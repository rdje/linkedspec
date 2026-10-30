//! TYPE-REFERENCE-BOOK.1.2.23.3.56.2.0 — cursor signatures before operands/state.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
const HELPERS: [&str; 4] = [
    "save_cursor",
    "restore_cursor",
    "rewind_entry_start",
    "rewind_match_start",
];
fn carrier(body: &str, definitions: &str) -> String {
    format!(
        "{definitions}\nTop::\n -> Value[entry] {{return(call(Value))}}\nValue:\n entry=/ab/\n colon=/:/\n -> Value[colon] {{{body}}}\n"
    )
}
fn observe(source: &str, input: &str) -> Value {
    let parsed = match parse_spec_with_user_functions(source) {
        Ok(value) => value,
        Err(error) => {
            return json!({"compile_error":{"stage":"parse","error":format!("{error:?}")}});
        }
    };
    if let Err(error) = validate(&parsed) {
        return json!({"compile_error":{"stage":"validate","error":format!("{error:?}")}});
    }
    let compiled = match compile(&parsed) {
        Ok(value) => value,
        Err(error) => {
            return json!({"compile_error":{"stage":"compile","error":format!("{error:?}")}});
        }
    };
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Top" => "Top",
                "Value" => "Value",
                other => panic!("unexpected label {other}"),
            },
            family: classify_generated_rule_family(rule).contract_name(),
        })
        .collect();
    let native = |spec| match Engine::new(spec)
        .execute_value_with_diagnostics(input, &ExecutionOptions::new())
    {
        Ok(value) => json!({"ok":value}),
        Err(error) => json!({"error":error.message(),"diagnostic":error.diagnostic()}),
    };
    let native_value = native(compiled);
    let restored_value = native(restored);
    let generated = match execute_generated_parser_v2(
        &serialized,
        &plan,
        input,
        "cursor-control-arity.spec",
        GENERATED_SOURCE_CONTRACT,
    ) {
        Ok(value) => json!({"ok":value}),
        Err(error) => json!({"error":error.to_string()}),
    };
    json!({"native":native_value,"restored":restored_value,"plan":generated})
}
fn arity_error(actual: &Value, helper: &str, count: usize) {
    assert!(
        actual.get("compile_error").is_none(),
        "runtime arity phase: {actual}"
    );
    for route in ["native", "restored", "plan"] {
        let row = &actual[route];
        let message = row["error"].as_str().expect("typed arity error");
        assert!(
            message.contains("helper_arity_mismatch")
                && message.contains(&format!("helper_name={helper}"))
                && message.contains(&format!("actual_arity={count}")),
            "{route} {message}"
        );
        if route != "plan" {
            let diagnostic = &row["diagnostic"];
            assert_eq!(diagnostic["code"], "helper_arity_mismatch");
            assert_eq!(diagnostic["stage"], "helper_arity_mismatch");
            assert_eq!(diagnostic["helper_name"], helper);
            assert_eq!(diagnostic["actual_arity"], count);
            assert_eq!(
                diagnostic["expected_arity"],
                "exactly 0 positional arguments"
            );
            assert_eq!(diagnostic["rule_label"], "Value");
        }
    }
}
fn rejected_batch(label: &str, arguments: &[(&str, usize)], selected: bool, definitions: &str) {
    // Collect the complete batch before assertions so RED retains every route/form.
    let rows: Vec<_> = HELPERS
        .iter()
        .flat_map(|helper| {
            arguments
                .iter()
                .map(move |(arg, count)| (*helper, *arg, *count))
        })
        .map(|(helper, arg, count)| {
            let call = if selected {
                format!("{helper}({arg})[0].coalesce(\"M\")")
            } else {
                format!("[{helper}({arg}),cursor_pos()]")
            };
            let source = carrier(&format!("save_cursor();return({call})"), definitions);
            (helper, arg, count, observe(&source, "zzab:cd"))
        })
        .collect();
    eprintln!(
        "CURSOR_ARITY_BATCH {label} {}",
        serde_json::to_string(&rows).unwrap()
    );
    for (helper, _, count, actual) in rows {
        arity_error(&actual, helper, count)
    }
}
#[test]
fn surplus_positional_and_keyword_arguments_reject_before_cursor_writes() {
    rejected_batch("surplus", &[("1", 1), ("extra:1", 1)], false, "");
}
#[test]
fn two_operands_reject_the_authored_count() {
    rejected_batch("two", &[("1,2", 2)], false, "");
}
#[test]
fn rejected_operands_do_not_enter_a_trapping_function() {
    rejected_batch(
        "trap",
        &[("trap()", 1)],
        false,
        "fn trap(){return(entry_text())}",
    );
}
#[test]
fn selected_field_defaults_do_not_mask_source_arity() {
    rejected_batch("selected", &[("1", 1)], true, "");
}
#[test]
fn pure_function_parser_state_priority_remains_first() {
    let rows: Vec<_> = HELPERS
        .iter()
        .flat_map(|helper| ["1", "trap()"].into_iter().map(move |arg| (*helper, arg)))
        .map(|(helper, arg)| {
            let definitions = format!(
                "fn trap(){{return(entry_text())}}\nfn denied(){{return({helper}({arg}))}}"
            );
            (
                helper,
                arg,
                observe(&carrier("return(denied())", &definitions), "zzab:cd"),
            )
        })
        .collect();
    eprintln!(
        "CURSOR_ARITY_FUNCTION {}",
        serde_json::to_string(&rows).unwrap()
    );
    for (helper, _, actual) in rows {
        assert!(actual.get("compile_error").is_none(), "{actual}");
        for route in ["native", "restored", "plan"] {
            let message = actual[route]["error"]
                .as_str()
                .expect("function state fence");
            assert!(
                message.contains("parser-state helper")
                    && message.contains(helper)
                    && !message.contains("helper_arity_mismatch"),
                "{message}"
            );
        }
    }
}
fn positive(label: &str, source: &str, input: &str, expected: Value) {
    let actual = observe(source, input);
    eprintln!("CURSOR_ARITY_POSITIVE {label} {actual}");
    assert!(actual.get("compile_error").is_none(), "{actual}");
    for route in ["native", "restored", "plan"] {
        assert_eq!(actual[route], json!({"ok":expected}), "{label} {route}")
    }
}
#[test]
fn valid_zero_calls_preserve_stack_null_number_and_unicode() {
    let body = "saved=save_cursor();before=cursor_pos();entry=rewind_entry_start();entry_pos=cursor_pos();local_value=rewind_match_start();local_pos=cursor_pos();restored=restore_cursor();return([saved,before,entry,entry_pos,local_value,local_pos,restored,cursor_pos(),\"x\".with(){return(value)}.uppercase()]);";
    positive(
        "valid_ascii",
        &carrier(body, ""),
        "zzab:cd",
        json!([null, 5, 2, 2, 4, 4, null, 5, "X"]),
    );
    positive(
        "valid_unicode",
        &carrier(body, ""),
        "🙂ab:cd",
        json!([null, 4, 1, 1, 3, 3, null, 4, "X"]),
    );
    positive(
        "empty_restore",
        "Top:: I {return([restore_cursor(),cursor_pos(),save_cursor(),restore_cursor(),cursor_pos()])}",
        "x",
        json!([null, 0, null, null, 0]),
    );
}
#[test]
fn trailing_codeblocks_keep_the_existing_rejection_phase() {
    let rows: Vec<_> = HELPERS
        .iter()
        .map(|helper| {
            let source = carrier(&format!("return({helper}(){{return(1)}})"), "");
            (*helper, observe(&source, "zzab:cd"))
        })
        .collect();
    eprintln!(
        "CURSOR_ARITY_TRAILING {}",
        serde_json::to_string(&rows).unwrap()
    );
    for (helper, actual) in rows {
        let compilation = actual
            .get("compile_error")
            .expect("existing static rejection");
        assert_eq!(compilation["stage"], "compile");
        let message = compilation["error"].as_str().unwrap();
        assert!(
            message.contains("callable_contract_rejected")
                && message.contains(helper)
                && message.contains("does not declare a final codeblock parameter"),
            "{message}"
        );
    }
}
#[test]
fn unrelated_function_prefix_and_logical_arity_remain_distinct() {
    positive(
        "function_prefix",
        &carrier(
            "return(rewind_entry_custom(2))",
            "fn rewind_entry_custom(value){return(value.add(1))}",
        ),
        "zzab:cd",
        json!(3),
    );
    let actual = observe(&carrier("return(and())", ""), "zzab:cd");
    eprintln!("CURSOR_ARITY_LOGICAL {actual}");
    for route in ["native", "restored", "plan"] {
        let message = actual[route]["error"]
            .as_str()
            .expect("existing logical arity");
        assert!(
            message.contains("helper_arity_mismatch")
                && message.contains("helper_name=and")
                && message.contains("at least 1 positional argument"),
            "{message}"
        );
    }
}
