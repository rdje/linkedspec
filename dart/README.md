# linkedspec_dart

Repository-owned Dart backend package for LinkedSpec parity work.

This package is intentionally staged. It establishes the Dart package boundary,
public library entrypoint, Dart-specific CLI entrypoint, compatibility corpus-runner entrypoint,
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
manifest-backed executable harness whose checked-in 105-fixture corpus gate is
green. The public package also exports deterministic generated-source v2
emission, typed metadata/errors, the exact ten-family plan/direct executor, and
isolated caller-package compile/run proof. Contract-sourced manifest admission
now passes too.

## Commands

Run from this directory:

```sh
bash ../tools/run_dart_project_data.sh pub get
bash ../tools/run_dart_project_data.sh format --set-exit-if-changed .
bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings
bash ../tools/run_dart_project_data.sh test
bash ../tools/run_dart_project_data.sh run bin/linkedspec_dart.dart --help
bash ../tools/run_dart_project_data.sh run bin/linkedspec_dart.dart --spec Lispish --input '(hello world)'
bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --help
bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus
bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --limit 1
bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --limit 40
bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 40 --limit 17
bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31
bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute
bash ../tools/run_dart_local.sh
```

## Semantic introspection

The package exports one immutable `SemanticIndex` plus typed and raw-neutral `linkedspec-semantic-query-v1`
requests. Construction copies in-memory text or strict UTF-8 bytes and requires caller-owned logical identity; it
never accepts or infers a source path:

```dart
import 'package:linkedspec_dart/linkedspec_dart.dart';

final index = SemanticIndex.fromSource(
  'Top::\n /x/\n',
  options: const SemanticIndexOptions(
    logicalName: 'example.spec',
    sourceDetailCeiling: SemanticSourceDetail.text,
  ),
);
final response = index.query(
  SemanticQuery(
    operation: SemanticQueryOperation.list,
    recordKinds: const ['rule'],
    source: const SemanticQuerySource(
      detail: SemanticSourceDetail.identity,
    ),
  ),
);
assert(response.ok && response.records.first.id == 'rule:Top');
```

`SemanticQueryOperation.list` selects the typed list operation. `index.capabilities` reports effective vocabulary and limits. `index.queryNeutral(value)` validates the exact
JSON-like envelope and shares the typed evaluator. Normal execution can capture typed events through
`RuntimeSemanticObservationSink`; after completion, `withExecutionObservation` derives a separate immutable index
containing execution/event records. Query evaluation never parses, compiles, executes, traces, reads paths, exposes
the compiled Dart model, or mutates either index. Current semantic rollout 9/9 and native admission 6/6 are closed
under the independent 128-mutation neutral checker and the six-runtime recurring proof.

## Native MCP server

The package exports a dependency-free, same-process `McpServer` around an already-created immutable
`SemanticIndex`. It never accepts a source path or source text and calls only the index's native `capabilities`
and `queryNeutral` surfaces. Register with host-owned authorization bytes, then either pass already-decoded
requests to `dispatch` or run the strict stdio adapter:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';

final index = SemanticIndex.fromSource(
  'Top::\n /x/\n',
  options: const SemanticIndexOptions(
    logicalName: 'example.spec',
    sourceDetailCeiling: SemanticSourceDetail.text,
  ),
);
final authorization = utf8.encode('tenant-42/read-only');
final server = McpServer();
final handle = server.registerIndex(index, authorization);

final response = server.dispatch({
  'jsonrpc': '2.0',
  'id': 1,
  'method': 'tools/call',
  'params': {
    '_meta': {
      'io.modelcontextprotocol/clientCapabilities': <String, Object?>{},
      'io.modelcontextprotocol/protocolVersion': '2026-07-28',
    },
    'name': 'linkedspec_semantic_capabilities',
    'arguments': {'handle': handle},
  },
}, authorization);

print(response?['jsonrpc']); // 2.0

// Alternatively, let the same server own one protocol-stream lifecycle:
// await server.serveStdio(stdin, stdout, authorization, log: stderr);

server.shutdown(); // omit after serveStdio: EOF/failure already shuts it down
```

Production handles encode exactly 256 secure random bits as 43 unpadded base64url characters. The registry keeps
only an authorization SHA-256 digest, uses monotonic absolute expiry, defaults to 1,024 live handles and a
15-minute lifetime, prunes expired entries, and makes unknown/expired/revoked/unauthorized states
indistinguishable. `McpRegistrationOptions` may lower source detail, digest access, page size, and budgets but can
never raise native index authority.

The generated 82,875-byte private contract part is verified from the shared neutral MCP bundle and read without
runtime filesystem access. `serveStdio(Stream<List<int>>, IOSink, ...)` accepts LF, CRLF, or one final complete
frame at EOF; bounds retained payload bytes; rejects invalid UTF-8/BOM, duplicate decoded keys, malformed numbers,
depth above 64, arrays/non-object roots, and ambiguous request ids before decoded dispatch; then emits recursively
key-sorted canonical UTF-8 plus exactly one LF. Accepted request ids stay active through successful flush, so a
deterministically observed pre-emission cancellation suppresses output while flushed output is final.

Input, output, and optional distinct log sinks remain caller-owned and are never closed. EOF and input/add/flush
failure release every registered index; an I/O failure can write only the fixed `linkedspec_mcp_io_failure` code
to the optional log and throws the same sanitized typed error. The production boundary imports only the `IOSink`
type from `dart:io`; it gains no file, process, socket, HTTP, isolate, parser, compiler, runtime, trace, cache, or
CLI authority. Exact admission composes every contract role once through one ordered public consumer. Subsequent
Julia and shared Lua admissions plus recurring all-twenty proof close the shared ledger at 5/5 implementations,
6/6 runtimes, and rollout complete/141. Verify the current surface from the repository root:

```sh
bash tools/run_python_project_data.sh tools/generate_dart_mcp_contract.py
cd dart
bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings
bash ../tools/run_dart_project_data.sh test test/mcp_contract_dart_binding_test.dart test/mcp_server_dart_dispatch_test.dart test/mcp_server_dart_stdio_test.dart test/mcp_server_dart_admission_test.dart
```

## Generated rule-label primitives

`lib/src/parser/unicode_rule_label.dart` is generated from the pinned Unicode 17.0.0 `XID_Continue` contract. It
contains all 806 merged scalar ranges, binary-search membership, complete-label validation, and a longest-prefix
scanner that keeps supplementary UTF-16 pairs intact. Regenerate and check it from the repository root:

```sh
python3 unicode_case/generate_unicode_rule_label_contract.py
bash tools/run_python_project_data.sh tools/check_unicode_rule_label_contract.py
cd dart && bash ../tools/run_dart_project_data.sh test test/unicode_rule_label_classifier_test.dart
```

The artifact is the single native rule-label authority. Leaf `.10.5.0.2.1` routes headers plus action, blind, and
bare targets through its supplementary-safe prefix scanner and revalidates every declaration/target through its
complete-label predicate. This applies equally to parsed, `SpecFile.fromJson`, and programmatic ASTs; malformed
suffixes cannot silently truncate to a valid prefix. Function/helper/lifecycle/fluent/mark identifiers retain
their separate existing grammars. Dedicated identity proof then drives all nine positive contract labels and both
distinct pairs through compiled maps/order, descriptors, generated plans, AST/emitted-payload reconstruction, an
isolated emitted package, native/generated selectors, exact diagnostics/traces, strict loading, and inline/file
primary commands. Those routes compare and transport immutable strings exactly: no normalization or case folding
is introduced downstream. Negative proof covers all eight neutral invalid labels in every declaration and
action/blind/bare target role from programmatic and reconstructed ASTs, source token/no-prefix boundaries, and
primary compilation. Rule-label expansion does not change ASCII/current-policy function names and parameters,
ActionIR helper or fluent names, lifecycle markers, or named-mark variables. Source punctuation remains
structural: `Top:` can be a `Top` declaration, and `Top\nRule` is two tokens, while neither string is one label.
The composed prerequisite is closed after complete Dart 296, primary 66x2, corpus 105/105, neutral contract, and
canonical signoff; that closure does not admit Dart semantic introspection, whose source foundation begins later.

## Generated source

`emitDartSourceV2(compiled, sourceIdentity)` emits a deterministic Dart library
with contract/format/identity metadata plus ordinary and traced direct-value
entrypoints. `emitDartSource(compiled)` is the `<inline>` compatibility adapter.

```dart
final compiled = compileSpec(parseSpec(source));
final generated = emitDartSourceV2(compiled, 'specs/example.spec');
```

Write `generated` as UTF-8 into a caller-owned Dart package that depends on
`linkedspec_dart`, then import the generated library. The emitted file is
Unicode Dart source; normalized spec state is strict-UTF-8/Base64 data inside
it. Structured failures use `GeneratedSourceException.toJson()`.

Generated libraries expose `plan()`, `validatePlan(...)`, and
`validatePlanForContract(...)`. V2/format 2 plan rows contain exactly `label`
and `family`; cursor policy is never serialized. All ten neutral families derive
seek/consume plus choice/sequence directly during validated execution.
Count/label/family/unknown-family drift fails before execution, while a v1
contract fails before payload reconstruction with expected/actual contract ids
and guidance to regenerate from the original `.spec`. The recurring admission
test also reads and passes the contract's exact eight-case subset.

## Rule-local cursor policy

`LinkedSpecRuntimeEngine` no longer accepts a parser-wide `parseMode`. Each
entered rule derives its own cursor and composition policy from its authored
family: default/OR rules seek, while AND rules consume. The same rule therefore
behaves identically whether entered directly, through an action or blind edge,
through `call(...)`, recursively, from loaded state, or from generated-source
v2.

```dart
final compiled = compileSpec(parseSpec('''
Top::AND
 Header
 Body

Header:
 /BEGIN/

Body:
 /payload=(\\w+)/
'''));

final engine = LinkedSpecRuntimeEngine(compiled);
final result = engine.execute('junk BEGIN junk payload=value');
```

Here `Top` consumes its ordered child calls, while each default-family child
retains `seek`; no caller option can rewrite either rule. A loaded parser uses
the same option-free boundary:

```dart
final loaded = loadAndCompileSpec(request, loadOptions);
final engine = loaded.createEngine(maxIterations: 10000);
```

The low-level `LinkedSpecParseMode` enum remains available to the regex matcher
primitives that implement seek and consume. It is not an engine, loader, corpus,
or staged-parser override.

The primary command omits `--parse-mode` from help and recognizes the retired
flag only to return usage exit 2 with migration guidance:

```text
linkedspec: --parse-mode has been removed; cursor policy is derived from each rule (OR/default=seek, AND=consume)
```

`--top-rule` remains available for entry selection. An explicit value has
priority over any authored `Rule::` and may select an ordinary `Rule:`; the
primary CLI regression suite locks that precedence. Core leaf `.9.1.1.2.3.1`
also accepts markerless one-or-more-rule sources and selects their first authored
rule. Neutral/five-backend rollout remains tracked under
`FUTURE-PARITY-BACKLOG.9.1.1.2`; all five backends are now admitted. Root-selection parity is closed at 7
complete / 0 pending, with `bash tools/check_root_rule_selection_five_backend.sh` owning recurring composition.
Canonical medium request trace records contain source, input, and top-rule identity but no
global cursor field.

Duplicate regex-slot identity is closed at 7 complete / 0 pending. Dart's direct
authored-alternative matcher preserves the required target/index across native,
normalized, generated, descriptor, trace, primary, and diagnostic routes. Run
`bash tools/check_duplicate_regex_slot_identity_five_backend.sh` for the exact
six-runtime recurring proof.

Repeated-action result parity is closed at 8 complete / 0 pending. Dart treats
bare `OR` as minimum-one repetition, collects one typed action-edge return per
accepted explicit-repetition hit, preserves lifecycle whole-rule returns and
scalar pipe, and retains generated-source v2. The exact recurring proof is
`tools/check_repeated_action_result_five_backend.sh`.

Core/descriptor leaf `.9.1.1.2.3.1` closes the preflight's 64/65 boundary: one compiled resolver applies explicit
selector > first authored marker > first authored rule before user code; validation accepts markerless sources,
zero/unknown selection failures use the portable stages and codes, and descriptors retain immutable authored
`is_top` facts plus the root-selection contract identity. Route leaf `.9.1.1.2.3.2` now proves loaded and
normalized-JSON reconstructed state plus generated and fresh emitted direct/traced execution reuse that resolver.
Low trace records requested/effective/basis, route failures keep portable zero/unknown fields, stale generated
contract validation remains first, and generated v2/format 2 identity plus its minimal family plan are unchanged.
Dart's root-selection admission passed 270 package tests and 65 primary cases in both environments; the recurring
repeated-action projection now extends the shared primary suite to 66 cases. The corpus remains 105/105.
Admission leaf `.3.3` composes all 15 contract-declared roles exactly once, topology-locks the
package-wide and canonical drivers plus six shared primary case ids, and recorded Dart's historical 4/7 boundary.

## Status

`FUTURE-PARITY-BACKLOG.3.3.1` closes the generated-source scaffold; `.3.3.2`
closes exact ten-family plan/direct execution and four plan rejections;
`.3.3.3` admits the exact interpreter-first eight-case generated proof. Focused
6/6 and complete format/analyze/181 tests/61x2 CLI/105 corpus passed at that
historical boundary. Dart now
passes the complete current capability census. Later cursor migration
`.9.1.5.4` advances current emitted/generated direct/traced roles from v1 to v2
without changing that admitted semantic capability. Public option removal
`.9.1.5.5` deletes all caller-owned global overrides and reaches 260/260 package,
63/63 default and POSIX primary, and 105/105 corpus proof. Composed cursor
admission remains `.9.1.5.6`.

`DART-BACKEND-PARITY.7.5` closes the scoped interpreter-first Dart milestone.
`FUTURE-PARITY-BACKLOG.1.5.3.1` replaces the old corpus-oriented primary boundary:
`bin/linkedspec_dart.dart` now exposes the exact shared source/input/parser/trace option grammar, help and usage
bytes, deterministic named/file/inline resolution, strict preserved UTF-8 loading, and stable compile/input/invoke
phase failures. It passes the 29 shared boundary/loading/failure cases in default and POSIX environments; native
execution/results and canonical trace remain the immediately following `.2` and `.3` leaves. The separate
`bin/corpus_runner.dart` retains all corpus validation/execution and selector behavior. `.1.5.3.2` composes that
boundary through the native staged parser, validator/compiler, and `LinkedSpecRuntimeEngine`, selects top rule and
global parse mode through native controls, and emits the direct result as recursively key-sorted compact UTF-8
JSON. That global-mode seam was later removed by `.9.1.5.5`; entry selection and direct-result framing remain.
`.1.5.3.3` adds the independent canonical phase trace with exact levels, byte counts, escaping, emoji,
stdout/route/mirror, reset/append, and failures. Dart now passes all 61 unchanged primary cases in default/POSIX;
`.1.5.3.4` makes both legs recurring in the focused gate alongside the package suite (now 160 tests) and 105/105 corpus, and closes the Dart
primary-command parent. The earlier
`DART-BACKEND-PARITY.6.3` corpus-parity boundary remains green: the full
checked-in 105-fixture manifest passes through Dart execute mode after the shipped-spec/parser-smoke window reached
31/31 green and the routed top-level `fn` fixtures passed through the spec-defined shell. The package
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
`join_values`, array numeric reducers, and updated-value array end mutations with receiver continuation.
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
uses bare typed bindings for scalar, array, harray, or codeblock values.
`set(items, [])`, `copy(items)`, `push(items, value)`, and `items += value`
all resolve the same typed binding; exact retired selectors reject before
execution. `call(...)` refreshes the runtime `retv` channel with the child result.
Statement-form `substr(...)` and `regex_subst(...)` now mutate scalar targets,
replacement strings expand `$n` capture placeholders, explicit
`split(target, source, delimiter)` replaces the bare typed array target, and
entry/local regex start line/column helpers are available.
Rule regexes and helper regex values now share a runtime compiler that normalizes
POSIX character classes, inline `i`/`m`/`s` flags, scoped flag groups by lifting
their options to the compiled Dart `RegExp`, possessive quantifier
markers, lower-bound `{,n}` quantifiers, and Python-style named captures before
using Dart `RegExp`.
The complete governed anonymous/named capture family now uses code-unit anchors internally with character-based
public lengths/positions. It includes stable/advancing slice, cursor, rest, from, and between reads; rule-local named current,
input-boundary, copied, and anonymous-bridge marks; and symbolic bare mark arguments. Non-repeated `AND`
blind-call rules surface ordered child returns when no explicit parent return overrides them.
Direct capture-slice helpers, diagnostic `print`/`print_each`/`say`, logical
`and`/`or`/`not`, and terminating `exit_now(...)` are available in the runtime.
Logical helpers implement ADR `0043`: `and`/`or` require one or more positional operands, `not` requires exactly
one, invalid arity fails before operand effects, and every valid operand evaluates once left-to-right before a
real boolean is composed. `runtimeLogicalTruth` is the internal shared truth boundary for helpers and lazy
controls: null, false, numeric zero, empty strings, and empty aggregates are false; every nonempty string and
aggregate is true. Neutral native/normalized/generated-plan/standalone-emitted/primary proof is locked by
`logical_helper_contract_test.dart`; generated-plan and standalone-emitted direct/traced roles preserve the same
value, eager effects, typed arity fields, and source identity. Shared case `success_logical_helpers_eager` passes
all five primary commands under default and POSIX option environments. From the repository root,
`bash tools/check_logical_helper_five_backend.sh` repeats the neutral, native/generated, selected primary, and
support-ledger proof; `LINKEDSPEC_RUN_LOGICAL_MATRIX=1 bash tools/run_ci_local.sh` executes the registered path.
Diagnostic helpers validate their one-plus/two-or-three positional arities before effects and evaluate every
valid argument once left-to-right. Native `parse`, `execute`, `parseWithTrace`, and `executeWithTrace` calls may
install a per-invocation `diagnosticOutputSink`; it receives typed `RuntimeDiagnosticOutputEvent` values with
`helperName`, current `ruleLabel`, and exact Unicode `message`:

```dart
final events = <RuntimeDiagnosticOutputEvent>[];
final result = engine.parse(
  input,
  diagnosticOutputSink: events.add,
);
```

Without a sink execution remains eager but quiet, and event text never enters `RuntimeParseResult` or native
trace. A thrown sink object propagates unchanged and aborts later delivery; `RuntimeExitNow.status` is separate
typed immediate control. Emitted generated entrypoints expose the same optional named argument while retaining
their sinkless signatures:

```dart
final value = execute(input, diagnosticOutputSink: events.add);
final traced = executeWithTrace(
  input,
  traceConfig,
  diagnosticOutputSink: events.add,
);
```

Caller objects and stacks cross generated framing unchanged; ordinary failures retain generated-source
attribution. Helper-call parsing preserves literal delimiters inside quoted arguments.
Compiled action edges now carry resolved regex-dispatch metadata, edge-only child
regexes are folded into the parent alternation, and runtime action dispatch uses
that metadata directly. Aggregate resets through `set(items, [])` and
`set(meta, {})` are scoped to the current rule invocation, preserving
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
parity is closed for the current checked-in manifest: `executeCorpusFixtures(...)` runs controlled manifest
fixtures through parse/compile/runtime, compares the engine output against
`[expected]` with structural JSON equality, and report every fixture failure.
It accepts named or bounded fixture selection through `caseNames`, `offset`, and
`limit`. The corpus-runner CLI exposes those developer options through
`bin/corpus_runner.dart`; they are deliberately absent from the shared primary parser command. Without a selector, `--execute`
runs the full checked-in manifest in order. The full 105-fixture corpus now passes
through execute mode, including the first 40 shipped manifest fixtures, the
non-`fn` middle helper/control/receiver fixtures, the shipped-spec/parser-smoke window, and the three routed
top-level `fn` fixtures. The top-level function fixtures obtain
`function_definition` nodes by executing `specs/user_function_definition.spec` and then use staged body projection;
there is no Dart raw `fn` scanner as the semantic source of truth. The final
31-fixture shipped-spec/parser-smoke window is now 31/31 green. The completed residual work is split into
portmap/action-edge result shape, hlink delimiter/capture, helper mutation/text normalization, legacy structural
smoke output, residual closeout, and structural-regex leaves.
Basic regex-dialect bridging is now done. The exact shipped structural PCRE forms that Dart `RegExp` cannot compile
directly are handled by bounded matchers: Lispish recursive `(?R)` square brackets, EBNF `\K` / recursive
`(?&name)` / `(?(DEFINE)...)` return structures, and spec.spec recursive block regexes.
The helper/action bridge, recursive/default-mode bridge, portmap result-shape bridge, and hlink delimiter/capture
bridge are also done; tclite, recursive top-rule, all five portmap fixtures, all five hlink fixtures,
`vhdl_library_use`, `tablegrep_simple_term`, `simenv_multiline_value`, `lib_reader_sattribute`, and
`lib_reader_cattribute` pass. The legacy accumulator bridge is also done, so `regdef_nested_register_fields`
passes. Dart now also mirrors Perl's public-parser leading blank/comment-line skip, so
`ds_vhistory_version_entry` passes without weakening ordinary scalar-held indexed reads. Dart also supports
action-edge `push(child, index)`, so `ebnf_logging_annotation` preserves indexed quoted-string payloads. The
diagnostic window is now 31/31 green, `.6.2.4` is closed, `.6.2.5` closes the routed top-level function
corpus fixtures, and `.6.3` closes the full Dart corpus gate at 99/99.
