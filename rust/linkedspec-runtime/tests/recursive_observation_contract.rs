use linkedspec_core::compiler::compile;
use linkedspec_core::expr::Expr;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, emit_rust_source_v2, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

const AUTHORED_SOURCE: &str = r#"Top::
 I {
   value = observe_recognition(observation, call(Child))
   return(array(value, observation))
 }

Child::AND
 /é/
 E { return(false) }
"#;

const PLAN: &[GeneratedPlanRow] = &[
    GeneratedPlanRow {
        label: "Top",
        family: "default",
    },
    GeneratedPlanRow {
        label: "Child",
        family: "and_regex_only",
    },
];

fn compile_source(source: &str) -> Result<CompiledSpec, String> {
    let parsed = parse_spec_with_user_functions(source).map_err(|error| error.to_string())?;
    validate(&parsed).map_err(|error| error.to_string())?;
    compile(&parsed).map_err(|error| error.to_string())
}

fn expected_observation(
    rule_label: &str,
    invocation_id: u64,
    parent_invocation_id: Option<u64>,
    entry_offset: u64,
    selected_match: Option<(u64, u64)>,
    accepted_exit: Option<u64>,
    outcome: &str,
    diagnostic: Option<&str>,
) -> Value {
    json!({
        "source_id": "input",
        "rule_label": rule_label,
        "invocation_id": invocation_id,
        "parent_invocation_id": parent_invocation_id,
        "entry_position": {"source_id": "input", "offset": entry_offset},
        "selected_match": selected_match.map(|(start, end)| json!({
            "source_id": "input",
            "start": start,
            "end": end,
            "provenance": "match",
        })),
        "accepted_exit": accepted_exit.map(|offset| json!({
            "source_id": "input",
            "offset": offset,
        })),
        "outcome": outcome,
        "diagnostic": diagnostic,
    })
}

#[test]
fn authored_form_lowers_once_to_a_dedicated_non_eager_node_and_rejects_static_drift() {
    let compiled = compile_source(AUTHORED_SOURCE).expect("compile recursive observation");
    let block = compiled
        .find("Top")
        .expect("compiled Top")
        .preamble
        .as_ref()
        .expect("Top I block");
    let Expr::AssignScalar { name, value } = &block.statements[0].expr else {
        panic!("recursive observation must remain one scalar assignment");
    };
    assert_eq!(name, "value");
    assert!(matches!(
        value.as_ref(),
        Expr::ObserveRecognition { target, rule }
            if target == "observation" && rule == "Child"
    ));
    let serialized = serde_json::to_string(&compiled).expect("serialize observation AST");
    assert_eq!(serialized.matches("observe_recognition").count(), 1);

    for (source, code) in [
        (
            r#"Top:: I { value = observe_recognition(observation["nested"], call(Child)) } Child::AND /x/"#,
            "source_location_recursive_observation_target",
        ),
        (
            r#"Top:: I { value = observe_recognition(observation, dynamic_child) } Child::AND /x/"#,
            "source_location_recursive_observation_operand",
        ),
        (
            r#"Top:: I { value = observe_recognition(observation, call(Missing)) }"#,
            "source_location_recursive_observation_operand",
        ),
        (
            r#"Top::
 I {
   tx = recognition_checkpoint()
   matched = recognize_once(tx, call(Observer))
   recognition_rollback(tx)
   return(matched)
 }
Observer:
 I { value = observe_recognition(observation, call(Child)); return(value) }
Child::AND
 /x/
"#,
            "recognition_effect_forbidden:binding_write",
        ),
        (
            r#"fn inspect() { value = observe_recognition(observation, call(Child)); return(value) }
Top::
 I {
   tx = recognition_checkpoint()
   matched = recognize_once(tx, call(Observer))
   recognition_rollback(tx)
   return(matched)
 }
Observer: I { return(inspect()) }
Child::AND
 /x/
"#,
            "recognition_effect_forbidden:binding_write",
        ),
    ] {
        let error = compile_source(source).expect_err("invalid observation must reject statically");
        assert!(error.contains(code), "expected {code}, got {error}");
    }
}

#[test]
fn native_and_reconstructed_execution_preserve_falsey_payloads_and_detached_records() {
    let compiled = compile_source(AUTHORED_SOURCE).expect("compile recursive observation");
    let expected = json!([
        false,
        expected_observation(
            "Child",
            2,
            Some(1),
            0,
            Some((0, 1)),
            Some(1),
            "accepted",
            None
        ),
    ]);
    let engine = Engine::new(compiled.clone());
    let first = engine
        .execute_value("é", &ExecutionOptions::new())
        .expect("native recursive observation");
    assert_eq!(first, expected);

    let mut detached = first;
    detached[1]["entry_position"]["offset"] = json!(99);
    detached[1]["selected_match"]["start"] = json!(99);
    assert_eq!(
        engine
            .execute_value("é", &ExecutionOptions::new())
            .expect("fresh native recursive observation"),
        expected,
        "detached mutation cannot affect a fresh parse and ids restart parse-locally",
    );

    let encoded = serde_json::to_string(&compiled).expect("serialize compiled observation");
    let reconstructed: CompiledSpec =
        serde_json::from_str(&encoded).expect("reconstruct compiled observation");
    assert_eq!(
        Engine::new(reconstructed)
            .execute_value("é", &ExecutionOptions::new())
            .expect("reconstructed recursive observation"),
        expected,
    );
}

#[test]
fn failed_zero_regex_and_child_owned_action_edge_cursor_semantics_are_exact() {
    let failed = compile_source(
        r#"Top::
 I { value = observe_recognition(observation, call(Missing)); return(array(value, observation)) }
Missing::AND
 /z/
"#,
    )
    .expect("compile failed-selection fixture");
    assert_eq!(
        Engine::new(failed)
            .execute_value("x", &ExecutionOptions::new())
            .expect("failed observation returns normally"),
        json!([
            null,
            expected_observation("Missing", 2, Some(1), 0, None, None, "failed", None),
        ]),
    );

    let zero = compile_source(
        r#"Top::
 I { value = observe_recognition(observation, call(Coordinator)); return(array(value, observation)) }
Coordinator:
 I { return("coordinated") }
"#,
    )
    .expect("compile zero-regex fixture");
    assert_eq!(
        Engine::new(zero)
            .execute_value("", &ExecutionOptions::new())
            .expect("zero-regex observation"),
        json!([
            "coordinated",
            expected_observation(
                "Coordinator",
                2,
                Some(1),
                0,
                None,
                Some(0),
                "accepted",
                None
            ),
        ]),
    );

    let edge = compile_source(
        r#"Top::
 /a/ -> Top {
   value = observe_recognition(observation, call(Child))
   return(array(value, observation))
 }
Child::AND
 /b/
 /c/
 -> Child[0] { first = match_text() }
 -> Child[1] { return(array(entry_text(), entry_start_pos())) }
"#,
    )
    .expect("compile action-edge fixture");
    assert_eq!(
        Engine::new(edge)
            .execute_value("abc", &ExecutionOptions::new())
            .expect("action-edge observation"),
        json!([
            ["a", 0],
            expected_observation(
                "Child",
                2,
                Some(1),
                1,
                Some((2, 3)),
                Some(3),
                "accepted",
                None
            ),
        ]),
    );
}

#[test]
fn direct_and_mutual_nonprogress_observations_keep_exact_typed_diagnostics() {
    let nested_ordinary = compile_source(
        r#"Top:: I { value = observe_recognition(observation, call(Child)); return(array(value, observation)) }
Child: I { nested = call(Child); return("guarded") }
"#,
    )
    .expect("compile ordinary nested-recursion fixture");
    assert_eq!(
        Engine::new(nested_ordinary)
            .execute_value("", &ExecutionOptions::new())
            .expect("ordinary nested recursion retains its existing cutoff"),
        json!([
            "guarded",
            expected_observation("Child", 2, Some(1), 0, None, Some(0), "accepted", None),
        ]),
        "only the one pending observed entry may become an observation rejection",
    );

    let direct = compile_source(
        r#"Top:: I { value = observe_recognition(top_observation, call(DirectRecur)); return(value) }
DirectRecur: I { value = observe_recognition(observation, call(DirectRecur)); return(value) }
"#,
    )
    .expect("compile direct recursion fixture");
    let direct_error = Engine::new(direct)
        .execute_value("x", &ExecutionOptions::new())
        .expect_err("direct recursive observation must reject");
    assert!(
        direct_error.contains("source_location_nonprogress_direct_recursion"),
        "{direct_error}",
    );

    let mutual = compile_source(
        r#"Top:: I { value = observe_recognition(top_observation, call(MutualA)); return(value) }
MutualA: I { value = observe_recognition(observation_a, call(MutualB)); return(value) }
MutualB: I { value = observe_recognition(observation_b, call(MutualA)); return(value) }
"#,
    )
    .expect("compile mutual recursion fixture");
    let mutual_error = Engine::new(mutual)
        .execute_value("x", &ExecutionOptions::new())
        .expect_err("mutual recursive observation must reject");
    assert!(
        mutual_error.contains("source_location_nonprogress_mutual_recursion"),
        "{mutual_error}",
    );
}

#[test]
fn aborted_observation_propagates_the_original_runtime_diagnostic() {
    let aborted = compile_source(
        r#"Top::
 I { value = observe_recognition(observation, call(AbortChild)); return(value) }
AbortChild:
 I { recognition_commit(missing) }
"#,
    )
    .expect("compile aborted observation fixture");
    let error = Engine::new(aborted)
        .execute_value("", &ExecutionOptions::new())
        .expect_err("aborted observation must propagate its child failure");
    assert!(error.contains("recognition_token_expected"), "{error}");
}

#[test]
fn generated_plan_executes_the_same_private_observation_runtime() {
    let compiled = compile_source(AUTHORED_SOURCE).expect("compile generated observation");
    let encoded = serde_json::to_string(&compiled).expect("serialize generated observation");
    assert_eq!(
        execute_generated_parser_v2(
            &encoded,
            PLAN,
            "é",
            "recursive-observation/rust.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("generated-plan recursive observation"),
        json!([
            false,
            expected_observation(
                "Child",
                2,
                Some(1),
                0,
                Some((0, 1)),
                Some(1),
                "accepted",
                None
            ),
        ]),
    );
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
                "recursive-observation-probe-{}-{nonce}",
                std::process::id()
            ));
        fs::create_dir_all(root.join("src")).expect("create emitted observation workspace");
        Self { root }
    }
}

impl Drop for EmittedProject {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

#[test]
fn independently_compiled_emitted_source_uses_the_same_private_runtime() {
    let compiled = compile_source(AUTHORED_SOURCE).expect("compile emitted observation");
    let emitted = emit_rust_source_v2(&compiled, "recursive-observation/rust.spec")
        .expect("emit recursive observation source");
    let project = EmittedProject::new();
    let runtime_manifest = Path::new(env!("CARGO_MANIFEST_DIR"));
    fs::write(
        project.root.join("Cargo.toml"),
        format!(
            "[package]\nname = \"recursive-observation-probe\"\nversion = \"0.0.0\"\nedition = \"2024\"\n\n[dependencies]\nlinkedspec-runtime = {{ path = {:?} }}\nserde_json = \"1\"\n\n[workspace]\n",
            runtime_manifest
        ),
    )
    .expect("write emitted observation manifest");
    fs::write(
        project.root.join("src/main.rs"),
        format!(
            "mod generated {{\n{emitted}\n}}\nfn main() {{ let value = generated::parse(\"é\").expect(\"generated observation\"); println!(\"{{}}\", value); }}\n"
        ),
    )
    .expect("write emitted observation main");

    let build = Command::new("cargo")
        .arg("run")
        .arg("--offline")
        .arg("--quiet")
        .env("CARGO_TARGET_DIR", project.root.join("target"))
        .current_dir(&project.root)
        .output()
        .expect("run emitted observation project");
    assert!(
        build.status.success(),
        "emitted observation project failed:\n{}",
        String::from_utf8_lossy(&build.stderr),
    );
    let actual: Value = serde_json::from_slice(&build.stdout).expect("emitted JSON output");
    assert_eq!(
        actual,
        json!([
            false,
            expected_observation(
                "Child",
                2,
                Some(1),
                0,
                Some((0, 1)),
                Some(1),
                "accepted",
                None
            ),
        ]),
    );
}
