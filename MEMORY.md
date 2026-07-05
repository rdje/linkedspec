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
- latest_completed_leaf: `SPEC-FORMAT-TERSE.15.2.1` (design/inventory) — bare-vs-`:name` value-position gap enumerated with DISCRIMINATING reference-engine probes: bare NOT read as the bound variable in `switch(...)` selector, `num_*(...)` callee args, and `if(...)`/`while(...)`/logical conditions (`switch(:kind)`→good vs `switch(kind)`→def; `num_lt(:n,5)`@n=10→no vs bare→yes; `if(:c)`@c=0→F vs bare→T). Plain `return(name)`/assign-RHS/receiver already read bare. Real shipped-spec hazard = rule-name collisions in `spec.spec`/`ebnf.spec` (ADR `0019`). Policy locked (value-position-is-variable); composes with `.11` type-at-assignment. NO engine change.
- latest_commit: `SPEC-FORMAT-TERSE.15.2.1` workflow commit pending; previous `86767aaf` (`.15.2 - reorder .15 to engine-first (bare-read gap)`). ~305 commits ahead of origin; do NOT push mid-PNT unless explicitly instructed.
- active_work_unit: `SPEC-FORMAT-TERSE.15.2.2` (Perl bare-read completion) — make bare identifiers read the bound typed value in every value position `.15.2.1` enumerated, with `:name` still compat during transition. Then `.15.2.3` Rust parity, `.15.2.4` source migration (output-preserving), then `.15.3`/`.15.4` remove `:name` ENTIRELY (no compat; user directive), `.15.5` closeout.
- next_action: Start `SPEC-FORMAT-TERSE.15.2.2`. PRIMARY Perl seam = `ActionIR::FlowExpr::_lower_flow_composite_expr` (`perl/LinkedSpec/ActionIR/FlowExpr.pm:319`; add a bare-ident→`$name` scalar-read branch next to the `:name`→`$name` branch at `:364`, guarded by value-position-is-variable — do NOT swallow helper-call names matched at `:374`), covering if/elseif/while/logical + `num_*` args; plus switch selector via `ActionIR::ControlFlow::_control_ast_value_source_expr` (`:332`) and `_lower_switch_case_value_expr` (`:104`). Prove bare==`:name` for switch/num/if via `scratchpad/probe_15_2_1b.pl`; keep phase0 at 1021 pass / 1 pre-existing fail (test 796).
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → always `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm`). **Generated Perl handlers are NON-strict.** **Rust = interpreter** at `rust/` (working vars auto-vivify; fresh ctx per `execute`). Baseline phase0 = **1021 pass / 1 pre-existing unrelated fail** (test 796 `emit_context_lowers_split_tagged_records_helper`, `unresolved_helper_count == 1`). oracle = `tools/gen_oracle_corpus.pl` (per-case fork/SIGKILL; ~90 fixtures → **run in background, foreground times out**; `manifest.json` + drift guards). `LinkedSpec::Get` takes **flat** option pairs; lowering probe = `call_spec_handler_subst`. Rust numbered capture helpers are captures-only (`0`=first capture); whole match = `entry_text()`/`match_text()`. Staged parsing stays implementation-language neutral.
- noise / deferred: `rgx` (submodule pointer) + `.claude/projects/` are untracked local noise — keep UNSTAGED. `docs/tasks/TRACE-OBSERVABILITY.md` stale-commit-hash edit is unowned noise (not this slice). Deferred lanes behind `.15`: `.8` (legacy-helper removal), `.9` (hash `=>`→`:`), `.10`/`.12`/`.13`/`.14` backlog; `ROADMAP-DRIFT-RECONCILE`, `DOCTRINE-ENFORCEMENT-ADOPT.3`, `SPEC-LANG-REFERENCE`.
- blockers: none for ownership. in_flight_uncommitted: this `.15.2` re-scope planning slice (task-tree + ADR `0019` + KM card + KNOWLEDGE_MAP regen + live docs) is being committed now; no engine/source behavior changed.
