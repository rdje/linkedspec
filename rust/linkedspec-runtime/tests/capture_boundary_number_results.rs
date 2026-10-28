//! TYPE-REFERENCE-BOOK.1.2.23.3.33.2 — readonly capture Number composition.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
fn routes(source: &str, input: &str, child: bool) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse capture Number");
    validate(&parsed).expect("validate capture Number");
    let compiled = compile(&parsed).expect("compile capture Number");
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
            "capture-boundary-number.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ]
}
fn check(source: &str, input: &str, expected: Value, child: bool) {
    for (route, value) in routes(source, input, child).into_iter().enumerate() {
        eprintln!("CAPTURE_NUMBER route{route} {value:?}");
        assert_eq!(
            value.expect("execute capture Number"),
            expected,
            "route{route}"
        );
    }
}
fn action(action: &str) -> String {
    format!(
        "Top::\n -> Value .push\n LX {{return(copy(Top))}}\nValue:\n /(?<head>αβ)/\n /:/\n /cat/\n -> Value[2] {{{action}}}\n"
    )
}
#[test]
fn frozen_readonly_capture_number_target() {
    check(
        include_str!("../../../tests/fixtures/capture_boundary_number_values.spec"),
        "αβ:cat",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/capture_boundary_number_values.json"
        ))
        .unwrap(),
        true,
    );
}
#[test]
fn original_getters_aliases_and_bound_snapshot() {
    check(
        &action(
            r#"order="";
original=[capture_slice_len(),capture_slice_pos(),capture_slice_line(),capture_slice_col(),capture_slice_until_cursor_len(),capture_rest_len(),capture_slice_length(),capture_len_from_rule_start(),capture_rest_length()];
width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");"!"});start_capture_slice();
return([original,snapshot,capture_slice_pos(),order]);"#,
        ),
        "αβ:cat",
        json!([[[1, 2, 1, 3, 4, 4, 1, 1, 4], "4!", 6, "S"]]),
        true,
    );
}
#[test]
fn capture_reader_function_fence_stays_specific_under_consumers() {
    let source = r#"fn forbidden(){return(capture_rest_len().coalesce(0).cat("!").split("!")[0].uppercase())}
Top:: I {return(forbidden())}"#;
    for result in routes(source, "x", false) {
        let error = result.expect_err("function must reject parser state");
        eprintln!("CAPTURE_NUMBER_FENCE {error}");
        assert!(
            error.contains("parser-state helper") && error.contains("capture_rest_len"),
            "{error}"
        );
    }
}
#[test]
fn legacy_first_consumers_keep_the_actual_rust_policy() {
    check(
        &action(
            r#"order="";a=capture_rest_len().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=capture_rest_len().take({order=cat(order,"T");1});return([a,b,order]);"#,
        ),
        "αβ:cat",
        json!([[4, [], "KVT"]]),
        true,
    );
}
#[test]
fn callback_sources_keep_their_dynamic_caller_context() {
    check(
        r#"Top:: I {cb={||return(capture_rest_len().coalesce(0).cat("!"))};return(cb())}"#,
        "x",
        json!("1!"),
        false,
    );
    let source = r#"fn apply(callback: codeblock){return(callback())} Top:: I {return(apply(){return(capture_rest_len().coalesce(0).cat("!"))})}"#;
    for result in routes(source, "x", false) {
        let error = result.expect_err("callback invoked inside function keeps that function fence");
        eprintln!("CAPTURE_NUMBER_CALLBACK_FENCE {error}");
        assert!(
            error.contains("user function 'apply'")
                && error.contains("parser-state helper")
                && error.contains("capture_rest_len"),
            "{error}"
        );
    }
}
// TYPE-REFERENCE-BOOK.1.2.23.3.36.1 — active-edge dispatch prerequisite repaired.
#[test]
fn outgoing_edge_dispatch_ignores_untargeted_declarations() {
    let source = action(r#"return("BODY")"#).replace("(?<head>αβ)", "(?<head>..)");
    check(&source, "αβ:cat", json!(["BODY"]), true);
}
