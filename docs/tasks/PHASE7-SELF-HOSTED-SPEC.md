# PHASE7-SELF-HOSTED-SPEC: Phase 7 Self-Hosted `.spec` Grammar

## Metadata

- Tree ID: `PHASE7-SELF-HOSTED-SPEC`
- Status: `active`
- Roadmap lane: `Phase 7`
- Created: `2026-05-16`
- Last updated: `2026-05-17`
- Owner: repo-local workflow

## Goal

Define and maintain `spec.spec` — a first-class LinkedSpec grammar that captures the currently supported `.spec` syntax and semantics, making it the preferred extension surface for future `.spec` format evolution.

## Non-Goals

- Modifying LinkedSpec core for `.spec` language changes (exception-only, explicitly justified).
- Replacing the bootstrap grammar as the compiler's internal parse mechanism.

## Acceptance Criteria

- `spec.spec` represents the current supported `.spec` language envelope with regression coverage.
- Roadmap-level `.spec` feature changes land through `spec.spec` first.
- Touching LinkedSpec core for `.spec` language evolution is exception-only and explicitly justified.
- Phase 7 exit criteria met per `ROADMAP.md`.

## Task Tree

- ID: `PHASE7-SELF-HOSTED-SPEC`
  Status: `active`
  Goal: `Define and maintain a self-hosted .spec grammar.`
  Children: `PHASE7-SELF-HOSTED-SPEC.1`

- ID: `PHASE7-SELF-HOSTED-SPEC.1`
  Status: `pending`
  Goal: `Survey the current .spec language surface: inventory every supported syntax element, rule form, action form, block form, and lifecycle marker that must be representable in spec.spec.`
  Acceptance: `Task file lists all .spec language elements with their current implementation status and names the first grammar-authoring leaf.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PHASE7-SELF-HOSTED-SPEC.1` | `pending` | Need a language-surface survey before grammar authoring. |

## Decisions

- `2026-05-16`: Created proposed task tree. Phase 7 is `not started` per `ROADMAP_V2.md`.

## Open Questions

- What is the minimal viable `spec.spec` first slice? (Answer pending survey.)

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| — | — | — | — |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| — | — | — | — |

## Changelog

- `2026-05-16`: Created proposed task tree from template.
