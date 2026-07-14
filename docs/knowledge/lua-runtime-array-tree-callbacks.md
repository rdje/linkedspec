---
id: lua-runtime-array-tree-callbacks
title: Lua array leaf traversal is zero-based and recurses only through nested arrays
answers:
  - how does Lua execute array tree walk leaves
  - how does Lua execute array map leaves
  - how does Lua execute reduce leaves on an array
  - what bindings does a Lua array callback receive
  - are Lua array indexes and paths zero based
  - are Lua hash values recursed inside array traversal
  - are Lua arrays recursed inside harray traversal
  - does Lua use one root kind dispatcher for tree callbacks
  - can Lua array walk leaves and map leaves continue through array methods
  - does Lua reduce leaves evaluate its initial value for an invalid receiver
date: 2026-07-13
status: current
tags: [lua, luajit, runtime, array, tree, callbacks, scope, copy, determinism, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.6.5.2 generalizes the harray traversal seam into evaluate_tree_receiver_block, tree_children, and kind-specific result construction in lua/src/linkedspec/interpreter.lua. The focused array case locks zero-based depth-first order, harray leaves, copied value/index/path/depth/acc scope, source/result isolation, walk/map continuation, terminal reduce, empty/invalid laziness, exact restoration, and the checked-in Perl oracle result. tools/run_lua_local.sh passes 114/114 on PUC Lua and LuaJIT while the prior harray case remains green; tools/run_ci_local.sh exits 0 with capability 64/0/0, CLI 61/61 twice, and phase0 1..1031 in 987 seconds."
reverify: "bash tools/run_lua_local.sh && rg -n 'tree_children|new_tree_container|set_tree_child|evaluate_tree_leaf_block|evaluate_tree_receiver_block|runtime array traversal' lua/src/linkedspec/interpreter.lua lua/test/run.lua"
---

Lua selects tree behavior from the receiver's runtime root kind. A harray root visits only nested harrays; an array
root visits only nested arrays. Cross-kind aggregates are leaves, so a harray inside an array callback is presented
whole as `value`, and an array inside a harray callback is likewise opaque. This is root-kind dispatch, not mixed-
aggregate recursion.

For an array root, each Lua offset is translated from one-based storage to a zero-based callback `index`. Children
are visited depth-first in source order. `path` is a copied array of zero-based root-to-leaf indexes and `depth` is
`count(path)`, so a root leaf has depth 1. The atomic callback frame also binds copied `value` and reduce-only
`acc`, snapshots every private store, and restores exact prior or absent bindings after success or error.

`walk_leaves` ignores callback results, preserves ordinary non-frame side effects, and returns an isolated source
copy. `map_leaves` rebuilds a typed array with copied callback results. Both can continue through compatible array
methods such as `.count()`. `reduce_leaves` evaluates its initial value once only for a valid array, threads copied
callback results, and is terminal. Empty arrays execute no callbacks; invalid receivers return null without
evaluating the callback or reduce initial.

Related facts: [[array-tree-traversal-contract]], [[perl-array-tree-traversal-callback-frame]],
[[rust-array-tree-traversal-receiver-blocks]], [[lua-runtime-harray-tree-callbacks]],
[[lua-runtime-builtin-final-codeblocks-with]].
