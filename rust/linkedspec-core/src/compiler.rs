//! Compiler — transforms parsed `SpecFile` AST into `CompiledSpec` for the runtime.
//!
//! The compiler:
//! 1. Extracts regex patterns from body elements
//! 2. Builds action-edge and blind-call dispatch tables
//! 3. Parses lifecycle code blocks into expression trees
//! 4. Determines parse mode (seek vs consume) per rule
//! 5. Extracts repetition bounds
//!
//! ## Action edge → regex association
//!
//! The compiler uses a two-phase model mirroring Perl's `build_dependency_regex_map`:
//!
//! **Phase 1 (per-rule)**: Tracks whether each action edge immediately follows a
//! `/regex/` element. Edges that do ("anchored") keep their parent regex index.
//! Edges that don't ("edge-only") get a placeholder `regex_idx = 0`.
//!
//! **Phase 2 (post-processing)**: `build_dependency_regex_map` runs after all
//! rules are compiled. For each edge-only entry, it looks up the child rule,
//! extracts the child's regex at `child_regex_idx`, appends it to the parent's
//! `regex_patterns`, and updates `regex_idx` to the new alternation position.
//!
//! Parent regexes always come first in the alternation; child-resolved regexes
//! are appended after. This matches Perl's semantics where `dependency_refs`
//! contribute child rule entrypoint regexes to the parent's LinkedRE alternation.
//!
//! The `[N]` in `-> rule[N]` is the *child* rule's regex entry slot, preserved
//! in `AcodeEntry.child_regex_idx` and used during Phase 2 resolution.

use crate::ast::{BodyElementKind, RegexSelector, Rule, SpecFile};
use crate::error::{LinkedSpecError, PortableDiagnostic, Result};
use crate::expr::{AccessSegment, Arg, CodeBlock, Expr, RemovedAggregateSelector};
use crate::trace::{TraceConfig, TraceEmitter, TraceLevel};
use crate::types::{
    AcodeEntry, AuthoredRegexSelector, BcodeEntry, CaptureGapsDirective, CompiledRule,
    CompiledSpec, CompiledUserFunction, DependencyRef, RegexSelectorKind, RegexSlot,
};

/// Portable duplicate regex-slot identity contract implemented by compiled
/// validation, descriptors, and every Rust execution route.
pub const REGEX_SLOT_IDENTITY_CONTRACT: &str = "linkedspec-duplicate-regex-slot-identity-v1";

/// Compile a parsed `SpecFile` into a `CompiledSpec` ready for the runtime.
pub fn compile(spec: &SpecFile) -> Result<CompiledSpec> {
    let mut functions = Vec::new();
    for function in &spec.functions {
        functions.push(compile_function(function)?);
    }

    let mut rules = Vec::new();
    for rule in &spec.rules {
        rules.push(compile_rule(rule, &spec.source_id)?);
    }
    let mut compiled = CompiledSpec { functions, rules };
    crate::callable_contract::normalize_compiled_spec(&mut compiled)
        .map_err(LinkedSpecError::Compile)?;
    validate_no_removed_aggregate_selectors(&compiled)?;
    validate_nested_write_nodes(&compiled)?;
    validate_receiver_mutation_nodes(&compiled)?;
    resolve_compiled_regex_selectors(&mut compiled)?;
    build_dependency_regex_map(&mut compiled)?;
    validate_recursive_observation_contract(&compiled)?;
    validate_progressive_span_dispatch_contract(&compiled)?;
    validate_staged_parse_job_contract(&compiled)?;
    validate_compiled_regex_slot_identities(&compiled)?;
    Ok(compiled)
}

/// Compile a parsed `SpecFile` with explicit trace configuration.
pub fn compile_with_trace(spec: &SpecFile, trace_config: TraceConfig) -> Result<CompiledSpec> {
    let mut trace = TraceEmitter::new(trace_config)?;
    compile_with_trace_emitter(spec, &mut trace)
}

/// Compile with a caller-owned trace emitter.
pub fn compile_with_trace_emitter(
    spec: &SpecFile,
    trace: &mut TraceEmitter,
) -> Result<CompiledSpec> {
    let scope = trace.enter_scope(
        "rust_core:compile",
        format!(
            "rules={} functions={}",
            spec.rules.len(),
            spec.functions.len()
        ),
        TraceLevel::LOW,
    )?;
    let result = compile_with_events(spec, trace);
    let exit_details = match &result {
        Ok(compiled) => format!(
            "status=ok rules={} functions={}",
            compiled.rules.len(),
            compiled.functions.len()
        ),
        Err(err) => format!("status=error error={err}"),
    };
    trace.exit_scope(scope, exit_details)?;
    result
}

fn compile_with_events(spec: &SpecFile, trace: &mut TraceEmitter) -> Result<CompiledSpec> {
    let mut functions = Vec::new();
    for (index, function) in spec.functions.iter().enumerate() {
        match compile_function(function) {
            Ok(compiled) => {
                trace.trace_decision(
                    "rust_core:compile:function",
                    true,
                    format!(
                        "index={index} name={} arity={}",
                        function.name, function.arity
                    ),
                    TraceLevel::MEDIUM,
                );
                functions.push(compiled);
            }
            Err(err) => {
                trace.trace_decision(
                    "rust_core:compile:function",
                    false,
                    format!(
                        "index={index} name={} arity={} error={err}",
                        function.name, function.arity
                    ),
                    TraceLevel::MEDIUM,
                );
                return Err(err);
            }
        }
    }

    let mut rules = Vec::new();
    for (index, rule) in spec.rules.iter().enumerate() {
        match compile_rule(rule, &spec.source_id) {
            Ok(compiled) => {
                trace.trace_decision(
                    "rust_core:compile:rule",
                    true,
                    format!(
                        "index={index} label={} mode={:?} cursor_policy={:?} regexes={} acode={} bcode={}",
                        compiled.label,
                        compiled.mode,
                        compiled.cursor_policy(),
                        compiled.regex_patterns.len(),
                        compiled.acode_dispatch.len(),
                        compiled.bcode_dispatch.len()
                    ),
                    TraceLevel::MEDIUM,
                );
                rules.push(compiled);
            }
            Err(err) => {
                trace.trace_decision(
                    "rust_core:compile:rule",
                    false,
                    format!(
                        "index={index} label={} mode={:?} error={err}",
                        rule.header.label, rule.header.mode
                    ),
                    TraceLevel::MEDIUM,
                );
                return Err(err);
            }
        }
    }

    let mut compiled = CompiledSpec { functions, rules };
    crate::callable_contract::normalize_compiled_spec(&mut compiled)
        .map_err(LinkedSpecError::Compile)?;
    validate_no_removed_aggregate_selectors(&compiled)?;
    validate_nested_write_nodes(&compiled)?;
    validate_receiver_mutation_nodes(&compiled)?;
    resolve_compiled_regex_selectors(&mut compiled)?;
    let edge_only_entries = compiled
        .rules
        .iter()
        .map(|rule| {
            rule.acode_dispatch
                .iter()
                .filter(|entry| !entry.has_parent_regex)
                .count()
        })
        .sum::<usize>();
    let regexes_before = compiled
        .rules
        .iter()
        .map(|rule| rule.regex_patterns.len())
        .sum::<usize>();
    let dependency_scope = trace.enter_scope(
        "rust_core:compile:dependency_regex_map",
        format!("edge_only_entries={edge_only_entries}"),
        TraceLevel::MEDIUM,
    )?;
    let dependency_result = build_dependency_regex_map(&mut compiled);
    let regexes_after = compiled
        .rules
        .iter()
        .map(|rule| rule.regex_patterns.len())
        .sum::<usize>();
    match &dependency_result {
        Ok(()) => {
            trace.trace_decision(
                "rust_core:compile:dependency_regex_map:result",
                true,
                format!(
                    "edge_only_entries={edge_only_entries} appended_regexes={}",
                    regexes_after.saturating_sub(regexes_before)
                ),
                TraceLevel::MEDIUM,
            );
        }
        Err(err) => {
            trace.trace_decision(
                "rust_core:compile:dependency_regex_map:result",
                false,
                format!("edge_only_entries={edge_only_entries} error={err}"),
                TraceLevel::MEDIUM,
            );
        }
    }
    trace.exit_scope(
        dependency_scope,
        match &dependency_result {
            Ok(()) => format!(
                "status=ok appended_regexes={}",
                regexes_after.saturating_sub(regexes_before)
            ),
            Err(err) => format!("status=error error={err}"),
        },
    )?;
    dependency_result?;
    validate_recursive_observation_contract(&compiled)?;
    validate_progressive_span_dispatch_contract(&compiled)?;
    validate_staged_parse_job_contract(&compiled)?;
    validate_compiled_regex_slot_identities(&compiled)?;

    Ok(compiled)
}

#[derive(Default)]
struct RecognitionEffectFacts {
    observes: bool,
    progressive_dispatch: bool,
    calls: Vec<String>,
    attempts: Vec<String>,
}

fn visit_expr(
    expr: &Expr,
    visitor: &mut impl FnMut(&Expr) -> std::result::Result<(), LinkedSpecError>,
) -> std::result::Result<(), LinkedSpecError> {
    visitor(expr)?;
    match expr {
        Expr::Call { args, .. } => visit_expr_args(args, visitor),
        Expr::AssignScalar { value, .. } | Expr::AssignArrayAppend { value, .. } => {
            visit_expr(value, visitor)
        }
        Expr::AssignHashIndex { key, value, .. } => {
            visit_expr(key, visitor)?;
            visit_expr(value, visitor)
        }
        Expr::AssignNestedAccess {
            segments, value, ..
        } => {
            visit_write_segments(segments, visitor)?;
            visit_expr(value, visitor)
        }
        Expr::ReceiverMutationChain {
            mutation,
            continuation,
            ..
        } => {
            visit_statements(&mutation.callback.body.statements, visitor)?;
            for call in continuation {
                visit_expr_args(&call.args, visitor)?;
            }
            Ok(())
        }
        Expr::IndexedVar { index, .. } => visit_expr(index, visitor),
        Expr::NestedAccess { segments, .. } => visit_expr_segments(segments, visitor),
        Expr::ValueAccess { receiver, segments } => {
            visit_expr(receiver, visitor)?;
            visit_expr_segments(segments, visitor)
        }
        Expr::ArrayLiteral { items } => {
            for item in items {
                visit_expr(item, visitor)?;
            }
            Ok(())
        }
        Expr::HashLiteral { entries } => {
            for entry in entries {
                visit_expr(&entry.key, visitor)?;
                visit_expr(&entry.value, visitor)?;
            }
            Ok(())
        }
        Expr::BlockValue { block } => visit_block(block, visitor),
        Expr::ContextualCodeblockCandidate(candidate) => {
            visit_statements(&candidate.codeblock.body_ast.statements, visitor)
        }
        Expr::CodeblockArgument(codeblock) | Expr::CodeblockLiteral(codeblock) => {
            visit_statements(&codeblock.body_ast.statements, visitor)
        }
        Expr::FluentChain { receiver, calls } => {
            visit_expr(receiver, visitor)?;
            for call in calls {
                visit_expr_args(&call.args, visitor)?;
            }
            Ok(())
        }
        Expr::RecognitionCheckpoint
        | Expr::ProgressiveDispatchSpan { .. }
        | Expr::StagedParseJobMarker { .. }
        | Expr::RecognizeOnce { .. }
        | Expr::ObserveRecognition { .. }
        | Expr::RecognitionCommit { .. }
        | Expr::RecognitionRollback { .. }
        | Expr::Variable { .. }
        | Expr::StringLiteral { .. }
        | Expr::NumberLiteral { .. }
        | Expr::BooleanLiteral { .. }
        | Expr::RegexLiteral { .. }
        | Expr::Undef => Ok(()),
    }
}

/// Reject every generic spelling that escaped the exclusive statement parser.
fn validate_progressive_span_dispatch_contract(spec: &CompiledSpec) -> Result<()> {
    let mut validate = |expr: &Expr| {
        if matches!(expr, Expr::Call { name, .. } if name == "dispatch_span") {
            return Err(LinkedSpecError::Compile(
                "LINKEDSPEC_PROGRESSIVE_SPAN_DISPATCH_ERROR:progressive_span_binding_required"
                    .to_owned(),
            ));
        }
        Ok(())
    };
    for rule in &spec.rules {
        for block in rule_blocks(rule) {
            visit_block(block, &mut validate)?;
        }
    }
    for function in &spec.functions {
        visit_block(&function.body, &mut validate)?;
    }
    Ok(())
}

/// Reject every generic parse-job spelling that escaped the exclusive assignment parser.
fn validate_staged_parse_job_contract(spec: &CompiledSpec) -> Result<()> {
    let mut validate = |expr: &Expr| {
        if matches!(expr, Expr::Call { name, .. } if name == "parse_job") {
            return Err(LinkedSpecError::Compile(
                "LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:staged_parse_job_options_required"
                    .to_owned(),
            ));
        }
        Ok(())
    };
    for rule in &spec.rules {
        for block in rule_blocks(rule) {
            visit_block(block, &mut validate)?;
        }
    }
    for function in &spec.functions {
        visit_block(&function.body, &mut validate)?;
    }
    Ok(())
}

fn visit_expr_args(
    args: &[Arg],
    visitor: &mut impl FnMut(&Expr) -> std::result::Result<(), LinkedSpecError>,
) -> std::result::Result<(), LinkedSpecError> {
    for argument in args {
        visit_expr(argument.value(), visitor)?;
    }
    Ok(())
}

fn visit_expr_segments(
    segments: &[AccessSegment],
    visitor: &mut impl FnMut(&Expr) -> std::result::Result<(), LinkedSpecError>,
) -> std::result::Result<(), LinkedSpecError> {
    for segment in segments {
        if let AccessSegment::Index { expr } = segment {
            visit_expr(expr, visitor)?;
        }
    }
    Ok(())
}

fn visit_write_segments(
    segments: &[crate::expr::WritePathSegment],
    visitor: &mut impl FnMut(&Expr) -> std::result::Result<(), LinkedSpecError>,
) -> std::result::Result<(), LinkedSpecError> {
    for segment in segments {
        visit_expr(&segment.expression, visitor)?;
    }
    Ok(())
}

fn visit_block(
    block: &CodeBlock,
    visitor: &mut impl FnMut(&Expr) -> std::result::Result<(), LinkedSpecError>,
) -> std::result::Result<(), LinkedSpecError> {
    visit_statements(&block.statements, visitor)
}

fn visit_statements(
    statements: &[crate::expr::Stmt],
    visitor: &mut impl FnMut(&Expr) -> std::result::Result<(), LinkedSpecError>,
) -> std::result::Result<(), LinkedSpecError> {
    for statement in statements {
        visit_expr(&statement.expr, visitor)?;
    }
    Ok(())
}

fn rule_blocks(rule: &CompiledRule) -> impl Iterator<Item = &CodeBlock> {
    [
        rule.preamble.as_ref(),
        rule.lxcode.as_ref(),
        rule.lscode.as_ref(),
        rule.lecode.as_ref(),
        rule.ecode.as_ref(),
        rule.excode.as_ref(),
        rule.itcode.as_ref(),
    ]
    .into_iter()
    .flatten()
    .chain(
        rule.acode_dispatch
            .iter()
            .filter_map(|entry| entry.code.as_ref()),
    )
    .chain(
        rule.bcode_dispatch
            .iter()
            .filter_map(|entry| entry.code.as_ref()),
    )
}

fn rule_reaches_forbidden_transaction_effect(
    node: &str,
    facts: &std::collections::BTreeMap<String, RecognitionEffectFacts>,
    visited: &mut std::collections::BTreeSet<String>,
) -> Option<&'static str> {
    if !visited.insert(node.to_owned()) {
        return None;
    }
    let Some(current) = facts.get(node) else {
        return None;
    };
    if current.observes {
        return Some("binding_write");
    }
    if current.progressive_dispatch {
        return Some("parser_registry_or_staged_dispatch");
    }
    current
        .calls
        .iter()
        .find_map(|callee| rule_reaches_forbidden_transaction_effect(callee, facts, visited))
}

/// Validate the dedicated static observation operand and its closed transaction effect.
fn validate_recursive_observation_contract(spec: &CompiledSpec) -> Result<()> {
    let rule_names = spec
        .rules
        .iter()
        .map(|rule| rule.label.as_str())
        .collect::<std::collections::BTreeSet<_>>();
    let function_names = spec
        .functions
        .iter()
        .map(|function| function.name.as_str())
        .collect::<std::collections::BTreeSet<_>>();
    let mut facts = std::collections::BTreeMap::new();

    let gather = |blocks: Vec<&CodeBlock>| -> Result<RecognitionEffectFacts> {
        let mut current = RecognitionEffectFacts::default();
        for block in blocks {
            visit_block(block, &mut |expr| {
                match expr {
                    Expr::ObserveRecognition { rule: callee, .. } => {
                        if !rule_names.contains(callee.as_str()) {
                            return Err(LinkedSpecError::Compile(
                                "LINKEDSPEC_SOURCE_LOCATION_ERROR:source_location_recursive_observation_operand"
                                    .to_owned(),
                            ));
                        }
                        current.observes = true;
                    }
                    Expr::ProgressiveDispatchSpan { .. } => {
                        current.progressive_dispatch = true;
                    }
                    Expr::StagedParseJobMarker { .. } => {
                        current.progressive_dispatch = true;
                    }
                    Expr::RecognizeOnce { rule: callee, .. } => {
                        current.attempts.push(format!("rule:{callee}"));
                    }
                    Expr::Call { name, args } if name == "call" => {
                        if let [Arg::Positional(Expr::Variable { name: callee })] = args.as_slice()
                        {
                            current.calls.push(format!("rule:{callee}"));
                        }
                    }
                    Expr::Call { name, .. } if function_names.contains(name.as_str()) => {
                        current.calls.push(format!("function:{name}"));
                    }
                    _ => {}
                }
                Ok(())
            })?;
        }
        Ok(current)
    };

    for rule in &spec.rules {
        facts.insert(
            format!("rule:{}", rule.label),
            gather(rule_blocks(rule).collect())?,
        );
    }
    for function in &spec.functions {
        facts.insert(
            format!("function:{}", function.name),
            gather(vec![&function.body])?,
        );
    }

    for current in facts.values() {
        for attempted_node in &current.attempts {
            if let Some(effect) = rule_reaches_forbidden_transaction_effect(
                attempted_node,
                &facts,
                &mut std::collections::BTreeSet::new(),
            ) {
                return Err(LinkedSpecError::Compile(format!(
                    "LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:recognition_effect_forbidden:{effect}"
                )));
            }
        }
    }
    Ok(())
}

fn removed_aggregate_selector_error(
    context: &str,
    selector: RemovedAggregateSelector,
) -> LinkedSpecError {
    LinkedSpecError::Compile(format!("{context}: {selector}"))
}

fn validate_code_block(
    block: &CodeBlock,
    context: &str,
) -> std::result::Result<(), LinkedSpecError> {
    if let Some(selector) = block.find_removed_aggregate_selector() {
        return Err(removed_aggregate_selector_error(context, selector));
    }
    Ok(())
}

fn validate_compiled_fluent_chain(
    chain: &[(String, String)],
    context: &str,
) -> std::result::Result<(), LinkedSpecError> {
    for (index, (method, args)) in chain.iter().enumerate() {
        let source = format!("{method}({args})");
        let Ok(block) = CodeBlock::parse(&source) else {
            // Fluent syntax historically remains runtime-parsed. This validator
            // must not turn an unrelated deferred parse failure into a new
            // compile-time language change.
            continue;
        };
        validate_code_block(&block, &format!("{context} fluent call {index}"))?;
    }
    Ok(())
}

/// Reject removed public aggregate selectors in every executable part of a
/// compiled specification.
///
/// This validator is public so serialized/generated `CompiledSpec` adapters can
/// enforce the same boundary before execution instead of trusting their payload.
pub fn validate_no_removed_aggregate_selectors(spec: &CompiledSpec) -> Result<()> {
    for function in &spec.functions {
        validate_code_block(
            &function.body,
            &format!("function '{}' body", function.name),
        )?;
    }

    for rule in &spec.rules {
        for (kind, block) in [
            ("I", rule.preamble.as_ref()),
            ("LX", rule.lxcode.as_ref()),
            ("LS", rule.lscode.as_ref()),
            ("LE", rule.lecode.as_ref()),
            ("E", rule.ecode.as_ref()),
            ("EX", rule.excode.as_ref()),
            ("IT", rule.itcode.as_ref()),
        ] {
            if let Some(block) = block {
                validate_code_block(block, &format!("rule '{}' {kind}-block", rule.label))?;
            }
        }

        for (index, entry) in rule.acode_dispatch.iter().enumerate() {
            if let Some(block) = &entry.code {
                validate_code_block(block, &format!("rule '{}' action edge {index}", rule.label))?;
            }
            validate_compiled_fluent_chain(
                &entry.fluent_chain,
                &format!("rule '{}' action edge {index}", rule.label),
            )?;
        }

        for (index, entry) in rule.bcode_dispatch.iter().enumerate() {
            if let Some(block) = &entry.code {
                validate_code_block(block, &format!("rule '{}' blind edge {index}", rule.label))?;
            }
            validate_compiled_fluent_chain(
                &entry.fluent_chain,
                &format!("rule '{}' blind edge {index}", rule.label),
            )?;
        }
    }

    Ok(())
}

fn nested_write_state_error(context: &str, reason: &str) -> LinkedSpecError {
    LinkedSpecError::Diagnostic(
        PortableDiagnostic::new(
            "nested_write_serialized_state_invalid",
            "validate_compiled_actionir",
            "Compiled nested-write ActionIR does not satisfy the typed v1 carrier contract",
        )
        .with_field("context", context.to_string())
        .with_field("reason", reason.to_string()),
    )
}

fn nested_write_root_is_reserved(name: &str) -> bool {
    matches!(
        name,
        "CAPTURE"
            | "IINDEX"
            | "IMATCH"
            | "IMATCH_HASH"
            | "IMATCH_LIST"
            | "IPOS"
            | "LINDEX"
            | "LMATCH"
            | "LMATCH_HASH"
            | "LMATCH_LIST"
            | "LSPOS"
            | "STRING"
            | "descr"
            | "false"
            | "info"
            | "minfo"
            | "null"
            | "retv"
            | "true"
            | "undef"
    )
}

fn char_slice(source: &str, start: usize, end: usize) -> Option<String> {
    if start > end {
        return None;
    }
    let value = source
        .chars()
        .skip(start)
        .take(end - start)
        .collect::<String>();
    (value.chars().count() == end - start).then_some(value)
}

fn receiver_mutation_state_error(context: &str, reason: &str) -> LinkedSpecError {
    LinkedSpecError::Diagnostic(
        PortableDiagnostic::new(
            "receiver_mutation_serialized_state_invalid",
            "validate_compiled_actionir",
            "Compiled receiver-mutation ActionIR does not satisfy the typed v1 carrier contract",
        )
        .with_field("context", context.to_string())
        .with_field("reason", reason.to_string()),
    )
}

fn span_projection(
    source: &str,
    containing_span: crate::expr::ExpressionSpan,
    span: crate::expr::ExpressionSpan,
) -> Option<String> {
    if span.start < containing_span.start || span.end > containing_span.end {
        return None;
    }
    char_slice(
        source,
        span.start - containing_span.start,
        span.end - containing_span.start,
    )
}

fn identifier_is_valid(name: &str) -> bool {
    !name.is_empty()
        && name
            .chars()
            .next()
            .is_some_and(|character| character.is_ascii_alphabetic() || character == '_')
        && name
            .chars()
            .all(|character| character.is_ascii_alphanumeric() || character == '_')
}

fn identifier_is_addressable(name: &str) -> bool {
    identifier_is_valid(name) && !nested_write_root_is_reserved(name)
}

fn validate_receiver_mutation_block(block: &CodeBlock, context: &str) -> Result<()> {
    for statement in &block.statements {
        visit_expr(&statement.expr, &mut |expr| {
            let Expr::ReceiverMutationChain {
                source,
                source_span,
                receiver,
                mutation,
                continuation,
            } = expr
            else {
                return Ok(());
            };
            if source_span.end.checked_sub(source_span.start) != Some(source.chars().count()) {
                return Err(receiver_mutation_state_error(
                    context,
                    "chain_source_span_mismatch",
                ));
            }
            if receiver.kind != "binding_reference"
                || receiver.source != receiver.name
                || !identifier_is_addressable(&receiver.name)
                || span_projection(source, *source_span, receiver.source_span).as_deref()
                    != Some(receiver.source.as_str())
            {
                return Err(receiver_mutation_state_error(
                    context,
                    "receiver_reference_invalid",
                ));
            }
            if mutation.kind != "receiver_mutation_call"
                || mutation.method != "map_leaves"
                || mutation.source_method != "map_leaves!"
                || span_projection(source, *source_span, mutation.source_span).as_deref()
                    != Some(mutation.source.as_str())
                || span_projection(source, *source_span, mutation.method_span).as_deref()
                    != Some("map_leaves!")
                || span_projection(source, *source_span, mutation.args_span).as_deref()
                    != Some("()")
                || mutation.source_span.start != mutation.method_span.start
            {
                return Err(receiver_mutation_state_error(
                    context,
                    "mutation_call_invalid",
                ));
            }
            let callback = &mutation.callback;
            let body = &callback.body;
            if callback.kind != "block_value"
                || body.kind != "action_block"
                || span_projection(source, *source_span, callback.source_span).as_deref()
                    != Some(callback.source.as_str())
                || span_projection(source, *source_span, body.source_span).as_deref()
                    != Some(body.source.as_str())
                || !callback.source.starts_with('{')
                || !callback.source.ends_with('}')
                || callback.source_span.start.checked_add(1) != Some(body.source_span.start)
                || body.source_span.end.checked_add(1) != Some(callback.source_span.end)
                || mutation.source_span.end != callback.source_span.end
            {
                return Err(receiver_mutation_state_error(
                    context,
                    "mutation_callback_invalid",
                ));
            }
            let mut prior_end = mutation.source_span.end;
            for call in continuation {
                if call.kind != "fluent_call"
                    || call.method.is_empty()
                    || call.method.contains('!')
                    || call.source_method != call.method
                    || !identifier_is_valid(&call.method)
                    || call.source_span.start < prior_end
                    || span_projection(source, *source_span, call.source_span).as_deref()
                        != Some(call.source.as_str())
                    || span_projection(source, *source_span, call.args_span).as_deref()
                        != Some(call.args_source.as_str())
                    || !call.source.starts_with(&call.source_method)
                    || call.args_span.start < call.source_span.start
                    || call.args_span.end > call.source_span.end
                {
                    return Err(receiver_mutation_state_error(
                        context,
                        "continuation_call_invalid",
                    ));
                }
                prior_end = call.source_span.end;
            }
            if continuation
                .last()
                .is_some_and(|call| call.source_span.end != source_span.end)
                || continuation.is_empty() && mutation.source_span.end != source_span.end
            {
                return Err(receiver_mutation_state_error(
                    context,
                    "chain_terminal_span_invalid",
                ));
            }
            Ok(())
        })?;
    }
    Ok(())
}

fn validate_nested_write_block(block: &CodeBlock, context: &str) -> Result<()> {
    for statement in &block.statements {
        visit_expr(&statement.expr, &mut |expr| {
            let Expr::AssignNestedAccess {
                source,
                source_span,
                base,
                segments,
                ..
            } = expr
            else {
                return Ok(());
            };
            if base.is_empty()
                || !base
                    .chars()
                    .next()
                    .is_some_and(|character| character.is_ascii_alphabetic() || character == '_')
                || !base
                    .chars()
                    .all(|character| character.is_ascii_alphanumeric() || character == '_')
                || nested_write_root_is_reserved(base)
            {
                return Err(nested_write_state_error(context, "base_not_addressable"));
            }
            if segments.is_empty() {
                return Err(nested_write_state_error(context, "segments_empty"));
            }
            let source_width = source_span.end.checked_sub(source_span.start);
            if source_width != Some(source.chars().count()) {
                return Err(nested_write_state_error(
                    context,
                    "assignment_source_span_mismatch",
                ));
            }
            for segment in segments {
                if segment.kind != "path_segment" || segment.source.is_empty() {
                    return Err(nested_write_state_error(
                        context,
                        "segment_kind_or_source_invalid",
                    ));
                }
                if segment.source_span.start < source_span.start
                    || segment.source_span.end > source_span.end
                    || segment.source_span.end < segment.source_span.start
                {
                    return Err(nested_write_state_error(
                        context,
                        "segment_source_span_out_of_bounds",
                    ));
                }
                let relative_start = segment.source_span.start - source_span.start;
                let relative_end = segment.source_span.end - source_span.start;
                if char_slice(source, relative_start, relative_end).as_deref()
                    != Some(segment.source.as_str())
                {
                    return Err(nested_write_state_error(
                        context,
                        "segment_source_span_mismatch",
                    ));
                }
            }
            Ok(())
        })?;
    }
    Ok(())
}

fn validate_nested_write_fluent_chain(chain: &[(String, String)], context: &str) -> Result<()> {
    for (index, (method, args)) in chain.iter().enumerate() {
        let source = format!("{method}({args})");
        let Ok(block) = CodeBlock::parse(&source) else {
            continue;
        };
        validate_nested_write_block(&block, &format!("{context} fluent call {index}"))?;
    }
    Ok(())
}

/// Validate every typed nested-write node before native or serialized/generated execution.
pub fn validate_nested_write_nodes(spec: &CompiledSpec) -> Result<()> {
    for function in &spec.functions {
        validate_nested_write_block(
            &function.body,
            &format!("function '{}' body", function.name),
        )?;
    }
    for rule in &spec.rules {
        for (kind, block) in [
            ("I", rule.preamble.as_ref()),
            ("LX", rule.lxcode.as_ref()),
            ("LS", rule.lscode.as_ref()),
            ("LE", rule.lecode.as_ref()),
            ("E", rule.ecode.as_ref()),
            ("EX", rule.excode.as_ref()),
            ("IT", rule.itcode.as_ref()),
        ] {
            if let Some(block) = block {
                validate_nested_write_block(block, &format!("rule '{}' {kind}-block", rule.label))?;
            }
        }
        for (index, entry) in rule.acode_dispatch.iter().enumerate() {
            if let Some(block) = &entry.code {
                validate_nested_write_block(
                    block,
                    &format!("rule '{}' action edge {index}", rule.label),
                )?;
            }
            validate_nested_write_fluent_chain(
                &entry.fluent_chain,
                &format!("rule '{}' action edge {index}", rule.label),
            )?;
        }
        for (index, entry) in rule.bcode_dispatch.iter().enumerate() {
            if let Some(block) = &entry.code {
                validate_nested_write_block(
                    block,
                    &format!("rule '{}' blind edge {index}", rule.label),
                )?;
            }
            validate_nested_write_fluent_chain(
                &entry.fluent_chain,
                &format!("rule '{}' blind edge {index}", rule.label),
            )?;
        }
    }
    Ok(())
}

/// Validate every typed receiver-mutation node before native or serialized/generated execution.
pub fn validate_receiver_mutation_nodes(spec: &CompiledSpec) -> Result<()> {
    for function in &spec.functions {
        validate_receiver_mutation_block(
            &function.body,
            &format!("function '{}' body", function.name),
        )?;
    }
    for rule in &spec.rules {
        for (kind, block) in [
            ("I", rule.preamble.as_ref()),
            ("LX", rule.lxcode.as_ref()),
            ("LS", rule.lscode.as_ref()),
            ("LE", rule.lecode.as_ref()),
            ("E", rule.ecode.as_ref()),
            ("EX", rule.excode.as_ref()),
            ("IT", rule.itcode.as_ref()),
        ] {
            if let Some(block) = block {
                validate_receiver_mutation_block(
                    block,
                    &format!("rule '{}' {kind}-block", rule.label),
                )?;
            }
        }
        for (index, entry) in rule.acode_dispatch.iter().enumerate() {
            if let Some(block) = &entry.code {
                validate_receiver_mutation_block(
                    block,
                    &format!("rule '{}' action edge {index}", rule.label),
                )?;
            }
        }
        for (index, entry) in rule.bcode_dispatch.iter().enumerate() {
            if let Some(block) = &entry.code {
                validate_receiver_mutation_block(
                    block,
                    &format!("rule '{}' blind edge {index}", rule.label),
                )?;
            }
        }
    }
    Ok(())
}

/// Validate every compiled action edge's structural target-rule/regex-index
/// identity after dependency regex resolution.
///
/// Serialized and generated adapters call the same validator before execution
/// so malformed compiled state cannot be interpreted as an ordinary miss.
pub fn validate_compiled_regex_slot_identities(spec: &CompiledSpec) -> Result<()> {
    for rule in &spec.rules {
        for entry in &rule.acode_dispatch {
            let target_exists = spec
                .find(&entry.child_label)
                .is_some_and(|target| entry.child_regex_idx < target.regex_patterns.len());
            let dispatch_exists = entry.regex_idx < rule.regex_patterns.len();
            if target_exists && dispatch_exists {
                continue;
            }
            return Err(LinkedSpecError::Diagnostic(
                PortableDiagnostic::new(
                    "regex_slot_identity_invalid",
                    "validate_compiled_rule",
                    format!(
                        "compiled action edge in rule '{}' references missing structural slot '{}#{}'",
                        rule.label, entry.child_label, entry.child_regex_idx
                    ),
                )
                .with_field("rule_label", rule.label.clone())
                .with_field("target_rule", entry.child_label.clone())
                .with_field("regex_index", entry.child_regex_idx),
            ));
        }
    }
    Ok(())
}

fn compile_function(function: &crate::ast::FunctionDefinition) -> Result<CompiledUserFunction> {
    let body = if let Some(body_ast) = &function.body_ast {
        serde_json::from_value::<CodeBlock>(body_ast.clone()).map_err(|e| {
            LinkedSpecError::Compile(format!(
                "function '{}': failed to compile dispatched body AST: {e}",
                function.name
            ))
        })?
    } else {
        CodeBlock::parse_with_callable_candidates(&function.body_source).map_err(|e| {
            LinkedSpecError::Compile(format!(
                "function '{}': failed to parse body code: {e}",
                function.name
            ))
        })?
    };

    Ok(CompiledUserFunction {
        name: function.name.clone(),
        params: function.params.clone(),
        arity: function.arity,
        parameter_kinds: function.parameter_kinds.clone(),
        signature: function.signature.clone(),
        body,
        body_source: function.body_source.clone(),
        body_payload: function.body_payload.clone(),
        body_parse_job: function.body_parse_job.clone(),
        body_ast: function.body_ast.clone(),
        source: function.source.clone(),
        source_span: function.source_span.clone(),
        body_span: function.body_span.clone(),
    })
}

fn parse_rule_code_block(
    rule_label: &str,
    code_kind: &str,
    code: &str,
) -> Result<Option<CodeBlock>> {
    match CodeBlock::parse_with_callable_candidates(code) {
        Ok(block) => Ok(Some(block)),
        Err(err) if is_fail_closed_actionir_error(&err) => Err(LinkedSpecError::Compile(format!(
            "rule '{rule_label}': failed to parse {code_kind} code: {err}"
        ))),
        Err(err) => {
            eprintln!("warning: rule '{rule_label}': failed to parse {code_kind} code: {err}");
            Ok(None)
        }
    }
}

fn is_fail_closed_actionir_error(error: &str) -> bool {
    error.contains("LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:")
        || error.contains("LINKEDSPEC_SOURCE_LOCATION_ERROR:")
        || error.contains("LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:")
        || error.contains("LINKEDSPEC_PROGRESSIVE_SPAN_DISPATCH_ERROR:")
        || error.contains("LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:")
}

fn append_lifecycle_block(slot: &mut Option<CodeBlock>, mut block: CodeBlock) {
    if let Some(existing) = slot {
        existing.statements.append(&mut block.statements);
    } else {
        *slot = Some(block);
    }
}

fn compile_rule(rule: &Rule, source_id: &str) -> Result<CompiledRule> {
    let mut regex_patterns: Vec<String> = Vec::new();
    let mut regex_slots: Vec<RegexSlot> = Vec::new();
    let mut dependency_refs: Vec<DependencyRef> = Vec::new();
    let mut acode_dispatch: Vec<AcodeEntry> = Vec::new();
    let mut bcode_dispatch: Vec<BcodeEntry> = Vec::new();
    let mut preamble: Option<CodeBlock> = None;
    let mut lxcode: Option<CodeBlock> = None;
    let mut lscode: Option<CodeBlock> = None;
    let mut lecode: Option<CodeBlock> = None;
    let mut ecode: Option<CodeBlock> = None;
    let mut excode: Option<CodeBlock> = None;
    let mut itcode: Option<CodeBlock> = None;
    let mut capture_gaps: Option<CaptureGapsDirective> = None;

    // Track the source line of the last `/regex/` element seen.
    // An action edge is "anchored" (has_parent_regex = true) only when it
    // appears on the SAME source line as the regex (e.g. `/pat/ -> Child`).
    // Edges on their own line (different line number) are "edge-only" and
    // will be resolved in Phase 2 post-processing.
    let mut current_regex_idx: usize = 0;
    let mut last_regex_line: Option<usize> = None;

    for element in &rule.body {
        match &element.kind {
            BodyElementKind::Regex { pattern, slot_id } => {
                let regex_index = regex_patterns.len();
                regex_patterns.push(pattern.clone());
                regex_slots.push(RegexSlot {
                    regex_index,
                    slot_id: slot_id.clone(),
                    source_id: source_id.to_string(),
                    line: element.line,
                });
                current_regex_idx += 1;
                last_regex_line = Some(element.line);
            }

            BodyElementKind::ActionEdge {
                targets,
                code,
                fluent_chain,
            } => {
                // An edge is anchored iff it shares the same source line as
                // the immediately preceding regex (same-line adjacency).
                let has_parent = last_regex_line == Some(element.line);
                let triggering_regex_idx = if has_parent && current_regex_idx > 0 {
                    current_regex_idx - 1
                } else {
                    0 // placeholder; post-processing fixes edge-only entries
                };

                let parsed_code = code
                    .as_deref()
                    .map(|c| parse_rule_code_block(&rule.header.label, "action", c))
                    .transpose()?
                    .flatten();
                let fluent: Vec<(String, String)> = fluent_chain
                    .iter()
                    .map(|fc| (fc.method.clone(), fc.args.clone()))
                    .collect();

                for target in targets {
                    let (selector_kind, authored_selector, child_regex_idx) =
                        compiled_selector(&target.selector);
                    dependency_refs.push(DependencyRef {
                        label: target.label.clone(),
                        index: child_regex_idx,
                        selector_kind: selector_kind.clone(),
                        authored_selector: authored_selector.clone(),
                        target_slot_id: None,
                    });
                    acode_dispatch.push(AcodeEntry {
                        regex_idx: triggering_regex_idx,
                        child_label: target.label.clone(),
                        child_regex_idx,
                        code: parsed_code.clone(),
                        fluent_chain: fluent.clone(),
                        has_parent_regex: has_parent,
                        selector_kind,
                        authored_selector,
                        target_slot_id: None,
                        source_id: source_id.to_string(),
                        line: element.line,
                    });
                }

                last_regex_line = None;
            }

            BodyElementKind::BlindEdge {
                target,
                code,
                fluent_chain,
                ..
            } => {
                last_regex_line = None;
                dependency_refs.push(DependencyRef {
                    label: target.clone(),
                    index: 0,
                    selector_kind: RegexSelectorKind::Unindexed,
                    authored_selector: None,
                    target_slot_id: None,
                });
                let parsed_code = code
                    .as_deref()
                    .map(|c| parse_rule_code_block(&rule.header.label, "blind-call", c))
                    .transpose()?
                    .flatten();

                // Preserve fluent chain as structured data (method_name, args_string).
                let fluent: Vec<(String, String)> = fluent_chain
                    .iter()
                    .map(|fc| (fc.method.clone(), fc.args.clone()))
                    .collect();

                bcode_dispatch.push(BcodeEntry {
                    child_label: target.clone(),
                    code: parsed_code,
                    fluent_chain: fluent,
                });
            }

            BodyElementKind::BareEdge {
                targets,
                code,
                fluent_chain,
            } => {
                last_regex_line = None;
                let fluent: Vec<(String, String)> = fluent_chain
                    .iter()
                    .map(|call| (call.method.clone(), call.args.clone()))
                    .collect();

                if rule.header.mode.is_and() {
                    let target = targets.first().ok_or_else(|| {
                        LinkedSpecError::Compile(format!(
                            "rule '{}': normalized bare edge has no target",
                            rule.header.label
                        ))
                    })?;
                    dependency_refs.push(DependencyRef {
                        label: target.label.clone(),
                        index: 0,
                        selector_kind: RegexSelectorKind::Unindexed,
                        authored_selector: None,
                        target_slot_id: None,
                    });
                    let parsed_code = code
                        .as_deref()
                        .map(|source| {
                            parse_rule_code_block(&rule.header.label, "blind-call", source)
                        })
                        .transpose()?
                        .flatten();
                    bcode_dispatch.push(BcodeEntry {
                        child_label: target.label.clone(),
                        code: parsed_code,
                        fluent_chain: fluent,
                    });
                } else {
                    let parsed_code = code
                        .as_deref()
                        .map(|source| parse_rule_code_block(&rule.header.label, "action", source))
                        .transpose()?
                        .flatten();
                    for target in targets {
                        let (selector_kind, authored_selector, child_regex_idx) =
                            compiled_selector(&target.selector);
                        dependency_refs.push(DependencyRef {
                            label: target.label.clone(),
                            index: child_regex_idx,
                            selector_kind: selector_kind.clone(),
                            authored_selector: authored_selector.clone(),
                            target_slot_id: None,
                        });
                        acode_dispatch.push(AcodeEntry {
                            regex_idx: 0,
                            child_label: target.label.clone(),
                            child_regex_idx,
                            code: parsed_code.clone(),
                            fluent_chain: fluent.clone(),
                            has_parent_regex: false,
                            selector_kind,
                            authored_selector,
                            target_slot_id: None,
                            source_id: source_id.to_string(),
                            line: element.line,
                        });
                    }
                }
            }

            BodyElementKind::CodeBlock { lifecycle, code } => {
                last_regex_line = None;
                let parsed = parse_rule_code_block(
                    &rule.header.label,
                    &format!("{lifecycle} -block"),
                    code,
                )?;
                if let Some(block) = parsed {
                    match lifecycle.as_str() {
                        "I" => append_lifecycle_block(&mut preamble, block),
                        "LS" => lscode = Some(block),
                        "LE" => lecode = Some(block),
                        "E" => ecode = Some(block),
                        "EX" => excode = Some(block),
                        "IT" => itcode = Some(block),
                        "LX" => lxcode = Some(block),
                        _ => {}
                    }
                }
            }

            // Lifecycle markers without code blocks — reset adjacency tracking.
            BodyElementKind::LifecycleMarker { .. } => {
                last_regex_line = None;
            }
            // Fluent chains on action edges are handled by attaching code to the
            // action edge itself — they're already in the ActionEdge.code field.
            BodyElementKind::FluentChain { .. } => {
                last_regex_line = None;
            }
            // Conditional markers (`-? word`) are consumed by the runtime.
            BodyElementKind::Conditional { .. } => {
                last_regex_line = None;
            }
            // Split markers (@capture_slice, @mark) are consumed by the runtime
            // during regex matching — no compile-time action needed.
            BodyElementKind::SplitMarker { .. } => {
                last_regex_line = None;
            }
            BodyElementKind::CaptureGapsDirective { directive } => {
                last_regex_line = None;
                capture_gaps = Some(CaptureGapsDirective {
                    enabled: true,
                    directive: directive.clone(),
                    source_id: source_id.to_string(),
                    line: element.line,
                });
            }
            // Plain code blocks and raw text are unexpected at compile time.
            BodyElementKind::PlainBlock { .. } | BodyElementKind::Raw { .. } => {
                last_regex_line = None;
            }
        }
    }

    let rep_min = rule.header.mode.rep_min();
    let rep_max = rule.header.mode.rep_max();

    Ok(CompiledRule {
        label: rule.header.label.clone(),
        is_top: rule.header.is_top,
        mode: rule.header.mode.clone(),
        regex_patterns,
        regex_slots,
        capture_gaps,
        dependency_refs,
        acode_dispatch,
        bcode_dispatch,
        preamble,
        lxcode,
        lscode,
        lecode,
        ecode,
        excode,
        itcode,
        rep_min,
        rep_max,
    })
}

fn compiled_selector(
    selector: &RegexSelector,
) -> (RegexSelectorKind, Option<AuthoredRegexSelector>, usize) {
    match selector {
        RegexSelector::Unindexed => (RegexSelectorKind::Unindexed, None, 0),
        RegexSelector::Numeric(index) => (
            RegexSelectorKind::Numeric,
            Some(AuthoredRegexSelector::Numeric(*index)),
            *index,
        ),
        RegexSelector::Named(name) => (
            RegexSelectorKind::Named,
            Some(AuthoredRegexSelector::Named(name.clone())),
            0,
        ),
        RegexSelector::Invalid(authored) => (
            RegexSelectorKind::Named,
            Some(AuthoredRegexSelector::Named(authored.clone())),
            0,
        ),
    }
}

/// Resolve every selector against the target rule's authored declaration rows
/// before dependency regex expansion. Validation has already issued authored
/// diagnostics; this pass also fails closed for programmatic AST callers.
fn resolve_compiled_regex_selectors(spec: &mut CompiledSpec) -> Result<()> {
    struct ActionResolution {
        rule_index: usize,
        entry_index: usize,
        regex_index: usize,
        slot_id: Option<String>,
    }

    struct DependencyResolution {
        rule_index: usize,
        dependency_index: usize,
        regex_index: usize,
        slot_id: Option<String>,
    }

    fn resolve_selector(
        source_rule: &str,
        target: &CompiledRule,
        selector_kind: &RegexSelectorKind,
        authored_selector: &Option<AuthoredRegexSelector>,
        numeric_fallback: usize,
        source_id: &str,
        line: usize,
    ) -> Result<(usize, Option<String>)> {
        let regex_index = match (selector_kind, authored_selector) {
            (RegexSelectorKind::Named, Some(AuthoredRegexSelector::Named(name))) => target
                .regex_slots
                .iter()
                .find(|slot| slot.slot_id.as_deref() == Some(name.as_str()))
                .map(|slot| slot.regex_index)
                .ok_or_else(|| {
                    LinkedSpecError::Diagnostic(
                        PortableDiagnostic::new(
                            "regex_slot_unknown_name",
                            "resolve_selector",
                            format!(
                                "action edge in rule '{source_rule}' selects unknown slot '{name}' in target '{}'",
                                target.label
                            ),
                        )
                        .with_field("rule_label", source_rule.to_string())
                        .with_field("source_id", source_id.to_string())
                        .with_field("line", line)
                        .with_field("target_rule", target.label.clone())
                        .with_field("authored_selector", name.clone()),
                    )
                })?,
            _ => numeric_fallback,
        };
        let slot_id = target
            .regex_slots
            .get(regex_index)
            .and_then(|slot| slot.slot_id.clone());
        Ok((regex_index, slot_id))
    }

    let mut action_resolutions = Vec::new();
    for (rule_index, rule) in spec.rules.iter().enumerate() {
        for (entry_index, entry) in rule.acode_dispatch.iter().enumerate() {
            let Some(target) = spec.find(&entry.child_label) else {
                if entry.selector_kind == RegexSelectorKind::Named {
                    return Err(LinkedSpecError::Compile(format!(
                        "rule '{}': named-selector target '{}' is not compiled",
                        rule.label, entry.child_label
                    )));
                }
                continue;
            };
            let (regex_index, slot_id) = resolve_selector(
                &rule.label,
                target,
                &entry.selector_kind,
                &entry.authored_selector,
                entry.child_regex_idx,
                &entry.source_id,
                entry.line,
            )?;
            action_resolutions.push(ActionResolution {
                rule_index,
                entry_index,
                regex_index,
                slot_id,
            });
        }
    }

    let mut dependency_resolutions = Vec::new();
    for (rule_index, rule) in spec.rules.iter().enumerate() {
        for (dependency_index, dependency) in rule.dependency_refs.iter().enumerate() {
            let Some(target) = spec.find(&dependency.label) else {
                if dependency.selector_kind == RegexSelectorKind::Named {
                    return Err(LinkedSpecError::Compile(format!(
                        "rule '{}': named-selector dependency target '{}' is not compiled",
                        rule.label, dependency.label
                    )));
                }
                continue;
            };
            let (regex_index, slot_id) = resolve_selector(
                &rule.label,
                target,
                &dependency.selector_kind,
                &dependency.authored_selector,
                dependency.index,
                "inline",
                0,
            )?;
            dependency_resolutions.push(DependencyResolution {
                rule_index,
                dependency_index,
                regex_index,
                slot_id,
            });
        }
    }

    for resolution in action_resolutions {
        let rule = &mut spec.rules[resolution.rule_index];
        let entry = &mut rule.acode_dispatch[resolution.entry_index];
        entry.child_regex_idx = resolution.regex_index;
        entry.target_slot_id = resolution.slot_id;
    }
    for resolution in dependency_resolutions {
        let dependency =
            &mut spec.rules[resolution.rule_index].dependency_refs[resolution.dependency_index];
        dependency.index = resolution.regex_index;
        dependency.target_slot_id = resolution.slot_id;
    }
    Ok(())
}

/// Resolve edge-only action entries by looking up child rules' regex patterns.
///
/// This is the Rust equivalent of Perl's `LinkedSpec::Compiler::build_dependency_regex_map`.
///
/// For each rule, entries with `has_parent_regex == false` ("edge-only") have no
/// parent regex to trigger on. Instead, the child rule's regex at `child_regex_idx`
/// is appended to this rule's alternation, and `regex_idx` is updated to point to
/// the new alternation position.
///
/// Parent regexes always come first (positions 0..P-1). Child-resolved regexes
/// are appended at positions P..P+C-1. Anchored entries (`has_parent_regex == true`)
/// are untouched — they keep their parent regex positions.
///
/// Self-recursive entries (`-> SameRule[N]`) resolve against the rule's own
/// already-populated parent regexes, duplicating them at new alternation positions.
pub fn build_dependency_regex_map(spec: &mut CompiledSpec) -> Result<()> {
    // Collect all edge-only resolutions first (to avoid simultaneous
    // mutable borrow of rules + immutable borrow of spec for find()).
    struct EdgeResolution {
        rule_idx: usize,
        entry_idx: usize,
        child_label: String,
        child_regex_idx: usize,
    }

    let mut resolutions: Vec<EdgeResolution> = Vec::new();
    for (rule_idx, rule) in spec.rules.iter().enumerate() {
        for (entry_idx, entry) in rule.acode_dispatch.iter().enumerate() {
            if !entry.has_parent_regex {
                resolutions.push(EdgeResolution {
                    rule_idx,
                    entry_idx,
                    child_label: entry.child_label.clone(),
                    child_regex_idx: entry.child_regex_idx,
                });
            }
        }
    }

    // Resolve each edge-only entry against child rules.
    // Following Perl's Compiler.pm:393-410, missing/out-of-bounds regex
    // indices are warned and skipped, not treated as compilation errors.
    //
    // Self-recursive entries (-> SameRule[N]) are a special case: the child
    // regex is already in this rule's alternation at its parent position.
    // Instead of duplicating it, point regex_idx directly at the parent slot.
    for res in &resolutions {
        let rule_label = spec.rules[res.rule_idx].label.clone();

        // Self-recursive: the child is the same rule.  The parent regex at
        // child_regex_idx is already in this rule's alternation (positions
        // 0..parent_count-1), so just point regex_idx at it directly.
        if res.child_label == rule_label {
            let parent_count = spec.rules[res.rule_idx].regex_patterns.len();
            if res.child_regex_idx < parent_count {
                spec.rules[res.rule_idx].acode_dispatch[res.entry_idx].regex_idx =
                    res.child_regex_idx;
            } else {
                eprintln!(
                    "warning: rule '{}': self-recursive entry '-> {}[{}]' \
                     references out-of-bounds regex index {} (has {} parent \
                     regexes) — entry will never fire",
                    rule_label,
                    res.child_label,
                    res.child_regex_idx,
                    res.child_regex_idx,
                    parent_count
                );
            }
            continue;
        }

        let child = match spec.find(&res.child_label) {
            Some(c) => c,
            None => {
                eprintln!(
                    "warning: rule '{}': edge-only entry '-> {}[{}]' \
                     references unknown rule '{}' — entry will never fire",
                    rule_label, res.child_label, res.child_regex_idx, res.child_label
                );
                continue;
            }
        };

        if res.child_regex_idx >= child.regex_patterns.len() {
            eprintln!(
                "warning: rule '{}': edge-only entry '-> {}[{}]' \
                 references out-of-bounds regex index {} in child rule \
                 '{}' (has {} regexes) — entry will never fire",
                rule_label,
                res.child_label,
                res.child_regex_idx,
                res.child_regex_idx,
                res.child_label,
                child.regex_patterns.len()
            );
            continue;
        }

        let resolved_pattern = child.regex_patterns[res.child_regex_idx].clone();
        let rule = &mut spec.rules[res.rule_idx];
        let new_regex_idx = rule.regex_patterns.len();
        rule.regex_patterns.push(resolved_pattern);
        rule.acode_dispatch[res.entry_idx].regex_idx = new_regex_idx;
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ast::{FunctionDefinition, SourceSpan};
    use crate::parser::parse_spec;
    use crate::types::ParseMode;

    fn spec_with_user_functions(functions: Vec<FunctionDefinition>, rules_src: &str) -> SpecFile {
        let mut spec = parse_spec(rules_src).unwrap();
        spec.functions = functions;
        spec
    }

    fn user_function(name: &str, params: &[&str], body_source: &str) -> FunctionDefinition {
        FunctionDefinition {
            name: name.to_string(),
            params: params.iter().map(|param| param.to_string()).collect(),
            arity: params.len(),
            parameter_kinds: Default::default(),
            signature: None,
            body_source: body_source.to_string(),
            body_payload: None,
            body_parse_job: None,
            body_ast: None,
            source: format!("fn {name}({}) {{ {body_source} }}", params.join(", ")),
            source_span: SourceSpan {
                line_start: 1,
                line_end: 3,
            },
            body_span: SourceSpan {
                line_start: 1,
                line_end: 3,
            },
        }
    }

    #[test]
    fn compile_simple_spec() {
        let src = "DemoParser::\n /pattern1/ -> Child {\n  return(42)\n }\n\nChild:\n /hello/ E { return(undef) }";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        assert_eq!(compiled.rules.len(), 2);
        assert_eq!(compiled.rules[0].label, "DemoParser");
        assert!(compiled.rules[0].is_top);
        assert_eq!(compiled.rules[0].cursor_policy(), ParseMode::Seek);
    }

    #[test]
    fn compile_lifecycle_blocks() {
        let src = "Top::\n /x/ I { set(results, []) } LE { push(results, retv) } E { return(copy(results)) }";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        assert!(compiled.rules[0].preamble.is_some()); // I-block
        assert!(compiled.rules[0].lecode.is_some()); // LE-block
        assert!(compiled.rules[0].ecode.is_some()); // E-block
    }

    #[test]
    fn compile_lifecycle_compact_fluent_chains() {
        let src = r#"Top::
 I.set(out, undef).set(out, "ok")
 /x/
 E.return(out)
"#;
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        assert!(
            compiled.rules[0].preamble.is_some(),
            "I.compact fluent chain should compile as lifecycle preamble code"
        );
        assert!(
            compiled.rules[0].ecode.is_some(),
            "E.compact fluent chain should compile as lifecycle E code"
        );
    }

    #[test]
    fn compile_handles_and_mode() {
        let src = "Top::AND\n /a/ /b/";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        assert_eq!(compiled.rules[0].cursor_policy(), ParseMode::Consume);
    }

    #[test]
    fn compile_derives_policy_only_from_authored_family() {
        let pipe = parse_spec("Top::|\n /x/ -> Top { return(\"hit\") }\n").unwrap();
        let pipe = compile(&pipe).unwrap();
        assert!(!pipe.rules[0].mode.is_and());
        assert_eq!(
            pipe.rules[0].cursor_policy(),
            ParseMode::Seek,
            "compact | must spend authored OR policy in live execution"
        );
        let blind = parse_spec("Top::\n => Child\n\nChild:\n /x/\n").unwrap();
        let blind = compile(&blind).unwrap();
        assert_eq!(blind.rules[0].bcode_dispatch.len(), 1);
        assert_eq!(blind.rules[0].cursor_policy(), ParseMode::Seek);
    }

    #[test]
    fn compile_default_mode_is_zero_min_repeated_choice() {
        let src = "Top::\n /a/";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        assert_eq!(compiled.rules[0].cursor_policy(), ParseMode::Seek);
        assert_eq!(compiled.rules[0].rep_min, Some(0));
        assert_eq!(compiled.rules[0].rep_max, None);
    }

    #[test]
    fn compile_extracts_regex_patterns() {
        let src = "Top::\n /hello/ /world/";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        assert_eq!(compiled.rules[0].regex_patterns.len(), 2);
    }

    #[test]
    fn compile_serialize_deserialize() {
        let src = "Top::\n /x/ I { set(r, []) } LE { push(r, retv) } E { return(copy(r)) }";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let json = serde_json::to_string(&compiled).unwrap();
        let _back: CompiledSpec = serde_json::from_str(&json).unwrap();
    }

    #[test]
    fn compile_user_function_registry() {
        let spec = spec_with_user_functions(
            vec![user_function(
                "normalize",
                &["value"],
                "return(trim(value))",
            )],
            "Top::\n /x/\n",
        );
        let compiled = compile(&spec).unwrap();
        assert_eq!(compiled.functions.len(), 1);
        let function = compiled.find_function("normalize").unwrap();
        assert_eq!(function.name, "normalize");
        assert_eq!(function.params, vec!["value".to_string()]);
        assert_eq!(function.arity, 1);
        assert_eq!(function.source_span.line_start, 1);
        assert_eq!(function.source_span.line_end, 3);
        assert_eq!(function.body_source, "return(trim(value))");
        assert_eq!(function.body.statements.len(), 1);
        assert_eq!(compiled.rules.len(), 1);
        assert_eq!(compiled.rules[0].label, "Top");
    }

    #[test]
    fn compile_user_function_body_parse_error_is_compile_error() {
        let spec = spec_with_user_functions(
            vec![user_function("bad", &["value"], "return(@invalid)")],
            "Top::\n /x/\n",
        );
        let err = compile(&spec).unwrap_err().to_string();
        assert!(err.contains("function 'bad': failed to parse body code"));
    }

    #[test]
    fn compile_action_edge_retired_hash_literal_fat_arrow_is_compile_error() {
        let src = "Top::\n /x/ -> Done { return({ old => value }) }\n\nDone:\n /done/\n";
        let spec = parse_spec(src).unwrap();
        let err = compile(&spec).unwrap_err().to_string();
        assert!(err.contains("rule 'Top': failed to parse action code"));
        assert!(err.contains("LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon"));
        assert!(err.contains("use ':' as in '{ key : value }'"));
    }

    // ── Action edge → regex association tests ──

    #[test]
    fn compile_action_edge_associated_with_preceding_regex() {
        // /a/ -> Child_A    should associate with regex index 0
        // /b/ -> Child_B    should associate with regex index 1
        let src =
            "DemoParser::\n /a/ -> Child_A\n /b/ -> Child_B\n\nChild_A:\n /ca/\nChild_B:\n /cb/";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = &compiled.rules[0];
        assert_eq!(rule.regex_patterns.len(), 2);
        assert_eq!(rule.acode_dispatch.len(), 2);
        // First action edge (-> Child_A) should be associated with regex[0] (/a/)
        assert_eq!(rule.acode_dispatch[0].regex_idx, 0);
        assert_eq!(rule.acode_dispatch[0].child_label, "Child_A");
        // Second action edge (-> Child_B) should be associated with regex[1] (/b/)
        assert_eq!(rule.acode_dispatch[1].regex_idx, 1);
        assert_eq!(rule.acode_dispatch[1].child_label, "Child_B");
    }

    #[test]
    fn compile_action_edge_multiple_targets_per_regex() {
        // /a/ -> Child_A | Child_B    both associated with regex[0]
        let src = "DemoParser::\n /a/ -> Child_A | Child_B\n\nChild_A:\n /ca/\nChild_B:\n /cb/";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = &compiled.rules[0];
        assert_eq!(rule.acode_dispatch.len(), 2);
        assert_eq!(rule.acode_dispatch[0].regex_idx, 0);
        assert_eq!(rule.acode_dispatch[1].regex_idx, 0);
    }

    #[test]
    fn compile_action_edge_no_regex() {
        // Edge-only rules get child regexes resolved during post-processing.
        // -> Child { return(1) } is edge-only (no preceding /regex/), so Child's
        // regex is added to Wrapper's alternation at position 0.
        let src = "Wrapper::\n -> Child { return(1) }\n\nChild:\n /child_pattern/";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = &compiled.rules[0];
        assert_eq!(rule.acode_dispatch.len(), 1);
        // Child's regex was resolved and added at position 0
        assert_eq!(rule.acode_dispatch[0].regex_idx, 0);
        assert_eq!(rule.regex_patterns.len(), 1);
        assert_eq!(rule.regex_patterns[0], "child_pattern");
        assert!(!rule.acode_dispatch[0].has_parent_regex);
    }

    #[test]
    fn compile_preserves_child_regex_index() {
        // -> Child[2]  should preserve child_regex_idx = 2
        let src = "DemoParser::\n /a/ -> Child[2]\n\nChild:\n /zero/ /one/ /two/";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = &compiled.rules[0];
        assert_eq!(rule.acode_dispatch[0].child_regex_idx, 2);
    }

    #[test]
    fn compile_spec_with_fluent_chain_blind_edge() {
        // Blind edge with fluent chain should preserve both as structured data
        let src = "Wrapper::AND\n => child .set(name, undef)";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = &compiled.rules[0];
        assert_eq!(rule.bcode_dispatch.len(), 1);
        assert_eq!(rule.bcode_dispatch[0].child_label, "child");
        // Fluent chain stored as structured (method, args) pairs
        assert_eq!(rule.bcode_dispatch[0].fluent_chain.len(), 1);
        assert_eq!(rule.bcode_dispatch[0].fluent_chain[0].0, "set");
        assert_eq!(rule.bcode_dispatch[0].fluent_chain[0].1, "name, undef");
    }

    #[test]
    fn compile_spec_with_fluent_chain_action_edge() {
        let src =
            "Wrapper::\n -> child .push\n -> child[1] .return(array(\"done\"))\n\nchild: /x/ /y/";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = &compiled.rules[0];
        assert_eq!(rule.acode_dispatch.len(), 2);
        assert_eq!(rule.acode_dispatch[0].child_label, "child");
        assert_eq!(rule.acode_dispatch[0].fluent_chain.len(), 1);
        assert_eq!(rule.acode_dispatch[0].fluent_chain[0].0, "push");
        assert_eq!(rule.acode_dispatch[0].fluent_chain[0].1, "");
        assert_eq!(rule.acode_dispatch[1].child_regex_idx, 1);
        assert_eq!(rule.acode_dispatch[1].fluent_chain.len(), 1);
        assert_eq!(rule.acode_dispatch[1].fluent_chain[0].0, "return");
        assert_eq!(rule.acode_dispatch[1].fluent_chain[0].1, "array(\"done\")");
    }

    #[test]
    fn compile_header_rest_action_edge_with_fluent_chain() {
        let src = "Wrapper::->child.push\nLX { return(copy(Wrapper)) }\n\nchild: /x/";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = compiled.find("Wrapper").unwrap();

        assert_eq!(rule.regex_patterns, vec!["x".to_string()]);
        assert_eq!(rule.acode_dispatch.len(), 1);
        assert_eq!(rule.acode_dispatch[0].regex_idx, 0);
        assert_eq!(rule.acode_dispatch[0].child_label, "child");
        assert_eq!(rule.acode_dispatch[0].child_regex_idx, 0);
        assert!(!rule.acode_dispatch[0].has_parent_regex);
        assert_eq!(
            rule.acode_dispatch[0].fluent_chain,
            vec![("push".to_string(), "".to_string())]
        );
        assert!(rule.lxcode.is_some());
    }

    #[test]
    fn compile_multiline_action_edge_fluent_flow_chain() {
        let src = r#"Wrapper::
 -> child
  .if(on)
    .push(child, out)
  .else()
    .return_undef()
  .endif()

child: /x/
"#;
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = &compiled.rules[0];
        assert_eq!(rule.acode_dispatch.len(), 1);
        assert_eq!(
            rule.acode_dispatch[0].fluent_chain,
            vec![
                ("if".to_string(), "on".to_string()),
                ("push".to_string(), "child, out".to_string()),
                ("else".to_string(), "".to_string()),
                ("return_undef".to_string(), "".to_string()),
                ("endif".to_string(), "".to_string()),
            ]
        );
    }

    // ── build_dependency_regex_map tests ──

    #[test]
    fn build_dependency_regex_map_resolves_edge_only_entries() {
        // grep::-style: all entries are edge-only, each gets a unique alternation position
        let src = "grep::\n -> re_term { set(retv, call(re_term)) }\n -> or_op { set(retv, call(or_op)) }\n\nre_term:\n /re_term_pattern/\nor_op:\n /or_op_pattern/\n";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let grep = compiled.find("grep").unwrap();
        // grep has no parent regexes, all come from children
        assert_eq!(grep.regex_patterns.len(), 2);
        assert_eq!(grep.regex_patterns[0], "re_term_pattern");
        assert_eq!(grep.regex_patterns[1], "or_op_pattern");
        // Each edge-only entry gets its own alternation position
        assert_eq!(grep.acode_dispatch[0].regex_idx, 0);
        assert_eq!(grep.acode_dispatch[1].regex_idx, 1);
        assert!(!grep.acode_dispatch[0].has_parent_regex);
        assert!(!grep.acode_dispatch[1].has_parent_regex);
    }

    #[test]
    fn build_dependency_regex_map_parent_regexes_come_first() {
        // Parent regexes at 0..P-1, child-resolved regexes at P..P+C-1
        let src = "Top::\n /parent_a/ -> Child_A\n /parent_b/ -> Child_B\n -> EdgeOnly\n\nChild_A:\n /child_a/\nChild_B:\n /child_b/\nEdgeOnly:\n /edge_only_regex/\n";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let top = compiled.find("Top").unwrap();
        // regex_patterns order: parent_a, parent_b, edge_only_regex
        assert_eq!(top.regex_patterns.len(), 3);
        assert_eq!(top.regex_patterns[0], "parent_a");
        assert_eq!(top.regex_patterns[1], "parent_b");
        assert_eq!(top.regex_patterns[2], "edge_only_regex");
        // Anchored entries keep their parent regex positions
        assert_eq!(top.acode_dispatch[0].regex_idx, 0); // -> Child_A (anchored to parent_a)
        assert_eq!(top.acode_dispatch[1].regex_idx, 1); // -> Child_B (anchored to parent_b)
        assert!(top.acode_dispatch[0].has_parent_regex);
        assert!(top.acode_dispatch[1].has_parent_regex);
        // Edge-only entry gets the resolved child regex at position 2
        assert_eq!(top.acode_dispatch[2].regex_idx, 2); // -> EdgeOnly
        assert!(!top.acode_dispatch[2].has_parent_regex);
    }

    #[test]
    fn build_dependency_regex_map_self_recursive_rule() {
        // Self-recursive entries point to parent regex positions directly —
        // no duplication needed since the regex is already in the alternation.
        let src = "Expr::\n /[A-Za-z_]/\n /\\d+/\n -> Expr\n -> Expr[1]\n";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let expr = compiled.find("Expr").unwrap();
        // Only parent regexes (self-refs use existing positions)
        assert_eq!(expr.regex_patterns.len(), 2);
        assert_eq!(expr.regex_patterns[0], "[A-Za-z_]");
        assert_eq!(expr.regex_patterns[1], r"\d+");
        // Self-refs point to parent positions: Expr[0]→0, Expr[1]→1
        assert_eq!(expr.acode_dispatch[0].regex_idx, 0);
        assert_eq!(expr.acode_dispatch[1].regex_idx, 1);
        assert_eq!(expr.acode_dispatch[0].child_regex_idx, 0);
        assert_eq!(expr.acode_dispatch[1].child_regex_idx, 1);
        assert!(!expr.acode_dispatch[0].has_parent_regex);
        assert!(!expr.acode_dispatch[1].has_parent_regex);
    }

    #[test]
    fn compile_rejects_missing_child_structural_slot() {
        let src = "Top::\n -> DoesNotExist\n";
        let spec = parse_spec(src).unwrap();
        let error = compile(&spec).unwrap_err();
        let diagnostic = error.diagnostic().expect("portable slot diagnostic");
        assert_eq!(diagnostic.code, "regex_slot_identity_invalid");
        assert_eq!(diagnostic.stage, "validate_compiled_rule");
        assert_eq!(
            diagnostic.field("rule_label"),
            Some(&serde_json::json!("Top"))
        );
        assert_eq!(
            diagnostic.field("target_rule"),
            Some(&serde_json::json!("DoesNotExist"))
        );
        assert_eq!(diagnostic.field("regex_index"), Some(&serde_json::json!(0)));
    }

    #[test]
    fn compile_rejects_out_of_bounds_child_structural_slot() {
        let src = "Top::\n -> Child[5]\n\nChild:\n /only_one/\n";
        let spec = parse_spec(src).unwrap();
        let error = compile(&spec).unwrap_err();
        let diagnostic = error.diagnostic().expect("portable slot diagnostic");
        assert_eq!(diagnostic.code, "regex_slot_identity_invalid");
        assert_eq!(diagnostic.stage, "validate_compiled_rule");
        assert_eq!(
            diagnostic.field("rule_label"),
            Some(&serde_json::json!("Top"))
        );
        assert_eq!(
            diagnostic.field("target_rule"),
            Some(&serde_json::json!("Child"))
        );
        assert_eq!(diagnostic.field("regex_index"), Some(&serde_json::json!(5)));
    }

    #[test]
    fn build_dependency_regex_map_no_edge_only_entries_is_noop() {
        // Rule with only anchored edges — regex_patterns and regex_idx unchanged
        let src = "Top::\n /a/ -> Child_A\n /b/ -> Child_B\n\nChild_A:\n /ca/\nChild_B:\n /cb/\n";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let top = compiled.find("Top").unwrap();
        assert_eq!(top.regex_patterns.len(), 2); // only parent regexes
        assert_eq!(top.regex_patterns[0], "a");
        assert_eq!(top.regex_patterns[1], "b");
        assert_eq!(top.acode_dispatch[0].regex_idx, 0);
        assert_eq!(top.acode_dispatch[1].regex_idx, 1);
    }

    #[test]
    fn build_dependency_regex_map_has_parent_regex_flag() {
        // Verify has_parent_regex is correctly set for anchored vs edge-only
        let src = "DemoParser::\n /a/ -> Child_A | Child_B\n -> Child_C\n\nChild_A:\n /ca/\nChild_B:\n /cb/\nChild_C:\n /cc/\n";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let rule = compiled.find("DemoParser").unwrap();
        // /a/ -> Child_A | Child_B: both anchored (same line as /a/)
        assert!(rule.acode_dispatch[0].has_parent_regex);
        assert!(rule.acode_dispatch[1].has_parent_regex);
        // -> Child_C: edge-only (no preceding regex)
        assert!(!rule.acode_dispatch[2].has_parent_regex);
    }

    #[test]
    fn compile_all_shipped_specs_to_json() {
        // Verify all shipped specs compile and serialize to valid JSON.
        use std::fs;
        use std::path::Path;

        let specs_dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("../../specs");
        if !specs_dir.exists() {
            eprintln!("specs/ directory not found, skipping");
            return;
        }

        for entry in fs::read_dir(&specs_dir).unwrap() {
            let entry = entry.unwrap();
            let path = entry.path();
            if path.extension().is_some_and(|e| e == "spec") {
                let source = fs::read_to_string(&path).unwrap();
                let spec = parse_spec(&source).unwrap();
                let compiled = compile(&spec).unwrap();
                // Verify serde roundtrip
                let json = serde_json::to_string(&compiled).unwrap();
                let _back: CompiledSpec = serde_json::from_str(&json).unwrap();
                assert!(
                    !compiled.rules.is_empty(),
                    "compiled spec {} has no rules",
                    path.display()
                );
                // Every rule should have a label
                for rule in &compiled.rules {
                    assert!(!rule.label.is_empty());
                }
            }
        }
    }

    #[test]
    fn header_line_bracket_pair_self_recursive_close_edge_resolves() {
        // RUST-PARITY.7.5.1: a `/open/ /close/` bracket pair written on the rule's
        // HEADER line must register both regexes (open=0, close=1), so the
        // self-recursive `-> bracket[1]` close edge resolves to index 1 — exactly
        // the recursive-descent bracket matcher in tclite/Lispish. Before the fix
        // group 3 ate the open delimiter, leaving only `close` at index 0 and
        // making `bracket[1]` out-of-bounds ("never fires"). This mirrors the
        // existing `build_dependency_regex_map_self_recursive_rule` test but with
        // the pair on the header line rather than separate body lines.
        let src = "Top::\n -> bracket\n\nbracket : /\\(/ /\\)/\n -> bracket\n -> bracket[1]\n";
        let spec = parse_spec(src).unwrap();
        let compiled = compile(&spec).unwrap();
        let bracket = compiled.find("bracket").unwrap();
        // Both header-line regexes registered, open first then close.
        assert_eq!(bracket.regex_patterns.len(), 2);
        assert_eq!(bracket.regex_patterns[0], "\\(");
        assert_eq!(bracket.regex_patterns[1], "\\)");
        // Self-recursive edges point at the existing parent positions:
        // `-> bracket` (index 0 = open), `-> bracket[1]` (index 1 = close).
        assert_eq!(bracket.acode_dispatch[0].regex_idx, 0);
        assert_eq!(bracket.acode_dispatch[0].child_regex_idx, 0);
        assert_eq!(bracket.acode_dispatch[1].regex_idx, 1);
        assert_eq!(bracket.acode_dispatch[1].child_regex_idx, 1);
        // The parent's `-> bracket` edge-only entry resolves against bracket's
        // entry (open) regex, appended to Top's alternation.
        let top = compiled.find("Top").unwrap();
        assert_eq!(top.regex_patterns.len(), 1);
        assert_eq!(top.regex_patterns[0], "\\(");
    }
}
