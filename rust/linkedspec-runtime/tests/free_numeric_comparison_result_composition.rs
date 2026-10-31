//! TYPE-REFERENCE-BOOK.1.2.23.3.64.2 — canonical numeric comparison source and Number-prefix result guards.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse numeric comparison sources");
    validate(&parsed).expect("validate numeric comparison sources");
    let compiled = compile(&parsed).expect("compile numeric comparison sources");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Value" => "Value",
                "Child" => "Child",
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
            "free-numeric-comparison-result-composition.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}

fn check(label: &str, source: &str, input: &str, expected: Value) {
    let actual = routes(source, input);
    eprintln!(
        "FREE_NUMERIC_COMPARISON_VALUE {label} {}",
        serde_json::to_string(&actual).unwrap()
    );
    for (route, value) in actual.into_iter().enumerate() {
        assert_eq!(
            value.expect("execute numeric comparison source"),
            expected,
            "{label} route{route}"
        );
    }
}

fn check_case(label: &str) {
    let cases: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/free_numeric_comparison_result_cases.json"
    ))
    .unwrap();
    let row = cases
        .as_array()
        .unwrap()
        .iter()
        .find(|row| row["id"] == label)
        .unwrap();
    check(
        label,
        row["source"].as_str().unwrap(),
        row["input"].as_str().unwrap(),
        row["expected"].clone(),
    );
}

#[test]
fn primitive_comparisons() {
    check_case("primitive_comparisons");
}

#[test]
fn strict_numeric_domains() {
    check_case("strict_numeric_domains");
}

#[test]
fn compatible_values() {
    check_case("compatible_values");
}

#[test]
fn free_container_guards() {
    check_case("free_container_guards");
}

#[test]
fn receiver_container_guards() {
    check_case("receiver_container_guards");
}

#[test]
fn free_guard_before_with() {
    check_case("free_guard_before_with");
}

#[test]
fn receiver_guard_before_with() {
    check_case("receiver_guard_before_with");
}

#[test]
fn free_bridge_rejection() {
    check_case("free_bridge_rejection");
}

#[test]
fn receiver_bridge_rejection() {
    check_case("receiver_bridge_rejection");
}

#[test]
fn valid_array_bridges() {
    check_case("valid_array_bridges");
}

#[test]
fn source_operand_snapshot() {
    check_case("source_operand_snapshot");
}

#[test]
fn zero_typed_indices() {
    check_case("zero_typed_indices");
}

#[test]
fn valid_null_with() {
    check_case("valid_null_with");
}

#[test]
fn valid_empty_with() {
    check_case("valid_empty_with");
}

#[test]
fn all_canonical_free_guards() {
    check_case("all_canonical_free_guards");
}

#[test]
fn all_short_receiver_with_guards() {
    check_case("all_short_receiver_with_guards");
}

#[test]
fn function_scope() {
    check_case("function_scope");
}

#[test]
fn valid_zero_and_one_with() {
    check_case("valid_zero_and_one_with");
}

#[test]
fn needed_source_error_precedes_recovery() {
    let cases: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/free_numeric_comparison_result_cases.json"
    ))
    .unwrap();
    let row = cases
        .as_array()
        .unwrap()
        .iter()
        .find(|row| row["expected_error"].is_string())
        .unwrap();
    let actual = routes(
        row["source"].as_str().unwrap(),
        row["input"].as_str().unwrap(),
    );
    eprintln!(
        "FREE_NUMERIC_COMPARISON_ERROR {}",
        serde_json::to_string(&actual).unwrap()
    );
    for route in actual {
        assert!(route.unwrap_err().contains("binding_kind_mismatch"));
    }
}
#[test]
fn excluded_source_shapes_stay_current() {
    use linkedspec_core::expr::CodeBlock;
    let rows: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/free_numeric_comparison_excluded_source_ast.json"
    ))
    .unwrap();
    let shapes: Vec<_> = rows
        .as_array()
        .unwrap()
        .iter()
        .map(|row| {
            let source = row["source"].as_str().unwrap();
            (source, CodeBlock::parse(source))
        })
        .collect();
    assert_eq!(shapes.len(), 14);
    eprintln!(
        "FREE_NUMERIC_COMPARISON_SHAPES {}",
        serde_json::to_string(&shapes).unwrap()
    );
}
