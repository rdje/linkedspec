//! TYPE-REFERENCE-BOOK.1.2.23.3.48.2.1 — typed blind fluent returns.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    emit_rust_source_v2, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

#[test]
fn blind_fluent_returns_evaluate_values_and_stop_the_chain() {
    let fixtures: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/blind_fluent_return_values.json"
    ))
    .unwrap();
    let mut failures = Vec::new();
    let mut observations = Vec::new();
    for fixture in fixtures {
        let name = fixture["name"].as_str().unwrap();
        let source = fixture["source"].as_str().unwrap();
        let input = fixture["input"].as_str().unwrap();
        let parsed = parse_spec_with_user_functions(source).expect("parse fluent return source");
        validate(&parsed).expect("validate fluent return source");
        let compiled = compile(&parsed).expect("compile fluent return source");
        let serialized = serde_json::to_string(&compiled).unwrap();
        let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
        let plan: Vec<GeneratedPlanRow> = compiled
            .rules
            .iter()
            .map(|rule| GeneratedPlanRow {
                // The public generated-plan API owns static labels. These are
                // the complete authored label set of this frozen fixture.
                label: match rule.label.as_str() {
                    "Top" => "Top",
                    "Child" => "Child",
                    other => panic!("unexpected endpoint fixture label: {other}"),
                },
                family: classify_generated_rule_family(rule).contract_name(),
            })
            .collect();
        let routes = [
            (
                "native",
                Engine::new(compiled.clone()).execute_value(input, &ExecutionOptions::new()),
            ),
            (
                "reconstructed",
                Engine::new(restored).execute_value(input, &ExecutionOptions::new()),
            ),
            (
                "plan",
                execute_generated_parser_v2(
                    &serialized,
                    &plan,
                    input,
                    "blind-fluent-return.spec",
                    GENERATED_SOURCE_CONTRACT,
                )
                .map_err(|error| error.to_string()),
            ),
        ];
        let emitted = emit_rust_source_v2(&compiled, "blind-fluent-return.spec").unwrap();
        let mut results = Vec::new();
        for (route, observed) in routes {
            results.push(json!({"route":route,"observed":observed}));
            if observed.as_ref() != Ok(&fixture["expected"]) {
                failures.push(format!(
                    "{name}/{route}: observed={observed:?}; expected={}",
                    fixture["expected"]
                ));
            }
        }
        observations.push(json!({"name":name,"compiled":compiled,"serialized":serialized,"emitted":emitted,"results":results}));
    }
    if std::env::var_os("LINKEDSPEC_BLIND_FLUENT_RETURN_INTAKE").is_some() {
        let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("../../.linkedspec-data/verification/rust-blind-fluent-return-observations.json");
        std::fs::write(path, serde_json::to_vec_pretty(&observations).unwrap()).unwrap();
    }
    assert!(failures.is_empty(), "{}", failures.join("\n"));
}
