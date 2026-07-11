use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use serde_json::json;

fn engine(source: &str) -> Engine {
    let spec = parse_spec(source).expect("parse diagnostic fixture");
    validate(&spec).expect("validate diagnostic fixture");
    Engine::new(compile(&spec).expect("compile diagnostic fixture"))
}

#[test]
fn exposes_exact_structured_runtime_failure_and_source_identity() {
    let engine = engine(
        r#"Top::
 /bye/
 I { exit_now(7) }
"#,
    )
    .with_spec_name("example")
    .with_spec_path("/specs/example.spec");

    let error = engine
        .execute_with_diagnostics("bye")
        .expect_err("exit_now must fail");
    assert_eq!(error.message(), "exit_now(7)");
    assert_eq!(error.to_string(), "exit_now(7)");
    assert_eq!(
        error.to_json().unwrap(),
        json!({
            "message": "exit_now(7)",
            "diagnostic": {
                "type": "runtime_parser",
                "stage": "runtime_execution",
                "owner_stage": "rust_runtime",
                "summary": "Rust runtime interpreter failed",
                "detail": "exit_now(7)",
                "spec_name": "example",
                "spec_path": "/specs/example.spec",
                "top_rule": "Top",
                "rule_label": "Top",
                "handler_source_label": "rust_runtime:rule:Top"
            }
        })
    );
    assert_eq!(engine.spec_name(), Some("example"));
    assert_eq!(engine.spec_path(), Some("/specs/example.spec"));
}

#[test]
fn preserves_deepest_child_rule_attribution_before_unwind() {
    let engine = engine(
        r#"Top::AND
 => Child

Child:
 /x/
 I { exit_now(9) }
"#,
    );

    let error = engine
        .execute_with_diagnostics("x")
        .expect_err("child exit_now must fail");
    let diagnostic = error.diagnostic();
    assert_eq!(diagnostic.top_rule.as_deref(), Some("Top"));
    assert_eq!(diagnostic.rule_label.as_deref(), Some("Child"));
    assert_eq!(
        diagnostic.handler_source_label.as_deref(),
        Some("rust_runtime:rule:Child")
    );
    assert_eq!(diagnostic.stage, "runtime_execution");
}

#[test]
fn attributes_missing_selected_entry_rule_without_string_scraping() {
    let engine = engine(
        r#"Top::
 /x/
 E { return("ok") }
"#,
    );
    let options = ExecutionOptions::new().with_entry_rule("Missing");

    let error = engine
        .execute_value_with_diagnostics("x", &options)
        .expect_err("missing selected entry must fail");
    assert_eq!(error.message(), "entry rule 'Missing' is not defined");
    assert_eq!(error.diagnostic.stage, "rule_lookup");
    assert_eq!(error.diagnostic.top_rule.as_deref(), Some("Missing"));
    assert_eq!(error.diagnostic.rule_label.as_deref(), Some("Missing"));
    assert_eq!(
        error.diagnostic.handler_source_label.as_deref(),
        Some("rust_runtime:rule:Missing")
    );
}

#[test]
fn reports_top_rule_selection_with_only_available_context() {
    let engine = Engine::new(CompiledSpec {
        functions: Vec::new(),
        rules: Vec::new(),
    });

    let error = engine
        .execute_with_diagnostics("")
        .expect_err("empty compiled state has no top rule");
    assert_eq!(error.message(), "no top rule in compiled spec");
    assert_eq!(error.diagnostic.stage, "top_rule_selection");
    assert_eq!(
        error.diagnostic.summary,
        "Rust runtime top-rule selection failed"
    );
    assert_eq!(error.diagnostic.top_rule, None);
    assert_eq!(error.diagnostic.rule_label, None);
    assert_eq!(
        error.diagnostic.handler_source_label.as_deref(),
        Some("rust_runtime")
    );
    let diagnostic_json = error.diagnostic.to_json().unwrap();
    assert!(diagnostic_json.get("spec_name").is_none());
    assert!(diagnostic_json.get("spec_path").is_none());
    assert!(diagnostic_json.get("top_rule").is_none());
    assert!(diagnostic_json.get("rule_label").is_none());
}

#[test]
fn preserves_success_values_and_legacy_string_errors() {
    let success = engine(
        r#"Top::
 /x/
 E { return("ok") }
"#,
    );
    assert_eq!(
        success.execute("x").unwrap(),
        success.execute_with_diagnostics("x").unwrap()
    );
    assert_eq!(
        success
            .execute_value("x", &ExecutionOptions::new())
            .unwrap(),
        success
            .execute_value_with_diagnostics("x", &ExecutionOptions::new())
            .unwrap()
    );

    let failure = engine(
        r#"Top::
 /bye/
 I { exit_now(3) }
"#,
    );
    let legacy = failure.execute("bye").expect_err("legacy error");
    let structured = failure
        .execute_with_diagnostics("bye")
        .expect_err("structured error");
    assert_eq!(legacy, structured.message());
}
