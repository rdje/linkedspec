//! TYPE-REFERENCE-BOOK.1.2.23.3.7.2 — index results feed scalar methods.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::json;

#[test]
fn index_results_preserve_kinds_shapes_and_operand_order() {
    let source = include_str!("../../../tests/fixtures/index_result_receiver_values.spec");
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    let spec = compile(&parsed).expect("compile");
    let expected = json!([2,2,1,null,null,null,2,2,2,2,2,2,"1!","X",8,null,null,null,2,"SNA",["a","b","c","d"],null,"N",["a","b"],null,"SN",["a","b"],["zero","old"],null,null,0,["a","b"],{"a":"a","b":"b"}]);
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
            "index-result-receivers.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
