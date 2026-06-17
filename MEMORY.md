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
- Durable facts/decisions live in `docs/decisions/` (index: `INDEX.md`).
- Doctrine (non-negotiable): no change without an owning task-tree leaf first — see
  `docs/decisions/0001-task-tree-and-commit-doctrine.md`.
- Before committing, run `scripts/check_memory_architecture.sh` (git hooks + the local CI
  gate `tools/run_ci_local.sh` enforce it).

## Current state (OVERWRITE this block each update — do not append)
- latest_commit: `SPEC-LANG-REFERENCE.10.5.4 — book: fix worked-spec-walkthrough.md → verified 2-rule idiom; drop declare/assign` (hash backfilled by next hash-sync; ahead of origin: ~4 — push threshold ~300; do NOT push mid-PNT)
- **PIVOT (user, 2026-06-18): activated `SPEC-FORMAT-TERSE`** (terse `.spec` format). The `SPEC-LANG-REFERENCE` whole-book scorch is **PAUSED after `.10.5.4`** (remaining `.10.5.5`–`.10.5.19` deferred — the terse migration re-sweeps every book example in lockstep with the engine, so finishing the 2-rule scorch first would duplicate work).
- active_work_unit: `SPEC-FORMAT-TERSE` (was `proposed`; being activated). **next_action: `SPEC-FORMAT-TERSE.0` (ratify direction + ADR `docs/decisions/000N-spec-format-terse-direction.md`)** — design/decision only, NOT gated by the regression suite. Then the implementation leaves (`.1.x`+).
- TERSE SEMANTICS (user clarifications 2026-06-18, all consistent with the tree + KM card `spec-format-brainstorm-rounds-1-3`): `assign(x,v)`→`x = v` (op) / `set`; **no sigils** — bare typed identifiers (no `scalar()/array()/hash()` wrappers); types inferred at init or by argument position; `copy()` unifies `array_copy`/`hash_copy` (arrays + hashes); arrays/hashes/numbers/strings have **methods** (chain by return type); **everything is an expression** → everything has a typed value (control flow + `{}` blocks are expressions). Rounds 1–3 detailed in `docs/tasks/SPEC-FORMAT-TERSE.md`.
- IMPLEMENTATION GATE: terse `.1.x`+ leaves **touch the Perl reference** — a user-sanctioned exception to [[feedback_do-not-fix-reference-engine]] for this owned language evolution — and per-leaf acceptance needs the full `t/phase0_regression.t` gate, **currently HUNG by the pre-existing RTLUtils regex hang**. The tree's own directive: implement AFTER that hang is fixed + the gate is usable. So `.0` (ratify) is safe now; implementation needs the gate (fix RTLUtils first, or a scoped check) — DECISION to surface to the user.
- verify tool: private driver `/tmp/lsq_me/run.pl <spec> '<input>'` (default mode) + `/tmp/lsq_me/runpm.pl <spec> '<input>' [mode]` (mode-aware); `perl -I perl`, scalar-ref input, `JSON::PP->canonical`; reproduces `["hello-world"]`.
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (hard timeout; Perl-side) — **now gates SPEC-FORMAT-TERSE implementation leaves**. (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched).
