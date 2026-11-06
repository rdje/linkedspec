//! TYPE-REFERENCE-BOOK.1.2.23.3.76.2 — ordinary Hash-view result guards.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse Hash-view sources");
    validate(&parsed).expect("validate Hash-view sources");
    let compiled = compile(&parsed).expect("compile Hash-view sources");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Value" => "Value",
                other => panic!("unexpected Hash-view fixture label {other}"),
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
            "hash-view-result-assessment.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ]
}

fn check_case(label: &str) {
    let mut cases: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/hash_view_result_guard_cases.json"
    ))
    .unwrap();
    let profiles: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/hash_view_result_guard_rust_profiles.json"
    ))
    .unwrap();
    for (id, profile) in profiles.as_object().unwrap() {
        if profile["profile_only"].as_bool() == Some(true) {
            cases.push(serde_json::json!({
                "id": id, "source": profile["source"], "input": profile["input"],
            }));
        }
    }
    let row = cases.iter().find(|row| row["id"] == label).unwrap();
    let results = routes(
        row["source"].as_str().unwrap(),
        row["input"].as_str().unwrap(),
    );
    let mut observations = serde_json::Map::new();
    for (name, result) in ["native", "restored", "plan"].into_iter().zip(results) {
        let actual = match result {
            Ok(value) => serde_json::json!({"value": value}),
            Err(error) => serde_json::json!({"error": error}),
        };
        observations.insert(name.into(), actual);
    }
    eprintln!(
        "HASH_VIEW_RUST_NORMAL {label} {}",
        Value::Object(observations.clone())
    );
    for (name, actual) in observations {
        if let Some(profile) = profiles.get(label) {
            assert_eq!(profile["source"], row["source"], "profile/source identity");
            assert_eq!(
                actual, profile[&name],
                "{label} {name}: independent Rust profile"
            );
            if let Some(error) = row["expected_error"].as_str() {
                assert!(
                    actual["error"].as_str().unwrap().contains(error),
                    "required argument error"
                );
            } else if row.get("expected").is_some() {
                assert_eq!(
                    actual["value"], row["expected"],
                    "{label} {name}: authored target"
                );
            }
        } else {
            assert_eq!(
                actual,
                serde_json::json!({"value": row["expected"]}),
                "{label} {name}"
            );
        }
    }
}

macro_rules! hash_view_cases {
    ($($name:ident),+ $(,)?) => {$(
        #[test]
        fn $name() { check_case(stringify!($name)); }
    )+};
}
hash_view_cases! {
    keys_compatible,
    values_compatible,
    free_sorted_keys_hash_guard,
    receiver_sorted_keys_hash_guard,
    free_sorted_values_hash_guard,
    receiver_sorted_values_hash_guard,
    later_with,
    copy_guard,
    logical_guard,
    explicit_bridges,
    nested_kinds,
    source_once_snapshot,
    needed_source_error,
    valid_empty_with,
    constructor_rejected_with,
    arity_profile,
    values_scalar_null_profile,
    keys_null_profile,
    values_array_error_profile,
    free_values_arity_profile,
    receiver_input_profile,
    receiver_null_with_profile,
}
