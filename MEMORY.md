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
- latest_completed_leaf: `SPEC-FORMAT-TERSE.15.2.2` (Perl bare-read completion) — ONE change to `ActionIR::FlowExpr::_lower_flow_composite_expr` (bare ident at `passthrough_no_call` → `$name` variable read, mirroring the `:name` branch) closed all 3 value-position gaps at once (if/elsif/while + `num_*` + logical delegate to it; switch selector funnels through it). CHANGE 2 in `ControlFlow::_lower_switch_case_value_expr` keeps a bare switch CASE LABEL a literal tag (hash-key-analogous exemption, ADR `0019`): `switch(kind)` reads var, `case(foo)` matches `"foo"`. Probes: switch/num/if bare == `:name`; `:name` still compat. FULL phase0 GREEN (reach `ok 1022`, 1021 pass, only pre-existing `not ok 796`); zero regressions.
- latest_commit: `SPEC-FORMAT-TERSE.15.2.2` workflow commit pending; previous `5a59b719` (`.15.2.1`). **~306 commits ahead of origin — OVER the documented 300 push threshold (LIVE_ACHIEVEMENT_STATUS); still do NOT push mid-PNT unless explicitly instructed.**
- active_work_unit: `SPEC-FORMAT-TERSE.15.2.3` (Rust parity) — make Rust `Expr::Variable` read the bound scalar in value/condition/selector/`num_*`-arg positions to match Perl `.15.2.2`; `Expr::ScalarSlot`→`get_scalar` stays compat; keep switch case labels literal. Then `.15.2.4` source migration (output-preserving), then `.15.3`/`.15.4` remove `:name` ENTIRELY (no compat; user directive), `.15.5` closeout.
- next_action: Start `SPEC-FORMAT-TERSE.15.2.3`. Rust seams: bare→`Expr::Variable` (`rust/linkedspec-core/src/expr.rs:1350`; selector test `:1788`), `:name`→`Expr::ScalarSlot`→`ctx.get_scalar` (`rust/linkedspec-runtime/src/engine.rs:3287`). FIRST probe whether Rust `Expr::Variable` ALREADY reads the scalar in switch/if/num positions (it may — interpreter auto-vivifies); only change what's needed. Keep `case(foo)` label literal (mirror Perl). Prove via regenerated Rust oracle corpus (`tools/gen_oracle_corpus.pl` in background) + `cargo test` corpus_oracle + the same discriminating cases.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → always `perl -Iperl`; **run phase0 with `PERL5LIB=` cleared** or subprocess tests (e.g. 102 pplugin lazy-load) fail on the stale checkout. Full phase0 needs the **10-min timeout** (`timeout:600000`), else it caps mid-run (exit 144/143). **Generated Perl handlers are NON-strict.** **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`). Baseline phase0 = **1021 pass / 1 pre-existing unrelated fail** (test 796 `emit_context_lowers_split_tagged_records_helper`). oracle = `tools/gen_oracle_corpus.pl` (per-case fork/SIGKILL; ~90 fixtures → **run in background**; `manifest.json` + drift guards). `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`. Rust numbered capture helpers are captures-only (`0`=first capture); whole match = `entry_text()`/`match_text()`.
- noise / deferred: `rgx` (submodule pointer) + `.claude/projects/` are untracked local noise — keep UNSTAGED. `docs/tasks/TRACE-OBSERVABILITY.md` stale-commit-hash edit is unowned noise (not this slice). Deferred lanes behind `.15`: `.8` (legacy-helper removal), `.9` (hash `=>`→`:`), `.10`/`.12`/`.13`/`.14` backlog; `ROADMAP-DRIFT-RECONCILE`, `DOCTRINE-ENFORCEMENT-ADOPT.3`, `SPEC-LANG-REFERENCE`.
- blockers: none for ownership. in_flight_uncommitted: this `.15.2` re-scope planning slice (task-tree + ADR `0019` + KM card + KNOWLEDGE_MAP regen + live docs) is being committed now; no engine/source behavior changed.
