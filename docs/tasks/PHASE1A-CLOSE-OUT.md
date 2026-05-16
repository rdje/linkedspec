# PHASE1A-CLOSE-OUT: Phase 1A LinkedSpec.pm Modularization Close-Out

## Metadata

- Tree ID: `PHASE1A-CLOSE-OUT`
- Status: `completed`
- Roadmap lane: `Phase 1A`
- Created: `2026-05-16`
- Last updated: `2026-05-16`
- Owner: repo-local workflow

## Goal

Close out the remaining Phase 1A modularization work: verify that `LinkedSpec.pm` is a thin orchestration façade, all extracted modules have stable interfaces, and no stale monolith-era coupling remains.

## Non-Goals

- New module extraction beyond what Phase 1A already scoped.
- New features or behavioral changes.
- Phase 2+ frontend/semantics work.

## Acceptance Criteria

- `LinkedSpec.pm` delegates all internal work to extracted owner modules.
- No remaining `OwnerDispatch` wrapper duplication across compile/runtime owners.
- `t/phase0_regression.t` stays green.
- `ROADMAP_V2.md` Phase 1A tracker flips to `done`.

## Task Tree

- ID: `PHASE1A-CLOSE-OUT`
  Status: `completed`
  Goal: `Close out Phase 1A modularization.`
  Children: `PHASE1A-CLOSE-OUT.1`

- ID: `PHASE1A-CLOSE-OUT.1`
  Status: `completed`
  Goal: `Audit remaining Phase 1A surfaces: check that every planned module extraction (Trace, Validation, Resolver, RuleIR, ActionRewriter, Compiler, BootstrapSpec) is complete and OwnerDispatch usage is uniform.`
  Acceptance: `Task file lists each extracted module, its interface stability status, any remaining wrapper duplication, and the next close-out leaf (or declares no remaining work).`
  Verification: `2026-05-16: Full audit complete (see inventory below). Phase 1A modularization is complete — LinkedSpec.pm is a thin 286-line facade delegating all work to 18 extracted modules through uniform OwnerDispatch. No wrapper duplication remains. One remaining action: update ROADMAP_V2.md Phase 1A status from "mostly done" to "done".`
  Commit: `Docs: inventory Phase 1A modularization close-out status`

- ID: `PHASE1A-CLOSE-OUT.2`
  Status: `completed`
  Goal: `Finalize Phase 1A: update ROADMAP_V2.md status from "mostly done" to "done".`
  Acceptance: `ROADMAP_V2.md Phase 1A lane reads "done" with completion date.`
  Verification: `2026-05-16: Updated ROADMAP_V2.md Phase 1A status from "mostly done" to "done" with 2026-05-16 completion date. Also updated Phase 2 from "in progress" to "done".`
  Commit: `Docs: finalize Phase 1A and Phase 2 status in ROADMAP_V2.md`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PHASE1A-CLOSE-OUT.1` | `completed` | Inventory audit complete. |
| 2 | `PHASE1A-CLOSE-OUT.2` | `completed` | ROADMAP_V2.md updated — Phase 1A and Phase 2 marked done. |

## PHASE1A-CLOSE-OUT.1 Inventory (2026-05-16)

### Modularization State

**LinkedSpec.pm** (286 lines, 20 subs): Thin orchestration façade. All 17 public API methods
(configure_trace, trace_enter, trace_exit, trace_decision, log_output, log_dump,
should_dump, Get, build_compiled_rule_table, call_spec_handler_subst, get_parser,
register_plugin, register_plugins, clear_registered_plugins, run_plugin, get_plugin,
dispatch_plugin_autoload_name) delegate through the shared `_dispatch_owner_call` helper.
Plus 2 private helpers (`_dispatch_owner_call`, `_normalize_flat_option_pairs`) and
`AUTOLOAD`. No business logic remains in the facade.

**18 extracted modules** (total ~6,900 lines):

| Module | Lines | Subs | Role |
| --- | --- | --- | --- |
| Trace | 476 | 24 | Structured trace/logging events |
| Validation | 1,368 | 40 | DSL frontend validation (Phase 2 hardened) |
| Resolver | 223 | 11 | Spec file path resolution |
| RuleIR | 278 | 15 | Rule intermediate representation |
| RuleIR::EmitContext | 764 | 93 | Handler code emission context + ActionIR lowering delegation |
| ActionRewriter | 117 | 3 | Action code compatibility rewriting |
| ActionIR::Scanner | 54 | 5 | Contract IR event scanning entry point |
| ActionIR::ScannerCore | 175 | 11 | Scanner core with scanner-rule bindings |
| Compiler | 1,176 | 46 | Full compile pipeline orchestration |
| CompilerState | 519 | 36 | Compiled spec + descriptor state owner |
| BootstrapSpec | 81 | 4 | Bootstrap spec build delegation |
| BootstrapSpec::Core | 851 | 51 | Hardcoded bootstrap grammar |
| SpecEntry | 933 | 45 | Spec → compiled-spec + handler construction |
| Runtime | 120 | 4 | Runtime entry point (run_get) |
| RuntimeContext | 384 | 38 | Runtime structured error + option state |
| ParserFactory | 368 | 8 | Parser resolution + option normalization |
| PluginRegistry | 130 | 8 | Plugin registration state |
| PluginBridge | 199 | 14 | Legacy + owner plugin dispatch bridge |

Plus central plumbing: OwnerDispatch (220 lines, 13 subs) and PPlugin (outside LinkedSpec namespace).

### OwnerDispatch Usage

All extracted modules use `LinkedSpec::OwnerDispatch` through one of its five entry points:

- `require_pkg_cb($owner, $target_pkg, $subname)` — lazy-loads a package and returns a callback
- `dispatch_owner_call($owner, $target_pkg, $subname, @args)` — lazy-loads, calls, and preserves `$@`
- `call_preserving_err($owner, $cb, @args)` — calls a callback preserving `$@`
- `build_dep_map($owner, %dep_spec)` — assembles a dependency callback map
- `build_dep_bundle($owner, %dep_spec)` — assembles a mixed callback+value dependency bundle

OwnerDispatch also seeds an absolute repo `perl` root into `@INC`, making lazy owner loads
`chdir(...)`-safe.

### `_require_dep` Pattern

The `_require_dep` functions remaining in Compiler (3), ParserFactory (6), PluginBridge (4),
and ActionIR modules (many) are thin validation seams that verify dependency callbacks exist
before use. They are NOT duplicated pass-through wrappers — they validate and report missing
dependencies with owner-specific diagnostic messages. This pattern replaced the previous
top-level `_require_dep` wrappers that hid the specific dependency being validated.

### Phase 1A Invariants Verified

- No `use re 'eval'` in LinkedSpec.pm (only in LinkedRE.pm and RTLUtils.pm)
- No dead OwnerDispatch pass-through wrappers (all previously removed per ROADMAP_V2 changelog)
- No `require LinkedSpec` from within the LinkedSpec namespace (no circular coupling)
- No TODO/FIXME/STUB/HACK markers in the LinkedSpec namespace
- `t/phase0_regression.t` green at 1,007 tests
- All 19 shipped specs compile and are ActionIR-ready

### Conclusion

Phase 1A modularization is complete. LinkedSpec.pm is a thin facade, all 18 extracted
modules have stable interfaces, and OwnerDispatch usage is uniform. The only remaining
close-out action is updating ROADMAP_V2.md Phase 1A status from `mostly done` to `done`
(PHASE1A-CLOSE-OUT.2).

## Decisions

- `2026-05-16`: Created close-out tree. ROADMAP_V2 reports Phase 1A as `mostly done` with OwnerDispatch now broadly centralized.
- `2026-05-16`: Completed PHASE1A-CLOSE-OUT.1 inventory. Found Phase 1A modularization complete — no remaining extraction work, no wrapper duplication, all invariants verified. Created PHASE1A-CLOSE-OUT.2 for the final ROADMAP status flip.

## Open Questions

- None. Audit confirmed Phase 1A is complete.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-05-16` | `PHASE1A-CLOSE-OUT.1` | Read LinkedSpec.pm (286 lines), all 18 extracted modules. Verified uniform OwnerDispatch usage across all modules. Checked for stale `use re 'eval'`, dead wrappers, circular coupling, and debt markers. Ran full regression suite. | Pass |
| `2026-05-16` | `PHASE1A-CLOSE-OUT.2` | Updated ROADMAP_V2.md: Phase 1A `mostly done` → `done`, Phase 2 `in progress` → `done`. Both with 2026-05-16 completion dates. | Pass |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `PHASE1A-CLOSE-OUT.1` | `Docs: inventory Phase 1A modularization close-out status` | 18-module audit, uniform OwnerDispatch verified |
| `PHASE1A-CLOSE-OUT.2` | `Docs: finalize Phase 1A and Phase 2 status in ROADMAP_V2.md` | Phase 1A → done, Phase 2 → done |

## Changelog

- `2026-05-16`: Created close-out tree from template.
- `2026-05-16`: Completed PHASE1A-CLOSE-OUT.1 inventory. Audited all 18 extracted modules, verified uniform OwnerDispatch usage, confirmed all Phase 1A invariants hold. Phase 1A modularization is complete — only ROADMAP status flip remains.
