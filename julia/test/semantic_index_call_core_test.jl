# FUTURE-PARITY-BACKLOG.10.6.4.1 — exact private typed call core.

const SEMANTIC_CALL_CORE_ROOT = normpath(
    joinpath(@__DIR__, "..", "..", "capability_conformance", "semantic_introspection"),
)

const SEMANTIC_CALL_CORE_MODEL = JSON3.read(
    read(
        joinpath(SEMANTIC_CALL_CORE_ROOT, "..", "semantic_introspection_model.json"),
        String,
    ),
    Dict{String,Any},
)

const SEMANTIC_CALL_CORE_SOURCE = read(
    joinpath(SEMANTIC_CALL_CORE_ROOT, "calls_and_staging.spec"),
    String,
)

function _semantic_call_core_index(
    source::String = SEMANTIC_CALL_CORE_SOURCE;
    logical_name = "calls_and_staging.spec",
)
    return semantic_index(
        source;
        logical_name = logical_name,
        source_detail_ceiling = SemanticSourceTextDetail,
    )
end

function _semantic_call_core_expected()
    snapshot = only(
        candidate for candidate in SEMANTIC_CALL_CORE_MODEL["snapshots"] if
        candidate["id"] == "calls"
    )
    result = JSON3.read(JSON3.write(snapshot), Dict{String,Any})
    delete!(result, "id")
    delete!(result, "fixture")
    result["records"] = [
        record for record in result["records"] if
        !(record["kind"] in ("staged_artifact", "generated_artifact"))
    ]
    retained = Set(record["id"] for record in result["records"])
    result["relations"] = [
        relation for relation in result["relations"] if
        relation["from_id"] in retained && relation["to_id"] in retained
    ]
    return result
end

function _semantic_call_core_subset(projection::Dict{String,Any})
    result = JSON3.read(JSON3.write(projection), Dict{String,Any})
    result["records"] = [
        record for record in result["records"] if
        !(record["kind"] in ("staged_artifact", "generated_artifact"))
    ]
    retained = Set(record["id"] for record in result["records"])
    result["relations"] = [
        relation for relation in result["relations"] if
        relation["from_id"] in retained && relation["to_id"] in retained
    ]
    return result
end

function _semantic_call_core_materialize(projection::Dict{String,Any})
    result = JSON3.read(JSON3.write(projection), Dict{String,Any})
    source_refs = pop!(result, "source_refs")
    for group in ("records", "relations")
        for item in result[group]
            source = item["source"]
            source isa AbstractString || continue
            item["source"] = JSON3.read(
                JSON3.write(source_refs[source]),
                Dict{String,Any},
            )
        end
    end
    return result
end

function _semantic_call_core_record(projection, record_id)
    return only(record for record in projection["records"] if record["id"] == record_id)
end

function _semantic_call_core_plain(value)
    forbidden_keys = Set([
        "host_path",
        "file_path",
        "source_text",
        "source_bytes",
        "body_source",
        "body_payload",
        "body_parse_job",
        "body_ast",
        "ast",
        "action_ir",
        "descriptor",
        "compiled_regex",
        "generated_source",
        "executor",
        "trace",
        "diagnostic_sink",
        "runtime_observer",
    ])
    if value isa AbstractDict
        return all(key isa AbstractString && !(key in forbidden_keys) for key in keys(value)) &&
               all(_semantic_call_core_plain, values(value))
    elseif value isa AbstractVector
        return all(_semantic_call_core_plain, value)
    end
    return value === nothing || value isa AbstractString || value isa Number || value isa Bool
end

@testset "Semantic index private typed call core" begin
    @testset "exact non-staged 18/16 target" begin
        projection = LinkedSpecJulia._semantic_static_projection_for_testing(
            _semantic_call_core_index(),
        )
        core = _semantic_call_core_subset(projection)
        actual = _semantic_call_core_materialize(core)
        wanted = _semantic_call_core_materialize(_semantic_call_core_expected())

        @test length(core["records"]) == 18
        @test length(core["relations"]) == 16
        @test length(core["source_refs"]) == 10
        @test length(projection["records"]) - length(core["records"]) == 4
        @test length(projection["relations"]) - length(core["relations"]) == 9
        @test actual == wanted
        @test !any(
            record["kind"] in ("staged_artifact", "generated_artifact") for
            record in core["records"]
        )
        @test !any(
            relation["kind"] in (
                "consumes",
                "produces",
                "lowered_from",
                "staged_by",
                "generated_as",
            ) for relation in core["relations"]
        )

        spec = _semantic_call_core_record(projection, "spec:0")
        @test spec["facts"]["definition_order"] == [
            "function:normalize",
            "rule:Top",
            "rule:Done",
        ]
        @test spec["facts"]["compiled_rule_order"] == ["rule:Top", "rule:Done"]
        @test [
            record["id"] for record in projection["records"] if
            record["kind"] == "helper"
        ] == ["helper:trim", "helper:match_text", "helper:return"]
        @test [
            record["id"] for record in projection["records"] if
            record["kind"] == "call"
        ] == [
            "call:function:normalize:0",
            "call:edge:rule:Top:0:0",
            "call:edge:rule:Top:0:1",
            "call:edge:rule:Top:0:2",
        ]
        @test [
            record["order"] for record in projection["records"] if
            record["kind"] == "call"
        ] == collect(0:3)

        function_record = _semantic_call_core_record(projection, "function:normalize")
        @test function_record["facts"]["signature"] == Dict{String,Any}(
            "parameters" => Any[Dict{String,Any}(
                "name" => "value",
                "kind" => "value",
                "required" => true,
            )],
            "arity_min" => 1,
            "arity_max" => 1,
            "rest_parameter" => nothing,
            "final_codeblock" => false,
        )
        @test function_record["facts"]["parameter_kinds"] == Any["value"]
        @test function_record["facts"]["return_shape"]["kind"] == "string"

        normalize_call = _semantic_call_core_record(
            projection,
            "call:edge:rule:Top:0:0",
        )
        @test normalize_call["facts"]["resolution_kind"] == "user_function"
        @test normalize_call["facts"]["argument_shapes"][1]["kind"] == "string"
        @test normalize_call["facts"]["return_shape"]["kind"] == "string"
        @test normalize_call["facts"]["target_shape"]["kind"] == "user_function"
        @test _semantic_call_core_record(
            projection,
            "binding:edge:rule:Top:0:result:0",
        )["facts"]["value_shape"]["kind"] == "string"
        @test _semantic_call_core_record(
            projection,
            "edge:rule:Top:0",
        )["facts"]["value_shape"]["kind"] == "string"
        @test _semantic_call_core_record(
            projection,
            "rule:Top",
        )["facts"]["value_shape"]["kind"] == "string"

        relation_ids = Set(relation["id"] for relation in projection["relations"])
        @test "relation:calls:call:edge:rule:Top:0:0:function:normalize:0" in relation_ids
        @test "relation:writes:call:edge:rule:Top:0:0:binding:edge:rule:Top:0:result:0:0" in relation_ids
        @test "relation:reads:call:edge:rule:Top:0:2:binding:edge:rule:Top:0:result:0:0" in relation_ids
        @test count(
            relation -> relation["kind"] == "explained_by",
            projection["relations"],
        ) == 2
    end

    @testset "authored ordering and Unicode scalar evidence" begin
        source = """Top::
 /x/ -> Done {
   result = normalize(match_text())
   return(result)
 }

fn normalize(value) { return(trim(\"é\")) }

Done:
 /x/
"""
        projection = LinkedSpecJulia._semantic_static_projection_for_testing(
            _semantic_call_core_index(source),
        )
        spec = _semantic_call_core_record(projection, "spec:0")
        @test spec["facts"]["definition_order"] == [
            "rule:Top",
            "function:normalize",
            "rule:Done",
        ]
        @test [
            record["id"] for record in projection["records"] if
            record["kind"] == "edge"
        ] == ["edge:rule:Top:0"]

        call = _semantic_call_core_record(projection, "call:function:normalize:0")
        source_ref = projection["source_refs"][call["source"]]
        span = source_ref["span"]
        @test source_ref["excerpt"] == "trim(\"é\")"
        @test span["end_byte"] - span["start_byte"] == ncodeunits("trim(\"é\")")
        @test span["end_column"] - span["start_column"] == length("trim(\"é\")")
        @test ncodeunits(source_ref["excerpt"]) > length(source_ref["excerpt"])
        @test projection["source_refs"][
            _semantic_call_core_record(projection, "function:normalize")["source"]
        ]["excerpt"] == "fn normalize(value) { return(trim(\"é\")) }"
    end

    @testset "nested duplicate calls retain occurrence identity" begin
        source = """fn normalize(value) { return(trim(value)) }

Top::
 /x/ -> Done {
   result = normalize(normalize(match_text()))
   return(result)
 }

Done:
 /x/
"""
        projection = LinkedSpecJulia._semantic_static_projection_for_testing(
            _semantic_call_core_index(source),
        )
        calls = [record for record in projection["records"] if record["kind"] == "call"]
        @test [record["id"] for record in calls] == [
            "call:function:normalize:0",
            "call:edge:rule:Top:0:0",
            "call:edge:rule:Top:0:1",
            "call:edge:rule:Top:0:2",
            "call:edge:rule:Top:0:3",
        ]
        @test [record["name"] for record in calls] == [
            "trim",
            "normalize",
            "normalize",
            "match_text",
            "return",
        ]
        excerpts = [
            projection["source_refs"][record["source"]]["excerpt"] for record in calls
        ]
        @test excerpts == [
            "trim(value)",
            "normalize(normalize(match_text()))",
            "normalize(match_text())",
            "match_text()",
            "return(result)",
        ]
        @test [record["order"] for record in calls] == collect(0:4)
        @test count(
            relation -> relation["kind"] == "calls" &&
                        relation["to_id"] == "function:normalize",
            projection["relations"],
        ) == 2
    end

    @testset "regex literals cannot steal call source identity" begin
        source = """fn normalize(value) {
 pattern = /trim(fake())/i
 return(trim(value))
}

Top:
 /x/
"""
        projection = LinkedSpecJulia._semantic_static_projection_for_testing(
            _semantic_call_core_index(source; logical_name = "regex-call-text.spec"),
        )
        call = _semantic_call_core_record(projection, "call:function:normalize:0")
        @test call["name"] == "trim"
        @test projection["source_refs"][call["source"]]["excerpt"] == "trim(value)"
        @test !any(record["name"] == "fake" for record in projection["records"])
    end

    @testset "variadic signatures and rest shapes stay conservative" begin
        source = """fn gather(prefix, ...items) { return(items) }

Top::
 /x/ -> Done { return(gather(\"p\", \"a\", \"b\")) }

Done:
 /x/
"""
        projection = LinkedSpecJulia._semantic_static_projection_for_testing(
            _semantic_call_core_index(source; logical_name = "variadic-calls.spec"),
        )
        function_record = _semantic_call_core_record(projection, "function:gather")
        signature = function_record["facts"]["signature"]
        @test signature["parameters"] == Any[Dict{String,Any}(
            "name" => "prefix",
            "kind" => "value",
            "required" => true,
        )]
        @test signature["arity_min"] == 1
        @test signature["arity_max"] === nothing
        @test signature["rest_parameter"] == "items"
        @test signature["final_codeblock"] === false
        @test function_record["facts"]["parameter_kinds"] == Any["value"]
        @test function_record["facts"]["return_shape"]["kind"] == "array"
        @test function_record["facts"]["return_shape"]["element"]["kind"] == "unknown"

        call = _semantic_call_core_record(projection, "call:edge:rule:Top:0:1")
        @test call["name"] == "gather"
        @test call["facts"]["resolution_kind"] == "user_function"
        @test [shape["kind"] for shape in call["facts"]["argument_shapes"]] == [
            "string",
            "string",
            "string",
        ]
        @test call["facts"]["return_shape"]["kind"] == "array"
        @test _semantic_call_core_record(
            projection,
            "edge:rule:Top:0",
        )["facts"]["value_shape"]["kind"] == "array"
    end

    @testset "detached private owner and host isolation" begin
        index = _semantic_call_core_index()
        first_copy = LinkedSpecJulia._semantic_static_projection_for_testing(index)
        first_call = _semantic_call_core_record(first_copy, "call:function:normalize:0")
        first_call["facts"]["resolution_kind"] = "injected"
        first_copy["source_refs"][first_call["source"]]["excerpt"] = "/tmp/injected"

        second_copy = LinkedSpecJulia._semantic_static_projection_for_testing(index)
        @test _semantic_call_core_record(
            second_copy,
            "call:function:normalize:0",
        )["facts"]["resolution_kind"] == "helper"
        @test !occursin("injected", JSON3.write(second_copy))
        @test first_copy !== second_copy
        @test JSON3.read(JSON3.write(second_copy), Dict{String,Any}) == second_copy
        @test _semantic_call_core_plain(second_copy)
        @test !occursin(r"/(?:Users|home|tmp)/", JSON3.write(second_copy))

        retained = getfield(index, :_static_projection)
        @test retained isa LinkedSpecJulia._SemanticStaticProjection
        @test retained.records.values isa Tuple
        @test retained.relations.values isa Tuple
        @test_throws MethodError setindex!(retained.records.values, nothing, 1)
        @test_throws MethodError push!(retained.relations.values, nothing)

        @test !isdefined(LinkedSpecJulia, :semantic_call_projection)
        @test !isdefined(LinkedSpecJulia, :semantic_calls)
        @test !(:_semantic_call_extend_core! in names(LinkedSpecJulia))

        implementation = read(
            joinpath(@__DIR__, "..", "src", "semantic", "SemanticCallProjection.jl"),
            String,
        )
        for forbidden in (
            "runtime_execute(",
            "emit_julia_source",
            "execute_generated",
            "LinkedSpecTraceEmitter",
            "LINKEDSPEC_TRACE_LEVEL",
            "diagnostic_output_sink",
            "runtime_observer",
            "ENV[",
            "time_ns(",
            "rand(",
        )
            @test !occursin(forbidden, implementation)
        end
    end
end
