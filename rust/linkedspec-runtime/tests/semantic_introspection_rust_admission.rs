//! FUTURE-PARITY-BACKLOG.10.4.6 — composed Rust semantic-introspection admission.

use linkedspec_core::compiler::compile;
use linkedspec_core::trace::TraceConfig;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::semantic_index::{
    SemanticIndex, SemanticIndexOptions, SemanticQuery, SemanticSnapshotState, SemanticSourceDetail,
};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, GeneratedRuleFamily, GeneratedRuleSpec,
    execute_generated_parser_v2_with_options, execute_generated_parser_with_trace_v2_with_options,
};
use linkedspec_runtime::spec_loader::{SpecLoadOptions, SpecRequest, load_and_compile_spec};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use linkedspec_runtime::{
    RUNTIME_SEMANTIC_OBSERVATION_CONTRACT, RuntimeSemanticObservationEvent,
    RuntimeSemanticObservationEventKind, RuntimeSemanticObservationSink,
};
use serde_json::{Value, json};
use sha2::{Digest, Sha256};
use std::cell::RefCell;
use std::collections::BTreeMap;
use std::fmt::Write;
use std::fs;
use std::path::{Path, PathBuf};
use std::rc::Rc;
use std::time::{SystemTime, UNIX_EPOCH};

const CONTRACT: &str =
    include_str!("../../../capability_conformance/semantic_introspection_contract.json");
const GRAPH: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/graph.spec");
const CALLS: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/calls_and_staging.spec");
const FAILED: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/failed.spec");
const RUNTIME: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/runtime.spec");
const RUNTIME_INPUT: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/runtime.input");
const PRIVACY: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/privacy.spec");
const CONSUMER_PATH: &str =
    "rust/linkedspec-runtime/tests/semantic_introspection_rust_admission.rs";
const CANONICAL_DRIVER: &str = "tools/run_ci_local.sh";
const SOURCE_IDENTITY: &str = "semantic-introspection/runtime.spec";
const INPUT_IDENTITY: &str =
    "input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece";
const RUNTIME_RESPONSE_DIGEST: &str =
    "36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887";
const ROLES: &[&str] = &[
    "source_normalization",
    "compiled_snapshots",
    "failed_snapshot",
    "runtime_direct",
    "runtime_loaded",
    "runtime_generated",
    "runtime_traced",
    "native_and_neutral_json",
    "exact_twenty_queries",
    "privacy_page_budget_error_explain",
    "query_non_interference",
    "stale_host_leak_denial",
];
const GENERATED_RULES: &[GeneratedRuleSpec] = &[GeneratedRuleSpec {
    label: "Top",
    family: GeneratedRuleFamily::RepAcode,
}];
const GENERATED_PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
    label: "Top",
    family: "rep_acode",
}];

fn contract() -> Value {
    serde_json::from_str(CONTRACT).expect("semantic contract parses")
}

fn query_case(case_id: &str) -> Value {
    contract()["query_cases"]
        .as_array()
        .expect("query cases")
        .iter()
        .find(|case| case["id"] == case_id)
        .unwrap_or_else(|| panic!("query case {case_id} exists"))
        .clone()
}

fn index(source: &[u8], logical_name: &str, ceiling: SemanticSourceDetail) -> SemanticIndex {
    SemanticIndex::from_utf8(source, SemanticIndexOptions::new(logical_name, ceiling))
        .expect("semantic fixture constructs")
}

fn index_for(snapshot: &str) -> SemanticIndex {
    match snapshot {
        "graph" => index(GRAPH, "graph.spec", SemanticSourceDetail::Text),
        "calls" => index(CALLS, "calls_and_staging.spec", SemanticSourceDetail::Text),
        "failed" => index(FAILED, "failed.spec", SemanticSourceDetail::Span),
        "privacy" => index(PRIVACY, "privacy.spec", SemanticSourceDetail::Text),
        "privacy_limited" => index(PRIVACY, "privacy.spec", SemanticSourceDetail::Identity),
        "runtime" => runtime_index(),
        other => panic!("unexpected semantic snapshot {other}"),
    }
}

fn runtime_source() -> &'static str {
    std::str::from_utf8(RUNTIME).expect("runtime source is UTF-8")
}

fn runtime_input() -> &'static str {
    std::str::from_utf8(RUNTIME_INPUT).expect("runtime input is UTF-8")
}

fn compiled_runtime() -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(runtime_source()).expect("parse runtime fixture");
    validate(&parsed).expect("validate runtime fixture");
    compile(&parsed).expect("compile runtime fixture")
}

fn canonical_digest<T: serde::Serialize>(value: &T) -> String {
    let value = serde_json::to_value(value).expect("value serializes");
    let digest = Sha256::digest(serde_json::to_vec(&value).expect("canonical value encodes"));
    let mut encoded = String::with_capacity(digest.len() * 2);
    for byte in digest {
        write!(&mut encoded, "{byte:02x}").expect("writing to String cannot fail");
    }
    encoded
}

fn observing_options() -> (
    ExecutionOptions,
    Rc<RefCell<Vec<RuntimeSemanticObservationEvent>>>,
) {
    let events = Rc::new(RefCell::new(Vec::new()));
    let captured = Rc::clone(&events);
    let sink = RuntimeSemanticObservationSink::new(move |event| {
        captured.borrow_mut().push(event);
    });
    (
        ExecutionOptions::new().with_semantic_observation_sink(sink),
        events,
    )
}

fn observe<F>(execute: F) -> (Value, Vec<RuntimeSemanticObservationEvent>)
where
    F: FnOnce(&ExecutionOptions) -> Value,
{
    let (options, events) = observing_options();
    let result = execute(&options);
    let events = events.borrow().clone();
    (result, events)
}

fn expected_events() -> Vec<RuntimeSemanticObservationEvent> {
    vec![
        RuntimeSemanticObservationEvent {
            contract_id: RUNTIME_SEMANTIC_OBSERVATION_CONTRACT.to_string(),
            event_kind: RuntimeSemanticObservationEventKind::RegexSlotSelected,
            rule_label: "Top".to_string(),
            target_rule: Some("Top".to_string()),
            regex_index: Some(0),
            position: 1,
            input_identity: None,
            status: None,
        },
        RuntimeSemanticObservationEvent {
            contract_id: RUNTIME_SEMANTIC_OBSERVATION_CONTRACT.to_string(),
            event_kind: RuntimeSemanticObservationEventKind::RegexSlotSelected,
            rule_label: "Top".to_string(),
            target_rule: Some("Top".to_string()),
            regex_index: Some(1),
            position: 2,
            input_identity: None,
            status: None,
        },
        RuntimeSemanticObservationEvent {
            contract_id: RUNTIME_SEMANTIC_OBSERVATION_CONTRACT.to_string(),
            event_kind: RuntimeSemanticObservationEventKind::RuleResult,
            rule_label: "Top".to_string(),
            target_rule: None,
            regex_index: None,
            position: 2,
            input_identity: Some(INPUT_IDENTITY.to_string()),
            status: Some("succeeded".to_string()),
        },
    ]
}

fn assert_runtime_route<F>(route: &str, execute: F) -> Vec<RuntimeSemanticObservationEvent>
where
    F: FnOnce(&ExecutionOptions) -> Value,
{
    let (result, events) = observe(execute);
    assert_eq!(result, json!(["A", "B"]), "{route} result");
    assert_eq!(events, expected_events(), "{route} observation");
    let derived = index(RUNTIME, "runtime.spec", SemanticSourceDetail::Text)
        .with_execution_observation(&events)
        .expect("derive runtime index");
    let response = derived.query_neutral(&query_case("runtime_events")["request"]);
    assert_eq!(
        canonical_digest(&response),
        RUNTIME_RESPONSE_DIGEST,
        "{route}"
    );
    events
}

fn runtime_index() -> SemanticIndex {
    let events = assert_runtime_route("runtime index", |options| {
        Engine::new(compiled_runtime())
            .execute_value(runtime_input(), options)
            .expect("execute runtime fixture")
    });
    index(RUNTIME, "runtime.spec", SemanticSourceDetail::Text)
        .with_execution_observation(&events)
        .expect("derive runtime index")
}

fn assert_case(index: &SemanticIndex, case: &Value) -> Value {
    let case_id = case["id"].as_str().expect("case id");
    let request_value = case["request"].clone();
    let request_before = request_value.clone();
    let request: SemanticQuery =
        serde_json::from_value(request_value.clone()).expect("canonical typed request");
    let typed = index.query(&request);
    let neutral = index.query_neutral(&request_value);
    assert_eq!(request_value, request_before, "{case_id} request isolation");
    assert_eq!(typed, neutral, "{case_id} typed/neutral identity");
    assert_eq!(typed.ok, case["expected"]["ok"], "{case_id} status");
    assert_eq!(
        typed
            .records
            .iter()
            .map(|record| record.id.as_str())
            .collect::<Vec<_>>(),
        case["expected"]["record_ids"]
            .as_array()
            .expect("expected record ids")
            .iter()
            .map(|id| id.as_str().expect("record id"))
            .collect::<Vec<_>>(),
        "{case_id} records"
    );
    assert_eq!(
        typed
            .relations
            .iter()
            .map(|relation| relation.id.as_str())
            .collect::<Vec<_>>(),
        case["expected"]["relation_ids"]
            .as_array()
            .expect("expected relation ids")
            .iter()
            .map(|id| id.as_str().expect("relation id"))
            .collect::<Vec<_>>(),
        "{case_id} relations"
    );
    assert_eq!(
        typed
            .diagnostics
            .iter()
            .map(|diagnostic| diagnostic.code.as_str())
            .collect::<Vec<_>>(),
        case["expected"]["diagnostic_codes"]
            .as_array()
            .expect("expected diagnostic codes")
            .iter()
            .map(|code| code.as_str().expect("diagnostic code"))
            .collect::<Vec<_>>(),
        "{case_id} diagnostics"
    );
    assert_eq!(typed.page.complete, case["expected"]["complete"]);
    assert_eq!(
        canonical_digest(&typed),
        case["expected"]["response_sha256"]
            .as_str()
            .expect("response digest"),
        "{case_id} response digest"
    );
    serde_json::to_value(typed).expect("response serializes")
}

fn role_source_normalization() {
    let decoded = std::str::from_utf8(PRIVACY).expect("privacy fixture is UTF-8");
    let raw = index(PRIVACY, "privacy.spec", SemanticSourceDetail::Text);
    let text = SemanticIndex::from_source(
        decoded,
        SemanticIndexOptions::new("privacy.spec", SemanticSourceDetail::Text),
    )
    .expect("decoded privacy fixture constructs");
    let case = query_case("privacy_text_and_digest");
    assert_eq!(assert_case(&raw, &case), assert_case(&text, &case));
}

fn role_compiled_snapshots() {
    for (snapshot, query) in [
        ("graph", "graph_list_rules"),
        ("calls", "calls_symbols_and_shapes"),
        ("privacy", "privacy_text_and_digest"),
    ] {
        let index = index_for(snapshot);
        assert!(index.compiled_authority_present(), "{snapshot} authority");
        assert!(!index.snapshot().has_execution, "{snapshot} stays static");
        assert_case(&index, &query_case(query));
    }
}

fn role_failed_snapshot() {
    let index = index_for("failed");
    assert!(!index.compiled_authority_present());
    assert_eq!(
        index.snapshot().state,
        SemanticSnapshotState::FailedCompilation
    );
    assert_case(&index, &query_case("failed_diagnostic"));
}

fn role_runtime_direct() {
    assert_runtime_route("direct", |options| {
        Engine::new(compiled_runtime())
            .execute_value(runtime_input(), options)
            .expect("direct execution")
    });
}

fn role_runtime_loaded() {
    let compiled = compiled_runtime();
    let encoded = serde_json::to_string(&compiled).expect("serialize compiled fixture");
    let reconstructed: CompiledSpec =
        serde_json::from_str(&encoded).expect("reconstruct compiled fixture");
    assert_runtime_route("reconstructed", |options| {
        Engine::new(reconstructed)
            .execute_value(runtime_input(), options)
            .expect("reconstructed execution")
    });

    let scratch = ScratchDirectory::new("semantic-admission-loaded");
    let source_path = scratch.path().join("runtime.spec");
    fs::write(&source_path, RUNTIME).expect("write loaded fixture");
    let loaded = load_and_compile_spec(
        &SpecRequest::path(source_path.to_string_lossy().into_owned()),
        &SpecLoadOptions::new(scratch.path()),
    )
    .expect("load runtime fixture");
    assert_runtime_route("loaded", |options| {
        loaded
            .into_engine()
            .execute_value(runtime_input(), options)
            .expect("loaded execution")
    });
}

fn role_runtime_generated() {
    let compiled = compiled_runtime();
    let encoded = serde_json::to_string(&compiled).expect("serialize compiled fixture");
    assert_runtime_route("generated plan", |options| {
        Engine::new(compiled)
            .execute_generated_value_with_plan_and_options(
                GENERATED_RULES,
                runtime_input(),
                options,
            )
            .expect("generated-plan execution")
    });
    assert_runtime_route("emitted source", |options| {
        execute_generated_parser_v2_with_options(
            &encoded,
            GENERATED_PLAN,
            runtime_input(),
            SOURCE_IDENTITY,
            GENERATED_SOURCE_CONTRACT,
            options,
        )
        .expect("emitted-source execution")
    });
}

fn role_runtime_traced() {
    let compiled = compiled_runtime();
    let encoded = serde_json::to_string(&compiled).expect("serialize compiled fixture");
    assert_runtime_route("direct traced", |options| {
        Engine::new(compiled.clone())
            .execute_value_with_trace(runtime_input(), options, TraceConfig::disabled())
            .expect("direct traced execution")
    });
    assert_runtime_route("generated traced", |options| {
        Engine::new(compiled)
            .execute_generated_with_plan_with_trace_roles_and_options(
                GENERATED_RULES,
                runtime_input(),
                TraceConfig::disabled(),
                SOURCE_IDENTITY,
                options,
            )
            .expect("generated traced execution")
    });
    assert_runtime_route("emitted traced", |options| {
        execute_generated_parser_with_trace_v2_with_options(
            &encoded,
            GENERATED_PLAN,
            runtime_input(),
            TraceConfig::disabled(),
            SOURCE_IDENTITY,
            GENERATED_SOURCE_CONTRACT,
            options,
        )
        .expect("emitted traced execution")
    });
}

fn role_native_and_neutral_json() {
    let index = index_for("graph");
    let case = query_case("capabilities");
    let request: SemanticQuery =
        serde_json::from_value(case["request"].clone()).expect("typed capabilities request");
    let mut native = index.capabilities();
    assert_eq!(native, index.query(&request));
    let neutral = serde_json::to_value(&native).expect("native response serializes");
    let encoded = serde_json::to_string(&neutral).expect("neutral response encodes");
    assert_eq!(
        serde_json::from_str::<Value>(&encoded).expect("neutral response decodes"),
        neutral
    );
    native.records[0].facts["record_kinds"][0] = json!("host_private_kind");
    assert_eq!(
        canonical_digest(&index.capabilities()),
        case["expected"]["response_sha256"]
            .as_str()
            .expect("capabilities digest")
    );
}

fn role_exact_twenty_queries() {
    let contract = contract();
    let cases = contract["query_cases"].as_array().expect("query cases");
    assert_eq!(cases.len(), 20);
    for case in cases {
        let snapshot = case["snapshot"].as_str().expect("snapshot id");
        assert_case(&index_for(snapshot), case);
    }
}

fn role_privacy_page_budget_error_explain() {
    let privacy = assert_case(&index_for("privacy"), &query_case("privacy_none"));
    assert!(privacy["records"][0]["source"].is_null());
    assert_eq!(
        privacy["records"][0]["redactions"],
        json!(["/facts/pattern"])
    );

    let text = assert_case(
        &index_for("privacy"),
        &query_case("privacy_text_and_digest"),
    );
    assert_eq!(text["records"][0]["facts"]["pattern"], "é");
    assert!(
        text["records"][0]["source"]["content_digest"]
            .as_str()
            .is_some_and(|digest| digest.starts_with("sha256:"))
    );

    for (case_id, code) in [
        ("budget_prefix", "semantic_query_budget_exceeded"),
        ("relation_budget_prefix", "semantic_query_budget_exceeded"),
        (
            "source_ceiling_forbidden",
            "semantic_query_source_detail_forbidden",
        ),
        (
            "unsupported_contract",
            "semantic_query_contract_unsupported",
        ),
        ("invalid_operation_combination", "semantic_query_invalid"),
    ] {
        let case = query_case(case_id);
        let response = assert_case(
            &index_for(case["snapshot"].as_str().expect("snapshot id")),
            &case,
        );
        assert_eq!(response["diagnostics"][0]["code"], code);
    }

    let explanation = assert_case(&index_for("graph"), &query_case("graph_explain_entry"));
    assert!(
        explanation["records"]
            .as_array()
            .expect("explanation records")
            .iter()
            .any(|record| record["kind"] == "explanation_step")
    );
}

fn role_query_non_interference() {
    let index = index_for("graph");
    let case = query_case("graph_explain_entry");
    let request = case["request"].clone();
    assert!(!index.snapshot().has_execution);
    let mut first = index.query_neutral(&request);
    let second = index.query_neutral(&request);
    assert_eq!(first, second);
    assert!(!index.snapshot().has_execution);
    first.records[0].facts["outcome"] = json!("mutated");
    assert_eq!(
        canonical_digest(&index.query_neutral(&request)),
        case["expected"]["response_sha256"]
            .as_str()
            .expect("explanation digest")
    );
}

fn role_stale_host_leak_denial() {
    let contract = contract();
    let mut responses = Vec::new();
    for case in contract["query_cases"].as_array().expect("query cases") {
        responses.push(assert_case(
            &index_for(case["snapshot"].as_str().expect("snapshot id")),
            case,
        ));
    }
    let encoded = serde_json::to_string(&responses).expect("responses encode");
    for forbidden in [
        "/Users/",
        "/private/tmp/",
        "CompiledSpec",
        "ActionIR",
        "RuntimeSemanticObservationEvent",
        "generated_implementation_source",
        "0x",
    ] {
        assert!(!encoded.contains(forbidden), "host leak: {forbidden}");
    }
}

#[test]
fn composed_rust_semantic_admission_executes_every_role_exactly_once() {
    let roles: [(&str, fn()); 12] = [
        ("source_normalization", role_source_normalization),
        ("compiled_snapshots", role_compiled_snapshots),
        ("failed_snapshot", role_failed_snapshot),
        ("runtime_direct", role_runtime_direct),
        ("runtime_loaded", role_runtime_loaded),
        ("runtime_generated", role_runtime_generated),
        ("runtime_traced", role_runtime_traced),
        ("native_and_neutral_json", role_native_and_neutral_json),
        ("exact_twenty_queries", role_exact_twenty_queries),
        (
            "privacy_page_budget_error_explain",
            role_privacy_page_budget_error_explain,
        ),
        ("query_non_interference", role_query_non_interference),
        ("stale_host_leak_denial", role_stale_host_leak_denial),
    ];
    assert_eq!(
        roles.iter().map(|(name, _)| *name).collect::<Vec<_>>(),
        ROLES
    );
    let mut completed = BTreeMap::new();
    for (name, role) in roles {
        role();
        *completed.entry(name).or_insert(0_usize) += 1;
    }
    assert_eq!(
        completed,
        ROLES
            .iter()
            .map(|role| (*role, 1_usize))
            .collect::<BTreeMap<_, _>>()
    );

    let contract = contract();
    let admission = contract["target_admissions"]
        .as_array()
        .expect("target admissions")
        .iter()
        .find(|row| row["backend"] == "rust" && row["runtime"] == "rust")
        .expect("Rust admission row");
    assert_eq!(admission["status"], "complete");
    assert_eq!(
        admission["consumer"],
        json!({
            "path": CONSUMER_PATH,
            "canonical_driver": CANONICAL_DRIVER,
            "roles": ROLES,
        })
    );
    let rollout = contract["rollout"]
        .as_array()
        .expect("rollout")
        .iter()
        .find(|row| row["capability"] == "rust_parity")
        .expect("Rust rollout row");
    assert_eq!(rollout["status"], "complete");
    assert!(
        contract["canonical_ci"]["required_tracked_files"]
            .as_array()
            .expect("required tracked files")
            .iter()
            .any(|path| path == CONSUMER_PATH)
    );
}

struct ScratchDirectory {
    path: PathBuf,
}

impl ScratchDirectory {
    fn new(label: &str) -> Self {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("system time after Unix epoch")
            .as_nanos();
        let path =
            std::env::temp_dir().join(format!("linkedspec-{label}-{}-{nanos}", std::process::id()));
        fs::create_dir_all(&path).expect("create scratch directory");
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
