---
id: capability-exclusion-freshness-gap
title: Capability exclusion freshness gap and schema-v2 repair
answers:
  - "can a stale future exclusion pass the capability checker"
  - "why does the capability manifest still call semantic MCP parked"
  - "why does the capability manifest still call rule-local cursor rollout pending"
  - "which task owns capability exclusion freshness"
  - "does the 80 0 0 capability census prove exclusion prose is current"
date: 2026-08-01
status: repaired with signoff-complete schema-v2/status governance under FUTURE-PARITY-BACKLOG.24.1
tags: [capability, governance, exclusions, status-drift, task-tree, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.7.1 first exposes that future.semantic_introspection_mcp and future.rule_local_cursor_and_bare_edges can stay stale while capability rows pass 80/0/0. FUTURE-PARITY-BACKLOG.24.0 freezes the exact correction, and .24.1 implements it: manifest schema v2 retains only plugin legacy under pending .6 and parse-job future work under active .14, removes both satisfied narratives, derives owner status from tracked tasks, locks exact order/content, and rejects 24 in-memory mutations while rows remain 80/0/0."
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

Related facts: [[capability-exclusion-freshness-model]], [[pending-staged-owner-metadata-corruption]],
[[callable-mdbook-public-count-drift]], [[semantic-introspection-public-no-drift]], and
[[rule-local-cursor-five-backend-admission]].
