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
- latest_completed_leaf: `RUST-PARITY.7.3.2` (`RUST-PARITY.7.3.2 - harden oracle timeout guard`; hash = this commit). Ahead of origin remains below push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `RUST-PARITY` — `.7.3.2` verified the historic `RTLUtils` timeout is retired from current core and changed `tools/gen_oracle_corpus.pl` to enforce `ORACLE_TIMEOUT` with per-case fork/SIGKILL instead of `alarm()`. `.7.3.3` tries remaining `hlink_substitution` delimiter/link-path fixtures; `.7.3.4` triages `portmap`/`lib_reader`/`ebnf`; `.7.3.5` triages `BNF`/`DT`/`ifelse`/`operators_try`/`spec.spec`; `.7.3.6` audits RTL/plugin/legacy candidates with the hardened timeout guard. Staged linked parsing first prototype is complete; broader public staged surfaces remain future work.
- next_action: Pick `RUST-PARITY.7.3.3`: author/probe remaining non-raw `hlink_substitution` delimiter/link-path inputs under the hardened oracle generator, keep only green fixtures if Rust matches Perl, or record exact divergence and split a narrower implementation owner before runtime changes.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict**. **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`); clippy/source warning noise includes nested `rgx` baseline. oracle = `tools/gen_oracle_corpus.pl` (per-case fork/SIGKILL hard timeout) → `corpus_oracle.rs` (**65 fixtures, including direct-access `lispish_x_y`, `tclite_*`, `hlink_substitution` raw strings, deep pure-helper composition, bare aggregate helper args, inline value-control if/switch, receiver-dot chains, numeric/comparison callees, assignment expression values, and Rust/Perl user-function runtime parity**). phase0 baseline = **1018 green after `STAGED-LINKED-PARSING.5.6`; Rust focused staged prototype test PASS 2026-07-03**. `s(...)`/`a(...)`/`h(...)` are retired diagnostics, not canonical wrappers; `scalaref(...)` is retired/removed; Rust numbered capture helpers are captures-only (`0` = first participating capture), while whole matches use `entry_text()`/`match_text()`. `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`. Staged parsing must stay implementation-language neutral across Perl5/Raku/Rust/Julia/Lua/Dart/Zig/Go.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: none intended after `.7.3.2` commit; known unrelated local paths `rgx` and `.claude/projects/` must remain unstaged.
