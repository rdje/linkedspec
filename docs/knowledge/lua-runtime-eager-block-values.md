---
id: lua-runtime-eager-block-values
title: Lua ordinary no-pair brace values execute eagerly and reserve inert blocks for contextual or explicit callable paths
answers:
  - do Lua expression valued blocks execute
  - what does an ordinary brace block return in Lua
  - is return inside a Lua expression block local
  - does callback equals brace block store a codeblock in Lua
  - how are eager blocks different from trailing codeblock arguments in Lua
  - why was the Lua codeblock storage test corrected
date: 2026-07-13
status: current
tags: [lua, runtime, block-value, codeblock, return, receiver, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.6.1 adds evaluate_block_value in lua/src/linkedspec/interpreter.lua and a focused end-to-end case in lua/test/run.lua. Both Lua ABIs pass 104/104; Perl call_spec_handler_subst and focused Rust terse_2_1_3/.2_1_4 tests agree."
reverify: "bash tools/run_lua_local.sh && perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(q{Top}, q{set(callback, { return(\"later\") })}), qq{\\n}'"
---

## Fact

Lua now matches the portable expression-valued block contract. A non-empty
brace payload without a top-level key/value pair runs eagerly in any ordinary
value position. Non-final statements execute in dropped-statement context, the
final expression becomes the block value, and `return(expr)` or `return()`
exits only that block and skips its remaining statements. The yielded value may
continue through ordinary receiver dispatch.

Empty `{}` and top-level-pair `{ key : value }` forms remain harrays. This means
that ordinary assignment is eager too:

```text
callback = { return("later") }  # stores scalar "later", not a codeblock
```

The earlier Lua `.4.3.1` fixture expected that assignment to preserve an inert
`block_value`. That was scaffold identity coverage added before block execution,
and it contradicted the already-settled Perl/Rust language surface. `.4.3.6.1`
corrects the expectation and annotates the historical task instead of treating
the Lua-only behavior as a compatibility promise.

The `codeblock` value kind remains real. A trailing contextual block is still a
structural final `block_value` argument until a signature-governed callable
executes it. Registry/invocation boundaries can copy typed block records, and
future explicit first-class values use `{|params| ...}`. Eager ordinary braces
must not erase those distinct contextual and explicit callable paths.

Related facts: [[terse-expression-valued-block-early-return]],
[[lua-runtime-core-value-capture-helpers]], [[lua-actionir-ast-parser]],
[[lua-runtime-block-control-callback-split]], [[callable-codeblock-literal-contract]].
