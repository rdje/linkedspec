---
id: dart-specific-cli
title: Dart primary parser CLI and separate corpus runner
answers:
  - how do I run the Dart backend CLI
  - what is the Dart-specific LinkedSpec CLI
  - how does Dart run the corpus from the CLI
  - what did DART-BACKEND-PARITY.7.4 implement
  - does corpus_runner still exist after the Dart CLI
date: 2026-07-09
status: current
tags: [dart, cli, corpus, runtime, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.7.4 created the historical corpus-oriented primary command; FUTURE-PARITY-BACKLOG.1.5.3.1 replaces that boundary with the shared parser interface and leaves dart/bin/corpus_runner.dart as the separate corpus owner."
reverify: "cd dart && dart run bin/linkedspec_dart.dart --help && dart run bin/corpus_runner.dart --help && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --limit 1 && cd .. && bash tools/run_dart_local.sh"
---

The Dart primary backend CLI is:

```sh
cd dart
dart run bin/linkedspec_dart.dart --help
```

It exposes the exact shared parser-oriented options and rejects corpus subcommands.
`.1.5.3.4` closes native direct execution/canonical JSON plus the independent
canonical trace protocol at recurring 61/61 default/POSIX. Rule-local cursor
`.9.1.5.5` removes the global mode flag/trace field and advances the current
shared command to 63/63 in both environments.

`dart/bin/corpus_runner.dart` is the separate corpus-focused command. It retains
`--corpus`, `--execute`, `--case`, `--offset`, and `--limit`; without a selector,
`--execute` runs the full manifest in order.

The earlier `DART-BACKEND-PARITY.7.4` corpus-primary arrangement is historical;
`.1.5.3.1` performs the replacement without removing the developer workflow.

Related facts: [[variant-specific-cli-requirement]], [[dart-controlled-corpus-execution]],
[[dart-scoped-parity-milestone-complete]], [[dart-primary-cli-mechanism-audit]],
[[dart-primary-cli-boundary]], [[dart-primary-cli-native-execution-canonical-json]],
[[dart-canonical-primary-cli-trace]], [[dart-primary-cli-closeout]].
