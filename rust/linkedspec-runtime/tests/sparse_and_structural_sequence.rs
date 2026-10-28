//! TYPE-REFERENCE-BOOK.1.2.23.3.39.1 — independent structural/dependency intake.
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    emit_rust_source_v2, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn check(name: &str, source: &str, slots: usize, family: Option<&str>, cases: &[(&str, Value)]) {
    let parsed = parse_spec_with_user_functions(source).expect("parse structural AND source");
    validate(&parsed).expect("validate structural AND source");
    let compiled = compile(&parsed).expect("compile structural AND source");
    let rule = compiled
        .rules
        .iter()
        .find(|rule| rule.label == "Value")
        .unwrap();
    let authored_slots = rule.regex_slots.len();
    let selected_family = classify_generated_rule_family(rule).contract_name();
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Top" => "Top",
                "Value" => "Value",
                "Part" => "Part",
                label => panic!("unowned structural test label: {label}"),
            },
            family: classify_generated_rule_family(rule).contract_name(),
        })
        .collect();
    let emitted = emit_rust_source_v2(&compiled, "sparse-and-structural.spec").unwrap();
    eprintln!(
        "RUST_SPARSE_AND_INPUT {name} {}",
        json!({
            "source":source, "serialized":serialized, "emitted":emitted,
            "authored_slots":authored_slots, "family":selected_family, "plan":plan,
        })
    );
    let native = Engine::new(compiled);
    let loaded = Engine::new(restored);
    // Collect every input and route before checking any expected result. A RED
    // must not hide an unreached distinguishing input later in the same shape.
    let observations: Vec<_> = cases
        .iter()
        .map(|(input, expected)| {
            let values = [
                if std::env::var_os("LINKEDSPEC_SPARSE_AND_TRACE").is_some() {
                    native.execute_value_with_trace(
                        input,
                        &ExecutionOptions::new(),
                        TraceConfig::enabled(TraceLevel::DEBUG),
                    )
                } else {
                    native.execute_value(input, &ExecutionOptions::new())
                },
                loaded.execute_value(input, &ExecutionOptions::new()),
                execute_generated_parser_v2(
                    &serialized,
                    &plan,
                    input,
                    "sparse-and-structural.spec",
                    GENERATED_SOURCE_CONTRACT,
                )
                .map_err(|error| error.to_string()),
            ];
            eprintln!(
                "RUST_SPARSE_AND_ACTUAL {name} {}",
                json!({"input":input,"routes":values})
            );
            (input, expected, values)
        })
        .collect();
    assert_eq!(
        authored_slots, slots,
        "{name}: full authored catalog retained"
    );
    if let Some(expected) = family {
        assert_eq!(
            selected_family, expected,
            "{name}: existing structural family"
        );
    }
    for (input, expected, values) in observations {
        for (route, actual) in values.into_iter().enumerate() {
            assert_eq!(
                actual.as_ref().expect("execute structural AND"),
                expected,
                "{name}, {input:?}, route{route}"
            );
        }
    }
}

const SINGLE: &str = "Value:AND\n /H/\n /cat/\n -> Value[1] {return(\"BODY\")}\n";

#[test]
fn direct_sparse_prefix_is_required() {
    check(
        "direct",
        &SINGLE.replacen("Value:AND", "Value::AND", 1),
        2,
        Some("and_acode_seq"),
        &[
            ("Hcat", json!("BODY")),
            ("cat", Value::Null),
            ("Hbad", Value::Null),
        ],
    );
}
#[test]
fn three_slots_surround_one_action() {
    check(
        "three",
        "Value::AND\n /H/\n /_/\n /cat/ -> Value[2] {return([match_text(),cursor_pos()])}\n",
        3,
        Some("and_acode_seq"),
        &[("H_cat", json!(["cat", 5])), ("cat", Value::Null)],
    );
}
#[test]
fn incoming_entry_keeps_the_complete_child_sequence() {
    check(
        "incoming",
        &format!("Top::\n -> Value .push\n LX {{return([copy(Top),cursor_pos()])}}\n{SINGLE}"),
        2,
        Some("and_acode_seq"),
        &[
            ("HHcat", json!([["BODY"], 5])),
            ("Hcat", json!([[null], 1])),
        ],
    );
}
#[test]
fn indexed_incoming_entry_keeps_child_slot_zero() {
    check(
        "indexed",
        &format!("Top::\n -> Value[1] .push\n LX {{return([copy(Top),cursor_pos()])}}\n{SINGLE}"),
        2,
        Some("and_acode_seq"),
        &[("catHcat", json!([["BODY"], 7]))],
    );
}

#[test]
fn indexed_and_preserves_distinct_entry_and_local_captures() {
    check_indexed_captures("indexed_capture_and", "AND", "and_acode_seq");
}

#[test]
fn indexed_compact_and_preserves_distinct_entry_and_local_captures() {
    check_indexed_captures("indexed_capture_compact", "&", "and_single_acode");
}

fn check_indexed_captures(name: &str, mode: &str, family: &str) {
    check(
        name,
        &format!(
            "Top::\n -> Value[1] .push\n LX {{return([copy(Top),cursor_pos()])}}\nValue:{mode}\n /H/\n /(cat)/\n -> Value[0] {{seen=match_text()}}\n -> Value[1] {{return([entry_text(),seen,match_text(),cursor_pos()])}}\n"
        ),
        2,
        Some(family),
        &[("catHcat", json!([[["cat", "H", "cat", 7]], 7]))],
    );
}

#[test]
fn indexed_choice_keeps_the_selected_entry_first() {
    for (name, mode, family, expected) in [
        ("indexed_default", "", "default", json!("CAT")),
        ("indexed_pipe", "|", "or_acode", json!("CAT")),
        ("indexed_or_once", "OR{1}", "rep_acode", json!(["CAT"])),
    ] {
        check(
            name,
            &format!(
                "Top::\n -> Value[1] .push\n LX {{return([copy(Top),cursor_pos()])}}\nValue:{mode}\n /H/\n /cat/\n -> Value[0] {{return(\"H\")}}\n -> Value[1] {{return(\"CAT\")}}\n"
            ),
            2,
            Some(family),
            &[("catHcat", json!([[expected], 7]))],
        );
    }
}
#[test]
#[ignore = "P1 TYPE-REFERENCE-BOOK.1.2.23.3.39.1.4; retained actual RED, required before admission"]
fn blind_entry_without_tail_collects_the_child_value() {
    check(
        "blind",
        &format!("Top::\n => Value\n{SINGLE}"),
        2,
        Some("and_acode_seq"),
        &[("Hcat", json!(["BODY"]))],
    );
}
#[test]
fn explicit_and_blind_entry_collects_the_child_value() {
    check(
        "blind_and",
        &format!("Top::AND\n => Value\n{SINGLE}"),
        2,
        Some("and_acode_seq"),
        &[("Hcat", json!(["BODY"]))],
    );
}
#[test]
fn default_blind_parent_plan_preserves_iteration_cursor() {
    check(
        "blind_cursor",
        &format!("Top::\n => Value\n E {{return(cursor_pos())}}\n{SINGLE}"),
        2,
        Some("and_acode_seq"),
        &[("HcatHcat", json!(8))],
    );
}
#[test]
fn incoming_falsey_values_preserve_their_kinds() {
    for (expression, expected) in [("0", json!(0)), ("\"\"", json!("")), ("undef", Value::Null)] {
        let source = format!(
            "Top::\n -> Value .push\n LX {{return([copy(Top),cursor_pos()])}}\n{}",
            SINGLE.replace("\"BODY\"", expression)
        );
        check(
            expression,
            &source,
            2,
            Some("and_acode_seq"),
            &[("HHcat", json!([[expected], 5]))],
        );
    }
}
#[test]
fn nonreturning_action_and_edgeless_tail_preserve_effects() {
    check(
        "effects",
        r#"Value::AND
 I {seen=[]}
 /H/
 /cat/
 /!/
 -> Value[1] {push(seen,match_text())}
 LE {if(eq(cursor_pos(),5)) {return([copy(seen),cursor_pos()])}}
"#,
        3,
        Some("and_acode_seq"),
        &[("Hcat!", json!([["cat"], 5]))],
    );
}
#[test]
fn cross_target_dependencies_do_not_become_local_structural_slots() {
    check(
        "cross",
        "Value::AND\n /H/\n /cat/\n -> Part[1] {return(match_text())}\nPart:\n /unused/\n /cat/\n",
        2,
        None,
        &[("cat", json!("cat")), ("Hcat", Value::Null)],
    );
}
#[test]
fn reordered_dependencies_keep_authored_order() {
    dependency_case(1, "ba", "b");
}
#[test]
fn duplicate_dependency_index_remains_two_steps() {
    dependency_case(0, "aa", "a");
}
#[test]
fn two_dependencies_on_one_authored_slot_are_two_matches() {
    check(
        "one_slot_two_steps",
        "Value::AND\n I {seen=[]}\n /a/\n -> Value[0] {push(seen,match_text())}\n -> Value[0] {return([copy(seen),match_text(),cursor_pos()])}\n",
        1,
        Some("and_acode_seq"),
        &[("aa", json!([["a"], "a", 2]))],
    );
}
#[test]
fn compact_and_keeps_the_native_ordered_algorithm() {
    check(
        "compact_and",
        "Value::&\n I {seen=[]}\n /a/ -> Value[0] {push(seen,match_text())}\n /b/ -> Value[1] {return([copy(seen),match_text(),cursor_pos()])}\n",
        2,
        Some("and_single_acode"),
        &[("ab", json!([["a"], "b", 2]))],
    );
}
#[test]
fn parent_owned_pattern_keeps_its_existing_role() {
    check(
        "parent_pattern",
        "Value::AND\n /a/ -> Part {return(match_text())}\nPart:\n /b/\n",
        1,
        Some("and_single_acode"),
        &[("a", json!("a"))],
    );
}
#[test]
fn legacy_omitted_slot_metadata_keeps_sparse_structure() {
    let source = SINGLE.replacen("Value:AND", "Value::AND", 1);
    let parsed = parse_spec_with_user_functions(&source).unwrap();
    validate(&parsed).unwrap();
    let mut wire = serde_json::to_value(compile(&parsed).unwrap()).unwrap();
    for rule in wire["rules"].as_array_mut().unwrap() {
        rule.as_object_mut().unwrap().remove("regex_slots");
    }
    let serialized = serde_json::to_string(&wire).unwrap();
    let compiled: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan = [GeneratedPlanRow {
        label: "Value",
        family: "and_acode_seq",
    }];
    let emitted = emit_rust_source_v2(&compiled, "legacy-and-slots.spec").unwrap();
    eprintln!(
        "RUST_AND_LEGACY_INPUT {}",
        json!({"source":source,"serialized":serialized,"emitted":emitted})
    );
    let mut results = Vec::new();
    for (input, expected) in [("Hcat", json!("BODY")), ("cat", Value::Null)] {
        let values = [
            Engine::new(compiled.clone()).execute_value(input, &ExecutionOptions::new()),
            Engine::new(serde_json::from_str(&serialized).unwrap())
                .execute_value(input, &ExecutionOptions::new()),
            execute_generated_parser_v2(
                &serialized,
                &plan,
                input,
                "legacy-and-slots.spec",
                GENERATED_SOURCE_CONTRACT,
            )
            .map_err(|error| error.to_string()),
        ];
        eprintln!(
            "RUST_AND_LEGACY_ACTUAL {}",
            json!({"input":input,"routes":values})
        );
        results.push((expected, values));
    }
    for (expected, values) in results {
        for value in values {
            assert_eq!(value.unwrap(), expected);
        }
    }
}
fn dependency_case(first: usize, input: &str, captured: &str) {
    let source = format!(
        "Value::AND\n I {{seen=[]}}\n /a/\n /b/\n -> Value[{first}] {{push(seen,match_text())}}\n -> Value[0] {{return([copy(seen),match_text(),cursor_pos()])}}\n"
    );
    check(
        input,
        &source,
        2,
        Some("and_acode_seq"),
        &[(input, json!([[captured], "a", 2]))],
    );
}
#[test]
#[ignore = "P1 TYPE-REFERENCE-BOOK.1.2.23.3.39.1.3; retained actual RED, required before admission"]
fn repeated_sparse_groups_keep_minimum_and_reset() {
    check(
        "repeat",
        &SINGLE.replacen("Value:AND", "Value::AND{2}", 1),
        2,
        Some("rep_and_acode"),
        &[("HcatHcat", json!(["BODY", "BODY"]))],
    );
}
#[test]
fn nonreturning_repeated_groups_keep_minimum_and_reset() {
    check(
        "repeat_nonreturn",
        NONRETURN_REPEAT,
        2,
        Some("rep_and_acode"),
        &[("HcatHcat", json!([["cat"], ["cat"]]))],
    );
}
#[test]
fn one_regex_retains_its_single_variant() {
    check(
        "single",
        "Value::AND\n /cat/ -> Value {return(\"BODY\")}\n",
        1,
        Some("and_single_acode"),
        &[("cat", json!("BODY"))],
    );
}
#[test]
fn early_action_return_still_unwinds_before_tail() {
    check(
        "early",
        "Value::AND\n /H/\n /cat/\n -> Value[0] {return(\"EARLY\")}\n",
        2,
        Some("and_acode_seq"),
        &[("H", json!("EARLY"))],
    );
}

const NONRETURN_REPEAT: &str = r#"Value::AND{2}
 I {pairs=[];pair=[]}
 /H/
 /cat/
 -> Value[1] {push(pair,match_text())}
 IT {push(pairs,copy(pair));pair=[]}
 E {return(copy(pairs))}
"#;

#[test]
#[ignore = "P1 TYPE-REFERENCE-BOOK.1.2.23.3.39.1.5; ordinary minimum miss Err/null reconciliation"]
fn explicit_return_below_minimum_is_an_ordinary_miss() {
    check(
        "repeat_under_min",
        &SINGLE.replacen("Value:AND", "Value::AND{2}", 1),
        2,
        Some("rep_and_acode"),
        &[("Hcat", Value::Null)],
    );
}
#[test]
#[ignore = "P1 TYPE-REFERENCE-BOOK.1.2.23.3.39.1.5; ordinary minimum miss Err/null reconciliation"]
fn nonreturning_group_below_minimum_is_an_ordinary_miss() {
    check(
        "repeat_nonreturn_under_min",
        NONRETURN_REPEAT,
        2,
        Some("rep_and_acode"),
        &[("Hcat", Value::Null)],
    );
}
