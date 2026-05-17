# BOOK-DOCUMENTATION-SYNC: Book/USER_GUIDE Sync

## Metadata

- Tree ID: `BOOK-DOCUMENTATION-SYNC`
- Status: `done`
- Roadmap lane: `Documentation`
- Created: `2026-05-17`
- Last updated: `2026-05-17`
- Active frontier: `none` (tree complete)
- Owner: repo-local workflow

## Goal

Sync the mdBook chapters with current codebase state and USER_GUIDE content. The survey found stale status notes about plugin deprecation (completed PLUGIN-MODERNIZATION tree, 2026-05-17) and the pplugin walkthrough's ready_ratio note. Update book to reflect: plugin methods are DEPRECATED (not "may be in a future phase"), METHOD-LIKE-DSL-MIGRATION is done, all 19 shipped specs are at zero compat.

## Non-Goals

- Rewriting book chapters for style or structure.
- Adding new chapters.
- Auditing USER_GUIDE files (10 files, 14,611 lines — already well-maintained, no stale references found).

## Acceptance Criteria

- `plugin-registry.md` status note updated: "may be narrowed or deprecated in a future phase" → reflect actual DEPRECATED status.
- `owner-tree.md` legacy plugin branch section notes DEPRECATED status of all 7 facade methods.
- `pplugin-spec-walkthrough.md` ready_ratio note verified or updated.
- Full regression gate passes (book is documentation-only, no code changes expected).

## Task Tree

- ID: `BOOK-DOCUMENTATION-SYNC`
  Status: `active`
  Goal: `Sync mdBook chapters with current codebase state — update stale plugin deprecation notes, verify ready_ratio references.`
  Children: `BOOK-DOCUMENTATION-SYNC.1`, `BOOK-DOCUMENTATION-SYNC.2`, `BOOK-DOCUMENTATION-SYNC.3`

- ID: `BOOK-DOCUMENTATION-SYNC.1`
  Status: `done`
  Goal: `Update plugin-registry.md legacy transition surface status note — reflect actual DEPRECATED status from PLUGIN-MODERNIZATION tree (completed 2026-05-17).`
  Acceptance: `Line 54 status note no longer says "may be narrowed or deprecated in a future phase." States methods are DEPRECATED with timeline and retirement criteria.`
  Verification: `2026-05-17: Updated. Status note now reads all 7 methods are DEPRECATED, references PLUGIN-MODERNIZATION tree, lists retirement path (migrate .plg actions, retire PPlugin, reduce/delete PluginBridge, remove deprecated methods, migrate FSMGen::AUTOLOAD).`
  Commit: `pending`

- ID: `BOOK-DOCUMENTATION-SYNC.2`
  Status: `done`
  Goal: `Update owner-tree.md legacy plugin branch section — note DEPRECATED status of all 7 facade methods with PLUGIN-MODERNIZATION tree reference.`
  Acceptance: `Lines 398-410 updated to reflect actual DEPRECATED status. PLUGIN-MODERNIZATION tree referenced as source of deprecation.`
  Verification: `2026-05-17: Updated. All 7 methods now annotated "DEPRECATED" individually. Section now includes retirement path summary and PLUGIN-MODERNIZATION reference.`
  Commit: `pending`

- ID: `BOOK-DOCUMENTATION-SYNC.3`
  Status: `done`
  Goal: `Verify pplugin-spec-walkthrough.md ready_ratio note and survey remaining book chapters for other stale references.`
  Acceptance: `pplugin-spec-walkthrough.md line 69 either confirmed accurate or updated. Quick scan of remaining 30+ chapters finds no additional stale references to pre-METHOD-LIKE-DSL-MIGRATION state.`
  Verification: `2026-05-17: Verified. pplugin-spec-walkthrough.md ready_ratio "below 1.0000" is accurate — pplugin.spec still uses eval in subdef[1]. All other ready_ratio references confirmed correct (portmap/tablegrep/ebnf/lispish at 1.0000). All legacy return-helper references properly documented with canonical alternatives. All compatibility alias references correctly marked as "compatibility alias for." Full 33-chapter sweep: no stale forward-looking language found. USER_GUIDE files (10 files) clean. No additional changes needed.`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `BOOK-DOCUMENTATION-SYNC.1` | `done` | plugin-registry.md status note updated — all 7 methods DEPRECATED. |
| 2 | `BOOK-DOCUMENTATION-SYNC.2` | `done` | owner-tree.md legacy plugin branch updated — all 7 methods DEPRECATED. |
| 3 | `BOOK-DOCUMENTATION-SYNC.3` | `done` | pplugin walkthrough verified accurate. Full book/USER_GUIDE sweep clean. |

## Background

Survey findings (2026-05-17):

1. **`plugin-registry.md` line 54**: "The legacy transition surface may be narrowed or deprecated in a future phase." — Stale. PLUGIN-MODERNIZATION tree completed 2026-05-17 deprecated all 7 plugin facade methods.

2. **`owner-tree.md` lines 398-410**: Lists all 7 deprecated facade methods but doesn't mention DEPRECATED status. Needs update.

3. **`value-container-flow-helper-reference.md`**: Already properly documents legacy helpers with canonical alternatives. No changes needed.

4. **USER_GUIDE files** (10 files, 14,611 lines): Already well-maintained. Document plugin bridge, deprecated status, migration path. No stale references found.

5. **Book chapters** (33 total): Surveyed for `may be narrowed`, `future phase`, `register_plugin`, `run_plugin`, `get_plugin` — only `plugin-registry.md` had stale language.

## Decisions

- `2026-05-17`: Created task tree. Book sync was requested by user after METHOD-LIKE-DSL-MIGRATION completion. Survey found 2 stale files (plugin-registry.md, owner-tree.md) and 1 to verify (pplugin-spec-walkthrough.md).

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-05-17` | `BOOK-DOCUMENTATION-SYNC.3` | Verified pplugin-spec-walkthrough.md ready_ratio note accurate. Full 33-chapter book sweep: no stale forward-looking language. All legacy helper refs correctly documented. All compat alias refs correctly marked. USER_GUIDE files (10) clean. | Pass — sweep complete. |
| `2026-05-17` | `BOOK-DOCUMENTATION-SYNC.2` | Updated owner-tree.md legacy plugin branch: all 7 methods annotated DEPRECATED individually, retirement path added, PLUGIN-MODERNIZATION referenced. | Pass — updated. |
| `2026-05-17` | `BOOK-DOCUMENTATION-SYNC.1` | Updated plugin-registry.md status note: "may be narrowed or deprecated in a future phase" → DEPRECATED with retirement path and PLUGIN-MODERNIZATION reference. | Pass — updated. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `BOOK-DOCUMENTATION-SYNC.1` | `ff732d3` | plugin-registry.md status note updated. |
| `BOOK-DOCUMENTATION-SYNC.2` | `ff732d3` | owner-tree.md legacy plugin branch updated. |
| `BOOK-DOCUMENTATION-SYNC.3` | `ff732d3` | pplugin walkthrough verified, full book/USER_GUIDE sweep clean. |

## Changelog

- `2026-05-17`: Completed BOOK-DOCUMENTATION-SYNC.3 — verified pplugin walkthrough and full book/USER_GUIDE sweep. Tree COMPLETE (3/3 leaves).
- `2026-05-17`: Completed BOOK-DOCUMENTATION-SYNC.2 — updated owner-tree.md legacy plugin branch with DEPRECATED annotations.
- `2026-05-17`: Completed BOOK-DOCUMENTATION-SYNC.1 — updated plugin-registry.md status note from "may be deprecated in a future phase" to actual DEPRECATED status.
- `2026-05-17`: Created task tree for book/USER_GUIDE sync.
