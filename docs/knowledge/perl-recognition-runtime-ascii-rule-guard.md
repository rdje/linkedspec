---
id: perl-recognition-runtime-ascii-rule-guard
title: Perl recognition runtime rejects valid Unicode rule labels through an ASCII-only name guard
answers:
  - "why does a compiled Perl Unicode rule fail with rule must be a bare identifier"
  - "which task repairs Perl recognition rule labels under pinned XID authority"
date: 2026-10-29
status: confirmed Ω recognition rejection; P1 repair48.2.6 before48.3/admission
evidence: "rust-blind-parent-push-intake.json.gz retains actual public/SDK/fresh source/results/typed context/producer receipts."
reverify: "Restore retained producers under owning leaf; use routed public Perl and locked offline Cargo wrappers, preserving initial/refined inputs and exclusions."
---

Public Ω-root source compiles and selects top_rule Ω, but native/emitted
execution fails before input at0. The structured context identifies runtime_handler,
rule_handler_eval, Ω and RecognitionTransactionRuntime's bare identifier error.
_required_name validates all roles with ASCII [A-Za-z_][A-Za-z0-9_]*. The existing
pinned Unicode17 XID classifier independently accepts Ω and rejects A-B. ADR0051
already governs exact rule-label identity; this is an implementation gap, not a
new Unicode policy.48.2.6/P1 after48.2.5 before48.3 owns role-specific repair and
strict negative isolation, preserving other identifier grammars. No peer failure
or broad Unicode/frontend completion is inferred. Actual source/typed context/
classifier producer and results are retained in rust-blind-parent-push-intake.json.gz.
