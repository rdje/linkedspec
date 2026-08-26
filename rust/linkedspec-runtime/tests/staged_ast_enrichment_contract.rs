#![allow(unexpected_cfgs)]
#![cfg(linkedspec_staged_ast_enrichment_red)]

//! FUTURE-PARITY-BACKLOG.14.7.4.0 — dormant Rust staged-AST enrichment contract.
//!
//! Ordinary Cargo discovery compiles this target with zero active tests. Before admission, run
//! the exact final-path RED with:
//!
//! `RUSTFLAGS='--cfg linkedspec_staged_ast_enrichment_red' bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract`.
//!
//! This consumer freezes the neutral inventory, current function-body v1 compatibility, and all
//! four final Rust observation surfaces without changing production behavior or canonical CI. Its
//! sole intentional failure is the missing dedicated `STAGED_PARSE_JOB_MARKER` with typed v2
//! provenance; a generic `parse_job(...)` helper call is not an implementation.

use linkedspec_core::compiler::compile;
use linkedspec_core::expr::Expr;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, emit_rust_source_v2, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use linkedspec_runtime::staged_parser_registry::{execute_parse_job, execute_parse_jobs};
use serde_json::{Value, json};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

const CONTRACT_SOURCE: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../capability_conformance/staged_ast_enrichment_contract.json"
));
const CI_DRIVER_SOURCE: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../tools/run_ci_local.sh"
));
const CONTRACT_ID: &str = "linkedspec-staged-ast-enrichment-v1";
const GENERATED_IDENTITY: &str = "staged-ast-enrichment/rust-red.spec";
const AUTHORED_SOURCE: &str = r#"Top::
 /([^;]+);/
 I {
  job_marker = parse_job(entry_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", "result_policy", "sibling_field", "into", "expression_ast", "on_error", "fail"))
  return(job_marker)
 }
"#;
const PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
    label: "Top",
    family: "default",
}];

fn contract() -> Value {
    serde_json::from_str(CONTRACT_SOURCE).expect("staged-AST enrichment contract JSON")
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
        .expect("parse exact staged-AST enrichment fixture");
    validate(&parsed).expect("validate exact staged-AST enrichment fixture");
    compile(&parsed).expect("compile exact staged-AST enrichment fixture")
}

fn occurrences(haystack: &str, needle: &str) -> usize {
    haystack.match_indices(needle).count()
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
                "staged-ast-enrichment-red-{}-{nonce}",
                std::process::id()
            ));
        fs::create_dir_all(root.join("src")).expect("create emitted staged-AST workspace");
        Self { root }
    }
}

impl Drop for EmittedProject {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

#[test]
fn final_path_reaches_only_the_missing_dedicated_staged_parse_marker() {
    let neutral = contract();
    assert_eq!(neutral["contract_id"], CONTRACT_ID);
    assert_eq!(neutral["format"], 1);
    assert_eq!(
        neutral["status"],
        "neutral_and_perl_complete_later_backends_pending"
    );
    assert_eq!(
        neutral["expected_counts"],
        json!({
            "registry_entries": 4,
            "sources": 2,
            "provenance_cases": 8,
            "job_id_cases": 3,
            "resolution_cases": 8,
            "authority_cases": 6,
            "cache_cases": 10,
            "queue_cases": 4,
            "isolation_cases": 3,
            "stitch_cases": 4,
            "failure_cases": 3,
            "chain_cases": 10,
            "detachment_cases": 5,
            "carrier_requirements": 4,
            "backend_consumers": 5,
            "runtime_routes": 6,
            "outward_guard_paths": 10,
            "diagnostics": 37,
            "rollout_legs": 9,
            "ownership_rows": 35,
            "mutations": 79,
        })
    );
    assert_eq!(
        ids(&neutral, "provenance_cases"),
        [
            "direct_unicode",
            "direct_empty",
            "derived_ordered",
            "direct_reversed",
            "direct_out_of_bounds",
            "derived_empty",
            "derived_segment_invalid",
            "copied_text_smuggling",
        ]
    );
    assert_eq!(
        ids(&neutral, "job_id_cases"),
        [
            "direct_identity",
            "derived_identity",
            "default_top_normalized_before_identity",
        ]
    );
    assert_eq!(
        ids(&neutral, "resolution_cases"),
        [
            "alias_first",
            "declaring_relative_second",
            "search_root_order",
            "provider_order",
            "missing",
            "same_priority_ambiguous",
            "alias_relative_collision",
            "path_traversal_rejected",
        ]
    );
    assert_eq!(
        ids(&neutral, "authority_cases"),
        [
            "intersection_and_minima",
            "entry_cannot_elevate_caller",
            "required_capability_missing",
            "policy_denied",
            "source_detail_denied",
            "helper_version_mismatch",
        ]
    );
    assert_eq!(
        ids(&neutral, "cache_cases"),
        [
            "base",
            "identical",
            "content_changed",
            "graph_changed",
            "top_changed",
            "spec_version_changed",
            "helper_version_changed",
            "staged_version_changed",
            "capability_order_normalized",
            "capability_set_changed",
        ]
    );
    assert_eq!(
        ids(&neutral, "queue_cases"),
        [
            "parent_then_provenance",
            "job_id_tie_break",
            "derived_order_key",
            "breadth_first_recursive_enqueue",
        ]
    );
    assert_eq!(
        ids(&neutral, "isolation_cases"),
        [
            "siblings_receive_fresh_runtime_contexts",
            "falsey_child_state_does_not_escape",
            "shared_budget_spans_next_depth",
        ]
    );
    assert_eq!(
        ids(&neutral, "stitch_cases"),
        [
            "replace_marker",
            "replace_field",
            "sibling_field",
            "append_child",
        ]
    );
    assert_eq!(
        ids(&neutral, "failure_cases"),
        [
            "fail_aborts_composed_parse",
            "keep_text_continues",
            "diagnostic_node_uses_result_target",
        ]
    );
    assert_eq!(
        ids(&neutral, "chain_cases"),
        [
            "direct_strictly_smaller",
            "derived_strictly_smaller",
            "exact_tuple_cycle",
            "same_extent_non_decreasing",
            "derived_not_contained",
            "depth_exceeded",
            "call_limit_exceeded",
            "cancelled",
            "deadline_exceeded",
            "budget_exhausted",
        ]
    );
    assert_eq!(
        ids(&neutral, "detachment_cases"),
        [
            "plain_nested",
            "falsey_scalar",
            "live_parser_handle",
            "reference_cycle_marker",
            "node_limit",
        ]
    );
    assert_eq!(
        neutral["diagnostics"]
            .as_array()
            .expect("diagnostic rows")
            .iter()
            .map(|row| row["code"].as_str().expect("diagnostic code"))
            .collect::<Vec<_>>(),
        [
            "staged_parse_job_options_required",
            "staged_parse_job_option_unknown",
            "staged_parser_identity_invalid",
            "staged_top_rule_invalid",
            "staged_result_policy_invalid",
            "staged_failure_policy_invalid",
            "staged_result_target_invalid",
            "staged_source_provenance_invalid",
            "staged_job_id_mismatch",
            "staged_duplicate_job_id",
            "staged_registry_missing",
            "staged_registry_ambiguous",
            "staged_registry_collision",
            "staged_implicit_load_forbidden",
            "staged_registry_mutation_forbidden",
            "staged_top_rule_forbidden",
            "staged_capability_denied",
            "staged_policy_denied",
            "staged_source_detail_denied",
            "staged_version_mismatch",
            "staged_cache_identity_invalid",
            "staged_cancelled",
            "staged_deadline_exceeded",
            "staged_budget_exhausted",
            "staged_cycle",
            "staged_chain_non_decreasing",
            "staged_depth_exceeded",
            "staged_call_limit_exceeded",
            "staged_child_failed",
            "staged_stitch_target_missing",
            "staged_stitch_target_collision",
            "staged_append_target_invalid",
            "staged_marker_mismatch",
            "staged_result_not_detached",
            "staged_result_node_limit_exceeded",
            "staged_transaction_forbidden",
            "staged_diagnostic_truncated",
        ]
    );
    assert_eq!(
        neutral["backend_consumers"]
            .as_array()
            .expect("backend consumers")
            .iter()
            .map(|row| row["status"].as_str().expect("consumer status"))
            .collect::<Vec<_>>(),
        [
            "complete",
            "dormant_red",
            "pending_absent",
            "pending_absent",
            "pending_absent",
        ]
    );
    assert_eq!(
        neutral["rollout"]
            .as_array()
            .expect("rollout rows")
            .iter()
            .map(|row| row["status"].as_str().expect("rollout status"))
            .collect::<Vec<_>>(),
        [
            "complete", "complete", "pending", "pending", "pending", "pending", "pending",
            "pending", "pending",
        ]
    );
    assert_eq!(
        neutral["compatibility_v1"],
        json!({
            "status": "current_unchanged",
            "record_version": 1,
            "parser_spec_id": "actionir-body.spec",
            "resolved_spec_id": "builtin:actionir-body.spec",
            "top_rule": "action_block",
            "result_policy": "replace_field",
            "result_field": "body_ast",
            "failure_policy": "fail",
            "source_provenance": "legacy copied exact text plus numeric offset and line span",
            "general_authoring": false,
            "upgrade_to_v2": "explicit_only",
        })
    );

    let job_later = json!({
        "kind": "parse_job",
        "job_id": "parse_job:function_body:functions.1.body_source:actionir-body.spec:action_block:40-51",
        "parent_ast_path": ["functions", "1", "body_source"],
        "node_kind": "function_definition",
        "payload_kind": "function_body",
        "text": "return(\"b\")",
        "source_span": {"start": 40, "end": 51, "line_start": 3, "line_end": 3},
        "parser_spec_id": "actionir-body.spec",
        "top_rule": "action_block",
        "result_policy": "replace_field",
        "result_field": "body_ast",
        "failure_policy": "fail",
        "diagnostic_owner": "function_body",
    });
    let job_earlier = json!({
        "kind": "parse_job",
        "job_id": "parse_job:function_body:functions.0.body_source:actionir-body.spec:action_block:10-21",
        "parent_ast_path": ["functions", "0", "body_source"],
        "node_kind": "function_definition",
        "payload_kind": "function_body",
        "text": "return(\"a\")",
        "source_span": {"start": 10, "end": 21, "line_start": 1, "line_end": 1},
        "parser_spec_id": "actionir-body.spec",
        "top_rule": "action_block",
        "result_policy": "replace_field",
        "result_field": "body_ast",
        "failure_policy": "fail",
        "diagnostic_owner": "function_body",
    });
    let mut wrong_top = job_earlier.clone();
    wrong_top["top_rule"] = json!("missing_top");
    let v1_results = execute_parse_jobs(&[job_later, job_earlier])
        .expect("current function-body v1 registry remains executable");
    assert_eq!(v1_results.len(), 2);
    assert_eq!(
        v1_results[0]["job_id"],
        "parse_job:function_body:functions.0.body_source:actionir-body.spec:action_block:10-21"
    );
    assert_eq!(v1_results[0]["queue_index"], 0);
    assert_eq!(
        v1_results[0]["phases"],
        json!(["resolve", "load", "compile", "execute"])
    );
    assert_eq!(
        v1_results[0]["resolved_spec_id"],
        "builtin:actionir-body.spec"
    );
    assert_eq!(v1_results[0]["registry_provider"], "builtin");
    assert_eq!(
        v1_results[0]["cache_key"]["kind"],
        "staged_parser_cache_key"
    );
    assert_eq!(v1_results[0]["result_policy"], "replace_field");
    assert_eq!(v1_results[0]["result_field"], "body_ast");
    assert_eq!(v1_results[0]["failure_policy"], "fail");
    assert_eq!(v1_results[0]["result"]["kind"], "action_block");
    let wrong_top_error = execute_parse_job(&wrong_top)
        .expect_err("current function-body v1 must reject an unsupported top rule");
    for context in [
        "phase=compile",
        "job_id=parse_job:function_body:functions.0.body_source:actionir-body.spec:action_block:10-21",
        "parent_ast_path=functions.0.body_source",
        "parser_spec_id=actionir-body.spec",
        "resolved_spec_id=builtin:actionir-body.spec",
        "top_rule=missing_top",
        "payload_kind=function_body",
        "source_span=10-21",
        "failure_policy=fail",
    ] {
        assert!(
            wrong_top_error.contains(context),
            "missing {context}: {wrong_top_error}"
        );
    }

    let general_job = json!({
        "kind": "parse_job",
        "job_id": "parse_job:v2:sha256:dormant-red",
        "parent_ast_path": ["Top", "job_marker"],
        "node_kind": "expression",
        "payload_kind": "embedded_expression",
        "text": "1+2",
        "source_span": {"start": 0, "end": 3, "line_start": 1, "line_end": 1},
        "parser_spec_id": "expr-v1",
        "top_rule": "Expr",
        "result_policy": "sibling_field",
        "result_field": "expression_ast",
        "failure_policy": "fail",
    });
    let general_error = execute_parse_job(&general_job)
        .expect_err("the current function-body adapter must reject general parser identity");
    assert!(general_error.contains("phase=resolve"), "{general_error}");
    assert!(
        general_error.contains("parser_spec_id=expr-v1"),
        "{general_error}"
    );
    assert!(
        general_error.contains("unsupported parser spec id 'expr-v1'"),
        "{general_error}"
    );

    let compiled = compile_source();
    let top = compiled.find("Top").expect("compiled Top rule");
    let preamble = top.preamble.as_ref().expect("staged-AST preamble");
    let Expr::AssignScalar { name, value } = &preamble.statements[0].expr else {
        panic!("parse_job must currently remain one generic scalar assignment");
    };
    assert_eq!(name, "job_marker");
    let Expr::Call { name, args } = value.as_ref() else {
        panic!("parse_job must currently remain one generic helper call");
    };
    assert_eq!(name, "parse_job");
    assert_eq!(args.len(), 2);

    let encoded = serde_json::to_string(&compiled).expect("serialize staged-AST fixture");
    assert_eq!(occurrences(&encoded, r#""name":"parse_job""#), 1);
    assert!(!encoded.contains("staged_parse_job_marker"));
    assert!(!encoded.contains("STAGED_PARSE_JOB_MARKER"));
    assert!(!encoded.contains("staged_parse_job_v2"));

    assert_eq!(
        Engine::new(compiled.clone())
            .execute_value("1+2;", &ExecutionOptions::new())
            .expect("native generic-fallback execution"),
        Value::Null
    );
    let reconstructed: CompiledSpec =
        serde_json::from_str(&encoded).expect("reconstruct staged-AST fixture");
    assert_eq!(
        Engine::new(reconstructed)
            .execute_value("1+2;", &ExecutionOptions::new())
            .expect("reconstructed generic-fallback execution"),
        Value::Null
    );
    assert_eq!(
        execute_generated_parser_v2(
            &encoded,
            PLAN,
            "1+2;",
            GENERATED_IDENTITY,
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("generated-plan generic-fallback execution"),
        Value::Null
    );

    let emitted =
        emit_rust_source_v2(&compiled, GENERATED_IDENTITY).expect("emit staged-AST fixture source");
    assert_eq!(occurrences(&emitted, r#"\"name\":\"parse_job\""#), 1);
    assert!(!emitted.contains("staged_parse_job_marker"));
    assert!(!emitted.contains("STAGED_PARSE_JOB_MARKER"));
    assert!(!emitted.contains("staged_parse_job_v2"));
    let project = EmittedProject::new();
    fs::write(
        project.root.join("Cargo.toml"),
        format!(
            "[package]\nname = \"staged-ast-enrichment-red\"\nversion = \"0.0.0\"\nedition = \"2024\"\n\n[dependencies]\nlinkedspec-runtime = {{ path = {:?} }}\nserde_json = \"1\"\n\n[workspace]\n",
            Path::new(env!("CARGO_MANIFEST_DIR"))
        ),
    )
    .expect("write emitted staged-AST manifest");
    fs::write(
        project.root.join("src/main.rs"),
        format!(
            "mod generated {{\n{emitted}\n}}\nfn main() {{ let value = generated::execute(\"1+2;\").expect(\"generated staged-AST RED\"); println!(\"{{}}\", value); }}\n"
        ),
    )
    .expect("write emitted staged-AST main");
    let child = Command::new("cargo")
        .arg("run")
        .arg("--offline")
        .arg("--quiet")
        .env(
            "CARGO_TARGET_DIR",
            Path::new(env!("CARGO_MANIFEST_DIR")).join("../target"),
        )
        .current_dir(&project.root)
        .output()
        .expect("run independently compiled staged-AST fixture");
    assert!(
        child.status.success(),
        "emitted staged-AST fixture failed:\n{}",
        String::from_utf8_lossy(&child.stderr)
    );
    assert_eq!(
        String::from_utf8(child.stdout)
            .expect("UTF-8 emitted stdout")
            .trim(),
        "null"
    );

    assert!(
        !CI_DRIVER_SOURCE.contains("staged_ast_enrichment_contract.rs"),
        "the dormant Rust consumer must remain absent from canonical CI"
    );

    assert!(
        encoded.contains(r#""kind":"staged_parse_job_marker""#),
        "LINKEDSPEC_STAGED_AST_ENRICHMENT_RED: missing node=[STAGED_PARSE_JOB_MARKER]; typed provenance sidecar=[staged_parse_job_v2] unavailable; generic parse_job helper fallback is not an implementation"
    );
}
