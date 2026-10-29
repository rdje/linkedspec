---
id: lua-local-match-writer-presence-compatibility
title: Safe Lua local-match mark writers already preserve targets when endpoints are absent
answers:
  - "does Lua mark_match_start preserve existing marks without a local match"
  - "does Lua evaluate local writer names before checking match presence"
  - "did Lua local-match writer absence need a runtime repair"
  - "which installed Lua hosts verify missing local-match writer targets"
date: 2026-10-29
status: bounded49.5 compatibility verified on PUC5.5/LuaJIT; selection/declared5.4/full admission separate
tags: [lua, luajit, marks, writer, match, absence, endpoint, mutation]
evidence: "lua-writer-endpoint-intake.json.gz retains15-source/four-route compatibility,429 selected checks and actual wrong-oracle3fail102pass per installed host."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/named_writer_endpoint_absence_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/named_writer_endpoint_absence_test.lua"
---

evaluate_named_mark_helper evaluates the mark name before selecting a local
writer. mark_match_start/end then require current local_match before selecting
byte_start/end and calling the validated write_mark owner. Missing local matches
therefore add no write or deletion after authored name effects; other writers
retain their own endpoints. No runtime/generated-source repair is required.

## Safe Lua compatibility49.5 (2026-10-29)

Installed PUC5.5/LuaJIT2.1.1788460057 independently pass all15 native/restored/plan/
separate emitted cases. Existing name evaluation then nullable local_match guard
before validated write_mark already preserves fresh/seeded/name-effect targets
and real empty/zero/Unicode/local-live cursor behavior. No runtime edit. Writer105/
named endpoint105/named Number-function-scope219 pass429 checks per host, empty
healthy stderr/syntax loads. Wrong first-mark oracle3fail102pass per host, actual
fixture/runtime unchanged, no product RED. Full source/normalized/compiled/plan/
emitted/metadata/results/debug traces retained, runtime/emitter/fixture match HEAD,
no regeneration. Packet lua-writer-endpoint-intake.json.gz retains closure. Normal
run.lua registration verified; exact selection23.4.1/declared5.4/unsafe formatter/
phase/full admission remain separate. Bounded49.0-.5 focused work complete on
recorded routes/hosts; parent admission open,48/45 precede wider features/push.
