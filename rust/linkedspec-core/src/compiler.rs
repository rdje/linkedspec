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
//! The compiler uses a two-phase model mirroring Perl's `build_dependency_regex_map`:
//!
//! **Phase 1 (per-rule)**: Tracks whether each action edge immediately follows a
//! `/regex/` element. Edges that do ("anchored") keep their parent regex index.
//! Edges that don't ("edge-only") get a placeholder `regex_idx = 0`.
//!
//! **Phase 2 (post-processing)**: `build_dependency_regex_map` runs after all
//! rules are compiled. For each edge-only entry, it looks up the child rule,
//! extracts the child's regex at `child_regex_idx`, appends it to the parent's
//! `regex_patterns`, and updates `regex_idx` to the new alternation position.
//!
//! Parent regexes always come first in the alternation; child-resolved regexes
//! are appended after. This matches Perl's semantics where `dependency_refs`
//! contribute child rule entrypoint regexes to the parent's LinkedRE alternation.
//!
//! The `[N]` in `-> rule[N]` is the *child* rule's regex entry slot, preserved
//! in `AcodeEntry.child_regex_idx` and used during Phase 2 resolution.

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
    let mut compiled = CompiledSpec { rules };
    build_dependency_regex_map(&mut compiled)?;
    Ok(compiled)
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

    // Track the source line of the last `/regex/` element seen.
    // An action edge is "anchored" (has_parent_regex = true) only when it
    // appears on the SAME source line as the regex (e.g. `/pat/ -> Child`).
    // Edges on their own line (different line number) are "edge-only" and
    // will be resolved in Phase 2 post-processing.
    let mut current_regex_idx: usize = 0;
    let mut last_regex_line: Option<usize> = None;

    for element in &rule.body {
        match &element.kind {
            BodyElementKind::Regex { pattern } => {
                regex_patterns.push(pattern.clone());
                current_regex_idx += 1;
                last_regex_line = Some(element.line);
            }

            BodyElementKind::ActionEdge { targets, code } => {
                // An edge is anchored iff it shares the same source line as
                // the immediately preceding regex (same-line adjacency).
                let has_parent = last_regex_line == Some(element.line);
                let triggering_regex_idx = if has_parent && current_regex_idx > 0 {
                    current_regex_idx - 1
                } else {
                    0 // placeholder; post-processing fixes edge-only entries
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
                        has_parent_regex: has_parent,
                    });
                }

                last_regex_line = None;
            }

            BodyElementKind::BlindEdge {
                target,
                code,
                fluent_chain,
            } => {
                last_regex_line = None;
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
                last_regex_line = None;
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

            // Lifecycle markers without code blocks — reset adjacency tracking.
            BodyElementKind::LifecycleMarker { .. } => { last_regex_line = None; }
            // Fluent chains on action edges are handled by attaching code to the
            // action edge itself — they're already in the ActionEdge.code field.
            BodyElementKind::FluentChain { .. } => { last_regex_line = None; }
            // Conditional markers (`-? word`) are consumed by the runtime.
            BodyElementKind::Conditional { .. } => { last_regex_line = None; }
            // Split markers (@capture_slice, @mark) are consumed by the runtime
            // during regex matching — no compile-time action needed.
            BodyElementKind::SplitMarker { .. } => { last_regex_line = None; }
            // Plain code blocks and raw text are unexpected at compile time.
            BodyElementKind::PlainBlock { .. } | BodyElementKind::Raw { .. } => { last_regex_line = None; }
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

/// Resolve edge-only action entries by looking up child rules' regex patterns.
///
/// This is the Rust equivalent of Perl's `LinkedSpec::Compiler::build_dependency_regex_map`.
///
/// For each rule, entries with `has_parent_regex == false` ("edge-only") have no
/// parent regex to trigger on. Instead, the child rule's regex at `child_regex_idx`
/// is appended to this rule's alternation, and `regex_idx` is updated to point to
/// the new alternation position.
///
/// Parent regexes always come first (positions 0..P-1). Child-resolved regexes
/// are appended at positions P..P+C-1. Anchored entries (`has_parent_regex == true`)
/// are untouched — they keep their parent regex positions.
///
/// Self-recursive entries (`-> SameRule[N]`) resolve against the rule's own
/// already-populated parent regexes, duplicating them at new alternation positions.
pub fn build_dependency_regex_map(spec: &mut CompiledSpec) -> Result<()> {
    // Collect all edge-only resolutions first (to avoid simultaneous
    // mutable borrow of rules + immutable borrow of spec for find()).
    struct EdgeResolution {
        rule_idx: usize,
        entry_idx: usize,
        child_label: String,
        child_regex_idx: usize,
    }

    let mut resolutions: Vec<EdgeResolution> = Vec::new();
    for (rule_idx, rule) in spec.rules.iter().enumerate() {
        for (entry_idx, entry) in rule.acode_dispatch.iter().enumerate() {
            if !entry.has_parent_regex {
                resolutions.push(EdgeResolution {
                    rule_idx,
                    entry_idx,
                    child_label: entry.child_label.clone(),
                    child_regex_idx: entry.child_regex_idx,
                });
            }
        }
    }

    // Resolve each edge-only entry against child rules.
    // Following Perl's Compiler.pm:393-410, missing/out-of-bounds regex
    // indices are warned and skipped, not treated as compilation errors.
    //
    // Self-recursive entries (-> SameRule[N]) are a special case: the child
    // regex is already in this rule's alternation at its parent position.
    // Instead of duplicating it, point regex_idx directly at the parent slot.
    for res in &resolutions {
        let rule_label = spec.rules[res.rule_idx].label.clone();

        // Self-recursive: the child is the same rule.  The parent regex at
        // child_regex_idx is already in this rule's alternation (positions
        // 0..parent_count-1), so just point regex_idx at it directly.
        if res.child_label == rule_label {
            let parent_count = spec.rules[res.rule_idx].regex_patterns.len();
            if res.child_regex_idx < parent_count {
                spec.rules[res.rule_idx]
                    .acode_dispatch[res.entry_idx]
                    .regex_idx = res.child_regex_idx;
            } else {
                eprintln!(
                    "warning: rule '{}': self-recursive entry '-> {}[{}]' \
                     references out-of-bounds regex index {} (has {} parent \
                     regexes) — entry will never fire",
                    rule_label,
                    res.child_label,
                    res.child_regex_idx,
                    res.child_regex_idx,
                    parent_count
                );
            }
            continue;
        }

        let child = match spec.find(&res.child_label) {
            Some(c) => c,
            None => {
                eprintln!(
                    "warning: rule '{}': edge-only entry '-> {}[{}]' \
                     references unknown rule '{}' — entry will never fire",
                    rule_label,
                    res.child_label,
                    res.child_regex_idx,
                    res.child_label
                );
                continue;
            }
        };

        if res.child_regex_idx >= child.regex_patterns.len() {
            eprintln!(
                "warning: rule '{}': edge-only entry '-> {}[{}]' \
                 references out-of-bounds regex index {} in child rule \
                 '{}' (has {} regexes) — entry will never fire",
                rule_label,
                res.child_label,
                res.child_regex_idx,
                res.child_regex_idx,
                res.child_label,
                child.regex_patterns.len()
            );
            continue;
        }

        let resolved_pattern =
            child.regex_patterns[res.child_regex_idx].clone();
        let rule = &mut spec.rules[res.rule_idx];
        let new_regex_idx = rule.regex_patterns.len();
        rule.regex_patterns.push(resolved_pattern);
        rule.acode_dispatch[res.entry_idx].regex_idx = new_regex_idx;
    }

    Ok(())
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
        // Edge-only rules get child regexes resolved during post-processing.
        // -> Child { return(1) } is edge-only (no preceding /regex/), so Child's
        // regex is added to Wrapper's alternation at position 0.
        let src = "Wrapper::\n -> Child { return(1) }\n\nChild:\n /child_pattern/";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = &compiled.rules[0];
        assert_eq!(rule.acode_dispatch.len(), 1);
        // Child's regex was resolved and added at position 0
        assert_eq!(rule.acode_dispatch[0].regex_idx, 0);
        assert_eq!(rule.regex_patterns.len(), 1);
        assert_eq!(rule.regex_patterns[0], "child_pattern");
        assert!(!rule.acode_dispatch[0].has_parent_regex);
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

    // ── build_dependency_regex_map tests ──

    #[test]
    fn build_dependency_regex_map_resolves_edge_only_entries() {
        // grep::-style: all entries are edge-only, each gets a unique alternation position
        let src = "grep::\n -> re_term { assign(s(retv), call(re_term)) }\n -> or_op { assign(s(retv), call(or_op)) }\n\nre_term:\n /re_term_pattern/\nor_op:\n /or_op_pattern/\n";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let grep = compiled.find("grep").unwrap();
        // grep has no parent regexes, all come from children
        assert_eq!(grep.regex_patterns.len(), 2);
        assert_eq!(grep.regex_patterns[0], "re_term_pattern");
        assert_eq!(grep.regex_patterns[1], "or_op_pattern");
        // Each edge-only entry gets its own alternation position
        assert_eq!(grep.acode_dispatch[0].regex_idx, 0);
        assert_eq!(grep.acode_dispatch[1].regex_idx, 1);
        assert!(!grep.acode_dispatch[0].has_parent_regex);
        assert!(!grep.acode_dispatch[1].has_parent_regex);
    }

    #[test]
    fn build_dependency_regex_map_parent_regexes_come_first() {
        // Parent regexes at 0..P-1, child-resolved regexes at P..P+C-1
        let src = "Top::\n /parent_a/ -> Child_A\n /parent_b/ -> Child_B\n -> EdgeOnly\n\nChild_A:\n /child_a/\nChild_B:\n /child_b/\nEdgeOnly:\n /edge_only_regex/\n";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let top = compiled.find("Top").unwrap();
        // regex_patterns order: parent_a, parent_b, edge_only_regex
        assert_eq!(top.regex_patterns.len(), 3);
        assert_eq!(top.regex_patterns[0], "parent_a");
        assert_eq!(top.regex_patterns[1], "parent_b");
        assert_eq!(top.regex_patterns[2], "edge_only_regex");
        // Anchored entries keep their parent regex positions
        assert_eq!(top.acode_dispatch[0].regex_idx, 0); // -> Child_A (anchored to parent_a)
        assert_eq!(top.acode_dispatch[1].regex_idx, 1); // -> Child_B (anchored to parent_b)
        assert!(top.acode_dispatch[0].has_parent_regex);
        assert!(top.acode_dispatch[1].has_parent_regex);
        // Edge-only entry gets the resolved child regex at position 2
        assert_eq!(top.acode_dispatch[2].regex_idx, 2); // -> EdgeOnly
        assert!(!top.acode_dispatch[2].has_parent_regex);
    }

    #[test]
    fn build_dependency_regex_map_self_recursive_rule() {
        // Self-recursive entries point to parent regex positions directly —
        // no duplication needed since the regex is already in the alternation.
        let src = "Expr::\n /[A-Za-z_]/\n /\\d+/\n -> Expr\n -> Expr[1]\n";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let expr = compiled.find("Expr").unwrap();
        // Only parent regexes (self-refs use existing positions)
        assert_eq!(expr.regex_patterns.len(), 2);
        assert_eq!(expr.regex_patterns[0], "[A-Za-z_]");
        assert_eq!(expr.regex_patterns[1], r"\d+");
        // Self-refs point to parent positions: Expr[0]→0, Expr[1]→1
        assert_eq!(expr.acode_dispatch[0].regex_idx, 0);
        assert_eq!(expr.acode_dispatch[1].regex_idx, 1);
        assert_eq!(expr.acode_dispatch[0].child_regex_idx, 0);
        assert_eq!(expr.acode_dispatch[1].child_regex_idx, 1);
        assert!(!expr.acode_dispatch[0].has_parent_regex);
        assert!(!expr.acode_dispatch[1].has_parent_regex);
    }

    #[test]
    fn build_dependency_regex_map_missing_child_rule_warns_and_continues() {
        // Missing child rules emit a warning but don't fail compilation.
        // The edge-only entry keeps regex_idx = 0 (placeholder, will never match).
        let src = "Top::\n -> DoesNotExist\n";
        let spec = parse_spec(src).unwrap();
        let result = compile(&spec);
        assert!(result.is_ok()); // compiles despite missing child
        let compiled = result.unwrap();
        let top = compiled.find("Top").unwrap();
        assert_eq!(top.regex_patterns.len(), 0); // nothing resolved
        assert_eq!(top.acode_dispatch[0].regex_idx, 0); // placeholder kept
        assert!(!top.acode_dispatch[0].has_parent_regex);
    }

    #[test]
    fn build_dependency_regex_map_child_regex_out_of_bounds_warns_and_continues() {
        let src = "Top::\n -> Child[5]\n\nChild:\n /only_one/\n";
        let spec = parse_spec(src).unwrap();
        let result = compile(&spec);
        assert!(result.is_ok()); // compiles despite OOB index
        let compiled = result.unwrap();
        let top = compiled.find("Top").unwrap();
        assert_eq!(top.regex_patterns.len(), 0); // nothing resolved (index 5 >= 1)
        assert_eq!(top.acode_dispatch[0].regex_idx, 0); // placeholder kept
    }

    #[test]
    fn build_dependency_regex_map_no_edge_only_entries_is_noop() {
        // Rule with only anchored edges — regex_patterns and regex_idx unchanged
        let src = "Top::\n /a/ -> Child_A\n /b/ -> Child_B\n\nChild_A:\n /ca/\nChild_B:\n /cb/\n";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let top = compiled.find("Top").unwrap();
        assert_eq!(top.regex_patterns.len(), 2); // only parent regexes
        assert_eq!(top.regex_patterns[0], "a");
        assert_eq!(top.regex_patterns[1], "b");
        assert_eq!(top.acode_dispatch[0].regex_idx, 0);
        assert_eq!(top.acode_dispatch[1].regex_idx, 1);
    }

    #[test]
    fn build_dependency_regex_map_has_parent_regex_flag() {
        // Verify has_parent_regex is correctly set for anchored vs edge-only
        let src = "DemoParser::\n /a/ -> Child_A | Child_B\n -> Child_C\n\nChild_A:\n /ca/\nChild_B:\n /cb/\nChild_C:\n /cc/\n";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = compiled.find("DemoParser").unwrap();
        // /a/ -> Child_A | Child_B: both anchored (same line as /a/)
        assert!(rule.acode_dispatch[0].has_parent_regex);
        assert!(rule.acode_dispatch[1].has_parent_regex);
        // -> Child_C: edge-only (no preceding regex)
        assert!(!rule.acode_dispatch[2].has_parent_regex);
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

    #[test]
    fn header_line_bracket_pair_self_recursive_close_edge_resolves() {
        // RUST-PARITY.7.5.1: a `/open/ /close/` bracket pair written on the rule's
        // HEADER line must register both regexes (open=0, close=1), so the
        // self-recursive `-> bracket[1]` close edge resolves to index 1 — exactly
        // the recursive-descent bracket matcher in tclite/Lispish. Before the fix
        // group 3 ate the open delimiter, leaving only `close` at index 0 and
        // making `bracket[1]` out-of-bounds ("never fires"). This mirrors the
        // existing `build_dependency_regex_map_self_recursive_rule` test but with
        // the pair on the header line rather than separate body lines.
        let src = "Top::\n -> bracket\n\nbracket : /\\(/ /\\)/\n -> bracket\n -> bracket[1]\n";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let bracket = compiled.find("bracket").unwrap();
        // Both header-line regexes registered, open first then close.
        assert_eq!(bracket.regex_patterns.len(), 2);
        assert_eq!(bracket.regex_patterns[0], "\\(");
        assert_eq!(bracket.regex_patterns[1], "\\)");
        // Self-recursive edges point at the existing parent positions:
        // `-> bracket` (index 0 = open), `-> bracket[1]` (index 1 = close).
        assert_eq!(bracket.acode_dispatch[0].regex_idx, 0);
        assert_eq!(bracket.acode_dispatch[0].child_regex_idx, 0);
        assert_eq!(bracket.acode_dispatch[1].regex_idx, 1);
        assert_eq!(bracket.acode_dispatch[1].child_regex_idx, 1);
        // The parent's `-> bracket` edge-only entry resolves against bracket's
        // entry (open) regex, appended to Top's alternation.
        let top = compiled.find("Top").unwrap();
        assert_eq!(top.regex_patterns.len(), 1);
        assert_eq!(top.regex_patterns[0], "\\(");
    }
}
