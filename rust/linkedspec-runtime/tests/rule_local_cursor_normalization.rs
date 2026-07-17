//! Live boundary checks for Rust rule-family and bare-edge normalization.

use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::Engine;
use serde_json::{Value, json};

fn execute(source: &str, input: &str) -> Value {
    let spec = parse_spec(source).expect("parse normalized edge source");
    validate(&spec).expect("validate normalized edge source");
    let compiled = compile(&spec).expect("compile normalized edge source");
    Engine::new(compiled)
        .execute(input)
        .expect("execute normalized edge source")
}

#[test]
fn and_family_bare_edge_executes_from_the_typed_blind_table() {
    let source = "Top::AND\n Child\n\nChild:\n /x/ E { return(\"hit\") }\n";
    assert_eq!(
        execute(source, "x"),
        json!([["hit"]]),
        "embedding execution wraps the AND child result in top-rule accumulation"
    );
}

#[test]
fn default_and_header_rest_bare_edges_retain_the_staged_live_boundary() {
    for source in [
        "Top::\n Child\n\nChild:\n /x/ E { return(\"hit\") }\n",
        "Top:: Child\n\nChild:\n /x/ E { return(\"hit\") }\n",
    ] {
        assert_eq!(
            execute(source, "x"),
            json!([]),
            "FUTURE-PARITY-BACKLOG.9.1.4.3 owns live action-edge entry"
        );
    }
}

#[test]
fn compact_or_retains_legacy_live_cursor_behavior_until_the_execution_leaf() {
    let source = "Top::|\n /x/ -> Top { return(\"hit\") }\n";
    assert_eq!(
        execute(source, "prefix x"),
        json!([]),
        "FUTURE-PARITY-BACKLOG.9.1.4.3 owns compact-OR cursor execution"
    );
}
