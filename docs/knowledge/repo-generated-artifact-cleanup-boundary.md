---
id: repo-generated-artifact-cleanup-boundary
title: Artifact cleanup may delete Rust/mdBook output and Julia compiled caches, but not source or depot content
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
date: 2026-07-17
status: accepted
tags: [repo-hygiene, artifacts, cleanup, rust, julia, depot, precompile, mdbook, rgx, task-tree]
evidence: "REPO-HYGIENE.3 established ignored/untracked rust/target and docs/linkedspec-book/book as rebuildable cleanup targets while preserving rgx corpus artifacts. REPO-HYGIENE.4 repeated that proof and added Julia-aware compiled-cache and stale-log cleanup, reclaiming about 20G while preserving depot and unrelated temp content. REPO-HYGIENE.5 proved dart/.dart_tool is also ignored/untracked; removed rust/target (2.6G), Dart .dart_tool (30M), two dedicated Julia compiled directories (142M + 125M), and fifteen exact July 15-16 generation logs totaling about 13.6GB decimal after header, process, and lsof proof. The immediate deletion baseline moved from 55G available/89% used to 71G/85%, a measured 16G gain. Both dedicated depots retained registries/logs; unrelated claude-501 (18G), unknown temp trees, and rgx corpus artifacts were preserved."
reverify: "git check-ignore -v rust/target docs/linkedspec-book/book; git ls-files rust/target docs/linkedspec-book/book; du -sh /private/tmp; du -sk /private/tmp/* 2>/dev/null | sort -n | tail -n 25"
---

# Repo Generated Artifact Cleanup Boundary

`rust/target` and `docs/linkedspec-book/book` are ignored, untracked, rebuildable generated outputs in the parent
checkout. Dart's ignored/untracked `dart/.dart_tool` is the same class of rebuildable package/build metadata. They
are safe cleanup targets when disk space matters.

Julia places compiled/precompile output under the active depot's `compiled/` directory rather than under a Rust-
style project target. The repo's dedicated test depot uses `/private/tmp/linkedspec-julia-depot/compiled`; ordinary
user-depot precompiles use `~/.julia/compiled`. Both directories are regenerable and may be removed when disk space
matters and no Julia job is running.

Do not broaden that permission to the whole depot. Preserve `packages/`, `registries/`, `environments/`, `logs/`,
`scratchspaces/`, `artifacts/`, and any source or project manifests unless a separately owned audit proves a
specific target safe.

For logs under `/private/tmp`, require provenance and liveness evidence before deletion: inspect the header to tie
the file to a completed repo generation command and confirm no process has it open. Do not blanket-delete
`/private/tmp`. Agent state, application IPC, other projects' test/mutant trees, and unknown temp directories remain
outside the safe boundary even when they are large.

Do not delete `.log` or `.bin` hits under `rgx/` as part of parent-repo cleanup. Those files are inside the tracked
`rgx` submodule's stimulus, fixture, or issue-artifact corpus. Any pruning there needs an explicit submodule-owned
task and its own status check.

`REPO-HYGIENE.5` repeated the boundary on 2026-07-17. It removed 2.6G of Rust output, 30M of Dart output, 267M of
dedicated Julia compiled caches, and fifteen exact stale generation logs totaling about 13.6GB decimal. Available
space increased by 16G at the deletion boundary (55G/89% to 71G/85%). The two Julia depots retained noncompiled
content, and the unrelated 18G `claude-501` tree remained untouched.
