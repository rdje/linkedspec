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
date: 2026-08-01
status: public-closed under FUTURE-PARITY-BACKLOG.24
tags: [capability, governance, exclusions, status-drift, task-tree, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.7.1 first exposes that future.semantic_introspection_mcp and future.rule_local_cursor_and_bare_edges can stay stale while capability rows pass 80/0/0. FUTURE-PARITY-BACKLOG.24.0 freezes the exact correction, and .24.1 implements schema v2 with two status-fresh records, derived owner status, 24 manifest mutations, and rows 80/0/0. FUTURE-PARITY-BACKLOG.24.2 proves the checker still accepts a contradictory rendered-book schema/count claim, then binds 12 governed projections plus ten stale-current denials through six public mutations and closes parent .24; canonical proof passes CLI 66x2, RAM 52%, and Phase 0 1,031/1,031 in 651 seconds."
reverify: "perl tools/check_capability_conformance.pl && ! rg -n 'future.semantic_introspection_mcp|future.rule_local_cursor_and_bare_edges' capability_conformance/manifest.json && rg -n 'legacy.perl_plugin_registry|future.general_parse_job_authoring|disposition|retention_authority' capability_conformance/manifest.json"
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
book gap directly; the manifest remains the independent semantic authority.

Related facts: [[capability-exclusion-freshness-model]], [[pending-staged-owner-metadata-corruption]],
[[callable-mdbook-public-count-drift]], [[semantic-introspection-public-no-drift]], and
[[rule-local-cursor-five-backend-admission]].
