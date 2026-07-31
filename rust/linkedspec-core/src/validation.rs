//! Validation passes for parsed `.spec` AST.
//!
//! Checks performed (every mode):
//! 1. At least one rule exists (an authored `::` marker is optional)
//! 2. Every declaration and edge target uses the pinned Unicode rule-label class
//! 3. No duplicate rule labels
//! 4. User-function names are unique and do not collide with rule labels,
//!    lifecycle markers, reserved runtime symbols, or built-in helper/control names
//! 5. User-function parameters are valid, unique, and not reserved runtime symbols
//! 6. Bare edges resolve against the complete rule set and obey family shape
//! 7. No rule mixes action and blind ownership after bare normalization
//! 8. All `{` blocks are balanced (no unclosed blocks)
//! 9. All edge targets reference existing rules
//! 10. Rule headers are not inside open blocks (handled by parser)
//!
//! Strict mode (`validate_with_options(spec, strict_syntax = true)`) promotes the
//! Perl reference's *reference warnings* to hard errors:
//! 11. No unused rules — every defined rule must be referenced by some edge (the
//!    top rule is NOT exempt, matching `Validation.pm`'s strict_syntax check).
//!
//! Note: undefined references are a hard error here in *every* mode (check 9),
//! which is stricter than the Perl reference's default (it warns, and only
//! `strict_syntax` makes them fatal). Strict mode keeps them fatal too, so the
//! observable addition of strict mode in this backend is the unused-rule check;
//! the Perl ordering (undefined reported before unused) is preserved because
//! check 5 runs before the strict check.

use crate::ast::{BodyElementKind, SpecFile};
use crate::entry_rule::no_rules_defined_diagnostic;
use crate::error::{LinkedSpecError, PortableDiagnostic, Result};
use crate::trace::{TraceConfig, TraceEmitter, TraceLevel};
use crate::unicode_rule_label::is_rule_label;
use rgx_core::Regex;
use std::collections::HashSet;

/// Run all (non-strict) validation passes on a parsed spec.
pub fn validate(spec: &SpecFile) -> Result<()> {
    validate_with_options(spec, false)
}

/// Run validation with explicit trace configuration.
pub fn validate_with_trace(spec: &SpecFile, trace_config: TraceConfig) -> Result<()> {
    let mut trace = TraceEmitter::new(trace_config)?;
    validate_with_trace_emitter(spec, &mut trace)
}

/// Run validation with a caller-owned trace emitter.
pub fn validate_with_trace_emitter(spec: &SpecFile, trace: &mut TraceEmitter) -> Result<()> {
    validate_with_options_with_trace_emitter(spec, false, trace)
}

/// Run validation passes, optionally in strict mode.
///
/// `strict_syntax` mirrors the Perl reference's `validate_dsl_syntax(...,
/// strict_syntax => 1)`: the reference warnings (undefined references, unused
/// rules) become hard errors. Undefined references are already fatal here in
/// every mode (`check_edge_targets`, which runs first — matching the reference's
/// "undefined before unused" order), so strict mode's observable addition is the
/// unused-rule rejection.
pub fn validate_with_options(spec: &SpecFile, strict_syntax: bool) -> Result<()> {
    check_rules_exist(spec)?;
    check_rule_labels(spec)?;
    check_duplicate_labels(spec)?;
    check_duplicate_function_names(spec)?;
    check_function_registry(spec)?;
    check_edge_structure(spec)?;
    check_mixed_edges(spec)?;
    check_balanced_braces(spec)?;
    check_edge_targets(spec)?;
    check_regex_syntax(spec)?;
    if strict_syntax {
        check_unused_rules(spec)?;
    }
    Ok(())
}

/// Run validation passes with trace events, optionally in strict mode.
pub fn validate_with_options_with_trace(
    spec: &SpecFile,
    strict_syntax: bool,
    trace_config: TraceConfig,
) -> Result<()> {
    let mut trace = TraceEmitter::new(trace_config)?;
    validate_with_options_with_trace_emitter(spec, strict_syntax, &mut trace)
}

/// Run validation passes with a caller-owned trace emitter.
pub fn validate_with_options_with_trace_emitter(
    spec: &SpecFile,
    strict_syntax: bool,
    trace: &mut TraceEmitter,
) -> Result<()> {
    let scope = trace.enter_scope(
        "rust_core:validate",
        format!(
            "rules={} functions={} strict_syntax={}",
            spec.rules.len(),
            spec.functions.len(),
            if strict_syntax { 1 } else { 0 }
        ),
        TraceLevel::LOW,
    )?;
    let result = (|| {
        trace_validation_pass(trace, "rules_exist", || check_rules_exist(spec))?;
        trace_validation_pass(trace, "rule_labels", || check_rule_labels(spec))?;
        trace_validation_pass(trace, "duplicate_labels", || check_duplicate_labels(spec))?;
        trace_validation_pass(trace, "duplicate_function_names", || {
            check_duplicate_function_names(spec)
        })?;
        trace_validation_pass(trace, "function_registry", || check_function_registry(spec))?;
        trace_validation_pass(trace, "edge_structure", || check_edge_structure(spec))?;
        trace_validation_pass(trace, "mixed_edges", || check_mixed_edges(spec))?;
        trace_validation_pass(trace, "balanced_braces", || check_balanced_braces(spec))?;
        trace_validation_pass(trace, "edge_targets", || check_edge_targets(spec))?;
        trace_validation_pass(trace, "regex_syntax", || check_regex_syntax(spec))?;
        if strict_syntax {
            trace_validation_pass(trace, "unused_rules", || check_unused_rules(spec))?;
        } else {
            trace.trace_decision(
                "rust_core:validate:unused_rules",
                false,
                "strict_syntax=0 skipped",
                TraceLevel::MEDIUM,
            );
        }
        Ok(())
    })();
    let exit_details = match &result {
        Ok(()) => "status=ok".to_string(),
        Err(err) => format!("status=error error={err}"),
    };
    trace.exit_scope(scope, exit_details)?;
    result
}

fn trace_validation_pass<F>(trace: &mut TraceEmitter, name: &str, check: F) -> Result<()>
where
    F: FnOnce() -> Result<()>,
{
    let result = check();
    match &result {
        Ok(()) => {
            trace.trace_decision(
                format!("rust_core:validate:{name}"),
                true,
                "pass",
                TraceLevel::MEDIUM,
            );
        }
        Err(err) => {
            trace.trace_decision(
                format!("rust_core:validate:{name}"),
                false,
                format!("error={err}"),
                TraceLevel::MEDIUM,
            );
        }
    }
    result
}

/// At least one rule declaration must exist; an authored marker is optional.
fn check_rules_exist(spec: &SpecFile) -> Result<()> {
    if spec.rules.is_empty() {
        return Err(LinkedSpecError::Diagnostic(no_rules_defined_diagnostic()));
    }
    Ok(())
}

/// Rule declarations and references share one generated, pinned Unicode contract.
fn check_rule_labels(spec: &SpecFile) -> Result<()> {
    for rule in &spec.rules {
        if !is_rule_label(&rule.header.label) {
            return Err(invalid_rule_label_diagnostic(
                &rule.header.label,
                "declaration",
                rule.header.line,
                None,
            ));
        }
        for element in &rule.body {
            let targets: Vec<&str> = match &element.kind {
                BodyElementKind::ActionEdge { targets, .. } => {
                    targets.iter().map(|target| target.label.as_str()).collect()
                }
                BodyElementKind::BlindEdge { target, .. } => vec![target.as_str()],
                BodyElementKind::BareEdge { targets, .. } => {
                    targets.iter().map(|target| target.label.as_str()).collect()
                }
                _ => continue,
            };
            for target in targets {
                if !is_rule_label(target) {
                    return Err(invalid_rule_label_diagnostic(
                        target,
                        "edge_target",
                        element.line,
                        Some(&rule.header.label),
                    ));
                }
            }
        }
    }
    Ok(())
}

fn invalid_rule_label_diagnostic(
    label: &str,
    role: &str,
    line: usize,
    owner: Option<&str>,
) -> LinkedSpecError {
    let mut diagnostic = diagnostic(
        "invalid_rule_label",
        "validate_rule_labels",
        format!(
            "{role} '{}' is not a nonempty Unicode 17.0.0 XID_Continue rule label",
            label
        ),
    )
    .with_field("label", label)
    .with_field("line", line)
    .with_field("role", role);
    if let Some(owner) = owner {
        diagnostic = diagnostic.with_field("rule_label", owner);
    }
    LinkedSpecError::Diagnostic(diagnostic)
}

/// Rule labels must be unique.
fn check_duplicate_labels(spec: &SpecFile) -> Result<()> {
    let mut seen = HashSet::new();
    for rule in &spec.rules {
        if !seen.insert(&rule.header.label) {
            return Err(LinkedSpecError::Validation(format!(
                "duplicate rule label '{}'",
                rule.header.label
            )));
        }
    }
    Ok(())
}

fn check_duplicate_function_names(spec: &SpecFile) -> Result<()> {
    let mut seen = HashSet::new();
    for function in &spec.functions {
        if !seen.insert(function.name.as_str()) {
            return Err(LinkedSpecError::Validation(format!(
                "duplicate user function definition '{}'",
                function.name
            )));
        }
    }
    Ok(())
}

fn check_function_registry(spec: &SpecFile) -> Result<()> {
    let rule_labels: HashSet<&str> = spec.rules.iter().map(|r| r.header.label.as_str()).collect();

    for function in &spec.functions {
        let name = function.name.as_str();
        if !is_identifier(name) {
            return Err(LinkedSpecError::Validation(format!(
                "invalid user function name '{}'",
                function.name
            )));
        }
        if rule_labels.contains(name) {
            return Err(LinkedSpecError::Validation(format!(
                "user function '{}' collides with rule label '{}'",
                function.name, function.name
            )));
        }
        if is_reserved_runtime_symbol(name) {
            return Err(LinkedSpecError::Validation(format!(
                "user function '{}' uses a reserved runtime symbol",
                function.name
            )));
        }
        if is_lifecycle_marker_name(name) {
            return Err(LinkedSpecError::Validation(format!(
                "user function '{}' collides with lifecycle marker '{}'",
                function.name, function.name
            )));
        }
        if is_function_keyword(name) || is_known_actionir_call_name(name) {
            return Err(LinkedSpecError::Validation(format!(
                "user function '{}' collides with built-in helper/control name '{}'",
                function.name, function.name
            )));
        }

        if let Some(signature) = &function.signature {
            if signature.kind != "callable_signature"
                || signature.version != 1
                || signature.positional_params != function.params
                || signature.min_arity != function.arity
                || signature.min_arity != signature.positional_params.len()
                || signature.rest_param.is_none()
                || signature.max_arity.is_some()
            {
                return Err(LinkedSpecError::Validation(format!(
                    "user function '{}' has an invalid variadic callable signature",
                    function.name
                )));
            }
        }

        let mut seen_params = HashSet::new();
        let all_params = function.params.iter().chain(
            function
                .signature
                .iter()
                .filter_map(|signature| signature.rest_param.as_ref()),
        );
        for param in all_params {
            if !is_identifier(param) {
                return Err(LinkedSpecError::Validation(format!(
                    "user function '{}' has invalid parameter '{}'",
                    function.name, param
                )));
            }
            if !seen_params.insert(param.as_str()) {
                return Err(LinkedSpecError::Validation(format!(
                    "duplicate parameter '{}' in function '{}'",
                    param, function.name
                )));
            }
            if is_reserved_runtime_symbol(param)
                || is_lifecycle_marker_name(param)
                || is_function_keyword(param)
            {
                return Err(LinkedSpecError::Validation(format!(
                    "user function '{}' parameter '{}' is reserved",
                    function.name, param
                )));
            }
        }
    }
    Ok(())
}

fn is_identifier(value: &str) -> bool {
    let mut chars = value.chars();
    let Some(first) = chars.next() else {
        return false;
    };
    (first.is_ascii_alphabetic() || first == '_')
        && chars.all(|ch| ch.is_ascii_alphanumeric() || ch == '_')
}

fn is_function_keyword(name: &str) -> bool {
    matches!(name, "fn" | "return")
}

fn is_lifecycle_marker_name(name: &str) -> bool {
    matches!(name, "I" | "LS" | "LE" | "E" | "EX" | "IT" | "LX")
}

fn is_reserved_runtime_symbol(name: &str) -> bool {
    matches!(
        name,
        "STRING"
            | "descr"
            | "minfo"
            | "LSPOS"
            | "LEPOS"
            | "LMATCH"
            | "LSMATCH"
            | "IMATCH"
            | "IMATCH_LIST"
            | "LMATCH_LIST"
            | "IMATCH_HASH"
            | "LMATCH_HASH"
            | "SELF"
            | "this"
            | "ctx"
            | "runtime_ctx"
    )
}

fn is_known_actionir_call_name(name: &str) -> bool {
    is_numeric_word_alias_name(name)
        || matches!(
            name,
            "and"
                | "array"
                | "call"
                | "capture_between"
                | "capture_from"
                | "capture_len_between"
                | "capture_len_from"
                | "capture_rest"
                | "capture_rest_from"
                | "capture_rest_len"
                | "capture_rest_len_from"
                | "capture_slice"
                | "capture_slice_len"
                | "capture_slice_line"
                | "capture_slice_pos"
                | "capture_slice_col"
                | "capture_slice_until_cursor"
                | "capture_slice_until_cursor_len"
                | "capture_until_boundary"
                | "capture_take"
                | "capture_take_len"
                | "capture_take_len_from"
                | "capture_take_rest"
                | "capture_take_rest_from"
                | "capture_take_rest_len"
                | "capture_take_rest_len_from"
                | "capture_take_between"
                | "capture_take_between_len"
                | "capture_take_until_cursor"
                | "capture_take_until_cursor_from"
                | "capture_take_until_cursor_len"
                | "capture_take_until_cursor_len_from"
                | "capture_until_cursor_from"
                | "capture_until_cursor_len_from"
                | "case"
                | "cat"
                | "clear_mark"
                | "coalesce"
                | "coalesce_nonempty"
                | "concat_arrays"
                | "contains"
                | "contains_substr"
                | "copy"
                | "count"
                | "count_keys"
                | "cursor_col"
                | "cursor_line"
                | "cursor_pos"
                | "cursor_rest"
                | "cursor_rest_len"
                | "default"
                | "drop_back"
                | "drop_front"
                | "drop_keys"
                | "else"
                | "elif"
                | "elseif"
                | "endcase"
                | "endif"
                | "ends_with"
                | "endswitch"
                | "entry_col"
                | "entry_end_pos"
                | "entry_group"
                | "entry_groups"
                | "entry_has"
                | "entry_len"
                | "entry_line"
                | "entry_map"
                | "entry_named"
                | "entry_named_map"
                | "entry_start_line"
                | "entry_start_pos"
                | "entry_text"
                | "exit_now"
                | "filter_match"
                | "filter_nonempty"
                | "first"
                | "flat"
                | "flat_array"
                | "flat_hash"
                | "has_key"
                | "hash"
                | "i"
                | "if"
                | "index_of"
                | "input_end_col"
                | "input_end_line"
                | "input_end_pos"
                | "input_len"
                | "input_slice"
                | "input_text"
                | "is_defined"
                | "is_empty"
                | "is_nonempty"
                | "is_undefined"
                | "join_values"
                | "last"
                | "length"
                | "lowercase"
                | "lowercase_each"
                | "mark_col"
                | "mark_copy"
                | "mark_capture_slice"
                | "mark_entry_end"
                | "mark_entry_start"
                | "mark_exists"
                | "mark_here"
                | "mark_input_end"
                | "mark_input_start"
                | "mark_line"
                | "mark_match_end"
                | "mark_match_start"
                | "mark_pos"
                | "match_col"
                | "match_end_pos"
                | "match_group"
                | "match_groups"
                | "match_has"
                | "match_len"
                | "match_line"
                | "match_map"
                | "match_named"
                | "match_named_map"
                | "match_start_pos"
                | "match_text"
                | "matches"
                | "merge_hash"
                | "next"
                | "not"
                | "or"
                | "num_abs"
                | "num_add"
                | "num_avg"
                | "num_ceil"
                | "num_clamp"
                | "num_div"
                | "num_eq"
                | "num_floor"
                | "num_ge"
                | "num_gt"
                | "num_le"
                | "num_lt"
                | "num_max"
                | "num_median"
                | "num_min"
                | "num_mod"
                | "num_mul"
                | "num_ne"
                | "num_range"
                | "num_round"
                | "num_sub"
                | "num_sum"
                | "otherwise"
                | "pick_keys"
                | "print"
                | "print_each"
                | "push"
                | "rename_key"
                | "replace_substr"
                | "return"
                | "return_undef"
                | "restore_cursor"
                | "rewind_entry_start"
                | "rewind_match_start"
                | "reversed"
                | "rm_prefix"
                | "rm_suffix"
                | "say"
                | "save_cursor"
                | "set"
                | "set_key"
                | "slice"
                | "sorted"
                | "sorted_keys"
                | "sorted_values"
                | "split"
                | "split_each"
                | "start_capture_slice"
                | "start_capture_slice_from"
                | "starts_with"
                | "str_eq"
                | "str_ge"
                | "str_gt"
                | "str_le"
                | "str_lt"
                | "str_ne"
                | "substr"
                | "switch"
                | "take"
                | "take_last"
                | "trim"
                | "trim_each"
                | "uniq"
                | "uppercase"
                | "uppercase_each"
                | "when"
                | "with"
                | "while"
        )
}

fn is_numeric_word_alias_name(name: &str) -> bool {
    matches!(
        name,
        "abs"
            | "add"
            | "avg"
            | "ceil"
            | "clamp"
            | "div"
            | "eq"
            | "floor"
            | "ge"
            | "gt"
            | "le"
            | "lt"
            | "max"
            | "median"
            | "min"
            | "mod"
            | "mul"
            | "ne"
            | "range"
            | "round"
            | "sub"
            | "sum"
    )
}

fn diagnostic(code: &str, stage: &str, message: impl Into<String>) -> PortableDiagnostic {
    PortableDiagnostic::new(code, stage, message)
}

/// Validate family-sensitive and explicit edge shapes before compilation.
fn check_edge_structure(spec: &SpecFile) -> Result<()> {
    let labels: HashSet<&str> = spec
        .rules
        .iter()
        .map(|rule| rule.header.label.as_str())
        .collect();

    for rule in &spec.rules {
        for element in &rule.body {
            match &element.kind {
                BodyElementKind::BareEdge { targets, code, .. } => {
                    for target in targets {
                        if !labels.contains(target.label.as_str()) {
                            return Err(LinkedSpecError::Diagnostic(
                                diagnostic(
                                    "bare_edge_target_undefined",
                                    "normalize_edges",
                                    format!(
                                        "bare edge in rule '{}' targets undefined rule '{}'",
                                        rule.header.label, target.label
                                    ),
                                )
                                .with_field("rule_label", rule.header.label.clone())
                                .with_field("target", target.label.clone()),
                            ));
                        }
                    }

                    if rule.header.mode.is_and() {
                        if let Some(target) = targets.iter().find(|target| target.index.is_some()) {
                            return Err(LinkedSpecError::Diagnostic(
                                diagnostic(
                                    "bare_edge_index_requires_action",
                                    "normalize_edges",
                                    format!(
                                        "indexed bare edge in AND rule '{}' requires explicit action ownership",
                                        rule.header.label
                                    ),
                                )
                                .with_field("rule_label", rule.header.label.clone())
                                .with_field("target", target.label.clone())
                                .with_field("regex_index", target.index.unwrap()),
                            ));
                        }
                        if targets.len() > 1 {
                            let labels = targets
                                .iter()
                                .map(|target| target.label.clone())
                                .collect::<Vec<_>>();
                            return Err(LinkedSpecError::Diagnostic(
                                diagnostic(
                                    "bare_edge_group_requires_action",
                                    "normalize_edges",
                                    format!(
                                        "grouped bare edge in AND rule '{}' requires explicit action ownership",
                                        rule.header.label
                                    ),
                                )
                                .with_field("rule_label", rule.header.label.clone())
                                .with_field("targets", serde_json::json!(labels)),
                            ));
                        }
                    } else if targets.len() > 1 && code.is_none() {
                        let labels = targets
                            .iter()
                            .map(|target| target.label.clone())
                            .collect::<Vec<_>>();
                        return Err(LinkedSpecError::Diagnostic(
                            diagnostic(
                                "grouped_action_shared_block_required",
                                "validate_rule",
                                format!(
                                    "grouped action-edge targets in rule '{}' require a shared code block",
                                    rule.header.label
                                ),
                            )
                            .with_field("rule_label", rule.header.label.clone())
                            .with_field("targets", serde_json::json!(labels)),
                        ));
                    }
                }
                BodyElementKind::ActionEdge { targets, code, .. }
                    if targets.len() > 1 && code.is_none() =>
                {
                    let labels = targets
                        .iter()
                        .map(|target| target.label.clone())
                        .collect::<Vec<_>>();
                    return Err(LinkedSpecError::Diagnostic(
                        diagnostic(
                            "grouped_action_shared_block_required",
                            "validate_rule",
                            format!(
                                "grouped action-edge targets in rule '{}' require a shared code block",
                                rule.header.label
                            ),
                        )
                        .with_field("rule_label", rule.header.label.clone())
                        .with_field("targets", serde_json::json!(labels)),
                    ));
                }
                BodyElementKind::BlindEdge {
                    target,
                    index: Some(regex_index),
                    ..
                } => {
                    return Err(LinkedSpecError::Diagnostic(
                        diagnostic(
                            "blind_call_index_forbidden",
                            "validate_rule",
                            format!(
                                "blind-call target '{}' in rule '{}' cannot select a regex index",
                                target, rule.header.label
                            ),
                        )
                        .with_field("rule_label", rule.header.label.clone())
                        .with_field("target", target.clone())
                        .with_field("regex_index", *regex_index),
                    ));
                }
                _ => {}
            }
        }
    }
    Ok(())
}

/// A rule must not mix action and blind ownership after bare normalization.
fn check_mixed_edges(spec: &SpecFile) -> Result<()> {
    for rule in &spec.rules {
        let has_action = rule.body.iter().any(|element| match element.kind {
            BodyElementKind::ActionEdge { .. } => true,
            BodyElementKind::BareEdge { .. } => !rule.header.mode.is_and(),
            _ => false,
        });
        let has_blind = rule.body.iter().any(|element| match element.kind {
            BodyElementKind::BlindEdge { .. } => true,
            BodyElementKind::BareEdge { .. } => rule.header.mode.is_and(),
            _ => false,
        });
        if has_action && has_blind {
            return Err(LinkedSpecError::Diagnostic(
                diagnostic(
                    "mixed_edge_ownership",
                    "validate_rule",
                    format!(
                        "rule '{}' mixes action and blind edge ownership",
                        rule.header.label
                    ),
                )
                .with_field("rule_label", rule.header.label.clone())
                .with_field("ownerships", serde_json::json!(["action", "blind"])),
            ));
        }
    }
    Ok(())
}

/// Every opening `{` must have a matching closing `}` within the same rule.
/// Counts braces only in code block content (not the delimiters in source text).
fn check_balanced_braces(spec: &SpecFile) -> Result<()> {
    for rule in &spec.rules {
        let mut depth: i32 = 0;
        for element in &rule.body {
            match &element.kind {
                BodyElementKind::CodeBlock { code, .. } => {
                    for ch in code.chars() {
                        match ch {
                            '{' => depth += 1,
                            '}' => depth -= 1,
                            _ => {}
                        }
                    }
                }
                BodyElementKind::ActionEdge { code, .. } => {
                    if let Some(c) = code {
                        for ch in c.chars() {
                            match ch {
                                '{' => depth += 1,
                                '}' => depth -= 1,
                                _ => {}
                            }
                        }
                    }
                }
                BodyElementKind::BlindEdge { code, .. } => {
                    if let Some(c) = code {
                        for ch in c.chars() {
                            match ch {
                                '{' => depth += 1,
                                '}' => depth -= 1,
                                _ => {}
                            }
                        }
                    }
                }
                BodyElementKind::BareEdge { code: Some(c), .. } => {
                    for ch in c.chars() {
                        match ch {
                            '{' => depth += 1,
                            '}' => depth -= 1,
                            _ => {}
                        }
                    }
                }
                BodyElementKind::PlainBlock { code } => {
                    for ch in code.chars() {
                        match ch {
                            '{' => depth += 1,
                            '}' => depth -= 1,
                            _ => {}
                        }
                    }
                }
                _ => {}
            }
        }
        if depth != 0 {
            return Err(LinkedSpecError::Validation(format!(
                "rule '{}' has unbalanced braces: {} unmatched {}",
                rule.header.label,
                depth.abs(),
                if depth > 0 { "open" } else { "close" }
            )));
        }
    }
    Ok(())
}

/// Every edge target must reference an existing rule.
fn check_edge_targets(spec: &SpecFile) -> Result<()> {
    let labels: HashSet<&str> = spec.rules.iter().map(|r| r.header.label.as_str()).collect();
    for rule in &spec.rules {
        for element in &rule.body {
            let targets: Vec<&str> = match &element.kind {
                BodyElementKind::ActionEdge { targets, .. } => {
                    targets.iter().map(|t| t.label.as_str()).collect()
                }
                BodyElementKind::BlindEdge { target, .. } => vec![target.as_str()],
                BodyElementKind::BareEdge { targets, .. } => {
                    targets.iter().map(|target| target.label.as_str()).collect()
                }
                _ => continue,
            };
            for t in targets {
                if !labels.contains(t) {
                    return Err(LinkedSpecError::Validation(format!(
                        "rule '{}' references undefined rule '{}'",
                        rule.header.label, t
                    )));
                }
            }
        }
    }
    Ok(())
}

/// Every regex literal must compile as a valid regex.
/// rgx (via PGEN) supports the full PCRE2 syntax surface including look-around,
/// backreferences, and subroutine calls — no patterns need to be skipped.
fn check_regex_syntax(spec: &SpecFile) -> Result<()> {
    for rule in &spec.rules {
        for element in &rule.body {
            if let BodyElementKind::Regex { pattern } = &element.kind {
                Regex::compile(pattern).map_err(|e| {
                    LinkedSpecError::Validation(format!(
                        "rule '{}': invalid regex pattern '/{}/': {}",
                        rule.header.label, pattern, e
                    ))
                })?;
            }
        }
    }
    Ok(())
}

/// Strict-mode reference check: every defined rule must be referenced by some
/// edge (`->` / `=>`). Mirrors the Perl reference `Validation.pm` strict_syntax
/// unused-rule warning promoted to an error (`@unused = defined − used`). The top
/// rule is **not** exempt — an unreferenced top rule is reported (parity confirmed
/// against the reference). Rule labels are unique by this point
/// (`check_duplicate_labels`), and definition order is preserved in the message.
fn check_unused_rules(spec: &SpecFile) -> Result<()> {
    let mut used: HashSet<&str> = HashSet::new();
    for rule in &spec.rules {
        for element in &rule.body {
            match &element.kind {
                BodyElementKind::ActionEdge { targets, .. } => {
                    for t in targets {
                        used.insert(t.label.as_str());
                    }
                }
                BodyElementKind::BlindEdge { target, .. } => {
                    used.insert(target.as_str());
                }
                BodyElementKind::BareEdge { targets, .. } => {
                    for target in targets {
                        used.insert(target.label.as_str());
                    }
                }
                _ => {}
            }
        }
    }
    let unused: Vec<&str> = spec
        .rules
        .iter()
        .map(|r| r.header.label.as_str())
        .filter(|label| !used.contains(label))
        .collect();
    if !unused.is_empty() {
        return Err(LinkedSpecError::Validation(format!(
            "unused rule(s) in strict mode: {}",
            unused.join(", ")
        )));
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ast::{FunctionDefinition, SourceSpan};
    use crate::parser::parse_spec;

    fn spec_with_user_functions(functions: Vec<FunctionDefinition>, rules_src: &str) -> SpecFile {
        let mut spec = parse_spec(rules_src).unwrap();
        spec.functions = functions;
        spec
    }

    fn user_function(name: &str, params: &[&str]) -> FunctionDefinition {
        FunctionDefinition {
            name: name.to_string(),
            params: params.iter().map(|param| param.to_string()).collect(),
            arity: params.len(),
            parameter_kinds: Default::default(),
            signature: None,
            body_source: "return(value)".to_string(),
            body_payload: None,
            body_parse_job: None,
            body_ast: None,
            source: format!("fn {name}({}) {{ return(value) }}", params.join(", ")),
            source_span: SourceSpan {
                line_start: 1,
                line_end: 1,
            },
            body_span: SourceSpan {
                line_start: 1,
                line_end: 1,
            },
        }
    }

    #[test]
    fn validate_accepts_valid_spec() {
        let src = "Top::\n /a/ -> Child\n\nChild:\n /b/";
        let spec = parse_spec(src).unwrap();
        assert!(validate(&spec).is_ok());
    }

    #[test]
    fn validate_accepts_markerless_rule() {
        let src = "R:\n /a/";
        let spec = parse_spec(src).unwrap();
        validate(&spec).unwrap();
    }

    #[test]
    fn validate_rejects_zero_rules_with_portable_diagnostic() {
        let spec = parse_spec("# no rule declarations\n").unwrap();
        let error = validate(&spec).unwrap_err();
        let diagnostic = error.diagnostic().expect("portable rule-count diagnostic");
        assert_eq!(diagnostic.code, "no_rules_defined");
        assert_eq!(diagnostic.stage, "validate_spec");
        assert!(diagnostic.fields.is_empty());
    }

    #[test]
    fn validate_rejects_duplicate_labels() {
        let src = "Top::\n /a/\n\nTop:\n /b/";
        let spec = parse_spec(src).unwrap();
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("duplicate")
        );
    }

    #[test]
    fn validate_accepts_user_function_registry() {
        let spec = spec_with_user_functions(
            vec![user_function("normalize", &["value"])],
            "Top::\n /x/\n",
        );
        validate(&spec).unwrap();
    }

    #[test]
    fn validate_rejects_duplicate_user_function_names() {
        let spec = spec_with_user_functions(
            vec![
                user_function("normalize", &["value"]),
                user_function("normalize", &["other"]),
            ],
            "Top::\n /x/\n",
        );
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("duplicate user function")
        );
    }

    #[test]
    fn validate_rejects_user_function_rule_label_collision() {
        let spec =
            spec_with_user_functions(vec![user_function("Top", &["value"])], "Top::\n /x/\n");
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("collides with rule label")
        );
    }

    #[test]
    fn validate_rejects_user_function_builtin_collision() {
        let spec =
            spec_with_user_functions(vec![user_function("trim", &["value"])], "Top::\n /x/\n");
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("built-in helper")
        );
    }

    #[test]
    fn validate_rejects_user_function_numeric_alias_collisions() {
        for name in [
            "add", "sub", "mul", "div", "mod", "abs", "floor", "ceil", "round", "min", "max",
            "clamp", "sum", "avg", "median", "range",
        ] {
            let spec =
                spec_with_user_functions(vec![user_function(name, &["value"])], "Top::\n /x/\n");
            assert!(
                validate(&spec)
                    .unwrap_err()
                    .to_string()
                    .contains("built-in helper"),
                "expected numeric alias {name} to be rejected"
            );
        }
    }

    #[test]
    fn validate_rejects_user_function_duplicate_parameter() {
        let spec = spec_with_user_functions(
            vec![user_function("normalize", &["value", "value"])],
            "Top::\n /x/\n",
        );
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("duplicate parameter")
        );
    }

    #[test]
    fn validate_rejects_user_function_reserved_parameter() {
        let spec =
            spec_with_user_functions(vec![user_function("normalize", &["ctx"])], "Top::\n /x/\n");
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("parameter 'ctx' is reserved")
        );
    }

    #[test]
    fn validate_rejects_mixed_edges() {
        let src = "Top::\n /a/ -> A\n /b/ => B";
        let spec = parse_spec(src).unwrap();
        assert!(validate(&spec).unwrap_err().to_string().contains("mixes"));
    }

    #[test]
    fn validate_rejects_undefined_target() {
        let src = "Top::\n /a/ -> Ghost";
        let spec = parse_spec(src).unwrap();
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("undefined rule")
        );
    }

    #[test]
    fn validate_rejects_invalid_regex() {
        let src = "Top::\n /[invalid/";
        let spec = parse_spec(src).unwrap();
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("invalid regex")
        );
    }

    #[test]
    fn validate_from_parse() {
        let src = "Top::\n /a/ -> Child\n\nChild:\n /b/ E { return(42) }";
        let spec = parse_spec(src).unwrap();
        validate(&spec).unwrap();
    }

    // ── RUST-PARITY.6: strict_syntax validation mode ──
    // Parity with the Perl reference `Validation.pm validate_dsl_syntax(...,
    // strict_syntax => 1)`: reference warnings (undefined, then unused) become
    // hard errors. Verified empirically against the reference (an unreferenced
    // top rule IS flagged as unused; undefined is reported first).

    #[test]
    fn validate_strict_rejects_unreferenced_top_rule() {
        // Top references Child, but Top itself is referenced by nothing → "unused"
        // under strict mode (the top rule is not exempt — matches the reference).
        let src = "Top::\n /a/ -> Child\n\nChild:\n /b/";
        let spec = parse_spec(src).unwrap();
        let err = validate_with_options(&spec, true).unwrap_err().to_string();
        assert!(
            err.contains("unused"),
            "expected unused-rule error, got: {err}"
        );
        assert!(
            err.contains("Top"),
            "expected 'Top' in the error, got: {err}"
        );
    }

    #[test]
    fn validate_nonstrict_allows_unreferenced_rules() {
        // The same spec passes in the default (non-strict) mode — unused rules are
        // only a warning in the reference, and this backend has no warning channel.
        let src = "Top::\n /a/ -> Child\n\nChild:\n /b/";
        let spec = parse_spec(src).unwrap();
        validate(&spec).unwrap();
        validate_with_options(&spec, false).unwrap();
    }

    #[test]
    fn validate_strict_markerless_rules_keep_authored_edge_semantics() {
        let unreferenced = parse_spec("A:\n /a/\n\nB:\n /b/\n").unwrap();
        let error = validate_with_options(&unreferenced, true)
            .unwrap_err()
            .to_string();
        assert!(
            error.contains("unused rule(s) in strict mode: A, B"),
            "{error}"
        );

        let closed_cycle = parse_spec("A:\n /a/ -> B\n\nB:\n /b/ -> A\n").unwrap();
        validate_with_options(&closed_cycle, true).unwrap();
    }

    #[test]
    fn validate_strict_still_rejects_undefined_reference() {
        // Undefined references stay fatal in strict mode (reported before unused).
        let src = "Top::\n /a/ -> Ghost";
        let spec = parse_spec(src).unwrap();
        let err = validate_with_options(&spec, true).unwrap_err().to_string();
        assert!(
            err.contains("undefined rule"),
            "expected undefined-rule error, got: {err}"
        );
    }

    #[test]
    fn validate_strict_accepts_fully_referenced_spec() {
        // Every defined rule is referenced (the top references itself) → no unused
        // rule, so strict mode passes.
        let src = "Top::\n /a/ -> Top";
        let spec = parse_spec(src).unwrap();
        validate_with_options(&spec, true).unwrap();
    }
}
