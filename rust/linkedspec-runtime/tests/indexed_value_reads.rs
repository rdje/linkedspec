//! Indexed reads follow current typed bindings through supported Rust carriers.

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
fn indexed_reads_keep_current_values_across_carriers() {
    let cases = [
        ("items = [\"a\",\"b\"]", "items[0]", json!("a")),
        ("keys = [\"a\"]", "{keys[0]:7}", json!({"a": 7})),
        ("keys = [\"a\"]", "{keys[0] : 7}", json!({"a": 7})),
        ("set(items,[\"a\",\"b\"])", "items[1]", json!("b")),
        ("push(items,\"a\")", "items[0]", json!("a")),
        ("items = []; items += \"a\"", "items[0]", json!("a")),
        ("items = split(\"a,b\",\",\")", "items[1]", json!("b")),
        ("split(items,\"a,b\",\",\")", "items[1]", json!("b")),
        ("items = [\"a\",\"b\"]; i = 1", "items[i]", json!("b")),
        ("items = [\"a\",\"b\"]", "items[add(0,1)]", json!("b")),
        ("items = [[\"a\"]]", "items[0][0]", json!("a")),
        (
            "items = {\"list\":[\"a\"]}",
            "items[\"list\"][0]",
            json!("a"),
        ),
        (
            "push(items,\"old\"); items = [\"new\"]",
            "items[0]",
            json!("new"),
        ),
        (
            "items = [[\"a\"]]; saved = items[0]; items[0][0] = \"b\"",
            "saved",
            json!(["a"]),
        ),
        ("items = [\"a\"]", "items[9]", json!(null)),
        ("items = [\"a\"]", "items", json!(["a"])),
        ("items = [\"a\"]", "items.first()", json!("a")),
        ("items = [\"a\"]", "(items)[0]", json!("a")),
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
                        "indexed-read.spec",
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
