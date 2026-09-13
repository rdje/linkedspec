---
id: conformance-uniform-binding-reading
title: Uniform-binding neutral reading and stale rollout guidance
answers:
  - "which uniform-binding contract bytes are physically read in conformance group 30"
  - "who owns the neutral uniform-binding future rollout wording"
  - "does conformance binding validation establish a fresh native runtime pass"
date: 2026-09-13
status: contract prefix read; neutral checks pass; guidance repair pending
tags: [conformance, bindings, reading, guidance, evidence]
evidence: "CONFORMANCE-SOURCE-READING.1.30 reads uniform_binding_contract.json lines 1-168; .1.31 owns 169-179. Fresh managed neutral validation passes 11 migrations, 7 executions, 6 invalid selectors and 8 constructors. CONFORMANCE-SOURCE-READING.2.1 owns stale rollout wording and its independent correction checks."
reverify: "bash tools/run_python_project_data.sh tools/check_uniform_binding_contract.py; inspect the exact .1.30/.1.31 reading owners and .2.1 repair in docs/tasks/CONFORMANCE-SOURCE-READING.md"
---

The prefix of `capability_conformance/uniform_binding_contract.json` fixes one
observable scalar, array, harray or codeblock binding per ASCII identifier.
Bare reads preserve the typed value. `set` yields the post-assignment value;
mutable helpers normally yield the updated target. A registered static rule
retains precedence over variable mutation in ambiguous `push` syntax.

Exact one-bare-name `array(name)` and `hash(name)` calls are removed. Empty,
quoted, computed and multi-argument constructors remain separate cases. Use
`[name]` for a one-element array containing the binding value. The read prefix
includes all seven execution cases, six invalid selectors, eight valid
constructors and the complete fixture step list. The final fixture expectations
and closing delimiters at 169-179 remain the next reading leaf's responsibility.

The complete neutral checker passes 11 migration mappings, seven execution
cases, six selector rejections and eight constructor classifications. Its full
fixture validation adds no physical-reading credit for the unread suffix and
establishes no fresh backend, emitted-process or canonical CI result.

`docs/knowledge/uniform-binding-neutral-contract.md` still has `status: current`
while calling exact selectors future-invalid and leaving Rust/Dart/Julia/Lua
rejection as follow-up work. The dated Rust and Lua compile-rejection records
already describe completed `.12.1.8.2` and `.12.1.8.5` implementations and scoped
native evidence. This is a guidance discrepancy, not a newly measured runtime
failure. Pending `.2.1.1` will reconcile all five canonical backend owners and
date or replace the old rollout language; `.2.1.2` independently verifies the
correction. Required startup prerequisites and existing runtime limitations
remain in force. Original cards and their historical counts are preserved.

Related facts: [[uniform-binding-neutral-contract]],
[[rust-aggregate-selector-compile-rejection]],
[[lua-aggregate-selector-compile-rejection]],
[[conformance-source-reading-coverage]].
