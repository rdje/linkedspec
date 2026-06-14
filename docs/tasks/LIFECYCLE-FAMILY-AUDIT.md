# LIFECYCLE-FAMILY-AUDIT: Lifecycle-Family Structured Authoring Audit

## Metadata

- Tree ID: `LIFECYCLE-FAMILY-AUDIT`
- Status: `active`
- Roadmap lane: `Overall roadmap — near-term priority 1: lifecycle-family follow-through`
- Created: `2026-06-14`
- Last updated: `2026-06-14`
- Owner: repo-local workflow

## Goal

Verify that semicolon-light structured authoring (helper-only regression coverage and marker-style
control-flow coverage) spans all 7 lifecycle markers (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`)
consistently. Identify any remaining narrower lifecycle-specific semantic gaps and document
exceptions. Per ROADMAP_V2.md: "keep extending any remaining narrower lifecycle-specific
semantics only when a real gap or exception is found."

## Non-Goals

- No new DSL feature implementation unless a concrete gap is found.
- No changes to lifecycle semantics or lowering behavior.
- No plugin migration work.

## Acceptance Criteria

- All 7 lifecycle markers audited for helper-only regression coverage.
- All 7 lifecycle markers audited for marker-style semicolon-light control-flow coverage.
- Any gaps identified and either fixed (if real) or documented as exceptions.
- mdBook and live docs updated with lifecycle coverage status.
- Local CI gate passes.
- Each completed leaf committed through `COMMIT.md`.

## Task Tree

- ID: `LIFECYCLE-FAMILY-AUDIT`
  Status: `active`
  Goal: `Audit lifecycle-family structured authoring parity, fix real gaps, document exceptions.`
  Children: `LIFECYCLE-FAMILY-AUDIT.1`, `LIFECYCLE-FAMILY-AUDIT.2`, `LIFECYCLE-FAMILY-AUDIT.3`, `LIFECYCLE-FAMILY-AUDIT.4`

- ID: `LIFECYCLE-FAMILY-AUDIT.1`
  Status: `done`
  Goal: `Inventory: audit regression suite for lifecycle coverage.`
  Acceptance: `A documented inventory of lifecycle coverage in the regression suite, with per-lifecycle counts of helper-only and control-flow test blocks.`
  Verification: `Full inventory complete. All 7 markers covered: I (71 literal blocks + interpolation), LS/LE/E/EX/IT (interpolation only, via 47 full_lifecycle + 12 remaining_lifecycle subtests), LX (89 literal blocks + interpolation, primary marker for 73+ fluent_and_structured helper-family subtests). Control-flow coverage spans all 7 via data-driven subtests. Semicolon-light coverage spans all 7. No single-marker lifecycle-specific behavior tests exist — all markers treated as interchangeable.`
  Commit: `pending`

- ID: `LIFECYCLE-FAMILY-AUDIT.2`
  Status: `done`
  Goal: `Gap analysis: compare inventory against ROADMAP_V2.md claim.`
  Acceptance: `Gap report documenting any missing coverage.`
  Verification: `No real gaps found. ROADMAP_V2.md claim validated: generic helper-only regression coverage and marker-style control-flow coverage now span all 7 lifecycles. 3 intentional design patterns noted: (1) LX is primary helper-family proof point (73+ subtests), assuming parity holds for other markers; (2) I and LX carry deeper standalone literal-block coverage, remaining 5 via interpolation; (3) no lifecycle-specific semantic behavior tests — all markers treated as equivalent. These are design trade-offs, not gaps. Zero implementation work needed.`
  Commit: `pending`

- ID: `LIFECYCLE-FAMILY-AUDIT.3`
  Status: `in_progress`
  Goal: `Document: update mdBook and live docs with lifecycle-family coverage status.`
  Acceptance: `mdBook and live docs reflect current lifecycle coverage status. ROADMAP_V2.md near-term priority #1 updated if status changed.`
  Verification: `pending`
  Commit: `pending`

- ID: `LIFECYCLE-FAMILY-AUDIT.4`
  Status: `pending`
  Goal: `Finalization: run full CI gate, verify all docs consistent, close out the tree.`
  Acceptance: `Local CI gate passes. Tree moved to Completed in TASK_TREE.md. MEMORY.md updated.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `LIFECYCLE-FAMILY-AUDIT.1` | `pending` | Must inventory lifecycle coverage before analyzing gaps. |

## Decisions

- `2026-06-14`: This tree is audit-first. If no real gaps are found (most likely outcome per ROADMAP_V2.md claim that coverage "now spans" all lifecycles), the tree's primary value is verification + documentation rather than implementation.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-14` | `LIFECYCLE-FAMILY-AUDIT.1` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `LIFECYCLE-FAMILY-AUDIT.1` | `pending` | `pending` |

## Changelog

- `2026-06-14`: Created task tree. ROADMAP_V2.md near-term priority #1: lifecycle-family follow-through for semicolon-light structured authoring.
