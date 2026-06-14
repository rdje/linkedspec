//! Helper function implementations for the LinkedSpec runtime.
//!
//! Reference: `docs/linkedspec-book/src/appendix/helper-contract-catalog.md`
//!
//! These helpers operate on RuntimeContext and provide the building blocks
//! that .spec lifecycle code uses.

use crate::runtime::{RuntimeContext, RuntimeValue};

/// Regex engine for position-tracked matching.
pub mod regex_engine {
    use regex::Regex;

    /// A compiled regex alternative — one pattern with its index.
    pub struct CompiledAlt {
        pub index: usize,
        pub regex: Regex,
    }

    /// A compiled alternation of multiple regexes.
    pub struct CompiledAlternation {
        alternatives: Vec<CompiledAlt>,
    }

    impl CompiledAlternation {
        /// Compile a set of regex patterns into a combined alternation.
        /// Each pattern is assigned its position index (0-based).
        pub fn compile(patterns: &[String]) -> Result<Self, String> {
            let alternatives: Result<Vec<_>, _> = patterns
                .iter()
                .enumerate()
                .map(|(i, pat)| {
                    Regex::new(pat)
                        .map(|re| CompiledAlt { index: i, regex: re })
                        .map_err(|e| format!("regex compile error for '{}': {}", pat, e))
                })
                .collect();
            Ok(Self {
                alternatives: alternatives?,
            })
        }

        /// Match in seek mode — match anywhere from the current position.
        /// Returns `(matched_index, match_start, match_end)` or `None` if no match.
        pub fn seek_match(&self, input: &str, pos: usize) -> Option<MatchResult> {
            let remaining = &input[pos..];
            let mut best: Option<MatchResult> = None;

            for alt in &self.alternatives {
                if let Some(m) = alt.regex.find(remaining) {
                    let abs_start = pos + m.start();
                    let abs_end = pos + m.end();
                    // Take the earliest match; if tied, take the first index
                    if best.as_ref().is_none_or(|b: &MatchResult| abs_start < b.start) {
                        let groups: Vec<String> = alt
                            .regex
                            .captures(remaining)
                            .map(|caps| {
                                caps.iter()
                                    .map(|c| c.map(|m| m.as_str().to_string()).unwrap_or_default())
                                    .collect()
                            })
                            .unwrap_or_default();
                        let named: std::collections::HashMap<String, String> =
                            std::collections::HashMap::new(); // named groups from regex
                        best = Some(MatchResult {
                            index: alt.index,
                            start: abs_start,
                            end: abs_end,
                            groups,
                            named,
                        });
                    }
                }
            }
            best
        }

        /// Match in consume mode — must match at exactly the current position (\G-anchored).
        pub fn consume_match(&self, input: &str, pos: usize) -> Option<MatchResult> {
            let remaining = &input[pos..];
            for alt in &self.alternatives {
                if let Some(m) = alt.regex.find_at(remaining, 0) {
                    // find_at starts at byte 0 of the slice, so it's position-anchored
                    if m.start() == 0 {
                        let groups: Vec<String> = alt
                            .regex
                            .captures(remaining)
                            .map(|caps| {
                                caps.iter()
                                    .map(|c| c.map(|m| m.as_str().to_string()).unwrap_or_default())
                                    .collect()
                            })
                            .unwrap_or_default();
                        let named: std::collections::HashMap<String, String> =
                            std::collections::HashMap::new();
                        return Some(MatchResult {
                            index: alt.index,
                            start: pos,
                            end: pos + m.end(),
                            groups,
                            named,
                        });
                    }
                }
            }
            None
        }
    }

    /// The result of a successful regex match.
    pub struct MatchResult {
        /// Which alternative matched (0-based index).
        pub index: usize,
        /// Absolute start position in the full input.
        pub start: usize,
        /// Absolute end position in the full input.
        pub end: usize,
        /// Capture groups (index 0 = full match).
        pub groups: Vec<String>,
        /// Named capture groups (not yet supported by regex crate for dynamic names).
        pub named: std::collections::HashMap<String, String>,
    }

    impl MatchResult {
        /// The matched text.
        pub fn matched_text(&self) -> &str {
            self.groups.first().map(|s| s.as_str()).unwrap_or("")
        }
    }
}

// ── Declaration helpers ──

/// `declare(scalar, name)` — declare a scalar variable.
pub fn declare_scalar(ctx: &mut RuntimeContext, name: &str) {
    ctx.declare_scalar(name);
}

/// `declare(scalar, name=value)` — declare a scalar with initial value.
pub fn declare_scalar_with(ctx: &mut RuntimeContext, name: &str, value: &str) {
    ctx.declare_scalar_with(name, value);
}

/// `declare(array, name)` — declare an array variable.
pub fn declare_array(ctx: &mut RuntimeContext, name: &str) {
    ctx.declare_array(name);
}

// ── Array helpers ──

/// `push_value(array, value)` — append a value to a named accumulator.
pub fn push_value(ctx: &mut RuntimeContext, arr_name: &str, value: &str) {
    ctx.push_value(arr_name, RuntimeValue::Scalar(value.to_string()));
}

/// `array_copy(array)` — shallow copy of an array.
pub fn array_copy(ctx: &RuntimeContext, name: &str) -> Vec<RuntimeValue> {
    ctx.array_copy(name)
}

/// `count(arr)` — number of elements.
pub fn count(ctx: &RuntimeContext, name: &str) -> usize {
    ctx.get_array(name).len()
}

/// `scalar(container, key)` — read a value from an array or hash.
pub fn scalar(ctx: &RuntimeContext, container: &str, key: &str) -> String {
    // Try hash first
    ctx.get_scalar(&format!("{}.{}", container, key)).to_string()
}

// ── Capture helpers ──

/// `entry_group(index)` — capture group by index.
pub fn entry_group(ctx: &RuntimeContext, index: usize) -> String {
    ctx.entry_groups.get(index).cloned().unwrap_or_default()
}

/// `entry_text()` — full text of the current match.
pub fn entry_text(ctx: &RuntimeContext) -> String {
    ctx.entry_groups.first().cloned().unwrap_or_default()
}

// ── Scalar helpers ──

/// `coalesce(values...)` — first defined non-null value.
pub fn coalesce(values: &[&str]) -> String {
    for v in values {
        if !v.is_empty() {
            return v.to_string();
        }
    }
    String::new()
}

/// `concat(values...)` — concatenate strings.
pub fn concat(values: &[&str]) -> String {
    values.iter().map(|s| *s).collect::<Vec<_>>().concat()
}

#[cfg(test)]
mod tests {
    use super::regex_engine::*;
    use super::*;

    #[test]
    fn regex_seek_finds_earliest_match() {
        let alt = CompiledAlternation::compile(&[
            r"hello".into(),
            r"world".into(),
        ])
        .unwrap();
        let result = alt.seek_match("say hello world", 0).unwrap();
        assert_eq!(result.index, 0);
        assert_eq!(result.start, 4);
        assert_eq!(result.end, 9);
        assert_eq!(result.matched_text(), "hello");
    }

    #[test]
    fn regex_consume_requires_position_match() {
        let alt = CompiledAlternation::compile(&[
            r"hello".into(),
            r"world".into(),
        ])
        .unwrap();
        // At position 4, "hello" is at the right spot
        let result = alt.consume_match("say hello world", 4).unwrap();
        assert_eq!(result.index, 0);
        assert_eq!(result.matched_text(), "hello");

        // At position 3, nothing matches at that exact spot
        assert!(alt.consume_match("say hello world", 3).is_none());
    }

    #[test]
    fn regex_no_match_returns_none() {
        let alt = CompiledAlternation::compile(&[r"foo".into()]).unwrap();
        assert!(alt.seek_match("no match here", 0).is_none());
    }
}
