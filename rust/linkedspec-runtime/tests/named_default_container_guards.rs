//! TYPE-REFERENCE-BOOK.1.2.23.3.59.6 — completed default containers retain actual kinds.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse set stored results");
    validate(&parsed).expect("validate set stored results");
    let compiled = compile(&parsed).expect("compile set stored results");
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
            "named-default-container-guards.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}

fn check(label: &str, source: &str, input: &str, expected: Value) {
    let actual = routes(source, input);
    eprintln!(
        "NAMED_DEFAULT_VALUE {label} {}",
        serde_json::to_string(&actual).unwrap()
    );
    for (route, value) in actual.into_iter().enumerate() {
        assert_eq!(
            value.expect("execute set stored result"),
            expected,
            "{label} route{route}"
        );
    }
}

#[test]
fn original_reproducer() {
    check(
        "original_reproducer",
        r#"Value:: I {order="";saved=set(items,["tail"]);out=saved.coalesce(undef)[-1].uppercase();bad=saved.coalesce(undef).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,bad,items,order])}"#,
        "x",
        serde_json::from_str(r#"["TAIL",null,["tail"],""]"#).unwrap(),
    );
}

#[test]
fn named_hash_guard() {
    check(
        "named_hash_guard",
        r#"Value:: I {order="";meta={"k":"tail"};out=meta.coalesce(undef).take({order=cat(order,"A");1});return([out,meta,order])}"#,
        "x",
        serde_json::from_str(r#"[null,{"k":"tail"},""]"#).unwrap(),
    );
}

#[test]
fn nonempty_container_guards() {
    check(
        "nonempty_container_guards",
        r#"Value:: I {order="";items=["tail"];meta={"k":"tail"};a=items.coalesce_nonempty({order=cat(order,"F");"bad"}).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=meta.coalesce_nonempty({order=cat(order,"F");"bad"}).take({order=cat(order,"A");1});return([a,b,order])}"#,
        "x",
        serde_json::from_str(r#"[null,null,""]"#).unwrap(),
    );
}

#[test]
fn compatible_fallbacks() {
    check(
        "compatible_fallbacks",
        r#"Value:: I {order="";none=undef;blank="";a=none.coalesce({order=cat(order,"A");["head","tail"]}).last().uppercase();b=blank.coalesce_nonempty({order=cat(order,"B");{"k":"tail"}}).sorted_keys().last().uppercase();return([a,b,order])}"#,
        "x",
        serde_json::from_str(r#"["TAIL","K","AB"]"#).unwrap(),
    );
}

#[test]
fn fallback_container_guards() {
    check(
        "fallback_container_guards",
        r#"Value:: I {order="";none=undef;blank="";a=none.coalesce({order=cat(order,"S");["tail"]}).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=blank.coalesce_nonempty({order=cat(order,"T");{"k":"tail"}}).take({order=cat(order,"A");1});return([a,b,order])}"#,
        "x",
        serde_json::from_str(r#"[null,null,"ST"]"#).unwrap(),
    );
}

#[test]
fn selected_prefix_guards() {
    check(
        "selected_prefix_guards",
        r#"Value:: I {order="";items=[];a=items.first().coalesce(["tail"]).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=items.first().coalesce({"k":"tail"}).take({order=cat(order,"A");1});return([a,b,items,order])}"#,
        "x",
        serde_json::from_str(r#"[null,null,[],""]"#).unwrap(),
    );
}

#[test]
fn guard_before_with() {
    check(
        "guard_before_with",
        r#"Value:: I {order="";items=["tail"];out=items.coalesce(undef).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,items,order])}"#,
        "x",
        serde_json::from_str(r#"[null,["tail"],""]"#).unwrap(),
    );
}

#[test]
fn with_returned_kinds() {
    check(
        "with_returned_kinds",
        r#"Value:: I {order="";value="outer";items=["tail"];a=items.coalesce(undef).with(){return({"k":["head","tail"]})}["k"][-1].uppercase();b=items.coalesce(undef).with(){return(false)}.take({order=cat(order,"A");1});return([a,b,value,items,order])}"#,
        "x",
        serde_json::from_str(r#"["TAIL",null,"outer",["tail"],""]"#).unwrap(),
    );
}

#[test]
fn scalar_and_empty_values() {
    check(
        "scalar_and_empty_values",
        r#"Value:: I {order="";text="";flag=false;number=0;none=undef;items=[];meta={};return([text.coalesce({order=cat(order,"F");"bad"}).cat("!"),flag.coalesce({order=cat(order,"F");true}),number.coalesce({order=cat(order,"F");7}),none.coalesce("").cat("!"),items.coalesce_nonempty(["head","tail"]).count(),meta.coalesce_nonempty({"k":"tail"}).count_keys(),order])}"#,
        "x",
        serde_json::from_str(r#"["!",false,0,"!",0,0,""]"#).unwrap(),
    );
}

#[test]
fn default_method_arity_distinction() {
    check(
        "default_method_arity_distinction",
        r#"Value:: I {order="";a={order=cat(order,"S");true}.coalesce().cat({order=cat(order,"C");"!"});b={order=cat(order,"S");true}.coalesce_nonempty().cat({order=cat(order,"C");"!"});return([a,b,order])}"#,
        "x",
        serde_json::from_str(r#"[null,"1!","SC"]"#).unwrap(),
    );
}

#[test]
fn unbridged_bound_call_policy() {
    check(
        "unbridged_bound_call_policy",
        r#"Value:: I {thunk={|| return([false,["tail"]])};return([thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count()])}"#,
        "x",
        serde_json::from_str(r#"[false,"TAIL",0,0]"#).unwrap(),
    );
}

#[test]
fn free_default_compatible() {
    check(
        "free_default_compatible",
        r#"Value:: I {return([coalesce(undef,["head","tail"]).last().uppercase(),coalesce_nonempty(undef,{"k":"tail"}).sorted_keys().last().uppercase()])}"#,
        "x",
        serde_json::from_str(r#"["TAIL","K"]"#).unwrap(),
    );
}

#[test]
fn needed_default_failure_is_not_masked() {
    let source = r#"Value:: I {none=undef;return(none.coalesce({items="text";push(items,"x")}).coalesce("masked"))}"#;
    let actual = routes(source, "x");
    eprintln!(
        "NAMED_DEFAULT_ERROR {}",
        serde_json::to_string(&actual).unwrap()
    );
    for row in actual {
        assert!(row.unwrap_err().contains("binding_kind_mismatch"));
    }
}
