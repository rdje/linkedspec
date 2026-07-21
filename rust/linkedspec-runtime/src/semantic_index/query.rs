//! Exact projection-only `linkedspec-semantic-query-v1` evaluator.

use super::static_projection::{
    RECORD_KINDS, RELATION_KINDS, SemanticRecord, SemanticRelation, SemanticStaticProjection,
};
use super::{SemanticSnapshot, SemanticSourceDetail, SemanticSourceSpan};
use serde::{Deserialize, Serialize};
use serde_json::{Map, Value, json};
use std::collections::{BTreeMap, BTreeSet};

const MODEL_ID: &str = "linkedspec-semantic-model-v1";
const QUERY_ID: &str = "linkedspec-semantic-query-v1";
const REQUEST_FIELDS: &[&str] = &[
    "contract",
    "operation",
    "subjects",
    "record_kinds",
    "relation_kinds",
    "direction",
    "page",
    "budget",
    "source",
];
const PAGE_DEFAULT: usize = 100;
const PAGE_MAX: usize = 1000;
const RECORD_BUDGET_DEFAULT: usize = 1000;
const RELATION_BUDGET_DEFAULT: usize = 2000;
const DEPTH_BUDGET_DEFAULT: usize = 4;
const RECORD_BUDGET_MAX: usize = 10000;
const RELATION_BUDGET_MAX: usize = 20000;
const DEPTH_BUDGET_MAX: usize = 8;

/// One native semantic-query-v1 operation.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum SemanticQueryOperation {
    Capabilities,
    List,
    Get,
    Relations,
    Explain,
}

/// Traversal direction for a relation query.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum SemanticQueryDirection {
    Outgoing,
    Incoming,
    Both,
}

/// Canonical after-id page request.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct SemanticQueryPage {
    pub after_id: Option<String>,
    pub limit: usize,
}

impl Default for SemanticQueryPage {
    fn default() -> Self {
        Self {
            after_id: None,
            limit: PAGE_DEFAULT,
        }
    }
}

/// Logical model-traversal budgets, independent of host resource accounting.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct SemanticQueryBudget {
    pub max_records: usize,
    pub max_relations: usize,
    pub max_depth: usize,
}

impl Default for SemanticQueryBudget {
    fn default() -> Self {
        Self {
            max_records: RECORD_BUDGET_DEFAULT,
            max_relations: RELATION_BUDGET_DEFAULT,
            max_depth: DEPTH_BUDGET_DEFAULT,
        }
    }
}

/// Query-selected source projection beneath the immutable construction ceiling.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct SemanticQuerySource {
    pub detail: SemanticSourceDetail,
    pub include_content_digest: bool,
}

impl Default for SemanticQuerySource {
    fn default() -> Self {
        Self {
            detail: SemanticSourceDetail::None,
            include_content_digest: false,
        }
    }
}

/// Strongly typed native projection of one exact neutral query request.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct SemanticQuery {
    pub contract: String,
    pub operation: SemanticQueryOperation,
    pub subjects: Vec<String>,
    pub record_kinds: Vec<String>,
    pub relation_kinds: Vec<String>,
    pub direction: SemanticQueryDirection,
    pub page: SemanticQueryPage,
    pub budget: SemanticQueryBudget,
    pub source: SemanticQuerySource,
}

impl SemanticQuery {
    /// Create one query with canonical v1 defaults and no filters.
    pub fn new(operation: SemanticQueryOperation) -> Self {
        Self {
            contract: QUERY_ID.to_string(),
            operation,
            subjects: Vec::new(),
            record_kinds: Vec::new(),
            relation_kinds: Vec::new(),
            direction: SemanticQueryDirection::Outgoing,
            page: SemanticQueryPage::default(),
            budget: SemanticQueryBudget::default(),
            source: SemanticQuerySource::default(),
        }
    }

    pub(super) fn capabilities_value() -> Value {
        serde_json::to_value(Self::new(SemanticQueryOperation::Capabilities))
            .expect("SemanticQuery always serializes")
    }
}

/// Source reference after query-time privacy projection.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct SemanticQuerySourceReference {
    pub source_id: String,
    pub logical_name: String,
    pub span: Option<SemanticSourceSpan>,
    pub excerpt: Option<String>,
    pub content_digest: Option<String>,
    pub provenance_ids: Vec<String>,
}

/// One public clone-safe semantic model record.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct SemanticQueryRecord {
    pub id: String,
    pub kind: String,
    pub name: Option<String>,
    pub owner_id: Option<String>,
    pub order: usize,
    pub source: Option<SemanticQuerySourceReference>,
    pub facts: Value,
    pub redactions: Vec<String>,
}

/// One public clone-safe semantic model relation.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct SemanticQueryRelation {
    pub id: String,
    pub kind: String,
    pub from_id: String,
    pub to_id: String,
    pub order: usize,
    pub source: Option<SemanticQuerySourceReference>,
    pub facts: Value,
    pub evidence_ids: Vec<String>,
}

/// Portable query diagnostic, distinct from compilation/runtime records.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct SemanticQueryDiagnostic {
    pub code: String,
    pub severity: String,
    pub message: String,
    pub fields: Value,
}

/// Canonical response paging state.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct SemanticQueryPageState {
    pub after_id: Value,
    pub next_after_id: Option<String>,
    pub complete: bool,
}

/// Logical traversal cost reported by one query.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct SemanticQueryCost {
    pub records_examined: usize,
    pub relations_examined: usize,
    pub depth_reached: usize,
}

/// Exact native and neutral semantic-query-v1 response envelope.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct SemanticQueryResponse {
    pub contract: String,
    pub model: String,
    pub ok: bool,
    pub snapshot: SemanticSnapshot,
    pub records: Vec<SemanticQueryRecord>,
    pub relations: Vec<SemanticQueryRelation>,
    pub page: SemanticQueryPageState,
    pub cost: SemanticQueryCost,
    pub diagnostics: Vec<SemanticQueryDiagnostic>,
}

#[derive(Clone)]
struct ValidRequest {
    operation: SemanticQueryOperation,
    subjects: Vec<String>,
    record_kinds: Vec<String>,
    relation_kinds: Vec<String>,
    direction: SemanticQueryDirection,
    after_id: Option<String>,
    page_limit: usize,
    max_records: usize,
    max_relations: usize,
    max_depth: usize,
    source_detail: SemanticSourceDetail,
    include_content_digest: bool,
}

struct PageResult<T> {
    selected: Vec<T>,
    page: SemanticQueryPageState,
    limited_by_budget: bool,
}

struct Traversal {
    relations: Vec<SemanticRelation>,
    depth_by_id: BTreeMap<String, usize>,
    depth_limited: bool,
}

pub(super) fn evaluate(
    projection: &SemanticStaticProjection,
    request_value: &Value,
) -> SemanticQueryResponse {
    let snapshot = projection.snapshot.clone();
    let request = match validate_request(&snapshot, request_value) {
        Ok(request) => request,
        Err(response) => return response,
    };
    let record_by_id = projection
        .records
        .iter()
        .map(|record| (record.id.as_str(), record))
        .collect::<BTreeMap<_, _>>();
    if matches!(
        request.operation,
        SemanticQueryOperation::Get | SemanticQueryOperation::Relations
    ) && request
        .subjects
        .iter()
        .any(|subject| !record_by_id.contains_key(subject.as_str()))
    {
        return empty_response(
            &snapshot,
            request_value,
            query_diagnostic("semantic_query_invalid", Some("unknown_subject"), None),
        );
    }

    let mut records = Vec::new();
    let mut relations = Vec::new();
    let mut diagnostics = Vec::new();
    let mut page;
    let (mut record_cost, mut relation_cost, mut depth) = (0, 0, 0);
    let mut budget_reason = None;

    match request.operation {
        SemanticQueryOperation::Capabilities => {
            let paged = page_stream(
                vec![capabilities_record(&snapshot)],
                &request,
                request.max_records,
                |record| &record.id,
            );
            let Ok(paged) = paged else {
                return invalid_after_id(&snapshot, request_value);
            };
            record_cost = paged.selected.len();
            records = paged.selected;
            page = paged.page;
            if paged.limited_by_budget {
                budget_reason = Some("max_records");
            }
        }
        SemanticQueryOperation::List | SemanticQueryOperation::Get => {
            let wanted = request.record_kinds.iter().collect::<BTreeSet<_>>();
            let subjects = request.subjects.iter().collect::<BTreeSet<_>>();
            let candidates = projection
                .records
                .iter()
                .filter(|record| match request.operation {
                    SemanticQueryOperation::List => {
                        wanted.is_empty() || wanted.contains(&record.kind)
                    }
                    SemanticQueryOperation::Get => subjects.contains(&record.id),
                    _ => unreachable!(),
                })
                .cloned()
                .collect::<Vec<_>>();
            let paged = page_stream(candidates, &request, request.max_records, |record| {
                &record.id
            });
            let Ok(paged) = paged else {
                return invalid_after_id(&snapshot, request_value);
            };
            record_cost = paged.selected.len();
            records = paged
                .selected
                .iter()
                .map(|record| project_record(record, projection, &request))
                .collect();
            page = paged.page;
            if paged.limited_by_budget {
                budget_reason = Some("max_records");
            }
        }
        SemanticQueryOperation::Relations => {
            let traversal = traverse_relations(projection, &request);
            let paged = page_stream(
                traversal.relations,
                &request,
                request.max_relations,
                |relation| &relation.id,
            );
            let Ok(paged) = paged else {
                return invalid_after_id(&snapshot, request_value);
            };
            relation_cost = paged.selected.len();
            depth = paged
                .selected
                .iter()
                .filter_map(|relation| traversal.depth_by_id.get(&relation.id))
                .copied()
                .max()
                .unwrap_or(0);
            relations = paged
                .selected
                .iter()
                .map(|relation| project_relation(relation, projection, &request))
                .collect();
            page = paged.page;
            if paged.limited_by_budget {
                budget_reason = Some("max_relations");
            } else if traversal.depth_limited {
                budget_reason = Some("max_depth");
            }
        }
        SemanticQueryOperation::Explain => {
            let subject = &request.subjects[0];
            let mut decision = record_by_id
                .get(subject.as_str())
                .copied()
                .filter(|record| record.kind == "decision");
            if decision.is_none() {
                let owned = projection
                    .records
                    .iter()
                    .filter(|record| {
                        record.kind == "decision" && record.owner_id.as_ref() == Some(subject)
                    })
                    .collect::<Vec<_>>();
                if owned.len() == 1 {
                    decision = Some(owned[0]);
                }
            }
            let Some(decision) = decision else {
                return empty_response(
                    &snapshot,
                    request_value,
                    query_diagnostic("semantic_query_invalid", Some("not_explainable"), None),
                );
            };
            let steps = projection
                .records
                .iter()
                .filter(|record| {
                    record.kind == "explanation_step"
                        && record.owner_id.as_ref() == Some(&decision.id)
                })
                .cloned()
                .collect::<Vec<_>>();
            let paged = page_stream(steps, &request, request.max_records - 1, |record| {
                &record.id
            });
            let Ok(paged) = paged else {
                return invalid_after_id(&snapshot, request_value);
            };
            let selected_step_ids = paged
                .selected
                .iter()
                .map(|record| record.id.as_str())
                .collect::<BTreeSet<_>>();
            records.push(project_record(decision, projection, &request));
            records.extend(
                paged
                    .selected
                    .iter()
                    .map(|record| project_record(record, projection, &request)),
            );
            relations = projection
                .relations
                .iter()
                .filter(|relation| {
                    relation.kind == "explained_by"
                        && relation.from_id == decision.id
                        && selected_step_ids.contains(relation.to_id.as_str())
                })
                .map(|relation| project_relation(relation, projection, &request))
                .collect();
            record_cost = records.len();
            relation_cost = relations.len();
            depth = usize::from(!paged.selected.is_empty());
            page = paged.page;
            if paged.limited_by_budget {
                budget_reason = Some("max_records");
            }
        }
    }

    if let Some(reason) = budget_reason {
        page.complete = false;
        diagnostics.push(query_diagnostic(
            "semantic_query_budget_exceeded",
            Some(reason),
            None,
        ));
    }

    SemanticQueryResponse {
        contract: QUERY_ID.to_string(),
        model: MODEL_ID.to_string(),
        ok: true,
        snapshot,
        records,
        relations,
        page,
        cost: SemanticQueryCost {
            records_examined: record_cost,
            relations_examined: relation_cost,
            depth_reached: depth,
        },
        diagnostics,
    }
}

// A rejected neutral request is already represented by its complete portable
// response envelope; returning it directly avoids a second error vocabulary.
#[allow(clippy::result_large_err)]
fn validate_request(
    snapshot: &SemanticSnapshot,
    request: &Value,
) -> Result<ValidRequest, SemanticQueryResponse> {
    let Some(object) = request.as_object() else {
        return Err(empty_response(
            snapshot,
            request,
            query_diagnostic("semantic_query_invalid", Some("request_not_object"), None),
        ));
    };
    let contract = object.get("contract");
    if contract.and_then(Value::as_str) != Some(QUERY_ID) {
        return Err(empty_response(
            snapshot,
            request,
            query_diagnostic(
                "semantic_query_contract_unsupported",
                None,
                contract.cloned(),
            ),
        ));
    }
    if !has_exact_keys(object, REQUEST_FIELDS) {
        return Err(invalid(snapshot, request, "request_fields"));
    }
    let page = exact_object(object.get("page"), &["after_id", "limit"])
        .ok_or_else(|| invalid(snapshot, request, "page_fields"))?;
    let budget = exact_object(
        object.get("budget"),
        &["max_records", "max_relations", "max_depth"],
    )
    .ok_or_else(|| invalid(snapshot, request, "budget_fields"))?;
    let source = exact_object(object.get("source"), &["detail", "include_content_digest"])
        .ok_or_else(|| invalid(snapshot, request, "source_fields"))?;

    let operation = match object.get("operation").and_then(Value::as_str) {
        Some("capabilities") => SemanticQueryOperation::Capabilities,
        Some("list") => SemanticQueryOperation::List,
        Some("get") => SemanticQueryOperation::Get,
        Some("relations") => SemanticQueryOperation::Relations,
        Some("explain") => SemanticQueryOperation::Explain,
        _ => return Err(invalid(snapshot, request, "operation")),
    };
    let subjects = string_array(object.get("subjects"))
        .ok_or_else(|| invalid(snapshot, request, "subjects_type"))?;
    let record_kinds = string_array(object.get("record_kinds"))
        .ok_or_else(|| invalid(snapshot, request, "record_kinds_type"))?;
    let relation_kinds = string_array(object.get("relation_kinds"))
        .ok_or_else(|| invalid(snapshot, request, "relation_kinds_type"))?;
    for (name, values) in [
        ("subjects", &subjects),
        ("record_kinds", &record_kinds),
        ("relation_kinds", &relation_kinds),
    ] {
        if values.iter().collect::<BTreeSet<_>>().len() != values.len() {
            return Err(invalid(snapshot, request, &format!("{name}_duplicate")));
        }
    }
    if record_kinds
        .iter()
        .any(|kind| !RECORD_KINDS.contains(&kind.as_str()))
    {
        return Err(invalid(snapshot, request, "record_kind"));
    }
    if relation_kinds
        .iter()
        .any(|kind| !RELATION_KINDS.contains(&kind.as_str()))
    {
        return Err(invalid(snapshot, request, "relation_kind"));
    }
    if !rank_ordered(&record_kinds, RECORD_KINDS) {
        return Err(invalid(snapshot, request, "record_kind_order"));
    }
    if !rank_ordered(&relation_kinds, RELATION_KINDS) {
        return Err(invalid(snapshot, request, "relation_kind_order"));
    }

    let direction = match object.get("direction").and_then(Value::as_str) {
        Some("outgoing") => SemanticQueryDirection::Outgoing,
        Some("incoming") => SemanticQueryDirection::Incoming,
        Some("both") => SemanticQueryDirection::Both,
        _ => return Err(invalid(snapshot, request, "direction")),
    };
    let after_id = match page.get("after_id") {
        Some(Value::Null) => None,
        Some(Value::String(value)) if !looks_numeric(value) => Some(value.clone()),
        _ => return Err(invalid(snapshot, request, "after_id")),
    };
    let page_limit = integer_in_range(page.get("limit"), 1, PAGE_MAX)
        .ok_or_else(|| invalid(snapshot, request, "page_limit"))?;
    let max_records = integer_in_range(budget.get("max_records"), 1, RECORD_BUDGET_MAX)
        .ok_or_else(|| invalid(snapshot, request, "max_records"))?;
    let max_relations = integer_in_range(budget.get("max_relations"), 1, RELATION_BUDGET_MAX)
        .ok_or_else(|| invalid(snapshot, request, "max_relations"))?;
    let max_depth = integer_in_range(budget.get("max_depth"), 0, DEPTH_BUDGET_MAX)
        .ok_or_else(|| invalid(snapshot, request, "max_depth"))?;
    let source_detail = match source.get("detail").and_then(Value::as_str) {
        Some("none") => SemanticSourceDetail::None,
        Some("identity") => SemanticSourceDetail::Identity,
        Some("span") => SemanticSourceDetail::Span,
        Some("text") => SemanticSourceDetail::Text,
        _ => return Err(invalid(snapshot, request, "source_policy")),
    };
    let include_content_digest = source
        .get("include_content_digest")
        .and_then(Value::as_bool)
        .ok_or_else(|| invalid(snapshot, request, "source_policy"))?;
    if include_content_digest && source_detail != SemanticSourceDetail::Text {
        return Err(invalid(snapshot, request, "digest_requires_text"));
    }
    if source_detail > snapshot.source_detail_ceiling
        || (include_content_digest && !snapshot.content_digest_available)
    {
        return Err(empty_response(
            snapshot,
            request,
            query_diagnostic(
                "semantic_query_source_detail_forbidden",
                Some(source_detail_name(snapshot.source_detail_ceiling)),
                Some(Value::String(source_detail_name(source_detail).to_string())),
            ),
        ));
    }

    let valid_combination = match operation {
        SemanticQueryOperation::Capabilities | SemanticQueryOperation::List => {
            subjects.is_empty() && relation_kinds.is_empty()
        }
        SemanticQueryOperation::Get => {
            !subjects.is_empty() && record_kinds.is_empty() && relation_kinds.is_empty()
        }
        SemanticQueryOperation::Relations => !subjects.is_empty() && record_kinds.is_empty(),
        SemanticQueryOperation::Explain => {
            subjects.len() == 1 && record_kinds.is_empty() && relation_kinds.is_empty()
        }
    };
    if !valid_combination {
        return Err(invalid(snapshot, request, "operation_combination"));
    }
    if operation == SemanticQueryOperation::Capabilities && !record_kinds.is_empty() {
        return Err(invalid(snapshot, request, "capability_filter"));
    }

    Ok(ValidRequest {
        operation,
        subjects,
        record_kinds,
        relation_kinds,
        direction,
        after_id,
        page_limit,
        max_records,
        max_relations,
        max_depth,
        source_detail,
        include_content_digest,
    })
}

fn capabilities_record(snapshot: &SemanticSnapshot) -> SemanticQueryRecord {
    SemanticQueryRecord {
        id: "capabilities:0".to_string(),
        kind: "capabilities".to_string(),
        name: Some("semantic introspection v1".to_string()),
        owner_id: None,
        order: 0,
        source: None,
        facts: json!({
            "model_ids": [MODEL_ID],
            "query_ids": [QUERY_ID],
            "record_kinds": RECORD_KINDS,
            "relation_kinds": RELATION_KINDS,
            "source_detail_ceiling": snapshot.source_detail_ceiling,
            "page_default": PAGE_DEFAULT,
            "page_max": PAGE_MAX,
            "budget_defaults": {
                "max_records": RECORD_BUDGET_DEFAULT,
                "max_relations": RELATION_BUDGET_DEFAULT,
                "max_depth": DEPTH_BUDGET_DEFAULT,
            },
            "budget_maxima": {
                "max_records": RECORD_BUDGET_MAX,
                "max_relations": RELATION_BUDGET_MAX,
                "max_depth": DEPTH_BUDGET_MAX,
            },
            "execution_observation": snapshot.has_execution,
            "features": [],
        }),
        redactions: Vec::new(),
    }
}

fn page_stream<T, F>(
    items: Vec<T>,
    request: &ValidRequest,
    budget_limit: usize,
    id: F,
) -> Result<PageResult<T>, ()>
where
    F: Fn(&T) -> &str,
{
    let start = if let Some(after_id) = &request.after_id {
        items
            .iter()
            .position(|item| id(item) == after_id)
            .ok_or(())?
            + 1
    } else {
        0
    };
    let mut remaining = items.into_iter().skip(start).collect::<Vec<_>>();
    let limited_by_budget = remaining.len() > budget_limit;
    let selected_count = remaining.len().min(request.page_limit.min(budget_limit));
    let unselected = remaining.split_off(selected_count);
    let selected = remaining;
    let complete = unselected.is_empty() && !limited_by_budget;
    let next_after_id = if !selected.is_empty() && !complete {
        Some(id(selected.last().expect("selected is nonempty")).to_string())
    } else {
        None
    };
    Ok(PageResult {
        selected,
        page: page_state(request, next_after_id, complete),
        limited_by_budget,
    })
}

fn traverse_relations(projection: &SemanticStaticProjection, request: &ValidRequest) -> Traversal {
    let wanted_kinds = request.relation_kinds.iter().collect::<BTreeSet<_>>();
    let mut frontier = request.subjects.iter().cloned().collect::<BTreeSet<_>>();
    let mut visited = frontier.clone();
    let mut depth_by_id = BTreeMap::new();

    for depth in 1..=request.max_depth {
        let layer = relation_layer(
            &projection.relations,
            &frontier,
            &wanted_kinds,
            request.direction,
            &depth_by_id,
        );
        if layer.is_empty() {
            break;
        }
        let mut next_frontier = BTreeSet::new();
        for relation in layer {
            depth_by_id.insert(relation.id.clone(), depth);
            if matches!(
                request.direction,
                SemanticQueryDirection::Outgoing | SemanticQueryDirection::Both
            ) && frontier.contains(&relation.from_id)
            {
                next_frontier.insert(relation.to_id.clone());
            }
            if matches!(
                request.direction,
                SemanticQueryDirection::Incoming | SemanticQueryDirection::Both
            ) && frontier.contains(&relation.to_id)
            {
                next_frontier.insert(relation.from_id.clone());
            }
        }
        next_frontier.retain(|record_id| !visited.contains(record_id));
        visited.extend(next_frontier.iter().cloned());
        frontier = next_frontier;
        if frontier.is_empty() {
            break;
        }
    }

    let depth_limited = !frontier.is_empty()
        && !relation_layer(
            &projection.relations,
            &frontier,
            &wanted_kinds,
            request.direction,
            &depth_by_id,
        )
        .is_empty();
    let relations = projection
        .relations
        .iter()
        .filter(|relation| depth_by_id.contains_key(&relation.id))
        .cloned()
        .collect();
    Traversal {
        relations,
        depth_by_id,
        depth_limited,
    }
}

fn relation_layer<'a>(
    relations: &'a [SemanticRelation],
    frontier: &BTreeSet<String>,
    wanted_kinds: &BTreeSet<&String>,
    direction: SemanticQueryDirection,
    selected: &BTreeMap<String, usize>,
) -> Vec<&'a SemanticRelation> {
    relations
        .iter()
        .filter(|relation| {
            (wanted_kinds.is_empty() || wanted_kinds.contains(&relation.kind))
                && (matches!(
                    direction,
                    SemanticQueryDirection::Outgoing | SemanticQueryDirection::Both
                ) && frontier.contains(&relation.from_id)
                    || matches!(
                        direction,
                        SemanticQueryDirection::Incoming | SemanticQueryDirection::Both
                    ) && frontier.contains(&relation.to_id))
                && !selected.contains_key(&relation.id)
        })
        .collect()
}

fn project_record(
    record: &SemanticRecord,
    projection: &SemanticStaticProjection,
    request: &ValidRequest,
) -> SemanticQueryRecord {
    let mut facts = record.facts.clone();
    let sensitive_path = match record.kind.as_str() {
        "regex_slot" => Some(("pattern", "/facts/pattern")),
        "diagnostic" => Some(("message", "/facts/message")),
        "explanation_step" => Some(("summary", "/facts/summary")),
        _ => None,
    };
    let mut redactions = record.redactions.clone();
    if request.source_detail != SemanticSourceDetail::Text
        && let Some((field, path)) = sensitive_path
    {
        facts
            .as_object_mut()
            .expect("semantic record facts are objects")
            .insert(field.to_string(), Value::Null);
        redactions = vec![path.to_string()];
    }
    SemanticQueryRecord {
        id: record.id.clone(),
        kind: record.kind.clone(),
        name: record.name.clone(),
        owner_id: record.owner_id.clone(),
        order: record.order,
        source: project_source(record.source.as_deref(), projection, request),
        facts,
        redactions,
    }
}

fn project_relation(
    relation: &SemanticRelation,
    projection: &SemanticStaticProjection,
    request: &ValidRequest,
) -> SemanticQueryRelation {
    SemanticQueryRelation {
        id: relation.id.clone(),
        kind: relation.kind.clone(),
        from_id: relation.from_id.clone(),
        to_id: relation.to_id.clone(),
        order: relation.order,
        source: project_source(relation.source.as_deref(), projection, request),
        facts: relation.facts.clone(),
        evidence_ids: relation.evidence_ids.clone(),
    }
}

fn project_source(
    source_key: Option<&str>,
    projection: &SemanticStaticProjection,
    request: &ValidRequest,
) -> Option<SemanticQuerySourceReference> {
    if request.source_detail == SemanticSourceDetail::None {
        return None;
    }
    let source = projection.source_refs.get(source_key?)?;
    Some(SemanticQuerySourceReference {
        source_id: source.source_id.clone(),
        logical_name: source.logical_name.clone(),
        span: (request.source_detail >= SemanticSourceDetail::Span).then(|| source.span.clone()),
        excerpt: (request.source_detail == SemanticSourceDetail::Text)
            .then(|| source.excerpt.clone()),
        content_digest: (request.source_detail == SemanticSourceDetail::Text
            && request.include_content_digest)
            .then(|| source.content_digest.clone()),
        provenance_ids: source.provenance_ids.clone(),
    })
}

fn query_diagnostic(
    code: &str,
    reason: Option<&str>,
    requested: Option<Value>,
) -> SemanticQueryDiagnostic {
    match code {
        "semantic_query_budget_exceeded" => SemanticQueryDiagnostic {
            code: code.to_string(),
            severity: "warning".to_string(),
            message: "Semantic query budget was reached; returning the deterministic prefix."
                .to_string(),
            fields: json!({"limit": reason}),
        },
        "semantic_query_contract_unsupported" => SemanticQueryDiagnostic {
            code: code.to_string(),
            severity: "error".to_string(),
            message: "Unsupported semantic query contract.".to_string(),
            fields: json!({
                "requested": requested.unwrap_or(Value::Null),
                "supported": [QUERY_ID],
            }),
        },
        "semantic_query_source_detail_forbidden" => SemanticQueryDiagnostic {
            code: code.to_string(),
            severity: "error".to_string(),
            message: "Requested source detail exceeds the index ceiling.".to_string(),
            fields: json!({
                "requested": requested.unwrap_or(Value::Null),
                "ceiling": reason,
            }),
        },
        _ => SemanticQueryDiagnostic {
            code: "semantic_query_invalid".to_string(),
            severity: "error".to_string(),
            message: "Invalid semantic query request.".to_string(),
            fields: json!({"reason": reason}),
        },
    }
}

fn empty_response(
    snapshot: &SemanticSnapshot,
    request: &Value,
    diagnostic: SemanticQueryDiagnostic,
) -> SemanticQueryResponse {
    let after_id = request
        .as_object()
        .and_then(|object| object.get("page"))
        .and_then(Value::as_object)
        .and_then(|page| page.get("after_id"))
        .cloned()
        .unwrap_or(Value::Null);
    SemanticQueryResponse {
        contract: QUERY_ID.to_string(),
        model: MODEL_ID.to_string(),
        ok: false,
        snapshot: snapshot.clone(),
        records: Vec::new(),
        relations: Vec::new(),
        page: SemanticQueryPageState {
            after_id,
            next_after_id: None,
            complete: true,
        },
        cost: SemanticQueryCost {
            records_examined: 0,
            relations_examined: 0,
            depth_reached: 0,
        },
        diagnostics: vec![diagnostic],
    }
}

fn invalid(snapshot: &SemanticSnapshot, request: &Value, reason: &str) -> SemanticQueryResponse {
    empty_response(
        snapshot,
        request,
        query_diagnostic("semantic_query_invalid", Some(reason), None),
    )
}

fn invalid_after_id(snapshot: &SemanticSnapshot, request: &Value) -> SemanticQueryResponse {
    invalid(snapshot, request, "after_id_not_in_primary_stream")
}

fn page_state(
    request: &ValidRequest,
    next_after_id: Option<String>,
    complete: bool,
) -> SemanticQueryPageState {
    SemanticQueryPageState {
        after_id: request
            .after_id
            .as_ref()
            .map_or(Value::Null, |value| Value::String(value.clone())),
        next_after_id,
        complete,
    }
}

fn has_exact_keys(object: &Map<String, Value>, fields: &[&str]) -> bool {
    object.len() == fields.len() && fields.iter().all(|field| object.contains_key(*field))
}

fn exact_object<'a>(value: Option<&'a Value>, fields: &[&str]) -> Option<&'a Map<String, Value>> {
    let object = value?.as_object()?;
    has_exact_keys(object, fields).then_some(object)
}

fn string_array(value: Option<&Value>) -> Option<Vec<String>> {
    value?
        .as_array()?
        .iter()
        .map(|item| item.as_str().map(str::to_string))
        .collect()
}

fn rank_ordered(values: &[String], ranks: &[&str]) -> bool {
    values.windows(2).all(|pair| {
        let left = ranks
            .iter()
            .position(|candidate| *candidate == pair[0])
            .expect("kinds were validated");
        let right = ranks
            .iter()
            .position(|candidate| *candidate == pair[1])
            .expect("kinds were validated");
        left <= right
    })
}

fn looks_numeric(value: &str) -> bool {
    !value.trim().is_empty() && value.trim().parse::<f64>().is_ok()
}

fn integer_in_range(value: Option<&Value>, minimum: usize, maximum: usize) -> Option<usize> {
    let value = usize::try_from(value?.as_u64()?).ok()?;
    (minimum..=maximum).contains(&value).then_some(value)
}

const fn source_detail_name(detail: SemanticSourceDetail) -> &'static str {
    match detail {
        SemanticSourceDetail::None => "none",
        SemanticSourceDetail::Identity => "identity",
        SemanticSourceDetail::Span => "span",
        SemanticSourceDetail::Text => "text",
    }
}
