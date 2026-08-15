# INTER-MATCH-GAP-CAPTURE.5.1-.5.2 — dormant Julia metadata/native stages.
#
# This final consumer path now proves parsing, validation, compiled provenance,
# source identity, and private native gap execution. Reconstruction/descriptor/
# generated projection, emitted source, primary execution, and admission remain
# owned by `.5.3-.5.5`.
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

execute_native(source::AbstractString, input::AbstractString) = runtime_parse(
    LinkedSpecRuntimeEngine(compile_metadata(source)),
    input,
)

function native_error(source::AbstractString, input::AbstractString)
    try
        execute_native(source, input)
    catch error
        error isa RuntimeInterpreterException || rethrow()
        return error
    end
    error("fixture must fail during native execution")
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

@testset "Julia private native gap state lifecycle and rollback" begin
    @test execute_native(raw"""
Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[head] { push(gaps, array(gap_kind(), gap_text())) }
 LX { push(gaps, array(gap_kind(), gap_text())); return(copy(gaps)) }
Part:
 head=/H/
 I.return(entry_text())
""", "αHω").value == Any[
        Any["prefix", "α"],
        Any["tail", "ω"],
    ]

    @test execute_native(raw"""
Top::
 @capture_gaps
 -> Part { return("unexpected") }
 LS { return(array(gap_kind(), gap_text(), match_text())) }
Part: /H/
""", "αH").value == Any["prefix", "α", "H"]

    @test execute_native(raw"""
Top::
 I { segments = [] }
 @capture_gaps
 -> Part[header]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[section] { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[footer]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 LX { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span())); return(copy(segments)) }
Part:
 header=/H/
 section=/S/
 footer=/F/
 I { return(hash("slot", entry_slot(), "text", entry_text(), "falsey", 0)) }
""", "αHβ\nS🙂Fω").value == Any[
        Dict{String,Any}(
            "kind" => "prefix",
            "text" => "α",
            "span" => Dict{String,Any}(
                "source_id" => "input",
                "start" => 0,
                "end" => 1,
                "provenance" => "gap",
            ),
            "child" => Dict{String,Any}(
                "slot" => Dict{String,Any}(
                    "target_rule" => "Part",
                    "regex_index" => 0,
                    "slot_id" => "header",
                    "selector_kind" => "named",
                    "authored_selector" => "header",
                ),
                "text" => "H",
                "falsey" => 0,
            ),
        ),
        Dict{String,Any}(
            "kind" => "interstitial",
            "text" => "β\n",
            "span" => Dict{String,Any}(
                "source_id" => "input",
                "start" => 2,
                "end" => 4,
                "provenance" => "gap",
            ),
            "child" => Dict{String,Any}(
                "slot" => Dict{String,Any}(
                    "target_rule" => "Part",
                    "regex_index" => 1,
                    "slot_id" => "section",
                    "selector_kind" => "named",
                    "authored_selector" => "section",
                ),
                "text" => "S",
                "falsey" => 0,
            ),
        ),
        Dict{String,Any}(
            "kind" => "interstitial",
            "text" => "🙂",
            "span" => Dict{String,Any}(
                "source_id" => "input",
                "start" => 5,
                "end" => 6,
                "provenance" => "gap",
            ),
            "child" => Dict{String,Any}(
                "slot" => Dict{String,Any}(
                    "target_rule" => "Part",
                    "regex_index" => 2,
                    "slot_id" => "footer",
                    "selector_kind" => "named",
                    "authored_selector" => "footer",
                ),
                "text" => "F",
                "falsey" => 0,
            ),
        ),
        Dict{String,Any}(
            "kind" => "tail",
            "text" => "ω",
            "span" => Dict{String,Any}(
                "source_id" => "input",
                "start" => 7,
                "end" => 8,
                "provenance" => "gap",
            ),
        ),
    ]

    @test execute_native(raw"""
Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[s] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[f] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 LX { push(gaps, array(gap_kind(), gap_text(), gap_span())); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 f=/F/
 I.return(entry_text())
""", "HSF").value == Any[
        Any[
            "prefix",
            "",
            Dict{String,Any}(
                "source_id" => "input",
                "start" => 0,
                "end" => 0,
                "provenance" => "gap",
            ),
        ],
        Any[
            "interstitial",
            "",
            Dict{String,Any}(
                "source_id" => "input",
                "start" => 1,
                "end" => 1,
                "provenance" => "gap",
            ),
        ],
        Any[
            "interstitial",
            "",
            Dict{String,Any}(
                "source_id" => "input",
                "start" => 2,
                "end" => 2,
                "provenance" => "gap",
            ),
        ],
        Any[
            "tail",
            "",
            Dict{String,Any}(
                "source_id" => "input",
                "start" => 3,
                "end" => 3,
                "provenance" => "gap",
            ),
        ],
    ]

    @test execute_native(raw"""
Top::
 I { gaps = [] }
 @capture_gaps
 -> Container[open] { push(gaps, array(gap_text(), call(Container))) }
 -> Bang { push(gaps, array(gap_text(), call(Bang))) }
 LX { push(gaps, array(gap_text(), gap_kind())); return(copy(gaps)) }
Container:
 open=/\{/
 -> Close { return(call(Close)) }
Close:
 /\}/
 I.return(entry_text())
Bang:
 /!/
 I.return(entry_text())
""", "p{abc}gap!").value == Any[
        Any["p", "}"],
        Any["gap", "!"],
        Any["", "tail"],
    ]

    @test execute_native(raw"""
Top::
 @capture_gaps
 -> Container[open] { return(array(gap_text(), call(Container), gap_text())) }
Container:
 open=/\{/
 I { inner = [] }
 @capture_gaps
 -> Atom { push(inner, gap_text()) }
 LX { push(inner, gap_text()); return(copy(inner)) }
Atom:
 /x/
 I.return(entry_text())
""", "p{axtail").value == Any[
        "p",
        Any["a", "tail"],
        "p",
    ]

    @test execute_native(raw"""
Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] {
  tx = recognition_checkpoint();
  matched = recognize_once(tx, call(Probe));
  recognition_rollback(tx);
  push(gaps, gap_text())
 }
 -> Part[s] { push(gaps, gap_text()) }
 LX { push(gaps, gap_text()); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 I.return(entry_text())
Probe:
 /X/
 I.return(0)
""", "aHXbS").value == Any["a", "Xb", ""]

    terminal_cases = (
        (
            raw"""
Top::
 @capture_gaps
 -> Part { return(gap_text()) }
 LX { return(array(gap_kind(), gap_text(), gap_span())) }
Part: /H/
""",
            "abc",
            Any[
                "tail",
                "abc",
                Dict{String,Any}(
                    "source_id" => "input",
                    "start" => 0,
                    "end" => 3,
                    "provenance" => "gap",
                ),
            ],
        ),
        (
            raw"""
Top::OR{0,2}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 EX { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
""",
            "aHtail",
            Any["a", "tail"],
        ),
        (
            raw"""
Top::OR{0,2}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 EX { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
""",
            "whole",
            Any["whole"],
        ),
        (
            raw"""
Top::OR{1}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 E { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
""",
            "aHtail",
            Any["a", "tail"],
        ),
    )
    for (source, input, expected) in terminal_cases
        @test execute_native(source, input).value == expected
    end

    unavailable = native_error(
        "Direct::\n /H/\n I { return(gap_text()) }\n",
        "H",
    )
    @test unavailable.message ==
        "LINKEDSPEC_INTER_MATCH_GAP_ERROR:gap_capture_context_unavailable"
    @test unavailable.diagnostic.code == "gap_capture_context_unavailable"
    @test unavailable.diagnostic.stage == "access_gap_context"

    post_commit = native_error(
        "Top::OR{1}\n @capture_gaps\n -> Part { return(0) }\n IT { return(gap_kind()) }\nPart: /H/\n",
        "H",
    )
    @test post_commit.diagnostic.code == "gap_capture_context_unavailable"

    regression = native_error(
        "Top::OR{1}\n @capture_gaps\n -> Part { rewind_match_start() }\nPart: /H/\n",
        "aH",
    )
    @test regression.message ==
        "LINKEDSPEC_SOURCE_LOCATION_ERROR:source_location_cursor_regression"
    @test regression.diagnostic.code == "source_location_cursor_regression"
    @test regression.diagnostic.stage == "advance_gap_context"

    for helper_name in ("entry_slot", "gap_span", "gap_text", "gap_kind")
        arity = native_error(
            "Top::OR{1}\n @capture_gaps\n -> Part { return($(helper_name)(1)) }\nPart: /H/\n",
            "H",
        )
        @test arity.diagnostic.code == "helper_arity_mismatch"
        @test arity.diagnostic.stage == "helper_arity_mismatch"
        @test arity.diagnostic.actual_arity == 1
    end

    @test execute_native(
        "Top::OR{2}\n @capture_gaps\n -> Part { return(gap_text()) }\n EX { return(\"unexpected-ex\") }\n E { return(\"unexpected-e\") }\nPart: /H/\n",
        "H",
    ).value === nothing
    @test execute_native(
        "Part::\n /H/\n I { return(entry_slot()) }\n",
        "H",
    ).value === nothing
    @test execute_native(
        "Top::\n /H/\n E { return(\"legacy\") }\n",
        "H",
    ).value == "legacy"
end

end # module JuliaInterMatchGapCaptureContract
