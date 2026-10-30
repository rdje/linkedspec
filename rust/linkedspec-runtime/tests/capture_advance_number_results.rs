//! TYPE-REFERENCE-BOOK.1.2.23.3.52.2 — advancing capture Number composition.
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
            "capture-advance-number.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ]
}

fn check(source: &str, input: &str, expected: Value, child: bool) {
    for (route, value) in routes(source, input, child).into_iter().enumerate() {
        eprintln!("CAPTURE_ADVANCE_NUMBER route{route} {value:?}");
        assert_eq!(
            value.expect("execute capture Number"),
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
fn frozen_advancing_capture_number_target() {
    check(
        include_str!("../../../tests/fixtures/capture_advance_number_values.spec"),
        "αβ:catTAIL",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/capture_advance_number_values.json"
        ))
        .unwrap(),
        true,
    );
}

#[test]
fn bound_sources_retain_distinct_width_and_origin_endpoints() {
    for (helper, width, origin) in [
        ("capture_take_len", 1, 6),
        ("capture_take_until_cursor_len", 4, 6),
        ("capture_take_rest_len", 8, 10),
    ] {
        check(
            &action(
                &format!(
                    "part={helper}();return([part.coalesce(99).add(1).cat(\"!\"),capture_slice_pos(),cursor_pos()])"
                ),
                "cat",
            ),
            "αβ:catTAIL",
            json!([[format!("{}!", width + 1), origin, 6]]),
            true,
        );
    }
}

#[test]
fn missing_zero_reversed_and_snapshot_keep_native_effect_order() {
    check(
        r#"Top:: I {return([capture_take_len().coalesce(99).cat("!"),capture_slice_pos(),cursor_pos()])}"#,
        "x",
        json!(["99!", 0, 0]),
        false,
    );
    check(
        &action(
            r#"first=capture_take_until_cursor_len();order="";zero=capture_take_until_cursor_len().coalesce({order=cat(order,"F");99}).add(1);missing=capture_take_len().coalesce(99).cat("!");return([first,zero,missing,capture_slice_pos(),cursor_pos(),order])"#,
            "cat",
        ),
        "αβ:catTAIL",
        json!([[4, 1, "99!", 6, 6, ""]]),
        true,
    );
    check(
        &action(
            r#"width=capture_take_rest_len().coalesce(0);snapshot=width.cat({start_capture_slice();"!"});return([width,snapshot,capture_slice_pos(),cursor_pos()])"#,
            "cat",
        ),
        "αβ:catTAIL",
        json!([[8, "8!", 6, 6]]),
        true,
    );
}

#[test]
fn named_width_source_retains_separate_mark_effects() {
    check(
        &action(
            r#"mark_capture_slice(begin);out=capture_take_len_from(begin).coalesce(99).add(1).cat("!");return([out,mark_pos(begin),capture_slice_pos(),cursor_pos()])"#,
            "cat",
        ),
        "αβ:catTAIL",
        json!([["2!", 6, 2, 6]]),
        true,
    );
}

#[test]
fn all_advancing_number_sources_keep_specific_function_state_errors() {
    for helper in [
        "capture_take_len",
        "capture_take_until_cursor_len",
        "capture_take_rest_len",
    ] {
        let source = format!(
            "fn forbidden(){{return({helper}().coalesce(99).add(1))}} Top:: I {{return(forbidden())}}"
        );
        for (route, result) in routes(&source, "x", false).into_iter().enumerate() {
            let error = result.expect_err("function must reject parser state");
            eprintln!("CAPTURE_ADVANCE_NUMBER_FENCE {helper} route{route} {error}");
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
fn callbacks_keep_caller_origin_update_and_function_invocation_fence() {
    check(
        r#"Top:: I {cb={||return(capture_take_rest_len().coalesce(99).add(1))};out=cb();return([out,capture_slice_pos(),cursor_pos()])}"#,
        "abc",
        json!([4, 3, 0]),
        false,
    );
    let source = r#"fn apply(callback: codeblock){return(callback())} Top:: I {return(apply(){return(capture_take_rest_len().coalesce(99).add(1))})}"#;
    for (route, result) in routes(source, "abc", false).into_iter().enumerate() {
        let error = result.expect_err("function-invoked callback keeps parser-state fence");
        eprintln!("CAPTURE_ADVANCE_NUMBER_CALLBACK_FENCE route{route} {error}");
        assert!(
            error.contains("user function 'apply'")
                && error.contains("parser-state helper")
                && error.contains("capture_take_rest_len"),
            "{error}"
        );
    }
}
