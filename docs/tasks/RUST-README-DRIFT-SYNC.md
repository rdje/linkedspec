# RUST-README-DRIFT-SYNC: reconcile Rust README oracle-count drift

## Metadata

- Tree ID: `RUST-README-DRIFT-SYNC`
- Status: `done`
- Roadmap lane: `Overall roadmap - documentation and book sync`
- Created: `2026-07-08`
- Last updated: `2026-07-08` (`.1` done; tree complete)
- Owner: repo-local workflow

## Goal

Keep the Rust variant README aligned with the current manifest-backed oracle count and the public mdBook status
surface.

## Non-Goals

- Changing parser/runtime behavior.
- Regenerating the oracle corpus.
- Rewriting broader Rust architecture documentation beyond the stale count found during startup review.
- Refreshing `ROADMAP.md` or `ARCHITECTURE_STATE.md`; those remain owned by `ROADMAP-DRIFT-RECONCILE`.

## Acceptance Criteria

- The `rust/README.md` generated-source/interpreter-oracle paragraph names the current 95-fixture interpreter
  oracle boundary, matching `rust/linkedspec-runtime/tests/corpus/manifest.json` and the mdBook.
- Focused scans confirm current-facing Rust README/book status pages do not retain the stale 93-fixture wording for
  the full interpreter oracle.
- `scripts/check_memory_architecture.sh`, `scripts/check_doctrines.sh`, and `git diff --check` pass.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `RUST-README-DRIFT-SYNC`
  Status: `done`
  Goal: Reconcile Rust README oracle-count drift with the current 95-fixture corpus state.
  Children: `.0`, `.1`

- ID: `RUST-README-DRIFT-SYNC.0`
  Status: `done`
  Goal: Capture and register the Rust README drift before editing the README.
  Acceptance: This file exists, `docs/TASK_TREE.md` registers the active tree, live recovery docs point to `.1` as
    the next leaf, and the finding is recorded without changing `rust/README.md`.
  Verification: Done - 2026-07-08. `bash scripts/check_memory_architecture.sh`,
    `bash scripts/check_doctrines.sh`, and `git diff --check` pass.
  Commit: `RUST-README-DRIFT-SYNC.0 - own Rust README count drift`

- ID: `RUST-README-DRIFT-SYNC.1`
  Status: `done`
  Goal: Update `rust/README.md` from the stale 93-fixture interpreter oracle wording to the current 95-fixture
    boundary.
  Acceptance: `rust/README.md` aligns with the checked-in manifest and mdBook; focused stale-count scans pass; no
    parser/runtime behavior changes.
  Verification: Done - 2026-07-08. Focused stale-count scans over `rust/README.md` and the current mdBook status
    pages pass; `bash scripts/check_memory_architecture.sh`, `bash scripts/check_doctrines.sh`, and
    `git diff --check` pass.
  Commit: `RUST-README-DRIFT-SYNC.1 - sync Rust README oracle count`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| - | _none_ | - | Tree complete; return to `docs/TASK_TREE.md` for the next PNT-eligible frontier. |

## Decisions

- `2026-07-08`: Session startup review read the roadmap, active task trees, Knowledge Map, codebase, Rust README,
  and mdBook. `rust/README.md` still said the full interpreter oracle has 93 fixtures, while
  `rust/linkedspec-runtime/tests/corpus/manifest.json`, `MEMORY.md`, live docs, the Knowledge Map, and mdBook pages
  all identify the current corpus as 95 fixtures after `terse_14_4_receiver_with_trailing_block`. This tree owns the
  narrow README correction instead of broadening deferred roadmap/architecture refresh leaves.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-08` | `RUST-README-DRIFT-SYNC.0` | `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; `git diff --check` | PASS - tracking-only owner registered; README content left for `.1` |
| `2026-07-08` | `RUST-README-DRIFT-SYNC.1` | Focused stale-count scans; `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; `git diff --check` | PASS - Rust README now names the 95-fixture interpreter oracle boundary |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `RUST-README-DRIFT-SYNC.0` | `RUST-README-DRIFT-SYNC.0 - own Rust README count drift` | Tracking-only owner for the Rust README count drift. |
| `RUST-README-DRIFT-SYNC.1` | `RUST-README-DRIFT-SYNC.1 - sync Rust README oracle count` | README correction complete. |

## Changelog

- `2026-07-08`: Created task tree to own the isolated Rust README oracle-count drift before editing the README.
- `2026-07-08`: Completed `.1` by updating `rust/README.md` to the current 95-fixture interpreter oracle count and
  closing the tree.
