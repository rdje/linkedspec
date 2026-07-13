---
id: julia-runtime-core-value-capture-helpers
title: Julia runtime core stores, nested writes, and capture helpers preserve portable value shapes
answers:
  - does Julia runtime preserve scalar array hash null boolean number shapes
  - where are Julia runtime scalar array and hash stores implemented
  - does Julia runtime support typed array and hash wrapper snapshots
  - does Julia runtime support hash index and nested assignment
  - does Julia nested value path assignment autovivify
  - does Julia nested assignment return the updated root
  - does Julia runtime support entry_map and match_map
  - does Julia runtime expose capture positions and line columns
date: 2026-07-13
status: current
tags: [julia, runtime, helpers, values, captures, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.4.3.1 extends julia/src/runtime/Interpreter.jl with scalar, array, and hash stores; copied bare reads; structural literals, assignments, indexed/nested reads, and final no-autovivification nested writes; plus entry/match named maps, existence, length, character-position, and line-column helpers. Focused end-to-end cases prove JSON-safe shapes, variable-held aggregates, successful updated-root writes, unchanged roots after path failures, bare capture names, multibyte offsets, and named capture maps. FUTURE-PARITY-BACKLOG.12.1 later replaced the public typed-wrapper snapshot model with uniform bare bindings and hard-rejected exact aggregate selectors."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

Julia core runtime value execution lives in `julia/src/runtime/Interpreter.jl`.

`_RuntimeExecutionContext` may retain private scalar/array/hash stores, but a
`.spec` name exposes one current typed value. Bare reads and `copy(...)` resolve
that binding to copied values. Exact `array(name)` and `hash(name)` selectors
reject before execution. Array/harray literals, assignment, append, hash-index
assignment, indexed reads, and mixed nested reads preserve strings, numbers,
booleans, `nothing`, arrays, and string-keyed dictionaries without host wrappers.

Nested value-path writes use the final portable contract: segment expressions
evaluate before the RHS; the root is copied and mutated only after the complete
path validates; missing or wrong-shape intermediates do not autovivify; a final
hash key may be created; a final array index may replace or append exactly at
the current length; success returns the updated root and failure returns
`nothing` without changing stored state.

The same interpreter owner exposes entry/local text and compact groups,
indexed and bare-name named captures, named-capture existence/maps, character
length and start/end positions, and start/end line-column helpers. Positions
remain character-based even though internal cursor state uses Julia code-unit
offsets.

Related facts: [[julia-runtime-rule-interpreter]], [[julia-runtime-matching-state]],
[[julia-runtime-string-numeric-helpers]],
[[dart-runtime-core-value-capture-helpers]], [[terse-nested-value-path-assignment]],
[[terse-direct-access-explicit-segments]].
