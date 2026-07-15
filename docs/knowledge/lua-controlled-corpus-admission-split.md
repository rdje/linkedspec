---
id: lua-controlled-corpus-admission-split
title: Lua controlled corpus admission closes one nested-assignment segment-kind defect
answers:
  - what are the Lua controlled core corpus windows
  - which corpus offsets does LUA BACKEND PARITY 6.1 own
  - how many Lua controlled corpus cases pass before repair
  - how many Lua controlled corpus cases pass after nested path repair
  - which Lua core corpus fixture fails before admission
  - why does Lua add a numeric zero key to a nested hash assignment
  - what is the Lua nested mixed value path assignment corpus failure
  - which task repairs Lua nested assignment path kinds
  - when will Lua add a library corpus executor
date: 2026-07-15
status: current
tags: [lua, corpus, assignment, nested-access, task-tree, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.6.1.0 runs disposable manifest-ordered PUC Lua and LuaJIT probes through automatic parse, validate, compile, engine, and runtime APIs. Both pass 45/46 across offsets 0-39 and 99-104. Offset 20 alone mismatches because assign_nested_access passes evaluated values to generic read_index/write_index without enforcing the parsed segment kind; numeric index 0 into a harray becomes string key 0."
evidence_update_2026_07_15_segment_kind_repair: "LUA-BACKEND-PARITY.6.1.1 preserves typed key/index segments, governed all-segments-then-RHS evaluation order, and copy/store-on-success assignment. Exact offset 20 passes unchanged, both owned windows pass 46/46 on PUC Lua and LuaJIT, and focused suites pass 157/157."
evidence_update_2026_07_15_core_prefix_admission: "LUA-BACKEND-PARITY.6.1.3 permanently executes exact manifest offsets 0-39 through the library executor. All 40 pass in order with exact wrapped expected output and byte/character endpoint 1; PUC Lua and LuaJIT pass 161/161."
reverify: "bash tools/run_lua_local.sh && rg -n 'assign_nested_access|local function read_index|local function write_index' lua/src/linkedspec/interpreter.lua && sed -n '1,40p' rust/linkedspec-runtime/tests/corpus/terse_11_4_nested_mixed_value_path_assignment/input.spec && sed -n '1,80p' rust/linkedspec-runtime/tests/corpus/terse_11_4_nested_mixed_value_path_assignment/expected.json"
---

`LUA-BACKEND-PARITY.6.1` owns two exact ordered manifest windows: the 40-case core prefix at offsets 0-39 and the
six governed capability fixtures at offsets 99-104. Advanced helpers, function cases, recursive cases, and shipped
specs at offsets 40-98 remain under `.6.2`.

Before production corpus-execution code, disposable native probes ran both owned windows through Lua's existing
automatic spec-defined parser, validation, compilation, source-identified engine, and runtime layers. PUC Lua and
LuaJIT produce the same result: 45/46 pass exactly. Every governed capability fixture passes, as do 39 of 40 core
fixtures. The sole residual is offset 20, `terse_11_4_nested_mixed_value_path_assignment`; it parses, validates,
compiles, matches, and reaches the expected endpoint, but its output is structurally wrong.

The governed assignment contract is already recorded in [[terse-nested-value-path-assignment]]: numeric index
segments traverse arrays, key segments traverse hashes, missing or wrong-kind intermediates do not autovivify, and
a rejected path returns null without mutating the root. Before `.6.1.1`, Lua's `assign_nested_access` evaluated
each segment but then called kind-generic `read_index(...)` / `write_index(...)`. For
`payload["items"][0][0] = "bad"`, the final numeric index therefore reaches a hash and is stringified into key
`"0"`; the invalid mutation leaks into `payload` and the assignment returns that root instead of null.

Repair `.6.1.1` keeps the parsed segment tag through every transition. Key segments require harrays; index values
normalize to finite nonnegative integers and require arrays. Nested assignment evaluates all segment expressions,
then RHS, before root/path validation; it mutates a deep copy and stores only after complete success. Exact offset
20 now passes without changing its source, expected JSON, or cursor, and both owned windows pass 46/46 on PUC Lua
and LuaJIT. Focused suites pass 157/157.

Planning leaf `.6.1.0` changes no runtime or fixture. It dependency-orders the work:

- `.6.1.1` preserves segment kind and repairs only this wrong-shape mutation (done);
- `.6.1.2` adds reusable library corpus execution and controlled result/failure proof (done);
- `.6.1.3` permanently admits exact offsets 0-39 on both Lua ABIs (done: 40/40, endpoint 1/1, 161/161);
- `.6.1.4` permanently admits offsets 99-104, closes `.6.1` no-drift, and activates `.6.2`.

Related facts: [[lua-runtime-core-value-capture-helpers]], [[terse-nested-value-path-assignment]],
[[lua-corpus-manifest-io]], [[lua-string-corpus-proof-routing]], [[lua-descriptor-trace-closeout]].
