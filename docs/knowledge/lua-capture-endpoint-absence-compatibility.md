---
id: lua-capture-endpoint-absence-compatibility
title: Safe Lua hosts already preserve unavailable anonymous capture endpoints and failed take boundaries
answers:
  - "does Lua capture_slice_len return null before a local match"
  - "does Lua capture_take advance its boundary without a local match"
  - "did safe Lua need a runtime repair for anonymous endpoint absence"
  - "which Lua regression distinguishes missing endpoints from real empty matches"
date: 2026-10-29
status: bounded40.5 independent dual-host compatibility and normal registration verified; declared5.4/named/canonical selection/full admission separate
tags: [lua, capture, endpoint, absence, presence, mutation, generated]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.40.5 lua-capture-endpoint-intake.json.gz retains16-source SDK/restored/plan/separate-process emitted compatibility,1411 selected assertions and actual three-failure wrong-oracle control per safe installed host."
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/capture_endpoint_absence_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/capture_endpoint_absence_test.lua"
---

evaluate_anonymous_capture_helper in lua/src/linkedspec/interpreter.lua leaves
end_byte unset without local_match; anonymous_capture_span returns json.null before
take mutation. Cursor/rest readers choose their own endpoints. Present empty/zero/
Unicode remain valid. Existing nullable register/span owners need no runtime repair.

Independent current16-source native/restored full matched/value/Unicode cursor/
output/lifecycle/debug traces, plan and separate-process emitted modules pass on
safe installed PUC5.5 and LuaJIT2.1.1788460057. Full input/generated/public metadata/
actual observations retained per host. Registered normal112/Number155/aliases638/
qualified-null506 pass1411 assertions per host; existing2 blind-LE inputs remain
39.4.5.2.2-owned. Temporary wrong empty-text expectation at root_blind_I fails3
value-route checks per host,109 pass; no product RED. Runtime/compiler/emitter/
shared fixture exact base bytes, no persistent interpreter chunk local added.

Fresh process loads retained emitted modules using current project/native products,
no isolated dependency workspace. No helper/policy/schema/generation change,
regeneration requirement, declared5.4/unsafe formatter/named/peer/full component or
admission credit. Bounded40 complete on recorded routes/hosts; exact canonical
selection23.4.1, nested-error41/named47/Phase0 owner45 remain separately owned.
