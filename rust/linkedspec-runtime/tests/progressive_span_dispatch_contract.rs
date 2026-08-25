#![allow(unexpected_cfgs)]
#![cfg(linkedspec_progressive_span_dispatch_red)]

//! FUTURE-PARITY-BACKLOG.14.6.3.3 — admitted Rust progressive-dispatch carrier contract.
//!
//! Ordinary Cargo discovery compiles this target with zero active tests. Canonical admission runs
//! the exact cfg-enabled consumer with:
//!
//! `RUSTFLAGS='--cfg linkedspec_progressive_span_dispatch_red' bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_contract`.
//!
//! This consumer freezes the neutral inventory and proves all four final Rust carriers. Its
//! historical outer cfg remains the exact admission identity; ordinary discovery stays dormant.

use linkedspec_core::compiler::compile;
use linkedspec_core::expr::{Expr, Stmt};
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::bounded_child_parse_authority::{
    ProgressiveCancellationToken, ProgressiveCeilings, ProgressiveClock,
    ProgressiveCompiledAuthority, ProgressiveExecutionSeed, ProgressiveInvocationConfig,
    ProgressiveRegistry, ProgressiveRegistryEntry, ProgressiveSourceDetail,
};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, emit_rust_source_v2,
    execute_generated_parser_v2_with_options,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use linkedspec_runtime::staged_parser_registry::execute_parse_job;
use serde_json::{Value, json};
use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};

const CONTRACT_SOURCE: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../capability_conformance/progressive_span_dispatch_contract.json"
));
const CI_DRIVER_SOURCE: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../tools/run_ci_local.sh"
));
const CONTRACT_ID: &str = "linkedspec-progressive-span-dispatch-v1";
const GENERATED_IDENTITY: &str = "progressive-span-dispatch/rust-red.spec";
const AUTHORED_SOURCE: &str = r#"Top::
 I {
  span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored")
  value = dispatch_span("expr-v1", "Expr", span)
  return(value)
 }
 /never/
"#;
const PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
    label: "Top",
    family: "default",
}];
const EXPECTED_VALUE: &str = r#"{"kind":"identifier","text":"a"}"#;
const EMITTED_AUTHORITY_SETUP: &str = r#"
use linkedspec_runtime::bounded_child_parse_authority::{ProgressiveCancellationToken, ProgressiveCeilings, ProgressiveClock, ProgressiveCompiledAuthority, ProgressiveExecutionSeed, ProgressiveInvocationConfig, ProgressiveRegistry, ProgressiveRegistryEntry, ProgressiveSourceDetail};
use linkedspec_runtime::engine::ExecutionOptions;
use serde_json::json;
use std::collections::BTreeMap;
use std::sync::Arc;

fn execution_options(input: &str) -> ExecutionOptions {
    let callback: ProgressiveCompiledAuthority = Arc::new(|request, _invocation| {
        assert_eq!(request.parser_id(), "expr-v1");
        assert_eq!(request.top_rule(), "Expr");
        assert_eq!(request.fingerprint(), "sha256:1111111111111111111111111111111111111111111111111111111111111111");
        Ok(json!({
            "kind": "identifier",
            "text": request.source_view().text().expect("live source view"),
        }))
    });
    let ceilings = ProgressiveCeilings::new(
        ProgressiveSourceDetail::Text,
        vec!["deterministic".to_owned(), "fail-only".to_owned()],
        100,
        100,
        4096,
    ).expect("progressive ceilings");
    let entry = ProgressiveRegistryEntry::new(
        "expr-v1",
        callback,
        "sha256:1111111111111111111111111111111111111111111111111111111111111111",
        vec!["Expr".to_owned()],
        vec!["parse".to_owned()],
        ceilings.clone(),
    ).expect("progressive entry");
    let registry = ProgressiveRegistry::new(vec![entry]).expect("progressive registry");
    let token = ProgressiveCancellationToken::new();
    let invocation = ProgressiveInvocationConfig {
        sources: BTreeMap::from([("input".to_owned(), input.to_owned())]),
        source_id: "input".to_owned(),
        cancellation_token: token,
        clock: ProgressiveClock::new(|| 0),
        deadline_tick: 100,
        remaining_steps: 100,
        max_depth: 8,
        max_calls: 16,
        active_chain: Vec::new(),
        total_calls: 0,
    };
    let seed = ProgressiveExecutionSeed::new(
        registry,
        invocation,
        vec!["parse".to_owned()],
        vec!["parse".to_owned()],
        ceilings,
        ProgressiveSourceDetail::None,
        1,
    );
    ExecutionOptions::new().with_bounded_child_parse_authority(seed)
}
"#;

fn contract() -> Value {
    serde_json::from_str(CONTRACT_SOURCE).expect("progressive span-dispatch contract JSON")
}

fn ids(value: &Value, field: &str) -> Vec<String> {
    value[field]
        .as_array()
        .unwrap_or_else(|| panic!("{field} array"))
        .iter()
        .map(|row| {
            row["id"]
                .as_str()
                .unwrap_or_else(|| panic!("{field} row id"))
                .to_owned()
        })
        .collect()
}

fn compile_source() -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(AUTHORED_SOURCE)
        .expect("parse exact progressive span-dispatch fixture");
    validate(&parsed).expect("validate exact progressive span-dispatch fixture");
    compile(&parsed).expect("compile exact progressive span-dispatch fixture")
}

fn try_compile_source(source: &str) -> Result<CompiledSpec, String> {
    let parsed = parse_spec_with_user_functions(source).map_err(|error| error.to_string())?;
    validate(&parsed).map_err(|error| error.to_string())?;
    compile(&parsed).map_err(|error| error.to_string())
}

fn occurrences(haystack: &str, needle: &str) -> usize {
    haystack.match_indices(needle).count()
}

fn execution_options(input: &str) -> ExecutionOptions {
    let callback: ProgressiveCompiledAuthority = Arc::new(|request, _invocation| {
        assert_eq!(request.parser_id(), "expr-v1");
        assert_eq!(request.top_rule(), "Expr");
        assert_eq!(
            request.fingerprint(),
            "sha256:1111111111111111111111111111111111111111111111111111111111111111"
        );
        Ok(json!({
            "kind": "identifier",
            "text": request.source_view().text().expect("live source view"),
        }))
    });
    let ceilings = ProgressiveCeilings::new(
        ProgressiveSourceDetail::Text,
        vec!["deterministic".to_owned(), "fail-only".to_owned()],
        100,
        100,
        4096,
    )
    .expect("progressive ceilings");
    let entry = ProgressiveRegistryEntry::new(
        "expr-v1",
        callback,
        "sha256:1111111111111111111111111111111111111111111111111111111111111111",
        vec!["Expr".to_owned()],
        vec!["parse".to_owned()],
        ceilings.clone(),
    )
    .expect("progressive entry");
    let registry = ProgressiveRegistry::new(vec![entry]).expect("progressive registry");
    let invocation = ProgressiveInvocationConfig {
        sources: BTreeMap::from([("input".to_owned(), input.to_owned())]),
        source_id: "input".to_owned(),
        cancellation_token: ProgressiveCancellationToken::new(),
        clock: ProgressiveClock::new(|| 0),
        deadline_tick: 100,
        remaining_steps: 100,
        max_depth: 8,
        max_calls: 16,
        active_chain: Vec::new(),
        total_calls: 0,
    };
    let seed = ProgressiveExecutionSeed::new(
        registry,
        invocation,
        vec!["parse".to_owned()],
        vec!["parse".to_owned()],
        ceilings,
        ProgressiveSourceDetail::None,
        1,
    );
    ExecutionOptions::new().with_bounded_child_parse_authority(seed)
}

struct EmittedProject {
    root: PathBuf,
}

impl EmittedProject {
    fn new() -> Self {
        let nonce = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("clock after epoch")
            .as_nanos();
        let root = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("../target/test-workspaces")
            .join(format!(
                "progressive-span-dispatch-red-{}-{nonce}",
                std::process::id()
            ));
        fs::create_dir_all(root.join("src")).expect("create emitted progressive workspace");
        Self { root }
    }
}

impl Drop for EmittedProject {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

#[test]
fn final_path_uses_one_dedicated_progressive_node_across_four_routes() {
    let neutral = contract();
    assert_eq!(neutral["contract_id"], CONTRACT_ID);
    assert_eq!(neutral["format"], 1);
    assert_eq!(
        neutral["status"],
        "all_private_backends_complete_recurring_and_public_pending"
    );
    assert_eq!(
        neutral["expected_counts"],
        json!({
            "registry_entries": 2,
            "sources": 2,
            "view_cases": 8,
            "authority_cases": 6,
            "cancellation_cases": 6,
            "chain_cases": 8,
            "execution_cases": 4,
            "rust_carrier_paths": 9,
            "dart_carrier_paths": 8,
            "julia_carrier_paths": 9,
            "lua_carrier_paths": 9,
            "backend_guard_groups": 0,
            "backend_guard_paths": 0,
            "outward_guard_paths": 10,
            "diagnostics": 26,
            "rollout_legs": 9,
            "mutations": 112,
        })
    );
    assert_eq!(
        ids(&neutral, "view_cases"),
        [
            "unicode_middle",
            "empty_direct_span",
            "ascii_full",
            "source_mismatch",
            "reversed",
            "outside_source",
            "copied_text_smuggling",
            "noninteger_offset",
        ]
    );
    assert_eq!(
        ids(&neutral, "authority_cases"),
        [
            "intersection_and_minima",
            "entry_cannot_elevate_caller",
            "required_capability_missing",
            "policy_intersection_empty",
            "source_detail_cannot_elevate",
            "caller_numeric_minimum",
        ]
    );
    assert_eq!(
        ids(&neutral, "cancellation_cases"),
        [
            "fresh_budget",
            "already_cancelled",
            "deadline_reached",
            "budget_empty",
            "cost_exceeds_remaining",
            "token_replacement",
        ]
    );
    assert_eq!(
        ids(&neutral, "chain_cases"),
        [
            "root",
            "strictly_smaller",
            "exact_repeat",
            "shifted_equal_length",
            "larger_repeat",
            "different_identity",
            "depth_limit",
            "call_limit",
        ]
    );
    assert_eq!(
        ids(&neutral, "execution_cases"),
        [
            "detached_success",
            "false_payload",
            "child_failure_propagates",
            "live_handle_rejected",
        ]
    );
    let diagnostic_codes = neutral["diagnostics"]
        .as_array()
        .expect("diagnostic rows")
        .iter()
        .map(|row| row["code"].as_str().expect("diagnostic code"))
        .collect::<Vec<_>>();
    assert_eq!(
        diagnostic_codes,
        [
            "progressive_parser_identity_literal_required",
            "progressive_parser_identity_invalid",
            "progressive_top_rule_literal_required",
            "progressive_top_rule_invalid",
            "progressive_span_binding_required",
            "progressive_span_shape_invalid",
            "progressive_span_source_mismatch",
            "progressive_span_out_of_bounds",
            "progressive_span_reversed",
            "progressive_registry_missing",
            "progressive_registry_mutation_forbidden",
            "progressive_implicit_load_forbidden",
            "progressive_top_rule_forbidden",
            "progressive_capability_denied",
            "progressive_policy_denied",
            "progressive_source_detail_denied",
            "progressive_cancelled",
            "progressive_deadline_exceeded",
            "progressive_budget_exhausted",
            "progressive_cancellation_authority_mismatch",
            "progressive_cycle_non_decreasing",
            "progressive_depth_exceeded",
            "progressive_call_limit_exceeded",
            "progressive_child_failed",
            "progressive_transaction_forbidden",
            "progressive_result_not_detached",
        ]
    );
    let rollout = neutral["rollout"].as_array().expect("rollout rows");
    assert_eq!(
        rollout
            .iter()
            .map(|row| row["leg"].as_str().expect("rollout leg"))
            .collect::<Vec<_>>(),
        [
            "neutral",
            "perl",
            "rust",
            "dart",
            "julia",
            "puc_lua",
            "luajit",
            "recurring",
            "public_no_drift",
        ]
    );
    assert_eq!(
        rollout
            .iter()
            .map(|row| row["status"].as_str().expect("rollout status"))
            .collect::<Vec<_>>(),
        [
            "complete", "complete", "complete", "complete", "complete", "complete", "complete",
            "pending", "pending",
        ]
    );
    assert_eq!(
        rollout[2]["paths"],
        json!(["rust/linkedspec-runtime/tests/progressive_span_dispatch_contract.rs"])
    );
    assert_eq!(
        rollout[4]["paths"],
        json!(["julia/test/progressive_span_dispatch_contract_test.jl"])
    );

    let staged_job = json!({
        "kind": "parse_job",
        "job_id": "progressive-rust-red",
        "parent_ast_path": ["Top"],
        "node_kind": "progressive_span_dispatch",
        "payload_kind": "source_span",
        "text": "a",
        "source_span": {"start": 0, "end": 1, "line_start": 1, "line_end": 1},
        "parser_spec_id": "expr-v1",
        "top_rule": "Expr",
        "result_policy": "replace_field",
        "result_field": "value",
        "failure_policy": "fail_only",
    });
    let staged_error = execute_parse_job(&staged_job)
        .expect_err("the function-body staged registry must reject expr-v1");
    assert!(staged_error.contains("phase=resolve"));
    assert!(staged_error.contains("parser_spec_id=expr-v1"));
    assert!(staged_error.contains("unsupported parser spec id 'expr-v1'"));

    for (source, code) in [
        (
            r#"Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span(parser_id, "Expr", span) } /never/"#,
            "progressive_parser_identity_literal_required",
        ),
        (
            r#"Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("Expr/V1", "Expr", span) } /never/"#,
            "progressive_parser_identity_invalid",
        ),
        (
            r#"Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("expr-v1", top_rule, span) } /never/"#,
            "progressive_top_rule_literal_required",
        ),
        (
            r#"Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("expr-v1", "Bad-Rule", span) } /never/"#,
            "progressive_top_rule_invalid",
        ),
        (
            r#"Top:: I { value = dispatch_span("expr-v1", "Expr", hash("source_id", "input")) } /never/"#,
            "progressive_span_binding_required",
        ),
        (
            r#"Top:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); return(cat(dispatch_span("expr-v1", "Expr", span))) } /never/"#,
            "progressive_span_binding_required",
        ),
        (
            r#"Top:: I { tx = recognition_checkpoint(); matched = recognize_once(tx, call(Child)); recognition_rollback(tx); return(matched) }
Child:: I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); value = dispatch_span("expr-v1", "Expr", span); return(value) } /never/"#,
            "recognition_effect_forbidden:parser_registry_or_staged_dispatch",
        ),
    ] {
        let error = try_compile_source(source).expect_err("invalid progressive form must reject");
        assert!(error.contains(code), "expected {code}, got {error}");
    }

    let compiled = compile_source();
    let top = compiled.find("Top").expect("compiled Top rule");
    let preamble = top.preamble.as_ref().expect("progressive preamble");
    let Expr::ProgressiveDispatchSpan {
        target,
        parser_id,
        top_rule,
        span,
    } = &preamble.statements[1].expr
    else {
        panic!("dispatch_span must compile to one dedicated expression");
    };
    assert_eq!(target, "value");
    assert_eq!(parser_id, "expr-v1");
    assert_eq!(top_rule, "Expr");
    assert_eq!(span, "span");

    let encoded = serde_json::to_string(&compiled).expect("serialize progressive fixture");
    assert_eq!(occurrences(&encoded, r#""name":"dispatch_span""#), 0);
    assert_eq!(
        occurrences(&encoded, r#""kind":"progressive_dispatch_span""#),
        1
    );
    assert!(!encoded.contains("PROGRESSIVE_DISPATCH_SPAN"));

    let mut defensive = compiled.clone();
    defensive
        .rules
        .iter_mut()
        .find(|rule| rule.label == "Top")
        .expect("defensive Top rule")
        .preamble
        .as_mut()
        .expect("defensive preamble")
        .statements
        .insert(
            0,
            Stmt {
                expr: Expr::AssignScalar {
                    name: "tx".to_owned(),
                    value: Box::new(Expr::RecognitionCheckpoint),
                },
            },
        );
    let defensive_error = Engine::new(defensive)
        .execute_value("abc", &execution_options("abc"))
        .expect_err("live recognition transaction must reject progressive dispatch");
    assert!(defensive_error.contains("progressive_transaction_forbidden"));

    let expected: Value = serde_json::from_str(EXPECTED_VALUE).expect("expected child value");
    assert_eq!(
        Engine::new(compiled.clone())
            .execute_value("abc", &execution_options("abc"))
            .expect("native progressive execution"),
        expected
    );
    let reconstructed: CompiledSpec =
        serde_json::from_str(&encoded).expect("reconstruct progressive fixture");
    assert_eq!(
        Engine::new(reconstructed)
            .execute_value("abc", &execution_options("abc"))
            .expect("reconstructed progressive execution"),
        expected
    );
    assert_eq!(
        execute_generated_parser_v2_with_options(
            &encoded,
            PLAN,
            "abc",
            GENERATED_IDENTITY,
            GENERATED_SOURCE_CONTRACT,
            &execution_options("abc"),
        )
        .expect("generated-plan progressive execution"),
        expected
    );

    let emitted = emit_rust_source_v2(&compiled, GENERATED_IDENTITY)
        .expect("emit progressive fixture source");
    assert_eq!(occurrences(&emitted, r#"\"name\":\"dispatch_span\""#), 0);
    assert_eq!(
        occurrences(&emitted, r#"\"kind\":\"progressive_dispatch_span\""#),
        1
    );
    assert!(!emitted.contains("PROGRESSIVE_DISPATCH_SPAN"));
    assert!(
        !emitted
            .contains("sha256:1111111111111111111111111111111111111111111111111111111111111111")
    );
    assert!(!emitted.contains("ProgressiveCompiledAuthority"));
    let project = EmittedProject::new();
    fs::write(
        project.root.join("Cargo.toml"),
        format!(
            "[package]\nname = \"progressive-span-dispatch-red\"\nversion = \"0.0.0\"\nedition = \"2024\"\n\n[dependencies]\nlinkedspec-runtime = {{ path = {:?} }}\nserde_json = \"1\"\n\n[workspace]\n",
            Path::new(env!("CARGO_MANIFEST_DIR"))
        ),
    )
    .expect("write emitted progressive manifest");
    fs::write(
        project.root.join("src/main.rs"),
        [
            format!("mod generated {{\n{emitted}\n}}\n"),
            EMITTED_AUTHORITY_SETUP.to_owned(),
            "\nfn main() { let options = execution_options(\"abc\"); let value = generated::execute_with_options(\"abc\", &options).expect(\"generated progressive dispatch\"); println!(\"{}\", value); }\n".to_owned(),
        ]
        .concat(),
    )
    .expect("write emitted progressive main");
    let shared_target = Path::new(env!("CARGO_MANIFEST_DIR")).join("../target");
    let child = Command::new("cargo")
        .arg("run")
        .arg("--offline")
        .arg("--quiet")
        .env("CARGO_TARGET_DIR", shared_target)
        .current_dir(&project.root)
        .output()
        .expect("run independently compiled progressive fixture");
    assert!(
        child.status.success(),
        "emitted progressive fixture failed:\n{}",
        String::from_utf8_lossy(&child.stderr)
    );
    assert_eq!(
        String::from_utf8(child.stdout)
            .expect("UTF-8 emitted stdout")
            .trim(),
        EXPECTED_VALUE
    );

    assert_eq!(
        occurrences(
            CI_DRIVER_SOURCE,
            "require_tracked_file rust/linkedspec-runtime/tests/progressive_span_dispatch_contract.rs"
        ),
        1,
        "canonical CI must require this exact Rust consumer once"
    );
    assert_eq!(
        occurrences(
            CI_DRIVER_SOURCE,
            "running exact Rust progressive span-dispatch admission consumer"
        ),
        1,
        "canonical CI must carry one exact Rust admission marker"
    );
    assert_eq!(
        occurrences(
            CI_DRIVER_SOURCE,
            "RUSTFLAGS='--cfg linkedspec_progressive_span_dispatch_red' cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_contract"
        ),
        1,
        "canonical CI must execute this exact cfg-enabled Rust consumer once"
    );

    assert!(encoded.contains(r#""kind":"progressive_dispatch_span""#));
}
