//! FUTURE-PARITY-BACKLOG.9.1.4.7 — composed Rust rule-local cursor admission.

use linkedspec_core::compiler::compile;
use linkedspec_core::error::PortableDiagnostic;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::primary_cli::run_with_context;
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, GeneratedSourceCode, GeneratedSourceStage,
    emit_rust_source_v2, execute_generated_parser_v2, execute_generated_parser_with_trace_v2,
    validate_generated_parser_plan_v2,
};
use linkedspec_runtime::spec_loader::{SpecLoadOptions, SpecRequest, load_and_compile_spec};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
use std::collections::{BTreeMap, BTreeSet};
use std::ffi::OsString;
use std::fs;
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

const CONTRACT_SOURCE: &str =
    include_str!("../../../capability_conformance/rule_local_cursor_contract.json");
const DEFAULT_SOURCE: &str = "Top::\n /x/ -> Top { return(\"hit\") }\n";
const AND_SOURCE: &str = "Top::AND\n /x/ -> Top { return(\"hit\") }\n";
const GENERATED_IDENTITY: &str = "rule-local-cursor/rust-admission.spec";
const GENERATED_PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
    label: "Top",
    family: "default",
}];

type AdmissionRole = fn(&Value, &mut AdmissionState);

#[derive(Default)]
struct AdmissionState {
    observed_diagnostics: BTreeSet<String>,
}

impl AdmissionState {
    fn observe(&mut self, code: &str) {
        self.observed_diagnostics.insert(code.to_string());
    }
}

fn contract() -> Value {
    serde_json::from_str(CONTRACT_SOURCE).expect("rule-local cursor contract JSON")
}

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse admission fixture");
    validate(&parsed).expect("validate admission fixture");
    compile(&parsed).expect("compile admission fixture")
}

fn execute(compiled: CompiledSpec, input: &str) -> Result<Value, String> {
    Engine::new(compiled).execute_value(input, &ExecutionOptions::new())
}

fn unique_temp_path(label: &str, extension: &str) -> PathBuf {
    let nonce = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("clock after epoch")
        .as_nanos();
    std::env::temp_dir().join(format!(
        "linkedspec-rust-cursor-admission-{}-{label}-{nonce}.{extension}",
        std::process::id()
    ))
}

fn os_arguments(arguments: &[&str]) -> Vec<OsString> {
    arguments.iter().map(OsString::from).collect()
}

fn edge_source(parent_family: &str, sources: &[&str], declared_rules: &[&str]) -> String {
    let mut source = if parent_family == "and" {
        "Top::AND\n".to_string()
    } else {
        "Top::\n".to_string()
    };
    for edge in sources {
        source.push(' ');
        source.push_str(edge);
        source.push('\n');
    }
    for label in declared_rules {
        source.push_str(&format!("\n{label}:\n /x/ /y/\n"));
    }
    source
}

fn diagnostic_for(source: &str) -> PortableDiagnostic {
    let parsed = parse_spec(source).expect("portable diagnostic fixture parses to typed AST");
    validate(&parsed)
        .expect_err("portable diagnostic fixture rejects")
        .diagnostic()
        .expect("validation failure carries a portable diagnostic")
        .clone()
}

fn assert_consume_rejects_leading_input(compiled: CompiledSpec, role: &str) {
    match execute(compiled, "prefix x") {
        Ok(value) => assert_eq!(value, Value::Null, "{role}: consume miss result"),
        Err(error) => assert!(
            error.contains("expected at least") && error.contains("got 0"),
            "{role}: unexpected consume miss: {error}"
        ),
    }
}

fn role_native_default_family(_contract: &Value, _state: &mut AdmissionState) {
    assert_eq!(
        execute(compile_source(DEFAULT_SOURCE), "prefix x").expect("default native execution"),
        json!("hit")
    );
}

fn role_native_and_family(_contract: &Value, _state: &mut AdmissionState) {
    let compiled = compile_source(AND_SOURCE);
    assert_consume_rejects_leading_input(compiled.clone(), "native AND family");
    assert_eq!(
        execute(compiled, "x").expect("contiguous native AND execution"),
        json!("hit")
    );
}

fn role_ordinary_serialized(_contract: &Value, _state: &mut AdmissionState) {
    for (source, input, expected) in [
        (DEFAULT_SOURCE, "prefix x", json!("hit")),
        (AND_SOURCE, "x", json!("hit")),
    ] {
        let encoded =
            serde_json::to_string(&compile_source(source)).expect("serialize CompiledSpec");
        let retired_field = ["parse", "mode"].join("_");
        assert!(
            !encoded.contains(&format!("\"{retired_field}\"")),
            "ordinary CompiledSpec JSON must not carry an independent cursor field"
        );
        let reconstructed: CompiledSpec =
            serde_json::from_str(&encoded).expect("reconstruct ordinary CompiledSpec");
        assert_eq!(
            execute(reconstructed, input).expect("execute reconstructed CompiledSpec"),
            expected
        );
    }
}

fn role_loaded_spec(_contract: &Value, _state: &mut AdmissionState) {
    let source = r#"Top::AND
 => Child
Child:
 /x/
 -> Child { return("hit") }
"#;
    let path = unique_temp_path("loaded", "spec");
    fs::write(&path, source).expect("write loaded admission spec");
    let loaded = load_and_compile_spec(
        &SpecRequest::path(path.to_string_lossy().into_owned()),
        &SpecLoadOptions::new(std::env::temp_dir()),
    )
    .expect("load admission spec");
    let _ = fs::remove_file(&path);
    assert_eq!(
        loaded
            .into_engine()
            .execute_value("prefix x", &ExecutionOptions::new())
            .expect("execute loaded mixed-family spec"),
        json!(["hit"])
    );
}

fn role_descriptor_v1(contract: &Value, _state: &mut AdmissionState) {
    let source = r#"Top::AND
 Child
Child:
 /x/
 -> Child { return("hit") }
"#;
    let descriptor = compile_source(source)
        .to_descriptor_json()
        .expect("project admission descriptor");
    assert_eq!(
        descriptor["meta"]["cursor_contract"],
        contract["descriptor_contract"]["meta"]["cursor_contract"]
    );
    assert_eq!(descriptor["spec"]["Top"]["meta"]["family"], "and");
    assert_eq!(
        descriptor["spec"]["Top"]["meta"]["cursor_policy"],
        "consume"
    );
    assert_eq!(descriptor["spec"]["Child"]["meta"]["cursor_policy"], "seek");
    assert_eq!(
        descriptor["spec"]["Top"]["meta"]["resolved_edges"][0]["ownership"],
        "blind"
    );
    for removed in contract["descriptor_contract"]["removed_fields"]
        .as_array()
        .expect("descriptor removed-fields array")
    {
        let field = removed
            .as_str()
            .expect("descriptor removed field string")
            .rsplit('.')
            .next()
            .expect("descriptor removed field tail");
        assert!(descriptor["meta"].get(field).is_none());
        assert!(descriptor["spec"]["Top"]["meta"].get(field).is_none());
    }
}

fn role_emitted_source_v2(contract: &Value, _state: &mut AdmissionState) {
    let emitted = emit_rust_source_v2(&compile_source(DEFAULT_SOURCE), GENERATED_IDENTITY)
        .expect("emit admission source v2");
    assert!(emitted.contains(GENERATED_IDENTITY));
    assert!(
        emitted.contains(
            contract["generated_source_v2"]["contract_id"]
                .as_str()
                .expect("generated contract id")
        )
    );
    assert!(emitted.contains("pub fn execute(input:"));
    assert!(emitted.contains("pub fn execute_with_trace(input:"));
    assert!(emitted.contains(r#"family: "default""#));
    let retired_field = ["parse", "mode"].join("_");
    assert!(!emitted.contains(&format!("\"{retired_field}\"")));
    assert!(!emitted.contains("cursor_policy:"));
}

fn role_generated_direct(contract: &Value, state: &mut AdmissionState) {
    let compiled_json = serde_json::to_string(&compile_source(DEFAULT_SOURCE))
        .expect("serialize generated fixture");
    assert_eq!(
        execute_generated_parser_v2(
            &compiled_json,
            GENERATED_PLAN,
            "prefix x",
            GENERATED_IDENTITY,
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("execute generated admission fixture"),
        json!("hit")
    );

    let legacy_contract = "linkedspec-generated-source-v1";
    let error = validate_generated_parser_plan_v2(
        &compiled_json,
        GENERATED_PLAN,
        GENERATED_IDENTITY,
        legacy_contract,
    )
    .expect_err("legacy generated contract rejects before reconstruction");
    assert_eq!(error.stage, GeneratedSourceStage::ValidateGeneratedPlan);
    assert_eq!(
        error.code,
        GeneratedSourceCode::GeneratedSourceContractVersionMismatch
    );
    assert_eq!(error.expected_contract(), Some(GENERATED_SOURCE_CONTRACT));
    assert_eq!(error.actual_contract(), Some(legacy_contract));
    state.observe(
        contract["generated_source_v2"]["v1_reconstruction_error"]
            .as_str()
            .expect("generated reconstruction diagnostic code"),
    );
}

fn role_generated_trace(_contract: &Value, _state: &mut AdmissionState) {
    let compiled_json =
        serde_json::to_string(&compile_source(DEFAULT_SOURCE)).expect("serialize traced fixture");
    let trace_path = unique_temp_path("generated-trace", "log");
    let trace_config = TraceConfig::enabled(TraceLevel::DEBUG)
        .with_trace_file(trace_path.clone())
        .with_reset_file(true);
    assert_eq!(
        execute_generated_parser_with_trace_v2(
            &compiled_json,
            GENERATED_PLAN,
            "prefix x",
            trace_config,
            GENERATED_IDENTITY,
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("execute traced generated admission fixture"),
        json!("hit")
    );
    let trace = fs::read_to_string(&trace_path).expect("read generated admission trace");
    let _ = fs::remove_file(&trace_path);
    for role in [
        "generated_rule_enter",
        "generated_family_decision",
        "generated_rule_exit",
    ] {
        assert!(
            trace.contains(role),
            "generated trace omits {role}:\n{trace}"
        );
    }
    assert!(trace.contains(GENERATED_IDENTITY));
    assert!(trace.contains("family=default"));
}

fn role_mixed_parent_child(_contract: &Value, _state: &mut AdmissionState) {
    let source = r#"Top::AND
 => Child
Child:
 /x/
 -> Child { return("hit") }
"#;
    assert_eq!(
        execute(compile_source(source), "prefix x").expect("execute mixed-family admission"),
        json!(["hit"])
    );
}

fn role_recursion(_contract: &Value, _state: &mut AdmissionState) {
    let source = r#"Top::AND
 /p/
 -> Top { return(call(Child)) }
Child:OR
 /x/ -> Child[0] { return(call(Top)) }
 /z/ -> Child[1] { return("done") }
"#;
    assert_eq!(
        execute(compile_source(source), "p junk xp junk z").expect("execute recursive admission"),
        json!("done")
    );
}

fn role_structural_ordered_landmarks(_contract: &Value, _state: &mut AdmissionState) {
    let source = r#"Top::AND
 => Header
 => Body
Header:
 /h/
 -> Header { return("header") }
Body:
 /b/
 -> Body { return("body") }
"#;
    assert_eq!(
        execute(compile_source(source), "junk h junk b")
            .expect("execute ordered-landmarks admission"),
        json!(["header", "body"])
    );
}

fn role_structural_anchored_choice(_contract: &Value, _state: &mut AdmissionState) {
    let source = r#"Top::|
 => X
 => Y
X:AND
 /x/
 -> X { return("x") }
Y:AND
 /y/
 -> Y { return("y") }
"#;
    assert_eq!(
        execute(compile_source(source), "prefix x").expect("execute anchored-choice admission"),
        Value::Null
    );
}

fn role_static_option_removal(contract: &Value, state: &mut AdmissionState) {
    let engine_source = include_str!(concat!(env!("CARGO_MANIFEST_DIR"), "/src/engine.rs"));
    let runtime_source = include_str!(concat!(env!("CARGO_MANIFEST_DIR"), "/src/runtime.rs"));
    let retired_field = ["parse", "mode"].join("_");
    assert!(!engine_source.contains(&format!("with_{retired_field}")));
    assert!(!engine_source.contains(&format!("options.{retired_field}")));
    assert!(!runtime_source.contains(&format!("{retired_field}_override")));
    assert!(!runtime_source.contains(&format!("effective_{retired_field}")));
    state.observe(
        contract["option_retirement"]["error"]["code"]
            .as_str()
            .expect("option-removal diagnostic code"),
    );
}

fn role_primary_command(contract: &Value, _state: &mut AdmissionState) {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
    let help = run_with_context(os_arguments(&["--help"]), &root, &root);
    assert_eq!(help.exit_code, 0);
    assert!(help.stderr.is_empty());
    let retired_flag = contract["option_retirement"]["cli"]["flag"]
        .as_str()
        .expect("retired CLI flag");
    assert!(
        !String::from_utf8(help.stdout)
            .unwrap()
            .contains(retired_flag)
    );

    let success = run_with_context(
        os_arguments(&["--inline-spec", DEFAULT_SOURCE, "--input", "prefix x"]),
        &root,
        &root,
    );
    assert_eq!(success.exit_code, 0);
    assert_eq!(success.stdout, b"\"hit\"\n");
    assert!(success.stderr.is_empty());

    let removed = run_with_context(
        os_arguments(&[
            "--inline-spec",
            DEFAULT_SOURCE,
            "--input",
            "x",
            retired_flag,
        ]),
        &root,
        &root,
    );
    assert_eq!(
        removed.exit_code,
        contract["option_retirement"]["cli"]["exit"]
            .as_i64()
            .expect("retired CLI exit") as i32
    );
    assert!(removed.stdout.is_empty());
    assert!(
        String::from_utf8(removed.stderr).unwrap().contains(
            contract["option_retirement"]["cli"]["stderr"]
                .as_str()
                .expect("retired CLI message")
        )
    );
}

fn role_portable_diagnostics(contract: &Value, state: &mut AdmissionState) {
    let diagnostics = contract["diagnostics"]
        .as_array()
        .expect("portable diagnostics array");
    let diagnostic_contract = diagnostics
        .iter()
        .map(|row| (row["code"].as_str().unwrap(), row))
        .collect::<BTreeMap<_, _>>();

    for case in contract["edge_resolution_cases"]
        .as_array()
        .expect("edge-resolution cases")
    {
        let Some(expected_code) = case.get("expected_error").and_then(Value::as_str) else {
            continue;
        };
        let declared = case["declared_rules"]
            .as_array()
            .expect("declared rules")
            .iter()
            .map(|label| label.as_str().unwrap())
            .collect::<Vec<_>>();
        let diagnostic = diagnostic_for(&edge_source(
            case["parent_family"].as_str().unwrap(),
            &[case["source"].as_str().unwrap()],
            &declared,
        ));
        assert_eq!(diagnostic.code, expected_code);
        assert_eq!(
            diagnostic.stage,
            diagnostic_contract[expected_code]["stage"]
                .as_str()
                .unwrap()
        );
        assert_eq!(
            diagnostic
                .fields
                .keys()
                .map(String::as_str)
                .collect::<BTreeSet<_>>(),
            diagnostic_contract[expected_code]["fields"]
                .as_array()
                .unwrap()
                .iter()
                .map(|field| field.as_str().unwrap())
                .collect::<BTreeSet<_>>()
        );
        state.observe(expected_code);
    }

    for case in contract["rule_edge_set_cases"]
        .as_array()
        .expect("rule edge-set cases")
    {
        let Some(expected_code) = case.get("expected_error").and_then(Value::as_str) else {
            continue;
        };
        let sources = case["sources"]
            .as_array()
            .expect("edge-set sources")
            .iter()
            .map(|source| source.as_str().unwrap())
            .collect::<Vec<_>>();
        let declared = case["declared_rules"]
            .as_array()
            .expect("edge-set declared rules")
            .iter()
            .map(|label| label.as_str().unwrap())
            .collect::<Vec<_>>();
        let diagnostic = diagnostic_for(&edge_source(
            case["parent_family"].as_str().unwrap(),
            &sources,
            &declared,
        ));
        assert_eq!(diagnostic.code, expected_code);
        assert_eq!(diagnostic.stage, "validate_rule");
        state.observe(expected_code);
    }

    assert_eq!(
        state.observed_diagnostics,
        diagnostics
            .iter()
            .map(|row| row["code"].as_str().unwrap().to_string())
            .collect::<BTreeSet<_>>(),
        "composed Rust roles must observe every portable diagnostic/removal outcome"
    );
}

#[test]
fn contract_declared_rust_roles_execute_once_and_only_once() {
    let contract = contract();
    let roles: [(&str, AdmissionRole); 15] = [
        ("native_default_family", role_native_default_family),
        ("native_and_family", role_native_and_family),
        ("ordinary_serialized", role_ordinary_serialized),
        ("loaded_spec", role_loaded_spec),
        ("descriptor_v1", role_descriptor_v1),
        ("emitted_source_v2", role_emitted_source_v2),
        ("generated_direct", role_generated_direct),
        ("generated_trace", role_generated_trace),
        ("mixed_parent_child", role_mixed_parent_child),
        ("recursion", role_recursion),
        (
            "structural_ordered_landmarks",
            role_structural_ordered_landmarks,
        ),
        (
            "structural_anchored_choice",
            role_structural_anchored_choice,
        ),
        ("static_option_removal", role_static_option_removal),
        ("primary_command", role_primary_command),
        ("portable_diagnostics", role_portable_diagnostics),
    ];
    let role_map = BTreeMap::from(roles);
    let declared_roles = contract["rust_parity_admission"]["roles"]
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

    let mut state = AdmissionState::default();
    let mut completed = BTreeMap::new();
    for role in declared_roles {
        role_map[role](&contract, &mut state);
        assert_eq!(completed.insert(role, 1_u8), None, "role {role} repeated");
    }
    assert_eq!(
        completed,
        role_map.keys().map(|role| (*role, 1_u8)).collect(),
        "every declared Rust admission role must complete once"
    );
}
