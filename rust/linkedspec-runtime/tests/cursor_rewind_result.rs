//! TYPE-REFERENCE-BOOK.1.2.23.3.56.2 — current cursor rewind result composition.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse cursor rewind results");
    validate(&parsed).expect("validate cursor rewind results");
    let compiled = compile(&parsed).expect("compile cursor rewind results");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Top" => "Top",
                "Value" => "Value",
                "Advance" => "Advance",
                other => panic!("unexpected fixture label {other}"),
            },
            family: classify_generated_rule_family(rule).contract_name(),
        })
        .collect();
    vec![
        Engine::new(compiled)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|e| e.to_string()),
        Engine::new(restored)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|e| e.to_string()),
        execute_generated_parser_v2(
            &serialized,
            &plan,
            input,
            "cursor-rewind-result.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}

fn check(label: &str, source: &str, input: &str, expected: Value) {
    let actual = routes(source, input);
    eprintln!(
        "CURSOR_REWIND {label} {}",
        serde_json::to_string(&actual).unwrap()
    );
    for (route, value) in actual.into_iter().enumerate() {
        assert_eq!(
            value.expect("execute cursor rewind result"),
            expected,
            "{label} route{route}"
        );
    }
}
fn carrier(body: &str, definitions: &str) -> String {
    format!(
        "{definitions}\nTop::\n -> Value[entry] {{return(call(Value))}}\nValue:\n entry=/ab/\n colon=/:/\n -> Value[colon] {{{body}}}\n"
    )
}
#[test]
fn frozen_qualified_rewind_result_target() {
    check(
        "shared",
        include_str!("../../../tests/fixtures/cursor_rewind_result_values.spec"),
        "zzab:cd",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/cursor_rewind_result_values.json"
        ))
        .unwrap(),
    );
}
fn primitive_body() -> &'static str {
    "save_cursor();p0=cursor_pos();v0=rewind_entry_start();p1=cursor_pos();v1=rewind_match_start();p2=cursor_pos();v2=restore_cursor();p3=cursor_pos();return([p0,v0,p1,v1,p2,v2,p3]);"
}
#[test]
fn primitive_numbers_retain_live_entry_and_local_anchors() {
    check(
        "primitive_ascii",
        &carrier(primitive_body(), ""),
        "zzab:cd",
        json!([5, 2, 2, 4, 4, null, 5]),
    );
}
#[test]
fn primitive_numbers_are_character_positions_on_unicode_input() {
    check(
        "primitive_unicode",
        &carrier(primitive_body(), ""),
        "🙂ab:cd",
        json!([4, 1, 1, 3, 3, null, 4]),
    );
}
#[test]
fn bound_and_direct_numeric_text_methods_share_existing_effects() {
    check(
        "numeric",
        &carrier(
            "entry_value=rewind_entry_start();p1=cursor_pos();local_value=rewind_match_start();p2=cursor_pos();return([entry_value.add(1).cat(\"!\"),local_value.add(1),p1,p2,rewind_entry_start().add(1),rewind_match_start().add(1),cursor_pos()]);",
            "",
        ),
        "zzab:cd",
        json!(["3!", 5, 2, 4, 3, 5, 4]),
    );
}
#[test]
fn defined_zero_and_incompatible_consumers_skip_operands() {
    check(
        "zero_and_guards",
        &carrier(
            "order=\"\";a=rewind_entry_start().coalesce({order=cat(order,\"F\");99}).add(1);b=rewind_entry_start().take({order=cat(order,\"A\");1});c=rewind_match_start().set_key({order=cat(order,\"K\");\"k\"},{order=cat(order,\"V\");7});return([a,b,c,order,cursor_pos()]);",
            "",
        ),
        "ab:cd",
        json!([1, null, null, "", 2]),
    );
}
#[test]
fn pure_function_state_fence_and_explicit_numbers_remain_distinct() {
    for helper in ["rewind_entry_start", "rewind_match_start"] {
        let source = carrier(
            "return(forbidden())",
            &format!("fn forbidden(){{return({helper}().coalesce(99).add(1))}}"),
        );
        let actual = routes(&source, "zzab:cd");
        eprintln!(
            "CURSOR_REWIND_FENCE {helper} {}",
            serde_json::to_string(&actual).unwrap()
        );
        for value in actual {
            let error = value.expect_err("function must not read cursor state");
            assert!(
                error.contains("parser-state helper") && error.contains(helper),
                "{error}"
            );
        }
    }
    check(
        "explicit_number",
        &carrier("return(inc(2))", "fn inc(value){return(value.add(1))}"),
        "zzab:cd",
        json!(3),
    );
}
#[test]
fn physical_rewinds_and_null_save_restore_stay_healthy() {
    check(
        "physical",
        &carrier(
            "saved=save_cursor();rewind_entry_start();p1=cursor_pos();rewind_match_start();p2=cursor_pos();restored=restore_cursor();return([saved,p1,p2,restored,cursor_pos()]);",
            "",
        ),
        "zzab:cd",
        json!([null, 2, 4, null, 5]),
    );
}
#[test]
fn existing_with_and_missing_read_array_bridges_stay_healthy() {
    check(
        "bridges",
        &carrier(
            "return([rewind_entry_start().with(){return([value,\"tail\"])}[-1].uppercase(),rewind_match_start()[0].coalesce([\"a\",\"tail\"])[-1].uppercase(),cursor_pos()]);",
            "",
        ),
        "zzab:cd",
        json!(["TAIL", "TAIL", 4]),
    );
}
#[test]
fn legacy_extra_argument_forms_do_not_gain_zero_argument_number_results() {
    // Preserve observed legacy malformed forms; this is no arity/error-phase admission.
    for (helper, position) in [("rewind_entry_start", 2), ("rewind_match_start", 4)] {
        for argument in ["1", "extra:1"] {
            check(
                &format!("legacy_{helper}_{argument}"),
                &carrier(&format!("return([{helper}({argument}),cursor_pos()])"), ""),
                "zzab:cd",
                json!([null, position]),
            );
        }
    }
}
