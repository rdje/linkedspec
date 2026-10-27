//! TYPE-REFERENCE-BOOK.1.2.23.3.22.2 — tagged-record producer and String receiver.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

#[test]
fn eager_tagged_record_producer_preserves_values_and_current_split() {
    assert_records(
        r#"Top:: I { counter=0;records=split_tagged_records("a,b,",",","row",set(counter,num_add(counter,1)),false,null,["x"],{"key":"v"});empty=split_tagged_records("",",","row",set(counter,num_add(counter,1)));return([records,empty,counter,split("a,b,",","),split("",",")]); }"#,
        json!([[["row","a",1,false,null,["x"],{"key":"v"}],["row","b",1,false,null,["x"],{"key":"v"}],["row","",1,false,null,["x"],{"key":"v"}]],[["row","",2]],2,["a","b",""],[""]]),
    );
}

#[test]
fn tagged_record_string_array_and_selected_value_chains() {
    assert_records(
        include_str!("../../../tests/fixtures/tagged_record_receiver_values.spec"),
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/tagged_record_receiver_values.json"
        ))
        .expect("tagged record oracle"),
    );
}

#[test]
fn earlier_carried_arguments_and_row_copies_survive_later_writes() {
    assert_records(
        r#"Top:: I { carried=["x"];number=7;records=split_tagged_records("a,b",",","row",carried,number,{carried+="later";number=9;number});records[0][2][0]="changed";return([records,carried,number]); }"#,
        json!([
            [["row", "a", ["changed"], 7, 9], ["row", "b", ["x"], 7, 9]],
            ["x", "later"],
            9
        ]),
    );
}

#[test]
fn malformed_receiver_shapes_reject_before_all_effects() {
    assert_records(
        r#"Top:: I { order="";bad0={order=cat(order,"S");"a,b"}.split_tagged_records().count();bad1={order=cat(order,"S");"a,b"}.split_tagged_records({order=cat(order,"D");","}).take({order=cat(order,"C");1});return([bad0,bad1,order]); }"#,
        json!([null, null, ""]),
    );
}

#[test]
fn short_free_shapes_keep_null_and_eager_operands() {
    assert_records(
        r#"Top:: I { order="";short=split_tagged_records({order=cat(order,"S");"a,b"},{order=cat(order,"D");","});return([split_tagged_records(),short,order]); }"#,
        json!([null, null, "SD"]),
    );
}

fn assert_records(source: &str, expected: Value) {
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
            "tagged-record-receivers.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
