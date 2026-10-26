---
id: terse-array-receiver-value-chains
title: Pure receiver chains and scalar result contracts
answers:
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
status: bounded ordinary joined results targeted-checked; full admission open
tags: [spec-format-terse, method-chaining, receiver-dot, array, actionir, rust-parity, oracle, mdbook]
evidence: "Pure chains2.3.5.1; end results12.1.1-.6; transforms5.3.1-.3; selected23.3.1; Rust copy23.3.2.3; count/length23.2.2; join result contract23.2.4."
reverify:
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test joined_string_receivers --test aggregate_numeric_receivers"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/joined_string_receiver_contract.t t/aggregate_numeric_receiver_contract.t"
---

Pure Array chains compose existing helpers: sorted/drop_front/first, uniq/join_values, filter_match/count and split_each/filter/count. join_values keeps delimiter-first free-helper roles. End mutations retain [[uniform-binding-array-end-result-supersession]]. Rust/Dart/Julia5.3.1-.3 implement dropped transforms with validated snapshots/ordered operands; pure value forms stay pure and broad5.3.4 stays open.

23.3.1 enables ordinary first/last continuations by actual String/Number/Array/Harray kind on five backends; copy/min/max dispatch by kind/arity. Scope/snapshots/effects: docs/checkpoints/type-operation-inventory/selected-values.md. Lua uses available5.5.1/JIT; declared5.4/full admission remain open.

Rust copy23.3.2.3 guards extras. Perl/Rust scalar/missing copy fallback stays []; Perl nested refs remain shared ([[perl-scalar-bound-receiver-copy]]).

Count/Length23.3.3 is targeted-checked on recorded hosts. Perl selected dispatch leaves deferred evaluation unchanged; hash-chain lowering failed while free count_keys worked. Rust is_selected_receiver_result_method permits result handoff/local Array Length without altering initial String dispatch. Scope: docs/checkpoints/type-operation-inventory/count-length-results.md. Other mechanisms: [[dart-runtime-array-helpers]], [[julia-runtime-array-helpers]], [[lua-runtime-array-transform-pipelines]].

23.2.4 freezes joined String continuations: docs/checkpoints/type-operation-inventory/joined-string-results.md. At activation direct/selected chains stopped; hash-view raw DSL raised host sorted_values while nested helpers worked. Perl23.3.5.1 uses scalar_result handoff and exact one-delimiter preflight. Native/fresh and direct aggregate checks pass after RED, retaining Unicode, split/length bridges, SDAN snapshots, clean shapes and incompatible Array nulls. Rust23.3.5.2 uses is_scalar_result_receiver_method and guarded mutation tails after []-versus-null RED. Dart23.3.5.3/Julia23.3.5.4 guard existing flow ([[dart-runtime-array-helpers]], [[julia-runtime-array-helpers]]). Lua23.3.5.5 adds flow/guards and fixes false delimiters ([[lua-runtime-array-transform-pipelines]]). Focused checks pass; source normalization/declared5.4/full admission stay open.
