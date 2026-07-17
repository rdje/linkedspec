//! FUTURE-PARITY-BACKLOG.5.2.3 — Rust logical-helper contract.

use linkedspec_core::compiler::compile;
use linkedspec_core::types::{CompiledSpec, RuntimeValue};
use linkedspec_core::validation::validate;
use linkedspec_runtime::diagnostic::RuntimeExecutionError;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GeneratedPlanRow, emit_rust_source_v1, execute_generated_parser_v1,
    validate_generated_parser_plan_v1,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

const CONTRACT_JSON: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../capability_conformance/logical_helper_contract.json"
));

const TOP_PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
    label: "Top",
    family: "default",
}];

fn contract() -> Value {
    serde_json::from_str(CONTRACT_JSON).expect("logical-helper contract JSON")
}

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse logical-helper fixture");
    validate(&parsed).expect("validate logical-helper fixture");
    compile(&parsed).expect("compile logical-helper fixture")
}

fn runtime_value(value: &Value) -> Option<RuntimeValue> {
    match value["kind"].as_str().expect("typed value kind") {
        "null" => Some(RuntimeValue::Undef),
        "boolean" => Some(RuntimeValue::Bool(
            value["value"].as_bool().expect("boolean payload"),
        )),
        "number" => Some(RuntimeValue::Number(
            value["value"].as_f64().expect("number payload"),
        )),
        "string" => Some(RuntimeValue::Scalar(
            value["value"].as_str().expect("string payload").to_string(),
        )),
        "array" => Some(RuntimeValue::Array(
            value["items"]
                .as_array()
                .expect("array payload")
                .iter()
                .map(|item| runtime_value(item).expect("nested runtime value"))
                .collect(),
        )),
        "harray" => Some(RuntimeValue::Hash(
            value["entries"]
                .as_object()
                .expect("harray payload")
                .iter()
                .map(|(key, item)| {
                    (
                        key.clone(),
                        runtime_value(item).expect("nested runtime value"),
                    )
                })
                .collect(),
        )),
        "codeblock" => None,
        kind => panic!("unknown neutral value kind {kind}"),
    }
}

fn assert_arity_error(error: &RuntimeExecutionError, case: &Value) {
    let diagnostic = error.diagnostic();
    let helper_name = case["helper_name"].as_str().expect("helper name");
    let actual_arity = case["actual_arity"].as_u64().expect("actual arity") as usize;
    let expected_arity = case["expected_arity"].as_str().expect("expected arity");

    assert_eq!(diagnostic.stage, "helper_arity_mismatch");
    assert_eq!(diagnostic.code.as_deref(), Some("helper_arity_mismatch"));
    assert_eq!(diagnostic.helper_name.as_deref(), Some(helper_name));
    assert_eq!(diagnostic.actual_arity, Some(actual_arity));
    assert_eq!(diagnostic.expected_arity.as_deref(), Some(expected_arity));
    assert_eq!(diagnostic.rule_label.as_deref(), Some("Top"));
    assert!(
        error.message().contains("helper_arity_mismatch"),
        "{}",
        error.message()
    );
    assert!(
        error
            .message()
            .contains(&format!("helper_name={helper_name}")),
        "{}",
        error.message()
    );
    assert!(
        error
            .message()
            .contains(&format!("actual_arity={actual_arity}")),
        "{}",
        error.message()
    );
    assert!(
        error
            .message()
            .contains(&format!("expected_arity={expected_arity:?}")),
        "{}",
        error.message()
    );
}

#[test]
fn every_representable_neutral_value_uses_one_typed_truth_seam() {
    let contract = contract();
    assert_eq!(contract["contract_id"], "linkedspec-logical-helper-v1");

    for case in contract["truthiness_cases"]
        .as_array()
        .expect("truthiness cases")
    {
        let Some(value) = runtime_value(&case["value"]) else {
            assert_eq!(case["id"], "codeblock");
            continue;
        };
        assert_eq!(
            value.as_bool(),
            case["expected"].as_bool().expect("truth expectation"),
            "{}",
            case["id"]
        );
    }
}

#[test]
fn neutral_fixtures_match_native_serialized_and_generated_plan_execution() {
    let contract = contract();
    for fixture_id in ["values", "effects", "receiver_and_lazy_control"] {
        let fixture = &contract["fixtures"][fixture_id];
        let source = fixture["spec_source"].as_str().expect("fixture source");
        let expected = fixture["expected"].clone();
        let compiled = compile_source(source);

        assert_eq!(
            Engine::new(compiled.clone())
                .execute_value("x", &ExecutionOptions::new())
                .unwrap_or_else(|error| panic!("native {fixture_id}: {error}")),
            expected,
            "native {fixture_id}"
        );

        let compiled_json = serde_json::to_string(&compiled).expect("serialize compiled fixture");
        let decoded: CompiledSpec =
            serde_json::from_str(&compiled_json).expect("deserialize compiled fixture");
        assert_eq!(
            Engine::new(decoded)
                .execute_value("x", &ExecutionOptions::new())
                .unwrap_or_else(|error| panic!("serialized {fixture_id}: {error}")),
            expected,
            "serialized {fixture_id}"
        );

        let identity = format!("logical-helper/{fixture_id}.spec");
        let emitted = emit_rust_source_v1(&compiled, &identity).expect("emit Rust fixture");
        assert!(emitted.contains("linkedspec-generated-source-v1"));
        validate_generated_parser_plan_v1(&compiled_json, TOP_PLAN, &identity)
            .expect("validate generated logical plan");
        assert_eq!(
            execute_generated_parser_v1(&compiled_json, TOP_PLAN, "x", &identity)
                .unwrap_or_else(|error| panic!("generated-plan {fixture_id}: {error}")),
            expected,
            "generated-plan {fixture_id}"
        );
    }
}

#[test]
fn invalid_arity_precedes_effects_with_exact_native_and_generated_fields() {
    let contract = contract();
    let cases = contract["invalid_arity_cases"]
        .as_array()
        .expect("invalid arity cases");
    let fixtures = contract["fixtures"]["invalid_arity"]
        .as_array()
        .expect("invalid arity fixtures");

    for fixture in fixtures {
        let id = fixture["id"].as_str().expect("fixture id");
        let case = cases
            .iter()
            .find(|case| case["id"] == id)
            .expect("matching invalid arity case");
        let compiled = compile_source(fixture["spec_source"].as_str().expect("fixture source"));

        let native = Engine::new(compiled.clone())
            .execute_value_with_diagnostics("x", &ExecutionOptions::new())
            .expect_err("native invalid arity must fail");
        assert_arity_error(&native, case);

        let compiled_json = serde_json::to_string(&compiled).expect("serialize invalid fixture");
        let decoded: CompiledSpec =
            serde_json::from_str(&compiled_json).expect("deserialize invalid fixture");
        let serialized = Engine::new(decoded)
            .execute_value_with_diagnostics("x", &ExecutionOptions::new())
            .expect_err("serialized invalid arity must fail");
        assert_arity_error(&serialized, case);

        let identity = format!("logical-helper/{id}.spec");
        let generated = execute_generated_parser_v1(&compiled_json, TOP_PLAN, "x", &identity)
            .expect_err("generated invalid arity must fail");
        let detail = generated.detail.as_deref().unwrap_or_default();
        assert!(detail.contains("helper_arity_mismatch"), "{id}: {detail}");
        assert!(
            detail.contains(&format!(
                "helper_name={}",
                case["helper_name"].as_str().expect("helper name")
            )),
            "{id}: {detail}"
        );
        assert!(
            detail.contains(&format!(
                "actual_arity={}",
                case["actual_arity"].as_u64().expect("actual arity")
            )),
            "{id}: {detail}"
        );
        assert!(!detail.contains("must not run"), "{id}: {detail}");
    }
}

struct TempProject {
    root: PathBuf,
}

impl TempProject {
    fn new() -> Self {
        let nonce = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("system clock")
            .as_nanos();
        let root = std::env::temp_dir().join(format!(
            "linkedspec-logical-helper-emitted-{}-{nonce}",
            std::process::id()
        ));
        fs::create_dir_all(root.join("src")).expect("create emitted-source project");
        Self { root }
    }

    fn path(&self) -> &Path {
        &self.root
    }
}

impl Drop for TempProject {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

fn rust_string_literal(value: &str) -> String {
    format!("{value:?}")
}

#[test]
fn standalone_emitted_modules_compile_and_run_values_effects_receivers_and_arity() {
    let contract = contract();
    let mut modules = String::new();
    let mut expected_literals = Vec::new();

    for fixture_id in ["values", "effects", "receiver_and_lazy_control"] {
        let fixture = &contract["fixtures"][fixture_id];
        let compiled = compile_source(fixture["spec_source"].as_str().expect("fixture source"));
        let emitted = emit_rust_source_v1(&compiled, &format!("logical-helper/{fixture_id}.spec"))
            .expect("emit standalone fixture");
        modules.push_str(&format!("pub mod {fixture_id} {{\n{emitted}\n}}\n"));
        expected_literals.push((
            fixture_id,
            rust_string_literal(
                &serde_json::to_string(&fixture["expected"]).expect("serialize expected value"),
            ),
        ));
    }

    let invalid_fixture = contract["fixtures"]["invalid_arity"]
        .as_array()
        .expect("invalid fixtures")
        .iter()
        .find(|fixture| fixture["id"] == "not_many")
        .expect("not_many fixture");
    let invalid_compiled = compile_source(
        invalid_fixture["spec_source"]
            .as_str()
            .expect("invalid fixture source"),
    );
    let invalid_emitted =
        emit_rust_source_v1(&invalid_compiled, "logical-helper/not_many-emitted.spec")
            .expect("emit invalid standalone fixture");
    modules.push_str(&format!(
        "pub mod invalid_not_many {{\n{invalid_emitted}\n}}\n"
    ));

    let assertions = expected_literals
        .iter()
        .map(|(fixture_id, expected)| {
            format!(
                r#"let expected: serde_json::Value = serde_json::from_str({expected}).unwrap();
        assert_eq!(super::{fixture_id}::execute("x").unwrap(), expected);"#
            )
        })
        .collect::<Vec<_>>()
        .join("\n        ");
    modules.push_str(&format!(
        r#"
#[cfg(test)]
mod emitted_contract_tests {{
    #[test]
    fn emitted_contract_is_exact() {{
        {assertions}
        let error = super::invalid_not_many::execute("x").unwrap_err();
        let detail = error.detail.as_deref().unwrap_or_default();
        assert!(detail.contains("helper_arity_mismatch"), "{{detail}}");
        assert!(detail.contains("helper_name=not"), "{{detail}}");
        assert!(detail.contains("actual_arity=2"), "{{detail}}");
        assert!(!detail.contains("must not run"), "{{detail}}");
    }}
}}
"#
    ));

    let project = TempProject::new();
    let runtime_manifest = Path::new(env!("CARGO_MANIFEST_DIR"));
    fs::write(
        project.path().join("Cargo.toml"),
        format!(
            r#"[package]
name = "linkedspec_logical_helper_emitted"
version = "0.0.0"
edition = "2024"

[dependencies]
linkedspec-runtime = {{ path = "{}" }}
serde_json = "1"
"#,
            runtime_manifest.display()
        ),
    )
    .expect("write emitted-source Cargo.toml");
    fs::write(project.path().join("src/lib.rs"), modules).expect("write emitted-source module");

    let output = Command::new("cargo")
        .arg("test")
        .arg("--offline")
        .arg("--quiet")
        .env("CARGO_TARGET_DIR", project.path().join("target"))
        .current_dir(project.path())
        .output()
        .expect("run emitted-source cargo test");
    assert!(
        output.status.success(),
        "standalone emitted-source test failed\nstatus: {}\nstdout:\n{}\nstderr:\n{}",
        output.status,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
}
