//! Private call, binding, staged-artifact, and generated-plan projection.
//!
//! The compiler remains the typed authority. This module only correlates its
//! clone-safe `ActionIR` trees and staged sidecars with authored source ranges;
//! neither host layouts nor generated implementation source are retained.

use super::static_projection::{
    SemanticSourceReference, SemanticStaticProjection, codeblock_shape, record, relation,
    value_shape,
};
use super::{
    SemanticEntrySelection, SemanticGeneratedPlanInput, SemanticIndexError, SemanticSourceMap,
};
use linkedspec_core::ast::{BodyElementKind, SpecFile};
use linkedspec_core::expr::{CodeBlock, Expr};
use linkedspec_core::types::{CompiledSpec, CompiledUserFunction};
use serde_json::{Value, json};
use std::collections::BTreeMap;

const SPEC_ID: &str = "spec:0";
const SOURCE_ID: &str = "source:0";

#[derive(Clone, Copy)]
struct SourceRange {
    start: usize,
    end: usize,
}

struct DefinitionRow {
    id: String,
    start: usize,
    kind: DefinitionKind,
}

enum DefinitionKind {
    Function(usize),
    Rule(String),
}

#[derive(Clone)]
struct ActionOwner {
    owner_id: String,
    block: CodeBlock,
    source_text: String,
    source_start: usize,
}

#[derive(Clone)]
struct CallSite {
    name: String,
    range: SourceRange,
}

struct CallCursor {
    sites: Vec<CallSite>,
    next: usize,
}

impl CallCursor {
    fn new(source: &str, source_start: usize) -> Result<Self, SemanticIndexError> {
        Ok(Self {
            sites: scan_calls(source, source_start)?,
            next: 0,
        })
    }

    fn take(&mut self, name: &str, owner_id: &str) -> Result<SourceRange, SemanticIndexError> {
        let Some(relative) = self.sites[self.next..]
            .iter()
            .position(|site| site.name == name)
        else {
            return Err(
                call_error("typed call has no authored source occurrence", owner_id)
                    .with_field("call_name", name),
            );
        };
        let index = self.next + relative;
        self.next = index + 1;
        Ok(self.sites[index].range)
    }
}

#[derive(Clone)]
struct HelperContract {
    parameters: Vec<(&'static str, &'static str)>,
    effects: Vec<&'static str>,
    return_kind: &'static str,
}

fn helper_contract(name: &str) -> Option<HelperContract> {
    match name {
        "trim" => Some(HelperContract {
            parameters: vec![("value", "value")],
            effects: Vec::new(),
            return_kind: "string",
        }),
        "match_text" => Some(HelperContract {
            parameters: Vec::new(),
            effects: vec!["reads_runtime_match"],
            return_kind: "string",
        }),
        "return" => Some(HelperContract {
            parameters: vec![("value", "value")],
            effects: vec!["returns_owner"],
            return_kind: "unknown",
        }),
        _ => None,
    }
}

pub(super) struct BuildInput<'a> {
    pub(super) source_text: &'a str,
    pub(super) source_map: &'a SemanticSourceMap,
    pub(super) logical_name: &'a str,
    pub(super) content_digest: &'a str,
    pub(super) parsed: &'a SpecFile,
    pub(super) compiled: &'a CompiledSpec,
    pub(super) entry_selection: Option<&'a SemanticEntrySelection>,
    pub(super) generated_plan: Option<&'a SemanticGeneratedPlanInput>,
    pub(super) projection: &'a mut SemanticStaticProjection,
}

pub(super) fn extend(input: BuildInput<'_>) -> Result<(), SemanticIndexError> {
    if input.compiled.functions.is_empty() {
        return Ok(());
    }

    let context = ProjectionContext {
        source_text: input.source_text,
        source_map: input.source_map,
        logical_name: input.logical_name,
        content_digest: input.content_digest,
    };
    let function_ranges = locate_function_ranges(&context, input.compiled)?;
    let action_owners = action_owners(input.parsed, input.compiled, input.projection, &context)?;
    let function_shapes = infer_function_shapes(&input.compiled.functions);

    let mut definitions = Vec::new();
    for (index, function) in input.compiled.functions.iter().enumerate() {
        definitions.push(DefinitionRow {
            id: function_id(&function.name),
            start: function_ranges[index].start,
            kind: DefinitionKind::Function(index),
        });
    }
    for rule in &input.compiled.rules {
        let id = rule_id(&rule.label);
        let source_key = format!("source_ref:{id}");
        let source = input
            .projection
            .source_refs
            .get(&source_key)
            .ok_or_else(|| call_error("rule source is missing during definition merge", &id))?;
        definitions.push(DefinitionRow {
            id,
            start: source.span.start_byte,
            kind: DefinitionKind::Rule(rule.label.clone()),
        });
    }
    definitions.sort_by(|left, right| left.start.cmp(&right.start).then(left.id.cmp(&right.id)));
    input.projection.records[0].facts["definition_order"] = Value::Array(
        definitions
            .iter()
            .map(|definition| Value::String(definition.id.clone()))
            .collect(),
    );

    for (index, function) in input.compiled.functions.iter().enumerate() {
        add_function_and_staging(
            input.projection,
            &context,
            function,
            index,
            input.compiled.rules.len() + index,
            function_ranges[index],
            &function_shapes[&function.name],
        )?;
    }

    let mut builder = CallBuilder {
        projection: input.projection,
        context: &context,
        functions: &input.compiled.functions,
        function_shapes: &function_shapes,
        helper_ids: BTreeMap::new(),
        binding_by_owner_name: BTreeMap::new(),
        global_call_order: 0,
        edge_value_shapes: BTreeMap::new(),
    };

    for definition in &definitions {
        match &definition.kind {
            DefinitionKind::Function(index) => {
                let function = &input.compiled.functions[*index];
                let body_range = function_body_range(&context, function)?;
                let mut cursor = CallCursor::new(&function.body_source, body_range.start)?;
                let mut local_order = 0;
                let owner_id = function_id(&function.name);
                let mut variables = function
                    .params
                    .iter()
                    .map(|name| (name.clone(), value_shape("unknown")))
                    .collect::<BTreeMap<_, _>>();
                for statement in &function.body.statements {
                    if let Expr::Call { name, args } = &statement.expr
                        && name == "return"
                    {
                        for argument in args {
                            builder.emit_expr_calls(
                                argument.value(),
                                &owner_id,
                                OwnerSurface::Function,
                                &mut cursor,
                                &mut local_order,
                                &mut variables,
                            )?;
                        }
                        continue;
                    }
                    builder.emit_statement(
                        &statement.expr,
                        &owner_id,
                        OwnerSurface::Function,
                        &mut cursor,
                        &mut local_order,
                        &mut variables,
                    )?;
                }
            }
            DefinitionKind::Rule(label) => {
                for owner in action_owners.iter().filter(|owner| {
                    owner
                        .owner_id
                        .starts_with(&format!("edge:{}:", rule_id(label)))
                }) {
                    let mut cursor = CallCursor::new(&owner.source_text, owner.source_start)?;
                    let mut local_order = 0;
                    let mut variables = BTreeMap::new();
                    for statement in &owner.block.statements {
                        builder.emit_statement(
                            &statement.expr,
                            &owner.owner_id,
                            OwnerSurface::Edge,
                            &mut cursor,
                            &mut local_order,
                            &mut variables,
                        )?;
                    }
                }
            }
        }
    }

    builder.apply_edge_shapes();
    add_generated_plan(
        builder.projection,
        input.entry_selection,
        input.generated_plan,
    )?;
    Ok(())
}

struct ProjectionContext<'a> {
    source_text: &'a str,
    source_map: &'a SemanticSourceMap,
    logical_name: &'a str,
    content_digest: &'a str,
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum OwnerSurface {
    Function,
    Edge,
}

struct EmittedCall {
    id: String,
    source: String,
    range: SourceRange,
}

struct CallBuilder<'a, 'b> {
    projection: &'a mut SemanticStaticProjection,
    context: &'b ProjectionContext<'b>,
    functions: &'b [CompiledUserFunction],
    function_shapes: &'b BTreeMap<String, Value>,
    helper_ids: BTreeMap<String, String>,
    binding_by_owner_name: BTreeMap<(String, String), String>,
    global_call_order: usize,
    edge_value_shapes: BTreeMap<String, Value>,
}

impl CallBuilder<'_, '_> {
    fn emit_statement(
        &mut self,
        expression: &Expr,
        owner_id: &str,
        surface: OwnerSurface,
        cursor: &mut CallCursor,
        local_order: &mut usize,
        variables: &mut BTreeMap<String, Value>,
    ) -> Result<(), SemanticIndexError> {
        if let Expr::AssignScalar { name, value } = expression {
            let shape = infer_expr_shape(value, variables, self.function_shapes);
            variables.insert(name.clone(), shape.clone());
            let binding_order = self
                .binding_by_owner_name
                .keys()
                .filter(|(owner, candidate)| owner == owner_id && candidate == name)
                .count();
            let binding_id = format!("binding:{owner_id}:{}:{binding_order}", escape_name(name));
            let emitted =
                self.emit_expr_calls(value, owner_id, surface, cursor, local_order, variables)?;
            let source = if let Some(call) = &emitted {
                Some(register_source(
                    self.projection,
                    self.context,
                    &binding_id,
                    call.range,
                )?)
            } else {
                None
            };
            self.projection.records.push(record(
                &binding_id,
                "binding",
                Some(name.clone()),
                Some(owner_id.to_string()),
                binding_order,
                source.clone(),
                json!({"scope": "action", "value_shape": shape, "mutable": true}),
            ));
            self.binding_by_owner_name
                .insert((owner_id.to_string(), name.clone()), binding_id.clone());
            if let Some(call) = emitted {
                self.projection.relations.push(relation(
                    "writes",
                    &call.id,
                    &binding_id,
                    0,
                    Some(call.source),
                    Vec::new(),
                ));
            }
            return Ok(());
        }

        if let Expr::Call { name, .. } = expression
            && name == "return"
            && surface == OwnerSurface::Edge
        {
            self.edge_value_shapes.insert(
                owner_id.to_string(),
                infer_expr_shape(expression, variables, self.function_shapes),
            );
        }
        self.emit_expr_calls(
            expression,
            owner_id,
            surface,
            cursor,
            local_order,
            variables,
        )?;
        Ok(())
    }

    fn emit_expr_calls(
        &mut self,
        expression: &Expr,
        owner_id: &str,
        surface: OwnerSurface,
        cursor: &mut CallCursor,
        local_order: &mut usize,
        variables: &mut BTreeMap<String, Value>,
    ) -> Result<Option<EmittedCall>, SemanticIndexError> {
        if let Expr::AssignScalar { value, .. } = expression {
            return self.emit_expr_calls(value, owner_id, surface, cursor, local_order, variables);
        }
        let Expr::Call { name, args } = expression else {
            return Ok(None);
        };

        let range = cursor.take(name, owner_id)?;
        let local = *local_order;
        *local_order += 1;
        let call_id = format!("call:{owner_id}:{local}");
        let source = register_source(self.projection, self.context, &call_id, range)?;
        let argument_shapes = args
            .iter()
            .map(|argument| infer_expr_shape(argument.value(), variables, self.function_shapes))
            .collect::<Vec<_>>();
        let function = self
            .functions
            .iter()
            .find(|function| function.name == *name);
        let helper = helper_contract(name);
        let resolution_kind = if function.is_some() {
            "user_function"
        } else if helper.is_some() {
            "helper"
        } else {
            "unresolved"
        };
        let return_shape = if function.is_some() {
            self.function_shapes[name].clone()
        } else if name == "return" && !argument_shapes.is_empty() {
            argument_shapes[0].clone()
        } else if let Some(contract) = &helper {
            value_shape(contract.return_kind)
        } else {
            value_shape("unknown")
        };
        self.projection.records.push(record(
            &call_id,
            "call",
            Some(name.clone()),
            Some(owner_id.to_string()),
            self.global_call_order,
            Some(source.clone()),
            json!({
                "call_form": "function",
                "resolution_kind": resolution_kind,
                "argument_shapes": argument_shapes,
                "return_shape": return_shape,
                "target_shape": value_shape(if resolution_kind == "unresolved" { "unknown" } else { resolution_kind }),
            }),
        ));
        self.global_call_order += 1;

        if let Some(function) = function {
            let target_id = function_id(&function.name);
            self.projection.relations.push(relation(
                "calls",
                &call_id,
                &target_id,
                0,
                Some(source.clone()),
                Vec::new(),
            ));
            self.add_resolution_explanation(
                &call_id,
                &source,
                function,
                &argument_shapes,
                &return_shape,
            );
        } else if let Some(contract) = helper {
            let helper_id = self.ensure_helper(name, &contract);
            let evidence = if surface == OwnerSurface::Function {
                vec![owner_id.to_string()]
            } else {
                Vec::new()
            };
            self.projection.relations.push(relation(
                "resolves_to",
                &call_id,
                &helper_id,
                0,
                Some(source.clone()),
                evidence,
            ));
        }

        if name == "return" {
            for argument in args {
                if let Expr::Variable { name } = argument.value()
                    && let Some(binding_id) = self
                        .binding_by_owner_name
                        .get(&(owner_id.to_string(), name.clone()))
                {
                    self.projection.relations.push(relation(
                        "reads",
                        &call_id,
                        binding_id,
                        0,
                        Some(source.clone()),
                        Vec::new(),
                    ));
                }
            }
        }

        for argument in args {
            self.emit_expr_calls(
                argument.value(),
                owner_id,
                surface,
                cursor,
                local_order,
                variables,
            )?;
        }
        Ok(Some(EmittedCall {
            id: call_id,
            source,
            range,
        }))
    }

    fn ensure_helper(&mut self, name: &str, contract: &HelperContract) -> String {
        if let Some(id) = self.helper_ids.get(name) {
            return id.clone();
        }
        let id = format!("helper:{}", escape_name(name));
        let order = self.helper_ids.len();
        self.helper_ids.insert(name.to_string(), id.clone());
        self.projection.records.push(record(
            &id,
            "helper",
            Some(name.to_string()),
            None,
            order,
            None,
            json!({
                "signature": signature_from_parameters(&contract.parameters),
                "effects": contract.effects,
                "return_shape": value_shape(contract.return_kind),
            }),
        ));
        id
    }

    fn add_resolution_explanation(
        &mut self,
        call_id: &str,
        source: &str,
        function: &CompiledUserFunction,
        argument_shapes: &[Value],
        return_shape: &Value,
    ) {
        let target_id = function_id(&function.name);
        let decision_id = format!("decision:call:{call_id}");
        self.projection.records.push(record(
            &decision_id,
            "decision",
            Some(format!("{} call resolution", function.name)),
            Some(call_id.to_string()),
            0,
            Some(source.to_string()),
            json!({"decision_kind": "call_resolution", "outcome": target_id}),
        ));
        let exact_id = format!("explanation:{decision_id}:0");
        self.projection.records.push(record(
            &exact_id,
            "explanation_step",
            None,
            Some(decision_id.clone()),
            0,
            Some(source.to_string()),
            json!({
                "rule_code": "call_exact_user_function",
                "summary": format!("The exact user-function name {} is registered.", function.name),
                "input_ids": [call_id, target_id],
                "output_fact": {"record_id": call_id, "path": "/facts/resolution_kind", "value": "user_function"},
            }),
        ));
        let signature_id = format!("explanation:{decision_id}:1");
        let count = argument_shapes.len();
        let count_words = if count == 1 {
            "one".to_string()
        } else {
            count.to_string()
        };
        let shape_words = if count == 1 {
            format!("{} argument", shape_kind(&argument_shapes[0]))
        } else {
            "arguments".to_string()
        };
        self.projection.records.push(record(
            &signature_id,
            "explanation_step",
            None,
            Some(decision_id.clone()),
            1,
            Some(source.to_string()),
            json!({
                "rule_code": "call_signature_accepts",
                "summary": format!(
                    "The {count_words} supplied {shape_words} satisfies {}({}).",
                    function.name,
                    function.params.join(", ")
                ),
                "input_ids": [call_id, target_id],
                "output_fact": {"record_id": call_id, "path": "/facts/return_shape/kind", "value": shape_kind(return_shape)},
            }),
        ));
        self.projection.relations.push(relation(
            "resolves_to",
            call_id,
            &target_id,
            0,
            Some(source.to_string()),
            vec![decision_id.clone()],
        ));
        self.projection.relations.push(relation(
            "explained_by",
            &decision_id,
            &exact_id,
            0,
            Some(source.to_string()),
            vec![target_id.clone()],
        ));
        self.projection.relations.push(relation(
            "explained_by",
            &decision_id,
            &signature_id,
            1,
            Some(source.to_string()),
            vec![target_id],
        ));
    }

    fn apply_edge_shapes(&mut self) {
        let mut rule_shapes = BTreeMap::new();
        for record in &mut self.projection.records {
            if record.kind != "edge" {
                continue;
            }
            let Some(shape) = self.edge_value_shapes.get(&record.id) else {
                continue;
            };
            record.facts["value_shape"] = shape.clone();
            if shape_kind(shape) != "unknown"
                && let Some(owner) = &record.owner_id
            {
                rule_shapes
                    .entry(owner.clone())
                    .or_insert_with(|| shape.clone());
            }
        }
        for record in &mut self.projection.records {
            if record.kind != "rule" {
                continue;
            }
            let Some(shape) = rule_shapes.get(&record.id) else {
                continue;
            };
            record.facts["value_shape"] = if record.facts["is_repetition"] == Value::Bool(true) {
                let mut array = value_shape("array");
                array["element"] = shape.clone();
                array
            } else {
                shape.clone()
            };
        }
    }
}

fn add_function_and_staging(
    projection: &mut SemanticStaticProjection,
    context: &ProjectionContext<'_>,
    function: &CompiledUserFunction,
    function_order: usize,
    declaration_order: usize,
    range: SourceRange,
    return_shape: &Value,
) -> Result<(), SemanticIndexError> {
    let parse_job = function.body_parse_job.as_ref().ok_or_else(|| {
        call_error(
            "compiled function has no staged body parse job",
            &function.name,
        )
    })?;
    if parse_job["parser_spec_id"] != "actionir-body.spec"
        || parse_job["top_rule"] != "action_block"
    {
        return Err(call_error(
            "compiled function staged parser identity is invalid",
            &function.name,
        ));
    }
    let id = function_id(&function.name);
    let source = register_source(projection, context, &id, range)?;
    let signature = function_signature(function);
    let parameter_kinds = signature["parameters"]
        .as_array()
        .expect("signature parameters")
        .iter()
        .map(|parameter| parameter["kind"].clone())
        .collect::<Vec<_>>();
    projection.records.push(record(
        &id,
        "function",
        Some(function.name.clone()),
        Some(SPEC_ID.to_string()),
        function_order,
        Some(source.clone()),
        json!({
            "signature": signature,
            "parameter_kinds": parameter_kinds,
            "return_shape": return_shape,
        }),
    ));
    projection.relations.push(relation(
        "declares",
        SPEC_ID,
        &id,
        declaration_order,
        Some(source.clone()),
        Vec::new(),
    ));

    let status = if function.body_ast.is_some() {
        "succeeded"
    } else {
        "failed"
    };
    let rows = [
        ("payload", "action_source", "string"),
        ("parse_job", "action_program", "unknown"),
        ("result", "action_program", "unknown"),
    ];
    let mut ids = BTreeMap::new();
    for (order, (artifact_kind, node_kind, shape_kind)) in rows.iter().enumerate() {
        let staged_id = format!("staged:{artifact_kind}:{id}:{order}");
        ids.insert(*artifact_kind, staged_id.clone());
        let suffix = if *artifact_kind == "parse_job" {
            "parse job"
        } else {
            artifact_kind
        };
        projection.records.push(record(
            &staged_id,
            "staged_artifact",
            Some(format!("{} body {suffix}", function.name)),
            Some(id.clone()),
            order,
            Some(source.clone()),
            json!({
                "artifact_kind": artifact_kind,
                "payload_kind": "function_body",
                "node_kind": node_kind,
                "parent_path": [id.clone()],
                "parser_spec_id": "linkedspec-action-v1",
                "top_rule": "FunctionBody",
                "result_policy": "typed_action_program",
                "failure_policy": "compile_diagnostic",
                "status": status,
                "value_shape": value_shape(shape_kind),
            }),
        ));
        projection.relations.push(relation(
            "contains",
            &id,
            &staged_id,
            order,
            Some(source.clone()),
            Vec::new(),
        ));
    }
    projection.relations.push(relation(
        "lowered_from",
        &ids["payload"],
        SOURCE_ID,
        0,
        Some(source.clone()),
        Vec::new(),
    ));
    projection.relations.push(relation(
        "consumes",
        &ids["parse_job"],
        &ids["payload"],
        0,
        Some(source.clone()),
        Vec::new(),
    ));
    projection.relations.push(relation(
        "produces",
        &ids["parse_job"],
        &ids["result"],
        0,
        Some(source.clone()),
        Vec::new(),
    ));
    projection.relations.push(relation(
        "lowered_from",
        &ids["result"],
        &ids["payload"],
        0,
        Some(source.clone()),
        Vec::new(),
    ));
    projection.relations.push(relation(
        "staged_by",
        &ids["result"],
        &ids["parse_job"],
        0,
        Some(source),
        Vec::new(),
    ));
    Ok(())
}

fn add_generated_plan(
    projection: &mut SemanticStaticProjection,
    entry_selection: Option<&SemanticEntrySelection>,
    generated_plan: Option<&SemanticGeneratedPlanInput>,
) -> Result<(), SemanticIndexError> {
    let selection = entry_selection.ok_or_else(|| {
        call_error(
            "compiled call projection has no resolved entry selection",
            SPEC_ID,
        )
    })?;
    let plan = generated_plan.ok_or_else(|| {
        call_error(
            "compiled call projection has no generated-v2 plan authority",
            SPEC_ID,
        )
    })?;
    let row = plan
        .rows
        .iter()
        .find(|row| row.label == selection.label)
        .ok_or_else(|| {
            call_error(
                "generated-v2 plan has no selected rule row",
                &selection.label,
            )
        })?;
    let id = "generated:handler_plan:0";
    projection.records.push(record(
        id,
        "generated_artifact",
        Some("handler plan".to_string()),
        Some(SPEC_ID.to_string()),
        0,
        None,
        json!({
            "artifact_kind": "handler_plan",
            "contract_id": plan.contract_id,
            "format_version": plan.format_version,
            "plan_family": row.family,
        }),
    ));
    projection
        .relations
        .push(relation("generated_as", SPEC_ID, id, 0, None, Vec::new()));
    Ok(())
}

fn locate_function_ranges(
    context: &ProjectionContext<'_>,
    compiled: &CompiledSpec,
) -> Result<Vec<SourceRange>, SemanticIndexError> {
    let mut ranges = Vec::with_capacity(compiled.functions.len());
    for function in &compiled.functions {
        let body = function_body_range(context, function)?;
        let range = context
            .source_text
            .match_indices(&function.source)
            .map(|(start, _)| SourceRange {
                start,
                end: start + function.source.len(),
            })
            .find(|range| range.start <= body.start && body.end <= range.end)
            .ok_or_else(|| {
                call_error(
                    "compiled function shell does not contain its staged body span",
                    &function.name,
                )
            })?;
        ranges.push(range);
    }
    Ok(ranges)
}

fn function_body_range(
    context: &ProjectionContext<'_>,
    function: &CompiledUserFunction,
) -> Result<SourceRange, SemanticIndexError> {
    let payload = function.body_payload.as_ref().ok_or_else(|| {
        call_error(
            "compiled function has no staged body payload",
            &function.name,
        )
    })?;
    let start = payload["source_span"]["start"]
        .as_u64()
        .and_then(|value| usize::try_from(value).ok())
        .ok_or_else(|| call_error("function body start is invalid", &function.name))?;
    let end = payload["source_span"]["end"]
        .as_u64()
        .and_then(|value| usize::try_from(value).ok())
        .ok_or_else(|| call_error("function body end is invalid", &function.name))?;
    let span = context.source_map.span_for_scalar_range(start, end)?;
    if context.source_text[span.start_byte..span.end_byte] != function.body_source {
        return Err(call_error(
            "staged function body span does not match compiled body source",
            &function.name,
        ));
    }
    Ok(SourceRange {
        start: span.start_byte,
        end: span.end_byte,
    })
}

fn action_owners(
    parsed: &SpecFile,
    compiled: &CompiledSpec,
    projection: &SemanticStaticProjection,
    context: &ProjectionContext<'_>,
) -> Result<Vec<ActionOwner>, SemanticIndexError> {
    let mut owners = Vec::new();
    for compiled_rule in &compiled.rules {
        let parsed_rule = parsed
            .rules
            .iter()
            .find(|rule| rule.header.label == compiled_rule.label)
            .ok_or_else(|| {
                call_error(
                    "compiled call owner has no parsed rule",
                    &compiled_rule.label,
                )
            })?;
        let mut authored = Vec::new();
        for element in &parsed_rule.body {
            match &element.kind {
                BodyElementKind::ActionEdge { targets, code, .. } => {
                    authored.extend((0..targets.len()).map(|_| code.clone()));
                }
                BodyElementKind::BlindEdge { code, .. } => authored.push(code.clone()),
                BodyElementKind::BareEdge { targets, code, .. } => {
                    authored.extend((0..targets.len()).map(|_| code.clone()));
                }
                _ => {}
            }
        }
        let compiled_count =
            compiled_rule.acode_dispatch.len() + compiled_rule.bcode_dispatch.len();
        if authored.len() != compiled_count {
            return Err(call_error(
                "authored and compiled call-owner counts differ",
                &compiled_rule.label,
            )
            .with_field("authored_edges", authored.len())
            .with_field("compiled_edges", compiled_count));
        }
        for (edge_order, authored_code) in authored.iter().enumerate() {
            let block = if edge_order < compiled_rule.acode_dispatch.len() {
                compiled_rule.acode_dispatch[edge_order].code.as_ref()
            } else {
                compiled_rule.bcode_dispatch[edge_order - compiled_rule.acode_dispatch.len()]
                    .code
                    .as_ref()
            };
            match (authored_code, block) {
                (None, None) => continue,
                (Some(_), None) | (None, Some(_)) => {
                    return Err(call_error(
                        "authored and compiled action-block presence differs",
                        &compiled_rule.label,
                    )
                    .with_field("edge_order", edge_order));
                }
                (Some(_code), Some(block)) => {
                    let owner_id = format!("edge:{}:{edge_order}", rule_id(&compiled_rule.label));
                    let source_key = format!("source_ref:{owner_id}");
                    let edge_source = projection
                        .source_refs
                        .get(&source_key)
                        .ok_or_else(|| call_error("action owner source is missing", &owner_id))?;
                    let edge_text = &context.source_text
                        [edge_source.span.start_byte..edge_source.span.end_byte];
                    let open = edge_text.find('{').ok_or_else(|| {
                        call_error("authored action block has no opening brace", &owner_id)
                    })?;
                    let close = edge_text.rfind('}').ok_or_else(|| {
                        call_error("authored action block has no closing brace", &owner_id)
                    })?;
                    if close < open {
                        return Err(call_error(
                            "authored action block braces are reversed",
                            &owner_id,
                        ));
                    }
                    let body_start = open + 1;
                    owners.push(ActionOwner {
                        owner_id,
                        block: block.clone(),
                        source_text: edge_text[body_start..close].to_string(),
                        source_start: edge_source.span.start_byte + body_start,
                    });
                }
            }
        }
    }
    Ok(owners)
}

fn infer_function_shapes(functions: &[CompiledUserFunction]) -> BTreeMap<String, Value> {
    let mut shapes = functions
        .iter()
        .map(|function| (function.name.clone(), value_shape("unknown")))
        .collect::<BTreeMap<_, _>>();
    for _ in 0..=functions.len() {
        let mut changed = false;
        for function in functions {
            let shape = function_return_shape(function, &shapes);
            if shapes[&function.name] != shape {
                shapes.insert(function.name.clone(), shape);
                changed = true;
            }
        }
        if !changed {
            break;
        }
    }
    shapes
}

fn function_return_shape(
    function: &CompiledUserFunction,
    function_shapes: &BTreeMap<String, Value>,
) -> Value {
    let mut variables = function
        .params
        .iter()
        .map(|name| (name.clone(), value_shape("unknown")))
        .collect::<BTreeMap<_, _>>();
    for statement in &function.body.statements {
        if let Expr::Call { name, args } = &statement.expr
            && name == "return"
            && let Some(argument) = args.first()
        {
            return infer_expr_shape(argument.value(), &variables, function_shapes);
        }
        if let Expr::AssignScalar { name, value } = &statement.expr {
            variables.insert(
                name.clone(),
                infer_expr_shape(value, &variables, function_shapes),
            );
        }
    }
    value_shape("unknown")
}

fn infer_expr_shape(
    expression: &Expr,
    variables: &BTreeMap<String, Value>,
    function_shapes: &BTreeMap<String, Value>,
) -> Value {
    match expression {
        Expr::StringLiteral { .. } => value_shape("string"),
        Expr::NumberLiteral { .. } => value_shape("number"),
        Expr::BooleanLiteral { .. } => value_shape("boolean"),
        Expr::Undef => value_shape("null"),
        Expr::CodeblockLiteral(literal) => codeblock_shape(&literal.signature),
        Expr::Variable { name } => variables
            .get(name)
            .cloned()
            .unwrap_or_else(|| value_shape("unknown")),
        Expr::AssignScalar { value, .. } => infer_expr_shape(value, variables, function_shapes),
        Expr::Call { name, args } => {
            if let Some(shape) = function_shapes.get(name) {
                return shape.clone();
            }
            if name == "return"
                && let Some(argument) = args.first()
            {
                return infer_expr_shape(argument.value(), variables, function_shapes);
            }
            helper_contract(name)
                .map(|contract| value_shape(contract.return_kind))
                .unwrap_or_else(|| value_shape("unknown"))
        }
        _ => value_shape("unknown"),
    }
}

fn function_signature(function: &CompiledUserFunction) -> Value {
    if let Some(signature) = &function.signature {
        let parameters = signature
            .positional_params
            .iter()
            .map(|name| json!({"name": name, "kind": "value", "required": true}))
            .collect::<Vec<_>>();
        return json!({
            "parameters": parameters,
            "arity_min": signature.min_arity,
            "arity_max": signature.max_arity,
            "rest_parameter": signature.rest_param,
            "final_codeblock": false,
        });
    }
    let parameters = function
        .params
        .iter()
        .map(|name| json!({"name": name, "kind": "value", "required": true}))
        .collect::<Vec<_>>();
    json!({
        "parameters": parameters,
        "arity_min": function.arity,
        "arity_max": function.arity,
        "rest_parameter": null,
        "final_codeblock": false,
    })
}

fn signature_from_parameters(parameters: &[(&str, &str)]) -> Value {
    let rows = parameters
        .iter()
        .map(|(name, kind)| json!({"name": name, "kind": kind, "required": true}))
        .collect::<Vec<_>>();
    json!({
        "parameters": rows,
        "arity_min": parameters.len(),
        "arity_max": parameters.len(),
        "rest_parameter": null,
        "final_codeblock": false,
    })
}

fn register_source(
    projection: &mut SemanticStaticProjection,
    context: &ProjectionContext<'_>,
    record_id: &str,
    range: SourceRange,
) -> Result<String, SemanticIndexError> {
    let span = context
        .source_map
        .span_for_byte_range(range.start, range.end)?;
    let key = format!("source_ref:{record_id}");
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

fn scan_calls(source: &str, source_start: usize) -> Result<Vec<CallSite>, SemanticIndexError> {
    let bytes = source.as_bytes();
    let mut sites = Vec::new();
    let mut index = 0;
    let mut quote = None;
    let mut escaped = false;
    while index < bytes.len() {
        let byte = bytes[index];
        if let Some(active) = quote {
            if escaped {
                escaped = false;
            } else if byte == b'\\' {
                escaped = true;
            } else if byte == active {
                quote = None;
            }
            index += 1;
            continue;
        }
        if matches!(byte, b'\'' | b'"') {
            quote = Some(byte);
            index += 1;
            continue;
        }
        if !is_identifier_start(byte) {
            index += 1;
            continue;
        }
        let name_start = index;
        index += 1;
        while index < bytes.len() && is_identifier_continue(bytes[index]) {
            index += 1;
        }
        let name_end = index;
        while index < bytes.len() && bytes[index].is_ascii_whitespace() {
            index += 1;
        }
        if index >= bytes.len() || bytes[index] != b'(' {
            continue;
        }
        let end = matching_parenthesis(source, index).ok_or_else(|| {
            call_error(
                "authored call has no balanced closing parenthesis",
                &source[name_start..name_end],
            )
        })?;
        sites.push(CallSite {
            name: source[name_start..name_end].to_string(),
            range: SourceRange {
                start: source_start + name_start,
                end: source_start + end,
            },
        });
        index = name_end;
    }
    Ok(sites)
}

fn matching_parenthesis(source: &str, open: usize) -> Option<usize> {
    let bytes = source.as_bytes();
    let mut depth = 0usize;
    let mut quote = None;
    let mut escaped = false;
    for (index, byte) in bytes.iter().copied().enumerate().skip(open) {
        if let Some(active) = quote {
            if escaped {
                escaped = false;
            } else if byte == b'\\' {
                escaped = true;
            } else if byte == active {
                quote = None;
            }
            continue;
        }
        if matches!(byte, b'\'' | b'"') {
            quote = Some(byte);
            continue;
        }
        match byte {
            b'(' => depth += 1,
            b')' => {
                depth = depth.checked_sub(1)?;
                if depth == 0 {
                    return Some(index + 1);
                }
            }
            _ => {}
        }
    }
    None
}

fn is_identifier_start(byte: u8) -> bool {
    byte.is_ascii_alphabetic() || byte == b'_'
}

fn is_identifier_continue(byte: u8) -> bool {
    byte.is_ascii_alphanumeric() || byte == b'_'
}

fn shape_kind(shape: &Value) -> &str {
    shape
        .get("kind")
        .and_then(Value::as_str)
        .unwrap_or("unknown")
}

fn function_id(name: &str) -> String {
    format!("function:{}", escape_name(name))
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

fn call_error(message: &str, identity: &str) -> SemanticIndexError {
    SemanticIndexError::new(
        "project_call_semantics",
        "semantic_call_correlation_failed",
        message,
    )
    .with_field("identity", identity)
}
