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
- latest_commit: `PHASE0-BACKHALF-TRIAGE.5.2 — fix Lispish corpus_regression hang (never-undef parser + unguarded multi-parse loop; forward-progress guard, TEST-ONLY)` (hash backfilled next; ahead of origin ~29 — push threshold ~300; do NOT push mid-PNT). Prior: `30c7a48` (doctrine-enforcement).
- Active trees: **`PHASE0-BACKHALF-TRIAGE`** frontier **`.5.4`** (3 TEST-ONLY re-blesses → green); `DOCTRINE-ENFORCEMENT-ADOPT` `.1`+`.2` DONE (`.3` deferred).
- **`.5.2` DONE — corpus hang FIXED; root cause CORRECTED (NOT a regex).** Measurement: a single parse of the full 392B file = 0.03s (no backtracking); the **Lispish parser never returns `undef`** — on a no-progress/EOF call it re-returns the prior form's AST with `pos()` unchanged. `parse_with_lispish_multi`'s `while(1){…last unless defined}` spun to its 100000 cap (~3 min/file × 76 files). **Fix:** a forward-progress guard (`last if pos_after<=pos_before`) in the multi-loop — TEST-ONLY (`t/phase0_regression.t`). **76/76 corpus files ok; `ok 941 - corpus_regression`; suite now reaches subtest 960.** Deeper parser-contract (never-undef) + grammar gap (no top-level whitespace skip ⇒ multi-form files parse only the first form) = engine/spec follow-ons (cross-variant). KM card corrected. See [[lispish-corpus-catastrophic-backtracking]].
- **`.5.4` NEXT (3 dark-tail failures revealed by running past corpus; all TEST-ONLY → green phase0):** **960** `plugin_bridge_dispatch_calls_mechanically_gated_in_plg_corpus` = stale `opendir ../plugin` (drop the non-core `.plg`-corpus inspection, keep the `PluginBridge.pm` check; same as `.5.1`); **952/953** `parse_mode_*` assert `~/\?Top:/` but `Top:: /a/ ->Top {return(1)}` now returns scalar `1` (cluster-A/G class — re-bless `qr/\?Top:/` to the dumped `$VAR1 = 1;`). Then `.5.3` gate flips (`SPEC-FORMAT-TERSE`/`LEGACY-VHDL-RETIRE.4-.5`/`NONCORE-QUARANTINE.V`) → `.6` book `:AND`.
- DOCTRINE-ENFORCEMENT directive: **DONE** (`.1`+`.2`) — `TOOLBOX.md` catalogs LinkedSpec's OWN debug tools (probes/trace/dump/tools/gates); `scripts/check_doctrines.sh` driver gates via hooks+CI. `.3` (a `check_diagnosis_evidence.sh`-style task-acceptance hard-gate) deferred (needs project-specific signature design). To add a doctrine: write `scripts/check_<id>.sh` + one registry line.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always run `perl -Iperl` (tests already do; confirm `$INC{'LinkedSpec.pm'}` in probes).
- VERIFY-UNDER-LOAD: a truncated/killed full run gives a FALSE `comm` "cleared" set — check the reach (last `ok N`) before trusting it; `alarm()` can't kill a catastrophic regex (use fork+SIGKILL).
- verify: `perl -c -Iperl t/phase0_regression.t` OK; `perl -c perl/LinkedSpec.pm` OK; full foreground run reaches **subtest 960** (957 ok / 3 not-ok) — `corpus_regression` GREEN; only 952/953/960 remain (all TEST-ONLY, `.5.4`). NOTE: run phase0 FOREGROUND with `timeout:600000` — `run_in_background` is killed at ~120s (exit 144) so it never reaches the corpus tail.
- blockers: (1) **`.5.4`** (3 TEST-ONLY re-blesses) blocks green phase0 + `SPEC-FORMAT-TERSE`/`LEGACY-VHDL-RETIRE.4-.5`/`NONCORE-QUARANTINE.V`. (2) PRE-EXISTING `cargo clippy --tests` exit-101. (3) `ARCHITECTURE_STATE.md` ~288-302 stale (domain owners now in `noncore/`) — docs-only refresh pending. in_flight_uncommitted: none after this commit.
