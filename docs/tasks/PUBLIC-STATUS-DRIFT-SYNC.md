# PUBLIC-STATUS-DRIFT-SYNC: Reconcile public status docs with current codebase state

## Metadata

- Tree ID: `PUBLIC-STATUS-DRIFT-SYNC`
- Status: `done`
- Roadmap lane: `Overall roadmap - documentation and book sync`
- Created: `2026-07-07`
- Last updated: `2026-07-07`
- Owner: repo-local workflow

## Goal

Close public status-documentation drift discovered during the 2026-07-07 bootstrap/context pass.
The authoritative current state is `ROADMAP_V2.md`, the active task-tree ledger, `MEMORY.md`,
`rust/linkedspec-runtime/tests/corpus/manifest.json`, and the live codebase. The first concrete
public drift is in the mdBook status surface: `overview/project-status.md` still describes Rust
cross-variant parity as an ongoing follow-on, and `appendix/backend-handoff.md` still names an older
Rust oracle corpus count in its explanatory handoff text.
A follow-up full mdBook read found one residual public count drift in
`specs-and-corpora/shipped-specs-and-corpora.md`; `.2` owns that correction before any book edit.

## Non-Goals

- Rewriting the long-form `ROADMAP.md`; that remains owned by `ROADMAP-DRIFT-RECONCILE`.
- Refreshing `ARCHITECTURE_STATE.md`; that remains owned by `ROADMAP-DRIFT-RECONCILE.2`.
- Changing parser/runtime behavior. This tree is documentation/status synchronization only.
- Resuming the paused `SPEC-LANG-REFERENCE` scorch. This tree only fixes status drift found in the
  current public overview/handoff surface.

## Acceptance Criteria

- The task-tree owner exists before any public status document edit.
- `docs/linkedspec-book/src/overview/project-status.md` no longer says Rust parity is an ongoing
  follow-on; it reflects the current manifest-backed 93-fixture interpreter oracle and generated-source
  subset boundary.
- `docs/linkedspec-book/src/appendix/backend-handoff.md` uses the current 93-fixture Rust corpus count
  where it describes the interpreter oracle gate.
- `docs/linkedspec-book/src/specs-and-corpora/shipped-specs-and-corpora.md` uses the current
  manifest-backed 93-fixture Rust corpus count instead of the older 91-fixture wording.
- Focused no-drift scans over the touched status pages pass.
- `mdbook build docs/linkedspec-book` passes when the book is changed.
- `scripts/check_memory_architecture.sh`, `knowledge-map/scripts/check_knowledge_map.sh`, and
  `scripts/check_doctrines.sh` pass.
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `PUBLIC-STATUS-DRIFT-SYNC`
  Status: `done`
  Goal: Reconcile public status docs with the current codebase/task-tree state.
  Children: `.0`, `.1`, `.2`

- ID: `PUBLIC-STATUS-DRIFT-SYNC.0`
  Status: `done`
  Goal: Create and register the task tree so the public status drift is owned before edits.
  Acceptance: This file exists, `docs/TASK_TREE.md` registers the active tree, live recovery docs point
    to `.1` as the next leaf, and no code/book content is changed in this tracking-only slice.
  Verification: `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`;
    `bash scripts/check_doctrines.sh`; `git diff --check`
  Commit: `PUBLIC-STATUS-DRIFT-SYNC.0 - create public status drift tree`

- ID: `PUBLIC-STATUS-DRIFT-SYNC.1`
  Status: `done`
  Goal: Update the mdBook public status/handoff pages to the current Rust parity/corpus state.
  Acceptance: `overview/project-status.md` and `appendix/backend-handoff.md` align with
    `ROADMAP_V2.md`, `MEMORY.md`, and `rust/linkedspec-runtime/tests/corpus/manifest.json`; no public
    status wording still presents closed Rust parity as ongoing; focused scans, mdBook, memory, Knowledge
    Map, and doctrine gates pass.
  Verification: `mdbook build docs/linkedspec-book`; focused stale-status scan over the touched book pages;
    `bash knowledge-map/scripts/gen_knowledge_map.sh`; `bash scripts/check_memory_architecture.sh`;
    `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `git diff --check`
  Commit: `PUBLIC-STATUS-DRIFT-SYNC.1 - sync public Rust status docs`

- ID: `PUBLIC-STATUS-DRIFT-SYNC.2`
  Status: `done`
  Goal: Correct the residual shipped-specs book page Rust oracle count after the full mdBook read.
  Acceptance: `specs-and-corpora/shipped-specs-and-corpora.md` no longer names the older 91-fixture
    Rust oracle corpus and instead matches the current 93-fixture manifest-backed interpreter oracle;
    long-form roadmap and architecture-state count drift remain deferred to `ROADMAP-DRIFT-RECONCILE`;
    focused scans, mdBook, memory, Knowledge Map, doctrine, and diff checks pass.
  Verification: `mdbook build docs/linkedspec-book`; focused stale-count scan over public status/handoff/
    shipped-specs pages; `bash scripts/check_memory_architecture.sh`;
    `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`;
    `git diff --check`
  Commit: `PUBLIC-STATUS-DRIFT-SYNC.2 - fix residual shipped corpus count drift`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | — | — | Complete; return to `docs/TASK_TREE.md` for the next PNT-eligible frontier after commit. |

## Decisions

- `2026-07-07`: During the user-directed bootstrap/context pass, `ROADMAP_V2.md`, `MEMORY.md`, the
  Rust corpus manifest, and core owner-code inspection showed Rust interpreter parity is no longer the
  open follow-on described by the mdBook project status page. The long-form roadmap drift remains owned
  elsewhere; this tree owns the narrower public status/book surface so it can be fixed without broadening
  `ROADMAP-DRIFT-RECONCILE`.
- `2026-07-07`: During the full mdBook read-through, the shipped-specs/corpora page still named the
  older 91-fixture Rust oracle corpus even though the manifest, project status page, and backend handoff
  page are now at 93 fixtures. Treat that as residual public-status drift under `.2`; do not broaden this
  leaf into the already deferred `ROADMAP-DRIFT-RECONCILE.1`/`.2` roadmap and architecture refresh.

## Open Questions

- None blocking.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-07` | `PUBLIC-STATUS-DRIFT-SYNC.0` | `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `git diff --check` | PASS — tracking-only tree registered, live docs updated, no code/book content changed |
| `2026-07-07` | `PUBLIC-STATUS-DRIFT-SYNC.1` | `mdbook build docs/linkedspec-book`; focused stale-status scan over the touched book pages; `bash knowledge-map/scripts/gen_knowledge_map.sh`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `git diff --check` | PASS — book status/handoff pages and Knowledge facts updated to the 93-fixture interpreter oracle and generated-source subset boundary |
| `2026-07-07` | `PUBLIC-STATUS-DRIFT-SYNC.2` | `mdbook build docs/linkedspec-book`; focused stale-count scan over public status/handoff/shipped-specs pages; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `git diff --check` | PASS — shipped-specs book page now points at the manifest-backed 93-fixture Rust oracle and stale 91/88 public-page hits are gone |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `PUBLIC-STATUS-DRIFT-SYNC.0` | `PUBLIC-STATUS-DRIFT-SYNC.0 - create public status drift tree` | Tracking-only; no code/book content changes. |
| `PUBLIC-STATUS-DRIFT-SYNC.1` | `PUBLIC-STATUS-DRIFT-SYNC.1 - sync public Rust status docs` | Public mdBook status/handoff wording and Knowledge cards refreshed. |
| `PUBLIC-STATUS-DRIFT-SYNC.2` | `PUBLIC-STATUS-DRIFT-SYNC.2 - fix residual shipped corpus count drift` | Residual shipped-specs book page count corrected. |

## Changelog

- `2026-07-07`: Created tree to own public status/mdBook drift before making any book edits.
- `2026-07-07`: Completed `.1`; public status/handoff pages now use the current Rust interpreter oracle count,
  generated-source subset boundary, and manifest path.
- `2026-07-07`: Completed `.2`; the shipped-specs/corpora book page now names the manifest-backed 93-fixture
  Rust oracle and points readers at the manifest for the exact case list.
