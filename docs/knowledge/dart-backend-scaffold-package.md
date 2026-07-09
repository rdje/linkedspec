---
id: dart-backend-scaffold-package
title: Dart backend scaffold package lives under dart/ and includes manifest IO only
answers:
  - where is the Dart backend package
  - how do I run the Dart backend scaffold checks
  - what does the Dart scaffold implement so far
  - how does the Dart corpus runner validate the manifest
  - does the Dart package implement parser or runtime semantics yet
  - is pubspec.lock committed for the Dart backend
date: 2026-07-09
status: current
tags: [dart, backends, package, scaffold, corpus, tests]
evidence: "DART-BACKEND-PARITY.1.2 creates the Dart package scaffold; DART-BACKEND-PARITY.1.3 adds dart/lib/src/corpus/manifest_runner.dart, dart/test/corpus_manifest_test.dart, and a --corpus CLI load path that validates the 99-fixture manifest without parser/runtime execution."
reverify: "git ls-files dart && (cd dart && dart format --set-exit-if-changed . && dart analyze --fatal-infos --fatal-warnings && dart test && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus)"
---

The Dart backend scaffold is the repo-owned package under `dart/`. It currently provides package
metadata, a committed `pubspec.lock`, analyzer options, a package README, public scaffold API,
`bin/linkedspec_dart.dart`, `bin/corpus_runner.dart`, corpus manifest IO, and `package:test` smoke tests.

The corpus IO layer loads the checked-in corpus under `rust/linkedspec-runtime/tests/corpus/`, validates
manifest format/count/name shape, detects missing or stale fixture directories, requires `input.spec`,
`input.txt`, and `expected.json`, and parses expected JSON.

This is still scaffold only. It does not implement `.spec` parsing, compiled-spec state, runtime semantics,
or corpus output comparison yet. `DART-BACKEND-PARITY.2.1` starts frontend AST/data types next.

Related facts: [[dart-backend-interpreter-first-plan]], [[text-to-ast-backend-doctrine]],
[[rust-perl-output-oracle]].
