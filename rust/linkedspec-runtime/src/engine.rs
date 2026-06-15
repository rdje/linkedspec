//! Runtime engine — executes compiled rule specifications against input text.
//!
//! The engine:
//! 1. Builds regex alternations from compiled rule patterns
//! 2. Executes the lifecycle loop (I → LS → match → LE → IT → LX/EX → E)
//! 3. Dispatches to child rules recursively
//! 4. Interprets lifecycle code expression trees
//! 5. Returns parse results as JSON

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
    pub fn execute(&self, input: &str) -> Result<Value, String> {
        let top = self.spec.top_rule().ok_or("no top rule in compiled spec")?;
        let label = top.label.clone();
        let mut ctx = RuntimeContext::new(input);
        self.execute_rule(&label, &mut ctx)?;
        Ok(RuntimeValue::Array(ctx.accumulator.clone()).to_json())
    }

    /// Execute a specific rule by label.
    fn execute_rule(&self, label: &str, ctx: &mut RuntimeContext) -> Result<(), String> {
        let rule = self.spec.find(label).ok_or_else(|| format!("rule '{}' not found", label))?;

        // Build regex alternation
        let alt = if rule.regex_patterns.is_empty() {
            CompiledAlternation::compile(&["\\w+".to_string()])?
        } else {
            CompiledAlternation::compile(&rule.regex_patterns)?
        };

        // Execute I-block (preamble)
        if let Some(ref preamble) = rule.preamble {
            self.execute_block(preamble, ctx, label)?;
        }

        let is_rep = rule.rep_min.is_some();
        let rep_min = rule.rep_min.unwrap_or(0);
        let rep_max = rule.rep_max;
        let mut matches: usize = 0;
        let max_iter = 10_000;

        for _ in 0..max_iter {
            // Non-REP rules execute once
            if !is_rep && matches > 0 {
                break;
            }

            // LS-block
            if let Some(ref lscode) = rule.lscode {
                self.execute_block(lscode, ctx, label)?;
            }

            // Match
            let match_result = match rule.parse_mode {
                ParseMode::Consume => alt.consume_match(&ctx.input, ctx.pos),
                ParseMode::Seek => alt.seek_match(&ctx.input, ctx.pos),
            };

            if let Some(m) = match_result {
                ctx.set_pos(m.end);
                ctx.entry_groups = m.groups.clone();
                ctx.entry_named = m.named.clone();
                ctx.match_groups = m.groups.clone();
                ctx.match_named = m.named.clone();

                // Dispatch to child rule if acode_dispatch
                for entry in &rule.acode_dispatch {
                    if entry.regex_idx == m.index {
                        // Execute child rule
                        self.execute_rule(&entry.child_label, ctx)?;
                        // Execute attached code if present
                        if let Some(ref block) = entry.code {
                            self.execute_block(block, ctx, label)?;
                        }
                    }
                }

                // LE-block
                if let Some(ref lecode) = rule.lecode {
                    self.execute_block(lecode, ctx, label)?;
                }

                matches += 1;

                // IT-block (per-iteration, REP only)
                if let Some(ref itcode) = rule.itcode {
                    self.execute_block(itcode, ctx, label)?;
                }
            } else {
                // No match — exit loop
                // LX-block (no-match exit)
                if let Some(ref lxcode) = rule.lxcode {
                    self.execute_block(lxcode, ctx, label)?;
                }
                break;
            }

            // Check max bound
            if let Some(max) = rep_max {
                if matches >= max {
                    break;
                }
            }

            // Zero-progress guard for REP variants
            if is_rep && matches > 100 && matches > rep_min {
                break;
            }
        }

        // Check min bound for REP variants
        if is_rep && matches < rep_min {
            return Err(format!(
                "rule '{}': expected at least {} matches, got {}",
                label, rep_min, matches
            ));
        }

        // EX-block (REP exhaustion)
        if let Some(ref excode) = rule.excode {
            self.execute_block(excode, ctx, label)?;
        }

        // E-block (exit)
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
                self.call_helper(name, &evaluated, ctx, rule_label)
            }
            Expr::Variable { name } => Ok(ctx.get_scalar(name)),
            Expr::IndexedVar { name, index } => {
                let idx_val = self.eval_expr(index, ctx, rule_label)?;
                let idx: usize = idx_val.as_number().unwrap_or(0.0) as usize;
                let arr = ctx.get_array(name);
                Ok(arr.get(idx).cloned().unwrap_or(RuntimeValue::Undef))
            }
            Expr::StringLiteral { value } => Ok(RuntimeValue::Scalar(value.clone())),
            Expr::NumberLiteral { value } => Ok(RuntimeValue::Number(*value)),
            Expr::BooleanLiteral { value } => Ok(RuntimeValue::Bool(*value)),
            Expr::RegexLiteral { pattern } => Ok(RuntimeValue::Scalar(pattern.clone())),
            Expr::Undef => Ok(RuntimeValue::Undef),
            Expr::FluentChain { receiver, calls } => {
                // Evaluate the receiver expression (e.g. push_value(...))
                self.eval_expr(receiver, ctx, rule_label)?;
                // Evaluate each fluent call in sequence (e.g. .return(...), .endif())
                for call in calls {
                    let evaluated: Vec<RuntimeValue> = call.args
                        .iter()
                        .map(|a| self.eval_expr(a.value(), ctx, rule_label))
                        .collect::<Result<Vec<_>, _>>()?;
                    self.call_helper(&call.method, &evaluated, ctx, rule_label)?;
                }
                Ok(RuntimeValue::Undef)
            }
        }
    }

    /// Dispatch a helper call by name with evaluated arguments.
    fn call_helper(
        &self,
        name: &str,
        args: &[RuntimeValue],
        ctx: &mut RuntimeContext,
        _rule_label: &str,
    ) -> Result<RuntimeValue, String> {
        match name {
            // Declaration
            "declare" => {
                if args.len() >= 2 {
                    let type_name = args[0].to_str();
                    let var_name = args[1].to_str();
                    match type_name.as_str() {
                        "scalar" => {
                            if args.len() >= 3 {
                                ctx.declare_scalar_with(&var_name, args[2].clone());
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
                    ctx.set_scalar(&args[0].to_str(), args[1].clone());
                }
                Ok(RuntimeValue::Undef)
            }
            // Array
            "array" | "a" => Ok(RuntimeValue::Array(args.to_vec())),
            "array_copy" => {
                if let Some(arg) = args.first() {
                    match arg {
                        RuntimeValue::Array(a) => Ok(RuntimeValue::Array(a.clone())),
                        _ => {
                            let arr_name = arg.to_str();
                            if !arr_name.is_empty() {
                                Ok(RuntimeValue::Array(ctx.array_copy(&arr_name)))
                            } else {
                                Ok(RuntimeValue::Array(Vec::new()))
                            }
                        }
                    }
                } else {
                    Ok(RuntimeValue::Array(Vec::new()))
                }
            }
            "push_value" | "push" => {
                if args.len() >= 2 {
                    let arr_name = args[0].to_str();
                    ctx.push_value(&arr_name, args[1].clone());
                }
                Ok(RuntimeValue::Undef)
            }
            "push_nonempty" => {
                if args.len() >= 2 && args[1].is_nonempty() {
                    let arr_name = args[0].to_str();
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
            // Scalar
            "scalar" => {
                if args.len() >= 2 {
                    match &args[0] {
                        RuntimeValue::Array(arr) => {
                            let idx = args[1].as_number().unwrap_or(0.0) as usize;
                            Ok(arr.get(idx).cloned().unwrap_or(RuntimeValue::Undef))
                        }
                        _ => {
                            let key = args[1].to_str();
                            Ok(ctx.get_scalar(&key))
                        }
                    }
                } else if let Some(arg) = args.first() {
                    Ok(arg.clone())
                } else {
                    Ok(RuntimeValue::Undef)
                }
            }
            "call" => {
                if let Some(arg) = args.first() {
                    let child = arg.to_str();
                    self.execute_rule(&child, ctx)?;
                }
                Ok(RuntimeValue::Undef)
            }
            "concat" => {
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
            // Entry/match
            "entry_text" => Ok(RuntimeValue::Scalar(
                ctx.entry_groups.first().cloned().unwrap_or_default(),
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
            "match_text" => Ok(RuntimeValue::Scalar(
                ctx.match_groups.first().cloned().unwrap_or_default(),
            )),
            "exit_now" => {
                let status = args.first().and_then(|a| a.as_number()).unwrap_or(1.0) as i32;
                ctx.exit_status = Some(status);
                Err(format!("exit_now({status})"))
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
}
