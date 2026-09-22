//! ADR0124: independently authored document values, atomic rejection and reuse.
use linkedspec_core::compiler::compile;
use linkedspec_core::validation::validate;
use linkedspec_runtime::RuntimeDiagnosticOutputExecutionError;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

const SOURCE: &str = include_str!("../../../specs/SExprDocumentV1.spec");
const CONTRACT: &str = include_str!("../../../tests/sexpr-document-v1/contract.json");

fn render_node(node: &Value) -> String {
    if node["kind"] == "list" {
        format!(
            "({})",
            node["items"]
                .as_array()
                .unwrap()
                .iter()
                .map(render_node)
                .collect::<Vec<_>>()
                .join(" ")
        )
    } else {
        node["lexeme"].as_str().unwrap().to_owned()
    }
}

#[test]
fn authored_document_contract_roundtrips_and_reuses_one_engine_after_rejection() {
    let contract: Value = serde_json::from_str(CONTRACT).unwrap();
    let cases = contract["cases"].as_array().unwrap();
    assert_eq!(cases.len(), 37);
    let reuse = cases
        .iter()
        .find(|case| case["id"] == "reuse_after_rejection")
        .unwrap();
    let parsed = parse_spec_with_user_functions(SOURCE).expect("parse shipped grammar");
    validate(&parsed).expect("validate shipped grammar");
    let engine = Engine::new(compile(&parsed).expect("compile shipped grammar"));
    let options = ExecutionOptions::new();

    for case in cases {
        let id = case["id"].as_str().unwrap();
        let result = engine.execute_value_with_diagnostic_output(
            case["input"].as_str().unwrap(),
            &options,
            None,
        );
        if case["outcome"] == "accept" {
            assert_eq!(
                result.unwrap_or_else(|error| panic!("{id}: {error}")),
                case["expected"],
                "{id}: authored tree"
            );
            let rendered = case["expected"]["forms"]
                .as_array()
                .unwrap()
                .iter()
                .map(render_node)
                .collect::<Vec<_>>()
                .join("\n");
            assert_eq!(
                engine.execute_value(&rendered, &options).unwrap(),
                case["expected"],
                "{id}: token spelling round trip"
            );
        } else {
            match result.expect_err(id) {
                RuntimeDiagnosticOutputExecutionError::Exit(exit) => {
                    assert_eq!(exit.status, 1, "{id}: rejection status")
                }
                other => panic!("{id}: expected typed rejection, got {other}"),
            }
            assert_eq!(
                engine
                    .execute_value(reuse["input"].as_str().unwrap(), &options)
                    .unwrap(),
                reuse["expected"],
                "{id}: independent input after rejection"
            );
        }
    }
}
