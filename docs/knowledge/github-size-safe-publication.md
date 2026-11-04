---
id: github-size-safe-publication
title: Publish oversized history through measured incremental packs on a temporary upload branch
answers:
  - "how can LinkedSpec publish a backlog above the GitHub push size limit"
  - "is the uncompressed Git object total the actual upload size"
  - "why use a temporary upload branch before updating main"
  - "where are the original backlog planner and actual publication records retained"
  - "are successive Git range object lists disjoint"
date: 2026-11-04
status: backlog published at d3a26a94f5c2; bounded logical input custody reviewed
tags: [git, publication, pack, github, continuity]
evidence: "Primary Git/GitHub contracts; original records, raw/normalized plans, actual publication logs/receipt and complete logical Git-object manifest in docs/checkpoints/publication-custody-2026-11-04/; scoped claim TYPE-REFERENCE-BOOK.1.2.23.4.7."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/publication-custody-2026-11-04/review.py; optional --verify-objects repeats full opaque body hashes. close_claim.py verifies that only the two original disclosed legs change. Archived planners and publisher are historical writers; never rerun them for review."
---

GitHub documents a maximum 2 GiB single push and successive smaller pushes as the
workaround: https://docs.github.com/en/get-started/using-git/troubleshooting-the-2-gb-push-limit.
Git transfers compressed objects and deltas; a raw object total is a different
measurement. Thin packs omit common objects already held by the receiver:
https://git-scm.com/docs/git-pack-objects and https://git-scm.com/docs/git-push.

For the initial 2ac834913..cd3b6adc backlog, retained diagnostic observations show
about 17.7 GiB of uncompressed objects and 9.30 GB in a thin-pack estimate against
the advertised remote main. The actual original call/output records and planner
are recovered in the custody capsule; wrong-budget/chain and original equality
controls close the two disclosed legs. These dated estimates are neither an
actual rejected upload nor a wire-size promise.

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
publisher messages survive in the November4 artifact-review capsule. The separate
publication-custody capsule retains every actual command/log, historical receipt,
raw input stream and109230 reachable logical Git-object identities. Every body
was retrieved and its Git address/SHA256 recomputed; Git history retains bodies
without a duplicate payload archive. Physical pack layout, transitive toolchain
closure, exact wire bytes and future remote state remain unassessed.

Actual successive range lists need not be disjoint: one blob appears in batches12
and20, is reachable through the later negative base history and absent from its
tip tree. The original35008 input rows cover35007 unique outgoing objects with
no missing required new object. Preserve raw lists and check set coverage rather
than summing counts as newly transmitted bodies. The first failed disjointness
review and independent diagnosis remain retained. This is an observed input-list
property, not an inference about Git implementation or wire duplication.

The raw final plan retains its initial head anchor and original last group33.
The normalized report independently derives actual runtime head d3a26a94f5c2,
834 first-parent commits and last range34. All published IDs remain intact.
The one-off publisher is retired as historical evidence for new publication use.

GitHub emitted an accepted50.86MB artifact warning in batch10. Follow-up23.4.8
owns future repository growth against primary host guidance; pack size is not
server on-disk storage, and no historical deletion or rewrite is authorized.
