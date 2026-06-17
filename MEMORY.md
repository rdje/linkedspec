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
- latest_commit: `LEGACY-VHDL-RETIRE.1 — own retirement tree + read-only inventory of the Perl-only legacy VHDL/RTL/FSM subsystem` (hash backfilled by next hash-sync; ahead of origin ~7 — push threshold ~300; do NOT push mid-PNT)
- active_work_unit: `LEGACY-VHDL-RETIRE` (gate-clearing prerequisite for `SPEC-FORMAT-TERSE`); `.1` read-only inventory **DONE** 2026-06-18. **next_action: surface the removal-scope decision to the user (AskUserQuestion); on confirmation execute `.2`→`.5` — remove the 6 dependent `.plg` + phase0 migration-smoke blocks → remove the 3 modules → confirm phase0 no longer hangs + full gate green → doc/book/KM sync — which clears `RTLUTILS-REGEX-HANG` and unblocks `SPEC-FORMAT-TERSE.1.1`.** Removal `.2`–`.5` are **BLOCKED pending that user confirmation** (deletions; doctrine requires confirming scope first).
- INVENTORY (`LEGACY-VHDL-RETIRE.1`, verified `git grep`+`wc -l`): subsystem `perl/RTLUtils.pm`(877)+`perl/FSMGen.pm`(3,549)+`perl/VHDL/ConstantEval.pm`(90)=4,516 lines, **ZERO `.spec`-core functional dependency** (only a comment at `LinkedSpec.pm:246`; `gen_oracle_corpus.pl:31` comment); 6 dependent `.plg` (fsmgen/lte_digital_rf/mbist/msword/regtest/rtl)=1,979 lines; ≈206 phase0 migration-smoke lines; footprint ≈6,701 lines. Catastrophic regex at **`RTLUtils.pm:746`** (corrected from prior `add_header_n_context_clause`). Doc drift: `generic_fake_memory_module.plg`/`wrapgen.plg` gone but cited in `ROADMAP_V2:157`/`ARCHITECTURE_STATE:588` (fix in `.5`). KM card [[rtlutils-regex-hang]].
- SPEC-FORMAT-TERSE (paused under the gate): `.0` done (ADR `0007`); migration policy = **gradual alias**; `SPEC-LANG-REFERENCE` book scorch PAUSED. TERSE SEMANTICS: `assign(x,v)`→`x = v`/`set`; **no sigils** (bare typed identifiers); type inference at init / by arg position; `copy()` unifies array+hash; arrays/hashes/numbers/strings have **methods** (chain by return type); **everything is an expression**. Open design Q (call-syntax, ratify in `.3.2`): my rec = uniform `callee(args)`, word canonical + symbol alias, no `(op a,b)`. Touching the Perl reference here is a user-sanctioned exception to [[feedback_do-not-fix-reference-engine]].
- verify tool: private driver `/tmp/lsq_me/run.pl <spec> '<input>'` (default) + `/tmp/lsq_me/runpm.pl <spec> '<input>' [mode]`; `perl -I perl`, scalar-ref input, `JSON::PP->canonical`; reproduces `["hello-world"]`.
- blockers: (1) PRE-EXISTING phase0 RTLUtils regex hang (`RTLUtils.pm:746`; Perl-side) — gates `SPEC-FORMAT-TERSE`; cleared by `LEGACY-VHDL-RETIRE.2`–`.4` (awaiting user removal-scope OK). (2) PRE-EXISTING `cargo clippy --tests` exit-101 (`approx_constant`, untouched).
