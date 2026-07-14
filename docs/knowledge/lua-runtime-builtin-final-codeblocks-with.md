---
id: lua-runtime-builtin-final-codeblocks-with
title: Lua executes metadata-governed contextual final blocks and cleanup-safe scoped with
answers:
  - does Lua execute with trailing blocks
  - does Lua support parenthesized final blocks for with
  - are with attached and parenthesized codeblocks equivalent in Lua
  - how does Lua restore value after with
  - does Lua with copy aggregate inputs and results
  - does Lua restore scoped bindings after a callback error
  - which Lua built-ins declare a final codeblock parameter
  - does Lua with implement user function codeblocks
date: 2026-07-13
status: current
tags: [lua, runtime, codeblock, with, scope, metadata, callbacks, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.6.4 adds copied built-in final-codeblock contracts, runtime_scoped_binding.lua, interpreter dispatch, and focused helper/receiver/scope/error coverage. PUC Lua and LuaJIT pass 112/112; Perl lowering/execution probes agree."
reverify: "bash tools/run_lua_local.sh && PERL5LIB=perl perl -MLinkedSpec -e 'for my $s (q{return(with(\"x\") { return(value) })}, q{return(with(\"x\", { return(value) }))}, q{return(\"x\".with() { return(value) })}, q{return(\"x\".with({ return(value) }))}) { print LinkedSpec::call_spec_handler_subst(q{Top},$s), qq{\\n}; }'"
---

## Fact

Lua's built-in callable registry declares one final `callback: codeblock` slot for helper `with` (zero or one
value argument), receiver `with` (no authored value argument), receiver `walk_leaves`/`map_leaves` (no authored
argument), and receiver `reduce_leaves` (one accumulator argument). The registry returns copied metadata, so
runtime consumers cannot mutate the contract.

Helper and receiver `with` now consume their final raw `block_value` only after that signature admits it. These
pairs execute identically:

```text
with("x") { return(value) }
with("x", { return(value) })

"x".with() { return(value) }
"x".with({ return(value) })
```

The optional helper value or receiver evaluates before scope entry. Lua copies it into the temporary uniform
working binding `value`, runs the block in the caller's current runtime context, copies the result, and restores
the exact prior or absent `value` state across the private scalar/array/harray stores. Restoration happens after
normal completion, block-local `return`, callback failure, and result-copy failure. Mutations to other working
bindings remain caller-visible. Aggregate arguments and results do not alias their sources, and the yielded result
may continue through compatible receiver methods.

An absent/non-codeblock final argument produces typed `final_argument_not_codeblock`; unsupported authored counts
use the generic `helper_arity_mismatch` path. Empty/keyed harrays are not promoted to codeblocks.

This leaf supplies the signature and scoped execution seam, not every callback behavior. Harray tree traversal now
consumes the same registry and an extended atomic frame through `LUA-BACKEND-PARITY.4.3.6.5.1`; array-root and
mixed-tree recursion remain `.4.3.6.5.2`. General user-function dispatch remains `.5.1`, and explicit first-class
`{|params| ...}` values remain `FUTURE-PARITY-BACKLOG.11.7`.

Related facts: [[lua-runtime-block-control-callback-split]], [[lua-runtime-eager-block-values]],
[[generic-trailing-codeblock-argument-correction]], [[final-codeblock-parameter-declaration]],
[[lua-runtime-harray-tree-callbacks]].
