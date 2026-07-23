# FUTURE-PARITY-BACKLOG.10.6.4.2 — exact staged and generated provenance.

function _semantic_call_staged_expected()
    snapshot = only(
        candidate for candidate in SEMANTIC_CALL_CORE_MODEL["snapshots"] if
        candidate["id"] == "calls"
    )
    result = JSON3.read(JSON3.write(snapshot), Dict{String,Any})
    delete!(result, "id")
    delete!(result, "fixture")
    return result
end

function _semantic_call_staged_definition(
    definition;
    body_payload = definition.body_payload,
    body_parse_job = definition.body_parse_job,
)
    return LinkedSpecJulia.FunctionDefinition(
        name = definition.name,
        params = definition.params,
        arity = definition.arity,
        signature = definition.signature,
        body_source = definition.body_source,
        body_payload = body_payload,
        body_parse_job = body_parse_job,
        body_ast = definition.body_ast,
        source = definition.source,
        source_span = definition.source_span,
        body_span = definition.body_span,
    )
end

function _semantic_call_staged_rebuild(index, generated_plan; entry_selection = nothing)
    outcome = LinkedSpecJulia._semantic_compilation_outcome(index)
    selection = entry_selection === nothing ? outcome.entry : entry_selection
    return LinkedSpecJulia._build_compiled_semantic_static_projection(
        getfield(index, :_source_text),
        getfield(index, :_source_map),
        getfield(index, :_logical_name),
        getfield(index, :_content_digest),
        semantic_snapshot(index),
        outcome.parsed,
        outcome.compiled,
        selection,
        generated_plan,
    )
end

function _semantic_call_staged_error(callback)
    try
        callback()
    catch error
        return error
    end
    return nothing
end

@testset "Semantic index staged and generated call provenance" begin
    @testset "exact complete 22/25 target" begin
        projection = LinkedSpecJulia._semantic_static_projection_for_testing(
            _semantic_call_core_index(),
        )
        actual = _semantic_call_core_materialize(projection)
        wanted = _semantic_call_core_materialize(_semantic_call_staged_expected())

        @test length(projection["records"]) == 22
        @test length(projection["relations"]) == 25
        @test length(projection["source_refs"]) == 10
        @test actual == wanted

        staged = [
            record for record in projection["records"] if
            record["kind"] == "staged_artifact"
        ]
        @test [record["id"] for record in staged] == [
            "staged:payload:function:normalize:0",
            "staged:parse_job:function:normalize:1",
            "staged:result:function:normalize:2",
        ]
        @test [record["facts"]["artifact_kind"] for record in staged] == [
            "payload",
            "parse_job",
            "result",
        ]
        @test [record["facts"]["node_kind"] for record in staged] == [
            "action_source",
            "action_program",
            "action_program",
        ]
        @test [record["facts"]["value_shape"]["kind"] for record in staged] == [
            "string",
            "unknown",
            "unknown",
        ]
        @test all(record["facts"]["status"] == "succeeded" for record in staged)
        @test all(record["facts"]["parent_path"] == Any["function:normalize"] for record in staged)

        function_source = _semantic_call_core_record(
            projection,
            "function:normalize",
        )["source"]
        @test all(record["source"] == function_source for record in staged)
        @test projection["source_refs"][function_source]["excerpt"] ==
              "fn normalize(value) { return(trim(value)) }"

        generated = _semantic_call_core_record(
            projection,
            "generated:handler_plan:0",
        )
        @test generated["kind"] == "generated_artifact"
        @test generated["source"] === nothing
        @test generated["facts"] == Dict{String,Any}(
            "artifact_kind" => "handler_plan",
            "contract_id" => "linkedspec-generated-source-v2",
            "format_version" => 2,
            "plan_family" => "default",
        )

        relation_ids = Set(relation["id"] for relation in projection["relations"])
        for id in (
            "relation:contains:function:normalize:staged:payload:function:normalize:0:0",
            "relation:contains:function:normalize:staged:parse_job:function:normalize:1:1",
            "relation:contains:function:normalize:staged:result:function:normalize:2:2",
            "relation:lowered_from:staged:payload:function:normalize:0:source:0:0",
            "relation:consumes:staged:parse_job:function:normalize:1:staged:payload:function:normalize:0:0",
            "relation:produces:staged:parse_job:function:normalize:1:staged:result:function:normalize:2:0",
            "relation:lowered_from:staged:result:function:normalize:2:staged:payload:function:normalize:0:0",
            "relation:staged_by:staged:result:function:normalize:2:staged:parse_job:function:normalize:1:0",
            "relation:generated_as:spec:0:generated:handler_plan:0:0",
        )
            @test id in relation_ids
        end
    end

    @testset "native staged sidecars must match their typed owner" begin
        index = _semantic_call_core_index()
        outcome = LinkedSpecJulia._semantic_compilation_outcome(index)
        entry = only(outcome.compiled.function_registry.entries)

        bad_payload = JSON3.read(
            JSON3.write(entry.definition.body_payload),
            Dict{String,Any},
        )
        bad_payload["kind"] = "wrong_payload"
        payload_error = _semantic_call_staged_error(() ->
            LinkedSpecJulia._semantic_call_validate_staged_authority(
                LinkedSpecJulia.UserFunctionEntry(
                    entry.index,
                    _semantic_call_staged_definition(
                        entry.definition;
                        body_payload = bad_payload,
                    ),
                ),
            )
        )
        @test payload_error isa SemanticIndexError
        @test payload_error.stage == "project_call_semantics"
        @test payload_error.code == "semantic_call_correlation_failed"
        @test payload_error.message ==
              "Native staged function metadata does not match its typed owner"

        job = entry.definition.body_parse_job
        bad_job = LinkedSpecJulia.StagedParseJob(
            version = job.version,
            job_id = job.job_id,
            parent_ast_path = job.parent_ast_path,
            node_kind = job.node_kind,
            payload_kind = job.payload_kind,
            function_name = job.function_name,
            params = job.params,
            arity = job.arity,
            signature = job.signature,
            text = job.text,
            source_span = job.source_span,
            parser_spec_id = job.parser_spec_id,
            top_rule = "wrong_top_rule",
            result_policy = job.result_policy,
            result_field = job.result_field,
            failure_policy = job.failure_policy,
            diagnostic_owner = job.diagnostic_owner,
        )
        job_error = _semantic_call_staged_error(() ->
            LinkedSpecJulia._semantic_call_validate_staged_authority(
                LinkedSpecJulia.UserFunctionEntry(
                    entry.index,
                    _semantic_call_staged_definition(
                        entry.definition;
                        body_parse_job = bad_job,
                    ),
                ),
            )
        )
        @test job_error isa SemanticIndexError
        @test job_error.stage == "project_call_semantics"
        @test job_error.code == "semantic_call_correlation_failed"
        @test job_error.message ==
              "Native staged function metadata does not match its typed owner"
    end

    @testset "retained generated plan identity and selection are exact" begin
        index = _semantic_call_core_index()
        outcome = LinkedSpecJulia._semantic_compilation_outcome(index)
        plan = outcome.generated_plan

        bad_contract = SemanticGeneratedPlanInput(
            contract_id = "wrong-contract",
            format_version = plan.format_version,
            source_identity = plan.source_identity,
            rows = plan.rows,
        )
        contract_error = _semantic_call_staged_error(
            () -> _semantic_call_staged_rebuild(index, bad_contract),
        )
        @test contract_error isa SemanticIndexError
        @test contract_error.code == "semantic_call_correlation_failed"
        @test contract_error.message ==
              "Retained generated plan does not match compiled semantic authority"

        bad_identity = SemanticGeneratedPlanInput(
            contract_id = plan.contract_id,
            format_version = plan.format_version,
            source_identity = "wrong.spec",
            rows = plan.rows,
        )
        identity_error = _semantic_call_staged_error(
            () -> _semantic_call_staged_rebuild(index, bad_identity),
        )
        @test identity_error isa SemanticIndexError
        @test identity_error.code == "semantic_call_correlation_failed"

        bad_order = SemanticGeneratedPlanInput(
            contract_id = plan.contract_id,
            format_version = plan.format_version,
            source_identity = plan.source_identity,
            rows = reverse(plan.rows),
        )
        order_error = _semantic_call_staged_error(
            () -> _semantic_call_staged_rebuild(index, bad_order),
        )
        @test order_error isa SemanticIndexError
        @test order_error.code == "semantic_call_correlation_failed"

        selection_error = _semantic_call_staged_error(() ->
            _semantic_call_staged_rebuild(
                index,
                plan;
                entry_selection = SemanticEntrySelection(
                    "Missing",
                    "explicit_selector",
                ),
            )
        )
        @test selection_error isa SemanticIndexError
        @test selection_error.code == "semantic_call_correlation_failed"
        @test selection_error.message ==
              "Generated plan has no unique selected entry row"
        @test Dict(selection_error.fields)["selected_rows"] == 0
    end

    @testset "complete projection remains detached private and host-free" begin
        index = _semantic_call_core_index()
        first = LinkedSpecJulia._semantic_static_projection_for_testing(index)
        _semantic_call_core_record(
            first,
            "staged:payload:function:normalize:0",
        )["facts"]["status"] = "injected"
        _semantic_call_core_record(
            first,
            "generated:handler_plan:0",
        )["facts"]["plan_family"] = "injected"

        second = LinkedSpecJulia._semantic_static_projection_for_testing(index)
        @test _semantic_call_core_record(
            second,
            "staged:payload:function:normalize:0",
        )["facts"]["status"] == "succeeded"
        @test _semantic_call_core_record(
            second,
            "generated:handler_plan:0",
        )["facts"]["plan_family"] == "default"
        @test !occursin("injected", JSON3.write(second))
        @test JSON3.read(JSON3.write(second), Dict{String,Any}) == second
        @test _semantic_call_core_plain(second)
        @test !occursin(r"/(?:Users|home|tmp)/", JSON3.write(second))

        retained = getfield(index, :_static_projection)
        @test retained.records.values isa Tuple
        @test retained.relations.values isa Tuple
        @test !isdefined(LinkedSpecJulia, :semantic_staged_artifacts)
        @test !isdefined(LinkedSpecJulia, :semantic_generated_artifacts)
        @test !(:_semantic_call_add_generated_plan! in names(LinkedSpecJulia))

        implementation = read(
            joinpath(@__DIR__, "..", "src", "semantic", "SemanticCallProjection.jl"),
            String,
        )
        for forbidden in (
            "build_generated_rule_plan(",
            "emit_julia_source",
            "execute_generated",
            "generated_source =",
            "runtime_execute(",
            "LINKEDSPEC_TRACE_LEVEL",
            "diagnostic_output_sink",
            "runtime_observer",
        )
            @test !occursin(forbidden, implementation)
        end
    end
end
