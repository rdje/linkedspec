//! Immutable runtime projection derived from one completed typed observation.

use super::static_projection::{
    SemanticRecord, SemanticStaticProjection, canonicalize, record, relation,
};
use super::{SemanticIndexError, SemanticSnapshotState};
use crate::{
    RUNTIME_SEMANTIC_OBSERVATION_CONTRACT, RuntimeSemanticObservationEvent,
    RuntimeSemanticObservationEventKind,
};
use serde_json::{Value, json};
use std::collections::BTreeMap;

const SPEC_ID: &str = "spec:0";
const EXECUTION_ID: &str = "execution:0";

pub(super) fn build(
    static_projection: &SemanticStaticProjection,
    observation: &[RuntimeSemanticObservationEvent],
) -> Result<SemanticStaticProjection, SemanticIndexError> {
    if observation.is_empty() {
        return Err(invalid(
            "Execution observation must contain at least one event",
        ));
    }
    if static_projection.snapshot.state != SemanticSnapshotState::Compiled
        || static_projection.snapshot.has_execution
    {
        return Err(invalid(
            "Execution observations require a compiled static semantic snapshot",
        ));
    }
    for event in observation {
        validate_event(event)?;
    }

    let result_events = observation
        .iter()
        .filter(|event| event.event_kind == RuntimeSemanticObservationEventKind::RuleResult)
        .collect::<Vec<_>>();
    if result_events.len() != 1
        || observation.last().map(|event| event.event_kind)
            != Some(RuntimeSemanticObservationEventKind::RuleResult)
    {
        return Err(invalid(
            "Completed execution observation must contain exactly one final rule result",
        ));
    }
    let result_event = result_events[0];
    if result_event.status.as_deref() != Some("succeeded") {
        return Err(invalid(
            "Final rule-result observation must report succeeded status",
        ));
    }
    let Some(input_identity) = result_event.input_identity.as_deref() else {
        return Err(invalid(
            "Final rule-result observation must carry a stable input identity",
        ));
    };
    if !is_input_identity(input_identity) {
        return Err(invalid(
            "Final rule-result observation must carry a stable input identity",
        ));
    }

    let record_by_id = static_projection
        .records
        .iter()
        .map(|item| (item.id.clone(), item.clone()))
        .collect::<BTreeMap<_, _>>();
    let rule_by_name = static_projection
        .records
        .iter()
        .filter(|item| item.kind == "rule")
        .filter_map(|item| item.name.as_ref().map(|name| (name.clone(), item.clone())))
        .collect::<BTreeMap<_, _>>();
    let slot_by_key = static_projection
        .records
        .iter()
        .filter(|item| item.kind == "regex_slot")
        .filter_map(|item| {
            let owner = item
                .owner_id
                .as_ref()
                .and_then(|owner_id| record_by_id.get(owner_id))?;
            Some(((owner.name.clone()?, item.order), item.clone()))
        })
        .collect::<BTreeMap<_, _>>();
    let mut edge_for_selection = BTreeMap::new();
    for selection in static_projection
        .relations
        .iter()
        .filter(|item| item.kind == "selects_regex")
    {
        let Some(edge) = record_by_id.get(&selection.from_id) else {
            continue;
        };
        if edge.kind != "edge" {
            continue;
        }
        let Some(owner_id) = edge.owner_id.as_ref() else {
            continue;
        };
        edge_for_selection
            .entry((owner_id.clone(), selection.to_id.clone()))
            .or_insert_with(|| edge.clone());
    }

    let Some(result_rule) = rule_by_name.get(&result_event.rule_label) else {
        return Err(invalid(format!(
            "Observed result rule '{}' does not exist in the semantic index",
            result_event.rule_label
        )));
    };
    let Some(spec) = record_by_id.get(SPEC_ID) else {
        return Err(invalid("Static semantic projection has no spec record"));
    };
    if spec.facts.get("entry_rule_id").and_then(Value::as_str) != Some(result_rule.id.as_str()) {
        return Err(invalid(
            "Observed final result does not belong to the selected entry rule",
        ));
    }
    let result_shape = required_shape(result_rule, "Final result rule has no value shape")?;

    let mut projection = static_projection.clone();
    projection.snapshot.has_execution = true;
    projection.records.push(record(
        EXECUTION_ID,
        "execution",
        Some("caller observation".to_string()),
        Some(SPEC_ID.to_string()),
        0,
        None,
        json!({
            "input_identity": input_identity,
            "status": "succeeded",
            "result_shape": result_shape,
        }),
    ));

    for (order, event) in observation.iter().enumerate() {
        let (name, source, value_shape, evidence_id) = match event.event_kind {
            RuntimeSemanticObservationEventKind::RegexSlotSelected => {
                let Some(rule) = rule_by_name.get(&event.rule_label) else {
                    return Err(invalid(format!(
                        "Observed selecting rule '{}' does not exist in the semantic index",
                        event.rule_label
                    )));
                };
                let target_rule = event
                    .target_rule
                    .as_ref()
                    .expect("slot event schema was validated");
                let regex_index = event.regex_index.expect("slot event schema was validated");
                let Some(slot) = slot_by_key.get(&(target_rule.clone(), regex_index)) else {
                    return Err(invalid(format!(
                        "Observed regex slot '{target_rule}[{regex_index}]' does not exist in the semantic index"
                    )));
                };
                let Some(edge) = edge_for_selection.get(&(rule.id.clone(), slot.id.clone())) else {
                    return Err(invalid(format!(
                        "Observed selecting rule '{}' does not select regex slot '{target_rule}[{regex_index}]'",
                        event.rule_label
                    )));
                };
                (
                    "slot selected",
                    slot.source.clone(),
                    required_shape(edge, "Observed selection edge has no value shape")?,
                    slot.id.clone(),
                )
            }
            RuntimeSemanticObservationEventKind::RuleResult => {
                if order + 1 != observation.len() {
                    return Err(invalid(
                        "Rule-result event must be the final observation event",
                    ));
                }
                (
                    "rule result",
                    result_rule.source.clone(),
                    result_shape.clone(),
                    result_rule.id.clone(),
                )
            }
        };
        let event_id = format!("event:{EXECUTION_ID}:{order}");
        projection.records.push(record(
            &event_id,
            "event",
            Some(name.to_string()),
            Some(EXECUTION_ID.to_string()),
            order,
            source.clone(),
            json!({
                "event_kind": event.event_kind,
                "position": event.position,
                "value_shape": value_shape,
            }),
        ));
        projection.relations.push(relation(
            "observed_as",
            EXECUTION_ID,
            &event_id,
            order,
            source,
            vec![evidence_id],
        ));
    }

    canonicalize(&mut projection);
    Ok(projection)
}

fn validate_event(event: &RuntimeSemanticObservationEvent) -> Result<(), SemanticIndexError> {
    if event.contract_id != RUNTIME_SEMANTIC_OBSERVATION_CONTRACT {
        return Err(invalid(
            "Execution observation event contract is unsupported",
        ));
    }
    if event.rule_label.is_empty() {
        return Err(invalid("Execution observation rule label is missing"));
    }
    match event.event_kind {
        RuntimeSemanticObservationEventKind::RegexSlotSelected => {
            if event.target_rule.as_deref().is_none_or(str::is_empty) {
                return Err(invalid("Regex-slot observation target rule is missing"));
            }
            if event.regex_index.is_none() {
                return Err(invalid("Regex-slot observation index is missing"));
            }
            if event.input_identity.is_some() || event.status.is_some() {
                return Err(invalid(
                    "Regex-slot observation cannot carry result identity or status",
                ));
            }
        }
        RuntimeSemanticObservationEventKind::RuleResult => {
            if event.target_rule.is_some() || event.regex_index.is_some() {
                return Err(invalid(
                    "Rule-result observation cannot carry regex-slot identity",
                ));
            }
        }
    }
    Ok(())
}

fn required_shape(record: &SemanticRecord, message: &str) -> Result<Value, SemanticIndexError> {
    record
        .facts
        .get("value_shape")
        .filter(|shape| shape.is_object())
        .cloned()
        .ok_or_else(|| invalid(message))
}

fn is_input_identity(value: &str) -> bool {
    value.strip_prefix("input:sha256:").is_some_and(|digest| {
        digest.len() == 64
            && digest
                .bytes()
                .all(|byte| byte.is_ascii_digit() || (b'a'..=b'f').contains(&byte))
    })
}

fn invalid(message: impl Into<String>) -> SemanticIndexError {
    SemanticIndexError::new(
        "execution_observation",
        "semantic_index_invalid_observation",
        message,
    )
}
