//! Helper modules for the LinkedSpec runtime.
//!
//! The `regex_engine` module provides the core regex dispatch mechanism:
//! - `CompiledAlternation`: compile multiple regex patterns into a combined alternation
//! - `seek_match`: find the earliest match among alternatives from current position
//! - `consume_match`: require a match at exactly the current position (\G-anchored)
//!
//! ## Design
//!
//! Patterns are combined into a single top-level alternation `(pat1)|(pat2)|(pat3)`
//! and rgx's `MatchResult.matched_branch_number` identifies which branch matched.
//! This mirrors Perl's `LinkedRE::oredRE` which builds a single combined regex with
//! `(?{$pos=N})` embedded-code position tracking, but uses rgx's native branch
//! tracking — no embedded code needed, portable across all rgx backends.
//!
//! ### Named captures
//!
//! When a regex pattern contains named capture groups like `(?P<name>...)`, they
//! are extracted into `MatchResult.named`. Unnamed groups are not included in
//! the named map. Named capture indices align with the positional group list.
//!
//! ### Group numbering
//!
//! In the combined regex, capture groups are numbered sequentially across all
//! branches. For example, `(\d+)|(\w+)|(\S+)` produces:
//! - Group 0: full match (always)
//! - Group 1: branch 0's capture
//! - Group 2: branch 1's capture
//! - Group 3: branch 2's capture
//! `AltInfo.group_offset` stores the starting group index for each branch (1-based,
//! excluding group 0), so only the winning branch's groups are extracted.

pub mod regex_engine {
    use rgx_core::Regex;
    use std::collections::HashMap;

    /// Per-alternative metadata for capture group extraction from the combined regex.
    struct AltInfo {
        /// Position of this alternative (0-based index matching LinkedRE semantics).
        _index: usize,
        /// Number of capture groups in this alternative's pattern (excluding group 0).
        group_count: usize,
        /// 1-based group index where this alternative's captures begin in the combined regex.
        /// (Group 0 = full match; first alt starts at 1.)
        group_offset: usize,
        /// Named capture group names for this alternative (aligned with local group indices).
        capture_names: Vec<Option<String>>,
    }

    /// A compiled alternation of multiple regex patterns.
    ///
    /// All patterns are combined into a single top-level alternation
    /// `(pat1)|(pat2)|(pat3)`. rgx's `matched_branch_number` identifies
    /// which branch matched — the portable equivalent of Perl's
    /// `(?{$pos=N})` embedded-code position tracking.
    pub struct CompiledAlternation {
        /// Combined regex: `(pat1)|(pat2)|...` — None if no patterns.
        combined_regex: Option<Regex>,
        /// Per-alternative group metadata for capture extraction.
        alt_infos: Vec<AltInfo>,
    }

    impl CompiledAlternation {
        /// Compile a set of regex patterns into a combined alternation.
        ///
        /// Each pattern is assigned its position index (0-based), matching
        /// Perl's `LinkedRE::oredRE` index semantics. Patterns are joined
        /// as `pat1|pat2|pat3` — rgx detects the top-level alternation
        /// and populates `MatchResult.matched_branch_number`.
        ///
        /// Returns an error if any pattern fails to compile or if the
        /// combined regex fails to compile.
        pub fn compile(patterns: &[String]) -> Result<Self, String> {
            if patterns.is_empty() {
                return Ok(Self {
                    combined_regex: None,
                    alt_infos: Vec::new(),
                });
            }

            // First pass: compile each pattern individually to count capture groups
            // and collect named capture names.
            let mut alt_infos: Vec<AltInfo> = Vec::with_capacity(patterns.len());
            let mut group_offset: usize = 1; // start after group 0 (full match)

            for (i, pat) in patterns.iter().enumerate() {
                let re = Regex::compile(pat)
                    .map_err(|e| format!("regex compile error for '/{}/': {}", pat, e))?;
                let capture_names: Vec<Option<String>> = re
                    .capture_names()
                    .map(|opt| opt.map(|s| s.to_string()))
                    .collect();
                // capture_names includes group 0 (always None), so group_count = len - 1
                let group_count = capture_names.len().saturating_sub(1);
                alt_infos.push(AltInfo {
                    _index: i,
                    group_count,
                    group_offset,
                    capture_names,
                });
                group_offset += group_count;
            }

            // Build the combined regex: pat1|pat2|pat3
            let combined_pattern = patterns.join("|");
            let combined_regex = Regex::compile(&combined_pattern)
                .map_err(|e| format!("regex compile error for combined alternation: {}", e))?;

            Ok(Self {
                combined_regex: Some(combined_regex),
                alt_infos,
            })
        }

        /// True if no patterns were compiled.
        pub fn is_empty(&self) -> bool {
            self.combined_regex.is_none()
        }

        /// Match in **seek mode** — find the earliest match among all alternatives
        /// starting from `pos`.
        ///
        /// Uses rgx's `matched_branch_number` to identify which alternative matched.
        /// rgx handles "earliest match across alternatives" internally.
        ///
        /// Returns `None` if no alternative matches anywhere in the input after `pos`.
        pub fn seek_match(&self, input: &str, pos: usize) -> Option<MatchResult> {
            let combined = self.combined_regex.as_ref()?;
            let remaining = &input[pos..];
            let m = combined.find_first(remaining)?;

            // matched_branch_number is 1-based; convert to 0-based index.
            // If absent (shouldn't happen with top-level alternation), default to 0.
            let branch = m.matched_branch_number.unwrap_or(1);
            let alt_idx = branch.saturating_sub(1);

            let info = self.alt_infos.get(alt_idx)?;
            let groups = extract_groups(combined, remaining, info);
            let named = extract_named(combined, remaining, info);

            Some(MatchResult {
                index: alt_idx,
                start: pos + m.start,
                end: pos + m.end,
                groups,
                named,
            })
        }

        /// Match in **consume mode** — must match at exactly `pos` (\G-anchored).
        ///
        /// Uses `find_first_at(remaining, 0)` to require the match starts at byte 0
        /// of the remaining input slice. rgx's `matched_branch_number` identifies
        /// which alternative matched.
        ///
        /// Returns `None` if no alternative matches at exactly `pos`.
        pub fn consume_match(&self, input: &str, pos: usize) -> Option<MatchResult> {
            let combined = self.combined_regex.as_ref()?;
            let remaining = &input[pos..];
            let m = combined.find_first_at(remaining, 0)?;

            // Verify the match truly starts at the beginning.
            if m.start != 0 {
                return None;
            }

            let branch = m.matched_branch_number.unwrap_or(1);
            let alt_idx = branch.saturating_sub(1);

            let info = self.alt_infos.get(alt_idx)?;
            let groups = extract_groups(combined, remaining, info);
            let named = extract_named(combined, remaining, info);

            Some(MatchResult {
                index: alt_idx,
                start: pos,
                end: pos + m.end,
                groups,
                named,
            })
        }
    }

    /// Extract positional capture groups belonging to the winning alternative.
    ///
    /// Index 0 is always the full match. Subsequent indices are the winning
    /// branch's capture groups (re-indexed from 0 within the result).
    fn extract_groups(regex: &Regex, haystack: &str, info: &AltInfo) -> Vec<String> {
        let mut groups = Vec::with_capacity(1 + info.group_count);
        if let Some(caps) = regex.captures(haystack) {
            // Group 0: full match
            groups.push(
                caps.get(0)
                    .map(|m| m.as_str().to_string())
                    .unwrap_or_default(),
            );
            // Winning branch's groups (offset by info.group_offset)
            for local_idx in 0..info.group_count {
                let global_idx = info.group_offset + local_idx;
                groups.push(
                    caps.get(global_idx)
                        .map(|m| m.as_str().to_string())
                        .unwrap_or_default(),
                );
            }
        }
        groups
    }

    /// Extract named capture groups belonging to the winning alternative.
    fn extract_named(
        regex: &Regex,
        haystack: &str,
        info: &AltInfo,
    ) -> HashMap<String, String> {
        let mut named = HashMap::new();
        if let Some(caps) = regex.captures(haystack) {
            // capture_names includes group 0 at index 0 (always None).
            // Skip group 0: start iterating at index 1.
            // Global group index = group_offset + (capture_names_index - 1).
            for (cap_idx, name_opt) in info.capture_names.iter().enumerate().skip(1) {
                if let Some(name) = name_opt {
                    let global_idx = info.group_offset + (cap_idx - 1);
                    if let Some(m) = caps.get(global_idx) {
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

    #[cfg(test)]
    mod tests {
        use super::*;

        #[test]
        fn seek_finds_earliest_match() {
            // dog won't match; caterpillar matches at position 2 → branch 1
            let alt = CompiledAlternation::compile(&[
                "dog".into(),
                "caterpillar".into(),
            ]).unwrap();
            let result = alt.seek_match("a caterpillar", 0).unwrap();
            assert_eq!(result.index, 1);
            assert_eq!(result.start, 2);
            assert_eq!(result.end, 13);
        }

        #[test]
        fn seek_tie_goes_to_lowest_index() {
            // rgx's top-level alternation: first matching branch wins on ties
            let alt = CompiledAlternation::compile(&[
                "cat".into(),
                "cat".into(),
            ]).unwrap();
            let result = alt.seek_match("the cat sat", 0).unwrap();
            assert_eq!(result.index, 0);
        }

        #[test]
        fn seek_on_empty_input() {
            let alt = CompiledAlternation::compile(&["cat".into()]).unwrap();
            assert!(alt.seek_match("", 0).is_none());
        }

        #[test]
        fn seek_on_no_match_returns_none() {
            let alt = CompiledAlternation::compile(&["cat".into()]).unwrap();
            assert!(alt.seek_match("dog bird fish", 0).is_none());
        }

        #[test]
        fn seek_on_empty_alternatives() {
            let alt = CompiledAlternation::compile(&[]).unwrap();
            assert!(alt.is_empty());
            assert!(alt.seek_match("anything", 0).is_none());
        }

        #[test]
        fn seek_respects_start_position() {
            let alt = CompiledAlternation::compile(&["cat".into()]).unwrap();
            let result = alt.seek_match("cat cat", 4).unwrap();
            assert_eq!(result.start, 4);
        }

        #[test]
        fn seek_prefers_earliest_position_across_alternatives() {
            let alt = CompiledAlternation::compile(&[
                "dog".into(),
                "cat".into(),
            ]).unwrap();
            let result = alt.seek_match("cat and dog", 0).unwrap();
            assert_eq!(result.index, 1);
            assert_eq!(result.start, 0);
        }

        #[test]
        fn consume_on_empty_alternatives() {
            let alt = CompiledAlternation::compile(&[]).unwrap();
            assert!(alt.consume_match("anything", 0).is_none());
        }

        #[test]
        fn consume_requires_position_match() {
            let alt = CompiledAlternation::compile(&["cat".into()]).unwrap();
            let result = alt.consume_match("cat", 0).unwrap();
            assert_eq!(result.start, 0);
            assert_eq!(result.end, 3);
        }

        #[test]
        fn consume_respects_second_alternative() {
            let alt = CompiledAlternation::compile(&[
                "dog".into(),
                "cat".into(),
            ]).unwrap();
            let result = alt.consume_match("cat", 0).unwrap();
            assert_eq!(result.index, 1);
        }

        #[test]
        fn consume_first_alternative_wins() {
            let alt = CompiledAlternation::compile(&[
                "cat".into(),
                "cat".into(),
            ]).unwrap();
            let result = alt.consume_match("cat", 0).unwrap();
            assert_eq!(result.index, 0);
        }

        #[test]
        fn capture_groups_positional() {
            let alt = CompiledAlternation::compile(&[r"(\d+)-(\w+)".into()]).unwrap();
            let result = alt.seek_match("abc-42-hello-99", 4).unwrap();
            assert_eq!(result.groups.len(), 3);
            assert_eq!(result.groups[0], "42-hello");
            assert_eq!(result.groups[1], "42");
            assert_eq!(result.groups[2], "hello");
        }

        #[test]
        fn capture_groups_multiple() {
            let alt = CompiledAlternation::compile(&[
                r"(\d+)".into(),
                r"(\w+)".into(),
            ]).unwrap();
            let result = alt.seek_match("hello", 0).unwrap();
            assert_eq!(result.index, 1);
            assert_eq!(result.groups[0], "hello");
            assert_eq!(result.groups[1], "hello");
        }

        #[test]
        fn capture_groups_optional_not_matched() {
            let alt = CompiledAlternation::compile(&[r"(\d+)?[a-z]+".into()]).unwrap();
            let result = alt.seek_match("abc", 0).unwrap();
            assert_eq!(result.groups.len(), 2);
            assert_eq!(result.groups[0], "abc");
            assert_eq!(result.groups[1], "");
        }

        #[test]
        fn named_captures_extracted() {
            let alt = CompiledAlternation::compile(&[r"(?P<year>\d{4})-(?P<month>\d{2})".into()]).unwrap();
            let result = alt.seek_match("date: 2024-03-15", 6).unwrap();
            assert_eq!(result.named.get("year").unwrap(), "2024");
            assert_eq!(result.named.get("month").unwrap(), "03");
        }

        #[test]
        fn named_captures_multiple() {
            let alt = CompiledAlternation::compile(&[r"(?P<first>\w+)\s+(?P<second>\w+)".into()]).unwrap();
            let result = alt.seek_match("hello world", 0).unwrap();
            assert_eq!(result.named.get("first").unwrap(), "hello");
            assert_eq!(result.named.get("second").unwrap(), "world");
        }

        #[test]
        fn named_captures_mixed_with_positional() {
            let alt = CompiledAlternation::compile(&[r"(?P<name>\w+)\s+(\d+)".into()]).unwrap();
            let result = alt.seek_match("alice 42", 0).unwrap();
            assert_eq!(result.named.get("name").unwrap(), "alice");
            assert_eq!(result.groups.len(), 3);
            assert_eq!(result.groups[2], "42");
        }

        #[test]
        fn named_captures_in_consume_mode() {
            let alt = CompiledAlternation::compile(&[r"(?P<word>\w+)".into()]).unwrap();
            let result = alt.consume_match("hello world", 0).unwrap();
            assert_eq!(result.named.get("word").unwrap(), "hello");
        }

        #[test]
        fn named_captures_with_no_named_groups() {
            let alt = CompiledAlternation::compile(&[r"(\d+)".into()]).unwrap();
            let result = alt.seek_match("abc 123", 4).unwrap();
            assert!(result.named.is_empty());
        }

        #[test]
        fn named_capture_absent_returns_none() {
            let alt = CompiledAlternation::compile(&[r"(?P<num>\d+)".into()]).unwrap();
            let result = alt.seek_match("abc 123", 4).unwrap();
            assert_eq!(result.named_capture("num"), Some("123"));
            assert_eq!(result.named_capture("nope"), None);
        }

        #[test]
        fn named_capture_optional_not_matched() {
            let alt = CompiledAlternation::compile(&[r"(?P<num>\d+)?[a-z]+".into()]).unwrap();
            let result = alt.seek_match("abc", 0).unwrap();
            assert_eq!(result.named.get("num"), None);
        }

        #[test]
        fn matched_text_returns_full_match() {
            let alt = CompiledAlternation::compile(&["hello".into()]).unwrap();
            let result = alt.seek_match("hello world", 0).unwrap();
            assert_eq!(result.matched_text(), "hello");
        }

        #[test]
        fn multiple_patterns_with_different_capture_layouts() {
            // Combined regex: (?P<num>\d+)|(?P<word>\w+)|(?P<both>\w+\d+)
            // On "abc123": branch 0 (\d+) fails at pos 0. Branch 1 (\w+) matches
            // "abc123" at pos 0. rgx's ordered alternation picks branch 1.
            // Branch 2 (\w+\d+) would also match but branch 1 wins (leftmost-first).
            let alt = CompiledAlternation::compile(&[
                r"(?P<num>\d+)".into(),
                r"(?P<word>\w+)".into(),
                r"(?P<both>\w+\d+)".into(),
            ]).unwrap();
            let result = alt.seek_match("abc123", 0).unwrap();
            assert_eq!(result.index, 1);
            assert_eq!(result.named.get("word").unwrap(), "abc123");
            assert_eq!(result.named.get("num"), None);
            assert_eq!(result.named.get("both"), None);
        }

        #[test]
        fn two_patterns_first_has_four_positional_groups() {
            // Simulates rule_paragraph scenario: pat1 has 4 groups, pat2 has 0
            let alt = CompiledAlternation::compile(&[
                r"(\w+)[ \t]*(::|:)[ \t]*(\S*)[ \t]*(.*)".into(),
                r"(?<!\\)/(?:\\.|[^/\\])*?(?<!\\)/".into(),
            ]).unwrap();
            // "DemoParser::" should match pat1 (branch 0) with 4 groups
            let result = alt.seek_match("DemoParser::\n /pattern/ -> Child", 0).unwrap();
            eprintln!("TEST groups={:?} index={}", result.groups, result.index);
            assert_eq!(result.index, 0, "should match first pattern");
            assert_eq!(result.groups.len(), 5, "full match + 4 groups");
            assert_eq!(result.groups[0], "DemoParser::");
            assert_eq!(result.groups[1], "DemoParser");
            assert_eq!(result.groups[2], "::");
        }
    }
}
