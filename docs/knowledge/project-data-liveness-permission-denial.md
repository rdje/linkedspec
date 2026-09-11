---
id: project-data-liveness-permission-denial
title: Denied process inspection can misclassify live managed scratch as abandoned
answers:
  - why does project data list call a running process abandoned
  - does project data cleanup distinguish EPERM from ESRCH
  - can restricted process inspection delete live scratch
  - is managed recovery safe when kill zero returns permission denied
  - which task owns permission denied liveness repair
  - why did managed generation report child setpgid operation not permitted
  - does the run wrapper verify child process group establishment
date: 2026-09-07
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

## Process-group setup warning — September 6 follow-up

During `SESSION-STARTUP-READING.3.2.27`, managed Knowledge-map generation emitted
`child setpgid (22263 to 22263): Operation not permitted`, then completed with exit 0 and the expected
968 facts / 8,102 keys. This historical count describes that generation only. The original child's PGID
was not captured, so this warning does not prove a mismatched group or unsafe cleanup.

`tools/project_data_run.sh:308` enables monitor mode, launches the command in the background, and
310–314 record `$!` as both child PID and process-group ID with no independent establishment check.
A subsequent current-process control reports matching PID/PGID 27725 and exits 0:

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -MJSON::PP -e 'print JSON::PP->new->canonical->encode({pid=>$$,pgid=>getpgrp(0),group_matches_pid=>getpgrp(0)==$$?1:0}),qq{\n}'
```

`SESSION-STARTUP-READING.7` now includes group-establishment verification and controlled failure coverage.
The denied child-side setup attempt is observed; its kernel/parent-child timing cause and the original final
group identity remain unestablished. Do not infer either a failed group or complete lifecycle correctness from
the successful command. The repair must distinguish a benign setup race from absent group establishment.

September 7 `SESSION-STARTUP-READING.3.3.26` observed the same child-side setup warning
for PID 76199 during a managed documentation correction. The command exited zero and the
intended edit was independently verified before staging. The actual resulting PGID was not
captured, so this recurrence adds no new causal conclusion; existing `.7` ownership and the
recovery/purge restriction remain unchanged. `.3.3.27` preserves this bounded observation.

September 11 `JULIA-STARTUP-READING.1.43` repeated the warning for child18745
during the managed mdBook build. The build exited0 and rendered output was
checked. The original final PGID was not captured; no group-failure or successful
establishment claim follows. The documented follow-up control reports PID/PGID
34421 with group_matches_pid1; read-only listing reports found0/removed0/skipped0.
The unchanged wrapper still records child_pid as group identity without a check.
Startup .7 already owns establishment/failure coverage and remains pending; no
recovery/purge or deletion probe ran. This adds a recurrence, not a new cause.
