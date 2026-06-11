# PLUGIN-ACTION-MIGRATION: Migrate remaining .plg actions to package owners

## Metadata

- Tree ID: `PLUGIN-ACTION-MIGRATION`
- Status: `active`
- Roadmap lane: `Plugin modernization follow-on`
- Created: `2026-06-11`
- Last updated: `2026-06-11`
- Owner: repo-local workflow

## Goal

Migrate the remaining 178 actions across 36 `.plg` files (5,132 total lines) to explicit package owners, following the pattern established in PLUGIN-MODERNIZATION: extract helper bodies into domain-appropriate package owners, retire legacy plugin registrations, and delete `.plg` wrappers once no repo-owned caller needs the old plugin name. The end state is that all repo-owned plugin behavior lives in named package owners, and the legacy `.plg`/plugin-bridge infrastructure can be evaluated for retirement.

> **Note:** The original PLUGIN-MODERNIZATION.5 estimate of "~1,200+ actions" was from before PLUGIN-MODERNIZATION deleted 17 `.plg` wrapper files and extracted many helpers. The current count is 178 top-level actions across the 36 remaining files.

## Non-Goals

- Does NOT retire `PPlugin.pm` or `PluginBridge.pm` — that is a separate follow-on tree after all actions are migrated.
- Does NOT remove the deprecated facade methods (`run_plugin`, `get_plugin`, etc.) — that follows plugin-infrastructure retirement.
- Does NOT migrate `FSMGen::AUTOLOAD` — that is a separate concern tracked in PLUGIN-MODERNIZATION.5.
- Does NOT change parser/spec/compiler behavior — this is a plugin-corpus migration, not a core change.

## Acceptance Criteria

- All 36 `.plg` files are audited: every action, helper, and registration is inventoried.
- Each file is either migrated to a package owner, deferred with explicit justification, or confirmed as already-migrated.
- The phase0 regression gate (`bash tools/run_ci_local.sh`) stays green throughout (corpus regression covers plugin parsing via `pplugin.spec`).
- Shipped `.plg` corpus source lock (no direct `LinkedSpec::get_plugin(...)`, `run_plugin(...)`, or `dispatch_plugin_autoload_name(...)` calls) is preserved or tightened.
- Live docs (`CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, `MEMORY.md`, `ROADMAP_V2.md`) are updated after each leaf.
- Each completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `PLUGIN-ACTION-MIGRATION`
  Status: `active`
  Goal: `Migrate all remaining .plg actions to package owners and clean up legacy plugin wrappers.`
  Children: `PLUGIN-ACTION-MIGRATION.1, PLUGIN-ACTION-MIGRATION.2, PLUGIN-ACTION-MIGRATION.3, PLUGIN-ACTION-MIGRATION.4, PLUGIN-ACTION-MIGRATION.5`

- ID: `PLUGIN-ACTION-MIGRATION.1`
  Status: `done`
  Goal: `Full inventory of all 36 remaining .plg files: count actions per file, identify already-extracted owners, identify migration candidates, and classify each file's migration complexity.`
  Acceptance: `The task file contains a complete per-file inventory with action counts, existing owner mappings, and migration classification (trivial/moderate/complex). Phase0 baseline stays green (no code changed).`
  Verification: `All 36 files inventoried: 178 actions across 5,132 lines. Six categories: A (extracted, 9 files/61 actions), B (dead, 10 files/27 actions), C (utility wrappers, 3 files/27 actions), D (moderate migration, 6 files/17 actions), E (complex migration, 7 files/45 actions), F (Expect, 1 file/1 action). wrapgen_update.plg counted in both A+B. Zero cross-file plugin dispatch calls found. Zero non-deprecated plugin dispatch callers outside legacy infrastructure. Phase0 unchanged (no code changed).`
  Commit: `pending`

- ID: `PLUGIN-ACTION-MIGRATION.2`
  Status: `done`
  Goal: `Delete Category B dead files (10 files, 27 actions, 534 lines) that have zero external references across the entire codebase. Remove their entries from any plugin registries if registered. Verify phase0 regression still passes (pplugin.spec corpus shrinks but parser still works).`
  Acceptance: `All 10 dead .plg files deleted. Phase0 stays green (remaining 26 files still parse through pplugin.spec). No code outside plugin/ changed.`
  Verification: `10 files deleted: edalog.plg (28L/1 action), fixscript.plg (10L/1), lstype_long.plg (34L/1), nlc.plg (40L/3), peruser.plg (47L/1), qclib_compile.plg (35L/1), quick_omap2430c_dft.plg (24L/1), sdc2top.plg (30L/2), seview.plg (151L/5), wrapgen_update.plg (135L/11). 26 files (151 actions) remain. Corpus regression discovers files dynamically — no count assertion to break. No code outside plugin/ changed.`
  Commit: `pending`

- ID: `PLUGIN-ACTION-MIGRATION.3`
  Status: `pending`
  Goal: `Verify and delete Category A files whose private helpers are already extracted to package owners (9 files, 61 actions). For each: confirm the action body correctly delegates to the package owner, then delete the .plg wrapper.`
  Acceptance: `Category A .plg wrappers deleted where safe. Phase0 stays green. Package owners carry all behavior directly.`
  Verification: `pending`
  Commit: `pending`

- ID: `PLUGIN-ACTION-MIGRATION.4`
  Status: `pending`
  Goal: `Migrate Category C thin utility wrappers (common.plg, raw.plg, test.plg — 3 files, 27 actions) to a utility package. Identify all cross-file callers and update them to use the new package.`
  Acceptance: `common.plg utilities live in a named package. All caller references updated. .plg wrappers deleted. Phase0 green.`
  Verification: `pending`
  Commit: `pending`

- ID: `PLUGIN-ACTION-MIGRATION.5`
  Status: `pending`
  Goal: `Migrate Category D moderate files (6 files, 17 actions) + exp.plg to domain-appropriate package owners. Extract action bodies into packages, update callers, delete .plg wrappers.`
  Acceptance: `All Category D and F files migrated. Phase0 green. No regressions.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PLUGIN-ACTION-MIGRATION.3` | `pending` | Category A extracted wrappers — verify then delete. |
| 2 | `PLUGIN-ACTION-MIGRATION.3` | `pending` | Category A extracted wrappers — verify then delete. |
| 3 | `PLUGIN-ACTION-MIGRATION.4` | `pending` | Category C utility wrappers — migrate to package. |
| 4 | `PLUGIN-ACTION-MIGRATION.5` | `pending` | Category D moderate + exp.plg — extract to domain owners. |

## Decisions

- `2026-06-11`: Created task tree; inventory-first approach so migration complexity is known before any code changes.
- `2026-06-11`: Completed `.1` inventory. Revised action count from ~1,200 to 178. Identified 10 dead files (zero refs) as immediate deletion candidates. Restructured tree from 2 leaves to 5 leaves with category-based grouping. Deletion of dead files (`.2`) is highest-priority first step — lowest risk, no migration work needed.
- `2026-06-11`: Category E (complex: fsmgen, regtest, msword, network, tree, spyglass, mbist, lte_digital_rf — 7 files, 45 actions) deferred to a future tree. msword.plg is additionally constrained by Win32::OLE (Windows-only). These files require significant per-action extraction work and are not on the critical path for plugin infrastructure retirement.

## Open Questions (from creation)

- How many of the 36 files have already had their private helpers extracted (e.g., qcflow.plg, qc_summary.plg, stan_backend.plg) but still keep visible actions?
- Which files have no remaining repo-owned callers and could be deleted outright?
- Which files depend on domain-specific Perl modules (e.g., Win32::OLE for msword.plg) that constrain extraction?

## Resolved Questions (from .1 inventory)

- **178** top-level actions across 36 files (not ~1,200 as previously estimated).
- **10 files** (28% of corpus, 27 actions) have zero external references and are deletion candidates.
- **9 files** already use extracted package owners; their visible actions still parse through pplugin.spec.
- **4 files** are thin utility wrappers with many cross-file callers (common.plg, raw.plg, test.plg, exp.plg).
- **2 files** require domain-specific Perl modules (msword.plg→Win32::OLE, exp.plg/network.plg→Expect).
- No `.plg` files call `run_plugin(...)` / `get_plugin(...)` / plugin dispatch on other `.plg` actions.
- Zero non-deprecated Perl code calls plugin dispatch methods outside the legacy plugin infrastructure itself.

## Full Per-File Inventory (PLUGIN-ACTION-MIGRATION.1)

### Category A: Already Extracted — Package owners exist (9 files, 61 actions)

These files already use package owners via `use` statements. Their private helpers were extracted during PLUGIN-MODERNIZATION, but the visible top-level actions still parse through `pplugin.spec`. Migration for these is primarily: verify the action body calls package owners correctly, then either delete the wrapper or keep as thin compatibility shim.

| # | File | Lines | Actions | Package owner(s) used | Migration assessment |
| --- | --- | --- | --- | --- | --- |
| 1 | `qcflow.plg` | 786 | 1 (`glc_xcel2hm`) | QC::Flow, QC::TclInterconn | Largest single-action file. All private helpers extracted. Action body delegates to package owners. |
| 2 | `rtl.plg` | 726 | 28 | HTTP::FileAccess, POSIX, VHDL | Largest file by action count. RTL utilities; some already extracted, most action bodies are standalone. |
| 3 | `stan_backend.plg` | 251 | 7 | Timing::StanBackend | STAN backend actions. Private helpers extracted; visible actions remain. |
| 4 | `skew.plg` | 171 | 1 (`skew`) | Timing::StanBackend | Thin wrapper; calls Timing::StanBackend::start(). |
| 5 | `stan_omap2430c_backend.plg` | 82 | 5 | Timing::StanOmap2430cBackend | OMAP-specific STAN. All private helpers extracted. |
| 6 | `qc_summary.plg` | 68 | 1 (`qc_summary`) | QC::Summary | Thin wrapper; private `qc_summary_merge` already extracted to `QC::Summary::append_merged_rows()`. |
| 7 | `setup_hold_tmax_tmin.plg` | 43 | 1 | Timing::SetupHold | Thin wrapper; all timing formulas extracted. |
| 8 | `duty_cycle_degradation.plg` | 13 | 1 | Timing::StanBackend | Trivial wrapper; calls Timing::StanBackend. |
| 9 | `wrapgen_update.plg` | 135 | 11 | RTLUtils | Uses RTLUtils. **Zero external references** — also in Category B. |

### Category B: Dead — Zero external references (10 files, 27 actions)

All actions in these files have zero references anywhere in the codebase (Perl `.pm`/`.pl`, other `.plg` files, tests, scripts). They are candidates for outright deletion. The only regression impact is reducing the `pplugin.spec` parse corpus.

| # | File | Lines | Actions | Notes |
| --- | --- | --- | --- | --- |
| 1 | `seview.plg` | 151 | 5 (`seview`, `uniquify_se`, `seview_annotate`, `sdcgen`, `load_sdcannotate`) | Session/view analysis; all actions dead |
| 2 | `edalog.plg` | 28 | 1 (`edalog_2ss`) | EDA log converter; dead |
| 3 | `peruser.plg` | 47 | 1 (`peruser_default`) | Per-user defaults; dead |
| 4 | `nlc.plg` | 40 | 3 (`nlc`, `nlc_diag`, `nlc_r2_cb`) | NLC analysis; dead |
| 5 | `qclib_compile.plg` | 35 | 1 (`qclib_compile`) | QC lib compilation; dead |
| 6 | `lstype_long.plg` | 34 | 1 (`lstype_long`) | List type long; dead |
| 7 | `sdc2top.plg` | 30 | 2 (`sdc2top`, `add_base`) | SDC to top; dead |
| 8 | `quick_omap2430c_dft.plg` | 24 | 1 (`quick_dft`) | OMAP DFT quick; dead |
| 9 | `fixscript.plg` | 10 | 1 (`fixscript`) | Fix script; dead |
| 10 | `wrapgen_update.plg` | 135 | 11 | Also in Category A (uses RTLUtils). Dead despite extraction. |
| — | **Subtotal** | **534** | **27** | **All deletion candidates** |

### Category C: Thin Utility Wrappers (3 files, 27 actions)

These provide utility wrappers around Perl builtins/CPAN modules and are referenced by other `.plg` files. Migration approach: move to explicit package owners or keep as utility packages.

| # | File | Lines | Actions | Notes |
| --- | --- | --- | --- | --- |
| 1 | `common.plg` | 25 | 23 | Thin wrappers: `config_read`, `config_link`, `digest_file_hex`, `abs_path`, `getcwd`, `catfile`, `dirname`, `store`, `retrieve`, etc. Widely used by other .plg files. Migration: move to a utility package. |
| 2 | `raw.plg` | 8 | 1 (`raw`) | Thin wrapper; used by other .plg files for raw data processing. |
| 3 | `test.plg` | 32 | 3 | Test helper utilities; used by test infrastructure. |

### Category D: Moderate Migration — Standalone, domain-specific (6 files, 17 actions)

Files with clear domain ownership and manageable complexity. Migration: extract action bodies into domain-appropriate package owners (existing or new), update any callers, delete `.plg`.

| # | File | Lines | Actions | Domain | Notes |
| --- | --- | --- | --- | --- | --- |
| 1 | `ds_vhistory.plg` | 89 | 1 (`ds_vhistory`) | DesignSync version history | Uses `LinkedSpec::get_parser('ds_vhistory')`; parses vhistory output. |
| 2 | `fxenv_helper.plg` | 60 | 1 (`check4diff`) | FX environment comparison | Standalone comparison utility. |
| 3 | `generic_fake_memory_module.plg` | 67 | 1 | RTL memory generation | RTL-related; `get_log2` helper already extracted to `RTLUtils::ceil_log2()`. |
| 4 | `matrix.plg` | 97 | 4 (`matrix`, `htree_2matrix`, `_matrix_default_code`, `rt_input_load`) | Matrix operations | Referenced by Perl code. |
| 5 | `specman.plg` | 84 | 1 | Specman e-language | Standalone specman integration. |
| 6 | `wrapgen.plg` | 85 | 5 | RTL wrapper generation | Wrapper generation for DFT/MBIST. Referenced by Perl code. |

### Category E: Complex Migration — Large, many actions, or special dependencies (8 files, 46 actions)

Files requiring significant migration effort due to size, action count, or platform-specific dependencies (Win32::OLE, Expect).

| # | File | Lines | Actions | Complexity driver | Notes |
| --- | --- | --- | --- | --- | --- |
| 1 | `fsmgen.plg` | 464 | 25 | 25 actions, 464 lines | FSM generation; largest action count. Actions include `interface_object`, `portlist_2hash`, `get_entity_file_name`, `fsmgen_from_string`, etc. FSMGen.pm already owns `getop_plugin_list`. Uses `LinkedSpec::get_parser`. |
| 2 | `regtest.plg` | 345 | 5 | Large bodies, uses LinkedSpec | Register test generation. Actions: `register_test`, `drive_regtest_do`, `drive_regtest_e`, `_reg_write_n_check`, `get_binary_alt`. Uses `LinkedSpec::get_parser`. |
| 3 | `msword.plg` | 326 | 4 | Requires Win32::OLE (Windows-only!) | Word document generation: `uref_2cidl`, `drive_cidl`, `cidl_register_definitions`, `iosmap_archi`. `uref_2cidl` config is read by fxenv_helper.plg and spyglass.plg via `config_read`. Platform-constrained; cannot migrate on non-Windows. |
| 4 | `network.plg` | 286 | 9 | Uses Expect | Network analysis: `network`, `reset_analyze`, `tfo_recurse`, `tfo_init`, `rpt_transitive_table_*`, `netw_tfo_propagate`, `tfo_propagate`, `netw_tfi`. |
| 5 | `tree.plg` | 213 | 16 | Many actions, widely referenced | Tree/table data structures: `string2tree`, `itable_2atree`, `dirlist_2db`, `dirlist_2itable`, `atree_2itable`, `atree_2ascii`, `slurp`, `hkey_2table`, `design_hierarchy_2htree`, etc. Uses HTTP::FileAccess. Referenced by 3+ Perl files. |
| 6 | `spyglass.plg` | 145 | 2 | Reads uref_2cidl config, uses MSOffice::Excel | SpyGlass flow: `spyglass_2ss`, `spyglass_waive`. `spyglass_waive` calls `MSOffice::Excel::start()` directly (already extracted). |
| 7 | `mbist.plg` | 75 | 3 | Memory BIST offsets | MBIST memory testing: `dsp_subsys_mbist_offset`, `dsp_ram_mbist_offset`, `_dsp_xyz_constants_2htree`. |
| 8 | `lte_digital_rf.plg` | 43 | 1 | LTE/RF analysis | Standalone LTE digital/RF analysis. |

### Category F: Special — Expect-based (1 file, 1 action)

| # | File | Lines | Actions | Notes |
| --- | --- | --- | --- | --- |
| 1 | `exp.plg` | 14 | 1 (`exp`) | Expect wrapper for interactive tool automation. Requires Expect CPAN module. Cross-referenced by other .plg files. |

### Summary Statistics

| Category | Files | Actions | Lines | Disposition |
| --- | --- | --- | --- | --- |
| A: Already extracted | 9 | 61 | 2,322 | Verify, then delete wrappers |
| B: Dead (zero refs) | 10 | 27 | 534 | Delete outright |
| C: Thin utilities | 3 | 27 | 65 | Migrate to utility packages |
| D: Moderate migration | 6 | 17 | 432 | Extract to domain owners |
| E: Complex migration | 7 | 45 | 1,752 | Extract with care |
| F: Expect wrapper | 1 | 1 | 14 | Extract to Expect utility |
| **Total** | **36** | **178** | **5,119** | |

> Note: wrapgen_update.plg (135 lines) is counted in both Category A and B. The 5,119 total differs slightly from `cat plugin/*.plg | wc -l` (5,132) due to counting methodology.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-11` | `PLUGIN-ACTION-MIGRATION.1` | Inventory completeness: all 36 files audited (178 actions, 6 categories). Zero cross-file plugin dispatch calls. No code changed — phase0 unchanged. | PASS |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `PLUGIN-ACTION-MIGRATION.1` | `581db79` — PLUGIN-ACTION-MIGRATION.1 — full .plg corpus inventory; tree activated + restructured | |

## Changelog

- `2026-06-11`: Created task tree. Activated from proposed status.
- `2026-06-11`: Completed `.1` inventory. Revised action count (178, not ~1,200). Six-category classification. Tree restructured from 2 to 5 leaves. Category E complex files deferred to future tree.
