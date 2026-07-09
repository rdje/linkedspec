# linkedspec_dart

Repository-owned Dart backend scaffold for LinkedSpec parity work.

This package is intentionally staged. It establishes the Dart package boundary,
public library entrypoint, CLI smoke entrypoint, corpus-runner entrypoint,
manifest IO scaffold, source-level AST/data types, a core `.spec` rule parser,
frontend validation, spec-returned function-shell projection, typed ActionIR
parsing/contract resolution, user-function registry scaffolding, and a
backend-neutral compiled-spec state model before runtime semantics land.

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

`DART-BACKEND-PARITY.3.4` owns the current boundary. The package can round-trip
parsed `.spec` structures and staged parse-job sidecars through JSON, parse rule
paragraphs into source AST types, validate those ASTs in non-strict or strict
mode, project spec-returned function-definition nodes, parse helper/action source
into typed ActionIR nodes, resolve current helper/control contracts, build an
ordered `UserFunctionRegistry`, and classify exact-arity user calls before helper
fallback. It can now compile a validated `SpecFile` into `CompiledSpec` state
with ordered rule tables, dependency-regex data, mode metadata, lifecycle/action
ActionIR payloads, the function registry, and descriptor-shaped JSON projection.
Runtime execution, tracing, and corpus output parity remain later leaves in
`docs/tasks/DART-BACKEND-PARITY.md`.
