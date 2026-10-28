//! TYPE-REFERENCE-BOOK.1.2.23.3.39.1.6 — live recognition progress, not just
//! neutral fixture validation. Public schema and ordinary loop behavior stay fixed.
use linkedspec_core::{compiler::compile, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, GeneratedRuleSpec, classify_generated_rule_family,
    emit_rust_source_v2, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use linkedspec_runtime::{RuntimeDiagnosticOutputExecutionError, RuntimeExecutionError};
use serde_json::{Value, json};

enum Expected {
    Value(Value),
    ProgressError,
}
struct Case {
    name: String,
    source: String,
    input: &'static str,
    expected: Expected,
}

fn scoped(name: &str, guard: &str, input: &'static str, expected: Expected) -> Case {
    Case {
        name: name.into(),
        source: format!(
            "Top::\n I {{tx=recognition_checkpoint();matched=recognize_once(tx,call(Guard));payload=recognition_commit(tx);return([matched,payload,cursor_pos()])}}\n /never/\n{guard}"
        ),
        input,
        expected,
    }
}

fn check_cases(cases: Vec<Case>) {
    // Reach every source and route before checking expected outcomes. A first
    // RED must not hide a later mode or an ordinary/one-shot compatibility case.
    let observations: Vec<_> = cases.iter().map(|case| {
        let parsed = parse_spec_with_user_functions(&case.source).unwrap();
        validate(&parsed).unwrap();
        let compiled = compile(&parsed).unwrap();
        let serialized = serde_json::to_string(&compiled).unwrap();
        let mut rows = Vec::new(); let mut rules = Vec::new();
        for rule in &compiled.rules {
            let label = match rule.label.as_str() { "Top"=>"Top", "Guard"=>"Guard", "Atom"=>"Atom", label=>panic!("unowned progress label {label}") };
            let family = classify_generated_rule_family(rule);
            rows.push(GeneratedPlanRow { label, family: family.contract_name() });
            rules.push(GeneratedRuleSpec { label, family });
        }
        let emitted = emit_rust_source_v2(&compiled, "recognition-live-progress.spec").unwrap();
        eprintln!("RUST_LIVE_PROGRESS_INPUT {} {}", case.name, json!({"source":case.source,"input":case.input,"serialized":serialized,"emitted":emitted,"plan":rows}));
        let restored = serde_json::from_str(&serialized).unwrap();
        let native = Engine::new(compiled);
        let loaded = Engine::new(restored);
        let generated = native.execute_generated_value_with_plan_with_diagnostic_output(&rules, case.input, None).map_err(|error| match error {
            RuntimeDiagnosticOutputExecutionError::Runtime(error)=>error,
            error=>panic!("unexpected generated control/sink error {error}"),
        });
        let sdk: [Result<Value, RuntimeExecutionError>; 3] = [
            native.execute_value_with_diagnostics(case.input, &ExecutionOptions::new()),
            loaded.execute_value_with_diagnostics(case.input, &ExecutionOptions::new()),
            generated,
        ];
        let envelope = execute_generated_parser_v2(&serialized, &rows, case.input, "recognition-live-progress.spec", GENERATED_SOURCE_CONTRACT).map_err(|error| error.to_string());
        eprintln!("RUST_LIVE_PROGRESS_ACTUAL {} {}", case.name, json!({"sdk":sdk,"envelope":envelope}));
        (case, sdk, envelope)
    }).collect();
    for (case, sdk, envelope) in observations {
        for (index, result) in sdk.into_iter().enumerate() {
            match &case.expected {
                Expected::Value(value) => assert_eq!(
                    result.as_ref().expect("compatible result"),
                    value,
                    "{} sdk{index}",
                    case.name
                ),
                Expected::ProgressError => {
                    let error = result.expect_err("accepted zero-progress repetition must reject");
                    assert!(
                        error
                            .message()
                            .contains("recognition_zero_progress_repetition"),
                        "{} sdk{index}",
                        case.name
                    );
                    assert_eq!(
                        error.diagnostic().code.as_deref(),
                        Some("recognition_zero_progress_repetition")
                    );
                    assert_eq!(error.diagnostic().rule_label.as_deref(), Some("Guard"));
                    assert_eq!(error.diagnostic().stage, "runtime_execution");
                }
            }
        }
        match &case.expected {
            Expected::Value(value) => {
                assert_eq!(envelope.unwrap(), *value, "{} envelope", case.name)
            }
            Expected::ProgressError => assert!(
                envelope
                    .expect_err("v2 progress failure")
                    .contains("recognition_zero_progress_repetition")
            ),
        }
    }
}

#[test]
fn live_action_repetitions_reject_zero_progress_before_maximum() {
    let mut cases = Vec::new();
    for (name, mode) in [
        ("plus", "+"),
        ("or", "OR"),
        ("or_one", "OR{1}"),
        ("and_one", "AND{1}"),
        ("and_two", "AND{2}"),
    ] {
        cases.push(scoped(
            name,
            &format!("Guard:{mode}\n /(?=a)/ -> Guard[0] .return(0)\n"),
            "a",
            Expected::ProgressError,
        ));
    }
    cases.push(scoped(
        "and_zero_group",
        "Guard:AND{1}\n /(?=a)/\n /(?=a)/ -> Guard[1] {return(0)}\n",
        "a",
        Expected::ProgressError,
    ));
    cases.push(scoped(
        "and_early_zero",
        "Guard:AND{1}\n /(?=a)/\n /a/\n -> Guard[0] {return(0)}\n",
        "a",
        Expected::ProgressError,
    ));
    cases.push(scoped(
        "it_cannot_bypass",
        "Guard:OR{1}\n /(?=a)/ -> Guard[0] {return(0)}\n IT {return(\"IT\")}\n",
        "a",
        Expected::ProgressError,
    ));
    check_cases(cases);
}

#[test]
fn live_blind_repetitions_check_the_completed_parent_iteration() {
    let mut cases = Vec::new();
    for (name, mode) in [
        ("blind_or_one", "OR{1}"),
        ("blind_and_one", "AND{1}"),
        ("blind_default", ""),
    ] {
        cases.push(scoped(
            name,
            &format!("Guard:{mode}\n => Atom\nAtom:|\n /(?=a)/ -> Atom[0] {{return(0)}}\n"),
            "a",
            Expected::ProgressError,
        ));
    }
    check_cases(cases);
}

#[test]
fn progress_is_measured_over_the_whole_and_group() {
    check_cases(vec![
        scoped(
            "zero_then_consuming",
            "Guard:AND{1}\n /(?=a)/\n /a/ -> Guard[1] {return(0)}\n",
            "a",
            Expected::Value(json!([true, [0], 1])),
        ),
        scoped(
            "consuming_then_zero",
            "Guard:AND{1}\n /a/\n /(?=b)/ -> Guard[1] {return(0)}\n",
            "ab",
            Expected::Value(json!([true, [0], 1])),
        ),
        scoped(
            "consuming_choice",
            "Guard:OR{1}\n /a/ -> Guard[0] {return(0)}\n",
            "a",
            Expected::Value(json!([true, [0], 1])),
        ),
    ]);
}

#[test]
fn ordinary_and_one_shot_zero_width_behavior_is_preserved() {
    let mut cases = vec![scoped(
        "one_shot",
        "Guard:|\n /(?=a)/ -> Guard[0] {return(0)}\n",
        "a",
        Expected::Value(json!([true, 0, 0])),
    )];
    for (name, mode) in [("ordinary_or", "OR{1}"), ("ordinary_and", "AND{1}")] {
        cases.push(Case {
            name: name.into(),
            source: format!("Guard::{mode}\n /(?=a)/ -> Guard[0] {{return(0)}}\n"),
            input: "a",
            expected: Expected::Value(json!([0])),
        });
    }
    cases.push(Case {name:"ordinary_blind".into(),source:"Guard::OR{1}\n => Atom\n EX {return(\"ORDINARY\")}\n E {return(\"ORDINARY\")}\nAtom:|\n /(?=a)/ -> Atom[0] {return(\"BODY\")}\n".into(),input:"a",expected:Expected::Value(json!("ORDINARY"))});
    check_cases(cases);
}
