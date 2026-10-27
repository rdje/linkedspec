//! TYPE-REFERENCE-BOOK.1.2.1.4.2.2.2 — primitive-preserving value copy (ADR0138).
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn assert_copy(source: &str, input: &str, expected: Value) {
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    let spec = compile(&parsed).expect("compile");
    let serialized = serde_json::to_string(&spec).expect("serialize");
    let restored: CompiledSpec = serde_json::from_str(&serialized).expect("restore");
    let plan: Vec<_> = spec
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Top" => "Top",
                "Item" => "Item",
                other => panic!("unexpected fixture rule {other}"),
            },
            family: "default",
        })
        .collect();
    let native = Engine::new(spec.clone()).execute_value(input, &ExecutionOptions::new());
    let restored = Engine::new(restored).execute_value(input, &ExecutionOptions::new());
    let generated = execute_generated_parser_v2(
        &serialized,
        &plan,
        input,
        "value-copy.spec",
        GENERATED_SOURCE_CONTRACT,
    );
    eprintln!("native={native:?}\nrestored={restored:?}\ngenerated={generated:?}");
    assert_eq!(native.expect("native"), expected);
    assert_eq!(restored.expect("restored"), expected);
    assert_eq!(generated.expect("generated"), expected);
}

#[test]
fn primitive_values_kinds_sources_and_result_flows() {
    assert_copy(
        include_str!("../../../tests/fixtures/value_copy_values.spec"),
        "x",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/value_copy_values.json"
        ))
        .expect("oracle"),
    );
}

#[test]
fn compatible_container_kind_is_checked_before_operands() {
    assert_copy(
        r#"Top:: I {
        order="";
        a=copy({"a":1}).take({order=cat(order,"A");1});
        b=copy([1]).set_key({order=cat(order,"K");"a"},{order=cat(order,"V");2});
        return([a,b,order]);
    }"#,
        "x",
        json!([null, null, ""]),
    );
}

#[test]
fn malformed_receiver_keeps_pre_effect_rejection() {
    assert_copy(
        r#"Top:: I {
        order="";
        a={order=cat(order,"S");false}.copy({order=cat(order,"A");1});
        b={order=cat(order,"R");[1]}.copy(fail("must-not-run"));
        return([a,b,order]);
    }"#,
        "x",
        json!([null, null, ""]),
    );
}

#[test]
fn legacy_rule_accumulator_copy_stays_a_container() {
    assert_copy(
        "Top::\n -> Item .push\n LX.return(copy(Top))\n\nItem: /x/ I.return(\"x\")\n",
        "xx",
        json!(["x", "x"]),
    );
}

#[test]
fn malformed_free_call_policy_and_text_payload_stay_explicit() {
    assert_copy(
        r#"Top:: I {
        Top=[7];return([copy(),copy(1,2),copy([1],2),copy("Top")]);
    }"#,
        "x",
        json!([[], [], [1], "Top"]),
    );
}

#[test]
fn string_copy_does_not_become_a_numeric_write_selector() {
    let source = r#"Top:: I { items=["zero"];items[copy("0")]="changed";return(items) }"#;
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    let spec = compile(&parsed).expect("compile");
    let serialized = serde_json::to_string(&spec).expect("serialize");
    let restored: CompiledSpec = serde_json::from_str(&serialized).expect("restore");
    let native = Engine::new(spec)
        .execute_value("x", &ExecutionOptions::new())
        .expect_err("String selector");
    let restored = Engine::new(restored)
        .execute_value("x", &ExecutionOptions::new())
        .expect_err("restored String selector");
    let generated = execute_generated_parser_v2(
        &serialized,
        &[GeneratedPlanRow {
            label: "Top",
            family: "default",
        }],
        "x",
        "value-copy.spec",
        GENERATED_SOURCE_CONTRACT,
    )
    .expect_err("generated String selector")
    .to_string();
    for error in [native, restored, generated] {
        assert!(error.contains("nested_write_kind_conflict"), "{error}");
        assert!(error.contains("harray"), "{error}");
    }
}
