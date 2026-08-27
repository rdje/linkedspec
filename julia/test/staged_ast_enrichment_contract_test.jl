# FUTURE-PARITY-BACKLOG.14.7.6.1 — private Julia marker/provenance boundary.
#
# This exact final-path consumer is intentionally omitted from ordinary Julia
# and canonical CI discovery. Its focused repository-local command is:
#
#   bash tools/run_julia_project_data.sh --project=julia --startup-file=no \
#     --history-file=no julia/test/staged_ast_enrichment_contract_test.jl
#
# Every marker/provenance assertion must remain GREEN. The sole intentional
# RED is the final `.14.7.6.2` authority sentinel; this leaf owns no registry,
# cache, result/failure stitching, recurrence, admission, or public surface.

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

    @testset "LINKEDSPEC_STAGED_AST_ENRICHMENT_JULIA_RED: missing authority=[pre_registered_resolution,immutable_cache,result_failure_policies]; marker=[STAGED_PARSE_JOB_MARKER] and typed provenance=[staged_parse_job_v2] are available" begin
        # Intentional RED: `.14.7.6.2` owns caller-frozen resolution/cache and
        # all result/failure stitching. This leaf stops at inert declaration.
        @test false
    end
end
