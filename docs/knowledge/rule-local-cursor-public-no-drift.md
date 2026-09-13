---
id: rule-local-cursor-public-no-drift
title: "Rule-local cursor public no-drift closes the executable rollout"
answers:
  - "is rule local cursor public no drift complete"
  - "what documents are governed by the cursor public contract"
  - "what stale parse_mode guidance is mechanically forbidden"
  - "what is the final rule local cursor rollout"
  - "how many rule local cursor mutations are rejected"
  - "does cursor closeout also close the AND OR semantics parent"
date: 2026-07-20
status: public no-drift complete; rollout 8 complete / 0 pending
tags: [cursor, parse-mode, public-contract, documentation, mdbook, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.9 adds `public_contract` to `capability_conformance/rule_local_cursor_contract.json` and mirrored validation to `tools/check_rule_local_cursor_contract.py`. Required current markers cover README, toolbox, user guide, capability/CLI guidance, both roadmaps, architecture/live/task state, ADR 0044, mdBook API/backend/runtime/status/user-model pages, and Knowledge Map cards. Exact stale-current claims about accepted global `parse_mode`, pending backend migration, generated-v1 admission, and pending public closeout fail mechanically. The checker advances only `public_no_drift`, closes at 75 migration files / 8 complete + 0 pending / 60 mutations, and leaves `.9.1`/`.9` active because pending child `.9.1.10` owns explicit repeated-OR action-result shape."
evidence_update_2026_07_29_readme_routing: "README-STABILITY-POLICY.1 retires root README as a changing capability-status marker owner while retaining the guide, capability/CLI, roadmap, architecture, task, ADR, mdBook, and Knowledge owners. README.md loses its parse_mode token and exact migration-group row, so the current census becomes 74 files / 8 complete + 0 pending / 60 mutations without reopening public admission."
evidence_update_2026_07_20_and_or_closure: "FUTURE-PARITY-BACKLOG.9.1.10.7 closes repeated-action public no-drift after every runtime and recurring proof. Exact inventory also found stale parent `.9.1.1` after all of its children were done. The final leaf requires `.9.1.1`, `.9.1.10`, `.9.1`, and `.9` to be done; the broader AND/OR parent is closed and `.10.1` becomes the next owner."
evidence_update_2026_08_30_mdbook_reconciliation: "FUTURE-PARITY-BACKLOG.23.2 adds the action-placement and formal-grammar pages to the same exact public contract, requires their all-five-backend 8/0 cursor and bare-edge markers, and denies three exact staged-rollout claims. Current governance is 30 documents / 28 stale-current denials while the existing 60 semantic/topology/recurring/public mutations and 74-file migration inventory remain unchanged."
reverify: "bash tools/run_python_project_data.sh tools/check_rule_local_cursor_contract.py; bash tools/check_rule_local_cursor_five_backend.sh"
---

## Current inventory update — September13

BACKEND-INTEGRATION-GUIDES.2.1 adds the Rust integration guide, whose link to the
parse-mode-named book chapter is itself a scanned migration token. Register that
one path under public_no_drift: the current ledger is 75 migration files / 8 complete + 0 pending / 60 mutations.
Ten current-document census markers and their exact contract/checker mirrors
advance from 74 to 75. The dated ADR0067 snapshot and earlier evidence stay unchanged.
The offline checker passes 36 family spellings, 18 edges, 8 parent/child cases,
30 public documents, 28 forbidden claims and 60 drift mutations. The exact JSON
delta preserves all non-census semantics, rollout rows and test cases. This is
new documentation ownership, not a new runtime admission or source-reading credit.


Public no-drift is an executable documentation contract, not a prose-only signoff. Each governed current surface
must carry its required rule-local markers, and exact obsolete guidance is denied so that removed caller-global
cursor controls cannot silently return to examples, API lists, help guidance, status ledgers, or the mdBook.

The cursor leaf itself closed only the cursor contract. The later repeated-action rollout has now completed, so
the broader AND/OR parent is closed by `FUTURE-PARITY-BACKLOG.9.1.10.7` after exact four-parent inventory.

Related: [[rule-local-cursor-and-bare-edge-contract]], [[rule-local-cursor-neutral-contract]], and
[[rule-local-cursor-five-backend-admission]].
