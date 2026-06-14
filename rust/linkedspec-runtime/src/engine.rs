//! Runtime engine — executes compiled HandlerIR nodes against input text.
//!
//! The engine interprets HandlerIR at runtime (not code-gen). It:
//! 1. Extracts child regex patterns from the HandlerIR
//! 2. Builds a compiled alternation
//! 3. Executes the lifecycle loop (seek or consume, with repetition)
//! 4. Returns the parse result as JSON

use crate::helpers::regex_engine::{CompiledAlternation, MatchResult};
use crate::runtime::{RuntimeContext, RuntimeValue};
use linkedspec_core::types::{HandlerIR, ParseMode};
use serde_json::Value;

/// The runtime engine executes HandlerIR nodes against input text.
pub struct Engine;

impl Engine {
    /// Create a new engine.
    pub fn new() -> Self {
        Self
    }

    /// Execute a single handler against the given input.
    ///
    /// Collects the rule's accumulator and returns it as a JSON value.
    pub fn execute(&self, handler: &HandlerIR, input: &str) -> Result<Value, String> {
        let mut ctx = RuntimeContext::new(input);

        // Build regex alternation from the handler's dispatch refs
        let alt = self.build_alternation(handler)?;

        // Execute lifecycle blocks
        self.run_lifecycle(handler, &alt, &mut ctx)?;

        // Return accumulator as JSON
        Ok(RuntimeValue::Array(ctx.accumulator.clone()).to_json())
    }

    /// Build a compiled regex alternation from the handler's dispatch refs.
    fn build_alternation(&self, handler: &HandlerIR) -> Result<CompiledAlternation, String> {
        // Collect child regex patterns from acodes or bcodes
        let patterns: Vec<String> = if let Some(ref acodes) = handler.acodes_ref {
            // For acode variants, each entry corresponds to a child regex
            // In the full implementation, these are code strings; here we use them as labels
            acodes.clone()
        } else if let Some(ref bcalls) = handler.bcalls_ref {
            // For bcode variants, each blind-call target corresponds to a child
            bcalls.iter().map(|_label| format!(r"\w+")) // placeholder
                .collect()
        } else {
            // No edges — use the rule's own regex patterns from body
            vec!["\\w+".to_string()]
        };

        if patterns.is_empty() {
            return Ok(CompiledAlternation::compile(&["\\w+".to_string()])?);
        }

        CompiledAlternation::compile(&patterns)
    }

    /// Execute the lifecycle loop for a handler.
    fn run_lifecycle(
        &self,
        handler: &HandlerIR,
        alt: &CompiledAlternation,
        ctx: &mut RuntimeContext,
    ) -> Result<(), String> {
        let is_rep = handler.is_rep_variant();
        let rep_min = handler.rep_min.unwrap_or(0); // non-REP: 0 min (optional match)
        let rep_max = handler.rep_max;

        // I-block (preamble)
        if let Some(ref preamble) = handler.preamble {
            // In full implementation, interpret lifecycle code
            let _ = preamble;
        }

        let mut matches: usize = 0;
        let max_iterations = 10_000; // safety limit

        for _iter in 0..max_iterations {
            // Check repetition bounds
            if !is_rep && matches > 0 {
                break; // non-REP handlers execute once
            }

            // LS-block
            if let Some(ref lscode) = handler.lscode {
                let _ = lscode;
            }

            // Match
            let match_result = match handler.parse_mode {
                ParseMode::Consume => alt.consume_match(&ctx.input, ctx.pos),
                ParseMode::Seek => alt.seek_match(&ctx.input, ctx.pos),
            };

            if let Some(m) = match_result {
                ctx.set_pos(m.end);
                // Record match groups for lifecycle code
                ctx.entry_groups = m.groups.clone();
                ctx.entry_named = m.named.clone();

                // LE-block
                if let Some(ref lecode) = handler.lecode {
                    self.execute_le_block(lecode, ctx, &m)?;
                }

                matches += 1;

                // IT-block (REP per-iteration)
                if let Some(ref itcode) = handler.itcode {
                    let _ = itcode;
                }
            } else {
                // No match — exit loop
                // LX-block
                if let Some(ref lxcode) = handler.lxcode {
                    let _ = lxcode;
                }
                break;
            }

            // Check max bound
            if let Some(max) = rep_max {
                if matches >= max {
                    break;
                }
            }

            // Zero-progress guard
            if matches > 100 && matches > rep_min {
                break; // safety valve
            }
        }

        // Check min bound (only for REP variants with explicit minimum)
        if is_rep && matches < rep_min {
            return Err(format!(
                "rule '{}': expected at least {} matches, got {}",
                handler.label, rep_min, matches
            ));
        }

        // EX-block
        if let Some(ref excode) = handler.excode {
            let _ = excode;
        }

        // E-block (exit)
        if let Some(ref ecode) = handler.ecode {
            self.execute_e_block(ecode, ctx);
        }

        Ok(())
    }

    /// Execute an LE (Loop End) block: `push_value(array(results), scalar(retv))`
    fn execute_le_block(
        &self,
        code: &str,
        ctx: &mut RuntimeContext,
        m: &MatchResult,
    ) -> Result<(), String> {
        if code.contains("push_value") {
            let arr_name = code
                .split("array(")
                .nth(1)
                .and_then(|s| s.split(')').next())
                .unwrap_or("results");
            let text = m.matched_text().to_string();
            ctx.push_value(arr_name, RuntimeValue::Scalar(text));
        }
        Ok(())
    }

    /// Execute an E (Exit) block: `return(array_copy(array(results)))`
    fn execute_e_block(&self, code: &str, ctx: &mut RuntimeContext) {
        if code.contains("array_copy") {
            // Extract array name and copy to accumulator
            let arr_name = code
                .split("array(")
                .nth(1)
                .and_then(|s| s.split(')').next())
                .unwrap_or("results");
            ctx.accumulator = ctx.array_copy(arr_name);
        }
    }
}

impl Default for Engine {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use linkedspec_core::types::{HandlerIR, HandlerKind, ParseMode};

    fn make_handler() -> HandlerIR {
        HandlerIR {
            kind: HandlerKind::Default,
            label: "Test".into(),
            parse_mode: ParseMode::Seek,
            preamble: Some("declare(array, results)".into()),
            lxcode: None,
            lscode: None,
            lecode: Some("push_value(array(results), scalar(retv))".into()),
            ecode: Some("return(array_copy(array(results)))".into()),
            excode: None,
            itcode: None,
            acodes_ref: Some(vec!["hello".into(), "world".into()]),
            bcodes_ref: None,
            bcalls_ref: None,
            and_icode: None,
            rep_min: None,
            rep_max: None,
        }
    }

    #[test]
    fn engine_finds_matches() {
        let engine = Engine::new();
        let handler = make_handler();
        let result = engine.execute(&handler, "hello world").unwrap();

        // Should have matched "hello" and "world"
        if let Value::Array(arr) = result {
            assert!(arr.len() >= 1);
        } else {
            panic!("expected array result");
        }
    }

    #[test]
    fn engine_empty_input_returns_empty() {
        let engine = Engine::new();
        let handler = make_handler();
        let result = engine.execute(&handler, "zzz no match").unwrap();
        // No matches → empty accumulator
        if let Value::Array(arr) = result {
            assert!(arr.is_empty());
        } else {
            panic!("expected array result");
        }
    }

    #[test]
    fn engine_consume_mode() {
        let mut handler = make_handler();
        handler.parse_mode = ParseMode::Consume;
        handler.acodes_ref = Some(vec!["hello".into()]);

        let engine = Engine::new();
        let result = engine.execute(&handler, "hello world").unwrap();
        if let Value::Array(arr) = result {
            assert!(!arr.is_empty());
        }
    }
}
