use linkedspec_core::ast::{FunctionDefinition, SourceSpan};
use linkedspec_core::compiler::compile;
use linkedspec_core::entry_rule::ENTRY_RULE_CONTRACT_ID;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::types::CompiledSpec;
use serde_json::{Value, json};
use std::collections::BTreeSet;
use std::path::PathBuf;

fn descriptor_contract() -> serde_json::Value {
    let path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("..")
        .join("capability_conformance")
        .join("outward_descriptor_contract.json");
    serde_json::from_str(&std::fs::read_to_string(path).unwrap()).unwrap()
}

fn cursor_contract() -> Value {
    let path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("..")
        .join("capability_conformance")
        .join("rule_local_cursor_contract.json");
    serde_json::from_str(&std::fs::read_to_string(path).unwrap()).unwrap()
}

fn edge_source(parent_family: &str, edge: &str, declared_rules: &[&str]) -> String {
    let mut source = if parent_family == "and" {
        "Top::AND\n".to_string()
    } else {
        "Top::\n".to_string()
    };
    source.push(' ');
    source.push_str(edge);
    source.push('\n');
    for label in declared_rules {
        source.push('\n');
        source.push_str(label);
        source.push_str(":\n /x/ /y/\n");
    }
    source
}

#[test]
fn projects_backend_neutral_descriptor_shape_and_staged_function_metadata() {
    let mut parsed = parse_spec("Top::OR\n /x/ -> Child\n\nChild:\n /[a-z]+/\n").unwrap();
    parsed.functions.push(FunctionDefinition {
        name: "normalize".to_string(),
        params: vec!["value".to_string()],
        arity: 1,
        signature: None,
        body_source: "return(trim(value))".to_string(),
        body_payload: Some(json!({
            "kind": "staged_payload",
            "payload_kind": "function_body",
            "parent_ast_path": ["functions", "0", "body_source"]
        })),
        body_parse_job: Some(json!({
            "kind": "parse_job",
            "job_id": "parse_job:function_body:functions.0.body_source"
        })),
        body_ast: Some(json!({"kind": "action_block", "statements": []})),
        source: "fn normalize(value) { return(trim(value)) }".to_string(),
        source_span: SourceSpan {
            line_start: 1,
            line_end: 1,
        },
        body_span: SourceSpan {
            line_start: 1,
            line_end: 1,
        },
    });

    let compiled = compile(&parsed).unwrap();
    let descriptor = compiled.descriptor_state();
    let contract = descriptor_contract();
    assert_eq!(
        descriptor.meta.descriptor_model,
        "compiled_descriptor_state"
    );
    assert_eq!(descriptor.meta.compiled_spec_model, "compiled_spec_state");
    assert_eq!(
        descriptor.meta.compiled_dependency_regex_model,
        "compiled_dependency_regex_state"
    );
    assert_eq!(descriptor.meta.definition_order, ["Top", "Child"]);
    assert_eq!(descriptor.meta.compiled_rule_order, ["Top", "Child"]);
    assert_eq!(descriptor.meta.function_order, ["normalize"]);
    assert_eq!(descriptor.meta.function_count, 1);
    assert_eq!(descriptor.meta.entry_rule_contract, ENTRY_RULE_CONTRACT_ID);

    let top = &descriptor.spec["Top"];
    assert_eq!(top.handler.kind, "rust_interpreter_rule");
    assert_eq!(top.regex_patterns, ["x"]);
    assert_eq!(top.dependency_refs.len(), 1);
    assert_eq!(top.dependency_refs[0].label, "Child");
    assert_eq!(top.dependency_refs[0].index, 0);
    assert_eq!(top.meta.mode.name, "Or");

    let dependency = &descriptor.dependency_regex_map["Top"];
    assert_eq!(dependency.patterns, ["[a-z]+"]);
    assert_eq!(dependency.combined_pattern, "(?:[a-z]+)");

    let function = &descriptor.functions["normalize"];
    assert_eq!(function.index, 0);
    assert_eq!(function.kind, "user_function_definition");
    assert_eq!(function.version, 1);
    assert_eq!(
        function.body_payload.as_ref().unwrap()["kind"],
        "staged_payload"
    );
    assert_eq!(
        function.body_parse_job.as_ref().unwrap()["kind"],
        "parse_job"
    );
    assert_eq!(function.body_ast.as_ref().unwrap()["kind"], "action_block");

    let json = compiled.to_descriptor_json().unwrap();
    let cursor_variant = &contract["meta_contract_variants"]["rule_local_cursor_v1"];
    for key in cursor_variant["required_keys"].as_array().unwrap() {
        assert!(json["meta"].get(key.as_str().unwrap()).is_some());
    }
    for key in cursor_variant["forbidden_keys"].as_array().unwrap() {
        assert!(json["meta"].get(key.as_str().unwrap()).is_none());
    }
    assert_eq!(
        json["meta"]["cursor_contract"],
        cursor_variant["cursor_contract"]
    );
    let expected_top_keys = contract["top_level_keys"]
        .as_array()
        .unwrap()
        .iter()
        .map(|key| key.as_str().unwrap().to_string())
        .collect::<BTreeSet<_>>();
    assert_eq!(
        json.as_object()
            .unwrap()
            .keys()
            .cloned()
            .collect::<BTreeSet<_>>(),
        expected_top_keys
    );
    let expected_function_keys = contract["function_record_keys"]
        .as_array()
        .unwrap()
        .iter()
        .map(|key| key.as_str().unwrap().to_string())
        .collect::<BTreeSet<_>>();
    assert_eq!(
        json["functions"]["normalize"]
            .as_object()
            .unwrap()
            .keys()
            .cloned()
            .collect::<BTreeSet<_>>(),
        expected_function_keys
    );
    assert_eq!(json["spec"]["Top"]["dependency_refs"][0]["idx"], 0);
}

#[test]
fn descriptor_projection_survives_compiled_spec_json_roundtrip() {
    let parsed = parse_spec("Top::\n -> Child\n\nChild:\n /x/\n").unwrap();
    let compiled = compile(&parsed).unwrap();
    let encoded = serde_json::to_string(&compiled).unwrap();
    let decoded: CompiledSpec = serde_json::from_str(&encoded).unwrap();
    assert_eq!(compiled.descriptor_state(), decoded.descriptor_state());
}

#[test]
fn projects_rule_local_cursor_v1_from_normalized_compiled_semantics() {
    let contract = cursor_contract();
    let descriptor_contract = &contract["descriptor_contract"];
    let root_legacy_field = descriptor_contract["removed_fields"][0]
        .as_str()
        .unwrap()
        .rsplit('.')
        .next()
        .unwrap();
    let rule_legacy_field = descriptor_contract["removed_fields"][1]
        .as_str()
        .unwrap()
        .rsplit('.')
        .next()
        .unwrap();

    for case in contract["family_cases"].as_array().unwrap() {
        let id = case["id"].as_str().unwrap();
        let source = format!("{}\n /x/\n", case["header"].as_str().unwrap());
        let compiled = compile(&parse_spec(&source).unwrap()).unwrap();
        let descriptor = compiled.to_descriptor_json().unwrap();
        let rule = &descriptor["spec"]["Top"]["meta"];

        assert_eq!(
            descriptor["meta"]["cursor_contract"], descriptor_contract["meta"]["cursor_contract"],
            "{id}"
        );
        assert!(descriptor["meta"].get(root_legacy_field).is_none(), "{id}");
        assert!(rule.get(rule_legacy_field).is_none(), "{id}");
        assert_eq!(rule["family"], case["family"], "{id}");
        assert_eq!(rule["cursor_policy"], case["cursor_policy"], "{id}");
        assert_eq!(rule["mode"]["is_and"], case["family"] == "and", "{id}");
    }

    let semantic_fields = descriptor_contract["resolved_edge_fields"]
        .as_array()
        .unwrap()
        .iter()
        .map(|field| field.as_str().unwrap().to_string())
        .collect::<BTreeSet<_>>();
    for case in contract["edge_resolution_cases"].as_array().unwrap() {
        let Some(expected) = case.get("expected") else {
            continue;
        };
        if expected["kind"] != "edge" {
            continue;
        }

        let id = case["id"].as_str().unwrap();
        let declared = case["declared_rules"]
            .as_array()
            .unwrap()
            .iter()
            .map(|label| label.as_str().unwrap())
            .collect::<Vec<_>>();
        let source = edge_source(
            case["parent_family"].as_str().unwrap(),
            case["source"].as_str().unwrap(),
            &declared,
        );
        let compiled = compile(&parse_spec(&source).unwrap()).unwrap();
        let direct = compiled.to_descriptor_json().unwrap();
        let encoded = serde_json::to_string(&compiled).unwrap();
        let reconstructed: CompiledSpec = serde_json::from_str(&encoded).unwrap();
        assert_eq!(direct, reconstructed.to_descriptor_json().unwrap(), "{id}");

        let rows = direct["spec"]["Top"]["meta"]["resolved_edges"]
            .as_array()
            .unwrap();
        let targets = expected["targets"].as_array().unwrap();
        assert_eq!(rows.len(), targets.len(), "{id}: ordered row count");
        assert_eq!(
            direct["spec"]["Top"]["meta"]["edge_ownership"], expected["ownership"],
            "{id}"
        );

        for (row, target) in rows.iter().zip(targets) {
            assert_eq!(row["ownership"], expected["ownership"], "{id}");
            assert_eq!(row["target"], target["label"], "{id}");
            if expected["ownership"] == "action" {
                assert_eq!(
                    row["regex_index"],
                    target["index"].as_u64().unwrap_or(0),
                    "{id}"
                );
            } else {
                assert!(row["regex_index"].is_null(), "{id}");
            }
            assert_eq!(row["block"], expected["has_block"], "{id}");
            assert_eq!(row["fluent"], target["fluent"], "{id}");
            assert_eq!(
                row.as_object()
                    .unwrap()
                    .keys()
                    .cloned()
                    .collect::<BTreeSet<_>>(),
                semantic_fields,
                "{id}: exact semantic fields"
            );
        }
    }
}

#[test]
fn descriptor_projection_uses_last_definition_order_deterministically() {
    let parsed = parse_spec("Top::\n /first/\n\nTop::\n /second/\n").unwrap();
    let compiled = compile(&parsed).unwrap();
    let descriptor = compiled.descriptor_state();
    assert_eq!(descriptor.meta.definition_order, ["Top", "Top"]);
    assert_eq!(descriptor.meta.compiled_rule_order, ["Top"]);
    assert_eq!(descriptor.meta.redefined_rule_labels, ["Top"]);
    assert_eq!(descriptor.spec["Top"].regex_patterns, ["second"]);
}
