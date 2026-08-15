# INTER-MATCH-GAP-CAPTURE.5.1 — dormant Julia authored/static metadata stage.
#
# This final consumer path deliberately proves only parsing, validation,
# compiled provenance, and ordinary/staged/loaded/primary source identity in
# this leaf. Native gap state, reconstruction/descriptor/generated projection,
# emitted source, primary execution, and admission remain owned by `.5.2-.5.5`.
# DORMANT: INTER-MATCH-GAP-CAPTURE.5.5 owns Julia runtime admission

module JuliaInterMatchGapCaptureContract

using JSON3
using LinkedSpecJulia
using Test

const CONTRACT = JSON3.read(
    read(
        normpath(joinpath(
            @__DIR__,
            "..",
            "..",
            "capability_conformance",
            "inter_match_gap_capture_contract.json",
        )),
        String,
    ),
    Dict{String,Any},
)
const CONTRACT_ID = "linkedspec-inter-match-gap-capture-v1"

function compile_metadata(source::AbstractString; source_id::AbstractString = "inline")
    parsed = parse_spec(source; source_id = source_id)
    validate_spec(parsed)
    return compile_spec(parsed; validate_source = false)
end

function portable_diagnostic(
    source::AbstractString;
    source_id::AbstractString = "inline",
)
    try
        compile_metadata(source; source_id = source_id)
    catch error
        if error isa SpecValidationException && error.diagnostic !== nothing
            return error.diagnostic
        end
        rethrow()
    end
    error("fixture must be rejected statically")
end

compiled_rule_json(compiled::CompiledSpec, label::AbstractString) =
    to_json(compiled.rules_by_label[String(label)])

function selector_identity(edge)
    return Dict{String,Any}(
        "selector_kind" => edge["selector_kind"],
        "authored_selector" => edge["authored_selector"],
        "target_rule" => edge["target_rule"],
        "regex_index" => edge["child_regex_index"],
        "target_slot_id" => edge["target_slot_id"],
    )
end

@testset "Julia dormant authored/static/compiled gap metadata" begin
    @test CONTRACT["contract_id"] == CONTRACT_ID
    @test CONTRACT["format"] == 1
    @test CONTRACT["rollout"][5] == Dict{String,Any}(
        "id" => "julia_runtime",
        "owner" => "INTER-MATCH-GAP-CAPTURE.5",
        "status" => "pending",
    )

    source = """Top::OR
 @capture_gaps
 -> Part[head] { return("named") }
 -> Part[0] { return("numeric") }
 -> Part { return("unindexed") }
Part:
 head = /H/
 /S/
 foot=/F/
 é́=/U/
"""
    parsed = parse_spec(source)
    part_rows = [
        to_json(element.kind) for element in parsed.rules[2].body
        if element.kind isa RegexBodyElementKind
    ]
    @test [row["slot_id"] for row in part_rows] == Any["head", nothing, "foot", "é́"]
    for declaration in ("head=/H/", "head =/H/", "head= /H/", "head = /H/")
        row = only(only(parse_spec("Top::\n $declaration\n").rules).body)
        @test to_json(row.kind)["slot_id"] == "head"
        @test to_json(row.kind)["pattern"] == "H"
    end

    validate_spec(parsed)
    compiled = compile_spec(parsed; validate_source = false)
    @test compiled_rule_json(compiled, "Part")["regex_slots"] == Any[
        Dict{String,Any}(
            "regex_index" => 0,
            "slot_id" => "head",
            "source_id" => "inline",
            "line" => 7,
        ),
        Dict{String,Any}(
            "regex_index" => 1,
            "slot_id" => nothing,
            "source_id" => "inline",
            "line" => 8,
        ),
        Dict{String,Any}(
            "regex_index" => 2,
            "slot_id" => "foot",
            "source_id" => "inline",
            "line" => 9,
        ),
        Dict{String,Any}(
            "regex_index" => 3,
            "slot_id" => "é́",
            "source_id" => "inline",
            "line" => 10,
        ),
    ]
    @test compiled_rule_json(compiled, "Top")["capture_gaps"] == Dict{String,Any}(
        "enabled" => true,
        "directive" => "@capture_gaps",
        "source_id" => "inline",
        "line" => 2,
    )
    edges = compiled_rule_json(compiled, "Top")["action_edges"]
    @test [selector_identity(edge) for edge in edges] == Any[
        Dict{String,Any}(
            "selector_kind" => "named",
            "authored_selector" => "head",
            "target_rule" => "Part",
            "regex_index" => 0,
            "target_slot_id" => "head",
        ),
        Dict{String,Any}(
            "selector_kind" => "numeric",
            "authored_selector" => 0,
            "target_rule" => "Part",
            "regex_index" => 0,
            "target_slot_id" => "head",
        ),
        Dict{String,Any}(
            "selector_kind" => "unindexed",
            "authored_selector" => nothing,
            "target_rule" => "Part",
            "regex_index" => 0,
            "target_slot_id" => "head",
        ),
    ]

    reordered = compile_metadata("""Top::
 -> Part[head] { return("named") }
 -> Part[0] { return("numeric") }
Part:
 other=/H/
 head=/H/
""")
    reordered_edges = compiled_rule_json(reordered, "Top")["action_edges"]
    @test [selector_identity(edge) for edge in reordered_edges] == Any[
        Dict{String,Any}(
            "selector_kind" => "named",
            "authored_selector" => "head",
            "target_rule" => "Part",
            "regex_index" => 1,
            "target_slot_id" => "head",
        ),
        Dict{String,Any}(
            "selector_kind" => "numeric",
            "authored_selector" => 0,
            "target_rule" => "Part",
            "regex_index" => 0,
            "target_slot_id" => "other",
        ),
    ]

    for header in ("Top::", "Top::OR", "Top::OR+", "Top::OR{1,3}", "Top:+")
        compile_metadata(
            "$header\n @capture_gaps\n -> Part { return(\"x\") }\nPart: /H/\n",
        )
    end
    compile_metadata("""Top::
 @capture_gaps
 @mark(gap_control)
 -> Part { return("x") }
Part: /H/
""")
    for (fixture, ownership) in (
        ("Top::\n @capture_gaps\n /H/\n", "none"),
        ("Top::\n @capture_gaps\n -> Part\n => Part\nPart: /H/\n", "mixed"),
        (
            "Top::\n @capture_gaps\n /H/ -> Part { return(\"x\") }\nPart: /H/\n",
            "local_adjacency",
        ),
    )
        result = portable_diagnostic(fixture)
        @test result.code == "capture_gaps_rule_ineligible"
        @test result.fields["edge_ownership"] == ownership
    end

    located = portable_diagnostic(
        "Top::\n -bad=/H/\n";
        source_id = "contract-fixture.spec",
    )
    @test located.fields["source_id"] == "contract-fixture.spec"
    @test located.fields["line"] == 2

    descriptor = to_descriptor_json(compiled)
    top_descriptor = descriptor["spec"]["Top"]
    resolved_edges = top_descriptor["meta"]["resolved_edges"]
    @test !haskey(first(resolved_edges), "selector_kind")
    @test top_descriptor["dependency_refs"] == Any[
        Dict{String,Any}("label" => "Part", "idx" => 0),
        Dict{String,Any}("label" => "Part", "idx" => 0),
        Dict{String,Any}("label" => "Part", "idx" => 0),
    ]

    ordinary = parse_spec("Top:: /H/\n"; source_id = "ordinary.spec")
    @test ordinary.source_id == "ordinary.spec"
    @test from_json(SpecFile, to_json(ordinary)).source_id == "ordinary.spec"
    legacy_json = to_json(ordinary)
    delete!(legacy_json, "source_id")
    @test from_json(SpecFile, legacy_json).source_id == "inline"

    staged = parse_spec_with_staged_user_function_definitions(
        "Top:: /H/\n";
        source_id = "staged.spec",
    )
    @test staged.source_id == "staged.spec"

    loaded_request = path_spec_request("loaded.spec")
    loaded_source = LoadedSpec(
        ResolvedSpec(loaded_request, "loaded.spec", "contract_fixture"),
        """Top::
 @capture_gaps
 -> Part { return("x") }
Part:
 head=/H/
""",
    )
    parse_loaded = getproperty(LinkedSpecJulia, :_parse_loaded_spec)
    loaded_spec = parse_loaded(loaded_source)
    validate_spec(loaded_spec)
    loaded_compiled = compile_spec(loaded_spec; validate_source = false)
    @test compiled_rule_json(loaded_compiled, "Part")["regex_slots"] == Any[
        Dict{String,Any}(
            "regex_index" => 0,
            "slot_id" => "head",
            "source_id" => "loaded.spec",
            "line" => 5,
        ),
    ]
    @test compiled_rule_json(loaded_compiled, "Top")["capture_gaps"]["source_id"] ==
        "loaded.spec"

    primary_parse = getproperty(LinkedSpecJulia, :_parse_primary_cli_spec)
    primary = primary_parse("Top:: /H/\n"; source_id = "primary.spec")
    @test primary.source_id == "primary.spec"

    cases = (
        (
            "Top::\n -bad=/H/\n",
            "regex_slot_name_invalid",
            "parse_declaration",
            2,
            Dict{String,Any}("slot_name" => "-bad"),
        ),
        (
            "Top::\n 123=/H/\n",
            "regex_slot_name_invalid",
            "parse_declaration",
            2,
            Dict{String,Any}("slot_name" => "123"),
        ),
        (
            "Top::\n head=/H/\n head=/S/\n",
            "regex_slot_duplicate_name",
            "resolve_declaration",
            3,
            Dict{String,Any}("slot_name" => "head", "first_line" => 2),
        ),
        (
            "Top::\n -> Part[missing] { return(\"x\") }\nPart:\n head=/H/\n",
            "regex_slot_unknown_name",
            "resolve_selector",
            2,
            Dict{String,Any}(
                "target_rule" => "Part",
                "authored_selector" => "missing",
            ),
        ),
        (
            "Top::\n -> Part[2] { return(\"x\") }\nPart:\n /H/\n",
            "regex_slot_index_out_of_range",
            "resolve_selector",
            2,
            Dict{String,Any}(
                "target_rule" => "Part",
                "regex_index" => 2,
                "regex_count" => 1,
            ),
        ),
        (
            "Top::\n -> Part[head { return(\"x\") }\nPart:\n head=/H/\n",
            "regex_slot_selector_invalid",
            "parse_selector",
            2,
            Dict{String,Any}(
                "target_rule" => "Part",
                "authored_selector" => "head",
            ),
        ),
        (
            "Top::\n @capture_gaps\n @capture_gaps\n -> Part { return(\"x\") }\nPart: /H/\n",
            "capture_gaps_duplicate_directive",
            "parse_directive",
            3,
            Dict{String,Any}("first_line" => 2),
        ),
        (
            "Top::AND\n @capture_gaps\n -> Part { return(\"x\") }\nPart: /H/\n",
            "capture_gaps_rule_ineligible",
            "validate_directive",
            2,
            Dict{String,Any}(
                "family" => "and",
                "cursor_policy" => "consume",
                "edge_ownership" => "action",
                "execution_shape" => "single_match",
            ),
        ),
        (
            "Top::\n @capture_gaps\n => Part\nPart: /H/\n",
            "capture_gaps_rule_ineligible",
            "validate_directive",
            2,
            Dict{String,Any}(
                "family" => "or_default",
                "cursor_policy" => "seek",
                "edge_ownership" => "blind",
                "execution_shape" => "default_scan_loop",
            ),
        ),
        (
            "Top::\n @capture_gaps\n @move_pos\n -> Part { return(\"x\") }\nPart: /H/\n",
            "capture_gaps_legacy_marker_conflict",
            "validate_directive",
            2,
            Dict{String,Any}("marker" => "@move_pos", "marker_line" => 3),
        ),
    )
    for (fixture, code, stage, line, fields) in cases
        result = portable_diagnostic(fixture)
        @test result.code == code
        @test result.stage == stage
        @test result.fields["rule_label"] == "Top"
        @test result.fields["source_id"] == "inline"
        @test result.fields["line"] == line
        for (field, value) in fields
            @test result.fields[field] == value
        end
    end
end

end # module JuliaInterMatchGapCaptureContract
