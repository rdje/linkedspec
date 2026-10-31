//! TYPE-REFERENCE-BOOK.1.2.23.3.72.2 — index source/prefix guards.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse index sources");
    validate(&parsed).expect("validate index sources");
    let compiled = compile(&parsed).expect("compile index sources");
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
            "index-result-guard-composition.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}

fn check(label: &str, source: &str, input: &str, expected: Value) {
    let actual = routes(source, input);
    eprintln!(
        "INDEX_GUARD_VALUE {label} {}",
        serde_json::to_string(&actual).unwrap()
    );
    for (route, value) in actual.into_iter().enumerate() {
        assert_eq!(
            value.expect("execute index source"),
            expected,
            "{label} route{route}"
        );
    }
}

fn check_case(label: &str) {
    let cases = guard_cases();
    let row = cases.iter().find(|row| row["id"] == label).unwrap();
    check(
        label,
        row["source"].as_str().unwrap(),
        row["input"].as_str().unwrap(),
        row.get("expected_nonperl")
            .unwrap_or(&row["expected"])
            .clone(),
    );
}

fn guard_cases() -> Vec<Value> {
    let mut cases: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/index_result_guard_cases.json"
    ))
    .unwrap();
    let null_prefix: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/index_null_prefix_guard_cases.json"
    ))
    .unwrap();
    cases.extend(null_prefix);
    cases
}

#[test]
fn primitive_indexes() {
    check_case("primitive_indexes");
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
fn compatible_values() {
    check_case("compatible_values");
}

#[test]
fn source_needle_snapshot() {
    check_case("source_needle_snapshot");
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
fn with_result_array() {
    check_case("with_result_array");
}

#[test]
fn needed_source_error() {
    check_source_error("needed_source_error");
}

#[test]
fn needed_needle_error() {
    check_source_error("needed_needle_error");
}

#[test]
fn function_scope() {
    check_case("function_scope");
}

#[test]
fn valid_array_bridges() {
    check_case("valid_array_bridges");
}

#[test]
fn literal_null_index() {
    check_case("literal_null_index");
}

#[test]
fn block_null_index() {
    check_case("block_null_index");
}

#[test]
fn selected_null_index() {
    check_case("selected_null_index");
}

fn check_source_error(label: &str) {
    let cases = guard_cases();
    let row = cases.iter().find(|row| row["id"] == label).unwrap();
    let actual = routes(
        row["source"].as_str().unwrap(),
        row["input"].as_str().unwrap(),
    );
    eprintln!(
        "INDEX_GUARD_ERROR {label} {}",
        serde_json::to_string(&actual).unwrap()
    );
    for result in actual {
        let error = result.expect_err("needed source error");
        assert!(
            error.contains(row["expected_error"].as_str().unwrap()),
            "{error}"
        );
    }
}
#[test]
fn excluded_source_shapes_stay_current() {
    use linkedspec_core::expr::CodeBlock;
    let rows: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/index_result_guard_excluded_ast.json"
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
    assert_eq!(shapes.len(), 18);
    eprintln!(
        "INDEX_GUARD_SHAPES {}",
        serde_json::to_string(&shapes).unwrap()
    );
}
