//! Literal values must survive header/body capture and supported source carriers.

use linkedspec_core::ast::{BodyElementKind, SpecFile};
use linkedspec_core::compiler::compile;
use linkedspec_core::types::CompiledSpec;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

const TOP_PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
    label: "Top",
    family: "default",
}];

#[test]
fn compact_header_literals_retain_values_through_source_and_compiled_carriers() {
    for literal in ["a  b", "a\tb", "  leading", "trailing  ", "é🦀\t  b"] {
        for separation in [" ", "\n", "\r\n"] {
            let action = format!("return(\"{literal}\")");
            let source = format!("Top::{separation}E{{{action}}} /x/\n");
            let parsed = parse_spec_with_user_functions(&source).unwrap();
            let BodyElementKind::CodeBlock { code, .. } = &parsed.rules[0].body[0].kind else {
                panic!("expected the exit action in {source:?}");
            };
            assert_eq!(code, &action, "{source:?}");

            assert_carriers(&parsed, Value::String(literal.to_owned()));
        }
    }
}

#[test]
fn a_block_on_a_closing_line_retains_its_first_continuation_statement() {
    let source =
        "Top::\n I { note = 0;\n note = 1 } E { note = 3;\n note = 4;\n return(note) } /x/\n";
    let parsed = parse_spec_with_user_functions(source).unwrap();
    assert_carriers(&parsed, Value::from(4));
}

fn assert_carriers(parsed: &SpecFile, expected: Value) {
    let reconstructed: SpecFile =
        serde_json::from_str(&serde_json::to_string(&parsed).unwrap()).unwrap();
    let compiled = compile(parsed).unwrap();
    assert_eq!(
        serde_json::to_value(&compiled).unwrap(),
        serde_json::to_value(compile(&reconstructed).unwrap()).unwrap(),
    );
    let encoded = serde_json::to_string(&compiled).unwrap();
    let decoded: CompiledSpec = serde_json::from_str(&encoded).unwrap();
    for spec in [compiled, decoded] {
        assert_eq!(
            Engine::new(spec)
                .execute_value("x", &ExecutionOptions::new())
                .unwrap(),
            expected,
        );
    }
    assert_eq!(
        execute_generated_parser_v2(
            &encoded,
            TOP_PLAN,
            "x",
            "source-fidelity.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .unwrap(),
        expected,
    );
}
