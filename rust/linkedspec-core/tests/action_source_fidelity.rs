//! Outer block capture must retain source before ActionIR assigns scalar spans.

use linkedspec_core::ast::{BodyElementKind, SpecFile};
use linkedspec_core::compiler::compile;
use linkedspec_core::expr::Expr;
use linkedspec_core::parser::parse_spec;

fn action_sources(spec: &SpecFile) -> Vec<&str> {
    spec.rules[0]
        .body
        .iter()
        .filter_map(|element| match &element.kind {
            BodyElementKind::CodeBlock { code, .. } => Some(code.as_str()),
            BodyElementKind::ActionEdge { code, .. }
            | BodyElementKind::BlindEdge { code, .. }
            | BodyElementKind::BareEdge { code, .. } => code.as_deref(),
            _ => None,
        })
        .collect()
}

#[test]
fn multiline_action_interiors_retain_physical_source() {
    for newline in ["\n", "\r\n"] {
        let action = format!(
            "note = \"é🦀\"; \t{newline}\t {newline}  tree = {{ \"clé\" : 1 }};{newline}\treturn(tree)"
        );
        for header in ["Top::", "Top::AND"] {
            for marker in [
                "I", "LS", "LE", "E", "EX", "IT", "LX", "-> Done", "=> Done", "Done", "",
            ] {
                for inline in [false, true] {
                    let separation = if inline { " " } else { newline };
                    let source = format!(
                        "{header}{separation} {marker} {{ {action} }}{newline}Done:{newline} /x/{newline}"
                    );
                    let parsed = parse_spec(&source).expect("parse an accepted outer block");
                    assert_eq!(action_sources(&parsed), [action.as_str()], "{source:?}");
                    assert_eq!(parsed.rules.len(), 2);
                    assert_eq!(parsed.rules[1].header.label, "Done");
                    assert_eq!(
                        parsed.rules[1].header.line,
                        source.lines().position(|line| line == "Done:").unwrap() + 1
                    );
                    let restored: SpecFile =
                        serde_json::from_str(&serde_json::to_string(&parsed).unwrap()).unwrap();
                    assert_eq!(action_sources(&restored), [action.as_str()]);
                }
            }
        }
    }
}

#[test]
fn compact_header_action_retains_inner_horizontal_spacing() {
    let action = "note   = \"é🦀\"; return(note)";
    for marker in ["", "I", "E"] {
        let parsed = parse_spec(&format!("Top:: {marker}{{{action}}}\n")).unwrap();
        assert_eq!(action_sources(&parsed), [action]);
    }
}

#[test]
fn closing_line_remainders_retain_next_block_source() {
    let first = "return(1)";
    let second = "note = 2; \t\r\n\treturn(note)";
    for third in [
        "note = 3; \t\n  \n  return(note)",
        "note = 3;\n note = 4;\n return(note)",
        "return(3)",
    ] {
        for separation in [" ", "\r\n"] {
            let source = format!(
                "Top::{separation} I {{ {first} }} LS {{{second}}} E {{{third}}} /x/\r\nDone:\r\n /y/\r\n"
            );
            let parsed = parse_spec(&source).unwrap();
            assert_eq!(action_sources(&parsed), [first, second, third]);
            assert!(matches!(
                parsed.rules[0].body.last().unwrap().kind,
                BodyElementKind::Regex { .. }
            ));
            assert_eq!(
                parsed.rules[0].body[2].line,
                source
                    .lines()
                    .position(|line| line.contains(" E {"))
                    .unwrap()
                    + 1
            );
            assert_eq!(parsed.rules.len(), 2);
            assert_eq!(
                parsed.rules[1].header.line,
                source.lines().position(|line| line == "Done:").unwrap() + 1
            );
        }
    }
}

#[test]
fn multiline_fluent_remainders_keep_their_closing_line_origin() {
    let action = "note = 3;\n note = 4;\n return(note)";
    for separation in [" ", "\n"] {
        let source = format!("Top::{separation} I.return(\n 42\n ) E {{{action}}} /x/\n");
        let parsed = parse_spec(&source).unwrap();
        assert_eq!(action_sources(&parsed), ["return(42)", action]);
        assert_eq!(
            parsed.rules[0].body[1].line,
            source
                .lines()
                .position(|line| line.contains(" E {"))
                .unwrap()
                + 1
        );
        assert!(matches!(
            parsed.rules[0].body.last().unwrap().kind,
            BodyElementKind::Regex { .. }
        ));
    }
}

#[test]
fn compiled_whole_spec_retains_mutation_source_and_scalar_spans() {
    for whitespace in ["\n", "\r\n", " \t\r\n \t\n  "] {
        let prefix = "note = \"é🦀\"; \r\n\r\n  ";
        let expression =
            format!("tree . map_leaves! ({whitespace}) {{ return(value) }} . count_keys()");
        let action = format!("{prefix}{expression}");
        let source = format!("Top::\r\n -> Done {{ {action} }}\r\nDone:\r\n /x/\r\n");
        let parsed = parse_spec(&source).unwrap();
        assert_eq!(action_sources(&parsed), [action.as_str()]);
        let compiled = compile(&parsed).unwrap();
        let Expr::ReceiverMutationChain {
            source,
            source_span,
            mutation,
            ..
        } = &compiled.rules[0].acode_dispatch[0]
            .code
            .as_ref()
            .unwrap()
            .statements[1]
            .expr
        else {
            panic!("expected the mutation carrier");
        };
        assert_eq!(source, &expression);
        assert_eq!(source_span.start, prefix.chars().count());
        assert_eq!(source_span.end, action.chars().count());
        let args_start = prefix.chars().count() + "tree . map_leaves! ".chars().count();
        assert_eq!(mutation.args_span.start, args_start);
        assert_eq!(
            mutation.args_span.end,
            args_start + whitespace.chars().count() + 2
        );
    }
}

#[test]
fn outer_trim_and_single_line_blocks_remain_compatible() {
    for suffix in ["", "\n", "\r\n"] {
        let source = format!("Top::\n I {{ \treturn(42) \t}}{suffix}");
        let parsed = parse_spec(&source).unwrap();
        assert_eq!(action_sources(&parsed), ["return(42)"]);
        assert_eq!(parsed.rules[0].body[0].source, "I { \treturn(42) \t}");
        assert_eq!(compiled_statement_count(&parsed), 1);
    }
    assert!(parse_spec("").unwrap().rules.is_empty());
    assert!(parse_spec(" \r\n\r\n").unwrap().rules.is_empty());
}

fn compiled_statement_count(spec: &SpecFile) -> usize {
    compile(spec).unwrap().rules[0]
        .preamble
        .as_ref()
        .unwrap()
        .statements
        .len()
}
