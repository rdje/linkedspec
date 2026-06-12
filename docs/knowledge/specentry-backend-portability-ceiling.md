---
id: specentry-backend-portability-ceiling
title: SpecEntry emits Perl source strings and eval()s them — this is the strongest backend-portability ceiling in the project
answers:
  - "why can't LinkedSpec target non-Perl backends"
  - "what is the biggest portability blocker"
  - "how does SpecEntry generate runtime handlers"
  - "what would it take to port LinkedSpec to another language"
date: 2026-06-12
status: current
tags: [architecture, specentry, portability, eval, tech-debt]
evidence: "ARCHITECTURE_STATE.md §Main Hotspots and Risks: 'SpecEntry still relies on generated Perl source plus eval; strongest backend-portability ceiling; still a likely long-term refactor target'"
reverify: "grep -n 'backend-portability ceiling\|eval' ARCHITECTURE_STATE.md | head -3"
---

`LinkedSpec::SpecEntry` compiles parsed rule entries into generated runtime handler code. It
still assembles Perl source strings and `eval`s them — this is explicitly the "clearest
backend-portability ceiling" in the current implementation (per `ARCHITECTURE_STATE.md`).

The ActionIR lowering stack (`LinkedSpec::ActionIR::*`) has made substantial progress toward
backend-neutral semantics, and the helper family (100+ helpers across 10 families) is fully
regression-locked on both fluent-chain and structured-block surfaces. But runtime handler
generation still bottoms out in emitted Perl and `eval`.

A possible first step toward decoupling: emit an AST intermediate form alongside the existing
Perl path (gated behind a flag), enabling a non-Perl backend to consume the same ActionIR
lowering output without touching the Perl code-gen path.

Related: [[actionir-lowering-stack]].
