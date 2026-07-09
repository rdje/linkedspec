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
controls/sinks plus runtime trace events, staged function-body dispatch, and
registered user-function runtime execution. Its corpus layer now has a
manifest-backed executable harness for controlled proof fixtures before full
shipped-corpus parity lands.

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
dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --limit 1
dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --limit 40
dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 40 --limit 17
dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31
```

## Status

`DART-BACKEND-PARITY.6.2.4.4.1` is the current completed corpus-parity boundary;
`.6.2.4.4.2` is the next shipped-spec/parser-smoke residual frontier for hlink delimiter/capture parity. The package
can round-trip
parsed `.spec` structures and staged parse-job sidecars through JSON, parse rule
paragraphs into source AST types, validate those ASTs in non-strict or strict
mode, project spec-returned function-definition nodes, parse helper/action source
into typed ActionIR nodes, resolve current helper/control contracts, build an
ordered `UserFunctionRegistry`, and classify exact-arity user calls before helper
fallback. It can now compile a validated `SpecFile` into `CompiledSpec` state
with ordered rule tables, dependency-regex data, mode metadata, lifecycle/action
ActionIR payloads, the function registry, and descriptor-shaped JSON projection.
It also has a minimal staged parser registry for function-body parse jobs:
`actionir-body.spec` resolves to the built-in `action_block` provider, jobs run
in stable queue order, dispatch records carry the staged cache key and compiled
parser shape, and `dispatchFunctionBodyParseJobs(...)` /
`parseSpecWithStagedUserFunctionDefinitionAsts(...)` stitch the returned
`action_block` JSON into each function's `body_ast`.
Registered exact-arity user-function calls now execute through the runtime
interpreter before helper fallback: arguments evaluate eagerly in the caller,
params bind into fresh function-local scalar/array/hash stores, function bodies
return their final expression or local `return(...)` payload, returned values
feed compatible receiver chains, standalone calls execute with their values
discarded, and direct or mutual recursion throws a structured diagnostic.
The descriptor projection now preserves neutral staged function fields through
parsed, compiled, descriptor, and runtime layers: `body_payload`, normalized
`body_parse_job`, stitched `body_ast`, `function_order`, and runtime output are
covered by focused compiled-state tests.
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
The runtime now also treats empty array/hash returns as successful non-null rule
matches, uses child-rule match bits for blind dispatch, and executes
marker-form `if(...)` / `elseif(...)` / `else()` / `endif()` statement chains
as grouped branches. It also preserves assignment expressions inside helper
argument lists, supports plain fallback values in inline `if(...)`, evaluates
single-argument numeric aggregate reducers through aggregate-aware reads, and
uses scalar-held list/map values for `array(name)`, `hash(name)`, and `copy(name)`
unless an explicit aggregate write supersedes the scalar-held value.
Rule regexes and helper regex values now share a runtime compiler that normalizes
POSIX character classes, inline `i`/`m`/`s` flags, scoped flag groups by lifting
their options to the compiled Dart `RegExp`, possessive quantifier
markers, lower-bound `{,n}` quantifiers, and Python-style named captures before
using Dart `RegExp`.
Direct capture-slice helpers, diagnostic `print`/`print_each`/`say`, logical
`and`/`or`/`not`, and terminating `exit_now(...)` are available in the runtime,
and helper-call parsing preserves literal delimiters inside quoted arguments.
Compiled action edges now carry resolved regex-dispatch metadata, edge-only child
regexes are folded into the parent alternation, and runtime action dispatch uses
that metadata directly. Explicit aggregate resets through `set(array(name), ...)`
and `set(hash(name), ...)` are scoped to the current rule invocation, preserving
recursive parser value parity while ordinary undeclared child mutations remain
caller-visible.
Runtime failures now expose `RuntimeDiagnostic` payloads through
`RuntimeInterpreterException.diagnostic` with stable `type`, `stage`,
`owner_stage`, `summary`, `detail`, `top_rule`, `rule_label`,
`handler_source_label`, and optional `spec_name` / `spec_path` fields. Dart now
also has `LinkedSpecTraceConfig`, `LinkedSpecTraceLevel`,
`LinkedSpecTraceEmitter`, event/scope primitives, stdout/routed-file/mirror sink
behavior with reset/truncate, and traced runtime entrypoints that preserve parse
output while emitting parse/rule scopes plus regex, child-dispatch, lifecycle,
cursor-control, recursion-cutoff, and source-boundary trace events. Corpus output
parity has started: `executeCorpusFixtures(...)` can run controlled manifest
fixtures through parse/compile/runtime, compare the engine output against
`[expected]` with structural JSON equality, and report every fixture failure.
It now accepts named or bounded fixture selection through `caseNames`, `offset`,
and `limit`. The corpus-runner CLI exposes that surface through opt-in
`--execute` mode with `--case`, `--offset`, and `--limit`; unbounded CLI
execution is rejected until the full shipped-corpus gate is ready, so the default
99-fixture command remains a manifest-loader smoke. The first 40 shipped
manifest fixtures and the non-`fn` middle helper/control/receiver fixtures now
pass through bounded execute mode. Top-level `fn` corpus fixtures remain routed
to `DART-BACKEND-PARITY.6.2.5` for spec-defined function-shell execution. The final
31-fixture shipped-spec/parser-smoke window is now 13/31 green. The residual work is split into portmap/action-edge
result shape, hlink delimiter/capture, helper mutation/text normalization, legacy structural smoke output, residual
closeout, and PCRE structural-regex leaves.
Basic regex-dialect bridging is now done; deeper PCRE structural constructs such as
`\K`, recursive `(?&name)` subpatterns, and `(?(DEFINE)...)` are routed to
`DART-BACKEND-PARITY.6.2.4.6`.
The helper/action bridge, recursive/default-mode bridge, and portmap result-shape bridge are also done; tclite,
recursive top-rule, all five portmap fixtures, and `vhdl_library_use` pass. The diagnostic window is now 13/31
green. Remaining non-PCRE failures are split under `.6.2.4.4`, with `.6.2.4.4.2` next for hlink
delimiter/capture parity; deeper PCRE structural regex constructs such as Lispish `(?R)` stay routed to
`.6.2.4.6`.
Full shipped-corpus output parity remains a later leaf in
`docs/tasks/DART-BACKEND-PARITY.md`.
