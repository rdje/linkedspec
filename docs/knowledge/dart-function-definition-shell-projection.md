---
id: dart-function-definition-shell-projection
title: Dart consumes spec-returned user-function definition AST nodes instead of raw-scanning fn source
answers:
  - does Dart parse user function definitions
  - does Dart raw-scan fn definitions
  - how does Dart consume specs/user_function_definition.spec output
  - where is Dart function-definition shell projection
  - does Dart preserve function body parse jobs
  - what owns Dart function-definition shell semantics
  - do Dart top-level fn corpus fixtures pass
  - how does Dart corpus execution route top-level fn fixtures
date: 2026-07-09
status: current
tags: [dart, parser, user-functions, staged-parsing, ast]
evidence: "DART-BACKEND-PARITY.2.4 adds dart/lib/src/parser/user_function_definition_shell.dart and test/user_function_definition_shell_test.dart. The projection APIs consume function_definition / function_definition_error nodes returned by specs/user_function_definition.spec, validate spans and staged sidecars, normalize parent_ast_path and body_parse_job ids, strip returned source spans, and attach FunctionDefinition records before rule parsing. Tests assert successful projection, malformed-node diagnostics, sidecar drift rejection, and that empty-node parsing does not raw-scan a leading fn shell. DART-BACKEND-PARITY.6.2.5 adds dart/lib/src/parser/user_function_definition_parser.dart, executes specs/user_function_definition.spec through the Dart runtime to obtain spec-produced nodes, feeds those nodes through parseSpecWithStagedUserFunctionDefinitionAsts(...), and routes executeCorpusFixtures(...) through that shell only when rule-only parseSpec(...) rejects top-level fn source. The three routed top-level fn corpus fixtures pass."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/user_function_definition_shell_test[.]dart test/user_function_definition_parser_test[.]dart test/staged_parser_registry_test[.]dart test/corpus_manifest_test.dart && bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --case terse_3_3_1_scalar_assignment_expressions --case terse_3_3_4_assignment_expression_closure --case terse_4_3_2_user_function_runtime && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

Dart function-definition shell semantics now follow the same owner boundary as
Perl and Rust: `specs/user_function_definition.spec` owns the returned
`function_definition` / `function_definition_error` AST shape.

The Dart frontend does not raw-scan `fn` source as a replacement.
`parseSpecWithUserFunctionDefinitionAsts(...)` and
`projectUserFunctionDefinitionAsts(...)` consume the node list returned by the
owning spec. The projection validates source/body spans against the original
source, validates `body_payload` and `body_parse_job`, normalizes source-order
`parent_ast_path` values to `functions.<index>.body_source`, derives the
deterministic body parse-job id, strips the returned definition spans while
preserving line layout, and attaches ordered `FunctionDefinition` records before
ordinary rule parsing.

`StagedParseJob` preserves the function-body sidecar metadata emitted by the
spec: fixed v1 jobs carry `params`/`arity`, while variadic v2 jobs carry the exact typed `signature`; both retain
`version`, `function_name`, and `diagnostic_owner` in JSON round-trips. The projection APIs remain the pre-dispatch shell boundary:
`parseSpecWithUserFunctionDefinitionAsts(...)` returns functions with preserved
`body_parse_job` and no automatic `body_ast`. The staged registry added later
provides `parseSpecWithStagedUserFunctionDefinitionAsts(...)` when callers want
the body job dispatched and stitched into `body_ast`.

`DART-BACKEND-PARITY.6.2.5` adds the executable Dart shell bridge:
`parseUserFunctionDefinitionAsts(...)` compiles and executes
`specs/user_function_definition.spec` through the Dart runtime, normalizes the
returned wrapper shape, and returns the shell-owned AST nodes.
`parseSpecWithStagedUserFunctionDefinitions(...)` then feeds those nodes through
staged function-body projection. The corpus runner keeps direct `parseSpec(...)`
for rule-only fixtures and falls back to this shell path when rule-only parsing
rejects top-level `fn` source. The routed terse user-function corpus fixtures
now pass without a Dart raw scanner owning the `fn` semantic shape.

Related facts: [[spec-defined-user-function-definition-parser]],
[[function-body-parse-job-sidecar]], [[dart-staged-function-body-registry]],
[[dart-core-spec-parser]], [[dart-frontend-ast-json-contract]],
[[dart-middle-corpus-batch]].

## 2026-09-09 — executable bridge and projection-prefix reading

`DART-STARTUP-READING.1.13` reads all 282 executable parser-bridge lines and shell lines
1-252. The bridge compiles caller-supplied parserSpecSource directly or reuses the default
compiled parser. Default logical-spec discovery searches upward from cwd and script
directories. Each parse uses the compiled parser to execute the source, normalizes the
returned map/list wrapper and composes staged projection. Trace scopes balance success
and failures, and parser/compiler/runtime errors retain their phase boundary.

The shell prefix projects spec-produced definition/error nodes, then parses stripped rule
source, keeping projection failures outside the narrower rule-parse wrapper. It distinguishes
fixed/typed-v1 fields from variadic-v2 signatures and validates identifier spellings.
The arity/body/span/sidecar remainder starts at line 253 and stays owned by .1.14.
Twenty-five selected registry/Unicode/function parser/shell tests pass. No raw fn scanner
or generic builder capability is added; proposed authoring work remains parked.

## 2026-09-09 — function-shell source reading complete

`DART-STARTUP-READING.1.14` reads lines 253-1006 through EOF. Character offsets are Unicode
scalars: source/body text must match their slices, body bounds stay inside the definition,
and removal rejects overlapping spans while replacing non-CR/LF scalars with spaces.
Line fields are checked for positive ordered bounds and retained by FunctionDefinition;
the scalar body coordinates remain in the staged sidecars, as distinguished in
[[dart-semantic-introspection-authority-map]].

Payload/job validation checks kind, function identity, fixed/typed-v1 or variadic-v2
signature, body text and span equality. Jobs additionally require the fixed parser/top,
replacement field, failure policy and diagnostic owner. Supplied placeholder parent paths
are normalized to function indices, and body job ids are regenerated from identity and
scalar boundaries. Variadic signatures require the exact six fields and null max_arity;
typed declaration failures receive specific diagnostics before the generic fallback.

The selected shell/parser/registry plus progressive authority/carrier tests pass 24/24.
This completes physical shell reading without changing its input contract or admitting a
generic builder. Earlier source and projection evidence remains intact.

## September 11 function parser and shell consumers complete

Dart .1.54 reads user_function_definition_parser_test.dart1-93 and
user_function_definition_shell_test.dart1-210 through EOF. Four parser tests execute
the owning spec, compose staged bodies, admit ordinary sources and normalize output
wrappers. Three shell tests preserve source lines and normalized job identity,
reject malformed/drifting sidecars and reject a leading fn source when no returned
nodes are supplied. Their synthetic fixture helpers use ASCII source coordinates;
they do not add independent astral span proof. All 43 selected tests pass.
No raw scanner, builder or MCP parser-construction feature is introduced.
