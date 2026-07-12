use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::Engine;
use serde_json::{Value, json};

fn contract() -> Value {
    serde_json::from_str(include_str!(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/../../capability_conformance/scalar_numeric_contract.json"
    )))
    .expect("scalar numeric contract must decode")
}

#[test]
fn scalar_numeric_v1_matches_all_neutral_cases() {
    let contract = contract();
    assert_eq!(contract["format"], 1);
    assert_eq!(contract["contract_id"], "linkedspec-scalar-numeric-v1");
    assert_eq!(contract["cases"].as_array().map(Vec::len), Some(55));

    let source = contract["spec_source"]
        .as_str()
        .expect("contract spec_source must be text");
    let spec = parse_spec(source).expect("contract spec must parse");
    validate(&spec).expect("contract spec must validate");
    let compiled = compile(&spec).expect("contract spec must compile");
    let result = Engine::new(compiled)
        .execute("xx")
        .expect("contract spec must execute");
    assert_eq!(result, json!([contract["expected"].clone()]));
}
