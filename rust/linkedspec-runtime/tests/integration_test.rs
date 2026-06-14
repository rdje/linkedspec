//! End-to-end integration test: parse → validate → compile → execute.
//!
//! Tests the full pipeline against the simple_grammar test corpus entry.

use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::Engine;
use serde_json::Value;

/// The simple_grammar spec from tests/corpus/simple_grammar/input.spec
const SIMPLE_GRAMMAR_SPEC: &str = r#"DemoParser::
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
    // 1. Parse
    let spec = parse_spec(SIMPLE_GRAMMAR_SPEC).expect("parse should succeed");
    assert_eq!(spec.rules.len(), 2);

    // 2. Validate
    validate(&spec).expect("validation should pass");

    // 3. Compile
    let handlers = compile(&spec).expect("compilation should succeed");
    assert_eq!(handlers.len(), 2);
    assert_eq!(handlers[0].label, "DemoParser");
    assert_eq!(handlers[1].label, "Child");

    // 4. Execute top rule (DemoParser)
    let engine = Engine::new();
    let result = engine
        .execute(&handlers[0], "pattern1 hello world")
        .expect("execution should succeed");

    // 5. Verify result structure
    // The DemoParser should return an array with "hello" matched by Child
    assert!(result.is_array(), "result should be an array");

    // Print result for inspection
    println!("Result: {}", serde_json::to_string_pretty(&result).unwrap());
}

#[test]
fn parse_validate_compile_all_shipped_specs() {
    // Test that the parser and compiler handle representative specs
    // This is a smoke test — full corpus compliance is in .7

    let specs = vec![
        ("simple_grammar", SIMPLE_GRAMMAR_SPEC),
    ];

    for (name, source) in specs {
        let spec = parse_spec(source)
            .unwrap_or_else(|e| panic!("parse failed for {}: {}", name, e));
        validate(&spec)
            .unwrap_or_else(|e| panic!("validation failed for {}: {}", name, e));
        let handlers = compile(&spec)
            .unwrap_or_else(|e| panic!("compile failed for {}: {}", name, e));
        assert!(!handlers.is_empty(), "{} should produce handlers", name);
    }
}

#[test]
fn engine_executes_on_simple_input() {
    let spec = parse_spec(SIMPLE_GRAMMAR_SPEC).unwrap();
    validate(&spec).unwrap();
    let handlers = compile(&spec).unwrap();

    let engine = Engine::new();

    // Input that matches
    let result = engine
        .execute(&handlers[0], "pattern1 hello world")
        .unwrap();
    assert!(result.is_array());

    // Input that doesn't match the regex
    let result = engine
        .execute(&handlers[0], "no match here at all")
        .unwrap();
    // Should return empty accumulator (no matches)
    assert!(result.is_array());
}

#[test]
fn engine_json_output_roundtrip() {
    let spec = parse_spec(SIMPLE_GRAMMAR_SPEC).unwrap();
    validate(&spec).unwrap();
    let handlers = compile(&spec).unwrap();

    let engine = Engine::new();
    let result = engine
        .execute(&handlers[0], "pattern1 hello world")
        .unwrap();

    // Serialize to JSON and back
    let json_str = serde_json::to_string(&result).unwrap();
    let parsed: Value = serde_json::from_str(&json_str).unwrap();
    assert_eq!(result, parsed);
}
