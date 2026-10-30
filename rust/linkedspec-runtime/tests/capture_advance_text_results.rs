//! TYPE-REFERENCE-BOOK.1.2.23.3.51.2 — advancing capture String composition.
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
            "capture-advance-text.spec",
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
fn frozen_advancing_capture_string_target() {
    check(
        include_str!("../../../tests/fixtures/capture_advance_text_values.spec"),
        "αβ:catTAIL",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/capture_advance_text_values.json"
        ))
        .unwrap(),
        true,
    );
}

#[test]
fn native_and_bound_sources_retain_distinct_capture_origin_endpoints() {
    for (helper, text, origin) in [
        ("capture_take", ":", 6),
        ("capture_take_until_cursor", ":cat", 6),
        ("capture_take_rest", ":catTAIL", 10),
    ] {
        check(
            &action(
                &format!(
                    "part={helper}();return([part.coalesce(\"M\").cat(\"!\"),capture_slice_pos(),cursor_pos()])"
                ),
                "cat",
            ),
            "αβ:catTAIL",
            json!([[format!("{text}!"), origin, 6]]),
            true,
        );
    }
}

#[test]
fn missing_empty_string_zero_and_number_links_preserve_effect_order() {
    check(
        r#"Top:: I {return([capture_take().coalesce("M").cat("!"),capture_slice_pos(),cursor_pos()])}"#,
        "x",
        json!(["M!", 0, 0]),
        false,
    );
    check(
        &action(
            r#"first=capture_take_until_cursor();order="";empty=capture_take_until_cursor().coalesce({order=cat(order,"F");"fallback"}).cat("!");missing=capture_take().coalesce("M").cat("!");return([first,empty,missing,capture_slice_pos(),cursor_pos(),order])"#,
            "cat",
        ),
        "αβ:catTAIL",
        json!([[":cat", "!", "M!", 6, 6, ""]]),
        true,
    );
    check(
        &action(
            r#"return([capture_take_until_cursor().coalesce("M").split(":")[-1].coalesce("bad"),capture_slice_pos(),cursor_pos()])"#,
            "0",
        ),
        "αβ:0TAIL",
        json!([["0", 4, 4]]),
        true,
    );
    check(
        &action(
            r#"return([capture_take_rest().coalesce("M").length().add(1),capture_slice_pos(),cursor_pos()])"#,
            "cat",
        ),
        "αβ:catTAIL",
        json!([[9, 10, 6]]),
        true,
    );
}

#[test]
fn named_capture_take_overload_keeps_its_separate_mark_effect() {
    check(
        &action(
            r#"mark_capture_slice(begin);out=capture_take(begin).coalesce("M").cat("!");return([out,mark_pos(begin),capture_slice_pos(),cursor_pos()])"#,
            "cat",
        ),
        "αβ:catTAIL",
        json!([[":!", 6, 2, 6]]),
        true,
    );
}

#[test]
fn advancing_sources_keep_specific_function_state_errors() {
    for helper in [
        "capture_take",
        "capture_take_until_cursor",
        "capture_take_rest",
    ] {
        let source = format!(
            "fn forbidden(){{return({helper}().coalesce(\"M\").cat(\"!\"))}} Top:: I {{return(forbidden())}}"
        );
        for (route, result) in routes(&source, "x", false).into_iter().enumerate() {
            let error = result.expect_err("function must reject parser state");
            eprintln!("CAPTURE_ADVANCE_FENCE {helper} route{route} {error}");
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
fn callbacks_keep_caller_capture_effects_and_function_invocation_fence() {
    check(
        r#"Top:: I {cb={||return(capture_take_rest().coalesce("M").cat("!"))};out=cb();return([out,capture_slice_pos(),cursor_pos()])}"#,
        "abc",
        json!(["abc!", 3, 0]),
        false,
    );
    let source = r#"fn apply(callback: codeblock){return(callback())} Top:: I {return(apply(){return(capture_take_rest().coalesce("M").cat("!"))})}"#;
    for (route, result) in routes(source, "abc", false).into_iter().enumerate() {
        let error = result.expect_err("callback invoked inside function keeps state fence");
        eprintln!("CAPTURE_ADVANCE_CALLBACK_FENCE route{route} {error}");
        assert!(
            error.contains("user function 'apply'")
                && error.contains("parser-state helper")
                && error.contains("capture_take_rest"),
            "{error}"
        );
    }
}
