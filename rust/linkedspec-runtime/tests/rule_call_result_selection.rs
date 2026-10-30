//! TYPE-REFERENCE-BOOK.1.2.23.3.54.2 — static child-return typed reads.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse rule-call selections");
    validate(&parsed).expect("validate rule-call selections");
    let compiled = compile(&parsed).expect("compile rule-call selections");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Top" => "Top",
                "Child" => "Child",
                "HashChild" => "HashChild",
                "End" => "End",
                "Text" => "Text",
                "Nothing" => "Nothing",
                "Empty" => "Empty",
                "Object" => "Object",
                "Wrong" => "Wrong",
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
            "rule-call-selection.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}
fn check(source: &str, input: &str, expected: Value) {
    for (route, value) in routes(source, input).into_iter().enumerate() {
        eprintln!("RULE_CALL_SELECTION route{route} {value:?}");
        assert_eq!(
            value.expect("execute rule-call selections"),
            expected,
            "route{route}"
        );
    }
}
#[test]
fn frozen_rule_call_result_selection_target() {
    check(
        include_str!("../../../tests/fixtures/rule_call_selection_values.spec"),
        "αβ:ENDTAIL",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/rule_call_selection_values.json"
        ))
        .unwrap(),
    );
}

#[test]
fn selected_child_values_preserve_each_ordinary_kind() {
    check(
        r#"
Top:: I {return([call(Child)[0],call(Child)[1],call(Child)[2],call(Child)[3],call(Child)[4],call(Child)[5]])}
Child: I {return([false,0,"0",undef,["a"],hash("name","b")])}
"#,
        "x",
        json!([false,0,"0",null,["a"],{"name":"b"}]),
    );
}

#[test]
fn scalar_null_empty_missing_child_results_keep_typed_null_reads() {
    check(
        r#"
Top:: I {return([call(Text)[-1].coalesce("M"),call(Nothing)[0].coalesce("N"),call(Empty)[-1].coalesce("E"),call(Object)["missing"].coalesce("K")])}
Text: I {return("red:tail")}
Nothing: I {return(undef)}
Empty: I {return([])}
Object: I {return(hash())}
"#,
        "x",
        json!(["M", "N", "E", "K"]),
    );
}

#[test]
fn existing_bound_and_method_call_results_stay_healthy() {
    check(
        r#"
Top:: I {part=call(Child);return([part[-1].uppercase(),call(Child).last().uppercase()])}
Child: I {return(["red","tail"])}
"#,
        "x",
        json!(["TAIL", "TAIL"]),
    );
}

#[test]
fn bare_child_rule_label_keeps_static_lookup_and_signed_selection() {
    check(
        r#"
Top:: I {Child="Wrong";return(call(Child)[-1].uppercase())}
Child: I {return(["red","tail"])}
Wrong: I {return(["wrong"])}
"#,
        "x",
        json!("TAIL"),
    );
}

#[test]
fn pure_function_call_fence_and_explicit_value_arguments_are_preserved() {
    let program = r#"
fn forbidden(){return(call(Child)[-1].uppercase())}
Top:: I {return(forbidden())}
Child: I {return(["tail"])}
"#;
    for (route, result) in routes(program, "x").into_iter().enumerate() {
        let error = result.expect_err("pure function must reject child parser call");
        eprintln!("RULE_CALL_SELECTION_FENCE route{route} {error}");
        assert!(
            error.contains("user function 'forbidden'")
                && error.contains("parser-state helper")
                && error.contains("'call'"),
            "{error}"
        );
    }
    check(
        r#"
fn upper(text){return(text.uppercase())}
Top:: I {return(upper(call(Child)[-1]))}
Child: I {return(["red","tail"])}
"#,
        "x",
        json!("TAIL"),
    );
}
