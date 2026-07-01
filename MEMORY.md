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
- latest_completed_leaf: `SPEC-FORMAT-TERSE.4.2.1` (`SPEC-FORMAT-TERSE.4.2.1 - add Perl user function registry`; hash = this commit). Ahead of origin remains below push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `SPEC-FORMAT-TERSE` — next frontier `.4.2.2`: Perl user-function value-call execution in value positions and receiver chains.
- next_action: Start `SPEC-FORMAT-TERSE.4.2.2` by resolving calls whose callee is present in the compiled function registry, after built-in/helper names stay excluded. Evaluate args eagerly in the caller context, bind exact-arity params into fresh function-local scope, evaluate the body AST, and return final-expression or `return(expr)` payload in supported value slots. Preserve `.4.2.1`: descriptor registry exists; unknown non-registered calls keep unresolved-helper diagnostics; standalone discard/purity hardening remains `.4.2.3`.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict**. **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`); clippy/source warning noise includes nested `rgx` baseline. oracle = `tools/gen_oracle_corpus.pl` → `corpus_oracle.rs` (**53 fixtures, including `tclite_*`, deep pure-helper composition, bare aggregate helper args, inline value-control if/switch, array/hash/string/number receiver-dot chains, aggregate wrapper quoted-name boundaries, block-valued receiver chains, and numeric word aliases**). phase0 baseline = **1005 green after `SPEC-FORMAT-TERSE.4.2.1`; focused AST suite PASS after `.4.2.1`; Rust core/runtime lib tests PASS after `.5.3.1`; local CI last PASS 2026-07-01 after `SPEC-FORMAT-TERSE.4.2.1`**. `s(...)`/`a(...)`/`h(...)` are retired diagnostics, not canonical wrappers. `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `RUST-PARITY.7.5.3` (recursive-grammar value parity), `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: none after `.4.2.1` commit; known unrelated local paths `rgx` and `.claude/projects/` must remain unstaged.
