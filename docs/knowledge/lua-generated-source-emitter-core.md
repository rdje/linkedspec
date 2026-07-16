---
id: lua-generated-source-emitter-core
title: Lua generated-source core emits deterministic exact effective state without claiming plan admission
answers:
  - how do I emit generated Lua source
  - what does emit_lua_source_v1 return
  - what metadata does a generated Lua module expose
  - how does generated Lua preserve fixed variadic and codeblock functions
  - is generated Lua standalone or optimized
  - which generated Lua roles are still pending
  - what errors can the Lua source emitter return
date: 2026-07-16
status: current
tags: [lua, generated-source, source-emitter, metadata, errors, utf8, callable-signature]
evidence: "LUA-BACKEND-PARITY.8.1.1 adds lua/src/linkedspec/source_emitter.lua and public exports. Equivalent CompiledSpec plus identity emits byte-identical ASCII native Lua. Source-ordered function registry definitions preserve fixed-v1 params/arity, variadic-v2 signature/rest, and final-codeblock-v3 parameter_kinds; compiled_rule_order preserves last-definition effective rules. spec_ast JSON is canonical strict UTF-8 and embedded with identity as lowercase hex. Loaded modules expose metadata(), execute(), and execute_with_trace(); typed portable emit/compile-load/execution failures retain identity and attribution. LUA-BACKEND-PARITY.8.1.2 adds exact fresh-process valid/corrupt load-run-cleanup proof; .8.2 adds plan()/validate_plan(), exact ten-family authoritative nested execution, portable trace, all-family isolation, and emitted variadic proof; .8.3 adds exact contract-ordered interpreter-first 8/105 fresh-host load/value/metadata/plan/trace proof. PUC Lua and LuaJIT each pass 177/177; canonical reference CLI is 61x2 and Phase 0 is 1031/1031 in 620 seconds. Census .8.4 remains."
reverify: "bash tools/run_lua_local.sh; perl tools/check_generated_source_contract.pl; rg -n 'emit_lua_source_v1|LINKEDSPEC_GENERATED_SOURCE|function M.execute' lua/src/linkedspec/source_emitter.lua lua/test/run.lua lua/README.md docs/linkedspec-book/src/public-api/native-spec-loading.md"
---

Use `emit_lua_source_v1(compiled, source_identity)` when the artifact needs a
stable caller identity. `emit_lua_source(compiled)` is the compatibility form
and uses `<inline>`. Both return module source; neither writes a file.

The emitter normalizes only effective compiled state. It copies immutable
source-ordered function definitions from `function_registry.entries`, selects
rules in `compiled_rule_order`, and rebuilds a typed `SpecFile`. That retains
the exact permanent callable union:

- fixed-v1 `params` and `arity`;
- variadic-v2 `signature`, including its rest parameter;
- final-codeblock-v3 fixed params/arity plus final-only `parameter_kinds`.

`spec_ast.to_json` plus canonical `json.encode` supplies a sorted-key strict-
UTF-8 payload. Payload and Unicode identity become lowercase ASCII hex, so the
generated host source has no Unicode-literal/interpolation ambiguity. Equivalent
state and identity therefore return the same bytes.

Loading the module reconstructs and compiles the typed spec through public Lua
APIs, creates the ordinary runtime engine, and exports `metadata()`,
`execute(input, options)`, and
`execute_with_trace(input, trace_config, options)`. The execution functions
return the direct runtime value, not its result envelope. The generated module
still requires `linkedspec`; it is not a bundled runtime or an optimization
claim.

Contract-v1 metadata and typed portable errors are current. Fresh-process PUC
Lua/LuaJIT persistence, corrupt-payload behavior, and cleanup are recurring
proof under `.8.1.2`. `plan()` and ten-family validation/execution plus portable
generated-family trace roles are current under `.8.2`; the contract-sourced
8/105 proof is closed under `.8.3`, and sole census promotion remains `.8.4`.

Related facts: [[lua-generated-source-scaffold-split]],
[[lua-generated-source-fresh-process-isolation]],
[[lua-generated-source-family-plan]],
[[lua-generated-source-accepted-subset]],
[[generated-source-contract-v1]], [[lua-outward-function-descriptor-union]],
[[lua-final-codeblock-metadata]], [[optional-native-parser-acceleration]].
