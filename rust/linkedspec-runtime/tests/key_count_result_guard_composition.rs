//! TYPE-REFERENCE-BOOK.1.2.23.3.75.2 — ordinary CountKeys result/source-owner guards.
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
            "key-count-result-guard-composition.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ]
}

fn check_case(label: &str) {
    let mut cases: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/key_count_result_guard_cases.json"
    ))
    .unwrap();
    let ownership: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/key_count_count_source_ownership_cases.json"
    ))
    .unwrap();
    cases.extend(ownership);
    let row = cases.iter().find(|row| row["id"] == label).unwrap();
    let actual = routes(
        row["source"].as_str().unwrap(),
        row["input"].as_str().unwrap(),
    );
    eprintln!(
        "KEY_COUNT_GUARD_ACTUAL {label} {}",
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
            let expected = if label == "source_domain" {
                let domain: Value = serde_json::from_str(include_str!(
                    "../../../tests/fixtures/key_count_result_guard_rust_domain.json"
                ))
                .unwrap();
                assert_eq!(domain["id"], row["id"]);
                assert_eq!(domain["source"], row["source"]);
                domain["expected"].clone()
            } else {
                row["expected"].clone()
            };
            assert_eq!(
                result.expect("execute CountKeys source"),
                expected,
                "{label} route{route}"
            );
        }
    }
}

macro_rules! key_count_cases {
    ($($name:ident),+ $(,)?) => {$(
        #[test]
        fn $name() {
            check_case(stringify!($name));
        }
    )+};
}

key_count_cases! {
    key_count_compatible,
    key_count_free_guard,
    key_count_receiver_guard,
    zero_with,
    explicit_bridges,
    source_once_snapshot,
    function_guard,
    needed_source_error,
    malformed_receiver,
    copy_guard,
    logical_guard,
    logical_valid_zero,
    seeded_hash,
    count_contrast,
    compatible_prefix_guard,
    source_domain,
    free_keys_count,
    receiver_keys_count,
    keys_count_with,
    keys_count_copy_logical,
    produced_zero_keys,
    initial_source_fallback,
    count_to_keys,
    count_to_keys_effects,
    initial_keys_controls,
}
