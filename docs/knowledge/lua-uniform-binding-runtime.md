---
id: lua-uniform-binding-runtime
title: "Lua bare mutations use one typed binding on PUC Lua and LuaJIT"
answers:
  - "does Lua support selector free push split and hash mutation"
  - "what does Lua set return for method chaining"
  - "how does Lua report a wrong kind bare mutation"
  - "does a saved Lua mutation result change after a later mutation"
  - "how does Lua distinguish push rule dispatch from binding mutation"
  - "are array name and hash name rejected on Lua yet"
date: 2026-07-12
status: current
tags: [lua, language, bindings, array, harray, mutation, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.6 centralizes Lua kind-checked array mutation around lookup_binding in lua/src/linkedspec/interpreter.lua. Nine permanent cases cover the neutral fixture, saved results, split, hash update, collection rebinding, array-end chaining, static precedence, and wrong-kind fields. FUTURE-PARITY-BACKLOG.12.1.8.5 rejects exact selectors across typed/deferred compiled state and caller-mutated runtime-engine input, then deletes their runtime dispatch. LUA-BACKEND-PARITY.4.3.4.4 extends that same seam to typed implicit accumulators and cached whole/indexed action-edge child push. PUC Lua and LuaJIT pass 98/98."
reverify: "bash tools/run_lua_local.sh"
---

# Lua uniform binding runtime

Lua consumes `linkedspec-uniform-binding-v1` through `lookup_binding` on both PUC Lua and LuaJIT. Its private
scalar/array/harray stores remain implementation details and do not create alternate `.spec` namespaces.

Bare assignment and `set` replace competing stores. Bare push/`+=`, three-argument mutable split, hash-index
mutation, array-end methods, and standalone collection transforms validate the current runtime kind, update the
binding, and return a copied post-operation value. Missing array/harray targets create only the required kind.
Incompatible existing values raise `binding_kind_mismatch` with stable code, identifier, expected-kind, and
actual-kind fields. Saved mutation results remain independent from later updates.

Registered compiled rules retain precedence for ambiguous `push(name, target)`: the rule executes and its result is
appended to the target binding. Otherwise the first name is the array binding. Minimal pure array dispatch supplies
the continuations required by the neutral fixture and mutation chains.

The current rule name exposes its typed implicit accumulator when no explicit binding shadows it; another absent
compiled-rule name reads as an empty array. Action-edge `.push`/`.push(target)` and the four whole/indexed
`push(Child[, target][, index])` forms reuse the cached child result and append through the same binding seam.

Exact one-bare-identifier aggregate selectors are rejected before execution; all tracked sources have migrated.
Lua's selector recognition and runtime dispatch are deleted by `FUTURE-PARITY-BACKLOG.12.1.8.5`.

Related facts: [[uniform-binding-neutral-contract]], [[perl-uniform-binding-runtime]],
[[rust-uniform-binding-runtime]], [[dart-uniform-binding-runtime]], [[julia-uniform-binding-runtime]],
[[lua-array-split-mutation]], [[lua-runtime-array-mutation-child-flow]],
[[spec-facing-aggregate-selector-retirement-inventory]].
