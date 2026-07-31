//! FUTURE-PARITY-BACKLOG.11.4.1-.2 — Rust callable-codeblock state and invocation.

use std::collections::BTreeSet;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

use linkedspec_core::compiler::compile;
use linkedspec_core::expr::{CodeBlock, Expr};
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::Engine;
use linkedspec_runtime::semantic_index::{
    SemanticIndex, SemanticIndexOptions, SemanticSourceDetail,
};
use linkedspec_runtime::source_emitter::{
    GeneratedPlanRow, classify_generated_rule_family, emit_rust_source, emit_rust_source_v2,
    execute_generated_parser,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn contract() -> Value {
    serde_json::from_str(include_str!(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/../../capability_conformance/callable_codeblock_contract.json"
    )))
    .expect("callable-codeblock contract must be valid JSON")
}

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse callable-codeblock source");
    validate(&parsed).expect("validate callable-codeblock source");
    compile(&parsed).expect("compile callable-codeblock source")
}

fn assignment_value(source: &str) -> Expr {
    let block = CodeBlock::parse(&format!("value = {source}"))
        .unwrap_or_else(|error| panic!("parse expression {source:?}: {error}"));
    let Expr::AssignScalar { name, value } = block.statements[0].expr.clone() else {
        panic!("expected scalar assignment for {source:?}");
    };
    assert_eq!(name, "value");
    *value
}

fn construction_source(literal: &str) -> String {
    format!(
        r#"Top::
 /x/ -> Done {{
   state = "before";
   cb = {literal};
   alias = cb;
   return({{ "state" : state, "cb" : alias }})
 }}

Done::
 /x/
"#
    )
}

fn generated_plan(compiled: &CompiledSpec) -> Vec<GeneratedPlanRow> {
    compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Top" => "Top",
                "Done" => "Done",
                "FixedMissing" => "FixedMissing",
                "FixedExtra" => "FixedExtra",
                "RestMissingFixed" => "RestMissingFixed",
                "KeywordArgument" => "KeywordArgument",
                "BoundNonCodeblock" => "BoundNonCodeblock",
                "UnknownCall" => "UnknownCall",
                "DirectRecursion" => "DirectRecursion",
                other => panic!("unowned generated callable-codeblock rule: {other}"),
            },
            family: classify_generated_rule_family(rule).contract_name(),
        })
        .collect()
}

fn invalid_case_body(id: &str) -> &'static str {
    match id {
        "fixed_missing" => r#"cb = {|left, right| return(cat(left, right)) }; return(cb("a"))"#,
        "fixed_extra" => {
            r#"cb = {|left, right| return(cat(left, right)) }; return(cb("a", "b", "c"))"#
        }
        "rest_missing_fixed" => r#"cb = {|prefix, ...items| return(items) }; return(cb())"#,
        "keyword_argument" => r#"cb = {|value| return(value) }; return(cb(value: "x"))"#,
        "bound_non_codeblock" => r#"text = "not callable"; return(text())"#,
        "unknown_call" => r#"cb = {|| return(missing()) }; return(cb())"#,
        "direct_recursion" => r#"reader = {|| return(reader()) }; return(reader())"#,
        other => panic!("unowned invalid callable-codeblock case: {other}"),
    }
}

fn invalid_case_rule_label(id: &str) -> &'static str {
    match id {
        "fixed_missing" => "FixedMissing",
        "fixed_extra" => "FixedExtra",
        "rest_missing_fixed" => "RestMissingFixed",
        "keyword_argument" => "KeywordArgument",
        "bound_non_codeblock" => "BoundNonCodeblock",
        "unknown_call" => "UnknownCall",
        "direct_recursion" => "DirectRecursion",
        other => panic!("unowned invalid callable-codeblock case: {other}"),
    }
}

fn invalid_case_source(id: &str) -> String {
    format!(
        "{}::\n /x/\n E {{ {} }}\n",
        invalid_case_rule_label(id),
        invalid_case_body(id)
    )
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
                "callable-codeblock-emitted-{}-{nonce}",
                std::process::id()
            ));
        fs::create_dir_all(root.join("src")).expect("create emitted callable workspace");
        Self { root }
    }
}

impl Drop for GeneratedTestProject {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

#[test]
fn neutral_brace_classes_and_all_literal_records_are_exact() {
    let contract = contract();
    for case in contract["brace_classification"].as_array().unwrap() {
        let expression = assignment_value(case["source"].as_str().unwrap());
        let actual = match expression {
            Expr::HashLiteral { .. } => "harray_literal",
            Expr::BlockValue { .. } => "block_value",
            Expr::CodeblockLiteral(_) => "codeblock_literal",
            other => panic!("unexpected brace expression: {other:?}"),
        };
        assert_eq!(actual, case["expected_kind"], "{}", case["id"]);
    }

    let expected_fields = contract["ast_schema"]["fields"]
        .as_array()
        .unwrap()
        .iter()
        .map(|field| field.as_str().unwrap().to_string())
        .collect::<BTreeSet<_>>();
    for row in contract["literals"].as_array().unwrap() {
        let source = row["source"].as_str().unwrap();
        let prefix = "value = ";
        let expression = assignment_value(source);
        let serialized = serde_json::to_value(&expression).unwrap();
        assert_eq!(
            serialized
                .as_object()
                .unwrap()
                .keys()
                .cloned()
                .collect::<BTreeSet<_>>(),
            expected_fields,
            "{}",
            row["id"]
        );
        let Expr::CodeblockLiteral(literal) = expression else {
            panic!("{} did not parse as a callable codeblock", row["id"]);
        };
        assert_eq!(literal.version, 1);
        assert_eq!(literal.source_text, source);
        assert_eq!(literal.body_source, row["body_source"]);
        assert_eq!(literal.body_ast.kind, "action_block");
        assert_eq!(literal.body_ast.source, row["body_source"]);
        assert!(!literal.body_ast.statements.is_empty());
        assert_eq!(literal.source_span.start, prefix.chars().count());
        assert_eq!(
            literal.source_span.end,
            prefix.chars().count() + source.chars().count()
        );
        let body_start = source[2..].find('|').unwrap() + 3;
        assert_eq!(
            literal.body_span.start,
            prefix.chars().count() + source[..body_start].chars().count()
        );
        assert_eq!(
            literal.body_span.end,
            prefix.chars().count() + source[..source.len() - 1].chars().count()
        );
        assert_eq!(literal.signature.kind, "callable_signature");
        assert_eq!(literal.signature.version, 1);
        assert_eq!(
            literal.signature.min_arity,
            literal.signature.positional_params.len()
        );
        assert_eq!(
            literal.signature.max_arity,
            literal
                .signature
                .rest_param
                .is_none()
                .then_some(literal.signature.min_arity)
        );
    }
}

#[test]
fn spans_use_containing_unicode_character_coordinates() {
    let source = "note = \"é\";\ncb = {|value| return(value) }";
    let block = CodeBlock::parse(source).expect("parse Unicode-prefix literal");
    let Expr::AssignScalar { value, .. } = &block.statements[1].expr else {
        panic!("expected callable assignment");
    };
    let Expr::CodeblockLiteral(literal) = value.as_ref() else {
        panic!("expected callable literal");
    };
    let start = source.find("{|").unwrap();
    assert_eq!(literal.source_span.start, source[..start].chars().count());
    assert_eq!(literal.source_span.end, source.chars().count());

    let nested_source = "prefix = \"é\"; cb = {|| nested = {|value| return(value) } }";
    let nested_block = CodeBlock::parse(nested_source).expect("parse nested callable literals");
    let Expr::AssignScalar { value: outer, .. } = &nested_block.statements[1].expr else {
        panic!("expected outer callable assignment");
    };
    let Expr::CodeblockLiteral(outer) = outer.as_ref() else {
        panic!("expected outer callable literal");
    };
    let Expr::AssignScalar { value: inner, .. } = &outer.body_ast.statements[0].expr else {
        panic!("expected nested callable assignment");
    };
    let Expr::CodeblockLiteral(inner) = inner.as_ref() else {
        panic!("expected nested callable literal");
    };
    let inner_start = nested_source.rfind("{|").unwrap();
    assert_eq!(
        inner.source_span.start,
        nested_source[..inner_start].chars().count()
    );
}

#[test]
fn invalid_literals_keep_the_neutral_diagnostic_codes() {
    for case in contract()["invalid_literal_cases"].as_array().unwrap() {
        let source = format!("value = {}", case["source"].as_str().unwrap());
        let error = match CodeBlock::parse(&source) {
            Ok(_) => panic!("invalid literal unexpectedly parsed: {}", case["id"]),
            Err(error) => error,
        };
        assert!(
            error.contains(case["expected_code"].as_str().unwrap()),
            "{}: {error}",
            case["id"]
        );
    }
}

#[test]
fn construction_copy_compiled_json_and_generated_state_are_inert() {
    let contract = contract();
    let literal = contract["literals"]
        .as_array()
        .unwrap()
        .iter()
        .find(|row| row["id"] == "mutate_dynamic")
        .unwrap();
    let source = construction_source(literal["source"].as_str().unwrap());
    let compiled = compile_source(&source);
    let direct = Engine::new(compiled.clone())
        .execute("xx")
        .expect("construct callable codeblock");
    assert_eq!(direct[0]["state"], "before");
    assert_eq!(direct[0]["cb"]["kind"], "codeblock_literal");
    assert_eq!(direct[0]["cb"]["version"], 1);
    assert_eq!(direct[0]["cb"]["source_text"], literal["source"]);
    assert_eq!(direct[0]["cb"]["body_source"], literal["body_source"]);
    assert_eq!(direct[0]["cb"]["body_ast"]["kind"], "action_block");
    assert_eq!(
        direct[0]["cb"]["body_ast"]["source"],
        literal["body_source"]
    );
    assert_eq!(
        direct[0]["cb"]["signature"]["positional_params"],
        json!(["value"])
    );

    let encoded = serde_json::to_string(&compiled).expect("serialize compiled callable state");
    let decoded: CompiledSpec =
        serde_json::from_str(&encoded).expect("deserialize compiled callable state");
    assert_eq!(
        serde_json::to_value(&decoded).unwrap(),
        serde_json::to_value(&compiled).unwrap()
    );

    let generated = emit_rust_source(&compiled).expect("emit callable-codeblock Rust source");
    assert!(generated.contains("codeblock_literal"));
    assert!(generated.contains("body_source"));
    assert!(!generated.contains("Box<dyn Fn"));
    assert!(!generated.contains("move |"));

    let plan = [
        GeneratedPlanRow {
            label: "Top",
            family: classify_generated_rule_family(&compiled.rules[0]).contract_name(),
        },
        GeneratedPlanRow {
            label: "Done",
            family: classify_generated_rule_family(&compiled.rules[1]).contract_name(),
        },
    ];
    assert_eq!(
        execute_generated_parser(&encoded, &plan, "xx").expect("execute generated construction"),
        direct
    );
}

#[test]
fn neutral_fixture_executes_all_nine_fixture_cases_in_every_shared_runtime_path() {
    let contract = contract();
    let source = contract["fixture"]["spec_source"].as_str().unwrap();
    let input = contract["fixture"]["input"].as_str().unwrap();
    let expected = json!([contract["fixture"]["expected"]]);
    let compiled = compile_source(source);

    assert_eq!(
        Engine::new(compiled.clone())
            .execute(input)
            .expect("execute native callable fixture"),
        expected
    );

    let encoded = serde_json::to_string(&compiled).expect("serialize callable fixture");
    let decoded: CompiledSpec =
        serde_json::from_str(&encoded).expect("reconstruct callable fixture");
    assert_eq!(
        Engine::new(decoded)
            .execute(input)
            .expect("execute reconstructed callable fixture"),
        expected
    );
    assert_eq!(
        execute_generated_parser(&encoded, &generated_plan(&compiled), input)
            .expect("execute generated-plan callable fixture"),
        expected
    );
}

#[test]
fn standalone_effects_static_precedence_order_and_recursive_copy_are_exact() {
    let source = r#"fn choose() { return("static") }

Top::
 /x/
 E {
   state = "";
   append_state = {|value| state = cat(state, value); return(state) };
   append_state("x");
   cat = {|left, right| return("shadow") };
   choose = {|| return("shadow") };
   order = "";
   tick = {|value| order = cat(order, value); return(value) };
   joiner = {|left, right| return(cat(left, right)) };
   original = { "nested" : [{ "value" : "outer" }] };
   mutate_copy = {|copy| copy["nested"][0]["value"] = "inner"; return(copy) };
   mutated = mutate_copy(original);
   return({
     "discard_state" : state,
     "helper_precedence" : cat("a", "b"),
     "function_precedence" : choose(),
     "ordered_result" : joiner(tick("a"), tick("b")),
     "ordered_effect" : order,
     "original" : original,
     "mutated" : mutated
   })
 }
"#;
    let actual = Engine::new(compile_source(source))
        .execute("x")
        .expect("execute callable behavior extensions");
    assert_eq!(
        actual,
        json!([{
            "discard_state": "x",
            "helper_precedence": "ab",
            "function_precedence": "static",
            "ordered_result": "ab",
            "ordered_effect": "ab",
            "original": {"nested": [{"value": "outer"}]},
            "mutated": {"nested": [{"value": "inner"}]}
        }])
    );
}

#[test]
fn all_seven_neutral_failures_are_structured_and_survive_reconstruction() {
    let contract = contract();
    for case in contract["invalid_call_cases"].as_array().unwrap() {
        let id = case["id"].as_str().unwrap();
        let expected = case["expected_error"].as_object().unwrap();
        let compiled = compile_source(&invalid_case_source(id));

        let direct = Engine::new(compiled.clone())
            .execute_with_diagnostics("x")
            .unwrap_err();
        let diagnostic = direct.diagnostic().to_json().unwrap();
        for (field, value) in expected {
            assert_eq!(&diagnostic[field], value, "{id} field {field}");
        }

        let encoded = serde_json::to_string(&compiled).unwrap();
        let decoded: CompiledSpec = serde_json::from_str(&encoded).unwrap();
        let reconstructed = Engine::new(decoded)
            .execute_with_diagnostics("x")
            .unwrap_err();
        assert_eq!(
            reconstructed.diagnostic().to_json().unwrap(),
            diagnostic,
            "{id} reconstructed diagnostic"
        );

        let generated_error =
            execute_generated_parser(&encoded, &generated_plan(&compiled), "x").unwrap_err();
        assert!(
            generated_error.contains(expected["code"].as_str().unwrap()),
            "{id}: {generated_error}"
        );
    }
}

#[test]
fn mutual_recursion_reports_the_ordered_callable_cycle() {
    let source = r#"Top::
 /x/
 E {
   left = {|| return(right()) };
   right = {|| return(left()) };
   return(left())
 }
"#;
    let error = Engine::new(compile_source(source))
        .execute_with_diagnostics("x")
        .unwrap_err();
    assert_eq!(
        error.diagnostic().code.as_deref(),
        Some("codeblock_recursion_unsupported")
    );
    assert_eq!(
        error.diagnostic().cycle,
        Some(vec!["left".into(), "right".into(), "left".into()])
    );
}

#[test]
fn colon_keyword_syntax_does_not_bypass_registered_function_policy() {
    let source = r#"fn identity(value) { return(value) }

Top::
 /x/
 E { return(identity(value: "x")) }
"#;
    let error = Engine::new(compile_source(source))
        .execute_with_diagnostics("x")
        .unwrap_err();
    assert_eq!(
        error.diagnostic().code.as_deref(),
        Some("user_function_keyword_arguments_unsupported")
    );
}

#[test]
fn standalone_emitted_source_executes_fixture_and_all_invalid_cases() {
    let contract = contract();
    let fixture_compiled = compile_source(contract["fixture"]["spec_source"].as_str().unwrap());
    let fixture_emitted =
        emit_rust_source_v2(&fixture_compiled, "callable-codeblock/neutral-fixture.spec")
            .expect("emit callable fixture");

    let invalid_source = contract["invalid_call_cases"]
        .as_array()
        .unwrap()
        .iter()
        .map(|case| invalid_case_source(case["id"].as_str().unwrap()))
        .collect::<Vec<_>>()
        .join("\n");
    let invalid_compiled = compile_source(&invalid_source);
    let invalid_emitted =
        emit_rust_source_v2(&invalid_compiled, "callable-codeblock/invalid-cases.spec")
            .expect("emit callable failures");

    let expected_literal = format!(
        "{:?}",
        serde_json::to_string(&contract["fixture"]["expected"]).unwrap()
    );
    let invalid_assertions = contract["invalid_call_cases"]
        .as_array()
        .unwrap()
        .iter()
        .map(|case| {
            let id = case["id"].as_str().unwrap();
            let label = invalid_case_rule_label(id);
            let code = case["expected_error"]["code"].as_str().unwrap();
            format!(
                r#"let options = linkedspec_runtime::engine::ExecutionOptions::new().with_entry_rule({label:?});
        let error = super::invalid::execute_with_options("x", &options).unwrap_err();
        assert!(error.detail.as_deref().unwrap_or_default().contains({code:?}), "{id}: {{error:?}}");"#
            )
        })
        .collect::<Vec<_>>()
        .join("\n        ");
    let modules = format!(
        r#"pub mod fixture {{
{fixture_emitted}
}}

pub mod invalid {{
{invalid_emitted}
}}

#[cfg(test)]
mod emitted_callable_tests {{
    #[test]
    fn callable_contract_is_exact() {{
        let expected: serde_json::Value = serde_json::from_str({expected_literal}).unwrap();
        assert_eq!(super::fixture::execute("xx").unwrap(), expected);
        {invalid_assertions}
    }}
}}
"#
    );

    let project = GeneratedTestProject::new();
    fs::write(
        project.root.join("Cargo.toml"),
        r#"[package]
name = "linkedspec_callable_codeblock_emitted"
version = "0.0.0"
edition = "2024"

[dependencies]
linkedspec-runtime = { path = "../../../linkedspec-runtime" }
serde_json = "1"

[workspace]
"#,
    )
    .expect("write emitted callable manifest");
    fs::write(project.root.join("src/lib.rs"), modules).expect("write emitted callable module");

    let output = Command::new("cargo")
        .arg("test")
        .arg("--offline")
        .arg("--quiet")
        .env("CARGO_TARGET_DIR", project.root.join("target"))
        .current_dir(&project.root)
        .output()
        .expect("run emitted callable workspace");
    assert!(
        output.status.success(),
        "standalone emitted callable test failed\nstatus: {}\nstdout:\n{}\nstderr:\n{}",
        output.status,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
}

#[test]
fn user_functions_preserve_codeblock_arguments_and_results_without_invoking_them() {
    let source = r#"fn identity(value) { return(value) }
fn make() { return({|| return("never") }) }

Top::
 /x/ -> Done {
   state = "before";
   from_arg = identity({|value| state = "wrong"; return(value) });
   from_result = make();
   return({ "state" : state, "from_arg" : from_arg, "from_result" : from_result })
 }

Done::
 /x/
"#;
    let actual = Engine::new(compile_source(source))
        .execute("xx")
        .expect("preserve callable values through user functions");
    assert_eq!(actual[0]["state"], "before");
    assert_eq!(actual[0]["from_arg"]["kind"], "codeblock_literal");
    assert_eq!(actual[0]["from_result"]["kind"], "codeblock_literal");
    assert_eq!(
        actual[0]["from_arg"]["signature"]["positional_params"],
        json!(["value"])
    );
    assert_eq!(
        actual[0]["from_result"]["signature"]["positional_params"],
        json!([])
    );
}

#[test]
fn retained_body_dependencies_do_not_pre_dispatch_an_action_edge_child() {
    let source = r#"Top:: I { state = "before" }
 /x/ -> Done {
   cb = {|| call(Done); return(retv) };
   return({ "state" : state, "cb" : cb })
 }

Done:
 /y/ I { state = "child" }
 E { return("done") }
"#;
    let actual = Engine::new(compile_source(source))
        .execute("xy")
        .expect("construct inert codeblock on action edge");
    assert_eq!(actual[0]["state"], "before");
    assert_eq!(actual[0]["cb"]["kind"], "codeblock_literal");
}

fn final_codeblock_equivalence_source() -> &'static str {
    r#"fn apply(value, callback: codeblock) { return(callback()) }
fn invoke(value, callback: codeblock) { return(callback(value)) }

Top::
 /x/
 E {
   return([
     with("x") { return(cat(value, "!")) },
     with("x", { return(cat(value, "!")) }),
     with("x", {|item| return(cat(item, "!")) }),
     "x".with() { return(cat(value, "!")) },
     "x".with({ return(cat(value, "!")) }),
     "x".with({|item| return(cat(item, "!")) }),
     apply("a") { return(cat(value, "!")) },
     apply("b", { return(cat(value, "?")) }),
     invoke("c", {|item| return(cat(item, ".")) }),
     { "b" : 2, "a" : 1 }.map_leaves() { return(cat(value, "!")) },
     { "b" : 2, "a" : 1 }.map_leaves({ return(cat(value, "!")) })
   ])
 }
"#
}

fn final_codeblock_direct_expected() -> Value {
    json!(["x!", "x!", "x!", "x!", "x!", "x!", "a!", "b?", "c.", {
        "a": "1!", "b": "2!"
    }, {
        "a": "1!", "b": "2!"
    }])
}

fn final_codeblock_accumulator_expected() -> Value {
    json!([final_codeblock_direct_expected()])
}

#[test]
fn typed_definition_and_contextual_ast_are_metadata_owned() {
    let compiled = compile_source(final_codeblock_equivalence_source());
    let descriptor = serde_json::to_value(compiled.descriptor_state()).unwrap();
    let apply = &descriptor["functions"]["apply"];
    assert_eq!(apply["version"], 3);
    assert_eq!(apply["params"], json!(["value", "callback"]));
    assert_eq!(apply["arity"], 2);
    assert_eq!(apply["parameter_kinds"], json!({"callback": "codeblock"}));
    assert_eq!(
        apply["body_payload"]["parameter_kinds"],
        json!({"callback": "codeblock"})
    );
    assert_eq!(
        apply["body_parse_job"]["parameter_kinds"],
        json!({"callback": "codeblock"})
    );

    let block = compiled.rules[0].ecode.as_ref().unwrap();
    let Expr::Call { name, args } = &block.statements[0].expr else {
        panic!("expected return call");
    };
    assert_eq!(name, "return");
    let Expr::ArrayLiteral { items } = args[0].value() else {
        panic!("expected returned array");
    };
    for (attached_index, parenthesized_index) in [(0, 1), (3, 4), (9, 10)] {
        let attached = serde_json::to_value(&items[attached_index]).unwrap();
        let parenthesized = serde_json::to_value(&items[parenthesized_index]).unwrap();
        let attached_argument = final_argument(&attached);
        let parenthesized_argument = final_argument(&parenthesized);
        for field in ["kind", "version", "signature", "body_source", "body_ast"] {
            assert_eq!(
                attached_argument[field], parenthesized_argument[field],
                "field {field} for pair {attached_index}/{parenthesized_index}"
            );
        }
        assert_eq!(attached_argument["kind"], "codeblock_argument");
        assert_eq!(
            attached_argument["signature"]["positional_params"],
            json!([])
        );
        assert_eq!(attached_argument["signature"]["max_arity"], 0);
    }
    let user_attached_value = serde_json::to_value(&items[6]).unwrap();
    let user_parenthesized_value = serde_json::to_value(&items[7]).unwrap();
    let user_attached = final_argument(&user_attached_value);
    let user_parenthesized = final_argument(&user_parenthesized_value);
    assert_eq!(user_attached["kind"], "codeblock_argument");
    assert_eq!(user_parenthesized["kind"], "codeblock_argument");
    assert_eq!(
        final_argument(&serde_json::to_value(&items[2]).unwrap())["kind"],
        "codeblock_literal"
    );
    assert!(
        !serde_json::to_string(&compiled)
            .unwrap()
            .contains("contextual_codeblock_candidate")
    );

    let index = SemanticIndex::from_utf8(
        final_codeblock_equivalence_source().as_bytes(),
        SemanticIndexOptions::new("final-codeblock.spec", SemanticSourceDetail::None),
    )
    .unwrap();
    let response = index.query_neutral(&json!({
        "contract": "linkedspec-semantic-query-v1",
        "operation": "list",
        "subjects": [],
        "record_kinds": ["function"],
        "relation_kinds": [],
        "direction": "outgoing",
        "page": {"after_id": null, "limit": 100},
        "budget": {"max_records": 1000, "max_relations": 2000, "max_depth": 4},
        "source": {"detail": "none", "include_content_digest": false}
    }));
    assert!(response.ok, "{:?}", response.diagnostics);
    let function = response
        .records
        .iter()
        .find(|record| record.name.as_deref() == Some("apply"))
        .unwrap();
    assert_eq!(
        function.facts["parameter_kinds"],
        json!(["value", "codeblock"])
    );
    assert_eq!(function.facts["signature"]["final_codeblock"], true);
}

fn final_argument(expression: &Value) -> &Value {
    if expression["kind"] == "call" {
        return expression["args"].as_array().unwrap().last().unwrap();
    }
    expression["calls"][0]["args"]
        .as_array()
        .unwrap()
        .last()
        .unwrap()
}

#[test]
fn contextual_forms_execute_in_native_reconstructed_and_generated_paths() {
    let compiled = compile_source(final_codeblock_equivalence_source());
    let expected = final_codeblock_accumulator_expected();
    assert_eq!(
        Engine::new(compiled.clone()).execute("x").unwrap(),
        expected
    );
    let encoded = serde_json::to_string(&compiled).unwrap();
    let reconstructed: CompiledSpec = serde_json::from_str(&encoded).unwrap();
    assert_eq!(Engine::new(reconstructed).execute("x").unwrap(), expected);
    assert_eq!(
        execute_generated_parser(&encoded, &generated_plan(&compiled), "x").unwrap(),
        expected
    );
}

#[test]
fn metadata_normalization_preserves_ordinary_eager_blocks() {
    let source = r#"fn choose(first, second) { return(first) }

Top::
 /x/
 E { return(choose({ value = "eager"; return(value) }, "ignored")) }
"#;
    let compiled = compile_source(source);
    let encoded = serde_json::to_string(&compiled).unwrap();
    assert!(!encoded.contains("contextual_codeblock_candidate"));
    assert!(encoded.contains("block_value"));
    assert_eq!(
        Engine::new(compiled).execute("x").unwrap(),
        json!(["eager"])
    );

    let unknown_attached = r#"Top::
 /x/
 E { return(custom("x") { return(value) }) }
"#;
    let parsed = parse_spec_with_user_functions(unknown_attached).unwrap();
    validate(&parsed).unwrap();
    let error = compile(&parsed).unwrap_err().to_string();
    assert!(error.contains("callable_contract_rejected"), "{error}");
    assert!(error.contains("custom"), "{error}");
}

#[test]
fn invalid_typed_declarations_and_final_values_keep_neutral_codes() {
    for case in contract()["final_codeblock_parameter_declaration"]["invalid"]
        .as_array()
        .unwrap()
    {
        let source = format!(
            "Top::\n /x/\n\nfn invalid({}) {{ return(undef) }}\n",
            case["source"].as_str().unwrap()
        );
        let error = parse_spec_with_user_functions(&source).unwrap_err();
        assert!(
            error.contains(case["expected_code"].as_str().unwrap()),
            "{}: {error}",
            case["id"]
        );
    }

    for (name, expression) in [
        ("typed_function", "apply(\"x\", { \"value\" : value })"),
        ("helper", "with(\"x\", { \"value\" : value })"),
        ("receiver", "\"x\".with({ \"value\" : value })"),
    ] {
        let source = format!(
            "fn apply(value, callback: codeblock) {{ return(callback()) }}\n\nTop::\n /x/\n E {{ return({expression}) }}\n"
        );
        let error = Engine::new(compile_source(&source))
            .execute_with_diagnostics("x")
            .unwrap_err();
        assert_eq!(
            error.diagnostic().code.as_deref(),
            Some("final_argument_not_codeblock"),
            "{name}"
        );
        assert_eq!(
            error.diagnostic().value_kind.as_deref(),
            Some("harray"),
            "{name}"
        );
    }
}

#[test]
fn standalone_emitted_source_executes_contextual_equivalence() {
    let compiled = compile_source(final_codeblock_equivalence_source());
    let emitted = emit_rust_source_v2(&compiled, "callable-codeblock/final-equivalence.spec")
        .expect("emit final-codeblock equivalence");
    let expected_literal = format!(
        "{:?}",
        serde_json::to_string(&final_codeblock_direct_expected()).unwrap()
    );
    let module = format!(
        r#"{emitted}

#[cfg(test)]
mod emitted_final_codeblock_tests {{
    #[test]
    fn contextual_equivalence_is_exact() {{
        let expected: serde_json::Value = serde_json::from_str({expected_literal}).unwrap();
        assert_eq!(super::execute("x").unwrap(), expected);
    }}
}}
"#
    );
    let project = GeneratedTestProject::new();
    fs::write(
        project.root.join("Cargo.toml"),
        r#"[package]
name = "linkedspec_final_codeblock_emitted"
version = "0.0.0"
edition = "2024"

[dependencies]
linkedspec-runtime = { path = "../../../linkedspec-runtime" }
serde_json = "1"

[workspace]
"#,
    )
    .unwrap();
    fs::write(project.root.join("src/lib.rs"), module).unwrap();
    let output = Command::new("cargo")
        .arg("test")
        .arg("--offline")
        .arg("--quiet")
        .env("CARGO_TARGET_DIR", project.root.join("target"))
        .current_dir(&project.root)
        .output()
        .unwrap();
    assert!(
        output.status.success(),
        "standalone final-codeblock test failed\nstdout:\n{}\nstderr:\n{}",
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
}

#[test]
fn semantic_binding_descriptor_retains_the_callable_signature() {
    let source = b"fn make() { cb = {|left, ...items| return(left) }; return(cb) }\n\nTop::\n /x/ E { return(make()) }\n";
    let index = SemanticIndex::from_utf8(
        source,
        SemanticIndexOptions::new("callable-codeblock.spec", SemanticSourceDetail::None),
    )
    .expect("construct semantic codeblock descriptor");
    assert!(
        index.compiled_authority_present(),
        "semantic compilation failed: {:?}",
        index.compilation_diagnostic()
    );
    let response = index.query_neutral(&json!({
        "contract": "linkedspec-semantic-query-v1",
        "operation": "list",
        "subjects": [],
        "record_kinds": ["binding"],
        "relation_kinds": [],
        "direction": "outgoing",
        "page": {"after_id": null, "limit": 100},
        "budget": {"max_records": 1000, "max_relations": 2000, "max_depth": 4},
        "source": {"detail": "none", "include_content_digest": false}
    }));
    assert!(
        response.ok,
        "semantic query diagnostics: {:?}",
        response.diagnostics
    );
    let binding = response
        .records
        .iter()
        .find(|record| record.name.as_deref() == Some("cb"))
        .unwrap_or_else(|| panic!("codeblock binding record: {:?}", response.records));
    assert_eq!(binding.facts["value_shape"]["kind"], "codeblock");
    assert_eq!(
        binding.facts["value_shape"]["signature"],
        json!({
            "parameters": [{"name": "left", "kind": "value", "required": true}],
            "arity_min": 1,
            "arity_max": null,
            "rest_parameter": "items",
            "final_codeblock": false
        })
    );
}
