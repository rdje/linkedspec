---
id: dart-specific-cli
title: Dart backend CLI entrypoint and corpus command
answers:
  - how do I run the Dart backend CLI
  - what is the Dart-specific LinkedSpec CLI
  - how does Dart run the corpus from the CLI
  - what did DART-BACKEND-PARITY.7.4 implement
  - does corpus_runner still exist after the Dart CLI
date: 2026-07-09
status: current
tags: [dart, cli, corpus, runtime, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.7.4 adds dart/lib/src/cli/linkedspec_dart_cli.dart, routes dart/bin/linkedspec_dart.dart through it, and keeps dart/bin/corpus_runner.dart as a compatibility wrapper over the same manifest-backed command implementation. dart/test/corpus_manifest_test.dart covers Dart-specific CLI help text and selected corpus execution; tools/run_dart_local.sh now includes a bounded Dart-specific CLI corpus smoke and passes with 140 Dart tests plus full 99-fixture corpus execution."
reverify: "cd dart && dart run bin/linkedspec_dart.dart --help && dart run bin/linkedspec_dart.dart corpus --corpus ../rust/linkedspec-runtime/tests/corpus --execute --limit 1 && dart run bin/corpus_runner.dart --help && cd .. && bash tools/run_dart_local.sh"
---

The Dart backend CLI is:

```sh
cd dart
dart run bin/linkedspec_dart.dart --help
dart run bin/linkedspec_dart.dart corpus --corpus ../rust/linkedspec-runtime/tests/corpus --execute
```

The `corpus` command validates or executes the manifest-backed corpus through
the Dart parser, compiler, and runtime. It accepts `--case`, `--offset`, and
`--limit` selectors for diagnostics; without a selector, `--execute` runs the
full manifest in order.

`dart/bin/corpus_runner.dart` remains available as a corpus-focused
compatibility wrapper, but it delegates to the same shared CLI implementation as
`linkedspec_dart.dart`. Do not treat it as a separate contract owner.

Related facts: [[variant-specific-cli-requirement]], [[dart-controlled-corpus-execution]].
