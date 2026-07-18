//! RUST-PARITY.8.2/.8.3.1-.8.4 — generated Rust-source compile/run proof.

use linkedspec_core::ast::RuleMode;
use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_core::types::ParseMode;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, GeneratedSourceCode, GeneratedSourceError,
    GeneratedSourceMetadata, GeneratedSourceStage, classify_generated_rule_family,
    emit_rust_source, emit_rust_source_v2, execute_generated_parser_v2,
    execute_generated_parser_with_trace_v2, validate_generated_parser_plan_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde::Deserialize;
use serde_json::{Value, json};
use std::collections::BTreeSet;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

const SIMPLE_SOURCE_EMITTER_SPEC: &str = r#"Top::
 I { set(words, []) }
 /hello[ \t]+(\w+)/
 LE { push(words, match_group(0)) }
 E { return(copy(words)) }
"#;

const OR_ACODE_SOURCE_EMITTER_SPEC: &str = r#"Top::OR
 /go/ -> Done { return(cat("or-acode:", call(Done))) }

Done:
 /go/
 E { return(entry_text()) }
"#;

const AND_SINGLE_ACODE_SOURCE_EMITTER_SPEC: &str = r#"Top::AND
 /one/ -> Done { return("and-single") }

Done:
 /one/
"#;

const AND_ACODE_SEQ_SOURCE_EMITTER_SPEC: &str = r#"Top::AND
 /a/ -> First
 /[ \t]+b/ -> Second { return("and-seq") }

First:
 /a/

Second:
 /[ \t]+b/
"#;

const AND_BCODE_SOURCE_EMITTER_SPEC: &str = r#"Top::AND
 I { set(log, []) }
 => ChildA { push(log, retv) }
 => ChildB { push(log, retv) }
 E { return(copy(log)) }

ChildA:
 /a/
 E { return("A") }

ChildB:
 /[ \t]+b/
 E { return("B") }
"#;

const AND_BCODE_IMPLICIT_RESULT_SOURCE_EMITTER_SPEC: &str = r#"Top::AND
 => ChildA
 => ChildB

ChildA:
 /a/
 E { return("A") }

ChildB:
 /[ \t]+b/
 E { return("B") }
"#;

const OR_BCODE_SOURCE_EMITTER_SPEC: &str = r#"Top::OR
 => ChildA
 => ChildB
 E { return(cat("or-bcode:", retv)) }

ChildA:
 /a/
 E { return("A") }

ChildB:
 /[ \t]+b/
 E { return("B") }
"#;

const OR_BCODE_LX_SOURCE_EMITTER_SPEC: &str = r#"Top::OR
 => ChildA
 => ChildB
 LX { return("or-miss") }
 E { return("unexpected") }

ChildA::
 I { return_undef() }

ChildB::
 I { return_undef() }
"#;

const REP_ACODE_SOURCE_EMITTER_SPEC: &str = r#"Top::OR{2,3}
 I { set(out, []) }
 /a/ -> A { push(out, match_text()) }
 /b/ -> B { push(out, match_text()) }
 E { return(copy(out)) }

A:
 /a/

B:
 /b/
"#;

const REP_BCODE_SOURCE_EMITTER_SPEC: &str = r#"Top::OR{2,3}
 I { set(out, []) }
 => A
 => B
 LE { push(out, retv) }
 E { return(copy(out)) }

A:&
 /a/
 LE { return("A") }

B:&
 /b/
 LE { return("B") }
"#;

const REP_AND_ACODE_SOURCE_EMITTER_SPEC: &str = r#"Top::AND{2}
 I { set(pairs, []); set(pair, []) }
 /a/ -> A { push(pair, match_text()) }
 /b/ -> B { push(pair, match_text()) }
 IT { push(pairs, copy(pair)); set(pair, []) }
 E { return(copy(pairs)) }

A:
 /a/

B:
 /b/
"#;

const REP_AND_BCODE_SOURCE_EMITTER_SPEC: &str = r#"Top::AND{2}
 I { set(groups, []); set(group, []) }
 => A { push(group, retv) }
 => B { push(group, retv) }
 IT { push(groups, copy(group)); set(group, []) }
 E { return(copy(groups)) }

A:&
 /a/
 LE { return("A") }

B:&
 /b/
 LE { return("B") }
"#;

const REP_ZERO_PROGRESS_SOURCE_EMITTER_SPEC: &str = r#"Top::OR+
 I { set(iters, []) }
 /x*/
 LE { push(iters, "i") }
 E { return(copy(iters)) }
"#;

const REP_RECURSION_GUARD_SOURCE_EMITTER_SPEC: &str = r#"Top::OR+
 /x*/ -> Top { return(cat("guard:", call(Top))) }
"#;

const EXECUTION_FAILURE_SOURCE_EMITTER_SPEC: &str = r#"Top::
 /bye/
 I { exit_now(7) }
"#;

const GENERATED_SOURCE_CORPUS_SUBSET: &[&str] = &[
    "proof_edge_array_literal",
    "proof_edge_scalar_literal",
    "autoexist_array_bare_arg",
    "terse_1_5_2_primitive_literals",
    "terse_2_2_3_attached_if_blocks",
    "terse_4_3_2_user_function_runtime",
    "tclite_command_subst",
    "portmap_bare",
];

#[derive(Debug, Deserialize)]
struct CorpusManifest {
    format: u64,
    case_count: usize,
    cases: Vec<String>,
}

struct TempProject {
    root: PathBuf,
}

impl TempProject {
    fn new(prefix: &str) -> Self {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("system time should be after the Unix epoch")
            .as_nanos();
        let root = std::env::temp_dir().join(format!("{prefix}-{}-{nanos}", std::process::id()));
        if root.exists() {
            fs::remove_dir_all(&root).expect("remove stale generated-source temp project");
        }
        fs::create_dir_all(root.join("src")).expect("create generated-source temp project");
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

fn corpus_dir() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/corpus")
}

fn load_corpus_manifest(dir: &Path) -> CorpusManifest {
    let path = dir.join("manifest.json");
    let text = fs::read_to_string(&path)
        .unwrap_or_else(|e| panic!("cannot read corpus manifest {}: {e}", path.display()));
    let manifest: CorpusManifest = serde_json::from_str(&text)
        .unwrap_or_else(|e| panic!("malformed corpus manifest {}: {e}", path.display()));

    assert_eq!(
        manifest.format,
        1,
        "unsupported corpus manifest format {} in {}",
        manifest.format,
        path.display()
    );
    assert_eq!(
        manifest.case_count,
        manifest.cases.len(),
        "corpus manifest case_count={} does not match cases.len()={}",
        manifest.case_count,
        manifest.cases.len()
    );
    assert!(
        manifest.case_count > 0,
        "corpus manifest must name at least one fixture"
    );

    let case_set: BTreeSet<&str> = manifest.cases.iter().map(String::as_str).collect();
    assert_eq!(
        case_set.len(),
        manifest.cases.len(),
        "corpus manifest contains duplicate case names"
    );
    manifest
}

fn run_generated_crate(prefix: &str, lib_rs: String) {
    let project = TempProject::new(prefix);
    let runtime_manifest = Path::new(env!("CARGO_MANIFEST_DIR"));
    fs::write(
        project.path().join("Cargo.toml"),
        format!(
            r#"[package]
name = "{prefix}"
version = "0.0.0"
edition = "2024"

[dependencies]
linkedspec-runtime = {{ path = "{}" }}
serde_json = "1"
"#,
            runtime_manifest.display()
        ),
    )
    .expect("write generated smoke Cargo.toml");

    fs::write(project.path().join("src/lib.rs"), lib_rs).expect("write generated smoke lib.rs");

    let output = Command::new("cargo")
        .arg("test")
        .arg("--offline")
        .arg("--quiet")
        .env("CARGO_TARGET_DIR", project.path().join("target"))
        .current_dir(project.path())
        .output()
        .expect("run generated smoke cargo test");

    assert!(
        output.status.success(),
        "generated smoke cargo test failed\nstatus: {}\nstdout:\n{}\nstderr:\n{}",
        output.status,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
}

fn rust_module_name_for_case(case_name: &str) -> String {
    format!("corpus_{case_name}")
}

#[test]
fn generated_source_v2_metadata_and_structured_errors_are_exact() {
    let parsed = parse_spec(SIMPLE_SOURCE_EMITTER_SPEC).expect("parse v2 metadata spec");
    validate(&parsed).expect("validate v2 metadata spec");
    let compiled = compile(&parsed).expect("compile v2 metadata spec");
    let identity = "generated-source/rüst-'identity.spec";

    let generated = emit_rust_source_v2(&compiled, identity).expect("emit v2 Rust source");
    assert_eq!(
        generated,
        emit_rust_source_v2(&compiled, identity).expect("repeat deterministic v2 emission")
    );
    assert_ne!(
        generated,
        emit_rust_source_v2(&compiled, "generated-source/other.spec")
            .expect("emit alternate identity")
    );
    assert_eq!(
        emit_rust_source(&compiled).expect("emit compatibility source"),
        emit_rust_source_v2(&compiled, "<inline>").expect("emit inline v2 source"),
        "compatibility emitter must delegate to the typed v2 path"
    );
    assert!(generated.contains("linkedspec-generated-source-v2"));
    assert!(generated.contains("LINKEDSPEC_GENERATED_SOURCE_CONTRACT"));
    assert!(generated.contains("LINKEDSPEC_GENERATED_SOURCE_IDENTITY"));
    assert!(generated.contains("generated-source/rüst-'identity.spec"));
    assert!(generated.contains("pub fn metadata()"));
    assert!(generated.contains("pub fn plan()"));
    assert!(generated.contains("pub fn validate_plan(actual:"));
    assert!(generated.contains("pub fn execute(input:"));
    assert!(generated.contains("pub fn execute_with_diagnostic_output("));
    assert!(generated.contains("pub fn execute_with_trace(input:"));
    assert!(generated.contains("pub fn execute_with_trace_and_diagnostic_output("));
    assert!(generated.contains("pub fn execute_with_options("));
    assert!(generated.contains("pub fn execute_with_options_and_diagnostic_output("));
    assert!(generated.contains("pub fn execute_with_trace_and_options("));
    assert!(generated.contains("pub fn execute_with_trace_and_options_and_diagnostic_output("));
    assert!(generated.contains("pub fn parse(input:"));
    assert!(generated.contains("pub fn parse_with_diagnostic_output("));
    assert!(generated.contains("pub fn parse_with_trace_and_diagnostic_output("));
    assert!(generated.contains("pub fn parse_with_options("));
    assert!(generated.contains("pub fn parse_with_options_and_diagnostic_output("));
    assert!(generated.contains("pub fn parse_with_trace_and_options("));
    assert!(generated.contains("pub fn parse_with_trace_and_options_and_diagnostic_output("));
    assert!(!generated.contains("\"parse_mode\""));
    assert!(!generated.contains("\"cursor_policy\""));
    assert!(!generated.contains("GENERATED_RULES"));

    let metadata = GeneratedSourceMetadata::new(identity);
    assert_eq!(
        serde_json::to_value(&metadata).expect("serialize generated metadata"),
        json!({
            "contract_id": "linkedspec-generated-source-v2",
            "format_version": 2,
            "source_identity": identity,
        })
    );

    let emission_error =
        emit_rust_source_v2(&compiled, "").expect_err("empty generated source identity must fail");
    assert_eq!(emission_error.error_type, "generated_source_error");
    assert_eq!(emission_error.stage, GeneratedSourceStage::EmitSource);
    assert_eq!(
        emission_error.code,
        GeneratedSourceCode::GeneratedSourceEmitFailed
    );
    assert_eq!(emission_error.source_identity, "");
    assert_eq!(
        emission_error.to_json().expect("serialize emission error"),
        json!({
            "type": "generated_source_error",
            "stage": "emit_source",
            "code": "generated_source_emit_failed",
            "summary": "Generated Rust source identity must not be empty",
            "source_identity": "",
            "detail": "source_identity is required",
        })
    );

    let compile_error = GeneratedSourceError::compile_failed(identity, "rustc failed");
    assert_eq!(
        compile_error.stage,
        GeneratedSourceStage::CompileOrLoadGeneratedSource
    );
    assert_eq!(
        compile_error.code,
        GeneratedSourceCode::GeneratedSourceCompileFailed
    );
    assert_eq!(compile_error.source_identity, identity);

    let invalid_json_error =
        execute_generated_parser_v2("not json", &[], "", identity, GENERATED_SOURCE_CONTRACT)
            .expect_err("invalid embedded compiled spec must fail as generated load");
    assert_eq!(
        invalid_json_error.stage,
        GeneratedSourceStage::CompileOrLoadGeneratedSource
    );
    assert_eq!(
        invalid_json_error.code,
        GeneratedSourceCode::GeneratedSourceCompileFailed
    );

    let compiled_json = serde_json::to_string(&compiled).expect("serialize compiled v2 fixture");
    let plan_error = execute_generated_parser_v2(
        &compiled_json,
        &[],
        "hello one",
        identity,
        GENERATED_SOURCE_CONTRACT,
    )
    .expect_err("missing generated plan rows must fail before execution");
    assert_eq!(
        plan_error.stage,
        GeneratedSourceStage::ValidateGeneratedPlan
    );
    assert_eq!(
        plan_error.code,
        GeneratedSourceCode::GeneratedPlanRowCountMismatch
    );
    assert_eq!(plan_error.source_identity, identity);

    let parsed_failure =
        parse_spec(EXECUTION_FAILURE_SOURCE_EMITTER_SPEC).expect("parse execution failure spec");
    validate(&parsed_failure).expect("validate execution failure spec");
    let compiled_failure = compile(&parsed_failure).expect("compile execution failure spec");
    let compiled_failure_json =
        serde_json::to_string(&compiled_failure).expect("serialize execution failure spec");
    let failure_plan = [GeneratedPlanRow {
        label: "Top",
        family: "default",
    }];
    let execution_error = execute_generated_parser_v2(
        &compiled_failure_json,
        &failure_plan,
        "bye",
        identity,
        GENERATED_SOURCE_CONTRACT,
    )
    .expect_err("exit_now must become a typed generated execution failure");
    assert_eq!(
        execution_error.stage,
        GeneratedSourceStage::ExecuteGenerated
    );
    assert_eq!(
        execution_error.code,
        GeneratedSourceCode::GeneratedExecutionFailed
    );
    assert_eq!(execution_error.rule_label.as_deref(), Some("Top"));
    assert_eq!(execution_error.handler_family.as_deref(), Some("default"));
    assert_eq!(execution_error.detail.as_deref(), Some("exit_now(7)"));
}

#[test]
fn emitted_source_option_roles_compile_and_select_an_ordinary_rule() {
    let source = r#"Earlier:
 /x/
 E { return("earlier") }

Marked::
 /x/
 E { return("marked") }
"#;
    let parsed = parse_spec(source).expect("parse emitted root-selection fixture");
    validate(&parsed).expect("validate emitted root-selection fixture");
    let compiled = compile(&parsed).expect("compile emitted root-selection fixture");
    let mut generated = emit_rust_source_v2(&compiled, "generated-source/root-selection.spec")
        .expect("emit root-selection source");
    generated.push_str(
        r#"
#[cfg(test)]
mod root_selection_options {
    use super::*;
    use linkedspec_runtime::engine::ExecutionOptions;
    use linkedspec_runtime::source_emitter::{GeneratedSourceCode, GeneratedSourceStage};

    #[test]
    fn all_option_roles_select_per_invocation() {
        let options = ExecutionOptions::new().with_entry_rule("Earlier");
        let direct = serde_json::json!("earlier");
        let compatibility = serde_json::json!(["earlier"]);

        assert_eq!(execute_with_options("x", &options).unwrap(), direct);
        assert_eq!(
            execute_with_options_and_diagnostic_output("x", &options, None).unwrap(),
            direct
        );
        assert_eq!(
            execute_with_trace_and_options("x", TraceConfig::disabled(), &options).unwrap(),
            direct
        );
        assert_eq!(
            execute_with_trace_and_options_and_diagnostic_output(
                "x",
                TraceConfig::disabled(),
                &options,
                None,
            )
            .unwrap(),
            direct
        );

        assert_eq!(parse_with_options("x", &options).unwrap(), compatibility);
        assert_eq!(
            parse_with_options_and_diagnostic_output("x", &options, None).unwrap(),
            compatibility
        );
        assert_eq!(
            parse_with_trace_and_options("x", TraceConfig::disabled(), &options).unwrap(),
            compatibility
        );
        assert_eq!(
            parse_with_trace_and_options_and_diagnostic_output(
                "x",
                TraceConfig::disabled(),
                &options,
                None,
            )
            .unwrap(),
            compatibility
        );

        let missing = ExecutionOptions::new().with_entry_rule("Missing");
        let error = execute_with_options("x", &missing).unwrap_err();
        assert_eq!(error.stage, GeneratedSourceStage::SelectEntryRule);
        assert_eq!(error.code, GeneratedSourceCode::EntryRuleNotFound);
        assert_eq!(error.entry_rule.as_deref(), Some("Missing"));
    }
}
"#,
    );
    run_generated_crate("linkedspec-generated-root-selection", generated);
}

#[test]
fn generated_source_v2_neutral_plan_and_trace_roles_are_exact() {
    let fixture_dir = Path::new(env!("CARGO_MANIFEST_DIR")).join(
        "../../capability_conformance/generated_source/fixtures/default_action_result_trace_identity",
    );
    let source = fs::read_to_string(fixture_dir.join("input.spec"))
        .expect("read neutral generated-source fixture spec");
    let input = fs::read_to_string(fixture_dir.join("input.txt"))
        .expect("read neutral generated-source fixture input");
    let expected: Value = serde_json::from_str(
        &fs::read_to_string(fixture_dir.join("expected.json"))
            .expect("read neutral generated-source expected JSON"),
    )
    .expect("parse neutral generated-source expected JSON");
    let parsed = parse_spec(&source).expect("parse neutral generated-source fixture");
    validate(&parsed).expect("validate neutral generated-source fixture");
    let compiled = compile(&parsed).expect("compile neutral generated-source fixture");
    let compiled_json =
        serde_json::to_string(&compiled).expect("serialize neutral generated-source fixture");
    let identity = "generated-source/default-action-result.spec";
    let plan = [
        GeneratedPlanRow {
            label: "Top",
            family: "default",
        },
        GeneratedPlanRow {
            label: "Done",
            family: "default",
        },
    ];

    validate_generated_parser_plan_v2(&compiled_json, &plan, identity, GENERATED_SOURCE_CONTRACT)
        .expect("exact neutral plan must validate");
    assert_eq!(
        execute_generated_parser_v2(
            &compiled_json,
            &plan,
            &input,
            identity,
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("neutral generated fixture must execute"),
        expected
    );

    let rejection = |actual: &[GeneratedPlanRow], expected_code: GeneratedSourceCode| {
        let error = validate_generated_parser_plan_v2(
            &compiled_json,
            actual,
            identity,
            GENERATED_SOURCE_CONTRACT,
        )
        .expect_err("mutated generated plan must be rejected");
        assert_eq!(error.error_type, "generated_source_error");
        assert_eq!(error.stage, GeneratedSourceStage::ValidateGeneratedPlan);
        assert_eq!(error.code, expected_code);
        assert_eq!(error.source_identity, identity);
    };
    rejection(&[], GeneratedSourceCode::GeneratedPlanRowCountMismatch);
    let wrong_label = [
        GeneratedPlanRow {
            label: "Wrong",
            family: "default",
        },
        plan[1],
    ];
    rejection(
        &wrong_label,
        GeneratedSourceCode::GeneratedPlanLabelMismatch,
    );
    let wrong_family = [
        GeneratedPlanRow {
            label: "Top",
            family: "or_acode",
        },
        plan[1],
    ];
    rejection(
        &wrong_family,
        GeneratedSourceCode::GeneratedPlanFamilyMismatch,
    );
    let unknown_family = [
        GeneratedPlanRow {
            label: "Top",
            family: "unknown",
        },
        plan[1],
    ];
    rejection(
        &unknown_family,
        GeneratedSourceCode::GeneratedPlanUnknownFamily,
    );

    let trace_project = TempProject::new("linkedspec-generated-neutral-trace");
    let trace_path = trace_project.path().join("generated.trace");
    let trace_config = TraceConfig::enabled(TraceLevel::DEBUG)
        .with_trace_file(trace_path.clone())
        .with_reset_file(true);
    assert_eq!(
        execute_generated_parser_with_trace_v2(
            &compiled_json,
            &plan,
            &input,
            trace_config,
            identity,
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("neutral traced generated fixture must execute"),
        expected
    );
    let trace = fs::read_to_string(&trace_path).expect("read neutral generated trace");
    for role in [
        "generated_rule_enter",
        "generated_family_decision",
        "generated_rule_exit",
    ] {
        assert!(
            trace.contains(role),
            "missing portable role {role}:\n{trace}"
        );
    }
    assert!(trace.contains(identity));
    assert!(trace.contains("family=default"));
    assert!(trace.contains("rust_runtime:generated_plan:family_dispatch"));
}

#[test]
fn emitted_rust_source_compiles_and_runs_family_plan_matrix() {
    struct Case {
        module: &'static str,
        spec: &'static str,
        input: &'static str,
        expected: serde_json::Value,
        expected_family: &'static str,
        expected_mode: RuleMode,
    }

    let cases = vec![
        Case {
            module: "default_case",
            spec: SIMPLE_SOURCE_EMITTER_SPEC,
            input: "hello one hello two",
            expected: json!([["one", "two"]]),
            expected_family: "default",
            expected_mode: RuleMode::Default,
        },
        Case {
            module: "or_acode_case",
            spec: OR_ACODE_SOURCE_EMITTER_SPEC,
            input: "go",
            expected: json!(["or-acode:go"]),
            expected_family: "or_acode",
            expected_mode: RuleMode::Or,
        },
        Case {
            module: "and_single_acode_case",
            spec: AND_SINGLE_ACODE_SOURCE_EMITTER_SPEC,
            input: "one",
            expected: json!(["and-single"]),
            expected_family: "and_single_acode",
            expected_mode: RuleMode::And,
        },
        Case {
            module: "and_acode_seq_case",
            spec: AND_ACODE_SEQ_SOURCE_EMITTER_SPEC,
            input: "a b",
            expected: json!(["and-seq"]),
            expected_family: "and_acode_seq",
            expected_mode: RuleMode::And,
        },
        Case {
            module: "and_bcode_case",
            spec: AND_BCODE_SOURCE_EMITTER_SPEC,
            input: "a b",
            expected: json!([["A", "B"]]),
            expected_family: "and_bcode",
            expected_mode: RuleMode::And,
        },
        Case {
            module: "and_bcode_implicit_result_case",
            spec: AND_BCODE_IMPLICIT_RESULT_SOURCE_EMITTER_SPEC,
            input: "a b",
            expected: json!([["A", "B"]]),
            expected_family: "and_bcode",
            expected_mode: RuleMode::And,
        },
        Case {
            module: "or_bcode_case",
            spec: OR_BCODE_SOURCE_EMITTER_SPEC,
            input: "a b",
            expected: json!(["or-bcode:A"]),
            expected_family: "or_bcode",
            expected_mode: RuleMode::Or,
        },
        Case {
            module: "or_bcode_miss_case",
            spec: OR_BCODE_LX_SOURCE_EMITTER_SPEC,
            input: "c",
            expected: json!(["or-miss"]),
            expected_family: "or_bcode",
            expected_mode: RuleMode::Or,
        },
        Case {
            module: "rep_acode_case",
            spec: REP_ACODE_SOURCE_EMITTER_SPEC,
            input: "abab",
            expected: json!([["a", "b", "a"]]),
            expected_family: "rep_acode",
            expected_mode: RuleMode::OrBounded {
                min: 2,
                max: Some(3),
            },
        },
        Case {
            module: "rep_bcode_case",
            spec: REP_BCODE_SOURCE_EMITTER_SPEC,
            input: "abab",
            expected: json!([["A", "B", "A"]]),
            expected_family: "rep_bcode",
            expected_mode: RuleMode::OrBounded {
                min: 2,
                max: Some(3),
            },
        },
        Case {
            module: "rep_and_acode_case",
            spec: REP_AND_ACODE_SOURCE_EMITTER_SPEC,
            input: "abab",
            expected: json!([[["a", "b"], ["a", "b"]]]),
            expected_family: "rep_and_acode",
            expected_mode: RuleMode::AndBounded {
                min: 2,
                max: Some(2),
            },
        },
        Case {
            module: "rep_and_bcode_case",
            spec: REP_AND_BCODE_SOURCE_EMITTER_SPEC,
            input: "abab",
            expected: json!([[["A", "B"], ["A", "B"]]]),
            expected_family: "rep_and_bcode",
            expected_mode: RuleMode::AndBounded {
                min: 2,
                max: Some(2),
            },
        },
        Case {
            module: "rep_zero_progress_case",
            spec: REP_ZERO_PROGRESS_SOURCE_EMITTER_SPEC,
            input: "abc",
            expected: json!([["i"]]),
            expected_family: "rep_acode",
            expected_mode: RuleMode::OrPlus,
        },
        Case {
            module: "rep_recursion_guard_case",
            spec: REP_RECURSION_GUARD_SOURCE_EMITTER_SPEC,
            input: "abc",
            expected: json!([null]),
            expected_family: "rep_acode",
            expected_mode: RuleMode::OrPlus,
        },
    ];

    let expected_non_rep_families = BTreeSet::from([
        "default",
        "or_acode",
        "and_single_acode",
        "and_acode_seq",
        "and_bcode",
        "or_bcode",
    ]);
    let mut covered_non_rep_families = BTreeSet::new();
    let expected_rep_families =
        BTreeSet::from(["rep_acode", "rep_bcode", "rep_and_acode", "rep_and_bcode"]);
    let mut covered_rep_families = BTreeSet::new();
    let cursor_contract: Value = serde_json::from_str(include_str!(
        "../../../capability_conformance/rule_local_cursor_contract.json"
    ))
    .expect("neutral rule-local cursor contract must be valid JSON");
    let contract_families = |field: &str| -> BTreeSet<&str> {
        cursor_contract["generated_source_v2"][field]
            .as_array()
            .unwrap_or_else(|| panic!("generated_source_v2.{field} must be an array"))
            .iter()
            .map(|family| {
                family
                    .as_str()
                    .unwrap_or_else(|| panic!("generated_source_v2.{field} must contain strings"))
            })
            .collect()
    };
    let expected_seek_families = contract_families("seek_families");
    let expected_consume_families = contract_families("consume_families");
    assert!(expected_seek_families.is_disjoint(&expected_consume_families));
    let expected_contract_families = expected_seek_families
        .union(&expected_consume_families)
        .copied()
        .collect::<BTreeSet<_>>();
    let mut covered_contract_families = BTreeSet::new();
    let mut generated_modules = String::new();
    let mut generated_tests = String::from("#[cfg(test)]\nmod generated_source_tests {\n");

    for case in &cases {
        let parsed = parse_spec(case.spec).expect("parse source-emitter smoke spec");
        validate(&parsed).expect("validate source-emitter smoke spec");
        let compiled = compile(&parsed).expect("compile source-emitter smoke spec");

        let interpreted = Engine::new(compiled.clone())
            .execute(case.input)
            .expect("interpreted smoke parser should execute");
        assert_eq!(interpreted, case.expected);
        let direct_expected = case
            .expected
            .as_array()
            .and_then(|values| values.first())
            .expect("legacy source-emitter expectation has one top-level result");
        assert_eq!(
            Engine::new(compiled.clone())
                .execute_value(case.input, &ExecutionOptions::new())
                .expect("direct interpreted smoke parser should execute"),
            direct_expected.clone()
        );

        let top = compiled
            .top_rule()
            .expect("compiled smoke spec has a top rule");
        assert_eq!(top.mode, case.expected_mode);

        let generated = emit_rust_source(&compiled).expect("emit generated Rust source");
        let generated_family = classify_generated_rule_family(top);
        let family_name = generated_family.contract_name();
        covered_contract_families.insert(family_name);
        if expected_non_rep_families.contains(case.expected_family) {
            covered_non_rep_families.insert(case.expected_family);
        }
        if expected_rep_families.contains(case.expected_family) {
            covered_rep_families.insert(case.expected_family);
        }
        assert!(generated.contains("LINKEDSPEC_GENERATED_SOURCE_FORMAT"));
        assert!(generated.contains("COMPILED_SPEC_JSON"));
        assert!(generated.contains("GENERATED_PLAN"));
        assert!(!generated.contains("GENERATED_RULES"));
        assert!(!generated.contains("\"parse_mode\""));
        assert!(!generated.contains("\"cursor_policy\""));
        assert!(!generated.contains("Engine::new"));
        assert_eq!(family_name, case.expected_family);
        let expected_policy = if expected_seek_families.contains(family_name) {
            ParseMode::Seek
        } else if expected_consume_families.contains(family_name) {
            ParseMode::Consume
        } else {
            panic!("family {family_name} is absent from the neutral v2 policy map")
        };
        assert_eq!(
            generated_family.cursor_policy(),
            expected_policy,
            "family {family_name} must derive its cursor policy from the neutral v2 map"
        );
        assert!(generated.contains(&format!("family: {:?}", case.expected_family)));

        generated_modules.push_str("pub mod ");
        generated_modules.push_str(case.module);
        generated_modules.push_str(" {\n");
        generated_modules.push_str(&generated);
        generated_modules.push_str("}\n\n");

        let input_literal = serde_json::to_string(case.input).expect("encode generated test input");
        let direct_expected_literal =
            serde_json::to_string(direct_expected).expect("encode generated direct expectation");
        let compatibility_expected_literal = serde_json::to_string(&case.expected)
            .expect("encode generated compatibility expectation");
        generated_tests.push_str("    #[test]\n    fn ");
        generated_tests.push_str(case.module);
        generated_tests.push_str("_runs() {\n        let actual = crate::");
        generated_tests.push_str(case.module);
        generated_tests.push_str("::execute(");
        generated_tests.push_str(&input_literal);
        generated_tests.push_str(").expect(\"generated parser should run\");\n        let expected: serde_json::Value = serde_json::from_str(");
        generated_tests.push_str(
            &serde_json::to_string(&direct_expected_literal)
                .expect("encode direct expected JSON literal"),
        );
        generated_tests.push_str(").expect(\"expected JSON should parse\");\n        assert_eq!(actual, expected);\n        let plan = crate::");
        generated_tests.push_str(case.module);
        generated_tests.push_str("::plan();\n        crate::");
        generated_tests.push_str(case.module);
        generated_tests.push_str("::validate_plan(plan).expect(\"embedded neutral plan should validate\");\n        let compatibility = crate::");
        generated_tests.push_str(case.module);
        generated_tests.push_str("::parse(");
        generated_tests.push_str(&input_literal);
        generated_tests.push_str(").expect(\"compatibility parser should run\");\n        let compatibility_expected: serde_json::Value = serde_json::from_str(");
        generated_tests.push_str(
            &serde_json::to_string(&compatibility_expected_literal)
                .expect("encode compatibility expected JSON literal"),
        );
        generated_tests.push_str(").expect(\"compatibility expected JSON should parse\");\n        assert_eq!(compatibility, compatibility_expected);\n    }\n");
    }
    assert_eq!(
        covered_non_rep_families, expected_non_rep_families,
        "source-emitter matrix must retain every non-REP generated family while adding REP coverage"
    );
    assert_eq!(
        covered_rep_families, expected_rep_families,
        "source-emitter matrix must cover every REP generated family before corpus integration"
    );
    assert_eq!(
        covered_contract_families, expected_contract_families,
        "source-emitter matrix must expose exactly the ten neutral generated families"
    );
    generated_tests.push_str("}\n");

    run_generated_crate(
        "linkedspec_generated_smoke",
        format!("{generated_modules}\n{generated_tests}"),
    );
}

#[test]
fn generated_source_v2_rejects_v1_before_plan_reconstruction() {
    let parsed = parse_spec(REP_AND_BCODE_SOURCE_EMITTER_SPEC)
        .expect("parse contract-version rejection spec");
    validate(&parsed).expect("validate contract-version rejection spec");
    let compiled = compile(&parsed).expect("compile contract-version rejection spec");
    let compiled_spec_json =
        serde_json::to_string(&compiled).expect("serialize contract-version rejection spec");
    let plan = [
        GeneratedPlanRow {
            label: "Top",
            family: "rep_and_bcode",
        },
        GeneratedPlanRow {
            label: "A",
            family: "and_single_acode",
        },
        GeneratedPlanRow {
            label: "B",
            family: "and_single_acode",
        },
    ];

    let error = validate_generated_parser_plan_v2(
        &compiled_spec_json,
        &plan,
        "generated-source/legacy-v1.spec",
        "linkedspec-generated-source-v1",
    )
    .expect_err("v1 artifact must be rejected by the v2 reconstruction boundary");
    assert_eq!(error.stage, GeneratedSourceStage::ValidateGeneratedPlan);
    assert_eq!(
        error.code,
        GeneratedSourceCode::GeneratedSourceContractVersionMismatch
    );
    assert_eq!(
        error.expected_contract(),
        Some("linkedspec-generated-source-v2")
    );
    assert_eq!(
        error.actual_contract(),
        Some("linkedspec-generated-source-v1")
    );
    assert!(
        error
            .detail
            .as_deref()
            .is_some_and(|detail| detail.contains("regenerate") && detail.contains(".spec"))
    );
    assert_eq!(
        error.to_json().expect("serialize v1 contract rejection"),
        json!({
            "type": "generated_source_error",
            "stage": "validate_generated_plan",
            "code": "generated_source_contract_version_mismatch",
            "summary": "Generated source contract does not match the active validator",
            "source_identity": "generated-source/legacy-v1.spec",
            "detail": "regenerate the generated artifact from its .spec source",
            "expected_contract": "linkedspec-generated-source-v2",
            "actual_contract": "linkedspec-generated-source-v1",
        })
    );
}

#[test]
fn generated_rust_source_matches_manifest_backed_corpus_subset() {
    let dir = corpus_dir();
    assert!(
        dir.is_dir(),
        "corpus directory missing: {} (run `perl tools/gen_oracle_corpus.pl`)",
        dir.display()
    );

    let manifest = load_corpus_manifest(&dir);
    let manifest_cases: BTreeSet<&str> = manifest.cases.iter().map(String::as_str).collect();
    for case_name in GENERATED_SOURCE_CORPUS_SUBSET {
        assert!(
            manifest_cases.contains(case_name),
            "generated-source corpus subset case {case_name:?} is not listed in manifest.json"
        );
    }

    let mut generated_modules = String::new();
    let mut generated_tests = String::from("#[cfg(test)]\nmod generated_corpus_tests {\n");

    for case_name in GENERATED_SOURCE_CORPUS_SUBSET {
        let case_dir = dir.join(case_name);
        let read = |file: &str| -> String {
            fs::read_to_string(case_dir.join(file)).unwrap_or_else(|e| {
                panic!(
                    "cannot read generated-source corpus subset file {}/{}: {e}",
                    case_dir.display(),
                    file
                )
            })
        };
        let source = read("input.spec");
        let input = read("input.txt");
        let expected_reference: Value =
            serde_json::from_str(&read("expected.json")).unwrap_or_else(|e| {
                panic!(
                    "malformed expected.json for generated-source corpus subset case {case_name}: {e}"
                )
            });
        let expected_engine_output = json!([expected_reference]);

        let parsed = parse_spec_with_user_functions(&source).unwrap_or_else(|e| {
            panic!("parse failed for generated-source corpus subset case {case_name}: {e}")
        });
        validate(&parsed).unwrap_or_else(|e| {
            panic!("validate failed for generated-source corpus subset case {case_name}: {e}")
        });
        let compiled = compile(&parsed).unwrap_or_else(|e| {
            panic!("compile failed for generated-source corpus subset case {case_name}: {e}")
        });

        let interpreted = Engine::new(compiled.clone())
            .execute(&input)
            .unwrap_or_else(|e| {
                panic!(
                    "interpreted execution failed for generated-source corpus subset case {case_name}: {e}"
                )
            });
        assert_eq!(
            interpreted, expected_engine_output,
            "generated-source corpus subset case {case_name} must first satisfy the interpreter oracle"
        );
        assert_eq!(
            Engine::new(compiled.clone())
                .execute_value(&input, &ExecutionOptions::new())
                .unwrap_or_else(|e| {
                    panic!(
                        "direct interpreted execution failed for generated-source corpus subset case {case_name}: {e}"
                    )
                }),
            expected_reference,
            "generated-source corpus subset case {case_name} must satisfy the direct interpreter oracle"
        );

        let generated = emit_rust_source(&compiled).unwrap_or_else(|e| {
            panic!("emit failed for generated-source corpus subset case {case_name}: {e}")
        });
        assert!(generated.contains("GENERATED_PLAN"));
        assert!(!generated.contains("GENERATED_RULES"));

        let module = rust_module_name_for_case(case_name);
        generated_modules.push_str("pub mod ");
        generated_modules.push_str(&module);
        generated_modules.push_str(" {\n");
        generated_modules.push_str(&generated);
        generated_modules.push_str("}\n\n");

        let input_literal =
            serde_json::to_string(&input).expect("encode generated corpus test input");
        let direct_expected_literal = serde_json::to_string(&expected_reference)
            .expect("encode generated corpus direct expectation");
        let compatibility_expected_literal = serde_json::to_string(&expected_engine_output)
            .expect("encode generated corpus compatibility expectation");
        generated_tests.push_str("    #[test]\n    fn ");
        generated_tests.push_str(&module);
        generated_tests.push_str("_matches_oracle() {\n        let actual = crate::");
        generated_tests.push_str(&module);
        generated_tests.push_str("::execute(");
        generated_tests.push_str(&input_literal);
        generated_tests.push_str(").expect(\"generated corpus parser should run\");\n        let expected: serde_json::Value = serde_json::from_str(");
        generated_tests.push_str(
            &serde_json::to_string(&direct_expected_literal)
                .expect("encode direct expected JSON literal"),
        );
        generated_tests.push_str(").expect(\"expected JSON should parse\");\n        assert_eq!(actual, expected);\n        let plan = crate::");
        generated_tests.push_str(&module);
        generated_tests.push_str("::plan();\n        crate::");
        generated_tests.push_str(&module);
        generated_tests.push_str("::validate_plan(plan).expect(\"embedded neutral corpus plan should validate\");\n        let compatibility = crate::");
        generated_tests.push_str(&module);
        generated_tests.push_str("::parse(");
        generated_tests.push_str(&input_literal);
        generated_tests.push_str(").expect(\"compatibility corpus parser should run\");\n        let compatibility_expected: serde_json::Value = serde_json::from_str(");
        generated_tests.push_str(
            &serde_json::to_string(&compatibility_expected_literal)
                .expect("encode compatibility expected JSON literal"),
        );
        generated_tests.push_str(").expect(\"compatibility expected JSON should parse\");\n        assert_eq!(compatibility, compatibility_expected);\n    }\n");
    }

    generated_tests.push_str("}\n");
    run_generated_crate(
        "linkedspec_generated_corpus_subset",
        format!("{generated_modules}\n{generated_tests}"),
    );
}
