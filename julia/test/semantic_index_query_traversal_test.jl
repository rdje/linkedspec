# FUTURE-PARITY-BACKLOG.10.6.5.2 — exact private traversal, paging, budgets, and costs.

const _SEMANTIC_QUERY_TRAVERSAL_CASES = (
    "graph_reverse_dispatch",
    "staged_chain",
    "generated_provenance",
    "pagination_after_id",
    "page_boundary",
    "budget_prefix",
    "relation_budget_prefix",
    "relation_depth_zero",
    "unsupported_contract",
    "invalid_operation_combination",
)

function _semantic_query_traversal_response(id)
    query_case = _semantic_query_kernel_case(id)
    return LinkedSpecJulia._semantic_query_kernel(
        _semantic_query_kernel_index(query_case["snapshot"]),
        _semantic_query_kernel_request(query_case["request"]),
    )
end

function _semantic_query_traversal_diagnostic_limit(response)
    diagnostic = only(response.diagnostics)
    return to_json(diagnostic)["fields"]["limit"]
end

@testset "Semantic index private query traversal and limits" begin
    responses = Dict{String,Any}()

    @testset "ten exact completion response hashes" begin
        @test length(_SEMANTIC_QUERY_TRAVERSAL_CASES) == 10
        for id in _SEMANTIC_QUERY_TRAVERSAL_CASES
            query_case = _semantic_query_kernel_case(id)
            response = _semantic_query_traversal_response(id)
            expected = query_case["expected"]
            responses[id] = response

            @test response.ok == expected["ok"]
            @test [record.id for record in response.records] == expected["record_ids"]
            @test [relation.id for relation in response.relations] ==
                  expected["relation_ids"]
            @test [diagnostic.code for diagnostic in response.diagnostics] ==
                  expected["diagnostic_codes"]
            @test response.page.complete == expected["complete"]
            @test _semantic_query_kernel_digest(response) == expected["response_sha256"]
        end
    end

    @testset "all nineteen static hashes compose" begin
        static_cases = [
            query_case for query_case in _SEMANTIC_QUERY_KERNEL_CONTRACT["query_cases"] if
            query_case["id"] != "runtime_events"
        ]
        @test length(static_cases) == 19
        for query_case in static_cases
            response = LinkedSpecJulia._semantic_query_kernel(
                _semantic_query_kernel_index(query_case["snapshot"]),
                _semantic_query_kernel_request(query_case["request"]),
            )
            @test _semantic_query_kernel_digest(response) ==
                  query_case["expected"]["response_sha256"]
        end
    end

    @testset "canonical relation traversal and logical depth" begin
        reverse = responses["graph_reverse_dispatch"]
        staged = responses["staged_chain"]
        generated = responses["generated_provenance"]

        @test reverse.cost == LinkedSpecJulia.SemanticQueryCost(0, 2, 1)
        @test staged.cost == LinkedSpecJulia.SemanticQueryCost(0, 2, 1)
        @test generated.cost == LinkedSpecJulia.SemanticQueryCost(0, 1, 1)
        @test reverse.page == LinkedSpecJulia.SemanticQueryPageState(nothing, nothing, true)

        both = LinkedSpecJulia.SemanticQuery(
            LinkedSpecJulia.SemanticQueryRelationsOperation;
            subjects = ("rule:Child",),
            relation_kinds = ("dispatches_to",),
            direction = LinkedSpecJulia.SemanticQueryBothDirection,
        )
        both_response = LinkedSpecJulia._semantic_query_kernel(
            _semantic_query_kernel_index("graph"),
            both,
        )
        @test [relation.id for relation in both_response.relations] ==
              [relation.id for relation in reverse.relations]
        @test both_response.cost == LinkedSpecJulia.SemanticQueryCost(0, 2, 1)
    end

    @testset "pages budgets and deterministic prefixes" begin
        after_id = responses["pagination_after_id"]
        boundary = responses["page_boundary"]
        records = responses["budget_prefix"]
        relations = responses["relation_budget_prefix"]
        depth_zero = responses["relation_depth_zero"]

        @test after_id.page ==
              LinkedSpecJulia.SemanticQueryPageState("rule:Child", nothing, true)
        @test after_id.cost == LinkedSpecJulia.SemanticQueryCost(2, 0, 0)
        @test boundary.page ==
              LinkedSpecJulia.SemanticQueryPageState(nothing, "rule:Top", false)
        @test boundary.cost == LinkedSpecJulia.SemanticQueryCost(1, 0, 0)
        @test isempty(boundary.diagnostics)

        @test records.page.next_after_id == "source:0"
        @test records.cost == LinkedSpecJulia.SemanticQueryCost(2, 0, 0)
        @test _semantic_query_traversal_diagnostic_limit(records) == "max_records"
        @test relations.page.next_after_id ==
              "relation:contains:rule:Top:edge:rule:Top:1:1"
        @test relations.cost == LinkedSpecJulia.SemanticQueryCost(0, 2, 1)
        @test _semantic_query_traversal_diagnostic_limit(relations) == "max_relations"
        @test depth_zero.page ==
              LinkedSpecJulia.SemanticQueryPageState(nothing, nothing, false)
        @test depth_zero.cost == LinkedSpecJulia.SemanticQueryCost(0, 0, 0)
        @test _semantic_query_traversal_diagnostic_limit(depth_zero) == "max_depth"
    end

    @testset "typed portable errors and cursor rejection" begin
        unsupported = responses["unsupported_contract"]
        invalid = responses["invalid_operation_combination"]
        @test to_json(only(unsupported.diagnostics))["fields"] == Dict{String,Any}(
            "requested" => "linkedspec-semantic-query-v0",
            "supported" => Any["linkedspec-semantic-query-v1"],
        )
        @test to_json(only(invalid.diagnostics))["fields"] ==
              Dict{String,Any}("reason" => "operation_combination")

        bad_cursor = LinkedSpecJulia.SemanticQuery(
            LinkedSpecJulia.SemanticQueryListOperation;
            record_kinds = ("rule",),
            page = LinkedSpecJulia.SemanticQueryPage(after_id = "rule:Missing"),
        )
        bad_cursor_response = LinkedSpecJulia._semantic_query_kernel(
            _semantic_query_kernel_index("graph"),
            bad_cursor,
        )
        @test !bad_cursor_response.ok
        @test bad_cursor_response.page.after_id == "rule:Missing"
        @test to_json(only(bad_cursor_response.diagnostics))["fields"] ==
              Dict{String,Any}("reason" => "after_id_not_in_primary_stream")

        unknown_subject = LinkedSpecJulia.SemanticQuery(
            LinkedSpecJulia.SemanticQueryRelationsOperation;
            subjects = ("rule:Missing",),
        )
        unknown_response = LinkedSpecJulia._semantic_query_kernel(
            _semantic_query_kernel_index("graph"),
            unknown_subject,
        )
        @test !unknown_response.ok
        @test to_json(only(unknown_response.diagnostics))["fields"] ==
              Dict{String,Any}("reason" => "unknown_subject")
    end

    @testset "explanation budgets reserve the decision" begin
        request = LinkedSpecJulia.SemanticQuery(
            LinkedSpecJulia.SemanticQueryExplainOperation;
            subjects = ("decision:entry:spec:0",),
            budget = LinkedSpecJulia.SemanticQueryBudget(max_records = 1),
            source = LinkedSpecJulia.SemanticQuerySource(detail = SemanticSourceSpanDetail),
        )
        response = LinkedSpecJulia._semantic_query_kernel(
            _semantic_query_kernel_index("graph"),
            request,
        )
        @test [record.id for record in response.records] == ["decision:entry:spec:0"]
        @test isempty(response.relations)
        @test response.page ==
              LinkedSpecJulia.SemanticQueryPageState(nothing, nothing, false)
        @test response.cost == LinkedSpecJulia.SemanticQueryCost(1, 0, 0)
        @test _semantic_query_traversal_diagnostic_limit(response) == "max_records"
    end

    @testset "relation values stay detached and private" begin
        first = responses["graph_reverse_dispatch"]
        mutable = to_json(first)
        mutable["relations"][1]["facts"]["host_private"] = true
        second = _semantic_query_traversal_response("graph_reverse_dispatch")

        @test _semantic_query_kernel_digest(second) ==
              _semantic_query_kernel_case("graph_reverse_dispatch")["expected"][
                  "response_sha256"
              ]
        @test !haskey(to_json(first)["relations"][1]["facts"], "host_private")
        @test all(
            relation ->
                _semantic_query_kernel_has_no_mutable_container(relation.facts) &&
                _semantic_query_kernel_has_no_mutable_container(relation.evidence_ids),
            first.relations,
        )
        @test :semantic_query in names(LinkedSpecJulia)
        @test :semantic_query_neutral in names(LinkedSpecJulia)
    end
end
