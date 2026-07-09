---
id: dart-controlled-corpus-execution
title: Dart can execute selected manifest corpus fixtures through parse, compile, and runtime
answers:
  - "does Dart execute corpus fixtures yet"
  - "how does Dart compare corpus expected.json"
  - "does Dart corpus execution use structural JSON equality"
  - "how does Dart select corpus fixtures for execution"
  - "does the Dart corpus CLI prevent unbounded execution"
  - "what does DART-BACKEND-PARITY.6.1 prove"
  - "what does DART-BACKEND-PARITY.6.2.1 prove"
  - "is the Dart corpus runner full 99-fixture parity yet"
date: 2026-07-09
status: current
tags: [dart, corpus, runtime, parity, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.1 adds executeCorpusFixtures plus CorpusExecutionResult and CorpusFixtureExecutionResult in dart/lib/src/corpus/manifest_runner.dart. DART-BACKEND-PARITY.6.2.1 adds caseNames/offset/limit selection to executeCorpusFixtures and opt-in bin/corpus_runner.dart --execute mode with --case/--offset/--limit. test/corpus_manifest_test.dart writes temporary manifest-backed fixtures that prove scalar output, nested array/hash/null/boolean output, blind rule dispatch, lifecycle output shape, mismatch reporting, named/bounded selection, CLI selected execution, and unbounded CLI execute rejection."
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

`DART-BACKEND-PARITY.6.2.1` adds named and bounded selection. Library callers
can pass `caseNames`, `offset`, and `limit` to `executeCorpusFixtures(...)`.
The CLI exposes the same safe surface through opt-in `--execute` with repeated
`--case`, `--offset`, and `--limit`; unbounded CLI execution is rejected until
full corpus parity is ready.

`DART-BACKEND-PARITY.6.1` proved execution with controlled temporary fixtures.
The full shipped 99-fixture manifest expansion remains owned by
`DART-BACKEND-PARITY.6.2.2` and later `.6` leaves.

Related facts: [[dart-backend-scaffold-package]],
[[dart-runtime-rule-interpreter]], [[dart-staged-function-descriptor-shape]],
[[rust-perl-output-oracle]].
