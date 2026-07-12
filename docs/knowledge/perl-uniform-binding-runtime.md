---
id: perl-uniform-binding-runtime
title: "Perl bare mutations execute through one typed binding and return independent updated values"
answers:
  - "does Perl support selector free push split and hash mutation"
  - "what does Perl set return for method chaining"
  - "how does Perl report a wrong kind bare mutation"
  - "does a saved Perl mutation result change after a later mutation"
  - "how does Perl distinguish push rule dispatch from binding mutation"
  - "are array name and hash name rejected on Perl yet"
date: 2026-07-12
status: current
tags: [perl, language, bindings, array, harray, mutation, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.2 adds LinkedSpec::BindingRuntime and focused live/standalone generated execution locks. Bare push/append, mutable split, hash/index update, array end mutation, in-place collection transforms, reads, receivers, copies, and chaining use scalar-held typed values; set chains from its assigned value; ambiguous two-bare push checks the static rule registry first; missing mutation targets auto-create; wrong kinds report binding_kind_mismatch. Wrapper forms remain accepted only until the scheduled source migration and Perl hard-rejection leaf."
reverify: "prove -Iperl t/uniform_binding_contract.t t/actionir_ast_parser.t t/trace_actionir_compact_lowerers.t t/trace_actionir_method_lowering.t"
---

# Perl uniform binding runtime

The Perl reference now consumes `linkedspec-uniform-binding-v1`. A `.spec` identifier exposes one typed value even
though generated Perl may use private host machinery. Bare `push(name, value)`, `name += value`,
`split(name, source, delimiter)`, `name[key] = value`, `set_key(name, key, value)`, and array end/transform methods
all update that binding and yield its post-operation typed value.

Array and harray updates are copy-on-write at the helper boundary. If a caller saves the result of one mutation,
a later mutation produces another value rather than changing the saved result through a shared Perl reference.
`set(name, value)` uses ordinary assignment value semantics, so `set(items, ["b", "a"]).sorted().first()` yields
`"a"` while `items` remains `["b", "a"]`.

An absent mutable target becomes the required empty array or harray before the update. An existing incompatible
target fails deterministically with `binding_kind_mismatch` plus identifier, expected kind, and actual kind.
For ambiguous `push(rule_or_target, destination_or_value)`, a registered static rule handler wins; otherwise the
first bare name is the array binding.

Exact `array(name)` and `hash(name)` remain accepted temporarily for source compatibility. Their removal is
already decided: the backend enablement leaves precede tracked-source migration, followed by Perl hard rejection
in `FUTURE-PARITY-BACKLOG.12.1.8.1`.

Related facts: [[uniform-binding-neutral-contract]],
[[spec-facing-aggregate-selector-retirement-inventory]],
[[uniform-expression-compatibility-retirement-doctrine]].
