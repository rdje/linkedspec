//! Independent lossless/child oracles shared by retained and freshly emitted Rust carriers.
use linkedspec_runtime::engine::ExecutionOptions;
use linkedspec_runtime::source_emitter::GeneratedDiagnosticOutputExecutionError;
use linkedspec_runtime::{
    CompiledStagedAuthority, RuntimeDiagnosticOutputExecutionError, StagedAstEnrichmentSeed,
};
use serde_json::{Value, json};
use std::collections::BTreeMap;
use std::sync::{Arc, Mutex};

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Failure {
    Exit(i32),
    Staged(String),
}
pub type Outcome = Result<Value, Failure>;
pub type Parser = Arc<dyn Fn(&str, &ExecutionOptions) -> Outcome + Send + Sync>;

fn staged_failure(message: &str) -> Failure {
    let code = message
        .strip_prefix("LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:")
        .unwrap_or_else(|| panic!("unexpected runtime error: {message}"));
    assert!(!code.is_empty() && code.bytes().all(|c| c.is_ascii_lowercase() || c == b'_'));
    Failure::Staged(code.to_owned())
}

pub fn native(result: Result<Value, RuntimeDiagnosticOutputExecutionError>) -> Outcome {
    match result {
        Ok(value) => Ok(value),
        Err(RuntimeDiagnosticOutputExecutionError::Exit(exit)) => Err(Failure::Exit(exit.status)),
        Err(RuntimeDiagnosticOutputExecutionError::Runtime(error)) => {
            Err(staged_failure(error.message()))
        }
        Err(other) => panic!("unexpected native diagnostic: {other}"),
    }
}

pub fn generated(result: Result<Value, GeneratedDiagnosticOutputExecutionError>) -> Outcome {
    match result {
        Ok(value) => Ok(value),
        Err(GeneratedDiagnosticOutputExecutionError::Exit(exit)) => Err(Failure::Exit(exit.status)),
        Err(GeneratedDiagnosticOutputExecutionError::GeneratedSource(error)) => {
            Err(staged_failure(
                error
                    .detail
                    .as_deref()
                    .expect("generated runtime error detail"),
            ))
        }
        Err(other) => panic!("unexpected generated diagnostic: {other}"),
    }
}

pub fn options(
    child: Parser,
    digest: &str,
    calls: Arc<Mutex<Vec<Value>>>,
    change: &str,
) -> ExecutionOptions {
    let authority = CompiledStagedAuthority::new(move |request, context| {
        calls
            .lock()
            .unwrap()
            .push(json!({"text": request["text"], "top": request["top_rule"]}));
        let mut result = child(request["text"].as_str().unwrap(), &ExecutionOptions::new())
            .map_err(|error| json!({"message": format!("{error:?}")}))?;
        result["source_span"] = context
            .rebase_span(&result["span"])
            .map_err(|e| e.as_record())?;
        Ok(result)
    });
    let caps = json!(["staged-parse-job-v2", "typed-source-location-v1"]);
    let modes = json!(["fail", "sibling_field"]);
    let ceilings = json!({"source_detail": "span", "max_steps": 100,
        "max_result_nodes": 512, "max_diagnostic_bytes": 4096});
    let mut snapshot = json!({
        "immutable": true, "prepared_before_authored_execution": true, "filesystem_access_during_dispatch": false,
        "aliases": [{"declaring_spec_id": "readiness/parent.spec", "authored_id": "integer",
            "resolved_spec_id": "registry:integer-v1"}],
        "declaring_relative": [], "search_roots": [], "providers": [],
        "entries": [{"resolved_spec_id": "registry:integer-v1", "compiled_authority": "opaque:integer",
            "content_digest": digest, "import_graph_fingerprint": "sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
            "default_top_rule": "Number", "allowed_top_rules": ["Number"], "spec_language_version": 2,
            "helper_contract_version": "actionir-v3", "staged_contract_version": 2,
            "capabilities": caps, "policy_modes": modes, "ceilings": ceilings}]
    });
    if change == "missing_identity" {
        snapshot["aliases"] = json!([]);
    }
    if change == "forbidden_top" {
        snapshot["entries"][0]["default_top_rule"] = json!("Other");
        snapshot["entries"][0]["allowed_top_rules"] = json!(["Other"]);
    }
    let seed = StagedAstEnrichmentSeed::new(
        snapshot,
        BTreeMap::from([("opaque:integer".to_owned(), authority)]),
        json!({"declaring_spec_id": "readiness/parent.spec", "caller_capabilities": caps,
            "caller_policy_modes": modes, "caller_ceilings": ceilings, "required_source_detail": "span",
            "required_versions": {"spec_language_version": 2, "helper_contract_version": "actionir-v3", "staged_contract_version": 2}}),
        json!({"cancellation_token": "lossless-child-readiness", "deadline": 100,
            "remaining_steps": if change == "no_budget" {0} else {100}, "required_steps": 1,
            "max_depth": 4, "max_calls": if change == "one_call" {1} else {16}}),
        |_| false,
        || 0,
    );
    ExecutionOptions::new().with_staged_ast_enrichment(seed)
}

fn case<'a>(cases: &'a Value, id: &str) -> &'a Value {
    cases["accept"]
        .as_array()
        .unwrap()
        .iter()
        .find(|row| row["id"] == id)
        .unwrap()
}

fn assert_segments(actual: &Value, expected: &Value, input: &str) {
    assert_eq!(
        actual, expected,
        "classification and exact records for {input:?}"
    );
    let scalars: Vec<char> = input.chars().collect();
    let mut cursor = 0;
    let mut reconstruction = String::new();
    for segment in actual.as_array().unwrap() {
        let span = &segment["span"];
        let (start, end) = if span.is_array() {
            (&span[0], &span[1])
        } else {
            (&span["start"], &span["end"])
        };
        let (start, end) = (
            start.as_u64().unwrap() as usize,
            end.as_u64().unwrap() as usize,
        );
        assert_eq!(start, cursor, "ordered scalar adjacency");
        assert!(start <= end && end <= scalars.len());
        let slice: String = scalars[start..end].iter().collect();
        assert_eq!(segment["text"], slice, "independent decoded-scalar slicing");
        reconstruction.push_str(segment["text"].as_str().unwrap());
        cursor = end;
    }
    assert_eq!(cursor, scalars.len());
    assert_eq!(reconstruction, input);
}

pub fn segmentation(cases: &Value, parse: &Parser) {
    assert_eq!(cases["accept"].as_array().unwrap().len(), 13);
    for _ in 0..2 {
        for row in cases["accept"].as_array().unwrap() {
            let input = row["input"].as_str().unwrap();
            assert_segments(
                &parse(input, &ExecutionOptions::new()).unwrap(),
                &row["expected"],
                input,
            );
        }
    }
    let row = case(cases, "unicode_edges");
    let input = row["input"].as_str().unwrap();
    let mut returned = parse(input, &ExecutionOptions::new()).unwrap();
    returned[0]["text"] = json!("changed gap");
    returned[0]["span"]["start"] = json!(999);
    assert_segments(
        &parse(input, &ExecutionOptions::new()).unwrap(),
        &row["expected"],
        input,
    );
}

fn composition(value: &Value, row: &Value, calls: &[Value]) {
    let mut original = value["ast"].clone();
    let mut requests = Vec::new();
    let mut sidecars = Vec::new();
    for (index, item) in row["expected"].as_array().unwrap().iter().enumerate() {
        if item["kind"] != "item" {
            continue;
        }
        let token = item["text"].as_str().unwrap();
        let text = &token[1..token.len() - 1]; // Authored items contain ASCII brackets/digits only.
        let span = json!({"kind": "direct_span", "source_id": "input", "provenance": "entry_group",
            "start": item["span"][0].as_u64().unwrap()+1, "end": item["span"][1].as_u64().unwrap()-1});
        assert_eq!(original[index]["child"], text);
        assert_eq!(
            original[index]["parsed"],
            json!({"kind": "integer", "text": text,
            "span": {"start": 0, "end": text.chars().count()}, "source_span": span})
        );
        original[index].as_object_mut().unwrap().remove("child");
        original[index].as_object_mut().unwrap().remove("parsed");
        requests.push(json!({"text": text, "top": "Number"}));
        sidecars.push((json!([index, "child"]), span));
    }
    assert_segments(&original, &row["expected"], row["input"].as_str().unwrap());
    assert_eq!(calls, requests);
    assert_eq!(value["sidecars"].as_array().unwrap().len(), sidecars.len());
    for (actual, (path, span)) in value["sidecars"].as_array().unwrap().iter().zip(sidecars) {
        assert_eq!(actual["parent_ast_path"], path);
        assert_eq!(actual["provenance"], span);
        assert_eq!(actual["resolved_spec_id"], "registry:integer-v1");
        assert_eq!(actual["top_rule"], "Number");
        assert_eq!(actual["state"], "succeeded");
    }
    assert_eq!(value["resources"]["total_calls"], requests.len());
    assert_eq!(value["cache"]["misses"], usize::from(!requests.is_empty()));
    assert_eq!(value["cache"]["hits"], requests.len().saturating_sub(1));
    assert_eq!(value["diagnostics"], json!([]));
}

pub fn children(
    cases: &Value,
    strict: &Value,
    parent: &Parser,
    child: &Parser,
    digest: &str,
) -> Vec<Value> {
    let calls = Arc::new(Mutex::new(Vec::new()));
    let seed = options(child.clone(), digest, calls.clone(), "");
    let mut records = Vec::new();
    for _ in 0..2 {
        for row in cases["accept"].as_array().unwrap() {
            calls.lock().unwrap().clear();
            let result = parent(row["input"].as_str().unwrap(), &seed).unwrap();
            composition(&result, row, &calls.lock().unwrap());
            records.push(result);
        }
    }
    calls.lock().unwrap().clear();
    assert_eq!(
        parent("[12][00][7]", &seed),
        Err(Failure::Staged("staged_child_failed".into()))
    );
    assert_eq!(
        *calls.lock().unwrap(),
        json!([{"text":"12","top":"Number"},{"text":"00","top":"Number"}])
            .as_array()
            .unwrap()
            .clone()
    );
    calls.lock().unwrap().clear();
    let mut recovery = case(cases, "single_zero").clone();
    recovery["input"] = json!("[8]");
    recovery["expected"][1]["text"] = json!("[8]");
    composition(
        &parent("[8]", &seed).unwrap(),
        &recovery,
        &calls.lock().unwrap(),
    );
    for (change, code, count) in [
        ("missing_identity", "staged_registry_missing", 0),
        ("forbidden_top", "staged_top_rule_forbidden", 0),
        ("no_budget", "staged_budget_exhausted", 0),
        ("one_call", "staged_call_limit_exceeded", 1),
    ] {
        let changed = options(child.clone(), digest, calls.clone(), change);
        calls.lock().unwrap().clear();
        assert_eq!(
            parent("[1][2]", &changed),
            Err(Failure::Staged(code.into()))
        );
        assert_eq!(
            calls.lock().unwrap().len(),
            count,
            "callback count for {change}"
        );
    }
    let row = case(cases, "unicode_edges");
    let mut detached = parent("α[12]🙂", &seed).unwrap();
    detached["ast"][1]["parsed"]["text"] = json!("changed child");
    detached["ast"][1]["parsed"]["source_span"]["start"] = json!(999);
    calls.lock().unwrap().clear();
    composition(
        &parent("α[12]🙂", &seed).unwrap(),
        row,
        &calls.lock().unwrap(),
    );
    calls.lock().unwrap().clear();
    let inert = parent("α[12]🙂", &ExecutionOptions::new()).unwrap();
    assert_eq!(inert[1]["child"]["kind"], "STAGED_PARSE_JOB_MARKER");
    assert_eq!(inert[1]["child"]["staged_parse_job_v2"]["text"], "12");
    assert!(calls.lock().unwrap().is_empty());
    assert_eq!(strict["accept"].as_array().unwrap().len(), 4);
    assert_eq!(strict["reject"].as_array().unwrap().len(), 15);
    for row in strict["accept"].as_array().unwrap() {
        assert_eq!(
            child(row["input"].as_str().unwrap(), &ExecutionOptions::new()),
            Ok(row["expected"].clone())
        );
    }
    for input in strict["reject"].as_array().unwrap() {
        assert_eq!(
            child(input.as_str().unwrap(), &ExecutionOptions::new()),
            Err(Failure::Exit(1))
        );
    }
    records
}

pub fn child_mutation(id: &str, parent: &Parser, child: &Parser, digest: &str) {
    let calls = Arc::new(Mutex::new(Vec::new()));
    let seed = options(child.clone(), digest, calls.clone(), "");
    match id {
        "leading_zero" => {
            let value = parent("[00]", &seed).unwrap();
            assert_eq!(
                value["ast"][1]["parsed"],
                json!({"kind":"integer","text":"00",
                "span":{"start":0,"end":2},"source_span":{"kind":"direct_span","source_id":"input",
                    "start":1,"end":3,"provenance":"entry_group"}})
            );
        }
        "wrong_span" => {
            let value = parent("α[12]🙂", &seed).unwrap();
            assert_eq!(
                value["ast"][1]["parsed"]["span"],
                json!({"start":1,"end":2})
            );
            assert_eq!(
                value["ast"][1]["parsed"]["source_span"],
                json!({"kind":"direct_span",
                "source_id":"input","start":3,"end":4,"provenance":"entry_group"})
            );
        }
        "whole_item" => {
            assert_eq!(
                parent("α[12]🙂", &seed),
                Err(Failure::Staged("staged_child_failed".into()))
            );
            assert_eq!(
                *calls.lock().unwrap(),
                vec![json!({"text":"[12]","top":"Number"})]
            );
        }
        _ => panic!("unknown child mutation {id}"),
    }
}

pub fn segment_mutation(id: &str, cases: &Value, parse: &Parser) {
    let (row, expected) = match id {
        "selection" => (
            case(cases, "single_zero"),
            json!([{"kind":"tail",
            "span":{"source_id":"input","start":0,"end":3,"provenance":"gap"},"text":"[0]"}]),
        ),
        "tail" => {
            let row = case(cases, "unicode_edges");
            let mut v = row["expected"].clone();
            v.as_array_mut().unwrap().pop();
            (row, v)
        }
        "item_span" => {
            let row = case(cases, "unicode_edges");
            let mut v = row["expected"].clone();
            v[1]["span"] = json!([5, 5]);
            (row, v)
        }
        "entry_prefix" => {
            let row = case(cases, "leading_lf");
            let mut v = row["expected"].clone();
            v.as_array_mut().unwrap().remove(0);
            (row, v)
        }
        _ => panic!("unknown segmentation mutation {id}"),
    };
    let actual = parse(row["input"].as_str().unwrap(), &ExecutionOptions::new()).unwrap();
    assert_eq!(actual, expected, "controlled wrong result for {id}");
    assert_ne!(
        actual, row["expected"],
        "original authored oracle detects {id}"
    );
}
