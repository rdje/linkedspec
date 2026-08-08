//! FUTURE-PARITY-BACKLOG.14.2.2.0.2 — Rust source-boundary compatibility aliases.

use linkedspec_core::compiler::compile;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, emit_rust_source_v2, execute_generated_parser_v2,
    validate_generated_parser_plan_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

const INPUT: &str = "é🙂  ab";

const ALIAS_NORMAL_SOURCE: &str = r#"Top::OR{1,1}
 /ab/
 I { started = capture_slice_here() }
 E { return(array(started, capture_from_rule_start(), capture_len_from_rule_start(), capture_slice_length(), capture_rest_length())) }
"#;

const CANONICAL_NORMAL_SOURCE: &str = r#"Top::OR{1,1}
 /ab/
 I { started = start_capture_slice() }
 E { return(array(started, capture_slice(), capture_slice_len(), capture_slice_len(), capture_rest_len())) }
"#;

const ALIAS_REVERSED_SOURCE: &str = r#"Top::OR{1,1}
 /ab/
 E { started = capture_slice_here(); return(array(started, capture_from_rule_start(), capture_len_from_rule_start(), capture_slice_length(), capture_rest_length())) }
"#;

const CANONICAL_REVERSED_SOURCE: &str = r#"Top::OR{1,1}
 /ab/
 E { started = start_capture_slice(); return(array(started, capture_slice(), capture_slice_len(), capture_slice_len(), capture_rest_len())) }
"#;

const TOP_PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
    label: "Top",
    family: "rep_acode",
}];

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse source-boundary fixture");
    validate(&parsed).expect("validate source-boundary fixture");
    compile(&parsed).expect("compile source-boundary fixture")
}

fn assert_runtime_carriers(source: &str, identity: &str, expected: &Value) -> CompiledSpec {
    let compiled = compile_source(source);
    assert_eq!(
        Engine::new(compiled.clone())
            .execute_value(INPUT, &ExecutionOptions::new())
            .expect("execute native source-boundary fixture"),
        *expected,
        "native carrier for {identity}"
    );

    let compiled_json =
        serde_json::to_string(&compiled).expect("serialize source-boundary fixture");
    let reconstructed: CompiledSpec =
        serde_json::from_str(&compiled_json).expect("reconstruct source-boundary fixture");
    assert_eq!(
        Engine::new(reconstructed)
            .execute_value(INPUT, &ExecutionOptions::new())
            .expect("execute reconstructed source-boundary fixture"),
        *expected,
        "serialized carrier for {identity}"
    );

    validate_generated_parser_plan_v2(
        &compiled_json,
        TOP_PLAN,
        identity,
        GENERATED_SOURCE_CONTRACT,
    )
    .expect("validate generated source-boundary plan");
    assert_eq!(
        execute_generated_parser_v2(
            &compiled_json,
            TOP_PLAN,
            INPUT,
            identity,
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("execute generated source-boundary plan"),
        *expected,
        "generated-plan carrier for {identity}"
    );
    compiled
}

struct GeneratedTestProject {
    root: PathBuf,
}

impl GeneratedTestProject {
    fn new() -> Self {
        let nonce = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("system clock")
            .as_nanos();
        let root = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("../target/test-workspaces")
            .join(format!(
                "source-boundary-aliases-emitted-{}-{nonce}",
                std::process::id()
            ));
        fs::create_dir_all(root.join("src")).expect("create emitted-source workspace");
        Self { root }
    }
}

impl Drop for GeneratedTestProject {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

fn assert_independently_compiled_emitted_sources(fixtures: &[(&str, CompiledSpec, Value)]) {
    let mut modules = String::new();
    let mut assertions = String::new();
    for (module, compiled, expected) in fixtures {
        let identity = format!("source-boundary/{module}.spec");
        let emitted =
            emit_rust_source_v2(compiled, &identity).expect("emit source-boundary module");
        modules.push_str(&format!("pub mod {module} {{\n{emitted}\n}}\n"));
        let expected = serde_json::to_string(expected).expect("serialize expected value");
        assertions.push_str(&format!(
            "assert_eq!(super::{module}::execute({INPUT:?}).unwrap(), serde_json::from_str::<serde_json::Value>({expected:?}).unwrap());\n        "
        ));
    }
    modules.push_str(&format!(
        r#"
#[cfg(test)]
mod emitted_source_boundary_tests {{
    #[test]
    fn compatibility_aliases_match_their_canonical_helpers() {{
        {assertions}
    }}
}}
"#
    ));

    let project = GeneratedTestProject::new();
    fs::write(
        project.root.join("Cargo.toml"),
        r#"[package]
name = "linkedspec_source_boundary_aliases_emitted"
version = "0.0.0"
edition = "2024"

[dependencies]
linkedspec-runtime = { path = "../../../linkedspec-runtime" }
serde_json = "1"

[workspace]
"#,
    )
    .expect("write emitted-source manifest");
    fs::write(project.root.join("src/lib.rs"), modules).expect("write emitted-source module");

    let output = Command::new("cargo")
        .arg("test")
        .arg("--offline")
        .arg("--quiet")
        .env("CARGO_TARGET_DIR", project.root.join("target"))
        .current_dir(&project.root)
        .output()
        .expect("run independently compiled emitted-source test");
    assert!(
        output.status.success(),
        "independently compiled emitted-source test failed\nstatus: {}\nstdout:\n{}\nstderr:\n{}",
        output.status,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
}

#[test]
fn five_compatibility_aliases_match_canonical_helpers_across_all_rust_carriers() {
    let normal = json!([null, "é🙂  ", 4, 4, 6]);
    let reversed = json!([null, null, null, null, 0]);

    let alias_normal = assert_runtime_carriers(
        ALIAS_NORMAL_SOURCE,
        "source-boundary/alias-normal.spec",
        &normal,
    );
    let canonical_normal = assert_runtime_carriers(
        CANONICAL_NORMAL_SOURCE,
        "source-boundary/canonical-normal.spec",
        &normal,
    );
    let alias_reversed = assert_runtime_carriers(
        ALIAS_REVERSED_SOURCE,
        "source-boundary/alias-reversed.spec",
        &reversed,
    );
    let canonical_reversed = assert_runtime_carriers(
        CANONICAL_REVERSED_SOURCE,
        "source-boundary/canonical-reversed.spec",
        &reversed,
    );

    assert_independently_compiled_emitted_sources(&[
        ("alias_normal", alias_normal, normal.clone()),
        ("canonical_normal", canonical_normal, normal),
        ("alias_reversed", alias_reversed, reversed.clone()),
        ("canonical_reversed", canonical_reversed, reversed),
    ]);
}
