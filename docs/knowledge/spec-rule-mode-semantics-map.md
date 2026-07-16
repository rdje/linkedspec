---
id: spec-rule-mode-semantics-map
title: "Rule mode labels choose sequence, choice, repetition, and bounds; parse mode is a separate cursor discipline axis"
answers:
  - "what do LinkedSpec rule modes mean"
  - "what is the rule-mode semantics map"
  - "what is the difference between :& and :AND"
  - "what is the difference between :| and OR"
  - "how do AND+ OR+ and bounded rule modes behave"
date: 2026-07-08
status: confirmed
tags: [spec-language, rule-modes, parse-modes, sequence, choice, repetition, SPEC-LANG-REFERENCE]
evidence: "SPEC-LANG-REFERENCE.7 promotes the durable rule-mode retrieval point from mdBook rule-modes-and-parse-modes.md and runtime-semantics.md. SPEC-LANG-REFERENCE.8 corrected stale no-regex-top wording after ADR 0010: `::` is the entry marker, and once selected it has the same rule-mode/regex/action feature surface as `:`. Runnable stream examples may still use no-regex top wrappers as an idiom."
---

# Spec Rule-Mode Semantics Map

**Confirmed 2026-07-08 (`SPEC-LANG-REFERENCE.7`).** Rule mode and parse mode
are separate axes. The rule label chooses the body-composition model; parser
construction or the handler family chooses cursor discipline (`seek` or
`consume`).

Current public rule-label semantics:

| Surface | Meaning |
| --- | --- |
| `Rule:` | historical repeated-choice baseline |
| `Rule::` | entry marker for the rule entered first; same body feature surface as `Rule:` |
| `Rule:&`, `Rule:AND` | ordered sequence |
| `Rule:|` | single successful choice |
| `Rule:+` | one-or-more repeated choice |
| `Rule:*` | zero-or-more repeated choice |
| `Rule:?` | zero-or-one repeated choice |
| `Rule:OR`, `Rule:OR+`, `Rule:OR{...}` | explicit repeated choice, optionally bounded |
| `Rule:AND+`, `Rule:AND{...}` | repeated ordered sequence, optionally bounded |

This card describes the current public implementation. Director-priority design
audit `FUTURE-PARITY-BACKLOG.9.1.0` has since shown that the separate
caller-global parse-mode axis mutates all nested rules and already creates an
uncovered default-AND backend drift. The proposed replacement makes OR/default
families intrinsically seek and AND families intrinsically consume, without a
public/global override; see [[and-or-cursor-ownership-audit]]. No runtime
behavior changes until the follow-on decision and implementation land.

Bounds count complete iterations:

- `{N}` means exactly `N`;
- `{N,M}` means at least `N` and at most `M`;
- `{N,}` means at least `N` and no DSL-level upper bound;
- `{,M}` means zero through `M`;
- invalid or descending bounds should fail validation.

For stream-of-records examples, the book often uses a no-regex `::` entry wrapper
that dispatches to regex-owning matcher rules and returns an accumulator. That is
an idiom, not a validity rule. Mechanically, `::` marks the rule entered first;
after entry selection, `::` and `:` rules support the same regex slots, modes,
edges, lifecycle blocks, and recursion model.

## Links

- Task tree: [[SPEC-LANG-REFERENCE]] (leaf `.7`)
- Book contract: `docs/linkedspec-book/src/user-model/rule-modes-and-parse-modes.md`
- Related: [[top-rule-is-ordinary-rule-entered-first]], [[spec-top-rule-no-regex-two-rule-minimum]]
