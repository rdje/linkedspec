# ROADMAP-DRIFT-RECONCILE: Reconcile ROADMAP.md / ARCHITECTURE_STATE.md drift with current state

## Metadata

- Tree ID: `ROADMAP-DRIFT-RECONCILE`
- Status: `active` (`.1` done 2026-07-08 after user `PNT` reactivated the previously deferred
  lane; `.2` is the current frontier)
- Roadmap lane: `Overall roadmap — documentation and book sync`
- Created: `2026-06-23`
- Last updated: `2026-07-08`
- Owner: repo-local workflow

## Goal

Close the zero-drift gap (doctrine ADR `0001` §4) between the long-form `ROADMAP.md` (and, to a
lesser degree, `ARCHITECTURE_STATE.md`) and the current codebase + task-tree state. A 2026-06-23
session-bootstrap drift audit (ROADMAP.md read in full) found `ROADMAP.md` has diverged from
`ROADMAP_V2.md` and the tree ledger on several points; this tree owns the reconciliation so the
finding survives and can be picked up cleanly later. `ROADMAP_V2.md` is current; `ROADMAP.md` is
the stale long-form companion.

## Non-Goals

- Re-litigating any settled roadmap direction — this is a faithfulness/sync pass, not a re-plan.
- Touching the codebase. This tree is documentation-reconciliation only.
- Rewriting `ROADMAP_V2.md` (it is already current) except where the doctrine "update both in the
  same slice" applies to a specific shared statement.

## Acceptance Criteria

- `ROADMAP.md` no longer contradicts `ROADMAP_V2.md` / the task-tree on the items in `.1` below.
- `ARCHITECTURE_STATE.md` dated header + status counts are refreshed to current (`.2`).
- `scripts/check_memory_architecture.sh` + the KM gate pass; `bash tools/run_ci_local.sh` EXIT 0
  (these are doc-only changes — phase0 unaffected, but the gate must stay green).
- Each completed leaf is committed through `COMMIT.md` with the leaf id in the subject.

## Task Tree

- ID: `ROADMAP-DRIFT-RECONCILE`
  Status: `active`
  Goal: Reconcile `ROADMAP.md` / `ARCHITECTURE_STATE.md` drift with the current state
  Children: `.0`, `.1`, `.2`

- ID: `ROADMAP-DRIFT-RECONCILE.0`
  Status: `done`
  Goal: Create + register this tracking tree so the 2026-06-23 drift finding is OWNED (not fixed)
  Acceptance: `docs/tasks/ROADMAP-DRIFT-RECONCILE.md` exists with the drift transcribed + leaves
    `.1`/`.2` defined; an Active Task Trees row is registered in `docs/TASK_TREE.md` with the
    deferral note; continuity docs updated; the doctrine driver + KM gate pass via the pre-commit
    hook. Tracking-only — no code/book/roadmap-content/KM-card change.
  Verification: Done — 2026-06-23/24. Tree authored from `docs/tasks/TEMPLATE.md`; index row added;
    `scripts/check_memory_architecture.sh` + `scripts/check_doctrines.sh` (2/2 PASS) + KM gate green
    via the pre-commit hook (KM map auto-regenerated: 46 facts / 276 keys, no card added). phase0
    baseline 965/965 + `bash tools/run_ci_local.sh` EXIT 0 confirmed on the pre-slice tree.
  Commit: `ROADMAP-DRIFT-RECONCILE.0` (see Commit Log)

- ID: `ROADMAP-DRIFT-RECONCILE.1`
  Status: `done`
  Goal: Reconcile `ROADMAP.md` long-form drift with the current state
  Acceptance: `ROADMAP.md` is updated so it (a) names the active `SPEC-FORMAT-TERSE` tree and the
    terse `.spec` format direction (ADR `0007`); (b) stops presenting `declare(...)` as the
    permanent required form — notes the current terse contract uses auto-existing working variables,
    assignments, type-implying helper positions, and explicit aggregate views; (c) records the
    `LEGACY-VHDL-RETIRE` deletion (RTLUtils/FSMGen/VHDL::ConstantEval + 6 `.plg`) and the
    `NONCORE-QUARANTINE` relocation of the remaining domain owners + 13 `.plg` to `noncore/`
    (root `plugin/` gone; `perl/` core-only except `PPlugin.pm` compatibility); (d) updates the
    Phase 0 baseline to the current `t/phase0_regression.t` count (`PASS 1..1026`) rather than a
    generic "all specs compile"; (e)
    states the `.spec` = single universal contract / Perl = reference / Rust+Julia+Dart = lockstep
    variants model. Doctrine "update both roadmaps in the same slice" honored for any shared
    statement. Gate EXIT 0.
  Verification: Done — 2026-07-08. `ROADMAP.md` now names `SPEC-FORMAT-TERSE` / ADR `0007`,
    current terse authoring, 21 shipped specs, phase0 `PASS 1..1026`, 95 Rust oracle fixtures,
    `LEGACY-VHDL-RETIRE`, `NONCORE-QUARANTINE`, `noncore/plugin`'s 13 `.plg`, root `plugin/`
    removal, and the Perl reference / Rust implemented / Julia+Dart future variant model. No
    parser/runtime/mdBook behavior changed. `bash tools/run_ci_local.sh` passed.
  Commit: `ROADMAP-DRIFT-RECONCILE.1 - reconcile long-form roadmap drift`

- ID: `ROADMAP-DRIFT-RECONCILE.2`
  Status: `pending`
  Goal: Refresh `ARCHITECTURE_STATE.md` dated header + status counts to current
  Acceptance: `ARCHITECTURE_STATE.md` "Last refreshed" header + Status block reflect work since
    `2026-06-14` (the `LEGACY-VHDL-RETIRE` / `NONCORE-QUARANTINE` retirements, `TOP-RULE-AS-NORMAL`,
    `SPEC-FORMAT-TERSE` progress) and the current phase0 count (`PASS 1..1026`). The architectural
    *model* in the body is re-read and corrected only where a new deep reading changed the best
    model (much of it is still accurate). Gate EXIT 0.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `ROADMAP-DRIFT-RECONCILE.1` | `done` | Closed 2026-07-08 after user `PNT` reactivated the previously deferred lane. |
| 2 | `ROADMAP-DRIFT-RECONCILE.2` | `pending` | Next PNT slice: refresh `ARCHITECTURE_STATE.md` header/status counts to current. |

## Decisions

- `2026-06-23`: **Created to own a deferred reconciliation.** During session bootstrap, a full read
  of `ROADMAP.md` (1266 lines) against `ROADMAP_V2.md` + the tree ledger + decision records found
  drift (declare-required wording, no terse-format mention, missing `LEGACY-VHDL-RETIRE` /
  `NONCORE-QUARANTINE` / `noncore/`, stale Phase 0 baseline, Rust-only multi-backend framing). The
  user chose **"Defer — track as a new leaf"** (AskUserQuestion, 2026-06-23): track the drift now,
  fix it later, and do **not** interrupt the signoff-critical `SPEC-FORMAT-TERSE.1.1.1` engine
  change. So this tree exists for continuity; its leaves stay `pending`-but-deferred behind the
  active terse track and are not in the immediate PNT frontier.
- `2026-06-23`: Scope limited to `ROADMAP.md` (the stale long-form companion) and
  `ARCHITECTURE_STATE.md`; `ROADMAP_V2.md` is already current and is the canonical execution view.
- `2026-07-08`: User `PNT` reactivated the previously deferred lane now that `SPEC-FORMAT-TERSE.14`
  is closed and no terse leaf is PNT-eligible. `.1` was selected first because the long-form roadmap
  had the broadest stale public-status surface; `.2` remains the next architecture-state refresh.

## Open Questions

- None blocking. (Whether `ARCHITECTURE_STATE.md` also warrants a deeper body re-model is decided
  inside `.2` when it is picked up.)

## Blockers

- None (the deferral is a priority choice, not a blocker — the leaves are doable now if activated).

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-23` | `ROADMAP-DRIFT-RECONCILE.0` | Tree authored from `docs/tasks/TEMPLATE.md`; drift findings transcribed from the 2026-06-23 bootstrap audit; index row registered; doctrine driver (2/2) + KM gate green via pre-commit hook | Tracking-only — no code/book/roadmap content changed in this slice; phase0 965 unaffected |
| `2026-07-08` | `ROADMAP-DRIFT-RECONCILE.1` | Filesystem/status checks for shipped specs, `noncore/plugin`, root `plugin/`, Perl core modules, Rust corpus manifest; focused stale-wording scans; `git diff --check`; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `bash tools/run_ci_local.sh` | PASS — local CI includes phase0 `1..1026`; no parser/runtime/mdBook behavior changed |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `ROADMAP-DRIFT-RECONCILE.0` | `ROADMAP-DRIFT-RECONCILE.0 — create tree to own deferred ROADMAP.md/ARCHITECTURE_STATE.md drift (tracking-only)` | Tracking-only; leaves `.1`/`.2` deferred behind `SPEC-FORMAT-TERSE` per user 2026-06-23. |
| `ROADMAP-DRIFT-RECONCILE.1` | `ROADMAP-DRIFT-RECONCILE.1 - reconcile long-form roadmap drift` | Long-form `ROADMAP.md` reconciliation; `.2` remains next. |

## Changelog

- `2026-06-23`: Created task tree to own the deferred `ROADMAP.md` / `ARCHITECTURE_STATE.md` drift
  reconciliation surfaced during session bootstrap. Leaves `.1` + `.2` parked `pending`-deferred
  behind the active `SPEC-FORMAT-TERSE` track (user decision: "Defer — track as a new leaf").
- `2026-07-08`: User `PNT` reactivated the lane; `.1` reconciled `ROADMAP.md` with current terse
  format, phase0, Rust oracle, noncore/plugin, and variant-model state. Frontier advances to `.2`.
