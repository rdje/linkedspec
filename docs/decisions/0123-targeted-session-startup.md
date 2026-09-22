# ADR 0123: Targeted session startup with fast context recovery

- Date: 2026-09-22
- Status: accepted by the director; implemented under SESSION-STARTUP-READING.84
- Tags: continuity, startup, reading, verification

## Context

The original session paragraph0 made full roadmap/codebase/mdBook reading a global
prerequisite. Its exhaustive audit displaced bug implementation. The director explicitly
approved targeted reading and requested a fast ramp-up. The prior reading checkpoint
is committed at cb47fde46: conformance89/143,109904 fragments,4784266 baseline bytes,
133 complete files. Those measurements remain evidence, not completed global reading.

## Decision

Recover context, Git state and the active leaf from the repository bootstrap, memory
pointer and canonical records. Target2–5 minutes for this startup step. Task-specific
investigation and verification take the time needed for signoff quality. A longer
startup requires a concrete blocker to be surfaced, not an expanding general audit.

Before changing a slice, read and understand its roadmap requirements, affected code
paths, interfaces/contracts, tests and relevant book sections. Retrieve established
facts through the Knowledge Map; reverify changes or conflicting observations. Follow
dependencies outward when needed. Confirm this scoped understanding, task ownership
and Git state. Never claim unread material as read or treat a passing test as reading.

Full-repository reading and historical audits remain separate, deferred task-tree work.
They do not block ordinary fixes unless specifically required for the selected task.
This decision supersedes only the blanket required-source/book/policy-reading condition
in older plans and task prerequisites. Relevant policies must still be read and obeyed;
genuine technical dependencies, unresolved defect causes, quality requirements and
explicit task-specific prerequisites remain. No repair is closed by this decision.

The current priority is the director's three bug reports. Their identities are missing
from the current resume context; .85 owns identification and routing to existing repair
owners. Do not guess that three audit findings or an unrelated upstream report are them.

## Consequences

SESSION_BOOTSTRAP.md is the current startup procedure. Existing memory, task ownership,
Knowledge retrieval, Git hygiene, focused/canonical verification tiers, same-volume
storage and read-only dependency boundaries continue unchanged. No timer, new doctrine,
checker or verification exemption is introduced. Preserve all prior reading scopes,
completed nodes, immutable history and source identities for eventual separate audit.

## Links

- `SESSION_BOOTSTRAP.md`
- `docs/tasks/SESSION-STARTUP-READING.md` (.84 adoption; .85 report identification)
- `docs/tasks/CONFORMANCE-SOURCE-READING.md` (separate audit, next unread .1.90)
- `MEMORY_ARCHITECTURE.md`
- `docs/decisions/0073-tiered-verification-cadence.md`
