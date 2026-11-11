//! TYPE-REFERENCE-BOOK.1.2.23.3.78.6.2 — callable Array-transform result guards.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

fn routes(label: &str, source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse Array-transform sources");
    if let Ok(folder) = std::env::var("LINKEDSPEC_CALLABLE_TRANSFORM_RUST_CAPTURE") {
        let path = std::path::Path::new(&folder);
        assert!(folder.starts_with("docs/checkpoints/array-transform-callable-rust-2026-11-11/"));
        assert!(
            path.components()
                .all(|part| matches!(part, std::path::Component::Normal(_)))
        );
        let inputs = path.join("normal-parsed");
        std::fs::create_dir_all(&inputs).unwrap();
        let target = inputs.join(format!("{label}.json"));
        assert!(!target.exists(), "parsed snapshots are one-shot");
        let body = serde_json::to_string(&parsed).unwrap();
        std::fs::write(&target, &body).unwrap();
        assert_eq!(std::fs::read_to_string(target).unwrap(), body);
        eprintln!(
            "CALLABLE_TRANSFORM_RUST_NORMAL_PARSED_INPUT {label} {}",
            serde_json::json!({"parsed": body})
        );
    }
    validate(&parsed).expect("validate Array-transform sources");
    let compiled = compile(&parsed).expect("compile Array-transform sources");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let retained = if let Ok(folder) = std::env::var("LINKEDSPEC_CALLABLE_TRANSFORM_RUST_CAPTURE") {
        let path = std::path::Path::new(&folder);
        assert!(folder.starts_with("docs/checkpoints/array-transform-callable-rust-2026-11-11/"));
        assert!(
            path.components()
                .all(|part| matches!(part, std::path::Component::Normal(_)))
        );
        let inputs = path.join("normal-inputs");
        std::fs::create_dir_all(&inputs).unwrap();
        let target = inputs.join(format!("{label}.json"));
        assert!(!target.exists(), "capture inputs are one-shot");
        std::fs::write(&target, &serialized).unwrap();
        let retained = std::fs::read_to_string(target).unwrap();
        assert_eq!(retained.as_bytes(), serialized.as_bytes());
        eprintln!(
            "CALLABLE_TRANSFORM_RUST_NORMAL_INPUT {label} {}",
            serde_json::json!({"compiled": &retained})
        );
        retained
    } else {
        serialized.clone()
    };
    let restored: CompiledSpec = serde_json::from_str(&retained).unwrap();
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
            &retained,
            &plan,
            input,
            "array-transform-callable-result-assessment.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ]
}

fn check_case(label: &str) {
    let cases: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/array_transform_callable_rust_cases.json"
    ))
    .unwrap();
    let profiles: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/array_transform_callable_result_guard_rust_profiles.json"
    ))
    .unwrap();
    let case = cases.iter().find(|case| case["id"] == label).unwrap();
    let profile = &profiles[label];
    assert_eq!(&profile["case"], case, "cold source identity");
    let results = routes(
        label,
        case["source"].as_str().unwrap(),
        case["input"].as_str().unwrap(),
    );
    let mut observed = serde_json::Map::new();
    for (name, result) in ["native", "restored", "plan"].into_iter().zip(results) {
        let actual = match result {
            Ok(value) => serde_json::json!({"value": value}),
            Err(error) => serde_json::json!({"error": error}),
        };
        observed.insert(name.into(), actual);
    }
    eprintln!(
        "CALLABLE_TRANSFORM_RUST_NORMAL {label} {}",
        Value::Object(observed.clone())
    );
    for (name, actual) in observed {
        assert_eq!(
            actual, profile[&name],
            "{label} {name}: independent Rust policy/guard result"
        );
    }
}

macro_rules! callable_transform_cases {
    ($($name:ident,)*) => { $(#[test] fn $name() { check_case(stringify!($name)); })* };
}
callable_transform_cases! {
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
    drop_logical_later_with,
    source_once,
    source_snapshot,
    valid_empty_with,
    nested_kinds,
    selected_hash_bridge,
    needed_source_terminal,
    needed_source_composed,
    needed_count_terminal,
    needed_count_composed,
    constructor_rejection_oracle,
    initial_number_terminal,
    initial_number_composed,
    initial_null_terminal,
    initial_null_composed,
    initial_hash_terminal,
    initial_hash_composed,
    source_effect_before_rejection,
    established_constructor_guard,
    own_initial_number_take_free,
    own_initial_number_take_free_with,
    own_initial_number_take_receiver,
    own_initial_number_take_receiver_with,
    own_initial_null_take_free,
    own_initial_null_take_free_with,
    own_initial_null_take_receiver,
    own_initial_null_take_receiver_with,
    own_initial_hash_take_free,
    own_initial_hash_take_free_with,
    own_initial_hash_take_receiver,
    own_initial_hash_take_receiver_with,
    own_extra_take_free,
    own_needed_source_take_free,
    own_extra_take_receiver,
    own_needed_source_take_receiver,
    own_initial_number_take_last_free,
    own_initial_number_take_last_free_with,
    own_initial_number_take_last_receiver,
    own_initial_number_take_last_receiver_with,
    own_initial_null_take_last_free,
    own_initial_null_take_last_free_with,
    own_initial_null_take_last_receiver,
    own_initial_null_take_last_receiver_with,
    own_initial_hash_take_last_free,
    own_initial_hash_take_last_free_with,
    own_initial_hash_take_last_receiver,
    own_initial_hash_take_last_receiver_with,
    own_extra_take_last_free,
    own_needed_source_take_last_free,
    own_extra_take_last_receiver,
    own_needed_source_take_last_receiver,
    own_initial_number_drop_front_free,
    own_initial_number_drop_front_free_with,
    own_initial_number_drop_front_receiver,
    own_initial_number_drop_front_receiver_with,
    own_initial_null_drop_front_free,
    own_initial_null_drop_front_free_with,
    own_initial_null_drop_front_receiver,
    own_initial_null_drop_front_receiver_with,
    own_initial_hash_drop_front_free,
    own_initial_hash_drop_front_free_with,
    own_initial_hash_drop_front_receiver,
    own_initial_hash_drop_front_receiver_with,
    own_extra_drop_front_free,
    own_needed_source_drop_front_free,
    own_extra_drop_front_receiver,
    own_needed_source_drop_front_receiver,
    own_initial_number_drop_back_free,
    own_initial_number_drop_back_free_with,
    own_initial_number_drop_back_receiver,
    own_initial_number_drop_back_receiver_with,
    own_initial_null_drop_back_free,
    own_initial_null_drop_back_free_with,
    own_initial_null_drop_back_receiver,
    own_initial_null_drop_back_receiver_with,
    own_initial_hash_drop_back_free,
    own_initial_hash_drop_back_free_with,
    own_initial_hash_drop_back_receiver,
    own_initial_hash_drop_back_receiver_with,
    own_extra_drop_back_free,
    own_needed_source_drop_back_free,
    own_extra_drop_back_receiver,
    own_needed_source_drop_back_receiver,
    own_initial_number_slice_free,
    own_initial_number_slice_free_with,
    own_initial_number_slice_receiver,
    own_initial_number_slice_receiver_with,
    own_initial_null_slice_free,
    own_initial_null_slice_free_with,
    own_initial_null_slice_receiver,
    own_initial_null_slice_receiver_with,
    own_initial_hash_slice_free,
    own_initial_hash_slice_free_with,
    own_initial_hash_slice_receiver,
    own_initial_hash_slice_receiver_with,
    own_extra_slice_free,
    own_needed_source_slice_free,
    own_extra_slice_receiver,
    own_needed_source_slice_receiver,
    own_initial_number_sorted_free,
    own_initial_number_sorted_free_with,
    own_initial_number_sorted_receiver,
    own_initial_number_sorted_receiver_with,
    own_initial_null_sorted_free,
    own_initial_null_sorted_free_with,
    own_initial_null_sorted_receiver,
    own_initial_null_sorted_receiver_with,
    own_initial_hash_sorted_free,
    own_initial_hash_sorted_free_with,
    own_initial_hash_sorted_receiver,
    own_initial_hash_sorted_receiver_with,
    own_extra_sorted_free,
    own_needed_source_sorted_free,
    own_extra_sorted_receiver,
    own_needed_source_sorted_receiver,
    own_initial_number_reversed_free,
    own_initial_number_reversed_free_with,
    own_initial_number_reversed_receiver,
    own_initial_number_reversed_receiver_with,
    own_initial_null_reversed_free,
    own_initial_null_reversed_free_with,
    own_initial_null_reversed_receiver,
    own_initial_null_reversed_receiver_with,
    own_initial_hash_reversed_free,
    own_initial_hash_reversed_free_with,
    own_initial_hash_reversed_receiver,
    own_initial_hash_reversed_receiver_with,
    own_extra_reversed_free,
    own_needed_source_reversed_free,
    own_extra_reversed_receiver,
    own_needed_source_reversed_receiver,
    own_initial_number_concat_arrays_free,
    own_initial_number_concat_arrays_free_with,
    own_initial_number_concat_arrays_receiver,
    own_initial_number_concat_arrays_receiver_with,
    own_initial_null_concat_arrays_free,
    own_initial_null_concat_arrays_free_with,
    own_initial_null_concat_arrays_receiver,
    own_initial_null_concat_arrays_receiver_with,
    own_initial_hash_concat_arrays_free,
    own_initial_hash_concat_arrays_free_with,
    own_initial_hash_concat_arrays_receiver,
    own_initial_hash_concat_arrays_receiver_with,
    own_extra_concat_arrays_free,
    own_needed_source_concat_arrays_free,
    own_extra_concat_arrays_receiver,
    own_needed_source_concat_arrays_receiver,
    own_missing_slice_free,
    own_missing_slice_receiver,
    own_missing_concat_arrays_free,
    own_missing_concat_arrays_receiver,
    own_prior_count,
    own_prior_key_count,
    own_prior_length,
    own_prior_hash,
    own_prior_copy,
    own_prior_view,
    own_optional_take_free,
    own_optional_take_free_composed,
    own_optional_take_receiver,
    own_optional_take_receiver_composed,
    own_optional_take_last_free,
    own_optional_take_last_free_composed,
    own_optional_take_last_receiver,
    own_optional_take_last_receiver_composed,
    own_optional_drop_front_free,
    own_optional_drop_front_free_composed,
    own_optional_drop_front_receiver,
    own_optional_drop_front_receiver_composed,
    own_optional_drop_back_free,
    own_optional_drop_back_free_composed,
    own_optional_drop_back_receiver,
    own_optional_drop_back_receiver_composed,
    own_optional_slice_free,
    own_optional_slice_free_composed,
    own_optional_slice_receiver,
    own_optional_slice_receiver_composed,
    own_function_arity_missing_terminal,
    own_function_arity_missing_composed,
    own_function_arity_extra_terminal,
    own_function_arity_extra_composed,
    own_signature_variadic_empty_terminal,
    own_signature_variadic_empty_composed,
    own_signature_variadic_multi_terminal,
    own_signature_variadic_multi_composed,
    own_signature_fixed_missing_terminal,
    own_signature_fixed_missing_composed,
    own_signature_fixed_extra_terminal,
    own_signature_fixed_extra_composed,
    own_signature_variadic_missing_terminal,
    own_signature_variadic_missing_composed,
    own_needed_count_take_free,
    own_needed_count_take_receiver,
    own_needed_count_take_last_free,
    own_needed_count_take_last_receiver,
    own_needed_count_drop_front_free,
    own_needed_count_drop_front_receiver,
    own_needed_count_drop_back_free,
    own_needed_count_drop_back_receiver,
    own_needed_start_slice_free,
    own_needed_count_slice_free,
    own_needed_start_slice_receiver,
    own_needed_count_slice_receiver,
    own_scalar_bool_free,
    own_scalar_bool_free_with,
    own_scalar_bool_receiver,
    own_scalar_bool_receiver_with,
    own_scalar_string_binding_name_free,
    own_scalar_string_binding_name_free_with,
    own_scalar_string_binding_name_receiver,
    own_scalar_string_binding_name_receiver_with,
    own_nested_scalar_kinds,
    own_numeric_array_source,
    own_source_before_rejection,
    own_extra_take_free_terminal_probe,
    own_needed_source_take_free_terminal_probe,
    own_extra_take_receiver_terminal_probe,
    own_needed_source_take_receiver_terminal_probe,
    own_extra_take_last_free_terminal_probe,
    own_needed_source_take_last_free_terminal_probe,
    own_extra_take_last_receiver_terminal_probe,
    own_needed_source_take_last_receiver_terminal_probe,
    own_extra_drop_front_free_terminal_probe,
    own_needed_source_drop_front_free_terminal_probe,
    own_extra_drop_front_receiver_terminal_probe,
    own_needed_source_drop_front_receiver_terminal_probe,
    own_extra_drop_back_free_terminal_probe,
    own_needed_source_drop_back_free_terminal_probe,
    own_extra_drop_back_receiver_terminal_probe,
    own_needed_source_drop_back_receiver_terminal_probe,
    own_extra_slice_free_terminal_probe,
    own_needed_source_slice_free_terminal_probe,
    own_extra_slice_receiver_terminal_probe,
    own_needed_source_slice_receiver_terminal_probe,
    own_extra_sorted_free_terminal_probe,
    own_needed_source_sorted_free_terminal_probe,
    own_extra_sorted_receiver_terminal_probe,
    own_needed_source_sorted_receiver_terminal_probe,
    own_extra_reversed_free_terminal_probe,
    own_needed_source_reversed_free_terminal_probe,
    own_extra_reversed_receiver_terminal_probe,
    own_needed_source_reversed_receiver_terminal_probe,
    own_extra_concat_arrays_free_terminal_probe,
    own_needed_source_concat_arrays_free_terminal_probe,
    own_extra_concat_arrays_receiver_terminal_probe,
    own_needed_source_concat_arrays_receiver_terminal_probe,
    own_missing_slice_free_terminal_probe,
    own_missing_slice_receiver_terminal_probe,
    own_missing_concat_arrays_free_terminal_probe,
    own_missing_concat_arrays_receiver_terminal_probe,
    own_needed_count_take_free_terminal_probe,
    own_needed_count_take_receiver_terminal_probe,
    own_needed_count_take_last_free_terminal_probe,
    own_needed_count_take_last_receiver_terminal_probe,
    own_needed_count_drop_front_free_terminal_probe,
    own_needed_count_drop_front_receiver_terminal_probe,
    own_needed_count_drop_back_free_terminal_probe,
    own_needed_count_drop_back_receiver_terminal_probe,
    own_needed_start_slice_free_terminal_probe,
    own_needed_count_slice_free_terminal_probe,
    own_needed_start_slice_receiver_terminal_probe,
    own_needed_count_slice_receiver_terminal_probe,
    positive_take_free_terminal,
    positive_take_receiver_terminal,
    positive_take_receiver_composed,
    positive_take_last_free_terminal,
    positive_take_last_receiver_terminal,
    positive_take_last_receiver_composed,
    positive_drop_front_free_terminal,
    positive_drop_front_receiver_terminal,
    positive_drop_front_receiver_composed,
    positive_drop_back_free_terminal,
    positive_drop_back_receiver_terminal,
    positive_drop_back_receiver_composed,
    positive_slice_free_terminal,
    positive_slice_receiver_terminal,
    positive_slice_receiver_composed,
    positive_sorted_free_terminal,
    positive_sorted_receiver_terminal,
    positive_sorted_receiver_composed,
    positive_reversed_free_terminal,
    positive_reversed_receiver_terminal,
    positive_reversed_receiver_composed,
    positive_concat_arrays_free_terminal,
    positive_concat_arrays_receiver_terminal,
    positive_concat_arrays_receiver_composed,
}
