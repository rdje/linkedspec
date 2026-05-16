# PHASE3-EXECUTION-SEMANTICS: Phase 3 Execution Semantics Clarification

## Metadata

- Tree ID: `PHASE3-EXECUTION-SEMANTICS`
- Status: `active`
- Roadmap lane: `Phase 3`
- Created: `2026-05-16`
- Last updated: `2026-05-17`
- Owner: repo-local workflow

## Goal

Complete formal parse-mode semantics: `seek` and `consume` modes with clear documented behavior contracts, orthogonal to `OR`/`AND` rule composition, and explicit about the non-backtracking forward-moving model.

## Non-Goals

- Full parser-engine backtracking (explicitly out of scope per roadmap).
- Capture/mark API (Phase 4).
- Runtime modernization (Phase 5).

## Acceptance Criteria

- `seek` and `consume` modes have deterministic documented behavior.
- Mode selection is orthogonal to rule composition.
- Backtracking helpers (`BACKTRACK`, `IBACKTRACK`) are documented as local cursor-rewind, not systemic search-tree rollback.
- Phase 3 exit criteria met per `ROADMAP.md`.

## Task Tree

- ID: `PHASE3-EXECUTION-SEMANTICS`
  Status: `active`
  Goal: `Complete parse-mode semantics clarification.`
  Children: `PHASE3-EXECUTION-SEMANTICS.1`, `PHASE3-EXECUTION-SEMANTICS.2`, `PHASE3-EXECUTION-SEMANTICS.3`, `PHASE3-EXECUTION-SEMANTICS.4`

- ID: `PHASE3-EXECUTION-SEMANTICS.1`
  Status: `completed`
  Goal: `Inventory current parse-mode surface: what is shipped, what is documented, and what gaps remain between the implemented contract and the documented contract.`
  Acceptance: `Task file lists each shipped parse-mode feature, its documentation status, known behavior gaps, and names the next executable leaf.`
  Verification: `2026-05-17: Full inventory complete (see below). Implementation surface: 8 components across LinkedRE.pm, Compiler.pm, SpecEntry.pm, CompilerState.pm, Runtime.pm, ActionIR/Contracts.pm, ActionIR/Scanner/LegacyRules.pm. Documentation surface: 5 book chapters covering seek/consume semantics, rule-mode orthogonality, public API shape, and BACKTRACK as compatibility helper. Test surface: 4 dedicated subtests (~30 assertions) plus ~40 consume-mode subtests. Gaps identified: BACKTRACK/IBACKTRACK local-rewind contract not explicitly documented, no explicit non-backtracking forward-moving model statement, BACKTRACK+parse_mode interaction undocumented, seek-mode test coverage lighter than consume. Three follow-on leaves created (.2, .3, .4).`
  Commit: `pending`

- ID: `PHASE3-EXECUTION-SEMANTICS.2`
  Status: `completed`
  Goal: `Document BACKTRACK/IBACKTRACK as local cursor-rewind helpers, not systemic search-tree rollback, in the mdbook source-boundary-helper-reference chapter.`
  Acceptance: `The book explicitly states BACKTRACK() rewinds to before the parent match (LSPOS - length LMATCH) and IBACKTRACK() rewinds to before the inner match (IPOS - length IMATCH), both are local pos() manipulations without search-tree state, and they exist as compatibility helpers for specs that need explicit cursor repositioning.`
  Verification: `2026-05-17: Added "BACKTRACK and IBACKTRACK: local cursor rewind" subsection (22 lines) to source-boundary-helper-reference.md. Covers: concrete pos() assignments, parent-match vs inner-match rewind distinction, local cursor rewind vs systemic backtracking distinction (LinkedSpec does not implement search-tree rollback), parse_mode interaction after rewind, label-argument compatibility note, and guidance to prefer structural alternatives when avoidable.`
  Commit: `pending`

- ID: `PHASE3-EXECUTION-SEMANTICS.3`
  Status: `pending`
  Goal: `Add explicit non-backtracking forward-moving model statement to rule-modes-and-parse-modes.md.`
  Acceptance: `The book explicitly states that the LinkedSpec parser model is forward-moving and non-backtracking: regex matching advances the cursor or stays put on failure, but the engine does not maintain a search tree, does not unwind partial rule matches to try alternatives, and does not implement systemic backtracking. BACKTRACK/IBACKTRACK are the sole explicit cursor-rewind mechanism and operate via local pos() manipulation.`
  Commit: `pending`

- ID: `PHASE3-EXECUTION-SEMANTICS.4`
  Status: `pending`
  Goal: `Document BACKTRACK/IBACKTRACK interaction with seek/consume parse modes.`
  Acceptance: `The book explains that BACKTRACK/IBACKTRACK reposition the cursor regardless of parse mode; after rewind, the next match proceeds under the active mode discipline at the new cursor position. In consume mode this means the next match must succeed contiguously from the rewound position.`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 2 | `PHASE3-EXECUTION-SEMANTICS.3` | `pending` | Add non-backtracking forward-moving model statement. |
| 3 | `PHASE3-EXECUTION-SEMANTICS.4` | `pending` | Document BACKTRACK+parse_mode interaction. |

## PHASE3-EXECUTION-SEMANTICS.1 Inventory (2026-05-17)

### Implementation Surface

**Core parse-mode engine** — `perl/LinkedRE.pm` (56 lines):
- `seek` mode (line 34-37): `$$stref =~ /(?{my $pos=0})$oredRE/gcp` — matches anywhere; the `gcp` flags support global matching without `\G` anchor, allowing forward seeking.
- `consume` mode (line 39-43): `$$stref =~ /\G(?{my $pos=0})$oredRE/gcp` — adds `\G` anchor requiring match at current `pos($$stref)`. If pos is unset (0) and the regex doesn't match at position 0, the match fails.
- Mode passed as 3rd arg to `or()`; when absent/undefined, defaults to `'seek'`. The `_linkedre_or_expr` helper in SpecEntry.pm omits the mode arg for seek (relying on the `$info` hashref being detected as parent_info rather than a mode string).

**Compiler normalization** — `perl/LinkedSpec/Compiler.pm`:
- `_normalize_parse_mode()` (line 471-476): Validates `seek` or `consume`, defaults to `'seek'`. Dies on unrecognized mode.
- `run_get_pipeline()` (line 531+): Reads `parse_mode` from user option (default `'seek'`), normalizes via `_normalize_parse_mode()`, threads through `$compile_spec_entry` callback and `_build_final_descriptor_state()`.
- `_build_final_descriptor_state()` (line 456-468): Stores `parse_mode` in compiled descriptor meta.

**Handler emission** — `perl/LinkedSpec/SpecEntry.pm`:
- `_linkedre_or_expr()` (line 120-129): Generates `LinkedRE::or()` call for each rule. In `consume` mode: passes `'consume'` string as 3rd arg. In `seek` mode: omits mode arg (LinkedRE defaults to seek).
- `_build_handler_variants()` (line 878): Threads `parse_mode` from deps into variant construction. Defaults to `'seek'` when absent/empty.

**Descriptor metadata** — `perl/LinkedSpec/CompilerState.pm` line 110:
- `$meta->{parse_mode} = $args{parse_mode}` — stored in compiled descriptor meta, exposed via `$descriptor->{meta}{parse_mode}`.

**Runtime passthrough** — `perl/LinkedSpec/Runtime.pm` (120 lines):
- `run_get()` delegates to `Compiler::run_get_pipeline()` with user-passed option hash; parse_mode flows through without runtime-level normalization.

**BACKTRACK/IBACKTRACK contracts** — `perl/LinkedSpec/ActionIR/Contracts.pm`:
- `ibacktrack_macro` (line 1713-1721): `IBACKTRACK()` → `pos($$STRING) = $IPOS - length $IMATCH` — rewinds cursor to before the current (inner) match.
- `backtrack_macro` (line 1723-1733): `BACKTRACK()` → `pos($$STRING) = $LSPOS - length $LMATCH` — rewinds cursor to before the last saved (parent) match.
- `ibacktrack` (line 1734-1744): `ibacktrack(label)` → same `pos($$STRING) = $IPOS - length $IMATCH` (compatibility syntax; label argument is ignored in active lowering).
- `backtrack` (line 1745-1755): `backtrack(label)` → same `pos($$STRING) = $LSPOS - length $LMATCH` (compatibility syntax; label argument is ignored).

**Scanner** — `perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm`:
- Scans handler code for BACKTRACK/IBACKTRACK events (both macro and label forms) and emits contract IR events.
- `perl/LinkedSpec/ActionIR/CanonicalEvents/Core.pm` (line 165-166): Maps `ibacktrack`/`ibacktrack_macro` → `IBACKTRACK`, `backtrack`/`backtrack_macro` → `BACKTRACK`.

### Documentation Surface

1. **`rule-modes-and-parse-modes.md`** (499 lines): Definitive user-facing chapter. Covers parse modes (`seek`/`consume`), rule modes (`AND`/`OR`/`|`/`:`/`+`/`*`/`?`/bounds), public option shape, descriptor introspection, mode selection guidance. Explicitly states orthogonality: "Rule modes, action/lifecycle placement, and parse modes are deliberately separate."
2. **`get-and-get-parser.md`** (137 lines): Public API reference. Covers `Get()` and `get_parser()` with `parse_mode` option documentation.
3. **`source-boundary-helper-reference.md`** (403 lines): Lists BACKTRACK/IBACKTRACK in a "Legacy compatibility helpers" table. Describes them as "keep as compatibility unless a clearer parser structure removes the need to backtrack." Does NOT explain the local cursor-rewind mechanism.
4. **`capture-marks-and-source-locations.md`** (171 lines): Covers capture/mark/cursor/entry/match families. No backtrack content.
5. **`ebnf-spec-walkthrough.md`**: One passing mention: "BACKTRACK() positions the parser so the next structural token can be processed by its own rule."

### Test Surface

4 dedicated parse-mode subtests in `t/phase0_regression.t`:
- `parse_mode_default_and_explicit_seek_preserve_progressive_matching` (6 assertions) — verifies seek matches forward past leading junk.
- `parse_mode_consume_requires_contiguous_match` (5 assertions) — verifies consume rejects leading junk.
- `return_descriptor_exposes_parse_mode_metadata_and_consume_parser_source` (10 assertions) — verifies descriptor metadata and parser-source emission.
- `invalid_parse_mode_records_structured_prepare_pipeline_error` (~10 assertions) — verifies structured error for invalid modes.

~40 additional subtests exercise behavior under `consume` mode in various parser construction contexts (named marks, capture helpers, entry/match helpers, cursor helpers, etc.). Seek mode tested primarily through default (no-option) paths.

### Gaps Identified

**Gap 1 — BACKTRACK/IBACKTRACK contract not explicitly documented**: The acceptance criteria calls for "Backtracking helpers are documented as local cursor-rewind, not systemic search-tree rollback." The book currently lists them as "compatibility helpers" without explaining the local-rewind mechanism. The implementation clearly shows `pos($$STRING) = $LSPOS - length $LMATCH` (rewind to before parent match) and `pos($$STRING) = $IPOS - length $IMATCH` (rewind to before inner match), but this distinction between local cursor manipulation and systemic backtracking is not made in prose. → **PHASE3-EXECUTION-SEMANTICS.2**

**Gap 2 — No explicit non-backtracking forward-moving model statement**: The acceptance criteria calls for "explicit about the non-backtracking forward-moving model." The book describes seek/consume cursor discipline and rule-mode composition, but does not contain an explicit statement that the LinkedSpec parser engine is forward-moving and non-backtracking: it does not maintain a search tree, does not unwind partial matches to try alternatives, and does not implement systemic backtracking (BACKTRACK/IBACKTRACK are the sole cursor-rewind mechanism and operate via local pos() manipulation). → **PHASE3-EXECUTION-SEMANTICS.3**

**Gap 3 — BACKTRACK+parse_mode interaction undocumented**: When BACKTRACK() or IBACKTRACK() rewinds the cursor, the next match proceeds under the active parse_mode at the new cursor position. In consume mode this means the next rule must match contiguously from the rewound position. This interaction is not documented anywhere. → **PHASE3-EXECUTION-SEMANTICS.4**

**Non-gap — parse_mode is global**: No per-rule parse_mode override exists. This is intentional and consistent with the stated orthogonality principle (parse mode is cursor discipline, not rule composition). The book does not advertise per-rule mode selection, so no gap.

**Non-gap — OR/AND orthogonality**: Well-documented. The rule-modes-and-parse-modes chapter explicitly separates these axes, and the implementation confirms they are independent (parse_mode is threaded globally, rule mode is per-label).

### Phase 3 Exit Criteria Status

Per ROADMAP_V2.md Phase 3 acceptance:
- `seek` and `consume` modes have deterministic documented behavior: **DONE** (comprehensive book chapter + solid implementation)
- Mode selection is orthogonal to rule composition: **DONE** (explicitly documented)
- Backtracking helpers documented as local cursor-rewind: **GAP** (see Gap 1)
- Non-backtracking forward-moving model explicit: **GAP** (see Gap 2)
- Phase 3 exit criteria met per ROADMAP.md: **PENDING** (resolve gaps 1-3)

## Decisions

- `2026-05-17`: Completed PHASE3-EXECUTION-SEMANTICS.1 inventory. Found 3 documentation gaps between implemented contract and documented contract. All three are documentation additions to existing book chapters, not implementation changes. Created leaves .2, .3, .4. Full regression suite green at 1007 tests.
- `2026-05-16`: Created task tree. First-slice parse modes (`seek`/`consume`) are already landed with public `parse_mode` option.

## Open Questions

- ~~Are there edge cases where `seek` vs `consume` behavior diverges from the documented contract?~~ Resolved: No behavioral edge-case divergences found. Gaps are documentation omissions (BACKTRACK rewind contract not explicit, non-backtracking model not stated, BACKTRACK+parse_mode interaction undocumented), not implementation bugs.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-05-17` | `PHASE3-EXECUTION-SEMANTICS.1` | Read all 8 implementation components (LinkedRE.pm, Compiler.pm, SpecEntry.pm, CompilerState.pm, Runtime.pm, ActionIR/Contracts.pm, ActionIR/Scanner/LegacyRules.pm, ActionIR/CanonicalEvents/Core.pm). Read all 5 documentation chapters. Analyzed test coverage (4 dedicated subtests + ~40 consume-mode subtests). Ran full regression suite. | Pass — 3 documentation gaps identified, no implementation gaps. Full suite: Files=1, Tests=1007, PASS. |
| `2026-05-17` | `PHASE3-EXECUTION-SEMANTICS.2` | Verified new "BACKTRACK and IBACKTRACK: local cursor rewind" subsection in source-boundary-helper-reference.md. Confirmed coverage: concrete pos() assignments, parent vs inner match distinction, local rewind vs systemic backtracking distinction, parse_mode interaction, label-argument compatibility note, structural-alternative guidance. | Pass — 22-line prose addition, no implementation changes. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `PHASE3-EXECUTION-SEMANTICS.1` | `Docs: inventory Phase 3 execution semantics surface` | 8-component audit, 3 gaps found, leaves .2/.3/.4 created |
| `PHASE3-EXECUTION-SEMANTICS.2` | `pending` | — |

## Changelog

- `2026-05-17`: Completed PHASE3-EXECUTION-SEMANTICS.2 — added "BACKTRACK and IBACKTRACK: local cursor rewind" subsection (22 lines) to source-boundary-helper-reference.md. Covers concrete pos() rewinds, parent vs inner match distinction, local rewind vs systemic backtracking (LinkedSpec does not do search-tree rollback), parse_mode interaction, and label-argument compatibility note.
- `2026-05-17`: Completed PHASE3-EXECUTION-SEMANTICS.1 inventory. Audited 8 implementation components, 5 book chapters, test coverage. Found 3 documentation gaps (BACKTRACK local-rewind contract, non-backtracking model statement, BACKTRACK+parse_mode interaction). Created leaves .2, .3, .4. 1007 PASS.
- `2026-05-16`: Created task tree from template.
