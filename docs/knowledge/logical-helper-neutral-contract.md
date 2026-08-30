---
id: logical-helper-neutral-contract
title: ADR 0043 fixes eager logical helpers over one typed truthiness policy
answers:
  - "what is LinkedSpec logical truthiness"
  - "is string zero true in LinkedSpec"
  - "is string false true in LinkedSpec"
  - "are empty arrays truthful in LinkedSpec"
  - "what arity do and or not accept"
  - "are LinkedSpec logical helpers eager"
  - "how do logical helper arity errors work"
  - "does testing a codeblock invoke it"
  - "which ADR defines LinkedSpec logical helpers"
  - "does the logical contract activate codeblock literals"
date: 2026-07-16
status: accepted-target
tags: [logical, truthiness, arity, actionir, codeblock, generated-source, portability, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.2.1 adopts ADR 0043 and linkedspec-logical-helper-v1. The independent checker validates 17 truthiness rows, ten helper cases, three eager effect scenarios, receiver and lazy-control contrast, four invalid arities, deterministic embedded fixtures, exact projection obligations, and 26 semantic/topology/public drift mutations. Perl .5.2.2, Rust .5.2.3, Dart .5.2.4, Julia .5.2.5, dual-ABI Lua .5.2.6, generated/primary .5.2.7, recurring admission .5.2.8, and public no-drift .5.2.9 consume and lock the unchanged target. Rollout is 8 complete / 0 pending. The explicit-codeblock row remains model/backend-unit evidence and does not activate FUTURE-PARITY-BACKLOG.11 syntax."
evidence_update_2026_08_30_mdbook_reconciliation: "FUTURE-PARITY-BACKLOG.23.2 makes the backend-handoff wording explicitly historical and forbids the two former present-tense `.5.2`-pending statements. Current governance is 19 documents / 14 stale-current denials / 26 mutations at rollout 8 complete / 0 pending; helper semantics, truthiness, arity, evaluation, runtime, and generated behavior remain unchanged."
reverify: "bash tools/check_logical_helper_five_backend.sh"
---

The adopted target treats `and`, `or`, and `not` as ordinary boolean value helpers. `and` and `or` accept at
least one positional argument; `not` accepts exactly one. Invalid arity produces `helper_arity_mismatch` with
helper name, actual arity, and expected arity before any operand evaluates. After a valid call is accepted, every
operand evaluates exactly once from left to right. `and`/`or` never short-circuit.

Truthiness is typed:

- null and false are false;
- finite numeric zero, including negative zero, is false; every other finite number is true;
- only the empty string is false, so `"0"`, `"false"`, whitespace, and nonempty Unicode text are true;
- empty arrays and harrays are false; nonempty aggregates are true regardless of their contained values;
- codeblocks are true without invocation.

Every valid logical call returns a real boolean, including one-argument `and(value)` and `or(value)`. Compatible
receiver continuations consume that boolean. `if`, `switch`, and `while` use the same truthiness seam but remain
lazy controls that execute only the selected branch or body.

The codeblock row fixes value-kind behavior only. Because explicit `{|...| ... }` literals remain separately
owned by `FUTURE-PARITY-BACKLOG.11`, the neutral portable source fixture excludes them; backend rollout proves the
row at typed runtime/unit boundaries without silently expanding logical-helper scope.

The target is adopted and current on the Perl reference's native/live/standalone-emitted roles, Rust's native/
serialized/generated-plan/direct-value/compiled-emitted roles, Dart's native/normalized/generated-plan/
standalone-emitted/primary roles, and Julia's native/normalized/generated-plan/standalone-emitted/primary roles.
Lua also conforms through native/reconstructed/generated-plan/loaded-emitted/primary roles on both ABIs.
Generated/primary, recurring admission, and public no-drift are complete at 8 complete / 0 pending. Parent
`FUTURE-PARITY-BACKLOG.5.2` is closed.

Related facts: [[logical-helper-five-backend-audit]], [[callable-codeblock-literal-contract]],
[[cross-backend-condition-truthiness-drift]], [[rust-logical-helper-neutral-runtime]],
[[dart-logical-helper-neutral-runtime]], [[julia-logical-helper-execution]],
[[logical-helper-recurring-five-backend-gate]], [[logical-helper-public-no-drift]].
