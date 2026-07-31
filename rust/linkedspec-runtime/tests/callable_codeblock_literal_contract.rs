//! FUTURE-PARITY-BACKLOG.11.4.1 — inert Rust callable-codeblock state.

use std::collections::BTreeSet;

use linkedspec_core::compiler::compile;
use linkedspec_core::expr::{CodeBlock, Expr};
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::Engine;
use linkedspec_runtime::semantic_index::{
    SemanticIndex, SemanticIndexOptions, SemanticSourceDetail,
};
use linkedspec_runtime::source_emitter::{
    GeneratedPlanRow, classify_generated_rule_family, emit_rust_source, execute_generated_parser,
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
