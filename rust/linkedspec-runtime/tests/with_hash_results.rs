//! TYPE-REFERENCE-BOOK.1.2.23.3.31.2.1 — ordinary eager with result composition.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
fn routes(source: &str, input: &str, child: bool) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse with result");
    validate(&parsed).expect("validate with result");
    let compiled = compile(&parsed).expect("compile with result");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let mut plan = vec![GeneratedPlanRow {
        label: "Top",
        family: "default",
    }];
    if child {
        plan.push(GeneratedPlanRow {
            label: "Value",
            family: "default",
        });
    }
    vec![
        Engine::new(compiled)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|error| error.to_string()),
        Engine::new(restored)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|error| error.to_string()),
        execute_generated_parser_v2(
            &serialized,
            &plan,
            input,
            "with-hash-results.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ]
}
fn check(source: &str, input: &str, expected: Value, child: bool) {
    for (route, value) in routes(source, input, child).into_iter().enumerate() {
        eprintln!("WITH_RESULT route{route} {value:?}");
        assert_eq!(
            value.expect("execute with result"),
            expected,
            "route{route}"
        );
    }
}
fn action(action: &str) -> String {
    format!(
        "Top::\n -> Value .push\n LX {{return(copy(Top))}}\nValue:\n /(?<head>name)/\n /=/\n /(?<value>Alpha)/\n -> Value[2] {{{action}}}\n"
    )
}
#[test]
fn unchanged_frozen_with_hash_target() {
    check(
        include_str!("../../../tests/fixtures/with_hash_result_values.spec"),
        "name=Alpha",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/with_hash_result_values.json"
        ))
        .unwrap(),
        true,
    );
}
#[test]
fn actual_kinds_skip_incompatible_operands_and_restore_scope() {
    check(
        &action(
            r#"
order="";value="outer";
a={order=cat(order,"S");"source"}.with(){order=cat(order,"W");return(3)}.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
b="source".with(){return("text")}.take({order=cat(order,"A");1});
c="source".with(){return(["a","b"])}.last().uppercase();
d="source".with(){return(false)}.coalesce({order=cat(order,"F");true});
e="source".with(){return(null)}.coalesce({order=cat(order,"N");7}).add(1);
f=with("source"){return(3)}.set_key({order=cat(order,"J");"k"},{order=cat(order,"L");1});
g=with("source"){return("text")}.take({order=cat(order,"T");1});
return([a,b,c,d,e,f,g,order,value]);
"#,
        ),
        "name=Alpha",
        json!([[null, null, "B", false, 8, null, null, "SWN", "outer"]]),
        true,
    );
}
#[test]
fn pure_function_keeps_scoped_with_value() {
    check(
        "fn pure(text){return(text.with(){return({\"n\":[value.uppercase()]})}.sorted_values().first().first())}\nTop:: I {return(pure(\"ok\"))}",
        "x",
        json!("OK"),
        false,
    );
}
#[test]
fn indexed_with_body_keeps_specific_function_fence() {
    let source = "fn forbidden(){return(\"x\".with(){return({\"n\":[entry_len()]})}.sorted_values().first()[0].uppercase())}\nTop:: I {return(forbidden())}";
    for result in routes(source, "x", false) {
        let error = result.expect_err("pure function must reject parser state");
        assert!(
            error.contains("parser-state helper") && error.contains("entry_len"),
            "{error}"
        );
    }
}

#[test]
fn nested_hash_results_keep_inner_and_outer_value_scopes() {
    check(
        &action(
            r#"
value="outer";order="";
result="outside".with(){inner="inside".with(){order=cat(order,"I");return({"k":[value]})}.sorted_values().first().first();order=cat(order,"O");return({"k":[value,inner]});}.sorted_values().first();
return([result,value,order]);
"#,
        ),
        "name=Alpha",
        json!([[["outside", "inside"], "outer", "IO"]]),
        true,
    );
}
