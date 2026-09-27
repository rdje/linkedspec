//! Bounded nesting readiness across public Rust native and generated carriers.
use linkedspec_core::compiler::compile;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, GeneratedRuleSpec, classify_generated_rule_family,
    emit_rust_source_v2, execute_generated_parser_with_diagnostic_output_v2,
    validate_generated_parser_plan_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;
use std::fs;
use std::path::PathBuf;
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

#[path = "../../../tests/language-readiness/nested-tree/rust_checks.rs"]
mod checks;

const SOURCE: &str = include_str!("../../../tests/language-readiness/nested-tree/grammar.spec");
const CASES: &str = include_str!("../../../tests/language-readiness/nested-tree/cases.json");
const CHECKS: &str = include_str!("../../../tests/language-readiness/nested-tree/rust_checks.rs");
const LABELS: [&str; 5] = ["Top", "List", "Atom", "Space", "Invalid"];

fn compiled(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse readiness source");
    validate(&parsed).expect("validate readiness source");
    compile(&parsed).expect("compile readiness source")
}

fn variants() -> Vec<(&'static str, String)> {
    let prefix = concat!(
        " if(matches(input_slice(0, cursor_pos()), /[^ \\t\\r\\n\\f\\x0B]/));\n",
        "  exit_now(1);\n endif();\n"
    );
    let gap = " -> Invalid { exit_now(1) }\n";
    let span = "[start, cursor_pos()]";
    assert_eq!(SOURCE.matches(prefix).count(), 1);
    assert_eq!(SOURCE.matches(gap).count(), 2);
    assert_eq!(SOURCE.matches(span).count(), 1);
    vec![
        ("original", SOURCE.to_owned()),
        ("prefix", SOURCE.replace(prefix, "")),
        ("gap", SOURCE.replace(gap, "")),
        ("span", SOURCE.replace(span, "[cursor_pos(), cursor_pos()]")),
    ]
}

fn plans(compiled: &CompiledSpec) -> (Vec<GeneratedRuleSpec>, Vec<GeneratedPlanRow>) {
    assert_eq!(compiled.rules.len(), LABELS.len());
    let mut rules = Vec::new();
    let mut rows = Vec::new();
    for (rule, label) in compiled.rules.iter().zip(LABELS) {
        assert_eq!(rule.label, label, "authored rule order remains exact");
        let family = classify_generated_rule_family(rule);
        rules.push(GeneratedRuleSpec { label, family });
        rows.push(GeneratedPlanRow {
            label,
            family: family.contract_name(),
        });
    }
    (rules, rows)
}

fn check_variant(id: &str, cases: &Value, parse: impl FnMut(&str) -> Option<Value>) {
    if id == "original" {
        assert_eq!(checks::sequence(cases, parse), 40);
    } else {
        checks::mutation(id, cases, parse);
    }
}

#[test]
fn native_reconstructed_and_generated_routes_preserve_values_and_typed_recovery() {
    let cases: Value = serde_json::from_str(CASES).unwrap();
    let options = ExecutionOptions::new();
    for (id, source) in variants() {
        let compiled = compiled(&source);
        let encoded = serde_json::to_string(&compiled).unwrap();
        let restored: CompiledSpec = serde_json::from_str(&encoded).unwrap();
        let (rules, plan) = plans(&compiled);
        validate_generated_parser_plan_v2(&encoded, &plan, id, GENERATED_SOURCE_CONTRACT).unwrap();
        for carrier in [compiled, restored] {
            let engine = Engine::new(carrier);
            // These four routes retain an engine throughout the sequence, including rejection.
            check_variant(id, &cases, |input| {
                checks::native_result(
                    engine.execute_value_with_diagnostic_output(input, &options, None),
                )
            });
            check_variant(id, &cases, |input| {
                checks::native_result(
                    engine.execute_generated_value_with_plan_with_diagnostic_output(
                        &rules, input, None,
                    ),
                )
            });
        }
        // The public serialized entry reconstructs an engine per call. Do not claim retained-engine recovery.
        check_variant(id, &cases, |input| {
            checks::generated_result(execute_generated_parser_with_diagnostic_output_v2(
                &encoded,
                &plan,
                input,
                id,
                GENERATED_SOURCE_CONTRACT,
                None,
            ))
        });
    }
    println!(
        "nested-tree Rust: 5 in-process routes; 40 original executions and 3 mutations per route"
    );
}

struct LocalCrate(PathBuf);

impl LocalCrate {
    fn new(root: &std::path::Path) -> Self {
        let base = root.join(".linkedspec-data/scratch");
        fs::create_dir_all(&base).expect("create project-local scratch parent");
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_nanos();
        let path = base.join(format!("nested-tree-rust-{}-{nanos}", std::process::id()));
        // Never remove a pre-existing directory in an attempt to claim it.
        fs::create_dir(&path).expect("create exclusively owned emitted crate");
        fs::create_dir(path.join("src")).unwrap();
        Self(path)
    }
}

impl Drop for LocalCrate {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.0);
    }
}

#[test]
fn fresh_emitted_modules_preserve_original_oracles_and_mutation_sensitivity() {
    let root = PathBuf::from(
        std::env::var_os("LINKEDSPEC_REPO_ROOT").expect("run through tools/run_cargo_local.sh"),
    );
    let project = LocalCrate::new(&root);
    fs::write(
        project.0.join("Cargo.toml"),
        r#"[package]
name = "nested-tree-readiness-emitted"
version = "0.0.0"
edition = "2024"

[workspace]

[dependencies]
linkedspec-runtime = { path = "../../../rust/linkedspec-runtime" }
serde_json = "1"
"#,
    )
    .unwrap();
    // Start with repository-pinned dependencies; only this owned child lockfile may be resolved.
    fs::copy(root.join("rust/Cargo.lock"), project.0.join("Cargo.lock")).unwrap();
    fs::write(project.0.join("cases.json"), CASES).unwrap();
    fs::write(project.0.join("src/checks.rs"), CHECKS).unwrap();
    let mut harness = String::from("#![allow(dead_code)]\nmod checks;\n");
    for (id, source) in variants() {
        let module = emit_rust_source_v2(&compiled(&source), &format!("nested-tree/{id}")).unwrap();
        fs::write(project.0.join(format!("src/{id}.rs")), module).unwrap();
        harness.push_str(&format!(r#"
mod {id};
#[test]
fn check_{id}() {{
    let cases: serde_json::Value = serde_json::from_str(include_str!("../cases.json")).unwrap();
    let metadata = {id}::metadata();
    assert_eq!(metadata.contract_id, "linkedspec-generated-source-v2");
    assert_eq!(metadata.format_version, 2);
    assert_eq!(metadata.source_identity, "nested-tree/{id}");
    {id}::validate_plan({id}::plan()).unwrap();
    let parse = |input: &str| checks::generated_result({id}::execute_with_diagnostic_output(input, None));
"#));
        if id == "original" {
            harness.push_str("    assert_eq!(checks::sequence(&cases, parse), 40);\n}\n");
        } else {
            harness.push_str(&format!(
                "    checks::mutation(\"{id}\", &cases, parse);\n}}\n"
            ));
        }
    }
    fs::write(project.0.join("src/lib.rs"), harness).unwrap();
    let target = root.join(".linkedspec-data/cache/nested-tree-rust-emitted-target");
    let cargo = std::env::var_os("LINKEDSPEC_CARGO_CMD").unwrap_or_else(|| "cargo".into());
    let output = Command::new(cargo)
        .args(["test", "--offline", "--quiet", "--color", "never"])
        .env("CARGO_TARGET_DIR", target)
        .current_dir(&project.0)
        .output()
        .expect("compile and execute the independent emitted modules");
    assert!(
        output.status.success(),
        "emitted child failed: {}\nstdout:\n{}\nstderr:\n{}",
        output.status,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
    let stdout = String::from_utf8(output.stdout).unwrap();
    assert_eq!(
        stdout.matches("4 passed; 0 failed;").count(),
        1,
        "all four emitted checks must actually execute: {stdout}"
    );
    println!(
        "nested-tree emitted Rust: child exit0; 4 tests; 40 original executions and 3 mutations"
    );
}
