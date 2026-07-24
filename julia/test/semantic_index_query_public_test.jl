# FUTURE-PARITY-BACKLOG.10.6.5.3 — exact public typed/raw-neutral semantic query.

function _semantic_query_public_request(id)
    return deepcopy(_semantic_query_kernel_case(id)["request"])
end

function _semantic_query_public_invalid_cases()
    request() = _semantic_query_public_request("graph_list_rules")
    cases = Any[(
        label = "request_not_object",
        request = Any[],
        code = "semantic_query_invalid",
        reason = "request_not_object",
    )]
    function add(label, value; code = "semantic_query_invalid", reason = nothing)
        push!(cases, (label = label, request = value, code = code, reason = reason))
    end

    value = request()
    value["contract"] = "linkedspec-semantic-query-v0"
    add("unsupported_contract", value; code = "semantic_query_contract_unsupported")

    value = request()
    delete!(value, "direction")
    add("request_fields", value; reason = "request_fields")

    value = request()
    delete!(value["page"], "limit")
    add("page_fields", value; reason = "page_fields")

    value = request()
    delete!(value["budget"], "max_depth")
    add("budget_fields", value; reason = "budget_fields")

    value = request()
    delete!(value["source"], "detail")
    add("source_fields", value; reason = "source_fields")

    value = request()
    value["operation"] = "search"
    add("operation", value; reason = "operation")

    value = request()
    value["subjects"] = "rule:Top"
    add("subjects_type", value; reason = "subjects_type")

    value = request()
    value["operation"] = "get"
    value["subjects"] = Any["rule:Top", "rule:Top"]
    value["record_kinds"] = Any[]
    add("subjects_duplicate", value; reason = "subjects_duplicate")

    value = request()
    value["record_kinds"] = Any["host_ast"]
    add("record_kind", value; reason = "record_kind")

    relation = request()
    relation["operation"] = "relations"
    relation["subjects"] = Any["rule:Top"]
    relation["record_kinds"] = Any[]
    relation["relation_kinds"] = Any["host_edge"]
    add("relation_kind", relation; reason = "relation_kind")

    value = request()
    value["record_kinds"] = Any["regex_slot", "rule"]
    add("record_kind_order", value; reason = "record_kind_order")

    relation = deepcopy(relation)
    relation["relation_kinds"] = Any["contains", "declares"]
    add("relation_kind_order", relation; reason = "relation_kind_order")

    value = request()
    value["direction"] = "sideways"
    add("direction", value; reason = "direction")

    value = request()
    value["page"]["after_id"] = 7
    add("after_id", value; reason = "after_id")

    value = request()
    value["page"]["limit"] = 0
    add("page_limit", value; reason = "page_limit")

    for (field, invalid) in (("max_records", 0), ("max_relations", 0), ("max_depth", 9))
        value = request()
        value["budget"][field] = invalid
        add(field, value; reason = field)
    end

    value = request()
    value["source"]["detail"] = "full"
    add("source_policy", value; reason = "source_policy")

    value = request()
    value["source"]["include_content_digest"] = 0
    add("numeric_boolean", value; reason = "source_policy")

    value = request()
    value["source"]["include_content_digest"] = true
    add("digest_requires_text", value; reason = "digest_requires_text")

    value = request()
    value["subjects"] = Any["rule:Top"]
    add("operation_combination", value; reason = "operation_combination")

    value = request()
    value["operation"] = "get"
    value["subjects"] = Any["rule:Unknown"]
    value["record_kinds"] = Any[]
    add("unknown_subject", value; reason = "unknown_subject")

    value = request()
    value["page"]["after_id"] = "rule:Unknown"
    add(
        "after_id_not_in_primary_stream",
        value;
        reason = "after_id_not_in_primary_stream",
    )

    value = request()
    value["operation"] = "explain"
    value["subjects"] = Any["rule:Child"]
    value["record_kinds"] = Any[]
    add("not_explainable", value; reason = "not_explainable")
    return cases
end

@testset "Semantic index public typed and raw-neutral query" begin
    @testset "nineteen exact typed and neutral response hashes" begin
        static_cases = [
            query_case for query_case in _SEMANTIC_QUERY_KERNEL_CONTRACT["query_cases"] if
            query_case["id"] != "runtime_events"
        ]
        @test length(static_cases) == 19
        for query_case in static_cases
            id = query_case["id"]
            raw = deepcopy(query_case["request"])
            before = deepcopy(raw)
            request = _semantic_query_kernel_request(raw)
            index = _semantic_query_kernel_index(query_case["snapshot"])
            typed = id == "capabilities" ?
                    semantic_capabilities(index) : semantic_query(index, request)
            neutral = semantic_query_neutral(index, raw)

            @test raw == before
            @test typed == neutral
            @test typed isa SemanticQueryResponse
            @test _semantic_query_kernel_digest(typed) ==
                  query_case["expected"]["response_sha256"]
        end
    end

    @testset "twenty-six exact portable raw boundaries" begin
        cases = _semantic_query_public_invalid_cases()
        @test length(cases) == 26
        index = _semantic_query_kernel_index("graph")
        for query_case in cases
            before = deepcopy(query_case.request)
            response = semantic_query_neutral(index, query_case.request)
            diagnostic = to_json(only(response.diagnostics))

            @test query_case.request == before
            @test !response.ok
            @test diagnostic["code"] == query_case.code
            if query_case.reason !== nothing
                @test diagnostic["fields"]["reason"] == query_case.reason
            end
            @test isempty(response.records)
            @test isempty(response.relations)
            @test response.cost == SemanticQueryCost(0, 0, 0)
        end
    end

    @testset "raw numeric ranks reject Julia booleans" begin
        index = _semantic_query_kernel_index("graph")
        for (container, field, reason) in (
            ("page", "limit", "page_limit"),
            ("budget", "max_records", "max_records"),
            ("budget", "max_relations", "max_relations"),
            ("budget", "max_depth", "max_depth"),
        )
            request = _semantic_query_public_request("graph_list_rules")
            request[container][field] = true
            response = semantic_query_neutral(index, request)
            @test !response.ok
            @test to_json(only(response.diagnostics))["fields"]["reason"] == reason
        end

        typed_invalid = SemanticQuery(
            SemanticQueryListOperation;
            record_kinds = ("host_ast",),
        )
        typed_response = semantic_query(index, typed_invalid)
        @test !typed_response.ok
        @test to_json(only(typed_response.diagnostics))["fields"]["reason"] == "record_kind"
    end

    @testset "responses inputs and interleaving stay detached" begin
        index = _semantic_query_kernel_index("graph")
        capabilities = semantic_capabilities(index)
        mutable = to_json(capabilities)
        mutable["records"][1]["facts"]["record_kinds"][1] = "host-private"
        list_request = _semantic_query_kernel_request(
            _semantic_query_public_request("graph_list_rules"),
        )
        explain_request = _semantic_query_kernel_request(
            _semantic_query_public_request("graph_explain_entry"),
        )
        first = semantic_query(index, explain_request)
        middle = semantic_query(index, list_request)
        second = semantic_query(index, explain_request)

        @test first == second
        @test first != middle
        @test _semantic_query_kernel_digest(semantic_capabilities(index)) ==
              _semantic_query_kernel_case("capabilities")["expected"]["response_sha256"]
        @test to_json(capabilities)["records"][1]["facts"]["record_kinds"][1] ==
              "capabilities"

        raw = _semantic_query_public_request("graph_list_rules")
        response = semantic_query_neutral(index, raw)
        json3_response = semantic_query_neutral(index, JSON3.read(JSON3.write(raw)))
        raw["record_kinds"][1] = "host_ast"
        @test response == semantic_query(index, list_request)
        @test json3_response == response
    end

    @testset "complete public exports and projection-only denial" begin
        public_names = names(LinkedSpecJulia)
        for name in (
            :SemanticQueryOperation,
            :SemanticQueryCapabilitiesOperation,
            :SemanticQueryListOperation,
            :SemanticQueryGetOperation,
            :SemanticQueryRelationsOperation,
            :SemanticQueryExplainOperation,
            :SemanticQueryDirection,
            :SemanticQueryOutgoingDirection,
            :SemanticQueryIncomingDirection,
            :SemanticQueryBothDirection,
            :SemanticQueryPage,
            :SemanticQueryBudget,
            :SemanticQuerySource,
            :SemanticQuery,
            :SemanticQuerySourceReference,
            :SemanticQueryRecord,
            :SemanticQueryRelation,
            :SemanticQueryDiagnostic,
            :SemanticQueryPageState,
            :SemanticQueryCost,
            :SemanticQueryResponse,
            :semantic_capabilities,
            :semantic_query,
            :semantic_query_neutral,
        )
            @test name in public_names
        end
        @test !(:_semantic_query_kernel in public_names)

        callback_called = Ref(false)
        callback = () -> (callback_called[] = true)
        raw = _semantic_query_public_request("graph_list_rules")
        raw["operation"] = callback
        callback_response = semantic_query_neutral(_semantic_query_kernel_index("graph"), raw)
        @test !callback_called[]
        @test to_json(only(callback_response.diagnostics))["fields"]["reason"] == "operation"

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
