---
id: lua-exhaustive-runtime-call-audit
title: Lua's 246-name runtime audit isolates three logical helper gaps and thirteen non-function surfaces
answers:
  - how many Lua current call names reach a runtime owner
  - which Lua current calls are still unsupported after diagnostic output
  - why are thirteen Lua current names allowed to reject function form
  - does Lua execute and or not yet
  - what does LUA-BACKEND-PARITY 4.3.9.0 prove
date: 2026-07-15
status: current
tags: [lua, runtime, helpers, logical, no-drift, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.9.0 generates a minimal action for every exact name in lua/src/linkedspec/action_call_names.lua and runs each through Lua parse, compile, and execution with a disposable PUC Lua PCRE2 adapter. Of 246 unique names, 230 reach an owner and 16 report unsupported runtime helper. Thirteen are intentionally structural or named-receiver-only; the exact missing value family is and/or/not. The audit also finds stale runtime-numeric-reducers status, a duplicate source or row, and missing focused direct call(rule) proof."
evidence_update_2026_07_15_logical: "LUA-BACKEND-PARITY.4.3.9.1 implements the exact three logical gaps eagerly over runtime_truthy and passes 123/123 on PUC Lua and LuaJIT. The remaining .4.3.9.2 closeout must make the probe recurring and report exactly the thirteen intentional non-function surfaces, while also covering direct call(rule), duplicate inventory cleanup, status, and parent closure."
reverify: "bash tools/run_lua_local.sh && perl tools/check_language_capability_coverage.pl --report"
---

The exhaustive Lua closeout does not infer execution from inventory equality or corpus source occurrence. Its
generated probe passes every one of the 246 admitted source names through the Lua parser, compiler, and runtime.
The measured partition before logical repair is:

| Result | Count | Names |
| --- | ---: | --- |
| Reaches a runtime owner | 230 | All admitted names except the sixteen below. |
| Intentional non-function surface | 13 | `case`, `elif`, `elseif`, `i`, `when`, `while`; receiver-only `walk_leaves`, `map_leaves`, `reduce_leaves`; named-receiver-only `push_back`, `push_front`, `pop_back`, `pop_front`. |
| Missing value helper | 3 | `and`, `or`, `not`. |

The thirteen names remain admitted because their documented current syntax is structural or receiver-bound; a
bare `name()` function probe is deliberately not their executable form. `LUA-BACKEND-PARITY.4.3.9.1` has now
closed eager logical execution at 123/123 on both ABIs. `.4.3.9.2` owns a permanent exact partition check, direct
`call(rule)` proof, duplicate inventory cleanup, public status correction, and parent closeout.

Toolbox probes also exposed a separate reference issue: Perl lowering emits `return and(...)` / `return or(...)`,
where keyword precedence returns `undef` instead of the documented boolean helper value. Rust, Dart, and Julia
already execute eager boolean composition. That cross-backend truthiness/arity/lowering decision is not hidden in
the Lua repair; dependency-gated `FUTURE-PARITY-BACKLOG.5.2` owns it.

Related facts: [[lua-runtime-helper-family-split]], [[lua-logical-helper-execution]], [[julia-logical-helper-execution]],
[[cross-backend-condition-truthiness-drift]], [[public-call-inventory-independent-coverage]].
