use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    emit_rust_source_v2, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
use std::{fs, path::Path};

fn value_row(result: Result<Value, String>) -> Value {
    match result {
        Ok(value) => json!({"value": value}),
        Err(error) => json!({"error": error}),
    }
}

fn observe(
    row: &Value,
    fresh: &Path,
    library: &mut String,
    main: &mut String,
) -> Result<Value, String> {
    let id = row["id"].as_str().unwrap();
    assert!(id.chars().all(|c| c.is_ascii_alphanumeric() || c == '_'));
    let input = row["input"].as_str().unwrap();
    let parsed = parse_spec_with_user_functions(row["source"].as_str().unwrap())
        .map_err(|error| format!("parse: {error:?}"))?;
    validate(&parsed).map_err(|error| format!("validate: {error:?}"))?;
    let compiled = compile(&parsed).map_err(|error| format!("compile: {error:?}"))?;
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    fs::create_dir_all(fresh.join("inputs")).unwrap();
    fs::write(fresh.join("inputs").join(format!("{id}.json")), &serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Value" => "Value",
                other => panic!("unexpected rule: {other}"),
            },
            family: classify_generated_rule_family(rule).contract_name(),
        })
        .collect();
    let emitted = emit_rust_source_v2(&compiled, &format!("array-transform-result/{id}.spec"))
        .map_err(|error| format!("emit: {error}"))?;
    fs::write(
        fresh.join("src/generated").join(format!("{id}.rs")),
        emitted,
    )
    .unwrap();
    library.push_str(&format!(
        "#[path = \"generated/{id}.rs\"] pub mod case_{id};\n"
    ));
    let input_literal = serde_json::to_string(input).unwrap();
    main.push_str(&format!(
        "let result = array_transform_result_rust_fresh::case_{id}::execute({input_literal});\nlet observed = match result {{ Ok(value) => serde_json::json!({{\"value\": value}}), Err(error) => serde_json::json!({{\"error\": error.to_string()}}) }};\nprintln!(\"ARRAY_TRANSFORM_RUST_FRESH {id} {{}}\", observed);\n"
    ));
    println!(
        "ARRAY_TRANSFORM_RUST_INPUT {id} {}",
        json!({"compiled": serialized})
    );
    Ok(json!({
        "native": value_row(Engine::new(compiled)
            .execute_value(input, &ExecutionOptions::new()).map_err(|error| error.to_string())),
        "restored": value_row(Engine::new(restored)
            .execute_value(input, &ExecutionOptions::new()).map_err(|error| error.to_string())),
        "plan": value_row(execute_generated_parser_v2(&serialized, &plan, input,
            "array-transform-result-assessment.spec", GENERATED_SOURCE_CONTRACT)
            .map_err(|error| error.to_string())),
    }))
}

fn main() {
    let cases: Vec<Value> = serde_json::from_str(include_str!("../../cases.json")).unwrap();
    let target = std::env::args()
        .nth(1)
        .expect("repository-relative emitted project path");
    let fresh = Path::new(&target);
    fs::create_dir_all(fresh.join("src/generated")).unwrap();
    let mut library = String::new();
    let mut main = String::from("fn main() {\n");
    for row in &cases {
        let actual = match observe(row, fresh, &mut library, &mut main) {
            Ok(value) => value,
            Err(error) => json!({"preparation_error": error}),
        };
        println!("ARRAY_TRANSFORM_RUST {} {}", row["id"].as_str().unwrap(), actual);
    }
    main.push_str("}\n");
    fs::write(fresh.join("src/lib.rs"), library).unwrap();
    fs::write(fresh.join("src/main.rs"), main).unwrap();
}
