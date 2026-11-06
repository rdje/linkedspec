---
id: restricted-macos-ram-host-size-fallback
title: Denied macOS host-size queries expose a wrong RAM-guard fallback
answers:
  - "why can ram_guard use16GiB on the director24GiB host"
  - "which task owns denied sysctl memory-size fallback repair"
  - "what RAM instruction supersedes the older86 percent card"
  - "does the Rust Cargo wrapper invoke the legacy RAM guard"
date: 2026-11-06
status: source defect owned P1 by TYPE-REFERENCE-BOOK.1.2.23.4.14; product work uses independent monitoring
tags: [host, memory, ram, macos, permissions, resources]
evidence: "Rust75.6.2 preflight: default-shell sysctl -n hw.memsize denied; memory_pressure -Q confirms the director24GiB host. At fb0cb2ce89004f93d2ae4153e28684422984c760, tools/ram_guard.sh falls back to17179869184 bytes if sysctl fails. Task4.14 owns retained reproduction/repair before memory-guarded full verification."
reverify:
  - "git show fb0cb2ce89004f93d2ae4153e28684422984c760:tools/ram_guard.sh"
  - "memory_pressure -Q"
---

The macOS _used_pct path reads host capacity with sysctl and substitutes16GiB
on failure. Restricted-shell access was denied while a separate OS query matched
the director's24GiB host. With the same available-page count, using16 rather than
24GiB underestimates used percentage. Three separate vm_stat calls also do not
form one atomic snapshot. These are source/producer findings, not a new published
RAM-usage measurement;4.14 must retain actual reproduction inputs/channels and
falsification controls before publishing such measurements or landing its repair.

Current product builds use one vm_stat snapshot with independently verified host
capacity, conservative workers and live observation. tools/run_cargo_local.sh
does not invoke ram_guard. Initial diagnostic channels were not captured as a
separate resource proof epoch; that missing custody leg is explicitly4.14-owned.
No actual pressure blocker or permission to stop another project's jobs follows.

The director's later November6 instruction supersedes the older86/90 hard limits
in [[shared-host-ram-budget]]: stable high80s are permitted; observe the trend and
intervene in our jobs if usage is above90% and still increasing. MEMORY carries
this latest instruction.4.14 owns canonical-card reconciliation with the source
repair before memory-guarded full verification; do not treat the older card's
86% admission advice as current director authorization.
