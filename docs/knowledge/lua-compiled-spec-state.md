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
evidence: "LUA-BACKEND-PARITY.3.4 adds typed compile/descriptor state; .5.3.1 makes the descriptor projection consume the exact fixed-v1/variadic-v2/final-codeblock-v3 union. The complete PUC Lua and LuaJIT gates pass 153/153."
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
model identities; order/count metadata; and canonical fixed-v1, variadic-v2, or final-codeblock-v3 staged function
records.
Lua handlers are explicitly `lua_interpreter_rule` / `compiled_state_only`.
`compiled:to_json()` separately exposes typed effective internal state.

Related facts: [[lua-user-function-registry]],
[[lua-actionir-contract-resolver]],
[[outward-compiled-descriptor-four-backend-contract]],
[[dart-compiled-spec-state]], [[julia-compiled-spec-state]],
[[compilerstate-internal-model]].
