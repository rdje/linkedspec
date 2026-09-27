//! Independent context-name oracles shared by retained and fresh emitted probes.
use linkedspec_runtime::RuntimeDiagnosticOutputExecutionError;
use linkedspec_runtime::source_emitter::GeneratedDiagnosticOutputExecutionError;
use serde_json::{Value, json};

pub type Outcome = Result<Value, i32>;

pub fn native_result(result: Result<Value, RuntimeDiagnosticOutputExecutionError>) -> Outcome {
    match result {
        Ok(value) => Ok(value),
        Err(RuntimeDiagnosticOutputExecutionError::Exit(exit)) => Err(exit.status),
        Err(other) => panic!("expected typed context-name exit, got {other}"),
    }
}

pub fn generated_result(result: Result<Value, GeneratedDiagnosticOutputExecutionError>) -> Outcome {
    match result {
        Ok(value) => Ok(value),
        Err(GeneratedDiagnosticOutputExecutionError::Exit(exit)) => Err(exit.status),
        Err(other) => panic!("expected typed generated context-name exit, got {other}"),
    }
}

fn case<'a>(cases: &'a Value, group: &str, id: &str) -> &'a Value {
    cases[group]
        .as_array()
        .unwrap()
        .iter()
        .find(|case| case["id"] == id)
        .unwrap()
}

pub fn sequence(cases: &Value, mut parse: impl FnMut(&str) -> Outcome) -> usize {
    let accepted = cases["accept"].as_array().unwrap();
    let rejected = cases["reject"].as_array().unwrap();
    assert_eq!((accepted.len(), rejected.len()), (11, 17));
    let recovery = case(cases, "accept", "siblings_restore_parent");
    let mut executions = 0;
    for _ in 0..2 {
        for case in accepted {
            assert_eq!(
                parse(case["input"].as_str().unwrap()),
                Ok(case["expected"].clone()),
                "independent context-name tree and scalar spans: {}",
                case["id"]
            );
            executions += 1;
        }
        for case in rejected {
            let status = i32::try_from(case["status"].as_i64().unwrap()).unwrap();
            assert_eq!(
                parse(case["input"].as_str().unwrap()),
                Err(status),
                "typed rejection with exact authored status, not a null result: {}",
                case["id"]
            );
            assert_eq!(
                parse(recovery["input"].as_str().unwrap()),
                Ok(recovery["expected"].clone()),
                "independent invocation after context-name rejection: {}",
                case["id"]
            );
            executions += 2;
        }
    }
    assert_eq!(executions, 90);
    executions
}

pub fn mutation(id: &str, cases: &Value, mut parse: impl FnMut(&str) -> Outcome) {
    match id {
        "comparison" => assert_eq!(
            parse(case(cases, "reject", "mismatch")["input"].as_str().unwrap()),
            Ok(case(cases, "accept", "empty_element")["expected"].clone()),
            "removing the name guard wrongly accepts a mismatched close"
        ),
        "state" => assert_eq!(
            parse(
                case(cases, "accept", "siblings_restore_parent")["input"]
                    .as_str()
                    .unwrap()
            ),
            Err(2),
            "clobbering the enclosing name wrongly rejects valid nested siblings"
        ),
        "span" => {
            let original = case(cases, "accept", "nested_distinct");
            let value = parse(original["input"].as_str().unwrap())
                .expect("span mutant must still return a document");
            assert!(value.is_array());
            assert_eq!(value[0]["span"], json!([17, 17]));
            assert_ne!(
                value, original["expected"],
                "authored span oracle detects mutation"
            );
        }
        other => panic!("unknown controlled context-name mutation {other}"),
    }
}
