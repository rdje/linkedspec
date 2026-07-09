# linkedspec_dart

Repository-owned Dart backend scaffold for LinkedSpec parity work.

This package is intentionally staged. It establishes the Dart package boundary,
public library entrypoint, CLI smoke entrypoint, corpus-runner entrypoint,
manifest IO scaffold, source-level AST/data types, and `package:test` coverage
before parser or runtime semantics land.

## Commands

Run from this directory:

```sh
dart pub get
dart format --set-exit-if-changed .
dart analyze --fatal-infos --fatal-warnings
dart test
dart run bin/linkedspec_dart.dart --help
dart run bin/corpus_runner.dart --help
dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus
```

## Status

`DART-BACKEND-PARITY.2.1` owns the source-level AST/data types. The package can
round-trip parsed `.spec` structures and staged parse-job sidecars through JSON,
and the corpus runner loads and validates the manifest-backed corpus directory.
Parser, compiler, runtime, tracing, and corpus parity remain later leaves in
`docs/tasks/DART-BACKEND-PARITY.md`.
