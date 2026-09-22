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
status: director-approved targeted startup; three report identities awaited under startup .85
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
reading or workflow checkpoint. Report identities must be supplied before choosing the
three requested repairs; startup .85 explicitly prevents substituting unrelated findings.

Related: [[startup-codebase-reading-inventory]], [[memory-handoff-task-status-consistency]].
