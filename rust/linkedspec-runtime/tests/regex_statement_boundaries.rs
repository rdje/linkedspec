//! Subsequent statements must survive regex parsing and supported carriers.

use linkedspec_core::ast::{BodyElementKind, SpecFile};
use linkedspec_core::compiler::compile;
use linkedspec_core::expr::Expr;
use linkedspec_core::types::CompiledSpec;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::json;

const TOP_PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
    label: "Top",
    family: "default",
}];

fn assert_carriers(action: &str, result: &str) -> CompiledSpec {
    let source = format!("Top::\r\n I {{ {action} }}\r\n /x/ E {{ return({result}) }}\r\n");
    let parsed = parse_spec_with_user_functions(&source).unwrap();
    let BodyElementKind::CodeBlock { code, .. } = &parsed.rules[0].body[0].kind else {
        panic!("expected the initialization block");
    };
    assert_eq!(code, action);
    let restored: SpecFile =
        serde_json::from_str(&serde_json::to_string(&parsed).unwrap()).unwrap();
    let compiled = compile(&parsed).unwrap();
    assert_eq!(
        serde_json::to_value(compile(&restored).unwrap()).unwrap(),
        serde_json::to_value(&compiled).unwrap(),
    );
    let encoded = serde_json::to_string(&compiled).unwrap();
    let decoded: CompiledSpec = serde_json::from_str(&encoded).unwrap();
    assert_eq!(
        serde_json::to_value(&decoded).unwrap(),
        serde_json::to_value(&compiled).unwrap(),
    );
    for carrier in [compiled.clone(), decoded] {
        assert_eq!(
            Engine::new(carrier)
                .execute_value("x", &ExecutionOptions::new())
                .unwrap(),
            json!(7),
            "{source:?}",
        );
    }
    assert_eq!(
        execute_generated_parser_v2(
            &encoded,
            TOP_PLAN,
            "x",
            "regex-boundary.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .unwrap(),
        json!(7),
    );
    compiled
}

#[test]
fn regex_statements_survive_source_and_compiled_carriers() {
    for pattern in ["x", r"a\/b", "é🦀", "(?i)x"] {
        for flags in ["", "i"] {
            for separator in ["\n", "\r\n", " \t\n  ", ";"] {
                let action = format!("rx = /{pattern}/{flags}{separator}out = 7");
                let compiled = assert_carriers(&action, "out");
                assert_eq!(
                    compiled.rules[0]
                        .preamble
                        .as_ref()
                        .unwrap()
                        .statements
                        .len(),
                    2
                );
            }
        }
    }
}

#[test]
fn regex_boundary_preserves_following_nested_write_source() {
    for separator in ["\n", "\r\n", " \t\n  "] {
        let prefix = format!("note = \"é🦀\";\r\nrx = /x/{separator}");
        let write = "out[\"clé\"] = 7";
        let action = format!("{prefix}{write}");
        let compiled = assert_carriers(&action, "out[\"clé\"]");
        let block = compiled.rules[0].preamble.as_ref().unwrap();
        assert_eq!(block.statements.len(), 3);
        let Expr::AssignNestedAccess {
            source,
            source_span,
            ..
        } = &block.statements[2].expr
        else {
            panic!("expected the following nested write");
        };
        assert_eq!(source, write);
        assert_eq!(source_span.start, prefix.chars().count());
        assert_eq!(source_span.end, action.chars().count());
    }
}

#[test]
fn slash_calls_strings_and_malformed_boundaries_retain_behavior() {
    for action in ["out = /(14, 2)", "out = / (14, 2)", "rx = \"x\"\nout = 7"] {
        assert_carriers(action, "out");
    }
    for action in ["rx = /x/ out = 7", "rx = /x/ i", "rx = /x/; return(@)"] {
        let source = format!("Top::\n I {{ {action} }}\n /x/\n");
        let parsed = parse_spec_with_user_functions(&source).unwrap();
        assert!(compile(&parsed).is_err(), "must reject {source:?}");
        let restored: SpecFile =
            serde_json::from_str(&serde_json::to_string(&parsed).unwrap()).unwrap();
        assert!(compile(&restored).is_err());
    }
}
