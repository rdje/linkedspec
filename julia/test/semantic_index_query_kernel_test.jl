# FUTURE-PARITY-BACKLOG.10.6.5.1 — private immutable non-traversal query kernel.

const _SEMANTIC_QUERY_KERNEL_CONTRACT = JSON3.read(
    read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "semantic_introspection_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)

const _SEMANTIC_QUERY_KERNEL_CASES = (
    "capabilities",
    "graph_list_rules",
    "graph_duplicate_regex_text",
    "graph_explain_entry",
    "calls_symbols_and_shapes",
    "failed_diagnostic",
    "privacy_none",
    "privacy_text_and_digest",
    "source_ceiling_forbidden",
)

function _semantic_query_kernel_case(id)
    return only(
        query_case for query_case in _SEMANTIC_QUERY_KERNEL_CONTRACT["query_cases"] if
        query_case["id"] == id
    )
end

function _semantic_query_kernel_index(snapshot)
    fixture, logical_name, ceiling = if snapshot == "graph"
        ("graph.spec", "graph.spec", SemanticSourceTextDetail)
    elseif snapshot == "calls"
        ("calls_and_staging.spec", "calls_and_staging.spec", SemanticSourceTextDetail)
    elseif snapshot == "failed"
        ("failed.spec", "failed.spec", SemanticSourceSpanDetail)
    elseif snapshot == "privacy"
        ("privacy.spec", "privacy.spec", SemanticSourceTextDetail)
    elseif snapshot == "privacy_limited"
        ("privacy.spec", "privacy.spec", SemanticSourceIdentityDetail)
    else
        error("Unknown semantic query kernel snapshot: $snapshot")
    end
    source = read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "semantic_introspection",
            fixture,
        ),
        String,
    )
    return semantic_index(
        source;
        logical_name = logical_name,
        source_detail_ceiling = ceiling,
    )
end

function _semantic_query_kernel_request(value)
    operation = Dict(
        "capabilities" => LinkedSpecJulia.SemanticQueryCapabilitiesOperation,
        "list" => LinkedSpecJulia.SemanticQueryListOperation,
        "get" => LinkedSpecJulia.SemanticQueryGetOperation,
        "relations" => LinkedSpecJulia.SemanticQueryRelationsOperation,
        "explain" => LinkedSpecJulia.SemanticQueryExplainOperation,
    )[value["operation"]]
    direction = Dict(
        "outgoing" => LinkedSpecJulia.SemanticQueryOutgoingDirection,
        "incoming" => LinkedSpecJulia.SemanticQueryIncomingDirection,
        "both" => LinkedSpecJulia.SemanticQueryBothDirection,
    )[value["direction"]]
    detail = Dict(
        "none" => SemanticSourceNoneDetail,
        "identity" => SemanticSourceIdentityDetail,
        "span" => SemanticSourceSpanDetail,
        "text" => SemanticSourceTextDetail,
    )[value["source"]["detail"]]
    return LinkedSpecJulia.SemanticQuery(
        operation;
        contract = value["contract"],
        subjects = value["subjects"],
        record_kinds = value["record_kinds"],
        relation_kinds = value["relation_kinds"],
        direction = direction,
        page = LinkedSpecJulia.SemanticQueryPage(
            after_id = value["page"]["after_id"],
            limit = value["page"]["limit"],
        ),
        budget = LinkedSpecJulia.SemanticQueryBudget(
            max_records = value["budget"]["max_records"],
            max_relations = value["budget"]["max_relations"],
            max_depth = value["budget"]["max_depth"],
        ),
        source = LinkedSpecJulia.SemanticQuerySource(
            detail = detail,
            include_content_digest = value["source"]["include_content_digest"],
        ),
    )
end

function _semantic_query_kernel_digest(response)
    encoded = LinkedSpecJulia._primary_cli_canonical_json(to_json(response))
    return bytes2hex(LinkedSpecJulia.SHA.sha256(codeunits(encoded)))
end

function _semantic_query_kernel_has_no_mutable_container(value)
    if value isa AbstractDict || value isa AbstractVector
        return false
    elseif value isa LinkedSpecJulia._SemanticQueryObject ||
           value isa LinkedSpecJulia._SemanticQueryArray
        return all(
            item -> item isa Pair ?
                    _semantic_query_kernel_has_no_mutable_container(last(item)) :
                    _semantic_query_kernel_has_no_mutable_container(item),
            getfield(value, :values),
        )
    elseif value isa Tuple
        return all(_semantic_query_kernel_has_no_mutable_container, value)
    end
    return true
end

@testset "Semantic index private immutable query kernel" begin
    responses = Dict{String,Any}()

    @testset "nine exact non-traversal response hashes" begin
        @test length(_SEMANTIC_QUERY_KERNEL_CASES) == 9
        for id in _SEMANTIC_QUERY_KERNEL_CASES
            query_case = _semantic_query_kernel_case(id)
            request = _semantic_query_kernel_request(query_case["request"])
            index = _semantic_query_kernel_index(query_case["snapshot"])
            response = LinkedSpecJulia._semantic_query_kernel(index, request)
            expected = query_case["expected"]
            responses[id] = response

            @test response.ok == expected["ok"]
            @test [record.id for record in response.records] == expected["record_ids"]
            @test [relation.id for relation in response.relations] == expected["relation_ids"]
            @test [diagnostic.code for diagnostic in response.diagnostics] ==
                  expected["diagnostic_codes"]
            @test response.page.complete == expected["complete"]
            @test _semantic_query_kernel_digest(response) == expected["response_sha256"]
        end
    end

    @testset "source privacy and exact structural redaction" begin
        none = to_json(responses["privacy_none"])["records"][1]
        @test none["source"] === nothing
        @test none["facts"]["pattern"] === nothing
        @test none["redactions"] == Any["/facts/pattern"]

        text = to_json(responses["privacy_text_and_digest"])["records"][1]
        @test text["facts"]["pattern"] == "é"
        @test text["redactions"] == Any[]
        @test text["source"]["excerpt"] == "/é/"
        @test startswith(text["source"]["content_digest"], "sha256:")
        @test ncodeunits(text["source"]["content_digest"]) == 71

        limited = responses["source_ceiling_forbidden"]
        @test !limited.ok
        @test to_json(only(limited.diagnostics))["fields"] == Dict{String,Any}(
            "requested" => "span",
            "ceiling" => "identity",
        )
    end

    @testset "recursive immutability and fresh detached serialization" begin
        index = _semantic_query_kernel_index("graph")
        request = _semantic_query_kernel_request(
            _semantic_query_kernel_case("capabilities")["request"],
        )
        first = LinkedSpecJulia._semantic_query_kernel(index, request)
        first_json = to_json(first)
        first_json["records"][1]["facts"]["record_kinds"][1] = "host-private"
        second = LinkedSpecJulia._semantic_query_kernel(index, request)

        @test first == second
        @test to_json(first) !== to_json(second)
        @test to_json(first)["records"] !== to_json(second)["records"]
        @test _semantic_query_kernel_digest(second) ==
              _semantic_query_kernel_case("capabilities")["expected"]["response_sha256"]
        @test to_json(first)["records"][1]["facts"]["record_kinds"][1] == "capabilities"
        @test all(
            record ->
                _semantic_query_kernel_has_no_mutable_container(record.facts) &&
                _semantic_query_kernel_has_no_mutable_container(record.redactions),
            first.records,
        )
        @test getfield(index, :_static_projection) isa LinkedSpecJulia._SemanticStaticProjection
    end

    @testset "typed boundaries and private kernel seam" begin
        graph = _semantic_query_kernel_index("graph")
        relations = LinkedSpecJulia.SemanticQuery(
            LinkedSpecJulia.SemanticQueryRelationsOperation;
            subjects = ("rule:Top",),
        )
        paged = LinkedSpecJulia.SemanticQuery(
            LinkedSpecJulia.SemanticQueryListOperation;
            page = LinkedSpecJulia.SemanticQueryPage(limit = 1),
        )
        budgeted = LinkedSpecJulia.SemanticQuery(
            LinkedSpecJulia.SemanticQueryListOperation;
            budget = LinkedSpecJulia.SemanticQueryBudget(max_records = 2),
        )
        @test LinkedSpecJulia._semantic_query_kernel(graph, relations).ok
        @test LinkedSpecJulia._semantic_query_kernel(graph, paged).page.next_after_id !== nothing
        @test !LinkedSpecJulia._semantic_query_kernel(graph, budgeted).page.complete
        @test_throws ArgumentError LinkedSpecJulia.SemanticQueryPage(limit = true)
        @test_throws MethodError LinkedSpecJulia.SemanticQueryPage(nothing, true)
        @test_throws ArgumentError LinkedSpecJulia.SemanticQueryBudget(max_records = true)
        @test_throws MethodError LinkedSpecJulia.SemanticQueryBudget(true, 2_000, 4)
        @test_throws ArgumentError LinkedSpecJulia.SemanticQuerySource(
            include_content_digest = 1,
        )
        @test LinkedSpecJulia.SemanticQuery(
            operation = LinkedSpecJulia.SemanticQueryListOperation,
        ) == LinkedSpecJulia.SemanticQuery(LinkedSpecJulia.SemanticQueryListOperation)

        public_names = names(LinkedSpecJulia)
        for name in (
            :SemanticQuery,
            :SemanticQueryResponse,
            :semantic_capabilities,
            :semantic_query,
            :semantic_query_neutral,
        )
            @test name in public_names
        end
        @test !(:_semantic_query_kernel in public_names)
    end

    @testset "detached-projection-only implementation" begin
        implementation = read(
            joinpath(REPO_ROOT, "julia", "src", "semantic", "SemanticQuery.jl"),
            String,
        )
        @test length(collect(eachmatch(
            r"_semantic_static_projection_materialize\(index\)",
            implementation,
        ))) == 1
        for forbidden in (
            "getfield(index, :_source_text)",
            "getfield(index, :_source_map)",
            "getfield(index, :_compilation_outcome)",
            "parse_spec(",
            "compile_spec(",
            "build_generated_rule_plan(",
            "emit_julia_source(",
            "runtime_execute(",
            "LinkedSpecTraceEmitter(",
            "ENV[",
            "time_ns(",
            "rand(",
        )
            @test !occursin(forbidden, implementation)
        end
    end
end
