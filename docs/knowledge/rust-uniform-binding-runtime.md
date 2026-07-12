---
id: rust-uniform-binding-runtime
title: "Rust bare mutations use one typed binding on native and generated execution"
answers:
  - "does Rust support selector free push split and hash mutation"
  - "what does Rust set return for method chaining"
  - "how does Rust report a wrong kind bare mutation"
  - "does a saved Rust mutation result change after a later mutation"
  - "how does Rust distinguish push rule dispatch from binding mutation"
  - "are array name and hash name rejected on Rust yet"
date: 2026-07-12
status: current
tags: [rust, language, bindings, array, harray, mutation, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.3 adds narrow RuntimeContext bare-array/harray mutation methods and native/generated integration proof. Bare push/append, mutable split, hash/index update, array end mutation, and standalone collection transforms read and update the current RuntimeValue; set chains from its assigned value; ambiguous push checks the compiled static rule table first; missing targets auto-create; wrong kinds report binding_kind_mismatch. Private scalar/array/hash maps remain an implementation detail. Wrapper forms remain accepted only until scheduled migration and Rust hard rejection."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test uniform_binding_contract"
---

# Rust uniform binding runtime

Rust consumes `linkedspec-uniform-binding-v1` through the same `Engine` used by native and generated-plan
execution. `RuntimeContext` may retain separate private maps, but a bare `.spec` identifier is resolved to one
current `RuntimeValue`. Bare `push(name, value)`, `name += value`, `split(name, source, delimiter)`,
`name[key] = value`, `set_key(name, key, value)`, and array end/standalone collection mutations update that value.

Mutable operations clone their returned `RuntimeValue`, so saving a first update is an independent snapshot when
the binding changes again. `set(name, value)` yields the assigned value and therefore supports chains such as
`set(items, ["b", "a"]).sorted().first()`. Array-end mutations likewise feed continuations, so
`items.push_back(value).count()` mutates `items` and yields its updated count.

An absent array or harray mutation target starts as the required empty kind. An existing incompatible value fails
with `binding_kind_mismatch` and stable identifier, expected-kind, and actual-kind fields. A statically compiled
rule retains precedence when the first argument of `push(...)` is ambiguous; otherwise the bare name is the array
binding.

The first full oracle run exposed a mixed migration bridge: bare `push(items, "a")` created a scalar-held array,
then statement `items += value` used the old aggregate-map path and lost the first update. Routing both statement
and expression append through the same bare mutation method repaired the causal defect; the existing oracle
fixture now returns `["a", "b"]`.

Exact `array(name)` and `hash(name)` are still parsed temporarily so existing sources can migrate after every
backend supports the replacement. This is scheduled compatibility, not an unresolved language choice. Rust
deletes and rejects those selector paths in `FUTURE-PARITY-BACKLOG.12.1.8.2` after source migration.

Related facts: [[uniform-binding-neutral-contract]], [[perl-uniform-binding-runtime]],
[[spec-facing-aggregate-selector-retirement-inventory]], [[terse-rust-duck-typed-assignment-parity]].
