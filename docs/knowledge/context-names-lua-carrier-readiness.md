---
id: context-names-lua-carrier-readiness
title: Lua and LuaJIT preserve closing-name context across five routes per ABI
answers:
  - which Lua and LuaJIT carriers preserve closing-name context and typed statuses
  - how many retained Lua context-name recovery transitions are verified
  - how are fresh Lua context-name emitted children validated
date: 2026-09-27
status: bounded dual-ABI carrier proof verified; canonical context reconciliation remains
tags: [language-readiness, context, lua, luajit, generated-source, recovery]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.6 passes160 v2 assertions per ABI plus51 document cases/27 round trips/24 recoveries. Each ABI verifies five routes with90 calls/three mutants each and68 recoveries on two retained engines. Both fixture children require actual success, empty stderr, exact metadata/plans/report and cleanup. Storage passes19 owners/three dual-ABI modules/30 census controls."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/rule_local_cursor_generated_source_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/rule_local_cursor_generated_source_test.lua"
---

`docs/language-readiness/context-names.md` owns exact scope and commands. Native and SpecFile-JSON reconstructed
engines retain their instance across34 typed rejection/immediate-success pairs each. Generated v2 on both
compiled forms and the emitted entry create engines per call. Failed pcall, the public RuntimeExitNow predicate
and authored1/2/3 are all required; successful nil cannot satisfy rejection. Canonical JSON preserves the
array/harray tags and scalar kinds as well as exact authored values and Unicode spans.

The existing managed v2 consumer takes explicit fixture options and preserves nesting defaults. Both unchanged
source/oracle pairs run natively and in fresh selected-ABI children. Four emitted modules per fixture require
v2 metadata/identity/plan validity, actual execution, exact reports, empty stderr and owned-workspace cleanup.
The repaired real storage gate passes all30 census controls and19 owners. No production, fixture, dependency,
generated-format or storage-policy change. The known malformed-regex path remains separately owned; no
unfiltered full Lua gate or broader format admission is claimed.
Related: [[nested-tree-lua-carrier-readiness]], [[context-names-public-native-readiness]],
[[lua-storage-census-failure-status]].
