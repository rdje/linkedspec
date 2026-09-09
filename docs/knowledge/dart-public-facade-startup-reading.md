---
id: dart-public-facade-startup-reading
title: Dart public exports and the first ActionIR data declarations retain distinct boundaries
answers:
  - where is the explicit Dart public export boundary
  - which Dart CLI entrypoint delegates to the primary command
  - does the Dart facade export private staged and recognition ActionIR nodes
  - what did the first Dart startup reading child cover
date: 2026-09-09
status: DART-STARTUP-READING.1.1 source range read; existing AST/parser proof passes 9 tests
tags: [dart, startup, reading, facade, cli, actionir, serialization]
evidence: "From clean decomposition 2f80bcb8, read all six owned ranges: 1500 fragments / 60321 bytes, five complete entries and action_ast.dart through line 659. The 22 explicit export directives select the public package surface; private progressive, staged-job and recognition AST declarations are not re-exported. Thin CLI mains delegate to distinct primary/corpus functions and assign their return to exitCode. Existing ActionIR/parser and spec-AST tests pass 9/9. No new defect is confirmed; the remaining AST and runtime implementation are not credited by this checkpoint."
reverify:
  - "sed -n '1,291p' dart/lib/linkedspec_dart.dart"
  - "sed -n '1,659p' dart/lib/src/action/action_ast.dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter expanded test/action_ast_parser_test.dart test/spec_ast_test.dart"
---

# First Dart reading checkpoint

The owned source range is in `docs/tasks/DART-STARTUP-READING.md` at `.1.1`.
It fully reads `dart/README.md`, analyzer options, both seven-line command
entrypoints and `dart/lib/linkedspec_dart.dart`; it also reads ActionIR
declarations through `dart/lib/src/action/action_ast.dart` line 659.
The range digest remains
`5b8b991130efbf43a7436c1be04c1e7714e523090e8444a6c3b99e95dcfa6c24`.

The public library is an explicit export list, with 22 directives covering
ActionIR/spec types and parsers, compiler state, corpus tools, loading, MCP,
staged function parsing, runtime matching/execution, semantic observations and
queries, generated source, tracing and validation. The primary and corpus mains
delegate to `runLinkedSpecDartCli` and `runLinkedSpecDartCorpusRunnerCli`
respectively; neither contains parsing policy.

The same internal ActionIR file declares the dedicated progressive dispatch,
general staged parse-job, recognition transaction and recursive-observation
nodes. Their absence from the public `show` list preserves the existing
private carrier boundary. A public AST export is not a new builder service or
permission to widen private execution authority; the proposed authoring work
remains separately parked.

The declarations retain kind/source/span data and structural JSON projection.
Progressive dispatch retains target/parser/top/span names. Staged-job data
retains typed direct/derived provenance plans and normalized literal options,
with copied unmodifiable segment/capability lists. Recognition nodes retain
their token, rule or target names. Read access distinguishes keys and indices;
a write path retains its expression so evaluation can determine the selector
kind. Contextual codeblocks retain syntax and callable metadata separately
from admitted arguments.

This range reaches the `ActionCodeblockLiteralExpr` constructor only.
Child `.1.2` resumes its fields/serialization and the remainder of the AST;
no unseen implementation is credited. The existing nine selected tests cover
ActionIR parsing and spec-AST JSON reconstruction, not exhaustive runtime or
private-carrier admission. The last canonical admission remains `a67a18bf`.

Related: [[dart-backend-scaffold-package]], [[dart-actionir-ast-parser]],
[[dart-progressive-span-dispatch-carriers]], [[dart-recursive-observation-admission]],
[[dart-startup-reading-coverage]].
