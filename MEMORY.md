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
- latest_commit: `SPEC-LANG-REFERENCE.3 — book: output/return-value shape contract in runtime-semantics §5 (output is author's choice; optional tagged shape)` (hash backfilled by next hash-sync; ahead of origin: ~151; push deferred, threshold ~300)
- active_work_unit: `SPEC-LANG-REFERENCE` (variant-agnostic `.spec` book-doc request; **PNT loop authorized** 2026-06-17) → frontier leaf `SPEC-LANG-REFERENCE.4` (pending). Done: `.1` audit, `.2` regex-first-class, `.3` output/return-shape (§5.5–§5.8; output = top rule's value; tagged `["?rule:",…]` shape framed as an OPTIONAL convention per user feedback; verified vs oracle corpus + live Perl run). `DOC-DRIFT-SYNC` COMPLETE. `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- next_action: `SPEC-LANG-REFERENCE.4` — add worked examples for the MAJOR/MEDIUM clarity gaps: (a) a **grouped shared-code action edge** (`-> A | B { ... }`, one block, multiple targets) in the edges chapter; (b) an **entry-vs-local-match divergence** scenario (multi-regex-slot / dispatched-child case where `entry_*` and `match_*` return different values) in the capture/lifecycle chapter. Examples must be valid against the grammar (verify by running the Perl reference, same do-not-guess discipline). `mdbook build` exit 0.
- recommendation: continue the PNT loop. `.4` needs runtime-verified examples — build + run any non-trivial `.spec` snippet through `LinkedSpec::Get` before documenting its output (the `.3` `[undef,undef,undef]` lesson). Repo handoff-ready; full plan in `docs/tasks/SPEC-LANG-REFERENCE.md`.
- queued_after: `.5` helper-catalog sweep (indexing already corrected in `.2`) → `.6` capture/mark cross-example → `.7` KM cards → `.8` finalize. Then `RUST-PARITY.7.5.3` (action-edge fluent lowering; compiler discards `.method` after a `->` edge, `compiler.rs:171`; greens tclite).
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (run phase0 with a hard timeout; Perl-side, does not gate Rust). (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched). Both want small hygiene leaves; neither gates the doc work.
