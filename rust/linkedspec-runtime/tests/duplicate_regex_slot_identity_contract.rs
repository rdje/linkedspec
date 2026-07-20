//! FUTURE-PARITY-BACKLOG.9.1.8.1.3 — Rust duplicate regex-slot admission.

use linkedspec_core::compiler::compile;
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions, assert_ordered_regex_slot_identity};
use linkedspec_runtime::primary_cli::run_with_context;
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, GeneratedSourceCode, GeneratedSourceStage,
    emit_rust_source_v2, execute_generated_parser_v2, execute_generated_parser_with_trace_v2,
    validate_generated_parser_plan_v2,
};
use linkedspec_runtime::spec_loader::{SpecLoadOptions, SpecRequest, load_and_compile_spec};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;
use std::collections::{BTreeMap, BTreeSet};
use std::ffi::OsString;
use std::fs;
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

const CONTRACT_SOURCE: &str =
    include_str!("../../../capability_conformance/duplicate_regex_slot_identity_contract.json");
const CONTRACT_ID: &str = "linkedspec-duplicate-regex-slot-identity-v1";
const GENERATED_IDENTITY: &str = "duplicate-regex-slot/rust-admission.spec";
const ORDERED_PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
    label: "Top",
    family: "and_acode_seq",
}];

type AdmissionRole = fn(&Value);

struct ScratchDirectory {
    path: PathBuf,
}

impl ScratchDirectory {
    fn new(label: &str) -> Self {
        let nonce = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("clock after Unix epoch")
            .as_nanos();
        let path = std::env::temp_dir().join(format!(
            "linkedspec-rust-duplicate-slot-{label}-{}-{nonce}",
            std::process::id()
        ));
        fs::create_dir_all(&path).expect("create duplicate-slot scratch directory");
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

fn contract() -> Value {
    serde_json::from_str(CONTRACT_SOURCE).expect("duplicate regex-slot contract JSON")
}

fn fixture<'a>(contract: &'a Value, id: &str) -> &'a Value {
    contract["fixtures"]
        .as_array()
        .expect("fixture array")
        .iter()
        .find(|row| row["id"] == id)
        .unwrap_or_else(|| panic!("missing duplicate-slot fixture {id}"))
}

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse duplicate-slot fixture");
    validate(&parsed).expect("validate duplicate-slot fixture");
    compile(&parsed).expect("compile duplicate-slot fixture")
}

fn execute_fixture(row: &Value) -> Value {
    Engine::new(compile_source(
        row["source"].as_str().expect("fixture source"),
    ))
    .execute_value(
        row["input"].as_str().expect("fixture input"),
        &ExecutionOptions::new(),
    )
    .expect("execute duplicate-slot fixture")
}

fn compiled_json(row: &Value) -> String {
    serde_json::to_string(&compile_source(
        row["source"].as_str().expect("fixture source"),
    ))
    .expect("serialize duplicate-slot fixture")
}

fn os_arguments(arguments: &[&str]) -> Vec<OsString> {
    arguments.iter().map(OsString::from).collect()
}

fn role_neutral_fixtures(contract: &Value) {
    assert_eq!(contract["contract_id"], CONTRACT_ID);
    assert_eq!(
        contract["identity"]["required_fields"],
        serde_json::json!(["target_rule", "regex_index"])
    );
    assert_eq!(
        contract["fixtures"]
            .as_array()
            .expect("fixture array")
            .iter()
            .map(|row| row["id"].as_str().expect("fixture id"))
            .collect::<Vec<_>>(),
        [
            "ordered_same_rule_duplicate",
            "choice_same_rule_duplicate",
            "repeated_ordered_duplicate",
            "repeated_non_duplicate_control",
            "ordered_cross_target_duplicate",
        ]
    );
}

fn role_native_ordered(contract: &Value) {
    let row = fixture(contract, "ordered_same_rule_duplicate");
    assert_eq!(execute_fixture(row), row["expected_result"]);
}

fn role_native_choice(contract: &Value) {
    let row = fixture(contract, "choice_same_rule_duplicate");
    assert_eq!(execute_fixture(row), row["expected_result"]);
}

fn role_repeated_ordered(contract: &Value) {
    let row = fixture(contract, "repeated_ordered_duplicate");
    assert_eq!(execute_fixture(row), row["expected_result"]);
}

fn role_repeated_control(contract: &Value) {
    let row = fixture(contract, "repeated_non_duplicate_control");
    assert_eq!(execute_fixture(row), row["expected_result"]);
}

fn role_cross_target(contract: &Value) {
    let row = fixture(contract, "ordered_cross_target_duplicate");
    assert_eq!(execute_fixture(row), row["expected_result"]);
}

fn role_loaded(contract: &Value) {
    let row = fixture(contract, "ordered_same_rule_duplicate");
    let scratch = ScratchDirectory::new("loaded");
    let path = scratch.path().join("duplicate.spec");
    fs::write(&path, row["source"].as_str().expect("fixture source"))
        .expect("write duplicate-slot spec");
    let loaded = load_and_compile_spec(
        &SpecRequest::path(path.to_string_lossy().into_owned()),
        &SpecLoadOptions::new(scratch.path()),
    )
    .expect("load duplicate-slot spec");
    assert_eq!(
        loaded
            .into_engine()
            .execute_value(
                row["input"].as_str().expect("fixture input"),
                &ExecutionOptions::new(),
            )
            .expect("execute loaded duplicate-slot spec"),
        row["expected_result"]
    );
}

fn role_reconstructed(contract: &Value) {
    let row = fixture(contract, "ordered_same_rule_duplicate");
    let reconstructed: CompiledSpec =
        serde_json::from_str(&compiled_json(row)).expect("reconstruct duplicate-slot spec");
    assert_eq!(
        Engine::new(reconstructed)
            .execute_value(
                row["input"].as_str().expect("fixture input"),
                &ExecutionOptions::new(),
            )
            .expect("execute reconstructed duplicate-slot spec"),
        row["expected_result"]
    );
}

fn role_descriptor(contract: &Value) {
    let row = fixture(contract, "ordered_same_rule_duplicate");
    let descriptor = compile_source(row["source"].as_str().expect("fixture source"))
        .to_descriptor_json()
        .expect("project duplicate-slot descriptor");
    assert_eq!(
        descriptor["meta"]["regex_slot_identity_contract"],
        CONTRACT_ID
    );
    assert_eq!(descriptor["spec"]["Top"]["re"].as_array().unwrap().len(), 2);
    assert_eq!(
        descriptor["spec"]["Top"]["dependency_refs"],
        serde_json::json!([
            {"label": "Top", "idx": 0},
            {"label": "Top", "idx": 1}
        ])
    );
    assert_eq!(
        descriptor["spec"]["Top"]["meta"]["resolved_edges"]
            .as_array()
            .unwrap()
            .iter()
            .map(|edge| (&edge["target"], &edge["regex_index"]))
            .collect::<Vec<_>>(),
        [
            (&Value::String("Top".to_string()), &Value::from(0)),
            (&Value::String("Top".to_string()), &Value::from(1)),
        ]
    );
}

fn role_emitted_source(contract: &Value) {
    let row = fixture(contract, "ordered_same_rule_duplicate");
    let emitted = emit_rust_source_v2(
        &compile_source(row["source"].as_str().expect("fixture source")),
        GENERATED_IDENTITY,
    )
    .expect("emit duplicate-slot Rust source");
    assert!(emitted.contains(GENERATED_SOURCE_CONTRACT));
    assert!(emitted.contains(CONTRACT_ID));
    assert!(emitted.contains(r#"family: "and_acode_seq""#));
    let plan = emitted
        .split_once("const GENERATED_PLAN")
        .expect("generated plan start")
        .1
        .split_once("];\n")
        .expect("generated plan end")
        .0;
    assert!(
        !plan.contains("regex_index"),
        "v2 plan must remain label/family only"
    );
}

fn role_generated_direct(contract: &Value) {
    let row = fixture(contract, "ordered_same_rule_duplicate");
    assert_eq!(
        execute_generated_parser_v2(
            &compiled_json(row),
            ORDERED_PLAN,
            row["input"].as_str().expect("fixture input"),
            GENERATED_IDENTITY,
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("execute generated duplicate-slot parser"),
        row["expected_result"]
    );
}

fn role_native_trace(contract: &Value) {
    let row = fixture(contract, "ordered_same_rule_duplicate");
    let scratch = ScratchDirectory::new("native-trace");
    let trace_path = scratch.path().join("native.trace");
    let trace_config = TraceConfig::enabled(TraceLevel::DEBUG)
        .with_trace_file(trace_path.clone())
        .with_reset_file(true);
    assert_eq!(
        Engine::new(compile_source(
            row["source"].as_str().expect("fixture source"),
        ))
        .execute_value_with_trace(
            row["input"].as_str().expect("fixture input"),
            &ExecutionOptions::new(),
            trace_config,
        )
        .expect("execute traced native duplicate-slot parser"),
        row["expected_result"]
    );
    let trace = fs::read_to_string(trace_path).expect("read native duplicate-slot trace");
    assert!(trace.contains("rust_runtime:engine:regex_slot_selected"));
    assert!(
        trace.contains(
            "rule_label=Top selection_role=ordered_required target_rule=Top regex_index=0"
        )
    );
    assert!(
        trace.contains(
            "rule_label=Top selection_role=ordered_required target_rule=Top regex_index=1"
        )
    );
}

fn role_generated_trace(contract: &Value) {
    let row = fixture(contract, "ordered_same_rule_duplicate");
    let scratch = ScratchDirectory::new("generated-trace");
    let trace_path = scratch.path().join("generated.trace");
    let trace_config = TraceConfig::enabled(TraceLevel::DEBUG)
        .with_trace_file(trace_path.clone())
        .with_reset_file(true);
    assert_eq!(
        execute_generated_parser_with_trace_v2(
            &compiled_json(row),
            ORDERED_PLAN,
            row["input"].as_str().expect("fixture input"),
            trace_config,
            GENERATED_IDENTITY,
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("execute traced generated duplicate-slot parser"),
        row["expected_result"]
    );
    let trace = fs::read_to_string(trace_path).expect("read generated duplicate-slot trace");
    assert!(trace.contains("rust_runtime:generated_plan:regex_slot_selected"));
    assert!(
        trace.contains(
            "rule_label=Top selection_role=ordered_required target_rule=Top regex_index=0"
        )
    );
    assert!(
        trace.contains(
            "rule_label=Top selection_role=ordered_required target_rule=Top regex_index=1"
        )
    );
}

fn role_primary_command(contract: &Value) {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
    for id in ["ordered_same_rule_duplicate", "choice_same_rule_duplicate"] {
        let row = fixture(contract, id);
        let outcome = run_with_context(
            os_arguments(&[
                "--inline-spec",
                row["source"].as_str().expect("fixture source"),
                "--input",
                row["input"].as_str().expect("fixture input"),
            ]),
            &root,
            &root,
        );
        assert_eq!(outcome.exit_code, 0, "{id}: primary command failed");
        assert!(outcome.stderr.is_empty(), "{id}: primary command stderr");
        assert_eq!(
            serde_json::from_slice::<Value>(&outcome.stdout).expect("primary command JSON"),
            row["expected_result"],
            "{id}: primary command value"
        );
    }
}

fn role_invalid_identity_diagnostics(contract: &Value) {
    let parsed = parse_spec_with_user_functions("Top::\n -> Missing[3]\n")
        .expect("parse invalid structural slot");
    let compile_error = compile(&parsed).expect_err("invalid structural slot must reject");
    let compile_diagnostic = compile_error
        .diagnostic()
        .expect("compile error carries portable diagnostic");
    assert_eq!(compile_diagnostic.code, "regex_slot_identity_invalid");
    assert_eq!(compile_diagnostic.stage, "validate_compiled_rule");
    assert_eq!(
        compile_diagnostic.field("rule_label"),
        Some(&Value::from("Top"))
    );
    assert_eq!(
        compile_diagnostic.field("target_rule"),
        Some(&Value::from("Missing"))
    );
    assert_eq!(
        compile_diagnostic.field("regex_index"),
        Some(&Value::from(3))
    );

    let row = fixture(contract, "ordered_same_rule_duplicate");
    let mut malformed = compile_source(row["source"].as_str().expect("fixture source"));
    malformed.rules[0].acode_dispatch[1].child_regex_idx = 9;
    let runtime_error = Engine::new(malformed.clone())
        .execute_value_with_diagnostics(
            row["input"].as_str().expect("fixture input"),
            &ExecutionOptions::new(),
        )
        .expect_err("runtime must reject malformed compiled slot");
    let diagnostic = runtime_error.diagnostic();
    assert_eq!(
        diagnostic.code.as_deref(),
        Some("regex_slot_identity_invalid")
    );
    assert_eq!(diagnostic.stage, "validate_compiled_rule");
    assert_eq!(diagnostic.rule_label.as_deref(), Some("Top"));
    assert_eq!(diagnostic.target_rule.as_deref(), Some("Top"));
    assert_eq!(diagnostic.regex_index, Some(9));

    let malformed_json = serde_json::to_string(&malformed).expect("serialize malformed spec");
    let generated_error = validate_generated_parser_plan_v2(
        &malformed_json,
        ORDERED_PLAN,
        GENERATED_IDENTITY,
        GENERATED_SOURCE_CONTRACT,
    )
    .expect_err("generated adapter must reject malformed compiled slot");
    assert_eq!(
        generated_error.stage,
        GeneratedSourceStage::ValidateCompiledRule
    );
    assert_eq!(
        generated_error.code,
        GeneratedSourceCode::RegexSlotIdentityInvalid
    );
    assert_eq!(generated_error.rule_label.as_deref(), Some("Top"));
    assert_eq!(generated_error.target_rule(), Some("Top"));
    assert_eq!(generated_error.regex_index(), Some(9));
    let generated_json = generated_error
        .to_json()
        .expect("serialize generated slot diagnostic");
    assert_eq!(generated_json["target_rule"], "Top");
    assert_eq!(generated_json["regex_index"], 9);

    let lost = assert_ordered_regex_slot_identity("Top", "First", 0, "Second", 0)
        .expect_err("target mismatch must be an ordered identity failure");
    assert_eq!(lost.rule_label, "Top");
    assert_eq!(lost.target_rule, "First");
    assert_eq!(lost.expected_regex_index, 0);
    assert_eq!(lost.actual_regex_index, 0);
    assert_eq!(
        lost.to_string(),
        "ordered_regex_slot_identity_lost stage=execute_rule rule_label=Top target_rule=First expected_regex_index=0 actual_regex_index=0"
    );
}

#[test]
fn contract_declared_rust_roles_execute_once_and_only_once() {
    let contract = contract();
    let roles: [(&str, AdmissionRole); 15] = [
        ("neutral_fixtures", role_neutral_fixtures),
        ("native_ordered", role_native_ordered),
        ("native_choice", role_native_choice),
        ("repeated_ordered", role_repeated_ordered),
        ("repeated_control", role_repeated_control),
        ("cross_target", role_cross_target),
        ("loaded", role_loaded),
        ("reconstructed", role_reconstructed),
        ("descriptor", role_descriptor),
        ("emitted_source", role_emitted_source),
        ("generated_direct", role_generated_direct),
        ("native_trace", role_native_trace),
        ("generated_trace", role_generated_trace),
        ("primary_command", role_primary_command),
        (
            "invalid_identity_diagnostics",
            role_invalid_identity_diagnostics,
        ),
    ];
    let role_map = BTreeMap::from(roles);
    let declared_roles = contract["rust_admission"]["roles"]
        .as_array()
        .expect("Rust admission role array")
        .iter()
        .map(|role| role.as_str().expect("Rust admission role string"))
        .collect::<Vec<_>>();
    assert_eq!(
        role_map.keys().copied().collect::<BTreeSet<_>>(),
        declared_roles.iter().copied().collect::<BTreeSet<_>>(),
        "Rust consumer must implement exactly the contract-declared roles"
    );

    let mut completed = BTreeMap::new();
    for role in declared_roles {
        role_map[role](&contract);
        assert_eq!(completed.insert(role, 1_u8), None, "role {role} repeated");
    }
    assert_eq!(
        completed,
        role_map.keys().map(|role| (*role, 1_u8)).collect(),
        "every declared Rust admission role must complete once"
    );
}
