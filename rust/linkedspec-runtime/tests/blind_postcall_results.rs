//! TYPE-REFERENCE-BOOK.1.2.23.3.48.2.5 — blind returns complete an iteration.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    emit_rust_source_v2, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

#[test]
fn blind_postcall_returns_preserve_iteration_minimum_and_progress() {
    let fixtures: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/blind_postcall_results.json"
    ))
    .unwrap();
    let mut failures = Vec::new();
    let mut observations = Vec::new();
    for fixture in fixtures {
        let name = fixture["name"].as_str().unwrap();
        let source = fixture["source"].as_str().unwrap();
        let parsed = parse_spec_with_user_functions(source).expect("parse post-call source");
        validate(&parsed).expect("validate post-call source");
        let compiled = compile(&parsed).expect("compile post-call source");
        let serialized = serde_json::to_string(&compiled).unwrap();
        let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
        let plan: Vec<GeneratedPlanRow> = compiled
            .rules
            .iter()
            .map(|rule| GeneratedPlanRow {
                label: match rule.label.as_str() {
                    "Top" => "Top",
                    "Atom" => "Atom",
                    "Tail" => "Tail",
                    "Guard" => "Guard",
                    other => panic!("unexpected post-call fixture label: {other}"),
                },
                family: classify_generated_rule_family(rule).contract_name(),
            })
            .collect();
        let emitted = emit_rust_source_v2(&compiled, "rust-blind-postcall.spec").unwrap();
        let mut cases = Vec::new();
        for case in fixture["cases"].as_array().unwrap() {
            let input = case["input"].as_str().unwrap();
            let expected = &case["expected"];
            let native = Engine::new(compiled.clone())
                .execute_value_with_diagnostics(input, &ExecutionOptions::new());
            let loaded = Engine::new(restored.clone())
                .execute_value_with_diagnostics(input, &ExecutionOptions::new());
            let generated = execute_generated_parser_v2(
                &serialized,
                &plan,
                input,
                "rust-blind-postcall.spec",
                GENERATED_SOURCE_CONTRACT,
            );
            let routes = [
                ("native", serde_json::to_value(native).unwrap()),
                ("restored", serde_json::to_value(loaded).unwrap()),
                (
                    "plan",
                    serde_json::to_value(generated.map_err(|error| error.to_string())).unwrap(),
                ),
            ];
            for (route, result) in &routes {
                let matches = if let Some(record) = expected.get("error_record") {
                    let code = record["code"].as_str().unwrap();
                    if *route == "plan" {
                        result["Err"]
                            .as_str()
                            .is_some_and(|message| message.contains(code))
                    } else {
                        result["Err"]["diagnostic"]["code"] == record["code"]
                            && result["Err"]["diagnostic"]["rule_label"] == record["rule"]
                            && result["Err"]["diagnostic"]["stage"] == "runtime_execution"
                    }
                } else {
                    result.get("Ok") == Some(expected)
                };
                if !matches {
                    failures.push(format!(
                        "{name}/{input:?}/{route}: observed={result}; expected={expected}"
                    ));
                }
            }
            if expected.get("error_record").is_some()
                && std::env::var_os("LINKEDSPEC_RUST_BLIND_POSTCALL_INTAKE").is_some()
            {
                println!("RUST_BLIND_POSTCALL_TRACE_BEGIN {name}");
                let traced = Engine::new(compiled.clone()).execute_value_with_trace(
                    input,
                    &ExecutionOptions::new(),
                    linkedspec_runtime::trace::TraceConfig::enabled(
                        linkedspec_runtime::trace::TraceLevel::DEBUG,
                    ),
                );
                println!("RUST_BLIND_POSTCALL_TRACE_END {name} {traced:?}");
            }
            cases.push(json!({"input":input,"expected":expected,"routes":routes.into_iter().collect::<std::collections::BTreeMap<_,_>>() }));
        }
        observations.push(json!({"name":name,"source":source,"compiled":compiled,
            "serialized":serialized,"emitted":emitted,"cases":cases}));
    }
    if std::env::var_os("LINKEDSPEC_RUST_BLIND_POSTCALL_INTAKE").is_some() {
        let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("../../.linkedspec-data/verification/rust-blind-postcall-observations.json");
        std::fs::write(path, serde_json::to_vec_pretty(&observations).unwrap()).unwrap();
    }
    assert!(failures.is_empty(), "{}", failures.join("\n"));
}
