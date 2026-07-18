//! FUTURE-PARITY-BACKLOG.9.1.1.2.2.2 — composed Rust root-selection routes.

use linkedspec_core::compiler::compile;
use linkedspec_core::entry_rule::ENTRY_RULE_CONTRACT_ID;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedDiagnosticOutputExecutionError, GeneratedPlanRow,
    GeneratedSourceCode, GeneratedSourceStage, execute_generated_parser_v2,
    execute_generated_parser_v2_with_options,
    execute_generated_parser_with_diagnostic_output_and_options,
    execute_generated_parser_with_diagnostic_output_v2_with_options,
    execute_generated_parser_with_options,
    execute_generated_parser_with_trace_and_diagnostic_output_and_options,
    execute_generated_parser_with_trace_and_diagnostic_output_v2_with_options,
    execute_generated_parser_with_trace_and_options,
    execute_generated_parser_with_trace_v2_with_options,
};
use linkedspec_runtime::spec_loader::{SpecLoadOptions, SpecRequest, load_and_compile_spec};
use serde_json::{Value, json};
use std::fs;
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

const IDENTITY: &str = "root-selection/rust-routes.spec";

const MARKED_SOURCE: &str = r#"Earlier:
 /x/
 E { return("earlier") }

Marked::
 /x/
 E { return("marked") }

Later::
 /x/
 E { return("later") }
"#;

const MARKERLESS_SOURCE: &str = r#"First:
 /x/
 E { return("first") }

Second:
 /x/
 E { return("second") }
"#;

const MARKED_PLAN: &[GeneratedPlanRow] = &[
    GeneratedPlanRow {
        label: "Earlier",
        family: "default",
    },
    GeneratedPlanRow {
        label: "Marked",
        family: "default",
    },
    GeneratedPlanRow {
        label: "Later",
        family: "default",
    },
];

const MARKERLESS_PLAN: &[GeneratedPlanRow] = &[
    GeneratedPlanRow {
        label: "First",
        family: "default",
    },
    GeneratedPlanRow {
        label: "Second",
        family: "default",
    },
];

struct ScratchDirectory {
    path: PathBuf,
}

impl ScratchDirectory {
    fn new(label: &str) -> Self {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("clock after Unix epoch")
            .as_nanos();
        let path = std::env::temp_dir().join(format!(
            "linkedspec-rust-root-routes-{label}-{}-{nanos}",
            std::process::id()
        ));
        fs::create_dir_all(&path).expect("create root-route scratch directory");
        Self { path }
    }

    fn path(&self) -> &Path {
        &self.path
    }
}

impl Drop for ScratchDirectory {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.path);
    }
}

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec(source).expect("root-route fixture parses");
    validate(&parsed).expect("root-route fixture validates");
    compile(&parsed).expect("root-route fixture compiles")
}

fn compiled_json(source: &str) -> String {
    serde_json::to_string(&compile_source(source)).expect("serialize root-route fixture")
}

fn explicit(label: &str) -> ExecutionOptions {
    ExecutionOptions::new().with_entry_rule(label)
}

#[test]
fn loaded_serialized_and_reconstructed_state_share_ordered_selection() {
    let compiled = compile_source(MARKED_SOURCE);
    let descriptor_before = compiled
        .to_descriptor_json()
        .expect("project direct descriptor");
    let encoded = serde_json::to_string(&compiled).expect("serialize compiled root-route state");
    let reconstructed: CompiledSpec =
        serde_json::from_str(&encoded).expect("reconstruct compiled root-route state");
    let descriptor_after = reconstructed
        .to_descriptor_json()
        .expect("project reconstructed descriptor");
    assert_eq!(descriptor_after, descriptor_before);
    assert_eq!(
        descriptor_after["meta"]["entry_rule_contract"],
        ENTRY_RULE_CONTRACT_ID
    );
    assert_eq!(
        descriptor_after["meta"]["definition_order"],
        json!(["Earlier", "Marked", "Later"])
    );
    assert_eq!(descriptor_after["spec"]["Earlier"]["meta"]["is_top"], false);
    assert_eq!(descriptor_after["spec"]["Marked"]["meta"]["is_top"], true);
    assert_eq!(descriptor_after["spec"]["Later"]["meta"]["is_top"], true);

    let engine = Engine::new(reconstructed);
    assert_eq!(
        engine
            .execute_value("x", &ExecutionOptions::new())
            .expect("reconstructed default execution"),
        json!("marked")
    );
    assert_eq!(
        engine
            .execute_value("x", &explicit("Earlier"))
            .expect("reconstructed explicit execution"),
        json!("earlier")
    );

    let scratch = ScratchDirectory::new("loaded");
    let path = scratch.path().join("marked.spec");
    fs::write(&path, MARKED_SOURCE).expect("write loaded root-route fixture");
    let loaded = load_and_compile_spec(
        &SpecRequest::path(path.to_string_lossy().into_owned()),
        &SpecLoadOptions::new(scratch.path()),
    )
    .expect("load root-route fixture");
    assert_eq!(
        loaded
            .into_engine()
            .execute_value("x", &explicit("Later"))
            .expect("loaded explicit execution"),
        json!("later")
    );
}

#[test]
fn generated_defaults_select_first_marker_then_first_rule() {
    let marked_json = compiled_json(MARKED_SOURCE);
    assert_eq!(
        execute_generated_parser_v2(
            &marked_json,
            MARKED_PLAN,
            "x",
            IDENTITY,
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("typed marked default"),
        json!("marked")
    );

    let markerless_json = compiled_json(MARKERLESS_SOURCE);
    assert_eq!(
        execute_generated_parser_v2(
            &markerless_json,
            MARKERLESS_PLAN,
            "x",
            IDENTITY,
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("typed markerless default"),
        json!("first")
    );
    assert_eq!(
        linkedspec_runtime::source_emitter::execute_generated_parser(
            &markerless_json,
            MARKERLESS_PLAN,
            "x",
        )
        .expect("compatibility markerless default"),
        json!(["first"])
    );
}

#[test]
fn every_generated_direct_and_compatibility_role_accepts_invocation_options() {
    let marked_json = compiled_json(MARKED_SOURCE);
    let options = explicit("Earlier");
    let direct = json!("earlier");
    let compatibility = json!(["earlier"]);

    assert_eq!(
        execute_generated_parser_v2_with_options(
            &marked_json,
            MARKED_PLAN,
            "x",
            IDENTITY,
            GENERATED_SOURCE_CONTRACT,
            &options,
        )
        .expect("typed direct options"),
        direct
    );
    assert_eq!(
        execute_generated_parser_with_diagnostic_output_v2_with_options(
            &marked_json,
            MARKED_PLAN,
            "x",
            IDENTITY,
            GENERATED_SOURCE_CONTRACT,
            None,
            &options,
        )
        .expect("typed diagnostic options"),
        direct
    );
    assert_eq!(
        execute_generated_parser_with_trace_v2_with_options(
            &marked_json,
            MARKED_PLAN,
            "x",
            TraceConfig::disabled(),
            IDENTITY,
            GENERATED_SOURCE_CONTRACT,
            &options,
        )
        .expect("typed trace options"),
        direct
    );
    assert_eq!(
        execute_generated_parser_with_trace_and_diagnostic_output_v2_with_options(
            &marked_json,
            MARKED_PLAN,
            "x",
            TraceConfig::disabled(),
            IDENTITY,
            GENERATED_SOURCE_CONTRACT,
            None,
            &options,
        )
        .expect("typed trace diagnostic options"),
        direct
    );

    assert_eq!(
        execute_generated_parser_with_options(&marked_json, MARKED_PLAN, "x", &options)
            .expect("compatibility direct options"),
        compatibility
    );
    assert_eq!(
        execute_generated_parser_with_diagnostic_output_and_options(
            &marked_json,
            MARKED_PLAN,
            "x",
            None,
            &options,
        )
        .expect("compatibility diagnostic options"),
        compatibility
    );
    assert_eq!(
        execute_generated_parser_with_trace_and_options(
            &marked_json,
            MARKED_PLAN,
            "x",
            TraceConfig::disabled(),
            &options,
        )
        .expect("compatibility trace options"),
        compatibility
    );
    assert_eq!(
        execute_generated_parser_with_trace_and_diagnostic_output_and_options(
            &marked_json,
            MARKED_PLAN,
            "x",
            TraceConfig::disabled(),
            None,
            &options,
        )
        .expect("compatibility trace diagnostic options"),
        compatibility
    );
}

#[test]
fn generated_selection_failures_are_portable_and_stale_contracts_fail_first() {
    let marked_json = compiled_json(MARKED_SOURCE);
    let missing = explicit("Missing");
    let error = execute_generated_parser_v2_with_options(
        &marked_json,
        MARKED_PLAN,
        "x",
        IDENTITY,
        GENERATED_SOURCE_CONTRACT,
        &missing,
    )
    .expect_err("typed unknown selector must fail");
    assert_eq!(error.stage, GeneratedSourceStage::SelectEntryRule);
    assert_eq!(error.code, GeneratedSourceCode::EntryRuleNotFound);
    assert_eq!(error.entry_rule.as_deref(), Some("Missing"));
    assert_eq!(error.rule_label, None);
    assert_eq!(error.source_identity, IDENTITY);
    assert_eq!(
        error.detail.as_deref(),
        Some("entry rule 'Missing' is not defined")
    );

    let typed_diagnostic = execute_generated_parser_with_diagnostic_output_v2_with_options(
        &marked_json,
        MARKED_PLAN,
        "x",
        IDENTITY,
        GENERATED_SOURCE_CONTRACT,
        None,
        &missing,
    )
    .expect_err("typed diagnostic unknown selector must fail");
    match typed_diagnostic {
        GeneratedDiagnosticOutputExecutionError::GeneratedSource(error) => {
            assert_eq!(error.stage, GeneratedSourceStage::SelectEntryRule);
            assert_eq!(error.code, GeneratedSourceCode::EntryRuleNotFound);
            assert_eq!(error.entry_rule.as_deref(), Some("Missing"));
        }
        other => panic!("unexpected typed diagnostic outcome: {other:?}"),
    }

    let compatibility =
        execute_generated_parser_with_options(&marked_json, MARKED_PLAN, "x", &missing)
            .expect_err("compatibility unknown selector must fail");
    assert_eq!(compatibility, "entry rule 'Missing' is not defined");

    let diagnostic = execute_generated_parser_with_diagnostic_output_and_options(
        &marked_json,
        MARKED_PLAN,
        "x",
        None,
        &missing,
    )
    .expect_err("diagnostic compatibility unknown selector must fail");
    match diagnostic {
        GeneratedDiagnosticOutputExecutionError::Compatibility(message) => {
            assert_eq!(message, "entry rule 'Missing' is not defined");
        }
        other => panic!("unexpected compatibility diagnostic outcome: {other:?}"),
    }

    let stale = execute_generated_parser_v2_with_options(
        &marked_json,
        MARKED_PLAN,
        "x",
        IDENTITY,
        "linkedspec-generated-source-v1",
        &missing,
    )
    .expect_err("stale generated contract must fail before selection");
    assert_eq!(stale.stage, GeneratedSourceStage::ValidateGeneratedPlan);
    assert_eq!(
        stale.code,
        GeneratedSourceCode::GeneratedSourceContractVersionMismatch
    );

    let empty = serde_json::to_string(&CompiledSpec {
        functions: Vec::new(),
        rules: Vec::new(),
    })
    .expect("serialize empty compiled state");
    let zero = execute_generated_parser_v2_with_options(
        &empty,
        &[],
        "",
        IDENTITY,
        GENERATED_SOURCE_CONTRACT,
        &missing,
    )
    .expect_err("zero-rule validation must win over selector lookup");
    assert_eq!(zero.stage, GeneratedSourceStage::ValidateSpec);
    assert_eq!(zero.code, GeneratedSourceCode::NoRulesDefined);
    assert_eq!(zero.entry_rule, None);
}

#[test]
fn generated_trace_and_execution_failure_use_the_effective_rule() {
    let scratch = ScratchDirectory::new("trace");
    let trace_path = scratch.path().join("selection.trace");
    let marked_json = compiled_json(MARKED_SOURCE);
    let options = explicit("Earlier");
    assert_eq!(
        execute_generated_parser_with_trace_v2_with_options(
            &marked_json,
            MARKED_PLAN,
            "x",
            TraceConfig::enabled(TraceLevel::DEBUG)
                .with_trace_file(trace_path.clone())
                .with_reset_file(true),
            IDENTITY,
            GENERATED_SOURCE_CONTRACT,
            &options,
        )
        .expect("traced explicit generated execution"),
        json!("earlier")
    );
    let trace = fs::read_to_string(&trace_path).expect("read generated selection trace");
    assert!(trace.contains("rust_runtime:generated_plan:top_rule"));
    assert!(trace.contains("label=Earlier basis=explicit_selector"));
    assert!(trace.contains("rule=Earlier"));

    let failure_source = MARKED_SOURCE.replace("E { return(\"earlier\") }", "I { exit_now(17) }");
    let failure_json = compiled_json(&failure_source);
    let error = execute_generated_parser_v2_with_options(
        &failure_json,
        MARKED_PLAN,
        "x",
        IDENTITY,
        GENERATED_SOURCE_CONTRACT,
        &options,
    )
    .expect_err("selected rule runtime failure must retain effective context");
    assert_eq!(error.stage, GeneratedSourceStage::ExecuteGenerated);
    assert_eq!(error.code, GeneratedSourceCode::GeneratedExecutionFailed);
    assert_eq!(error.rule_label.as_deref(), Some("Earlier"));
    assert_eq!(error.handler_family.as_deref(), Some("default"));
    assert_eq!(error.detail.as_deref(), Some("exit_now(17)"));
}

#[test]
fn descriptor_source_identity_never_becomes_invocation_state() {
    let compiled = compile_source(MARKED_SOURCE);
    let before: Value = compiled
        .to_descriptor_json()
        .expect("project descriptor before selection");
    let engine = Engine::new(compiled.clone());
    engine
        .execute_value("x", &explicit("Earlier"))
        .expect("execute explicit ordinary rule");
    let after = compiled
        .to_descriptor_json()
        .expect("project descriptor after selection");
    assert_eq!(after, before);
    assert!(after["meta"].get("entry_rule").is_none());
    assert!(after["meta"].get("selected_entry_rule").is_none());
}
