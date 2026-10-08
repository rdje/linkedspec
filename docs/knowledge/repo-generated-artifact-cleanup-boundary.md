---
id: repo-generated-artifact-cleanup-boundary
title: Rebuildable outputs may be removed only by an owned cleanup, while retained SSD caches stay available
answers:
  - "which generated artifacts are safe to delete for disk cleanup"
  - "can I delete rust target to recover space"
  - "can I delete docs/linkedspec-book/book"
  - "should cleanup delete rgx log files"
  - "should cleanup delete rgx bin files"
  - "which Julia generated artifacts are safe to delete"
  - "can I delete Julia compiled caches"
  - "can I delete the Julia depot"
  - "where are Julia precompile artifacts stored"
  - "can stale LinkedSpec logs under private tmp be deleted"
  - "should cleanup delete all of private tmp"
  - "why was private tmp using 46 gigabytes"
  - "what did REPO-HYGIENE.3 remove"
  - "what did REPO-HYGIENE.4 remove"
  - "what did REPO-HYGIENE.5 remove"
  - "is Dart dot dart tool safe to delete"
  - "how much space did the July 17 artifact cleanup reclaim"
date: 2026-10-08
status: accepted
tags: [repo-hygiene, artifacts, cleanup, rust, julia, depot, precompile, mdbook, rgx, task-tree]
evidence: "REPO-HYGIENE.3-.5 established the historical rebuildable-output boundary. PROJECT-DATA-SSD-ROOTING.2.0-.2.6 supersede routine space-recovery behavior: the repository now resides on a 4 TB SSD; supported workflows retain reusable language caches under .linkedspec-data/cache, use runtime-derived same-filesystem scratch, and reject project-owned output on another filesystem. tools/test_tool_project_data_storage.sh proves exact output boundaries without broad temporary-root scans."
evidence_update_2026_10_02: "REPO-HYGIENE.7 corrects the maintained submodule-task permission statement against the newer director boundary. The archived census/review instruments and exact retained enumeration live in docs/checkpoints/REPO-HYGIENE.7-artifact-review.json; no deletion or liveness/purge operation occurred."
evidence_update_2026_10_03: "REPO-HYGIENE.8 retains the dated parent/Rust enumeration and tracked stdout-only census/read-only reviewer. Fresh metadata and per-file lstat controls pass; zero removals. Current metadata is time-dependent: default review checks the retained snapshot, --live records a new observation."
evidence_update_2026_10_04: "REPO-HYGIENE.9 retains the October4 exact parent/Rust rows and actual full census/review channels with producer guards. Fresh scoped metadata and independent lstat agree, two metadata/four channel controls reject, zero removals. Original snapshots remain immutable; caches/proof data remain retained."
evidence_update_2026_10_07: "REPO-HYGIENE.11 retains the October7 exact parent/Rust metadata snapshot and actual full census/review channels with producer guards. Fresh scoped census and independent per-file lstat, metadata/channel/render controls verify the dated observation; zero removals. Previous snapshots remain immutable, and all evidence/caches remain retained."
evidence_update_2026_10_08: "REPO-HYGIENE.13 retains the dated October8 parent/Rust snapshot and complete actual producer channels. Fresh metadata, independent lstat and effective size/traversal/evidence controls pass. All artifacts remain retained; current start-path guards reject symlink ancestors, nested repositories, mock submodules and outside-root starts before traversal. Earlier snapshots are immutable; no concurrent adversarial filesystem guarantee is inferred."
reverify: "git check-ignore -v rust/target docs/linkedspec-book/book dart/.dart_tool .linkedspec-data; git ls-files rust/target docs/linkedspec-book/book dart/.dart_tool .linkedspec-data; bash tools/test_tool_project_data_storage.sh"
---

# Repo Generated Artifact Cleanup Boundary

`rust/target` and `docs/linkedspec-book/book` are ignored, untracked, rebuildable generated outputs in the parent
checkout. Dart's ignored/untracked `dart/.dart_tool` is the same class of rebuildable package/build metadata. That
classification permits an explicitly owned cleanup when one is genuinely needed; it is not a standing instruction
to purge caches. The repository now has ample SSD capacity, so normal work retains reusable build and package data.

Julia places compiled/precompile output under the active depot's `compiled/` directory rather than under a Rust-
style project target. Supported LinkedSpec workflows use the ignored repository-relative retained Julia depot.
Its compiled cache is regenerable, but it remains retained by default alongside package sources and registries so
offline operation and fast reruns do not depend on a developer-home cache.

Do not broaden that permission to the whole depot. Preserve `packages/`, `registries/`, `environments/`,
`scratchspaces/`, `artifacts/`, and any source or project manifests unless a separately owned audit proves a
specific target safe. The generated Julia `manifest_usage.toml` is one proven exception: supported wrappers remove
it because it is disposable garbage-collection metadata containing runtime absolute paths.

Supported workflows no longer store LinkedSpec logs or scratch under an operating-system temporary root. A targeted
old-root census is justified only for a named migration or residue proof. If one exact legacy file is found there,
require repository ownership and liveness evidence before deleting that exact path. Never inventory or delete an
entire shared temporary root merely to recover space; it can contain agent state, application IPC, and other projects.

Do not delete or modify anything under `rgx/` or any other Git repository. The September27 director
instruction permits this agent to write LinkedSpec only; a task or notification does not authorize crossing
that boundary. Parent cleanup excludes every submodule and nested repository before traversal. Report
upstream artifact issues through the public integration boundary; its owner applies any repair. The older
submodule-owned-task pruning suggestion is superseded. No dependency implementation classification is
needed to enforce this exclusion.

`REPO-HYGIENE.5` repeated the boundary on 2026-07-17. It removed 2.6G of Rust output, 30M of Dart output, 267M of
dedicated Julia compiled caches, and fifteen exact stale generation logs totaling about 13.6GB decimal. Available
space increased by 16G at the deletion boundary (55G/89% to 71G/85%). The two Julia depots retained noncompiled
content, and the unrelated 18G `claude-501` tree remained untouched.
