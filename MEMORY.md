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
- latest_completed_leaf: `SCALAREF-RETIREMENT.1` (`SCALAREF-RETIREMENT.1 - own scalaref retirement track`; hash = this commit). Ahead of origin remains below push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `SCALAREF-RETIREMENT` — `.1` is done: the user directive that `scalaref(...)` shall be retired/removed is owned and split with no behavior change. `RUST-PARITY.7.5.2` remains the committed parity fix for current Lispish behavior.
- next_action: Pick `SCALAREF-RETIREMENT.2` next: inventory every `scalaref(...)` use and select the canonical replacement before changing specs, docs, parser, compiler, or runtime behavior. `RUST-PARITY.7.2` remains pending after/behind the retirement inventory decision.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict**. **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`); clippy/source warning noise includes nested `rgx` baseline. oracle = `tools/gen_oracle_corpus.pl` → `corpus_oracle.rs` (**63 fixtures, including `tclite_*`, `lispish_x_y`, deep pure-helper composition, bare aggregate helper args, inline value-control if/switch, array/hash/string/number receiver-dot chains, aggregate wrapper quoted-name boundaries, block-valued receiver chains, numeric word aliases, arithmetic/comparison symbol callees, explicit string-comparison helpers, scalar/aggregate/mutation/closure assignment expression values, and Rust/Perl user-function runtime parity**). phase0 baseline = **1015 green after `SPEC-FORMAT-TERSE.3.3.4`; full local CI PASS 2026-07-02**. `s(...)`/`a(...)`/`h(...)` are retired diagnostics, not canonical wrappers; `scalaref(...)` is removal-bound under `SCALAREF-RETIREMENT`; Perl-shaped hash literal spelling is also legacy compatibility debt. `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: none intended after `.1` commit; known unrelated local paths `rgx` and `.claude/projects/` must remain unstaged.
