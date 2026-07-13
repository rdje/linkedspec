use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::Engine;
use linkedspec_runtime::unicode_case_mapping;
use serde::Deserialize;
use serde_json::{Value, json};

#[derive(Deserialize)]
struct Contract {
    contract_id: String,
    unicode_version: String,
    data_sha256: String,
    fixtures: Vec<Fixture>,
}

#[derive(Deserialize)]
struct Fixture {
    id: String,
    input: String,
    lower: String,
    upper: String,
}

fn contract() -> Contract {
    serde_json::from_str(include_str!(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/../../capability_conformance/unicode_case_contract.json"
    )))
    .expect("Unicode casing contract must decode")
}

fn execute_fixture(fixture: &Fixture) -> Value {
    let literal = serde_json::to_string(&fixture.input).expect("fixture string must encode");
    let grammar = format!(
        "Top::\n /x/ -> Done {{\n\
           set(lower_items, [{literal}])\n\
           lowercase_each(lower_items)\n\
           set(upper_items, [{literal}])\n\
           uppercase_each(upper_items)\n\
           return(array(lowercase({literal}), {literal}.lowercase(), uppercase({literal}), \
           {literal}.uppercase(), copy(lower_items), copy(upper_items)))\n\
         }}\n\nDone::\n /x/\n"
    );
    let spec = parse_spec(&grammar).unwrap_or_else(|error| panic!("{} parse: {error}", fixture.id));
    validate(&spec).unwrap_or_else(|error| panic!("{} validate: {error}", fixture.id));
    let compiled = compile(&spec).unwrap_or_else(|error| panic!("{} compile: {error}", fixture.id));
    let result = Engine::new(compiled)
        .execute("xx")
        .unwrap_or_else(|error| panic!("{} execute: {error}", fixture.id));
    serde_json::to_value(result).expect("runtime value must encode")
}

#[test]
fn generated_unicode_17_tables_and_all_runtime_paths_match_neutral_fixtures() {
    let contract = contract();
    assert_eq!(unicode_case_mapping::CONTRACT_ID, contract.contract_id);
    assert_eq!(
        unicode_case_mapping::UNICODE_VERSION,
        contract.unicode_version
    );
    assert_eq!(unicode_case_mapping::DATA_SHA256, contract.data_sha256);

    for fixture in &contract.fixtures {
        assert_eq!(
            unicode_case_mapping::lowercase(&fixture.input),
            fixture.lower,
            "{} direct lowercase",
            fixture.id
        );
        assert_eq!(
            unicode_case_mapping::uppercase(&fixture.input),
            fixture.upper,
            "{} direct uppercase",
            fixture.id
        );
        assert_eq!(
            execute_fixture(fixture),
            json!([[
                fixture.lower,
                fixture.lower,
                fixture.upper,
                fixture.upper,
                [fixture.lower],
                [fixture.upper],
            ]]),
            "{} helper, receiver, and array paths",
            fixture.id
        );
    }
}
