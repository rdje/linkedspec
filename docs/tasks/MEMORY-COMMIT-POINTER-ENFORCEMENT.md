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
  Status: `done`
  Goal: `Implement and test the satisfiable resume-pointer enforcement.`
  Acceptance: `The field, canonical workflow owners, hooks, and shared checker validate the ratified invariant atomically; hermetic focused tests exercise success and failure diagnostics; contradictory historical wording is explicitly superseded; all project-locality rules hold.`
  Verification: `11 hermetic pointer cases; direct auto/pre checks; Knowledge Map 763/6,194; mdBook 79 files/13,896 KiB; seven doctrines; canonical containment/moved-root, CLI 66x2, RAM 54%, Phase 0 1,031/1,031 in 637s`

- ID: `MEMORY-COMMIT-POINTER-ENFORCEMENT.2`
  Status: `pending`
  Goal: `Independently recompose the committed enforcement, reconcile status, and close the corrective tree.`
  Acceptance: `A clean-boundary audit finds all canonical and historical owners aligned without further implementation change; independent full signoff is green; the repository is clean and the Dart parity frontier is restored.`
  Verification: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `MEMORY-COMMIT-POINTER-ENFORCEMENT.0` | `done` | ADR `0065` ratifies the activation-boundary contract. |
| 2 | `MEMORY-COMMIT-POINTER-ENFORCEMENT.1` | `done` | Enforcement and complete signoff pass from clean `ddad65aa`; landing commit pending. |
| 3 | `MEMORY-COMMIT-POINTER-ENFORCEMENT.2` | `pending` | Independently recompose the committed rule and close the tree after the clean `.1` commit. |

## Decisions

- `2026-07-30`: Opened a separate tree because the exact-HEAD expectation is a foundational continuity defect,
  not part of Dart callable-codeblock parity.
- `2026-07-30`: Preserve a clean pivot boundary: the language-direction tree closed at `b9c3e676`; Dart
  `.11.5.1` remains parked until this tree is complete.
- `2026-07-30`: Ratified ADR `0065`: Git owns current `HEAD`; `MEMORY.md` stores `activation_commit`, which equals
  `HEAD` before the leaf commit and `HEAD^1` afterward. The leaf ID/subject is the durable landing join key.
- `2026-07-30`: Keep post-commit verification non-mutating, but add a hard staged pre-commit phase over one shared
  checker so stale activation boundaries cannot land silently.
- `2026-07-30`: Keep the field/checker/hook/workflow migration atomic in `.1`, including explicit supersession of
  contradictory historical wording. `.2` is an independent clean-boundary recomposition and status closeout,
  not a second partial migration.

## Evidence Plan

- Inspect `MEMORY_ARCHITECTURE.md`, `COMMIT.md`, `.githooks/post-commit`, and the historical
  `LINKEDSPEC-LOW-EFFORT.2` acceptance wording.
- Compare each recent commit's embedded `MEMORY.md` hash with its first parent and with itself.
- Inspect merge/history shape before selecting a first-parent or ancestor relationship.
- Test enforcement in repository-local disposable Git repositories; do not use off-volume temporary state.

## Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `rg -n` over `COMMIT.md`, `MEMORY_ARCHITECTURE.md`, `.githooks/post-commit`, and
  `docs/tasks/LINKEDSPEC-LOW-EFFORT.md` reproduced the impossible staged-then-self-`HEAD` requirement; the 31-commit
  Git history probe found 31 exact first-parent pointers and zero self pointers.
- [x] **ROOT CAUSE (WHY + WHERE)** — The mechanism is Git content addressing: `.githooks/post-commit` compared a
  hash stored in committed `MEMORY.md` with the commit identity that includes those bytes. ADR `0065` records why
  this cannot be satisfied and locates the old contract in the hook, memory standard, commit workflow, and task.
- [x] **FIX** — `scripts/check_memory_commit_pointer.sh` owns one read-only parser and exact auto/pre/post boundary;
  `.githooks/pre-commit` hard-checks staged `HEAD`, `.githooks/post-commit` softly verifies committed `HEAD^1`, and
  `scripts/check_memory_architecture.sh` plus `tools/run_ci_local.sh` compose the same owner.
- [x] **ADDRESSED (verified)** — `bash tools/test_memory_commit_pointer.sh` passes 11 hermetic cases and direct
  auto/pre-commit checks resolve `ddad65aa` to current `HEAD`; malformed, drifted, duplicate, and ambiguous states
  are rejection-tested. `bash scripts/check_doctrines.sh` passes all seven registered doctrines, and the complete
  `bash tools/run_ci_local.sh` rerun passes.
- [x] **NO REGRESSION** — `bash -n` over all six changed/new shell owners, `git diff --check`, the memory-architecture
  check, Knowledge Map 763/6,194, and `mdbook build docs/linkedspec-book` at 79 files / 13,896 KiB pass. The root
  `README.md`, parser/runtime/backend code, and public DSL behavior are unchanged.
- [x] **LOCKSTEP** — ADR `0065`, `AGENTS.md`, both memory/workflow standards, hooks, E2/E4 integration, historical
  task owners, both Knowledge cards, roadmaps/live architecture, task index, and mdBook describe one activation-
  boundary contract; `.2` independently re-audits the committed result before Dart parity resumes.

## Open Questions

- None; `.1` preserves ADR `0065` exactly and `.2` is a no-change committed-state audit.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-30` | `MEMORY-COMMIT-POINTER-ENFORCEMENT.0` | Contract/source inspection; 50-commit table; complete first-parent/merge census; ADR/Knowledge review; Knowledge Map; mdBook; memory/task/whitespace/seven-doctrine checks; canonical local CI | PASS — 31 consecutive parseable pointer commits use exact first parent, none use self, and the 2,418-commit branch has zero merges. Knowledge Map 763/6,193, mdBook 79 files/13,892 KiB, canonical CLI 66x2, RAM 56%, and Phase 0 1,031/1,031 in 643 seconds pass. |
| `2026-07-30` | `MEMORY-COMMIT-POINTER-ENFORCEMENT.1` | Shell syntax; 11 hermetic cases; direct auto/pre phases; memory/Knowledge/task/whitespace/seven doctrines; mdBook; complete canonical local CI | PASS — Knowledge Map 763/6,194; mdBook 79 files/13,896 KiB; all seven doctrines; containment/moved-root; CLI 66x2; RAM 54%; Phase 0 1,031/1,031 in 637 seconds. Initial canonical attempt rejected the missing task-acceptance checklist; exact evidence was added and the complete rerun passed. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `MEMORY-COMMIT-POINTER-ENFORCEMENT.0` | `ddad65aa` — `MEMORY-COMMIT-POINTER-ENFORCEMENT.0 - ratify satisfiable commit pointer` | Activation and semantic ratification; no hook implementation. |
| `MEMORY-COMMIT-POINTER-ENFORCEMENT.1` | planned subject `MEMORY-COMMIT-POINTER-ENFORCEMENT.1 - enforce activation commit pointer` | Enforcement implementation and focused/canonical signoff complete; exact hash is derived from Git after landing. |
| `MEMORY-COMMIT-POINTER-ENFORCEMENT.2` | pending | Documentation reconciliation, signoff, and closeout. |

## Changelog

- `2026-07-30`: Created the corrective task tree and parked the next language-parity leaf behind its clean
  closeout.
- `2026-07-30`: Completed `.0` evidence and ratification. ADR `0065` replaces the impossible self-hash premise
  with one phase-aware activation-boundary contract; `.1` remains the implementation owner.
- `2026-07-30`: Committed `.0` at `ddad65aa`, cleared the brief, removed the exact empty retained run namespace,
  proved a clean/zero-run boundary, and activated `.1` before implementation changes.
- `2026-07-30`: `.1` now has one pure phase-aware checker, a hard staged pre-commit boundary, a non-mutating
  committed first-parent post-check, automatic E2/E4 composition, and 11 repository-volume hermetic cases under
  review before signoff.
- `2026-07-30`: `.1` signoff passes after the doctrine gate caught and required its missing TOOLBOX acceptance
  checklist. Complete evidence is Knowledge Map 763/6,194, mdBook 79/13,896, seven doctrines, containment/
  moved-root, CLI 66x2, RAM 54%, and Phase 0 1,031/1,031 in 637 seconds; `.2` waits for the clean landing commit.
