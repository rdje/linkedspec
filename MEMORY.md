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
- latest_commit: `PHASE0-BACKHALF-TRIAGE.5.3.1 — drop stale plugin/ ref in tools/run_ci_local.sh; full local gate green end-to-end` (hash backfilled next; ahead of origin ~29 — push threshold ~300; do NOT push mid-PNT). Prior: `89e9526` (`.5.4`).
- Active trees: **`PHASE0-BACKHALF-TRIAGE`** frontier **`.5.3.2`** (downstream status/doc/KM gate-flips) → `.6` (book `:AND`); `DOCTRINE-ENFORCEMENT-ADOPT` `.1`+`.2` DONE (`.3` deferred).
- **BOTH the phase0 suite AND the full local gate are GREEN end-to-end (first time).** `t/phase0_regression.t` = 960/960 (`.5.4`: re-blessed 952/953 `?Top:`→`$VAR1 = 1;` since `return(1)`→scalar `1`, + 960 dropped the `noncore/`-moved `.plg`-corpus inspection). `.5.3.1`: `bash tools/run_ci_local.sh` now **EXIT 0** ("[ci] local CI gate passed") — fixed its stale `plugin/` ref (NONCORE-QUARANTINE leftover; the 13 `.plg` moved to `noncore/plugin/`); core gate stays core-only (dropped, not retargeted). All TEST/CI-only; engine/spec untouched; book unaffected.
- **`.5.3.2` NEXT (PNT-eligible):** flip the downstream **blocked statuses + doc/KM sync** now phase0 + full gate are green — `NONCORE-QUARANTINE.V` (verify + clear its blocker), `LEGACY-VHDL-RETIRE.4/.5` (RTLUtils hang already cleared; full gate green; + fix the `generic_fake_memory_module.plg`/`wrapgen.plg` doc drift), `SPEC-FORMAT-TERSE` impl-gate (RTLUTILS-REGEX-HANG + usable-phase0 now satisfied). Status/doc reconciliation only — does NOT start the `SPEC-FORMAT-TERSE` `.1.x`+ implementation leaves (they become PNT-eligible after the flip). Then `.6` (book `:AND`: the now-fixed `::AND`+regex+return form vs the book's "Body rule only"/"no regex on top" idiom — likely a short user policy check).
- DOCTRINE-ENFORCEMENT directive: **DONE** (`.1`+`.2`) — `TOOLBOX.md` catalogs LinkedSpec's OWN debug tools (probes/trace/dump/tools/gates); `scripts/check_doctrines.sh` driver gates via hooks+CI. `.3` (task-acceptance hard-gate) deferred. To add a doctrine: write `scripts/check_<id>.sh` + one registry line.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always run `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm` in probes).
- VERIFY: full gate `bash tools/run_ci_local.sh` (EXIT 0; runs doctrine + audits + `perl -c` + phase0 via `prove`, ~198s) OR phase0 alone FOREGROUND `perl -Iperl t/phase0_regression.t` (reaches `1..960`); check the reach (last `ok N`) before trusting any `comm` — a truncated/killed run gives a FALSE "cleared" set; `alarm()` can't kill a catastrophic regex (use fork+SIGKILL).
- blockers: NONE for phase0 / full local gate (both GREEN). Open: (1) PRE-EXISTING `cargo clippy --tests` exit-101 (Rust lane — NOT part of `run_ci_local.sh`). (2) `ARCHITECTURE_STATE.md` ~288-302 stale (domain owners now in `noncore/`) — docs-only refresh pending. in_flight_uncommitted: none after this commit.
