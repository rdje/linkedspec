---
id: rust-staged-ast-enrichment-recursive-authority
title: Rust privately schedules staged-AST markers breadth-first under one bounded source-aware authority
answers:
  - "does Rust recursively schedule staged AST parse jobs"
  - "where is Rust staged AST enrich_recursively implemented"
  - "how does Rust order recursively returned staged markers"
  - "what is in the Rust staged AST active chain"
  - "how does Rust detect a staged parse cycle"
  - "when may the same Rust staged parser and top rule recur"
  - "are Rust staged parse budgets reset at a new depth"
  - "how do Rust staged child safe points observe cancellation and deadlines"
  - "how are Rust staged child diagnostics rebased to original source"
  - "does Rust invent a contiguous span for a derived staged payload"
  - "how are Rust staged result nodes and diagnostic bytes bounded"
  - "is Rust general staged AST enrichment admitted"
  - "why does the Rust staged AST module still allow dead_code"
  - "what is FUTURE-PARITY-BACKLOG 14.7.4.3"
date: 2026-08-26
status: current private dormant recursive authority; fresh carriers, production call seam, admission, and rollout remain FUTURE-PARITY-BACKLOG.14.7.4.4-owned
tags: [rust, staged-parsing, recursive-queue, breadth-first, cancellation, budgets, diagnostics, source-location, private, dormant]
evidence: "FUTURE-PARITY-BACKLOG.14.7.4.3 extends private rust/linkedspec-runtime/src/staged_ast_enrichment.rs with enrich_recursively. Each complete depth is resolved, authority-checked, stitch-validated, and typed-sorted before callbacks; successful returned markers enter only the next depth. Callback requests receive fresh parser state and detached prior-chain tuples containing normalized parser, selected top, SHA-256 of exact UTF-8 payload text, and full typed provenance. Exact repeats are staged_cycle; same-parser/top recurrence requires strict segment containment and smaller total Unicode-scalar extent. One caller cancellation identity/callback, clock/deadline, remaining steps, total calls, maximum depth/calls, cumulative result nodes, and diagnostic bytes spend monotonically without reset. Expiring callback contexts provide safe_point plus direct/ordered-derived position, span, and diagnostic rebasing; cross-segment spans retain concatenate_in_order. The cfg consumer proves all ten neutral chain rows and adversarial queue/resource/rebasing cases before only the .14.7.4.4 carrier/admission sentinel. Ordinary discovery remains zero tests, canonical CI has no test-path reference, neutral governance remains 79 mutations with Rust dormant_red, and function-body v1/generated v2/public/outward truth does not move."
root_cause: "The current-depth authority deliberately stopped after one complete marker depth and left returned markers inert. Rust therefore lacked invocation-wide queue lineage, monotone cross-depth resources, callback liveness/safe points, and typed child-local projection even though the neutral contract and Perl mechanism already fixed those semantics."
reverify:
  - "RUSTFLAGS='--cfg linkedspec_staged_ast_enrichment_red' bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract"
  - "bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "rg -n 'enrich_recursively|StagedRecursiveAuthority|safe_point|staged_cycle|staged_chain_non_decreasing|staged_diagnostic_truncated' rust/linkedspec-runtime/src/staged_ast_enrichment.rs rust/linkedspec-runtime/tests/staged_ast_enrichment_contract.rs"
---

# Rust recursive staged-AST authority

`enrich_recursively(...)` preserves the one-depth `enrich_current_depth(...)` API while repeatedly preparing and
settling complete breadth-first queue depths. Every depth orders typed parent paths, provenance, and job ids before
any callback runs. Only successfully stitched returned markers are discovered, and they cannot run until every
sibling at their producing depth has settled.

The active lineage tuple contains normalized parser identity, selected top rule, SHA-256 of exact UTF-8 payload
text, and full typed provenance. An exact tuple repeat fails as `staged_cycle`. Reusing a parser/top pair with a
different tuple still fails unless every direct or ordered-derived child segment is contained by an active segment
and total Unicode-scalar extent strictly decreases.

One recursive invocation owns cancellation identity/callback, absolute deadline and caller clock, remaining
steps, total calls, depth/call maxima, cumulative result nodes, and diagnostic bytes. Entry and job ceilings only
narrow them. The ephemeral callback context can spend steps, observe cancellation/deadline, and rebase child-local
positions, spans, or diagnostics; it expires when the callback settles.

Direct spans remain direct. A derived range that crosses source segments remains ordered `derived_text` with
`concatenate_in_order`; Rust never invents a false contiguous source span. Oversized portable diagnostics become
the exact `staged_diagnostic_truncated` sentinel, and all retained scheduler records are detached.

This authority is still private and dormant. `.14.7.4.4` owns fresh native/reconstructed/generated/emitted
top-level authority, the first production caller, removal of the cfg-conditional dead-code allowance, ordinary and
canonical admission, Rust rollout promotion, and parent closure.

Related: [[rust-staged-ast-enrichment-current-depth-authority]],
[[rust-staged-ast-enrichment-marker-provenance]], [[general-staged-ast-enrichment-neutral-contract]],
[[general-staged-ast-current-boundary]], [[typed-source-location-cursor-algebra-direction]], and ADR `0088`.
