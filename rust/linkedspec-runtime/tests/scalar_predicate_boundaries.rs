//! SESSION-STARTUP-READING.61.2 — null and empty scalar operand boundaries.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::json;

#[test]
fn scalar_predicates_and_literal_replacement_keep_boundary_semantics() {
    let source = include_str!("../../../tests/fixtures/scalar_predicate_boundaries.spec");
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    let spec = compile(&parsed).expect("compile");
    let expected = json!([
        ["ab", 0, 0, 0, false],
        [0, 0, 0, false],
        [0, 0, 0, null, null, null, null],
        [1, 1, 1, true, false],
        ["ab", "ab", "ab", 0, 0, 0],
        [1, 1, 1, "a!a", "bc", "ab"],
        ["ab", "SNR"],
        [0, 0]
    ]);
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
            "scalar-predicate-boundaries.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
