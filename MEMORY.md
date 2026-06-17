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
- latest_commit: `SPEC-LANG-REFERENCE.2 — book: regex as a first-class concept (new user-model chapter) + fix capture-indexing drift` (hash backfilled by next hash-sync; ahead of origin: ~150; push deferred, threshold ~300)
- active_work_unit: `SPEC-LANG-REFERENCE` (the user's comprehensive variant-agnostic `.spec` book-doc request) → frontier leaf `SPEC-LANG-REFERENCE.3` (pending). `.1` audit + `.2` regex-first-class done (`.2`: new `user-model/regex-in-spec.md`, verified vs `LinkedRE.pm`/`Contracts.pm`/rgx/shipped specs; fixed a capture-indexing contradiction across 3 book files). `DOC-DRIFT-SYNC` COMPLETE. `RUST-PARITY` (frontier `.7.5.3`) stays active, resumes after this doc tree.
- next_action: `SPEC-LANG-REFERENCE.3` — document the **output/return-value shape contract** (CRITICAL gap B) in `appendix/runtime-semantics.md`: what a `.spec` parser returns (top rule's value), the implicit accumulator model, the canonical one-level wrap, the tagged-shape convention `["?rule:", [...]]`, and how `return(...)` interacts with the accumulator — GROUND in `docs/knowledge/rust-perl-output-oracle.md` + shipped specs, with worked input→output examples (no corpus reverse-engineering). `mdbook build` exit 0.
- recommendation: continue leaf-by-leaf. `.3` is meaty — verify the output shape against the oracle KM card + shipped specs before asserting (same do-not-guess discipline as `.2`). Repo is handoff-ready; full plan in `docs/tasks/SPEC-LANG-REFERENCE.md`.
- queued_after: `.4` grouped-target + entry-vs-local-match examples → `.5` helper-catalog sweep (indexing contract already corrected in `.2`) → `.6` capture/mark cross-example → `.7` KM cards → `.8` finalize. Then `RUST-PARITY.7.5.3` (action-edge fluent lowering; compiler discards `.method` after a `->` edge, `compiler.rs:171`; greens tclite).
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (run phase0 with a hard timeout; Perl-side, does not gate Rust). (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched). Both want small hygiene leaves; neither gates the doc work.
