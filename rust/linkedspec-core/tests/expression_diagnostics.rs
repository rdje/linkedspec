//! Malformed Unicode expressions must produce bounded diagnostics, never panics.

use linkedspec_core::expr::{CodeBlock, Expr};

const PARSERS: [fn(&str) -> Result<CodeBlock, String>; 2] =
    [CodeBlock::parse, CodeBlock::parse_with_callable_candidates];

#[test]
fn ascii_diagnostic_text_and_byte_positions_remain_stable() {
    for parse in PARSERS {
        assert_eq!(
            parse("return(@invalid)").unwrap_err(),
            "unexpected character '@' at position 7 near: '@invalid)'",
        );
        let prefix = "return(\"é🦀\");\nreturn(";
        let source = format!("{prefix}@{}", "a".repeat(80));
        assert_eq!(
            parse(&source).unwrap_err(),
            format!(
                "unexpected character '@' at position {} near: '@{}'",
                prefix.len(),
                "a".repeat(39),
            ),
        );
    }
}

#[test]
fn diagnostic_window_preserves_whole_scalars_at_every_byte_alignment() {
    for parse in PARSERS {
        for prefix in ["", "return(\"é🦀\");\nreturn("] {
            for scalar in ["é", "字", "🦀"] {
                for padding in 0..4 {
                    let lead = format!("@{}", "a".repeat(padding));
                    let source = format!("{prefix}{lead}{}", scalar.repeat(50));
                    let expected_context =
                        format!("{lead}{}", scalar.repeat((40 - lead.len()) / scalar.len()),);
                    assert_eq!(
                        parse(&source).unwrap_err(),
                        format!(
                            "unexpected character '@' at position {} near: '{expected_context}'",
                            prefix.len(),
                        ),
                        "source: {source:?}",
                    );
                }
            }
        }
        assert_eq!(
            parse(&format!("🦀{}", "é".repeat(30))).unwrap_err(),
            format!(
                "unexpected character '🦀' at position 0 near: '🦀{}'",
                "é".repeat(18),
            ),
        );
    }
}

#[test]
fn short_unicode_and_incomplete_expressions_remain_errors() {
    for parse in PARSERS {
        for suffix in ["", "é", "字", "🦀", "e\u{301}", "é\r\n🦀"] {
            let source = format!("@{suffix}");
            assert_eq!(
                parse(&source).unwrap_err(),
                format!("unexpected character '@' at position 0 near: '{source}'"),
            );
        }
        for source in [
            "return(\"é",
            "return(\"🦀\\",
            "return(é,",
            "return([\"字\",",
        ] {
            assert!(parse(source).is_err(), "must reject {source:?}");
        }
    }
}

#[test]
fn valid_unicode_retains_exact_text_and_scalar_source_spans() {
    let prefix = "return(\"é🦀\"); ";
    let write = "document[\"clé\"] = \"字🦀\"";
    let source = format!("{prefix}{write}");
    for parse in PARSERS {
        let block = parse(&source).unwrap();
        assert_eq!(block.statements.len(), 2);
        let Expr::AssignNestedAccess {
            source: retained_source,
            source_span,
            segments,
            value,
            ..
        } = &block.statements[1].expr
        else {
            panic!("expected a nested write with authored scalar spans");
        };
        assert_eq!(retained_source, write);
        assert_eq!(source_span.start, prefix.chars().count());
        assert_eq!(source_span.end, source.chars().count());
        assert_eq!(segments[0].source, "\"clé\"");
        assert_eq!(segments[0].source_span.start, prefix.chars().count() + 9);
        assert_eq!(segments[0].source_span.end, prefix.chars().count() + 14);
        assert!(matches!(value.as_ref(), Expr::StringLiteral { value } if value == "字🦀"));
    }
}
