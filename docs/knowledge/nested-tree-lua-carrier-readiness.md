---
id: nested-tree-lua-carrier-readiness
title: Lua and LuaJIT nesting proof has five public routes per ABI
answers:
  - which Lua nesting carriers preserve values and Unicode spans
  - does LuaJIT nesting recovery retain the same engine
  - how are the Lua nesting emitted children verified
  - does Lua nesting proof include malformed regex handling or complete storage census
date: 2026-09-27
status: bounded carrier proof verified; storage-census repair verified separately
tags: [language-readiness, lua, luajit, generated-source, recovery, spans]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.5: each ABI passes133 v2 assertions plus51 document cases/27 round trips/24 recoveries. Five routes each execute40 original calls and three mutations; two retained engines prove28 recoveries. Fresh child status, metadata/plans/report/stderr/cleanup pass. Original storage legacy census reports an error despite exit0; .6 subsequently repairs it with30 controls and real storage proof."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/rule_local_cursor_generated_source_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/rule_local_cursor_generated_source_test.lua"
---

Native and SpecFile-JSON reconstructed engines retain their instance. Public v2 for both compiled forms and fresh
emitted modules construct an engine per call; those three routes have no retained-engine recovery claim. Shared
canonical JSON oracles preserve array/harray tags and scalar kinds. Rejection must be typed RuntimeExitNow status1;
a returned nil cannot masquerade as failure. Prefix/gap/span grammar mutations expose the intended bad behavior.

The existing v2 consumer owns the managed temporary workspace. Four emitted modules load in the exact selected
ABI using current source/native paths. Actual success, empty stderr, exact completion and workspace removal are
required. No runtime, fixture, contract, storage mechanism or malformed-regex behavior changes in this leaf.

The original storage oracle's failed legacy census remains incomplete evidence; its subsequent repair passes30
controls and the real dual-ABI storage check: see [[lua-storage-census-failure-status]]. Canonical reconciliation remains. No unfiltered Lua gate or format admission is claimed.
Related: [[nested-tree-public-native-readiness]], [[lua-generated-source-fresh-process-isolation]].
