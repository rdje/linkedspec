---
id: capability-exclusion-freshness-gap
title: Capability exclusions validate owner existence but not current status freshness
answers:
  - "can a stale future exclusion pass the capability checker"
  - "why does the capability manifest still call semantic MCP parked"
  - "why does the capability manifest still call rule-local cursor rollout pending"
  - "which task owns capability exclusion freshness"
  - "does the 80 0 0 capability census prove exclusion prose is current"
date: 2026-08-01
status: current governance gap; exact model frozen under signoff-complete FUTURE-PARITY-BACKLOG.24.0
tags: [capability, governance, exclusions, status-drift, task-tree, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.7.1 corrects future.generic_final_codeblock, then compares the remaining excluded_or_future records with committed rollout authorities. future.semantic_introspection_mcp still says parked under completed .10.1, and future.rule_local_cursor_and_bare_edges still says 5 complete / 3 pending under completed .9.1.2. tools/check_capability_conformance.pl validates exact fields, unique ids, nonempty strings, and tracked owner existence only; perl tools/check_capability_conformance.pl therefore passes 80/0/0 despite the stale narratives. FUTURE-PARITY-BACKLOG.24.0 further proves broad parse-job owner .2 was superseded by active .14/.14.6-.7 and freezes schema-v2 disposition/retention/status governance plus 24 mutations. .24.0.1-.2 repair two independently discovered metadata/public defects before .24.1-.2 implement and close without changing capability rows."
reverify: "perl tools/check_capability_conformance.pl && rg -n 'future.semantic_introspection_mcp|future.rule_local_cursor_and_bare_edges' capability_conformance/manifest.json && sed -n '115,145p' tools/check_capability_conformance.pl && rg -n 'FUTURE-PARITY-BACKLOG.24' docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

The capability census and the exclusion narrative are separate data surfaces. Current governance strongly
validates every capability row and requires each exclusion to have exactly `id`, `reason`, and `owner`, but it
only proves that the owner is a tracked task id. It does not compare owner status or prose against the completed
rollout authority.

That gap is observable today. Semantic introspection plus MCP and rule-local cursor rollout are complete, yet two
future records still describe their earlier pending states. This does not make the 80/0/0 capability-row count
false, but it does make the same manifest internally misleading to readers and future agents.

`FUTURE-PARITY-BACKLOG.24` owns the correction after the callable public closeout. Planning `.24.0` classifies
retained legacy records separately from true future work, identifies the superseded `.2` owner, and avoids a
simplistic rule that rejects every completed legacy owner. Schema v2 instead carries explicit disposition and a
durable retention authority when a completed owner intentionally preserves legacy. The implementation makes the
exact record/order and owner/status relationships mutation-sensitive and corrects only audit-proven records. No
runtime or capability row moves.

Related facts: [[capability-exclusion-freshness-model]], [[pending-staged-owner-metadata-corruption]],
[[callable-mdbook-public-count-drift]], [[semantic-introspection-public-no-drift]], and
[[rule-local-cursor-five-backend-admission]].
