---
id: rust-single-index-read-bypasses-typed-binding
title: "Rust indexed reads preserve typed bindings and support signed array positions"
answers:
  - "why does Rust items[0] return null after items is assigned an array"
  - "why does an indexed Rust hash key become an empty string"
  - "why does Rust items.first work while items[0] fails"
  - "which task owns the Rust IndexedVar typed-binding repair"
  - "do Rust array index reads observe rebinding and saved array snapshots"
  - "why does Rust items[-1] return its first entry"
  - "which existing Rust negative index coercion test must the signed transition replace"
date: "2026-10-25"
status: "signed implementation; portable admission remains child17.7"
tags: [rust, bindings, arrays, indexed-read, hash, SESSION-STARTUP-READING]
evidence: "Startup88 and intake17.0 remain dated evidence. TYPE-REFERENCE-BOOK.1.2.17.3 retains complete old/new Rust sources, actual native/emitted executables, raw diagnostic channels, independent target readers and explicit existing read-order/coercion controls under docs/checkpoints/signed-array-rust/."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test signed_array_selector_contract; dated evidence: bash tools/run_python_project_data.sh docs/checkpoints/signed-array-rust/publish.py"
---

# Rust indexed reads

`IndexedVar` resolves the current typed array binding after evaluating its selector.
The older startup88 repair replaced a private-array-map read that missed scalar-held
arrays: `items=["a"]; items[0]` returned null and a computed harray key became empty.
Assignment, set, append, split and rebinding now observe the typed value; stale private
storage cannot override it. Missing/non-array reads are pure Undef. Saved snapshots
are detached. The public positive example is `examples/indexed-value-reads.spec`.

Signed child17.3 routes both single and nested/value-result array reads through
`array_selector_value`: a supported finite whole negative number selects `length+index`
only within the existing array, otherwise Undef. `[-1]` selects the last entry.
Single-index receiver lookup still follows selector effects; nested/value access retains
its earlier receiver snapshot. Fractions, evaluated strings, null and other unrelated
coercions retain their existing Rust behavior. Explicit quoted key access stays a key.
Rust's `f64` model does not distinguish `-1` from `-1.0` as selector kinds.

The original intake calibration `[-2,10,10,10,10]` described the old negative-to-usize
cast, including underflow selecting element0. Its 32 sources, actual CLI binary and
trace remain immutable. The permanent coercion test now expects tail selection for
negative integers while preserving its fractional/string/undefined controls. Rebuild
saved/emitted parsers after runtime updates. Portable signed admission remains17.7;
Perl grouped postfix remains startup87.4, with no AST format change here.

Exact former card and all startup88/intake reading details:
`git show 691d2d87690ce3f9052c1d032a3e862ee5d76211:docs/knowledge/rust-single-index-read-bypasses-typed-binding.md`.
That card points to the complete startup88 record at92c98fb3de0f8392abde59043bd6f67ba0199452,
including its seventeen source pairs, five unchanged controls and runtime/emitted/book
proof. Those historical counts are not new reruns.

Related: [[uniform-binding-neutral-contract]], [[terse-rust-duck-typed-assignment-parity]],
[[write-vivification-rust-runtime]], [[rust-hash-separator-and-cat-arity-defects]].
