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
- latest_completed_leaf: `STAGED-LINKED-PARSING.3` (`STAGED-LINKED-PARSING.3 - specify staged parse-job annotations`; hash = this commit). Ahead of origin remains below push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `STAGED-LINKED-PARSING` — ADR `0012` defines staged linked parsing; ADR `0013` defines future spec import/composition; ADR `0014` defines future `parse_job(text_expr, options)` annotations with source-aware sidecar metadata, result policies, and failure policies. Current parsers do not yet accept those directives/helpers.
- next_action: Pick `STAGED-LINKED-PARSING.4` when this architecture track resumes: design parser registry and dynamic next-stage dispatch. If PNT returns to parity first, `RUST-PARITY.7.3` remains the active Rust frontier.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict**. **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`); clippy/source warning noise includes nested `rgx` baseline. oracle = `tools/gen_oracle_corpus.pl` → `corpus_oracle.rs` (**65 fixtures, including direct-access `lispish_x_y`, `tclite_*`, `hlink_substitution` raw strings, deep pure-helper composition, bare aggregate helper args, inline value-control if/switch, receiver-dot chains, numeric/comparison callees, assignment expression values, and Rust/Perl user-function runtime parity**). phase0 baseline = **1015 green after `SCALAREF-RETIREMENT.5`; Rust corpus oracle PASS 2026-07-02**. `s(...)`/`a(...)`/`h(...)` are retired diagnostics, not canonical wrappers; `scalaref(...)` is retired/removed; Rust numbered capture helpers are captures-only (`0` = first participating capture), while whole matches use `entry_text()`/`match_text()`. `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`. Staged parsing must stay implementation-language neutral across Perl5/Raku/Rust/Julia/Lua/Dart/Zig/Go.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: none intended after `.5` commit; known unrelated local paths `rgx` and `.claude/projects/` must remain unstaged.
