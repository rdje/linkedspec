---
id: uniform-binding-array-end-result-supersession
title: Uniform binding supersedes statement-only array-end mutation results
answers:
  - "are array end mutations statement only now"
  - "what do push_back push_front pop_back and pop_front return"
  - "can an array end mutation continue into count"
  - "why do array end mutation docs disagree with uniform binding"
  - "which task repairs stale statement-only array end documentation"
date: 2026-07-12
status: current
tags: [language, uniform-binding, arrays, mutation, results, documentation, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.1 adopts linkedspec-uniform-binding-v1: mutable operations yield independent updated typed targets unless a callable explicitly returns something else. .12.1.2-.6 make Perl, Rust, Dart, Julia, and Lua execute that rule; each backend's permanent facts/tests include array-end result continuation. LUA-BACKEND-PARITY.4.3.4.0 found older mdBook and Knowledge Map sentences still teaching the superseded statement-only/null-result boundary. FUTURE-PARITY-BACKLOG.12.1.11 owns repair and recurring no-drift."
reverify: "python3 tools/check_uniform_binding_contract.py && rg -n 'push_back.*count|array-end.*updated|mutation_result' capability_conformance/uniform_binding_contract.json t rust dart julia lua docs/tasks/FUTURE-PARITY-BACKLOG.md docs/knowledge/*uniform-binding*"
---

The current contract is not statement-only. `push_back`, `push_front`, `pop_back`, and `pop_front` mutate one typed
array binding and evaluate to an independent copy of the updated array. Pop still discards the removed element; it
does not return that element. The updated array may feed a compatible continuation, so
`items.push_back(value).count()` mutates `items` and yields the new count. Saving an earlier mutation result does
not alias a later update.

This supersedes the narrower `SPEC-FORMAT-TERSE.1.6` result boundary recorded before uniform binding was adopted.
That older card remains valid history for what the original slice shipped, but it is not current normative
guidance. The array audit found stale current-facing statement-only/no-value claims in the helper catalog, helper
reference, backend summaries, and Dart/Julia/terse Knowledge Map cards. `FUTURE-PARITY-BACKLOG.12.1.11` must
reconcile those surfaces before Lua array implementation continues.
