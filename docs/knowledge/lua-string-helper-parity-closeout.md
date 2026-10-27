---
id: lua-string-helper-parity-closeout
title: Lua String helper milestone and bounded scalar result flow
answers:
  - why do Lua replacement and affix identities lose Number or Boolean kind
  - why does PUC substr with a large width return empty text at start one
  - is Lua scalar string helper parity complete
  - what is the Lua test count after string helper closeout
  - what Lua helper family follows string helpers
date: 2026-10-27
status: historical milestone; bounded String19.5/arguments20.3 targeted-checked
tags: [lua, runtime, strings, regex, split, mutation, no-drift, LUA-BACKEND-PARITY]
evidence: "July12 LUA-BACKEND-PARITY.4.3.2.2.5.1; exact prior record at Git71047c4791dddd79877a9c658fb161a4166e749c for this path."
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/scalar_string_results_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/scalar_string_results_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test/substring_optional_arguments_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/substring_optional_arguments_test.lua"
---

July12's 76/76-per-ABI milestone covered its deterministic/Unicode/scalar/regex/split/mutation surface. It is historical evidence, not a current test total or complete fluent/portable admission. The old numeric-next frontier is superseded by MEMORY/task trees. Current examples use cat; concat remains retired. [[terse-string-comparison-bridge-contract]] owns the current comparison handoff. Declared5.4 and malformed-native-pattern repairs remain LUA-STARTUP-READING.2.2/.2.3; do not replay excluded malformed patterns from the old whole-run command.

TYPE23.3.19.5 independently reproduces textified scalar identities/null operands,
typed index errors and[]/SCA/malformed SAC on both safe hosts/native-plan-fresh.
Preserve primitive Number/Boolean identities with explicit false-safe returns,
guard null operands and add eight-method scalar/shape checks, no new module
locals. Regex/other converted carriers retain text; free/global int/numeric/
selector/Unicode/callback/format domains stay. Strict eight-group canonical JSON,
direct defaults and interpreter/runner loads pass both hosts, covering shared
kinds/indices/Unicode/SONC-SC-selectedS/eager null/rejection/12 malformed controls
and both mutation aliases. TYPE23.2.20 then freezes existing Perl-reference slice
semantics:20.3 adds ordinary explicit-null width and branch-local Boolean1/0,
preserving global runtime_integer/legacy arities/module locals. Shared/legacy/
direct String checks pass native/plan/fresh on both safe hosts after RED, retaining
SIWC/source snapshots and clipped intervals. [[substring-optional-arguments]]
owns the bounded result; full admission/declared5.4 remain separate.

A related PUC defect is actual, not inferred: large_end/native-plan-fresh returns
[abc,empty,empty] for large positive width at offsets0/1, while LuaJIT gives
[abc,bc,bc]. start+width wraps before character conversion. Clip width to the
remaining character interval before addition and early-return an out-of-range
start; new free/receiver regression passes both hosts. Source/probe/fixture:
scalar_string_results_test.lua/probe_scalar_string_lua.lua and the frozen
scalar-string-results.md. No full runner/malformed native patterns/declared5.4,
magnitude matrix, whole-family or portable admission from this bounded proof.
