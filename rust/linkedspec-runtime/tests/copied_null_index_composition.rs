//! TYPE-REFERENCE-BOOK.1.2.23.3.72.6.2 — copied-null index composition.
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
            "copied-null-index-composition.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}

fn check_case(label: &str) {
    let cases: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/copied_null_index_cases.json"
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
            let error = result.expect_err("needed needle error");
            assert!(
                error.contains(expected.as_str().unwrap()),
                "{label} route{route}: {error}"
            );
        } else {
            assert_eq!(
                result.expect("execute copied-null index"),
                row["expected"],
                "{label} route{route}"
            );
        }
    }
}

#[test]
fn copy_rejection() {
    check_case("copy_rejection");
}

#[test]
fn copy_null_forms() {
    check_case("copy_null_forms");
}

#[test]
fn valid_null_with_copy() {
    check_case("valid_null_with_copy");
}

#[test]
fn rejected_copy_with() {
    check_case("rejected_copy_with");
}

#[test]
fn null_source_needle_snapshot() {
    check_case("null_source_needle_snapshot");
}

#[test]
fn repeated_copy() {
    check_case("repeated_copy");
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
fn rejected_copy_without_with() {
    check_case("rejected_copy_without_with");
}

#[test]
fn needed_needle_error() {
    check_case("needed_needle_error");
}

#[test]
fn array_source_needle_snapshot() {
    check_case("array_source_needle_snapshot");
}

#[test]
fn copied_array_indexes() {
    check_case("copied_array_indexes");
}

#[test]
fn copied_null_needle_policy() {
    let actual = routes(
        r###"Value:: I {order="";out=[{undef}.copy().index_of({order=cat(order,"A");"a"}),copy({undef}).index_of({order=cat(order,"B");"a"}),index_of(copy({undef}),{order=cat(order,"C");"a"})];return([out,order])}"###,
        "x",
    );
    eprintln!(
        "COPIED_NULL_VALUE copied_null_needle_policy {}",
        serde_json::to_string(&actual).unwrap()
    );
    let expected: Value = serde_json::from_str(r###"[[null, null, null], "ABC"]"###).unwrap();
    for result in actual {
        assert_eq!(result.unwrap(), expected);
    }
}

#[test]
fn null_source_needle_policy() {
    let actual = routes(
        r###"Value:: I {order="";out=[index_of(undef,{order=cat(order,"F");"a"}),{undef}.index_of({order=cat(order,"R");"a"}),[].first().index_of({order=cat(order,"S");"a"})];return([out,order])}"###,
        "x",
    );
    eprintln!(
        "COPIED_NULL_VALUE null_source_needle_policy {}",
        serde_json::to_string(&actual).unwrap()
    );
    let expected: Value = serde_json::from_str(r###"[[null, null, null], "FRS"]"###).unwrap();
    for result in actual {
        assert_eq!(result.unwrap(), expected);
    }
}
