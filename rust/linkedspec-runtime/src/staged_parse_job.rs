//! Private inert staged parse-job declarations and typed provenance materialization.
//!
//! This module owns no parser registry, cache, scheduler, callback, or source path.
//! Runtime match ranges are converted immediately through the existing typed source
//! authority; only detached Unicode-scalar provenance and exact materialized text
//! enter the returned marker record.

use crate::runtime::runtime_value_from_json;
use crate::source_location::{DerivedTextPolicy, SourceAuthority, SourceLocationContext};
use linkedspec_core::expr::{
    StagedParseJobDirectTextPlan, StagedParseJobOptions, StagedParseJobTextPlan,
};
use linkedspec_core::types::RuntimeValue;
use serde_json::{Map, Value, json};
use std::fmt;

const ERROR_PREFIX: &str = "LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:";
const PROVENANCE_CODE: &str = "staged_source_provenance_invalid";

/// One private staged-declaration failure with a detached neutral record.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct StagedParseJobError {
    record: Value,
}

impl StagedParseJobError {
    fn provenance(origin: &str, source_id: &str, provenance: &str) -> Self {
        Self {
            record: json!({
                "code": PROVENANCE_CODE,
                "phase": "declare",
                "origin": origin,
                "source_id": source_id,
                "provenance": provenance,
            }),
        }
    }

    /// Return a detached machine-readable failure record.
    #[allow(dead_code)]
    pub fn as_record(&self) -> Value {
        self.record.clone()
    }
}

impl fmt::Display for StagedParseJobError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        let code = self.record["code"].as_str().unwrap_or(PROVENANCE_CODE);
        write!(formatter, "{ERROR_PREFIX}{code}")
    }
}

impl std::error::Error for StagedParseJobError {}

fn exact_keys(object: &Map<String, Value>, expected: &[&str]) -> bool {
    object.len() == expected.len() && expected.iter().all(|key| object.contains_key(*key))
}

fn typed_direct_span(
    authority: &SourceAuthority,
    record: &Value,
    origin: &str,
) -> Result<(crate::source_location::Span, Value), StagedParseJobError> {
    let Some(object) = record.as_object() else {
        return Err(StagedParseJobError::provenance(
            origin,
            "<runtime>",
            "<invalid>",
        ));
    };
    let source_id = object
        .get("source_id")
        .and_then(Value::as_str)
        .unwrap_or("<runtime>");
    let provenance = object
        .get("provenance")
        .and_then(Value::as_str)
        .unwrap_or("<invalid>");
    if !exact_keys(object, &["kind", "source_id", "start", "end", "provenance"])
        || object.get("kind").and_then(Value::as_str) != Some("direct_span")
        || provenance.is_empty()
    {
        return Err(StagedParseJobError::provenance(
            origin, source_id, provenance,
        ));
    }
    let (Some(start), Some(end)) = (
        object.get("start").and_then(Value::as_u64),
        object.get("end").and_then(Value::as_u64),
    ) else {
        return Err(StagedParseJobError::provenance(
            origin, source_id, provenance,
        ));
    };
    let context = SourceLocationContext::new(origin, "staged_parse_job_declaration");
    let start = authority
        .position(source_id, start, &context)
        .map_err(|_| StagedParseJobError::provenance(origin, source_id, provenance))?;
    let end = authority
        .position(source_id, end, &context)
        .map_err(|_| StagedParseJobError::provenance(origin, source_id, provenance))?;
    let span = authority
        .direct_span(&start, &end, provenance, &context)
        .map_err(|_| StagedParseJobError::provenance(origin, source_id, provenance))?;
    let mut detached = span.as_record();
    detached
        .as_object_mut()
        .expect("span record is an object")
        .insert("kind".to_owned(), Value::String("direct_span".to_owned()));
    Ok((span, detached))
}

/// Validate and materialize one detached neutral direct or ordered-derived record.
pub fn validate_and_materialize_provenance(
    authority: &SourceAuthority,
    record: &Value,
    origin: &str,
) -> Result<Value, StagedParseJobError> {
    if record.get("kind").and_then(Value::as_str) == Some("direct_span") {
        let (span, provenance) = typed_direct_span(authority, record, origin)?;
        let context = SourceLocationContext::new(origin, "staged_parse_job_declaration");
        let text = authority
            .materialize(&span, &context)
            .map_err(|_| StagedParseJobError::provenance(origin, "<runtime>", "direct_span"))?;
        return Ok(json!({"text": text, "provenance": provenance}));
    }

    let Some(object) = record.as_object() else {
        return Err(StagedParseJobError::provenance(
            origin,
            "<derived>",
            "<invalid>",
        ));
    };
    let valid_shape = exact_keys(object, &["kind", "policy", "segments"])
        && object.get("kind").and_then(Value::as_str) == Some("derived_text")
        && object.get("policy").and_then(Value::as_str) == Some("concatenate_in_order");
    let Some(segments) = object.get("segments").and_then(Value::as_array) else {
        return Err(StagedParseJobError::provenance(
            origin,
            "<derived>",
            "derived_text",
        ));
    };
    if !valid_shape || segments.is_empty() {
        return Err(StagedParseJobError::provenance(
            origin,
            "<derived>",
            "derived_text",
        ));
    }

    let mut spans = Vec::with_capacity(segments.len());
    let mut detached_segments = Vec::with_capacity(segments.len());
    for segment in segments {
        let (span, detached) = typed_direct_span(authority, segment, origin)?;
        spans.push(span);
        detached_segments.push(detached);
    }
    let context = SourceLocationContext::new(origin, "staged_parse_job_declaration");
    let derived = authority
        .derived_text(DerivedTextPolicy::ConcatenateInOrder, &spans, &context)
        .map_err(|_| StagedParseJobError::provenance(origin, "<derived>", "derived_text"))?;
    let text = authority
        .materialize(&derived, &context)
        .map_err(|_| StagedParseJobError::provenance(origin, "<derived>", "derived_text"))?;
    Ok(json!({
        "text": text,
        "provenance": {
            "kind": "derived_text",
            "policy": "concatenate_in_order",
            "segments": detached_segments,
        },
    }))
}

pub(crate) struct RuntimeSourceView<'a> {
    pub authority: &'a SourceAuthority,
    pub source_id: &'a str,
    pub entry_match: Option<(usize, usize)>,
    pub entry_groups: &'a [(usize, usize)],
    pub local_match: Option<(usize, usize)>,
    pub local_groups: &'a [(usize, usize)],
}

fn direct_record_from_runtime(
    view: &RuntimeSourceView<'_>,
    plan: &StagedParseJobDirectTextPlan,
    origin: &str,
) -> Result<Value, StagedParseJobError> {
    let range = match (plan.source.as_str(), plan.index) {
        ("entry_text", None) => view.entry_match,
        ("match_text", None) => view.local_match,
        ("entry_group", Some(index)) => view.entry_groups.get(index).copied(),
        ("match_group", Some(index)) => view.local_groups.get(index).copied(),
        _ => None,
    }
    .ok_or_else(|| StagedParseJobError::provenance(origin, view.source_id, &plan.source))?;
    let context = SourceLocationContext::new(origin, "staged_parse_job_declaration");
    let start = view
        .authority
        .position_from_utf8_byte(view.source_id, range.0 as u64, &context)
        .map_err(|_| StagedParseJobError::provenance(origin, view.source_id, &plan.source))?;
    let end = view
        .authority
        .position_from_utf8_byte(view.source_id, range.1 as u64, &context)
        .map_err(|_| StagedParseJobError::provenance(origin, view.source_id, &plan.source))?;
    let span = view
        .authority
        .direct_span(&start, &end, &plan.source, &context)
        .map_err(|_| StagedParseJobError::provenance(origin, view.source_id, &plan.source))?;
    let mut record = span.as_record();
    record
        .as_object_mut()
        .expect("span record is an object")
        .insert("kind".to_owned(), Value::String("direct_span".to_owned()));
    Ok(record)
}

pub(crate) fn construct_marker(
    view: &RuntimeSourceView<'_>,
    origin: &str,
    text_plan: &StagedParseJobTextPlan,
    options: &StagedParseJobOptions,
) -> Result<RuntimeValue, String> {
    let provenance = match text_plan {
        StagedParseJobTextPlan::DirectSpan { source, index } => direct_record_from_runtime(
            view,
            &StagedParseJobDirectTextPlan {
                source: source.clone(),
                index: *index,
            },
            origin,
        )
        .map_err(|error| error.to_string())?,
        StagedParseJobTextPlan::DerivedText { policy, segments } => {
            if policy != "concatenate_in_order" || segments.is_empty() {
                return Err(StagedParseJobError::provenance(
                    origin,
                    view.source_id,
                    "derived_text",
                )
                .to_string());
            }
            let segments = segments
                .iter()
                .map(|segment| direct_record_from_runtime(view, segment, origin))
                .collect::<Result<Vec<_>, _>>()
                .map_err(|error| error.to_string())?;
            json!({
                "kind": "derived_text",
                "policy": "concatenate_in_order",
                "segments": segments,
            })
        }
    };
    let materialized = validate_and_materialize_provenance(view.authority, &provenance, origin)
        .map_err(|error| error.to_string())?;
    let mut sidecar = Map::new();
    sidecar.insert("kind".to_owned(), json!("staged_parse_job_v2"));
    sidecar.insert("version".to_owned(), json!(2));
    sidecar.insert("state".to_owned(), json!("declared"));
    sidecar.insert("effect".to_owned(), json!("staged_parse_job_declaration"));
    sidecar.insert("node_kind".to_owned(), json!(options.node_kind));
    sidecar.insert("payload_kind".to_owned(), json!(options.payload_kind));
    sidecar.insert("parser_spec_id".to_owned(), json!(options.spec));
    if let Some(top) = &options.top {
        sidecar.insert("top_rule".to_owned(), json!(top));
    }
    sidecar.insert("result_policy".to_owned(), json!(options.result_policy));
    if let Some(into) = &options.into {
        sidecar.insert("into".to_owned(), json!(into));
    }
    sidecar.insert("failure_policy".to_owned(), json!(options.on_error));
    sidecar.insert(
        "required_capabilities".to_owned(),
        json!(options.required_capabilities),
    );
    sidecar.insert("text".to_owned(), materialized["text"].clone());
    sidecar.insert("provenance".to_owned(), materialized["provenance"].clone());
    sidecar.insert("origin".to_owned(), json!(origin));

    Ok(runtime_value_from_json(json!({
        "kind": "STAGED_PARSE_JOB_MARKER",
        "version": 2,
        "sidecar_kind": "staged_parse_job_v2",
        "effect": "staged_parse_job_declaration",
        "staged_parse_job_v2": Value::Object(sidecar),
    })))
}
