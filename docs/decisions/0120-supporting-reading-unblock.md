# ADR 0120: Apply the prepared task checker correction and close supporting reading

- Date: 2026-09-13
- Status: accepted under `SUPPORTING-SOURCE-READING.2.6`; explicit director grant
- Tags: reading, verification, task-trees, capacity, continuity

## Context and authorization

Commit `693e11e48168aba753b179b88cdb6800d4b06513` contains the complete independent
supporting-source audit and exact one-file checker correction, including 37 internal
checks and 50 registry cases. The checker retained 88,000 lines/9,437,184 bytes while
the approved registry allowed 92,000/10,485,760, leaving five task lines available.
The engineer asked to apply that correction before the remaining reading and use
focused checks instead of full CI for the correction and supporting-reading
closeout. The director replied: “Granted”.

## Decision

1. Apply precisely the prepared `scripts/check_task_tree_partitions.pl` correction
   under supporting `.2.6`, before remaining startup prerequisites, with focused
   verification instead of its normally required canonical CI run/receipt.
   Reconcile the two aggregate ceilings and check all five registry boundaries on
   every run. Preserve registry ceilings, member safeguards, source/history and
   normal doctrine hooks. Commit this correction first and verify clean handoff.
2. In a separate commit, close only supporting reading `.1` and startup `.3.7`
   using the independent audit, focused preservation proof, normal doctrines,
   memory/Knowledge/history checks and rendered-book verification. Waive the
   canonical run/receipt solely for this reading-only closeout.
3. Continue authorized PNT at startup `.3.8` after its clean commit. Existing
   registry ceilings apply to that continuation; measure each actual candidate.

## Consequences

This records the two granted exceptions, not a new blanket cadence rule or a new
capacity increase. No RGX/PGEN build is needed. Their compatible products remain
reusable. Later source, infrastructure, admission and push boundaries retain their
standing requirements. All grammar/literal repairs and remaining reading/book/
policy obligations remain open. Reading closure is separate from runtime signoff.
The earlier Lua-only waiver remains recorded in ADR0119.

## Links

- Owner: `docs/tasks/SUPPORTING-SOURCE-READING.md`, `.2.6` then `.1`
- Startup: `docs/tasks/SESSION-STARTUP-READING.md`, `.3.7` then `.3.8`
- Exact patch and proof: `docs/knowledge/task-partition-capacity-registry-drift.md`
- Independent audit: `docs/knowledge/supporting-reading-closeout-audit.md`
- Standing verification: `COMMIT.md`; `docs/decisions/0073-tiered-verification-cadence.md`
