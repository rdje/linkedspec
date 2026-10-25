//! SESSION-STARTUP-READING.55.1 — value transport and checked host indices.
use linkedspec_core::ast::SpecFile;
use linkedspec_core::compiler::compile;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use linkedspec_runtime::staged_parser_registry::execute_parse_jobs;
use serde_json::{Value, json};

const PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
    label: "Top",
    family: "default",
}];

fn cases() -> Vec<Value> {
    let fixture: Value = serde_json::from_str(include_str!(
        "../../../tests/numeric-conversion/programs.json"
    ))
    .unwrap();
    let mut selected: Vec<Value> = fixture["cases"]
        .as_array()
        .unwrap()
        .iter()
        .filter(|case| {
            case["pointer_width"]
                .as_u64()
                .is_none_or(|width| width == u64::from(usize::BITS))
        })
        .cloned()
        .collect();
    let functions: Value = serde_json::from_str(include_str!(
        "../../../tests/numeric-conversion/functions.json"
    ))
    .unwrap();
    selected.extend(functions["cases"].as_array().unwrap().iter().cloned());
    selected
}

fn matches_value(actual: &Value, target: &Value) -> bool {
    if let Some(bits) = target["binary64"].as_str() {
        let bits = u64::from_str_radix(bits, 16).unwrap();
        return match target["json_kind"].as_str().unwrap() {
            "signed_integer" | "unsigned_integer" => {
                !actual.is_f64() && actual.to_string() == target["integer"].as_str().unwrap()
            }
            "finite_float" | "negative_zero" => {
                actual.is_f64() && actual.as_f64().map(f64::to_bits) == Some(bits)
            }
            _ => panic!("finite authored program target"),
        };
    }
    if let Some(expected) = target.get("exact") {
        return actual == expected;
    }
    if let Some(items) = target["array"].as_array() {
        return actual.as_array().is_some_and(|values| {
            values.len() == items.len()
                && values
                    .iter()
                    .zip(items)
                    .all(|(value, target)| matches_value(value, target))
        });
    }
    if let Some(entries) = target["object"].as_object() {
        return actual.as_object().is_some_and(|values| {
            values.len() == entries.len()
                && entries.iter().all(|(key, target)| {
                    values
                        .get(key)
                        .is_some_and(|value| matches_value(value, target))
                })
        });
    }
    panic!("unknown authored value target")
}

fn observe(case: &Value, route: &str, result: Result<Value, String>, failures: &mut Vec<String>) {
    let matches = match (&result, case["expected"].get("ok")) {
        (Ok(value), Some(target)) => matches_value(value, target),
        (Err(error), None) => serde_json::from_str::<Value>(error).is_ok_and(|value| {
            case["expected"]["error"]
                .as_object()
                .unwrap()
                .iter()
                .all(|(field, expected)| value.get(field) == Some(expected))
        }),
        _ => false,
    };
    println!(
        "NUMERIC_RUNTIME\t{}",
        json!({"id":case["id"],"route":route,
        "ok":result.as_ref().ok(),"raw_error":result.as_ref().err(),"matches":matches})
    );
    if !matches {
        failures.push(format!("{}:{route}", case["id"]));
    }
}

#[test]
fn numeric_values_cross_native_json_and_generated_routes() {
    let mut failures = Vec::new();
    for case in cases() {
        let parsed = parse_spec_with_user_functions(case["source"].as_str().unwrap())
            .unwrap_or_else(|error| panic!("{} source: {error}", case["id"]));
        validate(&parsed).unwrap();
        let spec_json = serde_json::to_string(&parsed).unwrap();
        let reconstructed: SpecFile = serde_json::from_str(&spec_json).unwrap();
        validate(&reconstructed).unwrap();
        let compiled = compile(&parsed).unwrap();
        let compiled_json = serde_json::to_string(&compiled).unwrap();
        let rebuilt: CompiledSpec = serde_json::from_str(&compiled_json).unwrap();
        for (route, carrier) in [
            ("native", compiled),
            ("spec_json", compile(&reconstructed).unwrap()),
            ("compiled_json", rebuilt),
        ] {
            observe(
                &case,
                route,
                Engine::new(carrier)
                    .execute_value(case["input"].as_str().unwrap(), &ExecutionOptions::new()),
                &mut failures,
            );
        }
        observe(
            &case,
            "generated_plan",
            execute_generated_parser_v2(
                &compiled_json,
                PLAN,
                case["input"].as_str().unwrap(),
                "numeric-conversion.spec",
                GENERATED_SOURCE_CONTRACT,
            )
            .map_err(|error| error.detail.as_deref().unwrap_or(error.summary).to_owned()),
            &mut failures,
        );
    }
    assert!(
        failures.is_empty(),
        "numeric route mismatches: {failures:?}"
    );
}

fn job() -> Value {
    json!({"kind":"parse_job","job_id":"numeric-boundary",
        "parent_ast_path":["functions","0","body_source"],
        "node_kind":"function_definition","payload_kind":"function_body",
        "text":"return(42)","source_span":{"start":0,"end":10,"line_start":1,"line_end":1},
        "parser_spec_id":"actionir-body.spec","top_rule":"action_block",
        "result_policy":"replace_field","result_field":"body_ast","failure_policy":"fail"})
}

#[test]
fn public_v1_metadata_rejects_out_of_range_floating_integers() {
    let mut failures = Vec::new();
    let upper = 2.0_f64.powi(usize::BITS as i32);
    let below = f64::from_bits(upper.to_bits() - 1);
    for field in ["start", "end", "line_start", "line_end"] {
        for (name, value, accepted) in [
            ("below", below, below.fract() == 0.0),
            ("outside", upper, false),
            ("above", f64::from_bits(upper.to_bits() + 1), false),
            ("fraction", 1.5, false),
            ("negative", -1.0, false),
        ] {
            let mut job = job();
            if field == "start" {
                job["source_span"]["end"] = json!(value);
            }
            if field == "line_start" {
                job["source_span"]["line_end"] = json!(value);
            }
            job["source_span"][field] = json!(value);
            let actual = execute_parse_jobs(&[job]);
            let matches = if accepted {
                actual.is_ok()
            } else {
                actual
                    .as_ref()
                    .err()
                    .is_some_and(|error| error.contains(&format!("field '{field}'")))
            };
            println!(
                "NUMERIC_METADATA\t{}",
                json!({"field":field,"case":name,
                "accepted":actual.is_ok(),"error":actual.err(),"matches":matches})
            );
            if !matches {
                failures.push(format!("{field}:{name}"));
            }
        }
    }
    for (name, value) in [
        ("small-integer", json!(10)),
        ("small-float", json!(10.0)),
        ("maximum-integer", json!(u64::MAX)),
    ] {
        let mut job = job();
        job["source_span"]["end"] = value;
        let actual = execute_parse_jobs(&[job]);
        let matches = actual.is_ok() == (name != "maximum-integer" || usize::BITS == 64);
        println!(
            "NUMERIC_METADATA\t{}",
            json!({"field":"end","case":name,
            "accepted":actual.is_ok(),"error":actual.err(),"matches":matches})
        );
        if !matches {
            failures.push(name.to_owned());
        }
    }
    assert!(failures.is_empty(), "metadata mismatches: {failures:?}");
}
