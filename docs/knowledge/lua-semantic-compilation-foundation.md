---
id: lua-semantic-compilation-foundation
title: Lua semantic construction retains one staged compiled-or-failed authority without execution
answers:
  - "how does Lua semantic_index compile source"
  - "which Lua semantic outcome methods are implemented"
  - "what does Lua semantic_snapshot return"
  - "what does Lua compilation_authority reveal"
  - "how are Lua semantic compilation diagnostics represented"
  - "which Lua semantic diagnostics preserve native codes"
  - "which Lua semantic compilation errors use fallback codes"
  - "how does Lua semantic_index select an entry rule"
  - "what does Lua generated_plan_input return"
  - "does Lua semantic construction execute target code"
  - "does Lua semantic construction read a caller path"
  - "does Lua semantic construction rethrow unknown errors"
  - "what tests prove the Lua compiled-or-failed foundation"
date: 2026-07-25
status: current implementation; .10.7.2 composition-closed, .10.7.3.0 audit closed, and .10.7.3.1 graph next
tags: [lua, luajit, semantic-introspection, compilation, diagnostics, generated-source, privacy, no-execution]
evidence: "lua/src/linkedspec/semantic_compilation_outcome.lua, lua/src/linkedspec/semantic_index.lua, and lua/test/semantic_index_compilation_foundation_test.lua; 122 assertions pass identically on PUC Lua and LuaJIT after the 378-assertion source owner, and .10.7.2.3 recomposes both unchanged."
reverify: "LINKEDSPEC_LUA_TEST_RUNTIME=lua lua lua/test/semantic_index_compilation_foundation_test.lua; LINKEDSPEC_LUA_TEST_RUNTIME=luajit luajit lua/test/semantic_index_compilation_foundation_test.lua; bash tools/run_lua_local.sh; python3 tools/check_semantic_introspection_contract.py"
---

# Lua semantic compilation foundation

`FUTURE-PARITY-BACKLOG.10.7.2.2` extends the existing opaque `semantic_index` only after strict source/options,
UTF-8 mapping, and digest construction succeed. A package-private outcome owner invokes exactly one staged user-
function-aware parse, native validation, `compile_spec(..., {validate_source=false})`, entry selection, and shared
generated-v2 plan build. The trusted bundled staged grammar is compiler infrastructure; no caller path is accepted
or read, and neither caller target actions/lifecycle code nor generated code is executed.

Weak-key state retains the parsed `SpecFile`, validated flag, compiled authority, merged authored function/rule
order, selected entry, and plan. The public handle adds `semantic_snapshot`, `compilation_authority`,
`compilation_diagnostic`, `entry_selection`, and `generated_plan_input`. Their protected empty-table values expose
only virtual scalar fields plus fresh detached JSON, diagnostic fields, or plan rows. Snapshot state is `compiled`
or `failed_compilation` and always reports `has_execution=false`; authority reveals only parsed/validated/compiled
presence. Entry is `{label,basis}`. Plan is `{contract_id,format_version,source_identity,rows}` and requires at least
the `identity` ceiling.

Native validation and entry-selection failures preserve exact portable code, stage, message, and detached fields.
Recognized parser, compiler, and generated-plan owner errors use deterministic `semantic_index_parse_failed` /
`parse_source`, `semantic_index_compilation_failed` / `compile_source`, and
`semantic_index_generated_plan_failed` / `build_generated_plan` fallbacks. Recognized validation errors lacking the
portable native tuple use `semantic_index_validation_failed` / `validate_source`. Any unrecognized thrown value is
re-raised unchanged, including table identity.

The 122-assertion suite covers graph, explicit/default entry, markerless source, staged functions, native failure,
parse/empty/missing-selection cases, validation/compile/plan fallbacks, unrecognized sentinel identity, generated
plan detachment, opacity, source scans, and a target body that would fail if executed. It passes unchanged on PUC
Lua and LuaJIT. Static projection, record/query APIs, runtime observation, generated-format changes, rollout, and
admission remain later leaves. No-change `.10.7.2.3` recomposes this suite after the source suite on both ABIs and
closes the foundation parent without replacement code. See [[lua-semantic-source-foundation]], [[lua-semantic-source-outcome-plan]],
[[lua-semantic-introspection-authority-map]], and [[semantic-introspection-neutral-contract]].
