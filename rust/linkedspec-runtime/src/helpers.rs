//! Helper modules for the LinkedSpec runtime.
//!
//! The `regex_engine` module provides the core regex dispatch mechanism:
//! - `CompiledAlternation`: compile multiple regex patterns into a position-tracked alternation
//! - `seek_match`: find the earliest match among alternatives from current position
//! - `consume_match`: require a match at exactly the current position (\G-anchored)
//!
//! ## Design
//!
//! Unlike Perl's `LinkedRE::oredRE` which builds a single combined regex with
//! `(?{$pos=N})` embedded-code position tracking, the Rust engine iterates over
//! alternatives and selects the earliest match. This is functionally equivalent
//! and avoids the portability issues of Perl's `(?{...})` regex code blocks.
//!
//! ### Named captures
//!
//! When a regex pattern contains named capture groups like `(?P<name>...)`, they
//! are extracted into `MatchResult.named`. Unnamed groups are not included in
//! the named map. Named capture indices align with the positional group list.

pub mod regex_engine {
    use rgx_core::Regex;
    use std::collections::HashMap;

    /// A compiled regex alternative — one pattern with its index.
    struct CompiledAlt {
        index: usize,
        regex: Regex,
        /// Named capture group names, indexed by capture group position.
        capture_names: Vec<Option<String>>,
    }

    /// A compiled alternation of multiple regex patterns.
    ///
    /// Patterns are compiled individually and matched in iteration order.
    /// For seek mode, the earliest match across all alternatives wins.
    /// For consume mode, the first alternative matching at exactly `pos` wins.
    pub struct CompiledAlternation {
        alternatives: Vec<CompiledAlt>,
    }

    impl CompiledAlternation {
        /// Compile a set of regex patterns into a combined alternation.
        ///
        /// Each pattern is assigned its position index (0-based), matching
        /// Perl's `LinkedRE::oredRE` index semantics. Returns an error if any
        /// pattern fails to compile.
        pub fn compile(patterns: &[String]) -> Result<Self, String> {
            let alternatives: Result<Vec<_>, _> = patterns
                .iter()
                .enumerate()
                .map(|(i, pat)| {
                    Regex::compile(pat)
                        .map(|re| {
                            // Collect named capture group names.
                            // capture_names() returns one entry per capture slot
                            // (index 0 = full match, then each group in order).
                            let capture_names: Vec<Option<String>> = re
                                .capture_names()
                                .map(|opt| opt.map(|s| s.to_string()))
                                .collect();
                            CompiledAlt {
                                index: i,
                                regex: re,
                                capture_names,
                            }
                        })
                        .map_err(|e| format!("rgx compile error for '/{}/': {}", pat, e))
                })
                .collect();
            Ok(Self {
                alternatives: alternatives?,
            })
        }

        /// True if no patterns were compiled.
        pub fn is_empty(&self) -> bool {
            self.alternatives.is_empty()
        }

        /// Match in **seek mode** — find the earliest match among all alternatives
        /// starting from `pos`.
        ///
        /// If multiple alternatives match at the same start position, the one
        /// with the lowest index (earliest in the pattern list) wins.
        ///
        /// Returns `None` if no alternative matches anywhere in the input after `pos`.
        pub fn seek_match(&self, input: &str, pos: usize) -> Option<MatchResult> {
            let remaining = &input[pos..];
            let mut best: Option<MatchResult> = None;

            for alt in &self.alternatives {
                if let Some(m) = alt.regex.find_first(remaining) {
                    let abs_start = pos + m.start;
                    let abs_end = pos + m.end;

                    // Keep the earliest match; on ties, lowest index (iteration order) wins.
                    let is_better = match &best {
                        None => true,
                        Some(b) => abs_start < b.start,
                    };

                    if is_better {
                        let groups = extract_groups(&alt.regex, remaining);
                        let named = extract_named(&alt.regex, &alt.capture_names, remaining);
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

        /// Match in **consume mode** — must match at exactly `pos` (\G-anchored).
        ///
        /// Uses `find_at(remaining, 0)` to require the match starts at byte 0
        /// of the remaining input slice. Returns the first alternative that matches.
        ///
        /// Returns `None` if no alternative matches at exactly `pos`.
        pub fn consume_match(&self, input: &str, pos: usize) -> Option<MatchResult> {
            let remaining = &input[pos..];
            for alt in &self.alternatives {
                if let Some(m) = alt.regex.find_first_at(remaining, 0) {
                    // find_first_at with offset 0 may return matches starting at
                    // position >0 if the regex uses optional prefixes. Verify
                    // the match truly starts at the beginning.
                    if m.start == 0 {
                        let groups = extract_groups(&alt.regex, remaining);
                        let named = extract_named(&alt.regex, &alt.capture_names, remaining);
                        return Some(MatchResult {
                            index: alt.index,
                            start: pos,
                            end: pos + m.end,
                            groups,
                            named,
                        });
                    }
                }
            }
            None
        }
    }

    /// Extract positional capture groups from a regex match.
    ///
    /// Index 0 is always the full match. Returns empty `Vec` if captures fail
    /// (should not happen since `find`/`find_at` already confirmed a match).
    fn extract_groups(regex: &Regex, haystack: &str) -> Vec<String> {
        regex
            .captures(haystack)
            .map(|caps| {
                caps.iter()
                    .map(|c| c.map(|m| m.as_str().to_string()).unwrap_or_default())
                    .collect()
            })
            .unwrap_or_default()
    }

    /// Extract named capture groups from a regex match.
    ///
    /// Uses the pre-computed `capture_names` list (from `Regex::capture_names()`)
    /// to map named group values. Groups with `None` name (unnamed positional
    /// groups) are skipped.
    fn extract_named(
        regex: &Regex,
        capture_names: &[Option<String>],
        haystack: &str,
    ) -> HashMap<String, String> {
        let mut named = HashMap::new();
        if let Some(caps) = regex.captures(haystack) {
            for (i, name_opt) in capture_names.iter().enumerate() {
                if let Some(name) = name_opt {
                    if let Some(m) = caps.get(i) {
                        named.insert(name.clone(), m.as_str().to_string());
                    }
                }
            }
        }
        named
    }

    /// The result of a successful regex match.
    #[derive(Debug, Clone)]
    pub struct MatchResult {
        /// Which alternative matched (0-based index into the patterns array).
        pub index: usize,
        /// Absolute start position in the full input (byte offset).
        pub start: usize,
        /// Absolute end position in the full input (byte offset).
        pub end: usize,
        /// Capture groups (index 0 = full match, then each parenthesized group).
        pub groups: Vec<String>,
        /// Named capture groups (e.g. `(?P<name>...)` → `"name" => "value"`).
        pub named: HashMap<String, String>,
    }

    impl MatchResult {
        /// The full matched text.
        pub fn matched_text(&self) -> &str {
            self.groups.first().map(|s| s.as_str()).unwrap_or("")
        }

        /// Get a named capture value by name.
        pub fn named_capture(&self, name: &str) -> Option<&str> {
            self.named.get(name).map(|s| s.as_str())
        }
    }

    // ── Tests ──

    #[cfg(test)]
    mod tests {
        use super::*;

        // ── Seek mode tests ──

        #[test]
        fn seek_finds_earliest_match() {
            let alt =
                CompiledAlternation::compile(&["hello".into(), "world".into()]).unwrap();
            let m = alt.seek_match("say hello world", 0).unwrap();
            assert_eq!(m.index, 0); // "hello" matches, index 0
            assert_eq!(m.start, 4);
            assert_eq!(m.end, 9);
            assert_eq!(m.matched_text(), "hello");
        }

        #[test]
        fn seek_prefers_earliest_position_across_alternatives() {
            // "world" (index 1) appears earlier than "hello" (index 0)
            let alt =
                CompiledAlternation::compile(&["hello".into(), "world".into()]).unwrap();
            let m = alt.seek_match("a world then hello", 0).unwrap();
            assert_eq!(m.index, 1, "world should win because it's earlier");
            assert_eq!(m.matched_text(), "world");
        }

        #[test]
        fn seek_tie_goes_to_lowest_index() {
            // Both match at the same position — first in list (index 0) wins
            let alt = CompiledAlternation::compile(&[
                r"\w+".into(), // matches "hello"
                r"hello".into(), // also matches "hello" at same position
            ])
            .unwrap();
            let m = alt.seek_match("hello world", 0).unwrap();
            assert_eq!(m.index, 0, "tie should go to lowest index");
            assert_eq!(m.matched_text(), "hello");
        }

        #[test]
        fn seek_respects_start_position() {
            let alt = CompiledAlternation::compile(&["hello".into()]).unwrap();
            // "hello" at position 4, but we start at position 6 — should not find it
            assert!(alt.seek_match("say hello world", 6).is_none());
            // Starting at 4 should find it
            assert!(alt.seek_match("say hello world", 4).is_some());
        }

        #[test]
        fn seek_on_no_match_returns_none() {
            let alt = CompiledAlternation::compile(&["foo".into()]).unwrap();
            assert!(alt.seek_match("no match here", 0).is_none());
        }

        #[test]
        fn seek_on_empty_input() {
            let alt = CompiledAlternation::compile(&["foo".into()]).unwrap();
            assert!(alt.seek_match("", 0).is_none());
        }

        #[test]
        fn seek_on_empty_alternatives() {
            let alt = CompiledAlternation::compile(&[]).unwrap();
            assert!(alt.is_empty());
            assert!(alt.seek_match("anything", 0).is_none());
        }

        // ── Consume mode tests ──

        #[test]
        fn consume_requires_position_match() {
            let alt =
                CompiledAlternation::compile(&["hello".into(), "world".into()]).unwrap();
            // "hello" starts at position 4
            assert!(alt.consume_match("say hello world", 4).is_some());
            // Nothing starts at position 3
            assert!(alt.consume_match("say hello world", 3).is_none());
        }

        #[test]
        fn consume_first_alternative_wins() {
            let alt = CompiledAlternation::compile(&[
                r"\w+".into(),  // matches any word
                r"hello".into(), // also matches "hello"
            ])
            .unwrap();
            let m = alt.consume_match("hello world", 0).unwrap();
            // First alternative (\w+) matches at position 0
            assert_eq!(m.index, 0);
            assert_eq!(m.matched_text(), "hello");
        }

        #[test]
        fn consume_respects_second_alternative() {
            let alt =
                CompiledAlternation::compile(&["goodbye".into(), "hello".into()]).unwrap();
            let m = alt.consume_match("hello world", 0).unwrap();
            // "goodbye" doesn't match, "hello" does
            assert_eq!(m.index, 1);
            assert_eq!(m.matched_text(), "hello");
        }

        #[test]
        fn consume_on_empty_alternatives() {
            let alt = CompiledAlternation::compile(&[]).unwrap();
            assert!(alt.is_empty());
            assert!(alt.consume_match("anything", 0).is_none());
        }

        // ── Capture group tests ──

        #[test]
        fn capture_groups_positional() {
            let alt =
                CompiledAlternation::compile(&[r"hello[ \t]+(\w+)".into()]).unwrap();
            let m = alt.seek_match("say hello world", 0).unwrap();
            assert_eq!(m.index, 0);
            assert!(m.groups.len() >= 2, "expected at least 2 groups, got {}", m.groups.len());
            assert_eq!(m.groups[0], "hello world"); // full match
            assert_eq!(m.groups[1], "world"); // first capture group
        }

        #[test]
        fn capture_groups_multiple() {
            let alt = CompiledAlternation::compile(&[r"(\w+)[ \t]+(\w+)".into()]).unwrap();
            let m = alt.seek_match("hello world", 0).unwrap();
            assert_eq!(m.groups.len(), 3); // full + 2 groups
            assert_eq!(m.groups[0], "hello world");
            assert_eq!(m.groups[1], "hello");
            assert_eq!(m.groups[2], "world");
        }

        #[test]
        fn capture_groups_optional_not_matched() {
            // Optional group that doesn't match should be empty string
            let alt = CompiledAlternation::compile(&[r"hello(?:[ \t]+(\w+))?".into()]).unwrap();
            let m = alt.seek_match("hello", 0).unwrap();
            assert_eq!(m.groups.len(), 2); // full + 1 optional
            assert_eq!(m.groups[0], "hello");
            assert_eq!(m.groups[1], ""); // optional group not matched → empty
        }

        // ── Named capture group tests ──

        #[test]
        fn named_captures_extracted() {
            let alt = CompiledAlternation::compile(&[
                r"hello[ \t]+(?P<name>\w+)".into(),
            ])
            .unwrap();
            let m = alt.seek_match("say hello world", 0).unwrap();
            assert_eq!(m.named.len(), 1);
            assert_eq!(m.named.get("name").unwrap(), "world");
            assert_eq!(m.named_capture("name"), Some("world"));
        }

        #[test]
        fn named_captures_multiple() {
            let alt = CompiledAlternation::compile(&[
                r"(?P<first>\w+)[ \t]+(?P<second>\w+)".into(),
            ])
            .unwrap();
            let m = alt.seek_match("hello world", 0).unwrap();
            assert_eq!(m.named.len(), 2);
            assert_eq!(m.named.get("first").unwrap(), "hello");
            assert_eq!(m.named.get("second").unwrap(), "world");
        }

        #[test]
        fn named_captures_mixed_with_positional() {
            // Named group nested inside positional groups
            let alt = CompiledAlternation::compile(&[
                r"((?P<word>\w+))[ \t]+(\w+)".into(),
            ])
            .unwrap();
            let m = alt.seek_match("hello world", 0).unwrap();
            assert!(m.groups.len() >= 3); // full + outer + named + last
            assert_eq!(m.named.get("word").unwrap(), "hello");
        }

        #[test]
        fn named_captures_in_consume_mode() {
            let alt = CompiledAlternation::compile(&[
                r"(?P<greeting>hello)[ \t]+(?P<target>\w+)".into(),
            ])
            .unwrap();
            let m = alt.consume_match("hello world", 0).unwrap();
            assert_eq!(m.named.get("greeting").unwrap(), "hello");
            assert_eq!(m.named.get("target").unwrap(), "world");
        }

        #[test]
        fn named_capture_optional_not_matched() {
            let alt = CompiledAlternation::compile(&[
                r"hello(?P<suffix>[ \t]+\w+)?".into(),
            ])
            .unwrap();
            let m = alt.seek_match("hello", 0).unwrap();
            assert!(m.named.is_empty(), "optional named group not matched → not in named map");
        }

        #[test]
        fn named_captures_with_no_named_groups() {
            // Patterns without named groups produce empty named map
            let alt =
                CompiledAlternation::compile(&[r"hello[ \t]+(\w+)".into()]).unwrap();
            let m = alt.seek_match("hello world", 0).unwrap();
            assert!(m.named.is_empty());
        }

        // ── MatchResult API tests ──

        #[test]
        fn matched_text_returns_full_match() {
            let alt =
                CompiledAlternation::compile(&[r"hello[ \t]+(\w+)".into()]).unwrap();
            let m = alt.seek_match("hello world", 0).unwrap();
            assert_eq!(m.matched_text(), "hello world");
        }

        #[test]
        fn named_capture_absent_returns_none() {
            let alt =
                CompiledAlternation::compile(&[r"hello".into()]).unwrap();
            let m = alt.seek_match("hello", 0).unwrap();
            assert_eq!(m.named_capture("nonexistent"), None);
        }

        // ── Multiple pattern tests ──

        #[test]
        fn multiple_patterns_with_different_capture_layouts() {
            // Three patterns with different capture layouts.
            // Pattern 0: `(?P<word>\w+)` — named group
            // Pattern 1: `hello[ \t]+(\w+)` — positional only, requires "hello "
            // Pattern 2: `(?P<greeting>\w+)[ \t]+(?P<target>\w+)` — two named
            let alt = CompiledAlternation::compile(&[
                r"(?P<word>\w+)".into(),
                r"hello[ \t]+(\w+)".into(),
                r"(?P<greeting>\w+)[ \t]+(?P<target>\w+)".into(),
            ])
            .unwrap();

            // At position 0 on "hello world":
            // Pattern 0 matches "hello" at position 0
            // Pattern 1 matches "hello world" at position 0 (but position same, index higher)
            // Pattern 2 matches "hello world" at position 0 (same)
            // → Pattern 0 wins (lowest index at earliest position)
            let m = alt.seek_match("hello world", 0).unwrap();
            assert_eq!(m.index, 0);
            assert_eq!(m.named.get("word").unwrap(), "hello");

            // On "good morning world" at position 0:
            // Pattern 0 matches "good" at position 0
            // Pattern 1 does NOT match (no "hello ")
            // Pattern 2 matches "good morning" at position 0
            // → Pattern 0 wins (lowest index, same position)
            let m = alt.seek_match("good morning world", 0).unwrap();
            assert_eq!(m.index, 0);
            assert_eq!(m.named.get("word").unwrap(), "good");
        }
    }
}
