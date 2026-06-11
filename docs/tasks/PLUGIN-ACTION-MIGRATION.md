# PLUGIN-ACTION-MIGRATION: Migrate remaining .plg actions to package owners

## Metadata

- Tree ID: `PLUGIN-ACTION-MIGRATION`
- Status: `proposed`
- Roadmap lane: `Plugin modernization follow-on`
- Created: `2026-06-11`
- Last updated: `2026-06-11`
- Owner: repo-local workflow

## Goal

Migrate the remaining ~1,200+ actions across 36 `.plg` files (5,132 total lines) to explicit package owners, following the pattern established in PLUGIN-MODERNIZATION: extract helper bodies into domain-appropriate package owners, retire legacy plugin registrations, and delete `.plg` wrappers once no repo-owned caller needs the old plugin name. The end state is that all repo-owned plugin behavior lives in named package owners, and the legacy `.plg`/plugin-bridge infrastructure can be evaluated for retirement.

## Non-Goals

- Does NOT retire `PPlugin.pm` or `PluginBridge.pm` — that is a separate follow-on tree after all actions are migrated.
- Does NOT remove the deprecated facade methods (`run_plugin`, `get_plugin`, etc.) — that follows plugin-infrastructure retirement.
- Does NOT migrate `FSMGen::AUTOLOAD` — that is a separate concern tracked in PLUGIN-MODERNIZATION.5.
- Does NOT change parser/spec/compiler behavior — this is a plugin-corpus migration, not a core change.

## Acceptance Criteria

- All 36 `.plg` files are audited: every action, helper, and registration is inventoried.
- Each file is either migrated to a package owner, deferred with explicit justification, or confirmed as already-migrated.
- The phase0 regression gate (`bash tools/run_ci_local.sh`) stays green throughout (corpus regression covers plugin parsing via `pplugin.spec`).
- Shipped `.plg` corpus source lock (no direct `LinkedSpec::get_plugin(...)`, `run_plugin(...)`, or `dispatch_plugin_autoload_name(...)` calls) is preserved or tightened.
- Live docs (`CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, `MEMORY.md`, `ROADMAP_V2.md`) are updated after each leaf.
- Each completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `PLUGIN-ACTION-MIGRATION`
  Status: `proposed`
  Goal: `Migrate all remaining .plg actions to package owners and clean up legacy plugin wrappers.`
  Children: `PLUGIN-ACTION-MIGRATION.1, PLUGIN-ACTION-MIGRATION.2`

- ID: `PLUGIN-ACTION-MIGRATION.1`
  Status: `pending`
  Goal: `Full inventory of all 36 remaining .plg files: count actions per file, identify already-extracted owners, identify migration candidates, and classify each file's migration complexity.`
  Acceptance: `The task file contains a complete per-file inventory with action counts, existing owner mappings, and migration classification (trivial/moderate/complex). Phase0 baseline stays green (no code changed).`
  Verification: `pending`
  Commit: `pending`

- ID: `PLUGIN-ACTION-MIGRATION.2`
  Status: `pending`
  Goal: `Migrate the first batch of low-complexity .plg files: extract helper bodies into package owners, update callers, and delete wrappers where safe.`
  Acceptance: `Selected low-complexity files are migrated. Phase0 stays green. Corpus regression still parses all 36 files through pplugin.spec.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PLUGIN-ACTION-MIGRATION.1` | `pending` | Need an accurate per-file inventory before any migration work. |

## Decisions

- `2026-06-11`: Created task tree; inventory-first approach so migration complexity is known before any code changes.

## Open Questions

- How many of the 36 files have already had their private helpers extracted (e.g., qcflow.plg, qc_summary.plg, stan_backend.plg) but still keep visible actions?
- Which files have no remaining repo-owned callers and could be deleted outright?
- Which files depend on domain-specific Perl modules (e.g., Win32::OLE for msword.plg) that constrain extraction?

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `pending` | `PLUGIN-ACTION-MIGRATION.1` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `PLUGIN-ACTION-MIGRATION.1` | `pending` | `pending` |

## Changelog

- `2026-06-11`: Created task tree. Activated from proposed status.
