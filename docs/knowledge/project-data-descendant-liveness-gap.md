---
id: project-data-descendant-liveness-gap
title: Managed-run process groups close descendant-liveness deletion gap
answers:
  - can a managed run delete scratch while a grandchild is still live
  - does project data recovery track process descendants
  - what descendant lifecycle gap did PROJECT DATA SSD ROOTING 3.1 find
  - why did guarded project data recovery race a compiler descendant
  - which task owns managed run descendant liveness
  - does child pid liveness prove the whole process tree is dead
  - does project data signal forwarding reach grandchildren
date: 2026-07-26
status: current
tags: [architecture, storage, scratch, lifecycle, recovery, process, concurrency, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.3.1.1 observed the RED: wrapper/direct-child death did not prove descendant death, and a deterministic descendant_live=yes/run_present=no probe showed normal cleanup deleting scratch under a live background descendant. PROJECT-DATA-SSD-ROOTING.3.1.2 closes it with marker version 2 and a dedicated child-led process group. The wrapper waits for group drain, forwards HUP/INT/TERM to the complete group, and recovery/purge recheck group liveness immediately before exact deletion. Live/reused groups are retained conservatively; legacy, mismatched, malformed, and interrupted starting markers cannot authorize deletion. The lifecycle oracle proves background wait, group signals, abrupt wrapper/direct-child loss, live orphan-group retention, post-drain recovery, and marker rejection."
reverify: "bash -n tools/project_data_run.sh tools/test_project_data_lifecycle.sh && bash tools/test_project_data_lifecycle.sh && rg -n 'process_group_id|process_group_is_live|child_group_active|indeterminate' tools/project_data_run.sh"
---

Marker version 1 proved only wrapper and direct foreground-child liveness. That was insufficient after abrupt
interruption because a compiler, test worker, or other descendant can outlive both recorded PIDs. Normal cleanup
has the same boundary: a direct child can launch a background descendant whose current directory remains inside
managed scratch, return success, and cause the wrapper to delete the run while that descendant is still alive.

The observed `rm -rf` race happened to fail safely while a compiler created files, but filesystem timing is not a
safety mechanism. The deterministic RED removes that ambiguity: after the direct child launched a 60-second
descendant with cwd in the run's `tmp/` directory and exited, the wrapper removed the run and returned while
`kill -0` still reported the descendant live. Signal forwarding likewise addresses only the recorded child PID.

`PROJECT-DATA-SSD-ROOTING.3.1.2` replaces that authority with marker version 2. The foreground child is the leader
of a dedicated process group inherited by descendants; the wrapper waits for group drain, forwards HUP/INT/TERM to
the group, and records the exact group id. Recovery and retained-failure purge re-read the marker and repeat
wrapper/child/group liveness immediately before exact deletion. A live or reused group is retained conservatively.
Legacy/malformed/mismatched markers are invalid, and a `starting` marker interrupted before group identity is
published is indeterminate and retained by both automated cleanup modes.

The mutation-sensitive green proof exercises the original normal-return case and the harder orphan case. After
the test kills both wrapper and direct child, a descendant remains live in the recorded group and `--recover`
retains its run. Only after the descendant exits and the group disappears does recovery remove the exact run.
Separate traps prove TERM reaches both direct child and descendant before scratch is removed.

Related facts: [[project-data-run-lifecycle]], [[project-data-migration-reconciliation]],
[[project-data-ssd-storage-locality]].

September 6 startup evidence in [[project-data-liveness-permission-denial]] qualifies these original
lifecycle guarantees: denied liveness inspection is not absence, and a later group-setup warning needs
establishment evidence. `SESSION-STARTUP-READING.7` owns the repair and verification before recovery/purge.
