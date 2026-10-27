//! TYPE-REFERENCE-BOOK.1.2.23.3.32.2 — immediate contextual with-result reads.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn routes(source: &str) -> Result<Vec<Result<Value, String>>, String> {
    let parsed =
        parse_spec_with_user_functions(source).map_err(|error| format!("parse: {error}"))?;
    validate(&parsed).map_err(|error| format!("validate: {error:?}"))?;
    let compiled = compile(&parsed).map_err(|error| format!("compile: {error}"))?;
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    Ok(vec![
        Engine::new(compiled)
            .execute_value("x", &ExecutionOptions::new())
            .map_err(|error| error.to_string()),
        Engine::new(restored)
            .execute_value("x", &ExecutionOptions::new())
            .map_err(|error| error.to_string()),
        execute_generated_parser_v2(
            &serialized,
            &[GeneratedPlanRow {
                label: "Top",
                family: "default",
            }],
            "x",
            "with-result-selection.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ])
}
fn projection(result: &Result<Vec<Result<Value, String>>, String>) -> Value {
    match result {
        Ok(rows) => json!({"routes": rows.iter().map(|row| match row {
            Ok(value) => json!({"ok": value}),
            Err(error) => json!({"error": error}),
        }).collect::<Vec<_>>()}),
        Err(error) => json!({"compile_error": error}),
    }
}
fn check(source: &str, expected: Value) {
    let results = routes(source);
    eprintln!("WITH_SELECTION_ACTUAL {}", projection(&results));
    for (route, result) in results.expect("compile source").into_iter().enumerate() {
        assert_eq!(result.expect("execute source"), expected, "route{route}");
    }
}
#[test]
fn frozen_immediate_with_selection_target() {
    check(
        include_str!("../../../tests/fixtures/with_result_selection_values.spec"),
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/with_result_selection_values.json"
        ))
        .unwrap(),
    );
}
#[test]
fn nested_and_pure_function_scopes_restore_the_caller() {
    check(
        r#"fn pure(text){return(with(text){return([uppercase(value)])}[0])}
Top:: I {
 value="outer";
 nested=with("outside"){return(with("inside"){return([value])}[0])};
 return([nested,value,pure("ok")]);
}"#,
        json!(["inside", "outer", "OK"]),
    );
}
#[test]
fn specific_function_and_unknown_helper_fences_survive_reads() {
    for (source, name) in [
        (
            "fn forbidden(){return(with(\"x\"){return([entry_len()])}[0].uppercase())}\nTop:: I {return(forbidden())}",
            "entry_len",
        ),
        (
            r#"Top:: I {return(with("x"){return([missing()])}[0].uppercase())}"#,
            "missing",
        ),
    ] {
        let results = routes(source);
        eprintln!("WITH_SELECTION_ERROR {name} {}", projection(&results));
        match results {
            Err(error) => {
                assert!(error.contains(name), "{error}");
                if name == "entry_len" {
                    assert!(error.contains("parser-state helper"), "{error}");
                }
            }
            Ok(rows) => {
                for row in rows {
                    let error = row.expect_err("source/body must reject");
                    assert!(error.contains(name), "{error}");
                    if name == "entry_len" {
                        assert!(error.contains("parser-state helper"), "{error}");
                    }
                }
            }
        }
    }
}
// Freeze the independently observed callback/body policies; these are not new
// helper-source rights. In particular, explicit/bound final callbacks retain
// their legacy first-consumer behavior.
#[test]
fn existing_callback_roles_keep_their_read_and_consumer_policies() {
    check(
        r#"Top:: I {order="";cb={|item|return([item])};return([with("z",cb)[0],with("z",cb)[9].count(),with("z",cb)[0].take({order=cat(order,"B");1}),order]);}"#,
        json!(["z", 0, [], "B"]),
    );
    check(
        r#"Top:: I {return([with("z",{|item|return([item])})[0],with("z",{|item|return([item])})[9].count()]);}"#,
        json!(["z", 0]),
    );
    check(
        r#"fn apply(callback: codeblock){return(callback())}
Top:: I {cb={||return(with("x"){return(["yes"])}[0])};a=apply(){return(with("x"){return(["yes"])}[0])};return([cb(),a,"x".with(){return([false])}[0].copy()]);}"#,
        json!(["yes", "yes", false]),
    );
}
#[test]
fn malformed_contextual_arity_keeps_its_compile_error() {
    let error = routes(r#"Top:: I {return(with("x","extra"){return([1])}[0]);}"#)
        .expect_err("malformed with must not compile");
    assert!(
        error.contains("callable_contract_arity_mismatch"),
        "{error}"
    );
    assert!(error.contains("Helper 'with'"), "{error}");
    assert!(error.contains("got 2"), "{error}");
}
#[test]
fn unknown_value_operand_keeps_ordinary_warning_undef_policy() {
    // The source operand runs before entering the callback, where Rust has
    // historically warned and returned undef for an unbound ordinary call.
    // Inside the body the existing callable unknown-helper diagnostic applies.
    check(
        r#"Top:: I {return(with(missing_source()){return([1])}[0].uppercase())}"#,
        json!("1"),
    );
}
