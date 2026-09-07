---
id: rust-capture-group-helper-indexing
title: Rust entry_group/match_group helpers use LinkedSpec capture indexing, not regex-library group indexing
answers:
  - "what does Rust entry_group(0) return"
  - "what does Rust match_group(0) return"
  - "does Rust entry_group(0) return the full match"
  - "does Rust match_group(0) return the full match"
  - "are Rust numbered capture helpers captures-only"
  - "are Rust capture groups compacted like Perl"
  - "are non-participating optional captures omitted in Rust"
  - "do participating empty captures stay present in Rust"
  - "what helper reads the whole regex match in Rust"
  - "was the Rust group-indexing divergence fixed"
  - "what does Rust entry_group return when the compacted index is absent"
  - "did Rust entry_group ever return an empty string for an absent capture"
date: 2026-09-07
status: confirmed
tags: [rust, capture-groups, helpers, oracle, RUST-PARITY]
evidence: "RUST-PARITY.7.2: rust/linkedspec-runtime/src/helpers.rs now stores both regex-oriented groups (index 0 full match) and LinkedSpec captures (capture-only, compacted); rust/linkedspec-runtime/src/engine.rs assigns ctx.entry_groups/ctx.match_groups from MatchResult.captures and reads whole-match text/length from spans. Tests cover capture_groups_optional_not_matched, capture_groups_empty_match_remains_participating, helpers_5_2_entry_text_and_entry_group, helpers_5_2_entry_groups_array, and the 65-fixture corpus oracle."
evidence_update_2026_07_22: "FUTURE-PARITY-BACKLOG.10.5.0.1.2.1 current-grammar five-runtime proof exposed one remaining helper-edge divergence: Rust entry_group(N) wrapped String::default when N was beyond the compacted capture list, yielding JSON empty string while match_group(N), Perl, Dart, Julia, and Lua yielded absent/null. The entry_group branch now maps present strings to Scalar and absence to RuntimeValue::Undef. helpers_5_2_absent_entry_group_is_undef locks both absent null and present index string; the current-grammar 5x2 manifest is byte-exact."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime capture_groups_; bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime helpers_5_2_"
---

# Rust Capture Group Helper Indexing

**Confirmed 2026-07-02 (`RUST-PARITY.7.2`).** Rust now matches the backend-neutral `.spec`
contract already documented in the mdBook: numbered capture helpers are 0-based over
captures only. `entry_group(0)` / `match_group(0)` return the first participating capture,
not the full match. Use `entry_text()` / `match_text()` for the full regex match.

The runtime keeps two layouts internally:

- `MatchResult.groups`: regex-oriented, with index `0` as the full match. This remains an
  internal/debug layout.
- `MatchResult.captures`: LinkedSpec helper layout. Non-participating optional captures
  are omitted, which compacts later indices; participating empty-string captures remain
  present.

`RuntimeContext.entry_groups` and `RuntimeContext.match_groups` now receive the
`captures` projection. Whole-match text and lengths are derived from stored byte spans and
converted at the helper boundary, not from group index `0`.

An index beyond that compacted list returns `undef` (JSON `null`). It is distinct from a participating capture
whose text is the empty string. Rust's `match_group(N)` already made this distinction; the 2026-07-22
current-grammar proof corrected `entry_group(N)` to use the same present-or-undef projection instead of synthesizing
an empty string for an absent vector element.

## Links

- Task tree: [[RUST-PARITY]] (leaf `.7.2`)
- Related: [[rust-entry-match-separation]], [[rust-perl-output-oracle]]
- Public contract: `docs/linkedspec-book/src/user-model/regex-in-spec.md`,
  `docs/linkedspec-book/src/appendix/helper-contract-catalog.md`
- Files: `rust/linkedspec-runtime/src/helpers.rs`, `rust/linkedspec-runtime/src/engine.rs`,
  `rust/linkedspec-runtime/src/runtime.rs`

## September 7 assertion audit

`SESSION-STARTUP-READING.3.3.22` reads the actual engine assertions: whole-match text and
captures-only groups are separate, and the absent-entry test checks null versus a present string.
Named group tests separately check missing names and numeric 1/0 presence. These are source-reading
facts; the July corpus counts above are historical, and this checkpoint did not rerun native tests.
Current typed-source neutral proof passes 14 complete / 0 pending / 231 mutations.
