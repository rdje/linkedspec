# FUTURE-PARITY-BACKLOG.10.6.6.2 — immutable observed runtime projection.

const JULIA_RUNTIME_PROJECTION_RESPONSE_DIGEST =
    "36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887"

function _julia_runtime_projection_source()
    return read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "semantic_introspection",
            "runtime.spec",
        ),
        String,
    )
end

function _julia_runtime_projection_base()
    return semantic_index(
        _julia_runtime_projection_source();
        logical_name = "runtime.spec",
        source_detail_ceiling = SemanticSourceTextDetail,
    )
end

function _julia_runtime_projection_capture()
    compiled = _julia_runtime_observation_compile(
        _julia_runtime_projection_source(),
    )
    return last(_julia_runtime_observation_capture() do sink
        runtime_parse(
            LinkedSpecRuntimeEngine(compiled),
            JULIA_RUNTIME_OBSERVATION_INPUT;
            semantic_observation_sink = sink,
        )
    end)
end

function _julia_runtime_projection_slot(;
    contract_id = RUNTIME_SEMANTIC_OBSERVATION_CONTRACT,
    rule_label = "Top",
    target_rule = "Top",
    regex_index = 0,
    position = 1,
    input_identity = nothing,
    status = nothing,
)
    return RuntimeSemanticObservationEvent(
        contract_id = contract_id,
        event_kind = RuntimeSemanticRegexSlotSelected,
        rule_label = rule_label,
        target_rule = target_rule,
        regex_index = regex_index,
        position = position,
        input_identity = input_identity,
        status = status,
    )
end

function _julia_runtime_projection_result(;
    contract_id = RUNTIME_SEMANTIC_OBSERVATION_CONTRACT,
    rule_label = "Top",
    target_rule = nothing,
    regex_index = nothing,
    position = 2,
    input_identity = JULIA_RUNTIME_OBSERVATION_INPUT_IDENTITY,
    status = "succeeded",
)
    return RuntimeSemanticObservationEvent(
        contract_id = contract_id,
        event_kind = RuntimeSemanticRuleResult,
        rule_label = rule_label,
        target_rule = target_rule,
        regex_index = regex_index,
        position = position,
        input_identity = input_identity,
        status = status,
    )
end

function _julia_runtime_projection_events()
    return RuntimeSemanticObservationEvent[
        _julia_runtime_projection_slot(),
        _julia_runtime_projection_slot(regex_index = 1, position = 2),
        _julia_runtime_projection_result(),
    ]
end

function _julia_runtime_projection_error(index, observation)
    return try
        with_execution_observation(index, observation)
        nothing
    catch error
        error
    end
end

@testset "Julia immutable semantic runtime observation projection" begin
    @testset "derived snapshot matches the twentieth typed and neutral digest" begin
        base = _julia_runtime_projection_base()
        events = _julia_runtime_projection_capture()
        query_case = _semantic_query_kernel_case("runtime_events")
        request = _semantic_query_kernel_request(query_case["request"])
        raw_request = deepcopy(query_case["request"])

        @test events == _julia_runtime_projection_events()
        @test !semantic_snapshot(base).has_execution
        @test isempty(semantic_query(base, request).records)
        derived = with_execution_observation(base, events)
        @test semantic_snapshot(derived).has_execution
        @test occursin("has_execution=true", sprint(show, derived))
        typed = semantic_query(derived, request)
        neutral = semantic_query_neutral(derived, raw_request)

        @test typed == neutral
        @test [record.id for record in typed.records] == [
            "execution:0",
            "event:execution:0:0",
            "event:execution:0:1",
            "event:execution:0:2",
        ]
        @test _semantic_query_kernel_digest(typed) ==
              JULIA_RUNTIME_PROJECTION_RESPONSE_DIGEST
        @test _semantic_query_kernel_digest(typed) ==
              query_case["expected"]["response_sha256"]

        relation_request = SemanticQuery(
            SemanticQueryRelationsOperation;
            subjects = ("execution:0",),
            relation_kinds = ("observed_as",),
            source = SemanticQuerySource(detail = SemanticSourceIdentityDetail),
        )
        relations = semantic_query(derived, relation_request)
        @test [relation.id for relation in relations.relations] == [
            "relation:observed_as:execution:0:event:execution:0:0:0",
            "relation:observed_as:execution:0:event:execution:0:1:1",
            "relation:observed_as:execution:0:event:execution:0:2:2",
        ]
        @test [collect(relation.evidence_ids) for relation in relations.relations] == [
            ["regex:rule:Top:0"],
            ["regex:rule:Top:1"],
            ["rule:Top"],
        ]

        events[1] = _julia_runtime_projection_slot(position = 999)
        detached = to_json(typed)
        detached["records"][1]["facts"]["status"] = "mutated"
        @test _semantic_query_kernel_digest(semantic_query(derived, request)) ==
              JULIA_RUNTIME_PROJECTION_RESPONSE_DIGEST
        @test !semantic_snapshot(base).has_execution
        @test isempty(semantic_query(base, request).records)
    end

    @testset "malformed foreign reordered and duplicate-final events reject" begin
        base = _julia_runtime_projection_base()
        valid = _julia_runtime_projection_events()
        cases = Any[
            ("not a vector", tuple(valid...)),
            ("non-event", Any[valid[1], "host", valid[3]]),
            ("empty", RuntimeSemanticObservationEvent[]),
            ("missing result", valid[1:2]),
            ("duplicate final", [valid..., valid[end]]),
            ("reordered final", [valid[1], valid[3], valid[2]]),
            (
                "foreign contract",
                [
                    _julia_runtime_projection_slot(contract_id = "future-contract"),
                    valid[2],
                    valid[3],
                ],
            ),
            (
                "missing rule label",
                [_julia_runtime_projection_slot(rule_label = ""), valid[2], valid[3]],
            ),
            (
                "missing slot target",
                [_julia_runtime_projection_slot(target_rule = nothing), valid[2], valid[3]],
            ),
            (
                "empty slot target",
                [_julia_runtime_projection_slot(target_rule = ""), valid[2], valid[3]],
            ),
            (
                "missing slot index",
                [_julia_runtime_projection_slot(regex_index = nothing), valid[2], valid[3]],
            ),
            (
                "negative slot index",
                [_julia_runtime_projection_slot(regex_index = -1), valid[2], valid[3]],
            ),
            (
                "negative slot position",
                [_julia_runtime_projection_slot(position = -1), valid[2], valid[3]],
            ),
            (
                "slot carries input identity",
                [
                    _julia_runtime_projection_slot(
                        input_identity = JULIA_RUNTIME_OBSERVATION_INPUT_IDENTITY,
                    ),
                    valid[2],
                    valid[3],
                ],
            ),
            (
                "slot carries result status",
                [_julia_runtime_projection_slot(status = "succeeded"), valid[2], valid[3]],
            ),
            (
                "result carries slot state",
                [
                    valid[1],
                    valid[2],
                    _julia_runtime_projection_result(
                        target_rule = "Top",
                        regex_index = 0,
                    ),
                ],
            ),
            (
                "foreign slot",
                [_julia_runtime_projection_slot(target_rule = "Missing"), valid[2], valid[3]],
            ),
            (
                "foreign result rule",
                [valid[1], valid[2], _julia_runtime_projection_result(rule_label = "Missing")],
            ),
            (
                "failed result",
                [valid[1], valid[2], _julia_runtime_projection_result(status = "failed")],
            ),
            (
                "missing result status",
                [valid[1], valid[2], _julia_runtime_projection_result(status = nothing)],
            ),
            (
                "negative result position",
                [valid[1], valid[2], _julia_runtime_projection_result(position = -1)],
            ),
            (
                "missing input identity",
                [valid[1], valid[2], _julia_runtime_projection_result(input_identity = nothing)],
            ),
            (
                "malformed input identity",
                [
                    valid[1],
                    valid[2],
                    _julia_runtime_projection_result(
                        input_identity = "input:sha256:xyz",
                    ),
                ],
            ),
            (
                "uppercase input identity",
                [
                    valid[1],
                    valid[2],
                    _julia_runtime_projection_result(
                        input_identity = string(
                            "input:sha256:",
                            uppercase(last(split(
                                JULIA_RUNTIME_OBSERVATION_INPUT_IDENTITY,
                                ':',
                            ))),
                        ),
                    ),
                ],
            ),
        ]
        @test length(cases) == 24
        for (label, observation) in cases
            captured = _julia_runtime_projection_error(base, observation)
            @test captured isa SemanticIndexError
            @test captured.stage == "execution_observation"
            @test captured.code == "semantic_index_invalid_observation"
            @test !isempty(captured.message)
            @test !isempty(label)
        end
    end

    @testset "selecting rule must own the selected slot relation" begin
        unrelated = semantic_index(
            """
Top::
 /a/ -> Top[0] { return("top") }

Other::
 /b/ -> Other[0] { return("other") }
""";
            logical_name = "unrelated.spec",
            source_detail_ceiling = SemanticSourceTextDetail,
        )
        events = RuntimeSemanticObservationEvent[
            _julia_runtime_projection_slot(rule_label = "Top", target_rule = "Other"),
            _julia_runtime_projection_result(rule_label = "Top"),
        ]
        captured = _julia_runtime_projection_error(unrelated, events)
        @test captured isa SemanticIndexError
        @test occursin(
            "does not select regex slot 'Other[0]'",
            captured.message,
        )
    end

    @testset "already observed and failed bases cannot derive again" begin
        valid = _julia_runtime_projection_events()
        derived = with_execution_observation(_julia_runtime_projection_base(), valid)
        repeated = _julia_runtime_projection_error(derived, valid)
        @test repeated isa SemanticIndexError
        @test repeated.stage == "execution_observation"
        @test repeated.code == "semantic_index_invalid_observation"

        failed = semantic_index(
            "Top:: Missing\n";
            logical_name = "failed.spec",
            source_detail_ceiling = SemanticSourceSpanDetail,
        )
        @test semantic_snapshot(failed).state == SemanticFailedCompilationSnapshotState
        failed_error = _julia_runtime_projection_error(failed, valid)
        @test failed_error isa SemanticIndexError
        @test failed_error.stage == "execution_observation"
        @test failed_error.code == "semantic_index_invalid_observation"
    end

    @testset "public derivation remains projection-only" begin
        @test :with_execution_observation in names(LinkedSpecJulia)
        implementation = read(
            joinpath(
                REPO_ROOT,
                "julia",
                "src",
                "semantic",
                "SemanticRuntimeProjection.jl",
            ),
            String,
        )
        for forbidden in (
            "parse_spec(",
            "validate_spec(",
            "compile_spec(",
            "runtime_parse(",
            "runtime_execute(",
            "LinkedSpecRuntimeEngine(",
            "LinkedSpecTraceEmitter(",
            "semantic_observation_sink",
            "SHA.sha256(",
            "ENV[",
            "read(",
            "open(",
        )
            @test !occursin(forbidden, implementation)
        end
    end
end
