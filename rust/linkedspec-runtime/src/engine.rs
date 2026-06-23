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
//! ## Blind-call dispatch (AND rules)
//!
//! Blind-call rules (`=> child`) dispatch children sequentially from
//! `bcode_dispatch`. Each child is invoked in order, without regex matching.
//! Blind-call dispatch takes priority over regex + acode dispatch.
//!
//! ## Multi-entrypoint child dispatch
//!
//! When `-> child[N]` is used, `child_regex_idx` selects which regex of the
//! child rule to start with. The default (0) uses the first regex.

use crate::helpers::regex_engine::CompiledAlternation;
use crate::runtime::RuntimeContext;
use linkedspec_core::types::{CompiledSpec, ParseMode, RuntimeValue};
use serde_json::Value;

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
    match_groups: Vec<String>,
    match_named: std::collections::HashMap<String, String>,
    entry_start_byte: usize,
    entry_end_byte: usize,
    match_start_byte: usize,
    match_end_byte: usize,
}

impl SavedMatchState {
    /// Restore the saved caller match state onto the context (invocation exit).
    fn restore(self, ctx: &mut RuntimeContext) {
        ctx.entry_groups = self.entry_groups;
        ctx.entry_named = self.entry_named;
        ctx.match_groups = self.match_groups;
        ctx.match_named = self.match_named;
        ctx.entry_start_byte = self.entry_start_byte;
        ctx.entry_end_byte = self.entry_end_byte;
        ctx.match_start_byte = self.match_start_byte;
        ctx.match_end_byte = self.match_end_byte;
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

impl Engine {
    /// Create a new engine from a compiled spec.
    pub fn new(spec: CompiledSpec) -> Self {
        Self { spec }
    }

    /// Execute the top rule against the given input.
    /// Returns the accumulator as a JSON array.
    pub fn execute(&self, input: &str) -> Result<Value, String> {
        let top = self
            .spec
            .top_rule()
            .ok_or("no top rule in compiled spec")?;
        let label = top.label.clone();
        let mut ctx = RuntimeContext::new(input);
        self.execute_rule(&label, 0, &mut ctx)?;
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
        if !ctx.enter_recursion(label, entry_pos) {
            // Non-progressing recursive re-entry at this exact position: cut the
            // cycle so it terminates instead of recursing forever.
            return Ok(RuntimeValue::Undef);
        }
        // Run the body, then leave the frame on BOTH the Ok and Err paths so the
        // active set stays balanced (empty between top-level parses).
        let result = self.execute_rule_inner(label, entry_regex_idx, ctx);
        ctx.exit_recursion(label, entry_pos);
        result
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
        let rule = self
            .spec
            .find(label)
            .ok_or_else(|| format!("rule '{}' (entry idx {}) not found in compiled spec", label, entry_regex_idx))?;

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
            match_groups: std::mem::take(&mut ctx.match_groups),
            match_named: std::mem::take(&mut ctx.match_named),
            entry_start_byte: ctx.entry_start_byte,
            entry_end_byte: ctx.entry_end_byte,
            match_start_byte: ctx.match_start_byte,
            match_end_byte: ctx.match_end_byte,
        };
        // ENTRY match (`IMATCH`) = the dispatcher's local match (`$$info{match}`).
        // For the top rule the caller has no local match, so this starts empty
        // and is seeded from the rule's own first match below (mirroring the
        // framework passing the top rule's own match as `$info`).
        ctx.entry_groups = saved_match.match_groups.clone();
        ctx.entry_named = saved_match.match_named.clone();
        ctx.entry_start_byte = saved_match.match_start_byte;
        ctx.entry_end_byte = saved_match.match_end_byte;
        // LOCAL match (`LMATCH`) starts empty until this rule matches its regex.
        ctx.match_start_byte = 0;
        ctx.match_end_byte = 0;

        // Build regex alternation (or fallback for edge-only rules)
        let alt = if rule.regex_patterns.is_empty() {
            CompiledAlternation::compile(&[])?
        } else {
            CompiledAlternation::compile(&rule.regex_patterns)?
        };

        // ── I-block (preamble, once per rule entry) ──
        if let Some(ref preamble) = rule.preamble {
            self.execute_block(preamble, ctx, label)?;
        }

        // ── Blind-call dispatch (AND rules) ──
        if !rule.bcode_dispatch.is_empty() {
            for entry in &rule.bcode_dispatch {
                // Execute child rule; its return value becomes the parent's
                // `retv` (Runtime Semantics §6.2), readable by the attached
                // code, fluent chain, and the E-block below.
                let child_retv = self.execute_rule(&entry.child_label, 0, ctx)?;
                ctx.set_retv(child_retv);
                // Execute attached code if present
                if let Some(ref block) = entry.code {
                    self.execute_block(block, ctx, label)?;
                }
                // Fluent chain calls on the blind edge
                for (method, _args_str) in &entry.fluent_chain {
                    let args_val: Vec<RuntimeValue> = if _args_str.is_empty() {
                        vec![]
                    } else {
                        vec![RuntimeValue::Scalar(_args_str.clone())]
                    };
                    let empty_kw = std::collections::HashMap::new();
                    let empty_raw: &[linkedspec_core::expr::Arg] = &[];
                    self.call_helper(method, empty_raw, &args_val, &empty_kw, ctx, label)?;
                }
            }
            // After blind-call dispatch, fire E-block and exit
            if let Some(ref ecode) = rule.ecode {
                self.execute_block(ecode, ctx, label)?;
            }
            let my_return = ctx.take_return_value().unwrap_or(RuntimeValue::Undef);
            ctx.restore_return_value(caller_return);
            saved_match.restore(ctx);
            return Ok(my_return);
        }

        // ── Regex-based matching loop ──
        let is_rep = rule.rep_min.is_some();
        let rep_min = rule.rep_min.unwrap_or(0);
        let rep_max = rule.rep_max;
        let mut matches: usize = 0;
        let max_iter = 10_000;

        // For non-REP entry-specific dispatch: if entry_regex_idx > 0,
        // try only that specific regex first (for self-recursive rules).
        let has_entry_idx = entry_regex_idx > 0 && entry_regex_idx < rule.regex_patterns.len();

        for _iter in 0..max_iter {
            // Non-REP rules execute once
            if !is_rep && matches > 0 {
                break;
            }

            // Cursor position at the start of this iteration — the zero-progress
            // guard below compares it against the position after the iteration
            // (Perl: `loop_start_pos`).
            let pos_before = ctx.pos;

            // ── LS-block (loop start, fires before each match attempt) ──
            if let Some(ref lscode) = rule.lscode {
                self.execute_block(lscode, ctx, label)?;
            }

            // ── Match ──
            let match_result = if has_entry_idx && matches == 0 {
                // Self-recursive entry: only try the specified regex slot.
                // Build a single-pattern alternation for this slot.
                let entry_pat = &rule.regex_patterns[entry_regex_idx];
                let entry_alt =
                    CompiledAlternation::compile(&[entry_pat.clone()])?;
                match rule.parse_mode {
                    ParseMode::Consume => {
                        entry_alt.consume_match(&ctx.input, ctx.pos)
                    }
                    ParseMode::Seek => {
                        entry_alt.seek_match(&ctx.input, ctx.pos)
                    }
                }
                .map(|mut m| {
                    // Fix up the index to match the real regex position
                    m.index = entry_regex_idx;
                    m
                })
            } else {
                match rule.parse_mode {
                    ParseMode::Consume => {
                        alt.consume_match(&ctx.input, ctx.pos)
                    }
                    ParseMode::Seek => {
                        alt.seek_match(&ctx.input, ctx.pos)
                    }
                }
            };

            if let Some(m) = match_result {
                let entry_was_empty = ctx.entry_groups.is_empty();
                ctx.set_pos(m.end);
                // LOCAL match (`LMATCH`) — the rule's own regex match. This is
                // what `match_*` helpers read; it must NOT touch the entry match
                // (Perl keeps `IMATCH` and `LMATCH` separate — only an explicit
                // I-block bridge copies one to the other). `m.start`/`m.end` are
                // byte offsets (exposed as char offsets by `match_*_pos`).
                ctx.match_groups = m.groups.clone();
                ctx.match_named = m.named.clone();
                ctx.match_start_byte = m.start;
                ctx.match_end_byte = m.end;
                // Top-rule / dispatcher-less entry: the rule's own first match
                // is also its entry match (the framework passes the top rule's
                // own match as `$info`). A dispatched child already carries a
                // non-empty entry match (the dispatcher's local match) and is
                // left untouched, so `entry_*` and `match_*` diverge correctly
                // in nested contexts.
                if entry_was_empty {
                    ctx.entry_groups = m.groups.clone();
                    ctx.entry_named = m.named.clone();
                    ctx.entry_start_byte = m.start;
                    ctx.entry_end_byte = m.end;
                }

                // ── Action-edge dispatch ──
                for entry in &rule.acode_dispatch {
                    if entry.regex_idx == m.index {
                        // Use child_regex_idx for multi-entrypoint support.
                        // The child's return value becomes the parent's `retv`
                        // (Runtime Semantics §3.3 / §6.1), readable by the
                        // attached code below and the LE-block after the loop.
                        let child_retv = self.execute_rule(
                            &entry.child_label,
                            entry.child_regex_idx,
                            ctx,
                        )?;
                        ctx.set_retv(child_retv);
                        // Execute attached code if present
                        if let Some(ref block) = entry.code {
                            self.execute_block(block, ctx, label)?;
                        }
                    }
                }

                // ── LE-block (loop end, after successful match) ──
                if let Some(ref lecode) = rule.lecode {
                    self.execute_block(lecode, ctx, label)?;
                }

                matches += 1;

                // ── IT-block (per-iteration, REP only) ──
                if let Some(ref itcode) = rule.itcode {
                    self.execute_block(itcode, ctx, label)?;
                }
            } else {
                // No match — exit the matching loop
                // ── LX-block (no-match exit, fires when loop ends without match) ──
                if let Some(ref lxcode) = rule.lxcode {
                    self.execute_block(lxcode, ctx, label)?;
                }
                break;
            }

            // Check max bound (REP rules)
            if let Some(max) = rep_max {
                if matches >= max {
                    break;
                }
            }

            // Zero-progress guard: a REP iteration that left the cursor
            // unchanged (e.g. a zero-width match with no consuming child
            // dispatch) would loop forever. Break when the iteration made no
            // progress (Perl: `loop_end_pos == loop_start_pos`); the min-bound
            // check below then fails the rule if we are still under `rep_min`.
            if is_rep && ctx.pos == pos_before {
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

        // ── EX-block (REP exhaustion, fires after loop completes normally) ──
        if let Some(ref excode) = rule.excode {
            self.execute_block(excode, ctx, label)?;
        }

        // ── E-block (exit, fires once after all matching/repetition is done) ──
        if let Some(ref ecode) = rule.ecode {
            self.execute_block(ecode, ctx, label)?;
        }

        // This invocation's return value is whatever its blocks last returned;
        // restore the caller's pending return and match lexicals so nested
        // dispatch is transparent to the parent.
        let my_return = ctx.take_return_value().unwrap_or(RuntimeValue::Undef);
        ctx.restore_return_value(caller_return);
        saved_match.restore(ctx);
        Ok(my_return)
    }

    /// Execute a lifecycle code block (parsed expression tree).
    fn execute_block(
        &self,
        block: &linkedspec_core::expr::CodeBlock,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<(), String> {
        for stmt in &block.statements {
            self.eval_expr(&stmt.expr, ctx, rule_label)?;
        }
        Ok(())
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
                // Lazy-evaluation calls: if/switch/elseif/else/case/default
                // Branch bodies must NOT be evaluated eagerly — they are
                // evaluated only when their condition matches.
                let is_lazy = matches!(
                    name.as_str(),
                    "if" | "switch" | "elseif" | "else" | "case" | "default"
                );
                if is_lazy {
                    return self.call_helper_lazy(name, args, ctx, rule_label);
                }
                // Normal eager evaluation for all other helpers
                let evaluated: Vec<RuntimeValue> = args
                    .iter()
                    .map(|a| self.eval_expr(a.value(), ctx, rule_label))
                    .collect::<Result<Vec<_>, _>>()?;
                self.call_helper_with_args(name, args, &evaluated, ctx, rule_label)
            }
            Expr::Variable { name } => Ok(ctx.get_scalar(name)),
            Expr::IndexedVar { name, index } => {
                let idx_val = self.eval_expr(index, ctx, rule_label)?;
                let idx: usize = idx_val.as_number().unwrap_or(0.0) as usize;
                let arr = ctx.get_array(name);
                Ok(arr.get(idx).cloned().unwrap_or(RuntimeValue::Undef))
            }
            Expr::StringLiteral { value } => {
                Ok(RuntimeValue::Scalar(value.clone()))
            }
            Expr::NumberLiteral { value } => Ok(RuntimeValue::Number(*value)),
            Expr::BooleanLiteral { value } => Ok(RuntimeValue::Bool(*value)),
            Expr::RegexLiteral { pattern } => {
                Ok(RuntimeValue::Scalar(pattern.clone()))
            }
            Expr::Undef => Ok(RuntimeValue::Undef),
            Expr::FluentChain { receiver, calls } => {
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

    /// Resolve a scalar target name from an evaluated value.
    ///
    /// `scalar(varname)` with a bare variable returns the variable's runtime
    /// value, but `assign(scalar(varname), ...)` needs the variable NAME.
    fn resolve_scalar_target(
        &self,
        raw_args: &[linkedspec_core::expr::Arg],
        val: &RuntimeValue,
    ) -> String {
        use linkedspec_core::expr::{Arg, Expr};
        if let Some(Arg::Positional(Expr::Call { name, args })) =
            raw_args.first()
        {
            if (name == "scalar" || name == "s") && args.len() == 1 {
                if let Arg::Positional(Expr::Variable { name: var_name }) =
                    &args[0]
                {
                    return var_name.clone();
                }
            }
        }
        val.to_str()
    }

    /// Resolve an array target name from the first arg of a helper call.
    ///
    /// In Perl LinkedSpec, `array(results)` is a CONTAINER SPECIFICATION meaning
    /// "the array named results", not a constructor. When raw_arg is a `Call`
    /// with name `"array"` or `"a"` and one argument, extract the inner
    /// variable name. Falls back to the evaluated value's `to_str()`.
    fn resolve_array_target(
        &self,
        raw_args: &[linkedspec_core::expr::Arg],
        val: &RuntimeValue,
    ) -> String {
        use linkedspec_core::expr::{Arg, Expr};
        // Check if the raw arg is `array(variable)` or `a(variable)`
        if let Some(Arg::Positional(Expr::Call { name, args })) = raw_args.first() {
            if (name == "array" || name == "a") && args.len() == 1 {
                if let Arg::Positional(Expr::Variable { name: var_name }) = &args[0] {
                    return var_name.clone();
                }
            }
        }
        val.to_str()
    }

    /// Resolve a child rule name from the first arg of a `call(...)` helper.
    ///
    /// A bare `call(RuleName)` names the target rule directly — its evaluated
    /// value would be undef (a rule label is not a scalar variable), so the name
    /// must come from the raw AST. Falls back to the evaluated value's
    /// `to_str()` for the quoted form `call(scalar("RuleName"))`.
    fn resolve_rule_name(
        &self,
        raw_args: &[linkedspec_core::expr::Arg],
        val: Option<&RuntimeValue>,
    ) -> String {
        use linkedspec_core::expr::{Arg, Expr};
        if let Some(Arg::Positional(Expr::Variable { name })) = raw_args.first() {
            return name.clone();
        }
        val.map(|v| v.to_str()).unwrap_or_default()
    }

    /// Dispatch a lazy-evaluation call (if/switch/elseif/else/case/default).
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
        let empty_kw = std::collections::HashMap::new();
        let empty_vals: Vec<RuntimeValue> = Vec::new();
        self.call_helper(name, args, &empty_vals, &empty_kw, ctx, rule_label)
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
        use linkedspec_core::expr::Arg;
        // Build a map from keyword name → evaluated value
        let mut kw: std::collections::HashMap<String, RuntimeValue> =
            std::collections::HashMap::new();
        for (arg, val) in raw_args.iter().zip(evaluated.iter()) {
            if let Arg::Keyword { name, .. } = arg {
                kw.insert(name.clone(), val.clone());
            }
        }
        self.call_helper(name, raw_args, evaluated, &kw, ctx, rule_label)
    }

    /// Dispatch a helper call by name with original args, evaluated args, and keyword map.
    fn call_helper(
        &self,
        name: &str,
        raw_args: &[linkedspec_core::expr::Arg],
        args: &[RuntimeValue],
        kw: &std::collections::HashMap<String, RuntimeValue>,
        ctx: &mut RuntimeContext,
        rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        match name {
            // ── Declarations ──
            "declare" => {
                if args.len() >= 2 {
                    let type_name = args[0].to_str();
                    // Variable name: positional arg[1] or keyword "name".
                    // Bare variable references like `declare(scalar, name)` should
                    // use the variable NAME, not its runtime value.
                    let var_name = if kw.contains_key("name") {
                        "name".to_string()
                    } else if let Some(linkedspec_core::expr::Arg::Positional(
                        linkedspec_core::expr::Expr::Variable { name },
                    )) = raw_args.get(1)
                    {
                        name.clone()
                    } else {
                        args[1].to_str()
                    };
                    match type_name.as_str() {
                        "scalar" => {
                            if kw.contains_key("name") {
                                // declare(scalar, name=<value>):
                                //   keyword value IS the initializer
                                let init = kw.get("name").unwrap();
                                ctx.declare_scalar_with(
                                    &var_name,
                                    init.clone(),
                                );
                            } else if args.len() >= 3 {
                                ctx.declare_scalar_with(
                                    &var_name,
                                    args[2].clone(),
                                );
                            } else {
                                ctx.declare_scalar(&var_name);
                            }
                        }
                        "array" => ctx.declare_array(&var_name),
                        "hash" => ctx.declare_hash(&var_name),
                        _ => {}
                    }
                }
                Ok(RuntimeValue::Undef)
            }
            "assign" => {
                if args.len() >= 2 {
                    let target = self.resolve_scalar_target(raw_args, &args[0]);
                    ctx.set_scalar(&target, args[1].clone());
                }
                Ok(RuntimeValue::Undef)
            }
            // ── Array constructors ──
            "array" | "a" => {
                // Container reference: `array(varname)` with single bare variable
                // returns the named array, not a constructed array.
                if args.len() == 1 && raw_args.len() == 1 {
                    if let linkedspec_core::expr::Arg::Positional(
                        linkedspec_core::expr::Expr::Variable { name: var_name },
                    ) = &raw_args[0]
                    {
                        return Ok(RuntimeValue::Array(
                            ctx.get_array(var_name),
                        ));
                    }
                }
                // General constructor: `array(val1, val2, ...)`
                Ok(RuntimeValue::Array(args.to_vec()))
            }
            "array_copy" => {
                if let Some(arg) = args.first() {
                    match arg {
                        RuntimeValue::Array(a) => {
                            Ok(RuntimeValue::Array(a.clone()))
                        }
                        _ => {
                            let arr_name = self.resolve_array_target(raw_args, arg);
                            if !arr_name.is_empty() {
                                Ok(RuntimeValue::Array(
                                    ctx.array_copy(&arr_name),
                                ))
                            } else {
                                Ok(RuntimeValue::Array(Vec::new()))
                            }
                        }
                    }
                } else {
                    Ok(RuntimeValue::Array(Vec::new()))
                }
            }
            // ── Accumulator ──
            "push_value" | "push" => {
                if args.len() >= 2 {
                    let arr_name = self.resolve_array_target(raw_args, &args[0]);
                    ctx.push_value(&arr_name, args[1].clone());
                }
                Ok(RuntimeValue::Undef)
            }
            "push_nonempty" => {
                if args.len() >= 2 && args[1].is_nonempty() {
                    let arr_name = self.resolve_array_target(raw_args, &args[0]);
                    ctx.push_value(&arr_name, args[1].clone());
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
            "return_undef" => Ok(RuntimeValue::Undef),
            // ── Scalar access ──
            "scalar" | "s" => {
                if raw_args.len() == 1 {
                    // `scalar(varname)` with bare variable → return its value
                    Ok(args.first().cloned().unwrap_or(RuntimeValue::Undef))
                } else if args.len() >= 2 {
                    // `scalar(container, key_or_index)` → index into container
                    match &args[0] {
                        RuntimeValue::Array(arr) => {
                            let idx =
                                args[1].as_number().unwrap_or(0.0) as usize;
                            Ok(arr
                                .get(idx)
                                .cloned()
                                .unwrap_or(RuntimeValue::Undef))
                        }
                        _ => {
                            let key = args[1].to_str();
                            Ok(ctx.get_scalar(&key))
                        }
                    }
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "call" => {
                // `call(child)` evaluates to the child's return value, so
                // `assign(s(retv), call(child))` captures it — the Perl
                // reference pattern (see specs/tablegrep.spec). The child rule
                // name comes from the raw arg (a bare label is not a scalar).
                let child = self.resolve_rule_name(raw_args, args.first());
                if !child.is_empty() {
                    let child_retv = self.execute_rule(&child, 0, ctx)?;
                    return Ok(child_retv);
                }
                Ok(RuntimeValue::Undef)
            }
            // ── Scalar/string ──
            "concat" => {
                let result: String =
                    args.iter().map(|a| a.to_str()).collect();
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
                if let Some(RuntimeValue::Array(arr)) = args.first() {
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
                if let Some(RuntimeValue::Array(arr)) = args.first() {
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
                ctx.entry_groups.first().cloned().unwrap_or_default(),
            )),
            "entry_group" => {
                if let Some(arg) = args.first() {
                    let idx = arg.as_number().unwrap_or(0.0) as usize;
                    Ok(RuntimeValue::Scalar(
                        ctx.entry_groups
                            .get(idx)
                            .cloned()
                            .unwrap_or_default(),
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
            "entry_named" => Ok(match args.first().map(|a| a.to_str()) {
                Some(name) => ctx
                    .entry_named
                    .get(&name)
                    .map(|v| RuntimeValue::Scalar(v.clone()))
                    .unwrap_or(RuntimeValue::Undef),
                None => RuntimeValue::Undef,
            }),
            "entry_has" => Ok(RuntimeValue::Bool(
                args.first()
                    .map(|a| ctx.entry_named.contains_key(&a.to_str()))
                    .unwrap_or(false),
            )),
            "entry_map" | "entry_named_map" => Ok(named_map_to_hash(&ctx.entry_named)),
            "match_text" => Ok(RuntimeValue::Scalar(
                ctx.match_groups.first().cloned().unwrap_or_default(),
            )),
            "exit_now" => {
                let status = args
                    .first()
                    .and_then(|a| a.as_number())
                    .unwrap_or(1.0) as i32;
                ctx.exit_status = Some(status);
                Err(format!("exit_now({status})"))
            }
            // `print` is handled by the consolidated `say | print | print_each`
            // arm below; `hash`/`h` and `hash_copy` by the `Hash helpers` arms
            // below. (RUST-PARITY.5.4: removed the earlier shadowing duplicates
            // so the more complete behavior — Hash-arg merge for `hash`, raw-AST
            // target resolution for `hash_copy` — wins.)
            // ── String/array index ──
            "substr" => {
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
                    Ok(RuntimeValue::Scalar(args.first().map(|a| a.to_str()).unwrap_or_default()))
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
                if args.len() >= 2 {
                    let s = args[0].to_str();
                    let delim = args[1].to_str();
                    Ok(RuntimeValue::Array(
                        s.split(&delim).map(|p| RuntimeValue::Scalar(p.to_string())).collect(),
                    ))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "split_each" => {
                if let Some(arr) = args.first() {
                    match arr {
                        RuntimeValue::Array(items) => {
                            let result: Vec<RuntimeValue> = items.iter().map(|v| {
                                RuntimeValue::Array(
                                    v.to_str().split_whitespace().map(|p| RuntimeValue::Scalar(p.to_string())).collect()
                                )
                            }).collect();
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
                    let transformed: Vec<RuntimeValue> = items.iter().map(|v| {
                        let s = v.to_str();
                        let s = match name {
                            "trim_each" => s.trim().to_string(),
                            "lowercase_each" => s.to_lowercase(),
                            "uppercase_each" => s.to_uppercase(),
                            _ => s,
                        };
                        RuntimeValue::Scalar(s)
                    }).collect();
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
                            items.iter().filter(|v| re.is_match(&v.to_str())).cloned().collect(),
                        )),
                        Err(e) => {
                            eprintln!("warning: filter_match: invalid regex '/{}/': {} — returning empty", pattern, e);
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
                    let uniq: Vec<RuntimeValue> = items.iter().filter(|v| {
                        seen.insert(v.to_str())
                    }).cloned().collect();
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
                let line = ctx.input[..ctx.pos].chars().filter(|&c| c == '\n').count() + 1;
                Ok(RuntimeValue::Number(line as f64))
            }
            "cursor_col" => {
                // Char distance from the last newline (Perl columns are char-based).
                let last_nl = ctx.input[..ctx.pos].rfind('\n').map(|i| i + 1).unwrap_or(0);
                let col = ctx.input[last_nl..ctx.pos].chars().count() + 1;
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
            "capture_slice_pos" => Ok(RuntimeValue::Number(
                byte_to_char_offset(&ctx.input, ctx.capture_start.unwrap_or(0)) as f64,
            )),
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
                Ok(RuntimeValue::Number(byte_to_char_offset(&ctx.input, byte) as f64))
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
                let pos = args.first().and_then(|a| a.as_number()).unwrap_or(0.0) as usize;
                let line = ctx.input[..pos].chars().filter(|&c| c == '\n').count() + 1;
                Ok(RuntimeValue::Number(line as f64))
            }
            "entry_col" => {
                let pos = args.first().and_then(|a| a.as_number()).unwrap_or(0.0) as usize;
                let last_nl = ctx.input[..pos].rfind('\n').map(|i| i + 1).unwrap_or(0);
                Ok(RuntimeValue::Number((pos - last_nl + 1) as f64))
            }
            "entry_len" => Ok(RuntimeValue::Number(
                ctx.entry_groups.first().map(|s| s.chars().count()).unwrap_or(0) as f64,
            )),
            "entry_start_pos" => Ok(RuntimeValue::Number(
                byte_to_char_offset(&ctx.input, ctx.entry_start_byte) as f64,
            )),
            "entry_end_pos" => Ok(RuntimeValue::Number(
                byte_to_char_offset(&ctx.input, ctx.entry_end_byte) as f64,
            )),
            "match_line" => {
                let pos = args.first().and_then(|a| a.as_number()).unwrap_or(0.0) as usize;
                let line = ctx.input[..pos].chars().filter(|&c| c == '\n').count() + 1;
                Ok(RuntimeValue::Number(line as f64))
            }
            "match_col" => {
                let pos = args.first().and_then(|a| a.as_number()).unwrap_or(0.0) as usize;
                let last_nl = ctx.input[..pos].rfind('\n').map(|i| i + 1).unwrap_or(0);
                Ok(RuntimeValue::Number((pos - last_nl + 1) as f64))
            }
            "match_len" => Ok(RuntimeValue::Number(
                ctx.match_groups.first().map(|s| s.chars().count()).unwrap_or(0) as f64,
            )),
            "match_start_pos" => Ok(RuntimeValue::Number(
                byte_to_char_offset(&ctx.input, ctx.match_start_byte) as f64,
            )),
            "match_end_pos" => Ok(RuntimeValue::Number(
                byte_to_char_offset(&ctx.input, ctx.match_end_byte) as f64,
            )),
            "match_group" => {
                if let Some(arg) = args.first() {
                    let idx = arg.as_number().unwrap_or(0.0) as usize;
                    Ok(RuntimeValue::Scalar(ctx.match_groups.get(idx).cloned().unwrap_or_default()))
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "match_groups" => {
                Ok(RuntimeValue::Array(
                    ctx.match_groups.iter().map(|g| RuntimeValue::Scalar(g.clone())).collect(),
                ))
            }
            // Named-capture readers for the LOCAL match — the immediate regex
            // match inside this code block, which can diverge from the entry match
            // in nested/dispatched contexts (Helper Contract Catalog §8). They read
            // the populated `ctx.match_named` map. `match_named_map` is a retired
            // alias of `match_map`.
            "match_named" => Ok(match args.first().map(|a| a.to_str()) {
                Some(name) => ctx
                    .match_named
                    .get(&name)
                    .map(|v| RuntimeValue::Scalar(v.clone()))
                    .unwrap_or(RuntimeValue::Undef),
                None => RuntimeValue::Undef,
            }),
            "match_has" => Ok(RuntimeValue::Bool(
                args.first()
                    .map(|a| ctx.match_named.contains_key(&a.to_str()))
                    .unwrap_or(false),
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
            "trim" => Ok(RuntimeValue::Scalar(args.first().map(|a| a.to_str().trim().to_string()).unwrap_or_default())),
            "lowercase" => Ok(RuntimeValue::Scalar(args.first().map(|a| a.to_str().to_lowercase()).unwrap_or_default())),
            "uppercase" => Ok(RuntimeValue::Scalar(args.first().map(|a| a.to_str().to_uppercase()).unwrap_or_default())),
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
                    Ok(RuntimeValue::Scalar(s.strip_prefix(&prefix).unwrap_or(&s).to_string()))
                } else {
                    Ok(args.first().cloned().unwrap_or(RuntimeValue::Undef))
                }
            }
            "rm_suffix" => {
                if args.len() >= 2 {
                    let s = args[0].to_str();
                    let suffix = args[1].to_str();
                    Ok(RuntimeValue::Scalar(s.strip_suffix(&suffix).unwrap_or(&s).to_string()))
                } else {
                    Ok(args.first().cloned().unwrap_or(RuntimeValue::Undef))
                }
            }
            "starts_with" => {
                if args.len() >= 2 {
                    let s = args[0].to_str();
                    let prefix = args[1].to_str();
                    Ok(RuntimeValue::Bool(s.starts_with(&prefix)))
                } else {
                    Ok(RuntimeValue::Bool(false))
                }
            }
            "ends_with" => {
                if args.len() >= 2 {
                    let s = args[0].to_str();
                    let suffix = args[1].to_str();
                    Ok(RuntimeValue::Bool(s.ends_with(&suffix)))
                } else {
                    Ok(RuntimeValue::Bool(false))
                }
            }
            "contains_substr" => {
                if args.len() >= 2 {
                    let s = args[0].to_str();
                    let sub = args[1].to_str();
                    Ok(RuntimeValue::Bool(s.contains(&sub)))
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
                            eprintln!("warning: matches: invalid regex '/{}/': {} — returning false", pat, e);
                            Ok(RuntimeValue::Bool(false))
                        }
                    }
                } else {
                    Ok(RuntimeValue::Bool(false))
                }
            }
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
            "num_add" | "num_sub" | "num_mul" | "num_div" | "num_mod" => {
                if args.len() >= 2 {
                    let a = args[0].as_number();
                    let b = args[1].as_number();
                    match (a, b) {
                        (Some(a), Some(b)) => {
                            let result = match name {
                                "num_add" => a + b,
                                "num_sub" => a - b,
                                "num_mul" => a * b,
                                "num_div" if b != 0.0 => a / b,
                                "num_mod" if b != 0.0 && a.fract() == 0.0 && b.fract() == 0.0 => (a as i64 % b as i64) as f64,
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
            "num_abs" => Ok(RuntimeValue::Number(
                args.first().and_then(|a| a.as_number()).map(|n| n.abs()).unwrap_or(0.0),
            )),
            "num_floor" => Ok(RuntimeValue::Number(
                args.first().and_then(|a| a.as_number()).map(|n| n.floor()).unwrap_or(0.0),
            )),
            "num_ceil" => Ok(RuntimeValue::Number(
                args.first().and_then(|a| a.as_number()).map(|n| n.ceil()).unwrap_or(0.0),
            )),
            "num_round" => Ok(RuntimeValue::Number(
                args.first().and_then(|a| a.as_number()).map(|n| n.round()).unwrap_or(0.0),
            )),
            "num_min" => {
                let min = args.iter().filter_map(|a| a.as_number()).fold(f64::INFINITY, |a, b| a.min(b));
                if min.is_finite() { Ok(RuntimeValue::Number(min)) } else { Ok(RuntimeValue::Undef) }
            }
            "num_max" => {
                let max = args.iter().filter_map(|a| a.as_number()).fold(f64::NEG_INFINITY, |a, b| a.max(b));
                if max.is_finite() { Ok(RuntimeValue::Number(max)) } else { Ok(RuntimeValue::Undef) }
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
                if let Some(RuntimeValue::Array(items)) = args.first() {
                    let nums: Vec<f64> = items.iter().filter_map(|v| v.as_number()).collect();
                    if nums.is_empty() { return Ok(RuntimeValue::Undef); }
                    match name {
                        "num_sum" => Ok(RuntimeValue::Number(nums.iter().sum())),
                        "num_avg" => Ok(RuntimeValue::Number(nums.iter().sum::<f64>() / nums.len() as f64)),
                        "num_median" => {
                            let mut sorted = nums.clone();
                            sorted.sort_by(|a, b| a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal));
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
                if let Some(RuntimeValue::Array(mut items)) = args.first().cloned() {
                    items.sort_by(|a, b| a.to_str().cmp(&b.to_str()));
                    Ok(RuntimeValue::Array(items))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "reversed" => {
                if let Some(RuntimeValue::Array(mut items)) = args.first().cloned() {
                    items.reverse();
                    Ok(RuntimeValue::Array(items))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "take" => {
                if let Some(RuntimeValue::Array(items)) = args.first() {
                    let n = args.get(1).and_then(|a| a.as_number()).unwrap_or(1.0) as usize;
                    Ok(RuntimeValue::Array(items.iter().take(n).cloned().collect()))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "take_last" => {
                if let Some(RuntimeValue::Array(items)) = args.first() {
                    let n = args.get(1).and_then(|a| a.as_number()).unwrap_or(1.0) as usize;
                    let start = if n > items.len() { 0 } else { items.len() - n };
                    Ok(RuntimeValue::Array(items[start..].to_vec()))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "drop_front" => {
                if let Some(RuntimeValue::Array(items)) = args.first() {
                    let n = args.get(1).and_then(|a| a.as_number()).unwrap_or(1.0) as usize;
                    Ok(RuntimeValue::Array(items.iter().skip(n).cloned().collect()))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "drop_back" => {
                if let Some(RuntimeValue::Array(items)) = args.first() {
                    let n = args.get(1).and_then(|a| a.as_number()).unwrap_or(1.0) as usize;
                    let end = if n > items.len() { 0 } else { items.len() - n };
                    Ok(RuntimeValue::Array(items[..end].to_vec()))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "slice" => {
                if let Some(RuntimeValue::Array(items)) = args.first() {
                    let start = args.get(1).and_then(|a| a.as_number()).unwrap_or(0.0) as usize;
                    let n = args.get(2).and_then(|a| a.as_number()).unwrap_or(items.len() as f64) as usize;
                    let end = (start + n).min(items.len());
                    Ok(RuntimeValue::Array(items[start..end].to_vec()))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "contains" => {
                if let Some(RuntimeValue::Array(items)) = args.first() {
                    let needle = args.get(1).map(|a| a.to_str()).unwrap_or_default();
                    Ok(RuntimeValue::Bool(items.iter().any(|v| v.to_str() == needle)))
                } else {
                    Ok(RuntimeValue::Bool(false))
                }
            }
            "index_of" => {
                if let Some(RuntimeValue::Array(items)) = args.first() {
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
            "is_defined" => Ok(RuntimeValue::Bool(args.first().is_some_and(|a| a.is_defined()))),
            "is_undefined" => Ok(RuntimeValue::Bool(args.first().is_none_or(|a| !a.is_defined()))),
            "flat_array" => Ok(RuntimeValue::Array(
                args.iter().flat_map(|a| match a {
                    RuntimeValue::Array(items) => items.clone(),
                    other => vec![other.clone()],
                }).collect(),
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
                args.iter().flat_map(|a| match a {
                    RuntimeValue::Array(items) => items.clone(),
                    other => vec![other.clone()],
                }).collect(),
            )),
            // ── Hash helpers ──
            "hash" | "h" => {
                let mut entries = Vec::new();
                let mut i = 0;
                while i + 1 < args.len() {
                    let key = args[i].to_str();
                    let val = args[i + 1].clone();
                    entries.push((key, val));
                    i += 2;
                }
                // Also merge in any Hash args
                for arg in args {
                    if let RuntimeValue::Hash(h_entries) = arg {
                        for (k, v) in h_entries {
                            entries.push((k.clone(), v.clone()));
                        }
                    }
                }
                Ok(RuntimeValue::Hash(entries))
            }
            "hash_copy" => {
                if let Some(arg) = args.first() {
                    match arg {
                        RuntimeValue::Hash(h) => Ok(RuntimeValue::Hash(h.clone())),
                        _ => {
                            let hash_name = self.resolve_array_target(raw_args, arg);
                            if !hash_name.is_empty() {
                                Ok(RuntimeValue::Hash(ctx.hash_copy(&hash_name)))
                            } else {
                                Ok(RuntimeValue::Hash(Vec::new()))
                            }
                        }
                    }
                } else {
                    Ok(RuntimeValue::Hash(Vec::new()))
                }
            }
            "merge_hash" => {
                let mut merged = Vec::new();
                let mut seen = std::collections::HashSet::new();
                for arg in args {
                    if let RuntimeValue::Hash(entries) = arg {
                        for (k, v) in entries {
                            if !seen.contains(k) {
                                seen.insert(k.clone());
                                merged.push((k.clone(), v.clone()));
                            }
                        }
                    }
                }
                Ok(RuntimeValue::Hash(merged))
            }
            "set_key" => {
                if args.len() >= 3 {
                    if let RuntimeValue::Hash(mut entries) = args[0].clone() {
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
                    if let RuntimeValue::Hash(entries) = args[0].clone() {
                        let old_key = args[1].to_str();
                        let new_key = args[2].to_str();
                        let renamed: Vec<_> = entries.into_iter().map(|(k, v)| {
                            if k == old_key { (new_key.clone(), v) } else { (k, v) }
                        }).collect();
                        Ok(RuntimeValue::Hash(renamed))
                    } else {
                        Ok(args[0].clone())
                    }
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "drop_keys" => {
                if let Some(RuntimeValue::Hash(entries)) = args.first().cloned() {
                    let keys_to_drop: std::collections::HashSet<String> = args[1..].iter().map(|a| a.to_str()).collect();
                    Ok(RuntimeValue::Hash(
                        entries.into_iter().filter(|(k, _)| !keys_to_drop.contains(k)).collect(),
                    ))
                } else {
                    Ok(args.first().cloned().unwrap_or(RuntimeValue::Undef))
                }
            }
            "pick_keys" => {
                if let Some(RuntimeValue::Hash(entries)) = args.first().cloned() {
                    let keys_to_keep: std::collections::HashSet<String> = args[1..].iter().map(|a| a.to_str()).collect();
                    Ok(RuntimeValue::Hash(
                        entries.into_iter().filter(|(k, _)| keys_to_keep.contains(k)).collect(),
                    ))
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "sorted_keys" => {
                if let Some(RuntimeValue::Hash(entries)) = args.first() {
                    let mut keys: Vec<RuntimeValue> = entries.iter().map(|(k, _)| RuntimeValue::Scalar(k.clone())).collect();
                    keys.sort_by(|a, b| a.to_str().cmp(&b.to_str()));
                    Ok(RuntimeValue::Array(keys))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "sorted_values" => {
                if let Some(RuntimeValue::Hash(entries)) = args.first() {
                    let mut items: Vec<(String, RuntimeValue)> = entries.clone();
                    items.sort_by(|(ak, _), (bk, _)| ak.cmp(bk));
                    Ok(RuntimeValue::Array(items.into_iter().map(|(_, v)| v).collect()))
                } else {
                    Ok(RuntimeValue::Array(vec![]))
                }
            }
            "count_keys" => {
                if let Some(RuntimeValue::Hash(entries)) = args.first() {
                    Ok(RuntimeValue::Number(entries.len() as f64))
                } else {
                    Ok(RuntimeValue::Number(0.0))
                }
            }
            "has_key" => {
                if let Some(RuntimeValue::Hash(entries)) = args.first() {
                    let key = args.get(1).map(|a| a.to_str()).unwrap_or_default();
                    Ok(RuntimeValue::Bool(entries.iter().any(|(k, _)| k == &key)))
                } else {
                    Ok(RuntimeValue::Bool(false))
                }
            }
            "scalaref" => {
                if args.len() >= 2 {
                    let path = args[1].to_str();
                    // Walk: container{path} → scalar
                    match &args[0] {
                        RuntimeValue::Hash(entries) => {
                            Ok(entries.iter().find(|(k, _)| k == &path).map(|(_, v)| v.clone()).unwrap_or(RuntimeValue::Undef))
                        }
                        _ => Ok(RuntimeValue::Undef),
                    }
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "flat_hash" => {
                let mut entries = Vec::new();
                for arg in args {
                    match arg {
                        RuntimeValue::Hash(h_entries) => {
                            for (k, v) in h_entries {
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
            // ── BACKTRACK / IBACKTRACK cursor save/restore ──
            "BACKTRACK" => {
                ctx.push_backtrack();
                Ok(RuntimeValue::Undef)
            }
            "IBACKTRACK" => {
                ctx.pop_backtrack();
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
                        linkedspec_core::expr::Expr::Call { name: branch_name, args: branch_args }
                    ) = &raw_args[i] {
                        if branch_name == "elseif" && !branch_args.is_empty() {
                            let elseif_cond = self.eval_expr(branch_args[0].value(), ctx, rule_label)?;
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
            "endif" => {
                Ok(RuntimeValue::Undef)
            }
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
                        linkedspec_core::expr::Expr::Call { name: branch_name, args: branch_args }
                    ) = &raw_args[i] {
                        if branch_name == "case" && !branch_args.is_empty() {
                            let case_val = self.eval_expr(branch_args[0].value(), ctx, rule_label)?;
                            if case_val.to_str() == switch_str {
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
            "endswitch" | "endcase" => {
                Ok(RuntimeValue::Undef)
            }
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
 /pattern1/ -> Child {
  I { declare(array, results) }
  LE { push_value(array(results), scalar(retv)) }
  E { return(array("?results:", array_copy(array(results)))) }
 }

Child::
 /hello[ \t]+(\w+)/
 I { declare(scalar, name=entry_group(1)) }
 E { return(scalar(name)) }
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

    // ── Lifecycle order tests ──

    #[test]
    fn lifecycle_all_markers_fire_in_order() {
        // Grammar that exercises all 7 lifecycle markers with REP (* mode).
        let grammar = r#"Top::*
 /hello/
 I { declare(array, log); push_value(array(log), scalar("I")) }
 LS { push_value(array(log), scalar("LS")) }
 LE { push_value(array(log), scalar("LE")) }
 IT { push_value(array(log), scalar("IT")) }
 LX { push_value(array(log), scalar("LX")) }
 EX { push_value(array(log), scalar("EX")) }
 E { push_value(array(log), scalar("E")); return(array_copy(array(log))) }
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
 I { declare(array, log); push_value(array(log), scalar("I")) }
 LS { push_value(array(log), scalar("LS")) }
 LX { push_value(array(log), scalar("LX")) }
 E { push_value(array(log), scalar("E")); return(array_copy(array(log))) }
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
 I { declare(array, log) }
 LE { push_value(array(log), scalar("match")) }
 E { return(array_copy(array(log))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        // "hello hello" → should match only once due to max=1
        let result = engine.execute("hello hello").unwrap();
        let arr = result.as_array().unwrap();
        assert_eq!(arr.len(), 1, "expected 1 match due to max bound, got {:?}", arr);
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
        let grammar = r#"Top::AND
 I { declare(array, log) }
 => ChildA
 => ChildB
 E { return(array_copy(array(log))) }

ChildA:
 /a/
 I { push_value(array(log), scalar("A")) }

ChildB:
 /b/
 I { push_value(array(log), scalar("B")) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("a b").unwrap();
        let outer: &Vec<Value> = result.as_array().unwrap();
        assert!(!outer.is_empty());
        let inner: &Vec<Value> = outer[0].as_array().unwrap();
        assert_eq!(inner.len(), 2, "expected 2 children in log, got {:?}", inner);
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
 I { declare(array, results) }
 -> A
 -> A[1]
 -> A[2]
 E { return(array_copy(array(results))) }
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
 I { declare(array, results) }
 LE { push_value(array(results), scalar(retv)) }
 E { return(array("?results:", array_copy(array(results)))) }

ChildA:
 /hello/
 I { declare(scalar, retv=entry_text()) }
 E { return(scalar(retv)) }

ChildB:
 /world/
 I { declare(scalar, retv=entry_text()) }
 E { return(scalar(retv)) }
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
 I { declare(scalar, name) }
 E { assign(scalar(name), entry_text()); return(scalar(name)) }
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
 I { declare(scalar, name) }
 E { return(scalar(name)) }
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
 I { declare(scalar, word) }
 LE { assign(scalar(word), entry_group(1)) }
 E { return(scalar(word)) }
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
 I { declare(scalar, word) }
 E { assign(scalar(word), entry_group(1)); return(scalar(word)) }
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
    fn helpers_5_1_declare_array_push_value_array_copy() {
        let grammar = r#"Top::
 /(\w+)/
 I { declare(array, results) }
 LE { push_value(array(results), entry_group(1)) }
 E { return(array_copy(array(results))) }
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
 I { declare(array, items); declare(scalar, item_count) }
 LE { push_value(array(items), entry_group(1)) }
 E { assign(scalar(item_count), count(array(items))); return(scalar(item_count)) }
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
    fn helpers_5_1_push_nonempty() {
        let grammar = r#"Top::
 /(\w+)/
 I { declare(array, items) }
 LE { push_nonempty(array(items), entry_group(1)) }
 E { return(array_copy(array(items))) }
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
        // Use hash() constructor and hash_copy() for roundtrip
        let grammar = r#"Top::
 /(\w+)=(\d+)/
 I { declare(hash, config) }
 LE { set_key(hash(config), entry_group(1), entry_group(2)) }
 E { return(entry_group(1)) }
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

    // ── .5.2 Scalar and capture helper tests ──

    #[test]
    fn helpers_5_2_entry_text_and_entry_group() {
        let grammar = r#"Top::
 /hello[ \t]+(\w+)/
 E { return(concat(scalar(entry_text()), scalar(" "), scalar(entry_group(1)))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello world").unwrap();
        let arr = result.as_array().unwrap();
        assert!(arr[0].as_str().unwrap().contains("hello"), "got {:?}", arr[0]);
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
        assert!(groups.len() >= 2, "expected >=2 groups, got {:?}", groups);
    }

    #[test]
    fn helpers_5_2_scalar_accessor() {
        // scalar(varname) returns the declared variable's value
        let grammar = r#"Top::
 /(\w+)/
 I { declare(scalar, word) }
 LE { assign(scalar(word), entry_group(1)) }
 E { return(scalar(word)) }
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
 I { declare(scalar, first); declare(scalar, second) }
 E { return(coalesce(scalar(first), scalar(second), scalar("default"))) }
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
 I { declare(scalar, val) }
 LE { assign(scalar(val), entry_group(1)) }
 E { return(coalesce(scalar(val), scalar("fallback"))) }
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
 E { return(concat(entry_group(1), scalar("+"), entry_group(2))) }
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
 I { mark_here(scalar("start")) }
 LE { return(capture_from(scalar("start"))) }
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
 I { mark_here(scalar("pos")) }
 LE { return(mark_pos(scalar("pos"))) }
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
 I { declare(array, items) }
 LE { push_value(array(items), entry_group(1)) }
 E { return(array_copy(array(items))); return_undef() }
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
 E { return(scalar("never_reached")) }
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
 I { declare(scalar, retv=next()) }
 E { return(scalar(retv)) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello").unwrap();
        let arr = result.as_array().unwrap();
        // next() returns undef
        assert!(arr[0].is_null(), "next() should return null, got {:?}", arr[0]);
    }

    #[test]
    fn helpers_5_3_coalesce_nonempty_skips_empty() {
        // coalesce_nonempty skips undef and "" but keeps "0" and other defined values
        let grammar = r#"Top::
 /(\d+)/
 I { declare(scalar, val) }
 LE { assign(scalar(val), entry_group(1)) }
 E { return(coalesce_nonempty(scalar(""), scalar(val), scalar("final"))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("42").unwrap();
        let arr = result.as_array().unwrap();
        // "" is nonempty? Actually scalar("") returns Scalar("") which IS empty
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
 I { declare(scalar, val) }
 LE { assign(scalar(val), entry_group(1)) }
 E { return(if(is_nonempty(val), scalar("found"), scalar("empty"))) }
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
 I { declare(scalar, val) }
 E { return(if(is_defined(val), scalar("defined"), scalar("undefined"))) }
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
 I { declare(scalar, val) }
 LE { assign(scalar(val), entry_group(1)) }
 E { return(if(is_defined(val), entry_text(), scalar("fallback"))) }
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
 E { return(if(0, scalar("then"),
               elseif(1, scalar("elseif_ok")),
               scalar("none"))) }
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
 I { declare(scalar, a); declare(scalar, b); declare(scalar, c) }
 E { return(if(is_nonempty(a), scalar("a"),
               elseif(is_nonempty(b), scalar("b")),
               else(scalar("none")))) }
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
 I { declare(scalar, val) }
 LE { assign(scalar(val), entry_group(1)) }
 E { return(switch(scalar(val),
               case(scalar("hello"), scalar("greeting")),
               case(scalar("world"), scalar("planet")),
               default(scalar("unknown")))) }
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
 I { declare(scalar, val) }
 LE { assign(scalar(val), entry_group(1)) }
 E { return(switch(scalar(val),
               case(scalar("red"), scalar("color")),
               default(scalar("not_a_color")))) }
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
 I { declare(scalar, val) }
 LE { assign(scalar(val), entry_group(1)) }
 E { return(switch(scalar(val),
               case(scalar("1"), scalar("one")),
               case(scalar("2"), scalar("two")),
               case(scalar("3"), scalar("three")),
               default(scalar("many")))) }
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
 E { endif(); endswitch(); endcase(); return(scalar("ok")) }
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
 I { declare(scalar, val) }
 LE { assign(scalar(val), entry_group(1)) }
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
 I { declare(scalar, val) }
 LE { assign(scalar(val), entry_group(1)) }
 E { return(if(is_defined(val), scalar("ok"),
               elseif(is_empty(val), exit_now(1)),
               scalar("fallback"))) }
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
    // BACKTRACK/IBACKTRACK tests
    // ═══════════════════════════════════════════════════════════

    #[test]
    fn backtrack_save_and_restore_cursor() {
        let grammar = r#"Top::
 /hello/
 I { BACKTRACK() }
 E { return(IBACKTRACK()) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        // IBACKTRACK returns undef, BACKTRACK saves position
        let result = engine.execute("hello");
        assert!(result.is_ok(), "expected ok, got {:?}", result);
        let val = result.unwrap();
        let arr = val.as_array().unwrap();
        assert!(arr[0].is_null());
    }

    #[test]
    fn backtrack_restores_position_for_retry() {
        // Save position before match, restore on no-match via LX
        let grammar = r#"Top::OR{1}
 /hello/
 I { BACKTRACK() }
 E { return() }
 LX { IBACKTRACK() }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello");
        assert!(result.is_ok(), "backtrack restore should succeed, got {:?}", result);
    }

    #[test]
    fn backtrack_empty_stack_no_op() {
        // IBACKTRACK with empty stack should not crash
        let grammar = r#"Top::
 /(\w+)/
 E { IBACKTRACK(); return(entry_group(1)) }
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
    fn backtrack_multiple_push_pop() {
        // BACKTRACK saves position; IBACKTRACK restores it
        let grammar = r#"Top::
 /(hello) (world)/
 I { declare(array, log); BACKTRACK() }
 LE { push_value(array(log), cursor_pos()) }
 E { push_value(array(log), cursor_pos());
      IBACKTRACK(); push_value(array(log), cursor_pos());
      return(array_copy(array(log))) }
"#;
        let spec = parse_spec(grammar).unwrap();
        validate(&spec).unwrap();
        let compiled = compile(&spec).unwrap();
        let engine = Engine::new(compiled);
        let result = engine.execute("hello world");
        assert!(result.is_ok(), "backtrack should work, got {:?}", result);
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
        engine
            .execute(input)
            .unwrap()
            .as_array()
            .unwrap()
            .clone()
    }

    #[test]
    fn chars_5_3_substr_is_char_based_no_panic() {
        // substr(café, 3, 1) = "é" (char index 3). Byte-slicing s[3..4] would
        // panic — byte 3 is the first of the two bytes of 'é'.
        let grammar = r#"Top::
 /café/
 E { return(substr(scalar(entry_text()), scalar(3), scalar(1))) }
"#;
        let acc = run_5_3(grammar, "café");
        assert_eq!(acc.last().unwrap().as_str().unwrap(), "é");
    }

    #[test]
    fn chars_5_3_input_slice_is_char_based() {
        // input_slice(start=3, width=1) over "café" = "é" (char offsets).
        let grammar = r#"Top::
 /café/
 E { return(input_slice(scalar(3), scalar(1))) }
"#;
        let acc = run_5_3(grammar, "café");
        assert_eq!(acc.last().unwrap().as_str().unwrap(), "é");
    }

    #[test]
    fn chars_5_3_cursor_pos_is_char_offset() {
        // After matching "café" the cursor is at byte 5 but char offset 4.
        let grammar = r#"Top::
 /café/
 E { return(scalar(cursor_pos())) }
"#;
        let acc = run_5_3(grammar, "café x");
        assert_eq!(acc.last().unwrap().as_f64().unwrap(), 4.0);
    }

    #[test]
    fn chars_5_3_cursor_col_is_char_based() {
        // "héllo" is 6 bytes / 5 chars; column after it = 5 + 1 = 6 (char-based).
        let grammar = r#"Top::
 /héllo/
 E { return(scalar(cursor_col())) }
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
 E { return(scalar(match_start_pos())) }
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
 E { return(scalar(entry_start_pos())) }
"#;
        let acc = run_5_3(grammar, "hi world");
        assert_eq!(acc.last().unwrap().as_f64().unwrap(), 3.0);
    }

    #[test]
    fn chars_5_3_length_is_char_count() {
        // length("café") = 4 chars (not 5 bytes).
        let grammar = r#"Top::
 /café/
 E { return(scalar(length(scalar(entry_text())))) }
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
 I { declare(array, iters) }
 LE { push_value(array(iters), scalar("i")) }
 E { return(array_copy(array(iters))) }
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
    fn hash_5_4_better_hash_arm_merges_hash_args() {
        // Distinguishing behavior of the surviving `hash` arm: it merges
        // Hash-valued args, which the removed shadowing duplicate dropped.
        // hash("b","2", hash("a","1")) must yield BOTH keys.
        let grammar = r#"Top:: /(\w+)/
 E { return(hash(scalar("b"), scalar("2"), hash(scalar("a"), scalar("1")))) }
"#;
        let acc = run_5_3(grammar, "x");
        let obj = acc.last().unwrap().as_object().cloned().unwrap_or_default();
        assert_eq!(obj.get("b").and_then(|v| v.as_str()), Some("2"));
        assert_eq!(
            obj.get("a").and_then(|v| v.as_str()),
            Some("1"),
            "the merged Hash arg must survive — proves the better hash arm won, got {:?}",
            acc.last()
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
 E { return(entry_named(scalar("year"))) }
"#;
        let acc = run_5_5_1(present, "2024-03");
        assert_eq!(acc.last().unwrap().as_str().unwrap(), "2024");

        // An absent name returns undef (JSON null), per the catalog.
        let absent = r#"Top::
 /(?P<year>\d+)/
 E { return(entry_named(scalar("nope"))) }
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
        // entry_has(name) is true for a present named group, false otherwise.
        let g_present = r#"Top::
 /(?P<word>\w+)/
 E { return(entry_has(scalar("word"))) }
"#;
        assert!(run_5_5_1(g_present, "hi").last().unwrap().as_bool().unwrap());

        let g_absent = r#"Top::
 /(?P<word>\w+)/
 E { return(entry_has(scalar("missing"))) }
"#;
        assert!(!run_5_5_1(g_absent, "hi").last().unwrap().as_bool().unwrap());
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
 E { return(match_named(scalar("month"))) }
"#;
        let acc = run_5_5_1(present, "2024-03");
        assert_eq!(acc.last().unwrap().as_str().unwrap(), "03");

        let absent = r#"Top::
 /(?P<year>\d+)/
 E { return(match_named(scalar("nope"))) }
"#;
        assert!(run_5_5_1(absent, "2024").last().unwrap().is_null());
    }

    #[test]
    fn helpers_5_5_1_match_has_presence() {
        let g_present = r#"Top::
 /(?P<word>\w+)/
 E { return(match_has(scalar("word"))) }
"#;
        assert!(run_5_5_1(g_present, "hi").last().unwrap().as_bool().unwrap());

        let g_absent = r#"Top::
 /(?P<word>\w+)/
 E { return(match_has(scalar("missing"))) }
"#;
        assert!(!run_5_5_1(g_absent, "hi").last().unwrap().as_bool().unwrap());
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
 E { return(scalar(input_end_line())) }
"#;
        assert_eq!(run_5_5_2(g, "abc").last().unwrap().as_f64().unwrap(), 1.0); // no newline
        assert_eq!(run_5_5_2(g, "a\nb\nc").last().unwrap().as_f64().unwrap(), 3.0); // 2 newlines
        assert_eq!(run_5_5_2(g, "a\nb\n").last().unwrap().as_f64().unwrap(), 3.0); // trailing newline
    }

    #[test]
    fn helpers_5_5_2_input_end_col_is_char_based() {
        // input_end_col(): char distance past the last newline, +1 when none.
        let g = r#"Top::
 /\w/
 E { return(scalar(input_end_col())) }
"#;
        assert_eq!(run_5_5_2(g, "abc").last().unwrap().as_f64().unwrap(), 4.0); // len 3, no nl → 4
        assert_eq!(run_5_5_2(g, "ab\ncde").last().unwrap().as_f64().unwrap(), 4.0); // "cde" past nl → 4
        assert_eq!(run_5_5_2(g, "ab\n").last().unwrap().as_f64().unwrap(), 1.0); // empty final line → 1
        // Char-based, not byte-based: 'é' is 2 bytes but 1 column → "héllo" = 5 chars → 6.
        assert_eq!(run_5_5_2(g, "héllo").last().unwrap().as_f64().unwrap(), 6.0);
    }

    #[test]
    fn helpers_5_5_2_flat_array_and_hash() {
        // flat(array) yields the array's elements as a list value.
        let g_arr = r#"Top::
 /\w/
 E { return(flat(array(scalar("a"), scalar("b")))) }
"#;
        let acc = run_5_5_2(g_arr, "x");
        let arr = acc.last().unwrap().as_array().unwrap();
        assert_eq!(arr.len(), 2);
        assert_eq!(arr[0].as_str().unwrap(), "a");
        assert_eq!(arr[1].as_str().unwrap(), "b");

        // flat(hash) splices key/value entries into a parent hash(...).
        let g_hash = r#"Top::
 /\w/
 E { return(hash(scalar("a"), scalar("1"), flat(hash(scalar("b"), scalar("2"))))) }
"#;
        let acc = run_5_5_2(g_hash, "x");
        let obj = acc.last().unwrap().as_object().unwrap();
        assert_eq!(obj.get("a").and_then(|v| v.as_str()), Some("1"));
        assert_eq!(obj.get("b").and_then(|v| v.as_str()), Some("2"));
        assert_eq!(obj.len(), 2);
    }

    // ── RUST-PARITY.5.5.3: mark-based capture family ──
    // A bare `Top::` rule is Seek mode (matches once); over `"  hi"` the
    // `/(\w+)/` match starts at byte 2, over `"ab cd"` it matches "ab" (cursor
    // ends at byte 2). `mark_input_start` pins a mark at 0, `mark_input_end` at
    // the byte length — giving deterministic spans independent of the match.
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
        let g = r#"Top::
 /(\w+)/
 E { mark_input_start(scalar("a")); return(capture_from(scalar("a"))) }
"#;
        let acc = run_5_5_3(g, "  hi");
        assert_eq!(acc[0].as_str().unwrap(), "  ");
    }

    #[test]
    fn helpers_5_5_3_capture_from_undef_on_missing_mark() {
        let g = r#"Top::
 /(\w+)/
 E { return(capture_from(scalar("nope"))) }
"#;
        let acc = run_5_5_3(g, "hi");
        assert!(acc[0].is_null(), "missing mark → undef, got {:?}", acc[0]);
    }

    #[test]
    fn helpers_5_5_3_capture_len_from_is_char_count() {
        let g = r#"Top::
 /(\w+)/
 E { mark_input_start(scalar("a")); return(capture_len_from(scalar("a"))) }
"#;
        let acc = run_5_5_3(g, "  hi");
        assert_eq!(acc[0].as_f64().unwrap(), 2.0); // "  " before the match
    }

    #[test]
    fn helpers_5_5_3_capture_until_cursor_from() {
        // mark 0 → cursor (match-end of "ab" = byte 2).
        let g = r#"Top::
 /(\w+)/
 E { mark_input_start(scalar("a")); return(capture_until_cursor_from(scalar("a"))) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        assert_eq!(acc[0].as_str().unwrap(), "ab");
    }

    #[test]
    fn helpers_5_5_3_capture_until_cursor_len_from() {
        let g = r#"Top::
 /(\w+)/
 E { mark_input_start(scalar("a")); return(capture_until_cursor_len_from(scalar("a"))) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        assert_eq!(acc[0].as_f64().unwrap(), 2.0);
    }

    #[test]
    fn helpers_5_5_3_capture_rest_from_reads_to_end() {
        // mark 0 → end-of-input (past the cursor at byte 2).
        let g = r#"Top::
 /(\w+)/
 E { mark_input_start(scalar("a")); return(capture_rest_from(scalar("a"))) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        assert_eq!(acc[0].as_str().unwrap(), "ab cd");
    }

    #[test]
    fn helpers_5_5_3_capture_rest_len_from() {
        let g = r#"Top::
 /(\w+)/
 E { mark_input_start(scalar("a")); return(capture_rest_len_from(scalar("a"))) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        assert_eq!(acc[0].as_f64().unwrap(), 5.0);
    }

    #[test]
    fn helpers_5_5_3_capture_between_and_len_multibyte() {
        // mark_input_start(a)=0, mark_input_end(b)=byte len; the span is the whole
        // multibyte input. capture_between returns the text; capture_len_between
        // returns the CHAR count (5), not the byte count (6) — char-based parity.
        let g = r#"Top::
 /\w/
 E { mark_input_start(scalar("a")); mark_input_end(scalar("b")); return(capture_between(scalar("a"), scalar("b"))); return(capture_len_between(scalar("a"), scalar("b"))) }
"#;
        let acc = run_5_5_3(g, "héllo");
        assert_eq!(acc[0].as_str().unwrap(), "héllo");
        assert_eq!(acc[1].as_f64().unwrap(), 5.0);
    }

    #[test]
    fn helpers_5_5_3_capture_between_undef_when_reversed() {
        // a = end-of-input, b = start-of-input → reversed span → undef.
        let g = r#"Top::
 /(\w+)/
 E { mark_input_end(scalar("a")); mark_input_start(scalar("b")); return(capture_between(scalar("a"), scalar("b"))) }
"#;
        let acc = run_5_5_3(g, "hi");
        assert!(acc[0].is_null(), "reversed span → undef, got {:?}", acc[0]);
    }

    #[test]
    fn helpers_5_5_3_mark_copy_copies_position() {
        // copy a (=0) into b, then read until cursor from b → "ab".
        let g = r#"Top::
 /(\w+)/
 E { mark_input_start(scalar("a")); mark_copy(scalar("b"), scalar("a")); return(capture_until_cursor_from(scalar("b"))) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        assert_eq!(acc[0].as_str().unwrap(), "ab");
    }

    #[test]
    fn helpers_5_5_3_mark_copy_deletes_target_when_source_missing() {
        // b is set, then mark_copy(b, <missing>) deletes b → capture_from(b) undef.
        let g = r#"Top::
 /(\w+)/
 E { mark_input_start(scalar("b")); mark_copy(scalar("b"), scalar("nope")); return(capture_from(scalar("b"))) }
"#;
        let acc = run_5_5_3(g, "hi");
        assert!(acc[0].is_null(), "deleted target → undef, got {:?}", acc[0]);
    }

    #[test]
    fn helpers_5_5_3_capture_take_until_cursor_from_advances_mark() {
        // First take reads mark→cursor ("ab") and advances the mark to the cursor;
        // the second read (mark now == cursor) is therefore empty.
        let g = r#"Top::
 /(\w+)/
 E { mark_input_start(scalar("a")); return(capture_take_until_cursor_from(scalar("a"))); return(capture_until_cursor_from(scalar("a"))) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        assert_eq!(acc[0].as_str().unwrap(), "ab");
        assert_eq!(acc[1].as_str().unwrap(), "");
    }

    #[test]
    fn helpers_5_5_3_capture_take_until_cursor_len_from_advances_mark() {
        let g = r#"Top::
 /(\w+)/
 E { mark_input_start(scalar("a")); return(capture_take_until_cursor_len_from(scalar("a"))); return(capture_until_cursor_len_from(scalar("a"))) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        assert_eq!(acc[0].as_f64().unwrap(), 2.0);
        assert_eq!(acc[1].as_f64().unwrap(), 0.0);
    }

    #[test]
    fn helpers_5_5_3_capture_take_len_from_advances_mark_to_cursor() {
        // len is mark→match-START ("  " = 2); the mark then advances to the CURSOR
        // (match-end, byte 4), so capture_rest_from is empty afterwards.
        let g = r#"Top::
 /(\w+)/
 E { mark_input_start(scalar("a")); return(capture_take_len_from(scalar("a"))); return(capture_rest_from(scalar("a"))) }
"#;
        let acc = run_5_5_3(g, "  hi");
        assert_eq!(acc[0].as_f64().unwrap(), 2.0);
        assert_eq!(acc[1].as_str().unwrap(), "");
    }

    #[test]
    fn helpers_5_5_3_capture_take_rest_from_advances_mark_to_end() {
        let g = r#"Top::
 /(\w+)/
 E { mark_input_start(scalar("a")); return(capture_take_rest_from(scalar("a"))); return(capture_rest_from(scalar("a"))) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        assert_eq!(acc[0].as_str().unwrap(), "ab cd");
        assert_eq!(acc[1].as_str().unwrap(), "");
    }

    #[test]
    fn helpers_5_5_3_capture_take_rest_len_from_advances_mark_to_end() {
        let g = r#"Top::
 /(\w+)/
 E { mark_input_start(scalar("a")); return(capture_take_rest_len_from(scalar("a"))); return(capture_rest_len_from(scalar("a"))) }
"#;
        let acc = run_5_5_3(g, "ab cd");
        assert_eq!(acc[0].as_f64().unwrap(), 5.0);
        assert_eq!(acc[1].as_f64().unwrap(), 0.0);
    }

    // ── RUST-PARITY.5.5.4: anonymous capture-slice family ──
    // `I { start_capture_slice() }` records the anonymous capture start at the
    // pre-seek cursor (pos 0 for the top rule); a bare `Top::` rule is Seek mode,
    // so over "  ab cd" the `/(\w+)/` match is "ab" at bytes 2..4 (match-start 2,
    // cursor 4), end-of-input 7. That fixes the three endpoints the family reads:
    // match-start (2), cursor (4), end (7). Reuses the run_5_5_3 pipeline harness.

    #[test]
    fn helpers_5_5_4_capture_slice_reads_pre_match_text() {
        // capture_slice ends at match-START → the "  " skipped before the match.
        let g = r#"Top::
 /(\w+)/
 I { start_capture_slice() }
 E { return(capture_slice()); return(capture_slice_len()) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        assert_eq!(acc[0].as_str().unwrap(), "  ");
        assert_eq!(acc[1].as_f64().unwrap(), 2.0);
    }

    #[test]
    fn helpers_5_5_4_capture_slice_until_cursor() {
        // ends at the CURSOR (match-end, byte 4) → "  ab".
        let g = r#"Top::
 /(\w+)/
 I { start_capture_slice() }
 E { return(capture_slice_until_cursor()); return(capture_slice_until_cursor_len()) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        assert_eq!(acc[0].as_str().unwrap(), "  ab");
        assert_eq!(acc[1].as_f64().unwrap(), 4.0);
    }

    #[test]
    fn helpers_5_5_4_capture_rest_reads_to_end() {
        // ends at END-of-input (byte 7), past the cursor → the whole input.
        let g = r#"Top::
 /(\w+)/
 I { start_capture_slice() }
 E { return(capture_rest()); return(capture_rest_len()) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        assert_eq!(acc[0].as_str().unwrap(), "  ab cd");
        assert_eq!(acc[1].as_f64().unwrap(), 7.0);
    }

    #[test]
    fn helpers_5_5_4_capture_take_advances_to_cursor() {
        // capture_take reads to match-START ("  ") and advances capture_start to
        // the CURSOR (byte 4); the following capture_rest is then 4→end = " cd".
        let g = r#"Top::
 /(\w+)/
 I { start_capture_slice() }
 E { return(capture_take()); return(capture_rest()) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        assert_eq!(acc[0].as_str().unwrap(), "  ");
        assert_eq!(acc[1].as_str().unwrap(), " cd");
    }

    #[test]
    fn helpers_5_5_4_capture_take_len_advances_to_cursor() {
        // len is capture_start→match-START (2); capture_start then advances to the
        // CURSOR (byte 4), so capture_rest_len afterward is 3 (" cd").
        let g = r#"Top::
 /(\w+)/
 I { start_capture_slice() }
 E { return(capture_take_len()); return(capture_rest_len()) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        assert_eq!(acc[0].as_f64().unwrap(), 2.0);
        assert_eq!(acc[1].as_f64().unwrap(), 3.0);
    }

    #[test]
    fn helpers_5_5_4_capture_take_until_cursor_advances() {
        // reads capture_start→cursor ("  ab") and advances capture_start to the
        // cursor, so the second until-cursor read (start == cursor) is empty.
        let g = r#"Top::
 /(\w+)/
 I { start_capture_slice() }
 E { return(capture_take_until_cursor()); return(capture_slice_until_cursor()) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        assert_eq!(acc[0].as_str().unwrap(), "  ab");
        assert_eq!(acc[1].as_str().unwrap(), "");
    }

    #[test]
    fn helpers_5_5_4_capture_take_until_cursor_len_advances() {
        let g = r#"Top::
 /(\w+)/
 I { start_capture_slice() }
 E { return(capture_take_until_cursor_len()); return(capture_slice_until_cursor_len()) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        assert_eq!(acc[0].as_f64().unwrap(), 4.0);
        assert_eq!(acc[1].as_f64().unwrap(), 0.0);
    }

    #[test]
    fn helpers_5_5_4_capture_take_rest_advances_to_end() {
        // reads capture_start→end ("  ab cd") and advances capture_start to end, so
        // the second capture_rest read is empty.
        let g = r#"Top::
 /(\w+)/
 I { start_capture_slice() }
 E { return(capture_take_rest()); return(capture_rest()) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        assert_eq!(acc[0].as_str().unwrap(), "  ab cd");
        assert_eq!(acc[1].as_str().unwrap(), "");
    }

    #[test]
    fn helpers_5_5_4_capture_take_rest_len_advances_to_end() {
        let g = r#"Top::
 /(\w+)/
 I { start_capture_slice() }
 E { return(capture_take_rest_len()); return(capture_rest_len()) }
"#;
        let acc = run_5_5_3(g, "  ab cd");
        assert_eq!(acc[0].as_f64().unwrap(), 7.0);
        assert_eq!(acc[1].as_f64().unwrap(), 0.0);
    }

    #[test]
    fn helpers_5_5_4_capture_rest_len_is_char_count() {
        // Multibyte parity: over "ab,héllo" the match is "ab" (bytes 0..2), so
        // capture_rest spans capture_start 0 → end-of-input. The text is the raw
        // slice; capture_rest_len is the CHAR count (8: a b , h é l l o), not the
        // byte count (9) — DSL lengths are char-based (.5.3).
        let g = r#"Top::
 /(\w+)/
 I { start_capture_slice() }
 E { return(capture_rest()); return(capture_rest_len()) }
"#;
        let acc = run_5_5_3(g, "ab,héllo");
        assert_eq!(acc[0].as_str().unwrap(), "ab,héllo");
        assert_eq!(acc[1].as_f64().unwrap(), 8.0);
    }
}
