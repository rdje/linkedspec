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
