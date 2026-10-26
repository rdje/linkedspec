//! TYPE-REFERENCE-BOOK.1.2.23.3.15.2 — numeric comparison result continuations.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

#[test]
fn existing_numeric_comparison_producers_keep_numeric_kinds_and_strict_domains() {
    assert_consumers(
        r#"Top:: I { raw=[num_eq(2,2),num_ne(2,3),num_gt(3,2),num_ge(2,2),num_lt(2,3),num_le(2,2),num_eq(2,3),num_ne(2,2),num_gt(2,3),num_ge(2,3),num_lt(3,2),num_le(3,2)];boundaries=[num_eq("02","2"),num_eq("-.5",-0.5),num_eq(undef,0),num_eq(false,0),num_eq(true,1),num_eq("",0),num_eq("x",0),num_eq([],0),num_eq({},0),num_eq(2),num_eq(2,2,2)];aliases=[eq(2,2),ne(2,2),gt(2,1),ge(2,2),lt(2,3),le(2,2),==(2,2),!=(2,2),>(2,1),>=(2,2),<(2,3),<=(2,2)];nested=[cat(num_eq(2,2),"!"),cat(coalesce_nonempty(num_eq(2,3),"late"),"!"),num_add(num_eq(2,3),2),uppercase(last(split(cat(num_eq(2,2),",x"),",")))];source=2;order="";effected=cat(num_eq({order=cat(order,"S");source},{order=cat(order,"O");source=3;2}),{order=cat(order,"C");source=undef;"!"});return({"raw":raw,"boundaries":boundaries,"aliases":aliases,"nested":nested,"effected":effected,"order":order,"source":source}); }"#,
        serde_json::json!({"raw":[1,1,1,1,1,1,0,0,0,0,0,0],"boundaries":[1,1,null,null,null,null,null,null,null,null,null],"aliases":[1,0,1,1,1,1,1,0,1,1,1,1],"nested":["1!","0!",2,"X"],"effected":"1!","order":"SOC","source":null}),
    );
}

#[test]
fn numeric_comparison_results_preserve_kinds_shapes_and_operand_order() {
    assert_consumers(
        include_str!("../../../tests/fixtures/numeric_comparison_result_receiver_values.spec"),
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/numeric_comparison_result_receiver_values.json"
        ))
        .expect("expected numeric comparison results"),
    );
}

#[test]
fn numeric_comparison_flags_remain_array_write_indexes() {
    assert_consumers(
        r#"Top:: I { score=2;values=["zero","one"];values[score.eq(2)]="updated";return(values) }"#,
        serde_json::json!(["zero", "updated"]),
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
            "numeric-comparison-results.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
