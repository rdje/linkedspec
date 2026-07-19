const JULIA_CURSOR_ADMISSION_CONTRACT = JSON3.read(
    read(
        joinpath(REPO_ROOT, "capability_conformance", "rule_local_cursor_contract.json"),
        String,
    ),
    Dict{String,Any},
)

const JULIA_CURSOR_ADMISSION_DEFAULT_SOURCE = raw"""
Top::
 /x/
 -> Top { return("hit") }
"""

const JULIA_CURSOR_ADMISSION_AND_SOURCE = raw"""
Top::AND
 /x/
 -> Top { return("hit") }
"""

const JULIA_CURSOR_ADMISSION_MIXED_SOURCE = raw"""
Top::AND
 => Child
Child:
 /x/
 -> Child { return("hit") }
"""

const JULIA_CURSOR_ADMISSION_RECURSION_SOURCE = raw"""
Top::AND
 /p/
 -> Top { return(call(Child)) }
Child:OR
 /x/ -> Child[0] { return(call(Top)) }
 /z/ -> Child[1] { return("done") }
"""

const JULIA_CURSOR_ADMISSION_ORDERED_SOURCE = raw"""
Top::AND
 => Header
 => Body
Header:
 /h/
 -> Header { return("header") }
Body:
 /b/
 -> Body { return("body") }
"""

const JULIA_CURSOR_ADMISSION_ANCHORED_SOURCE = raw"""
Top::|
 => X
 => Y
X:AND
 /x/
 -> X { return("x") }
Y:AND
 /y/
 -> Y { return("y") }
"""

const JULIA_CURSOR_ADMISSION_GENERATED_IDENTITY =
    "rule-local-cursor/julia-admission.spec"

mutable struct _JuliaCursorAdmissionState
    observed_diagnostics::Set{String}
end

_JuliaCursorAdmissionState() = _JuliaCursorAdmissionState(Set{String}())

function role_native_default_family(contract, _state)
    @test contract["policy"]["or_default_cursor"] == "seek"
    compiled = _julia_cursor_admission_compile(JULIA_CURSOR_ADMISSION_DEFAULT_SOURCE)
    @test runtime_parse(LinkedSpecRuntimeEngine(compiled), "prefix x").value == "hit"
    @test cursor_policy(compiled_rule(compiled, "Top").mode_metadata) == "seek"
end

function role_native_and_family(contract, _state)
    @test contract["policy"]["and_cursor"] == "consume"
    compiled = _julia_cursor_admission_compile(JULIA_CURSOR_ADMISSION_AND_SOURCE)
    @test runtime_parse(LinkedSpecRuntimeEngine(compiled), "prefix x").value === nothing
    @test runtime_parse(LinkedSpecRuntimeEngine(compiled), "x").value == "hit"
    @test cursor_policy(compiled_rule(compiled, "Top").mode_metadata) == "consume"
end

function role_ordinary_normalized(contract, _state)
    parsed = parse_spec(JULIA_CURSOR_ADMISSION_MIXED_SOURCE)
    encoded = JSON3.write(to_json(parsed))
    for option in contract["option_retirement"]["dynamic_option_names"]
        @test !occursin(String(option), encoded)
    end
    normalized = from_json(SpecFile, JSON3.read(encoded))
    @test runtime_parse(
        LinkedSpecRuntimeEngine(compile_spec(normalized)),
        "prefix x",
    ).value == Any["hit"]
end

function role_loaded_spec(_contract, _state)
    mktempdir() do scratch
        path = joinpath(scratch, "loaded.spec")
        write(path, JULIA_CURSOR_ADMISSION_MIXED_SOURCE)
        loaded = load_and_compile_spec(path_spec_request(path), SpecLoadOptions(scratch))
        @test runtime_parse(create_engine(loaded), "prefix x").value == Any["hit"]
    end
end

function role_descriptor_v1(contract, _state)
    source = JULIA_CURSOR_ADMISSION_DEFAULT_SOURCE * "\n" * replace(
        JULIA_CURSOR_ADMISSION_AND_SOURCE,
        "Top::AND" => "Consume:AND",
        "-> Top" => "-> Consume",
    )
    descriptor = to_descriptor_json(_julia_cursor_admission_compile(source))
    descriptor_contract = contract["descriptor_contract"]
    @test descriptor["meta"]["cursor_contract"] ==
          descriptor_contract["meta"]["cursor_contract"]
    @test descriptor["spec"]["Top"]["meta"]["cursor_policy"] == "seek"
    @test descriptor["spec"]["Consume"]["meta"]["cursor_policy"] == "consume"
    @test !occursin("\"parse_mode\"", JSON3.write(descriptor))
end

function role_emitted_source_v2(contract, _state)
    compiled = _julia_cursor_admission_compile(JULIA_CURSOR_ADMISSION_MIXED_SOURCE)
    generated_contract = contract["generated_source_v2"]
    emitted = emit_julia_source_v2(compiled, JULIA_CURSOR_ADMISSION_GENERATED_IDENTITY)
    @test occursin(String(generated_contract["contract_id"]), emitted)
    @test occursin(
        "const LINKEDSPEC_GENERATED_SOURCE_FORMAT = $(generated_contract["format_version"])",
        emitted,
    )
    @test occursin(bytes2hex(codeunits(JULIA_CURSOR_ADMISSION_GENERATED_IDENTITY)), emitted)
    @test occursin("function execute(", emitted)
    @test occursin("function execute_with_trace(", emitted)
    @test !occursin("\"cursor_policy\"", emitted)
    for option in contract["option_retirement"]["dynamic_option_names"]
        @test !occursin(String(option), emitted)
    end
end

function role_generated_direct(contract, state)
    compiled = _julia_cursor_admission_compile(JULIA_CURSOR_ADMISSION_DEFAULT_SOURCE)
    plan = build_generated_rule_plan(compiled)
    @test [to_json(row) for row in plan] == Any[
        Dict("label" => "Top", "family" => "default"),
    ]
    @test execute_generated_parser_v2(
        compiled,
        plan,
        "prefix x",
        JULIA_CURSOR_ADMISSION_GENERATED_IDENTITY,
    ) == "hit"

    failure = try
        execute_generated_parser_v2(
            compiled,
            plan,
            "x",
            JULIA_CURSOR_ADMISSION_GENERATED_IDENTITY;
            actual_contract = "linkedspec-generated-source-v1",
        )
        nothing
    catch error
        error
    end
    @test failure isa GeneratedSourceException
    if failure isa GeneratedSourceException
        projection = to_json(failure)
        expected_code = String(contract["generated_source_v2"]["v1_reconstruction_error"])
        @test projection["code"] == expected_code
        push!(state.observed_diagnostics, expected_code)
    end
end

function role_generated_trace(_contract, _state)
    compiled = _julia_cursor_admission_compile(JULIA_CURSOR_ADMISSION_DEFAULT_SOURCE)
    output = IOBuffer()
    @test execute_generated_parser_with_trace_v2(
        compiled,
        build_generated_rule_plan(compiled),
        "prefix x",
        trace_config_enabled(LinkedSpecTraceDebug),
        JULIA_CURSOR_ADMISSION_GENERATED_IDENTITY;
        stdout_io = output,
    ) == "hit"
    trace = String(take!(output))
    @test occursin("generated_rule_enter", trace)
    @test occursin("generated_family_decision", trace)
    @test occursin(JULIA_CURSOR_ADMISSION_GENERATED_IDENTITY, trace)
end

function role_mixed_parent_child(_contract, _state)
    compiled = _julia_cursor_admission_compile(JULIA_CURSOR_ADMISSION_MIXED_SOURCE)
    @test runtime_parse(LinkedSpecRuntimeEngine(compiled), "prefix x").value == Any["hit"]
end

function role_recursion(_contract, _state)
    compiled = _julia_cursor_admission_compile(JULIA_CURSOR_ADMISSION_RECURSION_SOURCE)
    @test runtime_parse(LinkedSpecRuntimeEngine(compiled), "p junk xp junk z").value == "done"
end

function role_structural_ordered_landmarks(_contract, _state)
    compiled = _julia_cursor_admission_compile(JULIA_CURSOR_ADMISSION_ORDERED_SOURCE)
    @test runtime_parse(LinkedSpecRuntimeEngine(compiled), "junk h junk b").value ==
          Any["header", "body"]
end

function role_structural_anchored_choice(_contract, _state)
    compiled = _julia_cursor_admission_compile(JULIA_CURSOR_ADMISSION_ANCHORED_SOURCE)
    @test runtime_parse(LinkedSpecRuntimeEngine(compiled), "prefix x").value === nothing
end

function role_static_option_removal(contract, state)
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
    for option in contract["option_retirement"]["dynamic_option_names"]
        @test !occursin(String(option), loader_source)
        @test !occursin(String(option), corpus_source)
    end
    @test !occursin("options.parse_mode", cli_source)
    @test !occursin("--parse-mode MODE", cli_source)
    @test occursin("option == \"--parse-mode\"", cli_source)
    @test occursin("function runtime_match(", matching_source)
    @test occursin("function seek_match(", matching_source)
    @test occursin("function consume_match(", matching_source)

    compiled = _julia_cursor_admission_compile(JULIA_CURSOR_ADMISSION_AND_SOURCE)
    failures = Any[
        try
            LinkedSpecRuntimeEngine(compiled; parse_mode = "seek")
            nothing
        catch error
            error
        end,
        try
            LinkedSpecRuntimeEngine(compiled; parseMode = "consume")
            nothing
        catch error
            error
        end,
    ]
    expected = contract["option_retirement"]["error"]
    for failure in failures
        @test failure isa RuntimeInterpreterException
        if failure isa RuntimeInterpreterException
            projection = to_json(failure.diagnostic)
            @test projection["stage"] == expected["stage"]
            @test projection["code"] == expected["code"]
            @test projection["option_name"] == expected["fields"]["option_name"]
        end
    end
    push!(state.observed_diagnostics, String(expected["code"]))
end

function role_primary_command(contract, state)
    output = IOBuffer()
    error_output = IOBuffer()
    @test run_cli(
        [
            "--inline-spec",
            JULIA_CURSOR_ADMISSION_DEFAULT_SOURCE,
            "--input",
            "prefix x",
        ];
        io = output,
        err = error_output,
    ) == 0
    @test String(take!(output)) == "\"hit\"\n"
    @test isempty(String(take!(error_output)))

    cli = contract["option_retirement"]["cli"]
    @test run_cli(
        [
            "--inline-spec",
            JULIA_CURSOR_ADMISSION_DEFAULT_SOURCE,
            "--input",
            "x",
            String(cli["flag"]),
            "seek",
        ];
        io = output,
        err = error_output,
    ) == cli["exit"]
    @test isempty(String(take!(output)))
    removed_error = String(take!(error_output))
    @test first(split(removed_error, '\n')) == "linkedspec: $(cli["stderr"])"

    @test run_cli(["--help"]; io = output, err = error_output) == 0
    @test !occursin(String(cli["flag"]), String(take!(output)))
    @test isempty(String(take!(error_output)))
    prepare_code = only(
        row for row in contract["diagnostics"] if row["stage"] == "prepare_options"
    )["code"]
    push!(state.observed_diagnostics, String(prepare_code))
end

function role_portable_diagnostics(contract, state)
    diagnostics = Dict(String(row["code"]) => row for row in contract["diagnostics"])
    invalid_rows = Any[
        [
            row for row in contract["edge_resolution_cases"]
            if haskey(row, "expected_error")
        ]...,
        [
            row for row in contract["rule_edge_set_cases"]
            if haskey(row, "expected_error")
        ]...,
    ]
    for row in invalid_rows
        expected_code = String(row["expected_error"])
        sources = haskey(row, "sources") ?
            String[String(source) for source in row["sources"]] :
            [String(row["source"])]
        diagnostic = _julia_cursor_admission_diagnostic(
            _julia_cursor_admission_edge_source(
                String(row["parent_family"]),
                sources,
                String[String(label) for label in row["declared_rules"]],
            ),
        )
        projection = to_json(diagnostic)
        expected = diagnostics[expected_code]
        @test diagnostic.code == expected_code
        @test diagnostic.stage == expected["stage"]
        @test Set(keys(projection["fields"])) ==
              Set(String(field) for field in expected["fields"])
        push!(state.observed_diagnostics, expected_code)
    end
    @test state.observed_diagnostics == Set(keys(diagnostics))
end

function _julia_cursor_admission_compile(source::AbstractString)
    return compile_spec(parse_spec(source))
end

function _julia_cursor_admission_normalized(source::AbstractString)
    parsed = parse_spec(source)
    return from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
end

function _julia_cursor_admission_diagnostic(source::AbstractString)
    try
        compile_spec(_julia_cursor_admission_normalized(source))
    catch error
        if error isa SpecValidationException && error.diagnostic isa SpecPortableDiagnostic
            return error.diagnostic
        end
        rethrow()
    end
    error("expected portable cursor admission diagnostic")
end

function _julia_cursor_admission_edge_source(
    parent_family::AbstractString,
    sources::Vector{String},
    declared_rules::Vector{String},
)
    output = IOBuffer()
    println(output, parent_family == "and" ? "Top::AND" : "Top::")
    for source in sources
        println(output, " ", source)
    end
    for label in declared_rules
        println(output)
        println(output, label, ":")
        println(output, " /x/ /y/")
    end
    return String(take!(output))
end

@testset "Contract-declared Julia cursor roles execute once and only once" begin
    role_map = Dict{String,Function}(
        "native_default_family" => role_native_default_family,
        "native_and_family" => role_native_and_family,
        "ordinary_normalized" => role_ordinary_normalized,
        "loaded_spec" => role_loaded_spec,
        "descriptor_v1" => role_descriptor_v1,
        "emitted_source_v2" => role_emitted_source_v2,
        "generated_direct" => role_generated_direct,
        "generated_trace" => role_generated_trace,
        "mixed_parent_child" => role_mixed_parent_child,
        "recursion" => role_recursion,
        "structural_ordered_landmarks" => role_structural_ordered_landmarks,
        "structural_anchored_choice" => role_structural_anchored_choice,
        "static_option_removal" => role_static_option_removal,
        "primary_command" => role_primary_command,
        "portable_diagnostics" => role_portable_diagnostics,
    )
    admission = JULIA_CURSOR_ADMISSION_CONTRACT["julia_backend_admission"]
    declared_roles = String[String(role) for role in admission["roles"]]
    @test Set(declared_roles) == Set(keys(role_map))
    @test length(declared_roles) == length(Set(declared_roles))

    completed = Set{String}()
    state = _JuliaCursorAdmissionState()
    for role in declared_roles
        @test role ∉ completed
        push!(completed, role)
        role_map[role](JULIA_CURSOR_ADMISSION_CONTRACT, state)
    end
    @test completed == Set(keys(role_map))
end
