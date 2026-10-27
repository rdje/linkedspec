//! TYPE-REFERENCE-BOOK.1.2.23.3.31.6.5 — final callback snapshot before scoped value.
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
        eprintln!("CALLBACK_SNAPSHOT route{route} {value:?}");
        assert_eq!(
            value.expect("execute with result"),
            expected,
            "route{route}"
        );
    }
}
fn top(body: &str) -> String {
    format!("Top:: I {{{body}}}")
}
#[test]
fn helper_callback_in_value_binding_is_snapshotted_and_restored() {
    check(
        &top(
            r#"value={|item|return(cat(item,"!"))};result=with("ok",value);return([result,value("again")]);"#,
        ),
        "x",
        json!(["ok!", "again!"]),
        false,
    );
}
#[test]
fn receiver_callback_in_value_binding_is_snapshotted_and_restored() {
    check(
        &top(
            r#"value={|item|return(cat(item,"!"))};result="ok".with(value);return([result,value("again")]);"#,
        ),
        "x",
        json!(["ok!", "again!"]),
        false,
    );
}
#[test]
fn opaque_callback_expression_runs_once_after_source_before_scope() {
    check(
        &top(
            r#"order="";value={|item|order=cat(order,"B");return(cat(item,"!"))};result=with({order=cat(order,"S");"ok"},coalesce({order=cat(order,"C");value},null));return([result,order,value("again"),order]);"#,
        ),
        "x",
        json!(["ok!", "SCB", "again!", "SCBB"]),
        false,
    );
}
#[test]
fn value_argument_effects_precede_the_final_callback_snapshot() {
    check(
        &top(
            r#"order="";old={|item|return(cat("old:",item))};new={|item|return(cat("new:",item))};value=old;result=with({order=cat(order,"S");value=new;"ok"},value);return([result,order,value("again")]);"#,
        ),
        "x",
        json!(["new:ok", "S", "new:again"]),
        false,
    );
}
#[test]
fn ordinary_callback_name_and_outer_value_remain_healthy() {
    check(
        &top(
            r#"value="outer";order="";cb={|item|return(cat(item,"!"))};result=with({order=cat(order,"S");"ok"},coalesce({order=cat(order,"C");cb},null));return([result,order,value]);"#,
        ),
        "x",
        json!(["ok!", "SC", "outer"]),
        false,
    );
}
