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
    assert_eq!(compiled.rules[0].label, "DemoParser");
    assert_eq!(compiled.rules[1].label, "Child");

    let engine = Engine::new(compiled);
    let result = engine.execute("pattern1 hello world").expect("execute");

    assert!(result.is_array());
    println!(
        "Result: {}",
        serde_json::to_string_pretty(&result).unwrap()
    );
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
    // Test that all shipped specs parse and validate correctly.
    // Reads from the specs/ directory.
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
                Err(e) => {
                    failed.push(format!("{}: parse failed: {e}", path.display()));
                }
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
    // Parse, validate, compile, execute a simple grammar and verify output shape.
    let spec = parse_spec(SIMPLE_GRAMMAR).expect("parse");
    validate(&spec).expect("validate");
    let compiled = compile(&spec).expect("compile");
    let engine = Engine::new(compiled);

    let result = engine.execute("pattern1 hello world").unwrap();
    // Output should be a JSON array with at least one element
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
    // OR{1,3} should match between 1 and 3 words
    assert!(inner.len() >= 1 && inner.len() <= 3,
        "expected 1-3 matches, got {}: {:?}", inner.len(), inner);
}
