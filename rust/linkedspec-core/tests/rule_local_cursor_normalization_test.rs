use linkedspec_core::ast::{BodyElementKind, RuleMode};
use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use serde_json::Value;
use std::collections::BTreeSet;

const CONTRACT_SOURCE: &str =
    include_str!("../../../capability_conformance/rule_local_cursor_contract.json");

fn contract() -> Value {
    serde_json::from_str(CONTRACT_SOURCE).expect("rule-local cursor contract must be valid JSON")
}

fn edge_source(parent_family: &str, sources: &[&str], declared_rules: &[&str]) -> String {
    let mut source = if parent_family == "and" {
        "Top::AND\n".to_string()
    } else {
        "Top::\n".to_string()
    };
    for edge in sources {
        source.push(' ');
        source.push_str(edge);
        source.push('\n');
    }
    for label in declared_rules {
        source.push('\n');
        source.push_str(label);
        source.push_str(":\n /x/ /y/\n");
    }
    source
}

fn diagnostic_for(source: &str) -> linkedspec_core::error::PortableDiagnostic {
    let parsed = parse_spec(source).expect("diagnostic fixture must parse to typed AST");
    validate(&parsed)
        .expect_err("diagnostic fixture must be rejected")
        .diagnostic()
        .expect("failure must carry a portable diagnostic")
        .clone()
}

#[test]
fn contract_family_cases_use_exact_authored_classification() {
    let contract = contract();
    for case in contract["family_cases"].as_array().unwrap() {
        let id = case["id"].as_str().unwrap();
        let source = format!("{}\n /x/\n", case["header"].as_str().unwrap());
        let parsed = parse_spec(&source).unwrap_or_else(|error| panic!("{id}: {error}"));
        let mode = &parsed.rules[0].header.mode;
        assert_eq!(mode.is_and(), case["family"] == "and", "{id}");
    }

    assert!(!RuleMode::Pipe.is_and(), "compact | is authored OR");
    assert!(RuleMode::Single.is_and(), "compact & is authored AND");
}

#[test]
fn contract_edge_cases_parse_validate_and_lower_exactly() {
    let contract = contract();
    let diagnostics = contract["diagnostics"].as_array().unwrap();

    for case in contract["edge_resolution_cases"].as_array().unwrap() {
        let id = case["id"].as_str().unwrap();
        let source_text = case["source"].as_str().unwrap();
        let declared = case["declared_rules"]
            .as_array()
            .unwrap()
            .iter()
            .map(|label| label.as_str().unwrap())
            .collect::<Vec<_>>();
        let source = edge_source(
            case["parent_family"].as_str().unwrap(),
            &[source_text],
            &declared,
        );

        if let Some(expected_code) = case.get("expected_error").and_then(Value::as_str) {
            let diagnostic = diagnostic_for(&source);
            let diagnostic_contract = diagnostics
                .iter()
                .find(|row| row["code"] == expected_code)
                .unwrap();
            assert_eq!(diagnostic.code, expected_code, "{id}");
            assert_eq!(
                diagnostic.stage,
                diagnostic_contract["stage"].as_str().unwrap(),
                "{id}"
            );
            let expected_fields = diagnostic_contract["fields"]
                .as_array()
                .unwrap()
                .iter()
                .map(|field| field.as_str().unwrap())
                .collect::<BTreeSet<_>>();
            let actual_fields = diagnostic
                .fields
                .keys()
                .map(String::as_str)
                .collect::<BTreeSet<_>>();
            assert_eq!(actual_fields, expected_fields, "{id}: diagnostic fields");

            assert_eq!(
                diagnostic.field("rule_label"),
                Some(&serde_json::json!("Top")),
                "{id}: rule attribution"
            );
            if expected_fields.contains("target") {
                let expected_target = if expected_code == "bare_edge_target_undefined" {
                    "Missing"
                } else {
                    "Child"
                };
                assert_eq!(
                    diagnostic.field("target"),
                    Some(&serde_json::json!(expected_target)),
                    "{id}: target attribution"
                );
            }
            if expected_fields.contains("regex_index") {
                assert_eq!(
                    diagnostic.field("regex_index"),
                    Some(&serde_json::json!(0)),
                    "{id}: explicit zero index must be retained"
                );
            }
            if expected_fields.contains("targets") {
                assert_eq!(
                    diagnostic.field("targets"),
                    Some(&serde_json::json!(declared)),
                    "{id}: grouped target order"
                );
            }

            let serialized = serde_json::to_string(&diagnostic).unwrap();
            let roundtrip: linkedspec_core::error::PortableDiagnostic =
                serde_json::from_str(&serialized).unwrap();
            assert_eq!(roundtrip, diagnostic, "{id}: diagnostic JSON roundtrip");
            continue;
        }

        let parsed = parse_spec(&source).unwrap_or_else(|error| panic!("{id}: {error}"));
        validate(&parsed).unwrap_or_else(|error| panic!("{id}: {error}"));
        let expected = &case["expected"];
        if expected["kind"] == "lifecycle" {
            assert!(matches!(
                parsed.rules[0].body[0].kind,
                BodyElementKind::LifecycleMarker { .. }
            ));
            continue;
        }

        if expected["source_form"] == "bare" {
            let BodyElementKind::BareEdge {
                targets,
                code,
                fluent_chain,
            } = &parsed.rules[0].body[0].kind
            else {
                panic!("{id}: bare source was not retained as typed BareEdge");
            };
            assert_eq!(targets.len(), expected["targets"].as_array().unwrap().len());
            assert_eq!(code.is_some(), expected["has_block"].as_bool().unwrap());
            let expected_fluent = expected["targets"][0]["fluent"].as_str();
            assert_eq!(
                fluent_chain.first().map(|call| {
                    if call.args.is_empty() {
                        call.method.clone()
                    } else {
                        format!("{}({})", call.method, call.args)
                    }
                }),
                expected_fluent.map(str::to_string),
                "{id}"
            );
            assert!(
                parsed.rules[0]
                    .body
                    .iter()
                    .all(|element| !matches!(element.kind, BodyElementKind::Raw { .. })),
                "{id}: governed bare source must never fall back to Raw"
            );
        }

        let compiled = compile(&parsed).unwrap_or_else(|error| panic!("{id}: {error}"));
        let serialized = serde_json::to_string(&compiled).unwrap();
        let compiled: CompiledSpec = serde_json::from_str(&serialized).unwrap();
        let top = &compiled.rules[0];
        let expected_targets = expected["targets"].as_array().unwrap();
        if expected["ownership"] == "action" {
            assert_eq!(top.acode_dispatch.len(), expected_targets.len(), "{id}");
            assert!(top.bcode_dispatch.is_empty(), "{id}");
            for (actual, expected) in top.acode_dispatch.iter().zip(expected_targets) {
                assert_eq!(actual.child_label, expected["label"], "{id}");
                assert_eq!(
                    actual.child_regex_idx,
                    expected["index"].as_u64().unwrap_or(0) as usize,
                    "{id}"
                );
            }
        } else {
            assert_eq!(top.bcode_dispatch.len(), expected_targets.len(), "{id}");
            assert!(top.acode_dispatch.is_empty(), "{id}");
            for (actual, expected) in top.bcode_dispatch.iter().zip(expected_targets) {
                assert_eq!(actual.child_label, expected["label"], "{id}");
            }
        }
    }
}

#[test]
fn contract_rule_edge_sets_validate_normalized_ownership() {
    let contract = contract();
    for case in contract["rule_edge_set_cases"].as_array().unwrap() {
        let id = case["id"].as_str().unwrap();
        let sources = case["sources"]
            .as_array()
            .unwrap()
            .iter()
            .map(|source| source.as_str().unwrap())
            .collect::<Vec<_>>();
        let declared = case["declared_rules"]
            .as_array()
            .unwrap()
            .iter()
            .map(|label| label.as_str().unwrap())
            .collect::<Vec<_>>();
        let source = edge_source(case["parent_family"].as_str().unwrap(), &sources, &declared);

        if let Some(expected_code) = case.get("expected_error").and_then(Value::as_str) {
            let diagnostic = diagnostic_for(&source);
            assert_eq!(diagnostic.code, expected_code, "{id}");
            assert_eq!(diagnostic.stage, "validate_rule", "{id}");
            assert_eq!(
                diagnostic
                    .fields
                    .keys()
                    .map(String::as_str)
                    .collect::<BTreeSet<_>>(),
                BTreeSet::from(["ownerships", "rule_label"]),
                "{id}: diagnostic fields"
            );
            assert_eq!(
                diagnostic.field("ownerships"),
                Some(&serde_json::json!(["action", "blind"])),
                "{id}"
            );
            continue;
        }

        let parsed = parse_spec(&source).unwrap_or_else(|error| panic!("{id}: {error}"));
        validate(&parsed).unwrap_or_else(|error| panic!("{id}: {error}"));
        let compiled = compile(&parsed).unwrap_or_else(|error| panic!("{id}: {error}"));
        let top = &compiled.rules[0];
        if case["expected_ownership"] == "action" {
            assert!(!top.acode_dispatch.is_empty(), "{id}");
            assert!(top.bcode_dispatch.is_empty(), "{id}");
        } else {
            assert!(!top.bcode_dispatch.is_empty(), "{id}");
            assert!(top.acode_dispatch.is_empty(), "{id}");
        }
    }
}

#[test]
fn complete_line_header_rest_and_multiline_bare_edges_remain_typed() {
    for source in [
        "Top::\n Child\n\nChild:\n /x/\n",
        "Top:: Child\n\nChild:\n /x/\n",
        "Top::AND\n Child {\n  return(child_result)\n }\n\nChild:\n /x/\n",
    ] {
        let parsed = parse_spec(source).unwrap();
        assert!(matches!(
            parsed.rules[0].body[0].kind,
            BodyElementKind::BareEdge { .. }
        ));
        assert!(
            parsed.rules[0]
                .body
                .iter()
                .all(|element| !matches!(element.kind, BodyElementKind::Raw { .. }))
        );
    }

    let same_line_suffix = parse_spec("Top:: /x/ Child\n\nChild:\n /x/\n").unwrap();
    assert!(
        same_line_suffix.rules[0]
            .body
            .iter()
            .all(|element| !matches!(element.kind, BodyElementKind::BareEdge { .. })),
        "bare recognition is physical-line scoped"
    );
}

#[test]
fn compiler_lowers_family_ownership_into_typed_dispatch_tables() {
    let default_spec = parse_spec("Top::\n Child\n\nChild:\n /x/\n").unwrap();
    validate(&default_spec).unwrap();
    let default_compiled = compile(&default_spec).unwrap();
    assert_eq!(default_compiled.rules[0].acode_dispatch.len(), 1);
    assert!(default_compiled.rules[0].bcode_dispatch.is_empty());

    let and_spec = parse_spec("Top::AND\n Child\n\nChild:\n /x/\n").unwrap();
    validate(&and_spec).unwrap();
    let and_compiled = compile(&and_spec).unwrap();
    assert_eq!(and_compiled.rules[0].bcode_dispatch.len(), 1);
    assert!(and_compiled.rules[0].acode_dispatch.is_empty());

    let explicit_blind = parse_spec("Top::\n => Child\n\nChild:\n /x/\n").unwrap();
    validate(&explicit_blind).unwrap();
    let explicit_blind = compile(&explicit_blind).unwrap();
    assert_eq!(explicit_blind.rules[0].bcode_dispatch.len(), 1);
}
