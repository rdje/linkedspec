//! End-to-end integration tests: parse → validate → compile → execute.

use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::Engine;
use serde_json::Value;

const SIMPLE_GRAMMAR: &str = r#"DemoParser::
 /pattern1/ -> Child {
  I { declare(array, results) }
  LE { push_value(array(results), scalar(retv)) }
  E { return(array("?results:", array_copy(array(results)))) }
 }

Child::
 /hello[ \t]+(\w+)/
 I { declare(scalar, name=entry_group(1)) }
 E { return(scalar(name)) }
"#;

#[test]
fn full_pipeline_simple_grammar() {
    let spec = parse_spec(SIMPLE_GRAMMAR).expect("parse");
    assert_eq!(spec.rules.len(), 2);
    validate(&spec).expect("validate");
    let compiled = compile(&spec).expect("compile");
    assert_eq!(compiled.rules.len(), 2);
    let engine = Engine::new(compiled);
    let result = engine.execute("pattern1 hello world").expect("execute");
    assert!(result.is_array());
}

#[test]
fn full_pipeline_empty_input() {
    let spec = parse_spec(SIMPLE_GRAMMAR).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let engine = Engine::new(compiled);
    let result = engine.execute("no match here").unwrap();
    assert!(result.is_array());
}

#[test]
fn json_output_roundtrip() {
    let spec = parse_spec(SIMPLE_GRAMMAR).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let engine = Engine::new(compiled);
    let result = engine.execute("pattern1 hello world").unwrap();
    let json_str = serde_json::to_string(&result).unwrap();
    let parsed: Value = serde_json::from_str(&json_str).unwrap();
    assert_eq!(result, parsed);
}

#[test]
fn parse_all_shipped_specs() {
    use std::fs;
    use std::path::Path;
    let specs_dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("../../specs");
    if !specs_dir.exists() {
        eprintln!("specs/ directory not found, skipping shipped-spec test");
        return;
    }
    let mut parsed = 0;
    let mut failed = Vec::new();
    for entry in fs::read_dir(&specs_dir).unwrap() {
        let entry = entry.unwrap();
        let path = entry.path();
        if path.extension().is_some_and(|e| e == "spec") {
            let source = fs::read_to_string(&path).unwrap();
            match parse_spec(&source) {
                Ok(spec) => {
                    if let Err(e) = validate(&spec) {
                        failed.push(format!("{}: validation failed: {e}", path.display()));
                    } else if let Err(e) = compile(&spec) {
                        failed.push(format!("{}: compile failed: {e}", path.display()));
                    } else {
                        parsed += 1;
                    }
                }
                Err(e) => failed.push(format!("{}: parse failed: {e}", path.display())),
            }
        }
    }
    println!("Parsed {} specs successfully", parsed);
    if !failed.is_empty() {
        for f in &failed {
            eprintln!("  FAIL: {f}");
        }
        panic!("{} specs failed", failed.len());
    }
    assert!(parsed > 0, "no .spec files found");
}

// ── Test corpus runner (.7.1) ──

#[test]
fn corpus_simple_grammar_returns_expected_output() {
    let spec = parse_spec(SIMPLE_GRAMMAR).expect("parse");
    validate(&spec).expect("validate");
    let compiled = compile(&spec).expect("compile");
    let engine = Engine::new(compiled);
    let result = engine.execute("pattern1 hello world").unwrap();
    assert!(result.is_array());
    let arr = result.as_array().unwrap();
    assert!(!arr.is_empty(), "expected non-empty result array");
}

#[test]
fn corpus_recursive_grammar() {
    let grammar = r#"Expr::
 /[A-Za-z_]\w*/
 /"(?:[^"\\]|\\.)*"/
 /\d+/
 /\(/
 /\)/
 I { declare(array, results) }
 LE { push_value(array(results), entry_text()) }
 -> Expr
 -> Expr[1]
 -> Expr[2]
 E { return(array_copy(array(results))) }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let engine = Engine::new(compiled);
    let result = engine.execute(r#"hello "world" 42"#).unwrap();
    assert!(result.is_array());
}

#[test]
fn corpus_lifecycle_ordered_output() {
    let grammar = r#"OrderedParser::
 /(\w+)/
 I { declare(array, log); push_value(array(log), scalar("I")) }
 LS { push_value(array(log), scalar("LS")) }
 LE { push_value(array(log), entry_group(1)) }
 E { push_value(array(log), scalar("E")); return(array_copy(array(log))) }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let engine = Engine::new(compiled);
    let result = engine.execute("hello").unwrap();
    let outer: &Vec<Value> = result.as_array().unwrap();
    let inner: &Vec<Value> = outer[0].as_array().unwrap();
    let strs: Vec<&str> = inner.iter().map(|v| v.as_str().unwrap()).collect();
    assert_eq!(strs[0], "I");
    assert_eq!(strs[1], "LS");
    assert_eq!(strs[2], "hello");
    assert_eq!(strs[3], "E");
}

#[test]
fn corpus_blind_call_and_rule() {
    let grammar = r#"Top::AND
 I { declare(array, log) }
 => ChildA
 => ChildB
 E { return(array_copy(array(log))) }

ChildA:
 /a/
 I { push_value(array(log), scalar("A")) }

ChildB:
 /b/
 I { push_value(array(log), scalar("B")) }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let engine = Engine::new(compiled);
    let result = engine.execute("a b").unwrap();
    let outer: &Vec<Value> = result.as_array().unwrap();
    let inner: &Vec<Value> = outer[0].as_array().unwrap();
    assert_eq!(inner.len(), 2);
    assert_eq!(inner[0].as_str().unwrap(), "A");
    assert_eq!(inner[1].as_str().unwrap(), "B");
}

#[test]
fn corpus_rep_with_bounds() {
    let grammar = r#"Repeater::OR{1,3}
 /(\w+)/
 I { declare(array, words) }
 LE { push_value(array(words), entry_group(1)) }
 E { return(array_copy(array(words))) }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let engine = Engine::new(compiled);
    let result = engine.execute("one two three four five").unwrap();
    let outer: &Vec<Value> = result.as_array().unwrap();
    let inner: &Vec<Value> = outer[0].as_array().unwrap();
    assert!(inner.len() >= 1 && inner.len() <= 3,
        "expected 1-3 matches, got {}: {:?}", inner.len(), inner);
}

// ── RUST-EDGE-SEMANTICS.3 regression tests ──

// (a) Edge-only rule: top rule with zero /regex/ patterns, all regexes
// come from child rules via build_dependency_regex_map.
#[test]
fn regression_edge_only_rule_dispatches_to_children() {
    let grammar = r#"DispatchParser::
 -> Word { return(scalar(entry_text())) }
 -> Number { return(scalar(entry_text())) }

Word:
 /[A-Za-z]+/
 E { return(scalar(entry_text())) }

Number:
 /\d+/
 E { return(scalar(entry_text())) }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let dp = compiled.find("DispatchParser").unwrap();
    assert_eq!(dp.regex_patterns.len(), 2);
    assert!(dp.acode_dispatch.iter().all(|e| !e.has_parent_regex));
    assert_eq!(dp.acode_dispatch[0].regex_idx, 0);
    assert_eq!(dp.acode_dispatch[1].regex_idx, 1);

    let engine = Engine::new(compiled);
    // "hello" matches Word's regex at alternation position 0
    let r = engine.execute("hello").unwrap();
    let arr = r.as_array().unwrap();
    assert!(!arr.is_empty());
    assert_eq!(arr[0].as_str().unwrap(), "hello");
    // "42" matches Number's regex at alternation position 1
    let r = engine.execute("42").unwrap();
    let arr = r.as_array().unwrap();
    assert_eq!(arr[0].as_str().unwrap(), "42");
}

// (b) Mixed rule: both /regex/ entries and edge-only entries.
// Parent regexes come first, child-resolved after.
#[test]
fn regression_mixed_regex_and_edge_rule() {
    let grammar = r#"MixedParser::
 /[Hh]i/ -> ChildA
 /[Bb]ye/ -> ChildB
 -> ChildC

ChildA:
 /[Hh]i/
 E { return(scalar("child_a")) }

ChildB:
 /[Bb]ye/
 E { return(scalar("child_b")) }

ChildC:
 /extra/
 E { return(scalar("child_c")) }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let mixed = compiled.find("MixedParser").unwrap();
    assert_eq!(mixed.regex_patterns.len(), 3);
    assert!(mixed.acode_dispatch[0].has_parent_regex);
    assert_eq!(mixed.acode_dispatch[0].regex_idx, 0);
    assert!(mixed.acode_dispatch[1].has_parent_regex);
    assert_eq!(mixed.acode_dispatch[1].regex_idx, 1);
    assert!(!mixed.acode_dispatch[2].has_parent_regex);
    assert_eq!(mixed.acode_dispatch[2].regex_idx, 2);

    let engine = Engine::new(compiled);
    assert_eq!(engine.execute("Hi").unwrap().as_array().unwrap()[0].as_str().unwrap(), "child_a");
    assert_eq!(engine.execute("Bye").unwrap().as_array().unwrap()[0].as_str().unwrap(), "child_b");
    assert_eq!(engine.execute("extra").unwrap().as_array().unwrap()[0].as_str().unwrap(), "child_c");
}

// (c) Self-recursive rule with -> same_rule[N].
// Self-recursive edge-only entries point to parent regex positions directly.
// The existing corpus_recursive_grammar test already covers self-recursive
// execution; this test focuses on the compiler output for the self-recursive
// edge-only case.
#[test]
fn regression_self_recursive_multi_entrypoint_compiler_output() {
    let grammar = r#"Expr::
 /[A-Za-z_]\w*/
 /\d+/
 /"[^"]*"/
 -> Expr
 -> Expr[1]
 -> Expr[2]
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let expr = compiled.find("Expr").unwrap();
    // Parent regexes only — self-refs point to these directly
    assert_eq!(expr.regex_patterns.len(), 3);
    assert!(!expr.acode_dispatch[0].has_parent_regex);
    assert_eq!(expr.acode_dispatch[0].regex_idx, 0);
    assert!(!expr.acode_dispatch[1].has_parent_regex);
    assert_eq!(expr.acode_dispatch[1].regex_idx, 1);
    assert!(!expr.acode_dispatch[2].has_parent_regex);
    assert_eq!(expr.acode_dispatch[2].regex_idx, 2);
}

// (d) Grouped targets: -> A | B { code } shares regex_idx and code block.
#[test]
fn regression_grouped_edge_targets() {
    let grammar = r#"GroupedParser::
 /token/ -> ChildA | ChildB { return(scalar("both")) }

ChildA:
 /token/
 E { return(scalar("A")) }

ChildB:
 /token/
 E { return(scalar("B")) }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let parser = compiled.find("GroupedParser").unwrap();
    assert_eq!(parser.acode_dispatch.len(), 2);
    assert!(parser.acode_dispatch[0].has_parent_regex);
    assert!(parser.acode_dispatch[1].has_parent_regex);
    assert_eq!(parser.acode_dispatch[0].regex_idx,
               parser.acode_dispatch[1].regex_idx);
    assert_eq!(parser.acode_dispatch[0].regex_idx, 0);

    let engine = Engine::new(compiled);
    let result = engine.execute("token").unwrap();
    let arr = result.as_array().unwrap();
    assert!(!arr.is_empty());
}

// (e) Edge-only with child_regex_idx > 0 (-> child[N]).
#[test]
fn regression_edge_only_with_child_regex_index() {
    let grammar = r#"Top::
 -> Child[1]

Child:
 /first_pattern/
 /second_pattern/
 E { return(scalar(entry_text())) }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let top = compiled.find("Top").unwrap();
    assert_eq!(top.regex_patterns.len(), 1);
    assert_eq!(top.regex_patterns[0], "second_pattern");
    assert_eq!(top.acode_dispatch[0].child_regex_idx, 1);
    assert_eq!(top.acode_dispatch[0].regex_idx, 0);
    assert!(!top.acode_dispatch[0].has_parent_regex);

    let engine = Engine::new(compiled);
    let result = engine.execute("second_pattern").unwrap();
    assert_eq!(result.as_array().unwrap()[0].as_str().unwrap(), "second_pattern");
}

// (f) Lifecycle with edge-only dispatch.
// Note: Child's return() pushes to the accumulator BEFORE the parent's
// LE/E blocks fire. The lifecycle log is in the second accumulator entry.
#[test]
fn regression_edge_only_with_lifecycle_blocks() {
    let grammar = r#"LifecycleParser::
 I { declare(array, log); push_value(array(log), scalar("I")) }
 LS { push_value(array(log), scalar("LS")) }
 LE { push_value(array(log), scalar("LE")) }
 -> Child
 E { push_value(array(log), scalar("E")); return(array_copy(array(log))) }

Child:
 /hello/
 I { declare(scalar, retv=entry_text()) }
 E { return(scalar(retv)) }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let parser = compiled.find("LifecycleParser").unwrap();
    assert!(!parser.regex_patterns.is_empty());
    assert_eq!(parser.regex_patterns[0], "hello");
    assert!(!parser.acode_dispatch[0].has_parent_regex);

    let engine = Engine::new(compiled);
    let result = engine.execute("hello").unwrap();
    let outer: &Vec<Value> = result.as_array().unwrap();
    // Child's E-block pushes "hello" first, then LifecycleParser's
    // E-block pushes the log array as the second entry.
    assert!(outer.len() >= 2, "expected at least 2 accumulator entries");
    // The second entry is the lifecycle log array
    let inner: &Vec<Value> = outer[1].as_array().unwrap();
    let strs: Vec<&str> = inner.iter().map(|v| v.as_str().unwrap()).collect();
    assert_eq!(strs[0], "I");
    assert_eq!(strs[1], "LS");
    assert_eq!(strs[2], "LE");
    assert_eq!(strs[3], "E");
}

// (g) Self-recursive edge-only: compiler produces correct regex_idx
// pointing to parent positions for self-referencing edges.
#[test]
fn regression_self_recursive_edge_only_compiler_output() {
    let grammar = r#"SelfOnly::*
 /[A-Z]/
 /\d/
 -> SelfOnly
 -> SelfOnly[1]
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let rule = compiled.find("SelfOnly").unwrap();
    // Parent regexes: [A-Z], \d. Self-refs point to these directly.
    assert_eq!(rule.regex_patterns.len(), 2);
    assert!(!rule.acode_dispatch[0].has_parent_regex);
    assert_eq!(rule.acode_dispatch[0].regex_idx, 0);
    assert!(!rule.acode_dispatch[1].has_parent_regex);
    assert_eq!(rule.acode_dispatch[1].regex_idx, 1);
}
