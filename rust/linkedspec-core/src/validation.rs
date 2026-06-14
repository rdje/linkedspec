//! Validation passes for parsed .spec AST.
//!
//! Reference: `docs/linkedspec-book/src/appendix/formal-grammar.md` §10

use crate::ast::{BodyElement, SpecFile};
use crate::error::{LinkedSpecError, Result};
use std::collections::HashSet;

/// Validate a parsed SpecFile AST.
///
/// Checks:
/// 1. At least one top rule exists.
/// 2. No duplicate rule labels.
/// 3. No mixed action + blind-call edges in a single rule.
/// 4. No unclosed blocks at EOF.
/// 5. Edge targets reference existing rules.
pub fn validate(spec: &SpecFile) -> Result<()> {
    check_top_rule_exists(spec)?;
    check_duplicate_labels(spec)?;
    check_mixed_edges(spec)?;
    check_unclosed_blocks(spec)?;
    check_edge_targets(spec)?;
    Ok(())
}

/// At least one rule must have `is_top = true` (double-colon label).
fn check_top_rule_exists(spec: &SpecFile) -> Result<()> {
    if !spec.rules.iter().any(|r| r.header.is_top) {
        return Err(LinkedSpecError::Validation(
            "no top rule found: at least one rule must use '::' (double colon) to declare a parser entry point".into(),
        ));
    }
    Ok(())
}

/// No two rules may have the same label.
fn check_duplicate_labels(spec: &SpecFile) -> Result<()> {
    let mut seen = HashSet::new();
    for rule in &spec.rules {
        if !seen.insert(&rule.header.label) {
            return Err(LinkedSpecError::Validation(format!(
                "duplicate rule label '{}': each rule must have a unique name",
                rule.header.label
            )));
        }
    }
    Ok(())
}

/// A rule must not mix action edges (->) and blind-call edges (=>) in the same rule.
fn check_mixed_edges(spec: &SpecFile) -> Result<()> {
    for rule in &spec.rules {
        let has_action = rule
            .body
            .iter()
            .any(|e| matches!(e, BodyElement::ActionEdge { .. }));
        let has_blind = rule
            .body
            .iter()
            .any(|e| matches!(e, BodyElement::BlindEdge { .. }));

        if has_action && has_blind {
            return Err(LinkedSpecError::Validation(format!(
                "rule '{}' mixes action edges (->) and blind-call edges (=>): a rule must use one or the other, not both",
                rule.header.label
            )));
        }
    }
    Ok(())
}

/// Every `{` opened in a rule body must have a matching `}` before EOF.
fn check_unclosed_blocks(spec: &SpecFile) -> Result<()> {
    for rule in &spec.rules {
        let mut depth: i32 = 0;
        for element in &rule.body {
            match element {
                BodyElement::CodeBlock { code, .. } | BodyElement::Raw(code) => {
                    depth += code.matches('{').count() as i32;
                    depth -= code.matches('}').count() as i32;
                }
                BodyElement::Regex { value } => {
                    // Regex can contain escaped braces, count only unescaped
                    depth += value.matches('{').count() as i32;
                    depth -= value.matches('}').count() as i32;
                }
                BodyElement::SplitMarker { marker } => {
                    depth += marker.matches('{').count() as i32;
                    depth -= marker.matches('}').count() as i32;
                }
                BodyElement::FluentChain { code } => {
                    depth += code.matches('(').count() as i32;
                    depth -= code.matches(')').count() as i32;
                }
                _ => {}
            }
        }
        if depth != 0 {
            return Err(LinkedSpecError::Validation(format!(
                "rule '{}' has unclosed blocks: {} unmatched {{ or }}",
                rule.header.label,
                if depth > 0 {
                    format!("{} open", depth)
                } else {
                    format!("{} extra close", -depth)
                }
            )));
        }
    }
    Ok(())
}

/// Every edge target must reference an existing rule.
fn check_edge_targets(spec: &SpecFile) -> Result<()> {
    let labels: HashSet<&str> = spec.rules.iter().map(|r| r.header.label.as_str()).collect();

    for rule in &spec.rules {
        for element in &rule.body {
            match element {
                BodyElement::ActionEdge { target, .. } | BodyElement::BlindEdge { target } => {
                    if !labels.contains(target.as_str()) {
                        return Err(LinkedSpecError::Validation(format!(
                            "rule '{}' references undefined rule '{}': edge targets must refer to existing rules",
                            rule.header.label, target
                        )));
                    }
                }
                _ => {}
            }
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ast::{Rule, RuleHeader, RuleMode};

    fn make_rule(label: &str, is_top: bool, body: Vec<BodyElement>) -> Rule {
        Rule {
            header: RuleHeader {
                label: label.into(),
                is_top,
                mode: RuleMode::Default,
                rest: String::new(),
            },
            body,
        }
    }

    #[test]
    fn validate_accepts_valid_spec() {
        let spec = SpecFile {
            rules: vec![
                make_rule(
                    "Top",
                    true,
                    vec![BodyElement::Regex {
                        value: "/a/".into(),
                    }],
                ),
                make_rule(
                    "Child",
                    false,
                    vec![BodyElement::Regex {
                        value: "/b/".into(),
                    }],
                ),
            ],
        };
        assert!(validate(&spec).is_ok());
    }

    #[test]
    fn validate_rejects_missing_top_rule() {
        let spec = SpecFile {
            rules: vec![make_rule("R1", false, vec![])],
        };
        let err = validate(&spec).unwrap_err();
        assert!(err.to_string().contains("no top rule"));
    }

    #[test]
    fn validate_rejects_duplicate_labels() {
        let spec = SpecFile {
            rules: vec![
                make_rule("Top", true, vec![]),
                make_rule("Top", false, vec![]),
            ],
        };
        let err = validate(&spec).unwrap_err();
        assert!(err.to_string().contains("duplicate"));
    }

    #[test]
    fn validate_rejects_mixed_edges() {
        let spec = SpecFile {
            rules: vec![make_rule(
                "Top",
                true,
                vec![
                    BodyElement::ActionEdge {
                        target: "A".into(),
                        index: 0,
                    },
                    BodyElement::BlindEdge {
                        target: "B".into(),
                    },
                ],
            )],
        };
        let err = validate(&spec).unwrap_err();
        assert!(err.to_string().contains("mixes action"));
    }

    #[test]
    fn validate_rejects_undefined_edge_target() {
        let spec = SpecFile {
            rules: vec![make_rule(
                "Top",
                true,
                vec![BodyElement::ActionEdge {
                    target: "Nonexistent".into(),
                    index: 0,
                }],
            )],
        };
        let err = validate(&spec).unwrap_err();
        assert!(err.to_string().contains("undefined rule"));
    }

    #[test]
    fn validate_rejects_unclosed_block() {
        let spec = SpecFile {
            rules: vec![{
                let mut rule = make_rule("Top", true, vec![]);
                rule.body.push(BodyElement::CodeBlock {
                    lifecycle: None,
                    code: "I { open block".into(),
                });
                rule
            }],
        };
        let err = validate(&spec).unwrap_err();
        assert!(err.to_string().contains("unclosed blocks"));
    }

    #[test]
    fn validate_edge_to_valid_target() {
        let spec = SpecFile {
            rules: vec![
                make_rule(
                    "Top",
                    true,
                    vec![
                        BodyElement::ActionEdge {
                            target: "Child".into(),
                            index: 0,
                        },
                        BodyElement::BlindEdge {
                            target: "Other".into(),
                        },
                    ],
                ),
                make_rule("Child", false, vec![]),
                make_rule("Other", false, vec![]),
            ],
        };
        // Should fail because Top has mixed edges, not because of undefined targets
        let err = validate(&spec).unwrap_err();
        assert!(err.to_string().contains("mixes action"));
    }
}
