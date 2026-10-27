//! TYPE-REFERENCE-BOOK.1.2.23.3.30.2 — frozen Number reader composition.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
fn routes(source: &str, input: &str, child: bool) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse Number reader");
    validate(&parsed).expect("validate Number reader");
    let compiled = compile(&parsed).expect("compile Number reader");
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
            "entry-match-number-results.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ]
}
fn check(source: &str, input: &str, expected: Value, child: bool) {
    for (route, value) in routes(source, input, child).into_iter().enumerate() {
        eprintln!("NUMBER_READER route{route} {value:?}");
        assert_eq!(
            value.expect("execute Number reader"),
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
fn unchanged_frozen_number_reader_target() {
    check(
        include_str!("../../../tests/fixtures/entry_match_number_result_values.spec"),
        "name=Alpha",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/entry_match_number_result_values.json"
        ))
        .unwrap(),
        true,
    );
}
#[test]
fn absent_match_number_uses_one_lazy_fallback() {
    check(
        "Top:: I {order=\"\";return([match_len().coalesce({order=cat(order,\"F\");7}).add(1),order])}",
        "x",
        json!([8, "F"]),
        false,
    );
}
#[test]
fn legacy_first_consumers_and_normalized_prefixes_keep_their_policy() {
    check(
        &action(
            r#"order="";result=match_len().add(0).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([match_len().set_key("k",1),entry_len().take(1),result,order]);"#,
        ),
        "name=Alpha",
        json!([[5, [], null, ""]]),
        true,
    );
}
#[test]
fn number_reader_function_fence_stays_specific() {
    let source = "fn forbidden(){return(entry_len())}\nTop:: I {return(forbidden())}";
    for result in routes(source, "x", false) {
        let error = result.expect_err("pure function must reject parser state");
        assert!(
            error.contains("parser-state helper") && error.contains("entry_len"),
            "{error}"
        );
    }
}
