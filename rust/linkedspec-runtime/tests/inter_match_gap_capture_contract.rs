//! INTER-MATCH-GAP-CAPTURE.3.1-.3.3 — dormant Rust carrier stage.
//!
//! This final consumer path now proves authored/static metadata, native
//! execution, ordinary reconstruction, descriptor projection, and the separate
//! generated-plan executor. Emitted source, primary routing, and admission
//! remain owned by `.3.4-.3.5`.

use linkedspec_core::compiler::compile;
use linkedspec_core::error::{LinkedSpecError, PortableDiagnostic};
use linkedspec_core::parser::parse_spec;
use linkedspec_core::types::{CompiledSpec, RegexSelectorKind};
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GeneratedRuleSpec, classify_generated_rule_family, emit_rust_source_v2,
};
use linkedspec_runtime::{RuntimeDiagnosticOutputExecutionError, RuntimeExecutionError};
use serde_json::{Value, json};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

const CONTRACT_SOURCE: &str =
    include_str!("../../../capability_conformance/inter_match_gap_capture_contract.json");
const CONTRACT_ID: &str = "linkedspec-inter-match-gap-capture-v1";

fn contract() -> Value {
    serde_json::from_str(CONTRACT_SOURCE).expect("inter-match gap contract JSON")
}

fn compile_metadata(source: &str) -> Result<CompiledSpec, LinkedSpecError> {
    let parsed = parse_spec(source)?;
    validate(&parsed)?;
    compile(&parsed)
}

fn diagnostic(source: &str) -> PortableDiagnostic {
    let error = compile_metadata(source).expect_err("fixture must be rejected statically");
    error
        .diagnostic()
        .unwrap_or_else(|| panic!("expected portable diagnostic, got {error}"))
        .clone()
}

fn native_and_generated_value(source: &str, input: &str) -> Value {
    let native = Engine::new(compile_metadata(source).expect("compile native gap fixture"))
        .execute_value(input, &ExecutionOptions::new())
        .unwrap_or_else(|error| panic!("execute native gap fixture: {error}"));
    let generated = generated_value(source, input)
        .unwrap_or_else(|error| panic!("execute generated-plan gap fixture: {error}"));
    assert_eq!(generated, native, "native/generated-plan value parity");
    native
}

fn generated_plan(compiled: &CompiledSpec) -> Vec<GeneratedRuleSpec> {
    compiled
        .rules
        .iter()
        .map(|rule| GeneratedRuleSpec {
            label: match rule.label.as_str() {
                "Top" => "Top",
                "Part" => "Part",
                "Container" => "Container",
                "Close" => "Close",
                "Bang" => "Bang",
                "Atom" => "Atom",
                "Probe" => "Probe",
                "Direct" => "Direct",
                label => panic!("fixture rule needs a stable generated label: {label}"),
            },
            family: classify_generated_rule_family(rule),
        })
        .collect()
}

fn generated_value(source: &str, input: &str) -> Result<Value, String> {
    let compiled = compile_metadata(source).expect("compile generated-plan gap fixture");
    let plan = generated_plan(&compiled);
    Engine::new(compiled).execute_generated_value_with_plan(&plan, input)
}

fn generated_runtime_error(source: &str, input: &str) -> RuntimeExecutionError {
    let compiled = compile_metadata(source).expect("compile generated-plan diagnostic fixture");
    let plan = generated_plan(&compiled);
    match Engine::new(compiled)
        .execute_generated_value_with_plan_with_diagnostic_output(&plan, input, None)
        .expect_err("generated-plan diagnostic fixture must fail")
    {
        RuntimeDiagnosticOutputExecutionError::Runtime(error) => error,
        error => panic!("expected generated runtime diagnostic, got {error}"),
    }
}

fn rule<'a>(compiled: &'a Value, label: &str) -> &'a Value {
    compiled["rules"]
        .as_array()
        .expect("compiled rules")
        .iter()
        .find(|rule| rule["label"] == label)
        .unwrap_or_else(|| panic!("missing compiled rule {label}"))
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
                "inter-match-gap-emitted-probe-{}-{nonce}",
                std::process::id()
            ));
        fs::create_dir_all(root.join("src")).expect("create emitted gap workspace");
        Self { root }
    }
}

impl Drop for EmittedProject {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

struct EmittedValueCase {
    module: &'static str,
    source: &'static str,
    input: &'static str,
    expected: Value,
}

struct EmittedErrorCase {
    module: &'static str,
    source: &'static str,
    input: &'static str,
    detail: &'static str,
}

fn independently_compiled_emitted_gap_contract() {
    let value_cases = [
        EmittedValueCase {
            module: "mixed_list_separators",
            source: r#"Top::
 I { segments = [] }
 @capture_gaps
 -> Item[word] { push(segments, array(gap_text(), call(Item))) }
 LX { push(segments, array(gap_text(), gap_kind())); return(copy(segments)) }
Item:
 word=/[a-z]+/
 I.return(entry_text())
"#,
            input: "alpha, beta | gamma\n- delta",
            expected: json!([
                ["", "alpha"],
                [", ", "beta"],
                [" | ", "gamma"],
                ["\n- ", "delta"],
                ["", "tail"]
            ]),
        },
        EmittedValueCase {
            module: "unicode_slots_and_falsey",
            source: r#"Top::
 I { segments = [] }
 @capture_gaps
 -> Part[header]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[section] { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[footer]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 LX { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span())); return(copy(segments)) }
Part:
 header=/H/
 section=/S/
 footer=/F/
 I { return(hash("slot", entry_slot(), "text", entry_text(), "falsey", 0)) }
"#,
            input: "αHβ\nS🙂Fω",
            expected: json!([
                {
                    "kind":"prefix", "text":"α",
                    "span":{"source_id":"input", "start":0, "end":1, "provenance":"gap"},
                    "child":{"slot":{"target_rule":"Part", "regex_index":0, "slot_id":"header", "selector_kind":"named", "authored_selector":"header"}, "text":"H", "falsey":0}
                },
                {
                    "kind":"interstitial", "text":"β\n",
                    "span":{"source_id":"input", "start":2, "end":4, "provenance":"gap"},
                    "child":{"slot":{"target_rule":"Part", "regex_index":1, "slot_id":"section", "selector_kind":"named", "authored_selector":"section"}, "text":"S", "falsey":0}
                },
                {
                    "kind":"interstitial", "text":"🙂",
                    "span":{"source_id":"input", "start":5, "end":6, "provenance":"gap"},
                    "child":{"slot":{"target_rule":"Part", "regex_index":2, "slot_id":"footer", "selector_kind":"named", "authored_selector":"footer"}, "text":"F", "falsey":0}
                },
                {"kind":"tail", "text":"ω", "span":{"source_id":"input", "start":7, "end":8, "provenance":"gap"}}
            ]),
        },
        EmittedValueCase {
            module: "empty_gaps",
            source: r#"Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[s] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[f] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 LX { push(gaps, array(gap_kind(), gap_text(), gap_span())); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 f=/F/
 I.return(entry_text())
"#,
            input: "HSF",
            expected: json!([
                ["prefix", "", {"source_id":"input", "start":0, "end":0, "provenance":"gap"}],
                ["interstitial", "", {"source_id":"input", "start":1, "end":1, "provenance":"gap"}],
                ["interstitial", "", {"source_id":"input", "start":2, "end":2, "provenance":"gap"}],
                ["tail", "", {"source_id":"input", "start":3, "end":3, "provenance":"gap"}]
            ]),
        },
        EmittedValueCase {
            module: "selection_before_ls",
            source: r#"Top::
 @capture_gaps
 -> Part { return("unexpected") }
 LS { return(array(gap_kind(), gap_text(), match_text())) }
Part: /H/
"#,
            input: "αH",
            expected: json!(["prefix", "α", "H"]),
        },
        EmittedValueCase {
            module: "child_extended_cursor",
            source: r#"Top::
 I { gaps = [] }
 @capture_gaps
 -> Container[open] { push(gaps, array(gap_text(), call(Container))) }
 -> Bang { push(gaps, array(gap_text(), call(Bang))) }
 LX { push(gaps, array(gap_text(), gap_kind())); return(copy(gaps)) }
Container:
 open=/\{/
 -> Close { return(call(Close)) }
Close:
 /\}/
 I.return(entry_text())
Bang:
 /!/
 I.return(entry_text())
"#,
            input: "p{abc}gap!",
            expected: json!([["p", "}"], ["gap", "!"], ["", "tail"]]),
        },
        EmittedValueCase {
            module: "nested_gap_owner",
            source: r#"Top::
 @capture_gaps
 -> Container[open] { return(array(gap_text(), call(Container), gap_text())) }
Container:
 open=/\{/
 I { inner = [] }
 @capture_gaps
 -> Atom { push(inner, gap_text()) }
 LX { push(inner, gap_text()); return(copy(inner)) }
Atom:
 /x/
 I.return(entry_text())
"#,
            input: "p{axtail",
            expected: json!(["p", ["a", "tail"], "p"]),
        },
        EmittedValueCase {
            module: "rollback_snapshot",
            source: r#"Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] {
  tx = recognition_checkpoint();
  matched = recognize_once(tx, call(Probe));
  recognition_rollback(tx);
  push(gaps, gap_text())
 }
 -> Part[s] { push(gaps, gap_text()) }
 LX { push(gaps, gap_text()); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 I.return(entry_text())
Probe:
 /X/
 I.return(0)
"#,
            input: "aHXbS",
            expected: json!(["a", "Xb", ""]),
        },
        EmittedValueCase {
            module: "lx_no_match_tail",
            source: r#"Top::
 @capture_gaps
 -> Part { return(gap_text()) }
 LX { return(array(gap_kind(), gap_text(), gap_span())) }
Part: /H/
"#,
            input: "abc",
            expected: json!(["tail", "abc", {"source_id":"input", "start":0, "end":3, "provenance":"gap"}]),
        },
        EmittedValueCase {
            module: "ex_zero_match_tail",
            source: r#"Top::OR{0,2}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 EX { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
"#,
            input: "whole",
            expected: json!(["whole"]),
        },
        EmittedValueCase {
            module: "e_success_tail",
            source: r#"Top::OR{1}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 E { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
"#,
            input: "aHtail",
            expected: json!(["a", "tail"]),
        },
        EmittedValueCase {
            module: "failed_minimum",
            source: "Top::OR{2}\n @capture_gaps\n -> Part { return(gap_text()) }\n EX { return(\"unexpected-ex\") }\n E { return(\"unexpected-e\") }\nPart: /H/\n",
            input: "H",
            expected: Value::Null,
        },
        EmittedValueCase {
            module: "direct_entry",
            source: "Part::\n /H/\n I { return(entry_slot()) }\n",
            input: "H",
            expected: Value::Null,
        },
        EmittedValueCase {
            module: "unflagged_legacy",
            source: "Top::\n /H/\n E { return(\"legacy\") }\n",
            input: "H",
            expected: json!("legacy"),
        },
    ];
    let error_cases = [
        EmittedErrorCase {
            module: "unavailable_context",
            source: "Direct::\n /H/\n I { return(gap_text()) }\n",
            input: "H",
            detail: "LINKEDSPEC_INTER_MATCH_GAP_ERROR:gap_capture_context_unavailable",
        },
        EmittedErrorCase {
            module: "cursor_regression",
            source: "Top::OR{1}\n @capture_gaps\n -> Part { rewind_match_start() }\nPart: /H/\n",
            input: "aH",
            detail: "LINKEDSPEC_SOURCE_LOCATION_ERROR:source_location_cursor_regression",
        },
    ];

    let project = EmittedProject::new();
    let mut generated = String::new();
    let mut generated_tests = String::from(
        r#"#[cfg(test)]
mod emitted_gap_contract {
    use linkedspec_runtime::source_emitter::{GeneratedSourceCode, GeneratedSourceStage};
    use linkedspec_runtime::trace::{TraceConfig, TraceLevel};
    use std::fs;
    use std::path::Path;

"#,
    );
    for case in &value_cases {
        let compiled = compile_metadata(case.source)
            .unwrap_or_else(|error| panic!("compile emitted {} fixture: {error}", case.module));
        let identity = format!("inter-match-gap/emitted/{}.spec", case.module);
        let emitted = emit_rust_source_v2(&compiled, &identity)
            .unwrap_or_else(|error| panic!("emit {} fixture: {error}", case.module));
        generated.push_str(&format!("mod {} {{\n{}\n}}\n\n", case.module, emitted));

        let expected_json = serde_json::to_string(&case.expected).expect("encode emitted expected");
        generated_tests.push_str(&format!(
            r#"    #[test]
    fn {module}_direct_and_traced() {{
        let expected: serde_json::Value = serde_json::from_str({expected_json:?}).unwrap();
        assert_eq!(super::{module}::execute({input:?}).unwrap(), expected);
        let trace_path = Path::new(env!("CARGO_MANIFEST_DIR")).join("{module}.trace");
        let trace = TraceConfig::enabled(TraceLevel::DEBUG)
            .with_trace_file(trace_path.clone())
            .with_reset_file(true);
        assert_eq!(super::{module}::execute_with_trace({input:?}, trace).unwrap(), expected);
        let trace = fs::read_to_string(trace_path).unwrap();
        assert!(trace.contains("rust_runtime:generated_plan:"), "{{trace}}");
        assert!(trace.contains({identity:?}), "{{trace}}");
    }}

"#,
            module = case.module,
            input = case.input,
        ));
    }
    for case in &error_cases {
        let compiled = compile_metadata(case.source)
            .unwrap_or_else(|error| panic!("compile emitted {} fixture: {error}", case.module));
        let identity = format!("inter-match-gap/emitted/{}.spec", case.module);
        let emitted = emit_rust_source_v2(&compiled, &identity)
            .unwrap_or_else(|error| panic!("emit {} fixture: {error}", case.module));
        generated.push_str(&format!("mod {} {{\n{}\n}}\n\n", case.module, emitted));
        generated_tests.push_str(&format!(
            r#"    #[test]
    fn {module}_direct_and_traced_diagnostic() {{
        let direct = super::{module}::execute({input:?}).unwrap_err();
        assert_eq!(direct.stage, GeneratedSourceStage::ExecuteGenerated);
        assert_eq!(direct.code, GeneratedSourceCode::GeneratedExecutionFailed);
        assert_eq!(direct.detail.as_deref(), Some({detail:?}));
        let traced = super::{module}::execute_with_trace(
            {input:?},
            TraceConfig::disabled(),
        ).unwrap_err();
        assert_eq!(traced, direct);
    }}

"#,
            module = case.module,
            input = case.input,
            detail = case.detail,
        ));
    }
    generated_tests.push_str("}\n");
    generated.push_str(&generated_tests);

    let runtime_manifest = Path::new(env!("CARGO_MANIFEST_DIR"));
    fs::write(
        project.root.join("Cargo.toml"),
        format!(
            "[package]\nname = \"inter-match-gap-emitted-probe\"\nversion = \"0.0.0\"\nedition = \"2024\"\n\n[dependencies]\nlinkedspec-runtime = {{ path = {:?} }}\nserde_json = \"1\"\n\n[workspace]\n",
            runtime_manifest
        ),
    )
    .expect("write emitted gap manifest");
    fs::write(project.root.join("src/lib.rs"), generated).expect("write emitted gap source");

    let output = Command::new("cargo")
        .arg("test")
        .arg("--offline")
        .arg("--quiet")
        .arg("--")
        .arg("--test-threads=1")
        .env("CARGO_TARGET_DIR", project.root.join("target"))
        .current_dir(&project.root)
        .output()
        .expect("compile and execute emitted gap source");
    assert!(
        output.status.success(),
        "emitted gap project failed\nstatus: {}\nstdout:\n{}\nstderr:\n{}",
        output.status,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr),
    );
}

#[test]
#[ignore = "INTER-MATCH-GAP-CAPTURE.3.5 owns Rust runtime admission"]
fn authored_static_compiled_metadata_stage() {
    let contract = contract();
    assert_eq!(contract["contract_id"], CONTRACT_ID);
    assert_eq!(contract["format"], 1);
    assert_eq!(contract["rollout"][2]["id"], "rust_runtime");
    assert_eq!(contract["rollout"][2]["status"], "pending");

    let source = concat!(
        "Top::OR\n",
        " @capture_gaps\n",
        " -> Part[head] { return(\"named\") }\n",
        " -> Part[0] { return(\"numeric\") }\n",
        " -> Part { return(\"unindexed\") }\n",
        "Part:\n",
        " head = /H/\n",
        " /S/\n",
        " foot=/F/\n",
        " é́=/U/\n",
    );
    let parsed = parse_spec(source).expect("parse authored metadata fixture");
    let parsed_json = serde_json::to_value(&parsed).expect("serialize parsed metadata fixture");
    let part_body = parsed_json["rules"][1]["body"]
        .as_array()
        .expect("Part body rows");
    assert_eq!(
        part_body
            .iter()
            .filter(|row| row["kind"]["kind"] == "regex")
            .map(|row| row["kind"]["slot_id"].clone())
            .collect::<Vec<_>>(),
        [json!("head"), Value::Null, json!("foot"), json!("é́")],
        "named and anonymous declarations must share authored order",
    );
    for declaration in ["head=/H/", "head =/H/", "head= /H/", "head = /H/"] {
        let parsed = parse_spec(&format!("Top::\n {declaration}\n"))
            .unwrap_or_else(|error| panic!("spacing variant {declaration:?}: {error}"));
        let row = &parsed.rules[0].body[0];
        let row = serde_json::to_value(row).expect("serialize spacing row");
        assert_eq!(row["kind"]["slot_id"], "head", "{declaration:?}");
        assert_eq!(row["kind"]["pattern"], "H", "{declaration:?}");
    }

    validate(&parsed).expect("validate authored metadata fixture");
    let compiled = compile(&parsed).expect("compile authored metadata fixture");
    let compiled_json = serde_json::to_value(&compiled).expect("serialize compiled metadata");
    assert_eq!(
        rule(&compiled_json, "Part")["regex_slots"],
        json!([
            {"regex_index": 0, "slot_id": "head", "source_id": "inline", "line": 7},
            {"regex_index": 1, "slot_id": null, "source_id": "inline", "line": 8},
            {"regex_index": 2, "slot_id": "foot", "source_id": "inline", "line": 9},
            {"regex_index": 3, "slot_id": "é́", "source_id": "inline", "line": 10}
        ]),
    );
    assert_eq!(
        rule(&compiled_json, "Top")["capture_gaps"],
        json!({
            "enabled": true,
            "directive": "@capture_gaps",
            "source_id": "inline",
            "line": 2
        }),
    );
    let edges = rule(&compiled_json, "Top")["acode_dispatch"]
        .as_array()
        .expect("compiled action edges");
    assert_eq!(
        edges
            .iter()
            .map(|edge| json!({
                "selector_kind": edge["selector_kind"],
                "authored_selector": edge["authored_selector"],
                "target_rule": edge["child_label"],
                "regex_index": edge["child_regex_idx"],
                "target_slot_id": edge["target_slot_id"],
            }))
            .collect::<Vec<_>>(),
        [
            json!({"selector_kind":"named", "authored_selector":"head", "target_rule":"Part", "regex_index":0, "target_slot_id":"head"}),
            json!({"selector_kind":"numeric", "authored_selector":0, "target_rule":"Part", "regex_index":0, "target_slot_id":"head"}),
            json!({"selector_kind":"unindexed", "authored_selector":null, "target_rule":"Part", "regex_index":0, "target_slot_id":"head"}),
        ],
    );

    let reordered = compile_metadata(concat!(
        "Top::\n",
        " -> Part[head] { return(\"named\") }\n",
        " -> Part[0] { return(\"numeric\") }\n",
        "Part:\n",
        " other=/H/\n",
        " head=/H/\n",
    ))
    .expect("compile reordered duplicate-text slots");
    let reordered = serde_json::to_value(reordered).expect("serialize reordered slots");
    let reordered_edges = rule(&reordered, "Top")["acode_dispatch"]
        .as_array()
        .expect("reordered action edges");
    assert_eq!(
        reordered_edges
            .iter()
            .map(|edge| json!({
                "selector_kind": edge["selector_kind"],
                "authored_selector": edge["authored_selector"],
                "regex_index": edge["child_regex_idx"],
                "target_slot_id": edge["target_slot_id"],
            }))
            .collect::<Vec<_>>(),
        [
            json!({"selector_kind":"named", "authored_selector":"head", "regex_index":1, "target_slot_id":"head"}),
            json!({"selector_kind":"numeric", "authored_selector":0, "regex_index":0, "target_slot_id":"other"}),
        ],
        "named identity must survive reordering and duplicate regex text",
    );

    for header in ["Top::", "Top::OR", "Top::OR+", "Top::OR{1,3}", "Top:+"] {
        compile_metadata(&format!(
            "{header}\n @capture_gaps\n -> Part {{ return(\"x\") }}\nPart: /H/\n"
        ))
        .unwrap_or_else(|error| panic!("eligible directive mode {header}: {error}"));
    }
    compile_metadata(concat!(
        "Top::\n",
        " @capture_gaps\n",
        " @mark(gap-control)\n",
        " -> Part { return(\"x\") }\n",
        "Part: /H/\n",
    ))
    .expect("named marks remain independent of gap capture");
    for (source, ownership) in [
        ("Top::\n @capture_gaps\n /H/\n", "none"),
        (
            "Top::\n @capture_gaps\n -> Part\n => Part\nPart: /H/\n",
            "mixed",
        ),
        (
            "Top::\n @capture_gaps\n /H/ -> Part { return(\"x\") }\nPart: /H/\n",
            "local_adjacency",
        ),
    ] {
        let diagnostic = diagnostic(source);
        assert_eq!(diagnostic.code, "capture_gaps_rule_ineligible");
        assert_eq!(diagnostic.field("edge_ownership"), Some(&json!(ownership)));
    }

    let mut located = parse_spec("Top::\n -bad=/H/\n").expect("parse located diagnostic");
    located.source_id = "contract-fixture.spec".to_string();
    let error = validate(&located).expect_err("located invalid name must fail");
    let located_diagnostic = error.diagnostic().expect("located portable diagnostic");
    assert_eq!(
        located_diagnostic.field("source_id"),
        Some(&json!("contract-fixture.spec")),
    );
    assert_eq!(located_diagnostic.field("line"), Some(&json!(2)));

    let descriptor = compiled.to_descriptor_json().expect("project descriptor");
    assert_eq!(
        descriptor["spec"]["Top"]["meta"]["resolved_edges"],
        json!([
            {"ownership":"action", "target":"Part", "regex_index":0, "block":true, "fluent":null},
            {"ownership":"action", "target":"Part", "regex_index":0, "block":true, "fluent":null},
            {"ownership":"action", "target":"Part", "regex_index":0, "block":true, "fluent":null}
        ]),
        "the legacy five-field resolved-edge projection remains unchanged",
    );
    assert_eq!(
        descriptor["spec"]["Top"]["dependency_refs"],
        json!([
            {"label":"Part", "idx":0},
            {"label":"Part", "idx":0},
            {"label":"Part", "idx":0}
        ]),
    );

    let reconstructed: CompiledSpec =
        serde_json::from_value(compiled_json.clone()).expect("reconstruct compiled metadata");
    assert_eq!(
        serde_json::to_value(reconstructed).expect("reserialize compiled metadata"),
        compiled_json,
        "ordinary serde reconstruction must preserve authored provenance",
    );

    let carrier_source = concat!(
        "Top::\n",
        " I { gaps = [] }\n",
        " @capture_gaps\n",
        " -> Part[head] { push(gaps, array(gap_kind(), gap_text())) }\n",
        " LX { push(gaps, array(gap_kind(), gap_text())); return(copy(gaps)) }\n",
        "Part:\n",
        " head=/H/\n",
        " I.return(entry_text())\n",
    );
    let carrier = compile_metadata(carrier_source).expect("compile reconstruction carrier");
    let carrier_json = serde_json::to_value(&carrier).expect("serialize reconstruction carrier");
    let reconstructed: CompiledSpec =
        serde_json::from_value(carrier_json).expect("reconstruct executable carrier");
    assert_eq!(
        Engine::new(reconstructed)
            .execute_value("αHω", &ExecutionOptions::new())
            .expect("execute reconstructed carrier"),
        json!([["prefix", "α"], ["tail", "ω"]]),
        "ordinary reconstructed CompiledSpec executes native gap semantics",
    );

    let generated = generated_value(carrier_source, "αHω")
        .map_err(|error| json!({"error": error}))
        .unwrap_or_else(|error| error);
    assert_eq!(
        json!({
            "regex_slots": descriptor["spec"]["Part"]["meta"]["regex_slots"],
            "capture_gaps": descriptor["spec"]["Top"]["meta"]["capture_gaps"],
            "resolved_slot_edges": descriptor["spec"]["Top"]["meta"]["resolved_slot_edges"],
            "generated_plan": generated,
        }),
        json!({
            "regex_slots": [
                {"regex_index":0, "slot_id":"head", "source_id":"inline", "line":7},
                {"regex_index":1, "slot_id":null, "source_id":"inline", "line":8},
                {"regex_index":2, "slot_id":"foot", "source_id":"inline", "line":9},
                {"regex_index":3, "slot_id":"é́", "source_id":"inline", "line":10}
            ],
            "capture_gaps": {
                "enabled":true, "directive":"@capture_gaps", "source_id":"inline", "line":2
            },
            "resolved_slot_edges": [
                {"selector_kind":"named", "authored_selector":"head", "target_rule":"Part", "regex_index":0, "target_slot_id":"head"},
                {"selector_kind":"numeric", "authored_selector":0, "target_rule":"Part", "regex_index":0, "target_slot_id":"head"},
                {"selector_kind":"unindexed", "authored_selector":null, "target_rule":"Part", "regex_index":0, "target_slot_id":"head"}
            ],
            "generated_plan": [["prefix", "α"], ["tail", "ω"]],
        }),
        "descriptor and generated-plan carriers must expose the current compiled gap contract",
    );

    let emitted = emit_rust_source_v2(&carrier, "gap-generated-plan-v2.spec")
        .expect("emit unchanged generated-source v2 carrier");
    assert!(emitted.contains("linkedspec-generated-source-v2"));
    assert!(emitted.contains("LINKEDSPEC_GENERATED_SOURCE_FORMAT: u32 = 2"));
    assert!(!emitted.contains("capture_gaps:"));
    assert!(!emitted.contains("regex_slots:"));

    let mut legacy = serde_json::to_value(
        compile_metadata("Top::\n -> Part[0]\nPart:\n /H/\n")
            .expect("compile legacy anonymous fixture"),
    )
    .expect("serialize legacy anonymous fixture");
    for rule in legacy["rules"].as_array_mut().expect("legacy rules") {
        let rule = rule.as_object_mut().expect("legacy rule record");
        rule.remove("regex_slots");
        rule.remove("capture_gaps");
        for dependency in rule["dependency_refs"]
            .as_array_mut()
            .expect("legacy dependencies")
        {
            let dependency = dependency.as_object_mut().expect("legacy dependency");
            dependency.remove("selector_kind");
            dependency.remove("authored_selector");
            dependency.remove("target_slot_id");
        }
        for edge in rule["acode_dispatch"]
            .as_array_mut()
            .expect("legacy action edges")
        {
            let edge = edge.as_object_mut().expect("legacy action edge");
            edge.remove("selector_kind");
            edge.remove("authored_selector");
            edge.remove("target_slot_id");
            edge.remove("source_id");
            edge.remove("line");
        }
    }
    let legacy: CompiledSpec =
        serde_json::from_value(legacy).expect("legacy compiled state uses serde defaults");
    assert!(legacy.rules.iter().all(|rule| rule.regex_slots.is_empty()));
    assert!(legacy.rules.iter().all(|rule| rule.capture_gaps.is_none()));
    let legacy_edge = &legacy.find("Top").expect("legacy Top").acode_dispatch[0];
    assert_eq!(legacy_edge.selector_kind, RegexSelectorKind::Unindexed);
    assert_eq!(legacy_edge.source_id, "inline");
    assert_eq!(legacy_edge.line, 0);

    let cases = [
        (
            "Top::\n -bad=/H/\n",
            "regex_slot_name_invalid",
            "parse_declaration",
            2,
            json!({"slot_name":"-bad"}),
        ),
        (
            "Top::\n 123=/H/\n",
            "regex_slot_name_invalid",
            "parse_declaration",
            2,
            json!({"slot_name":"123"}),
        ),
        (
            "Top::\n head=/H/\n head=/S/\n",
            "regex_slot_duplicate_name",
            "resolve_declaration",
            3,
            json!({"slot_name":"head", "first_line":2}),
        ),
        (
            "Top::\n -> Part[missing] { return(\"x\") }\nPart:\n head=/H/\n",
            "regex_slot_unknown_name",
            "resolve_selector",
            2,
            json!({"target_rule":"Part", "authored_selector":"missing"}),
        ),
        (
            "Top::\n -> Part[2] { return(\"x\") }\nPart:\n /H/\n",
            "regex_slot_index_out_of_range",
            "resolve_selector",
            2,
            json!({"target_rule":"Part", "regex_index":2, "regex_count":1}),
        ),
        (
            "Top::\n -> Part[head { return(\"x\") }\nPart:\n head=/H/\n",
            "regex_slot_selector_invalid",
            "parse_selector",
            2,
            json!({"target_rule":"Part", "authored_selector":"head"}),
        ),
        (
            "Top::\n @capture_gaps\n @capture_gaps\n -> Part { return(\"x\") }\nPart: /H/\n",
            "capture_gaps_duplicate_directive",
            "parse_directive",
            3,
            json!({"first_line":2}),
        ),
        (
            "Top::AND\n @capture_gaps\n -> Part { return(\"x\") }\nPart: /H/\n",
            "capture_gaps_rule_ineligible",
            "validate_directive",
            2,
            json!({"family":"and", "cursor_policy":"consume", "edge_ownership":"action", "execution_shape":"single_match"}),
        ),
        (
            "Top::\n @capture_gaps\n => Part\nPart: /H/\n",
            "capture_gaps_rule_ineligible",
            "validate_directive",
            2,
            json!({"family":"or_default", "cursor_policy":"seek", "edge_ownership":"blind", "execution_shape":"default_scan_loop"}),
        ),
        (
            "Top::\n @capture_gaps\n @move_pos\n -> Part { return(\"x\") }\nPart: /H/\n",
            "capture_gaps_legacy_marker_conflict",
            "validate_directive",
            2,
            json!({"marker":"@move_pos", "marker_line":3}),
        ),
    ];
    for (source, code, stage, line, expected_fields) in cases {
        let diagnostic = diagnostic(source);
        assert_eq!(diagnostic.code, code);
        assert_eq!(diagnostic.stage, stage);
        assert_eq!(diagnostic.field("rule_label"), Some(&json!("Top")));
        assert_eq!(diagnostic.field("source_id"), Some(&json!("inline")));
        assert_eq!(diagnostic.field("line"), Some(&json!(line)));
        for (field, value) in expected_fields.as_object().expect("expected fields") {
            assert_eq!(
                diagnostic.field(field),
                Some(value),
                "diagnostic field {field}"
            );
        }
    }

    let native = compile_metadata(concat!(
        "Top::\n",
        " I { gaps = [] }\n",
        " @capture_gaps\n",
        " -> Part[head] { push(gaps, array(gap_kind(), gap_text())) }\n",
        " LX { push(gaps, array(gap_kind(), gap_text())); return(copy(gaps)) }\n",
        "Part:\n",
        " head=/H/\n",
        " I.return(entry_text())\n",
    ))
    .expect("compile native gap RED fixture");
    assert_eq!(
        Engine::new(native)
            .execute_value("αHω", &ExecutionOptions::new())
            .expect("native gap execution"),
        json!([["prefix", "α"], ["tail", "ω"]]),
    );

    assert_eq!(
        native_and_generated_value(
            r#"Top::
 @capture_gaps
 -> Part { return("unexpected") }
 LS { return(array(gap_kind(), gap_text(), match_text())) }
Part: /H/
"#,
            "αH",
        ),
        json!(["prefix", "α", "H"]),
        "capture-enabled selection and local-match extraction precede LS",
    );

    let unicode_source = r#"Top::
 I { segments = [] }
 @capture_gaps
 -> Part[header]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[section] { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 -> Part[footer]  { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span(), "child", call(Part))) }
 LX { push(segments, hash("kind", gap_kind(), "text", gap_text(), "span", gap_span())); return(copy(segments)) }
Part:
 header=/H/
 section=/S/
 footer=/F/
 I { return(hash("slot", entry_slot(), "text", entry_text(), "falsey", 0)) }
"#;
    assert_eq!(
        native_and_generated_value(unicode_source, "αHβ\nS🙂Fω"),
        json!([
            {
                "kind":"prefix", "text":"α",
                "span":{"source_id":"input", "start":0, "end":1, "provenance":"gap"},
                "child":{"slot":{"target_rule":"Part", "regex_index":0, "slot_id":"header", "selector_kind":"named", "authored_selector":"header"}, "text":"H", "falsey":0}
            },
            {
                "kind":"interstitial", "text":"β\n",
                "span":{"source_id":"input", "start":2, "end":4, "provenance":"gap"},
                "child":{"slot":{"target_rule":"Part", "regex_index":1, "slot_id":"section", "selector_kind":"named", "authored_selector":"section"}, "text":"S", "falsey":0}
            },
            {
                "kind":"interstitial", "text":"🙂",
                "span":{"source_id":"input", "start":5, "end":6, "provenance":"gap"},
                "child":{"slot":{"target_rule":"Part", "regex_index":2, "slot_id":"footer", "selector_kind":"named", "authored_selector":"footer"}, "text":"F", "falsey":0}
            },
            {"kind":"tail", "text":"ω", "span":{"source_id":"input", "start":7, "end":8, "provenance":"gap"}}
        ]),
        "Unicode gaps, detached spans, falsey values, and named entry slots are exact",
    );

    assert_eq!(
        native_and_generated_value(
            r#"Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[s] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 -> Part[f] { push(gaps, array(gap_kind(), gap_text(), gap_span())) }
 LX { push(gaps, array(gap_kind(), gap_text(), gap_span())); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 f=/F/
 I.return(entry_text())
"#,
            "HSF",
        ),
        json!([
            ["prefix", "", {"source_id":"input", "start":0, "end":0, "provenance":"gap"}],
            ["interstitial", "", {"source_id":"input", "start":1, "end":1, "provenance":"gap"}],
            ["interstitial", "", {"source_id":"input", "start":2, "end":2, "provenance":"gap"}],
            ["tail", "", {"source_id":"input", "start":3, "end":3, "provenance":"gap"}]
        ]),
        "empty prefix, interstitial, and tail gaps remain first class",
    );

    assert_eq!(
        native_and_generated_value(
            r#"Top::
 I { gaps = [] }
 @capture_gaps
 -> Container[open] { push(gaps, array(gap_text(), call(Container))) }
 -> Bang { push(gaps, array(gap_text(), call(Bang))) }
 LX { push(gaps, array(gap_text(), gap_kind())); return(copy(gaps)) }
Container:
 open=/\{/
 -> Close { return(call(Close)) }
Close:
 /\}/
 I.return(entry_text())
Bang:
 /!/
 I.return(entry_text())
"#,
            "p{abc}gap!",
        ),
        json!([["p", "}"], ["gap", "!"], ["", "tail"]]),
        "the accepted child exit cursor becomes the next committed boundary",
    );

    assert_eq!(
        native_and_generated_value(
            r#"Top::
 @capture_gaps
 -> Container[open] { return(array(gap_text(), call(Container), gap_text())) }
Container:
 open=/\{/
 I { inner = [] }
 @capture_gaps
 -> Atom { push(inner, gap_text()) }
 LX { push(inner, gap_text()); return(copy(inner)) }
Atom:
 /x/
 I.return(entry_text())
"#,
            "p{axtail",
        ),
        json!(["p", ["a", "tail"], "p"]),
        "nested gap owners hide and then restore the parent candidate",
    );

    assert_eq!(
        native_and_generated_value(
            r#"Top::
 I { gaps = [] }
 @capture_gaps
 -> Part[h] {
  tx = recognition_checkpoint();
  matched = recognize_once(tx, call(Probe));
  recognition_rollback(tx);
  push(gaps, gap_text())
 }
 -> Part[s] { push(gaps, gap_text()) }
 LX { push(gaps, gap_text()); return(copy(gaps)) }
Part:
 h=/H/
 s=/S/
 I.return(entry_text())
Probe:
 /X/
 I.return(0)
"#,
            "aHXbS",
        ),
        json!(["a", "Xb", ""]),
        "recognition rollback restores the same invocation gap snapshot",
    );

    let terminal_cases = [
        (
            r#"Top::
 @capture_gaps
 -> Part { return(gap_text()) }
 LX { return(array(gap_kind(), gap_text(), gap_span())) }
Part: /H/
"#,
            "abc",
            json!(["tail", "abc", {"source_id":"input", "start":0, "end":3, "provenance":"gap"}]),
        ),
        (
            r#"Top::OR{0,2}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 EX { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
"#,
            "aHtail",
            json!(["a", "tail"]),
        ),
        (
            r#"Top::OR{0,2}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 EX { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
"#,
            "whole",
            json!(["whole"]),
        ),
        (
            r#"Top::OR{1}
 I { gaps = [] }
 @capture_gaps
 -> Part { push(gaps, gap_text()) }
 E { push(gaps, gap_text()); return(copy(gaps)) }
Part: /H/
"#,
            "aHtail",
            json!(["a", "tail"]),
        ),
    ];
    for (source, input, expected) in terminal_cases {
        assert_eq!(native_and_generated_value(source, input), expected);
    }

    let unavailable_source = "Direct::\n /H/\n I { return(gap_text()) }\n";
    let unavailable = Engine::new(
        compile_metadata(unavailable_source).expect("compile unavailable-context fixture"),
    )
    .execute_value_with_diagnostics("H", &ExecutionOptions::new())
    .expect_err("gap access without a candidate must fail");
    assert_eq!(
        unavailable.message,
        "LINKEDSPEC_INTER_MATCH_GAP_ERROR:gap_capture_context_unavailable",
    );
    assert_eq!(
        unavailable.diagnostic.code.as_deref(),
        Some("gap_capture_context_unavailable"),
    );
    assert_eq!(unavailable.diagnostic.stage, "access_gap_context");
    let generated_unavailable = generated_runtime_error(unavailable_source, "H");
    assert_eq!(generated_unavailable.message, unavailable.message);
    assert_eq!(generated_unavailable.diagnostic, unavailable.diagnostic);

    let post_commit_source = "Top::OR{1}\n @capture_gaps\n -> Part { return(0) }\n IT { return(gap_kind()) }\nPart: /H/\n";
    let post_commit =
        Engine::new(compile_metadata(post_commit_source).expect("compile post-commit IT fixture"))
            .execute_value_with_diagnostics("H", &ExecutionOptions::new())
            .expect_err("IT must not retain the committed candidate");
    assert_eq!(
        post_commit.diagnostic.code.as_deref(),
        Some("gap_capture_context_unavailable"),
    );
    let generated_post_commit = generated_runtime_error(post_commit_source, "H");
    assert_eq!(generated_post_commit.message, post_commit.message);
    assert_eq!(generated_post_commit.diagnostic, post_commit.diagnostic);

    let regression_source =
        "Top::OR{1}\n @capture_gaps\n -> Part { rewind_match_start() }\nPart: /H/\n";
    let regression = Engine::new(
        compile_metadata(regression_source).expect("compile cursor-regression fixture"),
    )
    .execute_value_with_diagnostics("aH", &ExecutionOptions::new())
    .expect_err("gap commit must reject cursor regression");
    assert_eq!(
        regression.message,
        "LINKEDSPEC_SOURCE_LOCATION_ERROR:source_location_cursor_regression",
    );
    assert_eq!(
        regression.diagnostic.code.as_deref(),
        Some("source_location_cursor_regression"),
    );
    let generated_regression = generated_runtime_error(regression_source, "aH");
    assert_eq!(generated_regression.message, regression.message);
    assert_eq!(generated_regression.diagnostic, regression.diagnostic);

    assert_eq!(
        native_and_generated_value(
            "Top::OR{2}\n @capture_gaps\n -> Part { return(gap_text()) }\n EX { return(\"unexpected-ex\") }\n E { return(\"unexpected-e\") }\nPart: /H/\n",
            "H",
        ),
        Value::Null,
        "failed repetition minimum exposes neither a tail nor terminal hooks",
    );

    assert_eq!(
        native_and_generated_value("Part::\n /H/\n I { return(entry_slot()) }\n", "H"),
        Value::Null,
        "direct entry has no action-edge slot identity",
    );

    independently_compiled_emitted_gap_contract();
}
