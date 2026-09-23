//! Regex suffix scanning must leave statement separators and later source intact.

use linkedspec_core::ast::BodyElementKind;
use linkedspec_core::compiler::compile;
use linkedspec_core::expr::{CodeBlock, Expr};
use linkedspec_core::parser::parse_spec;

const PARSERS: [fn(&str) -> Result<CodeBlock, String>; 2] =
    [CodeBlock::parse, CodeBlock::parse_with_callable_candidates];

#[test]
fn regex_assignments_leave_following_statement_separators() {
    for parse in PARSERS {
        for pattern in ["x", r"a\/b", "é🦀", "(?i)x"] {
            // Preserve existing adjacent-suffix compatibility, without assigning
            // new flag semantics to the pattern-only RegexLiteral carrier.
            for flags in ["", "i", "ogx"] {
                for separator in ["\n", "\r\n", "\r", " \t\n  ", ";", " \t; \n"] {
                    let source = format!("rx = /{pattern}/{flags}{separator}out = 7");
                    let block =
                        parse(&source).unwrap_or_else(|error| panic!("{source:?}: {error}"));
                    assert_eq!(block.statements.len(), 2, "{source:?}");
                    let Expr::AssignScalar { name, value } = &block.statements[0].expr else {
                        panic!("expected regex assignment in {source:?}");
                    };
                    assert_eq!(name, "rx");
                    assert_eq!(
                        value.as_ref(),
                        &Expr::RegexLiteral {
                            pattern: pattern.to_owned(),
                        },
                    );
                    let Expr::AssignScalar { name, value } = &block.statements[1].expr else {
                        panic!("expected the following assignment in {source:?}");
                    };
                    assert_eq!(name, "out");
                    assert_eq!(value.as_ref(), &Expr::NumberLiteral { value: 7.0 });
                }
            }
        }
    }
}

#[test]
fn a_following_identifier_is_not_a_regex_suffix() {
    for parse in PARSERS {
        let block = parse("/x/\nflag").unwrap();
        assert_eq!(block.statements.len(), 2);
        assert_eq!(
            block.statements[1].expr,
            Expr::Variable {
                name: "flag".to_owned(),
            },
        );
    }
}

#[test]
fn subsequent_nested_write_retains_source_and_scalar_spans() {
    for separator in ["\n", "\r\n", " \t\n  "] {
        let prefix = format!("note = \"é🦀\";\r\nrx = /x/{separator}");
        let write = "out[\"clé\"] = 7";
        let action = format!("{prefix}{write}");
        let spec = format!("Top::\r\n I {{ {action} }}\r\n /x/\r\n");
        let parsed = parse_spec(&spec).unwrap();
        let BodyElementKind::CodeBlock { code, .. } = &parsed.rules[0].body[0].kind else {
            panic!("expected the initialization block");
        };
        assert_eq!(code, &action);
        let compiled = compile(&parsed).unwrap();
        let mut blocks = vec![compiled.rules[0].preamble.clone().unwrap()];
        blocks.extend(PARSERS.map(|parse| parse(&action).unwrap()));
        for block in blocks {
            assert_eq!(block.statements.len(), 3);
            let Expr::AssignNestedAccess {
                source,
                source_span,
                base,
                segments,
                ..
            } = &block.statements[2].expr
            else {
                panic!("expected the subsequent nested write");
            };
            assert_eq!(base, "out");
            assert_eq!(source, write);
            assert_eq!(source_span.start, prefix.chars().count());
            assert_eq!(source_span.end, action.chars().count());
            assert_eq!(segments.len(), 1);
            assert_eq!(segments[0].source, "\"clé\"");
            assert_eq!(segments[0].source_span.start, prefix.chars().count() + 4);
            assert_eq!(segments[0].source_span.end, prefix.chars().count() + 9);
            let restored: CodeBlock =
                serde_json::from_str(&serde_json::to_string(&block).unwrap()).unwrap();
            assert_eq!(restored, block);
        }
    }
}

#[test]
fn horizontal_whitespace_does_not_attach_suffix_letters() {
    for parse in PARSERS {
        for gap in [" ", "\t", " \t "] {
            let source = format!("rx = /x/{gap}i");
            assert!(parse(&source).is_err(), "must reject {source:?}");
        }
    }
}

#[test]
fn slash_calls_strings_and_invalid_regex_controls_remain_stable() {
    for parse in PARSERS {
        for source in [
            // Symbol-call newline recognition is separately owned by startup
            // .86; its unchanged failing sources are retained in that task.
            "out = /(14, 2); return(out)",
            "out = / (14, 2); return(out)",
            "rx = \"x\"\nout = 7",
            "rx = /x/i\nout = 7",
            "rx = /x/; out = 7",
        ] {
            assert_eq!(parse(source).unwrap().statements.len(), 2, "{source:?}");
        }
        for source in ["return(/(x)/)", r"return(/a\/b/)", "return(/x/)"] {
            assert_eq!(parse(source).unwrap().statements.len(), 1);
        }
        for source in ["rx = /x", "rx = /x/ out = 7", "rx = /x/; return(@)"] {
            assert!(parse(source).is_err(), "must reject {source:?}");
        }
    }
}
