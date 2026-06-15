//! Compiler — transforms parsed `SpecFile` AST into `CompiledSpec` for the runtime.
//!
//! The compiler:
//! 1. Extracts regex patterns from body elements
//! 2. Builds action-edge and blind-call dispatch tables
//! 3. Parses lifecycle code blocks into expression trees
//! 4. Determines parse mode (seek vs consume) per rule
//! 5. Extracts repetition bounds
//!
//! ## Action edge → regex association
//!
//! In Perl LinkedSpec, an action edge fires when the regex that *immediately precedes*
//! it in the rule body matches. The compiler tracks `current_regex_idx` which
//! increments only for regex patterns, not action edges. When an action edge is
//! encountered, it is associated with `current_regex_idx - 1` (the last regex).
//!
//! The `[N]` in `-> rule[N]` is the *child* rule's regex entry slot, preserved
//! in `AcodeEntry.child_regex_idx` for future multi-entrypoint support.

use crate::ast::{BodyElementKind, Rule, SpecFile};
use crate::error::Result;
use crate::expr::CodeBlock;
use crate::types::{AcodeEntry, BcodeEntry, CompiledRule, CompiledSpec, ParseMode};

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
    let mut acode_dispatch: Vec<AcodeEntry> = Vec::new();
    let mut bcode_dispatch: Vec<BcodeEntry> = Vec::new();
    let mut preamble: Option<CodeBlock> = None;
    let mut lxcode: Option<CodeBlock> = None;
    let mut lscode: Option<CodeBlock> = None;
    let mut lecode: Option<CodeBlock> = None;
    let mut ecode: Option<CodeBlock> = None;
    let mut excode: Option<CodeBlock> = None;
    let mut itcode: Option<CodeBlock> = None;

    // Tracks the number of regex patterns seen so far. Each action edge is
    // associated with the last regex that preceded it (current_regex_idx - 1).
    let mut current_regex_idx: usize = 0;

    for element in &rule.body {
        match &element.kind {
            BodyElementKind::Regex { pattern } => {
                regex_patterns.push(pattern.clone());
                current_regex_idx += 1;
            }

            BodyElementKind::ActionEdge { targets, code } => {
                // Action edges fire after the most recent regex matches.
                // If there are no regexes yet (e.g. blind-call only rules),
                // associate with index 0.
                let triggering_regex_idx = if current_regex_idx > 0 {
                    current_regex_idx - 1
                } else {
                    0
                };

                let parsed_code = code
                    .as_ref()
                    .and_then(|c| {
                        CodeBlock::parse(c)
                            .map_err(|e| {
                                // Log the parse failure but don't crash — the
                                // validation layer should catch these earlier.
                                eprintln!(
                                    "warning: rule '{}': failed to parse action code: {e}",
                                    rule.header.label
                                );
                            })
                            .ok()
                    });

                for target in targets {
                    let child_regex_idx = target.index; // from `-> rule[N]`
                    acode_dispatch.push(AcodeEntry {
                        regex_idx: triggering_regex_idx,
                        child_label: target.label.clone(),
                        child_regex_idx,
                        code: parsed_code.clone(),
                    });
                }
            }

            BodyElementKind::BlindEdge {
                target,
                code,
                fluent_chain,
            } => {
                let parsed_code = code.as_ref().and_then(|c| {
                    CodeBlock::parse(c)
                        .map_err(|e| {
                            eprintln!(
                                "warning: rule '{}': failed to parse blind-call code: {e}",
                                rule.header.label
                            );
                        })
                        .ok()
                });

                // Preserve fluent chain as structured data (method_name, args_string).
                let fluent: Vec<(String, String)> = fluent_chain
                    .iter()
                    .map(|fc| (fc.method.clone(), fc.args.clone()))
                    .collect();

                bcode_dispatch.push(BcodeEntry {
                    child_label: target.clone(),
                    code: parsed_code,
                    fluent_chain: fluent,
                });
            }

            BodyElementKind::CodeBlock { lifecycle, code } => {
                let parsed = CodeBlock::parse(code)
                    .map_err(|e| {
                        eprintln!(
                            "warning: rule '{}': failed to parse {} -block code: {e}",
                            rule.header.label, lifecycle
                        );
                    })
                    .ok();
                if let Some(block) = parsed {
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

            // Lifecycle markers without code blocks are no-ops at compile time.
            BodyElementKind::LifecycleMarker { .. } => {}
            // Fluent chains on action edges are handled by attaching code to the
            // action edge itself — they're already in the ActionEdge.code field.
            BodyElementKind::FluentChain { .. } => {}
            // Conditional markers (`-? word`) are consumed by the runtime.
            BodyElementKind::Conditional { .. } => {}
            // Split markers (@capture_slice, @mark) are consumed by the runtime
            // during regex matching — no compile-time action needed.
            BodyElementKind::SplitMarker { .. } => {}
            // Plain code blocks and raw text are unexpected at compile time.
            BodyElementKind::PlainBlock { .. } | BodyElementKind::Raw { .. } => {}
        }
    }

    // Determine parse mode: AND-type → consume, otherwise seek.
    // Blind-call-dispatch rules also use consume mode (sequential stepping).
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

    // ── Action edge → regex association tests ──

    #[test]
    fn compile_action_edge_associated_with_preceding_regex() {
        // /a/ -> Child_A    should associate with regex index 0
        // /b/ -> Child_B    should associate with regex index 1
        let src = "DemoParser::\n /a/ -> Child_A\n /b/ -> Child_B";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = &compiled.rules[0];
        assert_eq!(rule.regex_patterns.len(), 2);
        assert_eq!(rule.acode_dispatch.len(), 2);
        // First action edge (-> Child_A) should be associated with regex[0] (/a/)
        assert_eq!(rule.acode_dispatch[0].regex_idx, 0);
        assert_eq!(rule.acode_dispatch[0].child_label, "Child_A");
        // Second action edge (-> Child_B) should be associated with regex[1] (/b/)
        assert_eq!(rule.acode_dispatch[1].regex_idx, 1);
        assert_eq!(rule.acode_dispatch[1].child_label, "Child_B");
    }

    #[test]
    fn compile_action_edge_multiple_targets_per_regex() {
        // /a/ -> Child_A | Child_B    both associated with regex[0]
        let src = "DemoParser::\n /a/ -> Child_A | Child_B";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = &compiled.rules[0];
        assert_eq!(rule.acode_dispatch.len(), 2);
        assert_eq!(rule.acode_dispatch[0].regex_idx, 0);
        assert_eq!(rule.acode_dispatch[1].regex_idx, 0);
    }

    #[test]
    fn compile_action_edge_no_regex() {
        // Edge-only rules (blind-call style via action edges) associate with index 0
        let src = "Wrapper::\n -> Child { return(1) }";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = &compiled.rules[0];
        assert_eq!(rule.acode_dispatch.len(), 1);
        assert_eq!(rule.acode_dispatch[0].regex_idx, 0);
    }

    #[test]
    fn compile_preserves_child_regex_index() {
        // -> Child[2]  should preserve child_regex_idx = 2
        let src = "DemoParser::\n /a/ -> Child[2]";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = &compiled.rules[0];
        assert_eq!(rule.acode_dispatch[0].child_regex_idx, 2);
    }

    #[test]
    fn compile_spec_with_fluent_chain_blind_edge() {
        // Blind edge with fluent chain should preserve both as structured data
        let src = "Wrapper::AND\n => child .declare(scalar, name)";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = &compiled.rules[0];
        assert_eq!(rule.bcode_dispatch.len(), 1);
        assert_eq!(rule.bcode_dispatch[0].child_label, "child");
        // Fluent chain stored as structured (method, args) pairs
        assert_eq!(rule.bcode_dispatch[0].fluent_chain.len(), 1);
        assert_eq!(rule.bcode_dispatch[0].fluent_chain[0].0, "declare");
        assert_eq!(rule.bcode_dispatch[0].fluent_chain[0].1, "scalar, name");
    }

    #[test]
    fn compile_all_shipped_specs_to_json() {
        // Verify all shipped specs compile and serialize to valid JSON.
        use std::fs;
        use std::path::Path;

        let specs_dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("../../specs");
        if !specs_dir.exists() {
            eprintln!("specs/ directory not found, skipping");
            return;
        }

        for entry in fs::read_dir(&specs_dir).unwrap() {
            let entry = entry.unwrap();
            let path = entry.path();
            if path.extension().is_some_and(|e| e == "spec") {
                let source = fs::read_to_string(&path).unwrap();
                let spec = parse_spec(&source).unwrap();
                let compiled = compile(&spec).unwrap();
                // Verify serde roundtrip
                let json = serde_json::to_string(&compiled).unwrap();
                let _back: CompiledSpec = serde_json::from_str(&json).unwrap();
                assert!(!compiled.rules.is_empty(),
                    "compiled spec {} has no rules", path.display());
                // Every rule should have a label
                for rule in &compiled.rules {
                    assert!(!rule.label.is_empty());
                }
            }
        }
    }
}
