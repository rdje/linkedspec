//! TYPE-REFERENCE-BOOK.1.2.23.3.73.6.2 — Count Array-only source fallback.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse Count sources");
    validate(&parsed).expect("validate Count sources");
    let compiled = compile(&parsed).expect("compile Count sources");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Value" => "Value",
                other => panic!("unexpected Count fixture label {other}"),
            },
            family: classify_generated_rule_family(rule).contract_name(),
        })
        .collect();
    vec![
        Engine::new(compiled)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|error| error.to_string()),
        Engine::new(restored)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|error| error.to_string()),
        execute_generated_parser_v2(
            &serialized,
            &plan,
            input,
            "count-result-guard-composition.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ]
}

fn check_case(label: &str) {
    let cases: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/count_source_fallback_cases.json"
    ))
    .unwrap();
    let row = cases.iter().find(|row| row["id"] == label).unwrap();
    let actual = routes(
        row["source"].as_str().unwrap(),
        row["input"].as_str().unwrap(),
    );
    eprintln!(
        "COUNT_SOURCE_NORMAL {label} {}",
        serde_json::to_string(&actual).unwrap()
    );
    for (route, result) in actual.into_iter().enumerate() {
        if let Some(error) = row["expected_error"].as_str() {
            let actual_error = result.expect_err("required source error propagates");
            assert!(
                actual_error.contains(error),
                "{label} route{route}: {actual_error}"
            );
        } else {
            assert_eq!(
                result.expect("execute Count source"),
                row["expected"],
                "{label} route{route}"
            );
        }
    }
}

macro_rules! count_cases {
    ($($name:ident),+ $(,)?) => {$(
        #[test]
        fn $name() {
            check_case(stringify!($name));
        }
    )+};
}

count_cases! {
    free_source_domains,
    receiver_source_domains,
    free_copied_domains,
    copied_receiver_domains,
    copied_value_kinds,
    count_copy_zero,
    count_copy_with,
    rejection_through_copy,
    legitimate_null_through_copy,
    copied_wrong_source_rejection,
    count_copy_snapshot,
    count_copy_needed_source_error,
    noncreating_missing_source,
    repeated_count_after_copy,
    function_copy_scope,
    receiver_repeated_copy_rejection,
    rejected_copy_without_with,
    valid_null_copy_default,
    function_rejected_copy_scope,
    length_policy_preserved,
}
