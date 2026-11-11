---
id: dart-callable-pipeline-result-guards
title: Dart function pipelines retain guards and complete available error wire fields
answers:
  - "why does Dart function trim_each set_key retain the Array and run Hash operands"
  - "which Dart predicate excludes registered callable pipeline result guards"
  - "does Dart callable pipeline repair preserve ignored excess free arguments"
  - "which Dart callable error source identity and stage fields are retained"
  - "were original Dart parsed inputs retained before compilation and restoration"
date: 2026-11-11
status: bounded callable79.6.3 implemented with focused checks; full admission separate
tags: [dart, functions, pipelines, guards, errors, source, custody]
evidence: "docs/checkpoints/array-pipeline-callable-dart-2026-11-11/REVIEW.md;194/four routes/private19RED-current194,16 supported targets/three separate compatibility changes/175 full-wire records preserved,388 pairs/776 normal inputs/seven trace inputs/direct383/first readonly17 controls/current497 identities. Four interpreter insertions/four deletions."
reverify:
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter expanded --concurrency=1 test/array_pipeline_callable_result_guard_composition_test.dart"
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P docs/checkpoints/array-pipeline-callable-dart-2026-11-11/review.py"
---

Independent194 questions find13 shared failures, two valid variadic compositions
and one invalid-range receiver result target. _isOrdinaryArrayPipelineResultChain
explicitly rejects registered sources before common actual-kind ownership. Four
insertions/four deletions allow only canonical first-pipeline prefixes while
keeping unregistered free-helper identity. Existing invocation/signature/producer
semantics and formats remain; wrong Hash consumers skip operands/later work while
preserving source S. Same-path old/current reproduces19RED/194PASS.

175 full records remain exact:42 terminal[]/42 first-with[0,W], excess free SKW
versus receiver SXKW, missing arguments, earlier owners, nested kinds, snapshots,
required errors and invalid fixed/rest signatures. Three noncanonical pattern
compositions are separate compatibility changes; original terminal P survives.
No new dynamic-pattern, callback, source or peer-policy authority follows.

New native/restored/generated-plan/fresh observation retains every available
RuntimeInterpreterException/GeneratedSourceException.toJson field, with actual
route-specific generated source identities. Parsed bytes persist/readback before
compile/restore; capture-mode normal does likewise. Default normal is semantic
proof without a new custody claim. Historical ordinary observer compiles/restores
before persistence; old omitted generated fields remain unknown. P1 audit4.24
covers inherited Rust/Dart claims before admission, with originals unchanged.

First readonly17 corruption controls/current497 identities pass; all388 actual
parsed/module pairs and776 normal/seven trace inputs remain recoverable without
running the latest SDK. Native/VM/cache/transitive/toolchain4.2/SESSION5 and broader
source/context/isolation/registration/declared5.4/full23.4 remain separate. Rebuild
Dart applications. Independent Julia79.6.4 follows clean landing.

Related: [[dart-array-pipeline-result-guards]], [[dart-callable-key-count-preservation]],
[[rust-callable-pipeline-result-guards]].
