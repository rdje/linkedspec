---
id: project-data-run-lifecycle
title: Managed project-data run lifecycle and guarded recovery
answers:
  - where does LinkedSpec put per run scratch
  - how are concurrent LinkedSpec workflow runs isolated
  - when is successful LinkedSpec scratch deleted
  - how do I retain a failed LinkedSpec run for diagnosis
  - how do I list retained or interrupted LinkedSpec runs
  - how do I recover scratch after an interrupted LinkedSpec workflow
  - how do I purge an explicitly retained failed run
  - how does one LinkedSpec checkout avoid deleting another checkout data
  - does scratch cleanup delete reusable package caches
  - how is the project data lifecycle tested
  - does managed run recovery prove all descendants are dead
  - may I recover an interrupted run while a grandchild is live
date: 2026-07-26
status: current
tags: [architecture, storage, filesystem, scratch, lifecycle, concurrency, recovery, cache, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.1.3 adds tools/project_data_run.sh around all standard workflow boundaries. PROJECT-DATA-SSD-ROOTING.3.1.2 upgrades ownership to marker version 2: each top-level command is the leader of one dedicated process group, normal cleanup waits for the group to drain, signals target the group, and recovery/purge repeat wrapper/child/group liveness checks immediately before exact removal. Live or reused group ids retain scratch conservatively; legacy, malformed, mismatched-group, indeterminate starting, symlink, and foreign-checkout candidates cannot authorize automated deletion. tools/test_project_data_lifecycle.sh proves cleanup/cache/retention/concurrency, background descendants, group-wide signals, abrupt wrapper/direct-child loss, live-orphan-group recovery refusal, post-drain recovery, and marker rejection."
reverify: "bash -n tools/project_data_env.sh tools/project_data_run.sh tools/test_project_data_lifecycle.sh && bash tools/test_project_data_lifecycle.sh && bash tools/test_project_data_workflow_routing.sh && bash tools/project_data_run.sh --list && rg -n 'PROJECT-DATA-SSD-ROOTING\\.3\\.1\\.2' docs/tasks/PROJECT-DATA-SSD-ROOTING.md"
---

Standard routed workflows execute through `tools/project_data_run.sh`. The wrapper creates one collision-safe
directory below repository-relative `/.linkedspec-data/scratch/runs/<checkout-id>/`, exports it as
`LINKEDSPEC_RUN_DIR`, and points `TMPDIR`, `TMP`, and `TEMP` at its private `tmp/` child. The checkout identity is a
random, path-free token stored at `/.linkedspec-data/checkout-id`; it moves with the checkout and prevents ordinary
recovery in one checkout namespace from scanning another. Concurrent invocations use distinct `mktemp` names.

Successful scratch is deleted. Failed scratch is also deleted by default; set
`LINKEDSPEC_FAILED_RUN_POLICY=retain` on an invocation only when its diagnostic state is worth preserving. Retained
package/dependency state beneath `/.linkedspec-data/cache/` is never part of run cleanup. Every run carries a
non-symlink version-2 ownership marker with its checkout id, exact run name/token, state, failure policy, wrapper
PID, child PID, process-group id, and exit status. The child must be the exact positive group leader for every
post-start state. Cleanup and recovery refuse an invalid marker and remove one validated leaf, never a broad
scratch root. A dead default-delete failure is abandoned/recoverable; only a marker that binds explicit `retain`
policy is classified as a diagnostic failure.

The top-level command leads a dedicated process group inherited by its descendants. Normal success/default-failure
cleanup waits until that whole group drains; HUP, INT, and TERM are forwarded to it. Abrupt termination can leave
an `active` marker. `bash tools/project_data_run.sh --list` reports owned live, failed, abandoned, and indeterminate
runs. `--recover` removes an abandoned run only after wrapper, child, and group liveness are checked again at the
deletion boundary; it retains explicit failures. `--purge-failed` is the separate explicit deletion for dead
retained failures. A live or reused PID/group is a conservative retain. Legacy, malformed, mismatched-group, and
interrupted `starting` markers never authorize automated deletion. Related facts:
[[project-data-env-initializer]], [[project-data-workflow-routing]], [[project-data-ssd-storage-locality]].
