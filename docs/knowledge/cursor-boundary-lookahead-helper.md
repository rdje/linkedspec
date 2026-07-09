---
id: cursor-boundary-lookahead-helper
title: "capture_until_boundary(rule[, ...]) is the portable non-consuming structural boundary helper"
answers:
  - "how do I capture until the next structural rule without consuming it"
  - "does LinkedSpec support zero width lookahead boundaries"
  - "what helper replaces consume then rewind for EBNF semantic annotations"
  - "how does capture_until_boundary work"
  - "is capture_until_boundary based on save_cursor restore_cursor"
  - "should EBNF semantic_annotation use rewind_match_start"
date: 2026-07-09
status: current
tags: [helpers, cursor, boundary-lookahead, perl, rust, dart, BACKTRACK-SURFACE-RUST-ALIGNMENT]
evidence: "BACKTRACK-SURFACE-RUST-ALIGNMENT.2 adds capture_until_boundary(rule[, ...]) to Perl ActionIR lowering/scanning, Rust runtime helper execution/validation, and Dart ActionIR/runtime execution. The active specs/ebnf.spec and Rust corpus copies use capture_until_boundary(semantic_annotation, grammar_rule) so semantic annotations stop before the next semantic annotation or grammar rule without consuming that boundary."
reverify: "PERL5LIB= perl -Iperl t/phase0_regression.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime helpers_capture_until_boundary_captures_without_consuming_boundary && cd dart && dart test test/runtime_interpreter_test.dart -n 'captures until named boundary without consuming the boundary'"
---

# Non-Consuming Structural Boundary Capture

`capture_until_boundary(rule[, ...])` is the portable helper for open-ended
payloads whose right edge is the next structural rule, not a fixed delimiter.

The helper starts at the live cursor and seeks for the earliest match of any
named boundary rule. It returns the text before that boundary and moves the live
cursor to the boundary start. The boundary match itself is not consumed, so the
normal rule path can process it next.

This is intentionally distinct from the other cursor controls:

- `save_cursor()` / `restore_cursor()` are explicit stack operations.
- `rewind_match_start()` / `rewind_entry_start()` move to lifecycle anchors after
  something has already been consumed.
- `capture_until_boundary(...)` avoids consuming the structural boundary in the
  first place.

`specs/ebnf.spec` uses:

```text
capture_until_boundary(semantic_annotation, grammar_rule)
```

so an annotation body stops before either the next annotation or the next grammar
rule header.

If at least one requested boundary rule resolves but none is found later in the
input, the helper captures through end-of-input and moves the cursor there. If no
requested boundary rule can be resolved to a usable pattern, it returns
`undef`/`null` and leaves the cursor unchanged.

Related facts: [[spec-capture-mark-family-taxonomy]],
[[dart-runtime-backtrack-cursor-helpers]], [[rust-anonymous-capture-slice-family]].
