---
id: perl-numeric-reducer-direct-read-rejection
title: "Perl numeric sum rejects direct-access array values before evaluation"
answers:
  - "why does sum(document[items]) return null on Perl"
  - "does Perl sum accept a direct-access array receiver"
  - "which task repairs numeric reducer direct-read composition"
date: 2026-09-24
status: confirmed defect; required repair SESSION-STARTUP-READING.91 after .90 before .51
tags: [perl, numeric, arrays, direct-access, lowering, SESSION-STARTUP-READING]
evidence: "Public Get returns null for sum(document[\"items\"]), num_sum(document[\"items\"]) and direct-read .sum() over [3,1,2]; assigning the read to a binding also fails. Literal and explicit sorted-chain controls return6. Explicitly loaded activation-commit owners reproduce all four failures. Public call_spec_handler_subst emits the num_sum unsupported-helper sentinel. MethodLowering rejects through the array-source spelling classifier before ordinary value lowering. Exact sources/results and baseline identities are in docs/checkpoints/SESSION-STARTUP-READING.91-numeric-direct-read.json."
reverify: "Replay the checkpoint sources through LinkedSpec::Get/runtime_ctx_ref and call_spec_handler_subst under tools/project_data_run.sh; compare full values and the unsupported-helper sentinel."
---

With `document = {"items":[3,1,2]}`, all three measured spellings return null:
`sum(document["items"])`, `num_sum(document["items"])` and
`document["items"].sum()`. The literal twin `sum([3,1,2])` returns6.
Assigning the direct read to `selected` before `sum(selected)` also returns null.
The explicit `document["items"].sorted().sum()` control returns6 on both versions.
This failure predates the read-purity repair; it is not a guarded-read regression.

MethodLowering's AST aggregate bridge eventually reaches its compatibility
`num_sum` arm. That arm accepts only sources which the array-spelling classifier
or internal pipeline lowerer recognizes, before attempting normal value lowering.
FlowExpr's classifier accepts named arrays and known array-producing calls but
rejects direct-access syntax. The resulting unsupported-helper sentinel evaluates
to undef without a runtime context error. Static source spelling prevents the
runtime reducer from seeing a valid array value.

Startup `.91` owns the bounded correction after function constructors `.90` and
before `.51`, including fresh emitted execution and single-evaluation controls.
Audit other reducer arms at activation instead of assuming the whole family fails.
No `.91` implementation or full-family acceptance is claimed in `.89`.
