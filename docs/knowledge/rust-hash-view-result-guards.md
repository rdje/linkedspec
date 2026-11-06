---
id: rust-hash-view-result-guards
title: Rust Hash-view Array results own guards after the initial source policy
answers:
  - "why do Rust sorted_keys set_key operands still run"
  - "which Rust guard loops own ordinary Hash-view result composition"
  - "does Rust null sorted_values receiver retain empty Array with behavior"
  - "what is the independent Rust Hash-view source and arity profile"
date: 2026-11-06
status: Rust76.2 implemented with focused52/four-route22 proof; full admission separate
tags: [rust, hash, arrays, guards, sorted_keys, sorted_values]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.76.2; hash-view-result-guard-rust-2026-11-06/REVIEW.md retains shared15=8healthy7RED, separate own5+receiver2 profiles, unchanged22 normal15healthy7RED to22PASS and four-route22GREEN. Actual22 modules/serialized inputs and15 healthy observations remain exact; direct30/total52, scoped format and eight recovery controls pass."
reverify:
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -j 1 -p linkedspec-runtime --test hash_view_result_guard_composition --test value_copy --test constructor_result_composition -- --test-threads=1"
  - "bash tools/run_python_project_data.sh docs/checkpoints/hash-view-result-guard-rust-2026-11-06/review.py"
---

At clean55d7d7aa, public native/restored/generated-plan/compiled emitted shared15
has eight healthy/seven failures. Wrong Hash operands run: free views return the
original Array with KV; receiver views return null with KV. Later copy/with/logical
bodies execute. Actual serialized compiled actions contain canonical view sources
and typed set_key operands. engine.rs direct fluent and trailing-with source-role
lists omit views before their existing actual-kind/rejection guards.

Both paths now admit only canonical positional free-one/zero-extra view roles to
existing guards, keeping initial-source permission separate from produced Array
ownership before Count/CountKeys fallback. Unchanged22 normal15healthy7RED becomes
22PASS; actual compiled emitted22 GREEN. Fifteen healthy observations and actual22
module/serialized-input bytes stay exact. Direct constructor24/copy6 plus normal22
give52 focused tests; scoped format/eight recovery corruptions pass. Rebuild Rust
apps/runtime; no emitted-source regeneration or schema migration is required.

Own initial-source controls retain[] from initial Number/null/Array view receivers
and[1,2] from ordered Hash values. undef.sorted_values().with executes its valid
empty-Array body and yields[0,W]. Preserve that initial first-view producer policy
only when no prior result guard owns the source; guard the produced Array before
later Count/CountKeys fallback admission. Producers themselves are not the defect.

Rust malformed extra-argument profiles retain ran/AW, and the Array-source free
view yields[]; Perl's W/error profile does not apply. Seven source/arity controls
plus the required source-error wrapper are independently frozen from actual own
epochs. User-function receiver compatibility, source/context closure, complete
native/cache/transitive custody4.2 and general isolation/full23.4 remain separate.
Actual own grammar bytes, including compile-time user_function_definition.spec,
precede this leaf's Cargo build; earlier missing grammar edges stay4.2-owned.

P1 follow-up76.6 separately owns the missing initial-receiver policy comparison in
earlier Perl76.1 coverage, before Dart76.3. No Perl regression or cross-backend input
policy is inferred from Rust observations. Current frontier is MEMORY.md.
