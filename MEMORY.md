# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL (Perl). This file is **layer A** of
`MEMORY_ARCHITECTURE.md`: the bounded, overwrite-only pointer to *now* — not a log. Its
full history lives in git (layer D); per-unit work lives in the task-trees (layer B);
durable cross-cutting facts live in `docs/decisions/` (layer C).

## How to resume
- Read `MEMORY_ARCHITECTURE.md` (the memory system — mandatory and mechanically enforced)
  and `README.md` (project objective/layout), then `SESSION_BOOTSTRAP.md`.
- Work is tracked in task-trees under `docs/tasks/` (index: `docs/TASK_TREE.md`); follow
  the commit workflow in `COMMIT.md` with the task-tree leaf id in the subject.
- Durable facts/decisions live in `docs/decisions/` (index: `INDEX.md`); fact cards in
  `docs/knowledge/` (retrieval index `KNOWLEDGE_MAP.md`).
- Doctrine (non-negotiable): no change without an owning task-tree leaf first — see
  `docs/decisions/0001-task-tree-and-commit-doctrine.md`.
- Before committing, run `scripts/check_memory_architecture.sh` (git hooks + the local CI
  gate `tools/run_ci_local.sh` enforce it).

## Current state (OVERWRITE this block each update — do not append)
- latest_commit: `PHASE0-BACKHALF-TRIAGE.1 — read-only triage complete` (hash backfilled by next hash-sync; ahead of origin ~12 — push threshold ~300; do NOT push mid-PNT). Prior: `f9c34fe` (WIP triage+trace), `2baddbd` (NONCORE-QUARANTINE.3+.4).
- active_work_unit: `PHASE0-BACKHALF-TRIAGE` (current focus). **`.1` read-only triage DONE**: 173 failing phase0 subtests → **108 STALE (re-bless) / 65 REAL (engine-fix), 2 engine defects.** STALE: A parser-collection-shape (8), B `method_like` (75, retired `return_*`/`RETURN_A` nodes), C `emit_context` (20, removed `Deps::*` seams), F migration-summary (3), G singles (2) — all assert intentionally-retired behavior; engine is correct.
- REAL **Defect #1 — AND-rule action-codegen** (63): multi-edge AND (`-> Rule[0..N]`) with a `return(...)` edge emits `SCALAR(0x…)Rule` ⇒ compile-fail (top rule, `near ")Top"`) / dropped payload `[]` (child rule). Per-edge helper lowering is fine; bug is the AND-branch emitter (`HandlerVariantEmitter`/`SpecEntry`). See [[and-return-edge-codegen-defect]]. REAL **Defect #2 — input-boundary regression** (2): `Runtime.pm:~126` wrapper derefs before the SCALAR-ref guard (commit `d7294d0`). See [[runtime-input-boundary-validation-regression]].
- next_action: **get user OK to touch the reference engine** for `.3` (AND-codegen) + `.4` (input-boundary), then fix; `.2.x` re-bless the 108 stale (independent of the engine touch); `.5` verify green phase0 (incl. the unobserved 881–959 tail). See `docs/tasks/PHASE0-BACKHALF-TRIAGE.md`.
- TRACE-OBSERVABILITY (active, user directive 2026-06-19): discoverable CLI trace control + comprehensive "see everything" trace. Framework EXISTS (`Trace.pm`; env `LINKEDSPEC_TRACE_LEVEL=debug` works; bare `$DUMP_VERBOSITY` set does NOT). Gaps: undiscoverable (no `--trace`/bin/docs) + coverage not exhaustive. `.2` (CLI+docs) = quick win. See `docs/tasks/TRACE-OBSERVABILITY.md`.
- SPEC-FORMAT-TERSE (gated until phase0 green): `.0` done (ADR `0007`); migration = gradual-alias; book scorch PAUSED. Reference-touching = sanctioned exception to [[feedback_do-not-fix-reference-engine]].
- verify: `perl -c perl/LinkedSpec.pm` OK; phase0 = 173 fail/707 pass (deterministic), reached 880/959 before the background run was terminated (exit 144 mid-881 — re-confirm 881–959 in `.5`). TAP: `/tmp/phase0_triage.tap` (transient).
- blockers: (1) **65 REAL phase0 failures = 2 reference-engine defects** (AND-codegen + input-boundary) — gates green phase0 + `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` + `NONCORE-QUARANTINE.V`; `.3`/`.4` blocked on user OK to touch `perl/`. (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`).
