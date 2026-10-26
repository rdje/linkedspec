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
  - "what contract lets numeric reducer results feed scalar methods"
  - "are array numeric reducers terminal receiver methods"
  - "are sum and avg number receiver methods"
  - "what did SPEC-FORMAT-TERSE.7.3 backfill"
  - "which task follows SPEC-FORMAT-TERSE.7.3"
date: 2026-10-26
status: ordinary result contract frozen; Perl implementation next
tags: [spec-format-terse, method-chaining, receiver-dot, array, number, reducers, actionir, rust-parity, oracle, mdbook]
evidence: "Historical reducer7.3; contract TYPE23.2.3 distinguishes six stopped Perl chains from working nested controls."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_reducer_results.pl"
---

Historical7.3 adds array sum/avg/median/range/min/max receiver forms after compatible array pipelines, with blanket terminal policy. Exact historical evidence and broad replay commands remain in this card at Git80d9809216282d1f077e1eac1b302cd608f75ae9; do not replay them for ordinary feature work.

TYPE23.2.3 freezes ordinary reducer results feeding existing compatible scalar/number methods. Public Perl Get returns [null,13,null,5,null,5,null,5,null,3,null,7] for six fluent/nested addition pairs; substitution emits return undef. MethodLowering preflight and array return-family classification stop the results. Perl implementation23.3.4.1 follows. Contract: docs/checkpoints/type-operation-inventory/aggregate-numeric-results.md.

Preserve zero-extra aggregate forms and scalar min/max overloads, actual values, source/operand order and snapshots. No scalar sum, new source domain, callback/deferred or complete admission is implied. Older incompatible array-consumer controls remain invalid by their helper domains. Ordinary Count/Length already continues under23.3.3; only earlier blanket terminal policy for compatible reducer consumers is advanced here.

Rust September reading3.3.21 distinguishes min/max scalar_numeric_value validation from sum/avg/median/range generic as_number filtering; Perl checks all decimal spellings. Selected numeric-string result kinds/Boolean inputs remain [[perl-numeric-reducer-string-result-kinds]], startup95. [[rust-array-slice-boundary-panics]] retains source slicing repair60. No such repair is claimed by result continuation.
