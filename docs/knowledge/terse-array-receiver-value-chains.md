---
id: terse-array-receiver-value-chains
title: Pure receiver chains and scalar result contracts
answers:
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
status: ordinary Perl/Rust/Dart/Julia count/length results implemented; other backend assessment/admission open
tags: [spec-format-terse, method-chaining, receiver-dot, array, actionir, rust-parity, oracle, mdbook]
evidence: "Pure chains2.3.5.1; end results12.1.1-.6; transforms5.3.1-.3; selected23.3.1; Rust copy23.3.2.3; count/length contract23.2.2."
reverify:
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test count_length_receivers --test receiver_copy_arity --test selected_value_receivers"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/count_length_receiver_contract.t"
---

Pure array chains compose existing helpers: items.sorted().drop_front(2).first(),
items.uniq().join_values(","), items.filter_match(/^a$/).count() and split_each/filter/count.
join_values keeps its delimiter-first free-helper argument order. End mutations
retain [[uniform-binding-array-end-result-supersession]]. Rust/Dart/Julia5.3.1-.3
implement standalone transforms using validated snapshots and ordered operands;
value/receiver forms stay pure and broad5.3.4 remains open.

23.3.1 implements first/last actual-value continuations through compatible pure
scalar/number/array/harray methods on all five ordinary backends. Runtime kind
selects generic copy; min/max distinguish scalar from zero-extra array form.
Focused fixtures retain snapshots and once-only effects. The full bounded
contract/status lives in docs/checkpoints/type-operation-inventory/selected-values.md; Lua checks use PUC5.5.1/LuaJIT,
with declared5.4/full admission open.

Rust23.3.2.3 rejects copy extra arguments before effects. Public controls retain
Perl/Rust scalar/missing empty-array fallback; Perl nested references remain shared
([[perl-scalar-bound-receiver-copy]]). The book qualifies copy domains/depths.

23.2.2 freezes ordinary count/count_keys/length result flow. Perl23.3.3.1 reuses
selected-value dispatch, retaining the separate deferred evaluator. Rust23.3.3.2
uses is_selected_receiver_result_method across static/dynamic loops and allows
length within array pipelines while preserving initial string/scalar dispatch.
Zero-extra shapes reject before effects. Focused native/fresh/restored/generated-
plan fixtures retain values, Unicode, once-only order and later-mutation snapshots.
The earlier Perl hash-chain host failure was result flow; free count_keys worked.
docs/checkpoints/type-operation-inventory/count-length-results.md owns status.
Dart23.3.3.3/Julia23.3.3.4 preserve dynamic flow and guard arity; [[dart-runtime-array-helpers]]/[[julia-runtime-array-helpers]] own count-domain repairs. Lua/full admission stay open.
