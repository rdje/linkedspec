//! Helper modules for the LinkedSpec runtime.
//!
//! The `regex_engine` module provides the core regex dispatch mechanism:
//! - `CompiledAlternation`: compile multiple regex patterns into a position-tracked alternation
//! - `seek_match`: find the earliest match among alternatives from current position
//! - `consume_match`: require a match at exactly the current position (\G-anchored)

/// Regex engine for position-tracked matching.
pub mod regex_engine {
    use regex::Regex;

    /// A compiled regex alternative — one pattern with its index.
    struct CompiledAlt {
        index: usize,
        regex: Regex,
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
                        .map_err(|e| format!("regex compile error for '/{}/': {}", pat, e))
                })
                .collect();
            Ok(Self { alternatives: alternatives? })
        }

        /// Match in seek mode — find the earliest match among all alternatives
        /// starting from `pos`. If multiple alternatives match at the same start
        /// position, the first (lowest index) wins.
        pub fn seek_match(&self, input: &str, pos: usize) -> Option<MatchResult> {
            let remaining = &input[pos..];
            let mut best: Option<MatchResult> = None;

            for alt in &self.alternatives {
                if let Some(m) = alt.regex.find(remaining) {
                    let abs_start = pos + m.start();
                    let abs_end = pos + m.end();
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
                            std::collections::HashMap::new();
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

        /// Match in consume mode — must match at exactly `pos` (\G-anchored).
        /// Uses `find_at(remaining, 0)` to require the match starts at byte 0
        /// of the remaining slice.
        pub fn consume_match(&self, input: &str, pos: usize) -> Option<MatchResult> {
            let remaining = &input[pos..];
            for alt in &self.alternatives {
                if let Some(m) = alt.regex.find_at(remaining, 0) {
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
                        let named = std::collections::HashMap::new();
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
    #[derive(Debug, Clone)]
    pub struct MatchResult {
        /// Which alternative matched (0-based index into the patterns array).
        pub index: usize,
        /// Absolute start position in the full input.
        pub start: usize,
        /// Absolute end position in the full input.
        pub end: usize,
        /// Capture groups (index 0 = full match).
        pub groups: Vec<String>,
        /// Named capture groups.
        pub named: std::collections::HashMap<String, String>,
    }

    impl MatchResult {
        /// The full matched text.
        pub fn matched_text(&self) -> &str {
            self.groups.first().map(|s| s.as_str()).unwrap_or("")
        }
    }

    #[cfg(test)]
    mod tests {
        use super::*;

        #[test]
        fn seek_finds_earliest_match() {
            let alt = CompiledAlternation::compile(&["hello".into(), "world".into()]).unwrap();
            let m = alt.seek_match("say hello world", 0).unwrap();
            assert_eq!(m.index, 0); // "hello" matches first
            assert_eq!(m.start, 4);
            assert_eq!(m.end, 9);
            assert_eq!(m.matched_text(), "hello");
        }

        #[test]
        fn consume_requires_position_match() {
            let alt = CompiledAlternation::compile(&["hello".into(), "world".into()]).unwrap();
            // "hello" starts at position 4
            assert!(alt.consume_match("say hello world", 4).is_some());
            // Nothing starts at position 3
            assert!(alt.consume_match("say hello world", 3).is_none());
        }

        #[test]
        fn seek_on_no_match_returns_none() {
            let alt = CompiledAlternation::compile(&["foo".into()]).unwrap();
            assert!(alt.seek_match("no match here", 0).is_none());
        }

        #[test]
        fn capture_groups() {
            let alt = CompiledAlternation::compile(&[r"hello[ \t]+(\w+)".into()]).unwrap();
            let m = alt.seek_match("say hello world", 0).unwrap();
            assert_eq!(m.index, 0);
            assert!(m.groups.len() >= 2);
            assert_eq!(m.groups[0], "hello world");
            assert_eq!(m.groups[1], "world");
        }

        #[test]
        fn earliest_of_multiple_alternatives() {
            // "world" appears earlier in input than "hello", so index 1 should win
            let alt = CompiledAlternation::compile(&["hello".into(), "world".into()]).unwrap();
            let m = alt.seek_match("a world then hello", 0).unwrap();
            assert_eq!(m.index, 1); // "world" is earlier
            assert_eq!(m.matched_text(), "world");
        }
    }
}
