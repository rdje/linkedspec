# DOC-BOOK-SYNC: Documentation and mdBook Synchronization

## Metadata

- Tree ID: `DOC-BOOK-SYNC`
- Status: `active`
- Roadmap lane: `Overall roadmap — documentation and book sync`
- Created: `2026-06-14`
- Last updated: `2026-06-14`
- Owner: repo-local workflow

## Goal

Ensure the mdBook (`docs/linkedspec-book/`) and live docs (`USER_GUIDE.md`, `ARCHITECTURE_STATE.md`, etc.) are fully synchronized with the current codebase. Every user-facing feature, DSL helper, API surface, and architectural boundary present in the code must be accurately reflected in the book. No drift permitted between codebase ↔ book ↔ live docs.

## Non-Goals

- Adding new features or changing code behavior (this is a documentation-only tree).
- Restructuring the book's organization (keep the existing SUMMARY.md chapter layout unless a concrete gap demands a new page).
- Rewriting the entire book from scratch (targeted fixes only).

## Acceptance Criteria

- Every page in the mdBook is audited against the current codebase; gaps and stale references are identified.
- All identified gaps are remediated: missing content added, stale references updated, drift eliminated.
- Live docs (`USER_GUIDE.md`, `ARCHITECTURE_STATE.md`) are verified to be aligned with the book and codebase.
- `scripts/check_memory_architecture.sh` passes.
- Broader regression gate (`tools/run_ci_local.sh`) passes.
- Each completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `DOC-BOOK-SYNC`
  Status: `active`
  Goal: `Full documentation and mdBook synchronization with the current codebase.`
  Children: `DOC-BOOK-SYNC.0`, `DOC-BOOK-SYNC.1`, `DOC-BOOK-SYNC.2`, `DOC-BOOK-SYNC.3`

- ID: `DOC-BOOK-SYNC.0`
  Status: `in_progress`
  Goal: `Create the DOC-BOOK-SYNC task tree, register it in docs/TASK_TREE.md active table, and update MEMORY.md resume pointer.`
  Acceptance: `Tree file exists at docs/tasks/DOC-BOOK-SYNC.md with 4 leaves. Active Task Trees table updated. MEMORY.md current-state block reflects DOC-BOOK-SYNC as active_work_unit.`
  Verification: `pending`
  Commit: `pending`

- ID: `DOC-BOOK-SYNC.1`
  Status: `pending`
  Goal: `Audit the mdBook and live docs against the current codebase — identify every gap, stale reference, missing feature, and drift.`
  Acceptance: `A gap list is produced covering: (a) each mdBook page checked against its corresponding code surface, (b) live docs (USER_GUIDE.md, ARCHITECTURE_STATE.md) checked for staleness, (c) each gap classified as missing/stale/drift. The gap list is recorded in this task file under a dedicated audit-results section.`
  Verification: `pending`
  Commit: `pending`

- ID: `DOC-BOOK-SYNC.2`
  Status: `pending`
  Goal: `Remediate all gaps identified in DOC-BOOK-SYNC.1 — update book pages, live docs, and cross-references to eliminate drift.`
  Acceptance: `Every gap from the .1 audit is addressed: book pages updated, live docs refreshed, stale references removed, missing content added. Each remediation is traceable to a specific gap from the audit list.`
  Verification: `pending`
  Commit: `pending`

- ID: `DOC-BOOK-SYNC.3`
  Status: `pending`
  Goal: `Finalization: verify alignment, run full CI gate, update live docs, close tree.`
  Acceptance: `mdBook build succeeds (if tooling available). scripts/check_memory_architecture.sh passes. tools/run_ci_local.sh passes. ROADMAP_V2.md overall status reflects completion. MEMORY.md updated. Tree moved to Completed in docs/TASK_TREE.md.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `DOC-BOOK-SYNC.0` | `in_progress` | Bootstrap: tree creation, TASK_TREE.md registration, MEMORY.md update. |
| 2 | `DOC-BOOK-SYNC.1` | `pending` | Need an accurate gap inventory before any remediation can begin. |

## Decisions

- `2026-06-14`: Tree created with 3 leaves (audit → remediate → finalize). The existing BOOK-DOCUMENTATION-SYNC tree (completed, 3 leaves) covered a prior sync pass; this tree is a fresh sweep to catch any drift that has accumulated since.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `pending` | `DOC-BOOK-SYNC.0` | `pending` | `pending` |
| `pending` | `DOC-BOOK-SYNC.1` | `pending` | `pending` |
| `pending` | `DOC-BOOK-SYNC.2` | `pending` | `pending` |
| `pending` | `DOC-BOOK-SYNC.3` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `DOC-BOOK-SYNC.0` | `pending` | `pending` |
| `DOC-BOOK-SYNC.1` | `pending` | `pending` |
| `DOC-BOOK-SYNC.2` | `pending` | `pending` |
| `DOC-BOOK-SYNC.3` | `pending` | `pending` |

## Changelog

- `2026-06-14`: Created task tree with 3 leaves for documentation/book sync audit and remediation.
