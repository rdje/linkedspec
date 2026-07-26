---
id: julia-runtime-value-control-tree-helpers
title: Julia runtime executes value blocks, structured controls, with-blocks, and tree callbacks
answers:
  - does Julia execute expression valued blocks
  - does Julia keep return local inside value blocks
  - does Julia support attached if elseif else and when otherwise
  - does Julia support marker form if elseif else endif
  - does Julia support attached switch case default and while
  - does Julia support lazy inline if and switch helpers
  - does Julia support helper with trailing blocks
  - does Julia support receiver with trailing blocks
  - does Julia support hash tree traversal callbacks
  - does Julia support array tree traversal callbacks
  - what callback variables does Julia tree traversal bind
  - do non aggregate Julia tree receivers evaluate reduce initial values
date: 2026-07-10
status: current
tags: [julia, runtime, blocks, controls, tree-traversal, callbacks, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.4.3.5 extends julia/src/runtime/Interpreter.jl with separate rule/value block flow, attached and marker controls, lazy inline branches, deterministic while guards, helper/receiver with-blocks, scoped binding snapshots, and hash/array walk/map/reduce receiver callbacks. Eight focused assertions in julia/test/runtests.jl and the full 567-assertion Pkg.test() run prove local/rule return boundaries, branch behavior, binding restoration, traversal order/shapes, unsupported trailing-block and arity fences, non-aggregate lazy failure, and persistent caller-side effects."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using Pkg; Pkg.test()'"
---

Julia value/control/callback execution lives in
`julia/src/runtime/Interpreter.jl`.

Expression-valued blocks yield their final expression unless block-local
`return(...)` or `return_undef()` runs first. That return skips later block
statements without setting the surrounding rule return channel. Action blocks
execute attached and marker controls, while inline `if(...)` and `switch(...)`
evaluate only the selected value branch.

Helper `with(value) { ... }`, undefined `with() { ... }`, and receiver
`.with() { ... }` run immediately with scoped `value`. Every prior scalar,
array, or hash binding under that name is restored afterward; unrelated working
variable side effects persist.

Hash tree traversal is sorted-key depth-first with nested hashes as interiors.
Array traversal is zero-based depth-first with nested arrays as interiors.
Callback frames bind scoped `value`, `path`, `depth`, hash `key`, array `index`,
and reduce-only `acc`. `walk_leaves` returns a copied source tree,
`map_leaves` preserves structure with callback results, and
`reduce_leaves(initial)` returns the final accumulator. Non-aggregate receivers
return `nothing` without executing either the callback or reduce initializer.

Related facts: [[julia-runtime-helper-value-no-drift]], [[julia-runtime-hash-helpers]], [[julia-runtime-array-helpers]],
[[dart-runtime-value-control-tree-helpers]],
[[terse-expression-valued-block-early-return]],
[[terse-trailing-block-argument-mvp]],
[[rust-hash-tree-traversal-receiver-blocks]],
[[array-tree-traversal-contract]].
