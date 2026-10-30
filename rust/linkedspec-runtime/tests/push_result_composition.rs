//! TYPE-REFERENCE-BOOK.1.2.23.3.58.2 — existing push snapshots as typed results.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse push snapshot results");
    validate(&parsed).expect("validate push snapshot results");
    let compiled = compile(&parsed).expect("compile push snapshot results");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Value" => "Value",
                "Child" => "Child",
                other => panic!("unexpected fixture label {other}"),
            },
            family: classify_generated_rule_family(rule).contract_name(),
        })
        .collect();
    vec![
        Engine::new(compiled)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|e| e.to_string()),
        Engine::new(restored)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|e| e.to_string()),
        execute_generated_parser_v2(
            &serialized,
            &plan,
            input,
            "push-result-composition.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}

fn check(label: &str, source: &str, input: &str, expected: Value) {
    let actual = routes(source, input);
    eprintln!(
        "PUSH_SNAPSHOT_VALUE {label} {}",
        serde_json::to_string(&actual).unwrap()
    );
    for (route, value) in actual.into_iter().enumerate() {
        assert_eq!(
            value.expect("execute push snapshot result"),
            expected,
            "{label} route{route}"
        );
    }
}

#[test]
fn frozen_full_push_snapshot_target() {
    check(
        "shared",
        include_str!("../../../tests/fixtures/push_result_selection_values.spec"),
        "x",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/push_result_selection_values.json"
        ))
        .unwrap(),
    );
}

#[test]
fn primitive_saved_and_absent_targets_keep_existing_values() {
    check(
        "primitive_saved",
        r#"Value:: I {items=[];saved=push(items,"a");items.push_back("later");return([saved,items])}"#,
        "x",
        json!([["a"], ["a", "later"]]),
    );
    check(
        "absent_empty",
        r#"Value:: I {empty=push(created,"").last().coalesce("F").cat("!");missing=push(nulls,undef).last().coalesce(["a","tail"])[-1].uppercase();array=push(empties,[]).last().count().add(1);return([empty,missing,array,created,nulls,empties])}"#,
        "x",
        json!(["!", "TAIL", 1, [""], [null], [[]]]),
    );
}

#[test]
fn existing_types_copy_and_logical_transitions_compose() {
    check(
        "transitions",
        r#"Value:: I {items=[];number=push(items,[3,1]).last().sorted().last().add(4);hash=push(items,{"k":"tail"}).last().sorted_keys().last().uppercase();count=push(items,"tail").count().add(1);text=push(items,"tail").copy().last().uppercase();boolean=push(items,false).last().not();logical=push(items,"tail").is_nonempty().and(false);return([number,hash,count,text,boolean,logical,items])}"#,
        "x",
        json!([7,"K",4,"TAIL",true,false,[[3,1],{"k":"tail"},"tail","tail",false,"tail"]]),
    );
}

#[test]
fn direct_actual_kind_guards_skip_operands() {
    check(
        "direct_guard",
        r#"Value:: I {items=[];order="";out=push(items,"tail").set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,items,order])}"#,
        "x",
        json!([null, ["tail"], ""]),
    );
}

#[test]
fn selected_actual_kind_guards_and_recovery_stay_current() {
    check(
        "selected_recovery",
        r#"Value:: I {items=[];order="";bad=push(items,false)[-1].take({order=cat(order,"A");1});out=push(items,"tail")[-1][0].coalesce(["a","tail"])[-1].uppercase();empty=push(items,"")[-1].coalesce({order=cat(order,"F");"bad"}).cat("!");return([bad,out,empty,items,order])}"#,
        "x",
        json!([null, "TAIL", "!", [false, "tail", ""], ""]),
    );
}

#[test]
fn with_result_kinds_preserve_outer_scope_and_guards() {
    check(
        "with_kinds",
        r#"Value:: I {items=[];value="outer";order="";array=push(items,"a").with(){return([value,"tail"])}[-1].uppercase();hash=push(items,"b").with(){return({"k":["head","tail"]})}["k"][-1].uppercase();bad=push(items,"c").with(){return(false)}.take({order=cat(order,"A");1});boolean=push(items,"d").with(){return(false)}.coalesce(true);return([array,hash,bad,boolean,value,order,items])}"#,
        "x",
        json!([
            "TAIL",
            "TAIL",
            null,
            false,
            "outer",
            "",
            ["a", "b", "c", "d"]
        ]),
    );
}

#[test]
fn source_order_snapshots_and_function_locals_stay_current() {
    check(
        "source_once",
        r#"Value:: I {items=[];order="";out=push(items,{order=cat(order,"S");return("tail")}).last().cat({items=["new"];order=cat(order,"C");return("!")}).uppercase();return([out,items,order])}"#,
        "x",
        json!(["TAIL!", ["new"], "SC"]),
    );
    check(
        "function_local",
        r#"fn pick(){items=[];out=push(items,"tail").last().uppercase();return([out,items])} Value:: I {items=["caller"];return([pick(),items])}"#,
        "x",
        json!([["TAIL", ["tail"]], ["caller"]]),
    );
}

#[test]
fn source_binding_failure_is_not_masked_by_fluent_default() {
    for (label, source) in [
        (
            "primitive",
            r#"Value:: I {items="text";return(push(items,"x"))}"#,
        ),
        (
            "fluent",
            r#"Value:: I {items="text";return(push(items,"x").last().coalesce("masked"))}"#,
        ),
    ] {
        let actual = routes(source, "x");
        eprintln!(
            "PUSH_SNAPSHOT_ERROR {label} {}",
            serde_json::to_string(&actual).unwrap()
        );
        for result in actual {
            assert!(
                result.unwrap_err().contains("binding_kind_mismatch"),
                "{label} source error preserved"
            );
        }
    }
}

#[test]
fn existing_static_child_precedence_is_preserved() {
    check(
        "static_child",
        "Value::\n I {Child=[\"unchanged\"];outputs=[];saved=push(Child,outputs);return([Child,outputs,saved])}\nChild::\n /x/ I {return(\"child\")}\n",
        "x",
        json!([["unchanged"], ["child"], ["child"]]),
    );
}
