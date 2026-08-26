---
id: perl-staged-ast-enrichment-dormant-red
title: Perl general staged-AST enrichment has private recursive authority and stops before carriers
answers:
  - "where is the Perl staged AST enrichment dormant RED"
  - "what is the first Perl general parse_job failure"
  - "does Perl lower parse_job to STAGED_PARSE_JOB_MARKER"
  - "what is the current Perl general parse_job RED"
  - "how many assertions pass after Perl marker provenance"
  - "does Perl general parse_job use raw Perl fallback"
  - "does the Perl staged function-body adapter resolve expr-v1"
  - "how many assertions pass before the Perl staged AST RED"
  - "is the Perl staged AST consumer in ordinary tests"
  - "is the Perl staged AST consumer in canonical CI"
  - "does the Perl dormant RED change function-body v1"
  - "which task adds Perl staged parse-job provenance"
date: 2026-08-25
status: historical dormant RED superseded by four-carrier Perl admission
tags: [perl, staged-parsing, parse-job, ActionIR, source-provenance, RED, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.7.3.0 adds t/staged_ast_enrichment_perl_contract.t at its final path without phase-0 or canonical registration. The consumer passes 60 assertions over all neutral inventories, exact v1 registry phases/diagnostics, and descriptor body_ast stitching, then fails only because assignment-form parse_job remains ordinary ASSIGN with one unsupported-helper sentinel, zero raw dependencies, and no STAGED_PARSE_JOB_MARKER. LinkedSpec::StagedParserRegistry separately rejects expr-v1 at resolve. The neutral checker advances only this planned consumer from pending_absent to dormant_red; all semantic counts, 72 mutations, rollout, production, generated, and outward boundaries remain unchanged."
evidence_update_2026_08_26_private_carrier: "FUTURE-PARITY-BACKLOG.14.7.3.1 advances the same consumer to 120 GREEN assertions and one RED for missing pre-registered resolution/cache/result/failure authority. Perl now owns one exclusive STAGED_PARSE_JOB_MARKER, an opaque detached staged_parse_job_v2 declaration sidecar, strict literal options, and ADR-0056 direct/ordered-derived provenance. Malformed/dynamic/smuggled forms and recognition-transaction reachability reject; v1 stays unchanged; ordinary/canonical discovery, carriers, rollout, generated format, public inventory, and outward surfaces remain fixed."
evidence_update_2026_08_26_current_depth: "FUTURE-PARITY-BACKLOG.14.7.3.2 advances the same consumer to 133 GREEN top-level checks and one RED for missing breadth-first recurrence, decreasing-chain/cancellation/resource bounds, and source-rebased diagnostics. Perl now privately owns caller-frozen pure resolution, deterministic v2/cache identities, current-depth typed ordering, fresh sibling contexts, all four result and three failure policies, and detached results without adding a route or public behavior."
evidence_update_2026_08_26_recursive: "FUTURE-PARITY-BACKLOG.14.7.3.3 advances the same consumer to 141 GREEN top-level checks and one RED for native/reconstructed/generated-plan/emitted fresh-authority carriers, ordinary/canonical admission, and Perl rollout promotion. Breadth-first recurrence, exact-text/full-provenance tuples, decreasing chains, shared cancellation/deadline/steps/calls/depth/result/diagnostic limits, ephemeral safe points, direct/derived source rebasing, and transaction closure are private and complete without a route or public behavior."
evidence_update_2026_08_26_admission: "FUTURE-PARITY-BACKLOG.14.7.3.4 supersedes the final RED. The same final-path consumer now passes 143 top-level checks across four fresh-authority carriers and exact admission; neutral+Perl is complete at 78 mutations while public authoring and later backends remain pending."
reverify:
  - "PERL5LIB= prove -q -Iperl t/staged_ast_enrichment_perl_contract.t"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "test \"$(rg -c 't/staged_ast_enrichment_perl_contract[.]t' t/phase0_regression.t)\" -eq 1"
---

# Perl general staged-AST dormant RED

The final-path consumer is `t/staged_ast_enrichment_perl_contract.t`. It is now admitted once through phase-0 and
once through canonical CI. The dormant boundaries below remain historical evidence; current carrier truth is in
[[perl-staged-ast-enrichment-carriers-admission]].

Everything before the implementation boundary is GREEN. The test loads every neutral registry/provenance/
identity/resolution/authority/cache/queue/isolation/policy/chain/detachment inventory and all 37 diagnostics. It
also proves the current function-body-v1 adapter still resolves, loads, compiles, executes, reports the original
wrong-top job context, and stitches an `action_block` into `body_ast` without silently upgrading to v2.

The original sole failure was exact: assignment-form `parse_job(...)` remained an ordinary scalar assignment with
one unsupported-helper sentinel and no dedicated node. Leaf `.14.7.3.1` now owns and closes only that boundary.
`call_spec_handler_subst` emits one private marker constructor; `return_descriptor` reports one exclusive
`STAGED_PARSE_JOB_MARKER`, normalized literal options, and a typed text plan with no unresolved or raw dependency.
Live direct and ordered-derived cases materialize exact text from typed spans into detached opaque sidecars.
Malformed/dynamic options, transformed/literal copied text, copied-text smuggling, invalid provenance, residual
generic calls, and uncommitted-recognition reachability fail closed. The narrow v1 registry still rejects
`expr-v1`, so no accidental resolution or parser authority exists.

The former sole RED required `.14.7.3.4`'s native, reconstructed, generated-plan, and independently loaded emitted
fresh-authority carriers plus ordinary/canonical admission and Perl rollout promotion. That boundary is now closed
at 143/143; caller-prepared resolution/cache, recurrence, bounds, rebasing, all policies, carriers, and admission
are GREEN.

Related: [[general-staged-ast-enrichment-neutral-contract]], [[general-staged-ast-current-boundary]],
[[perl-staged-ast-enrichment-marker-provenance]], [[perl-staged-ast-enrichment-current-depth-authority]],
[[perl-staged-ast-enrichment-recursive-authority]],
[[function-body-staged-registry-dispatch]], and ADR `0088`.
