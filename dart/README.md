# linkedspec_dart

Repository-owned Dart backend scaffold for LinkedSpec parity work.

This package is intentionally staged. It establishes the Dart package boundary,
public library entrypoint, CLI smoke entrypoint, corpus-runner entrypoint,
manifest IO scaffold, source-level AST/data types, a core `.spec` rule parser,
frontend validation, spec-returned function-shell projection, typed ActionIR
parsing/contract resolution, user-function registry scaffolding, a
backend-neutral compiled-spec state model, runtime regex/match-state primitives,
a first rule-dispatch interpreter, core runtime value/capture helpers,
string/numeric helper execution, array helper execution, and hash helper
execution, plus value-block/control/tree helper execution, explicit
cursor-control behavior, structured runtime diagnostics, and trace
controls/sinks plus runtime trace events before staged runtime/corpus semantics
land.

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

`DART-BACKEND-PARITY.4.5.4` is the current completed diagnostics/trace boundary; `.5.1`
is the next staged-runtime frontier. The package can round-trip
parsed `.spec` structures and staged parse-job sidecars through JSON, parse rule
paragraphs into source AST types, validate those ASTs in non-strict or strict
mode, project spec-returned function-definition nodes, parse helper/action source
into typed ActionIR nodes, resolve current helper/control contracts, build an
ordered `UserFunctionRegistry`, and classify exact-arity user calls before helper
fallback. It can now compile a validated `SpecFile` into `CompiledSpec` state
with ordered rule tables, dependency-regex data, mode metadata, lifecycle/action
ActionIR payloads, the function registry, and descriptor-shaped JSON projection.
It also has runtime regex primitives for seek/consume matching, stable
alternative identity, capture and named-capture records, char-offset projections,
entry/local match registers, cursor state, and zero-progress detection.
`LinkedSpecRuntimeEngine` now executes compiled rules through the first
interpreter layer: default/AND/OR/repetition dispatch, action-edge and
blind-call child dispatch, lifecycle blocks, explicit returns, `retv`,
accumulator collection, bounded repetition, zero-progress cutoffs, and recursion
cutoffs. The runtime evaluator now also preserves scalar/array/hash/null/boolean/
number shapes through assignment and wrapper snapshots, supports `hash(...)`,
`set(hash(...), ...)`, hash-index mutation, nested reads, non-numeric map keys,
aggregate `copy(...)`, nested value-path assignment without autovivifying
missing intermediates, and named/map/position capture helpers. It now executes
string/scalar helpers, explicit `str_*` lexical comparisons, numeric
arithmetic/reducer/comparison helpers, numeric aliases and symbol callees, and
compatible string/number receiver chains. It now also executes array helpers,
array receiver chains, regex split/filter bridges, delimiter-first
`join_values`, array numeric reducers, and statement-only array end mutations.
It now also executes hash helpers, hash receiver chains, statement/value
`set_key` boundaries, bare-overlay `merge_hash`, direct hash-index assignment
values, and explicit flat-style hash splicing inside `hash(...)`. It now also
executes expression-valued blocks with block-local `return(...)`, attached and
inline `if`/`when`/`switch`/`while` controls, helper-form `with(...) { ... }`,
receiver `.with() { ... }`, and hash/array tree traversal receiver callbacks
with scoped callback bindings. It now also executes `save_cursor()` /
`restore_cursor()` stack semantics, `rewind_match_start()` /
`rewind_entry_start()` anchor rewinds, and char-based cursor/input helpers such
as `cursor_pos`, `cursor_rest`, `input_slice`, and `input_end_pos`.
Runtime failures now expose `RuntimeDiagnostic` payloads through
`RuntimeInterpreterException.diagnostic` with stable `type`, `stage`,
`owner_stage`, `summary`, `detail`, `top_rule`, `rule_label`,
`handler_source_label`, and optional `spec_name` / `spec_path` fields. Dart now
also has `LinkedSpecTraceConfig`, `LinkedSpecTraceLevel`,
`LinkedSpecTraceEmitter`, event/scope primitives, stdout/routed-file/mirror sink
behavior with reset/truncate, and traced runtime entrypoints that preserve parse
output while emitting parse/rule scopes plus regex, child-dispatch, lifecycle,
cursor-control, recursion-cutoff, and source-boundary trace events. Staged
runtime execution and corpus output parity remain later leaves in
`docs/tasks/DART-BACKEND-PARITY.md`.
