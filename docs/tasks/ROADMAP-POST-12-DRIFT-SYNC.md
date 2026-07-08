# ROADMAP-POST-12-DRIFT-SYNC: sync long roadmap after hash-tree traversal closeout

## Metadata

- Tree ID: `ROADMAP-POST-12-DRIFT-SYNC`
- Status: `done`
- Roadmap lane: `Overall roadmap - documentation and book sync`
- Created: `2026-07-08`
- Last updated: `2026-07-08` (`.1` done; tree complete)
- Owner: repo-local workflow

## Goal

Keep the long-form `ROADMAP.md` aligned with the current post-`SPEC-FORMAT-TERSE.12.4`
status baseline after startup review found stale current-state counts.

## Non-Goals

- Changing parser/runtime behavior.
- Regenerating the oracle corpus.
- Reopening the completed `ROADMAP-DRIFT-RECONCILE` tree.
- Editing mdBook content when the reviewed book already carries the current `1..1027` /
  96-fixture state.

## Acceptance Criteria

- Current-facing `ROADMAP.md` status lines name the phase0 `1..1027` baseline and 96-fixture
  Rust interpreter oracle, matching `MEMORY.md`, `ROADMAP_V2.md`, `ARCHITECTURE_STATE.md`,
  the `SPEC-FORMAT-TERSE.12.4` task-tree closeout, and the mdBook.
- Focused stale-count scans confirm the long roadmap no longer advertises the current state
  as `1..1026` or 95 Rust oracle fixtures.
- Live docs record this docs-only drift correction and the reviewed mdBook no-drift boundary.
- `scripts/check_memory_architecture.sh`, doctrine checks, mdBook build, and `git diff --check`
  pass.
- The completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `ROADMAP-POST-12-DRIFT-SYNC`
  Status: `done`
  Goal: Reconcile `ROADMAP.md` with the current post-`.12.4` status baseline.
  Children: `.1`

- ID: `ROADMAP-POST-12-DRIFT-SYNC.1`
  Status: `done`
  Goal: Update stale current-state counts in `ROADMAP.md` from the pre-`.12` `1..1026` /
    95-fixture baseline to the current `1..1027` / 96-fixture baseline.
  Acceptance: `ROADMAP.md` current-state status lines align with current live docs and mdBook; focused stale-count
    scans pass; no parser/runtime behavior changes.
  Verification: Done - 2026-07-08. Focused stale-count scans over `ROADMAP.md` pass; mdBook source was reviewed and
    already carried the current baseline; `mdbook build docs/linkedspec-book`, memory architecture, Knowledge Map,
    doctrine, task-tree metadata, and whitespace checks pass.
  Commit: `ROADMAP-POST-12-DRIFT-SYNC.1 - sync long roadmap baseline`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| - | _none_ | - | Tree complete; return to `docs/TASK_TREE.md` for the next PNT-eligible frontier. |

## Decisions

- `2026-07-08`: Startup review loaded the roadmap, relevant codebase spine, and mdBook. The mdBook already
  documents phase0 `1..1027`, the 96-fixture Rust oracle, and hash-tree traversal receiver blocks, while
  `ROADMAP.md` still retained current-state `1..1026` / 95-fixture wording in several live-status locations.
  This tree owns the narrow long-roadmap correction instead of reopening the completed broader reconciliation
  tree.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-08` | `ROADMAP-POST-12-DRIFT-SYNC.1` | Focused stale-count scans over `ROADMAP.md`; `mdbook build docs/linkedspec-book`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `git diff --check` | PASS - long roadmap current-state counts now align with the `1..1027` / 96-fixture baseline |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `ROADMAP-POST-12-DRIFT-SYNC.1` | `ROADMAP-POST-12-DRIFT-SYNC.1 - sync long roadmap baseline` | Long roadmap count drift corrected; tree complete. |

## Changelog

- `2026-07-08`: Created task tree to own the startup-discovered long-roadmap baseline drift before editing
  `ROADMAP.md`.
- `2026-07-08`: Completed `.1` by synchronizing `ROADMAP.md` current-state counts to phase0 `1..1027` and the
  96-fixture Rust interpreter oracle.
