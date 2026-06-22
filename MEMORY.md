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
- latest_commit: `PHASE0-BACKHALF-TRIAGE.5.3.2.2 — narrative-doc + book drift sync (deleted/relocated owners; DOC-ONLY); close LEGACY-VHDL-RETIRE + NONCORE-QUARANTINE` (hash backfilled next; ahead of origin ~31 — push threshold ~300; do NOT push mid-PNT). Prior: `04ab4d7` (`.5.3.2.1`).
- **`PHASE0-BACKHALF-TRIAGE.5.3.2.2` DONE (this commit, DOC-ONLY):** synced `ROADMAP_V2.md` + `ARCHITECTURE_STATE.md` (owner-tree + legacy-plugin-branch prose) + 2 mdBook files (`specs-and-corpora/shipped-specs-and-corpora.md`, `architecture/owner-tree.md`) to the real module state — RTLUtils/FSMGen/VHDL::ConstantEval **DELETED** (LEGACY-VHDL-RETIRE), the 12 remaining domain owners + 13 `.plg` **relocated to `noncore/`** (NONCORE-QUARANTINE), root `plugin/` gone, `perl/` core-only; the `generic_fake_memory_module.plg`/`wrapgen.plg`/`ceil_log2` drift gone; `mdbook build` EXIT 0; book stays variant-agnostic. **Flipped `LEGACY-VHDL-RETIRE.5` + `NONCORE-QUARANTINE.V` → done — BOTH trees now CLOSED** (NONCORE `.N` deferred as an explicit Non-Goal). phase0 still 960/960; engine/spec/test/book-behavior untouched.
- Active trees: **`PHASE0-BACKHALF-TRIAGE`** — **only open leaf `.6`** (book `:AND` reconciliation: the now-fixed `::AND`+regex+return form vs the book's "Body rule only"/"no regex on top" idiom). **`.6` LIKELY NEEDS A SHORT USER POLICY CHECK** (document `::AND`+regex as a supported form vs. keep steering authors to the 2-rule idiom [[spec-top-rule-no-regex-two-rule-minimum]]). Other PNT-eligible lanes: **`SPEC-FORMAT-TERSE`** `.1.x` (impl-gate cleared; policy=gradual-alias ADR 0007; first `.1.1` auto-existing variables), `DOCTRINE-ENFORCEMENT-ADOPT` `.3` (deferred), `TRACE-OBSERVABILITY`, `RUST-PARITY.7.5.3`.
- next_action: surface the `.6` policy choice to the user, OR (if directed to keep PNT'ing) start `SPEC-FORMAT-TERSE.1.1`. Read `docs/tasks/SPEC-FORMAT-TERSE.md` + ADR `0007` first for that lane. phase0 960/960 GREEN + `bash tools/run_ci_local.sh` EXIT 0 both hold.
- ENV HAZARD: stale `PERL5LIB=…/pgen/fx/perl` → bare `use LinkedSpec` loads the WRONG checkout (the `rgx/subs/pgen/fx/perl` copy, where deleted RTLUtils/FSMGen still live); always run `perl -Iperl` (confirm `$INC{'LinkedSpec.pm'}`=`perl/LinkedSpec.pm` in probes).
- VERIFY: full gate `bash tools/run_ci_local.sh` (EXIT 0; doctrine + audits + `perl -c` + phase0 via `prove`, ~198s) OR phase0 alone FOREGROUND `perl -Iperl t/phase0_regression.t` (reaches `1..960`); for doc-only slices, `mdbook build docs/linkedspec-book` + `scripts/check_memory_architecture.sh` + `scripts/check_doctrines.sh`.
- blockers: NONE for phase0 / full local gate (both GREEN). `.6` gated on a user policy choice (above). Open: PRE-EXISTING `cargo clippy --tests` exit-101 (Rust lane — NOT part of `run_ci_local.sh`). in_flight_uncommitted: none after this commit.
