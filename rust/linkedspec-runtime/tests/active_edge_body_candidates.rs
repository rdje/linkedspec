//! TYPE-REFERENCE-BOOK.1.2.23.3.36.1 — outgoing edges own body choice candidates.
use linkedspec_core::compiler::compile;
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2, execute_generated_parser_with_trace_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
use std::fs;
use std::time::{SystemTime, UNIX_EPOCH};

fn compiled(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse active-edge source");
    validate(&parsed).expect("validate active-edge source");
    compile(&parsed).expect("compile active-edge source")
}

fn plan(spec: &CompiledSpec) -> Vec<GeneratedPlanRow> {
    spec.rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Top" => "Top",
                "Value" => "Value",
                "First" => "First",
                "Second" => "Second",
                "Landmark" => "Landmark",
                label => panic!("add stable fixture label {label}"),
            },
            family: classify_generated_rule_family(rule).contract_name(),
        })
        .collect()
}

fn check(source: &str, input: &str, expected: Value) {
    let spec = compiled(source);
    let serialized = serde_json::to_string(&spec).unwrap();
    let restored = serde_json::from_str(&serialized).unwrap();
    let plan = plan(&spec);
    // Evaluate all routes before asserting so a native RED cannot hide plan RED.
    let actual = vec![
        Engine::new(spec).execute_value(input, &ExecutionOptions::new()),
        Engine::new(restored).execute_value(input, &ExecutionOptions::new()),
        execute_generated_parser_v2(
            &serialized,
            &plan,
            input,
            "active-edge-body.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ];
    eprintln!("ACTIVE_EDGE native/restored/plan {actual:?}");
    assert_eq!(actual, vec![Ok(expected); 3]);
}

fn carrier(head: &str, action: &str) -> String {
    format!(
        "Top::\n -> Value .push\n LX {{return(copy(Top))}}\nValue:\n /(?<head>{head})/\n /:/\n /(?<token>cat)/\n -> Value[2] {{{action}}}\n"
    )
}

#[test]
fn wildcard_entry_does_not_compete_with_written_body_edge() {
    check(
        &carrier("..", "return(\"BODY\")"),
        "αβ:cat",
        json!(["BODY"]),
    );
}

#[test]
fn literal_entry_control_keeps_payload() {
    check(
        &carrier("αβ", "return(\"BODY\")"),
        "αβ:cat",
        json!(["BODY"]),
    );
}

#[test]
fn duplicate_choice_uses_edge_order_even_when_selectors_are_reversed() {
    for mode in ["", "|"] {
        let source = format!(
            "Top::\n -> Value .push\n LX {{return(copy(Top))}}\nValue:{mode}\n /H/\n /a/\n /a/\n -> Value[2] {{return(2)}}\n -> Value[1] {{return(1)}}\n"
        );
        check(&source, "Ha", json!([2]));
    }
}

#[test]
fn earliest_match_start_precedes_authored_edge_priority() {
    check(
        "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /H/\n /b/\n /a/\n -> Value[1] {return(\"B\")}\n -> Value[2] {return(\"A\")}\n",
        "Hab",
        json!(["A"]),
    );
}

#[test]
fn cross_target_choice_ignores_parent_declarations() {
    check(
        "Top::\n /./\n -> Second {return(\"second\")}\n -> First {return(\"first\")}\nFirst: /a/\nSecond: /a/\n",
        "a",
        json!("second"),
    );
}

#[test]
fn untargeted_match_cannot_trigger_local_match_hooks() {
    check(
        "Top::\n /./\n @capture_gaps\n -> Value {return(\"edge\")}\n LS {return(\"wrong\")}\n LX {return(\"miss\")}\nValue: /cat/\n",
        "x",
        json!("miss"),
    );
}

#[test]
fn selected_capture_identity_and_unicode_source_positions_are_preserved() {
    check(
        &carrier(
            "..",
            "mark_match_start(begin);mark_match_end(finish);return([match_text(),match_group(0),match_named(token),mark_pos(begin),mark_pos(finish),entry_named(head)])",
        ),
        "αβ:cat",
        json!([["cat", "cat", "cat", 3, 6, "αβ"]]),
    );
}

#[test]
fn boundary_lookahead_keeps_untargeted_catalog_slots() {
    check(
        "Top:: I {return(capture_until_boundary(\"Landmark\"))}\nLandmark:\n /END/\n /!/\n -> Landmark[1] {return(1)}\n",
        "bodyEND!",
        json!("body"),
    );
}

#[test]
fn established_duplicate_slot_fixtures_keep_ordered_and_repeated_behavior() {
    let contract: Value = serde_json::from_str(include_str!(
        "../../../capability_conformance/duplicate_regex_slot_identity_contract.json"
    ))
    .unwrap();
    for row in contract["fixtures"].as_array().unwrap() {
        check(
            row["source"].as_str().unwrap(),
            row["input"].as_str().unwrap(),
            row["expected_result"].clone(),
        );
    }
}

#[test]
fn rule_family_still_owns_seek_or_consume() {
    check(
        "Top:: /x/ -> Top {return(\"hit\")}\n",
        "prefix x",
        json!("hit"),
    );
    check(
        "Top::AND /x/ -> Top {return(\"hit\")}\n",
        "prefix x",
        Value::Null,
    );
}

#[test]
fn inter_match_gap_uses_selected_edge_span() {
    let source = carrier("..", "return(\"unreached\")").replace(
        " -> Value[2]",
        " @capture_gaps\n LS {return([gap_text(),gap_span(),match_text()])}\n -> Value[2]",
    );
    check(
        &source,
        "αβ:cat",
        json!([[":", {"source_id":"input","start":2,"end":3,"provenance":"gap"}, "cat"]]),
    );
}

#[test]
fn native_and_generated_trace_attribute_the_written_structural_slot() {
    let source = carrier("..", "return(\"BODY\")");
    let spec = compiled(&source);
    let serialized = serde_json::to_string(&spec).unwrap();
    let plan = plan(&spec);
    assert_eq!(spec.find("Value").unwrap().regex_patterns.len(), 3);
    let edge = &spec.find("Value").unwrap().acode_dispatch[0];
    assert_eq!((edge.regex_idx, edge.child_regex_idx), (2, 2));
    let nonce = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_nanos();
    let mut observations = Vec::new();
    for generated in [false, true] {
        let path = std::env::temp_dir().join(format!(
            "active-edge-{}-{nonce}-{generated}.log",
            std::process::id()
        ));
        let trace = TraceConfig::enabled(TraceLevel::DEBUG)
            .with_trace_file(path.clone())
            .with_reset_file(true);
        let actual = if generated {
            execute_generated_parser_with_trace_v2(
                &serialized,
                &plan,
                "αβ:cat",
                trace,
                "active-edge-body.spec",
                GENERATED_SOURCE_CONTRACT,
            )
            .map_err(|error| error.to_string())
        } else {
            Engine::new(spec.clone()).execute_value_with_trace(
                "αβ:cat",
                &ExecutionOptions::new(),
                trace,
            )
        };
        let trace = fs::read_to_string(&path).expect("read active-edge trace");
        fs::remove_file(path).expect("remove owned trace");
        let selected: Vec<_> = trace
            .lines()
            .filter(|line| {
                line.contains("regex_slot_selected") && line.contains("rule_label=Value ")
            })
            .map(str::to_owned)
            .collect();
        eprintln!("ACTIVE_EDGE_TRACE generated={generated} {selected:?}");
        observations.push((actual, selected));
    }
    for (actual, selected) in observations {
        assert_eq!(actual.unwrap(), json!(["BODY"]));
        assert_eq!(selected.len(), 1);
        assert!(selected[0].contains("target_rule=Value regex_index=2"));
    }
}
