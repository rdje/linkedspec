//! TYPE-REFERENCE-BOOK.1.2.23.3.78.2 — ordinary Array-transform result guards.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse Array-transform sources");
    validate(&parsed).expect("validate Array-transform sources");
    let compiled = compile(&parsed).expect("compile Array-transform sources");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Value" => "Value",
                other => panic!("unexpected Array-transform fixture label {other}"),
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
            "array-transform-result-assessment.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ]
}

fn check_case(label: &str) {
    let mut cases: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/array_transform_result_guard_cases.json"
    ))
    .unwrap();
    cases.extend(
        serde_json::from_str::<Vec<Value>>(include_str!(
            "../../../tests/fixtures/array_transform_optional_result_guard_cases.json"
        ))
        .unwrap(),
    );
    let profiles: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/array_transform_result_guard_rust_profiles.json"
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
        "ARRAY_TRANSFORM_RUST_NORMAL {label} {}",
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

macro_rules! array_transform_cases {
    ($($name:ident),+ $(,)?) => {$(
        #[test]
        fn $name() { check_case(stringify!($name)); }
    )+};
}
array_transform_cases! {
    take_compatible,
    take_free_hash_guard,
    take_receiver_hash_guard,
    take_last_compatible,
    take_last_free_hash_guard,
    take_last_receiver_hash_guard,
    drop_front_compatible,
    drop_front_free_hash_guard,
    drop_front_receiver_hash_guard,
    drop_back_compatible,
    drop_back_free_hash_guard,
    drop_back_receiver_hash_guard,
    slice_compatible,
    slice_free_hash_guard,
    slice_receiver_hash_guard,
    sorted_compatible,
    sorted_free_hash_guard,
    sorted_receiver_hash_guard,
    reversed_compatible,
    reversed_free_hash_guard,
    reversed_receiver_hash_guard,
    concat_arrays_compatible,
    concat_arrays_free_hash_guard,
    concat_arrays_receiver_hash_guard,
    take_later_with,
    reverse_copy_later_with,
    sort_logical_later_with,
    explicit_selected_bridges,
    nested_kinds_and_source,
    source_once,
    source_snapshot,
    valid_empty_with,
    needed_source_error_terminal,
    needed_source_error_composed,
    needed_count_error_terminal,
    needed_count_error_composed,
    constructor_array_guard,
    optional_take_free_guard,
    optional_take_receiver_guard,
    optional_take_last_free_guard,
    optional_take_last_receiver_guard,
    optional_drop_front_free_guard,
    optional_drop_front_receiver_guard,
    optional_drop_back_free_guard,
    optional_drop_back_receiver_guard,
    optional_slice_free_guard,
    optional_slice_receiver_guard,
    initial_number_take_free,
    initial_number_take_free_with,
    initial_number_take_receiver,
    initial_number_take_receiver_with,
    initial_null_take_free,
    initial_null_take_free_with,
    initial_null_take_receiver,
    initial_null_take_receiver_with,
    initial_hash_take_free,
    initial_hash_take_free_with,
    initial_hash_take_receiver,
    initial_hash_take_receiver_with,
    extra_take_free,
    extra_take_receiver,
    missing_take_free,
    initial_number_take_last_free,
    initial_number_take_last_free_with,
    initial_number_take_last_receiver,
    initial_number_take_last_receiver_with,
    initial_null_take_last_free,
    initial_null_take_last_free_with,
    initial_null_take_last_receiver,
    initial_null_take_last_receiver_with,
    initial_hash_take_last_free,
    initial_hash_take_last_free_with,
    initial_hash_take_last_receiver,
    initial_hash_take_last_receiver_with,
    extra_take_last_free,
    extra_take_last_receiver,
    missing_take_last_free,
    initial_number_drop_front_free,
    initial_number_drop_front_free_with,
    initial_number_drop_front_receiver,
    initial_number_drop_front_receiver_with,
    initial_null_drop_front_free,
    initial_null_drop_front_free_with,
    initial_null_drop_front_receiver,
    initial_null_drop_front_receiver_with,
    initial_hash_drop_front_free,
    initial_hash_drop_front_free_with,
    initial_hash_drop_front_receiver,
    initial_hash_drop_front_receiver_with,
    extra_drop_front_free,
    extra_drop_front_receiver,
    missing_drop_front_free,
    initial_number_drop_back_free,
    initial_number_drop_back_free_with,
    initial_number_drop_back_receiver,
    initial_number_drop_back_receiver_with,
    initial_null_drop_back_free,
    initial_null_drop_back_free_with,
    initial_null_drop_back_receiver,
    initial_null_drop_back_receiver_with,
    initial_hash_drop_back_free,
    initial_hash_drop_back_free_with,
    initial_hash_drop_back_receiver,
    initial_hash_drop_back_receiver_with,
    extra_drop_back_free,
    extra_drop_back_receiver,
    missing_drop_back_free,
    initial_number_slice_free,
    initial_number_slice_free_with,
    initial_number_slice_receiver,
    initial_number_slice_receiver_with,
    initial_null_slice_free,
    initial_null_slice_free_with,
    initial_null_slice_receiver,
    initial_null_slice_receiver_with,
    initial_hash_slice_free,
    initial_hash_slice_free_with,
    initial_hash_slice_receiver,
    initial_hash_slice_receiver_with,
    extra_slice_free,
    extra_slice_receiver,
    missing_slice_free,
    initial_number_sorted_free,
    initial_number_sorted_free_with,
    initial_number_sorted_receiver,
    initial_number_sorted_receiver_with,
    initial_null_sorted_free,
    initial_null_sorted_free_with,
    initial_null_sorted_receiver,
    initial_null_sorted_receiver_with,
    initial_hash_sorted_free,
    initial_hash_sorted_free_with,
    initial_hash_sorted_receiver,
    initial_hash_sorted_receiver_with,
    extra_sorted_free,
    extra_sorted_receiver,
    missing_sorted_free,
    initial_number_reversed_free,
    initial_number_reversed_free_with,
    initial_number_reversed_receiver,
    initial_number_reversed_receiver_with,
    initial_null_reversed_free,
    initial_null_reversed_free_with,
    initial_null_reversed_receiver,
    initial_null_reversed_receiver_with,
    initial_hash_reversed_free,
    initial_hash_reversed_free_with,
    initial_hash_reversed_receiver,
    initial_hash_reversed_receiver_with,
    extra_reversed_free,
    extra_reversed_receiver,
    missing_reversed_free,
    initial_number_concat_arrays_free,
    initial_number_concat_arrays_free_with,
    initial_number_concat_arrays_receiver,
    initial_number_concat_arrays_receiver_with,
    initial_null_concat_arrays_free,
    initial_null_concat_arrays_free_with,
    initial_null_concat_arrays_receiver,
    initial_null_concat_arrays_receiver_with,
    initial_hash_concat_arrays_free,
    initial_hash_concat_arrays_free_with,
    initial_hash_concat_arrays_receiver,
    initial_hash_concat_arrays_receiver_with,
    extra_concat_arrays_free,
    extra_concat_arrays_receiver,
    missing_concat_arrays_free,
    missing_slice_receiver,
    missing_concat_arrays_receiver,
    optional_take_free,
    optional_take_free_with,
    optional_take_receiver,
    optional_take_receiver_with,
    optional_take_last_free,
    optional_take_last_free_with,
    optional_take_last_receiver,
    optional_take_last_receiver_with,
    optional_drop_front_free,
    optional_drop_front_free_with,
    optional_drop_front_receiver,
    optional_drop_front_receiver_with,
    optional_drop_back_free,
    optional_drop_back_free_with,
    optional_drop_back_receiver,
    optional_drop_back_receiver_with,
    optional_slice_free,
    optional_slice_free_with,
    optional_slice_receiver,
    optional_slice_receiver_with,
    prior_count,
    prior_key_count,
    prior_length,
    prior_hash,
    prior_copy,
    prior_view,
}
