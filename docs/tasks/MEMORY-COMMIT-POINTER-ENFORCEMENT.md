# MEMORY-COMMIT-POINTER-ENFORCEMENT: make the resume-pointer hash contract satisfiable

## Metadata

- Tree ID: `MEMORY-COMMIT-POINTER-ENFORCEMENT`
- Status: `active`
- Roadmap lane: `Repository continuity and doctrine enforcement`
- Created: `2026-07-30`
- Last updated: `2026-07-30`
- Owner: repo-local workflow

## Goal

Replace the self-referential `MEMORY.md latest_commit == post-commit HEAD` expectation with one precise,
satisfiable continuity invariant. Preserve the bounded layer-A resume pointer, make the hook signal actionable,
and prove the rule against repository history and executable checks.

## Problem Statement

`COMMIT.md` requires `MEMORY.md` to be updated before creating a commit. The existing
`.githooks/post-commit` then requires the hash stored in that commit's `MEMORY.md` to equal the newly created
commit's own hash. A normal Git commit cannot contain its own hash: changing the embedded hash changes the
tree and therefore changes the commit hash. Recent repository history instead records the clean activation
boundary from which the committed slice began.

This tree owns the correction. Until it closes, callable-codeblock parity remains parked at the clean Dart
frontier `FUTURE-PARITY-BACKLOG.11.5.1`.

## Non-Goals

- Brute-forcing a self-referential Git hash or rewriting repository history.
- Weakening the bounded-memory, task-tree, Knowledge Map, or commit-per-leaf doctrines.
- Automatically mutating tracked files after a commit and leaving the repository dirty.
- Changing parser, runtime, backend, MCP, or public spec-language behavior.
- Growing the root `README.md`.

## Acceptance Criteria

- Repository history is measured to establish the actual committed-pointer convention.
- The layer-A field has one unambiguous meaning before, during, and after a commit.
- Pre-commit and post-commit expectations are mutually consistent and mechanically testable.
- `.githooks/post-commit` never instructs an operator to create impossible self-hash state.
- Focused tests cover success, malformed-pointer, and genuine-drift cases without modifying the real repository.
- `MEMORY_ARCHITECTURE.md`, `COMMIT.md`, the historical owner, Knowledge Map, live docs, and task indexes agree.
- The root `README.md` remains unchanged.
- Doctrine checks and the canonical local gate pass; each completed leaf is committed separately.

## Task Tree

- ID: `MEMORY-COMMIT-POINTER-ENFORCEMENT`
  Status: `active`
  Goal: `Make the committed resume-pointer hash invariant precise, satisfiable, and enforced.`
  Children: `MEMORY-COMMIT-POINTER-ENFORCEMENT.0`, `MEMORY-COMMIT-POINTER-ENFORCEMENT.1`, `MEMORY-COMMIT-POINTER-ENFORCEMENT.2`

- ID: `MEMORY-COMMIT-POINTER-ENFORCEMENT.0`
  Status: `done`
  Goal: `Activate the corrective owner, measure history, and ratify the exact pointer semantics.`
  Acceptance: `The task tree is indexed; evidence distinguishes the pre-commit activation boundary from the newly created commit; the chosen invariant and migration scope are durable before hook implementation begins.`
  Verification: `ADR 0065; 31/31 consecutive parseable hashes equal first parent; 0 equal self; 0 merge commits in 2,418-commit history; Knowledge Map 763/6,193; mdBook 79 files/13,892 KiB; seven doctrines; canonical CLI 66x2, RAM 56%, Phase 0 1,031/1,031 in 643s; implementation explicitly deferred to .1`

- ID: `MEMORY-COMMIT-POINTER-ENFORCEMENT.1`
  Status: `pending`
  Goal: `Implement and test the satisfiable resume-pointer enforcement.`
  Acceptance: `The hook and any shared checker validate the ratified invariant; hermetic focused tests exercise success and failure diagnostics; all project-locality rules hold.`
  Verification: `pending`

- ID: `MEMORY-COMMIT-POINTER-ENFORCEMENT.2`
  Status: `pending`
  Goal: `Reconcile historical/live documentation, run signoff, and close the corrective tree.`
  Acceptance: `All canonical owners describe the implemented behavior; prior contradictory wording is explicitly superseded; full signoff is green; the repository is clean and the Dart parity frontier is restored.`
  Verification: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `MEMORY-COMMIT-POINTER-ENFORCEMENT.0` | `done` | ADR `0065` ratifies the activation-boundary contract. |
| 2 | `MEMORY-COMMIT-POINTER-ENFORCEMENT.1` | `pending` | Implement only after the contract is durable. |
| 3 | `MEMORY-COMMIT-POINTER-ENFORCEMENT.2` | `pending` | Reconcile and sign off the implemented rule. |

## Decisions

- `2026-07-30`: Opened a separate tree because the exact-HEAD expectation is a foundational continuity defect,
  not part of Dart callable-codeblock parity.
- `2026-07-30`: Preserve a clean pivot boundary: the language-direction tree closed at `b9c3e676`; Dart
  `.11.5.1` remains parked until this tree is complete.
- `2026-07-30`: Ratified ADR `0065`: Git owns current `HEAD`; `MEMORY.md` stores `activation_commit`, which equals
  `HEAD` before the leaf commit and `HEAD^1` afterward. The leaf ID/subject is the durable landing join key.
- `2026-07-30`: Keep post-commit verification non-mutating, but add a hard staged pre-commit phase over one shared
  checker so stale activation boundaries cannot land silently.

## Evidence Plan

- Inspect `MEMORY_ARCHITECTURE.md`, `COMMIT.md`, `.githooks/post-commit`, and the historical
  `LINKEDSPEC-LOW-EFFORT.2` acceptance wording.
- Compare each recent commit's embedded `MEMORY.md` hash with its first parent and with itself.
- Inspect merge/history shape before selecting a first-parent or ancestor relationship.
- Test enforcement in repository-local disposable Git repositories; do not use off-volume temporary state.

## Open Questions

- None for `.0`; implementation details must preserve ADR `0065` exactly.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-30` | `MEMORY-COMMIT-POINTER-ENFORCEMENT.0` | Contract/source inspection; 50-commit table; complete first-parent/merge census; ADR/Knowledge review; Knowledge Map; mdBook; memory/task/whitespace/seven-doctrine checks; canonical local CI | PASS — 31 consecutive parseable pointer commits use exact first parent, none use self, and the 2,418-commit branch has zero merges. Knowledge Map 763/6,193, mdBook 79 files/13,892 KiB, canonical CLI 66x2, RAM 56%, and Phase 0 1,031/1,031 in 643 seconds pass. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `MEMORY-COMMIT-POINTER-ENFORCEMENT.0` | `MEMORY-COMMIT-POINTER-ENFORCEMENT.0 - ratify satisfiable commit pointer` (pending hash) | Activation and semantic ratification; no hook implementation. |
| `MEMORY-COMMIT-POINTER-ENFORCEMENT.1` | pending | Enforcement implementation and focused tests. |
| `MEMORY-COMMIT-POINTER-ENFORCEMENT.2` | pending | Documentation reconciliation, signoff, and closeout. |

## Changelog

- `2026-07-30`: Created the corrective task tree and parked the next language-parity leaf behind its clean
  closeout.
- `2026-07-30`: Completed `.0` evidence and ratification. ADR `0065` replaces the impossible self-hash premise
  with one phase-aware activation-boundary contract; `.1` remains the implementation owner.
