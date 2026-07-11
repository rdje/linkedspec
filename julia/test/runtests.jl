using LinkedSpecJulia
using JSON3
using Test

const REPO_ROOT = normpath(joinpath(@__DIR__, "..", ".."))
const CORPUS_ROOT = joinpath(REPO_ROOT, "rust", "linkedspec-runtime", "tests", "corpus")
const DESCRIPTOR_CONTRACT = JSON3.read(
    read(joinpath(REPO_ROOT, "capability_conformance", "outward_descriptor_contract.json"), String),
    Dict{String,Any},
)

function _throws_corpus_message(call, needle)
    try
        call()
    catch error
        return error isa CorpusManifestException && occursin(needle, sprint(showerror, error))
    end
    return false
end

function _throws_validation_message(call, needle)
    try
        call()
    catch error
        return error isa SpecValidationException && occursin(needle, sprint(showerror, error))
    end
    return false
end

function _throws_parse_message(call, needle)
    try
        call()
    catch error
        return error isa SpecParseException && occursin(needle, sprint(showerror, error))
    end
    return false
end

function _throws_user_function_message(call, needle)
    try
        call()
    catch error
        return error isa UserFunctionDefinitionException && occursin(needle, sprint(showerror, error))
    end
    return false
end

function _throws_compiled_spec_message(call, needle)
    try
        call()
    catch error
        return error isa CompiledSpecException && occursin(needle, sprint(showerror, error))
    end
    return false
end

function _write_manifest(root, cases; case_count = length(cases), format = 1)
    manifest = Dict(
        "format" => format,
        "case_count" => case_count,
        "cases" => cases,
    )
    write(joinpath(root, "manifest.json"), JSON3.write(manifest))
end

function _write_fixture(
    root,
    name;
    spec_source = "Top:: /x/",
    input_text = "x",
    expected_json = Any[],
    expected_text = nothing,
    write_expected = true,
)
    fixture = joinpath(root, name)
    mkpath(fixture)
    write(joinpath(fixture, "input.spec"), spec_source)
    write(joinpath(fixture, "input.txt"), input_text)
    if write_expected
        text = expected_text === nothing ? JSON3.write(expected_json) : expected_text
        write(joinpath(fixture, "expected.json"), text)
    end
end

function _returning_spec(value::AbstractString)
    return "Top::\n /x/\n E { return($(JSON3.write(String(value)))) }\n"
end

function _regex_patterns_of(rule::Rule)
    return [
        element.kind.pattern for element in rule.body
        if element.kind isa RegexBodyElementKind
    ]
end

function _starts_with_top_level_function(source::AbstractString)
    for line in split(source, '\n'; keepempty = true)
        trimmed = strip(line)
        if isempty(trimmed) || startswith(trimmed, "#")
            continue
        end
        return startswith(trimmed, "fn ")
    end
    return false
end

function _spec_with_functions(functions)
    rule = Rule(
        header = RuleHeader("Top", true, default_rule_mode(), "", 1),
        body = [BodyElement(RegexBodyElementKind("x"), "/x/", 2)],
    )
    return SpecFile(functions = functions, rules = [rule])
end

function _function_definition(name, params; arity = length(params))
    return FunctionDefinition(
        name = name,
        params = params,
        arity = arity,
        body_source = "return(value)",
        source = "fn $name($(join(params, ", "))) { return(value) }",
        source_span = SourceSpan(1, 1),
        body_span = SourceSpan(1, 1),
    )
end

function _function_with_body_sidecar(
    name,
    params;
    body_source = "return(value)",
    body_ast = nothing,
    index = 0,
)
    path = ["functions", string(index), "body_source"]
    span = StagedSourceSpan(0, 1, 1, 1)
    span_json = to_json(span)
    payload = Dict{String,Any}(
        "kind" => "staged_payload",
        "node_kind" => "function_definition",
        "payload_kind" => "function_body",
        "parent_ast_path" => path,
        "function_name" => name,
        "params" => params,
        "arity" => length(params),
        "text" => body_source,
        "source_span" => span_json,
    )
    job = StagedParseJob(
        version = 1,
        job_id = "parse_job:function_body:functions.$index.body_source",
        parent_ast_path = path,
        node_kind = "function_definition",
        payload_kind = "function_body",
        function_name = name,
        params = params,
        arity = length(params),
        text = body_source,
        source_span = span,
        parser_spec_id = "actionir-body.spec",
        top_rule = "action_block",
        result_policy = "replace_field",
        result_field = "body_ast",
        failure_policy = "fail",
        diagnostic_owner = "function_body",
    )
    return FunctionDefinition(
        name = name,
        params = params,
        arity = length(params),
        body_source = body_source,
        body_payload = payload,
        body_parse_job = job,
        body_ast = body_ast,
        source = "fn $name($(join(params, ", "))) { $body_source }",
        source_span = SourceSpan(1, 1),
        body_span = SourceSpan(1, 1),
    )
end

function _runtime_engine_with_functions(source, functions; kwargs...)
    parsed = parse_spec(source)
    staged = stitch_function_body_parse_jobs(SpecFile(
        functions = functions,
        rules = parsed.rules,
    ))
    return LinkedSpecRuntimeEngine(compile_spec(staged); kwargs...)
end

function _staged_job_with(
    job::StagedParseJob;
    parser_spec_id = job.parser_spec_id,
    top_rule = job.top_rule,
    result_field = job.result_field,
)
    return StagedParseJob(
        version = job.version,
        job_id = job.job_id,
        parent_ast_path = job.parent_ast_path,
        node_kind = job.node_kind,
        payload_kind = job.payload_kind,
        function_name = job.function_name,
        params = job.params,
        arity = job.arity,
        text = job.text,
        source_span = job.source_span,
        parser_spec_id = parser_spec_id,
        top_rule = top_rule,
        result_policy = job.result_policy,
        result_field = result_field,
        failure_policy = job.failure_policy,
        diagnostic_owner = job.diagnostic_owner,
    )
end

function _function_with_parse_job(definition::FunctionDefinition, job::StagedParseJob)
    return FunctionDefinition(
        name = definition.name,
        params = definition.params,
        arity = definition.arity,
        body_source = definition.body_source,
        body_payload = definition.body_payload,
        body_parse_job = job,
        body_ast = definition.body_ast,
        source = definition.source,
        source_span = definition.source_span,
        body_span = definition.body_span,
    )
end

function _canonical_names(resolution::ActionContractResolution)
    return [contract.canonical_name for contract in resolution.contracts]
end

function _action_contract(resolution::ActionContractResolution, source_name::AbstractString)
    matches = [contract for contract in resolution.contracts if contract.source_name == source_name]
    @test length(matches) == 1
    return only(matches)
end

function _diagnostic_codes(resolution::ActionContractResolution)
    return [diagnostic.code for diagnostic in resolution.diagnostics]
end

function _definition_node(source, name, params, body_source)
    source_start = _find_offset(source, "fn $name")
    body_start = _find_offset(source, body_source; start = source_start)
    body_end = body_start + length(collect(body_source))
    source_end = _find_offset(source, "}"; start = body_end) + 1
    source_text = _slice_chars(source, source_start, source_end)
    source_span = _span(source, source_start, source_end)
    body_span = _span(source, body_start, body_end)

    return Dict{String,Any}(
        "type" => "function_definition",
        "kind" => "user_function_definition",
        "version" => 1,
        "name" => name,
        "params" => params,
        "arity" => length(params),
        "source_text" => source_text,
        "source_span" => source_span,
        "body_source" => body_source,
        "body_span" => body_span,
        "body_payload" => Dict{String,Any}(
            "kind" => "staged_payload",
            "version" => 1,
            "node_kind" => "function_definition",
            "payload_kind" => "function_body",
            "parent_ast_path" => ["functions", "__pending_source_order__", "body_source"],
            "function_name" => name,
            "params" => params,
            "arity" => length(params),
            "text" => body_source,
            "source_span" => body_span,
            "provenance" => Any[
                Dict("kind" => "source_slice", "source_span" => body_span),
            ],
        ),
        "body_parse_job" => Dict{String,Any}(
            "kind" => "parse_job",
            "version" => 1,
            "job_id" => "parse_job:function_body:$name:actionir-body.spec:action_block",
            "parent_ast_path" => ["functions", "__pending_source_order__", "body_source"],
            "node_kind" => "function_definition",
            "payload_kind" => "function_body",
            "function_name" => name,
            "params" => params,
            "arity" => length(params),
            "text" => body_source,
            "source_span" => body_span,
            "parser_spec_id" => "actionir-body.spec",
            "top_rule" => "action_block",
            "result_policy" => "replace_field",
            "result_field" => "body_ast",
            "failure_policy" => "fail",
            "diagnostic_owner" => "function_body",
        ),
    )
end

function _find_offset(source, needle; start = 0)
    chars = collect(source)
    needle_chars = collect(needle)
    if isempty(needle_chars)
        return start
    end
    last_start = length(chars) - length(needle_chars) + 1
    for index in (start + 1):last_start
        if chars[index:(index + length(needle_chars) - 1)] == needle_chars
            return index - 1
        end
    end
    error("missing $needle")
end

function _slice_chars(source, start, stop)
    if start == stop
        return ""
    end
    return String(collect(source)[(start + 1):stop])
end

function _span(source, start, stop)
    return Dict{String,Any}(
        "start" => start,
        "end" => stop,
        "line_start" => _line_at(source, start),
        "line_end" => _line_at(source, stop),
    )
end

function _line_at(source, offset)
    line = 1
    for (index, char) in enumerate(collect(source))
        if index > offset
            break
        end
        if char == '\n'
            line += 1
        end
    end
    return line
end

@testset "LinkedSpecJulia scaffold" begin
    @test backend_name() == "julia"
    @test cli_entrypoint() == "julia/bin/linkedspec_julia.jl"
    @test corpus_runner_entrypoint() == "julia/bin/corpus_runner.jl"

    status = backend_status()
    @test status.backend == "julia"
    @test status.package == "LinkedSpecJulia"
    @test status.parity == "runtime-corpus-primary-cli"

    cli_output = IOBuffer()
    cli_error = IOBuffer()
    @test run_cli(["--help"]; io = cli_output, err = cli_error) == 0
    cli_text = String(take!(cli_output))
    @test occursin("linkedspec_julia --spec NAME --input TEXT", cli_text)
    @test occursin("--inline-spec TEXT", cli_text)
    @test !occursin("--case <name>", cli_text)
    @test isempty(String(take!(cli_error)))

    status_output = IOBuffer()
    status_error = IOBuffer()
    @test run_cli(["status"]; io = status_output, err = status_error) == 2
    @test isempty(String(take!(status_output)))
    @test occursin("unexpected positional argument 'status'", String(take!(status_error)))

    corpus_output = IOBuffer()
    corpus_error = IOBuffer()
    @test run_corpus_runner(["--corpus", CORPUS_ROOT];
        io = corpus_output,
        err = corpus_error,
    ) == 0
    @test occursin("manifest validated", String(take!(corpus_output)))
    @test isempty(String(take!(corpus_error)))

    help_output = IOBuffer()
    @test run_corpus_runner(["--help"]; io = help_output, err = IOBuffer()) == 0
    @test occursin("runs the complete corpus", String(take!(help_output)))
end

@testset "Primary CLI arguments resolution and loading" begin
    function usage_failure(args, needle)
        output = IOBuffer()
        error_output = IOBuffer()
        status = run_cli(args; io = output, err = error_output)
        return status == 2 &&
            isempty(String(take!(output))) &&
            occursin(needle, String(take!(error_output)))
    end

    function preparation_error(options; cwd = pwd(), repo_root = REPO_ROOT)
        try
            LinkedSpecJulia._prepare_primary_cli_request(
                options;
                cwd = cwd,
                repo_root = repo_root,
            )
        catch error
            return error
        end
        return nothing
    end

    shared_help = replace(
        read(joinpath(REPO_ROOT, "cli_conformance", "cases", "help", "stdout.txt"), String),
        "{{COMMAND}}" => "linkedspec_julia",
    )
    help_output = IOBuffer()
    help_error = IOBuffer()
    @test run_cli(["--help"]; io = help_output, err = help_error) == 0
    @test String(take!(help_output)) == shared_help
    @test isempty(String(take!(help_error)))

    inline_options = LinkedSpecJulia._parse_primary_cli_args([
        "--input=x",
        "--inline-spec=Top:: /x/",
        "--top-rule",
        "Top",
        "--parse-mode",
        "consume",
        "--trace",
        "DEBUG",
        "--trace-file",
        "trace.log",
        "--trace-mode",
        "route",
        "--trace-reset",
        "--trace-emoji",
    ])
    @test inline_options.inline_spec == "Top:: /x/"
    @test inline_options.input == "x"
    @test inline_options.top_rule == "Top"
    @test inline_options.parse_mode == "consume"
    @test inline_options.trace_level == "DEBUG"
    @test inline_options.trace_file == "trace.log"
    @test inline_options.trace_mode == "route"
    @test inline_options.trace_reset
    @test inline_options.trace_emoji
    @test all(
        level -> LinkedSpecJulia._parse_primary_cli_args([
            "--inline-spec",
            "Top:: /x/",
            "--input",
            "x",
            "--trace",
            level,
        ]).trace_level == level,
        ("none", "quiet", "low", "medium", "med", "high", "full", "debug", "verbose", "350", "-1"),
    )

    repeated = LinkedSpecJulia._parse_primary_cli_args([
        "--inline-spec",
        "first",
        "--inline-spec",
        "second",
        "--input",
        "value",
    ])
    @test repeated.inline_spec == "second"

    @test usage_failure(String[], "choose exactly one source option")
    @test usage_failure(["status"], "unexpected positional argument 'status'")
    @test usage_failure(["corpus"], "unexpected positional argument 'corpus'")
    @test usage_failure(["--unknown"], "unknown option '--unknown'")
    @test usage_failure(["--inline-spec", "Top:: /x/"], "choose exactly one input option")
    @test usage_failure(
        ["--inline-spec", "Top:: /x/", "--spec", "Lispish", "--input", "x"],
        "choose exactly one source option",
    )
    @test usage_failure(
        ["--inline-spec", "Top:: /x/", "--input", "x", "--input-file", "input.txt"],
        "choose exactly one input option",
    )
    @test usage_failure(
        ["--inline-spec", "Top:: /x/", "--input", "x", "--parse-mode", "scan"],
        "--parse-mode must be 'seek' or 'consume'",
    )
    @test usage_failure(
        ["--inline-spec", "Top:: /x/", "--input", "x", "--trace", "loud"],
        "--trace has an unsupported level 'loud'",
    )
    @test usage_failure(
        ["--inline-spec", "Top:: /x/", "--input", "x", "--trace", "off"],
        "--trace has an unsupported level 'off'",
    )
    @test usage_failure(
        ["--inline-spec", "Top:: /x/", "--input", "x", "--trace-mode", "both"],
        "--trace-mode must be 'stdout', 'route', or 'mirror'",
    )
    @test usage_failure(["--spec"], "--spec requires a value")
    @test usage_failure(["--help=1"], "--help does not accept a value")
    @test usage_failure(["--trace-reset=yes"], "--trace-reset does not accept a value")

    named_options = LinkedSpecJulia._parse_primary_cli_args([
        "--spec",
        "Lispish",
        "--input",
        "(hello world)",
    ])
    named_request = LinkedSpecJulia._prepare_primary_cli_request(named_options)
    @test named_request.spec_path == joinpath(REPO_ROOT, "specs", "Lispish.spec")
    @test named_request.spec_source == read(named_request.spec_path, String)
    @test named_request.spec_name == "Lispish"
    @test named_request.input == "(hello world)"
    @test named_request.input_path === nothing

    inline_request = LinkedSpecJulia._prepare_primary_cli_request(inline_options)
    @test inline_request.spec_source == "Top:: /x/"
    @test inline_request.spec_name == "<inline>"
    @test inline_request.spec_path === nothing
    @test inline_request.input == "x"

    mktempdir() do directory
        spec_source = "Top::\n /loaded/\n"
        input_source = "loaded input\n"
        write(joinpath(directory, "demo.spec"), spec_source)
        write(joinpath(directory, "demo.txt"), input_source)

        file_options = LinkedSpecJulia._parse_primary_cli_args([
            "--spec-file",
            "demo.spec",
            "--input-file",
            "demo.txt",
        ])
        file_request = LinkedSpecJulia._prepare_primary_cli_request(
            file_options;
            cwd = directory,
            repo_root = REPO_ROOT,
        )
        @test file_request.spec_source == spec_source
        @test file_request.spec_path == joinpath(directory, "demo.spec")
        @test file_request.input == input_source
        @test file_request.input_path == joinpath(directory, "demo.txt")

        write(joinpath(directory, "choice"), "exact")
        write(joinpath(directory, "choice.spec"), "with extension")
        @test LinkedSpecJulia._resolve_named_spec_path(
            "choice";
            cwd = directory,
            repo_root = REPO_ROOT,
        ) == joinpath(directory, "choice")

        directory_error = preparation_error(
            LinkedSpecJulia._parse_primary_cli_args([
                "--spec-file",
                directory,
                "--input",
                "x",
            ]),
        )
        @test directory_error isa LinkedSpecJulia._PrimaryCliLoadException
        @test occursin("spec file is not a file", sprint(showerror, directory_error))

        invalid_spec_path = joinpath(directory, "invalid.spec")
        invalid_input_path = joinpath(directory, "invalid.txt")
        write(invalid_spec_path, UInt8[0x54, 0x6f, 0x70, 0x3a, 0x3a, 0xff])
        write(invalid_input_path, UInt8[0x78, 0xff])
        invalid_spec_error = preparation_error(
            LinkedSpecJulia._parse_primary_cli_args([
                "--spec-file",
                invalid_spec_path,
                "--input",
                "x",
            ]),
        )
        @test invalid_spec_error isa LinkedSpecJulia._PrimaryCliLoadException
        @test occursin("spec file is not valid UTF-8", sprint(showerror, invalid_spec_error))

        invalid_input_error = preparation_error(
            LinkedSpecJulia._parse_primary_cli_args([
                "--inline-spec",
                "Top:: /x/",
                "--input-file",
                invalid_input_path,
            ]),
        )
        @test invalid_input_error isa LinkedSpecJulia._PrimaryCliLoadException
        @test occursin("input file is not valid UTF-8", sprint(showerror, invalid_input_error))
    end

    mktempdir() do repository
        mkpath(joinpath(repository, "specs"))
        mkpath(joinpath(repository, "authored", "nested"))
        mkpath(joinpath(repository, "target", "generated"))
        write(joinpath(repository, "specs", "Priority.spec"), "repo specs")
        write(joinpath(repository, "authored", "Priority.spec"), "fallback")
        write(joinpath(repository, "authored", "nested", "Fallback.spec"), "nested")
        write(joinpath(repository, "target", "generated", "Pruned.spec"), "generated")

        @test LinkedSpecJulia._resolve_named_spec_path(
            "Priority";
            cwd = repository,
            repo_root = repository,
        ) == joinpath(repository, "specs", "Priority.spec")
        @test LinkedSpecJulia._resolve_named_spec_path(
            "Fallback";
            cwd = repository,
            repo_root = repository,
        ) == joinpath(repository, "authored", "nested", "Fallback.spec")
        fallback_error = try
            LinkedSpecJulia._resolve_named_spec_path(
                "Pruned";
                cwd = repository,
                repo_root = repository,
            )
            nothing
        catch error
            error
        end
        @test fallback_error isa LinkedSpecJulia._PrimaryCliLoadException

        explicit_error = try
            LinkedSpecJulia._resolve_named_spec_path(
                "Fallback.spec";
                cwd = repository,
                repo_root = repository,
            )
            nothing
        catch error
            error
        end
        @test explicit_error isa LinkedSpecJulia._PrimaryCliLoadException
    end

    missing_input = preparation_error(LinkedSpecJulia._parse_primary_cli_args([
        "--inline-spec",
        "Top:: /x/",
        "--input-file",
        "definitely-missing-input.txt",
    ]))
    @test missing_input isa LinkedSpecJulia._PrimaryCliLoadException
    @test occursin("input file not found", sprint(showerror, missing_input))

    prepared_output = IOBuffer()
    prepared_error = IOBuffer()
    @test run_cli(
        ["--inline-spec", _returning_spec("prepared"), "--input", "x"];
        io = prepared_output,
        err = prepared_error,
    ) == 0
    @test String(take!(prepared_output)) == "\"prepared\"\n"
    @test isempty(String(take!(prepared_error)))
end

@testset "Primary CLI execution and canonical JSON" begin
    function cli_run(args)
        output = IOBuffer()
        error_output = IOBuffer()
        status = run_cli(args; io = output, err = error_output)
        return status, String(take!(output)), String(take!(error_output))
    end

    canonical_value = Dict{String,Any}()
    canonical_value["z"] = Any[nothing, true, "line\n\"quoted\""]
    canonical_value["a"] = Dict{String,Any}("delta" => 4, "beta" => 2)
    @test LinkedSpecJulia._primary_cli_canonical_json(canonical_value) ==
        "{\"a\":{\"beta\":2,\"delta\":4},\"z\":[null,true,\"line\\n\\\"quoted\\\"\"]}"
    @test LinkedSpecJulia._primary_cli_canonical_json((1, false, nothing)) ==
        "[1,false,null]"
    @test_throws ArgumentError LinkedSpecJulia._primary_cli_canonical_json(Dict(1 => "x"))

    hash_spec = raw"""
Top::
 /x/
 E { return(hash("z", 0, "a", hash("d", 4, "b", 2))) }
"""
    status, output, error_output = cli_run([
        "--inline-spec",
        hash_spec,
        "--input",
        "x",
    ])
    @test status == 0
    @test output == "{\"a\":{\"b\":2,\"d\":4},\"z\":0}\n"
    @test isempty(error_output)

    top_rule_spec = raw"""
Top::
 /x/
 E { return("top") }

Alternate:
 /x/
 E { return("alternate") }
"""
    status, output, error_output = cli_run([
        "--inline-spec",
        top_rule_spec,
        "--input",
        "x",
        "--top-rule",
        "Alternate",
        "--parse-mode",
        "consume",
    ])
    @test status == 0
    @test output == "\"alternate\"\n"
    @test isempty(error_output)

    consume_spec = raw"""
Top::AND
 /ab/
 /cd/
 E { return(match_text()) }
"""
    consume_args = [
        "--inline-spec",
        consume_spec,
        "--input",
        "prefix abcd",
        "--parse-mode",
        "consume",
    ]
    status, output, error_output = cli_run(consume_args)
    @test status == 0
    @test output == "null\n"
    @test isempty(error_output)

    function_spec = raw"""
fn wrap(value) { return(hash("wrapped", value)) }
Top::
 /x/
 E { return(wrap(match_text())) }
"""
    status, output, error_output = cli_run([
        "--inline-spec",
        function_spec,
        "--input",
        "x",
    ])
    @test status == 0
    @test output == "{\"wrapped\":\"x\"}\n"
    @test isempty(error_output)

    mktempdir() do directory
        spec_path = joinpath(directory, "file.spec")
        input_path = joinpath(directory, "input.txt")
        trace_path = joinpath(directory, "trace.log")
        write(spec_path, _returning_spec("file"))
        write(input_path, "x")
        write(trace_path, "stale trace\n")

        status, output, error_output = cli_run([
            "--spec-file",
            spec_path,
            "--input-file",
            input_path,
            "--trace",
            "high",
            "--trace-file",
            trace_path,
            "--trace-mode",
            "route",
            "--trace-reset",
        ])
        @test status == 0
        @test output == "\"file\"\n"
        @test isempty(error_output)
        trace_text = read(trace_path, String)
        @test !occursin("stale trace", trace_text)
        @test trace_text ==
            "[linkedspec][low] compile:start\n" *
            "[linkedspec][medium] request source=file input=file " *
            "top_rule=<default> parse_mode=seek\n" *
            "[linkedspec][high] arguments source_bytes=$(ncodeunits(spec_path)) " *
            "input_bytes=$(ncodeunits(input_path))\n" *
            "[linkedspec][low] compile:ok\n" *
            "[linkedspec][low] input:start\n" *
            "[linkedspec][high] input bytes=1\n" *
            "[linkedspec][low] input:ok\n" *
            "[linkedspec][low] invoke:start\n" *
            "[linkedspec][low] invoke:ok\n"
    end
end

@testset "Primary CLI failures and trace routing" begin
    function cli_run(args)
        output = IOBuffer()
        error_output = IOBuffer()
        status = run_cli(args; io = output, err = error_output)
        return status, String(take!(output)), String(take!(error_output))
    end

    missing_input_path = joinpath(
        tempdir(),
        "definitely-missing-linkedspec-primary-input.txt",
    )
    status, output, error_output = cli_run([
        "--inline-spec",
        "not a spec",
        "--input-file",
        missing_input_path,
    ])
    @test status == 1
    @test isempty(output)
    @test error_output == "linkedspec: parser compilation failed\n"
    @test !occursin("input load failed", error_output)

    status, output, error_output = cli_run([
        "--spec-file",
        joinpath(tempdir(), "definitely-missing-linkedspec-primary.spec"),
        "--input",
        "x",
    ])
    @test status == 1
    @test isempty(output)
    @test error_output == "linkedspec: parser compilation failed\n"

    status, output, error_output = cli_run([
        "--inline-spec",
        _returning_spec("unused"),
        "--input-file",
        missing_input_path,
    ])
    @test status == 1
    @test isempty(output)
    @test error_output == "linkedspec: input load failed\n"

    status, output, error_output = cli_run([
        "--inline-spec",
        "Top::\n /x/\n",
        "--input",
        "x",
        "--top-rule",
        "Missing",
    ])
    @test status == 1
    @test isempty(output)
    @test error_output == "linkedspec: parser invocation failed\n"
    @test LinkedSpecJulia._primary_cli_fatal_error(InterruptException())
    @test LinkedSpecJulia._primary_cli_fatal_error(OutOfMemoryError())
    @test LinkedSpecJulia._primary_cli_fatal_error(StackOverflowError())
    @test !LinkedSpecJulia._primary_cli_fatal_error(ArgumentError("ordinary"))
    @test LinkedSpecJulia._primary_cli_valid_trace_level("999999999999999999999")
    @test all(
        value -> !LinkedSpecJulia._primary_cli_valid_trace_level(value),
        ("+1", "-"),
    )
    @test LinkedSpecJulia._primary_cli_trace_level_number("med") == 200
    @test LinkedSpecJulia._primary_cli_trace_level_number("250") == 250
    @test LinkedSpecJulia._primary_cli_trace_level_number("999999999999999999999") > 500
    @test LinkedSpecJulia._primary_cli_trace_field("A β\n") == "A%20%CE%B2%0A"

    mktempdir() do directory
        trace_path = joinpath(directory, "trace.log")
        trace_spec = _returning_spec("trace")
        base_args = ["--inline-spec", trace_spec, "--input", "x", "--trace", "high"]
        expected_json = "\"trace\"\n"
        expected_trace =
            "[linkedspec][low] compile:start\n" *
            "[linkedspec][medium] request source=inline input=literal " *
            "top_rule=<default> parse_mode=seek\n" *
            "[linkedspec][high] arguments source_bytes=$(ncodeunits(trace_spec)) input_bytes=1\n" *
            "[linkedspec][low] compile:ok\n" *
            "[linkedspec][low] input:start\n" *
            "[linkedspec][high] input bytes=1\n" *
            "[linkedspec][low] input:ok\n" *
            "[linkedspec][low] invoke:start\n" *
            "[linkedspec][low] invoke:ok\n"

        identified_spec_path = joinpath(directory, "identified.spec")
        write(identified_spec_path, trace_spec)
        status, output, error_output = cli_run([
            "--spec-file",
            identified_spec_path,
            "--input",
            "x",
            "--top-rule",
            "Missing",
        ])
        @test status == 1
        @test isempty(output)
        @test error_output == "linkedspec: parser invocation failed\n"

        status, output, error_output = cli_run([base_args..., "--trace-mode", "stdout"])
        @test status == 0
        @test output == expected_trace * expected_json
        @test isempty(error_output)

        write(trace_path, "stale\n")
        status, output, error_output = cli_run([
            base_args...,
            "--trace-file",
            trace_path,
            "--trace-reset",
        ])
        @test status == 0
        @test output == expected_json
        @test isempty(error_output)
        routed_trace = read(trace_path, String)
        @test routed_trace == expected_trace

        status, output, error_output = cli_run([
            base_args...,
            "--trace-file",
            trace_path,
            "--trace-mode",
            "mirror",
            "--trace-reset",
        ])
        mirrored_trace = read(trace_path, String)
        @test status == 0
        @test !isempty(mirrored_trace)
        @test output == mirrored_trace * expected_json
        @test isempty(error_output)

        write(trace_path, "stale\n")
        status, output, error_output = cli_run([
            base_args...,
            "--trace-file",
            trace_path,
            "--trace-mode",
            "stdout",
            "--trace-reset",
        ])
        @test status == 0
        @test output == expected_trace * expected_json
        @test isempty(read(trace_path, String))
        @test isempty(error_output)

        write(trace_path, "preserved\n")
        status, output, error_output = cli_run([
            base_args...,
            "--trace-file",
            trace_path,
            "--trace-mode",
            "stdout",
        ])
        @test status == 0
        @test output == expected_trace * expected_json
        @test read(trace_path, String) == "preserved\n"
        @test isempty(error_output)

        status, output, error_output = cli_run([
            base_args...,
            "--trace-file",
            "",
        ])
        @test status == 0
        @test output == expected_trace * expected_json
        @test isempty(error_output)

        status, output, error_output = cli_run([base_args..., "--trace-mode", "route"])
        @test status == 0
        @test output == expected_json
        @test isempty(error_output)

        status, output, error_output = cli_run([base_args..., "--trace-mode", "mirror"])
        @test status == 0
        @test output == expected_trace * expected_json
        @test isempty(error_output)

        status, output, error_output = cli_run([
            base_args...,
            "--trace-mode",
            "stdout",
            "--trace-emoji",
        ])
        @test status == 0
        @test occursin("ℹ️ ", output)
        @test occursin("🔎 ", output)
        @test occursin("🧭 ", output)
        @test endswith(output, expected_json)
        @test !occursin("julia_", output)
        @test isempty(error_output)

        status, output, error_output = cli_run([
            "--inline-spec",
            trace_spec,
            "--input",
            "x",
            "--trace",
            "none",
            "--trace-emoji",
        ])
        @test status == 0
        @test output == expected_json
        @test isempty(error_output)

        write(trace_path, "stale\n")
        status, output, error_output = cli_run([
            "--inline-spec",
            trace_spec,
            "--input",
            "x",
            "--trace-file",
            trace_path,
            "--trace-reset",
        ])
        @test status == 0
        @test output == expected_json
        @test isempty(read(trace_path, String))
        @test isempty(error_output)

        status, output, error_output = cli_run([
            base_args...,
            "--trace-file",
            directory,
        ])
        @test status == 1
        @test isempty(output)
        @test error_output == "linkedspec: parser compilation failed\n"
    end
end

@testset "Action AST parser" begin
    block = parse_action_block(
        "set(array(results), []); push(array(results), retv)\n" *
        "return(copy(array(results)))",
    )
    @test block.kind == "action_block"
    @test length(block.statements) == 3
    @test all(statement -> statement.drops_value, block.statements)
    @test block.statements[1].expr isa ActionCallExpr
    @test block.statements[1].expr.name == "set"
    @test block.statements[1].expr.args[1].value isa ActionCallExpr
    @test block.statements[1].expr.args[2].value isa ActionArrayLiteralExpr
    @test block.statements[2].expr.name == "push"
    @test block.statements[2].expr.args[2].value isa ActionVariableExpr

    @test parse_action_expression("42") isa ActionNumberLiteralExpr
    @test parse_action_expression("true") isa ActionBooleanLiteralExpr
    @test parse_action_expression("undef") isa ActionUndefExpr
    @test parse_action_expression("/a\\\\sb/i") isa ActionRegexLiteralExpr

    nested = parse_action_expression("foo[\"a\"][i][0]")
    @test nested isa ActionNestedAccessExpr
    @test nested.base == "foo"
    @test [segment.kind for segment in nested.segments] == ["key", "index", "index"]

    array = parse_action_expression("[value, true, []]")
    @test array isa ActionArrayLiteralExpr
    @test [item.kind for item in array.items] == ["variable", "boolean", "array_literal"]

    hash = parse_action_expression("{ key : value, \"fixed\" : [value] }")
    @test hash isa ActionHashLiteralExpr
    @test hash.entries[1].key isa ActionVariableExpr
    @test hash.entries[2].key isa ActionStringLiteralExpr
    @test hash.entries[2].value isa ActionArrayLiteralExpr
    @test parse_action_expression("{ key => value }") isa ActionRawExpr
    @test parse_action_expression("{ key => value }").reason == "hash_literal_use_colon"

    assignment = parse_action_expression("items = [value]")
    @test assignment isa ActionAssignScalarExpr
    @test assignment.name == "items"
    @test assignment.value isa ActionArrayLiteralExpr

    append = parse_action_expression("items += value")
    @test append isa ActionAssignArrayAppendExpr
    @test append.name == "items"
    @test append.value isa ActionVariableExpr

    hash_assignment = parse_action_expression("meta[key] = { stage : value }")
    @test hash_assignment isa ActionAssignHashIndexExpr
    @test hash_assignment.key isa ActionVariableExpr
    @test hash_assignment.value isa ActionHashLiteralExpr

    nested_assignment = parse_action_expression("payload[\"children\"][0][\"name\"] = value")
    @test nested_assignment isa ActionAssignNestedAccessExpr
    @test length(nested_assignment.segments) == 3

    assignment_chain = parse_action_expression("(items += value).count()")
    @test assignment_chain isa ActionFluentChainExpr
    @test assignment_chain.receiver isa ActionAssignArrayAppendExpr
    @test only(assignment_chain.calls).method == "count"

    call_with_assignment = parse_action_expression("array(items = [value], copy(array(items)))")
    @test call_with_assignment isa ActionCallExpr
    @test call_with_assignment.args[1] isa ActionPositionalArgument
    @test call_with_assignment.args[1].value isa ActionAssignScalarExpr

    chain = parse_action_expression("\" raw \".trim().split(\"-\").count()")
    @test chain isa ActionFluentChainExpr
    @test chain.receiver isa ActionStringLiteralExpr
    @test [call.method for call in chain.calls] == ["trim", "split", "count"]

    with_call = parse_action_expression("with(\"x\") { return(value) }")
    @test with_call isa ActionCallExpr
    @test with_call.trailing_block_arg
    @test with_call.args[end].value isa ActionBlockValueExpr

    receiver_with = parse_action_expression("\"x\".with() { return(value) }")
    @test receiver_with isa ActionFluentChainExpr
    @test only(receiver_with.calls).method == "with"
    @test only(receiver_with.calls).receiver_trailing_block_arg
    @test only(receiver_with.calls).args[1].value isa ActionBlockValueExpr

    print_call = parse_action_expression("print(\"begin_end_blocks: BEGIN   (\", entry_text(), \"\\n\")")
    @test print_call isa ActionCallExpr
    @test print_call.name == "print"
    @test length(print_call.args) == 3
    @test print_call.args[1].value isa ActionStringLiteralExpr

    block_value = parse_action_expression("{ set(x, \"a\"); x }")
    @test block_value isa ActionBlockValueExpr
    @test length(block_value.block.statements) == 2
    @test block_value.block.statements[end].expr isa ActionVariableExpr

    if_node = parse_action_expression("if(flag) { set(out, \"yes\") }")
    @test if_node isa ActionControlIfExpr
    @test if_node.keyword == "if"
    @test if_node.condition isa ActionVariableExpr
    @test only(if_node.body.statements).expr isa ActionCallExpr

    branch_block = parse_action_block(
        "if(false) { set(out, \"bad\") } " *
        "elseif(true) { set(out, \"yes\") } " *
        "else { set(out, \"no\") }",
    )
    @test [statement.expr.kind for statement in branch_block.statements] == [
        "control_if",
        "control_if",
        "control_else",
    ]
    @test branch_block.statements[2].expr.branch_role == "elseif"

    while_node = parse_action_expression("while(flag) { next() }")
    @test while_node isa ActionControlWhileExpr
    @test while_node.condition isa ActionVariableExpr
    @test only(while_node.body.statements).expr isa ActionCallExpr

    switch_node = parse_action_expression(
        "switch(kind) { case(\"a\") { return(\"hit\") } default { return(\"miss\") } }",
    )
    @test switch_node isa ActionControlSwitchExpr
    @test switch_node.source_expr isa ActionVariableExpr
    @test length(switch_node.cases) == 1
    @test switch_node.default_case !== nothing

    raw = parse_action_expression("@invalid")
    @test raw isa ActionRawExpr
    @test raw.reason == "unsupported_expression"
    @test to_json(raw)["kind"] == "raw_perl"
end

@testset "Action contract resolver" begin
    block = parse_action_block(
        "set(out, +(1, 2));\n" *
        "if(gt(out, 0)) { return(cat(\"ok\", out)) }\n" *
        "\" x \".trim().with() { return(value) }",
    )
    resolution = resolve_action_block_contracts(block)

    @test resolution.ok
    @test all(name -> name in _canonical_names(resolution), ["set", "num_add", "if", "num_gt"])
    @test all(name -> name in _canonical_names(resolution), ["return", "cat", "trim", "with"])

    add_contract = _action_contract(resolution, "+")
    @test add_contract.canonical_name == "num_add"
    @test add_contract.family == "numeric"
    @test canonicalized(add_contract)

    gt_contract = _action_contract(resolution, "gt")
    @test gt_contract.canonical_name == "num_gt"
    @test gt_contract.positional_arg_count == 2

    assignments = resolve_action_block_contracts(parse_action_block(
        "name = \"ok\"; items += name; meta[name] = [name]; " *
        "payload[\"children\"][0][\"name\"] = name",
    ))
    @test assignments.ok
    @test _action_contract(assignments, "=").canonical_name == "set"
    @test _action_contract(assignments, "+=").canonical_name == "push"
    @test _action_contract(assignments, "[]=").canonical_name == "set_key"
    @test _action_contract(assignments, "nested_access=").canonical_name == "nested_access_assignment"

    unknown = resolve_action_block_contracts(parse_action_block("unknown_helper(value); @invalid"))
    @test !unknown.ok
    @test _diagnostic_codes(unknown) == ["unknown_helper", "raw_perl"]
    @test unknown.diagnostics[1].helper_name == "unknown_helper"
    @test occursin("canonical ActionIR helper contract", unknown.diagnostics[1].message)

    @test is_known_action_ir_call_name("cat")
    @test is_known_action_ir_call_name("gt")
    @test is_known_action_ir_call_name("push_back")
    @test is_known_action_ir_call_name("sorted_keys")
    @test is_known_action_ir_call_name("save_cursor")
    @test is_known_action_ir_call_name("restore_cursor")
    @test is_known_action_ir_call_name("rewind_match_start")
    @test is_known_action_ir_call_name("rewind_entry_start")
    @test is_known_action_ir_call_name("entry_end_line")
    @test is_known_action_ir_call_name("match_end_line")
    @test is_known_action_ir_call_name("capture_until_boundary")
    @test is_known_action_ir_call_name("mark_capture_slice")
    @test is_known_action_ir_call_name("start_capture_slice_from")
    @test !is_known_action_ir_call_name("BACKTRACK")
    @test !is_known_action_ir_call_name("IBACKTRACK")
    @test !is_known_action_ir_call_name("mystery_helper")
    @test canonical_action_helper_name(">=") == "num_ge"

    collision = _spec_with_functions([_function_definition("cat", ["value"])])
    @test _throws_validation_message(() -> validate_spec(collision), "built-in helper/control name")
end

@testset "User function registry" begin
    zero_ast = Dict{String,Any}("kind" => "action_block", "statements" => Any[])
    zero = _function_with_body_sidecar(
        "zero",
        String[];
        body_source = "return(\"zero\")",
        body_ast = zero_ast,
        index = 0,
    )
    normalize = _function_with_body_sidecar(
        "normalize",
        ["value"];
        body_source = "return(value.trim())",
        index = 1,
    )
    registry = user_function_registry_from_functions([zero, normalize])

    @test user_function_names(registry) == ["zero", "normalize"]
    @test [job.job_id for job in body_parse_jobs(registry)] == [
        "parse_job:function_body:functions.0.body_source",
        "parse_job:function_body:functions.1.body_source",
    ]

    zero_resolution = resolve_user_function_call(registry, "zero", 0)
    @test zero_resolution.matched
    @test zero_resolution.entry.index == 0
    @test zero_resolution.entry.definition.params == String[]
    @test zero_resolution.entry.definition.body_ast == zero_ast
    @test zero_resolution.entry.definition.body_parse_job.parent_ast_path == [
        "functions",
        "0",
        "body_source",
    ]

    mismatch = resolve_user_function_call(registry, "normalize", 2)
    @test mismatch.name_known
    @test mismatch.arity_mismatch
    @test mismatch.expected_arities == [1]

    missing = resolve_user_function_call(registry, "missing", 0)
    @test !missing.name_known

    encoded = to_json(registry)
    @test encoded["functions"] isa Vector
    @test encoded["body_parse_jobs"] isa Vector

    spec = SpecFile(functions = [zero, normalize], rules = [
        Rule(
            header = RuleHeader("Top", true, default_rule_mode(), "", 1),
            body = [BodyElement(RegexBodyElementKind("x"), "/x/", 2)],
        ),
    ])
    stitched_ast = Dict{String,Any}("kind" => "action_block", "statements" => [Dict("kind" => "action_stmt")])
    stitched = stitch_function_body_ast(
        spec,
        "parse_job:function_body:functions.1.body_source",
        stitched_ast,
    )
    @test stitched.functions[1].body_ast == zero_ast
    @test stitched.functions[2].body_ast == stitched_ast
    @test spec.functions[2].body_ast === nothing

    @test_throws UserFunctionRegistryException user_function_registry_from_functions([
        _function_with_body_sidecar("dup", ["value"], index = 0),
        _function_with_body_sidecar("dup", ["other"], index = 1),
    ])

    block = parse_action_block(
        "return(normalize(\" x \")); normalize(\"x\", \"y\"); mystery(\"z\")",
    )
    resolution = resolve_action_block_contracts(block; function_registry = registry)
    user_contract = _action_contract(resolution, "normalize")
    @test user_contract.family == "user_function"
    @test user_contract.canonical_name == "normalize"
    @test user_contract.positional_arg_count == 1
    @test _diagnostic_codes(resolution) == ["user_function_arity_mismatch", "unknown_helper"]
    @test occursin("expects arity 1, got 2", resolution.diagnostics[1].message)
end

@testset "Staged function-body parser registry" begin
    earlier = _function_with_body_sidecar(
        "earlier",
        String[];
        body_source = "return(\"a\")",
        index = 0,
    )
    later = _function_with_body_sidecar(
        "later",
        String[];
        body_source = "return(\"b\")",
        index = 1,
    )
    results = execute_staged_parse_jobs([
        later.body_parse_job,
        earlier.body_parse_job,
    ])
    @test [result.job.job_id for result in results] == [
        "parse_job:function_body:functions.0.body_source",
        "parse_job:function_body:functions.1.body_source",
    ]
    @test [result.queue_index for result in results] == [0, 1]

    encoded = to_json(first(results))
    @test encoded["kind"] == "staged_parse_result"
    @test encoded["phases"] == ["resolve", "load", "compile", "execute"]
    @test encoded["resolved_spec_id"] == ACTION_IR_BODY_RESOLVED_SPEC_ID
    @test encoded["registry_provider"] == "builtin"
    @test encoded["compiled_parser"]["top_rule"] == ACTION_IR_BODY_TOP_RULE
    cache_key = encoded["cache_key"]
    @test cache_key["kind"] == "staged_parser_cache_key"
    @test cache_key["normalized_spec_identity"] == ACTION_IR_BODY_RESOLVED_SPEC_ID
    @test cache_key["content_digest"] == ACTION_IR_BODY_ADAPTER_DIGEST
    @test cache_key["fingerprint"] == join([
        ACTION_IR_BODY_RESOLVED_SPEC_ID,
        ACTION_IR_BODY_ADAPTER_DIGEST,
        "none",
        ACTION_IR_BODY_TOP_RULE,
        "spec-language-v1",
        "actionir-v1",
        "staged-parsing-v1",
        "actionir_ast_v1",
    ], "|")
    @test encoded["result"]["kind"] == "action_block"
    @test encoded["result"]["statements"][1]["expr"]["name"] == "return"

    spec = SpecFile(functions = [earlier, later], rules = _spec_with_functions(FunctionDefinition[]).rules)
    dispatch = dispatch_function_body_parse_jobs(spec)
    @test [result.queue_index for result in dispatch.results] == [0, 1]
    @test [definition.name for definition in dispatch.spec.functions] == ["earlier", "later"]
    @test dispatch.spec.functions[1].body_ast["kind"] == "action_block"
    @test dispatch.spec.functions[1].body_parse_job.result_field == "body_ast"
    @test spec.functions[1].body_ast === nothing
    @test stitch_function_body_parse_jobs(spec).functions[2].body_ast["kind"] == "action_block"

    source = join([
        "fn zero() {return(\"zero\")}",
        "Top::",
        " /x/",
    ], "\n")
    nodes = [_definition_node(source, "zero", String[], "return(\"zero\")")]
    staged_spec = parse_spec_with_staged_user_function_definition_asts(source, nodes)
    @test length(staged_spec.functions) == 1
    @test staged_spec.functions[1].body_ast["kind"] == "action_block"
    @test [rule.header.label for rule in staged_spec.rules] == ["Top"]

    unsupported = _staged_job_with(
        earlier.body_parse_job;
        parser_spec_id = "missing.spec",
    )
    unsupported_error = try
        execute_staged_parse_job(unsupported)
        nothing
    catch error
        error
    end
    @test unsupported_error isa StagedParserRegistryException
    @test occursin("phase=resolve", unsupported_error.message)
    @test occursin("parser_spec_id=missing.spec", unsupported_error.message)
    @test occursin("source_span=0-1", unsupported_error.message)
    @test occursin("failure_policy=fail", unsupported_error.message)

    wrong_top = _staged_job_with(earlier.body_parse_job; top_rule = "missing_top")
    wrong_top_error = try
        execute_staged_parse_job(wrong_top)
        nothing
    catch error
        error
    end
    @test wrong_top_error isa StagedParserRegistryException
    @test occursin("phase=compile", wrong_top_error.message)

    wrong_field = _staged_job_with(earlier.body_parse_job; result_field = "wrong_field")
    drifted = _function_with_parse_job(earlier, wrong_field)
    drift_error = try
        dispatch_function_body_parse_jobs(SpecFile(functions = [drifted], rules = spec.rules))
        nothing
    catch error
        error
    end
    @test drift_error isa StagedParserRegistryException
    @test occursin("result_field must be 'body_ast'", drift_error.message)
end

@testset "Compiled spec state" begin
    parsed = parse_spec(raw"""
Top::
 /x/ -> Child { return(normalize(entry_text())) }
 I { set(out, "start") }
 E.return(out)

Child:
 /[a-z]+/
""")
    normalize = _function_with_body_sidecar(
        "normalize",
        ["value"];
        body_source = "return(value)",
        body_ast = to_json(parse_action_block("return(value)")),
        index = 0,
    )
    spec = SpecFile(functions = [normalize], rules = parsed.rules)
    compiled = compile_spec(spec)

    @test compiled.definition_order == ["Top", "Child"]
    @test compiled.compiled_rule_order == ["Top", "Child"]
    @test isempty(compiled.redefined_rule_labels)
    @test user_function_names(compiled.function_registry) == ["normalize"]
    @test compiled_functions(compiled)[1].definition.name == "normalize"

    top = compiled_rule(compiled, "Top")
    @test top !== nothing
    @test top.regex_patterns == ["x"]
    @test top.mode_metadata.name == "Default"
    @test top.mode_metadata.is_top
    @test !top.mode_metadata.is_and
    @test top.dependency_refs[1].label == "Child"
    @test top.dependency_refs[1].index == 0
    @test [payload.lifecycle for payload in top.lifecycle_action_payloads] == ["I", "E"]
    @test length(action_payloads(top)) == 3

    edge_payload = top.action_edges[1].action_payload
    @test edge_payload !== nothing
    @test length(edge_payload.action_ast.statements) == 1
    @test any(
        contract -> contract.family == "user_function" && contract.canonical_name == "normalize",
        edge_payload.contracts.contracts,
    )

    dependency_entry = compiled.dependency_regex_state.dependency_regex_map["Top"]
    @test dependency_entry.patterns == ["[a-z]+"]
    @test combined_pattern(dependency_entry) == "(?:[a-z]+)"

    encoded = to_json(compiled)
    @test encoded["kind"] == "compiled_spec_state"
    @test encoded["function_order"] == ["normalize"]
    @test haskey(encoded["rules_by_label"], "Top")

    descriptor = to_descriptor_json(compiled)
    @test Set(keys(descriptor)) == Set(DESCRIPTOR_CONTRACT["top_level_keys"])
    descriptor_top = descriptor["spec"]["Top"]
    @test descriptor_top["handler"]["kind"] == "julia_interpreter_rule"
    @test descriptor_top["handler"]["status"] == "compiled_state_only"
    @test descriptor_top["dependency_refs"] == [Dict{String,Any}("label" => "Child", "idx" => 0)]
    @test descriptor["meta"]["descriptor_model"] == "compiled_descriptor_state"
    @test descriptor["meta"]["compiled_rule_order"] == ["Top", "Child"]
    @test descriptor["meta"]["function_order"] == ["normalize"]
    @test descriptor["meta"]["function_count"] == 1
    @test descriptor["functions"]["normalize"]["body_ast"]["kind"] == "action_block"
    @test descriptor["dependency_regex_map"]["Top"]["patterns"] == ["[a-z]+"]

    edge_compiled = compile_spec(parse_spec(raw"""
Top::
 /z/ -> Anchored { return(match_text()) }
 -> Child .push

Anchored: /z/
Child: /c/
Pair: /\[/ /\]/
 -> Other .push
 -> Pair[1] .return(array("pair"))

Other: /x/
"""))
    top_edges = compiled_rule(edge_compiled, "Top").action_edges
    @test [
        (edge.targets[1].label, edge.regex_index, edge.child_regex_index, edge.has_parent_regex)
        for edge in top_edges
    ] == [("Anchored", 0, 0, true), ("Child", 1, 0, false)]
    pair_edges = compiled_rule(edge_compiled, "Pair").action_edges
    @test compiled_rule(edge_compiled, "Pair").regex_patterns == ["\\[", "\\]", "x"]
    @test [
        (edge.targets[1].label, edge.regex_index, edge.child_regex_index, edge.has_parent_regex)
        for edge in pair_edges
    ] == [("Other", 2, 0, false), ("Pair", 1, 1, false)]

    first = Rule(
        header = RuleHeader("Top", true, default_rule_mode(), "", 1),
        body = [BodyElement(RegexBodyElementKind("first"), "/first/", 2)],
    )
    second = Rule(
        header = RuleHeader("Top", true, default_rule_mode(), "", 4),
        body = [BodyElement(RegexBodyElementKind("second"), "/second/", 5)],
    )
    duplicate = compile_spec(SpecFile(rules = [first, second]); validate_source = false)
    @test duplicate.definition_order == ["Top", "Top"]
    @test duplicate.compiled_rule_order == ["Top"]
    @test duplicate.redefined_rule_labels == ["Top"]
    @test compiled_rule(duplicate, "Top").regex_patterns == ["second"]

    missing = parse_spec("Top::\n -> Ghost")
    @test _throws_validation_message(() -> compile_spec(missing), "undefined rule")
    @test _throws_compiled_spec_message(
        () -> compile_spec(missing; validate_source = false),
        "undefined rule 'Ghost'",
    )
end

@testset "Staged function descriptor shape through runtime" begin
    normalize_body = "return(trim(value))"
    pair_body = "return(hash(\"left\", left, \"right\", right))"
    source = join([
        "fn normalize(value) {$normalize_body}",
        "fn pair(left, right) {$pair_body}",
        "Top::",
        " /x/",
        " E { return(hash(\"name\", normalize(\" x \"), \"pair\", pair(\"a\", \"b\"))) }",
    ], "\n")
    nodes = [
        _definition_node(source, "normalize", ["value"], normalize_body),
        _definition_node(source, "pair", ["left", "right"], pair_body),
    ]
    spec = parse_spec_with_staged_user_function_definition_asts(source, nodes)
    compiled = compile_spec(spec)
    descriptor = to_descriptor_json(compiled)
    jobs = body_parse_jobs(compiled.function_registry)

    @test [definition.name for definition in spec.functions] == ["normalize", "pair"]
    @test [job.job_id for job in jobs] == [
        "parse_job:function_body:$(join(job.parent_ast_path, ".")):$(job.parser_spec_id):" *
        "$(job.top_rule):$(job.source_span.start)-$(job.source_span.stop)"
        for job in jobs
    ]
    @test [job.parent_ast_path for job in jobs] == [
        ["functions", "0", "body_source"],
        ["functions", "1", "body_source"],
    ]
    @test to_json(compiled.function_registry)["body_parse_jobs"] == [to_json(job) for job in jobs]
    @test sort(collect(keys(descriptor))) == ["dependency_regex_map", "functions", "meta", "spec"]
    @test sort(collect(keys(descriptor["functions"]))) == ["normalize", "pair"]
    @test (
        descriptor["meta"]["function_order"],
        descriptor["meta"]["function_count"],
    ) == (["normalize", "pair"], 2)

    for (index, definition) in enumerate(spec.functions)
        function_json = descriptor["functions"][definition.name]
        payload = function_json["body_payload"]
        job = definition.body_parse_job
        job_json = function_json["body_parse_job"]
        body_ast = function_json["body_ast"]

        @test Set(keys(function_json)) == Set(DESCRIPTOR_CONTRACT["function_record_keys"])
        @test function_json["kind"] == DESCRIPTOR_CONTRACT["function_kind"]
        @test function_json["version"] == DESCRIPTOR_CONTRACT["function_version"]
        @test function_json["source_text"] == definition.source

        @test (
            function_json["index"],
            function_json["name"],
            function_json["params"],
            function_json["arity"],
            function_json["body_source"],
        ) == (index - 1, definition.name, definition.params, definition.arity, definition.body_source)
        @test (
            payload["kind"],
            payload["node_kind"],
            payload["payload_kind"],
            payload["parent_ast_path"],
            payload["function_name"],
            payload["params"],
            payload["arity"],
            payload["text"],
            payload["source_span"],
        ) == (
            "staged_payload",
            "function_definition",
            "function_body",
            ["functions", string(index - 1), "body_source"],
            definition.name,
            definition.params,
            definition.arity,
            definition.body_source,
            to_json(job.source_span),
        )
        @test payload["provenance"] == Any[
            Dict("kind" => "source_slice", "source_span" => to_json(job.source_span)),
        ]
        @test job_json == to_json(job)
        @test (
            job_json["kind"],
            job_json["node_kind"],
            job_json["payload_kind"],
            job_json["parser_spec_id"],
            job_json["top_rule"],
            job_json["result_policy"],
            job_json["result_field"],
            job_json["failure_policy"],
            job_json["diagnostic_owner"],
        ) == (
            "parse_job",
            "function_definition",
            "function_body",
            ACTION_IR_BODY_SPEC_ID,
            ACTION_IR_BODY_TOP_RULE,
            "replace_field",
            "body_ast",
            "fail",
            "function_body",
        )
        @test (
            body_ast,
            body_ast["kind"],
            body_ast["statements"][1]["expr"]["name"],
        ) == (definition.body_ast, "action_block", "return")
    end

    @test runtime_parse(LinkedSpecRuntimeEngine(compiled), "x").value == Dict{String,Any}(
        "name" => "x",
        "pair" => Dict{String,Any}("left" => "a", "right" => "b"),
    )
end

@testset "Runtime regex matching state" begin
    @test parse_mode_from_name("seek") == SeekParseMode
    @test parse_mode_from_name("consume") == ConsumeParseMode
    @test parse_mode_name(SeekParseMode) == "seek"
    @test to_json(ConsumeParseMode) == "consume"
    @test_throws RuntimeRegexException parse_mode_from_name("scan")
    @test_throws RuntimeRegexException RuntimeRegexAlternation(["("])

    alternation = RuntimeRegexAlternation(["cat", "dog"])
    @test length(alternation) == 2
    @test !isempty(alternation)
    @test to_json(alternation)["patterns"] == ["cat", "dog"]

    seek = runtime_match(alternation, "xx dog cat", 0; parse_mode = SeekParseMode)
    @test seek !== nothing
    @test seek.alternative_index == 1
    @test seek.pattern == "dog"
    @test match_text(seek) == "dog"
    @test seek.codeunit_start == 3

    @test runtime_match(alternation, "xx dog cat", 0; parse_mode = "consume") === nothing
    consume = consume_match(alternation, "dog cat", 0)
    @test consume !== nothing
    @test consume.alternative_index == 1
    @test match_text(consume) == "dog"

    tie = RuntimeRegexAlternation(["c.t", "cat"])
    @test seek_match(tie, "cat", 0).alternative_index == 0
    @test isempty(RuntimeRegexAlternation(String[]))

    compiled = compile_spec(parse_spec("Top::\n /cat/ /dog/"))
    compiled_alternation = RuntimeRegexAlternation(compiled_rule(compiled, "Top"))
    compiled_match = seek_match(compiled_alternation, "xx dog cat", 0)
    @test compiled_match.alternative_index == 1
    @test compiled_match.pattern == "dog"

    capture_input = "e🙂 abc-42"
    capture_match = seek_match(
        RuntimeRegexAlternation([raw"(?P<word>[a-z]+)-(a)?(\d+)()"]),
        capture_input,
        0,
    )
    @test match_text(capture_match) == "abc-42"
    @test capture_match.groups == ["abc-42", "abc", "", "42", ""]
    @test capture_match.captures == ["abc", "42", ""]
    @test named_capture(capture_match, "word") == "abc"
    @test capture_match.codeunit_start == 6
    @test capture_match.codeunit_end == 12
    @test codeunit_length(capture_match) == 6
    @test char_start(capture_match) == 3
    @test char_end(capture_match) == 9
    @test char_length(capture_match) == 6
    @test to_json(match_start_line_column(capture_match)) == Dict{String,Any}(
        "line" => 1,
        "column" => 4,
    )
    @test to_json(capture_match)["captures"] == ["abc", "42", ""]
    @test !is_zero_width(capture_match)

    @test named_capture(
        consume_match(RuntimeRegexAlternation([raw"(?<word>[a-z]+)"]), "name", 0),
        "word",
    ) == "name"
    @test match_text(
        consume_match(RuntimeRegexAlternation([raw"[[:alpha:]]+"]), "Name", 0),
    ) == "Name"
    @test match_text(
        consume_match(RuntimeRegexAlternation([raw"(?i)name"]), "NAME", 0),
    ) == "NAME"
    @test match_text(
        consume_match(RuntimeRegexAlternation([raw"(?i:name)"]), "NAME", 0),
    ) == "NAME"
    @test match_text(
        consume_match(RuntimeRegexAlternation([raw"\w++\s+[^}]++"]), "name value", 0),
    ) == "name value"
    @test match_text(
        consume_match(
            RuntimeRegexAlternation([raw"(\[(?:[^\[\]]++|(?R))+\])"]),
            "[x [y] z]",
            0,
        ),
    ) == "[x [y] z]"

    register_input = "parent child"
    parent_match = consume_match(RuntimeRegexAlternation(["parent", "child"]), register_input, 0)
    parent_registers = with_local_match(RuntimeMatchRegisters(register_input), parent_match)
    child_entry = enter_child(parent_registers)
    @test match_text(child_entry.entry_match) == "parent"
    @test child_entry.local_match === nothing
    @test child_entry.capture_start_codeunit == parent_match.codeunit_end

    child_match = consume_match(
        RuntimeRegexAlternation(["parent", "child"]),
        register_input,
        ncodeunits("parent "),
    )
    child_registers = with_local_match(child_entry, child_match)
    @test match_text(child_registers.entry_match) == "parent"
    @test match_text(child_registers.local_match) == "child"
    @test match_text(parent_registers.local_match) == "parent"

    cursor_input = "a\n🙂b"
    cursor_codeunit = char_offset_to_codeunit_offset(cursor_input, 3)
    @test cursor_codeunit == 6
    @test codeunit_offset_to_char_offset(cursor_input, cursor_codeunit) == 3
    cursor_registers = RuntimeMatchRegisters(cursor_input; cursor_codeunit = cursor_codeunit)
    @test cursor_char_offset(cursor_registers) == 3
    @test to_json(cursor_line_column(cursor_registers)) == Dict{String,Any}(
        "line" => 2,
        "column" => 2,
    )

    empty_match = consume_match(RuntimeRegexAlternation([""]), cursor_input, 1)
    @test is_zero_width(empty_match)
    @test is_zero_progress_from(empty_match, 1)
    @test !made_progress_from(empty_match, 1)

    advanced_match = seek_match(RuntimeRegexAlternation(["🙂"]), cursor_input, 0)
    advanced_registers = with_local_match(RuntimeMatchRegisters(cursor_input), advanced_match)
    @test !zero_progress_since(advanced_registers, 0)
    @test reindex_runtime_regex_match(advanced_match, 7).alternative_index == 7
    @test with_cursor_codeunit(advanced_registers, 0).cursor_codeunit == 0
    @test with_capture_start_codeunit(advanced_registers, 0).capture_start_codeunit == 0
    @test_throws ArgumentError RuntimeMatchRegisters(cursor_input; cursor_codeunit = 3)
    @test_throws ArgumentError with_local_match(
        RuntimeMatchRegisters("other"),
        advanced_match,
    )
end

@testset "Runtime rule interpreter" begin
    runtime_engine(source; parse_mode = SeekParseMode, max_iterations = 10_000) =
        LinkedSpecRuntimeEngine(
            compile_spec(parse_spec(source));
            parse_mode = parse_mode,
            max_iterations = max_iterations,
        )

    public_parser_trivia = runtime_engine(raw"""
Top::
 I {
   cur = undef
   set(array(items), [])
 }
 -> object { cur = call(object) }
 -> version { push(array(items), call(version)) }
 LX { return(array(cur[1], copy(array(items)))) }

object: /(?i)\nobject:\s+(\S+)/ I { return(array("?object:", flat_array(entry_groups()))) }
version: /(?i)\nversion:\s+(\S+)/ I { return(array("?version:", flat_array(entry_groups()))) }
""")
    public_parser_result = runtime_parse(
        public_parser_trivia,
        "\n \t# generated report\nobject: /proj/foo\nversion: 1\n",
    )
    @test public_parser_result.value == Any[nothing, Any[Any["?version:", "1"]]]

    indexed_read = runtime_engine(raw"""
Top::
 /x/
 E {
   payload = array("tag", "name")
   return(payload[1])
 }
""")
    @test runtime_parse(indexed_read, "x").value == "name"

    repetition = runtime_engine(raw"""
Top::
 I { set(array(words), []) }
 /hello[ \t]+(\w+)/
 LE { push(array(words), match_group(0)) }
 E { return(copy(array(words))) }
""")
    repetition_result = runtime_parse(repetition, "hello one hello two")
    @test repetition_result.matched
    @test repetition_result.value == Any["one", "two"]
    @test repetition_result.output == Any[Any["one", "two"]]
    @test repetition_result.cursor_codeunit == ncodeunits("hello one hello two")
    @test repetition_result.cursor_char_offset == length("hello one hello two")
    @test [event.lifecycle for event in repetition_result.lifecycle_events] == ["I", "LE", "LE", "E"]
    @test to_json(repetition_result)["output"] == Any[Any["one", "two"]]

    action_edge = runtime_engine(raw"""
top::
 -> item .push
 E { return(copy(array(top))) }

item:
 /x/
 I { return(entry_text()) }
""")
    action_result = runtime_execute(action_edge, "xx")
    @test action_result.value == Any["x", "x"]
    @test action_result.cursor_codeunit == 2

    explicit_call = runtime_engine(raw"""
Top::
 -> Item { return(call(Item)) }

Item:
 /x/
 I { return(entry_text()) }
""")
    @test runtime_parse(explicit_call, "x").value == "x"

    action_retv = runtime_engine(raw"""
Top::
 I { set(array(out), []) }
 -> A { push(array(out), retv) }
 -> B { push(array(out), retv) }
 E { return(copy(array(out))) }

A: /a/ I { return("A") }
B: /b/ I { return("B") }
""")
    @test runtime_parse(action_retv, "ab").value == Any["A", "B"]

    passive_child = runtime_engine(raw"""
Top::
 -> Item
 E { return(match_text()) }

Item: /x/
""")
    passive_result = runtime_parse(passive_child, "x")
    @test passive_result.value == "x"
    @test passive_result.cursor_codeunit == 1

    blind_and = runtime_engine(raw"""
Top::AND
 I { set(array(log), []) }
 => ChildA { push(array(log), retv) }
 => ChildB { push(array(log), retv) }
 E { return(copy(array(log))) }

ChildA:
 /a/
 E { return("A") }

ChildB:
 /[ \t]+b/
 E { return("B") }
""")
    blind_and_result = runtime_parse(blind_and, "a b")
    @test blind_and_result.value == Any["A", "B"]
    @test blind_and_result.cursor_codeunit == 3

    blind_or = runtime_engine(raw"""
Top::OR
 => ChildA
 => ChildB
 LX { return("or-miss") }
 E { return("unexpected") }

ChildA::
 I { return_undef() }
 /never/

ChildB::
 I { return_undef() }
 /never/
""")
    blind_or_result = runtime_parse(blind_or, "c")
    @test blind_or_result.value == "or-miss"
    @test [event.lifecycle for event in blind_or_result.lifecycle_events] == ["I", "I", "LX"]

    bounded_or = runtime_engine(raw"""
Top::OR{2,3}
 I { set(array(out), []) }
 /a/ -> A { push(array(out), match_text()) }
 /b/ -> B { push(array(out), match_text()) }
 E { return(copy(array(out))) }

A: /a/
B: /b/
""")
    bounded_result = runtime_parse(bounded_or, "abab")
    @test bounded_result.value == Any["a", "b", "a"]
    @test bounded_result.cursor_codeunit == 3

    zero_width = runtime_engine(raw"""
Top::OR+
 I { set(array(iters), []) }
 /x*/
 LE { push(array(iters), "i") }
 E { return(copy(array(iters))) }
""")
    zero_width_result = runtime_parse(zero_width, "abc")
    @test zero_width_result.value == Any["i"]
    @test zero_width_result.cursor_codeunit == 0

    lifecycle = runtime_engine(raw"""
Top::OR{1}
 I { push(array(events), "I") }
 LS { push(array(events), "LS") }
 /a/
 LE { push(array(events), "LE") }
 IT { push(array(events), "IT") }
 EX { push(array(events), "EX") }
 LX { push(array(events), "LX") }
 E { return(copy(array(events))) }
""")
    lifecycle_result = runtime_parse(lifecycle, "a")
    @test lifecycle_result.value == Any["I", "LS", "LE", "IT", "EX", "LX"]
    @test [event.lifecycle for event in lifecycle_result.lifecycle_events] ==
        ["I", "LS", "LE", "IT", "EX", "LX", "E"]
    @test to_json(first(lifecycle_result.lifecycle_events)) == Dict{String,Any}(
        "rule_label" => "Top",
        "lifecycle" => "I",
        "line" => 2,
    )

    consume_and = runtime_engine(
        raw"""
Top::AND
 /ab/
 /cd/
 E { return(match_text()) }
""";
        parse_mode = "consume",
    )
    consume_result = runtime_parse(consume_and, "abcd")
    @test consume_result.value == "cd"
    @test consume_result.cursor_codeunit == 4

    shaped = runtime_engine(raw"""
Top::
 /x/
 E { return(array("ok", array(1, true, undef))) }
""")
    @test runtime_parse(shaped, "x").value == Any["ok", Any[1, true, nothing]]

    recursion_guard = runtime_engine(raw"""
Loop::OR
 /x*/
 => Loop
""")
    recursion_result = runtime_parse(recursion_guard, "x")
    @test !recursion_result.matched
    @test recursion_result.value === nothing
    @test recursion_result.cursor_codeunit == 0

    rule_local_resets = runtime_engine(raw"""
Top::
 I {
   set(array(items), ["outer"])
   set(hash(meta), { "scope" : "outer" })
 }
 -> Child {
   inner = call(Child)
   return(hash(
     "inner", inner,
     "outer_items", copy(array(items)),
     "outer_meta", copy(hash(meta))
   ))
 }

Child:
 /x/
 I {
   set(array(items), ["inner"])
   set(hash(meta), { "scope" : "inner" })
   return(hash("items", copy(array(items)), "meta", copy(hash(meta))))
 }
""")
    @test runtime_parse(rule_local_resets, "x").value == Dict{String,Any}(
        "inner" => Dict{String,Any}(
            "items" => Any["inner"],
            "meta" => Dict{String,Any}("scope" => "inner"),
        ),
        "outer_items" => Any["outer"],
        "outer_meta" => Dict{String,Any}("scope" => "outer"),
    )

    shared_mutation = runtime_engine(raw"""
Top::
 I { set(array(items), []) }
 -> Child {
   call(Child)
   return(copy(array(items)))
 }

Child:
 /x/
 I {
   push(array(items), "child")
   return("done")
 }
""")
    @test runtime_parse(shared_mutation, "x").value == Any["child"]

    child_push_forms = runtime_engine(raw"""
Parent::
 I { set(array(explicit), []) }
 -> Child {
   push(Child)
   push(Child, explicit)
   push(Child, 1)
   push(Child, explicit, 0)
   return(hash(
     "implicit", copy(array(Parent)),
     "explicit", copy(array(explicit))
   ))
 }

Child:
 /x/
 I { return(["zero", "one"]) }
""")
    @test runtime_parse(child_push_forms, "x").value == Dict{String,Any}(
        "implicit" => Any[Any["zero", "one"], "one"],
        "explicit" => Any[Any["zero", "one"], "zero"],
    )

    below_minimum = runtime_engine(raw"""
Top::OR{2}
 /a/
""")
    @test_throws RuntimeInterpreterException runtime_parse(below_minimum, "a")

    unsupported = runtime_engine(raw"""
Top::
 /x/
 E { unknown_runtime_helper(match_text()) }
""")
    @test_throws RuntimeInterpreterException runtime_parse(unsupported, "x")
    @test_throws RuntimeInterpreterException runtime_parse(repetition, "x"; top_rule = "Missing")
    @test_throws ArgumentError LinkedSpecRuntimeEngine(repetition.compiled_spec; max_iterations = 0)
end

@testset "Runtime core value stores and capture helpers" begin
    runtime_engine(source; parse_mode = SeekParseMode) =
        LinkedSpecRuntimeEngine(compile_spec(parse_spec(source)); parse_mode = parse_mode)

    typed_stores = runtime_engine(raw"""
Top::
 /x/
 E {
   set(value, "ok")
   set(array(items), ["a"])
   items += value
   set(hash(meta), { "k" : "v" })
   meta["n"] = 2
   payload = { "children" : [ { "name" : "zero" }, { "name" : value } ] }
   return(hash(
     "scalar", value,
     "items", copy(array(items)),
     "bare_items", items,
     "meta", copy(hash(meta)),
     "bare_meta", meta,
     "name", payload["children"][1]["name"],
     "shapes", array(undef, false, 3, 2.5)
   ))
 }
""")
    @test runtime_parse(typed_stores, "x").value == Dict{String,Any}(
        "scalar" => "ok",
        "items" => Any["a", "ok"],
        "bare_items" => Any["a", "ok"],
        "meta" => Dict{String,Any}("k" => "v", "n" => 2),
        "bare_meta" => Dict{String,Any}("k" => "v", "n" => 2),
        "name" => "ok",
        "shapes" => Any[nothing, false, 3, 2.5],
    )

    variable_shapes = runtime_engine(raw"""
Top::
 /x/
 E {
   value = "ok"
   items = [value, "tail"]
   meta = { "key" : value }
   key = "key"
   return(array(
     items[0],
     copy(items),
     copy(array(items)),
     meta[key],
     hash(meta),
     copy(hash(meta))
   ))
 }
""")
    @test runtime_parse(variable_shapes, "x").value == Any[
        "ok",
        Any["ok", "tail"],
        Any["ok", "tail"],
        "ok",
        Dict{String,Any}("key" => "ok"),
        Dict{String,Any}("key" => "ok"),
    ]

    nested_writes = runtime_engine(raw"""
Top::
 /x/
 E {
   payload = { "items" : [{ "name" : "old" }] }
   root_array = [{ "name" : "old" }]
   return(array(
     payload["items"][0]["name"] = "new",
     payload["items"][1] = "tail",
     payload,
     payload["items"][3] = "gap",
     payload["missing"][0] = "bad",
     payload["items"][0][0] = "bad",
     root_array[0]["name"] = "changed",
     root_array[1] = { "name" : "tail" },
     root_array["bad"] = { "name" : "bad" },
     root_array
   ))
 }
""")
    updated_payload_once = Dict{String,Any}(
        "items" => Any[Dict{String,Any}("name" => "new")],
    )
    updated_payload = Dict{String,Any}(
        "items" => Any[Dict{String,Any}("name" => "new"), "tail"],
    )
    updated_root_once = Any[Dict{String,Any}("name" => "changed")]
    updated_root = Any[
        Dict{String,Any}("name" => "changed"),
        Dict{String,Any}("name" => "tail"),
    ]
    @test runtime_parse(nested_writes, "x").value == Any[
        updated_payload_once,
        updated_payload,
        updated_payload,
        nothing,
        nothing,
        nothing,
        updated_root_once,
        updated_root,
        nothing,
        updated_root,
    ]

    captures = runtime_engine(raw"""
Top::
 /(?<name>\w+)=(\d+)/
 E {
   return(hash(
     "entry_text", entry_text(),
     "match_text", match_text(),
     "entry_groups", entry_groups(),
     "match_group_1", match_group(1),
     "entry_named", entry_named(name),
     "match_named", match_named(name),
     "entry_has", entry_has(name),
     "match_has", match_has(name),
     "entry_map", entry_map(),
     "match_map", match_map(),
     "entry_len", entry_len(),
     "match_len", match_len(),
     "entry_start", entry_start_pos(),
     "entry_end", entry_end_pos(),
     "match_start", match_start_pos(),
     "match_end", match_end_pos(),
     "entry_line", entry_line(),
     "entry_col", entry_col(),
     "entry_end_line", entry_end_line(),
     "entry_end_col", entry_end_col(),
     "match_line", match_line(),
     "match_col", match_col(),
     "match_end_line", match_end_line(),
     "match_end_col", match_end_col()
   ))
 }
""")
    @test runtime_parse(captures, "🙂\n key=42").value == Dict{String,Any}(
        "entry_text" => "key=42",
        "match_text" => "key=42",
        "entry_groups" => Any["key", "42"],
        "match_group_1" => "42",
        "entry_named" => "key",
        "match_named" => "key",
        "entry_has" => 1,
        "match_has" => 1,
        "entry_map" => Dict{String,Any}("name" => "key"),
        "match_map" => Dict{String,Any}("name" => "key"),
        "entry_len" => 6,
        "match_len" => 6,
        "entry_start" => 3,
        "entry_end" => 9,
        "match_start" => 3,
        "match_end" => 9,
        "entry_line" => 2,
        "entry_col" => 2,
        "entry_end_line" => 2,
        "entry_end_col" => 8,
        "match_line" => 2,
        "match_col" => 2,
        "match_end_line" => 2,
        "match_end_col" => 8,
    )
end

@testset "Runtime string scalar and numeric helpers" begin
    runtime_engine(source) = LinkedSpecRuntimeEngine(compile_spec(parse_spec(source)))

    string_helpers = runtime_engine(raw"""
Top::
 /(.+)/
 E {
   raw = entry_group(0)
   set(array(tmp), ["x"])
   missing = tmp[5]
   eager = "before"
   eager_or = or(true, eager = "after")
   return(hash(
     "cat", cat("A", undef, "B"),
     "trim", trim(raw),
     "chain", raw.trim().lowercase().replace_substr("-", "_").rm_suffix("_end"),
     "substr", substr(trim(raw), 1, 3),
     "contains", contains_substr(raw, "-B-"),
     "starts", starts_with(trim(raw), "A"),
     "ends", ends_with(trim(raw), "END"),
     "matches", matches(trim(raw), /^A/),
     "flagged_match", matches("AbC", /^abc$/i),
     "portable_noop_flags", matches("AbC", /^abc$/igo),
     "invalid_flag", matches("abc", /^abc$/q),
     "split", raw.trim().split("-"),
     "regex_split_noop_flags", split("a-b-c", /-/go),
     "coalesce", coalesce(missing, "fallback"),
     "coalesce_nonempty", coalesce_nonempty("", "filled"),
     "defined", is_defined(""),
     "undefined", is_undefined(missing),
     "empty", is_empty(""),
     "nonempty", is_nonempty("x"),
     "empty_array", is_empty(array()),
     "nonempty_hash", is_nonempty(hash("k", "v")),
     "and", and(true, 1, "x"),
     "and_empty", and(),
     "or", or(0, "yes"),
     "or_empty", or(),
     "not", not(0),
     "not_empty", not(),
     "eager_or", eager_or,
     "eager", eager,
     "unicode_length", length("🙂a"),
     "unicode_substr", substr("🙂ab", 1, 2),
     "str_eq", str_eq("a", "a"),
     "str_ne", str_ne("a", "b"),
     "str_lt", str_lt("a", "b"),
     "str_ge", str_ge("b", "b")
   ))
 }
""")
    @test runtime_parse(string_helpers, " A-B-END ").value == Dict{String,Any}(
        "cat" => "AB",
        "trim" => "A-B-END",
        "chain" => "a_b",
        "substr" => "-B-",
        "contains" => 1,
        "starts" => 1,
        "ends" => 1,
        "matches" => true,
        "flagged_match" => true,
        "portable_noop_flags" => true,
        "invalid_flag" => false,
        "split" => Any["A", "B", "END"],
        "regex_split_noop_flags" => Any["a", "b", "c"],
        "coalesce" => "fallback",
        "coalesce_nonempty" => "filled",
        "defined" => true,
        "undefined" => true,
        "empty" => true,
        "nonempty" => true,
        "empty_array" => true,
        "nonempty_hash" => true,
        "and" => true,
        "and_empty" => false,
        "or" => true,
        "or_empty" => false,
        "not" => true,
        "not_empty" => true,
        "eager_or" => true,
        "eager" => "after",
        "unicode_length" => 2,
        "unicode_substr" => "ab",
        "str_eq" => true,
        "str_ne" => true,
        "str_lt" => true,
        "str_ge" => true,
    )

    diagnostic_output = runtime_engine(raw"""
Top::
 /x/
 E {
   items = ["a", "b"]
   print("prefix=", "x")
   say(" line")
   print_each(array(items), "item:", "!")
   return("ok")
 }
""")
    diagnostic_io = IOBuffer()
    diagnostic_trace = LinkedSpecTraceEmitter(
        trace_config_enabled(LinkedSpecTraceLow);
        stdout_io = diagnostic_io,
    )
    diagnostic_result = runtime_parse(diagnostic_output, "x"; trace = diagnostic_trace)
    diagnostic_text = String(take!(diagnostic_io))
    @test diagnostic_result.value == "ok" &&
        occursin("prefix=x", diagnostic_text) &&
        occursin(" line", diagnostic_text) &&
        occursin("item:a!", diagnostic_text) &&
        occursin("item:b!", diagnostic_text)

    explicit_exit = runtime_engine(raw"""
Top::
 /x/
 E {
   exit_now(7)
   return("never")
 }
""")
    explicit_exit_error = try
        runtime_parse(explicit_exit, "x")
        nothing
    catch error
        error
    end
    @test explicit_exit_error isa RuntimeInterpreterException
    @test explicit_exit_error.message == "exit_now(7) in rule Top"
    @test explicit_exit_error.diagnostic.stage == "runtime_execution"
    @test explicit_exit_error.diagnostic.top_rule == "Top"
    @test explicit_exit_error.diagnostic.rule_label == "Top"

    default_exit = runtime_engine(raw"""
Top::
 /x/
 E { exit_now() }
""")
    default_exit_error = try
        runtime_parse(default_exit, "x")
        nothing
    catch error
        error
    end
    @test default_exit_error isa RuntimeInterpreterException
    @test default_exit_error.message == "exit_now(1) in rule Top"

    substitution_helpers = runtime_engine(raw"""
Top::
 /x/
 E {
   value = "\"bar,baz\""
   numbered = "a12b34"
   first_only = "a1b2"
   letters = "AbA"
   untouched = "abcdef"
   substr(value, '"|\s', "", go)
   regex_subst(numbered, /(\d+)/, "[$1]", g)
   substr(first_only, /(\d+)/, "[$1]", o)
   substr(letters, /a/, "x", ig)
   substr(untouched, 1, 3)
   return(hash(
     "value", value,
     "numbered", numbered,
     "first_only", first_only,
     "letters", letters,
     "untouched", untouched,
     "slice", substr(untouched, 1, 3)
   ))
 }
""")
    substitution_result = runtime_parse(substitution_helpers, "x").value
    @test substitution_result["value"] == "bar,baz"
    @test substitution_result["numbered"] == "a[12]b[34]"
    @test substitution_result["first_only"] == "a[1]b2"
    @test substitution_result["letters"] == "xbx"
    @test substitution_result["untouched"] == "abcdef"
    @test substitution_result["slice"] == "bcd"

    numeric_helpers = runtime_engine(raw"""
Top::
 /x/
 E {
   scores += 1
   scores += 5
   scores += 3
   scores += 5
   return(hash(
     "symbol_add", +(2, *(3, 4)),
     "sub", sub(10, 3, 2),
     "div", num_div(7, 2),
     "mod", 17.mod(5),
     "abs_floor", -3.2.abs().floor(),
     "ceil", ceil(3.2),
     "clamp", num_clamp(42, 0, 10),
     "gt", gt(10, 2),
     "le", <=(2, 2),
     "round", 3.5.round(),
     "half_round", round(2.5),
     "sum", sum(array(2, 4, 6)),
     "range", num_range(array(3, 9, 1, 7)),
     "avg", avg(array(2, 4, 6)),
     "median", median(array(5, 1, 4, 2)),
     "minimum", min(array(8, 3, 5, 1)),
     "bare_min", min(scores),
     "bare_max", max(scores),
     "bad_div", num_div(5, 0),
     "bad_mod", num_mod(5.5, 2),
     "bad_number", num_add("x", 1)
   ))
 }
""")
    @test runtime_parse(numeric_helpers, "x").value == Dict{String,Any}(
        "symbol_add" => 14,
        "sub" => 5,
        "div" => 3.5,
        "mod" => 2,
        "abs_floor" => 3,
        "ceil" => 4,
        "clamp" => 10,
        "gt" => 1,
        "le" => 1,
        "round" => 4,
        "half_round" => 3,
        "sum" => 12,
        "range" => 8,
        "avg" => 4,
        "median" => 3,
        "minimum" => 1,
        "bare_min" => 1,
        "bare_max" => 5,
        "bad_div" => nothing,
        "bad_mod" => nothing,
        "bad_number" => nothing,
    )
end

@testset "Runtime array helpers and mutations" begin
    runtime_engine(source) = LinkedSpecRuntimeEngine(compile_spec(parse_spec(source)))

    array_helpers = runtime_engine(raw"""
Top::
 /x/
 E {
   items += "b"
   items += "a"
   items += "c"
   items += "a"
   phrases += "aa-b"
   phrases += "cc-aa"
   set(array(public), [" x ", "", "Y"])
   return(hash(
     "sorted_drop_first", items.sorted().drop_front(2).first(),
     "reverse_take_last", array(items).reversed().take(2).last(),
     "contains", items.sorted().contains("c"),
     "index", items.sorted().index_of("c"),
     "drop_join", items.drop_back().join_values("|"),
     "uniq_join", items.uniq().join_values(","),
     "filter_count", items.filter_match(/^a$/).count(),
     "split_filter_count", phrases.split_each("-").filter_match(/^aa$/).count(),
     "transform_join", public.trim_each().filter_nonempty().lowercase_each().join_values("|"),
     "take_last", items.take_last(2),
     "slice", items.sorted().slice(1, 2),
     "flat", flat_array(array("p", "q"), "r"),
     "array_flat_splice", array("tag", flat_array(array("p", "q")), "tail"),
     "array_copy_nested", array("tag", copy(array("p", "q"))),
     "concat", concat_arrays(array("x"), array("y", "z")),
     "sum", array(2, 4, 6).sum(),
     "avg", array(2, 4, 6).avg(),
     "source", copy(array(items)),
     "empty_missing", missing.sorted().is_empty()
   ))
 }
""")
    @test runtime_parse(array_helpers, "x").value == Dict{String,Any}(
        "sorted_drop_first" => "b",
        "reverse_take_last" => "c",
        "contains" => 1,
        "index" => 3,
        "drop_join" => "b|a|c",
        "uniq_join" => "b,a,c",
        "filter_count" => 2,
        "split_filter_count" => 2,
        "transform_join" => "x|y",
        "take_last" => Any["c", "a"],
        "slice" => Any["a", "b"],
        "flat" => Any["p", "q", "r"],
        "array_flat_splice" => Any["tag", "p", "q", "tail"],
        "array_copy_nested" => Any["tag", Any["p", "q"]],
        "concat" => Any["x", "y", "z"],
        "sum" => 12,
        "avg" => 4,
        "source" => Any["b", "a", "c", "a"],
        "empty_missing" => true,
    )

    array_mutations = runtime_engine(raw"""
Top::
 /x/
 E {
   raw = " left , right,,third "
   split(array(parts), raw, /\s*,\s*/)
   items.push_back("a")
   items.push_back("b")
   items.push_front("z")
   items.pop_back()
   items.pop_front()
   array(items).push_back("c")
   scalar_items = ["s"]
   scalar_items.push_back("t")
   return(hash(
     "parts", copy(array(parts)),
     "receiver_split", "a, b".split(/\s*,\s*/),
     "items", copy(array(items)),
     "scalar_items", scalar_items,
     "value_push", items.push_back("bad"),
     "after_value_push", copy(array(items)),
     "tagged", split_tagged_records("a,b", /,/, "?tag:", "field")
   ))
 }
""")
    @test runtime_parse(array_mutations, "x").value == Dict{String,Any}(
        "parts" => Any[" left", "right", "", "third "],
        "receiver_split" => Any["a", "b"],
        "items" => Any["a", "c"],
        "scalar_items" => Any["s", "t"],
        "value_push" => nothing,
        "after_value_push" => Any["a", "c"],
        "tagged" => Any[Any["?tag:", "a", "field"], Any["?tag:", "b", "field"]],
    )
end

@testset "Runtime hash helpers and mutations" begin
    engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::
 /x/
 E {
   set_key(meta, "b", 2)
   set_key(meta, "a", 1)
   set_key(meta, "drop", 0)
   set_key(hash(meta), "stmt_hash", 4)
   set_key(overlay, "a", 10)
   set_key(overlay, "c", 3)
   value_set = set_key(meta, "value_only", 9)
   receiver_set = meta.set_key("receiver_only", 5)
   return(hash(
     "keys", meta.sorted_keys().join_values(","),
     "values", meta.sorted_values().join_values("|"),
     "count", meta.count_keys(),
     "has_a", meta.has_key("a"),
     "drop_pick", meta.drop_keys("drop").pick_keys("a", "stmt_hash").sorted_values(),
     "rename", hash(meta).rename_key("a", "aa").drop_keys("drop").set_key("z", 7).sorted_keys().join_values(","),
     "merged", merge_hash(copy(hash(meta)), overlay).sorted_values(),
     "bare_first_merge", merge_hash(meta, overlay).sorted_keys(),
     "value_set_has", value_set.has_key("value_only"),
     "receiver_set_has", receiver_set.has_key("receiver_only"),
     "after_value_set", copy(hash(meta)).has_key("value_only"),
     "after_receiver_set", copy(hash(meta)).has_key("receiver_only"),
     "index_value", meta["expr"] = "E",
     "after_index_value", copy(hash(meta)).has_key("expr"),
     "flat_splice", hash("z", 0, flat(hash(meta))).sorted_keys().join_values(","),
     "flat_hash_splice", hash("z", 0, meta.flat_hash()).sorted_keys().join_values(","),
     "map_field", hash("nested", copy(hash(meta))).pick_keys("nested")
   ))
 }
""")))

    @test runtime_parse(engine, "x").value == Dict{String,Any}(
        "keys" => "a,b,drop,stmt_hash",
        "values" => "1|2|0|4",
        "count" => 4,
        "has_a" => 1,
        "drop_pick" => Any[1, 4],
        "rename" => "aa,b,stmt_hash,z",
        "merged" => Any[10, 2, 3, 0, 4],
        "bare_first_merge" => Any["a", "c"],
        "value_set_has" => 1,
        "receiver_set_has" => 1,
        "after_value_set" => 0,
        "after_receiver_set" => 0,
        "index_value" => Dict{String,Any}(
            "b" => 2,
            "a" => 1,
            "drop" => 0,
            "stmt_hash" => 4,
            "expr" => "E",
        ),
        "after_index_value" => 1,
        "flat_splice" => "a,b,drop,expr,stmt_hash,z",
        "flat_hash_splice" => "a,b,drop,expr,stmt_hash,z",
        "map_field" => Dict{String,Any}(
            "nested" => Dict{String,Any}(
                "b" => 2,
                "a" => 1,
                "drop" => 0,
                "stmt_hash" => 4,
                "expr" => "E",
            ),
        ),
    )
end

@testset "Governed exhaustive pure helper fixture" begin
    source = read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "fixtures",
            "capability_pure_helper_surface.spec",
        ),
        String,
    )
    engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(source)))

    @test runtime_parse(engine, "x").value == Any[
        Dict{String,Any}(
            "coalesce" => "fallback",
            "concat_arrays" => Any[1, 2, 3],
            "contains" => 1,
            "contains_substr" => 1,
            "ends_with" => 1,
            "starts_with" => 1,
            "flat" => Any["x", "y", "z"],
            "has_key" => 1,
            "slice" => Any["b", "c"],
            "take_last" => Any["b", "c"],
            "uppercase_each" => Any["A", "BC"],
            "num_abs" => 3,
            "num_avg" => 4,
            "num_ceil" => 3,
            "num_clamp" => 10,
            "num_div" => 3,
            "num_floor" => 2,
            "num_ge" => 1,
            "num_le" => 1,
            "num_median" => 3,
            "num_mod" => 2,
            "num_mul" => 12,
            "num_ne" => 1,
            "num_range" => 8,
            "num_round" => 3,
            "num_sum" => 6,
        ),
    ]
end

@testset "Governed exhaustive position helper fixture" begin
    source = read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "fixtures",
            "capability_position_helper_surface.spec",
        ),
        String,
    )
    engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(source)))

    @test runtime_parse(engine, "ab").value == Any[
        Dict{String,Any}(
            "cursor_col" => 3,
            "cursor_rest" => "",
            "cursor_rest_len" => 0,
            "entry_col" => 1,
            "entry_end_col" => 3,
            "entry_end_line" => 1,
            "entry_end_pos" => 2,
            "entry_has" => 1,
            "entry_len" => 2,
            "entry_line" => 1,
            "entry_map" => Dict{String,Any}("word" => "ab"),
            "entry_start_col" => 1,
            "entry_start_line" => 1,
            "entry_start_pos" => 0,
            "input_end_col" => 3,
            "input_end_line" => 1,
            "input_end_pos" => 2,
            "input_len" => 2,
            "input_text" => "ab",
            "match_col" => 1,
            "match_end_col" => 1,
            "match_end_line" => 1,
            "match_end_pos" => nothing,
            "match_group" => nothing,
            "match_groups" => Any[],
            "match_has" => 0,
            "match_len" => nothing,
            "match_map" => Dict{String,Any}(),
            "match_named" => nothing,
            "match_start_col" => 1,
            "match_start_line" => 1,
        ),
    ]
end

@testset "Zero-width local match remains present" begin
    source = raw"""
Top::
 /(?<empty>)/
 E { return(hash("group", match_group(0), "has", match_has(empty), "len", match_len(), "start", match_start_pos(), "end", match_end_pos())) }
"""
    engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(source)))

    @test runtime_parse(engine, "x").value == Dict{String,Any}(
        "end" => 0,
        "group" => "",
        "has" => 1,
        "len" => 0,
        "start" => 0,
    )
end

@testset "Governed marker-control fixture" begin
    source = read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "fixtures",
            "capability_control_marker_surface.spec",
        ),
        String,
    )
    engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(source)))

    @test runtime_parse(engine, "xx").value == Any["elif", "case-b"]
end

@testset "Governed anonymous and named capture fixtures" begin
    anonymous_source = read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "fixtures",
            "capability_capture_anonymous_surface.spec",
        ),
        String,
    )
    anonymous_engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(anonymous_source)))
    @test runtime_parse(anonymous_engine, "AxxBC").value == Any[
        Dict{String,Any}(
            "rest" => "xxBC",
            "rest_len" => 4,
            "slice" => "xxB",
            "slice_col" => 2,
            "slice_len" => 3,
            "slice_line" => 1,
            "slice_pos" => 1,
            "take" => "xxB",
            "take_len" => 3,
            "take_rest" => "xxBC",
            "take_rest_len" => 4,
            "take_until_cursor" => "xxBC",
            "take_until_cursor_len" => 4,
            "until_cursor" => "xxBC",
            "until_cursor_len" => 4,
        ),
    ]

    named_source = read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "fixtures",
            "capability_capture_named_surface.spec",
        ),
        String,
    )
    named_engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(named_source)))
    @test runtime_parse(named_engine, "AxxBC").value == Any[
        Dict{String,Any}(
            "between" => "xxBC",
            "between_len" => 4,
            "copied_pos" => 1,
            "from" => "xxB",
            "from_len" => 3,
            "origin_exists" => 1,
            "origin_pos" => 1,
            "rest" => "xxBC",
            "rest_len" => 4,
            "take_between" => "xxBC",
            "take_between_len" => 4,
            "take_len" => 3,
            "take_rest" => "xxBC",
            "take_rest_len" => 4,
            "take_until_cursor" => "xxBC",
            "take_until_cursor_len" => 4,
            "until_cursor" => "xxBC",
            "until_cursor_len" => 4,
            "whole_input" => "AxxBC",
        ),
    ]
end

@testset "Named capture mark scope and character projection" begin
    implicit_and = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::AND
 => ChildA
 => ChildB

ChildA: /a/ E { return("A") }
ChildB: /[ \t]+b/ E { return("B") }
""")))
    @test runtime_parse(implicit_and, "a b").value == Any["A", "B"]

    rule_local = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::AND
 => First
 => Second

First:AND
 /A/
 /x/
 -> First[0] { mark_here(shared) }
 -> First[1] { return(mark_pos(shared)) }

Second:AND
 /B/
 /C/
 -> Second[1] { return(mark_exists(shared)) }
""")))
    @test runtime_parse(rule_local, "AxBC").value == Any[1, 0]

    multibyte = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::AND
 => Value

Value:AND
 /A/
 /éB/
 /C/
 -> Value[0] { mark_here(origin) }
 -> Value[2] { return(hash("len", capture_len_from(origin), "pos", mark_pos(origin), "text", capture_from(origin))) }
""")))
    @test runtime_parse(multibyte, "AéBC").value == Any[
        Dict{String,Any}("len" => 2, "pos" => 1, "text" => "éB"),
    ]
end

@testset "Runtime value blocks controls and trailing blocks" begin
    engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::
 /x/
 E {
   counted = { count = 0; while(num_lt(count, 2)) { count = num_add(count, 1) }; count }
   local = { while(true) { return("local") }; "bad" }
   local_undef = { return_undef(); "bad" }
   branch = { if(false) { return("bad") } elseif(true) { return("yes") } else { return("no") } }
   alias_branch = { when(false) { return("bad") } otherwise { return("alias") } }
   marker = { if(false); return("bad"); else(); return("marker"); endif() }
   kind = "b"
   switched = { switch(kind) { case("a") { return("bad") } case("b") { return("hit") } default { return("miss") } } }
   inline = if(false, "bad", else("fallback"))
   inline_plain = if(false, "bad", "fallback")
   inline_switch = switch(kind, case("a", "bad"), case("b", "inline-hit"), default("miss"))
   value = "outer"
   with_result = with("inner") { value = cat(value, "!"); return(value) }
   with_undef = with() { return(is_undefined(value)) }
   receiver = " a-b ".trim().with() { return(value.split("-")) }.count()
   return(array(counted, local, is_undefined(local_undef), branch, alias_branch, marker, switched, inline, inline_plain, inline_switch, with_result, with_undef, receiver, value))
 }
""")))

    @test runtime_parse(engine, "x").value == Any[
        2,
        "local",
        true,
        "yes",
        "alias",
        "marker",
        "hit",
        "fallback",
        "fallback",
        "inline-hit",
        "inner!",
        true,
        2,
        "outer",
    ]

    return_engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::
 /x/
 E {
   while(true) { return("done") }
   return("bad")
 }
""")))
    @test runtime_parse(return_engine, "x").value == "done"

    marker_engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::
 /x/
 E {
   if(false)
   return("bad")
   else()
   return("marker-rule")
   endif()
 }
""")))
    @test runtime_parse(marker_engine, "x").value == "marker-rule"

    limited_engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::
 /x/
 E {
   while(true) { count = num_add(count, 1) }
 }
""")); max_iterations = 2)
    @test_throws RuntimeInterpreterException runtime_parse(limited_engine, "x")

    unsupported_block_engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::
 /x/
 E {
   cat("x") { return("bad") }
   return("ok")
 }
""")))
    @test_throws RuntimeInterpreterException runtime_parse(unsupported_block_engine, "x")

    receiver_arity_engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::
 /x/
 E { return("x".with("bad") { return(value) }) }
""")))
    @test_throws RuntimeInterpreterException runtime_parse(receiver_arity_engine, "x")
end

@testset "Runtime registered user functions" begin
    functions = [
        _function_with_body_sidecar(
            "normalize",
            ["value"];
            body_source = "trim(value)",
            index = 0,
        ),
        _function_with_body_sidecar(
            "echo",
            ["value"];
            body_source = "return(value)",
            index = 1,
        ),
        _function_with_body_sidecar(
            "discard",
            ["value"];
            body_source = raw"""
marker = "inner"
return(value)
""",
            index = 2,
        ),
        _function_with_body_sidecar(
            "use_shapes",
            ["items", "meta"];
            body_source = raw"""
set(array(items), items.sorted())
set_key(hash(meta), "extra", "ok")
return(hash("first", items.first(), "meta", copy(hash(meta))))
""",
            index = 3,
        ),
        _function_with_body_sidecar(
            "read_missing",
            String[];
            body_source = "return(marker)",
            index = 4,
        ),
    ]
    engine = _runtime_engine_with_functions(raw"""
Top::
 /x/
 E {
   value = "caller"
   marker = "caller"
   set(array(items), ["caller"])
   discard(value = "discard-arg")
   after_discard = value
   eager = echo(value = "arg")
   captured = read_missing()
   shaped = use_shapes(["b", "a"], { "key" : "Value" })
   return(hash(
     "value", value,
     "marker", marker,
     "after_discard", after_discard,
     "eager", eager,
     "normal", normalize(" A-B ").lowercase().replace_substr("-", "_"),
     "captured", captured,
     "shaped", shaped,
     "items", copy(array(items))
   ))
 }
""", functions)

    @test runtime_parse(engine, "x").value == Dict{String,Any}(
        "value" => "arg",
        "marker" => "caller",
        "after_discard" => "discard-arg",
        "eager" => "arg",
        "normal" => "a_b",
        "captured" => nothing,
        "shaped" => Dict{String,Any}(
            "first" => "a",
            "meta" => Dict{String,Any}(
                "key" => "Value",
                "extra" => "ok",
            ),
        ),
        "items" => Any["caller"],
    )

    direct_engine = _runtime_engine_with_functions(raw"""
Top::
 /x/
 E { return(loop("x")) }
""", [
        _function_with_body_sidecar(
            "loop",
            ["value"];
            body_source = "return(loop(value))",
            index = 0,
        ),
    ])
    direct_error = try
        runtime_parse(direct_engine, "x")
        nothing
    catch error
        error
    end
    @test direct_error isa RuntimeInterpreterException
    @test occursin("loop -> loop", direct_error.message)
    @test direct_error.diagnostic.stage == "user_function_call"
    @test direct_error.diagnostic.handler_source_label == "julia_runtime:function:loop"

    mutual_engine = _runtime_engine_with_functions(raw"""
Top::
 /x/
 E { return(alpha("x")) }
""", [
        _function_with_body_sidecar(
            "alpha",
            ["value"];
            body_source = "return(beta(value))",
            index = 0,
        ),
        _function_with_body_sidecar(
            "beta",
            ["value"];
            body_source = "return(alpha(value))",
            index = 1,
        ),
    ])
    mutual_error = try
        runtime_parse(mutual_engine, "x")
        nothing
    catch error
        error
    end
    @test mutual_error isa RuntimeInterpreterException
    @test occursin("alpha -> beta -> alpha", mutual_error.message)

    arity_engine = _runtime_engine_with_functions(raw"""
Top::
 /x/
 E { return(echo()) }
""", [
        _function_with_body_sidecar(
            "echo",
            ["value"];
            body_source = "return(value)",
            index = 0,
        ),
    ])
    arity_error = try
        runtime_parse(arity_engine, "x")
        nothing
    catch error
        error
    end
    @test arity_error isa RuntimeInterpreterException
    @test occursin("expects 1 argument(s), got 0", arity_error.message)
end

@testset "Runtime hash and array tree traversal callbacks" begin
    engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::
 /x/
 E {
   meta = { "b" : { "y" : "B" }, "a" : "A", "arr" : ["u", "v"] }
   items = ["a", ["b", "c"], { "h" : "H" }]
   value = "outer"
   key = "outer-key"
   index = 99
   path = ["outer"]
   depth = 99
   acc = "outer-acc"
   nonhash = "x".map_leaves() { seen += "bad" }
   nonarray = "x".walk_leaves() { seen += "bad" }
   nonreduce = "x".reduce_leaves(seen += "bad") { return(acc) }
   return(array(
     meta.map_leaves() { return(cat(join_values("/", array(path)), "=", if(count(array(value)), join_values("", array(value)), else(value)))) },
     meta.reduce_leaves("") { return(cat(acc, key)) },
     meta.walk_leaves() { seen += join_values("/", array(path)); return(value) }.count_keys(),
     items.map_leaves() { return(cat(join_values("/", array(path)), "=", if(count(hash(value).sorted_keys()), cat("{", hash(value).sorted_keys().join_values(","), "}"), else(value)))) },
     items.reduce_leaves("") { return(cat(acc, join_values("/", array(path)), ":", if(count(hash(value).sorted_keys()), cat("{", hash(value).sorted_keys().join_values(","), "}"), else(value)), ";")) },
     items.walk_leaves() { seen += join_values("/", array(path)); return(value) }.count(),
     array(seen),
     is_undefined(nonhash),
     is_undefined(nonarray),
     is_undefined(nonreduce),
     value,
     key,
     index,
     array(path),
     depth,
     acc
   ))
 }
""")))

    @test runtime_parse(engine, "x").value == Any[
        Dict{String,Any}(
            "a" => "a=A",
            "arr" => "arr=uv",
            "b" => Dict{String,Any}("y" => "b/y=B"),
        ),
        "aarry",
        3,
        Any[
            "0=a",
            Any["1/0=b", "1/1=c"],
            "2={h}",
        ],
        "0:a;1/0:b;1/1:c;2:{h};",
        3,
        Any["a", "arr", "b/y", "0", "1/0", "1/1", "2"],
        true,
        true,
        true,
        "outer",
        "outer-key",
        99,
        Any["outer"],
        99,
        "outer-acc",
    ]

    malformed_engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::
 /x/
 E {
   items = ["x"]
   return(items.map_leaves("bad") { return(value) })
 }
""")))
    @test_throws RuntimeInterpreterException runtime_parse(malformed_engine, "x")
end

@testset "Runtime cursor controls and boundary capture" begin
    runtime_engine(source; parse_mode = SeekParseMode) =
        LinkedSpecRuntimeEngine(compile_spec(parse_spec(source)); parse_mode = parse_mode)

    saved_cursor = runtime_engine(
        raw"""
Top::AND
 /ab/ -> Top[0] { save_cursor() }
 /cd/ -> Top[1] { save_cursor() }
 E {
   marker = "retained"
   restore_cursor()
   first_restore = cursor_pos()
   restore_cursor()
   return(hash(
     "first_restore", first_restore,
     "cursor", cursor_pos(),
     "rest", cursor_rest(),
     "marker", marker
   ))
 }
""";
        parse_mode = ConsumeParseMode,
    )
    saved_result = runtime_parse(saved_cursor, "abcd")
    @test saved_result.value == Dict{String,Any}(
        "first_restore" => 4,
        "cursor" => 2,
        "rest" => "cd",
        "marker" => "retained",
    )
    @test saved_result.cursor_codeunit == 2

    empty_restore = runtime_engine(raw"""
Top::
 /x/
 E {
   restore_cursor()
   return(cursor_pos())
 }
""")
    @test runtime_parse(empty_restore, "x").value == 1

    entry_rewind = runtime_engine(raw"""
Top::AND
 /ab/
 /cd/ -> Top[1] {
   before = cursor_pos()
   rewind_entry_start()
   return(hash(
     "before", before,
     "after", cursor_pos(),
     "entry_start", entry_start_pos(),
     "match_start", match_start_pos(),
     "rest", cursor_rest()
   ))
 }
""")
    entry_rewind_result = runtime_parse(entry_rewind, "abcd")
    @test entry_rewind_result.value == Dict{String,Any}(
        "before" => 4,
        "after" => 0,
        "entry_start" => 0,
        "match_start" => 2,
        "rest" => "abcd",
    )
    @test entry_rewind_result.cursor_codeunit == 0

    consume_rewind = runtime_engine(
        raw"""
Top::AND
 /ab/ -> Top[0] { rewind_match_start() }
 /ab/
 E { return(hash("cursor", cursor_pos(), "rest", cursor_rest())) }
""";
        parse_mode = ConsumeParseMode,
    )
    consume_rewind_result = runtime_parse(consume_rewind, "ab")
    @test consume_rewind_result.value == Dict{String,Any}(
        "cursor" => 2,
        "rest" => "",
    )
    @test consume_rewind_result.cursor_codeunit == 2

    char_helpers = runtime_engine(
        raw"""
Top::AND
 /é/
 /x/
 E {
   return(hash(
     "cursor", cursor_pos(),
     "cursor_line", cursor_line(),
     "cursor_col", cursor_col(),
     "rest", cursor_rest(),
     "rest_len", cursor_rest_len(),
     "input", input_text(),
     "input_len", input_len(),
     "slice", input_slice(1, 1),
     "end_pos", input_end_pos(),
     "end_line", input_end_line(),
     "end_col", input_end_col()
   ))
 }
""";
        parse_mode = ConsumeParseMode,
    )
    @test runtime_parse(char_helpers, "éx").value == Dict{String,Any}(
        "cursor" => 2,
        "cursor_line" => 1,
        "cursor_col" => 3,
        "rest" => "",
        "rest_len" => 0,
        "input" => "éx",
        "input_len" => 2,
        "slice" => "x",
        "end_pos" => 2,
        "end_line" => 1,
        "end_col" => 3,
    )

    anonymous_capture_readers = runtime_engine(
        raw"""
Top::AND
 /BEGIN\n/ -> Top[0] { start_capture_slice() }
 /ébody/
 /END/ -> Top[2] {
   slice = capture_slice()
   slice_len = capture_slice_len()
   through_cursor = capture_slice_until_cursor()
   through_cursor_len = capture_slice_until_cursor_len()
   rest = capture_rest()
   rest_len = capture_rest_len()
   capture_pos = capture_slice_pos()
   capture_line = capture_slice_line()
   capture_col = capture_slice_col()
   taken_len = capture_take_len()
   tail = capture_take_rest()
   return(hash(
     "slice", slice,
     "slice_len", slice_len,
     "through_cursor", through_cursor,
     "through_cursor_len", through_cursor_len,
     "rest", rest,
     "rest_len", rest_len,
     "capture_pos", capture_pos,
     "capture_line", capture_line,
     "capture_col", capture_col,
     "taken_len", taken_len,
     "tail", tail,
     "remaining_len", capture_rest_len()
   ))
 }
""";
        parse_mode = ConsumeParseMode,
    )
    @test runtime_parse(anonymous_capture_readers, "BEGIN\nébodyENDTAIL").value == Dict{String,Any}(
        "slice" => "ébody",
        "slice_len" => 5,
        "through_cursor" => "ébodyEND",
        "through_cursor_len" => 8,
        "rest" => "ébodyENDTAIL",
        "rest_len" => 12,
        "capture_pos" => 6,
        "capture_line" => 2,
        "capture_col" => 1,
        "taken_len" => 5,
        "tail" => "TAIL",
        "remaining_len" => 0,
    )

    anonymous_capture_take = runtime_engine(
        raw"""
Top::AND
 /BEGIN\n/ -> Top[0] { start_capture_slice() }
 /ébody/
 /END/ -> Top[2] {
   taken = capture_take()
   tail_len = capture_take_rest_len()
   return(array(taken, tail_len, capture_rest()))
 }
""";
        parse_mode = ConsumeParseMode,
    )
    @test runtime_parse(anonymous_capture_take, "BEGIN\nébodyENDTAIL").value == Any["ébody", 4, ""]

    anonymous_capture_until_cursor = runtime_engine(
        raw"""
Top::AND
 /BEGIN\n/ -> Top[0] { start_capture_slice() }
 /ébody/ -> Top[1] {
   body = capture_take_until_cursor()
   body_remainder_len = capture_slice_until_cursor_len()
 }
 /END/ -> Top[2] {
   close_len = capture_take_until_cursor_len()
   return(array(body, body_remainder_len, close_len, capture_slice_pos(), capture_rest()))
 }
""";
        parse_mode = ConsumeParseMode,
    )
    @test runtime_parse(anonymous_capture_until_cursor, "BEGIN\nébodyENDTAIL").value ==
        Any["ébody", 0, 3, 14, "TAIL"]

    boundary_capture = runtime_engine(raw"""
Top::
 /BEGIN/
 E {
   body = capture_until_boundary(Boundary, EarlierBoundary)
   return(hash("body", body, "cursor", cursor_pos(), "rest", cursor_rest()))
 }

Boundary: /END/
EarlierBoundary: /STOP/
""")
    boundary_result = runtime_parse(boundary_capture, "BEGIN body STOP later END")
    @test boundary_result.value == Dict{String,Any}(
        "body" => " body ",
        "cursor" => 11,
        "rest" => "STOP later END",
    )
    @test boundary_result.cursor_codeunit == 11

    eof_capture = runtime_engine(raw"""
Top::
 /x/
 E { return(capture_until_boundary(Boundary)) }

Boundary: /END/
""")
    eof_result = runtime_parse(eof_capture, "x tail")
    @test eof_result.value == " tail"
    @test eof_result.cursor_codeunit == ncodeunits("x tail")

    unresolved_boundary = runtime_engine(raw"""
Top::
 /x/
 E {
   before = cursor_pos()
   captured = capture_until_boundary(Missing)
   return(hash("captured", captured, "before", before, "after", cursor_pos()))
 }
""")
    unresolved_result = runtime_parse(unresolved_boundary, "x tail")
    @test unresolved_result.value == Dict{String,Any}(
        "captured" => nothing,
        "before" => 1,
        "after" => 1,
    )
    @test unresolved_result.cursor_codeunit == 1
end

@testset "Runtime structured diagnostics" begin
    success_spec = compile_spec(parse_spec(raw"""
Top::
 /x/
 E { return(hash("value", "ok")) }
"""))
    plain_engine = LinkedSpecRuntimeEngine(success_spec)
    identified_engine = LinkedSpecRuntimeEngine(
        success_spec;
        spec_name = "diagnostic-example",
        spec_path = "/specs/diagnostic-example.spec",
    )
    @test to_json(runtime_parse(identified_engine, "x")) ==
        to_json(runtime_parse(plain_engine, "x"))

    missing_rule_error = try
        runtime_parse(identified_engine, "x"; top_rule = "Missing")
        nothing
    catch error
        error
    end
    @test missing_rule_error isa RuntimeInterpreterException
    @test to_json(missing_rule_error) == Dict{String,Any}(
        "message" => "rule 'Missing' is not compiled",
        "diagnostic" => Dict{String,Any}(
            "type" => "runtime_parser",
            "stage" => "rule_lookup",
            "owner_stage" => "julia_runtime",
            "summary" => "Julia runtime rule lookup failed",
            "detail" => "rule 'Missing' is not compiled",
            "spec_name" => "diagnostic-example",
            "spec_path" => "/specs/diagnostic-example.spec",
            "top_rule" => "Missing",
            "rule_label" => "Missing",
            "handler_source_label" => "julia_runtime:rule:Missing",
        ),
    )

    child_failure_engine = LinkedSpecRuntimeEngine(
        compile_spec(parse_spec(raw"""
Top::
 => Child

Child:
 /x/
 E { unknown_runtime_helper(match_text()) }
"""));
        spec_name = "child-failure",
        spec_path = "/specs/child-failure.spec",
    )
    child_error = try
        runtime_parse(child_failure_engine, "x")
        nothing
    catch error
        error
    end
    @test child_error isa RuntimeInterpreterException
    @test child_error.diagnostic !== nothing
    @test to_json(child_error.diagnostic) == Dict{String,Any}(
        "type" => "runtime_parser",
        "stage" => "runtime_execution",
        "owner_stage" => "julia_runtime",
        "summary" => "Julia runtime interpreter failed",
        "detail" => "unsupported runtime helper 'unknown_runtime_helper' in rule Child",
        "spec_name" => "child-failure",
        "spec_path" => "/specs/child-failure.spec",
        "top_rule" => "Top",
        "rule_label" => "Child",
        "handler_source_label" => "julia_runtime:rule:Child",
    )
    @test sprint(showerror, child_error) == child_error.message
end

@testset "Trace controls events and sinks" begin
    @test parse_trace_level("none") == LinkedSpecTraceNone
    @test parse_trace_level("quiet") == LinkedSpecTraceNone
    @test parse_trace_level("med") == LinkedSpecTraceMedium
    @test parse_trace_level("verbose") == LinkedSpecTraceDebug
    @test parse_trace_level("350").value == 350
    @test_throws LinkedSpecTraceException parse_trace_level("unknown")
    @test trace_allows(LinkedSpecTraceMedium, LinkedSpecTraceLow)
    @test !trace_allows(LinkedSpecTraceLow, LinkedSpecTraceMedium)
    @test trace_level_name(LinkedSpecTraceLevel(350)) == "full"
    @test parse_trace_sink_mode("both") == LinkedSpecTraceMirror

    environment_config = trace_config_from_environment(Dict(
        "LINKEDSPEC_TRACE_LEVEL" => "debug",
        "LINKEDSPEC_TRACE_FILE" => "trace.log",
        "LINKEDSPEC_TRACE_MIRROR_STDOUT" => "1",
        "LINKEDSPEC_TRACE_RESET_FILE" => "yes",
        "LINKEDSPEC_TRACE_EMOJI" => "on",
    ))
    @test (
        environment_config.level,
        environment_config.trace_file,
        environment_config.sink_mode,
        environment_config.reset_file,
        environment_config.emoji,
    ) == (
        LinkedSpecTraceDebug,
        "trace.log",
        LinkedSpecTraceMirror,
        true,
        true,
    )

    mktempdir() do directory
        trace_path = joinpath(directory, "route.log")
        write(trace_path, "old\n")
        route_stdout = IOBuffer()
        route_config = with_trace_reset_file(with_trace_file(
            trace_config_enabled(LinkedSpecTraceDebug),
            trace_path,
        ))
        route_emitter = LinkedSpecTraceEmitter(route_config; stdout_io = route_stdout)
        emit_trace_line!(route_emitter, LinkedSpecTraceLow, "hello")
        @test isempty(String(take!(route_stdout)))
        @test read(trace_path, String) == "hello\n"

        mirror_stdout = IOBuffer()
        mirror_config = with_trace_sink_mode(route_config, LinkedSpecTraceMirror)
        mirror_emitter = LinkedSpecTraceEmitter(mirror_config; stdout_io = mirror_stdout)
        emit_trace_event!(
            mirror_emitter,
            LinkedSpecTraceLog,
            "topic",
            "details",
            LinkedSpecTraceLow,
        )
        expected = "[LOW][log] topic details\n"
        @test String(take!(mirror_stdout)) == expected
        @test read(trace_path, String) == expected
    end

    primitive_stdout = IOBuffer()
    primitive_emitter = LinkedSpecTraceEmitter(
        trace_config_enabled(LinkedSpecTraceDebug);
        stdout_io = primitive_stdout,
    )
    scope = enter_trace_scope!(
        primitive_emitter,
        "compile",
        "start",
        LinkedSpecTraceHigh,
    )
    @test !trace_decision!(
        primitive_emitter,
        "use_cache",
        false,
        "miss",
        LinkedSpecTraceDebug,
    )
    log_trace_output!(primitive_emitter, LinkedSpecTraceLow, "runtime message", "ctx=run")
    log_trace_dump!(primitive_emitter, LinkedSpecTraceFull, "compiled descriptor dump")
    exit_trace_scope!(primitive_emitter, scope, "done")
    primitive_output = String(take!(primitive_stdout))
    @test occursin("[HIGH][enter] -> compile start", primitive_output)
    @test occursin("[DEBUG][decision]   use_cache taken=0 reason=miss", primitive_output)
    @test occursin("[LOW][log]   log_output runtime message context=ctx=run", primitive_output)
    @test occursin("[FULL][dump]   log_dump compiled descriptor dump", primitive_output)
    @test occursin("[HIGH][exit] <- compile done", primitive_output)
    @test [to_json(event)["kind"] for event in trace_events(primitive_emitter)] ==
        ["enter", "decision", "log", "dump", "exit"]

    runtime_engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::
 /x/
 E { return(match_text()) }
""")))
    untraced = runtime_parse(runtime_engine, "x")
    quiet_stdout = IOBuffer()
    quiet_emitter = LinkedSpecTraceEmitter(
        trace_config_disabled();
        stdout_io = quiet_stdout,
    )
    quiet = runtime_parse(runtime_engine, "x"; trace = quiet_emitter)
    @test to_json(quiet) == to_json(untraced)
    @test isempty(String(take!(quiet_stdout)))
    @test isempty(trace_events(quiet_emitter))

    mktempdir() do directory
        trace_path = joinpath(directory, "runtime.log")
        trace_config = with_trace_reset_file(with_trace_file(
            trace_config_enabled(LinkedSpecTraceDebug),
            trace_path,
        ))
        routed = runtime_execute_with_trace(runtime_engine, "x", trace_config)
        @test to_json(routed) == to_json(untraced)
        runtime_trace = read(trace_path, String)
        @test occursin("julia_runtime:parse", runtime_trace)
        @test occursin("top_rule=Top", runtime_trace)
        @test occursin("matched=true cursor=1", runtime_trace)
    end

    instrumented_engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::
 I { stage = "started" }
 /BEGIN/ -> Child {
   save_cursor()
   body = capture_until_boundary(Boundary)
   restore_cursor()
   rewind_match_start()
   rewind_entry_start()
 }
 E { return(hash("body", body, "stage", stage)) }

Child:
 /BEGIN/
 E { return("child") }

Boundary: /STOP/
""")))
    instrumented_untraced = runtime_parse(instrumented_engine, "BEGIN body STOP")
    instrumented_stdout = IOBuffer()
    instrumented_emitter = LinkedSpecTraceEmitter(
        trace_config_enabled(LinkedSpecTraceDebug);
        stdout_io = instrumented_stdout,
    )
    instrumented_traced = runtime_parse(
        instrumented_engine,
        "BEGIN body STOP";
        trace = instrumented_emitter,
    )
    @test instrumented_untraced.value == Dict{String,Any}(
        "body" => " body ",
        "stage" => "started",
    )
    @test to_json(instrumented_traced) == to_json(instrumented_untraced)
    instrumented_events = trace_events(instrumented_emitter)
    instrumented_topics = [event.topic for event in instrumented_events]
    @test "julia_runtime:rule" in instrumented_topics
    @test "julia_runtime:regex_match" in instrumented_topics
    @test "julia_runtime:lifecycle_block" in instrumented_topics
    @test any(
        event.topic == "julia_runtime:child_dispatch" &&
        occursin("edge_family=action", event.details)
        for event in instrumented_events
    )
    @test "julia_runtime:cursor_control" in instrumented_topics
    @test "julia_runtime:source_boundary" in instrumented_topics
    @test all(
        any(
            event.topic == "julia_runtime:cursor_control" &&
            occursin("helper=$helper", event.details)
            for event in instrumented_events
        )
        for helper in (
            "save_cursor",
            "restore_cursor",
            "rewind_match_start",
            "rewind_entry_start",
        )
    )
    @test any(
        event.topic == "julia_runtime:source_boundary" &&
        occursin("capture_start=5 boundary=11 length=6 found=1", event.details)
        for event in instrumented_events
    )

    blind_engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
BlindTop::AND
 => First
 => Second
 E { return("blind") }

First: /a/
Second: /b/
""")))
    blind_untraced = runtime_parse(blind_engine, "ab")
    blind_emitter = LinkedSpecTraceEmitter(
        trace_config_enabled(LinkedSpecTraceDebug);
        stdout_io = IOBuffer(),
    )
    blind_traced = runtime_parse(blind_engine, "ab"; trace = blind_emitter)
    @test to_json(blind_traced) == to_json(blind_untraced)
    @test any(
        event.topic == "julia_runtime:child_dispatch" &&
        occursin("edge_family=blind mode=AND", event.details)
        for event in trace_events(blind_emitter)
    )

    recursion_engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Loop::OR
 /x*/
 => Loop
""")))
    recursion_untraced = runtime_parse(recursion_engine, "x")
    recursion_emitter = LinkedSpecTraceEmitter(
        trace_config_enabled(LinkedSpecTraceDebug);
        stdout_io = IOBuffer(),
    )
    recursion_traced = runtime_parse(recursion_engine, "x"; trace = recursion_emitter)
    @test to_json(recursion_traced) == to_json(recursion_untraced)
    @test any(
        event.topic == "julia_runtime:recursion_guard" &&
        occursin("taken=1", event.details)
        for event in trace_events(recursion_emitter)
    )
end

@testset "Frontend compiler and staged trace coverage" begin
    source = raw"""
Top::
 /x/ -> Child { return(entry_text()) }

Child: /x/
"""
    untraced_spec = parse_spec(source)
    untraced_compiled = compile_spec(untraced_spec)
    frontend_output = IOBuffer()
    frontend_trace = LinkedSpecTraceEmitter(
        trace_config_enabled(LinkedSpecTraceDebug);
        stdout_io = frontend_output,
    )
    traced_spec = parse_spec(source; trace = frontend_trace)
    traced_compiled = compile_spec(traced_spec; trace = frontend_trace)

    @test to_json(traced_spec) == to_json(untraced_spec)
    @test to_descriptor_json(traced_compiled) == to_descriptor_json(untraced_compiled)
    frontend_events = trace_events(frontend_trace)
    frontend_topics = [event.topic for event in frontend_events]
    @test "julia_frontend:parse_spec" in frontend_topics
    @test "julia_frontend:parse_spec:result" in frontend_topics
    @test "julia_frontend:validate_spec" in frontend_topics
    @test "julia_frontend:validate_spec:edge_targets" in frontend_topics
    @test "julia_compiler:compile_spec" in frontend_topics
    @test "julia_compiler:compile_spec:rule" in frontend_topics
    @test "julia_compiler:compile_spec:dependency_regex_map" in frontend_topics
    @test count(
        event -> event.topic == "julia_frontend:parse_spec" &&
            event.kind == LinkedSpecTraceEnter,
        frontend_events,
    ) == 1
    @test count(
        event -> event.topic == "julia_frontend:parse_spec" &&
            event.kind == LinkedSpecTraceExit,
        frontend_events,
    ) == 1
    @test occursin("status=ok", String(take!(frontend_output)))

    invalid_spec = parse_spec("Top::\n -> Missing")
    invalid_trace = LinkedSpecTraceEmitter(
        trace_config_enabled(LinkedSpecTraceDebug);
        stdout_io = IOBuffer(),
    )
    @test_throws SpecValidationException compile_spec(invalid_spec; trace = invalid_trace)
    @test any(
        event.topic == "julia_frontend:validate_spec:edge_targets" &&
        event.kind == LinkedSpecTraceDecision &&
        occursin("taken=0", event.details)
        for event in trace_events(invalid_trace)
    )
    @test any(
        event.topic == "julia_compiler:compile_spec" &&
        event.kind == LinkedSpecTraceExit &&
        occursin("status=error", event.details)
        for event in trace_events(invalid_trace)
    )

    function_source = read(
        joinpath(CORPUS_ROOT, "terse_4_3_2_user_function_runtime", "input.spec"),
        String,
    )
    staged_output = IOBuffer()
    staged_trace = LinkedSpecTraceEmitter(
        trace_config_enabled(LinkedSpecTraceDebug);
        stdout_io = staged_output,
    )
    traced_staged = parse_spec_with_staged_user_function_definitions(
        function_source;
        trace = staged_trace,
    )
    untraced_staged = parse_spec_with_staged_user_function_definitions(function_source)
    @test to_json(traced_staged) == to_json(untraced_staged)
    staged_events = trace_events(staged_trace)
    staged_topics = [event.topic for event in staged_events]
    @test "julia_frontend:function_shell:parse_definitions" in staged_topics
    @test "julia_frontend:function_shell:parse_definitions:result" in staged_topics
    @test "julia_frontend:function_shell:project" in staged_topics
    @test "julia_frontend:function_shell:parse_spec" in staged_topics
    @test "julia_staged:dispatch_function_body_parse_jobs" in staged_topics
    @test "julia_staged:execute_parse_jobs" in staged_topics
    @test all(
        "julia_staged:execute_parse_jobs:$phase" in staged_topics
        for phase in ("normalize_job", "queue_sorted", "resolve", "load", "compile", "execute")
    )
    @test occursin("julia_staged:execute_parse_jobs:execute", String(take!(staged_output)))

    quiet_output = IOBuffer()
    quiet_trace = LinkedSpecTraceEmitter(trace_config_disabled(); stdout_io = quiet_output)
    quiet_spec = parse_spec(source; trace = quiet_trace)
    quiet_compiled = compile_spec(quiet_spec; trace = quiet_trace)
    @test to_descriptor_json(quiet_compiled) == to_descriptor_json(untraced_compiled)
    @test isempty(trace_events(quiet_trace))
    @test isempty(String(take!(quiet_output)))

    mktempdir() do directory
        trace_path = joinpath(directory, "frontend.log")
        route_config = with_trace_reset_file(with_trace_file(
            trace_config_enabled(LinkedSpecTraceDebug),
            trace_path,
        ))
        route_trace = LinkedSpecTraceEmitter(route_config; stdout_io = IOBuffer())
        parse_spec(source; trace = route_trace)
        @test occursin("julia_frontend:parse_spec", read(trace_path, String))
    end
end

@testset "Spec parser" begin
    modes = Dict(
        "R1:AND" => RuleMode("And"),
        "R2:OR+" => RuleMode("OrPlus"),
        "R3::*" => RuleMode("Star"),
        "R4:?" => RuleMode("Optional"),
        "R5:AND{2,4}" => and_bounded_rule_mode(min = 2, max = 4),
        "R6:OR{3}" => or_bounded_rule_mode(min = 3, max = 3),
        "R7:&" => RuleMode("Single"),
        "R8:|" => RuleMode("Pipe"),
    )

    for (header, mode) in modes
        spec = parse_spec("$header\n /x/")
        @test spec.rules[1].header.mode == mode
        @test spec.rules[1].body[1].kind isa RegexBodyElementKind
    end

    inline = parse_spec("Top:: /x/ I { return(entry_text()) } E.return(\"done\")")
    @test inline.rules[1].header.rest == "/x/ I { return(entry_text()) } E.return(\"done\")"
    @test inline.rules[1].body[1].kind isa RegexBodyElementKind
    @test inline.rules[1].body[2].kind isa CodeBlockBodyElementKind
    @test inline.rules[1].body[3].kind isa CodeBlockBodyElementKind

    single = parse_spec("Top::\n -> semi\n\nsemi : /;/")
    @test _regex_patterns_of(find_rule(single, "semi")) == [";"]

    pair = parse_spec("Top::\n -> bracket\n\nbracket : /\\(/ /\\)/")
    @test _regex_patterns_of(find_rule(pair, "bracket")) == ["\\(", "\\)"]

    edges = parse_spec(raw"""
Top::->Child.push
 -> Child[1] .return(array("?child:", copy(array(Child))))
 -> A | B { return(entry_text()) }
 =>Helper.trim()

Child: /x/ /y/
Helper: /h/
""")
    top = top_rule(edges)
    @test length(top.body) == 4
    compact = top.body[1].kind
    @test compact isa ActionEdgeBodyElementKind
    @test compact.targets[1].label == "Child"
    @test compact.targets[1].index == 0
    @test compact.fluent_chain[1].method == "push"

    indexed = top.body[2].kind
    @test indexed isa ActionEdgeBodyElementKind
    @test indexed.targets[1].index == 1
    @test indexed.fluent_chain[1].method == "return"
    @test indexed.fluent_chain[1].args == "array(\"?child:\", copy(array(Child)))"

    grouped = top.body[3].kind
    @test grouped isa ActionEdgeBodyElementKind
    @test [target.label for target in grouped.targets] == ["A", "B"]
    @test grouped.code == "return(entry_text())"

    blind = top.body[4].kind
    @test blind isa BlindEdgeBodyElementKind
    @test blind.target == "Helper"
    @test blind.fluent_chain[1].method == "trim"

    continuation = parse_spec(raw"""
Top::
 -> item
  .if(on)
    .push(item, out)
  .else()
    .return_undef()
  .endif()

item: /x/
""")
    edge = top_rule(continuation).body[1].kind
    @test [(call.method, call.args) for call in edge.fluent_chain] == [
        ("if", "on"),
        ("push", "item, out"),
        ("else", ""),
        ("return_undef", ""),
        ("endif", ""),
    ]

    attached = parse_spec(raw"""
Top::
 -> Done.when(false) {
    return("bad")
 }.otherwise {
    return("fallback")
 }
 I.when(false) { set(out, "bad") } otherwise { set(out, "fallback") }

Done:
 /x/
""")
    action = top_rule(attached).body[1].kind
    @test action isa ActionEdgeBodyElementKind
    @test isempty(action.fluent_chain)
    @test occursin("when(false)", action.code)
    @test occursin("return(\"fallback\")", action.code)
    lifecycle = top_rule(attached).body[2].kind
    @test lifecycle isa CodeBlockBodyElementKind
    @test lifecycle.lifecycle == "I"
    @test occursin("otherwise", lifecycle.code)

    compact_lifecycle = parse_spec(raw"""
Top::
 I.set(out, undef).set(out, "ok").return(out)
 /x/
""")
    block = top_rule(compact_lifecycle).body[1].kind
    @test block isa CodeBlockBodyElementKind
    @test block.code == "set(out, undef); set(out, \"ok\"); return(out)"

    multiline_args = parse_spec(raw"""
Top::
 I.return({
  "type" => "function_definition_error",
  "source_text" => entry_text()
 })
 /x/
""")
    multiline_block = top_rule(multiline_args).body[1].kind
    @test multiline_block isa CodeBlockBodyElementKind
    @test startswith(multiline_block.code, "return({")
    @test occursin("\"source_text\" => entry_text()", multiline_block.code)
    @test top_rule(multiline_args).body[2].kind isa RegexBodyElementKind

    quoted_braces = parse_spec(raw"""
Top::
 /a/ I { print("literal { brace"); print('literal } brace') }
 /b/ E { return("ok") }
""")
    quoted_block = top_rule(quoted_braces).body[2].kind
    @test quoted_block isa CodeBlockBodyElementKind
    @test occursin("print(\"literal { brace\")", quoted_block.code)
    @test occursin("print('literal } brace')", quoted_block.code)
    @test top_rule(quoted_braces).body[3].kind isa RegexBodyElementKind

    raw_fallback = parse_spec("Top::\n raw compatibility line")
    @test top_rule(raw_fallback).body[1].kind isa RawBodyElementKind
    @test_throws SpecParseException parse_spec("fn normalize(value) { return(trim(value)) }\n\nTop::\n /x/")

    spec_files = sort(filter(path -> endswith(path, ".spec"), readdir(joinpath(REPO_ROOT, "specs"); join = true)))
    @test !isempty(spec_files)
    for file in spec_files
        parsed = parse_spec(read(file, String))
        @test !isempty(parsed.rules)
    end

    corpus_specs = String[]
    for (root, _, files) in walkdir(CORPUS_ROOT)
        for file in files
            if file == "input.spec"
                push!(corpus_specs, joinpath(root, file))
            end
        end
    end
    sort!(corpus_specs)

    parsed_count = 0
    skipped_function_shells = 0
    for file in corpus_specs
        source = read(file, String)
        if _starts_with_top_level_function(source)
            skipped_function_shells += 1
            continue
        end
        parsed = parse_spec(source)
        @test !isempty(parsed.rules)
        parsed_count += 1
    end
    @test parsed_count > 80
    @test skipped_function_shells > 0
end

@testset "Spec validation" begin
    valid = parse_spec("Top::\n /a/ -> Child\n\nChild:\n /b/")
    @test validate_spec(valid) === nothing

    no_top = parse_spec("Rule:\n /a/")
    @test _throws_validation_message(() -> validate_spec(no_top), "no top rule")

    duplicate = parse_spec("Top::\n /a/\n\nTop:\n /b/")
    @test _throws_validation_message(() -> validate_spec(duplicate), "duplicate rule label")

    mixed = parse_spec(raw"""
Top::
 /a/ -> A
 /b/ => B

A: /a/
B: /b/
""")
    @test _throws_validation_message(() -> validate_spec(mixed), "mixes action")

    missing = parse_spec("Top::\n /a/ -> Ghost")
    @test _throws_validation_message(() -> validate_spec(missing), "undefined rule")

    bad_index = parse_spec("Top::\n /a/ -> Child[1]\n\nChild:\n /b/")
    @test _throws_validation_message(() -> validate_spec(bad_index), "regex slot 1")

    grouped = parse_spec("Top::\n -> A | B\n\nA: /a/\nB: /b/")
    @test _throws_validation_message(() -> validate_spec(grouped), "grouped action-edge targets")

    raw = parse_spec("Top::\n unsupported helper line")
    @test _throws_validation_message(() -> validate_spec(raw), "unrecognized body syntax")

    invalid_regex = parse_spec("Top::\n /[invalid/")
    @test _throws_validation_message(() -> validate_spec(invalid_regex), "invalid regex pattern")

    strict_unused = parse_spec("Top::\n /a/ -> Child\n\nChild:\n /b/")
    @test validate_spec(strict_unused) === nothing
    @test _throws_validation_message(() -> validate_spec(strict_unused; strict_syntax = true), "unused")
    @test _throws_validation_message(() -> validate_spec(strict_unused; strict_syntax = true), "Top")

    recursive_top = parse_spec("Top::\n /a/ -> Top")
    @test validate_spec(recursive_top; strict_syntax = true) === nothing

    ok_function = _spec_with_functions([_function_definition("normalize", ["value"])])
    @test validate_spec(ok_function) === nothing

    duplicate_function = _spec_with_functions([
        _function_definition("normalize", ["value"]),
        _function_definition("normalize", ["other"]),
    ])
    @test _throws_validation_message(() -> validate_spec(duplicate_function), "duplicate user function")

    rule_collision = _spec_with_functions([_function_definition("Top", ["value"])])
    @test _throws_validation_message(() -> validate_spec(rule_collision), "collides with rule label")

    builtin_collision = _spec_with_functions([_function_definition("trim", ["value"])])
    @test _throws_validation_message(() -> validate_spec(builtin_collision), "built-in helper")

    invalid_function_name = _spec_with_functions([_function_definition("1bad", ["value"])])
    @test _throws_validation_message(() -> validate_spec(invalid_function_name), "invalid user function name")

    duplicate_param = _spec_with_functions([_function_definition("normalize", ["value", "value"])])
    @test _throws_validation_message(() -> validate_spec(duplicate_param), "duplicate parameter")

    reserved_param = _spec_with_functions([_function_definition("normalize", ["ctx"])])
    @test _throws_validation_message(() -> validate_spec(reserved_param), "parameter 'ctx' is reserved")

    arity_mismatch = _spec_with_functions([_function_definition("normalize", ["value"]; arity = 2)])
    @test _throws_validation_message(() -> validate_spec(arity_mismatch), "arity")

    spec_files = sort(filter(path -> endswith(path, ".spec"), readdir(joinpath(REPO_ROOT, "specs"); join = true)))
    @test !isempty(spec_files)
    for file in spec_files
        validate_spec(parse_spec(read(file, String)))
    end

    corpus_specs = String[]
    for (root, _, files) in walkdir(CORPUS_ROOT)
        for file in files
            if file == "input.spec"
                push!(corpus_specs, joinpath(root, file))
            end
        end
    end
    sort!(corpus_specs)

    parsed_count = 0
    for file in corpus_specs
        source = read(file, String)
        if _starts_with_top_level_function(source)
            continue
        end
        validate_spec(parse_spec(source))
        parsed_count += 1
    end
    @test parsed_count > 80
end

@testset "User function definition shell projection" begin
    source = join([
        "fn zero() {return(\"zero\")}",
        "Top::",
        " /x/ -> Done { return(zero()) }",
        "",
        "Done:",
        " /[a-z]+/",
        "",
        "fn after(value) { return(value) }",
        "",
    ], "\n")

    nodes = [
        _definition_node(source, "zero", String[], "return(\"zero\")"),
        _definition_node(source, "after", ["value"], " return(value) "),
    ]

    @test _throws_parse_message(
        () -> parse_spec_with_user_function_definition_asts(source, Any[]),
        "rule parse after function extraction failed",
    )

    projection = project_user_function_definition_asts(source, nodes)
    @test [function_definition.name for function_definition in projection.functions] == ["zero", "after"]
    @test length(split(projection.stripped_source, '\n'; keepempty = true)) ==
        length(split(source, '\n'; keepempty = true))
    @test !occursin("fn zero", projection.stripped_source)
    @test occursin("Top::", projection.stripped_source)

    zero = projection.functions[1]
    @test isempty(zero.params)
    @test zero.arity == 0
    @test zero.body_source == "return(\"zero\")"
    @test zero.body_payload["parent_ast_path"] == ["functions", "0", "body_source"]
    @test zero.body_parse_job.parent_ast_path == ["functions", "0", "body_source"]
    @test zero.body_parse_job.job_id ==
        "parse_job:function_body:functions.0.body_source:actionir-body.spec:action_block:11-25"
    @test zero.body_parse_job.version == 1
    @test zero.body_parse_job.function_name == "zero"
    @test zero.body_parse_job.params == String[]
    @test zero.body_parse_job.arity == 0
    @test zero.body_parse_job.diagnostic_owner == "function_body"
    @test zero.body_ast === nothing

    parsed = parse_spec_with_user_function_definition_asts(source, nodes)
    @test validate_spec(parsed) === nothing
    @test length(parsed.functions) == 2
    @test [rule.header.label for rule in parsed.rules] == ["Top", "Done"]

    malformed = Dict{String,Any}(
        "type" => "function_definition_error",
        "kind" => "user_function_definition_error",
        "message" => "invalid user function definition",
        "source_text" => "fn bad(value",
        "source_span" => Dict("start" => 0, "end" => 12, "line_start" => 1, "line_end" => 1),
    )
    @test _throws_parse_message(
        () -> project_user_function_definition_asts("fn bad(value\nTop::\n /x/\n", [malformed]),
        "user function definition parse error at line 1",
    )

    drift = _definition_node("fn zero() {return(\"zero\")}\nTop::\n /x/\n", "zero", String[], "return(\"zero\")")
    drift["body_parse_job"]["text"] = "return(\"drift\")"
    @test _throws_user_function_message(
        () -> project_user_function_definition_asts("fn zero() {return(\"zero\")}\nTop::\n /x/\n", [drift]),
        "body_parse_job text does not match body_source",
    )

    node = Dict{String,Any}("type" => "function_definition")
    @test definition_nodes_from_user_function_definition_output(nothing) == Any[]
    @test definition_nodes_from_user_function_definition_output(Any[]) == Any[]
    @test definition_nodes_from_user_function_definition_output(node) == Any[node]
    @test definition_nodes_from_user_function_definition_output(Any[node]) == Any[node]
    @test definition_nodes_from_user_function_definition_output(Any[Any[node], Any[]]) == Any[node]
end

@testset "Spec-driven user function definition parser" begin
    source = read(
        joinpath(CORPUS_ROOT, "terse_4_3_2_user_function_runtime", "input.spec"),
        String,
    )
    nodes = parse_user_function_definition_asts(source)

    @test length(nodes) == 2
    @test [node["name"] for node in nodes] == ["normalize", "words"]
    @test [node["body_source"] for node in nodes] == [
        " return(trim(value)) ",
        " set(scratch, trim(value)); return([scratch, uppercase(scratch)]) ",
    ]

    spec = parse_spec_with_staged_user_function_definitions(source)
    @test [definition.name for definition in spec.functions] == ["normalize", "words"]
    @test all(definition -> definition.body_ast !== nothing, spec.functions)
    @test [rule.header.label for rule in spec.rules] == ["Top", "Done"]
    @test validate_spec(spec) === nothing
end

@testset "Corpus manifest IO" begin
    validation = load_corpus_fixtures(CORPUS_ROOT)

    @test validation.root == CORPUS_ROOT
    @test validation.manifest.format == 1
    @test validation.manifest.case_count == 105
    @test length(validation.manifest.cases) == validation.manifest.case_count
    @test length(validation.fixtures) == validation.manifest.case_count
    @test validation.fixtures[1].name == "proof_edge_array_literal"
    @test !isempty(validation.fixtures[1].spec_source)
    @test validation.fixtures[1].expected_json == ["?proof:", "ok"]

    cli_output = IOBuffer()
    cli_error = IOBuffer()
    @test run_corpus_runner(["--corpus", CORPUS_ROOT]; io = cli_output, err = cli_error) == 0
    cli_text = String(take!(cli_output))
    @test occursin("fixtures: 105", cli_text)
    @test occursin("manifest validated", cli_text)
    @test isempty(String(take!(cli_error)))

    mktempdir() do root
        _write_manifest(root, ["alpha"]; format = 2)
        _write_fixture(root, "alpha")
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "unsupported corpus manifest format 2")
    end

    mktempdir() do root
        _write_manifest(root, ["../bad"])
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "invalid corpus manifest case name: ../bad")
    end

    mktempdir() do root
        _write_manifest(root, ["alpha", "alpha"])
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "duplicate case names")
    end

    mktempdir() do root
        _write_manifest(root, ["alpha", "beta"])
        _write_fixture(root, "alpha")
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "missing fixture dirs: [beta]")
    end

    mktempdir() do root
        _write_manifest(root, ["alpha"])
        _write_fixture(root, "alpha")
        _write_fixture(root, "stale")
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "extra fixture dirs: [stale]")
    end

    mktempdir() do root
        _write_manifest(root, ["alpha"]; case_count = 2)
        _write_fixture(root, "alpha")
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "case_count=2 does not match cases.len()=1")
    end

    mktempdir() do root
        _write_manifest(root, ["alpha"])
        _write_fixture(root, "alpha"; write_expected = false)
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "expected.json")
    end

    mktempdir() do root
        _write_manifest(root, ["alpha"])
        _write_fixture(root, "alpha"; expected_text = "{")
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "malformed expected.json for corpus case alpha")
    end
end

@testset "Controlled corpus execution" begin
    mktempdir() do root
        cases = [
            "scalar_output",
            "nested_aggregate_output",
            "rule_dispatch_output",
            "lifecycle_output_shape",
            "boundary_capture",
            "user_function_call",
        ]
        _write_manifest(root, cases)
        _write_fixture(
            root,
            "scalar_output";
            spec_source = raw"""
Top::
 /x/ -> Done { return("scalar-ok") }

Done::
 /[a-z]+/
""",
            input_text = "xhello",
            expected_json = "scalar-ok",
        )
        _write_fixture(
            root,
            "nested_aggregate_output";
            spec_source = raw"""
Top::
 /n/ -> Done { return(hash("items", array("a", hash("b", 2)), "flag", true, "none", undef)) }

Done::
 /ested/
""",
            input_text = "nested",
            expected_json = Dict{String,Any}(
                "flag" => true,
                "items" => Any["a", Dict{String,Any}("b" => 2)],
                "none" => nothing,
            ),
        )
        _write_fixture(
            root,
            "rule_dispatch_output";
            spec_source = raw"""
Top::AND
 I { set(array(out), []) }
 => First { push(array(out), retv) }
 => Second { push(array(out), retv) }
 E { return(copy(array(out))) }

First:
 /a/
 E { return("first") }

Second:
 /b/
 E { return("second") }
""",
            input_text = "ab",
            expected_json = Any["first", "second"],
        )
        _write_fixture(
            root,
            "lifecycle_output_shape";
            spec_source = raw"""
Top::OR{1}
 I { push(array(events), "I") }
 LS { push(array(events), "LS") }
 /x/
 LE { push(array(events), "LE") }
 IT { push(array(events), "IT") }
 EX { push(array(events), "EX") }
 LX { push(array(events), "LX") }
 E { return(hash("cursor", cursor_pos(), "events", copy(array(events)))) }
""",
            input_text = "x",
            expected_json = Dict{String,Any}(
                "cursor" => 1,
                "events" => Any["I", "LS", "LE", "IT", "EX", "LX"],
            ),
        )
        _write_fixture(
            root,
            "boundary_capture";
            spec_source = raw"""
Top::
 /BEGIN/
 E {
   body = capture_until_boundary(Boundary, EarlierBoundary)
   return(hash("body", body, "cursor", cursor_pos(), "rest", cursor_rest()))
 }

Boundary: /END/
EarlierBoundary: /STOP/
""",
            input_text = "BEGIN body STOP later END",
            expected_json = Dict{String,Any}(
                "body" => " body ",
                "cursor" => 11,
                "rest" => "STOP later END",
            ),
        )
        function_body = "return(hash(\"wrapped\", value))"
        function_source = join([
            "fn wrap(value) {$function_body}",
            "Top::",
            " /x/",
            " E { return(wrap(match_text())) }",
        ], "\n")
        _write_fixture(
            root,
            "user_function_call";
            spec_source = function_source,
            input_text = "x",
            expected_json = Dict{String,Any}("wrapped" => "x"),
        )

        function controlled_spec_parser(source)
            if _starts_with_top_level_function(source)
                nodes = [_definition_node(source, "wrap", ["value"], function_body)]
                return parse_spec_with_staged_user_function_definition_asts(source, nodes)
            end
            return parse_spec(source)
        end

        execution = execute_corpus_fixtures(
            root;
            spec_parser = controlled_spec_parser,
            trace_config = trace_config_enabled(LinkedSpecTraceDebug),
        )
        @test execution.validation.manifest.cases == cases
        @test length(execution.results) == 6
        @test corpus_execution_passed(execution)
        @test corpus_passed_count(execution) == 6
        @test isempty(corpus_failures(execution))
        @test corpus_fixture_result(execution, "scalar_output").actual_value == "scalar-ok"
        @test corpus_fixture_result(execution, "nested_aggregate_output").actual_value ==
            Dict{String,Any}(
                "flag" => true,
                "items" => Any["a", Dict{String,Any}("b" => 2)],
                "none" => nothing,
            )
        @test corpus_fixture_result(execution, "rule_dispatch_output").actual_output ==
            Any[Any["first", "second"]]
        @test corpus_fixture_result(execution, "lifecycle_output_shape").actual_output == Any[
            Dict{String,Any}(
                "cursor" => 1,
                "events" => Any["I", "LS", "LE", "IT", "EX", "LX"],
            ),
        ]
        boundary_result = corpus_fixture_result(execution, "boundary_capture")
        @test boundary_result.cursor_codeunit == 11
        @test any(
            line -> occursin("julia_runtime:source_boundary", line),
            boundary_result.trace_lines,
        )
        function_result = corpus_fixture_result(execution, "user_function_call")
        @test corpus_fixture_passed(function_result)
        @test function_result.actual_value == Dict{String,Any}("wrapped" => "x")
        @test_throws CorpusManifestException corpus_fixture_result(execution, "missing")
    end

    mktempdir() do root
        _write_manifest(root, ["runtime_failure", "output_mismatch", "passing_after_failures"])
        _write_fixture(
            root,
            "runtime_failure";
            spec_source = raw"""
Top::
 /x/
 E { unknown_runtime_helper(match_text()) }
""",
            expected_json = "unused",
        )
        _write_fixture(
            root,
            "output_mismatch";
            spec_source = raw"""
Top::
 /x/
 E { return("actual") }
""",
            expected_json = "expected",
        )
        _write_fixture(
            root,
            "passing_after_failures";
            spec_source = raw"""
Top::
 /x/
 E { return("ok") }
""",
            expected_json = "ok",
        )

        execution = execute_corpus_fixtures(root)
        @test !corpus_execution_passed(execution)
        @test corpus_passed_count(execution) == 1
        @test [result.name for result in corpus_failures(execution)] ==
            ["runtime_failure", "output_mismatch"]
        runtime_failure = corpus_fixture_result(execution, "runtime_failure")
        @test occursin("execute failed: unsupported runtime helper", runtime_failure.failure)
        @test runtime_failure.diagnostic isa RuntimeDiagnostic
        @test runtime_failure.diagnostic.stage == "runtime_execution"
        @test runtime_failure.diagnostic.spec_name == "runtime_failure"
        mismatch = corpus_fixture_result(execution, "output_mismatch")
        @test occursin("output mismatch", mismatch.failure)
        @test occursin("[\"expected\"]", mismatch.failure)
        @test corpus_fixture_passed(corpus_fixture_result(execution, "passing_after_failures"))
    end

    mktempdir() do root
        _write_manifest(root, ["mismatched", "first", "second"])
        _write_fixture(
            root,
            "mismatched";
            spec_source = _returning_spec("actual"),
            expected_json = "expected",
        )
        _write_fixture(
            root,
            "first";
            spec_source = _returning_spec("first"),
            expected_json = "first",
        )
        _write_fixture(
            root,
            "second";
            spec_source = _returning_spec("second"),
            expected_json = "second",
        )

        named = execute_corpus_fixtures(root; case_names = ["second", "first"])
        @test corpus_execution_passed(named)
        @test [result.name for result in named.results] == ["second", "first"]

        bounded = execute_corpus_fixtures(root; offset = 1, limit = 1)
        @test corpus_execution_passed(bounded)
        @test [result.name for result in bounded.results] == ["first"]
        capped = execute_corpus_fixtures(root; offset = 1, limit = 10)
        @test [result.name for result in capped.results] == ["first", "second"]

        @test _throws_corpus_message(
            () -> execute_corpus_fixtures(root; case_names = ["missing"]),
            "selected corpus case not found in manifest: missing",
        )
        @test _throws_corpus_message(
            () -> execute_corpus_fixtures(root; case_names = ["first", "first"]),
            "selection contains duplicate case name: first",
        )
        @test _throws_corpus_message(
            () -> execute_corpus_fixtures(root; case_names = ["first"], limit = 1),
            "case selection cannot be combined with offset or limit",
        )
        @test _throws_corpus_message(
            () -> execute_corpus_fixtures(root; offset = -1),
            "offset must be a non-negative integer",
        )
        @test _throws_corpus_message(
            () -> execute_corpus_fixtures(root; limit = 0),
            "limit must be a positive integer",
        )
        @test _throws_corpus_message(
            () -> execute_corpus_fixtures(root; offset = 3),
            "offset 3 is outside fixture count 3",
        )

        named_output = IOBuffer()
        named_error = IOBuffer()
        @test run_corpus_runner(
            ["--corpus", root, "--execute", "--case", "second"];
            io = named_output,
            err = named_error,
        ) == 0
        named_text = String(take!(named_output))
        @test occursin("PASS second", named_text)
        @test occursin("1 passed, 0 failed", named_text)
        @test !occursin("mismatched", named_text)
        @test isempty(String(take!(named_error)))

        bounded_output = IOBuffer()
        @test run_corpus_runner(
            ["--corpus=$root", "--execute", "--offset=1", "--limit=1"];
            io = bounded_output,
            err = IOBuffer(),
        ) == 0
        @test occursin("PASS first", String(take!(bounded_output)))

        failure_output = IOBuffer()
        @test run_corpus_runner(
            ["--corpus", root, "--execute", "--case=mismatched"];
            io = failure_output,
            err = IOBuffer(),
        ) == 1
        failure_text = String(take!(failure_output))
        @test occursin("FAIL mismatched: output mismatch", failure_text)
        @test occursin("0 passed, 1 failed", failure_text)

        full_output = IOBuffer()
        @test run_corpus_runner(
            ["--corpus", root, "--execute"];
            io = full_output,
            err = IOBuffer(),
        ) == 1
        full_text = String(take!(full_output))
        @test occursin("FAIL mismatched: output mismatch", full_text)
        @test occursin("PASS first", full_text)
        @test occursin("PASS second", full_text)
        @test occursin("2 passed, 1 failed", full_text)

        offset_output = IOBuffer()
        @test run_corpus_runner(
            ["--corpus", root, "--execute", "--offset", "1"];
            io = offset_output,
            err = IOBuffer(),
        ) == 0
        @test occursin("2 passed, 0 failed", String(take!(offset_output)))

        validation_selector_error = IOBuffer()
        @test run_corpus_runner(
            ["--corpus", root, "--case", "first"];
            io = IOBuffer(),
            err = validation_selector_error,
        ) == 2
        @test occursin("require --execute", String(take!(validation_selector_error)))

        invalid_limit_error = IOBuffer()
        @test run_corpus_runner(
            ["--corpus", root, "--execute", "--limit", "0"];
            io = IOBuffer(),
            err = invalid_limit_error,
        ) == 2
        @test occursin("--limit requires a positive integer", String(take!(invalid_limit_error)))

        mixed_selector_error = IOBuffer()
        @test run_corpus_runner(
            ["--corpus", root, "--execute", "--case", "first", "--offset", "0"];
            io = IOBuffer(),
            err = mixed_selector_error,
        ) == 2
        @test occursin("cannot be combined", String(take!(mixed_selector_error)))
    end
end

@testset "Starter corpus batch" begin
    execution = execute_corpus_fixtures(CORPUS_ROOT; offset = 0, limit = 40)
    failures = ["$(result.name): $(result.failure)" for result in corpus_failures(execution)]

    @test execution.validation.manifest.case_count == 105
    @test length(execution.results) == 40
    @test first(execution.results).name == "proof_edge_array_literal"
    @test last(execution.results).name == "terse_2_2_5_2_attached_switch_blocks"
    @test corpus_passed_count(execution) == 40
    @test isempty(failures)
end

@testset "Middle non-function corpus batch" begin
    windows = [(40, 17), (58, 2), (62, 6)]
    executions = [
        execute_corpus_fixtures(CORPUS_ROOT; offset = offset, limit = limit)
        for (offset, limit) in windows
    ]
    results = reduce(vcat, [execution.results for execution in executions])
    failures = ["$(result.name): $(result.failure)" for result in results if !corpus_fixture_passed(result)]

    @test [length(execution.results) for execution in executions] == [17, 2, 6]
    @test [(first(execution.results).name, last(execution.results).name) for execution in executions] == [
        ("terse_2_2_6_2_attached_while_blocks", "terse_3_2_3_4_numeric_comparison_symbol_callees"),
        ("terse_3_3_2_aggregate_assignment_expressions", "terse_3_3_3_mutation_assignment_expressions"),
        ("terse_2_3_5_5_block_valued_receiver_chains", "terse_2_3_5_6_typed_wrapper_quoted_names"),
    ]
    @test length(results) == 25
    @test sum(corpus_passed_count, executions) == 25
    @test isempty(failures)
    @test executions[1].validation.manifest.cases[[58, 61, 62]] == [
        "terse_3_3_1_scalar_assignment_expressions",
        "terse_3_3_4_assignment_expression_closure",
        "terse_4_3_2_user_function_runtime",
    ]
end

@testset "Shipped capture-boundary corpus batch" begin
    passing_names = [
        "hlink_curly_brace",
        "hlink_bracket_body",
        "hlink_mixed_bracket_brace",
    ]
    passing = execute_corpus_fixtures(CORPUS_ROOT; case_names = passing_names)
    failures = [
        "$(result.name): $(result.failure)"
        for result in passing.results if !corpus_fixture_passed(result)
    ]
    residual = execute_corpus_fixtures(
        CORPUS_ROOT;
        case_names = ["ebnf_logging_annotation"],
    )
    residual_result = only(residual.results)

    @test [result.name for result in passing.results] == passing_names
    @test corpus_passed_count(passing) == 3
    @test isempty(failures)
    @test corpus_fixture_passed(residual_result)
    @test residual_result.failure === nothing
    @test !occursin("unsupported runtime helper", something(residual_result.failure, ""))
end

@testset "Shipped logical-helper corpus batch" begin
    passing_names = [
        "portmap_bare",
        "portmap_bit",
        "portmap_constant",
        "portmap_concatenation",
        "tablegrep_simple_term",
    ]
    passing = execute_corpus_fixtures(CORPUS_ROOT; case_names = passing_names)
    failures = [
        "$(result.name): $(result.failure)"
        for result in passing.results if !corpus_fixture_passed(result)
    ]
    @test [result.name for result in passing.results] == passing_names
    @test corpus_passed_count(passing) == 5
    @test isempty(failures)
    constant_result = only(result for result in passing.results if result.name == "portmap_constant")
    @test corpus_fixture_passed(constant_result)
    @test constant_result.actual_output == Any[Any["?constant:", Any["0x1f"]]]
    @test constant_result.failure === nothing
end

@testset "Shipped mutation and leading-trivia corpus batch" begin
    execution = execute_corpus_fixtures(
        CORPUS_ROOT;
        case_names = ["simenv_multiline_value", "ds_vhistory_version_entry"],
    )
    simenv, history = execution.results

    @test [result.name for result in execution.results] == [
        "simenv_multiline_value",
        "ds_vhistory_version_entry",
    ]
    @test corpus_fixture_passed(simenv)
    @test simenv.actual_output == Any[simenv.expected_json]
    @test simenv.failure === nothing
    @test corpus_fixture_passed(history)
    @test history.actual_output == Any[history.expected_json]
    @test history.failure === nothing
end

@testset "Shipped recursive top-rule corpus batch" begin
    passing_names = [
        "top_rule_body_recursion_sexpr",
        "top_rule_lx_recursion_nested",
        "top_rule_lx_recursion_sequence",
    ]
    execution = execute_corpus_fixtures(CORPUS_ROOT; case_names = passing_names)
    failures = [
        "$(result.name): $(result.failure)"
        for result in execution.results if !corpus_fixture_passed(result)
    ]

    @test [result.name for result in execution.results] == passing_names
    @test corpus_passed_count(execution) == 3
    @test isempty(failures)
end

@testset "Shipped structural and quote-normalization corpus batch" begin
    passing_names = [
        "spec_spec_minimal_rule",
        "spec_spec_action_edge",
        "spec_spec_user_function_definition",
        "spec_spec_comment_skip",
        "ebnf_expression_rules",
        "ebnf_logging_annotation",
    ]
    passing = execute_corpus_fixtures(CORPUS_ROOT; case_names = passing_names)
    failures = [
        "$(result.name): $(result.failure)"
        for result in passing.results if !corpus_fixture_passed(result)
    ]
    @test [result.name for result in passing.results] == passing_names
    @test corpus_passed_count(passing) == 6
    @test isempty(failures)
    @test all(result -> result.actual_output == Any[result.expected_json], passing.results[5:6])
end

@testset "Shipped lib_reader quote-normalization corpus batch" begin
    passing_names = ["lib_reader_sattribute", "lib_reader_cattribute"]
    execution = execute_corpus_fixtures(CORPUS_ROOT; case_names = passing_names)
    failures = [
        "$(result.name): $(result.failure)"
        for result in execution.results if !corpus_fixture_passed(result)
    ]

    @test [result.name for result in execution.results] == passing_names
    @test corpus_passed_count(execution) == 2
    @test isempty(failures)
    @test all(result -> result.actual_output == Any[result.expected_json], execution.results)
end

@testset "Complete shipped-spec corpus batch" begin
    execution = execute_corpus_fixtures(CORPUS_ROOT; offset = 68, limit = 31)
    failures = [
        "$(result.name): $(result.failure)"
        for result in execution.results if !corpus_fixture_passed(result)
    ]

    @test execution.validation.manifest.case_count == 105
    @test length(execution.results) == 31
    @test (first(execution.results).name, last(execution.results).name) ==
          ("tclite_command_subst", "lib_reader_cattribute")
    @test corpus_passed_count(execution) == 31
    @test isempty(failures)
    @test all(result -> result.actual_output == Any[result.expected_json], execution.results)
end

@testset "Top-level user-function corpus batch" begin
    case_names = [
        "terse_3_3_1_scalar_assignment_expressions",
        "terse_3_3_4_assignment_expression_closure",
        "terse_4_3_2_user_function_runtime",
    ]
    execution = execute_corpus_fixtures(CORPUS_ROOT; case_names = case_names)
    failures = [
        "$(result.name): $(result.failure)"
        for result in execution.results if !corpus_fixture_passed(result)
    ]

    @test [result.name for result in execution.results] == case_names
    @test corpus_passed_count(execution) == 3
    @test isempty(failures)
    @test all(result -> result.actual_output == Any[result.expected_json], execution.results)
end

@testset "Complete corpus gate" begin
    execution = execute_corpus_fixtures(CORPUS_ROOT)
    failures = [
        "$(result.name): $(result.failure)"
        for result in execution.results if !corpus_fixture_passed(result)
    ]

    @test execution.validation.manifest.format == 1
    @test execution.validation.manifest.case_count == 105
    @test length(execution.results) == 105
    @test [result.name for result in execution.results] == execution.validation.manifest.cases
    @test (first(execution.results).name, last(execution.results).name) ==
          ("proof_edge_array_literal", "capability_capture_named_surface")
    @test corpus_passed_count(execution) == 105
    @test isempty(failures)
    @test all(result -> result.actual_output == Any[result.expected_json], execution.results)
end

@testset "Spec AST JSON contract" begin
    spec = SpecFile(
        functions = [
            FunctionDefinition(
                name = "normalize",
                params = ["value"],
                arity = 1,
                body_source = "return(trim(value))",
                body_payload = Dict("kind" => "action_block"),
                body_parse_job = StagedParseJob(
                    job_id = "parse_job:function_body:functions.0.body_source",
                    parent_ast_path = ["functions", "0", "body_source"],
                    node_kind = "function_definition",
                    payload_kind = "action_block",
                    text = "return(trim(value))",
                    source_span = StagedSourceSpan(10, 28, 1, 1),
                    parser_spec_id = "actionir-body.spec",
                    top_rule = "action_block",
                    result_policy = "replace_field",
                    result_field = "body_ast",
                    failure_policy = "diagnostic",
                ),
                body_ast = Dict("kind" => "code_block", "statements" => Any[]),
                source = "fn normalize(value) { return(trim(value)) }",
                source_span = SourceSpan(1, 1),
                body_span = SourceSpan(1, 1),
            ),
        ],
        rules = [
            Rule(
                header = RuleHeader(
                    "Top",
                    true,
                    and_bounded_rule_mode(min = 1, max = 2),
                    "/x/ -> Child[0] { return(normalize(retv)) }",
                    2,
                ),
                body = [
                    BodyElement(RegexBodyElementKind("x"), "/x/", 2),
                    BodyElement(
                        ActionEdgeBodyElementKind(
                            targets = [EdgeTarget(label = "Child")],
                            code = "return(normalize(retv))",
                            fluent_chain = [FluentCall("push", "")],
                        ),
                        "-> Child[0] { return(normalize(retv)) }.push",
                        2,
                    ),
                    BodyElement(
                        CodeBlockBodyElementKind("I", "set(count, 0)"),
                        "I { set(count, 0) }",
                        3,
                    ),
                ],
            ),
        ],
    )

    encoded = JSON3.write(to_json(spec))
    decoded = from_json(SpecFile, JSON3.read(encoded))

    @test decoded.functions[1].name == "normalize"
    @test decoded.functions[1].body_parse_job !== nothing
    @test decoded.functions[1].body_parse_job.job_id == "parse_job:function_body:functions.0.body_source"
    @test top_rule(decoded).header.mode == and_bounded_rule_mode(min = 1, max = 2)
    @test is_and(top_rule(decoded).header.mode)
    @test rep_min(top_rule(decoded).header.mode) == 1
    @test rep_max(top_rule(decoded).header.mode) == 2
    @test decoded.rules[1].body[2].kind isa ActionEdgeBodyElementKind
    @test to_json(decoded) == to_json(spec)

    @test rep_min(default_rule_mode()) == 0
    @test rep_min(RuleMode("Star")) == 0
    @test rep_max(RuleMode("Optional")) == 1
    @test rep_min(RuleMode("Plus")) == 1
    @test is_and(RuleMode("And"))
    @test !is_and(RuleMode("Or"))
    @test rep_max(or_bounded_rule_mode(min = 2)) === nothing
end
