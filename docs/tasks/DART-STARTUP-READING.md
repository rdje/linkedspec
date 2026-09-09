# DART-STARTUP-READING: Bounded Dart source reading and repair ownership

## Metadata

- Tree ID: `DART-STARTUP-READING`
- Status: `pending` / admitted ownership; decomposition and source reading have not begun
- Roadmap lane: `Session required reading / SESSION-STARTUP-READING.3.4`
- Created: `2026-09-09`
- Last updated: `2026-09-09`
- Owner: repo-local workflow

## Goal

Read and understand every baseline Dart entry and every current delta through bounded, committed
leaves. Keep source coverage, comprehension, canonical facts and confirmed repair ownership durable.
The existing startup node `SESSION-STARTUP-READING.3.4` remains the Dart prerequisite and
reading-closeout owner; this separate bounded tree owns its decomposition and reading evidence.

## Non-Goals

- This admission grants no Dart source-reading credit and changes no parser/runtime behavior.
- Existing startup repairs retain their IDs and evidence; new findings reuse those owners when applicable.
- Repair implementation remains behind startup reading and policy gates; admission does not waive them.
- Generics, libraries, builders, fileless MCP debugging and the approved format/language ideas remain parked.
- Recovery/purge remains blocked by startup `.7`; no capacity increase or artifact purge is owned here.

## Acceptance Criteria

- Decomposition `.0` accounts for all baseline/current paths and creates bounded source-reading children before reading.
- Each reading child preserves exact baseline coordinates, byte identity, current deltas and comprehension evidence.
- Confirmed defects have a precise existing or new repair owner before any fix; reading completion never claims zero defects.
- Closeout `.3` proves complete byte coverage, delta accounting, child commit identity and retained findings,
  then completes startup `.3.4` and routes the next required-reading activity.
- The whole tree closes only after its repair-intake work is done, deferred with a reason, or superseded by named owners.
- Every completed leaf follows COMMIT.md with proportional proof, synchronized book/live docs, a cleared brief and clean Git state.
- Current members and aggregate stores remain within ADR 0109's finite controls; no unique evidence is discarded.

## Baseline And Admission Boundary

- Reading baseline: `baeb984e36a94a15951cd23d4c52def5064cdaca`.
- Capacity implementation: `4489f5e9a3cf60fabf6c4f69d27aedfc87cbac6b`; independent proof:
  `a7d392a8ea61ed22cab1a397aacc854cc9b1139f`.
- Admission owner: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.4`; its clean canonical commit must precede `.0`.
- Measured inventory: 115 paths / 80,296 physical lines / 2,471,305 bytes, baseline-identical at admission.
  Physical lines use LF boundaries and count a nonempty final line without LF.
- Reproducible planning: 55 groups / 169 ranges / 80,297 per-window fragments; two ranges use byte coordinates
  for an oversized physical line. Every group fits 1,500 fragments / 65,536 bytes without splitting UTF-8.
- A separate 56-group control preserves the conservative allowance; it is not a reconstruction of older grouping.
- Canonical inventory/range audit: `docs/knowledge/startup-task-chronology-compaction.md`,
  DART_CAPACITY_AUDIT. Controls/reserve audit: `docs/knowledge/dart-reading-capacity-controls.md`.
- These are inventory and planning measurements. `.0` must freeze actual child ownership and repeat the delta check.
  Zero Dart reading leaves and zero source ranges are completed at this admission.

## Task Tree

- ID: `DART-STARTUP-READING`
  Status: `pending`
  Goal: Complete bounded Dart reading and durable repair intake while preserving startup prerequisite ownership.
  Children: `.0`, `.1`, `.2`, `.3`

- ID: `DART-STARTUP-READING.0`
  Status: `pending`
  Goal: Freeze exact baseline/current membership and decompose all Dart source reading into bounded owned leaves.
  Dependencies: Clean canonical containment `.7.4` admission.
  Acceptance: Reconstruct every path/range and byte exactly once, preserve empty and oversized-line handling,
    turn `.1` into a container with scoped children, and route the first child without claiming physical reading.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1`
  Status: `pending`
  Goal: Read and understand the entire owned Dart scope through the bounded children defined by `.0`.
  Dependencies: `.0`; never execute this broad node as one reading slice.
  Acceptance: Every child accounts for its exact source bytes and deltas, reconciles Knowledge before re-derivation,
    records comprehension and confirmed findings, runs necessary focused diagnostics and commits before the next child.
  Verification: `pending`; `.0` must replace this leaf shape with an explicit reading container before reading starts.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2`
  Status: `pending`
  Goal: Reconcile and retain ownership of every confirmed Dart finding established during the reading.
  Dependencies: Findings from `.1`; implementation additionally requires startup `.3`, `.4` and `.5`.
  Acceptance: Cross-reference existing owners for known defects; create disjoint bounded repair children here
    immediately for new confirmed defects, with mechanism, source, reproduction, acceptance and unblock conditions.
    If no new repair is needed, close this intake with an explicit complete reconciliation rather than inventing work.
  Verification: `pending`; no new Dart defect or repair implementation is admitted by this placeholder.
  Commit: `pending`

- ID: `DART-STARTUP-READING.3`
  Status: `pending`
  Goal: Close Dart reading with exact coverage, current-delta, comprehension and child-commit proof.
  Dependencies: `.0` and every `.1` child complete; all findings durably owned under `.2` or existing trees.
  Acceptance: Independently prove complete baseline/current coverage and all child commits; preserve every
    pending repair, complete only startup `.3.4` reading, and route startup Julia `.3.5`.
    Pending repairs keep this tree open; reading closeout is not defect remediation.
  Verification: `pending`; canonical milestone proof is required before reading-parent closeout.
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `DART-STARTUP-READING.0` | `pending` | Exact ownership precedes source reading, after the clean canonical admission commit. |

## Decisions

- `2026-09-09`: ADRs 0108/0109 authorize separate bounded Dart ownership without moving startup evidence or increasing member limits.
- Keep startup `.3.4` as the existing reading prerequisite/closeout owner; this tree provides directly navigable execution evidence.
- Reading findings are tracked immediately, but repair implementation respects the remaining startup gates.

## Open Questions

- None blocks decomposition. Unknown source findings are recorded and task-owned when established.

## Blockers

- `.0` starts only after the containment `.7.4` canonical commit, empty brief and clean-tree proof.
- Repair implementation remains gated by required reading and policy adoption; this does not block reading.

## Verification Log

- Admission verifies inventory and bounded ownership only. Canonical outcome and exact receipt belong to the
  containment `.7.4` commit; no Dart reading verification is claimed here.

## Commit Log

- Created by `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.4 - admit bounded Dart reading ownership`.
- No `DART-STARTUP-READING` leaf has completed at this boundary.

## Changelog

- `2026-09-09`: Admit pending ownership, exact baseline pointers and the startup bridge; decomposition is next.
