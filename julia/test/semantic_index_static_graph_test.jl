const SEMANTIC_STATIC_MODEL = JSON3.read(
    read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "semantic_introspection_model.json",
        ),
        String,
    ),
    Dict{String,Any},
)

function _semantic_static_graph_index()
    return semantic_index(
        read(
            joinpath(
                REPO_ROOT,
                "capability_conformance",
                "semantic_introspection",
                "graph.spec",
            ),
            String,
        );
        logical_name = "graph.spec",
        source_detail_ceiling = SemanticSourceTextDetail,
    )
end

function _semantic_static_expected(snapshot_id::String)
    snapshot = only(
        candidate for candidate in SEMANTIC_STATIC_MODEL["snapshots"] if
        candidate["id"] == snapshot_id
    )
    result = JSON3.read(JSON3.write(snapshot), Dict{String,Any})
    delete!(result, "id")
    delete!(result, "fixture")
    return result
end

function _semantic_static_materialize_sources(projection::Dict{String,Any})
    result = JSON3.read(JSON3.write(projection), Dict{String,Any})
    source_refs = pop!(result, "source_refs")
    for group in ("records", "relations")
        for item in result[group]
            source = item["source"]
            if source isa AbstractString
                item["source"] = JSON3.read(
                    JSON3.write(source_refs[source]),
                    Dict{String,Any},
                )
            end
        end
    end
    return result
end

function _semantic_static_plain_and_host_free(value)
    forbidden_keys = Set([
        "source_text",
        "source_bytes",
        "ast",
        "action_ir",
        "descriptor",
        "compiled_regex",
        "executor",
        "trace",
        "diagnostic_sink",
        "runtime_observer",
    ])
    if value isa AbstractDict
        return all(key isa AbstractString && !(key in forbidden_keys) for key in keys(value)) &&
               all(_semantic_static_plain_and_host_free, values(value))
    elseif value isa AbstractVector
        return all(_semantic_static_plain_and_host_free, value)
    end
    return value === nothing || value isa AbstractString || value isa Number || value isa Bool
end

@testset "Semantic index private static graph projection" begin
    graph_index = _semantic_static_graph_index()
    projection = LinkedSpecJulia._semantic_static_projection_for_testing(graph_index)
    expected = _semantic_static_expected("graph")

    @test length(projection["records"]) == 12
    @test length(projection["relations"]) == 14
    @test length(projection["source_refs"]) == 7
    @test _semantic_static_materialize_sources(projection) ==
          _semantic_static_materialize_sources(expected)
    @test JSON3.read(JSON3.write(projection), Dict{String,Any}) == projection
    @test _semantic_static_plain_and_host_free(projection)

    snapshot = projection["snapshot"]
    @test snapshot == Dict{String,Any}(
        "id" => "snapshot:0",
        "state" => "compiled",
        "has_execution" => false,
        "source_detail_ceiling" => "text",
        "content_digest_available" => true,
    )

    records = projection["records"]
    @test [record["kind"] for record in records] == [
        "spec",
        "source",
        "rule",
        "rule",
        "regex_slot",
        "regex_slot",
        "edge",
        "edge",
        "lifecycle",
        "decision",
        "explanation_step",
        "explanation_step",
    ]
    @test records[1]["facts"]["definition_order"] == ["rule:Top", "rule:Child"]
    @test records[1]["facts"]["compiled_rule_order"] == ["rule:Top", "rule:Child"]
    @test records[1]["facts"]["entry_rule_id"] == "rule:Top"
    @test records[1]["facts"]["entry_selection_basis"] == "first_marker"

    top_rule = only(record for record in records if record["id"] == "rule:Top")
    child_rule = only(record for record in records if record["id"] == "rule:Child")
    @test top_rule["facts"]["family"] == "and"
    @test top_rule["facts"]["cursor_policy"] == "contiguous"
    @test top_rule["facts"]["is_repetition"] === false
    @test top_rule["facts"]["rep_min"] === nothing
    @test top_rule["facts"]["rep_max"] === nothing
    @test top_rule["facts"]["value_shape"]["kind"] == "array"
    @test top_rule["facts"]["value_shape"]["element"]["kind"] == "string"
    @test child_rule["facts"]["family"] == "or"
    @test child_rule["facts"]["cursor_policy"] == "seek"
    @test child_rule["facts"]["is_repetition"] === true
    @test child_rule["facts"]["rep_min"] == 1
    @test child_rule["facts"]["rep_max"] === nothing

    regex_slots = [record for record in records if record["kind"] == "regex_slot"]
    @test [record["id"] for record in regex_slots] == [
        "regex:rule:Child:0",
        "regex:rule:Child:1",
    ]
    @test [record["facts"]["pattern"] for record in regex_slots] == ["a", "a"]
    @test [record["facts"]["authored_index"] for record in regex_slots] == [0, 1]
    @test all(record["facts"]["combined_owner_ids"] == ["rule:Child"] for record in regex_slots)

    outcome = LinkedSpecJulia._semantic_compilation_outcome(graph_index)
    @test outcome.compiled.rules_by_label["Top"].regex_patterns == ["a", "a"]
    @test isempty(record for record in regex_slots if record["owner_id"] == "rule:Top")

    edges = [record for record in records if record["kind"] == "edge"]
    @test [record["id"] for record in edges] == ["edge:rule:Top:0", "edge:rule:Top:1"]
    @test all(record["facts"]["ownership"] == "action" for record in edges)
    @test all(record["facts"]["source_form"] == "indexed" for record in edges)
    @test all(record["facts"]["has_block"] === true for record in edges)
    @test all(record["facts"]["value_shape"]["kind"] == "string" for record in edges)

    sources = projection["source_refs"]
    @test sources["source_ref:edge:rule:Top:0"]["excerpt"] ==
          "/a/ -> Child[0] { return(\"first\") }"
    @test sources["source_ref:edge:rule:Top:0"]["span"] == Dict{String,Any}(
        "start_byte" => 10,
        "end_byte" => 45,
        "start_line" => 2,
        "start_column" => 2,
        "end_line" => 2,
        "end_column" => 37,
    )
    @test all(
        source["logical_name"] == "graph.spec" &&
        source["content_digest"] ==
            "sha256:28505ba8524900f55e11452988acc6b7d35dccbccc1c0cb6194c8cda80a0cbcf" &&
        isempty(source["provenance_ids"])
        for source in values(sources)
    )

    relations = projection["relations"]
    @test count(relation -> relation["kind"] == "declares", relations) == 2
    @test count(relation -> relation["kind"] == "contains", relations) == 6
    @test count(relation -> relation["kind"] == "dispatches_to", relations) == 2
    @test count(relation -> relation["kind"] == "selects_regex", relations) == 2
    @test count(relation -> relation["kind"] == "explained_by", relations) == 2
    @test all(isempty(relation["facts"]) for relation in relations)

    first_copy = LinkedSpecJulia._semantic_static_projection_for_testing(graph_index)
    first_copy["records"][1]["facts"]["definition_order"][1] = "rule:Injected"
    first_copy["source_refs"]["source_ref:rule:Top"]["logical_name"] = "/tmp/private.spec"
    second_copy = LinkedSpecJulia._semantic_static_projection_for_testing(graph_index)
    @test second_copy["records"][1]["facts"]["definition_order"] == [
        "rule:Top",
        "rule:Child",
    ]
    @test second_copy["source_refs"]["source_ref:rule:Top"]["logical_name"] ==
          "graph.spec"
    @test first_copy !== second_copy

    retained = getfield(graph_index, :_static_projection)
    @test retained isa LinkedSpecJulia._SemanticStaticProjection
    @test retained.records.values isa Tuple
    @test retained.source_refs.values isa Tuple
    @test_throws MethodError push!(retained.records.values, nothing)
    @test_throws MethodError push!(retained.source_refs.values, nothing)

    default_index = semantic_index(
        "Top::\n /x/\n";
        logical_name = "default.spec",
        source_detail_ceiling = SemanticSourceTextDetail,
    )
    default_projection = LinkedSpecJulia._semantic_static_projection_for_testing(default_index)
    default_rule = only(
        record for record in default_projection["records"] if record["kind"] == "rule"
    )
    @test default_rule["facts"]["is_repetition"] === false
    @test default_rule["facts"]["rep_min"] === nothing
    @test default_rule["facts"]["rep_max"] === nothing

    @test !isdefined(LinkedSpecJulia, :semantic_static_projection)
    @test !isdefined(LinkedSpecJulia, :semantic_records)
    @test !(:_semantic_static_projection_for_testing in names(LinkedSpecJulia))

    implementation = read(
        joinpath(@__DIR__, "..", "src", "semantic", "SemanticStaticProjection.jl"),
        String,
    )
    for forbidden in (
        "to_json(parsed)",
        "to_json(compiled)",
        "to_descriptor_json",
        "runtime_parse(",
        "runtime_execute(",
        "execute_generated_parser",
        "LinkedSpecTraceEmitter",
        "diagnostic_output_sink",
        "semantic_observation",
        "ENV[",
        "Dates.now",
        "rand(",
    )
        @test !occursin(forbidden, implementation)
    end
end
