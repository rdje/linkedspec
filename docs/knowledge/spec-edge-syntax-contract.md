---
id: spec-edge-syntax-contract
title: .spec edge syntax contract - action edges, blind-call edges, and grouped action targets
answers:
  - "what is the spec edge syntax contract"
  - "what is the difference between -> and => edges"
  - "are grouped action-edge targets valid"
  - "is -> A | B valid without a code block"
  - "where is grouped action-edge syntax regression locked"
date: 2026-07-01
status: locked
tags: [spec-format, dsl, action-edge, blind-call, grouped-targets]
evidence: "SPEC-FORMAT-TERSE.3.1; t/phase0_regression.t grouped-action subtests; perl/LinkedSpec/Validation.pm grouped-target diagnostic; docs/linkedspec-book/src/dsl/action-and-lifecycle-placement.md; docs/linkedspec-book/src/appendix/formal-grammar.md"
reverify: "perl -Iperl -c t/phase0_regression.t"
---

# .spec Edge Syntax Contract

As of `SPEC-FORMAT-TERSE.3.1`, Round 3 keeps the existing edge syntax:

- `-> Target` is an action edge. It binds the current rule to a child rule and
  requires action code for semantic transformation.
- `=> Target` is a blind-call edge. It delegates to the child rule without a
  parent action block; the child rule's own actions run.
- `-> A | B { code }` is valid grouped action-edge syntax. The pipe is only
  syntactic factoring: one shared block is expanded across the listed targets,
  and each target still dispatches independently.
- `-> A | B` without `{ code }` is invalid. The validator reports "Grouped
  action-edge targets require a shared code block".

Existing locks are in `t/phase0_regression.t`:

- `bootstrap_grouped_action_edge_targets_share_one_code_block`
- `validation_accepts_grouped_action_edge_targets_with_shared_code_block`
- `validation_rejects_grouped_action_edge_targets_without_shared_code_block`
- `validation_accepts_grouped_action_edge_with_three_targets`

The user-facing contract is documented in the mdBook action/lifecycle placement
chapter and the formal grammar appendix.
