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
```

## Status

`DART-BACKEND-PARITY.1.2` owns this scaffold. Manifest IO begins in
`DART-BACKEND-PARITY.1.3`; parser, compiler, runtime, tracing, and corpus parity
remain later leaves in `docs/tasks/DART-BACKEND-PARITY.md`.
