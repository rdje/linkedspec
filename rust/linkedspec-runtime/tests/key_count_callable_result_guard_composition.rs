//! TYPE-REFERENCE-BOOK.1.2.23.3.75.6.2 — function-result CountKeys preservation.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse CountKeys sources");
    validate(&parsed).expect("validate CountKeys sources");
    let compiled = compile(&parsed).expect("compile CountKeys sources");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Value" => "Value",
                other => panic!("unexpected CountKeys fixture label {other}"),
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
            "key-count-callable-result-composition.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ]
}

fn check_case(label: &str) {
    let cases: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/key_count_callable_result_cases.json"
    ))
    .unwrap();
    let profiles: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/key_count_callable_rust_profiles.json"
    ))
    .unwrap();
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
        "CALLABLE_KEY_COUNT_RUST_NORMAL {label} {}",
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

macro_rules! callable_key_count_cases {
    ($($name:ident),+ $(,)?) => {$(
        #[test]
        fn $name() { check_case(stringify!($name)); }
    )+};
}
callable_key_count_cases! {
    compatible_counts,
    wrong_array,
    wrong_hash,
    later_with,
    copy_guard,
    logical_guard,
    count_consumers,
    valid_zero,
    explicit_bridges,
    source_once_snapshot,
    needed_argument_error,
    boolean_receiver_profile,
    malformed_receiver_profile,
    function_controls,
    parameter_source_control,
    boolean_terminal_profile,
}
