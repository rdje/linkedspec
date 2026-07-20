module JuliaRepeatedActionResultAdmission

using JSON3
using LinkedSpecJulia
using Test

const REPO_ROOT = isdefined(Main, :REPO_ROOT) ?
    Main.REPO_ROOT : normpath(joinpath(@__DIR__, "..", ".."))
const JULIA_REPEATED_ACTION_RESULT_CONTRACT = JSON3.read(
    read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "repeated_action_result_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)
const JULIA_REPEATED_ACTION_RESULT_CONTRACT_ID =
    "linkedspec-explicit-repetition-action-result-v1"
const JULIA_REPEATED_ACTION_RESULT_GENERATED_IDENTITY =
    "repeated-action-result/julia-admission.spec"

function _julia_repeated_result_rows(contract)
    return Any[contract["mode_cases"]...; contract["special_cases"]...]
end

function _julia_repeated_result_case(contract, case_id::AbstractString)
    return only(row for row in _julia_repeated_result_rows(contract) if row["id"] == case_id)
end

function _julia_repeated_result_compile(row)
    return compile_spec(parse_spec(String(row["source"])))
end

function _julia_repeated_result_execute(row)
    return runtime_parse(
        LinkedSpecRuntimeEngine(_julia_repeated_result_compile(row)),
        String(row["input"]),
    )
end

function _julia_repeated_result_expect_native(row)
    result = _julia_repeated_result_execute(row)
    @test result.value == row["expected_result"]
    @test result.cursor_codeunit == row["expected_position"]
end

function _julia_repeated_result_capture_error(body)
    try
        body()
    catch error
        return error
    end
    return nothing
end

function _julia_repeated_result_selected_events(events)
    return [
        event for event in events
        if event.topic == "julia_runtime:regex_slot_selected"
    ]
end

function _julia_repeated_result_expect_selected_trace(events)
    selected = _julia_repeated_result_selected_events(events)
    @test length(selected) == 2
    if length(selected) >= 1
        @test occursin("target_rule=Top regex_index=0", selected[1].details)
    end
    if length(selected) >= 2
        @test occursin("target_rule=Top regex_index=1", selected[2].details)
    end
end

function _julia_repeated_result_host_process(scratch, runner, generated, private_depot)
    separator = Sys.iswindows() ? ';' : ':'
    parent_depot = get(ENV, "JULIA_DEPOT_PATH", "")
    isempty(parent_depot) && (parent_depot = join(Base.DEPOT_PATH, separator))
    depot_path = isempty(parent_depot) ?
        private_depot : string(private_depot, separator, parent_depot)
    load_path = join(
        [scratch, joinpath(REPO_ROOT, "julia"), "@stdlib"],
        separator,
    )
    command = `$(Base.julia_cmd()) --project=$scratch --startup-file=no --history-file=no --compiled-modules=no $runner $generated`
    environment = copy(ENV)
    environment["JULIA_DEPOT_PATH"] = depot_path
    environment["JULIA_LOAD_PATH"] = load_path
    environment["JULIA_PKG_OFFLINE"] = "true"
    output = IOBuffer()
    errors = IOBuffer()
    process = run(
        pipeline(
            ignorestatus(setenv(command, environment));
            stdout = output,
            stderr = errors,
        ),
    )
    return success(process), String(take!(output)), String(take!(errors))
end

function role_neutral_contract(contract)
    @test contract["contract_id"] == JULIA_REPEATED_ACTION_RESULT_CONTRACT_ID
    @test contract["scope"]["explicit_repetition_modes"] == [
        "Star",
        "Plus",
        "Optional",
        "Or",
        "OrPlus",
        "OrBounded",
    ]
    @test [row["id"] for row in contract["mode_cases"]] == [
        "compact_star_two_hits",
        "compact_plus_two_hits",
        "compact_optional_one_hit",
        "explicit_or_two_hits",
        "explicit_or_plus_two_hits",
        "bounded_exact_two_hits",
        "bounded_up_to_two_hits",
        "pipe_distinct_scalar",
    ]
    @test contract["semantics"]["lifecycle_return"] == "whole_rule_return"
    @test contract["generated_source_v2"]["format_version"] == 2
end

function role_ast_metadata(contract)
    for row in contract["mode_cases"]
        rule = compiled_rule(_julia_repeated_result_compile(row), "Top")
        @test rule.mode_metadata.is_repetition == row["is_repetition"]
        @test rule.mode_metadata.rep_min == row["rep_min"]
        @test rule.mode_metadata.rep_max == row["rep_max"]
        @test generated_rule_family_name(classify_generated_rule_family(rule)) ==
              row["generated_family"]
    end

    blind = compiled_rule(
        _julia_repeated_result_compile(
            _julia_repeated_result_case(contract, "blind_or_repeats"),
        ),
        "Top",
    )
    @test blind.mode_metadata.rep_min == 1
    @test generated_rule_family_name(classify_generated_rule_family(blind)) == "rep_bcode"
end

function role_native_mode_matrix(contract)
    for row in contract["mode_cases"]
        _julia_repeated_result_expect_native(row)
    end
end

function role_native_special_cases(contract)
    for row in contract["special_cases"]
        row["edge_surface"] == "blind" && continue
        _julia_repeated_result_expect_native(row)
    end
end

function role_loaded(contract)
    row = _julia_repeated_result_case(contract, "explicit_or_two_hits")
    mktempdir() do scratch
        path = joinpath(scratch, "explicit-or.spec")
        write(path, String(row["source"]))
        loaded = load_and_compile_spec(path_spec_request(path), SpecLoadOptions(scratch))
        result = runtime_parse(create_engine(loaded), String(row["input"]))
        @test result.value == row["expected_result"]
    end
end

function role_reconstructed(contract)
    row = _julia_repeated_result_case(contract, "explicit_or_two_hits")
    parsed = parse_spec(String(row["source"]))
    reconstructed = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
    result = runtime_parse(
        LinkedSpecRuntimeEngine(compile_spec(reconstructed)),
        String(row["input"]),
    )
    @test result.value == row["expected_result"]
end

function role_descriptor(contract)
    descriptor_contract = contract["descriptor_contract"]
    for case_id in ("explicit_or_two_hits", "pipe_distinct_scalar")
        row = _julia_repeated_result_case(contract, case_id)
        descriptor = to_descriptor_json(_julia_repeated_result_compile(row))
        metadata = descriptor["spec"]["Top"]["meta"]
        mode = metadata["mode"]
        @test metadata["family"] == descriptor_contract["family"]
        @test metadata["cursor_policy"] == descriptor_contract["cursor_policy"]
        @test mode["is_repetition"] == row["is_repetition"]
        @test get(mode, "rep_min", nothing) == row["rep_min"]
        @test get(mode, "rep_max", nothing) == row["rep_max"]
    end
end

function role_emitted_source(contract)
    row = _julia_repeated_result_case(contract, "explicit_or_two_hits")
    compiled = _julia_repeated_result_compile(row)
    emitted = emit_julia_source_v2(
        compiled,
        JULIA_REPEATED_ACTION_RESULT_GENERATED_IDENTITY,
    )
    @test occursin("linkedspec-generated-source-v2", emitted)
    @test occursin("const LINKEDSPEC_GENERATED_SOURCE_FORMAT = 2", emitted)
    @test occursin("rep_acode", emitted)
    @test occursin("function execute(", emitted)
    @test occursin("function execute_with_trace(", emitted)

    mktempdir() do scratch
        private_depot = joinpath(scratch, "depot")
        mkpath(private_depot)
        write(
            joinpath(scratch, "Project.toml"),
            "name = \"JuliaRepeatedResultEmittedHost\"\n" *
            "uuid = \"73eec671-fc55-4603-bbd5-e556f37f7875\"\n" *
            "version = \"0.1.0\"\n",
        )
        generated_path = joinpath(scratch, "generated_parser.jl")
        runner_path = joinpath(scratch, "runner.jl")
        write(generated_path, emitted)
        write(
            runner_path,
            """
import JSON3
import LinkedSpecJulia

include(ARGS[1])
const Parser = LinkedSpecGeneratedParser
trace_path = joinpath(dirname(ARGS[1]), "generated.trace")
direct = Parser.execute("ab")
traced = Parser.execute_with_trace(
    "ab",
    LinkedSpecJulia.LinkedSpecTraceConfig(
        level = LinkedSpecJulia.LinkedSpecTraceHigh,
        trace_file = trace_path,
        sink_mode = LinkedSpecJulia.LinkedSpecTraceRoute,
        reset_file = true,
    ),
)
print(JSON3.write(Dict("direct" => direct, "traced" => traced)))
""",
        )
        passed, output, errors = _julia_repeated_result_host_process(
            scratch,
            runner_path,
            generated_path,
            private_depot,
        )
        @test passed
        @test isempty(errors)
        @test JSON3.read(output, Dict{String,Any}) == Dict{String,Any}(
            "direct" => row["expected_result"],
            "traced" => row["expected_result"],
        )
        trace = read(joinpath(scratch, "generated.trace"), String)
        @test length(collect(eachmatch(r"julia_runtime:regex_slot_selected", trace))) == 2
        @test occursin("target_rule=Top regex_index=0", trace)
        @test occursin("target_rule=Top regex_index=1", trace)
    end

    failure = _julia_repeated_result_capture_error() do
        validate_generated_rule_plan_v2(
            compiled,
            [GeneratedPlanRow("Top", "or_acode")],
            JULIA_REPEATED_ACTION_RESULT_GENERATED_IDENTITY,
        )
    end
    @test failure isa GeneratedSourceException
    if failure isa GeneratedSourceException
        @test failure.stage == ValidateGeneratedPlanStage
        @test failure.code == GeneratedPlanFamilyMismatchCode
    end
end

function role_generated_direct(contract)
    for row in contract["mode_cases"]
        compiled = _julia_repeated_result_compile(row)
        @test execute_generated_parser_v2(
            compiled,
            build_generated_rule_plan(compiled),
            String(row["input"]),
            JULIA_REPEATED_ACTION_RESULT_GENERATED_IDENTITY,
        ) == row["expected_result"]
    end
end

function role_native_trace(contract)
    row = _julia_repeated_result_case(contract, "explicit_or_two_hits")
    trace = LinkedSpecTraceEmitter(
        trace_config_enabled(LinkedSpecTraceHigh);
        stdout_io = IOBuffer(),
    )
    result = runtime_parse(
        LinkedSpecRuntimeEngine(_julia_repeated_result_compile(row)),
        String(row["input"]);
        trace = trace,
    )
    @test result.value == row["expected_result"]
    _julia_repeated_result_expect_selected_trace(trace_events(trace))
end

function role_generated_trace(contract)
    row = _julia_repeated_result_case(contract, "explicit_or_two_hits")
    compiled = _julia_repeated_result_compile(row)
    mktempdir() do scratch
        trace_path = joinpath(scratch, "generated.trace")
        value = execute_generated_parser_with_trace_v2(
            compiled,
            build_generated_rule_plan(compiled),
            String(row["input"]),
            LinkedSpecTraceConfig(
                level = LinkedSpecTraceHigh,
                trace_file = trace_path,
                sink_mode = LinkedSpecTraceRoute,
                reset_file = true,
            ),
            JULIA_REPEATED_ACTION_RESULT_GENERATED_IDENTITY,
        )
        @test value == row["expected_result"]
        trace = read(trace_path, String)
        @test length(collect(eachmatch(r"julia_runtime:regex_slot_selected", trace))) == 2
        @test occursin("target_rule=Top regex_index=0", trace)
        @test occursin("target_rule=Top regex_index=1", trace)
    end
end

function role_primary_command(contract)
    for case_id in ("explicit_or_two_hits", "pipe_distinct_scalar")
        row = _julia_repeated_result_case(contract, case_id)
        output = IOBuffer()
        errors = IOBuffer()
        @test run_cli(
            [
                "--inline-spec",
                String(row["source"]),
                "--input",
                String(row["input"]),
            ];
            io = output,
            err = errors,
        ) == 0
        @test JSON3.read(String(take!(output))) == row["expected_result"]
        @test isempty(String(take!(errors)))
    end
end

function role_corpus_bundle(contract)
    row = _julia_repeated_result_case(contract, "explicit_or_two_hits")
    bundle = contract["corpus_bundle"]
    source = read(joinpath(REPO_ROOT, String(bundle["source"])), String)
    input = read(joinpath(REPO_ROOT, String(bundle["input"])), String)
    expected = JSON3.read(
        read(joinpath(REPO_ROOT, String(bundle["expected"])), String),
    )
    @test source == row["source"]
    @test input == "ab\n"
    @test expected == row["expected_result"]
    @test runtime_parse(
        LinkedSpecRuntimeEngine(compile_spec(parse_spec(source))),
        chomp(input),
    ).value == expected
end

function role_lifecycle_authority(contract)
    for case_id in (
        "exit_lifecycle_overrides_collection",
        "loop_end_lifecycle_exits_rule",
    )
        _julia_repeated_result_expect_native(
            _julia_repeated_result_case(contract, case_id),
        )
    end
end

function role_bounds_and_progress(contract)
    for case_id in (
        "compact_optional_one_hit",
        "bounded_exact_two_hits",
        "bounded_up_to_two_hits",
        "zero_permitted_hits_empty",
        "below_minimum_is_null",
    )
        _julia_repeated_result_expect_native(
            _julia_repeated_result_case(contract, case_id),
        )
    end

    zero_progress = """
Top::OR{,3}
 /x*/ -> Top[0] { return("Z") }
"""
    result = runtime_parse(
        LinkedSpecRuntimeEngine(compile_spec(parse_spec(zero_progress))),
        "",
    )
    @test result.value == ["Z"]
end

@testset "Julia explicit-repetition action-result admission" begin
    row = _julia_repeated_result_case(
        JULIA_REPEATED_ACTION_RESULT_CONTRACT,
        "explicit_or_two_hits",
    )
    rule = compiled_rule(_julia_repeated_result_compile(row), "Top")
    @test rule.mode_metadata.is_repetition
    @test rule.mode_metadata.rep_min == 1
    @test generated_rule_family_name(classify_generated_rule_family(rule)) == "rep_acode"
    @test _julia_repeated_result_execute(row).value == ["A", "B"]

    roles = Dict{String,Function}(
        "neutral_contract" => role_neutral_contract,
        "ast_metadata" => role_ast_metadata,
        "native_mode_matrix" => role_native_mode_matrix,
        "native_special_cases" => role_native_special_cases,
        "loaded" => role_loaded,
        "reconstructed" => role_reconstructed,
        "descriptor" => role_descriptor,
        "emitted_source" => role_emitted_source,
        "generated_direct" => role_generated_direct,
        "native_trace" => role_native_trace,
        "generated_trace" => role_generated_trace,
        "primary_command" => role_primary_command,
        "corpus_bundle" => role_corpus_bundle,
        "lifecycle_authority" => role_lifecycle_authority,
        "bounds_and_progress" => role_bounds_and_progress,
    )
    declared = String[
        role for role in JULIA_REPEATED_ACTION_RESULT_CONTRACT["admissions"]["julia"]["roles"]
    ]
    @test length(unique(declared)) == length(declared)
    @test Set(keys(roles)) == Set(declared)

    completed = Set{String}()
    for role in declared
        @test !(role in completed)
        push!(completed, role)
        roles[role](JULIA_REPEATED_ACTION_RESULT_CONTRACT)
    end
    @test completed == Set(keys(roles))
end

end
