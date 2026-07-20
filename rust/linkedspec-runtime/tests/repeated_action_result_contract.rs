//! FUTURE-PARITY-BACKLOG.9.1.10.2 — Rust explicit-repetition result admission.

use linkedspec_core::compiler::compile;
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::primary_cli::run_with_context;
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, GeneratedSourceCode, GeneratedSourceStage,
    classify_generated_rule_family, emit_rust_source_v2, execute_generated_parser_v2,
    execute_generated_parser_with_trace_v2, validate_generated_parser_plan_v2,
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
    include_str!("../../../capability_conformance/repeated_action_result_contract.json");
const CORPUS_SOURCE: &str = include_str!(
    "../../../capability_conformance/repeated_action_result/explicit_or_distinct.spec"
);
const CORPUS_INPUT: &str = include_str!(
    "../../../capability_conformance/repeated_action_result/explicit_or_distinct.input"
);
const CORPUS_EXPECTED: &str = include_str!(
    "../../../capability_conformance/repeated_action_result/explicit_or_distinct.expected.json"
);
const CONTRACT_ID: &str = "linkedspec-explicit-repetition-action-result-v1";
const GENERATED_IDENTITY: &str = "repeated-action-result/rust-admission.spec";
const REP_PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
    label: "Top",
    family: "rep_acode",
}];
const OR_PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
    label: "Top",
    family: "or_acode",
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
            "linkedspec-rust-repeated-result-{label}-{}-{nonce}",
            std::process::id()
        ));
        fs::create_dir_all(&path).expect("create repeated-result scratch directory");
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
    serde_json::from_str(CONTRACT_SOURCE).expect("explicit-repetition result contract JSON")
}

fn case<'a>(contract: &'a Value, id: &str) -> &'a Value {
    ["mode_cases", "special_cases"]
        .into_iter()
        .flat_map(|field| contract[field].as_array().expect("contract case array"))
        .find(|row| row["id"] == id)
        .unwrap_or_else(|| panic!("missing explicit-repetition result case {id}"))
}

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse repeated-result fixture");
    validate(&parsed).expect("validate repeated-result fixture");
    compile(&parsed).expect("compile repeated-result fixture")
}

fn compiled_json(row: &Value) -> String {
    serde_json::to_string(&compile_source(
        row["source"].as_str().expect("fixture source"),
    ))
    .expect("serialize repeated-result fixture")
}

fn execute_fixture(row: &Value) -> Value {
    Engine::new(compile_source(
        row["source"].as_str().expect("fixture source"),
    ))
    .execute_value(
        row["input"].as_str().expect("fixture input"),
        &ExecutionOptions::new(),
    )
    .unwrap_or_else(|error| panic!("{} native execution failed: {error}", row["id"]))
}

fn generated_plan(family: &str) -> &'static [GeneratedPlanRow] {
    match family {
        "rep_acode" => REP_PLAN,
        "or_acode" => OR_PLAN,
        other => panic!("unsupported one-rule generated plan family {other}"),
    }
}

fn os_arguments(arguments: &[&str]) -> Vec<OsString> {
    arguments.iter().map(OsString::from).collect()
}

fn optional_usize(value: &Value) -> Option<usize> {
    value.as_u64().map(|number| number as usize)
}

fn role_neutral_contract(contract: &Value) {
    assert_eq!(contract["contract_id"], CONTRACT_ID);
    assert_eq!(
        contract["scope"]["explicit_repetition_modes"],
        serde_json::json!(["Star", "Plus", "Optional", "Or", "OrPlus", "OrBounded"])
    );
    assert_eq!(
        contract["mode_cases"]
            .as_array()
            .expect("mode cases")
            .iter()
            .map(|row| row["id"].as_str().expect("mode id"))
            .collect::<Vec<_>>(),
        [
            "compact_star_two_hits",
            "compact_plus_two_hits",
            "compact_optional_one_hit",
            "explicit_or_two_hits",
            "explicit_or_plus_two_hits",
            "bounded_exact_two_hits",
            "bounded_up_to_two_hits",
            "pipe_distinct_scalar",
        ]
    );
    assert_eq!(
        contract["semantics"]["lifecycle_return"],
        "whole_rule_return"
    );
    assert_eq!(contract["generated_source_v2"]["format_version"], 2);
}

fn role_ast_metadata(contract: &Value) {
    for row in contract["mode_cases"].as_array().expect("mode cases") {
        let compiled = compile_source(row["source"].as_str().expect("fixture source"));
        let rule = &compiled.rules[0];
        assert_eq!(
            rule.mode.is_repetition(),
            row["is_repetition"].as_bool().expect("repetition boolean"),
            "{} authored repetition predicate",
            row["id"]
        );
        assert_eq!(
            rule.rep_min,
            optional_usize(&row["rep_min"]),
            "{} rep_min",
            row["id"]
        );
        assert_eq!(
            rule.rep_max,
            optional_usize(&row["rep_max"]),
            "{} rep_max",
            row["id"]
        );
        assert_eq!(
            classify_generated_rule_family(rule).contract_name(),
            row["generated_family"].as_str().expect("generated family"),
            "{} generated family",
            row["id"]
        );
    }

    let blind = case(contract, "blind_or_repeats");
    let compiled = compile_source(blind["source"].as_str().expect("blind source"));
    assert_eq!(compiled.rules[0].rep_min, Some(1));
    assert_eq!(
        classify_generated_rule_family(&compiled.rules[0]).contract_name(),
        "rep_bcode"
    );
}

fn role_native_mode_matrix(contract: &Value) {
    for row in contract["mode_cases"].as_array().expect("mode cases") {
        assert_eq!(
            execute_fixture(row),
            row["expected_result"],
            "{}",
            row["id"]
        );
    }
}

fn role_native_special_cases(contract: &Value) {
    for row in contract["special_cases"].as_array().expect("special cases") {
        if row["edge_surface"] == "blind" {
            continue;
        }
        assert_eq!(
            execute_fixture(row),
            row["expected_result"],
            "{}",
            row["id"]
        );
    }
}

fn role_loaded(contract: &Value) {
    let row = case(contract, "explicit_or_two_hits");
    let scratch = ScratchDirectory::new("loaded");
    let path = scratch.path().join("explicit-or.spec");
    fs::write(&path, row["source"].as_str().expect("fixture source"))
        .expect("write repeated-result spec");
    let loaded = load_and_compile_spec(
        &SpecRequest::path(path.to_string_lossy().into_owned()),
        &SpecLoadOptions::new(scratch.path()),
    )
    .expect("load repeated-result spec");
    assert_eq!(
        loaded
            .into_engine()
            .execute_value(
                row["input"].as_str().expect("fixture input"),
                &ExecutionOptions::new(),
            )
            .expect("execute loaded repeated-result spec"),
        row["expected_result"]
    );
}

fn role_reconstructed(contract: &Value) {
    let row = case(contract, "explicit_or_two_hits");
    let reconstructed: CompiledSpec =
        serde_json::from_str(&compiled_json(row)).expect("reconstruct repeated-result spec");
    assert_eq!(
        Engine::new(reconstructed)
            .execute_value(
                row["input"].as_str().expect("fixture input"),
                &ExecutionOptions::new(),
            )
            .expect("execute reconstructed repeated-result spec"),
        row["expected_result"]
    );
}

fn role_descriptor(contract: &Value) {
    for id in ["explicit_or_two_hits", "pipe_distinct_scalar"] {
        let row = case(contract, id);
        let descriptor = compile_source(row["source"].as_str().expect("fixture source"))
            .to_descriptor_json()
            .expect("project repeated-result descriptor");
        let meta = &descriptor["spec"]["Top"]["meta"];
        assert_eq!(meta["family"], contract["descriptor_contract"]["family"]);
        assert_eq!(
            meta["cursor_policy"],
            contract["descriptor_contract"]["cursor_policy"]
        );
        assert_eq!(meta["mode"]["is_repetition"], row["is_repetition"]);
        assert_eq!(meta["mode"]["rep_min"], row["rep_min"]);
        assert_eq!(meta["mode"]["rep_max"], row["rep_max"]);
    }
}

fn role_emitted_source(contract: &Value) {
    let row = case(contract, "explicit_or_two_hits");
    let json = compiled_json(row);
    let emitted = emit_rust_source_v2(
        &compile_source(row["source"].as_str().expect("fixture source")),
        GENERATED_IDENTITY,
    )
    .expect("emit repeated-result Rust source");
    assert!(emitted.contains(GENERATED_SOURCE_CONTRACT));
    assert!(emitted.contains(r#"family: "rep_acode""#));
    assert!(emitted.contains("pub fn execute(input: &str)"));
    assert!(emitted.contains("pub fn execute_with_trace(input: &str"));
    let stale = validate_generated_parser_plan_v2(
        &json,
        OR_PLAN,
        GENERATED_IDENTITY,
        GENERATED_SOURCE_CONTRACT,
    )
    .expect_err("stale bare-OR plan must reject");
    assert_eq!(stale.stage, GeneratedSourceStage::ValidateGeneratedPlan);
    assert_eq!(stale.code, GeneratedSourceCode::GeneratedPlanFamilyMismatch);
}

fn role_generated_direct(contract: &Value) {
    for row in contract["mode_cases"].as_array().expect("mode cases") {
        let family = row["generated_family"].as_str().expect("generated family");
        assert_eq!(
            execute_generated_parser_v2(
                &compiled_json(row),
                generated_plan(family),
                row["input"].as_str().expect("fixture input"),
                GENERATED_IDENTITY,
                GENERATED_SOURCE_CONTRACT,
            )
            .unwrap_or_else(|error| panic!("{} generated execution failed: {error}", row["id"])),
            row["expected_result"],
            "{}",
            row["id"]
        );
    }
}

fn role_native_trace(contract: &Value) {
    let row = case(contract, "explicit_or_two_hits");
    let scratch = ScratchDirectory::new("native-trace");
    let trace_path = scratch.path().join("native.trace");
    let trace_config = TraceConfig::enabled(TraceLevel::DEBUG)
        .with_trace_file(trace_path.clone())
        .with_reset_file(true);
    assert_eq!(
        Engine::new(compile_source(
            row["source"].as_str().expect("fixture source")
        ))
        .execute_value_with_trace(
            row["input"].as_str().expect("fixture input"),
            &ExecutionOptions::new(),
            trace_config,
        )
        .expect("execute traced native repeated-result parser"),
        row["expected_result"]
    );
    let trace = fs::read_to_string(trace_path).expect("read native repeated-result trace");
    assert_eq!(
        trace
            .matches("rust_runtime:engine:regex_slot_selected")
            .count(),
        2
    );
    assert!(trace.contains("target_rule=Top regex_index=0"));
    assert!(trace.contains("target_rule=Top regex_index=1"));
}

fn role_generated_trace(contract: &Value) {
    let row = case(contract, "explicit_or_two_hits");
    let scratch = ScratchDirectory::new("generated-trace");
    let trace_path = scratch.path().join("generated.trace");
    let trace_config = TraceConfig::enabled(TraceLevel::DEBUG)
        .with_trace_file(trace_path.clone())
        .with_reset_file(true);
    assert_eq!(
        execute_generated_parser_with_trace_v2(
            &compiled_json(row),
            REP_PLAN,
            row["input"].as_str().expect("fixture input"),
            trace_config,
            GENERATED_IDENTITY,
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("execute traced generated repeated-result parser"),
        row["expected_result"]
    );
    let trace = fs::read_to_string(trace_path).expect("read generated repeated-result trace");
    assert_eq!(
        trace
            .matches("rust_runtime:generated_plan:regex_slot_selected")
            .count(),
        2
    );
    assert!(trace.contains("target_rule=Top regex_index=0"));
    assert!(trace.contains("target_rule=Top regex_index=1"));
}

fn role_primary_command(contract: &Value) {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
    for id in ["explicit_or_two_hits", "pipe_distinct_scalar"] {
        let row = case(contract, id);
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

fn role_corpus_bundle(contract: &Value) {
    let row = case(contract, "explicit_or_two_hits");
    assert_eq!(
        CORPUS_SOURCE,
        row["source"].as_str().expect("fixture source")
    );
    assert_eq!(CORPUS_INPUT, "ab\n");
    let expected: Value = serde_json::from_str(CORPUS_EXPECTED).expect("corpus expected JSON");
    assert_eq!(expected, row["expected_result"]);
    assert_eq!(
        Engine::new(compile_source(CORPUS_SOURCE))
            .execute_value(CORPUS_INPUT.trim_end(), &ExecutionOptions::new())
            .expect("execute repeated-result corpus"),
        expected
    );
}

fn role_lifecycle_authority(contract: &Value) {
    for id in [
        "exit_lifecycle_overrides_collection",
        "loop_end_lifecycle_exits_rule",
    ] {
        let row = case(contract, id);
        assert_eq!(execute_fixture(row), row["expected_result"], "{id}");
    }
}

fn role_bounds_and_progress(contract: &Value) {
    for id in [
        "compact_optional_one_hit",
        "bounded_exact_two_hits",
        "bounded_up_to_two_hits",
        "zero_permitted_hits_empty",
        "below_minimum_is_null",
    ] {
        let row = case(contract, id);
        assert_eq!(execute_fixture(row), row["expected_result"], "{id}");
    }

    let zero_progress = "Top::OR{,3}\n /x*/ -> Top[0] { return(\"Z\") }\n";
    assert_eq!(
        Engine::new(compile_source(zero_progress))
            .execute_value("", &ExecutionOptions::new())
            .expect("execute zero-progress repeated action"),
        serde_json::json!(["Z"]),
        "one accepted zero-width hit is retained before repetition stops"
    );
}

#[test]
fn bare_or_metadata_and_family_are_repetition() {
    let row = case(&contract(), "explicit_or_two_hits").clone();
    let compiled = compile_source(row["source"].as_str().expect("fixture source"));
    assert!(compiled.rules[0].mode.is_repetition());
    assert_eq!(compiled.rules[0].rep_min, Some(1));
    assert_eq!(
        classify_generated_rule_family(&compiled.rules[0]).contract_name(),
        "rep_acode"
    );
}

#[test]
fn repeated_action_returns_are_collected_per_hit() {
    let contract = contract();
    let row = case(&contract, "explicit_or_two_hits");
    assert_eq!(execute_fixture(row), serde_json::json!(["A", "B"]));
}

#[test]
fn contract_declared_rust_roles_execute_once_and_only_once() {
    let contract = contract();
    let roles: [(&str, AdmissionRole); 15] = [
        ("neutral_contract", role_neutral_contract),
        ("ast_metadata", role_ast_metadata),
        ("native_mode_matrix", role_native_mode_matrix),
        ("native_special_cases", role_native_special_cases),
        ("loaded", role_loaded),
        ("reconstructed", role_reconstructed),
        ("descriptor", role_descriptor),
        ("emitted_source", role_emitted_source),
        ("generated_direct", role_generated_direct),
        ("native_trace", role_native_trace),
        ("generated_trace", role_generated_trace),
        ("primary_command", role_primary_command),
        ("corpus_bundle", role_corpus_bundle),
        ("lifecycle_authority", role_lifecycle_authority),
        ("bounds_and_progress", role_bounds_and_progress),
    ];
    let role_map = BTreeMap::from(roles);
    let declared_roles = contract["admissions"]["rust"]["roles"]
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
