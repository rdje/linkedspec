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
  - "why did migrated bare join values read an empty Perl array"
  - "do Perl pure helpers read the same bare typed binding as mutations"
date: 2026-07-12
status: current
tags: [perl, language, bindings, array, harray, mutation, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.2 adds LinkedSpec::BindingRuntime and focused live/standalone generated execution locks. FUTURE-PARITY-BACKLOG.12.1.7.1 then proves pure array/hash helpers, emptiness flow, and print_each consume those same scalar-held typed values after shipped selector migration; the original Lispish join_values failure came from legacy @name fast-path reads diverging from $name mutation writes. Bare mutation/chaining, static precedence, missing-target creation, and binding_kind_mismatch remain locked."
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

Exact `array(name)` and `hash(name)` remain accepted temporarily for source compatibility. All backend enablement
leaves are complete, and all 15 affected shipped specs are selector-free. Remaining tracked-source migration is
active; Perl hard rejection follows in
`FUTURE-PARITY-BACKLOG.12.1.8.1`.

The Perl lowering invariant is now explicit: uniform bindings live in scalar-held typed values, so mutation and
read-only helper paths must both consume `$name`. During shipped migration, `join_values("", word)` initially read
legacy `@word` after `push(word, value)` had updated `$word`; that split produced empty Lispish words. Central
array/hash helper lowering, generic typed emptiness checks, and `print_each` now all use the scalar-held value when
the rule's bare-name memory identifies a uniform binding. Generated Perl sigils remain private host machinery and
do not create a second `.spec` namespace.

Related facts: [[uniform-binding-neutral-contract]],
[[spec-facing-aggregate-selector-retirement-inventory]],
[[uniform-expression-compatibility-retirement-doctrine]].
