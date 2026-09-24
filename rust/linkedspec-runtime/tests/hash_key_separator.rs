//! Compact hash keys retain evaluated values and authored source through carriers.

use linkedspec_core::ast::{BodyElementKind, SpecFile};
use linkedspec_core::compiler::compile;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

const PLAN: &[GeneratedPlanRow] = &[
    GeneratedPlanRow {
        label: "Top",
        family: "default",
    },
    GeneratedPlanRow {
        label: "Done",
        family: "default",
    },
];

#[test]
fn compact_keys_keep_values_source_and_mismatch_behavior_across_carriers() {
    let cases = [
        ("key = \" a \"", "{key.trim:7}", json!({"a": 7})),
        ("key = \" a \"", "{key.trim():7}", json!({"a": 7})),
        ("key = \"a\"", "{ key : 7 }", json!({"a": 7})),
        ("key = \"a\"", "{ key :7 }", json!({"a": 7})),
        ("key = \"a\"", "{ key: 7 }", json!({"a": 7})),
        ("key = \"a\"", "{key:7}", json!({"a": 7})),
        ("key = \"a\"", "{(key):7}", json!({"a": 7})),
        ("key = \"a\"", "{cat(key,\"\"):7}", json!({"a": 7})),
        ("key = \"a\"", "{\"a\":7}", json!({"a": 7})),
        (
            "key = \"a\"",
            "{key:{key:7},\"fixed\":key}",
            json!({"a": {"a": 7}, "fixed": "a"}),
        ),
        ("key = \"é🦀\"", "{key:7}", json!({"é🦀": 7})),
        ("key = \"a\"", "{\"é🦀\":7}", json!({"é🦀": 7})),
        ("key = \"é\"", "{cat(key,\"🦀\"):7}", json!({"é🦀": 7})),
    ];
    for (setup, literal, expected) in cases {
        for newline in ["\n", "\r\n"] {
            let action = format!("{setup};{newline}out = {literal}; return(out)");
            let source = format!(
                "Top::{newline} -> Done {{ {action} }}{newline}Done:{newline} /x/{newline}"
            );
            let parsed = parse_spec_with_user_functions(&source).unwrap();
            let BodyElementKind::ActionEdge { code, .. } = &parsed.rules[0].body[0].kind else {
                panic!("expected the explicit action edge");
            };
            assert_eq!(code.as_deref(), Some(action.as_str()));
            validate(&parsed).unwrap();
            let restored: SpecFile =
                serde_json::from_value(serde_json::to_value(&parsed).unwrap()).unwrap();
            assert_eq!(
                serde_json::to_value(&parsed).unwrap(),
                serde_json::to_value(&restored).unwrap()
            );
            let compiled = compile(&parsed).unwrap();
            assert_eq!(
                serde_json::to_value(&compiled).unwrap(),
                serde_json::to_value(compile(&restored).unwrap()).unwrap()
            );
            let encoded = serde_json::to_string(&compiled).unwrap();
            let decoded: CompiledSpec = serde_json::from_str(&encoded).unwrap();
            assert_eq!(
                serde_json::to_value(&compiled).unwrap(),
                serde_json::to_value(&decoded).unwrap()
            );
            for carrier in [compiled, decoded] {
                let engine = Engine::new(carrier);
                for (input, value) in [
                    ("x", expected.clone()),
                    ("y", Value::Null),
                    ("x", expected.clone()),
                ] {
                    assert_eq!(
                        engine
                            .execute_value(input, &ExecutionOptions::new())
                            .unwrap(),
                        value,
                        "{source:?}, {input:?}"
                    );
                }
            }
            for (input, value) in [("x", expected.clone()), ("y", Value::Null)] {
                assert_eq!(
                    execute_generated_parser_v2(
                        &encoded,
                        PLAN,
                        input,
                        "hash-key.spec",
                        GENERATED_SOURCE_CONTRACT
                    )
                    .unwrap(),
                    value,
                    "{source:?}, {input:?}"
                );
            }
        }
    }
}
