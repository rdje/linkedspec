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
  - "what does DART-BACKEND-PARITY.6.2.2 prove"
  - "what does DART-BACKEND-PARITY.6.2.3 prove"
  - "what does DART-BACKEND-PARITY.6.2.4.0 prove"
  - "what does DART-BACKEND-PARITY.6.2.5 prove"
  - "what does DART-BACKEND-PARITY.6.3 prove"
  - "is the Dart corpus runner full 99-fixture parity yet"
date: 2026-07-09
status: current
tags: [dart, corpus, runtime, parity, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.1 adds executeCorpusFixtures plus CorpusExecutionResult and CorpusFixtureExecutionResult in dart/lib/src/corpus/manifest_runner.dart. DART-BACKEND-PARITY.6.2.1 adds caseNames/offset/limit selection to executeCorpusFixtures and opt-in bin/corpus_runner.dart --execute mode with --case/--offset/--limit. DART-BACKEND-PARITY.6.2.2 proves the first 40 shipped manifest fixtures green with `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --limit 40`. DART-BACKEND-PARITY.6.2.3 proves the non-fn middle helper/control/receiver fixtures green and routes three top-level fn fixtures to .6.2.5. DART-BACKEND-PARITY.6.2.4.0 measures the final shipped-spec/parser-smoke window at 2/31 green and splits the known failure clusters before implementation. DART-BACKEND-PARITY.6.2.5 routes the three top-level fn fixtures through specs/user_function_definition.spec and staged projection without a Dart raw scanner; the routed three-fixture corpus run passes. DART-BACKEND-PARITY.6.3 enables unbounded CLI --execute and proves the checked-in 99-fixture corpus green with 99 passed / 0 failed. test/corpus_manifest_test.dart locks scalar output, nested array/hash/null/boolean output, blind rule dispatch, lifecycle output shape, mismatch reporting, named/bounded selection, CLI selected execution, CLI full-manifest execution, unsupported manifest format rejection, invalid/duplicate case-name rejection, count mismatch, missing fixture dirs, stale extra dirs, and missing required fixture files."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/corpus_manifest_test.dart && bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
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
`--case`, `--offset`, and `--limit`; without a selector it runs the full
manifest in order.

`DART-BACKEND-PARITY.6.2.2` proves the first 40 shipped manifest fixtures green
through bounded execute mode. This is a starter corpus-batch proof, not full
99-fixture parity.

`DART-BACKEND-PARITY.6.2.3` proves the non-`fn` middle helper/control/receiver
fixtures green and routes the three top-level `fn` fixtures to a spec-defined
function-shell follow-up.

`DART-BACKEND-PARITY.6.2.4.0` measures the final shipped-spec/parser-smoke
window and splits it by failure cluster before implementation.

`DART-BACKEND-PARITY.6.2.5` proves the routed top-level `fn` fixtures green by
obtaining `function_definition` nodes from `specs/user_function_definition.spec`
and feeding them through staged function-body projection.

`DART-BACKEND-PARITY.6.3` proves full checked-in Dart corpus parity: the current
99-fixture manifest runs through Dart parse/compile/runtime execution with 99
passed and 0 failed. The same slice locks unsupported manifest formats, invalid
or duplicate case names, count drift, directory drift, missing files, output
mismatches, selected CLI execution, and full-manifest CLI execution.

`DART-BACKEND-PARITY.6.1` proved execution with controlled temporary fixtures.
`DART-BACKEND-PARITY.6.4` then wires that green corpus gate into the focused
Dart local verification script and optional local-CI path.

Related facts: [[dart-backend-scaffold-package]],
[[dart-runtime-rule-interpreter]], [[dart-starter-corpus-batch]],
[[dart-middle-corpus-batch]], [[dart-shipped-corpus-smoke-split]],
[[dart-staged-function-descriptor-shape]], [[rust-perl-output-oracle]].
