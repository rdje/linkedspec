---
id: capability-exclusion-freshness-model
title: Capability exclusion freshness is schema-v2 governed and public-closed
answers:
  - "which capability exclusions should remain after the freshness audit"
  - "which capability exclusions are stale and must be removed"
  - "what task owns general parse job authoring now"
  - "what owner states may a future capability exclusion use"
  - "may a legacy capability exclusion have a completed owner"
  - "what mutations must capability exclusion freshness reject"
  - "why does the capability exclusion plan say 24 mutations when its old list names 23"
  - "is capability exclusion public no drift closed"
date: 2026-08-01
status: public-closed under FUTURE-PARITY-BACKLOG.24
tags: [capability, exclusions, governance, status-freshness, supersession, task-tree, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.24.0 audits all four manifest excluded_or_future records against task status, ADRs, recurring gates, public no-drift cards, Git history, and the sole-facing mdBook. FUTURE-PARITY-BACKLOG.24.1 implements schema v2 with exactly two ordered records: legacy.perl_plugin_registry remains under pending .6 with legacy disposition/null retention; future.general_parse_job_authoring moves from superseded .2 to active .14 with future disposition/null retention. Satisfied semantic/MCP and rule-local cursor records are absent. The checker derives unique task ids/leading statuses, preserves 16 capabilities at 80/0/0, and rejects 24 in-memory manifest mutations. FUTURE-PARITY-BACKLOG.24.2 adds 12 governed projections, ten stale-current denials, and six public mutations after reproducing an accepted rendered-book contradiction, then closes parent .24 without manifest or runtime movement. Final canonical proof passes CLI 66x2, RAM 52%, and Phase 0 1,031/1,031 in 651 seconds."
evidence_update_2026_08_28_parse_job_admission: "FUTURE-PARITY-BACKLOG.14.7.9 satisfies and removes future.general_parse_job_authoring in the same public-admission slice. The manifest is now 17 capability rows at 85/0/0 with exactly one exclusion, legacy.perl_plugin_registry. Capability governance rejects 19 current mutations across 12 projections plus six public mutations; staged public authoring has its own 129-mutation authority."
reverify: "perl tools/check_capability_conformance.pl && rg -n 'legacy.perl_plugin_registry|disposition|retention_authority' capability_conformance/manifest.json && ! rg -n 'future.general_parse_job_authoring|future.semantic_introspection_mcp|future.rule_local_cursor_and_bare_edges' capability_conformance/manifest.json"
---

The capability-row census and the exclusion narrative are different ledgers. The current 17 rows are exactly
85 pass / 0 partial / 0 gap while the exclusion list contains one retained legacy record.

Capability exclusion freshness is public-closed under `FUTURE-PARITY-BACKLOG.24`. Twelve governed projections
now carry the same current truth, and six public mutations protect their inventory, markers, denials, and rendered-
book status independently of the 24 manifest-semantic mutations.

| Audited record | Classification | Current authority | Implemented state |
| --- | --- | --- | --- |
| `legacy.perl_plugin_registry` | retained legacy compatibility | pending `.6`; plugin transition card and mdBook legacy chapter | retained as `legacy`, null retention |
| `future.general_parse_job_authoring` | satisfied direction | completed public admission `.14.7.9` | removed in the delivery slice |
| `future.semantic_introspection_mcp` | satisfied stale future narrative | completed `.10`; ADR `0049`; public 9/9, native 6/6, MCP 5/5 + 6/6 | removed |
| `future.rule_local_cursor_and_bare_edges` | satisfied stale future narrative | completed `.9`; ADR `0044`; rollout 8/0 and six-runtime recurrence | removed |

The implementation keeps exclusions explicit rather than inferring meaning from prose. Manifest schema v2 adds
`disposition` (`legacy` or `future`) and nullable `retention_authority` to each exclusion. A future record may
point only to a proposed, pending, or active owner and never uses retention authority. A legacy record may use an
open owner without retention authority; a completed owner is permitted only when a repository-relative durable
authority explicitly retains that legacy exclusion. Thus a completed owner is not blindly rejected, but it is
never silently accepted either.

The checker parses unique task ids and their leading status enum from the tracked task sources, removes redundant
hard-coded owner insertions, requires the exact current exclusion set and order, and rejects all satisfied ids.
Any completed future direction is removed when delivered/abandoned, or rewritten to a precise live
owner if a narrower direction genuinely remains. Supersession removes the old owner/id relationship in the same
slice; it never leaves parallel old/new records.

The 24 RED mutations cover schema downgrade; missing/unknown disposition; both id/disposition mismatches;
future or open-legacy retention misuse; completed legacy without retention; completed future even with retention;
missing owner task/status; duplicate owner id; invalid owner status; missing `retention_authority`; extra, omitted,
duplicated, or reordered exclusions; both exact reason drifts; both owner drifts; and reintroduction of each
satisfied semantic/cursor id. The missing-field mutation is the previously unlabeled 24th class.
All run in memory through the existing checker, so no host-temp or project scratch tree is needed.

Related: [[capability-exclusion-freshness-gap]], [[pplugin-pluginbridge-transition-machinery]],
[[structural-progressive-staged-authoring-doctrine]], [[semantic-introspection-public-no-drift]], and
[[rule-local-cursor-five-backend-admission]].
