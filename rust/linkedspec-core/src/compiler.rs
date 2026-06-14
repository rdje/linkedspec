//! Compiler — transforms parsed `SpecFile` AST into `CompiledSpec` for the runtime.
//!
//! The compiler:
//! 1. Extracts regex patterns from body elements
//! 2. Builds action-edge and blind-call dispatch tables
//! 3. Parses lifecycle code blocks into expression trees
//! 4. Determines parse mode (seek vs consume) per rule
//! 5. Extracts repetition bounds

use crate::ast::{BodyElementKind, Rule, SpecFile};
use crate::error::Result;
use crate::expr::CodeBlock;
use crate::types::{CompiledRule, CompiledSpec, ParseMode};

/// Compile a parsed `SpecFile` into a `CompiledSpec` ready for the runtime.
pub fn compile(spec: &SpecFile) -> Result<CompiledSpec> {
    let mut rules = Vec::new();
    for rule in &spec.rules {
        rules.push(compile_rule(rule)?);
    }
    Ok(CompiledSpec { rules })
}

fn compile_rule(rule: &Rule) -> Result<CompiledRule> {
    let mut regex_patterns: Vec<String> = Vec::new();
    let mut acode_dispatch: Vec<(usize, String, Option<CodeBlock>)> = Vec::new();
    let mut bcode_dispatch: Vec<(String, Option<CodeBlock>)> = Vec::new();
    let mut preamble: Option<CodeBlock> = None;
    let mut lxcode: Option<CodeBlock> = None;
    let mut lscode: Option<CodeBlock> = None;
    let mut lecode: Option<CodeBlock> = None;
    let mut ecode: Option<CodeBlock> = None;
    let mut excode: Option<CodeBlock> = None;
    let mut itcode: Option<CodeBlock> = None;

    let mut regex_idx: usize = 0;

    for element in &rule.body {
        match &element.kind {
            // Regex patterns — each becomes a dispatch alternative
            BodyElementKind::Regex { pattern } => {
                regex_patterns.push(pattern.clone());
                regex_idx += 1;
            }

            // Action edges — linked to a specific regex index
            BodyElementKind::ActionEdge { targets, code } => {
                let parsed_code = code.as_ref().and_then(|c| CodeBlock::parse(c).ok());
                for target in targets {
                    let idx = target.index.max(0).min(regex_idx.max(1) - 1);
                    acode_dispatch.push((idx, target.label.clone(), parsed_code.clone()));
                }
                if !targets.is_empty() {
                    regex_idx += 1;
                }
            }

            // Blind-call edges — dispatched by rule label, not regex
            BodyElementKind::BlindEdge { target, code, .. } => {
                let parsed_code = code.as_ref().and_then(|c| CodeBlock::parse(c).ok());
                bcode_dispatch.push((target.clone(), parsed_code));
            }

            // Lifecycle code blocks
            BodyElementKind::CodeBlock { lifecycle, code } => {
                if let Ok(block) = CodeBlock::parse(code) {
                    match lifecycle.as_str() {
                        "I" => preamble = Some(block),
                        "LS" => lscode = Some(block),
                        "LE" => lecode = Some(block),
                        "E" => ecode = Some(block),
                        "EX" => excode = Some(block),
                        "IT" => itcode = Some(block),
                        "LX" => lxcode = Some(block),
                        _ => {}
                    }
                }
            }

            _ => {}
        }
    }

    // Determine parse mode: AND-type → consume, otherwise seek
    let parse_mode = if rule.header.mode.is_and() || !bcode_dispatch.is_empty() {
        ParseMode::Consume
    } else {
        ParseMode::Seek
    };

    let rep_min = rule.header.mode.rep_min();
    let rep_max = rule.header.mode.rep_max();

    Ok(CompiledRule {
        label: rule.header.label.clone(),
        is_top: rule.header.is_top,
        parse_mode,
        regex_patterns,
        acode_dispatch,
        bcode_dispatch,
        preamble,
        lxcode,
        lscode,
        lecode,
        ecode,
        excode,
        itcode,
        rep_min,
        rep_max,
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::parser::parse_spec;

    #[test]
    fn compile_simple_spec() {
        let src = "DemoParser::\n /pattern1/ -> Child {\n  return(42)\n }\n\nChild:\n /hello/ E { return(undef) }";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        assert_eq!(compiled.rules.len(), 2);
        assert_eq!(compiled.rules[0].label, "DemoParser");
        assert!(compiled.rules[0].is_top);
        assert_eq!(compiled.rules[0].parse_mode, ParseMode::Seek);
    }

    #[test]
    fn compile_lifecycle_blocks() {
        let src = "Top::\n /x/ I { declare(array, results) } LE { push_value(array(results), scalar(retv)) } E { return(array_copy(array(results))) }";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        assert!(compiled.rules[0].preamble.is_some()); // I-block
        assert!(compiled.rules[0].lecode.is_some());    // LE-block
        assert!(compiled.rules[0].ecode.is_some());     // E-block
    }

    #[test]
    fn compile_handles_and_mode() {
        let src = "Top::AND\n /a/ /b/";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        assert_eq!(compiled.rules[0].parse_mode, ParseMode::Consume);
    }

    #[test]
    fn compile_extracts_regex_patterns() {
        let src = "Top::\n /hello/ /world/";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        assert_eq!(compiled.rules[0].regex_patterns.len(), 2);
    }

    #[test]
    fn compile_serialize_deserialize() {
        let src = "Top::\n /x/ I { declare(array, r) } LE { push_value(array(r), scalar(retv)) } E { return(array_copy(array(r))) }";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let json = serde_json::to_string(&compiled).unwrap();
        let _back: CompiledSpec = serde_json::from_str(&json).unwrap();
    }
}
