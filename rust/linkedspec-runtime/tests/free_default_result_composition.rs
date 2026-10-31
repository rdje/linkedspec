//! TYPE-REFERENCE-BOOK.1.2.23.3.60.2 — canonical free-default actual-kind result guards.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse free default results");
    validate(&parsed).expect("validate free default results");
    let compiled = compile(&parsed).expect("compile free default results");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Value" => "Value",
                "Child" => "Child",
                other => panic!("unexpected fixture label {other}"),
            },
            family: classify_generated_rule_family(rule).contract_name(),
        })
        .collect();
    vec![
        Engine::new(compiled)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|e| e.to_string()),
        Engine::new(restored)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|e| e.to_string()),
        execute_generated_parser_v2(
            &serialized,
            &plan,
            input,
            "free-default-result-composition.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}

fn check(label: &str, source: &str, input: &str, expected: Value) {
    let actual = routes(source, input);
    eprintln!(
        "FREE_DEFAULT_VALUE {label} {}",
        serde_json::to_string(&actual).unwrap()
    );
    for (route, value) in actual.into_iter().enumerate() {
        assert_eq!(
            value.expect("execute free default result"),
            expected,
            "{label} route{route}"
        );
    }
}

fn check_case(label: &str) {
    let cases: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/free_default_result_cases.json"
    ))
    .unwrap();
    let row = cases
        .as_array()
        .unwrap()
        .iter()
        .find(|row| row["id"] == label)
        .unwrap();
    check(
        label,
        row["source"].as_str().unwrap(),
        row["input"].as_str().unwrap(),
        row["expected"].clone(),
    );
}

#[test]
fn scalar_primitives() {
    check_case("scalar_primitives");
}

#[test]
fn scalar_compatible() {
    check_case("scalar_compatible");
}

#[test]
fn scalar_string_guards() {
    check_case("scalar_string_guards");
}

#[test]
fn scalar_number_bool_guards() {
    check_case("scalar_number_bool_guards");
}

#[test]
fn container_compatible() {
    check_case("container_compatible");
}

#[test]
fn container_guards() {
    check_case("container_guards");
}

#[test]
fn completed_bound_guards() {
    check_case("completed_bound_guards");
}

#[test]
fn selected_guard() {
    check_case("selected_guard");
}

#[test]
fn lazy_order_and_snapshot() {
    check_case("lazy_order_and_snapshot");
}

#[test]
fn skip_unused_failure() {
    check_case("skip_unused_failure");
}

#[test]
fn with_kinds_and_outer_scope() {
    check_case("with_kinds_and_outer_scope");
}

#[test]
fn function_scope() {
    check_case("function_scope");
}

#[test]
fn valid_null_with_runs() {
    check(
        "valid_null_with_runs",
        r#"Value:: I {order="";out=coalesce(undef,undef).with(){order=cat(order,"W");return("recovered")};return([out,order])}"#,
        "x",
        serde_json::from_str(r#"["recovered","W"]"#).unwrap(),
    );
}

#[test]
fn valid_empty_array_with_runs() {
    check(
        "valid_empty_array_with_runs",
        r#"Value:: I {order="";out=coalesce(["tail"],undef).take(0).with(){order=cat(order,"W");return([value.count(),"tail"])};return([out,order])}"#,
        "x",
        serde_json::from_str(r#"[[0,"tail"],"W"]"#).unwrap(),
    );
}

#[test]
fn rejection_skips_with_after_source_once() {
    check(
        "rejection_skips_with_after_source_once",
        r#"Value:: I {order="";out=coalesce_nonempty({order=cat(order,"S");""},"tail").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}"#,
        "x",
        serde_json::from_str(r#"[null,"S"]"#).unwrap(),
    );
}

#[test]
fn valid_with_preserves_outer_value() {
    check(
        "valid_with_preserves_outer_value",
        r#"Value:: I {value="outer";out=coalesce(undef,"tail").with(){return(value.cat("!"))};return([out,value])}"#,
        "x",
        serde_json::from_str(r#"["tail!","outer"]"#).unwrap(),
    );
}

#[test]
fn needed_default_failure_precedes_recovery() {
    let actual = routes(
        r#"Value:: I {return(coalesce(undef,{items="text";push(items,"x")}).coalesce("masked"))}"#,
        "x",
    );
    eprintln!(
        "FREE_DEFAULT_ERROR {}",
        serde_json::to_string(&actual).unwrap()
    );
    for row in actual {
        assert!(row.unwrap_err().contains("binding_kind_mismatch"));
    }
}

#[test]
fn excluded_source_shapes_stay_current() {
    use linkedspec_core::expr::CodeBlock;
    let shapes: Vec<_> = [
        r#"coalesce().take(1)"#,
        r#"coalesce("tail").take(1)"#,
        r#"coalesce(first:"tail",second:undef).take(1)"#,
        r#"coalesce_nonempty("","tail"){return("x")}.take(1)"#,
        r#"(coalesce(undef,"tail")).take(1)"#,
        r#"thunk().take(1)"#,
        r#"coalesce(undef,["tail"])[-1]="x""#,
        r#"{|| return(coalesce(undef,"tail").take(1)) }"#,
    ]
    .iter()
    .map(|source| (*source, CodeBlock::parse(source)))
    .collect();
    assert_eq!(shapes.len(), 8);
    eprintln!(
        "FREE_DEFAULT_SHAPES {}",
        serde_json::to_string(&shapes).unwrap()
    );
}
