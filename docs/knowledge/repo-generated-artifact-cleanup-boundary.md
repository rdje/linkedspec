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
date: 2026-07-26
status: accepted
tags: [repo-hygiene, artifacts, cleanup, rust, julia, depot, precompile, mdbook, rgx, task-tree]
evidence: "REPO-HYGIENE.3-.5 established the historical rebuildable-output boundary. PROJECT-DATA-SSD-ROOTING.2.0-.2.6 supersede routine space-recovery behavior: the repository now resides on a 4 TB SSD; supported workflows retain reusable language caches under .linkedspec-data/cache, use runtime-derived same-filesystem scratch, and reject project-owned output on another filesystem. tools/test_tool_project_data_storage.sh proves exact output boundaries without broad temporary-root scans."
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

Do not delete `.log` or `.bin` hits under `rgx/` as part of parent-repo cleanup. Those files are inside the tracked
`rgx` submodule's stimulus, fixture, or issue-artifact corpus. Any pruning there needs an explicit submodule-owned
task and its own status check.

`REPO-HYGIENE.5` repeated the boundary on 2026-07-17. It removed 2.6G of Rust output, 30M of Dart output, 267M of
dedicated Julia compiled caches, and fifteen exact stale generation logs totaling about 13.6GB decimal. Available
space increased by 16G at the deletion boundary (55G/89% to 71G/85%). The two Julia depots retained noncompiled
content, and the unrelated 18G `claude-501` tree remained untouched.
