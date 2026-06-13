# FLUENT-BLOCK-EQUIVALENCE: Broaden Fluent/Block Equivalence on Supported Surfaces

## Metadata

- Tree ID: `FLUENT-BLOCK-EQUIVALENCE`
- Status: `active`
- Roadmap lane: `Overall roadmap — method-like DSL migration track (near-term priority 2)`
- Created: `2026-06-14`
- Last updated: `2026-06-14`
- Owner: repo-local workflow

## Goal

Broaden fluent/block equivalence on supported surfaces across the LinkedSpec DSL, ensuring that what can be expressed in fluent (chain) style can also be expressed in structured (block) style and vice versa, across all supported control-flow constructs and lifecycle families.

## Non-Goals

- Adding new DSL helper functions (already landed)
- Deep cross-nesting parity expansion (formally deferred in METHOD-LIKE-DSL-MIGRATION.5)
- Changing the ActionIR lowering architecture
- Broadening beyond currently supported surfaces
- Altering the marker-style vs inline-composite design distinctions

## Acceptance Criteria

- Inventory/audit of current fluent vs block equivalence surfaces complete
- Identified gaps documented and triaged
- Any verified gaps closed with implementation
- Regression coverage broadened for equivalence points
- Live docs updated where project state changed
- Each completed leaf is committed through `COMMIT.md`

## Task Tree

- ID: `FLUENT-BLOCK-EQUIVALENCE`
  Status: `active`
  Goal: `Broaden fluent/block equivalence on supported surfaces across the DSL.`
  Children: `FLUENT-BLOCK-EQUIVALENCE.1`, `FLUENT-BLOCK-EQUIVALENCE.2`

- ID: `FLUENT-BLOCK-EQUIVALENCE.1`
  Status: `pending`
  Goal: `Inventory/audit of current fluent vs block equivalence across all supported control-flow constructs and lifecycle families. Identify gaps where fluent and block forms diverge.`
  Acceptance: `A documented inventory of all control-flow constructs (if/elseif/else, switch/case/default, marker-style, inline-composite, attached-block) with fluent and block surface coverage noted, gaps identified, and next leaves defined.`
  Verification: `pending`
  Commit: `pending`

- ID: `FLUENT-BLOCK-EQUIVALENCE.2`
  Status: `pending`
  Goal: `Close identified equivalence gaps — implementation of missing surface pairings.`
  Acceptance: `All verified gaps closed. Regression baseline stays green. New regression coverage for equivalence points added.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `FLUENT-BLOCK-EQUIVALENCE.1` | `pending` | Need an accurate surface inventory before closing any gaps. |

## Decisions

- `2026-06-14`: Created task tree from ROADMAP_V2.md near-term priority 2 ("broaden fluent/block equivalence on supported surfaces"). This is the most concrete remaining item in the near-term priorities that is not already marked "landed."

## Open Questions

- What is the exact scope of "supported surfaces" — all control-flow constructs (if/switch) across all lifecycle families (I/LS/LE/E/EX/IT/LX), or a narrower set?
- Are there known gaps already, or does this need fresh discovery?

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-14` | `FLUENT-BLOCK-EQUIVALENCE.1` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `FLUENT-BLOCK-EQUIVALENCE.1` | `pending` | `pending` |

## Changelog

- `2026-06-14`: Created task tree from ROADMAP_V2.md near-term priority 2.
