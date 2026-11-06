---
id: reference-scope-selected-owner
title: Reference scope refresh uses the current leaf through its landing
answers:
  - "why does scope update require its selected unique owning leaf"
  - "which MEMORY field selects reference scope ownership before staging"
  - "can active_work_unit point to the next leaf before scope refresh"
date: 2026-11-06
status: current reference-scope commit-boundary behavior
tags: [reference, scope, memory, owner, commit]
evidence: "Julia74.4 closeout initially set active_work_unit to pending74.5; update_reference_scope.py --owner TYPE-REFERENCE-BOOK.1.2.23.3.74.4 rejected that mismatch. Restoring completed74.4 as active_work_unit accepted the refresh; next_action continues to name74.5. tools/reference_scope.py selected_owner/build are the canonical mechanism."
reverify:
  - "rg -n -A 10 'def selected_owner|def build' tools/reference_scope.py"
---

Before staging, the reference-scope updater selects active_work_unit from MEMORY.
The --owner must match that id and resolve to a unique task-tree node. Keep the
completed current leaf as active_work_unit through its commit; next_action names
the successor. After staging, the verifier selects ownership through
check_task_verification_fields.pl --owner. Do not relabel a scope refresh as
successor work or activate a different leaf while the current slice is dirty.
