//! TYPE-REFERENCE-BOOK.1.2.23.3.39.1.4.2 — implicit blind collections.
use linkedspec_core::{compiler::compile, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    emit_rust_source_v2, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

#[test]
fn blind_repetition_preserves_child_values_groups_and_lifecycle_authority() {
    let fixtures: Vec<Value> =
        serde_json::from_str(include_str!("fixtures/blind_repetition_collection.json")).unwrap();
    let mut observations = Vec::new();
    for row in fixtures {
        let name = row["name"].as_str().unwrap();
        let source = row["source"].as_str().unwrap();
        let parsed = parse_spec_with_user_functions(source).unwrap();
        validate(&parsed).unwrap();
        let compiled = compile(&parsed).unwrap();
        let serialized = serde_json::to_string(&compiled).unwrap();
        let plan: Vec<_> = compiled
            .rules
            .iter()
            .map(|rule| GeneratedPlanRow {
                label: match rule.label.as_str() {
                    "Top" => "Top",
                    "First" => "First",
                    "Second" => "Second",
                    label => panic!("unowned blind label {label}"),
                },
                family: classify_generated_rule_family(rule).contract_name(),
            })
            .collect();
        let emitted = emit_rust_source_v2(&compiled, "blind-collection.spec").unwrap();
        eprintln!(
            "RUST_BLIND_COLLECTION_INPUT {name} {}",
            json!({"source":source,"serialized":serialized,"plan":plan,"emitted":emitted})
        );
        let loaded = Engine::new(serde_json::from_str(&serialized).unwrap());
        let engine = Engine::new(compiled);
        for case in row["cases"].as_array().unwrap() {
            let input = case["input"].as_str().unwrap();
            let routes = [
                engine.execute_value(input, &ExecutionOptions::new()),
                loaded.execute_value(input, &ExecutionOptions::new()),
                execute_generated_parser_v2(
                    &serialized,
                    &plan,
                    input,
                    "blind-collection.spec",
                    GENERATED_SOURCE_CONTRACT,
                )
                .map_err(|error| error.to_string()),
            ];
            eprintln!(
                "RUST_BLIND_COLLECTION_ACTUAL {name} {}",
                json!({"input":input,"expected":case["expected"],"routes":routes})
            );
            observations.push((
                name.to_owned(),
                input.to_owned(),
                case["expected"].clone(),
                routes,
            ));
        }
    }
    // Reach every authored source/carrier before the first result assertion.
    for (name, input, expected, routes) in observations {
        for (route, result) in routes.into_iter().enumerate() {
            assert_eq!(
                result,
                Ok(expected.clone()),
                "{name} {input:?} route{route}"
            );
        }
    }
}
