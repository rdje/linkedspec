---
id: claim-verification-index-snapshot
title: Claim verification requires a stable index for cached blobs and live owner selection
answers:
  - "why can claim verification miss a valid declaration when staging overlaps the check"
  - "can I stage files while claim verification is running"
date: 2026-10-05
status: source-confirmed sequencing contract; no checker or policy change
tags: [claims, verification, git, continuity]
evidence: "tools/check_claim_verification.py::run_check snapshots index_files once, reads those blob IDs, and later selects the owner from Git's live staged delta. .1.1.2.1 retains the actual failed overlapping check and canceled CI candidate with explicit unretained original snapshot limits."
reverify: "sed -n '118,150p;185,196p' tools/check_claim_verification.py"
---

Finish staging before running the claim check. Keep the index unchanged until it
finishes. The checker reads claim/task bytes through its initial index blob table;
its final owner selection uses the current staged delta. Those views can differ
when staging overlaps verification. A missing-declaration diagnostic then need not
describe the resulting stable staged task bytes.

The .1.1.2.1 attempt changed the index while a background check ran and returned a
missing-declaration failure. Its resulting staged node had the required declaration.
The source explains the mixed-view mechanism; actual original cached blob IDs were
not captured, so no exact earlier read-boundary recovery is claimed. The orchestration
repair serializes staging and verification, retains the limited original failure and
canceled CI exit143/diff/log, then reruns proof against one unchanged staged candidate.
This records the existing input-stability requirement, without weakening a checker
or adding a claim that concurrent index mutation is supported.
