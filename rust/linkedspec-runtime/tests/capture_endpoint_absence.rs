//! TYPE-REFERENCE-BOOK.1.2.23.3.40.2 — unavailable versus empty capture endpoints.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

#[test]
fn capture_endpoints_require_an_available_local_match() {
    let fixtures: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/capture_endpoint_absence.json"
    ))
    .unwrap();
    let mut failures = Vec::new();
    for fixture in fixtures {
        let name = fixture["name"].as_str().unwrap();
        let source = fixture["source"].as_str().unwrap();
        let input = fixture["input"].as_str().unwrap();
        let parsed = parse_spec_with_user_functions(source).expect("parse endpoint source");
        validate(&parsed).expect("validate endpoint source");
        let compiled = compile(&parsed).expect("compile endpoint source");
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
                    "End" => "End",
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
                    "capture-endpoint-absence.spec",
                    GENERATED_SOURCE_CONTRACT,
                )
                .map_err(|error| error.to_string()),
            ),
        ];
        for (route, observed) in routes {
            if observed.as_ref() != Ok(&fixture["expected"]) {
                failures.push(format!(
                    "{name}/{route}: observed={observed:?}; expected={}",
                    fixture["expected"]
                ));
            }
        }
    }
    assert!(failures.is_empty(), "{}", failures.join("\n"));
}
