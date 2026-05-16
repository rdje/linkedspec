# PLUGIN-MODERNIZATION: Plugin/Resource-Resolution Modernization

## Metadata

- Tree ID: `PLUGIN-MODERNIZATION`
- Status: `active`
- Roadmap lane: `Plugin/resource-resolution modernization track`
- Created: `2026-05-16`
- Last updated: `2026-05-16`
- Owner: repo-local workflow

## Goal

Complete plugin/resource-resolution modernization: retire dynamic `.plg`/`PPlugin` execution support, keep deterministic `get_parser('name')`-style spec lookup intact, and ensure all extracted helper owners live under clear non-plugin domain owners.

## Non-Goals

- Breaking existing spec resolution (`get_parser('name')` must keep working).
- Removing helper functionality (only moving it to proper package owners).

## Acceptance Criteria

- Dynamic `.plg` execution and `PPlugin` support are fully retired.
- All extracted helpers live under clear domain owners (`HTTP::FileAccess`, `RTLUtils`, `FSMGen`, `Timing::*`, `Table::GenericFilter`, `QC::*`, etc.).
- `run_plugin(...)`, `get_plugin(...)`, and registry machinery are removed or reduced to transitional stubs.
- Spec resolution via `get_parser('name')` remains deterministic and intact.

## Task Tree

- ID: `PLUGIN-MODERNIZATION`
  Status: `active`
  Goal: `Retire dynamic plugin execution, preserve spec resolution.`
  Children: `PLUGIN-MODERNIZATION.1`

- ID: `PLUGIN-MODERNIZATION.1`
  Status: `pending`
  Goal: `Inventory current plugin surface: list every remaining .plg reference, PPlugin dependency, and dynamic-plugin code path. Map each to its replacement domain owner or retirement plan.`
  Acceptance: `Task file lists each plugin artifact, its current status, its replacement owner (if applicable), and names the next executable retirement leaf.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PLUGIN-MODERNIZATION.1` | `pending` | Need a plugin-surface inventory before targeted removal. |

## Decisions

- `2026-05-16`: Created task tree. Extensive plugin-to-owner extraction already landed per `ROADMAP_V2.md` (HTTP::FileAccess, RTLUtils, FSMGen, Timing::*, Table::GenericFilter, QC::*, etc.).

## Open Questions

- Are there remaining internal `.plg` files that still need extraction? (Answer pending inventory.)

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

- `2026-05-16`: Created task tree from template.
