---
id: spec-rule-mode-semantics-map
title: "Rule mode labels choose sequence, choice, repetition and bounds; current cursor policy derives from the rule family"
answers:
  - "what do LinkedSpec rule modes mean"
  - "what is the rule-mode semantics map"
  - "what is the difference between :& and :AND"
  - "what is the difference between :| and OR"
  - "how do AND+ OR+ and bounded rule modes behave"
date: 2026-07-08
status: family labels and bounds retained; historical global cursor axis superseded by ADR0044
tags: [spec-language, rule-modes, parse-modes, sequence, choice, repetition, SPEC-LANG-REFERENCE]
evidence: "SPEC-LANG-REFERENCE.7 promotes the durable rule-mode retrieval point from mdBook rule-modes-and-parse-modes.md and runtime-semantics.md. SPEC-LANG-REFERENCE.8 corrected stale no-regex-top wording after ADR 0010: `::` is the entry marker, and once selected it has the same rule-mode/regex/action feature surface as `:`. Runnable stream examples may still use no-regex top wrappers as an idiom."
---

# Spec Rule-Mode Semantics Map

**Updated 2026-09-21 (`CONFORMANCE-SOURCE-READING.1.43`).** The July 8
evidence above predates ADR0044. The rule label chooses body composition and
now intrinsically derives cursor discipline: AND families consume and OR/default
families seek. The public/global `parse_mode` override has been removed.
[[rule-local-cursor-and-bare-edge-contract]] owns the admitted current contract.

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

The earlier design audit [[and-or-cursor-ownership-audit]] motivated this
replacement; it is no longer pending implementation. All five backends and six
runtime routes are admitted under the canonical contract's eight completed
rollout items. Parent mode never propagates to or overrides child mode; see
[[rule-local-cursor-ownership-decision]]. This reading checkpoint reconciles the
older wording with that existing admission and claims no fresh runtime execution.

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
