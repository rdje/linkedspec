struct _PrimaryCliUsageException <: Exception
    message::String
end

Base.showerror(io::IO, error::_PrimaryCliUsageException) = print(io, error.message)

struct _PrimaryCliLoadException <: Exception
    stage::String
    message::String
end

Base.showerror(io::IO, error::_PrimaryCliLoadException) = print(io, error.message)

struct _PrimaryCliOptions
    spec::Union{Nothing,String}
    spec_file::Union{Nothing,String}
    inline_spec::Union{Nothing,String}
    input::Union{Nothing,String}
    input_file::Union{Nothing,String}
    top_rule::Union{Nothing,String}
    parse_mode::Union{Nothing,String}
    trace_level::Union{Nothing,String}
    trace_file::Union{Nothing,String}
    trace_mode::Union{Nothing,String}
    trace_reset::Bool
    trace_emoji::Bool
    help::Bool
end

struct _PrimaryCliRequest
    options::_PrimaryCliOptions
    spec_source::String
    spec_name::String
    spec_path::Union{Nothing,String}
    input::Union{Nothing,String}
    input_path::Union{Nothing,String}
end

const _PRIMARY_CLI_VALUE_OPTIONS = Set([
    "--spec",
    "--spec-file",
    "--inline-spec",
    "--input",
    "--input-file",
    "--top-rule",
    "--parse-mode",
    "--trace",
    "--trace-file",
    "--trace-mode",
])

const _PRIMARY_CLI_SEARCH_PRUNE = Set([
    ".git",
    ".dart_tool",
    "book",
    "compiled",
    "deps",
    "incremental",
    "node_modules",
    "target",
])

function _primary_cli_usage()
    return """Usage:
  linkedspec_julia --spec NAME --input TEXT [options]
  linkedspec_julia --spec-file PATH --input-file PATH [options]
  linkedspec_julia --inline-spec TEXT --input TEXT [options]

Source selection (choose exactly one):
  --spec NAME          Resolve and compile a named .spec through the native library
  --spec-file PATH     Compile .spec source read from PATH
  --inline-spec TEXT   Compile the literal .spec source TEXT

Input selection (choose exactly one):
  --input TEXT         Parse TEXT
  --input-file PATH    Parse file contents read from PATH

Parser options:
  --top-rule NAME      Select the entry rule
  --parse-mode MODE    MODE is seek or consume

Trace options:
  --trace LEVEL        Enable trace level: none, low, medium, high, full, debug
  --trace-file PATH    Write trace output to PATH
  --trace-mode MODE    MODE is stdout, route, or mirror
  --trace-reset        Truncate --trace-file before writing
  --trace-emoji        Enable emoji trace prefixes

Output:
  Prints the parser result as canonical JSON on stdout. When trace output is sent
  to stdout it is intentionally interleaved with that JSON; use --trace-file with
  --trace-mode route for machine-readable stdout plus routed trace.

Examples:
  linkedspec_julia --spec Lispish --input '(hello world)'
  linkedspec_julia --spec-file demo.spec --input-file demo.txt \
    --trace high --trace-file linkedspec.trace.log --trace-mode route --trace-reset
"""
end

function _parse_primary_cli_args(args)
    values = Dict{String,Union{Nothing,String}}(
        option => nothing for option in _PRIMARY_CLI_VALUE_OPTIONS
    )
    trace_reset = false
    trace_emoji = false
    help = false
    errors = String[]
    arguments = String[String(argument) for argument in args]

    index = 1
    while index <= length(arguments)
        argument = arguments[index]
        option, inline_value = _split_primary_cli_option(argument)

        if option == "--help" || option == "-h"
            if inline_value !== nothing
                push!(errors, "$option does not accept a value")
            else
                help = true
            end
        elseif option == "--trace-reset"
            if inline_value !== nothing
                push!(errors, "--trace-reset does not accept a value")
            else
                trace_reset = true
            end
        elseif option == "--trace-emoji"
            if inline_value !== nothing
                push!(errors, "--trace-emoji does not accept a value")
            else
                trace_emoji = true
            end
        elseif option in _PRIMARY_CLI_VALUE_OPTIONS
            if inline_value !== nothing
                values[option] = inline_value
            elseif index == length(arguments)
                push!(errors, "$option requires a value")
            else
                index += 1
                values[option] = arguments[index]
            end
        elseif startswith(option, "-")
            push!(errors, "unknown option '$option'")
        else
            push!(errors, "unexpected positional argument '$argument'")
        end
        index += 1
    end

    if !isempty(errors)
        throw(_PrimaryCliUsageException(join(errors, "; ")))
    end

    options = _PrimaryCliOptions(
        values["--spec"],
        values["--spec-file"],
        values["--inline-spec"],
        values["--input"],
        values["--input-file"],
        values["--top-rule"],
        values["--parse-mode"],
        values["--trace"],
        values["--trace-file"],
        values["--trace-mode"],
        trace_reset,
        trace_emoji,
        help,
    )
    if options.help
        return options
    end

    source_count = count(
        value -> value !== nothing,
        (options.spec, options.spec_file, options.inline_spec),
    )
    if source_count != 1
        throw(_PrimaryCliUsageException(
            "choose exactly one source option: --spec, --spec-file, or --inline-spec",
        ))
    end
    input_count = count(value -> value !== nothing, (options.input, options.input_file))
    if input_count != 1
        throw(_PrimaryCliUsageException(
            "choose exactly one input option: --input or --input-file",
        ))
    end
    if options.parse_mode !== nothing && !(options.parse_mode in ("seek", "consume"))
        throw(_PrimaryCliUsageException("--parse-mode must be 'seek' or 'consume'"))
    end
    if options.trace_level !== nothing
        if !_primary_cli_valid_trace_level(options.trace_level)
            throw(_PrimaryCliUsageException(
                "--trace has an unsupported level '$(options.trace_level)'",
            ))
        end
    end
    if options.trace_mode !== nothing &&
            !(options.trace_mode in ("stdout", "route", "mirror"))
        throw(_PrimaryCliUsageException(
            "--trace-mode must be 'stdout', 'route', or 'mirror'",
        ))
    end
    return options
end

function _primary_cli_valid_trace_level(value::String)
    if value != strip(value)
        return false
    end
    if tryparse(Int, value) !== nothing
        return true
    end
    return lowercase(value) in (
        "none",
        "quiet",
        "low",
        "medium",
        "med",
        "high",
        "full",
        "debug",
        "verbose",
    )
end

function _split_primary_cli_option(argument::String)
    if startswith(argument, "--")
        equals_index = findfirst(==('='), argument)
        if equals_index !== nothing
            option = argument[firstindex(argument):prevind(argument, equals_index)]
            value_start = nextind(argument, equals_index)
            value = value_start > lastindex(argument) ? "" : argument[value_start:lastindex(argument)]
            return option, value
        end
    end
    return argument, nothing
end

function _prepare_primary_cli_request(
    options::_PrimaryCliOptions;
    cwd::AbstractString = pwd(),
    repo_root::AbstractString = _primary_cli_repo_root(),
    load_input_file::Bool = true,
)
    spec_source, spec_name, spec_path = if options.spec !== nothing
        resolved = _resolve_named_spec_path(
            options.spec;
            cwd = cwd,
            repo_root = repo_root,
        )
        (_read_primary_cli_file(resolved, "spec file"), options.spec, resolved)
    elseif options.spec_file !== nothing
        path = _primary_cli_explicit_path(options.spec_file, cwd)
        (_read_primary_cli_file(path, "spec file"), basename(path), path)
    else
        (something(options.inline_spec, ""), "<inline>", nothing)
    end

    input, input_path = if options.input_file !== nothing
        path = _primary_cli_explicit_path(options.input_file, cwd)
        (
            load_input_file ? _read_primary_cli_file(path, "input file") : nothing,
            path,
        )
    else
        (something(options.input, ""), nothing)
    end

    return _PrimaryCliRequest(
        options,
        spec_source,
        spec_name,
        spec_path,
        input,
        input_path,
    )
end

function _resolve_named_spec_path(
    spec_name::AbstractString;
    cwd::AbstractString = pwd(),
    repo_root::AbstractString = _primary_cli_repo_root(),
)
    name = String(spec_name)
    if isempty(name) || isempty(strip(name)) || strip(name) != name || any(iscntrl, name)
        throw(_PrimaryCliLoadException(
            "spec",
            "invalid spec name: expected a non-empty value without surrounding whitespace or control characters",
        ))
    end

    current_root = abspath(String(cwd))
    repository_root = abspath(String(repo_root))
    spec_filename = endswith(name, ".spec") ? name : "$name.spec"
    candidates = String[
        _primary_cli_explicit_path(name, current_root),
        _primary_cli_explicit_path(spec_filename, current_root),
        normpath(joinpath(repository_root, "specs", spec_filename)),
    ]
    seen = Set{String}()
    for candidate in candidates
        if candidate in seen
            continue
        end
        push!(seen, candidate)
        if isfile(candidate)
            return candidate
        end
    end

    explicit = occursin('/', name) || occursin('\\', name) || endswith(name, ".spec")
    if explicit
        throw(_PrimaryCliLoadException("spec", "spec path not found: '$name'"))
    end

    fallback = _find_primary_cli_repository_spec(repository_root, spec_filename)
    if fallback !== nothing
        return fallback
    end
    throw(_PrimaryCliLoadException("spec", "spec path not found: '$name'"))
end

function _find_primary_cli_repository_spec(repo_root::String, spec_filename::String)
    if !isdir(repo_root)
        return nothing
    end
    for (root, directories, files) in walkdir(repo_root; topdown = true, follow_symlinks = false)
        filter!(directory -> !(directory in _PRIMARY_CLI_SEARCH_PRUNE), directories)
        sort!(directories)
        sort!(files)
        if spec_filename in files
            candidate = normpath(joinpath(root, spec_filename))
            if isfile(candidate)
                return candidate
            end
        end
    end
    return nothing
end

function _read_primary_cli_file(path::String, label::String)
    if !isfile(path)
        if isdir(path)
            throw(_PrimaryCliLoadException(label, "$label is not a file: '$path'"))
        end
        throw(_PrimaryCliLoadException(label, "$label not found: '$path'"))
    end
    try
        return read(path, String)
    catch error
        throw(_PrimaryCliLoadException(
            label,
            "cannot read $label '$path': $(sprint(showerror, error))",
        ))
    end
end

function _primary_cli_explicit_path(path::AbstractString, cwd::AbstractString)
    value = String(path)
    return isabspath(value) ? normpath(value) : normpath(joinpath(String(cwd), value))
end

_primary_cli_repo_root() = normpath(joinpath(@__DIR__, "..", "..", ".."))

function _primary_cli_trace_emitter(options::_PrimaryCliOptions; stdout_io::IO = stdout)
    trace_requested = options.trace_level !== nothing ||
        options.trace_file !== nothing ||
        options.trace_mode !== nothing ||
        options.trace_reset ||
        options.trace_emoji
    if !trace_requested
        return nothing
    end

    config = trace_config_disabled()
    if options.trace_level !== nothing
        config = with_trace_level(config, options.trace_level)
    end
    if options.trace_file !== nothing && !isempty(strip(options.trace_file))
        config = with_trace_file(config, strip(options.trace_file))
    end
    if options.trace_mode !== nothing
        config = with_trace_sink_mode(config, options.trace_mode)
    end
    if options.trace_reset
        config = with_trace_reset_file(config)
    end
    if options.trace_emoji
        config = with_trace_emoji(config)
    end
    return LinkedSpecTraceEmitter(config; stdout_io = stdout_io)
end

function _parse_primary_cli_spec(
    source::AbstractString;
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    try
        return parse_spec(source; trace = trace)
    catch error
        if error isa SpecParseException
            return parse_spec_with_staged_user_function_definitions(source; trace = trace)
        end
        rethrow()
    end
end

function _compile_primary_cli_request(
    request::_PrimaryCliRequest;
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    spec = _parse_primary_cli_spec(request.spec_source; trace = trace)
    compiled = compile_spec(spec; trace = trace)
    return LinkedSpecRuntimeEngine(
        compiled;
        parse_mode = something(request.options.parse_mode, "seek"),
        spec_name = request.spec_name,
        spec_path = request.spec_path,
    )
end

function _invoke_primary_cli_request(
    engine::LinkedSpecRuntimeEngine,
    request::_PrimaryCliRequest,
    input::AbstractString;
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
)
    return runtime_execute(
        engine,
        input;
        top_rule = request.options.top_rule,
        trace = trace,
    )
end

function _execute_primary_cli_request(request::_PrimaryCliRequest; stdout_io::IO = stdout)
    trace = _primary_cli_trace_emitter(request.options; stdout_io = stdout_io)
    engine = _compile_primary_cli_request(request; trace = trace)
    input = _load_primary_cli_request_input(request)
    return _invoke_primary_cli_request(engine, request, input; trace = trace)
end

function _primary_cli_canonical_json(value)
    output = IOBuffer()
    _write_primary_cli_canonical_json(output, value)
    return String(take!(output))
end

function _write_primary_cli_canonical_json(io::IO, value)
    if value === nothing
        print(io, "null")
    elseif value isa Bool
        print(io, value ? "true" : "false")
    elseif value isa AbstractString
        print(io, String(JSON3.write(String(value))))
    elseif value isa Number
        print(io, String(JSON3.write(value)))
    elseif value isa AbstractDict
        entries = Pair{String,Any}[]
        seen_keys = Set{String}()
        for (key, entry_value) in pairs(value)
            if !(key isa AbstractString)
                throw(ArgumentError(
                    "canonical JSON object keys must be strings, got $(typeof(key))",
                ))
            end
            text_key = String(key)
            if text_key in seen_keys
                throw(ArgumentError("canonical JSON object contains duplicate key '$text_key'"))
            end
            push!(seen_keys, text_key)
            push!(entries, text_key => entry_value)
        end
        sort!(entries; by = first)

        print(io, '{')
        for (index, entry) in enumerate(entries)
            if index > 1
                print(io, ',')
            end
            print(io, String(JSON3.write(first(entry))), ':')
            _write_primary_cli_canonical_json(io, last(entry))
        end
        print(io, '}')
    elseif value isa AbstractVector || value isa Tuple
        print(io, '[')
        for (index, item) in enumerate(value)
            if index > 1
                print(io, ',')
            end
            _write_primary_cli_canonical_json(io, item)
        end
        print(io, ']')
    else
        throw(ArgumentError(
            "canonical JSON does not support values of type $(typeof(value))",
        ))
    end
    return nothing
end

function _print_primary_cli_usage_error(err, message)
    println(err, "linkedspec: ", message)
    println(err)
    print(err, _primary_cli_usage())
end

function _print_primary_cli_runtime_error(err::IO, message::String, error)
    println(err, "linkedspec: ", message)
    diagnostic = error isa RuntimeInterpreterException ? error.diagnostic : nothing
    if diagnostic !== nothing
        fields = (
            "owner_stage" => diagnostic.owner_stage,
            "summary" => diagnostic.summary,
            "detail" => diagnostic.detail,
            "spec_name" => diagnostic.spec_name,
            "spec_path" => diagnostic.spec_path,
            "top_rule" => diagnostic.top_rule,
            "rule_label" => diagnostic.rule_label,
        )
        for (name, value) in fields
            if value !== nothing
                println(err, "  ", name, ": ", value)
            end
        end
    end
    raw_error = sprint(showerror, error)
    if !isempty(raw_error)
        println(err, "  error: ", raw_error)
    end
    return nothing
end

function _load_primary_cli_request_input(request::_PrimaryCliRequest)
    if request.input !== nothing
        return request.input
    end
    if request.input_path === nothing
        throw(ArgumentError("primary CLI request has neither loaded input nor an input path"))
    end
    return _read_primary_cli_file(request.input_path, "input file")
end

_primary_cli_fatal_error(error) =
    error isa InterruptException || error isa OutOfMemoryError || error isa StackOverflowError

function run_cli(args = ARGS; io = stdout, err = stderr)
    options = try
        _parse_primary_cli_args(args)
    catch error
        if error isa _PrimaryCliUsageException
            _print_primary_cli_usage_error(err, error.message)
            return 2
        end
        rethrow()
    end

    if options.help
        print(io, _primary_cli_usage())
        return 0
    end

    request = try
        _prepare_primary_cli_request(options; load_input_file = false)
    catch error
        if _primary_cli_fatal_error(error)
            rethrow()
        end
        _print_primary_cli_runtime_error(err, "parser compilation failed", error)
        return 1
    end

    trace = nothing
    engine = try
        trace = _primary_cli_trace_emitter(options; stdout_io = io)
        _compile_primary_cli_request(request; trace = trace)
    catch error
        if _primary_cli_fatal_error(error)
            rethrow()
        end
        _print_primary_cli_runtime_error(err, "parser compilation failed", error)
        return 1
    end

    input = try
        _load_primary_cli_request_input(request)
    catch error
        if _primary_cli_fatal_error(error)
            rethrow()
        end
        _print_primary_cli_runtime_error(err, "input load failed", error)
        return 1
    end

    output = try
        result = _invoke_primary_cli_request(engine, request, input; trace = trace)
        _primary_cli_canonical_json(result.value)
    catch error
        if _primary_cli_fatal_error(error)
            rethrow()
        end
        _print_primary_cli_runtime_error(err, "parser invocation failed", error)
        return 1
    end

    println(io, output)
    return 0
end
