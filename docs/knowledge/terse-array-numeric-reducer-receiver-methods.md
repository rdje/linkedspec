---
id: terse-array-numeric-reducer-receiver-methods
title: SPEC-FORMAT-TERSE.7.3 array numeric reducer receiver methods
answers:
  - "does scores.sum() work"
  - "does scores.avg() work"
  - "does scores.median() work"
  - "does scores.range() work"
  - "does scores.min() work on arrays"
  - "does scores.max() work on arrays"
  - "why does Rust empty Array sum return zero while invalid filtered sources remain null"
  - "why do Perl reducer results reject array methods until an explicit split bridge"
  - "what contract lets numeric reducer results feed scalar methods"
  - "are array numeric reducers terminal receiver methods"
  - "are sum and avg number receiver methods"
  - "what did SPEC-FORMAT-TERSE.7.3 backfill"
  - "which task follows SPEC-FORMAT-TERSE.7.3"
date: 2026-10-26
status: ordinary Perl/Rust/Dart reducer results implemented; other backend assessment open
tags: [spec-format-terse, method-chaining, receiver-dot, array, number, reducers, actionir, rust-parity, oracle, mdbook]
evidence: "Historical reducer7.3; contract TYPE23.2.3 distinguishes six stopped Perl chains from working nested controls."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/aggregate_numeric_receiver_contract.t t/count_length_receiver_contract.t"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test aggregate_numeric_receivers --test count_length_receivers"
---

Historical7.3 adds array sum/avg/median/range/min/max receiver forms after compatible array pipelines, with blanket terminal policy. Exact historical evidence and broad replay commands remain in this card at Git80d9809216282d1f077e1eac1b302cd608f75ae9; do not replay them for ordinary feature work.

TYPE23.2.3 freezes ordinary reducers feeding existing scalar/number methods. Contract: docs/checkpoints/type-operation-inventory/aggregate-numeric-results.md. Perl23.3.4.1 uses scalar_result flow in the selected dispatcher until an explicit split returns an Array; initial zero-extra min/max uses Array dispatch, scalar overloads keep operands. Generic handoff initially exposed array fallback; retained incompatible nulls now pass. Native/fresh and direct Count/Length checks pass.

Dart23.3.4.3 preserves correct result flow/empty identity, guards canonical aggregate extras and shares ordinary/mutating-source value iteration with scalar boundaries. [[dart-runtime-array-helpers]] owns its current proof.

Preserve zero-extra aggregate forms and scalar min/max overloads, actual values, source/operand order and snapshots. No scalar sum, new source domain, callback/deferred or complete admission is implied. Older incompatible array-consumer controls remain invalid by their helper domains. Ordinary Count/Length already continues under23.3.3; only earlier blanket terminal policy for compatible reducer consumers is advanced here.

Rust September reading3.3.21 distinguishes min/max scalar_numeric_value validation from sum/avg/median/range generic as_number filtering; Perl checks all decimal spellings. Selected numeric-string result kinds/Boolean inputs remain [[perl-numeric-reducer-string-result-kinds]], startup95. [[rust-array-slice-boundary-panics]] retains source slicing repair60. No such repair is claimed by result continuation.

Rust23.3.4.2 shares reducer handoff/endpoint exemptions and guards zero-extra sum/avg/median/range. Scalar consumer checks persist until a helper returns a container. Public free-helper RED isolates empty Array sum: the shared numeric arm rejected all empty term lists; return0 only for actual empty sum, leaving nonempty filtering untouched. Native/restored/generated-plan and direct Count/Length fixtures pass after RED; callable vocabulary and full admission stay separate.
