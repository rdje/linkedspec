//! FUTURE-PARITY-BACKLOG.16.3 — Rust punctuation-light zero-argument contract.

use linkedspec_core::compiler::compile;
use linkedspec_core::expr::{Arg, CodeBlock, Expr};
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GeneratedPlanRow, emit_rust_source_v1, execute_generated_parser_v1,
    validate_generated_parser_plan_v1,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

const CONTRACT_JSON: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../capability_conformance/punctuation_light_zero_arg_contract.json"
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
    serde_json::from_str(CONTRACT_JSON).expect("punctuation-light contract JSON")
}

fn parse_statement(source: &str) -> Expr {
    let mut block = CodeBlock::parse(source)
        .unwrap_or_else(|error| panic!("parse punctuation-light statement {source:?}: {error}"));
    assert_eq!(block.statements.len(), 1, "single statement: {source}");
    block.statements.remove(0).expr
}

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse punctuation-light fixture");
    validate(&parsed).expect("validate punctuation-light fixture");
    compile(&parsed).expect("compile punctuation-light fixture")
}

fn action_source(action: &str) -> String {
    format!("Top::\n /x/ -> Done {{ values = [\"a\", \"b\"]; {action} }}\nDone::\n /x/\n")
}

#[test]
fn standalone_aliases_share_the_parenthesized_typed_ast() {
    let contract = contract();
    assert_eq!(
        contract["contract_id"],
        "linkedspec-punctuation-light-zero-arg-v1"
    );

    for case in contract["standalone_cases"]
        .as_array()
        .expect("standalone cases")
    {
        let bare = case["bare"].as_str().expect("bare statement");
        let parenthesized = case["parenthesized"]
            .as_str()
            .expect("parenthesized statement");
        let bare_ast = parse_statement(bare);
        assert_eq!(bare_ast, parse_statement(parenthesized), "{}", case["id"]);
        assert!(
            matches!(&bare_ast, Expr::Call { name, args } if name == bare && args.is_empty()),
            "{}: {bare_ast:?}",
            case["id"]
        );
    }

    let value_next = parse_statement("return(next)");
    let Expr::Call { args, .. } = value_next else {
        panic!("return(next) must remain a call");
    };
    assert!(matches!(
        args.first(),
        Some(Arg::Positional(Expr::Variable { name })) if name == "next"
    ));
}

#[test]
fn terminal_receiver_aliases_share_the_parenthesized_typed_ast() {
    for case in contract()["receiver_cases"]
        .as_array()
        .expect("receiver cases")
    {
        let bare = case["bare"].as_str().expect("bare receiver");
        let parenthesized = case["parenthesized"]
            .as_str()
            .expect("parenthesized receiver");
        let bare_ast = parse_statement(bare);
        assert_eq!(bare_ast, parse_statement(parenthesized), "{}", case["id"]);
        assert!(
            matches!(bare_ast, Expr::FluentChain { .. }),
            "{}",
            case["id"]
        );
    }
}

#[test]
fn retained_identifiers_and_excluded_syntax_do_not_broaden() {
    let contract = contract();
    for case in contract["retained_noncall_cases"]
        .as_array()
        .expect("retained non-call cases")
    {
        let source = case["source"].as_str().expect("retained source");
        assert!(
            matches!(parse_statement(source), Expr::Variable { name } if name == source),
            "{}",
            case["id"]
        );
    }

    for case in contract["invalid_syntax_cases"]
        .as_array()
        .expect("invalid syntax cases")
    {
        let source = case["source"].as_str().expect("invalid source");
        let error = match CodeBlock::parse(source) {
            Ok(ast) => panic!("invalid syntax unexpectedly parsed: {source}: {ast:?}"),
            Err(error) => error,
        };
        let expected_fragment = match case["id"].as_str().expect("invalid case id") {
            "intermediate_generic_receiver" | "receiver_trailing_block_without_call" => {
                "expected '(' after fluent method"
            }
            _ => "expected ';' or newline between statements",
        };
        assert!(error.contains(expected_fragment), "{}: {error}", case["id"]);
    }
}

#[test]
fn terminal_alias_preserves_existing_rust_method_resolution() {
    let contract = contract();
    let required_argument_case = contract["method_contract_cases"]
        .as_array()
        .expect("method contract cases")
        .iter()
        .find(|case| case["id"] == "nonzero_arg_method")
        .expect("required-argument method case");
    assert_eq!(
        required_argument_case["expected_resolution"],
        "same_rejection_as_parenthesized"
    );

    let accepted = action_source("return(values.count)");
    assert_eq!(
        Engine::new(compile_source(&accepted))
            .execute_value("xx", &ExecutionOptions::new())
            .expect("terminal count alias"),
        Value::from(2)
    );

    let bare = action_source("return(values.contains)");
    let parenthesized = action_source("return(values.contains())");
    let bare_value = Engine::new(compile_source(&bare))
        .execute_value("xx", &ExecutionOptions::new())
        .expect("bare contains retains authoritative zero-argument behavior");
    let parenthesized_value = Engine::new(compile_source(&parenthesized))
        .execute_value("xx", &ExecutionOptions::new())
        .expect("parenthesized contains retains authoritative zero-argument behavior");
    assert_eq!(bare_value, parenthesized_value);
    // Rust already defaults the absent contains needle to empty text instead
    // of enforcing the Perl-reference arity. FUTURE-PARITY-BACKLOG.5 owns
    // that pre-existing helper drift; this syntax leaf must preserve it.
    assert_eq!(bare_value, Value::from(0));
}

#[test]
fn neutral_fixture_matches_the_perl_oracle_natively_serialized_and_generated() {
    let fixture = &contract()["future_fixture"];
    let source = fixture["spec_source"]
        .as_str()
        .expect("future fixture source");
    let input = fixture["input"].as_str().expect("future fixture input");
    let expected = fixture["expected"].clone();
    let compiled = compile_source(source);

    assert_eq!(
        Engine::new(compiled.clone())
            .execute_value(input, &ExecutionOptions::new())
            .expect("native punctuation-light fixture"),
        expected
    );

    let compiled_json = serde_json::to_string(&compiled).expect("serialize compiled fixture");
    let decoded: CompiledSpec =
        serde_json::from_str(&compiled_json).expect("deserialize compiled fixture");
    assert_eq!(
        Engine::new(decoded)
            .execute_value(input, &ExecutionOptions::new())
            .expect("serialized punctuation-light fixture"),
        expected
    );

    let identity = "punctuation-light-zero-arg.spec";
    let generated = emit_rust_source_v1(&compiled, identity).expect("emit generated Rust source");
    assert!(generated.contains("linkedspec-generated-source-v1"));
    validate_generated_parser_plan_v1(&compiled_json, TOP_DONE_PLAN, identity)
        .expect("validate punctuation-light generated plan");
    assert_eq!(
        execute_generated_parser_v1(&compiled_json, TOP_DONE_PLAN, input, identity)
            .expect("execute punctuation-light generated parser"),
        expected
    );
}
