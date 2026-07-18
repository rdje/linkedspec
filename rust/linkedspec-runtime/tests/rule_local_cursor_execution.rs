//! FUTURE-PARITY-BACKLOG.9.1.4.3-.4 — live execution and descriptor projection.

use linkedspec_core::compiler::compile;
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_core::types::{CompiledSpec, ParseMode};
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GeneratedRuleFamily, GeneratedRuleSpec, classify_generated_rule_family, emit_rust_source_v1,
};
use linkedspec_runtime::spec_loader::{SpecLoadOptions, SpecRequest, load_and_compile_spec};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
use std::collections::BTreeSet;
use std::fs;
use std::path::PathBuf;
use std::time::{SystemTime, UNIX_EPOCH};

const CONTRACT_SOURCE: &str =
    include_str!("../../../capability_conformance/rule_local_cursor_contract.json");

#[derive(Clone, Copy)]
struct ExecutionCase {
    id: &'static str,
    source: &'static str,
    input: &'static str,
    expected: ValueFactory,
}

#[derive(Clone, Copy)]
enum ValueFactory {
    Null,
    String(&'static str),
    Strings(&'static [&'static str]),
}

impl ValueFactory {
    fn value(self) -> Value {
        match self {
            Self::Null => Value::Null,
            Self::String(value) => json!(value),
            Self::Strings(values) => json!(values),
        }
    }
}

const PARENT_CHILD_CASES: &[ExecutionCase] = &[
    ExecutionCase {
        id: "and_to_or_blind",
        input: "prefix x",
        expected: ValueFactory::Strings(&["hit"]),
        source: r#"Top::AND
 => Child
Child:
 /x/
 -> Child { return("hit") }
"#,
    },
    ExecutionCase {
        id: "or_to_and_blind",
        input: "prefix x",
        expected: ValueFactory::Null,
        source: r#"Top::|
 => Child
Child:AND
 /x/
 -> Child { return("hit") }
"#,
    },
    ExecutionCase {
        id: "and_to_or_action",
        input: "x junk x",
        expected: ValueFactory::String("hit"),
        source: r#"Top::AND
 -> Child { return(call(Child)) }
Child:
 /x/
 -> Child { return("hit") }
"#,
    },
    ExecutionCase {
        id: "or_to_and_action",
        input: "prefix x junk x",
        expected: ValueFactory::Null,
        source: r#"Top::|
 -> Child { return(call(Child)) }
Child:AND
 /x/
 -> Child { return("hit") }
"#,
    },
    ExecutionCase {
        id: "and_to_or_call",
        input: "p junk x",
        expected: ValueFactory::String("hit"),
        source: r#"Top::AND
 /p/
 -> Top { return(call(Child)) }
Child:
 /x/
 -> Child { return("hit") }
"#,
    },
    ExecutionCase {
        id: "or_to_and_call",
        input: "prefix p junk x",
        expected: ValueFactory::Null,
        source: r#"Top::|
 /p/
 -> Top { return(call(Child)) }
Child:AND
 /x/
 -> Child { return("hit") }
"#,
    },
    ExecutionCase {
        id: "and_to_or_recursion",
        input: "p junk xp junk z",
        expected: ValueFactory::String("done"),
        source: r#"Top::AND
 /p/
 -> Top { return(call(Child)) }
Child:OR
 /x/ -> Child[0] { return(call(Top)) }
 /z/ -> Child[1] { return("done") }
"#,
    },
    ExecutionCase {
        id: "or_to_and_recursion",
        input: "junk p junk x z",
        expected: ValueFactory::Null,
        source: r#"Top::|
 /p/ -> Top[0] { return(call(Child)) }
 /z/ -> Top[1] { return("done") }
Child:AND
 /x/ -> Child { return(call(Top)) }
"#,
    },
];

const STRUCTURAL_CASES: &[ExecutionCase] = &[
    ExecutionCase {
        id: "ordered_landmarks",
        input: "junk h junk b",
        expected: ValueFactory::Strings(&["header", "body"]),
        source: r#"Top::AND
 => Header
 => Body
Header:
 /h/
 -> Header { return("header") }
Body:
 /b/
 -> Body { return("body") }
"#,
    },
    ExecutionCase {
        id: "anchored_choice",
        input: "prefix x",
        expected: ValueFactory::Null,
        source: r#"Top::|
 => X
 => Y
X:AND
 /x/
 -> X { return("x") }
Y:AND
 /y/
 -> Y { return("y") }
"#,
    },
];

fn contract() -> Value {
    serde_json::from_str(CONTRACT_SOURCE).expect("rule-local cursor contract JSON")
}

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse cursor execution fixture");
    validate(&parsed).expect("validate cursor execution fixture");
    compile(&parsed).expect("compile cursor execution fixture")
}

fn execute_compiled(compiled: CompiledSpec, input: &str, options: &ExecutionOptions) -> Value {
    Engine::new(compiled)
        .execute_value(input, options)
        .expect("execute cursor fixture")
}

fn temp_path(label: &str) -> PathBuf {
    let nonce = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("clock after epoch")
        .as_nanos();
    std::env::temp_dir().join(format!(
        "linkedspec-rule-local-cursor-{}-{label}-{nonce}.spec",
        std::process::id()
    ))
}

#[test]
fn every_neutral_parent_child_and_structural_case_is_rule_local_live_and_serialized() {
    let contract = contract();
    let contract_parent_ids = contract["parent_child_cases"]
        .as_array()
        .unwrap()
        .iter()
        .map(|case| case["id"].as_str().unwrap())
        .collect::<BTreeSet<_>>();
    let test_parent_ids = PARENT_CHILD_CASES
        .iter()
        .map(|case| case.id)
        .collect::<BTreeSet<_>>();
    assert_eq!(test_parent_ids, contract_parent_ids);

    let contract_structural_ids = contract["structural_replacements"]
        .as_array()
        .unwrap()
        .iter()
        .map(|case| case["id"].as_str().unwrap())
        .collect::<BTreeSet<_>>();
    let test_structural_ids = STRUCTURAL_CASES
        .iter()
        .map(|case| case.id)
        .collect::<BTreeSet<_>>();
    assert_eq!(test_structural_ids, contract_structural_ids);

    for case in PARENT_CHILD_CASES.iter().chain(STRUCTURAL_CASES) {
        let compiled = compile_source(case.source);
        let expected = case.expected.value();
        assert_eq!(
            execute_compiled(compiled.clone(), case.input, &ExecutionOptions::new()),
            expected,
            "{}: live execution",
            case.id
        );

        let serialized = serde_json::to_string(&compiled).expect("serialize CompiledSpec");
        let reconstructed: CompiledSpec =
            serde_json::from_str(&serialized).expect("reconstruct CompiledSpec");
        assert_eq!(
            execute_compiled(reconstructed, case.input, &ExecutionOptions::new()),
            expected,
            "{}: serialized execution",
            case.id
        );
    }
}

#[test]
fn every_neutral_family_spelling_spends_its_authored_policy() {
    let contract = contract();
    let family_cases = contract["family_cases"].as_array().unwrap();
    let descriptor_contract = &contract["descriptor_contract"];
    assert_eq!(family_cases.len(), 36);

    for case in family_cases {
        let id = case["id"].as_str().unwrap();
        let header = case["header"].as_str().unwrap();
        let top_prefix = if header.starts_with("Top::") {
            ""
        } else {
            "Root::\n I { return(\"unused\") }\n\n"
        };
        let source = format!("{top_prefix}{header}\n /x/ -> Top {{ return(\"hit\") }}\n");
        let compiled = compile_source(&source);
        let descriptor = compiled
            .to_descriptor_json()
            .expect("project family descriptor");
        assert_eq!(
            descriptor["meta"]["cursor_contract"], descriptor_contract["meta"]["cursor_contract"],
            "{id}: descriptor contract"
        );
        assert_eq!(
            descriptor["spec"]["Top"]["meta"]["family"], case["family"],
            "{id}: descriptor family"
        );
        assert_eq!(
            descriptor["spec"]["Top"]["meta"]["cursor_policy"], case["cursor_policy"],
            "{id}: descriptor/live policy agreement"
        );
        let options = ExecutionOptions::new().with_entry_rule("Top");
        let expected = if case["cursor_policy"] == "consume" {
            Value::Null
        } else {
            json!("hit")
        };
        let serialized = serde_json::to_string(&compiled).expect("serialize family fixture");
        let reconstructed: CompiledSpec =
            serde_json::from_str(&serialized).expect("reconstruct family fixture");
        for (projection, compiled) in [("live", compiled), ("serialized", reconstructed)] {
            let result = Engine::new(compiled).execute_value("prefix x", &options);
            if case["cursor_policy"] == "consume" {
                match result {
                    Ok(value) => assert_eq!(value, expected, "{id}: {projection} policy"),
                    Err(error) => assert!(
                        error.contains("expected at least") && error.contains("got 0"),
                        "{id}: {projection} consume failure: {error}"
                    ),
                }
            } else {
                assert_eq!(
                    result.expect("seek family execution"),
                    expected,
                    "{id}: {projection} policy"
                );
            }
        }
    }
}

#[test]
fn compiled_json_derives_policy_from_family_without_a_mutable_field() {
    for (source, expected) in [
        ("Top::\n /x/ -> Top { return(\"hit\") }\n", json!("hit")),
        ("Top::AND\n /x/ -> Top { return(\"hit\") }\n", Value::Null),
    ] {
        let compiled = compile_source(source);
        let mut serialized = serde_json::to_value(&compiled).expect("serialize CompiledSpec");
        assert!(
            serialized["rules"][0].get("parse_mode").is_none(),
            "compiled JSON must not serialize independent cursor policy"
        );

        serialized["rules"][0]
            .as_object_mut()
            .unwrap()
            .insert("parse_mode".to_string(), json!("consume"));
        let reconstructed: CompiledSpec =
            serde_json::from_value(serialized).expect("accept legacy serialized field as unknown");
        assert_eq!(
            execute_compiled(reconstructed, "prefix x", &ExecutionOptions::new()),
            expected,
            "legacy serialized policy cannot change authored family behavior"
        );
    }
}

#[test]
fn staged_public_override_no_longer_propagates_into_rule_execution() {
    let and_compiled = compile_source("Top::AND\n /x/ -> Top { return(\"hit\") }\n");
    assert_eq!(
        execute_compiled(
            and_compiled,
            "prefix x",
            &ExecutionOptions::new().with_parse_mode(ParseMode::Seek),
        ),
        Value::Null,
        "caller seek cannot override authored AND consume"
    );

    let default_compiled = compile_source("Top::\n /x/ -> Top { return(\"hit\") }\n");
    assert_eq!(
        execute_compiled(
            default_compiled,
            "prefix x",
            &ExecutionOptions::new().with_parse_mode(ParseMode::Consume),
        ),
        json!("hit"),
        "caller consume cannot override authored default seek"
    );
}

#[test]
fn loaded_execution_and_trace_use_each_entered_rule_family() {
    let source = PARENT_CHILD_CASES
        .iter()
        .find(|case| case.id == "and_to_or_call")
        .unwrap()
        .source;
    let path = temp_path("loaded");
    fs::write(&path, source).expect("write loaded cursor fixture");
    let request = SpecRequest::path(path.to_string_lossy().into_owned());
    let options = SpecLoadOptions::new(std::env::temp_dir());
    let loaded = load_and_compile_spec(&request, &options).expect("load cursor fixture");
    let loaded_descriptor = loaded
        .compiled()
        .to_descriptor_json()
        .expect("project loaded descriptor");
    assert_eq!(
        loaded_descriptor["spec"]["Top"]["meta"]["cursor_policy"],
        json!("consume")
    );
    assert_eq!(
        loaded_descriptor["spec"]["Child"]["meta"]["cursor_policy"],
        json!("seek")
    );
    let loaded_value = loaded
        .into_engine()
        .execute_value("p junk x", &ExecutionOptions::new())
        .expect("execute loaded cursor fixture");
    let _ = fs::remove_file(&path);
    assert_eq!(loaded_value, json!("hit"));

    let trace_path = temp_path("trace").with_extension("log");
    let trace_config = TraceConfig::enabled(TraceLevel::DEBUG)
        .with_trace_file(trace_path.clone())
        .with_reset_file(true);
    let traced = Engine::new(compile_source(source))
        .execute_value_with_trace("p junk x", &ExecutionOptions::new(), trace_config)
        .expect("execute traced cursor fixture");
    assert_eq!(traced, json!("hit"));

    let trace = fs::read_to_string(&trace_path).expect("read cursor trace");
    let _ = fs::remove_file(&trace_path);
    assert!(
        trace.contains("rule=Top regex_idx=0 start=0 end=1 pos_before=0 parse_mode=Consume"),
        "trace must attribute consume to the AND parent:\n{trace}"
    );
    assert!(
        trace.contains("rule=Child regex_idx=0 start=7 end=8 pos_before=1 parse_mode=Seek"),
        "trace must attribute seek to the default child:\n{trace}"
    );
}

#[test]
fn descriptor_v1_is_current_while_generated_source_v1_remains_staged() {
    let contract = contract();
    let compiled = compile_source("Top::|\n /x/ -> Top { return(\"hit\") }\n");
    assert_eq!(
        execute_compiled(compiled.clone(), "prefix x", &ExecutionOptions::new()),
        json!("hit"),
        "normal live execution uses exact compact-OR policy"
    );

    let descriptor = compiled
        .to_descriptor_json()
        .expect("project descriptor v1");
    assert_eq!(
        descriptor["meta"]["cursor_contract"],
        contract["descriptor_contract"]["meta"]["cursor_contract"]
    );
    assert_eq!(
        descriptor["spec"]["Top"]["meta"]["family"],
        json!("or_default")
    );
    assert_eq!(
        descriptor["spec"]["Top"]["meta"]["cursor_policy"],
        json!("seek")
    );
    assert_eq!(
        descriptor["spec"]["Top"]["meta"]["resolved_edges"],
        json!([{
            "ownership": "action",
            "target": "Top",
            "regex_index": 0,
            "block": true,
            "fluent": null
        }])
    );

    let family = classify_generated_rule_family(compiled.top_rule().unwrap());
    assert_eq!(family, GeneratedRuleFamily::AndSingleAcode);
    let generated_plan = [GeneratedRuleSpec {
        label: "Top",
        family,
    }];
    assert_eq!(
        Engine::new(compiled.clone())
            .execute_generated_value_with_plan(&generated_plan, "prefix x")
            .expect("execute staged generated v1 plan"),
        Value::Null,
        "FUTURE-PARITY-BACKLOG.9.1.4.5 owns generated execution migration"
    );

    let generated_source =
        emit_rust_source_v1(&compiled, "cursor-v1-boundary.spec").expect("emit staged v1");
    assert!(generated_source.contains("linkedspec-generated-source-v1"));
    assert!(
        generated_source.contains(r#"\"parse_mode\":\"consume\""#),
        "v1's embedded compatibility wire shape must remain explicit"
    );
}
