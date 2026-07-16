use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GeneratedDiagnosticOutputExecutionError, GeneratedPlanRow, GeneratedRuleFamily,
    GeneratedRuleSpec, execute_generated_parser_with_diagnostic_output,
    execute_generated_parser_with_diagnostic_output_v1,
    execute_generated_parser_with_trace_and_diagnostic_output,
    execute_generated_parser_with_trace_and_diagnostic_output_v1,
};
use linkedspec_runtime::{
    RuntimeDiagnosticOutputEvent, RuntimeDiagnosticOutputExecutionError,
    RuntimeDiagnosticOutputSink,
};
use serde_json::{Value, json};
use std::cell::RefCell;
use std::convert::Infallible;
use std::error::Error;
use std::fmt;
use std::rc::Rc;
use std::time::{SystemTime, UNIX_EPOCH};

const CONTRACT_JSON: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../capability_conformance/diagnostic_output_contract.json"
));

fn contract() -> Value {
    serde_json::from_str(CONTRACT_JSON).expect("diagnostic-output contract JSON")
}

fn program_source(contract: &Value, id: &str) -> String {
    contract["programs"]
        .as_array()
        .expect("program rows")
        .iter()
        .find(|row| row["id"] == id)
        .unwrap_or_else(|| panic!("missing diagnostic-output program {id}"))["spec_source"]
        .as_str()
        .expect("program spec_source")
        .to_string()
}

fn scenario<'a>(contract: &'a Value, id: &str) -> &'a Value {
    contract["scenarios"]
        .as_array()
        .expect("scenario rows")
        .iter()
        .find(|row| row["id"] == id)
        .unwrap_or_else(|| panic!("missing diagnostic-output scenario {id}"))
}

fn engine(source: &str) -> Engine {
    let spec = parse_spec(source).expect("parse diagnostic-output fixture");
    validate(&spec).expect("validate diagnostic-output fixture");
    Engine::new(compile(&spec).expect("compile diagnostic-output fixture"))
}

fn collecting_sink() -> (
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

fn event_json(events: &[RuntimeDiagnosticOutputEvent]) -> Value {
    serde_json::to_value(events).expect("serialize diagnostic-output events")
}

#[test]
fn consumes_exact_ordered_unicode_and_quiet_scenarios() {
    let contract = contract();
    assert_eq!(
        contract["event_schema"]["native_type"],
        "RuntimeDiagnosticOutputEvent"
    );
    let source = program_source(&contract, "ordered_unicode");
    let engine = engine(&source);
    let collected = scenario(&contract, "ordered_unicode_with_sink");
    let quiet = scenario(&contract, "ordered_unicode_quiet");

    let (sink, events) = collecting_sink();
    let output = engine
        .execute_with_diagnostic_output("x", Some(&sink))
        .expect("collected diagnostic-output execution");
    assert_eq!(output, collected["expected"]["outcome"]["output"]);
    assert_eq!(
        event_json(&events.borrow()),
        collected["expected"]["events"]
    );

    let (value_sink, value_events) = collecting_sink();
    let value = engine
        .execute_value_with_diagnostic_output("x", &ExecutionOptions::new(), Some(&value_sink))
        .expect("direct-value diagnostic-output execution");
    assert_eq!(value, collected["expected"]["outcome"]["value"]);
    assert_eq!(
        event_json(&value_events.borrow()),
        collected["expected"]["events"]
    );

    let quiet_output = engine
        .execute_with_diagnostic_output("x", None)
        .expect("quiet diagnostic-output execution");
    assert_eq!(quiet_output, quiet["expected"]["outcome"]["output"]);

    let legacy_output = engine.execute("x").expect("legacy quiet execution");
    assert_eq!(legacy_output, quiet["expected"]["outcome"]["output"]);
    let legacy_value = engine
        .execute_value("x", &ExecutionOptions::new())
        .expect("legacy direct-value quiet execution");
    assert_eq!(legacy_value, quiet["expected"]["outcome"]["value"]);
}

#[test]
fn consumes_every_scalar_render_case() {
    let contract = contract();
    let rows = contract["scalar_render_cases"]
        .as_array()
        .expect("scalar render rows");

    for row in rows {
        let expression = match row["value"]["kind"].as_str().expect("render kind") {
            "string" => serde_json::to_string(&row["value"]["value"]).unwrap(),
            "boolean" | "number" => row["value"]["value"].to_string(),
            "null" => "undef".to_string(),
            "array" => "[1]".to_string(),
            "harray" => "{ \"k\" : 1 }".to_string(),
            "codeblock" => "{ return(undef) }".to_string(),
            other => panic!("unsupported scalar render fixture kind {other}"),
        };
        let source = format!("Top::\n /x/\n E {{ print({expression}); return(\"ok\") }}\n");
        let (sink, events) = collecting_sink();
        let output = engine(&source)
            .execute_with_diagnostic_output("x", Some(&sink))
            .unwrap_or_else(|error| panic!("render case {} failed: {error}", row["id"]));
        assert_eq!(output, json!(["ok"]), "render case {} output", row["id"]);
        assert_eq!(events.borrow().len(), 1, "render case {} count", row["id"]);
        assert_eq!(
            events.borrow()[0].message,
            row["expected"].as_str().expect("expected render text"),
            "render case {}",
            row["id"]
        );
    }
}

#[test]
fn rejects_every_invalid_arity_before_argument_evaluation() {
    let contract = contract();
    let rows = contract["invalid_arity_cases"]
        .as_array()
        .expect("invalid arity rows");

    for row in rows {
        let helper = row["helper_name"].as_str().expect("helper name");
        let actual = row["actual_arity"].as_u64().expect("actual arity") as usize;
        let args = (0..actual)
            .map(|index| {
                if index == 0 {
                    "exit_now(77)".to_string()
                } else {
                    format!("\"arg-{index}\"")
                }
            })
            .collect::<Vec<_>>()
            .join(", ");
        let source = format!("Top::\n /x/\n E {{ {helper}({args}); return(\"late\") }}\n");
        let error = engine(&source)
            .execute_with_diagnostic_output("x", None)
            .expect_err("invalid diagnostic-output arity must fail");
        match error {
            RuntimeDiagnosticOutputExecutionError::Runtime(error) => {
                assert_eq!(error.diagnostic.stage, row["expected_code"]);
                assert!(
                    error.message.contains(
                        row["expected_arity"]
                            .as_str()
                            .expect("expected arity wording")
                    ),
                    "case {} error was {}",
                    row["id"],
                    error.message
                );
            }
            other => panic!(
                "case {} evaluated an argument or returned the wrong outcome: {other}",
                row["id"]
            ),
        }
    }
}

#[test]
fn consumes_wrong_kind_and_immediate_exit_scenarios() {
    let contract = contract();

    let wrong_kind = scenario(&contract, "wrong_kind_no_events");
    let (wrong_sink, wrong_events) = collecting_sink();
    let wrong_output = engine(&program_source(&contract, "wrong_kind"))
        .execute_with_diagnostic_output("x", Some(&wrong_sink))
        .expect("wrong-kind print_each execution");
    assert_eq!(wrong_output, wrong_kind["expected"]["outcome"]["output"]);
    assert_eq!(
        event_json(&wrong_events.borrow()),
        wrong_kind["expected"]["events"]
    );

    let exit = scenario(&contract, "event_before_immediate_exit");
    let (exit_sink, exit_events) = collecting_sink();
    let error = engine(&program_source(&contract, "immediate_exit"))
        .execute_with_diagnostic_output("x", Some(&exit_sink))
        .expect_err("exit_now must be a typed immediate outcome");
    match error {
        RuntimeDiagnosticOutputExecutionError::Exit(exit_now) => {
            assert_eq!(
                i64::from(exit_now.status),
                exit["expected"]["outcome"]["status"]
                    .as_i64()
                    .expect("expected exit status")
            );
        }
        other => panic!("exit_now returned the wrong outcome: {other}"),
    }
    assert_eq!(
        event_json(&exit_events.borrow()),
        exit["expected"]["events"]
    );
}

#[derive(Debug)]
struct CallerSinkFailure {
    id: String,
    identity: Rc<()>,
}

impl fmt::Display for CallerSinkFailure {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        formatter.write_str(&self.id)
    }
}

impl Error for CallerSinkFailure {}

#[test]
fn preserves_synchronous_caller_sink_failure_and_stops_delivery() {
    let contract = contract();
    for scenario_id in ["print_each_sink_failure", "synchronous_sink_failure"] {
        let row = scenario(&contract, scenario_id);
        let source = program_source(
            &contract,
            row["program_id"].as_str().expect("scenario program id"),
        );
        let fail_on = row["sink"]["invocation"]
            .as_u64()
            .expect("failure invocation") as usize;
        let error_id = row["sink"]["error_id"]
            .as_str()
            .expect("caller error id")
            .to_string();
        let identity = Rc::new(());
        let sink_identity = Rc::clone(&identity);
        let events = Rc::new(RefCell::new(Vec::new()));
        let captured = Rc::clone(&events);
        let sink_error_id = error_id.clone();
        let mut invocation = 0;
        let sink = RuntimeDiagnosticOutputSink::new(move |event| {
            invocation += 1;
            captured.borrow_mut().push(event);
            if invocation == fail_on {
                Err(CallerSinkFailure {
                    id: sink_error_id.clone(),
                    identity: Rc::clone(&sink_identity),
                })
            } else {
                Ok(())
            }
        });

        let error = engine(&source)
            .execute_with_diagnostic_output("x", Some(&sink))
            .expect_err("injected caller sink failure must abort execution");
        match error {
            RuntimeDiagnosticOutputExecutionError::Sink(error) => {
                let caller = error
                    .downcast_ref::<CallerSinkFailure>()
                    .expect("unchanged caller sink failure type");
                assert_eq!(caller.id, error_id);
                assert!(Rc::ptr_eq(&caller.identity, &identity));
            }
            other => panic!("scenario {scenario_id} returned the wrong outcome: {other}"),
        }
        assert_eq!(
            event_json(&events.borrow()),
            row["expected"]["events"],
            "scenario {scenario_id} event prefix"
        );
    }
}

#[test]
fn keeps_diagnostic_events_out_of_native_trace() {
    let marker = "diagnostic-only-pré🙂";
    let source = format!("Top::\n /x/\n E {{ say(\"{marker}\"); return(\"ok\") }}\n");
    let nonce = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("system clock after epoch")
        .as_nanos();
    let trace_path = std::env::temp_dir().join(format!(
        "linkedspec-rust-diagnostic-output-{}-{nonce}.log",
        std::process::id()
    ));
    let config = TraceConfig::enabled(TraceLevel::DEBUG)
        .with_trace_file(trace_path.clone())
        .with_reset_file(true);

    let output = engine(&source)
        .execute_with_trace("x", config)
        .expect("traced quiet diagnostic-helper execution");
    assert_eq!(output, json!(["ok"]));
    let trace = std::fs::read_to_string(&trace_path).expect("read native trace");
    assert!(trace.contains("rust_runtime:engine:execute"));
    assert!(
        !trace.contains(marker),
        "diagnostic event data entered native trace: {trace}"
    );
    std::fs::remove_file(trace_path).expect("remove focused trace artifact");
}

#[test]
fn generated_direct_and_traced_roles_preserve_diagnostic_outcomes() {
    let contract = contract();
    let ordered = scenario(&contract, "ordered_unicode_with_sink");
    let source = program_source(&contract, "ordered_unicode");
    let parsed = parse_spec(&source).expect("parse generated diagnostic fixture");
    validate(&parsed).expect("validate generated diagnostic fixture");
    let compiled = compile(&parsed).expect("compile generated diagnostic fixture");
    let compiled_json = serde_json::to_string(&compiled).expect("serialize generated fixture");
    let plan = [GeneratedPlanRow {
        label: "Top",
        family: "default",
    }];
    let compatibility_plan = [GeneratedRuleSpec {
        label: "Top",
        family: GeneratedRuleFamily::Default,
    }];
    let identity = "diagnostic-output/generated-rust.spec";

    let (sink, events) = collecting_sink();
    let value = execute_generated_parser_with_diagnostic_output_v1(
        &compiled_json,
        &plan,
        "x",
        identity,
        Some(&sink),
    )
    .expect("generated direct diagnostic execution");
    assert_eq!(value, ordered["expected"]["outcome"]["value"]);
    assert_eq!(event_json(&events.borrow()), ordered["expected"]["events"]);

    let (trace_sink, trace_events) = collecting_sink();
    let traced = execute_generated_parser_with_trace_and_diagnostic_output_v1(
        &compiled_json,
        &plan,
        "x",
        TraceConfig::default(),
        identity,
        Some(&trace_sink),
    )
    .expect("generated traced diagnostic execution");
    assert_eq!(traced, value);
    assert_eq!(
        event_json(&trace_events.borrow()),
        ordered["expected"]["events"]
    );

    let (compatibility_sink, compatibility_events) = collecting_sink();
    let compatibility = execute_generated_parser_with_diagnostic_output(
        &compiled_json,
        &compatibility_plan,
        "x",
        Some(&compatibility_sink),
    )
    .expect("compatibility generated diagnostic execution");
    assert_eq!(compatibility, ordered["expected"]["outcome"]["output"]);
    assert_eq!(
        event_json(&compatibility_events.borrow()),
        ordered["expected"]["events"]
    );

    let (compatibility_trace_sink, compatibility_trace_events) = collecting_sink();
    let compatibility_traced = execute_generated_parser_with_trace_and_diagnostic_output(
        &compiled_json,
        &compatibility_plan,
        "x",
        TraceConfig::default(),
        Some(&compatibility_trace_sink),
    )
    .expect("compatibility traced diagnostic execution");
    assert_eq!(compatibility_traced, compatibility);
    assert_eq!(
        event_json(&compatibility_trace_events.borrow()),
        ordered["expected"]["events"]
    );

    let failure_row = scenario(&contract, "synchronous_sink_failure");
    let failure_source = program_source(&contract, "sink_failure");
    let failure_spec = parse_spec(&failure_source).expect("parse generated sink-failure fixture");
    validate(&failure_spec).expect("validate generated sink-failure fixture");
    let failure_json = serde_json::to_string(
        &compile(&failure_spec).expect("compile generated sink-failure fixture"),
    )
    .expect("serialize generated sink-failure fixture");
    let identity_token = Rc::new(());
    let callback_token = Rc::clone(&identity_token);
    let mut invocation = 0;
    let failing_sink = RuntimeDiagnosticOutputSink::new(move |_event| {
        invocation += 1;
        if invocation == 2 {
            Err(CallerSinkFailure {
                id: "generated-caller-sink-failure".to_string(),
                identity: Rc::clone(&callback_token),
            })
        } else {
            Ok(())
        }
    });
    let error = execute_generated_parser_with_diagnostic_output_v1(
        &failure_json,
        &plan,
        "x",
        identity,
        Some(&failing_sink),
    )
    .expect_err("generated sink failure must abort");
    match error {
        GeneratedDiagnosticOutputExecutionError::Sink(error) => {
            let caller = error
                .downcast_ref::<CallerSinkFailure>()
                .expect("generated path preserves caller failure type");
            assert_eq!(caller.id, "generated-caller-sink-failure");
            assert!(Rc::ptr_eq(&caller.identity, &identity_token));
        }
        other => panic!("generated sink failure returned wrong outcome: {other}"),
    }
    assert_eq!(failure_row["expected"]["outcome"]["kind"], "sink_failure");

    let exit_source = program_source(&contract, "immediate_exit");
    let exit_spec = parse_spec(&exit_source).expect("parse generated exit fixture");
    validate(&exit_spec).expect("validate generated exit fixture");
    let exit_json =
        serde_json::to_string(&compile(&exit_spec).expect("compile generated exit fixture"))
            .expect("serialize generated exit fixture");
    let (exit_sink, exit_events) = collecting_sink();
    let error = execute_generated_parser_with_diagnostic_output_v1(
        &exit_json,
        &plan,
        "x",
        identity,
        Some(&exit_sink),
    )
    .expect_err("generated exit must remain typed");
    match error {
        GeneratedDiagnosticOutputExecutionError::Exit(exit) => assert_eq!(exit.status, 23),
        other => panic!("generated exit returned wrong outcome: {other}"),
    }
    assert_eq!(
        event_json(&exit_events.borrow()),
        scenario(&contract, "event_before_immediate_exit")["expected"]["events"]
    );
}
