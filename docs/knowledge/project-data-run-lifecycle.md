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
status: observed
tags: [architecture, storage, filesystem, scratch, lifecycle, concurrency, recovery, cache, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.1.3 adds tools/project_data_run.sh around all 14 standard workflow boundaries. A persisted root-relative random checkout identity namespaces mktemp-created run directories; ownership markers bind exact identity, failure policy, and wrapper/foreground-child liveness. Success and default failure delete only the exact validated run, LINKEDSPEC_FAILED_RUN_POLICY=retain explicitly keeps failures, --recover removes only dead abandoned runs, and --purge-failed removes only dead retained failures. tools/test_project_data_lifecycle.sh proves cleanup, cache retention, explicit failure retention, concurrency isolation, live-child protection, invalid-marker and namespace-symlink rejection, and checkout namespace isolation. PROJECT-DATA-SSD-ROOTING.3.1.1 establishes a remaining boundary: marker version 1 does not track descendants. A deterministic probe observes descendant_live=yes and run_present=no after the direct child launches a descendant with cwd in managed tmp and returns. PROJECT-DATA-SSD-ROOTING.3.1.2 owns remediation."
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
non-symlink ownership marker with its checkout id, exact run name/token, state, failure policy, wrapper PID, child
PID, and exit status. Cleanup and recovery refuse an invalid marker and remove one validated leaf, never a broad
scratch root. A dead default-delete failure is abandoned/recoverable; only a marker that binds explicit `retain`
policy is classified as a diagnostic failure.

Abrupt termination can leave an `active` marker. `bash tools/project_data_run.sh --list` reports owned live,
failed, and abandoned runs. `--recover` removes an abandoned run only when neither its wrapper nor foreground child
is live; it retains explicit failures. `--purge-failed` is the separate explicit deletion for dead retained
failures.

Known gap: marker version 1 does not prove descendant liveness. A direct child can launch a background descendant
whose cwd remains inside managed scratch, return, and cause normal cleanup to delete the run while that descendant
is still live. Abrupt wrapper/direct-child loss can create the same recovery hazard. Until
`PROJECT-DATA-SSD-ROOTING.3.1.2` lands, a foreground command must not return while descendants consume scratch, and
operators must not use recovery when untracked descendants may still exist. Related facts:
[[project-data-env-initializer]], [[project-data-workflow-routing]], [[project-data-ssd-storage-locality]].
