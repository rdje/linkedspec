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
  - "why did copy inside a Perl user function become an unsupported helper"
  - "how does Perl distinguish an implicit rule accumulator from an untyped copy binding"
  - "why can a shallow Perl copy remain unchanged after a nested write"
date: 2026-07-12
status: current
tags: [perl, language, bindings, array, harray, mutation, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.2 adds LinkedSpec::BindingRuntime and focused live/standalone generated execution locks. FUTURE-PARITY-BACKLOG.12.1.7.1 then proves pure array/hash helpers, emptiness flow, and print_each consume those same scalar-held typed values after shipped selector migration; the original Lispish join_values failure came from legacy @name fast-path reads diverging from $name mutation writes. FUTURE-PARITY-BACKLOG.12.1.7.3 removes embedded selector sources and closes two final lowering seams: aggregate AST arguments inside user functions preserve the spec-level bare name until runtime typed-value lowering, while each rule label is recorded as its implicit internal array accumulator unless explicitly rebound. FUTURE-PARITY-BACKLOG.12.1.8.1 then rejects exact selector nodes before Perl lowering with the neutral diagnostic while retaining non-selector constructors."
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

Exact `array(name)` and `hash(name)` are rejected on Perl before lowering with `aggregate_selector_removed` and
portable surface/identifier/replacement fields. This includes nested/dead rule code and unused user-function
bodies. Empty, quoted, computed, and multi-argument constructors remain values. See
[[perl-aggregate-selector-compile-rejection]].

The Perl lowering invariant is now explicit: uniform bindings live in scalar-held typed values, so mutation and
read-only helper paths must both consume `$name`. During shipped migration, `join_values("", word)` initially read
legacy `@word` after `push(word, value)` had updated `$word`; that split produced empty Lispish words. Central
array/hash helper lowering, generic typed emptiness checks, and `print_each` now all use the scalar-held value when
the rule's bare-name memory identifies a uniform binding. Generated Perl sigils remain private host machinery and
do not create a second `.spec` namespace.

Embedded-source migration exposed two related ownership boundaries. A user-function local such as `items` is a
scalar-held runtime typed value; the aggregate AST bridge must pass the spec-level name into `copy(items)` and let
the aggregate lowerer produce the runtime kind check, rather than prematurely constructing the host spelling
`copy($items)`. Conversely, every generated rule has a private implicit array accumulator named after its label.
Type memory records that known ownership so `copy(rule_label)` snapshots `@rule_label`; an explicit authored
binding of the same name still overrides it as a scalar-held typed value. This replaces the old array-first guess
with explicit ownership at both boundaries.

Related facts: [[uniform-binding-neutral-contract]], [[perl-aggregate-selector-compile-rejection]],
[[spec-facing-aggregate-selector-retirement-inventory]],
[[uniform-expression-compatibility-retirement-doctrine]].

September 6 `.3.2.28` reverified `original = {"nested":{"x":1}}; snapshot = copy(original);`
followed by `original["nested"]["x"] = 2`. Public Get returns original x=2 and snapshot x=1. The dumped
copy creates an outer hash snapshot; the later write calls `BindingRuntime::nested_write` and rebinds
`original` to its updated value. This control establishes independence for that DSL mutation sequence,
not a promise that the copy expression recursively clones arbitrary host objects. The exact control lives
in `docs/tasks/SESSION-STARTUP-READING.md` under `.3.2.28`.
