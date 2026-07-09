# linkedspec_dart

Repository-owned Dart backend scaffold for LinkedSpec parity work.

This package is intentionally staged. It establishes the Dart package boundary,
public library entrypoint, CLI smoke entrypoint, corpus-runner entrypoint,
manifest IO scaffold, source-level AST/data types, a core `.spec` rule parser,
and `package:test` coverage before validation or runtime semantics land.

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

`DART-BACKEND-PARITY.2.2` owns the core `.spec` rule parser. The package can
round-trip parsed `.spec` structures and staged parse-job sidecars through JSON,
parse rule paragraphs into source AST types, and load/validate the
manifest-backed corpus directory. Strict validation, function-definition shell
integration, compiler, runtime, tracing, and corpus parity remain later leaves in
`docs/tasks/DART-BACKEND-PARITY.md`.
