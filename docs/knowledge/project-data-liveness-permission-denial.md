---
id: project-data-liveness-permission-denial
title: Denied process inspection can misclassify live managed scratch as abandoned
answers:
  - why does project data list call a running process abandoned
  - does project data cleanup distinguish EPERM from ESRCH
  - can restricted process inspection delete live scratch
  - is managed recovery safe when kill zero returns permission denied
  - which task owns permission denied liveness repair
date: 2026-09-06
status: confirmed defect; repair pending under SESSION-STARTUP-READING.7
tags: [storage, cleanup, process, liveness, permissions, sandbox, defect]
evidence: "SESSION-STARTUP-READING.6 at source d6d3c890c2e4aa49747879b2db227f2577db0fb6 launches a managed 45-second sleep. Same-run restricted list reports abandoned and permitted list reports live. Restricted kill-zero on wrapper 91044, child 91271, and group -91271 returns zero with errno 1 / EPERM; permitted ps shows both alive at 27 seconds and all three kill-zero probes succeed. The wrapper exits 0 and final permitted list finds zero leftovers. No recover/purge/deletion probe runs."
reverify:
  - "sed -n '36,44p;120,141p;167,190p' tools/project_data_run.sh"
  - "bash tools/project_data_run.sh --list"
---

# Permission denial is not proof of process absence

The startup checkpoint exposed a real cleanup authorization defect. At the source commit above,
`pid_is_live` and `process_group_is_live` (`tools/project_data_run.sh` lines 36–44) return the Boolean status
of `kill -0` and discard its diagnostic. This collapses permission denial and confirmed absence into one false
result. `marker_has_live_owner` (120–126) combines those results; `scan_runs` (167–174) consequently reports a
live active run as abandoned. `safe_remove_owned_run` (129–141) repeats the same Boolean test before `rm -rf`.
The recheck does not repair the error distinction, so recovery/purge can authorize deletion without proof of death.

The controlled probe used `LINKEDSPEC_RUN_LABEL=startup-liveness-probe bash tools/project_data_run.sh
/bin/sleep 45` with ordinary process permissions. While that process was still sleeping, two callers ran
`bash tools/project_data_run.sh --list`: the restricted caller said abandoned, and the permitted caller said live
for the same marker, wrapper, child, and process-group identities. Paired zero-signal probes then established
EPERM versus success, and permitted `ps` independently showed both live. PID numbers are historical evidence;
always obtain new identities from a new controlled run before reverifying.

No actual premature deletion was attempted or observed. The controlled wrapper completed normally, exited 0,
and removed its own completed scratch; final permitted census reported `found=0 removed=0 skipped=0`.
Avoid `--recover` and `--purge-failed` until the repair lands. Listing is read-only with respect to run contents.

Repair owner `SESSION-STARTUP-READING.7` must preserve denied/unknown observations conservatively and only
authorize cleanup from confirmed absence. Tests must cover PID and group inspection, recovery/purge, normal
drain, and live restricted-process denial while preserving real dead-run cleanup. The startup no-source-change
prerequisite still applies; this diagnostic checkpoint records the defect rather than claiming it fixed.
The existing `tools/test_project_data_lifecycle.sh` (441 lines reviewed) exercises ordinary live/dead and
descendant cases, but has no denied-inspection case. Its previous passes do not cover this distinction.

Related: [[project-data-descendant-liveness-gap]], [[project-data-run-lifecycle]].
