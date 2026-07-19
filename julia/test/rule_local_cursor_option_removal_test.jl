function _removed_cursor_option_failure(callback)
    try
        callback()
    catch error
        return error
    end
    return nothing
end

function _assert_removed_cursor_option_failure(error)
    @test error isa RuntimeInterpreterException
    error isa RuntimeInterpreterException || return
    @test error.diagnostic isa RuntimeDiagnostic
    error.diagnostic isa RuntimeDiagnostic || return
    projection = to_json(error.diagnostic)
    @test projection["stage"] == "prepare_options"
    @test projection["code"] == "parse_mode_override_removed"
    @test projection["option_name"] == "parse_mode"
    @test projection["detail"] ==
        "cursor policy is derived from each rule (OR/default=seek, AND=consume)"
end

@testset "Rule-local cursor public option removal" begin
    interpreter_source = read(
        joinpath(REPO_ROOT, "julia", "src", "runtime", "Interpreter.jl"),
        String,
    )
    loader_source = read(joinpath(REPO_ROOT, "julia", "src", "io", "SpecLoader.jl"), String)
    corpus_source = read(
        joinpath(REPO_ROOT, "julia", "src", "corpus", "CorpusManifest.jl"),
        String,
    )
    cli_source = read(
        joinpath(REPO_ROOT, "julia", "src", "cli", "LinkedSpecJuliaCli.jl"),
        String,
    )
    matching_source = read(
        joinpath(REPO_ROOT, "julia", "src", "runtime", "Matching.jl"),
        String,
    )

    @test !occursin("parse_mode::Union{Nothing,LinkedSpecParseMode}", interpreter_source)
    @test !occursin("engine.parse_mode", interpreter_source)
    @test occursin("parse_mode_override_removed", interpreter_source)
    @test !occursin(r"parse_mode|parseMode|parse-mode", loader_source)
    @test !occursin(r"parse_mode|parseMode|parse-mode", corpus_source)
    @test !occursin("parse_mode::Union", cli_source)
    @test !occursin("options.parse_mode", cli_source)
    @test !occursin("--parse-mode MODE", cli_source)
    @test occursin("option == \"--parse-mode\"", cli_source)
    @test occursin("function runtime_match(", matching_source)
    @test occursin("parse_mode = SeekParseMode", matching_source)
    @test occursin("function seek_match(", matching_source)
    @test occursin("function consume_match(", matching_source)

    source = raw"""
Top::AND
 /x/ -> Top { return("hit") }
"""
    compiled = compile_spec(parse_spec(source))
    @test runtime_parse(LinkedSpecRuntimeEngine(compiled), "prefix x").value === nothing

    engine_snake = _removed_cursor_option_failure() do
        LinkedSpecRuntimeEngine(
            compiled;
            parse_mode = "seek",
            spec_name = "option-removal.spec",
        )
    end
    _assert_removed_cursor_option_failure(engine_snake)
    @test engine_snake.diagnostic.spec_name == "option-removal.spec"

    engine_camel = _removed_cursor_option_failure() do
        LinkedSpecRuntimeEngine(compiled; parseMode = "consume")
    end
    _assert_removed_cursor_option_failure(engine_camel)

    mktempdir() do root
        spec_path = joinpath(root, "option-removal.spec")
        write(spec_path, source)
        loaded = load_and_compile_spec(
            path_spec_request("option-removal.spec"),
            SpecLoadOptions(root),
        )
        loaded_failure = _removed_cursor_option_failure() do
            create_engine(loaded; parse_mode = SeekParseMode)
        end
        _assert_removed_cursor_option_failure(loaded_failure)
        @test loaded_failure.diagnostic.spec_path == spec_path

        corpus_failure = _removed_cursor_option_failure() do
            execute_corpus_fixtures(
                joinpath(root, "missing-corpus");
                parse_mode = "seek",
            )
        end
        _assert_removed_cursor_option_failure(corpus_failure)
    end

    removed_message =
        "--parse-mode has been removed; " *
        "cursor policy is derived from each rule (OR/default=seek, AND=consume)"
    output = IOBuffer()
    error_output = IOBuffer()
    @test run_cli(
        [
            "--inline-spec",
            "not a spec",
            "--input-file",
            "missing-input.txt",
            "--parse-mode",
            "consume",
        ];
        io = output,
        err = error_output,
    ) == 2
    @test isempty(String(take!(output)))
    @test first(split(String(take!(error_output)), '\n')) == "linkedspec: $removed_message"

    help_output = IOBuffer()
    help_error = IOBuffer()
    @test run_cli(["--help"]; io = help_output, err = help_error) == 0
    @test !occursin("--parse-mode", String(take!(help_output)))
    @test isempty(String(take!(help_error)))

    top_source = raw"""
Top::
 /x/
 I { return("top") }

Alternate:
 /x/
 I { return("alternate") }
"""
    top_output = IOBuffer()
    top_error = IOBuffer()
    @test run_cli(
        ["--inline-spec", top_source, "--input", "x", "--top-rule", "Alternate"];
        io = top_output,
        err = top_error,
    ) == 0
    @test String(take!(top_output)) == "\"alternate\"\n"
    @test isempty(String(take!(top_error)))

    trace_output = IOBuffer()
    trace_error = IOBuffer()
    @test run_cli(
        ["--inline-spec", top_source, "--input", "x", "--trace", "medium"];
        io = trace_output,
        err = trace_error,
    ) == 0
    trace_text = String(take!(trace_output))
    @test occursin(
        "request source=inline input=literal top_rule=<default>",
        trace_text,
    )
    @test !occursin("parse_mode", trace_text)
    @test isempty(String(take!(trace_error)))
end
