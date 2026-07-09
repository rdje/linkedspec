---
id: dart-starter-corpus-batch
title: Dart starter corpus batch is green over the first 40 manifest fixtures
answers:
  - "does Dart pass the starter corpus batch"
  - "how many shipped corpus fixtures pass on Dart so far"
  - "does Dart treat empty aggregate returns as successful matches"
  - "does Dart execute marker-form if else endif chains"
  - "what does DART-BACKEND-PARITY.6.2.2 prove"
date: 2026-07-09
status: current
tags: [dart, corpus, runtime, parity, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.2 updates dart/lib/src/runtime/interpreter.dart so returned non-null empty arrays/hashes count as successful rule matches, blind child dispatch uses the child RuleResult.matched bit, and marker-form if/elseif/else/endif action chains execute as grouped branches. dart/test/runtime_interpreter_test.dart locks empty aggregate returns and marker-form branch execution. The bounded shipped-corpus proof `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --limit 40` passes."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --limit 40 && dart analyze --fatal-infos --fatal-warnings"
---

`DART-BACKEND-PARITY.6.2.2` is the first shipped-corpus expansion proof for
the Dart backend. It does not claim full 99-fixture parity; it proves the first
40 manifest fixtures execute green through the Dart parser, compiler, runtime,
and corpus harness.

Two runtime semantics were corrected:

- Empty aggregate outputs such as `copy(hash(...))` and `copy(array(...))` are
  valid non-null return values and therefore successful rule matches. Null /
  `return_undef` remains a non-match.
- Marker-form statement controls such as `if(false); ... else(); ... endif()`
  execute as one branch chain, including in value-block contexts.

Blind child dispatch also now trusts the child rule's `matched` bit instead of
recomputing success from returned value truthiness.

Related facts: [[dart-controlled-corpus-execution]],
[[dart-runtime-rule-interpreter]], [[dart-runtime-value-control-tree-helpers]],
[[rust-perl-output-oracle]].
