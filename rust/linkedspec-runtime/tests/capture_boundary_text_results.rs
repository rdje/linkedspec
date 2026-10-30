//! TYPE-REFERENCE-BOOK.1.2.23.3.50.2 — readonly capture String composition.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn routes(source: &str, input: &str, child: bool) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse capture String");
    validate(&parsed).expect("validate capture String");
    let compiled = compile(&parsed).expect("compile capture String");
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
            "capture-boundary-text.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ]
}

fn check(source: &str, input: &str, expected: Value, child: bool) {
    for (route, value) in routes(source, input, child).into_iter().enumerate() {
        eprintln!("CAPTURE_TEXT route{route} {value:?}");
        assert_eq!(
            value.expect("execute capture String"),
            expected,
            "route{route}"
        );
    }
}

fn action(body: &str, tail: &str) -> String {
    format!(
        "Top::\n -> Value .push\n LX {{return(copy(Top))}}\nValue:\n /(?<head>αβ)/\n /:/\n /{tail}/\n -> Value[2] {{{body}}}\n"
    )
}

#[test]
fn frozen_readonly_capture_string_target() {
    check(
        include_str!("../../../tests/fixtures/capture_boundary_text_values.spec"),
        "αβ:cat",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/capture_boundary_text_values.json"
        ))
        .unwrap(),
        true,
    );
}

#[test]
fn each_reader_defaults_and_original_producers_keep_values() {
    check(
        &action(
            r#"return([capture_slice().coalesce("bad").cat("!"),capture_slice_until_cursor().coalesce("bad").cat("!"),capture_rest().coalesce("bad").cat("!"),capture_from_rule_start().coalesce("bad").cat("!"),[capture_slice(),capture_slice_until_cursor(),capture_rest(),capture_from_rule_start()]])"#,
            "cat",
        ),
        "αβ:cat",
        json!([[":!", ":cat!", ":cat!", ":!", [":", ":cat", ":cat", ":"]]]),
        true,
    );
    check(
        &action(
            r#"tail=capture_rest();return([tail.split(":")[-1].uppercase(),capture_rest().coalesce("bad").split(":")[-1].coalesce("bad")])"#,
            "0",
        ),
        "αβ:0",
        json!([["0", "0"]]),
        true,
    );
}

#[test]
fn initial_absence_empty_and_reversed_spans_keep_getter_policy() {
    check(
        r#"Top:: I {return([capture_slice().coalesce("missing").cat("!"),capture_from_rule_start().coalesce("alias").uppercase(),capture_rest().coalesce("bad").cat("!"),capture_slice_until_cursor().coalesce("bad").cat("!")])}"#,
        "x",
        json!(["missing!", "ALIAS", "x!", "!"]),
        false,
    );
    check(
        &action(
            r#"start_capture_slice();return([capture_slice().coalesce("reversed").cat("!"),capture_slice_pos()])"#,
            "cat",
        ),
        "αβ:cat",
        json!([["reversed!", 6]]),
        true,
    );
}

#[test]
fn legacy_first_consumer_and_with_result_keep_rust_policy() {
    check(
        &action(
            r#"order="";a=capture_rest().take({order=cat(order,"T");1});b=capture_rest().with() {return(["ok"])}.first().uppercase();return([a,b,order]);"#,
            "cat",
        ),
        "αβ:cat",
        json!([[[], "OK", "T"]]),
        true,
    );
}

#[test]
fn each_reader_retains_specific_function_state_error() {
    for helper in [
        "capture_slice",
        "capture_slice_until_cursor",
        "capture_rest",
        "capture_from_rule_start",
    ] {
        let source = format!(
            "fn forbidden(){{return({helper}().coalesce(\"M\").cat(\"!\"))}} Top:: I {{return(forbidden())}}"
        );
        for (route, result) in routes(&source, "x", false).into_iter().enumerate() {
            let error = result.expect_err("pure function must reject parser state");
            eprintln!("CAPTURE_TEXT_FENCE {helper} route{route} {error}");
            assert!(
                error.contains("user function 'forbidden'")
                    && error.contains("parser-state helper")
                    && error.contains(helper),
                "{error}"
            );
        }
    }
}

#[test]
fn callbacks_retain_existing_dynamic_context_and_function_fence() {
    check(
        r#"Top:: I {cb={||return(capture_rest().coalesce("bad").cat("!"))};return(cb())}"#,
        "x",
        json!("x!"),
        false,
    );
    let source = r#"fn apply(callback: codeblock){return(callback())} Top:: I {return(apply(){return(capture_rest().coalesce("bad").cat("!"))})}"#;
    for (route, result) in routes(source, "x", false).into_iter().enumerate() {
        let error = result.expect_err("callback inside a function must keep its state fence");
        eprintln!("CAPTURE_TEXT_CALLBACK_FENCE route{route} {error}");
        assert!(
            error.contains("user function 'apply'")
                && error.contains("parser-state helper")
                && error.contains("capture_rest"),
            "{error}"
        );
    }
}
