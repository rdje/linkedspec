//! TYPE-REFERENCE-BOOK.1.2.23.3.77.2 — ordinary Hash-valued helper result guards.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse Hash-valued helper sources");
    validate(&parsed).expect("validate Hash-valued helper sources");
    let compiled = compile(&parsed).expect("compile Hash-valued helper sources");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Value" => "Value",
                other => panic!("unexpected Hash-valued helper fixture label {other}"),
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
            "hash-value-result-assessment.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ]
}

fn check_case(label: &str) {
    let mut cases: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/hash_value_result_guard_cases.json"
    ))
    .unwrap();
    let profiles: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/hash_value_result_guard_rust_profiles.json"
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
        "HASH_VALUE_RUST_NORMAL {label} {}",
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

macro_rules! hash_value_cases {
    ($($name:ident),+ $(,)?) => {$(
        #[test]
        fn $name() { check_case(stringify!($name)); }
    )+};
}
hash_value_cases! {
    merge_hash_compatible,
    merge_hash_free_array_guard,
    merge_hash_receiver_array_guard,
    set_key_compatible,
    set_key_free_array_guard,
    set_key_receiver_array_guard,
    rename_key_compatible,
    rename_key_free_array_guard,
    rename_key_receiver_array_guard,
    drop_keys_compatible,
    drop_keys_free_array_guard,
    drop_keys_receiver_array_guard,
    pick_keys_compatible,
    pick_keys_free_array_guard,
    pick_keys_receiver_array_guard,
    merge_later_with,
    set_copy_later_with,
    rename_logical_later_with,
    explicit_bridges,
    nested_kinds_and_source,
    variadic_key_preservation,
    source_once_snapshot,
    empty_pick_with,
    needed_source_error_terminal,
    needed_source_error_composed,
    needed_value_error_terminal,
    needed_value_error_composed,
    constructor_hash_guard,
    initial_number_merge_hash_free,
    initial_number_merge_hash_receiver,
    initial_number_merge_hash_with,
    initial_null_merge_hash_free,
    initial_null_merge_hash_receiver,
    initial_null_merge_hash_with,
    initial_array_merge_hash_free,
    initial_array_merge_hash_receiver,
    initial_array_merge_hash_with,
    initial_number_set_key_free,
    initial_number_set_key_receiver,
    initial_number_set_key_with,
    initial_null_set_key_free,
    initial_null_set_key_receiver,
    initial_null_set_key_with,
    initial_array_set_key_free,
    initial_array_set_key_receiver,
    initial_array_set_key_with,
    initial_number_rename_key_free,
    initial_number_rename_key_receiver,
    initial_number_rename_key_with,
    initial_null_rename_key_free,
    initial_null_rename_key_receiver,
    initial_null_rename_key_with,
    initial_array_rename_key_free,
    initial_array_rename_key_receiver,
    initial_array_rename_key_with,
    initial_number_drop_keys_free,
    initial_number_drop_keys_receiver,
    initial_number_drop_keys_with,
    initial_null_drop_keys_free,
    initial_null_drop_keys_receiver,
    initial_null_drop_keys_with,
    initial_array_drop_keys_free,
    initial_array_drop_keys_receiver,
    initial_array_drop_keys_with,
    initial_number_pick_keys_free,
    initial_number_pick_keys_receiver,
    initial_number_pick_keys_with,
    initial_null_pick_keys_free,
    initial_null_pick_keys_receiver,
    initial_null_pick_keys_with,
    initial_array_pick_keys_free,
    initial_array_pick_keys_receiver,
    initial_array_pick_keys_with,
    extra_merge_hash_free,
    extra_merge_hash_receiver,
    extra_set_key_free,
    extra_set_key_receiver,
    extra_rename_key_free,
    extra_rename_key_receiver,
    drop_keys_free_zero_keys,
    drop_keys_receiver_zero_keys,
    pick_keys_free_zero_keys,
    pick_keys_receiver_zero_keys,
    prior_count,
    prior_key_count,
    prior_length,
    prior_view,
    prior_copy,
    prior_array,
}
