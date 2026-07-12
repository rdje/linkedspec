---
id: spec-regex-feature-contract
title: "A backend must support governed regex anchoring, branch/capture identity, and required lookaround"
answers:
  - "what regex features must a LinkedSpec backend support"
  - "what is the .spec regex feature set"
  - "are regex flags part of the .spec contract"
  - "how do numbered capture groups work in .spec"
  - "does entry_group(0) mean the whole match"
  - "does the spec regex contract require lookbehind"
  - "why does spec.spec use negative lookbehind"
date: 2026-07-08
status: confirmed
tags: [spec-language, regex, backend-contract, captures, SPEC-LANG-REFERENCE]
evidence: "SPEC-LANG-REFERENCE.2 verified the regex chapter against LinkedRE, ActionIR helper lowering, the Rust rgx-backed runtime, and shipped specs. SPEC-LANG-REFERENCE.7 promotes the durable backend-facing retrieval card."
---

# Spec Regex Feature Contract

**Confirmed 2026-07-08 (`SPEC-LANG-REFERENCE.7`).** `.spec` files are
regex-anchored. A conforming backend must reproduce the regex behavior described
by the Perl reference, even if its implementation uses a different regex engine.

The required surface is:

- slash-delimited regex literals, with `/` escaped as `\/` inside the pattern;
- inline regex flags such as `(?i)`, `(?m)`, `(?s)`, and scoped forms such as
  `(?s:...)`; `.spec` adds no separate flag syntax;
- seek mode, where a match may search forward from the cursor;
- consume mode, where a match is anchored at the current cursor;
- N-way alternation over a rule's regex slots, with branch identification so the
  engine knows which 0-based slot matched;
- numbered captures exposed as a 0-based captures-only list. Group 0 is the
  first parenthesized capture, not the whole match;
- compacted numbered captures: non-participating groups are removed from the
  list and can shift later indices;
- named captures with read and presence-test helpers.
- governed zero-width lookahead and fixed-width lookbehind, including
  `spec.spec`'s one-character negative `(?<!\\)` assertion.

Use `entry_text()` / `match_text()` for the whole match. Use
`entry_group(N)` / `match_group(N)` for numbered captures. Prefer named captures
when optional groups would make numbered capture compaction ambiguous.

## Links

- Task tree: [[SPEC-LANG-REFERENCE]] (leaf `.7`; original book work `.2`)
- Book contract: `docs/linkedspec-book/src/user-model/regex-in-spec.md`
- Related: [[rust-capture-group-helper-indexing]], [[entry-match-divergence-verified-shape]]
- Lookbehind engine proof: [[dart-lua-fixed-lookbehind-support]]
