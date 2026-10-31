---
id: lua-push-snapshot-result-guards
title: Safe Lua explicit push snapshots use existing actual-kind result guards
answers:
  - "why does Lua push set_key evaluate incompatible operands"
  - "which Lua owner guards explicit push snapshot methods"
  - "does Lua selected pushed Bool take already skip operands"
  - "does Lua push snapshot composition add interpreter chunk locals"
date: 2026-10-31
status: installed PUC5.5.1/LuaJIT58.5 targeted-checked; full admission separate
tags: [lua, push, array, selection, fluent, guards]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.58.5; push-snapshot-lua-intake.json.gz retains actual producers/inputs/65 checks57PASS8RED to65PASS per host, six computed programs/loadfile/version. Original57 includes two compile scaffolds."
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/push_result_composition_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/push_result_composition_test.lua"
---

At7112f1859 direct Array/selected String Hash consumers retain their value and
execute KV. Selected Bool take already skips operands via scalar_result. Full12,
order/snapshot/local returns/functions/copy/logical/with/absence/errors/static-
child action-edge control already work. Two source guard roles omit push.

receiver_mutation.is_explicit_push_result_source now admits canonical exact two
positional args/plain target and recognized value ASTs to existing direct and
computed guards. Static rule target names/bare-numeric/contextual trailing forms
excluded. Function attaches to the existing namespace, no interpreter chunk local
addition. Original push/child ABI/parser/methods/with/copy/function/arity/schema and
remaining interpreter exact; runner gains three lines.

Same65 checks57PASS/8RED to65PASS per installed PUC5.5.1/LuaJIT2.1.1788460057.
Original57 includes two passing compile scaffolds in failing groups. Eleven
values/two errors retain native/restoredSpec/plan/fresh module in one process;
nine healthy values/all errors byte-equal. Six computed programs/18 route
observations/loadfile/version pass per host, focused stderr empty. Rebuild
runtime/apps; no declared5.4/unsafe full runner/formatter/isolated package or
exhaustive outside-shape/full admission claim. Selection23.1.20 continues features.
