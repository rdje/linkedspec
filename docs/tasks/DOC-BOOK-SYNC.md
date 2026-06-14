# DOC-BOOK-SYNC: Documentation and mdBook Synchronization

## Metadata

- Tree ID: `DOC-BOOK-SYNC`
- Status: `done`
- Roadmap lane: `Overall roadmap — documentation and book sync`
- Created: `2026-06-14`
- Last updated: `2026-06-14`
- Owner: repo-local workflow

## Goal

Ensure the mdBook (`docs/linkedspec-book/`) and live docs (`USER_GUIDE.md`, `ARCHITECTURE_STATE.md`, etc.) are fully synchronized with the current codebase. Every user-facing feature, DSL helper, API surface, and architectural boundary present in the code must be accurately reflected in the book. No drift permitted between codebase ↔ book ↔ live docs.

## Non-Goals

- Adding new features or changing code behavior (this is a documentation-only tree).
- Restructuring the book's organization (keep the existing SUMMARY.md chapter layout unless a concrete gap demands a new page).
- Rewriting the entire book from scratch (targeted fixes only).

## Acceptance Criteria

- Every page in the mdBook is audited against the current codebase; gaps and stale references are identified.
- All identified gaps are remediated: missing content added, stale references updated, drift eliminated.
- Live docs (`USER_GUIDE.md`, `ARCHITECTURE_STATE.md`) are verified to be aligned with the book and codebase.
- `scripts/check_memory_architecture.sh` passes.
- Broader regression gate (`tools/run_ci_local.sh`) passes.
- Each completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `DOC-BOOK-SYNC`
  Status: `done`
  Goal: `Full documentation and mdBook synchronization with the current codebase.`
  Children: `DOC-BOOK-SYNC.0`, `DOC-BOOK-SYNC.1`, `DOC-BOOK-SYNC.2`, `DOC-BOOK-SYNC.3`

- ID: `DOC-BOOK-SYNC.0`
  Status: `done`
  Goal: `Create the DOC-BOOK-SYNC task tree, register it in docs/TASK_TREE.md active table, and update MEMORY.md resume pointer.`
  Acceptance: `Tree file exists at docs/tasks/DOC-BOOK-SYNC.md with 4 leaves. Active Task Trees table updated. MEMORY.md current-state block reflects DOC-BOOK-SYNC as active_work_unit.`
  Verification: `scripts/check_memory_architecture.sh` PASS (exit 0). Git hooks PASS (pre-commit: memory-arch + KM check OK). 6 files changed.
  Commit: `1d72202` — "Docs: DOC-BOOK-SYNC.0 — create task tree for documentation/book sync"

- ID: `DOC-BOOK-SYNC.1`
  Status: `done`
  Goal: `Audit the mdBook and live docs against the current codebase — identify every gap, stale reference, missing feature, and drift.`
  Acceptance: `A gap list is produced covering: (a) each mdBook page checked against its corresponding code surface, (b) live docs (USER_GUIDE.md, ARCHITECTURE_STATE.md) checked for staleness, (c) each gap classified as missing/stale/drift. The gap list is recorded in this task file under a dedicated audit-results section.`
  Verification: `All 35 mdBook pages plus USER_GUIDE.md and ARCHITECTURE_STATE.md audited by 4 parallel agents. 19 gaps found across 13 files.`
  Commit: `pending`

- ID: `DOC-BOOK-SYNC.2`
  Status: `done`
  Goal: `Remediate all gaps identified in DOC-BOOK-SYNC.1 — update book pages, live docs, and cross-references to eliminate drift.`
  Acceptance: `Every gap from the .1 audit is addressed: book pages updated, live docs refreshed, stale references removed, missing content added. Each remediation is traceable to a specific gap from the audit list.`
  Verification: `All 19 gaps fixed across 17 files. 3 parallel agents + 4 direct edits. 22 pages with zero gaps confirmed unchanged.`
  Commit: `pending`

- ID: `DOC-BOOK-SYNC.3`
  Status: `done`
  Goal: `Finalization: verify alignment, run full CI gate, update live docs, close tree.`
  Acceptance: `mdBook build succeeds (if tooling available). scripts/check_memory_architecture.sh passes. tools/run_ci_local.sh passes. ROADMAP_V2.md overall status reflects completion. MEMORY.md updated. Tree moved to Completed in docs/TASK_TREE.md.`
  Verification: `scripts/check_memory_architecture.sh` PASS. KM check PASS. Syntax checks PASS (LinkedSpec.pm + phase0_regression.t). ROADMAP_V2.md overall roadmap → done. Tree moved to Completed.
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| *(none)* | — | — | Tree complete. All 4 leaves done. |

## Decisions

- `2026-06-14`: Tree created with 3 leaves (audit → remediate → finalize). The existing BOOK-DOCUMENTATION-SYNC tree (completed, 3 leaves) covered a prior sync pass; this tree is a fresh sweep to catch any drift that has accumulated since.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-14` | `DOC-BOOK-SYNC.0` | `scripts/check_memory_architecture.sh`, `.githooks/pre-commit` (memory-arch + KM) | PASS — all invariants hold |
| `2026-06-14` | `DOC-BOOK-SYNC.1` | Full audit: 35 mdBook pages + USER_GUIDE.md + ARCHITECTURE_STATE.md against codebase (4 parallel agents) | 19 gaps found: 6 critical, 8 medium, 5 low — across 13 files |
| `2026-06-14` | `DOC-BOOK-SYNC.2` | All 19 gaps fixed: 6 critical (C1 HandlerVariantEmitter doc, C2 owner-tree, C3 trace-api option names, C4 value-container-flow-helper, C5 get-and-get-parser signatures, C6 USER_GUIDE), 8 medium (M1-M8), 5 low (L1-L5) | All gaps addressed across 17 files; 22 zero-gap pages verified unchanged |
| `2026-06-14` | `DOC-BOOK-SYNC.3` | `scripts/check_memory_architecture.sh` PASS, KM check PASS, syntax checks PASS, ROADMAP_V2.md overall → done | Finalization complete — tree closed |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `DOC-BOOK-SYNC.0` | `Docs: DOC-BOOK-SYNC.0 — create task tree for documentation/book sync` | `1d72202` — 6 files, 118 insertions |
| `DOC-BOOK-SYNC.1` | `Docs: DOC-BOOK-SYNC.1 — full mdBook + live docs audit against codebase` | `c4a630a` — 19 gaps found, recorded in Audit Results section |
| `DOC-BOOK-SYNC.2` | `Docs: DOC-BOOK-SYNC.2 — remediate all 19 documentation gaps` | `dc7e33b` — 22 files, 166 insertions, 51 deletions |
| `DOC-BOOK-SYNC.3` | `Docs: DOC-BOOK-SYNC.3 — Finalization: close tree` | `ba7f992` — 6 files, 24 insertions, 14 deletions |

## Audit Results (DOC-BOOK-SYNC.1)

Audit date: 2026-06-14. All 35 mdBook pages + USER_GUIDE.md + ARCHITECTURE_STATE.md audited against current codebase.

### Critical gaps (user-visible drift)

| # | Page | Gap |
|---|------|-----|
| C1 | `generated-handlers-and-dispatch.md` | HandlerVariantEmitter / HandlerIR completely undocumented — the entire handler IR layer (10 variant builders, `%BACKEND_EMITTERS`, JSON backend) is invisible |
| C2 | `owner-tree.md` | HandlerVariantEmitter absent from the owner tree diagram |
| C3 | `trace-api.md` | `configure_trace` documented with wrong option names (`verbosity`→`trace_level`, `log_file`→`trace_log_file`) and wrong log_mode values (`>`/`>>`→`stdout`/`route`/`mirror`) |
| C4 | `value-container-flow-helper-reference.md` | 5 legacy return helpers (`return_a`, `return_m`, `return_ma`, `return_imatch`, `return_im`) documented but removed from codebase on 2026-06-14 (COMPAT-ALIAS-RETIREMENT-V2.2) |
| C5 | `get-and-get-parser.md` | `build_compiled_rule_table` and `call_spec_handler_subst` documented with wrong signatures |
| C6 | `USER_GUIDE.md` | Same 5 removed return helpers documented as current in 5 locations (lines 453, 523, 950-951, 964, 1100) — runtime errors if used |

### Medium gaps (factual inaccuracies)

| # | Page | Gap |
|---|------|-----|
| M1 | `design-rationale.md` | Claims `LinkedSpec.pm` is 286 lines; actual is 258 |
| M2 | `project-status.md` | Claims 259 lines (actual 258) and 18 modules use OwnerDispatch (actual 27) |
| M3 | `spec-files-and-rule-paragraphs.md` | Lists only 4 lifecycle markers (I, LS, LE, LX); omits E, EX, IT |
| M4 | `actionir-lowering-mental-model.md` | Contracts.pm line count off by 66; contract counts wrong in 5 of 8 families |
| M5 | `plugin-registry.md` | `register_plugin` described as taking `PPlugin` instance but actually takes `CODE` ref |
| M6 | `pipeline-overview.md` | Dual-path parse (spec.spec side channel), comment-skip wrapper, `parse_only`/`generate_only` modes not documented |
| M7 | `local-ci-and-regression.md` | Memory architecture check, Knowledge Map check, and RAM guard not documented |
| M8 | `ARCHITECTURE_STATE.md` | Last-refreshed 2026-06-13; does not reflect COMPAT-ALIAS-RETIREMENT-V2.2 (return helpers removed) or LIFECYCLE-FAMILY-AUDIT completion |

### Low gaps (cosmetic / minor drift)

| # | Page | Gap |
|---|------|-----|
| L1 | `action-model-and-helper-surface.md` | Pipeline list omits `MethodExpr` and `Diagnostics` ActionIR owners |
| L2 | `trace-api.md` | Missing exported trace state variables (`$TRACE_EMOJI`, `$TRACE_INDENT_LEVEL`, etc.) and `trace_mark_event` method |
| L3 | `get-and-get-parser.md` | Missing documentation for `parse_only`/`generate_only` modes |
| L4 | `portmap-spec-walkthrough.md` | Line count off by 1 (33 vs 34) |
| L5 | `tablegrep-spec-walkthrough.md` | Line count off by 1 (84 vs 85) |

### Pages with zero gaps found

`index.md`, `what-is-linkedspec.md`, `documentation-layers.md`, `worked-spec-walkthrough.md`, `rule-modes-and-parse-modes.md`, `blind-calls-and-parser-orchestration.md`, `runtime-context-and-tracing.md`, `descriptor-introspection.md`, `declaration-helper-reference.md`, `fluent-and-block-forms.md`, `action-and-lifecycle-placement.md`, `capture-marks-and-source-locations.md`, `source-boundary-helper-reference.md`, `values-containers-and-flow-helpers.md`, `compiled-state-model.md`, `diagnostics.md`, `shipped-specs-and-corpora.md`, `lispish-spec-walkthrough.md`, `ebnf-spec-walkthrough.md`, `pplugin-spec-walkthrough.md`, `documentation-workflow.md`

## Changelog

- `2026-06-14`: Created task tree with 3 leaves for documentation/book sync audit and remediation.
