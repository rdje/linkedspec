use linkedspec_runtime::semantic_index::{
    SemanticIndex, SemanticIndexOptions, SemanticQuery, SemanticSourceDetail,
};
use serde_json::{Value, json};
use sha2::{Digest, Sha256};
use std::fmt::Write;

const CONTRACT: &str =
    include_str!("../../../capability_conformance/semantic_introspection_contract.json");
const GRAPH: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/graph.spec");
const CALLS: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/calls_and_staging.spec");
const FAILED: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/failed.spec");
const PRIVACY: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/privacy.spec");

fn index(source: &[u8], logical_name: &str, ceiling: SemanticSourceDetail) -> SemanticIndex {
    SemanticIndex::from_utf8(source, SemanticIndexOptions::new(logical_name, ceiling))
        .expect("semantic fixture constructs")
}

fn index_for(snapshot: &str) -> SemanticIndex {
    match snapshot {
        "graph" => index(GRAPH, "graph.spec", SemanticSourceDetail::Text),
        "calls" => index(CALLS, "calls_and_staging.spec", SemanticSourceDetail::Text),
        "failed" => index(FAILED, "failed.spec", SemanticSourceDetail::Span),
        "privacy" => index(PRIVACY, "privacy.spec", SemanticSourceDetail::Text),
        "privacy_limited" => index(PRIVACY, "privacy.spec", SemanticSourceDetail::Identity),
        other => panic!("unexpected static snapshot {other}"),
    }
}

fn canonical_value<T: serde::Serialize>(value: &T) -> Value {
    serde_json::to_value(value).expect("value serializes")
}

fn canonical_digest<T: serde::Serialize>(value: &T) -> String {
    let bytes = serde_json::to_vec(&canonical_value(value)).expect("canonical value serializes");
    let digest = Sha256::digest(bytes);
    let mut encoded = String::with_capacity(digest.len() * 2);
    for byte in digest {
        write!(&mut encoded, "{byte:02x}").expect("writing to String cannot fail");
    }
    encoded
}

fn contract() -> Value {
    serde_json::from_str(CONTRACT).expect("semantic contract parses")
}

#[test]
fn all_nineteen_static_queries_match_exact_neutral_responses() {
    let contract = contract();
    let cases = contract["query_cases"].as_array().expect("query cases");
    let static_cases = cases
        .iter()
        .filter(|case| case["id"] != "runtime_events")
        .collect::<Vec<_>>();
    assert_eq!(static_cases.len(), 19);

    for case in static_cases {
        let case_id = case["id"].as_str().expect("case id");
        let snapshot = case["snapshot"].as_str().expect("snapshot id");
        let request_value = case["request"].clone();
        let request_before = request_value.clone();
        let request: SemanticQuery =
            serde_json::from_value(request_value.clone()).expect("canonical request is typed");
        let index = index_for(snapshot);
        let native = index.query(&request);
        let neutral = index.query_neutral(&request_value);

        assert_eq!(request_value, request_before, "{case_id} input isolation");
        assert_eq!(native, neutral, "{case_id} native/neutral identity");
        assert_eq!(
            native.ok,
            case["expected"]["ok"].as_bool().expect("expected ok"),
            "{case_id} status"
        );
        assert_eq!(
            native
                .records
                .iter()
                .map(|record| record.id.as_str())
                .collect::<Vec<_>>(),
            case["expected"]["record_ids"]
                .as_array()
                .expect("record ids")
                .iter()
                .map(|id| id.as_str().expect("record id"))
                .collect::<Vec<_>>(),
            "{case_id} record ids"
        );
        assert_eq!(
            native
                .relations
                .iter()
                .map(|relation| relation.id.as_str())
                .collect::<Vec<_>>(),
            case["expected"]["relation_ids"]
                .as_array()
                .expect("relation ids")
                .iter()
                .map(|id| id.as_str().expect("relation id"))
                .collect::<Vec<_>>(),
            "{case_id} relation ids"
        );
        assert_eq!(
            native
                .diagnostics
                .iter()
                .map(|diagnostic| diagnostic.code.as_str())
                .collect::<Vec<_>>(),
            case["expected"]["diagnostic_codes"]
                .as_array()
                .expect("diagnostic codes")
                .iter()
                .map(|code| code.as_str().expect("diagnostic code"))
                .collect::<Vec<_>>(),
            "{case_id} diagnostics"
        );
        assert_eq!(
            native.page.complete,
            case["expected"]["complete"]
                .as_bool()
                .expect("expected complete"),
            "{case_id} completion"
        );
        assert_eq!(
            canonical_digest(&native),
            case["expected"]["response_sha256"]
                .as_str()
                .expect("response digest"),
            "{case_id} full response digest"
        );
    }
}

#[test]
fn capabilities_is_exact_isolated_and_projection_only() {
    let contract = contract();
    let case = contract["query_cases"]
        .as_array()
        .expect("query cases")
        .iter()
        .find(|case| case["id"] == "capabilities")
        .expect("capabilities case");
    let request: SemanticQuery =
        serde_json::from_value(case["request"].clone()).expect("typed capabilities request");
    let index = index_for("graph");
    let mut first = index.capabilities();
    assert_eq!(first, index.query(&request));
    assert_eq!(
        canonical_digest(&first),
        case["expected"]["response_sha256"]
            .as_str()
            .expect("response digest")
    );

    first.records[0].facts["record_kinds"][0] = json!("host_private_kind");
    first.snapshot.source_detail_ceiling = SemanticSourceDetail::None;
    assert_eq!(
        canonical_digest(&index.capabilities()),
        case["expected"]["response_sha256"]
            .as_str()
            .expect("response digest"),
        "caller mutation cannot alter retained projection"
    );
    assert!(index.compiled_authority_present());
    assert!(!index.snapshot().has_execution);
}

#[test]
fn source_privacy_is_structural_and_monotonic() {
    let contract = contract();
    let cases = contract["query_cases"].as_array().expect("query cases");
    let request = |id: &str| {
        cases
            .iter()
            .find(|case| case["id"] == id)
            .expect("query case")["request"]
            .clone()
    };
    let privacy = index_for("privacy");
    let none = privacy.query_neutral(&request("privacy_none"));
    assert!(none.records[0].source.is_none());
    assert!(none.records[0].facts["pattern"].is_null());
    assert_eq!(none.records[0].redactions, ["/facts/pattern"]);

    let text = privacy.query_neutral(&request("privacy_text_and_digest"));
    assert_eq!(text.records[0].facts["pattern"], "é");
    let source = text.records[0].source.as_ref().expect("text source");
    assert_eq!(source.excerpt.as_deref(), Some("/é/"));
    assert!(
        source
            .content_digest
            .as_deref()
            .is_some_and(|digest| digest.starts_with("sha256:") && digest.len() == 71)
    );

    let limited = index_for("privacy_limited").query_neutral(&request("source_ceiling_forbidden"));
    assert!(!limited.ok);
    assert_eq!(
        limited.diagnostics[0].fields,
        json!({"requested": "span", "ceiling": "identity"})
    );
}

#[test]
fn neutral_validation_covers_all_twenty_six_portable_boundaries() {
    let contract = contract();
    let base = contract["query_cases"]
        .as_array()
        .expect("query cases")
        .iter()
        .find(|case| case["id"] == "graph_list_rules")
        .expect("base case")["request"]
        .clone();
    let mut cases: Vec<(&str, Value, &str, Option<&str>)> = vec![(
        "request_not_object",
        json!([]),
        "semantic_query_invalid",
        Some("request_not_object"),
    )];
    let mut add = |label, request, code, reason| cases.push((label, request, code, reason));

    let mut request = base.clone();
    request["contract"] = json!("linkedspec-semantic-query-v0");
    add(
        "unsupported_contract",
        request,
        "semantic_query_contract_unsupported",
        None,
    );
    let mut request = base.clone();
    request.as_object_mut().expect("object").remove("direction");
    add(
        "request_fields",
        request,
        "semantic_query_invalid",
        Some("request_fields"),
    );
    let mut request = base.clone();
    request["page"]
        .as_object_mut()
        .expect("page")
        .remove("limit");
    add(
        "page_fields",
        request,
        "semantic_query_invalid",
        Some("page_fields"),
    );
    let mut request = base.clone();
    request["budget"]
        .as_object_mut()
        .expect("budget")
        .remove("max_depth");
    add(
        "budget_fields",
        request,
        "semantic_query_invalid",
        Some("budget_fields"),
    );
    let mut request = base.clone();
    request["source"]
        .as_object_mut()
        .expect("source")
        .remove("detail");
    add(
        "source_fields",
        request,
        "semantic_query_invalid",
        Some("source_fields"),
    );
    let mut request = base.clone();
    request["operation"] = json!("search");
    add(
        "operation",
        request,
        "semantic_query_invalid",
        Some("operation"),
    );
    let mut request = base.clone();
    request["subjects"] = json!("rule:Top");
    add(
        "subjects_type",
        request,
        "semantic_query_invalid",
        Some("subjects_type"),
    );
    let mut request = base.clone();
    request["operation"] = json!("get");
    request["subjects"] = json!(["rule:Top", "rule:Top"]);
    request["record_kinds"] = json!([]);
    add(
        "subjects_duplicate",
        request,
        "semantic_query_invalid",
        Some("subjects_duplicate"),
    );
    let mut request = base.clone();
    request["record_kinds"] = json!(["host_ast"]);
    add(
        "record_kind",
        request,
        "semantic_query_invalid",
        Some("record_kind"),
    );
    let mut relation = base.clone();
    relation["operation"] = json!("relations");
    relation["subjects"] = json!(["rule:Top"]);
    relation["record_kinds"] = json!([]);
    relation["relation_kinds"] = json!(["host_edge"]);
    add(
        "relation_kind",
        relation.clone(),
        "semantic_query_invalid",
        Some("relation_kind"),
    );
    let mut request = base.clone();
    request["record_kinds"] = json!(["regex_slot", "rule"]);
    add(
        "record_kind_order",
        request,
        "semantic_query_invalid",
        Some("record_kind_order"),
    );
    relation["relation_kinds"] = json!(["contains", "declares"]);
    add(
        "relation_kind_order",
        relation,
        "semantic_query_invalid",
        Some("relation_kind_order"),
    );
    let mut request = base.clone();
    request["direction"] = json!("sideways");
    add(
        "direction",
        request,
        "semantic_query_invalid",
        Some("direction"),
    );
    let mut request = base.clone();
    request["page"]["after_id"] = json!(7);
    add(
        "after_id",
        request,
        "semantic_query_invalid",
        Some("after_id"),
    );
    let mut request = base.clone();
    request["page"]["limit"] = json!(0);
    add(
        "page_limit",
        request,
        "semantic_query_invalid",
        Some("page_limit"),
    );
    for (field, value) in [("max_records", 0), ("max_relations", 0), ("max_depth", 9)] {
        let mut request = base.clone();
        request["budget"][field] = json!(value);
        add(field, request, "semantic_query_invalid", Some(field));
    }
    let mut request = base.clone();
    request["source"]["detail"] = json!("full");
    add(
        "source_policy",
        request,
        "semantic_query_invalid",
        Some("source_policy"),
    );
    let mut request = base.clone();
    request["source"]["include_content_digest"] = json!(0);
    add(
        "numeric_boolean",
        request,
        "semantic_query_invalid",
        Some("source_policy"),
    );
    let mut request = base.clone();
    request["source"]["include_content_digest"] = json!(true);
    add(
        "digest_requires_text",
        request,
        "semantic_query_invalid",
        Some("digest_requires_text"),
    );
    let mut request = base.clone();
    request["subjects"] = json!(["rule:Top"]);
    add(
        "operation_combination",
        request,
        "semantic_query_invalid",
        Some("operation_combination"),
    );
    let mut request = base.clone();
    request["operation"] = json!("get");
    request["subjects"] = json!(["rule:Unknown"]);
    request["record_kinds"] = json!([]);
    add(
        "unknown_subject",
        request,
        "semantic_query_invalid",
        Some("unknown_subject"),
    );
    let mut request = base.clone();
    request["page"]["after_id"] = json!("rule:Unknown");
    add(
        "after_id_not_in_primary_stream",
        request,
        "semantic_query_invalid",
        Some("after_id_not_in_primary_stream"),
    );
    let mut request = base;
    request["operation"] = json!("explain");
    request["subjects"] = json!(["rule:Child"]);
    request["record_kinds"] = json!([]);
    add(
        "not_explainable",
        request,
        "semantic_query_invalid",
        Some("not_explainable"),
    );

    assert_eq!(cases.len(), 26);
    let index = index_for("graph");
    for (label, request, code, reason) in cases {
        let before = request.clone();
        let response = index.query_neutral(&request);
        assert_eq!(request, before, "{label} input isolation");
        assert!(!response.ok, "{label} is rejected");
        assert_eq!(response.diagnostics[0].code, code, "{label} code");
        if let Some(reason) = reason {
            assert_eq!(
                response.diagnostics[0].fields["reason"], reason,
                "{label} reason"
            );
        }
        assert!(response.records.is_empty(), "{label} records");
        assert!(response.relations.is_empty(), "{label} relations");
    }
}

#[test]
fn repeated_interleaved_queries_are_deterministic_and_host_clean() {
    let contract = contract();
    let cases = contract["query_cases"].as_array().expect("query cases");
    let explain = &cases
        .iter()
        .find(|case| case["id"] == "graph_explain_entry")
        .expect("explain case")["request"];
    let list = &cases
        .iter()
        .find(|case| case["id"] == "graph_list_rules")
        .expect("list case")["request"];
    let index = index_for("graph");
    let first = index.query_neutral(explain);
    let middle = index.query_neutral(list);
    let second = index.query_neutral(explain);
    assert_eq!(first, second);
    assert_ne!(first, middle);

    let encoded = serde_json::to_string(&canonical_value(&first)).expect("response JSON");
    for forbidden in [
        "/tmp/",
        "/Users/",
        "CompiledSpec",
        "ActionIR",
        "Regex(",
        "0x",
        "generated source",
    ] {
        assert!(!encoded.contains(forbidden), "host leak: {forbidden}");
    }
    assert!(!index.snapshot().has_execution);
}
