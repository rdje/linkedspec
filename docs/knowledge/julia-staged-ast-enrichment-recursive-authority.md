---
id: julia-staged-ast-enrichment-recursive-authority
title: Julia has private breadth-first staged-AST recurrence with shared bounded authority
answers:
  - "where is Julia recursive staged AST enrichment implemented"
  - "how does Julia queue parse_job markers breadth first"
  - "does Julia rescan old staged parse job markers"
  - "how does Julia detect staged parse job cycles"
  - "when may Julia recursively call the same staged parser and top rule"
  - "what resources are shared across Julia staged parse depths"
  - "how do Julia staged callback safe points work"
  - "when does a Julia staged callback context expire"
  - "how are Julia staged child positions and spans rebased"
  - "how are Julia staged child diagnostics byte bounded"
  - "how are returned markers mapped through staged result policies"
  - "what does FUTURE-PARITY-BACKLOG 14.7.6.3 implement"
date: 2026-08-27
status: current private recursive API; production-carried and privately admitted, but not publicly authored
tags: [julia, staged-parsing, parse-job, recursion, breadth-first, cancellation, budgets, source-location, private]
evidence: "FUTURE-PARITY-BACKLOG.14.7.6.3 preserves _enrich_staged_current_depth and adds the separate unexported _enrich_staged_recursively path in julia/src/runtime/StagedAstEnrichment.jl. One invocation copies the parent AST, carries the same frozen registry/plan cache, and processes a queue one complete depth at a time. Every depth resolves, authority-checks, reserves targets, and typed-sorts all jobs before callback one. Only valid marker values inside a successful detached callback result enter the next queue; their paths are derived from the exact replace_marker, replace_field, sibling_field, or append_child stitch destination, so old inert markers are never rediscovered. Each lineage frame contains normalized resolved parser id, selected top, exact UTF-8 payload SHA-256, and full direct or ordered-derived provenance. An exact tuple repeat is staged_cycle. Same parser/top recurrence is accepted only when every child segment is contained by an active segment and total Unicode-scalar extent strictly decreases. Immutable caller authority plus mutable invocation state share one cancellation identity/probe, clock/absolute deadline, remaining steps, seeded total calls, depth/call maxima, cumulative result-node allowance, and UTF-8 diagnostic-byte allowance across every depth. Each callback receives fresh cursor/mark/capture/variable dictionaries and one ephemeral authority view; dispatch and safe points observe cancellation/deadline and spend the stricter invocation/job budget, then the view expires on return or throw. Direct and ordered-derived provenance project child-local positions, half-open spans, and nested diagnostics back to original source; cross-segment spans remain derived_text/concatenate_in_order, invalid local ranges fail closed, and oversized diagnostics become staged_diagnostic_truncated. Marker-shaped results count atomically for the cumulative result-node budget but still undergo deep plain-data and live-key validation. The dormant consumer is 386 GREEN/one .14.7.6.4 fresh-carrier/production/admission/rollout RED. Complete ordinary Julia, 105/105 corpus, neutral 92-mutation governance, Perl 143/143, Rust 1/1 including its independently compiled emitted carrier, Dart 19/19, and all direct governance ledgers pass; Julia remains dormant and ordinary/canonical discovery remains absent."
root_cause: "Leaf .14.7.6.2 deliberately stopped after one complete marker depth and left returned markers inert. Julia therefore had no lineage-bearing next-depth queue, non-resetting invocation state, callback-lifetime authority, safe-point resource seam, or child-local source projection. Rescanning the stitched AST would have been incorrect because it could reactivate pre-existing inert markers and lose the producing callback's active lineage. The recursive path instead records only marker paths found in each successful detached result and maps them through the exact stitch destination before the next depth is prepared."
evidence_update_2026_08_27_carrier_admission: "FUTURE-PARITY-BACKLOG.14.7.6.4 preserves the recursive scheduler and exposes it only through a host-only seed on four top-level production routes. Each run receives fresh registry/cache/resource state; the exact consumer is 491/491 and admitted once in ordinary/canonical discovery."
last_verified: 2026-08-27
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/test/staged_ast_enrichment_contract_test.jl"
  - "rg -n '_StagedRecursiveAuthority|_evaluate_staged_chain_case|_staged_safe_point|_staged_rebase_(position|span|diagnostic)|_enrich_staged_recursively' julia/src/runtime/StagedAstEnrichment.jl julia/test/staged_ast_enrichment_contract_test.jl"
  - "rg -n 'staged_ast_enrichment_contract_test.jl' julia/test/runtests.jl tools/run_ci_local.sh"
---

# Julia staged recursive authority

`_enrich_staged_recursively` is a private post-AST scheduler over the same
caller-frozen registry used by the one-depth API. The current-depth entrypoint
is unchanged. The recursive entrypoint owns one detached working AST, one
plan-only cache, and one invocation resource record for the complete run.

The queue is breadth-first. A complete depth is prepared and validated before
any callback at that depth executes. Callback-returned markers are collected
only from a successful detached result and inherit their producer's active
frames. The scheduler calculates the marker's future path from the stitch
policy before stitching: the marker path itself for `replace_marker`, the
named result field for `replace_field` and `sibling_field`, and the exact new
list index for `append_child`. It never rescans the complete AST.

An active frame's public tuple is:

```text
[resolved_spec_id, selected_top_rule, payload_sha256, full_provenance]
```

An exact repeat rejects as `staged_cycle`. Reusing only the parser and top is
permitted when every child direct segment is contained in an active direct
segment and the sum of child Unicode-scalar extents is strictly smaller. The
same predicate handles nonempty ordered-derived provenance.

Dispatch entry spends the configured per-call work and increments the shared
call count only after cancellation, deadline, budget, depth, and call-limit
admission. A callback safe point observes the same cancellation probe and
absolute deadline, then spends both the invocation and current-job allowance.
Result nodes and canonical UTF-8 diagnostic bytes are cumulative. No depth or
job resets or extends an invocation-wide ceiling.

Every callback receives a fresh parser-local context. Its private authority
view exposes only cancellation identity, deadline, remaining work, safe-point
spending, and typed source projection. The view is invalidated in a `finally`
boundary after callback return or throw; retained contexts cannot spend or
project later. Direct positions and spans remain direct. A span crossing
ordered source segments remains `derived_text` with
`concatenate_in_order`. Invalid child-local ranges do not invent a source
location, and oversized retained diagnostics become the governed truncation
sentinel.

This remains private behavior, but `.14.7.6.4` now carries it through fresh
native, reconstructed, generated-plan, and emitted-module execution authority
and admits the exact consumer. Public authoring remains separately owned.

Related: [[julia-staged-ast-enrichment-current-depth-authority]],
[[julia-staged-ast-enrichment-marker-provenance]],
[[julia-staged-ast-enrichment-carriers-admission]],
[[general-staged-ast-enrichment-neutral-contract]],
[[general-staged-ast-current-boundary]].

## 2026-09-11 — lineage and source projection reading

Julia .1.21 reads recursive authority validation, complete source-segment extent
checks, exact tuple/nondecreasing lineage diagnostics, and direct/ordered-derived
position/span/diagnostic rebasing through the plan-preparation prefix. Extent
accumulation checks representable bounds before addition. Existing491 consumer
assertions pass; recursive scheduling suffix remains unread. Registry patterns have
separate confirmed gaps under .2.13: [[julia-staged-registry-pattern-boundaries]].
