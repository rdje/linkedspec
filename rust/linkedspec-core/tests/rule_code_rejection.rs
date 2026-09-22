//! Malformed rule code must stop compilation instead of disappearing from the program.

use linkedspec_core::compiler::compile;
use linkedspec_core::error::LinkedSpecError;
use linkedspec_core::parser::parse_spec;

fn assert_rejected(source: &str, context: &str, detail: &str) {
    let ast = parse_spec(source).expect("outer spec syntax must reach code compilation");
    match compile(&ast) {
        Err(LinkedSpecError::Compile(message)) => {
            assert!(message.starts_with(context), "{message}");
            assert!(message.contains(detail), "{message}");
        }
        result => panic!("malformed code must reject compilation: {result:?}"),
    }
}

#[test]
fn malformed_lifecycle_blocks_are_compile_errors() {
    for lifecycle in ["I", "LS", "LE", "E", "EX", "IT", "LX"] {
        assert_rejected(
            &format!("Top::\n /x/\n {lifecycle} {{ return(@invalid) }}\n"),
            &format!("rule 'Top': failed to parse {lifecycle} -block code:"),
            "unexpected character '@'",
        );
    }
}

#[test]
fn malformed_explicit_and_bare_edge_blocks_are_compile_errors() {
    for (header, edge, kind) in [
        ("Top::", "/x/ -> Child", "action"),
        ("Top::", "=> Child", "blind-call"),
        ("Top::", "Child", "action"),
        ("Top::AND", "Child", "blind-call"),
    ] {
        assert_rejected(
            &format!("{header}\n {edge} {{ return(@invalid) }}\n\nChild:\n /x/\n"),
            &format!("rule 'Top': failed to parse {kind} code:"),
            "unexpected character '@'",
        );
    }
}

#[test]
fn malformed_document_guard_is_a_compile_error() {
    assert_rejected(
        "Document::\n /x/\n LX { if(cursor_pos() != input_end_pos()); exit_now(1); endif() }\n",
        "rule 'Document': failed to parse LX -block code:",
        "expected ')' after args in attached control 'if'",
    );
}

#[test]
fn malformed_write_and_mutation_blocks_are_compile_errors() {
    for (code, detail) in [
        ("tree[] = 1", "nested_write_segment_empty"),
        ("retv[\"x\"] = 1", "nested_write_root_reserved"),
        (
            "tree = { \"a\" : 1 }; tree.map_leaves!(1) { value }",
            "map_leaves_mutation_arguments_invalid",
        ),
    ] {
        assert_rejected(
            &format!("Top::\n I {{ {code} }}\n /x/ E {{ return(42) }}\n"),
            "rule 'Top': failed to parse I -block code:",
            detail,
        );
    }
}

#[test]
fn valid_lifecycle_and_edge_blocks_remain_present() {
    let source = "Top::\n /x/\n I { return(1) }\n LS { return(2) }\n LE { return(3) }\n E { return(4) }\n EX { return(5) }\n IT { return(6) }\n LX { return(7) }\n";
    let compiled = compile(&parse_spec(source).unwrap()).unwrap();
    let rule = &compiled.rules[0];
    for block in [
        &rule.preamble,
        &rule.lscode,
        &rule.lecode,
        &rule.ecode,
        &rule.excode,
        &rule.itcode,
        &rule.lxcode,
    ] {
        assert_eq!(block.as_ref().unwrap().statements.len(), 1);
    }
    for (header, edge, blind) in [
        ("Top::", "/x/ -> Child", false),
        ("Top::", "=> Child", true),
        ("Top::", "Child", false),
        ("Top::AND", "Child", true),
    ] {
        let source = format!("{header}\n {edge} {{ return(42) }}\n\nChild:\n /x/\n");
        let compiled = compile(&parse_spec(&source).unwrap()).unwrap();
        let rule = &compiled.rules[0];
        let block = if blind {
            &rule.bcode_dispatch[0].code
        } else {
            &rule.acode_dispatch[0].code
        };
        assert_eq!(block.as_ref().unwrap().statements.len(), 1);
    }
}
