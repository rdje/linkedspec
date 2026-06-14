//! Compiler — transforms parsed AST into HandlerIR nodes.
use crate::ast::{BodyElement, BodyElementKind, Rule, RuleMode, SpecFile};
use crate::error::Result;
use crate::types::{HandlerIR, HandlerKind, ParseMode};
use std::collections::HashMap;

pub fn compile(spec: &SpecFile) -> Result<Vec<HandlerIR>> {
    let mut handlers = Vec::new();
    for rule in &spec.rules {
        handlers.push(compile_rule(rule)?);
    }
    Ok(handlers)
}

fn compile_rule(rule: &Rule) -> Result<HandlerIR> {
    let acode_count = rule.body.iter().filter(|e| matches!(e.kind, BodyElementKind::ActionEdge { .. })).count();
    let bcode_count = rule.body.iter().filter(|e| matches!(e.kind, BodyElementKind::BlindEdge { .. })).count();
    let has_acode = acode_count > 0;
    let has_bcode = bcode_count > 0;
    let edge_count = acode_count + bcode_count;
    let is_rep = rule.header.mode.is_repetition();
    let is_and = matches!(&rule.header.mode, RuleMode::And | RuleMode::AndPlus | RuleMode::AndBounded { .. } | RuleMode::Pipe);

    let lifecycle_blocks = collect_lifecycle_blocks(&rule.body);
    let (acodes_ref, bcodes_ref, bcalls_ref) = build_dispatch_refs(&rule.body);

    let kind = if is_rep {
        if is_and { if has_acode { HandlerKind::RepAndAcode } else { HandlerKind::RepAndBcode } }
        else { if has_acode { HandlerKind::RepAcode } else { HandlerKind::RepBcode } }
    } else if is_and {
        if has_acode { if edge_count == 1 { HandlerKind::AndSingleAcode } else { HandlerKind::AndAcodeSeq } }
        else { HandlerKind::AndBcode }
    } else {
        if has_acode { if edge_count == 1 && !has_bcode { HandlerKind::OrAcode } else { HandlerKind::Default } }
        else { HandlerKind::OrBcode }
    };

    let parse_mode = if is_and { ParseMode::Consume } else { ParseMode::Seek };
    let (rep_min, rep_max) = build_rep_bounds(&rule.header.mode);

    Ok(HandlerIR {
        kind, label: rule.header.label.clone(), parse_mode,
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
        and_icode: None, rep_min, rep_max,
    })
}

fn collect_lifecycle_blocks(body: &[BodyElement]) -> HashMap<String, String> {
    let mut blocks: HashMap<String, String> = HashMap::new();
    for element in body {
        match &element.kind {
            BodyElementKind::LifecycleMarker { marker } => {
                blocks.entry(marker.clone()).or_insert_with(String::new);
            }
            BodyElementKind::CodeBlock { lifecycle, code } => {
                if let Some(lc) = lifecycle {
                    blocks.entry(lc.clone())
                        .and_modify(|e| { e.push(' '); e.push_str(code); })
                        .or_insert_with(|| code.clone());
                }
            }
            _ => {}
        }
    }
    blocks
}

fn build_dispatch_refs(body: &[BodyElement]) -> (Vec<String>, Vec<(String, String)>, Vec<String>) {
    let mut acodes: Vec<String> = Vec::new();
    let mut bcodes: Vec<(String, String)> = Vec::new();
    let mut bcalls: Vec<String> = Vec::new();
    for (idx, element) in body.iter().enumerate() {
        match &element.kind {
            BodyElementKind::ActionEdge { target, .. } => {
                acodes.push(format!("__action_{idx}_{target}"));
            }
            BodyElementKind::BlindEdge { target } => {
                bcalls.push(target.clone());
                bcodes.push((target.clone(), format!("__bcode_{idx}_{target}")));
            }
            _ => {}
        }
    }
    (acodes, bcodes, bcalls)
}

fn build_rep_bounds(mode: &RuleMode) -> (Option<usize>, Option<usize>) {
    match mode {
        RuleMode::Star => (Some(0), None),
        RuleMode::Plus | RuleMode::OrPlus | RuleMode::AndPlus => (Some(1), None),
        RuleMode::Optional => (Some(0), Some(1)),
        RuleMode::OrBounded { min, max } | RuleMode::AndBounded { min, max } => (Some(*min), *max),
        _ => (None, None),
    }
}

impl RuleMode {
    fn is_repetition(&self) -> bool {
        matches!(self, RuleMode::Star | RuleMode::Plus | RuleMode::OrPlus | RuleMode::AndPlus | RuleMode::Optional | RuleMode::OrBounded { .. } | RuleMode::AndBounded { .. })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ast::{BodyElement, BodyElementKind, RuleHeader};

    #[test]
    fn compile_simple_and_bcode() {
        let rule = Rule {
            header: RuleHeader { label: "Top".into(), is_top: true, mode: RuleMode::And, rest: String::new() },
            body: vec![
                BodyElement::new(BodyElementKind::Regex, "/a/"),
                BodyElement::new(BodyElementKind::BlindEdge { target: "Child".into() }, "=> Child"),
            ],
        };
        let spec = SpecFile { rules: vec![
            rule,
            Rule { header: RuleHeader { label: "Child".into(), is_top: false, mode: RuleMode::Default, rest: String::new() }, body: vec![] },
        ]};
        let handlers = compile(&spec).unwrap();
        assert_eq!(handlers.len(), 2);
        assert_eq!(handlers[0].kind, HandlerKind::AndBcode);
        assert_eq!(handlers[0].parse_mode, ParseMode::Consume);
    }

    #[test]
    fn compile_or_acode() {
        let spec = SpecFile { rules: vec![Rule {
            header: RuleHeader { label: "Top".into(), is_top: true, mode: RuleMode::Default, rest: String::new() },
            body: vec![BodyElement::new(BodyElementKind::ActionEdge { target: "Child".into(), index: 0 }, "-> Child")],
        }]};
        let handlers = compile(&spec).unwrap();
        assert_eq!(handlers[0].kind, HandlerKind::OrAcode);
        assert_eq!(handlers[0].parse_mode, ParseMode::Seek);
    }

    #[test]
    fn compile_rep() {
        let spec = SpecFile { rules: vec![Rule {
            header: RuleHeader { label: "Top".into(), is_top: true, mode: RuleMode::Star, rest: String::new() },
            body: vec![BodyElement::new(BodyElementKind::ActionEdge { target: "C".into(), index: 0 }, "-> C")],
        }]};
        let handlers = compile(&spec).unwrap();
        assert_eq!(handlers[0].kind, HandlerKind::RepAcode);
        assert_eq!(handlers[0].rep_min, Some(0));
        assert_eq!(handlers[0].rep_max, None);
    }

    #[test]
    fn compile_lifecycle() {
        let spec = SpecFile { rules: vec![Rule {
            header: RuleHeader { label: "Top".into(), is_top: true, mode: RuleMode::Default, rest: String::new() },
            body: vec![
                BodyElement::new(BodyElementKind::LifecycleMarker { marker: "I".into() }, "I"),
                BodyElement::new(BodyElementKind::CodeBlock { lifecycle: Some("I".into()), code: "declare(array, results)".into() }, "I { declare(array, results) }"),
            ],
        }]};
        let handlers = compile(&spec).unwrap();
        assert!(handlers[0].preamble.as_ref().unwrap().contains("declare"));
    }

    #[test]
    fn compile_default_or() {
        let spec = SpecFile { rules: vec![Rule {
            header: RuleHeader { label: "Top".into(), is_top: true, mode: RuleMode::Default, rest: String::new() },
            body: vec![BodyElement::new(BodyElementKind::ActionEdge { target: "A".into(), index: 0 }, "-> A")],
        }]};
        let handlers = compile(&spec).unwrap();
        assert_eq!(handlers[0].kind, HandlerKind::OrAcode);
    }
}
