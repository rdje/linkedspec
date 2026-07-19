---
id: lua-generated-source-family-plan
title: Generated Lua uses an exact ten-family plan as authoritative nested dispatch
answers:
  - does generated Lua expose a family plan
  - what generated rule families does Lua support
  - does the generated Lua plan control execution
  - what generated Lua plan errors exist
  - what portable trace roles does generated Lua emit
  - how is the generated Lua all-family matrix tested
  - why must Lua generated repetition classification use mode names
  - does generated Lua preserve variadic rest arrays
date: 2026-07-19
status: current at generated-source v2
tags: [lua, generated-source, family-plan, direct-execution, trace, variadic, PUC-Lua, LuaJIT]
evidence: "LUA-BACKEND-PARITY.8.2 adds typed GeneratedPlanRow APIs, exact classification/order/validation/execution in lua/src/linkedspec/source_emitter.lua, plan-authoritative nested dispatch and portable trace in lua/src/linkedspec/interpreter.lua, public exports, and three permanent tests. One 26-row combined spec covers all ten root families and nested rows; four mutations lock row-count/label/family/unknown-family errors; a fresh emitted all-family module runs through exact PUC Lua/LuaJIT hosts with cleanup; the neutral variadic fixture reconstructs and executes typed rest arrays. Initial DefaultRoot classification as rep_acode proved Lua's broad native is_repetition flag includes ordinary default scanning, so generated classification uses the exact seven explicit repetition mode names. Both ABIs pass 176/176; primary is 61x2, corpus 105/105, capability 64/0/0, and canonical Phase 0 1031/1031 in 626 seconds."
reverify: "bash tools/run_lua_local.sh; perl tools/check_generated_source_contract.pl; rg -n 'build_generated_rule_plan|validate_generated_rule_plan_v2|generated_rule_enter|generated_family_decision|generated_rule_exit|generated Lua plans classify' lua/src/linkedspec/source_emitter.lua lua/src/linkedspec/interpreter.lua lua/src/linkedspec/init.lua lua/test/run.lua"
---

Lua generated-source v2 uses the exact ten family names: `default`, `or_acode`,
`and_single_acode`, `and_acode_seq`, `and_bcode`, `or_bcode`, `rep_acode`,
`rep_bcode`, `rep_and_acode`, and `rep_and_bcode`.
`build_generated_rule_plan(...)` classifies effective compiled rule order into
typed source-ordered rows. Emitted modules expose a fresh copy through `plan()`
and validate any caller-supplied copy through `validate_plan(actual)`.

Validation runs before execution and distinguishes exact row-count, ordered-
label, known-family mismatch, and unknown-family failures. Unknown families are
rejected before expected-family comparison. The returned per-label map is
threaded through every root and nested runtime call and selects regex versus
blind dispatch. Native execution has no generated map and continues selecting
from compiled structure, so the plan is authoritative without forking ordinary
interpreter behavior.

Generated traced execution retains native trace and adds
`generated_rule_enter`, `generated_family_decision`, and
`generated_rule_exit` at low level. Each event carries source identity and rule;
decision and exit events carry the neutral family. Root and nested events are
both permanent proof.

Lua's native `mode_metadata.is_repetition` is deliberately broader than the
generated-source family contract: it also describes ordinary default scanning.
Generated classification must therefore enumerate the exact seven explicit
repetition modes (`Plus`, `Star`, `Optional`, `OrPlus`, `AndPlus`, `OrBounded`,
and `AndBounded`). Using the native boolean misclassifies `Default` as
`rep_acode`.

One combined 26-row specification proves all ten root families and nested
dispatch, compares every generated direct value with the native interpreter,
and locks all four rejections plus attributed execution failure. The same spec
runs as one persisted generated module in fresh PUC Lua and LuaJIT hosts with
exact trace and cleanup. The neutral callable-signature fixture also survives
emission and executes mixed/empty fresh typed rest arrays; no host vararg
semantics are introduced.

Exact contract-sourced interpreter-first 8/105 admission is closed under
`.8.3`; final census admission closes under `.8.4` at five-backend 80/0/0.
Rule-local cursor leaf `.9.1.7.4` now derives the five seek and five consume policies from these rows, classifies
compact Pipe as OR, and rejects v1 before payload reconstruction; see [[lua-generated-source-v2-rule-local-cursor]].

Related facts: [[generated-source-contract-v1]],
[[lua-generated-source-emitter-core]],
[[lua-generated-source-accepted-subset]],
[[lua-five-backend-capability-admission]],
[[lua-generated-source-fresh-process-isolation]],
[[lua-generated-source-scaffold-split]], [[lua-backend-full-parity-plan]].
