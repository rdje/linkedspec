use linkedspec_core::compiler::{compile, compile_with_trace};
use linkedspec_core::parser::{parse_spec, parse_spec_with_trace};
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_core::validation::{validate, validate_with_trace};
use linkedspec_runtime::engine::Engine;
use linkedspec_runtime::source_emitter::{
    GeneratedPlanRow, classify_generated_rule_family, emit_rust_source, execute_generated_parser,
    execute_generated_parser_with_trace,
};
use linkedspec_runtime::spec_parser::{
    parse_spec_with_user_functions, parse_spec_with_user_functions_with_trace,
};
use linkedspec_runtime::staged_parser_registry::{
    execute_parse_jobs, execute_parse_jobs_with_trace,
};
use serde_json::{Value, json};
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

const SIMPLE_SPEC: &str = r#"
Top::
 /x/ { return("hit") }
"#;

const USER_FUNCTION_SPEC: &str = r#"fn label() {return("hit")}

Top::
 /x/ { return(label()) }
"#;

const RUNTIME_TRACE_SPEC: &str = r#"
Top::
 I { mark_input_start("input") }
 LS { start_capture_slice() }
 /x/ -> Child
 LE { push(results, retv) }
 E { return(array(capture_rest_from("input"), copy(results))) }

Child::
 /y/
 E { return(match_text()) }
"#;

#[test]
fn core_traced_entrypoints_match_untraced_outputs_when_quiet() {
    let untraced_spec = parse_spec(SIMPLE_SPEC).expect("parse untraced spec");
    let traced_spec =
        parse_spec_with_trace(SIMPLE_SPEC, TraceConfig::default()).expect("parse traced spec");
    assert_eq!(
        serde_json::to_value(&traced_spec).expect("serialize traced spec"),
        serde_json::to_value(&untraced_spec).expect("serialize untraced spec")
    );

    validate(&untraced_spec).expect("validate untraced spec");
    validate_with_trace(&traced_spec, TraceConfig::default()).expect("validate traced spec");

    let untraced_compiled = compile(&untraced_spec).expect("compile untraced spec");
    let traced_compiled =
        compile_with_trace(&traced_spec, TraceConfig::default()).expect("compile traced spec");
    assert_eq!(
        serde_json::to_value(&traced_compiled).expect("serialize traced compiled spec"),
        serde_json::to_value(&untraced_compiled).expect("serialize untraced compiled spec")
    );
}

#[test]
fn traced_compile_enforces_progressive_static_contract() {
    let source = r#"
Top::
 I { span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored"); return(cat(dispatch_span("expr-v1", "Expr", span))) }
 /never/
"#;
    let spec = parse_spec(source).expect("parse residual progressive call");
    let ordinary = compile(&spec)
        .expect_err("ordinary compile must reject residual dispatch_span")
        .to_string();
    let traced = compile_with_trace(&spec, TraceConfig::default())
        .expect_err("traced compile must reject residual dispatch_span")
        .to_string();

    assert_eq!(traced, ordinary);
    assert!(
        traced.contains(
            "LINKEDSPEC_PROGRESSIVE_SPAN_DISPATCH_ERROR:progressive_span_binding_required"
        )
    );
}

#[test]
fn engine_traced_entrypoint_matches_untraced_output_when_quiet() {
    let compiled = compile_valid_spec();
    let engine = Engine::new(compiled);

    let untraced = engine.execute("x").expect("execute untraced");
    let traced = engine
        .execute_with_trace("x", TraceConfig::default())
        .expect("execute traced");

    assert_eq!(traced, untraced);
}

#[test]
fn generated_parser_traced_entrypoint_matches_untraced_output_when_quiet() {
    let compiled = compile_valid_spec();
    let compiled_spec_json =
        serde_json::to_string(&compiled).expect("serialize compiled spec for generated parser");
    let generated_rules = [GeneratedPlanRow {
        label: "Top",
        family: classify_generated_rule_family(compiled.top_rule().expect("top rule"))
            .contract_name(),
    }];

    let untraced =
        execute_generated_parser(&compiled_spec_json, &generated_rules, "x").expect("untraced");
    let traced = execute_generated_parser_with_trace(
        &compiled_spec_json,
        &generated_rules,
        "x",
        TraceConfig::default(),
    )
    .expect("traced");

    assert_eq!(traced, untraced);
}

#[test]
fn emitted_rust_source_exposes_trace_control_entrypoint() {
    let generated = emit_rust_source(&compile_valid_spec()).expect("emit generated source");

    assert!(generated.contains("pub fn parse(input: &str)"));
    assert!(generated.contains("pub fn parse_with_trace"));
    assert!(generated.contains("TraceConfig"));
    assert!(generated.contains("execute_generated_parser_with_trace"));
}

#[test]
fn traced_entrypoint_validates_route_sink_setup_without_changing_output() {
    let path = temp_trace_path("route-sink-setup");

    let compiled = compile_valid_spec();
    let engine = Engine::new(compiled);
    let untraced = engine.execute("x").expect("execute untraced");
    let config = TraceConfig::enabled(TraceLevel::DEBUG)
        .with_trace_file(path.clone())
        .with_reset_file(true);
    let output = engine
        .execute_with_trace("x", config)
        .expect("execute with routed trace config");

    assert_eq!(output, untraced);
    assert!(
        path.exists(),
        "routed trace setup should create the log file"
    );
    let trace = std::fs::read_to_string(&path).expect("read routed trace file");
    assert!(trace.contains("rust_runtime:engine:execute"), "{trace}");
    assert!(trace.contains("rust_runtime:engine:top_rule"), "{trace}");
    assert!(
        trace.contains("rust_runtime:engine:lifecycle_block"),
        "{trace}"
    );
    assert!(
        !trace.contains("rust_runtime:engine:regex_match"),
        "direct rule entry must not test that rule's own regex:\n{trace}"
    );
    let _ = std::fs::remove_file(path);
}

#[test]
fn engine_runtime_trace_emits_branch_lifecycle_and_mark_capture_events() {
    let path = temp_trace_path("engine-runtime-events");
    let compiled = compile_spec(RUNTIME_TRACE_SPEC);
    let engine = Engine::new(compiled);

    let untraced = engine.execute("xy").expect("execute untraced");
    let traced = engine
        .execute_with_trace("xy", trace_config(&path, true))
        .expect("execute traced");

    assert_eq!(traced, untraced);

    let trace = std::fs::read_to_string(&path).expect("read trace file");
    for marker in [
        "rust_runtime:engine:execute",
        "rust_runtime:engine:rule",
        "rust_runtime:engine:regex_match",
        "rust_runtime:engine:acode_dispatch",
        "rust_runtime:engine:child_dispatch",
        "rust_runtime:engine:lifecycle_block",
        "rust_runtime:engine:mark_capture",
    ] {
        assert!(
            trace.contains(marker),
            "missing {marker} in trace:\n{trace}"
        );
    }
    let _ = std::fs::remove_file(path);
}

#[test]
fn generated_runtime_trace_emits_plan_and_branch_events() {
    let path = temp_trace_path("generated-runtime-events");
    let compiled = compile_spec(RUNTIME_TRACE_SPEC);
    let compiled_spec_json =
        serde_json::to_string(&compiled).expect("serialize compiled spec for generated parser");
    let generated_rules = [
        GeneratedPlanRow {
            label: "Top",
            family: classify_generated_rule_family(
                compiled
                    .rules
                    .iter()
                    .find(|rule| rule.label == "Top")
                    .expect("Top rule"),
            )
            .contract_name(),
        },
        GeneratedPlanRow {
            label: "Child",
            family: classify_generated_rule_family(
                compiled
                    .rules
                    .iter()
                    .find(|rule| rule.label == "Child")
                    .expect("Child rule"),
            )
            .contract_name(),
        },
    ];

    let untraced =
        execute_generated_parser(&compiled_spec_json, &generated_rules, "xy").expect("untraced");
    let traced = execute_generated_parser_with_trace(
        &compiled_spec_json,
        &generated_rules,
        "xy",
        trace_config(&path, true),
    )
    .expect("traced");

    assert_eq!(traced, untraced);

    let trace = std::fs::read_to_string(&path).expect("read trace file");
    for marker in [
        "rust_runtime:generated_plan:execute",
        "rust_runtime:generated_plan:top_rule",
        "rust_runtime:generated_plan:family_dispatch",
        "rust_runtime:generated_plan:regex_match",
        "rust_runtime:generated_plan:acode_dispatch",
        "rust_runtime:generated_plan:child_dispatch",
        "rust_runtime:engine:lifecycle_block",
        "rust_runtime:engine:mark_capture",
    ] {
        assert!(
            trace.contains(marker),
            "missing {marker} in trace:\n{trace}"
        );
    }
    let _ = std::fs::remove_file(path);
}

#[test]
fn core_traced_entrypoints_emit_parse_validate_and_compile_events() {
    let path = temp_trace_path("core-events");

    let spec = parse_spec_with_trace(SIMPLE_SPEC, trace_config(&path, true)).expect("parse traced");
    validate_with_trace(&spec, trace_config(&path, false)).expect("validate traced");
    let traced = compile_with_trace(&spec, trace_config(&path, false)).expect("compile traced");
    let untraced = compile_valid_spec();

    assert_eq!(
        serde_json::to_value(&traced).expect("serialize traced compiled spec"),
        serde_json::to_value(&untraced).expect("serialize untraced compiled spec")
    );

    let trace = std::fs::read_to_string(&path).expect("read trace file");
    assert!(trace.contains("rust_core:parse_spec"), "{trace}");
    assert!(trace.contains("rust_core:validate:rules_exist"), "{trace}");
    assert!(trace.contains("rust_core:compile:rule"), "{trace}");
    assert!(
        trace.contains("rust_core:compile:dependency_regex_map"),
        "{trace}"
    );
    let _ = std::fs::remove_file(path);
}

#[test]
fn full_spec_parser_trace_includes_user_function_and_staged_dispatch_events() {
    let path = temp_trace_path("spec-parser-events");

    let untraced =
        parse_spec_with_user_functions(USER_FUNCTION_SPEC).expect("parse untraced full spec");
    let traced =
        parse_spec_with_user_functions_with_trace(USER_FUNCTION_SPEC, trace_config(&path, true))
            .expect("parse traced full spec");

    assert_eq!(
        serde_json::to_value(&traced).expect("serialize traced full spec"),
        serde_json::to_value(&untraced).expect("serialize untraced full spec")
    );

    let trace = std::fs::read_to_string(&path).expect("read trace file");
    assert!(
        trace.contains("rust_runtime:parse_spec_with_user_functions"),
        "{trace}"
    );
    assert!(
        trace.contains("rust_runtime:parse_user_function_definition_asts"),
        "{trace}"
    );
    assert!(
        trace.contains("rust_runtime:staged_parser_registry:resolve"),
        "{trace}"
    );
    assert!(
        trace.contains("rust_runtime:staged_parser_registry:execute"),
        "{trace}"
    );
    let _ = std::fs::remove_file(path);
}

#[test]
fn staged_dispatch_trace_preserves_queue_results_and_phase_events() {
    let path = temp_trace_path("staged-dispatch-events");
    let job_later = staged_body_job(
        1,
        40,
        51,
        3,
        "return(\"b\")",
        "parse_job:function_body:functions.1.body_source:actionir-body.spec:action_block:40-51",
    );
    let job_earlier = staged_body_job(
        0,
        10,
        21,
        1,
        "return(\"a\")",
        "parse_job:function_body:functions.0.body_source:actionir-body.spec:action_block:10-21",
    );

    let untraced =
        execute_parse_jobs(&[job_later.clone(), job_earlier.clone()]).expect("untraced staged");
    let traced =
        execute_parse_jobs_with_trace(&[job_later, job_earlier], trace_config(&path, true))
            .expect("traced staged");

    assert_eq!(traced, untraced);
    assert_eq!(
        traced[0]["job_id"],
        json!(
            "parse_job:function_body:functions.0.body_source:actionir-body.spec:action_block:10-21"
        )
    );

    let trace = std::fs::read_to_string(&path).expect("read trace file");
    for marker in [
        "rust_runtime:staged_parser_registry:normalize_job",
        "rust_runtime:staged_parser_registry:queue_sorted",
        "rust_runtime:staged_parser_registry:resolve",
        "rust_runtime:staged_parser_registry:load",
        "rust_runtime:staged_parser_registry:compile",
        "rust_runtime:staged_parser_registry:execute",
    ] {
        assert!(
            trace.contains(marker),
            "missing {marker} in trace:\n{trace}"
        );
    }
    let _ = std::fs::remove_file(path);
}

fn compile_valid_spec() -> linkedspec_core::types::CompiledSpec {
    compile_spec(SIMPLE_SPEC)
}

fn compile_spec(source: &str) -> linkedspec_core::types::CompiledSpec {
    let spec = parse_spec(source).expect("parse spec");
    validate(&spec).expect("validate spec");
    compile(&spec).expect("compile spec")
}

fn trace_config(path: &Path, reset_file: bool) -> TraceConfig {
    TraceConfig::enabled(TraceLevel::DEBUG)
        .with_trace_file(path.to_path_buf())
        .with_reset_file(reset_file)
}

fn staged_body_job(
    function_index: usize,
    start: usize,
    end: usize,
    line: usize,
    text: &str,
    job_id: &str,
) -> Value {
    json!({
        "kind": "parse_job",
        "job_id": job_id,
        "parent_ast_path": ["functions", function_index.to_string(), "body_source"],
        "node_kind": "function_definition",
        "payload_kind": "function_body",
        "text": text,
        "source_span": {"start": start, "end": end, "line_start": line, "line_end": line},
        "parser_spec_id": "actionir-body.spec",
        "top_rule": "action_block",
        "result_policy": "replace_field",
        "result_field": "body_ast",
        "failure_policy": "fail",
        "diagnostic_owner": "function_body",
    })
}

fn temp_trace_path(name: &str) -> PathBuf {
    let nanos = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("system time before UNIX_EPOCH")
        .as_nanos();
    std::env::temp_dir().join(format!(
        "linkedspec-runtime-{name}-{}-{nanos}.log",
        std::process::id()
    ))
}
