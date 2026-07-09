# linkedspec_dart

Repository-owned Dart backend scaffold for LinkedSpec parity work.

This package is intentionally minimal. It establishes the Dart package boundary,
public library entrypoint, CLI smoke entrypoint, corpus-runner entrypoint, and a
`package:test` smoke test before parser or runtime semantics land.

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

`DART-BACKEND-PARITY.1.3` owns manifest IO scaffolding. The corpus runner loads
and validates the manifest-backed corpus directory, including missing/stale
fixture-directory detection and required fixture-file checks. Parser, compiler,
runtime, tracing, and corpus parity remain later leaves in
`docs/tasks/DART-BACKEND-PARITY.md`.
