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
- latest_completed_leaf: `RUST-PARITY.7.3.6` (`RUST-PARITY.7.3.6 - land legacy shipped-spec safety smokes`; hash = this commit). Ahead of origin remains below push threshold ~300; do NOT push mid-PNT.
- active_work_unit: `RUST-PARITY`; `SPEC-FORMAT-TERSE` declaration-retirement `.6` and type-method `.7` lanes are closed, with no pending terse leaf. `.7.3.6` landed seven RTL/plugin/legacy safety smokes and recorded richer pplugin/tkgui/sdce/tablegrep/simenv/vhdl/ds_vhistory/verilog mismatches for follow-up instead of broadening the leaf.
- next_action: Pick `RUST-PARITY.7.4`: regression guard + finalize the oracle corpus, unless a new higher-priority task-tree leaf is explicitly split.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict**. **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`); clippy/source warning noise includes nested `rgx` baseline. oracle = `tools/gen_oracle_corpus.pl` (per-case fork/SIGKILL hard timeout) → `corpus_oracle.rs` (**88 fixtures, including `regdef_nested_register_fields`, `tablegrep_simple_term`, `simenv_multiline_value`, `vhdl_library_use`, `ds_vhistory_version_entry`, `pplugin_empty`, `tkgui_empty`, `spec_spec_*`, `portmap_concatenation`, `ebnf_expression_rules`, `ebnf_logging_annotation`, `terse_7_3_array_numeric_reducer_receiver_methods`, `terse_6_2_3_1_scalar_slot_shorthand`, direct-access `lispish_x_y`, `tclite_*`, `hlink_substitution` raw strings plus curly brace, `lib_reader_sattribute`/`lib_reader_cattribute`, `portmap_bare`/`portmap_bit`/`portmap_slice`/`portmap_constant`, deep pure-helper composition, bare aggregate helper args, inline value-control if/switch, receiver-dot chains, numeric/comparison callees, assignment expression values, and Rust/Perl user-function runtime parity**). phase0 baseline = **1021 green**. `declare(...)` is retirement-bound for spec files; `s(...)`/`a(...)`/`h(...)` are retired diagnostics, not canonical wrappers; `scalaref(...)` is retired/removed; authored specs use `:name` for scalar slots and `LHS = RHS`/`set(...)` for assignment; backend Perl may still contain Perl built-ins such as `scalar(@...)`. Rust numbered capture helpers are captures-only (`0` = first participating capture), while whole matches use `entry_text()`/`match_text()`. `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`. Staged parsing must stay implementation-language neutral across Perl5/Raku/Rust/Julia/Lua/Dart/Zig/Go.
- deferred-tracked: `ROADMAP-DRIFT-RECONCILE` (`.1` ROADMAP.md, `.2` ARCHITECTURE_STATE.md) — parked behind the terse track (user "defer"). Other lanes: `TRACE-OBSERVABILITY`, `DOCTRINE-ENFORCEMENT-ADOPT.3`; `TOP-RULE-AS-NORMAL.3.2` blocked on `RUST-PARITY`.
- blockers: NONE PNT-eligible-blocking. in_flight_uncommitted: none after this commit; known unrelated local paths `rgx` and `.claude/projects/` must remain unstaged.
