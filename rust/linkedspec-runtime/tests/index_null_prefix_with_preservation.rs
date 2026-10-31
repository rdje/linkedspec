//! TYPE-REFERENCE-BOOK.1.2.23.3.72.2 — index leading null index with preservation.
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

#[test]
fn block_null_with() {
    check(
        "block_null_with",
        r#"Value:: I {order="";out={order=cat(order,"S");undef}.index_of({order=cat(order,"O");"a"}).with(){order=cat(order,"W");return(value)};return([out,order])}"#,
        "x",
        serde_json::json!([null, "SOW"]),
    );
}

#[test]
fn literal_null_with() {
    check(
        "literal_null_with",
        r#"Value:: I {order="";out=undef.index_of({order=cat(order,"O");"a"}).with(){order=cat(order,"W");return(value)};return([out,order])}"#,
        "x",
        serde_json::json!([null, "OW"]),
    );
}
