---
id: lua-named-capture-endpoint-origin-compatibility
title: Safe Lua named capture takes already preserve named origins and missing endpoints
answers:
  - "does Lua capture_take with a name preserve the anonymous capture boundary"
  - "does Lua named capture_take evaluate names when no local match exists"
  - "did Lua named capture endpoint absence need a runtime repair"
  - "which installed Lua hosts pass the named endpoint and take origin target"
date: 2026-10-29
status: bounded47.5 compatibility verified on PUC5.5/LuaJIT; declared5.4/selection/full admission separate
tags: [lua, luajit, capture, mark, absence, endpoint, mutation]
evidence: "lua-named-capture-endpoint-intake.json.gz retains15-source/four-route compatibility,436 focused checks and actual3-failure wrong-oracle control per installed host."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/named_capture_endpoint_absence_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/named_capture_endpoint_absence_test.lua"
---

evaluate_named_mark_helper owns both named readers/takes and existing writers.
Dispatch selects it for capture_take with arguments before anonymous processing.
It evaluates the first mark name, uses the nullable local-match left byte edge,
and passes both endpoints through anonymous_capture_span's existing validity
guard. Only a successful result advances its named mark; the anonymous boundary
is separate. Cursor/rest/between families use their own available endpoints.

## Safe Lua compatibility47.5 (2026-10-29)

Installed PUC5.5 and LuaJIT2.1.1788460057 independently pass all15 on native/restored/
plan/separate-process emitted routes. Existing explicit named take dispatch/name
evaluation/nullable local-match byte endpoint/valid-only typed span and mark update
already preserve named/anonymous origins and failed takes; no runtime repair.
Named105/anonymous112/named Number-function-scope219 pass436 checks per host,
empty stderr/syntax loads. Wrong root empty-text oracle fails3 values/102pass per
host, actual fixture unchanged; no product RED claim. Exact source/normalized/
compiled/plan/emitted/full metadata/results/traces retained, runtime/emitter/fixture
match activation HEAD, no regeneration. New normal/run.lua registration verified;
selection23.4.1/declared5.4/unsafe formatter/phase/full admission remain separate.
Packet lua-named-capture-endpoint-intake.json.gz retains closure. Bounded47.0-.5
targeted-checked; writer49/referenced-blind48/Phase0 owner45 precede wider features.
