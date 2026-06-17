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
- latest_commit: `SPEC-LANG-REFERENCE.5.2 — book: compile-verified worked examples for all Scalar + Numeric helpers (helper-contract-catalog §2/§5)` (hash backfilled by next hash-sync; ahead of origin: ~154; push deferred, threshold ~300)
- active_work_unit: `SPEC-LANG-REFERENCE` (variant-agnostic `.spec` book-doc request; **PNT loop authorized** 2026-06-17) → frontier leaf `SPEC-LANG-REFERENCE.9` (pending). Done: `.1`–`.4`, `.5.1`, `.5.2` (35 Scalar+Numeric helper examples, each run-verified vs the oracle). `DOC-DRIFT-SYNC` COMPLETE. `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- next_action: `SPEC-LANG-REFERENCE.9` — correct the drifted §5.5 `runtime-semantics.md` Pair example (the `Pair::AND … -> Pair[0]` form returns `[]`, NOT the documented `["?pair:","key","val"]`; the tagged array needs the OR self-ref form `Pair:: … -> Pair { return(array(…)) }`). Re-verify the corrected snippet through `LinkedSpec::Get`; sweep §5.5/§5.6 for the same AND-`[N]`-self-edge drift; `mdbook build` exit 0. (Discovered during `.5.2`; no-drift priority.)
- key facts (`.5.2`): verified doc scaffold is `Demo:: /<re>/ -> Demo { return(<expr>) }` (bare-`::` OR self-ref edge surfaces the return value as top-level output). `is_defined`/`is_undefined` are **condition-only** (lower via `ActionIR/FlowExpr.pm`; `return(is_defined(x))` dies). `split→num_sum` does NOT compose (returns `null`) — array-form reducers use explicit `array(...)`. Candidates for KM cards in `.7`.
- queued_after: `.5.3` Array → `.5.4` Hash+Control Flow → `.5.5` remaining families (closes `.5`) → `.6` capture/mark cross-example → `.7` KM cards → `.8` finalize. Then `RUST-PARITY.7.5.3`.
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (run phase0 with a hard timeout; Perl-side, does not gate Rust). (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched). Both want small hygiene leaves; neither gates the doc work.
