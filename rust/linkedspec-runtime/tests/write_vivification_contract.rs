//! FUTURE-PARITY-BACKLOG.19.3.1 — Rust nested-write vivification contract.

use linkedspec_core::ast::SpecFile;
use linkedspec_core::compiler::compile;
use linkedspec_core::expr::{CodeBlock, Expr};
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, emit_rust_source_v2, execute_generated_parser_v2,
    validate_generated_parser_plan_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

const CONTRACT_JSON: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../capability_conformance/write_vivification_contract.json"
));

const TOP_DONE_PLAN: &[GeneratedPlanRow] = &[
    GeneratedPlanRow {
        label: "Top",
        family: "default",
    },
    GeneratedPlanRow {
        label: "Done",
        family: "default",
    },
];

fn contract() -> Value {
    serde_json::from_str(CONTRACT_JSON).expect("write-vivification contract JSON")
}

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse write-vivification fixture");
    validate(&parsed).expect("validate write-vivification fixture");
    compile(&parsed).expect("compile write-vivification fixture")
}

fn spec_for_action(action: &str) -> String {
    format!("Top::\n -> Done {{ {action} }}\n\nDone::\n /[a-z]+/\n")
}

fn dsl_literal(value: &Value) -> String {
    match value {
        Value::Null => "undef".to_string(),
        Value::Bool(value) => value.to_string(),
        Value::Number(value) => value.to_string(),
        Value::String(value) => serde_json::to_string(value).expect("quote string literal"),
        Value::Array(values) => format!(
            "[{}]",
            values
                .iter()
                .map(dsl_literal)
                .collect::<Vec<_>>()
                .join(", ")
        ),
        Value::Object(values) => format!(
            "{{ {} }}",
            values
                .iter()
                .map(|(key, value)| format!(
                    "{} : {}",
                    serde_json::to_string(key).expect("quote harray key"),
                    dsl_literal(value)
                ))
                .collect::<Vec<_>>()
                .join(", ")
        ),
    }
}

fn identifier(source: &str) -> bool {
    source
        .chars()
        .next()
        .is_some_and(|character| character.is_ascii_alphabetic() || character == '_')
        && source
            .chars()
            .all(|character| character.is_ascii_alphanumeric() || character == '_')
}

fn ordinary_case_action(case: &Value, include_result: bool) -> String {
    let mut statements = Vec::new();
    if case["initial_binding"]["present"] == true {
        statements.push(format!(
            "document = {}",
            dsl_literal(&case["initial_binding"]["value"])
        ));
    }
    for segment in case["segments"].as_array().expect("segments") {
        let source = segment["source"].as_str().expect("segment source");
        if identifier(source) && !matches!(source, "true" | "false" | "null" | "undef") {
            let value = if segment["kind"] == "codeblock" {
                r#"{|value| return(value) }"#.to_string()
            } else {
                dsl_literal(&segment["value"])
            };
            statements.push(format!("{source} = {value}"));
        }
    }
    let rhs_source = case["rhs"]["source"].as_str().expect("rhs source");
    if identifier(rhs_source) {
        statements.push(format!(
            "{rhs_source} = {}",
            dsl_literal(&case["rhs"]["value"])
        ));
    }
    if include_result {
        statements.push(format!(
            "result = ({})",
            case["source"].as_str().expect("case source")
        ));
        statements.push("return(array(document, result))".to_string());
    } else {
        statements.push(case["source"].as_str().expect("case source").to_string());
    }
    statements.join("; ")
}

fn execute_native(source: &str) -> Result<Value, String> {
    Engine::new(compile_source(source)).execute_value("xhello", &ExecutionOptions::new())
}

fn nested_error(error: &str) -> Value {
    serde_json::from_str(error)
        .unwrap_or_else(|_| panic!("expected structured nested-write error: {error}"))
}

#[test]
fn frozen_ast_and_syntax_inventory_is_projected_by_the_rust_parser() {
    let contract = contract();
    assert_eq!(contract["contract_id"], "linkedspec-write-vivification-v1");
    assert_eq!(contract["valid_syntax_cases"].as_array().unwrap().len(), 5);
    assert_eq!(
        contract["invalid_syntax_cases"].as_array().unwrap().len(),
        7
    );
    assert_eq!(
        contract["excluded_syntax_cases"].as_array().unwrap().len(),
        4
    );

    for case in contract["valid_syntax_cases"].as_array().unwrap() {
        let source = case["source"].as_str().unwrap();
        let block = CodeBlock::parse(source).unwrap_or_else(|error| {
            panic!("{} failed to parse: {error}", case["id"]);
        });
        let Expr::AssignNestedAccess {
            source: parsed_source,
            source_span,
            base,
            segments,
            ..
        } = &block.statements[0].expr
        else {
            panic!("{} did not use assign_nested_access", case["id"]);
        };
        let expected = &case["expected_ast"];
        assert_eq!(parsed_source, source, "{} source", case["id"]);
        assert_eq!(
            base,
            expected["base"].as_str().unwrap(),
            "{} base",
            case["id"]
        );
        assert_eq!(
            source_span.start,
            expected["source_span"]["start"].as_u64().unwrap() as usize
        );
        assert_eq!(
            source_span.end,
            expected["source_span"]["end"].as_u64().unwrap() as usize
        );
        assert_eq!(
            segments.len(),
            expected["segments"].as_array().unwrap().len()
        );
        for (segment, expected) in segments
            .iter()
            .zip(expected["segments"].as_array().unwrap())
        {
            assert_eq!(segment.kind, "path_segment");
            assert_eq!(segment.source, expected["source"].as_str().unwrap());
            assert_eq!(
                segment.source_span.start,
                expected["source_span"]["start"].as_u64().unwrap() as usize
            );
            assert_eq!(
                segment.source_span.end,
                expected["source_span"]["end"].as_u64().unwrap() as usize
            );
            let expression = serde_json::to_value(segment.expression.as_ref())
                .expect("serialize typed path expression");
            let expected_kind = match expected["expression"]["kind"].as_str().unwrap() {
                "identifier" => "variable",
                "integer_literal" => "number",
                "string_literal" => "string",
                other => other,
            };
            assert_eq!(
                expression["kind"], expected_kind,
                "{} expression kind",
                case["id"]
            );
        }
    }

    for case in contract["invalid_syntax_cases"].as_array().unwrap() {
        let error = CodeBlock::parse(case["source"].as_str().unwrap()).unwrap_err();
        let diagnostic = &case["diagnostic"];
        assert!(
            error.contains(diagnostic["code"].as_str().unwrap()),
            "{}: {error}",
            case["id"]
        );
        assert!(
            error.contains(&format!(
                "start:{},end:{}",
                diagnostic["source_span"]["start"].as_u64().unwrap(),
                diagnostic["source_span"]["end"].as_u64().unwrap()
            )),
            "{}: {error}",
            case["id"]
        );
        assert!(
            error.contains("stage=action_parse"),
            "{}: {error}",
            case["id"]
        );
        assert!(
            error.contains(diagnostic["message"].as_str().unwrap()),
            "{}: {error}",
            case["id"]
        );
    }

    for case in contract["excluded_syntax_cases"].as_array().unwrap() {
        let source = case["source"].as_str().unwrap();
        match case["classification"].as_str().unwrap() {
            "not_nested_write" => assert!(matches!(
                CodeBlock::parse(source).unwrap().statements[0].expr,
                Expr::AssignScalar { .. }
            )),
            "read_only" => assert!(matches!(
                CodeBlock::parse(source).unwrap().statements[0].expr,
                Expr::NestedAccess { .. }
            )),
            "unsupported_helper" => assert!(matches!(
                CodeBlock::parse(source).unwrap().statements[0].expr,
                Expr::Call { ref name, .. } if name == "vivify"
            )),
            "unsupported_operator" => {
                let error = CodeBlock::parse(source).unwrap_err();
                assert!(
                    !error.contains("assign_nested_access"),
                    "{}: {error}",
                    case["id"]
                );
            }
            other => panic!("unknown exclusion classification {other}"),
        }
    }
}

#[test]
fn all_frozen_success_cases_execute_natively() {
    let contract = contract();
    let cases = contract["success_cases"].as_array().unwrap();
    assert_eq!(cases.len(), 11);
    for case in cases {
        let action = match case["id"].as_str().unwrap() {
            "rhs_same_binding_side_effect_composes" => {
                r#"document = { "audit" : [] }; result = (document["value"] = { document = { "audit" : ["rhs"] }; "done" }); return(array(document, result))"#.to_string()
            }
            "segment_same_binding_side_effect_composes" => {
                r#"result = (document[{ document = { "seed" : 1 }; "value" }] = "done"); return(array(document, result))"#.to_string()
            }
            _ => ordinary_case_action(case, true),
        };
        let actual = execute_native(&spec_for_action(&action))
            .unwrap_or_else(|error| panic!("{} failed: {error}", case["id"]));
        assert_eq!(
            actual,
            json!([
                case["expected_binding"].clone(),
                case["expected_result"].clone()
            ]),
            "{}",
            case["id"]
        );
    }
}

#[test]
fn all_frozen_structural_failures_return_exact_typed_fields() {
    let contract = contract();
    let cases = contract["failure_cases"].as_array().unwrap();
    assert_eq!(cases.len(), 16);
    for case in cases {
        let action = if case["id"] == "rhs_side_effect_survives_outer_gap" {
            r#"document = []; document[2] = { document = ["rhs"]; "outer" }"#.to_string()
        } else {
            ordinary_case_action(case, false)
        };
        let error =
            execute_native(&spec_for_action(&action)).expect_err(case["id"].as_str().unwrap());
        let payload = nested_error(&error);
        let expected = &case["expected_error"];
        assert_eq!(payload["code"], expected["code"], "{} code", case["id"]);
        assert_eq!(payload["operation"], "nested_write_vivification");
        assert_eq!(payload["binding"], "document");
        for field in [
            "segment_index",
            "path",
            "actual_kind",
            "reason",
            "expected_kind",
            "index",
            "length",
        ] {
            if !expected[field].is_null() {
                assert_eq!(payload[field], expected[field], "{} {field}", case["id"]);
            }
        }
        let expected_message = match expected["code"].as_str().unwrap() {
            "nested_write_segment_invalid" => format!(
                "nested write segment {} for binding 'document' must evaluate to a string or nonnegative integer; got {} ({})",
                expected["segment_index"].as_u64().unwrap(),
                expected["actual_kind"].as_str().unwrap(),
                expected["reason"].as_str().unwrap(),
            ),
            "nested_write_kind_conflict" => format!(
                "nested write segment {} for binding 'document' requires {}; found {}",
                expected["segment_index"].as_u64().unwrap(),
                expected["expected_kind"].as_str().unwrap(),
                expected["actual_kind"].as_str().unwrap(),
            ),
            "nested_write_array_gap" => format!(
                "nested write segment {} for binding 'document' cannot create array index {} at length {}",
                expected["segment_index"].as_u64().unwrap(),
                expected["index"].as_u64().unwrap(),
                expected["length"].as_u64().unwrap(),
            ),
            other => panic!("unexpected nested-write diagnostic {other}"),
        };
        assert_eq!(
            payload["message"], expected_message,
            "{} message",
            case["id"]
        );
        let target = expected["source_target"].as_str().unwrap();
        let index = target
            .strip_prefix("segment:")
            .unwrap()
            .parse::<usize>()
            .unwrap();
        let authored_block = CodeBlock::parse(&action).expect("parse executed failure action");
        let authored_segments = authored_block
            .statements
            .iter()
            .find_map(|statement| match &statement.expr {
                Expr::AssignNestedAccess { segments, .. } => Some(segments),
                _ => None,
            })
            .expect("executed action contains nested write");
        assert_eq!(
            payload["source_span"]["start"], authored_segments[index].source_span.start,
            "{} authored span start",
            case["id"]
        );
        assert_eq!(
            payload["source_span"]["end"], authored_segments[index].source_span.end,
            "{} authored span end",
            case["id"]
        );
        assert_eq!(payload["source_span"]["unit"], "unicode_scalar");
        assert_eq!(payload["source_span"]["provenance"], "authored");
    }
}

#[test]
fn user_function_locals_start_absent_each_call_and_parameters_start_present() {
    let fresh_local_source = r#"fn build_document() {
 document["items"][0] = "value";
 return(document)
}

Top::
 -> Done { return([build_document(), build_document()]) }

Done::
 /[a-z]+/
"#;
    assert_eq!(
        execute_native(fresh_local_source).expect("execute repeated fresh-local nested writes"),
        json!([
            {"items": ["value"]},
            {"items": ["value"]},
        ])
    );

    let present_parameter_source = r#"fn write_document(document) {
 document["key"] = "value";
 return(document)
}

Top::
 -> Done { return(write_document(undef)) }

Done::
 /[a-z]+/
"#;
    let error = execute_native(present_parameter_source)
        .expect_err("an explicitly bound null parameter must not vivify");
    let payload = nested_error(
        &error
            .strip_prefix("user function 'write_document': ")
            .unwrap_or(&error),
    );
    assert_eq!(payload["code"], "nested_write_kind_conflict");
    assert_eq!(payload["binding"], "document");
    assert_eq!(payload["segment_index"], 0);
    assert_eq!(payload["expected_kind"], "harray");
    assert_eq!(payload["actual_kind"], "null");
}

#[test]
fn native_serialized_generated_plan_and_emitted_source_share_one_typed_node() {
    let action =
        r#"key_name = "sections"; document[key_name][0]["title"] = "Intro"; return(document)"#;
    let source = spec_for_action(action);
    let expected = json!({"sections": [{"title": "Intro"}]});
    let parsed = parse_spec_with_user_functions(&source).expect("parse typed SpecFile");
    let spec_json = serde_json::to_string(&parsed).expect("serialize typed SpecFile");
    let reconstructed_spec: SpecFile =
        serde_json::from_str(&spec_json).expect("reconstruct typed SpecFile");
    validate(&reconstructed_spec).expect("validate reconstructed typed SpecFile");
    let compiled = compile(&reconstructed_spec).expect("compile reconstructed typed SpecFile");

    assert_eq!(
        Engine::new(compiled.clone())
            .execute_value("xhello", &ExecutionOptions::new())
            .unwrap(),
        expected
    );
    let compiled_json = serde_json::to_string(&compiled).expect("serialize typed CompiledSpec");
    assert!(compiled_json.contains(r#""kind":"path_segment""#));
    assert!(compiled_json.contains(r#""source":"key_name""#));
    let reconstructed: CompiledSpec =
        serde_json::from_str(&compiled_json).expect("reconstruct typed CompiledSpec");
    assert_eq!(
        Engine::new(reconstructed)
            .execute_value("xhello", &ExecutionOptions::new())
            .unwrap(),
        expected
    );

    validate_generated_parser_plan_v2(
        &compiled_json,
        TOP_DONE_PLAN,
        "write-vivification.spec",
        GENERATED_SOURCE_CONTRACT,
    )
    .expect("validate generated plan");
    assert_eq!(
        execute_generated_parser_v2(
            &compiled_json,
            TOP_DONE_PLAN,
            "xhello",
            "write-vivification.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("execute generated plan"),
        expected
    );

    let corrupted = compiled_json.replacen(
        r#""kind":"path_segment""#,
        r#""kind":"corrupt_path_segment""#,
        1,
    );
    let corrupted_compiled: CompiledSpec =
        serde_json::from_str(&corrupted).expect("decode deliberately corrupted carrier");
    let native_error = Engine::new(corrupted_compiled)
        .execute_value("xhello", &ExecutionOptions::new())
        .expect_err("native execution must reject corrupted nested-write carriers");
    assert!(
        native_error.contains("nested_write_serialized_state_invalid"),
        "{native_error}"
    );
    let error = validate_generated_parser_plan_v2(
        &corrupted,
        TOP_DONE_PLAN,
        "write-vivification-corrupt.spec",
        GENERATED_SOURCE_CONTRACT,
    )
    .expect_err("generated decode must reject corrupted nested-write carriers");
    assert!(
        error
            .to_string()
            .contains("nested_write_serialized_state_invalid"),
        "{error}"
    );
    assert_independently_compiled_emitted_source(&compiled, &expected);
}

struct GeneratedTestProject {
    root: PathBuf,
}

impl GeneratedTestProject {
    fn new() -> Self {
        let nonce = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("system clock")
            .as_nanos();
        let root = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("../target/test-workspaces")
            .join(format!(
                "write-vivification-emitted-{}-{nonce}",
                std::process::id()
            ));
        fs::create_dir_all(root.join("src")).expect("create emitted-source workspace");
        Self { root }
    }
}

impl Drop for GeneratedTestProject {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

fn assert_independently_compiled_emitted_source(compiled: &CompiledSpec, expected: &Value) {
    let emitted = emit_rust_source_v2(compiled, "write-vivification-emitted.spec")
        .expect("emit typed write-vivification source");
    let expected = serde_json::to_string(expected).expect("serialize emitted expected value");
    let module = format!(
        r#"{emitted}

#[cfg(test)]
mod emitted_write_vivification_tests {{
    #[test]
    fn computed_string_path_vivifies() {{
        assert_eq!(
            super::execute("xhello").unwrap(),
            serde_json::from_str::<serde_json::Value>({expected:?}).unwrap()
        );
    }}
}}
"#
    );
    let project = GeneratedTestProject::new();
    fs::write(
        project.root.join("Cargo.toml"),
        r#"[package]
name = "linkedspec_write_vivification_emitted"
version = "0.0.0"
edition = "2024"

[dependencies]
linkedspec-runtime = { path = "../../../linkedspec-runtime" }
serde_json = "1"

[workspace]
"#,
    )
    .expect("write emitted manifest");
    fs::write(project.root.join("src/lib.rs"), module).expect("write emitted module");
    let output = Command::new("cargo")
        .arg("test")
        .arg("--offline")
        .arg("--quiet")
        .env("CARGO_TARGET_DIR", project.root.join("target"))
        .current_dir(&project.root)
        .output()
        .expect("run independently compiled emitted test");
    assert!(
        output.status.success(),
        "independently compiled emitted test failed\nstatus: {}\nstdout:\n{}\nstderr:\n{}",
        output.status,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
}
