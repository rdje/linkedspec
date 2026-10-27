//! TYPE-REFERENCE-BOOK.1.2.23.3.29.2.2 — accepted pure-function parser-state ban.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::json;

fn routes(source: &str) -> Vec<Result<serde_json::Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse source");
    validate(&parsed).expect("validate source");
    let compiled = compile(&parsed).expect("compile source");
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
    vec![
        Engine::new(compiled)
            .execute_value("name=Alpha", &ExecutionOptions::new())
            .map_err(|e| e.to_string()),
        Engine::new(restored)
            .execute_value("name=Alpha", &ExecutionOptions::new())
            .map_err(|e| e.to_string()),
        execute_generated_parser_v2(
            &serialized,
            &plan,
            "name=Alpha",
            "function-state-boundary.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}
fn source(definitions: &str, action: &str) -> String {
    format!(
        "{definitions}\nTop::\n -> Value .push\n LX {{return(copy(Top))}}\nValue:\n /(?<head>name)/\n /=/\n /(?<value>Alpha)/\n -> Value[2] {{{action}}}\n"
    )
}
fn reject(helper: &str, expression: &str) {
    let source = source(
        &format!("fn forbidden(){{return({expression})}}"),
        "return(forbidden())",
    );
    for (route, result) in routes(&source).into_iter().enumerate() {
        let error = result.expect_err(&format!("route{route} must reject {helper}"));
        assert!(
            error.contains("parser-state helper") && error.contains(helper),
            "route{route}: {error}"
        );
    }
}
#[test]
fn capture_collection_and_group_readers_cannot_read_caller_state() {
    for helper in [
        "entry_groups",
        "match_groups",
        "entry_map",
        "match_map",
        "entry_named_map",
        "match_named_map",
        "entry_group",
        "match_group",
    ] {
        reject(
            helper,
            &format!(
                "{helper}({})",
                if helper.ends_with("group") { "0" } else { "" }
            ),
        );
    }
}
#[test]
fn input_position_and_capture_roles_retain_the_function_boundary() {
    for (helper, expression) in [
        ("input_text", "input_text()"),
        ("cursor_pos", "cursor_pos()"),
        ("entry_start_pos", "entry_start_pos()"),
        ("mark_pos", "mark_pos(point)"),
        ("capture_slice", "capture_slice()"),
        ("save_cursor", "save_cursor(point)"),
    ] {
        reject(helper, expression);
    }
}
#[test]
fn nested_and_discarded_parser_reads_reject() {
    let source = source(
        "fn inner(){return(entry_groups())}\nfn outer(){match_map();return(inner())}",
        "return(outer())",
    );
    for result in routes(&source) {
        let error = result.expect_err("discarded parser reader must reject");
        assert!(
            error.contains("parser-state helper") && error.contains("match_map"),
            "{error}"
        );
    }
}
#[test]
fn explicit_caller_values_locals_and_prefix_named_functions_remain_valid() {
    let source = source(
        "fn entry_custom(text){local_text=text.uppercase();return(local_text)}\nfn capture_custom(text){return(entry_custom(text))}",
        "return([capture_custom(entry_group(0)),capture_custom(match_named(\"value\")),entry_groups().last().uppercase(),match_map()[\"value\"].uppercase()])",
    );
    for result in routes(&source) {
        assert_eq!(
            result.expect("pure value function"),
            json!([["NAME", "ALPHA", "NAME", "ALPHA"]])
        );
    }
}
