use linkedspec_core::{compiler::compile, trace::{TraceConfig, TraceLevel}, validation::validate};
use linkedspec_runtime::{engine::{Engine, ExecutionOptions}, spec_parser::parse_spec_with_user_functions};
use serde_json::{Value, json};
use std::{fs, path::Path};

fn main() {
    let cases: Vec<Value> = serde_json::from_str(include_str!("../../cases.json")).unwrap();
    let output = std::env::args().nth(1).unwrap();
    let output = Path::new(&output);
    fs::create_dir_all(output.join("inputs")).unwrap();
    for case in cases {
        let id = case["id"].as_str().unwrap();
        let parsed = parse_spec_with_user_functions(case["source"].as_str().unwrap()).unwrap();
        validate(&parsed).unwrap();
        let compiled = compile(&parsed).unwrap();
        let serialized = serde_json::to_string(&compiled).unwrap();
        fs::write(output.join("inputs").join(format!("{id}.json")), &serialized).unwrap();
        println!("CALLABLE_PIPELINE_TRACE_INPUT {id} {}", json!({"compiled": serialized}));
        let path = output.join(format!("{id}.trace.log"));
        let trace = TraceConfig::enabled(TraceLevel::DEBUG)
            .with_trace_file(path.to_str().unwrap()).with_reset_file(true);
        let result = Engine::new(compiled).execute_value_with_trace(
            case["input"].as_str().unwrap(), &ExecutionOptions::new(), trace);
        let observed = match result {
            Ok(value) => json!({"value": value}),
            Err(error) => json!({"error": error}),
        };
        println!("CALLABLE_PIPELINE_TRACE {id} {observed}");
    }
}
