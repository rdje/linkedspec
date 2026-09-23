//! Non-slash symbol calls retain their callee and following statement boundaries.

use linkedspec_core::expr::{CodeBlock, Expr};

const PARSERS: [fn(&str) -> Result<CodeBlock, String>; 2] =
    [CodeBlock::parse, CodeBlock::parse_with_callable_candidates];
const SYMBOLS: [(&str, &str); 11] = [
    ("+", "+(3,4)"),
    ("-", "-(10,3)"),
    ("*", "*(1,7)"),
    ("%", "%(15,8)"),
    ("==", "==(2,2)"),
    ("!=", "!=(2,3)"),
    (">=", ">=(2,2)"),
    ("<=", "<=(2,2)"),
    (">", ">(3,2)"),
    ("<", "<(2,3)"),
    ("=", "=(inner,7)"),
];

fn assert_symbol(expr: &Expr, symbol: &str) {
    let Expr::Call { name, args } = expr else {
        panic!("expected symbol call, got {expr:?}");
    };
    assert_eq!(name, symbol, "the authored callee must survive");
    assert_eq!(args.len(), 2);
}

#[test]
fn non_slash_calls_preserve_newlines_and_callee_identity() {
    // Keep every failure visible in RED, including subtraction's wrong AST.
    let mut failures = Vec::new();
    for parse in PARSERS {
        for (symbol, call) in SYMBOLS {
            for separator in ["\n", "\r\n", "\r", " \t\n  ", ";"] {
                let source = format!("out = {call}{separator}note = 1");
                match parse(&source) {
                    Ok(block) => {
                        assert_eq!(block.statements.len(), 2, "{source:?}");
                        let Expr::AssignScalar { name, value } = &block.statements[0].expr else {
                            panic!("expected out assignment: {source:?}");
                        };
                        assert_eq!(name, "out");
                        if matches!(value.as_ref(), Expr::Call { name, .. } if name.is_empty()) {
                            failures.push(format!("{source:?}: callee was erased"));
                            continue;
                        }
                        assert_symbol(value, symbol);
                        assert_eq!(
                            block.statements[1].expr,
                            Expr::AssignScalar {
                                name: "note".to_owned(),
                                value: Box::new(Expr::NumberLiteral { value: 1.0 }),
                            },
                        );
                    }
                    Err(error) => failures.push(format!("{source:?}: {error}")),
                }
            }
        }
    }
    assert!(failures.is_empty(), "{}", failures.join("\n"));
}

#[test]
fn subsequent_write_preserves_exact_unicode_source_and_spans() {
    for parse in PARSERS {
        for (_, call) in SYMBOLS {
            let prefix = format!("title = \"é🦀\"; out = {call}\r\n");
            let write = "tree[\"clé\"] = out";
            let source = format!("{prefix}{write}");
            let block = parse(&source).unwrap();
            assert_eq!(block.statements.len(), 3);
            let Expr::AssignNestedAccess {
                source: retained,
                source_span,
                ..
            } = &block.statements[2].expr
            else {
                panic!("expected the following write");
            };
            assert_eq!(retained, write);
            assert_eq!(source_span.start, prefix.chars().count());
            assert_eq!(source_span.end, source.chars().count());
            let restored: CodeBlock =
                serde_json::from_str(&serde_json::to_string(&block).unwrap()).unwrap();
            assert_eq!(restored, block);
        }
    }
}

#[test]
fn eof_nested_quoted_negative_and_invalid_controls_remain_stable() {
    for parse in PARSERS {
        for (symbol, call) in SYMBOLS {
            let block = parse(call).unwrap();
            assert_symbol(&block.statements[0].expr, symbol);
            for separator in [" ", "\t"] {
                assert!(parse(&format!("out = {call}{separator}note = 1")).is_err());
            }
            assert!(parse(&format!("out = {call}\nreturn(@)")).is_err());
        }
        for source in [
            "return(+(3,4))",
            "out = +(3,4); note = 1",
            "out = -7\nnote = 1",
            "out = -(10, +(1,2)); note = 1",
            "out = +(\"(\", \"\\\")\"); note = 1",
        ] {
            parse(source).unwrap_or_else(|error| panic!("{source:?}: {error}"));
        }
    }
}

#[test]
fn slash_calls_and_multiline_regex_keep_their_existing_interpretations() {
    // Division/newline repair is the next owned slice, .86.2. Do not weaken its
    // original failing cases here or broaden this non-slash correction.
    for parse in PARSERS {
        for pattern in [
            "(x)",
            r"(\))",
            r#"(")")"#,
            "(x)\ny",
            "(14,2)\ntext",
            "(14,2)\nnext = ",
            "(x)\r\ny",
        ] {
            let source = format!("rx = /{pattern}/; note = 1");
            let block = parse(&source).unwrap();
            let Expr::AssignScalar { value, .. } = &block.statements[0].expr else {
                panic!("expected regex assignment");
            };
            assert_eq!(
                value.as_ref(),
                &Expr::RegexLiteral {
                    pattern: pattern.to_owned()
                }
            );
        }
        for source in ["/(14,2)", "/ (14,2); note = 1", "return(/(14,2))"] {
            parse(source).unwrap();
        }
    }
}
