---
id: write-vivification-neutral-contract
title: "Future nested write vivification uses evaluated typed segments and one unified ActionIR node"
answers:
  - "what is the neutral nested write vivification contract"
  - "does write vivification currently run on any backend"
  - "does a dynamic string path segment select an harray"
  - "does a dynamic integer path segment select an array"
  - "does quoted zero select an array or harray"
  - "what AST node owns one segment nested assignment"
  - "what AST node owns multi segment nested assignment"
  - "when do nested write segments and RHS evaluate"
  - "what happens when a nested write expression mutates the same binding"
  - "does a failed nested write roll back expression side effects"
  - "can nested write vivification create array gaps"
  - "what diagnostics does nested write vivification use"
  - "why must current static key index lowering change"
  - "how are nested write source spans measured"
date: 2026-08-30
status: neutral contract frozen under FUTURE-PARITY-BACKLOG.19.1.1; implemented on Perl and Rust by .19.2.1/.19.3.1
tags: [dsl, actionir, assignment, autovivification, diagnostics, source-spans, mutation, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.1.1 adds capability_conformance/write_vivification_contract.json and tools/check_write_vivification_contract.py. The independent checker validates five exact AST cases, seven syntax failures, 11 successful writes, 16 structural failures, three expression failures, three read exclusions, detached values, and 105 rejected mutations. Exact current probes remain non-vivifying on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT. Perl lowering proves quoted segments are currently tagged key while every computed segment is statically tagged/coerced as index; Rust/Dart/Julia/Lua preserve the same authored key/index split. No backend behavior or public-current capability changes in this leaf."
evidence_update_2026_08_31_composition: "FUTURE-PARITY-BACKLOG.19.1.3 adds linkedspec-write-map-leaves-composition-v1 as a shared fixture consumed by both existing checkers. This write checker now validates eight additional nested writes spanning detached callback value, unrelated global, same-spelling shadow local, active receiver guard, and post-commit receiver targets while retaining all 105 base mutations. No write behavior is admitted."
evidence_update_2026_08_31_perl_reference: "FUTURE-PARITY-BACKLOG.19.2.1 implements the unchanged v1 contract on Perl only. One-/many-segment parsing, authored spans, exact typed syntax/runtime diagnostics, evaluated string/integer dispatch, absent-versus-bound-null presence, dense isolated creation, post-evaluation snapshots, detachment, and rule/function invocation state are exercised directly from the frozen fixture. Rust, Dart, Julia, and Lua remain non-vivifying; capability/public admission remains pending."
evidence_update_2026_09_01_rust_reference: "FUTURE-PARITY-BACKLOG.19.3.1 implements the same unchanged v1 contract on Rust. Parsed, serialized, generated-plan, emitted-source, independently compiled emitted Rust, and native execution preserve one typed assign_nested_access node with expression-bearing path segments and Unicode-scalar spans. Runtime strings/nonnegative integers select harray/array, absent state is distinct from bound null, structural building is isolated and dense, typed errors fail closed, and fresh user-function locals/parameters retain their presence rules. Dart, Julia, and Lua remain non-vivifying; map_leaves! and portable/public admission remain pending on Rust."
evidence_update_2026_09_01_rust_composition: "FUTURE-PARITY-BACKLOG.19.3.2 implements Rust map_leaves! and executes the frozen write/mutation composition. Callback-local, unrelated, active-receiver, shadow, and post-commit nested writes retain the unchanged write contract; Dart/Julia/Lua and portable/public admission remain pending."
reverify: "bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test write_vivification_contract"
---

# Future neutral write-vivification contract

The future `linkedspec-write-vivification-v1` contract keeps ordinary assignment syntax:

```text
document["sections"][0]["title"] = title
document[segment_name][position] = make_value()
```

It was frozen without admitting a backend. Perl and Rust now implement that unchanged contract under `.19.2.1`
and `.19.3.1`; Dart, Julia, and Lua retain their existing non-vivifying behavior until their owned implementation
leaves and the later public admission boundary land.

## One typed path model

Every bracket contains one ordinary ActionIR value expression. Its evaluated value, not its spelling, selects the
container kind: a string selects an harray and a nonnegative integer selects a zero-based array. Consequently a
dynamic string selects an harray, a dynamic integer selects an array, and the quoted string `"0"` remains an harray
key. Boolean, null, negative, fractional, aggregate, and codeblock values are invalid selectors.

One or many segments lower to `assign_nested_access`. Each `path_segment` retains `source`, a half-open
Unicode-scalar `source_span`, and its complete typed `expression`; the parser does not assign a semantic `key` or
`index` tag. The complete assignment retains exact source, span, bare binding base, ordered segments, and typed RHS.

This unification is necessary rather than cosmetic. Current lowering assigns quoted literals to a static key path
and computed expressions to a static integer-index path. A current `payload[segment]` therefore cannot implement
the accepted rule when `segment` evaluates to a string. The future implementation leaves must replace that static
choice without changing current behavior early.

## Evaluation, creation, and commit

Segments evaluate once from left to right, then the RHS evaluates once. Expression failures stop continuation and
propagate unchanged. Only after those evaluations does structural validation/building snapshot the binding and
operate on an isolated copy.

An absent root is created from the first valid selector. A missing nonfinal child is created from the next valid
selector. Bound null is present, not absent; existing wrong-kind values are never coerced. Arrays remain dense:
existing indexes may be replaced and index `length` may append, while a larger index fails without fillers.

Completed expression side effects follow ordinary language semantics. If a segment or RHS mutates the same root
binding, the outer write snapshots that post-evaluation value. Success composes its isolated path update onto that
state; a later structural failure leaves the post-evaluation state intact rather than rolling back an already
completed expression. Atomicity forbids only a partial structural path commit. The committed binding, returned
updated root, initial tree, and aggregate RHS are detached values.

## Diagnostics and exclusions

Syntax failures use exact `action_parse` diagnostics and authored Unicode-scalar spans. Structural failures use
`nested_write_segment_invalid`, `nested_write_kind_conflict`, or `nested_write_array_gap`, with the binding,
zero-based failing segment, detached valid prefix, typed authored segment span, and kind/gap fields. Precedence is
unchanged expression failure first, then the first invalid evaluated selector, then the first structural conflict
or dense-array gap.

Reads never create state. Scalar assignment, temporary/literal/helper/property roots, reserved runtime bindings,
an invented `vivify(...)` helper, and an invented `:=` operator are outside this contract.

Related: [[write-vivification-receiver-mutation-direction]], [[terse-nested-value-path-assignment]],
[[write-vivification-perl-reference]], [[write-vivification-rust-runtime]], [[uniform-binding-neutral-contract]],
[[write-map-leaves-neutral-composition]], and ADR `0036`.
