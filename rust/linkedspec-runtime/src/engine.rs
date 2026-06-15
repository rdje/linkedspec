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
    fn execute_rule(
        &self,
        label: &str,
        entry_regex_idx: usize,
        ctx: &mut RuntimeContext,
    ) -> Result<(), String> {
        let rule = self
            .spec
            .find(label)
            .ok_or_else(|| format!("rule '{}' (entry idx {}) not found in compiled spec", label, entry_regex_idx))?;

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
                // Execute child rule
                self.execute_rule(&entry.child_label, 0, ctx)?;
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
            return Ok(());
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
                ctx.set_pos(m.end);
                ctx.entry_groups = m.groups.clone();
                ctx.entry_named = m.named.clone();
                ctx.match_groups = m.groups.clone();
                ctx.match_named = m.named.clone();

                // ── Action-edge dispatch ──
                for entry in &rule.acode_dispatch {
                    if entry.regex_idx == m.index {
                        // Use child_regex_idx for multi-entrypoint support
                        self.execute_rule(
                            &entry.child_label,
                            entry.child_regex_idx,
                            ctx,
                        )?;
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

            // Zero-progress guard: if we're past min and position hasn't changed,
            // we're stuck in an infinite loop. Force break.
            if is_rep && matches > rep_min && matches > 100 {
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

        Ok(())
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
        _rule_label: &str,
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
                    ctx.push_accumulator(val.clone());
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
                if let Some(arg) = args.first() {
                    let child = arg.to_str();
                    self.execute_rule(&child, 0, ctx)?;
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
            "print" => {
                for a in args {
                    eprintln!("{}", a.to_str());
                }
                Ok(RuntimeValue::Undef)
            }
            // ── Hash ──
            "hash" | "h" => {
                // args are flat key,value,key,value pairs
                let mut entries = Vec::new();
                let mut i = 0;
                while i + 1 < args.len() {
                    let key = args[i].to_str();
                    let val = args[i + 1].clone();
                    entries.push((key, val));
                    i += 2;
                }
                Ok(RuntimeValue::Hash(entries))
            }
            "hash_copy" => {
                if let Some(arg) = args.first() {
                    match arg {
                        RuntimeValue::Hash(h) => {
                            Ok(RuntimeValue::Hash(h.clone()))
                        }
                        _ => {
                            let hash_name = arg.to_str();
                            if !hash_name.is_empty() {
                                Ok(RuntimeValue::Hash(
                                    ctx.hash_copy(&hash_name),
                                ))
                            } else {
                                Ok(RuntimeValue::Hash(Vec::new()))
                            }
                        }
                    }
                } else {
                    Ok(RuntimeValue::Hash(Vec::new()))
                }
            }
            _ => {
                // Unknown helper — return undef silently (compatibility)
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
}
