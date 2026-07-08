# RUST-STATUS-DRIFT-SYNC: sync Rust status counts after array-tree oracle closeout

## Metadata

- Tree ID: `RUST-STATUS-DRIFT-SYNC`
- Status: `done`
- Roadmap lane: `Overall roadmap - documentation and book sync`
- Created: `2026-07-08`
- Last updated: `2026-07-08` (`.1` done; tree complete)
- Owner: repo-local workflow

## Goal

Keep current-facing Rust variant status docs aligned with the post-`SPEC-FORMAT-TERSE.13.4` baseline: phase0
`1..1028`, 21 shipped specs, and the 97-fixture manifest-backed Rust interpreter oracle.

## Non-Goals

- Changing parser/runtime behavior.
- Regenerating the Rust oracle corpus.
- Rewriting historical task-tree or changelog entries whose counts were accurate at the time of their slice.
- Reopening the completed `SPEC-FORMAT-TERSE` or earlier roadmap-drift task trees.

## Acceptance Criteria

- Current-facing `ROADMAP.md`, `rust/README.md`, and mdBook shipped-corpus status no longer advertise stale
  96-fixture, 20-shipped-spec, or `1..1027` current state.
- Focused scans distinguish current-facing drift from historical records and pass for the changed docs.
- Live docs record this docs-only drift correction.
- `mdbook build docs/linkedspec-book`, `scripts/check_memory_architecture.sh`, doctrine checks, task-tree metadata,
  and `git diff --check` pass.
- The completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `rg -n "1\\.\\.1027|96-fixture|96 fixture|all 20 shipped|20 shipped specs|All 20 shipped|full 96|green over 96|over 96" docs/linkedspec-book/src rust/README.md ROADMAP.md ...` found current-facing stale status in `ROADMAP.md`, `rust/README.md`, and `docs/linkedspec-book/src/specs-and-corpora/shipped-specs-and-corpora.md`.
- [x] **ROOT CAUSE (WHY + WHERE)** — root cause was current-facing documentation drift after `SPEC-FORMAT-TERSE.13.3` raised the Rust oracle; WHERE: `ROADMAP.md:864`, `rust/README.md:20`, `rust/README.md:89`, `rust/README.md:101`, and `docs/linkedspec-book/src/specs-and-corpora/shipped-specs-and-corpora.md:191`; `rust/linkedspec-runtime/tests/corpus/manifest.json:2` is the canonical `case_count` source.
- [x] **FIX** — Updated only the current-facing docs to 97 fixtures, 21 shipped specs, and phase0 `1..1028`; historical earlier-count records stayed intact.
- [x] **ADDRESSED (verified)** — `rg -n` over the changed current-facing files now returns no stale 96-fixture / 20-shipped-spec / `1..1027` current-state hits; `rg -n '"case_count"|terse_13_3_array_tree_traversal_receiver_blocks' rust/linkedspec-runtime/tests/corpus/manifest.json` shows `case_count` 97 and the array-tree fixture.
- [x] **NO REGRESSION** — Docs-only change; no parser/runtime/corpus files changed. `mdbook build docs/linkedspec-book`, `bash scripts/check_memory_architecture.sh`, `bash knowledge-map/scripts/check_knowledge_map.sh`, `bash scripts/check_doctrines.sh`, `bash scripts/check_task_tree_metadata.sh`, and `git diff --check` PASS.
- [x] **LOCKSTEP** — `MEMORY.md`, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, `docs/TASK_TREE.md`, this task file, `ROADMAP.md`, `rust/README.md`, and the mdBook shipped-corpora page are updated together; Knowledge Map check passes with no fact-card change needed.

## Task Tree

- ID: `RUST-STATUS-DRIFT-SYNC`
  Status: `done`
  Goal: Reconcile current-facing Rust status counts after the 97th oracle fixture landed.
  Children: `.1`

- ID: `RUST-STATUS-DRIFT-SYNC.1`
  Status: `done`
  Goal: Update stale current-facing Rust status counts in `ROADMAP.md`, `rust/README.md`, and the mdBook.
  Acceptance: Current-facing docs align with the 97-fixture manifest, 21 shipped specs, and phase0 `1..1028`;
    focused stale-count scans and doc gates pass; no parser/runtime behavior changes.
  Verification: Done - 2026-07-08. Focused current-facing stale-count scans pass for `ROADMAP.md`, `rust/README.md`,
    and mdBook source; remaining stale-count hits are historical slice records. `mdbook build`, memory architecture,
    Knowledge Map, doctrine, task-tree metadata, and whitespace gates pass.
  Commit: `RUST-STATUS-DRIFT-SYNC.1 - sync Rust status counts`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| - | _none_ | - | Tree complete; return to `docs/TASK_TREE.md` for the next PNT-eligible frontier. |

## Decisions

- `2026-07-08`: Knowledge Map retrieval confirms the current Rust oracle fact: `SPEC-FORMAT-TERSE.13.3` added
  `terse_13_3_array_tree_traversal_receiver_blocks`, raising the manifest-backed Rust oracle to 97 fixtures.
  Current-facing docs should state 97 fixtures, 21 shipped specs, and phase0 `1..1028`; historical records from
  earlier leaves remain untouched unless they claim current state.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-08` | `RUST-STATUS-DRIFT-SYNC.1` | Focused stale-count scans over current-facing docs; manifest `case_count` check; shipped-spec count check; `mdbook build docs/linkedspec-book`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `git diff --check` | PASS - current-facing Rust status docs align with 97 fixtures, 21 shipped specs, and phase0 `1..1028` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `RUST-STATUS-DRIFT-SYNC.1` | `RUST-STATUS-DRIFT-SYNC.1 - sync Rust status counts` | Rust status count drift corrected; tree complete. |

## Changelog

- `2026-07-08`: Created task tree to own startup-discovered current-facing Rust status drift before editing docs.
- `2026-07-08`: Completed `.1` by synchronizing current-facing Rust status counts in the roadmap, Rust README, and
  mdBook shipped-corpora page to 97 fixtures, 21 shipped specs, and phase0 `1..1028`.
