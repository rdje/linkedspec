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
- latest_commit: `PHASE0-BACKHALF-TRIAGE.5.4 — re-bless 3 dark-tail failures (TEST-ONLY); phase0 fully GREEN 960/960` (hash backfilled next; ahead of origin ~28 — push threshold ~300; do NOT push mid-PNT). Prior: `e74149d` (`.5.2`).
- Active trees: **`PHASE0-BACKHALF-TRIAGE`** frontier **`.5.3`** (flip downstream gates, now unblocked) → `.6` (book `:AND`); `DOCTRINE-ENFORCEMENT-ADOPT` `.1`+`.2` DONE (`.3` deferred).
- **`t/phase0_regression.t` IS FULLY GREEN end-to-end (960/960, EXIT 0, `1..960`) — first time ever.** `.5.4` DONE (TEST-ONLY, engine/spec untouched): re-blessed **952/953** `parse_mode_*` `qr/\?Top:/`→`qr/\$VAR1 = 1;/` (`Top:: /a/ ->Top {return(1)}` → scalar `1`; got dumped via `LinkedSpec::Get` per TOOLBOX Protocol A) + **960** dropped the `noncore/`-moved `.plg`-corpus inspection, kept the core `PluginBridge.pm` check (plan 5→1; same core-only precedent as `.5.1`). before 957ok/3not-ok → after 960ok/0not-ok; `comm` = exactly the 3 cleared, 0 new. Book unaffected.
- **`.5.3` NEXT (PNT-eligible):** flip the downstream gates — `SPEC-FORMAT-TERSE`, `LEGACY-VHDL-RETIRE.4/.5`, `NONCORE-QUARANTINE.V` — now the green-phase0 condition is met. `NONCORE-QUARANTINE.V` itself owns clearing those blockers + doc/book/KM sync, so `.5.3` may largely hand off to `.V`. Then `.6` (book `:AND`: the now-fixed `::AND`+regex+return form vs the book's "Body rule only"/"no regex on top" idiom — likely a short user policy check).
- DOCTRINE-ENFORCEMENT directive: **DONE** (`.1`+`.2`) — `TOOLBOX.md` catalogs LinkedSpec's OWN debug tools (probes/trace/dump/tools/gates); `scripts/check_doctrines.sh` driver gates via hooks+CI. `.3` (task-acceptance hard-gate) deferred. To add a doctrine: write `scripts/check_<id>.sh` + one registry line.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always run `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm` in probes).
- VERIFY: run phase0 FOREGROUND `perl -Iperl t/phase0_regression.t` (≈minutes; reaches subtest 960 / `1..960`); check the reach (last `ok N`) before trusting any `comm` — a truncated/killed run gives a FALSE "cleared" set; `alarm()` can't kill a catastrophic regex (use fork+SIGKILL). `perl -c -Iperl t/phase0_regression.t` OK; `perl -c perl/LinkedSpec.pm` OK.
- blockers: NONE for phase0 (GREEN). Open: (1) PRE-EXISTING `cargo clippy --tests` exit-101 (Rust lane). (2) `ARCHITECTURE_STATE.md` ~288-302 stale (domain owners now in `noncore/`) — docs-only refresh pending. in_flight_uncommitted: none after this commit.
