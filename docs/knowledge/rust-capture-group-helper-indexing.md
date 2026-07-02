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
date: 2026-07-02
status: confirmed
tags: [rust, capture-groups, helpers, oracle, RUST-PARITY]
evidence: "RUST-PARITY.7.2: rust/linkedspec-runtime/src/helpers.rs now stores both regex-oriented groups (index 0 full match) and LinkedSpec captures (capture-only, compacted); rust/linkedspec-runtime/src/engine.rs assigns ctx.entry_groups/ctx.match_groups from MatchResult.captures and reads whole-match text/length from spans. Tests cover capture_groups_optional_not_matched, capture_groups_empty_match_remains_participating, helpers_5_2_entry_text_and_entry_group, helpers_5_2_entry_groups_array, and the 65-fixture corpus oracle."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime capture_groups_ -- --nocapture && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime helpers_5_2_entry -- --nocapture && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture"
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

## Links

- Task tree: [[RUST-PARITY]] (leaf `.7.2`)
- Related: [[rust-entry-match-separation]], [[rust-perl-output-oracle]]
- Public contract: `docs/linkedspec-book/src/user-model/regex-in-spec.md`,
  `docs/linkedspec-book/src/appendix/helper-contract-catalog.md`
- Files: `rust/linkedspec-runtime/src/helpers.rs`, `rust/linkedspec-runtime/src/engine.rs`,
  `rust/linkedspec-runtime/src/runtime.rs`
