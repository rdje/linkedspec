//! TYPE-REFERENCE-BOOK.1.2.23.3.57.2 — existing gap Strings as guarded sources.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse gap String results");
    validate(&parsed).expect("validate gap String results");
    let compiled = compile(&parsed).expect("compile gap String results");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Top" => "Top",
                "List" => "List",
                "Item" => "Item",
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
            "gap-string-result.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}

fn check(label: &str, source: &str, input: &str, expected: Value) {
    let actual = routes(source, input);
    eprintln!(
        "GAP_STRING_RESULT {label} {}",
        serde_json::to_string(&actual).unwrap()
    );
    for (route, value) in actual.into_iter().enumerate() {
        assert_eq!(
            value.expect("execute gap String result"),
            expected,
            "{label} route{route}"
        );
    }
}
fn carrier(action: &str, definitions: &str, pattern: &str) -> String {
    format!(
        "{definitions}\nList::\n @capture_gaps\n I {{rows=[];order=\"\"}}\n -> Item[word] {{{action}}}\n LX {{return([rows,gap_text(),gap_kind(),order,cursor_pos()])}}\nItem:\n word=/{pattern}/\n I {{return(entry_text())}}\n"
    )
}
fn basic(action: &str) -> String {
    carrier(action, "", "[^,;]+")
}
#[test]
fn frozen_guarded_gap_string_target() {
    check(
        "shared",
        include_str!("../../../tests/fixtures/gap_string_result_values.spec"),
        "a,b;",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/gap_string_result_values.json"
        ))
        .unwrap(),
    );
}
#[test]
fn primitives_and_bound_direct_compatible_string_methods_stay_healthy() {
    check(
        "primitive",
        &basic("push(rows,[gap_text(),gap_kind(),call(Item)])"),
        "a,b;",
        json!([
            [["", "prefix", "a"], [",", "interstitial", "b"]],
            ";",
            "tail",
            "",
            3
        ]),
    );
    check(
        "compatible",
        &basic(
            r#"text=gap_text();kind=gap_kind();push(rows,[text.coalesce("F").cat("!"),gap_text().coalesce("F").cat("!"),kind.uppercase(),gap_kind().uppercase(),call(Item)])"#,
        ),
        "a,b;",
        json!([
            [
                ["!", "!", "PREFIX", "PREFIX", "a"],
                [",!", ",!", "INTERSTITIAL", "INTERSTITIAL", "b"]
            ],
            ";",
            "tail",
            "",
            3
        ]),
    );
}
#[test]
fn incompatible_consumers_return_null_and_skip_operands() {
    check(
        "guards",
        &basic(
            r#"a=gap_text().take({order=cat(order,"A");1});b=gap_kind().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});push(rows,[a,b,call(Item)])"#,
        ),
        "a,b;",
        json!([[[null, null, "a"], [null, null, "b"]], ";", "tail", "", 3]),
    );
}
#[test]
fn both_noncontainer_reads_recover_array_bool_number_and_string() {
    check(
        "recovery",
        &basic(
            r#"push(rows,[gap_text()[0].coalesce(["a","tail"])[-1].uppercase(),gap_kind()["missing"].coalesce(false),gap_kind()[0].coalesce(0).add(1),gap_text()[0].coalesce("").cat("!"),call(Item)])"#,
        ),
        "a,b;",
        json!([
            [["TAIL", false, 1, "!", "a"], ["TAIL", false, 1, "!", "b"]],
            ";",
            "tail",
            "",
            3
        ]),
    );
}
#[test]
fn with_returns_actual_container_and_bool_kinds_and_restores_outer_value() {
    check(
        "with_kinds",
        &basic(
            r#"value="outer";a=gap_text().with(){return([value,"tail"])}[-1].uppercase();b=gap_kind().with(){return({"k":[false]})}["k"][-1];push(rows,[a,b,value,call(Item)])"#,
        ),
        "a,b;",
        json!([
            [["TAIL", false, "outer", "a"], ["TAIL", false, "outer", "b"]],
            ";",
            "tail",
            "",
            3
        ]),
    );
}
#[test]
fn unicode_gap_strings_retain_character_length() {
    check(
        "unicode",
        &carrier(
            r#"push(rows,[gap_text().length(),gap_text().cat("!"),call(Item)])"#,
            "",
            "[ab]",
        ),
        "a🙂b;",
        json!([[[0, "!", "a"], [1, "🙂!", "b"]], ";", "tail", "", 3]),
    );
}
#[test]
fn unavailable_context_errors_precede_defaults() {
    for helper in ["gap_text", "gap_kind"] {
        let primitive = format!("Top:: I {{return({helper}())}}");
        let selected = format!("Top:: I {{return({helper}().coalesce(\"M\"))}}");
        let rows = [routes(&primitive, "x"), routes(&selected, "x")];
        eprintln!(
            "GAP_STRING_CONTEXT {helper} {}",
            serde_json::to_string(&rows).unwrap()
        );
        for actual in rows {
            for row in actual {
                assert!(
                    row.expect_err("gap source failure precedes default")
                        .contains("gap_capture_context_unavailable")
                );
            }
        }
        let native_error = |source: &str| {
            let parsed = parse_spec_with_user_functions(source).unwrap();
            validate(&parsed).unwrap();
            Engine::new(compile(&parsed).unwrap())
                .execute_value_with_diagnostics("x", &ExecutionOptions::new())
                .expect_err("typed source failure")
        };
        let before = native_error(&primitive);
        let after = native_error(&selected);
        assert_eq!(
            after.diagnostic.code.as_deref(),
            Some("gap_capture_context_unavailable")
        );
        assert_eq!(before.message, after.message);
        assert_eq!(before.diagnostic, after.diagnostic);
    }
}
#[test]
fn pure_function_primitive_and_computed_reads_remain_forbidden() {
    for helper in ["gap_text", "gap_kind"] {
        for suffix in ["", "[0]"] {
            let definition = format!("fn denied(){{return({helper}(){suffix}.coalesce(\"M\"))}}");
            let source = carrier("push(rows,[denied(),call(Item)])", &definition, "[^,;]+");
            let actual = routes(&source, "a,b;");
            eprintln!(
                "GAP_STRING_FUNCTION {helper}{suffix} {}",
                serde_json::to_string(&actual).unwrap()
            );
            for row in actual {
                let error = row.expect_err("pure function cannot read parser state");
                assert!(
                    error.contains("parser-state helper") && error.contains(helper),
                    "{error}"
                );
            }
        }
    }
    check(
        "explicit_args",
        &carrier(
            "push(rows,[selected(gap_text(),gap_kind()),call(Item)])",
            r#"fn selected(text,kind){return([text.cat("!"),kind.uppercase()])}"#,
            "[^,;]+",
        ),
        "a,b;",
        json!([
            [[["!", "PREFIX"], "a"], [[",!", "INTERSTITIAL"], "b"]],
            ";",
            "tail",
            "",
            3
        ]),
    );
}
#[test]
fn malformed_call_counts_keep_existing_typed_arity_errors() {
    for helper in ["gap_text", "gap_kind"] {
        for argument in ["1", "extra:1"] {
            let source = format!("Top:: I {{return({helper}({argument})[0].coalesce(\"M\"))}}");
            let actual = routes(&source, "x");
            eprintln!(
                "GAP_STRING_ARITY {helper} {argument} {}",
                serde_json::to_string(&actual).unwrap()
            );
            for row in actual {
                let error = row.expect_err("invalid call cannot gain zero-argument source role");
                assert!(
                    error.contains("helper_arity_mismatch")
                        && error.contains(helper)
                        && error.contains("actual_arity=1"),
                    "{error}"
                );
            }
        }
    }
}
