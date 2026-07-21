use linkedspec_core::compiler::compile;
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::semantic_index::{
    SemanticIndex, SemanticIndexOptions, SemanticQuery, SemanticSourceDetail,
};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, GeneratedRuleFamily, GeneratedRuleSpec,
    emit_rust_source_v2, execute_generated_parser_v2_with_options,
    execute_generated_parser_with_trace_v2_with_options,
};
use linkedspec_runtime::spec_loader::{SpecLoadOptions, SpecRequest, load_and_compile_spec};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use linkedspec_runtime::{
    RUNTIME_SEMANTIC_OBSERVATION_CONTRACT, RuntimeDiagnosticOutputEvent,
    RuntimeDiagnosticOutputSink, RuntimeSemanticObservationEvent,
    RuntimeSemanticObservationEventKind, RuntimeSemanticObservationSink,
};
use serde_json::{Value, json};
use sha2::{Digest, Sha256};
use std::cell::RefCell;
use std::convert::Infallible;
use std::fmt::Write;
use std::fs;
use std::panic::{AssertUnwindSafe, catch_unwind};
use std::path::{Path, PathBuf};
use std::process::Command;
use std::rc::Rc;
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};

const CONTRACT: &str =
    include_str!("../../../capability_conformance/semantic_introspection_contract.json");
const SOURCE: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/runtime.spec");
const INPUT: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/runtime.input");
const SOURCE_IDENTITY: &str = "semantic-introspection/runtime.spec";
const INPUT_IDENTITY: &str =
    "input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece";
const RESPONSE_DIGEST: &str = "36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887";
const GENERATED_RULES: &[GeneratedRuleSpec] = &[GeneratedRuleSpec {
    label: "Top",
    family: GeneratedRuleFamily::RepAcode,
}];
const GENERATED_PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
    label: "Top",
    family: "rep_acode",
}];

fn source() -> &'static str {
    std::str::from_utf8(SOURCE).expect("canonical runtime source is UTF-8")
}

fn input() -> &'static str {
    std::str::from_utf8(INPUT).expect("canonical runtime input is UTF-8")
}

fn compiled() -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source()).expect("parse runtime fixture");
    validate(&parsed).expect("validate runtime fixture");
    compile(&parsed).expect("compile runtime fixture")
}

fn base_index() -> SemanticIndex {
    SemanticIndex::from_utf8(
        SOURCE,
        SemanticIndexOptions::new("runtime.spec", SemanticSourceDetail::Text),
    )
    .expect("construct runtime semantic index")
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

fn observed<F>(execute: F) -> (Value, Vec<RuntimeSemanticObservationEvent>)
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

fn runtime_query_case() -> Value {
    let contract: Value = serde_json::from_str(CONTRACT).expect("semantic contract parses");
    contract["query_cases"]
        .as_array()
        .expect("query cases")
        .iter()
        .find(|case| case["id"] == "runtime_events")
        .expect("runtime query case")
        .clone()
}

fn canonical_digest<T: serde::Serialize>(value: &T) -> String {
    let canonical = serde_json::to_value(value).expect("canonical value serializes");
    let bytes = serde_json::to_vec(&canonical).expect("canonical value encodes");
    let digest = Sha256::digest(bytes);
    let mut encoded = String::with_capacity(digest.len() * 2);
    for byte in digest {
        write!(&mut encoded, "{byte:02x}").expect("writing to String cannot fail");
    }
    encoded
}

#[test]
fn direct_loaded_reconstructed_generated_and_traced_routes_are_exact() {
    assert_eq!(input(), "ab\n");
    let compiled = compiled();
    let compiled_json = serde_json::to_string(&compiled).expect("serialize compiled fixture");
    let reconstructed: CompiledSpec =
        serde_json::from_str(&compiled_json).expect("reconstruct compiled fixture");
    let scratch = ScratchDirectory::new("loaded-route");
    let source_path = scratch.path().join("runtime.spec");
    fs::write(&source_path, SOURCE).expect("write loaded runtime fixture");
    let loaded = load_and_compile_spec(
        &SpecRequest::path(source_path.to_string_lossy().into_owned()),
        &SpecLoadOptions::new(scratch.path()),
    )
    .expect("load runtime fixture");

    let routes = vec![
        observed(|options| {
            Engine::new(compiled.clone())
                .execute_value(input(), options)
                .expect("direct observed execution")
        }),
        observed(|options| {
            loaded
                .into_engine()
                .execute_value(input(), options)
                .expect("loaded observed execution")
        }),
        observed(|options| {
            Engine::new(reconstructed)
                .execute_value(input(), options)
                .expect("reconstructed observed execution")
        }),
        observed(|options| {
            Engine::new(compiled.clone())
                .execute_generated_value_with_plan_and_options(GENERATED_RULES, input(), options)
                .expect("generated-plan observed execution")
        }),
        observed(|options| {
            Engine::new(compiled.clone())
                .execute_value_with_trace(input(), options, TraceConfig::disabled())
                .expect("direct traced observed execution")
        }),
        observed(|options| {
            Engine::new(compiled.clone())
                .execute_generated_with_plan_with_trace_roles_and_options(
                    GENERATED_RULES,
                    input(),
                    TraceConfig::disabled(),
                    SOURCE_IDENTITY,
                    options,
                )
                .expect("generated traced observed execution")
        }),
        observed(|options| {
            execute_generated_parser_v2_with_options(
                &compiled_json,
                GENERATED_PLAN,
                input(),
                SOURCE_IDENTITY,
                GENERATED_SOURCE_CONTRACT,
                options,
            )
            .expect("source-emitter direct observed execution")
        }),
        observed(|options| {
            execute_generated_parser_with_trace_v2_with_options(
                &compiled_json,
                GENERATED_PLAN,
                input(),
                TraceConfig::disabled(),
                SOURCE_IDENTITY,
                GENERATED_SOURCE_CONTRACT,
                options,
            )
            .expect("source-emitter traced observed execution")
        }),
    ];

    for (result, events) in routes {
        assert_eq!(result, json!(["A", "B"]));
        assert_eq!(events, expected_events());
    }
    assert_eq!(source(), std::str::from_utf8(SOURCE).unwrap());
}

#[test]
fn runtime_derivation_is_immutable_and_matches_the_twentieth_digest() {
    let base = base_index();
    let (_, mut events) = observed(|options| {
        Engine::new(compiled())
            .execute_value(input(), options)
            .expect("capture completed runtime observation")
    });
    let query_case = runtime_query_case();
    let request = query_case["request"].clone();
    let base_response = base.query_neutral(&request);
    assert!(!base.snapshot().has_execution);
    assert!(base_response.records.is_empty());

    let derived = base
        .with_execution_observation(&events)
        .expect("derive runtime semantic index");
    assert!(derived.snapshot().has_execution);
    let mut response = derived.query_neutral(&request);
    let typed_request: SemanticQuery =
        serde_json::from_value(request.clone()).expect("runtime request is typed");
    assert_eq!(response, derived.query(&typed_request));
    assert_eq!(
        response
            .records
            .iter()
            .map(|record| record.id.as_str())
            .collect::<Vec<_>>(),
        [
            "execution:0",
            "event:execution:0:0",
            "event:execution:0:1",
            "event:execution:0:2",
        ]
    );
    assert_eq!(
        canonical_digest(&response),
        RESPONSE_DIGEST,
        "runtime response:\n{}",
        serde_json::to_string_pretty(&response).expect("format runtime response")
    );

    events[0].position = 999;
    response.records[0].facts["status"] = json!("mutated");
    assert_eq!(
        canonical_digest(&derived.query_neutral(&request)),
        RESPONSE_DIGEST,
        "caller event/response mutation cannot alter the retained projection"
    );
    assert!(!base.snapshot().has_execution);
    assert!(base.query_neutral(&request).records.is_empty());
}

#[test]
fn failed_execution_never_claims_a_completed_rule_result() {
    let (options, events) = observing_options();
    let options = options.with_entry_rule("Missing");
    Engine::new(compiled())
        .execute_value(input(), &options)
        .expect_err("unknown entry selection must fail");
    let events = events.borrow();
    assert!(events.is_empty());
    assert!(
        events
            .iter()
            .all(|event| event.event_kind != RuntimeSemanticObservationEventKind::RuleResult)
    );

    let failing_source = "Top::\n /a/\n LE { exit_now(17) }\n";
    let parsed = parse_spec_with_user_functions(failing_source).expect("parse failing fixture");
    validate(&parsed).expect("validate failing fixture");
    let (options, events) = observing_options();
    Engine::new(compile(&parsed).expect("compile failing fixture"))
        .execute_value("a", &options)
        .expect_err("post-match lifecycle failure must fail the invocation");
    let events = events.borrow();
    assert_eq!(events.len(), 1, "the accepted slot remains observable");
    assert_eq!(
        events[0].event_kind,
        RuntimeSemanticObservationEventKind::RegexSlotSelected
    );
    assert!(
        events
            .iter()
            .all(|event| event.event_kind != RuntimeSemanticObservationEventKind::RuleResult),
        "a post-match failure cannot claim completed execution"
    );
}

#[test]
fn malformed_observations_fail_with_the_stable_typed_error() {
    let base = base_index();
    let valid = expected_events();
    let mut bad_contract = valid.clone();
    bad_contract[0].contract_id = "future-contract".to_string();
    let mut foreign_slot = valid.clone();
    foreign_slot[0].target_rule = Some("Missing".to_string());
    let mut non_entry_result = valid.clone();
    non_entry_result[2].rule_label = "Missing".to_string();
    let mut premature_result = valid.clone();
    premature_result.swap(1, 2);

    for observation in [
        Vec::new(),
        valid[..2].to_vec(),
        bad_contract,
        foreign_slot,
        non_entry_result,
        premature_result,
    ] {
        let error = base
            .with_execution_observation(&observation)
            .expect_err("malformed observation must fail");
        assert_eq!(error.stage, "execution_observation");
        assert_eq!(error.code, "semantic_index_invalid_observation");
    }

    let derived = base
        .with_execution_observation(&valid)
        .expect("valid observation derives once");
    let error = derived
        .with_execution_observation(&valid)
        .expect_err("already-derived snapshot cannot derive again");
    assert_eq!(error.code, "semantic_index_invalid_observation");
}

#[derive(Debug, PartialEq, Eq)]
struct ObserverFailure(&'static str);

#[test]
fn observer_panics_preserve_exact_identity_at_slot_and_result_delivery() {
    for generated in [false, true] {
        for failure_kind in [
            RuntimeSemanticObservationEventKind::RegexSlotSelected,
            RuntimeSemanticObservationEventKind::RuleResult,
        ] {
            let failure = Arc::new(ObserverFailure(match (generated, failure_kind) {
                (false, RuntimeSemanticObservationEventKind::RegexSlotSelected) => "direct-slot",
                (false, RuntimeSemanticObservationEventKind::RuleResult) => "direct-result",
                (true, RuntimeSemanticObservationEventKind::RegexSlotSelected) => "generated-slot",
                (true, RuntimeSemanticObservationEventKind::RuleResult) => "generated-result",
            }));
            let raised = Arc::clone(&failure);
            let sink = RuntimeSemanticObservationSink::new(move |event| {
                if event.event_kind == failure_kind {
                    std::panic::panic_any(Arc::clone(&raised));
                }
            });
            let options = ExecutionOptions::new().with_semantic_observation_sink(sink);
            let engine = Engine::new(compiled());
            let caught = catch_unwind(AssertUnwindSafe(|| {
                if generated {
                    engine.execute_generated_value_with_plan_and_options(
                        GENERATED_RULES,
                        input(),
                        &options,
                    )
                } else {
                    engine.execute_value(input(), &options)
                }
            }))
            .expect_err("observer panic must unwind synchronously");
            let caught = caught
                .downcast::<Arc<ObserverFailure>>()
                .expect("observer panic payload type is preserved");
            assert!(Arc::ptr_eq(&caught, &failure));
        }
    }
}

#[test]
fn trace_diagnostics_unicode_positions_and_quiet_execution_are_independent() {
    let engine = Engine::new(compiled());
    let quiet = engine
        .execute_value(input(), &ExecutionOptions::new())
        .expect("quiet direct execution");
    let quiet_trace = unique_temp_path("quiet-trace", "log");
    let observed_trace = unique_temp_path("observed-trace", "log");
    let traced_quiet = engine
        .execute_value_with_trace(
            input(),
            &ExecutionOptions::new(),
            trace_config(&quiet_trace),
        )
        .expect("quiet traced execution");
    let (traced_observed, events) = observed(|options| {
        engine
            .execute_value_with_trace(input(), options, trace_config(&observed_trace))
            .expect("observed traced execution")
    });
    assert_eq!(quiet, traced_quiet);
    assert_eq!(quiet, traced_observed);
    assert_eq!(events, expected_events());
    assert_eq!(
        normalize_trace(&fs::read_to_string(&quiet_trace).expect("read quiet trace")),
        normalize_trace(&fs::read_to_string(&observed_trace).expect("read observed trace"))
    );
    fs::remove_file(&quiet_trace).expect("remove quiet trace");
    fs::remove_file(&observed_trace).expect("remove observed trace");

    let diagnostic_contract: Value = serde_json::from_str(include_str!(
        "../../../capability_conformance/diagnostic_output_contract.json"
    ))
    .expect("diagnostic contract parses");
    let diagnostic_source = diagnostic_contract["programs"]
        .as_array()
        .expect("diagnostic programs")
        .iter()
        .find(|program| program["id"] == "ordered_unicode")
        .expect("ordered Unicode diagnostic program")["spec_source"]
        .as_str()
        .expect("diagnostic source");
    let diagnostic_engine = Engine::new({
        let parsed =
            parse_spec_with_user_functions(diagnostic_source).expect("parse diagnostic fixture");
        validate(&parsed).expect("validate diagnostic fixture");
        compile(&parsed).expect("compile diagnostic fixture")
    });
    let (quiet_sink, quiet_diagnostics) = diagnostic_sink();
    let quiet_diagnostic_result = diagnostic_engine
        .execute_value_with_diagnostic_output("x", &ExecutionOptions::new(), Some(&quiet_sink))
        .expect("quiet semantic diagnostic execution");
    let (observed_sink, observed_diagnostics) = diagnostic_sink();
    let (options, semantic_events) = observing_options();
    let observed_diagnostic_result = diagnostic_engine
        .execute_value_with_diagnostic_output("x", &options, Some(&observed_sink))
        .expect("observed semantic diagnostic execution");
    assert_eq!(observed_diagnostic_result, quiet_diagnostic_result);
    assert_eq!(*observed_diagnostics.borrow(), *quiet_diagnostics.borrow());
    assert!(!semantic_events.borrow().is_empty());

    let unicode_source = "Top::\n /é/\n E { return(\"ok\") }\n";
    let parsed = parse_spec_with_user_functions(unicode_source).expect("parse Unicode fixture");
    validate(&parsed).expect("validate Unicode fixture");
    let (unicode_result, unicode_events) = observed(|options| {
        Engine::new(compile(&parsed).expect("compile Unicode fixture"))
            .execute_value("é", options)
            .expect("execute Unicode fixture")
    });
    assert_eq!(unicode_result, json!("ok"));
    assert_eq!(unicode_events[0].position, 1);
    assert_eq!(unicode_events[1].position, 1);
    assert_eq!(
        unicode_events[1].input_identity.as_deref(),
        Some("input:sha256:4a99557e4033c3539de2eb65472017cad5f9557f7a0625a09f1c3f6e2ba69c4c")
    );
}

#[test]
fn emitted_generated_module_compiles_and_delivers_options_to_both_routes() {
    let mut generated =
        emit_rust_source_v2(&compiled(), SOURCE_IDENTITY).expect("emit runtime fixture source");
    generated.push_str(
        r#"
#[cfg(test)]
mod semantic_observation_options {
    use super::*;
    use linkedspec_runtime::{
        RuntimeSemanticObservationEventKind, RuntimeSemanticObservationSink,
    };
    use std::cell::RefCell;
    use std::rc::Rc;

    fn observed<F>(execute: F)
    where
        F: FnOnce(&ExecutionOptions) -> serde_json::Value,
    {
        let events = Rc::new(RefCell::new(Vec::new()));
        let captured = Rc::clone(&events);
        let options = ExecutionOptions::new().with_semantic_observation_sink(
            RuntimeSemanticObservationSink::new(move |event| {
                captured.borrow_mut().push(event);
            }),
        );
        assert_eq!(execute(&options), serde_json::json!(["A", "B"]));
        let events = events.borrow();
        assert_eq!(events.len(), 3);
        assert_eq!(events[0].event_kind, RuntimeSemanticObservationEventKind::RegexSlotSelected);
        assert_eq!(events[0].position, 1);
        assert_eq!(events[1].position, 2);
        assert_eq!(events[2].event_kind, RuntimeSemanticObservationEventKind::RuleResult);
        assert_eq!(events[2].position, 2);
    }

    #[test]
    fn direct_and_traced_generated_entrypoints_deliver_typed_events() {
        observed(|options| execute_with_options("ab\n", options).unwrap());
        observed(|options| {
            execute_with_trace_and_options("ab\n", TraceConfig::disabled(), options).unwrap()
        });
    }
}
"#,
    );
    run_generated_crate("linkedspec-semantic-observation-generated", generated);
}

fn diagnostic_sink() -> (
    RuntimeDiagnosticOutputSink,
    Rc<RefCell<Vec<RuntimeDiagnosticOutputEvent>>>,
) {
    let events = Rc::new(RefCell::new(Vec::new()));
    let captured = Rc::clone(&events);
    let sink = RuntimeDiagnosticOutputSink::new(move |event| {
        captured.borrow_mut().push(event);
        Ok::<(), Infallible>(())
    });
    (sink, events)
}

fn trace_config(path: &Path) -> TraceConfig {
    TraceConfig::enabled(TraceLevel::DEBUG)
        .with_trace_file(path)
        .with_reset_file(true)
}

fn normalize_trace(trace: &str) -> String {
    trace
        .lines()
        .map(|line| line.split_once(']').map_or(line, |(_, rest)| rest))
        .collect::<Vec<_>>()
        .join("\n")
}

fn unique_temp_path(label: &str, extension: &str) -> PathBuf {
    let nanos = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("system time after Unix epoch")
        .as_nanos();
    std::env::temp_dir().join(format!(
        "linkedspec-{label}-{}-{nanos}.{extension}",
        std::process::id()
    ))
}

struct ScratchDirectory {
    path: PathBuf,
}

impl ScratchDirectory {
    fn new(label: &str) -> Self {
        let path = unique_temp_path(label, "dir");
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

fn run_generated_crate(package: &str, source: String) {
    let project = ScratchDirectory::new(package);
    fs::create_dir_all(project.path().join("src")).expect("create generated crate source dir");
    let runtime_manifest = Path::new(env!("CARGO_MANIFEST_DIR"));
    fs::write(
        project.path().join("Cargo.toml"),
        format!(
            r#"[package]
name = "{package}"
version = "0.0.0"
edition = "2024"

[dependencies]
linkedspec-runtime = {{ path = "{}" }}
serde_json = "1"
"#,
            runtime_manifest.display()
        ),
    )
    .expect("write generated smoke manifest");
    fs::write(project.path().join("src/lib.rs"), source).expect("write generated smoke source");
    let output = Command::new("cargo")
        .arg("test")
        .arg("--offline")
        .arg("--quiet")
        .env("CARGO_TARGET_DIR", project.path().join("target"))
        .current_dir(project.path())
        .output()
        .expect("run generated smoke test");
    assert!(
        output.status.success(),
        "generated smoke failed\nstatus: {}\nstdout:\n{}\nstderr:\n{}",
        output.status,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
}
