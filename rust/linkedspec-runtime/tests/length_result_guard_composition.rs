//! TYPE-REFERENCE-BOOK.1.2.23.3.74.2 — ordinary Length result/source-owner guards.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse Length sources");
    validate(&parsed).expect("validate Length sources");
    let compiled = compile(&parsed).expect("compile Length sources");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Value" => "Value",
                other => panic!("unexpected Length fixture label {other}"),
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
            "length-result-guard-composition.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ]
}

fn check_case(label: &str) {
    let mut cases: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/length_result_guard_cases.json"
    ))
    .unwrap();
    let source_owners: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/length_count_source_ownership_cases.json"
    ))
    .unwrap();
    cases.extend(source_owners);
    let row = cases.iter().find(|row| row["id"] == label).unwrap();
    let actual = routes(
        row["source"].as_str().unwrap(),
        row["input"].as_str().unwrap(),
    );
    eprintln!(
        "LENGTH_GUARD_ACTUAL {label} {}",
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
            let expected = if row.get("perl_expected").is_some() {
                let domain: Value = serde_json::from_str(include_str!(
                    "../../../tests/fixtures/length_result_guard_rust_domain.json"
                ))
                .unwrap();
                assert_eq!(domain["id"], row["id"]);
                assert_eq!(domain["source"], row["source"]);
                domain["expected"].clone()
            } else {
                row["expected"].clone()
            };
            assert_eq!(
                result.expect("execute Length source"),
                expected,
                "{label} route{route}"
            );
        }
    }
}

macro_rules! length_cases {
    ($($name:ident),+ $(,)?) => {$(
        #[test]
        fn $name() {
            check_case(stringify!($name));
        }
    )+};
}

length_cases! {
    length_compatible,
    length_free_guard,
    length_receiver_guard,
    zero_null_with,
    explicit_bridges,
    source_once_snapshot,
    function_guard,
    needed_source_error,
    malformed_receiver,
    copy_guard,
    logical_guard,
    logical_valid_null_zero,
    seeded_hash,
    count_contrast,
    compatible_prefix_guard,
    scalar_array_sources,
    free_length_count,
    receiver_length_count,
    length_count_with,
    length_count_copy_logical,
    produced_null_zero_count,
    initial_count_policy,
    explicit_array_bridge,
    needed_length_source_error,
}
