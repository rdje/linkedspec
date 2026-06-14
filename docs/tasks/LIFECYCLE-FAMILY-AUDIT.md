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
  Status: `pending`
  Goal: `Inventory: audit regression suite for lifecycle coverage. Check which lifecycles appear in phase0_regression.t, which helper families are tested per lifecycle, and whether all 7 markers have structured-authoring regression locks.`
  Acceptance: `A documented inventory of lifecycle coverage in the regression suite, with per-lifecycle counts of helper-only and control-flow test blocks.`
  Verification: `pending`
  Commit: `pending`

- ID: `LIFECYCLE-FAMILY-AUDIT.2`
  Status: `pending`
  Goal: `Gap analysis: compare the inventory against the ROADMAP_V2.md claim that generic helper-only regression coverage and marker-style control-flow coverage now span all 7 lifecycles. Identify any lifecycles with missing coverage families or narrower semantics not yet verified.`
  Acceptance: `A gap report documenting any missing coverage, with each gap classified as either (a) real — needs implementation, or (b) exception — semantically not applicable for that lifecycle.`
  Verification: `pending`
  Commit: `pending`

- ID: `LIFECYCLE-FAMILY-AUDIT.3`
  Status: `pending`
  Goal: `Document: update mdBook (project-status.md, relevant DSL chapters) and live docs with lifecycle-family coverage status. If gaps were found and fixed, document the fixes. If exceptions were found, document the rationale.`
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
