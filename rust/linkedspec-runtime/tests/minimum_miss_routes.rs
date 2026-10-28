//! TYPE-REFERENCE-BOOK.1.2.23.3.39.1.5 — ordinary minimum misses stay distinct
//! from accepted null results and genuine execution errors.
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    emit_rust_source_v2, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

enum Expected {
    Value(Value),
    ErrorContaining(&'static str),
}

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).unwrap();
    validate(&parsed).unwrap();
    compile(&parsed).unwrap()
}

fn check(name: &str, source: &str, cases: &[(&str, Expected)]) {
    let compiled = compile_source(source);
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
                "Guard" => "Guard",
                label => panic!("unowned minimum-test label {label}"),
            },
            family: classify_generated_rule_family(rule).contract_name(),
        })
        .collect();
    let emitted = emit_rust_source_v2(&compiled, "minimum-miss.spec").unwrap();
    eprintln!(
        "RUST_MINIMUM_INPUT {name} {}",
        json!({"source":source,"serialized":serialized,"emitted":emitted,"plan":plan})
    );
    let native = Engine::new(compiled);
    let loaded = Engine::new(restored);
    let observations: Vec<_> = cases
        .iter()
        .map(|(input, expected)| {
            let routes = [
                if std::env::var_os("LINKEDSPEC_MINIMUM_TRACE").is_some() {
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
                    "minimum-miss.spec",
                    GENERATED_SOURCE_CONTRACT,
                )
                .map_err(|error| error.to_string()),
            ];
            let target = match expected {
                Expected::Value(value) => json!({"Ok":value}),
                Expected::ErrorContaining(code) => json!({"ErrContaining":code}),
            };
            eprintln!(
                "RUST_MINIMUM_ACTUAL {name} {}",
                json!({"input":input,"expected":target,"routes":routes})
            );
            (input, expected, routes)
        })
        .collect();
    for (input, expected, routes) in observations {
        for (route, actual) in routes.into_iter().enumerate() {
            match expected {
                Expected::Value(value) => assert_eq!(
                    actual.as_ref().expect("ordinary result"),
                    value,
                    "{name} {input:?} route{route}"
                ),
                Expected::ErrorContaining(code) => assert!(
                    actual
                        .expect_err("real error must propagate")
                        .contains(code),
                    "{name} {input:?} route{route}"
                ),
            }
        }
    }
}

const CHILD: &str = "Part:AND\n /H/\n /cat/ -> Part[1] {return(\"BODY\")}\n";
fn check_mode(name: &str, mode: &str, minimum: usize, max_one: bool) {
    let source = format!(
        "Value::{mode}\n => Part\n EX {{return([\"EXIT\",cursor_pos()])}}\n E {{return([\"EXIT\",cursor_pos()])}}\n{CHILD}"
    );
    check(
        name,
        &source,
        &[
            (
                "HcatHcat",
                Expected::Value(json!(["EXIT", if max_one { 4 } else { 8 }])),
            ),
            (
                "Hcat",
                Expected::Value(if minimum > 1 {
                    Value::Null
                } else {
                    json!(["EXIT", 4])
                }),
            ),
            (
                "bad",
                Expected::Value(if minimum > 0 {
                    Value::Null
                } else {
                    json!(["EXIT", 0])
                }),
            ),
            (
                "",
                Expected::Value(if minimum > 0 {
                    Value::Null
                } else {
                    json!(["EXIT", 0])
                }),
            ),
        ],
    );
}
#[test]
#[ignore = "P1 TYPE-REFERENCE-BOOK.1.2.23.3.39.1.5.1; retained actual RED, required before admission"]
fn repeated_blind_choice_minimum_is_an_ordinary_miss() {
    check_mode("or_two", "OR{2}", 2, false);
}
#[test]
#[ignore = "P1 TYPE-REFERENCE-BOOK.1.2.23.3.39.1.5.1; retained actual RED, required before admission"]
fn repeated_blind_sequence_minimum_is_an_ordinary_miss() {
    check_mode("and_two", "AND{2}", 2, false);
}
#[test]
#[ignore = "P1 TYPE-REFERENCE-BOOK.1.2.23.3.39.1.5.1; retained actual RED, required before admission"]
fn bare_blind_or_keeps_its_minimum_one() {
    check_mode("or_one", "OR", 1, false);
}
#[test]
fn zero_minimum_and_bounded_success_keep_exit_values() {
    check_mode("or_zero", "OR{0,1}", 0, true);
}

#[test]
#[ignore = "P1 TYPE-REFERENCE-BOOK.1.2.23.3.39.1.5.1; retained actual RED, required before admission"]
fn a_caller_can_recover_from_a_child_minimum_miss() {
    check(
        "recovery",
        &format!(
            "Top::OR{{0,1}}\n => Value\n EX {{return([\"RECOVERED\",cursor_pos()])}}\n E {{return([\"RECOVERED\",cursor_pos()])}}\nValue:OR{{2}}\n => Part\n EX {{return(\"CHILD_EXIT\")}}\n E {{return(\"CHILD_EXIT\")}}\n{CHILD}"
        ),
        &[
            ("Hcat", Expected::Value(json!(["RECOVERED", 4]))),
            ("HcatHcat", Expected::Value(json!(["RECOVERED", 8]))),
            ("bad", Expected::Value(json!(["RECOVERED", 0]))),
        ],
    );
}

#[test]
#[ignore = "P1 TYPE-REFERENCE-BOOK.1.2.23.3.39.1.5.1; retained actual RED, required before admission"]
fn a_successful_null_lifecycle_result_remains_a_value() {
    check(
        "null_exit",
        &format!("Value::OR{{2}}\n => Part\n EX {{return(undef)}}\n E {{return(undef)}}\n{CHILD}"),
        &[
            ("HcatHcat", Expected::Value(Value::Null)),
            ("Hcat", Expected::Value(Value::Null)),
        ],
    );
}

const LEGACY_SOURCE: &str = "Top::OR{2,}\n /hello/\n E { return(1) }\n";
#[test]
#[ignore = "P1 TYPE-REFERENCE-BOOK.1.2.23.3.39.1.5.1; retained actual RED, required before admission"]
fn regex_only_minimum_has_the_same_ordinary_miss_boundary() {
    // The reference's full regex-only E result shaping is separately owned by
    // SESSION-STARTUP-READING.27. Preserve existing Rust full-result behavior.
    check(
        "regex_only",
        LEGACY_SOURCE,
        &[
            ("hello world", Expected::Value(Value::Null)),
            ("hello hello", Expected::Value(json!(1))),
        ],
    );
}

#[test]
#[ignore = "P1 TYPE-REFERENCE-BOOK.1.2.23.3.39.1.5.1; retained actual RED, required before admission"]
fn legacy_accumulator_api_does_not_raise_for_a_minimum_miss() {
    let compiled = compile_source(LEGACY_SOURCE);
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored = serde_json::from_str(&serialized).unwrap();
    let routes = [
        Engine::new(compiled).execute("hello world"),
        Engine::new(restored).execute("hello world"),
    ];
    eprintln!(
        "RUST_MINIMUM_LEGACY {}",
        json!({"source":LEGACY_SOURCE,"serialized":serialized,"routes":routes})
    );
    for result in routes {
        assert_eq!(result.unwrap(), json!([]));
    }
}

#[test]
fn a_real_progress_error_is_not_converted_to_a_miss() {
    let source = "Value::OR{2}\n => Part\nPart:\n I {tx=recognition_checkpoint();matched=recognize_once(tx,call(Guard));recognition_rollback(tx);return(matched)}\n /never/\nGuard:+\n /(?=a)/ -> Guard {return(\"zero\")}\n";
    check(
        "progress_error",
        source,
        &[(
            "a",
            Expected::ErrorContaining("recognition_zero_progress_repetition"),
        )],
    );
}
