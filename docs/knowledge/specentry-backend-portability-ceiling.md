---
id: specentry-backend-portability-ceiling
title: Historical SpecEntry portability ceiling before HandlerIR and native backend rollout
answers:
  - "why can't LinkedSpec target non-Perl backends"
  - "what is the biggest portability blocker"
  - "how does SpecEntry generate runtime handlers"
  - "what would it take to port LinkedSpec to another language"
date: 2026-06-12
status: historical; HandlerIR extraction and native backend rollout supersede the project-wide blocker
tags: [architecture, specentry, portability, eval, tech-debt]
evidence: "ARCHITECTURE_STATE.md §Main Hotspots and Risks: 'SpecEntry still relies on generated Perl source plus eval; strongest backend-portability ceiling; still a likely long-term refactor target'"
reverify: "grep -n 'backend-portability ceiling\|eval' ARCHITECTURE_STATE.md | head -3"
---

**2026-09-06 reconciliation (`SESSION-STARTUP-READING.3.2.8`):** The original assessment below describes
2026-06-12. Current SpecEntry delegates structural variant construction and emission to
`HandlerVariantEmitter`; see [[handler-ir-design]] and [[specentry-perl-coupling-inventory]]. Its Perl runtime
wrapper still compiles emitted Perl using `eval`, but this is not a current project-wide blocker to native
Rust, Dart, Julia, or Lua implementations. Their admitted rule-local contract is indexed in
[[rule-local-cursor-and-bare-edge-contract]]. The original proposal and evidence are preserved as history.

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
