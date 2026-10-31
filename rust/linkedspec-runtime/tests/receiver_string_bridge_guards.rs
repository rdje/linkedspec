//! TYPE-REFERENCE-BOOK.1.2.23.3.62.6.2 — canonical receiver String-prefix bridge guards.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse receiver String bridges");
    validate(&parsed).expect("validate receiver String bridges");
    let compiled = compile(&parsed).expect("compile receiver String bridges");
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
            "receiver-string-bridge-guards.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}

fn check(label: &str, source: &str, input: &str, expected: Value) {
    let actual = routes(source, input);
    eprintln!(
        "RECEIVER_BRIDGE_VALUE {label} {}",
        serde_json::to_string(&actual).unwrap()
    );
    for (route, value) in actual.into_iter().enumerate() {
        assert_eq!(
            value.expect("execute receiver String bridge"),
            expected,
            "{label} route{route}"
        );
    }
}

fn check_case(label: &str) {
    let cases: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/receiver_string_bridge_cases.json"
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
fn reject_bridge_with() {
    check_case("reject_bridge_with");
}

#[test]
fn reject_bridge_without_with() {
    check_case("reject_bridge_without_with");
}

#[test]
fn source_once() {
    check_case("source_once");
}

#[test]
fn valid_selected_with() {
    check_case("valid_selected_with");
}

#[test]
fn valid_empty_with() {
    check_case("valid_empty_with");
}

#[test]
fn valid_null_with() {
    check_case("valid_null_with");
}

#[test]
fn all_eight_prefixes() {
    check_case("all_eight_prefixes");
}

#[test]
fn function_scope() {
    check_case("function_scope");
}

#[test]
fn direct_rejection_with() {
    check_case("direct_rejection_with");
}

#[test]
fn primitive_values() {
    check_case("primitive_values");
}

#[test]
fn compatible_values() {
    check_case("compatible_values");
}

#[test]
fn receiver_numeric_identity_remains_an_array_index() {
    check(
        "receiver_numeric_identity_remains_an_array_index",
        r#"Value:: I {slots=["old"];index=0.rm_prefix("x").copy();slots[index]="updated";return([index,slots,false.rm_suffix("x").copy()])}"#,
        "x",
        serde_json::from_str(r#"[0,["updated"],false]"#).unwrap(),
    );
}
#[test]
fn needed_source_error_precedes_recovery() {
    let actual = routes(
        r#"Value:: I {return({items="text";push(items,"x")}.trim().split(",").with(){return("masked")})}"#,
        "x",
    );
    eprintln!(
        "RECEIVER_BRIDGE_ERROR {}",
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
        "../../../tests/fixtures/receiver_string_bridge_excluded_ast.json"
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
    assert_eq!(shapes.len(), 9);
    eprintln!(
        "RECEIVER_BRIDGE_SHAPES {}",
        serde_json::to_string(&shapes).unwrap()
    );
}
