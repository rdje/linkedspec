//! TYPE-REFERENCE-BOOK.1.2.23.3.53.2 — structural-boundary result methods.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse boundary methods");
    validate(&parsed).expect("validate boundary methods");
    let compiled = compile(&parsed).expect("compile boundary methods");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Top" => "Top",
                "End" => "End",
                "Far" => "Far",
                "b" => "b",
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
            "boundary-capture-fluent.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}
fn check(source: &str, input: &str, expected: Value) {
    for (route, value) in routes(source, input).into_iter().enumerate() {
        eprintln!("BOUNDARY_CAPTURE route{route} {value:?}");
        assert_eq!(
            value.expect("execute boundary methods"),
            expected,
            "route{route}"
        );
    }
}
fn source(body: &str, end: &str) -> String {
    format!("Top::\n I {{{body}}}\nEnd:OR{{1,1}}\n /{end}/\nFar:OR{{1,1}}\n /TAIL/\n")
}
fn function_fence(program: &str, name: &str) {
    for (route, result) in routes(program, "αβ:ENDTAIL").into_iter().enumerate() {
        let error = result.expect_err("pure function must reject boundary state");
        eprintln!("BOUNDARY_CAPTURE_FENCE route{route} {error}");
        assert!(
            error.contains(&format!("user function '{name}'"))
                && error.contains("parser-state helper")
                && error.contains("capture_until_boundary"),
            "{error}"
        );
    }
}
#[test]
fn frozen_structural_boundary_target() {
    check(
        include_str!("../../../tests/fixtures/boundary_capture_fluent_values.spec"),
        "αβ:ENDTAIL",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/boundary_capture_fluent_values.json"
        ))
        .unwrap(),
    );
}
#[test]
fn primitive_bound_direct_and_number_retain_cursor_not_origin_effect() {
    for (body, expected) in [
        (
            r#"return([capture_until_boundary(End),cursor_pos(),capture_slice_pos()])"#,
            json!(["αβ:", 3, 0]),
        ),
        (
            r#"part=capture_until_boundary(End);return([part.coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])"#,
            json!(["αβ:!", 3, 0]),
        ),
        (
            r#"return([capture_until_boundary(End).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])"#,
            json!(["αβ:!", 3, 0]),
        ),
        (
            r#"return([capture_until_boundary(End).coalesce("").length().add(1),cursor_pos(),capture_slice_pos()])"#,
            json!([4, 3, 0]),
        ),
    ] {
        check(&source(body, "END"), "αβ:ENDTAIL", expected);
    }
}
#[test]
fn empty_missing_and_eof_keep_distinct_native_policies() {
    check(
        &source(
            r#"first=capture_until_boundary(End);order="";empty=capture_until_boundary(End).coalesce({order=cat(order,"F");"fallback"}).cat("!");return([first,empty,cursor_pos(),capture_slice_pos(),order])"#,
            "END",
        ),
        "αβ:ENDTAIL",
        json!(["αβ:", "!", 3, 0, ""]),
    );
    check(
        &source(
            r#"return([capture_until_boundary(Missing).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])"#,
            "END",
        ),
        "αβ:ENDTAIL",
        json!(["M!", 0, 0]),
    );
    check(
        &source(
            r#"return([capture_until_boundary(End).coalesce("").length().add(1),cursor_pos(),capture_slice_pos()])"#,
            "ZZZ",
        ),
        "αβ:ENDTAIL",
        json!([11, 10, 0]),
    );
}
#[test]
fn quoted_comma_and_multiple_labels_keep_atom_and_earliest_rules() {
    let quoted = source(
        r#"return([capture_until_boundary("a,b,c",End).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])"#,
        "END",
    ) + "\nb:OR{1,1}\n /αβ/\n";
    check(&quoted, "αβ:ENDTAIL", json!(["αβ:!", 3, 0]));
    check(
        &source(
            r#"return([capture_until_boundary(Far,End).coalesce("M").cat("!"),cursor_pos(),capture_slice_pos()])"#,
            "END",
        ),
        "αβ:ENDTAIL",
        json!(["αβ:!", 3, 0]),
    );
}
#[test]
fn boundary_source_keeps_specific_pure_function_state_error() {
    let program = "fn forbidden(){return(capture_until_boundary(End).coalesce(\"M\").cat(\"!\"))} "
        .to_owned()
        + &source("return(forbidden())", "END");
    function_fence(&program, "forbidden");
}
#[test]
fn callbacks_keep_caller_cursor_effect_and_function_invocation_fence() {
    check(
        &source(
            r#"cb={||return(capture_until_boundary(End).coalesce("M").cat("!"))};out=cb();return([out,cursor_pos(),capture_slice_pos()])"#,
            "END",
        ),
        "αβ:ENDTAIL",
        json!(["αβ:!", 3, 0]),
    );
    let program = "fn apply(callback: codeblock){return(callback())} ".to_owned()
        + &source(
            r#"return(apply(){return(capture_until_boundary(End).coalesce("M").cat("!"))})"#,
            "END",
        );
    function_fence(&program, "apply");
}
