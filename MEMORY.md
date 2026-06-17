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
- latest_commit: `SPEC-LANG-REFERENCE.1 — audit: full .spec surface inventory + book coverage map; decompose into .2-.8` (hash backfilled by next hash-sync; ahead of origin: ~149; push deferred, threshold ~300)
- active_work_unit: `SPEC-LANG-REFERENCE` (the user's comprehensive variant-agnostic `.spec` book-doc request) → frontier leaf `SPEC-LANG-REFERENCE.2` (pending). `.1` audit done (8/10 surface areas already well-covered; full inventory + gap→leaf map in the tree's "Audit Findings"). `DOC-DRIFT-SYNC` COMPLETE. `RUST-PARITY` (frontier `.7.5.3`) stays active, resumes after this doc tree.
- next_action: `SPEC-LANG-REFERENCE.2` — document **regex in `.spec` as a first-class concept** (CRITICAL gap): `/pattern/` syntax + delimiter escaping, multi-cluster ordered-sequence model, capture-group ↔ `entry_group(N)`/`match_group(N)`/`entry_named(name)` indexing, and a **verified** statement of the regex feature set a backend must support — VERIFY against `perl/LinkedRE.pm` + the rgx engine before asserting (do not guess). New `user-model` chapter and/or expanded `appendix/formal-grammar.md`; many examples; `mdbook build`. Then `.3` output/return-shape contract (ground in `docs/knowledge/rust-perl-output-oracle.md`), `.4`–`.6` example/neutrality gaps, `.7` KM cards, `.8` finalize.
- recommendation: a FRESH SESSION is advised before `.2` — the gap-filling leaves are meaty signoff-quality book writing with abundant examples, and this session is long. Repo is handoff-ready; the full plan is committed in `docs/tasks/SPEC-LANG-REFERENCE.md`.
- queued_after: `RUST-PARITY.7.5.3` — action-edge fluent lowering (`-> Child .push`/`.return(...)`); compiler discards `.method` after a `->` edge (`compiler.rs:171`); greens tclite.
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (run phase0 with a hard timeout; Perl-side, does not gate Rust). (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched). Both want small hygiene leaves; neither gates the doc work.
