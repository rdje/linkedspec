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
- latest_commit: `PHASE0-BACKHALF-TRIAGE.5.3.2.1 — status & continuity reconciliation (flip downstream gates; DOC-ONLY)` (hash backfilled next; ahead of origin ~30 — push threshold ~300; do NOT push mid-PNT). Prior: `b4e2265` (`.5.3.1`).
- Active trees: **`PHASE0-BACKHALF-TRIAGE`** frontier **`.5.3.2.2`** (narrative-doc + book drift sync) → `.6` (book `:AND`); `DOCTRINE-ENFORCEMENT-ADOPT` `.1`+`.2` DONE (`.3` deferred); `SPEC-FORMAT-TERSE` impl-gate **now cleared** (`.1.x`+ PNT-eligible, policy=gradual-alias ADR 0007).
- **BOTH phase0 (960/960) AND the full local gate (`bash tools/run_ci_local.sh` EXIT 0) are GREEN end-to-end.** `.5.3.2.1` (DONE this commit, DOC-ONLY): split `.5.3.2`, then flipped the downstream gates now that's true — `NONCORE-QUARANTINE.V` blocker (the 173) cleared→`pending`; `LEGACY-VHDL-RETIRE.4`→`done` (RTLUtils hang cleared + full gate green; subtest-131 `HTML::PathLinks` hang moot — smoke excised by NONCORE-QUARANTINE.3) + `.5` cleared→`pending`; `SPEC-FORMAT-TERSE` impl-gate cleared. Synced `docs/TASK_TREE.md` index + the `rtlutils-regex-hang` KM card + live docs. No engine/spec/test/book change.
- **`.5.3.2.2` NEXT (PNT-eligible):** the deferred `LEGACY-VHDL-RETIRE.5` body — narrative-doc + book drift sync: `ROADMAP_V2.md:157` + `ARCHITECTURE_STATE.md` (the "Project/domain utility owners" owner-tree block ~288-302 + "Legacy Plugin Branch Reading" prose + the `generic_fake_memory_module.plg`/`wrapgen.plg`/`ceil_log2` lines 157/588) + mdBook `specs-and-corpora/shipped-specs-and-corpora.md` (~183-197) + `architecture/owner-tree.md` (~430-452) — reflecting RTLUtils/FSMGen/VHDL::ConstantEval DELETED + the rest relocated to `noncore/`. Then flip `LEGACY-VHDL-RETIRE.5` + `NONCORE-QUARANTINE.V` → `done`. `mdbook build` exit 0; keep book variant-agnostic. Then `.6` (book `:AND`: now-fixed `::AND`+regex+return vs the book's "Body rule only"/"no regex on top" idiom — likely a short user policy check).
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout; always run `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm` in probes).
- VERIFY: full gate `bash tools/run_ci_local.sh` (EXIT 0; doctrine + audits + `perl -c` + phase0 via `prove`, ~198s) OR phase0 alone FOREGROUND `perl -Iperl t/phase0_regression.t` (reaches `1..960`); check the reach (last `ok N`) before trusting any `comm` — a truncated/killed run gives a FALSE "cleared" set; `alarm()` can't kill a catastrophic regex (use fork+SIGKILL).
- blockers: NONE for phase0 / full local gate (both GREEN). Open: (1) PRE-EXISTING `cargo clippy --tests` exit-101 (Rust lane — NOT part of `run_ci_local.sh`). (2) `ARCHITECTURE_STATE.md` owner-tree + the 2 mdBook owner lists carry deleted/relocated-module drift — owned by `.5.3.2.2` (next). in_flight_uncommitted: none after this commit.
