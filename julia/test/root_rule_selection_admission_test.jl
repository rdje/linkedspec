const JULIA_ROOT_ADMISSION_CONTRACT = JSON3.read(
    read(
        joinpath(REPO_ROOT, "capability_conformance", "root_rule_selection_contract.json"),
        String,
    ),
    Dict{String,Any},
)

const JULIA_ROOT_ADMISSION_IDENTITY = "root-selection/julia-admission.spec"

# Entry lifecycle returns make the selected rule observable before matching can
# make exit lifecycle appear equivalent.
const JULIA_ROOT_ADMISSION_MARKED_SOURCE = raw"""
Earlier:
 /x/
 I { return("earlier") }

Marked::
 /x/
 I { return("marked") }

Later::
 /x/
 I { return("later") }
"""

const JULIA_ROOT_ADMISSION_MARKERLESS_SOURCE = raw"""
First:
 /x/
 I { return("first") }

Second:
 /x/
 I { return("second") }
"""

# This source is shared byte-for-byte with the primary CLI trace manifest.
const JULIA_ROOT_ADMISSION_TRACE_SOURCE = raw"""Top::
 /x/ -> Done { return("trace") }

Done::
 /x/
"""

function _julia_root_admission_compile(source)
    spec = parse_spec(source)
    validate_spec(spec)
    return compile_spec(spec; validate_source = false)
end

function _julia_root_admission_compiled_for_rows(rows)
    if isempty(rows)
        return compile_spec(SpecFile(rules = Rule[]); validate_source = false)
    end
    source = join(
        [
            begin
                label = String(row["label"])
                separator = row["authored_is_top"] ? "::" : ":"
                "$label$separator\n /x/\n I { return(\"$label\") }\n"
            end for row in rows
        ],
        "\n",
    )
    return _julia_root_admission_compile(source)
end

function _julia_root_admission_error(call)
    try
        call()
    catch error
        return error
    end
    return nothing
end

_julia_root_admission_latest_binding(owner::Module, name::Symbol) =
    Base.invokelatest(() -> Core.getglobal(owner, name))

function _julia_root_admission_with_emitted_parser(body, source, label)
    compiled = _julia_root_admission_compile(source)
    mktempdir() do scratch
        generated_path = joinpath(scratch, "generated_parser.jl")
        write(generated_path, emit_julia_source_v2(compiled, JULIA_ROOT_ADMISSION_IDENTITY))
        host = Module(gensym(:JuliaRootAdmissionHost))
        Base.include(host, generated_path)
        parser = Base.invokelatest(() -> getfield(host, :LinkedSpecGeneratedParser))
        return body(parser, label)
    end
end

function role_neutral_selection(contract)
    @test contract["contract_id"] == ENTRY_RULE_CONTRACT_ID
    for case_value in contract["selection_cases"]
        case_id = String(case_value["id"])
        compiled = _julia_root_admission_compiled_for_rows(case_value["rules"])
        authored_before = [
            (label, compiled_rule(compiled, label).header.is_top)
            for label in compiled.compiled_rule_order
        ]
        selection = resolve_entry_rule(compiled, case_value["explicit_selector"])
        @test selection.rule.label == case_value["expected_label"]
        @test entry_rule_selection_basis_name(selection.basis) ==
            case_value["expected_basis"]
        @test [
            (label, compiled_rule(compiled, label).header.is_top)
            for label in compiled.compiled_rule_order
        ] == authored_before
        @test !isempty(case_id)
    end
end

function role_neutral_failures(contract)
    for case_value in contract["failure_cases"]
        compiled = _julia_root_admission_compiled_for_rows(case_value["rules"])
        error = _julia_root_admission_error() do
            resolve_entry_rule(compiled, case_value["explicit_selector"])
        end
        @test error isa EntryRuleSelectionException
        if error isa EntryRuleSelectionException
            @test error.code == case_value["expected_code"]
            @test error.stage == case_value["expected_stage"]
        end
    end
end

function role_neutral_strict(contract)
    sources = Dict(
        "explicit_selection_is_not_reference" => "A:\n /a/\n\nB:\n /b/\n",
        "marker_selection_is_not_reference" =>
            "Top::\n /x/ -> Child\n\nChild:\n /x/ -> Child\n",
        "closed_reference_cycle_has_no_unused_rules" =>
            "A:\n /a/ -> B\n\nB:\n /b/ -> A\n",
    )
    for case_value in contract["strict_cases"]
        case_id = String(case_value["id"])
        spec = parse_spec(sources[case_id])
        expected_unused = String[String(label) for label in case_value["expected_unused"]]
        if case_value["explicit_selector"] !== nothing
            resolve_entry_rule(compile_spec(spec), case_value["explicit_selector"])
        end
        if isempty(expected_unused)
            @test validate_spec(spec; strict_syntax = true) === nothing
        else
            error = _julia_root_admission_error() do
                validate_spec(spec; strict_syntax = true)
            end
            @test error isa SpecValidationException
            if error isa SpecValidationException
                @test error.message ==
                    "unused rule(s) in strict mode: $(join(expected_unused, ", "))"
            end
        end
    end
end

function role_native(_contract)
    marked = LinkedSpecRuntimeEngine(
        _julia_root_admission_compile(JULIA_ROOT_ADMISSION_MARKED_SOURCE),
    )
    @test runtime_parse(marked, "x").value == "marked"
    @test runtime_parse(marked, "x"; top_rule = "Earlier").value == "earlier"
    @test runtime_parse(marked, "x"; top_rule = "Later").value == "later"

    markerless = LinkedSpecRuntimeEngine(
        _julia_root_admission_compile(JULIA_ROOT_ADMISSION_MARKERLESS_SOURCE),
    )
    @test runtime_parse(markerless, "x").value == "first"
    @test runtime_parse(markerless, "x"; top_rule = "Second").value == "second"
end

function role_loaded(_contract)
    mktempdir() do scratch
        path = joinpath(scratch, "markerless.spec")
        write(path, JULIA_ROOT_ADMISSION_MARKERLESS_SOURCE)
        loaded = load_and_compile_spec(path_spec_request(path), SpecLoadOptions(scratch))
        engine = create_engine(loaded)
        @test runtime_parse(engine, "x").value == "first"
        @test runtime_parse(engine, "x"; top_rule = "Second").value == "second"
    end
end

function role_reconstructed(_contract)
    normalized_json = JSON3.read(
        JSON3.write(to_json(parse_spec(JULIA_ROOT_ADMISSION_MARKED_SOURCE))),
    )
    compiled = compile_spec(from_json(SpecFile, normalized_json))
    @test [
        (label, compiled_rule(compiled, label).header.is_top)
        for label in compiled.compiled_rule_order
    ] == [("Earlier", false), ("Marked", true), ("Later", true)]
    engine = LinkedSpecRuntimeEngine(compiled)
    @test runtime_parse(engine, "x").value == "marked"
    @test runtime_parse(engine, "x"; top_rule = "Earlier").value == "earlier"
end

function role_generated_direct(_contract)
    marked = _julia_root_admission_compile(JULIA_ROOT_ADMISSION_MARKED_SOURCE)
    @test execute_generated_parser_v2(
        marked,
        build_generated_rule_plan(marked),
        "x",
        JULIA_ROOT_ADMISSION_IDENTITY;
        top_rule = "Earlier",
    ) == "earlier"

    markerless = _julia_root_admission_compile(JULIA_ROOT_ADMISSION_MARKERLESS_SOURCE)
    @test execute_generated_parser_v2(
        markerless,
        build_generated_rule_plan(markerless),
        "x",
        JULIA_ROOT_ADMISSION_IDENTITY,
    ) == "first"
end

function role_generated_traced(_contract)
    mktempdir() do scratch
        compiled = _julia_root_admission_compile(JULIA_ROOT_ADMISSION_MARKED_SOURCE)
        trace_path = joinpath(scratch, "generated.trace")
        @test execute_generated_parser_with_trace_v2(
            compiled,
            build_generated_rule_plan(compiled),
            "x",
            LinkedSpecTraceConfig(
                level = LinkedSpecTraceDebug,
                trace_file = trace_path,
                sink_mode = LinkedSpecTraceRoute,
                reset_file = true,
            ),
            JULIA_ROOT_ADMISSION_IDENTITY;
            top_rule = "Later",
        ) == "later"
        trace = read(trace_path, String)
        @test occursin("julia_runtime:entry_rule_selection", trace)
        @test occursin("requested=Later", trace)
        @test occursin("effective=Later", trace)
        @test occursin("basis=explicit_selector", trace)
        @test occursin("rule=Later", trace)
    end
end

function role_emitted_source_direct(_contract)
    _julia_root_admission_with_emitted_parser(
        JULIA_ROOT_ADMISSION_MARKED_SOURCE,
        "Earlier",
    ) do parser, label
        execute = _julia_root_admission_latest_binding(parser, :execute)
        @test Base.invokelatest(execute, "x") == "marked"
        @test Base.invokelatest(execute, "x"; top_rule = label) == "earlier"
    end
end

function role_emitted_source_traced(_contract)
    _julia_root_admission_with_emitted_parser(
        JULIA_ROOT_ADMISSION_MARKERLESS_SOURCE,
        "Second",
    ) do parser, label
        output = IOBuffer()
        result = Base.invokelatest(
            _julia_root_admission_latest_binding(parser, :execute_with_trace),
            "x",
            trace_config_enabled("low");
            top_rule = label,
            stdout_io = output,
        )
        @test result == "second"
        trace = String(take!(output))
        @test occursin("julia_runtime:entry_rule_selection", trace)
        @test occursin("requested=Second", trace)
        @test occursin("effective=Second", trace)
        @test occursin("basis=explicit_selector", trace)
    end
end

function role_descriptor(_contract)
    compiled = _julia_root_admission_compile(JULIA_ROOT_ADMISSION_MARKED_SOURCE)
    before = to_descriptor_json(compiled)
    @test runtime_parse(
        LinkedSpecRuntimeEngine(compiled),
        "x";
        top_rule = "Earlier",
    ).value == "earlier"
    after = to_descriptor_json(compiled)
    @test after == before
    @test after["meta"]["entry_rule_contract"] == ENTRY_RULE_CONTRACT_ID
    @test after["meta"]["definition_order"] == ["Earlier", "Marked", "Later"]
    @test !haskey(after["meta"], "entry_rule")
    @test !haskey(after["meta"], "selected_entry_rule")
    @test after["spec"]["Earlier"]["meta"]["is_top"] === false
    @test after["spec"]["Marked"]["meta"]["is_top"] === true
    @test after["spec"]["Later"]["meta"]["is_top"] === true
end

function role_diagnostic(_contract)
    engine = LinkedSpecRuntimeEngine(
        _julia_root_admission_compile(JULIA_ROOT_ADMISSION_MARKED_SOURCE),
    )
    unknown = _julia_root_admission_error() do
        runtime_parse(engine, "x"; top_rule = "Missing")
    end
    @test unknown isa RuntimeInterpreterException
    if unknown isa RuntimeInterpreterException
        @test unknown.diagnostic.code == "entry_rule_not_found"
        @test unknown.diagnostic.stage == "select_entry_rule"
        @test unknown.diagnostic.entry_rule == "Missing"
    end

    empty = LinkedSpecRuntimeEngine(
        compile_spec(SpecFile(rules = Rule[]); validate_source = false),
    )
    zero = _julia_root_admission_error() do
        runtime_parse(empty, ""; top_rule = "Missing")
    end
    @test zero isa RuntimeInterpreterException
    if zero isa RuntimeInterpreterException
        @test zero.diagnostic.code == "no_rules_defined"
        @test zero.diagnostic.stage == "validate_spec"
    end

    compiled = _julia_root_admission_compile(JULIA_ROOT_ADMISSION_MARKED_SOURCE)
    stale = _julia_root_admission_error() do
        execute_generated_parser_v2(
            compiled,
            build_generated_rule_plan(compiled),
            "x",
            JULIA_ROOT_ADMISSION_IDENTITY;
            top_rule = "Missing",
            actual_contract = "linkedspec-generated-source-v1",
        )
    end
    @test stale isa GeneratedSourceException
    if stale isa GeneratedSourceException
        @test stale.stage == ValidateGeneratedPlanStage
        @test stale.code == GeneratedSourceContractVersionMismatchCode
    end
end

function role_runtime_trace(_contract)
    failure_source = raw"""
Earlier:
 /x/
 I { return(not(true, false)) }

Marked::
 /x/
 I { return("marked") }
"""
    mktempdir() do scratch
        compiled = _julia_root_admission_compile(failure_source)
        trace_path = joinpath(scratch, "failure.trace")
        failure = _julia_root_admission_error() do
            execute_generated_parser_with_trace_v2(
                compiled,
                build_generated_rule_plan(compiled),
                "x",
                LinkedSpecTraceConfig(
                    level = LinkedSpecTraceDebug,
                    trace_file = trace_path,
                    sink_mode = LinkedSpecTraceRoute,
                    reset_file = true,
                ),
                JULIA_ROOT_ADMISSION_IDENTITY;
                top_rule = "Earlier",
            )
        end
        @test failure isa GeneratedSourceException
        if failure isa GeneratedSourceException
            @test failure.stage == ExecuteGeneratedStage
            @test failure.code == GeneratedExecutionFailedCode
            @test failure.rule_label == "Earlier"
            @test failure.handler_family == "default"
        end
        trace = read(trace_path, String)
        @test occursin("requested=Earlier", trace)
        @test occursin("effective=Earlier", trace)
        @test occursin("basis=explicit_selector", trace)
        @test occursin("rule=Earlier", trace)
    end
end

function role_primary_cli(_contract)
    routes = (
        (JULIA_ROOT_ADMISSION_MARKED_SOURCE, String[], "\"marked\"\n"),
        (JULIA_ROOT_ADMISSION_MARKERLESS_SOURCE, String[], "\"first\"\n"),
        (
            JULIA_ROOT_ADMISSION_MARKED_SOURCE,
            ["--top-rule", "Earlier"],
            "\"earlier\"\n",
        ),
    )
    for (source, extra, expected) in routes
        output = IOBuffer()
        error_output = IOBuffer()
        @test run_cli(
            ["--inline-spec", source, "--input", "x", extra...];
            io = output,
            err = error_output,
        ) == 0
        @test String(take!(output)) == expected
        @test isempty(String(take!(error_output)))
    end

    output = IOBuffer()
    error_output = IOBuffer()
    @test run_cli(
        [
            "--inline-spec",
            JULIA_ROOT_ADMISSION_MARKED_SOURCE,
            "--input",
            "x",
            "--top-rule",
            "Missing",
        ];
        io = output,
        err = error_output,
    ) == 1
    @test isempty(String(take!(output)))
    @test String(take!(error_output)) == "linkedspec: parser invocation failed\n"
end

function role_primary_request_trace(_contract)
    expected_default = read(
        joinpath(REPO_ROOT, "cli_conformance", "cases", "trace", "medium_stdout.txt"),
    )
    output = IOBuffer()
    error_output = IOBuffer()
    @test run_cli(
        [
            "--inline-spec",
            JULIA_ROOT_ADMISSION_TRACE_SOURCE,
            "--input",
            "x",
            "--trace",
            "medium",
        ];
        io = output,
        err = error_output,
    ) == 0
    @test take!(output) == expected_default
    @test isempty(take!(error_output))

    mktempdir() do scratch
        trace_path = joinpath(scratch, "trace.log")
        write(trace_path, "stale trace\n")
        output = IOBuffer()
        error_output = IOBuffer()
        status = cd(scratch) do
            run_cli(
                [
                    "--inline-spec",
                    JULIA_ROOT_ADMISSION_TRACE_SOURCE,
                    "--input",
                    "x",
                    "--top-rule",
                    "Top\nInjected",
                    "--trace",
                    "medium",
                    "--trace-file",
                    "trace.log",
                    "--trace-mode",
                    "route",
                    "--trace-reset",
                ];
                io = output,
                err = error_output,
            )
        end
        @test status == 1
        @test isempty(take!(output))
        @test String(take!(error_output)) == "linkedspec: parser invocation failed\n"
        @test read(trace_path) == read(
            joinpath(
                REPO_ROOT,
                "cli_conformance",
                "cases",
                "trace",
                "failure_invoke_escaped_medium.txt",
            ),
        )
    end
end

@testset "Contract-declared Julia root-selection roles execute once" begin
    role_map = Dict{String,Function}(
        "neutral_selection" => role_neutral_selection,
        "neutral_failures" => role_neutral_failures,
        "neutral_strict" => role_neutral_strict,
        "native" => role_native,
        "loaded" => role_loaded,
        "reconstructed" => role_reconstructed,
        "generated_direct" => role_generated_direct,
        "generated_traced" => role_generated_traced,
        "emitted_source_direct" => role_emitted_source_direct,
        "emitted_source_traced" => role_emitted_source_traced,
        "descriptor" => role_descriptor,
        "diagnostic" => role_diagnostic,
        "runtime_trace" => role_runtime_trace,
        "primary_cli" => role_primary_cli,
        "primary_request_trace" => role_primary_request_trace,
    )
    admission = JULIA_ROOT_ADMISSION_CONTRACT["julia_admission"]
    declared_roles = String[String(role) for role in admission["roles"]]
    @test length(unique(declared_roles)) == length(declared_roles)
    @test Set(keys(role_map)) == Set(declared_roles)

    completed = Set{String}()
    for role in declared_roles
        @test !(role in completed)
        push!(completed, role)
        role_map[role](JULIA_ROOT_ADMISSION_CONTRACT)
    end
    @test completed == Set(keys(role_map))
end
