//! FUTURE-PARITY-BACKLOG.3.2.0 — full-manifest generated-source classifier.
//!
//! This strict recurring breadth gate runs with the runtime package tests. It
//! can also be run independently with:
//!
//! ```text
//! cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime \
//!   --test generated_source_full_manifest_classifier -- --nocapture
//! ```
//!
//! Every manifest case receives one deterministic terminal classification. A
//! failed case does not prevent later cases from reaching their own stage.

use linkedspec_core::compiler::compile;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::emit_rust_source_v1;
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde::Deserialize;
use serde_json::{Value, json};
use std::collections::BTreeSet;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, Output};
use std::time::{SystemTime, UNIX_EPOCH};

const FULL_MANIFEST_CASE_COUNT: usize = 105;
const COMPLETED_STAGES: &str =
    "read,parse,validate,compile,interpreter_oracle,emit_source,host_compile,host_run";

#[derive(Debug, Deserialize)]
struct CorpusManifest {
    format: u64,
    case_count: usize,
    cases: Vec<String>,
}

#[derive(Debug)]
struct CaseFailure {
    stage: &'static str,
    detail: String,
}

impl CaseFailure {
    fn new(stage: &'static str, detail: impl Into<String>) -> Self {
        Self {
            stage,
            detail: detail.into(),
        }
    }
}

struct PreparedCase {
    generated_source: String,
    input: String,
    direct_expected: Value,
    compatibility_expected: Value,
}

struct TempProject {
    root: PathBuf,
}

impl TempProject {
    fn new() -> Self {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("system time should be after the Unix epoch")
            .as_nanos();
        let root = std::env::temp_dir().join(format!(
            "linkedspec-generated-full-manifest-{}-{nanos}",
            std::process::id()
        ));
        fs::create_dir_all(root.join("src")).expect("create generated classifier project");

        let runtime_manifest = Path::new(env!("CARGO_MANIFEST_DIR"));
        fs::write(
            root.join("Cargo.toml"),
            format!(
                r#"[package]
name = "linkedspec-generated-full-manifest"
version = "0.0.0"
edition = "2024"

[dependencies]
linkedspec-runtime = {{ path = "{}" }}
serde_json = "1"
"#,
                runtime_manifest.display()
            ),
        )
        .expect("write generated classifier Cargo.toml");

        Self { root }
    }

    fn write_cases(&self, cases: &[(String, PreparedCase)]) -> Result<(), CaseFailure> {
        let generated_dir = self.root.join("src/generated");
        fs::create_dir_all(&generated_dir)
            .map_err(|error| CaseFailure::new("emit_source", error.to_string()))?;
        let mut library = String::new();

        for (case_name, prepared) in cases {
            let module = format!("corpus_{case_name}");
            library.push_str(&format!(
                "#[path = \"generated/{case_name}.rs\"]\npub mod {module};\n"
            ));

            let input_literal = serde_json::to_string(&prepared.input)
                .map_err(|error| CaseFailure::new("emit_source", error.to_string()))?;
            let direct_expected = serde_json::to_string(&prepared.direct_expected)
                .map_err(|error| CaseFailure::new("emit_source", error.to_string()))?;
            let compatibility_expected = serde_json::to_string(&prepared.compatibility_expected)
                .map_err(|error| CaseFailure::new("emit_source", error.to_string()))?;
            let direct_expected_literal = serde_json::to_string(&direct_expected)
                .map_err(|error| CaseFailure::new("emit_source", error.to_string()))?;
            let compatibility_expected_literal = serde_json::to_string(&compatibility_expected)
                .map_err(|error| CaseFailure::new("emit_source", error.to_string()))?;

            let source = format!(
                r#"{generated_source}

#[cfg(test)]
mod generated_classifier_tests {{
    #[test]
    fn generated_case_matches_oracle() {{
        let actual = super::execute({input_literal})
            .expect("generated classifier parser should execute");
        let expected: serde_json::Value = serde_json::from_str({direct_expected_literal})
            .expect("direct expected JSON should parse");
        assert_eq!(actual, expected, "direct result drift for {case_name}");

        let plan = super::plan();
        super::validate_plan(plan).expect("embedded neutral plan should validate");

        let compatibility = super::parse({input_literal})
            .expect("generated compatibility parser should execute");
        let compatibility_expected: serde_json::Value =
            serde_json::from_str({compatibility_expected_literal})
                .expect("compatibility expected JSON should parse");
        assert_eq!(
            compatibility, compatibility_expected,
            "compatibility result drift for {case_name}"
        );
        println!("HOST_RUN_PASS {case_name}");
    }}
}}
"#,
                generated_source = prepared.generated_source,
            );
            fs::write(generated_dir.join(format!("{case_name}.rs")), source)
                .map_err(|error| CaseFailure::new("emit_source", error.to_string()))?;
        }

        fs::write(self.root.join("src/lib.rs"), library)
            .map_err(|error| CaseFailure::new("emit_source", error.to_string()))
    }

    fn cargo(&self, args: &[&str]) -> Result<Output, CaseFailure> {
        Command::new("cargo")
            .arg("--offline")
            .arg("--quiet")
            .args(args)
            .env("CARGO_TARGET_DIR", self.root.join("target"))
            .current_dir(&self.root)
            .output()
            .map_err(|error| CaseFailure::new("host_compile", error.to_string()))
    }
}

impl Drop for TempProject {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

fn corpus_dir() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/corpus")
}

fn read_utf8(path: &Path, stage: &'static str) -> Result<String, CaseFailure> {
    fs::read_to_string(path).map_err(|error| {
        CaseFailure::new(stage, format!("cannot read {}: {error}", path.display()))
    })
}

fn load_manifest(dir: &Path) -> CorpusManifest {
    let path = dir.join("manifest.json");
    let text = read_utf8(&path, "read").unwrap_or_else(|failure| {
        panic!("{}: {}", failure.stage, failure.detail);
    });
    let manifest: CorpusManifest = serde_json::from_str(&text)
        .unwrap_or_else(|error| panic!("malformed {}: {error}", path.display()));

    assert_eq!(manifest.format, 1, "unsupported corpus manifest format");
    assert_eq!(
        manifest.case_count,
        manifest.cases.len(),
        "manifest case_count does not match cases length"
    );
    assert_eq!(
        manifest.case_count, FULL_MANIFEST_CASE_COUNT,
        "update the generated-source full-manifest contract when the primary corpus changes"
    );
    let names: BTreeSet<&str> = manifest.cases.iter().map(String::as_str).collect();
    assert_eq!(
        names.len(),
        manifest.cases.len(),
        "manifest contains duplicate case names"
    );
    manifest
}

fn prepare_case(dir: &Path, case_name: &str) -> Result<PreparedCase, CaseFailure> {
    let source = read_utf8(&dir.join("input.spec"), "read")?;
    let input = read_utf8(&dir.join("input.txt"), "read")?;
    let expected_text = read_utf8(&dir.join("expected.json"), "read")?;
    let direct_expected: Value = serde_json::from_str(&expected_text)
        .map_err(|error| CaseFailure::new("read", format!("malformed expected.json: {error}")))?;
    let compatibility_expected = json!([direct_expected.clone()]);

    let parsed = parse_spec_with_user_functions(&source)
        .map_err(|error| CaseFailure::new("parse", error))?;
    validate(&parsed).map_err(|error| CaseFailure::new("validate", error.to_string()))?;
    let compiled =
        compile(&parsed).map_err(|error| CaseFailure::new("compile", error.to_string()))?;

    let compatibility_actual = Engine::new(compiled.clone())
        .execute(&input)
        .map_err(|error| CaseFailure::new("interpreter_oracle", error))?;
    if compatibility_actual != compatibility_expected {
        return Err(CaseFailure::new(
            "interpreter_oracle",
            format!(
                "compatibility result mismatch: expected {compatibility_expected}, got {compatibility_actual}"
            ),
        ));
    }

    let direct_actual = Engine::new(compiled.clone())
        .execute_value(&input, &ExecutionOptions::new())
        .map_err(|error| CaseFailure::new("interpreter_oracle", error))?;
    if direct_actual != direct_expected {
        return Err(CaseFailure::new(
            "interpreter_oracle",
            format!("direct result mismatch: expected {direct_expected}, got {direct_actual}"),
        ));
    }

    let identity = format!("corpus/{case_name}/input.spec");
    let generated_source = emit_rust_source_v1(&compiled, &identity)
        .map_err(|error| CaseFailure::new("emit_source", error.to_string()))?;

    Ok(PreparedCase {
        generated_source,
        input,
        direct_expected,
        compatibility_expected,
    })
}

fn cargo_failure_detail(output: &Output) -> String {
    format!(
        "status={} stdout={} stderr={}",
        output.status,
        String::from_utf8_lossy(&output.stdout).trim(),
        String::from_utf8_lossy(&output.stderr).trim()
    )
}

fn record_failure(
    failures: &mut Vec<(String, &'static str)>,
    case_name: &str,
    failure: &CaseFailure,
) {
    println!("CLASSIFY {case_name} FAIL stage={}", failure.stage);
    println!("  detail: {}", failure.detail);
    failures.push((case_name.to_string(), failure.stage));
}

#[test]
fn classify_all_generated_source_manifest_cases() {
    let dir = corpus_dir();
    assert!(dir.is_dir(), "corpus directory missing: {}", dir.display());
    let manifest = load_manifest(&dir);
    let project = TempProject::new();
    let mut failures = Vec::new();
    let mut prepared_cases = Vec::new();
    let mut passed = 0;

    for case_name in &manifest.cases {
        let case_dir = dir.join(case_name);
        match prepare_case(&case_dir, case_name) {
            Ok(prepared) => prepared_cases.push((case_name.clone(), prepared)),
            Err(failure) => record_failure(&mut failures, case_name, &failure),
        }
    }

    if let Err(failure) = project.write_cases(&prepared_cases) {
        for (case_name, _) in &prepared_cases {
            record_failure(&mut failures, case_name, &failure);
        }
    } else {
        let compile_output = project
            .cargo(&["test", "--no-run"])
            .expect("launch isolated full-manifest host compiler");
        if !compile_output.status.success() {
            let failure = CaseFailure::new("host_compile", cargo_failure_detail(&compile_output));
            for (case_name, _) in &prepared_cases {
                record_failure(&mut failures, case_name, &failure);
            }
        } else {
            let run_output = project
                .cargo(&["test", "--", "--nocapture", "--test-threads=1"])
                .expect("launch isolated full-manifest generated tests");
            let stdout = String::from_utf8_lossy(&run_output.stdout);
            let passed_host_cases: BTreeSet<&str> = stdout
                .lines()
                .filter_map(|line| {
                    line.split_once("HOST_RUN_PASS ")
                        .map(|(_, case_name)| case_name.trim())
                })
                .collect();
            let run_detail = cargo_failure_detail(&run_output);

            for (case_name, _) in &prepared_cases {
                if passed_host_cases.contains(case_name.as_str()) {
                    println!("CLASSIFY {case_name} PASS stages={COMPLETED_STAGES}");
                    passed += 1;
                } else {
                    let failure = CaseFailure::new("host_run", run_detail.clone());
                    record_failure(&mut failures, case_name, &failure);
                }
            }
        }
    }

    println!(
        "CLASSIFY SUMMARY total={} pass={} fail={}",
        manifest.case_count,
        passed,
        failures.len()
    );
    for (case_name, stage) in &failures {
        println!("CLASSIFY FAILURE {case_name} stage={stage}");
    }

    assert_eq!(
        passed + failures.len(),
        manifest.case_count,
        "classifier silently skipped one or more manifest cases"
    );
    assert!(
        failures.is_empty(),
        "strict generated-source classifier found {} failure(s)",
        failures.len()
    );
}
