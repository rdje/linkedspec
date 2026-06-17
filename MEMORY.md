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
- latest_commit: `SPEC-LANG-REFERENCE.5.1 — helper-catalog audit: 0 completeness gaps, fix 2 variant-neutrality sigil leaks, decompose example work into .5.2-.5.5` (hash backfilled by next hash-sync; ahead of origin: ~153; push deferred, threshold ~300)
- active_work_unit: `SPEC-LANG-REFERENCE` (variant-agnostic `.spec` book-doc request; **PNT loop authorized** 2026-06-17) → frontier leaf `SPEC-LANG-REFERENCE.5.2` (pending). Done: `.1`–`.4`, `.5.1` (catalog audit: 0 public-API gaps; 2 sigil leaks fixed; `.5` split into per-family example sub-leaves `.5.2`–`.5.5`). `DOC-DRIFT-SYNC` COMPLETE. `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- next_action: `SPEC-LANG-REFERENCE.5.2` — add worked examples for the **Scalar + Numeric** helper families to `appendix/helper-contract-catalog.md` (the catalog has 0 `.spec` examples today): ≥1 per family + several for high-frequency helpers (`trim`/`concat`/`coalesce`/`num_add`/`num_sum`/…). **Compile-verify every example through `LinkedSpec::Get` before asserting behavior** (do-not-guess; the `.4` accumulator lesson). `mdbook build` exit 0.
- recommendation: **a FRESH SESSION is advised before `.5.2`** — `.5.2`–`.5.5` are a large, repetitive, compile-verify-each example push (~140 helpers, currently 0 examples), best done with fresh focus to hold the signoff bar. Repo is handoff-ready; full per-family plan committed in `docs/tasks/SPEC-LANG-REFERENCE.md`. 4 leaves (`.2`,`.3`,`.4`,`.5.1`) committed this session.
- queued_after: `.5.3` Array → `.5.4` Hash+Control Flow → `.5.5` remaining families (closes `.5`) → `.6` capture/mark cross-example → `.7` KM cards → `.8` finalize. Then `RUST-PARITY.7.5.3`.
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (run phase0 with a hard timeout; Perl-side, does not gate Rust). (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched). Both want small hygiene leaves; neither gates the doc work.
