---
id: lua-runtime-harray-tree-callbacks
title: Lua harray leaf traversal uses sorted recursion and one atomic copied callback frame
answers:
  - how does Lua execute hash tree walk leaves
  - how does Lua execute harray map leaves
  - how does Lua execute reduce leaves on a harray
  - what bindings does a Lua harray callback receive
  - what depth does a root Lua harray leaf receive
  - are Lua tree callback paths and values copied
  - does Lua restore callback bindings after an error
  - are arrays leaves inside Lua harray traversal
  - does Lua evaluate reduce initial on an invalid receiver
  - which task owns Lua array root tree traversal
date: 2026-07-13
status: current
tags: [lua, luajit, runtime, harray, tree, callbacks, scope, copy, determinism, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.6.5.1.2 adds runtime_scoped_binding.run_frame plus sorted harray walk/map/reduce dispatch in lua/src/linkedspec/interpreter.lua. The focused case locks copied value/key/path/depth/acc scope, root depth 1, arrays as leaves, source/result isolation, walk continuation, terminal reduce, empty/invalid boundaries, typed malformed calls, and the exact direct Perl LinkedSpec::Get result. tools/run_lua_local.sh passes 113/113 on PUC Lua and LuaJIT; the mandatory full local CI gate passes capability 64/0/0, CLI 61/61 twice, and phase0 1..1031."
reverify: "bash tools/run_lua_local.sh && rg -n 'run_frame|evaluate_hash_tree_receiver_block|exact Perl reference callback result|runtime harray traversal' lua/src/linkedspec/runtime_scoped_binding.lua lua/src/linkedspec/interpreter.lua lua/test/run.lua"
---

Lua evaluates `walk_leaves`, `map_leaves`, and `reduce_leaves` only after the existing receiver callable metadata
has validated the final `callback: codeblock` slot and the method's ordinary argument count. A non-harray receiver
returns null before the reduce initial expression or callback executes. Empty harrays execute no callbacks.

Each harray node visits its string keys in lexical order. A nested harray is an interior node; every other typed
value is a leaf, including arrays and null. The path is a fresh array of root-to-leaf keys and `depth` is exactly
`count(path)`, so a root leaf receives depth 1.

One `runtime_scoped_binding.run_frame` call installs copied `value`, `key`, `path`, `depth`, and reduce-only `acc`
values in the uniform scalar store. Before installation it snapshots all scalar/array/harray stores for every
name. It copies the callback result, then restores every prior or absent store in reverse frame order after normal
completion or error. Callback mutation therefore cannot alias the receiver, mapped result, path, or accumulator;
side effects on names outside the callback frame persist normally.

`walk_leaves` ignores callback results and returns a copy of the receiver, so hash-family continuation remains
valid. `map_leaves` rebuilds a typed harray with each leaf replaced by its copied callback result. `reduce_leaves`
evaluates its initial value once for a valid harray, threads each copied callback result, and is terminal in a
receiver chain. Array-root and mixed harray/array recursion are deliberately not inferred here; active
`LUA-BACKEND-PARITY.4.3.6.5.2` owns that separate zero-based-index contract.

Related facts: [[perl-hash-tree-traversal-callback-frame]], [[rust-hash-tree-traversal-receiver-blocks]],
[[hash-tree-callback-append-scope-collision]], [[lua-runtime-builtin-final-codeblocks-with]],
[[lua-runtime-block-control-callback-split]].
