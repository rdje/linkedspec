---
id: lua-callable-codeblock-emitted-route-identity
title: Lua callable codeblocks retain one typed state and executor across emitted routes
answers:
  - "does Lua execute callable codeblocks from emitted source"
  - "does a fresh Lua generated module preserve codeblock literals"
  - "how are Lua codeblocks serialized into generated source"
  - "does Lua generated source create host closures for codeblocks"
  - "do Lua native reconstructed generated and emitted callable routes agree"
  - "can Lua with receive an explicit or bound codeblock value"
  - "when does Lua resolve a final callback relative to scoped value"
  - "why are nested Lua with callbacks not codeblock recursion"
  - "does Lua detect recursion when a bound callback is passed through with"
  - "how are Lua emitted callable temporary files stored and cleaned"
  - "how many Lua temporary allocation owners exist"
date: 2026-08-01
status: current
tags: [lua, luajit, callable, codeblock, generated-source, serialization, storage, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.8.3 proves the unchanged typed callable record and runtime detail through native compilation, canonical effective-SpecFile JSON reconstruction, generated-plan execution, and independently loaded emitted modules on PUC Lua and LuaJIT. One executor handles bound and built-in final callbacks; anonymous callbacks omit helper-name recursion tracking, while callbacks passed by variable retain that binding identity and dynamic direct/mutual/helper-mediated recursion remains ordered. The focused consumer passes 449 assertions per ABI, complete Lua passes 177 TAP groups per ABI with CLI 66x2 and corpus 105/105, and the storage oracle registers the consumer as exact Lua owner 17. Neutral+20, signatures 3/9/7, capability 80/0/0, Knowledge Map 779/6,322, mdBook 79/14,048 KiB, all doctrines, and canonical Phase 0 1,031/1,031 in 809 seconds plus the four-backend callable matrix complete signoff."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/callable_codeblock_literal_contract_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/callable_codeblock_literal_contract_test.lua && bash tools/test_lua_project_data_storage.sh && bash tools/run_lua_local.sh"
---

# Lua Callable-Codeblock Emitted Route Identity

Lua generated source retains one canonical, strict-UTF-8 effective `SpecFile` as lowercase ASCII hex. A fresh
module decodes that payload, reconstructs the typed AST through `spec_ast.from_json`, compiles it normally, builds
the existing generated plan, and enters the ordinary interpreter. Callable literals therefore remain the same
eight-field data records across native, reconstructed, generated-plan, and independently loaded emitted routes.
The emitter contains no Lua closure body, host function value, callable-specific codec, or generated-only executor.

Built-in final-codeblock dispatch now validates a callback value rather than requiring authored `block_value`
syntax. Authored contextual blocks remain zero-positional callable data; explicit or bound literals receive the
helper/receiver/tree scoped value according to their signature. Callback expressions resolve before the helper
installs its scoped `value`, so even a callback stored in the caller binding named `value` remains callable and the
binding restores afterward.

All callback bodies enter `callable_codeblock.execute_values`. Ordinary `cb(args)` dispatch tracks the bound name
in `active_codeblocks`, preserving exact direct and mutual recursion rejection. Built-in final callbacks do not
claim the helper name as callable identity: two nested anonymous `with` callbacks are distinct values, not a
`with -> with` recursion cycle. When the callback expression is a variable, that binding name remains the
recursion identity through helper dispatch, so re-entering `callback` reports `callback -> callback` exactly.

The focused consumer writes exact emitted bytes only below managed repository-derived `TMPDIR`, launches a fresh
PUC Lua or LuaJIT child, projects typed generated wrapper errors plus exact inner runtime detail, corrupts one
payload to prove compile/load rejection, and removes every workspace after normal and injected-failure paths. The
Lua storage oracle freezes that file as temporary owner 17 and continues to prove repository-device identity and
zero residue.

Related facts: [[lua-callable-codeblock-dynamic-invocation]], [[lua-callable-codeblock-literal-state]],
[[lua-generated-source-emitter-core]], [[lua-generated-source-fresh-process-isolation]],
[[project-data-ssd-storage-locality]], [[callable-codeblock-four-backend-recurring-gate]].
