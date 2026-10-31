//! TYPE-REFERENCE-BOOK.1.2.23.3.61.2 — retained constructor result guards.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse constructor results");
    validate(&parsed).expect("validate constructor results");
    let compiled = compile(&parsed).expect("compile constructor results");
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
            "constructor-result-composition.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}

fn check(label: &str, source: &str, input: &str, expected: Value) {
    let actual = routes(source, input);
    eprintln!(
        "CONSTRUCTOR_VALUE {label} {}",
        serde_json::to_string(&actual).unwrap()
    );
    for (route, value) in actual.into_iter().enumerate() {
        assert_eq!(
            value.expect("execute constructor result"),
            expected,
            "{label} route{route}"
        );
    }
}

fn check_case(label: &str) {
    let cases: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/constructor_result_cases.json"
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
fn primitive_array() {
    check_case("primitive_array");
}

#[test]
fn primitive_hash() {
    check_case("primitive_hash");
}

#[test]
fn empty_and_compatible() {
    check_case("empty_and_compatible");
}

#[test]
fn direct_reads() {
    check_case("direct_reads");
}

#[test]
fn array_hash_guard() {
    check_case("array_hash_guard");
}

#[test]
fn hash_array_guard() {
    check_case("hash_array_guard");
}

#[test]
fn selected_guards() {
    check_case("selected_guards");
}

#[test]
fn completed_bound_guards() {
    check_case("completed_bound_guards");
}

#[test]
fn source_order_snapshot() {
    check_case("source_order_snapshot");
}

#[test]
fn with_kinds() {
    check_case("with_kinds");
}

#[test]
fn function_scope() {
    check_case("function_scope");
}

#[test]
fn array_payload_order() {
    check_case("array_payload_order");
}

#[test]
fn guard_before_with() {
    check_case("guard_before_with");
}

#[test]
fn valid_empty_with() {
    check_case("valid_empty_with");
}

#[test]
fn hash_rejection_source_once_with() {
    check(
        "hash_rejection_source_once_with",
        r#"Value:: I {order="";out=hash({order=cat(order,"S");return("k")},"tail").take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}"#,
        "x",
        serde_json::from_str(r#"[null,"S"]"#).unwrap(),
    );
}

#[test]
fn array_prefix_rejection_skips_with() {
    check(
        "array_prefix_rejection_skips_with",
        r#"Value:: I {order="";out=array("head","tail").take(1).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])}"#,
        "x",
        serde_json::from_str(r#"[null,""]"#).unwrap(),
    );
}

#[test]
fn valid_empty_array_prefix_with() {
    check(
        "valid_empty_array_prefix_with",
        r#"Value:: I {order="";out=array("tail").take(0).with(){order=cat(order,"W");return([value.count(),"tail"])};return([out,order])}"#,
        "x",
        serde_json::from_str(r#"[[0,"tail"],"W"]"#).unwrap(),
    );
}

#[test]
fn valid_null_result_with() {
    check(
        "valid_null_result_with",
        r#"Value:: I {order="";out=array("tail").with(){order=cat(order,"N");return(undef)}.with(){order=cat(order,"W");return("recovered")};return([out,order])}"#,
        "x",
        serde_json::from_str(r#"["recovered","NW"]"#).unwrap(),
    );
}

#[test]
fn computed_key_forms() {
    check(
        "computed_key_forms",
        r#"Value:: I {names=["idx"];meta={"key":"field"};return([hash("k".cat("x"),1),hash(names[0],2),hash(meta["key"],3),hash({return("block")},4),hash(cat("c","all"),5)])}"#,
        "x",
        serde_json::from_str(r#"[{"kx":1},{"idx":2},{"field":3},{"block":4},{"call":5}]"#).unwrap(),
    );
}

#[test]
fn hash_block_key_value_order_snapshot() {
    check(
        "hash_block_key_value_order_snapshot",
        r#"Value:: I {name="old";order="";out=hash({order=cat(order,"K");return(name)},{name="new";order=cat(order,"V");return([false,0,"tail"])});return([out,name,order])}"#,
        "x",
        serde_json::from_str(r#"[{"old":[false,0,"tail"]},"new","KV"]"#).unwrap(),
    );
}

#[test]
fn hash_block_key_function_scope() {
    check(
        "hash_block_key_function_scope",
        r#"fn build(key){return(hash({return(key)},array("tail",false)))} Value:: I {key="caller";return([build("inside"),key])}"#,
        "x",
        serde_json::from_str(r#"[{"inside":["tail",false]},"caller"]"#).unwrap(),
    );
}

#[test]
fn needed_argument_failure_precedes_recovery() {
    let actual = routes(
        r#"Value:: I {return(array({items="text";push(items,"x")},"tail").last().coalesce("masked"))}"#,
        "x",
    );
    eprintln!(
        "CONSTRUCTOR_ARGUMENT_ERROR {}",
        serde_json::to_string(&actual).unwrap()
    );
    for row in actual {
        assert!(row.unwrap_err().contains("binding_kind_mismatch"));
    }
}
#[test]
fn needed_key_failure_precedes_consumer() {
    let actual = routes(
        r#"Value:: I {return(hash({items="text";push(items,"x")},"tail").take(1))}"#,
        "x",
    );
    eprintln!(
        "CONSTRUCTOR_KEY_ERROR {}",
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
        r#"array(items).take(1)"#,
        r#"hash(meta).take(1)"#,
        r#"hash("odd").take(1)"#,
        r#"hash(flat_array(["k",1])).take(1)"#,
        r#"array(flat_array([1,2])).set_key("k",1)"#,
        r#"array(flat_hash({"k":1})).set_key("k",1)"#,
        r#"flat_array([1,2]).set_key("k",1)"#,
        r#"custom_constructor("tail").set_key("k",1)"#,
    ]
    .iter()
    .map(|source| (*source, CodeBlock::parse(source)))
    .collect();
    assert_eq!(shapes.len(), 8);
    eprintln!(
        "CONSTRUCTOR_SHAPES {}",
        serde_json::to_string(&shapes).unwrap()
    );
}
