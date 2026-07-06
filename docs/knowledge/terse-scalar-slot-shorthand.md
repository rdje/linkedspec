---
id: terse-scalar-slot-shorthand
title: "SPEC-FORMAT-TERSE.6.2.3.1 historical note - :name was the scalar-slot shorthand, but SPEC-FORMAT-TERSE.15.3 hard-retired Perl support; current authoring uses bare reads."
answers:
  - "what is :name in LinkedSpec"
  - "how do I write scalar(name) tersely"
  - "does :payload keep scalar payload boundary for direct shape assignment"
  - "is scalar(name) retired or still accepted"
  - "where did SPEC-FORMAT-TERSE.6.2.3.1 land"
  - "how do Perl and Rust parse :name scalar slot shorthand"
date: 2026-07-06
status: superseded
tags: [dsl, scalar, shorthand, spec-format-terse, SPEC-FORMAT-TERSE, actionir, rust, parity, mdbook]
evidence: "Historical fact: SPEC-FORMAT-TERSE.6.2.3.1 introduced `:name` on 2026-07-03 as the terse scalar-slot spelling, and SPEC-FORMAT-TERSE.6.2.3.2 later retired authored `scalar(name)` / `assign(...)`. The current surface supersedes that: SPEC-FORMAT-TERSE.15.2.4 migrated current specs/corpus/docs/KM to bare reads, and SPEC-FORMAT-TERSE.15.3 hard-retired Perl `:name` parsing/lowering by emitting `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read` instead of a successful scalar read/target. Current authoring uses bare value reads and explicit `array(...)` / `hash(...)` targets for aggregate storage boundaries. Rust `Expr::ScalarSlot` remains the next retirement target under SPEC-FORMAT-TERSE.15.4."
reverify: "prove -q -Iperl t/actionir_ast_parser.t t/trace_emit_context_bridge.t t/trace_actionir_pipeline.t t/trace_actionir_compact_lowerers.t t/trace_actionir_method_lowering.t"
---

# Historical Scalar-Slot Shorthand

`SPEC-FORMAT-TERSE.6.2.3.1` added `:name` as a temporary terse scalar-slot spelling. That contract is now
superseded on the Perl reference backend by `SPEC-FORMAT-TERSE.15.3`.

Current authored specs should use bare value reads:

```text
return(name)
return([value, other])
set(payload, [value])
```

On Perl, a remaining `:name` form is a migration error/diagnostic sentinel, not a working scalar-slot read.
Rust `Expr::ScalarSlot` is still tracked separately for removal under `SPEC-FORMAT-TERSE.15.4`.
