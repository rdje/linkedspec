//! FUTURE-PARITY-BACKLOG.14.3.3.3 — admitted Rust recognition-transaction contract.
//!
//! Ordinary and canonical Cargo execution run this exact final-path consumer once.

use linkedspec_runtime::recognition_transaction::{
    RecognitionFrameState, RecognitionTransactionAuthority, RecognitionTransactionError,
};
use linkedspec_runtime::source_location::SourceAuthority;
use serde_json::{Value, json};
use std::collections::{BTreeMap, BTreeSet};
use std::sync::Arc;

const CONTRACT_SOURCE: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../capability_conformance/recognition_transaction_contract.json"
));
const CONTRACT_ID: &str = "linkedspec-recognition-transaction-v1";

fn contract() -> Value {
    serde_json::from_str(CONTRACT_SOURCE).expect("recognition-transaction contract JSON")
}

fn new_authority(source_identity: &str) -> RecognitionTransactionAuthority {
    let sources = BTreeMap::from([("input".to_owned(), "abcdef".to_owned())]);
    RecognitionTransactionAuthority::new(Arc::new(SourceAuthority::new(&sources)), source_identity)
}

fn state(cursor: u64, boundary: Option<u64>, marks: &[(&str, u64)]) -> RecognitionFrameState {
    RecognitionFrameState::new(
        cursor,
        boundary,
        marks
            .iter()
            .map(|(name, offset)| ((*name).to_owned(), *offset))
            .collect(),
    )
}

fn initial_state() -> RecognitionFrameState {
    state(2, Some(1), &[("a", 1)])
}

fn staged_state() -> RecognitionFrameState {
    state(5, Some(4), &[("a", 3), ("b", 4)])
}

fn diagnostic(contract: &Value, code: &str) -> Value {
    contract["diagnostics"]
        .as_array()
        .expect("diagnostic fixtures")
        .iter()
        .find(|row| row["code"] == code)
        .unwrap_or_else(|| panic!("missing diagnostic fixture {code}"))
        .clone()
}

fn assert_diagnostic(
    contract: &Value,
    error: RecognitionTransactionError,
    code: &str,
    expected: &[(&str, Value)],
) {
    let fixture = diagnostic(contract, code);
    let record = error.as_record();
    assert_eq!(record["code"], code);

    let actual_fields = record
        .as_object()
        .expect("diagnostic record")
        .keys()
        .cloned()
        .collect::<BTreeSet<_>>();
    let expected_fields = fixture["fields"]
        .as_array()
        .expect("diagnostic fields")
        .iter()
        .map(|field| field.as_str().expect("diagnostic field").to_owned())
        .collect::<BTreeSet<_>>();
    assert_eq!(actual_fields, expected_fields, "{code} exact fields");

    for (field, value) in expected {
        assert_eq!(&record[*field], value, "{code} context field {field}");
    }
    assert_eq!(
        error.to_string(),
        format!("LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:{code}")
    );
}

fn payload_for(operation: &str) -> Value {
    match operation {
        "attempt_match:false" => json!(false),
        "attempt_match:0" => json!(0),
        "attempt_match:" => json!(""),
        "attempt_match:null" => Value::Null,
        "attempt_match:value" => json!("value"),
        other => panic!("unowned matched-payload operation {other}"),
    }
}

#[test]
fn neutral_authority_and_rust_admission_are_exact() {
    let contract = contract();
    assert_eq!(contract["contract_id"], CONTRACT_ID);
    assert_eq!(contract["format"], 1);
    assert_eq!(contract["expected_counts"]["current_action_ir_nodes"], 128);
    assert_eq!(contract["expected_counts"]["dedicated_action_ir_nodes"], 4);
    assert_eq!(contract["expected_counts"]["canonical_call_contracts"], 246);
    assert_eq!(contract["expected_counts"]["token_positive_cases"], 8);
    assert_eq!(contract["expected_counts"]["token_negative_cases"], 17);
    assert_eq!(contract["expected_counts"]["effect_graph_cases"], 6);
    assert_eq!(contract["expected_counts"]["mark_cases"], 6);
    assert_eq!(contract["expected_counts"]["progress_cases"], 8);
    assert_eq!(contract["expected_counts"]["diagnostics"], 15);
    assert_eq!(contract["expected_counts"]["mutations"], 43);

    let rollout = contract["rollout"].as_array().expect("rollout rows");
    assert_eq!(rollout.len(), 9);
    assert_eq!(rollout[0]["leg"], "neutral");
    assert_eq!(rollout[0]["status"], "complete");
    assert_eq!(rollout[1]["leg"], "perl");
    assert_eq!(rollout[1]["status"], "complete");
    assert_eq!(rollout[2]["leg"], "rust");
    assert_eq!(rollout[2]["status"], "complete");
    assert_eq!(
        rollout[2]["paths"],
        json!(["rust/linkedspec-runtime/tests/recognition_transaction_contract.rs"])
    );
    assert_eq!(rollout[3]["leg"], "dart");
    assert_eq!(rollout[3]["status"], "complete");
    assert_eq!(
        rollout[3]["paths"],
        json!(["dart/test/recognition_transaction_contract_test.dart"])
    );
    assert!(rollout[4..].iter().all(|row| row["status"] == "red"));

    assert_eq!(
        contract["authored_surface"],
        json!({
            "checkpoint": "tx = recognition_checkpoint()",
            "attempt": "matched = recognize_once(tx, call(Child))",
            "commit": "payload = recognition_commit(tx)",
            "rollback": "recognition_rollback(tx)",
            "operand": "recognize_once accepts exactly one unevaluated static call(Rule) operand",
            "result_separation": "recognize_once returns a strict match boolean; the recognized payload remains staged until commit",
            "availability": "available only in an admitted backend; currently Perl, Rust, and Dart, with all later runtime legs future and unavailable",
        })
    );
}

#[test]
fn invocation_frames_are_monotonic_opaque_and_same_label_isolated() {
    let mut authority = new_authority("input.spec");
    let parent = authority
        .enter_invocation("Top", "root", initial_state())
        .expect("enter parent invocation");
    authority
        .write_mark(&parent, "shared", 1)
        .expect("write parent mark");
    let parent_snapshot = authority
        .frame_snapshot(&parent)
        .expect("snapshot parent invocation");

    let child = authority
        .enter_invocation("Top", "Top->Top", state(3, Some(2), &[]))
        .expect("enter recursive child invocation");
    let child_snapshot = authority
        .frame_snapshot(&child)
        .expect("snapshot child invocation");
    assert!(child_snapshot.invocation() > parent_snapshot.invocation());
    assert!(child_snapshot.generation() > parent_snapshot.generation());
    assert_eq!(
        authority
            .read_mark(&child, "shared")
            .expect("read child mark"),
        None
    );
    authority
        .write_mark(&child, "shared", 4)
        .expect("write child mark");
    assert_eq!(
        authority
            .read_mark(&parent, "shared")
            .expect("read parent mark"),
        Some(1)
    );
    authority
        .leave_invocation(&child)
        .expect("leave recursive child");

    let next = authority
        .enter_invocation("Top", "Top->Top:next", state(3, Some(2), &[]))
        .expect("enter next recursive child");
    let next_snapshot = authority
        .frame_snapshot(&next)
        .expect("snapshot next child");
    assert!(next_snapshot.invocation() > child_snapshot.invocation());
    assert!(next_snapshot.generation() > child_snapshot.generation());
    authority.leave_invocation(&next).expect("leave next child");

    let mut detached = parent_snapshot.as_record();
    detached["marks"]["shared"] = json!(99);
    assert_eq!(
        authority
            .read_mark(&parent, "shared")
            .expect("read parent after detached mutation"),
        Some(1)
    );
    authority
        .leave_invocation(&parent)
        .expect("leave parent invocation");

    let stale = authority
        .frame_snapshot(&parent)
        .expect_err("left frame generation must reject");
    assert_diagnostic(
        &contract(),
        stale,
        "recognition_mark_generation_invalid",
        &[
            ("rule", json!("Top")),
            ("origin", json!("root")),
            ("generation", json!(parent_snapshot.generation())),
        ],
    );
}

#[test]
fn all_eight_positive_tokens_keep_match_presence_separate_from_payload() {
    let contract = contract();
    for fixture in contract["fixtures"]["token_positive"]
        .as_array()
        .expect("positive token fixtures")
    {
        let mut authority = new_authority("input.spec");
        let frame = authority
            .enter_invocation(
                "Top",
                fixture["id"].as_str().expect("fixture id"),
                initial_state(),
            )
            .expect("enter positive fixture invocation");
        let token = authority
            .checkpoint(&frame, fixture["id"].as_str().expect("fixture id"))
            .expect("checkpoint positive fixture");
        let attempt = fixture["ops"]
            .as_array()
            .expect("positive operations")
            .iter()
            .find_map(|operation| {
                let operation = operation.as_str().expect("positive operation");
                operation.starts_with("attempt_").then_some(operation)
            })
            .expect("positive attempt operation");
        let matched = attempt != "attempt_miss";
        let payload = matched.then(|| payload_for(attempt));
        let observed = authority
            .attempt(
                &frame,
                &token,
                matched,
                payload.clone(),
                if matched {
                    staged_state()
                } else {
                    initial_state()
                },
            )
            .expect("stage positive attempt");
        assert_eq!(observed, matched, "{} strict match", fixture["id"]);

        let terminal = fixture["ops"]
            .as_array()
            .expect("positive operations")
            .last()
            .and_then(Value::as_str)
            .expect("terminal operation");
        if terminal == "commit" {
            assert_eq!(
                authority
                    .commit(&frame, &token)
                    .expect("commit positive fixture"),
                payload,
                "{} committed payload",
                fixture["id"]
            );
        } else {
            authority
                .rollback(&frame, &token)
                .expect("rollback positive fixture");
        }
        authority
            .leave_invocation(&frame)
            .expect("leave positive fixture invocation");
    }
}

#[test]
fn rollback_restores_and_commit_retains_cursor_boundary_and_invocation_marks() {
    let contract = contract();
    for fixture in contract["fixtures"]["marks"]
        .as_array()
        .expect("mark fixtures")
        .iter()
        .take(2)
    {
        let mut authority = new_authority("input.spec");
        let frame = authority
            .enter_invocation(
                "Top",
                fixture["id"].as_str().expect("fixture id"),
                initial_state(),
            )
            .expect("enter mark fixture");
        let token = authority
            .checkpoint(&frame, fixture["id"].as_str().expect("fixture id"))
            .expect("checkpoint mark fixture");
        authority
            .attempt(&frame, &token, true, Some(json!("payload")), staged_state())
            .expect("stage mark fixture");
        if fixture["terminal"] == "commit" {
            authority
                .commit(&frame, &token)
                .expect("commit mark fixture");
        } else {
            authority
                .rollback(&frame, &token)
                .expect("rollback mark fixture");
        }
        assert_eq!(
            authority
                .frame_snapshot(&frame)
                .expect("snapshot terminal frame")
                .state_record(),
            fixture["expected"],
            "{} terminal state",
            fixture["id"]
        );
        authority
            .leave_invocation(&frame)
            .expect("leave mark fixture");
    }
}

#[test]
fn negative_token_ownership_and_lifecycle_paths_use_portable_diagnostics() {
    let contract = contract();

    for fixture in contract["fixtures"]["token_negative"]
        .as_array()
        .expect("negative token fixtures")
        .iter()
        .filter(|fixture| {
            matches!(
                fixture["violation"].as_str(),
                Some(
                    "copy"
                        | "comparison"
                        | "aggregate_storage"
                        | "function_storage"
                        | "codeblock_storage"
                        | "return"
                        | "capture"
                        | "serialization"
                )
            )
        })
    {
        let mut authority = new_authority("input.spec");
        let frame = authority
            .enter_invocation(
                "Top",
                fixture["id"].as_str().expect("fixture id"),
                initial_state(),
            )
            .expect("enter escape fixture");
        let token = authority
            .checkpoint(&frame, fixture["id"].as_str().expect("fixture id"))
            .expect("checkpoint escape fixture");
        let escape = fixture["violation"].as_str().expect("escape kind");
        let error = authority
            .reject_escape(&frame, &token, escape)
            .expect_err("token escape must reject");
        assert_diagnostic(
            &contract,
            error,
            "recognition_token_escape",
            &[
                ("rule", json!("Top")),
                ("origin", fixture["id"].clone()),
                ("escape", json!(escape)),
            ],
        );
        authority
            .leave_invocation(&frame)
            .expect("leave escape fixture");
    }

    let mut authority = new_authority("input.spec");
    let frame = authority
        .enter_invocation("Top", "missing_attempt", initial_state())
        .expect("enter missing-attempt fixture");
    let token = authority
        .checkpoint(&frame, "missing_attempt")
        .expect("checkpoint missing-attempt fixture");
    let missing = authority
        .rollback(&frame, &token)
        .expect_err("terminal without attempt must reject");
    assert_diagnostic(
        &contract,
        missing,
        "recognition_attempt_count",
        &[
            ("rule", json!("Top")),
            ("origin", json!("missing_attempt")),
            ("count", json!(0)),
        ],
    );
    authority
        .leave_invocation(&frame)
        .expect("leave missing-attempt fixture");

    let mut authority = new_authority("input.spec");
    let frame = authority
        .enter_invocation("Top", "retry", initial_state())
        .expect("enter retry fixture");
    let token = authority
        .checkpoint(&frame, "retry")
        .expect("checkpoint retry fixture");
    authority
        .attempt(&frame, &token, false, None, initial_state())
        .expect("first attempt");
    let retry = authority
        .attempt(&frame, &token, true, Some(json!("value")), staged_state())
        .expect_err("retry must reject");
    assert_diagnostic(
        &contract,
        retry,
        "recognition_attempt_count",
        &[
            ("rule", json!("Top")),
            ("origin", json!("retry")),
            ("count", json!(2)),
        ],
    );
    authority
        .leave_invocation(&frame)
        .expect("leave retry fixture");
}

#[test]
fn cross_invocation_cross_source_nesting_reuse_and_unwind_are_exact() {
    let contract = contract();

    let mut authority = new_authority("input.spec");
    let parent = authority
        .enter_invocation("Top", "parent", initial_state())
        .expect("enter parent");
    let token = authority
        .checkpoint(&parent, "parent")
        .expect("checkpoint parent");
    let child = authority
        .enter_invocation("Top", "child", initial_state())
        .expect("enter child");
    let cross_invocation = authority
        .rollback(&child, &token)
        .expect_err("cross-invocation token must reject");
    assert_diagnostic(
        &contract,
        cross_invocation,
        "recognition_cross_invocation",
        &[("rule", json!("Top")), ("origin", json!("child"))],
    );
    authority
        .leave_invocation(&child)
        .expect("leave cross-invocation child");
    authority
        .leave_invocation(&parent)
        .expect("leave cross-invocation parent");

    let mut first = new_authority("first.spec");
    let first_frame = first
        .enter_invocation("Top", "cross_source", initial_state())
        .expect("enter first source");
    let first_token = first
        .checkpoint(&first_frame, "cross_source")
        .expect("checkpoint first source");
    let mut second = new_authority("second.spec");
    let second_frame = second
        .enter_invocation("Top", "cross_source", initial_state())
        .expect("enter second source");
    let cross_source = second
        .rollback(&second_frame, &first_token)
        .expect_err("cross-source token must reject");
    assert_diagnostic(
        &contract,
        cross_source,
        "recognition_cross_source",
        &[("rule", json!("Top")), ("origin", json!("cross_source"))],
    );
    second
        .leave_invocation(&second_frame)
        .expect("leave second source");
    first
        .leave_invocation(&first_frame)
        .expect("leave first source");

    let mut authority = new_authority("input.spec");
    let frame = authority
        .enter_invocation("Top", "double_terminal", initial_state())
        .expect("enter double-terminal fixture");
    let token = authority
        .checkpoint(&frame, "double_terminal")
        .expect("checkpoint double-terminal fixture");
    authority
        .attempt(&frame, &token, true, Some(json!("value")), staged_state())
        .expect("attempt double-terminal fixture");
    authority
        .commit(&frame, &token)
        .expect("first terminal operation");
    let reused = authority
        .rollback(&frame, &token)
        .expect_err("second terminal operation must reject");
    assert_diagnostic(
        &contract,
        reused,
        "recognition_token_reused",
        &[
            ("rule", json!("Top")),
            ("origin", json!("double_terminal")),
            ("operation", json!("rollback")),
        ],
    );
    authority
        .leave_invocation(&frame)
        .expect("leave double-terminal fixture");

    let mut authority = new_authority("input.spec");
    let frame = authority
        .enter_invocation("Top", "unwind", initial_state())
        .expect("enter unwind fixture");
    let token = authority
        .checkpoint(&frame, "unwind")
        .expect("checkpoint unwind fixture");
    authority
        .attempt(&frame, &token, true, Some(json!("value")), staged_state())
        .expect("stage unwind fixture");
    let unwind = authority
        .leave_invocation(&frame)
        .expect_err("active token must restore and reject on unwind");
    assert_diagnostic(
        &contract,
        unwind,
        "recognition_terminal_required",
        &[("rule", json!("Top")), ("origin", json!("unwind"))],
    );
}

#[test]
fn nesting_rejection_and_token_drop_restore_before_invalidation() {
    let contract = contract();

    let mut authority = new_authority("input.spec");
    let parent = authority
        .enter_invocation("Top", "nesting_parent", initial_state())
        .expect("enter nesting parent");
    let parent_before = authority
        .frame_snapshot(&parent)
        .expect("snapshot nesting parent before checkpoint")
        .state_record();
    let parent_token = authority
        .checkpoint(&parent, "nesting_parent")
        .expect("checkpoint nesting parent");
    authority
        .attempt(
            &parent,
            &parent_token,
            true,
            Some(json!("value")),
            staged_state(),
        )
        .expect("stage nesting parent");
    let child = authority
        .enter_invocation("Child", "nesting_child", state(3, Some(2), &[]))
        .expect("enter nesting child");
    let nesting = match authority.checkpoint(&child, "nesting_child") {
        Ok(_) => panic!("nested transaction must reject"),
        Err(error) => error,
    };
    assert_diagnostic(
        &contract,
        nesting,
        "recognition_nesting_forbidden",
        &[("rule", json!("Child")), ("origin", json!("nesting_child"))],
    );
    assert_eq!(
        authority
            .frame_snapshot(&parent)
            .expect("snapshot restored nesting parent")
            .state_record(),
        parent_before
    );
    authority
        .leave_invocation(&child)
        .expect("leave nesting child");
    authority
        .leave_invocation(&parent)
        .expect("leave restored nesting parent");

    let mut authority = new_authority("input.spec");
    let frame = authority
        .enter_invocation("Top", "drop", initial_state())
        .expect("enter token-drop fixture");
    let frame_before = authority
        .frame_snapshot(&frame)
        .expect("snapshot token-drop frame before checkpoint")
        .state_record();
    {
        let token = authority
            .checkpoint(&frame, "drop")
            .expect("checkpoint token-drop fixture");
        authority
            .attempt(&frame, &token, true, Some(json!("value")), staged_state())
            .expect("stage token-drop fixture");
    }
    assert_eq!(
        authority
            .frame_snapshot(&frame)
            .expect("snapshot restored token-drop frame")
            .state_record(),
        frame_before
    );
    authority
        .leave_invocation(&frame)
        .expect("leave restored token-drop frame");
}

mod integration {
    use super::*;
    use linkedspec_core::compiler::compile;
    use linkedspec_core::expr::Expr;
    use linkedspec_core::types::CompiledSpec;
    use linkedspec_core::validation::validate;
    use linkedspec_runtime::engine::{Engine, ExecutionOptions};
    use linkedspec_runtime::recognition_transaction::{
        classify_recognition_effects, validate_recognition_progress,
    };
    use linkedspec_runtime::source_emitter::{
        GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, emit_rust_source_v2,
        execute_generated_parser_v2,
    };
    use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
    use std::fs;
    use std::path::{Path, PathBuf};
    use std::process::Command;
    use std::time::{SystemTime, UNIX_EPOCH};

    const AUTHORED_SOURCE: &str = r#"Top::AND
 => Child {
   tx = recognition_checkpoint();
   matched = recognize_once(tx, call(Child));
   if(matched) {
     payload = recognition_commit(tx);
     return(payload)
   } else {
     recognition_rollback(tx);
     return("miss")
   }
 }

Child::AND
 /x/
 E { return(false) }
"#;

    const PLAN: &[GeneratedPlanRow] = &[
        GeneratedPlanRow {
            label: "Top",
            family: "and_bcode_seq",
        },
        GeneratedPlanRow {
            label: "Child",
            family: "and_regex_only",
        },
    ];

    fn compile_source(source: &str) -> CompiledSpec {
        let parsed = parse_spec_with_user_functions(source).expect("parse transaction fixture");
        validate(&parsed).expect("validate transaction fixture");
        compile(&parsed).expect("compile transaction fixture")
    }

    #[test]
    fn authored_forms_lower_to_four_dedicated_non_eager_nodes() {
        let compiled = compile_source(AUTHORED_SOURCE);
        let top = compiled.find("Top").expect("compiled Top rule");
        let block = top.bcode_dispatch[0]
            .code
            .as_ref()
            .expect("transaction edge code");

        let Expr::AssignScalar {
            name: checkpoint_name,
            value: checkpoint_value,
        } = &block.statements[0].expr
        else {
            panic!("checkpoint must remain a dedicated scalar assignment");
        };
        assert_eq!(checkpoint_name, "tx");
        assert!(matches!(
            checkpoint_value.as_ref(),
            Expr::RecognitionCheckpoint
        ));

        let Expr::AssignScalar {
            name: attempt_name,
            value: attempt_value,
        } = &block.statements[1].expr
        else {
            panic!("attempt must remain a dedicated scalar assignment");
        };
        assert_eq!(attempt_name, "matched");
        assert!(matches!(
            attempt_value.as_ref(),
            Expr::RecognizeOnce { token, rule } if token == "tx" && rule == "Child"
        ));
        assert!(block.statements.iter().any(|statement| matches!(
            statement.expr,
            Expr::RecognitionRollback { ref token } if token == "tx"
        )));

        let serialized = serde_json::to_value(&compiled).expect("serialize compiled transaction");
        let text = serialized.to_string();
        for kind in [
            "recognition_checkpoint",
            "recognize_once",
            "recognition_commit",
            "recognition_rollback",
        ] {
            assert_eq!(text.matches(kind).count(), 1, "one dedicated {kind} node");
        }
    }

    #[test]
    fn neutral_effect_graphs_and_progress_cases_are_enforced_without_state_substitutes() {
        let contract = contract();
        for graph in contract["fixtures"]["effect_graphs"]
            .as_array()
            .expect("effect graph fixtures")
        {
            let result = classify_recognition_effects(graph);
            assert_eq!(result.is_ok(), graph["accepted"] == true, "{}", graph["id"]);
            if graph["accepted"] == false {
                assert_eq!(
                    result.expect_err("forbidden graph").as_record()["code"],
                    graph["diagnostic"],
                    "{} diagnostic",
                    graph["id"]
                );
            }
        }
        for fixture in contract["fixtures"]["progress"]
            .as_array()
            .expect("progress fixtures")
        {
            let result = validate_recognition_progress(fixture);
            assert_eq!(
                result.is_ok(),
                fixture["accepted"] == true,
                "{}",
                fixture["id"]
            );
            if fixture["accepted"] == false {
                assert_eq!(
                    result.expect_err("zero-progress fixture").as_record()["code"],
                    fixture["diagnostic"],
                    "{} diagnostic",
                    fixture["id"]
                );
            }
        }
    }

    #[test]
    fn native_reconstructed_and_generated_plan_carriers_preserve_false_payload() {
        let compiled = compile_source(AUTHORED_SOURCE);
        let expected = json!(false);
        assert_eq!(
            Engine::new(compiled.clone())
                .execute_value("xx", &ExecutionOptions::new())
                .expect("native transaction execution"),
            expected
        );

        let encoded = serde_json::to_string(&compiled).expect("serialize compiled transaction");
        let reconstructed: CompiledSpec =
            serde_json::from_str(&encoded).expect("reconstruct compiled transaction");
        assert_eq!(
            Engine::new(reconstructed)
                .execute_value("xx", &ExecutionOptions::new())
                .expect("reconstructed transaction execution"),
            expected
        );
        assert_eq!(
            execute_generated_parser_v2(
                &encoded,
                PLAN,
                "xx",
                "recognition-transaction/rust.spec",
                GENERATED_SOURCE_CONTRACT,
            )
            .expect("generated-plan transaction execution"),
            expected
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
                    "recognition-transaction-probe-{}-{nonce}",
                    std::process::id()
                ));
            fs::create_dir_all(root.join("src")).expect("create emitted transaction workspace");
            Self { root }
        }
    }

    impl Drop for EmittedProject {
        fn drop(&mut self) {
            let _ = fs::remove_dir_all(&self.root);
        }
    }

    #[test]
    fn independently_compiled_emitted_source_uses_the_same_transaction_runtime() {
        let compiled = compile_source(AUTHORED_SOURCE);
        let emitted = emit_rust_source_v2(&compiled, "recognition-transaction/rust.spec")
            .expect("emit transaction source");
        let project = EmittedProject::new();
        let runtime_manifest = Path::new(env!("CARGO_MANIFEST_DIR"));
        fs::write(
            project.root.join("Cargo.toml"),
            format!(
                "[package]\nname = \"recognition-transaction-probe\"\nversion = \"0.0.0\"\nedition = \"2024\"\n\n[dependencies]\nlinkedspec-runtime = {{ path = {:?} }}\nserde_json = \"1\"\n\n[workspace]\n",
                runtime_manifest
            ),
        )
        .expect("write emitted transaction manifest");
        fs::write(
            project.root.join("src/main.rs"),
            format!(
                "mod generated {{\n{emitted}\n}}\nfn main() {{ let value = generated::parse(\"xx\").expect(\"generated transaction\"); println!(\"{{}}\", value); }}\n"
            ),
        )
        .expect("write emitted transaction main");

        let target = project.root.join("target");
        let build = Command::new("cargo")
            .arg("run")
            .arg("--offline")
            .arg("--quiet")
            .env("CARGO_TARGET_DIR", &target)
            .current_dir(&project.root)
            .output()
            .expect("run emitted transaction project");
        assert!(
            build.status.success(),
            "emitted transaction project failed:\n{}",
            String::from_utf8_lossy(&build.stderr)
        );
        assert_eq!(
            String::from_utf8(build.stdout)
                .expect("UTF-8 stdout")
                .trim(),
            "false"
        );
    }

    #[test]
    fn compatibility_cursor_stack_and_nontransaction_execution_remain_unchanged() {
        let ordinary = compile_source(
            r#"Top::AND
 /a/ E { save_cursor(); rewind_match_start(); restore_cursor(); return("ok") }
"#,
        );
        assert_eq!(
            Engine::new(ordinary)
                .execute_value("a", &ExecutionOptions::new())
                .expect("ordinary compatibility cursor execution"),
            json!("ok")
        );
    }
}
