---
id: lua-compiled-spec-state
title: Lua compile_spec builds ordered rule, dependency-regex, payload, and exact descriptor state
answers:
  - where is the Lua compiled spec state
  - does Lua have compile_spec
  - how does Lua project descriptor JSON
  - where does Lua build dependency regex data
  - does Lua compiled state carry ActionIR payloads
  - does Lua match the outward descriptor contract
  - does Lua snapshot source before compilation
date: 2026-07-11
status: current
tags: [lua, compiler, compiled-state, descriptor, dependency-regex, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.3.4 adds lua/src/linkedspec/compiled_spec.lua and exports compile_spec plus typed compiled rule/mode/edge/payload/dependency/descriptor state; .4.1 consumes compiled rules in matching. Five focused compiler tests plus five matching tests pass in the 60/60 PUC Lua and LuaJIT gate."
reverify: "bash tools/run_lua_local.sh && perl tools/check_language_capability_coverage.pl"
---

## Fact

Lua compiled-state construction lives in
`lua/src/linkedspec/compiled_spec.lua`.

`compile_spec(spec[, options])` validates by default and snapshots the typed
`SpecFile`, then carries the ordered user-function registry into a typed
`CompiledSpec`. It records source `definition_order`, deterministic
last-definition `compiled_rule_order`, `redefined_rule_labels`, and effective
rules keyed by label. Each `CompiledRule` contains source header/body identity,
neutral mode metadata, regex patterns, dependency refs, action/blind edges,
lifecycle/plain payloads, parsed ActionIR, and registry-aware contracts.

Action edges without a same-line parent regex validate and copy the referenced
child slot into their effective regex row. `CompiledDependencyRegexState`
retains structured refs, pattern rows, and combined-pattern metadata; `.3.4`
does not execute or host-compile regexes.

`compiled:to_descriptor_json()` matches
`capability_conformance/outward_descriptor_contract.json`: exact top-level
`spec`, `functions`, `dependency_regex_map`, and `meta` keys; exact composing
model identities; order/count metadata; and canonical staged function records.
Lua handlers are explicitly `lua_interpreter_rule` / `compiled_state_only`.
`compiled:to_json()` separately exposes typed effective internal state.

Related facts: [[lua-user-function-registry]],
[[lua-actionir-contract-resolver]],
[[outward-compiled-descriptor-four-backend-contract]],
[[dart-compiled-spec-state]], [[julia-compiled-spec-state]],
[[compilerstate-internal-model]].
