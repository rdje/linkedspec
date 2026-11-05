//! TYPE-REFERENCE-BOOK.1.2.23.3.73.2 — Count source/prefix guards.
use linkedspec_core::{
    compiler::compile, expr::CodeBlock, types::CompiledSpec, validation::validate,
};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

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
    let mut cases: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/count_result_guard_cases.json"
    ))
    .unwrap();
    let source_owners: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/count_result_guard_source_owner_cases.json"
    ))
    .unwrap();
    cases.extend(source_owners);
    let row = cases.iter().find(|row| row["id"] == label).unwrap();
    let actual = routes(
        row["source"].as_str().unwrap(),
        row["input"].as_str().unwrap(),
    );
    eprintln!(
        "COUNT_GUARD_ACTUAL {label} {}",
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
    primitive_counts,
    free_container_guards,
    receiver_container_guards,
    free_guard_before_with,
    receiver_guard_before_with,
    free_bridge_rejection,
    receiver_bridge_rejection,
    compatible_values,
    source_consumer_snapshot,
    valid_zero_with,
    valid_null_with,
    valid_empty_with,
    with_result_array,
    needed_source_error,
    function_scope,
    valid_array_bridges,
    count_results_keep_prior_kind_guard,
}

#[test]
fn source_domain_diagnostic() {
    let actual = routes(
        "Value:: I {return([count(undef),count(\"text\"),count({}),{undef}.count(),\"text\".count(),{}.count(),{undef}.copy().count()])}",
        "x",
    );
    eprintln!(
        "COUNT_GUARD_DOMAIN {}",
        serde_json::to_string(&actual).unwrap()
    );
    // Freeze the independently observed Rust source-domain behavior before any
    // production edit. Copy/source-domain policy remains separately owned by73.6.
    let frozen: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/count_result_guard_rust_domain.json"
    ))
    .unwrap();
    for result in actual {
        assert_eq!(result.unwrap(), frozen);
    }
}

#[test]
fn excluded_source_shapes_stay_current() {
    let rows: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/count_result_guard_excluded_ast.json"
    ))
    .unwrap();
    let actual: Vec<_> = rows
        .iter()
        .map(|row| {
            let source = row["source"].as_str().unwrap();
            json!({"source": source, "ast": CodeBlock::parse(source)})
        })
        .collect();
    eprintln!(
        "COUNT_GUARD_SHAPES {}",
        serde_json::to_string(&actual).unwrap()
    );
    let frozen: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/count_result_guard_rust_ast.json"
    ))
    .unwrap();
    assert_eq!(
        json!(actual),
        frozen,
        "excluded source ASTs stay at the pre-edit Rust boundary"
    );
}
