---
id: capability-exclusion-freshness-gap
title: Capability exclusion freshness gap and schema-v2 repair
answers:
  - "can a stale future exclusion pass the capability checker"
  - "why does the capability manifest still call semantic MCP parked"
  - "why does the capability manifest still call rule-local cursor rollout pending"
  - "which task owns capability exclusion freshness"
  - "does the 80 0 0 capability census prove exclusion prose is current"
  - "how is capability exclusion public drift prevented"
  - "why must docs TASK_TREE keep the capability exclusion closeout marker"
date: 2026-08-01
status: public-closed under FUTURE-PARITY-BACKLOG.24
tags: [capability, governance, exclusions, status-drift, task-tree, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.7.1 first exposes that future.semantic_introspection_mcp and future.rule_local_cursor_and_bare_edges can stay stale while capability rows pass 80/0/0. FUTURE-PARITY-BACKLOG.24.0 freezes the exact correction, and .24.1 implements schema v2 with two status-fresh records, derived owner status, 24 manifest mutations, and rows 80/0/0. FUTURE-PARITY-BACKLOG.24.2 proves the checker still accepts a contradictory rendered-book schema/count claim, then binds 12 governed projections plus ten stale-current denials through six public mutations and closes parent .24; canonical proof passes CLI 66x2, RAM 52%, and Phase 0 1,031/1,031 in 651 seconds."
evidence_update_2026_08_10_document_closeout: "LIVE-DOCUMENT-PRESSURE-CONTAINMENT.4 first shortened the FUTURE-PARITY-BACKLOG row in docs/TASK_TREE.md while restoring the product frontier. Canonical capability conformance rejected the resulting tree because parent .24 closure does not substitute for the checker-owned exact .24.2 public-closeout projection. The focused rerun then rejected synonymous 'remains public-closed' in place of the exact 'is public-closed' parent projection. Restoring both markers makes capability conformance pass at 80/0/0, 24 governance mutations, 12 governed projections, and six public mutations; no oracle is weakened."
evidence_update_2026_08_28_parse_job_admission: "The same freshness rule fires at delivery: FUTURE-PARITY-BACKLOG.14.7.9 removes future.general_parse_job_authoring, leaving one legacy exclusion. Current capability truth is 17 rows/85 pass/0 partial/0 gap with 19 governance mutations, 12 governed projections, and six public mutations."
reverify: "perl tools/check_capability_conformance.pl && ! rg -n 'future.general_parse_job_authoring|future.semantic_introspection_mcp|future.rule_local_cursor_and_bare_edges' capability_conformance/manifest.json && rg -n 'legacy.perl_plugin_registry|disposition|retention_authority' capability_conformance/manifest.json"
---

The capability census and the exclusion narrative are separate data surfaces. Before `.24.1`, governance strongly
validated every capability row and required each exclusion to have exactly `id`, `reason`, and `owner`, but it
proved only that the owner was a tracked task id. It did not compare owner status or prose against completed
rollout authority.

That gap was observable while semantic introspection plus MCP and rule-local cursor rollout were complete but two
future records still described their earlier pending states. It did not make the 80/0/0 capability-row count
false, but it made the same manifest internally misleading to readers and future agents.

`FUTURE-PARITY-BACKLOG.24.1` repairs the gap after planning `.24.0` classifies retained legacy separately from true
future work and identifies superseded `.2`. Schema v2 carries explicit disposition and a nullable durable
retention authority, exact record/order and owner/status relationships are mutation-sensitive, and only the two
audit-proven stale records disappear. No runtime or capability row moves.

Capability exclusion freshness is public-closed under `FUTURE-PARITY-BACKLOG.24`. Closeout `.24.2` adds 12 exact
governed projections, ten path-scoped stale-current denials, and six public mutations after reproducing the former
book gap directly; the manifest remains the independent semantic authority. Because the central task index is one
of those projections, a compact frontier rewrite must retain both exact parent `.24` and child `.24.2` closeout
markers; synonymous status prose is not interchangeable governed evidence.

Portable `parse_job(...)` admission later exercises that model exactly as intended: `.14.7.9` removes the
satisfied future record in the delivery slice. The only current exclusion is the explicitly retained legacy Perl
plugin registry; capability rows are 17/85/0/0 and current governance is 19 mutations.

Related facts: [[capability-exclusion-freshness-model]], [[pending-staged-owner-metadata-corruption]],
[[callable-mdbook-public-count-drift]], [[semantic-introspection-public-no-drift]], and
[[rule-local-cursor-five-backend-admission]].
