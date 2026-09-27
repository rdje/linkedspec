//! Independent authored values shared by the in-process and emitted Rust probes.
use linkedspec_runtime::RuntimeDiagnosticOutputExecutionError;
use linkedspec_runtime::source_emitter::GeneratedDiagnosticOutputExecutionError;
use serde_json::{Value, json};

pub fn native_result(
    result: Result<Value, RuntimeDiagnosticOutputExecutionError>,
) -> Option<Value> {
    match result {
        Ok(value) => Some(value),
        Err(RuntimeDiagnosticOutputExecutionError::Exit(exit)) => {
            assert_eq!(exit.status, 1, "exact typed grammar rejection");
            None
        }
        Err(other) => panic!("expected typed grammar rejection, got {other}"),
    }
}

pub fn generated_result(
    result: Result<Value, GeneratedDiagnosticOutputExecutionError>,
) -> Option<Value> {
    match result {
        Ok(value) => Some(value),
        Err(GeneratedDiagnosticOutputExecutionError::Exit(exit)) => {
            assert_eq!(exit.status, 1, "exact typed generated rejection");
            None
        }
        Err(other) => panic!("expected typed generated rejection, got {other}"),
    }
}

pub fn sequence(cases: &Value, mut parse: impl FnMut(&str) -> Option<Value>) -> usize {
    let accepted = cases["accept"].as_array().unwrap();
    let rejected = cases["reject"].as_array().unwrap();
    assert_eq!((accepted.len(), rejected.len()), (6, 7));
    let recovery = accepted
        .iter()
        .find(|case| case["id"] == "nested_state")
        .unwrap();
    let mut executions = 0;
    for _ in 0..2 {
        for case in accepted {
            assert_eq!(
                parse(case["input"].as_str().unwrap()),
                Some(case["expected"].clone()),
                "authored value/spans: {}",
                case["id"]
            );
            executions += 1;
        }
        for case in rejected {
            assert_eq!(
                parse(case["input"].as_str().unwrap()),
                None,
                "{}",
                case["id"]
            );
            assert_eq!(
                parse(recovery["input"].as_str().unwrap()),
                Some(recovery["expected"].clone()),
                "independent parse after rejection: {}",
                case["id"]
            );
            executions += 2;
        }
    }
    assert_eq!(executions, 40);
    executions
}

pub fn mutation(id: &str, cases: &Value, mut parse: impl FnMut(&str) -> Option<Value>) {
    let (group, case_id) = match id {
        "prefix" => ("reject", "hidden_prefix"),
        "gap" => ("reject", "interstitial_junk"),
        "span" => ("accept", "nested_state"),
        other => panic!("unknown controlled mutation {other}"),
    };
    let case = cases[group]
        .as_array()
        .unwrap()
        .iter()
        .find(|case| case["id"] == case_id)
        .unwrap();
    let value = parse(case["input"].as_str().unwrap()).expect("mutant must execute successfully");
    assert!(value.is_array(), "mutant must still return a document");
    if id == "span" {
        assert_eq!(
            value[0]["span"],
            json!([9, 9]),
            "controlled wrong start coordinate"
        );
        assert_ne!(
            value, case["expected"],
            "original authored span oracle detects mutation"
        );
    } else {
        assert_eq!(
            value.as_array().unwrap().len(),
            if id == "prefix" { 1 } else { 2 },
            "mutant wrongly accepts the surrounding forms"
        );
    }
}
