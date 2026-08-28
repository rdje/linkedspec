//! FUTURE-PARITY-BACKLOG.14.7.4.4 — admitted Rust staged-AST enrichment contract.
//!
//! The consumer freezes the neutral inventory, function-body v1 compatibility, private marker and
//! recursive authority, and four fresh-authority production carriers. Ordinary Cargo and canonical
//! CI each discover this exact target once.

use linkedspec_core::compiler::compile;
use linkedspec_core::expr::Expr;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, emit_rust_source_v2, execute_generated_parser_v2,
    execute_generated_parser_v2_with_options,
};
use linkedspec_runtime::source_location::SourceAuthority;
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use linkedspec_runtime::staged_parser_registry::{execute_parse_job, execute_parse_jobs};
use linkedspec_runtime::{
    CompiledStagedAuthority, FrozenStagedRegistry, StagedAstEnrichmentSeed,
    StagedRecursiveAuthority, StagedRuntimeContext, enrich_current_depth, enrich_recursively,
    evaluate_staged_chain_case, staged_cache_identity, staged_current_depth_order,
    staged_job_identity, validate_and_materialize_provenance,
};
use serde_json::{Value, json};
use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Arc, Mutex};
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
 /([^;]+);/ -> Top {
  job_marker = parse_job(entry_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", "result_policy", "sibling_field", "into", "expression_ast", "on_error", "fail"))
  return(job_marker)
 }
"#;
const CARRIER_SOURCE: &str = r#"Top::
 /([^;]+);/ -> Top {
  job_marker = parse_job(entry_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr", "top", "Expr", "result_policy", "sibling_field", "into", "expression_ast", "on_error", "fail"))
  return(hash("payload", job_marker))
 }
"#;
const PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
    label: "Top",
    family: "default",
}];
const EMITTED_CARRIER_SETUP: &str = r#"
use linkedspec_runtime::{CompiledStagedAuthority, StagedAstEnrichmentSeed};
use linkedspec_runtime::engine::ExecutionOptions;
use serde_json::{Value, json};
use std::collections::BTreeMap;
use std::sync::Arc;
use std::sync::atomic::{AtomicUsize, Ordering};

fn execution_options(
    neutral: &Value,
    calls: &Arc<AtomicUsize>,
    cancellation_checks: &Arc<AtomicUsize>,
    clock_checks: &Arc<AtomicUsize>,
) -> ExecutionOptions {
    let calls_for_callback = Arc::clone(calls);
    let authority = CompiledStagedAuthority::new(move |request, _context| {
        calls_for_callback.fetch_add(1, Ordering::SeqCst);
        Ok(json!({"kind": "expression", "text": request["text"]}))
    });
    let compiled = neutral["resolution_snapshot"]["entries"]
        .as_array().expect("registry entries").iter().map(|entry| (
            entry["compiled_authority"].as_str().expect("authority identity").to_owned(),
            authority.clone(),
        )).collect::<BTreeMap<_, _>>();
    let cancellation_checks = Arc::clone(cancellation_checks);
    let clock_checks = Arc::clone(clock_checks);
    let seed = StagedAstEnrichmentSeed::new(
        neutral["resolution_snapshot"].clone(),
        compiled,
        json!({
            "declaring_spec_id": "grammar/main.spec",
            "caller_capabilities": ["staged-parse-job-v2", "structured-result-v1", "typed-source-location-v1", "xml-v1", "yaml-v1"],
            "caller_policy_modes": ["append_child", "diagnostic_node", "fail", "keep_text", "replace_field", "replace_marker", "sibling_field", "trace"],
            "caller_ceilings": {"source_detail": "text", "max_steps": 200, "max_result_nodes": 128, "max_diagnostic_bytes": 8192},
            "required_source_detail": "identity",
            "required_versions": {"spec_language_version": 2, "helper_contract_version": "actionir-v3", "staged_contract_version": 2}
        }),
        json!({"cancellation_token": "emitted", "deadline": 100, "remaining_steps": 20, "required_steps": 1, "max_depth": 4, "max_calls": 10}),
        move |token| {
            cancellation_checks.fetch_add(1, Ordering::SeqCst);
            assert_eq!(token, &json!("emitted"));
            false
        },
        move || {
            clock_checks.fetch_add(1, Ordering::SeqCst);
            1
        },
    );
    ExecutionOptions::new().with_staged_ast_enrichment(seed)
}

fn main() {
    let neutral: Value = serde_json::from_str(include_str!("../contract.json"))
        .expect("staged neutral contract");
    let calls = Arc::new(AtomicUsize::new(0));
    let cancellation_checks = Arc::new(AtomicUsize::new(0));
    let clock_checks = Arc::new(AtomicUsize::new(0));
    let options = execution_options(&neutral, &calls, &cancellation_checks, &clock_checks);
    let first = generated::execute_with_options("1+2;", &options)
        .expect("first emitted staged enrichment");
    let second = generated::execute_with_options("1+2;", &options)
        .expect("second emitted staged enrichment");
    println!("{}", json!({
        "first": first,
        "second": second,
        "calls": calls.load(Ordering::SeqCst),
        "cancellation_checks": cancellation_checks.load(Ordering::SeqCst),
        "clock_checks": clock_checks.load(Ordering::SeqCst),
    }));
}
"#;

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
    compile_fixture(AUTHORED_SOURCE)
}

fn compile_fixture(source: &str) -> CompiledSpec {
    let parsed =
        parse_spec_with_user_functions(source).expect("parse exact staged-AST enrichment fixture");
    validate(&parsed).expect("validate exact staged-AST enrichment fixture");
    compile(&parsed).expect("compile exact staged-AST enrichment fixture")
}

fn staged_execution_options(
    neutral: &Value,
    identity: &str,
    calls: &Arc<AtomicUsize>,
    cancellation_checks: &Arc<AtomicUsize>,
    clock_checks: &Arc<AtomicUsize>,
) -> ExecutionOptions {
    let calls_for_callback = Arc::clone(calls);
    let authority = CompiledStagedAuthority::new(move |request, _context| {
        calls_for_callback.fetch_add(1, Ordering::SeqCst);
        Ok(json!({
            "kind": "expression",
            "text": request["text"],
        }))
    });
    let compiled = neutral["resolution_snapshot"]["entries"]
        .as_array()
        .expect("frozen registry entries")
        .iter()
        .map(|entry| {
            (
                entry["compiled_authority"]
                    .as_str()
                    .expect("opaque authority identity")
                    .to_owned(),
                authority.clone(),
            )
        })
        .collect::<BTreeMap<_, _>>();
    let cancellation_checks = Arc::clone(cancellation_checks);
    let clock_checks = Arc::clone(clock_checks);
    let expected_identity = identity.to_owned();
    let seed = StagedAstEnrichmentSeed::new(
        neutral["resolution_snapshot"].clone(),
        compiled,
        enrichment_options(),
        recursive_config(identity, 100, 20, 1, 4, 10),
        move |token| {
            cancellation_checks.fetch_add(1, Ordering::SeqCst);
            assert_eq!(token, &json!(expected_identity));
            false
        },
        move || {
            clock_checks.fetch_add(1, Ordering::SeqCst);
            1
        },
    );
    ExecutionOptions::new().with_staged_ast_enrichment(seed)
}

fn try_compile_source(source: &str) -> Result<CompiledSpec, String> {
    let parsed = parse_spec_with_user_functions(source).map_err(|error| error.to_string())?;
    validate(&parsed).map_err(|error| error.to_string())?;
    compile(&parsed).map_err(|error| error.to_string())
}

fn occurrences(haystack: &str, needle: &str) -> usize {
    haystack.match_indices(needle).count()
}

fn frozen_registry(neutral: &Value, authority: CompiledStagedAuthority) -> FrozenStagedRegistry {
    let compiled = neutral["resolution_snapshot"]["entries"]
        .as_array()
        .expect("frozen registry entries")
        .iter()
        .map(|entry| {
            (
                entry["compiled_authority"]
                    .as_str()
                    .expect("opaque authority identity")
                    .to_owned(),
                authority.clone(),
            )
        })
        .collect::<BTreeMap<_, _>>();
    FrozenStagedRegistry::from_value(&neutral["resolution_snapshot"], compiled)
        .expect("freeze caller-prepared staged registry")
}

fn enrichment_options() -> Value {
    json!({
        "declaring_spec_id": "grammar/main.spec",
        "caller_capabilities": [
            "staged-parse-job-v2",
            "structured-result-v1",
            "typed-source-location-v1",
            "xml-v1",
            "yaml-v1",
        ],
        "caller_policy_modes": [
            "append_child",
            "diagnostic_node",
            "fail",
            "keep_text",
            "replace_field",
            "replace_marker",
            "sibling_field",
            "trace",
        ],
        "caller_ceilings": {
            "source_detail": "text",
            "max_steps": 200,
            "max_result_nodes": 128,
            "max_diagnostic_bytes": 8192,
        },
        "required_source_detail": "identity",
        "required_versions": {
            "spec_language_version": 2,
            "helper_contract_version": "actionir-v3",
            "staged_contract_version": 2,
        },
    })
}

fn staged_marker(
    text: &str,
    start: u64,
    result_policy: &str,
    into: Option<&str>,
    failure_policy: &str,
) -> Value {
    let mut sidecar = json!({
        "kind": "staged_parse_job_v2",
        "version": 2,
        "state": "declared",
        "effect": "staged_parse_job_declaration",
        "node_kind": "expression",
        "payload_kind": "embedded_expression",
        "parser_spec_id": "expr",
        "top_rule": "Expr",
        "result_policy": result_policy,
        "failure_policy": failure_policy,
        "required_capabilities": ["typed-source-location-v1"],
        "text": text,
        "provenance": {
            "kind": "direct_span",
            "source_id": "ascii",
            "start": start,
            "end": start + u64::try_from(text.chars().count()).expect("text length fits u64"),
            "provenance": "capture",
        },
        "origin": "contract:parse_job",
    });
    if let Some(into) = into {
        sidecar["into"] = json!(into);
    }
    json!({
        "kind": "STAGED_PARSE_JOB_MARKER",
        "version": 2,
        "sidecar_kind": "staged_parse_job_v2",
        "effect": "staged_parse_job_declaration",
        "staged_parse_job_v2": sidecar,
    })
}

fn recursive_config(
    token: &str,
    deadline: u64,
    remaining_steps: u64,
    required_steps: u64,
    max_depth: u64,
    max_calls: u64,
) -> Value {
    json!({
        "cancellation_token": token,
        "deadline": deadline,
        "remaining_steps": remaining_steps,
        "required_steps": required_steps,
        "max_depth": max_depth,
        "max_calls": max_calls,
    })
}

fn assert_fresh_execution_pair(
    route: &str,
    first: &Value,
    second: &Value,
    calls: usize,
    cancellation_checks: usize,
    clock_checks: usize,
) {
    assert_eq!(
        first, second,
        "{route} top-level results must detach equally"
    );
    for result in [first, second] {
        assert_eq!(result["cache"]["entries"], 1, "{route} cache entries");
        assert_eq!(result["cache"]["hits"], 0, "{route} fresh cache hits");
        assert_eq!(result["cache"]["misses"], 1, "{route} fresh cache misses");
        assert_eq!(result["diagnostics"], json!([]), "{route} diagnostics");
        assert_eq!(result["sidecars"].as_array().map(Vec::len), Some(1));
        assert_eq!(result["ast"]["expression_ast"]["kind"], "expression");
        assert_eq!(result["ast"]["expression_ast"]["text"], "1+2");
    }
    assert_eq!(calls, 2, "{route} must invoke one fresh callback per run");
    assert!(
        cancellation_checks >= 2,
        "{route} must observe cancellation through each fresh authority"
    );
    assert!(
        clock_checks >= 2,
        "{route} must observe the caller clock through each fresh authority"
    );
}

fn prove_current_depth_authority(neutral: &Value) {
    let inert =
        CompiledStagedAuthority::new(|_request: &Value, _context: &mut StagedRuntimeContext| {
            Ok(json!({"kind": "ok"}))
        });
    let registry = frozen_registry(neutral, inert);

    for case in neutral["resolution_cases"]
        .as_array()
        .expect("resolution cases")
    {
        let result = registry.resolve_pre_registered(
            case["declaring_spec_id"].as_str().expect("declaring id"),
            case["parser_spec_id"].as_str().expect("parser id"),
            "contract:resolution",
        );
        if case["diagnostic"].is_null() {
            assert_eq!(
                result.expect("frozen resolution succeeds"),
                case["resolved_spec_id"],
                "{}",
                case["id"]
            );
        } else {
            assert_eq!(
                result.expect_err("frozen resolution rejects").as_record()["code"],
                case["diagnostic"],
                "{}",
                case["id"]
            );
        }
    }

    for case in neutral["authority_cases"]
        .as_array()
        .expect("authority cases")
    {
        let result = registry.evaluate_authority_case(case, "contract:authority");
        if case["accepted"].as_bool().expect("authority acceptance") {
            assert_eq!(
                result.expect("effective authority succeeds"),
                case["effective"],
                "{}",
                case["id"]
            );
        } else {
            assert_eq!(
                result.expect_err("effective authority rejects").as_record()["code"],
                case["diagnostic"],
                "{}",
                case["id"]
            );
        }
    }
    let mut forbidden_top = neutral["authority_cases"][0].clone();
    forbidden_top["top_rule"] = json!("MissingTop");
    assert_eq!(
        registry
            .evaluate_authority_case(&forbidden_top, "contract:forbidden-top")
            .expect_err("unregistered top rule rejects")
            .as_record()["code"],
        "staged_top_rule_forbidden"
    );

    for case in neutral["job_id_cases"].as_array().expect("job id cases") {
        let mut fields = case.clone();
        fields
            .as_object_mut()
            .expect("job case object")
            .remove("id");
        let expected = fields
            .as_object_mut()
            .expect("job case object")
            .remove("expected_job_id")
            .expect("expected job id");
        assert_eq!(
            staged_job_identity(&fields).expect("deterministic job id"),
            expected,
            "{}",
            case["id"]
        );
    }

    let mut base_cache_key = None;
    for case in neutral["cache_cases"].as_array().expect("cache cases") {
        let key = staged_cache_identity(&case["fields"]).expect("valid cache identity");
        if case["id"] == "base" {
            base_cache_key = Some(key.clone());
        }
        assert_eq!(
            key == *base_cache_key.as_ref().expect("base case ordered first"),
            case["same_as_base"],
            "{}",
            case["id"]
        );
    }

    for case in neutral["queue_cases"]
        .as_array()
        .expect("queue cases")
        .iter()
        .take(3)
    {
        assert_eq!(
            json!(staged_current_depth_order(&case["jobs"]).expect("current-depth queue order")),
            case["expected_order"],
            "{}",
            case["id"]
        );
    }
    assert_eq!(
        json!(
            staged_current_depth_order(&neutral["queue_cases"][3]["jobs"])
                .expect("mixed depths sort breadth-first")
        ),
        neutral["queue_cases"][3]["expected_order"]
    );

    for case in neutral["stitch_cases"].as_array().expect("stitch cases") {
        let result = case["result"].clone();
        let authority = CompiledStagedAuthority::new(
            move |_request: &Value, _context: &mut StagedRuntimeContext| Ok(result.clone()),
        );
        let registry = frozen_registry(neutral, authority);
        let mut parent = case["parent"].clone();
        let marker_field = case["marker_field"].as_str().expect("marker field");
        parent[marker_field] = staged_marker(
            case["text"].as_str().expect("marker text"),
            0,
            case["result_policy"].as_str().expect("result policy"),
            case["into"].as_str(),
            "fail",
        );
        let outcome = enrich_current_depth(&registry, &parent, &enrichment_options())
            .expect("result policy settles");
        assert_eq!(outcome.ast, case["expected_parent"], "{}", case["id"]);
        assert!(outcome.diagnostics.is_empty(), "{}", case["id"]);
        assert_eq!(outcome.sidecars[0]["state"], "succeeded", "{}", case["id"]);
    }

    for case in neutral["failure_cases"].as_array().expect("failure cases") {
        let authority = CompiledStagedAuthority::new(
            |_request: &Value, _context: &mut StagedRuntimeContext| {
                Err(json!({"code": "child_parse_error", "offset": 1}))
            },
        );
        let registry = frozen_registry(neutral, authority);
        let mut parent = case["parent"].clone();
        let marker_field = case["marker_field"].as_str().expect("marker field");
        parent[marker_field] = staged_marker(
            case["text"].as_str().expect("marker text"),
            0,
            case["result_policy"].as_str().expect("result policy"),
            case["into"].as_str(),
            case["failure_policy"].as_str().expect("failure policy"),
        );
        let result = enrich_current_depth(&registry, &parent, &enrichment_options());
        match case["failure_policy"].as_str().expect("failure policy") {
            "fail" => {
                let error = result.expect_err("fail policy aborts");
                assert_eq!(error.as_record()["code"], "staged_child_failed");
                assert_eq!(
                    parent[marker_field]["kind"], "STAGED_PARSE_JOB_MARKER",
                    "input AST remains unpublished"
                );
            }
            "keep_text" => {
                let outcome = result.expect("keep-text policy continues");
                assert_eq!(outcome.ast[marker_field], case["text"]);
                assert_eq!(outcome.ast["children"], json!([]));
                assert_eq!(outcome.diagnostics.len(), 1);
                assert_eq!(outcome.sidecars[0]["state"], "failed_keep_text");
            }
            "diagnostic_node" => {
                let outcome = result.expect("diagnostic-node policy continues");
                assert_eq!(outcome.ast[marker_field], case["text"]);
                assert_eq!(outcome.ast["ast"]["kind"], "staged_parse_diagnostic");
                assert_eq!(outcome.ast["ast"]["diagnostic"], outcome.diagnostics[0]);
                assert_eq!(outcome.sidecars[0]["state"], "failed_diagnostic_node");
                let required = neutral["diagnostics"]
                    .as_array()
                    .expect("diagnostics")
                    .iter()
                    .find(|row| row["code"] == "staged_child_failed")
                    .expect("child-failure diagnostic")["required_context"]
                    .as_array()
                    .expect("required context");
                for field in required {
                    let field = field.as_str().expect("context field");
                    assert!(
                        outcome.diagnostics[0].get(field).is_some(),
                        "missing staged_child_failed context {field}"
                    );
                }
            }
            policy => panic!("unexpected failure policy {policy}"),
        }
    }

    let observed_contexts = Arc::new(Mutex::new(Vec::new()));
    let observed_order = Arc::new(Mutex::new(Vec::new()));
    let callback_count = Arc::new(Mutex::new(0_u64));
    let authority = {
        let observed_contexts = Arc::clone(&observed_contexts);
        let observed_order = Arc::clone(&observed_order);
        let callback_count = Arc::clone(&callback_count);
        CompiledStagedAuthority::new(move |request: &Value, context: &mut StagedRuntimeContext| {
            observed_contexts
                .lock()
                .expect("context observations")
                .push(context.as_record());
            observed_order
                .lock()
                .expect("order observations")
                .push(request["text"].as_str().expect("request text").to_owned());
            *callback_count.lock().expect("callback count") += 1;
            context.set_cursor(9);
            context.marks_mut().insert("child".to_owned(), json!(1));
            context
                .captures_mut()
                .insert("capture".to_owned(), json!("local"));
            context
                .variables_mut()
                .insert("variable".to_owned(), json!(true));
            Ok(json!({"kind": "parsed", "text": request["text"]}))
        })
    };
    let registry = frozen_registry(neutral, authority);
    let ordered_ast = json!({
        "nodes": [
            {"payload": staged_marker("first", 4, "replace_marker", None, "fail")},
            {"payload": staged_marker("second", 1, "replace_marker", None, "fail")},
        ],
    });
    let first = enrich_current_depth(&registry, &ordered_ast, &enrichment_options())
        .expect("first current-depth run");
    assert_eq!(
        *observed_order.lock().expect("order observations"),
        ["first", "second"]
    );
    assert_eq!(
        *observed_contexts.lock().expect("context observations"),
        [
            json!({"cursor": 0, "marks": {}, "captures": {}, "variables": {}}),
            json!({"cursor": 0, "marks": {}, "captures": {}, "variables": {}}),
        ]
    );
    assert_eq!(first.cache.entries, 1);
    assert_eq!(first.cache.misses, 1);
    assert_eq!(first.cache.hits, 1);
    let second = enrich_current_depth(&registry, &ordered_ast, &enrichment_options())
        .expect("second current-depth run");
    assert_eq!(second.cache.entries, 1);
    assert_eq!(second.cache.misses, 1);
    assert_eq!(second.cache.hits, 3);
    assert_eq!(*callback_count.lock().expect("callback count"), 4);
    let isolated_registry = frozen_registry(
        neutral,
        CompiledStagedAuthority::new(|_request: &Value, _context: &mut StagedRuntimeContext| {
            Ok(json!(null))
        }),
    );
    assert_eq!(isolated_registry.cache_stats().entries, 0);
    assert_eq!(isolated_registry.cache_stats().hits, 0);
    assert_eq!(isolated_registry.cache_stats().misses, 0);

    let default_top_registry = frozen_registry(
        neutral,
        CompiledStagedAuthority::new(|_request: &Value, _context: &mut StagedRuntimeContext| {
            Ok(json!({"kind": "expr"}))
        }),
    );
    let mut default_top_marker = staged_marker("x", 0, "replace_marker", None, "fail");
    default_top_marker["staged_parse_job_v2"]
        .as_object_mut()
        .expect("marker sidecar")
        .remove("top_rule");
    let default_top = enrich_current_depth(
        &default_top_registry,
        &json!({"payload": default_top_marker}),
        &enrichment_options(),
    )
    .expect("entry default top is selected");
    assert_eq!(default_top.sidecars[0]["top_rule"], "Expr");
    let identity_fields = json!({
        "declaring_spec_id": "grammar/main.spec",
        "parent_ast_path": ["payload"],
        "node_kind": "expression",
        "payload_kind": "embedded_expression",
        "parser_spec_id": "expr",
        "top_rule": "Expr",
        "provenance": {
            "kind": "direct_span",
            "source_id": "ascii",
            "start": 0,
            "end": 1,
            "provenance": "capture",
        },
    });
    assert_eq!(
        default_top.sidecars[0]["job_id"],
        staged_job_identity(&identity_fields).expect("normalized-top job id")
    );

    let atomic_input = json!({
        "nodes": [
            {"payload": staged_marker("ok", 0, "replace_marker", None, "fail")},
            {"payload": staged_marker("bad", 2, "replace_marker", None, "fail")},
        ],
    });
    let atomic_registry = frozen_registry(
        neutral,
        CompiledStagedAuthority::new(|request: &Value, _context: &mut StagedRuntimeContext| {
            if request["text"] == "bad" {
                Err(json!({"code": "expected_failure"}))
            } else {
                Ok(json!({"kind": "first_result"}))
            }
        }),
    );
    assert_eq!(
        enrich_current_depth(&atomic_registry, &atomic_input, &enrichment_options())
            .expect_err("later fail policy aborts atomically")
            .as_record()["code"],
        "staged_child_failed"
    );
    assert_eq!(
        atomic_input["nodes"][0]["payload"]["kind"],
        "STAGED_PARSE_JOB_MARKER"
    );

    let invalid_callback_count = Arc::new(Mutex::new(0_u64));
    let invalid_registry = {
        let invalid_callback_count = Arc::clone(&invalid_callback_count);
        frozen_registry(
            neutral,
            CompiledStagedAuthority::new(
                move |_request: &Value, _context: &mut StagedRuntimeContext| {
                    *invalid_callback_count
                        .lock()
                        .expect("invalid callback count") += 1;
                    Ok(json!({"kind": "unexpected"}))
                },
            ),
        )
    };
    let collision = json!({
        "payload": staged_marker("x", 0, "sibling_field", Some("ast"), "fail"),
        "ast": {"kind": "occupied"},
    });
    assert_eq!(
        enrich_current_depth(&invalid_registry, &collision, &enrichment_options())
            .expect_err("sibling collision rejects before execution")
            .as_record()["code"],
        "staged_stitch_target_collision"
    );
    let invalid_append = json!({
        "payload": staged_marker("x", 0, "append_child", Some("children"), "fail"),
        "children": {},
    });
    assert_eq!(
        enrich_current_depth(&invalid_registry, &invalid_append, &enrichment_options())
            .expect_err("non-array append target rejects")
            .as_record()["code"],
        "staged_append_target_invalid"
    );
    let missing_into = json!({
        "payload": staged_marker("x", 0, "sibling_field", None, "fail"),
    });
    assert_eq!(
        enrich_current_depth(&invalid_registry, &missing_into, &enrichment_options())
            .expect_err("missing sibling target rejects")
            .as_record()["code"],
        "staged_stitch_target_missing"
    );
    let missing_replace_field = json!({
        "payload": staged_marker("x", 0, "replace_field", Some("ast"), "fail"),
    });
    assert_eq!(
        enrich_current_depth(
            &invalid_registry,
            &missing_replace_field,
            &enrichment_options(),
        )
        .expect_err("missing replace target rejects")
        .as_record()["code"],
        "staged_stitch_target_missing"
    );
    assert_eq!(
        *invalid_callback_count
            .lock()
            .expect("invalid callback count"),
        0
    );

    let stale_count = Arc::new(Mutex::new(0_u64));
    let stale_registry = {
        let stale_count = Arc::clone(&stale_count);
        frozen_registry(
            neutral,
            CompiledStagedAuthority::new(
                move |_request: &Value, _context: &mut StagedRuntimeContext| {
                    *stale_count.lock().expect("stale callback count") += 1;
                    Ok(json!({"kind": "replacement"}))
                },
            ),
        )
    };
    let stale = json!({
        "control": staged_marker("first", 0, "replace_field", Some("payload"), "fail"),
        "payload": staged_marker("second", 6, "replace_marker", None, "fail"),
    });
    assert_eq!(
        enrich_current_depth(&stale_registry, &stale, &enrichment_options())
            .expect_err("stale marker rejects")
            .as_record()["code"],
        "staged_marker_mismatch"
    );
    assert_eq!(*stale_count.lock().expect("stale callback count"), 1);

    let live_registry = frozen_registry(
        neutral,
        CompiledStagedAuthority::new(|_request: &Value, _context: &mut StagedRuntimeContext| {
            Ok(json!({"parser_handle": "live"}))
        }),
    );
    assert_eq!(
        enrich_current_depth(
            &live_registry,
            &json!({"payload": staged_marker("x", 0, "replace_marker", None, "fail")}),
            &enrichment_options(),
        )
        .expect_err("live result rejects")
        .as_record()["code"],
        "staged_result_not_detached"
    );
    let node_registry = frozen_registry(
        neutral,
        CompiledStagedAuthority::new(|_request: &Value, _context: &mut StagedRuntimeContext| {
            Ok(json!({"kind": "too_large", "children": [1, 2, 3]}))
        }),
    );
    let mut tight_options = enrichment_options();
    tight_options["caller_ceilings"]["max_result_nodes"] = json!(2);
    assert_eq!(
        enrich_current_depth(
            &node_registry,
            &json!({"payload": staged_marker("x", 0, "replace_marker", None, "fail")}),
            &tight_options,
        )
        .expect_err("node bound rejects")
        .as_record()["code"],
        "staged_result_node_limit_exceeded"
    );

    let failure_calls = Arc::new(Mutex::new(0_u64));
    let failure_registry = {
        let failure_calls = Arc::clone(&failure_calls);
        frozen_registry(
            neutral,
            CompiledStagedAuthority::new(
                move |_request: &Value, _context: &mut StagedRuntimeContext| {
                    *failure_calls.lock().expect("failure callback count") += 1;
                    Err(json!({"code": "repeatable_failure"}))
                },
            ),
        )
    };
    let failing_ast = json!({
        "payload": staged_marker("bad", 0, "replace_marker", None, "fail"),
    });
    for _ in 0..2 {
        assert!(
            enrich_current_depth(&failure_registry, &failing_ast, &enrichment_options()).is_err()
        );
    }
    assert_eq!(*failure_calls.lock().expect("failure callback count"), 2);
    assert_eq!(failure_registry.cache_stats().entries, 1);
    assert_eq!(failure_registry.cache_stats().misses, 1);
    assert_eq!(failure_registry.cache_stats().hits, 1);

    let partial_registry = frozen_registry(
        neutral,
        CompiledStagedAuthority::new(|_request: &Value, _context: &mut StagedRuntimeContext| {
            Ok(json!({"kind": "unused"}))
        }),
    );
    let mut unresolved = staged_marker("x", 0, "replace_marker", None, "fail");
    unresolved["staged_parse_job_v2"]["parser_spec_id"] = json!("missing-v1");
    assert!(
        enrich_current_depth(
            &partial_registry,
            &json!({"payload": unresolved}),
            &enrichment_options(),
        )
        .is_err()
    );
    assert_eq!(partial_registry.cache_stats().entries, 0);
    assert_eq!(partial_registry.cache_stats().hits, 0);
    assert_eq!(partial_registry.cache_stats().misses, 0);

    let nested_calls = Arc::new(Mutex::new(0_u64));
    let nested_marker = staged_marker("nested", 1, "replace_marker", None, "fail");
    let nested_registry = {
        let nested_calls = Arc::clone(&nested_calls);
        frozen_registry(
            neutral,
            CompiledStagedAuthority::new(
                move |_request: &Value, _context: &mut StagedRuntimeContext| {
                    *nested_calls.lock().expect("nested callback count") += 1;
                    Ok(nested_marker.clone())
                },
            ),
        )
    };
    let nested = enrich_current_depth(
        &nested_registry,
        &json!({"payload": staged_marker("outer", 0, "replace_marker", None, "fail")}),
        &enrichment_options(),
    )
    .expect("new marker remains inert at current depth");
    assert_eq!(nested.ast["payload"]["kind"], "STAGED_PARSE_JOB_MARKER");
    assert_eq!(*nested_calls.lock().expect("nested callback count"), 1);

    let panic_registry = frozen_registry(
        neutral,
        CompiledStagedAuthority::new(
            |_request: &Value, _context: &mut StagedRuntimeContext| -> Result<Value, Value> {
                panic!("contained child panic")
            },
        ),
    );
    let prior_panic_hook = std::panic::take_hook();
    std::panic::set_hook(Box::new(|_| {}));
    let panic_result = enrich_current_depth(
        &panic_registry,
        &json!({"payload": staged_marker("panic", 0, "replace_marker", None, "keep_text")}),
        &enrichment_options(),
    );
    std::panic::set_hook(prior_panic_hook);
    let panic_outcome = panic_result.expect("contained panic obeys keep-text policy");
    assert_eq!(panic_outcome.ast["payload"], "panic");
    assert_eq!(
        panic_outcome.diagnostics[0]["child_diagnostic"]["code"],
        "staged_child_exception"
    );
}

fn prove_recursive_authority(neutral: &Value) {
    for case in neutral["chain_cases"].as_array().expect("chain cases") {
        let actual = evaluate_staged_chain_case(case).expect("evaluate neutral chain case");
        assert_eq!(actual["accepted"], case["accepted"], "{}", case["id"]);
        assert_eq!(actual["diagnostic"], case["diagnostic"], "{}", case["id"]);
    }

    let observed = Arc::new(Mutex::new(Vec::new()));
    let cancelled_tokens = Arc::new(Mutex::new(Vec::new()));
    let retained_context = Arc::new(Mutex::new(None::<StagedRuntimeContext>));
    let authority = {
        let observed = Arc::clone(&observed);
        let retained_context = Arc::clone(&retained_context);
        CompiledStagedAuthority::new(move |request: &Value, context: &mut StagedRuntimeContext| {
            observed.lock().expect("recursive observations").push(json!({
                "depth": request["stage_depth"],
                "text": request["text"],
                "stage_chain_length": request["stage_chain"].as_array().expect("request chain").len(),
                "context": context.as_record(),
                "token": context.cancellation_token().expect("callback token"),
                "deadline": context.deadline().expect("callback deadline"),
                "remaining_before": context.remaining_steps().expect("callback budget"),
            }));
            if retained_context.lock().expect("retained context").is_none() {
                *retained_context.lock().expect("retained context") = Some(context.clone());
            }
            context.safe_point(1).map_err(|error| error.as_record())?;
            context.set_cursor(request["stage_depth"].as_u64().expect("stage depth"));
            context
                .marks_mut()
                .insert("child".to_owned(), request["text"].clone());
            Ok(match request["text"].as_str().expect("request text") {
                "abcdef" => json!({
                    "kind": "branch",
                    "child": staged_marker("bc", 1, "replace_marker", None, "fail"),
                }),
                "ghijkl" => json!({
                    "kind": "branch",
                    "child": staged_marker("hi", 7, "replace_marker", None, "fail"),
                }),
                text => json!({"kind": "leaf", "text": text}),
            })
        })
    };
    let registry = frozen_registry(neutral, authority);
    let recursive_authority = {
        let cancelled_tokens = Arc::clone(&cancelled_tokens);
        StagedRecursiveAuthority::new(
            &recursive_config("cancel:shared", 100, 20, 1, 4, 10),
            move |token| {
                cancelled_tokens
                    .lock()
                    .expect("cancel-token observations")
                    .push(token.clone());
                false
            },
            || 1,
        )
        .expect("recursive invocation authority")
    };
    let input = json!({
        "nodes": [
            {"payload": staged_marker("abcdef", 0, "replace_marker", None, "fail")},
            {"payload": staged_marker("ghijkl", 6, "replace_marker", None, "fail")},
        ],
    });
    let outcome = enrich_recursively(
        &registry,
        &input,
        &enrichment_options(),
        &recursive_authority,
    )
    .expect("breadth-first recursive enrichment");
    assert_eq!(
        *observed.lock().expect("recursive observations"),
        [
            json!({"depth": 1, "text": "abcdef", "stage_chain_length": 1, "context": {"cursor": 0, "marks": {}, "captures": {}, "variables": {}}, "token": "cancel:shared", "deadline": 100, "remaining_before": 19}),
            json!({"depth": 1, "text": "ghijkl", "stage_chain_length": 1, "context": {"cursor": 0, "marks": {}, "captures": {}, "variables": {}}, "token": "cancel:shared", "deadline": 100, "remaining_before": 17}),
            json!({"depth": 2, "text": "bc", "stage_chain_length": 2, "context": {"cursor": 0, "marks": {}, "captures": {}, "variables": {}}, "token": "cancel:shared", "deadline": 100, "remaining_before": 15}),
            json!({"depth": 2, "text": "hi", "stage_chain_length": 2, "context": {"cursor": 0, "marks": {}, "captures": {}, "variables": {}}, "token": "cancel:shared", "deadline": 100, "remaining_before": 13}),
        ]
    );
    assert!(
        cancelled_tokens
            .lock()
            .expect("cancel-token observations")
            .iter()
            .all(|token| token == "cancel:shared")
    );
    assert_eq!(
        outcome
            .sidecars
            .iter()
            .map(|row| row["stage_depth"].as_u64().expect("sidecar depth"))
            .collect::<Vec<_>>(),
        [1, 1, 2, 2]
    );
    assert_eq!(
        outcome
            .sidecars
            .iter()
            .map(|row| row["stage_chain"].as_array().expect("sidecar chain").len())
            .collect::<Vec<_>>(),
        [0, 0, 1, 1]
    );
    assert_eq!(outcome.ast["nodes"][0]["payload"]["child"]["kind"], "leaf");
    assert_eq!(outcome.ast["nodes"][1]["payload"]["child"]["text"], "hi");
    assert_eq!(outcome.resources.remaining_steps, 12);
    assert_eq!(outcome.resources.total_calls, 4);
    assert_eq!(outcome.resources.remaining_result_nodes, 116);
    assert_eq!(outcome.cache.entries, 1);
    assert_eq!(outcome.cache.misses, 1);
    assert_eq!(outcome.cache.hits, 3);
    assert!(outcome.diagnostics.is_empty());
    assert!(
        retained_context
            .lock()
            .expect("retained context")
            .as_ref()
            .expect("callback retained a context clone")
            .safe_point(0)
            .is_err(),
        "callback resource context must expire after return"
    );

    let cycle_calls = Arc::new(AtomicUsize::new(0));
    let cycle_marker = staged_marker("abcdef", 0, "replace_marker", None, "fail");
    let cycle_registry = {
        let cycle_calls = Arc::clone(&cycle_calls);
        let cycle_marker = cycle_marker.clone();
        frozen_registry(
            neutral,
            CompiledStagedAuthority::new(move |_request, _context| {
                cycle_calls.fetch_add(1, Ordering::SeqCst);
                Ok(cycle_marker.clone())
            }),
        )
    };
    let open_authority = StagedRecursiveAuthority::new(
        &recursive_config("cancel:cycle", 100, 20, 1, 4, 10),
        |_| false,
        || 1,
    )
    .expect("cycle authority");
    assert_eq!(
        enrich_recursively(
            &cycle_registry,
            &json!({"payload": cycle_marker}),
            &enrichment_options(),
            &open_authority,
        )
        .expect_err("exact active tuple must cycle")
        .as_record()["code"],
        "staged_cycle"
    );
    assert_eq!(cycle_calls.load(Ordering::SeqCst), 1);

    let nondecreasing_registry = frozen_registry(
        neutral,
        CompiledStagedAuthority::new(|_request, _context| {
            Ok(staged_marker("uvwxyz", 0, "replace_marker", None, "fail"))
        }),
    );
    assert_eq!(
        enrich_recursively(
            &nondecreasing_registry,
            &json!({"payload": staged_marker("abcdef", 0, "replace_marker", None, "fail")}),
            &enrichment_options(),
            &open_authority,
        )
        .expect_err("same parser/top extent must decrease")
        .as_record()["code"],
        "staged_chain_non_decreasing"
    );

    let nested_marker = staged_marker("bc", 1, "replace_marker", None, "fail");
    for (name, authority, expected) in [
        (
            "depth",
            StagedRecursiveAuthority::new(
                &recursive_config("cancel:depth", 100, 20, 1, 1, 10),
                |_| false,
                || 1,
            )
            .expect("depth authority"),
            "staged_depth_exceeded",
        ),
        (
            "calls",
            StagedRecursiveAuthority::new(
                &recursive_config("cancel:calls", 100, 20, 1, 4, 1),
                |_| false,
                || 1,
            )
            .expect("call authority"),
            "staged_call_limit_exceeded",
        ),
    ] {
        let marker = nested_marker.clone();
        let registry = frozen_registry(
            neutral,
            CompiledStagedAuthority::new(move |_request, _context| Ok(marker.clone())),
        );
        let error = enrich_recursively(
            &registry,
            &json!({"payload": staged_marker("abcdef", 0, "replace_marker", None, "fail")}),
            &enrichment_options(),
            &authority,
        )
        .expect_err("recursive limit must reject");
        assert_eq!(error.as_record()["code"], expected, "{name} limit");
    }

    let no_call_registry = frozen_registry(
        neutral,
        CompiledStagedAuthority::new(|_request, _context| Ok(json!(null))),
    );
    for (authority, expected) in [
        (
            StagedRecursiveAuthority::new(
                &recursive_config("cancel:budget", 100, 0, 1, 4, 10),
                |_| false,
                || 1,
            )
            .expect("budget authority"),
            "staged_budget_exhausted",
        ),
        (
            StagedRecursiveAuthority::new(
                &recursive_config("cancel:cancelled", 100, 20, 1, 4, 10),
                |_| true,
                || 1,
            )
            .expect("cancelled authority"),
            "staged_cancelled",
        ),
        (
            StagedRecursiveAuthority::new(
                &recursive_config("cancel:deadline", 10, 20, 1, 4, 10),
                |_| false,
                || 11,
            )
            .expect("deadline authority"),
            "staged_deadline_exceeded",
        ),
    ] {
        assert_eq!(
            enrich_recursively(
                &no_call_registry,
                &json!({"payload": staged_marker("x", 0, "replace_marker", None, "fail")}),
                &enrichment_options(),
                &authority,
            )
            .expect_err("dispatch resource denial")
            .as_record()["code"],
            expected
        );
    }

    let node_calls = Arc::new(AtomicUsize::new(0));
    let node_registry = {
        let node_calls = Arc::clone(&node_calls);
        frozen_registry(
            neutral,
            CompiledStagedAuthority::new(move |_request, _context| {
                node_calls.fetch_add(1, Ordering::SeqCst);
                Ok(json!({"kind": "leaf", "value": 1}))
            }),
        )
    };
    let mut node_options = enrichment_options();
    node_options["caller_ceilings"]["max_result_nodes"] = json!(5);
    assert_eq!(
        enrich_recursively(
            &node_registry,
            &json!({
                "nodes": [
                    {"payload": staged_marker("a", 0, "replace_marker", None, "fail")},
                    {"payload": staged_marker("b", 1, "replace_marker", None, "fail")},
                ],
            }),
            &node_options,
            &open_authority,
        )
        .expect_err("result-node budget is cumulative")
        .as_record()["code"],
        "staged_result_node_limit_exceeded"
    );
    assert_eq!(node_calls.load(Ordering::SeqCst), 2);

    let direct_registry = frozen_registry(
        neutral,
        CompiledStagedAuthority::new(|_request, context| {
            assert_eq!(
                context.rebase_position(1).expect("direct position"),
                json!({"source_id": "ascii", "offset": 2})
            );
            assert_eq!(
                context
                    .rebase_span(&json!({"start": 1, "end": 3}))
                    .expect("direct span"),
                json!({"kind": "direct_span", "source_id": "ascii", "start": 2, "end": 4, "provenance": "capture"})
            );
            Err(json!({
                "code": "child_parse_error",
                "position": {"offset": 1},
                "span": {"start": 1, "end": 3},
                "end_offset": 3,
            }))
        }),
    );
    let direct = enrich_recursively(
        &direct_registry,
        &json!({"payload": staged_marker("abcd", 1, "replace_marker", None, "keep_text")}),
        &enrichment_options(),
        &open_authority,
    )
    .expect("direct diagnostic rebasing continues");
    assert_eq!(
        direct.diagnostics[0]["child_diagnostic"]["position"],
        json!({"source_id": "ascii", "offset": 2})
    );
    assert_eq!(
        direct.diagnostics[0]["child_diagnostic"]["span"],
        json!({"kind": "direct_span", "source_id": "ascii", "start": 2, "end": 4, "provenance": "capture"})
    );
    assert_eq!(
        direct.diagnostics[0]["child_diagnostic"]["end_offset"],
        json!({"source_id": "ascii", "offset": 4})
    );

    let derived_registry = frozen_registry(
        neutral,
        CompiledStagedAuthority::new(|_request, context| {
            assert_eq!(
                context.rebase_position(2).expect("derived position"),
                json!({"source_id": "unicode", "offset": 1})
            );
            let span = context
                .rebase_span(&json!({"start": 1, "end": 3}))
                .expect("derived span");
            assert_eq!(span["kind"], "derived_text");
            assert_eq!(span["policy"], "concatenate_in_order");
            assert_eq!(
                span["segments"].as_array().expect("derived segments").len(),
                2
            );
            assert_eq!(
                context
                    .rebase_diagnostic(&json!({"code": "child", "span": {"start": 1, "end": 3}}))
                    .expect("derived diagnostic")["span"],
                span
            );
            Err(json!({"code": "child_parse_error", "span": {"start": 1, "end": 3}}))
        }),
    );
    let mut derived_marker = staged_marker("abcd", 0, "replace_marker", None, "keep_text");
    derived_marker["staged_parse_job_v2"]["provenance"] = json!({
        "kind": "derived_text",
        "policy": "concatenate_in_order",
        "segments": [
            {"kind": "direct_span", "source_id": "ascii", "start": 0, "end": 2, "provenance": "capture"},
            {"kind": "direct_span", "source_id": "unicode", "start": 1, "end": 3, "provenance": "capture"},
        ],
    });
    let derived = enrich_recursively(
        &derived_registry,
        &json!({"payload": derived_marker}),
        &enrichment_options(),
        &open_authority,
    )
    .expect("derived diagnostic rebasing continues");
    assert_eq!(
        derived.diagnostics[0]["child_diagnostic"]["span"]["policy"],
        "concatenate_in_order"
    );
    assert_eq!(
        derived.diagnostics[0]["child_diagnostic"]["span"]["segments"]
            .as_array()
            .expect("rebased child segments")
            .len(),
        2
    );

    let mut diagnostic_options = enrichment_options();
    diagnostic_options["caller_ceilings"]["max_diagnostic_bytes"] = json!(64);
    let diagnostic_registry = frozen_registry(
        neutral,
        CompiledStagedAuthority::new(|_request, _context| {
            Err(json!({"code": "child_parse_error", "detail": "x".repeat(1024)}))
        }),
    );
    let truncated = enrich_recursively(
        &diagnostic_registry,
        &json!({"payload": staged_marker("bad", 0, "replace_marker", None, "keep_text")}),
        &diagnostic_options,
        &open_authority,
    )
    .expect("oversized keep-text diagnostic is bounded");
    assert_eq!(
        truncated.diagnostics[0]["code"],
        "staged_diagnostic_truncated"
    );
    assert_eq!(truncated.resources.remaining_diagnostic_bytes, 0);

    let cancel_checks = Arc::new(AtomicUsize::new(0));
    let safe_cancel_authority = {
        let cancel_checks = Arc::clone(&cancel_checks);
        StagedRecursiveAuthority::new(
            &recursive_config("cancel:safe-point", 100, 20, 1, 4, 10),
            move |_| cancel_checks.fetch_add(1, Ordering::SeqCst) >= 1,
            || 1,
        )
        .expect("safe-point cancellation authority")
    };
    let safe_registry = frozen_registry(
        neutral,
        CompiledStagedAuthority::new(|_request, context| {
            Err(context
                .safe_point(0)
                .expect_err("safe point observes cancellation")
                .as_record())
        }),
    );
    assert_eq!(
        enrich_recursively(
            &safe_registry,
            &json!({"payload": staged_marker("x", 0, "replace_marker", None, "fail")}),
            &enrichment_options(),
            &safe_cancel_authority,
        )
        .expect_err("callback safe-point cancellation")
        .as_record()["code"],
        "staged_cancelled"
    );

    let clock_checks = Arc::new(AtomicUsize::new(0));
    let safe_deadline_authority = {
        let clock_checks = Arc::clone(&clock_checks);
        StagedRecursiveAuthority::new(
            &recursive_config("cancel:safe-deadline", 10, 20, 1, 4, 10),
            |_| false,
            move || {
                if clock_checks.fetch_add(1, Ordering::SeqCst) == 0 {
                    1
                } else {
                    11
                }
            },
        )
        .expect("safe-point deadline authority")
    };
    assert_eq!(
        enrich_recursively(
            &safe_registry,
            &json!({"payload": staged_marker("x", 0, "replace_marker", None, "fail")}),
            &enrichment_options(),
            &safe_deadline_authority,
        )
        .expect_err("callback safe-point deadline")
        .as_record()["code"],
        "staged_deadline_exceeded"
    );

    let narrowed_authority = StagedRecursiveAuthority::new(
        &recursive_config("cancel:narrowed", 100, 500, 0, 4, 10),
        |_| false,
        || 1,
    )
    .expect("caller-narrowed authority");
    let narrowed = enrich_recursively(
        &no_call_registry,
        &json!({"payload": staged_marker("x", 0, "replace_marker", None, "fail")}),
        &enrichment_options(),
        &narrowed_authority,
    )
    .expect("caller max-steps ceiling narrows invocation");
    assert_eq!(narrowed.resources.remaining_steps, 200);
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
fn final_path_admits_fresh_production_carriers() {
    let neutral = contract();
    assert_eq!(neutral["contract_id"], CONTRACT_ID);
    assert_eq!(neutral["format"], 1);
    assert_eq!(
        neutral["status"],
        "all_private_backends_complete_recurring_current_public_pending"
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
            "recurring_source_groups": 5,
            "recurring_runtime_routes": 6,
            "outward_guard_paths": 10,
            "diagnostics": 37,
            "rollout_legs": 9,
            "ownership_rows": 35,
            "mutations": 123,
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
        ["complete", "complete", "complete", "complete", "complete",]
    );
    assert_eq!(
        neutral["rollout"]
            .as_array()
            .expect("rollout rows")
            .iter()
            .map(|row| row["status"].as_str().expect("rollout status"))
            .collect::<Vec<_>>(),
        [
            "complete", "complete", "complete", "complete", "complete", "complete", "complete",
            "complete", "pending",
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

    let sources = neutral["sources"]
        .as_array()
        .expect("neutral sources")
        .iter()
        .map(|row| {
            (
                row["source_id"].as_str().expect("source id").to_owned(),
                row["text"].as_str().expect("source text").to_owned(),
            )
        })
        .collect::<BTreeMap<_, _>>();
    let source_authority = SourceAuthority::new(&sources);
    for case in neutral["provenance_cases"]
        .as_array()
        .expect("provenance cases")
    {
        let result = validate_and_materialize_provenance(
            &source_authority,
            &case["provenance"],
            "contract:parse_job",
        );
        if case["accepted"].as_bool().expect("accepted flag") {
            let result = result.unwrap_or_else(|error| panic!("{}: {error}", case["id"]));
            assert_eq!(result["text"], case["materialized_text"], "{}", case["id"]);
            assert_eq!(result["provenance"], case["provenance"], "{}", case["id"]);
        } else {
            let error = result.expect_err("invalid provenance must reject");
            assert_eq!(
                error.as_record()["code"],
                case["diagnostic"],
                "{}",
                case["id"]
            );
            assert_eq!(error.as_record()["phase"], "declare", "{}", case["id"]);
        }
    }

    let valid_options = r#"hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "fail")"#;
    let invalid_forms = [
        (
            "dynamic options",
            "job_marker = parse_job(match_group(0), options)".to_owned(),
            "staged_parse_job_options_required",
        ),
        (
            "unknown option",
            format!("job_marker = parse_job(match_group(0), hash(\"node_kind\", \"expression\", \"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", \"result_policy\", \"replace_marker\", \"on_error\", \"fail\", \"loader\", \"ambient\"))"),
            "staged_parse_job_option_unknown",
        ),
        (
            "duplicate option",
            format!("job_marker = parse_job(match_group(0), hash(\"node_kind\", \"expression\", \"node_kind\", \"expression\", \"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", \"result_policy\", \"replace_marker\", \"on_error\", \"fail\"))"),
            "staged_parse_job_options_required",
        ),
        (
            "missing required option",
            "job_marker = parse_job(match_group(0), hash(\"node_kind\", \"expression\", \"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", \"result_policy\", \"replace_marker\"))".to_owned(),
            "staged_parse_job_options_required",
        ),
        (
            "dynamic node kind",
            "job_marker = parse_job(match_group(0), hash(\"node_kind\", node_kind, \"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", \"result_policy\", \"replace_marker\", \"on_error\", \"fail\"))".to_owned(),
            "staged_parse_job_options_required",
        ),
        (
            "path-like parser identity",
            "job_marker = parse_job(match_group(0), hash(\"node_kind\", \"expression\", \"payload_kind\", \"embedded_expression\", \"spec\", \"../expr\", \"result_policy\", \"replace_marker\", \"on_error\", \"fail\"))".to_owned(),
            "staged_parser_identity_invalid",
        ),
        (
            "invalid top rule",
            "job_marker = parse_job(match_group(0), hash(\"node_kind\", \"expression\", \"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", \"top\", \"Expr/Bad\", \"result_policy\", \"replace_marker\", \"on_error\", \"fail\"))".to_owned(),
            "staged_top_rule_invalid",
        ),
        (
            "invalid result policy",
            "job_marker = parse_job(match_group(0), hash(\"node_kind\", \"expression\", \"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", \"result_policy\", \"replace\", \"on_error\", \"fail\"))".to_owned(),
            "staged_result_policy_invalid",
        ),
        (
            "invalid failure policy",
            "job_marker = parse_job(match_group(0), hash(\"node_kind\", \"expression\", \"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", \"result_policy\", \"replace_marker\", \"on_error\", \"retry\"))".to_owned(),
            "staged_failure_policy_invalid",
        ),
        (
            "replace marker with target",
            "job_marker = parse_job(match_group(0), hash(\"node_kind\", \"expression\", \"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", \"result_policy\", \"replace_marker\", \"into\", \"wrong\", \"on_error\", \"fail\"))".to_owned(),
            "staged_result_target_invalid",
        ),
        (
            "sibling without target",
            "job_marker = parse_job(match_group(0), hash(\"node_kind\", \"expression\", \"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", \"result_policy\", \"sibling_field\", \"on_error\", \"fail\"))".to_owned(),
            "staged_result_target_invalid",
        ),
        (
            "transformed copied text",
            format!("job_marker = parse_job(trim(match_group(0)), {valid_options})"),
            "staged_source_provenance_invalid",
        ),
        (
            "literal copied text",
            format!("job_marker = parse_job(\"copied\", {valid_options})"),
            "staged_source_provenance_invalid",
        ),
        (
            "dynamic capture index",
            format!("job_marker = parse_job(match_group(index), {valid_options})"),
            "staged_source_provenance_invalid",
        ),
        (
            "duplicate required capability",
            "job_marker = parse_job(match_group(0), hash(\"node_kind\", \"expression\", \"payload_kind\", \"embedded_expression\", \"spec\", \"expr-v1\", \"result_policy\", \"replace_marker\", \"on_error\", \"fail\", \"required_capabilities\", array(\"actionir-v1\", \"actionir-v1\")))".to_owned(),
            "staged_parse_job_options_required",
        ),
    ];
    for (name, statement, code) in invalid_forms {
        let source = format!("Top::\n /(x);/ -> Top {{ {statement}; return(job_marker) }}\n");
        let error = try_compile_source(&source).expect_err("invalid parse-job form must reject");
        assert!(error.contains(code), "{name}: expected {code}, got {error}");
    }
    let residual =
        format!("Top::\n /(x);/ -> Top {{ return(parse_job(match_group(0), {valid_options})) }}\n");
    let residual_error =
        try_compile_source(&residual).expect_err("residual generic parse_job must reject");
    assert!(
        residual_error.contains("staged_parse_job_options_required"),
        "{residual_error}"
    );

    let transaction_source = r#"Top::
 I { tx = recognition_checkpoint(); matched = recognize_once(tx, call(Child)); recognition_rollback(tx); return(matched) }
 /never/
Child::
 I { marker = parse_job(entry_text(), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "fail")); return(marker) }
 /never/
"#;
    let transaction_error = try_compile_source(transaction_source)
        .expect_err("recognition-reachable staged declaration must reject");
    assert!(
        transaction_error
            .contains("recognition_effect_forbidden:parser_registry_or_staged_dispatch"),
        "{transaction_error}"
    );

    let compiled = compile_source();
    let top = compiled.find("Top").expect("compiled Top rule");
    let declaration = top.acode_dispatch[0]
        .code
        .as_ref()
        .expect("staged-AST action code");
    let Expr::StagedParseJobMarker {
        target,
        version,
        sidecar_kind,
        effect,
        text_plan,
        options,
    } = &declaration.statements[0].expr
    else {
        panic!("parse_job assignment must compile to one dedicated expression");
    };
    assert_eq!(target, "job_marker");
    assert_eq!(*version, 2);
    assert_eq!(sidecar_kind, "staged_parse_job_v2");
    assert_eq!(effect, "staged_parse_job_declaration");
    assert_eq!(
        serde_json::to_value(text_plan).expect("serialize text plan"),
        json!({"kind": "direct_span", "source": "entry_group", "index": 0})
    );
    assert_eq!(
        serde_json::to_value(options).expect("serialize options"),
        json!({
            "node_kind": "expression",
            "payload_kind": "embedded_expression",
            "spec": "expr-v1",
            "top": "Expr",
            "result_policy": "sibling_field",
            "into": "expression_ast",
            "on_error": "fail",
            "required_capabilities": [],
        })
    );

    let encoded = serde_json::to_string(&compiled).expect("serialize staged-AST fixture");
    assert_eq!(occurrences(&encoded, r#""name":"parse_job""#), 0);
    assert_eq!(
        occurrences(&encoded, r#""kind":"staged_parse_job_marker""#),
        1
    );
    assert_eq!(occurrences(&encoded, "staged_parse_job_v2"), 1);

    let expected = json!({
        "kind": "STAGED_PARSE_JOB_MARKER",
        "version": 2,
        "sidecar_kind": "staged_parse_job_v2",
        "effect": "staged_parse_job_declaration",
        "staged_parse_job_v2": {
            "kind": "staged_parse_job_v2",
            "version": 2,
            "state": "declared",
            "effect": "staged_parse_job_declaration",
            "node_kind": "expression",
            "payload_kind": "embedded_expression",
            "parser_spec_id": "expr-v1",
            "top_rule": "Expr",
            "result_policy": "sibling_field",
            "into": "expression_ast",
            "failure_policy": "fail",
            "required_capabilities": [],
            "text": "1+2",
            "provenance": {
                "kind": "direct_span",
                "source_id": "input",
                "start": 0,
                "end": 3,
                "provenance": "entry_group",
            },
            "origin": "Top:parse_job",
        },
    });
    let native = Engine::new(compiled.clone())
        .execute_value("1+2;", &ExecutionOptions::new())
        .expect("native staged marker execution");
    assert_eq!(native, expected);
    let reconstructed: CompiledSpec =
        serde_json::from_str(&encoded).expect("reconstruct staged-AST fixture");
    assert_eq!(
        Engine::new(reconstructed)
            .execute_value("1+2;", &ExecutionOptions::new())
            .expect("reconstructed staged marker execution"),
        expected
    );
    assert_eq!(
        execute_generated_parser_v2(
            &encoded,
            PLAN,
            "1+2;",
            GENERATED_IDENTITY,
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("generated-plan staged marker execution"),
        expected
    );

    let derived_source = r#"Top::
 /(a)(a);/ -> Top { job_marker = parse_job(cat(match_group(0), match_group(1)), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "keep_text", "required_capabilities", array("typed-source-location-v1", "actionir-v1"))); return(job_marker) }
"#;
    let derived = Engine::new(try_compile_source(derived_source).expect("compile derived fixture"))
        .execute_value("aa;", &ExecutionOptions::new())
        .expect("execute derived fixture");
    assert_eq!(derived["staged_parse_job_v2"]["text"], "aa");
    assert_eq!(
        derived["staged_parse_job_v2"]["provenance"],
        json!({
            "kind": "derived_text",
            "policy": "concatenate_in_order",
            "segments": [
                {"kind": "direct_span", "source_id": "input", "start": 0, "end": 1, "provenance": "match_group"},
                {"kind": "direct_span", "source_id": "input", "start": 1, "end": 2, "provenance": "match_group"},
            ],
        })
    );
    assert_eq!(
        derived["staged_parse_job_v2"]["required_capabilities"],
        json!(["actionir-v1", "typed-source-location-v1"])
    );
    let detached = derived.clone();
    let mut mutated = derived;
    mutated["staged_parse_job_v2"]["provenance"]["segments"][0]["start"] = json!(99);
    assert_eq!(
        detached["staged_parse_job_v2"]["provenance"]["segments"][0]["start"],
        0
    );
    let serialized_outputs = serde_json::to_string(&expected).expect("serialize expected marker");
    for forbidden in [
        "path",
        "source_authority",
        "match_object",
        "registry",
        "compiled_authority",
        "callback",
        "host_handle",
        "cancellation_token",
        "deadline",
        "mutable_queue",
    ] {
        assert!(
            !serialized_outputs.contains(&format!(r#""{forbidden}""#)),
            "marker leaked forbidden key {forbidden}"
        );
    }

    let emitted =
        emit_rust_source_v2(&compiled, GENERATED_IDENTITY).expect("emit staged-AST fixture source");
    assert_eq!(occurrences(&emitted, r#"\"name\":\"parse_job\""#), 0);
    assert_eq!(
        occurrences(&emitted, r#"\"kind\":\"staged_parse_job_marker\""#),
        1
    );
    assert_eq!(occurrences(&emitted, "staged_parse_job_v2"), 1);
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
            "mod generated {{\n{emitted}\n}}\nfn main() {{ let value = generated::execute(\"1+2;\").expect(\"generated staged-AST marker\"); println!(\"{{}}\", value); }}\n"
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
    let emitted_value: Value = serde_json::from_slice(&child.stdout).expect("emitted marker JSON");
    assert_eq!(emitted_value, expected);

    let carrier_compiled = compile_fixture(CARRIER_SOURCE);
    let carrier_encoded =
        serde_json::to_string(&carrier_compiled).expect("serialize staged carrier fixture");
    let mut carrier_results = Vec::new();

    let native_calls = Arc::new(AtomicUsize::new(0));
    let native_cancellation_checks = Arc::new(AtomicUsize::new(0));
    let native_clock_checks = Arc::new(AtomicUsize::new(0));
    let native_options = staged_execution_options(
        &neutral,
        "native",
        &native_calls,
        &native_cancellation_checks,
        &native_clock_checks,
    );
    let native_engine = Engine::new(carrier_compiled.clone());
    let native_first = native_engine
        .execute_value("1+2;", &native_options)
        .expect("first native staged enrichment");
    let native_second = native_engine
        .execute_value("1+2;", &native_options)
        .expect("second native staged enrichment");
    assert_fresh_execution_pair(
        "native",
        &native_first,
        &native_second,
        native_calls.load(Ordering::SeqCst),
        native_cancellation_checks.load(Ordering::SeqCst),
        native_clock_checks.load(Ordering::SeqCst),
    );
    carrier_results.push(native_first);

    let reconstructed_calls = Arc::new(AtomicUsize::new(0));
    let reconstructed_cancellation_checks = Arc::new(AtomicUsize::new(0));
    let reconstructed_clock_checks = Arc::new(AtomicUsize::new(0));
    let reconstructed_options = staged_execution_options(
        &neutral,
        "reconstructed",
        &reconstructed_calls,
        &reconstructed_cancellation_checks,
        &reconstructed_clock_checks,
    );
    let reconstructed: CompiledSpec =
        serde_json::from_str(&carrier_encoded).expect("reconstruct staged carrier fixture");
    let reconstructed_engine = Engine::new(reconstructed);
    let reconstructed_first = reconstructed_engine
        .execute_value("1+2;", &reconstructed_options)
        .expect("first reconstructed staged enrichment");
    let reconstructed_second = reconstructed_engine
        .execute_value("1+2;", &reconstructed_options)
        .expect("second reconstructed staged enrichment");
    assert_fresh_execution_pair(
        "reconstructed",
        &reconstructed_first,
        &reconstructed_second,
        reconstructed_calls.load(Ordering::SeqCst),
        reconstructed_cancellation_checks.load(Ordering::SeqCst),
        reconstructed_clock_checks.load(Ordering::SeqCst),
    );
    carrier_results.push(reconstructed_first);

    let generated_calls = Arc::new(AtomicUsize::new(0));
    let generated_cancellation_checks = Arc::new(AtomicUsize::new(0));
    let generated_clock_checks = Arc::new(AtomicUsize::new(0));
    let generated_options = staged_execution_options(
        &neutral,
        "generated",
        &generated_calls,
        &generated_cancellation_checks,
        &generated_clock_checks,
    );
    let generated_first = execute_generated_parser_v2_with_options(
        &carrier_encoded,
        PLAN,
        "1+2;",
        GENERATED_IDENTITY,
        GENERATED_SOURCE_CONTRACT,
        &generated_options,
    )
    .expect("first generated-plan staged enrichment");
    let generated_second = execute_generated_parser_v2_with_options(
        &carrier_encoded,
        PLAN,
        "1+2;",
        GENERATED_IDENTITY,
        GENERATED_SOURCE_CONTRACT,
        &generated_options,
    )
    .expect("second generated-plan staged enrichment");
    assert_fresh_execution_pair(
        "generated-plan",
        &generated_first,
        &generated_second,
        generated_calls.load(Ordering::SeqCst),
        generated_cancellation_checks.load(Ordering::SeqCst),
        generated_clock_checks.load(Ordering::SeqCst),
    );
    carrier_results.push(generated_first);

    let carrier_emitted = emit_rust_source_v2(&carrier_compiled, GENERATED_IDENTITY)
        .expect("emit staged carrier fixture source");
    for forbidden in [
        "CompiledStagedAuthority",
        "StagedAstEnrichmentSeed",
        "FrozenStagedRegistry",
        "cancellation_token",
        "mutable_queue",
        "host_handle",
    ] {
        assert!(
            !carrier_emitted.contains(forbidden),
            "emitted logical carrier leaked {forbidden}"
        );
    }
    fs::write(project.root.join("contract.json"), CONTRACT_SOURCE)
        .expect("write emitted staged neutral contract");
    fs::write(
        project.root.join("src/main.rs"),
        [
            format!("mod generated {{\n{carrier_emitted}\n}}\n"),
            EMITTED_CARRIER_SETUP.to_owned(),
        ]
        .concat(),
    )
    .expect("write emitted staged carrier main");
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
        .expect("run independently compiled staged carrier fixture");
    assert!(
        child.status.success(),
        "emitted staged carrier fixture failed:\n{}",
        String::from_utf8_lossy(&child.stderr)
    );
    let emitted_run: Value =
        serde_json::from_slice(&child.stdout).expect("emitted staged carrier JSON");
    assert_fresh_execution_pair(
        "independently compiled emitted",
        &emitted_run["first"],
        &emitted_run["second"],
        emitted_run["calls"].as_u64().expect("emitted calls") as usize,
        emitted_run["cancellation_checks"]
            .as_u64()
            .expect("emitted cancellation checks") as usize,
        emitted_run["clock_checks"]
            .as_u64()
            .expect("emitted clock checks") as usize,
    );
    carrier_results.push(emitted_run["first"].clone());
    assert!(carrier_results.windows(2).all(|pair| pair[0] == pair[1]));

    let detached = carrier_results[0].clone();
    carrier_results[1]["ast"]["expression_ast"]["text"] = json!("mutated");
    assert_eq!(detached["ast"]["expression_ast"]["text"], "1+2");

    prove_current_depth_authority(&neutral);
    prove_recursive_authority(&neutral);

    assert!(
        CI_DRIVER_SOURCE.contains("staged_ast_enrichment_contract.rs"),
        "the admitted Rust consumer must be present in canonical CI"
    );
}
