# DOC-DRIFT-SYNC: Reconcile verified roadmap/book drift against the codebase

## Metadata

- Tree ID: `DOC-DRIFT-SYNC`
- Status: `active`
- Roadmap lane: `Overall roadmap — documentation and book sync`
- Created: `2026-06-17`
- Last updated: `2026-06-17` (`.1` done — ROADMAP.md synced to ROADMAP_V2.md: Phase 8/9 long-form sections + Status rows added, Overall flipped to `done`; frontier → `.2`)
- Owner: repo-local workflow

## Goal

Eliminate two drifts found by a bootstrap-session audit and verified directly against
the source, restoring the non-negotiable zero-drift invariant between `ROADMAP.md`,
`ROADMAP_V2.md`, the mdBook, and the codebase (doctrine: `docs/decisions/0001`,
`ROADMAP_V2.md:425`):

1. `ROADMAP.md` lags `ROADMAP_V2.md`: its Status table marks Overall `mostly done`
   (scope "phases 0-7"), has **no Phase 8 / Phase 9 rows**, and never narrates Phases
   8–9 in its long-form Work Phases section, while `ROADMAP_V2.md:56,66-67` marks
   Overall `done` with Phase 8 (multi-backend handoff) and Phase 9 (Rust variant, v0.1
   operational) both `done`.
2. `docs/linkedspec-book/src/appendix/formal-grammar.md` has the `:&` and `:|`
   rule-mode description cells **transposed** — it labels `:&` "single-match choice
   (`:OR{1}`)" and `:|` "Ordered sequence (equivalent to `:AND`)", inverting the
   AND/OR sense relative to the authoritative `BootstrapSpec/Core.pm:347-348`
   (`'&' => 'AND'`, `'|' => 'OR'`) and the dedicated book chapter
   `user-model/rule-modes-and-parse-modes.md` (`:&` = ordered sequence; `:|` =
   single-choice dispatch).

## Non-Goals

- The "158 vs 146 helper contracts" count flagged by the same audit — **not drift**:
  the book's `158` is reproducible (`grep -cE "\bid\b => '"` `ActionIR/Contracts.pm`
  = 158); the dismissed 146 used a narrower indentation-anchored pattern. No change.
- Any code/behavior change in the Perl reference or the Rust variant.
- Re-narrating the full ActionIR/owner-cleanup history into `ROADMAP.md` (that detail
  lives in `ROADMAP_V2.md` + the task trees by design).

## Acceptance Criteria

- `ROADMAP.md` and `ROADMAP_V2.md` agree on Overall status and on Phases 0–9.
- `formal-grammar.md` `:&`/`:|` rows match `Core.pm` + `rule-modes-and-parse-modes.md`;
  `mdbook build` succeeds.
- `scripts/check_memory_architecture.sh` passes; the KM gate stays green.
- Live docs updated where project state changed; each leaf committed via `COMMIT.md`.

## Task Tree

- ID: `DOC-DRIFT-SYNC`
  Status: `active`
  Goal: Reconcile the two verified roadmap/book drifts against the codebase
  Children: `.1`, `.2`

- ID: `DOC-DRIFT-SYNC.1`
  Status: `done`
  Goal: Sync `ROADMAP.md` to `ROADMAP_V2.md` — add Phase 8 + Phase 9 (long-form Work
  Phases sections + Status-table rows) and flip Overall `mostly done` → `done`
  Acceptance: `ROADMAP.md` carries `## Phase 8` and `## Phase 9` prose sections
  (mirroring `ROADMAP_V2.md:66-67` + the completed `PHASE8-MULTI-BACKEND-HANDOFF` /
  `PHASE9-RUST-VARIANT` trees) and Status-table rows for both; the Overall row reads
  `done` with covers/remaining text aligned to `ROADMAP_V2.md:56`; no other roadmap
  status changes; self-check passes.
  Verification: Done — 2026-06-17. Added `## Phase 8` (multi-backend specification and
  handoff surface, mirroring `PHASE8-MULTI-BACKEND-HANDOFF`) and `## Phase 9` (Rust
  variant implementation, mirroring `PHASE9-RUST-VARIANT` and pointing at the active
  `RUST-PARITY` parity follow-on) long-form sections after Phase 7 and before the
  Backbone Refactor Track; inserted Phase 8 + Phase 9 rows in the Status table after the
  Phase 7 row; flipped the Overall row `mostly done` → `done` with covers/remaining
  aligned to `ROADMAP_V2.md:56`. `ROADMAP.md` now agrees with `ROADMAP_V2.md` on Overall
  status and Phases 0–9; no other roadmap status changed. The owning tree was created in
  this same commit (ownership-first: tree authored before the ROADMAP.md edit and present
  in the committed state). `scripts/check_memory_architecture.sh` exit 0; KM gate green.
  Doc-only, no book/code touched — no `mdbook build` needed for this leaf.
  Commit: `DOC-DRIFT-SYNC.1` (see Commit Log)

- ID: `DOC-DRIFT-SYNC.2`
  Status: `pending`
  Goal: Fix the transposed `:&`/`:|` rule-mode description cells in
  `docs/linkedspec-book/src/appendix/formal-grammar.md`
  Acceptance: row `:&` reads "Ordered sequence (equivalent to `:AND`)." and row `:|`
  reads a single-choice description (`:OR{1}`), matching `Core.pm:347-348` and
  `user-model/rule-modes-and-parse-modes.md`; `mdbook build` exit 0; self-check passes.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `DOC-DRIFT-SYNC.1` | `done` | ROADMAP.md synced to ROADMAP_V2.md (2026-06-17): Phase 8/9 long-form sections + Status rows added, Overall flipped `mostly done`→`done` |
| 1 | `DOC-DRIFT-SYNC.2` | `pending` | **next** — surgical two-cell book fix: swap the transposed `:&`/`:|` rows in formal-grammar.md:68-69 to match Core.pm + rule-modes-and-parse-modes.md |

## Decisions

- `2026-06-17`: Created tree to own two drifts surfaced during the `README.md` bootstrap
  audit and verified directly against source (not relayed second-hand). Split into two
  independent, separately-reviewable leaves (PNT splitting rule): a roadmap-tracker sync
  and a surgical book correctness fix. The "158 vs 146 contracts" finding was dismissed
  after direct verification (the book figure is reproducible) and is recorded as a
  Non-Goal so a later session does not re-investigate it.
- `2026-06-17`: `ROADMAP_V2.md` is treated as the canonical high-level workstream status
  (per `docs/TASK_TREE.md` "Relationship To Live Docs"), so `.1` aligns `ROADMAP.md`
  *to* V2 rather than the reverse; V2 itself needs no change.

## Open Questions

- None — both fixes are fully specified and verified against authoritative source.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-17` | `DOC-DRIFT-SYNC.1` | `scripts/check_memory_architecture.sh`; KM gate (pre-commit regenerate-and-stage); diff review of ROADMAP.md vs ROADMAP_V2.md | self-check exit 0; KM in sync (34 facts / 186 keys, no fact-card change); ROADMAP.md Overall=`done` + Phase 8/9 rows + long-form sections now agree with ROADMAP_V2.md; no other status changed |
| `2026-06-17` | `DOC-DRIFT-SYNC.2` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `DOC-DRIFT-SYNC.1` | `DOC-DRIFT-SYNC.1 — sync ROADMAP.md to ROADMAP_V2.md (Phase 8/9 + Overall done)` | Also creates the owning tree + registers it in docs/TASK_TREE.md (ownership-first, atomic with the first leaf per repo convention) |
| `DOC-DRIFT-SYNC.2` | `pending` | `pending` |

## Changelog

- `2026-06-17`: Created task tree (ownership-first, before any content change). Two
  leaves: `.1` ROADMAP.md Phase 8/9 + Overall status sync, `.2` formal-grammar.md
  `:&`/`:|` rule-mode fix. Frontier → `.1`.
- `2026-06-17`: `.1` done — synced `ROADMAP.md` to `ROADMAP_V2.md`. Added `## Phase 8`
  (multi-backend specification + handoff surface) and `## Phase 9` (Rust variant
  implementation; points at the active `RUST-PARITY` parity follow-on) long-form sections
  after Phase 7; inserted Phase 8 + Phase 9 Status-table rows after the Phase 7 row;
  flipped the Overall row `mostly done` → `done` (covers/remaining aligned to
  `ROADMAP_V2.md:56`). The two roadmaps now agree on Overall status and Phases 0–9.
  Committed together with the owning tree creation + `docs/TASK_TREE.md` registration
  (the commit-msg gate requires a dotted leaf id, so the repo convention is one commit
  per leaf with the tree folded into its first leaf). self-check exit 0; KM green.
  Frontier → `.2`.
