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
- latest_completed_leaf: `PERL-ACTIONIR-AST-MIGRATION.4.4.3` (`PERL-ACTIONIR-AST-MIGRATION.4.4.3 - lower switch controls from AST`; hash pending commit). Previous HEAD before this slice: `4002f05`. Ahead of origin remains below push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `PERL-ACTIONIR-AST-MIGRATION` — `.4.4.4` is next: lower `while` statement forms from typed condition/body nodes while preserving the existing iteration-safety guard.
- next_action: Start `PERL-ACTIONIR-AST-MIGRATION.4.4.4` by marking the leaf in progress before code, then route while attached-body lowering through typed control nodes without changing generated guard behavior. User-defined functions remain queued and must use the AST path; final `fn <name>(...) { ... }` grammar belongs in `specs/spec.spec`, and any bootstrap-parser `fn` support is temporary migration debt to remove after text-to-AST carries the surface. Keep `SPEC-FORMAT-TERSE.3.2.2`/`.3.2.3` and `SPEC-FORMAT-TERSE.3.3` queued behind the user-directed AST/function run; do not start Julia/Dart backend code without a dedicated owning backend leaf/tree; do not start Lua backend work without an accepted decision record.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict**. **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`); clippy/source warning noise includes nested `rgx` baseline. oracle = `tools/gen_oracle_corpus.pl` → `corpus_oracle.rs` (**53 fixtures, including `tclite_*`, deep pure-helper composition, bare aggregate helper args, inline value-control if/switch, array/hash/string/number receiver-dot chains, aggregate wrapper quoted-name boundaries, block-valued receiver chains, and numeric word aliases**). phase0 baseline = **1002 green after `PERL-ACTIONIR-AST-MIGRATION.4.4.3`; local CI last PASS 2026-07-01 after `.4.4.3`**. `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `RUST-PARITY.7.5.3` (recursive-grammar value parity), `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: `.4.4.3` switch-control AST lowering code/tests/docs/KM until commit; known unrelated local paths `rgx` and `.claude/projects/` must remain unstaged.
