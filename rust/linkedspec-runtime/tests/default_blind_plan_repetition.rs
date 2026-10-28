//! TYPE-REFERENCE-BOOK.1.2.23.3.39.1.4.1 — default repeats without changing v2 rows.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, GeneratedSourceCode,
    classify_generated_rule_family, emit_rust_source_v2, execute_generated_parser_v2,
    validate_generated_parser_plan_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::json;

fn setup(name: &str, source: &str) -> (CompiledSpec, String, Vec<GeneratedPlanRow>) {
    let parsed = parse_spec_with_user_functions(source).expect("parse blind mode control");
    validate(&parsed).expect("validate blind mode control");
    let compiled = compile(&parsed).expect("compile blind mode control");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Top" => "Top",
                "Value" => "Value",
                label => panic!("unowned blind mode control label: {label}"),
            },
            family: classify_generated_rule_family(rule).contract_name(),
        })
        .collect();
    let emitted = emit_rust_source_v2(&compiled, "default-blind-plan.spec").unwrap();
    eprintln!(
        "DEFAULT_BLIND_PLAN_SOURCE {name} {}",
        json!({
            "source":source,"serialized":serialized,"plan":plan,"emitted":emitted,
        })
    );
    (compiled, serialized, plan)
}

fn blind_source(mode: &str) -> String {
    format!(
        "Top::{mode}\n => Value\n E {{return(cursor_pos())}}\nValue:AND\n /H/\n /cat/ -> Value[1] {{return(\"BODY\")}}\n"
    )
}

fn check(name: &str, source: &str, family: &str, expected: i64) {
    let (compiled, serialized, plan) = setup(name, source);
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let values = [
        Engine::new(compiled).execute_value("HcatHcat", &ExecutionOptions::new()),
        Engine::new(restored).execute_value("HcatHcat", &ExecutionOptions::new()),
        execute_generated_parser_v2(
            &serialized,
            &plan,
            "HcatHcat",
            "default-blind-plan.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ];
    eprintln!(
        "DEFAULT_BLIND_PLAN_ACTUAL {name} {}",
        json!({"routes":values,"plan":plan})
    );
    assert_eq!(
        plan.iter().find(|row| row.label == "Top").unwrap().family,
        family,
        "existing authored-family projection stays unchanged"
    );
    for (route, value) in values.into_iter().enumerate() {
        assert_eq!(
            value.expect("execute blind mode control"),
            json!(expected),
            "{name} route{route}"
        );
    }
}

#[test]
fn default_blind_keeps_or_bcode_row_and_repeats() {
    check("default", &blind_source(""), "or_bcode", 8);
}
#[test]
fn pipe_sharing_or_bcode_row_stays_single() {
    check("pipe", &blind_source("|"), "or_bcode", 4);
}
#[test]
fn explicit_or_repetition_keeps_rep_bcode_row() {
    check("explicit_or", &blind_source("OR{1}"), "rep_bcode", 4);
}
#[test]
fn explicit_and_keeps_and_bcode_row() {
    check("explicit_and", &blind_source("AND"), "and_bcode", 4);
}
#[test]
fn default_action_keeps_default_row_and_whole_rule_return() {
    check(
        "default_action",
        "Top::\n /Hcat/ -> Top {return(cursor_pos())}\n",
        "default",
        4,
    );
}
#[test]
fn existing_default_plan_remains_valid_and_rep_bcode_substitution_is_rejected() {
    let (_, serialized, plan) = setup("validation", &blind_source(""));
    validate_generated_parser_plan_v2(
        &serialized,
        &plan,
        "default-blind-plan.spec",
        GENERATED_SOURCE_CONTRACT,
    )
    .expect("existing or_bcode artifact remains valid");
    let mut wrong = plan.clone();
    wrong
        .iter_mut()
        .find(|row| row.label == "Top")
        .unwrap()
        .family = "rep_bcode";
    let error = validate_generated_parser_plan_v2(
        &serialized,
        &wrong,
        "default-blind-plan.spec",
        GENERATED_SOURCE_CONTRACT,
    )
    .expect_err("do not redefine default's accepted neutral row");
    assert_eq!(error.code, GeneratedSourceCode::GeneratedPlanFamilyMismatch);
}
