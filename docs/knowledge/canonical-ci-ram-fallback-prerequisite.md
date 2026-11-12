---
id: canonical-ci-ram-fallback-prerequisite
title: Canonical CI shares the pending macOS RAM fallback prerequisite
answers:
  - "does canonical CI share the denied sysctl RAM size fallback"
  - "which task repairs the canonical heavy-suite RAM preflight before push"
date: 2026-11-12
status: source-policy prerequisite owned by TYPE-REFERENCE-BOOK.1.2.23.4.14; no infrastructure change here
tags: [ci, ram, macos, resources, publication]
evidence: "At fb613736f68f7d1f90df5ade3c0e73c98160ca3f, tools/run_ci_local.sh1323-1345 defines _ram_used_pct with the same17179869184-byte fallback after denied sysctl as tools/ram_guard.sh. Discovered during Lua80.5 publication preparation;4.14 owns both affected producers before memory-guarded canonical verification."
reverify:
  - "git show fb613736f68f7d1f90df5ade3c0e73c98160ca3f:tools/run_ci_local.sh | sed -n '1323,1347p'"
---

The existing4.14 resource-control prerequisite also applies to the heavy-suite
preflight embedded in tools/run_ci_local.sh. Its Darwin branch substitutes16GiB
when sysctl fails and obtains free/inactive/speculative pages from separate
vm_stat calls. This is a structural source observation, not a new measured
host-memory result or an actual canonical-run failure. The default danger value
there is88, while tools/ram_guard.sh and the dated RAM card have their own older
threshold behavior. Reconcile all direct producers with the director's current
trend-based policy under4.14; do not fix only the standalone wrapper.

Own the repair after the clean current feature slice, before relying on the
memory-guarded full verification/push boundary. Retain denied-query/success/
arithmetic controls and exact actual inputs then. Lua80.5 itself uses independent
memory_pressure admission with conservative serial jobs; its focused proof does
not exercise or qualify this canonical preflight. No other project's jobs may be
stopped. Native process liveness remains SESSION7-owned; the managed pgrep query
was denied (sysmond service unavailable), so no native PID/PGID census follows.

Related: [[restricted-macos-ram-host-size-fallback]], [[shared-host-ram-budget]].
