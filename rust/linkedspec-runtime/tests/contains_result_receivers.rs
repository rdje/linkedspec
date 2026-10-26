//! TYPE-REFERENCE-BOOK.1.2.23.3.13.2 — Array contains result receivers.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

#[test]
fn existing_contains_producer_domains() {
    let source = r#"Top:: I { items=["a","b"]; raw=[contains(["a","b"],"a"),contains(["a","b"],"z"),contains([],"a"),contains([undef],undef),contains([undef],""),contains([""],undef),contains([""],""),contains([0],"0"),contains([false],0)]; order=""; value=contains(items,{order=cat(order,"O");items=["z"];"a"});missing=[].first(); missing_order=""; missing_value=contains(missing,{missing_order=cat(missing_order,"O");missing=["a"];"a"});return({"raw":raw,"snapshot_absent":[missing_value,missing_order,missing],"snapshot":[value,order,items],"text":[cat(contains(["a"],"z"),"!"),cat(coalesce_nonempty(contains(["a"],"z"),"late"),"!")]}) }"#;

    let expected = serde_json::json!({"raw":[1,0,0,1,1,1,1,1,1],"snapshot":[1,"O",["z"]],"snapshot_absent":[0,"O",["a"]],"text":["0!","0!"]});
    assert_consumers(source, expected);
}

#[test]
fn contains_results_preserve_kinds_shapes_and_operand_order() {
    let source = include_str!("../../../tests/fixtures/contains_result_receiver_values.spec");
    let expected: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/contains_result_receiver_values.rust.json"
    ))
    .expect("expected fixture");
    assert_consumers(source, expected);
}

fn assert_consumers(source: &str, expected: Value) {
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    let spec = compile(&parsed).expect("compile");
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
            "contains-result-receivers.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
