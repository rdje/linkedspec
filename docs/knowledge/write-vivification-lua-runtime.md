---
id: write-vivification-lua-runtime
title: Lua nested writes use evaluated typed paths and one isolated dense publication on both ABIs
answers:
  - how does Lua implement nested write vivification
  - what Lua AST node owns document key position assignment
  - does Lua nested assignment create missing containers
  - how does Lua distinguish absent from bound null during nested writes
  - do Lua emitted parsers preserve nested write path expressions
  - does Lua map_leaves bang exist yet
  - where is the Lua write vivification regression test
date: 2026-09-04
status: current; Lua nested writes implemented on PUC Lua and LuaJIT, Lua map_leaves bang and portable admission pending
tags: [lua, luajit, actionir, assignment, autovivification, diagnostics, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.6.1 replaces Lua's authored key/index-tagged assignment lowering with ActionWritePathSegment plus assign_nested_access. Parser/compiler/runtime/static-contract/source-emitter owners carry typed expressions and Unicode-scalar spans through native, public SpecFile reconstruction, generated-plan, emitted-module, and primary-CLI routes on PUC Lua and LuaJIT. Runtime evaluates every segment then RHS, snapshots afterward, distinguishes absent from bound null, builds selector-determined dense harray/array state on an isolated copy, publishes once, preserves completed expression effects and exact expression failures, and returns detached values. lua/test/write_vivification_contract_test.lua consumes the unchanged 5/7/11/16/3/3 neutral fixture, rejects malformed and reserved carriers, and permanently proves map_leaves! remains unadmitted at 436 assertions on each ABI. The complete Lua gate, CLI 66x2, corpus 105/105, and project-data storage proof pass."
reverify: "bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py && bash tools/run_lua_project_data.sh puc lua/test/write_vivification_contract_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/write_vivification_contract_test.lua && bash tools/run_lua_local.sh"
---

# Lua write-vivification runtime

Lua parses every authored one- or many-segment bracket assignment into one
`assign_nested_access` `ActionExpr`. Each `ActionWritePathSegment` owns its original
typed expression, source text, and half-open Unicode-scalar span. Source spelling no
longer decides harray versus array behavior.

The runtime evaluates all segment expressions from left to right and then the RHS
exactly once. Only afterward does it inspect binding presence and copy the current
root. Evaluated strings select harrays, exact nonnegative integers select zero-based
arrays, and a missing root or child is created only when the current or next selector
determines its kind. Present null and existing wrong-kind values fail rather than being
coerced; arrays may replace or append at exactly `length`, but never create a gap.

Structural work mutates only the copied root. Success publishes once and returns an
independent copy. Structural failure publishes no partial path, while ordinary
segment/RHS side effects completed before the snapshot remain visible. Reads keep
their prior non-creating behavior. Compiler, direct-runtime, generated-plan, and
source-emission boundaries reject malformed typed write carriers.

One shared permanent consumer runs unchanged on PUC Lua and LuaJIT. It also locks the
separate frontier: `map_leaves!` remains unsupported raw syntax until `.19.6.2`, and
portable/public cross-backend admission remains owned by later `.19` leaves.

Related: [[write-vivification-neutral-contract]], [[terse-nested-value-path-assignment]],
[[lua-action-edge-child-call-reuse]], [[write-vivification-receiver-mutation-direction]],
and ADR `0036`.
