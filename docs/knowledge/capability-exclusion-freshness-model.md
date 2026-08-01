---
id: capability-exclusion-freshness-model
title: Capability exclusion freshness has an exact four-record audit and schema-v2 governance plan
answers:
  - "which capability exclusions should remain after the freshness audit"
  - "which capability exclusions are stale and must be removed"
  - "what task owns general parse job authoring now"
  - "what owner states may a future capability exclusion use"
  - "may a legacy capability exclusion have a completed owner"
  - "what mutations must capability exclusion freshness reject"
date: 2026-08-01
status: model frozen and signoff-complete under FUTURE-PARITY-BACKLOG.24.0; repair and implementation pending
tags: [capability, exclusions, governance, status-freshness, supersession, task-tree, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.24.0 audits all four manifest excluded_or_future records against task status, ADRs, recurring gates, public no-drift cards, Git history, and the sole-facing mdBook. legacy.perl_plugin_registry remains a deprecated Perl-only compatibility surface under pending .6. General parse-job work remains future, but closed STAGED-LINKED-PARSING and ADR 0056 transfer its current progressive/staged owner from broad .2, now explicitly superseded without implementation, to active parent .14, specifically .14.6-.7. future.semantic_introspection_mcp is satisfied by completed .10 at rollout 9/9, native 6/6, MCP 5/5 implementations plus 6/6 runtimes and must be removed. future.rule_local_cursor_and_bare_edges is satisfied by completed .9 at 8/0 and six-runtime recurrence and must be removed. The plan adopts manifest schema v2 with explicit disposition and nullable retention_authority, exact two-record/order governance, task-state parsing, and 24 in-memory RED mutations without changing capability rows or runtime behavior."
reverify: "perl tools/check_capability_conformance.pl && rg -n 'legacy.perl_plugin_registry|future.general_parse_job_authoring|future.semantic_introspection_mcp|future.rule_local_cursor_and_bare_edges' capability_conformance/manifest.json && rg -n 'FUTURE-PARITY-BACKLOG\\.(2|6|9|10|14)' docs/tasks/FUTURE-PARITY-BACKLOG.md && rg -n 'General public.*parse_job|FUTURE-PARITY-BACKLOG.14' docs/tasks/STAGED-LINKED-PARSING.md docs/decisions/0056-typed-source-location-and-cursor-algebra.md"
---

The capability-row census and the exclusion narrative are different ledgers. The 16 rows remain exactly
80 pass / 0 partial / 0 gap while the exclusion list is corrected.

| Current record | Audit classification | Current authority | Planned action |
| --- | --- | --- | --- |
| `legacy.perl_plugin_registry` | retained legacy compatibility | pending `.6`; plugin transition card and mdBook legacy chapter | retain unchanged |
| `future.general_parse_job_authoring` | valid future direction with superseded owner | active parent `.14`, especially progressive `.14.6` and staged `.14.7` | rewrite/re-owner from `.2` to `.14` |
| `future.semantic_introspection_mcp` | satisfied stale future narrative | completed `.10`; ADR `0049`; public 9/9, native 6/6, MCP 5/5 + 6/6 | remove |
| `future.rule_local_cursor_and_bare_edges` | satisfied stale future narrative | completed `.9`; ADR `0044`; rollout 8/0 and six-runtime recurrence | remove |

The implementation plan keeps exclusions explicit rather than inferring meaning from prose. Manifest schema v2
adds `disposition` (`legacy` or `future`) and nullable `retention_authority` to each exclusion. A future record may
point only to a proposed, pending, or active owner and never uses retention authority. A legacy record may use an
open owner without retention authority; a completed owner is permitted only when a repository-relative durable
authority explicitly retains that legacy exclusion. Thus a completed owner is not blindly rejected, but it is
never silently accepted either.

The checker will parse unique task ids and their leading status enum from the tracked task sources, remove the
three redundant hard-coded owner insertions, require the exact two retained records and order, and reject all
satisfied ids. Any completed future direction is removed when delivered/abandoned, or rewritten to a precise live
owner if a narrower direction genuinely remains. Supersession removes the old owner/id relationship in the same
slice; it never leaves parallel old/new records.

The 24 frozen RED mutations cover schema downgrade; missing/unknown disposition; both id/disposition mismatches;
future or open-legacy retention misuse; completed legacy without retention; completed future even with retention;
missing owner task/status; duplicate owner id; invalid owner status; extra, omitted, duplicated, or reordered
exclusions; both exact reason drifts; both owner drifts; and reintroduction of each satisfied semantic/cursor id.
All run in memory through the existing checker, so no host-temp or project scratch tree is needed.

Related: [[capability-exclusion-freshness-gap]], [[pplugin-pluginbridge-transition-machinery]],
[[structural-progressive-staged-authoring-doctrine]], [[semantic-introspection-public-no-drift]], and
[[rule-local-cursor-five-backend-admission]].
