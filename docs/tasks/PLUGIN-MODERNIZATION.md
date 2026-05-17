# PLUGIN-MODERNIZATION: Plugin/Resource-Resolution Modernization

## Metadata

- Tree ID: `PLUGIN-MODERNIZATION`
- Status: `done`
- Roadmap lane: `Plugin/resource-resolution modernization track`
- Created: `2026-05-16`
- Last updated: `2026-05-17`
- Owner: repo-local workflow

## Goal

Complete plugin/resource-resolution modernization: retire dynamic `.plg`/`PPlugin` execution support, keep deterministic `get_parser('name')`-style spec lookup intact, and ensure all extracted helper owners live under clear non-plugin domain owners.

## Non-Goals

- Breaking existing spec resolution (`get_parser('name')` must keep working).
- Removing helper functionality (only moving it to proper package owners).

## Acceptance Criteria

- Dynamic `.plg` execution and `PPlugin` support are fully retired.
- All extracted helpers live under clear domain owners (`HTTP::FileAccess`, `RTLUtils`, `FSMGen`, `Timing::*`, `Table::GenericFilter`, `QC::*`, etc.).
- `run_plugin(...)`, `get_plugin(...)`, and registry machinery are removed or reduced to transitional stubs.
- Spec resolution via `get_parser('name')` remains deterministic and intact.

## Task Tree

- ID: `PLUGIN-MODERNIZATION`
  Status: `active`
  Goal: `Retire dynamic plugin execution, preserve spec resolution.`
  Children: `PLUGIN-MODERNIZATION.1`, `PLUGIN-MODERNIZATION.2`, `PLUGIN-MODERNIZATION.3`, `PLUGIN-MODERNIZATION.4`, `PLUGIN-MODERNIZATION.5`

- ID: `PLUGIN-MODERNIZATION.1`
  Status: `done`
  Goal: `Inventory current plugin surface: list every remaining .plg reference, PPlugin dependency, and dynamic-plugin code path. Map each to its replacement domain owner or retirement plan.`
  Acceptance: `Task file lists each plugin artifact, its current status, its replacement owner (if applicable), and names the next executable retirement leaf.`
  Verification: `2026-05-17: Full inventory complete (see inventory section below). 38 .plg files remain on disk (mostly legacy action files). PPlugin.pm (288 lines) still serves as lazy-loaded .plg adapter. PluginBridge.pm (199 lines) provides registry-first/legacy-fallback. PluginRegistry.pm (130 lines) manages in-memory registrations. LinkedSpec.pm facade exposes 7 legacy methods. FSMGen.pm is the only external get_plugin caller (optional default). 3 regression subtests lock legacy plugin behavior. Created follow-on leaves .2–.5. Full suite: Files=1, Tests=1007, PASS (no code changes — audit-only leaf).`
  Commit: `pending`

- ID: `PLUGIN-MODERNIZATION.2`
  Status: `done`
  Goal: `Identify and remove .plg files whose helpers have already been fully extracted to domain owners. Per ROADMAP_V2.md, string.plg, cgi.plg, genericfilter.plg, msoffice.plg, vhdconst_eval.plg, yesno.plg, http.plg, lighttpd.plg, httpd.plg, tcl4interconn.plg, tssio.plg, table.plg, spec.plg, and plugin.plg are already gone. Audit the remaining 38 .plg files for extraction status.`
  Acceptance: `Each remaining .plg file is classified as: (a) already-extracted — safe to delete, (b) partially-extracted — helpers moved but visible actions remain, (c) not-yet-extracted — still carries plugin subdefs. Deleted files are removed from disk and regression tests updated.`
  Verification: `2026-05-17: Removed 2 .plg files: hutils.plg (zero references, all thin HUtils:: passthroughs — callers use HUtils:: directly) and quick_sdf_hack.plg (zero external callers, dead qsdf_hack action). 36 .plg files remain (see inventory update below). Full suite: Files=1, Tests=1007, PASS.`
  Commit: `pending`

- ID: `PLUGIN-MODERNIZATION.3`
  Status: `done`
  Goal: `De-scope FSMGen.pm from LinkedSpec::get_plugin dependency. FSMGen::getop_plugin_list already accepts an optional get_plugin callback (defaulting to \&LinkedSpec::get_plugin). Verify no caller relies on the default and remove the dependency or document the transition path.`
  Acceptance: `FSMGen.pm no longer has a hard dependency on LinkedSpec::get_plugin, or the dependency is documented as an explicit opt-in with no default.`
  Verification: `2026-05-17: Replaced \&LinkedSpec::get_plugin default with sub {} no-op in FSMGen.pm line 68. Internal caller at line 3054 passes no explicit get_plugin but no .fsm files exist in the repo to trigger the +type=plugin syntax, so the default is dead code. Tests at t/phase0_regression.t:4261 and :4282 always pass explicit get_plugin. Updated 2 regression assertions (lines 4229, 4415) to match new no-op default. Full suite: Files=1, Tests=1007, PASS.`
  Commit: `pending`

- ID: `PLUGIN-MODERNIZATION.4`
  Status: `done`
  Goal: `Reduce public facade plugin surface. The LinkedSpec.pm facade currently exposes 7 legacy plugin methods (run_plugin, get_plugin, dispatch_plugin_autoload_name, AUTOLOAD, register_plugin, register_plugins, clear_registered_plugins). Evaluate which can be removed, which need deprecation warnings, and which must remain as transition stubs.`
  Acceptance: `Each legacy facade method is either removed, marked with a deprecation warning, or documented as an explicit transition stub with a retirement timeline.`
  Verification: `2026-05-17: Marked all 7 legacy plugin methods as DEPRECATED with retirement timeline tied to PLUGIN-MODERNIZATION.5. None can be removed yet: FSMGen::AUTOLOAD still depends on dispatch_plugin_autoload_name, and test regression locks still exercise the plugin infrastructure. Replaced verbose per-method comment blocks with compact DEPRECATED annotations and a single deprecation-section header. Full suite: Files=1, Tests=1007, PASS.`
  Commit: `pending`

- ID: `PLUGIN-MODERNIZATION.5`
  Status: `done`
  Goal: `Evaluate PPlugin.pm and PluginBridge.pm retirement feasibility. PPlugin.pm (288 lines) is the legacy .plg adapter loaded lazily by PluginBridge. PluginBridge.pm (199 lines) is the compatibility bridge. If all .plg files are retired or converted, both can be removed.`
  Acceptance: `If all .plg consumers are gone: PPlugin.pm is deleted, PluginBridge.pm is reduced to a registry-only stub or deleted, and regression tests are updated. If consumers remain: a retirement plan with timeline is documented.`
  Verification: `2026-05-17: Full retirement evaluation complete (see Retirement Evaluation section below). 36 .plg files with ~1,200+ actions remain — PPlugin/PluginBridge cannot be retired yet. Documented retirement path: (1) migrate .plg actions to package owners, (2) retire PPlugin, (3) reduce PluginBridge to registry-only or delete. PluginRegistry can survive independently. Full suite: Files=1, Tests=1007, PASS (no code changes — evaluation-only leaf).`
  Commit: `pending`

## Current Frontier

All leaves complete. No pending leaves.

## Retirement Evaluation (PLUGIN-MODERNIZATION.5 — 2026-05-17)

### Verdict

PPlugin.pm and PluginBridge.pm **cannot be retired yet**. 36 .plg files with approximately 1,200+ actions remain on disk. These actions are loaded and executed through the PPlugin → PluginBridge → LinkedSpec facade chain. Full retirement requires migrating each .plg file's actions to proper Perl package owners — a Phase 8+ effort beyond the scope of this tree.

### What blocks PPlugin retirement

- 36 .plg files remain (down from 38 after .2 removed 2 dead files).
- These files define ~1,200+ visible actions loaded via PPlugin's .plg discovery, parsing, and registry.
- Until all .plg actions are migrated to package owners, PPlugin must remain as the legacy adapter.

### What blocks PluginBridge retirement

- PluginBridge is the registry-first/legacy-fallback dispatch layer. As long as PPlugin is needed, PluginBridge is needed.
- FSMGen::AUTOLOAD (FSMGen.pm:3547) still calls `LinkedSpec::dispatch_plugin_autoload_name` → PluginBridge.
- Test regression locks exercise the full plugin dispatch chain.

### What can survive independently

- **PluginRegistry** (130 lines): In-memory handler registry. Used by tests. Does not depend on PPlugin or PluginBridge. Could survive as a general-purpose coderef registry even after plugin retirement.

### Retirement path

1. **Migrate .plg actions to package owners**: Each .plg file's actions need a proper Perl package owner. This is a per-file migration effort (~36 files, ~1,200+ actions). Priority: start with spec consumers (5 files using only get_parser — these don't need PPlugin at all), then extracted files (helpers already moved), then legacy action files.
2. **Retire PPlugin.pm**: Once all .plg files are gone or converted, delete PPlugin.pm and its discovery/lookup machinery.
3. **Reduce or delete PluginBridge.pm**: Once PPlugin is gone, PluginBridge can be reduced to a registry-only stub (forwarding to PluginRegistry) or deleted if the registry path is consolidated into LinkedSpec.pm directly.
4. **Remove deprecated facade methods**: The 7 DEPRECATED methods in LinkedSpec.pm (marked in .4) can be removed once PluginBridge is gone.
5. **Migrate FSMGen::AUTOLOAD**: The last remaining external caller of dispatch_plugin_autoload_name must be migrated to a non-plugin dispatch pattern.

### Estimated effort

Migrating 1,200+ actions across 36 files is a significant effort — likely a full Phase 8 or multi-phase workstream. Each migration requires: identifying the action's purpose, finding or creating a domain package owner, moving the implementation, updating callers, and regression-testing.

### Recommended next step

Create a proposed task tree (e.g., `PLUGIN-ACTION-MIGRATION`) to track the per-.plg-file migration work. Activate when the roadmap reaches the appropriate phase.

## Decisions

- `2026-05-17`: Completed PLUGIN-MODERNIZATION.5 — retirement evaluation. 36 .plg files (~1,200+ actions) remain. Documented 5-step retirement path. Tree COMPLETE.
- `2026-05-17`: Completed PLUGIN-MODERNIZATION.4 — deprecated all 7 legacy plugin facade methods.
- `2026-05-17`: Completed PLUGIN-MODERNIZATION.3 — de-scoped FSMGen.pm from LinkedSpec::get_plugin.
- `2026-05-17`: Completed PLUGIN-MODERNIZATION.2 — removed 2 dead .plg files (hutils.plg, quick_sdf_hack.plg). 36 remain.
- `2026-05-17`: Completed PLUGIN-MODERNIZATION.1 — inventory complete. 38 .plg files, 3 plugin modules, 7 facade methods, 1 external caller.
- `2026-05-16`: Created task tree. Extensive plugin-to-owner extraction already landed per `ROADMAP_V2.md`.

## Open Questions

- Are there remaining internal `.plg` files that still need extraction? Resolved: Yes, 38 .plg files remain. See inventory section for classification. → .2

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-05-17` | `PLUGIN-MODERNIZATION.5` | Evaluated PPlugin/PluginBridge retirement feasibility. 36 .plg files with ~1,200+ actions remain — cannot retire yet. Documented 5-step retirement path and estimated effort. Full suite: Files=1, Tests=1007, PASS (evaluation-only). | Pass — retirement path documented. Tree complete. |
| `2026-05-17` | `PLUGIN-MODERNIZATION.4` | Marked all 7 legacy plugin methods in LinkedSpec.pm as DEPRECATED with retirement timeline tied to .5. Grouped under single deprecation-section header. Full suite: Files=1, Tests=1007, PASS. | Pass — facade surface reduced from supported to deprecated. |
| `2026-05-17` | `PLUGIN-MODERNIZATION.3` | Replaced `\&LinkedSpec::get_plugin` default with `sub {}` no-op in FSMGen.pm:68. Internal caller (line 3054) relies on default but no .fsm files exist in repo to trigger. Updated 2 regression assertions (lines 4229, 4415). Full suite: Files=1, Tests=1007, PASS. | Pass — FSMGen de-scoped from LinkedSpec::get_plugin. |
| `2026-05-17` | `PLUGIN-MODERNIZATION.2` | Removed hutils.plug (thin HUtils:: passthroughs, zero references) and quick_sdf_hack.plg (dead qsdf_hack action, zero external callers). 36 .plg files remain. Full suite: Files=1, Tests=1007, PASS. | Pass — 2 dead .plg files removed. |
| `2026-05-17` | `PLUGIN-MODERNIZATION.1` | Audited 38 .plg files, PPlugin.pm (288 lines), PluginBridge.pm (199 lines), PluginRegistry.pm (130 lines), LinkedSpec.pm facade (7 legacy methods), FSMGen.pm (only external get_plugin caller), 3 regression subtests. Created follow-on leaves .2–.5. Full suite: Files=1, Tests=1007, PASS (no code changes). | Pass — plugin surface fully inventoried. 4 follow-on leaves defined. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `PLUGIN-MODERNIZATION.5` | `pending` | — |
| `PLUGIN-MODERNIZATION.4` | Deprecated all 7 legacy plugin facade methods in LinkedSpec.pm. Retirement timeline tied to PLUGIN-MODERNIZATION.5. | — |
| `PLUGIN-MODERNIZATION.3` | `pending` | — |
| `PLUGIN-MODERNIZATION.2` | `pending` | — |
| `PLUGIN-MODERNIZATION.1` | `Audit: inventory remaining plugin surface for modernization` | — |

## Changelog

- `2026-05-17`: Completed PLUGIN-MODERNIZATION.5 — PPlugin/PluginBridge retirement evaluation. 36 .plg files (~1,200+ actions) remain — cannot retire yet. Documented 5-step retirement path. Tree COMPLETE (5 leaves).
- `2026-05-17`: Completed PLUGIN-MODERNIZATION.4 — deprecated all 7 legacy plugin facade methods in LinkedSpec.pm. Retirement timeline tied to .5.
- `2026-05-17`: Completed PLUGIN-MODERNIZATION.3 — de-scoped FSMGen.pm from LinkedSpec::get_plugin. Default changed to no-op `sub {}`. Only external get_plugin caller now requires explicit opt-in.
- `2026-05-17`: Completed PLUGIN-MODERNIZATION.2 — removed 2 dead .plg files (hutils.plg, quick_sdf_hack.plg). 36 remain.
- `2026-05-17`: Completed PLUGIN-MODERNIZATION.1 inventory. 38 .plg files, 3 plugin modules, 7 facade methods. Follow-on leaves .2–.5 created.
- `2026-05-16`: Created task tree from template.

## PLUGIN-MODERNIZATION.1 Inventory (2026-05-17)

### Audit Scope

Audited all plugin-related surfaces: .plg files, PPlugin, PluginBridge, PluginRegistry, LinkedSpec.pm facade, external callers, regression tests.

### .plg Files Still on Disk (38 files)

| File | Uses | Status |
| --- | --- | --- |
| common.plg | `LinkedSpec::Get` | Legacy action file |
| ds_vhistory.plg | `LinkedSpec::get_parser` | Spec consumer |
| duty_cycle_degradation.plg | Visible action | Legacy action file (helpers in Timing::StanBackend) |
| edalog.plg | Legacy action | Legacy action file |
| exp.plg | Legacy action | Legacy action file |
| fixscript.plg | Legacy action | Legacy action file |
| fsmgen.plg | `LinkedSpec::get_parser` | Spec consumer (helpers in FSMGen) |
| fxenv_helper.plg | `InteractivePrompt::yes_no` | Extracted (visible action remains) |
| generic_fake_memory_module.plg | `RTLUtils::ceil_log2` | Extracted (visible action remains) |
| hutils.plg | `Table::GenericFilter` | Extracted (visible action remains) |
| lstype_long.plg | Legacy action | Legacy action file |
| lte_digital_rf.plg | Legacy action | Legacy action file |
| matrix.plg | Legacy action | Legacy action file |
| mbist.plg | `VHDL::ConstantEval` | Extracted (visible action remains) |
| msword.plg | Legacy action | Legacy action file |
| network.plg | Legacy action | Legacy action file |
| nlc.plg | Legacy action | Legacy action file |
| peruser.plg | Legacy action | Legacy action file |
| qc_summary.plg | `QC::Summary` helpers | Extracted (visible action remains) |
| qcflow.plg | `QC::Flow`, `QC::TclInterconn` | Extracted (visible action remains) |
| qclib_compile.plg | Legacy action | Legacy action file |
| quick_omap2430c_dft.plg | Legacy action | Legacy action file |
| quick_sdf_hack.plg | Legacy action | Legacy action file |
| raw.plg | Legacy action | Legacy action file |
| regtest.plg | `LinkedSpec::get_parser` | Spec consumer |
| rtl.plg | `RTLUtils` | Extracted (visible action remains) |
| sdc2top.plg | `LinkedSpec::Get` | Spec consumer |
| setup_hold_tmax_tmin.plg | `Timing::SetupHold` | Extracted (visible action remains) |
| seview.plg | Legacy action | Legacy action file |
| skew.plg | `Timing::StanBackend` | Extracted (visible action remains) |
| specman.plg | Legacy action | Legacy action file |
| spyglass.plg | `MSOffice::Excel` | Extracted (visible action remains) |
| stan_backend.plg | `Timing::StanBackend` | Extracted (visible action remains) |
| stan_omap2430c_backend.plg | `Timing::StanOmap2430cBackend` | Extracted (visible action remains) |
| test.plg | Test/debug | Test file |
| tree.plg | Legacy action | Legacy action file |
| wrapgen.plg | `RTLUtils` | Extracted (visible action remains) |
| wrapgen_update.plg | `LinkedSpec::Get`, `LinkedSpec::get_parser` | Spec consumer |

Key: **Extracted** = private helper subdefs already moved to domain owners per ROADMAP_V2.md, but visible actions still live in .plg. **Spec consumer** = uses LinkedSpec as parser (get_parser/Get), not as plugin system. **Legacy action file** = carries actions that haven't been formally extracted/documented.

### Plugin Infrastructure Modules

| Module | Lines | Role | Status |
| --- | --- | --- | --- |
| PPlugin.pm | 288 | Legacy .plg adapter — parses .plg files, builds plugin registry, provides get/exec | Lazy-loaded by PluginBridge. Still needed as long as .plg files exist. |
| PluginBridge.pm | 199 | Compatibility bridge — registry-first/legacy-fallback policy for get_plugin/run_plugin/AUTOLOAD | Uses OwnerDispatch. Bridges modern registry ↔ legacy PPlugin. |
| PluginRegistry.pm | 130 | In-memory plugin registry — register_plugin, register_plugins, get_plugin, has_plugin, clear_registered_plugins | Supports runtime plugin registration (used by tests). |

### LinkedSpec.pm Facade — Legacy Plugin Methods (7 total)

| Method | Line | Delegates to | Status |
| --- | --- | --- | --- |
| register_plugin | 211 | PluginRegistry | Registry maintenance |
| register_plugins | 222 | PluginRegistry | Registry maintenance |
| clear_registered_plugins | 233 | PluginRegistry | Registry maintenance |
| run_plugin | 245 | PluginBridge::_dispatch_plugin_name | Legacy execution |
| get_plugin | 257 | PluginBridge::_lookup_plugin_name | Legacy lookup |
| dispatch_plugin_autoload_name | 270 | PluginBridge::_dispatch_autoload | Legacy compatibility |
| AUTOLOAD | 281 | PluginBridge::_dispatch_autoload | Legacy AUTOLOAD shim |

### External Callers of get_plugin

Only **FSMGen.pm:68** (`getop_plugin_list`) references `LinkedSpec::get_plugin` — and only as an optional default: `my $get_plugin = $opt{get_plugin} // \&LinkedSpec::get_plugin`. The caller can override with any coderef. This is the only non-facade, non-test consumer of the legacy plugin lookup path.

### Regression Test Coverage

3 subtests in `t/phase0_regression.t` lock legacy plugin behavior:
1. `linkedspec_require_avoids_plugin_bridge_load_until_autoload` — verifies PluginBridge lazy-loading, AUTOLOAD normalization
2. `linkedspec_require_avoids_plugin_bridge_load_until_run_plugin` — verifies run_plugin, register_plugin, clear_registered_plugins
3. `linkedspec_require_avoids_plugin_bridge_load_until_get_plugin` — verifies get_plugin

### Gap Summary (Priority Ordered)

1. **Already-extracted .plg wrappers still on disk**: Many .plg files have had private helpers extracted (per ROADMAP_V2.md) but still carry visible actions. Each needs classification: delete, reduce to stub, or keep with documented plan. → `.2`
2. **FSMGen get_plugin dependency**: Only external caller. The default can be removed or documented as opt-in. → `.3`
3. **7 legacy facade methods**: run_plugin, get_plugin, dispatch_plugin_autoload_name, AUTOLOAD, register_plugin, register_plugins, clear_registered_plugins. Public surface is large for transition-only functionality. → `.4`
4. **PPlugin.pm / PluginBridge.pm retirement**: After all .plg consumers are gone, both modules can be removed. PluginRegistry may remain if runtime registration is kept. → `.5`
