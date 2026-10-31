//! TYPE-REFERENCE-BOOK.1.2.23.3.69.6.2 — copied-null presence composition.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse has_key sources");
    validate(&parsed).expect("validate has_key sources");
    let compiled = compile(&parsed).expect("compile has_key sources");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Value" => "Value",
                "Child" => "Child",
                "Top" => "Top",
                other => panic!("unexpected fixture label {other}"),
            },
            family: classify_generated_rule_family(rule).contract_name(),
        })
        .collect();
    vec![
        Engine::new(compiled)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|e| e.to_string()),
        Engine::new(restored)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|e| e.to_string()),
        execute_generated_parser_v2(
            &serialized,
            &plan,
            input,
            "copied-null-presence-composition.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}

fn check_case(label: &str) {
    let cases: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/copied_null_presence_cases.json"
    ))
    .unwrap();
    let row = cases
        .as_array()
        .unwrap()
        .iter()
        .find(|row| row["id"] == label)
        .unwrap();
    let actual = routes(
        row["source"].as_str().unwrap(),
        row["input"].as_str().unwrap(),
    );
    eprintln!(
        "COPIED_NULL_VALUE {label} {}",
        serde_json::to_string(&actual).unwrap()
    );
    for (route, result) in actual.into_iter().enumerate() {
        if let Some(expected) = row.get("expected_error") {
            let error = result.expect_err("needed key error");
            assert!(
                error.contains(expected.as_str().unwrap()),
                "{label} route{route}: {error}"
            );
        } else {
            assert_eq!(
                result.expect("execute copied-null presence"),
                row["expected"],
                "{label} route{route}"
            );
        }
    }
}

#[test]
fn copy_forms() {
    check_case("copy_forms");
}

#[test]
fn null_source_key_snapshot() {
    check_case("null_source_key_snapshot");
}

#[test]
fn repeated_copy() {
    check_case("repeated_copy");
}

#[test]
fn valid_null_with_copy() {
    check_case("valid_null_with_copy");
}

#[test]
fn valid_null_numeric_copy() {
    check_case("valid_null_numeric_copy");
}

#[test]
fn copied_wrong_kinds() {
    check_case("copied_wrong_kinds");
}

#[test]
fn rejected_copy() {
    check_case("rejected_copy");
}

#[test]
fn needed_key_error() {
    check_case("needed_key_error");
}

#[test]
fn hash_source_key_snapshot() {
    check_case("hash_source_key_snapshot");
}

#[test]
fn present_null_copy() {
    check_case("present_null_copy");
}

#[test]
fn rejected_copy_without_with() {
    let actual = routes(
        r#"Top:: I {order="";out=has_key({},"k").take({order=cat(order,"A");1}).copy().has_key({order=cat(order,"K");"k"});return([out,order])}"#,
        "x",
    );
    eprintln!(
        "COPIED_NULL_VALUE rejected_copy_without_with {}",
        serde_json::to_string(&actual).unwrap()
    );
    for value in actual {
        assert_eq!(
            value.expect("rejected copy is a value"),
            serde_json::json!([null, ""])
        );
    }
}
