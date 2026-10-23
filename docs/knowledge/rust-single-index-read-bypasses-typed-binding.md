---
id: rust-single-index-read-bypasses-typed-binding
title: "Rust single-index reads use current typed array bindings after startup .88"
answers:
  - "why does Rust items[0] return null after items is assigned an array"
  - "why does an indexed Rust hash key become an empty string"
  - "why does Rust items.first work while items[0] fails"
  - "which task owns the Rust IndexedVar typed-binding repair"
  - "do Rust array index reads observe rebinding and saved array snapshots"
  - "why does Rust items[-1] return its first entry"
  - "which existing Rust negative index coercion test must the signed transition replace"
date: "2026-10-23"
status: "typed-binding repair preserved; legacy negative coercion awaits signed child17.3"
tags: [rust, bindings, arrays, indexed-read, hash, SESSION-STARTUP-READING]
evidence: "Original startup88 sources, seventeen before/after pairs, binary identities and complete dated proof remain retained; full original card: git show 92c98fb3de0f8392abde59043bd6f67ba0199452:docs/knowledge/rust-single-index-read-bypasses-typed-binding.md. Intake17.0 retains32 native sources, the actual Rust CLI binary and a direct negative-value/index calibration. No new portable selector admission."
reverify: "Dated source-bound intake: bash tools/run_python_project_data.sh docs/checkpoints/signed-array-selectors/review.py. No current signed-policy admission."
---

# Rust indexed reads: typed bindings and pending signed selectors

Before startup .88, `IndexedVar` read the private array map while ordinary
assignment stored the typed value in the scalar map. Consequently `items=["a"];
return(items[0])` returned null, and an indexed value used as a computed hash key
became an empty string. Bare binding and `first()` controls agreed with Perl.

The .88 repair reads `ctx.get_bare_value(name)` and selects a cloned element from
that current typed array. It observes assignment, set, append, split and later
rebinding; stale private storage cannot override the value. Missing/non-array
reads return Undef and create no state. The index expression still runs before
the binding is resolved. Saved binding snapshots remain detached.

The original17-source before/after proof, five unchanged controls, complete
runtime/emitted/book checks, command recipes, binary identities and historical
counts remain unchanged in the startup88 checkpoints. The complete original
card is `git show 92c98fb3de0f8392abde59043bd6f67ba0199452:docs/knowledge/rust-single-index-read-bypasses-typed-binding.md`.
The positive public example remains `examples/indexed-value-reads.spec`.
Rust grouped receiver access was a separate control; Perl grouped postfix
remains separately owned by startup .87.4. No AST or serialized format changed.

## October23 signed-index intake

The retained public calibration returns `[-2,10,10,10,10]`: the variable remains
negative, but negative selectors, including underflow, select element0.
`IndexedVar` and `eval_access_value` convert evaluated numbers to `usize`.
The existing `indexed_var_preserves_existing_read_index_coercion` test explicitly
expects the first entry for -1. Its fractional, numeric-string, nonnumeric and
undefined controls are existing Rust behavior, not a portable read policy.

TYPE-REFERENCE-BOOK.1.2.17.3 owns replacing that negative behavior under the
director's in-range tail rule, preserving unrelated coercion scope and the
original evidence. Intake17.0 retains the source, actual CLI binary, full trace
and native outcomes; it admits no signed support. Regenerate/rebuild emitted
parsers after a runtime repair.

Related: [[uniform-binding-neutral-contract]],
[[terse-rust-duck-typed-assignment-parity]],
[[rust-hash-separator-and-cat-arity-defects]].
