//! Non-slash symbol statements preserve values and typed source across carriers.

use linkedspec_core::ast::{BodyElementKind, SpecFile};
use linkedspec_core::compiler::compile;
use linkedspec_core::expr::Expr;
use linkedspec_core::types::CompiledSpec;
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
const CALLS: [(&str, i64); 11] = [
    ("+(3,4)", 7),
    ("-(10,3)", 7),
    ("*(1,7)", 7),
    ("%(15,8)", 7),
    ("==(2,2)", 1),
    ("!=(2,3)", 1),
    (">=(2,2)", 1),
    ("<=(2,2)", 1),
    (">(3,2)", 1),
    ("<(2,3)", 1),
    ("=(inner,7)", 7),
];

fn assert_carriers(action: &str, expected: Value) -> CompiledSpec {
    let source = format!("Top::\r\n -> Done {{ {action} }}\r\nDone:\r\n /x/\r\n");
    let parsed = parse_spec_with_user_functions(&source).unwrap();
    let BodyElementKind::ActionEdge { code, .. } = &parsed.rules[0].body[0].kind else {
        panic!("expected action edge");
    };
    assert_eq!(code.as_deref(), Some(action));
    let restored: SpecFile =
        serde_json::from_str(&serde_json::to_string(&parsed).unwrap()).unwrap();
    assert_eq!(
        serde_json::to_value(&restored).unwrap(),
        serde_json::to_value(&parsed).unwrap()
    );
    let compiled = compile(&parsed).unwrap();
    assert_eq!(
        serde_json::to_value(compile(&restored).unwrap()).unwrap(),
        serde_json::to_value(&compiled).unwrap()
    );
    let encoded = serde_json::to_string(&compiled).unwrap();
    let decoded: CompiledSpec = serde_json::from_str(&encoded).unwrap();
    assert_eq!(
        serde_json::to_value(&decoded).unwrap(),
        serde_json::to_value(&compiled).unwrap()
    );
    for carrier in [compiled.clone(), decoded] {
        assert_eq!(
            Engine::new(carrier)
                .execute_value("x", &ExecutionOptions::new())
                .unwrap(),
            expected,
            "{source:?}"
        );
    }
    assert_eq!(
        execute_generated_parser_v2(
            &encoded,
            PLAN,
            "x",
            "symbol-boundary.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .unwrap(),
        expected
    );
    compiled
}

#[test]
fn all_non_slash_symbols_execute_after_newline_boundaries() {
    for (call, expected) in CALLS {
        for separator in ["\n", "\r\n", " \t\n  "] {
            let action = format!("out = {call}{separator}note = 1; return(out)");
            let compiled = assert_carriers(&action, json!(expected));
            let block = compiled.rules[0].acode_dispatch[0].code.as_ref().unwrap();
            assert_eq!(block.statements.len(), 3);
        }
    }
}

#[test]
fn subtraction_keeps_later_write_source_and_scalar_spans() {
    let prefix = "title = \"é🦀\"; out = -(10,3)\r\n";
    let write = "tree[\"clé\"] = out";
    let action = format!("{prefix}{write}; return(tree[\"clé\"])");
    let compiled = assert_carriers(&action, json!(7));
    let block = compiled.rules[0].acode_dispatch[0].code.as_ref().unwrap();
    let Expr::AssignNestedAccess {
        source,
        source_span,
        ..
    } = &block.statements[2].expr
    else {
        panic!("expected the following write");
    };
    assert_eq!(source, write);
    assert_eq!(source_span.start, prefix.chars().count());
    assert_eq!(
        source_span.end,
        prefix.chars().count() + write.chars().count()
    );
}

#[test]
fn negative_nested_and_unchanged_slash_regex_controls_execute() {
    for (action, expected) in [
        ("out = -7\nnote = 1; return(out)", -7),
        ("out = -(10, +(1,2))\nnote = 1; return(out)", 7),
        ("out = /(14,2); note = 1; return(out)", 7),
        ("rx = /(x)\ny/; return(7)", 7),
        ("rx = /(14,2)\nnext = /; return(7)", 7),
    ] {
        assert_carriers(action, json!(expected));
    }
}
