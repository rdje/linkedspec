//! TYPE-REFERENCE-BOOK.1.2.23.3.29.2.6.2 — parser calls and public gap readers.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
fn routes(source: &str, labels: &[&'static str], input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse source");
    validate(&parsed).expect("validate source");
    let compiled = compile(&parsed).expect("compile source");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = labels
        .iter()
        .map(|label| GeneratedPlanRow {
            label,
            family: "default",
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
            "function-parser-context.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}
fn gap_source(definitions: &str, action: &str, item: &str) -> String {
    format!(
        "{definitions}\nList::\n @capture_gaps\n I {{set(rows,array())}}\n -> Item[word] {{{action}}}\n LX {{return(copy(rows))}}\nItem:\n word=/[^,;]+/\n I {{{item}}}\n"
    )
}
fn reject(source: &str, labels: &[&'static str], input: &str, helper: &str) {
    for (route, result) in routes(source, labels, input).into_iter().enumerate() {
        let error = result.expect_err(&format!("route{route} must reject {helper}"));
        assert!(
            error.contains("parser-state helper") && error.contains(helper),
            "{error}"
        );
    }
}
#[test]
fn pure_function_cannot_invoke_a_child_parser() {
    reject(
        "fn selected(){return(call(Child))}\nTop:: I {return(selected())}\nChild: I {return(\"child\")}\n",
        &["Top", "Child"],
        "x",
        "call",
    );
}
#[test]
fn pure_function_cannot_read_public_gap_context() {
    for helper in ["gap_text", "gap_kind", "gap_span", "entry_slot"] {
        let source = gap_source(
            &format!("fn selected(){{return({helper}())}}"),
            "push(rows,selected())",
            "return(entry_text())",
        );
        reject(&source, &["List", "Item"], "a,b", helper);
    }
}
#[test]
fn pure_function_cannot_read_incoming_child_slot() {
    let source = gap_source(
        "fn selected(){return(entry_slot())}",
        "push(rows,call(Item))",
        "return(selected())",
    );
    reject(&source, &["List", "Item"], "a,b", "entry_slot");
}
#[test]
fn ordinary_parser_values_remain_valid_explicit_function_arguments() {
    let source = "fn upper(text){return(text.uppercase())}\nTop:: I {return(upper(call(Child)))}\nChild: I {return(\"child\")}\n";
    for value in routes(source, &["Top", "Child"], "x") {
        assert_eq!(value.unwrap(), json!("CHILD"));
    }
    let source = gap_source(
        "fn selected(text,kind,span){return([text.uppercase(),kind,span])}",
        "push(rows,selected(gap_text(),gap_kind(),gap_span()))",
        "return(entry_text())",
    );
    for value in routes(&source, &["List", "Item"], "a,b") {
        assert_eq!(
            value.unwrap(),
            json!([["", "prefix", {"source_id":"input","start":0,"end":0,"provenance":"gap"}], [",", "interstitial", {"source_id":"input","start":1,"end":2,"provenance":"gap"}]])
        );
    }
    let source = gap_source(
        "fn identify(slot){return(slot)}",
        "push(rows,call(Item))",
        "return(identify(entry_slot()))",
    );
    let slot = json!({"target_rule":"Item","regex_index":0,"slot_id":"word","selector_kind":"named","authored_selector":"word"});
    for value in routes(&source, &["List", "Item"], "a,b") {
        assert_eq!(value.unwrap(), json!([slot, slot]));
    }
}
