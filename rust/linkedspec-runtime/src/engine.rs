//! Runtime engine — executes compiled rule specifications against input text.
//!
//! The engine:
//! 1. Builds regex alternations from compiled rule patterns
//! 2. Executes the lifecycle loop (I → LS → match → LE → IT → LX/EX → E)
//! 3. Dispatches to child rules recursively
//! 4. Interprets lifecycle code expression trees
//! 5. Returns parse results as JSON
//!
//! ## Lifecycle loop
//!
//! For non-REP (single-fire) rules:
//!   I → LS → match → (acode dispatch) → LE → E
//! If no match:
//!   I → LS → no match → LX → E
//!
//! For REP (repeating) rules:
//!   I → loop { LS → match → (acode dispatch) → LE → IT } → EX → E
//! If no match on first iteration:
//!   I → LS → no match → LX → E
//!
//! ## Blind-call dispatch
//!
//! Blind-call rules (`=> child`) dispatch children from `bcode_dispatch`.
//! Explicit OR mode stops after the first truthy child return; AND mode invokes
//! each child sequentially, and repeated blind-call modes loop those choice or
//! sequence steps with the normal repetition bounds and progress guard.
//! Blind-call dispatch takes priority over regex + acode dispatch.
//!
//! ## Multi-entrypoint child dispatch
//!
//! When `-> child[N]` is used, `child_regex_idx` selects which regex of the
//! child rule to start with. The default (0) uses the first regex.

use crate::helpers::regex_engine::CompiledAlternation;
use crate::runtime::{RuntimeContext, RuntimeVarKind};
use crate::source_emitter::{GeneratedRuleFamily, GeneratedRuleSpec};
use linkedspec_core::ast::RuleMode;
use linkedspec_core::expr::{AccessSegment, Arg, CodeBlock, Expr};
use linkedspec_core::trace::{TraceConfig, TraceEmitter, TraceLevel};
use linkedspec_core::types::{
    BcodeEntry, CompiledSpec, CompiledUserFunction, ParseMode, RuntimeValue,
};
use serde_json::Value;

const LINKEDSPEC_WHILE_ITERATION_LIMIT: usize = 10_000;

/// Per-invocation controls for direct top-rule value execution.
///
/// These options do not mutate the compiled specification. They select an
/// optional entry rule and optionally override every rule's compiled parse mode
/// for this execution only.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct ExecutionOptions {
    entry_rule: Option<String>,
    parse_mode: Option<ParseMode>,
}

impl ExecutionOptions {
    /// Create default options: enter the compiled top rule and retain each
    /// rule's compiled parse mode.
    pub fn new() -> Self {
        Self::default()
    }

    /// Select the rule entered first for this execution.
    pub fn with_entry_rule(mut self, label: impl Into<String>) -> Self {
        self.entry_rule = Some(label.into());
        self
    }

    /// Override every rule's compiled parse mode for this execution.
    pub fn with_parse_mode(mut self, mode: ParseMode) -> Self {
        self.parse_mode = Some(mode);
        self
    }

    /// Return the selected entry rule, if any.
    pub fn entry_rule(&self) -> Option<&str> {
        self.entry_rule.as_deref()
    }

    /// Return the global parse-mode override, if any.
    pub fn parse_mode(&self) -> Option<ParseMode> {
        self.parse_mode
    }
}

#[derive(Debug, Clone)]
enum EvaluatedAccessSegment {
    Key(String),
    Index(usize),
}

/// The runtime engine executes CompiledRule nodes against input text.
pub struct Engine {
    /// The compiled spec being executed (needed for child rule lookup).
    spec: CompiledSpec,
}

/// Saved per-invocation entry/local match state.
///
/// In the Perl reference, the entry match (`IMATCH`) and the local match
/// (`LMATCH`) are per-handler `my` lexicals, so a child rule's matching can
/// never mutate the parent's match state. The Rust engine shares one
/// `RuntimeContext` across the whole parse, so `execute_rule` emulates that
/// lexical scoping: on entry it saves the caller's match state here, and on exit
/// it restores it — making nested dispatch transparent to the parent.
struct SavedMatchState {
    entry_groups: Vec<String>,
    entry_named: std::collections::HashMap<String, String>,
    entry_match_present: bool,
    match_groups: Vec<String>,
    match_named: std::collections::HashMap<String, String>,
    match_present: bool,
    entry_start_byte: usize,
    entry_end_byte: usize,
    match_start_byte: usize,
    match_end_byte: usize,
    capture_start: Option<usize>,
}

/// Statement-form conditional state for lifecycle blocks.
///
/// This is deliberately separate from the expression-level `if(...)` helper:
/// `if(cond, then, else)` remains a lazy value expression, while
/// `if(cond); ... else(); ... endif()` gates subsequent statements in the block.
struct StatementIfFrame {
    parent_active: bool,
    current_active: bool,
    branch_taken: bool,
}

/// Statement-form switch state for lifecycle blocks.
///
/// `switch(expr); case(value); ... default(); ... endswitch()` is the statement
/// sibling of lazy value-form `switch(expr, case(...), default(...))`.
struct StatementSwitchFrame {
    parent_active: bool,
    current_active: bool,
    branch_taken: bool,
    switch_value: String,
}

#[derive(Clone, Copy)]
enum ShapeLiteralKind {
    Array,
    Hash,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
enum StatementBlockFlow {
    Continue,
    Returned,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
enum ActionEdgeFlow {
    Continue,
    Returned,
}

enum ValueBlockFlow {
    Continue,
    Returned(RuntimeValue),
}

impl SavedMatchState {
    /// Restore the saved caller match state onto the context (invocation exit).
    fn restore(self, ctx: &mut RuntimeContext) {
        ctx.entry_groups = self.entry_groups;
        ctx.entry_named = self.entry_named;
        ctx.entry_match_present = self.entry_match_present;
        ctx.match_groups = self.match_groups;
        ctx.match_named = self.match_named;
        ctx.match_present = self.match_present;
        ctx.entry_start_byte = self.entry_start_byte;
        ctx.entry_end_byte = self.entry_end_byte;
        ctx.match_start_byte = self.match_start_byte;
        ctx.match_end_byte = self.match_end_byte;
        ctx.capture_start = self.capture_start;
    }
}

/// Convert a **byte** offset into `input` to a **character** offset. Internal
/// positions (`ctx.pos`, marks, match spans, regex byte offsets) are byte-based,
/// but the Perl reference exposes char offsets (`pos()` is char-based), so every
/// position/length surfaced to the DSL goes through this.
fn byte_to_char_offset(input: &str, byte_off: usize) -> usize {
    let clamped = byte_off.min(input.len());
    input[..clamped].chars().count()
}

fn line_col_at_char_offset(input: &str, char_off: usize) -> (usize, usize) {
    let mut line = 1;
    let mut col = 1;
    for ch in input.chars().take(char_off.min(input.chars().count())) {
        if ch == '\n' {
            line += 1;
            col = 1;
        } else {
            col += 1;
        }
    }
    (line, col)
}

fn line_col_at_byte_offset(input: &str, byte_off: usize) -> (usize, usize) {
    line_col_at_char_offset(input, byte_to_char_offset(input, byte_off))
}

fn line_col_from_optional_char_arg(
    input: &str,
    args: &[RuntimeValue],
    default_byte_off: usize,
) -> (usize, usize) {
    match args.first().and_then(RuntimeValue::as_number) {
        Some(pos) => line_col_at_char_offset(input, pos.max(0.0) as usize),
        None => line_col_at_byte_offset(input, default_byte_off),
    }
}

/// `len` characters of `s` starting at character index `start` (Perl `substr`
/// semantics — char-based, never panics on a multibyte boundary).
fn char_substr(s: &str, start: usize, len: usize) -> String {
    s.chars().skip(start).take(len).collect()
}

/// The suffix of `s` from character index `start` (`substr($s, $start)`).
fn char_substr_from(s: &str, start: usize) -> String {
    s.chars().skip(start).collect()
}

/// Owned text of the byte span `input[start..end]`, used by the mark-based
/// capture family (`capture_*_from`, `capture_between`). `start`/`end` are
/// **byte** offsets at char boundaries (marks, match spans, the cursor). A
/// reversed or out-of-range span yields `None` (→ DSL `undef`) instead of
/// panicking — the Perl reference guards these readers with a `defined`/`>=`
/// check (RUST-PARITY.5.5.3, parity with `Contracts.pm` ~690–928).
fn span_text(input: &str, start: usize, end: usize) -> Option<String> {
    if start <= end && end <= input.len() {
        Some(input[start..end].to_string())
    } else {
        None
    }
}

/// Char-length of the byte span `input[start..end]` — DSL lengths are
/// char-based (RUST-PARITY.5.3), guarded exactly like [`span_text`].
fn span_char_len(input: &str, start: usize, end: usize) -> Option<usize> {
    if start <= end && end <= input.len() {
        Some(input[start..end].chars().count())
    } else {
        None
    }
}

fn next_char_boundary_after(input: &str, byte_off: usize) -> usize {
    if byte_off >= input.len() {
        return input.len();
    }
    input[byte_off..]
        .char_indices()
        .nth(1)
        .map(|(offset, _)| byte_off + offset)
        .unwrap_or(input.len())
}

fn regex_literal_arg(args: &[Arg], index: usize) -> Option<&str> {
    match args.get(index).map(Arg::value) {
        Some(Expr::RegexLiteral { pattern }) => Some(pattern.as_str()),
        _ => None,
    }
}

fn scalar_mutation_target_arg(arg: &Arg) -> Option<String> {
    match arg.value() {
        Expr::Variable { name } => Some(name.clone()),
        _ => None,
    }
}

fn regex_subst_call_parts(raw_args: &[Arg]) -> Option<(String, usize, usize, usize)> {
    if raw_args.len() >= 5
        && let Some(target) = scalar_mutation_target_arg(&raw_args[1])
    {
        return Some((target, 2, 3, 4));
    }
    if raw_args.len() >= 4
        && let Some(target) = scalar_mutation_target_arg(&raw_args[0])
    {
        return Some((target, 1, 2, 3));
    }
    None
}

fn array_mutation_target_arg(arg: &Arg) -> Option<String> {
    match arg.value() {
        Expr::Call { name, args } if name == "array" && args.len() == 1 => match args[0].value() {
            Expr::Variable { name } => Some(name.clone()),
            _ => None,
        },
        Expr::Variable { name } => Some(name.clone()),
        _ => None,
    }
}

fn split_statement_call_parts(raw_args: &[Arg]) -> Option<(String, usize, usize)> {
    if raw_args.len() >= 4
        && let Some(target) = array_mutation_target_arg(&raw_args[1])
    {
        return Some((target, 2, 3));
    }
    if raw_args.len() >= 3
        && let Some(target) = array_mutation_target_arg(&raw_args[0])
    {
        return Some((target, 1, 2));
    }
    None
}

fn literal_or_value_arg_text(raw_args: &[Arg], args: &[RuntimeValue], index: usize) -> String {
    match raw_args.get(index).map(Arg::value) {
        Some(Expr::StringLiteral { value }) | Some(Expr::RegexLiteral { pattern: value }) => {
            value.clone()
        }
        _ => args
            .get(index)
            .map(RuntimeValue::to_str)
            .unwrap_or_default(),
    }
}

fn regex_subst_flags_arg(raw_args: &[Arg], args: &[RuntimeValue], index: usize) -> String {
    match raw_args.get(index).map(Arg::value) {
        Some(Expr::Variable { name }) => name.clone(),
        Some(Expr::StringLiteral { value }) | Some(Expr::RegexLiteral { pattern: value }) => {
            value.clone()
        }
        _ => args
            .get(index)
            .map(RuntimeValue::to_str)
            .unwrap_or_default(),
    }
}

fn regex_subst_pattern_with_flags(pattern: &str, flags: &str) -> String {
    let mut inline_flags = String::new();
    for flag in ['i', 'm', 's', 'x'] {
        if flags.contains(flag) {
            inline_flags.push(flag);
        }
    }
    if inline_flags.is_empty() {
        pattern.to_string()
    } else {
        format!("(?{inline_flags}:{pattern})")
    }
}

fn split_string_literal(input: &str, delimiter: &str) -> Vec<RuntimeValue> {
    input
        .split(delimiter)
        .map(|part| RuntimeValue::Scalar(part.to_string()))
        .collect()
}

fn split_string_regex(input: &str, pattern: &str) -> Result<Vec<RuntimeValue>, String> {
    let alt = CompiledAlternation::compile(&[pattern.to_string()])?;
    let mut parts = Vec::new();
    let mut slice_start = 0usize;
    let mut search_start = 0usize;

    while search_start <= input.len() {
        let Some(matched) = alt.seek_match(input, search_start) else {
            break;
        };

        if matched.start < slice_start {
            break;
        }

        parts.push(RuntimeValue::Scalar(
            input[slice_start..matched.start].to_string(),
        ));
        slice_start = matched.end;

        if matched.start == matched.end {
            if matched.end >= input.len() {
                break;
            }
            search_start = next_char_boundary_after(input, matched.end);
        } else {
            search_start = matched.end;
        }
    }

    parts.push(RuntimeValue::Scalar(input[slice_start..].to_string()));
    Ok(parts)
}

fn split_string_for_arg(
    input: &str,
    raw_args: &[Arg],
    delimiter_index: usize,
    delimiter: &RuntimeValue,
) -> Result<Vec<RuntimeValue>, String> {
    if let Some(pattern) = regex_literal_arg(raw_args, delimiter_index) {
        split_string_regex(input, pattern)
    } else {
        Ok(split_string_literal(input, &delimiter.to_str()))
    }
}

/// Materialize a named-capture map (`entry_named`/`match_named`) into a
/// `RuntimeValue::Hash` for the `entry_map`/`match_map` helpers (Helper Contract
/// Catalog §8). Keys are sorted so the projection is deterministic — independent
/// of host `HashMap` iteration order — matching `sorted_keys`/`sorted_values`.
fn named_map_to_hash(named: &std::collections::HashMap<String, String>) -> RuntimeValue {
    let mut entries: Vec<(String, RuntimeValue)> = named
        .iter()
        .map(|(k, v)| (k.clone(), RuntimeValue::Scalar(v.clone())))
        .collect();
    entries.sort_by(|(a, _), (b, _)| a.cmp(b));
    RuntimeValue::Hash(entries)
}

fn trace_write_failed(err: impl std::fmt::Display) -> String {
    format!("trace write failed: {err}")
}

fn runtime_value_trace_kind(value: &RuntimeValue) -> &'static str {
    match value {
        RuntimeValue::Undef => "undef",
        RuntimeValue::Bool(_) => "bool",
        RuntimeValue::Number(_) => "number",
        RuntimeValue::Scalar(_) => "scalar",
        RuntimeValue::Array(_) => "array",
        RuntimeValue::Hash(_) => "hash",
    }
}

struct GeneratedPlanExecutor<'a> {
    engine: &'a Engine,
    generated_rules: &'a [GeneratedRuleSpec],
}

impl GeneratedPlanExecutor<'_> {
    fn execute_rule(
        &self,
        label: &str,
        entry_regex_idx: usize,
        ctx: &mut RuntimeContext,
    ) -> Result<RuntimeValue, String> {
        let entry_pos = ctx.pos;
        ctx.trace_enter(
            "rust_runtime:generated_plan:rule",
            format!("label={label} entry_regex_idx={entry_regex_idx} pos={entry_pos}"),
            TraceLevel::LOW,
        );
        let result = (|| {
            let family = self.generated_rule_family(label)?;
            ctx.trace_decision(
                "rust_runtime:generated_plan:family_dispatch",
                true,
                format!("label={label} family={family:?} entry_regex_idx={entry_regex_idx}"),
                TraceLevel::MEDIUM,
            );
            match family {
                GeneratedRuleFamily::Default
                | GeneratedRuleFamily::OrAcode
                | GeneratedRuleFamily::AndSingleAcode
                | GeneratedRuleFamily::AndAcodeSeq => {
                    self.execute_direct_acode_rule(label, entry_regex_idx, family, ctx)
                }
                GeneratedRuleFamily::AndBcode | GeneratedRuleFamily::OrBcode => {
                    self.execute_direct_bcode_rule(label, entry_regex_idx, family, ctx)
                }
                GeneratedRuleFamily::RepAcode | GeneratedRuleFamily::RepAndAcode => {
                    self.execute_direct_acode_rule(label, entry_regex_idx, family, ctx)
                }
                GeneratedRuleFamily::RepBcode | GeneratedRuleFamily::RepAndBcode => {
                    self.execute_direct_bcode_rule(label, entry_regex_idx, family, ctx)
                }
                GeneratedRuleFamily::Repetition => {
                    let rule = self.engine.spec.find(label).ok_or_else(|| {
                        format!(
                            "rule '{}' (entry idx {}) not found in compiled spec",
                            label, entry_regex_idx
                        )
                    })?;
                    let family = crate::source_emitter::classify_generated_rule_family(rule);
                    self.execute_rule_by_family(label, entry_regex_idx, family, ctx)
                }
            }
        })();
        let status = match &result {
            Ok(value) => format!("status=ok value_kind={}", runtime_value_trace_kind(value)),
            Err(err) => format!("status=error error={err}"),
        };
        ctx.trace_exit(
            "rust_runtime:generated_plan:rule",
            format!("{status} label={label} pos={}", ctx.pos),
            TraceLevel::LOW,
        );
        result
    }

    fn execute_rule_by_family(
        &self,
        label: &str,
        entry_regex_idx: usize,
        family: GeneratedRuleFamily,
        ctx: &mut RuntimeContext,
    ) -> Result<RuntimeValue, String> {
        match family {
            GeneratedRuleFamily::Default
            | GeneratedRuleFamily::OrAcode
            | GeneratedRuleFamily::AndSingleAcode
            | GeneratedRuleFamily::AndAcodeSeq
            | GeneratedRuleFamily::RepAcode
            | GeneratedRuleFamily::RepAndAcode => {
                self.execute_direct_acode_rule(label, entry_regex_idx, family, ctx)
            }
            GeneratedRuleFamily::AndBcode
            | GeneratedRuleFamily::OrBcode
            | GeneratedRuleFamily::RepBcode
            | GeneratedRuleFamily::RepAndBcode => {
                self.execute_direct_bcode_rule(label, entry_regex_idx, family, ctx)
            }
            GeneratedRuleFamily::Repetition => Err(format!(
                "generated rule '{label}' retained unspecialized repetition family"
            )),
        }
    }

    fn generated_rule_family(&self, label: &str) -> Result<GeneratedRuleFamily, String> {
        self.generated_rules
            .iter()
            .find(|rule| rule.label == label)
            .map(|rule| rule.family)
            .ok_or_else(|| format!("generated rule plan missing label '{label}'"))
    }

    fn execute_child_rule(
        &self,
        label: &str,
        entry_regex_idx: usize,
        ctx: &mut RuntimeContext,
    ) -> Result<RuntimeValue, String> {
        let accumulator_len = ctx.accumulator.len();
        ctx.trace_decision(
            "rust_runtime:generated_plan:child_dispatch",
            true,
            format!(
                "label={label} entry_regex_idx={entry_regex_idx} pos={} accumulator_len={accumulator_len}",
                ctx.pos
            ),
            TraceLevel::MEDIUM,
        );
        let child_result = self.execute_rule(label, entry_regex_idx, ctx);
        ctx.accumulator.truncate(accumulator_len);
        match &child_result {
            Ok(value) => {
                ctx.trace_decision(
                    "rust_runtime:generated_plan:child_dispatch_result",
                    value.as_bool(),
                    format!(
                        "label={label} value_kind={}",
                        runtime_value_trace_kind(value)
                    ),
                    TraceLevel::MEDIUM,
                );
            }
            Err(err) => {
                ctx.trace_decision(
                    "rust_runtime:generated_plan:child_dispatch_result",
                    false,
                    format!("label={label} error={err}"),
                    TraceLevel::MEDIUM,
                );
            }
        }
        child_result
    }

    fn execute_action_edge_child_rule(
        &self,
        label: &str,
        entry_regex_idx: usize,
        ctx: &mut RuntimeContext,
    ) -> Result<RuntimeValue, String> {
        if self.engine.is_passive_terminal_rule(label) {
            ctx.trace_decision(
                "rust_runtime:generated_plan:passive_terminal_dispatch",
                false,
                format!(
                    "label={label} entry_regex_idx={entry_regex_idx} pos={}",
                    ctx.pos
                ),
                TraceLevel::MEDIUM,
            );
            return Ok(RuntimeValue::Undef);
        }
        self.execute_child_rule(label, entry_regex_idx, ctx)
    }

    fn execute_direct_acode_rule(
        &self,
        label: &str,
        entry_regex_idx: usize,
        family: GeneratedRuleFamily,
        ctx: &mut RuntimeContext,
    ) -> Result<RuntimeValue, String> {
        let entry_pos = ctx.pos;
        if !ctx.enter_recursion(label, entry_pos) {
            ctx.trace_decision(
                "rust_runtime:generated_plan:recursion_guard",
                false,
                format!("label={label} entry_regex_idx={entry_regex_idx} pos={entry_pos}"),
                TraceLevel::MEDIUM,
            );
            return Ok(RuntimeValue::Undef);
        }

        ctx.enter_rule_variable_scope();
        ctx.trace_enter(
            "rust_runtime:generated_plan:direct_acode_rule",
            format!(
                "label={label} entry_regex_idx={entry_regex_idx} family={family:?} pos={entry_pos}"
            ),
            TraceLevel::MEDIUM,
        );
        let result = self.execute_direct_acode_rule_inner(label, entry_regex_idx, family, ctx);
        let status = match &result {
            Ok(value) => format!("status=ok value_kind={}", runtime_value_trace_kind(value)),
            Err(err) => format!("status=error error={err}"),
        };
        ctx.trace_exit(
            "rust_runtime:generated_plan:direct_acode_rule",
            format!("{status} label={label} pos={}", ctx.pos),
            TraceLevel::MEDIUM,
        );
        ctx.exit_rule_variable_scope();
        ctx.exit_recursion(label, entry_pos);
        result
    }

    fn execute_direct_acode_rule_inner(
        &self,
        label: &str,
        entry_regex_idx: usize,
        family: GeneratedRuleFamily,
        ctx: &mut RuntimeContext,
    ) -> Result<RuntimeValue, String> {
        let rule = self.engine.spec.find(label).ok_or_else(|| {
            format!(
                "rule '{}' (entry idx {}) not found in compiled spec",
                label, entry_regex_idx
            )
        })?;

        let caller_return = ctx.take_return_value();
        let saved_match = SavedMatchState {
            entry_groups: std::mem::take(&mut ctx.entry_groups),
            entry_named: std::mem::take(&mut ctx.entry_named),
            entry_match_present: ctx.entry_match_present,
            match_groups: std::mem::take(&mut ctx.match_groups),
            match_named: std::mem::take(&mut ctx.match_named),
            match_present: ctx.match_present,
            entry_start_byte: ctx.entry_start_byte,
            entry_end_byte: ctx.entry_end_byte,
            match_start_byte: ctx.match_start_byte,
            match_end_byte: ctx.match_end_byte,
            capture_start: ctx.capture_start,
        };
        ctx.entry_groups = saved_match.match_groups.clone();
        ctx.entry_named = saved_match.match_named.clone();
        ctx.entry_match_present = saved_match.match_present;
        ctx.entry_start_byte = saved_match.match_start_byte;
        ctx.entry_end_byte = saved_match.match_end_byte;
        ctx.match_start_byte = 0;
        ctx.match_end_byte = 0;
        ctx.match_present = false;
        ctx.capture_start = Some(ctx.entry_end_byte);

        macro_rules! return_if_rule_returned {
            () => {
                if let Some(my_return) = ctx.take_return_value() {
                    ctx.restore_return_value(caller_return);
                    saved_match.restore(ctx);
                    return Ok(my_return);
                }
            };
        }

        let alt = if rule.regex_patterns.is_empty() {
            CompiledAlternation::compile(&[])?
        } else {
            CompiledAlternation::compile(&rule.regex_patterns)?
        };

        if let Some(ref preamble) = rule.preamble {
            self.engine
                .execute_lifecycle_block("I", preamble, ctx, label)?;
            return_if_rule_returned!();
        }

        if !rule.bcode_dispatch.is_empty() {
            ctx.restore_return_value(caller_return);
            saved_match.restore(ctx);
            return Err(format!(
                "generated direct acode executor received bcode rule '{label}'"
            ));
        }

        let is_rep = rule.rep_min.is_some();
        let rep_min = rule.rep_min.unwrap_or(0);
        let rep_max = rule.rep_max;
        let is_rep_and_acode_seq = is_rep
            && matches!(family, GeneratedRuleFamily::RepAndAcode)
            && rule.regex_patterns.len() > 1;
        let is_and_acode_seq = (!is_rep
            && matches!(family, GeneratedRuleFamily::AndAcodeSeq)
            && rule.regex_patterns.len() > 1)
            || is_rep_and_acode_seq;
        let and_acode_seq_len = rule.regex_patterns.len();
        let mut matches: usize = 0;
        let mut and_acode_idx: usize = 0;
        let mut rep_and_start_pos = ctx.pos;
        let max_iter = 10_000;
        let has_entry_idx = entry_regex_idx > 0 && entry_regex_idx < rule.regex_patterns.len();

        for _iter in 0..max_iter {
            if is_rep_and_acode_seq && and_acode_idx == 0 {
                rep_and_start_pos = ctx.pos;
            }
            if !is_rep && !is_and_acode_seq && matches > 0 {
                break;
            }
            if !is_rep && is_and_acode_seq && matches >= and_acode_seq_len {
                break;
            }
            if is_rep_and_acode_seq
                && let Some(max) = rep_max
                && matches >= max
            {
                break;
            }

            let pos_before = ctx.pos;

            if let Some(ref lscode) = rule.lscode {
                self.engine
                    .execute_lifecycle_block("LS", lscode, ctx, label)?;
                return_if_rule_returned!();
            }

            let parse_mode = ctx.effective_parse_mode(rule.parse_mode);
            let match_result = if has_entry_idx && matches == 0 {
                let entry_pat = &rule.regex_patterns[entry_regex_idx];
                let entry_alt = CompiledAlternation::compile(std::slice::from_ref(entry_pat))?;
                match parse_mode {
                    ParseMode::Consume => entry_alt.consume_match(&ctx.input, ctx.pos),
                    ParseMode::Seek => entry_alt.seek_match(&ctx.input, ctx.pos),
                }
                .map(|mut m| {
                    m.index = entry_regex_idx;
                    m
                })
            } else {
                match parse_mode {
                    ParseMode::Consume => alt.consume_match(&ctx.input, ctx.pos),
                    ParseMode::Seek => alt.seek_match(&ctx.input, ctx.pos),
                }
            };

            match &match_result {
                Some(m) => {
                    ctx.trace_decision(
                        "rust_runtime:generated_plan:regex_match",
                        true,
                        format!(
                            "rule={label} regex_idx={} start={} end={} pos_before={pos_before} parse_mode={:?} entry_regex_idx={entry_regex_idx}",
                            m.index, m.start, m.end, parse_mode
                        ),
                        TraceLevel::MEDIUM,
                    );
                }
                None => {
                    ctx.trace_decision(
                        "rust_runtime:generated_plan:regex_match",
                        false,
                        format!(
                            "rule={label} pos_before={pos_before} parse_mode={:?} entry_regex_idx={entry_regex_idx}",
                            parse_mode
                        ),
                        TraceLevel::MEDIUM,
                    );
                }
            }

            if let Some(m) = match_result {
                let expected_and_idx = if is_rep_and_acode_seq {
                    and_acode_idx
                } else {
                    matches
                };
                if is_and_acode_seq && m.index != expected_and_idx {
                    ctx.trace_decision(
                        "rust_runtime:generated_plan:and_sequence_slot",
                        false,
                        format!(
                            "rule={label} regex_idx={} expected_idx={expected_and_idx} matches={matches}",
                            m.index
                        ),
                        TraceLevel::MEDIUM,
                    );
                    if let Some(ref lxcode) = rule.lxcode {
                        self.engine
                            .execute_lifecycle_block("LX", lxcode, ctx, label)?;
                        return_if_rule_returned!();
                    }
                    break;
                }

                let entry_was_empty = !ctx.entry_match_present;
                ctx.set_pos(m.end);
                ctx.match_groups = m.captures.clone();
                ctx.match_named = m.named.clone();
                ctx.match_start_byte = m.start;
                ctx.match_end_byte = m.end;
                ctx.match_present = true;
                if entry_was_empty {
                    ctx.entry_groups = m.captures.clone();
                    ctx.entry_named = m.named.clone();
                    ctx.entry_start_byte = m.start;
                    ctx.entry_end_byte = m.end;
                    ctx.entry_match_present = true;
                }

                let mut dispatched_acode = false;
                for entry in &rule.acode_dispatch {
                    if entry.regex_idx == m.index {
                        dispatched_acode = true;
                        ctx.trace_decision(
                            "rust_runtime:generated_plan:acode_dispatch",
                            true,
                            format!(
                                "rule={label} regex_idx={} child={} child_regex_idx={} fluent_chain_len={} has_code={}",
                                entry.regex_idx,
                                entry.child_label,
                                entry.child_regex_idx,
                                entry.fluent_chain.len(),
                                entry.code.is_some()
                            ),
                            TraceLevel::MEDIUM,
                        );
                        if entry.fluent_chain.is_empty() {
                            if let Some(ref block) = entry.code {
                                if Engine::block_calls_rule(block, &entry.child_label)
                                    || Engine::block_reads_retv(block)
                                {
                                    let child_retv = self.execute_action_edge_child_rule(
                                        &entry.child_label,
                                        entry.child_regex_idx,
                                        ctx,
                                    )?;
                                    ctx.push_action_edge_call_result(
                                        &entry.child_label,
                                        child_retv.clone(),
                                    );
                                    ctx.set_retv(child_retv.clone());
                                    let block_result = self.engine.execute_block(block, ctx, label);
                                    ctx.pop_action_edge_call_result();
                                    block_result?;
                                    return_if_rule_returned!();
                                    ctx.set_retv(child_retv);
                                } else if entry.child_label == label {
                                    self.engine.execute_block(block, ctx, label)?;
                                    return_if_rule_returned!();
                                } else {
                                    self.engine.execute_block(block, ctx, label)?;
                                    return_if_rule_returned!();
                                    let child_retv = self.execute_action_edge_child_rule(
                                        &entry.child_label,
                                        entry.child_regex_idx,
                                        ctx,
                                    )?;
                                    ctx.set_retv(child_retv);
                                }
                            } else {
                                let child_retv = self.execute_action_edge_child_rule(
                                    &entry.child_label,
                                    entry.child_regex_idx,
                                    ctx,
                                )?;
                                ctx.set_retv(child_retv);
                            }
                        } else if self
                            .engine
                            .execute_action_edge_fluent_chain(entry, ctx, label)?
                            == ActionEdgeFlow::Returned
                        {
                            let my_return = ctx.take_return_value().unwrap_or(RuntimeValue::Undef);
                            ctx.restore_return_value(caller_return);
                            saved_match.restore(ctx);
                            return Ok(my_return);
                        }
                    }
                }
                if !dispatched_acode {
                    ctx.trace_decision(
                        "rust_runtime:generated_plan:acode_dispatch",
                        false,
                        format!("rule={label} regex_idx={} child=none", m.index),
                        TraceLevel::MEDIUM,
                    );
                }

                if let Some(ref lecode) = rule.lecode {
                    self.engine
                        .execute_lifecycle_block("LE", lecode, ctx, label)?;
                    return_if_rule_returned!();
                }

                if is_rep_and_acode_seq {
                    and_acode_idx += 1;
                    if and_acode_idx < and_acode_seq_len {
                        continue;
                    }
                    and_acode_idx = 0;
                }
                matches += 1;

                if let Some(ref itcode) = rule.itcode {
                    self.engine
                        .execute_lifecycle_block("IT", itcode, ctx, label)?;
                    return_if_rule_returned!();
                }
            } else {
                if let Some(ref lxcode) = rule.lxcode {
                    self.engine
                        .execute_lifecycle_block("LX", lxcode, ctx, label)?;
                    return_if_rule_returned!();
                }
                break;
            }

            if let Some(max) = rep_max
                && matches >= max
            {
                break;
            }

            let progress_start = if is_rep_and_acode_seq {
                rep_and_start_pos
            } else {
                pos_before
            };
            if is_rep && ctx.pos == progress_start {
                break;
            }
        }

        if is_rep && matches < rep_min {
            return Err(format!(
                "rule '{}': expected at least {} matches, got {}",
                label, rep_min, matches
            ));
        }

        if !is_rep && is_and_acode_seq && matches < and_acode_seq_len {
            ctx.restore_return_value(caller_return);
            saved_match.restore(ctx);
            return Ok(RuntimeValue::Undef);
        }

        if let Some(ref excode) = rule.excode {
            self.engine
                .execute_lifecycle_block("EX", excode, ctx, label)?;
            return_if_rule_returned!();
        }

        if let Some(ref ecode) = rule.ecode {
            self.engine
                .execute_lifecycle_block("E", ecode, ctx, label)?;
            return_if_rule_returned!();
        }

        let my_return = ctx.take_return_value().unwrap_or(RuntimeValue::Undef);
        ctx.restore_return_value(caller_return);
        saved_match.restore(ctx);
        Ok(my_return)
    }

    fn execute_direct_bcode_rule(
        &self,
        label: &str,
        entry_regex_idx: usize,
        family: GeneratedRuleFamily,
        ctx: &mut RuntimeContext,
    ) -> Result<RuntimeValue, String> {
        let entry_pos = ctx.pos;
        if !ctx.enter_recursion(label, entry_pos) {
            ctx.trace_decision(
                "rust_runtime:generated_plan:recursion_guard",
                false,
                format!("label={label} entry_regex_idx={entry_regex_idx} pos={entry_pos}"),
                TraceLevel::MEDIUM,
            );
            return Ok(RuntimeValue::Undef);
        }

        ctx.enter_rule_variable_scope();
        ctx.trace_enter(
            "rust_runtime:generated_plan:direct_bcode_rule",
            format!(
                "label={label} entry_regex_idx={entry_regex_idx} family={family:?} pos={entry_pos}"
            ),
            TraceLevel::MEDIUM,
        );
        let result = self.execute_direct_bcode_rule_inner(label, entry_regex_idx, family, ctx);
        let status = match &result {
            Ok(value) => format!("status=ok value_kind={}", runtime_value_trace_kind(value)),
            Err(err) => format!("status=error error={err}"),
        };
        ctx.trace_exit(
            "rust_runtime:generated_plan:direct_bcode_rule",
            format!("{status} label={label} pos={}", ctx.pos),
            TraceLevel::MEDIUM,
        );
        ctx.exit_rule_variable_scope();
        ctx.exit_recursion(label, entry_pos);
        result
    }

    fn execute_direct_bcode_rule_inner(
        &self,
        label: &str,
        entry_regex_idx: usize,
        family: GeneratedRuleFamily,
        ctx: &mut RuntimeContext,
    ) -> Result<RuntimeValue, String> {
        let rule = self.engine.spec.find(label).ok_or_else(|| {
            format!(
                "rule '{}' (entry idx {}) not found in compiled spec",
                label, entry_regex_idx
            )
        })?;

        let caller_return = ctx.take_return_value();
        let saved_match = SavedMatchState {
            entry_groups: std::mem::take(&mut ctx.entry_groups),
            entry_named: std::mem::take(&mut ctx.entry_named),
            entry_match_present: ctx.entry_match_present,
            match_groups: std::mem::take(&mut ctx.match_groups),
            match_named: std::mem::take(&mut ctx.match_named),
            match_present: ctx.match_present,
            entry_start_byte: ctx.entry_start_byte,
            entry_end_byte: ctx.entry_end_byte,
            match_start_byte: ctx.match_start_byte,
            match_end_byte: ctx.match_end_byte,
            capture_start: ctx.capture_start,
        };
        ctx.entry_groups = saved_match.match_groups.clone();
        ctx.entry_named = saved_match.match_named.clone();
        ctx.entry_match_present = saved_match.match_present;
        ctx.entry_start_byte = saved_match.match_start_byte;
        ctx.entry_end_byte = saved_match.match_end_byte;
        ctx.match_start_byte = 0;
        ctx.match_end_byte = 0;
        ctx.match_present = false;
        ctx.capture_start = Some(ctx.entry_end_byte);

        macro_rules! return_if_rule_returned {
            () => {
                if let Some(my_return) = ctx.take_return_value() {
                    ctx.restore_return_value(caller_return);
                    saved_match.restore(ctx);
                    return Ok(my_return);
                }
            };
        }

        if let Some(ref preamble) = rule.preamble {
            self.engine
                .execute_lifecycle_block("I", preamble, ctx, label)?;
            return_if_rule_returned!();
        }

        if !rule.acode_dispatch.is_empty() {
            ctx.restore_return_value(caller_return);
            saved_match.restore(ctx);
            return Err(format!(
                "generated direct bcode executor received acode rule '{label}'"
            ));
        }
        if rule.bcode_dispatch.is_empty() {
            ctx.restore_return_value(caller_return);
            saved_match.restore(ctx);
            return Err(format!(
                "generated direct bcode executor received rule '{label}' without bcode dispatch"
            ));
        }

        match family {
            GeneratedRuleFamily::RepBcode | GeneratedRuleFamily::RepAndBcode => {
                let rep_min = rule.rep_min.unwrap_or(0);
                let rep_max = rule.rep_max;
                let mut matches = 0usize;

                for _iter in 0..LINKEDSPEC_WHILE_ITERATION_LIMIT {
                    if let Some(max) = rep_max
                        && matches >= max
                    {
                        break;
                    }

                    let pos_before = ctx.pos;

                    if let Some(ref lscode) = rule.lscode {
                        self.engine
                            .execute_lifecycle_block("LS", lscode, ctx, label)?;
                        return_if_rule_returned!();
                    }

                    let matched = if matches!(family, GeneratedRuleFamily::RepAndBcode) {
                        let mut completed_sequence = true;
                        for entry in &rule.bcode_dispatch {
                            let child_retv = self.execute_child_rule(&entry.child_label, 0, ctx)?;
                            let child_matched = child_retv.as_bool();
                            ctx.trace_decision(
                                "rust_runtime:generated_plan:bcode_dispatch",
                                child_matched,
                                format!(
                                    "rule={label} child={} family={family:?} mode=rep_and value_kind={}",
                                    entry.child_label,
                                    runtime_value_trace_kind(&child_retv)
                                ),
                                TraceLevel::MEDIUM,
                            );
                            ctx.set_retv(child_retv);
                            self.engine.execute_bcode_entry_tail(entry, ctx, label)?;
                            return_if_rule_returned!();
                            if !child_matched {
                                completed_sequence = false;
                                break;
                            }
                        }
                        completed_sequence
                    } else {
                        let mut matched_choice = false;
                        for entry in &rule.bcode_dispatch {
                            let child_retv = self.execute_child_rule(&entry.child_label, 0, ctx)?;
                            let child_matched = child_retv.as_bool();
                            ctx.trace_decision(
                                "rust_runtime:generated_plan:bcode_dispatch",
                                child_matched,
                                format!(
                                    "rule={label} child={} family={family:?} mode=rep_or value_kind={}",
                                    entry.child_label,
                                    runtime_value_trace_kind(&child_retv)
                                ),
                                TraceLevel::MEDIUM,
                            );
                            ctx.set_retv(child_retv);
                            self.engine.execute_bcode_entry_tail(entry, ctx, label)?;
                            return_if_rule_returned!();
                            if child_matched {
                                matched_choice = true;
                                break;
                            }
                        }
                        matched_choice
                    };

                    if !matched {
                        if let Some(ref lxcode) = rule.lxcode {
                            self.engine
                                .execute_lifecycle_block("LX", lxcode, ctx, label)?;
                            return_if_rule_returned!();
                        }
                        break;
                    }

                    if let Some(ref lecode) = rule.lecode {
                        self.engine
                            .execute_lifecycle_block("LE", lecode, ctx, label)?;
                        return_if_rule_returned!();
                    }

                    matches += 1;

                    if let Some(ref itcode) = rule.itcode {
                        self.engine
                            .execute_lifecycle_block("IT", itcode, ctx, label)?;
                        return_if_rule_returned!();
                    }

                    if ctx.pos == pos_before {
                        break;
                    }
                }

                if matches < rep_min {
                    return Err(format!(
                        "rule '{}': expected at least {} matches, got {}",
                        label, rep_min, matches
                    ));
                }

                if let Some(ref excode) = rule.excode {
                    self.engine
                        .execute_lifecycle_block("EX", excode, ctx, label)?;
                    return_if_rule_returned!();
                }
            }
            GeneratedRuleFamily::AndBcode => {
                for entry in &rule.bcode_dispatch {
                    let child_retv = self.execute_child_rule(&entry.child_label, 0, ctx)?;
                    ctx.trace_decision(
                        "rust_runtime:generated_plan:bcode_dispatch",
                        child_retv.as_bool(),
                        format!(
                            "rule={label} child={} family={family:?} mode=and value_kind={}",
                            entry.child_label,
                            runtime_value_trace_kind(&child_retv)
                        ),
                        TraceLevel::MEDIUM,
                    );
                    ctx.set_retv(child_retv);
                    self.engine.execute_bcode_entry_tail(entry, ctx, label)?;
                    return_if_rule_returned!();
                }
            }
            GeneratedRuleFamily::OrBcode => {
                let mut matched = false;
                for entry in &rule.bcode_dispatch {
                    let child_retv = self.execute_child_rule(&entry.child_label, 0, ctx)?;
                    let child_matched = child_retv.as_bool();
                    ctx.trace_decision(
                        "rust_runtime:generated_plan:bcode_dispatch",
                        child_matched,
                        format!(
                            "rule={label} child={} family={family:?} mode=or value_kind={}",
                            entry.child_label,
                            runtime_value_trace_kind(&child_retv)
                        ),
                        TraceLevel::MEDIUM,
                    );
                    ctx.set_retv(child_retv);
                    self.engine.execute_bcode_entry_tail(entry, ctx, label)?;
                    return_if_rule_returned!();
                    if child_matched {
                        matched = true;
                        break;
                    }
                }
                if !matched && let Some(ref lxcode) = rule.lxcode {
                    self.engine
                        .execute_lifecycle_block("LX", lxcode, ctx, label)?;
                    return_if_rule_returned!();
                }
            }
            _ => {
                ctx.restore_return_value(caller_return);
                saved_match.restore(ctx);
                return Err(format!(
                    "generated direct bcode executor received non-bcode family {:?} for '{label}'",
                    family
                ));
            }
        }

        if let Some(ref ecode) = rule.ecode {
            self.engine
                .execute_lifecycle_block("E", ecode, ctx, label)?;
            return_if_rule_returned!();
        }

        let my_return = ctx.take_return_value().unwrap_or(RuntimeValue::Undef);
        ctx.restore_return_value(caller_return);
        saved_match.restore(ctx);
        Ok(my_return)
    }
}

impl Engine {
    /// Create a new engine from a compiled spec.
    pub fn new(spec: CompiledSpec) -> Self {
        Self { spec }
    }

    /// Execute the top rule against the given input.
    /// Returns the accumulator as a JSON array.
    pub fn execute(&self, input: &str) -> Result<Value, String> {
        let mut ctx = RuntimeContext::new(input);
        self.execute_with_context(&mut ctx)
    }

    /// Execute an optionally selected entry rule and return that rule's value
    /// directly as JSON.
    ///
    /// Unlike the legacy [`execute`](Self::execute) API, this does not wrap the
    /// result in the engine accumulator. It matches LinkedSpec's public parser
    /// contract and is suitable for native embedding and primary CLI adapters.
    pub fn execute_value(&self, input: &str, options: &ExecutionOptions) -> Result<Value, String> {
        let mut ctx = RuntimeContext::with_parse_mode(input, options.parse_mode());
        self.execute_value_with_context(&mut ctx, options)
    }

    /// Execute a direct rule value with explicit native trace configuration.
    pub fn execute_value_with_trace(
        &self,
        input: &str,
        options: &ExecutionOptions,
        trace_config: TraceConfig,
    ) -> Result<Value, String> {
        let mut trace =
            TraceEmitter::new(trace_config).map_err(|err| format!("trace setup failed: {err}"))?;
        self.execute_value_with_trace_emitter(input, options, &mut trace)
    }

    /// Execute a direct rule value with a caller-owned native trace emitter.
    pub fn execute_value_with_trace_emitter(
        &self,
        input: &str,
        options: &ExecutionOptions,
        trace: &mut TraceEmitter,
    ) -> Result<Value, String> {
        let scope = trace
            .enter_scope(
                "rust_runtime:engine:execute_value",
                format!(
                    "input_bytes={} input_chars={} entry_rule={} parse_mode={}",
                    input.len(),
                    input.chars().count(),
                    options.entry_rule().unwrap_or("<default>"),
                    match options.parse_mode() {
                        Some(ParseMode::Seek) => "seek",
                        Some(ParseMode::Consume) => "consume",
                        None => "<compiled>",
                    }
                ),
                TraceLevel::LOW,
            )
            .map_err(trace_write_failed)?;
        let mut ctx = RuntimeContext::with_parse_mode(input, options.parse_mode());
        if trace.should_emit(TraceLevel::LOW) {
            ctx.enable_trace_events();
        }
        let result = self.execute_value_with_context(&mut ctx, options);
        ctx.replay_trace_events(trace).map_err(trace_write_failed)?;
        let exit_details = match &result {
            Ok(value) => format!("status=ok output={value}"),
            Err(err) => format!("status=error error={err}"),
        };
        trace
            .exit_scope(scope, exit_details)
            .map_err(trace_write_failed)?;
        result
    }

    /// Execute the top rule with explicit trace configuration.
    pub fn execute_with_trace(
        &self,
        input: &str,
        trace_config: TraceConfig,
    ) -> Result<Value, String> {
        let mut trace =
            TraceEmitter::new(trace_config).map_err(|err| format!("trace setup failed: {err}"))?;
        self.execute_with_trace_emitter(input, &mut trace)
    }

    /// Execute the top rule with a caller-owned trace emitter.
    pub fn execute_with_trace_emitter(
        &self,
        input: &str,
        trace: &mut TraceEmitter,
    ) -> Result<Value, String> {
        let scope = trace
            .enter_scope(
                "rust_runtime:engine:execute",
                format!(
                    "input_bytes={} input_chars={}",
                    input.len(),
                    input.chars().count()
                ),
                TraceLevel::LOW,
            )
            .map_err(trace_write_failed)?;
        let mut ctx = RuntimeContext::new(input);
        if trace.should_emit(TraceLevel::LOW) {
            ctx.enable_trace_events();
        }
        let result = self.execute_with_context(&mut ctx);
        ctx.replay_trace_events(trace).map_err(trace_write_failed)?;
        let exit_details = match &result {
            Ok(value) => format!("status=ok output={}", value),
            Err(err) => format!("status=error error={err}"),
        };
        trace
            .exit_scope(scope, exit_details)
            .map_err(trace_write_failed)?;
        result
    }

    /// Execute generated source through a validated rule-family plan.
    ///
    /// This path is separate from [`execute`](Self::execute): generated modules
    /// call it after `source_emitter` validates the static family table emitted
    /// beside the serialized `CompiledSpec`. `RUST-PARITY.8.4` routes both
    /// non-REP families and explicit REP subfamilies directly through the
    /// generated-plan executor.
    pub fn execute_generated_with_plan(
        &self,
        generated_rules: &[GeneratedRuleSpec],
        input: &str,
    ) -> Result<Value, String> {
        let mut ctx = RuntimeContext::new(input);
        self.execute_generated_with_plan_context(generated_rules, &mut ctx)
    }

    /// Execute generated source through a validated rule-family plan with
    /// explicit trace configuration.
    pub fn execute_generated_with_plan_with_trace(
        &self,
        generated_rules: &[GeneratedRuleSpec],
        input: &str,
        trace_config: TraceConfig,
    ) -> Result<Value, String> {
        let mut trace =
            TraceEmitter::new(trace_config).map_err(|err| format!("trace setup failed: {err}"))?;
        self.execute_generated_with_plan_with_trace_emitter(generated_rules, input, &mut trace)
    }

    /// Execute generated source with a caller-owned trace emitter.
    pub fn execute_generated_with_plan_with_trace_emitter(
        &self,
        generated_rules: &[GeneratedRuleSpec],
        input: &str,
        trace: &mut TraceEmitter,
    ) -> Result<Value, String> {
        let scope = trace
            .enter_scope(
                "rust_runtime:generated_plan:execute",
                format!(
                    "input_bytes={} input_chars={} plan_rules={}",
                    input.len(),
                    input.chars().count(),
                    generated_rules.len()
                ),
                TraceLevel::LOW,
            )
            .map_err(trace_write_failed)?;
        let mut ctx = RuntimeContext::new(input);
        if trace.should_emit(TraceLevel::LOW) {
            ctx.enable_trace_events();
        }
        let result = self.execute_generated_with_plan_context(generated_rules, &mut ctx);
        ctx.replay_trace_events(trace).map_err(trace_write_failed)?;
        let exit_details = match &result {
            Ok(value) => format!("status=ok output={}", value),
            Err(err) => format!("status=error error={err}"),
        };
        trace
            .exit_scope(scope, exit_details)
            .map_err(trace_write_failed)?;
        result
    }

    fn execute_with_context(&self, ctx: &mut RuntimeContext) -> Result<Value, String> {
        let top = self.spec.top_rule().ok_or("no top rule in compiled spec")?;
        let label = top.label.clone();
        ctx.trace_decision(
            "rust_runtime:engine:top_rule",
            true,
            format!("label={label} input_bytes={}", ctx.input.len()),
            TraceLevel::LOW,
        );
        self.execute_rule(&label, 0, ctx)?;
        Ok(RuntimeValue::Array(ctx.accumulator.clone()).to_json())
    }

    fn execute_value_with_context(
        &self,
        ctx: &mut RuntimeContext,
        options: &ExecutionOptions,
    ) -> Result<Value, String> {
        let label = if let Some(label) = options.entry_rule() {
            self.spec
                .find(label)
                .ok_or_else(|| format!("entry rule '{label}' is not defined"))?;
            label.to_string()
        } else {
            self.spec
                .top_rule()
                .ok_or("no top rule in compiled spec")?
                .label
                .clone()
        };
        ctx.trace_decision(
            "rust_runtime:engine:entry_rule",
            true,
            format!(
                "label={label} input_bytes={} parse_mode={}",
                ctx.input.len(),
                match options.parse_mode() {
                    Some(ParseMode::Seek) => "seek",
                    Some(ParseMode::Consume) => "consume",
                    None => "compiled",
                }
            ),
            TraceLevel::LOW,
        );
        self.execute_rule(&label, 0, ctx)
            .map(|value| value.to_json())
    }

    fn execute_generated_with_plan_context(
        &self,
        generated_rules: &[GeneratedRuleSpec],
        ctx: &mut RuntimeContext,
    ) -> Result<Value, String> {
        let top = self.spec.top_rule().ok_or("no top rule in compiled spec")?;
        let label = top.label.clone();
        ctx.trace_decision(
            "rust_runtime:generated_plan:top_rule",
            true,
            format!(
                "label={label} input_bytes={} plan_rules={}",
                ctx.input.len(),
                generated_rules.len()
            ),
            TraceLevel::LOW,
        );
        let generated = GeneratedPlanExecutor {
            engine: self,
            generated_rules,
        };
        generated.execute_rule(&label, 0, ctx)?;
        Ok(RuntimeValue::Array(ctx.accumulator.clone()).to_json())
    }

    /// Execute a specific rule by label, entering at the given regex index
    /// (0 = first regex, N = Nth regex for `-> rule[N]` multi-entrypoint).
    ///
    /// This is the single re-entry seam for every cross-rule call, action edge,
    /// blind-call edge, and `call(rule)` helper — the Rust analogue of the Perl
    /// reference's `SpecEntry::_build_runtime_handler` closure. It wraps the rule
    /// body with the **forward-progress / consume-before-recurse termination
    /// guard** (TOP-RULE-AS-NORMAL.3.1, ADR 0010; mirror of the Perl `.2.1`
    /// `(rule,pos)` cutoff): a rule re-entered at an input position already active
    /// on its own recursion stack consumed no input since that enclosing entry —
    /// a non-progressing cycle that would otherwise overflow the native stack — so
    /// the branch is cut by returning `undef`. Legitimate consume-before-recurse
    /// recursion advances `ctx.pos` first, so the cutoff never fires for a
    /// terminating grammar.
    fn execute_rule(
        &self,
        label: &str,
        entry_regex_idx: usize,
        ctx: &mut RuntimeContext,
    ) -> Result<RuntimeValue, String> {
        let entry_pos = ctx.pos;
        ctx.trace_enter(
            "rust_runtime:engine:rule",
            format!("label={label} entry_regex_idx={entry_regex_idx} pos={entry_pos}"),
            TraceLevel::LOW,
        );
        if !ctx.enter_recursion(label, entry_pos) {
            // Non-progressing recursive re-entry at this exact position: cut the
            // cycle so it terminates instead of recursing forever.
            ctx.trace_decision(
                "rust_runtime:engine:recursion_guard",
                false,
                format!("label={label} entry_regex_idx={entry_regex_idx} pos={entry_pos}"),
                TraceLevel::MEDIUM,
            );
            ctx.trace_exit(
                "rust_runtime:engine:rule",
                format!("status=cut label={label} pos={}", ctx.pos),
                TraceLevel::LOW,
            );
            return Ok(RuntimeValue::Undef);
        }
        // Run the body, then leave the frame on BOTH the Ok and Err paths so the
        // active set stays balanced (empty between top-level parses).
        ctx.enter_rule_variable_scope();
        let result = self.execute_rule_inner(label, entry_regex_idx, ctx);
        ctx.exit_rule_variable_scope();
        ctx.exit_recursion(label, entry_pos);
        let status = match &result {
            Ok(value) => format!("status=ok value_kind={}", runtime_value_trace_kind(value)),
            Err(err) => format!("status=error error={err}"),
        };
        ctx.trace_exit(
            "rust_runtime:engine:rule",
            format!("{status} label={label} pos={}", ctx.pos),
            TraceLevel::LOW,
        );
        result
    }

    fn execute_child_rule(
        &self,
        label: &str,
        entry_regex_idx: usize,
        ctx: &mut RuntimeContext,
    ) -> Result<RuntimeValue, String> {
        let accumulator_len = ctx.accumulator.len();
        ctx.trace_decision(
            "rust_runtime:engine:child_dispatch",
            true,
            format!(
                "label={label} entry_regex_idx={entry_regex_idx} pos={} accumulator_len={accumulator_len}",
                ctx.pos
            ),
            TraceLevel::MEDIUM,
        );
        let child_result = self.execute_rule(label, entry_regex_idx, ctx);
        ctx.accumulator.truncate(accumulator_len);
        match &child_result {
            Ok(value) => {
                ctx.trace_decision(
                    "rust_runtime:engine:child_dispatch_result",
                    value.as_bool(),
                    format!(
                        "label={label} value_kind={}",
                        runtime_value_trace_kind(value)
                    ),
                    TraceLevel::MEDIUM,
                );
            }
            Err(err) => {
                ctx.trace_decision(
                    "rust_runtime:engine:child_dispatch_result",
                    false,
                    format!("label={label} error={err}"),
                    TraceLevel::MEDIUM,
                );
            }
        }
        child_result
    }

    fn execute_action_edge_child_rule(
        &self,
        label: &str,
        entry_regex_idx: usize,
        ctx: &mut RuntimeContext,
    ) -> Result<RuntimeValue, String> {
        if self.is_passive_terminal_rule(label) {
            ctx.trace_decision(
                "rust_runtime:engine:passive_terminal_dispatch",
                false,
                format!(
                    "label={label} entry_regex_idx={entry_regex_idx} pos={}",
                    ctx.pos
                ),
                TraceLevel::MEDIUM,
            );
            return Ok(RuntimeValue::Undef);
        }
        self.execute_child_rule(label, entry_regex_idx, ctx)
    }

    /// A passive terminal handler has no executable body in the Perl reference:
    /// the parent edge regex has already consumed its match, and calling the
    /// child only exposes that entry match before returning undef.
    fn is_passive_terminal_rule(&self, label: &str) -> bool {
        let Some(rule) = self.spec.find(label) else {
            return false;
        };
        rule.preamble.is_none()
            && rule.lxcode.is_none()
            && rule.lscode.is_none()
            && rule.lecode.is_none()
            && rule.ecode.is_none()
            && rule.excode.is_none()
            && rule.itcode.is_none()
            && rule.acode_dispatch.is_empty()
            && rule.bcode_dispatch.is_empty()
    }

    fn execute_bcode_entry_tail(
        &self,
        entry: &BcodeEntry,
        ctx: &mut RuntimeContext,
        label: &str,
    ) -> Result<(), String> {
        if let Some(ref block) = entry.code {
            self.execute_block(block, ctx, label)?;
        }

        for (method, args_str) in &entry.fluent_chain {
            let args_val: Vec<RuntimeValue> = if args_str.is_empty() {
                vec![]
            } else {
                vec![RuntimeValue::Scalar(args_str.clone())]
            };
            let empty_raw: &[linkedspec_core::expr::Arg] = &[];
            self.call_helper(method, empty_raw, &args_val, ctx, label)?;
        }

        Ok(())
    }

    /// The rule body, wrapped by [`execute_rule`] (which adds the recursion
    /// termination guard). All recursive dispatch goes through `execute_rule`,
    /// never directly through this method.
    fn execute_rule_inner(
        &self,
        label: &str,
        entry_regex_idx: usize,
        ctx: &mut RuntimeContext,
    ) -> Result<RuntimeValue, String> {
        let rule = self.spec.find(label).ok_or_else(|| {
            format!(
                "rule '{}' (entry idx {}) not found in compiled spec",
                label, entry_regex_idx
            )
        })?;

        // Each rule invocation reports its own return value (the value of the
        // last `return(...)` in its blocks — Runtime Semantics §5.4). Save the
        // caller's pending return, then start this invocation with a clean
        // channel so a dispatched child cannot leak its return into ours.
        let caller_return = ctx.take_return_value();

        // ── Emulate the Perl per-handler IMATCH/LMATCH lexicals ──
        // The dispatcher passes its own local match as the child's `$info`
        // (`MethodLowering.pm:332` calls the child handler with `$minfo`), and
        // the child's preamble sets `IMATCH = $$info{match}`
        // (`SpecEntry::_build_handler_preamble`). The rule's own regex match
        // sets `LMATCH` (`HandlerVariantEmitter::_build_lmatch_extraction`). So
        // this invocation's ENTRY match is the dispatcher's current LOCAL match,
        // and the rule's own matches only update the LOCAL match. Save the
        // caller's lexicals and restore them on exit so a child's matching never
        // mutates the parent's entry/local match.
        let saved_match = SavedMatchState {
            entry_groups: std::mem::take(&mut ctx.entry_groups),
            entry_named: std::mem::take(&mut ctx.entry_named),
            entry_match_present: ctx.entry_match_present,
            match_groups: std::mem::take(&mut ctx.match_groups),
            match_named: std::mem::take(&mut ctx.match_named),
            match_present: ctx.match_present,
            entry_start_byte: ctx.entry_start_byte,
            entry_end_byte: ctx.entry_end_byte,
            match_start_byte: ctx.match_start_byte,
            match_end_byte: ctx.match_end_byte,
            capture_start: ctx.capture_start,
        };
        // ENTRY match (`IMATCH`) = the dispatcher's local match (`$$info{match}`).
        // For the top rule the caller has no local match, so this starts empty
        // and is seeded from the rule's own first match below (mirroring the
        // framework passing the top rule's own match as `$info`).
        ctx.entry_groups = saved_match.match_groups.clone();
        ctx.entry_named = saved_match.match_named.clone();
        ctx.entry_match_present = saved_match.match_present;
        ctx.entry_start_byte = saved_match.match_start_byte;
        ctx.entry_end_byte = saved_match.match_end_byte;
        // LOCAL match (`LMATCH`) starts empty until this rule matches its regex.
        ctx.match_start_byte = 0;
        ctx.match_end_byte = 0;
        ctx.match_present = false;
        ctx.capture_start = Some(ctx.entry_end_byte);

        macro_rules! return_if_rule_returned {
            () => {
                if let Some(my_return) = ctx.take_return_value() {
                    ctx.restore_return_value(caller_return);
                    saved_match.restore(ctx);
                    return Ok(my_return);
                }
            };
        }

        // Build regex alternation (or fallback for edge-only rules)
        let alt = if rule.regex_patterns.is_empty() {
            CompiledAlternation::compile(&[])?
        } else {
            CompiledAlternation::compile(&rule.regex_patterns)?
        };

        // ── I-block (preamble, once per rule entry) ──
        if let Some(ref preamble) = rule.preamble {
            self.execute_lifecycle_block("I", preamble, ctx, label)?;
            return_if_rule_returned!();
        }

        let is_rep = rule.rep_min.is_some();
        let rep_min = rule.rep_min.unwrap_or(0);
        let rep_max = rule.rep_max;

        // ── Blind-call dispatch ──
        if !rule.bcode_dispatch.is_empty() {
            if is_rep {
                let mut matches = 0usize;
                for _iter in 0..LINKEDSPEC_WHILE_ITERATION_LIMIT {
                    if let Some(max) = rep_max
                        && matches >= max
                    {
                        break;
                    }

                    let pos_before = ctx.pos;

                    if let Some(ref lscode) = rule.lscode {
                        self.execute_lifecycle_block("LS", lscode, ctx, label)?;
                        return_if_rule_returned!();
                    }

                    let matched = if rule.mode.is_and() {
                        let mut completed_sequence = true;
                        for entry in &rule.bcode_dispatch {
                            let child_retv = self.execute_child_rule(&entry.child_label, 0, ctx)?;
                            let child_matched = child_retv.as_bool();
                            ctx.trace_decision(
                                "rust_runtime:engine:bcode_dispatch",
                                child_matched,
                                format!(
                                    "rule={label} child={} mode=rep_and value_kind={}",
                                    entry.child_label,
                                    runtime_value_trace_kind(&child_retv)
                                ),
                                TraceLevel::MEDIUM,
                            );
                            ctx.set_retv(child_retv);
                            self.execute_bcode_entry_tail(entry, ctx, label)?;
                            return_if_rule_returned!();
                            if !child_matched {
                                completed_sequence = false;
                                break;
                            }
                        }
                        completed_sequence
                    } else {
                        let mut matched_choice = false;
                        for entry in &rule.bcode_dispatch {
                            let child_retv = self.execute_child_rule(&entry.child_label, 0, ctx)?;
                            let child_matched = child_retv.as_bool();
                            ctx.trace_decision(
                                "rust_runtime:engine:bcode_dispatch",
                                child_matched,
                                format!(
                                    "rule={label} child={} mode=rep_or value_kind={}",
                                    entry.child_label,
                                    runtime_value_trace_kind(&child_retv)
                                ),
                                TraceLevel::MEDIUM,
                            );
                            ctx.set_retv(child_retv);
                            self.execute_bcode_entry_tail(entry, ctx, label)?;
                            return_if_rule_returned!();
                            if child_matched {
                                matched_choice = true;
                                break;
                            }
                        }
                        matched_choice
                    };

                    if !matched {
                        if let Some(ref lxcode) = rule.lxcode {
                            self.execute_lifecycle_block("LX", lxcode, ctx, label)?;
                            return_if_rule_returned!();
                        }
                        break;
                    }

                    if let Some(ref lecode) = rule.lecode {
                        self.execute_lifecycle_block("LE", lecode, ctx, label)?;
                        return_if_rule_returned!();
                    }

                    matches += 1;

                    if let Some(ref itcode) = rule.itcode {
                        self.execute_lifecycle_block("IT", itcode, ctx, label)?;
                        return_if_rule_returned!();
                    }

                    if ctx.pos == pos_before {
                        break;
                    }
                }

                if matches < rep_min {
                    return Err(format!(
                        "rule '{}': expected at least {} matches, got {}",
                        label, rep_min, matches
                    ));
                }

                if let Some(ref excode) = rule.excode {
                    self.execute_lifecycle_block("EX", excode, ctx, label)?;
                    return_if_rule_returned!();
                }
            } else if !matches!(rule.mode, RuleMode::Or) {
                for entry in &rule.bcode_dispatch {
                    // Execute child rule; its return value becomes the parent's
                    // `retv` (Runtime Semantics §6.2), readable by the attached
                    // code, fluent chain, and the E-block below.
                    let child_retv = self.execute_child_rule(&entry.child_label, 0, ctx)?;
                    ctx.trace_decision(
                        "rust_runtime:engine:bcode_dispatch",
                        child_retv.as_bool(),
                        format!(
                            "rule={label} child={} mode=and value_kind={}",
                            entry.child_label,
                            runtime_value_trace_kind(&child_retv)
                        ),
                        TraceLevel::MEDIUM,
                    );
                    ctx.set_retv(child_retv);
                    self.execute_bcode_entry_tail(entry, ctx, label)?;
                    return_if_rule_returned!();
                }
            } else {
                let mut matched = false;
                for entry in &rule.bcode_dispatch {
                    let child_retv = self.execute_child_rule(&entry.child_label, 0, ctx)?;
                    let child_matched = child_retv.as_bool();
                    ctx.trace_decision(
                        "rust_runtime:engine:bcode_dispatch",
                        child_matched,
                        format!(
                            "rule={label} child={} mode=or value_kind={}",
                            entry.child_label,
                            runtime_value_trace_kind(&child_retv)
                        ),
                        TraceLevel::MEDIUM,
                    );
                    ctx.set_retv(child_retv);
                    self.execute_bcode_entry_tail(entry, ctx, label)?;
                    return_if_rule_returned!();
                    if child_matched {
                        matched = true;
                        break;
                    }
                }
                if !matched && let Some(ref lxcode) = rule.lxcode {
                    self.execute_lifecycle_block("LX", lxcode, ctx, label)?;
                    return_if_rule_returned!();
                }
            }
            // After blind-call dispatch, fire E-block and exit
            if let Some(ref ecode) = rule.ecode {
                self.execute_lifecycle_block("E", ecode, ctx, label)?;
                return_if_rule_returned!();
            }
            let my_return = ctx.take_return_value().unwrap_or(RuntimeValue::Undef);
            ctx.restore_return_value(caller_return);
            saved_match.restore(ctx);
            return Ok(my_return);
        }

        // ── Regex-based matching loop ──
        let is_rep_and_acode_seq = is_rep && rule.mode.is_and() && rule.regex_patterns.len() > 1;
        let is_and_acode_seq = (!is_rep && rule.mode.is_and() && rule.regex_patterns.len() > 1)
            || is_rep_and_acode_seq;
        let and_acode_seq_len = rule.regex_patterns.len();
        let mut matches: usize = 0;
        let mut and_acode_idx: usize = 0;
        let mut rep_and_start_pos = ctx.pos;
        let max_iter = 10_000;

        // For non-REP entry-specific dispatch: if entry_regex_idx > 0,
        // try only that specific regex first (for self-recursive rules).
        let has_entry_idx = entry_regex_idx > 0 && entry_regex_idx < rule.regex_patterns.len();

        for _iter in 0..max_iter {
            if is_rep_and_acode_seq && and_acode_idx == 0 {
                rep_and_start_pos = ctx.pos;
            }
            // Non-REP rules execute once
            if !is_rep && !is_and_acode_seq && matches > 0 {
                break;
            }
            if !is_rep && is_and_acode_seq && matches >= and_acode_seq_len {
                break;
            }
            if is_rep_and_acode_seq
                && let Some(max) = rep_max
                && matches >= max
            {
                break;
            }

            // Cursor position at the start of this iteration — the zero-progress
            // guard below compares it against the position after the iteration
            // (Perl: `loop_start_pos`).
            let pos_before = ctx.pos;

            // ── LS-block (loop start, fires before each match attempt) ──
            if let Some(ref lscode) = rule.lscode {
                self.execute_lifecycle_block("LS", lscode, ctx, label)?;
                return_if_rule_returned!();
            }

            // ── Match ──
            let parse_mode = ctx.effective_parse_mode(rule.parse_mode);
            let match_result = if has_entry_idx && matches == 0 {
                // Self-recursive entry: only try the specified regex slot.
                // Build a single-pattern alternation for this slot.
                let entry_pat = &rule.regex_patterns[entry_regex_idx];
                let entry_alt = CompiledAlternation::compile(std::slice::from_ref(entry_pat))?;
                match parse_mode {
                    ParseMode::Consume => entry_alt.consume_match(&ctx.input, ctx.pos),
                    ParseMode::Seek => entry_alt.seek_match(&ctx.input, ctx.pos),
                }
                .map(|mut m| {
                    // Fix up the index to match the real regex position
                    m.index = entry_regex_idx;
                    m
                })
            } else {
                match parse_mode {
                    ParseMode::Consume => alt.consume_match(&ctx.input, ctx.pos),
                    ParseMode::Seek => alt.seek_match(&ctx.input, ctx.pos),
                }
            };

            match &match_result {
                Some(m) => {
                    ctx.trace_decision(
                        "rust_runtime:engine:regex_match",
                        true,
                        format!(
                            "rule={label} regex_idx={} start={} end={} pos_before={pos_before} parse_mode={:?} entry_regex_idx={entry_regex_idx}",
                            m.index, m.start, m.end, parse_mode
                        ),
                        TraceLevel::MEDIUM,
                    );
                }
                None => {
                    ctx.trace_decision(
                        "rust_runtime:engine:regex_match",
                        false,
                        format!(
                            "rule={label} pos_before={pos_before} parse_mode={:?} entry_regex_idx={entry_regex_idx}",
                            parse_mode
                        ),
                        TraceLevel::MEDIUM,
                    );
                }
            }

            if let Some(m) = match_result {
                let expected_and_idx = if is_rep_and_acode_seq {
                    and_acode_idx
                } else {
                    matches
                };
                if is_and_acode_seq && m.index != expected_and_idx {
                    ctx.trace_decision(
                        "rust_runtime:engine:and_sequence_slot",
                        false,
                        format!(
                            "rule={label} regex_idx={} expected_idx={expected_and_idx} matches={matches}",
                            m.index
                        ),
                        TraceLevel::MEDIUM,
                    );
                    if let Some(ref lxcode) = rule.lxcode {
                        self.execute_lifecycle_block("LX", lxcode, ctx, label)?;
                        return_if_rule_returned!();
                    }
                    break;
                }

                let entry_was_empty = !ctx.entry_match_present;
                ctx.set_pos(m.end);
                // LOCAL match (`LMATCH`) — the rule's own regex match. This is
                // what `match_*` helpers read; it must NOT touch the entry match
                // (Perl keeps `IMATCH` and `LMATCH` separate — only an explicit
                // I-block bridge copies one to the other). `m.start`/`m.end` are
                // byte offsets (exposed as char offsets by `match_*_pos`).
                ctx.match_groups = m.captures.clone();
                ctx.match_named = m.named.clone();
                ctx.match_start_byte = m.start;
                ctx.match_end_byte = m.end;
                ctx.match_present = true;
                // Top-rule / dispatcher-less entry: the rule's own first match
                // is also its entry match (the framework passes the top rule's
                // own match as `$info`). A dispatched child already carries a
                // non-empty entry match (the dispatcher's local match) and is
                // left untouched, so `entry_*` and `match_*` diverge correctly
                // in nested contexts.
                if entry_was_empty {
                    ctx.entry_groups = m.captures.clone();
                    ctx.entry_named = m.named.clone();
                    ctx.entry_start_byte = m.start;
                    ctx.entry_end_byte = m.end;
                    ctx.entry_match_present = true;
                }

                // ── Action-edge dispatch ──
                let mut dispatched_acode = false;
                for entry in &rule.acode_dispatch {
                    if entry.regex_idx == m.index {
                        dispatched_acode = true;
                        ctx.trace_decision(
                            "rust_runtime:engine:acode_dispatch",
                            true,
                            format!(
                                "rule={label} regex_idx={} child={} child_regex_idx={} fluent_chain_len={} has_code={}",
                                entry.regex_idx,
                                entry.child_label,
                                entry.child_regex_idx,
                                entry.fluent_chain.len(),
                                entry.code.is_some()
                            ),
                            TraceLevel::MEDIUM,
                        );
                        if entry.fluent_chain.is_empty() {
                            if let Some(ref block) = entry.code {
                                if Self::block_calls_rule(block, &entry.child_label)
                                    || Self::block_reads_retv(block)
                                {
                                    // Perl lowers `call(child)` inside the edge
                                    // block to the already matched edge child.
                                    // A bare `retv` read has the same dependency:
                                    // pre-dispatch once, then let helper
                                    // evaluation read the scoped child result.
                                    let child_retv = self.execute_action_edge_child_rule(
                                        &entry.child_label,
                                        entry.child_regex_idx,
                                        ctx,
                                    )?;
                                    ctx.push_action_edge_call_result(
                                        &entry.child_label,
                                        child_retv.clone(),
                                    );
                                    ctx.set_retv(child_retv.clone());
                                    let block_result = self.execute_block(block, ctx, label);
                                    ctx.pop_action_edge_call_result();
                                    block_result?;
                                    return_if_rule_returned!();
                                    ctx.set_retv(child_retv);
                                } else if entry.child_label == label {
                                    // A self-recursive code edge such as
                                    // `-> rule[1] { return(...) }` is usually a
                                    // close/finalizer branch. The matched regex
                                    // already selected that entry point; running
                                    // the same rule again would seek forward to a
                                    // later close marker and move the cursor
                                    // past the current construct before the
                                    // block can return.
                                    self.execute_block(block, ctx, label)?;
                                    return_if_rule_returned!();
                                } else {
                                    // Blocks that do not call the child run before
                                    // the generated Perl handler dispatches that
                                    // child. The child return then seeds `retv`
                                    // for later edges / lifecycle blocks.
                                    self.execute_block(block, ctx, label)?;
                                    return_if_rule_returned!();
                                    let child_retv = self.execute_action_edge_child_rule(
                                        &entry.child_label,
                                        entry.child_regex_idx,
                                        ctx,
                                    )?;
                                    ctx.set_retv(child_retv);
                                }
                            } else {
                                let child_retv = self.execute_action_edge_child_rule(
                                    &entry.child_label,
                                    entry.child_regex_idx,
                                    ctx,
                                )?;
                                ctx.set_retv(child_retv);
                            }
                        } else if self.execute_action_edge_fluent_chain(entry, ctx, label)?
                            == ActionEdgeFlow::Returned
                        {
                            let my_return = ctx.take_return_value().unwrap_or(RuntimeValue::Undef);
                            ctx.restore_return_value(caller_return);
                            saved_match.restore(ctx);
                            return Ok(my_return);
                        }
                    }
                }
                if !dispatched_acode {
                    ctx.trace_decision(
                        "rust_runtime:engine:acode_dispatch",
                        false,
                        format!("rule={label} regex_idx={} child=none", m.index),
                        TraceLevel::MEDIUM,
                    );
                }

                // ── LE-block (loop end, after successful match) ──
                if let Some(ref lecode) = rule.lecode {
                    self.execute_lifecycle_block("LE", lecode, ctx, label)?;
                    return_if_rule_returned!();
                }

                if is_rep_and_acode_seq {
                    and_acode_idx += 1;
                    if and_acode_idx < and_acode_seq_len {
                        continue;
                    }
                    and_acode_idx = 0;
                }
                matches += 1;

                // ── IT-block (per-iteration, REP only) ──
                if let Some(ref itcode) = rule.itcode {
                    self.execute_lifecycle_block("IT", itcode, ctx, label)?;
                    return_if_rule_returned!();
                }
            } else {
                // No match — exit the matching loop
                // ── LX-block (no-match exit, fires when loop ends without match) ──
                if let Some(ref lxcode) = rule.lxcode {
                    self.execute_lifecycle_block("LX", lxcode, ctx, label)?;
                    return_if_rule_returned!();
                }
                break;
            }

            // Check max bound (REP rules)
            if let Some(max) = rep_max
                && matches >= max
            {
                break;
            }

            // Zero-progress guard: a REP iteration that left the cursor
            // unchanged (e.g. a zero-width match with no consuming child
            // dispatch) would loop forever. Break when the iteration made no
            // progress (Perl: `loop_end_pos == loop_start_pos`); the min-bound
            // check below then fails the rule if we are still under `rep_min`.
            let progress_start = if is_rep_and_acode_seq {
                rep_and_start_pos
            } else {
                pos_before
            };
            if is_rep && ctx.pos == progress_start {
                break;
            }
        }

        // Check min bound for REP variants (not for non-REP with no matches)
        if is_rep && matches < rep_min {
            return Err(format!(
                "rule '{}': expected at least {} matches, got {}",
                label, rep_min, matches
            ));
        }

        if !is_rep && is_and_acode_seq && matches < and_acode_seq_len {
            ctx.restore_return_value(caller_return);
            saved_match.restore(ctx);
            return Ok(RuntimeValue::Undef);
        }

        // ── EX-block (REP exhaustion, fires after loop completes normally) ──
        if let Some(ref excode) = rule.excode {
            self.execute_lifecycle_block("EX", excode, ctx, label)?;
            return_if_rule_returned!();
        }

        // ── E-block (exit, fires once after all matching/repetition is done) ──
        if let Some(ref ecode) = rule.ecode {
            self.execute_lifecycle_block("E", ecode, ctx, label)?;
            return_if_rule_returned!();
        }

        // This invocation's return value is whatever its blocks last returned;
        // restore the caller's pending return and match lexicals so nested
        // dispatch is transparent to the parent.
        let my_return = ctx.take_return_value().unwrap_or(RuntimeValue::Undef);
        ctx.restore_return_value(caller_return);
        saved_match.restore(ctx);
        Ok(my_return)
    }

    fn block_calls_rule(block: &CodeBlock, rule_label: &str) -> bool {
        block
            .statements
            .iter()
            .any(|stmt| Self::expr_calls_rule(&stmt.expr, rule_label))
    }

    fn expr_calls_rule(expr: &Expr, rule_label: &str) -> bool {
        match expr {
            Expr::Call { name, args } => {
                (name == "call" && Self::call_names_rule(args, rule_label))
                    || args.iter().any(|arg| Self::arg_calls_rule(arg, rule_label))
            }
            Expr::AssignScalar { value, .. } => Self::expr_calls_rule(value, rule_label),
            Expr::AssignArrayAppend { value, .. } => Self::expr_calls_rule(value, rule_label),
            Expr::AssignHashIndex { key, value, .. } => {
                Self::expr_calls_rule(key, rule_label) || Self::expr_calls_rule(value, rule_label)
            }
            Expr::AssignNestedAccess {
                segments, value, ..
            } => {
                segments.iter().any(|segment| match segment {
                    AccessSegment::Key { .. } => false,
                    AccessSegment::Index { expr } => Self::expr_calls_rule(expr, rule_label),
                }) || Self::expr_calls_rule(value, rule_label)
            }
            Expr::IndexedVar { index, .. } => Self::expr_calls_rule(index, rule_label),
            Expr::NestedAccess { segments, .. } => segments.iter().any(|segment| match segment {
                AccessSegment::Key { .. } => false,
                AccessSegment::Index { expr } => Self::expr_calls_rule(expr, rule_label),
            }),
            Expr::ArrayLiteral { items } => items
                .iter()
                .any(|item| Self::expr_calls_rule(item, rule_label)),
            Expr::HashLiteral { entries } => entries.iter().any(|entry| {
                Self::expr_calls_rule(&entry.key, rule_label)
                    || Self::expr_calls_rule(&entry.value, rule_label)
            }),
            Expr::BlockValue { block } => Self::block_calls_rule(block, rule_label),
            Expr::FluentChain { receiver, calls } => {
                Self::expr_calls_rule(receiver, rule_label)
                    || calls.iter().any(|call| {
                        call.args
                            .iter()
                            .any(|arg| Self::arg_calls_rule(arg, rule_label))
                    })
            }
            Expr::Variable { .. }
            | Expr::StringLiteral { .. }
            | Expr::NumberLiteral { .. }
            | Expr::BooleanLiteral { .. }
            | Expr::RegexLiteral { .. }
            | Expr::Undef => false,
        }
    }

    fn block_reads_retv(block: &CodeBlock) -> bool {
        block
            .statements
            .iter()
            .any(|stmt| Self::expr_reads_retv(&stmt.expr))
    }

    fn expr_reads_retv(expr: &Expr) -> bool {
        match expr {
            Expr::Call { args, .. } => args.iter().any(Self::arg_reads_retv),
            Expr::AssignScalar { value, .. } => Self::expr_reads_retv(value),
            Expr::AssignArrayAppend { value, .. } => Self::expr_reads_retv(value),
            Expr::AssignHashIndex { key, value, .. } => {
                Self::expr_reads_retv(key) || Self::expr_reads_retv(value)
            }
            Expr::AssignNestedAccess {
                base,
                segments,
                value,
            } => {
                base == "retv"
                    || segments.iter().any(|segment| match segment {
                        AccessSegment::Key { .. } => false,
                        AccessSegment::Index { expr } => Self::expr_reads_retv(expr),
                    })
                    || Self::expr_reads_retv(value)
            }
            Expr::Variable { name } => name == "retv",
            Expr::IndexedVar { name, index } => name == "retv" || Self::expr_reads_retv(index),
            Expr::NestedAccess { base, segments } => {
                base == "retv"
                    || segments.iter().any(|segment| match segment {
                        AccessSegment::Key { .. } => false,
                        AccessSegment::Index { expr } => Self::expr_reads_retv(expr),
                    })
            }
            Expr::ArrayLiteral { items } => items.iter().any(Self::expr_reads_retv),
            Expr::HashLiteral { entries } => entries.iter().any(|entry| {
                Self::expr_reads_retv(&entry.key) || Self::expr_reads_retv(&entry.value)
            }),
            Expr::BlockValue { block } => Self::block_reads_retv(block),
            Expr::FluentChain { receiver, calls } => {
                Self::expr_reads_retv(receiver)
                    || calls
                        .iter()
                        .any(|call| call.args.iter().any(Self::arg_reads_retv))
            }
            Expr::StringLiteral { .. }
            | Expr::NumberLiteral { .. }
            | Expr::BooleanLiteral { .. }
            | Expr::RegexLiteral { .. }
            | Expr::Undef => false,
        }
    }

    fn arg_calls_rule(arg: &Arg, rule_label: &str) -> bool {
        Self::expr_calls_rule(arg.value(), rule_label)
    }

    fn arg_reads_retv(arg: &Arg) -> bool {
        Self::expr_reads_retv(arg.value())
    }

    fn call_names_rule(args: &[Arg], rule_label: &str) -> bool {
        match args.first().map(Arg::value) {
            Some(Expr::Variable { name }) | Some(Expr::StringLiteral { value: name }) => {
                name == rule_label
            }
            _ => false,
        }
    }

    fn execute_action_edge_fluent_chain(
        &self,
        entry: &linkedspec_core::types::AcodeEntry,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<ActionEdgeFlow, String> {
        let mut if_stack: Vec<StatementIfFrame> = Vec::new();
        let mut switch_stack: Vec<StatementSwitchFrame> = Vec::new();

        for (method, args) in &entry.fluent_chain {
            let call_args = Self::parse_action_edge_fluent_call_args(method, args)?;
            let call_expr = linkedspec_core::expr::Expr::Call {
                name: method.clone(),
                args: call_args.clone(),
            };
            let parent_active = Self::statement_controls_active(&if_stack, &switch_stack);
            if self.handle_statement_if_control(
                &call_expr,
                &mut if_stack,
                parent_active,
                ctx,
                rule_label,
            )? {
                continue;
            }
            if self.handle_statement_switch_control(
                &call_expr,
                &mut switch_stack,
                parent_active,
                ctx,
                rule_label,
            )? {
                continue;
            }

            if !Self::statement_controls_active(&if_stack, &switch_stack) {
                continue;
            }

            match method.as_str() {
                "push" => {
                    self.execute_action_edge_fluent_push(entry, &call_args, ctx, rule_label)?;
                }
                "return" => {
                    let value = self.eval_action_edge_fluent_return(args, ctx, rule_label)?;
                    if self.spec.find(rule_label).is_some_and(|rule| rule.is_top) {
                        ctx.push_accumulator(value.clone());
                    }
                    ctx.set_return_value(value);
                    return Ok(ActionEdgeFlow::Returned);
                }
                "return_undef" => {
                    ctx.set_return_value(RuntimeValue::Undef);
                    return Ok(ActionEdgeFlow::Returned);
                }
                other => {
                    self.eval_expr(&call_expr, ctx, rule_label).map_err(|err| {
                        format!("action-edge fluent method '.{other}' failed: {err}")
                    })?;
                }
            }
        }
        Ok(ActionEdgeFlow::Continue)
    }

    fn parse_action_edge_fluent_call_args(
        method: &str,
        args: &str,
    ) -> Result<Vec<linkedspec_core::expr::Arg>, String> {
        use linkedspec_core::expr::Expr;

        let code = if args.trim().is_empty() {
            format!("{method}()")
        } else {
            format!("{method}({args})")
        };
        let block = linkedspec_core::expr::CodeBlock::parse(&code)
            .map_err(|err| format!("failed to parse action-edge fluent call '.{method}': {err}"))?;
        let Some(stmt) = block.statements.first() else {
            return Ok(Vec::new());
        };
        match &stmt.expr {
            Expr::Call { name, args } if name == method => Ok(args.clone()),
            _ => Err(format!(
                "failed to parse action-edge fluent call '.{method}' from {code}"
            )),
        }
    }

    fn execute_action_edge_fluent_push(
        &self,
        entry: &linkedspec_core::types::AcodeEntry,
        args: &[linkedspec_core::expr::Arg],
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<(), String> {
        let (child_label, child_regex_idx, target_label) = match args.len() {
            0 => (
                entry.child_label.clone(),
                entry.child_regex_idx,
                rule_label.to_string(),
            ),
            1 => {
                let target_value = self.eval_expr(args[0].value(), ctx, rule_label)?;
                (
                    entry.child_label.clone(),
                    entry.child_regex_idx,
                    self.resolve_array_target(args, &target_value, true),
                )
            }
            _ => {
                let child_value = self.eval_expr(args[0].value(), ctx, rule_label)?;
                let child_label = self.resolve_rule_name(args, Some(&child_value));
                let target_value = self.eval_expr(args[1].value(), ctx, rule_label)?;
                let child_regex_idx = if child_label == entry.child_label {
                    entry.child_regex_idx
                } else {
                    0
                };
                (
                    child_label,
                    child_regex_idx,
                    self.resolve_array_target(&args[1..], &target_value, true),
                )
            }
        };

        let child_retv = self.execute_action_edge_child_rule(&child_label, child_regex_idx, ctx)?;
        ctx.set_retv(child_retv.clone());
        ctx.push_array_value(&target_label, child_retv);
        Ok(())
    }

    fn eval_action_edge_fluent_return(
        &self,
        args: &str,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        let code = if args.trim().is_empty() {
            "return()".to_string()
        } else {
            format!("return({args})")
        };
        let block = linkedspec_core::expr::CodeBlock::parse(&code)?;
        let Some(stmt) = block.statements.first() else {
            return Ok(RuntimeValue::Undef);
        };
        match Self::return_call_payload(&stmt.expr) {
            Some(Some(expr)) => self.eval_expr(expr, ctx, rule_label),
            Some(None) => Ok(RuntimeValue::Undef),
            None => Err(format!("failed to parse action-edge fluent return: {code}")),
        }
    }

    /// Execute a lifecycle code block (parsed expression tree).
    fn execute_lifecycle_block(
        &self,
        phase: &str,
        block: &linkedspec_core::expr::CodeBlock,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<(), String> {
        ctx.trace_decision(
            "rust_runtime:engine:lifecycle_block",
            true,
            format!("rule={rule_label} phase={phase} pos={}", ctx.pos),
            TraceLevel::MEDIUM,
        );
        let result = self.execute_block(block, ctx, rule_label);
        match &result {
            Ok(()) => {
                ctx.trace_decision(
                    "rust_runtime:engine:lifecycle_block_result",
                    true,
                    format!("rule={rule_label} phase={phase} pos={}", ctx.pos),
                    TraceLevel::MEDIUM,
                );
            }
            Err(err) => {
                ctx.trace_decision(
                    "rust_runtime:engine:lifecycle_block_result",
                    false,
                    format!("rule={rule_label} phase={phase} error={err}"),
                    TraceLevel::MEDIUM,
                );
            }
        }
        result
    }

    /// Execute a lifecycle code block (parsed expression tree).
    fn execute_block(
        &self,
        block: &linkedspec_core::expr::CodeBlock,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<(), String> {
        self.execute_block_statements(block, ctx, rule_label, true)?;
        Ok(())
    }

    fn execute_block_statements(
        &self,
        block: &linkedspec_core::expr::CodeBlock,
        ctx: &mut RuntimeContext,
        rule_label: &str,
        stop_on_return_call: bool,
    ) -> Result<StatementBlockFlow, String> {
        let mut if_stack: Vec<StatementIfFrame> = Vec::new();
        let mut switch_stack: Vec<StatementSwitchFrame> = Vec::new();
        for stmt in &block.statements {
            let parent_active = Self::statement_controls_active(&if_stack, &switch_stack);
            if self.handle_statement_if_control(
                &stmt.expr,
                &mut if_stack,
                parent_active,
                ctx,
                rule_label,
            )? {
                continue;
            }
            let parent_active = Self::statement_controls_active(&if_stack, &switch_stack);
            if self.handle_statement_switch_control(
                &stmt.expr,
                &mut switch_stack,
                parent_active,
                ctx,
                rule_label,
            )? {
                continue;
            }
            if !Self::statement_controls_active(&if_stack, &switch_stack) {
                continue;
            }
            if let Some(flow) = self.execute_statement_while_loop(&stmt.expr, ctx, rule_label)? {
                if flow == StatementBlockFlow::Returned {
                    return Ok(flow);
                }
                continue;
            }
            if stop_on_return_call && Self::return_call_payload(&stmt.expr).is_some() {
                self.eval_expr(&stmt.expr, ctx, rule_label)?;
                return Ok(StatementBlockFlow::Returned);
            }
            if self.execute_scalar_assignment_operator_statement(&stmt.expr, ctx, rule_label)? {
                continue;
            }
            if self.execute_array_append_operator_statement(&stmt.expr, ctx, rule_label)? {
                continue;
            }
            if self.execute_array_end_mutation_method_statement(&stmt.expr, ctx, rule_label)? {
                continue;
            }
            if self.execute_hash_index_assignment_operator_statement(&stmt.expr, ctx, rule_label)? {
                continue;
            }
            if self
                .execute_nested_access_assignment_operator_statement(&stmt.expr, ctx, rule_label)?
            {
                continue;
            }
            if self.execute_set_key_statement(&stmt.expr, ctx, rule_label)? {
                continue;
            }
            self.execute_block_statement_expr(&stmt.expr, ctx, rule_label)?;
        }
        Ok(StatementBlockFlow::Continue)
    }

    fn execute_block_statement_expr(
        &self,
        expr: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<(), String> {
        if self.execute_scalar_assignment_operator_statement(expr, ctx, rule_label)? {
            return Ok(());
        }
        if self.execute_array_append_operator_statement(expr, ctx, rule_label)? {
            return Ok(());
        }
        if self.execute_array_end_mutation_method_statement(expr, ctx, rule_label)? {
            return Ok(());
        }
        if self.execute_hash_index_assignment_operator_statement(expr, ctx, rule_label)? {
            return Ok(());
        }
        if self.execute_nested_access_assignment_operator_statement(expr, ctx, rule_label)? {
            return Ok(());
        }
        if self.execute_set_key_statement(expr, ctx, rule_label)? {
            return Ok(());
        }
        if self.execute_push_child_call_statement(expr, ctx, rule_label)? {
            return Ok(());
        }
        if self.execute_array_string_transform_statement(expr, ctx, rule_label)? {
            return Ok(());
        }
        self.eval_expr(expr, ctx, rule_label)?;
        Ok(())
    }

    fn execute_array_string_transform_statement(
        &self,
        expr: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<bool, String> {
        use linkedspec_core::expr::{Arg, Expr};

        let Expr::Call { name, args } = expr else {
            return Ok(false);
        };
        if !matches!(
            name.as_str(),
            "trim_each" | "lowercase_each" | "uppercase_each"
        ) || args.len() != 1
        {
            return Ok(false);
        }
        let Some(Arg::Positional(Expr::Call {
            name: wrapper,
            args: wrapper_args,
        })) = args.first()
        else {
            return Ok(false);
        };
        let [Arg::Positional(Expr::Variable { name: target })] = wrapper_args.as_slice() else {
            return Ok(false);
        };
        if wrapper != "array" {
            return Ok(false);
        }

        let transformed = ctx
            .get_array(target)
            .iter()
            .map(|value| {
                let value = value.to_str();
                RuntimeValue::Scalar(match name.as_str() {
                    "trim_each" => value.trim().to_string(),
                    "lowercase_each" => value.to_lowercase(),
                    "uppercase_each" => value.to_uppercase(),
                    _ => unreachable!(),
                })
            })
            .collect();
        ctx.set_array(target, transformed);
        ctx.trace_decision(
            "rust_runtime:engine:array_string_transform_statement",
            true,
            format!("rule={rule_label} helper={name} target={target}"),
            TraceLevel::FULL,
        );
        Ok(true)
    }

    fn execute_statement_while_loop(
        &self,
        expr: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<Option<StatementBlockFlow>, String> {
        let Some((condition, body)) = Self::while_call_parts(expr) else {
            return Ok(None);
        };

        let mut iterations = 0usize;
        while self.eval_expr(condition, ctx, rule_label)?.as_bool() {
            iterations += 1;
            if iterations > LINKEDSPEC_WHILE_ITERATION_LIMIT {
                return Err(Self::while_iteration_limit_message());
            }
            if self.execute_block_statements(body, ctx, rule_label, true)?
                == StatementBlockFlow::Returned
            {
                return Ok(Some(StatementBlockFlow::Returned));
            }
        }

        Ok(Some(StatementBlockFlow::Continue))
    }

    fn statement_controls_active(
        if_stack: &[StatementIfFrame],
        switch_stack: &[StatementSwitchFrame],
    ) -> bool {
        if_stack.iter().all(|frame| frame.current_active)
            && switch_stack.iter().all(|frame| frame.current_active)
    }

    /// Handle statement-form `if(cond); elseif(cond); else(); endif()` controls.
    ///
    /// Only one-argument `if`/`elseif` and zero-argument `else`/`endif` are
    /// statement controls. Multi-argument `if(cond, then, else)` remains the
    /// value helper implemented by `call_helper_lazy`.
    fn handle_statement_if_control(
        &self,
        expr: &linkedspec_core::expr::Expr,
        if_stack: &mut Vec<StatementIfFrame>,
        parent_active: bool,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<bool, String> {
        use linkedspec_core::expr::Expr;

        let Expr::Call { name, args } = expr else {
            return Ok(false);
        };

        match name.as_str() {
            "if" if args.len() == 1 => {
                let cond = if parent_active {
                    self.eval_expr(args[0].value(), ctx, rule_label)?.as_bool()
                } else {
                    false
                };
                ctx.trace_decision(
                    "rust_runtime:engine:statement_if",
                    parent_active && cond,
                    format!("rule={rule_label} branch=if parent_active={parent_active}"),
                    TraceLevel::FULL,
                );
                if_stack.push(StatementIfFrame {
                    parent_active,
                    current_active: parent_active && cond,
                    branch_taken: cond,
                });
                Ok(true)
            }
            "elseif" if args.len() == 1 => {
                let Some(frame) = if_stack.last_mut() else {
                    return Ok(true);
                };
                if frame.parent_active && !frame.branch_taken {
                    let cond = self.eval_expr(args[0].value(), ctx, rule_label)?.as_bool();
                    frame.current_active = cond;
                    frame.branch_taken = cond;
                    ctx.trace_decision(
                        "rust_runtime:engine:statement_if",
                        cond,
                        format!("rule={rule_label} branch=elseif parent_active=true"),
                        TraceLevel::FULL,
                    );
                } else {
                    frame.current_active = false;
                    ctx.trace_decision(
                        "rust_runtime:engine:statement_if",
                        false,
                        format!(
                            "rule={rule_label} branch=elseif parent_active={} prior_branch_taken={}",
                            frame.parent_active, frame.branch_taken
                        ),
                        TraceLevel::FULL,
                    );
                }
                Ok(true)
            }
            "else" if args.is_empty() => {
                let Some(frame) = if_stack.last_mut() else {
                    return Ok(true);
                };
                frame.current_active = frame.parent_active && !frame.branch_taken;
                ctx.trace_decision(
                    "rust_runtime:engine:statement_if",
                    frame.current_active,
                    format!(
                        "rule={rule_label} branch=else parent_active={} prior_branch_taken={}",
                        frame.parent_active, frame.branch_taken
                    ),
                    TraceLevel::FULL,
                );
                frame.branch_taken = true;
                Ok(true)
            }
            "endif" if args.is_empty() => {
                if_stack.pop();
                Ok(true)
            }
            _ => Ok(false),
        }
    }

    /// Handle statement-form `switch(expr); case(value); default(); endswitch()` controls.
    ///
    /// Only one-argument `switch` / `case` and zero-argument `default` /
    /// `endswitch` are statement controls. Multi-argument lazy value-form
    /// `switch(expr, case(...), default(...))` remains in `call_helper_lazy`.
    fn handle_statement_switch_control(
        &self,
        expr: &linkedspec_core::expr::Expr,
        switch_stack: &mut Vec<StatementSwitchFrame>,
        parent_active: bool,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<bool, String> {
        use linkedspec_core::expr::Expr;

        let Expr::Call { name, args } = expr else {
            return Ok(false);
        };

        match name.as_str() {
            "switch" if args.len() == 1 => {
                let switch_value = if parent_active {
                    self.eval_expr(args[0].value(), ctx, rule_label)?.to_str()
                } else {
                    String::new()
                };
                ctx.trace_decision(
                    "rust_runtime:engine:statement_switch",
                    parent_active,
                    format!("rule={rule_label} branch=switch parent_active={parent_active}"),
                    TraceLevel::FULL,
                );
                switch_stack.push(StatementSwitchFrame {
                    parent_active,
                    current_active: false,
                    branch_taken: false,
                    switch_value,
                });
                Ok(true)
            }
            "case" if args.len() == 1 => {
                let Some(frame) = switch_stack.last_mut() else {
                    return Ok(true);
                };
                if frame.parent_active && !frame.branch_taken {
                    let case_value =
                        self.eval_switch_case_value(args[0].value(), ctx, rule_label)?;
                    let matches = case_value == frame.switch_value;
                    frame.current_active = matches;
                    frame.branch_taken = matches;
                    ctx.trace_decision(
                        "rust_runtime:engine:statement_switch",
                        matches,
                        format!("rule={rule_label} branch=case parent_active=true"),
                        TraceLevel::FULL,
                    );
                } else {
                    frame.current_active = false;
                    ctx.trace_decision(
                        "rust_runtime:engine:statement_switch",
                        false,
                        format!(
                            "rule={rule_label} branch=case parent_active={} prior_branch_taken={}",
                            frame.parent_active, frame.branch_taken
                        ),
                        TraceLevel::FULL,
                    );
                }
                Ok(true)
            }
            "default" if args.is_empty() => {
                let Some(frame) = switch_stack.last_mut() else {
                    return Ok(true);
                };
                frame.current_active = frame.parent_active && !frame.branch_taken;
                ctx.trace_decision(
                    "rust_runtime:engine:statement_switch",
                    frame.current_active,
                    format!(
                        "rule={rule_label} branch=default parent_active={} prior_branch_taken={}",
                        frame.parent_active, frame.branch_taken
                    ),
                    TraceLevel::FULL,
                );
                frame.branch_taken = true;
                Ok(true)
            }
            "endswitch" if args.is_empty() => {
                switch_stack.pop();
                Ok(true)
            }
            _ => Ok(false),
        }
    }

    fn eval_switch_case_value(
        &self,
        expr: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<String, String> {
        match expr {
            linkedspec_core::expr::Expr::Variable { name } => Ok(name.clone()),
            other => Ok(self.eval_expr(other, ctx, rule_label)?.to_str()),
        }
    }

    /// Execute the statement-only scalar assignment operator `name = value`.
    fn execute_scalar_assignment_operator_statement(
        &self,
        expr: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<bool, String> {
        use linkedspec_core::expr::Expr;
        let Expr::AssignScalar { name, value } = expr else {
            return Ok(false);
        };
        let evaluated = self.eval_expr(value, ctx, rule_label)?;
        ctx.set_scalar(name, evaluated);
        Ok(true)
    }

    /// Execute the statement-level array append operator `items += value`.
    fn execute_array_append_operator_statement(
        &self,
        expr: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<bool, String> {
        use linkedspec_core::expr::Expr;
        let Expr::AssignArrayAppend { name, value } = expr else {
            return Ok(false);
        };
        let evaluated = self.eval_expr(value, ctx, rule_label)?;
        ctx.push_array_value(name, evaluated);
        Ok(true)
    }

    /// Execute the statement-level hash-index assignment operator `meta["key"] = value`.
    fn execute_hash_index_assignment_operator_statement(
        &self,
        expr: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<bool, String> {
        use linkedspec_core::expr::Expr;
        let Expr::AssignHashIndex { name, key, value } = expr else {
            return Ok(false);
        };
        self.eval_hash_index_assignment_expression(name, key, value, ctx, rule_label)?;
        Ok(true)
    }

    /// Execute the statement-level nested value-path assignment
    /// `payload["items"][0]["name"] = value`.
    fn execute_nested_access_assignment_operator_statement(
        &self,
        expr: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<bool, String> {
        use linkedspec_core::expr::Expr;
        let Expr::AssignNestedAccess {
            base,
            segments,
            value,
        } = expr
        else {
            return Ok(false);
        };
        self.eval_nested_access_assignment_expression(base, segments, value, ctx, rule_label)?;
        Ok(true)
    }

    fn eval_array_append_expression(
        &self,
        name: &str,
        value: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        let evaluated = self.eval_expr(value, ctx, rule_label)?;
        ctx.push_array_value(name, evaluated);
        Ok(RuntimeValue::Array(ctx.get_array(name)))
    }

    fn eval_hash_index_assignment_expression(
        &self,
        name: &str,
        key: &linkedspec_core::expr::Expr,
        value: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        if matches!(ctx.bare_kind(name), Some(RuntimeVarKind::Scalar)) {
            let mut root = ctx.get_scalar(name);
            match root {
                RuntimeValue::Hash(ref mut entries) => {
                    let evaluated_key = self.eval_expr(key, ctx, rule_label)?.to_str();
                    let evaluated_value = self.eval_expr(value, ctx, rule_label)?;
                    if let Some((_, existing)) = entries
                        .iter_mut()
                        .find(|(candidate, _)| candidate == &evaluated_key)
                    {
                        *existing = evaluated_value;
                    } else {
                        entries.push((evaluated_key, evaluated_value));
                    }
                    ctx.set_scalar(name, root.clone());
                    return Ok(root);
                }
                RuntimeValue::Array(ref mut items) => {
                    if matches!(key, linkedspec_core::expr::Expr::StringLiteral { .. }) {
                        return Ok(RuntimeValue::Undef);
                    }
                    let idx_val = self.eval_expr(key, ctx, rule_label)?;
                    let idx_number = idx_val.as_number().unwrap_or(0.0);
                    let idx = if idx_number.is_finite() && idx_number >= 0.0 {
                        idx_number as usize
                    } else {
                        usize::MAX
                    };
                    let evaluated_value = self.eval_expr(value, ctx, rule_label)?;
                    if idx < items.len() {
                        items[idx] = evaluated_value;
                    } else if idx == items.len() {
                        items.push(evaluated_value);
                    } else {
                        return Ok(RuntimeValue::Undef);
                    }
                    ctx.set_scalar(name, root.clone());
                    return Ok(root);
                }
                _ => return Ok(RuntimeValue::Undef),
            }
        }
        let evaluated_key = self.eval_expr(key, ctx, rule_label)?.to_str();
        let evaluated_value = self.eval_expr(value, ctx, rule_label)?;
        ctx.set_hash_entry(name, &evaluated_key, evaluated_value);
        Ok(RuntimeValue::Hash(ctx.get_hash(name)))
    }

    fn eval_nested_access_assignment_expression(
        &self,
        base: &str,
        segments: &[AccessSegment],
        value: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        let evaluated_segments = self.eval_access_segments(segments, ctx, rule_label)?;
        let evaluated_value = self.eval_expr(value, ctx, rule_label)?;
        let original_kind = ctx.bare_kind(base);
        let mut root = ctx.get_bare_value(base);
        if !Self::assign_nested_runtime_value(&mut root, &evaluated_segments, evaluated_value) {
            return Ok(RuntimeValue::Undef);
        }

        match (original_kind, &root) {
            (Some(RuntimeVarKind::Array), RuntimeValue::Array(values)) => {
                ctx.set_array(base, values.clone())
            }
            (Some(RuntimeVarKind::Hash), RuntimeValue::Hash(values)) => {
                ctx.set_hash(base, values.clone())
            }
            _ => ctx.set_scalar(base, root.clone()),
        }
        Ok(root)
    }

    fn eval_access_segments(
        &self,
        segments: &[AccessSegment],
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<Vec<EvaluatedAccessSegment>, String> {
        let mut evaluated = Vec::with_capacity(segments.len());
        for segment in segments {
            match segment {
                AccessSegment::Key { value } => {
                    evaluated.push(EvaluatedAccessSegment::Key(value.clone()));
                }
                AccessSegment::Index { expr } => {
                    let idx_val = self.eval_expr(expr, ctx, rule_label)?;
                    let idx_number = idx_val.as_number().unwrap_or(0.0);
                    let idx = if idx_number.is_finite() && idx_number >= 0.0 {
                        idx_number as usize
                    } else {
                        usize::MAX
                    };
                    evaluated.push(EvaluatedAccessSegment::Index(idx));
                }
            }
        }
        Ok(evaluated)
    }

    fn assign_nested_runtime_value(
        current: &mut RuntimeValue,
        segments: &[EvaluatedAccessSegment],
        value: RuntimeValue,
    ) -> bool {
        let Some((segment, rest)) = segments.split_first() else {
            return false;
        };
        if rest.is_empty() {
            return match (current, segment) {
                (RuntimeValue::Hash(entries), EvaluatedAccessSegment::Key(key)) => {
                    if let Some((_, existing)) =
                        entries.iter_mut().find(|(candidate, _)| candidate == key)
                    {
                        *existing = value;
                    } else {
                        entries.push((key.clone(), value));
                    }
                    true
                }
                (RuntimeValue::Array(items), EvaluatedAccessSegment::Index(idx)) => {
                    if *idx < items.len() {
                        items[*idx] = value;
                        true
                    } else if *idx == items.len() {
                        items.push(value);
                        true
                    } else {
                        false
                    }
                }
                _ => false,
            };
        }

        match (current, segment) {
            (RuntimeValue::Hash(entries), EvaluatedAccessSegment::Key(key)) => {
                let Some((_, child)) = entries.iter_mut().find(|(candidate, _)| candidate == key)
                else {
                    return false;
                };
                Self::assign_nested_runtime_value(child, rest, value)
            }
            (RuntimeValue::Array(items), EvaluatedAccessSegment::Index(idx)) => {
                let Some(child) = items.get_mut(*idx) else {
                    return false;
                };
                Self::assign_nested_runtime_value(child, rest, value)
            }
            _ => false,
        }
    }

    /// Execute statement-level receiver-dot array end mutations.
    ///
    /// `items.push_back(value)` and `array(items).push_front(value)` name the
    /// working array on the receiver side; these are not value-returning fluent
    /// expressions in this slice.
    fn execute_array_end_mutation_method_statement(
        &self,
        expr: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<bool, String> {
        use linkedspec_core::expr::Expr;
        let Expr::FluentChain { receiver, calls } = expr else {
            return Ok(false);
        };
        let [call] = calls.as_slice() else {
            return Ok(false);
        };
        let Some(target) = Self::array_receiver_target(receiver) else {
            return Ok(false);
        };

        match call.method.as_str() {
            "push_back" if call.args.len() == 1 => {
                let value = self.eval_expr(call.args[0].value(), ctx, rule_label)?;
                ctx.push_array_value(&target, value);
                Ok(true)
            }
            "push_front" if call.args.len() == 1 => {
                let value = self.eval_expr(call.args[0].value(), ctx, rule_label)?;
                ctx.push_front_value(&target, value);
                Ok(true)
            }
            "pop_back" if call.args.is_empty() => {
                let _ = ctx.pop_back_value(&target);
                Ok(true)
            }
            "pop_front" if call.args.is_empty() => {
                let _ = ctx.pop_front_value(&target);
                Ok(true)
            }
            _ => Ok(false),
        }
    }

    fn array_receiver_target(receiver: &linkedspec_core::expr::Expr) -> Option<String> {
        use linkedspec_core::expr::{Arg, Expr};
        match receiver {
            Expr::Variable { name } => Some(name.clone()),
            Expr::Call { name, args } if name == "array" && args.len() == 1 => match &args[0] {
                Arg::Positional(Expr::Variable { name }) => Some(name.clone()),
                _ => None,
            },
            _ => None,
        }
    }

    /// Execute the top-level mutation form `set_key(target, key, value)`.
    ///
    /// Nested `set_key(hash_expr, key, value)` remains a pure hash-valued
    /// expression in `call_helper`; only a lifecycle statement whose first
    /// argument names a hash target mutates the runtime hash.
    fn execute_set_key_statement(
        &self,
        expr: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<bool, String> {
        use linkedspec_core::expr::{Arg, Expr};
        let Expr::Call { name, args } = expr else {
            return Ok(false);
        };
        if name != "set_key" {
            return Ok(false);
        }

        let effective_args: &[Arg] = if args.len() == 4 {
            match args.first() {
                Some(Arg::Positional(Expr::Variable { .. })) => &args[1..],
                _ => args,
            }
        } else {
            args
        };
        if effective_args.len() != 3 {
            return Ok(false);
        }

        let hash_name = self.resolve_hash_target(effective_args, &RuntimeValue::Undef, true);
        if hash_name.is_empty() {
            return Ok(false);
        }

        let key = self
            .eval_expr(effective_args[1].value(), ctx, rule_label)?
            .to_str();
        let value = self.eval_expr(effective_args[2].value(), ctx, rule_label)?;
        ctx.set_hash_entry(&hash_name, &key, value);
        Ok(true)
    }

    fn execute_push_child_call_statement(
        &self,
        expr: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<bool, String> {
        use linkedspec_core::expr::{Arg, Expr};

        let Expr::Call { name, args } = expr else {
            return Ok(false);
        };
        if name != "push" || args.is_empty() || args.len() > 3 {
            return Ok(false);
        }

        let Some(child_label) = args.first().and_then(|arg| match arg {
            Arg::Positional(Expr::Variable { name }) if self.spec.find(name).is_some() => {
                Some(name.as_str())
            }
            _ => None,
        }) else {
            return Ok(false);
        };

        if matches!(args.as_slice(), [_child, _target, index_arg] if Self::literal_usize_arg(index_arg).is_none())
        {
            return Ok(false);
        }

        let child_value = if let Some(value) = ctx.action_edge_call_result(child_label) {
            value
        } else {
            self.execute_child_rule(child_label, 0, ctx)?
        };

        match args.as_slice() {
            [_child] => {
                ctx.push_array_value(rule_label, child_value);
            }
            [_child, second] => {
                if let Some(index) = Self::literal_usize_arg(second) {
                    ctx.push_array_value(rule_label, Self::array_index_value(&child_value, index));
                } else {
                    let target_value = self.eval_expr(second.value(), ctx, rule_label)?;
                    let target = self.resolve_array_target(
                        std::slice::from_ref(second),
                        &target_value,
                        true,
                    );
                    ctx.push_array_value(&target, child_value);
                }
            }
            [_child, target_arg, index_arg] => {
                let index = Self::literal_usize_arg(index_arg)
                    .expect("push(child, target, index) shape validated before child dispatch");
                let target_value = self.eval_expr(target_arg.value(), ctx, rule_label)?;
                let target = self.resolve_array_target(
                    std::slice::from_ref(target_arg),
                    &target_value,
                    true,
                );
                ctx.push_array_value(&target, Self::array_index_value(&child_value, index));
            }
            _ => return Ok(false),
        }

        Ok(true)
    }

    fn literal_usize_arg(arg: &linkedspec_core::expr::Arg) -> Option<usize> {
        match arg.value() {
            linkedspec_core::expr::Expr::NumberLiteral { value }
                if value.is_finite() && *value >= 0.0 && value.fract() == 0.0 =>
            {
                Some(*value as usize)
            }
            _ => None,
        }
    }

    fn array_index_value(value: &RuntimeValue, index: usize) -> RuntimeValue {
        match value {
            RuntimeValue::Array(values) => {
                values.get(index).cloned().unwrap_or(RuntimeValue::Undef)
            }
            _ => RuntimeValue::Undef,
        }
    }

    fn aggregate_wrapper_assignment_target(
        raw_target: &linkedspec_core::expr::Arg,
        value: &RuntimeValue,
    ) -> Option<(ShapeLiteralKind, String)> {
        use linkedspec_core::expr::{Arg, Expr};
        let Arg::Positional(Expr::Call { name, args }) = raw_target else {
            return None;
        };
        if args.len() != 1 {
            return None;
        }
        let Arg::Positional(Expr::Variable { name: target }) = &args[0] else {
            return None;
        };
        match (name.as_str(), value) {
            ("array", RuntimeValue::Array(_)) => Some((ShapeLiteralKind::Array, target.clone())),
            ("hash", RuntimeValue::Hash(_)) => Some((ShapeLiteralKind::Hash, target.clone())),
            _ => None,
        }
    }

    fn store_aggregate_assignment(
        target: &str,
        kind: ShapeLiteralKind,
        value: RuntimeValue,
        ctx: &mut RuntimeContext,
    ) -> Result<RuntimeValue, String> {
        match (kind, value) {
            (ShapeLiteralKind::Array, RuntimeValue::Array(values)) => {
                let stored = RuntimeValue::Array(values.clone());
                ctx.record_rule_local_binding(target);
                ctx.set_array(target, values);
                Ok(stored)
            }
            (ShapeLiteralKind::Hash, RuntimeValue::Hash(values)) => {
                let stored = RuntimeValue::Hash(values.clone());
                ctx.record_rule_local_binding(target);
                ctx.set_hash(target, values);
                Ok(stored)
            }
            (_, other) => Err(format!(
                "aggregate assignment evaluated to unexpected value kind: {:?}",
                other
            )),
        }
    }

    fn scalar_held_array_snapshot(ctx: &RuntimeContext, name: &str) -> Option<Vec<RuntimeValue>> {
        if ctx.descriptor_scalar_bare_read(name) {
            return None;
        }
        if !matches!(ctx.bare_kind(name), Some(RuntimeVarKind::Scalar)) {
            return None;
        }
        match ctx.get_scalar(name) {
            RuntimeValue::Array(values) => Some(values),
            _ => None,
        }
    }

    fn scalar_held_hash_snapshot(
        ctx: &RuntimeContext,
        name: &str,
    ) -> Option<Vec<(String, RuntimeValue)>> {
        if ctx.descriptor_scalar_bare_read(name) {
            return None;
        }
        if !matches!(ctx.bare_kind(name), Some(RuntimeVarKind::Scalar)) {
            return None;
        }
        match ctx.get_scalar(name) {
            RuntimeValue::Hash(values) => Some(values),
            _ => None,
        }
    }

    /// Evaluate an expression tree against the runtime context.
    fn eval_expr(
        &self,
        expr: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        use linkedspec_core::expr::Expr;
        match expr {
            Expr::Call { name, args } => {
                // Lazy-evaluation calls: if/switch/while/with/elseif/else/case/default
                // Branch bodies must NOT be evaluated eagerly — they are
                // evaluated only when their condition matches.
                let is_lazy = matches!(
                    name.as_str(),
                    "if" | "switch" | "while" | "with" | "elseif" | "else" | "case" | "default"
                );
                if is_lazy {
                    return self.call_helper_lazy(name, args, ctx, rule_label);
                }
                if let Some(function) = self.spec.find_function(name) {
                    if args.len() != function.arity {
                        return Err(format!(
                            "user function '{}' expects {} argument(s), got {} in rule '{}'",
                            function.name,
                            function.arity,
                            args.len(),
                            rule_label
                        ));
                    }
                    let evaluated: Vec<RuntimeValue> = args
                        .iter()
                        .map(|a| self.eval_expr(a.value(), ctx, rule_label))
                        .collect::<Result<Vec<_>, _>>()?;
                    return self.execute_user_function(function, &evaluated, ctx);
                }
                // Normal eager evaluation for all other helpers
                let evaluated: Vec<RuntimeValue> = args
                    .iter()
                    .map(|a| self.eval_expr(a.value(), ctx, rule_label))
                    .collect::<Result<Vec<_>, _>>()?;
                self.call_helper_with_args(name, args, &evaluated, ctx, rule_label)
            }
            Expr::AssignScalar { name, value } => {
                let evaluated = self.eval_expr(value, ctx, rule_label)?;
                ctx.set_scalar(name, evaluated.clone());
                Ok(evaluated)
            }
            Expr::AssignArrayAppend { name, value } => {
                self.eval_array_append_expression(name, value, ctx, rule_label)
            }
            Expr::AssignHashIndex { name, key, value } => {
                self.eval_hash_index_assignment_expression(name, key, value, ctx, rule_label)
            }
            Expr::AssignNestedAccess {
                base,
                segments,
                value,
            } => self
                .eval_nested_access_assignment_expression(base, segments, value, ctx, rule_label),
            Expr::Variable { name } => Ok(ctx.get_bare_value(name)),
            Expr::IndexedVar { name, index } => {
                let idx_val = self.eval_expr(index, ctx, rule_label)?;
                let idx: usize = idx_val.as_number().unwrap_or(0.0) as usize;
                let arr = ctx.get_array(name);
                Ok(arr.get(idx).cloned().unwrap_or(RuntimeValue::Undef))
            }
            Expr::NestedAccess { base, segments } => {
                let mut current = ctx.get_bare_value(base);
                for segment in segments {
                    current = match segment {
                        AccessSegment::Key { value } => match current {
                            RuntimeValue::Hash(entries) => entries
                                .iter()
                                .find(|(key, _)| key == value)
                                .map(|(_, value)| value.clone())
                                .unwrap_or(RuntimeValue::Undef),
                            _ => RuntimeValue::Undef,
                        },
                        AccessSegment::Index { expr } => {
                            let idx_val = self.eval_expr(expr, ctx, rule_label)?;
                            let idx: usize = idx_val.as_number().unwrap_or(0.0) as usize;
                            match current {
                                RuntimeValue::Array(items) => {
                                    items.get(idx).cloned().unwrap_or(RuntimeValue::Undef)
                                }
                                _ => RuntimeValue::Undef,
                            }
                        }
                    };
                }
                Ok(current)
            }
            Expr::ArrayLiteral { items } => {
                let mut values = Vec::new();
                for item in items {
                    let value = self.eval_expr(item, ctx, rule_label)?;
                    if matches!(
                        item,
                        Expr::Call { name, .. }
                            if matches!(name.as_str(), "flat" | "flat_array" | "flat_hash")
                    ) {
                        Self::push_list_context_values(&mut values, &value);
                    } else {
                        values.push(value);
                    }
                }
                Ok(RuntimeValue::Array(values))
            }
            Expr::HashLiteral { entries } => {
                let mut values = Vec::new();
                for entry in entries {
                    let key = self.eval_expr(&entry.key, ctx, rule_label)?.to_str();
                    let value = self.eval_expr(&entry.value, ctx, rule_label)?;
                    values.push((key, value));
                }
                Ok(RuntimeValue::Hash(values))
            }
            Expr::BlockValue { block } => self.eval_block_value(block, ctx, rule_label),
            Expr::StringLiteral { value } => Ok(RuntimeValue::Scalar(value.clone())),
            Expr::NumberLiteral { value } => Ok(RuntimeValue::Number(*value)),
            Expr::BooleanLiteral { value } => Ok(RuntimeValue::Bool(*value)),
            Expr::RegexLiteral { pattern } => Ok(RuntimeValue::Scalar(pattern.clone())),
            Expr::Undef => Ok(RuntimeValue::Undef),
            Expr::FluentChain { receiver, calls } => {
                if calls
                    .iter()
                    .any(Self::is_receiver_trailing_block_surface_call)
                {
                    return self
                        .eval_receiver_with_trailing_block_chain(receiver, calls, ctx, rule_label);
                }
                if calls.first().is_some_and(|call| {
                    Self::is_hash_receiver_value_chain_method(&call.method)
                        && (call.method != "copy"
                            || Self::copy_receiver_starts_hash_chain(receiver, calls, ctx))
                }) {
                    return self.eval_hash_receiver_value_chain(receiver, calls, ctx, rule_label);
                }
                if calls
                    .first()
                    .is_some_and(|call| Self::is_array_receiver_value_chain_method(&call.method))
                {
                    return self.eval_array_receiver_value_chain(receiver, calls, ctx, rule_label);
                }
                if calls
                    .first()
                    .is_some_and(|call| Self::is_string_receiver_value_chain_method(&call.method))
                {
                    return self.eval_string_receiver_value_chain(receiver, calls, ctx, rule_label);
                }
                if calls
                    .first()
                    .is_some_and(|call| Self::is_number_receiver_value_chain_method(&call.method))
                {
                    return self.eval_number_receiver_value_chain(receiver, calls, ctx, rule_label);
                }
                if calls
                    .iter()
                    .any(|call| Self::is_statement_only_array_end_mutation_method(&call.method))
                {
                    self.eval_expr(receiver, ctx, rule_label)?;
                    return Ok(RuntimeValue::Undef);
                }
                self.eval_expr(receiver, ctx, rule_label)?;
                for call in calls {
                    let evaluated: Vec<RuntimeValue> = call
                        .args
                        .iter()
                        .map(|a| self.eval_expr(a.value(), ctx, rule_label))
                        .collect::<Result<Vec<_>, _>>()?;
                    self.call_helper_with_args(
                        &call.method,
                        &call.args,
                        &evaluated,
                        ctx,
                        rule_label,
                    )?;
                }
                Ok(RuntimeValue::Undef)
            }
        }
    }

    fn execute_user_function(
        &self,
        function: &CompiledUserFunction,
        args: &[RuntimeValue],
        ctx: &mut RuntimeContext,
    ) -> Result<RuntimeValue, String> {
        if !ctx.enter_user_function(&function.name) {
            return Err(format!(
                "recursive user function call '{}' is not supported",
                function.name
            ));
        }

        let caller_stores = ctx.take_variable_stores();
        for (param, value) in function.params.iter().zip(args.iter().cloned()) {
            ctx.set_scalar(param, value.clone());
            match value {
                RuntimeValue::Array(values) => ctx.set_array(param, values),
                RuntimeValue::Hash(values) => ctx.set_hash(param, values),
                _ => {}
            }
        }

        let function_label = format!("function '{}'", function.name);
        ctx.suspend_rule_declaration_tracking();
        let result = self.eval_block_value(&function.body, ctx, &function_label);
        ctx.resume_rule_declaration_tracking();
        ctx.restore_variable_stores(caller_stores);
        ctx.exit_user_function(&function.name);
        result.map_err(|err| format!("user function '{}': {}", function.name, err))
    }

    fn is_statement_only_array_end_mutation_method(method: &str) -> bool {
        matches!(
            method,
            "push_back" | "push_front" | "pop_back" | "pop_front"
        )
    }

    fn is_array_receiver_value_chain_method(method: &str) -> bool {
        matches!(
            method,
            "copy"
                | "sorted"
                | "reversed"
                | "take"
                | "take_last"
                | "drop_front"
                | "drop_back"
                | "slice"
                | "concat_arrays"
                | "split_each"
                | "trim_each"
                | "filter_nonempty"
                | "lowercase_each"
                | "uppercase_each"
                | "uniq"
                | "filter_match"
                | "count"
                | "first"
                | "last"
                | "contains"
                | "index_of"
                | "is_empty"
                | "is_nonempty"
                | "join_values"
                | "sum"
                | "avg"
                | "median"
                | "range"
                | "min"
                | "max"
        )
    }

    fn is_array_receiver_array_returning_method(method: &str) -> bool {
        matches!(
            method,
            "copy"
                | "sorted"
                | "reversed"
                | "take"
                | "take_last"
                | "drop_front"
                | "drop_back"
                | "slice"
                | "concat_arrays"
                | "split_each"
                | "trim_each"
                | "filter_nonempty"
                | "lowercase_each"
                | "uppercase_each"
                | "uniq"
                | "filter_match"
        )
    }

    fn is_hash_receiver_value_chain_method(method: &str) -> bool {
        Self::is_hash_receiver_hash_returning_method(method)
            || Self::is_hash_receiver_array_returning_method(method)
            || Self::is_hash_receiver_terminal_method(method)
    }

    fn is_hash_receiver_hash_returning_method(method: &str) -> bool {
        matches!(
            method,
            "copy"
                | "merge_hash"
                | "set_key"
                | "rename_key"
                | "drop_keys"
                | "pick_keys"
                | "flat_hash"
                | "walk_leaves"
                | "map_leaves"
        )
    }

    fn is_hash_receiver_array_returning_method(method: &str) -> bool {
        matches!(method, "sorted_keys" | "sorted_values")
    }

    fn is_hash_receiver_terminal_method(method: &str) -> bool {
        matches!(method, "count_keys" | "has_key" | "reduce_leaves")
    }

    fn copy_receiver_starts_hash_chain(
        receiver: &linkedspec_core::expr::Expr,
        calls: &[linkedspec_core::expr::FluentCall],
        ctx: &RuntimeContext,
    ) -> bool {
        use linkedspec_core::expr::Expr;

        match receiver {
            Expr::Call { name, args } if name == "hash" && args.len() == 1 => return true,
            Expr::Call { name, args } if name == "array" && args.len() == 1 => return false,
            Expr::Variable { name } => match ctx.bare_kind(name) {
                Some(RuntimeVarKind::Hash) => return true,
                Some(RuntimeVarKind::Array) => return false,
                _ => {}
            },
            _ => {}
        }

        if let Some(next) = calls.get(1) {
            if Self::is_hash_receiver_value_chain_method(&next.method) {
                return true;
            }
            if Self::is_array_receiver_value_chain_method(&next.method) {
                return false;
            }
        }

        false
    }

    fn is_string_receiver_value_chain_method(method: &str) -> bool {
        Self::is_string_receiver_string_returning_method(method)
            || Self::is_string_receiver_array_returning_method(method)
            || Self::is_string_receiver_terminal_method(method)
    }

    fn is_string_receiver_string_returning_method(method: &str) -> bool {
        matches!(
            method,
            "trim"
                | "lowercase"
                | "uppercase"
                | "replace_substr"
                | "rm_prefix"
                | "rm_suffix"
                | "substr"
                | "cat"
                | "coalesce_nonempty"
        )
    }

    fn is_string_receiver_array_returning_method(method: &str) -> bool {
        matches!(method, "split")
    }

    fn is_string_receiver_terminal_method(method: &str) -> bool {
        matches!(
            method,
            "length" | "starts_with" | "ends_with" | "contains_substr" | "matches"
        )
    }

    fn number_receiver_helper_name(method: &str) -> Option<&'static str> {
        match method {
            "abs" => Some("num_abs"),
            "floor" => Some("num_floor"),
            "ceil" => Some("num_ceil"),
            "round" => Some("num_round"),
            "add" => Some("num_add"),
            "sub" => Some("num_sub"),
            "mul" => Some("num_mul"),
            "div" => Some("num_div"),
            "mod" => Some("num_mod"),
            "min" => Some("num_min"),
            "max" => Some("num_max"),
            "clamp" => Some("num_clamp"),
            "eq" => Some("num_eq"),
            "ne" => Some("num_ne"),
            "gt" => Some("num_gt"),
            "ge" => Some("num_ge"),
            "lt" => Some("num_lt"),
            "le" => Some("num_le"),
            _ => None,
        }
    }

    fn numeric_word_helper_name(method: &str) -> Option<&'static str> {
        match method {
            "+" => Some("num_add"),
            "-" => Some("num_sub"),
            "*" => Some("num_mul"),
            "/" => Some("num_div"),
            "%" => Some("num_mod"),
            "==" => Some("num_eq"),
            "!=" => Some("num_ne"),
            ">" => Some("num_gt"),
            ">=" => Some("num_ge"),
            "<" => Some("num_lt"),
            "<=" => Some("num_le"),
            "abs" => Some("num_abs"),
            "floor" => Some("num_floor"),
            "ceil" => Some("num_ceil"),
            "round" => Some("num_round"),
            "sum" => Some("num_sum"),
            "avg" => Some("num_avg"),
            "median" => Some("num_median"),
            "range" => Some("num_range"),
            "add" => Some("num_add"),
            "sub" => Some("num_sub"),
            "mul" => Some("num_mul"),
            "div" => Some("num_div"),
            "mod" => Some("num_mod"),
            "clamp" => Some("num_clamp"),
            "min" => Some("num_min"),
            "max" => Some("num_max"),
            "eq" => Some("num_eq"),
            "ne" => Some("num_ne"),
            "gt" => Some("num_gt"),
            "ge" => Some("num_ge"),
            "lt" => Some("num_lt"),
            "le" => Some("num_le"),
            _ => None,
        }
    }

    fn is_mark_capture_helper(name: &str) -> bool {
        matches!(
            name,
            "start_capture_slice"
                | "capture_slice"
                | "capture_slice_len"
                | "capture_slice_line"
                | "capture_slice_pos"
                | "capture_slice_until_cursor"
                | "capture_slice_until_cursor_len"
                | "capture_until_boundary"
                | "capture_take_until_cursor"
                | "capture_take_until_cursor_len"
                | "capture_take"
                | "capture_take_len"
                | "capture_rest"
                | "capture_rest_len"
                | "capture_take_rest"
                | "capture_take_rest_len"
                | "mark_here"
                | "mark_pos"
                | "mark_exists"
                | "mark_input_start"
                | "mark_input_end"
                | "mark_copy"
                | "capture_from"
                | "capture_len_from"
                | "capture_until_cursor_from"
                | "capture_until_cursor_len_from"
                | "capture_take_until_cursor_from"
                | "capture_take_until_cursor_len_from"
                | "capture_take_len_from"
                | "capture_rest_from"
                | "capture_rest_len_from"
                | "capture_take_rest_from"
                | "capture_take_rest_len_from"
                | "capture_between"
                | "capture_len_between"
        )
    }

    fn is_number_receiver_value_chain_method(method: &str) -> bool {
        Self::is_number_receiver_number_returning_method(method)
            || Self::is_number_receiver_terminal_method(method)
    }

    fn is_number_receiver_number_returning_method(method: &str) -> bool {
        matches!(
            method,
            "abs"
                | "floor"
                | "ceil"
                | "round"
                | "add"
                | "sub"
                | "mul"
                | "div"
                | "mod"
                | "min"
                | "max"
                | "clamp"
        )
    }

    fn is_number_receiver_terminal_method(method: &str) -> bool {
        matches!(method, "eq" | "ne" | "gt" | "ge" | "lt" | "le")
    }

    fn is_receiver_with_trailing_block_call(call: &linkedspec_core::expr::FluentCall) -> bool {
        use linkedspec_core::expr::{Arg, Expr};

        call.method == "with"
            && matches!(
                call.args.last(),
                Some(Arg::Positional(Expr::BlockValue { .. }))
            )
    }

    fn is_tree_traversal_receiver_method(method: &str) -> bool {
        matches!(method, "walk_leaves" | "map_leaves" | "reduce_leaves")
    }

    fn is_receiver_trailing_block_surface_call(call: &linkedspec_core::expr::FluentCall) -> bool {
        Self::is_receiver_with_trailing_block_call(call)
            || Self::is_tree_traversal_receiver_method(&call.method)
    }

    fn eval_receiver_with_trailing_block_chain(
        &self,
        receiver: &linkedspec_core::expr::Expr,
        calls: &[linkedspec_core::expr::FluentCall],
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        let mut current = self.eval_expr(receiver, ctx, rule_label)?;

        for (index, call) in calls.iter().enumerate() {
            if Self::is_receiver_with_trailing_block_call(call)
                || Self::is_tree_traversal_receiver_method(&call.method)
            {
                current =
                    self.eval_receiver_with_trailing_block_call(current, call, ctx, rule_label)?;
                if call.method == "reduce_leaves" && index + 1 != calls.len() {
                    return Ok(RuntimeValue::Undef);
                }
                continue;
            }

            let next_call = calls.get(index + 1);
            current = self.eval_receiver_dynamic_value_chain_call(
                current,
                call,
                next_call,
                index + 1 == calls.len(),
                ctx,
                rule_label,
            )?;
        }

        Ok(current)
    }

    fn eval_receiver_with_trailing_block_call(
        &self,
        current: RuntimeValue,
        call: &linkedspec_core::expr::FluentCall,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        use linkedspec_core::expr::Expr;

        if Self::is_tree_traversal_receiver_method(&call.method) {
            return self.eval_tree_receiver_trailing_block_call(current, call, ctx, rule_label);
        }

        if call.args.len() != 1 {
            return Err(format!(
                "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:with: receiver `.with() {{ ... }}` expects no parenthesized arguments in rule '{rule_label}'"
            ));
        }
        let Expr::BlockValue { block } = call.args[0].value() else {
            return Err(format!(
                "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:with: receiver `.with()` requires a trailing block argument in rule '{rule_label}'"
            ));
        };

        let binding = ctx.enter_scoped_scalar_binding("value", current);
        let result = self.eval_block_value(block, ctx, rule_label);
        ctx.exit_scoped_variable_binding(binding);
        result
    }

    fn eval_tree_receiver_trailing_block_call(
        &self,
        current: RuntimeValue,
        call: &linkedspec_core::expr::FluentCall,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        use linkedspec_core::expr::Expr;

        let method = call.method.as_str();
        let Some(block_arg) = call.args.last() else {
            return Err(Self::tree_receiver_malformed_message(method, rule_label));
        };
        let Expr::BlockValue { block } = block_arg.value() else {
            return Err(Self::tree_receiver_malformed_message(method, rule_label));
        };

        match method {
            "walk_leaves" | "map_leaves" if call.args.len() != 1 => {
                return Err(Self::tree_receiver_malformed_message(method, rule_label));
            }
            "reduce_leaves" if call.args.len() != 2 => {
                return Err(Self::tree_receiver_malformed_message(method, rule_label));
            }
            "walk_leaves" | "map_leaves" | "reduce_leaves" => {}
            _ => return Ok(RuntimeValue::Undef),
        }

        match current {
            RuntimeValue::Hash(entries) => match method {
                "walk_leaves" => {
                    let mut path = Vec::new();
                    self.walk_hash_tree_entries(&entries, &mut path, block, ctx, rule_label)?;
                    Ok(RuntimeValue::Hash(entries))
                }
                "map_leaves" => {
                    let mut path = Vec::new();
                    let mapped =
                        self.map_hash_tree_entries(&entries, &mut path, block, ctx, rule_label)?;
                    Ok(RuntimeValue::Hash(mapped))
                }
                "reduce_leaves" => {
                    let mut acc = self.eval_expr(call.args[0].value(), ctx, rule_label)?;
                    let mut path = Vec::new();
                    self.reduce_hash_tree_entries(
                        &entries, &mut path, block, &mut acc, ctx, rule_label,
                    )?;
                    Ok(acc)
                }
                _ => Ok(RuntimeValue::Undef),
            },
            RuntimeValue::Array(items) => match method {
                "walk_leaves" => {
                    let mut path = Vec::new();
                    self.walk_array_tree_items(&items, &mut path, block, ctx, rule_label)?;
                    Ok(RuntimeValue::Array(items))
                }
                "map_leaves" => {
                    let mut path = Vec::new();
                    let mapped =
                        self.map_array_tree_items(&items, &mut path, block, ctx, rule_label)?;
                    Ok(RuntimeValue::Array(mapped))
                }
                "reduce_leaves" => {
                    let mut acc = self.eval_expr(call.args[0].value(), ctx, rule_label)?;
                    let mut path = Vec::new();
                    self.reduce_array_tree_items(
                        &items, &mut path, block, &mut acc, ctx, rule_label,
                    )?;
                    Ok(acc)
                }
                _ => Ok(RuntimeValue::Undef),
            },
            _ => Ok(RuntimeValue::Undef),
        }
    }

    fn tree_receiver_malformed_message(method: &str, rule_label: &str) -> String {
        let signature = match method {
            "reduce_leaves" => ".reduce_leaves(initial) { ... }",
            "walk_leaves" => ".walk_leaves() { ... }",
            "map_leaves" => ".map_leaves() { ... }",
            _ => ".<tree-traversal-method>() { ... }",
        };
        format!(
            "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:{method}: receiver `{signature}` requires the accepted tree traversal trailing-block arity in rule '{rule_label}'"
        )
    }

    fn sorted_hash_tree_entries(entries: &[(String, RuntimeValue)]) -> Vec<(String, RuntimeValue)> {
        let mut sorted = entries.to_vec();
        sorted.sort_by(|(left, _), (right, _)| left.cmp(right));
        sorted
    }

    fn walk_hash_tree_entries(
        &self,
        entries: &[(String, RuntimeValue)],
        path: &mut Vec<String>,
        block: &CodeBlock,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<(), String> {
        for (key, value) in Self::sorted_hash_tree_entries(entries) {
            path.push(key.clone());
            let result = match value {
                RuntimeValue::Hash(child_entries) => {
                    self.walk_hash_tree_entries(&child_entries, path, block, ctx, rule_label)
                }
                leaf => self
                    .eval_hash_tree_leaf_block(block, leaf, &key, path, None, ctx, rule_label)
                    .map(|_| ()),
            };
            path.pop();
            result?;
        }
        Ok(())
    }

    fn map_hash_tree_entries(
        &self,
        entries: &[(String, RuntimeValue)],
        path: &mut Vec<String>,
        block: &CodeBlock,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<Vec<(String, RuntimeValue)>, String> {
        let mut mapped = Vec::new();
        for (key, value) in Self::sorted_hash_tree_entries(entries) {
            path.push(key.clone());
            let next_value = match value {
                RuntimeValue::Hash(child_entries) => self
                    .map_hash_tree_entries(&child_entries, path, block, ctx, rule_label)
                    .map(RuntimeValue::Hash),
                leaf => {
                    self.eval_hash_tree_leaf_block(block, leaf, &key, path, None, ctx, rule_label)
                }
            };
            path.pop();
            mapped.push((key, next_value?));
        }
        Ok(mapped)
    }

    fn reduce_hash_tree_entries(
        &self,
        entries: &[(String, RuntimeValue)],
        path: &mut Vec<String>,
        block: &CodeBlock,
        acc: &mut RuntimeValue,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<(), String> {
        for (key, value) in Self::sorted_hash_tree_entries(entries) {
            path.push(key.clone());
            let result = match value {
                RuntimeValue::Hash(child_entries) => {
                    self.reduce_hash_tree_entries(&child_entries, path, block, acc, ctx, rule_label)
                }
                leaf => {
                    *acc = self.eval_hash_tree_leaf_block(
                        block,
                        leaf,
                        &key,
                        path,
                        Some(acc.clone()),
                        ctx,
                        rule_label,
                    )?;
                    Ok(())
                }
            };
            path.pop();
            result?;
        }
        Ok(())
    }

    fn eval_hash_tree_leaf_block(
        &self,
        block: &CodeBlock,
        value: RuntimeValue,
        key: &str,
        path: &[String],
        acc: Option<RuntimeValue>,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        let mut bindings = Vec::new();
        if let Some(acc_value) = acc {
            bindings.push(ctx.enter_scoped_scalar_binding("acc", acc_value));
        }
        bindings.push(ctx.enter_scoped_scalar_binding("value", value));
        bindings
            .push(ctx.enter_scoped_scalar_binding("key", RuntimeValue::Scalar(key.to_string())));
        bindings.push(
            ctx.enter_scoped_scalar_binding(
                "path",
                RuntimeValue::Array(
                    path.iter()
                        .map(|part| RuntimeValue::Scalar(part.clone()))
                        .collect(),
                ),
            ),
        );
        bindings.push(
            ctx.enter_scoped_scalar_binding("depth", RuntimeValue::Number(path.len() as f64)),
        );

        let result = self.eval_block_value(block, ctx, rule_label);
        while let Some(binding) = bindings.pop() {
            ctx.exit_scoped_variable_binding(binding);
        }
        result
    }

    fn walk_array_tree_items(
        &self,
        items: &[RuntimeValue],
        path: &mut Vec<usize>,
        block: &CodeBlock,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<(), String> {
        for (index, value) in items.iter().enumerate() {
            path.push(index);
            let result = match value {
                RuntimeValue::Array(child_items) => {
                    self.walk_array_tree_items(child_items, path, block, ctx, rule_label)
                }
                leaf => self
                    .eval_array_tree_leaf_block(
                        block,
                        leaf.clone(),
                        index,
                        path,
                        None,
                        ctx,
                        rule_label,
                    )
                    .map(|_| ()),
            };
            path.pop();
            result?;
        }
        Ok(())
    }

    fn map_array_tree_items(
        &self,
        items: &[RuntimeValue],
        path: &mut Vec<usize>,
        block: &CodeBlock,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<Vec<RuntimeValue>, String> {
        let mut mapped = Vec::new();
        for (index, value) in items.iter().enumerate() {
            path.push(index);
            let next_value = match value {
                RuntimeValue::Array(child_items) => self
                    .map_array_tree_items(child_items, path, block, ctx, rule_label)
                    .map(RuntimeValue::Array),
                leaf => self.eval_array_tree_leaf_block(
                    block,
                    leaf.clone(),
                    index,
                    path,
                    None,
                    ctx,
                    rule_label,
                ),
            };
            path.pop();
            mapped.push(next_value?);
        }
        Ok(mapped)
    }

    fn reduce_array_tree_items(
        &self,
        items: &[RuntimeValue],
        path: &mut Vec<usize>,
        block: &CodeBlock,
        acc: &mut RuntimeValue,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<(), String> {
        for (index, value) in items.iter().enumerate() {
            path.push(index);
            let result = match value {
                RuntimeValue::Array(child_items) => {
                    self.reduce_array_tree_items(child_items, path, block, acc, ctx, rule_label)
                }
                leaf => {
                    *acc = self.eval_array_tree_leaf_block(
                        block,
                        leaf.clone(),
                        index,
                        path,
                        Some(acc.clone()),
                        ctx,
                        rule_label,
                    )?;
                    Ok(())
                }
            };
            path.pop();
            result?;
        }
        Ok(())
    }

    fn eval_array_tree_leaf_block(
        &self,
        block: &CodeBlock,
        value: RuntimeValue,
        index: usize,
        path: &[usize],
        acc: Option<RuntimeValue>,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        let mut bindings = Vec::new();
        if let Some(acc_value) = acc {
            bindings.push(ctx.enter_scoped_scalar_binding("acc", acc_value));
        }
        bindings.push(ctx.enter_scoped_scalar_binding("value", value));
        bindings.push(ctx.enter_scoped_scalar_binding("index", RuntimeValue::Number(index as f64)));
        bindings.push(
            ctx.enter_scoped_scalar_binding(
                "path",
                RuntimeValue::Array(
                    path.iter()
                        .map(|part| RuntimeValue::Number(*part as f64))
                        .collect(),
                ),
            ),
        );
        bindings.push(
            ctx.enter_scoped_scalar_binding("depth", RuntimeValue::Number(path.len() as f64)),
        );

        let result = self.eval_block_value(block, ctx, rule_label);
        while let Some(binding) = bindings.pop() {
            ctx.exit_scoped_variable_binding(binding);
        }
        result
    }

    fn eval_receiver_dynamic_value_chain_call(
        &self,
        current: RuntimeValue,
        call: &linkedspec_core::expr::FluentCall,
        next_call: Option<&linkedspec_core::expr::FluentCall>,
        is_last: bool,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        let method = call.method.as_str();

        if method == "copy" {
            if matches!(current, RuntimeValue::Hash(_))
                || next_call
                    .is_some_and(|next| Self::is_hash_receiver_value_chain_method(&next.method))
            {
                return self.eval_hash_receiver_dynamic_value_call(
                    current, call, is_last, ctx, rule_label,
                );
            }
            return self
                .eval_array_receiver_dynamic_value_call(current, call, is_last, ctx, rule_label);
        }

        if Self::is_hash_receiver_value_chain_method(method) {
            return self
                .eval_hash_receiver_dynamic_value_call(current, call, is_last, ctx, rule_label);
        }
        if Self::is_array_receiver_value_chain_method(method)
            && (!matches!(method, "min" | "max") || matches!(current, RuntimeValue::Array(_)))
        {
            return self
                .eval_array_receiver_dynamic_value_call(current, call, is_last, ctx, rule_label);
        }
        if Self::is_string_receiver_value_chain_method(method) {
            return self
                .eval_string_receiver_dynamic_value_call(current, call, is_last, ctx, rule_label);
        }
        if Self::is_number_receiver_value_chain_method(method) {
            return self
                .eval_number_receiver_dynamic_value_call(current, call, is_last, ctx, rule_label);
        }

        Ok(RuntimeValue::Undef)
    }

    fn receiver_call_args(
        &self,
        current: RuntimeValue,
        call: &linkedspec_core::expr::FluentCall,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<(Vec<linkedspec_core::expr::Arg>, Vec<RuntimeValue>), String> {
        use linkedspec_core::expr::{Arg, Expr};

        let evaluated_call_args: Vec<RuntimeValue> = call
            .args
            .iter()
            .map(|arg| self.eval_expr(arg.value(), ctx, rule_label))
            .collect::<Result<Vec<_>, _>>()?;

        let receiver_arg = Arg::Positional(Expr::Undef);
        if call.method == "join_values" {
            let mut raw = call.args.clone();
            raw.push(receiver_arg);
            let mut vals = evaluated_call_args;
            vals.push(current);
            return Ok((raw, vals));
        }

        let mut raw = Vec::with_capacity(call.args.len() + 1);
        raw.push(receiver_arg);
        raw.extend(call.args.clone());
        let mut vals = Vec::with_capacity(evaluated_call_args.len() + 1);
        vals.push(current);
        vals.extend(evaluated_call_args);
        Ok((raw, vals))
    }

    fn eval_array_receiver_dynamic_value_call(
        &self,
        current: RuntimeValue,
        call: &linkedspec_core::expr::FluentCall,
        is_last: bool,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        if Self::is_statement_only_array_end_mutation_method(&call.method)
            || !Self::is_array_receiver_value_chain_method(&call.method)
        {
            return Ok(RuntimeValue::Undef);
        }

        let (raw_args, evaluated) = self.receiver_call_args(current, call, ctx, rule_label)?;
        let next =
            self.call_helper_with_args(&call.method, &raw_args, &evaluated, ctx, rule_label)?;
        if !Self::is_array_receiver_array_returning_method(&call.method) && !is_last {
            return Ok(RuntimeValue::Undef);
        }
        Ok(next)
    }

    fn eval_hash_receiver_dynamic_value_call(
        &self,
        current: RuntimeValue,
        call: &linkedspec_core::expr::FluentCall,
        is_last: bool,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        if !Self::is_hash_receiver_value_chain_method(&call.method) {
            return Ok(RuntimeValue::Undef);
        }

        let (raw_args, evaluated) = self.receiver_call_args(current, call, ctx, rule_label)?;
        let next =
            self.call_helper_with_args(&call.method, &raw_args, &evaluated, ctx, rule_label)?;
        if Self::is_hash_receiver_terminal_method(&call.method) && !is_last {
            return Ok(RuntimeValue::Undef);
        }
        Ok(next)
    }

    fn eval_string_receiver_dynamic_value_call(
        &self,
        current: RuntimeValue,
        call: &linkedspec_core::expr::FluentCall,
        is_last: bool,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        if !Self::is_string_receiver_value_chain_method(&call.method) {
            return Ok(RuntimeValue::Undef);
        }

        let (raw_args, evaluated) = self.receiver_call_args(current, call, ctx, rule_label)?;
        let next =
            self.call_helper_with_args(&call.method, &raw_args, &evaluated, ctx, rule_label)?;
        if Self::is_string_receiver_terminal_method(&call.method) && !is_last {
            return Ok(RuntimeValue::Undef);
        }
        Ok(next)
    }

    fn eval_number_receiver_dynamic_value_call(
        &self,
        current: RuntimeValue,
        call: &linkedspec_core::expr::FluentCall,
        is_last: bool,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        use linkedspec_core::expr::{Arg, Expr};

        if !Self::is_number_receiver_value_chain_method(&call.method) {
            return Ok(RuntimeValue::Undef);
        }
        let valid_arity = match call.method.as_str() {
            "abs" | "floor" | "ceil" | "round" => call.args.is_empty(),
            "sub" | "div" | "mod" | "eq" | "ne" | "gt" | "ge" | "lt" | "le" => call.args.len() == 1,
            "clamp" => call.args.len() == 2,
            "add" | "mul" | "min" | "max" => !call.args.is_empty(),
            _ => false,
        };
        if !valid_arity {
            return Ok(RuntimeValue::Undef);
        }

        let Some(helper_name) = Self::number_receiver_helper_name(&call.method) else {
            return Ok(RuntimeValue::Undef);
        };
        let evaluated_call_args: Vec<RuntimeValue> = call
            .args
            .iter()
            .map(|arg| self.eval_expr(arg.value(), ctx, rule_label))
            .collect::<Result<Vec<_>, _>>()?;

        let mut raw_args = Vec::with_capacity(call.args.len() + 1);
        raw_args.push(Arg::Positional(Expr::Undef));
        raw_args.extend(call.args.clone());
        let mut evaluated = Vec::with_capacity(evaluated_call_args.len() + 1);
        evaluated.push(current);
        evaluated.extend(evaluated_call_args);

        let next =
            self.call_helper_with_args(helper_name, &raw_args, &evaluated, ctx, rule_label)?;
        if Self::is_number_receiver_terminal_method(&call.method) && !is_last {
            return Ok(RuntimeValue::Undef);
        }
        Ok(next)
    }

    fn eval_array_receiver_value_chain(
        &self,
        receiver: &linkedspec_core::expr::Expr,
        calls: &[linkedspec_core::expr::FluentCall],
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        use linkedspec_core::expr::{Arg, Expr};

        #[derive(Clone, Copy, Eq, PartialEq)]
        enum ReceiverFamily {
            Array,
            Terminal,
        }

        let mut current = match receiver {
            Expr::Variable { name } => Self::scalar_held_array_snapshot(ctx, name)
                .map(RuntimeValue::Array)
                .unwrap_or_else(|| RuntimeValue::Array(ctx.array_snapshot(name))),
            Expr::Call { name, args } if name == "array" && args.len() == 1 => match &args[0] {
                Arg::Positional(Expr::Variable { name }) => {
                    Self::scalar_held_array_snapshot(ctx, name)
                        .map(RuntimeValue::Array)
                        .unwrap_or_else(|| RuntimeValue::Array(ctx.array_snapshot(name)))
                }
                _ => self.eval_expr(receiver, ctx, rule_label)?,
            },
            _ => self.eval_expr(receiver, ctx, rule_label)?,
        };
        let mut family = ReceiverFamily::Array;

        for (index, call) in calls.iter().enumerate() {
            if family == ReceiverFamily::Terminal {
                return Ok(RuntimeValue::Undef);
            }
            if Self::is_statement_only_array_end_mutation_method(&call.method)
                || !Self::is_array_receiver_value_chain_method(&call.method)
            {
                return Ok(RuntimeValue::Undef);
            }

            let evaluated_call_args: Vec<RuntimeValue> = call
                .args
                .iter()
                .map(|arg| self.eval_expr(arg.value(), ctx, rule_label))
                .collect::<Result<Vec<_>, _>>()?;

            let receiver_arg = Arg::Positional(Expr::Undef);
            let (raw_args, evaluated) = if call.method == "join_values" {
                let mut raw = call.args.clone();
                raw.push(receiver_arg);
                let mut vals = evaluated_call_args;
                vals.push(current);
                (raw, vals)
            } else {
                let mut raw = Vec::with_capacity(call.args.len() + 1);
                raw.push(receiver_arg);
                raw.extend(call.args.clone());
                let mut vals = Vec::with_capacity(evaluated_call_args.len() + 1);
                vals.push(current);
                vals.extend(evaluated_call_args);
                (raw, vals)
            };

            current =
                self.call_helper_with_args(&call.method, &raw_args, &evaluated, ctx, rule_label)?;
            family = match call.method.as_str() {
                "copy" | "sorted" | "reversed" | "take" | "take_last" | "drop_front"
                | "drop_back" | "slice" | "concat_arrays" | "split_each" | "trim_each"
                | "filter_nonempty" | "lowercase_each" | "uppercase_each" | "uniq"
                | "filter_match" => ReceiverFamily::Array,
                _ => {
                    if index + 1 != calls.len() {
                        return Ok(RuntimeValue::Undef);
                    }
                    ReceiverFamily::Terminal
                }
            };
        }

        Ok(current)
    }

    fn eval_hash_receiver_value_chain(
        &self,
        receiver: &linkedspec_core::expr::Expr,
        calls: &[linkedspec_core::expr::FluentCall],
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        use linkedspec_core::expr::{Arg, Expr};

        #[derive(Clone, Copy, Eq, PartialEq)]
        enum ReceiverFamily {
            Hash,
            Array,
            Terminal,
        }

        let mut current = match receiver {
            Expr::Variable { name } => Self::scalar_held_hash_snapshot(ctx, name)
                .map(RuntimeValue::Hash)
                .unwrap_or_else(|| RuntimeValue::Hash(ctx.hash_snapshot(name))),
            Expr::Call { name, args } if name == "hash" && args.len() == 1 => match &args[0] {
                Arg::Positional(Expr::Variable { name }) => {
                    Self::scalar_held_hash_snapshot(ctx, name)
                        .map(RuntimeValue::Hash)
                        .unwrap_or_else(|| RuntimeValue::Hash(ctx.hash_snapshot(name)))
                }
                _ => self.eval_expr(receiver, ctx, rule_label)?,
            },
            _ => self.eval_expr(receiver, ctx, rule_label)?,
        };
        let mut family = ReceiverFamily::Hash;

        for (index, call) in calls.iter().enumerate() {
            if family == ReceiverFamily::Terminal {
                return Ok(RuntimeValue::Undef);
            }

            let evaluated_call_args: Vec<RuntimeValue> = call
                .args
                .iter()
                .map(|arg| self.eval_expr(arg.value(), ctx, rule_label))
                .collect::<Result<Vec<_>, _>>()?;

            let receiver_arg = Arg::Positional(Expr::Undef);
            let (raw_args, evaluated) =
                if family == ReceiverFamily::Array && call.method == "join_values" {
                    let mut raw = call.args.clone();
                    raw.push(receiver_arg);
                    let mut vals = evaluated_call_args;
                    vals.push(current);
                    (raw, vals)
                } else {
                    let mut raw = Vec::with_capacity(call.args.len() + 1);
                    raw.push(receiver_arg);
                    raw.extend(call.args.clone());
                    let mut vals = Vec::with_capacity(evaluated_call_args.len() + 1);
                    vals.push(current);
                    vals.extend(evaluated_call_args);
                    (raw, vals)
                };

            match family {
                ReceiverFamily::Hash => {
                    if !Self::is_hash_receiver_value_chain_method(&call.method) {
                        return Ok(RuntimeValue::Undef);
                    }
                    current = self.call_helper_with_args(
                        &call.method,
                        &raw_args,
                        &evaluated,
                        ctx,
                        rule_label,
                    )?;
                    if Self::is_hash_receiver_hash_returning_method(&call.method) {
                        family = ReceiverFamily::Hash;
                    } else if Self::is_hash_receiver_array_returning_method(&call.method) {
                        family = ReceiverFamily::Array;
                    } else {
                        if index + 1 != calls.len() {
                            return Ok(RuntimeValue::Undef);
                        }
                        family = ReceiverFamily::Terminal;
                    }
                }
                ReceiverFamily::Array => {
                    if Self::is_statement_only_array_end_mutation_method(&call.method)
                        || !Self::is_array_receiver_value_chain_method(&call.method)
                    {
                        return Ok(RuntimeValue::Undef);
                    }
                    current = self.call_helper_with_args(
                        &call.method,
                        &raw_args,
                        &evaluated,
                        ctx,
                        rule_label,
                    )?;
                    family = match call.method.as_str() {
                        "copy" | "sorted" | "reversed" | "take" | "take_last" | "drop_front"
                        | "drop_back" | "slice" | "concat_arrays" | "split_each" | "trim_each"
                        | "filter_nonempty" | "lowercase_each" | "uppercase_each" | "uniq"
                        | "filter_match" => ReceiverFamily::Array,
                        "sum" | "avg" | "median" | "range" | "min" | "max"
                            if index + 1 != calls.len() =>
                        {
                            return Ok(RuntimeValue::Undef);
                        }
                        _ => ReceiverFamily::Terminal,
                    };
                }
                ReceiverFamily::Terminal => return Ok(RuntimeValue::Undef),
            }
        }

        Ok(current)
    }

    fn eval_string_receiver_value_chain(
        &self,
        receiver: &linkedspec_core::expr::Expr,
        calls: &[linkedspec_core::expr::FluentCall],
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        use linkedspec_core::expr::{Arg, Expr};

        #[derive(Clone, Copy, Eq, PartialEq)]
        enum ReceiverFamily {
            String,
            Array,
            Terminal,
        }

        let mut current = self.eval_expr(receiver, ctx, rule_label)?;
        let mut family = ReceiverFamily::String;

        for (index, call) in calls.iter().enumerate() {
            if family == ReceiverFamily::Terminal {
                return Ok(RuntimeValue::Undef);
            }

            let evaluated_call_args: Vec<RuntimeValue> = call
                .args
                .iter()
                .map(|arg| self.eval_expr(arg.value(), ctx, rule_label))
                .collect::<Result<Vec<_>, _>>()?;

            let receiver_arg = Arg::Positional(Expr::Undef);
            let (raw_args, evaluated) =
                if family == ReceiverFamily::Array && call.method == "join_values" {
                    let mut raw = call.args.clone();
                    raw.push(receiver_arg);
                    let mut vals = evaluated_call_args;
                    vals.push(current);
                    (raw, vals)
                } else {
                    let mut raw = Vec::with_capacity(call.args.len() + 1);
                    raw.push(receiver_arg);
                    raw.extend(call.args.clone());
                    let mut vals = Vec::with_capacity(evaluated_call_args.len() + 1);
                    vals.push(current);
                    vals.extend(evaluated_call_args);
                    (raw, vals)
                };

            match family {
                ReceiverFamily::String => {
                    if !Self::is_string_receiver_value_chain_method(&call.method) {
                        return Ok(RuntimeValue::Undef);
                    }
                    current = self.call_helper_with_args(
                        &call.method,
                        &raw_args,
                        &evaluated,
                        ctx,
                        rule_label,
                    )?;
                    if Self::is_string_receiver_string_returning_method(&call.method) {
                        family = ReceiverFamily::String;
                    } else if Self::is_string_receiver_array_returning_method(&call.method) {
                        family = ReceiverFamily::Array;
                    } else {
                        if index + 1 != calls.len() {
                            return Ok(RuntimeValue::Undef);
                        }
                        family = ReceiverFamily::Terminal;
                    }
                }
                ReceiverFamily::Array => {
                    if Self::is_statement_only_array_end_mutation_method(&call.method)
                        || !Self::is_array_receiver_value_chain_method(&call.method)
                    {
                        return Ok(RuntimeValue::Undef);
                    }
                    current = self.call_helper_with_args(
                        &call.method,
                        &raw_args,
                        &evaluated,
                        ctx,
                        rule_label,
                    )?;
                    family = match call.method.as_str() {
                        "copy" | "sorted" | "reversed" | "take" | "take_last" | "drop_front"
                        | "drop_back" | "slice" | "concat_arrays" | "split_each" | "trim_each"
                        | "filter_nonempty" | "lowercase_each" | "uppercase_each" | "uniq"
                        | "filter_match" => ReceiverFamily::Array,
                        "sum" | "avg" | "median" | "range" | "min" | "max"
                            if index + 1 != calls.len() =>
                        {
                            return Ok(RuntimeValue::Undef);
                        }
                        _ => ReceiverFamily::Terminal,
                    };
                }
                ReceiverFamily::Terminal => return Ok(RuntimeValue::Undef),
            }
        }

        Ok(current)
    }

    fn eval_number_receiver_value_chain(
        &self,
        receiver: &linkedspec_core::expr::Expr,
        calls: &[linkedspec_core::expr::FluentCall],
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        use linkedspec_core::expr::{Arg, Expr};

        #[derive(Clone, Copy, Eq, PartialEq)]
        enum ReceiverFamily {
            Number,
            Terminal,
        }

        let mut current = self.eval_expr(receiver, ctx, rule_label)?;
        let mut family = ReceiverFamily::Number;

        for (index, call) in calls.iter().enumerate() {
            if family == ReceiverFamily::Terminal {
                return Ok(RuntimeValue::Undef);
            }
            if !Self::is_number_receiver_value_chain_method(&call.method) {
                return Ok(RuntimeValue::Undef);
            }

            let valid_arity = match call.method.as_str() {
                "abs" | "floor" | "ceil" | "round" => call.args.is_empty(),
                "sub" | "div" | "mod" | "eq" | "ne" | "gt" | "ge" | "lt" | "le" => {
                    call.args.len() == 1
                }
                "clamp" => call.args.len() == 2,
                "add" | "mul" | "min" | "max" => !call.args.is_empty(),
                _ => false,
            };
            if !valid_arity {
                return Ok(RuntimeValue::Undef);
            }

            let helper_name = match Self::number_receiver_helper_name(&call.method) {
                Some(name) => name,
                None => return Ok(RuntimeValue::Undef),
            };
            let evaluated_call_args: Vec<RuntimeValue> = call
                .args
                .iter()
                .map(|arg| self.eval_expr(arg.value(), ctx, rule_label))
                .collect::<Result<Vec<_>, _>>()?;

            let mut raw_args = Vec::with_capacity(call.args.len() + 1);
            raw_args.push(Arg::Positional(Expr::Undef));
            raw_args.extend(call.args.clone());
            let mut evaluated = Vec::with_capacity(evaluated_call_args.len() + 1);
            evaluated.push(current);
            evaluated.extend(evaluated_call_args);

            current =
                self.call_helper_with_args(helper_name, &raw_args, &evaluated, ctx, rule_label)?;
            if Self::is_number_receiver_terminal_method(&call.method) {
                if index + 1 != calls.len() {
                    return Ok(RuntimeValue::Undef);
                }
                family = ReceiverFamily::Terminal;
            } else {
                family = ReceiverFamily::Number;
            }
        }

        Ok(current)
    }

    fn eval_block_value(
        &self,
        block: &linkedspec_core::expr::CodeBlock,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        let Some(last_index) = block.statements.len().checked_sub(1) else {
            return Ok(RuntimeValue::Undef);
        };

        let mut if_stack: Vec<StatementIfFrame> = Vec::new();
        let mut switch_stack: Vec<StatementSwitchFrame> = Vec::new();
        for (index, stmt) in block.statements.iter().enumerate() {
            let parent_active = Self::statement_controls_active(&if_stack, &switch_stack);
            if self.handle_statement_if_control(
                &stmt.expr,
                &mut if_stack,
                parent_active,
                ctx,
                rule_label,
            )? {
                continue;
            }
            let parent_active = Self::statement_controls_active(&if_stack, &switch_stack);
            if self.handle_statement_switch_control(
                &stmt.expr,
                &mut switch_stack,
                parent_active,
                ctx,
                rule_label,
            )? {
                continue;
            }
            if !Self::statement_controls_active(&if_stack, &switch_stack) {
                continue;
            }
            if let Some(flow) = self.eval_value_while_loop(&stmt.expr, ctx, rule_label)? {
                match flow {
                    ValueBlockFlow::Continue => {
                        if index == last_index {
                            return Ok(RuntimeValue::Undef);
                        }
                        continue;
                    }
                    ValueBlockFlow::Returned(value) => return Ok(value),
                }
            }
            if let Some(payload) = Self::return_call_payload(&stmt.expr) {
                return match payload {
                    Some(value) => self.eval_expr(value, ctx, rule_label),
                    None => Ok(RuntimeValue::Undef),
                };
            }
            if index == last_index {
                return self.eval_block_final_expr(&stmt.expr, ctx, rule_label);
            }
            self.execute_block_statement_expr(&stmt.expr, ctx, rule_label)?;
        }
        Ok(RuntimeValue::Undef)
    }

    fn execute_value_block_side_effects(
        &self,
        block: &linkedspec_core::expr::CodeBlock,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<ValueBlockFlow, String> {
        let mut if_stack: Vec<StatementIfFrame> = Vec::new();
        let mut switch_stack: Vec<StatementSwitchFrame> = Vec::new();
        for stmt in &block.statements {
            let parent_active = Self::statement_controls_active(&if_stack, &switch_stack);
            if self.handle_statement_if_control(
                &stmt.expr,
                &mut if_stack,
                parent_active,
                ctx,
                rule_label,
            )? {
                continue;
            }
            let parent_active = Self::statement_controls_active(&if_stack, &switch_stack);
            if self.handle_statement_switch_control(
                &stmt.expr,
                &mut switch_stack,
                parent_active,
                ctx,
                rule_label,
            )? {
                continue;
            }
            if !Self::statement_controls_active(&if_stack, &switch_stack) {
                continue;
            }
            if let Some(flow) = self.eval_value_while_loop(&stmt.expr, ctx, rule_label)? {
                match flow {
                    ValueBlockFlow::Continue => continue,
                    ValueBlockFlow::Returned(value) => return Ok(ValueBlockFlow::Returned(value)),
                }
            }
            if let Some(payload) = Self::return_call_payload(&stmt.expr) {
                return match payload {
                    Some(value) => self
                        .eval_expr(value, ctx, rule_label)
                        .map(ValueBlockFlow::Returned),
                    None => Ok(ValueBlockFlow::Returned(RuntimeValue::Undef)),
                };
            }
            self.execute_block_statement_expr(&stmt.expr, ctx, rule_label)?;
        }
        Ok(ValueBlockFlow::Continue)
    }

    fn eval_value_while_loop(
        &self,
        expr: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<Option<ValueBlockFlow>, String> {
        let Some((condition, body)) = Self::while_call_parts(expr) else {
            return Ok(None);
        };

        let mut iterations = 0usize;
        while self.eval_expr(condition, ctx, rule_label)?.as_bool() {
            iterations += 1;
            if iterations > LINKEDSPEC_WHILE_ITERATION_LIMIT {
                return Err(Self::while_iteration_limit_message());
            }
            match self.execute_value_block_side_effects(body, ctx, rule_label)? {
                ValueBlockFlow::Continue => {}
                ValueBlockFlow::Returned(value) => {
                    return Ok(Some(ValueBlockFlow::Returned(value)));
                }
            }
        }

        Ok(Some(ValueBlockFlow::Continue))
    }

    fn eval_block_final_expr(
        &self,
        expr: &linkedspec_core::expr::Expr,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        use linkedspec_core::expr::Expr;
        if let Some(payload) = Self::return_call_payload(expr) {
            return match payload {
                Some(value) => self.eval_expr(value, ctx, rule_label),
                None => Ok(RuntimeValue::Undef),
            };
        }

        match expr {
            Expr::AssignScalar { name, value } => {
                let evaluated = self.eval_expr(value, ctx, rule_label)?;
                ctx.set_scalar(name, evaluated.clone());
                Ok(evaluated)
            }
            Expr::AssignArrayAppend { name, value } => {
                self.eval_array_append_expression(name, value, ctx, rule_label)
            }
            Expr::AssignHashIndex { name, key, value } => {
                self.eval_hash_index_assignment_expression(name, key, value, ctx, rule_label)
            }
            Expr::AssignNestedAccess {
                base,
                segments,
                value,
            } => self
                .eval_nested_access_assignment_expression(base, segments, value, ctx, rule_label),
            _ => self.eval_expr(expr, ctx, rule_label),
        }
    }

    fn return_call_payload(
        expr: &linkedspec_core::expr::Expr,
    ) -> Option<Option<&linkedspec_core::expr::Expr>> {
        use linkedspec_core::expr::Expr;
        match expr {
            Expr::Call { name, args } if name == "return" => {
                Some(args.first().map(|arg| arg.value()))
            }
            Expr::Call { name, args } if name == "return_undef" && args.is_empty() => Some(None),
            _ => None,
        }
    }

    fn while_call_parts(
        expr: &linkedspec_core::expr::Expr,
    ) -> Option<(
        &linkedspec_core::expr::Expr,
        &linkedspec_core::expr::CodeBlock,
    )> {
        use linkedspec_core::expr::Expr;
        let Expr::Call { name, args } = expr else {
            return None;
        };
        if name != "while" || args.len() != 2 {
            return None;
        }
        let Expr::BlockValue { block } = args[1].value() else {
            return None;
        };
        Some((args[0].value(), block))
    }

    fn eval_with_trailing_block(
        &self,
        raw_args: &[linkedspec_core::expr::Arg],
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        use linkedspec_core::expr::Expr;

        if raw_args.is_empty() || raw_args.len() > 2 {
            return Err(format!(
                "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:with: helper `with(...) {{ ... }}` expects zero or one value argument plus a trailing block in rule '{rule_label}'"
            ));
        }

        let Some(block_arg) = raw_args.last() else {
            unreachable!("raw_args.is_empty() was checked above");
        };
        let Expr::BlockValue { block } = block_arg.value() else {
            return Err(format!(
                "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:with: helper `with(...)` requires a trailing block argument in rule '{rule_label}'"
            ));
        };

        let scoped_value = if raw_args.len() == 2 {
            self.eval_expr(raw_args[0].value(), ctx, rule_label)?
        } else {
            RuntimeValue::Undef
        };
        let binding = ctx.enter_scoped_scalar_binding("value", scoped_value);
        let result = self.eval_block_value(block, ctx, rule_label);
        ctx.exit_scoped_variable_binding(binding);
        result
    }

    fn while_iteration_limit_message() -> String {
        format!(
            "LinkedSpec while iteration safety limit exceeded after {} iterations",
            LINKEDSPEC_WHILE_ITERATION_LIMIT
        )
    }

    /// Resolve a scalar target name from an evaluated value.
    ///
    /// A bare target name in scalar-target position names the working variable
    /// itself.
    fn resolve_scalar_target(
        &self,
        raw_args: &[linkedspec_core::expr::Arg],
        val: &RuntimeValue,
    ) -> String {
        use linkedspec_core::expr::{Arg, Expr};
        // SPEC-FORMAT-TERSE.1.2.1 Channel 1 (Rust parity, .1.2.2): a BARE
        // (un-wrapped) name in the scalar-target position (e.g. v = ...) IS
        // the working variable itself — mirrors the Perl reference's `^(\w+)$`
        // fallback in ValueExpr::_extract_scalar_symbol_name. The per-parse
        // RuntimeContext HashMap auto-vivifies on set_scalar, so it auto-exists
        // without a separate declaration step and never leaks across parses
        // (fresh ctx per execute).
        if let Some(Arg::Positional(Expr::Variable { name: var_name })) = raw_args.first() {
            return var_name.clone();
        }
        val.to_str()
    }

    /// Resolve an array target name from the first arg of a helper call.
    ///
    /// In Perl LinkedSpec, `array(results)` is a CONTAINER SPECIFICATION meaning
    /// "the array named results", not a constructor. When raw_arg is a `Call`
    /// with name `"array"` and one argument, extract the inner
    /// variable name. Falls back to the evaluated value's `to_str()`.
    fn resolve_array_target(
        &self,
        raw_args: &[linkedspec_core::expr::Arg],
        val: &RuntimeValue,
        allow_bare: bool,
    ) -> String {
        use linkedspec_core::expr::{Arg, Expr};
        // Check if the raw arg is `array(variable)`.
        if let Some(Arg::Positional(Expr::Call { name, args })) = raw_args.first() {
            if name == "array" && args.len() == 1 {
                if let Arg::Positional(Expr::Variable { name: var_name }) = &args[0] {
                    return var_name.clone();
                }
            }
        }
        // SPEC-FORMAT-TERSE.1.2.1 Channel 1 (Rust parity, .1.2.2): in a type-implying
        // array-TARGET position (`push`), a BARE (un-wrapped) name
        // IS the working array — mirrors the Perl reference's `^(\w+)$` fallback in
        // ValueExpr::_extract_array_symbol_name. SPEC-FORMAT-TERSE.1.2.3.2 extends
        // the same narrow aggregate-target interpretation to array snapshot reads
        // (array-first `copy(NAME)`). Scalar-like bare reads and bare direct-access
        // path atoms remain owned by later Channel 2 leaves.
        if let (true, Some(Arg::Positional(Expr::Variable { name: var_name }))) =
            (allow_bare, raw_args.first())
        {
            return var_name.clone();
        }
        val.to_str()
    }

    /// Resolve a hash target name from the first arg of a helper call.
    ///
    /// Mirrors `resolve_array_target` for hash-valued helpers: `hash(name)`
    /// names the runtime hash `name`, while constructor forms such as
    /// `hash("key", value)` stay value expressions handled by the `hash` helper.
    /// When `allow_bare` is true, `copy(hash(NAME))` may name the hash directly;
    /// scalar-like bare value reads stay outside this resolver.
    fn resolve_hash_target(
        &self,
        raw_args: &[linkedspec_core::expr::Arg],
        val: &RuntimeValue,
        allow_bare: bool,
    ) -> String {
        use linkedspec_core::expr::{Arg, Expr};
        if let Some(var_name) = raw_args.first().and_then(|arg| match arg {
            Arg::Positional(Expr::Call { name, args }) if name == "hash" && args.len() == 1 => {
                match &args[0] {
                    Arg::Positional(Expr::Variable { name }) => Some(name),
                    _ => None,
                }
            }
            _ => None,
        }) {
            return var_name.clone();
        }
        if let (true, Some(Arg::Positional(Expr::Variable { name: var_name }))) =
            (allow_bare, raw_args.first())
        {
            return var_name.clone();
        }
        val.to_str()
    }

    fn hash_consuming_arg(
        &self,
        raw_args: &[linkedspec_core::expr::Arg],
        args: &[RuntimeValue],
        index: usize,
        ctx: &RuntimeContext,
    ) -> RuntimeValue {
        use linkedspec_core::expr::{Arg, Expr};

        let evaluated = args.get(index).cloned().unwrap_or(RuntimeValue::Undef);
        if let Some(Arg::Positional(Expr::Variable { name })) = raw_args.get(index) {
            if let Some(values) = Self::scalar_held_hash_snapshot(ctx, name) {
                return RuntimeValue::Hash(values);
            }
            return RuntimeValue::Hash(ctx.hash_snapshot(name));
        }

        if matches!(evaluated, RuntimeValue::Hash(_)) {
            return evaluated;
        }

        evaluated
    }

    fn array_consuming_arg(
        &self,
        raw_args: &[linkedspec_core::expr::Arg],
        args: &[RuntimeValue],
        index: usize,
        ctx: &RuntimeContext,
    ) -> RuntimeValue {
        use linkedspec_core::expr::{Arg, Expr};

        let evaluated = args.get(index).cloned().unwrap_or(RuntimeValue::Undef);
        if let Some(Arg::Positional(Expr::Variable { name })) = raw_args.get(index) {
            if let Some(values) = Self::scalar_held_array_snapshot(ctx, name) {
                return RuntimeValue::Array(values);
            }
            return RuntimeValue::Array(ctx.array_snapshot(name));
        }

        if matches!(evaluated, RuntimeValue::Array(_)) {
            return evaluated;
        }

        evaluated
    }

    fn is_list_context_splice_arg(raw_arg: &linkedspec_core::expr::Arg) -> bool {
        use linkedspec_core::expr::{Arg, Expr};

        matches!(
            raw_arg,
            Arg::Positional(Expr::Call { name, .. })
                if matches!(name.as_str(), "flat" | "flat_array" | "flat_hash")
        )
    }

    fn is_hash_context_splice_arg(raw_arg: &linkedspec_core::expr::Arg) -> bool {
        use linkedspec_core::expr::{Arg, Expr};

        matches!(
            raw_arg,
            Arg::Positional(Expr::Call { name, .. })
                if matches!(name.as_str(), "flat" | "flat_hash")
        )
    }

    fn push_list_context_values(target: &mut Vec<RuntimeValue>, value: &RuntimeValue) {
        match value {
            RuntimeValue::Array(items) => target.extend(items.iter().cloned()),
            RuntimeValue::Hash(entries) => {
                for (key, item) in entries {
                    target.push(RuntimeValue::Scalar(key.clone()));
                    target.push(item.clone());
                }
            }
            other => target.push(other.clone()),
        }
    }

    /// Resolve a child rule name from the first arg of a `call(...)` helper.
    ///
    /// A bare `call(RuleName)` names the target rule directly — its evaluated
    /// value would be undef (a rule label is not a scalar variable), so the name
    /// must come from the raw AST. Falls back to the evaluated value's
    /// `to_str()` for the quoted form `call("RuleName")`.
    fn resolve_rule_name(
        &self,
        raw_args: &[linkedspec_core::expr::Arg],
        val: Option<&RuntimeValue>,
    ) -> String {
        self.resolve_rule_name_at(raw_args, val, 0)
    }

    fn resolve_rule_name_at(
        &self,
        raw_args: &[linkedspec_core::expr::Arg],
        val: Option<&RuntimeValue>,
        index: usize,
    ) -> String {
        use linkedspec_core::expr::{Arg, Expr};
        if let Some(Arg::Positional(Expr::Variable { name })) = raw_args.get(index) {
            return name.clone();
        }
        val.map(|v| v.to_str()).unwrap_or_default()
    }

    fn resolve_named_capture_key(
        raw_args: &[linkedspec_core::expr::Arg],
        args: &[RuntimeValue],
    ) -> Option<String> {
        use linkedspec_core::expr::{Arg, Expr};
        if let Some(Arg::Positional(Expr::Variable { name })) = raw_args.first() {
            return Some(name.clone());
        }
        args.first().map(RuntimeValue::to_str)
    }

    /// Dispatch a lazy-evaluation call (if/switch/while/elseif/else/case/default).
    ///
    /// These calls receive unevaluated arg AST nodes; the handler evaluates
    /// conditions and branch bodies lazily via `self.eval_expr()`.
    fn call_helper_lazy(
        &self,
        name: &str,
        args: &[linkedspec_core::expr::Arg],
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        ctx.trace_decision(
            "rust_runtime:engine:lazy_helper",
            true,
            format!("rule={rule_label} helper={name} arity={}", args.len()),
            TraceLevel::FULL,
        );
        let empty_vals: Vec<RuntimeValue> = Vec::new();
        self.call_helper(name, args, &empty_vals, ctx, rule_label)
    }

    /// Dispatch a helper call with keyword argument awareness.
    ///
    /// Extracts keyword arg names from the original `Arg` list and passes both
    /// original args and evaluated values to `call_helper`.
    fn call_helper_with_args(
        &self,
        name: &str,
        raw_args: &[linkedspec_core::expr::Arg],
        evaluated: &[RuntimeValue],
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        self.call_helper(name, raw_args, evaluated, ctx, rule_label)
    }

    /// Dispatch a helper call by name with original args and evaluated args.
    fn call_helper(
        &self,
        name: &str,
        raw_args: &[linkedspec_core::expr::Arg],
        args: &[RuntimeValue],
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        let name = Self::numeric_word_helper_name(name).unwrap_or(name);
        if Self::is_mark_capture_helper(name) {
            ctx.trace_mark(
                "rust_runtime:engine:mark_capture",
                format!(
                    "rule={rule_label} helper={name} arity={} pos={} match_start={} match_end={} capture_start={:?}",
                    args.len(),
                    ctx.pos,
                    ctx.match_start_byte,
                    ctx.match_end_byte,
                    ctx.capture_start
                ),
                TraceLevel::FULL,
            );
        }
        match name {
            "set" | "=" => {
                if args.len() >= 2 {
                    if let Some((kind, target)) =
                        Self::aggregate_wrapper_assignment_target(&raw_args[0], &args[1])
                    {
                        return Self::store_aggregate_assignment(
                            &target,
                            kind,
                            args[1].clone(),
                            ctx,
                        );
                    }
                    let target = self.resolve_scalar_target(raw_args, &args[0]);
                    ctx.set_scalar(&target, args[1].clone());
                    return Ok(args[1].clone());
                }
                Ok(RuntimeValue::Undef)
            }
            // ── Array constructors ──
            "array" => {
                // Container reference: `array(varname)` with single bare variable
                // returns the named array, not a constructed array.
                if args.len() == 1 && raw_args.len() == 1 {
                    if let linkedspec_core::expr::Arg::Positional(
                        linkedspec_core::expr::Expr::Variable { name: var_name },
                    ) = &raw_args[0]
                    {
                        if let Some(values) = Self::scalar_held_array_snapshot(ctx, var_name) {
                            return Ok(RuntimeValue::Array(values));
                        }
                        return Ok(RuntimeValue::Array(ctx.get_array(var_name)));
                    }
                }
                // General constructor: `array(val1, val2, ...)`. Explicit
                // flattening helpers are list-context splices in the Perl
                // lowering, so `array(flat_array(items))` opens `items` into
                // this constructor while `array(copy(items))` stays nested.
                let mut values = Vec::new();
                for (raw_arg, value) in raw_args.iter().zip(args.iter()) {
                    if Self::is_list_context_splice_arg(raw_arg) {
                        Self::push_list_context_values(&mut values, value);
                    } else {
                        values.push(value.clone());
                    }
                }
                Ok(RuntimeValue::Array(values))
            }
            "copy" => {
                if let Some(arg) = args.first() {
                    match arg {
                        RuntimeValue::Array(a) => Ok(RuntimeValue::Array(a.clone())),
                        RuntimeValue::Hash(h) => Ok(RuntimeValue::Hash(h.clone())),
                        _ => {
                            let arr_name = self.resolve_array_target(raw_args, arg, true);
                            if !arr_name.is_empty() {
                                if let Some(values) =
                                    Self::scalar_held_array_snapshot(ctx, &arr_name)
                                {
                                    return Ok(RuntimeValue::Array(values));
                                }
                                Ok(RuntimeValue::Array(ctx.array_snapshot(&arr_name)))
                            } else {
                                let hash_name = self.resolve_hash_target(raw_args, arg, true);
                                if !hash_name.is_empty() {
                                    if let Some(values) =
                                        Self::scalar_held_hash_snapshot(ctx, &hash_name)
                                    {
                                        return Ok(RuntimeValue::Hash(values));
                                    }
                                    Ok(RuntimeValue::Hash(ctx.hash_snapshot(&hash_name)))
                                } else {
                                    Ok(RuntimeValue::Array(Vec::new()))
                                }
                            }
                        }
                    }
                } else {
                    Ok(RuntimeValue::Array(Vec::new()))
                }
            }
            // ── Accumulator ──
            "push" => {
                if args.len() >= 2 {
                    let arr_name = self.resolve_array_target(raw_args, &args[0], true);
                    ctx.push_array_value(&arr_name, args[1].clone());
                }
                Ok(RuntimeValue::Undef)
            }
            "return" => {
                if let Some(val) = args.first() {
                    // Preserve the accumulator contract (execute() returns it)…
                    ctx.push_accumulator(val.clone());
                    // …and record this rule's return value so a parent can read
                    // it as `retv` after dispatch (Runtime Semantics §5.4).
                    ctx.set_return_value(val.clone());
                }
                Ok(RuntimeValue::Undef)
            }
            "return_undef" => {
                ctx.set_return_value(RuntimeValue::Undef);
                Ok(RuntimeValue::Undef)
            }
            "call" => {
                // `call(child)` evaluates to the child's return value, so
                // `retv = call(child)` captures it — the Perl
                // reference pattern (see specs/tablegrep.spec). The child rule
                // name comes from the raw arg (a bare label is not a scalar).
                let child = self.resolve_rule_name(raw_args, args.first());
                if !child.is_empty() {
                    ctx.trace_decision(
                        "rust_runtime:engine:helper_call_dispatch",
                        true,
                        format!("rule={rule_label} child={child} pos={}", ctx.pos),
                        TraceLevel::MEDIUM,
                    );
                    if let Some(value) = ctx.action_edge_call_result(&child) {
                        return Ok(value);
                    }
                    let child_retv = self.execute_child_rule(&child, 0, ctx)?;
                    return Ok(child_retv);
                }
                Ok(RuntimeValue::Undef)
            }
            // ── Scalar/string ──
            "cat" => {
                let result: String = args.iter().map(|a| a.to_str()).collect();
                Ok(RuntimeValue::Scalar(result))
            }
            "coalesce" => {
                for a in args {
                    if a.is_defined() && a.to_str() != "" {
                        return Ok(a.clone());
                    }
                }
                Ok(RuntimeValue::Undef)
            }
            "count" => {
                if let Some(arg) = args.first() {
                    Ok(RuntimeValue::Number(arg.len() as f64))
                } else {
                    Ok(RuntimeValue::Number(0.0))
                }
            }
            "first" => {
                if let RuntimeValue::Array(arr) = self.array_consuming_arg(raw_args, args, 0, ctx) {
                    Ok(arr.first().cloned().unwrap_or(RuntimeValue::Undef))
                } else if let Some(arg) = args.first() {
                    let arr_name = arg.to_str();
                    let arr = ctx.get_array(&arr_name);
                    Ok(arr.first().cloned().unwrap_or(RuntimeValue::Undef))
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "last" => {
                if let RuntimeValue::Array(arr) = self.array_consuming_arg(raw_args, args, 0, ctx) {
                    Ok(arr.last().cloned().unwrap_or(RuntimeValue::Undef))
                } else if let Some(arg) = args.first() {
                    let arr_name = arg.to_str();
                    let arr = ctx.get_array(&arr_name);
                    Ok(arr.last().cloned().unwrap_or(RuntimeValue::Undef))
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            // ── Entry/match ──
            "entry_text" => Ok(RuntimeValue::Scalar(
                span_text(&ctx.input, ctx.entry_start_byte, ctx.entry_end_byte).unwrap_or_default(),
            )),
            "entry_group" => {
                if let Some(arg) = args.first() {
                    let idx = arg.as_number().unwrap_or(0.0) as usize;
                    Ok(RuntimeValue::Scalar(
                        ctx.entry_groups.get(idx).cloned().unwrap_or_default(),
                    ))
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "entry_groups" => {
                let arr: Vec<RuntimeValue> = ctx
                    .entry_groups
                    .iter()
                    .map(|g| RuntimeValue::Scalar(g.clone()))
                    .collect();
                Ok(RuntimeValue::Array(arr))
            }
            // Named-capture readers for the ENTRY match — the regex capture that
            // triggered this rule's code (Helper Contract Catalog §8). They read
            // the populated `ctx.entry_named` map. `entry_named_map` is a retired
            // alias of `entry_map`: identical behavior, accepted for legacy specs.
            "entry_named" => Ok(match Self::resolve_named_capture_key(raw_args, args) {
                Some(name) => ctx
                    .entry_named
                    .get(&name)
                    .map(|v| RuntimeValue::Scalar(v.clone()))
                    .unwrap_or(RuntimeValue::Undef),
                None => RuntimeValue::Undef,
            }),
            "entry_has" => Ok(RuntimeValue::Number(
                if Self::resolve_named_capture_key(raw_args, args)
                    .map(|name| ctx.entry_named.contains_key(&name))
                    .unwrap_or(false)
                {
                    1.0
                } else {
                    0.0
                },
            )),
            "entry_map" | "entry_named_map" => Ok(named_map_to_hash(&ctx.entry_named)),
            "match_text" => Ok(if ctx.match_present {
                RuntimeValue::Scalar(
                    span_text(&ctx.input, ctx.match_start_byte, ctx.match_end_byte)
                        .unwrap_or_default(),
                )
            } else {
                RuntimeValue::Undef
            }),
            "exit_now" => {
                let status = args.first().and_then(|a| a.as_number()).unwrap_or(1.0) as i32;
                ctx.exit_status = Some(status);
                Err(format!("exit_now({status})"))
            }
            // `print` is handled by the consolidated `say | print | print_each`
            // arm below. (RUST-PARITY.5.4 removed earlier shadowing duplicates
            // so the more complete hash behavior remains in the current arms.)
            // ── String/array index ──
            "substr" | "regex_subst" => {
                if let Some((target, pattern_idx, replacement_idx, flags_idx)) =
                    regex_subst_call_parts(raw_args)
                {
                    let pattern = literal_or_value_arg_text(raw_args, args, pattern_idx);
                    let replacement = literal_or_value_arg_text(raw_args, args, replacement_idx);
                    let flags = regex_subst_flags_arg(raw_args, args, flags_idx);
                    let effective_pattern = regex_subst_pattern_with_flags(&pattern, &flags);
                    let re = rgx_core::Regex::compile(&effective_pattern).map_err(|e| {
                        format!(
                            "regex_subst({target}) in rule '{rule_label}' has invalid pattern /{pattern}/: {e}"
                        )
                    })?;
                    let current = ctx.get_scalar(&target).to_str();
                    let updated = if flags.contains('g') {
                        re.replace_all(&current, replacement.as_str()).into_owned()
                    } else {
                        re.replace(&current, replacement.as_str()).into_owned()
                    };
                    ctx.set_scalar(&target, RuntimeValue::Scalar(updated));
                    return Ok(RuntimeValue::Undef);
                }
                if name == "regex_subst" {
                    return Ok(RuntimeValue::Undef);
                }
                // Char-based (Perl `substr`): start/len are character offsets, so
                // byte-slicing would panic on a multibyte boundary and diverge.
                if args.len() >= 3 {
                    let s = args[0].to_str();
                    let start = args[1].as_number().unwrap_or(0.0) as usize;
                    let len = args[2].as_number().unwrap_or(0.0) as usize;
                    Ok(RuntimeValue::Scalar(char_substr(&s, start, len)))
                } else if args.len() == 2 {
                    let s = args[0].to_str();
                    let start = args[1].as_number().unwrap_or(0.0) as usize;
                    Ok(RuntimeValue::Scalar(char_substr_from(&s, start)))
                } else {
                    Ok(RuntimeValue::Scalar(
                        args.first().map(|a| a.to_str()).unwrap_or_default(),
                    ))
                }
            }
            "join_values" => {
                if args.len() >= 2 {
                    let delim = args[0].to_str();
                    let arr = &args[1];
                    let parts: Vec<String> = match arr {
                        RuntimeValue::Array(items) => items.iter().map(|v| v.to_str()).collect(),
                        _ => vec![arr.to_str()],
                    };
                    Ok(RuntimeValue::Scalar(parts.join(&delim)))
                } else {
                    Ok(RuntimeValue::Scalar(String::new()))
                }
            }
            "split" => {
                if let Some((target, source_idx, delimiter_idx)) =
                    split_statement_call_parts(raw_args)
                {
                    let source = args
                        .get(source_idx)
                        .map(RuntimeValue::to_str)
                        .unwrap_or_default();
                    let delimiter = args
                        .get(delimiter_idx)
                        .cloned()
                        .unwrap_or(RuntimeValue::Undef);
                    let parts = split_string_for_arg(&source, raw_args, delimiter_idx, &delimiter)?;
                    ctx.set_array(&target, parts);
                    return Ok(RuntimeValue::Undef);
                }
                if args.len() >= 2 {
                    let s = args[0].to_str();
                    Ok(RuntimeValue::Array(split_string_for_arg(
                        &s, raw_args, 1, &args[1],
                    )?))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "split_each" => {
                if let Some(arr) = args.first() {
                    match arr {
                        RuntimeValue::Array(items) => {
                            let delimiter = args.get(1).cloned().unwrap_or(RuntimeValue::Undef);
                            let mut result = Vec::new();
                            for item in items {
                                let value = item.to_str();
                                result
                                    .extend(split_string_for_arg(&value, raw_args, 1, &delimiter)?);
                            }
                            Ok(RuntimeValue::Array(result))
                        }
                        _ => Ok(RuntimeValue::Array(vec![])),
                    }
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "trim_each" | "lowercase_each" | "uppercase_each" => {
                if let Some(RuntimeValue::Array(items)) = args.first() {
                    let transformed: Vec<RuntimeValue> = items
                        .iter()
                        .map(|v| {
                            let s = v.to_str();
                            let s = match name {
                                "trim_each" => s.trim().to_string(),
                                "lowercase_each" => s.to_lowercase(),
                                "uppercase_each" => s.to_uppercase(),
                                _ => s,
                            };
                            RuntimeValue::Scalar(s)
                        })
                        .collect();
                    Ok(RuntimeValue::Array(transformed))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "filter_nonempty" => {
                if let Some(RuntimeValue::Array(items)) = args.first() {
                    Ok(RuntimeValue::Array(
                        items.iter().filter(|v| v.is_nonempty()).cloned().collect(),
                    ))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "filter_match" => {
                if let Some(RuntimeValue::Array(items)) = args.first() {
                    let pattern = args.get(1).map(|a| a.to_str()).unwrap_or_default();
                    let re = rgx_core::Regex::compile(&pattern);
                    match re {
                        Ok(re) => Ok(RuntimeValue::Array(
                            items
                                .iter()
                                .filter(|v| re.is_match(&v.to_str()))
                                .cloned()
                                .collect(),
                        )),
                        Err(e) => {
                            eprintln!(
                                "warning: filter_match: invalid regex '/{}/': {} — returning empty",
                                pattern, e
                            );
                            Ok(RuntimeValue::Array(vec![]))
                        }
                    }
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "uniq" => {
                if let Some(RuntimeValue::Array(items)) = args.first() {
                    let mut seen = std::collections::HashSet::new();
                    let uniq: Vec<RuntimeValue> = items
                        .iter()
                        .filter(|v| seen.insert(v.to_str()))
                        .cloned()
                        .collect();
                    Ok(RuntimeValue::Array(uniq))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "say" | "print" | "print_each" => {
                if name == "print_each" {
                    if let Some(RuntimeValue::Array(items)) = args.first() {
                        for item in items {
                            eprintln!("{}", item.to_str());
                        }
                    }
                } else {
                    for a in args {
                        eprintln!("{}", a.to_str());
                    }
                }
                Ok(RuntimeValue::Undef)
            }
            // ── Position/cursor ── (DSL-facing positions/lengths are char-based)
            "cursor_pos" => Ok(RuntimeValue::Number(
                byte_to_char_offset(&ctx.input, ctx.pos) as f64,
            )),
            "cursor_line" => {
                let (line, _) = line_col_at_byte_offset(&ctx.input, ctx.pos);
                Ok(RuntimeValue::Number(line as f64))
            }
            "cursor_col" => {
                let (_, col) = line_col_at_byte_offset(&ctx.input, ctx.pos);
                Ok(RuntimeValue::Number(col as f64))
            }
            "cursor_rest" => Ok(RuntimeValue::Scalar(ctx.remaining().to_string())),
            "cursor_rest_len" => Ok(RuntimeValue::Number(ctx.remaining().chars().count() as f64)),
            "input_text" => Ok(RuntimeValue::Scalar(ctx.input.clone())),
            "input_len" => Ok(RuntimeValue::Number(ctx.input.chars().count() as f64)),
            "input_slice" => {
                // start/width are char offsets (Perl parity); char-slice, no panic.
                if args.len() >= 2 {
                    let start = args[0].as_number().unwrap_or(0.0) as usize;
                    let width = args[1].as_number().unwrap_or(0.0) as usize;
                    Ok(RuntimeValue::Scalar(char_substr(&ctx.input, start, width)))
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "input_end_pos" => Ok(RuntimeValue::Number(ctx.input.chars().count() as f64)),
            // RUST-PARITY.5.5.2 — whole-input right-edge location, char-based, no stored mark.
            // Perl reference: `input_end_line()` lowers to `1 + (newline count over the whole
            // input)` (Contracts.pm INPUT_END_LINE_READ); `input_end_col()` lowers to the column
            // at `length($$STRING)` via `_build_column_read_expr` — char distance past the last
            // newline, or `length + 1` when the input has none. Newline counts are byte/char
            // identical, so line uses a plain `'\n'` count; the column is char-based.
            "input_end_line" => Ok(RuntimeValue::Number(
                (ctx.input.chars().filter(|&c| c == '\n').count() + 1) as f64,
            )),
            "input_end_col" => {
                let last_nl = ctx.input.rfind('\n').map(|i| i + 1).unwrap_or(0);
                let col = ctx.input[last_nl..].chars().count() + 1;
                Ok(RuntimeValue::Number(col as f64))
            }
            "start_capture_slice" => {
                ctx.capture_start = Some(ctx.pos);
                Ok(RuntimeValue::Undef)
            }
            "capture_slice" => {
                // RUST-PARITY.5.5.4: ends at the START of the current local match
                // (`ctx.match_start_byte`, Perl `$LSPOS - length $LMATCH`), not the
                // cursor as before this leaf — `capture_slice` is the anonymous
                // counterpart of the mark-based `capture_from` (.5.5.3), so the
                // captured text is everything between `capture_start` and the match.
                let start = ctx.capture_start.unwrap_or(0);
                Ok(span_text(&ctx.input, start, ctx.match_start_byte)
                    .map(RuntimeValue::Scalar)
                    .unwrap_or(RuntimeValue::Undef))
            }
            "capture_slice_len" => {
                let start = ctx.capture_start.unwrap_or(0);
                Ok(span_char_len(&ctx.input, start, ctx.match_start_byte)
                    .map(|n| RuntimeValue::Number(n as f64))
                    .unwrap_or(RuntimeValue::Undef))
            }
            "capture_slice_line" => {
                let start = ctx.capture_start.unwrap_or(0);
                let line = ctx.input[..start].chars().filter(|&c| c == '\n').count() + 1;
                Ok(RuntimeValue::Number(line as f64))
            }
            "capture_slice_pos" => Ok(RuntimeValue::Number(byte_to_char_offset(
                &ctx.input,
                ctx.capture_start.unwrap_or(0),
            ) as f64)),
            // ── RUST-PARITY.5.5.4: anonymous capture-slice family ──
            // These read the anonymous capture start `ctx.capture_start` (Perl
            // `$IPOS`, set by `start_capture_slice()`), not a named mark — the
            // anonymous counterparts of the mark-based `.5.5.3` family.
            // Authoritative contract: `perl/LinkedSpec/ActionIR/Contracts.pm`
            // ~366–656. Endpoints (byte offsets): the START of the current local
            // match (`$LSPOS - length $LMATCH` = `ctx.match_start_byte`) for
            // `capture_take`(+`_len`); the cursor (`pos` = `ctx.pos`) for
            // `_until_cursor`; end-of-input for `_rest`. `_take_*` advance
            // `capture_start` to the cursor (Perl `$IPOS = pos $$STRING`), or to
            // end-of-input for `_take_rest` (`$IPOS = length $$STRING`). Text is
            // the raw byte slice (correct chars); `_len` results are char counts
            // (.5.3). A degenerate (reversed / out-of-range) span yields `undef`
            // via span_text/span_char_len — panic-safe; the `_until_cursor`/`_rest`
            // Perl readers carry the same `defined`/`>=` guard, and `_take_*`
            // mutate only on a valid span (identical to Perl on every realistic
            // `capture_start ≤ match-start ≤ cursor ≤ end` input).
            "capture_slice_until_cursor" => {
                let start = ctx.capture_start.unwrap_or(0);
                Ok(span_text(&ctx.input, start, ctx.pos)
                    .map(RuntimeValue::Scalar)
                    .unwrap_or(RuntimeValue::Undef))
            }
            "capture_slice_until_cursor_len" => {
                let start = ctx.capture_start.unwrap_or(0);
                Ok(span_char_len(&ctx.input, start, ctx.pos)
                    .map(|n| RuntimeValue::Number(n as f64))
                    .unwrap_or(RuntimeValue::Undef))
            }
            "capture_until_boundary" => {
                let mut saw_valid_boundary = false;
                let mut boundary_start: Option<usize> = None;
                for index in 0..raw_args.len() {
                    let target = self.resolve_rule_name_at(raw_args, args.get(index), index);
                    if target.is_empty() {
                        continue;
                    }
                    let Some(boundary_rule) = self.spec.find(&target) else {
                        continue;
                    };
                    if boundary_rule.regex_patterns.is_empty() {
                        continue;
                    }
                    saw_valid_boundary = true;
                    let boundary_alt = CompiledAlternation::compile(&boundary_rule.regex_patterns)?;
                    if let Some(candidate) = boundary_alt.seek_match(&ctx.input, ctx.pos) {
                        if boundary_start.is_none_or(|current| candidate.start < current) {
                            boundary_start = Some(candidate.start);
                        }
                    }
                }
                if !saw_valid_boundary {
                    return Ok(RuntimeValue::Undef);
                }
                let boundary_start = boundary_start.unwrap_or(ctx.input.len());
                let start = ctx.pos;
                match span_text(&ctx.input, start, boundary_start) {
                    Some(text) => {
                        ctx.set_pos(boundary_start);
                        Ok(RuntimeValue::Scalar(text))
                    }
                    None => Ok(RuntimeValue::Undef),
                }
            }
            "capture_take_until_cursor" => {
                let start = ctx.capture_start.unwrap_or(0);
                let cursor = ctx.pos;
                match span_text(&ctx.input, start, cursor) {
                    Some(text) => {
                        ctx.capture_start = Some(cursor);
                        Ok(RuntimeValue::Scalar(text))
                    }
                    None => Ok(RuntimeValue::Undef),
                }
            }
            "capture_take_until_cursor_len" => {
                let start = ctx.capture_start.unwrap_or(0);
                let cursor = ctx.pos;
                match span_char_len(&ctx.input, start, cursor) {
                    Some(n) => {
                        ctx.capture_start = Some(cursor);
                        Ok(RuntimeValue::Number(n as f64))
                    }
                    None => Ok(RuntimeValue::Undef),
                }
            }
            "capture_take" => {
                // text capture_start→match-START; advance capture_start to the
                // cursor (Contracts.pm CAPTURE_SLICE_TAKE, `$IPOS = pos $$STRING`).
                let start = ctx.capture_start.unwrap_or(0);
                match span_text(&ctx.input, start, ctx.match_start_byte) {
                    Some(text) => {
                        ctx.capture_start = Some(ctx.pos);
                        Ok(RuntimeValue::Scalar(text))
                    }
                    None => Ok(RuntimeValue::Undef),
                }
            }
            "capture_take_len" => {
                // length capture_start→match-START; advance capture_start to the
                // cursor (Contracts.pm CAPTURE_SLICE_TAKE_LEN).
                let start = ctx.capture_start.unwrap_or(0);
                match span_char_len(&ctx.input, start, ctx.match_start_byte) {
                    Some(n) => {
                        ctx.capture_start = Some(ctx.pos);
                        Ok(RuntimeValue::Number(n as f64))
                    }
                    None => Ok(RuntimeValue::Undef),
                }
            }
            "capture_rest" => {
                let start = ctx.capture_start.unwrap_or(0);
                Ok(span_text(&ctx.input, start, ctx.input.len())
                    .map(RuntimeValue::Scalar)
                    .unwrap_or(RuntimeValue::Undef))
            }
            "capture_rest_len" => {
                let start = ctx.capture_start.unwrap_or(0);
                Ok(span_char_len(&ctx.input, start, ctx.input.len())
                    .map(|n| RuntimeValue::Number(n as f64))
                    .unwrap_or(RuntimeValue::Undef))
            }
            "capture_take_rest" => {
                let start = ctx.capture_start.unwrap_or(0);
                let end = ctx.input.len();
                match span_text(&ctx.input, start, end) {
                    Some(text) => {
                        ctx.capture_start = Some(end);
                        Ok(RuntimeValue::Scalar(text))
                    }
                    None => Ok(RuntimeValue::Undef),
                }
            }
            "capture_take_rest_len" => {
                let start = ctx.capture_start.unwrap_or(0);
                let end = ctx.input.len();
                match span_char_len(&ctx.input, start, end) {
                    Some(n) => {
                        ctx.capture_start = Some(end);
                        Ok(RuntimeValue::Number(n as f64))
                    }
                    None => Ok(RuntimeValue::Undef),
                }
            }
            "mark_here" => {
                if !args.is_empty() {
                    let name = args[0].to_str();
                    ctx.marks.insert(name, ctx.pos);
                }
                Ok(RuntimeValue::Undef)
            }
            "mark_pos" => {
                let name = args.first().map(|a| a.to_str()).unwrap_or_default();
                let byte = ctx.marks.get(&name).copied().unwrap_or(0);
                Ok(RuntimeValue::Number(
                    byte_to_char_offset(&ctx.input, byte) as f64
                ))
            }
            "mark_exists" => {
                let name = args.first().map(|a| a.to_str()).unwrap_or_default();
                Ok(RuntimeValue::Bool(ctx.marks.contains_key(&name)))
            }
            // ── RUST-PARITY.5.5.3: mark-based capture family ──
            // Authoritative contract: `perl/LinkedSpec/ActionIR/Contracts.pm`
            // ~690–1047. Endpoints (byte offsets): the start of the current local
            // match (`$LSPOS - length $LMATCH` = `ctx.match_start_byte`) for the
            // non-cursor `*_from`/`*_len_from` readers; the cursor (`pos` =
            // `ctx.pos`) for `_until_cursor_`; end-of-input for `_rest_`. `_take_`
            // variants advance the named mark to the read's end (the cursor, or
            // end-of-input for `_rest_`). Marks are stored byte offsets; text is the
            // raw slice (correct chars); `_len_` results are char counts (DSL
            // lengths are char-based, .5.3). A missing mark, or a degenerate
            // (reversed / out-of-range) span, yields `undef` — matching the Perl
            // readers' `defined`/`>=` guards; `_take_` mutates only when the span
            // is valid.
            "mark_input_start" => {
                // Store the absolute start-of-input position (0) under the mark.
                if let Some(a) = args.first() {
                    ctx.marks.insert(a.to_str(), 0);
                }
                Ok(RuntimeValue::Undef)
            }
            "mark_input_end" => {
                // Store the absolute end-of-input position (byte length) under the mark.
                if let Some(a) = args.first() {
                    let end = ctx.input.len();
                    ctx.marks.insert(a.to_str(), end);
                }
                Ok(RuntimeValue::Undef)
            }
            "mark_copy" => {
                // 2-arg `mark_copy(target, source)`: copy source's position to
                // target when source is present, else delete target (Contracts.pm
                // MARK_COPY). The book catalog's 1-arg form was an imprecision,
                // corrected in .5.5.3.
                let target = args.first().map(|a| a.to_str()).unwrap_or_default();
                let source = args.get(1).map(|a| a.to_str()).unwrap_or_default();
                match ctx.marks.get(&source).copied() {
                    Some(pos) => {
                        ctx.marks.insert(target, pos);
                    }
                    None => {
                        ctx.marks.remove(&target);
                    }
                }
                Ok(RuntimeValue::Undef)
            }
            "capture_from" => {
                // mark → match-START (was match-END before .5.5.3; fixed for Perl
                // parity — `capture_from` is a non-cursor reader).
                let name = args.first().map(|a| a.to_str()).unwrap_or_default();
                Ok(match ctx.marks.get(&name).copied() {
                    Some(mark) => span_text(&ctx.input, mark, ctx.match_start_byte)
                        .map(RuntimeValue::Scalar)
                        .unwrap_or(RuntimeValue::Undef),
                    None => RuntimeValue::Undef,
                })
            }
            "capture_len_from" => {
                let name = args.first().map(|a| a.to_str()).unwrap_or_default();
                Ok(match ctx.marks.get(&name).copied() {
                    Some(mark) => span_char_len(&ctx.input, mark, ctx.match_start_byte)
                        .map(|n| RuntimeValue::Number(n as f64))
                        .unwrap_or(RuntimeValue::Undef),
                    None => RuntimeValue::Undef,
                })
            }
            "capture_until_cursor_from" => {
                let name = args.first().map(|a| a.to_str()).unwrap_or_default();
                let cursor = ctx.pos;
                Ok(match ctx.marks.get(&name).copied() {
                    Some(mark) => span_text(&ctx.input, mark, cursor)
                        .map(RuntimeValue::Scalar)
                        .unwrap_or(RuntimeValue::Undef),
                    None => RuntimeValue::Undef,
                })
            }
            "capture_until_cursor_len_from" => {
                let name = args.first().map(|a| a.to_str()).unwrap_or_default();
                let cursor = ctx.pos;
                Ok(match ctx.marks.get(&name).copied() {
                    Some(mark) => span_char_len(&ctx.input, mark, cursor)
                        .map(|n| RuntimeValue::Number(n as f64))
                        .unwrap_or(RuntimeValue::Undef),
                    None => RuntimeValue::Undef,
                })
            }
            "capture_take_until_cursor_from" => {
                let name = args.first().map(|a| a.to_str()).unwrap_or_default();
                let cursor = ctx.pos;
                match ctx.marks.get(&name).copied() {
                    Some(mark) => match span_text(&ctx.input, mark, cursor) {
                        Some(text) => {
                            ctx.marks.insert(name, cursor);
                            Ok(RuntimeValue::Scalar(text))
                        }
                        None => Ok(RuntimeValue::Undef),
                    },
                    None => Ok(RuntimeValue::Undef),
                }
            }
            "capture_take_until_cursor_len_from" => {
                let name = args.first().map(|a| a.to_str()).unwrap_or_default();
                let cursor = ctx.pos;
                match ctx.marks.get(&name).copied() {
                    Some(mark) => match span_char_len(&ctx.input, mark, cursor) {
                        Some(n) => {
                            ctx.marks.insert(name, cursor);
                            Ok(RuntimeValue::Number(n as f64))
                        }
                        None => Ok(RuntimeValue::Undef),
                    },
                    None => Ok(RuntimeValue::Undef),
                }
            }
            "capture_take_len_from" => {
                // length mark→match-START; advances the mark to the cursor
                // (Contracts.pm CAPTURE_TAKE_LEN_FROM_MARK).
                let name = args.first().map(|a| a.to_str()).unwrap_or_default();
                let cursor = ctx.pos;
                let end = ctx.match_start_byte;
                match ctx.marks.get(&name).copied() {
                    Some(mark) => match span_char_len(&ctx.input, mark, end) {
                        Some(n) => {
                            ctx.marks.insert(name, cursor);
                            Ok(RuntimeValue::Number(n as f64))
                        }
                        None => Ok(RuntimeValue::Undef),
                    },
                    None => Ok(RuntimeValue::Undef),
                }
            }
            "capture_rest_from" => {
                let name = args.first().map(|a| a.to_str()).unwrap_or_default();
                let end = ctx.input.len();
                Ok(match ctx.marks.get(&name).copied() {
                    Some(mark) => span_text(&ctx.input, mark, end)
                        .map(RuntimeValue::Scalar)
                        .unwrap_or(RuntimeValue::Undef),
                    None => RuntimeValue::Undef,
                })
            }
            "capture_rest_len_from" => {
                let name = args.first().map(|a| a.to_str()).unwrap_or_default();
                let end = ctx.input.len();
                Ok(match ctx.marks.get(&name).copied() {
                    Some(mark) => span_char_len(&ctx.input, mark, end)
                        .map(|n| RuntimeValue::Number(n as f64))
                        .unwrap_or(RuntimeValue::Undef),
                    None => RuntimeValue::Undef,
                })
            }
            "capture_take_rest_from" => {
                let name = args.first().map(|a| a.to_str()).unwrap_or_default();
                let end = ctx.input.len();
                match ctx.marks.get(&name).copied() {
                    Some(mark) => match span_text(&ctx.input, mark, end) {
                        Some(text) => {
                            ctx.marks.insert(name, end);
                            Ok(RuntimeValue::Scalar(text))
                        }
                        None => Ok(RuntimeValue::Undef),
                    },
                    None => Ok(RuntimeValue::Undef),
                }
            }
            "capture_take_rest_len_from" => {
                let name = args.first().map(|a| a.to_str()).unwrap_or_default();
                let end = ctx.input.len();
                match ctx.marks.get(&name).copied() {
                    Some(mark) => match span_char_len(&ctx.input, mark, end) {
                        Some(n) => {
                            ctx.marks.insert(name, end);
                            Ok(RuntimeValue::Number(n as f64))
                        }
                        None => Ok(RuntimeValue::Undef),
                    },
                    None => Ok(RuntimeValue::Undef),
                }
            }
            "capture_between" => {
                let a = args.first().map(|v| v.to_str()).unwrap_or_default();
                let b = args.get(1).map(|v| v.to_str()).unwrap_or_default();
                let start = ctx.marks.get(&a).copied();
                let end = ctx.marks.get(&b).copied();
                Ok(match (start, end) {
                    (Some(s), Some(e)) => span_text(&ctx.input, s, e)
                        .map(RuntimeValue::Scalar)
                        .unwrap_or(RuntimeValue::Undef),
                    _ => RuntimeValue::Undef,
                })
            }
            "capture_len_between" => {
                let a = args.first().map(|v| v.to_str()).unwrap_or_default();
                let b = args.get(1).map(|v| v.to_str()).unwrap_or_default();
                let start = ctx.marks.get(&a).copied();
                let end = ctx.marks.get(&b).copied();
                Ok(match (start, end) {
                    (Some(s), Some(e)) => span_char_len(&ctx.input, s, e)
                        .map(|n| RuntimeValue::Number(n as f64))
                        .unwrap_or(RuntimeValue::Undef),
                    _ => RuntimeValue::Undef,
                })
            }
            // ── Entry/match detail ──
            "entry_line" | "entry_start_line" => {
                let (line, _) =
                    line_col_from_optional_char_arg(&ctx.input, args, ctx.entry_start_byte);
                Ok(RuntimeValue::Number(line as f64))
            }
            "entry_col" | "entry_start_col" => {
                let (_, col) =
                    line_col_from_optional_char_arg(&ctx.input, args, ctx.entry_start_byte);
                Ok(RuntimeValue::Number(col as f64))
            }
            "entry_end_line" => {
                let (line, _) =
                    line_col_from_optional_char_arg(&ctx.input, args, ctx.entry_end_byte);
                Ok(RuntimeValue::Number(line as f64))
            }
            "entry_end_col" => {
                let (_, col) =
                    line_col_from_optional_char_arg(&ctx.input, args, ctx.entry_end_byte);
                Ok(RuntimeValue::Number(col as f64))
            }
            "entry_len" => Ok(RuntimeValue::Number(
                span_char_len(&ctx.input, ctx.entry_start_byte, ctx.entry_end_byte).unwrap_or(0)
                    as f64,
            )),
            "entry_start_pos" => Ok(RuntimeValue::Number(byte_to_char_offset(
                &ctx.input,
                ctx.entry_start_byte,
            ) as f64)),
            "entry_end_pos" => Ok(RuntimeValue::Number(byte_to_char_offset(
                &ctx.input,
                ctx.entry_end_byte,
            ) as f64)),
            "match_line" | "match_start_line" => {
                let (line, _) =
                    line_col_from_optional_char_arg(&ctx.input, args, ctx.match_start_byte);
                Ok(RuntimeValue::Number(line as f64))
            }
            "match_col" | "match_start_col" => {
                let (_, col) =
                    line_col_from_optional_char_arg(&ctx.input, args, ctx.match_start_byte);
                Ok(RuntimeValue::Number(col as f64))
            }
            "match_end_line" => {
                let (line, _) =
                    line_col_from_optional_char_arg(&ctx.input, args, ctx.match_end_byte);
                Ok(RuntimeValue::Number(line as f64))
            }
            "match_end_col" => {
                let (_, col) =
                    line_col_from_optional_char_arg(&ctx.input, args, ctx.match_end_byte);
                Ok(RuntimeValue::Number(col as f64))
            }
            "match_len" => Ok(if ctx.match_present {
                span_char_len(&ctx.input, ctx.match_start_byte, ctx.match_end_byte)
                    .map(|length| RuntimeValue::Number(length as f64))
                    .unwrap_or(RuntimeValue::Undef)
            } else {
                RuntimeValue::Undef
            }),
            "match_start_pos" => Ok(if ctx.match_present {
                RuntimeValue::Number(byte_to_char_offset(&ctx.input, ctx.match_start_byte) as f64)
            } else {
                RuntimeValue::Undef
            }),
            "match_end_pos" => Ok(if ctx.match_present {
                RuntimeValue::Number(byte_to_char_offset(&ctx.input, ctx.match_end_byte) as f64)
            } else {
                RuntimeValue::Undef
            }),
            "match_group" => {
                if !ctx.match_present {
                    Ok(RuntimeValue::Undef)
                } else if let Some(arg) = args.first() {
                    let idx = arg.as_number().unwrap_or(0.0) as usize;
                    Ok(ctx
                        .match_groups
                        .get(idx)
                        .cloned()
                        .map(RuntimeValue::Scalar)
                        .unwrap_or(RuntimeValue::Undef))
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "match_groups" => Ok(RuntimeValue::Array(
                ctx.match_groups
                    .iter()
                    .map(|g| RuntimeValue::Scalar(g.clone()))
                    .collect(),
            )),
            // Named-capture readers for the LOCAL match — the immediate regex
            // match inside this code block, which can diverge from the entry match
            // in nested/dispatched contexts (Helper Contract Catalog §8). They read
            // the populated `ctx.match_named` map. `match_named_map` is a retired
            // alias of `match_map`.
            "match_named" => Ok(match Self::resolve_named_capture_key(raw_args, args) {
                Some(name) => ctx
                    .match_named
                    .get(&name)
                    .map(|v| RuntimeValue::Scalar(v.clone()))
                    .unwrap_or(RuntimeValue::Undef),
                None => RuntimeValue::Undef,
            }),
            "match_has" => Ok(RuntimeValue::Number(
                if Self::resolve_named_capture_key(raw_args, args)
                    .map(|name| ctx.match_named.contains_key(&name))
                    .unwrap_or(false)
                {
                    1.0
                } else {
                    0.0
                },
            )),
            "match_map" | "match_named_map" => Ok(named_map_to_hash(&ctx.match_named)),
            // ── Scalar transforms ──
            "length" => {
                // Char count (Perl `length`), not byte length.
                if let Some(arg) = args.first() {
                    Ok(RuntimeValue::Number(arg.to_str().chars().count() as f64))
                } else {
                    Ok(RuntimeValue::Number(0.0))
                }
            }
            "trim" => Ok(RuntimeValue::Scalar(
                args.first()
                    .map(|a| a.to_str().trim().to_string())
                    .unwrap_or_default(),
            )),
            "lowercase" => Ok(RuntimeValue::Scalar(
                args.first()
                    .map(|a| a.to_str().to_lowercase())
                    .unwrap_or_default(),
            )),
            "uppercase" => Ok(RuntimeValue::Scalar(
                args.first()
                    .map(|a| a.to_str().to_uppercase())
                    .unwrap_or_default(),
            )),
            "replace_substr" => {
                if args.len() >= 3 {
                    let s = args[0].to_str();
                    let from = args[1].to_str();
                    let to = args[2].to_str();
                    Ok(RuntimeValue::Scalar(s.replace(&from, &to)))
                } else {
                    Ok(args.first().cloned().unwrap_or(RuntimeValue::Undef))
                }
            }
            "rm_prefix" => {
                if args.len() >= 2 {
                    let s = args[0].to_str();
                    let prefix = args[1].to_str();
                    Ok(RuntimeValue::Scalar(
                        s.strip_prefix(&prefix).unwrap_or(&s).to_string(),
                    ))
                } else {
                    Ok(args.first().cloned().unwrap_or(RuntimeValue::Undef))
                }
            }
            "rm_suffix" => {
                if args.len() >= 2 {
                    let s = args[0].to_str();
                    let suffix = args[1].to_str();
                    Ok(RuntimeValue::Scalar(
                        s.strip_suffix(&suffix).unwrap_or(&s).to_string(),
                    ))
                } else {
                    Ok(args.first().cloned().unwrap_or(RuntimeValue::Undef))
                }
            }
            "starts_with" => {
                if args.len() >= 2 {
                    let s = args[0].to_str();
                    let prefix = args[1].to_str();
                    Ok(RuntimeValue::Number(if s.starts_with(&prefix) {
                        1.0
                    } else {
                        0.0
                    }))
                } else {
                    Ok(RuntimeValue::Number(0.0))
                }
            }
            "ends_with" => {
                if args.len() >= 2 {
                    let s = args[0].to_str();
                    let suffix = args[1].to_str();
                    Ok(RuntimeValue::Number(if s.ends_with(&suffix) {
                        1.0
                    } else {
                        0.0
                    }))
                } else {
                    Ok(RuntimeValue::Number(0.0))
                }
            }
            "contains_substr" => {
                if args.len() >= 2 {
                    let s = args[0].to_str();
                    let sub = args[1].to_str();
                    Ok(RuntimeValue::Number(if s.contains(&sub) {
                        1.0
                    } else {
                        0.0
                    }))
                } else {
                    Ok(RuntimeValue::Number(0.0))
                }
            }
            "str_eq" | "str_ne" | "str_gt" | "str_ge" | "str_lt" | "str_le" => {
                if args.len() >= 2 {
                    let lhs = args[0].to_str();
                    let rhs = args[1].to_str();
                    let result = match name {
                        "str_eq" => lhs == rhs,
                        "str_ne" => lhs != rhs,
                        "str_gt" => lhs > rhs,
                        "str_ge" => lhs >= rhs,
                        "str_lt" => lhs < rhs,
                        "str_le" => lhs <= rhs,
                        _ => false,
                    };
                    Ok(RuntimeValue::Bool(result))
                } else {
                    Ok(RuntimeValue::Bool(false))
                }
            }
            "matches" => {
                if args.len() >= 2 {
                    let s = args[0].to_str();
                    let pat = args[1].to_str();
                    match rgx_core::Regex::compile(&pat) {
                        Ok(re) => Ok(RuntimeValue::Bool(re.is_match(&s))),
                        Err(e) => {
                            eprintln!(
                                "warning: matches: invalid regex '/{}/': {} — returning false",
                                pat, e
                            );
                            Ok(RuntimeValue::Bool(false))
                        }
                    }
                } else {
                    Ok(RuntimeValue::Bool(false))
                }
            }
            "or" => Ok(RuntimeValue::Bool(args.iter().any(RuntimeValue::as_bool))),
            "and" => Ok(RuntimeValue::Bool(
                !args.is_empty() && args.iter().all(RuntimeValue::as_bool),
            )),
            "not" => Ok(RuntimeValue::Bool(
                args.first().is_none_or(|arg| !arg.as_bool()),
            )),
            // ── Coalesce ──
            "coalesce_nonempty" => {
                for a in args {
                    if a.is_defined() && !a.to_str().is_empty() {
                        return Ok(a.clone());
                    }
                }
                Ok(RuntimeValue::Undef)
            }
            // ── Scalar arithmetic ──
            "num_add" | "num_mul" => {
                if args.len() >= 2 {
                    let nums: Option<Vec<f64>> = args.iter().map(|arg| arg.as_number()).collect();
                    match nums {
                        Some(nums) if name == "num_add" => {
                            Ok(RuntimeValue::Number(nums.iter().sum()))
                        }
                        Some(nums) => Ok(RuntimeValue::Number(nums.iter().product())),
                        None => Ok(RuntimeValue::Undef),
                    }
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "num_sub" | "num_div" | "num_mod" => {
                if args.len() >= 2 {
                    let a = args[0].as_number();
                    let b = args[1].as_number();
                    match (a, b) {
                        (Some(a), Some(b)) => {
                            let result = match name {
                                "num_sub" => a - b,
                                "num_div" if b != 0.0 => a / b,
                                "num_mod" if b != 0.0 && a.fract() == 0.0 && b.fract() == 0.0 => {
                                    (a as i64 % b as i64) as f64
                                }
                                _ => return Ok(RuntimeValue::Undef),
                            };
                            Ok(RuntimeValue::Number(result))
                        }
                        _ => Ok(RuntimeValue::Undef),
                    }
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "num_eq" | "num_ne" | "num_gt" | "num_ge" | "num_lt" | "num_le" => {
                if args.len() >= 2 {
                    match (args[0].as_number(), args[1].as_number()) {
                        (Some(a), Some(b)) => {
                            let result = match name {
                                "num_eq" => a == b,
                                "num_ne" => a != b,
                                "num_gt" => a > b,
                                "num_ge" => a >= b,
                                "num_lt" => a < b,
                                "num_le" => a <= b,
                                _ => false,
                            };
                            Ok(RuntimeValue::Number(if result { 1.0 } else { 0.0 }))
                        }
                        _ => Ok(RuntimeValue::Number(0.0)),
                    }
                } else {
                    Ok(RuntimeValue::Number(0.0))
                }
            }
            "num_abs" => Ok(RuntimeValue::Number(
                args.first()
                    .and_then(|a| a.as_number())
                    .map(|n| n.abs())
                    .unwrap_or(0.0),
            )),
            "num_floor" => Ok(RuntimeValue::Number(
                args.first()
                    .and_then(|a| a.as_number())
                    .map(|n| n.floor())
                    .unwrap_or(0.0),
            )),
            "num_ceil" => Ok(RuntimeValue::Number(
                args.first()
                    .and_then(|a| a.as_number())
                    .map(|n| n.ceil())
                    .unwrap_or(0.0),
            )),
            "num_round" => Ok(RuntimeValue::Number(
                args.first()
                    .and_then(|a| a.as_number())
                    .map(|n| n.round())
                    .unwrap_or(0.0),
            )),
            "num_min" => {
                let values: Vec<f64> = if args.len() == 1 {
                    match self.array_consuming_arg(raw_args, args, 0, ctx) {
                        RuntimeValue::Array(items) => {
                            items.iter().filter_map(|item| item.as_number()).collect()
                        }
                        value => value.as_number().into_iter().collect(),
                    }
                } else {
                    args.iter().filter_map(|a| a.as_number()).collect()
                };
                let min = values.iter().copied().fold(f64::INFINITY, |a, b| a.min(b));
                if min.is_finite() {
                    Ok(RuntimeValue::Number(min))
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "num_max" => {
                let values: Vec<f64> = if args.len() == 1 {
                    match self.array_consuming_arg(raw_args, args, 0, ctx) {
                        RuntimeValue::Array(items) => {
                            items.iter().filter_map(|item| item.as_number()).collect()
                        }
                        value => value.as_number().into_iter().collect(),
                    }
                } else {
                    args.iter().filter_map(|a| a.as_number()).collect()
                };
                let max = values
                    .iter()
                    .copied()
                    .fold(f64::NEG_INFINITY, |a, b| a.max(b));
                if max.is_finite() {
                    Ok(RuntimeValue::Number(max))
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "num_clamp" => {
                if args.len() >= 3 {
                    let v = args[0].as_number();
                    let lo = args[1].as_number();
                    let hi = args[2].as_number();
                    match (v, lo, hi) {
                        (Some(v), Some(lo), Some(hi)) if lo <= hi => {
                            Ok(RuntimeValue::Number(v.clamp(lo, hi)))
                        }
                        _ => Ok(RuntimeValue::Undef),
                    }
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "num_sum" | "num_avg" | "num_median" | "num_range" => {
                if let RuntimeValue::Array(items) = self.array_consuming_arg(raw_args, args, 0, ctx)
                {
                    let nums: Vec<f64> = items.iter().filter_map(|v| v.as_number()).collect();
                    if nums.is_empty() {
                        return Ok(RuntimeValue::Undef);
                    }
                    match name {
                        "num_sum" => Ok(RuntimeValue::Number(nums.iter().sum())),
                        "num_avg" => Ok(RuntimeValue::Number(
                            nums.iter().sum::<f64>() / nums.len() as f64,
                        )),
                        "num_median" => {
                            let mut sorted = nums.clone();
                            sorted.sort_by(|a, b| {
                                a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal)
                            });
                            let mid = sorted.len() / 2;
                            if sorted.len() % 2 == 0 {
                                Ok(RuntimeValue::Number((sorted[mid - 1] + sorted[mid]) / 2.0))
                            } else {
                                Ok(RuntimeValue::Number(sorted[mid]))
                            }
                        }
                        "num_range" => {
                            let min = nums.iter().fold(f64::INFINITY, |a, &b| a.min(b));
                            let max = nums.iter().fold(f64::NEG_INFINITY, |a, &b| a.max(b));
                            Ok(RuntimeValue::Number(max - min))
                        }
                        _ => Ok(RuntimeValue::Undef),
                    }
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            // ── Array helpers ──
            "sorted" => {
                if let RuntimeValue::Array(mut items) =
                    self.array_consuming_arg(raw_args, args, 0, ctx)
                {
                    items.sort_by(|a, b| a.to_str().cmp(&b.to_str()));
                    Ok(RuntimeValue::Array(items))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "reversed" => {
                if let RuntimeValue::Array(mut items) =
                    self.array_consuming_arg(raw_args, args, 0, ctx)
                {
                    items.reverse();
                    Ok(RuntimeValue::Array(items))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "take" => {
                if let RuntimeValue::Array(items) = self.array_consuming_arg(raw_args, args, 0, ctx)
                {
                    let n = args.get(1).and_then(|a| a.as_number()).unwrap_or(1.0) as usize;
                    Ok(RuntimeValue::Array(items.iter().take(n).cloned().collect()))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "take_last" => {
                if let RuntimeValue::Array(items) = self.array_consuming_arg(raw_args, args, 0, ctx)
                {
                    let n = args.get(1).and_then(|a| a.as_number()).unwrap_or(1.0) as usize;
                    let start = if n > items.len() { 0 } else { items.len() - n };
                    Ok(RuntimeValue::Array(items[start..].to_vec()))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "drop_front" => {
                if let RuntimeValue::Array(items) = self.array_consuming_arg(raw_args, args, 0, ctx)
                {
                    let n = args.get(1).and_then(|a| a.as_number()).unwrap_or(1.0) as usize;
                    Ok(RuntimeValue::Array(items.iter().skip(n).cloned().collect()))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "drop_back" => {
                if let RuntimeValue::Array(items) = self.array_consuming_arg(raw_args, args, 0, ctx)
                {
                    let n = args.get(1).and_then(|a| a.as_number()).unwrap_or(1.0) as usize;
                    let end = if n > items.len() { 0 } else { items.len() - n };
                    Ok(RuntimeValue::Array(items[..end].to_vec()))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "slice" => {
                if let RuntimeValue::Array(items) = self.array_consuming_arg(raw_args, args, 0, ctx)
                {
                    let start = args.get(1).and_then(|a| a.as_number()).unwrap_or(0.0) as usize;
                    let n = args
                        .get(2)
                        .and_then(|a| a.as_number())
                        .unwrap_or(items.len() as f64) as usize;
                    let end = (start + n).min(items.len());
                    Ok(RuntimeValue::Array(items[start..end].to_vec()))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "contains" => {
                if let RuntimeValue::Array(items) = self.array_consuming_arg(raw_args, args, 0, ctx)
                {
                    let needle = args.get(1).map(|a| a.to_str()).unwrap_or_default();
                    Ok(RuntimeValue::Number(
                        if items.iter().any(|v| v.to_str() == needle) {
                            1.0
                        } else {
                            0.0
                        },
                    ))
                } else {
                    Ok(RuntimeValue::Number(0.0))
                }
            }
            "index_of" => {
                if let RuntimeValue::Array(items) = self.array_consuming_arg(raw_args, args, 0, ctx)
                {
                    let needle = args.get(1).map(|a| a.to_str()).unwrap_or_default();
                    match items.iter().position(|v| v.to_str() == needle) {
                        Some(i) => Ok(RuntimeValue::Number(i as f64)),
                        None => Ok(RuntimeValue::Undef),
                    }
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "is_empty" => {
                let val = args.first().cloned().unwrap_or(RuntimeValue::Undef);
                Ok(RuntimeValue::Bool(!val.is_nonempty()))
            }
            "is_nonempty" => {
                let val = args.first().cloned().unwrap_or(RuntimeValue::Undef);
                Ok(RuntimeValue::Bool(val.is_nonempty()))
            }
            "is_defined" => Ok(RuntimeValue::Bool(
                args.first().is_some_and(|a| a.is_defined()),
            )),
            "is_undefined" => Ok(RuntimeValue::Bool(
                args.first().is_none_or(|a| !a.is_defined()),
            )),
            "flat_array" => Ok(RuntimeValue::Array(
                args.iter()
                    .enumerate()
                    .flat_map(|(index, _)| {
                        match self.array_consuming_arg(raw_args, args, index, ctx) {
                            RuntimeValue::Array(items) => items,
                            other => vec![other],
                        }
                    })
                    .collect(),
            )),
            // RUST-PARITY.5.5.2 — generic list-context splice (Perl `flat(container)`,
            // MethodLowering.pm:199): an array container splices its elements, a hash
            // container splices its key/value entries, any other value becomes a
            // single-element list. Consistent with `flat_array` (Array→Array) and
            // `flat_hash` (Hash→Hash) so a parent `array(...)`/`hash(...)` consumes it the
            // same way. The retired Perl aliases `flatten`/`tail`/`drop_last` are
            // intentionally NOT added — the Perl reference no longer recognizes them
            // (COMPAT-ALIAS-RETIREMENT.1), so adding them in Rust would diverge from the
            // reference's recognized surface rather than match it.
            "flat" => {
                let arg = args.first().cloned().unwrap_or(RuntimeValue::Undef);
                match arg {
                    RuntimeValue::Hash(entries) => Ok(RuntimeValue::Hash(entries)),
                    RuntimeValue::Array(items) => Ok(RuntimeValue::Array(items)),
                    other => Ok(RuntimeValue::Array(vec![other])),
                }
            }
            "concat_arrays" => Ok(RuntimeValue::Array(
                args.iter()
                    .flat_map(|a| match a {
                        RuntimeValue::Array(items) => items.clone(),
                        other => vec![other.clone()],
                    })
                    .collect(),
            )),
            // ── Hash helpers ──
            "hash" => {
                if let (
                    true,
                    Some(linkedspec_core::expr::Arg::Positional(
                        linkedspec_core::expr::Expr::Variable { name: var_name },
                    )),
                ) = (args.len() == 1 && raw_args.len() == 1, raw_args.first())
                {
                    if let Some(values) = Self::scalar_held_hash_snapshot(ctx, var_name) {
                        return Ok(RuntimeValue::Hash(values));
                    }
                    return Ok(RuntimeValue::Hash(ctx.get_hash(var_name)));
                }
                let mut entries = Vec::new();
                let mut i = 0;
                while i + 1 < args.len() {
                    let key = args[i].to_str();
                    let val = args[i + 1].clone();
                    entries.push((key, val));
                    i += 2;
                }
                // Only explicit flat/flat_hash arguments splice entries. An
                // ordinary hash in a value slot remains one nested value.
                for (raw_arg, arg) in raw_args.iter().zip(args.iter()) {
                    if Self::is_hash_context_splice_arg(raw_arg)
                        && let RuntimeValue::Hash(h_entries) = arg
                    {
                        for (k, v) in h_entries {
                            entries.push((k.clone(), v.clone()));
                        }
                    }
                }
                Ok(RuntimeValue::Hash(entries))
            }
            "merge_hash" => {
                let mut merged = Vec::new();
                for index in 0..args.len() {
                    let arg = self.hash_consuming_arg(raw_args, args, index, ctx);
                    if let RuntimeValue::Hash(entries) = arg {
                        for (k, v) in &entries {
                            if let Some((_, existing_value)) = merged
                                .iter_mut()
                                .find(|(existing_key, _)| existing_key == k)
                            {
                                *existing_value = v.clone();
                            } else {
                                merged.push((k.clone(), v.clone()));
                            }
                        }
                    }
                }
                Ok(RuntimeValue::Hash(merged))
            }
            "set_key" => {
                if args.len() >= 3 {
                    if let RuntimeValue::Hash(mut entries) =
                        self.hash_consuming_arg(raw_args, args, 0, ctx)
                    {
                        let key = args[1].to_str();
                        let val = args[2].clone();
                        if let Some(existing) = entries.iter_mut().find(|(k, _)| k == &key) {
                            existing.1 = val;
                        } else {
                            entries.push((key, val));
                        }
                        Ok(RuntimeValue::Hash(entries))
                    } else {
                        Ok(args[0].clone())
                    }
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "rename_key" => {
                if args.len() >= 3 {
                    if let RuntimeValue::Hash(entries) =
                        self.hash_consuming_arg(raw_args, args, 0, ctx)
                    {
                        let old_key = args[1].to_str();
                        let new_key = args[2].to_str();
                        let renamed: Vec<_> = entries
                            .into_iter()
                            .map(|(k, v)| {
                                if k == old_key {
                                    (new_key.clone(), v)
                                } else {
                                    (k, v)
                                }
                            })
                            .collect();
                        Ok(RuntimeValue::Hash(renamed))
                    } else {
                        Ok(args[0].clone())
                    }
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "drop_keys" => {
                if let RuntimeValue::Hash(entries) = self.hash_consuming_arg(raw_args, args, 0, ctx)
                {
                    let keys_to_drop: std::collections::HashSet<String> =
                        args[1..].iter().map(|a| a.to_str()).collect();
                    Ok(RuntimeValue::Hash(
                        entries
                            .into_iter()
                            .filter(|(k, _)| !keys_to_drop.contains(k))
                            .collect(),
                    ))
                } else {
                    Ok(args.first().cloned().unwrap_or(RuntimeValue::Undef))
                }
            }
            "pick_keys" => {
                if let RuntimeValue::Hash(entries) = self.hash_consuming_arg(raw_args, args, 0, ctx)
                {
                    let keys_to_keep: std::collections::HashSet<String> =
                        args[1..].iter().map(|a| a.to_str()).collect();
                    Ok(RuntimeValue::Hash(
                        entries
                            .into_iter()
                            .filter(|(k, _)| keys_to_keep.contains(k))
                            .collect(),
                    ))
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "sorted_keys" => {
                if let RuntimeValue::Hash(entries) = self.hash_consuming_arg(raw_args, args, 0, ctx)
                {
                    let mut keys: Vec<RuntimeValue> = entries
                        .iter()
                        .map(|(k, _)| RuntimeValue::Scalar(k.clone()))
                        .collect();
                    keys.sort_by(|a, b| a.to_str().cmp(&b.to_str()));
                    Ok(RuntimeValue::Array(keys))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "sorted_values" => {
                if let RuntimeValue::Hash(entries) = self.hash_consuming_arg(raw_args, args, 0, ctx)
                {
                    let mut items: Vec<(String, RuntimeValue)> = entries;
                    items.sort_by(|(ak, _), (bk, _)| ak.cmp(bk));
                    Ok(RuntimeValue::Array(
                        items.into_iter().map(|(_, v)| v).collect(),
                    ))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "count_keys" => {
                if let RuntimeValue::Hash(entries) = self.hash_consuming_arg(raw_args, args, 0, ctx)
                {
                    Ok(RuntimeValue::Number(entries.len() as f64))
                } else {
                    Ok(RuntimeValue::Number(0.0))
                }
            }
            "has_key" => {
                if let RuntimeValue::Hash(entries) = self.hash_consuming_arg(raw_args, args, 0, ctx)
                {
                    let key = args.get(1).map(|a| a.to_str()).unwrap_or_default();
                    Ok(RuntimeValue::Number(
                        if entries.iter().any(|(k, _)| k == &key) {
                            1.0
                        } else {
                            0.0
                        },
                    ))
                } else {
                    Ok(RuntimeValue::Number(0.0))
                }
            }
            "flat_hash" => {
                let mut entries = Vec::new();
                for index in 0..args.len() {
                    let arg = self.hash_consuming_arg(raw_args, args, index, ctx);
                    match arg {
                        RuntimeValue::Hash(h_entries) => {
                            for (k, v) in &h_entries {
                                entries.push((k.clone(), v.clone()));
                            }
                        }
                        _ => {}
                    }
                }
                Ok(RuntimeValue::Hash(entries))
            }
            "next" => {
                // flow skip — equivalent to "continue matching"
                Ok(RuntimeValue::Undef)
            }
            // ── Explicit cursor controls ──
            "save_cursor" => {
                ctx.save_cursor();
                Ok(RuntimeValue::Undef)
            }
            "restore_cursor" => {
                ctx.restore_cursor();
                Ok(RuntimeValue::Undef)
            }
            "rewind_match_start" => {
                ctx.rewind_match_start();
                Ok(RuntimeValue::Undef)
            }
            "rewind_entry_start" => {
                ctx.rewind_entry_start();
                Ok(RuntimeValue::Undef)
            }
            // ── Conditional flow: if/elseif/else/endif ──
            "if" => {
                // Inline composite: if(cond, then, elseif(cond2, then2), else(else_body))
                // Lazy evaluation — branch bodies NOT evaluated unless their condition
                // matches. raw_args provides AST nodes; eval_expr evaluates conditionally.
                if raw_args.is_empty() {
                    return Ok(RuntimeValue::Undef);
                }
                let cond = self.eval_expr(raw_args[0].value(), ctx, rule_label)?;
                if cond.as_bool() {
                    if raw_args.len() >= 2 {
                        return self.eval_expr(raw_args[1].value(), ctx, rule_label);
                    }
                    return Ok(RuntimeValue::Undef);
                }
                let mut i = 2;
                while i < raw_args.len() {
                    if let linkedspec_core::expr::Arg::Positional(
                        linkedspec_core::expr::Expr::Call {
                            name: branch_name,
                            args: branch_args,
                        },
                    ) = &raw_args[i]
                    {
                        if branch_name == "elseif" && !branch_args.is_empty() {
                            let elseif_cond =
                                self.eval_expr(branch_args[0].value(), ctx, rule_label)?;
                            if elseif_cond.as_bool() {
                                if branch_args.len() >= 2 {
                                    return self.eval_expr(branch_args[1].value(), ctx, rule_label);
                                }
                                return Ok(RuntimeValue::Undef);
                            }
                            i += 1;
                            continue;
                        }
                        if branch_name == "else" && !branch_args.is_empty() {
                            return self.eval_expr(branch_args[0].value(), ctx, rule_label);
                        }
                    }
                    return self.eval_expr(raw_args[i].value(), ctx, rule_label);
                }
                Ok(RuntimeValue::Undef)
            }
            "elseif" => {
                if raw_args.len() >= 2 {
                    let cond = self.eval_expr(raw_args[0].value(), ctx, rule_label)?;
                    if cond.as_bool() {
                        return self.eval_expr(raw_args[1].value(), ctx, rule_label);
                    }
                } else if !raw_args.is_empty() {
                    let _ = self.eval_expr(raw_args[0].value(), ctx, rule_label)?;
                }
                Ok(RuntimeValue::Undef)
            }
            "else" => {
                if let Some(raw) = raw_args.first() {
                    return self.eval_expr(raw.value(), ctx, rule_label);
                }
                Ok(RuntimeValue::Undef)
            }
            "endif" => Ok(RuntimeValue::Undef),
            // ── Conditional flow: switch/case/default/endswitch ──
            "switch" => {
                if raw_args.is_empty() {
                    return Ok(RuntimeValue::Undef);
                }
                let switch_val = self.eval_expr(raw_args[0].value(), ctx, rule_label)?;
                let switch_str = switch_val.to_str();
                let mut i = 1;
                while i < raw_args.len() {
                    if let linkedspec_core::expr::Arg::Positional(
                        linkedspec_core::expr::Expr::Call {
                            name: branch_name,
                            args: branch_args,
                        },
                    ) = &raw_args[i]
                    {
                        if branch_name == "case" && !branch_args.is_empty() {
                            let case_val = self.eval_switch_case_value(
                                branch_args[0].value(),
                                ctx,
                                rule_label,
                            )?;
                            if case_val == switch_str {
                                if branch_args.len() >= 2 {
                                    return self.eval_expr(branch_args[1].value(), ctx, rule_label);
                                }
                                return Ok(RuntimeValue::Undef);
                            }
                            i += 1;
                            continue;
                        }
                        if branch_name == "default" && !branch_args.is_empty() {
                            return self.eval_expr(branch_args[0].value(), ctx, rule_label);
                        }
                    }
                    return self.eval_expr(raw_args[i].value(), ctx, rule_label);
                }
                Ok(RuntimeValue::Undef)
            }
            "while" => {
                if raw_args.len() != 2 {
                    return Ok(RuntimeValue::Undef);
                }
                let linkedspec_core::expr::Expr::BlockValue { block } = raw_args[1].value() else {
                    return Ok(RuntimeValue::Undef);
                };

                let mut iterations = 0usize;
                while self
                    .eval_expr(raw_args[0].value(), ctx, rule_label)?
                    .as_bool()
                {
                    iterations += 1;
                    if iterations > LINKEDSPEC_WHILE_ITERATION_LIMIT {
                        return Err(Self::while_iteration_limit_message());
                    }
                    match self.execute_value_block_side_effects(block, ctx, rule_label)? {
                        ValueBlockFlow::Continue => {}
                        ValueBlockFlow::Returned(value) => return Ok(value),
                    }
                }
                Ok(RuntimeValue::Undef)
            }
            "with" => self.eval_with_trailing_block(raw_args, ctx, rule_label),
            "case" => {
                if raw_args.len() >= 2 {
                    let _ = self.eval_expr(raw_args[0].value(), ctx, rule_label)?;
                    return self.eval_expr(raw_args[1].value(), ctx, rule_label);
                }
                Ok(RuntimeValue::Undef)
            }
            "default" => {
                if let Some(raw) = raw_args.first() {
                    return self.eval_expr(raw.value(), ctx, rule_label);
                }
                Ok(RuntimeValue::Undef)
            }
            "endswitch" | "endcase" => Ok(RuntimeValue::Undef),
            _ => {
                eprintln!(
                    "warning: unknown helper '{}' in rule '{}' — returning undef",
                    name, rule_label
                );
                Ok(RuntimeValue::Undef)
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use linkedspec_core::compiler::compile;
    use linkedspec_core::parser::parse_spec;
    use linkedspec_core::validation::validate;

    const SIMPLE_GRAMMAR: &str = r#"DemoParser::
 /pattern1/ -> Child
 I { set(array(results), []) }
 LE { push(array(results), retv) }
 E { return(array("?results:", copy(array(results)))) }

Child::
 /hello[ \t]+(\w+)/
 I { name = entry_group(0) }
 E { return(name) }
"#;

    #[test]
    fn engine_executes_simple_grammar() {
        let spec = parse_spec(SIMPLE_GRAMMAR).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("pattern1 hello world").unwrap();
        assert!(result.is_array());
    }

    #[test]
    fn engine_empty_input() {
        let spec = parse_spec(SIMPLE_GRAMMAR).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("no match here").unwrap();
        assert!(result.is_array());
    }

    #[test]
    fn engine_json_output_roundtrip() {
        let spec = parse_spec(SIMPLE_GRAMMAR).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("pattern1 hello world").unwrap();
        let json_str = serde_json::to_string(&result).unwrap();
        let _parsed: Value = serde_json::from_str(&json_str).unwrap();
    }

    #[test]
    fn execute_value_returns_direct_rule_value_without_legacy_wrapper() {
        let grammar = r#"Top::
 /x/
 E { return("direct") }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let engine = Engine::new(compile(&spec).unwrap());
        assert_eq!(engine.execute("x").unwrap(), serde_json::json!(["direct"]));
        assert_eq!(
            engine.execute_value("x", &ExecutionOptions::new()).unwrap(),
            serde_json::json!("direct")
        );
    }

    #[test]
    fn execute_value_applies_entry_rule_and_parse_mode_per_invocation() {
        let grammar = r#"Top::
 /x/ -> Done { return("top") }

Alternate:
 /x/ -> Done { return("alternate") }

Done::
 /x/
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let engine = Engine::new(compile(&spec).unwrap());
        let alternate_seek = ExecutionOptions::new()
            .with_entry_rule("Alternate")
            .with_parse_mode(ParseMode::Seek);
        let alternate_consume = ExecutionOptions::new()
            .with_entry_rule("Alternate")
            .with_parse_mode(ParseMode::Consume);
        assert_eq!(
            engine.execute_value("prefix x", &alternate_seek).unwrap(),
            serde_json::json!("alternate")
        );
        assert_eq!(
            engine
                .execute_value("prefix x", &alternate_consume)
                .unwrap(),
            Value::Null
        );
        assert!(
            engine
                .execute_value("x", &ExecutionOptions::new().with_entry_rule("Missing"))
                .unwrap_err()
                .contains("entry rule 'Missing' is not defined")
        );
    }

    // ── Lifecycle order tests ──

    #[test]
    fn lifecycle_all_markers_fire_in_order() {
        // Grammar that exercises all 7 lifecycle markers with REP (* mode).
        let grammar = r#"Top::*
 /hello/
 I { set(array(log), []); push(array(log), "I") }
 LS { push(array(log), "LS") }
 LE { push(array(log), "LE") }
 IT { push(array(log), "IT") }
 LX { push(array(log), "LX") }
 EX { push(array(log), "EX") }
 E { push(array(log), "E"); return(copy(array(log))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        // "hello hello" → REP matches twice → I, LS, LE, IT, LS, LE, IT, EX, E
        let result = engine.execute("hello hello").unwrap();
        // Result is [["I","LS","LE","IT","LS","LE","IT","EX","E"]]
        let outer: &Vec<Value> = result.as_array().unwrap();
        let inner: &Vec<Value> = outer[0].as_array().unwrap();
        let strs: Vec<&str> = inner.iter().map(|v| v.as_str().unwrap()).collect();
        assert_eq!(strs[0], "I");
        assert!(strs.contains(&"LS"));
        assert!(strs.contains(&"LE"));
        assert!(strs.contains(&"IT"));
        assert!(strs.contains(&"EX"));
        assert_eq!(strs[strs.len() - 1], "E");
        // LX fires on loop exhaustion (when REP runs out of matches)
        assert!(strs.contains(&"LX"), "LX should fire on REP exhaustion");
    }

    #[test]
    fn lifecycle_lx_fires_on_no_match() {
        // Use * (0 or more) so that zero matches is valid; LX fires on first no-match.
        let grammar = r#"Top::*
 /hello/
 I { set(array(log), []); push(array(log), "I") }
 LS { push(array(log), "LS") }
 LX { push(array(log), "LX") }
 E { push(array(log), "E"); return(copy(array(log))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("no match").unwrap();
        let outer: &Vec<Value> = result.as_array().unwrap();
        let inner: &Vec<Value> = outer[0].as_array().unwrap();
        let strs: Vec<&str> = inner.iter().map(|v| v.as_str().unwrap()).collect();
        assert_eq!(strs[0], "I");
        assert_eq!(strs[1], "LS");
        assert_eq!(strs[2], "LX");
        assert_eq!(strs[3], "E");
    }

    #[test]
    fn default_mode_repeats_action_edge_choices_and_allows_zero_matches() {
        let grammar = r#"Top::
 -> Item .push
 LX.return(array("top", copy(array(Top))))

Item: /x/ I.return("x")
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);

        let repeated = engine.execute("xx").unwrap();
        assert_eq!(repeated, serde_json::json!([["top", ["x", "x"]]]));

        let empty = engine.execute("").unwrap();
        assert_eq!(empty, serde_json::json!([["top", []]]));
    }

    // ── REP bounds tests ──

    #[test]
    fn rep_min_not_met_returns_error() {
        // OR{2,} — minimum 2 matches required
        let grammar = r#"Top::OR{2,}
 /hello/
 E { return(1) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        // Only one "hello" — should fail
        let result = engine.execute("hello world");
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("expected at least 2 matches"));
    }

    #[test]
    fn rep_max_stops_at_bound() {
        // OR{,1} — at most 1 match
        let grammar = r#"Top::OR{,1}
 /hello/
 I { set(array(log), []) }
 LE { push(array(log), "match") }
 E { return(copy(array(log))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        // "hello hello" → should match only once due to max=1
        let result = engine.execute("hello hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(
            arr.len(),
            1,
            "expected 1 match due to max bound, got {:?}",
            arr
        );
    }

    #[test]
    fn rep_zero_or_more_matches_nothing() {
        // * — zero or more, should succeed with zero matches
        let grammar = r#"Top::*
 /hello/
 E { return(1) }
"#;
        let spec = parse_spec(grammar).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("no match").unwrap();
        assert!(result.is_array());
    }

    // ── Blind-call dispatch tests ──

    #[test]
    fn blind_call_and_rule_dispatches_children() {
        // Child dispatch is still allowed to mutate caller-visible working
        // variables when the child does not bind the same name locally.
        let grammar = r#"Top::AND
 I { set(array(log), []) }
 => ChildA
 => ChildB
 E { return(copy(array(log))) }

ChildA:
 /a/
 I { push(array(log), "A") }

ChildB:
 /b/
 I { push(array(log), "B") }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("a b").unwrap();
        let outer: &Vec<Value> = result.as_array().unwrap();
        assert!(!outer.is_empty());
        let inner: &Vec<Value> = outer[0].as_array().unwrap();
        assert_eq!(
            inner.len(),
            2,
            "expected 2 children in log, got {:?}",
            inner
        );
        assert_eq!(inner[0].as_str().unwrap(), "A");
        assert_eq!(inner[1].as_str().unwrap(), "B");
    }

    // ── Self-recursive / multi-entrypoint tests ──

    #[test]
    fn self_recursive_rule_uses_different_entrypoints() {
        // Rule enters itself at different regex slots
        let grammar = r#"A::
 /[A-Za-z_]\w*/
 /"(?:[^"\\]|\\.)*"/
 /\d+/
 I { set(array(results), []) }
 -> A
 -> A[1]
 -> A[2]
 E { return(copy(array(results))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        // Matches identifier, then identifier fallback
        let result = engine.execute(r#"hello"#).unwrap();
        assert!(result.is_array());
    }

    // ── Accumulator tests ──

    #[test]
    fn accumulator_collects_child_results() {
        let grammar = r#"DemoParser::
 /pattern1/ -> ChildA
 /pattern2/ -> ChildB
 I { set(array(results), []) }
 LE { push(array(results), retv) }
 E { return(array("?results:", copy(array(results)))) }

ChildA:
 /hello/
 I { retv = entry_text() }
 E { return(retv) }

ChildB:
 /world/
 I { retv = entry_text() }
 E { return(retv) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("pattern1 hello pattern2 world").unwrap();
        let arr = result.as_array().unwrap();
        assert!(!arr.is_empty());
    }

    // ── Keyword argument tests ──

    #[test]
    fn declare_with_keyword_arg_initializer() {
        // Declare in I, populate in E (entry_text() is valid AFTER match)
        let grammar = r#"Top::
 /hello/
 I { name = undef }
 E { name = entry_text(); return(name) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let outer: &Vec<Value> = result.as_array().unwrap();
        assert_eq!(outer[0].as_str().unwrap(), "hello");
    }

    // ── .5.1 Declaration and array helper tests ──

    #[test]
    fn helpers_5_1_declare_scalar_with_default() {
        let grammar = r#"Top::
 /hello/
 I { name = undef }
 E { return(name) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        // scalar declared without initializer returns undef → JSON null
        let arr = result.as_array().unwrap();
        assert!(arr[0].is_null(), "expected null, got {:?}", arr[0]);
    }

    #[test]
    fn helpers_5_1_declare_scalar_with_initializer() {
        // entry_group is only available AFTER match, so use LE to assign
        let grammar = r#"Top::
 /(\w+)/
 I { word = undef }
 LE { word = entry_group(0) }
 E { return(word) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "hello");
    }

    #[test]
    fn helpers_5_1_assign_scalar() {
        let grammar = r#"Top::
 /(\w+)/
 I { word = undef }
 E { word = entry_group(0); return(word) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "hello");
    }

    #[test]
    fn helpers_5_1_declare_array_push_value_copy() {
        let grammar = r#"Top::
 /(\w+)/
 I { set(array(results), []) }
 LE { push(array(results), entry_group(0)) }
 E { return(copy(array(results))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let outer: &Vec<Value> = result.as_array().unwrap();
        let inner: &Vec<Value> = outer[0].as_array().unwrap();
        assert_eq!(inner[0].as_str().unwrap(), "hello");
    }

    #[test]
    fn helpers_5_1_return_value_and_count() {
        let grammar = r#"Top::
 /(\w+)/
 I { set(array(items), []); item_count = undef }
 LE { push(array(items), entry_group(0)) }
 E { item_count = count(array(items)); return(item_count) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert!(arr[0].is_number(), "expected number, got {:?}", arr[0]);
        assert_eq!(arr[0].as_f64().unwrap(), 1.0);
    }

    #[test]
    fn helpers_5_1_explicit_nonempty_guarded_push() {
        let grammar = r#"Top::
 /(\w+)/
 I { set(array(items), []) }
 LE { if(is_nonempty(entry_group(0)), push(array(items), entry_group(0))) }
 E { return(copy(array(items))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let outer: &Vec<Value> = result.as_array().unwrap();
        let inner: &Vec<Value> = outer[0].as_array().unwrap();
        assert!(!inner.is_empty());
    }

    #[test]
    fn helpers_5_1_hash_roundtrip() {
        // Use hash() constructor and copy() for roundtrip
        let grammar = r#"Top::
 /(\w+)=(\d+)/
 I { set(hash(config), hash()) }
 LE { set_key(hash(config), entry_group(0), entry_group(1)) }
 E { return(entry_group(0)) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("key=42").unwrap();
        let arr = result.as_array().unwrap();
        // Returns the matched key
        assert_eq!(arr[0].as_str().unwrap(), "key");
    }

    #[test]
    fn helpers_5_1_unknown_helper_spellings_use_generic_unknown_helper_path() {
        fn execute_snippet(snippet: &str) -> Value {
            let grammar = format!("Top::\n /x/\n E {{ {snippet} }}\n");
            let spec = parse_spec(&grammar).expect("parse unknown-helper fixture");
            validate(&spec).expect("validate unknown-helper fixture");
            let compiled = compile(&spec).expect("compile unknown-helper fixture");
            Engine::new(compiled)
                .execute("x")
                .expect("generic unknown helper should return undef instead of failing")
        }

        let cases = [
            (
                "unknown_decl_helper(v); return(v)",
                serde_json::json!([null]),
            ),
            (
                "return(unknown_array_copy_helper(array(items)))",
                serde_json::json!([null]),
            ),
            (
                "return(unknown_hash_copy_helper(hash(meta)))",
                serde_json::json!([null]),
            ),
            (
                "return(unknown_concat_helper(\"a\", \"b\"))",
                serde_json::json!([null]),
            ),
            (
                "unknown_push_value_helper(array(items), \"a\"); return(copy(array(items)))",
                serde_json::json!([[]]),
            ),
            (
                "unknown_push_nonempty_helper(array(items), \"a\"); return(copy(array(items)))",
                serde_json::json!([[]]),
            ),
            (
                "return(unknown_array_wrapper(items))",
                serde_json::json!([null]),
            ),
            (
                "return(unknown_hash_wrapper(meta))",
                serde_json::json!([null]),
            ),
        ];

        for (snippet, expected) in cases {
            assert_eq!(
                execute_snippet(snippet),
                expected,
                "unknown helper spelling should follow generic unknown-helper behavior: {snippet}"
            );
        }
    }

    // ── .5.2 Scalar and capture helper tests ──

    #[test]
    fn helpers_5_2_entry_text_and_entry_group() {
        let grammar = r#"Top::
 /hello[ \t]+(\w+)/
 E { return(cat(entry_text(), " ", entry_group(0))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello world").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "hello world world");
    }

    #[test]
    fn helpers_5_2_entry_groups_array() {
        let grammar = r#"Top::
 /(\w+)=(\d+)/
 E { return(entry_groups()) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("key=42").unwrap();
        let outer: &Vec<Value> = result.as_array().unwrap();
        let groups: &Vec<Value> = outer[0].as_array().unwrap();
        assert_eq!(
            groups,
            &vec![serde_json::json!("key"), serde_json::json!("42")]
        );
    }

    #[test]
    fn helpers_5_2_scalar_accessor() {
        // varname returns the declared variable's value
        let grammar = r#"Top::
 /(\w+)/
 I { word = undef }
 LE { word = entry_group(0) }
 E { return(word) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "hello");
    }

    #[test]
    fn helpers_5_2_coalesce_first_defined() {
        let grammar = r#"Top::
 /(\w+)/
 I { first = undef; second = undef }
 E { return(coalesce(first, second, "default")) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        // Both first and second are undef, so coalesce falls back to "default"
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "default");
    }

    #[test]
    fn helpers_5_2_coalesce_short_circuits() {
        let grammar = r#"Top::
 /(\w+)/
 I { val = undef }
 LE { val = entry_group(0) }
 E { return(coalesce(val, "fallback")) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "hello");
    }

    #[test]
    fn helpers_5_2_concat_strings() {
        let grammar = r#"Top::
 /(\w+) (\w+)/
 E { return(cat(entry_group(0), "+", entry_group(1))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello world").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "hello+world");
    }

    #[test]
    fn helpers_5_2_capture_slice_basic() {
        // RUST-PARITY.5.5.4: `capture_slice()` now ends at the START of the current
        // local match (Perl `$LSPOS - $IPOS - length $LMATCH`), not the cursor. The
        // I-block starts the capture at pos 0; over "hello" the match also starts at
        // 0, so nothing precedes the match → "" (parity-correct; see
        // helpers_5_5_4_capture_slice_reads_pre_match_text for the non-empty case).
        let grammar = r#"Top::
 /(\w+)/
 I { start_capture_slice() }
 LE { return(capture_slice()) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "");
    }

    #[test]
    fn helpers_5_2_capture_slice_len() {
        // RUST-PARITY.5.5.4: capture started at the match start (pos 0) → length 0.
        let grammar = r#"Top::
 /(\w+)/
 I { start_capture_slice() }
 LE { return(capture_slice_len()) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_f64().unwrap(), 0.0);
    }

    #[test]
    fn helpers_5_2_mark_and_capture_from() {
        // RUST-PARITY.5.5.3: `capture_from(mark)` now ends at the **start** of the
        // current local match (Perl parity: `$LSPOS - length $LMATCH`), not the
        // cursor / match-end. The mark is set at pos 0 (I-block) and the match
        // "hello" also starts at byte 0, so the span mark→match-start is empty.
        // (Before .5.5.3 this wrongly read to match-end and returned "hello".)
        let grammar = r#"Top::
 /(\w+)/
 I { mark_here("start") }
 LE { return(capture_from("start")) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "");
    }

    #[test]
    fn helpers_5_2_mark_pos() {
        let grammar = r#"Top::
 /(\w+)/
 I { mark_here("pos") }
 LE { return(mark_pos("pos")) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_f64().unwrap(), 0.0); // mark at start of input (pos 0 in I-block)
    }

    // ── .5.3 Control flow helper tests ──

    #[test]
    fn helpers_5_3_return_undef_skips_accumulator() {
        let grammar = r#"Top::
 /(\w+)/
 I { set(array(items), []) }
 LE { push(array(items), entry_group(0)) }
 E { return(copy(array(items))); return_undef() }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        // return_undef after return — doesn't add to accumulator
        assert!(!arr.is_empty());
    }

    #[test]
    fn helpers_5_3_exit_now_terminates() {
        let grammar = r#"Top::
 /bye/
 I { exit_now(1) }
 E { return("never_reached") }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("bye");
        assert!(result.is_err(), "exit_now should terminate with error");
        assert!(result.unwrap_err().contains("exit_now(1)"));
    }

    #[test]
    fn helpers_5_3_next_skips() {
        // next() returns undef — used as control flow skip in loops
        let grammar = r#"Top::
 /(\w+)/
 I { retv = next() }
 E { return(retv) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        // next() returns undef
        assert!(
            arr[0].is_null(),
            "next() should return null, got {:?}",
            arr[0]
        );
    }

    #[test]
    fn helpers_5_3_coalesce_nonempty_skips_empty() {
        // coalesce_nonempty skips undef and "" but keeps "0" and other defined values
        let grammar = r#"Top::
 /(\d+)/
 I { val = undef }
 LE { val = entry_group(0) }
 E { return(coalesce_nonempty("", val, "final")) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("42").unwrap();
        let arr = result.as_array().unwrap();
        // "" is nonempty? Actually "" returns Scalar("") which IS empty
        // coalesce_nonempty skips empty strings, picks "42"
        assert_eq!(arr[0].as_str().unwrap(), "42");
    }

    // ═══════════════════════════════════════════════════════════
    // Conditional flow tests — if/elseif/else/switch/case/default
    // ═══════════════════════════════════════════════════════════

    #[test]
    fn cond_if_basic_then_branch() {
        let grammar = r#"Top::
 /(\w+)/
 I { val = undef }
 LE { val = entry_group(0) }
 E { return(if(is_nonempty(val), "found", "empty")) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "found");
    }

    #[test]
    fn cond_if_falsy_falls_through_to_else() {
        // Undef variable → condition falsy → else branch
        let grammar = r#"Top::
 /(\w+)/
 I { val = undef }
 E { return(if(is_defined(val), "defined", "undefined")) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        // val declared but never assigned → undef → is_defined false → "undefined"
        assert_eq!(arr[0].as_str().unwrap(), "undefined");
    }

    #[test]
    fn cond_if_three_arg_else_fallback() {
        // if(cond, then, else) — 3 positional args
        let grammar = r#"Top::
 /(\w+)/
 I { val = undef }
 LE { val = entry_group(0) }
 E { return(if(is_defined(val), entry_text(), "fallback")) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        // val IS defined (we assigned it in LE), so then-branch returns entry_text
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "hello");
    }

    #[test]
    fn cond_if_with_elseif_chain() {
        // 0 is falsy, 1 is truthy — tests if/elseif chain with literal conditions
        let grammar = r#"Top::
 /(\w+)/
 E { return(if(0, "then",
               elseif(1, "elseif_ok"),
               "none")) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        // 0 is falsy → skip then. 1 is truthy → "elseif_ok"
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "elseif_ok");
    }

    #[test]
    fn cond_if_all_falsy_falls_to_else() {
        let grammar = r#"Top::
 /(\w+)/
 I { a = undef; b = undef; c = undef }
 E { return(if(is_nonempty(a), "a",
               elseif(is_nonempty(b), "b"),
               else("none"))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        // None of a, b assigned → all empty/undef → "none"
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "none");
    }

    #[test]
    fn cond_switch_basic_case_match() {
        let grammar = r#"Top::
 /(\w+)/
 I { val = undef }
 LE { val = entry_group(0) }
 E { return(switch(val,
               case("hello", "greeting"),
               case("world", "planet"),
               default("unknown"))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "greeting");
    }

    #[test]
    fn cond_switch_no_match_falls_to_default() {
        let grammar = r#"Top::
 /(\w+)/
 I { val = undef }
 LE { val = entry_group(0) }
 E { return(switch(val,
               case("red", "color"),
               default("not_a_color"))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "not_a_color");
    }

    #[test]
    fn cond_switch_multiple_cases() {
        let grammar = r#"Top::
 /(\d+)/
 I { val = undef }
 LE { val = entry_group(0) }
 E { return(switch(val,
               case("1", "one"),
               case("2", "two"),
               case("3", "three"),
               default("many"))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("3").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "three");
    }

    #[test]
    fn cond_endif_and_endswitch_are_noops() {
        let grammar = r#"Top::
 /(\w+)/
 E { endif(); endswitch(); endcase(); return("ok") }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "ok");
    }

    #[test]
    fn cond_if_with_lazy_evaluation_side_effects() {
        // The else branch contains exit_now(1) — if lazy evaluation works,
        // it should NOT be called when condition is truthy.
        let grammar = r#"Top::
 /(\w+)/
 I { val = undef }
 LE { val = entry_group(0) }
 E { return(if(is_defined(val), entry_text(), exit_now(1))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        // val IS defined, so else branch (exit_now) should NOT execute
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "hello");
    }

    #[test]
    fn cond_if_lazy_evaluation_elseif() {
        // elseif branch contains exit_now(1) — if lazy evaluation works,
        // it should NOT be called when the if-condition is truthy.
        let grammar = r#"Top::
 /(\w+)/
 I { val = undef }
 LE { val = entry_group(0) }
 E { return(if(is_defined(val), "ok",
               elseif(is_empty(val), exit_now(1)),
               "fallback")) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        // val IS defined, so elseif branch should NOT execute
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "ok");
    }

    // ═══════════════════════════════════════════════════════════
    // Explicit cursor-control tests
    // ═══════════════════════════════════════════════════════════

    #[test]
    fn cursor_stack_save_and_restore_cursor() {
        let grammar = r#"Top::
 /hello/
 I { save_cursor() }
 E { return(restore_cursor()) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        // restore_cursor returns undef, save_cursor saves position
        let result = engine.execute("hello");
        assert!(result.is_ok(), "expected ok, got {:?}", result);
        let val = result.unwrap();
        let arr = val.as_array().unwrap();
        assert!(arr[0].is_null());
    }

    #[test]
    fn cursor_stack_restores_position_for_retry() {
        // Save position before match, restore on no-match via LX
        let grammar = r#"Top::OR{1}
 /hello/
 I { save_cursor() }
 E { return() }
 LX { restore_cursor() }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello");
        assert!(
            result.is_ok(),
            "cursor restore should succeed, got {:?}",
            result
        );
    }

    #[test]
    fn cursor_stack_empty_restore_no_op() {
        // restore_cursor with empty stack should not crash
        let grammar = r#"Top::
 /(\w+)/
 E { restore_cursor(); return(entry_group(0)) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr[0].as_str().unwrap(), "hello");
    }

    #[test]
    fn cursor_stack_multiple_save_restore() {
        // save_cursor saves position; restore_cursor restores it
        let grammar = r#"Top::
 /(hello) (world)/
 I { set(array(log), []); save_cursor() }
 LE { push(array(log), cursor_pos()) }
 E { push(array(log), cursor_pos());
      restore_cursor(); push(array(log), cursor_pos());
      return(copy(array(log))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello world");
        assert!(
            result.is_ok(),
            "cursor save/restore should work, got {:?}",
            result
        );
    }

    #[test]
    fn cursor_rewinds_to_entry_or_match_start() {
        let entry_grammar = r#"Top::AND
 I { set(array(log), []) }
 /ab/ -> Top[0] { push(array(log), hash("slot", 0, "cursor", cursor_pos(), "entry_start", entry_start_pos(), "match_start", match_start_pos())) }
 /cd/ -> Top[1] {
   before = cursor_pos();
   rewind_entry_start();
   push(array(log), hash("slot", 1, "before", before, "after", cursor_pos(), "entry_start", entry_start_pos(), "match_start", match_start_pos(), "rest", cursor_rest()))
 }
 E { return(copy(array(log))) }
"#;
        let match_grammar = r#"Top::AND
 I { set(array(log), []) }
 /ab/ -> Top[0] { push(array(log), hash("slot", 0, "cursor", cursor_pos(), "entry_start", entry_start_pos(), "match_start", match_start_pos())) }
 /cd/ -> Top[1] {
   before = cursor_pos();
   rewind_match_start();
   push(array(log), hash("slot", 1, "before", before, "after", cursor_pos(), "entry_start", entry_start_pos(), "match_start", match_start_pos(), "rest", cursor_rest()))
 }
 E { return(copy(array(log))) }
"#;
        let entry_engine = Engine::new(compile(&parse_spec(entry_grammar).unwrap()).unwrap());
        let match_engine = Engine::new(compile(&parse_spec(match_grammar).unwrap()).unwrap());
        let entry_json = entry_engine.execute("abcd").unwrap();
        let match_json = match_engine.execute("abcd").unwrap();
        let entry_outer = entry_json.as_array().unwrap();
        let match_outer = match_json.as_array().unwrap();
        let entry_arr = entry_outer[0].as_array().unwrap();
        let match_arr = match_outer[0].as_array().unwrap();
        assert_eq!(
            entry_arr[0].get("cursor").and_then(|v| v.as_f64()),
            Some(2.0)
        );
        assert_eq!(
            entry_arr[1].get("after").and_then(|v| v.as_f64()),
            Some(0.0)
        );
        assert_eq!(
            entry_arr[1].get("rest").and_then(|v| v.as_str()),
            Some("abcd")
        );
        assert_eq!(
            match_arr[0].get("cursor").and_then(|v| v.as_f64()),
            Some(2.0)
        );
        assert_eq!(
            match_arr[1].get("after").and_then(|v| v.as_f64()),
            Some(2.0)
        );
        assert_eq!(
            match_arr[1].get("rest").and_then(|v| v.as_str()),
            Some("cd")
        );
    }

    // ── RUST-PARITY.5.3 — char-based (not byte) offsets/slicing ──
    //
    // Internal positions (`ctx.pos`, marks, match spans, regex offsets) are byte
    // offsets, but the Perl reference exposes char offsets (`pos()`/`length`/
    // `substr` are char-based). These tests use multibyte UTF-8 input ('é' is two
    // bytes), where byte-based slicing would panic on a char boundary and every
    // position/length would diverge from Perl by the number of multibyte chars.

    // Helper: parse → validate → compile → execute, return the accumulator JSON.
    fn run_5_3(grammar: &str, input: &str) -> Vec<serde_json::Value> {
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        engine.execute(input).unwrap().as_array().unwrap().clone()
    }

    #[test]
    fn helpers_5_3_split_accepts_regex_literal_delimiter() {
        let grammar = r#"Top::
 /x/
 E { return("left , right,third".split(/\s*,\s*/).trim_each()) }
"#;
        let acc = run_5_3(grammar, "x");
        assert_eq!(
            acc.last().unwrap(),
            &serde_json::json!(["left", "right", "third"])
        );
    }

    #[test]
    fn helpers_5_3_split_each_accepts_regex_literal_delimiter() {
        let grammar = r#"Top::
 /x/
 E { return(["a, b", "c ,d"].split_each(/\s*,\s*/).trim_each()) }
"#;
        let acc = run_5_3(grammar, "x");
        assert_eq!(
            acc.last().unwrap(),
            &serde_json::json!(["a", "b", "c", "d"])
        );
    }

    #[test]
    fn chars_5_3_substr_is_char_based_no_panic() {
        // substr(café, 3, 1) = "é" (char index 3). Byte-slicing s[3..4] would
        // panic — byte 3 is the first of the two bytes of 'é'.
        let grammar = r#"Top::
 /café/
 E { return(substr(entry_text(), 3, 1)) }
"#;
        let acc = run_5_3(grammar, "café");
        assert_eq!(acc.last().unwrap().as_str().unwrap(), "é");
    }

    #[test]
    fn chars_5_3_input_slice_is_char_based() {
        // input_slice(start=3, width=1) over "café" = "é" (char offsets).
        let grammar = r#"Top::
 /café/
 E { return(input_slice(3, 1)) }
"#;
        let acc = run_5_3(grammar, "café");
        assert_eq!(acc.last().unwrap().as_str().unwrap(), "é");
    }

    #[test]
    fn chars_5_3_cursor_pos_is_char_offset() {
        // After matching "café" the cursor is at byte 5 but char offset 4.
        let grammar = r#"Top::
 /café/
 E { return(cursor_pos()) }
"#;
        let acc = run_5_3(grammar, "café x");
        assert_eq!(acc.last().unwrap().as_f64().unwrap(), 4.0);
    }

    #[test]
    fn chars_5_3_cursor_col_is_char_based() {
        // "héllo" is 6 bytes / 5 chars; column after it = 5 + 1 = 6 (char-based).
        let grammar = r#"Top::
 /héllo/
 E { return(cursor_col()) }
"#;
        let acc = run_5_3(grammar, "héllo");
        assert_eq!(acc.last().unwrap().as_f64().unwrap(), 6.0);
    }

    #[test]
    fn chars_5_3_match_start_pos_not_hardcoded_zero() {
        // "world" seek-matches after "héllo " (6 chars / 7 bytes): char start 6.
        // Previously match_start_pos was hardcoded to 0.0.
        let grammar = r#"Top::
 /world/
 E { return(match_start_pos()) }
"#;
        let acc = run_5_3(grammar, "héllo world");
        assert_eq!(acc.last().unwrap().as_f64().unwrap(), 6.0);
    }

    #[test]
    fn chars_5_3_entry_start_pos_not_hardcoded_zero() {
        // Top rule's entry match = its own match; "world" starts at char 3 after
        // "hi " — entry_start_pos must be 3, not the old hardcoded 0.0.
        let grammar = r#"Top::
 /world/
 E { return(entry_start_pos()) }
"#;
        let acc = run_5_3(grammar, "hi world");
        assert_eq!(acc.last().unwrap().as_f64().unwrap(), 3.0);
    }

    #[test]
    fn chars_5_3_length_is_char_count() {
        // length("café") = 4 chars (not 5 bytes).
        let grammar = r#"Top::
 /café/
 E { return(length(entry_text())) }
"#;
        let acc = run_5_3(grammar, "café");
        assert_eq!(acc.last().unwrap().as_f64().unwrap(), 4.0);
    }

    // ── RUST-PARITY.5.4 — dedup shadowed arms + REP zero-progress guard ──

    #[test]
    fn rep_5_4_zero_progress_guard_terminates() {
        // A REP rule whose regex matches zero-width (`/x*/` on input with no
        // 'x' matches the empty string at the cursor) makes no progress. The
        // guard must break after one no-progress iteration; the old guard only
        // broke after 100 iterations, so it would have collected 100+ entries.
        let grammar = r#"Top::OR+
 /x*/
 I { set(array(iters), []) }
 LE { push(array(iters), "i") }
 E { return(copy(array(iters))) }
"#;
        let acc = run_5_3(grammar, "abc");
        let iters = acc.last().unwrap().as_array().unwrap();
        assert_eq!(
            iters.len(),
            1,
            "zero-width REP must stop after one no-progress iteration, got {iters:?}"
        );
    }

    #[test]
    fn hash_constructor_only_splices_explicit_flat_hash_args() {
        // Ordinary hash-valued pair values stay nested. Explicit flat_hash is
        // the list-context splice operation.
        let grammar = r#"Top:: /(\w+)/
 E { return(array(hash("nested", hash("a", "1")), hash("b", "2", flat_hash(hash("a", "1"))))) }
"#;
        let acc = run_5_3(grammar, "x");
        assert_eq!(
            acc.last(),
            Some(&serde_json::json!([
                {"nested": {"a": "1"}},
                {"a": "1", "b": "2"}
            ]))
        );
    }

    // ── RUST-PARITY.5.5.1 — named-group readers (entry/match _named/_has/_map) ──

    /// Parse → validate → compile → execute, returning the accumulator array.
    fn run_5_5_1(grammar: &str, input: &str) -> Vec<Value> {
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        Engine::new(compiled)
            .execute(input)
            .unwrap()
            .as_array()
            .unwrap()
            .clone()
    }

    #[test]
    fn helpers_5_5_1_entry_named_reads_named_group() {
        // entry_named(name) returns the named capture's value as a string.
        let present = r#"Top::
 /(?P<year>\d+)-(?P<month>\d+)/
 E { return(entry_named("year")) }
"#;
        let acc = run_5_5_1(present, "2024-03");
        assert_eq!(acc.last().unwrap().as_str().unwrap(), "2024");

        let bare_name = r#"Top::
 /(?P<year>\d+)-(?P<month>\d+)/
 E { return(entry_named(year)) }
"#;
        let acc = run_5_5_1(bare_name, "2024-03");
        assert_eq!(acc.last().unwrap().as_str().unwrap(), "2024");

        // An absent name returns undef (JSON null), per the catalog.
        let absent = r#"Top::
 /(?P<year>\d+)/
 E { return(entry_named("nope")) }
"#;
        let acc = run_5_5_1(absent, "2024");
        assert!(
            acc.last().unwrap().is_null(),
            "absent named group must be undef, got {:?}",
            acc.last()
        );
    }

    #[test]
    fn helpers_5_5_1_entry_has_presence() {
        // entry_has(name) returns Perl-compatible numeric 1/0 presence.
        let g_present = r#"Top::
 /(?P<word>\w+)/
 E { return(entry_has("word")) }
"#;
        assert_eq!(
            run_5_5_1(g_present, "hi").last().unwrap().as_f64(),
            Some(1.0)
        );

        let g_present_bare = r#"Top::
 /(?P<word>\w+)/
 E { return(entry_has(word)) }
"#;
        assert_eq!(
            run_5_5_1(g_present_bare, "hi").last().unwrap().as_f64(),
            Some(1.0)
        );

        let g_absent = r#"Top::
 /(?P<word>\w+)/
 E { return(entry_has("missing")) }
"#;
        assert_eq!(
            run_5_5_1(g_absent, "hi").last().unwrap().as_f64(),
            Some(0.0)
        );
    }

    #[test]
    fn helpers_5_5_1_entry_map_and_alias() {
        // entry_map() returns all named groups as a hash; entry_named_map() is a
        // retired alias that must behave identically.
        let g_map = r#"Top::
 /(?P<a>\w+)-(?P<b>\w+)/
 E { return(entry_map()) }
"#;
        let acc = run_5_5_1(g_map, "hello-world");
        let obj = acc.last().unwrap().as_object().unwrap();
        assert_eq!(obj.get("a").and_then(|v| v.as_str()), Some("hello"));
        assert_eq!(obj.get("b").and_then(|v| v.as_str()), Some("world"));
        assert_eq!(obj.len(), 2);

        let g_alias = r#"Top::
 /(?P<a>\w+)-(?P<b>\w+)/
 E { return(entry_named_map()) }
"#;
        let acc = run_5_5_1(g_alias, "hello-world");
        let obj = acc.last().unwrap().as_object().unwrap();
        assert_eq!(obj.get("a").and_then(|v| v.as_str()), Some("hello"));
        assert_eq!(obj.get("b").and_then(|v| v.as_str()), Some("world"));
    }

    #[test]
    fn helpers_5_5_1_match_named_reads_named_group() {
        // match_named reads the LOCAL match's named groups. On a top rule the
        // entry and local match coincide, so the value is readable here.
        let present = r#"Top::
 /(?P<year>\d+)-(?P<month>\d+)/
 E { return(match_named("month")) }
"#;
        let acc = run_5_5_1(present, "2024-03");
        assert_eq!(acc.last().unwrap().as_str().unwrap(), "03");

        let bare_name = r#"Top::
 /(?P<year>\d+)-(?P<month>\d+)/
 E { return(match_named(month)) }
"#;
        let acc = run_5_5_1(bare_name, "2024-03");
        assert_eq!(acc.last().unwrap().as_str().unwrap(), "03");

        let absent = r#"Top::
 /(?P<year>\d+)/
 E { return(match_named("nope")) }
"#;
        assert!(run_5_5_1(absent, "2024").last().unwrap().is_null());
    }

    #[test]
    fn helpers_5_5_1_match_has_presence() {
        let g_present = r#"Top::
 /(?P<word>\w+)/
 E { return(match_has("word")) }
"#;
        assert_eq!(
            run_5_5_1(g_present, "hi").last().unwrap().as_f64(),
            Some(1.0)
        );

        let g_present_bare = r#"Top::
 /(?P<word>\w+)/
 E { return(match_has(word)) }
"#;
        assert_eq!(
            run_5_5_1(g_present_bare, "hi").last().unwrap().as_f64(),
            Some(1.0)
        );

        let g_absent = r#"Top::
 /(?P<word>\w+)/
 E { return(match_has("missing")) }
"#;
        assert_eq!(
            run_5_5_1(g_absent, "hi").last().unwrap().as_f64(),
            Some(0.0)
        );
    }

    #[test]
    fn helpers_5_5_1_match_map_and_alias() {
        // match_map() and its retired alias match_named_map() both return the
        // local match's named groups as a hash.
        let g_map = r#"Top::
 /(?P<a>\w+)-(?P<b>\w+)/
 E { return(match_map()) }
"#;
        let acc = run_5_5_1(g_map, "foo-bar");
        let obj = acc.last().unwrap().as_object().unwrap();
        assert_eq!(obj.get("a").and_then(|v| v.as_str()), Some("foo"));
        assert_eq!(obj.get("b").and_then(|v| v.as_str()), Some("bar"));

        let g_alias = r#"Top::
 /(?P<a>\w+)-(?P<b>\w+)/
 E { return(match_named_map()) }
"#;
        let acc = run_5_5_1(g_alias, "foo-bar");
        let obj = acc.last().unwrap().as_object().unwrap();
        assert_eq!(obj.get("a").and_then(|v| v.as_str()), Some("foo"));
        assert_eq!(obj.get("b").and_then(|v| v.as_str()), Some("bar"));
    }

    // ── RUST-PARITY.5.5.2 — input-boundary helpers + the `flat` splice ──

    /// Parse → validate → compile → execute, returning the accumulator array.
    fn run_5_5_2(grammar: &str, input: &str) -> Vec<Value> {
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        Engine::new(compiled)
            .execute(input)
            .unwrap()
            .as_array()
            .unwrap()
            .clone()
    }

    #[test]
    fn helpers_5_5_2_input_end_line_counts_newlines() {
        // input_end_line() = 1 + newline count over the WHOLE input (not the cursor).
        let g = r#"Top::
 /\w/
 E { return(input_end_line()) }
"#;
        assert_eq!(run_5_5_2(g, "abc").last().unwrap().as_f64().unwrap(), 1.0); // no newline
        assert_eq!(
            run_5_5_2(g, "a\nb\nc").last().unwrap().as_f64().unwrap(),
            3.0
        ); // 2 newlines
        assert_eq!(
            run_5_5_2(g, "a\nb\n").last().unwrap().as_f64().unwrap(),
            3.0
        ); // trailing newline
    }

    #[test]
    fn helpers_5_5_2_input_end_col_is_char_based() {
        // input_end_col(): char distance past the last newline, +1 when none.
        let g = r#"Top::
 /\w/
 E { return(input_end_col()) }
"#;
        assert_eq!(run_5_5_2(g, "abc").last().unwrap().as_f64().unwrap(), 4.0); // len 3, no nl → 4
        assert_eq!(
            run_5_5_2(g, "ab\ncde").last().unwrap().as_f64().unwrap(),
            4.0
        ); // "cde" past nl → 4
        assert_eq!(run_5_5_2(g, "ab\n").last().unwrap().as_f64().unwrap(), 1.0); // empty final line → 1
        // Char-based, not byte-based: 'é' is 2 bytes but 1 column → "héllo" = 5 chars → 6.
        assert_eq!(run_5_5_2(g, "héllo").last().unwrap().as_f64().unwrap(), 6.0);
    }

    #[test]
    fn helpers_5_5_2_flat_array_and_hash() {
        // flat(array) yields the array's elements as a list value.
        let g_arr = r#"Top::
 /\w/
 E { return(flat(array("a", "b"))) }
"#;
        let acc = run_5_5_2(g_arr, "x");
        let arr = acc.last().unwrap().as_array().unwrap();
        assert_eq!(arr.len(), 2);
        assert_eq!(arr[0].as_str().unwrap(), "a");
        assert_eq!(arr[1].as_str().unwrap(), "b");

        // flat(hash) splices key/value entries into a parent hash(...).
        let g_hash = r#"Top::
 /\w/
 E { return(hash("a", "1", flat(hash("b", "2")))) }
"#;
        let acc = run_5_5_2(g_hash, "x");
        let obj = acc.last().unwrap().as_object().unwrap();
        assert_eq!(obj.get("a").and_then(|v| v.as_str()), Some("1"));
        assert_eq!(obj.get("b").and_then(|v| v.as_str()), Some("2"));
        assert_eq!(obj.len(), 2);
    }

    // ── RUST-PARITY.5.5.3: mark-based capture family ──
    // Use explicit `OR{1,1}` so these tests stay focused on capture/mark
    // endpoints around one seek match. Bare default rules are repeated-choice
    // loops, so a later word in the input would intentionally move the cursor.
    // `mark_input_start` pins a mark at 0, `mark_input_end` at the byte length,
    // giving deterministic spans independent of the match.
    fn run_5_5_3(grammar: &str, input: &str) -> Vec<Value> {
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        Engine::new(compiled)
            .execute(input)
            .unwrap()
            .as_array()
            .unwrap()
            .clone()
    }

    #[test]
    fn helpers_5_5_3_capture_from_reads_to_match_start() {
        // mark at 0, match "hi" starts at byte 2 → the pre-match text "  ".
        let g = r#"Top::OR{1,1}
 /(\w+)/
 E { mark_input_start("a"); return(capture_from("a")) }
"#;
        let acc = run_5_5_3(g, "  hi");
        assert_eq!(acc[0].as_str().unwrap(), "  ");
    }

    #[test]
    fn helpers_5_5_3_capture_from_undef_on_missing_mark() {
        let g = r#"Top::OR{1,1}
 /(\w+)/
 E { return(capture_from("nope")) }
"#;
        let acc = run_5_5_3(g, "hi");
        assert!(acc[0].is_null(), "missing mark → undef, got {:?}", acc[0]);
    }

    #[test]
    fn helpers_5_5_3_capture_len_from_is_char_count() {
        let g = r#"Top::OR{1,1}
 /(\w+)/
 E { mark_input_start("a"); return(capture_len_from("a")) }
"#;
        let acc = run_5_5_3(g, "  hi");
        assert_eq!(acc[0].as_f64().unwrap(), 2.0); // "  " before the match
    }

    #[test]
    fn helpers_5_5_3_capture_until_cursor_from() {
        // mark 0 → cursor (match-end of "ab" = byte 2).
        let g = r#"Top::OR{1,1}
 /(\w+)/
 E { mark_input_start("a"); return(capture_until_cursor_from("a")) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        assert_eq!(acc[0].as_str().unwrap(), "ab");
    }

    #[test]
    fn helpers_5_5_3_capture_until_cursor_len_from() {
        let g = r#"Top::OR{1,1}
 /(\w+)/
 E { mark_input_start("a"); return(capture_until_cursor_len_from("a")) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        assert_eq!(acc[0].as_f64().unwrap(), 2.0);
    }

    #[test]
    fn helpers_5_5_3_capture_rest_from_reads_to_end() {
        // mark 0 → end-of-input (past the cursor at byte 2).
        let g = r#"Top::OR{1,1}
 /(\w+)/
 E { mark_input_start("a"); return(capture_rest_from("a")) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        assert_eq!(acc[0].as_str().unwrap(), "ab cd");
    }

    #[test]
    fn helpers_5_5_3_capture_rest_len_from() {
        let g = r#"Top::OR{1,1}
 /(\w+)/
 E { mark_input_start("a"); return(capture_rest_len_from("a")) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        assert_eq!(acc[0].as_f64().unwrap(), 5.0);
    }

    #[test]
    fn helpers_5_5_3_capture_between_and_len_multibyte() {
        // mark_input_start(a)=0, mark_input_end(b)=byte len; the span is the whole
        // multibyte input. capture_between returns the text; capture_len_between
        // returns the CHAR count (5), not the byte count (6) — char-based parity.
        let g = r#"Top::OR{1,1}
 /\w/
 E { mark_input_start("a"); mark_input_end("b"); return(array(capture_between("a", "b"), capture_len_between("a", "b"))) }
"#;
        let acc = run_5_5_3(g, "héllo");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_str().unwrap(), "héllo");
        assert_eq!(acc[1].as_f64().unwrap(), 5.0);
    }

    #[test]
    fn helpers_5_5_3_capture_between_undef_when_reversed() {
        // a = end-of-input, b = start-of-input → reversed span → undef.
        let g = r#"Top::OR{1,1}
 /(\w+)/
 E { mark_input_end("a"); mark_input_start("b"); return(capture_between("a", "b")) }
"#;
        let acc = run_5_5_3(g, "hi");
        assert!(acc[0].is_null(), "reversed span → undef, got {:?}", acc[0]);
    }

    #[test]
    fn helpers_5_5_3_mark_copy_copies_position() {
        // copy a (=0) into b, then read until cursor from b → "ab".
        let g = r#"Top::OR{1,1}
 /(\w+)/
 E { mark_input_start("a"); mark_copy("b", "a"); return(capture_until_cursor_from("b")) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        assert_eq!(acc[0].as_str().unwrap(), "ab");
    }

    #[test]
    fn helpers_5_5_3_mark_copy_deletes_target_when_source_missing() {
        // b is set, then mark_copy(b, <missing>) deletes b → capture_from(b) undef.
        let g = r#"Top::OR{1,1}
 /(\w+)/
 E { mark_input_start("b"); mark_copy("b", "nope"); return(capture_from("b")) }
"#;
        let acc = run_5_5_3(g, "hi");
        assert!(acc[0].is_null(), "deleted target → undef, got {:?}", acc[0]);
    }

    #[test]
    fn helpers_5_5_3_capture_take_until_cursor_from_advances_mark() {
        // First take reads mark→cursor ("ab") and advances the mark to the cursor;
        // the second read (mark now == cursor) is therefore empty.
        let g = r#"Top::OR{1,1}
 /(\w+)/
 E { mark_input_start("a"); return(array(capture_take_until_cursor_from("a"), capture_until_cursor_from("a"))) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_str().unwrap(), "ab");
        assert_eq!(acc[1].as_str().unwrap(), "");
    }

    #[test]
    fn helpers_5_5_3_capture_take_until_cursor_len_from_advances_mark() {
        let g = r#"Top::OR{1,1}
 /(\w+)/
 E { mark_input_start("a"); return(array(capture_take_until_cursor_len_from("a"), capture_until_cursor_len_from("a"))) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_f64().unwrap(), 2.0);
        assert_eq!(acc[1].as_f64().unwrap(), 0.0);
    }

    #[test]
    fn helpers_5_5_3_capture_take_len_from_advances_mark_to_cursor() {
        // len is mark→match-START ("  " = 2); the mark then advances to the CURSOR
        // (match-end, byte 4), so capture_rest_from is empty afterwards.
        let g = r#"Top::OR{1,1}
 /(\w+)/
 E { mark_input_start("a"); return(array(capture_take_len_from("a"), capture_rest_from("a"))) }
"#;
        let acc = run_5_5_3(g, "  hi");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_f64().unwrap(), 2.0);
        assert_eq!(acc[1].as_str().unwrap(), "");
    }

    #[test]
    fn helpers_5_5_3_capture_take_rest_from_advances_mark_to_end() {
        let g = r#"Top::OR{1,1}
 /(\w+)/
 E { mark_input_start("a"); return(array(capture_take_rest_from("a"), capture_rest_from("a"))) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_str().unwrap(), "ab cd");
        assert_eq!(acc[1].as_str().unwrap(), "");
    }

    #[test]
    fn helpers_5_5_3_capture_take_rest_len_from_advances_mark_to_end() {
        let g = r#"Top::OR{1,1}
 /(\w+)/
 E { mark_input_start("a"); return(array(capture_take_rest_len_from("a"), capture_rest_len_from("a"))) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_f64().unwrap(), 5.0);
        assert_eq!(acc[1].as_f64().unwrap(), 0.0);
    }

    // ── RUST-PARITY.5.5.4: anonymous capture-slice family ──
    // `I { start_capture_slice() }` records the anonymous capture start at the
    // pre-seek cursor (pos 0 for the top rule). `OR{1,1}` keeps the test grammar
    // to one seek match, so over "  ab cd" the `/(\w+)/` match is "ab" at bytes
    // 2..4 (match-start 2, cursor 4), end-of-input 7. That fixes the three
    // endpoints the family reads: match-start (2), cursor (4), end (7). Reuses
    // the run_5_5_3 pipeline harness.

    #[test]
    fn helpers_5_5_4_capture_slice_reads_pre_match_text() {
        // capture_slice ends at match-START → the "  " skipped before the match.
        let g = r#"Top::OR{1,1}
 /(\w+)/
 I { start_capture_slice() }
 E { return(array(capture_slice(), capture_slice_len())) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_str().unwrap(), "  ");
        assert_eq!(acc[1].as_f64().unwrap(), 2.0);
    }

    #[test]
    fn helpers_5_5_4_capture_slice_until_cursor() {
        // ends at the CURSOR (match-end, byte 4) → "  ab".
        let g = r#"Top::OR{1,1}
 /(\w+)/
 I { start_capture_slice() }
 E { return(array(capture_slice_until_cursor(), capture_slice_until_cursor_len())) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_str().unwrap(), "  ab");
        assert_eq!(acc[1].as_f64().unwrap(), 4.0);
    }

    #[test]
    fn helpers_capture_until_boundary_captures_without_consuming_boundary() {
        let g = r#"Top::
 I { set(array(out), []) }
 -> Annotation.push(out)
 LX { return(copy(array(out))) }

Annotation: /@(\w+):[ \t]*/
 I { body = capture_until_boundary(Annotation, Boundary); return(hash("kind", "annotation", "name", entry_group(0), "body", trim(body), "cursor", cursor_pos(), "rest", cursor_rest())) }

Boundary: /END/
"#;
        let acc = run_5_5_3(g, "@a: first @b: second END");
        let entries = acc[0].as_array().unwrap();
        let obj = entries[0].as_object().unwrap();
        let second = entries[1].as_object().unwrap();

        assert_eq!(obj.get("kind").and_then(|v| v.as_str()), Some("annotation"));
        assert_eq!(obj.get("name").and_then(|v| v.as_str()), Some("a"));
        assert_eq!(obj.get("body").and_then(|v| v.as_str()), Some("first"));
        assert_eq!(obj.get("cursor").and_then(|v| v.as_f64()), Some(10.0));
        assert_eq!(
            obj.get("rest").and_then(|v| v.as_str()),
            Some("@b: second END")
        );
        assert_eq!(second.get("name").and_then(|v| v.as_str()), Some("b"));
        assert_eq!(second.get("body").and_then(|v| v.as_str()), Some("second"));
    }

    #[test]
    fn helpers_5_5_4_capture_rest_reads_to_end() {
        // ends at END-of-input (byte 7), past the cursor → the whole input.
        let g = r#"Top::OR{1,1}
 /(\w+)/
 I { start_capture_slice() }
 E { return(array(capture_rest(), capture_rest_len())) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_str().unwrap(), "  ab cd");
        assert_eq!(acc[1].as_f64().unwrap(), 7.0);
    }

    #[test]
    fn helpers_5_5_4_capture_take_advances_to_cursor() {
        // capture_take reads to match-START ("  ") and advances capture_start to
        // the CURSOR (byte 4); the following capture_rest is then 4→end = " cd".
        let g = r#"Top::OR{1,1}
 /(\w+)/
 I { start_capture_slice() }
 E { return(array(capture_take(), capture_rest())) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_str().unwrap(), "  ");
        assert_eq!(acc[1].as_str().unwrap(), " cd");
    }

    #[test]
    fn helpers_5_5_4_capture_take_len_advances_to_cursor() {
        // len is capture_start→match-START (2); capture_start then advances to the
        // CURSOR (byte 4), so capture_rest_len afterward is 3 (" cd").
        let g = r#"Top::OR{1,1}
 /(\w+)/
 I { start_capture_slice() }
 E { return(array(capture_take_len(), capture_rest_len())) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_f64().unwrap(), 2.0);
        assert_eq!(acc[1].as_f64().unwrap(), 3.0);
    }

    #[test]
    fn helpers_5_5_4_capture_take_until_cursor_advances() {
        // reads capture_start→cursor ("  ab") and advances capture_start to the
        // cursor, so the second until-cursor read (start == cursor) is empty.
        let g = r#"Top::OR{1,1}
 /(\w+)/
 I { start_capture_slice() }
 E { return(array(capture_take_until_cursor(), capture_slice_until_cursor())) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_str().unwrap(), "  ab");
        assert_eq!(acc[1].as_str().unwrap(), "");
    }

    #[test]
    fn helpers_5_5_4_capture_take_until_cursor_len_advances() {
        let g = r#"Top::OR{1,1}
 /(\w+)/
 I { start_capture_slice() }
 E { return(array(capture_take_until_cursor_len(), capture_slice_until_cursor_len())) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_f64().unwrap(), 4.0);
        assert_eq!(acc[1].as_f64().unwrap(), 0.0);
    }

    #[test]
    fn helpers_5_5_4_capture_take_rest_advances_to_end() {
        // reads capture_start→end ("  ab cd") and advances capture_start to end, so
        // the second capture_rest read is empty.
        let g = r#"Top::OR{1,1}
 /(\w+)/
 I { start_capture_slice() }
 E { return(array(capture_take_rest(), capture_rest())) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_str().unwrap(), "  ab cd");
        assert_eq!(acc[1].as_str().unwrap(), "");
    }

    #[test]
    fn helpers_5_5_4_capture_take_rest_len_advances_to_end() {
        let g = r#"Top::OR{1,1}
 /(\w+)/
 I { start_capture_slice() }
 E { return(array(capture_take_rest_len(), capture_rest_len())) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_f64().unwrap(), 7.0);
        assert_eq!(acc[1].as_f64().unwrap(), 0.0);
    }

    #[test]
    fn helpers_5_5_4_capture_rest_len_is_char_count() {
        // Multibyte parity: over "ab,héllo" the match is "ab" (bytes 0..2), so
        // capture_rest spans capture_start 0 → end-of-input. The text is the raw
        // slice; capture_rest_len is the CHAR count (8: a b , h é l l o), not the
        // byte count (9) — DSL lengths are char-based (.5.3).
        let g = r#"Top::OR{1,1}
 /(\w+)/
 I { start_capture_slice() }
 E { return(array(capture_rest(), capture_rest_len())) }
"#;
        let acc = run_5_5_3(g, "ab,héllo");
        let acc = acc[0].as_array().unwrap();
        assert_eq!(acc[0].as_str().unwrap(), "ab,héllo");
        assert_eq!(acc[1].as_f64().unwrap(), 8.0);
    }
}
