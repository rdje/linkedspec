//! TYPE-REFERENCE-BOOK.1.2.23.3.48.2.3 — qualified written edge ownership for regex-free targets.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    emit_rust_source_v2, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

#[test]
fn qualified_regex_free_intermediates_follow_written_edge_ownership() {
    let fixtures: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/referenced_blind_intermediate_qualified.json"
    ))
    .unwrap();
    let mut failures = Vec::new();
    let mut observations = Vec::new();
    for fixture in fixtures {
        let name = fixture["name"].as_str().unwrap();
        let source = fixture["source"].as_str().unwrap();
        let pipeline = (|| {
            let parsed = parse_spec_with_user_functions(source)
                .map_err(|error| format!("parse: {error:?}"))?;
            validate(&parsed).map_err(|error| format!("validate: {error:?}"))?;
            compile(&parsed).map_err(|error| format!("compile: {error:?}"))
        })();
        if pipeline.is_ok() != fixture["expected_builds"].as_bool().unwrap() {
            failures.push(format!("{name}: unexpected build result {pipeline:?}"));
        }
        let compiled = match pipeline {
            Ok(compiled) => compiled,
            Err(error) => {
                observations.push(json!({"name": name, "build_error": error}));
                continue;
            }
        };
        let serialized = serde_json::to_string(&compiled).unwrap();
        let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
        let plan: Vec<GeneratedPlanRow> = compiled
            .rules
            .iter()
            .map(|rule| GeneratedPlanRow {
                // Static labels are required by the public plan API. This is
                // the complete label set of the authored fixture, not a leak.
                label: match rule.label.as_str() {
                    "Top" => "Top",
                    "Middle" => "Middle",
                    "Value" => "Value",
                    other => panic!("unexpected fixture label: {other}"),
                },
                family: classify_generated_rule_family(rule).contract_name(),
            })
            .collect();
        let emitted = emit_rust_source_v2(&compiled, "referenced-intermediate-qualified.spec")
            .expect("emit valid ownership source");
        let mut results = Vec::new();
        for case in fixture["cases"].as_array().unwrap() {
            let input = case["input"].as_str().unwrap();
            let routes = [
                (
                    "native",
                    Engine::new(compiled.clone()).execute_value(input, &ExecutionOptions::new()),
                ),
                (
                    "reconstructed",
                    Engine::new(restored.clone()).execute_value(input, &ExecutionOptions::new()),
                ),
                (
                    "plan",
                    execute_generated_parser_v2(
                        &serialized,
                        &plan,
                        input,
                        "referenced-intermediate-qualified.spec",
                        GENERATED_SOURCE_CONTRACT,
                    )
                    .map_err(|error| error.to_string()),
                ),
            ];
            for (route, observed) in routes {
                if observed.as_ref() != Ok(&case["expected"]) {
                    failures.push(format!(
                        "{name}/{route}: {observed:?}; expected={}",
                        case["expected"]
                    ));
                }
                results.push(json!({"route": route, "observed": observed}));
            }
        }
        observations.push(json!({"name": name, "compiled": compiled,
            "serialized": serialized, "emitted": emitted, "results": results}));
    }
    // Optional retained intake uses the exact ordinary consumer. Normal test
    // runs have no artifact side effect; paths derive from the repository root.
    if std::env::var_os("LINKEDSPEC_REFERENCED_QUALIFIED_INTAKE").is_some() {
        let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join(
            "../../.linkedspec-data/verification/rust-referenced-qualified-observations.json",
        );
        std::fs::write(path, serde_json::to_vec_pretty(&observations).unwrap()).unwrap();
    }
    assert!(failures.is_empty(), "{}", failures.join("\n"));
}
