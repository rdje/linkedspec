//! FUTURE-PARITY-BACKLOG.9.1.1.2.2.3 — composed Rust root-selection admission.

use linkedspec_core::compiler::compile;
use linkedspec_core::entry_rule::ENTRY_RULE_CONTRACT_ID;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::{validate, validate_with_options};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::primary_cli::run_with_context;
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, GeneratedSourceCode, GeneratedSourceStage,
    emit_rust_source_v2, execute_generated_parser_v2_with_options,
    execute_generated_parser_with_trace_v2_with_options,
};
use linkedspec_runtime::spec_loader::{SpecLoadOptions, SpecRequest, load_and_compile_spec};
use serde_json::{Value, json};
use std::collections::{BTreeMap, BTreeSet};
use std::ffi::OsString;
use std::fs;
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

const CONTRACT_SOURCE: &str =
    include_str!("../../../capability_conformance/root_rule_selection_contract.json");
const DEFAULT_REQUEST_TRACE: &str =
    include_str!("../../../cli_conformance/cases/trace/medium_stdout.txt");
const EXPLICIT_REQUEST_TRACE: &str =
    include_str!("../../../cli_conformance/cases/trace/failure_invoke_escaped_medium.txt");
const GENERATED_IDENTITY: &str = "root-selection/rust-admission.spec";

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

const TRACE_SOURCE: &str = r#"Top::
 /x/
 E { return("trace") }
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
            "linkedspec-rust-root-admission-{label}-{}-{nonce}",
            std::process::id()
        ));
        fs::create_dir_all(&path).expect("create root-admission scratch directory");
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
    serde_json::from_str(CONTRACT_SOURCE).expect("root-rule selection contract JSON")
}

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec(source).expect("parse root-admission fixture");
    validate(&parsed).expect("validate root-admission fixture");
    compile(&parsed).expect("compile root-admission fixture")
}

fn compiled_json(source: &str) -> String {
    serde_json::to_string(&compile_source(source)).expect("serialize root-admission fixture")
}

fn explicit(label: &str) -> ExecutionOptions {
    ExecutionOptions::new().with_entry_rule(label)
}

fn os_arguments(arguments: &[&str]) -> Vec<OsString> {
    arguments.iter().map(OsString::from).collect()
}

fn source_for_contract_rows(rows: &[Value]) -> String {
    rows.iter()
        .map(|row| {
            let label = row["label"].as_str().expect("contract rule label");
            let separator = if row["authored_is_top"] == true {
                "::"
            } else {
                ":"
            };
            format!("{label}{separator}\n /x/\n E {{ return(\"{label}\") }}\n")
        })
        .collect::<Vec<_>>()
        .join("\n")
}

fn compiled_for_contract_rows(rows: &[Value]) -> CompiledSpec {
    if rows.is_empty() {
        CompiledSpec {
            functions: Vec::new(),
            rules: Vec::new(),
        }
    } else {
        compile_source(&source_for_contract_rows(rows))
    }
}

fn role_neutral_selection(contract: &Value) {
    assert_eq!(contract["contract_id"], ENTRY_RULE_CONTRACT_ID);
    for case in contract["selection_cases"]
        .as_array()
        .expect("neutral selection cases")
    {
        let rows = case["rules"].as_array().expect("selection rule rows");
        let selector = case["explicit_selector"].as_str();
        let compiled = compiled_for_contract_rows(rows);
        let authored_before = compiled
            .rules
            .iter()
            .map(|rule| (rule.label.clone(), rule.is_top))
            .collect::<Vec<_>>();
        let selected = compiled
            .resolve_entry_rule(selector)
            .unwrap_or_else(|error| panic!("{}: {error}", case["id"]));
        assert_eq!(selected.rule.label, case["expected_label"]);
        assert_eq!(selected.basis.as_str(), case["expected_basis"]);
        assert_eq!(
            compiled
                .rules
                .iter()
                .map(|rule| (rule.label.clone(), rule.is_top))
                .collect::<Vec<_>>(),
            authored_before,
            "{} rewrote authored identity",
            case["id"]
        );
    }
}

fn role_neutral_failures(contract: &Value) {
    for case in contract["failure_cases"]
        .as_array()
        .expect("neutral failure cases")
    {
        let rows = case["rules"].as_array().expect("failure rule rows");
        let error = compiled_for_contract_rows(rows)
            .resolve_entry_rule(case["explicit_selector"].as_str())
            .expect_err("neutral failure row must reject");
        assert_eq!(error.code, case["expected_code"]);
        assert_eq!(error.stage, case["expected_stage"]);
    }
}

fn role_neutral_strict(contract: &Value) {
    for case in contract["strict_cases"]
        .as_array()
        .expect("neutral strict cases")
    {
        let source = match case["id"].as_str().expect("strict case id") {
            "explicit_selection_is_not_reference" => "A:\n /a/\n\nB:\n /b/\n",
            "marker_selection_is_not_reference" => {
                "Top::\n /x/ -> Child\n\nChild:\n /x/ -> Child\n"
            }
            "closed_reference_cycle_has_no_unused_rules" => "A:\n /a/ -> B\n\nB:\n /b/ -> A\n",
            other => panic!("unhandled strict case {other}"),
        };
        let parsed = parse_spec(source).expect("parse strict admission fixture");
        let expected_unused = case["expected_unused"]
            .as_array()
            .expect("strict expected-unused rows");
        if expected_unused.is_empty() {
            validate_with_options(&parsed, true).expect("closed reference graph validates");
        } else {
            let error = validate_with_options(&parsed, true)
                .expect_err("unreferenced rules must fail strict validation")
                .to_string();
            for label in expected_unused {
                assert!(
                    error.contains(label.as_str().expect("unused label")),
                    "strict diagnostic omitted {label}: {error}"
                );
            }
        }
    }
}

fn role_native(_contract: &Value) {
    let marked = Engine::new(compile_source(MARKED_SOURCE));
    assert_eq!(
        marked
            .execute_value("x", &ExecutionOptions::new())
            .expect("native marked default"),
        json!("marked")
    );
    assert_eq!(
        marked
            .execute_value("x", &explicit("Earlier"))
            .expect("native explicit ordinary"),
        json!("earlier")
    );
    assert_eq!(
        marked
            .execute_value("x", &explicit("Later"))
            .expect("native explicit later marker"),
        json!("later")
    );
    assert_eq!(
        Engine::new(compile_source(MARKERLESS_SOURCE))
            .execute_value("x", &ExecutionOptions::new())
            .expect("native markerless default"),
        json!("first")
    );
}

fn role_loaded(_contract: &Value) {
    let scratch = ScratchDirectory::new("loaded");
    let path = scratch.path().join("markerless.spec");
    fs::write(&path, MARKERLESS_SOURCE).expect("write loaded admission fixture");
    let loaded = load_and_compile_spec(
        &SpecRequest::path(path.to_string_lossy().into_owned()),
        &SpecLoadOptions::new(scratch.path()),
    )
    .expect("load markerless admission fixture");
    assert_eq!(
        loaded
            .into_engine()
            .execute_value("x", &explicit("Second"))
            .expect("loaded explicit markerless execution"),
        json!("second")
    );
}

fn role_reconstructed(_contract: &Value) {
    let encoded = serde_json::to_string(&compile_source(MARKED_SOURCE))
        .expect("serialize admission CompiledSpec");
    let reconstructed: CompiledSpec =
        serde_json::from_str(&encoded).expect("reconstruct admission CompiledSpec");
    assert_eq!(
        reconstructed
            .rules
            .iter()
            .map(|rule| (rule.label.as_str(), rule.is_top))
            .collect::<Vec<_>>(),
        [("Earlier", false), ("Marked", true), ("Later", true)]
    );
    let engine = Engine::new(reconstructed);
    assert_eq!(
        engine
            .execute_value("x", &ExecutionOptions::new())
            .expect("reconstructed marked default"),
        json!("marked")
    );
    assert_eq!(
        engine
            .execute_value("x", &explicit("Earlier"))
            .expect("reconstructed explicit ordinary"),
        json!("earlier")
    );
}

fn role_generated_direct(_contract: &Value) {
    assert_eq!(
        execute_generated_parser_v2_with_options(
            &compiled_json(MARKED_SOURCE),
            MARKED_PLAN,
            "x",
            GENERATED_IDENTITY,
            GENERATED_SOURCE_CONTRACT,
            &explicit("Earlier"),
        )
        .expect("generated explicit direct execution"),
        json!("earlier")
    );
    assert_eq!(
        execute_generated_parser_v2_with_options(
            &compiled_json(MARKERLESS_SOURCE),
            MARKERLESS_PLAN,
            "x",
            GENERATED_IDENTITY,
            GENERATED_SOURCE_CONTRACT,
            &ExecutionOptions::new(),
        )
        .expect("generated markerless direct execution"),
        json!("first")
    );
}

fn role_generated_traced(_contract: &Value) {
    let scratch = ScratchDirectory::new("generated-traced");
    let trace_path = scratch.path().join("generated.trace");
    assert_eq!(
        execute_generated_parser_with_trace_v2_with_options(
            &compiled_json(MARKED_SOURCE),
            MARKED_PLAN,
            "x",
            TraceConfig::enabled(TraceLevel::DEBUG)
                .with_trace_file(trace_path.clone())
                .with_reset_file(true),
            GENERATED_IDENTITY,
            GENERATED_SOURCE_CONTRACT,
            &explicit("Later"),
        )
        .expect("generated traced later-marker execution"),
        json!("later")
    );
    let trace = fs::read_to_string(trace_path).expect("read generated admission trace");
    assert!(trace.contains("rust_runtime:generated_plan:top_rule"));
    assert!(trace.contains("label=Later basis=explicit_selector"));
    assert!(trace.contains("rule=Later"));
}

fn role_emitted_source_direct(_contract: &Value) {
    let source = emit_rust_source_v2(&compile_source(MARKED_SOURCE), GENERATED_IDENTITY)
        .expect("emit admission source");
    for entrypoint in [
        "pub fn execute_with_options(",
        "pub fn parse_with_options(",
        "pub fn execute_with_options_and_diagnostic_output(",
        "pub fn parse_with_options_and_diagnostic_output(",
    ] {
        assert!(
            source.contains(entrypoint),
            "emitted source omitted {entrypoint}"
        );
    }
    assert!(source.contains("ExecutionOptions"));
    assert!(source.contains(GENERATED_IDENTITY));
}

fn role_emitted_source_traced(_contract: &Value) {
    let source = emit_rust_source_v2(&compile_source(MARKED_SOURCE), GENERATED_IDENTITY)
        .expect("emit traced admission source");
    for entrypoint in [
        "pub fn execute_with_trace_and_options(",
        "pub fn parse_with_trace_and_options(",
        "pub fn execute_with_trace_and_options_and_diagnostic_output(",
        "pub fn parse_with_trace_and_options_and_diagnostic_output(",
    ] {
        assert!(
            source.contains(entrypoint),
            "emitted source omitted {entrypoint}"
        );
    }
}

fn role_descriptor(_contract: &Value) {
    let compiled = compile_source(MARKED_SOURCE);
    let before = compiled
        .to_descriptor_json()
        .expect("project admission descriptor");
    Engine::new(compiled.clone())
        .execute_value("x", &explicit("Earlier"))
        .expect("execute explicit descriptor admission fixture");
    let after = compiled
        .to_descriptor_json()
        .expect("re-project admission descriptor");
    assert_eq!(after, before);
    assert_eq!(after["meta"]["entry_rule_contract"], ENTRY_RULE_CONTRACT_ID);
    assert_eq!(
        after["meta"]["definition_order"],
        json!(["Earlier", "Marked", "Later"])
    );
    assert_eq!(after["spec"]["Earlier"]["meta"]["is_top"], false);
    assert_eq!(after["spec"]["Marked"]["meta"]["is_top"], true);
    assert!(after["meta"].get("entry_rule").is_none());
    assert!(after["meta"].get("selected_entry_rule").is_none());
}

fn role_diagnostic(_contract: &Value) {
    let unknown = Engine::new(compile_source(MARKED_SOURCE))
        .execute_value_with_diagnostics("x", &explicit("Missing"))
        .expect_err("unknown selector must reject before execution");
    assert_eq!(
        unknown.diagnostic.code.as_deref(),
        Some("entry_rule_not_found")
    );
    assert_eq!(unknown.diagnostic.stage, "select_entry_rule");
    assert_eq!(unknown.diagnostic.entry_rule.as_deref(), Some("Missing"));

    let zero = Engine::new(CompiledSpec {
        functions: Vec::new(),
        rules: Vec::new(),
    })
    .execute_value_with_diagnostics("", &explicit("Missing"))
    .expect_err("zero-rule validation must win over selection");
    assert_eq!(zero.diagnostic.code.as_deref(), Some("no_rules_defined"));
    assert_eq!(zero.diagnostic.stage, "validate_spec");

    let stale = execute_generated_parser_v2_with_options(
        &compiled_json(MARKED_SOURCE),
        MARKED_PLAN,
        "x",
        GENERATED_IDENTITY,
        "linkedspec-generated-source-v1",
        &explicit("Missing"),
    )
    .expect_err("stale generated contract must fail before selection");
    assert_eq!(stale.stage, GeneratedSourceStage::ValidateGeneratedPlan);
    assert_eq!(
        stale.code,
        GeneratedSourceCode::GeneratedSourceContractVersionMismatch
    );
}

fn role_runtime_trace(_contract: &Value) {
    let failure_source = MARKED_SOURCE.replace("E { return(\"earlier\") }", "I { exit_now(17) }");
    let scratch = ScratchDirectory::new("runtime-trace");
    let trace_path = scratch.path().join("failure.trace");
    let error = execute_generated_parser_with_trace_v2_with_options(
        &compiled_json(&failure_source),
        MARKED_PLAN,
        "x",
        TraceConfig::enabled(TraceLevel::DEBUG)
            .with_trace_file(trace_path.clone())
            .with_reset_file(true),
        GENERATED_IDENTITY,
        GENERATED_SOURCE_CONTRACT,
        &explicit("Earlier"),
    )
    .expect_err("selected rule runtime failure must retain effective identity");
    assert_eq!(error.stage, GeneratedSourceStage::ExecuteGenerated);
    assert_eq!(error.code, GeneratedSourceCode::GeneratedExecutionFailed);
    assert_eq!(error.rule_label.as_deref(), Some("Earlier"));
    assert_eq!(error.handler_family.as_deref(), Some("default"));
    let trace = fs::read_to_string(trace_path).expect("read failed generated trace");
    assert!(trace.contains("label=Earlier basis=explicit_selector"));
    assert!(trace.contains("rule=Earlier"));
}

fn role_primary_cli(_contract: &Value) {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
    for (source, selector, expected) in [
        (MARKED_SOURCE, None, b"\"marked\"\n".as_slice()),
        (MARKERLESS_SOURCE, None, b"\"first\"\n".as_slice()),
        (MARKED_SOURCE, Some("Earlier"), b"\"earlier\"\n".as_slice()),
    ] {
        let mut arguments = vec!["--inline-spec", source, "--input", "x"];
        if let Some(selector) = selector {
            arguments.extend(["--top-rule", selector]);
        }
        let output = run_with_context(os_arguments(&arguments), &root, &root);
        assert_eq!(output.exit_code, 0);
        assert_eq!(output.stdout, expected);
        assert!(output.stderr.is_empty());
    }

    let unknown = run_with_context(
        os_arguments(&[
            "--inline-spec",
            MARKED_SOURCE,
            "--input",
            "x",
            "--top-rule",
            "Missing",
        ]),
        &root,
        &root,
    );
    assert_eq!(unknown.exit_code, 1);
    assert!(unknown.stdout.is_empty());
    assert_eq!(unknown.stderr, b"linkedspec: parser invocation failed\n");
}

fn role_primary_request_trace(_contract: &Value) {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
    let default = run_with_context(
        os_arguments(&[
            "--inline-spec",
            TRACE_SOURCE,
            "--input",
            "x",
            "--trace",
            "medium",
        ]),
        &root,
        &root,
    );
    assert_eq!(default.exit_code, 0);
    assert_eq!(default.stdout, DEFAULT_REQUEST_TRACE.as_bytes());
    assert!(default.stderr.is_empty());

    let scratch = ScratchDirectory::new("primary-request-trace");
    let explicit = run_with_context(
        os_arguments(&[
            "--inline-spec",
            TRACE_SOURCE,
            "--input",
            "x",
            "--top-rule",
            "Top\nInjected",
            "--trace",
            "medium",
            "--trace-file",
            "trace.log",
            "--trace-mode",
            "route",
            "--trace-reset",
        ]),
        scratch.path(),
        &root,
    );
    assert_eq!(explicit.exit_code, 1);
    assert!(explicit.stdout.is_empty());
    assert_eq!(explicit.stderr, b"linkedspec: parser invocation failed\n");
    assert_eq!(
        fs::read(scratch.path().join("trace.log")).expect("read explicit request trace"),
        EXPLICIT_REQUEST_TRACE.as_bytes()
    );
}

#[test]
fn contract_declared_rust_roles_execute_once_and_only_once() {
    let contract = contract();
    let roles: [(&str, AdmissionRole); 15] = [
        ("neutral_selection", role_neutral_selection),
        ("neutral_failures", role_neutral_failures),
        ("neutral_strict", role_neutral_strict),
        ("native", role_native),
        ("loaded", role_loaded),
        ("reconstructed", role_reconstructed),
        ("generated_direct", role_generated_direct),
        ("generated_traced", role_generated_traced),
        ("emitted_source_direct", role_emitted_source_direct),
        ("emitted_source_traced", role_emitted_source_traced),
        ("descriptor", role_descriptor),
        ("diagnostic", role_diagnostic),
        ("runtime_trace", role_runtime_trace),
        ("primary_cli", role_primary_cli),
        ("primary_request_trace", role_primary_request_trace),
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
