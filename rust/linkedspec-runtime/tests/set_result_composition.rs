//! TYPE-REFERENCE-BOOK.1.2.23.3.59.2 — canonical set stored typed results.
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
            "set-result-composition.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}

fn check(label: &str, source: &str, input: &str, expected: Value) {
    let actual = routes(source, input);
    eprintln!(
        "SET_RESULT_VALUE {label} {}",
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
fn full_frozen_set_target() {
    check(
        "shared",
        include_str!("../../../tests/fixtures/set_result_selection_values.spec"),
        "x",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/set_result_selection_values.json"
        ))
        .unwrap(),
    );
}

#[test]
fn stored_result_case_1() {
    check(
        "existing primitives and compatible methods",
        r#"Value:: I {a=set(text," tail ").trim().uppercase();b=set(items,[3,1]).sorted().first();c=set(meta,{"k":"tail"});d=set(flag,false).not();e=set(number,0).add(1);f=set(absent,undef).coalesce("M");return([a,b,c,d,e,f,text,items,meta,flag,number,absent])}"#,
        "x",
        serde_json::from_str(
            r#"["TAIL",1,{"k":"tail"},true,1,"M"," tail ",[3,1],{"k":"tail"},false,0,null]"#,
        )
        .unwrap(),
    );
}

#[test]
fn stored_result_case_2() {
    check(
        "existing completed-value read",
        r#"Value:: I {saved=set(items,["tail"]);out=saved.coalesce(undef)[-1].uppercase();return([out,items])}"#,
        "x",
        serde_json::from_str(r#"["TAIL",["tail"]]"#).unwrap(),
    );
}

#[test]
fn stored_result_case_3() {
    check(
        "direct incompatible consumers skip operands",
        r#"Value:: I {order="";out=set(items,["tail"]).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,items,order])}"#,
        "x",
        serde_json::from_str(r#"[null,["tail"],""]"#).unwrap(),
    );
}

#[test]
fn stored_result_case_4() {
    check(
        "selected guards empty defaults and noncontainer recovery",
        r#"Value:: I {order="";bad=set(flag,false)[0].coalesce(false).take({order=cat(order,"A");1});text=set(word,"tail")[0].coalesce(["a","tail"])[-1].uppercase();empty=set(blank,"").coalesce({order=cat(order,"F");"bad"}).cat("!");return([bad,text,empty,flag,word,blank,order])}"#,
        "x",
        serde_json::from_str(r#"[null,"TAIL","!",false,"tail","",""]"#).unwrap(),
    );
}

#[test]
fn stored_result_case_5() {
    check(
        "source once before consumer rebinding and local returns",
        r#"Value:: I {order="";out=set(items,{order=cat(order,"S");return(["tail"])}).last().cat({items=["new"];order=cat(order,"C");return("!")}).uppercase();return([out,items,order])}"#,
        "x",
        serde_json::from_str(r#"["TAIL!",["new"],"SC"]"#).unwrap(),
    );
}

#[test]
fn stored_result_case_6() {
    check(
        "with actual kinds preserves outer value",
        r#"Value:: I {value="outer";order="";a=set(text,"source").with(){return([value,"tail"])}[-1].uppercase();b=set(meta,{}).with(){return({"k":["head","tail"]})}["k"][-1].uppercase();bad=set(flag,false).with(){return(false)}.take({order=cat(order,"A");1});return([a,b,bad,value,order,text,meta,flag])}"#,
        "x",
        serde_json::from_str(r#"["TAIL","TAIL",null,"outer","","source",{},false]"#).unwrap(),
    );
}

#[test]
fn stored_result_case_7() {
    check(
        "function-local set source and selectors keep caller scope",
        r#"fn pick(){items=["old"];order="";out=set(items,["a","tail"])[{order=cat(order,"I");-1}].uppercase();return([out,items,order])} Value:: I {items=["caller"];order="outer";return([pick(),items,order])}"#,
        "x",
        serde_json::from_str(r#"[["TAIL",["a","tail"],"I"],["caller"],"outer"]"#).unwrap(),
    );
}

#[test]
fn stored_result_case_8() {
    check(
        "set preserves existing first-class codeblock values",
        r#"Value:: I {saved=set(thunk,{|| return("tail")});return([thunk(),saved()])}"#,
        "x",
        serde_json::from_str(r#"["tail","tail"]"#).unwrap(),
    );
}

#[test]
fn stored_result_case_9() {
    check(
        "selected Bool skips Array operand",
        r#"Value:: I {order="";out=set(items,[false])[0].take({order=cat(order,"A");1});return([out,items,order])}"#,
        "x",
        serde_json::from_str(r#"[null,[false],""]"#).unwrap(),
    );
}

#[test]
fn stored_result_case_10() {
    check(
        "selected String skips Hash operands",
        r#"Value:: I {order="";out=set(items,["tail"])[0].set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,items,order])}"#,
        "x",
        serde_json::from_str(r#"[null,["tail"],""]"#).unwrap(),
    );
}

#[test]
fn source_rhs_failure_precedes_defaults() {
    let source =
        r#"Value:: I {return(set(target,{items="text";push(items,"x")}).coalesce("masked"))}"#;
    let actual = routes(source, "x");
    eprintln!(
        "SET_RESULT_ERROR {}",
        serde_json::to_string(&actual).unwrap()
    );
    for row in actual {
        assert!(row.unwrap_err().contains("binding_kind_mismatch"));
    }
}

#[test]
fn source_shape_and_alias_provenance_stay_current() {
    use linkedspec_core::expr::{CodeBlock, Expr};
    let alias = CodeBlock::parse(r#"=(items,["tail"])"#).unwrap();
    assert!(matches!(&alias.statements[0].expr,Expr::Call{name,..} if name=="="));
    let shapes: Vec<_> = [
        r#"set()"#,
        r#"set(items)"#,
        r#"set(items,["tail"],99)"#,
        r#"set(["items"],"tail")"#,
        r#"set(items,"tail"){return("x")}[0]"#,
        r#"set(items,["tail"])[-1]="x""#,
        r#"{|| return(set(items,["tail"])[-1])}"#,
    ]
    .iter()
    .map(|source| (*source, CodeBlock::parse(source)))
    .collect();
    eprintln!(
        "SET_RESULT_SHAPES {}",
        serde_json::to_string(&(alias, shapes)).unwrap()
    );
}
