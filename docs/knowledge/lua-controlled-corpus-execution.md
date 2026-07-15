---
id: lua-controlled-corpus-execution
title: Lua corpus execution is a reusable non-aborting library pipeline with typed proof records
answers:
  - how does Lua execute LinkedSpec corpus fixtures
  - can Lua execute a named or bounded corpus subset
  - does Lua validate the full corpus before selecting fixtures
  - what fields does a Lua corpus execution result retain
  - does one Lua corpus failure abort later fixtures
  - how is expected corpus JSON compared in Lua
  - can Lua corpus execution retain trace lines and runtime diagnostics
  - does the Lua corpus runner CLI execute fixtures
date: 2026-07-15
status: current
tags: [lua, corpus, execution, library, result-records, trace, diagnostics, PUC-Lua, LuaJIT]
evidence: "LUA-BACKEND-PARITY.6.1.2 adds execute_corpus_fixtures and typed result/query APIs. Controlled scalar, aggregate, dispatch, lifecycle, function, boundary, selection, and failure/continuation proof passes 160/160 on PUC Lua and LuaJIT."
reverify: "bash tools/run_lua_local.sh"
---

`lua/src/linkedspec/corpus.lua` owns both strict corpus loading and reusable in-process execution. The executor
loads and validates the complete manifest, exact directory membership, strict-UTF-8 files, and typed expected JSON
before it applies a selection. Callers may preserve their requested name order with `case_names`, or use a
zero-based `offset` and optional positive `limit`; the two selection styles cannot be mixed.

Every selected fixture runs through the automatic spec-defined function parser, explicit source validation,
compilation without duplicate validation, source-identified runtime-engine construction, and native runtime. The
expected JSON is wrapped exactly once in an array and compared structurally with explicit JSON null, array, and
harray identity. When a trace config is supplied, each fixture receives a fresh silent emitter and retains its
trace lines without writing them to the caller's stdout.

`CorpusFixtureExecutionResult` retains name, copied expected JSON, copied actual value/output, match flag, byte and
character endpoints, trace lines, an optional typed runtime diagnostic, a stable failure stage, and failure text.
Stages are `parse`, `validate`, `compile`, `execute`, `match`, `compare`, or `unexpected`. Per-fixture failures are
records, not control flow, so later selected fixtures always run. Manifest/selection errors still raise because no
valid execution set exists. `CorpusExecutionResult` retains the full validation result and selected records;
`corpus_fixture_passed`, `corpus_execution_passed`, `corpus_passed_count`, `corpus_failures`, and
`corpus_fixture_result` query it.

The developer `lua/bin/corpus_runner.lua` remains validation-only by design. `LUA-BACKEND-PARITY.6.1.3` now
permanently executes exact core offsets 0-39 at 40/40 with endpoint 1/1; capability offsets 99-104 remain
`.6.1.4`, while full corpus and CLI promotion have later owners. Related facts: [[lua-corpus-manifest-io]],
[[lua-controlled-corpus-admission-split]], [[lua-native-spec-pipeline]], [[lua-native-full-pipeline-trace]].
