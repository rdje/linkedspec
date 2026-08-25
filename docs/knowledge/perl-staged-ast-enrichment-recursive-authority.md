---
id: perl-staged-ast-enrichment-recursive-authority
title: Perl privately schedules staged-AST markers breadth-first under one bounded source-aware authority
answers:
  - "does Perl recursively schedule staged AST parse jobs"
  - "where is Perl staged AST enrich_recursively implemented"
  - "how does Perl order recursively returned staged markers"
  - "what is in the Perl staged AST active chain"
  - "how does Perl detect a staged parse cycle"
  - "when may the same Perl staged parser and top rule recur"
  - "are Perl staged parse budgets reset at a new depth"
  - "how do Perl staged child safe points observe cancellation and deadlines"
  - "how are Perl staged child diagnostics rebased to original source"
  - "does Perl invent a contiguous span for a derived staged payload"
  - "how are Perl staged result nodes and diagnostic bytes bounded"
  - "is Perl general staged AST enrichment admitted"
  - "what is FUTURE-PARITY-BACKLOG 14.7.3.3"
date: 2026-08-26
status: current private dormant recursive authority; carriers, admission, rollout, and public authoring pending
tags: [perl, staged-parsing, recursive-queue, breadth-first, cancellation, budgets, diagnostics, source-location, private]
evidence: "FUTURE-PARITY-BACKLOG.14.7.3.3 extends unexported LinkedSpec::StagedASTEnrichment with enrich_recursively. Every complete depth is discovered, resolved, authority-checked, stitch-validated, and typed-sorted before callbacks; returned markers enter only the next depth. Callback requests receive fresh parser state and an active chain of exact normalized parser/top/exact-text-digest/full-provenance tuples. Exact repeats are staged_cycle; same parser/top recurrence requires every direct/ordered-derived segment be contained in the active provenance and total Unicode-scalar extent strictly decrease. One caller-owned cancellation identity/callback, clock/deadline, remaining steps, total calls, max depth/calls, cumulative result nodes, and diagnostic bytes narrow and spend without reset. Ephemeral callback contexts provide safe_point plus direct/ordered-derived position, span, and diagnostic rebasing; cross-segment spans remain concatenate_in_order provenance. The dormant oracle has 141 GREEN top-level checks and one carriers/admission RED. Function-body v1, neutral lifecycle/rollout, ordinary/canonical discovery, generated format, public/outward surfaces, and other backends remain unchanged."
reverify:
  - "perl -Iperl -c perl/LinkedSpec/StagedASTEnrichment.pm && perl -Iperl -c t/staged_ast_enrichment_perl_contract.t"
  - "test \"$(PERL5LIB= prove -Iperl t/staged_ast_enrichment_perl_contract.t 2>&1 | rg -c 'Failed 1/142 subtests|expected RED: missing authority=\\[native_fresh_authority,reconstructed_fresh_authority,generated_plan_fresh_authority,emitted_module_fresh_authority,ordinary_canonical_admission,perl_rollout_promotion\\]')\" -eq 2"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
---

# Perl recursive staged-AST authority

`LinkedSpec::StagedASTEnrichment->enrich_recursively(...)` is a private, deliberately unrouted post-AST entrypoint.
It preserves the one-depth `enrich_ast(...)` API while repeatedly preparing and settling complete queue depths.
Every depth is ordered by typed parent path, provenance, and job id. A marker returned by one callback cannot run
until every sibling at the producing depth has settled.

The scheduler's private lineage frame retains normalized parser identity, selected top rule, SHA-256 of the exact
UTF-8 payload text, full typed provenance, and job id. Callback-visible chain rows are detached four-part tuples.
An exact tuple repeat fails as `staged_cycle`. A same-parser/top repeat with a different tuple still fails unless
every child segment is contained by an active segment and its total Unicode-scalar extent is smaller.

One recursive invocation owns cancellation, an absolute deadline, shared steps, total calls, depth/call maxima,
cumulative result nodes, and diagnostic bytes. Caller and entry ceilings only narrow these values. The ephemeral
execution context can spend steps or observe cancellation/deadline at a child safe point, and expires immediately
when the callback settles.

Child-local positions and spans project through the marker's original direct or ordered-derived provenance.
A local range crossing derived segments becomes ordered `derived_text`; it is never flattened to a false direct
span. Portable child diagnostics use the same projection before scheduler retention, and oversized diagnostics
become the exact `staged_diagnostic_truncated` sentinel.

This is still private implementation evidence. `.14.7.3.4` alone owns native/reconstructed/generated-plan/emitted
fresh-authority carriers, ordinary/canonical registration, Perl rollout promotion, and behavioral-parent closure.
Public `parse_job(...)` authoring remains `.14.7.9`.

Related: [[perl-staged-ast-enrichment-current-depth-authority]],
[[perl-staged-ast-enrichment-marker-provenance]], [[general-staged-ast-enrichment-neutral-contract]], and ADR `0088`.
