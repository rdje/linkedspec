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
evidence_update_2026_07_15_permanent_windows: "LUA-BACKEND-PARITY.6.1.3-.4 permanently execute exact core offsets 0-39 at 40/40 endpoint 1 and governed offsets 99-104 at 6/6 endpoints 2,1,2,1,5,5. Both ABIs pass 162/162 and .6.1 is closed."
evidence_update_2026_07_15_full_gate: "LUA-BACKEND-PARITY.6.3 executes the complete manifest without selectors through the library and developer runner. Both paths pass 105/105 in order with zero failures; PUC Lua and LuaJIT pass 167/167 with status runtime-corpus-full."
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

The developer `lua/bin/corpus_runner.lua` validates only by default. Under `.6.3`, bare `--execute` now runs the
complete manifest through this library API and maps all-pass, fixture-failure, and argument/manifest outcomes to
exits 0, 1, and 2. `LUA-BACKEND-PARITY.6.1.3` permanently executes exact core offsets 0-39 at 40/40 with endpoint
1/1; `.6.1.4` permanently executes capability offsets 99-104 at 6/6 with endpoints `2,1,2,1,5,5`; `.6.2.6`
permanently executes advanced/shipped offsets 40-98 at 59/59. Final `.6.3` locks one ordered 105/105 run. Related
facts: [[lua-full-corpus-gate]], [[lua-corpus-manifest-io]],
[[lua-controlled-corpus-admission-split]], [[lua-native-spec-pipeline]], [[lua-native-full-pipeline-trace]].
