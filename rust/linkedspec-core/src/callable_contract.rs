//! Metadata-owned final-codeblock contracts and contextual normalization.
//!
//! The expression parser recognizes attached block syntax structurally. This
//! module is the single semantic seam that admits contextual blocks for builtin
//! helpers, receiver methods, or typed user functions.

use std::collections::BTreeMap;

use crate::expr::{
    Arg, CodeBlock, ContextualBlockSyntax, Expr, FluentCall, HashLiteralEntry, Stmt,
};
use crate::types::{CompiledRule, CompiledSpec, CompiledUserFunction};

/// Callable surface whose final parameter may accept a codeblock value.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CallableSurface {
    /// Ordinary helper or registered user-function call.
    Helper,
    /// Fluent receiver method call.
    Receiver,
}

/// Exact arity metadata before the required final codeblock value.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FinalCodeblockContract {
    /// Minimum ordinary positional values before the codeblock.
    pub min_before_codeblock: usize,
    /// Maximum ordinary positional values before the codeblock.
    pub max_before_codeblock: usize,
    /// Declared name of the final codeblock parameter.
    pub final_parameter_name: String,
}

impl FinalCodeblockContract {
    fn accepts(&self, before_count: usize) -> bool {
        (self.min_before_codeblock..=self.max_before_codeblock).contains(&before_count)
    }
}

/// Return the builtin contract for one helper/receiver name.
pub fn builtin_contract(surface: CallableSurface, name: &str) -> Option<FinalCodeblockContract> {
    let (minimum, maximum) = match (surface, name) {
        (CallableSurface::Helper, "with") => (0, 1),
        (CallableSurface::Receiver, "with")
        | (CallableSurface::Receiver, "walk_leaves")
        | (CallableSurface::Receiver, "map_leaves") => (0, 0),
        (CallableSurface::Receiver, "reduce_leaves") => (1, 1),
        _ => return None,
    };
    Some(FinalCodeblockContract {
        min_before_codeblock: minimum,
        max_before_codeblock: maximum,
        final_parameter_name: "callback".to_string(),
    })
}

/// Derive a user-function contract only from its declared final parameter kind.
pub fn user_function_contract(function: &CompiledUserFunction) -> Option<FinalCodeblockContract> {
    let final_name = function.params.last()?;
    if function.parameter_kinds.len() != 1
        || function.parameter_kinds.get(final_name).map(String::as_str) != Some("codeblock")
    {
        return None;
    }
    let before = function.params.len().checked_sub(1)?;
    Some(FinalCodeblockContract {
        min_before_codeblock: before,
        max_before_codeblock: before,
        final_parameter_name: final_name.clone(),
    })
}

/// Normalize every compiled ActionIR block using builtin and typed-user metadata.
pub fn normalize_compiled_spec(spec: &mut CompiledSpec) -> Result<(), String> {
    for function in &spec.functions {
        if !function.parameter_kinds.is_empty() && user_function_contract(function).is_none() {
            return Err(format!(
                "invalid final-codeblock metadata for user function '{}'",
                function.name
            ));
        }
    }
    let user_contracts = spec
        .functions
        .iter()
        .filter_map(|function| {
            user_function_contract(function).map(|contract| (function.name.clone(), contract))
        })
        .collect::<BTreeMap<_, _>>();

    for function in &mut spec.functions {
        normalize_codeblock(&mut function.body, &user_contracts)?;
        if let Some(staged_body) = &function.body_ast {
            function.body_ast = Some(normalized_staged_body_ast(staged_body, &function.body)?);
        }
    }
    for rule in &mut spec.rules {
        normalize_rule(rule, &user_contracts)?;
    }
    Ok(())
}

fn normalized_staged_body_ast(
    staged_body: &serde_json::Value,
    body: &CodeBlock,
) -> Result<serde_json::Value, String> {
    let mut normalized = serde_json::to_value(body)
        .map_err(|error| format!("serialize normalized function body: {error}"))?;
    let staged_object = staged_body
        .as_object()
        .ok_or_else(|| "normalized function body AST must remain an object".to_string())?;
    let normalized_object = normalized
        .as_object_mut()
        .ok_or_else(|| "serialized normalized function body must be an object".to_string())?;

    for (key, value) in staged_object {
        if key != "statements" && !normalized_object.contains_key(key) {
            normalized_object.insert(key.clone(), value.clone());
        }
    }

    let staged_statements = staged_object
        .get("statements")
        .and_then(serde_json::Value::as_array)
        .ok_or_else(|| "normalized function body AST must retain staged statements".to_string())?;
    let normalized_statements = normalized_object
        .get_mut("statements")
        .and_then(serde_json::Value::as_array_mut)
        .ok_or_else(|| "serialized normalized function body must contain statements".to_string())?;
    if staged_statements.len() != normalized_statements.len() {
        return Err(format!(
            "normalized function body statement count changed from {} to {}",
            staged_statements.len(),
            normalized_statements.len()
        ));
    }
    for (staged_statement, normalized_statement) in
        staged_statements.iter().zip(normalized_statements)
    {
        let (Some(staged_statement), Some(normalized_statement)) = (
            staged_statement.as_object(),
            normalized_statement.as_object_mut(),
        ) else {
            return Err("normalized function body statements must remain objects".to_string());
        };
        for (key, value) in staged_statement {
            if !normalized_statement.contains_key(key) {
                normalized_statement.insert(key.clone(), value.clone());
            }
        }
    }
    Ok(normalized)
}

fn normalize_rule(
    rule: &mut CompiledRule,
    user_contracts: &BTreeMap<String, FinalCodeblockContract>,
) -> Result<(), String> {
    for entry in &mut rule.acode_dispatch {
        if let Some(block) = &mut entry.code {
            normalize_codeblock(block, user_contracts)?;
        }
    }
    for entry in &mut rule.bcode_dispatch {
        if let Some(block) = &mut entry.code {
            normalize_codeblock(block, user_contracts)?;
        }
    }
    for block in [
        &mut rule.preamble,
        &mut rule.lxcode,
        &mut rule.lscode,
        &mut rule.lecode,
        &mut rule.ecode,
        &mut rule.excode,
        &mut rule.itcode,
    ]
    .into_iter()
    .flatten()
    {
        normalize_codeblock(block, user_contracts)?;
    }
    Ok(())
}

fn normalize_codeblock(
    block: &mut CodeBlock,
    user_contracts: &BTreeMap<String, FinalCodeblockContract>,
) -> Result<(), String> {
    for statement in &mut block.statements {
        normalize_expr(&mut statement.expr, user_contracts)?;
    }
    Ok(())
}

fn normalize_args(
    args: &mut [Arg],
    user_contracts: &BTreeMap<String, FinalCodeblockContract>,
) -> Result<(), String> {
    for argument in args.iter_mut() {
        normalize_expr(argument.value_mut(), user_contracts)?;
    }
    Ok(())
}

fn normalize_call_arguments(
    surface: CallableSurface,
    name: &str,
    args: &mut Vec<Arg>,
    user_contracts: &BTreeMap<String, FinalCodeblockContract>,
) -> Result<(), String> {
    normalize_args(args, user_contracts)?;
    let Some(Arg::Positional(Expr::ContextualCodeblockCandidate(candidate))) = args.last() else {
        restore_parenthesized_blocks(args);
        return Ok(());
    };
    let syntax = candidate.syntax;
    let contract = builtin_contract(surface, name).or_else(|| {
        if surface == CallableSurface::Helper {
            user_contracts.get(name).cloned()
        } else {
            None
        }
    });
    let Some(contract) = contract else {
        if syntax == ContextualBlockSyntax::Attached {
            return Err(format!(
                "callable_contract_rejected: {surface:?} '{name}' does not declare a final codeblock parameter"
            ));
        }
        restore_parenthesized_blocks(args);
        return Ok(());
    };
    let before_count = args.len() - 1;
    if !contract.accepts(before_count) {
        return Err(format!(
            "callable_contract_arity_mismatch: {surface:?} '{name}' expects {}..={} value argument(s) before final codeblock, got {before_count}",
            contract.min_before_codeblock, contract.max_before_codeblock
        ));
    }
    let Arg::Positional(Expr::ContextualCodeblockCandidate(candidate)) = args.pop().unwrap() else {
        unreachable!("last argument was checked as a contextual candidate");
    };
    args.push(Arg::Positional(Expr::CodeblockArgument(
        candidate.codeblock,
    )));
    restore_parenthesized_blocks(args);
    Ok(())
}

fn restore_parenthesized_blocks(args: &mut [Arg]) {
    for argument in args {
        let value = argument.value_mut();
        if !matches!(
            value,
            Expr::ContextualCodeblockCandidate(candidate)
                if candidate.syntax == ContextualBlockSyntax::Parenthesized
        ) {
            continue;
        }
        let Expr::ContextualCodeblockCandidate(candidate) = std::mem::replace(value, Expr::Undef)
        else {
            unreachable!("candidate kind was checked before replacement");
        };
        *value = Expr::BlockValue {
            block: CodeBlock {
                statements: candidate.codeblock.body_ast.statements,
            },
        };
    }
}

fn normalize_expr(
    expr: &mut Expr,
    user_contracts: &BTreeMap<String, FinalCodeblockContract>,
) -> Result<(), String> {
    match expr {
        Expr::Call { name, args } => {
            normalize_call_arguments(CallableSurface::Helper, name, args, user_contracts)
        }
        Expr::AssignScalar { value, .. } | Expr::AssignArrayAppend { value, .. } => {
            normalize_expr(value, user_contracts)
        }
        Expr::AssignHashIndex { key, value, .. } => {
            normalize_expr(key, user_contracts)?;
            normalize_expr(value, user_contracts)
        }
        Expr::AssignNestedAccess {
            segments, value, ..
        } => {
            normalize_segments(segments, user_contracts)?;
            normalize_expr(value, user_contracts)
        }
        Expr::IndexedVar { index, .. } => normalize_expr(index, user_contracts),
        Expr::NestedAccess { segments, .. } => normalize_segments(segments, user_contracts),
        Expr::ValueAccess { receiver, segments } => {
            normalize_expr(receiver, user_contracts)?;
            normalize_segments(segments, user_contracts)
        }
        Expr::ArrayLiteral { items } => {
            for item in items {
                normalize_expr(item, user_contracts)?;
            }
            Ok(())
        }
        Expr::HashLiteral { entries } => normalize_hash_entries(entries, user_contracts),
        Expr::BlockValue { block } => normalize_codeblock(block, user_contracts),
        Expr::ContextualCodeblockCandidate(candidate) => {
            normalize_statements(&mut candidate.codeblock.body_ast.statements, user_contracts)
        }
        Expr::CodeblockArgument(codeblock) | Expr::CodeblockLiteral(codeblock) => {
            normalize_statements(&mut codeblock.body_ast.statements, user_contracts)
        }
        Expr::FluentChain { receiver, calls } => {
            normalize_expr(receiver, user_contracts)?;
            for FluentCall { method, args } in calls {
                normalize_call_arguments(CallableSurface::Receiver, method, args, user_contracts)?;
            }
            Ok(())
        }
        Expr::RecognitionCheckpoint
        | Expr::ProgressiveDispatchSpan { .. }
        | Expr::StagedParseJobMarker { .. }
        | Expr::RecognizeOnce { .. }
        | Expr::ObserveRecognition { .. }
        | Expr::RecognitionCommit { .. }
        | Expr::RecognitionRollback { .. } => Ok(()),
        Expr::Variable { .. }
        | Expr::StringLiteral { .. }
        | Expr::NumberLiteral { .. }
        | Expr::BooleanLiteral { .. }
        | Expr::RegexLiteral { .. }
        | Expr::Undef => Ok(()),
    }
}

fn normalize_statements(
    statements: &mut [Stmt],
    user_contracts: &BTreeMap<String, FinalCodeblockContract>,
) -> Result<(), String> {
    for statement in statements {
        normalize_expr(&mut statement.expr, user_contracts)?;
    }
    Ok(())
}

fn normalize_hash_entries(
    entries: &mut [HashLiteralEntry],
    user_contracts: &BTreeMap<String, FinalCodeblockContract>,
) -> Result<(), String> {
    for entry in entries {
        normalize_expr(&mut entry.key, user_contracts)?;
        normalize_expr(&mut entry.value, user_contracts)?;
    }
    Ok(())
}

fn normalize_segments(
    segments: &mut [crate::expr::AccessSegment],
    user_contracts: &BTreeMap<String, FinalCodeblockContract>,
) -> Result<(), String> {
    for segment in segments {
        if let crate::expr::AccessSegment::Index { expr } = segment {
            normalize_expr(expr, user_contracts)?;
        }
    }
    Ok(())
}
