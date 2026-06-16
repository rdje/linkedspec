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
- latest_commit: `ff90634` — "MDBOOK-VARIANT-AGNOSTIC.5 — reframe DSL + compiler/architecture chapters as variant-agnostic"   (ahead of origin: ~117; push at 300)
- active_work_unit: `MDBOOK-VARIANT-AGNOSTIC` → frontier leaf: `MDBOOK-VARIANT-AGNOSTIC.6` (pending — appendix + 6 corpus walkthroughs)
- next_action: do `MDBOOK-VARIANT-AGNOSTIC.6` — per `.1` audit, the appendix is mostly LABEL (`helper-contract-catalog` is the gold standard; `runtime-semantics` + `backend-handoff` need light labels) and the **6 corpus walkthroughs** (`shipped-specs-and-corpora`, `lispish`, `ebnf`, `tablegrep`, `portmap`, `pplugin`) all share one `use LinkedSpec; my $parser = …; $parser->(\$input)` Perl driver block — reframe them uniformly (one shared "how to run a `.spec` in the reference backend" convention), keep the `ebnf` raw-Perl-action edge + `pplugin` `.plg`/`eval` content as inherent/compat. Also `development/local-ci-and-regression` (LABEL). Re-grep each page; don't trust `.1` CLEAN tags blindly. Other live frontiers: `SPEC-SPEC-SELFHOST.4`, `RUST-PARITY.5` (retv BLOCKER).
- done: `MDBOOK-VARIANT-AGNOSTIC.5` — reframed DSL + compiler/architecture chapters (4 compiler + 4 DSL frames + `owner-tree` banner; 5 pages confirmed CLEAN). Re-grep caught 3 leaks `.1` mis-tagged CLEAN (`fluent-and-block-forms`, `source-boundary-helper-reference` BACKTRACK, `action-model-and-helper-surface` "byte offset"). Reconciled stale `docs/TASK_TREE.md` index row `.2`→`.6`. `mdbook build` exit 0; self-check exit 0.
- in_flight_uncommitted: none.
- blockers: PRE-EXISTING phase0 hang (UNOWNED — needs new tree `RTLUTILS-REGEX-HANG`): `RTLUtils::add_header_n_context_clause` catastrophic-backtracks on the recursive regex `([[:alpha:]]\w+)(?:\.((?1)))?$` over comma input (`work.pkg,local.extra`); subtest `rtlutils_header_context_clause_package_owner_preserves_payload` hangs (proven via direct `require RTLUtils`, 15s timeout). `perl/RTLUtils.pm` last touched e6e8a96 (not by recent slices). Run phase0 only with a hard timeout until fixed; this also gates `SPEC-FORMAT-TERSE` (proposed).
