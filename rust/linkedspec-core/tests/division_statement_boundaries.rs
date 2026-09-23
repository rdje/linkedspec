//! Newline division must not steal successful multiline regex interpretations.

use linkedspec_core::expr::{CodeBlock, Expr};

const PARSERS: [fn(&str) -> Result<CodeBlock, String>; 2] =
    [CodeBlock::parse, CodeBlock::parse_with_callable_candidates];

fn assignment_value(block: &CodeBlock, index: usize) -> &Expr {
    let Expr::AssignScalar { value, .. } = &block.statements[index].expr else {
        panic!("expected scalar assignment: {:?}", block.statements[index]);
    };
    value
}

fn assert_division(expr: &Expr) {
    assert!(
        matches!(expr, Expr::Call { name, args } if name == "/" && args.len() == 2),
        "{expr:?}"
    );
}

#[test]
fn division_accepts_authored_statement_newlines() {
    let mut failures = Vec::new();
    for parse in PARSERS {
        for call in ["/(14,2)", "/ \t(14,2)", "/(+(10,4),2)"] {
            for separator in ["\n", "\r\n", "\r", " \t\n  "] {
                let source = format!("out = {call}{separator}note = 1; return(out)");
                match parse(&source) {
                    Ok(block) => {
                        assert_eq!(block.statements.len(), 3, "{source:?}");
                        assert_division(assignment_value(&block, 0));
                    }
                    Err(error) => failures.push(format!("{source:?}: {error}")),
                }
            }
        }
    }
    assert!(failures.is_empty(), "{}", failures.join("\n"));
}

#[test]
fn ambiguous_regex_prefix_can_be_retried_after_a_later_statement_fails() {
    for parse in PARSERS {
        for tail in [
            "rx = /x/; return(out)",
            "note = \"/)\"; return(out)",
            "rx = /; @/; return(out)",
            "other = /(28,4)\nreturn(out)",
        ] {
            let source = format!("out = /(14,2)\n{tail}");
            let block = parse(&source).unwrap_or_else(|error| panic!("{source:?}: {error}"));
            assert_eq!(block.statements.len(), 3, "{source:?}");
            assert_division(assignment_value(&block, 0));
            if tail.starts_with("other") {
                assert_division(assignment_value(&block, 1));
            }
        }
    }
}

#[test]
fn existing_successful_regex_interpretations_remain_exact() {
    for parse in PARSERS {
        for pattern in [
            "(x)",
            r"(\))",
            r#"(")")"#,
            "(x)\ny",
            "(14,2)\ntext",
            "(14,2)\nnext = ",
            "(x)\r\ny",
            r"(?<!\\)}",
        ] {
            let block = parse(&format!("rx = /{pattern}/; return(7)")).unwrap();
            assert_eq!(block.statements.len(), 2);
            assert_eq!(
                assignment_value(&block, 0),
                &Expr::RegexLiteral {
                    pattern: pattern.to_owned()
                }
            );
        }
        // A regex before a repaired division retains its own exact pattern.
        let block = parse("rx = /(x)\ny/; out = /(14,2)\nreturn(out)").unwrap();
        assert_eq!(
            assignment_value(&block, 0),
            &Expr::RegexLiteral {
                pattern: "(x)\ny".into()
            }
        );
        assert_division(assignment_value(&block, 1));
    }
}

#[test]
fn repaired_boundary_retains_unicode_write_source_and_spans() {
    for parse in PARSERS {
        let prefix = "title = \"é🦀\"; out = /(14,2)\r\n";
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
            panic!("expected following write");
        };
        assert_eq!(retained, write);
        assert_eq!(source_span.start, prefix.chars().count());
        assert_eq!(source_span.end, source.chars().count());
        let restored: CodeBlock =
            serde_json::from_str(&serde_json::to_string(&block).unwrap()).unwrap();
        assert_eq!(restored, block);
    }
}

#[test]
fn long_division_sequences_and_late_invalid_input_terminate_without_recursion() {
    for parse in PARSERS {
        let source = "out = /(14,2)\n".repeat(1500) + "return(out)";
        let block = parse(&source).unwrap();
        assert_eq!(block.statements.len(), 1501);
        for statement in &block.statements[..1500] {
            let Expr::AssignScalar { value, .. } = &statement.expr else {
                panic!("expected assignment")
            };
            assert_division(value);
        }
        assert!(parse(&(source + "; @")).is_err());
    }
}

#[test]
fn nested_blocks_and_regex_arguments_keep_their_own_interpretations() {
    for parse in PARSERS {
        for source in [
            "out = 0; if(true) { out = /(14,2)\nnote = 1 }; return(out)",
            "out = 0; switch(1) { case(1) { out = /(14,2)\nnote = 1 } default { out = 2 } }; return(out)",
            "out = 14; while(gt(out,7)) { out = /(out,2)\nnote = 1 }; return(out)",
            "out = { n = /(14,2)\nreturn(n) }; return(out)",
            "return(({ n = /(14,2)\nreturn(n) }))",
            "out = /(if(true,14,/(x)\ny/),2)\nnote = 1; return(out)",
            "my out = /(14,2)\n; ; note = 1;",
        ] {
            let block = parse(source).unwrap_or_else(|error| panic!("{source:?}: {error}"));
            let encoded = serde_json::to_string(&block).unwrap();
            let restored: CodeBlock = serde_json::from_str(&encoded).unwrap();
            assert_eq!(restored, block);
            assert!(
                encoded.contains(r#""name":"/""#),
                "division was lost: {source:?}"
            );
        }
        let block = parse("out = /(if(true,14,/(x)\ny/),2)\nnote = 1").unwrap();
        assert_division(assignment_value(&block, 0));
        let encoded = serde_json::to_value(&block).unwrap();
        // Check the nested regex's exact pattern, independently of its runtime use.
        fn has_pattern(value: &serde_json::Value) -> bool {
            match value {
                serde_json::Value::Object(fields) => {
                    fields.get("pattern") == Some(&serde_json::json!("(x)\ny"))
                        || fields.values().any(has_pattern)
                }
                serde_json::Value::Array(items) => items.iter().any(has_pattern),
                _ => false,
            }
        }
        assert!(has_pattern(&encoded));
    }
}

#[test]
fn existing_call_boundaries_and_invalid_inputs_remain_stable() {
    for parse in PARSERS {
        for source in [
            "/(14,2)",
            "/ (14,2); note = 1",
            "return(/(14,2))",
            "out = -7\nnote = 1",
        ] {
            parse(source).unwrap();
        }
        for source in [
            "out = /(14,2) note = 1",
            "out = /(14,2)\nreturn(@)",
            "out = /(14,2\nnote = 1",
        ] {
            assert!(parse(source).is_err(), "{source:?}");
        }
    }
}
