---
id: lua-callable-codeblock-typed-audit
title: Lua callable-codeblock parity has four dependency-ordered implementation seams
answers:
  - "what is the exact Lua callable codeblock implementation plan"
  - "which Lua files own explicit callable codeblock construction"
  - "how should Lua parse codeblock keyword arguments"
  - "does Lua name equals value mean a keyword argument"
  - "how should Lua invoke a bound codeblock variable"
  - "how should Lua preserve codeblocks through generated source"
  - "which Lua callable codeblock test should be added"
  - "how is Lua admitted to recurring callable codeblock proof"
date: 2026-08-01
status: current-plan
tags: [lua, luajit, callable, codeblock, actionir, diagnostics, generated-source, semantic-introspection, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.8.0 runs identical typed ActionIR/runtime probes on PUC Lua and LuaJIT, retrieves the neutral contract and four completed backend consumers, maps every Lua owner, and freezes one focused consumer plus .11.8.1-.4 construction/invocation/route/admission boundaries without production behavior changes."
evidence_update_2026_08_01_construction: "FUTURE-PARITY-BACKLOG.11.8.1 implements the first planned seam exactly: the focused consumer passes 168 assertions on both Lua ABIs and the complete Lua gate remains green; dynamic invocation and route/admission owners are unchanged."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && bash tools/run_lua_local.sh && rg -n 'codeblock_literal|codeblock_argument|runtime_scoped_binding|value_access|keyword_argument|execute_contextual_codeblock' lua/src/linkedspec lua/test tools"
---

# Lua Callable-Codeblock Typed Audit

The exact pre-implementation probe produces the same result on PUC Lua and LuaJIT. Exact `{|` forms currently
become eager `block_value` nodes whose bodies contain `raw_perl`; malformed brace-pipe forms likewise have no
portable typed diagnostic. `cb(value: "x")` is a positional raw expression, while `cb(value = "x")` is a
positional `assign_scalar`. The latter is deliberately retained: only the colon spelling may become a typed
`keyword_argument`, solely so governed callable dispatch can reject it. An evaluated-call key access such as
`collector("p")["items"]` also lacks a typed receiver, although an ordinary call already works as the receiver of
a fluent chain.

Runtime probes preserve the existing boundaries. A `block_value` executes eagerly. A contextual block passed to a
declared final `codeblock` slot can be transported and invoked inside that user-function frame. The same value
bound to an ordinary variable cannot be called outside the declared slot. A registered user function wins over a
same-named bound block, and a bound scalar call is currently indistinguishable from an unbound helper call. These
are the exact seams to change; existing eager blocks, controls, harray classification, contextual normalization,
and static precedence are regression locks.

Implementation is dependency-ordered:

1. `.11.8.1` adds exact brace-pipe parsing, the neutral eight-field `codeblock_literal`, fixed/final-rest
   `ActionCallableSignature`, Unicode-character spans, nine portable parse codes, recursive copy/registry/runtime
   kind support, inert construction, deferred contract/removed-selector traversal, user-function transport, and
   semantic codeblock signature state. The existing compiled ActionIR JSON and effective-`SpecFile` emitter carry
   that data; no codec or closure is added.
2. `.11.8.2` adds narrow colon-keyword and evaluated-value-access ActionIR, then resolves a bound codeblock only
   after controls, helpers, and registered functions. The existing `runtime_scoped_binding.run_frame` owns copied
   fixed/rest bindings and cleanup-safe three-store restoration. One interpreter executes the retained typed body
   with live caller nonparameter stores, invocation-local return, result access/chaining/discard, and a separate
   ordered active-codeblock stack. The runtime diagnostic projection gains the neutral
   `callable_name`/`expected`/`got`/`value_kind`/`name`/`cycle` fields.
3. `.11.8.3` proves the same record and executor through native compilation, normalized `SpecFile`
   reconstruction, generated-plan execution, and a byte-fresh independently loaded emitted module on both Lua
   ABIs. This is proof and narrow identity repair, not authority for a route-specific executor.
4. `.11.8.4` replaces the four-backend recurring composition with one omission-sensitive five-backend driver,
   invokes the same Lua consumer on PUC Lua and LuaJIT from repository-managed storage, removes the Lua-only future
   exclusion only after proof, advances public/capability state, and closes parent `.11.8` and callable parent
   `.11`. Lexical capture remains excluded from version 1.

Current progress: step 1 is complete. Exact inert construction/state is documented in
[[lua-callable-codeblock-literal-state]]. Steps 2-4 remain dependency-ordered and unchanged.

One focused file, `lua/test/callable_codeblock_literal_contract_test.lua`, grows across `.1-.3`. It consumes the
unchanged neutral JSON and owns the same ten roles as each admitted backend: neutral contract, inert construction,
dynamic caller context, static callable precedence, contextual final blocks, portable failures, native execution,
reconstructed execution, generated execution, and emitted execution. It becomes a registered complete-Lua test
on both ABIs as soon as its first green construction slice lands; its emitted-module temporary owner is added to
the Lua project-data inventory in `.3`.

Related facts: [[lua-explicit-callable-codeblock-gap]], [[callable-codeblock-literal-contract]],
[[lua-contextual-user-function-codeblock-runtime]], [[lua-generated-source-scaffold-split]],
[[lua-runtime-core-value-capture-helpers]], [[callable-codeblock-four-backend-recurring-gate]].
