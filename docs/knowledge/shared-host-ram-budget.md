---
id: shared-host-ram-budget
title: Shared host RAM uses snapshot admission and director trend monitoring
answers:
  - "how much RAM is available on the shared macOS host"
  - "are the86 and90 percent memory limits per process or host wide"
  - "when must an agent request a quiet time window"
  - "may an agent stop another project's jobs for RAM"
  - "does tools ram_guard monitor memory during a running job"
  - "why should RAM guard admission use danger pct86"
  - "how do RAM guard and canonical CI acquire host capacity"
date: 2026-11-12
status: current director trend policy; resource14 focused repair with canonical admission required
tags: [host, memory, ram, resources, locality, operations]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.14; retained original/native/source-bound controls and historical recovery in docs/checkpoints/ram-host-size-preflight-2026-11-12/. The prior November5 hard86/90 card is retained at b370de8d3 and in the before-edit proof capsules."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/ram-host-size-preflight-2026-11-12/review.py"
  - "bash tools/run_python_project_data.sh tools/test_ram_guard.py"
---

The director identifies this macOS host as24GB shared across projects and agents.
Thresholds concern total host usage. Before intensive work, check enough headroom
for the expected peak, use conservative workers/batches and run at most one
intensive job of our own. Observe the trend while it runs. If usage exceeds90%
and keeps increasing, tell the director and reduce or stop our driving jobs.
Otherwise, stable high80s alone do not require intervention. After a pressure
stop, resume only with stable sufficient headroom, aiming for80% or less and
using lower concurrency or smaller batches. Never stop another project's jobs.
If other projects keep usage above90%, defer our intensive work and report why.

Request a quiet window when the job needs unavailable headroom or background
activity could skew a measurement. State purpose, proposed start/duration and
required free memory or background limit; wait for confirmation, verify readiness
and announce when the window is no longer needed. Adequate headroom does not
require an unsolicited quiet-window pause.

tools/host_ram_usage.sh supplies the shared snapshot producer. On Darwin it uses
positive sysctl capacity, falling back to actual memory_pressure -Q capacity when
the first query fails or is invalid. It parses page size and free/inactive/
speculative pages from one vm_stat response. On Linux it uses one /proc/meminfo
response. Missing/invalid capacity or snapshots fail clearly. The upward-rounded
used estimate is100 minus the available-byte percentage rounded down; it is not
memory_pressure's free indicator, a peak bound or continuous trend monitoring.

tools/ram_guard.sh and canonical CI use that same producer. Their configurable88%
default is conservative job admission, not the superseded director86% global
rule. The wrapper refuses unknown usage or a reached threshold with77, preserves
the admitted child's exit code and attempts a virtual-memory ceiling; it does not
guarantee an RSS ceiling or monitor the child. The agent remains responsible for
current headroom and live host trends. Keep project logs and scratch in managed
repository storage. Historical November5 measurements and evidence stay unchanged.
