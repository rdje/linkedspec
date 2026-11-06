---
id: lua-key-count-result-guards
title: Installed Lua CountKeys preserves Count ownership and scalar mutation boundaries
answers:
  - "how does Lua guard ordinary CountKeys result continuations"
  - "why does Lua false count_keys remain null while free false returns zero"
  - "can Lua free Count results regain CountKeys initial zero"
  - "does Lua key-count guarding add interpreter chunk locals"
  - "does Lua CountKeys repair change scalar_result or loop-index mutation rights"
  - "must Lua CountKeys emitted modules be regenerated"
date: 2026-11-06
status: bounded installed-host Lua75.5 focused-checked; callable75.6/full admission pending
tags: [lua, count_keys, count, guards, scalar, source, mutation, copy, logical, with]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.75.5; docs/checkpoints/key-count-guard-lua-2026-11-06/REVIEW.md retains actual first inputs/modules/full raw epochs. Each host25 groups13PASS12RED become25PASS/four routes; thirteen healthy exact and25 module/parsed bodies unchanged. New126/Count92/Length122 and Count-length programs pass; seven recovery corruptions reject."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/key-count-guard-lua-2026-11-06/review.py"
  - "bash tools/run_lua_project_data.sh puc lua/test/key_count_result_guard_composition_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/key_count_result_guard_composition_test.lua"
---

Canonical free-one/zero-extra CountKeys roles join common kind ownership before
Count permission. Separate first-step KeyCount permission skips only common guard
and excludes free Count ownership. Produced Number/zero rejects incompatible
operands and later copy/logical/with bodies. Initial zero and explicit bridges
remain valid; free Count1/0 cannot regain KeyCount zero. Use the existing namespace,
adding no interpreter chunk locals. scalar_result initialization/assignments/
scalar guard, Count permission and loop-index Array-end mutation rights stay exact.
Producers/domains/signatures/copy/parser/schema remain unchanged.

PUC5.5.1 and LuaJIT2.1.1788460057 independently freeze free domain
[0,0,0,0,0,0,2], receiver[0,0,null,0,0,0,2] and per-route error flags/code/wrapper
before production. Thus count_keys(false)=0 while false.count_keys() stays null.
Each25 programs13PASS12RED becomes25PASS/four routes, thirteen healthy exact.
All25 module texts/parsed inputs per host remain unchanged. New126/Count92/
Length122 checks and two Count/length programs/native-plan-fresh pass per host,
with empty final stderr, loadfile checks and one three-line normal registration.
No unsafe full runner/formatter/declared5.4 inference. Rebuild Lua apps/runtime;
no source-regeneration or generated-format movement is required.

Actual declared direct source/fixture/wrapper/writer inputs and pre-run modules/
parsed data recover byte/mode-exactly with full raw channels; seven effective
corruptions reject. Fresh modules share process/runtime. No native host seeding
or full transitive/toolchain closure4.2/general isolation/source-context discovery/
callable75.6/full23.4 admission follows. Historical recovery is not latest-runtime
proof. Current frontier belongs to MEMORY.md.
