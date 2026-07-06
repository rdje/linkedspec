//! End-to-end integration tests: parse → validate → compile → execute.

use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::Engine;
use linkedspec_runtime::spec_parser::{
    parse_spec_with_user_functions, parse_user_function_definition_asts,
};
use linkedspec_runtime::staged_parser_registry::execute_parse_jobs;
use serde_json::Value;

const SIMPLE_GRAMMAR: &str = r#"DemoParser::
 /pattern1/ -> Child {
  I { declare(array, results) }
  LE { push_value(array(results), :retv) }
  E { return(array("?results:", array_copy(array(results)))) }
 }

Child::
 /hello[ \t]+(\w+)/
 I { declare(scalar, name=entry_group(0)) }
 E { return(:name) }
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
            match parse_spec_with_user_functions(&source) {
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

#[test]
fn staged_parser_registry_dispatches_function_body_jobs() {
    let job_later = serde_json::json!({
        "kind": "parse_job",
        "job_id": "parse_job:function_body:functions.1.body_source:actionir-body.spec:action_block:40-51",
        "parent_ast_path": ["functions", "1", "body_source"],
        "node_kind": "function_definition",
        "payload_kind": "function_body",
        "text": "return(\"b\")",
        "source_span": {"start": 40, "end": 51, "line_start": 3, "line_end": 3},
        "parser_spec_id": "actionir-body.spec",
        "top_rule": "action_block",
        "result_policy": "replace_field",
        "result_field": "body_ast",
        "failure_policy": "fail",
        "diagnostic_owner": "function_body",
    });
    let job_earlier = serde_json::json!({
        "kind": "parse_job",
        "job_id": "parse_job:function_body:functions.0.body_source:actionir-body.spec:action_block:10-21",
        "parent_ast_path": ["functions", "0", "body_source"],
        "node_kind": "function_definition",
        "payload_kind": "function_body",
        "text": "return(\"a\")",
        "source_span": {"start": 10, "end": 21, "line_start": 1, "line_end": 1},
        "parser_spec_id": "actionir-body.spec",
        "top_rule": "action_block",
        "result_policy": "replace_field",
        "result_field": "body_ast",
        "failure_policy": "fail",
        "diagnostic_owner": "function_body",
    });

    let results = execute_parse_jobs(&[job_later, job_earlier]).expect("staged parse dispatch");
    assert_eq!(results.len(), 2);
    assert_eq!(
        results[0]["job_id"],
        serde_json::json!(
            "parse_job:function_body:functions.0.body_source:actionir-body.spec:action_block:10-21"
        )
    );
    assert_eq!(results[0]["queue_index"], serde_json::json!(0));
    assert_eq!(
        results[0]["phases"],
        serde_json::json!(["resolve", "load", "compile", "execute"])
    );
    assert_eq!(
        results[0]["resolved_spec_id"],
        serde_json::json!("builtin:actionir-body.spec")
    );
    assert_eq!(
        results[0]["registry_provider"],
        serde_json::json!("builtin")
    );
    assert_eq!(
        results[0]["cache_key"]["kind"],
        serde_json::json!("staged_parser_cache_key")
    );
    assert_eq!(
        results[0]["cache_key"]["normalized_spec_identity"],
        serde_json::json!("builtin:actionir-body.spec")
    );
    assert_eq!(
        results[0]["cache_key"]["content_digest"],
        serde_json::json!(
            "sha256:87ca81d966bb41f7025d31e4bae426af101e2ec75ff2ac14e96517d97fbbf55c"
        )
    );
    assert_eq!(
        results[0]["result"]["kind"],
        serde_json::json!("action_block")
    );
    assert_eq!(
        results[0]["result"]["statements"][0]["kind"],
        serde_json::json!("action_stmt")
    );
    assert_eq!(
        results[0]["result"]["statements"][0]["expr"]["kind"],
        serde_json::json!("call")
    );
    assert_eq!(
        results[0]["result"]["statements"][0]["expr"]["name"],
        serde_json::json!("return")
    );

    let bad_job = serde_json::json!({
        "kind": "parse_job",
        "job_id": "parse_job:function_body:functions.0.body_source:missing.spec:action_block:10-21",
        "parent_ast_path": ["functions", "0", "body_source"],
        "node_kind": "function_definition",
        "payload_kind": "function_body",
        "text": "return(\"a\")",
        "source_span": {"start": 10, "end": 21, "line_start": 1, "line_end": 1},
        "parser_spec_id": "missing.spec",
        "top_rule": "action_block",
        "result_policy": "replace_field",
        "result_field": "body_ast",
        "failure_policy": "fail",
        "diagnostic_owner": "function_body",
    });
    let err = execute_parse_jobs(&[bad_job]).expect_err("missing parser spec should fail");
    assert!(err.contains("phase=resolve"), "{err}");
    assert!(
        err.contains(
            "job_id=parse_job:function_body:functions.0.body_source:missing.spec:action_block:10-21"
        ),
        "{err}"
    );
    assert!(err.contains("parser_spec_id=missing.spec"), "{err}");
    assert!(err.contains("source_span=10-21"), "{err}");
    assert!(err.contains("failure_policy=fail"), "{err}");
}

#[test]
fn spec_defined_user_function_parser_returns_expected_ast_shape() {
    let grammar = r#"fn zero() {return("zero")}

Top::
 /x/ -> Done { return(zero()) }

fn choose(value, other) {
 if(value) { return("{ok}") } else { return("}") }
 return(other)
}

Done:
 /[a-z]+/

fn after(value) {return(value)}
"#;

    let asts = parse_user_function_definition_asts(grammar).expect("function AST parse");
    assert_eq!(
        asts.len(),
        3,
        "only top-level function definitions become AST nodes: {asts:#?}"
    );

    let zero = asts[0].as_object().expect("zero object");
    assert_eq!(zero["type"], serde_json::json!("function_definition"));
    assert_eq!(zero["kind"], serde_json::json!("user_function_definition"));
    assert_eq!(zero["version"], serde_json::json!(1));
    assert_eq!(zero["name"], serde_json::json!("zero"));
    assert_eq!(zero["params"], serde_json::json!([]));
    assert_eq!(zero["arity"], serde_json::json!(0));
    assert_eq!(zero["body_source"], serde_json::json!(r#"return("zero")"#));
    assert_eq!(
        zero["body_payload"]["kind"],
        serde_json::json!("staged_payload")
    );
    assert_eq!(
        zero["body_payload"]["payload_kind"],
        serde_json::json!("function_body")
    );
    assert_eq!(zero["body_payload"]["text"], zero["body_source"]);
    assert_eq!(zero["body_payload"]["source_span"], zero["body_span"]);
    assert_eq!(
        zero["body_parse_job"]["kind"],
        serde_json::json!("parse_job")
    );
    assert_eq!(
        zero["body_parse_job"]["job_id"],
        serde_json::json!("parse_job:function_body:zero:actionir-body.spec:action_block")
    );
    assert_eq!(
        zero["body_parse_job"]["parent_ast_path"],
        serde_json::json!(["functions", "__pending_source_order__", "body_source"])
    );
    assert_eq!(
        zero["body_parse_job"]["parser_spec_id"],
        serde_json::json!("actionir-body.spec")
    );
    assert_eq!(
        zero["body_parse_job"]["top_rule"],
        serde_json::json!("action_block")
    );
    assert_eq!(
        zero["body_parse_job"]["result_policy"],
        serde_json::json!("replace_field")
    );
    assert_eq!(
        zero["body_parse_job"]["result_field"],
        serde_json::json!("body_ast")
    );
    assert_eq!(
        zero["body_parse_job"]["failure_policy"],
        serde_json::json!("fail")
    );
    assert_eq!(zero["body_parse_job"]["text"], zero["body_source"]);
    assert_eq!(zero["body_parse_job"]["source_span"], zero["body_span"]);

    let choose = asts[1].as_object().expect("choose object");
    assert_eq!(choose["name"], serde_json::json!("choose"));
    assert_eq!(choose["params"], serde_json::json!(["value", "other"]));
    assert_eq!(choose["arity"], serde_json::json!(2));
    assert!(
        choose["body_source"]
            .as_str()
            .unwrap()
            .contains(r#"return("{ok}")"#)
    );
    assert!(
        choose["body_source"]
            .as_str()
            .unwrap()
            .contains(r#"return("}")"#),
        "nested body braces and braces inside strings must not close the function early"
    );

    let spec = parse_spec_with_user_functions(grammar).expect("full spec parse");
    assert_eq!(spec.function_names(), vec!["zero", "choose", "after"]);
    let zero_body_ast = spec.functions[0].body_ast.as_ref().expect("zero body ast");
    assert_eq!(zero_body_ast["kind"], serde_json::json!("action_block"));
    assert_eq!(
        zero_body_ast["statements"][0]["expr"]["kind"],
        serde_json::json!("call")
    );
    assert_eq!(
        zero_body_ast["statements"][0]["expr"]["name"],
        serde_json::json!("return")
    );
    let zero_job = spec.functions[0]
        .body_parse_job
        .as_ref()
        .expect("zero parse job");
    assert_eq!(
        zero_job["parent_ast_path"],
        serde_json::json!(["functions", "0", "body_source"])
    );
    assert_eq!(
        zero_job["job_id"],
        serde_json::json!(
            "parse_job:function_body:functions.0.body_source:actionir-body.spec:action_block:11-25"
        )
    );
    assert_eq!(spec.rules.len(), 2);
    validate(&spec).expect("validate");
    let compiled = compile(&spec).expect("compile");
    assert_eq!(compiled.functions.len(), 3);
    assert!(
        compiled.functions[0].body_parse_job.is_some(),
        "compiled functions preserve the neutral body parse job"
    );
    assert!(
        compiled.functions[0].body_ast.is_some(),
        "compiled functions preserve the dispatched body AST"
    );
    assert_eq!(
        Engine::new(compiled).execute("xhello").expect("execute"),
        serde_json::json!(["zero"])
    );
}

#[test]
fn spec_defined_user_function_parser_accepts_definition_variations() {
    let cases = [
        (
            "zero arity compact body",
            r#"fn compact() {return("ok")}
Top::
 /x/ -> Done { return(compact()) }
Done:
 /[a-z]+/
"#,
            "compact",
            serde_json::json!([]),
            r#"return("ok")"#,
        ),
        (
            "spaced parameters",
            r#"fn spaced( left , right ) { return(cat(left, right)) }
Top::
 /x/ -> Done { return(spaced("a", "b")) }
Done:
 /[a-z]+/
"#,
            "spaced",
            serde_json::json!(["left", "right"]),
            "return(cat(left, right))",
        ),
        (
            "nested blocks and strings",
            r#"fn choose(value) {
 if(value) { return("{ok}") } else { return("}") }
}
Top::
 /x/ -> Done { return(choose("yes")) }
Done:
 /[a-z]+/
"#,
            "choose",
            serde_json::json!(["value"]),
            r#"return("{ok}")"#,
        ),
        (
            "regex literal close brace",
            r#"fn has_close(value) {
 if(matches(value, /}/)) { return("brace") }
 return(value)
}
Top::
 /x/ -> Done { return(has_close("}")) }
Done:
 /[a-z]+/
"#,
            "has_close",
            serde_json::json!(["value"]),
            r#"matches(value, /}/)"#,
        ),
        (
            "shape literal body",
            r#"fn meta() { return({ "b" => 2, "a" => [1, 2] }) }
Top::
 /x/ -> Done { return(meta().keys().sort()) }
Done:
 /[a-z]+/
"#,
            "meta",
            serde_json::json!([]),
            r#"return({ "b" => 2, "a" => [1, 2] })"#,
        ),
    ];

    for (label, grammar, name, params, body_fragment) in cases {
        let asts = parse_user_function_definition_asts(grammar)
            .unwrap_or_else(|err| panic!("{label}: AST parse failed: {err}"));
        assert_eq!(asts.len(), 1, "{label}: expected one function AST");
        let node = asts[0].as_object().expect("function object");
        assert_eq!(
            node["type"],
            serde_json::json!("function_definition"),
            "{label}: AST node was {node:#?}"
        );
        assert_eq!(node["name"], serde_json::json!(name));
        assert_eq!(node["params"], params);
        assert!(
            node["body_source"]
                .as_str()
                .unwrap()
                .contains(body_fragment),
            "{label}: body_source did not contain {body_fragment:?}"
        );
        assert_eq!(node["body_payload"]["text"], node["body_source"]);
        assert_eq!(node["body_payload"]["source_span"], node["body_span"]);
        assert_eq!(node["body_parse_job"]["text"], node["body_source"]);
        assert_eq!(node["body_parse_job"]["source_span"], node["body_span"]);
        assert_eq!(
            node["body_parse_job"]["parser_spec_id"],
            serde_json::json!("actionir-body.spec")
        );

        let spec = parse_spec_with_user_functions(grammar)
            .unwrap_or_else(|err| panic!("{label}: full spec parse failed: {err}"));
        assert_eq!(spec.functions.len(), 1, "{label}: function count");
        assert_eq!(spec.functions[0].name, name, "{label}: function name");
        assert!(
            spec.functions[0].body_payload.is_some(),
            "{label}: body_payload must be preserved"
        );
        assert!(
            spec.functions[0].body_parse_job.is_some(),
            "{label}: body_parse_job must be preserved"
        );
        assert!(
            spec.functions[0].body_ast.is_some(),
            "{label}: dispatched body_ast must be preserved"
        );
    }
}

#[test]
fn function_body_staged_prototype_end_to_end_shape_and_runtime() {
    let grammar = r#"fn normalize(value) { return(trim(value)) }
fn join_pair(left, right) { return(concat(left, right)) }
fn mk_items(first, second) { items += first; items += second; return(array_copy(items)) }
fn mk_meta(key, value) { meta[key] = value; return(hash_copy(meta)) }

Top::
 /x/ -> Done { stage_meta = mk_meta("k","v"); return([normalize(" x "), join_pair("a","b"), count(mk_items("a","b")), stage_meta["k"]]) }
Done:
 /[a-z]+/
"#;

    let asts = parse_user_function_definition_asts(grammar).expect("function AST parse");
    assert_eq!(asts.len(), 4);
    assert_eq!(
        asts.iter()
            .map(|node| node["name"].as_str().unwrap())
            .collect::<Vec<_>>(),
        vec!["normalize", "join_pair", "mk_items", "mk_meta"]
    );
    for node in &asts {
        assert_eq!(node["type"], serde_json::json!("function_definition"));
        assert_eq!(
            node["body_parse_job"]["parent_ast_path"],
            serde_json::json!(["functions", "__pending_source_order__", "body_source"])
        );
        assert_eq!(
            node["body_parse_job"]["parser_spec_id"],
            serde_json::json!("actionir-body.spec")
        );
        assert_eq!(node["body_parse_job"]["source_span"], node["body_span"]);
    }

    let spec = parse_spec_with_user_functions(grammar).expect("full spec parse");
    assert_eq!(
        spec.function_names(),
        vec!["normalize", "join_pair", "mk_items", "mk_meta"]
    );
    let expected = [
        ("normalize", vec!["value"], 1usize),
        ("join_pair", vec!["left", "right"], 2usize),
        ("mk_items", vec!["first", "second"], 2usize),
        ("mk_meta", vec!["key", "value"], 2usize),
    ];
    for (idx, (name, params, arity)) in expected.iter().enumerate() {
        let function = &spec.functions[idx];
        assert_eq!(&function.name, name);
        assert_eq!(
            function.params,
            params
                .iter()
                .map(|param| param.to_string())
                .collect::<Vec<_>>()
        );
        assert_eq!(function.arity, *arity);

        let payload = function.body_payload.as_ref().expect("body payload");
        let job = function.body_parse_job.as_ref().expect("body parse job");
        let body_ast = function.body_ast.as_ref().expect("body ast");
        assert_eq!(payload["kind"], serde_json::json!("staged_payload"));
        assert_eq!(payload["payload_kind"], serde_json::json!("function_body"));
        assert_eq!(
            payload["parent_ast_path"],
            serde_json::json!(["functions", idx.to_string(), "body_source"])
        );
        assert_eq!(payload["text"], serde_json::json!(function.body_source));
        assert_eq!(job["kind"], serde_json::json!("parse_job"));
        assert_eq!(
            job["parent_ast_path"],
            serde_json::json!(["functions", idx.to_string(), "body_source"])
        );
        assert_eq!(job["text"], serde_json::json!(function.body_source));
        assert_eq!(job["source_span"], payload["source_span"]);
        assert_eq!(
            job["parser_spec_id"],
            serde_json::json!("actionir-body.spec")
        );
        assert_eq!(job["top_rule"], serde_json::json!("action_block"));
        assert_eq!(job["result_policy"], serde_json::json!("replace_field"));
        assert_eq!(job["result_field"], serde_json::json!("body_ast"));
        assert_eq!(job["failure_policy"], serde_json::json!("fail"));

        let start = job["source_span"]["start"].as_u64().expect("span start");
        let end = job["source_span"]["end"].as_u64().expect("span end");
        assert_eq!(
            job["job_id"],
            serde_json::json!(format!(
                "parse_job:function_body:functions.{idx}.body_source:actionir-body.spec:action_block:{start}-{end}"
            ))
        );
        assert_eq!(body_ast["kind"], serde_json::json!("action_block"));
        assert!(
            body_ast["statements"]
                .as_array()
                .is_some_and(|items| !items.is_empty()),
            "{name}: body_ast should contain parsed statements: {body_ast:#?}"
        );
    }

    validate(&spec).expect("validate");
    let compiled = compile(&spec).expect("compile");
    assert_eq!(compiled.functions.len(), 4);
    for (idx, function) in compiled.functions.iter().enumerate() {
        assert!(
            function.body_parse_job.is_some(),
            "compiled function {idx} preserves body_parse_job"
        );
        assert!(
            function.body_ast.is_some(),
            "compiled function {idx} preserves stitched body_ast"
        );
    }
    assert_eq!(
        Engine::new(compiled).execute("xhello").expect("execute"),
        serde_json::json!([["x", "ab", 2, "v"]])
    );

    let bad_job = serde_json::json!({
        "kind": "parse_job",
        "job_id": "parse_job:function_body:functions.0.body_source:missing.spec:action_block:10-21",
        "parent_ast_path": ["functions", "0", "body_source"],
        "node_kind": "function_definition",
        "payload_kind": "function_body",
        "text": "return(\"a\")",
        "source_span": {"start": 10, "end": 21, "line_start": 1, "line_end": 1},
        "parser_spec_id": "missing.spec",
        "top_rule": "action_block",
        "result_policy": "replace_field",
        "result_field": "body_ast",
        "failure_policy": "fail",
        "diagnostic_owner": "function_body",
    });
    let err = execute_parse_jobs(&[bad_job]).expect_err("missing parser spec should fail");
    assert!(err.contains("phase=resolve"), "{err}");
    assert!(
        err.contains("parent_ast_path=functions.0.body_source"),
        "{err}"
    );
    assert!(err.contains("source_span=10-21"), "{err}");
    assert!(err.contains("failure_policy=fail"), "{err}");
}

#[test]
fn spec_defined_user_function_parser_reports_malformed_definitions() {
    let grammar = r#"fn bad(value
Top::
 /x/
"#;
    let err = parse_spec_with_user_functions(grammar).unwrap_err();
    assert!(
        err.contains("user function definition parse error"),
        "expected spec-defined parse error, got: {err}"
    );
}

#[test]
fn spec_defined_user_function_parser_reports_malformed_definition_ast() {
    let asts = parse_user_function_definition_asts("fn bad(value\nTop::\n /x/\n")
        .expect("malformed function definition AST parse");
    assert_eq!(
        asts.len(),
        1,
        "malformed definition must produce one AST node"
    );
    assert_eq!(
        asts[0]["type"],
        serde_json::json!("function_definition_error"),
        "malformed definition AST was {asts:#?}"
    );
    assert_eq!(asts[0]["source_text"], serde_json::json!("fn bad(value"));
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
    let grammar = r#"OrderedParser::OR{1,1}
 /(\w+)/
 I { declare(array, log); push_value(array(log), "I") }
 LS { push_value(array(log), "LS") }
 LE { push_value(array(log), entry_group(0)) }
 E { push_value(array(log), "E"); return(array_copy(array(log))) }
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
 I { push_value(array(log), "A") }

ChildB:
 /b/
 I { push_value(array(log), "B") }
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
 LE { push_value(array(words), entry_group(0)) }
 E { return(array_copy(array(words))) }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let engine = Engine::new(compiled);
    let result = engine.execute("one two three four five").unwrap();
    let outer: &Vec<Value> = result.as_array().unwrap();
    let inner: &Vec<Value> = outer[0].as_array().unwrap();
    assert!(
        inner.len() >= 1 && inner.len() <= 3,
        "expected 1-3 matches, got {}: {:?}",
        inner.len(),
        inner
    );
}

// ── RUST-EDGE-SEMANTICS.3 regression tests ──

// (a) Edge-only rule: top rule with zero /regex/ patterns, all regexes
// come from child rules via build_dependency_regex_map.
#[test]
fn regression_edge_only_rule_dispatches_to_children() {
    let grammar = r#"DispatchParser::
 -> Word { return(entry_text()) }
 -> Number { return(entry_text()) }

Word:
 /[A-Za-z]+/
 E { return(entry_text()) }

Number:
 /\d+/
 E { return(entry_text()) }
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

#[test]
fn regression_edge_only_scanner_rule_repeats_until_no_match() {
    let grammar = r#"Top::
 -> Word .push(items)
 -> Number .push(items)
 E { return(copy(items)) }

Word:
 /[A-Za-z]+/
 I.return(entry_text())

Number:
 /\d+/
 I.return(entry_text())
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let top = compiled.find("Top").unwrap();
    assert_eq!(top.rep_min, Some(0));
    assert!(top.acode_dispatch.iter().all(|e| !e.has_parent_regex));

    let result = Engine::new(compiled).execute("hello 42 world").unwrap();
    assert_eq!(result, serde_json::json!([["hello", "42", "world"]]));
}

#[test]
fn regression_edge_only_child_i_return_pushes_parent_entry_match() {
    let grammar = r#"Top::
 -> Bad .push(definitions)
 LX { return(copy(definitions)) }

Bad:
 /(?m)^[ \t]*fn\b[^\n]*/
 I.return({
  "type" => "function_definition_error",
  "source_text" => entry_text()
 })
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let result = Engine::new(compiled)
        .execute("fn bad(value\nTop::\n /x/\n")
        .unwrap();
    assert_eq!(
        result,
        serde_json::json!([[{
            "type": "function_definition_error",
            "source_text": "fn bad(value"
        }]])
    );
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
 E { return("child_a") }

ChildB:
 /[Bb]ye/
 E { return("child_b") }

ChildC:
 /extra/
 E { return("child_c") }
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
    assert_eq!(
        engine.execute("Hi").unwrap().as_array().unwrap()[0]
            .as_str()
            .unwrap(),
        "child_a"
    );
    assert_eq!(
        engine.execute("Bye").unwrap().as_array().unwrap()[0]
            .as_str()
            .unwrap(),
        "child_b"
    );
    assert_eq!(
        engine.execute("extra").unwrap().as_array().unwrap()[0]
            .as_str()
            .unwrap(),
        "child_c"
    );
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
 /token/ -> ChildA | ChildB { return("both") }

ChildA:
 /token/
 E { return("A") }

ChildB:
 /token/
 E { return("B") }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let parser = compiled.find("GroupedParser").unwrap();
    assert_eq!(parser.acode_dispatch.len(), 2);
    assert!(parser.acode_dispatch[0].has_parent_regex);
    assert!(parser.acode_dispatch[1].has_parent_regex);
    assert_eq!(
        parser.acode_dispatch[0].regex_idx,
        parser.acode_dispatch[1].regex_idx
    );
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
 E { return(entry_text()) }
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
    assert_eq!(
        result.as_array().unwrap()[0].as_str().unwrap(),
        "second_pattern"
    );
}

// (f) Lifecycle with edge-only dispatch.
// Note: Child's return() pushes to the accumulator BEFORE the parent's
// LE/E blocks fire. The lifecycle log is in the second accumulator entry.
#[test]
fn regression_edge_only_with_lifecycle_blocks() {
    let grammar = r#"LifecycleParser::OR{1,1}
 I { declare(array, log); push_value(array(log), "I") }
 LS { push_value(array(log), "LS") }
 LE { push_value(array(log), "LE") }
 -> Child
 E { push_value(array(log), "E"); return(array_copy(array(log))) }

Child:
 /hello/
 I { declare(scalar, retv=entry_text()) }
 E { return(:retv) }
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

// ── RUST-PARITY.5.1 regression tests — child-return (retv) propagation ──
//
// Before the fix, a child rule's `return(expr)` only pushed onto the shared
// accumulator and `execute_rule` never set a `retv` scalar, so `:retv`
// in a parent block resolved to undef. These tests pin retv propagation across
// action edges (`->`, OR/default), blind-call edges (`=>`, AND), repetition
// (REP), and the `call(child)` helper. `execute()` returns the accumulator, so
// each parent pushes its collected array last — we read `acc.last()`.

// (a) Action edge: `-> Child` must set the parent's retv to the child's return,
// readable in the parent's LE-block.
#[test]
fn retv_5_1_action_edge_propagates_child_return_into_le() {
    let grammar = r#"Parent::
 /open/ -> Child
 I { declare(array, results) }
 LE { push_value(array(results), :retv) }
 E { return(array_copy(array(results))) }

Child:
 /close/
 E { return("child_value") }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let engine = Engine::new(compiled);
    let result = engine.execute("open").unwrap();
    let acc: &Vec<Value> = result.as_array().unwrap();
    let results: &Vec<Value> = acc.last().unwrap().as_array().unwrap();
    assert_eq!(
        results.last().unwrap().as_str().unwrap(),
        "child_value",
        "parent LE must read the child's return via retv (regression: was null)"
    );
}

// (b) Blind-call edge: `=> Child` (AND) must set the parent's retv to the
// child's return, readable in the parent's E-block.
#[test]
fn retv_5_1_blind_call_edge_propagates_child_return() {
    let grammar = r#"Top::AND
 I { declare(array, collected) }
 => Child
 E { push_value(array(collected), :retv); return(array_copy(array(collected))) }

Child:
 /go/
 E { return("blind_ret") }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let engine = Engine::new(compiled);
    let result = engine.execute("go").unwrap();
    let acc: &Vec<Value> = result.as_array().unwrap();
    let collected: &Vec<Value> = acc.last().unwrap().as_array().unwrap();
    assert_eq!(
        collected.last().unwrap().as_str().unwrap(),
        "blind_ret",
        "parent E must read the blind-call child's return via retv"
    );
}

// (c) Repetition: a REP rule dispatching a child each iteration must expose the
// per-iteration child return as retv so the LE-block collects every result.
#[test]
fn retv_5_1_rep_dispatch_collects_each_child_return_via_retv() {
    let grammar = r#"List::OR+
 /(\w+)/ -> Item
 I { declare(array, out) }
 LE { push_value(array(out), :retv) }
 E { return(array_copy(array(out))) }

Item:
 /unused/
 E { return("ITEM") }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let engine = Engine::new(compiled);
    let result = engine.execute("a b c").unwrap();
    let acc: &Vec<Value> = result.as_array().unwrap();
    let out: &Vec<Value> = acc.last().unwrap().as_array().unwrap();
    assert_eq!(
        out.len(),
        3,
        "one child return collected per REP iteration: {out:?}"
    );
    assert!(
        out.iter().all(|v| v.as_str() == Some("ITEM")),
        "every REP iteration's retv must be the child's return, got {out:?}"
    );
}

// (d) `call(child)` evaluates to the child's return value, so a normal
// assignment captures it in the caller.
#[test]
fn retv_5_1_call_helper_returns_child_return_value() {
    let grammar = r#"Driver::
 /seed/
 I { declare(scalar, captured) }
 E { captured = call(Sub); return(:captured) }

Sub:
 /x/
 E { return("sub_ret") }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let engine = Engine::new(compiled);
    let result = engine.execute("seed").unwrap();
    let acc: &Vec<Value> = result.as_array().unwrap();
    assert_eq!(
        acc.last().unwrap().as_str().unwrap(),
        "sub_ret",
        "call(child) must evaluate to the child's return value"
    );
}

// ── RUST-PARITY.5.2 regression tests — entry_* vs match_* separation ──
//
// The Perl reference keeps two distinct match registers per handler invocation:
// the ENTRY match (`IMATCH`), initialised in the handler preamble from the
// match the dispatcher passed in (`IMATCH = $$info{match}`, and a parent calls
// a child with its own `$minfo` — `MethodLowering.pm:332`), and the LOCAL match
// (`LMATCH = $$minfo{match}`), the rule's own regex match
// (`HandlerVariantEmitter::_build_lmatch_extraction`). They are per-handler
// `my` lexicals, so a child's matching never mutates the parent's. The Rust
// engine previously unified them on the shared context (both set to the same
// groups on every match), so `entry_*` and `match_*` could never diverge and a
// child clobbered the parent's match. These tests pin the corrected semantics.

// (a) A dispatched child reads the PARENT's (dispatcher's) match via `entry_*`
// and its OWN match via `match_*` — the two diverge.
#[test]
fn match_5_2_child_entry_is_dispatcher_match_local_is_own() {
    let grammar = r#"Parent::
 /(open)/ -> Child
 I { declare(array, results) }
 LE { push_value(array(results), :retv) }
 E { return(array_copy(array(results))) }

Child:
 /(close)/
 E { return(concat(entry_text(), "|", match_text())) }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let engine = Engine::new(compiled);
    let result = engine.execute("openclose").unwrap();
    let acc: &Vec<Value> = result.as_array().unwrap();
    let results: &Vec<Value> = acc.last().unwrap().as_array().unwrap();
    assert_eq!(
        results.last().unwrap().as_str().unwrap(),
        "open|close",
        "child entry_text must be the parent's match ('open'), match_text its \
         own ('close') — they must diverge (regression: were unified)"
    );
}

// (b) The parent's LOCAL match survives a child dispatch: after dispatching a
// child that matches a different pattern, the parent's `match_*` still reads its
// own match (per-handler lexical restore), not the child's.
#[test]
fn match_5_2_parent_local_match_survives_child_dispatch() {
    let grammar = r#"Parent::
 /(open)/ -> Child
 I { declare(array, results) }
 LE { push_value(array(results), match_text()) }
 E { return(array_copy(array(results))) }

Child:
 /(close)/
 E { return("child") }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let engine = Engine::new(compiled);
    let result = engine.execute("openclose").unwrap();
    let acc: &Vec<Value> = result.as_array().unwrap();
    let results: &Vec<Value> = acc.last().unwrap().as_array().unwrap();
    assert_eq!(
        results.last().unwrap().as_str().unwrap(),
        "open",
        "parent's match_text after child dispatch must be its own match \
         ('open'), not the child's ('close')"
    );
}

// (c) The top rule with no dispatcher seeds its entry match from its own first
// match, so `entry_*` and `match_*` agree there (no spurious divergence).
#[test]
fn match_5_2_top_rule_entry_equals_local_match() {
    let grammar = r#"Top::
 /(\w+)/
 E { return(concat(entry_text(), "|", match_text())) }
"#;
    let spec = parse_spec(grammar).unwrap();
    validate(&spec).unwrap();
    let compiled = compile(&spec).unwrap();
    let engine = Engine::new(compiled);
    let result = engine.execute("hello").unwrap();
    let acc: &Vec<Value> = result.as_array().unwrap();
    assert_eq!(
        acc.last().unwrap().as_str().unwrap(),
        "hello|hello",
        "top rule (no dispatcher) seeds entry from its own first match"
    );
}

// ── TOP-RULE-AS-NORMAL.3.1 (ADR 0010) — cross-variant termination parity ──
//
// A rule that recurses into itself WITHOUT consuming input is a non-progressing
// cycle. Before the forward-progress / consume-before-recurse guard, the Rust
// engine recursed natively through `Engine::execute_rule` (the `call(rule)`
// helper at engine.rs) and overflowed the stack → SIGABRT (process abort). The
// guard now cuts the cycle so the parse TERMINATES cleanly — the Rust mirror of
// the Perl reference's `%__ls_recursion_active` `(rule,pos)` cutoff in
// `SpecEntry::_build_runtime_handler` and its phase0 lock
// `top_rule_as_normal_no_consume_recursion_terminates_not_hang`.
//
// This test is self-protecting: a guard regression makes the engine overflow the
// stack and abort the test process (a hard failure), so it can never silently
// pass once broken.
#[test]
fn top_rule_as_normal_3_1_no_consume_recursion_terminates() {
    let grammar = "top:: /a/\n I { return(call(top)) }\n";
    let spec = parse_spec(grammar).expect("parse");
    validate(&spec).expect("validate");
    let compiled = compile(&spec).expect("compile");
    let engine = Engine::new(compiled);
    // Must return (not overflow/abort): the no-consume self-recursion is cut by
    // the forward-progress guard. The cut yields `undef`, so the engine returns
    // `[null]` — which is exactly the Perl reference value (`undef`/`null`)
    // wrapped one level by the documented Perl↔Rust accumulator output-shape rule
    // (see tests/corpus_oracle.rs). So this lock confirms BOTH clean termination
    // and value-shape parity with the Perl phase0 lock.
    let result = engine
        .execute("aaa")
        .expect("no-consume recursion must terminate cleanly (guard cut the cycle)");
    assert_eq!(
        result,
        serde_json::json!([null]),
        "cut non-progressing recursion yields `[null]` = Perl's `undef` wrapped one level (the guard, not a crash)"
    );
}

// Companion: legitimate consume-before-recurse recursion must NOT be cut by the
// guard. Each re-entry advances `ctx.pos` (the rule consumes `(` before
// recursing), so the `(rule,pos)` key differs at every depth and the cutoff
// never fires. TOP-RULE-AS-NORMAL.3.2 below locks the exact value parity; this
// test remains the narrow termination/shape guard from .3.1.
#[test]
fn top_rule_as_normal_3_1_consume_before_recurse_is_not_cut() {
    let grammar = "top::\n -> sexpr { return(call(sexpr)) }\n\n\
                   sexpr: /\\(/ /\\)/  I { declare(array, items) }\n\
                    -> sexpr     { push_value(a(items), call(sexpr)) }\n\
                    -> atom      { push_value(a(items), call(atom)) }\n\
                    -> sexpr[1]  { return(array_copy(a(items))) }\n\n\
                   atom: /[A-Za-z0-9]+/   I.return(entry_text())\n";
    let spec = parse_spec(grammar).expect("parse");
    validate(&spec).expect("validate");
    let compiled = compile(&spec).expect("compile");
    let engine = Engine::new(compiled);
    let result = engine
        .execute("(a(b)c)")
        .expect("consume-before-recurse recursion must terminate (guard must not cut it)");
    assert!(
        result.is_array(),
        "legitimate recursion returns a well-formed array (guard left it intact)"
    );
}

// ── TOP-RULE-AS-NORMAL.3.2 (ADR 0010) — cross-variant value parity ──
//
// Perl proved in TOP-RULE-AS-NORMAL.2.2 that a recursive top rule is an
// ordinary recursive rule when authored with the standard LX accumulator-return
// idiom. The remaining Rust gap was value shape: recursive child invocations
// shared the same working-variable stores, and `declare(array, items)` did not
// resolve the first bare argument as a declaration type token, so a nested
// `sexpr` frame could leak its local `items` array into its parent. The runtime
// now scopes declared working variables per rule invocation while preserving
// the existing shared-state behavior for undeclared mutations.
#[test]
fn top_rule_as_normal_3_2_body_recursion_value_parity() {
    let grammar = "top::\n -> sexpr { return(call(sexpr)) }\n\n\
                   sexpr: /\\(/ /\\)/  I { declare(array, items) }\n\
                    -> sexpr     { push_value(array(items), call(sexpr)) }\n\
                    -> atom      { push_value(array(items), call(atom)) }\n\
                    -> sexpr[1]  { return(array_copy(array(items))) }\n\n\
                   atom: /[A-Za-z0-9]+/   I.return(entry_text())\n";
    assert_eq!(
        build_and_run(grammar, "(a(b)c)"),
        serde_json::json!([["a", ["b"], "c"]]),
        "Rust wraps the Perl body-recursive reference value one level"
    );
}

#[test]
fn top_rule_as_normal_3_2_top_lx_recursion_value_parity() {
    let grammar = "sexpr:: /\\(/ /\\)/  I { declare(array, items) }\n\
                    -> sexpr     { push_value(array(items), call(sexpr)) }\n\
                    -> atom      { push_value(array(items), call(atom)) }\n\
                    -> sexpr[1]  { return(array_copy(array(items))) }\n\
                    LX { return(array_copy(array(items))) }\n\n\
                   atom: /[A-Za-z0-9]+/   I.return(entry_text())\n";
    assert_eq!(
        build_and_run(grammar, "(a(b)c)"),
        serde_json::json!([[["a", ["b"], "c"]]]),
        "Rust wraps the Perl top-recursive LX reference value one level"
    );
    assert_eq!(
        build_and_run(grammar, "(a) (b)"),
        serde_json::json!([[["a"], ["b"]]]),
        "Rust preserves the Perl top-rule sequence arity under the wrapper rule"
    );
}

// ── SPEC-FORMAT-TERSE.1.1.2 (ADR 0007 + ADR 0006) — auto-existing working ──
// ── variables: Rust lockstep parity with the Perl reference (.1.1.1).        ──
//
// The Perl reference now lets a working variable referenced through the current
// typed spelling -- `:NAME` for scalar slots and `array(NAME)` for arrays -- be
// used WITHOUT a prior declare(...). In Perl that needed an engine change: generated
// handlers run non-strict, so an undeclared bare var would silently become a
// leaky package global (KM working-vars-no-strict-need-my-lexical), and the fix
// auto-injects a per-invocation `my` in the handler preamble.
//
// The Rust runtime needs NO such change: it is an interpreter, not a codegen+eval
// backend. Working variables live in HashMaps on `RuntimeContext` that auto-vivify
// on write (`set_scalar`/`push_value`) and read as Undef/empty when absent
// (`get_scalar`/`get_array`) -- so they already "auto-exist" with no declare. And
// `Engine::execute` builds a FRESH `RuntimeContext` per call, so a value can never
// leak across parses (the Rust analogue of Perl's per-invocation `my` lexical).
// declare(...) still seeds an initializer (`declare(scalar, x=expr)`), so it stays
// meaningful and unchanged.
//
// These locks use the divergence-free edge-action form (the corpus_oracle.rs
// proof class: non-recursive `Parent:: /re/ -> Child { ... }`, value set by the
// edge's own `return(...)`, action-less child), so the asserted values are the
// Perl reference values wrapped one level by the documented Perl<->Rust output
// shape rule -- i.e. genuine cross-variant parity (the same grammars are frozen
// as oracle fixtures `autoexist_*`). The recursive/REP auto-exist idiom the Perl
// phase0 locks use does NOT yet reproduce on Rust: that is the separately-owned
// RUST-PARITY recursive-grammar gap, not auto-existence.

/// parse -> validate -> compile -> execute one inline grammar, panicking with a
/// useful message on any stage failure (the auto-exist locks below are all
/// expected to compile and run cleanly).
fn build_and_run(grammar: &str, input: &str) -> Value {
    let spec = parse_spec_with_user_functions(grammar).expect("parse");
    validate(&spec).expect("validate");
    let compiled = compile(&spec).expect("compile");
    Engine::new(compiled).execute(input).expect("execute")
}

fn build_and_run_result(grammar: &str, input: &str) -> Result<Value, String> {
    let spec = parse_spec_with_user_functions(grammar).expect("parse");
    validate(&spec).expect("validate");
    let compiled = compile(&spec).expect("compile");
    Engine::new(compiled).execute(input)
}

#[test]
fn terse_1_1_2_auto_existing_scalar_var_works_without_declare() {
    // :v is assigned and read back with NO declare(scalar, v) -- it
    // auto-exists. Perl returns "ok"; Rust wraps the accumulator one level.
    let grammar = "Top::\n /x/ -> Done { v = \"ok\"; return(:v) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["ok"]),
        "undeclared scalar working var auto-exists (= Perl reference \"ok\" wrapped one level)"
    );
}

#[test]
fn terse_1_1_2_auto_existing_array_var_works_without_declare() {
    // array(items) is pushed to and copied with NO declare(array, items) -- it
    // auto-exists. Perl returns ["a","b"]; Rust wraps one level.
    let grammar = "Top::\n /x/ -> Done { push_value(array(items), \"a\"); push_value(array(items), \"b\"); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["a", "b"]]),
        "undeclared array working var auto-exists and accumulates (= Perl [\"a\",\"b\"] wrapped one level)"
    );
}

#[test]
fn terse_1_1_2_declare_form_unchanged_vs_no_declare() {
    // The declare(...) form and the no-declare form lower to identical output --
    // the Rust analogue of the Perl "declare path stays single `my`, no double"
    // lock: adding/removing the declare must not change behavior.
    let scalar_no = "Top::\n /x/ -> Done { v = \"ok\"; return(:v) }\n\nDone::\n /[a-z]+/\n";
    let scalar_decl =
        "Top::\n /x/ -> Done { declare(scalar, v); v = \"ok\"; return(:v) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(scalar_no, "xhello"),
        build_and_run(scalar_decl, "xhello"),
        "scalar: declare-form and no-declare-form produce identical output"
    );

    let array_no = "Top::\n /x/ -> Done { push_value(array(items), \"a\"); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    let array_decl = "Top::\n /x/ -> Done { declare(array, items); push_value(array(items), \"a\"); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(array_no, "xhello"),
        build_and_run(array_decl, "xhello"),
        "array: declare-form and no-declare-form produce identical output"
    );
}

#[test]
fn terse_1_1_2_auto_existing_vars_are_per_parse_not_leaky() {
    // The decisive per-invocation proof (mirrors the Perl lock's "re-run returns
    // 3, not 6"): re-running the SAME engine must yield the identical value, never
    // an accumulation. A shared/leaky variable store would grow across parses; a
    // fresh-per-execute context does not. We assert BOTH runs equal AND the exact
    // value, so a regression to a leaky store fails loudly.
    let scalar = "Top::\n /x/ -> Done { v = \"ok\"; return(:v) }\n\nDone::\n /[a-z]+/\n";
    let spec = parse_spec(scalar).expect("parse");
    validate(&spec).expect("validate");
    let engine = Engine::new(compile(&spec).expect("compile"));
    let r1 = engine.execute("xhello").expect("run1");
    let r2 = engine.execute("xhello").expect("run2");
    assert_eq!(r1, serde_json::json!(["ok"]), "scalar first run");
    assert_eq!(
        r1, r2,
        "scalar var is per-parse, not leaked across executes"
    );

    let array = "Top::\n /x/ -> Done { push_value(array(items), \"a\"); push_value(array(items), \"b\"); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    let spec = parse_spec(array).expect("parse");
    validate(&spec).expect("validate");
    let engine = Engine::new(compile(&spec).expect("compile"));
    let r1 = engine.execute("xhello").expect("run1");
    let r2 = engine.execute("xhello").expect("run2");
    assert_eq!(r1, serde_json::json!([["a", "b"]]), "array first run");
    assert_eq!(
        r1, r2,
        "array accumulator is per-parse, not leaked across executes (would be 4 items if leaky)"
    );
}

// ── SPEC-FORMAT-TERSE.1.2.2 — Rust lockstep parity for .1.2.1 (Channel 1):
// a BARE working var in a type-implying position auto-exists with
// the position-implied kind (operator assignment target -> scalar, push_value/push_nonempty
// target -> array). On the Perl reference (.1.2.1) the engine auto-supplies the
// per-invocation `my`; on Rust resolve_scalar_target/resolve_array_target now map
// the bare name to the working variable and the per-parse RuntimeContext HashMap
// auto-vivifies it (no declare, no leak). The mutation target is bare (Channel 1);
// the value is read back through `:name`.

#[test]
fn terse_1_2_2_bare_scalar_arg_auto_exists() {
    // v = ... with a BARE target -- no scalar-slot marker, no declare.
    let grammar = "Top::\n /x/ -> Done { v = \"ok\"; return(:v) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["ok"]),
        "bare assignment target auto-exists as scalar state; Perl reference is \"ok\" wrapped one level"
    );
}

#[test]
fn terse_1_2_2_bare_array_arg_auto_exists() {
    // push_value(items, ...) with a BARE target.
    let grammar = "Top::\n /x/ -> Done { push_value(items, \"a\"); push_value(items, \"b\"); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["a", "b"]]),
        "bare push_value target auto-exists as an array (= Perl [\"a\",\"b\"] wrapped one level)"
    );
    // push_nonempty(items, ...) with a BARE target -- same array auto-existence,
    // and the empty value is still skipped.
    let ne = "Top::\n /x/ -> Done { push_nonempty(items, \"a\"); push_nonempty(items, \"\"); push_nonempty(items, \"b\"); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(ne, "xhello"),
        serde_json::json!([["a", "b"]]),
        "bare push_nonempty target auto-exists as an array and skips the empty value"
    );
}

#[test]
fn terse_1_2_2_bare_matches_wrapped_and_declare() {
    // The bare assignment form produces the same value as the explicit scalar-slot form and the
    // declare form (the Rust analogue of the Perl "byte-identical / single `my`"
    // locks): the explicit slot marker/declare are optional in these positions.
    let bare = "Top::\n /x/ -> Done { v = \"ok\"; return(:v) }\n\nDone::\n /[a-z]+/\n";
    let explicit_slot =
        "Top::\n /x/ -> Done { set(:v, \"ok\"); return(:v) }\n\nDone::\n /[a-z]+/\n";
    let declared =
        "Top::\n /x/ -> Done { declare(scalar, v); v = \"ok\"; return(:v) }\n\nDone::\n /[a-z]+/\n";
    let b = build_and_run(bare, "xhello");
    assert_eq!(
        b,
        build_and_run(explicit_slot, "xhello"),
        "scalar: bare assignment == explicit slot"
    );
    assert_eq!(
        b,
        build_and_run(declared, "xhello"),
        "scalar: bare arg == declare"
    );

    let bare_a = "Top::\n /x/ -> Done { push_value(items, \"a\"); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    let wrapped_a = "Top::\n /x/ -> Done { push_value(array(items), \"a\"); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(bare_a, "xhello"),
        build_and_run(wrapped_a, "xhello"),
        "array: bare push_value target == wrapped"
    );
}

#[test]
fn terse_1_2_2_bare_arg_vars_are_per_parse_not_leaky() {
    // Re-running the SAME engine yields the identical value -- a bare arg-position
    // working var is per-parse (fresh RuntimeContext per execute), never leaked.
    let scalar = "Top::\n /x/ -> Done { v = \"ok\"; return(:v) }\n\nDone::\n /[a-z]+/\n";
    let spec = parse_spec(scalar).expect("parse");
    validate(&spec).expect("validate");
    let engine = Engine::new(compile(&spec).expect("compile"));
    let r1 = engine.execute("xhello").expect("run1");
    let r2 = engine.execute("xhello").expect("run2");
    assert_eq!(r1, serde_json::json!(["ok"]), "bare scalar first run");
    assert_eq!(
        r1, r2,
        "bare scalar arg var is per-parse, not leaked across executes"
    );

    let array = "Top::\n /x/ -> Done { push_value(items, \"a\"); push_value(items, \"b\"); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    let spec = parse_spec(array).expect("parse");
    validate(&spec).expect("validate");
    let engine = Engine::new(compile(&spec).expect("compile"));
    let r1 = engine.execute("xhello").expect("run1");
    let r2 = engine.execute("xhello").expect("run2");
    assert_eq!(r1, serde_json::json!([["a", "b"]]), "bare array first run");
    assert_eq!(
        r1, r2,
        "bare array accumulator is per-parse, not leaked (would be 4 items if leaky)"
    );
}

// ── SPEC-FORMAT-TERSE.1.2.3.2 — Rust lockstep parity for .1.2.3.1:
// aggregate bare value reads are type-implying snapshot positions. `array_copy(NAME)`
// and array-first `copy(NAME)` read array `NAME`; `hash_copy(NAME)` reads hash `NAME`.
// Scalar-like bare value reads and bare direct-access path atoms landed later
// under SPEC-FORMAT-TERSE.1.2.3.4.

#[test]
fn terse_1_2_3_2_bare_array_copy_read_matches_wrapped() {
    let bare = "Top::\n /x/ -> Done { push_value(items, \"a\"); push_value(items, \"b\"); return(array_copy(items)) }\n\nDone::\n /[a-z]+/\n";
    let wrapped = "Top::\n /x/ -> Done { push_value(items, \"a\"); push_value(items, \"b\"); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    let actual = build_and_run(bare, "xhello");
    assert_eq!(
        actual,
        serde_json::json!([["a", "b"]]),
        "array_copy(items) reads the array working variable under the Perl output shape"
    );
    assert_eq!(
        actual,
        build_and_run(wrapped, "xhello"),
        "array_copy(items) == array_copy(array(items)) on Rust"
    );
}

#[test]
fn terse_1_2_3_2_bare_hash_copy_read_matches_wrapped() {
    let bare = "Top::\n /x/ -> Done { set_key(meta, \"stage\", \"v\"); return(hash_copy(meta)) }\n\nDone::\n /[a-z]+/\n";
    let wrapped = "Top::\n /x/ -> Done { set_key(meta, \"stage\", \"v\"); return(hash_copy(hash(meta))) }\n\nDone::\n /[a-z]+/\n";
    let actual = build_and_run(bare, "xhello");
    assert_eq!(
        actual,
        serde_json::json!([{"stage": "v"}]),
        "hash_copy(meta) reads the hash working variable under the Perl output shape"
    );
    assert_eq!(
        actual,
        build_and_run(wrapped, "xhello"),
        "hash_copy(meta) == hash_copy(hash(meta)) on Rust"
    );
}

#[test]
fn terse_1_2_3_2_copy_bare_array_first_and_wrapped_hash() {
    let bare_array = "Top::\n /x/ -> Done { push_value(items, \"a\"); return(copy(items)) }\n\nDone::\n /[a-z]+/\n";
    let wrapped_array = "Top::\n /x/ -> Done { push_value(items, \"a\"); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    let actual_array = build_and_run(bare_array, "xhello");
    assert_eq!(
        actual_array,
        serde_json::json!([["a"]]),
        "copy(items) follows the documented array-first aggregate bare-read rule"
    );
    assert_eq!(
        actual_array,
        build_and_run(wrapped_array, "xhello"),
        "copy(items) == array_copy(array(items)) on Rust"
    );

    let wrapped_hash = "Top::\n /x/ -> Done { set_key(meta, \"stage\", \"v\"); return(copy(hash(meta))) }\n\nDone::\n /[a-z]+/\n";
    let canonical_hash = "Top::\n /x/ -> Done { set_key(meta, \"stage\", \"v\"); return(hash_copy(hash(meta))) }\n\nDone::\n /[a-z]+/\n";
    let actual_hash = build_and_run(wrapped_hash, "xhello");
    assert_eq!(
        actual_hash,
        serde_json::json!([{"stage": "v"}]),
        "copy(hash(meta)) clones the named hash working variable"
    );
    assert_eq!(
        actual_hash,
        build_and_run(canonical_hash, "xhello"),
        "copy(hash(meta)) == hash_copy(hash(meta)) on Rust"
    );
}

#[test]
fn terse_1_2_3_2_bare_aggregate_reads_are_per_parse() {
    let array = "Top::\n /([ab])/ -> Done { push_value(items, match_group(0)); return(array_copy(items)) }\n\nDone::\n /[a-z]+/\n";
    let spec = parse_spec(array).expect("parse array");
    validate(&spec).expect("validate array");
    let engine = Engine::new(compile(&spec).expect("compile array"));
    assert_eq!(
        engine.execute("ahello").expect("array run1"),
        serde_json::json!([["a"]]),
        "bare array read first execution"
    );
    assert_eq!(
        engine.execute("bhello").expect("array run2"),
        serde_json::json!([["b"]]),
        "bare array read is isolated to the fresh RuntimeContext per execute"
    );

    let hash = "Top::\n /([ab])/ -> Done { set_key(meta, match_group(0), \"seen\"); return(hash_copy(meta)) }\n\nDone::\n /[a-z]+/\n";
    let spec = parse_spec(hash).expect("parse hash");
    validate(&spec).expect("validate hash");
    let engine = Engine::new(compile(&spec).expect("compile hash"));
    assert_eq!(
        engine.execute("ahello").expect("hash run1"),
        serde_json::json!([{"a": "seen"}]),
        "bare hash read first execution"
    );
    assert_eq!(
        engine.execute("bhello").expect("hash run2"),
        serde_json::json!([{"b": "seen"}]),
        "bare hash read is isolated to the fresh RuntimeContext per execute"
    );
}

// ── SPEC-FORMAT-TERSE.1.4.2 — Rust lockstep parity for .1.4.1:
// `set` is an assign alias, `cat` is a concat alias, and `copy` is a unified
// array/hash value-copy helper. These tests stay in the same non-recursive
// parent-edge proof class as the oracle fixtures.

#[test]
fn terse_1_4_2_set_cat_copy_array_match_canonical_helpers() {
    let terse = "Top::\n /x/ -> Done { set(:label, cat(\"a\", \"b\")); push_value(array(items), :label); return(copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    let canonical = "Top::\n /x/ -> Done { label = concat(\"a\", \"b\"); push_value(array(items), :label); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    let actual = build_and_run(terse, "xhello");
    assert_eq!(
        actual,
        serde_json::json!([["ab"]]),
        "terse set+cat+copy(array) returns the same value shape as the Perl oracle"
    );
    assert_eq!(
        actual,
        build_and_run(canonical, "xhello"),
        "set/cat/copy(array) == operator/concat/array_copy on Rust"
    );
}

#[test]
fn terse_1_4_2_copy_hash_matches_hash_copy() {
    let terse = "Top::\n /x/ -> Done { return(copy(h(m))) }\n\nDone::\n /[a-z]+/\n";
    let canonical = "Top::\n /x/ -> Done { return(hash_copy(h(m))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(terse, "xhello"),
        serde_json::json!([{}]),
        "copy(h(m)) produces the Perl empty-hash reference value wrapped one level"
    );
    assert_eq!(
        build_and_run(terse, "xhello"),
        build_and_run(canonical, "xhello"),
        "copy(hash target) == hash_copy(hash target) on Rust"
    );

    let value_terse =
        "Top::\n /x/ -> Done { return(copy(hash(\"k\", \"v\"))) }\n\nDone::\n /[a-z]+/\n";
    let value_canonical =
        "Top::\n /x/ -> Done { return(hash_copy(hash(\"k\", \"v\"))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(value_terse, "xhello"),
        serde_json::json!([{"k": "v"}]),
        "copy clones an already-materialized hash value"
    );
    assert_eq!(
        build_and_run(value_terse, "xhello"),
        build_and_run(value_canonical, "xhello"),
        "copy(hash value) == hash_copy(hash value) on Rust"
    );
}

#[test]
fn terse_1_3_2_push_alias_matches_push_value() {
    let terse = "Top::\n /x/ -> Done { set(label, \"b\"); push(items, \"a\"); push(items, :label); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    let canonical = "Top::\n /x/ -> Done { set(label, \"b\"); push_value(items, \"a\"); push_value(items, :label); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    let actual = build_and_run(terse, "xhello");
    assert_eq!(
        actual,
        serde_json::json!([["a", "b"]]),
        "terse push(target, value) appends explicit values with the Perl oracle output shape"
    );
    assert_eq!(
        actual,
        build_and_run(canonical, "xhello"),
        "push(target, value) == push_value(target, value) on Rust for explicit-value append"
    );
}

#[test]
fn terse_1_3_3_set_key_statement_mutates_hash() {
    let grammar = "Top::\n /x/ -> Done { set_key(meta, \"stage\", cat(\"a\", \"b\")); return(hash_copy(hash(meta))) }\n\nDone::\n /[a-z]+/\n";
    let spec = parse_spec(grammar).expect("parse");
    validate(&spec).expect("validate");
    let engine = Engine::new(compile(&spec).expect("compile"));
    let r1 = engine.execute("xhello").expect("run1");
    let r2 = engine.execute("xhello").expect("run2");
    assert_eq!(
        r1,
        serde_json::json!([{"stage": "ab"}]),
        "set_key(meta, key, value) mutates a no-declare hash target"
    );
    assert_eq!(
        r1, r2,
        "set_key hash target state is per parse, not leaked between executions"
    );
}

#[test]
fn terse_1_3_3_set_key_value_helper_stays_pure_copy() {
    let grammar = "Top::\n /x/ -> Done { set_key(meta, \"existing\", \"old\"); set(snapshot, set_key(hash(meta), \"stage\", \"v\")); return(array(hash_copy(hash(meta)), :snapshot)) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[{"existing": "old"}, {"existing": "old", "stage": "v"}]]),
        "nested set_key(hash(meta), key, value) returns a copied hash and does not mutate meta"
    );
}

#[test]
fn terse_1_3_4_1_scalar_assignment_operator_matches_set() {
    let operator =
        "Top::\n /x/ -> Done { name = cat(\"o\", \"k\"); return(:name) }\n\nDone::\n /[a-z]+/\n";
    let canonical = "Top::\n /x/ -> Done { set(name, cat(\"o\", \"k\")); return(:name) }\n\nDone::\n /[a-z]+/\n";
    let actual = build_and_run(operator, "xhello");
    assert_eq!(
        actual,
        serde_json::json!(["ok"]),
        "scalar assignment operator mutates a no-declare scalar target"
    );
    assert_eq!(
        actual,
        build_and_run(canonical, "xhello"),
        "name = value matches set(name, value) on Rust"
    );
}

#[test]
fn terse_1_3_4_1_scalar_assignment_target_is_per_parse() {
    let grammar =
        "Top::\n /x/ -> Done { name = cat(\"o\", \"k\"); return(:name) }\n\nDone::\n /[a-z]+/\n";
    let spec = parse_spec(grammar).expect("parse");
    validate(&spec).expect("validate");
    let engine = Engine::new(compile(&spec).expect("compile"));
    let r1 = engine.execute("xhello").expect("run1");
    let r2 = engine.execute("xhello").expect("run2");
    assert_eq!(r1, serde_json::json!(["ok"]), "scalar assignment first run");
    assert_eq!(r1, r2, "scalar assignment state is per parse");
}

#[test]
fn terse_1_3_4_2_array_append_operator_matches_push_value() {
    let operator = "Top::\n /x/ -> Done { label = \"b\"; items += \"a\"; items += :label; return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    let canonical = "Top::\n /x/ -> Done { set(label, \"b\"); push_value(items, \"a\"); push_value(items, :label); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    let actual = build_and_run(operator, "xhello");
    assert_eq!(
        actual,
        serde_json::json!([["a", "b"]]),
        "array append operator mutates a no-declare array target"
    );
    assert_eq!(
        actual,
        build_and_run(canonical, "xhello"),
        "items += value matches push_value(items, value) on Rust for explicit RHS shapes"
    );
}

#[test]
fn terse_1_3_4_2_array_append_target_is_per_parse() {
    let grammar = "Top::\n /x/ -> Done { items += \"a\"; return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    let spec = parse_spec(grammar).expect("parse");
    validate(&spec).expect("validate");
    let engine = Engine::new(compile(&spec).expect("compile"));
    let r1 = engine.execute("xhello").expect("run1");
    let r2 = engine.execute("xhello").expect("run2");
    assert_eq!(r1, serde_json::json!([["a"]]), "array append first run");
    assert_eq!(r1, r2, "array append state is per parse");
}

#[test]
fn terse_1_3_4_3_hash_index_assignment_operator_matches_set_key() {
    let operator = "Top::\n /x/ -> Done { meta[cat(\"s\", \"tage\")] = cat(\"a\", \"b\"); return(hash_copy(hash(meta))) }\n\nDone::\n /[a-z]+/\n";
    let canonical = "Top::\n /x/ -> Done { set_key(meta, cat(\"s\", \"tage\"), cat(\"a\", \"b\")); return(hash_copy(hash(meta))) }\n\nDone::\n /[a-z]+/\n";
    let actual = build_and_run(operator, "xhello");
    assert_eq!(
        actual,
        serde_json::json!([{"stage": "ab"}]),
        "hash-index assignment operator mutates a no-declare hash target"
    );
    assert_eq!(
        actual,
        build_and_run(canonical, "xhello"),
        "meta[key] = value matches set_key(meta, key, value) on Rust for explicit key/RHS shapes"
    );
}

#[test]
fn terse_1_3_4_3_hash_index_assignment_target_is_per_parse() {
    let grammar = "Top::\n /x/ -> Done { meta[\"stage\"] = \"v\"; return(hash_copy(hash(meta))) }\n\nDone::\n /[a-z]+/\n";
    let spec = parse_spec(grammar).expect("parse");
    validate(&spec).expect("validate");
    let engine = Engine::new(compile(&spec).expect("compile"));
    let r1 = engine.execute("xhello").expect("run1");
    let r2 = engine.execute("xhello").expect("run2");
    assert_eq!(
        r1,
        serde_json::json!([{"stage": "v"}]),
        "hash-index assignment first run"
    );
    assert_eq!(r1, r2, "hash-index assignment state is per parse");
}

#[test]
fn terse_1_4_2_set_target_is_per_parse_not_leaky() {
    let grammar =
        "Top::\n /x/ -> Done { set(v, cat(\"o\", \"k\")); return(:v) }\n\nDone::\n /[a-z]+/\n";
    let spec = parse_spec(grammar).expect("parse");
    validate(&spec).expect("validate");
    let engine = Engine::new(compile(&spec).expect("compile"));
    let r1 = engine.execute("xhello").expect("run1");
    let r2 = engine.execute("xhello").expect("run2");
    assert_eq!(r1, serde_json::json!(["ok"]), "set bare target first run");
    assert_eq!(r1, r2, "set alias uses assign's per-parse target semantics");
}

// ── SPEC-FORMAT-TERSE.1.5.2 — primitive literal parity:
// quoted strings, numbers, true, false, and undef are explicit typed value
// literals in return payloads, mutations, and flow conditions. Prefix
// identifiers such as trueword remain identifiers, not literals.

#[test]
fn terse_1_5_2_primitive_literals_return_typed_values() {
    let grammar = "Top::\n /x/ -> Done { return(array(true, false, \"s\", 42, 3.14, undef)) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[true, false, "s", 42, 3.14, null]]),
        "primitive literals preserve typed JSON values in return payloads"
    );
}

#[test]
fn terse_1_5_2_boolean_literals_work_in_mutations_and_flow() {
    let grammar = "Top::\n /x/ -> Done { flag = true; items += false; push(items, true); meta[\"enabled\"] = true; if(false); return(\"bad\"); else(); return(array(:flag, array_copy(array(items)), hash_copy(hash(meta)))); endif() }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[true, [false, true], {"enabled": true}]]),
        "boolean literals preserve typed values in mutation RHS positions and if(false) selects else"
    );
}

// ── SPEC-FORMAT-TERSE.1.5.3 — call spacing locks:
// Calls keep mandatory parentheses, while optional whitespace before `(` is a
// layout detail at supported statement and value-expression sites.

#[test]
fn terse_1_5_3_call_spacing_runs_like_tight_calls() {
    let grammar = "Top::\n /x/ -> Done { set (name, cat (\"a\", \"b\")); items += cat (\"c\", \"d\"); meta[cat (\"s\", \"tage\")] = :name; return (array(:name, array_copy (array (items)), hash_copy (hash (meta)))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["ab", ["cd"], {"stage": "ab"}]]),
        "optional whitespace before call parentheses preserves runtime values"
    );
}

// ── SPEC-FORMAT-TERSE.1.5.4 — statement separator contract:
// Newlines are implicit top-level statement separators; same-line adjacent
// statements keep requiring semicolons.

#[test]
fn terse_1_5_4_newline_and_semicolon_statement_separators_run() {
    let newline_grammar =
        "Top::\n /x/ -> Done { set(name,\"a\")\n return(:name) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(newline_grammar, "xhello"),
        serde_json::json!(["a"]),
        "newline-separated statements run in order"
    );

    let semicolon_grammar =
        "Top::\n /x/ -> Done { set(name,\"b\"); return(:name) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(semicolon_grammar, "xhello"),
        serde_json::json!(["b"]),
        "same-line statements separated by semicolon still run in order"
    );
}

// ── SPEC-FORMAT-TERSE.1.5.5.1 — direct nested access with explicit segments.

#[test]
fn terse_1_5_5_1_direct_nested_access_explicit_segments_run() {
    let grammar = "Top::\n /x/ -> Done { set(foo, hash(\"a\", array(hash(\"b\", array(\"zero\",\"one\")))))\n set(z,1)\n return(foo[\"a\"][0][\"b\"][z]) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["one"]),
        "direct nested access walks mixed hash and array segments"
    );
}

// ── SPEC-FORMAT-TERSE.1.2.3.4 — Rust scalar bare-read parity:
// source slots, mutation key/RHS slots, and direct-access bare path atoms all
// evaluate `Expr::Variable` as a scalar working-variable read. RHS-shape
// inference remains later, and this does not change the `push(...)` disambiguation.

#[test]
fn terse_1_2_3_4_scalar_source_slot_bare_reads_run() {
    let grammar = "Top::\n /x/ -> Done { set(value, \"ok\"); set(out, value); name = value; return(value); return(array(:out, :name)) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["ok", ["ok", "ok"]]),
        "bare scalar reads work in return and assignment source slots"
    );
}

#[test]
fn terse_1_2_3_4_mutation_and_direct_access_bare_reads_run() {
    let grammar = "Top::\n /x/ -> Done { set(value, \"payload\"); set(key, \"stage\"); set(idx, 1); set(foo, hash(\"a\", array(\"zero\", \"one\"))); items += value; set_key(meta, key, value); meta[key] = value; return(array(array_copy(array(items)), hash_copy(hash(meta)), foo[\"a\"][idx])) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[["payload"], {"stage": "payload"}, "one"]]),
        "bare scalar reads work in mutation slots and direct-access path indexes"
    );
}

// ── SPEC-FORMAT-TERSE.1.6 — array end-mutation methods:
// statement-level receiver-dot methods mutate a named working array.

#[test]
fn terse_1_6_array_end_mutation_methods_run_in_order() {
    let grammar = "Top::\n /x/ -> Done { set(value, \"b\"); items.push_back(\"a\"); items.push_back(value); items.push_front(\"z\"); items.pop_back(); items.pop_front(); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["a"]]),
        "push_back/push_front/pop_back/pop_front mutate the receiver working array"
    );
}

#[test]
fn terse_1_6_explicit_array_receiver_aliases_run() {
    let grammar = "Top::\n /x/ -> Done { array(items).push_back(\"b\"); a(items).push_front(\"a\"); return(array_copy(array(items))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["a", "b"]]),
        "array(...) and a(...) receivers name the working array for end mutations"
    );
}

// ── SPEC-FORMAT-TERSE.1.2.3.5.3 — Rust shape-literal value parity:
// direct `[]` and `{ key => value }` forms are value expressions. Their members
// use the same expression semantics as the Perl `.1.2.3.5.1` contract: bare
// names read scalar working variables, helper calls compose, primitive literals
// stay typed, and nested shapes recurse. RHS target-kind inference landed later
// in `.1.2.3.5.4`; the live target-kind behavior is locked in that section.

#[test]
fn terse_1_2_3_5_3_shape_literal_values_return_typed_nested_payload() {
    let grammar = "Top::\n /x/ -> Done { set(value, \"ok\"); set(key, \"stage\"); return(array([value, cat(\"a\", \"b\"), true, []], { key => value, \"fixed\" => [value] })) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[["ok", "ab", true, []], {"fixed": ["ok"], "stage": "ok"}]]),
        "shape literal values preserve typed nested arrays/hashes and scalar bare reads"
    );
}

#[test]
fn terse_1_2_3_5_3_shape_literals_work_in_mutation_rhs_slots() {
    let grammar = "Top::\n /x/ -> Done { set(value, \"payload\"); set(key, \"stage\"); items += [value]; meta[key] = { key => value }; return(array(array_copy(array(items)), hash_copy(hash(meta)))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[[["payload"]], {"stage": {"stage": "payload"}}]]),
        "array-append and hash-index RHS slots accept direct shape literal values"
    );
}

// ── SPEC-FORMAT-TERSE.11.3 — Rust duck-typed assignment parity:
// direct shape literals on bare assignment targets bind scalar-held typed
// values. Explicit array/hash targets still mutate aggregate storage.

#[test]
fn terse_11_3_shape_assignment_binds_scalar_held_array_values() {
    let grammar = "Top::\n /x/ -> Done { set(value, \"ok\"); name = [value]; return(array(:name, array(name), copy(name), name.count(), name.first())) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[["ok"], ["ok"], ["ok"], 1, "ok"]]),
        "direct shape RHS on a bare target stores and reads a scalar-held array value"
    );
}

#[test]
fn terse_11_3_assignment_can_replace_scalar_array_hash_values() {
    let grammar = "Top::\n /x/ -> Done { set(value, \"ok\"); set(key, \"stage\"); thing = \"text\"; first = thing; thing = [value]; second = array(thing); thing = { key => value }; third = hash(thing); thing = \"done\"; return(array(first, second, third, thing)) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["text", ["ok"], {"stage": "ok"}, "done"]]),
        "later assignment can replace a scalar with array/hash values and then a scalar again"
    );
}

#[test]
fn terse_11_3_set_shape_rhs_binds_bare_targets_as_values() {
    let grammar = "Top::\n /x/ -> Done { set(value, \"ok\"); set(key, \"stage\"); set(items, [value]); set(meta, { key => value }); return(array(array(items), hash(meta), :items, :meta)) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[["ok"], {"stage": "ok"}, ["ok"], {"stage": "ok"}]]),
        "set(...) with a bare direct shape target stores scalar-held typed values"
    );
}

#[test]
fn terse_11_3_explicit_typed_targets_remain_aggregate_storage() {
    let grammar = "Top::\n /x/ -> Done { set(value, \"ok\"); set(key, \"stage\"); set(array(items), [value]); set(hash(meta), { key => value }); set(:payload, [value]); return(array(array_copy(array(items)), hash_copy(hash(meta)), :payload, array_copy(array(payload)))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[["ok"], {"stage": "ok"}, ["ok"], ["ok"]]]),
        "explicit array/hash targets use aggregate storage while scalar targets keep scalar-held payloads"
    );
}

// ── SPEC-FORMAT-TERSE.11.4 — nested mixed value-path writes:
// multi-segment lvalue paths mutate scalar-held array/hash value trees with
// explicit no-autovivification behavior for missing/wrong intermediate nodes.

#[test]
fn terse_11_4_nested_hash_array_hash_value_path_writes_run() {
    let grammar = "Top::\n /x/ -> Done { set(value, \"new\"); payload = { \"items\" => [{ \"name\" => \"old\" }] }; payload[\"items\"][0][\"name\"] = value; payload[\"items\"][1] = { \"name\" => \"tail\" }; return(array(payload[\"items\"][0][\"name\"], payload[\"items\"][1][\"name\"], payload)) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["new", "tail", {"items": [{"name": "new"}, {"name": "tail"}]}]]),
        "nested hash-array-hash paths replace existing leaves and append at the array boundary"
    );
}

#[test]
fn terse_11_4_nested_array_hash_value_path_writes_run() {
    let grammar = "Top::\n /x/ -> Done { payload = [{ \"name\" => \"old\" }]; payload[0][\"name\"] = \"new\"; payload[1] = { \"name\" => \"tail\" }; return(payload) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[{"name": "new"}, {"name": "tail"}]]),
        "array-then-hash paths mutate scalar-held array roots"
    );
}

#[test]
fn terse_11_4_nested_assignment_expression_returns_root_or_undef() {
    let grammar = "Top::\n /x/ -> Done { payload = { \"items\" => [{ \"name\" => \"old\" }] }; return(array((payload[\"items\"][0][\"name\"] = \"new\").count_keys(), payload[\"items\"][1] = \"tail\", payload, payload[\"items\"][3] = \"gap\", payload, payload[\"missing\"][0] = \"bad\", payload, payload[\"items\"][0][0] = \"bad\", payload)) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[1, {"items": [{"name": "new"}, "tail"]}, {"items": [{"name": "new"}, "tail"]}, null, {"items": [{"name": "new"}, "tail"]}, null, {"items": [{"name": "new"}, "tail"]}, null, {"items": [{"name": "new"}, "tail"]}]]),
        "nested assignment expressions return the updated root on success and undef without mutation on missing or wrong-shape paths"
    );
}

#[test]
fn terse_6_2_3_1_scalar_slot_shorthand_runs() {
    let grammar = "Top::\n /x/ -> Done { set(value, \"ok\"); set(:payload, [value]); set(snapshot, :payload); return(array(:value, :payload, copy(array(payload)), :snapshot)) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["ok", ["ok"], ["ok"], ["ok"]]]),
        ":name reads scalar slots and set(:name, shape) keeps the shape payload in the scalar"
    );
}

#[test]
fn terse_6_2_3_2_bare_identifier_remembers_type_after_initialization() {
    let grammar = "Top::\n /x/ -> Done { value = \"ok\"; key = \"stage\"; items = [value]; meta = { key => value }; return(array(copy(items), copy(meta), items.count(), meta.count_keys(), items.first(), meta.pick_keys(key).sorted_values().first())) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[["ok"], {"stage": "ok"}, 1, 1, "ok", "ok"]]),
        "bare identifiers remember scalar/array/hash kind after initialization"
    );
}

// ── SPEC-FORMAT-TERSE.2.1.3 — Rust expression-valued block parity:
// non-empty non-hash braces are value blocks, matching the Perl core landed in
// `.2.1.2`; hash literals keep precedence and true mid-block return remains
// separate.

#[test]
fn terse_2_1_3_expression_valued_block_returns_last_expression() {
    let grammar = "Top::\n /x/ -> Done { return({ set(x, \"a\"); x }) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["a"]),
        "block values return their final expression"
    );
}

#[test]
fn terse_2_1_3_expression_valued_block_final_return_is_local() {
    let grammar =
        "Top::\n /x/ -> Done { return({ set(x, \"a\"); return(x) }) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["a"]),
        "a final return(expr) inside a block value yields the block payload"
    );
}

#[test]
fn terse_2_1_3_expression_valued_block_assignment_source_is_scalar() {
    let grammar = "Top::\n /x/ -> Done { set(out, { set(x, \"a\"); x }); return(out) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["a"]),
        "assignment-source block values do not infer hash targets"
    );
}

#[test]
fn terse_2_1_3_expression_valued_blocks_compose_with_hash_literals() {
    let grammar = "Top::\n /x/ -> Done { return(array({ set(x, \"a\"); x }, { set(key, \"stage\"); set(value, \"ok\"); { key => value } }, {}, { key => value })) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["a", {"stage": "ok"}, {}, {"stage": "ok"}]]),
        "block values compose in arrays while empty/keyed braces stay hash literals"
    );
}

// ── SPEC-FORMAT-TERSE.2.1.4 — block-local early return:
// return(expr) exits only the expression-valued block, does not set the
// surrounding rule return channel, and skips later block statements.

#[test]
fn terse_2_1_4_expression_valued_block_nonfinal_return_is_local() {
    let grammar = "Top::\n /x/ -> Done { return({ return(\"a\"); \"b\" }) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["a"]),
        "non-final return(expr) yields the block payload"
    );
}

#[test]
fn terse_2_1_4_expression_valued_block_assignment_source_stops_after_return() {
    let grammar = "Top::\n /x/ -> Done { set(out, { set(x, \"a\"); return(x); set(x, \"b\"); x }); return(out) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["a"]),
        "early return(expr) skips later block statements in assignment-source blocks"
    );
}

#[test]
fn terse_2_1_4_expression_valued_blocks_compose_with_early_return_hash() {
    let grammar = "Top::\n /x/ -> Done { return(array({ return(\"a\"); \"b\" }, { set(x, \"c\"); return({ \"k\" => x }); \"bad\" })) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["a", {"k": "c"}]]),
        "early-return block values compose while hash-literal payloads keep shape"
    );
}

// ── SPEC-FORMAT-TERSE.2.2.3 — Rust attached-block if parity:

#[test]
fn terse_2_2_3_attached_if_elseif_else_runs_selected_branch() {
    let grammar = "Top::\n /x/ -> Done { if(false) { return(\"bad\") } elseif(true) { return(\"yes\") } else { return(\"no\") } }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["yes"]),
        "attached-block if/elseif/else executes the selected branch"
    );
}

#[test]
fn terse_2_2_3_attached_if_preserves_marker_and_inline_if_forms() {
    let grammar = "Top::\n /x/ -> Done { if(false); return(\"bad\"); else(); set(marker, \"marker\"); endif(); set(inline, if(false, \"bad\", \"inline\")); return(array(marker, inline)) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["marker", "inline"]]),
        "attached-block parsing does not claim marker-form or inline if expressions"
    );
}

// ── SPEC-FORMAT-TERSE.2.2.4 — when/otherwise conditional aliases:

#[test]
fn terse_2_2_4_when_otherwise_alias_runs_selected_branch() {
    let true_branch = "Top::\n /x/ -> Done { when(true) { return(\"yes\") } otherwise { return(\"no\") } }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(true_branch, "xhello"),
        serde_json::json!(["yes"]),
        "when(true)/otherwise normalizes to attached if/else and executes the true branch"
    );

    let fallback_branch = "Top::\n /x/ -> Done { when(false) { return(\"yes\") } otherwise { return(\"no\") } }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(fallback_branch, "xhello"),
        serde_json::json!(["no"]),
        "when(false)/otherwise normalizes to attached if/else and executes the fallback"
    );
}

// ── SPEC-FORMAT-TERSE.2.2.5.2 — Rust attached-block switch parity:

#[test]
fn terse_2_2_5_2_attached_switch_selects_first_matching_case() {
    let grammar = "Top::\n /x/ -> Done { set(kind, \"a\"); switch(:kind) { case(\"a\") { return(\"first\") } case(\"a\") { return(\"second\") } default { return(\"default\") } } }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["first"]),
        "attached switch uses first-match case semantics"
    );
}

#[test]
fn terse_2_2_5_2_attached_switch_selects_later_case_and_default() {
    let later_case = "Top::\n /x/ -> Done { set(kind, \"b\"); switch(:kind) { case(\"a\") { return(\"bad\") } case(\"b\") { return(\"later\") } default { return(\"default\") } } }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(later_case, "xhello"),
        serde_json::json!(["later"]),
        "attached switch can select a later case"
    );

    let fallback = "Top::\n /x/ -> Done { set(kind, \"z\"); switch(:kind) { case(\"a\") { return(\"bad\") } case(\"b\") { return(\"bad\") } default { return(\"default\") } } }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(fallback, "xhello"),
        serde_json::json!(["default"]),
        "attached switch falls through to default"
    );
}

#[test]
fn terse_2_2_5_2_attached_switch_branches_gate_side_effects() {
    let grammar = "Top::\n /x/ -> Done { set(kind, \"b\"); set(out, \"start\"); switch(:kind) { case(\"a\") { set(out, \"bad\") } case(\"b\") { if(true) { set(out, \"matched\") } else { set(out, \"bad\") } } default { set(out, \"default\") } }; return(out) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["matched"]),
        "only the active attached switch branch mutates state"
    );
}

#[test]
fn terse_2_2_5_2_attached_switch_preserves_inline_value_form() {
    let grammar = "Top::\n /x/ -> Done { set(kind, \"b\"); set(inline, switch(:kind, case(\"a\", \"bad\"), case(\"b\", \"inline\"), default(\"default\"))); switch(:kind) { case(\"b\") { set(attached, \"attached\") } default { set(attached, \"bad\") } }; return(array(inline, attached)) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["inline", "attached"]]),
        "attached switch parsing does not claim or weaken inline lazy switch expressions"
    );
}

// ── SPEC-FORMAT-TERSE.15.2.3 — Rust parity for bare value reads:

#[test]
fn terse_15_2_3_bare_reads_in_switch_num_and_if_value_positions() {
    let grammar = "Top::\n /x/ -> Done { set(kind, \"b\"); set(n, 10); set(c, 0); set(switch_out, switch(kind, case(\"a\", \"bad\"), case(\"b\", \"good\"), default(\"def\"))); set(num_out, if(num_lt(n, 5), \"yes\", else(\"no\"))); set(if_out, if(c, \"T\", else(\"F\"))); return(array(switch_out, num_out, if_out)) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["good", "no", "F"]]),
        "bare names in switch selectors, numeric helper args, and if conditions read bound values"
    );
}

#[test]
fn terse_15_2_3_bare_switch_case_labels_are_literal_tags() {
    let attached = "Top::\n /x/ -> Done { set(kind, \"foo\"); set(foo, \"bar\"); switch(kind) { case(foo) { attached = \"literal\" } case(:foo) { attached = \"slot\" } default { attached = \"default\" } }; set(inline, switch(kind, case(foo, \"literal\"), case(:foo, \"slot\"), default(\"default\"))); return(array(attached, inline)) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(attached, "xhello"),
        serde_json::json!([["literal", "literal"]]),
        "bare case labels are literal tags for both attached and inline switch"
    );

    let scalar_slot = "Top::\n /x/ -> Done { set(kind, \"bar\"); set(foo, \"bar\"); switch(kind) { case(foo) { attached = \"literal\" } case(:foo) { attached = \"slot\" } default { attached = \"default\" } }; set(inline, switch(kind, case(foo, \"literal\"), case(:foo, \"slot\"), default(\"default\"))); return(array(attached, inline)) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(scalar_slot, "xhello"),
        serde_json::json!([["slot", "slot"]]),
        "scalar-slot case labels still evaluate through the normal expression path during the transition"
    );
}

// ── SPEC-FORMAT-TERSE.2.2.6.2 — Rust attached-block while parity:

#[test]
fn terse_2_2_6_2_attached_while_counts_and_reevaluates_condition() {
    let grammar = "Top::\n /x/ -> Done { set(count, 0); while(num_lt(:count, 3)) { set(count, num_add(:count, 1)) }; return(count) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([3]),
        "attached while re-evaluates its condition after body mutation"
    );
}

#[test]
fn terse_2_2_6_2_attached_while_composes_with_if_and_switch_blocks() {
    let grammar = "Top::\n /x/ -> Done { set(count, 0); set(kind, \"a\"); set(out, \"\"); while(num_lt(:count, 2)) { if(true) { switch(:kind) { case(\"a\") { set(out, cat(:out, \"A\")); set(kind, \"b\") } default { set(out, cat(:out, \"B\")) } } } else { set(out, \"bad\") }; set(count, num_add(:count, 1)) }; return(out) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["AB"]),
        "attached while bodies can contain existing attached if/switch controls"
    );
}

#[test]
fn terse_2_2_6_2_attached_while_return_exits_rule_block() {
    let grammar = "Top::\n /x/ -> Done { while(true) { return(\"done\") }; return(\"bad\") }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["done"]),
        "return(expr) inside an attached while exits the surrounding rule action"
    );
}

#[test]
fn terse_2_2_6_2_attached_while_composes_inside_expression_blocks() {
    let grammar = "Top::\n /x/ -> Done { set(counted, { set(count, 0); while(num_lt(:count, 2)) { set(count, num_add(:count, 1)) }; count }); set(local, { while(true) { return(\"local\") }; \"bad\" }); return(array(counted, local)) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[2, "local"]]),
        "attached while composes with expression-valued block side effects and local return"
    );
}

#[test]
fn terse_2_2_6_2_attached_while_has_iteration_safety_limit() {
    let grammar = "Top::\n /x/ -> Done { while(true) { set(count, num_add(:count, 1)) } }\n\nDone::\n /[a-z]+/\n";
    let err = build_and_run_result(grammar, "xhello").unwrap_err();
    assert!(
        err.contains("LinkedSpec while iteration safety limit exceeded after 10000 iterations"),
        "non-terminating attached while must hit the deterministic safety guard: {err}"
    );
}

// ── SPEC-FORMAT-TERSE.2.3.2 — lifecycle block value/drop channel:
// lifecycle blocks execute statements and discard statement values. A top-level
// lifecycle return(expr) records a surrounding rule return event, while
// return(expr) inside an expression-valued block remains block-local.

#[test]
fn terse_2_3_2_lifecycle_statement_values_are_discarded() {
    let grammar = "Top::\n I { set(out, \"from_i\"); set(ignored, \"i-final\") }\n /x/\n E { return(hash(\"out\", :out, \"ignored\", :ignored)) }\n";
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!([{"ignored": "i-final", "out": "from_i"}]),
        "final lifecycle statement values do not become implicit rule returns"
    );
}

#[test]
fn terse_2_3_2_lifecycle_return_records_surrounding_rule_return() {
    let grammar =
        "Top::\n I { return(\"from_i\"); set(out, \"after\") }\n /x/\n E { return(out) }\n";
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!(["from_i"]),
        "top-level I return(expr) exits the rule before matching or E"
    );
}

#[test]
fn terse_2_3_2_lifecycle_return_undef_records_surrounding_rule_return() {
    let grammar =
        "Top::\n I { return_undef(); return(\"bad\") }\n /x/\n E { return(\"also_bad\") }\n";
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!([]),
        "block-form return_undef() exits the surrounding rule without pushing an accumulator value"
    );
}

#[test]
fn terse_2_3_2_action_edge_return_exits_before_lx() {
    let grammar = "Top::\n /x/ -> Done { return(\"good\") }\n LX { return(\"bad\") }\n\nDone:\n /y/\n I.return_undef()\n";
    assert_eq!(
        build_and_run(grammar, "xy"),
        serde_json::json!(["good"]),
        "attached action-block return(expr) exits before the rule can fall through to LX"
    );
}

#[test]
fn terse_2_3_2_child_rule_capture_slice_starts_after_entry_match() {
    let grammar = "Top::\n -> Body .push\n E { return(array_copy(array(Top))) }\n\nBody: /\\{/ /\\}/\n -> Body[1] { return(capture_slice()) }\n";
    assert_eq!(
        build_and_run(grammar, "{abc}"),
        serde_json::json!([["abc"]]),
        "a dispatched delimiter rule captures the text island between its opener and close edge"
    );
}

#[test]
fn terse_2_3_2_expression_block_return_inside_lifecycle_stays_local() {
    let grammar = "Top::\n I { set(out, { return(\"block\"); \"after\" }); set(after, \"continued\") }\n /x/\n E { return(hash(\"out\", :out, \"after\", :after)) }\n";
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!([{"after": "continued", "out": "block"}]),
        "return(expr) inside an expression-valued block does not write the rule return channel"
    );
}

// ── SPEC-FORMAT-TERSE.2.3.3.1 — Rust action-edge fluent continuations:
// no-arg `.push` dispatches the child and appends the child return to the
// current rule's same-named accumulator; `.return(expr)` returns the expression
// for the triggering edge without forcing a recursive close-edge dispatch.

#[test]
fn terse_2_3_3_1_action_edge_fluent_push_appends_child_return() {
    let grammar = "top::\n -> item .push\n E { return(array_copy(array(top))) }\n\nitem:\n /x/\n I { return(entry_text()) }\n";
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!([["x"]]),
        "action-edge .push appends the child return without leaking the child return event"
    );
}

#[test]
fn rust_parity_7_3_4_1_header_rest_action_edge_allows_compact_arrow_spacing() {
    let grammar =
        "top::->item.push\nE{return(array_copy(array(top)))}\n\nitem:/x/I.return(entry_text())\n";
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!([["x"]]),
        "header-rest action-edge dispatch accepts zero spaces after ::, ->, and before .push"
    );
}

#[test]
fn rust_parity_7_3_4_4_dependency_edge_child_entry_captures() {
    let grammar = "top::\n -> item .push\n E { return(array_copy(array(top))) }\n\nitem:\n /\\b(\\w+)=(\\w+)/\n I { return(array(\"ITEM\", entry_group(0), entry_group(1))) }\n";
    assert_eq!(
        build_and_run(grammar, "foo=bar"),
        serde_json::json!([[["ITEM", "foo", "bar"]]]),
        "an edge-only parent match resolved from the child regex seeds the child entry captures"
    );
}

#[test]
fn rust_parity_7_3_4_4_regex_subst_mutates_scalar_targets() {
    let grammar = r#"Top::
 -> Item .push
 E { return(array_copy(array(Top))) }

Item:
 /("[^"]+")/
 I { raw = entry_group(0); substr(:raw, "\"", "", go); bracket = "[42]"; substr(:bracket, /^\[(\d+)\]$/, "$1", o); csv = "a,b"; parts = []; split(array(parts), :csv, /,/); return(array(:raw, :bracket, copy(array(parts)))) }
"#;
    assert_eq!(
        build_and_run(grammar, "\"abc\""),
        serde_json::json!([[["abc", "42", ["a", "b"]]]]),
        "statement-form regex_subst mutates scalars and split mutates array targets"
    );
}

#[test]
fn rust_parity_7_3_4_4_lib_reader_keeps_entry_captures() {
    use std::fs;
    use std::path::Path;

    let spec_path = Path::new(env!("CARGO_MANIFEST_DIR")).join("../../specs/lib_reader.spec");
    let grammar = fs::read_to_string(&spec_path).expect("read specs/lib_reader.spec");

    assert_eq!(
        build_and_run(&grammar, "cell(\"foo\"){ attr : \"bar\"; }"),
        serde_json::json!([[["GROUP", "cell", "foo", [["SATTRIBUTE", "attr", "bar"]]]]]),
        "lib_reader sattribute nodes retain the group opener and attribute entry captures"
    );
    assert_eq!(
        build_and_run(&grammar, "cell(\"foo\"){ attr(\"bar,baz\"); }"),
        serde_json::json!([[[
            "GROUP",
            "cell",
            "foo",
            [["CATTRIBUTE", "attr", ["bar", "baz"]]]
        ]]]),
        "lib_reader cattribute nodes retain the group opener and attribute entry captures"
    );
}

#[test]
fn rust_parity_7_3_4_2_array_constructor_splices_flattening_helpers() {
    let grammar = r#"Top::
 /x/
 I {
   set(array(parts), array("a", "b"));
   return(array("?node:", array(flat_array(parts)), array_copy(parts)));
 }
"#;
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!([["?node:", ["a", "b"], ["a", "b"]]]),
        "array(flat_array(name)) splices into the inner constructor while array_copy(name) stays nested"
    );
}

#[test]
fn rust_parity_7_3_4_2_boolean_helpers_match_flow_truthiness() {
    let grammar = r#"Top::
 /x/
 I {
   return(array(
     or(false, "", "0", is_nonempty("x")),
     and(true, 1, is_nonempty("x")),
     not(false),
     not("x")
   ));
 }
"#;
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!([[true, true, true, false]]),
        "or/and/not use RuntimeValue truthiness compatible with Rust flow predicates"
    );
}

#[test]
fn rust_parity_7_3_4_2_portmap_scalar_classifications_run() {
    use std::fs;
    use std::path::Path;

    let spec_path = Path::new(env!("CARGO_MANIFEST_DIR")).join("../../specs/portmap.spec");
    let grammar = fs::read_to_string(&spec_path).expect("read specs/portmap.spec");

    assert_eq!(
        build_and_run(&grammar, "foo"),
        serde_json::json!([["?bare:", ["foo"]]]),
        "portmap bare signal classification keeps a one-level capture snapshot"
    );
    assert_eq!(
        build_and_run(&grammar, "bar[3]"),
        serde_json::json!([["?bit:", ["bar", "3"]]]),
        "portmap bit classification uses or(...) and preserves flat capture shape"
    );
    assert_eq!(
        build_and_run(&grammar, "baz[7:0]"),
        serde_json::json!([["?slice:", ["baz", "7", "0"]]]),
        "portmap slice classification preserves both numeric slice captures"
    );
    assert_eq!(
        build_and_run(&grammar, "0x1f"),
        serde_json::json!([["?constant:", ["0x1f"]]]),
        "portmap constant classification preserves the constant capture"
    );
}

#[test]
fn rust_parity_7_3_4_3_portmap_concatenation_aggregates_child_returns() {
    use std::fs;
    use std::path::Path;

    let spec_path = Path::new(env!("CARGO_MANIFEST_DIR")).join("../../specs/portmap.spec");
    let grammar = fs::read_to_string(&spec_path).expect("read specs/portmap.spec");

    assert_eq!(
        build_and_run(&grammar, "{foo bar[2]}"),
        serde_json::json!([["?concat:", [["?bare:", ["foo"]], ["?bit:", ["bar", "2"]]]]]),
        "portmap recursive concatenation keeps child classification payloads in the concatenation target"
    );
}

#[test]
fn rust_parity_7_3_4_3_action_edge_block_call_uses_edge_match() {
    let grammar = r#"Top::
-> Header { item = call(Header); return(:item) }

Header: /A/ I.return(array("h", entry_text()))
"#;

    assert_eq!(
        build_and_run(grammar, "A"),
        serde_json::json!([["h", "A"]]),
        "call(child) inside an action-edge block reads the already matched edge child"
    );
}

#[test]
fn rust_parity_7_3_4_3_scoped_fluent_push_keeps_current_token_match() {
    let grammar = r#"Top:: I {
  rules = [];
  rule = [];
  rule = undef;
  on = undef
}

LX {
  if(:rule);
    push(array(rules), array(:rule, flat_array(rule)));
  endif();

  return(array_copy(array(rules)))
}

-> Header { rule = call(Header); on = 1 }

-> Word
  .if(:on)
    .push(Word, rule)
  .else()
    .return_undef()
  .endif()

Header: /(?m)^([A-Z]\w*)\s*:=/ I.return(array("header", entry_group(0)))
Word: /\b[A-Z][a-z]*\b/ I.return(array("word", entry_text()))
"#;

    assert_eq!(
        build_and_run(grammar, "Expr := Term\n"),
        serde_json::json!([[[["header", "Expr"], ["word", "Term"]]]]),
        "scoped fluent push(child, target) appends the current token edge return"
    );
}

#[test]
fn rust_parity_7_3_4_3_action_block_push_child_index_uses_edge_match() {
    let grammar = r#"Top::
-> Pair { push(Pair, 1) }
LX { return(array_copy(array(Top))) }

Pair: /(\w+):(\w+)/ I.return(array(entry_group(0), entry_group(1)))
"#;

    assert_eq!(
        build_and_run(grammar, "left:right"),
        serde_json::json!([["right"]]),
        "statement push(child, index) reads the already matched action-edge child return"
    );
}

#[test]
fn rust_parity_7_3_4_3_ebnf_grammar_rule_header_regex_matches() {
    let grammar = r#"Top::
-> grammar_rule .push
LX { return(array_copy(array(Top))) }

grammar_rule: /(?m)^\s*([[:alpha:]_]\w*)\s*:{,2}=/ I.return(array("rule", entry_group(0)))
"#;

    let spec = parse_spec_with_user_functions(grammar).expect("parse");
    validate(&spec).expect("validate");
    let compiled = compile(&spec).expect("compile");
    let grammar_rule = compiled.find("grammar_rule").expect("grammar_rule");
    assert_eq!(
        grammar_rule.regex_patterns,
        vec![r"(?m)^\s*([[:alpha:]_]\w*)\s*:{,2}=".to_string()]
    );
    let top = compiled.find("Top").expect("Top");
    assert_eq!(
        top.regex_patterns,
        vec![r"(?m)^\s*([[:alpha:]_]\w*)\s*:{,2}=".to_string()],
        "edge-only Top dispatch must be resolved from the child grammar_rule regex"
    );
    assert_eq!(top.acode_dispatch.len(), 1);
    assert_eq!(top.acode_dispatch[0].regex_idx, 0);
    assert_eq!(top.acode_dispatch[0].child_label, "grammar_rule");
    assert_eq!(
        top.acode_dispatch[0].fluent_chain,
        vec![("push".to_string(), String::new())]
    );

    assert_eq!(
        Engine::new(compiled)
            .execute("Expr := Term\n")
            .expect("execute"),
        serde_json::json!([[["rule", "Expr"]]]),
        "Rust matches the shipped ebnf grammar_rule header regex before aggregating payload tokens"
    );
}

#[test]
fn rust_parity_7_3_4_3_ebnf_rule_payloads_do_not_duplicate_headers() {
    use std::fs;
    use std::path::Path;

    let spec_path = Path::new(env!("CARGO_MANIFEST_DIR")).join("../../specs/ebnf.spec");
    let grammar = fs::read_to_string(&spec_path).expect("read specs/ebnf.spec");

    assert_eq!(
        build_and_run(&grammar, "Expr := Term (\"+\" Term)*\nTerm := Factor\n"),
        serde_json::json!([[
            [
                ["rule", "Expr"],
                ["rule_reference", "Term"],
                ["group_open", "("],
                ["quoted_string", "+"],
                ["rule_reference", "Term"],
                ["group_close", ")"],
                ["operator", "*"]
            ],
            [["rule", "Term"], ["rule_reference", "Factor"]]
        ]]),
        "ebnf rule payloads preserve token returns without recursively appending rule headers"
    );
}

#[test]
fn rust_parity_7_3_4_3_ebnf_logging_annotation_payloads_are_preserved() {
    use std::fs;
    use std::path::Path;

    let spec_path = Path::new(env!("CARGO_MANIFEST_DIR")).join("../../specs/ebnf.spec");
    let grammar = fs::read_to_string(&spec_path).expect("read specs/ebnf.spec");

    assert_eq!(
        build_and_run(&grammar, "Expr := Term @log_rule(\"expr\", \"term\")\n"),
        serde_json::json!([[[
            ["rule", "Expr"],
            ["rule_reference", "Term"],
            ["logging_annotation", ["log_rule", ["expr", "term"]]]
        ]]]),
        "ebnf logging_annotation child returns survive push(child, rule) aggregation"
    );
}

#[test]
fn terse_2_3_3_1_action_edge_fluent_return_closes_recursive_rule() {
    let grammar = "top::\n -> box .push\n E { return(array_copy(array(top))) }\n\nbox:* /\\[/ /\\]/\n -> item .push\n -> box[1] .return(array(\"?box:\", array_copy(array(box))))\n\nitem:\n /x/\n I { return(entry_text()) }\n";
    assert_eq!(
        build_and_run(grammar, "[x]"),
        serde_json::json!([[["?box:", ["x"]]]]),
        "action-edge .return(expr) returns the current rule payload at the close edge"
    );
}

#[test]
fn terse_2_3_3_1_action_edge_fluent_return_undef_skips_accumulator() {
    let grammar = "top::\n -> item .return_undef\n\nitem:\n /x/\n I { return(entry_text()) }\n";
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!([]),
        "action-edge .return_undef returns undef without adding an accumulator event"
    );
}

// ── SPEC-FORMAT-TERSE.2.3.3.2 — Rust attached fluent block payloads:
// action-edge and lifecycle receiver-fluent `.when(cond) { ... }` payloads
// normalize to attached when/otherwise statement blocks. The fallback tail may
// be dotted (`.otherwise`) or no-dot (`otherwise`), matching the Perl reference.

#[test]
fn terse_2_3_3_2_action_edge_attached_fluent_when_dotted_otherwise() {
    let grammar = "Top::\n /x/ -> Done.when(false) { return(\"bad\") }.otherwise { return(\"fallback\") }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["fallback"]),
        "dotted action-edge .otherwise executes the fallback attached payload"
    );
}

#[test]
fn terse_2_3_3_2_action_edge_attached_fluent_when_nodot_otherwise() {
    let grammar = "Top::\n /x/ -> Done.when(false) { return(\"bad\") } otherwise { return(\"fallback\") }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["fallback"]),
        "no-dot action-edge otherwise executes the fallback attached payload"
    );
}

#[test]
fn terse_2_3_3_2_lifecycle_attached_fluent_when_dotted_otherwise() {
    let grammar = "Top::\n I.when(false) { set(out, \"bad\") }.otherwise { set(out, \"fallback\") }\n /x/\n E { return(out) }\n";
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!(["fallback"]),
        "dotted lifecycle .otherwise executes the fallback attached payload"
    );
}

#[test]
fn terse_2_3_3_2_lifecycle_attached_fluent_when_nodot_otherwise() {
    let grammar = "Top::\n I.when(false) { set(out, \"bad\") } otherwise { set(out, \"fallback\") }\n /x/\n E { return(out) }\n";
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!(["fallback"]),
        "no-dot lifecycle otherwise executes the fallback attached payload"
    );
}

// ── SPEC-FORMAT-TERSE.2.3.3.3.1 — Rust compact lifecycle/body receiver chains:
// lifecycle-marker fluent chains normalize to executable lifecycle statement
// blocks instead of surviving as dropped standalone FluentChain body elements.

#[test]
fn terse_2_3_3_3_1_lifecycle_compact_return_records_rule_return() {
    let grammar = "Top::\n I.return(\"from_i\")\n /x/\n E.return(\"from_e\")\n";
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!(["from_i"]),
        "compact I.return(expr) exits the rule before matching or E"
    );
}

#[test]
fn terse_2_3_3_3_1_lifecycle_compact_chain_executes_in_order() {
    let grammar = "Top::\n I.declare(scalar, out).set(out, \"ok\")\n /x/\n E.return(out)\n";
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!(["ok"]),
        "compact lifecycle helper chains execute as ordered lifecycle statements"
    );
}

#[test]
fn terse_2_3_3_3_1_inline_lifecycle_compact_chain_executes() {
    let grammar = "Top:: /x/ I.declare(scalar, out).set(out, \"header\") E.return(out)\n";
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!(["header"]),
        "header-line lifecycle fluent chains are parsed into lifecycle statements"
    );
}

// ── SPEC-FORMAT-TERSE.2.3.3.3.2 — Rust action-edge explicit/flow
// fluent chains: multiline action-edge continuations stay attached to the
// edge, `.push(target)` / `.push(child,target)` dispatch through the child
// return channel, and fluent statement controls gate the following calls.

#[test]
fn terse_2_3_3_3_2_action_edge_fluent_push_target_appends_child_return() {
    let grammar = "top::\n I { declare(array, out) }\n -> item.push(out)\n E { return(array_copy(array(out))) }\n\nitem: /x/ I.return(entry_text())\n";
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!([["x"]]),
        "action-edge .push(target) appends the child return to the named array target"
    );
}

#[test]
fn terse_2_3_3_3_2_action_edge_fluent_flow_push_child_target_true_branch() {
    let grammar = "top::\n I { declare(array, out); declare(scalar, on); set(on, true) }\n -> item\n  .if(:on)\n    .push(item, out)\n  .else()\n    .return_undef()\n  .endif()\n E { return(array_copy(array(out))) }\n\nitem: /x/ I.return(entry_text())\n";
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!([["x"]]),
        "active fluent .if branch dispatches .push(child,target)"
    );
}

#[test]
fn terse_2_3_3_3_2_action_edge_fluent_flow_return_undef_false_branch() {
    let grammar = "top::\n I { declare(array, out); declare(scalar, on); set(on, false) }\n -> item\n  .if(:on)\n    .push(item, out)\n  .else()\n    .say(\"missing item\")\n    .return_undef()\n  .endif()\n E { return(array_copy(array(out))) }\n\nitem: /x/ I.return(entry_text())\n";
    assert_eq!(
        build_and_run(grammar, "x"),
        serde_json::json!([]),
        "inactive fluent .if branch skips push and active else return_undef closes the edge"
    );
}

// ── SPEC-FORMAT-TERSE.2.3.4.1 — Rust aggregate-helper bare args:

#[test]
fn terse_2_3_4_1_bare_hash_merge_arg_matches_wrapped() {
    let bare = "Top::\n /x/ -> Done { set_key(base, \"b\", 2); set_key(base, \"a\", 1); set_key(overlay, \"c\", 3); return(count(drop_front(sorted_keys(merge_hash(hash_copy(base), overlay))))) }\n\nDone::\n /[a-z]+/\n";
    let wrapped = "Top::\n /x/ -> Done { set_key(base, \"b\", 2); set_key(base, \"a\", 1); set_key(overlay, \"c\", 3); return(count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay)))))) }\n\nDone::\n /[a-z]+/\n";
    let actual = build_and_run(bare, "xhello");
    assert_eq!(
        actual,
        serde_json::json!([2]),
        "merge_hash(hash_copy(base), overlay) reads overlay as a hash snapshot"
    );
    assert_eq!(
        actual,
        build_and_run(wrapped, "xhello"),
        "bare hash helper argument matches the explicit hash(overlay) wrapper"
    );
}

#[test]
fn terse_2_3_4_1_hash_consumers_accept_bare_hash_arg() {
    let grammar = r#"Top::
 /x/ -> Done { set_key(meta, "b", 2); set_key(meta, "a", 1); set_key(extra, "c", 3); return(array(sorted_keys(set_key(meta, "c", 3)), sorted_keys(rename_key(meta, "a", "aa")), sorted_keys(drop_keys(meta, "b")), sorted_keys(pick_keys(meta, "a")), has_key(meta, "a"), hash(meta).pick_keys("b").sorted_values().first(), count_keys(flat_hash(meta, extra)))) }

Done::
 /[a-z]+/
"#;
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[["a", "b", "c"], ["aa", "b"], ["a"], ["a"], true, 2, 3]]),
        "hash-consuming helper slots read bare hash working variables as snapshots"
    );
}

#[test]
fn scalaref_retirement_3_direct_access_reads_child_retval_field() {
    let grammar = r#"Top::
 /x/ -> Done { return(retv["content"]) }

Done::
 /[a-z]+/ I.return(hash("content", entry_text()))
"#;
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["x"]),
        "direct nested access reads a literal hash field from the child return value"
    );
}

#[test]
fn scalaref_retirement_3_direct_access_walks_nested_arrays_and_hashes() {
    let grammar = r#"Top::
 /x/ -> Done { set(i, 1); return(retv["children"][i]["name"]) }

Done::
 /[a-z]+/ I.return(hash("children", array(hash("name", "zero"), hash("name", entry_text()))))
"#;
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!(["x"]),
        "direct nested access walks hash keys and explicit scalar array indexes"
    );
}

#[test]
fn scalaref_retirement_4_function_helper_returns_undef_as_unknown_helper() {
    let grammar = r#"Top::
 /x/ -> Done { return(scalaref(retv, "content")) }

Done::
 /[a-z]+/ I.return(hash("content", entry_text()))
"#;
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([null]),
        "function-form scalaref is no longer a recognized Rust helper"
    );
}

#[test]
fn scalaref_retirement_4_receiver_method_returns_undef() {
    let grammar = r#"Top::
 /x/ -> Done { set_key(meta, "a", 1); return(hash(meta).scalaref("a")) }

Done::
 /[a-z]+/
"#;
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([null]),
        "receiver-dot scalaref is no longer a recognized Rust hash method"
    );
}

#[test]
fn rust_parity_7_5_2_assign_array_wrapper_replaces_array_value() {
    let grammar = "Top::\n /x/ -> Done { push_value(array(word), \"x\"); word = []; push_value(array(word), \"y\"); return(array_copy(array(word))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["y"]]),
        "name = [] replaces the working array instead of assigning a scalar"
    );
}

#[test]
fn rust_parity_7_5_2_set_hash_wrapper_replaces_hash_value() {
    let grammar = "Top::\n /x/ -> Done { set_key(hash(meta), \"old\", \"x\"); set(hash(meta), hash(\"new\", \"y\")); return(hash_copy(hash(meta))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([{"new": "y"}]),
        "set(hash(name), hash(...)) replaces the working hash instead of assigning a scalar"
    );
}

#[test]
fn terse_2_3_4_1_array_consumers_accept_bare_array_arg() {
    let grammar = "Top::\n /x/ -> Done { items += \"b\"; items += \"a\"; nums += 1; nums += 2; extra += \"c\"; return(array(sorted(items), reversed(items), first(items), last(items), take(items, 1), take_last(items, 1), drop_front(items), drop_back(items), slice(items, 1, 1), contains(items, \"a\"), index_of(items, \"a\"), num_sum(nums), flat_array(items, extra))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[
            ["a", "b"],
            ["a", "b"],
            "b",
            "a",
            ["b"],
            ["a"],
            ["a"],
            ["b"],
            ["a"],
            true,
            1,
            3,
            ["b", "a", "c"]
        ]]),
        "array-consuming helper slots read bare array working variables as snapshots"
    );
}

// ── SPEC-FORMAT-TERSE.2.3.5.1 — array receiver-dot value chains:

#[test]
fn terse_2_3_5_1_array_receiver_value_chains_run() {
    let grammar = "Top::\n /x/ -> Done { items += \"b\"; items += \"a\"; items += \"c\"; items += \"a\"; phrases += \"aa-b\"; phrases += \"c-aa\"; return(array(items.sorted().drop_front(2).first(), array(items).reversed().take(2).last(), items.sorted().contains(\"c\"), items.sorted().index_of(\"c\"), items.drop_back().join_values(\"|\"), items.uniq().join_values(\",\"), items.filter_match(/^a$/).count(), phrases.split_each(\"-\").filter_match(/^aa$/).count(), items.sorted().is_nonempty(), missing.sorted().is_empty())) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["b", "c", true, 3, "b|a|c", "b,a,c", 2, 2, true, true]]),
        "array receiver-dot value chains feed each returned value into the next array helper"
    );
}

#[test]
fn terse_2_3_5_1_array_end_mutations_remain_statement_only_in_value_slots() {
    let grammar = "Top::\n /x/ -> Done { items.push_back(\"seed\"); return(array(items.push_back(\"value\"), array_copy(items))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[null, ["seed"]]]),
        "push_back remains statement-only when it appears in a value expression"
    );
}

// ── SPEC-FORMAT-TERSE.2.3.5.2 — hash receiver-dot value chains:

#[test]
fn terse_2_3_5_2_hash_receiver_value_chains_run() {
    let grammar = r#"Top::
 /x/ -> Done { set_key(meta, "b", 2); set_key(meta, "a", 1); set_key(extra, "a", 9); set_key(extra, "c", 3); set(hash(layered), merge_hash(hash(meta), hash(extra))); return(array(meta.set_key("c", 3).sorted_keys().join_values(","), hash(layered).pick_keys("a").sorted_values().first(), hash(meta).rename_key("a", "aa").drop_keys("b").set_key("z", 4).count_keys(), meta.pick_keys("a", "missing").has_key("a"), meta.pick_keys("missing").count_keys(), meta.sorted_values().drop_front(1).first(), meta.hash_copy().flat_hash().count_keys(), missing.hash_copy().count_keys())) }

Done::
 /[a-z]+/
"#;
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["a,b,c", 9, 2, true, 0, 2, 2, 0]]),
        "hash receiver-dot value chains feed hash and array-returning helper results into compatible next helpers"
    );
}

#[test]
fn terse_2_3_5_2_hash_statement_mutations_remain_statement_level() {
    let grammar = "Top::\n /x/ -> Done { set_key(meta, \"a\", 1); set(snapshot, meta.set_key(\"b\", 2)); meta[\"c\"] = 3; return(array(join_values(\",\", sorted_keys(hash(meta))), count_keys(:snapshot))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["a,c", 2]]),
        "receiver-dot set_key is a pure value while statement set_key and hash-index assignment still mutate meta"
    );
}

// ── SPEC-FORMAT-TERSE.2.3.5.3 — string receiver-dot value chains:

#[test]
fn terse_2_3_5_3_string_receiver_value_chains_run() {
    let grammar = "Top::\n /x/ -> Done { set(raw, \" Node-Name_end \"); return(array(raw.trim().lowercase().replace_substr(\"-\", \"_\").rm_prefix(\"node_\").rm_suffix(\"_end\").cat(\"!\"), raw.trim().length(), raw.trim().starts_with(\"Node\"), raw.trim().lowercase().matches(/^node/), raw.trim().contains_substr(\"-\"), raw.trim().ends_with(\"_end\"), raw.trim().split(\"-\").trim_each().lowercase_each().join_values(\"|\"), \" a-b \".trim().split(\"-\").count(), \"abcdef\".substr(1, 3).uppercase(), raw.coalesce_nonempty(\"fallback\").trim())) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[
            "name!",
            13,
            true,
            true,
            true,
            true,
            "node|name_end",
            2,
            "BCD",
            "Node-Name_end"
        ]]),
        "string receiver-dot value chains compose string helpers and bridge split results into array chains"
    );
}

#[test]
fn terse_2_3_5_3_string_terminal_methods_end_chains() {
    let grammar = "Top::\n /x/ -> Done { set(raw, \"abc\"); return(array(raw.length().trim(), raw.matches(/^a/).lowercase())) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[null, null]]),
        "string receiver terminal values cannot continue into later receiver-dot methods"
    );
}

// ── SPEC-FORMAT-TERSE.2.3.5.4 — number receiver-dot value chains:

#[test]
fn terse_2_3_5_4_number_receiver_value_chains_run() {
    let grammar = "Top::\n /x/ -> Done { set(score, -3.7); return(array(score.abs().ceil().add(2, 3).mul(2).sub(1).div(2).clamp(0, 20).max(5).min(12), 5.mod(2), 3.5.floor().add(1), 3.5.round(), score.abs().gt(3), score.abs().le(4))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[8.5, 1, 4, 4, true, true]]),
        "number receiver-dot value chains compose numeric helpers and comparisons"
    );
}

#[test]
fn terse_2_3_5_4_number_terminal_methods_end_chains() {
    let grammar = "Top::\n /x/ -> Done { return(array(5.gt(3).add(1), 5.eq(5).abs())) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[null, null]]),
        "number receiver comparison terminal values cannot continue into later receiver-dot methods"
    );
}

// ── SPEC-FORMAT-TERSE.7.3 — array numeric reducer receiver methods:

#[test]
fn terse_7_3_array_numeric_reducer_receiver_methods_run() {
    let grammar = "Top::\n /x/ -> Done { scores += 1; scores += 5; scores += 3; scores += 5; return(array(scores.sum(), scores.avg(), scores.median(), scores.range(), scores.min(), scores.max(), scores.sorted().take(3).avg(), scores.uniq().sum(), num_min(array(scores)), num_max(array(scores)), min(scores), max(scores))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[14, 3.5, 4, 4, 1, 5, 3, 9, 1, 5, 1, 5]]),
        "array receiver numeric reducers terminate array chains and match the array-form helper aliases"
    );
}

#[test]
fn terse_7_3_array_numeric_reducer_receiver_methods_end_chains() {
    let grammar = "Top::\n /x/ -> Done { scores += 1; scores += 2; return(array(scores.sum().drop_front(1), scores.min().sorted())) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[null, null]]),
        "array receiver numeric reducer terminals cannot continue into later receiver-dot methods"
    );
}

// ── SPEC-FORMAT-TERSE.3.2.1 — numeric word aliases:

#[test]
fn terse_3_2_1_numeric_word_aliases_run() {
    let grammar = "Top::\n /x/ -> Done { return(array(add(2,3,4), sub(10,3), mul(2,3,4), div(9,2), mod(17,5), abs(-7), floor(3.7), ceil(3.2), round(3.5), min(8,3,5), max(8,3,5), clamp(add(2,5),0,6), sum(array(1,2,3)), avg(array(2,4,6)), median(array(1,5,3)), range(array(1,5,3)))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[9, 7, 24, 4.5, 2, 7, 3, 4, 4, 3, 8, 6, 6, 4, 3, 4]]),
        "numeric word aliases dispatch through the existing num_* helper family"
    );
}

// ── SPEC-FORMAT-TERSE.3.2.2 — arithmetic symbol callees:

#[test]
fn terse_3_2_2_arithmetic_symbol_callees_run() {
    let grammar = "Top::\n /x/ -> Done { return(array(+(2,3,4), -(10,3), *(2,3,4), /(9,2), %(17,5), +(2, *(3,4)))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[9, 7, 24, 4.5, 2, 14]]),
        "arithmetic symbol callees dispatch through the existing num_* helper family"
    );
}

// ── SPEC-FORMAT-TERSE.3.2.3.2 — explicit string comparison helpers:

#[test]
fn terse_3_2_3_2_string_comparison_helpers_run() {
    let grammar = "Top::\n /x/ -> Done { return(array(str_eq(\"a\",\"a\"), str_ne(\"a\",\"b\"), str_gt(\"2\",\"10\"), str_ge(\"2\",\"2\"), str_lt(\"10\",\"2\"), str_le(\"10\",\"10\"), str_gt(\"10\",\"2\"), num_gt(\"10\",\"2\"))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[true, true, true, true, true, true, false, true]]),
        "str_* helpers preserve lexical string semantics while num_gt remains numeric"
    );
}

// ── SPEC-FORMAT-TERSE.3.2.3.3 — numeric comparison word aliases:

#[test]
fn terse_3_2_3_3_numeric_comparison_word_aliases_run() {
    let grammar = "Top::\n /x/ -> Done { return(array(eq(\"2\",\"2\"), ne(\"2\",\"3\"), gt(\"10\",\"2\"), ge(\"2\",\"2\"), lt(\"2\",\"10\"), le(\"2\",\"2\"), gt(\"2\",\"10\"), str_gt(\"2\",\"10\"))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[true, true, true, true, true, true, false, true]]),
        "bare comparison word calls dispatch numerically while str_gt remains lexical"
    );
}

// ── SPEC-FORMAT-TERSE.3.2.3.4 — numeric comparison symbol callees:

#[test]
fn terse_3_2_3_4_numeric_comparison_symbol_callees_run() {
    let grammar = "Top::\n /x/ -> Done { return(array(==(\"2\",\"2\"), !=(\"2\",\"3\"), >(\"10\",\"2\"), >=(\"2\",\"2\"), <(\"2\",\"10\"), <=(\"2\",\"2\"), >(\"2\",\"10\"), str_gt(\"2\",\"10\"))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[true, true, true, true, true, true, false, true]]),
        "comparison symbol calls dispatch numerically while str_gt remains lexical"
    );
}

// ── SPEC-FORMAT-TERSE.3.3.1 — scalar assignment expression values:

#[test]
fn terse_3_3_1_scalar_assignment_expressions_run() {
    let grammar = r#"fn store(value) { return(local = value) }
Top::
 /x/ -> Done { return(array(name = "ok", name, =(other, cat(:name, "!")), other, set(third, store("fn")), third, { block = cat(:third, "!"); block }, =(raw, " hi ").trim())) }

Done::
 /[a-z]+/
"#;
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["ok", "ok", "ok!", "ok!", "fn", "fn", "fn!", "hi"]]),
        "scalar assignment expressions store and return the scalar value in return/helper/block/function/receiver-chain contexts"
    );
}

// ── SPEC-FORMAT-TERSE.3.3.2 — aggregate assignment expression values:

#[test]
fn terse_3_3_2_aggregate_assignment_expressions_run() {
    let grammar = r#"Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); return(array(items = [value], array_copy(array(items)), set(meta, { key => value }), hash_copy(hash(meta)), set(:payload, [value]), payload, =(more, [value, "x"]).count())) }

Done::
 /[a-z]+/
"#;
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[["ok"], ["ok"], {"stage": "ok"}, {"stage": "ok"}, ["ok"], ["ok"], 2]]),
        "aggregate assignment expressions store and return arrays/hashes while ... keeps payloads"
    );
}

// ── SPEC-FORMAT-TERSE.3.3.3 — mutation assignment expression values:

#[test]
fn terse_3_3_3_mutation_assignment_expressions_run() {
    let grammar = r#"Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); return(array(items += value, array_copy(items), meta[key] = value, hash_copy(meta), (items += "x").count(), (meta["last"] = value).count_keys())) }

Done::
 /[a-z]+/
"#;
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[["ok"], ["ok"], {"stage": "ok"}, {"stage": "ok"}, 2, 2]]),
        "mutation assignment expressions store and return aggregate snapshots"
    );
}

// ── SPEC-FORMAT-TERSE.3.3.4 — assignment expression closure:

#[test]
fn terse_3_3_4_assignment_expression_closure_run() {
    let grammar = r#"fn keep(value) { return(fn_out = value) }
Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); return(array(name = value, name, =(other, cat(:name, "!")), other, set(third, keep("fn")), third, set(current, "surface"), current, items = [value], array(items), set(meta, { key => value }), hash(meta), set(array(items_mut), [value]), items_mut += "tail", copy(array(items_mut)), set(hash(meta_mut), { key => value }), meta_mut["extra"] = other, copy(hash(meta_mut)), (items_mut += "last").count(), (meta_mut["last"] = value).count_keys())) }

Done::
 /[a-z]+/
"#;
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[
            "ok",
            "ok",
            "ok!",
            "ok!",
            "fn",
            "fn",
            "surface",
            "surface",
            ["ok"],
            ["ok"],
            {"stage": "ok"},
            {"stage": "ok"},
            ["ok"],
            ["ok", "tail"],
            ["ok", "tail"],
            {"stage": "ok"},
            {"extra": "ok!", "stage": "ok"},
            {"extra": "ok!", "stage": "ok"},
            3,
            3
        ]]),
        "assignment expression closure composes scalar, aggregate, mutation, and legacy compatibility forms"
    );
}

// ── SPEC-FORMAT-TERSE.4.3.2 — Rust user-function runtime parity:

#[test]
fn terse_4_3_2_user_function_value_calls_run() {
    let grammar = r#"fn normalize(value) { return(trim(value)) }
fn bracket(value) { return(cat("[", value, "]")) }
Top::
 /x/ -> Done { return(array(normalize(" x "), bracket(normalize(" y ")))) }

Done::
 /[a-z]+/
"#;
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["x", "[y]"]]),
        "registered user functions execute as ordinary value calls"
    );
}

#[test]
fn terse_4_3_2_user_function_scope_is_local() {
    let grammar = r#"fn shadow(value) { set(value, "function"); set(extra, "hidden"); return(value) }
Top::
 /x/ -> Done { set(value, "caller"); return(array(shadow("arg"), value, extra)) }

Done::
 /[a-z]+/
"#;
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["function", "caller", null]]),
        "function-local variables and params do not leak into the caller"
    );
}

#[test]
fn terse_4_3_2_user_function_receiver_chains_continue_by_returned_type() {
    let grammar = r#"fn words(value) { return([trim(value), uppercase(trim(value))]) }
fn meta() { return({ "b" => 2, "a" => 1 }) }
Top::
 /x/ -> Done { return(array(words(" go ").join_values("|"), words(" a ").count(), meta().sorted_keys().join_values(","))) }

Done::
 /[a-z]+/
"#;
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["go|GO", 2, "a,b"]]),
        "returned arrays and hashes feed compatible receiver-dot value chains"
    );
}

#[test]
fn terse_4_3_2_user_function_standalone_results_are_discarded() {
    let grammar = r#"fn touch(value) { set(scratch, cat(value, "!")); return(scratch) }
Top::
 /x/ -> Done { touch("drop"); touch("X").lowercase(); return(array("ok", scratch)) }

Done::
 /[a-z]+/
"#;
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["ok", null]]),
        "standalone user-function calls execute and discard their return values"
    );
}

#[test]
fn terse_4_3_2_user_function_wrong_arity_diagnoses() {
    let grammar = r#"fn one(value) { return(value) }
Top::
 /x/ -> Done { return(one()) }

Done::
 /[a-z]+/
"#;
    let err = build_and_run_result(grammar, "xhello").unwrap_err();
    assert!(
        err.contains("user function 'one' expects 1 argument(s), got 0"),
        "expected exact-arity diagnostic, got: {err}"
    );
}

#[test]
fn terse_4_3_2_user_function_recursion_diagnoses() {
    let grammar = r#"fn loop(value) { return(loop(value)) }
Top::
 /x/ -> Done { return(loop("x")) }

Done::
 /[a-z]+/
"#;
    let err = build_and_run_result(grammar, "xhello").unwrap_err();
    assert!(
        err.contains("recursive user function call 'loop' is not supported"),
        "expected recursion diagnostic, got: {err}"
    );
}

#[test]
fn terse_4_3_2_user_function_mutual_recursion_diagnoses() {
    let grammar = r#"fn left(value) { return(right(value)) }
fn right(value) { return(left(value)) }
Top::
 /x/ -> Done { return(left("x")) }

Done::
 /[a-z]+/
"#;
    let err = build_and_run_result(grammar, "xhello").unwrap_err();
    assert!(
        err.contains("recursive user function call 'left' is not supported"),
        "expected mutual-recursion diagnostic, got: {err}"
    );
}

// ── SPEC-FORMAT-TERSE.2.3.5.5 — block-valued receiver-dot chains:

#[test]
fn terse_2_3_5_5_block_valued_receiver_chains_run() {
    let grammar = "Top::\n /x/ -> Done { return(array({ [3, 1, 2] }.sorted().join_values(\",\"), { return([\"x\", \"y\"]); [\"bad\"] }.join_values(\"|\"), { set(raw, \" a-b \"); raw }.trim().split(\"-\").count(), { { \"b\" => 2, \"a\" => 1 } }.sorted_keys().join_values(\",\"), { 3.5 }.floor().add(2))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([["1,2,3", "x|y", 2, "a,b", 5]]),
        "block-valued receivers feed their yielded values into compatible array/string/hash/number receiver families"
    );
}

// ── SPEC-FORMAT-TERSE.2.3.5.6 — typed wrapper quoted-name boundaries:

#[test]
fn terse_2_3_5_6_typed_wrapper_quoted_boundaries_run() {
    let grammar = "Top::\n /x/ -> Done { items += \"a\"; items += \"b\"; set_key(meta, \"a\", 1); set_key(meta, \"b\", 2); return(array(count(array(items)), count(array(\"items\")), count(array('items')), count(a(items)), count(a(\"items\")), count([\"items\"]), count(array(\"literal\", \"value\")), count_keys(hash(meta)), count_keys(hash(\"meta\", 1)), count_keys(hash('meta', 1)), count_keys({ \"meta\" => 1 }), count_keys(h(meta)), count_keys(h(\"meta\", 1)))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[2, 1, 1, 2, 1, 1, 2, 2, 1, 1, 1, 2, 1]]),
        "bare wrappers read working variables while quoted wrappers and direct shapes construct literal payloads"
    );
}

#[test]
fn terse_2_3_5_6_quoted_names_are_not_runtime_indirect_lookups() {
    let grammar = "Top::\n /x/ -> Done { set(alias, \"items\"); items += \"a\"; set(hash_alias, \"meta\"); set_key(meta, \"a\", 1); return(array(count(array(\"alias\")), count(array(alias)), count(array(items)), count_keys(hash(\"hash_alias\", 1)), count_keys(hash(hash_alias)), count_keys(hash(meta)))) }\n\nDone::\n /[a-z]+/\n";
    assert_eq!(
        build_and_run(grammar, "xhello"),
        serde_json::json!([[1, 0, 1, 1, 0, 1]]),
        "quoted wrapper arguments are literal constructor payloads, not scalar-indirect aggregate names"
    );
}
