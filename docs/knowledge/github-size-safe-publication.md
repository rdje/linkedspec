---
id: github-size-safe-publication
title: Publish oversized history through measured incremental packs on a temporary upload branch
answers:
  - "how can LinkedSpec publish a backlog above the GitHub push size limit"
  - "is the uncompressed Git object total the actual upload size"
  - "why use a temporary upload branch before updating main"
date: 2026-11-04
status: backlog published at d3a26a94f5c2; initial measurement custody closeout remains owned
tags: [git, publication, pack, github, continuity]
evidence: "GitHub 2 GiB push guidance; Git pack-objects and push documentation; docs/checkpoints/task-acceptance-backend-scope/publication-intake.json and push-plan.json; synthetic publisher controls. Actual publisher messages are retained in docs/checkpoints/artifact-review-2026-11-04/observation.json.gz. Initial planning custody/falsification gaps are explicitly owned by TYPE-REFERENCE-BOOK.1.2.23.4.7."
reverify: "Read source URLs and immutable plan; bash tools/run_python_project_data.sh docs/checkpoints/artifact-review-2026-11-04/review.py reviews dated metadata and retained messages. Repeat only read-only pack measurements at the recorded endpoints; publish.py is a write operation."
---

GitHub documents a maximum 2 GiB single push and successive smaller pushes as the
workaround: https://docs.github.com/en/get-started/using-git/troubleshooting-the-2-gb-push-limit.
Git transfers compressed objects and deltas; a raw object total is a different
measurement. Thin packs omit common objects already held by the receiver:
https://git-scm.com/docs/git-pack-objects and https://git-scm.com/docs/git-push.

For the initial 2ac834913..cd3b6adc backlog, retained diagnostic observations show
about 17.7 GiB of uncompressed objects and 9.30 GB in a thin-pack estimate against
the advertised remote main. Both source/input custody and independent initial
planner RED gaps are disclosed in the publication claim and owned by 23.4.7;
these observations are neither an actual rejected upload nor a wire-size promise.

The prepared publisher uploads successive existing commit tips to its own
temporary branch. Each data batch gets a fresh conservative non-thin size check
below 1.5 GiB. Main stays at its initial tip until the upload reaches the verified
runtime HEAD, then advances once. Git's shared object store should make that last
update small; actual server acceptance and identities must be observed. All Git
IDs survive. Tags and submodule recursion are disabled for these root-repository
pushes. Cleanup deletes only the session's temporary ref with an expected-tip
lease. Existing-ref collisions and unexpected main changes reject.

Synthetic healthy/resume/oversize/wrong-main/collision controls exercise operator
logic without a real push or receipt. The real operation requires a clean tree,
the exact canonical receipt and normal hooks. The actual operation completed23
batches, advanced main to d3a26a94f5c2 and removed its temporary branch. A fresh
remote check matched local/origin main and found no temporary ref. Byte-exact
publisher messages survive in the November4 artifact-review capsule; complete
transport custody and the initial planning proof gaps still belong to23.4.7.

GitHub emitted an accepted50.86MB artifact warning in batch10. Follow-up23.4.8
owns future repository growth against primary host guidance; pack size is not
server on-disk storage, and no historical deletion or rewrite is authorized.
