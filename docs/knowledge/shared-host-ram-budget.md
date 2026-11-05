---
id: shared-host-ram-budget
title: Shared host memory uses director86/90 percent thresholds
answers:
  - "how much RAM is available on the shared macOS host"
  - "are the86 and90 percent memory limits per process or host wide"
  - "when must an agent request a quiet time window"
  - "may an agent stop another project's jobs for RAM"
  - "does tools ram_guard monitor memory during a running job"
  - "why should RAM guard admission use danger pct86"
date: 2026-11-05
status: director operating constraint; existing preflight wrapper unchanged
tags: [host, memory, ram, resources, locality, operations]
evidence: "Director session-startup paragraph23; current verification under TYPE-REFERENCE-BOOK.1.2.23.3.73.6.3. tools/ram_guard.sh supplies configurable admission and a virtual-memory ceiling, not continuous host monitoring."
reverify: "bash tools/ram_guard.sh --danger-pct 86 --ceiling-mb 512 -- true"
---

The director identifies this macOS host as24GB shared across projects and agents.
Thresholds apply to total host usage. Before intensive work, check headroom for
the expected peak, use conservative workers/batches and run at most one intensive
job of our own. Monitor during execution frequently enough to catch growth.

At86%, defer new intensive work and promptly reduce our running job's usage.
At90%, act immediately: stop our driving jobs if reduction cannot quickly restore
usage below86%. Intervene only in jobs we started. If other projects keep usage
at or above86%, defer our intensive work and report the specific blocker.
Restart only with stable sufficient headroom and reduced concurrency/batches;
aim for80% or less after a memory-triggered stop.

If headroom is insufficient, or background activity could skew a benchmark,
request a quiet window. State the command/purpose, proposed start/duration and
required free memory or background-activity limit. Wait for explicit confirmation,
verify the host before starting, and notify the director when the window ends.

Use the explicit86% admission option with the existing wrapper; its default88%
does not replace this director constraint. The wrapper checks before a command
and attempts a virtual-memory ceiling. It does not perform live host monitoring;
the agent remains responsible for that monitoring and timely intervention. Keep
all project-owned monitoring logs and scratch on the repository volume.
