//! TYPE-REFERENCE-BOOK.1.2.23.3.62.2 — canonical free String result guards.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse free String results");
    validate(&parsed).expect("validate free String results");
    let compiled = compile(&parsed).expect("compile free String results");
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
            "free-string-result-composition.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}

fn check(label: &str, source: &str, input: &str, expected: Value) {
    let actual = routes(source, input);
    eprintln!(
        "FREE_STRING_VALUE {label} {}",
        serde_json::to_string(&actual).unwrap()
    );
    for (route, value) in actual.into_iter().enumerate() {
        assert_eq!(
            value.expect("execute free String result"),
            expected,
            "{label} route{route}"
        );
    }
}

fn check_case(label: &str) {
    let cases: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/free_string_result_cases.json"
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
fn primitive_values() {
    check_case("primitive_values");
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
fn bound_guarded_bridge() {
    check_case("bound_guarded_bridge");
}

#[test]
fn valid_null_with() {
    check_case("valid_null_with");
}

#[test]
fn guard_before_with() {
    check_case("guard_before_with");
}

#[test]
fn source_order_snapshot() {
    check_case("source_order_snapshot");
}

#[test]
fn all_free_guard_sources() {
    check_case("all_free_guard_sources");
}

#[test]
fn function_scope() {
    check_case("function_scope");
}

#[test]
fn free_bridge_rejection() {
    check_case("free_bridge_rejection");
}

#[test]
fn valid_empty_bridge_with() {
    check_case("valid_empty_bridge_with");
}

#[test]
fn valid_null_after_bridge_with() {
    check_case("valid_null_after_bridge_with");
}

#[test]
fn legacy_named_empty_fallback() {
    check_case("legacy_named_empty_fallback");
}

#[test]
fn numeric_identity_remains_an_array_index() {
    check(
        "numeric_identity_remains_an_array_index",
        r#"Value:: I {slots=["old"];index=rm_prefix(0,"x").copy();slots[index]="updated";return([index,slots,rm_suffix(false,"x").copy()])}"#,
        "x",
        serde_json::from_str(r#"[0,["updated"],false]"#).unwrap(),
    );
}

#[test]
fn needed_source_error_precedes_recovery() {
    let actual = routes(
        r#"Value:: I {return(trim({items="text";push(items,"x")}).coalesce("masked"))}"#,
        "x",
    );
    eprintln!(
        "FREE_STRING_ERROR {}",
        serde_json::to_string(&actual).unwrap()
    );
    for route in actual {
        assert!(route.unwrap_err().contains("binding_kind_mismatch"));
    }
}

#[test]
fn receiver_only_context_is_observed_independently() {
    // Perl's unready classification is not a portable expected-value contract.
    let source = r#"Value:: I {order="";out=" a,b ".trim().split(",").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}"#;
    let actual = routes(source, "x");
    eprintln!(
        "FREE_STRING_CONTEXT {}",
        serde_json::to_string(&actual).unwrap()
    );
    assert_eq!(actual.len(), 3);
    for route in &actual[1..] {
        assert_eq!(route, &actual[0]);
    }
}

#[test]
fn excluded_source_shapes_stay_current() {
    use linkedspec_core::expr::CodeBlock;
    let sources: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/free_string_excluded_source_ast.json"
    ))
    .unwrap();
    let shapes: Vec<_> = sources
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
        "FREE_STRING_SHAPES {}",
        serde_json::to_string(&shapes).unwrap()
    );
}
