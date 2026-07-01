---
id: language-agnostic-backend-vision
title: LinkedSpec language-agnostic backend vision — Perl reference plus Rust today; Julia/Dart future backends consume same .spec files in lockstep
answers:
  - what backends will LinkedSpec support
  - what is the language-agnostic architecture vision
  - how do backends stay in lockstep
  - does the Perl version go away
  - what LinkedSpec backends are implemented today
  - what is the role of .spec files across backends
  - how does HandlerIR help portability
  - what is the backend roadmap for LinkedSpec
  - is Lua an accepted LinkedSpec backend
date: 2026-06-12
status: accepted
tags: [architecture, portability, backends, roadmap, vision]
evidence: "User-specified vision during MEDIUM-IMPACT.1.3 HandlerIR work; ADR 0006 formalized Rust, Julia, and Dart future-backend targets. Phase 9 then implemented the Rust interpreter under rust/ and explicitly did not implement Julia or Dart. SPEC-FORMAT-TERSE.5.0 reverified that no tracked Julia/Dart/Lua implementation paths exist outside the unrelated nested rgx checkout, and that Lua is not in ADR 0006 or the mdBook backend handoff."
reverify: "grep -n 'Rust\\|Julia\\|Dart\\|Lua\\|backend' ROADMAP_V2.md docs/decisions/0006-multi-backend-vision.md docs/linkedspec-book/src/appendix/backend-handoff.md docs/tasks/PHASE9-RUST-VARIANT.md | head -40"
---

## Context

LinkedSpec currently has the Perl reference implementation and the Rust interpreter variant
under `rust/`. The accepted future backend vision is to add Julia and Dart backends as
separate implementation tracks — not replacing Perl, but alongside it. All backends consume
the exact same `.spec` files and produce identical parser behavior. JS and Wasm targets are
reached via Rust (wasm-bindgen/wasm-pack) or Dart (dart2js/dart2wasm).

Lua is not part of the accepted backend set today. It needs an explicit decision record or
roadmap update before any Lua backend task-tree leaf or implementation code is created.

## Decision

1. **Perl version stays** — it is not abandoned. It remains the reference implementation
   and the development platform for `.spec` language evolution.
2. **`.spec` files are the universal contract** — each backend parses the identical `.spec`
   grammar files. No per-backend spec dialects.
3. **Backends stay in lockstep** — same features, same runtime semantics, same `.spec`
   compatibility. A spec that compiles on Perl must compile identically on Rust/Julia/Dart
   once those backend tracks exist.
4. **Language-agnostic architecture** — every component that can be language-neutral should
   be:
   - HandlerIR defines handler structure without language-specific code generation
   - mdBook is the user-facing specification (not a Perl tutorial)
   - Phase0 regression defines the behavioral contract all backends must pass
   - ActionIR lowering is already largely backend-neutral
5. **HandlerIR is the first concrete decoupling step** — it separates structural decisions
   (which loop, which dispatch) from code generation (Perl source strings). Future backends
   consume the same HandlerIR nodes and emit their own language equivalents.

## Consequences

- mdBook must be kept in lockstep with the codebase at all times — it is the spec.
- Every feature must be documented language-neutrally (describe behavior, not Perl
  implementation details).
- Knowledge Map cards should document contracts (what the system does) rather than
  implementation archaeology (how Perl does it).
- ROADMAP.md / ROADMAP_V2.md should eventually reflect backend milestones.

## Backend reach matrix

| Backend | CLI | Web (JS) | Wasm | Mobile |
|---------|-----|----------|------|--------|
| Perl    | ✅  | —        | —    | —      |
| Rust    | ✅ implemented | ✅ (wasm-bindgen future target) | ✅ future target | — |
| Julia   | ✅ accepted future target | —        | —    | —      |
| Dart    | ✅ accepted future target | ✅ (dart2js future target) | ✅ (dart2wasm future target) | ✅ (Flutter future target) |

## Speculated VM consideration

A bytecode VM was discussed but is not the preferred path. Direct language emitters
(HandlerIR → Rust codegen, HandlerIR → Julia codegen, etc.) are more idiomatic and
performant than a VM layer. The HandlerIR already provides the structured representation
a VM would need; the decision of emit-vs-interpret is per-backend.

## Links

- [[handler-ir-design]] — formal HandlerIR specification (created 2026-06-14, PHASE8-MULTI-BACKEND-HANDOFF.3)
- [[specentry-backend-portability-ceiling]]
- [[actionir-lowering-stack]]
