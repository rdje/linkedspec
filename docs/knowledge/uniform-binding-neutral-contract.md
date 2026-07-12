---
id: uniform-binding-neutral-contract
title: "Neutral contract v1 removes aggregate selectors and makes bare identifiers typed bindings"
answers:
  - "what replaces array name and hash name selectors"
  - "what does set return in the uniform binding contract"
  - "how does push distinguish a rule from an array binding"
  - "what is the mutable split syntax without array target wrappers"
  - "is array value still a valid one element constructor"
  - "which array and hash constructor calls remain after selector removal"
  - "what diagnostic replaces array identifier and hash identifier"
  - "does uniform binding require identical backend storage"
date: 2026-07-12
status: current
tags: [language, bindings, array, harray, mutation, diagnostics, compatibility, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.1 adopts capability_conformance/uniform_binding_contract.json and tools/check_uniform_binding_contract.py. The independent checker validates 11 migration mappings, seven binding/mutation execution cases, six exact invalid-selector cases, eight valid constructor/literal classifications, and deterministic future fixture source/results. Canonical local CI runs the checker before backend behavior changes."
reverify: "python3 tools/check_uniform_binding_contract.py"
---

# Uniform binding contract v1

`linkedspec-uniform-binding-v1` defines one observable binding per `.spec` identifier. The binding may hold scalar,
array, harray, or codeblock. A bare identifier reads that typed value; backend host storage layout is not public and
may not create an alternate namespace.

The core mutation and result rules are:

- `set(name, value)` binds the evaluated value and yields `name`'s post-assignment typed value;
- `push(name, value)` or `name += value` appends to an array binding and yields the updated array;
- an absent array/harray mutation target auto-creates only the required empty kind;
- mutation of an existing incompatible kind fails with `binding_kind_mismatch`;
- `split(source, delimiter)` remains pure, while `split(name, source, delimiter)` binds and yields the split array;
- `name[key] = value` binds/mutates an harray and yields the updated harray;
- unused expression values are silently dropped.

Static names keep precedence. When the first argument of `push(name, target)` is a registered rule, the call keeps
child-rule push semantics; otherwise it is array-binding mutation. That preserves existing rule dispatch without
making an alternate aggregate namespace public.

Exact `array(IDENTIFIER)` and `hash(IDENTIFIER)` are future-invalid everywhere with
`aggregate_selector_removed`, whether authored as a read, target, receiver, or would-be constructor. Use the bare
identifier for the value. Use `[identifier]` when a one-element array constructor was intended. Version 1 keeps
non-selector constructor calls such as `array()`, `array("literal")`, `array(expr1, expr2)`, `hash()`, and
`hash("key", value)`; literals remain canonical.

This contract is adopted before behavior. Perl `.12.1.2`, then Rust/Dart/Julia/Lua, consume the unchanged cases;
tracked sources migrate only after those alternatives execute, and hard rejection follows migration.

Related facts: [[spec-facing-aggregate-selector-retirement-inventory]],
[[uniform-expression-compatibility-retirement-doctrine]], [[terse-mutation-surface-ground-truth]].
