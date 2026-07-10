---
id: julia-helper-regex-flag-normalization
title: Julia helper regex compilation preserves imsx, ignores go, and rejects unknown flags
answers:
  - how does Julia compile helper regex flags
  - does Julia accept the Perl regex o flag
  - does Julia accept the regex g flag in matches and split
  - which regex flags are portable in Julia helpers
  - why did Julia portmap_constant return bare
  - does Julia portmap_constant pass
  - what does JULIA-BACKEND-PARITY.6.2.4.2.3 prove
date: 2026-07-10
status: current
tags: [julia, runtime, regex, flags, helpers, corpus, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.2.4.2.3 adds _runtime_compile_helper_regex in julia/src/runtime/Interpreter.jl. It retains imsx, ignores execution-only g and Perl compile-once o, and returns failure for unknown flags or invalid patterns. matches(...) and regex split(...) share it. Focused igo/go/q coverage and the permanent portmap corpus regression pass; portmap_constant returns exact expected output, full Pkg.test() passes with 772 assertions, and shipped smoke is 18/31."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()' && JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --case portmap_constant"
---

Julia helper regex literals use one strict compilation seam:

- `i`, `m`, `s`, and `x` are passed to Julia `Regex`.
- `g` is an operation-level flag and is ignored during compilation.
- Perl's compile-once `o` is accepted as a compatibility no-op.
- Any other flag, or an invalid pattern, fails closed.

Pure `matches(...)` returns false on compilation failure. Regex-delimiter `split(...)` returns an empty array. Both
use the same normalization, preventing helper-specific flag drift.

This closes `portmap_constant`. Its compacted `entry_group(0)` was already correct at `0x1f`; the prior
`?bare:` output came from `matches(entry_group(0), /^\d/io)` returning false when raw `io` was passed to Julia
`Regex`. It now returns exact checked-in `?constant:` output. At that boundary full tests were green with 772
assertions, the shipped-smoke window was 18/31, and status was `runtime-corpus-helper-regex-flags`.
`.6.2.4.2.2` has since closed diagnostic output, `.6.2.4.5.3` has closed history leading trivia, and `.6.2.4.6`
is active for final shipped-window no-drift.

Related facts: [[julia-logical-helper-execution]], [[julia-shipped-corpus-smoke-split]],
[[rust-capture-group-helper-indexing]], [[rust-perl-output-oracle]].
