use linkedspec_core::compiler::{compile, compile_with_trace};
use linkedspec_core::parser::{parse_spec, parse_spec_with_trace};
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_core::validation::{validate, validate_with_trace};
use linkedspec_runtime::engine::Engine;
use linkedspec_runtime::source_emitter::{
    GeneratedRuleSpec, classify_generated_rule_family, emit_rust_source, execute_generated_parser,
    execute_generated_parser_with_trace,
};

const SIMPLE_SPEC: &str = r#"
Top::
 /x/ { return("hit") }
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
    let generated_rules = [GeneratedRuleSpec {
        label: "Top",
        family: classify_generated_rule_family(compiled.top_rule().expect("top rule")),
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
    let path = std::env::temp_dir().join(format!(
        "linkedspec-runtime-trace-controls-{}.log",
        std::process::id()
    ));
    let _ = std::fs::remove_file(&path);

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
    assert_eq!(
        std::fs::read_to_string(&path).expect("read routed trace file"),
        "",
        ".4.2 wires controls and sinks; runtime events are owned by .4.4"
    );
    let _ = std::fs::remove_file(path);
}

fn compile_valid_spec() -> linkedspec_core::types::CompiledSpec {
    let spec = parse_spec(SIMPLE_SPEC).expect("parse simple spec");
    validate(&spec).expect("validate simple spec");
    compile(&spec).expect("compile simple spec")
}
