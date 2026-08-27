# FUTURE-PARITY-BACKLOG.14.7.6.0 — dormant Julia staged-AST enrichment RED.
#
# This exact final-path consumer is intentionally omitted from ordinary Julia
# and canonical CI discovery. Its focused repository-local command is:
#
#   bash tools/run_julia_project_data.sh --project=julia --startup-file=no \
#     --history-file=no julia/test/staged_ast_enrichment_contract_test.jl
#
# Every pre-boundary assertion must remain GREEN. The sole intentional RED is
# the final missing dedicated `STAGED_PARSE_JOB_MARKER` plus typed
# `staged_parse_job_v2` provenance assertion; the current generic
# `parse_job(...)` call and unsupported-helper rejection are not an
# implementation.

using JSON3
using LinkedSpecJulia
using Test

const JULIA_STAGED_ENRICHMENT_REPO_ROOT = normpath(joinpath(@__DIR__, "..", ".."))
const JULIA_STAGED_ENRICHMENT_CONTRACT = JSON3.read(
    read(
        joinpath(
            JULIA_STAGED_ENRICHMENT_REPO_ROOT,
            "capability_conformance",
            "staged_ast_enrichment_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)
const JULIA_STAGED_ENRICHMENT_CONTRACT_ID =
    "linkedspec-staged-ast-enrichment-v1"
const JULIA_STAGED_ENRICHMENT_CONSUMER =
    "julia/test/staged_ast_enrichment_contract_test.jl"
const JULIA_STAGED_ENRICHMENT_SOURCE_IDENTITY =
    "staged-ast-enrichment/julia-red.spec"
const JULIA_STAGED_ENRICHMENT_EMITTED_IDENTITY =
    "staged-ast-enrichment/julia-red-emitted.spec"
const JULIA_STAGED_ENRICHMENT_AUTHORED_SOURCE = raw"""Top::
 /([^;]+);/
 I {
  job_marker = parse_job(entry_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", "result_policy", "sibling_field", "into", "expression_ast", "on_error", "fail"))
  return(job_marker)
 }
"""

function _julia_staged_enrichment_all_objects(value)
    objects = Dict{String,Any}[]
    if value isa AbstractDict
        object = Dict{String,Any}(
            String(key) => child for (key, child) in pairs(value)
        )
        push!(objects, object)
        for child in values(object)
            append!(objects, _julia_staged_enrichment_all_objects(child))
        end
    elseif value isa AbstractVector
        for child in value
            append!(objects, _julia_staged_enrichment_all_objects(child))
        end
    end
    return objects
end

function _julia_staged_enrichment_objects_with_kind(value, kind::AbstractString)
    return [
        object for object in _julia_staged_enrichment_all_objects(value)
        if get(object, "kind", nothing) == kind
    ]
end

function _julia_staged_enrichment_capture(operation::Function)
    try
        operation()
    catch error
        return error
    end
    return nothing
end

function _julia_staged_enrichment_compile(source::AbstractString)
    parsed = parse_spec(source)
    validate_spec(parsed)
    return parsed, compile_spec(parsed)
end

function _julia_staged_enrichment_expect_native_failure(error)
    @test error isa RuntimeInterpreterException
    error isa RuntimeInterpreterException || return
    @test sprint(showerror, error) ==
          "unsupported runtime helper 'parse_job' in rule Top"
    @test error.diagnostic !== nothing
    error.diagnostic === nothing && return
    diagnostic = to_json(error.diagnostic)
    @test diagnostic["stage"] == "runtime_execution"
    @test diagnostic["rule_label"] == "Top"
    @test diagnostic["detail"] ==
          "unsupported runtime helper 'parse_job' in rule Top"
end

function _julia_staged_enrichment_expect_generated_failure(
    error,
    identity::AbstractString,
)
    @test error isa GeneratedSourceException
    error isa GeneratedSourceException || return
    @test error.stage == ExecuteGeneratedStage
    @test error.code == GeneratedExecutionFailedCode
    @test error.source_identity == identity
    @test error.rule_label == "Top"
    @test error.handler_family == "default"
    @test error.detail == "unsupported runtime helper 'parse_job' in rule Top"
end

function _julia_staged_enrichment_execute_emitted_failure(
    compiled::CompiledSpec,
    identity::AbstractString,
)
    emitted = emit_julia_source_v2(compiled, identity)
    host = Module(gensym(:JuliaStagedAstEnrichmentRedHost))
    Base.include_string(host, emitted, "staged_ast_enrichment_generated.jl")
    parser = Base.invokelatest(() -> getfield(host, :LinkedSpecGeneratedParser))
    execute = Base.invokelatest(() -> getfield(parser, :execute))
    metadata = Base.invokelatest(() -> getfield(parser, :metadata))
    error = _julia_staged_enrichment_capture(
        () -> Base.invokelatest(execute, "1+2;"),
    )
    source_identity = Base.invokelatest(metadata).source_identity
    return error, emitted, source_identity
end

function _julia_staged_enrichment_v1_job(; top_rule = "action_block")
    body_source = "return(trim(value))"
    return StagedParseJob(
        version = 1,
        job_id =
            "parse_job:function_body:functions.0.body_source:" *
            "actionir-body.spec:action_block:10-29",
        parent_ast_path = ["functions", "0", "body_source"],
        node_kind = "function_definition",
        payload_kind = "function_body",
        function_name = "normalize",
        params = ["value"],
        arity = 1,
        text = body_source,
        source_span = StagedSourceSpan(10, 29, 1, 1),
        parser_spec_id = "actionir-body.spec",
        top_rule = top_rule,
        result_policy = "replace_field",
        result_field = "body_ast",
        failure_policy = "fail",
        diagnostic_owner = "function_body",
    )
end

function _julia_staged_enrichment_ids(contract, field::AbstractString)
    return String[String(row["id"]) for row in contract[field]]
end

@testset "Dormant Julia staged-AST enrichment RED" begin
    @testset "neutral authority and function-body v1 stay exact" begin
        contract = JULIA_STAGED_ENRICHMENT_CONTRACT
        @test contract["contract_id"] == JULIA_STAGED_ENRICHMENT_CONTRACT_ID
        @test contract["format"] == 1
        @test contract["status"] ==
              "neutral_perl_rust_and_dart_complete_julia_dormant_red_lua_pending"
        @test contract["expected_counts"] == Dict{String,Any}(
            "registry_entries" => 4,
            "sources" => 2,
            "provenance_cases" => 8,
            "job_id_cases" => 3,
            "resolution_cases" => 8,
            "authority_cases" => 6,
            "cache_cases" => 10,
            "queue_cases" => 4,
            "isolation_cases" => 3,
            "stitch_cases" => 4,
            "failure_cases" => 3,
            "chain_cases" => 10,
            "detachment_cases" => 5,
            "carrier_requirements" => 4,
            "backend_consumers" => 5,
            "runtime_routes" => 6,
            "outward_guard_paths" => 10,
            "diagnostics" => 37,
            "rollout_legs" => 9,
            "ownership_rows" => 35,
            "mutations" => 92,
        )
        expected_ids = Dict(
            "provenance_cases" => [
                "direct_unicode",
                "direct_empty",
                "derived_ordered",
                "direct_reversed",
                "direct_out_of_bounds",
                "derived_empty",
                "derived_segment_invalid",
                "copied_text_smuggling",
            ],
            "job_id_cases" => [
                "direct_identity",
                "derived_identity",
                "default_top_normalized_before_identity",
            ],
            "resolution_cases" => [
                "alias_first",
                "declaring_relative_second",
                "search_root_order",
                "provider_order",
                "missing",
                "same_priority_ambiguous",
                "alias_relative_collision",
                "path_traversal_rejected",
            ],
            "authority_cases" => [
                "intersection_and_minima",
                "entry_cannot_elevate_caller",
                "required_capability_missing",
                "policy_denied",
                "source_detail_denied",
                "helper_version_mismatch",
            ],
            "cache_cases" => [
                "base",
                "identical",
                "content_changed",
                "graph_changed",
                "top_changed",
                "spec_version_changed",
                "helper_version_changed",
                "staged_version_changed",
                "capability_order_normalized",
                "capability_set_changed",
            ],
            "queue_cases" => [
                "parent_then_provenance",
                "job_id_tie_break",
                "derived_order_key",
                "breadth_first_recursive_enqueue",
            ],
            "isolation_cases" => [
                "siblings_receive_fresh_runtime_contexts",
                "falsey_child_state_does_not_escape",
                "shared_budget_spans_next_depth",
            ],
            "stitch_cases" => [
                "replace_marker",
                "replace_field",
                "sibling_field",
                "append_child",
            ],
            "failure_cases" => [
                "fail_aborts_composed_parse",
                "keep_text_continues",
                "diagnostic_node_uses_result_target",
            ],
            "chain_cases" => [
                "direct_strictly_smaller",
                "derived_strictly_smaller",
                "exact_tuple_cycle",
                "same_extent_non_decreasing",
                "derived_not_contained",
                "depth_exceeded",
                "call_limit_exceeded",
                "cancelled",
                "deadline_exceeded",
                "budget_exhausted",
            ],
            "detachment_cases" => [
                "plain_nested",
                "falsey_scalar",
                "live_parser_handle",
                "reference_cycle_marker",
                "node_limit",
            ],
        )
        for (field, ids) in expected_ids
            @test _julia_staged_enrichment_ids(contract, field) == ids
        end

        @test [row["status"] for row in contract["backend_consumers"]] == [
            "complete",
            "complete",
            "complete",
            "dormant_red",
            "pending_absent",
        ]
        julia_consumer = contract["backend_consumers"][4]
        @test julia_consumer == Dict{String,Any}(
            "backend" => "julia",
            "owner" => "FUTURE-PARITY-BACKLOG.14.7.6.0",
            "path" => JULIA_STAGED_ENRICHMENT_CONSUMER,
            "status" => "dormant_red",
        )
        @test [row["status"] for row in contract["rollout"]] == [
            "complete",
            "complete",
            "complete",
            "complete",
            "pending",
            "pending",
            "pending",
            "pending",
            "pending",
        ]
        @test contract["authored_surface"]["availability"] ==
              "neutral executable authority with private Perl, Rust, and Dart carriers complete; " *
              "the Julia general carrier contract is dormant RED; PUC Lua, LuaJIT, recurring, " *
              "and public authoring remain pending under FUTURE-PARITY-BACKLOG.14.7.6-.10"
        @test contract["compatibility_v1"] == Dict{String,Any}(
            "status" => "current_unchanged",
            "record_version" => 1,
            "parser_spec_id" => "actionir-body.spec",
            "resolved_spec_id" => "builtin:actionir-body.spec",
            "top_rule" => "action_block",
            "result_policy" => "replace_field",
            "result_field" => "body_ast",
            "failure_policy" => "fail",
            "source_provenance" =>
                "legacy copied exact text plus numeric offset and line span",
            "general_authoring" => false,
            "upgrade_to_v2" => "explicit_only",
        )

        v1_result = to_json(only(execute_staged_parse_jobs([
            _julia_staged_enrichment_v1_job(),
        ])))
        @test v1_result["phases"] == ["resolve", "load", "compile", "execute"]
        @test v1_result["resolved_spec_id"] == "builtin:actionir-body.spec"
        @test v1_result["registry_provider"] == "builtin"
        @test v1_result["result_policy"] == "replace_field"
        @test v1_result["result_field"] == "body_ast"
        @test v1_result["failure_policy"] == "fail"
        @test v1_result["result"]["kind"] == "action_block"

        wrong_top = _julia_staged_enrichment_capture(
            () -> execute_staged_parse_job(
                _julia_staged_enrichment_v1_job(top_rule = "missing_top"),
            ),
        )
        @test wrong_top isa StagedParserRegistryException
        wrong_top isa StagedParserRegistryException || return
        for context in [
            "phase=compile",
            "parent_ast_path=functions.0.body_source",
            "parser_spec_id=actionir-body.spec",
            "resolved_spec_id=builtin:actionir-body.spec",
            "top_rule=missing_top",
            "payload_kind=function_body",
            "source_span=10-29",
            "failure_policy=fail",
        ]
            @test occursin(context, wrong_top.message)
        end

        general_job = StagedParseJob(
            version = 2,
            job_id = "parse_job:v2:sha256:dormant-red",
            parent_ast_path = ["Top", "job_marker"],
            node_kind = "expression",
            payload_kind = "embedded_expression",
            text = "1+2",
            source_span = StagedSourceSpan(0, 3, 1, 1),
            parser_spec_id = "expr-v1",
            top_rule = "Expr",
            result_policy = "sibling_field",
            result_field = "expression_ast",
            failure_policy = "fail",
        )
        general_error = _julia_staged_enrichment_capture(
            () -> execute_staged_parse_job(general_job),
        )
        @test general_error isa StagedParserRegistryException
        general_error isa StagedParserRegistryException || return
        @test occursin("phase=resolve", general_error.message)
        @test occursin("parser_spec_id=expr-v1", general_error.message)
        @test occursin(
            "unsupported parser spec id 'expr-v1'",
            general_error.message,
        )
    end

    parsed, compiled = _julia_staged_enrichment_compile(
        JULIA_STAGED_ENRICHMENT_AUTHORED_SOURCE,
    )
    payload = only(action_payloads(compiled_rule(compiled, "Top")))
    compiled_action = to_json(payload.action_ast)
    generic_calls = [
        object for object in _julia_staged_enrichment_objects_with_kind(
            compiled_action,
            "call",
        )
        if get(object, "name", nothing) == "parse_job"
    ]
    marker_nodes = _julia_staged_enrichment_objects_with_kind(
        compiled_action,
        "staged_parse_job_marker",
    )

    @testset "authored syntax remains exactly one generic helper call" begin
        @test length(generic_calls) == 1
        call = only(generic_calls)
        @test length(call["args"]) == 2
        @test call["args"][1]["kind"] == "call"
        @test call["args"][1]["name"] == "entry_group"
        @test call["args"][2]["kind"] == "call"
        @test call["args"][2]["name"] == "hash"
        @test isempty(marker_nodes)
        encoded = JSON3.write(compiled_action)
        @test count("\"name\":\"parse_job\"", encoded) == 1
        @test !occursin("STAGED_PARSE_JOB_MARKER", encoded)
        @test !occursin("staged_parse_job_v2", encoded)
    end

    @testset "four carriers converge on the unsupported-helper boundary" begin
        native_error = _julia_staged_enrichment_capture(
            () -> runtime_parse(LinkedSpecRuntimeEngine(compiled), "1+2;"),
        )
        _julia_staged_enrichment_expect_native_failure(native_error)

        normalized = JSON3.read(JSON3.write(to_json(parsed)), Dict{String,Any})
        reconstructed = from_json(SpecFile, normalized)
        validate_spec(reconstructed)
        reconstructed_compiled = compile_spec(reconstructed)
        reconstructed_error = _julia_staged_enrichment_capture(
            () -> runtime_parse(
                LinkedSpecRuntimeEngine(reconstructed_compiled),
                "1+2;",
            ),
        )
        _julia_staged_enrichment_expect_native_failure(reconstructed_error)

        generated_error = _julia_staged_enrichment_capture(
            () -> execute_generated_parser_v2(
                compiled,
                build_generated_rule_plan(compiled),
                "1+2;",
                JULIA_STAGED_ENRICHMENT_SOURCE_IDENTITY,
            ),
        )
        _julia_staged_enrichment_expect_generated_failure(
            generated_error,
            JULIA_STAGED_ENRICHMENT_SOURCE_IDENTITY,
        )

        emitted_error, emitted, emitted_identity =
            _julia_staged_enrichment_execute_emitted_failure(
                compiled,
                JULIA_STAGED_ENRICHMENT_EMITTED_IDENTITY,
            )
        _julia_staged_enrichment_expect_generated_failure(
            emitted_error,
            JULIA_STAGED_ENRICHMENT_EMITTED_IDENTITY,
        )
        @test emitted_identity == JULIA_STAGED_ENRICHMENT_EMITTED_IDENTITY
        @test !occursin("STAGED_PARSE_JOB_MARKER", emitted)
        @test !occursin("staged_parse_job_v2", emitted)
        @test !occursin(JULIA_STAGED_ENRICHMENT_CONTRACT_ID, emitted)
    end

    @testset "consumer remains outside ordinary and canonical discovery" begin
        ordinary = read(
            joinpath(
                JULIA_STAGED_ENRICHMENT_REPO_ROOT,
                "julia",
                "test",
                "runtests.jl",
            ),
            String,
        )
        canonical = read(
            joinpath(
                JULIA_STAGED_ENRICHMENT_REPO_ROOT,
                "tools",
                "run_ci_local.sh",
            ),
            String,
        )
        @test isfile(joinpath(
            JULIA_STAGED_ENRICHMENT_REPO_ROOT,
            JULIA_STAGED_ENRICHMENT_CONSUMER,
        ))
        @test !occursin("staged_ast_enrichment_contract_test.jl", ordinary)
        @test !occursin(JULIA_STAGED_ENRICHMENT_CONSUMER, canonical)
        umbrella = read(
            joinpath(
                JULIA_STAGED_ENRICHMENT_REPO_ROOT,
                "julia",
                "src",
                "LinkedSpecJulia.jl",
            ),
            String,
        )
        for private_token in [
            "parse_job(text_expr",
            "STAGED_PARSE_JOB_MARKER",
            JULIA_STAGED_ENRICHMENT_CONTRACT_ID,
        ]
            @test !occursin(private_token, umbrella)
        end
    end

    @testset "LINKEDSPEC_STAGED_AST_ENRICHMENT_JULIA_RED: missing dedicated marker and typed provenance" begin
        # Intentional RED: owner .14.7.6.1 must replace only the reserved
        # generic assignment with one dedicated logical marker and sidecar.
        @test isempty(generic_calls) && length(marker_nodes) == 1
    end
end
