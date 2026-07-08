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
evidence: "SPEC-LANG-REFERENCE.7 promotes the durable rule-mode retrieval point from mdBook rule-modes-and-parse-modes.md and runtime-semantics.md. Earlier SPEC-LANG-REFERENCE.10.5.6 corrected runnable examples to use no-regex top wrappers and normal regex-owning matcher rules."
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
| `Rule::` | entry-style spelling, commonly used as a no-regex top dispatcher |
| `Rule:&`, `Rule:AND` | ordered sequence |
| `Rule:|` | single successful choice |
| `Rule:+` | one-or-more repeated choice |
| `Rule:*` | zero-or-more repeated choice |
| `Rule:?` | zero-or-one repeated choice |
| `Rule:OR`, `Rule:OR+`, `Rule:OR{...}` | explicit repeated choice, optionally bounded |
| `Rule:AND+`, `Rule:AND{...}` | repeated ordered sequence, optionally bounded |

Bounds count complete iterations:

- `{N}` means exactly `N`;
- `{N,M}` means at least `N` and at most `M`;
- `{N,}` means at least `N` and no DSL-level upper bound;
- `{,M}` means zero through `M`;
- invalid or descending bounds should fail validation.

For book examples, keep `::` as a no-regex entry or dispatcher rule and put
regex slots on ordinary `:` rules. Mechanically, the top rule is still an
ordinary rule entered first; the no-regex wrapper style is the current teaching
idiom.

## Links

- Task tree: [[SPEC-LANG-REFERENCE]] (leaf `.7`)
- Book contract: `docs/linkedspec-book/src/user-model/rule-modes-and-parse-modes.md`
- Related: [[top-rule-is-ordinary-rule-entered-first]], [[spec-top-rule-no-regex-two-rule-minimum]]
