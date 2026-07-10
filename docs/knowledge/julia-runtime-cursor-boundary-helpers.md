---
id: julia-runtime-cursor-boundary-helpers
title: Julia runtime implements explicit cursor controls and non-consuming boundary capture
answers:
  - does Julia runtime support save_cursor restore_cursor
  - does Julia runtime support rewind_match_start rewind_entry_start
  - does Julia runtime support capture_until_boundary
  - how does Julia keep runtime cursor and match registers synchronized
  - are Julia cursor and input helper offsets character based
  - does a Julia cursor rewind roll back variables or matches
  - what happens when Julia capture_until_boundary cannot resolve a boundary rule
date: 2026-07-10
status: current
tags: [julia, runtime, cursor, boundary-lookahead, helpers, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.4.4 extends julia/src/runtime/Interpreter.jl with an explicit cursor stack, centralized live/register cursor updates, direct match/entry anchor rewinds, character-based cursor/input helpers, overflow-safe input slicing, and earliest usable named-rule boundary capture. Fourteen focused assertions in julia/test/runtests.jl and the full 581-assertion Pkg.test() run prove consume-mode continuation, multibyte public offsets, preserved match/store state, non-consumption, EOF fallback, and unresolved-rule no-op behavior."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

Julia runtime cursor-control and cursor/input helper execution lives in
`julia/src/runtime/Interpreter.jl` on top of the immutable match-register state
in `julia/src/runtime/Matching.jl`.

`save_cursor()` pushes the current internal code-unit cursor onto an explicit
LIFO stack. `restore_cursor()` pops and restores it when present; an empty stack
is a no-op. `rewind_match_start()` and `rewind_entry_start()` move directly to
the current local-match or initial/entry-match start and do not use the stack.

All four controls update the live execution cursor and
`RuntimeMatchRegisters.cursor_codeunit` together. They do not roll back or
replace entry/local match records, variables, arrays, hashes, accumulators,
lifecycle effects, or branch decisions. Normal matching after the move retains
the engine's configured seek or consume mode.

Julia stores the internal cursor as a zero-based UTF-8 code-unit offset. Public
`cursor_*` and `input_*` helpers return character-based offsets, lengths, and
slices plus 1-based line/column values.

`capture_until_boundary(rule[, ...])` seeks every usable named boundary rule
from the live cursor and selects the earliest match while leaving that boundary
unconsumed. If usable rules exist but none matches later, it captures through
EOF and moves there. If no requested rule resolves to regex patterns, it
returns `nothing` and leaves the cursor unchanged.

Related facts: [[julia-runtime-matching-state]], [[julia-runtime-rule-interpreter]],
[[julia-runtime-value-control-tree-helpers]], [[cursor-boundary-lookahead-helper]],
[[dart-runtime-backtrack-cursor-helpers]].
