//! TYPE-REFERENCE-BOOK.1.2.23.3.79.2 — ordinary Array-pipeline result guards.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse Array-pipeline sources");
    validate(&parsed).expect("validate Array-pipeline sources");
    let compiled = compile(&parsed).expect("compile Array-pipeline sources");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Value" => "Value",
                other => panic!("unexpected Array-pipeline fixture label {other}"),
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
            "array-pipeline-result-assessment.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ]
}

fn check_case(label: &str) {
    let mut cases: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/array_pipeline_result_guard_cases.json"
    ))
    .unwrap();
    let profiles: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/array_pipeline_result_guard_rust_profiles.json"
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
        "ARRAY_PIPELINE_RUST_NORMAL {label} {}",
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

macro_rules! array_pipeline_cases {
    ($($name:ident),+ $(,)?) => {$(
        #[test]
        fn $name() { check_case(stringify!($name)); }
    )+};
}
array_pipeline_cases! {
    split_each_compatible,
    split_each_free_hash_guard,
    split_each_receiver_hash_guard,
    trim_each_compatible,
    trim_each_free_hash_guard,
    trim_each_receiver_hash_guard,
    filter_nonempty_compatible,
    filter_nonempty_free_hash_guard,
    filter_nonempty_receiver_hash_guard,
    lowercase_each_compatible,
    lowercase_each_free_hash_guard,
    lowercase_each_receiver_hash_guard,
    uppercase_each_compatible,
    uppercase_each_free_hash_guard,
    uppercase_each_receiver_hash_guard,
    uniq_compatible,
    uniq_free_hash_guard,
    uniq_receiver_hash_guard,
    filter_match_compatible,
    filter_match_free_hash_guard,
    filter_match_receiver_hash_guard,
    trim_later_with,
    uniq_copy_later_with,
    lower_logical_later_with,
    selected_string_bridge,
    selected_numeric_kind,
    source_once,
    source_snapshot,
    valid_empty_with,
    needed_source_error_terminal,
    needed_source_error_composed,
    needed_delimiter_error_terminal,
    needed_delimiter_error_composed,
    constructor_array_guard,
    value_source_preserved,
    standalone_writeback,
    initial_number_split_each_free,
    initial_number_split_each_free_with,
    initial_number_split_each_receiver,
    initial_number_split_each_receiver_with,
    initial_null_split_each_free,
    initial_null_split_each_free_with,
    initial_null_split_each_receiver,
    initial_null_split_each_receiver_with,
    initial_hash_split_each_free,
    initial_hash_split_each_free_with,
    initial_hash_split_each_receiver,
    initial_hash_split_each_receiver_with,
    extra_split_each_free,
    needed_source_split_each_free,
    extra_split_each_receiver,
    needed_source_split_each_receiver,
    missing_split_each_free,
    initial_number_trim_each_free,
    initial_number_trim_each_free_with,
    initial_number_trim_each_receiver,
    initial_number_trim_each_receiver_with,
    initial_null_trim_each_free,
    initial_null_trim_each_free_with,
    initial_null_trim_each_receiver,
    initial_null_trim_each_receiver_with,
    initial_hash_trim_each_free,
    initial_hash_trim_each_free_with,
    initial_hash_trim_each_receiver,
    initial_hash_trim_each_receiver_with,
    extra_trim_each_free,
    needed_source_trim_each_free,
    extra_trim_each_receiver,
    needed_source_trim_each_receiver,
    missing_trim_each_free,
    initial_number_filter_nonempty_free,
    initial_number_filter_nonempty_free_with,
    initial_number_filter_nonempty_receiver,
    initial_number_filter_nonempty_receiver_with,
    initial_null_filter_nonempty_free,
    initial_null_filter_nonempty_free_with,
    initial_null_filter_nonempty_receiver,
    initial_null_filter_nonempty_receiver_with,
    initial_hash_filter_nonempty_free,
    initial_hash_filter_nonempty_free_with,
    initial_hash_filter_nonempty_receiver,
    initial_hash_filter_nonempty_receiver_with,
    extra_filter_nonempty_free,
    needed_source_filter_nonempty_free,
    extra_filter_nonempty_receiver,
    needed_source_filter_nonempty_receiver,
    missing_filter_nonempty_free,
    initial_number_lowercase_each_free,
    initial_number_lowercase_each_free_with,
    initial_number_lowercase_each_receiver,
    initial_number_lowercase_each_receiver_with,
    initial_null_lowercase_each_free,
    initial_null_lowercase_each_free_with,
    initial_null_lowercase_each_receiver,
    initial_null_lowercase_each_receiver_with,
    initial_hash_lowercase_each_free,
    initial_hash_lowercase_each_free_with,
    initial_hash_lowercase_each_receiver,
    initial_hash_lowercase_each_receiver_with,
    extra_lowercase_each_free,
    needed_source_lowercase_each_free,
    extra_lowercase_each_receiver,
    needed_source_lowercase_each_receiver,
    missing_lowercase_each_free,
    initial_number_uppercase_each_free,
    initial_number_uppercase_each_free_with,
    initial_number_uppercase_each_receiver,
    initial_number_uppercase_each_receiver_with,
    initial_null_uppercase_each_free,
    initial_null_uppercase_each_free_with,
    initial_null_uppercase_each_receiver,
    initial_null_uppercase_each_receiver_with,
    initial_hash_uppercase_each_free,
    initial_hash_uppercase_each_free_with,
    initial_hash_uppercase_each_receiver,
    initial_hash_uppercase_each_receiver_with,
    extra_uppercase_each_free,
    needed_source_uppercase_each_free,
    extra_uppercase_each_receiver,
    needed_source_uppercase_each_receiver,
    missing_uppercase_each_free,
    initial_number_uniq_free,
    initial_number_uniq_free_with,
    initial_number_uniq_receiver,
    initial_number_uniq_receiver_with,
    initial_null_uniq_free,
    initial_null_uniq_free_with,
    initial_null_uniq_receiver,
    initial_null_uniq_receiver_with,
    initial_hash_uniq_free,
    initial_hash_uniq_free_with,
    initial_hash_uniq_receiver,
    initial_hash_uniq_receiver_with,
    extra_uniq_free,
    needed_source_uniq_free,
    extra_uniq_receiver,
    needed_source_uniq_receiver,
    missing_uniq_free,
    initial_number_filter_match_free,
    initial_number_filter_match_free_with,
    initial_number_filter_match_receiver,
    initial_number_filter_match_receiver_with,
    initial_null_filter_match_free,
    initial_null_filter_match_free_with,
    initial_null_filter_match_receiver,
    initial_null_filter_match_receiver_with,
    initial_hash_filter_match_free,
    initial_hash_filter_match_free_with,
    initial_hash_filter_match_receiver,
    initial_hash_filter_match_receiver_with,
    extra_filter_match_free,
    needed_source_filter_match_free,
    extra_filter_match_receiver,
    needed_source_filter_match_receiver,
    missing_filter_match_free,
    missing_operand_split_each_free,
    missing_operand_split_each_receiver,
    missing_operand_filter_match_free,
    missing_operand_filter_match_receiver,
    prior_count,
    prior_key_count,
    prior_length,
    prior_hash,
    prior_copy,
    prior_view,
    needed_delimiter_free,
    invalid_range_free_terminal,
    invalid_range_free_composed,
    needed_delimiter_receiver,
    invalid_range_receiver_terminal,
    invalid_range_receiver_composed,
    nested_scalar_kinds,
    numeric_array_source,
}
