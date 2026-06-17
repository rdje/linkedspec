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
- latest_commit: `SPEC-FORMAT-TERSE — design: call-syntax open question + my recommendation; record portability principle + RTLUtils retire-direction` (hash backfilled by next hash-sync; ahead of origin: ~6 — push threshold ~300; do NOT push mid-PNT)
- **PIVOT (user, 2026-06-18): activated `SPEC-FORMAT-TERSE`** (terse `.spec` format). `.0` done (ADR `0007`). Migration policy RESOLVED = **gradual alias** (user). The `SPEC-LANG-REFERENCE` whole-book scorch is **PAUSED** (terse migration re-sweeps the book in lockstep).
- active_work_unit: `SPEC-FORMAT-TERSE` (current focus; still in a live design conversation — see the call-syntax Open Question + my recommendation in the tree). **next_action: own a RETIREMENT tree for the Perl-only legacy VHDL subsystem (RTLUtils + FSMGen + `VHDL/ConstantEval`) — read-only feasibility/inventory leaf first; CONFIRM removal scope with the user before deleting.** This **supersedes** the earlier "fix `RTLUTILS-REGEX-HANG`" answer: retiring it (per [[feedback_keep-only-portable-cross-variant]]) also clears the phase0 hang + sheds ~4,400 Perl-only lines. Then the gate is usable → terse `.1.x` leaves.
- TERSE SEMANTICS (user clarifications 2026-06-18, all consistent with the tree + KM card `spec-format-brainstorm-rounds-1-3`): `assign(x,v)`→`x = v` (op) / `set`; **no sigils** — bare typed identifiers (no `scalar()/array()/hash()` wrappers); types inferred at init or by argument position; `copy()` unifies `array_copy`/`hash_copy` (arrays + hashes); arrays/hashes/numbers/strings have **methods** (chain by return type); **everything is an expression** → everything has a typed value (control flow + `{}` blocks are expressions). Rounds 1–3 detailed in `docs/tasks/SPEC-FORMAT-TERSE.md`.
- DESIGN CONVERSATION (open, user steering 2026-06-18): call-syntax for op/comparison functions — my rec = uniform `callee(args)`, word canonical (`ge(a,b)`) + symbol alias (`>=(a,b)`), NO `(op a,b)` Lisp form (Open Question in the tree; ratify in `.3.2`). Op-functions return typed values with chainable methods; type may change in the chain. Semicolons mandatory between same-line statements (already `.1.5`).
- IMPLEMENTATION GATE: terse `.1.x`+ leaves **touch the Perl reference** — a user-sanctioned exception to [[feedback_do-not-fix-reference-engine]] for this owned evolution — and need the full `t/phase0_regression.t` gate, **HUNG by the RTLUtils catastrophic regex**. Unblock = **RETIRE** the Perl-only legacy VHDL subsystem (RTLUtils/FSMGen/VHDL) per [[feedback_keep-only-portable-cross-variant]] (also sheds ~4,400 lines), NOT fix the regex — confirm removal scope first.
- verify tool: private driver `/tmp/lsq_me/run.pl <spec> '<input>'` (default mode) + `/tmp/lsq_me/runpm.pl <spec> '<input>' [mode]` (mode-aware); `perl -I perl`, scalar-ref input, `JSON::PP->canonical`; reproduces `["hello-world"]`.
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (hard timeout; Perl-side) — **now gates SPEC-FORMAT-TERSE implementation leaves**. (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched).
