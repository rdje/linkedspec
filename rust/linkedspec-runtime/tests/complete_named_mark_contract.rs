//! FUTURE-PARITY-BACKLOG.17.1 — complete named-mark helper contract.

use linkedspec_core::compiler::compile;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GeneratedPlanRow, emit_rust_source_v1, execute_generated_parser_v1,
    validate_generated_parser_plan_v1,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

const CONTRACT_JSON: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../capability_conformance/complete_named_mark_contract.json"
));

const TOP_CHILD_PLAN: &[GeneratedPlanRow] = &[
    GeneratedPlanRow {
        label: "Top",
        family: "default",
    },
    GeneratedPlanRow {
        label: "Child",
        family: "default",
    },
];

fn contract() -> Value {
    serde_json::from_str(CONTRACT_JSON).expect("complete named-mark contract JSON")
}

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse complete named-mark fixture");
    validate(&parsed).expect("validate complete named-mark fixture");
    compile(&parsed).expect("compile complete named-mark fixture")
}

#[test]
fn seven_helper_contract_matches_perl_oracle_natively_serialized_and_generated() {
    let contract = contract();
    assert_eq!(contract["contract_id"], "linkedspec-complete-named-mark-v1");
    assert_eq!(contract["helpers"].as_array().expect("helpers").len(), 7);

    let fixture = &contract["fixture"];
    let source = fixture["spec_source"].as_str().expect("fixture source");
    let input = fixture["input"].as_str().expect("fixture input");
    let expected = fixture["expected"].clone();
    let compiled = compile_source(source);

    assert_eq!(
        Engine::new(compiled.clone())
            .execute_value(input, &ExecutionOptions::new())
            .expect("native complete named-mark fixture"),
        expected
    );

    let compiled_json = serde_json::to_string(&compiled).expect("serialize compiled fixture");
    let decoded: CompiledSpec =
        serde_json::from_str(&compiled_json).expect("deserialize compiled fixture");
    assert_eq!(
        Engine::new(decoded)
            .execute_value(input, &ExecutionOptions::new())
            .expect("serialized complete named-mark fixture"),
        expected
    );

    let identity = "complete-named-mark.spec";
    let generated = emit_rust_source_v1(&compiled, identity).expect("emit generated Rust source");
    assert!(generated.contains("linkedspec-generated-source-v1"));
    validate_generated_parser_plan_v1(&compiled_json, TOP_CHILD_PLAN, identity)
        .expect("validate complete named-mark generated plan");
    assert_eq!(
        execute_generated_parser_v1(&compiled_json, TOP_CHILD_PLAN, input, identity)
            .expect("execute complete named-mark generated parser"),
        expected
    );
}
