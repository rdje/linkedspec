# BACKBONE-ACTION-IR-LOWERING: Backbone Item 3 — ActionIR/Rewrite/Lowering Pipeline

## Metadata

- Tree ID: `BACKBONE-ACTION-IR-LOWERING`
- Status: `done`
- Roadmap lane: `Backbone refactor track`
- Created: `2026-05-16`
- Last updated: `2026-05-16`
- Owner: repo-local workflow

## Goal

Complete the structured ActionIR/rewrite/lowering pipeline: finish the remaining ActionIR/EmitContext owner-contract cleanup, reduce compatibility-surface coupling, and drive toward the final objective of eliminating raw Perl code blocks in `.spec`.

## Non-Goals

- Full action AST/IR lowering (still planned but deferred past close-out).
- New DSL features outside the ActionIR lowering surface.
- Bootstrap grammar changes (Backbone Item 1, done).

## Acceptance Criteria

- All ActionIR owners spend `OwnerDispatch` uniformly with no duplicate local validators.
- EmitContext owner-contract is clean and auditable.
- Compatibility-surface reduction is complete for the current shipped surface.
- `t/phase0_regression.t` stays green.
- Backbone Item 3 tracker flips to `done`.

## Task Tree

- ID: `BACKBONE-ACTION-IR-LOWERING`
  Status: `done`
  Goal: `Complete the ActionIR lowering pipeline close-out.`
  Children: `BACKBONE-ACTION-IR-LOWERING.1`

- ID: `BACKBONE-ACTION-IR-LOWERING.1`
  Status: `done`
  Goal: `Audit remaining ActionIR owner surfaces: verify that every ActionIR owner (Scanner, StatementSplit, CanonicalEvents, Diagnostics, RewritePipeline, ArrayPipeline, Contracts, ControlFlow, MethodLowering, ValueExpr, FlowExpr, DeclareMethod) has clean OwnerDispatch usage and no stale duplicate validators.`
  Acceptance: `Task file lists each ActionIR owner, its OwnerDispatch status, any remaining duplicate validators or compatibility wrappers, and names the next close-out leaf.`
  Verification: `2026-05-17: Full audit complete (see inventory section below). All 12 ActionIR owners + ScannerCore/StatementSplitCore/CanonicalEventsCore + EmitContext use OwnerDispatch uniformly. Zero old-style top-level _require_dep(...) validator wrappers remain — all die messages with _require_dep are inline dependency validation inside the actual work functions (the intended final state per ROADMAP_V2.md). No duplicate validators, no compatibility wrappers. Backbone Item 3 ActionIR owner-contract cleanup is complete. Full suite: Files=1, Tests=1007, PASS (no code changes — audit-only leaf).`
  Commit: `pending`

## Current Frontier

All leaves complete. The BACKBONE-ACTION-IR-LOWERING tree is finished.

## Decisions

- `2026-05-17`: Completed BACKBONE-ACTION-IR-LOWERING.1 audit (see inventory section below). All 12 ActionIR owners verified clean. Zero old-style _require_dep wrappers. Backbone Item 3 ActionIR owner-contract cleanup is complete.
- `2026-05-16`: Created task tree. Backbone Item 3 is `mostly done` per `ROADMAP_V2.md` with extensive OwnerDispatch centralization already landed.

## Open Questions

- Are there remaining local `_require_dep(...)` wrappers in any ActionIR owner? Resolved: No. All _require_dep references are inline validation inside work functions, not separate top-level wrappers. See inventory section.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-05-17` | `BACKBONE-ACTION-IR-LOWERING.1` | Audited all 12 ActionIR owners + ScannerCore/StatementSplitCore/CanonicalEventsCore + EmitContext. Every owner uses OwnerDispatch uniformly via `build_dep_map` in `default_deps_for_package`. Zero old-style top-level `_require_dep(...)` validator wrappers. All `_require_dep` die messages are inline validation inside work functions. Scanner.pm cleanest (54 lines, `require_pkg_cb` / `call_preserving_err`). Zero duplicate validators, zero compatibility wrappers. Full suite: Files=1, Tests=1007, PASS. | Pass — ActionIR owner-contract cleanup is complete. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `BACKBONE-ACTION-IR-LOWERING.1` | `pending` | — |

## Changelog

- `2026-05-17`: Completed BACKBONE-ACTION-IR-LOWERING.1 audit. All 12 ActionIR owners clean. Findings documented in inventory section below.

## BACKBONE-ACTION-IR-LOWERING.1 Inventory (2026-05-17)

### Audit Scope

Audited all 12 ActionIR owners plus 3 internal Core modules plus EmitContext:

| Module | Lines | OwnerDispatch | Inline dep checks | Old-style wrappers | Status |
| --- | --- | --- | --- | --- | --- |
| Scanner.pm | 54 | `build_dep_map`, `require_pkg_cb`, `call_preserving_err` | 0 | 0 | Cleanest |
| StatementSplit.pm | 44 | `build_dep_map`, `require_pkg`, `call_preserving_err` | 1 (`trim_action_ir_value`) | 0 | Clean |
| CanonicalEvents.pm | 103 | `build_dep_map`, `require_pkg`, `call_preserving_err` | 2 (`trim_action_ir_value`, `split_action_ir_statements`) | 0 | Clean |
| Diagnostics.pm | 182 | `build_dep_map` | 2 (`split_action_ir_statements`, `scan_contract_ir_events`) | 0 | Clean |
| RewritePipeline.pm | 164 | `build_dep_map` | 4 (contracts, ir_nodes, canonical_events, unresolved_helpers) | 0 | Clean |
| ArrayPipeline.pm | 318 | `build_dep_map` | 7 (trim, strip_delimiters, extract_array_symbol, parse_method, is_bare_token, extract_scalar ×2 contexts) | 0 | Clean |
| Contracts.pm | 2,176 | `build_dep_map` | 1 (`_require_lowering_deps`) | 0 | Clean |
| ControlFlow.pm | 1,095 | `build_dep_map` | 20 (one per lowering function) | 0 | Clean |
| MethodLowering.pm | 1,884 | `build_dep_map` | 10 (one per method/value/assignment/return lowering function) | 0 | Clean |
| ValueExpr.pm | 416 | `build_dep_map` | 9 (one per value-expression lowering function) | 0 | Clean |
| FlowExpr.pm | 370 | `build_dep_map` | 5 (one per flow-expression lowering function) | 0 | Clean |
| DeclareMethod.pm | 265 | `build_dep_map` | 6 (one per declare/assign lowering function) | 0 | Clean |
| ScannerCore.pm | — | `require_pkg` | 0 (keeps `_scanner_rule_dep_bindings` as sole validation seam) | 0 | Clean |
| StatementSplitCore.pm | 359 | `require_pkg` | 0 | 0 | Clean |
| CanonicalEventsCore.pm | 213 | None (pure logic, no deps) | 0 | 0 | Clean |
| EmitContext.pm | 764 | `require_pkg`, `require_pkg_cb`, `call_preserving_err` | 0 | 0 | Clean |

### Key Finding: Old-Style vs New-Style _require_dep

**Old-style (eliminated everywhere):** A separate top-level `_require_dep($deps)` wrapper function that validated ALL dependency callbacks before calling the real work function. This created duplicate validation — the wrapper checked, then the work function might check again.

**New-style (current everywhere):** Each public entry point validates its own needed dependency callbacks inline. The `_require_dep` in die messages is now only an error-attribution prefix (e.g., `"(LinkedSpec::ActionIR::RewritePipeline::_require_dep) -E- missing dependency callback 'build_action_lowering_contracts'"`), not a separate wrapper function.

### Conclusion

Backbone Item 3 ActionIR owner-contract cleanup is complete. All owners:
- Use `OwnerDispatch` uniformly via `build_dep_map` in `default_deps_for_package`.
- Have zero old-style top-level `_require_dep(...)` validator wrappers.
- Keep each public entry point as its own dependency-validation seam.
- No duplicate validators, no compatibility wrappers, no local package-loader wrappers.

The `_require_dep` message prefix could be renamed to avoid confusion with the old wrapper pattern, but that is cosmetic — it does not affect correctness or the owner-contract cleanup goal.
