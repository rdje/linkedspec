---
id: progressive-span-dispatch-public-no-drift
title: Progressive span dispatch closes at 9/9 as private six-runtime behavior without an outward API
answers:
  - "is progressive span dispatch public"
  - "is progressive span dispatch rollout complete"
  - "what did FUTURE-PARITY-BACKLOG.14.6.8 close"
  - "why was the progressive recurring row still pending after the recurring driver landed"
  - "which documents govern progressive span dispatch public no drift"
  - "which outward surfaces reject progressive span dispatch"
  - "how many progressive span dispatch public mutations exist"
  - "does progressive public no drift add dispatch_span to the shared helper inventory"
date: 2026-08-25
status: current public projection/no-drift; staged dispatch FUTURE-PARITY-BACKLOG.14.7 and combined public no-drift FUTURE-PARITY-BACKLOG.14.8 remain separate
tags: [progressive-parsing, public-no-drift, recurring-gate, source-location, conformance, documentation, api-boundary]
evidence: "FUTURE-PARITY-BACKLOG.14.6.8 promotes the progressive behavioral recurring row through the already-committed tools/check_progressive_span_dispatch_six_runtime.sh and promotes public_no_drift through six exact current documents. The neutral checker is 9/9 with 116 contract mutations and separately enforces public 6 documents / 12 stale-current denials / 10 outward paths / 60 omission-and-injection mutations. Perl 129, cfg-enabled Rust 1, Dart 7, Julia 62, PUC Lua 178, and LuaJIT 178 remain the unchanged private consumers; typed truth remains 12/2/170. No parser, compiler, runtime, consumer, fixture, generated format, shared helper inventory, facade, descriptor/result schema, semantic/MCP surface, CLI, or README behavior changes."
root_cause: "FUTURE-PARITY-BACKLOG.14.6.7 intentionally copied the recursive-observation typed-aggregate precedent and promoted only typed progressive_span_dispatch, even though the independent progressive contract—unlike that aggregate precedent—already defined a behavioral recurring row owned by .14.6.7. The canonical driver landed and passed while that owner-complete row stayed pending with no path. The .14.6.8 checker-first RED reproduced this exact mismatch, then bound the committed driver without changing behavior."
last_verified: 2026-08-25
reverify:
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "bash tools/check_progressive_span_dispatch_six_runtime.sh"
  - "bash scripts/check_readme_stability.sh"
  - "LINKEDSPEC_RUN_PROGRESSIVE_SPAN_MATRIX=1 bash tools/run_ci_local.sh"
---

# Progressive span-dispatch public no-drift

Progressive span dispatch is implemented and admitted as one private intrinsic on Perl, Rust, Dart, Julia, PUC
Lua, and LuaJIT. The authored internal spelling is `dispatch_span("expr-v1", "Expr", span)`, but it is not a
shared public helper and does not appear in a facade, descriptor/result schema, semantic or MCP payload, CLI
option, or README promise.

The public closeout governs six current projections: the source-location chapter, backend-handoff appendix,
project-status page, local-CI guide, capability guide, and Toolbox. Twelve exact stale-current claims cover the
milestone sequence that previously left Lua dormant, called the intrinsic Perl-only or future, or retained 7/9
and pending-public language. Ten outward paths reject three private tokens each.

The completed recurring driver predates this closeout and remains unchanged. `.14.6.8` corrects its stale
behavioral rollout projection, completes `public_no_drift`, and closes `.14.6` at 9/9/116 plus public 6/12/10/60.
Typed source remains 12/2/170. Staged AST dispatch remains `.14.7`-owned, and the combined program-wide typed
public-no-drift row remains `.14.8`-owned.

Related: [[progressive-span-dispatch-recurring-gate]], [[progressive-span-dispatch-audit-plan]], and ADR `0080`.
