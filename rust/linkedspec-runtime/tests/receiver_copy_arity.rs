//! TYPE-REFERENCE-BOOK.1.2.23.3.2.3 — receiver copy shape before effects.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::json;

#[test]
fn receiver_copy_rejects_extra_operands_before_effects() {
    let source = r#"Top:: I {
      effects=0;
      invalid={effects=num_add(effects,1); [["a"]]}.first().copy({effects=num_add(effects,1); 1});
      invalid_direct={effects=num_add(effects,1); ["b"]}.copy({effects=num_add(effects,1); 1});
      valid_effects=0; original=[["a"]];
      copied={valid_effects=num_add(valid_effects,1); original}.first().copy();
      copied+="b";
      return([invalid,invalid_direct,effects,copied,original,valid_effects,"x".copy(),missing.copy()]);
    }"#;
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    let spec = compile(&parsed).expect("compile");
    // ADR0138 advances only the primitive/null copy results; shape/depth controls stay.
    let expected = json!([null, null, 0, ["a", "b"], [["a"]], 1, "x", null]);
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
            "receiver-copy-arity.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
