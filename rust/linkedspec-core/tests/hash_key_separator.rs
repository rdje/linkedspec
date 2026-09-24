//! A hash-pair colon terminates its key without changing evaluated-key ASTs.

use linkedspec_core::expr::{Arg, CodeBlock, Expr, HashLiteralEntry, Stmt};

const PARSERS: [fn(&str) -> Result<CodeBlock, String>; 2] =
    [CodeBlock::parse, CodeBlock::parse_with_callable_candidates];

fn variable(name: &str) -> Expr {
    Expr::Variable { name: name.into() }
}

fn text(value: &str) -> Expr {
    Expr::StringLiteral {
        value: value.into(),
    }
}

fn hash(entries: Vec<(Expr, Expr)>) -> Expr {
    Expr::HashLiteral {
        entries: entries
            .into_iter()
            .map(|(key, value)| HashLiteralEntry { key, value })
            .collect(),
    }
}

fn returned(expr: Expr) -> CodeBlock {
    CodeBlock {
        statements: vec![Stmt {
            expr: Expr::Call {
                name: "return".into(),
                args: vec![Arg::Positional(expr)],
            },
        }],
    }
}

#[test]
fn adjacent_and_spaced_colons_preserve_exact_key_expressions() {
    let keys = [
        ("key", variable("key")),
        ("(key)", variable("key")),
        ("pkg::key", variable("pkg::key")),
        ("\"é🦀\"", text("é🦀")),
        ("true", Expr::BooleanLiteral { value: true }),
        ("7", Expr::NumberLiteral { value: 7.0 }),
        (
            "cat(key,\"🦀\")",
            Expr::Call {
                name: "cat".into(),
                args: vec![
                    Arg::Positional(variable("key")),
                    Arg::Positional(text("🦀")),
                ],
            },
        ),
    ];
    for parse in PARSERS {
        for (source_key, expected_key) in &keys {
            for separator in [" : ", " :", ": ", ":", ":\r\n"] {
                let source = format!("return({{{source_key}{separator}value}})");
                assert_eq!(
                    parse(&source).unwrap_or_else(|error| panic!("{source:?}: {error}")),
                    returned(hash(vec![(expected_key.clone(), variable("value"))])),
                    "{source:?}",
                );
            }
        }
    }
}

#[test]
fn nested_compact_pairs_preserve_dynamic_values_and_fixed_names() {
    let source = r#"return({key:{other:value},"fixed":key})"#;
    let expected = returned(hash(vec![
        (
            variable("key"),
            hash(vec![(variable("other"), variable("value"))]),
        ),
        (text("fixed"), variable("key")),
    ]));
    for parse in PARSERS {
        assert_eq!(parse(source).unwrap(), expected);
    }
}

#[test]
fn namespace_names_and_keyword_arguments_keep_distinct_ast_roles() {
    for parse in PARSERS {
        assert_eq!(
            parse("return(pkg::key)").unwrap(),
            returned(variable("pkg::key"))
        );
        let block = parse("pkg::read(value:key, other:{key:7})").unwrap();
        assert_eq!(
            block,
            CodeBlock {
                statements: vec![Stmt {
                    expr: Expr::Call {
                        name: "pkg::read".into(),
                        args: vec![
                            Arg::Keyword {
                                name: "value".into(),
                                value: Box::new(variable("key"))
                            },
                            Arg::Keyword {
                                name: "other".into(),
                                value: Box::new(hash(vec![(
                                    variable("key"),
                                    Expr::NumberLiteral { value: 7.0 }
                                )]))
                            },
                        ],
                    }
                }]
            }
        );
        assert_eq!(
            parse("{pkg::key}").unwrap(),
            CodeBlock {
                statements: vec![Stmt {
                    expr: Expr::BlockValue {
                        block: CodeBlock {
                            statements: vec![Stmt {
                                expr: variable("pkg::key")
                            }]
                        }
                    },
                }]
            }
        );
        // A namespace separator alone must never manufacture a hash pair.
        assert!(parse("return({key::7, other:9})").is_err());
        assert!(parse("return({key 7})").is_err());
        assert!(
            parse("return({key:})")
                .unwrap_err()
                .contains("expected value after hash pair separator")
        );
        assert!(
            parse("return({key=>7})")
                .unwrap_err()
                .contains("hash_literal_use_colon")
        );
    }
}

#[test]
fn compact_keys_preserve_unicode_write_text_and_scalar_spans() {
    let prefix = "title = \"é🦀\";\r\n";
    let write = "document[\"clé\"] = {key:7,\"é🦀\":key}";
    let source = format!("{prefix}{write}");
    for parse in PARSERS {
        let block = parse(&source).unwrap();
        assert_eq!(block.statements.len(), 2);
        let Expr::AssignNestedAccess {
            source: retained,
            source_span,
            segments,
            value,
            ..
        } = &block.statements[1].expr
        else {
            panic!("expected a nested write");
        };
        assert_eq!(retained, write);
        assert_eq!(source_span.start, prefix.chars().count());
        assert_eq!(source_span.end, source.chars().count());
        assert_eq!(segments[0].source, "\"clé\"");
        assert_eq!(segments[0].source_span.start, prefix.chars().count() + 9);
        assert_eq!(segments[0].source_span.end, prefix.chars().count() + 14);
        assert_eq!(
            value.as_ref(),
            &hash(vec![
                (variable("key"), Expr::NumberLiteral { value: 7.0 }),
                (text("é🦀"), variable("key")),
            ])
        );
    }
}
