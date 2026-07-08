---
id: spec-capture-mark-family-taxonomy
title: "Source-boundary helpers split into capture, mark, cursor, entry, match, and whole-input anchor families"
answers:
  - "what are the capture and mark helper families"
  - "what is the capture mark family taxonomy"
  - "when should I use capture_* versus mark_*"
  - "what is the difference between cursor entry and match helpers"
  - "how do anonymous capture boundaries and named marks relate"
date: 2026-07-08
status: confirmed
tags: [spec-language, helpers, capture-mark, source-boundaries, SPEC-LANG-REFERENCE]
evidence: "SPEC-LANG-REFERENCE.7 promotes the durable capture/mark taxonomy from capture-marks-and-source-locations.md, source-boundary-helper-reference.md, and helper-contract-catalog.md. SPEC-LANG-REFERENCE.5.5 and .6 added verified examples for the individual helpers and marker-form cross-example."
---

# Spec Capture/Mark Family Taxonomy

**Confirmed 2026-07-08 (`SPEC-LANG-REFERENCE.7`).** Source-boundary helpers
are organized by anchor family:

- `capture_*` uses the rule-local anonymous capture boundary. Use it when one
  rolling segment start is enough.
- `mark_*` uses named, rule-local checkpoints. Use it when more than one
  boundary must survive or when a boundary needs a durable name.
- `cursor_*` reads the live parser cursor.
- `entry_*` reads the match that entered the current rule/action context.
- `match_*` reads the current local match being processed.
- `input_*` reads absolute whole-input text or positions.

Anonymous and named boundaries can bridge:

- `mark_capture_slice(name)` stores the anonymous boundary into a named mark.
- `start_capture_slice_from(name)` restores the anonymous boundary from that
  named mark.

Capture readers differ by right edge:

- current local-match left edge: `capture_slice()` / `capture_from(name)`;
- live cursor: `capture_slice_until_cursor()` /
  `capture_until_cursor_from(name)`;
- end of input: `capture_rest()` / `capture_rest_from(name)`;
- explicit stored mark: `capture_between(start, end)`.

Helpers containing `take` read and then advance the relevant boundary. Marker
members such as `@capture_slice` and `@mark(name)` are placement-sensitive; use
helper-call forms such as `start_capture_slice()` and `mark_here(name)` when the
boundary belongs inside an action block.

## Links

- Task tree: [[SPEC-LANG-REFERENCE]] (leaf `.7`)
- Book contract: `docs/linkedspec-book/src/dsl/source-boundary-helper-reference.md`
- Related: [[split-boundary-marker-action-timing]], [[entry-match-divergence-verified-shape]]
