# PHASE4-CAPTURE-MARK-API: Phase 4 Capture/Mark API Formalization

## Metadata

- Tree ID: `PHASE4-CAPTURE-MARK-API`
- Status: `active`
- Roadmap lane: `Phase 4`
- Created: `2026-05-16`
- Last updated: `2026-05-17`
- Owner: repo-local workflow

## Goal

Complete the capture/mark API formalization: finish the first-class mark/checkpoint and capture-helper surface, close out remaining compatibility-alias cleanup, and ensure all shipped `.spec` files use the canonical helper surface.

## Non-Goals

- New capture primitives beyond the already-planned surface.
- Parse-mode semantics (Phase 3).
- Runtime/diagnostics changes (Phase 5).

## Acceptance Criteria

- Named marks and anonymous capture boundaries are first-class, transparent concepts.
- All capture/mark helpers have clear documented semantics.
- Legacy `$CAPTURE` and compatibility aliases are preserved but documented as legacy.
- Shipped `.spec` files use canonical helpers where practical.
- Phase 4 exit criteria met per `ROADMAP.md`.

## Task Tree

- ID: `PHASE4-CAPTURE-MARK-API`
  Status: `active`
  Goal: `Complete capture/mark API formalization.`
  Children: `PHASE4-CAPTURE-MARK-API.1`, `PHASE4-CAPTURE-MARK-API.2`, `PHASE4-CAPTURE-MARK-API.3`, `PHASE4-CAPTURE-MARK-API.4`

- ID: `PHASE4-CAPTURE-MARK-API.1`
  Status: `completed`
  Goal: `Inventory current capture/mark surface: list every shipped helper, its documentation status, remaining compatibility-alias surface, and any gap between what is implemented and what the roadmap promised.`
  Acceptance: `Task file maps each helper family (anonymous boundary, named mark, cursor, whole-input, immediate-match, local-match) to implementation status, doc coverage, and remaining work.`
  Verification: `2026-05-17: Full inventory complete (see below). Audited 163 Contracts.pm entries (~100+ capture/mark/position-specific). Shipped specs: zero legacy usage (no raw pos(), no $CAPTURE, no capture(label), no capture_slice, no @mark). Documentation: 2 book chapters (594 lines) covering all families with comprehensive reference. ~12 compatibility aliases identified across 6 pairs. Created 3 follow-on leaves (.2 legacy alias doc cleanup, .3 mark-family completeness check, .4 Phase 4 finalize).`
  Commit: `pending`

- ID: `PHASE4-CAPTURE-MARK-API.2`
  Status: `pending`
  Goal: `Verify all compatibility aliases are documented as legacy in source-boundary-helper-reference.md, and add entries for any missing ones.`
  Acceptance: `Every compatibility alias pair (capture_slice_length/capture_slice_len, capture_len_from_rule_start/capture_slice_len, capture_from_rule_start/capture_slice, capture_slice_here/start_capture_slice, capture_rest_length/capture_rest_len, entry_named_map/entry_map, match_named_map/match_map) has the legacy spelling documented in the reference.`
  Commit: `pending`

- ID: `PHASE4-CAPTURE-MARK-API.3`
  Status: `pending`
  Goal: `Verify mark-family completeness: all 14 mark_* helpers are documented with clear semantics in source-boundary-helper-reference.md.`
  Acceptance: `Each mark helper (mark_here, mark_entry_start, mark_entry_end, mark_match_start, mark_match_end, mark_input_start, mark_input_end, mark_capture_slice, mark_copy, mark_pos, mark_line, mark_col, mark_exists, clear_mark) has its own entry in the reference table with a clear description of what it does.`
  Commit: `pending`

- ID: `PHASE4-CAPTURE-MARK-API.4`
  Status: `pending`
  Goal: `Finalize Phase 4: update ROADMAP_V2.md status from "in progress" to "done", move tree to completed in TASK_TREE.md.`
  Acceptance: `ROADMAP_V2.md Phase 4 lane reads "done" with 2026-05-17 completion date. TASK_TREE.md moves PHASE4-CAPTURE-MARK-API to completed table.`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 2 | `PHASE4-CAPTURE-MARK-API.2` | `pending` | Verify all compat aliases documented as legacy. |
| 3 | `PHASE4-CAPTURE-MARK-API.3` | `pending` | Verify all 14 mark helpers have reference entries. |
| 4 | `PHASE4-CAPTURE-MARK-API.4` | `pending` | Finalize: ROADMAP status flip, TASK_TREE move. |

## PHASE4-CAPTURE-MARK-API.1 Inventory (2026-05-17)

### Implementation Surface

163 contracts total in `perl/LinkedSpec/ActionIR/Contracts.pm`. ~100+ are capture/mark/position-specific. Each contract has an `id` (lowercase DSL spelling), an `ir_node` (canonical IR node), a `diag_name` (diagnostic label), an `unresolved_pattern` (regex for legacy scanner), and a `lower` (code transformation sub).

**Anonymous capture boundary family** (17 helpers):
| Canonical | IR node | Notes |
| --- | --- | --- |
| `capture_slice()` | CAPTURE_SLICE | Read from anonymous boundary without moving it |
| `capture_slice_len()` | CAPTURE_SLICE_LEN | Width from anonymous boundary |
| `capture_slice_until_cursor()` | CAPTURE_SLICE_UNTIL_CURSOR | From boundary to current cursor |
| `capture_slice_until_cursor_len()` | CAPTURE_SLICE_UNTIL_CURSOR_LEN | Width from boundary to cursor |
| `capture_slice_line()` | CAPTURE_SLICE_LINE_READ | Line number of anonymous boundary |
| `capture_slice_col()` | CAPTURE_SLICE_COL_READ | Column of anonymous boundary |
| `capture_slice_pos()` | CAPTURE_SLICE_POS_READ | Absolute position of anonymous boundary |
| `start_capture_slice()` | CAPTURE_SLICE_START | Set/advance anonymous boundary to current cursor |
| `start_capture_slice_from(name)` | CAPTURE_SLICE_START_FROM_MARK | Bridge: restore anonymous boundary from named mark |
| `capture_take()` | CAPTURE_SLICE_TAKE | Read AND advance anonymous boundary |
| `capture_take_len()` | CAPTURE_SLICE_TAKE_LEN | Width read AND advance |
| `capture_take_until_cursor()` | CAPTURE_SLICE_TAKE_UNTIL_CURSOR | Read-to-cursor AND advance |
| `capture_take_until_cursor_len()` | CAPTURE_SLICE_TAKE_UNTIL_CURSOR_LEN | Width-to-cursor AND advance |
| `capture_rest()` | CAPTURE_REST | From boundary to end-of-input |
| `capture_rest_len()` | CAPTURE_REST_LEN | Width from boundary to end |
| `capture_take_rest()` | CAPTURE_REST_TAKE | Read-to-end AND advance |
| `capture_take_rest_len()` | CAPTURE_REST_TAKE_LEN | Width-to-end AND advance |

**Compatibility aliases** (same IR node, different DSL spelling):
| Alias | Canonical | Shared IR node |
| --- | --- | --- |
| `capture_from_rule_start()` | `capture_slice()` | CAPTURE_SLICE |
| `capture_len_from_rule_start()` | `capture_slice_len()` | CAPTURE_SLICE_LEN |
| `capture_slice_length()` | `capture_slice_len()` | CAPTURE_SLICE_LEN |
| `capture_slice_here()` | `start_capture_slice()` | CAPTURE_SLICE_START |
| `capture_rest_length()` | `capture_rest_len()` | CAPTURE_REST_LEN |

**Named mark family** (14 helpers):
| Helper | IR node | Purpose |
| --- | --- | --- |
| `mark_here(name)` | MARK_HERE | Write named checkpoint at current cursor |
| `mark_entry_start(name)` | MARK_ENTRY_START | Write at entry-match start |
| `mark_entry_end(name)` | MARK_ENTRY_END | Write at entry-match end |
| `mark_match_start(name)` | MARK_MATCH_START | Write at local-match start |
| `mark_match_end(name)` | MARK_MATCH_END | Write at local-match end |
| `mark_input_start(name)` | MARK_INPUT_START | Write at input position 0 |
| `mark_input_end(name)` | MARK_INPUT_END | Write at end-of-input |
| `mark_capture_slice(name)` | MARK_CAPTURE_SLICE | Bridge: store anonymous boundary as named mark |
| `mark_copy(target, source)` | MARK_COPY | Copy one mark's position to another |
| `mark_pos(name)` | MARK_POS_READ | Read absolute position of mark |
| `mark_line(name)` | MARK_LINE_READ | Read line number of mark |
| `mark_col(name)` | MARK_COL_READ | Read column of mark |
| `mark_exists(name)` | MARK_EXISTS | Test whether mark is set |
| `clear_mark(name)` | CLEAR_MARK | Remove named mark |

**Named mark → capture bridge helpers** (18 helpers):
All follow the pattern: capture-from-named-mark instead of from-anonymous-boundary.
- `capture_from(name)` / `capture_len_from(name)` — read from named mark
- `capture_rest_from(name)` / `capture_rest_len_from(name)` — read to end from named mark
- `capture_take_from(name)` / `capture_take_len_from(name)` — read+advance from named mark
- `capture_take_rest_from(name)` / `capture_take_rest_len_from(name)` — read+advance to end from named mark
- `capture_until_cursor_from(name)` / `capture_until_cursor_len_from(name)` — read to cursor from named mark
- `capture_take_until_cursor_from(name)` / `capture_take_until_cursor_len_from(name)` — read+advance to cursor from named mark
- `capture_between(start, end)` / `capture_len_between(start, end)` — span between two named marks
- `capture_take_between(start, end)` / `capture_take_between_len(start, end)` — span-between AND advance

**Cursor family** (5 helpers): `cursor_pos()`, `cursor_line()`, `cursor_col()`, `cursor_rest()`, `cursor_rest_len()`.
**Whole-input family** (6 helpers): `input_text()`, `input_len()`, `input_end_pos()`, `input_end_line()`, `input_end_col()`, `input_slice()`.
**Immediate-match (entry) family** (12 helpers): `entry_text()`, `entry_len()`, `entry_line()` / `entry_start_line()`, `entry_col()` / `entry_start_col()`, `entry_start_pos()`, `entry_end_pos()`, `entry_end_line()`, `entry_end_col()`, `entry_group(n)`, `entry_groups()`, `entry_named(name)`, `entry_has(name)`, `entry_map()`.
**Local-match family** (12 helpers): Same shape as immediate-match, prefixed `match_*`.

**Compatibility map aliases**: `entry_named_map()` ↔ `entry_map()`, `match_named_map()` ↔ `match_map()`.

**Legacy helpers**: `$CAPTURE` (capture_macro), `capture(label)`, `capture_if(label)`, `CAPTURE_IF()`, `ibacktrack(label)` / `IBACKTRACK()`, `backtrack(label)` / `BACKTRACK()` — all documented as legacy compatibility in source-boundary-helper-reference.md; BACKTRACK/IBACKTRACK contracts fully documented in Phase 3.

### Shipped Spec Usage

**Zero legacy usage**: No shipped `.spec` file uses `$CAPTURE`, `capture(label)`, `capture_if(label)`, `CAPTURE_IF()`, raw `$IPOS`/`$IMATCH`/`pos($$STRING)`, `capture_slice()`, or `@mark`. All 19 shipped specs are simple extraction rules without capture/mark semantics. This means Phase 4 is purely a documentation formalization task — no spec migration needed.

### Documentation Surface

Two book chapters (594 lines total):
1. **`capture-marks-and-source-locations.md`** (171 lines): Mental model chapter. Covers the 5 anchor families (capture, mark, cursor, entry, match), the distinction between anonymous boundary and named marks, and the family choice guide.
2. **`source-boundary-helper-reference.md`** (423 lines): Comprehensive reference. Covers core vocabulary, anchor types, capture helpers (anonymous, named-mark bridge, span-between, advancing), mark helpers, cursor/input/entry/match helpers, and the compatibility aliases table.

### Gaps Identified

**Gap 1 — Some compat aliases not explicit in reference**: The reference table mentions `capture_slice_length()` and `capture_from_rule_start()` but doesn't explicitly list every alias pair. `capture_slice_here()`, `capture_rest_length()`, `entry_named_map()`, and `match_named_map()` are not in the legacy table. → **PHASE4-CAPTURE-MARK-API.2**

**Gap 2 — Mark helper completeness**: The 14 mark helpers have partial coverage in the reference. `mark_entry_start/end`, `mark_match_start/end`, `mark_input_start/end`, `mark_copy`, `mark_pos`, `mark_line`, `mark_col`, `mark_exists`, `clear_mark` are implemented but not all have individual entries in the reference table. → **PHASE4-CAPTURE-MARK-API.3**

**Non-gap — Shipped specs**: Zero legacy usage — no migration needed.
**Non-gap — Anonymous capture boundary**: All 17 helpers documented in capture-marks-and-source-locations.md.
**Non-gap — Cursor/input/entry/match families**: All documented in the reference chapter.
**Non-gap — BACKTRACK/IBACKTRACK**: Documented in Phase 3.

### Phase 4 Exit Criteria Status

Per ROADMAP_V2.md Phase 4 acceptance:
- Named marks and anonymous capture boundaries are first-class, transparent concepts: **DONE** (comprehensive docs)
- All capture/mark helpers have clear documented semantics: **MOSTLY DONE** (2 minor gaps: compat alias table, mark helper completeness)
- Legacy `$CAPTURE` and compatibility aliases preserved but documented as legacy: **MOSTLY DONE** (some aliases not in legacy table)
- Shipped `.spec` files use canonical helpers where practical: **DONE** (zero legacy usage)
- Phase 4 exit criteria met per ROADMAP.md: **PENDING** (resolve gaps .2, .3)

## Decisions

- `2026-05-17`: Completed PHASE4-CAPTURE-MARK-API.1 inventory. 163 contracts audited (~100+ capture/mark). Zero shipped spec legacy usage. Documentation is 2 chapters / 594 lines. Two minor gaps: compat alias table completeness (.2) and mark-helper reference completeness (.3). Created leaves .2, .3, .4.
- `2026-05-16`: Created task tree. The capture/mark API has an extensive landed surface spanning anonymous-boundary, named-mark, cursor, whole-input, immediate-match, and local-match families.

## Open Questions

- ~~Are there remaining raw `$IPOS`/`$IMATCH`/`$$STRING` occurrences in shipped `.spec` files that should migrate?~~ Resolved: Zero legacy usage in any shipped `.spec`. No migration needed.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-05-17` | `PHASE4-CAPTURE-MARK-API.1` | Audited 163 Contracts.pm entries (~100+ capture/mark/position). Verified zero legacy usage in 19 shipped specs. Reviewed 2 book chapters (594 lines). Identified 12 compatibility alias pairs, 6 families, 14 mark helpers. | Pass — 2 minor doc gaps found. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `PHASE4-CAPTURE-MARK-API.1` | `pending` | — |

## Changelog

- `2026-05-17`: Completed PHASE4-CAPTURE-MARK-API.1 inventory. 163 contracts, 100+ capture/mark helpers across 6 families. Zero shipped spec legacy usage. Created leaves .2, .3, .4.
- `2026-05-16`: Created task tree from template.
