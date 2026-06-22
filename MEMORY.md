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
- latest_commit: `PHASE0-BACKHALF-TRIAGE.5.1 — remove stale corpus_regression plugin dataset (TEST-ONLY); exposes .5.2 Lispish corpus catastrophic backtracking` (hash backfilled next; ahead of origin ~26 — push threshold ~300; do NOT push mid-PNT). Prior: `75289f7` (.2.4).
- active_work_unit: `PHASE0-BACKHALF-TRIAGE`. `.1`/`.2.*`/`.3`/`.4` DONE; `.5` SPLIT → **`.5.1` DONE**, **`.5.2` BLOCKED** (needs user decision), `.5.3` blocked. Frontier → **`.5.2`**.
- **`.5.1` DONE (TEST-ONLY):** subtest-941 `corpus_regression` "No tests run"/exit-255 = a **real stale ref, NOT a natural stop** — `NONCORE-QUARANTINE.3` rmdir'd `plugin/` but left the `plugin_plg_via_pplugin_spec` dataset (`opendir ../plugin` → die, aborting the run at 941 so 942-959 never ran). Removed that non-core `.plg` dataset (core gate stays core-only; `plan` 8→6, rationale comment). Baseline confirmed subtests **1-940 GREEN**.
- **`.5.2` BLOCKER (green-phase0):** removing the plugin die EXPOSED that `corpus_regression`'s conf+tablescript parse via **Lispish catastrophically backtracks** — a full run = **374 CPU-min** on one 392B file; fork+SIGKILL census killed **~21/22 conf files (≈100%)**; `alarm()` can't interrupt the C-level regex; the ebnf dataset is healthy. ReDoS-style regex in the Lispish spec. Long-masked (subtest-110 hang → plugin die). See [[lispish-corpus-catastrophic-backtracking]].
- next_action: **surface the `.5.2` direction decision** — (A) quarantine the Lispish corpus datasets (conf+tablescript) from the core gate, keep ebnf (doctrine-aligned, mirrors `.5.1`); (B) fix the Lispish catastrophic regex (engine/spec, needs authorization); (C) hard per-file timeout guard. Then green phase0 → `.5.3` gate flips (`SPEC-FORMAT-TERSE`/`LEGACY-VHDL-RETIRE.4-.5`/`NONCORE-QUARANTINE.V`) → `.6` book `:AND`.
- NEW DIRECTIVE (pending, post-`.5.1`): adopt `/Users/richarddje/Documents/github/pgen/DOCTRINE_ENFORCEMENT.md`; maintain `TOOLBOX.md` listing LinkedSpec's issue-pinpointing tools (env-`LINKEDSPEC_TRACE_LEVEL`, the `LinkedSpec::Get`/`call_spec_handler_subst` probe pattern, fork+SIGKILL corpus census, focused-Test::More subtest harness, `comm` set-diff).
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always run `perl -Iperl` (tests already do; confirm `$INC{'LinkedSpec.pm'}` in probes).
- VERIFY-UNDER-LOAD: a truncated/killed full run gives a FALSE `comm` "cleared" set — check the reach (last `ok N`) before trusting it; `alarm()` can't kill a catastrophic regex (use fork+SIGKILL).
- verify: `perl -c -Iperl t/phase0_regression.t` OK; `perl -c perl/LinkedSpec.pm` OK; phase0 **NOT green** (blocked by `.5.2`).
- blockers: (1) **`.5.2`** (above) blocks green phase0 + `SPEC-FORMAT-TERSE`/`LEGACY-VHDL-RETIRE.4-.5`/`NONCORE-QUARANTINE.V`. (2) PRE-EXISTING `cargo clippy --tests` exit-101. (3) `ARCHITECTURE_STATE.md` ~288-302 stale (domain owners now in `noncore/`) — docs-only refresh pending. in_flight_uncommitted: none after this commit.
