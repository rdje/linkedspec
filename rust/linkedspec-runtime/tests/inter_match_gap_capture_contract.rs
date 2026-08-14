//! INTER-MATCH-GAP-CAPTURE.3.1 — dormant Rust authored/static metadata stage.
//!
//! This final consumer path deliberately proves only parsing, validation,
//! compiled provenance, and serde reconstruction in this leaf. Native gap
//! state, generated execution, emitted source, primary routing, and admission
//! remain owned by `.3.2-.3.5`.

use linkedspec_core::compiler::compile;
use linkedspec_core::error::{LinkedSpecError, PortableDiagnostic};
use linkedspec_core::parser::parse_spec;
use linkedspec_core::types::{CompiledSpec, RegexSelectorKind};
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use serde_json::{Value, json};

const CONTRACT_SOURCE: &str =
    include_str!("../../../capability_conformance/inter_match_gap_capture_contract.json");
const CONTRACT_ID: &str = "linkedspec-inter-match-gap-capture-v1";

fn contract() -> Value {
    serde_json::from_str(CONTRACT_SOURCE).expect("inter-match gap contract JSON")
}

fn compile_metadata(source: &str) -> Result<CompiledSpec, LinkedSpecError> {
    let parsed = parse_spec(source)?;
    validate(&parsed)?;
    compile(&parsed)
}

fn diagnostic(source: &str) -> PortableDiagnostic {
    let error = compile_metadata(source).expect_err("fixture must be rejected statically");
    error
        .diagnostic()
        .unwrap_or_else(|| panic!("expected portable diagnostic, got {error}"))
        .clone()
}

fn native_value(source: &str, input: &str) -> Value {
    Engine::new(compile_metadata(source).expect("compile native gap fixture"))
        .execute_value(input, &ExecutionOptions::new())
        .unwrap_or_else(|error| panic!("execute native gap fixture: {error}"))
}

fn rule<'a>(compiled: &'a Value, label: &str) -> &'a Value {
    compiled["rules"]
        .as_array()
        .expect("compiled rules")
        .iter()
        .find(|rule| rule["label"] == label)
        .unwrap_or_else(|| panic!("missing compiled rule {label}"))
}

#[test]
#[ignore = "INTER-MATCH-GAP-CAPTURE.3.5 owns Rust runtime admission"]
fn authored_static_compiled_metadata_stage() {
    let contract = contract();
    assert_eq!(contract["contract_id"], CONTRACT_ID);
    assert_eq!(contract["format"], 1);
    assert_eq!(contract["rollout"][2]["id"], "rust_runtime");
    assert_eq!(contract["rollout"][2]["status"], "pending");

    let source = concat!(
        "Top::OR\n",
        " @capture_gaps\n",
        " -> Part[head] { return(\"named\") }\n",
        " -> Part[0] { return(\"numeric\") }\n",
        " -> Part { return(\"unindexed\") }\n",
        "Part:\n",
        " head = /H/\n",
        " /S/\n",
        " foot=/F/\n",
        " é́=/U/\n",
    );
    let parsed = parse_spec(source).expect("parse authored metadata fixture");
    let parsed_json = serde_json::to_value(&parsed).expect("serialize parsed metadata fixture");
    let part_body = parsed_json["rules"][1]["body"]
        .as_array()
        .expect("Part body rows");
    assert_eq!(
        part_body
            .iter()
            .filter(|row| row["kind"]["kind"] == "regex")
            .map(|row| row["kind"]["slot_id"].clone())
            .collect::<Vec<_>>(),
        [json!("head"), Value::Null, json!("foot"), json!("é́")],
        "named and anonymous declarations must share authored order",
    );
    for declaration in ["head=/H/", "head =/H/", "head= /H/", "head = /H/"] {
        let parsed = parse_spec(&format!("Top::\n {declaration}\n"))
            .unwrap_or_else(|error| panic!("spacing variant {declaration:?}: {error}"));
        let row = &parsed.rules[0].body[0];
        let row = serde_json::to_value(row).expect("serialize spacing row");
        assert_eq!(row["kind"]["slot_id"], "head", "{declaration:?}");
        assert_eq!(row["kind"]["pattern"], "H", "{declaration:?}");
    }

    validate(&parsed).expect("validate authored metadata fixture");
    let compiled = compile(&parsed).expect("compile authored metadata fixture");
    let compiled_json = serde_json::to_value(&compiled).expect("serialize compiled metadata");
    assert_eq!(
        rule(&compiled_json, "Part")["regex_slots"],
        json!([
            {"regex_index": 0, "slot_id": "head", "source_id": "inline", "line": 7},
            {"regex_index": 1, "slot_id": null, "source_id": "inline", "line": 8},
            {"regex_index": 2, "slot_id": "foot", "source_id": "inline", "line": 9},
            {"regex_index": 3, "slot_id": "é́", "source_id": "inline", "line": 10}
        ]),
    );
    assert_eq!(
        rule(&compiled_json, "Top")["capture_gaps"],
        json!({
            "enabled": true,
            "directive": "@capture_gaps",
            "source_id": "inline",
            "line": 2
        }),
    );
    let edges = rule(&compiled_json, "Top")["acode_dispatch"]
        .as_array()
        .expect("compiled action edges");
    assert_eq!(
        edges
            .iter()
            .map(|edge| json!({
                "selector_kind": edge["selector_kind"],
                "authored_selector": edge["authored_selector"],
                "target_rule": edge["child_label"],
                "regex_index": edge["child_regex_idx"],
                "target_slot_id": edge["target_slot_id"],
            }))
            .collect::<Vec<_>>(),
        [
            json!({"selector_kind":"named", "authored_selector":"head", "target_rule":"Part", "regex_index":0, "target_slot_id":"head"}),
            json!({"selector_kind":"numeric", "authored_selector":0, "target_rule":"Part", "regex_index":0, "target_slot_id":"head"}),
            json!({"selector_kind":"unindexed", "authored_selector":null, "target_rule":"Part", "regex_index":0, "target_slot_id":"head"}),
        ],
    );

    let reordered = compile_metadata(concat!(
        "Top::\n",
        " -> Part[head] { return(\"named\") }\n",
        " -> Part[0] { return(\"numeric\") }\n",
        "Part:\n",
        " other=/H/\n",
        " head=/H/\n",
    ))
    .expect("compile reordered duplicate-text slots");
    let reordered = serde_json::to_value(reordered).expect("serialize reordered slots");
    let reordered_edges = rule(&reordered, "Top")["acode_dispatch"]
        .as_array()
        .expect("reordered action edges");
    assert_eq!(
        reordered_edges
            .iter()
            .map(|edge| json!({
                "selector_kind": edge["selector_kind"],
                "authored_selector": edge["authored_selector"],
                "regex_index": edge["child_regex_idx"],
                "target_slot_id": edge["target_slot_id"],
            }))
            .collect::<Vec<_>>(),
        [
            json!({"selector_kind":"named", "authored_selector":"head", "regex_index":1, "target_slot_id":"head"}),
            json!({"selector_kind":"numeric", "authored_selector":0, "regex_index":0, "target_slot_id":"other"}),
        ],
        "named identity must survive reordering and duplicate regex text",
    );

    for header in ["Top::", "Top::OR", "Top::OR+", "Top::OR{1,3}", "Top:+"] {
        compile_metadata(&format!(
            "{header}\n @capture_gaps\n -> Part {{ return(\"x\") }}\nPart: /H/\n"
        ))
        .unwrap_or_else(|error| panic!("eligible directive mode {header}: {error}"));
    }
    compile_metadata(concat!(
        "Top::\n",
        " @capture_gaps\n",
        " @mark(gap-control)\n",
        " -> Part { return(\"x\") }\n",
        "Part: /H/\n",
    ))
    .expect("named marks remain independent of gap capture");
    for (source, ownership) in [
        ("Top::\n @capture_gaps\n /H/\n", "none"),
        (
            "Top::\n @capture_gaps\n -> Part\n => Part\nPart: /H/\n",
            "mixed",
        ),
        (
            "Top::\n @capture_gaps\n /H/ -> Part { return(\"x\") }\nPart: /H/\n",
            "local_adjacency",
        ),
    ] {
        let diagnostic = diagnostic(source);
        assert_eq!(diagnostic.code, "capture_gaps_rule_ineligible");
        assert_eq!(diagnostic.field("edge_ownership"), Some(&json!(ownership)));
    }

    let mut located = parse_spec("Top::\n -bad=/H/\n").expect("parse located diagnostic");
    located.source_id = "contract-fixture.spec".to_string();
    let error = validate(&located).expect_err("located invalid name must fail");
    let located_diagnostic = error.diagnostic().expect("located portable diagnostic");
    assert_eq!(
        located_diagnostic.field("source_id"),
        Some(&json!("contract-fixture.spec")),
    );
    assert_eq!(located_diagnostic.field("line"), Some(&json!(2)));

    let descriptor = compiled
        .to_descriptor_json()
        .expect("project deliberately legacy-shaped descriptor");
    assert!(
        descriptor["spec"]["Top"]["meta"]["resolved_edges"][0]
            .get("selector_kind")
            .is_none(),
        "descriptor projection remains owned by INTER-MATCH-GAP-CAPTURE.3.3",
    );
    assert_eq!(
        descriptor["spec"]["Top"]["dependency_refs"],
        json!([
            {"label":"Part", "idx":0},
            {"label":"Part", "idx":0},
            {"label":"Part", "idx":0}
        ]),
    );

    let reconstructed: CompiledSpec =
        serde_json::from_value(compiled_json.clone()).expect("reconstruct compiled metadata");
    assert_eq!(
        serde_json::to_value(reconstructed).expect("reserialize compiled metadata"),
        compiled_json,
        "ordinary serde reconstruction must preserve authored provenance",
    );

    let mut legacy = serde_json::to_value(
        compile_metadata("Top::\n -> Part[0]\nPart:\n /H/\n")
            .expect("compile legacy anonymous fixture"),
    )
    .expect("serialize legacy anonymous fixture");
    for rule in legacy["rules"].as_array_mut().expect("legacy rules") {
        let rule = rule.as_object_mut().expect("legacy rule record");
        rule.remove("regex_slots");
        rule.remove("capture_gaps");
        for dependency in rule["dependency_refs"]
            .as_array_mut()
            .expect("legacy dependencies")
        {
            let dependency = dependency.as_object_mut().expect("legacy dependency");
            dependency.remove("selector_kind");
            dependency.remove("authored_selector");
            dependency.remove("target_slot_id");
        }
        for edge in rule["acode_dispatch"]
            .as_array_mut()
            .expect("legacy action edges")
        {
            let edge = edge.as_object_mut().expect("legacy action edge");
            edge.remove("selector_kind");
            edge.remove("authored_selector");
            edge.remove("target_slot_id");
            edge.remove("source_id");
            edge.remove("line");
        }
    }
    let legacy: CompiledSpec =
        serde_json::from_value(legacy).expect("legacy compiled state uses serde defaults");
    assert!(legacy.rules.iter().all(|rule| rule.regex_slots.is_empty()));
    assert!(legacy.rules.iter().all(|rule| rule.capture_gaps.is_none()));
    let legacy_edge = &legacy.find("Top").expect("legacy Top").acode_dispatch[0];
    assert_eq!(legacy_edge.selector_kind, RegexSelectorKind::Unindexed);
    assert_eq!(legacy_edge.source_id, "inline");
    assert_eq!(legacy_edge.line, 0);

    let cases = [
        (
            "Top::\n -bad=/H/\n",
            "regex_slot_name_invalid",
            "parse_declaration",
            2,
            json!({"slot_name":"-bad"}),
        ),
        (
            "Top::\n 123=/H/\n",
            "regex_slot_name_invalid",
            "parse_declaration",
            2,
            json!({"slot_name":"123"}),
        ),
        (
            "Top::\n head=/H/\n head=/S/\n",
            "regex_slot_duplicate_name",
            "resolve_declaration",
            3,
            json!({"slot_name":"head", "first_line":2}),
        ),
        (
            "Top::\n -> Part[missing] { return(\"x\") }\nPart:\n head=/H/\n",
            "regex_slot_unknown_name",
            "resolve_selector",
            2,
            json!({"target_rule":"Part", "authored_selector":"missing"}),
        ),
        (
            "Top::\n -> Part[2] { return(\"x\") }\nPart:\n /H/\n",
            "regex_slot_index_out_of_range",
            "resolve_selector",
            2,
            json!({"target_rule":"Part", "regex_index":2, "regex_count":1}),
        ),
        (
            "Top::\n -> Part[head { return(\"x\") }\nPart:\n head=/H/\n",
            "regex_slot_selector_invalid",
            "parse_selector",
            2,
            json!({"target_rule":"Part", "authored_selector":"head"}),
        ),
        (
            "Top::\n @capture_gaps\n @capture_gaps\n -> Part { return(\"x\") }\nPart: /H/\n",
            "capture_gaps_duplicate_directive",
            "parse_directive",
            3,
            json!({"first_line":2}),
        ),
        (
            "Top::AND\n @capture_gaps\n -> Part { return(\"x\") }\nPart: /H/\n",
            "capture_gaps_rule_ineligible",
            "validate_directive",
            2,
            json!({"family":"and", "cursor_policy":"consume", "edge_ownership":"action", "execution_shape":"single_match"}),
        ),
        (
            "Top::\n @capture_gaps\n => Part\nPart: /H/\n",
            "capture_gaps_rule_ineligible",
            "validate_directive",
            2,
            json!({"family":"or_default", "cursor_policy":"seek", "edge_ownership":"blind", "execution_shape":"default_scan_loop"}),
        ),
        (
            "Top::\n @capture_gaps\n @move_pos\n -> Part { return(\"x\") }\nPart: /H/\n",
            "capture_gaps_legacy_marker_conflict",
            "validate_directive",
            2,
            json!({"marker":"@move_pos", "marker_line":3}),
        ),
    ];
    for (source, code, stage, line, expected_fields) in cases {
        let diagnostic = diagnostic(source);
        assert_eq!(diagnostic.code, code);
        assert_eq!(diagnostic.stage, stage);
        assert_eq!(diagnostic.field("rule_label"), Some(&json!("Top")));
        assert_eq!(diagnostic.field("source_id"), Some(&json!("inline")));
        assert_eq!(diagnostic.field("line"), Some(&json!(line)));
        for (field, value) in expected_fields.as_object().expect("expected fields") {
            assert_eq!(
                diagnostic.field(field),
                Some(value),
                "diagnostic field {field}"
            );
        }
    }

    let native = compile_metadata(concat!(
        "Top::\n",
        " I { gaps = [] }\n",
        " @capture_gaps\n",
        " -> Part[head] { push(gaps, array(gap_kind(), gap_text())) }\n",
        " LX { push(gaps, array(gap_kind(), gap_text())); return(copy(gaps)) }\n",
        "Part:\n",
        " head=/H/\n",
        " I.return(entry_text())\n",
    ))
    .expect("compile native gap RED fixture");
    assert_eq!(
        Engine::new(native)
            .execute_value("αHω", &ExecutionOptions::new())
            .expect("native gap execution"),
        json!([["prefix", "α"], ["tail", "ω"]]),
    );

    assert_eq!(
        native_value(
            r#"Top::
 @capture_gaps
 -> Part { return("unexpected") }
 LS { return(array(gap_kind(), gap_text(), match_text())) }
Part: /H/
"#,
            "αH",
        ),
        json!(["prefix", "α", "H"]),
        "capture-enabled selection and local-match extraction precede LS",
    );

    let unicode_source = r#"Top::
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
"#;
    assert_eq!(
        native_value(unicode_source, "αHβ\nS🙂Fω"),
        json!([
            {
                "kind":"prefix", "text":"α",
                "span":{"source_id":"input", "start":0, "end":1, "provenance":"gap"},
                "child":{"slot":{"target_rule":"Part", "regex_index":0, "slot_id":"header", "selector_kind":"named", "authored_selector":"header"}, "text":"H", "falsey":0}
            },
            {
                "kind":"interstitial", "text":"β\n",
                "span":{"source_id":"input", "start":2, "end":4, "provenance":"gap"},
                "child":{"slot":{"target_rule":"Part", "regex_index":1, "slot_id":"section", "selector_kind":"named", "authored_selector":"section"}, "text":"S", "falsey":0}
            },
            {
                "kind":"interstitial", "text":"🙂",
                "span":{"source_id":"input", "start":5, "end":6, "provenance":"gap"},
                "child":{"slot":{"target_rule":"Part", "regex_index":2, "slot_id":"footer", "selector_kind":"named", "authored_selector":"footer"}, "text":"F", "falsey":0}
            },
            {"kind":"tail", "text":"ω", "span":{"source_id":"input", "start":7, "end":8, "provenance":"gap"}}
        ]),
        "Unicode gaps, detached spans, falsey values, and named entry slots are exact",
    );

    assert_eq!(
        native_value(
            r#"Top::
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
"#,
            "HSF",
        ),
        json!([
            ["prefix", "", {"source_id":"input", "start":0, "end":0, "provenance":"gap"}],
            ["interstitial", "", {"source_id":"input", "start":1, "end":1, "provenance":"gap"}],
            ["interstitial", "", {"source_id":"input", "start":2, "end":2, "provenance":"gap"}],
            ["tail", "", {"source_id":"input", "start":3, "end":3, "provenance":"gap"}]
        ]),
        "empty prefix, interstitial, and tail gaps remain first class",
    );

    assert_eq!(
        native_value(
            r#"Top::
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
"#,
            "p{abc}gap!",
        ),
        json!([["p", "}"], ["gap", "!"], ["", "tail"]]),
        "the accepted child exit cursor becomes the next committed boundary",
    );

    assert_eq!(
        native_value(
            r#"Top::
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
"#,
            "p{axtail",
        ),
        json!(["p", ["a", "tail"], "p"]),
        "nested gap owners hide and then restore the parent candidate",
    );

    assert_eq!(
        native_value(
            r#"Top::
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
"#,
            "aHXbS",
        ),
        json!(["a", "Xb", ""]),
        "recognition rollback restores the same invocation gap snapshot",
    );

    let terminal_cases = [
        (
            r#"Top::
 @capture_gaps
 -> Part { return(gap_text()) }
 LX { return(array(gap_kind(), gap_text(), gap_span())) }
Part: /H/
"#,
            "abc",
            json!(["tail", "abc", {"source_id":"input", "start":0, "end":3, "provenance":"gap"}]),
        ),
        (
            r#"Top::OR{0,2}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 EX { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
"#,
            "aHtail",
            json!(["a", "tail"]),
        ),
        (
            r#"Top::OR{0,2}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 EX { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
"#,
            "whole",
            json!(["whole"]),
        ),
        (
            r#"Top::OR{1}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 E { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
"#,
            "aHtail",
            json!(["a", "tail"]),
        ),
    ];
    for (source, input, expected) in terminal_cases {
        assert_eq!(native_value(source, input), expected);
    }

    let unavailable = Engine::new(
        compile_metadata("Direct::\n /H/\n I { return(gap_text()) }\n")
            .expect("compile unavailable-context fixture"),
    )
    .execute_value_with_diagnostics("H", &ExecutionOptions::new())
    .expect_err("gap access without a candidate must fail");
    assert_eq!(
        unavailable.message,
        "LINKEDSPEC_INTER_MATCH_GAP_ERROR:gap_capture_context_unavailable",
    );
    assert_eq!(
        unavailable.diagnostic.code.as_deref(),
        Some("gap_capture_context_unavailable"),
    );
    assert_eq!(unavailable.diagnostic.stage, "access_gap_context");

    let post_commit = Engine::new(
        compile_metadata(
            "Top::OR{1}\n @capture_gaps\n -> Part { return(0) }\n IT { return(gap_kind()) }\nPart: /H/\n",
        )
        .expect("compile post-commit IT fixture"),
    )
    .execute_value_with_diagnostics("H", &ExecutionOptions::new())
    .expect_err("IT must not retain the committed candidate");
    assert_eq!(
        post_commit.diagnostic.code.as_deref(),
        Some("gap_capture_context_unavailable"),
    );

    let regression = Engine::new(
        compile_metadata(
            "Top::OR{1}\n @capture_gaps\n -> Part { rewind_match_start() }\nPart: /H/\n",
        )
        .expect("compile cursor-regression fixture"),
    )
    .execute_value_with_diagnostics("aH", &ExecutionOptions::new())
    .expect_err("gap commit must reject cursor regression");
    assert_eq!(
        regression.message,
        "LINKEDSPEC_SOURCE_LOCATION_ERROR:source_location_cursor_regression",
    );
    assert_eq!(
        regression.diagnostic.code.as_deref(),
        Some("source_location_cursor_regression"),
    );

    assert_eq!(
        native_value(
            "Top::OR{2}\n @capture_gaps\n -> Part { return(gap_text()) }\n EX { return(\"unexpected-ex\") }\n E { return(\"unexpected-e\") }\nPart: /H/\n",
            "H",
        ),
        Value::Null,
        "failed repetition minimum exposes neither a tail nor terminal hooks",
    );

    assert_eq!(
        native_value("Part::\n /H/\n I { return(entry_slot()) }\n", "H"),
        Value::Null,
        "direct entry has no action-edge slot identity",
    );
}
