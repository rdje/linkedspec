---
id: perl-staged-ast-enrichment-dormant-red
title: Perl general staged-AST enrichment stops at one missing dedicated marker
answers:
  - "where is the Perl staged AST enrichment dormant RED"
  - "what is the first Perl general parse_job failure"
  - "does Perl lower parse_job to STAGED_PARSE_JOB_MARKER"
  - "does Perl general parse_job use raw Perl fallback"
  - "does the Perl staged function-body adapter resolve expr-v1"
  - "how many assertions pass before the Perl staged AST RED"
  - "is the Perl staged AST consumer in ordinary tests"
  - "is the Perl staged AST consumer in canonical CI"
  - "does the Perl dormant RED change function-body v1"
  - "which task adds Perl staged parse-job provenance"
date: 2026-08-25
status: current dormant RED; private marker/sidecar and typed provenance pending FUTURE-PARITY-BACKLOG.14.7.3.1
tags: [perl, staged-parsing, parse-job, ActionIR, source-provenance, RED, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.7.3.0 adds t/staged_ast_enrichment_perl_contract.t at its final path without phase-0 or canonical registration. The consumer passes 60 assertions over all neutral inventories, exact v1 registry phases/diagnostics, and descriptor body_ast stitching, then fails only because assignment-form parse_job remains ordinary ASSIGN with one unsupported-helper sentinel, zero raw dependencies, and no STAGED_PARSE_JOB_MARKER. LinkedSpec::StagedParserRegistry separately rejects expr-v1 at resolve. The neutral checker advances only this planned consumer from pending_absent to dormant_red; all semantic counts, 72 mutations, rollout, production, generated, and outward boundaries remain unchanged."
reverify:
  - "test \"$(PERL5LIB= prove -Iperl t/staged_ast_enrichment_perl_contract.t 2>&1 | rg -c 'Failed 1/61 subtests|expected RED: missing node=\\[STAGED_PARSE_JOB_MARKER\\]')\" -eq 2"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "test \"$(rg -c 't/staged_ast_enrichment_perl_contract[.]t' tools/run_ci_local.sh t/phase0_regression.t || true)\" -eq 0"
---

# Perl general staged-AST dormant RED

The final-path consumer is `t/staged_ast_enrichment_perl_contract.t`. It is deliberately absent from phase-0 and
canonical discovery. The neutral checker requires the exact file as `dormant_red` while the Perl rollout row
remains pending.

Everything before the implementation boundary is GREEN. The test loads every neutral registry/provenance/
identity/resolution/authority/cache/queue/isolation/policy/chain/detachment inventory and all 37 diagnostics. It
also proves the current function-body-v1 adapter still resolves, loads, compiles, executes, reports the original
wrong-top job context, and stitches an `action_block` into `body_ast` without silently upgrading to v2.

The sole failure is exact. `LinkedSpec::call_spec_handler_subst` lowers assignment-form `parse_job(...)` to an
ordinary scalar assignment containing one `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:parse_job` sentinel.
`return_descriptor` reports ordinary `ASSIGN`, `IMATCH_GROUP_READ`, and `RETURN`, one unresolved helper, zero raw
dependencies, and no `STAGED_PARSE_JOB_MARKER`. The narrow staged registry independently rejects `expr-v1` during
`resolve`, so it grants no accidental loading or general parser authority.

Leaf `.14.7.3.1` owns only the private dedicated marker/sidecar plus typed direct/ordered-derived provenance and
retains this same final-path consumer for its next owned RED. Resolution/cache/policies, recursive scheduling/
bounds/diagnostics, and fresh carriers/admission remain `.2`, `.3`, and `.4` respectively.

Related: [[general-staged-ast-enrichment-neutral-contract]], [[general-staged-ast-current-boundary]],
[[function-body-staged-registry-dispatch]], and ADR `0088`.
