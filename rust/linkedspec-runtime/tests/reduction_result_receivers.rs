//! TYPE-REFERENCE-BOOK.1.2.23.3.21.2 — reduction accumulator result continuations.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

#[test]
fn admitted_reduction_producers_preserve_actual_accumulator_kinds() {
    assert_consumers(
        r#"Top:: I { return([[1,[2,3]].reduce_leaves(0) { return(acc.add(value)) },["a",["b"]].reduce_leaves("") { return(cat(acc,value)) },[1,[2,3]].reduce_leaves([]) { return(concat_arrays(acc,[value])) },[1].reduce_leaves({}) { return({"key":"B"}) },[].reduce_leaves(false) { return(true) },[1].reduce_leaves(0) { return(undef) },[].reduce_leaves(["empty"]) { return(value) },{"b":2,"a":1}.reduce_leaves(0) { return(acc.add(value)) }]); }"#,
        json!([6,"ab",[1,2,3],{"key":"B"},false,null,["empty"],3]),
    );
}

#[test]
fn admitted_walk_map_and_plain_reduce_keep_root_shapes_and_path_order() {
    assert_consumers(
        r#"Top:: I { original=[1,[2]];seen=[];walked=original.walk_leaves() {seen+=join_values("/",path);return(99)};mapped=original.map_leaves() {return(value.add(1))};meta={"b":{"y":2},"a":1,"arr":[9]};paths=[];hash=meta.walk_leaves() {paths+=join_values("/",path);return(0)};return([original,walked,mapped,seen,hash,paths,[1,[2]].reduce_leaves(0) {return(acc.add(value))}]); }"#,
        json!([[1,[2]],[1,[2]],[2,[3]],["0","1/0"],{"b":{"y":2},"a":1,"arr":[9]},["a","arr","b/y"],3]),
    );
}

#[test]
fn reduction_result_kinds_immediate_traversals_scopes_and_effects_compose() {
    assert_consumers(
        include_str!("../../../tests/fixtures/reduction_result_receiver_values.spec"),
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/reduction_result_receiver_values.json"
        ))
        .expect("reduction result oracle"),
    );
}

#[test]
fn reduction_continuations_keep_source_initial_callback_consumer_order() {
    assert_consumers(
        r#"Top:: I { items=[1,2];order="";calls=0;result={order=cat(order,"S");calls=num_add(calls,1);items}.reduce_leaves({order=cat(order,"I");items=[9];0}) {order=cat(order,"L");return(acc.add(value))}.cat({order=cat(order,"C");items=undef;"!"});return([result,order,calls,items]); }"#,
        json!(["3!", "SILLC", 1, null]),
    );
}

#[test]
fn invalid_tree_roots_skip_initial_and_callback_effects() {
    assert_consumers(
        r#"Top:: I { order="";result={order=cat(order,"S");"x"}.reduce_leaves({order=cat(order,"I");0}) {order=cat(order,"L");return(value)};other=undef.reduce_leaves({order=cat(order,"I");0}) {order=cat(order,"L");return(value)};return([result,other,order]); }"#,
        json!([null, null, "S"]),
    );
}

#[test]
fn malformed_reduction_arity_keeps_compile_time_contract_errors() {
    for source in [
        r#"Top:: I { return([1].reduce_leaves() { return(value) }.cat("!")); }"#,
        r#"Top:: I { return([1].reduce_leaves(0,1) { return(value) }.cat("!")); }"#,
    ] {
        let parsed = parse_spec_with_user_functions(source).expect("parse malformed shape");
        validate(&parsed).expect("structural validation");
        let error = compile(&parsed)
            .expect_err("callable signature rejects arity")
            .to_string();
        assert!(
            error.contains("callable_contract_arity_mismatch"),
            "{error}"
        );
        assert!(error.contains("reduce_leaves"), "{error}");
    }
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
            "reduction-result-receivers.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
