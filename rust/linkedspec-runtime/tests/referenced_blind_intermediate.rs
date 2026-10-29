//! TYPE-REFERENCE-BOOK.1.2.23.3.48.2 — compile ownership for regex-free targets.
use linkedspec_core::{compiler::compile, validation::validate};
use linkedspec_runtime::source_emitter::emit_rust_source_v2;
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

#[test]
fn regex_free_intermediates_preserve_action_slot_ownership() {
    let fixtures: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/referenced_blind_intermediate.json"
    ))
    .unwrap();
    for fixture in fixtures {
        let name = fixture["name"].as_str().unwrap();
        let source = fixture["source"].as_str().unwrap();
        let parsed = parse_spec_with_user_functions(source).expect("parse ownership source");
        let result = validate(&parsed)
            .map_err(|error| format!("{error:?}"))
            .and_then(|()| compile(&parsed).map_err(|error| format!("{error:?}")));
        assert_eq!(
            result.is_ok(),
            fixture["expected_builds"].as_bool().unwrap(),
            "{name}: {result:?}"
        );
        match result {
            Ok(compiled) => {
                emit_rust_source_v2(&compiled, "referenced-intermediate.spec")
                    .expect("emit valid blind/direct/action ownership source");
            }
            Err(error) => {
                let expected = if name == "indexed_action_no_regex" {
                    "regex_slot_index_out_of_range"
                } else {
                    "regex_slot_identity_invalid"
                };
                assert!(error.contains(expected), "{name}: {error}");
                assert!(error.contains("Middle"), "{name}: {error}");
            }
        }
    }
}
