using JSON3

struct CorpusManifestException <: Exception
    message::String
end

Base.showerror(io::IO, error::CorpusManifestException) = print(io, error.message)

struct CorpusManifest
    format::Int
    case_count::Int
    cases::Vector{String}
end

struct CorpusFixture
    name::String
    spec_source::String
    input_text::String
    expected_json::Any
end

struct CorpusValidationResult
    root::String
    manifest::CorpusManifest
    fixtures::Vector{CorpusFixture}
end

struct CorpusFixtureExecutionResult
    name::String
    expected_json::Any
    actual_value::Any
    actual_output::Any
    matched::Union{Nothing,Bool}
    cursor_codeunit::Union{Nothing,Int}
    trace_lines::Vector{String}
    diagnostic::Any
    failure::Union{Nothing,String}
end

struct CorpusExecutionResult
    validation::CorpusValidationResult
    results::Vector{CorpusFixtureExecutionResult}
end

corpus_fixture_passed(result::CorpusFixtureExecutionResult) = result.failure === nothing

corpus_failures(result::CorpusExecutionResult) = CorpusFixtureExecutionResult[
    fixture_result for fixture_result in result.results
    if !corpus_fixture_passed(fixture_result)
]

corpus_execution_passed(result::CorpusExecutionResult) = isempty(corpus_failures(result))

corpus_passed_count(result::CorpusExecutionResult) =
    count(corpus_fixture_passed, result.results)

function corpus_fixture_result(result::CorpusExecutionResult, name::AbstractString)
    fixture_name = String(name)
    index = findfirst(fixture_result -> fixture_result.name == fixture_name, result.results)
    if index === nothing
        throw(CorpusManifestException("executed corpus fixture not found: $fixture_name"))
    end
    return result.results[index]
end

function _print_corpus_help(io)
    println(io, "LinkedSpec Julia corpus runner")
    println(io)
    println(io, "Usage:")
    println(io, "  corpus_runner --corpus <path> [--execute]")
end

function _parse_corpus_runner_args(args)
    corpus_path = nothing
    execute = false
    help = false
    unknown = String[]

    index = firstindex(args)
    while index <= lastindex(args)
        arg = args[index]
        if arg == "--help" || arg == "-h"
            help = true
            index += 1
        elseif arg == "--execute"
            execute = true
            index += 1
        elseif arg == "--corpus"
            next_index = index + 1
            if next_index > lastindex(args)
                push!(unknown, "--corpus requires a path")
                index += 1
            else
                corpus_path = args[next_index]
                index += 2
            end
        else
            push!(unknown, arg)
            index += 1
        end
    end

    return (; corpus_path, execute, help, unknown)
end

function run_corpus_runner(args = ARGS; io = stdout, err = stderr)
    parsed = _parse_corpus_runner_args(args)
    if parsed.help || isempty(args)
        _print_corpus_help(io)
        return 0
    end

    if !isempty(parsed.unknown)
        println(err, "error: unknown corpus argument: ", join(parsed.unknown, ", "))
        return 2
    end

    if parsed.corpus_path === nothing
        println(err, "error: --corpus <path> is required")
        return 2
    end

    if parsed.execute
        println(err, "error: corpus --execute CLI is not enabled in the Julia backend yet")
        return 2
    end

    try
        validation = load_corpus_fixtures(parsed.corpus_path)
        println(io, "corpus: ", validation.root)
        println(io, "format: ", validation.manifest.format)
        println(io, "fixtures: ", validation.manifest.case_count)
        println(io, "status: manifest validated; library execution is available; CLI --execute is not enabled")
    catch error
        if error isa CorpusManifestException
            println(err, "error: ", error.message)
            return 2
        end
        rethrow()
    end

    return 0
end

function load_corpus_fixtures(corpus_path::AbstractString)
    root = String(corpus_path)
    if !isdir(root)
        throw(CorpusManifestException("corpus directory missing: $root"))
    end

    manifest = _load_manifest(root)
    _assert_manifest_matches_directories(root, manifest)

    fixtures = CorpusFixture[]
    for case_name in manifest.cases
        push!(fixtures, _load_fixture(root, case_name))
    end

    return CorpusValidationResult(root, manifest, fixtures)
end

function execute_corpus_fixtures(
    corpus_path::AbstractString;
    parse_mode = nothing,
    spec_parser = nothing,
    trace_config = nothing,
)
    validation = load_corpus_fixtures(corpus_path)
    effective_parse_mode = parse_mode === nothing ? SeekParseMode : parse_mode
    results = CorpusFixtureExecutionResult[
        _execute_corpus_fixture(
            validation,
            fixture;
            parse_mode = effective_parse_mode,
            spec_parser = spec_parser,
            trace_config = trace_config,
        )
        for fixture in validation.fixtures
    ]
    return CorpusExecutionResult(validation, results)
end

function _execute_corpus_fixture(
    validation::CorpusValidationResult,
    fixture::CorpusFixture;
    parse_mode,
    spec_parser,
    trace_config,
)
    parse_result = nothing
    trace = nothing
    try
        spec = spec_parser === nothing ? parse_spec(fixture.spec_source) : spec_parser(fixture.spec_source)
        compiled = compile_spec(spec)
        engine = LinkedSpecRuntimeEngine(
            compiled;
            parse_mode = parse_mode,
            spec_name = fixture.name,
            spec_path = joinpath(validation.root, fixture.name, "input.spec"),
        )
        if trace_config !== nothing
            trace = LinkedSpecTraceEmitter(trace_config; stdout_io = IOBuffer())
        end
        parse_result = runtime_execute(engine, fixture.input_text; trace = trace)
        expected_output = Any[fixture.expected_json]
        if !parse_result.matched
            return _corpus_fixture_failure(
                fixture,
                "runtime did not match input; cursor_codeunit=$(parse_result.cursor_codeunit)";
                parse_result = parse_result,
                trace = trace,
            )
        end
        if !isequal(parse_result.output, expected_output)
            return _corpus_fixture_failure(
                fixture,
                "output mismatch on input $(_format_corpus_json(fixture.input_text))\n" *
                "    expected (reference, wrapped): $(_format_corpus_json(expected_output))\n" *
                "    actual   (runtime_execute)    : $(_format_corpus_json(parse_result.output))";
                parse_result = parse_result,
                trace = trace,
            )
        end
        return CorpusFixtureExecutionResult(
            fixture.name,
            deepcopy(fixture.expected_json),
            deepcopy(parse_result.value),
            deepcopy(parse_result.output),
            parse_result.matched,
            parse_result.cursor_codeunit,
            _corpus_trace_lines(trace),
            nothing,
            nothing,
        )
    catch error
        return _corpus_fixture_failure(
            fixture,
            "$(_corpus_failure_stage(error)) failed: $(sprint(showerror, error))";
            parse_result = parse_result,
            trace = trace,
            diagnostic = error isa RuntimeInterpreterException ? error.diagnostic : nothing,
        )
    end
end

function _corpus_fixture_failure(
    fixture::CorpusFixture,
    failure::AbstractString;
    parse_result = nothing,
    trace = nothing,
    diagnostic = nothing,
)
    return CorpusFixtureExecutionResult(
        fixture.name,
        deepcopy(fixture.expected_json),
        parse_result === nothing ? nothing : deepcopy(parse_result.value),
        parse_result === nothing ? nothing : deepcopy(parse_result.output),
        parse_result === nothing ? nothing : parse_result.matched,
        parse_result === nothing ? nothing : parse_result.cursor_codeunit,
        _corpus_trace_lines(trace),
        diagnostic,
        String(failure),
    )
end

_corpus_trace_lines(trace) = trace === nothing ? String[] : String[trace_lines(trace)...]

function _corpus_failure_stage(error)
    if error isa SpecParseException ||
            error isa UserFunctionDefinitionException ||
            error isa StagedParserRegistryException
        return "parse"
    elseif error isa SpecValidationException
        return "validate"
    elseif error isa CompiledSpecException
        return "compile"
    elseif error isa RuntimeInterpreterException
        return "execute"
    end
    return "unexpected"
end

_format_corpus_json(value) = String(JSON3.write(value))

function _load_manifest(root::AbstractString)
    manifest_file = joinpath(root, "manifest.json")
    if !isfile(manifest_file)
        throw(CorpusManifestException("cannot read corpus manifest $manifest_file: file does not exist"))
    end

    decoded = try
        JSON3.read(read(manifest_file, String))
    catch error
        throw(CorpusManifestException("malformed corpus manifest $manifest_file: $(sprint(showerror, error))"))
    end

    if !(decoded isa AbstractDict)
        throw(CorpusManifestException("malformed corpus manifest $manifest_file: top-level value must be an object"))
    end

    format = _required_int(decoded, "format", manifest_file)
    if format != 1
        throw(CorpusManifestException("unsupported corpus manifest format $format in $manifest_file"))
    end

    case_count = _required_int(decoded, "case_count", manifest_file)
    cases = _required_string_list(decoded, "cases", manifest_file)
    if case_count != length(cases)
        throw(CorpusManifestException("corpus manifest case_count=$case_count does not match cases.len()=$(length(cases))"))
    end
    if case_count <= 0
        throw(CorpusManifestException("corpus manifest must name at least one fixture"))
    end

    _validate_case_names(cases)
    return CorpusManifest(format, case_count, cases)
end

function _required_int(manifest::AbstractDict, key::AbstractString, manifest_file::AbstractString)
    value = get(manifest, Symbol(key), nothing)
    if !(value isa Integer) || value isa Bool
        throw(CorpusManifestException("malformed corpus manifest $manifest_file: field $key must be an integer"))
    end
    return Int(value)
end

function _required_string_list(manifest::AbstractDict, key::AbstractString, manifest_file::AbstractString)
    value = get(manifest, Symbol(key), nothing)
    if !(value isa AbstractVector)
        throw(CorpusManifestException("malformed corpus manifest $manifest_file: field $key must be an array"))
    end

    result = String[]
    for item in value
        if !(item isa AbstractString)
            throw(CorpusManifestException("malformed corpus manifest $manifest_file: field $key must contain only strings"))
        end
        push!(result, String(item))
    end
    return result
end

function _validate_case_names(cases::Vector{String})
    seen = Set{String}()
    for name in cases
        if isempty(name) || contains(name, "/") || contains(name, "\\") || name == "." || name == ".."
            throw(CorpusManifestException("invalid corpus manifest case name: $name"))
        end
        if name in seen
            throw(CorpusManifestException("corpus manifest contains duplicate case names"))
        end
        push!(seen, name)
    end
end

function _assert_manifest_matches_directories(root::AbstractString, manifest::CorpusManifest)
    expected = Set(manifest.cases)
    actual = _directory_case_names(root)
    missing = _difference(expected, actual)
    extra = _difference(actual, expected)
    if !isempty(missing) || !isempty(extra)
        throw(CorpusManifestException(
            "oracle corpus manifest drift\n" *
            "  missing fixture dirs: $(_format_names(missing))\n" *
            "  extra fixture dirs: $(_format_names(extra))\n" *
            "regenerate with `perl tools/gen_oracle_corpus.pl` and stage the manifest plus fixture dirs",
        ))
    end
end

function _directory_case_names(root::AbstractString)
    result = Set{String}()
    for name in readdir(root)
        if isdir(joinpath(root, name))
            push!(result, name)
        end
    end
    return result
end

function _difference(left::Set{String}, right::Set{String})
    result = collect(setdiff(left, right))
    sort!(result)
    return result
end

function _load_fixture(root::AbstractString, case_name::AbstractString)
    case_dir = joinpath(root, case_name)
    spec_file = _required_fixture_file(case_dir, "input.spec")
    input_file = _required_fixture_file(case_dir, "input.txt")
    expected_file = _required_fixture_file(case_dir, "expected.json")

    expected_json = try
        _plain_json(JSON3.read(read(expected_file, String)))
    catch error
        throw(CorpusManifestException("malformed expected.json for corpus case $case_name: $(sprint(showerror, error))"))
    end

    return CorpusFixture(
        String(case_name),
        read(spec_file, String),
        read(input_file, String),
        expected_json,
    )
end

function _required_fixture_file(case_dir::AbstractString, file_name::AbstractString)
    file = joinpath(case_dir, file_name)
    if !isfile(file)
        throw(CorpusManifestException("missing required fixture file $file"))
    end
    return file
end

function _plain_json(value)
    if value isa JSON3.Object
        result = Dict{String,Any}()
        for key in keys(value)
            result[String(key)] = _plain_json(value[key])
        end
        return result
    elseif value isa JSON3.Array
        return Any[_plain_json(item) for item in value]
    end
    return value
end

function _format_names(names::Vector{String})
    return "[" * join(names, ", ") * "]"
end
