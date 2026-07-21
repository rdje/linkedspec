//! Clone-safe static `linkedspec-semantic-model-v1` lowering.

use super::{
    SemanticEntrySelection, SemanticGeneratedPlanInput, SemanticIndexError, SemanticSnapshot,
    SemanticSourceMap, SemanticSourceSpan, call_projection,
};
use linkedspec_core::ast::{BodyElement, BodyElementKind, RuleMode, SpecFile};
use linkedspec_core::error::PortableDiagnostic;
use linkedspec_core::expr::{Arg, CodeBlock, Expr};
use linkedspec_core::types::{CompiledRule, CompiledSpec};
use serde::Serialize;
use serde_json::{Value, json};
use std::cmp::Ordering;
use std::collections::{BTreeMap, BTreeSet};

const SPEC_ID: &str = "spec:0";
const SOURCE_ID: &str = "source:0";

pub(super) const RECORD_KINDS: &[&str] = &[
    "capabilities",
    "spec",
    "source",
    "rule",
    "regex_slot",
    "edge",
    "lifecycle",
    "function",
    "helper",
    "binding",
    "call",
    "staged_artifact",
    "generated_artifact",
    "diagnostic",
    "decision",
    "execution",
    "event",
    "explanation_step",
];

pub(super) const RELATION_KINDS: &[&str] = &[
    "declares",
    "contains",
    "depends_on",
    "dispatches_to",
    "selects_regex",
    "calls",
    "resolves_to",
    "reads",
    "writes",
    "consumes",
    "produces",
    "lowered_from",
    "staged_by",
    "generated_as",
    "diagnoses",
    "observed_as",
    "explained_by",
];

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub(crate) struct SemanticSourceReference {
    pub(crate) source_id: String,
    pub(crate) logical_name: String,
    pub(crate) span: SemanticSourceSpan,
    pub(crate) excerpt: String,
    pub(crate) content_digest: String,
    pub(crate) provenance_ids: Vec<String>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub(crate) struct SemanticRecord {
    pub(crate) id: String,
    pub(crate) kind: String,
    pub(crate) name: Option<String>,
    pub(crate) owner_id: Option<String>,
    pub(crate) order: usize,
    pub(crate) source: Option<String>,
    pub(crate) facts: Value,
    pub(crate) redactions: Vec<String>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub(crate) struct SemanticRelation {
    pub(crate) id: String,
    pub(crate) kind: String,
    pub(crate) from_id: String,
    pub(crate) to_id: String,
    pub(crate) order: usize,
    pub(crate) source: Option<String>,
    pub(crate) facts: Value,
    pub(crate) evidence_ids: Vec<String>,
}

#[derive(Debug, Clone, PartialEq, Serialize)]
pub(crate) struct SemanticStaticProjection {
    pub(crate) snapshot: SemanticSnapshot,
    pub(crate) source_refs: BTreeMap<String, SemanticSourceReference>,
    pub(crate) records: Vec<SemanticRecord>,
    pub(crate) relations: Vec<SemanticRelation>,
}

#[derive(Debug, Clone, Copy)]
struct SourceRange {
    start: usize,
    end: usize,
}

#[derive(Debug)]
struct ScannedRule<'a> {
    label: &'a str,
    header: SourceRange,
    members: Vec<ScannedMember<'a>>,
}

#[derive(Debug)]
struct ScannedMember<'a> {
    range: SourceRange,
    regex: Option<ScannedRegex<'a>>,
    edges: Vec<ScannedEdge<'a>>,
    lifecycle: Option<&'a str>,
}

#[derive(Debug)]
struct ScannedRegex<'a> {
    pattern: &'a str,
    flags: String,
}

#[derive(Debug)]
struct ScannedEdge<'a> {
    target: &'a str,
    target_index: Option<usize>,
}

#[derive(Debug)]
struct EdgeProjection<'a> {
    source: SourceRange,
    ownership: &'static str,
    target: &'a str,
    target_index: Option<usize>,
    has_block: bool,
    value_shape: Value,
}

pub(super) struct BuildInput<'a> {
    pub(super) source_text: &'a str,
    pub(super) source_map: &'a SemanticSourceMap,
    pub(super) logical_name: &'a str,
    pub(super) content_digest: &'a str,
    pub(super) snapshot: SemanticSnapshot,
    pub(super) parsed: Option<&'a SpecFile>,
    pub(super) compiled: Option<&'a CompiledSpec>,
    pub(super) diagnostic: Option<&'a PortableDiagnostic>,
    pub(super) entry_selection: Option<&'a SemanticEntrySelection>,
    pub(super) generated_plan: Option<&'a SemanticGeneratedPlanInput>,
}

pub(super) fn build(input: BuildInput<'_>) -> Result<SemanticStaticProjection, SemanticIndexError> {
    let context = ProjectionContext {
        source_text: input.source_text,
        source_map: input.source_map,
        logical_name: input.logical_name,
        content_digest: input.content_digest,
    };
    let mut projection = if let (Some(parsed), Some(compiled)) = (input.parsed, input.compiled) {
        build_compiled(
            &context,
            input.snapshot,
            parsed,
            compiled,
            input.entry_selection,
            input.generated_plan,
        )?
    } else {
        build_failed(&context, input.snapshot, input.parsed, input.diagnostic)?
    };
    canonicalize(&mut projection);
    Ok(projection)
}

struct ProjectionContext<'a> {
    source_text: &'a str,
    source_map: &'a SemanticSourceMap,
    logical_name: &'a str,
    content_digest: &'a str,
}

fn build_compiled(
    context: &ProjectionContext<'_>,
    snapshot: SemanticSnapshot,
    parsed: &SpecFile,
    compiled: &CompiledSpec,
    entry_selection: Option<&SemanticEntrySelection>,
    generated_plan: Option<&SemanticGeneratedPlanInput>,
) -> Result<SemanticStaticProjection, SemanticIndexError> {
    let scans = scan_rules(context.source_text, parsed)?;
    let scans_by_label = scans
        .iter()
        .map(|scan| (scan.label, scan))
        .collect::<BTreeMap<_, _>>();
    let mut projection = SemanticStaticProjection {
        snapshot,
        source_refs: BTreeMap::new(),
        records: Vec::new(),
        relations: Vec::new(),
    };
    let definition_order = parsed
        .rules
        .iter()
        .map(|rule| rule_id(&rule.header.label))
        .collect::<Vec<_>>();
    let compiled_order = compiled
        .rules
        .iter()
        .map(|rule| rule_id(&rule.label))
        .collect::<Vec<_>>();
    let entry_rule_id = entry_selection.map(|selection| rule_id(&selection.label));
    let entry_basis = entry_selection.map(|selection| neutral_entry_basis(&selection.basis));

    projection.records.push(record(
        SPEC_ID,
        "spec",
        Some(spec_name(context.logical_name)),
        None,
        0,
        None,
        json!({
            "definition_order": definition_order,
            "compiled_rule_order": compiled_order,
            "entry_rule_id": entry_rule_id,
            "entry_selection_basis": entry_basis,
        }),
    ));
    projection.records.push(source_record());

    let mut record_sources = BTreeMap::<String, Option<String>>::new();
    for (rule_order, compiled_rule) in compiled.rules.iter().enumerate() {
        let parsed_rule = parsed
            .rules
            .iter()
            .find(|rule| rule.header.label == compiled_rule.label)
            .ok_or_else(|| {
                correlation_error(
                    "compiled rule has no parsed source owner",
                    &compiled_rule.label,
                )
            })?;
        let scan = scans_by_label
            .get(compiled_rule.label.as_str())
            .copied()
            .ok_or_else(|| {
                correlation_error(
                    "compiled rule has no scanned source owner",
                    &compiled_rule.label,
                )
            })?;
        let id = rule_id(&compiled_rule.label);
        let header_source = register_source(&mut projection, context, &id, scan.header)?;
        record_sources.insert(id.clone(), Some(header_source.clone()));

        let repetition = neutral_repetition(&parsed_rule.header.mode);
        let (rep_min, rep_max) = neutral_bounds(&parsed_rule.header.mode);
        let edges = project_edges(scan, compiled_rule)?;
        let lifecycles = project_lifecycles(scan, compiled_rule);
        let rule_shape = rule_value_shape(repetition, &edges, &lifecycles);
        projection.records.push(record(
            &id,
            "rule",
            Some(compiled_rule.label.clone()),
            Some(SPEC_ID.to_string()),
            rule_order,
            Some(header_source),
            json!({
                "family": if parsed_rule.header.mode.is_and() { "and" } else { "or" },
                "cursor_policy": if parsed_rule.header.mode.is_and() { "contiguous" } else { "seek" },
                "is_entry_marker": parsed_rule.header.is_top,
                "is_repetition": repetition,
                "rep_min": rep_min,
                "rep_max": rep_max,
                "edge_ownership": rule_edge_ownership(&edges),
                "value_shape": rule_shape,
            }),
        ));

        let regex_slots = project_regex_slots(scan, compiled_rule)?;
        for (slot_order, (member, regex)) in regex_slots.iter().enumerate() {
            let slot_id = format!("regex:{id}:{slot_order}");
            let source = register_source(&mut projection, context, &slot_id, member.range)?;
            record_sources.insert(slot_id.clone(), Some(source.clone()));
            projection.records.push(record(
                &slot_id,
                "regex_slot",
                None,
                Some(id.clone()),
                slot_order,
                Some(source),
                json!({
                    "authored_index": slot_order,
                    "pattern": regex.pattern,
                    "flags": regex.flags,
                    "combined_owner_ids": [id.clone()],
                    "target_shape": value_shape("regex_slot"),
                }),
            ));
        }

        for (edge_order, edge) in edges.iter().enumerate() {
            let edge_id = format!("edge:{id}:{edge_order}");
            let source = register_source(&mut projection, context, &edge_id, edge.source)?;
            record_sources.insert(edge_id.clone(), Some(source.clone()));
            projection.records.push(record(
                &edge_id,
                "edge",
                None,
                Some(id.clone()),
                edge_order,
                Some(source),
                json!({
                    "ownership": edge.ownership,
                    "source_form": if edge.target_index.is_some() { "indexed" } else { "direct" },
                    "has_block": edge.has_block,
                    "fluent_call_ids": [],
                    "value_shape": edge.value_shape,
                    "target_shape": value_shape(if edge.target_index.is_some() { "regex_slot" } else { "rule" }),
                }),
            ));
        }

        for (lifecycle_order, (member, marker, shape)) in lifecycles.iter().enumerate() {
            let marker_order = lifecycles[..lifecycle_order]
                .iter()
                .filter(|(_, prior, _)| prior == marker)
                .count();
            let lifecycle_id = format!("lifecycle:{id}:{marker}:{marker_order}");
            let source = register_source(&mut projection, context, &lifecycle_id, member.range)?;
            record_sources.insert(lifecycle_id.clone(), Some(source.clone()));
            projection.records.push(record(
                &lifecycle_id,
                "lifecycle",
                Some((*marker).to_string()),
                Some(id.clone()),
                marker_order,
                Some(source),
                json!({
                    "marker": marker,
                    "whole_rule_return": *marker == "E",
                    "value_shape": shape,
                }),
            ));
        }

        projection.relations.push(relation(
            "declares",
            SPEC_ID,
            &id,
            rule_order,
            None,
            Vec::new(),
        ));
        let mut contains_order = 0;
        for slot_order in 0..regex_slots.len() {
            let slot_id = format!("regex:{id}:{slot_order}");
            projection.relations.push(relation(
                "contains",
                &id,
                &slot_id,
                contains_order,
                record_sources.get(&slot_id).cloned().flatten(),
                Vec::new(),
            ));
            contains_order += 1;
        }
        for edge_order in 0..edges.len() {
            let edge_id = format!("edge:{id}:{edge_order}");
            projection.relations.push(relation(
                "contains",
                &id,
                &edge_id,
                contains_order,
                record_sources.get(&edge_id).cloned().flatten(),
                Vec::new(),
            ));
            contains_order += 1;
        }
        for (lifecycle_order, (_, marker, _)) in lifecycles.iter().enumerate() {
            let marker_order = lifecycles[..lifecycle_order]
                .iter()
                .filter(|(_, prior, _)| prior == marker)
                .count();
            let lifecycle_id = format!("lifecycle:{id}:{marker}:{marker_order}");
            projection.relations.push(relation(
                "contains",
                &id,
                &lifecycle_id,
                contains_order,
                record_sources.get(&lifecycle_id).cloned().flatten(),
                Vec::new(),
            ));
            contains_order += 1;
        }

        for (edge_order, edge) in edges.iter().enumerate() {
            let edge_id = format!("edge:{id}:{edge_order}");
            let target_rule_id = rule_id(edge.target);
            let source = record_sources.get(&edge_id).cloned().flatten();
            if !(target_rule_id == id && edge.target_index.is_some()) {
                projection.relations.push(relation(
                    "dispatches_to",
                    &edge_id,
                    &target_rule_id,
                    edge_order,
                    source.clone(),
                    Vec::new(),
                ));
            }
            if let Some(slot) = edge.target_index {
                let target_slot_id = format!("regex:{target_rule_id}:{slot}");
                projection.relations.push(relation(
                    "selects_regex",
                    &edge_id,
                    &target_slot_id,
                    edge_order,
                    source,
                    Vec::new(),
                ));
            }
        }
    }

    projection.relations.push(relation(
        "contains",
        SPEC_ID,
        SOURCE_ID,
        0,
        None,
        Vec::new(),
    ));

    call_projection::extend(call_projection::BuildInput {
        source_text: context.source_text,
        source_map: context.source_map,
        logical_name: context.logical_name,
        content_digest: context.content_digest,
        parsed,
        compiled,
        entry_selection,
        generated_plan,
        projection: &mut projection,
    })?;

    if parsed.functions.is_empty()
        && compiled.rules.len() > 1
        && let Some(selection) = entry_selection
    {
        add_entry_explanation(&mut projection, &record_sources, selection, &compiled.rules);
    }

    Ok(projection)
}

fn build_failed(
    context: &ProjectionContext<'_>,
    snapshot: SemanticSnapshot,
    parsed: Option<&SpecFile>,
    diagnostic: Option<&PortableDiagnostic>,
) -> Result<SemanticStaticProjection, SemanticIndexError> {
    let mut projection = SemanticStaticProjection {
        snapshot,
        source_refs: BTreeMap::new(),
        records: Vec::new(),
        relations: Vec::new(),
    };
    let scans = if let Some(parsed) = parsed {
        scan_rules(context.source_text, parsed)?
    } else {
        Vec::new()
    };
    let rules = parsed.map(|spec| spec.rules.as_slice()).unwrap_or_default();
    projection.records.push(record(
        SPEC_ID,
        "spec",
        Some(spec_name(context.logical_name)),
        None,
        0,
        None,
        json!({
            "definition_order": rules.iter().map(|rule| rule_id(&rule.header.label)).collect::<Vec<_>>(),
            "compiled_rule_order": [],
            "entry_rule_id": null,
            "entry_selection_basis": null,
        }),
    ));
    projection.records.push(source_record());

    let raw = diagnostic.cloned().unwrap_or_else(|| {
        PortableDiagnostic::new(
            "semantic_index_compilation_failed",
            "compile_source",
            "Spec compilation failed.",
        )
    });
    let normalized = normalize_failed_diagnostic(&raw);
    let failed_label = normalized
        .rule_label
        .as_deref()
        .or_else(|| rules.first().map(|rule| rule.header.label.as_str()));
    let failed_rule_id = failed_label.map(rule_id);
    let failed_scan = failed_label.and_then(|label| scans.iter().find(|scan| scan.label == label));

    for (order, rule) in rules.iter().enumerate() {
        let id = rule_id(&rule.header.label);
        let scan = scans.iter().find(|scan| scan.label == rule.header.label);
        let source = if let Some(scan) = scan {
            Some(register_source(&mut projection, context, &id, scan.header)?)
        } else {
            None
        };
        let has_edge = rule.body.iter().any(|element| {
            matches!(
                element.kind,
                BodyElementKind::ActionEdge { .. }
                    | BodyElementKind::BlindEdge { .. }
                    | BodyElementKind::BareEdge { .. }
            )
        });
        projection.records.push(record(
            &id,
            "rule",
            Some(rule.header.label.clone()),
            Some(SPEC_ID.to_string()),
            order,
            source,
            json!({
                "family": if rule.header.mode.is_and() { "and" } else { "or" },
                "cursor_policy": if rule.header.mode.is_and() { "contiguous" } else { "seek" },
                "is_entry_marker": rule.header.is_top,
                "is_repetition": neutral_repetition(&rule.header.mode),
                "rep_min": neutral_bounds(&rule.header.mode).0,
                "rep_max": neutral_bounds(&rule.header.mode).1,
                "edge_ownership": if has_edge { if rule.header.mode.is_and() { "blind" } else { "action" } } else { "none" },
                "value_shape": value_shape("unknown"),
            }),
        ));
    }

    let diagnostic_id = "diagnostic:compile:0";
    let diagnostic_range = normalized
        .target
        .as_deref()
        .and_then(|target| failed_scan.and_then(|scan| member_for_target(scan, target)))
        .map(|member| member.range);
    let diagnostic_source = if let Some(range) = diagnostic_range {
        Some(register_source(
            &mut projection,
            context,
            diagnostic_id,
            range,
        )?)
    } else {
        None
    };
    projection.records.push(record(
        diagnostic_id,
        "diagnostic",
        Some(normalized.code.clone()),
        Some(SPEC_ID.to_string()),
        0,
        diagnostic_source.clone(),
        json!({
            "code": normalized.code,
            "stage": normalized.stage,
            "severity": "error",
            "message": normalized.message,
            "fields": normalized.fields,
        }),
    ));

    projection.relations.push(relation(
        "contains",
        SPEC_ID,
        SOURCE_ID,
        0,
        None,
        Vec::new(),
    ));
    projection.relations.push(relation(
        "contains",
        SPEC_ID,
        diagnostic_id,
        1,
        diagnostic_source.clone(),
        Vec::new(),
    ));

    if normalized.code == "unknown_rule_reference"
        && let (Some(label), Some(rule_id), Some(target)) =
            (failed_label, failed_rule_id, normalized.target.as_deref())
    {
        let decision_id = format!("decision:compile:{rule_id}");
        let explanation_id = format!("explanation:{decision_id}:0");
        projection.records.push(record(
            &decision_id,
            "decision",
            Some(format!("compile rule {label}")),
            Some(rule_id.clone()),
            0,
            diagnostic_source.clone(),
            json!({"decision_kind": "dependency_resolution", "outcome": diagnostic_id}),
        ));
        projection.records.push(record(
            &explanation_id,
            "explanation_step",
            None,
            Some(decision_id.clone()),
            0,
            diagnostic_source.clone(),
            json!({
                "rule_code": "dependency_target_missing",
                "summary": format!("The authored dependency {target} has no declared rule."),
                "input_ids": [rule_id.clone()],
                "output_fact": {
                    "record_id": decision_id,
                    "path": "/facts/outcome",
                    "value": diagnostic_id,
                },
            }),
        ));
        projection.relations.push(relation(
            "diagnoses",
            diagnostic_id,
            &rule_id,
            0,
            diagnostic_source.clone(),
            Vec::new(),
        ));
        projection.relations.push(relation(
            "explained_by",
            &decision_id,
            &explanation_id,
            0,
            diagnostic_source,
            vec![diagnostic_id.to_string()],
        ));
    }

    Ok(projection)
}

struct NormalizedFailure {
    code: String,
    stage: String,
    message: String,
    fields: Value,
    rule_label: Option<String>,
    target: Option<String>,
}

fn normalize_failed_diagnostic(diagnostic: &PortableDiagnostic) -> NormalizedFailure {
    let rule_label = string_field(diagnostic, "rule_label");
    let target =
        string_field(diagnostic, "target").or_else(|| string_field(diagnostic, "target_rule"));
    if matches!(
        diagnostic.code.as_str(),
        "bare_edge_target_undefined" | "regex_slot_identity_invalid"
    ) && let (Some(rule_label), Some(target)) = (rule_label.clone(), target.clone())
    {
        return NormalizedFailure {
            code: "unknown_rule_reference".to_string(),
            stage: "compile".to_string(),
            message: format!("Rule {rule_label} references unknown rule {target}."),
            fields: json!({
                "rule_id": rule_id(&rule_label),
                "missing_rule_id": rule_id(&target),
            }),
            rule_label: Some(rule_label),
            target: Some(target),
        };
    }
    NormalizedFailure {
        code: diagnostic.code.clone(),
        stage: diagnostic.stage.clone(),
        message: diagnostic.message.clone(),
        fields: Value::Object(diagnostic.fields.clone().into_iter().collect()),
        rule_label,
        target,
    }
}

fn string_field(diagnostic: &PortableDiagnostic, name: &str) -> Option<String> {
    diagnostic
        .field(name)
        .and_then(Value::as_str)
        .map(ToOwned::to_owned)
}

fn project_edges<'a>(
    scan: &'a ScannedRule<'a>,
    compiled: &'a CompiledRule,
) -> Result<Vec<EdgeProjection<'a>>, SemanticIndexError> {
    let scanned = scan
        .members
        .iter()
        .flat_map(|member| member.edges.iter().map(move |edge| (member.range, edge)))
        .collect::<Vec<_>>();
    let authority_count = compiled.acode_dispatch.len() + compiled.bcode_dispatch.len();
    if scanned.len() != authority_count {
        return Err(
            correlation_error("authored and compiled edge counts differ", &compiled.label)
                .with_field("authored_edges", scanned.len())
                .with_field("compiled_edges", authority_count),
        );
    }
    let mut result = Vec::with_capacity(authority_count);
    for ((source, scanned), edge) in scanned.iter().zip(&compiled.acode_dispatch) {
        if scanned.target != edge.child_label {
            return Err(correlation_error(
                "authored and compiled action-edge targets differ",
                &compiled.label,
            ));
        }
        result.push(EdgeProjection {
            source: *source,
            ownership: "action",
            target: scanned.target,
            target_index: scanned.target_index,
            has_block: edge.code.is_some(),
            value_shape: block_return_shape(edge.code.as_ref()),
        });
    }
    for ((source, scanned), edge) in scanned
        .iter()
        .skip(compiled.acode_dispatch.len())
        .zip(&compiled.bcode_dispatch)
    {
        if scanned.target != edge.child_label {
            return Err(correlation_error(
                "authored and compiled blind-edge targets differ",
                &compiled.label,
            ));
        }
        result.push(EdgeProjection {
            source: *source,
            ownership: "blind",
            target: scanned.target,
            target_index: None,
            has_block: edge.code.is_some(),
            value_shape: block_return_shape(edge.code.as_ref()),
        });
    }
    Ok(result)
}

fn project_regex_slots<'a>(
    scan: &'a ScannedRule<'a>,
    compiled: &CompiledRule,
) -> Result<Vec<(&'a ScannedMember<'a>, &'a ScannedRegex<'a>)>, SemanticIndexError> {
    let slots = scan
        .members
        .iter()
        .filter_map(|member| {
            let regex = member.regex.as_ref()?;
            let retained = member.edges.is_empty()
                || member
                    .edges
                    .iter()
                    .any(|edge| edge.target == compiled.label && edge.target_index.is_some());
            retained.then_some((member, regex))
        })
        .collect::<Vec<_>>();
    for (index, (_, regex)) in slots.iter().enumerate() {
        if compiled.regex_patterns.get(index).map(String::as_str) != Some(regex.pattern) {
            return Err(correlation_error(
                "authored and compiled regex-slot identities differ",
                &compiled.label,
            )
            .with_field("slot", index));
        }
    }
    Ok(slots)
}

fn project_lifecycles<'a>(
    scan: &'a ScannedRule<'a>,
    compiled: &'a CompiledRule,
) -> Vec<(&'a ScannedMember<'a>, &'a str, Value)> {
    scan.members
        .iter()
        .filter_map(|member| {
            let marker = member.lifecycle?;
            let block = lifecycle_block(compiled, marker);
            Some((member, marker, block_return_shape(block)))
        })
        .collect()
}

fn lifecycle_block<'a>(compiled: &'a CompiledRule, marker: &str) -> Option<&'a CodeBlock> {
    match marker {
        "I" => compiled.preamble.as_ref(),
        "LS" => compiled.lscode.as_ref(),
        "LE" => compiled.lecode.as_ref(),
        "E" => compiled.ecode.as_ref(),
        "EX" => compiled.excode.as_ref(),
        "IT" => compiled.itcode.as_ref(),
        "LX" => compiled.lxcode.as_ref(),
        _ => None,
    }
}

fn scan_rules<'a>(
    source: &'a str,
    parsed: &'a SpecFile,
) -> Result<Vec<ScannedRule<'a>>, SemanticIndexError> {
    let lines = line_ranges(source);
    parsed
        .rules
        .iter()
        .map(|rule| {
            let header = trimmed_line_range(source, &lines, rule.header.line)?;
            let mut member_lines = Vec::new();
            let mut seen = BTreeSet::new();
            for element in &rule.body {
                if seen.insert(element.line) {
                    member_lines.push(element.line);
                }
            }
            let mut members = Vec::with_capacity(member_lines.len());
            for line in member_lines {
                let elements = rule
                    .body
                    .iter()
                    .filter(|element| element.line == line)
                    .collect::<Vec<_>>();
                let range = member_range(source, &lines, line)?;
                members.push(scan_member(source, range, &elements));
            }
            Ok(ScannedRule {
                label: rule.header.label.as_str(),
                header,
                members,
            })
        })
        .collect()
}

fn scan_member<'a>(
    source: &'a str,
    range: SourceRange,
    elements: &[&'a BodyElement],
) -> ScannedMember<'a> {
    let text = &source[range.start..range.end];
    let regex = elements.iter().find_map(|element| match &element.kind {
        BodyElementKind::Regex { pattern } => Some(ScannedRegex {
            pattern,
            flags: leading_regex_flags(text),
        }),
        _ => None,
    });
    let mut edges = Vec::new();
    let mut lifecycle = None;
    for element in elements {
        match &element.kind {
            BodyElementKind::ActionEdge { targets, .. } => {
                edges.extend(targets.iter().map(|target| ScannedEdge {
                    target: target.label.as_str(),
                    target_index: explicit_target_index(text, &target.label, target.index),
                }));
            }
            BodyElementKind::BlindEdge { target, index, .. } => {
                edges.push(ScannedEdge {
                    target,
                    target_index: *index,
                });
            }
            BodyElementKind::BareEdge { targets, .. } => {
                edges.extend(targets.iter().map(|target| ScannedEdge {
                    target: target.label.as_str(),
                    target_index: target.index,
                }));
            }
            BodyElementKind::CodeBlock {
                lifecycle: marker, ..
            }
            | BodyElementKind::LifecycleMarker { marker } => lifecycle = Some(marker.as_str()),
            _ => {}
        }
    }
    ScannedMember {
        range,
        regex,
        edges,
        lifecycle,
    }
}

fn line_ranges(source: &str) -> Vec<SourceRange> {
    let mut result = Vec::new();
    let mut start = 0;
    for (index, byte) in source.bytes().enumerate() {
        if byte == b'\n' {
            result.push(SourceRange { start, end: index });
            start = index + 1;
        }
    }
    if start < source.len() || source.is_empty() {
        result.push(SourceRange {
            start,
            end: source.len(),
        });
    }
    result
}

fn trimmed_line_range(
    source: &str,
    lines: &[SourceRange],
    line: usize,
) -> Result<SourceRange, SemanticIndexError> {
    let raw = lines.get(line.saturating_sub(1)).copied().ok_or_else(|| {
        correlation_error("parsed line is outside captured source", &line.to_string())
    })?;
    let text = &source[raw.start..raw.end];
    let start = text.len() - text.trim_start().len();
    let end = text.trim_end().len();
    Ok(SourceRange {
        start: raw.start + start,
        end: raw.start + end,
    })
}

fn member_range(
    source: &str,
    lines: &[SourceRange],
    line: usize,
) -> Result<SourceRange, SemanticIndexError> {
    let start_line = trimmed_line_range(source, lines, line)?;
    let mut depth = 0isize;
    let mut quote = None;
    let mut escaped = false;
    let mut regex = source[start_line.start..].starts_with('/');
    let mut last_non_whitespace = start_line.start;
    for (relative, character) in source[start_line.start..].char_indices() {
        let absolute = start_line.start + relative;
        if character == '\n' && quote.is_none() && !regex && depth == 0 {
            return Ok(SourceRange {
                start: start_line.start,
                end: last_non_whitespace,
            });
        }
        if !character.is_whitespace() {
            last_non_whitespace = absolute + character.len_utf8();
        }
        if regex {
            if escaped {
                escaped = false;
            } else if character == '\\' {
                escaped = true;
            } else if character == '/' && absolute != start_line.start {
                regex = false;
            }
            continue;
        }
        if let Some(active) = quote {
            if escaped {
                escaped = false;
            } else if character == '\\' {
                escaped = true;
            } else if character == active {
                quote = None;
            }
            continue;
        }
        if matches!(character, '\'' | '"') {
            quote = Some(character);
            continue;
        }
        match character {
            '(' | '[' | '{' => depth += 1,
            ')' | ']' | '}' => depth -= 1,
            _ => {}
        }
    }
    Ok(SourceRange {
        start: start_line.start,
        end: last_non_whitespace,
    })
}

fn leading_regex_flags(text: &str) -> String {
    if !text.starts_with('/') {
        return String::new();
    }
    let mut escaped = false;
    for (index, character) in text.char_indices().skip(1) {
        if escaped {
            escaped = false;
        } else if character == '\\' {
            escaped = true;
        } else if character == '/' {
            return text[index + 1..]
                .chars()
                .take_while(|value| value.is_ascii_alphabetic())
                .collect();
        }
    }
    String::new()
}

fn explicit_target_index(text: &str, label: &str, expected: usize) -> Option<usize> {
    let search_start = text
        .find("->")
        .or_else(|| text.find("=>"))
        .map(|index| index + 2)
        .unwrap_or(0);
    let relative = text[search_start..].find(label)?;
    let after_label = search_start + relative + label.len();
    let rest = text[after_label..].trim_start();
    let body = rest.strip_prefix('[')?;
    let close = body.find(']')?;
    body[..close]
        .trim()
        .parse::<usize>()
        .ok()
        .filter(|value| *value == expected)
}

fn member_for_target<'a>(scan: &'a ScannedRule<'a>, target: &str) -> Option<&'a ScannedMember<'a>> {
    scan.members
        .iter()
        .find(|member| member.edges.iter().any(|edge| edge.target == target))
}

fn add_entry_explanation(
    projection: &mut SemanticStaticProjection,
    record_sources: &BTreeMap<String, Option<String>>,
    selection: &SemanticEntrySelection,
    compiled_rules: &[CompiledRule],
) {
    let selected_rule_id = rule_id(&selection.label);
    let source = record_sources.get(&selected_rule_id).cloned().flatten();
    let basis = neutral_entry_basis(&selection.basis);
    let decision_id = "decision:entry:spec:0";
    projection.records.push(record(
        decision_id,
        "decision",
        Some("entry selection".to_string()),
        Some(SPEC_ID.to_string()),
        0,
        source.clone(),
        json!({"decision_kind": "entry_selection", "outcome": selected_rule_id}),
    ));
    let first_id = format!("explanation:{decision_id}:0");
    let explicit = selection.basis == "explicit_selector";
    projection.records.push(record(
        &first_id,
        "explanation_step",
        None,
        Some(decision_id.to_string()),
        0,
        source.clone(),
        json!({
            "rule_code": if explicit { "entry_explicit_selector" } else { "entry_explicit_selector_absent" },
            "summary": if explicit {
                format!("The caller selected {}.", selection.label)
            } else {
                "No caller selector was supplied.".to_string()
            },
            "input_ids": [SPEC_ID],
            "output_fact": {"record_id": SPEC_ID, "path": "/facts/entry_selection_basis", "value": basis},
        }),
    ));
    let second_id = format!("explanation:{decision_id}:1");
    let (rule_code, summary) = match basis {
        "first_marker" => (
            "entry_first_marker",
            format!(
                "The first authored entry marker selects {}.",
                selection.label
            ),
        ),
        "first_rule" => (
            "entry_first_rule",
            format!("The first authored rule selects {}.", selection.label),
        ),
        _ => (
            "entry_explicit_rule",
            format!("The explicit selector resolves to {}.", selection.label),
        ),
    };
    projection.records.push(record(
        &second_id,
        "explanation_step",
        None,
        Some(decision_id.to_string()),
        1,
        source.clone(),
        json!({
            "rule_code": rule_code,
            "summary": summary,
            "input_ids": [selected_rule_id.clone()],
            "output_fact": {"record_id": SPEC_ID, "path": "/facts/entry_rule_id", "value": selected_rule_id},
        }),
    ));
    projection.relations.push(relation(
        "explained_by",
        decision_id,
        &first_id,
        0,
        source.clone(),
        vec![rule_id(&selection.label)],
    ));
    projection.relations.push(relation(
        "explained_by",
        decision_id,
        &second_id,
        1,
        source,
        vec![rule_id(&selection.label)],
    ));
    debug_assert!(
        compiled_rules
            .iter()
            .any(|rule| rule.label == selection.label)
    );
}

fn rule_value_shape(
    repetition: bool,
    edges: &[EdgeProjection<'_>],
    lifecycles: &[(&ScannedMember<'_>, &str, Value)],
) -> Value {
    if let Some((_, _, shape)) = lifecycles
        .iter()
        .find(|(_, marker, shape)| *marker == "E" && shape_kind(shape) != "unknown")
    {
        return shape.clone();
    }
    let element = edges
        .iter()
        .find(|edge| shape_kind(&edge.value_shape) != "unknown")
        .map(|edge| edge.value_shape.clone())
        .unwrap_or_else(|| value_shape("unknown"));
    if repetition {
        array_shape(element)
    } else {
        element
    }
}

fn block_return_shape(block: Option<&CodeBlock>) -> Value {
    block
        .and_then(|block| {
            block
                .statements
                .iter()
                .find_map(|statement| return_shape(&statement.expr))
        })
        .unwrap_or_else(|| value_shape("unknown"))
}

fn return_shape(expression: &Expr) -> Option<Value> {
    match expression {
        Expr::Call { name, args } if name == "return" => {
            args.first().map(|arg| expression_shape(arg.value()))
        }
        Expr::BlockValue { block } => block
            .statements
            .iter()
            .find_map(|statement| return_shape(&statement.expr)),
        Expr::FluentChain { receiver, calls } => return_shape(receiver).or_else(|| {
            calls.iter().find_map(|call| {
                (call.method == "return")
                    .then(|| call.args.first().map(|arg| expression_shape(arg.value())))
                    .flatten()
            })
        }),
        _ => None,
    }
}

fn expression_shape(expression: &Expr) -> Value {
    match expression {
        Expr::StringLiteral { .. } => value_shape("string"),
        Expr::NumberLiteral { .. } => value_shape("number"),
        Expr::BooleanLiteral { .. } => value_shape("boolean"),
        Expr::Undef => value_shape("null"),
        Expr::ArrayLiteral { items } => {
            let element = common_shape(items.iter().map(expression_shape));
            array_shape(element)
        }
        Expr::HashLiteral { .. } => value_shape("object"),
        Expr::Call { name, args } if name == "return" => args
            .first()
            .map(Arg::value)
            .map(expression_shape)
            .unwrap_or_else(|| value_shape("unknown")),
        _ => value_shape("unknown"),
    }
}

fn common_shape(mut shapes: impl Iterator<Item = Value>) -> Value {
    let Some(first) = shapes.next() else {
        return value_shape("unknown");
    };
    if shapes.all(|shape| shape == first) {
        first
    } else {
        value_shape("unknown")
    }
}

pub(super) fn value_shape(kind: &str) -> Value {
    json!({
        "kind": kind,
        "element": null,
        "key": null,
        "value": null,
        "signature": null,
        "members": [],
    })
}

fn array_shape(element: Value) -> Value {
    let mut shape = value_shape("array");
    shape["element"] = element;
    shape
}

fn shape_kind(shape: &Value) -> &str {
    shape
        .get("kind")
        .and_then(Value::as_str)
        .unwrap_or("unknown")
}

fn neutral_repetition(mode: &RuleMode) -> bool {
    !matches!(
        mode,
        RuleMode::Default | RuleMode::And | RuleMode::Single | RuleMode::Pipe
    )
}

fn neutral_bounds(mode: &RuleMode) -> (Option<usize>, Option<usize>) {
    if neutral_repetition(mode) {
        (mode.rep_min(), mode.rep_max())
    } else {
        (None, None)
    }
}

fn rule_edge_ownership(edges: &[EdgeProjection<'_>]) -> &'static str {
    let action = edges.iter().any(|edge| edge.ownership == "action");
    let blind = edges.iter().any(|edge| edge.ownership == "blind");
    match (action, blind) {
        (true, false) => "action",
        (false, true) => "blind",
        (false, false) => "none",
        (true, true) => "mixed",
    }
}

fn register_source(
    projection: &mut SemanticStaticProjection,
    context: &ProjectionContext<'_>,
    record_id: &str,
    range: SourceRange,
) -> Result<String, SemanticIndexError> {
    let key = format!("source_ref:{record_id}");
    let span = context
        .source_map
        .span_for_byte_range(range.start, range.end)?;
    projection.source_refs.insert(
        key.clone(),
        SemanticSourceReference {
            source_id: SOURCE_ID.to_string(),
            logical_name: context.logical_name.to_string(),
            span,
            excerpt: context.source_text[range.start..range.end].to_string(),
            content_digest: context.content_digest.to_string(),
            provenance_ids: Vec::new(),
        },
    );
    Ok(key)
}

fn source_record() -> SemanticRecord {
    record(
        SOURCE_ID,
        "source",
        None,
        Some(SPEC_ID.to_string()),
        0,
        None,
        json!({"logical_kind": "spec", "origin_kind": "authored"}),
    )
}

pub(super) fn record(
    id: &str,
    kind: &str,
    name: Option<String>,
    owner_id: Option<String>,
    order: usize,
    source: Option<String>,
    facts: Value,
) -> SemanticRecord {
    SemanticRecord {
        id: id.to_string(),
        kind: kind.to_string(),
        name,
        owner_id,
        order,
        source,
        facts,
        redactions: Vec::new(),
    }
}

pub(super) fn relation(
    kind: &str,
    from_id: &str,
    to_id: &str,
    order: usize,
    source: Option<String>,
    evidence_ids: Vec<String>,
) -> SemanticRelation {
    SemanticRelation {
        id: format!("relation:{kind}:{from_id}:{to_id}:{order}"),
        kind: kind.to_string(),
        from_id: from_id.to_string(),
        to_id: to_id.to_string(),
        order,
        source,
        facts: json!({}),
        evidence_ids,
    }
}

fn canonicalize(projection: &mut SemanticStaticProjection) {
    projection.records.sort_by(|left, right| {
        kind_rank(RECORD_KINDS, &left.kind)
            .cmp(&kind_rank(RECORD_KINDS, &right.kind))
            .then(left.order.cmp(&right.order))
            .then(left.id.cmp(&right.id))
    });
    let record_rank = projection
        .records
        .iter()
        .enumerate()
        .map(|(index, record)| (record.id.as_str(), index))
        .collect::<BTreeMap<_, _>>();
    projection
        .relations
        .sort_by(|left, right| compare_relation(left, right, &record_rank));
}

fn compare_relation(
    left: &SemanticRelation,
    right: &SemanticRelation,
    record_rank: &BTreeMap<&str, usize>,
) -> Ordering {
    record_rank
        .get(left.from_id.as_str())
        .unwrap_or(&usize::MAX)
        .cmp(
            record_rank
                .get(right.from_id.as_str())
                .unwrap_or(&usize::MAX),
        )
        .then(kind_rank(RELATION_KINDS, &left.kind).cmp(&kind_rank(RELATION_KINDS, &right.kind)))
        .then(
            record_rank
                .get(left.to_id.as_str())
                .unwrap_or(&usize::MAX)
                .cmp(record_rank.get(right.to_id.as_str()).unwrap_or(&usize::MAX)),
        )
        .then(left.id.cmp(&right.id))
}

fn kind_rank(kinds: &[&str], kind: &str) -> usize {
    kinds
        .iter()
        .position(|candidate| *candidate == kind)
        .unwrap_or(usize::MAX)
}

fn rule_id(label: &str) -> String {
    format!("rule:{}", escape_name(label))
}

fn escape_name(name: &str) -> String {
    let mut escaped = String::new();
    for byte in name.as_bytes() {
        let character = *byte as char;
        if character.is_ascii_alphanumeric() || matches!(character, '.' | '_' | '~' | '-') {
            escaped.push(character);
        } else {
            use std::fmt::Write;
            write!(&mut escaped, "%{byte:02X}").expect("writing to String cannot fail");
        }
    }
    escaped
}

fn spec_name(logical_name: &str) -> String {
    logical_name
        .strip_suffix(".spec")
        .unwrap_or(logical_name)
        .to_string()
}

fn neutral_entry_basis(basis: &str) -> &'static str {
    match basis {
        "first_authored_marker" => "first_marker",
        "first_authored_rule" => "first_rule",
        "explicit_selector" => "explicit_selector",
        _ => "first_rule",
    }
}

fn correlation_error(message: &str, identity: &str) -> SemanticIndexError {
    SemanticIndexError::new(
        "project_static_semantics",
        "semantic_static_correlation_failed",
        message,
    )
    .with_field("identity", identity)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::semantic_index::{SemanticIndex, SemanticIndexOptions, SemanticSourceDetail};

    const MODEL: &str =
        include_str!("../../../../capability_conformance/semantic_introspection_model.json");
    const GRAPH: &[u8] =
        include_bytes!("../../../../capability_conformance/semantic_introspection/graph.spec");
    const PRIVACY: &[u8] =
        include_bytes!("../../../../capability_conformance/semantic_introspection/privacy.spec");
    const FAILED: &[u8] =
        include_bytes!("../../../../capability_conformance/semantic_introspection/failed.spec");
    const RUNTIME: &[u8] =
        include_bytes!("../../../../capability_conformance/semantic_introspection/runtime.spec");
    const CALLS: &[u8] = include_bytes!(
        "../../../../capability_conformance/semantic_introspection/calls_and_staging.spec"
    );

    fn projection(source: &[u8], name: &str, detail: SemanticSourceDetail) -> Value {
        let index = SemanticIndex::from_utf8(source, SemanticIndexOptions::new(name, detail))
            .expect("construct semantic index");
        serde_json::to_value(index.static_projection()).expect("serialize plain projection")
    }

    fn expected(id: &str) -> Value {
        let model: Value = serde_json::from_str(MODEL).expect("parse neutral model");
        let mut snapshot = model["snapshots"]
            .as_array()
            .expect("snapshot array")
            .iter()
            .find(|snapshot| snapshot["id"] == id)
            .expect("expected snapshot")
            .clone();
        snapshot
            .as_object_mut()
            .expect("snapshot object")
            .remove("id");
        snapshot
            .as_object_mut()
            .expect("snapshot object")
            .remove("fixture");
        snapshot
    }

    fn materialize_sources(mut projection: Value) -> Value {
        let source_refs = projection
            .as_object_mut()
            .expect("projection object")
            .remove("source_refs")
            .expect("source refs");
        for group in ["records", "relations"] {
            for item in projection[group].as_array_mut().expect("projection rows") {
                let Some(key) = item["source"].as_str() else {
                    continue;
                };
                item["source"] = source_refs[key].clone();
            }
        }
        projection
    }

    #[test]
    fn graph_static_projection_deep_equals_neutral_model() {
        let actual =
            materialize_sources(projection(GRAPH, "graph.spec", SemanticSourceDetail::Text));
        let wanted = materialize_sources(expected("graph"));
        assert_eq!(actual, wanted);
    }

    #[test]
    fn unicode_privacy_static_projection_is_exact_at_both_ceilings() {
        for (id, detail) in [
            ("privacy", SemanticSourceDetail::Text),
            ("privacy_limited", SemanticSourceDetail::Identity),
        ] {
            let actual = materialize_sources(projection(PRIVACY, "privacy.spec", detail));
            let wanted = materialize_sources(expected(id));
            assert_eq!(actual, wanted, "{id}");
        }
    }

    #[test]
    fn runtime_static_half_deep_equals_neutral_model_without_observation() {
        let actual = materialize_sources(projection(
            RUNTIME,
            "runtime.spec",
            SemanticSourceDetail::Text,
        ));
        let mut wanted = expected("runtime");
        let records = wanted["records"]
            .as_array()
            .expect("records")
            .iter()
            .filter(|record| !matches!(record["kind"].as_str(), Some("execution" | "event")))
            .cloned()
            .collect::<Vec<_>>();
        let ids = records
            .iter()
            .filter_map(|record| record["id"].as_str())
            .collect::<BTreeSet<_>>();
        let relations = wanted["relations"]
            .as_array()
            .expect("relations")
            .iter()
            .filter(|relation| {
                relation["from_id"]
                    .as_str()
                    .is_some_and(|id| ids.contains(id))
                    && relation["to_id"]
                        .as_str()
                        .is_some_and(|id| ids.contains(id))
            })
            .cloned()
            .collect::<Vec<_>>();
        wanted["records"] = Value::Array(records);
        wanted["relations"] = Value::Array(relations);
        wanted["snapshot"]["has_execution"] = Value::Bool(false);
        let wanted = materialize_sources(wanted);
        assert_eq!(actual, wanted);
    }

    #[test]
    fn failed_projection_deliberately_normalizes_rust_failure_seam() {
        let actual = materialize_sources(projection(
            FAILED,
            "failed.spec",
            SemanticSourceDetail::Span,
        ));
        let wanted = materialize_sources(expected("failed"));
        assert_eq!(actual, wanted);
    }

    #[test]
    fn calls_and_staging_projection_deep_equals_neutral_model() {
        let actual = materialize_sources(projection(
            CALLS,
            "calls_and_staging.spec",
            SemanticSourceDetail::Text,
        ));
        let wanted = materialize_sources(expected("calls"));
        assert_eq!(actual, wanted);
    }

    #[test]
    fn calls_preserve_typed_preorder_resolution_and_staged_directions() {
        let actual = projection(CALLS, "calls_and_staging.spec", SemanticSourceDetail::Text);
        let calls = actual["records"]
            .as_array()
            .expect("records")
            .iter()
            .filter(|record| record["kind"] == "call")
            .map(|record| {
                (
                    record["name"].as_str().expect("call name"),
                    record["facts"]["resolution_kind"]
                        .as_str()
                        .expect("resolution kind"),
                    record["facts"]["return_shape"]["kind"]
                        .as_str()
                        .expect("return kind"),
                )
            })
            .collect::<Vec<_>>();
        assert_eq!(
            calls,
            vec![
                ("trim", "helper", "string"),
                ("normalize", "user_function", "string"),
                ("match_text", "helper", "string"),
                ("return", "helper", "string"),
            ]
        );
        assert_eq!(
            actual["records"][0]["facts"]["definition_order"],
            json!(["function:normalize", "rule:Top", "rule:Done"])
        );
        let relation_kinds = actual["relations"]
            .as_array()
            .expect("relations")
            .iter()
            .filter_map(|relation| relation["kind"].as_str())
            .collect::<BTreeSet<_>>();
        for kind in ["consumes", "produces", "lowered_from", "staged_by"] {
            assert!(relation_kinds.contains(kind), "missing {kind}");
        }
    }

    #[test]
    fn call_source_correlation_converts_unicode_scalars_once() {
        let source = b"# pr\xC3\xA9face\nfn clean(value) { return(trim(value)) }\n\nTop::\n /x/ -> Done { return(clean(match_text())) }\n\nDone:\n /x/\n";
        let actual = projection(source, "unicode_calls.spec", SemanticSourceDetail::Text);
        let source_refs = actual["source_refs"].as_object().expect("source refs");
        let calls = actual["records"]
            .as_array()
            .expect("records")
            .iter()
            .filter(|record| record["kind"] == "call")
            .collect::<Vec<_>>();
        let excerpts = calls
            .iter()
            .map(|record| {
                source_refs[record["source"].as_str().expect("source key")]["excerpt"]
                    .as_str()
                    .expect("excerpt")
            })
            .collect::<Vec<_>>();
        assert_eq!(
            excerpts,
            vec![
                "trim(value)",
                "return(clean(match_text()))",
                "clean(match_text())",
                "match_text()"
            ]
        );
        let columns = calls
            .iter()
            .map(|record| {
                source_refs[record["source"].as_str().expect("source key")]["span"]["start_column"]
                    .as_u64()
                    .expect("start column")
            })
            .collect::<Vec<_>>();
        assert_eq!(columns, vec![26, 16, 23, 29]);
    }

    #[test]
    fn interleaved_function_shell_remains_one_definition_not_a_rule_member() {
        let source = b"Top::\n /x/ -> Done { return(clean(match_text())) }\n\nfn clean(value) { return(trim(value)) }\n\nDone:\n /x/\n";
        let actual = projection(source, "interleaved_calls.spec", SemanticSourceDetail::Text);
        assert_eq!(
            actual["records"][0]["facts"]["definition_order"],
            json!(["rule:Top", "function:clean", "rule:Done"])
        );
        let rule_ids = actual["records"]
            .as_array()
            .expect("records")
            .iter()
            .filter(|record| record["kind"] == "rule")
            .map(|record| record["id"].as_str().expect("rule id"))
            .collect::<Vec<_>>();
        assert_eq!(rule_ids, vec!["rule:Top", "rule:Done"]);
        let encoded = serde_json::to_string(&actual).expect("serialize projection");
        assert!(!encoded.contains("body_ast"));
        assert!(!encoded.contains("body_source"));
        assert!(!encoded.contains("GENERATED_PLAN"));
    }

    #[test]
    fn retained_projection_is_clone_safe_and_host_object_free() {
        let index = SemanticIndex::from_utf8(
            GRAPH,
            SemanticIndexOptions::new("graph.spec", SemanticSourceDetail::Text),
        )
        .expect("construct graph index");
        let mut first = index.static_projection();
        first.records[0].facts["definition_order"][0] = json!("rule:Injected");
        first
            .source_refs
            .get_mut("source_ref:rule:Top")
            .expect("top source")
            .logical_name = "/tmp/private.spec".to_string();
        let second = index.static_projection();
        assert_eq!(second.records[0].facts["definition_order"][0], "rule:Top");
        assert_eq!(
            second.source_refs["source_ref:rule:Top"].logical_name,
            "graph.spec"
        );
        let encoded = serde_json::to_string(&second).expect("serialize normalized projection");
        assert!(!encoded.contains("CODE(0x"));
        assert!(!encoded.contains("Regexp(0x"));
        assert!(!encoded.contains("/tmp/"));
    }
}
