---
id: julia-logical-helper-execution
title: Julia logical and/or/not helpers are eager boolean composition values
answers:
  - does Julia support and or not helpers
  - are LinkedSpec logical helpers short circuit
  - are and or not eager or lazy in LinkedSpec
  - what are empty and or not results
  - which Julia portmap fixtures pass after logical helpers
  - why does Julia portmap_constant still fail after logical helpers
  - what does JULIA-BACKEND-PARITY.6.2.4.2.1 prove
date: 2026-07-10
status: current
tags: [julia, runtime, logical, truthiness, corpus, regex-flags, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.2.4.2.1 adds and/or/not to Julia's eager pure-helper dispatcher through _runtime_truthy. Existing runtime coverage locks truthiness, empty false/false/true arities, and eager assignment side effects; six corpus assertions lock four passes plus one routed residual. Full Pkg.test() passes with 772 assertions. Direct compiled-regex capture and traced corpus probes prove portmap_constant's residual is helper Regex flag `o`, not logical evaluation."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()' && JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31"
---

Julia executes logical `and`, `or`, and `not` as normal eager value helpers, matching the Rust and Lua evaluation
shape but not current Perl condition lowering or Dart. Every argument is evaluated first, then Julia's established
runtime truthiness is applied:

- `nothing`, false, zero, empty strings, empty arrays, and empty hashes are false.
- Other values are true.
- Empty `and()`, `or()`, and `not()` return false, false, and true, matching Rust.

These helpers do not short-circuit side effects. Use structured or inline `if`/`switch` for lazy branch selection.
Focused coverage locks eager scalar assignment in an `or(true, ...)` argument.

`portmap_bare`, `portmap_bit`, `portmap_concatenation`, and `tablegrep_simple_term` now pass. `portmap_constant`
no longer fails on unsupported `or`, but returns `?bare:` instead of `?constant:`. A direct compiled-rule probe
shows the compacted capture is correctly `["0x1f"]`; a runtime trace shows the expected `bare_bit_slice` action
executes. The residual comes from `matches(entry_group(0), /^\d/io)`: Julia passes `io` directly to `Regex`, where
Perl's compile-once `o` flag is invalid, so the predicate returns false. `.6.2.4.2.3` has since closed that exact
bridge and `portmap_constant` passes.

The full shipped-smoke window is 17/31, full tests pass with 772 assertions, and status is
`runtime-corpus-logical-helpers` at that boundary. Helper regex flag normalization has since moved the window to
18/31 with status `runtime-corpus-helper-regex-flags`.

Related facts: [[julia-helper-regex-flag-normalization]], [[julia-shipped-corpus-smoke-split]], [[julia-anonymous-capture-boundary-helpers]],
[[dart-helper-action-surface-bridge]], [[logical-helper-five-backend-audit]], [[rust-capture-group-helper-indexing]],
[[rust-perl-output-oracle]].
