---
id: lua-string-helper-parity-closeout
title: Historical Lua scalar and String milestone recorded 76 tests per ABI
answers:
  - is Lua scalar string helper parity complete
  - what is the Lua test count after string helper closeout
  - what Lua helper family follows string helpers
date: 2026-10-26
status: historical milestone; current admission separately owned
tags: [lua, runtime, strings, regex, split, mutation, no-drift, LUA-BACKEND-PARITY]
evidence: "July12 LUA-BACKEND-PARITY.4.3.2.2.5.1; exact prior record at Git71047c4791dddd79877a9c658fb161a4166e749c for this path."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/string_comparison_result_receivers_test.lua"
---

July12's 76/76-per-ABI milestone covered its deterministic/Unicode/scalar/regex/split/mutation surface. It is historical evidence, not a current test total or complete fluent/portable admission. The old numeric-next frontier is superseded by MEMORY/task trees. Current examples use cat; concat remains retired. [[terse-string-comparison-bridge-contract]] owns the current comparison handoff. Declared5.4 and malformed-native-pattern repairs remain LUA-STARTUP-READING.2.2/.2.3; do not replay excluded malformed patterns from the old whole-run command.
