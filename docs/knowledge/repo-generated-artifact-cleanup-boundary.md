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
date: 2026-07-10
status: accepted
tags: [repo-hygiene, artifacts, cleanup, rust, julia, depot, precompile, mdbook, rgx, task-tree]
evidence: "REPO-HYGIENE.3 established ignored/untracked rust/target and docs/linkedspec-book/book as rebuildable cleanup targets while preserving rgx corpus artifacts. REPO-HYGIENE.4 repeated that proof and added Julia-aware measurement: /private/tmp/linkedspec-julia-depot/compiled was 148M and ~/.julia/compiled was 261M, distinct from packages, registries, environments, logs, and scratchspaces. A follow-up root-cause scan found /private/tmp at 46G: twelve July 6–9 LinkedSpec/RGX generation logs accounted for about 18G, their headers named repo parser-generation commands, and process/lsof checks found no writer. The leaf removed only those logs plus the four build/cache targets, reclaiming about 20G and moving availability from 50G/90% to 68G/86%. The unrelated 29G claude-501 directory and unrelated cargo-mutants trees were preserved."
reverify: "git check-ignore -v rust/target docs/linkedspec-book/book; git ls-files rust/target docs/linkedspec-book/book; du -sh /private/tmp; du -sk /private/tmp/* 2>/dev/null | sort -n | tail -n 25"
---

# Repo Generated Artifact Cleanup Boundary

`rust/target` and `docs/linkedspec-book/book` are ignored, untracked, rebuildable generated outputs in the parent
checkout. They are safe cleanup targets when disk space matters.

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
