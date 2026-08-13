---
id: spec-edge-syntax-contract
title: .spec edge syntax contract - action edges, blind-call edges, and grouped action targets
answers:
  - "what is the spec edge syntax contract"
  - "what is the difference between -> and => edges"
  - "what is the action-vs-blind edge dispatch model"
  - "when should I use -> instead of =>"
  - "who owns the match for action and blind-call edges"
  - "does a regex preceding an action edge trigger that edge"
  - "which rule owns the regex selected by Rule[index]"
  - "are grouped action-edge targets valid"
  - "is -> A | B valid without a code block"
  - "where is grouped action-edge syntax regression locked"
date: 2026-07-01
status: locked
tags: [spec-format, dsl, action-edge, blind-call, grouped-targets]
evidence: "SPEC-FORMAT-TERSE.3.1; t/phase0_regression.t grouped-action subtests; perl/LinkedSpec/Validation.pm grouped-target diagnostic; docs/linkedspec-book/src/dsl/action-and-lifecycle-placement.md; docs/linkedspec-book/src/user-model/blind-calls-and-parser-orchestration.md; docs/linkedspec-book/src/appendix/formal-grammar.md; SPEC-LANG-REFERENCE.7 added the action-vs-blind dispatch retrieval keys."
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

## Dispatch model

Use `->` when the enclosing rule should own selection and attached action code.
The edge's target rule owns the selected regex slot: `-> Document` selects its
default slot and `-> Document[index]` selects an explicit zero-based slot. The
target retains its lifecycle/code. A preceding regex line has no trigger or
qualification relationship with the following edge; compact same-rule layouts
still resolve through the written target and index.

Use `=>` when the parent is a composition shell and the child parser should own
the next match. The parent rule label still decides whether those blind child
calls are sequenced, chosen, repeated choice, or repeated ordered sequence.
Blind calls do not imply `AND` by themselves.

Do not mix action edges and blind-call edges in one rule body. Split the work
into separate rules so each rule has one execution model.

Existing locks are in `t/phase0_regression.t`:

- `bootstrap_grouped_action_edge_targets_share_one_code_block`
- `validation_accepts_grouped_action_edge_targets_with_shared_code_block`
- `validation_rejects_grouped_action_edge_targets_without_shared_code_block`
- `validation_accepts_grouped_action_edge_with_three_targets`

The user-facing contract is documented in the mdBook action/lifecycle placement
chapter and the formal grammar appendix.

ADR `0044` ratifies a future shorthand without changing this current explicit
contract: a complete bare child member normalizes to blind ownership in AND and
action ownership in OR/default. Explicit `->` and `=>` retain the meanings above,
remain legal across families, and resolved ownership still cannot mix. Indexed
and grouped bare forms obey the resolved edge family's existing limits. Rollout
is pending under `FUTURE-PARITY-BACKLOG.9.1.2-.9`.

ADR `0045` additionally fixes historical “super split” as inter-match gap
capture around these externally resolved action-edge matches. It is unrelated
to blind calls. Perl now recognizes named regex selectors and `@capture_gaps`
static metadata and privately executes native-live gap behavior; generated
loading and portable/public admission remain pending.
