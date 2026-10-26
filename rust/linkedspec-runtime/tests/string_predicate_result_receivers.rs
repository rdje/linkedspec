//! TYPE-REFERENCE-BOOK.1.2.23.3.10.2 — string_predicate results feed scalar methods.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

#[test]
fn string_predicate_results_preserve_kinds_shapes_and_operand_order() {
    let source =
        include_str!("../../../tests/fixtures/string_predicate_result_receiver_values.spec");
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    let spec = compile(&parsed).expect("compile");
    let expected: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/string_predicate_result_receiver_values.json"
    ))
    .expect("expected fixture");
    assert_eq!(
        Engine::new(spec.clone())
            .execute_value("x", &ExecutionOptions::new())
            .expect("native execute"),
        expected
    );
    let serialized = serde_json::to_string(&spec).expect("serialize");
    let restored: CompiledSpec = serde_json::from_str(&serialized).expect("restore");
    assert_eq!(
        Engine::new(restored)
            .execute_value("x", &ExecutionOptions::new())
            .expect("restored execute"),
        expected
    );
    let plan = [GeneratedPlanRow {
        label: "Top",
        family: "default",
    }];
    assert_eq!(
        execute_generated_parser_v2(
            &serialized,
            &plan,
            "x",
            "string-predicate-result-receivers.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}

#[test]
fn regex_literal_flags_follow_the_existing_helper_contract() {
    let source = r#"Top:: I { return([matches("ABC",/^a/i),matches("ABC",/^a/),matches("abc",/^a/),matches("ABC",/^A/),matches("ABC",/(?i)^a/),matches("ab",/^ a b $/x),matches("ab",/(?x)^ a b $/),matches(input_text(),/^b/m),matches(input_text(),/^b/),matches(input_text(),/(?m)^b/),matches(input_text(),/^a.b$/s),matches(input_text(),/^a.b$/),matches(input_text(),/(?s)^a.b$/),matches("abc",/^a/go),matches("abc",/^a/q),matches("ABC",/^a/ii),split("AXB",/x/i),["A","b"].filter_match(/a/i)]) }"#;
    let parsed = parse_spec_with_user_functions(source).expect("parse flag probe");
    validate(&parsed).expect("validate flag probe");
    let spec = compile(&parsed).expect("compile flag probe");
    let actual = Engine::new(spec.clone())
        .execute_value("a\nb", &ExecutionOptions::new())
        .expect("execute flag probe");
    let expected = serde_json::json!([
        true,
        false,
        true,
        true,
        true,
        true,
        true,
        true,
        false,
        true,
        true,
        false,
        true,
        true,
        false,
        true,
        ["A", "B"],
        ["A"]
    ]);
    if actual != expected {
        println!(
            "compiled_regex_flag_probe:{}",
            serde_json::to_string(&spec).expect("serialize flag probe")
        );
    }
    assert_eq!(actual, expected);
    let serialized = serde_json::to_string(&spec).expect("serialize flag controls");
    let restored: CompiledSpec = serde_json::from_str(&serialized).expect("restore flag controls");
    assert_eq!(
        Engine::new(restored)
            .execute_value("a\nb", &ExecutionOptions::new())
            .expect("restored flag controls"),
        expected
    );
    let plan = [GeneratedPlanRow {
        label: "Top",
        family: "default",
    }];
    assert_eq!(
        execute_generated_parser_v2(
            &serialized,
            &plan,
            "a\nb",
            "regex-literal-flag-controls.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated flag controls"),
        expected
    );
}
