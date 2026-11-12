---
id: claim-gap-owner-status-vocabulary
title: Claim repair owners use pending active or blocked status
answers:
  - "why is an in_progress gap repair owner rejected"
  - "which task statuses count as open in claim verification"
  - "why does gap repair owner is not open reject an ongoing task"
date: 2026-11-12
status: existing schema clarified; bounded caller-status repair verified
tags: [claims, task-tree, status, verification, ownership]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.30.1; docs/checkpoints/publication-size-monitor-2026-11-12/owner-status/; first normal1 and actual unchanged-parser original RED/fixed GREEN/closed RED."
reverify:
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P docs/checkpoints/publication-size-monitor-2026-11-12/review_landing.py"
---

The claim checker requires exactly one current mutable task node for a gap's
repair owner. Its existing open-status schema accepts `pending`, `active` and
`blocked`. Use `active` while a referenced repair is underway. Other progress
labels used elsewhere in task prose are not automatically members of this schema.

The monitor's first landing uses `in_progress` for still-open parent23.4.30.
`InputSnapshot.check_owner` in tools/check_claim_verification.py rejects it,
blocking the earlier Dart operational claim. The retained whole-task fixtures
exercise the unchanged production parser through its explicit git_reader seam:
the original status is RED, the corrected `active` status is GREEN, and a
`completed` owner remains RED. Every case has exactly one owner match, so this
failure is a status-vocabulary mismatch rather than a duplicate-node ambiguity.

Only the caller's task status changes. The checker contract, original claim
statements, hashes, revisions and measured pack observations stay unchanged.
The separate historical reader recovers actual source/input/channel/full-mode
images and these observations without executing the old producer or current
checker. Full native/raw artifact custody remains separately qualified.

Related: [[github-size-safe-publication]].
