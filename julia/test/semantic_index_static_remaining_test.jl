const SEMANTIC_STATIC_REMAINING_ROOT = normpath(
    joinpath(@__DIR__, "..", "..", "capability_conformance", "semantic_introspection"),
)

const SEMANTIC_STATIC_REMAINING_MODEL = JSON3.read(
    read(
        joinpath(
            SEMANTIC_STATIC_REMAINING_ROOT,
            "..",
            "semantic_introspection_model.json",
        ),
        String,
    ),
    Dict{String,Any},
)

function _semantic_static_remaining_index(
    fixture::String,
    ceiling::SemanticSourceDetail,
)
    return semantic_index(
        read(joinpath(SEMANTIC_STATIC_REMAINING_ROOT, "$fixture.spec"), String);
        logical_name = "$fixture.spec",
        source_detail_ceiling = ceiling,
    )
end

function _semantic_static_remaining_expected(snapshot_id::String)
    snapshot = only(
        candidate for candidate in SEMANTIC_STATIC_REMAINING_MODEL["snapshots"] if
        candidate["id"] == snapshot_id
    )
    result = JSON3.read(JSON3.write(snapshot), Dict{String,Any})
    delete!(result, "id")
    delete!(result, "fixture")
    return result
end

function _semantic_static_remaining_materialize(projection::Dict{String,Any})
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

function _semantic_static_remaining_runtime_expected()
    wanted = _semantic_static_remaining_expected("runtime")
    wanted["records"] = [
        record for record in wanted["records"] if
        !(record["kind"] in ("execution", "event"))
    ]
    retained = Set(record["id"] for record in wanted["records"])
    wanted["relations"] = [
        relation for relation in wanted["relations"] if
        relation["from_id"] in retained && relation["to_id"] in retained
    ]
    wanted["snapshot"]["has_execution"] = false
    return wanted
end

function _semantic_static_remaining_record(projection, record_id)
    return only(record for record in projection["records"] if record["id"] == record_id)
end

function _semantic_static_remaining_plain(value)
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
               all(_semantic_static_remaining_plain, values(value))
    elseif value isa AbstractVector
        return all(_semantic_static_remaining_plain, value)
    end
    return value === nothing || value isa AbstractString || value isa Number || value isa Bool
end

@testset "Semantic index remaining private static targets and isolation" begin
    @testset "Unicode privacy ceilings" begin
        for (snapshot_id, ceiling, expected_ceiling, digest_available) in (
            ("privacy", SemanticSourceTextDetail, "text", true),
            ("privacy_limited", SemanticSourceIdentityDetail, "identity", false),
        )
            index = _semantic_static_remaining_index("privacy", ceiling)
            raw = LinkedSpecJulia._semantic_static_projection_for_testing(index)
            actual = _semantic_static_remaining_materialize(raw)
            wanted = _semantic_static_remaining_materialize(
                _semantic_static_remaining_expected(snapshot_id),
            )
            @test actual == wanted
            @test length(actual["records"]) == 4
            @test length(actual["relations"]) == 3
            @test actual["snapshot"]["source_detail_ceiling"] == expected_ceiling
            @test actual["snapshot"]["content_digest_available"] == digest_available
            @test length(raw["source_refs"]) == 2

            rule = _semantic_static_remaining_record(actual, "rule:T%C3%B6p")
            slot = _semantic_static_remaining_record(actual, "regex:rule:T%C3%B6p:0")
            @test rule["name"] == "Töp"
            @test rule["source"]["span"]["start_byte"] == 0
            @test rule["source"]["span"]["end_byte"] == 6
            @test rule["source"]["excerpt"] == "Töp::"
            @test slot["facts"]["pattern"] == "é"
            @test slot["source"]["span"]["start_column"] == 2
            @test slot["source"]["span"]["end_column"] == 5
        end
    end

    @testset "runtime static absence" begin
        index = _semantic_static_remaining_index("runtime", SemanticSourceTextDetail)
        actual = _semantic_static_remaining_materialize(
            LinkedSpecJulia._semantic_static_projection_for_testing(index),
        )
        wanted = _semantic_static_remaining_materialize(
            _semantic_static_remaining_runtime_expected(),
        )
        @test actual == wanted
        @test length(actual["records"]) == 7
        @test length(actual["relations"]) == 8
        @test actual["snapshot"]["has_execution"] == false
        @test !any(record["kind"] in ("execution", "event") for record in actual["records"])
        @test !any(relation["kind"] == "observed_as" for relation in actual["relations"])
        @test !any(relation["kind"] == "dispatches_to" for relation in actual["relations"])
        @test count(relation -> relation["kind"] == "selects_regex", actual["relations"]) == 2

        rule = _semantic_static_remaining_record(actual, "rule:Top")
        @test rule["facts"]["is_repetition"] == true
        @test rule["facts"]["rep_min"] == 2
        @test rule["facts"]["rep_max"] == 2
        @test [
            _semantic_static_remaining_record(actual, "regex:rule:Top:$index")["facts"]["pattern"] for
            index in 0:1
        ] == ["a", "b"]
    end

    @testset "failed compilation normalization" begin
        index = _semantic_static_remaining_index("failed", SemanticSourceSpanDetail)
        native = compilation_diagnostic(index)
        @test native.code == "bare_edge_target_undefined"
        @test native.stage == "normalize_edges"
        @test native.message == "bare edge in rule 'Top' targets undefined rule 'Missing'"
        @test Dict(native.fields) == Dict{String,Any}(
            "rule_label" => "Top",
            "target" => "Missing",
        )

        raw = LinkedSpecJulia._semantic_static_projection_for_testing(index)
        actual = _semantic_static_remaining_materialize(raw)
        wanted = _semantic_static_remaining_materialize(
            _semantic_static_remaining_expected("failed"),
        )
        @test actual == wanted
        @test length(actual["records"]) == 6
        @test length(actual["relations"]) == 4
        @test actual["snapshot"] == Dict{String,Any}(
            "id" => "snapshot:0",
            "state" => "failed_compilation",
            "has_execution" => false,
            "source_detail_ceiling" => "span",
            "content_digest_available" => false,
        )
        @test [record["id"] for record in actual["records"]] == [
            "spec:0",
            "source:0",
            "rule:Top",
            "diagnostic:compile:0",
            "decision:compile:rule:Top",
            "explanation:decision:compile:rule:Top:0",
        ]

        diagnostic = _semantic_static_remaining_record(actual, "diagnostic:compile:0")
        @test diagnostic["facts"]["code"] == "unknown_rule_reference"
        @test diagnostic["facts"]["stage"] == "compile"
        @test diagnostic["facts"]["fields"] == Dict{String,Any}(
            "rule_id" => "rule:Top",
            "missing_rule_id" => "rule:Missing",
        )
        @test diagnostic["source"]["excerpt"] == "Missing"
        @test diagnostic["source"]["span"]["start_byte"] == 6
        @test diagnostic["source"]["span"]["end_byte"] == 13

        rule = _semantic_static_remaining_record(actual, "rule:Top")
        @test rule["facts"]["edge_ownership"] == "action"
        @test rule["source"]["excerpt"] == "Top:"
        @test count(relation -> relation["kind"] == "diagnoses", actual["relations"]) == 1
        explained = only(
            relation for relation in actual["relations"] if
            relation["kind"] == "explained_by"
        )
        @test explained["evidence_ids"] == ["diagnostic:compile:0"]
    end

    @testset "repeated lifecycle occurrence identity" begin
        source = """Top::
 /x/
 E { return("first") }
 E { return(["second"]) }
"""
        index = semantic_index(
            source;
            logical_name = "repeated-lifecycle.spec",
            source_detail_ceiling = SemanticSourceTextDetail,
        )
        actual = _semantic_static_remaining_materialize(
            LinkedSpecJulia._semantic_static_projection_for_testing(index),
        )
        lifecycles = [
            record for record in actual["records"] if record["kind"] == "lifecycle"
        ]
        @test length(lifecycles) == 2
        @test [record["id"] for record in lifecycles] == [
            "lifecycle:rule:Top:E:0",
            "lifecycle:rule:Top:E:1",
        ]
        @test [record["order"] for record in lifecycles] == [0, 1]
        @test [record["facts"]["value_shape"]["kind"] for record in lifecycles] == [
            "string",
            "array",
        ]
        @test [record["source"]["excerpt"] for record in lifecycles] == [
            "E { return(\"first\") }",
            "E { return([\"second\"]) }",
        ]
        @test [record["source"]["span"]["start_line"] for record in lifecycles] == [3, 4]
        @test count(
            relation -> relation["kind"] == "contains" &&
                        startswith(relation["to_id"], "lifecycle:"),
            actual["relations"],
        ) == 2
    end

    @testset "clone, fallback, and host isolation" begin
        indexes = (
            _semantic_static_remaining_index("privacy", SemanticSourceTextDetail),
            _semantic_static_remaining_index("privacy", SemanticSourceIdentityDetail),
            _semantic_static_remaining_index("failed", SemanticSourceSpanDetail),
            _semantic_static_remaining_index("runtime", SemanticSourceTextDetail),
        )
        for index in indexes
            projection = LinkedSpecJulia._semantic_static_projection_for_testing(index)
            @test _semantic_static_remaining_plain(projection)
            @test JSON3.read(JSON3.write(projection), Dict{String,Any}) == projection
            @test !occursin(r"/(?:Users|home|tmp)/", JSON3.write(projection))
        end

        failed_index = indexes[3]
        first_copy = LinkedSpecJulia._semantic_static_projection_for_testing(failed_index)
        first_diagnostic = _semantic_static_remaining_record(first_copy, "diagnostic:compile:0")
        first_diagnostic["facts"]["fields"]["missing_rule_id"] = "rule:Injected"
        second_copy = LinkedSpecJulia._semantic_static_projection_for_testing(failed_index)
        second_diagnostic = _semantic_static_remaining_record(second_copy, "diagnostic:compile:0")
        @test second_diagnostic["facts"]["fields"]["missing_rule_id"] == "rule:Missing"
        @test first_copy !== second_copy

        retained = getfield(failed_index, :_static_projection)
        @test retained isa LinkedSpecJulia._SemanticStaticProjection
        @test retained.records.values isa Tuple
        @test_throws MethodError setindex!(retained.records.values, nothing, 1)

        parse_failure = semantic_index(
            "Top:::\n /x/\n";
            logical_name = "parse-failure.spec",
            source_detail_ceiling = SemanticSourceIdentityDetail,
        )
        parse_projection = LinkedSpecJulia._semantic_static_projection_for_testing(parse_failure)
        @test length(parse_projection["records"]) == 3
        @test length(parse_projection["relations"]) == 2
        @test _semantic_static_remaining_record(
            parse_projection,
            "diagnostic:compile:0",
        )["facts"]["code"] == "semantic_index_parse_failed"

        missing_entry = semantic_index(
            "Top::\n /x/\n";
            logical_name = "missing-entry.spec",
            source_detail_ceiling = SemanticSourceIdentityDetail,
            entry_rule = "Missing",
        )
        missing_projection = LinkedSpecJulia._semantic_static_projection_for_testing(missing_entry)
        @test length(missing_projection["records"]) == 4
        @test length(missing_projection["relations"]) == 2
        @test _semantic_static_remaining_record(
            missing_projection,
            "diagnostic:compile:0",
        )["facts"]["code"] == "entry_rule_not_found"

        @test !(:_semantic_static_projection_for_testing in names(LinkedSpecJulia))
        implementation = read(
            joinpath(@__DIR__, "..", "src", "semantic", "SemanticStaticProjection.jl"),
            String,
        )
        for forbidden in (
            "SpecLoader",
            "to_descriptor_json",
            "emit_julia_source",
            "execute_generated",
            "LINKEDSPEC_TRACE_LEVEL",
            "diagnostic_output_sink",
            "runtime_observer",
            "RuntimeSemanticObservation",
            "ENV[",
            "time_ns(",
            "rand(",
        )
            @test !occursin(forbidden, implementation)
        end
    end
end
