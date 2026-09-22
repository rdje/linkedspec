---
id: targeted-session-startup
title: Session startup recovers the next task quickly and uses scoped reading before fixes
answers:
  - must the whole codebase be read before ordinary bug fixes
  - how fast should session ramp up be
  - where is the director-approved targeted startup rule
  - why is the full reading audit no longer the active prerequisite
  - which three bug reports should be fixed next
date: 2026-09-22
status: director-approved targeted startup; SEMULITH report register recovered under startup .85
tags: [startup, continuity, reading, task-tree]
evidence: "The director approved targeted reading and fast ramp-up after conformance .1.89, committed cb47fde46. SESSION-STARTUP-READING.84 implements ADR0123 without changing source, gates or prior audit coverage."
reverify: "Read SESSION_BOOTSTRAP.md, ADR0123 and MEMORY.md; resolve the current task frontier. Run scripts/check_memory_architecture.sh for pointer consistency."
---

Target2–5 minutes for context/Git/task recovery, followed by task-specific investigation.
Read affected requirements, code paths, contracts, tests and relevant book sections before
changing them. Use canonical Knowledge facts; reverify changed or contradictory evidence.
Expand for real dependencies and surface a concrete blocker if startup exceeds its target.

The exhaustive audit remains separately tracked and incomplete. ADR0123 supersedes its
blanket blocking condition in older plans, while real technical dependencies, relevant
policies, quality, verification and commit hygiene remain. No defect is closed by a
reading or workflow checkpoint. The three reports were already registered by integration
.8.1: SEMULITH/LS-001 quoted LF corruption, LS-002 atom-kind preservation, and LS-003
integration guidance. Startup .85 corrects the retrieval failure, routes the first repair to .83.2.1, which now fixes quoted LF across six runtime
routes. .83.1 now records ADR0124; .45.1 fixes compiler rejection; .45.2/.45.3 verify carriers and closeout
before the versioned grammar is delivered. LS-003 remedies remain verified. Follow
[[archogen-rust-lispish-integration]] for the exact register and evidence.

Related: [[startup-codebase-reading-inventory]], [[memory-handoff-task-status-consistency]].
