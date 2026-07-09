---
id: dart-controlled-corpus-execution
title: Dart can execute controlled manifest corpus fixtures through parse, compile, and runtime
answers:
  - "does Dart execute corpus fixtures yet"
  - "how does Dart compare corpus expected.json"
  - "does Dart corpus execution use structural JSON equality"
  - "what does DART-BACKEND-PARITY.6.1 prove"
  - "is the Dart corpus runner full 99-fixture parity yet"
date: 2026-07-09
status: current
tags: [dart, corpus, runtime, parity, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.1 adds executeCorpusFixtures plus CorpusExecutionResult and CorpusFixtureExecutionResult in dart/lib/src/corpus/manifest_runner.dart. test/corpus_manifest_test.dart writes temporary manifest-backed fixtures that prove scalar output, nested array/hash/null/boolean output, blind rule dispatch, lifecycle output shape, and mismatch reporting through parseSpec, compileSpec, and LinkedSpecRuntimeEngine."
reverify: "cd dart && dart test test/corpus_manifest_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

The Dart executable corpus harness lives in
`dart/lib/src/corpus/manifest_runner.dart`.

`executeCorpusFixtures(...)` first reuses `loadCorpusFixtures(...)` so manifest
format, count, fixture directory drift, required files, and expected JSON syntax
are checked before execution. It then runs each fixture through `parseSpec(...)`,
`compileSpec(...)`, and `LinkedSpecRuntimeEngine`.

The comparison follows the backend-neutral corpus contract: `expected.json` is
the top-rule reference value, and Dart's engine output must equal `[expected]`.
The harness uses structural JSON equality for lists and maps and returns every
fixture result, so one failing fixture does not hide later failures.

`DART-BACKEND-PARITY.6.1` proves this with controlled temporary fixtures only.
The full shipped 99-fixture manifest expansion remains owned by
`DART-BACKEND-PARITY.6.2` and later `.6` leaves.

Related facts: [[dart-backend-scaffold-package]],
[[dart-runtime-rule-interpreter]], [[dart-staged-function-descriptor-shape]],
[[rust-perl-output-oracle]].
