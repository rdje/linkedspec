---
id: dart-backend-scaffold-package
title: Dart backend scaffold package lives under dart/ and is smoke-tested only
answers:
  - where is the Dart backend package
  - how do I run the Dart backend scaffold checks
  - what does the Dart scaffold implement so far
  - does the Dart package implement parser or runtime semantics yet
  - is pubspec.lock committed for the Dart backend
date: 2026-07-09
status: current
tags: [dart, backends, package, scaffold, tests]
evidence: "DART-BACKEND-PARITY.1.2 creates dart/pubspec.yaml, dart/pubspec.lock, dart/lib/linkedspec_dart.dart, dart/bin/linkedspec_dart.dart, dart/bin/corpus_runner.dart, and dart/test/smoke_test.dart; docs/tasks/DART-BACKEND-PARITY.md records the accepted scaffold boundary."
reverify: "git ls-files dart && (cd dart && dart format --set-exit-if-changed . && dart analyze --fatal-infos --fatal-warnings && dart test && dart run bin/linkedspec_dart.dart --help && dart run bin/corpus_runner.dart --help)"
---

The Dart backend scaffold is the repo-owned package under `dart/`. It currently provides package
metadata, a committed `pubspec.lock`, analyzer options, a package README, public scaffold API,
`bin/linkedspec_dart.dart`, `bin/corpus_runner.dart`, and a `package:test` smoke test.

This is scaffold only. It does not implement `.spec` parsing, compiled-spec state, runtime semantics,
manifest IO, or corpus parity yet. `DART-BACKEND-PARITY.1.3` adds manifest/corpus IO scaffolding next.

Related facts: [[dart-backend-interpreter-first-plan]], [[text-to-ast-backend-doctrine]],
[[rust-perl-output-oracle]].
