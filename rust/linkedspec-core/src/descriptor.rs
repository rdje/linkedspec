//! Backend-neutral outward compiled-descriptor projection.
//!
//! Runtime execution continues to consume [`CompiledSpec`] directly. This module
//! projects that internal state into the stable public `spec`, `functions`,
//! `dependency_regex_map`, and `meta` shape used by LinkedSpec tooling.

use std::collections::{BTreeMap, BTreeSet};

use serde::{Deserialize, Serialize};
use serde_json::Value;

use crate::ast::{RuleMode, SourceSpan};
use crate::compiler::REGEX_SLOT_IDENTITY_CONTRACT;
use crate::entry_rule::ENTRY_RULE_CONTRACT_ID;
use crate::types::{CompiledRule, CompiledSpec, DependencyRef, ParseMode};

/// Public compiled descriptor returned to Rust tooling.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CompiledDescriptorState {
    pub spec: BTreeMap<String, CompiledRuleDescriptor>,
    pub functions: BTreeMap<String, CompiledFunctionDescriptor>,
    pub dependency_regex_map: BTreeMap<String, CompiledDependencyRegexEntry>,
    pub meta: CompiledDescriptorMeta,
}

impl CompiledDescriptorState {
    /// Convert the typed descriptor to JSON without exposing runtime internals.
    pub fn to_json(&self) -> Result<Value, serde_json::Error> {
        serde_json::to_value(self)
    }
}

/// Host-native handler identity for one projected rule.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct CompiledRuleHandlerDescriptor {
    pub kind: String,
    pub label: String,
    pub status: String,
}

/// Public projection of one compiled rule.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CompiledRuleDescriptor {
    pub handler: CompiledRuleHandlerDescriptor,
    #[serde(rename = "re")]
    pub regex_patterns: Vec<String>,
    pub dependency_refs: Vec<DependencyRef>,
    pub meta: CompiledRuleDescriptorMeta,
}

/// Public rule metadata independent of the runtime engine.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CompiledRuleDescriptorMeta {
    pub label: String,
    pub is_top: bool,
    pub family: String,
    pub cursor_policy: ParseMode,
    pub edge_ownership: String,
    pub resolved_edges: Vec<CompiledResolvedEdgeDescriptor>,
    pub mode: CompiledRuleModeMetadata,
}

/// One normalized semantic edge in deterministic source order.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct CompiledResolvedEdgeDescriptor {
    pub ownership: String,
    pub target: String,
    pub regex_index: Option<usize>,
    pub block: bool,
    pub fluent: Option<String>,
}

/// Stable rule-mode projection shared with the other native variants.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct CompiledRuleModeMetadata {
    pub name: String,
    pub is_top: bool,
    pub is_and: bool,
    pub is_repetition: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub rep_min: Option<usize>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub rep_max: Option<usize>,
}

/// Public compiled dependency-regex entry.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct CompiledDependencyRegexEntry {
    pub owner_label: String,
    pub dependency_refs: Vec<DependencyRef>,
    pub patterns: Vec<String>,
    pub combined_pattern: String,
}

/// Public staged user-function record.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CompiledFunctionDescriptor {
    pub index: usize,
    pub kind: String,
    pub version: usize,
    pub name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub params: Option<Vec<String>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub arity: Option<usize>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub parameter_kinds: Option<std::collections::BTreeMap<String, String>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub signature: Option<crate::ast::CallableSignature>,
    pub source_text: String,
    pub source_span: SourceSpan,
    pub body_span: SourceSpan,
    pub body_source: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub body_payload: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub body_parse_job: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub body_ast: Option<Value>,
}

/// Descriptor-wide model identities and deterministic source/compile order.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct CompiledDescriptorMeta {
    pub descriptor_model: String,
    pub compiled_spec_model: String,
    pub compiled_dependency_regex_model: String,
    pub cursor_contract: String,
    pub regex_slot_identity_contract: String,
    pub entry_rule_contract: String,
    pub definition_order: Vec<String>,
    pub compiled_rule_order: Vec<String>,
    pub redefined_rule_labels: Vec<String>,
    pub function_order: Vec<String>,
    pub function_count: usize,
}

impl CompiledSpec {
    /// Project internal compiled state into the backend-neutral public descriptor.
    pub fn descriptor_state(&self) -> CompiledDescriptorState {
        let definition_order = self
            .rules
            .iter()
            .map(|rule| rule.label.clone())
            .collect::<Vec<_>>();
        let compiled_rule_order = last_definition_order(&definition_order);
        let redefined_rule_labels = redefined_rule_labels(&definition_order);
        let rules_by_label = rules_by_label(self);

        let spec = compiled_rule_order
            .iter()
            .filter_map(|label| {
                rules_by_label
                    .get(label)
                    .map(|rule| (label.clone(), project_rule(rule)))
            })
            .collect();

        let functions = self
            .functions
            .iter()
            .enumerate()
            .map(|(index, function)| {
                (
                    function.name.clone(),
                    CompiledFunctionDescriptor {
                        index,
                        kind: "user_function_definition".to_string(),
                        version: if !function.parameter_kinds.is_empty() {
                            3
                        } else if function.signature.is_some() {
                            2
                        } else {
                            1
                        },
                        name: function.name.clone(),
                        params: function
                            .signature
                            .is_none()
                            .then(|| function.params.clone()),
                        arity: function.signature.is_none().then_some(function.arity),
                        parameter_kinds: (!function.parameter_kinds.is_empty())
                            .then(|| function.parameter_kinds.clone()),
                        signature: function.signature.clone(),
                        source_text: function.source.clone(),
                        source_span: function.source_span.clone(),
                        body_span: function.body_span.clone(),
                        body_source: function.body_source.clone(),
                        body_payload: function.body_payload.clone(),
                        body_parse_job: function.body_parse_job.clone(),
                        body_ast: function.body_ast.clone(),
                    },
                )
            })
            .collect::<BTreeMap<_, _>>();

        let dependency_regex_map = compiled_rule_order
            .iter()
            .filter_map(|label| {
                let rule = rules_by_label.get(label)?;
                let dependency_refs = dependency_refs(rule);
                if dependency_refs.is_empty() {
                    return None;
                }
                let patterns = dependency_refs
                    .iter()
                    .filter_map(|dependency| {
                        rules_by_label
                            .get(&dependency.label)
                            .and_then(|target| target.regex_patterns.get(dependency.index))
                            .cloned()
                    })
                    .collect::<Vec<_>>();
                let combined_pattern = patterns
                    .iter()
                    .map(|pattern| format!("(?:{pattern})"))
                    .collect::<Vec<_>>()
                    .join("|");
                Some((
                    label.clone(),
                    CompiledDependencyRegexEntry {
                        owner_label: label.clone(),
                        dependency_refs,
                        patterns,
                        combined_pattern,
                    },
                ))
            })
            .collect();

        let function_order = self
            .functions
            .iter()
            .map(|function| function.name.clone())
            .collect::<Vec<_>>();
        CompiledDescriptorState {
            spec,
            functions,
            dependency_regex_map,
            meta: CompiledDescriptorMeta {
                descriptor_model: "compiled_descriptor_state".to_string(),
                compiled_spec_model: "compiled_spec_state".to_string(),
                compiled_dependency_regex_model: "compiled_dependency_regex_state".to_string(),
                cursor_contract: "linkedspec-rule-local-cursor-v1".to_string(),
                regex_slot_identity_contract: REGEX_SLOT_IDENTITY_CONTRACT.to_string(),
                entry_rule_contract: ENTRY_RULE_CONTRACT_ID.to_string(),
                definition_order,
                compiled_rule_order,
                redefined_rule_labels,
                function_count: function_order.len(),
                function_order,
            },
        }
    }

    /// Project internal compiled state directly to JSON.
    pub fn to_descriptor_json(&self) -> Result<Value, serde_json::Error> {
        self.descriptor_state().to_json()
    }
}

fn project_rule(rule: &CompiledRule) -> CompiledRuleDescriptor {
    CompiledRuleDescriptor {
        handler: CompiledRuleHandlerDescriptor {
            kind: "rust_interpreter_rule".to_string(),
            label: rule.label.clone(),
            status: "compiled_state_only".to_string(),
        },
        regex_patterns: rule.regex_patterns.clone(),
        dependency_refs: dependency_refs(rule),
        meta: CompiledRuleDescriptorMeta {
            label: rule.label.clone(),
            is_top: rule.is_top,
            family: rule_family(&rule.mode).to_string(),
            cursor_policy: rule.cursor_policy(),
            edge_ownership: edge_ownership(rule).to_string(),
            resolved_edges: resolved_edges(rule),
            mode: CompiledRuleModeMetadata {
                name: rule_mode_name(&rule.mode).to_string(),
                is_top: rule.is_top,
                is_and: rule.mode.is_and(),
                is_repetition: rule.mode.is_repetition(),
                rep_min: rule.rep_min,
                rep_max: rule.rep_max,
            },
        },
    }
}

fn rule_family(mode: &RuleMode) -> &'static str {
    if mode.is_and() { "and" } else { "or_default" }
}

fn edge_ownership(rule: &CompiledRule) -> &'static str {
    match (
        rule.acode_dispatch.is_empty(),
        rule.bcode_dispatch.is_empty(),
    ) {
        (false, true) => "action",
        (true, false) => "blind",
        (true, true) => "none",
        (false, false) => "mixed",
    }
}

fn resolved_edges(rule: &CompiledRule) -> Vec<CompiledResolvedEdgeDescriptor> {
    rule.acode_dispatch
        .iter()
        .map(|entry| CompiledResolvedEdgeDescriptor {
            ownership: "action".to_string(),
            target: entry.child_label.clone(),
            regex_index: Some(entry.child_regex_idx),
            block: entry.code.is_some(),
            fluent: project_fluent(&entry.fluent_chain),
        })
        .chain(
            rule.bcode_dispatch
                .iter()
                .map(|entry| CompiledResolvedEdgeDescriptor {
                    ownership: "blind".to_string(),
                    target: entry.child_label.clone(),
                    regex_index: None,
                    block: entry.code.is_some(),
                    fluent: project_fluent(&entry.fluent_chain),
                }),
        )
        .collect()
}

fn project_fluent(chain: &[(String, String)]) -> Option<String> {
    (!chain.is_empty()).then(|| {
        chain
            .iter()
            .map(|(method, args)| {
                if args.is_empty() {
                    method.clone()
                } else {
                    format!("{method}({args})")
                }
            })
            .collect::<Vec<_>>()
            .join(".")
    })
}

fn dependency_refs(rule: &CompiledRule) -> Vec<DependencyRef> {
    if !rule.dependency_refs.is_empty() {
        return rule
            .dependency_refs
            .iter()
            .map(|entry| DependencyRef {
                label: entry.label.clone(),
                index: entry.index,
                selector_kind: Default::default(),
                authored_selector: None,
                target_slot_id: None,
            })
            .collect();
    }
    rule.acode_dispatch
        .iter()
        .map(|entry| DependencyRef {
            label: entry.child_label.clone(),
            index: entry.child_regex_idx,
            selector_kind: Default::default(),
            authored_selector: None,
            target_slot_id: None,
        })
        .chain(rule.bcode_dispatch.iter().map(|entry| DependencyRef {
            label: entry.child_label.clone(),
            index: 0,
            selector_kind: Default::default(),
            authored_selector: None,
            target_slot_id: None,
        }))
        .collect()
}

fn rules_by_label(spec: &CompiledSpec) -> BTreeMap<String, &CompiledRule> {
    let mut rules = BTreeMap::new();
    for rule in &spec.rules {
        rules.insert(rule.label.clone(), rule);
    }
    rules
}

fn last_definition_order(definition_order: &[String]) -> Vec<String> {
    let mut seen = BTreeSet::new();
    let mut order = definition_order
        .iter()
        .rev()
        .filter(|label| seen.insert((*label).clone()))
        .cloned()
        .collect::<Vec<_>>();
    order.reverse();
    order
}

fn redefined_rule_labels(definition_order: &[String]) -> Vec<String> {
    let mut seen = BTreeSet::new();
    let mut redefined = BTreeSet::new();
    let mut order = Vec::new();
    for label in definition_order {
        if !seen.insert(label.clone()) && redefined.insert(label.clone()) {
            order.push(label.clone());
        }
    }
    order
}

fn rule_mode_name(mode: &RuleMode) -> &'static str {
    match mode {
        RuleMode::Default => "Default",
        RuleMode::And => "And",
        RuleMode::AndPlus => "AndPlus",
        RuleMode::AndBounded { .. } => "AndBounded",
        RuleMode::Or => "Or",
        RuleMode::OrPlus => "OrPlus",
        RuleMode::OrBounded { .. } => "OrBounded",
        RuleMode::Single => "Single",
        RuleMode::Pipe => "Pipe",
        RuleMode::Plus => "Plus",
        RuleMode::Star => "Star",
        RuleMode::Optional => "Optional",
    }
}
