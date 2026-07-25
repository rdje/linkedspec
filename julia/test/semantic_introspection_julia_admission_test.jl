# FUTURE-PARITY-BACKLOG.10.6.7 — composed Julia semantic admission.

using JSON3
using LinkedSpecJulia
using Test

const JULIA_SEMANTIC_ADMISSION_REPO_ROOT = normpath(joinpath(@__DIR__, "..", ".."))
const JULIA_SEMANTIC_ADMISSION_CONSUMER =
    "julia/test/semantic_introspection_julia_admission_test.jl"
const JULIA_SEMANTIC_ADMISSION_DRIVER = "tools/run_ci_local.sh"
const JULIA_SEMANTIC_ADMISSION_RUNTIME_INPUT = "ab\n"
const JULIA_SEMANTIC_ADMISSION_RUNTIME_IDENTITY =
    "semantic-introspection/runtime.spec"
const JULIA_SEMANTIC_ADMISSION_RUNTIME_DIGEST =
    "36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887"
const JULIA_SEMANTIC_ADMISSION_ROLES = (
    "source_normalization",
    "compiled_snapshots",
    "failed_snapshot",
    "runtime_direct",
    "runtime_loaded",
    "runtime_generated",
    "runtime_traced",
    "native_and_neutral_json",
    "exact_twenty_queries",
    "privacy_page_budget_error_explain",
    "query_non_interference",
    "stale_host_leak_denial",
)

mutable struct JuliaSemanticAdmissionContext
    contract::Dict{String,Any}
    indexes::Dict{String,Any}
    responses::Dict{String,Any}
    runtime_source::String
    runtime_compiled::CompiledSpec
    runtime_plan::Vector{GeneratedPlanRow}
    runtime_base::SemanticIndex
    runtime_index::Union{Nothing,SemanticIndex}
    direct_events::Vector{RuntimeSemanticObservationEvent}
end

function JuliaSemanticAdmissionContext()
    contract = JSON3.read(
        read(
            joinpath(
                JULIA_SEMANTIC_ADMISSION_REPO_ROOT,
                "capability_conformance",
                "semantic_introspection_contract.json",
            ),
            String,
        ),
        Dict{String,Any},
    )
    runtime_source = _julia_semantic_admission_fixture_text("runtime")
    parsed = parse_spec(runtime_source)
    validate_spec(parsed)
    compiled = compile_spec(parsed)
    return JuliaSemanticAdmissionContext(
        contract,
        Dict{String,Any}(),
        Dict{String,Any}(),
        runtime_source,
        compiled,
        build_generated_rule_plan(compiled),
        semantic_index(
            runtime_source;
            logical_name = "runtime.spec",
            source_detail_ceiling = SemanticSourceTextDetail,
        ),
        nothing,
        RuntimeSemanticObservationEvent[],
    )
end

function _julia_semantic_admission_fixture_bytes(name::AbstractString)
    return read(
        joinpath(
            JULIA_SEMANTIC_ADMISSION_REPO_ROOT,
            "capability_conformance",
            "semantic_introspection",
            "$(String(name)).spec",
        ),
    )
end

_julia_semantic_admission_fixture_text(name::AbstractString) =
    String(copy(_julia_semantic_admission_fixture_bytes(name)))

function _julia_semantic_admission_case(context, id::AbstractString)
    return only(
        query_case for query_case in context.contract["query_cases"] if
        query_case["id"] == id
    )
end

function _julia_semantic_admission_index(context, snapshot::AbstractString)
    if snapshot == "runtime"
        context.runtime_index === nothing && error("Runtime admission index is not captured")
        return context.runtime_index::SemanticIndex
    end
    return get!(context.indexes, String(snapshot)) do
        fixture, logical_name, ceiling = if snapshot == "graph"
            ("graph", "graph.spec", SemanticSourceTextDetail)
        elseif snapshot == "calls"
            ("calls_and_staging", "calls_and_staging.spec", SemanticSourceTextDetail)
        elseif snapshot == "failed"
            ("failed", "failed.spec", SemanticSourceSpanDetail)
        elseif snapshot == "privacy"
            ("privacy", "privacy.spec", SemanticSourceTextDetail)
        elseif snapshot == "privacy_limited"
            ("privacy", "privacy.spec", SemanticSourceIdentityDetail)
        else
            error("Unexpected semantic admission snapshot: $snapshot")
        end
        semantic_index(
            _julia_semantic_admission_fixture_bytes(fixture);
            logical_name = logical_name,
            source_detail_ceiling = ceiling,
        )
    end
end

function _julia_semantic_admission_request(value)
    operation = Dict(
        "capabilities" => SemanticQueryCapabilitiesOperation,
        "list" => SemanticQueryListOperation,
        "get" => SemanticQueryGetOperation,
        "relations" => SemanticQueryRelationsOperation,
        "explain" => SemanticQueryExplainOperation,
    )[value["operation"]]
    direction = Dict(
        "outgoing" => SemanticQueryOutgoingDirection,
        "incoming" => SemanticQueryIncomingDirection,
        "both" => SemanticQueryBothDirection,
    )[value["direction"]]
    detail = Dict(
        "none" => SemanticSourceNoneDetail,
        "identity" => SemanticSourceIdentityDetail,
        "span" => SemanticSourceSpanDetail,
        "text" => SemanticSourceTextDetail,
    )[value["source"]["detail"]]
    return SemanticQuery(
        operation;
        contract = value["contract"],
        subjects = value["subjects"],
        record_kinds = value["record_kinds"],
        relation_kinds = value["relation_kinds"],
        direction = direction,
        page = SemanticQueryPage(
            after_id = value["page"]["after_id"],
            limit = value["page"]["limit"],
        ),
        budget = SemanticQueryBudget(
            max_records = value["budget"]["max_records"],
            max_relations = value["budget"]["max_relations"],
            max_depth = value["budget"]["max_depth"],
        ),
        source = SemanticQuerySource(
            detail = detail,
            include_content_digest = value["source"]["include_content_digest"],
        ),
    )
end

function _julia_semantic_admission_clone(value::AbstractDict)
    return JSON3.read(JSON3.write(value), Dict{String,Any})
end

function _julia_semantic_admission_digest(value)
    encoded = LinkedSpecJulia._primary_cli_canonical_json(value)
    return bytes2hex(LinkedSpecJulia.SHA.sha256(codeunits(encoded)))
end

function _julia_semantic_admission_assert_case(context, index, query_case)
    id = String(query_case["id"])
    request_value = _julia_semantic_admission_clone(query_case["request"])
    request_before = _julia_semantic_admission_clone(request_value)
    typed_request = _julia_semantic_admission_request(request_value)
    typed = id == "capabilities" ?
            semantic_capabilities(index) : semantic_query(index, typed_request)
    neutral = semantic_query_neutral(index, request_value)
    expected = query_case["expected"]

    @test request_value == request_before
    @test typed == neutral
    @test typed.ok == expected["ok"]
    @test [record.id for record in typed.records] == expected["record_ids"]
    @test [relation.id for relation in typed.relations] == expected["relation_ids"]
    @test [diagnostic.code for diagnostic in typed.diagnostics] ==
          expected["diagnostic_codes"]
    @test typed.page.complete == expected["complete"]
    @test _julia_semantic_admission_digest(to_json(typed)) ==
          expected["response_sha256"]
    return typed
end

function _julia_semantic_admission_expected_events()
    return RuntimeSemanticObservationEvent[
        RuntimeSemanticObservationEvent(
            event_kind = RuntimeSemanticRegexSlotSelected,
            rule_label = "Top",
            target_rule = "Top",
            regex_index = 0,
            position = 1,
        ),
        RuntimeSemanticObservationEvent(
            event_kind = RuntimeSemanticRegexSlotSelected,
            rule_label = "Top",
            target_rule = "Top",
            regex_index = 1,
            position = 2,
        ),
        RuntimeSemanticObservationEvent(
            event_kind = RuntimeSemanticRuleResult,
            rule_label = "Top",
            position = 2,
            input_identity =
                "input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece",
            status = "succeeded",
        ),
    ]
end

function _julia_semantic_admission_capture(call, context, route::AbstractString)
    events = RuntimeSemanticObservationEvent[]
    value = call(event -> push!(events, event))
    @test value == Any["A", "B"]
    @test events == _julia_semantic_admission_expected_events()
    derived = with_execution_observation(context.runtime_base, events)
    response = _julia_semantic_admission_assert_case(
        context,
        derived,
        _julia_semantic_admission_case(context, "runtime_events"),
    )
    @test _julia_semantic_admission_digest(to_json(response)) ==
          JULIA_SEMANTIC_ADMISSION_RUNTIME_DIGEST
    @test !isempty(route)
    return value, events, derived
end

function _julia_semantic_admission_events_from_json(rows)
    return RuntimeSemanticObservationEvent[
        RuntimeSemanticObservationEvent(
            contract_id = row["contract_id"],
            event_kind = row["event_kind"] == "regex_slot_selected" ?
                         RuntimeSemanticRegexSlotSelected : RuntimeSemanticRuleResult,
            rule_label = row["rule_label"],
            target_rule = row["target_rule"],
            regex_index = row["regex_index"],
            position = row["position"],
            input_identity = row["input_identity"],
            status = row["status"],
        ) for row in rows
    ]
end

function _julia_semantic_admission_isolated_emitted(context)
    return mktempdir() do scratch
        generated_path = joinpath(scratch, "runtime_generated.jl")
        runner_path = joinpath(scratch, "runner.jl")
        write(
            generated_path,
            emit_julia_source_v2(
                context.runtime_compiled,
                JULIA_SEMANTIC_ADMISSION_RUNTIME_IDENTITY,
            ),
        )
        write(
            runner_path,
            raw"""
import JSON3
import LinkedSpecJulia

include(ARGS[1])
const Parser = LinkedSpecGeneratedParser
const INPUT = "ab\n"

direct_events = LinkedSpecJulia.RuntimeSemanticObservationEvent[]
direct = Parser.execute(
    INPUT;
    semantic_observation_sink = event -> push!(direct_events, event),
)
trace_output = IOBuffer()
traced_events = LinkedSpecJulia.RuntimeSemanticObservationEvent[]
traced = Parser.execute_with_trace(
    INPUT,
    LinkedSpecJulia.trace_config_enabled(LinkedSpecJulia.LinkedSpecTraceDebug);
    stdout_io = trace_output,
    semantic_observation_sink = event -> push!(traced_events, event),
)
print(JSON3.write(Dict{String,Any}(
    "direct" => direct,
    "traced" => traced,
    "direct_events" => [LinkedSpecJulia.to_json(event) for event in direct_events],
    "traced_events" => [LinkedSpecJulia.to_json(event) for event in traced_events],
    "trace_nonempty" => !isempty(String(take!(trace_output))),
)))
""",
        )

        output = IOBuffer()
        errors = IOBuffer()
        command = `$(Base.julia_cmd()) --project=$(joinpath(JULIA_SEMANTIC_ADMISSION_REPO_ROOT, "julia")) --startup-file=no --history-file=no --compiled-modules=no $runner_path $generated_path`
        process = run(pipeline(ignorestatus(command); stdout = output, stderr = errors))
        @test success(process)
        @test isempty(String(take!(errors)))
        return JSON3.read(String(take!(output)), Dict{String,Any})
    end
end

function role_source_normalization(context::JuliaSemanticAdmissionContext)
    bytes = _julia_semantic_admission_fixture_bytes("privacy")
    decoded = String(copy(bytes))
    from_bytes = semantic_index(
        bytes;
        logical_name = "privacy.spec",
        source_detail_ceiling = SemanticSourceTextDetail,
    )
    from_text = semantic_index(
        decoded;
        logical_name = "privacy.spec",
        source_detail_ceiling = SemanticSourceTextDetail,
    )
    query_case = _julia_semantic_admission_case(context, "privacy_text_and_digest")
    @test to_json(_julia_semantic_admission_assert_case(context, from_bytes, query_case)) ==
          to_json(_julia_semantic_admission_assert_case(context, from_text, query_case))
    return nothing
end

function role_compiled_snapshots(context::JuliaSemanticAdmissionContext)
    for (snapshot, query_id) in (
        ("graph", "graph_list_rules"),
        ("calls", "calls_symbols_and_shapes"),
        ("privacy", "privacy_text_and_digest"),
        ("privacy_limited", "source_ceiling_forbidden"),
    )
        index = _julia_semantic_admission_index(context, snapshot)
        @test compilation_authority(index).compiled
        @test !semantic_snapshot(index).has_execution
        _julia_semantic_admission_assert_case(
            context,
            index,
            _julia_semantic_admission_case(context, query_id),
        )
    end
    return nothing
end

function role_failed_snapshot(context::JuliaSemanticAdmissionContext)
    index = _julia_semantic_admission_index(context, "failed")
    @test !compilation_authority(index).compiled
    @test semantic_snapshot(index).state == SemanticFailedCompilationSnapshotState
    _julia_semantic_admission_assert_case(
        context,
        index,
        _julia_semantic_admission_case(context, "failed_diagnostic"),
    )
    return nothing
end

function role_runtime_direct(context::JuliaSemanticAdmissionContext)
    _, events, derived = _julia_semantic_admission_capture(context, "direct") do sink
        runtime_parse(
            LinkedSpecRuntimeEngine(context.runtime_compiled),
            JULIA_SEMANTIC_ADMISSION_RUNTIME_INPUT;
            semantic_observation_sink = sink,
        ).value
    end
    context.direct_events = events
    context.runtime_index = derived
    return nothing
end

function role_runtime_loaded(context::JuliaSemanticAdmissionContext)
    mktempdir() do scratch
        write(joinpath(scratch, "runtime.spec"), context.runtime_source)
        loaded = load_and_compile_spec(
            path_spec_request("runtime.spec"),
            SpecLoadOptions(scratch),
        )
        _, loaded_events, _ = _julia_semantic_admission_capture(context, "loaded") do sink
            runtime_parse(
                create_engine(loaded),
                JULIA_SEMANTIC_ADMISSION_RUNTIME_INPUT;
                semantic_observation_sink = sink,
            ).value
        end
        @test loaded_events == context.direct_events

        normalized = from_json(
            SpecFile,
            JSON3.read(JSON3.write(to_json(parse_spec(context.runtime_source)))),
        )
        validate_spec(normalized)
        reconstructed = compile_spec(normalized)
        _, reconstructed_events, _ = _julia_semantic_admission_capture(
            context,
            "reconstructed",
        ) do sink
            runtime_parse(
                LinkedSpecRuntimeEngine(reconstructed),
                JULIA_SEMANTIC_ADMISSION_RUNTIME_INPUT;
                semantic_observation_sink = sink,
            ).value
        end
        @test reconstructed_events == context.direct_events
    end
    return nothing
end

function role_runtime_generated(context::JuliaSemanticAdmissionContext)
    _, helper_events, _ = _julia_semantic_admission_capture(
        context,
        "generated plan public helper",
    ) do sink
        execute_generated_parser_v2(
            context.runtime_compiled,
            context.runtime_plan,
            JULIA_SEMANTIC_ADMISSION_RUNTIME_INPUT,
            JULIA_SEMANTIC_ADMISSION_RUNTIME_IDENTITY;
            semantic_observation_sink = sink,
        )
    end
    @test helper_events == context.direct_events

    generated = emit_julia_source_v2(
        context.runtime_compiled,
        JULIA_SEMANTIC_ADMISSION_RUNTIME_IDENTITY,
    )
    mktempdir() do scratch
        generated_path = joinpath(scratch, "runtime_generated.jl")
        write(generated_path, generated)
        host = Module(:JuliaSemanticAdmissionGeneratedHost)
        Base.include(host, generated_path)
        parser = Base.invokelatest(getproperty, host, :LinkedSpecGeneratedParser)
        execute = Base.invokelatest(getproperty, parser, :execute)
        execute_with_trace = Base.invokelatest(getproperty, parser, :execute_with_trace)

        _, emitted_events, _ = _julia_semantic_admission_capture(
            context,
            "fresh emitted direct",
        ) do sink
            Base.invokelatest(
                execute,
                JULIA_SEMANTIC_ADMISSION_RUNTIME_INPUT;
                semantic_observation_sink = sink,
            )
        end
        @test emitted_events == context.direct_events

        trace_output = IOBuffer()
        _, emitted_traced_events, _ = _julia_semantic_admission_capture(
            context,
            "fresh emitted traced",
        ) do sink
            Base.invokelatest(
                execute_with_trace,
                JULIA_SEMANTIC_ADMISSION_RUNTIME_INPUT,
                trace_config_enabled(LinkedSpecTraceDebug);
                stdout_io = trace_output,
                semantic_observation_sink = sink,
            )
        end
        @test !isempty(String(take!(trace_output)))
        @test emitted_traced_events == context.direct_events
    end

    isolated = _julia_semantic_admission_isolated_emitted(context)
    @test isolated["direct"] == Any["A", "B"]
    @test isolated["traced"] == Any["A", "B"]
    @test isolated["trace_nonempty"] === true
    for key in ("direct_events", "traced_events")
        events = _julia_semantic_admission_events_from_json(isolated[key])
        @test events == context.direct_events
        derived = with_execution_observation(context.runtime_base, events)
        response = _julia_semantic_admission_assert_case(
            context,
            derived,
            _julia_semantic_admission_case(context, "runtime_events"),
        )
        @test _julia_semantic_admission_digest(to_json(response)) ==
              JULIA_SEMANTIC_ADMISSION_RUNTIME_DIGEST
    end
    return nothing
end

function role_runtime_traced(context::JuliaSemanticAdmissionContext)
    native_trace = IOBuffer()
    _, native_events, _ = _julia_semantic_admission_capture(
        context,
        "native traced",
    ) do sink
        runtime_parse_with_trace(
            LinkedSpecRuntimeEngine(context.runtime_compiled),
            JULIA_SEMANTIC_ADMISSION_RUNTIME_INPUT,
            trace_config_enabled(LinkedSpecTraceDebug);
            stdout_io = native_trace,
            semantic_observation_sink = sink,
        ).value
    end
    @test !isempty(String(take!(native_trace)))
    @test native_events == context.direct_events

    generated_trace = IOBuffer()
    _, generated_events, _ = _julia_semantic_admission_capture(
        context,
        "generated helper traced",
    ) do sink
        execute_generated_parser_with_trace_v2(
            context.runtime_compiled,
            context.runtime_plan,
            JULIA_SEMANTIC_ADMISSION_RUNTIME_INPUT,
            trace_config_enabled(LinkedSpecTraceDebug),
            JULIA_SEMANTIC_ADMISSION_RUNTIME_IDENTITY;
            stdout_io = generated_trace,
            semantic_observation_sink = sink,
        )
    end
    @test !isempty(String(take!(generated_trace)))
    @test generated_events == context.direct_events
    return nothing
end

function role_native_and_neutral_json(context::JuliaSemanticAdmissionContext)
    index = _julia_semantic_admission_index(context, "graph")
    query_case = _julia_semantic_admission_case(context, "capabilities")
    request = _julia_semantic_admission_clone(query_case["request"])
    native = semantic_capabilities(index)
    neutral = semantic_query_neutral(index, request)
    @test native == neutral
    @test JSON3.read(JSON3.write(to_json(native)), Dict{String,Any}) == to_json(native)

    detached = to_json(native)
    detached["records"][1]["facts"]["record_kinds"][1] = "host_private_kind"
    @test _julia_semantic_admission_digest(to_json(semantic_capabilities(index))) ==
          query_case["expected"]["response_sha256"]
    return nothing
end

function role_exact_twenty_queries(context::JuliaSemanticAdmissionContext)
    @test length(context.contract["query_cases"]) == 20
    for query_case in context.contract["query_cases"]
        id = String(query_case["id"])
        response = _julia_semantic_admission_assert_case(
            context,
            _julia_semantic_admission_index(context, query_case["snapshot"]),
            query_case,
        )
        context.responses[id] = to_json(response)
    end
    return nothing
end

function role_privacy_page_budget_error_explain(context::JuliaSemanticAdmissionContext)
    none = only(context.responses["privacy_none"]["records"])
    @test none["source"] === nothing
    @test none["redactions"] == Any["/facts/pattern"]

    text = only(context.responses["privacy_text_and_digest"]["records"])
    @test text["facts"]["pattern"] == "é"
    @test occursin(r"^sha256:[0-9a-f]{64}$", text["source"]["content_digest"])
    @test context.responses["source_ceiling_forbidden"]["ok"] === false

    for id in ("pagination_after_id", "page_boundary")
        @test context.responses[id]["page"]["complete"] ==
              _julia_semantic_admission_case(context, id)["expected"]["complete"]
    end
    for (id, code) in (
        ("budget_prefix", "semantic_query_budget_exceeded"),
        ("relation_budget_prefix", "semantic_query_budget_exceeded"),
        ("unsupported_contract", "semantic_query_contract_unsupported"),
        ("invalid_operation_combination", "semantic_query_invalid"),
    )
        @test only(context.responses[id]["diagnostics"])["code"] == code
    end
    @test any(
        record -> record["kind"] == "explanation_step",
        context.responses["graph_explain_entry"]["records"],
    )
    return nothing
end

function role_query_non_interference(context::JuliaSemanticAdmissionContext)
    index = _julia_semantic_admission_index(context, "graph")
    query_case = _julia_semantic_admission_case(context, "graph_explain_entry")
    request = _julia_semantic_admission_clone(query_case["request"])
    @test !semantic_snapshot(index).has_execution
    first = semantic_query_neutral(index, request)
    second = semantic_query_neutral(index, request)
    @test first == second
    @test !semantic_snapshot(index).has_execution
    @test !semantic_snapshot(context.runtime_base).has_execution

    detached = to_json(first)
    detached["records"][1]["facts"]["outcome"] = "mutated"
    @test _julia_semantic_admission_digest(to_json(semantic_query_neutral(index, request))) ==
          query_case["expected"]["response_sha256"]

    implementation = read(
        joinpath(
            JULIA_SEMANTIC_ADMISSION_REPO_ROOT,
            "julia",
            "src",
            "semantic",
            "SemanticQuery.jl",
        ),
        String,
    )
    for forbidden in (
        "parse_spec(",
        "compile_spec(",
        "build_generated_rule_plan(",
        "emit_julia_source(",
        "runtime_execute(",
        "LinkedSpecTraceEmitter(",
        "RuntimeSemanticObservationSink",
        "ENV[",
        "read(",
        "open(",
    )
        @test !occursin(forbidden, implementation)
    end
    return nothing
end

function role_stale_host_leak_denial(context::JuliaSemanticAdmissionContext)
    encoded = String(JSON3.write(context.responses))
    for forbidden in (
        "/Users/",
        "/private/tmp/",
        "CompiledSpec",
        "ActionIR",
        "SpecFile",
        "RuntimeSemanticObservationEvent",
        "generated_implementation_source",
        "LinkedSpecJulia.",
        "0x",
    )
        @test !occursin(forbidden, encoded)
    end
    return nothing
end

@testset "composed Julia semantic admission executes every role exactly once" begin
    context = JuliaSemanticAdmissionContext()
    roles = (
        "source_normalization" => role_source_normalization,
        "compiled_snapshots" => role_compiled_snapshots,
        "failed_snapshot" => role_failed_snapshot,
        "runtime_direct" => role_runtime_direct,
        "runtime_loaded" => role_runtime_loaded,
        "runtime_generated" => role_runtime_generated,
        "runtime_traced" => role_runtime_traced,
        "native_and_neutral_json" => role_native_and_neutral_json,
        "exact_twenty_queries" => role_exact_twenty_queries,
        "privacy_page_budget_error_explain" =>
            role_privacy_page_budget_error_explain,
        "query_non_interference" => role_query_non_interference,
        "stale_host_leak_denial" => role_stale_host_leak_denial,
    )
    @test Tuple(first(role) for role in roles) == JULIA_SEMANTIC_ADMISSION_ROLES

    completed = Dict{String,Int}()
    for (name, role) in roles
        completed[name] = get(completed, name, 0) + 1
        @test completed[name] == 1
        role(context)
    end
    @test completed == Dict(role => 1 for role in JULIA_SEMANTIC_ADMISSION_ROLES)

    admission = only(
        row for row in context.contract["target_admissions"] if
        row["backend"] == "julia" && row["runtime"] == "julia"
    )
    @test admission["status"] == "complete"
    @test admission["consumer"] == Dict{String,Any}(
        "path" => JULIA_SEMANTIC_ADMISSION_CONSUMER,
        "canonical_driver" => JULIA_SEMANTIC_ADMISSION_DRIVER,
        "roles" => Any[JULIA_SEMANTIC_ADMISSION_ROLES...],
    )
    rollout = only(
        row for row in context.contract["rollout"] if
        row["capability"] == "julia_parity"
    )
    @test rollout["status"] == "complete"
    @test JULIA_SEMANTIC_ADMISSION_CONSUMER in
          context.contract["canonical_ci"]["required_tracked_files"]
end
