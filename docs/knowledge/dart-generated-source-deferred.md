---
id: dart-generated-source-deferred
title: Dart generated source has exact ten-family direct execution; manifest admission remains
answers:
  - "does Dart generated source exist now"
  - "what did DART-BACKEND-PARITY.7.2 decide"
  - "why was generated Dart source deferred"
  - "what must the Dart source emitter still prove"
  - "is generated Dart source required for Dart parity"
  - "how does Dart embed Unicode generated spec state"
  - "where is the Dart generated-source compile run harness"
date: 2026-07-11
status: current
tags: [dart, codegen, source-emitter, corpus, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.7.2 deferred codegen; ADR 0023 later required it. FUTURE-PARITY-BACKLOG.3.3.1 adds deterministic public v1 emission/isolation. .3.3.2 adds generated_plan.dart, exact ten-family classification/rows, four plan rejections, typed per-rule structural routing in interpreter.dart, three portable trace roles, and one isolated offline package compiling/running every family against interpreter values. Focused 5/5 and complete Dart 180 tests, 61x2 CLI, and 105/105 corpus pass. .3.3.3 manifest admission remains."
reverify: "cd dart && dart test test/source_emitter_test.dart && dart analyze --fatal-infos --fatal-warnings && rg -n 'FUTURE-PARITY-BACKLOG\\.3\\.3|emitDartSourceV1|_compiledSpecJsonBase64|PUB_CACHE' ../docs/tasks/FUTURE-PARITY-BACKLOG.md lib/src/source_emitter.dart test/source_emitter_test.dart"
---

Generated Dart source now exists as a public scaffold. It was not required for
the scoped interpreter-corpus claim, green at 105/105, but ADR `0023` requires
it for complete public capability parity because Rust exports source emission.

`DART-BACKEND-PARITY.7.2` deliberately deferred generated Dart source. The later
implementation split under `FUTURE-PARITY-BACKLOG.3.3` now has:

- `.3.3.1` done: compatibility/v1 emitters, metadata/errors, deterministic
  effective-state emission, and isolated caller-package compile/run;
- `.3.3.2` done: exact generated family-plan metadata, four-way validation,
  portable trace roles, and direct execution for every structural family;
- `.3.3.3` pending: curated manifest-backed admission after interpreter-first
  exact comparison.

The scaffold reconstructs a normalized `SpecFile` from effective ordered
`CompiledSpec` functions/rules. The generated Dart library is Unicode source;
its embedded normalized JSON is encoded as strict UTF-8 then Base64. Unicode is
the character model, while UTF-8 is the selected byte encoding at this
boundary; UTF-16 and UTF-32 are other Unicode encodings, not invalid Unicode.

`DART-BACKEND-PARITY.7.5` closed the scoped interpreter-first Dart milestone
without claiming generated-source parity. The closed Dart tree has no active
frontier; remaining source-generation proof is owned by active global
`FUTURE-PARITY-BACKLOG.3.3.3`. Capability status remains gap until admission.

Related facts: [[user-observable-backend-cli-parity-contract]],
[[dart-backend-interpreter-first-plan]], [[rust-source-emitter-lane-split]],
[[rust-generated-source-corpus-subset]], [[dart-mdbook-usage-status]].
