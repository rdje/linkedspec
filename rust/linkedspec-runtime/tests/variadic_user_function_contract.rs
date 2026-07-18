//! FUTURE-PARITY-BACKLOG.4.2.2 — neutral variadic user-function contract.

use linkedspec_core::compiler::compile;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::Engine;
use linkedspec_runtime::source_emitter::{
    GeneratedPlanRow, classify_generated_rule_family, emit_rust_source, execute_generated_parser,
};
use linkedspec_runtime::spec_parser::{
    parse_spec_with_user_functions, parse_user_function_definition_asts,
};
use serde_json::{Value, json};
use std::collections::BTreeSet;

fn contract() -> Value {
    serde_json::from_str(include_str!(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/../../capability_conformance/callable_signature_contract.json"
    )))
    .expect("callable signature contract must be valid JSON")
}

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse variadic fixture");
    validate(&parsed).expect("validate variadic fixture");
    compile(&parsed).expect("compile variadic fixture")
}

fn fixture_source() -> String {
    contract()["fixture"]["spec_source"]
        .as_str()
        .expect("fixture spec_source")
        .to_string()
}

#[test]
fn definition_parser_emits_exact_v1_and_v2_signature_unions() {
    let asts = parse_user_function_definition_asts(&fixture_source()).expect("definition ASTs");
    assert_eq!(asts.len(), 3);

    let fixed = asts[0].as_object().expect("fixed record");
    assert_eq!(fixed["version"], 1);
    assert_eq!(fixed["params"], json!(["left", "right"]));
    assert_eq!(fixed["arity"], 2);
    assert!(!fixed.contains_key("signature"));

    for (node, name, positional, rest, minimum) in [
        (&asts[1], "all_values", json!([]), "items", 0),
        (&asts[2], "collect", json!(["prefix"]), "items", 1),
    ] {
        let record = node.as_object().expect("variadic record");
        assert_eq!(record["version"], 2, "{name}");
        assert_eq!(record["name"], name, "{name}");
        assert!(!record.contains_key("params"), "{name}");
        assert!(!record.contains_key("arity"), "{name}");
        assert_eq!(record["signature"]["kind"], "callable_signature");
        assert_eq!(record["signature"]["version"], 1);
        assert_eq!(record["signature"]["positional_params"], positional);
        assert_eq!(record["signature"]["rest_param"], rest);
        assert_eq!(record["signature"]["min_arity"], minimum);
        assert!(record["signature"]["max_arity"].is_null());
        for staged in ["body_payload", "body_parse_job"] {
            assert_eq!(record[staged]["signature"], record["signature"], "{name}");
            assert!(record[staged].get("params").is_none(), "{name}");
            assert!(record[staged].get("arity").is_none(), "{name}");
        }
    }
}

#[test]
fn compiled_descriptor_uses_the_contract_v2_record_shape() {
    let compiled = compile_source(&fixture_source());
    let descriptor = compiled.to_descriptor_json().unwrap();
    let expected_keys = contract()["definition_versions"]["variadic"]["record_fields"]
        .as_array()
        .unwrap()
        .iter()
        .map(|value| value.as_str().unwrap().to_string())
        .collect::<BTreeSet<_>>();

    for name in ["all_values", "collect"] {
        let record = descriptor["functions"][name].as_object().unwrap();
        assert_eq!(
            record.keys().cloned().collect::<BTreeSet<_>>(),
            expected_keys
        );
        assert_eq!(record["version"], 2);
        assert!(record.get("params").is_none());
        assert!(record.get("arity").is_none());
    }
}

#[test]
fn fixture_executes_mixed_and_empty_rest_values_and_receiver_chain() {
    let compiled = compile_source(&fixture_source());
    let actual = Engine::new(compiled)
        .execute("xx")
        .expect("execute neutral fixture");
    assert_eq!(actual, json!([contract()["fixture"]["expected"]]));
}

#[test]
fn arguments_are_evaluated_once_left_to_right_and_rest_arrays_are_fresh() {
    let source = r#"fn gather(...items) { return(items) }
fn mutate_rest(...items) { items += "mutated"; return(items) }

Top::
 /x/ -> Done {
   order = "";
   first = gather(order = cat(order, "a"), order = cat(order, "b"), order);
   return({
     "first" : first,
     "fresh_one" : mutate_rest("a"),
     "fresh_two" : mutate_rest(),
     "order" : order
   })
 }

Done::
 /x/
"#;
    assert_eq!(
        Engine::new(compile_source(source)).execute("xx").unwrap(),
        json!([{
            "first": ["a", "ab", "ab"],
            "fresh_one": ["a", "mutated"],
            "fresh_two": ["mutated"],
            "order": "ab"
        }])
    );
}

#[test]
fn fixed_and_variadic_arity_failures_remain_distinct() {
    let fixed = fixture_source().replace(
        "pair(\"left\", \"right\")",
        "pair(\"left\", \"right\", \"extra\")",
    );
    let fixed_error = Engine::new(compile_source(&fixed))
        .execute("xx")
        .unwrap_err();
    assert!(
        fixed_error.contains("user function 'pair' expects 2 argument(s), got 3"),
        "{fixed_error}"
    );

    let variadic = fixture_source().replace("collect(\"p\")", "collect()");
    let variadic_error = Engine::new(compile_source(&variadic))
        .execute("xx")
        .unwrap_err();
    assert!(
        variadic_error.contains("user function 'collect' expects at least 1 argument(s), got 0"),
        "{variadic_error}"
    );
}

#[test]
fn invalid_rest_definitions_are_rejected() {
    let cases = [
        "...items, tail",
        "...left, ...right",
        "...",
        "items...",
        "... items",
    ];
    for params in cases {
        let source = format!("fn bad({params}) {{ return(undef) }}\nTop::\n /x/\n");
        assert!(
            parse_spec_with_user_functions(&source).is_err(),
            "invalid definition unexpectedly parsed: {params}"
        );
    }

    for params in ["item, ...item", "...return"] {
        let source = format!("fn bad({params}) {{ return(undef) }}\nTop::\n /x/\n");
        let parsed = parse_spec_with_user_functions(&source)
            .unwrap_or_else(|error| panic!("{params} should reach semantic validation: {error}"));
        assert!(
            validate(&parsed).is_err(),
            "invalid definition validated: {params}"
        );
    }
}

#[test]
fn compiled_json_and_generated_source_preserve_variadic_signature() {
    let compiled = compile_source(&fixture_source());
    let encoded = serde_json::to_string(&compiled).unwrap();
    let decoded: CompiledSpec = serde_json::from_str(&encoded).unwrap();
    assert_eq!(
        Engine::new(decoded).execute("xx").unwrap(),
        json!([contract()["fixture"]["expected"]])
    );

    let generated = emit_rust_source(&compiled).expect("emit generated Rust source");
    assert!(generated.contains("\\\"rest_param\\\":\\\"items\\\""));
    assert!(generated.contains("\\\"max_arity\\\":null"));

    let generated_rules = [
        GeneratedPlanRow {
            label: "Top",
            family: classify_generated_rule_family(&compiled.rules[0]).contract_name(),
        },
        GeneratedPlanRow {
            label: "Done",
            family: classify_generated_rule_family(&compiled.rules[1]).contract_name(),
        },
    ];
    assert_eq!(
        execute_generated_parser(&encoded, &generated_rules, "xx").unwrap(),
        json!([contract()["fixture"]["expected"]])
    );
}
