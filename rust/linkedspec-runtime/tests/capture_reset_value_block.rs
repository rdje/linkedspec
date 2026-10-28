//! TYPE-REFERENCE-BOOK.1.2.23.3.35.2 — ordinary value-block reset statements.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn routes(source: &str) -> Value {
    let parsed = parse_spec_with_user_functions(source).expect("parse reset block");
    validate(&parsed).expect("validate reset block");
    let compiled = compile(&parsed).expect("compile reset block");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan = [
        GeneratedPlanRow {
            label: "Top",
            family: "default",
        },
        GeneratedPlanRow {
            label: "Value",
            family: "default",
        },
    ];
    let mut result = serde_json::Map::new();
    for (route, value) in [
        (
            "native",
            Engine::new(compiled)
                .execute_value("αβ:cat", &ExecutionOptions::new())
                .map_err(|e| e.to_string()),
        ),
        (
            "restored",
            Engine::new(restored)
                .execute_value("αβ:cat", &ExecutionOptions::new())
                .map_err(|e| e.to_string()),
        ),
        (
            "plan",
            execute_generated_parser_v2(
                &serialized,
                &plan,
                "αβ:cat",
                "capture-reset-value-block.spec",
                GENERATED_SOURCE_CONTRACT,
            )
            .map_err(|e| e.to_string()),
        ),
    ] {
        result.insert(
            route.to_string(),
            match value {
                Ok(value) => json!({"value":value}),
                Err(error) => json!({"error":error}),
            },
        );
    }
    Value::Object(result)
}
fn cases() -> Vec<(&'static str, &'static str)> {
    vec![
        (
            "without_reset",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");"!"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
"###,
        ),
        (
            "standalone",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");"!"});start_capture_slice();order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
"###,
        ),
        (
            "inside",
            include_str!("../../../tests/fixtures/capture_reset_value_block_values.spec"),
        ),
        (
            "alias_inside",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");capture_slice_here();"!"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
"###,
        ),
        (
            "return_before",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");return("!");start_capture_slice();order=cat(order,"T");"bad"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
"###,
        ),
        (
            "return_after",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");start_capture_slice();return("!");order=cat(order,"T");"bad"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
"###,
        ),
        (
            "lazy_skip",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";width=capture_rest_len();snapshot=width.coalesce({order=cat(order,"S");start_capture_slice();"bad"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
"###,
        ),
        (
            "direct_source",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {order="";snapshot=capture_rest_len().cat({order=cat(order,"S");start_capture_slice();"!"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])}
"###,
        ),
        (
            "function_start_capture_slice",
            r###"fn forbidden(){return("x".cat({start_capture_slice();"!"}))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {result=forbidden();return([result,capture_slice_pos()])}
"###,
        ),
        (
            "literal_start_capture_slice",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {cb={||return("x".cat({start_capture_slice();"!"}))};result=cb();return([result,capture_slice_pos()])}
"###,
        ),
        (
            "registered_start_capture_slice",
            r###"fn apply(callback: codeblock){return(callback())}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {result=apply(){return("x".cat({start_capture_slice();"!"}))};return([result,capture_slice_pos()])}
"###,
        ),
        (
            "function_capture_slice_here",
            r###"fn forbidden(){return("x".cat({capture_slice_here();"!"}))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {result=forbidden();return([result,capture_slice_pos()])}
"###,
        ),
        (
            "literal_capture_slice_here",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {cb={||return("x".cat({capture_slice_here();"!"}))};result=cb();return([result,capture_slice_pos()])}
"###,
        ),
        (
            "registered_capture_slice_here",
            r###"fn apply(callback: codeblock){return(callback())}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {result=apply(){return("x".cat({capture_slice_here();"!"}))};return([result,capture_slice_pos()])}
"###,
        ),
    ]
}
fn expect_value(label: &str, source: &str, expected: Value) {
    let observed = routes(source);
    eprintln!("CAPTURE_RESET {label} {observed}");
    for route in ["native", "restored", "plan"] {
        assert_eq!(
            observed[route],
            json!({"value": expected}),
            "{label} {route}"
        );
    }
}

#[test]
fn ordinary_blocks_preserve_snapshot_lazy_order_and_local_returns() {
    for (label, source) in cases() {
        let expected = match label {
            "without_reset" | "return_before" => json!([["4!", 2, 4, "SA"]]),
            "inside" => serde_json::from_str(include_str!(
                "../../../tests/fixtures/capture_reset_value_block_values.json"
            ))
            .unwrap(),
            "standalone" | "alias_inside" | "return_after" | "direct_source" => {
                json!([["4!", 6, 0, "SA"]])
            }
            "lazy_skip" => json!([[4, 2, 4, "A"]]),
            _ => continue,
        };
        expect_value(label, source, expected);
    }
}

#[test]
fn literal_callbacks_keep_existing_caller_parser_context() {
    for (label, source) in cases() {
        if label.starts_with("literal_") {
            expect_value(label, source, json!([["x!", 6]]));
        }
    }
}

#[test]
fn pure_function_and_registered_callback_fences_keep_authored_names() {
    for (label, source) in cases() {
        let function = if label.starts_with("function_") {
            "forbidden"
        } else if label.starts_with("registered_") {
            "apply"
        } else {
            continue;
        };
        let helper = label.split_once('_').unwrap().1;
        let observed = routes(source);
        eprintln!("CAPTURE_RESET_FENCE {label} {observed}");
        for route in ["native", "restored", "plan"] {
            let error = observed[route]["error"]
                .as_str()
                .expect("function must reject state");
            assert!(
                error.contains(&format!("user function '{function}'"))
                    && error.contains(&format!("parser-state helper '{helper}'"))
                    && error.contains("not supported in user functions"),
                "{label} {route}: {error}"
            );
            assert_eq!(
                error.starts_with("Generated Rust parser execution failed: "),
                route == "plan"
            );
        }
    }
}
