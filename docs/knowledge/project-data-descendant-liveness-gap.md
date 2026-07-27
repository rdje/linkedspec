---
id: project-data-descendant-liveness-gap
title: Managed-run markers do not yet own descendant liveness
answers:
  - can a managed run delete scratch while a grandchild is still live
  - does project data recovery track process descendants
  - what descendant lifecycle gap did PROJECT DATA SSD ROOTING 3.1 find
  - why did guarded project data recovery race a compiler descendant
  - which task owns managed run descendant liveness
  - does child pid liveness prove the whole process tree is dead
  - does project data signal forwarding reach grandchildren
date: 2026-07-26
status: observed
tags: [architecture, storage, scratch, lifecycle, recovery, process, concurrency, PROJECT-DATA-SSD-ROOTING]
evidence: "During PROJECT-DATA-SSD-ROOTING.3.1.1, an interrupted Rust storage oracle left its wrapper and recorded direct child dead while a compiler descendant still wrote below managed scratch. Recovery classified the marker abandoned and attempted exact deletion; rm reported Directory not empty during the write race and recovery skipped it, but the code had not proved that refusal. A deterministic repository-local probe then launched a descendant with cwd inside LINKEDSPEC_RUN_DIR/tmp and let the direct child exit successfully. tools/project_data_run.sh deleted the run while kill -0 proved the descendant remained live: descendant_live=yes, run_present=no. Marker version 1 stores wrapper_pid and child_pid only; scan_runs checks only those PIDs, signal forwarding targets only child_pid, and safe_remove_owned_run has no descendant/process-group liveness authority. PROJECT-DATA-SSD-ROOTING.3.1.2 owns the portable fix and focused RED-to-green proof before final residue cleanup."
reverify: "rg -n 'marker_child_pid|pid_is_live.*marker_child_pid|kill -\"\\$signal\".*child_pid|safe_remove_owned_run' tools/project_data_run.sh && rg -n 'PROJECT-DATA-SSD-ROOTING\\.3\\.1\\.2|guard managed-run descendants' docs/tasks/PROJECT-DATA-SSD-ROOTING.md"
---

Marker version 1 proves only wrapper and direct foreground-child liveness. That is insufficient after abrupt
interruption because a compiler, test worker, or other descendant can outlive both recorded PIDs. Normal cleanup
has the same boundary: a direct child can launch a background descendant whose current directory remains inside
managed scratch, return success, and cause the wrapper to delete the run while that descendant is still alive.

The observed `rm -rf` race happened to fail safely while a compiler created files, but filesystem timing is not a
safety mechanism. The deterministic RED removes that ambiguity: after the direct child launched a 60-second
descendant with cwd in the run's `tmp/` directory and exited, the wrapper removed the run and returned while
`kill -0` still reported the descendant live. Signal forwarding likewise addresses only the recorded child PID.

`PROJECT-DATA-SSD-ROOTING.3.1.2` must add portable whole-run process ownership, descendant-aware liveness, and
group signal forwarding before `.3.2` performs final residue deletion. Until then, do not interpret dead wrapper
and child PIDs as proof that an interrupted run is safe to remove.

Related facts: [[project-data-run-lifecycle]], [[project-data-migration-reconciliation]],
[[project-data-ssd-storage-locality]].
