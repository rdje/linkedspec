//! TYPE-REFERENCE-BOOK.1.2.23.3.9.2 — emptiness results feed scalar methods.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

#[test]
fn emptiness_results_preserve_kinds_shapes_and_operand_order() {
    let source = include_str!("../../../tests/fixtures/emptiness_result_receiver_values.spec");
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    let spec = compile(&parsed).expect("compile");
    let expected: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/emptiness_result_receiver_values.json"
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
            "emptiness-result-receivers.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
