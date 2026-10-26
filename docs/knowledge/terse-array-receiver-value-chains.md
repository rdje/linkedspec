---
id: terse-array-receiver-value-chains
title: Pure receiver chains and result contracts
answers:
  - "can Rust emptiness results continue through scalar methods and retain copied Hash kinds"
  - "can index_of results continue into numeric methods"
  - "can join_values results continue into String methods or split back to Array"
  - "can count length and count_keys results continue into numeric methods"
  - "why can Rust array pipelines use length without changing initial string dispatch"
  - "why does a chained count_keys addition reach a host call on Perl"
  - "does Rust receiver copy reject extra arguments before effects"
  - "does Rust receiver copy preserve scalar or missing values"
  - "can first or last continue through selected string methods"
  - "can copy preserve selected array or harray values"
  - "why do Rust standalone split_each filter_match and uniq update arrays"
  - "how do array receiver-dot value chains work"
  - "does items.sorted().drop_front().first() work"
  - "does items.uniq().join_values work"
  - "does items.filter_match().count work"
  - "does split_each flatten in receiver-dot array chains"
  - "does items.join_values keep delimiter first"
  - "are push_back and pop_back value-returning after SPEC-FORMAT-TERSE.2.3.5.1"
  - "which task follows SPEC-FORMAT-TERSE.2.3.5.1"
date: 2026-10-26
status: bounded index/Perl-Rust emptiness checked; full admission open
tags: [spec-format-terse, method-chaining, receiver-dot, array, actionir, rust-parity, oracle, mdbook]
evidence: "Pure/end/transform contracts; selected/scalar rollout23.3; index contract23.2.6 and bounded23.3.7.1-.5."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/index_result_receiver_contract.t"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test emptiness_result_receivers --test has_key_result_receivers"
---

Pure Array chains compose existing helpers: sorted/drop_front/first, uniq/join_values, filter_match/count and split_each/filter/count. join_values keeps delimiter-first free-helper roles. End mutations retain [[uniform-binding-array-end-result-supersession]]. Rust/Dart/Julia5.3.1-.3 implement dropped transforms with validated snapshots/ordered operands; pure value forms stay pure and broad5.3.4 stays open.

23.3.1 enables ordinary first/last continuations by actual String/Number/Array/Harray kind on five backends; copy/min/max dispatch by kind/arity. Scope/snapshots/effects: docs/checkpoints/type-operation-inventory/selected-values.md. Lua uses available5.5.1/JIT; declared5.4/full admission remain open.

Rust copy23.3.2.3 guards extras. Perl/Rust scalar/missing copy fallback stays []; Perl nested refs remain shared ([[perl-scalar-bound-receiver-copy]]).

Count/Length/join/index23.3.3/.5/.7 bounded flow/shape guards pass on recorded hosts; contracts: docs/checkpoints/type-operation-inventory/count-length-results.md, joined-string-results.md and index-results.md. Preserve producer/equality/source/copy and explicit bridges. Current full prior details/commands remain exact at Git61dd294d9394cfffc52abf0648a3c0530ecfd91a for this path; earlier join history at Git05cd2f8074894f012d56c3410e9366eb67dd2f97. Full admission remains open.

Emptiness23.3.9.2 preserves Rust Bool outputs/RuntimeValue::is_nonempty domains and adds scalar-result/zero-operand guards plus generic evaluated-value dispatch at initial/family-prefix/selected positions. Copy before a generic predicate must retain actual kind: static Array inference gave copied Hash1! versus0!. Native/restored/plan result/direct has_key tests pass after null/S/four-effect and copied-Hash RED, with actual source/copy kinds, false retention/repeated predicates/bridges/scalar nulls and1!/SA/once-only snapshots. Dart3 guards checked ([[dart-runtime-array-helpers]]); Julia4 guards checked ([[julia-runtime-array-helpers]]); Lua5/full admission open; bounded Perl details: [[perl-emptiness-expression-and-host-slot-drift]].
