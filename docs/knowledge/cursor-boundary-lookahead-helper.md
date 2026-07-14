---
id: cursor-boundary-lookahead-helper
title: "capture_until_boundary(rule[, ...]) is the portable non-consuming structural boundary helper"
answers:
  - "how do I capture until the next structural rule without consuming it"
  - "does LinkedSpec support zero width lookahead boundaries"
  - "what helper replaces consume then rewind for EBNF semantic annotations"
  - "how does capture_until_boundary work"
  - "is capture_until_boundary based on save_cursor restore_cursor"
  - "should EBNF semantic_annotation use rewind_match_start"
date: 2026-07-09
status: current
tags: [helpers, cursor, boundary-lookahead, perl, rust, dart, julia, lua, BACKTRACK-SURFACE-RUST-ALIGNMENT]
evidence: "BACKTRACK-SURFACE-RUST-ALIGNMENT.2 adds capture_until_boundary(rule[, ...]) to Perl ActionIR lowering/scanning, Rust runtime helper execution/validation, and Dart ActionIR/runtime execution. JULIA-BACKEND-PARITY.4.4 adds Julia parity. LUA-BACKEND-PARITY.4.3.7.5 adds cached usable-rule alternations, unconditional seek, earliest selection, non-consumption, EOF fallback, and unresolved/regex-free no-op behavior on both Lua ABIs. The active specs/ebnf.spec and Rust corpus copies use capture_until_boundary(semantic_annotation, grammar_rule) so semantic annotations stop before the next semantic annotation or grammar rule without consuming that boundary."
reverify: "PERL5LIB= perl -Iperl t/phase0_regression.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime helpers_capture_until_boundary_captures_without_consuming_boundary && cd dart && dart test test/runtime_interpreter_test.dart -n 'captures until named boundary without consuming the boundary' && cd .. && JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()' && bash tools/run_lua_local.sh"
---

# Non-Consuming Structural Boundary Capture

`capture_until_boundary(rule[, ...])` is the portable helper for open-ended
payloads whose right edge is the next structural rule, not a fixed delimiter.

The helper starts at the live cursor and seeks for the earliest match of any
named boundary rule. It returns the text before that boundary and moves the live
cursor to the boundary start. The boundary match itself is not consumed, so the
normal rule path can process it next.

This is intentionally distinct from the other cursor controls:

- `save_cursor()` / `restore_cursor()` are explicit stack operations.
- `rewind_match_start()` / `rewind_entry_start()` move to lifecycle anchors after
  something has already been consumed.
- `capture_until_boundary(...)` avoids consuming the structural boundary in the
  first place.

`specs/ebnf.spec` uses:

```text
capture_until_boundary(semantic_annotation, grammar_rule)
```

so an annotation body stops before either the next annotation or the next grammar
rule header.

If at least one requested boundary rule resolves but none is found later in the
input, the helper captures through end-of-input and moves the cursor there. If no
requested boundary rule can be resolved to a usable pattern, it returns
`undef`/`null` and leaves the cursor unchanged.

Lua implements the same contract through a boundary-specific compiled-regex
cache and unconditional `seek_match`, so surrounding consume mode cannot turn
lookahead into an anchored match. PUC Lua and LuaJIT share the implementation.
The public signature requires at least one rule, but zero-argument behavior is
not yet portable: Perl leaves a raw call that later fails in the generated
handler, while Rust/Dart/Julia/Lua return null without moving. Helper-caveat
owner `FUTURE-PARITY-BACKLOG.5` owns normalization.

Related facts: [[spec-capture-mark-family-taxonomy]],
[[dart-runtime-backtrack-cursor-helpers]], [[julia-runtime-cursor-boundary-helpers]],
[[rust-anonymous-capture-slice-family]].
