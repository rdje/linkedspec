//! TYPE-REFERENCE-BOOK.1.2.23.3.14.1 — captured aggregate operand values.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

#[test]
fn aggregate_sources_are_captured_before_later_operands() {
    assert_consumers(
        include_str!(
            "../../../docs/checkpoints/type-operation-inventory/operand-snapshot-membership.spec"
        ),
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/aggregate_operand_snapshot_values.rust.json"
        ))
        .expect("expected snapshots"),
    );
}

#[test]
fn named_aggregate_defaults_and_typed_reads_stay_compatible() {
    assert_consumers(
        r#"Top:: I { items=["b","a"]; meta={"b":2,"a":1}; missing=undef; wrong=7; return({"first":first(items),"last":last(items),"copy":copy(items),"sorted":sorted_values(meta),"missing_index":index_of(missing,"a"),"missing_key":has_key(missing,"a"),"wrong_flat":flat_hash(wrong),"missing_flat":flat_hash(missing)}) }"#,
        serde_json::json!({"first":"b","last":"a","copy":["b","a"],"sorted":[1,2],"missing_index":null,"missing_key":0,"wrong_flat":{},"missing_flat":{}}),
    );
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
            "aggregate-operand-snapshots.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
