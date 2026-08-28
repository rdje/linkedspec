# FUTURE-PARITY-BACKLOG.14.7.6.0-.4 — admitted Julia staged-AST enrichment.
#
# Ordinary Julia discovery and canonical CI run this exact final-path consumer.
# Its focused repository-local command is:
#
#   bash tools/run_julia_project_data.sh --project=julia --startup-file=no \
#     --history-file=no julia/test/staged_ast_enrichment_contract_test.jl
#
# It freezes the neutral contract, private marker/provenance/recursive authority,
# and four fresh top-level production routes without making general parse_job
# authoring public.

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
 E {
  job_marker = parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", "result_policy", "sibling_field", "into", "expression_ast", "on_error", "fail"))
  return(job_marker)
 }
"""
const JULIA_STAGED_ENRICHMENT_PRODUCTION_SOURCE = raw"""Top::
 /([^;]+);/
 E {
  job_marker = parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr", "top", "Expr", "result_policy", "replace_marker", "on_error", "fail"))
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

function _julia_staged_enrichment_execute_emitted_marker(
    compiled::CompiledSpec,
    identity::AbstractString,
)
    emitted = emit_julia_source_v2(compiled, identity)
    host = Module(gensym(:JuliaStagedAstEnrichmentRedHost))
    Base.include_string(host, emitted, "staged_ast_enrichment_generated.jl")
    parser = Base.invokelatest(() -> getfield(host, :LinkedSpecGeneratedParser))
    execute = Base.invokelatest(() -> getfield(parser, :execute))
    metadata = Base.invokelatest(() -> getfield(parser, :metadata))
    value = Base.invokelatest(execute, "1+2;")
    source_identity = Base.invokelatest(metadata).source_identity
    return value, emitted, source_identity
end

function _julia_staged_enrichment_execute_emitted_production(
    compiled::CompiledSpec,
    identity::AbstractString,
    seed,
)
    emitted = emit_julia_source_v2(compiled, identity)
    host = Module(gensym(:JuliaStagedAstEnrichmentCarrierHost))
    Base.include_string(host, emitted, "staged_ast_enrichment_production.jl")
    parser = Base.invokelatest(() -> getfield(host, :LinkedSpecGeneratedParser))
    execute = Base.invokelatest(() -> getfield(parser, :execute))
    metadata = Base.invokelatest(() -> getfield(parser, :metadata))
    values = Any[
        Base.invokelatest(
            execute,
            "1+2;";
            staged_ast_enrichment_seed = seed,
        ) for _ in 1:2
    ]
    source_identity = Base.invokelatest(metadata).source_identity
    return values, emitted, source_identity
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

function _julia_staged_enrichment_expected_marker()
    return Dict{String,Any}(
        "kind" => "STAGED_PARSE_JOB_MARKER",
        "version" => 2,
        "sidecar_kind" => "staged_parse_job_v2",
        "effect" => "staged_parse_job_declaration",
        "staged_parse_job_v2" => Dict{String,Any}(
            "kind" => "staged_parse_job_v2",
            "version" => 2,
            "state" => "declared",
            "effect" => "staged_parse_job_declaration",
            "node_kind" => "expression",
            "payload_kind" => "embedded_expression",
            "parser_spec_id" => "expr-v1",
            "top_rule" => "Expr",
            "result_policy" => "sibling_field",
            "into" => "expression_ast",
            "failure_policy" => "fail",
            "required_capabilities" => Any[],
            "text" => "1+2",
            "provenance" => Dict{String,Any}(
                "kind" => "direct_span",
                "source_id" => "input",
                "start" => 0,
                "end" => 3,
                "provenance" => "match_group",
            ),
            "origin" => "Top:parse_job",
        ),
    )
end

function _julia_staged_enrichment_options()
    return Dict{String,Any}(
        "declaring_spec_id" => "grammar/main.spec",
        "caller_capabilities" => Any[
            "staged-parse-job-v2",
            "structured-result-v1",
            "typed-source-location-v1",
            "xml-v1",
            "yaml-v1",
        ],
        "caller_policy_modes" => Any[
            "append_child",
            "diagnostic_node",
            "fail",
            "keep_text",
            "replace_field",
            "replace_marker",
            "sibling_field",
            "trace",
        ],
        "caller_ceilings" => Dict{String,Any}(
            "source_detail" => "text",
            "max_steps" => 200,
            "max_result_nodes" => 128,
            "max_diagnostic_bytes" => 8192,
        ),
        "required_source_detail" => "identity",
        "required_versions" => Dict{String,Any}(
            "spec_language_version" => 2,
            "helper_contract_version" => "actionir-v3",
            "staged_contract_version" => 2,
        ),
    )
end

function _julia_staged_enrichment_marker(
    text::AbstractString,
    start::Int,
    result_policy::AbstractString,
    into::Union{Nothing,AbstractString},
    failure_policy::AbstractString;
    top_rule::Union{Nothing,AbstractString} = "Expr",
)
    sidecar = Dict{String,Any}(
        "kind" => "staged_parse_job_v2",
        "version" => 2,
        "state" => "declared",
        "effect" => "staged_parse_job_declaration",
        "node_kind" => "expression",
        "payload_kind" => "embedded_expression",
        "parser_spec_id" => "expr",
        "result_policy" => String(result_policy),
        "failure_policy" => String(failure_policy),
        "required_capabilities" => Any["typed-source-location-v1"],
        "text" => String(text),
        "provenance" => Dict{String,Any}(
            "kind" => "direct_span",
            "source_id" => "ascii",
            "start" => start,
            "end" => start + length(text),
            "provenance" => "capture",
        ),
        "origin" => "contract:parse_job",
    )
    top_rule === nothing || (sidecar["top_rule"] = String(top_rule))
    into === nothing || (sidecar["into"] = String(into))
    return Dict{String,Any}(
        "kind" => "STAGED_PARSE_JOB_MARKER",
        "version" => 2,
        "sidecar_kind" => "staged_parse_job_v2",
        "effect" => "staged_parse_job_declaration",
        "staged_parse_job_v2" => sidecar,
    )
end

function _julia_staged_enrichment_registry(callback::Function)
    callbacks = Dict{String,Function}(
        String(entry["compiled_authority"]) => callback
        for entry in JULIA_STAGED_ENRICHMENT_CONTRACT["resolution_snapshot"]["entries"]
    )
    return LinkedSpecJulia._freeze_staged_registry(
        JULIA_STAGED_ENRICHMENT_CONTRACT["resolution_snapshot"],
        callbacks,
    )
end

function _julia_staged_enrichment_recursive_authority(;
    token = "cancel:open",
    deadline = 100,
    remaining_steps = 20,
    required_steps = 1,
    max_depth = 4,
    max_calls = 10,
    total_calls = nothing,
    cancelled = _token -> false,
    clock = () -> 1,
)
    config = Dict{String,Any}(
        "cancellation_token" => token,
        "deadline" => deadline,
        "remaining_steps" => remaining_steps,
        "required_steps" => required_steps,
        "max_depth" => max_depth,
        "max_calls" => max_calls,
    )
    total_calls === nothing || (config["total_calls"] = total_calls)
    return LinkedSpecJulia._StagedRecursiveAuthority(
        config,
        cancelled,
        clock,
    )
end

function _julia_staged_enrichment_production_seed(observations; failure::Bool = false)
    run_counter = Ref(0)
    factory = function()
        run_counter[] += 1
        run_id = run_counter[]
        token = Dict{String,Any}("run_id" => run_id)
        callback_bindings = Dict{String,Function}()
        for entry in JULIA_STAGED_ENRICHMENT_CONTRACT["resolution_snapshot"]["entries"]
            callback_name = String(entry["compiled_authority"])
            callback = let callback_name = callback_name, run_id = run_id
                function(request, context)
                    push!(observations["callbacks"], Dict{String,Any}(
                        "run_id" => run_id,
                        "callback_name" => callback_name,
                        "text" => request["text"],
                        "token" => LinkedSpecJulia._staged_cancellation_token(context),
                    ))
                    LinkedSpecJulia._staged_safe_point(context, 0)
                    return failure ?
                        LinkedSpecJulia._staged_child_failure(Dict{String,Any}(
                            "code" => "fixture_child_failure",
                        )) :
                        LinkedSpecJulia._staged_child_success(Dict{String,Any}(
                            "kind" => "expression",
                            "text" => request["text"],
                            "top_rule" => request["top_rule"],
                        ))
                end
            end
            callback_bindings[callback_name] = callback
        end
        cancelled = let run_id = run_id
            function(actual_token)
                push!(observations["cancellation_checks"], Dict{String,Any}(
                    "run_id" => run_id,
                    "token" => deepcopy(actual_token),
                ))
                return false
            end
        end
        clock = let run_id = run_id
            function()
                push!(observations["clock_checks"], run_id)
                return 1
            end
        end
        push!(observations["starts"], Dict{String,Any}(
            "run_id" => run_id,
            "token" => deepcopy(token),
            "callbacks" => Any[values(callback_bindings)...],
            "cancelled" => cancelled,
            "clock" => clock,
        ))
        return Dict{String,Any}(
            "compiled_authorities" => callback_bindings,
            "recursive_authority" => Dict{String,Any}(
                "cancellation_token" => token,
                "deadline" => 100,
                "remaining_steps" => 20,
                "required_steps" => 1,
                "max_depth" => 4,
                "max_calls" => 10,
            ),
            "cancelled" => cancelled,
            "clock" => clock,
        )
    end
    return LinkedSpecJulia.StagedAstEnrichmentSeed(
        snapshot = JULIA_STAGED_ENRICHMENT_CONTRACT["resolution_snapshot"],
        options = _julia_staged_enrichment_options(),
        authority_factory = factory,
    )
end

function _julia_staged_enrichment_error_code(error)
    error isa LinkedSpecJulia.StagedAstEnrichmentException || return nothing
    return to_json(error)["code"]
end

function _julia_staged_enrichment_diagnostic_is_complete(error)
    code = _julia_staged_enrichment_error_code(error)
    code === nothing && return false
    rows = [
        row for row in JULIA_STAGED_ENRICHMENT_CONTRACT["diagnostics"]
        if row["code"] == code
    ]
    length(rows) == 1 || return false
    record = to_json(error)
    return all(haskey(record, field) for field in only(rows)["required_context"])
end

function _julia_staged_enrichment_forbidden_key_hits(value)
    forbidden = Set([
        "path",
        "spec_path",
        "source_authority",
        "match",
        "match_object",
        "parser",
        "registry",
        "compiled_authority",
        "callback",
        "host_handle",
        "cancellation_token",
        "deadline",
        "mutable_queue",
    ])
    hits = String[]
    function visit(current)
        if current isa AbstractDict
            for (key, child) in pairs(current)
                key_string = String(key)
                key_string in forbidden && push!(hits, key_string)
                visit(child)
            end
        elseif current isa AbstractVector
            foreach(visit, current)
        end
        return nothing
    end
    visit(value)
    sort!(hits)
    return hits
end

@testset "Admitted Julia staged-AST enrichment" begin
    @testset "neutral authority and function-body v1 stay exact" begin
        contract = JULIA_STAGED_ENRICHMENT_CONTRACT
        @test contract["contract_id"] == JULIA_STAGED_ENRICHMENT_CONTRACT_ID
        @test contract["format"] == 1
        @test contract["status"] ==
              "all_backends_complete_recurring_and_public_current"
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
            "recurring_source_groups" => 5,
            "recurring_runtime_routes" => 6,
            "outward_guard_paths" => 10,
            "diagnostics" => 37,
            "rollout_legs" => 9,
            "ownership_rows" => 35,
            "mutations" => 123,
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
            "complete",
            "complete",
        ]
        julia_consumer = contract["backend_consumers"][4]
        @test julia_consumer == Dict{String,Any}(
            "backend" => "julia",
            "owner" => "FUTURE-PARITY-BACKLOG.14.7.6.0",
            "path" => JULIA_STAGED_ENRICHMENT_CONSUMER,
            "status" => "complete",
        )
        @test [row["status"] for row in contract["rollout"]] == [
            "complete",
            "complete",
            "complete",
            "complete",
            "complete",
            "complete",
            "complete",
            "complete",
            "complete",
        ]
        @test contract["authored_surface"]["availability"] ==
              "portable exact-assignment parse_job authoring is current on Perl, Rust, Dart, " *
              "Julia, PUC Lua, and LuaJIT through the dedicated staged marker and " *
              "caller-frozen already-compiled authority"
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

    @testset "exclusive assignment lowers to one typed dedicated ActionIR node" begin
        @test isempty(generic_calls)
        @test length(marker_nodes) == 1
        marker = only(marker_nodes)
        @test marker["target"] == "job_marker"
        @test marker["version"] == 2
        @test marker["sidecar_kind"] == "staged_parse_job_v2"
        @test marker["effect"] == "staged_parse_job_declaration"
        @test marker["text_plan"] == Dict{String,Any}(
            "kind" => "direct_span",
            "source" => "match_group",
            "index" => 0,
        )
        @test marker["options"] == Dict{String,Any}(
            "node_kind" => "expression",
            "payload_kind" => "embedded_expression",
            "spec" => "expr-v1",
            "top" => "Expr",
            "result_policy" => "sibling_field",
            "into" => "expression_ast",
            "on_error" => "fail",
            "required_capabilities" => Any[],
        )
        encoded = JSON3.write(compiled_action)
        @test count("\"name\":\"parse_job\"", encoded) == 0
        @test !occursin("STAGED_PARSE_JOB_MARKER", encoded)
        @test count("\"kind\":\"staged_parse_job_marker\"", encoded) == 1
        @test occursin("staged_parse_job_v2", encoded)
    end

    @testset "four logical carriers preserve one detached marker" begin
        expected = _julia_staged_enrichment_expected_marker()
        native = runtime_parse(LinkedSpecRuntimeEngine(compiled), "1+2;").value
        @test native == expected

        normalized = JSON3.read(JSON3.write(to_json(parsed)), Dict{String,Any})
        reconstructed = from_json(SpecFile, normalized)
        validate_spec(reconstructed)
        reconstructed_compiled = compile_spec(reconstructed)
        reconstructed_value = runtime_parse(
            LinkedSpecRuntimeEngine(reconstructed_compiled),
            "1+2;",
        ).value
        @test reconstructed_value == expected

        generated_value = execute_generated_parser_v2(
            compiled,
            build_generated_rule_plan(compiled),
            "1+2;",
            JULIA_STAGED_ENRICHMENT_SOURCE_IDENTITY,
        )
        @test generated_value == expected

        emitted_value, emitted, emitted_identity =
            _julia_staged_enrichment_execute_emitted_marker(
                compiled,
                JULIA_STAGED_ENRICHMENT_EMITTED_IDENTITY,
            )
        @test emitted_value == expected
        @test emitted_identity == JULIA_STAGED_ENRICHMENT_EMITTED_IDENTITY
        @test !occursin("STAGED_PARSE_JOB_MARKER", emitted)
        @test !occursin("staged_parse_job_v2", emitted)
        @test !occursin(JULIA_STAGED_ENRICHMENT_CONTRACT_ID, emitted)
        @test isempty(_julia_staged_enrichment_forbidden_key_hits(native))
    end

    @testset "four production routes start fresh opaque staged authority" begin
        production_parsed, production_compiled =
            _julia_staged_enrichment_compile(
                JULIA_STAGED_ENRICHMENT_PRODUCTION_SOURCE,
            )
        raw_marker = runtime_parse(
            LinkedSpecRuntimeEngine(production_compiled),
            "1+2;",
        ).value
        @test raw_marker["kind"] == "STAGED_PARSE_JOB_MARKER"

        observations = Dict{String,Any}(
            "starts" => Any[],
            "callbacks" => Any[],
            "cancellation_checks" => Any[],
            "clock_checks" => Any[],
        )
        seed = _julia_staged_enrichment_production_seed(observations)
        @test sprint(show, seed) == "StagedAstEnrichmentSeed(<opaque>)"
        @test_throws ArgumentError LinkedSpecRuntimeEngine(
            production_compiled;
            staged_ast_enrichment_seed = "not-a-seed",
        )

        native_engine = LinkedSpecRuntimeEngine(
            production_compiled;
            staged_ast_enrichment_seed = seed,
        )
        native_values = Any[
            runtime_parse(native_engine, "1+2;").value for _ in 1:2
        ]

        normalized = JSON3.read(
            JSON3.write(to_json(production_parsed)),
            Dict{String,Any},
        )
        reconstructed = from_json(SpecFile, normalized)
        validate_spec(reconstructed)
        reconstructed_compiled = compile_spec(reconstructed)
        reconstructed_engine = LinkedSpecRuntimeEngine(
            reconstructed_compiled;
            staged_ast_enrichment_seed = seed,
        )
        reconstructed_values = Any[
            runtime_parse(reconstructed_engine, "1+2;").value for _ in 1:2
        ]

        generated_plan = build_generated_rule_plan(production_compiled)
        generated_values = Any[
            execute_generated_parser_v2(
                production_compiled,
                generated_plan,
                "1+2;",
                JULIA_STAGED_ENRICHMENT_SOURCE_IDENTITY;
                staged_ast_enrichment_seed = seed,
            ) for _ in 1:2
        ]

        emitted_values, production_emitted, production_emitted_identity =
            _julia_staged_enrichment_execute_emitted_production(
                production_compiled,
                JULIA_STAGED_ENRICHMENT_EMITTED_IDENTITY,
                seed,
            )
        @test production_emitted_identity ==
              JULIA_STAGED_ENRICHMENT_EMITTED_IDENTITY

        # Host authority must not start until the complete parent value exists.
        parent_failure_source = raw"""Top::
 /(x);/
 E { marker = parse_job(match_group(1), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "fail")); return(marker) }
"""
        _, parent_failure_compiled =
            _julia_staged_enrichment_compile(parent_failure_source)
        _julia_staged_enrichment_capture(() -> runtime_parse(
            LinkedSpecRuntimeEngine(
                parent_failure_compiled;
                staged_ast_enrichment_seed = seed,
            ),
            "x;",
        ))

        all_values = Any[
            native_values...,
            reconstructed_values...,
            generated_values...,
            emitted_values...,
        ]
        @test length(all_values) == 8
        @test all(value == first(all_values) for value in all_values)
        for value in all_values
            @test value["ast"] == Dict{String,Any}(
                "kind" => "expression",
                "text" => "1+2",
                "top_rule" => "Expr",
            )
            @test isempty(value["diagnostics"])
            @test length(value["sidecars"]) == 1
            @test only(value["sidecars"])["state"] == "succeeded"
            @test value["cache"]["entries"] == 1
            @test value["cache"]["hits"] == 0
            @test value["cache"]["misses"] == 1
            @test value["resources"]["total_calls"] == 1
        end

        @test length(observations["starts"]) == 8
        @test [row["run_id"] for row in observations["starts"]] == collect(1:8)
        @test [row["token"] for row in observations["starts"]] ==
              Any[Dict{String,Any}("run_id" => run_id) for run_id in 1:8]
        callback_binding_ids = Any[
            objectid(callback)
            for row in observations["starts"]
            for callback in row["callbacks"]
        ]
        @test length(callback_binding_ids) == 32
        @test length(unique(callback_binding_ids)) == 32
        @test length(observations["callbacks"]) == 8
        @test [row["run_id"] for row in observations["callbacks"]] == collect(1:8)
        @test all(row["text"] == "1+2" for row in observations["callbacks"])
        @test Set(row["run_id"] for row in observations["cancellation_checks"]) ==
              Set(1:8)
        @test Set(observations["clock_checks"]) == Set(1:8)

        detached_probe = deepcopy(first(all_values))
        detached_probe["ast"]["kind"] = "mutated"
        @test all(value["ast"]["kind"] == "expression" for value in all_values)

        logical_artifacts = String[
            JSON3.write(to_json(production_parsed)),
            JSON3.write(Any[
                Dict{String,Any}("label" => row.label, "family" => row.family)
                for row in generated_plan
            ]),
            production_emitted,
        ]
        for artifact in logical_artifacts
            for forbidden in [
                "authority_factory",
                "compiled_authorities",
                "recursive_authority",
                "cancellation_token",
                "mutable_queue",
                "run_id",
            ]
                @test !occursin(forbidden, artifact)
            end
        end

        failure_observations = Dict{String,Any}(
            "starts" => Any[],
            "callbacks" => Any[],
            "cancellation_checks" => Any[],
            "clock_checks" => Any[],
        )
        failure_seed = _julia_staged_enrichment_production_seed(
            failure_observations;
            failure = true,
        )
        native_failure = _julia_staged_enrichment_capture(() -> runtime_parse(
            LinkedSpecRuntimeEngine(
                production_compiled;
                staged_ast_enrichment_seed = failure_seed,
            ),
            "1+2;",
        ))
        generated_failure = _julia_staged_enrichment_capture(() ->
            execute_generated_parser_v2(
                production_compiled,
                generated_plan,
                "1+2;",
                JULIA_STAGED_ENRICHMENT_SOURCE_IDENTITY;
                staged_ast_enrichment_seed = failure_seed,
            ))
        @test _julia_staged_enrichment_error_code(native_failure) ==
              "staged_child_failed"
        @test _julia_staged_enrichment_error_code(generated_failure) ==
              "staged_child_failed"

        state = LinkedSpecJulia._start_staged_ast_enrichment(seed)
        transaction_error = _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._complete_staged_ast_enrichment!(
                state,
                raw_marker;
                transaction_active = true,
            ))
        @test _julia_staged_enrichment_error_code(transaction_error) ==
              "staged_transaction_forbidden"
        @test _julia_staged_enrichment_error_code(
            _julia_staged_enrichment_capture(() ->
                LinkedSpecJulia._complete_staged_ast_enrichment!(
                    state,
                    raw_marker;
                    transaction_active = false,
                )),
        ) == "staged_registry_snapshot_invalid"
    end

    @testset "neutral provenance accepts exact records and rejects smuggling" begin
        sources = Dict{String,String}(
            String(row["source_id"]) => String(row["text"])
            for row in JULIA_STAGED_ENRICHMENT_CONTRACT["sources"]
        )
        authority = LinkedSpecJulia.SourceLocation.SourceAuthority(
            sources = sources,
        )
        for row in JULIA_STAGED_ENRICHMENT_CONTRACT["provenance_cases"]
            if row["accepted"] == true
                result = LinkedSpecJulia.validate_and_materialize_staged_provenance(
                    authority = authority,
                    record = row["provenance"],
                    origin = "contract:parse_job",
                )
                @test result["text"] == row["materialized_text"]
                @test result["provenance"] == row["provenance"]
            else
                error = _julia_staged_enrichment_capture(
                    () -> LinkedSpecJulia.validate_and_materialize_staged_provenance(
                        authority = authority,
                        record = row["provenance"],
                        origin = "contract:parse_job",
                    ),
                )
                @test error isa LinkedSpecJulia.StagedParseJobDeclarationException
                if error isa LinkedSpecJulia.StagedParseJobDeclarationException
                    @test to_json(error)["code"] == row["diagnostic"]
                end
            end
        end
    end

    @testset "runtime materializes Unicode direct and ordered-derived spans" begin
        direct_source = raw"""Top::
 /(é🙂)(B);/
 E { marker = parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", "result_policy", "sibling_field", "into", "expression_ast", "on_error", "fail")); return(marker) }
"""
        _, direct_compiled = _julia_staged_enrichment_compile(direct_source)
        direct = runtime_parse(
            LinkedSpecRuntimeEngine(direct_compiled),
            "Aé🙂B;C",
        ).value
        direct_sidecar = direct["staged_parse_job_v2"]
        @test direct_sidecar["text"] == "é🙂"
        @test direct_sidecar["provenance"] == Dict{String,Any}(
            "kind" => "direct_span",
            "source_id" => "input",
            "start" => 1,
            "end" => 3,
            "provenance" => "match_group",
        )

        derived_source = raw"""Top::
 /(a)(a);/
 E { marker = parse_job(cat(match_group(0), match_group(1)), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "keep_text", "required_capabilities", array("typed-source-location-v1", "actionir-v1"))); return(marker) }
"""
        _, derived_compiled = _julia_staged_enrichment_compile(derived_source)
        derived = runtime_parse(
            LinkedSpecRuntimeEngine(derived_compiled),
            "aa;",
        ).value
        derived_sidecar = derived["staged_parse_job_v2"]
        @test derived_sidecar["text"] == "aa"
        @test derived_sidecar["required_capabilities"] == Any[
            "actionir-v1",
            "typed-source-location-v1",
        ]
        @test derived_sidecar["provenance"] == Dict{String,Any}(
            "kind" => "derived_text",
            "policy" => "concatenate_in_order",
            "segments" => Any[
                Dict{String,Any}(
                    "kind" => "direct_span",
                    "source_id" => "input",
                    "start" => 0,
                    "end" => 1,
                    "provenance" => "match_group",
                ),
                Dict{String,Any}(
                    "kind" => "direct_span",
                    "source_id" => "input",
                    "start" => 1,
                    "end" => 2,
                    "provenance" => "match_group",
                ),
            ],
        )
        @test isempty(_julia_staged_enrichment_forbidden_key_hits(derived))

        out_of_range_source = raw"""Top::
 /(x);/
 E { marker = parse_job(match_group(1), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "fail")); return(marker) }
"""
        _, out_of_range_compiled =
            _julia_staged_enrichment_compile(out_of_range_source)
        error = _julia_staged_enrichment_capture(
            () -> runtime_parse(
                LinkedSpecRuntimeEngine(out_of_range_compiled),
                "x;",
            ),
        )
        @test error isa RuntimeInterpreterException
        @test occursin(
            "staged_source_provenance_invalid",
            sprint(showerror, error),
        )
    end

    @testset "invalid annotations and recognition-reachable markers fail closed" begin
        valid_options =
            "hash(\"node_kind\", \"expression\", \"payload_kind\", " *
            "\"embedded_expression\", \"spec\", \"expr-v1\", " *
            "\"result_policy\", \"replace_marker\", \"on_error\", \"fail\")"
        invalid_forms = [
            (
                "parse_job(match_group(0), options)",
                "staged_parse_job_options_required",
            ),
            (
                "parse_job(match_group(0), hash(\"node_kind\", \"expression\", " *
                "\"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", " *
                "\"result_policy\", \"replace_marker\", \"on_error\", \"fail\", " *
                "\"loader\", \"ambient\"))",
                "staged_parse_job_option_unknown",
            ),
            (
                "parse_job(match_group(0), hash(\"node_kind\", \"expression\", " *
                "\"node_kind\", \"expression\", \"payload_kind\", " *
                "\"embedded_expression\", \"spec\", \"expr-v1\", " *
                "\"result_policy\", \"replace_marker\", \"on_error\", \"fail\"))",
                "staged_parse_job_options_required",
            ),
            (
                "parse_job(match_group(0), hash(\"node_kind\", \"expression\", " *
                "\"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", " *
                "\"result_policy\", \"replace_marker\"))",
                "staged_parse_job_options_required",
            ),
            (
                "parse_job(match_group(0), hash(\"node_kind\", node_kind, " *
                "\"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", " *
                "\"result_policy\", \"replace_marker\", \"on_error\", \"fail\"))",
                "staged_parse_job_options_required",
            ),
            (
                "parse_job(trim(match_group(0)), $valid_options)",
                "staged_source_provenance_invalid",
            ),
            (
                "parse_job(\"copied\", $valid_options)",
                "staged_source_provenance_invalid",
            ),
            (
                "parse_job(match_group(index), $valid_options)",
                "staged_source_provenance_invalid",
            ),
            (
                "parse_job(match_group(0), hash(\"node_kind\", \"expression\", " *
                "\"payload_kind\", \"embedded_expression\", \"spec\", \"../expr\", " *
                "\"result_policy\", \"replace_marker\", \"on_error\", \"fail\"))",
                "staged_parser_identity_invalid",
            ),
            (
                "parse_job(match_group(0), hash(\"node_kind\", \"expression\", " *
                "\"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", " *
                "\"top\", \"Expr/Bad\", \"result_policy\", \"replace_marker\", " *
                "\"on_error\", \"fail\"))",
                "staged_top_rule_invalid",
            ),
            (
                "parse_job(match_group(0), hash(\"node_kind\", \"expression\", " *
                "\"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", " *
                "\"result_policy\", \"replace\", \"on_error\", \"fail\"))",
                "staged_result_policy_invalid",
            ),
            (
                "parse_job(match_group(0), hash(\"node_kind\", \"expression\", " *
                "\"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", " *
                "\"result_policy\", \"replace_marker\", \"on_error\", \"retry\"))",
                "staged_failure_policy_invalid",
            ),
            (
                "parse_job(match_group(0), hash(\"node_kind\", \"expression\", " *
                "\"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", " *
                "\"result_policy\", \"replace_marker\", \"into\", \"wrong\", " *
                "\"on_error\", \"fail\"))",
                "staged_result_target_invalid",
            ),
            (
                "parse_job(match_group(0), hash(\"node_kind\", \"expression\", " *
                "\"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", " *
                "\"result_policy\", \"sibling_field\", \"on_error\", \"fail\"))",
                "staged_result_target_invalid",
            ),
            (
                "parse_job(match_group(0), hash(\"node_kind\", \"expression\", " *
                "\"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", " *
                "\"result_policy\", \"replace_marker\", \"on_error\", \"fail\", " *
                "\"required_capabilities\", array(\"actionir-v1\", \"actionir-v1\")))",
                "staged_parse_job_options_required",
            ),
        ]
        for (call, code) in invalid_forms
            source = "Top::\n /(x);/\n E { marker = $call; return(marker) }\n"
            error = _julia_staged_enrichment_capture(
                () -> _julia_staged_enrichment_compile(source),
            )
            @test error !== nothing
            @test occursin(code, sprint(showerror, error))
        end

        residual_forms = [
            "return(parse_job(match_group(0), $valid_options))",
            "marker += parse_job(match_group(0), $valid_options)",
            "markers[\"one\"] = parse_job(match_group(0), $valid_options)",
            "marker = source.parse_job(match_group(0), $valid_options)",
        ]
        for residual in residual_forms
            source = "Top::\n /(x);/\n E { $residual }\n"
            residual_error = _julia_staged_enrichment_capture(
                () -> _julia_staged_enrichment_compile(source),
            )
            @test residual_error !== nothing
            @test occursin(
                "staged_parse_job_options_required",
                sprint(showerror, residual_error),
            )
        end

        transaction_source = raw"""Top:: I { tx = recognition_checkpoint(); matched = recognize_once(tx, call(Child)); recognition_rollback(tx); return(matched) }
Child:: I { marker = parse_job(entry_text(), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "fail")); return(marker) } /never/"""
        transaction_error = _julia_staged_enrichment_capture(
            () -> _julia_staged_enrichment_compile(transaction_source),
        )
        @test transaction_error !== nothing
        @test occursin(
            "recognition_effect_forbidden:parser_registry_or_staged_dispatch",
            sprint(showerror, transaction_error),
        )
    end

    @testset "caller-frozen registry resolves and narrows without ambient authority" begin
        inert = (_request, _context) ->
            LinkedSpecJulia._staged_child_success(Dict{String,Any}("kind" => "ok"))
        registry = _julia_staged_enrichment_registry(inert)

        @test fieldnames(typeof(registry)) == (
            :aliases,
            :declaring_relative,
            :search_roots,
            :providers,
            :entries,
            :snapshot_id,
            :cache,
        )
        @test startswith(registry.snapshot_id, "registry-snapshot:sha256:")
        @test registry.entries isa Tuple
        @test all(entry.allowed_top_rules isa Tuple for entry in registry.entries)
        @test all(entry.capabilities isa Tuple for entry in registry.entries)
        @test all(entry.policy_modes isa Tuple for entry in registry.entries)
        @test LinkedSpecJulia._staged_cache_stats(registry) == Dict{String,Any}(
            "snapshot_id" => registry.snapshot_id,
            "entries" => 0,
            "hits" => 0,
            "misses" => 0,
        )

        for row in JULIA_STAGED_ENRICHMENT_CONTRACT["resolution_cases"]
            result = _julia_staged_enrichment_capture(() ->
                LinkedSpecJulia._resolve_staged_pre_registered(
                    registry;
                    declaring_spec_id = row["declaring_spec_id"],
                    parser_spec_id = row["parser_spec_id"],
                    job_id = "contract:resolution",
                ))
            if row["diagnostic"] === nothing
                @test result === nothing
                @test LinkedSpecJulia._resolve_staged_pre_registered(
                    registry;
                    declaring_spec_id = row["declaring_spec_id"],
                    parser_spec_id = row["parser_spec_id"],
                    job_id = "contract:resolution",
                ) == row["resolved_spec_id"]
            else
                @test _julia_staged_enrichment_error_code(result) == row["diagnostic"]
                @test _julia_staged_enrichment_diagnostic_is_complete(result)
            end
        end

        for row in JULIA_STAGED_ENRICHMENT_CONTRACT["authority_cases"]
            result = try
                LinkedSpecJulia._evaluate_staged_authority_case(
                    registry,
                    row;
                    job_id = "contract:authority",
                )
            catch error
                error
            end
            if row["accepted"] == true
                @test result == row["effective"]
            else
                @test _julia_staged_enrichment_error_code(result) == row["diagnostic"]
                @test _julia_staged_enrichment_diagnostic_is_complete(result)
            end
        end
        forbidden_top = deepcopy(JULIA_STAGED_ENRICHMENT_CONTRACT["authority_cases"][1])
        forbidden_top["top_rule"] = "MissingTop"
        top_error = _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._evaluate_staged_authority_case(
                registry,
                forbidden_top;
                job_id = "contract:forbidden-top",
            ))
        @test _julia_staged_enrichment_error_code(top_error) ==
              "staged_top_rule_forbidden"
        @test _julia_staged_enrichment_diagnostic_is_complete(top_error)

        snapshot_copy = deepcopy(
            JULIA_STAGED_ENRICHMENT_CONTRACT["resolution_snapshot"],
        )
        callbacks = Dict{String,Function}(
            String(entry["compiled_authority"]) => inert
            for entry in snapshot_copy["entries"]
        )
        isolated = LinkedSpecJulia._freeze_staged_registry(snapshot_copy, callbacks)
        snapshot_copy["aliases"][1]["resolved_spec_id"] = "registry:yaml-v1"
        @test LinkedSpecJulia._resolve_staged_pre_registered(
            isolated;
            declaring_spec_id = "grammar/main.spec",
            parser_spec_id = "expr",
            job_id = "contract:immutable",
        ) == "registry:expr-v2"

        malformed_snapshots = Any[]
        for (field, value) in [
            ("immutable", false),
            ("prepared_before_authored_execution", false),
            ("filesystem_access_during_dispatch", true),
        ]
            malformed = deepcopy(
                JULIA_STAGED_ENRICHMENT_CONTRACT["resolution_snapshot"],
            )
            malformed[field] = value
            push!(malformed_snapshots, malformed)
        end
        bad_digest = deepcopy(
            JULIA_STAGED_ENRICHMENT_CONTRACT["resolution_snapshot"],
        )
        bad_digest["entries"][1]["content_digest"] = "sha256:not-a-digest"
        push!(malformed_snapshots, bad_digest)
        bad_default = deepcopy(
            JULIA_STAGED_ENRICHMENT_CONTRACT["resolution_snapshot"],
        )
        bad_default["entries"][1]["default_top_rule"] = "MissingTop"
        push!(malformed_snapshots, bad_default)
        duplicate_order = deepcopy(
            JULIA_STAGED_ENRICHMENT_CONTRACT["resolution_snapshot"],
        )
        duplicate_order["search_roots"][2]["order"] = 1
        push!(malformed_snapshots, duplicate_order)
        for malformed in malformed_snapshots
            error = _julia_staged_enrichment_capture(() ->
                LinkedSpecJulia._freeze_staged_registry(malformed, callbacks))
            @test _julia_staged_enrichment_error_code(error) ==
                  "staged_registry_snapshot_invalid"
        end
        missing_callback = copy(callbacks)
        delete!(missing_callback, first(keys(missing_callback)))
        missing_callback_error = _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._freeze_staged_registry(
                JULIA_STAGED_ENRICHMENT_CONTRACT["resolution_snapshot"],
                missing_callback,
            ))
        @test _julia_staged_enrichment_error_code(missing_callback_error) ==
              "staged_registry_snapshot_invalid"
        extra_callback = copy(callbacks)
        extra_callback["opaque:compiled:extra"] = inert
        extra_callback_error = _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._freeze_staged_registry(
                JULIA_STAGED_ENRICHMENT_CONTRACT["resolution_snapshot"],
                extra_callback,
            ))
        @test _julia_staged_enrichment_error_code(extra_callback_error) ==
              "staged_registry_snapshot_invalid"
    end

    @testset "job, cache, and typed current-depth order identities are exact" begin
        for row in JULIA_STAGED_ENRICHMENT_CONTRACT["job_id_cases"]
            fields = deepcopy(row)
            delete!(fields, "id")
            expected = pop!(fields, "expected_job_id")
            @test LinkedSpecJulia._staged_job_identity(fields) == expected
        end

        base_key = nothing
        for row in JULIA_STAGED_ENRICHMENT_CONTRACT["cache_cases"]
            key = LinkedSpecJulia._staged_cache_identity(row["fields"])
            row["id"] == "base" && (base_key = key)
            @test (key == base_key) == row["same_as_base"]
        end
        @test base_key isa String
        @test startswith(base_key, "sha256:")
        malformed_cache = deepcopy(
            JULIA_STAGED_ENRICHMENT_CONTRACT["cache_cases"][1]["fields"],
        )
        malformed_cache["ambient_loader"] = true
        cache_error = _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._staged_cache_identity(malformed_cache))
        @test _julia_staged_enrichment_error_code(cache_error) ==
              "staged_cache_identity_invalid"
        @test _julia_staged_enrichment_diagnostic_is_complete(cache_error)

        for row in JULIA_STAGED_ENRICHMENT_CONTRACT["queue_cases"]
            @test LinkedSpecJulia._staged_current_depth_order(row["jobs"]) ==
                  row["expected_order"]
        end
    end

    @testset "all result and failure policies stitch detached values atomically" begin
        for row in JULIA_STAGED_ENRICHMENT_CONTRACT["stitch_cases"]
            result = deepcopy(row["result"])
            callback = (_request, _context) ->
                LinkedSpecJulia._staged_child_success(deepcopy(result))
            registry = _julia_staged_enrichment_registry(callback)
            parent = deepcopy(row["parent"])
            parent[row["marker_field"]] = _julia_staged_enrichment_marker(
                row["text"],
                0,
                row["result_policy"],
                row["into"],
                "fail",
            )
            outcome = LinkedSpecJulia._enrich_staged_current_depth(
                registry,
                parent,
                _julia_staged_enrichment_options(),
            )
            @test outcome.ast == row["expected_parent"]
            @test isempty(outcome.diagnostics)
            @test only(outcome.sidecars)["state"] == "succeeded"
        end

        for row in JULIA_STAGED_ENRICHMENT_CONTRACT["failure_cases"]
            callback = (_request, _context) ->
                LinkedSpecJulia._staged_child_failure(Dict{String,Any}(
                    "code" => "child_parse_error",
                    "offset" => 1,
                ))
            registry = _julia_staged_enrichment_registry(callback)
            parent = deepcopy(row["parent"])
            parent[row["marker_field"]] = _julia_staged_enrichment_marker(
                row["text"],
                0,
                row["result_policy"],
                row["into"],
                row["failure_policy"],
            )
            result = try
                LinkedSpecJulia._enrich_staged_current_depth(
                    registry,
                    parent,
                    _julia_staged_enrichment_options(),
                )
            catch error
                error
            end
            if row["failure_policy"] == "fail"
                @test _julia_staged_enrichment_error_code(result) ==
                      "staged_child_failed"
                @test _julia_staged_enrichment_diagnostic_is_complete(result)
                @test parent[row["marker_field"]]["kind"] ==
                      "STAGED_PARSE_JOB_MARKER"
            elseif row["failure_policy"] == "keep_text"
                @test result.ast[row["marker_field"]] == row["text"]
                @test result.ast["children"] == Any[]
                @test length(result.diagnostics) == 1
                @test only(result.sidecars)["state"] == "failed_keep_text"
            else
                @test result.ast[row["marker_field"]] == row["text"]
                @test result.ast["ast"]["kind"] == "staged_parse_diagnostic"
                @test result.ast["ast"]["diagnostic"] ==
                      only(result.diagnostics)
                @test only(result.sidecars)["state"] ==
                      "failed_diagnostic_node"
                required = only([
                    diagnostic["required_context"]
                    for diagnostic in JULIA_STAGED_ENRICHMENT_CONTRACT["diagnostics"]
                    if diagnostic["code"] == "staged_child_failed"
                ])
                for field in required
                    @test haskey(only(result.diagnostics), field)
                end
            end
        end
    end

    @testset "complete-depth preflight, sibling isolation, and cache lifecycle are exact" begin
        contexts = Dict{String,Any}[]
        order = String[]
        callback_count = Ref(0)
        callback = function(request, context)
            push!(contexts, LinkedSpecJulia._staged_runtime_context_record(context))
            push!(order, String(request["text"]))
            callback_count[] += 1
            context.cursor = 9
            context.marks["child"] = 1
            context.captures["capture"] = "local"
            context.variables["variable"] = true
            return LinkedSpecJulia._staged_child_success(Dict{String,Any}(
                "kind" => "parsed",
                "text" => request["text"],
            ))
        end
        registry = _julia_staged_enrichment_registry(callback)
        ordered_ast = Dict{String,Any}(
            "nodes" => Any[
                Dict{String,Any}(
                    "payload" => _julia_staged_enrichment_marker(
                        "first",
                        4,
                        "replace_marker",
                        nothing,
                        "fail",
                    ),
                ),
                Dict{String,Any}(
                    "payload" => _julia_staged_enrichment_marker(
                        "second",
                        1,
                        "replace_marker",
                        nothing,
                        "fail",
                    ),
                ),
            ],
        )
        first = LinkedSpecJulia._enrich_staged_current_depth(
            registry,
            ordered_ast,
            _julia_staged_enrichment_options(),
        )
        @test order == ["first", "second"]
        @test contexts == [
            Dict{String,Any}(
                "cursor" => 0,
                "marks" => Dict{String,Any}(),
                "captures" => Dict{String,Any}(),
                "variables" => Dict{String,Any}(),
            ),
            Dict{String,Any}(
                "cursor" => 0,
                "marks" => Dict{String,Any}(),
                "captures" => Dict{String,Any}(),
                "variables" => Dict{String,Any}(),
            ),
        ]
        @test first.cache["entries"] == 1
        @test first.cache["misses"] == 1
        @test first.cache["hits"] == 1
        second = LinkedSpecJulia._enrich_staged_current_depth(
            registry,
            ordered_ast,
            _julia_staged_enrichment_options(),
        )
        @test second.cache["entries"] == 1
        @test second.cache["misses"] == 1
        @test second.cache["hits"] == 3
        @test callback_count[] == 4
        @test ordered_ast["nodes"][1]["payload"]["kind"] ==
              "STAGED_PARSE_JOB_MARKER"

        isolated_registry = _julia_staged_enrichment_registry(callback)
        @test LinkedSpecJulia._staged_cache_stats(isolated_registry)["entries"] == 0
        @test LinkedSpecJulia._staged_cache_stats(isolated_registry)["hits"] == 0
        @test LinkedSpecJulia._staged_cache_stats(isolated_registry)["misses"] == 0
        @test fieldnames(LinkedSpecJulia._StagedCachedPlan) == (
            :compiled_authority,
            :resolved_spec_id,
            :top_rule,
            :effective_capabilities,
        )

        default_registry = _julia_staged_enrichment_registry(
            (_request, _context) -> LinkedSpecJulia._staged_child_success(
                Dict{String,Any}("kind" => "expr"),
            ),
        )
        default_marker = _julia_staged_enrichment_marker(
            "x",
            0,
            "replace_marker",
            nothing,
            "fail";
            top_rule = nothing,
        )
        default_outcome = LinkedSpecJulia._enrich_staged_current_depth(
            default_registry,
            Dict{String,Any}("payload" => default_marker),
            _julia_staged_enrichment_options(),
        )
        @test only(default_outcome.sidecars)["top_rule"] == "Expr"
        @test only(default_outcome.sidecars)["job_id"] ==
              LinkedSpecJulia._staged_job_identity(Dict{String,Any}(
                  "declaring_spec_id" => "grammar/main.spec",
                  "parent_ast_path" => Any["payload"],
                  "node_kind" => "expression",
                  "payload_kind" => "embedded_expression",
                  "parser_spec_id" => "expr",
                  "top_rule" => "Expr",
                  "provenance" => Dict{String,Any}(
                      "kind" => "direct_span",
                      "source_id" => "ascii",
                      "start" => 0,
                      "end" => 1,
                      "provenance" => "capture",
                  ),
              ))
    end

    @testset "invalid depths reject before publication and returned markers stay inert" begin
        invalid_callback_count = Ref(0)
        invalid_registry = _julia_staged_enrichment_registry(
            function(_request, _context)
                invalid_callback_count[] += 1
                return LinkedSpecJulia._staged_child_success(
                    Dict{String,Any}("kind" => "unexpected"),
                )
            end,
        )
        invalid_asts = [
            Dict{String,Any}(
                "payload" => _julia_staged_enrichment_marker(
                    "x",
                    0,
                    "sibling_field",
                    "ast",
                    "fail",
                ),
                "ast" => Dict{String,Any}("kind" => "occupied"),
            ) => "staged_stitch_target_collision",
            Dict{String,Any}(
                "payload" => _julia_staged_enrichment_marker(
                    "x",
                    0,
                    "append_child",
                    "children",
                    "fail",
                ),
                "children" => Dict{String,Any}(),
            ) => "staged_append_target_invalid",
            Dict{String,Any}(
                "payload" => _julia_staged_enrichment_marker(
                    "x",
                    0,
                    "sibling_field",
                    nothing,
                    "fail",
                ),
            ) => "staged_stitch_target_missing",
            Dict{String,Any}(
                "payload" => _julia_staged_enrichment_marker(
                    "x",
                    0,
                    "replace_field",
                    "ast",
                    "fail",
                ),
            ) => "staged_stitch_target_missing",
        ]
        for (ast, code) in invalid_asts
            error = _julia_staged_enrichment_capture(() ->
                LinkedSpecJulia._enrich_staged_current_depth(
                    invalid_registry,
                    ast,
                    _julia_staged_enrichment_options(),
                ))
            @test _julia_staged_enrichment_error_code(error) == code
            @test _julia_staged_enrichment_diagnostic_is_complete(error)
        end
        @test invalid_callback_count[] == 0

        unresolved = _julia_staged_enrichment_marker(
            "x",
            0,
            "replace_marker",
            nothing,
            "fail",
        )
        unresolved["staged_parse_job_v2"]["parser_spec_id"] = "missing-v1"
        unresolved_error = _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._enrich_staged_current_depth(
                invalid_registry,
                Dict{String,Any}("payload" => unresolved),
                _julia_staged_enrichment_options(),
            ))
        @test _julia_staged_enrichment_error_code(unresolved_error) ==
              "staged_registry_missing"
        @test _julia_staged_enrichment_diagnostic_is_complete(unresolved_error)
        @test LinkedSpecJulia._staged_cache_stats(invalid_registry)["entries"] == 0
        @test invalid_callback_count[] == 0

        atomic_input = Dict{String,Any}(
            "nodes" => Any[
                Dict{String,Any}(
                    "payload" => _julia_staged_enrichment_marker(
                        "ok",
                        0,
                        "replace_marker",
                        nothing,
                        "fail",
                    ),
                ),
                Dict{String,Any}(
                    "payload" => _julia_staged_enrichment_marker(
                        "bad",
                        2,
                        "replace_marker",
                        nothing,
                        "fail",
                    ),
                ),
            ],
        )
        atomic_registry = _julia_staged_enrichment_registry(
            (request, _context) -> request["text"] == "bad" ?
                LinkedSpecJulia._staged_child_failure(
                    Dict{String,Any}("code" => "expected_failure"),
                ) : LinkedSpecJulia._staged_child_success(
                    Dict{String,Any}("kind" => "first_result"),
                ),
        )
        atomic_error = _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._enrich_staged_current_depth(
                atomic_registry,
                atomic_input,
                _julia_staged_enrichment_options(),
            ))
        @test _julia_staged_enrichment_error_code(atomic_error) ==
              "staged_child_failed"
        @test _julia_staged_enrichment_diagnostic_is_complete(atomic_error)
        @test atomic_input["nodes"][1]["payload"]["kind"] ==
              "STAGED_PARSE_JOB_MARKER"

        stale_count = Ref(0)
        stale_registry = _julia_staged_enrichment_registry(
            function(_request, _context)
                stale_count[] += 1
                return LinkedSpecJulia._staged_child_success(
                    Dict{String,Any}("kind" => "replacement"),
                )
            end,
        )
        stale = Dict{String,Any}(
            "control" => _julia_staged_enrichment_marker(
                "first",
                0,
                "replace_field",
                "payload",
                "fail",
            ),
            "payload" => _julia_staged_enrichment_marker(
                "second",
                6,
                "replace_marker",
                nothing,
                "fail",
            ),
        )
        stale_error = _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._enrich_staged_current_depth(
                stale_registry,
                stale,
                _julia_staged_enrichment_options(),
            ))
        @test _julia_staged_enrichment_error_code(stale_error) ==
              "staged_stitch_target_collision"
        @test _julia_staged_enrichment_diagnostic_is_complete(stale_error)
        @test stale_count[] == 0
        @test stale["control"]["kind"] == "STAGED_PARSE_JOB_MARKER"

        stale_working = LinkedSpecJulia._staged_copy_ast(Dict{String,Any}(
            "payload" => _julia_staged_enrichment_marker(
                "stale",
                0,
                "replace_marker",
                nothing,
                "fail",
            ),
        ))
        stale_discovered = LinkedSpecJulia._StagedDiscoveredMarker[]
        LinkedSpecJulia._staged_discover_markers!(
            stale_working,
            Any[],
            stale_discovered,
        )
        stale_plan = LinkedSpecJulia._staged_prepare_plan(
            stale_registry,
            only(stale_discovered),
            LinkedSpecJulia._parse_staged_enrichment_options(
                _julia_staged_enrichment_options(),
            ),
        )
        stale_working["payload"] = "already-changed"
        marker_error = _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._staged_validate_stitch_target(
                stale_working,
                stale_plan,
            ))
        @test _julia_staged_enrichment_error_code(marker_error) ==
              "staged_marker_mismatch"
        @test haskey(to_json(marker_error), "actual_marker")
        @test _julia_staged_enrichment_diagnostic_is_complete(marker_error)

        nested_calls = Ref(0)
        nested_marker = _julia_staged_enrichment_marker(
            "nested",
            1,
            "replace_marker",
            nothing,
            "fail",
        )
        nested_registry = _julia_staged_enrichment_registry(
            function(_request, _context)
                nested_calls[] += 1
                return LinkedSpecJulia._staged_child_success(deepcopy(nested_marker))
            end,
        )
        nested = LinkedSpecJulia._enrich_staged_current_depth(
            nested_registry,
            Dict{String,Any}(
                "payload" => _julia_staged_enrichment_marker(
                    "outer",
                    0,
                    "replace_marker",
                    nothing,
                    "fail",
                ),
            ),
            _julia_staged_enrichment_options(),
        )
        @test nested.ast["payload"]["kind"] == "STAGED_PARSE_JOB_MARKER"
        nested_marker["callback"] = "opaque:live"
        smuggled_marker = try
            LinkedSpecJulia._enrich_staged_current_depth(
                nested_registry,
                Dict{String,Any}(
                    "payload" => _julia_staged_enrichment_marker(
                        "outer-smuggled",
                        0,
                        "replace_marker",
                        nothing,
                        "fail",
                    ),
                ),
                _julia_staged_enrichment_options(),
            )
        catch error
            error
        end
        @test nested_calls[] == 2 &&
              _julia_staged_enrichment_error_code(smuggled_marker) ==
              "staged_result_not_detached"
    end

    @testset "plain-result detachment is finite, acyclic, and node-bounded" begin
        for row in JULIA_STAGED_ENRICHMENT_CONTRACT["detachment_cases"]
            callback = (_request, _context) ->
                LinkedSpecJulia._staged_child_success(deepcopy(row["value"]))
            registry = _julia_staged_enrichment_registry(callback)
            options = _julia_staged_enrichment_options()
            options["caller_ceilings"]["max_result_nodes"] = row["max_nodes"]
            result = try
                LinkedSpecJulia._enrich_staged_current_depth(
                    registry,
                    Dict{String,Any}(
                        "payload" => _julia_staged_enrichment_marker(
                            "x",
                            0,
                            "replace_marker",
                            nothing,
                            "fail",
                        ),
                    ),
                    options,
                )
            catch error
                error
            end
            if row["accepted"] == true
                @test result.ast["payload"] == row["value"]
            else
                @test _julia_staged_enrichment_error_code(result) == row["diagnostic"]
                @test _julia_staged_enrichment_diagnostic_is_complete(result)
            end

            direct = try
                LinkedSpecJulia._staged_detach_plain(
                    deepcopy(row["value"]);
                    maximum = row["max_nodes"],
                )
            catch error
                error
            end
            if row["accepted"] == true
                @test direct.nodes == row["visited_nodes"]
                @test direct.value == row["value"]
            else
                @test direct isa LinkedSpecJulia._StagedDetachFailure
                direct isa LinkedSpecJulia._StagedDetachFailure || continue
                @test direct.nodes == row["visited_nodes"]
            end
        end

        cyclic = Any[]
        push!(cyclic, cyclic)
        cycle_registry = _julia_staged_enrichment_registry(
            (_request, _context) -> LinkedSpecJulia._staged_child_success(cyclic),
        )
        cycle_error = _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._enrich_staged_current_depth(
                cycle_registry,
                Dict{String,Any}(
                    "payload" => _julia_staged_enrichment_marker(
                        "x",
                        0,
                        "replace_marker",
                        nothing,
                        "fail",
                    ),
                ),
                _julia_staged_enrichment_options(),
            ))
        @test _julia_staged_enrichment_error_code(cycle_error) ==
              "staged_result_not_detached"
        @test _julia_staged_enrichment_diagnostic_is_complete(cycle_error)

        failure_calls = Ref(0)
        failure_registry = _julia_staged_enrichment_registry(
            function(_request, _context)
                failure_calls[] += 1
                return LinkedSpecJulia._staged_child_failure(
                    Dict{String,Any}("code" => "repeatable_failure"),
                )
            end,
        )
        failing_ast = Dict{String,Any}(
            "payload" => _julia_staged_enrichment_marker(
                "bad",
                0,
                "replace_marker",
                nothing,
                "fail",
            ),
        )
        for _ in 1:2
            @test _julia_staged_enrichment_capture(() ->
                LinkedSpecJulia._enrich_staged_current_depth(
                    failure_registry,
                    failing_ast,
                    _julia_staged_enrichment_options(),
                )) isa LinkedSpecJulia.StagedAstEnrichmentException
        end
        @test failure_calls[] == 2
        @test LinkedSpecJulia._staged_cache_stats(failure_registry)["entries"] == 1
        @test LinkedSpecJulia._staged_cache_stats(failure_registry)["misses"] == 1
        @test LinkedSpecJulia._staged_cache_stats(failure_registry)["hits"] == 1

        fail_first = Ref(true)
        recovery_calls = Ref(0)
        recovery_registry = _julia_staged_enrichment_registry(
            function(_request, _context)
                recovery_calls[] += 1
                if fail_first[]
                    fail_first[] = false
                    return LinkedSpecJulia._staged_child_failure(
                        Dict{String,Any}("code" => "first_attempt_failed"),
                    )
                end
                return LinkedSpecJulia._staged_child_success(
                    Dict{String,Any}("kind" => "fresh"),
                )
            end,
        )
        @test _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._enrich_staged_current_depth(
                recovery_registry,
                failing_ast,
                _julia_staged_enrichment_options(),
            )) isa LinkedSpecJulia.StagedAstEnrichmentException
        recovered = LinkedSpecJulia._enrich_staged_current_depth(
            recovery_registry,
            failing_ast,
            _julia_staged_enrichment_options(),
        )
        @test recovered.ast["payload"] == Dict{String,Any}("kind" => "fresh")
        @test recovery_calls[] == 2
        @test recovered.cache["entries"] == 1
        @test recovered.cache["misses"] == 1
        @test recovered.cache["hits"] == 1

        thrown_registry = _julia_staged_enrichment_registry(
            (_request, _context) -> error("contained child exception"),
        )
        thrown = LinkedSpecJulia._enrich_staged_current_depth(
            thrown_registry,
            Dict{String,Any}(
                "payload" => _julia_staged_enrichment_marker(
                    "panic",
                    0,
                    "replace_marker",
                    nothing,
                    "keep_text",
                ),
            ),
            _julia_staged_enrichment_options(),
        )
        @test thrown.ast["payload"] == "panic"
        @test only(thrown.diagnostics)["child_diagnostic"]["code"] ==
              "staged_child_exception"
    end

    @testset "consumer is admitted exactly once without outward leakage" begin
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
        @test count(
            "include(\"staged_ast_enrichment_contract_test.jl\")",
            ordinary,
        ) == 1
        @test count(
            "require_tracked_file " * JULIA_STAGED_ENRICHMENT_CONSUMER,
            canonical,
        ) == 1
        @test count(
            "running exact Julia staged-AST enrichment admission consumer",
            canonical,
        ) == 1
        @test count(
            "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no " *
            JULIA_STAGED_ENRICHMENT_CONSUMER,
            canonical,
        ) == 1
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

    @testset "recursive breadth-first authority shares exact lineage and resources" begin
        for row in JULIA_STAGED_ENRICHMENT_CONTRACT["chain_cases"]
            actual = LinkedSpecJulia._evaluate_staged_chain_case(row)
            @test actual["accepted"] == row["accepted"]
            @test actual["diagnostic"] == row["diagnostic"]
        end

        observed = Dict{String,Any}[]
        cancellation_tokens = Any[]
        retained_context = Ref{Any}(nothing)
        recursive_registry = _julia_staged_enrichment_registry(
            function(request, context)
                push!(observed, Dict{String,Any}(
                    "depth" => request["stage_depth"],
                    "text" => request["text"],
                    "stage_chain_length" => length(request["stage_chain"]),
                    "context" => LinkedSpecJulia._staged_runtime_context_record(context),
                    "token" => LinkedSpecJulia._staged_cancellation_token(context),
                    "deadline" => LinkedSpecJulia._staged_deadline(context),
                    "remaining_before" => LinkedSpecJulia._staged_remaining_steps(context),
                ))
                retained_context[] === nothing && (retained_context[] = context)
                LinkedSpecJulia._staged_safe_point(context, 1)
                context.cursor = request["stage_depth"]
                context.marks["child"] = request["text"]
                result = if request["text"] == "abcdef"
                    Dict{String,Any}(
                        "kind" => "branch",
                        "child" => _julia_staged_enrichment_marker(
                            "bc", 1, "replace_marker", nothing, "fail",
                        ),
                    )
                elseif request["text"] == "ghijkl"
                    Dict{String,Any}(
                        "kind" => "branch",
                        "child" => _julia_staged_enrichment_marker(
                            "hi", 7, "replace_marker", nothing, "fail",
                        ),
                    )
                else
                    Dict{String,Any}(
                        "kind" => "leaf",
                        "text" => request["text"],
                    )
                end
                return LinkedSpecJulia._staged_child_success(result)
            end,
        )
        recursive_authority = _julia_staged_enrichment_recursive_authority(
            token = "cancel:shared",
            cancelled = token -> begin
                push!(cancellation_tokens, deepcopy(token))
                false
            end,
        )
        recursive_input = Dict{String,Any}(
            "nodes" => Any[
                Dict{String,Any}(
                    "payload" => _julia_staged_enrichment_marker(
                        "abcdef", 0, "replace_marker", nothing, "fail",
                    ),
                ),
                Dict{String,Any}(
                    "payload" => _julia_staged_enrichment_marker(
                        "ghijkl", 6, "replace_marker", nothing, "fail",
                    ),
                ),
            ],
        )
        recursive = LinkedSpecJulia._enrich_staged_recursively(
            recursive_registry,
            recursive_input,
            _julia_staged_enrichment_options(),
            recursive_authority,
        )
        @test observed == Dict{String,Any}[
            Dict(
                "depth" => 1,
                "text" => "abcdef",
                "stage_chain_length" => 1,
                "context" => Dict(
                    "cursor" => 0,
                    "marks" => Dict{String,Any}(),
                    "captures" => Dict{String,Any}(),
                    "variables" => Dict{String,Any}(),
                ),
                "token" => "cancel:shared",
                "deadline" => 100,
                "remaining_before" => 19,
            ),
            Dict(
                "depth" => 1,
                "text" => "ghijkl",
                "stage_chain_length" => 1,
                "context" => Dict(
                    "cursor" => 0,
                    "marks" => Dict{String,Any}(),
                    "captures" => Dict{String,Any}(),
                    "variables" => Dict{String,Any}(),
                ),
                "token" => "cancel:shared",
                "deadline" => 100,
                "remaining_before" => 17,
            ),
            Dict(
                "depth" => 2,
                "text" => "bc",
                "stage_chain_length" => 2,
                "context" => Dict(
                    "cursor" => 0,
                    "marks" => Dict{String,Any}(),
                    "captures" => Dict{String,Any}(),
                    "variables" => Dict{String,Any}(),
                ),
                "token" => "cancel:shared",
                "deadline" => 100,
                "remaining_before" => 15,
            ),
            Dict(
                "depth" => 2,
                "text" => "hi",
                "stage_chain_length" => 2,
                "context" => Dict(
                    "cursor" => 0,
                    "marks" => Dict{String,Any}(),
                    "captures" => Dict{String,Any}(),
                    "variables" => Dict{String,Any}(),
                ),
                "token" => "cancel:shared",
                "deadline" => 100,
                "remaining_before" => 13,
            ),
        ]
        @test all(token == "cancel:shared" for token in cancellation_tokens)
        @test [row["stage_depth"] for row in recursive.sidecars] == [1, 1, 2, 2]
        @test [length(row["stage_chain"]) for row in recursive.sidecars] == [0, 0, 1, 1]
        @test recursive.ast["nodes"][1]["payload"]["child"]["kind"] == "leaf"
        @test recursive.ast["nodes"][2]["payload"]["child"]["text"] == "hi"
        @test recursive.resources.remaining_steps == 12
        @test recursive.resources.total_calls == 4
        @test recursive.resources.remaining_result_nodes == 116
        @test recursive.diagnostics == Dict{String,Any}[]
        @test _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._staged_safe_point(retained_context[], 0)) isa
              LinkedSpecJulia.StagedAstEnrichmentException

        routed_registry = _julia_staged_enrichment_registry(
            function(request, _context)
                start = Dict("abcd" => 0, "efgh" => 10, "ijkl" => 20)
                result = haskey(start, request["text"]) ?
                    _julia_staged_enrichment_marker(
                        request["text"][2:3],
                        start[request["text"]] + 1,
                        "replace_marker",
                        nothing,
                        "fail",
                    ) :
                    Dict{String,Any}("kind" => "routed_leaf")
                return LinkedSpecJulia._staged_child_success(result)
            end,
        )
        routed = LinkedSpecJulia._enrich_staged_recursively(
            routed_registry,
            Dict{String,Any}(
                "replace" => Dict{String,Any}(
                    "control" => _julia_staged_enrichment_marker(
                        "abcd", 0, "replace_field", "ast", "fail",
                    ),
                    "ast" => nothing,
                ),
                "sibling" => Dict{String,Any}(
                    "control" => _julia_staged_enrichment_marker(
                        "efgh", 10, "sibling_field", "ast", "fail",
                    ),
                ),
                "append" => Dict{String,Any}(
                    "control" => _julia_staged_enrichment_marker(
                        "ijkl", 20, "append_child", "children", "fail",
                    ),
                    "children" => Any[],
                ),
            ),
            _julia_staged_enrichment_options(),
            _julia_staged_enrichment_recursive_authority(),
        )
        @test routed.ast["replace"]["ast"]["kind"] == "routed_leaf"
        @test routed.ast["sibling"]["ast"]["kind"] == "routed_leaf"
        @test routed.ast["append"]["children"][1]["kind"] == "routed_leaf"
        @test count(row -> row["stage_depth"] == 1, routed.sidecars) == 3
        @test count(row -> row["stage_depth"] == 2, routed.sidecars) == 3
    end

    @testset "recursive denials never reset lineage or cumulative ceilings" begin
        cycle_calls = Ref(0)
        cycle_marker = _julia_staged_enrichment_marker(
            "abcdef", 0, "replace_marker", nothing, "fail",
        )
        cycle_registry = _julia_staged_enrichment_registry(
            function(_request, _context)
                cycle_calls[] += 1
                return LinkedSpecJulia._staged_child_success(deepcopy(cycle_marker))
            end,
        )
        cycle_error = _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._enrich_staged_recursively(
                cycle_registry,
                Dict{String,Any}("payload" => cycle_marker),
                _julia_staged_enrichment_options(),
                _julia_staged_enrichment_recursive_authority(),
            ))
        @test _julia_staged_enrichment_error_code(cycle_error) == "staged_cycle"
        @test _julia_staged_enrichment_diagnostic_is_complete(cycle_error)
        @test cycle_calls[] == 1

        nondecreasing_registry = _julia_staged_enrichment_registry(
            (_request, _context) -> LinkedSpecJulia._staged_child_success(
                _julia_staged_enrichment_marker(
                    "uvwxyz", 0, "replace_marker", nothing, "fail",
                ),
            ),
        )
        nondecreasing = _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._enrich_staged_recursively(
                nondecreasing_registry,
                Dict{String,Any}("payload" => cycle_marker),
                _julia_staged_enrichment_options(),
                _julia_staged_enrichment_recursive_authority(),
            ))
        @test _julia_staged_enrichment_error_code(nondecreasing) ==
              "staged_chain_non_decreasing"
        @test _julia_staged_enrichment_diagnostic_is_complete(nondecreasing)

        nested_marker = _julia_staged_enrichment_marker(
            "bc", 1, "replace_marker", nothing, "fail",
        )
        for (authority, expected) in [
            (
                _julia_staged_enrichment_recursive_authority(max_depth = 1),
                "staged_depth_exceeded",
            ),
            (
                _julia_staged_enrichment_recursive_authority(max_calls = 1),
                "staged_call_limit_exceeded",
            ),
        ]
            registry = _julia_staged_enrichment_registry(
                (_request, _context) ->
                    LinkedSpecJulia._staged_child_success(deepcopy(nested_marker)),
            )
            error = _julia_staged_enrichment_capture(() ->
                LinkedSpecJulia._enrich_staged_recursively(
                    registry,
                    Dict{String,Any}("payload" => cycle_marker),
                    _julia_staged_enrichment_options(),
                    authority,
                ))
            @test _julia_staged_enrichment_error_code(error) == expected
            @test _julia_staged_enrichment_diagnostic_is_complete(error)
        end

        for (authority, expected) in [
            (
                _julia_staged_enrichment_recursive_authority(
                    remaining_steps = 0,
                ),
                "staged_budget_exhausted",
            ),
            (
                _julia_staged_enrichment_recursive_authority(
                    cancelled = _token -> true,
                ),
                "staged_cancelled",
            ),
            (
                _julia_staged_enrichment_recursive_authority(
                    deadline = 10,
                    clock = () -> 11,
                ),
                "staged_deadline_exceeded",
            ),
        ]
            calls = Ref(0)
            registry = _julia_staged_enrichment_registry(
                function(_request, _context)
                    calls[] += 1
                    return LinkedSpecJulia._staged_child_success(nothing)
                end,
            )
            error = _julia_staged_enrichment_capture(() ->
                LinkedSpecJulia._enrich_staged_recursively(
                    registry,
                    Dict{String,Any}(
                        "payload" => _julia_staged_enrichment_marker(
                            "x", 0, "replace_marker", nothing, "fail",
                        ),
                    ),
                    _julia_staged_enrichment_options(),
                    authority,
                ))
            @test _julia_staged_enrichment_error_code(error) == expected
            @test _julia_staged_enrichment_diagnostic_is_complete(error)
            @test calls[] == 0
        end

        node_calls = Ref(0)
        node_registry = _julia_staged_enrichment_registry(
            function(_request, _context)
                node_calls[] += 1
                return LinkedSpecJulia._staged_child_success(
                    Dict{String,Any}("kind" => "leaf", "value" => 1),
                )
            end,
        )
        node_options = _julia_staged_enrichment_options()
        node_options["caller_ceilings"]["max_result_nodes"] = 5
        node_error = _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._enrich_staged_recursively(
                node_registry,
                Dict{String,Any}(
                    "nodes" => Any[
                        Dict{String,Any}(
                            "payload" => _julia_staged_enrichment_marker(
                                "a", 0, "replace_marker", nothing, "fail",
                            ),
                        ),
                        Dict{String,Any}(
                            "payload" => _julia_staged_enrichment_marker(
                                "b", 1, "replace_marker", nothing, "fail",
                            ),
                        ),
                    ],
                ),
                node_options,
                _julia_staged_enrichment_recursive_authority(),
            ))
        @test _julia_staged_enrichment_error_code(node_error) ==
              "staged_result_node_limit_exceeded"
        @test _julia_staged_enrichment_diagnostic_is_complete(node_error)
        @test node_calls[] == 2

        narrowed = LinkedSpecJulia._enrich_staged_recursively(
            _julia_staged_enrichment_registry(
                (_request, _context) -> LinkedSpecJulia._staged_child_success(nothing),
            ),
            Dict{String,Any}(
                "payload" => _julia_staged_enrichment_marker(
                    "x", 0, "replace_marker", nothing, "fail",
                ),
            ),
            _julia_staged_enrichment_options(),
            _julia_staged_enrichment_recursive_authority(
                remaining_steps = 500,
                required_steps = 0,
            ),
        )
        @test narrowed.resources.remaining_steps == 200
    end

    @testset "recursive safe points and source projection stay ephemeral and bounded" begin
        direct_registry = _julia_staged_enrichment_registry(
            function(_request, context)
                @test LinkedSpecJulia._staged_rebase_position(context, 1) ==
                      Dict{String,Any}("source_id" => "ascii", "offset" => 2)
                @test LinkedSpecJulia._staged_rebase_span(
                    context,
                    Dict{String,Any}("start" => 1, "end" => 3),
                ) == Dict{String,Any}(
                    "kind" => "direct_span",
                    "source_id" => "ascii",
                    "start" => 2,
                    "end" => 4,
                    "provenance" => "capture",
                )
                return LinkedSpecJulia._staged_child_failure(Dict{String,Any}(
                    "code" => "child_parse_error",
                    "position" => Dict{String,Any}("offset" => 1),
                    "span" => Dict{String,Any}("start" => 1, "end" => 3),
                    "end_offset" => 3,
                ))
            end,
        )
        direct = LinkedSpecJulia._enrich_staged_recursively(
            direct_registry,
            Dict{String,Any}(
                "payload" => _julia_staged_enrichment_marker(
                    "abcd", 1, "replace_marker", nothing, "keep_text",
                ),
            ),
            _julia_staged_enrichment_options(),
            _julia_staged_enrichment_recursive_authority(),
        )
        child = only(direct.diagnostics)["child_diagnostic"]
        @test child["position"] == Dict{String,Any}(
            "source_id" => "ascii", "offset" => 2,
        )
        @test child["span"]["kind"] == "direct_span"
        @test child["span"]["start"] == 2
        @test child["span"]["end"] == 4
        @test child["end_offset"] == Dict{String,Any}(
            "source_id" => "ascii", "offset" => 4,
        )

        derived_marker = _julia_staged_enrichment_marker(
            "abcd", 0, "replace_marker", nothing, "keep_text",
        )
        derived_marker["staged_parse_job_v2"]["provenance"] = Dict{String,Any}(
            "kind" => "derived_text",
            "policy" => "concatenate_in_order",
            "segments" => Any[
                Dict{String,Any}(
                    "kind" => "direct_span",
                    "source_id" => "ascii",
                    "start" => 0,
                    "end" => 2,
                    "provenance" => "capture",
                ),
                Dict{String,Any}(
                    "kind" => "direct_span",
                    "source_id" => "unicode",
                    "start" => 1,
                    "end" => 3,
                    "provenance" => "capture",
                ),
            ],
        )
        derived_registry = _julia_staged_enrichment_registry(
            function(_request, context)
                @test LinkedSpecJulia._staged_rebase_position(context, 2) ==
                      Dict{String,Any}("source_id" => "unicode", "offset" => 1)
                span = LinkedSpecJulia._staged_rebase_span(
                    context,
                    Dict{String,Any}("start" => 1, "end" => 3),
                )
                @test span["kind"] == "derived_text"
                @test span["policy"] == "concatenate_in_order"
                @test length(span["segments"]) == 2
                @test LinkedSpecJulia._staged_rebase_diagnostic(
                    context,
                    Dict{String,Any}(
                        "code" => "child",
                        "span" => Dict{String,Any}("start" => 1, "end" => 3),
                    ),
                )["span"] == span
                return LinkedSpecJulia._staged_child_failure(Dict{String,Any}(
                    "code" => "child_parse_error",
                    "span" => Dict{String,Any}("start" => 1, "end" => 3),
                ))
            end,
        )
        derived = LinkedSpecJulia._enrich_staged_recursively(
            derived_registry,
            Dict{String,Any}("payload" => derived_marker),
            _julia_staged_enrichment_options(),
            _julia_staged_enrichment_recursive_authority(),
        )
        derived_span = only(derived.diagnostics)["child_diagnostic"]["span"]
        @test derived_span["policy"] == "concatenate_in_order"
        @test length(derived_span["segments"]) == 2

        invalid_range = LinkedSpecJulia._enrich_staged_recursively(
            _julia_staged_enrichment_registry(
                (_request, _context) -> LinkedSpecJulia._staged_child_failure(
                    Dict{String,Any}(
                        "code" => "child_parse_error",
                        "span" => Dict{String,Any}("start" => 1, "end" => 99),
                    ),
                ),
            ),
            Dict{String,Any}(
                "payload" => _julia_staged_enrichment_marker(
                    "abcd", 0, "replace_marker", nothing, "keep_text",
                ),
            ),
            _julia_staged_enrichment_options(),
            _julia_staged_enrichment_recursive_authority(),
        )
        @test only(invalid_range.diagnostics)["child_diagnostic"] ==
              Dict{String,Any}(
                  "code" => "child_parse_error",
                  "source_projection" => "invalid_local_range",
              )

        diagnostic_options = _julia_staged_enrichment_options()
        diagnostic_options["caller_ceilings"]["max_diagnostic_bytes"] = 64
        truncated = LinkedSpecJulia._enrich_staged_recursively(
            _julia_staged_enrichment_registry(
                (_request, _context) -> LinkedSpecJulia._staged_child_failure(
                    Dict{String,Any}(
                        "code" => "child_parse_error",
                        "detail" => repeat("x", 1024),
                    ),
                ),
            ),
            Dict{String,Any}(
                "payload" => _julia_staged_enrichment_marker(
                    "bad", 0, "replace_marker", nothing, "keep_text",
                ),
            ),
            diagnostic_options,
            _julia_staged_enrichment_recursive_authority(),
        )
        @test only(truncated.diagnostics)["code"] ==
              "staged_diagnostic_truncated"
        @test truncated.resources.remaining_diagnostic_bytes == 0

        cancel_checks = Ref(0)
        safe_cancel_authority = _julia_staged_enrichment_recursive_authority(
            cancelled = _token -> begin
                cancel_checks[] += 1
                cancel_checks[] >= 2
            end,
        )
        safe_registry = _julia_staged_enrichment_registry(
            function(_request, context)
                LinkedSpecJulia._staged_safe_point(context, 0)
                return LinkedSpecJulia._staged_child_success(nothing)
            end,
        )
        safe_cancelled = _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._enrich_staged_recursively(
                safe_registry,
                Dict{String,Any}(
                    "payload" => _julia_staged_enrichment_marker(
                        "x", 0, "replace_marker", nothing, "fail",
                    ),
                ),
                _julia_staged_enrichment_options(),
                safe_cancel_authority,
            ))
        @test _julia_staged_enrichment_error_code(safe_cancelled) ==
              "staged_cancelled"

        clock_checks = Ref(0)
        safe_deadline_authority = _julia_staged_enrichment_recursive_authority(
            deadline = 10,
            clock = () -> begin
                clock_checks[] += 1
                clock_checks[] == 1 ? 1 : 11
            end,
        )
        safe_deadline = _julia_staged_enrichment_capture(() ->
            LinkedSpecJulia._enrich_staged_recursively(
                safe_registry,
                Dict{String,Any}(
                    "payload" => _julia_staged_enrichment_marker(
                        "x", 0, "replace_marker", nothing, "fail",
                    ),
                ),
                _julia_staged_enrichment_options(),
                safe_deadline_authority,
            ))
        @test _julia_staged_enrichment_error_code(safe_deadline) ==
              "staged_deadline_exceeded"
    end

end
