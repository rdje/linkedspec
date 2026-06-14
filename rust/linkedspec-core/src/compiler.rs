//! Compiler — transforms parsed AST into HandlerIR nodes.
//!
//! The compiler:
//! 1. Resolves rule dependencies (which rules each edge targets).
//! 2. Determines the handler variant kind for each rule.
//! 3. Assembles HandlerIR nodes with lifecycle slots.
//!
//! Reference: `docs/knowledge/handler-ir-design.md`

use crate::ast::{BodyElement, Rule, RuleMode, SpecFile};
use crate::error::Result;
use crate::types::{HandlerIR, HandlerKind, ParseMode};
use std::collections::HashMap;

/// Compile a parsed (and validated) SpecFile into HandlerIR nodes.
pub fn compile(spec: &SpecFile) -> Result<Vec<HandlerIR>> {
    let mut handlers = Vec::new();

    for rule in &spec.rules {
        let handler = compile_rule(rule, spec)?;
        handlers.push(handler);
    }

    Ok(handlers)
}

/// Compile a single rule into a HandlerIR node.
fn compile_rule(rule: &Rule, _spec: &SpecFile) -> Result<HandlerIR> {
    let edges: Vec<&BodyElement> = rule
        .body
        .iter()
        .filter(|e| matches!(e, BodyElement::ActionEdge { .. } | BodyElement::BlindEdge { .. }))
        .collect();

    let _has_edges = !edges.is_empty();
    let is_rep = rule.header.mode.is_repetition();

    // Collect lifecycle code blocks
    let lifecycle_blocks = collect_lifecycle_blocks(&rule.body);

    // Determine variant kind
    let kind = determine_variant(&rule.header.mode, &edges, is_rep);

    // Determine parse mode from rule mode
    let parse_mode = match &rule.header.mode {
        RuleMode::And | RuleMode::AndPlus | RuleMode::AndBounded { .. } | RuleMode::Pipe => {
            ParseMode::Consume
        }
        _ => ParseMode::Seek,
    };

    // Build dispatch refs
    let (acodes_ref, bcodes_ref, bcalls_ref) = build_dispatch_refs(&edges);

    // Build repetition bounds
    let (rep_min, rep_max) = build_rep_bounds(&rule.header.mode);

    Ok(HandlerIR {
        kind,
        label: rule.header.label.clone(),
        parse_mode,
        preamble: lifecycle_blocks.get("I").cloned(),
        lxcode: lifecycle_blocks.get("LX").cloned(),
        lscode: lifecycle_blocks.get("LS").cloned(),
        lecode: lifecycle_blocks.get("LE").cloned(),
        ecode: lifecycle_blocks.get("E").cloned(),
        excode: lifecycle_blocks.get("EX").cloned(),
        itcode: lifecycle_blocks.get("IT").cloned(),
        acodes_ref: if acodes_ref.is_empty() { None } else { Some(acodes_ref) },
        bcodes_ref: if bcodes_ref.is_empty() { None } else { Some(bcodes_ref) },
        bcalls_ref: if bcalls_ref.is_empty() { None } else { Some(bcalls_ref) },
        and_icode: None,
        rep_min,
        rep_max,
    })
}

/// Collect lifecycle blocks from body elements into a map of marker → code.
fn collect_lifecycle_blocks(body: &[BodyElement]) -> HashMap<String, String> {
    let mut blocks: HashMap<String, String> = HashMap::new();

    for element in body {
        match element {
            BodyElement::LifecycleMarker { marker } => {
                // Lifecycle marker alone (no attached block) — store as placeholder
                blocks.entry(marker.clone()).or_insert_with(String::new);
            }
            BodyElement::CodeBlock {
                lifecycle: Some(lc),
                code,
            } => {
                blocks
                    .entry(lc.clone())
                    .and_modify(|existing| {
                        existing.push(' ');
                        existing.push_str(code);
                    })
                    .or_insert_with(|| code.clone());
            }
            _ => {}
        }
    }

    blocks
}

/// Determine the handler variant kind from the rule mode and edges.
fn determine_variant(
    mode: &RuleMode,
    edges: &[&BodyElement],
    is_rep: bool,
) -> HandlerKind {
    let has_acode = edges
        .iter()
        .any(|e| matches!(e, BodyElement::ActionEdge { .. }));
    let has_bcode = edges
        .iter()
        .any(|e| matches!(e, BodyElement::BlindEdge { .. }));
    let edge_count = edges.len();

    // No edges → default handler
    if !has_acode && !has_bcode {
        return HandlerKind::Default;
    }

    let is_and = matches!(
        mode,
        RuleMode::And | RuleMode::AndPlus | RuleMode::AndBounded { .. } | RuleMode::Pipe
    );

    if is_rep {
        // REP variants
        if is_and {
            if has_acode {
                return HandlerKind::RepAndAcode;
            }
            return HandlerKind::RepAndBcode;
        }
        if has_acode {
            return HandlerKind::RepAcode;
        }
        return HandlerKind::RepBcode;
    }

    // Non-REP variants
    if is_and {
        if has_acode {
            if edge_count == 1 {
                return HandlerKind::AndSingleAcode;
            }
            return HandlerKind::AndAcodeSeq;
        }
        return HandlerKind::AndBcode;
    }

    // OR / default variants
    if has_acode {
        if edge_count == 1 && !has_bcode {
            return HandlerKind::OrAcode;
        }
        return HandlerKind::Default;
    }
    HandlerKind::OrBcode
}

/// Build dispatch references: action codes, blind-call codes, and blind-call order.
fn build_dispatch_refs(
    edges: &[&BodyElement],
) -> (Vec<String>, Vec<(String, String)>, Vec<String>) {
    let mut acodes: Vec<String> = Vec::new();
    let mut bcodes: Vec<(String, String)> = Vec::new();
    let mut bcalls: Vec<String> = Vec::new();

    for (idx, edge) in edges.iter().enumerate() {
        match edge {
            BodyElement::ActionEdge { target, .. } => {
                acodes.push(format!("__action_{idx}_{target}")); // placeholder — real code comes from lifecycle
            }
            BodyElement::BlindEdge { target } => {
                bcalls.push(target.clone());
                bcodes.push((target.clone(), format!("__bcode_{idx}_{target}")));
            }
            _ => {}
        }
    }

    (acodes, bcodes, bcalls)
}

/// Build repetition bounds from the rule mode.
fn build_rep_bounds(mode: &RuleMode) -> (Option<usize>, Option<usize>) {
    match mode {
        RuleMode::Star => (Some(0), None),
        RuleMode::Plus | RuleMode::OrPlus | RuleMode::AndPlus => (Some(1), None),
        RuleMode::Optional => (Some(0), Some(1)),
        RuleMode::OrBounded { min, max } | RuleMode::AndBounded { min, max } => {
            (Some(*min), *max)
        }
        _ => (None, None),
    }
}

impl RuleMode {
    /// Returns true if this mode implies repetition.
    fn is_repetition(&self) -> bool {
        matches!(
            self,
            RuleMode::Star
                | RuleMode::Plus
                | RuleMode::OrPlus
                | RuleMode::AndPlus
                | RuleMode::Optional
                | RuleMode::OrBounded { .. }
                | RuleMode::AndBounded { .. }
        )
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ast::{RuleHeader, SpecFile};

    fn make_spec(rules: Vec<Rule>) -> SpecFile {
        SpecFile { rules }
    }

    fn make_rule(label: &str, is_top: bool, mode: RuleMode, body: Vec<BodyElement>) -> Rule {
        Rule {
            header: RuleHeader {
                label: label.into(),
                is_top,
                mode,
                rest: String::new(),
            },
            body,
        }
    }

    #[test]
    fn compile_simple_and_bcode() {
        let spec = make_spec(vec![
            make_rule(
                "Top",
                true,
                RuleMode::And,
                vec![
                    BodyElement::Regex {
                        value: "/a/".into(),
                    },
                    BodyElement::BlindEdge {
                        target: "Child".into(),
                    },
                ],
            ),
            make_rule(
                "Child",
                false,
                RuleMode::Default,
                vec![BodyElement::Regex {
                    value: "/b/".into(),
                }],
            ),
        ]);

        let handlers = compile(&spec).unwrap();
        assert_eq!(handlers.len(), 2);
        assert_eq!(handlers[0].kind, HandlerKind::AndBcode);
        assert_eq!(handlers[0].parse_mode, ParseMode::Consume);
        assert!(handlers[0].bcalls_ref.is_some());
        assert_eq!(handlers[0].bcalls_ref.as_ref().unwrap().len(), 1);
    }

    #[test]
    fn compile_or_acode_default() {
        let spec = make_spec(vec![make_rule(
            "Top",
            true,
            RuleMode::Default,
            vec![BodyElement::ActionEdge {
                target: "Child".into(),
                index: 0,
            }],
        )]);

        let handlers = compile(&spec).unwrap();
        assert_eq!(handlers[0].kind, HandlerKind::OrAcode); // single acode → OrAcode optimization
        assert_eq!(handlers[0].parse_mode, ParseMode::Seek);
        assert!(handlers[0].acodes_ref.is_some());
    }

    #[test]
    fn compile_rep_variant() {
        let spec = make_spec(vec![make_rule(
            "Top",
            true,
            RuleMode::Star,
            vec![BodyElement::ActionEdge {
                target: "Child".into(),
                index: 0,
            }],
        )]);

        let handlers = compile(&spec).unwrap();
        assert_eq!(handlers[0].kind, HandlerKind::RepAcode);
        assert_eq!(handlers[0].rep_min, Some(0));
        assert_eq!(handlers[0].rep_max, None); // unbounded
    }

    #[test]
    fn compile_with_lifecycle_blocks() {
        let spec = make_spec(vec![make_rule(
            "Top",
            true,
            RuleMode::Default,
            vec![
                BodyElement::LifecycleMarker {
                    marker: "I".into(),
                },
                BodyElement::CodeBlock {
                    lifecycle: Some("I".into()),
                    code: "declare(array, results)".into(),
                },
                BodyElement::Regex {
                    value: "/x/".into(),
                },
            ],
        )]);

        let handlers = compile(&spec).unwrap();
        let ir = &handlers[0];
        assert!(ir.preamble.is_some());
        assert!(ir.preamble.as_ref().unwrap().contains("declare"));
    }

    #[test]
    fn compile_empty_mode_is_or() {
        let spec = make_spec(vec![
            make_rule(
                "Top",
                true,
                RuleMode::Default,
                vec![BodyElement::ActionEdge {
                    target: "A".into(),
                    index: 0,
                }],
            ),
            make_rule("A", false, RuleMode::Default, vec![]),
        ]);

        let handlers = compile(&spec).unwrap();
        assert_eq!(handlers.len(), 2);
        assert_eq!(handlers[0].kind, HandlerKind::OrAcode); // single acode → OrAcode
        assert_eq!(handlers[0].parse_mode, ParseMode::Seek);
    }
}
