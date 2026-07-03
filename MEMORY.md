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
- latest_completed_leaf: `SPEC-FORMAT-TERSE.6.2.2` (`SPEC-FORMAT-TERSE.6.2.2 - migrate shipped-spec helper spellings`; hash = this commit). Ahead of origin remains below push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `SPEC-FORMAT-TERSE` — shipped specs no longer use active `declare(...)` / `.declare(...)` or old helper spellings `assign(...)`, `push_value(...)`, `array_copy(...)`, `hash_copy(...)`, `concat(...)`; focused compile, phase0 **1018 green**, and Rust corpus oracle **66 fixtures** pass. `.6.2.3` next migrates typed wrappers/constructors where terse inference is unambiguous; `.6.2.4` final shipped-spec no-drift inventory; `.6.3` docs/corpus/examples; `.6.4` declaration compatibility policy. User backlog directive captured as `.7.1`: audit supported type methods, including string `substr()` as a receiver method.
- next_action: Pick `SPEC-FORMAT-TERSE.6.2.3`: migrate shipped-spec typed wrappers/constructors toward bare reads and direct shape literals where accepted terse inference rules make the replacement unambiguous; verify focused compile, phase0, Rust corpus oracle, and no-drift scans.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict**. **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`); clippy/source warning noise includes nested `rgx` baseline. oracle = `tools/gen_oracle_corpus.pl` (per-case fork/SIGKILL hard timeout) → `corpus_oracle.rs` (**66 fixtures, including direct-access `lispish_x_y`, `tclite_*`, `hlink_substitution` raw strings plus curly brace, deep pure-helper composition, bare aggregate helper args, inline value-control if/switch, receiver-dot chains, numeric/comparison callees, assignment expression values, and Rust/Perl user-function runtime parity**). phase0 baseline = **1018 green after `STAGED-LINKED-PARSING.5.6`; Rust focused staged prototype test PASS 2026-07-03**. `declare(...)` is retirement-bound for spec files; `s(...)`/`a(...)`/`h(...)` are retired diagnostics, not canonical wrappers; `scalaref(...)` is retired/removed; Rust numbered capture helpers are captures-only (`0` = first participating capture), while whole matches use `entry_text()`/`match_text()`. `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`. Staged parsing must stay implementation-language neutral across Perl5/Raku/Rust/Julia/Lua/Dart/Zig/Go.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: none intended after `.7.3.3.3` commit; known unrelated local paths `rgx` and `.claude/projects/` must remain unstaged.
