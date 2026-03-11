# CHANGES
Detailed technical history of changes prepared for commit.
## 2026-03-11 - Backbone Item 3 Slice: Move RewritePipeline Default Dep Builder into `RewritePipeline`
## Summary
Continued the ActionIR cleanup track by moving rewrite-pipeline default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::RewritePipeline`, so the active rewrite-pipeline owner now defines its own callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/RewritePipeline.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored rewrite-pipeline dependency ownership:
  - added `LinkedSpec::ActionIR::RewritePipeline::_require_pkg_cb(...)`,
  - added `LinkedSpec::ActionIR::RewritePipeline::default_deps_for_package(...)`,
  - rewired `LinkedSpec::ActionRewriter::_rewrite_pipeline_deps()` to resolve through `RewritePipeline` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::action_rewriter_rewrite_pipeline_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still builds rewrite rules and canonical-IR-driven helper rewrites through `LinkedSpec::ActionIR::RewritePipeline`,
  - rewrite-pipeline defaults still target the same lowering-contract, helper-event, canonical-event, and unresolved-helper callbacks as before,
  - helper rewrite output stays behavior-stable for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_rewrite_pipeline_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=162`)
## 2026-03-11 - Backbone Item 3 Slice: Move Diagnostics Default Dep Builder into `Diagnostics`
## Summary
Continued the ActionIR cleanup track by moving diagnostics default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::Diagnostics`, so the active diagnostics owner now defines its own callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/Diagnostics.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored diagnostics dependency ownership:
  - added `LinkedSpec::ActionIR::Diagnostics::_require_pkg_cb(...)`,
  - added `LinkedSpec::ActionIR::Diagnostics::default_deps_for_package(...)`,
  - rewired `LinkedSpec::ActionRewriter::_diagnostics_deps()` to resolve through `Diagnostics` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::action_rewriter_diagnostics_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still builds unresolved-helper and helper-event diagnostics through `LinkedSpec::ActionIR::Diagnostics`,
  - diagnostics defaults still target the same statement-split and contract-scan callbacks as before,
  - unresolved-helper counting stays behavior-stable for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_diagnostics_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Diagnostics.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=161`)
## 2026-03-11 - Backbone Item 3 Slice: Move Canonical Event Default Dep Builder into `CanonicalEvents`
## Summary
Continued the ActionIR cleanup track by moving canonical-event default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::CanonicalEvents`, so the active canonical-event owner now defines its own callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored canonical-event dependency ownership:
  - added `LinkedSpec::ActionIR::CanonicalEvents::_require_pkg_cb(...)`,
  - added `LinkedSpec::ActionIR::CanonicalEvents::default_deps_for_package(...)`,
  - rewired `LinkedSpec::ActionRewriter::_canonical_event_deps()` to resolve through `CanonicalEvents` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::action_rewriter_canonical_event_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still builds canonical action-IR events through `LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events(...)`,
  - canonical-event defaults still target the same trim and statement-split helpers as before,
  - canonical node emission stays behavior-stable for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_canonical_event_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=160`)
## 2026-03-11 - Backbone Item 3 Slice: Move StatementSplit Default Dep Builder into `StatementSplit`
## Summary
Continued the ActionIR cleanup track by moving statement-split default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::StatementSplit`, so the active statement-splitting owner now defines its own callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/StatementSplit.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored statement-split dependency ownership:
  - added `LinkedSpec::ActionIR::StatementSplit::_require_pkg_cb(...)`,
  - added `LinkedSpec::ActionIR::StatementSplit::default_deps_for_package(...)`,
  - rewired `LinkedSpec::ActionRewriter::_statement_split_deps()` to resolve through `StatementSplit` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::action_rewriter_statement_split_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still splits action statements through `LinkedSpec::ActionIR::StatementSplit::_split_action_ir_statements(...)`,
  - the statement-split path still consumes the same `trim_action_ir_value` helper callback as before,
  - statement segmentation stays behavior-stable for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_statement_split_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=159`)
## 2026-03-11 - Backbone Item 3 Slice: Move Scanner Default Dep Builder into `Scanner`
## Summary
Continued the ActionIR cleanup track by moving scanner default dependency construction out of `LinkedSpec::Deps` and into `LinkedSpec::ActionIR::Scanner`, so the active scanner owner module now defines its own default callback map.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/Scanner.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored scanner dependency ownership:
  - added `LinkedSpec::ActionIR::Scanner::default_deps_for_package(...)`,
  - added `LinkedSpec::ActionIR::Scanner::_require_pkg_cb(...)` for scanner-owned callback validation,
  - rewired `LinkedSpec::ActionRewriter::_scan_contract_ir_event_deps()` to resolve through `Scanner` instead of `Deps`.
- Removed stale dependency plumbing:
  - deleted `LinkedSpec::Deps::action_rewriter_scanner_deps_for_package(...)` because it is no longer part of the active path.
- Preserved behavior:
  - ActionRewriter still scans helper contracts through `LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(...)`,
  - scanner default deps still target the same split/trim/method/declare helpers as before,
  - rewrite output remains unchanged for the current regression corpus.
- Updated focused regression coverage:
  - added `action_rewriter_avoids_deps_scanner_dep_builder`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=158`)
## 2026-03-11 - Backbone Item 3 Slice: Move Scanner Rule Dep Rebinding into `ScannerCore` Owner Helpers
## Summary
Continued the ActionIR cleanup track by moving scanner-rule dependency rebinding and dispatcher selection into explicit `LinkedSpec::ActionIR::ScannerCore` owner helpers, instead of leaving that orchestration inline inside `scan_contract_ir_events(...)`.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/ScannerCore.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::ActionIR::ScannerCore`:
  - added `_scanner_rule_dep_bindings(...)` to build the callback map consumed by scanner rule packages,
  - added `_with_scanner_rule_deps(...)` to own scanner-rule dependency rebinding,
  - added `_scanner_dispatchers()` so `scan_contract_ir_events(...)` no longer hardcodes its scanner dispatch chain inline.
- Preserved behavior:
  - ActionIR contract scanning still dispatches through the same primitive/basic/pipeline/flow/legacy rule packages,
  - scanner rule packages still receive the same helper callbacks for statement splitting, trimming, method parsing, array-pipeline planning, and declare parsing,
  - the action-rewriter and phase0 parser-generation path are behavior-stable.
- Updated focused regression coverage:
  - added `actionir_scannercore_uses_scanner_dep_binding_owner`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ScannerCore.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=157`)
## 2026-03-11 - Plugin Bridge Slice: Move Default Legacy Runtime Deps onto Owner Helpers
## Summary
Continued the `LinkedSpec::PluginBridge` modernization track by moving the bridge's default legacy runtime load/exec behavior onto explicit owner helpers, so the compatibility seam is now fully named inside `LinkedSpec::PluginBridge` instead of relying on inline closures.

## Changed Files
- Updated: `perl/LinkedSpec/PluginBridge.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::PluginBridge`:
  - added `_load_legacy_plugin_runtime(...)` as the explicit owner helper for lazy `PPlugin` loading,
  - added `_exec_legacy_plugin(...)` as the explicit owner helper for normalized-name legacy plugin execution,
  - updated `_default_deps()` to point at those owner helpers instead of inline closures.
- Preserved behavior:
  - `LinkedSpec::AUTOLOAD` still delegates to `LinkedSpec::PluginBridge::_dispatch_autoload(...)`,
  - default bridge dispatch still lazy-loads `PPlugin` and executes through `PPlugin::exec_plugin_name(...)`,
  - the public compatibility surface is unchanged while the bridge replacement seam gets narrower and easier to test.
- Updated focused regression coverage:
  - added `plugin_bridge_default_load_dep_uses_legacy_runtime_owner`,
  - added `plugin_bridge_default_exec_dep_uses_legacy_exec_owner`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=156`)
## 2026-03-11 - Plugin Bridge Slice: Split Explicit Plugin-Name Dispatch from Autoload Normalization
## Summary
Continued the `LinkedSpec::PluginBridge` modernization track by splitting explicit plugin-name dispatch into its own owner path, so autoload handling now normalizes once and delegates to a reusable explicit-name dispatcher.

## Changed Files
- Updated: `perl/LinkedSpec/PluginBridge.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::PluginBridge`:
  - added `_require_plugin_name(...)` to validate explicit normalized plugin names,
  - added `_dispatch_plugin_name(...)` as the owner path for explicit-name plugin dispatch through injected runtime deps,
  - `_dispatch_autoload(...)` now reduces to autoload-name normalization plus delegation into `_dispatch_plugin_name(...)`.
- Preserved behavior:
  - `LinkedSpec::AUTOLOAD` still delegates to `LinkedSpec::PluginBridge::_dispatch_autoload(...)`,
  - injected and default plugin-runtime deps still load the runtime and execute the normalized plugin name the same way,
  - invalid autoload names still fail before any runtime load/exec side effects.
- Updated focused regression coverage:
  - added `plugin_bridge_dispatch_plugin_name_supports_injected_runtime_deps`,
  - added `plugin_bridge_dispatch_plugin_name_rejects_invalid_name_before_runtime_load`,
  - added `plugin_bridge_autoload_uses_dispatch_plugin_name_owner`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=154`)
## 2026-03-11 - Plugin Runtime Slice: Migrate Internal Explicit Plugin Callers to `exec_plugin_name(...)`
## Summary
Continued the plugin/runtime modernization track by moving repo-owned callers that already know explicit plugin names off the compatibility `PPlugin::exec(...)` wrapper and onto `PPlugin::exec_plugin_name(...)`.

## Changed Files
- Updated: `perl/HUtils.pm`
- Updated: `perl/RTLUtils.pm`
- Updated: `perl/TableScript.pm`
- Updated: `plugin/string.plg`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated repo-owned explicit plugin dispatch sites:
  - `HUtils::GenericFilter(...)` now calls `PPlugin::exec_plugin_name("genericfilter_$action", ...)`,
  - `RTLUtils` header/context-clause generation now calls `PPlugin::exec_plugin_name('add_header_n_context_clause', ...)`,
  - `TableScript::http_exec(...)` now calls `PPlugin::exec_plugin_name('httplink', ...)`,
  - `plugin/string.plg` now calls `PPlugin::exec_plugin_name('file_list_path2http', ...)`.
- Preserved behavior:
  - explicit plugin names and arguments remain unchanged at each callsite,
  - the compatibility `PPlugin::exec(...)` wrapper remains available for mixed-name and external legacy callers,
  - autoload-style compatibility entrypoints are unchanged.
- Updated focused regression coverage:
  - added `tablescript_http_exec_uses_pplugin_explicit_name_owner`,
  - added `hutils_generic_filter_uses_pplugin_explicit_name_owner`.

## Validation
- Ran:
  - `perl -Iperl -c perl/HUtils.pm`
  - `perl -Iperl -c perl/RTLUtils.pm`
  - `perl -Iperl -c perl/TableScript.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=151`)
## 2026-03-11 - Plugin Runtime Slice: Lazy-Load `LinkedSpec` from `PPlugin` Default Parser Deps
## Summary
Continued the plugin/runtime modernization track by removing `PPlugin`'s eager `LinkedSpec` import and making the default `pplugin` parser dependency lazy-load `LinkedSpec` only when that callback is actually invoked.

## Changed Files
- Updated: `perl/PPlugin.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `PPlugin` module-load behavior:
  - removed eager `use LinkedSpec;` from `PPlugin.pm`,
  - added explicit core path-module ownership in `PPlugin.pm` with `Cwd`, `File::Basename`, and `File::Spec`,
  - updated `_default_deps()->{load_plugin_parser}` to `require LinkedSpec` lazily before calling `LinkedSpec::get_parser('pplugin')`.
- Preserved behavior:
  - `PPlugin` still uses the `pplugin` spec and `LinkedSpec::get_parser(...)` for legacy `.plg` parsing by default,
  - default registry construction and plugin dispatch behavior remain unchanged for the phase0 corpus,
  - `LinkedSpec` still loads when the default parser callback is executed.
- Updated focused regression coverage:
  - added `pplugin_require_does_not_eagerly_load_linkedspec`,
  - added `pplugin_default_parser_dep_lazy_loads_linkedspec`,
  - added `run_perl_snippet_in_subprocess(...)` helper for process-isolated module-load assertions.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/PPlugin.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=149`)
## 2026-03-11 - Plugin Runtime Slice: Extract Explicit `PPlugin` Registry Loader Deps
## Summary
Continued the plugin/runtime modernization track by extracting legacy registry construction in `PPlugin::new(...)` behind an explicit dependency-owned loader seam, so the compatibility adapter no longer hardwires parser loading, plugin-file discovery, and registry assembly inline.

## Changed Files
- Updated: `perl/PPlugin.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored legacy plugin registry loading:
  - added `_require_dep(...)`, `_default_deps()`, and `_load_legacy_registry(...)` to `PPlugin`,
  - `PPlugin::new(...)` now initializes its cached legacy registry through `_load_legacy_registry()` instead of calling `LinkedSpec::get_parser('pplugin')`, `_legacy_plugin_files(...)`, and `_build_plugin_registry(...)` inline,
  - the default dependency map now makes parser loading, plugin-file discovery, and registry assembly explicit owner callbacks.
- Preserved behavior:
  - `PPlugin` still loads the `pplugin` parser through `LinkedSpec` by default,
  - legacy `.plg` file discovery and registry assembly semantics remain unchanged for the phase0 corpus,
  - the cached registry shape and dispatch behavior stay compatibility-stable.
- Updated focused regression coverage:
  - added `pplugin_load_legacy_registry_uses_explicit_dependency_callbacks`,
  - added `pplugin_default_registry_deps_load_through_explicit_owner_paths`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/PPlugin.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=147`)
## 2026-03-11 - Plugin Runtime Slice: Route Bridge Exec Through Explicit `PPlugin` Plugin-Name Owner
## Summary
Continued the plugin/runtime modernization track by making `PPlugin` own explicit plugin-name execution through `exec_plugin_name(...)`, with `LinkedSpec::PluginBridge` now using that owner path directly while the older mixed-name `exec(...)` surface remains as compatibility glue.

## Changed Files
- Updated: `perl/PPlugin.pm`
- Updated: `perl/LinkedSpec/PluginBridge.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored legacy plugin execution ownership:
  - added `PPlugin::exec_plugin_name(...)` as the explicit owner path for executing a plugin by normalized plugin name,
  - added `PPlugin::_normalize_plugin_name(...)` so the older mixed-name `exec(...)` wrapper and `AUTOLOAD` compatibility path can normalize before delegating,
  - `LinkedSpec::PluginBridge::_default_deps()` now dispatches through `PPlugin::exec_plugin_name(...)` instead of the older mixed-name wrapper.
- Preserved behavior:
  - `LinkedSpec::AUTOLOAD` still resolves through `LinkedSpec::PluginBridge`,
  - the compatibility `PPlugin::exec(...)` surface still accepts older mixed autoload/subname inputs for direct callers,
  - legacy `.plg` dispatch behavior remains unchanged for the phase0 corpus.
- Updated focused regression coverage:
  - added `plugin_bridge_default_exec_dep_uses_pplugin_explicit_name_owner`,
  - added `pplugin_exec_wrapper_normalizes_to_explicit_name_owner`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/PPlugin.pm`
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=145`)
## 2026-03-11 - Plugin Runtime Slice: Extract Explicit Legacy Registry Builder
## Summary
Continued the plugin/runtime modernization track by extracting legacy `.plg` registry construction in `PPlugin` into an explicit owner helper, so the compatibility adapter now exposes a narrower, testable registry seam without changing runtime behavior.

## Changed Files
- Updated: `perl/PPlugin.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `PPlugin` legacy registry construction:
  - added `_build_plugin_registry(...)` as the owner helper for building the cached legacy plugin registry from discovered `.plg` files,
  - `PPlugin::new(...)` now enumerates plugin files through `_legacy_plugin_files(...)` and hands the ordered list to `_build_plugin_registry(...)`,
  - registry construction still preserves later-file override behavior for duplicate plugin names while skipping malformed plugin parses with a warning.
- Preserved behavior:
  - legacy `.plg` execution still searches the working directory and the project `plugin/` tree through the previously-landed deterministic discovery helpers,
  - plugin dispatch behavior remains unchanged for the phase0 corpus,
  - malformed legacy plugin files remain non-fatal to registry construction.
- Updated focused regression coverage:
  - added `pplugin_build_plugin_registry_preserves_file_order_and_skips_parse_failures`,
  - kept the deterministic discovery seam coverage for cwd-first root enumeration and sorted `.plg` file lists.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/PPlugin.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=143`)
## 2026-03-10 - Plugin Runtime Slice: Make Legacy `.plg` File Discovery Deterministic
## Summary
Continued the plugin/runtime modernization track by replacing `PPlugin`'s brace-glob plugin-file discovery with explicit, deterministic cwd-first root enumeration and sorted `.plg` file lists.

## Changed Files
- Updated: `perl/PPlugin.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `PPlugin` legacy discovery:
  - added `_plugin_project_root(...)` to compute the project-relative legacy plugin root,
  - added `_legacy_plugin_search_roots(...)` to enumerate cwd-first legacy plugin roots explicitly,
  - added `_legacy_plugin_files(...)` to enumerate `.plg` files per root in sorted order and dedupe duplicate file paths,
  - `PPlugin::new(...)` now consumes `_legacy_plugin_files(...)` instead of brace-globbing two root patterns directly.
- Preserved behavior:
  - legacy `.plg` execution still searches the working directory and the project `plugin/` tree,
  - plugin parsing/execution behavior remains unchanged for the phase0 corpus,
  - duplicate plugin filenames in distinct roots still preserve cwd-first root precedence through stable per-root ordering.
- Updated focused regression coverage:
  - added `pplugin_legacy_plugin_search_roots_are_cwd_first_and_deduped`,
  - added `pplugin_legacy_plugin_files_are_sorted_and_deduped`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/PPlugin.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=142`)
## 2026-03-10 - Plugin Runtime Slice: Normalize `PluginBridge` Dispatch to Explicit Plugin Names
## Summary
Continued the plugin/runtime modernization track by making `LinkedSpec::PluginBridge` normalize full `AUTOLOAD` names into explicit plugin names before runtime dispatch, narrowing the compatibility seam toward a deterministic registry-style plugin contract.

## Changed Files
- Updated: `perl/LinkedSpec/PluginBridge.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::PluginBridge`:
  - added `_normalize_plugin_name(...)` to extract and validate an explicit plugin identifier from the full Perl `AUTOLOAD` name,
  - `_dispatch_autoload(...)` now normalizes the autoloaded method name before loading the legacy runtime and before calling the injected `exec_plugin` callback,
  - invalid autoload names now fail before any legacy plugin-runtime load/exec side effects occur.
- Preserved behavior:
  - `LinkedSpec::AUTOLOAD` still delegates to `LinkedSpec::PluginBridge::_dispatch_autoload(...)`,
  - the default compatibility runtime still lazy-loads `PPlugin`,
  - legacy plugin execution still works through the same `.plg` compatibility path.
- Updated focused regression coverage:
  - `plugin_bridge_supports_injected_plugin_runtime_deps` now proves injected runtime callbacks receive normalized plugin names rather than full Perl method names,
  - added `plugin_bridge_rejects_invalid_autoload_name_before_runtime_load` to prove invalid autoload names fail before plugin runtime load/exec.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=140`)
## 2026-03-10 - Phase 1A Slice: Remove Dead Validation Facade Wrappers
## Summary
Reduced another stale `LinkedSpec.pm` seam by removing the dead validation delegate wrappers now that active validation and DSL error reporting already stay on `LinkedSpec::Validation`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale validation delegates from `LinkedSpec.pm`:
  - deleted `get_dsl_context(...)`,
  - deleted `report_dsl_error(...)`,
  - deleted `validate_spec_content(...)`,
  - deleted `validate_rule_definition(...)`,
  - deleted `validate_gdata_references(...)`,
  - deleted `validate_dsl_syntax(...)`,
  - deleted `extract_regex_literals_from_rule_rhs(...)`,
  - removed the now-unused `LinkedSpec::Validation` import from `LinkedSpec.pm`.
- Preserved behavior:
  - active compile-time validation still routes through `LinkedSpec::Validation` from `LinkedSpec::Compiler`,
  - malformed-spec diagnostics still report DSL line context through the `LinkedSpec::Validation` owner path,
  - `Get(..., return_descr => 1)` still returns the same descriptor structure and metadata.
- Updated focused regression coverage:
  - expanded `get_parser_malformed_spec_reports_validation_error` to trap the removed `LinkedSpec` validation helpers on the error path,
  - added `get_return_descr_avoids_removed_linkedspec_validation_facade` to trap the removed validation helpers on the successful descriptor-build path.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Validation.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=139`)
## 2026-03-10 - Phase 1A Slice: Remove Dead Internal Trace and Runtime Helper Wrappers
## Summary
Reduced another stale `LinkedSpec.pm` seam by removing the dead internal trace/runtime helper wrappers now that active trace configuration and parser-source emission already stay on `LinkedSpec::Trace`, `LinkedSpec::ParserFactory`, and `LinkedSpec::SpecEntry`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale internal wrappers from `LinkedSpec.pm`:
  - deleted `_trace_level_name(...)`,
  - deleted `_apply_trace_options(...)`,
  - deleted `_emit_parser_source_line(...)`.
- Preserved behavior:
  - public `LinkedSpec::configure_trace(...)` remains as the compatibility trace entrypoint,
  - active `get_parser(...)` tracing still routes through `LinkedSpec::Trace` and `LinkedSpec::ParserFactory`,
  - active parser-source emission still routes through `LinkedSpec::SpecEntry` plus injected `runtime_ctx`.
- Updated focused regression coverage:
  - expanded `get_parser_avoids_linkedspec_parser_factory_facade` to trap the removed internal trace helper `_trace_level_name(...)`,
  - expanded `spec_entry_compile_spec_entry_uses_injected_runtime_context` to trap the removed runtime helper `_emit_parser_source_line(...)`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Trace.pm`
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=138`)
## 2026-03-10 - Phase 1A Slice: Remove Dead Internal ActionIR Lowering Delegate Block
## Summary
Reduced another stale `LinkedSpec.pm` seam by removing the dead internal ActionIR lowering/dependency delegate block now that active helper lowering already stays on `LinkedSpec::ActionRewriter` and the extracted ActionIR owner modules.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale internal ActionIR delegates from `LinkedSpec.pm`:
  - deleted the old dependency builders (`_flow_expr_deps`, `_method_lowering_deps`, `_declare_method_deps`, `_array_pipeline_deps`, `_control_flow_deps`, `_value_expr_deps`),
  - deleted the remaining internal lowering/parser/extraction wrappers for flow expressions, declare/method lowering, value lowering, array-pipeline lowering, and fluent control-flow lowering,
  - removed the now-unused ActionIR/Deps import lines from `LinkedSpec.pm`.
- Preserved behavior:
  - `LinkedSpec::call_spec_handler_subst(...)` remains the compatibility/test shim,
  - active helper lowering still routes through `LinkedSpec::ActionRewriter::call_spec_handler_subst(...)` and the extracted ActionIR owner modules.
- Updated focused regression coverage:
  - renamed seam lock to `action_rewriter_avoids_removed_linkedspec_lowering_facade`,
  - expanded the traps across the removed internal lowering/dependency names,
  - added explicit `is_empty(...)` and composable array-pipeline coverage so the owner-path lock exercises the removed flow/value/pipeline helper surface more broadly.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=138`)
## 2026-03-10 - Phase 1A Slice: Remove Dead Internal RuleIR and Descriptor Delegate Block
## Summary
Reduced another stale `LinkedSpec.pm` seam by removing the dead internal `Compiler`/`RuleIR`/action-contract delegate block now that active descriptor/rule-compilation flow already stays on the owner modules.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale internal delegates from `LinkedSpec.pm`:
  - deleted `_build_action_rewriter_migration_summary(...)`
  - deleted `_action_contract_deps(...)`
  - deleted `_build_action_lowering_contracts(...)`
  - deleted `_select_rule_handler_variant(...)`
  - deleted `_build_rule_execution_meta(...)`
  - deleted `_collect_rule_ir(...)`
  - deleted `_plan_rule_ir_meta(...)`
  - deleted `_validate_rule_ir_or_exit(...)`
  - deleted `_normalize_rule_code_chunks(...)`
  - deleted `_build_rule_ir_emit_context(...)`
- Preserved behavior:
  - `LinkedSpec::spec_descr(...)` still compiles rules through `LinkedSpec::Compiler` plus `LinkedSpec::SpecEntry`,
  - `LinkedSpec::Get(..., return_descr => 1)` still exposes compiled handlers, selected handler metadata, and descriptor-level action-rewriter migration summary.
- Added focused regression coverage:
  - `spec_descr_and_get_avoid_removed_linkedspec_ruleir_internal_facade`
  - the seam lock traps the removed helper names and proves both `spec_descr(...)` and `Get(..., return_descr => 1)` succeed through the owner modules only.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=138`)
## 2026-03-10 - Phase 1A Slice: Remove Dead Internal ActionRewriter Facade Block
## Summary
Reduced another stale `LinkedSpec.pm` seam by removing the dead internal ActionRewriter delegate block now that active rewrite/scanner/canonicalization flow already stays on `LinkedSpec::ActionRewriter` and `LinkedSpec::RuleIR::EmitContext`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale internal ActionRewriter delegates from `LinkedSpec.pm`:
  - deleted `_find_unresolved_action_helpers(...)`
  - deleted `_scan_contract_ir_events(...)`
  - deleted `_collect_action_helper_ir_nodes(...)`
  - deleted `_trim_action_ir_value(...)`
  - deleted `_canonicalize_helper_action_ir_event(...)`
  - deleted `_split_action_ir_statements(...)`
  - deleted `_build_canonical_action_ir_events(...)`
  - deleted `_lower_action_code_from_canonical_ir(...)`
  - deleted `_accumulate_action_rewrite_diagnostics(...)`
  - deleted `_rewrite_action_code_with_diagnostics(...)`
  - deleted `_build_action_rewrite_rules(...)`
- Preserved behavior:
  - runtime rule emission still rewrites through `LinkedSpec::RuleIR::EmitContext` plus `LinkedSpec::ActionRewriter`,
  - `LinkedSpec::call_spec_handler_subst(...)` remains the public compatibility/test shim for focused rewrite inspection.
- Updated focused regression coverage:
  - `ruleir_emit_context_avoids_removed_linkedspec_action_rewriter_facade`
  - the seam lock now traps the removed helper names and proves `LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context(...)` still succeeds through the owner modules only.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=137`)
## 2026-03-10 - Phase 1A Slice: Remove Runtime `compile_spec_entry` Wrapper
## Summary
Reduced another stale runtime seam by removing `LinkedSpec::Runtime::compile_spec_entry(...)` now that active rule-entry compilation already flows through `LinkedSpec::SpecEntry::compile_spec_entry(...)` with injected runtime context.

## Changed Files
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale runtime wrapper from `Runtime.pm`:
  - deleted `LinkedSpec::Runtime::compile_spec_entry(...)`,
  - active rule-entry compilation continues to resolve through `LinkedSpec::SpecEntry::compile_spec_entry(...)` with injected `runtime_ctx`.
- Updated focused injected-callback coverage:
  - direct injected-state coverage now targets `LinkedSpec::SpecEntry::compile_spec_entry(...)`,
  - compiler-pipeline injected callback tests now use the `SpecEntry.pm` owner directly.
- Added/updated focused regression coverage:
  - `spec_entry_compile_spec_entry_uses_injected_runtime_context`
  - existing wrapper-bypass seams continue to prove active descriptor-build paths do not depend on the removed runtime wrapper.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=137`)
## 2026-03-10 - Phase 1A Slice: Remove Facade `spec_entry` Helper
## Summary
Reduced another stale `LinkedSpec.pm` compatibility seam by removing the façade-only `spec_entry(...)` wrapper and regression-locking rule-entry compilation to `LinkedSpec::SpecEntry`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale rule-entry delegation from `LinkedSpec.pm`:
  - deleted `LinkedSpec::spec_entry(...)`,
  - active rule-entry compilation continues to resolve through `LinkedSpec::SpecEntry::compile_spec_entry(...)` via compiler-owned defaults.
- Added focused regression coverage:
  - `spec_descr_paths_avoid_linkedspec_spec_entry_facade`
  - the regression traps the removed façade helper name and proves both `LinkedSpec::spec_descr(...)` and `LinkedSpec::Get(..., return_descr => 1)` still build compiled handlers through the `SpecEntry.pm` owner path.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=137`)
## 2026-03-10 - Phase 1A Slice: Remove Legacy Runtime Raw-Arg Wrapper
## Summary
Reduced another stale runtime seam by removing `LinkedSpec::Runtime::run_get_from_args(...)` now that active public/runtime/parser-factory flows all normalize options before delegating into `LinkedSpec::Runtime::run_get(...)`.

## Changed Files
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale runtime wrapper from `Runtime.pm`:
  - deleted `LinkedSpec::Runtime::run_get_from_args(...)`,
  - active runtime entrypoints continue to resolve through `LinkedSpec::Runtime::run_get(...)` with normalized hashref options supplied by `LinkedSpec::Get(...)` and `LinkedSpec::ParserFactory`.
- Added focused regression coverage:
  - `runtime_run_get_avoids_legacy_raw_arg_wrapper`
  - the regression traps the removed wrapper name and proves `LinkedSpec::Runtime::run_get(..., { return_descr => 1 })` still returns a descriptor hash directly through the active owner path.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=136`)
## 2026-03-10 - Phase 1A Slice: Remove Facade `spec_gdata` Helper
## Summary
Reduced another stale `LinkedSpec.pm` compatibility seam by removing the façade-only `spec_gdata(...)` wrapper and regression-locking final descriptor `gdata` compilation to `LinkedSpec::Compiler`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale compiler delegation from `LinkedSpec.pm`:
  - deleted `LinkedSpec::spec_gdata(...)`,
  - active final descriptor `gdata` compilation continues to resolve through `LinkedSpec::Compiler::spec_gdata(...)` inside `_build_final_descr(...)`.
- Added focused regression coverage:
  - `compiler_pipeline_avoids_linkedspec_spec_gdata_facade`
  - the regression traps the removed façade helper name and proves `Runtime::run_get(..., return_descr => 1)` still returns a descriptor hash with compiled `gdata` through the compiler-owned path.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=135`)
## 2026-03-10 - Phase 1A Slice: Remove Facade Local Spec Path Helper
## Summary
Reduced another stale `LinkedSpec.pm` compatibility seam by removing the façade-only `_resolve_local_spec_path(...)` wrapper and regression-locking the active local/module-relative parser-resolution path to `LinkedSpec::Resolver`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale resolver delegation from `LinkedSpec.pm`:
  - deleted `LinkedSpec::_resolve_local_spec_path(...)`,
  - active local/module-relative lookup continues to resolve through `LinkedSpec::Resolver::_resolve_local_spec_path(...)` via `resolve_spec_path(...)`.
- Added focused regression coverage:
  - `get_parser_avoids_linkedspec_local_spec_path_facade`
  - the regression traps the removed façade helper name and proves `get_parser('Lispish')` still resolves from a non-project cwd, builds a parser, executes it, and keeps `PathSearch` unloaded.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Resolver.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=134`)
## 2026-03-10 - Phase 1A Slice: Remove Stale Compiler Bootstrap Helper
## Summary
Reduced stale compiler scaffolding by removing the unused `LinkedSpec::Compiler::_run_bootstrap_parse(...)` helper now that bootstrap parsing is fully owned by `LinkedSpec::BootstrapSpec`, and regression-locking the active pipeline to that owner path.

## Changed Files
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Removed stale compiler-local bootstrap parsing glue:
  - deleted `LinkedSpec::Compiler::_run_bootstrap_parse(...)`,
  - active bootstrap parsing continues to resolve through `LinkedSpec::BootstrapSpec::run_bootstrap_parse(...)`.
- Added focused regression coverage:
  - `compiler_pipeline_avoids_legacy_run_bootstrap_parse_helper`
  - the regression traps the removed compiler-local helper name and proves `Runtime::run_get(...)` still returns a valid descriptor through the active BootstrapSpec-owned path.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=133`)
## 2026-03-10 - Plugin Runtime Slice: Add Explicit `PluginBridge` Runtime Deps
## Summary
Started the plugin/runtime modernization track in code by making `LinkedSpec::PluginBridge` own explicit plugin-runtime load/exec dependency callbacks, so future module-based plugin runtime work can replace `PPlugin` without changing `LinkedSpec::AUTOLOAD`.

## Changed Files
- Updated: `perl/LinkedSpec/PluginBridge.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::PluginBridge`:
  - added `_default_deps()` for lazy `PPlugin` loading and dispatch execution,
  - added `_dispatch_autoload(...)` as the internal compatibility-shim owner that consumes injected `load_plugin_runtime` and `exec_plugin` callbacks,
  - `LinkedSpec::AUTOLOAD` now delegates straight to `_dispatch_autoload(...)`,
  - removed the stale `dispatch_autoload(...)` wrapper.
- Added focused regression coverage:
  - `autoload_avoids_plugin_bridge_wrapper`
  - `plugin_bridge_supports_injected_plugin_runtime_deps`
  - the new seam locks prove `LinkedSpec::AUTOLOAD` still delegates through `PluginBridge`, and that `PluginBridge` can execute through injected runtime callbacks without relying on direct `PPlugin` calls at the call site.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=132`)
## 2026-03-10 - Phase 1A Slice: Move Pipeline Default Callbacks Into `Compiler`
## Summary
Reduced another compiler/runtime callback seam by making `LinkedSpec::Compiler::run_get_pipeline(...)` own the default `bootstrap_parse` and `compile_spec_entry` callbacks, so `LinkedSpec::Runtime::run_get(...)` now injects only `runtime_ctx` for mutable per-run state.

## Changed Files
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::Compiler::run_get_pipeline(...)`:
  - it now defaults `bootstrap_parse` to `LinkedSpec::BootstrapSpec::run_bootstrap_parse(...)` internally,
  - it now defaults `compile_spec_entry` to `LinkedSpec::SpecEntry::compile_spec_entry(...)` bound to the injected `runtime_ctx`,
  - explicit callback injection remains available for focused tests and future internal refactors.
- Simplified `LinkedSpec::Runtime::run_get(...)`:
  - it now injects only `runtime_ctx`,
  - compiler owner modules now supply the default bootstrap/rule-compilation callbacks.
- Added focused regression coverage:
  - `runtime_run_get_defers_default_pipeline_callbacks_to_compiler_owner`
  - the regression traps `LinkedSpec::Compiler::run_get_pipeline(...)` and proves `Runtime::run_get(...)` no longer injects `bootstrap_parse` or `compile_spec_entry` while still returning a valid descriptor hash.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=130`)
## 2026-03-10 - Phase 1A Slice: Move Final Descriptor `spec_gdata` Default Into `Compiler`
## Summary
Reduced another compiler-owned callback seam by making `LinkedSpec::Compiler::_build_final_descr(...)` own the default `spec_gdata` callback, so `run_get_pipeline(...)` no longer threads that callback explicitly during descriptor assembly.

## Changed Files
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::Compiler::_build_final_descr(...)`:
  - it now defaults `spec_gdata` to `LinkedSpec::Compiler::spec_gdata(...)` internally,
  - explicit callback injection remains available for focused tests and future internal refactors.
- Simplified `LinkedSpec::Compiler::run_get_pipeline(...)`:
  - final descriptor assembly now calls `_build_final_descr($auto_descr_spec)` directly,
  - `run_get_pipeline(...)` no longer threads `\&spec_gdata` as an explicit callback.
- Added focused regression coverage:
  - `run_get_pipeline_defers_default_spec_gdata_callback_to_final_descr_owner`
  - the regression traps `LinkedSpec::Compiler::_build_final_descr(...)` and proves the compiler pipeline now leaves the default `spec_gdata` callback undefined at the call site while still returning a valid descriptor.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=129`)
## 2026-03-10 - Phase 1A Slice: Move `spec_descr(...)` Default Callback Into `Compiler`
## Summary
Reduced another façade-owned default by making `LinkedSpec::Compiler::spec_descr(...)` own the default `compile_spec_entry` callback, so `LinkedSpec::spec_descr(...)` is now a pure façade delegate and no longer injects that default itself.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::Compiler::spec_descr(...)`:
  - it now defaults `compile_spec_entry` to `LinkedSpec::SpecEntry::compile_spec_entry(...)` internally,
  - injected compile callbacks are still supported for focused tests and alternative compilation paths.
- Simplified `LinkedSpec::spec_descr(...)`:
  - it now delegates directly to `LinkedSpec::Compiler::spec_descr(...)`,
  - default callback ownership no longer lives in `LinkedSpec.pm`.
- Added focused regression coverage:
  - `spec_descr_defers_default_compile_callback_to_compiler_owner`
  - the regression traps `LinkedSpec::Compiler::spec_descr(...)` and proves `LinkedSpec::spec_descr(...)` now delegates without injecting the default callback while still returning a compiled handler.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=128`)
## 2026-03-10 - Phase 1A Slice: Move ParserFactory Default Deps Out of the Facade
## Summary
Reduced another façade-only helper seam by making `LinkedSpec::ParserFactory::run_get_parser(...)` own its default trace/resolution/compile dependency map, so the public `LinkedSpec::get_parser(...)` path no longer depends on the private façade helper `_parser_factory_deps()`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/ParserFactory.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::ParserFactory::run_get_parser(...)`:
  - it now loads its default dependency map from `LinkedSpec::Deps` when no explicit dep hash is supplied,
  - the explicit injected-deps seam remains available for focused tests and internal reuse.
- Simplified `LinkedSpec::get_parser(...)`:
  - it still normalizes flat option pairs locally,
  - parser-factory dispatch now delegates without calling the façade-only `_parser_factory_deps()` helper.
- Added focused regression coverage:
  - `get_parser_avoids_linkedspec_parser_factory_dep_builder`
  - the regression traps `LinkedSpec::_parser_factory_deps()` and proves `get_parser(...)` still returns an executable parser and parses input successfully.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=127`)
## 2026-03-10 - Phase 1A Slice: Normalize `get_parser(...)` Options Before `ParserFactory`
## Summary
Reduced another active raw-argument compatibility seam by making `LinkedSpec::get_parser(...)` normalize its flat option pairs locally and pass a hashref into `LinkedSpec::ParserFactory::run_get_parser(...)`, so the public parser path no longer depends on option-list normalization inside `ParserFactory.pm`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/ParserFactory.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::get_parser(...)`:
  - it now preserves the existing odd-option fallback behavior while normalizing flat option pairs locally,
  - parser-factory dispatch now forwards a normalized option hashref instead of a raw option list.
- Tightened `LinkedSpec::ParserFactory::run_get_parser(...)`:
  - it now treats the option payload as a hashref contract,
  - trace setup, resolution, and compile forwarding continue to use the same option keys and values.
- Added focused regression coverage:
  - `get_parser_normalizes_option_pairs_before_parser_factory`
  - the regression traps `LinkedSpec::ParserFactory::run_get_parser(...)` and proves `get_parser(...)` now passes a normalized option hashref with the expected trace option keys while still returning an executable parser.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=126`)
## 2026-03-09 - Phase 1A Slice: Route `Get(...)` Through `Runtime::run_get`
## Summary
Reduced another active compatibility-wrapper dependency by making `LinkedSpec::Get(...)` normalize its flat option pairs locally and delegate straight to `LinkedSpec::Runtime::run_get(...)`, so the public `Get` path no longer depends on `LinkedSpec::Runtime::run_get_from_args(...)`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::Get(...)`:
  - it now extracts the spec scalar ref and normalizes trailing flat option pairs locally,
  - runtime compilation now delegates directly to `LinkedSpec::Runtime::run_get(...)`.
- Preserved compatibility:
  - `LinkedSpec::Runtime::run_get_from_args(...)` remains available as a compatibility wrapper for callers that still invoke the runtime entrypoint with raw flat option pairs,
  - public `Get(...)` behavior and option surface remain unchanged.
- Added focused regression coverage:
  - `get_avoids_runtime_run_get_from_args_wrapper`
  - the regression traps `LinkedSpec::Runtime::run_get_from_args(...)` and proves `LinkedSpec::Get(...)` still returns an executable parser coderef and successfully parses input without touching that wrapper.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=125`)
## 2026-03-09 - Phase 1A Slice: Route ParserFactory Compilation Through `Runtime::run_get`
## Summary
Reduced another active compatibility-wrapper dependency by making `LinkedSpec::ParserFactory` compile specs through `LinkedSpec::Runtime::run_get(...)` with an injected option hashref, so parser-factory compilation no longer depends on `LinkedSpec::Runtime::run_get_from_args(...)`.

## Changed Files
- Updated: `perl/LinkedSpec/ParserFactory.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::ParserFactory::run_get_parser(...)`:
  - it now forwards a normalized option hashref into the injected compile callback,
  - `trace_reset_log` is still stripped before the compile step so parser generation does not reapply reset-only trace handling.
- Updated parser-factory dependency wiring:
  - `LinkedSpec::Deps::parser_factory_deps_for_package(...)` now resolves `compile_spec` from `LinkedSpec::Runtime::run_get(...)` instead of `run_get_from_args(...)`.
- Preserved compatibility:
  - `LinkedSpec::Runtime::run_get_from_args(...)` remains as a compatibility wrapper for raw `Get(...)`-style entrypoints,
  - `LinkedSpec::Get(...)` public behavior is unchanged.
- Extended focused regression coverage:
  - `get_parser_avoids_linkedspec_parser_factory_facade`
  - the regression now also traps `LinkedSpec::Runtime::run_get_from_args(...)` and proves `get_parser(...)` still resolves, compiles, executes, and emits trace output without touching that raw-arg wrapper.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=124`)
## 2026-03-09 - Phase 1A Slice: Move Bootstrap Parse Ownership into `BootstrapSpec`
## Summary
Reduced another compiler/runtime coupling point by making `LinkedSpec::BootstrapSpec` own cached bootstrap grammar state and bootstrap parse execution, while `LinkedSpec::Compiler::run_get_pipeline(...)` now depends only on an injected `bootstrap_parse` callback instead of the raw bootstrap descriptor/index/gdata triple.

## Changed Files
- Updated: `perl/LinkedSpec/BootstrapSpec.pm`
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Expanded `LinkedSpec::BootstrapSpec`:
  - added `cached_bootstrap_state()` to lazily own the shared hardcoded bootstrap grammar state,
  - added `run_bootstrap_parse(...)` as the bootstrap parse owner for runtime/compiler callers.
- Refactored `LinkedSpec::Compiler::run_get_pipeline(...)`:
  - removed direct dependency on `spec_descr`, `bootstrap_rule_index`, and `gdata`,
  - now requires a single injected `bootstrap_parse` callback for the bootstrap parse step.
- Simplified `LinkedSpec::Runtime::run_get(...)`:
  - removed local bootstrap descriptor caching from `Runtime.pm`,
  - now injects `LinkedSpec::BootstrapSpec::run_bootstrap_parse(...)` directly into the compiler pipeline.
- Added focused regression coverage:
  - `compiler_run_get_pipeline_uses_injected_bootstrap_parse_and_runtime_context`
  - the regression proves `run_get_pipeline(...)` succeeds with the new injected `bootstrap_parse` callback plus shared `runtime_ctx`, and invokes the callback exactly once while preserving descriptor generation and parser-source capture.
- Refreshed focused bootstrap-entry tests:
  - targeted spec-entry/runtime tests now use `LinkedSpec::BootstrapSpec::run_bootstrap_parse(...)` directly instead of the older compiler-owned bootstrap parse helper.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=124`)
## 2026-03-09 - Phase 1A Slice: Route SpecEntry Compilation Through `SpecEntry.pm`
## Summary
Reduced another façade-era wrapper by letting `LinkedSpec::SpecEntry::compile_spec_entry(...)` consume the injected runtime context directly for parser-source emission and `top_rule` propagation, so default spec-entry compilation no longer depends on `LinkedSpec::Runtime::compile_spec_entry(...)` except as compatibility glue.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `perl/LinkedSpec/SpecEntry.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::SpecEntry::compile_spec_entry(...)`:
  - it now accepts `runtime_ctx` in its dependency hash,
  - parser-source emission falls back to `runtime_ctx->{emit_parser_source_line}`,
  - discovered `top_rule` is written back into the shared runtime context before returning.
- Simplified default/facade wiring:
  - `LinkedSpec::Runtime::run_get(...)` now injects `LinkedSpec::SpecEntry::compile_spec_entry(...)` directly into the compiler pipeline,
  - `LinkedSpec::spec_descr(...)` now defaults to `LinkedSpec::SpecEntry::compile_spec_entry(...)`,
  - `LinkedSpec::spec_entry(...)` now delegates directly to `SpecEntry.pm`,
  - `LinkedSpec::Runtime::compile_spec_entry(...)` remains only as a compatibility wrapper around the extracted owner.
- Added focused regression coverage:
  - `spec_entry_paths_avoid_runtime_compile_spec_entry_wrapper`
  - the regression traps `LinkedSpec::Runtime::compile_spec_entry(...)` and proves both `LinkedSpec::spec_descr(...)` and `LinkedSpec::Get(..., return_descr => 1)` still compile rules successfully without touching that wrapper.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=124`)
## 2026-03-09 - Phase 1A Slice: Collapse Compiler Runtime State Deps into `runtime_ctx`
## Summary
Reduced another compiler/runtime coupling point by making `LinkedSpec::Compiler::run_get_pipeline(...)` consume a single injected runtime context hash for parser-source emission, chunk capture, and `top_rule` propagation instead of threading those mutable state handles as separate dependencies.

## Changed Files
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::Compiler::run_get_pipeline(...)`:
  - added a single required `runtime_ctx` dependency,
  - runtime-context validation now ensures parser-source chunk storage exists on the shared hash,
  - parser-source emission, final `Get` wrapper generation, and `top_rule` reads now all route through `runtime_ctx`.
- Simplified `LinkedSpec::Runtime::run_get(...)`:
  - stopped passing `emit_parser_source_line`, `top_rule_ref`, and `parser_source_chunks_ref` as separate compiler dependencies,
  - now injects the already-existing per-run `runtime_ctx` hash directly into `Compiler.pm`.
- Added focused regression coverage:
  - `compiler_run_get_pipeline_uses_injected_runtime_context`
  - the regression proves `run_get_pipeline(...)` succeeds when only `runtime_ctx` is provided for mutable parser-build state, records `top_rule`, and emits parser-source output through that shared injected context.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=123`)
## 2026-03-09 - Phase 1A Slice: Move Runtime Mutable State into Per-Run Context
## Summary
Reduced another package-global coupling point in `LinkedSpec::Runtime` by moving mutable parser-build state (`top_rule`, parser-source emission) into an injected per-run runtime context hash while keeping the cached bootstrap grammar shared.

## Changed Files
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::Runtime`:
  - cached bootstrap state is now grouped in a shared lexical hash (`spec_descr`, `bootstrap_rule_index`, `gdata`),
  - mutable per-run state now lives in a runtime context hash created by `run_get(...)`,
  - parser-source emission now delegates through the injected runtime context instead of package-global `PARSER_SOURCE_EMIT_CB`,
  - `compile_spec_entry(...)` now accepts optional injected runtime context and writes discovered `top_rule` back into that context.
- Preserved behavior:
  - `LinkedSpec::Get(...)` / `LinkedSpec::Runtime::run_get_from_args(...)` still compile and return functional parsers with the same public API,
  - cached bootstrap grammar reuse is unchanged,
  - parser-source dumping and top-rule propagation still work through the compiler pipeline.
- Added focused regression coverage:
  - `runtime_compile_spec_entry_uses_injected_runtime_context`
  - the regression proves `LinkedSpec::Runtime::compile_spec_entry(...)` can compile a parsed entry, emit parser-source chunks, and write `top_rule` into injected state without relying on package-global mutation.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=122`)
## 2026-03-09 - Phase 1A Slice: Decouple ParserFactory from `LinkedSpec.pm` Facade
## Summary
Reduced another modularization-era reach-back into `LinkedSpec.pm` by making parser-factory dependency wiring use `LinkedSpec::Trace`, `LinkedSpec::Resolver`, and `LinkedSpec::Runtime` directly instead of routing trace/config/compile callbacks through façade helpers on `LinkedSpec.pm`.

## Changed Files
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Updated `LinkedSpec::Deps::parser_factory_deps_for_package(...)`:
  - trace/config callbacks now resolve from `LinkedSpec::Trace`,
  - spec validation/path/content callbacks continue to resolve from `LinkedSpec::Resolver`,
  - parser compilation callback now resolves from `LinkedSpec::Runtime::run_get_from_args(...)`,
  - dump-level values now resolve from `LinkedSpec::Trace` instead of `LinkedSpec.pm`.
- Preserved behavior:
  - `LinkedSpec::get_parser(...)` still returns parser coderefs with the same public API,
  - module-relative spec resolution still keeps `PathSearch` unloaded when not needed,
  - trace routing still works, but trace metadata now surfaces the real owning modules (`ParserFactory.pm`, `Resolver.pm`, `Compiler.pm`, etc.) rather than necessarily `LinkedSpec.pm`.
- Added focused regression coverage:
  - `get_parser_avoids_linkedspec_parser_factory_facade`
  - the regression traps the old `LinkedSpec.pm` parser-factory façade helpers/values and proves `get_parser(...)` still creates and executes a parser, keeps `PathSearch` unloaded for module-relative resolution, and emits routed trace output.
- Refreshed trace metadata regression:
  - `trace_output_includes_metadata_and_decisions` now asserts owning-module metadata rather than hardcoding `LinkedSpec.pm`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=121`)
## 2026-03-09 - Phase 1A Slice: Decouple ActionRewriter Lowering from `LinkedSpec.pm` Facade
## Summary
Reduced another modularization-era reach-back into `LinkedSpec.pm` by making `LinkedSpec::ActionRewriter` own the extracted lowering callbacks used by its declare/scanner/contract dependency maps, instead of resolving those callbacks through the façade.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Expanded `LinkedSpec::ActionRewriter`:
  - added local wrapper/dependency-builder helpers for extracted ActionIR modules:
    - `FlowExpr`
    - `ValueExpr`
    - `MethodLowering`
    - `ArrayPipeline`
    - `ControlFlow`
  - direct action-rewriter lowering now stays inside `LinkedSpec::ActionRewriter` for:
    - declare helper lowering
    - value/assignment lowering
    - array-pipeline lowering
    - fluent control-flow lowering
    - return/push/regex-substitution lowering
- Updated `LinkedSpec::Deps`:
  - `action_rewriter_declare_method_deps_for_package(...)` no longer hardcodes `LinkedSpec.pm` for declare/value lowering callbacks,
  - `action_rewriter_scanner_deps_for_package(...)` no longer hardcodes `LinkedSpec.pm` for array-pipeline planning,
  - `action_rewriter_contract_deps_for_package(...)` no longer hardcodes `LinkedSpec.pm` for method/pipeline/control-flow lowering callbacks.
- Added focused regression coverage:
  - `action_rewriter_avoids_removed_linkedspec_lowering_facade`
  - the regression traps the old `LinkedSpec::_...` lowering helper names and proves direct `LinkedSpec::ActionRewriter::call_spec_handler_subst(...)` rewrites still succeed for declare, assign, push, regex, pipeline, flow, switch, and return forms.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=120`)
## 2026-03-09 - Phase 1A Slice: Decouple RuleIR EmitContext from `LinkedSpec.pm` Action-Rewriter Facade
## Summary
Reduced one more modularization-era reach-back into `LinkedSpec.pm` by making `LinkedSpec::RuleIR::EmitContext` call `LinkedSpec::ActionRewriter` directly for rewrite-rule construction, rewrite execution, diagnostic accumulation, and trim helpers.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Updated `LinkedSpec::RuleIR::EmitContext`:
  - added explicit module dependency on `LinkedSpec::ActionRewriter`,
  - introduced local wrapper helpers that delegate to `LinkedSpec::ActionRewriter`,
  - removed remaining direct calls to:
    - `LinkedSpec::_build_action_rewrite_rules(...)`
    - `LinkedSpec::_rewrite_action_code_with_diagnostics(...)`
    - `LinkedSpec::_accumulate_action_rewrite_diagnostics(...)`
    - `LinkedSpec::_trim_action_ir_value(...)`
- Preserved behavior:
  - emit-context assembly still produces rewritten ACODE/BCODE/lifecycle chunks,
  - per-rule `action_rewriter` metadata remains intact,
  - gdata mapping order remains unchanged.
- Added focused regression coverage:
  - `ruleir_emit_context_avoids_linkedspec_action_rewriter_facade`
  - the regression traps the old `LinkedSpec.pm` façade helper names and proves `LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context(...)` still succeeds without them.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=119`)
## 2026-03-09 - CI Slice: Add Shared Local/GitHub Phase-0 Gate
## Summary
Added a repo-root CI entrypoint that can be run locally and from GitHub Actions, and tightened it so the gate only passes when the workflow/script themselves are git-tracked and the exercised LinkedSpec surface stays free of machine-specific absolute paths.

## Changed Files
- Added: `.github/workflows/ci.yml`
- Added: `tools/run_ci_local.sh`
- Updated: `README.md`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added shared CI gate `tools/run_ci_local.sh`:
  - checks required commands: `git`, `perl`, `prove`
  - requires git-tracked CI-critical files:
    - `.github/workflows/ci.yml`
    - `tools/run_ci_local.sh`
    - `perl/LinkedSpec.pm`
    - `t/phase0_regression.t`
  - requires git-tracked CI-critical trees:
    - `specs/`, `plugin/`, `conf/`, `tablescript/`, `ebnf/`, `perl/`, `t/`
  - fails on untracked files under the CI-critical surface, including the workflow directory and shared CI script path
  - audits machine-specific absolute-path literals across:
    - `.github/workflows/ci.yml`
    - `tools/run_ci_local.sh`
    - `t/phase0_regression.t`
    - `perl/LinkedSpec.pm`
    - `perl/LinkedSpec/**`
  - runs:
    - `perl -c perl/LinkedSpec.pm`
    - `perl -c -Iperl t/phase0_regression.t`
    - `prove -v -Iperl t/phase0_regression.t`
- Added `.github/workflows/ci.yml`:
  - triggers on `push`, `pull_request`, and `workflow_dispatch`
  - delegates directly to `bash tools/run_ci_local.sh` so local and GitHub validation stay aligned
- Verified the enforcement gap was closed:
  - before staging the new CI files, the gate failed because `.github/workflows/ci.yml` was not git-tracked
  - after staging the CI files, the gate passed cleanly
- Scope note:
  - the absolute-path audit now covers the CI-exercised LinkedSpec surface
  - older literals remain in non-LinkedSpec/non-gated files such as `perl/env.conf` and `perl/EasyTk.pm`

## Validation
- Ran:
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=118`)
## 2026-03-09 - Phase 1A Slice: Inject `compile_spec_entry` into `Compiler.pm`
## Summary
Reduced one more internal reverse dependency in the modularization track by making `LinkedSpec::Compiler` consume an injected `compile_spec_entry` callback during spec-descriptor assembly instead of calling back into `LinkedSpec.pm` directly.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Refactored `LinkedSpec::Compiler::spec_descr(...)`:
  - it now requires a `compile_spec_entry` callback,
  - it no longer reaches back into `LinkedSpec::spec_entry(...)` while iterating parsed bootstrap entries.
- Refactored `LinkedSpec::Compiler::run_get_pipeline(...)`:
  - it now requires injected dependency `compile_spec_entry`,
  - descriptor assembly passes that callback through to `spec_descr(...)`.
- Updated `LinkedSpec::Runtime::run_get(...)`:
  - runtime pipeline wiring now injects `\&compile_spec_entry` into compiler dependencies so top-rule propagation stays owned by `Runtime.pm`.
- Preserved public compatibility surface:
  - `LinkedSpec::spec_descr(...)` still works with its existing public signature,
  - the façade now supplies `\&LinkedSpec::Runtime::compile_spec_entry` to the compiler internally.
- Added focused regression coverage:
  - `compiler_spec_descr_uses_injected_compile_spec_entry_callback`
  - locks that `LinkedSpec::Compiler::spec_descr(...)` can build a rule descriptor through an injected callback and still returns a compiled handler.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=118`)
## 2026-03-09 - Roadmap Slice: Add `array_copy(...)` Snapshot Alias
## Summary
Added clearer backend-neutral snapshot helper `array_copy(array(...))` as the preferred alias for `array_values(array(...))`, while keeping the older spelling fully supported and updating the lowering guides to present the new name as the canonical surface.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/FlowExpr.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_ArrayPipeline.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `USER_GUIDE_ActionIR_EmittedPerlReference.md`
- Updated: `USER_GUIDE_ActionIR_MethodLowering.md`
- Updated: `USER_GUIDE_ActionIR_ValueExpr.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added snapshot-helper alias recognition in canonical lowering:
  - `array_copy(array(target))` now lowers to `[@target]`,
  - legacy `array_values(array(target))` is unchanged and still lowers to the same emitted Perl shape.
- Routed the alias through every existing array-snapshot lowering surface:
  - direct method-value lowering in `MethodLowering::_lower_method_value_expr`,
  - generalized `return(payload)` direct helper detection and nested helper rewriting in `_lower_return_payload_expr`,
  - flow/value passthrough recognition in `ActionIR::FlowExpr`.
- Expanded focused regression coverage:
  - `action_rewriter_lowers_array_snapshot_and_array_assign_method_contracts` now covers `array_copy(...)` in `push_value(...)`, plain `return(payload)`, structured hash payloads, and descriptor readiness through an inline `return(array_copy(array(items)))` spec.
- Documentation cleanup:
  - the top-level guide and ActionIR references now present `array_copy(...)` as the preferred snapshot helper for new DSL authoring,
  - `array_values(...)` is now documented explicitly as preserved compatibility syntax rather than the preferred new spelling.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=117`)
## 2026-03-09 - Roadmap Slice: Migrate `tkgui` Entry-Point Print to Canonical Helper Flow
## Summary
Cleared the remaining `tkgui.spec` blocker by replacing the last raw entry-point debug print in `sub_gui` with canonical helper `print(...)`, while preserving both the printed message and the parser’s current one-entry hash result shape.

## Changed Files
- Updated: `specs/tkgui.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Selected `tkgui.spec` as the next deterministic tail slice because after the `pplugin` cleanup it was the final remaining blocked non-deferred spec (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`).
- Cleared the blocked `tkgui` rule:
  - `sub_gui`
- Reworked the `sub_gui` initializer print:
  - retained the existing `my ($subgui_name) = @IMATCH_LIST` destructuring,
  - replaced raw debug print `print "Found a SUB GUI entry point <$subgui_name>\n"` with:
    - `print("Found a SUB GUI entry point <", scalar(subgui_name), ">\n")`
- Important migration nuance:
  - the blocker was only the interpolated debug print; the existing return shape was already flowing through recognized helper lowering,
  - preserving behavior meant keeping the current output string unchanged even though the parser’s resulting hash shape is non-obvious,
  - the new smoke regression deliberately locks that current one-entry hash result instead of “fixing” it as part of this migration slice.
- Added focused regression coverage:
  - `tkgui_helper_flow_eliminates_raw_fallback`
  - `tkgui_parser_smoke`
  - these lock zero raw fallback, zero unresolved-helper hits, zero blocked-rule summary state, preserved entry-point print output, and the current one-entry hash result on a compact inline sample with a top-level comment.
- Updated blocker scan after the slice:
  - `tkgui.spec` no longer appears in the blocked-spec ranking
  - current non-deferred action-rewriter migration scan result:
    - zero blocked specs (`__BLOCKED_COUNT__=0`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=117`)
## 2026-03-09 - Roadmap Slice: Migrate `pplugin` Top Accumulator to Canonical Helper Flow
## Summary
Cleared the remaining `pplugin.spec` blocker by replacing the last raw list-splice in `pplugin_top` with canonical collection-target assignment, while preserving the parser’s returned hash-of-coderefs behavior for parsed `.plg` files.

## Changed Files
- Updated: `specs/pplugin.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Selected `pplugin.spec` as the next deterministic tail slice because after the `portmap` cleanup it had become the highest remaining one-rule blocker (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`).
- Cleared the blocked `pplugin` rule:
  - `pplugin_top`
- Reworked the top accumulator flow:
  - retained the existing initializer and child call shape (`my @defs; my $retv` and `$retv = call(subdef)`),
  - replaced raw splice `push @defs, @$retv` with canonical collection-target assignment:
    - `assign(array(defs), array(flat_array(defs), scalaref(retv, [0]), scalaref(retv, [1])))`
- Important migration nuance:
  - the blocker was not the child call itself but the flat list-splice of the returned `[name, coderef]` pair,
  - rebuilding `@defs` through `assign(array(...), array(...))` preserved the original flat `name => coderef` list semantics expected by the existing `return {@defs}` path,
  - this avoided adding new lowering contracts or changing the parser’s output contract.
- Added focused regression coverage:
  - `pplugin_helper_flow_eliminates_raw_fallback`
  - `pplugin_parser_smoke`
  - these lock zero raw fallback, zero unresolved-helper hits, zero blocked-rule summary state, and preserved returned hash/coderef execution behavior on a small inline plugin sample with comments.
- Updated blocker scan after the slice:
  - `pplugin.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=115`)
## 2026-03-08 - Roadmap Slice: Capture Plugin Modernization and `PathSearch` Strategy
## Summary
Recorded the missing roadmap commitment to replace the current `AUTOLOAD` + `.plg` plugin runtime with a clearer module-based plugin system, and documented the short-term decision to keep `PathSearch->go(...)` as a compatibility surface while hardening/replacing its internals rather than removing it outright.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `CHANGES.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Root cause for the roadmap gap:
  - existing docs only captured the lazy-loading cleanup (`LinkedSpec::PluginBridge`, lazy `PPlugin` load, lazy `PathSearch` fallback),
  - they did not explicitly state that the current plugin runtime itself is planned for later replacement.
- Captured current plugin-runtime behavior in the notes:
  - `LinkedSpec::AUTOLOAD` delegates to `LinkedSpec::PluginBridge::dispatch_autoload(...)`,
  - the bridge lazy-loads `PPlugin`,
  - `PPlugin` builds a cached registry from cwd `*.plg` plus project `plugin/*.plg`, parses those files via `pplugin.spec`, and dispatches plugins by extracted method-name suffix.
- Captured current `PathSearch` behavior in the notes:
  - `PathSearch->go(...)` seeds a mutable `state $search_path` from cwd plus a recursive project-tree walk,
  - extra directories are merged by hash dedupe and unordered `keys %hash`,
  - misses currently warn and return `undef`.
- Recorded roadmap direction:
  - plugin runtime: migrate toward explicit module/package plugins and registry/loader semantics, with `AUTOLOAD` + `.plg` kept only as a compatibility bridge during transition,
  - `PathSearch`: keep the public API short-term because it is still used by parser resolution, config loading, GUI/resource lookup, FSM loading, and plugin helpers, but rework the implementation around deterministic search roots, lazy walking, better diagnostics, and later CPAN-backed primitives,
  - keep this track orthogonal to Backbone item #3 so `pplugin.spec` cleanup can proceed without treating the current runtime as the final architecture.

## Validation
- Not run (`ROADMAP.md` / notes-only update)
## 2026-03-08 - Roadmap Slice: Migrate `portmap` Bare-Bit-Slice Classification to Canonical Helper Flow
## Summary
Cleared the remaining `portmap.spec` blocked rule by rewriting `bare_bit_slice` from a raw Perl smartmatch classifier into canonical helper control flow, while preserving the existing `bare` / `bit` / `slice` / `constant` AST shapes and explicitly locking the `bit[0]` edge case.

## Changed Files
- Updated: `specs/portmap.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Selected `portmap.spec` as the next slice because after the `sdce` cleanup it was the highest remaining blocked spec (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`).
- Cleared the blocked `portmap` rule:
  - `bare_bit_slice`
- Reworked `bare_bit_slice` into canonical helper flow:
  - raw `$mcnt = @IMATCH_LIST` / smartmatch classification logic was replaced with helper `if` / `elseif` / `else` branches,
  - helper returns now use `return(array("?kind:", array(flat_array(IMATCH_LIST))))`,
  - classification now branches on:
    - `matches(scalar(IMATCH), /:/)` for `slice`,
    - `or(eq(scalar(IMATCH_LIST, 1), "0"), is_nonempty(scalar(IMATCH_LIST, 1)))` for `bit`,
    - `matches(scalar(IMATCH_LIST, 0), /^\\d/io)` for `constant`,
    - final `else()` for `bare`.
- Important migration nuance:
  - `is_nonempty(scalar(IMATCH_LIST, n))` on indexed captures lowers through truthiness rather than strict defined/nonempty string checks,
  - because of that, zero-valued indices such as `bar[0]` and slice low bits such as `baz[7:0]` needed explicit classification logic instead of a naive truthiness test,
  - using `matches(scalar(IMATCH), /:/)` for slice detection plus the explicit `eq(..., "0")` guard for `bit` preserved the original zero-valued cases without reintroducing raw Perl.
- Behavior cleanup side effect:
  - the old raw classifier emitted Perl experimental smartmatch warnings during parsing,
  - the helper rewrite removes that warning path while keeping the AST contract unchanged.
- Added focused regression coverage:
  - `portmap_bare_bit_slice_helper_flow_eliminates_raw_fallback`
  - `portmap_bare_bit_slice_classification_smoke`
  - these lock zero raw fallback, zero unresolved-helper hits, canonical node coverage, zero blocked-rule summary state, and representative AST classification cases including `bar[0]`.
- Updated blocker scan after the slice:
  - `portmap.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=113`)
## 2026-03-08 - Roadmap Slice: Migrate `sdce` to Canonical Helper Flow
## Summary
Cleared the remaining `sdce.spec` blocked rules by rewriting the top accumulator and nested pin/port tokenization flow into canonical helper actions, removing raw push/substr/split chains while preserving parser output shape.

## Changed Files
- Updated: `specs/sdce.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Selected `sdce.spec` as the next slice because after the `lib_reader` cleanup it was the highest remaining blocked spec (`BLOCKED=2`, `TOP=sdc_esplit`, `BLOCKERS=5`).
- Cleared the blocked `sdce` rules:
  - `sdc_esplit`
  - `get_pinport`
- Reworked `sdc_esplit` into canonical helper flow:
  - initializer now uses `I.declare(array, pieces).declare(scalar, retv).assign(scalar(IPOS), 0)`
  - child dispatch accumulation now uses `assign(scalar(retv), call(get_pinport))` plus `push_value(array(pieces), scalar(retv))`
  - plain substring captures now use helper-shell `assign(...)` plus `push_value(...)`
  - rule exit now uses `return(array_values(array(pieces)))`
- Reworked `get_pinport` into canonical helper flow:
  - initializer now uses `I.declare(array, pieces)`
  - plain-text segment tokenization now uses `split(..., /(\\s+)/)` plus `filter_nonempty(...)`
  - brace-content tokenization now uses `split(..., /\\s+/)` plus `filter_nonempty(...)`
  - append semantics are preserved with `assign(array(pieces), array(flat_array(pieces), flat_array(segment_parts)))`
  - structured return now uses `return(array(flat_array(IMATCH_LIST), array_values(array(pieces))))`
- Important migration nuance:
  - `split(array(segment_parts), scalar(segment), /(\\s+)/)` was needed on the `LS` path to preserve the original interstitial whitespace tokens from raw `split /(\\s+)/`,
  - `split(..., /\\s+/)` on the brace path preserved the old non-whitespace token behavior from `=~ /\\S+/og`,
  - array reassignment with `flat_array(...)` provided a canonical replacement for the old raw `push @pieces, LIST` splice behavior.
- Added focused regression coverage:
  - `sdce_helper_flow_eliminates_raw_fallback`
  - locks per-rule zero raw fallback, zero unresolved-helper hits, canonical node coverage, and descriptor-level zero-blocker summary state for `sdce`
- Manual semantic spot-checks on representative inputs remained unchanged, including bracketed pin/port lists with whitespace and nested brace content.
- Updated blocker scan after the slice:
  - `sdce.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `portmap.spec` (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`)
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=111`)
## 2026-03-08 - Roadmap Slice: Migrate `lib_reader` to Canonical Helper Flow
## Summary
Cleared the remaining `lib_reader.spec` blocked rules by rewriting the initializer and attribute-normalization logic into canonical helper flow, using method-chain initializer syntax where the brace-block helper form still left raw-fallback metadata.

## Changed Files
- Updated: `specs/lib_reader.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Selected `lib_reader.spec` as the next slice because it had become the highest remaining blocked spec after the `DT` + `hlink_substitution` cleanup (`BLOCKED=3`, `TOP=group`, `BLOCKERS=4`).
- Cleared the blocked `lib_reader` rules:
  - `group`
  - `sattribute`
  - `cattribute`
- Rewrote the old raw cleanup paths into helper flow:
  - `group`
    - moved the initializer into method-chain form:
      - `I.declare(scalar, grouptype=scalar(IMATCH_LIST, 0), groupname=scalar(IMATCH_LIST, 1)).substr(scalar(groupname), "\"", "", go)`
    - migrated the close action to:
      - `.return(array("GROUP", scalar(grouptype), scalar(groupname), array_values(array(group))))`
    - migrated the syntax-error branch to canonical `say(...)` helper syntax plus `exit 1`
  - `sattribute`
    - migrated to method-chain form:
      - `I.declare(...).substr(...).return(array("SATTRIBUTE", ...))`
  - `cattribute`
    - migrated to method-chain form:
      - `I.declare(...).declare(array, value_items).substr(...).split(...).return(array("CATTRIBUTE", ..., array_values(array(value_items))))`
- Important nuance discovered during the slice:
  - the direct brace-block helper form for these initializer rules still reported raw-fallback metadata even though `call_spec_handler_subst(...)` could lower the same helper statements correctly in isolation,
  - switching those initializers to the existing method-chain form (`I.declare(...).substr(...).return(...)`) cleared the raw-fallback counts and made the rules language-agnostic-action-IR ready.
- Added focused regression coverage:
  - `lib_reader_helper_flow_eliminates_raw_fallback`
  - locks zero raw fallback, zero unresolved-helper hits, readiness, and zero blocked-rule summary state for `lib_reader`
- Updated blocker scan after the slice:
  - `lib_reader.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `sdce.spec` (`BLOCKED=2`, `TOP=sdc_esplit`, `BLOCKERS=5`)
    - `portmap.spec` (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`)
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=110`)
## 2026-03-08 - Roadmap Slice: Migrate `hlink_substitution` to Canonical Helper Flow
## Summary
Cleared the remaining `hlink_substitution.spec` blocked rules by converting the raw error prints to canonical `print(...)` helper flow and rewriting the top accumulator rule into canonical helper flow with declarations, handler-call assignment, helper push, and helper return logic.

## Changed Files
- Updated: `specs/hlink_substitution.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Chose `hlink_substitution.spec` over the tied `lib_reader.spec` candidate because it was the lower-risk slice:
  - `hlink_substitution` blockers were limited to raw error prints plus one simple accumulator push in `substitute_top`
  - `lib_reader` still wants conditional regex-substitution cleanup in three rules
- Cleared the blocked `hlink_substitution` rules:
  - `substitute_top`
  - `substitute_statement2`
  - `curlyb`
- Reworked `substitute_top` into canonical helper flow:
  - declarations now use `declare(scalar, retv); declare(array, word_items)`
  - child dispatch assignments now use `assign(scalar(retv), call(...))`
  - the loop-end accumulator now uses `push_value(array(word_items), scalar(retv))`
  - the rule exit now uses helper control flow:
    - `if(is_nonempty(array(word_items))); return(array_values(array(word_items))); else(); return_undef(); endif()`
- Replaced the remaining raw error prints with canonical helper calls:
  - dangling closing bracket in `substitute_top`
  - unmatched closing bracket in `substitute_statement2`
  - unmatched closing brace in `curlyb`
- Added focused regression coverage:
  - `hlink_substitution_helper_flow_eliminates_raw_fallback`
  - locks per-rule zero raw fallback, zero unresolved-helper hits, node coverage, and descriptor-level zero-blocker summary state
- Updated blocker scan after the slice:
  - `hlink_substitution.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `lib_reader.spec` (`BLOCKED=3`, `TOP=group`, `BLOCKERS=4`)
    - `sdce.spec` (`BLOCKED=2`, `TOP=sdc_esplit`, `BLOCKERS=5`)
    - `portmap.spec` (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`)
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=109`)
## 2026-03-08 - Roadmap Slice: Migrate `DT` Debug Prints to Canonical Helper Flow
## Summary
Cleared the remaining `DT.spec` blocked rules by converting all raw debug `print` statements to canonical `print(...)` helper flow, added a focused regression lock, and refreshed the blocker snapshot after the slice.

## Changed Files
- Updated: `specs/DT.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Selected `DT.spec` immediately after the `operators_try` commit because it became the highest remaining blocked spec in the corpus scan (`BLOCKED=11`, `TOP=group`, `BLOCKERS=14`).
- Confirmed that the entire `DT.spec` blocker surface was raw debug prints only, so the slice required no new lowering contracts.
- Migrated the remaining blocked `DT` rules:
  - `dtree`
  - `testcontrol`
  - `group`
  - `identifier`
  - `if_binary`
  - `if_vector`
  - `reg_assignment_lhs`
  - `state_transition`
  - `dtree_call`
  - `logical_operator`
  - `inline_dt_definition`
- Replaced raw `print "..."` actions with canonical `print(...)` helper flow throughout the spec.
- Re-expressed the old interpolated `($IMATCH)` diagnostics with canonical helper arguments using `scalar(IMATCH)`, e.g. `print("(identifier)(", scalar(IMATCH), ")\n")`.
- Added focused regression coverage:
  - `dt_debug_print_helper_flow_eliminates_raw_fallback`
  - locks per-rule zero raw fallback, canonical `PRINT` node coverage, and descriptor-level zero-blocker summary state.
- Updated blocker scan after the slice:
  - `DT.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `hlink_substitution.spec` (`BLOCKED=3`, `TOP=substitute_top`, `BLOCKERS=4`)
    - `lib_reader.spec` (`BLOCKED=3`, `TOP=group`, `BLOCKERS=4`)
    - `sdce.spec` (`BLOCKED=2`, `TOP=sdc_esplit`, `BLOCKERS=5`)
    - `portmap.spec` (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`)
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=108`)
## 2026-03-08 - Roadmap Slice: Migrate `operators_try` Debug Prints to Canonical Helper Flow
## Summary
Cleared the remaining `operators_try` blocked rules by converting all raw debug `print` statements to canonical `print(...)` helper flow, added a focused regression lock, and refreshed the live notes with the new post-slice blocker ranking.

## Changed Files
- Updated: `specs/operators_try.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Selected `operators_try` as the next slice because the corpus-level migration summary had it as the highest remaining blocked spec (`BLOCKED=13`, `BLOCKERS=16`) and every blocker statement in the inspected rules was a raw debug print, so no new lowering contracts were required.
- Migrated the remaining blocked `operators_try` rules:
  - `top_expression`
  - `group`
  - `function_call`
  - `string`
  - `auto_inc_op`
  - `auto_dec_op`
  - `div_op`
  - `mul_op`
  - `add_op`
  - `sub_op`
  - `string_concat`
  - `variable`
  - `integer`
- Replaced raw `print "..."` actions with canonical `print(...)` helper flow throughout the spec.
- Re-expressed the old interpolated `($IMATCH)` diagnostics with canonical helper arguments using `scalar(IMATCH)`, e.g. `print("-> (", scalar(IMATCH), ") auto_inc_op\n")`.
- Removed the leftover nested `I { ... }` wrapper inside the `group[1]` closing action so the rule no longer contributed a residual raw fallback statement.
- Added focused regression coverage:
  - `operators_try_debug_print_helper_flow_eliminates_raw_fallback`
  - locks per-rule zero raw fallback, canonical `PRINT` node coverage, and descriptor-level zero-blocker summary state.
- Updated blocker scan after the slice:
  - `operators_try` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `DT.spec` (`BLOCKED=11`, `TOP=group`, `BLOCKERS=14`)
    - `hlink_substitution.spec` (`BLOCKED=3`, `TOP=substitute_top`, `BLOCKERS=4`)
    - `lib_reader.spec` (`BLOCKED=3`, `TOP=group`, `BLOCKERS=4`)
    - `sdce.spec` (`BLOCKED=2`, `TOP=sdc_esplit`, `BLOCKERS=5`)
    - `portmap.spec` (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`)
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=107`)
## 2026-03-08 - Roadmap Slice: Migrate `Lispish::parenthesis` and Finalize the Exhaustive Lowering Guide Set
## Summary
Completed the last outstanding `Lispish` blocker by migrating `Lispish::parenthesis` off raw Perl fallback, added canonical assignment-source lowering for `call(rule)`, and finished the lowering documentation pass with a hub, module-focused guides, and an exhaustive emitted-Perl reference for the current ActionIR surface.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/ValueExpr.pm`
- Updated: `specs/Lispish.spec`
- Updated: `t/phase0_regression.t`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_DeclareMethod.md`
- Updated: `USER_GUIDE_ActionIR_MethodLowering.md`
- Updated: `USER_GUIDE_ActionIR_ValueExpr.md`
- Updated: `USER_GUIDE_ActionIR_FlowExpr.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `USER_GUIDE_ActionIR_ArrayPipeline.md`
- Updated: `USER_GUIDE_ActionIR_Contracts.md`
- Updated: `USER_GUIDE_ActionIR_EmittedPerlReference.md`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added canonical method-value lowering for `call(rule)` in `MethodLowering.pm` and taught assignment-source lowering in `ValueExpr.pm` to route `assign(scalar(retv), call(rule))` through that path instead of leaving it as a raw wrapper.
- Cleared `Lispish::parenthesis` by replacing the old raw state machine:
  - removed raw declarations `my @submatchs; my @word; my $retv`
  - removed raw call-wrapper assignments such as `$retv = call(parenthesis)`
  - removed the raw `LE { ... }` post-dispatch classification block
  - replaced them with canonical helper flow using:
    - `declare(array, word, tail)`
    - `declare(scalar, retv, head, has_head)`
    - `assign(scalar(retv), call(parenthesis))`
    - `push_value(array(word), scalaref(retv, {content}))`
    - `join_values("", array(word))`
    - `if/else/endif`
    - `return(array(...))`
- Preserved the existing recursive Lispish AST semantics while re-expressing the rule as explicit head/tail accumulation:
  - the first completed item becomes `head`
  - later completed items are accumulated into `tail`
  - empty list remains `return(array(undef))`
  - single-item list remains `return(array(scalar(head), undef))`
  - multi-item list remains `return(array(scalar(head), array_values(array(tail))))`
- Added/updated regressions:
  - extended `action_rewriter_lowers_method_contracts_for_capture_and_structured_return_values` with a direct lock for `assign(scalar(retv), call(Leaf))`
  - refreshed `lispish_small_helper_flow_eliminates_raw_fallback` to the final zero-blocker state
  - added `lispish_parenthesis_helper_flow_eliminates_raw_fallback`
  - kept `lispish_ast_smoke` passing to preserve the baseline nested AST shape
- Post-migration metadata snapshot:
  - `Lispish::parenthesis`: `raw_perl_dependency_count` `6 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `Lispish::parenthesis` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, `PUSH`, `IF`, `CALL`, and `RETURN`
  - `Lispish` descriptor migration summary: `language_agnostic_blocked_rule_count` `1 -> 0`
- Documentation scope:
  - rewrote `USER_GUIDE.md` into a navigation hub that explains portability tiers, common lowering patterns, and inspection workflow
  - added module-focused lowering references for:
    - `DeclareMethod.pm`
    - `MethodLowering.pm`
    - `ValueExpr.pm`
    - `FlowExpr.pm`
    - `ControlFlow.pm`
    - `ArrayPipeline.pm`
    - `Contracts.pm`
  - added `USER_GUIDE_ActionIR_EmittedPerlReference.md` as the exhaustive lowering-contract review document:
    - enumerates the preferred canonical helper surface,
    - enumerates compatibility helpers such as `return_a`, `return_m`, `return_ma`, `return_im`, `return_imatch`, `return_array`, capture/backtrack helpers, and raw call wrappers,
    - enumerates classified pass-through idioms that are preserved verbatim while still counting as canonical ActionIR rather than `RAW_PERL` fallback,
    - shows the emitted Perl shape for each documented construct
  - documented the preferred canonical replacement of raw `$retv = call(rule)` wrappers with `assign(scalar(retv), call(rule))`
  - added broader examples for declarations, value constructors, assignment, control flow, array pipelines, regex substitution, switch regex cases, and compatibility helper surfaces
  - cross-linked the module guides back to the exhaustive emitted-Perl reference so review can start either from the top-level hub or from the relevant ActionIR module guide

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=106`)
## 2026-03-08 - Roadmap Slice: Migrate `vhdl::subprogram_body` to Canonical Helper Flow
## Summary
Advanced roadmap Item #3 by adding a small backend-neutral array tokenization helper and using it to migrate `vhdl::subprogram_body` off raw Perl fallback, clearing the last blocked `vhdl` rule.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
- Updated: `perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`
- Updated: `perl/LinkedSpec/ActionIR/Contracts.pm`
- Updated: `specs/vhdl.spec`
- Updated: `t/phase0_regression.t`
- Updated: `USER_GUIDE.md`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added backend-neutral array tokenization helper:
  - `split_each(array(...), /.../)`
  - lowers as a composable flattened per-element split stage and now surfaces canonical `SPLIT_EACH` action-IR metadata.
- Cleared `vhdl::subprogram_body` by replacing the raw init/finalization block with helper flow:
  - `declare(scalar, pos_begin, subprogram_statement_part); declare(array, subprogram_statement_tokens)`
  - `assign(scalar(pos_begin), pos $$STRING)`
  - `assign(scalar(subprogram_statement_part), substr($$STRING, $pos_begin, $LSPOS - $pos_begin - length $LMATCH))`
  - `split(array(subprogram_statement_tokens), scalar(subprogram_statement_part), /((?:\s*--.*\s*)+|\s*;\s*)/)`
  - `split_each(array(subprogram_statement_tokens), /^(\s+)/)`
  - `filter_nonempty(array(subprogram_statement_tokens))`
  - `return(array("?subprogram_body:", flat_array(IMATCH_LIST), array_values(array(subprogram_statement_tokens))))`
- Preserved the previous tokenization behavior while removing the raw Perl `grep {length} map {split /^(\s+)/o} split ...` fallback path.
- Added focused regression coverage:
  - `vhdl_subprogram_body_helper_flow_eliminates_raw_fallback`
- Refreshed older VHDL snapshot tests:
  - `vhdl_declaration_helper_flow_eliminates_raw_fallback`
  - `vhdl_small_blocker_helper_flow_eliminates_raw_fallback`
  - `vhdl_process_statement_helper_flow_eliminates_raw_fallback`
  - each now expects the later zero-blocker state after `subprogram_body` cleanup.
- Post-migration metadata snapshot:
  - `vhdl::subprogram_body`: `raw_perl_dependency_count` `5 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl::subprogram_body` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, `SPLIT`, `SPLIT_EACH`, `FILTER_NONEMPTY`, `RETURN`, and existing `CALL`
  - `vhdl` descriptor migration summary: `language_agnostic_blocked_rule_count` `1 -> 0`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=105`)
## 2026-03-07 - Roadmap Slice: Migrate `ds_vhistory::vhistory` to Canonical Helper Flow
## Summary
Advanced roadmap Item #3 by migrating `ds_vhistory::vhistory` off raw Perl fallback using the existing helper surface, clearing the last blocked `ds_vhistory` rule without adding new lowering contracts.

## Changed Files
- Updated: `specs/ds_vhistory.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Cleared `ds_vhistory::vhistory` without adding new helper surface:
  - replaced the raw declaration block `my (@vhistory, @capt, @object_hier, $cur_object)` with canonical declaration flow:
    - `declare(array, vhistory, capt, object_hier)`
    - `declare(scalar, cur_object, first_capt, entry_tag, current_object_name)`
  - replaced the raw capture/object-hierarchy flush logic with helper flow using:
    - `if(is_nonempty(array(capt)))`
    - `assign(scalar(first_capt), scalar(array(capt), 0))`
    - `if(eq(scalaref(first_capt, [0]), "?branch:")) ... else() ... endif()`
    - `push_value(array(object_hier), array(scalar(entry_tag), array_values(array(capt))))`
  - replaced in-place arrayref mutation `push @$cur_object, [@object_hier]` with direct construction of the finalized object payload before pushing into `vhistory`:
    - `assign(scalar(current_object_name), scalaref(cur_object, [1]))`
    - `push_value(array(vhistory), array("?object:", scalar(current_object_name), array_values(array(object_hier))))`
  - replaced the raw final return `['?ds_vhistory:', \@vhistory]` with:
    - `return(array("?ds_vhistory:", array_values(array(vhistory))))`
  - migrated the debug print to canonical helper form:
    - `print("\tObject   ", scalaref(cur_object, [1]), "\n")`
- Added focused regression coverage:
  - `ds_vhistory_vhistory_helper_flow_eliminates_raw_fallback`
- Post-migration metadata snapshot:
  - `ds_vhistory::vhistory`: `raw_perl_dependency_count` `5 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `ds_vhistory::vhistory` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, `IF`, `ELSE`, `ENDIF`, `PUSH`, `RETURN`, `CALL`, and `PRINT`
  - `ds_vhistory` descriptor migration summary: `language_agnostic_blocked_rule_count` `1 -> 0`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=104`)
## 2026-03-07 - Roadmap Slice: Migrate `vhdl::process_statement` to Canonical Helper Flow
## Summary
Advanced roadmap Item #3 by migrating `vhdl::process_statement` off raw Perl fallback using the existing helper surface, reducing the `vhdl` blocked-rule set from two rules to only `subprogram_body`.

## Changed Files
- Updated: `specs/vhdl.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Cleared `vhdl::process_statement` without adding new helper surface:
  - replaced raw declaration block `my $pos_begin` with canonical declaration flow:
    - `declare(scalar, pos_begin, process_statement_part)`
  - replaced raw position capture `$pos_begin = pos $$STRING` with:
    - `assign(scalar(pos_begin), pos $$STRING)`
  - replaced raw substring/return logic with:
    - `assign(scalar(process_statement_part), substr($$STRING, $pos_begin, $LSPOS - $pos_begin - length $LMATCH))`
    - `return(array("?process_statement:", flat_array(IMATCH_LIST), array_values(array(process_statement)), scalar(process_statement_part)))`
- Removed the leftover commented raw debug-print statements from the action blocks so the rule no longer contributes raw fallback metadata.
- Added focused regression coverage:
  - `vhdl_process_statement_helper_flow_eliminates_raw_fallback`
- Refreshed older VHDL snapshot tests:
  - `vhdl_declaration_helper_flow_eliminates_raw_fallback` now expects the later `process_statement` cleanup state
  - `vhdl_small_blocker_helper_flow_eliminates_raw_fallback` now reflects that only `subprogram_body` remains blocked
- Post-migration metadata snapshot:
  - `vhdl::process_statement`: `raw_perl_dependency_count` `4 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl::process_statement` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, `RETURN`, plus existing `CALL`/`PUSH`
  - `vhdl` descriptor migration summary: `language_agnostic_blocked_rule_count` `2 -> 1`, with blocked-rule priority list now reduced to `['subprogram_body']`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=103`)
## 2026-03-07 - Roadmap Slice: Clear the Remaining Small Lispish Blockers
## Summary
Advanced roadmap Item #3 by migrating the remaining small `Lispish` blockers — `Lispish`, `sbrackets`, `dquotes`, `squotes`, `curlyb`, `spaces`, `others`, and `comments` — off raw Perl fallback using the existing helper surface, reducing the `Lispish` blocked-rule set from nine rules to only `parenthesis`.

## Changed Files
- Updated: `specs/Lispish.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Cleared the top-level `Lispish` syntax-error branch:
  - replaced the raw form `say "(Lispish) -E- Syntax Error"` with canonical helper-call syntax:
    - `say("(Lispish) -E- Syntax Error")`
  - preserved the existing hard exit behavior with `exit 1`.
- Migrated the small token/leaf rules to canonical structured returns:
  - `sbrackets` now returns `hash("type", "SBRACKETS", "content", scalar(IMATCH))`
  - `dquotes` now returns `hash("type", "DQUOTES", "content", scalar(IMATCH_LIST, 0))`
  - `squotes` now returns `hash("type", "SQUOTES", "content", scalar(IMATCH_LIST, 0))`
  - `spaces` now returns `hash("type", "SPACE", "content", scalar(IMATCH))`
  - `others` now returns `hash("type", "OTHERS", "content", scalar(IMATCH))`
  - `comments` now returns `hash("type", "COMMENTS", "content", scalar(IMATCH))`
- Migrated `curlyb` to canonical helper flow:
  - added `declare(scalar, content)`
  - replaced the raw capture/return block with:
    - `assign(scalar(content), CAPTURE)`
    - `return(hash("type", "CBRACE", "content", scalar(content)))`
- Added focused regression coverage:
  - `lispish_small_helper_flow_eliminates_raw_fallback`
- Post-migration metadata snapshot:
  - `Lispish`, `comments`, `curlyb`, `dquotes`, `others`, `sbrackets`, `spaces`, and `squotes` now each report `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `curlyb` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, and `RETURN`
  - top-level `Lispish` canonical action-IR nodes now include `SAY`
  - `Lispish` descriptor migration summary: `language_agnostic_blocked_rule_count` `9 -> 1`, with blocked-rule priority list now reduced to `['parenthesis']`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=102`)
## 2026-03-07 - Roadmap Slice: Clear the Remaining Small VHDL Blockers
## Summary
Advanced roadmap Item #3 by clearing the remaining small `vhdl` blockers — `signal_declaration`, `configuration_specification`, and `vhdl_file` — without adding new helper surface, reducing the `vhdl` blocked-rule set from five rules to just `subprogram_body` and `process_statement`.

## Changed Files
- Updated: `specs/vhdl.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Cleared `vhdl::signal_declaration`:
  - replaced raw rest-arity destructuring `my ($identifier_list, @remainder_info) = @IMATCH_LIST` with fixed-arity scalar destructuring:
    - `my ($identifier_list, $subtype_indication, $signal_kind, $expression) = @IMATCH_LIST`
  - preserved the existing return shape while removing the only remaining raw blocker statement for the rule.
- Cleared `vhdl::configuration_specification`:
  - replaced raw rest-arity destructuring `my ($instantiation_list, @remainder_info) = @IMATCH_LIST` with fixed-arity scalar destructuring:
    - `my ($instantiation_list, $component_name, $binding_indication) = @IMATCH_LIST`
  - preserved the existing return shape while removing the only remaining raw blocker statement for the rule.
- Cleared `vhdl::vhdl_file`:
  - removed the leftover line-buffering side effect `I {$|=1}`
  - kept the parser rule behavior unchanged apart from dropping that non-portable startup side effect.
- Added focused regression coverage:
  - `vhdl_small_blocker_helper_flow_eliminates_raw_fallback`
- Refreshed the older declaration-slice snapshot test:
  - `vhdl_declaration_helper_flow_eliminates_raw_fallback` now expects the later post-cleanup blocked-rule count.
- Post-migration metadata snapshot:
  - `vhdl::signal_declaration`: `raw_perl_dependency_count` `1 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl::configuration_specification`: `raw_perl_dependency_count` `1 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl::vhdl_file`: `raw_perl_dependency_count` `1 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl` descriptor migration summary: `language_agnostic_blocked_rule_count` `5 -> 2`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=101`)
## 2026-03-07 - Roadmap Slice: Migrate `ebnf::grammar_file` to Canonical Helper Flow
## Summary
Advanced roadmap Item #3 by migrating the remaining blocked `ebnf::grammar_file` accumulator/finalization path off raw Perl fallback using the existing helper surface, clearing the last `ebnf` blocked rule without adding new lowering contracts.

## Changed Files
- Updated: `specs/ebnf.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated `ebnf::grammar_file` initialization/finalization state to canonical helper flow:
  - replaced raw declarations with:
    - `declare(array, rules, rule, includes, semantic_annotations)`
    - `declare(scalar, rule, on)`
  - replaced both raw pending-rule flush sites with:
    - `if(scalar(rule))`
    - `push_value(array(rules), array(scalar(rule), flat_array(rule)))`
    - `endif()`
  - replaced raw final return `[@includes, @rules]` with:
    - `return(array(flat_array(includes), flat_array(rules)))`
- Migrated the `-> grammar_rule` state handoff:
  - copied staged semantic annotations into the next rule accumulator with:
    - `assign(array(rule), array(flat_array(semantic_annotations)))`
    - `assign(array(semantic_annotations), array())`
  - retained canonical call-wrapper assignment for rule binding:
    - `$rule = call(grammar_rule)`
    - `assign(scalar(on), 1)`
- Important DSL usage note captured during the slice:
  - `array_values(array(...))` remains the array-snapshot helper,
  - list-context array copying into an `assign(array(...), ...)` target should use `array(flat_array(source))`.
- Added focused regression coverage:
  - `ebnf_grammar_file_helper_flow_eliminates_raw_fallback`
- Post-migration metadata snapshot:
  - `ebnf::grammar_file`: `raw_perl_dependency_count` `4 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `ebnf` descriptor migration summary: `language_agnostic_blocked_rule_count` `1 -> 0`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=100`)
## 2026-03-07 - Roadmap Slice: Add Flat List Helpers and Clear VHDL Declaration Blockers
## Summary
Advanced roadmap Item #3 by adding backend-neutral flat list insertion helpers for array/hash content and then using that new helper surface to migrate `vhdl::subprogram_declaration` and `vhdl::type_declaration` off raw Perl fallback.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/Contracts.pm`
- Updated: `perl/LinkedSpec/BootstrapSpec/Core.pm`
- Updated: `specs/vhdl.spec`
- Updated: `t/phase0_regression.t`
- Updated: `USER_GUIDE.md`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added flat list insertion helper support in method/value lowering:
  - generic forms:
    - `flat(array(name))`
    - `flatten(array(name))`
    - `flat(hash(name))`
    - `flatten(hash(name))`
  - non-redundant aliases:
    - `flat_array(name)`
    - `flat_hash(name)`
- Flat helpers now lower into surrounding list-context insertion expressions:
  - arrays -> `@name`
  - hashes -> `%name`
- Generalized `return(payload)` and method-chain `.return(...)` payload detection now recognize flat-list helper starts, including direct forms such as `return(flat_array(items))`.
- `hash(...)` constructor lowering now accepts flat hash/list insertions alongside ordinary key/value pairs.
- Migrated VHDL declaration rules to use the new helper:
  - `subprogram_declaration`
    - replaced raw `@IMATCH_LIST` return expansion with `I.return(array("?subprogram_declaration:", flat_array(IMATCH_LIST)))`
  - `type_declaration`
    - removed inert raw start block
    - replaced raw capture/return logic with:
      - `declare(scalar, type_definition)`
      - `assign(scalar(type_definition), CAPTURE)`
      - `return(array("?type_declaration:", flat_array(IMATCH_LIST), scalar(type_definition)))`
- Added focused regression coverage:
  - `action_rewriter_lowers_flat_list_value_helpers`
  - `vhdl_declaration_helper_flow_eliminates_raw_fallback`
- Post-migration metadata snapshot:
  - `vhdl::subprogram_declaration`: `raw_perl_dependency_count` `1 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl::type_declaration`: `raw_perl_dependency_count` `2 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl` descriptor migration summary: `language_agnostic_blocked_rule_count` `7 -> 5`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=100`)
## 2026-03-07 - Roadmap Slice: Migrate VHDL Package Rules to Canonical Helper Flow
## Summary
Advanced roadmap Item #3 by migrating `vhdl::package_declaration` and `vhdl::package_body` off raw Perl fallback using the existing helper surface, clearing both rules from the blocked set without adding new lowering contracts.

## Changed Files
- Updated: `specs/vhdl.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated `vhdl::package_declaration`:
  - replaced the inert raw start block with canonical helper declaration flow `I {declare(array, imatch_copy)}`
  - replaced raw lowercase/return logic with helper flow:
    - `assign(array(imatch_copy), array(scalar(IMATCH_LIST, 0)))`
    - `lowercase_each(array(imatch_copy))`
    - `return(array("?package_declaration:", scalar(array(imatch_copy), 0), array_values(array(package_declaration))))`
- Migrated `vhdl::package_body`:
  - removed the empty raw start block entirely
  - replaced the raw structured return with `.return(array("?package_body:", scalar(IMATCH_LIST, 0), array_values(array(package_body))))`
- Added focused regression coverage:
  - `vhdl_package_helper_flow_eliminates_raw_fallback`
  - verifies zero raw fallback, canonical node coverage, readiness, and absence from the blocked-rule summary
- Post-migration metadata snapshot:
  - `vhdl::package_declaration`: `raw_perl_dependency_count` `2 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl::package_body`: `raw_perl_dependency_count` `2 -> 0`, `unresolved_helper_count` `0 -> 0`, `language_agnostic_action_ir_ready` `0 -> 1`
  - `vhdl` descriptor migration summary: `language_agnostic_blocked_rule_count` `9 -> 7`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=98`)
## 2026-03-07 - Roadmap Slice: Clear Final `vhdl::signal_decl_range` Blocker
## Summary
Advanced roadmap Item #3 by clearing the last remaining raw fallback in `vhdl::signal_decl_range`, replacing the raw array reset with canonical helper flow so the rule now reports zero blockers and full language-agnostic action-IR readiness.

## Changed Files
- Updated: `specs/vhdl.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated the last remaining blocked statement in `vhdl::signal_decl_range`:
  - replaced raw `@capt = ()` with canonical helper flow `assign(array(capt), array())`
- Strengthened existing regression lock:
  - `vhdl_signal_decl_range_method_flow_reduces_raw_push_capture_fallback`
  - now verifies:
    - zero raw fallback statements,
    - zero raw fallback count,
    - and `language_agnostic_action_ir_ready=1`
- Post-migration metadata snapshot for `vhdl::signal_decl_range`:
  - `raw_perl_dependency_count`: `1 -> 0`
  - `unresolved_helper_count`: `0 -> 0`
  - `language_agnostic_action_ir_ready`: `0 -> 1`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=97`)
## 2026-03-07 - Roadmap Slice: Add `hash(...)` Return Payload Lowering and Clear `tablegrep` Blockers
## Summary
Advanced roadmap Item #3 by teaching generalized `return(payload)` lowering to handle helper-based `hash(...)` constructor payloads, then using that canonical form to migrate the remaining blocked `tablegrep` rules (`and_op`, `or_op`, `re_term`) off raw Perl fallback.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `specs/tablegrep.spec`
- Updated: `t/phase0_regression.t`
- Updated: `USER_GUIDE.md`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added helper-based hash constructor lowering in generalized return payload flow:
  - `return(hash("key", value, ...))` now lowers to a canonical structured hash payload instead of falling through as a raw helper expression
  - helper hash keys are normalized as stable string expressions while nested helper values continue to lower recursively
- Migrated remaining blocked `tablegrep` rules:
  - `and_op`
    - moved raw return payload to `I.return(hash("type", "AND_OP"))`
  - `or_op`
    - moved raw return payload to `I.return(hash("type", "OR_OP"))`
  - `re_term`
    - replaced raw capture/branch logic with helper flow using `declare`, `if(matches(...))`, `substr`, and `return(hash(...))`
    - bracketed numeric fields now normalize through canonical regex substitution helper flow before returning `STERM`
- Added/extended regression coverage:
  - extended `action_rewriter_lowers_general_return_payloads_with_nested_structures` to lock `return(hash(...))` lowering
  - added `tablegrep_terminal_token_helper_flow_eliminates_raw_fallback`
  - verifies zero raw fallback and zero blocked-rule summary state for `tablegrep`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=97`)
## 2026-03-07 - Roadmap Slice: Clear Remaining `simenv` Action-Rewriter Blockers
## Summary
Advanced roadmap Item #3 by migrating the last two blocked `simenv.spec` rules, `top` and `anyvariable`, to canonical helper flow so the `simenv` spec no longer reports any language-agnostic action-IR blocked rules.

## Changed Files
- Updated: `specs/simenv.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated `simenv::top`:
  - replaced raw `my @blocks` initialization with `declare(array, blocks)`
  - replaced `push @blocks, $retv if $retv` with fluent helper control flow using `if(...)`, `push_value(...)`, and `endif()`
  - replaced bare Perl `return @blocks ? \@blocks : undef` with helper return flow using `if(...)`, `return(array_values(array(blocks)))`, and `return_undef()`
- Migrated `simenv::anyvariable`:
  - replaced raw regex capture extraction `$IMATCH =~ /(\S+)/` with helper flow using `declare(scalar, variable_name=scalar(IMATCH))`
  - trimmed trailing spaces through `substr(...)`
  - converted diagnostic output to canonical `print(...)`
  - returned the structured payload through generalized `return({...})`
- Added focused regression coverage:
  - `simenv_top_and_anyvariable_helper_flow_eliminates_raw_fallback`
  - locks zero raw fallback and readiness for `top` and `anyvariable`, and verifies `simenv` now reports zero blocked rules in descriptor migration metadata

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=96`)
## 2026-03-07 - Roadmap Note: Queue `array_values(...)` Naming Cleanup
## Summary
Recorded a deferred roadmap task to rename the backend-neutral array snapshot helper `array_values(array(...))` to clearer `array_copy(array(...))` later, without changing current runtime behavior or helper semantics in this slice.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added an explicit backlog note under roadmap immediate-next-step guidance:
  - future naming cleanup target: `array_values(array(...))` -> `array_copy(array(...))`
  - current helper behavior remains unchanged for now
  - transition is expected to preserve compatibility for existing specs when the rename is eventually implemented

## Validation
- Docs-only roadmap update.
- No code or test validation was required for this slice.
## 2026-03-07 - Roadmap Slice: Migrate `simenv` Quote/Substitution Diagnostics to Canonical Helper Flow
## Summary
Advanced roadmap Item #3 by converting the remaining raw diagnostic/debug print statements in a focused `simenv.spec` quote/substitution family to canonical helper flow, and by rewriting `variable_substitution` and `comments` to avoid raw regex/print/chomp fallbacks.

## Changed Files
- Updated: `specs/simenv.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated raw diagnostic/debug print statements to canonical helper flow in:
  - `singleline_value`
  - `dquotes`
  - `perl_dquotes`
  - `command_substitution`
  - `perl_command_substitution`
- Rewrote remaining raw helper-block logic in:
  - `variable_substitution`
    - now uses `declare(scalar, variable_name=scalar(IMATCH))`
    - strips the leading `$` via `substr(...)`
    - emits diagnostics through `print(...)`
    - returns via generalized `return({...})`
  - `comments`
    - now uses `declare(scalar, comment_text=scalar(IMATCH))`
    - removes the trailing newline via `substr(...)`
    - emits diagnostics through `print(...)`
- Migration impact:
  - all seven migrated rules now report `raw_perl_dependency_count=0`,
  - all seven migrated rules now report `language_agnostic_action_ir_ready=1`.
- Added focused regression coverage:
  - `simenv_quote_substitution_helper_flow_eliminates_raw_fallback`
  - locks zero raw fallback, canonical `PRINT` node presence, and readiness across the selected `simenv` quote/substitution family.

## Validation
- Ran:
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=95`)
## 2026-03-07 - Roadmap Slice: Migrate `simenv` Delimiter-Helper Diagnostics to Canonical `print(...)` Flow
## Summary
Advanced roadmap Item #3 by converting the raw diagnostic/debug print statements in a focused `simenv.spec` delimiter-helper family to canonical `print(...)` helper calls, removing raw Perl fallback from those rules without changing parser behavior.

## Changed Files
- Updated: `specs/simenv.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated raw print statements to canonical helper flow in:
  - `bs_nl`
  - `squotes`
  - `perl_squotes`
  - `multiline_value`
  - `bvariable_substitution`
  - `curlybrace`
  - `parenthesis`
- Where diagnostic output included captured text or computed line numbers, the helper form now uses ordinary print arguments such as:
  - `print("<", substr(...), ">\n")`
  - `print("...", (@startline + 1), "\n")`
- Migration impact:
  - all seven migrated rules now report `raw_perl_dependency_count=0`,
  - all seven migrated rules now report `language_agnostic_action_ir_ready=1`.
- Added focused regression coverage:
  - `simenv_delimiter_helper_print_flow_eliminates_raw_fallback`
  - locks zero raw fallback, canonical `PRINT` node presence, and readiness across the selected `simenv` rule family.

## Validation
- Ran:
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=94`)
## 2026-03-07 - Roadmap Slice: Migrate `BNF.spec` Debug Prints to Canonical `print(...)` Helper Flow
## Summary
Advanced roadmap Item #3 by converting the raw debug-print statements in `specs/BNF.spec` to canonical `print(...)` helper calls, removing raw Perl fallback across the full BNF grammar while preserving existing behavior.

## Changed Files
- Updated: `specs/BNF.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated raw debug-print statements in `specs/BNF.spec` to canonical helper flow:
  - `description`
  - `construction_start`
  - `node`
  - `dquote_str`
  - `squote_str`
  - `regex`
  - `group`
  - `g_repetition`
  - `q_mark`
  - `plus`
  - `star`
  - `pipe`
- Where debug text depended on `$IMATCH`, the helper form now uses backend-neutral value access through `scalar(IMATCH)` inside `print(...)`.
- Migration impact:
  - eliminated raw-print fallback across the entire BNF spec,
  - all 12 migrated rules now report `raw_perl_dependency_count=0`,
  - all 12 migrated rules now report `language_agnostic_action_ir_ready=1`.
- Added focused regression coverage:
  - `bnf_debug_print_helper_flow_eliminates_raw_fallback`
  - locks zero raw fallback, canonical `PRINT` node presence, and readiness across the full BNF rule set.

## Validation
- Ran:
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=93`)
## 2026-03-06 - Roadmap Slice: Migrate `ifelse.spec` Debug Prints to Canonical `print(...)` Helper Flow
## Summary
Advanced roadmap Item #3 by converting the raw debug-print statements in `specs/ifelse.spec` to canonical `print(...)` helper calls, removing raw Perl fallback across the entire `ifelse` grammar without changing parser behavior.

## Changed Files
- Updated: `specs/ifelse.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Migrated all debug-print statements in `specs/ifelse.spec` from raw Perl:
  - `print "..."` -> `print("...")`
- Covered rules:
  - `program`
  - `if`
  - `then`
  - `elsif`
  - `else`
  - `while`
  - `while_then`
- Migration impact:
  - eliminated 23 raw-print fallback statements across the `ifelse` file,
  - all seven rules now report `raw_perl_dependency_count=0`,
  - all seven rules now report `language_agnostic_action_ir_ready=1`.
- Added focused regression coverage:
  - `ifelse_debug_print_helper_flow_eliminates_raw_fallback`
  - locks zero raw fallback, canonical `PRINT` node presence, and readiness across the full `ifelse` rule set.

## Validation
- Ran:
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=92`)
## 2026-03-06 - Roadmap Slice: Migrate `simenv::begin_end_blocks` with Canonical Array Snapshot Flow
## Summary
Advanced roadmap Item #3 by introducing backend-neutral `array_values(...)` array snapshot lowering, extending `assign(...)` beyond scalar targets, and migrating `specs/simenv.spec` rule `begin_end_blocks` away from Perl-specific `[@...]` / `\@...` payload forms to canonical helper flow.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/FlowExpr.pm`
- Updated: `specs/simenv.spec`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `git_message_brief.txt`

## Technical Details
- Added method value helper lowering:
  - `array_values(array(target))` now lowers to a snapshot of current array contents (`[@target]`) without requiring Perl array-literal syntax in `.spec`.
  - Implemented through `MethodLowering::_lower_method_value_expr` and routed through generalized return/flow value lowering so it works inside `return(...)` payloads and nested helper expressions.
- Extended assignment lowering:
  - `assign(target, source_expr)` now accepts `array(name)` and `hash(name)` targets in addition to scalar targets.
  - Collection-target assignment reuses structured initializer lowering, so `assign(array(items), array(...))` and `assign(hash(map), hash(...))` remain canonical helper forms.
- Migrated `specs/simenv.spec` `begin_end_blocks`:
  - replaced Perl-ish `[@keyval_pairs]` / `\@assigns` payload usage with `array_values(array(...))`,
  - moved block-name extraction, branch guards, pending-pair flush, structured return, and diagnostics to helper flow using `declare`, `assign`, `push_value`, `if/else/endif`, `substr`, `print`, `return`, `return_undef`, and `exit`.
- Added regression coverage:
  - `action_rewriter_lowers_array_snapshot_and_array_assign_method_contracts`,
  - `simenv_begin_end_blocks_method_flow_is_language_agnostic_ready`.
- Post-migration metadata snapshot for `simenv::begin_end_blocks`:
  - `raw_perl_dependency_count`: `8 -> 0`
  - `unresolved_helper_count`: `0 -> 0`
  - `language_agnostic_action_ir_ready`: `0 -> 1`

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=91`)
## 2026-03-06 - Roadmap Slice: Migrate `vhdl::signal_decl_range` to Method Flow + Add `join_values` Helper
## Summary
Advanced roadmap Item #3 by migrating `specs/vhdl.spec` rule `signal_decl_range` away from raw Perl capture/push/guard statements, and added canonical value helper `join_values(...)` so assignment sources no longer need raw Perl `join(...)` expression text in `.spec` method flow.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/FlowExpr.pm`
- Updated: `specs/vhdl.spec`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added method value helper lowering:
  - `join_values(delimiter, array(target))` now lowers to `join(delimiter, @target)`.
  - Implemented in `MethodLowering::_lower_method_value_expr`.
  - Routed through flow-expression source lowering by extending `FlowExpr` value-expression passthrough set.
- Migrated `vhdl.spec` `signal_decl_range` rule:
  - declaration setup moved from raw `my (@capt, @msi_lsi)` to `declare(array, capt, msi_lsi)`,
  - LS capture push moved to `push_value(array(capt), substr(...))`,
  - LE position update moved to `assign(scalar(IPOS), pos $$STRING)`,
  - nested capture handling moved to helper flow (`declare`, `assign`, `push_value`, `if`, `substr`, `endif`),
  - raw `join("", @capt)` sources replaced with `join_values("", array(capt))`.
- Added/updated regression locks:
  - expanded `action_rewriter_lowers_method_contracts_for_capture_and_structured_return_values` with `join_values` assignment-source lowering assertion,
  - added `vhdl_signal_decl_range_method_flow_reduces_raw_push_capture_fallback` to lock targeted raw fallback reductions and canonical node presence.
- Post-migration metadata snapshot for `vhdl::signal_decl_range`:
  - `raw_perl_dependency_count`: `9 -> 1`,
  - remaining raw fallback statement: `@capt = ()`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=89`)
## 2026-03-06 - Roadmap Slice: Add `push_value` Method Contract and Migrate `tablegrep` Accumulator Flow
## Summary
Advanced roadmap Item #3 by introducing a reusable `push_value(...)` action method contract (canonical `PUSH`) and migrating `tablegrep.spec` accumulator handling (`grep`/`group`) from raw Perl statements to fluent helper flow.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/Contracts.pm`
- Updated: `perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `specs/tablegrep.spec`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `push_value(...)` helper lowering end-to-end:
  - new lowering routine `MethodLowering::_lower_push_value_statement`,
  - new lowering contract `push_value` in `ActionIR::Contracts` with canonical `PUSH` node,
  - new scanner extractor `_scan_contract_push_value` in `Scanner::PrimitivePipelineRules`,
  - dependency wiring via `Deps::action_rewriter_contract_deps_for_package` and `LinkedSpec::_lower_push_value_statement`.
- Migrated `specs/tablegrep.spec` `grep`/`group` accumulator actions to fluent helper flow:
  - declarations now use `declare(array, internal)` + `declare(scalar, prev_node_type)`,
  - null-guard uses `if(not(scalar(retv))); return_undef(); endif();`,
  - accumulator push uses `push_value(array(internal), scalar(retv));`,
  - previous-node tracking uses `assign(scalar(prev_node_type), scalaref(retv, {type}))`,
  - group-empty guard now uses `if(is_empty(array(internal))); print(...); exit 2; endif();`,
  - group return now uses `return({type=>'GROUP', group=>array(internal)})`.
- Added regression coverage:
  - `action_rewriter_lowers_push_value_method_contract`,
  - `tablegrep_accumulator_method_flow_avoids_push_internal_raw_fallback`.
- Post-migration metadata check:
  - `tablegrep::grep` and `tablegrep::group` now report `raw=0`, `unresolved=0`, `fallback=0`, and `language_agnostic_action_ir_ready=1`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=88`)
## 2026-03-06 - Roadmap Slice: Migrate `tablegrep` Operator-Adjacency Guards to Fluent Method Flow
## Summary
Advanced roadmap Item #3 by migrating `tablegrep.spec` operator-adjacency guard logic from raw Perl `if (...) { ... }` blocks into fluent method-flow statements, reducing RAW_PERL fallback for those guard branches while preserving runtime behavior and diagnostics.

## Changed Files
- Updated: `specs/tablegrep.spec`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- In both `tablegrep` rules `grep` and `group`, converted LE guard blocks from raw Perl:
  - `if ($prev_node_type && $prev_node_type =~ /_OP/o && $$retv{type} =~ /_OP/o) { print ...; exit 1 }`
  to fluent method-flow statements:
  - `if(and(and(scalar(prev_node_type), matches(scalar(prev_node_type), /_OP/o)), matches(scalaref(retv, {type}), /_OP/o)));`
  - `print(...)`
  - `exit 1`
  - `endif();`
- This migration reuses existing method/value lowering surfaces:
  - `and(...)`, `matches(...)`, `scalar(...)`, `scalaref(...)`
  - flow control markers `if(...)` / `endif()`
- Added regression lock `tablegrep_operator_guard_method_flow_avoids_prev_node_type_if_raw_fallback` to ensure:
  - `grep` and `group` no longer report `if($prev_node_type...)` raw fallback statements,
  - canonical action-IR includes `IF` and `EXIT` nodes for the migrated guards.

## Validation
- Ran:
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=86`)
## 2026-03-06 - Roadmap Slice: EBNF Fluent-Branch Migration + Quote-Aware Method Parsing
## Summary
Advanced roadmap Item #3 (language-agnostic action migration) by converting `ebnf.spec` container-guard branches from raw Perl `if/else` blocks to fluent method-chain control flow, and fixed method-argument parsing/lowering so delimiters inside quoted strings (e.g., `(`, `)`, `{`, `}`, `[`, `]`) no longer break recursive parenthesis matching.

## Changed Files
- Updated: `specs/ebnf.spec`
- Updated: `t/phase0_regression.t`
- Updated: `perl/LinkedSpec/BootstrapSpec/Core.pm`
- Updated: `perl/LinkedSpec/ActionIR/MethodExpr.pm`
- Updated: `perl/LinkedSpec/ActionIR/Contracts.pm`
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm`
- Updated: `perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm`
- Updated: `perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Migrated `specs/ebnf.spec` `grammar_file` token edges (`rule_name`, `quoted_string`, `number`, operators, parens, regex, logging annotation, etc.) from raw Perl:
  - `if ($on) { push @rule, call(...) } else { say ...; return undef }`
  to fluent method-chain forms:
  - `.if(scalar(on)).push(..., rule).else().say(...).return_undef().endif()`
- Added regression lock `ebnf_grammar_file_method_chain_branches_avoid_if_on_raw_fallback` to assert:
  - `grammar_file` no longer reports `if($on)` raw-perl fallback statements,
  - canonical action-IR captures `IF` and `PUSH` nodes for those branches.
- Fixed parser/lowering bug root cause:
  - recursive `PAREN` regexes previously counted delimiters inside quoted string payloads as structural parentheses,
  - this could fragment/skip method calls when strings contained delimiter characters.
- Applied quote-aware recursive `PAREN` handling across method-chain parsing and ActionIR rewrite/scanner surfaces so quoted string delimiters are ignored as literals.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec/Core.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=85`)
## 2026-03-06 - Phase 1A Slice: Decompose RuleIR Emit-Context Construction into `RuleIR::EmitContext`
## Summary
Refactored `LinkedSpec::RuleIR::_build_rule_ir_emit_context` into focused helper routines in a new `LinkedSpec::RuleIR::EmitContext` module, while keeping `RuleIR.pm` as a thin delegate surface for emit-context functions.

## Changed Files
- Added: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `perl/LinkedSpec/RuleIR.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- New `LinkedSpec::RuleIR::EmitContext` ownership:
  - rewrite diagnostics accumulator initialization (`_build_rewrite_diag_acc`)
  - ACODE and BCODE rewrite passes (`_rewrite_acode_entries`, `_rewrite_bcode_entries`)
  - lifecycle chunk normalization (`_normalize_rule_lifecycle_code` + `_normalize_rule_code_chunks`)
  - unresolved-helper/raw-Perl blocker extraction and deduplication
  - action-rewriter metadata assembly (`_build_action_rewriter_meta`)
  - top-level emit-context orchestrator (`build_rule_ir_emit_context`).
- `LinkedSpec::RuleIR` now delegates:
  - `_normalize_rule_code_chunks` -> `RuleIR::EmitContext::_normalize_rule_code_chunks`
  - `_build_rule_ir_emit_context` -> `RuleIR::EmitContext::build_rule_ir_emit_context`
- Behavior-preserving output shape was retained for emit context fields consumed by `SpecEntry` (`ACODEs`, `BCODEs`, `BCALLs`, `GDATA`, lifecycle chunks, and `action_rewriter_meta`).

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-06 - Phase 1A Slice: Decompose `build_bootstrap_spec` into `BootstrapSpec::Core` Rule Builders
## Summary
Refactored the large `LinkedSpec::BootstrapSpec::build_bootstrap_spec` flow into focused rule-builder helpers in a new `LinkedSpec::BootstrapSpec::Core` module, and reduced `BootstrapSpec.pm` to a thin delegate facade.

## Changed Files
- Added: `perl/LinkedSpec/BootstrapSpec/Core.pm`
- Updated: `perl/LinkedSpec/BootstrapSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- `LinkedSpec::BootstrapSpec::Core` now owns:
  - method-chain parsing/rendering helpers used by method-like bootstrap rules,
  - focused per-rule descriptor builders (SPEC_ROOT, entry-label, action/non-action code blocks, comment, blind-call, split-like, and curly-brace scanner),
  - bootstrap descriptor assembly orchestrator (`_build_bootstrap_rule_descriptors`),
  - bootstrap registry/gdata compilation (`_build_bootstrap_registry_gdata`),
  - top-level orchestrator (`build_bootstrap_spec`).
- `build_bootstrap_spec` is now decomposed as:
  - context initialization (`node_type` map + mutable `bootstrap_rule_index` registry handle),
  - descriptor construction via targeted helper builders,
  - registry/gdata construction and registry backfill into handler-shared context.
- `LinkedSpec::BootstrapSpec::build_bootstrap_spec` is now a thin facade delegating to `LinkedSpec::BootstrapSpec::Core::build_bootstrap_spec`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec/Core.pm`
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-06 - Phase 1A Slice: Decompose Canonical Helper-Event Normalization into `CanonicalEvents::Core`
## Summary
Refactored `_canonicalize_helper_action_ir_event` by decomposing its large contract-id mapping logic into smaller targeted helpers in a new `LinkedSpec::ActionIR::CanonicalEvents::Core` module, while keeping `CanonicalEvents.pm` as a thin delegate for that path.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/CanonicalEvents/Core.pm`
- Updated: `perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- `LinkedSpec::ActionIR::CanonicalEvents::Core` now owns decomposed canonicalization helpers:
  - `_kind_override_for_contract_id`
  - `_canonical_kind`
  - `_normalize_canonical_args`
  - `canonicalize_helper_action_ir_event`
- Canonicalization logic is now structured as:
  - contract-id -> kind override lookup
  - grouped multi-contract kind handling
  - focused argument normalization for special contract families (`return_call`, push variants, `return_undef`)
  - final canonical event assembly.
- `LinkedSpec::ActionIR::CanonicalEvents::_canonicalize_helper_action_ir_event` is now a thin delegate into `CanonicalEvents::Core`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents/Core.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-06 - Phase 1A Slice: Decompose `_split_action_ir_statements` into Core + Mode Submodules
## Summary
Refactored the large statement-splitting state machine into smaller targeted functions across dedicated `StatementSplit` submodules, keeping `LinkedSpec::ActionIR::StatementSplit` as a thin facade.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/StatementSplit/Core.pm`
- Added: `perl/LinkedSpec/ActionIR/StatementSplit/Mode.pm`
- Updated: `perl/LinkedSpec/ActionIR/StatementSplit.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- `LinkedSpec::ActionIR::StatementSplit` now owns only dependency validation + delegation.
- New `StatementSplit::Core` ownership:
  - split orchestrator loop (`split_action_ir_statements`)
  - state initialization
  - nesting/terminator handling
  - trimmed statement emission.
- New `StatementSplit::Mode` ownership:
  - line/single/double/backtick/slash/angle/pipe mode consumers
  - mode-entry detectors for quote/comment and regex-like delimiters.
- The original single 240+ line state machine is now decomposed into focused helpers connected by the core orchestrator while preserving call surface.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit/Mode.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit/Core.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-05 - Phase 1A Slice: Decompose `scan_contract_ir_events` into Smaller Scanner Rule Submodules
## Summary
Refactored scanner ownership to break the large `scan_contract_ir_events` implementation into smaller targeted scanner rule submodules, with a thin orchestrator in `ScannerCore` and a stable facade in `Scanner`.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/ScannerCore.pm`
- Added: `perl/LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm`
- Added: `perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`
- Added: `perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm`
- Added: `perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm`
- Updated: `perl/LinkedSpec/ActionIR/Scanner.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- `LinkedSpec::ActionIR::Scanner` is now a thin facade that delegates to `LinkedSpec::ActionIR::ScannerCore`.
- `LinkedSpec::ActionIR::ScannerCore` now owns orchestration only:
  - dependency callback validation (`_require_dep`)
  - callback symbol localization into scanner-rule submodule packages
  - ordered dispatch across focused scanner rule modules.
- Scanner rule ownership moved into focused submodules:
  - `Scanner::PrimitiveBasicRules`
  - `Scanner::PrimitivePipelineRules`
  - `Scanner::FlowRules`
  - `Scanner::LegacyRules`
- Each scanner submodule now owns only a bounded contract-id family and uses small targeted handlers per contract id.
- Resulting scanner file sizing (approx):
  - `ScannerCore.pm`: 66 lines
  - `PrimitiveBasicRules.pm`: 241 lines
  - `PrimitivePipelineRules.pm`: 208 lines
  - `FlowRules.pm`: 246 lines
  - `LegacyRules.pm`: 198 lines
  - `Scanner.pm`: 25 lines

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ScannerCore.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-05 - Phase 1A Slice: Extract ActionRewriter Dependency-Map Ownership to `LinkedSpec::Deps`
## Summary
Moved ActionRewriter dependency-map ownership out of `LinkedSpec::ActionRewriter` into `LinkedSpec::Deps`, preserving behavior with thin dependency-map delegates in `ActionRewriter`.

## Changed Files
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added ActionRewriter-specific dependency-map builders in `LinkedSpec::Deps`:
  - `action_rewriter_declare_method_deps_for_package`
  - `action_rewriter_statement_split_deps_for_package`
  - `action_rewriter_canonical_event_deps_for_package`
  - `action_rewriter_scanner_deps_for_package`
  - `action_rewriter_diagnostics_deps_for_package`
  - `action_rewriter_rewrite_pipeline_deps_for_package`
  - `action_rewriter_contract_deps_for_package`
- Updated `LinkedSpec::ActionRewriter`:
  - added `use LinkedSpec::Deps ();`
  - converted `_declare_method_deps`, `_statement_split_deps`, `_canonical_event_deps`, `_diagnostics_deps`, `_rewrite_pipeline_deps`, and `_action_contract_deps` to delegates into `LinkedSpec::Deps`.
  - added `_scan_contract_ir_event_deps` delegate into `LinkedSpec::Deps`.
  - rewired `_scan_contract_ir_events` to consume `_scan_contract_ir_event_deps()` rather than an in-file dependency hash.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-04 - Phase 1A Slice: Extract Rewrite Pipeline Ownership to `LinkedSpec::ActionIR::RewritePipeline`
## Summary
Moved rewrite pipeline orchestration/lowering ownership out of `LinkedSpec::ActionRewriter` into a dedicated `LinkedSpec::ActionIR::RewritePipeline` module, preserving compatibility through thin delegates in `ActionRewriter`.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/RewritePipeline.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ActionIR::RewritePipeline` owning:
  - `_lower_action_code_from_canonical_ir`
  - `_build_action_rewrite_rules`
  - `_rewrite_action_code_with_diagnostics`
- Boundary design:
  - module is dependency-injected for contract construction, helper-IR collection, canonical-event assembly, and unresolved-helper detection callbacks,
  - no hard-coded direct calls into `LinkedSpec` internals from rewrite-pipeline logic.
- Updated `LinkedSpec::ActionRewriter`:
  - added `use LinkedSpec::ActionIR::RewritePipeline ();`
  - added `_rewrite_pipeline_deps` callback map
  - converted moved rewrite pipeline functions to thin delegates.
- Validation bug discovered/fixed during this slice:
  - corrected delegate argument forwarding in `_rewrite_action_code_with_diagnostics` so dependency callbacks are passed in the dedicated deps argument slot when `rewrite_rules` is omitted.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-04 - Phase 1A Slice: Extract Action-Rewrite Diagnostics Ownership to `LinkedSpec::ActionIR::Diagnostics`
## Summary
Moved action rewrite diagnostics/helper aggregation ownership out of `LinkedSpec::ActionRewriter` into a dedicated `LinkedSpec::ActionIR::Diagnostics` module, preserving compatibility through thin delegates in `ActionRewriter`.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/Diagnostics.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ActionIR::Diagnostics` owning:
  - `_find_unresolved_action_helpers`
  - `_collect_action_helper_ir_nodes`
  - `_accumulate_action_rewrite_diagnostics`
- Boundary design:
  - module is dependency-injected for statement splitting and contract-event scanning callbacks,
  - no hard-coded direct calls into `LinkedSpec` internals from diagnostics aggregation logic.
- Updated `LinkedSpec::ActionRewriter`:
  - added `use LinkedSpec::ActionIR::Diagnostics ();`
  - added `_diagnostics_deps` callback map
  - converted `_find_unresolved_action_helpers`, `_collect_action_helper_ir_nodes`, and `_accumulate_action_rewrite_diagnostics` to thin delegates.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Diagnostics.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-04 - Phase 1A Slice: Extract Action-IR Statement Splitting to `LinkedSpec::ActionIR::StatementSplit`
## Summary
Moved statement-splitting ownership out of `LinkedSpec::ActionRewriter` into a dedicated `LinkedSpec::ActionIR::StatementSplit` module, preserving behavior through a thin delegate in `ActionRewriter`.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/StatementSplit.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ActionIR::StatementSplit` owning:
  - `_split_action_ir_statements`
- Boundary design:
  - module is dependency-injected for trimming callback (`trim_action_ir_value`),
  - no hard-coded direct calls into `LinkedSpec` internals from statement-splitting logic.
- Updated `LinkedSpec::ActionRewriter`:
  - added `use LinkedSpec::ActionIR::StatementSplit ();`
  - added `_statement_split_deps` callback map
  - converted `_split_action_ir_statements` to a thin delegate to `ActionIR::StatementSplit`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-03 - Phase 1A Slice: Extract Canonical Helper-Event Ownership to `LinkedSpec::ActionIR::CanonicalEvents`
## Summary
Moved canonical helper-event normalization and canonical action-IR event assembly ownership out of `LinkedSpec::ActionRewriter` into a dedicated `LinkedSpec::ActionIR::CanonicalEvents` module, preserving compatibility through thin delegates in `ActionRewriter`.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ActionIR::CanonicalEvents` owning:
  - `_canonicalize_helper_action_ir_event`
  - `_build_canonical_action_ir_events`
- Boundary design:
  - module is dependency-injected for trimming and top-level statement splitting callbacks,
  - no hard-coded direct calls back into `LinkedSpec` internals from module logic.
- Updated `LinkedSpec::ActionRewriter`:
  - added `use LinkedSpec::ActionIR::CanonicalEvents ();`
  - added `_canonical_event_deps` callback map
  - converted `_canonicalize_helper_action_ir_event` and `_build_canonical_action_ir_events` to thin delegates.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-03 - Phase 1A Slice: Extract Remaining `Get`/`AUTOLOAD` Ownership from `LinkedSpec.pm`
## Summary
Moved the last non-delegate entrypoint ownership out of `LinkedSpec.pm` by extracting `AUTOLOAD` plugin dispatch to `LinkedSpec::PluginBridge` and moving raw `Get` argument parsing into `LinkedSpec::Runtime`.

## Changed Files
- Added: `perl/LinkedSpec/PluginBridge.pm`
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::PluginBridge::dispatch_autoload($autoload_name, @args)`:
  - owns lazy `PPlugin` loading and plugin dispatch execution.
- Updated `LinkedSpec::Runtime`:
  - added `run_get_from_args(@args)` to own raw `Get` argument normalization (`$spec_content_ref`, `%options`) and delegate to existing `run_get(...)`.
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::PluginBridge ();`
  - `Get(...)` now delegates to `LinkedSpec::Runtime::run_get_from_args(...)`
  - `AUTOLOAD(...)` now delegates to `LinkedSpec::PluginBridge::dispatch_autoload(...)`
- Ownership outcome:
  - `LinkedSpec.pm` no longer contains non-delegate orchestration/bridge logic for `Get` and `AUTOLOAD`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-03 - Phase 1A Slice: Extract Declare/Assign Method Helper Ownership to `LinkedSpec::ActionIR::DeclareMethod`
## Summary
Moved declare/assign method helper parsing/lowering ownership out of `LinkedSpec::ActionRewriter` into a dedicated `LinkedSpec::ActionIR::DeclareMethod` module, while preserving compatibility through thin delegates in `ActionRewriter` and `LinkedSpec.pm`.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/DeclareMethod.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/Deps.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ActionIR::DeclareMethod` owning:
  - `_split_declare_symbol_names`
  - `_parse_declare_binding_entry`
  - `_lower_declare_value_expr`
  - `_lower_declare_initializer_expr`
  - `_extract_declare_statement_from_method_expr`
  - `_lower_declare_method_statement`
  - `_lower_assign_method_statement`
- Boundary design:
  - module is dependency-injected via callback map (`trim`, method parse/scope helpers, flow/value lowering, declaration alias/type lowering, assign lowering),
  - no hard-coded direct calls back into `LinkedSpec` internals from module logic.
- Updated `LinkedSpec::ActionRewriter`:
  - added `_declare_method_deps` dependency map,
  - converted the moved helper surface to thin delegates into `ActionIR::DeclareMethod`.
- Updated `LinkedSpec::Deps`:
  - added `declare_method_deps_for_package` callback map builder.
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::ActionIR::DeclareMethod ();`,
  - added `_declare_method_deps` delegate helper,
  - rewired declare/assign helper wrappers to delegate directly to `ActionIR::DeclareMethod`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/DeclareMethod.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-03 - Phase 1A Slice: Extract Dependency-Map Ownership to `LinkedSpec::Deps`
## Summary
Moved callback dependency-map construction ownership out of `LinkedSpec.pm` into a dedicated `LinkedSpec::Deps` module with explicit callback/value contract checks.

## Changed Files
- Added: `perl/LinkedSpec/Deps.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::Deps` module owning dependency-map builders:
  - `flow_expr_deps_for_package`
  - `method_lowering_deps_for_package`
  - `array_pipeline_deps_for_package`
  - `control_flow_deps_for_package`
  - `value_expr_deps_for_package`
  - `parser_factory_deps_for_package`
- Contract enforcement added in `LinkedSpec::Deps`:
  - `_require_pkg_cb` verifies required callbacks exist and are callable,
  - `_require_pkg_value` verifies required constant/value providers exist.
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::Deps ();`
  - converted `_flow_expr_deps`, `_method_lowering_deps`, `_array_pipeline_deps`, `_control_flow_deps`, `_value_expr_deps`, and `_parser_factory_deps` into thin delegates to `LinkedSpec::Deps`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ValueExpr.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-02 - Phase 1A Slice: Extract Runtime State + Get/spec_entry Orchestration to `LinkedSpec::Runtime`
## Summary
Moved bootstrap runtime state and `Get`/`spec_entry` orchestration ownership out of `LinkedSpec.pm` into a dedicated `LinkedSpec::Runtime` module, preserving public entrypoint compatibility through thin delegates in `LinkedSpec.pm`.

## Changed Files
- Added: `perl/LinkedSpec/Runtime.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::Runtime` as the owner of:
  - bootstrap parser runtime state initialization (`spec_descr`, `bootstrap_rule_index`, `gdata`),
  - parser-source emit callback routing (`_emit_parser_source_line` + callback state),
  - `Get` orchestration glue (`run_get`) that injects runtime state into `LinkedSpec::Compiler::run_get_pipeline(...)`,
  - `spec_entry` orchestration glue (`compile_spec_entry`) including top-rule propagation.
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::Runtime ();`
  - converted `_emit_parser_source_line` to a thin delegate,
  - replaced `Get(...)` body with a thin delegate to `LinkedSpec::Runtime::run_get(...)`,
  - replaced `spec_entry(...)` body with a thin delegate to `LinkedSpec::Runtime::compile_spec_entry(...)`.
- Ownership clean-up:
  - removed runtime bootstrap globals/callback state management from `LinkedSpec.pm`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-02 - Phase 1A Slice: Transfer Action Contract/Scanner Wiring to `LinkedSpec::ActionRewriter`
## Summary
Moved action-rewriter contract wiring and scanner-adapter ownership out of `LinkedSpec.pm` into `LinkedSpec::ActionRewriter`, preserving compatibility through thin delegates in `LinkedSpec.pm`.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- `LinkedSpec::ActionRewriter` now owns:
  - `_action_contract_deps`
  - `_build_action_lowering_contracts`
  - `_scan_contract_ir_events`
- `ActionRewriter` internal flow updates:
  - `_collect_action_helper_ir_nodes` now routes scanner calls through local `_scan_contract_ir_events`,
  - `_build_action_rewrite_rules` now builds contracts through local `_build_action_lowering_contracts` rather than calling back into `LinkedSpec`.
- `LinkedSpec.pm` updates:
  - `_action_contract_deps` converted to thin delegate,
  - `_build_action_lowering_contracts` converted to thin delegate,
  - `_scan_contract_ir_events` converted to thin delegate.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-02 - Phase 1A Slice: Extract `get_parser` Orchestration to `LinkedSpec::ParserFactory`
## Summary
Moved `get_parser` orchestration ownership out of `LinkedSpec.pm` into a dedicated `LinkedSpec::ParserFactory` module, preserving the public API via a thin delegate in `LinkedSpec.pm`.

## Changed Files
- Added: `perl/LinkedSpec/ParserFactory.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ParserFactory::run_get_parser(...)` as the new owner of parser-factory orchestration:
  - trace option normalization/application,
  - trace-scope entry/exit wiring,
  - spec-name validation + path resolution + content loading integration,
  - `trace_reset_log` option filtering before compilation,
  - final compilation decision trace + parser return.
- Boundary design:
  - parser-factory module is dependency-injected for trace/resolver/compile callbacks and dump levels,
  - no direct hard-coded calls back into `LinkedSpec` implementation internals.
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::ParserFactory ();`
  - added `_parser_factory_deps` callback map
  - replaced in-file `get_parser(...)` orchestration body with a thin delegate.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Resolver.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-02 - Phase 1A Slice: Extract Method/Statement Lowering to `LinkedSpec::ActionIR::MethodLowering`
## Summary
Moved method-driven declaration/value/return/assign/regex lowering ownership out of `LinkedSpec.pm` into a dedicated `LinkedSpec::ActionIR::MethodLowering` module, preserving compatibility through thin delegates in `LinkedSpec.pm`.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ActionIR::MethodLowering` module owning:
  - `_declare_sigil_for_type`
  - `_declare_alias_to_type`
  - `_lower_typed_declare_statement`
  - `_normalize_method_tag_expr`
  - `_lower_method_value_expr`
  - `_lower_return_payload_expr`
  - `_lower_return_general_statement`
  - `_lower_return_imatch_statement`
  - `_lower_assign_statement`
  - `_lower_regex_subst_statement`
  - `_lower_return_undef_statement`
  - `_lower_return_array_statement`
- Boundary design:
  - module logic is callback-driven through explicit dependency injection and avoids hard-coded `LinkedSpec::...` calls.
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::ActionIR::MethodLowering ();`
  - added `_method_lowering_deps` callback map
  - replaced moved in-file method/statement-lowering implementations with thin delegates.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-03-01 - Phase 1A Slice: Extract Array Pipeline Lowering to `LinkedSpec::ActionIR::ArrayPipeline`
## Summary
Moved array pipeline planning/lowering ownership out of `LinkedSpec.pm` into `LinkedSpec::ActionIR::ArrayPipeline`, preserving public helper surfaces via thin delegates in `LinkedSpec.pm`.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ActionIR::ArrayPipeline` module owning:
  - `_normalize_split_delimiter_expr`
  - `_build_array_pipeline_plan_from_expr`
  - `_lower_array_pipeline_expr`
  - `_lower_split_statement`
  - `_lower_trim_each_statement`
  - `_lower_filter_nonempty_statement`
  - `_lower_lowercase_each_statement`
  - `_lower_uppercase_each_statement`
  - `_lower_uniq_statement`
  - `_lower_filter_match_statement`
- Boundary design:
  - module uses explicit dependency callbacks (`trim`, literal-strip, method parsing, scope-token detection, symbol extractors),
  - no hard-coded `LinkedSpec::...` calls inside array-pipeline module logic.
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::ActionIR::ArrayPipeline ();`
  - added `_array_pipeline_deps` helper map
  - replaced moved in-file implementations with thin delegates.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-28 - Phase 1A Slice: Extract Fluent Control-Flow Lowering to `LinkedSpec::ActionIR::ControlFlow`
## Summary
Moved fluent control-flow lowering ownership out of `LinkedSpec.pm` into `LinkedSpec::ActionIR::ControlFlow`, including if/elseif/else/endif and switch/case/default/endcase/endswitch lowering plus fluent `say(...)`/`print(...)` lowering.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/ControlFlow.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ActionIR::ControlFlow` module owning:
  - `_lower_control_flow_value_expr`
  - `_lower_switch_case_value_expr`
  - `_lower_if_flow_statement`
  - `_lower_elseif_flow_statement`
  - `_lower_else_flow_statement`
  - `_lower_endif_flow_statement`
  - `_lower_flow_branch_action_expr`
  - `_lower_inline_switch_branch_expr`
  - `_lower_switch_flow_statement`
  - `_lower_case_flow_statement`
  - `_lower_default_flow_statement`
  - `_lower_endcase_flow_statement`
  - `_lower_endswitch_flow_statement`
  - `_lower_say_statement`
  - `_lower_print_statement`
- Boundary design:
  - module uses explicit dependency callbacks for trim/tag normalization/composite expression lowering and method-expression parsing/scope normalization,
  - no hard-coded `LinkedSpec::...` back-calls inside module logic.
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::ActionIR::ControlFlow ();`
  - added `_control_flow_deps` helper map,
  - replaced moved function bodies with thin compatibility delegates.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-28 - Phase 1A Slice: Extract Flow Composite Expression Helpers to `LinkedSpec::ActionIR::FlowExpr`
## Summary
Moved flow-composite expression lowering ownership out of `LinkedSpec.pm` into a dedicated `LinkedSpec::ActionIR::FlowExpr` module, preserving existing call surfaces via thin delegates.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/FlowExpr.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ActionIR::FlowExpr` module owning:
  - `_lower_is_empty_expr`
  - `_lower_flow_composite_expr`
- Boundary design:
  - module uses explicit dependency callbacks (`trim`, symbol extractors, method-value lowering, method-expression parse/scope-normalization),
  - no hard-coded `LinkedSpec::...` calls inside flow-expression module logic.
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::ActionIR::FlowExpr ();`
  - added `_flow_expr_deps` dependency map helper,
  - replaced in-file bodies of `_lower_is_empty_expr` and `_lower_flow_composite_expr` with thin delegates.
- Behavioral parity:
  - composite condition lowering semantics (`and/or/not`, string/numeric compares, `matches`, `is_empty`, `is_nonempty`) unchanged.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-28 - Phase 1A Slice: Transfer Bootstrap Grammar Ownership to `LinkedSpec::BootstrapSpec`
## Summary
Moved hardcoded bootstrap grammar ownership out of `LinkedSpec.pm` into `LinkedSpec::BootstrapSpec`, including method-chain parsing/render helpers and descriptor construction logic. `LinkedSpec.pm` now initializes bootstrap parsing state through one builder call.

## Changed Files
- Updated: `perl/LinkedSpec/BootstrapSpec.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Expanded `LinkedSpec::BootstrapSpec` to own bootstrap grammar construction:
  - added `build_bootstrap_spec()` returning:
    - bootstrap descriptor (`$spec_descr`)
    - bootstrap rule index map ref
    - bootstrap gdata bundle
- Moved method-chain helper ownership from `LinkedSpec.pm` into `BootstrapSpec`:
  - `_parse_method_call_chain`
  - `_method_chain_return_uses_general_payload`
  - `_render_method_call_chain`
  - local trim helper for method-chain payloads
- Kept bootstrap registry/gdata build local to bootstrap module and reused by the new builder flow.
- Replaced large in-file bootstrap grammar block in `LinkedSpec.pm` with:
  - `my ($spec_descr, $bootstrap_rule_index_ref, $gdata) = LinkedSpec::BootstrapSpec::build_bootstrap_spec();`
  - local hash materialization for existing parser call sites.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-28 - Phase 1A Slice: Extract `Get` Pipeline Ownership to `LinkedSpec::Compiler`
## Summary
Moved the full `Get` compile/generate orchestration pipeline out of `LinkedSpec.pm` into `LinkedSpec::Compiler::run_get_pipeline(...)`, while keeping `LinkedSpec.pm::Get` as a thin façade that only manages parser-source emitter scoping and state handles.

## Changed Files
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::Compiler::run_get_pipeline($spec_content_ref, $option_hashref, $deps_hashref)` as the new owner of `Get` pipeline orchestration:
  - trace option application and pipeline scope tracing
  - validation flow (`validate_spec_content`, `validate_dsl_syntax`)
  - bootstrap parse execution and diagnostics
  - descriptor generation and gdata validation
  - parser-source emission and output routing
  - parse-only / generate-only / return-descr mode branching
  - final parser closure return
- Added dependency validation helper in compiler module:
  - `_require_dep($deps, $name)`
- `run_get_pipeline` uses explicit injected state handles for the few fields owned by `LinkedSpec.pm`:
  - `spec_descr`
  - `bootstrap_rule_index`
  - `gdata`
  - `emit_parser_source_line`
  - `top_rule_ref`
  - `parser_source_chunks_ref`
- Replaced monolithic `LinkedSpec.pm::Get` body with a thin delegate to compiler pipeline, preserving existing API and behavior.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-28 - Phase 1A Slice: Extract `spec_entry` to `LinkedSpec::SpecEntry`
## Summary
Moved full `spec_entry` rule-compilation ownership out of `LinkedSpec.pm` into a dedicated `LinkedSpec::SpecEntry` module, and replaced `LinkedSpec.pm::spec_entry` with a thin façade delegate.

## Changed Files
- Added: `perl/LinkedSpec/SpecEntry.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::SpecEntry::compile_spec_entry($einfo, $deps)` as the new owner of staged spec-entry compilation:
  - RuleIR collection/planning/validation and emit-context assembly
  - handler preamble generation
  - deterministic handler-variant assembly and selection
  - runtime handler closure construction with trace enter/exit/eval decision events
  - parser-source emission through explicit dependency callback (`emit_parser_source_line`)
- Split the extracted logic into clear sub-responsibility helpers inside `SpecEntry.pm`:
  - handler preamble and dispatch block builders
  - per-variant handler template builders (`AND_*`, `OR_*`, `REP_*`, default)
  - variant selection and runtime-handler construction
- Moved repetition min/max map ownership (`REP_PLUS`, `REP_STAR`, `REP_OPT`) from `LinkedSpec.pm` into `LinkedSpec::SpecEntry`.
- Replaced large in-file `LinkedSpec.pm::spec_entry` body with a thin delegate that:
  - calls `LinkedSpec::SpecEntry::compile_spec_entry(...)`
  - updates local `$top_rule` from returned top-rule candidate
  - preserves existing return shape `($label, $rule_info_hashref)`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-28 - Phase 1A Slice: Decompose Action-Lowering Contracts into Responsibility-Specific Builders
## Summary
Replaced the monolithic `_build_action_lowering_contracts` implementation (previously ~660 lines in `LinkedSpec.pm`) with a delegated contracts module that is split into clear, responsibility-oriented builder functions.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/Contracts.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `LinkedSpec::ActionIR::Contracts` with explicit separation of responsibilities:
  - `_build_call_and_dispatch_contracts`
  - `_build_return_contracts`
  - `_build_capture_and_backtrack_contracts`
  - `_build_passthrough_ir_contracts`
  - `_build_assignment_and_regex_contracts`
  - `_build_array_pipeline_contracts`
  - `_build_flow_control_contracts`
  - `_build_emit_and_declare_contracts`
  - orchestrated by `build_action_lowering_contracts`.
- Replaced `LinkedSpec.pm::_build_action_lowering_contracts` with a thin delegate to `LinkedSpec::ActionIR::Contracts::build_action_lowering_contracts`.
- Added `LinkedSpec.pm::_action_contract_deps` to pass explicit lowering callbacks into the contracts module.
- Boundary quality:
  - Contracts module does not hard-call `LinkedSpec::...` symbols.
  - All lowering hooks are explicit dependencies injected by `LinkedSpec.pm`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-28 - Phase 1A Slice: Extract Value/Scalaref Helpers to `LinkedSpec::ActionIR::ValueExpr`
## Summary
Executed another `LinkedSpec.pm` decomposition slice by extracting the value/scalaref helper cluster into `LinkedSpec::ActionIR::ValueExpr` and wiring `LinkedSpec.pm` delegates to pass explicit dependency callbacks rather than hard-calling back into `LinkedSpec` from the module.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/ValueExpr.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added module `LinkedSpec::ActionIR::ValueExpr` with extracted helpers:
  - `_extract_scalar_symbol_name`
  - `_extract_array_symbol_name`
  - `_extract_hash_symbol_name`
  - `_lower_scalar_access_key_expr`
  - `_split_scalaref_path_segments`
  - `_lower_scalaref_segment_expr`
  - `_lower_scalaref_value_expr`
  - `_infer_scalar_container_kind`
  - `_lower_assignment_source_expr`
  - `_strip_literal_delimiters`
- Replaced local implementations in `LinkedSpec.pm` with thin delegates to `ActionIR::ValueExpr`.
- Boundary/coupling correction:
  - `ActionIR::ValueExpr` no longer hard-calls `LinkedSpec::...` helpers internally.
  - Instead, each call receives explicit dependency callbacks (`trim_action_ir_value`, `lower_flow_composite_expr`, `lower_method_value_expr`) from `LinkedSpec.pm`.
  - This keeps module ownership explicit while avoiding the prior callback-indirection anti-pattern.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ValueExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-28 - Phase 1A Slice: Extract Method-Expression Parsing Helpers to `LinkedSpec::ActionIR::MethodExpr`
## Summary
Extracted method-expression parsing primitives from `LinkedSpec.pm` into a dedicated `LinkedSpec::ActionIR::MethodExpr` module and rewired both `LinkedSpec.pm` and `LinkedSpec::ActionRewriter` to consume that module directly.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/MethodExpr.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added new module:
  - `LinkedSpec::ActionIR::MethodExpr`
  - extracted helpers:
    - `_split_top_level_csv`
    - `_parse_method_function_expr`
    - `_is_bare_method_scope_token`
    - `_normalize_method_args_with_optional_scope`
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::ActionIR::MethodExpr ();`
  - replaced in-file helper bodies above with compatibility delegates to the new module.
- Updated `LinkedSpec::ActionRewriter`:
  - switched declare/assign helper parsing call sites to use `LinkedSpec::ActionIR::MethodExpr` directly,
  - updated scanner callback wiring to pass parser/scope-normalization callbacks from `MethodExpr` rather than `LinkedSpec` wrapper functions.
- Behavioral parity note:
  - this slice is a boundary extraction and call-path cleanup only; parser/lowering semantics remain unchanged.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-27 - Phase 1A Slice: Extract Contract IR Scanner to `LinkedSpec::ActionIR::Scanner`
## Summary
Extracted `_scan_contract_ir_events` out of `LinkedSpec.pm` into a new dedicated scanner module and rewired both `LinkedSpec.pm` and `LinkedSpec::ActionRewriter` to use it through explicit helper-callback dependencies.

## Changed Files
- Added: `perl/LinkedSpec/ActionIR/Scanner.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added new module:
  - `LinkedSpec::ActionIR::Scanner`
  - public entrypoint: `scan_contract_ir_events($contract, $code, $deps)`
- Moved full contract scanner implementation from `LinkedSpec.pm` into the new module with no logic changes to pattern matching or event payload construction.
- Introduced explicit dependency callbacks (`split/trim/parse/normalize/pipeline/declare` helpers) so scanner logic is reusable without direct hard-calls back into `LinkedSpec.pm`.
- Updated call paths:
  - `LinkedSpec.pm::_scan_contract_ir_events(...)` now delegates to `LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(...)`.
  - `LinkedSpec::ActionRewriter::_collect_action_helper_ir_nodes(...)` now invokes scanner module directly instead of calling back through `LinkedSpec::_scan_contract_ir_events(...)`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-27 - Phase 1A Slice: Extract Canonical IR/Statement Split Helpers to `LinkedSpec::ActionRewriter`
## Summary
Completed the in-progress ActionRewriter modularization by moving canonical helper-event normalization and robust action-statement splitting internals from `LinkedSpec.pm` to `LinkedSpec::ActionRewriter`, with delegating wrappers preserved in `LinkedSpec.pm`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added helper implementations to `LinkedSpec::ActionRewriter`:
  - `_canonicalize_helper_action_ir_event`
  - `_split_action_ir_statements`
- Updated ActionRewriter internal call paths to use local helpers:
  - `_find_unresolved_action_helpers` now calls local `_split_action_ir_statements`
  - `_build_canonical_action_ir_events` now calls local `_trim_action_ir_value`, `_canonicalize_helper_action_ir_event`, and `_split_action_ir_statements`
- Updated `LinkedSpec.pm` compatibility surfaces:
  - `_canonicalize_helper_action_ir_event(...)` delegates to `LinkedSpec::ActionRewriter`
  - `_split_action_ir_statements(...)` delegates to `LinkedSpec::ActionRewriter`
- Behavioral parity note:
  - action rewrite and canonical IR generation behavior remains unchanged; this slice relocates helper ownership only.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-27 - Phase 1A Slice: Extract Declare/Assign Method Lowering Helpers to `LinkedSpec::ActionRewriter`
## Summary
Executed the next incremental modularization slice by moving declaration/assignment helper parsing and lowering internals from `LinkedSpec.pm` to `LinkedSpec::ActionRewriter`, while preserving call surfaces through delegating wrappers.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added helper implementations to `LinkedSpec::ActionRewriter`:
  - `_trim_action_ir_value`
  - `_split_declare_symbol_names`
  - `_parse_declare_binding_entry`
  - `_lower_declare_value_expr`
  - `_lower_declare_initializer_expr`
  - `_extract_declare_statement_from_method_expr`
  - `_lower_declare_method_statement`
  - `_lower_assign_method_statement`
- Updated `LinkedSpec.pm` to delegate the same helper names to `LinkedSpec::ActionRewriter` for compatibility with existing call sites and regex-lowering contract execution paths.
- Behavioral parity note:
  - extraction keeps helper signatures and return semantics unchanged;
  - contract-driven rewrites still resolve through `LinkedSpec` entrypoints, now delegating into `ActionRewriter` for this helper cluster.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-27 - Phase 1A Slice: Extract `spec_descr`/`spec_gdata` to `LinkedSpec::Compiler` and Replace `pm_drive`
## Summary
Completed the active Phase 1A compiler follow-up slice by moving spec descriptor/gdata build logic into `LinkedSpec::Compiler`, delegating compatibility wrappers from `LinkedSpec.pm`, and replacing the legacy `pm_drive` generation toggle with an explicit parser-source emission option.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `USER_GUIDE.md`
- Deleted: `specs/test.pl`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- `LinkedSpec::Compiler` now owns:
  - `spec_descr`
  - `spec_gdata`
- `LinkedSpec.pm` keeps stable helper call surfaces via wrappers:
  - `spec_descr(...) -> LinkedSpec::Compiler::spec_descr(...)`
  - `spec_gdata(...) -> LinkedSpec::Compiler::spec_gdata(...)`
- Removed all `pm_drive` references from project sources and docs.
- Added explicit parser-source dump flow in `Get(...)`:
  - `dump_parser_source => 1` enables source emission,
  - `parser_source_ref => \$scalar` captures emitted source without stdout printing.
- Introduced internal emitter hook (`_emit_parser_source_line`) so generated handler source fragments are accumulated centrally during build and emitted once at the end of generation.
- Removed legacy sample script `specs/test.pl` from version control per user request.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Trace.pm`
  - `perl -Iperl -c perl/LinkedSpec/Validation.pm`
  - `perl -Iperl -c perl/LinkedSpec/Resolver.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec.pm`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-27 - Phase 1A Slice: Extract Bootstrap Registry Helpers to `LinkedSpec/BootstrapSpec.pm`
## Summary
Executed the next Phase 1A modularization slice by extracting bootstrap registry/scanner-bundle construction from `LinkedSpec.pm` into `LinkedSpec::BootstrapSpec`, while preserving bootstrap parsing behavior.

## Changed Files
- Added: `perl/LinkedSpec/BootstrapSpec.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added new module `LinkedSpec::BootstrapSpec` with helper:
  - `_build_bootstrap_registry_gdata`
- Helper responsibilities moved from `LinkedSpec.pm`:
  - build `%bootstrap_rule_index` from bootstrap descriptor IDs,
  - enforce required bootstrap rule IDs (`SPEC_ROOT`, `CURLY_BRACE`),
  - derive bootstrap start-token scanner arrays and dispatch mapping,
  - derive curly-brace scanner bundle,
  - build bootstrap `gdata` (`startREs`, `start_dispatch`, `cbrace`).
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::BootstrapSpec ();`
  - replaced inlined bootstrap registry/gdata initialization block with:
    - `LinkedSpec::BootstrapSpec::_build_bootstrap_registry_gdata($spec_descr)`
    - assignment of returned rule-index hashref into existing `%bootstrap_rule_index`.
- Behavioral parity note:
  - bootstrap descriptor handlers and call sites are unchanged; extraction is limited to registry/scanner setup logic.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec/Trace.pm`
  - `perl -c perl/LinkedSpec/Validation.pm`
  - `perl -c perl/LinkedSpec/Resolver.pm`
  - `perl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c perl/LinkedSpec/BootstrapSpec.pm`
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-27 - Phase 1A Slice: Extract Compiler Runtime Helpers to `LinkedSpec/Compiler.pm`
## Summary
Executed the next Phase 1A modularization slice by extracting selected compile-orchestration helpers from `LinkedSpec.pm` into `LinkedSpec::Compiler`, while preserving `Get(...)` behavior through incremental delegation.

## Changed Files
- Added: `perl/LinkedSpec/Compiler.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added new module `LinkedSpec::Compiler` with extracted helpers:
  - `_run_bootstrap_parse`
  - `_build_action_rewriter_migration_summary`
  - `_build_final_descr`
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::Compiler ();`
  - delegated `_build_action_rewriter_migration_summary(...)` to `LinkedSpec::Compiler`.
  - updated `Get(...)` to delegate:
    - bootstrap parser eval invocation via `_run_bootstrap_parse(...)`,
    - final descriptor/meta assembly via `_build_final_descr(...)`.
- Behavioral parity note:
  - diagnostics/logging text and stage decisions in `Get(...)` remain unchanged; only helper execution location moved.
- Added local `@INC` bootstrap in `LinkedSpec::Compiler` for direct module syntax-check workflows.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec/Trace.pm`
  - `perl -c perl/LinkedSpec/Validation.pm`
  - `perl -c perl/LinkedSpec/Resolver.pm`
  - `perl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-27 - Phase 1A Slice: Extract ActionRewriter Runtime to `LinkedSpec/ActionRewriter.pm`
## Summary
Executed the next Phase 1A modularization slice by extracting action-rewrite pipeline orchestration and diagnostics helpers from `LinkedSpec.pm` into `LinkedSpec::ActionRewriter`, while preserving existing call surfaces through compatibility delegates.

## Changed Files
- Added: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added new module `LinkedSpec::ActionRewriter` containing extracted helpers:
  - `_find_unresolved_action_helpers`
  - `_collect_action_helper_ir_nodes`
  - `_build_canonical_action_ir_events`
  - `_lower_action_code_from_canonical_ir`
  - `_accumulate_action_rewrite_diagnostics`
  - `_rewrite_action_code_with_diagnostics`
  - `_build_action_rewrite_rules`
  - `call_spec_handler_subst`
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::ActionRewriter ();`
  - delegated the helper names above to `LinkedSpec::ActionRewriter` to preserve compatibility and existing call sites.
- Behavioral parity approach:
  - `LinkedSpec::ActionRewriter` invokes remaining helper scanners/normalizers/contract builders via fully-qualified `LinkedSpec::...` calls, keeping the extraction incremental and no-behavior-change.
- Added local `@INC` bootstrap in `LinkedSpec::ActionRewriter` for direct module syntax-check workflows.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec/Trace.pm`
  - `perl -c perl/LinkedSpec/Validation.pm`
  - `perl -c perl/LinkedSpec/Resolver.pm`
  - `perl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-27 - Phase 1A Slice: Extract RuleIR Runtime to `LinkedSpec/RuleIR.pm`
## Summary
Executed the next Phase 1A modularization slice by extracting RuleIR collection/planning/validation/emit-context helpers from `LinkedSpec.pm` into a dedicated `LinkedSpec::RuleIR` module, while preserving `spec_entry(...)` behavior through façade delegation.

## Changed Files
- Added: `perl/LinkedSpec/RuleIR.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added new module `LinkedSpec::RuleIR` containing extracted RuleIR helpers:
  - `_select_rule_handler_variant`
  - `_build_rule_execution_meta`
  - `_collect_rule_ir`
  - `_plan_rule_ir_meta`
  - `_validate_rule_ir_or_exit`
  - `_normalize_rule_code_chunks`
  - `_build_rule_ir_emit_context`
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::RuleIR ();`
  - delegated the same helper names above to `LinkedSpec::RuleIR` for compatibility and minimal call-site churn.
- Preserved runtime behavior:
  - `spec_entry(...)` continues to orchestrate the same staged RuleIR pipeline,
  - existing action-rewriter diagnostics/meta assembly paths remain unchanged, with `LinkedSpec::RuleIR` invoking existing rewrite helpers through fully-qualified calls.
- Added local `@INC` bootstrap in `LinkedSpec::RuleIR` for direct module syntax-check workflows.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec/Trace.pm`
  - `perl -c perl/LinkedSpec/Validation.pm`
  - `perl -c perl/LinkedSpec/Resolver.pm`
  - `perl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-27 - Phase 1A Slice: Extract Resolver Runtime to `LinkedSpec/Resolver.pm`
## Summary
Executed the third Phase 1A modularization slice by extracting spec-name validation, spec-path resolution, and spec-source loading behavior from `LinkedSpec.pm` into a dedicated `LinkedSpec::Resolver` module, while preserving `get_parser(...)` behavior and diagnostics through façade delegation.

## Changed Files
- Added: `perl/LinkedSpec/Resolver.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added new module `LinkedSpec::Resolver` containing resolver helpers:
  - `validate_spec_name`
  - `_resolve_local_spec_path`
  - `resolve_spec_path`
  - `load_spec_content`
- Updated `LinkedSpec.pm`:
  - added `use LinkedSpec::Resolver ();`
  - delegated `_resolve_local_spec_path` to `LinkedSpec::Resolver::_resolve_local_spec_path(...)`
  - simplified `get_parser(...)` orchestration to call resolver helpers for:
    - spec-name validation error path handling,
    - explicit/local/fallback spec path resolution behavior,
    - spec file open/read path handling.
- Preserved diagnostic and trace surfaces used by regression locks:
  - error message text remains unchanged for invalid-name, missing-path, non-file path, pathsearch load/runtime failure, and open failure cases.
- Added local `@INC` bootstrap in `LinkedSpec::Resolver` for direct `perl -c` workflow support.
- Corrected module-path lookup in `_resolve_local_spec_path` by deriving an `@INC` key from package name (`LinkedSpec/Resolver.pm`) instead of raw `__PACKAGE__.'.pm'`, restoring module-relative specs lookup behavior.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec/Trace.pm`
  - `perl -c perl/LinkedSpec/Validation.pm`
  - `perl -c perl/LinkedSpec/Resolver.pm`
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-27 - Phase 1A Slice: Extract Validation Runtime to `LinkedSpec/Validation.pm`
## Summary
Executed the second Phase 1A modularization slice by extracting DSL/spec validation helpers from `LinkedSpec.pm` into a dedicated `LinkedSpec::Validation` module, while preserving external validation API compatibility via delegating wrappers.

## Changed Files
- Added: `perl/LinkedSpec/Validation.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added new module `LinkedSpec::Validation` containing extracted validation helpers:
  - `get_dsl_context`
  - `report_dsl_error`
  - `validate_spec_content`
  - `validate_rule_definition`
  - `validate_gdata_references`
  - `validate_dsl_syntax`
  - `extract_regex_literals_from_rule_rhs`
- Updated `LinkedSpec.pm` to load `LinkedSpec::Validation` and delegate the same public validation function names to the new module, preserving call-site behavior and compatibility.
- Added local `@INC` bootstrap in `LinkedSpec::Validation` so direct module syntax checks (`perl -c perl/LinkedSpec/Validation.pm`) resolve sibling `LinkedSpec::*` modules without requiring external `-I` flags.
- Validation logging behavior remains routed through `LinkedSpec::Trace::log_output`, preserving tracing/runtime formatting and routing semantics introduced in the prior Trace extraction slice.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec/Trace.pm`
  - `perl -c perl/LinkedSpec/Validation.pm`
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-27 - Phase 1A Slice: Extract Tracing Runtime to `LinkedSpec/Trace.pm`
## Summary
Executed the first Phase 1A modularization slice by extracting tracing runtime internals from `LinkedSpec.pm` into a dedicated `LinkedSpec::Trace` module, while preserving existing trace API behavior and regression stability.

## Changed Files
- Added: `perl/LinkedSpec/Trace.pm`
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added new module `LinkedSpec::Trace` containing:
  - trace state globals (`DUMP_VERBOSITY`, sink/style state),
  - trace level parsing/mapping helpers,
  - trace emit/routing internals,
  - runtime configuration entrypoint (`configure_trace`),
  - trace scope helpers (`trace_enter`, `trace_exit`, `trace_decision`),
  - public logging helpers (`log_output`, `log_dump`, `should_dump`).
- Updated `LinkedSpec.pm` to delegate trace APIs to `LinkedSpec::Trace`:
  - `_trace_level_name`, `_apply_trace_options`, `configure_trace`,
  - `trace_enter`, `trace_exit`, `trace_decision`,
  - `log_output`, `log_dump`, `should_dump`.
- Preserved compatibility for existing global trace variable surfaces in `LinkedSpec.pm` by aliasing to `LinkedSpec::Trace` package globals.
- Added local `@INC` bootstrap in `LinkedSpec.pm` so sibling module loading works reliably for direct `perl -c perl/LinkedSpec.pm` workflows without requiring external `-I` flags.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec/Trace.pm`
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-27 - First-Class Tracing Framework + Modularization Roadmap Track
## Summary
Implemented a first-class multi-level tracing framework in `LinkedSpec.pm` (UVM-style verbosity, structured scope/decision events, metadata-rich formatting, and trace-file routing), added focused regression locks for trace metadata/routing behavior, and updated roadmap tracking with a new phased modularization track for splitting `LinkedSpec.pm` into submodules.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `USER_GUIDE.md`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added centralized trace runtime in `LinkedSpec.pm`:
  - multi-level trace/verbosity parsing (`none|low|medium|high|debug`, with compatibility for numeric/internal levels),
  - runtime trace configuration API: `configure_trace(...)`,
  - environment knobs: `LINKEDSPEC_TRACE_LEVEL`, `LINKEDSPEC_TRACE_FILE`, `LINKEDSPEC_TRACE_MIRROR_STDOUT`, `LINKEDSPEC_TRACE_RESET_FILE`, `LINKEDSPEC_TRACE_EMOJI`,
  - structured trace helpers: `trace_enter`, `trace_exit`, `trace_decision`,
  - metadata formatting includes timestamp, level, file, function, and line, with indentation and optional emoji styling,
  - output sink modes: `stdout`, `route`, `mirror`.
- Added targeted trace instrumentation in key compile/runtime paths:
  - `Get`, `get_parser`, `spec_descr`, `spec_entry`, `spec_gdata`, `_validate_rule_ir_or_exit`,
  - runtime rule handler wrapper now emits entry/exit + eval decision traces.
- Added trace routing behavior for `trace.log` use cases:
  - explicit `trace_log_file` defaults to route-style behavior unless `trace_log_mode` is set,
  - preserved compatibility with existing `$main::LOG_FILE` mirroring behavior.
- Updated docs in `USER_GUIDE.md` with tracing levels, APIs/options, env vars, and `trace.log` routing semantics.
- Added focused phase0 regression locks:
  - `trace_output_includes_metadata_and_decisions`
  - `trace_log_file_route_redirects_stdout_to_trace_log`
- Updated `ROADMAP.md`:
  - added `Phase 1A: LinkedSpec.pm Modularization (New Priority)`,
  - defined target module boundaries (`Trace`, `Validation`, `Resolver`, `RuleIR`, `ActionRewriter`, `Compiler`, `BootstrapSpec`),
  - recorded phased extraction order (Trace -> Validation -> Resolver first) and status/next-step tracking.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=84`)
## 2026-02-27 - Add `COMMIT.md` Workflow Guide
## Summary
Added a git-tracked workflow document describing the repository commit process so new AI sessions can reliably follow the same commit procedure and file responsibilities.

## Changed Files
- Added: `COMMIT.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `COMMIT.md` at repo root with:
  - commit workflow objective and cadence,
  - exact file roles and lifecycle (`git_message_brief.txt`, `CHANGES.md`, `DEVELOPMENT_NOTES.md`, task files),
  - pre-commit validation expectations,
  - step-by-step execution sequence,
  - guardrails for scope, documentation consistency, and cleanup behavior.

## Validation
- Ran:
  - `git --no-pager status --short`
- Result:
  - `COMMIT.md` tracked in git index and ready for commit.
## 2026-02-27 - Blocker Reduction Slice: Tuple Destructure + Foreach Print + Split/Trim/Filter Assignment
## Summary
Reduced remaining high-priority language-agnostic action-IR blockers by adding identity-preserving canonical classification coverage for three frequent raw statement forms while preserving runtime behavior.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added canonical action-IR contract coverage (classification-only, no rewrite behavior change) for:
  - `destructure_imatch_list_my`:
    - `my ($a, $b, ...) = @IMATCH_LIST`
  - `print_foreach_iterable`:
    - `print "...$_..." foreach (@iterable)`
  - `split_trim_filter_assignment`:
    - `my @parts = grep { length($_) } map { my $v = $_; $v =~ s/.../.../g; $v } split /.../, $args`
- Extended canonical kind mapping for the new contracts:
  - tuple destructure and split/trim/filter assignment map to canonical `ASSIGN`,
  - foreach-print maps to canonical `PRINT`.
- Added focused phase0 regression locks:
  - `action_rewriter_canonical_action_ir_classifies_imatch_list_destructure_without_raw_fallback`
  - `action_rewriter_canonical_action_ir_classifies_print_foreach_iterable_without_raw_fallback`
  - `action_rewriter_canonical_action_ir_classifies_split_trim_filter_assignment_without_raw_fallback`
- Blocker triage impact:
  - highest blocker frequency reduced from `2` to `1` across in-scope specs (excluding deferred `tclite.spec`).

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=82`)
## 2026-02-26 - Declare Initializers (`name=expr`) + Assign Expression Sources
## Summary
Extended declaration and assignment helper contracts so declaration entries can be initialized inline and assign sources can use the same expression surfaces as fluent control-flow conditions.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- `declare(...)` and aliases now support per-entry initialization using `name=expr`:
  - supported for `declare(type, ...)` where `type` is `array|scalar|hash`,
  - supported for aliases `declare_a/s/h` and `declare_array/scalar/hash`,
  - optional leading scope token remains supported.
- Added declaration initializer lowering helpers:
  - `_parse_declare_binding_entry(...)`
  - `_lower_declare_value_expr(...)`
  - `_lower_declare_initializer_expr(...)`
  - `_extract_declare_statement_from_method_expr(...)`
  - `_lower_declare_method_statement(...)`
- `assign(target, source)` now accepts expression sources (not only CAPTURE/IMATCH/LMATCH):
  - source lowering routes through the same flow/value expression surfaces used by `if()/elseif()/switch()`,
  - helper lowering/scanning now parses full `assign(...)` expressions with optional scope token.
- Regression updates:
  - extended `action_rewriter_lowers_typed_declare_methods_and_aliases` with scalar/array/hash initializer cases,
  - extended `action_rewriter_lowers_method_contracts_for_capture_and_structured_return_values` with expression-source assign case.
- Updated helper reference documentation in `USER_GUIDE.md` for declare initializers and assign expression sources.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=79`)
## 2026-02-26 - `scalaref(base,path)` Generalized Ref-Path Lowering
## Summary
Implemented generalized `scalaref(...)` helper lowering for mixed dereference paths (array/hash segments), so ref-path value access can be expressed in language-neutral helper form instead of raw Perl dereference chains.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added `scalaref(base_ref, path)` value lowering support:
  - supports mixed path segments such as `[A][B]{C}[D]` and `{A}[B]{C}[D]`,
  - lowers into canonical Perl dereference chains with explicit segment traversal,
  - supports nested/helper-based segment expressions while preserving bare token path atoms.
- Extended value/payload lowering paths so `scalaref(...)` is recognized in:
  - control-flow/value expression lowering,
  - generalized `return(payload)` lowering and helper replacement passes.
- Added focused regression checks under `action_rewriter_lowers_general_return_payloads_with_nested_structures` for:
  - `return(scalaref(myref, [A][B]{C}[D]))`,
  - `return({ item => scalaref(myref, {A}[B]{C}[D]) })`.
- Updated user guide helper reference and payload examples to document `scalaref(...)` usage and chain payload recognition.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=79`)
## 2026-02-26 - Language-Agnostic Blocker Reduction Slice + `return(payload)` Guide Expansion
## Summary
Reduced high-frequency language-agnostic migration blockers by adding identity-preserving canonical action-IR classification for common raw statements, and expanded `return(payload)` user-guide coverage with concrete payload categories and examples.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`

## Technical Details
- Added canonical action-IR classifier coverage (without behavior rewrites) for frequent raw statement forms:
  - `return_bare` (canonical `RETURN`)
  - `exit_bare` (canonical `EXIT`)
  - `linecount_prefix_newline_matches` (canonical `LINE_COUNT`)
  - `print_capture_substr` (canonical `PRINT`)
  - `my_declare_bare` (canonical `DECLARE`)
  - `position_tracking` cluster (canonical `POSITION_TRACK`)
  - `assign_match_my` (canonical `ASSIGN`)
  - `regex_subst_assignment` (canonical `REGEX_SUBST`)
  - `next_bare` (canonical `NEXT`)
  - `ref_field_assign` (canonical `ASSIGN` for `->{...}` / `->[...]` path reads)
- Added focused phase0 regression locks for each classifier slice to ensure no RAW_PERL fallback for covered forms and deterministic canonical-node emission.
- Expanded `USER_GUIDE.md` with exhaustive `return(payload)` usage guidance, payload typing notes, and examples aligned with canonical action lowering surfaces.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=79`)
## 2026-02-25 - Backbone Item #3 Follow-up: Unified Lisp-Style Control-Flow Expressions + Inline Composite `switch(...)` Branches
## Summary
Extended fluent control-flow lowering to use a unified Lisp-style expression path for `if`/`elseif`/`switch` conditions, added scalar accessor support for collection entry reads (`scalar(container, key_or_index)`), and added inline composite switch-branch lowering so `switch(condition, case(...), default(...))` can be expressed directly inside `switch(...)` arguments.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `ROADMAP.md`
- Updated: `MEMORY.md`

## Technical Details
- Added unified recursive control-flow expression lowering for fluent conditions:
  - boolean composition: `or(...)`, `and(...)`, `not(...)`
  - emptiness predicates: `is_empty(...)`, `is_nonempty(...)`
  - comparisons: `eq/ne/gt/ge/lt/le` and numeric `num_eq/num_ne/num_gt/num_ge/num_lt/num_le`
  - regex predicate: `matches(...)`
- Extended scalar value lowering:
  - `scalar(name)` for scalar variables
  - `scalar(container, key_or_index)` for collection entry reads
  - explicit forms `scalar(array(foo), idx)` and `scalar(hash(bar), key)` supported
  - compatibility form `scalar(IMATCH_LIST, n)` preserved
- Added inline composite switch branch lowering:
  - supports `switch(cond, case(v1, action1, ...), case(v2, ...), default(actionN, ...))`
  - each inline branch action reuses existing helper-lowering contracts
  - legacy marker flow (`switch(); case(); default(); endswitch()`) remains supported
- Added/extended regression coverage in `t/phase0_regression.t`:
  - extended `action_rewriter_lowers_fluent_if_else_and_branch_statements` with nested Lisp-style conditions and `scalar(array/hash, key)` access assertions
  - extended `action_rewriter_lowers_fluent_switch_case_default_with_optional_endcase` with inline composite switch(case/default) lowering assertions and descriptor-level readiness checks
- Expanded user documentation in `USER_GUIDE.md`:
  - added a complete method/helper reference section covering control-flow markers, condition helpers, scalar/collection access forms, branch actions, return helpers, declarations/transforms, and method-chain usage forms.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=68`)
## 2026-02-25 - Backbone Item #3 Follow-up: Fluent Control-Flow DSL + pipe_operator If/Else Showcase
## Summary
Extended method-like DSL lowering to support fluent control-flow markers and branch statements without `{...}` code blocks, including `if`/`i`, `elseif`/`elif`, `else`, `endif`, `switch`, `case`, `default`, `endswitch`, optional `endcase`, and branch statements (`say`, `print`, `return_undef`). Added a `pipe_operator` showcase example and dedicated regression lock for fluent if/else method chaining.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `ROADMAP.md`
- Updated: `MEMORY.md`

## Technical Details
- Added fluent control-flow lowering helpers and contracts for:
  - `if_flow`/`elseif_flow`/`else_flow`/`endif_flow`
  - `switch_flow`/`case_flow`/`default_flow`/`endcase_flow`/`endswitch_flow`
  - branch statements `say_stmt`, `print_stmt`, `return_undef`
- Added scope-aware argument normalization/lowering support for control-flow and switch/case value expressions.
- Added `push_scope_target_arg` contract handling so scope-injected method-chain forms (for example `push(Top, pipe_operator, rule)`) lower through canonical IR without RAW fallback.
- Updated canonical helper-event mapping and scanner coverage so fluent control-flow and branch events emit canonical action-IR forms deterministically.
- Fixed contextual lowering bug in `_lower_action_code_from_canonical_ir(...)` by removing stale non-contextual duplicate apply-path usage; canonical lowering now uses the context-aware apply path only.
- Added regression coverage in `t/phase0_regression.t`:
  - `action_rewriter_lowers_fluent_if_else_and_branch_statements`
  - `action_rewriter_lowers_fluent_switch_case_default_with_optional_endcase`
  - `action_rewriter_showcase_pipe_operator_if_else_method_chain`
- Added user-facing example section in `USER_GUIDE.md`:
  - `Fluent Control-Flow Example (pipe_operator with if/else)`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=68`)
## 2026-02-25 - Backbone Item #3 Follow-up: Composable Array Method DSL + Codegen Inspection Utility
## Summary
Extended method-like DSL lowering with composable array-string routines (`split`, `trim_each`, `filter_nonempty`, `lowercase_each`, `uppercase_each`, `uniq`, `filter_match`) including nested functional composition and dot-chain scope-injected forms, and added a utility to inspect generated Perl for `.spec` snippets.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Added: `tools/inspect_spec_codegen.pl`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `MEMORY.md`

## Technical Details
- Added composable array contracts in `_build_action_lowering_contracts(...)`:
  - `split_array` (`split(...)`)
  - `trim_each`
  - `filter_nonempty`
  - `lowercase_each`
  - `uppercase_each`
  - `uniq_array` (`uniq(...)`)
  - `filter_match`
- Added/extended lowering helpers in `LinkedSpec.pm`:
  - `_extract_array_symbol_name(...)`
  - `_normalize_split_delimiter_expr(...)`
  - `_parse_method_function_expr(...)`
  - `_is_bare_method_scope_token(...)`
  - `_build_array_pipeline_plan_from_expr(...)`
  - `_lower_array_pipeline_expr(...)`
  - wrapper helpers (`_lower_split_statement`, `_lower_trim_each_statement`, `_lower_filter_nonempty_statement`, `_lower_lowercase_each_statement`, `_lower_uppercase_each_statement`, `_lower_uniq_statement`, `_lower_filter_match_statement`) now route through the shared pipeline lowerer.
- Composability behavior:
  - Dot-chained forms continue to work (`I.lowercase_each(...).filter_match(...)`).
  - Nested functional forms are now lowered (`filter_match(uniq(uppercase_each(array(parts))), /.../)`).
  - Mixed style (dot-chain + nested functional call) is supported.
  - Scope-injected helper calls generated by method-chain rendering (`method(Top, ...)`) are recognized by the functional pipeline parser.
  - Nested functional composition lowers to single-assignment style for the nested expression path.
- Added inspection utility:
  - `tools/inspect_spec_codegen.pl`
  - accepts snippet/edge/lifecycle forms and prints:
    - normalized helper code,
    - generated Perl,
    - canonical IR nodes,
    - RAW_PERL fallback and unresolved-helper counts.
- Added/updated focused regression locks in `t/phase0_regression.t`:
  - `action_rewriter_lowers_composable_array_string_method_contracts`
  - `action_rewriter_lowers_additional_composable_array_string_routines`
  - includes nested composition and mixed-style coverage.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `perl -c tools/inspect_spec_codegen.pl`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=65`)
## 2026-02-24 - Backbone Item #3 Follow-up: Method Contracts for Capture and Structured Return Patterns
## Summary
Added another method-like DSL migration slice (guided by `ebnf.spec` usage) to lower additional non-block helper forms through canonical action-IR: tagged IMATCH return, capture/source assignment, regex substitution, and structured return-array payload constructors.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added method-value and lowering helpers:
  - `_normalize_method_tag_expr(...)`
  - `_extract_scalar_symbol_name(...)`
  - `_lower_assignment_source_expr(...)`
  - `_strip_literal_delimiters(...)`
  - `_split_top_level_csv(...)`
  - `_lower_method_value_expr(...)`
  - `_lower_return_imatch_statement(...)`
  - `_lower_assign_statement(...)`
  - `_lower_regex_subst_statement(...)`
  - `_lower_return_array_statement(...)`
- Added lowering contracts and scanner support for:
  - `return_imatch` (including `return_im` alias),
  - `assign(...)` with `CAPTURE|IMATCH|LMATCH` sources (`assign_value` contract),
  - `substr(...)` / `regex_subst(...)` method forms (`regex_subst` contract),
  - `return_array(...)` with nested constructor payloads such as `array(scalar(...), scalar(...))`.
- Extended canonical event mapping:
  - `_canonicalize_helper_action_ir_event(...)` now maps these new contracts into canonical `RETURN`, `ASSIGN`, and `REGEX_SUBST` kinds.
- Added focused regression lock:
  - `action_rewriter_lowers_method_contracts_for_capture_and_structured_return_values`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=63`)
## 2026-02-24 - Backbone Item #3 Follow-up: Typed Declare Methods + Chained Method-Like Blocks
## Summary
Added first method-like DSL migration slice for canonical typed declarations and chained method parsing, enabling `declare(type, ...)` lowering (with aliases) and multi-method chain handling without RAW_PERL fallback.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added method-chain parsing/render helpers:
  - `_parse_method_call_chain(...)`
  - `_render_method_call_chain(...)`
- Extended bootstrap method-like handlers to accept chained method forms:
  - `METHOD_EMPTY_ACTION_CODE_BLOCK` now parses/render chains like `-> Rule .m1(...).m2(...)`
  - `METHOD_EMPTY_NON_ACTION_CODE_BLOCK` now parses/render chains like `I.m1(...).m2(...)`
  - empty argument lists (`()`) in chained methods are now accepted.
- Added typed declaration lowering utilities:
  - `_split_declare_symbol_names(...)`
  - `_declare_sigil_for_type(...)`
  - `_declare_alias_to_type(...)`
  - `_lower_typed_declare_statement(...)`
- Added declaration lowering contracts and scanner support:
  - canonical `declare(type, ...)` where `type` is `array|scalar|hash` (optional injected scope label tolerated for method-chain rendering),
  - aliases `declare_a|declare_s|declare_h` and `declare_array|declare_scalar|declare_hash`.
- Canonical action-IR:
  - declaration methods now map to canonical `DECLARE` events (helper + canonical node surfaces).
- Added focused regression locks:
  - `action_rewriter_lowers_typed_declare_methods_and_aliases`
  - `method_like_action_chain_parses_into_multiple_helper_events`

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=62`)
## 2026-02-24 - Backbone Item #3 Follow-up: Indexed Push-Call Wrapper Lowering
## Summary
Extended structured action lowering to handle full-statement `push @target, call(Rule)->[index]` wrappers so canonical action-IR can avoid RAW_PERL fallback for indexed call-wrapper push forms.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `ROADMAP.md`
- Updated: `MEMORY.md`

## Technical Details
- Extended helper-lowering contracts in `_build_action_lowering_contracts(...)`:
  - added `push_call_indexed_builtin` contract for `push @target, call(Rule)->[index]` wrappers.
  - tightened existing `push_call_builtin` with negative-lookahead boundary so non-indexed and indexed wrapper contracts do not overlap.
- Extended helper event scanning in `_scan_contract_ir_events(...)`:
  - captures indexed push-call wrapper payloads (`target`, `callee`, `index`) under `push_call_indexed_builtin`.
- Added focused regression lock:
  - `action_rewriter_canonical_action_ir_lowers_push_call_indexed_wrapper_without_raw_fallback`
  - verifies no unresolved helper hits, no RAW_PERL fallback dependency, direct rewrite output correctness, and language-agnostic readiness for indexed push-call wrapper-only actions.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=60`)
## 2026-02-24 - Backbone Item #3 Follow-up: Return-Call Wrapper Lowering
## Summary
Extended structured action lowering to handle full-statement `return call(Rule)` wrappers so canonical action-IR can avoid RAW_PERL fallback for this wrapper form.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `ROADMAP.md`
- Updated: `MEMORY.md`

## Technical Details
- Extended helper-lowering contracts in `_build_action_lowering_contracts(...)`:
  - added `return_call` contract for `return call(Rule)` full-statement wrappers.
- Extended helper event scanning in `_scan_contract_ir_events(...)`:
  - captures `return_call` wrapper payloads with callee/context metadata.
- Extended canonical helper-event normalization in `_canonicalize_helper_action_ir_event(...)`:
  - maps `return_call` to canonical `CALL` kind (with return context marker).
- Added focused regression lock:
  - `action_rewriter_canonical_action_ir_lowers_return_call_wrapper_without_raw_fallback`
  - verifies no unresolved helper hits, no RAW_PERL fallback dependency, direct rewrite output correctness, and language-agnostic readiness for return-call wrapper-only actions.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=59`)
## 2026-02-24 - Backbone Item #3 Follow-up: Method-Style Action Arg Trimming Fix
## Summary
Fixed method-style empty action argument trimming so leading-space argument forms keep balanced helper payloads, preventing false unresolved-helper and RAW_PERL fallback classification for `.return ((...))`-style actions.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `ROADMAP.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `METHOD_EMPTY_ACTION_CODE_BLOCK` handling in `LinkedSpec.pm`:
  - outer argument parentheses are now trimmed with whitespace-tolerant boundary handling (`^\s*\(` and `\)\s*$`), instead of the prior strict `^\(`/`\)$` pattern.
- Migration impact:
  - method-style helper actions with leading-space args (e.g. `.return ((map {lc} @IMATCH_LIST), \@Top, call(Leaf))`) now lower through structured helper contracts without being misclassified as unresolved/RAW_PERL blockers.
- Added focused regression lock:
  - `method_empty_action_return_with_leading_space_args_stays_balanced`
  - verifies zero unresolved-helper/raw-perl/fallback counts and canonical `RETURN` action-IR node presence for the leading-space method-arg form.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=58`)
## 2026-02-24 - Backbone Item #3 Follow-up: Call-Wrapper Lowering Coverage
## Summary
Extended structured action lowering to handle common call-wrapper statement forms so canonical action-IR can avoid RAW_PERL fallback for these wrappers while preserving existing rewrite-contract ordering.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `ROADMAP.md`
- Updated: `MEMORY.md`

## Technical Details
- Extended helper-lowering contracts in `_build_action_lowering_contracts(...)`:
  - `assign_call_my` for `my $x = call(Rule)` wrappers,
  - `assign_call` for `$x = call(Rule)` wrappers,
  - `push_call_builtin` for `push @arr, call(Rule)` wrappers.
- Extended helper event scanning in `_scan_contract_ir_events(...)` for the new wrapper contracts.
- Kept historical contract ordering stability:
  - appended new wrapper contracts after existing helper contracts so legacy ordering lock expectations remain stable.
- Added focused regression lock:
  - `action_rewriter_canonical_action_ir_lowers_call_wrappers_without_raw_fallback`
  - verifies wrapper lowering output and confirms zero RAW_PERL fallback/unresolved-helper counts for supported wrapper-only actions.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=57`)
## 2026-02-24 - Backbone Item #3 Follow-up: Descriptor Migration Blocker-Type Ratios
## Summary
Extended descriptor-level action-rewriter migration summary with blocker-type ratio fields so triage dashboards can track blocked-rule composition trends over time (raw-only vs unresolved-only vs mixed).

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `ROADMAP.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `_build_action_rewriter_migration_summary(...)` in `LinkedSpec.pm`:
  - added ratio fields normalized by `language_agnostic_blocked_rule_count`:
    - `language_agnostic_blocked_raw_perl_only_ratio`
    - `language_agnostic_blocked_unresolved_helper_only_ratio`
    - `language_agnostic_blocked_mixed_ratio`
  - ratio fields default to `'0.0000'` when blocked-rule count is zero.
- Extended focused regression lock:
  - `return_descr_exposes_action_rewriter_migration_blocker_type_breakdown`
  - now validates all three blocker-type ratio fields in addition to blocked-rule type counts/lists.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=56`)
## 2026-02-24 - Backbone Item #3 Follow-up: Descriptor Migration Blocker-Type Breakdown
## Summary
Extended descriptor-level action-rewriter migration summary with explicit blocker-type breakdown fields so migration triage can distinguish raw-perl-only, unresolved-helper-only, and mixed blocked rules.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `ROADMAP.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `_build_action_rewriter_migration_summary(...)` in `LinkedSpec.pm`:
  - added blocked-rule type counters:
    - `language_agnostic_blocked_raw_perl_only_rule_count`
    - `language_agnostic_blocked_unresolved_helper_only_rule_count`
    - `language_agnostic_blocked_mixed_rule_count`
  - added deterministic blocked-rule lists by blocker type:
    - `language_agnostic_blocked_raw_perl_only_rules`
    - `language_agnostic_blocked_unresolved_helper_only_rules`
    - `language_agnostic_blocked_mixed_rules`
- Added focused regression lock:
  - `return_descr_exposes_action_rewriter_migration_blocker_type_breakdown`
  - verifies blocked-rule type counts/lists and priority interaction (`language_agnostic_top_blocked_rule`) for mixed/raw/unresolved blocker combinations.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=56`)
## 2026-02-24 - Backbone Item #3 Follow-up: Action Rewriter Dead-Helper Cleanup
## Summary
Removed an unused legacy action-rewriter helper and clarified the remaining helper API so rewrite entrypoints are explicit and non-confusing for maintainers.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `ROADMAP.md`
- Updated: `MEMORY.md`

## Technical Details
- Removed dead helper from `LinkedSpec.pm`:
  - `_apply_action_rewrite_pipeline(...)` (no runtime/test callers).
- Clarified retained helper contract:
  - `call_spec_handler_subst(...)` is now explicitly documented as a compatibility/test shim,
  - runtime rule compilation continues to call `_rewrite_action_code_with_diagnostics(...)` directly from RuleIR emit flow.
- Updated architecture/test notes to reflect canonical-IR-first runtime rewrite path and avoid stale references to removed helper stage.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=55`)
## 2026-02-24 - Backbone Item #3 Follow-up: Descriptor Migration Prioritization Metadata
## Summary
Extended descriptor-level action-rewriter migration summary metadata with deterministic blocked-rule prioritization fields so language-agnostic migration work can be triaged by highest-impact blockers.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `_build_action_rewriter_migration_summary(...)` in `LinkedSpec.pm`:
  - accumulates descriptor-level blocker payload total (`language_agnostic_blocker_statement_total_count`),
  - computes deterministic blocked-rule migration order (`language_agnostic_blocked_rules_by_priority`) sorted by:
    - blocker statement count (descending),
    - unresolved helper count (descending),
    - raw-Perl dependency count (descending),
    - rule name (ascending tie-breaker),
  - exposes highest-priority blocked rule (`language_agnostic_top_blocked_rule`).
- Extended migration-summary regression lock:
  - `return_descr_exposes_action_rewriter_migration_summary`
  - now validates blocker-statement total, deterministic blocked-rule priority order, and top blocked rule.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=55`)
## 2026-02-24 - Backbone Item #3 Follow-up: Descriptor-Level Action Rewriter Migration Summary
## Summary
Added descriptor-level migration summary metadata so `return_descr` consumers can quantify language-agnostic readiness across all rules and prioritize concrete blocker cleanup.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added `_build_action_rewriter_migration_summary(...)` in `LinkedSpec.pm`:
  - aggregates per-rule `meta.action_rewriter` into descriptor-level summary metrics.
- Extended `Get(...)` descriptor payload:
  - now exposes `meta.action_rewriter_migration` at descriptor top-level.
- Summary metadata fields include:
  - `total_rules`
  - `rules_with_action_rewriter_meta`
  - `language_agnostic_ready_rule_count`
  - `language_agnostic_blocked_rule_count`
  - `language_agnostic_ready_rules`
  - `language_agnostic_blocked_rules`
  - `language_agnostic_ready_ratio`
- Added focused regression lock:
  - `return_descr_exposes_action_rewriter_migration_summary`
  - verifies deterministic counts/lists, blocked rule payloads, and readiness ratio.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=55`)

## 2026-02-24 - LinkedSpec.pm Maintainability Pass: Subroutine Docstrings and Structural Comments
## Summary
Performed a broad documentation pass on `LinkedSpec.pm` to improve maintainability and readability by adding docstring-style comment headers for core subs, clarifying top-level parser globals, and annotating key compilation/rewrite pipeline responsibilities.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `ROADMAP.md`
- Updated: `MEMORY.md`

## Technical Details
- Added structured comment headers (`Function`, `Purpose`, `Args`, `Returns`) to major subroutines across:
  - logging/validation helpers,
  - parser compilation entrypoints (`Get`, `get_parser`),
  - RuleIR planning/emission helpers,
  - action-rewriter and canonical action-IR pipeline helpers,
  - plugin dispatch bridge (`AUTOLOAD`).
- Added explanatory comments for important top-level variables and bootstrap structures:
  - bootstrap rule index registry,
  - node/repetition semantics maps,
  - bootstrap grammar descriptor and gdata scanner bundles,
  - top-rule parse state.
- Added section-level readability anchors around bootstrap metadata and parser/rewrite flow areas without changing runtime behavior.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=54`)

## 2026-02-24 - Backbone Item #3 Follow-up: Language-Agnostic Blocker Statement Metadata
## Summary
Extended action-rewriter rule metadata with explicit blocker statement details so language-agnostic migration can prioritize concrete unresolved-helper and RAW_PERL dependency statements per rule.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Extended unresolved-helper diagnostics in `LinkedSpec.pm`:
  - unresolved-helper events are now captured at statement granularity and exposed in metadata.
- Extended `spec->{rule}{meta}{action_rewriter}` with:
  - `unresolved_helper_events`
  - `unresolved_helper_statements`
  - `language_agnostic_action_ir_blocker_statement_count`
  - `language_agnostic_action_ir_blocker_statements`
- Metadata semantics:
  - blocker statement list is a deduplicated union of canonical RAW_PERL dependency statements and unresolved helper statements.
  - readiness remains controlled by unresolved-helper count and raw-perl dependency count; blocker statements provide direct migration targets.
- Added focused regression lock:
  - `action_rewriter_meta_exposes_language_agnostic_blocker_statements`
  - verifies helper-only rules expose zero blockers and mixed unresolved+raw rules expose both blocker statement payloads and blocker count.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=54`)

## 2026-02-24 - Backbone Item #3 Follow-up: Language-Agnostic Action Readiness Metadata
## Summary
Added explicit action-rewriter metadata that quantifies raw Perl fallback dependency and reports per-rule language-agnostic action readiness, so migration away from embedded Perl code-block behavior in `.spec` can be tracked and enforced incrementally.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Extended action-rewriter metadata assembly in `LinkedSpec.pm` (`_build_rule_ir_emit_context(...)`):
  - added `raw_perl_dependency_count` (canonical RAW_PERL fallback statement count),
  - added `raw_perl_dependency_statements` (deduplicated canonical RAW_PERL statement payloads),
  - added `language_agnostic_action_ir_ready` readiness flag (`true` only when both raw-Perl fallback count and unresolved-helper count are zero).
- Migration impact:
  - rule metadata now directly exposes whether an action block is currently backend-neutral-ready versus still dependent on fallback/raw-host-language behavior.
- Added focused regression lock:
  - `action_rewriter_meta_exposes_language_agnostic_readiness`
  - verifies readiness behavior for:
    - helper-only rules (`ready`),
    - rules with RAW_PERL fallback statements (`not ready`),
    - rules with unresolved helpers (`not ready` even without RAW_PERL fallback).

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=53`)

## 2026-02-24 - Backbone Item #3 Follow-up: Pipe-Quote-Safe Canonical Statement Splitting
## Summary
Hardened canonical action-IR statement splitting to ignore semicolons inside pipe-delimited Perl quote-like payloads (e.g. `qr|...|`), preventing fallback-fragment noise for pipe-quote payload statements while preserving helper lowering behavior.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `_split_action_ir_statements(...)` in `LinkedSpec.pm`:
  - added pipe-delimited quote-like state handling with escape support and multi-segment tracking for `s|...|...|`/`tr|...|...|`/`y|...|...|` forms,
  - semicolons inside pipe-delimited quote-like payloads are no longer treated as top-level statement delimiters.
- Canonical action-IR impact:
  - pipe-quote payload statements (e.g. `my $re = qr|a;b|`) remain single RAW_PERL fallback events instead of semicolon-fragmented shards.
- Added focused regression lock:
  - `action_rewriter_canonical_action_ir_ignores_pipe_quote_semicolon_fragmentation`
  - verifies canonical fallback count/payload integrity, unresolved-helper stability, and lowering output for helper + pipe-quote-semicolon mixed action code.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=52`)

## 2026-02-24 - Backbone Item #3 Follow-up: Angle-Quote-Safe Canonical Statement Splitting
## Summary
Hardened canonical action-IR statement splitting to ignore semicolons inside angle-delimited Perl quote-like payloads (e.g. `qr<...>`), preventing fallback-fragment noise for angle-quote payload statements while preserving helper lowering behavior.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `_split_action_ir_statements(...)` in `LinkedSpec.pm`:
  - added angle-delimited quote-like state tracking with escape and nested-angle handling,
  - semicolons inside angle-delimited quote-like payloads are no longer treated as top-level statement delimiters.
- Canonical action-IR impact:
  - angle-quote payload statements (e.g. `my $re = qr<a;b>`) remain single RAW_PERL fallback events instead of semicolon-fragmented shards.
- Added focused regression lock:
  - `action_rewriter_canonical_action_ir_ignores_angle_quote_semicolon_fragmentation`
  - verifies canonical fallback count/payload integrity, unresolved-helper stability, and lowering output for helper + angle-quote-semicolon mixed action code.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=51`)

## 2026-02-24 - Backbone Item #3 Follow-up: Slash-Quote-Safe Canonical Statement Splitting
## Summary
Hardened canonical action-IR statement splitting to ignore semicolons inside slash-delimited Perl quote-like payloads, preventing fallback-fragment noise for `qr/.../` and related forms while preserving helper lowering behavior.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `_split_action_ir_statements(...)` in `LinkedSpec.pm`:
  - added slash-quote-like state handling with escape support for slash-delimited Perl forms,
  - semicolons inside slash-delimited quote-like payloads are no longer treated as top-level statement delimiters.
- Canonical action-IR impact:
  - slash-quote payload statements (e.g. `my $re = qr/a;b/`) remain single RAW_PERL fallback events instead of semicolon-fragmented shards.
- Added focused regression lock:
  - `action_rewriter_canonical_action_ir_ignores_slash_quote_semicolon_fragmentation`
  - verifies canonical fallback count/payload integrity, unresolved-helper stability, and lowering output for helper + slash-quote-semicolon mixed action code.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=50`)

## 2026-02-24 - Backbone Item #3 Follow-up: Backtick-Quote-Safe Canonical Statement Splitting
## Summary
Hardened canonical action-IR statement splitting to ignore semicolons inside Perl backtick-quoted strings, preventing fallback-fragment noise for backtick payloads while preserving helper lowering behavior.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `_split_action_ir_statements(...)` in `LinkedSpec.pm`:
  - added backtick-quote state tracking with escape handling (`\\` + `` ` ``),
  - semicolons inside backtick-quoted strings are no longer treated as top-level statement delimiters.
- Canonical action-IR impact:
  - backtick payload statements (e.g. ``my $cmd = `echo a;b` ``) remain single RAW_PERL fallback events instead of semicolon-fragmented shards.
- Added focused regression lock:
  - `action_rewriter_canonical_action_ir_ignores_backtick_semicolon_fragmentation`
  - verifies canonical fallback count/payload integrity, unresolved-helper stability, and lowering output for helper + backtick-semicolon mixed action code.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=49`)

## 2026-02-24 - Backbone Item #3 Follow-up: Line-Comment-Safe Canonical Statement Splitting
## Summary
Hardened canonical action-IR statement splitting to ignore semicolons inside Perl line comments, preventing false RAW_PERL fallback fragmentation and improving canonical metadata stability for comment-bearing action code.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `_split_action_ir_statements(...)` in `LinkedSpec.pm`:
  - added line-comment state tracking outside quoted strings,
  - semicolons encountered within `# ...` comments are no longer treated as top-level statement delimiters.
- Canonical action-IR impact:
  - comment text containing semicolons is preserved as a single RAW_PERL fallback statement instead of fragmented fallback shards.
- Added focused regression lock:
  - `action_rewriter_canonical_action_ir_ignores_line_comment_semicolon_fragmentation`
  - verifies canonical fallback count, RAW_PERL payload integrity, unresolved-helper stability, and lowering output behavior for `call(Leaf); # keep; comment`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=48`)

## 2026-02-24 - Backbone Item #3 Follow-up: Whitespace-Tolerant Canonical Helper Lowering
## Summary
Expanded canonical helper lowering so helper invocations with optional whitespace are lowered consistently, reducing unresolved helper surface caused by spacing-only variations while preserving unresolved diagnostics for true label-mismatch helper forms.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated helper lowering substitutions in `LinkedSpec.pm` (`_build_action_lowering_contracts(...)`):
  - helper-lowering regexes now accept optional spacing around helper names, parentheses, and arguments for supported helper contracts (`call`, `push`, `return*`, `capture*`, `backtrack*`).
- Canonical lowering effect:
  - spacing-only helper forms (e.g. `call (Leaf)`, `CAPTURE_IF ( )`) now lower via canonical action-IR helper events instead of remaining unresolved.
- Preserved unresolved-helper diagnostics coverage:
  - unresolved-helper regression now targets label-mismatch helper forms (`return_a(Leaf)`, `return(Leaf, $x)`) so diagnostics continue to lock non-lowerable helper behavior.
- Updated focused regression locks:
  - `action_rewriter_pipeline_helper_substitutions` now validates spaced helper lowering forms.
  - `action_rewriter_canonical_ir_lowering_preserves_helper_and_raw_behavior` now verifies spaced helper lowering in mixed helper + RAW_PERL statements.
  - `action_rewriter_reports_unresolved_helpers_in_rule_meta` now locks unresolved label-mismatch helper diagnostics.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=47`)

## 2026-02-24 - Backbone Item #3 Follow-up: Nested-Semicolon-Safe Canonical Action-IR Statement Splitting
## Summary
Hardened canonical action-IR statement splitting so semicolons inside nested helper payload expressions no longer produce false `RAW_PERL` fallback canonical events, improving canonical IR fidelity while preserving helper-lowering behavior.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Reworked canonical statement splitter in `LinkedSpec.pm`:
  - `_split_action_ir_statements(...)` now performs depth-aware scanning over `()`, `{}`, `[]`, and quoted strings instead of naive `split /;/`.
  - top-level semicolons continue to delimit statements; nested semicolons inside helper payloads remain within the same statement.
- Canonical action-IR effects:
  - helper payloads like `return_a(... do { ...; ... } ...)` now stay canonicalized as helper events instead of being fragmented into fallback fragments.
  - `canonical_action_ir_fallback_count` and `canonical_action_ir_nodes` no longer over-report `RAW_PERL` for nested helper payload semicolons.
- Added focused regression lock:
  - `action_rewriter_canonical_action_ir_handles_nested_semicolon_payloads`
  - verifies canonical metadata and lowering output for `return_a` helper payloads containing nested semicolons.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=47`)

## 2026-02-24 - Backbone Item #3 Follow-up: Canonical Action-IR-Driven Lowering
## Summary
Switched helper lowering from whole-code regex rewrite passes to canonical action-IR event driven lowering so helper transformations now consume canonical IR metadata directly while preserving unresolved-helper behavior and RAW_PERL pass-through.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added canonical lowering helper in `LinkedSpec.pm`:
  - `_lower_action_code_from_canonical_ir(...)`
- Updated rewrite flow:
  - `_rewrite_action_code_with_diagnostics(...)` now lowers via canonical action-IR events instead of `_apply_action_rewrite_pipeline(...)` over the full code string.
- Canonical lowering behavior:
  - helper events are lowered via contract-specific apply functions using canonical event `contract_id` + `raw` payload,
  - non-helper statements continue via existing canonical `RAW_PERL` pass-through behavior,
  - unresolved helper forms remain unchanged when contract lowering does not apply (preserving diagnostics behavior).
- Added focused regression lock:
  - `action_rewriter_canonical_ir_lowering_preserves_helper_and_raw_behavior`
  - verifies canonical-IR lowering rewrites helpers, preserves RAW_PERL statements, and keeps unresolved helper forms unchanged.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=46`)

## 2026-02-24 - Backbone Item #3 Follow-up: Canonical Action-IR Promotion with RAW_PERL Fallback
## Summary
Promoted helper payload events into canonical action-IR events and added explicit `RAW_PERL` fallback markers for non-helper statements so rule metadata now captures a canonical, statement-level action-IR view.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added canonical action-IR promotion helpers in `LinkedSpec.pm`:
  - `_canonicalize_helper_action_ir_event(...)`
  - `_split_action_ir_statements(...)`
  - `_build_canonical_action_ir_events(...)`
- Extended action-rewriter diagnostics aggregation:
  - canonical action-IR counters/hits/events are now accumulated across ACODE/BCODE/lifecycle chunks.
- Extended `spec->{rule}{meta}{action_rewriter}` metadata with:
  - `canonical_action_ir_count`
  - `canonical_action_ir_nodes`
  - `canonical_action_ir_hits`
  - `canonical_action_ir_events`
  - `canonical_action_ir_fallback_count`
- Canonical action-IR behavior:
  - helper payload events are promoted into canonical node kinds (`CALL`, `PUSH`, `RETURN_A`, etc.),
  - non-helper statements are represented explicitly as `RAW_PERL` fallback events with preserved statement payload.
- Added focused regression lock:
  - `action_rewriter_meta_exposes_canonical_action_ir_with_raw_fallback`
  - verifies canonical node coverage plus `RAW_PERL` fallback behavior and payload extraction.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=45`)

## 2026-02-24 - Backbone Item #3 Follow-up: Structured Helper Action-IR Payload Events
## Summary
Extended helper action-IR reporting from node counters to structured payload events by parsing helper invocations before lowering and exposing the parsed argument payloads in rule metadata.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added structured helper payload parsing in `LinkedSpec.pm`:
  - `_trim_action_ir_value(...)`
  - `_scan_contract_ir_events(...)`
- Extended helper action-IR collection:
  - `_collect_action_helper_ir_nodes(...)` now aggregates structured events (`ir_node`, `contract_id`, `raw`, parsed `args`) rather than only counts.
- Extended rewrite diagnostics aggregation:
  - `_accumulate_action_rewrite_diagnostics(...)` now accumulates `helper_action_ir_events` across ACODE/BCODE/lifecycle chunks.
- Extended action-rewriter metadata in `spec->{rule}{meta}{action_rewriter}` with:
  - `helper_action_ir_events` (structured per-helper payload events).
- Preserved rewrite/lowering behavior while improving action-IR introspection fidelity for upcoming canonical action-IR migration.
- Added focused regression lock:
  - `action_rewriter_meta_exposes_helper_action_ir_payload_events`
  - verifies parsed helper payload events and argument extraction for representative helper forms (`call`, `push(rule,target)`, `return_a(label,arg)`).

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=44`)

## 2026-02-24 - Backbone Item #3 Follow-up: Helper Action-IR Node Metadata
## Summary
Extended the action rewriter to expose helper action-IR node usage in rule metadata, using the existing lowering-contract catalog as the shared source for IR-node detection and unresolved-helper diagnostics.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Extended helper-lowering contracts with explicit `ir_node` identities (e.g. `CALL`, `RETURN_A`, `CAPTURE_IF`).
- Added helper action-IR collection helper:
  - `_collect_action_helper_ir_nodes(...)`
- Updated rewrite diagnostics flow:
  - `_rewrite_action_code_with_diagnostics(...)` now returns both unresolved-helper diagnostics and helper action-IR node hits,
  - `_accumulate_action_rewrite_diagnostics(...)` now accumulates both unresolved-helper and helper action-IR counters.
- Extended `spec->{rule}{meta}{action_rewriter}` metadata with:
  - `helper_action_ir_count`
  - `helper_action_ir_nodes`
  - `helper_action_ir_hits`
- Preserved rewrite/runtime behavior while improving introspection surface for progressive action-IR migration.
- Added focused regression lock:
  - `action_rewriter_meta_exposes_helper_action_ir_nodes`
  - verifies helper action-IR node presence/hit-counts for representative helper invocations.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=43`)

## 2026-02-24 - Backbone Item #3 Follow-up: Lowering Contract Catalog for Action Rewriter
## Summary
Refactored action-rewriter helper lowering to use an explicit contract catalog shared by rewrite application and unresolved-helper diagnostics, and surfaced the contract list in rule metadata.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added explicit helper lowering contracts in `LinkedSpec.pm`:
  - `_build_action_lowering_contracts($label)`
- Rewired action rewrite plumbing:
  - `_build_action_rewrite_rules(...)` now compiles from lowering contracts,
  - unresolved-helper diagnostics now reuse the same contract definitions (`diag_name` + `unresolved_pattern`),
  - `_build_rule_ir_emit_context(...)` now builds rewrite rules once per rule and reuses them across ACODE/BCODE/lifecycle chunk normalization.
- Extended metadata surface in `spec->{rule}{meta}{action_rewriter}`:
  - added `rewrite_contract_ids` for stable tooling/introspection of active helper-lowering contracts.
- Added focused regression lock:
  - `action_rewriter_meta_exposes_lowering_contract_ids`
  - verifies `rewrite_contract_ids` presence, stability, and expected helper-contract membership.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=42`)

## 2026-02-24 - Backbone Item #3 Follow-up: Action-Rewriter Diagnostics Metadata
## Summary
Extended the structured action rewriter with diagnostics for unresolved helper forms and surfaced those diagnostics in per-rule metadata for `return_descr` tooling workflows.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added rewrite-diagnostics helpers in `LinkedSpec.pm`:
  - `_find_unresolved_action_helpers(...)`
  - `_accumulate_action_rewrite_diagnostics(...)`
  - `_rewrite_action_code_with_diagnostics(...)`
- Updated rule-emission pipeline wiring:
  - action rewrites now collect unresolved helper diagnostics while normalizing ACODE/BCODE and lifecycle code chunks,
  - diagnostics are exposed at `spec->{rule}{meta}{action_rewriter}` with:
    - `unresolved_helper_count`,
    - `unresolved_helpers`,
    - `unresolved_helper_hits`.
- Preserved existing rewrite/runtime behavior:
  - `call_spec_handler_subst(...)` remains string-returning and backward-compatible.
- Added focused regression lock:
  - `action_rewriter_reports_unresolved_helpers_in_rule_meta`
  - verifies unresolved helper diagnostics are emitted in rule metadata for malformed helper forms while clean rules remain at zero unresolved-helper count.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=41`)

## 2026-02-24 - Backbone Refactor Item #3: Structured Action Rewriter Pipeline
## Summary
Landed Backbone Refactor Track item #3 by replacing inline regex-chain helper substitutions in `call_spec_handler_subst()` with an ordered, structured rewrite pipeline and locking helper behavior with focused regression coverage.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added rewrite-pipeline helpers in `LinkedSpec.pm`:
  - `_build_action_rewrite_rules($label)`
  - `_apply_action_rewrite_pipeline($code, $rules)`
- Updated `call_spec_handler_subst(...)` to:
  - build ordered rewrite rules once per invocation,
  - apply rewrites through a dedicated pipeline stage rather than chained inline substitutions.
- Added focused regression lock:
  - `action_rewriter_pipeline_helper_substitutions`
  - verifies helper rewrites for `call`, `push`, `$CAPTURE`, `IBACKTRACK`, `BACKTRACK`, `return_a`, `return_ma`, `capture_if`, and `CAPTURE_IF`.
- Preserved current helper-rewrite output semantics, including argument-spacing behavior in `return_a(label,arg)` rewrite output.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=40`)

## 2026-02-24 - Backbone Refactor Item #2: spec_entry Staged RuleIR Pipeline
## Summary
Landed Backbone Refactor Track item #2 by splitting `spec_entry()` into explicit RuleIR stages while preserving parser behavior and existing handler-template semantics.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added staged RuleIR helpers in `LinkedSpec.pm`:
  - `_collect_rule_ir(...)`
  - `_plan_rule_ir_meta(...)`
  - `_validate_rule_ir_or_exit(...)`
  - `_normalize_rule_code_chunks(...)`
  - `_build_rule_ir_emit_context(...)`
- `spec_entry(...)` now executes a clear pipeline:
  1. collect RuleIR from parsed entries,
  2. plan execution metadata,
  3. validate incompatible action-mode combinations,
  4. build normalized emit-context for handler assembly.
- Preserved downstream behavior:
  - existing handler templates unchanged,
  - mixed ACTION/BLIND CALL explicit-exit behavior preserved,
  - gdata mapping and handler-variant metadata flow preserved.
- Added focused regression lock:
  - `ruleir_pipeline_preserves_acode_gdata_mapping_order`
  - verifies RuleIR stage outputs preserve ACODE gdata mapping order/count and expected multi-AND handler variant.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=39`)

## 2026-02-24 - Backbone Refactor Item #1: Declarative Bootstrap Rule Registry
## Summary
Landed Backbone Refactor Track item #1 by replacing fixed-index bootstrap grammar coupling in `LinkedSpec.pm` with explicit rule IDs/tags and registry-driven dispatch.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Annotated each hardcoded bootstrap rule in `$spec_descr` with explicit metadata:
  - `id` (stable rule identity),
  - `tags` (semantic routing markers such as `start_token` and `brace_scanner`).
- Replaced positional dispatch assumptions:
  - root bootstrap handler now dispatches via `start_dispatch` mapping (`gdata`), not `index + 1`.
  - recursive brace handling now resolves via `CURLY_BRACE` rule ID lookup (`%bootstrap_rule_index`) instead of fixed numeric slot.
- Rebuilt bootstrap scanner sets from registry metadata:
  - `startREs` now derived from `start_token` tags,
  - `cbrace` scanner now derived from `CURLY_BRACE` rule ID.
- Added bootstrap integrity checks for required IDs and non-empty start-token registry.
- Added focused regression lock:
  - `bootstrap_registry_curly_brace_recursion_smoke`
  - validates nested/quoted brace handling still compiles/runs AST parsing under registry-driven recursion dispatch.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=38`)

## 2026-02-23 - Phase 1 Core Structure: Rule Execution Metadata + Descriptor Introspection
## Summary
Reworked core rule-compilation structure in `LinkedSpec.pm` to expose explicit per-rule execution metadata and deterministic handler-template selection, while preserving parser behavior and baseline compatibility.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `USER_GUIDE.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added `return_descr => 1` mode to `LinkedSpec::Get(...)`:
  - returns generated descriptor hash (`{ spec => ..., gdata => ... }`) for tooling/introspection instead of parser coderef.
- Added deterministic rule-strategy helpers:
  - `_select_rule_handler_variant(...)`
  - `_build_rule_execution_meta(...)`
- `spec_entry(...)` now computes and stores per-rule metadata at `spec->{rule}{meta}` including:
  - `node_type`, regex/action counts, `action_mode`,
  - selected handler variant,
  - execution shape and loop/non-loop strategy marker.
- Added dedicated single-regex AND action template:
  - `AND_SINGLE_ACODE` is now selected for AND rules with exactly one action-regex edge,
  - multi-regex AND rules continue to use `AND_ACODE` loop template.
- Replaced non-deterministic handler-template pick (`keys %handlers` ordering) with metadata-driven deterministic selection.

## Validation
- Ran syntax check:
  - `perl -c perl/LinkedSpec.pm`
  - Result: `syntax OK`
- Ran regression suite:
  - `prove -v -Iperl t/phase0_regression.t`
  - Result: PASS
  - Total: 37 tests successful.

## 2026-02-23 - Documentation Infrastructure Bootstrap
## Summary
Created live project documentation files to support long-running, interruption-resilient development and commit hygiene.

## Added Files
- `ROADMAP.md`
- `USER_GUIDE.md`
- `DEVELOPMENT_NOTES.md`
- `CHANGES.md`
- `MEMORY.md`

## Technical Details
- Established project positioning and multi-phase roadmap for LinkedSpec modernization.
- Documented user-facing syntax/workflow guidance for LinkedSpec DSL.
- Captured engineering rationale and architectural observations for refactoring decisions.
- Established a compact, resumable session memory protocol (`MEMORY.md`) for LLM/AI handoff continuity.
- Established a pre-commit documentation gate to keep live documents synchronized before commit workflow execution.
- Recorded external-consumer policy: downstream consumers are separate projects and should be treated as independent compatibility targets.
- Recorded scope update: downstream-consumer compatibility work is deferred for now.

## Rationale
- The project is parser-infrastructure-heavy and spans multiple modules and specs.
- Session interruption risk is high during iterative “vibe coding.”
- Live, versioned documents reduce context loss and improve continuation quality across agent/session restarts.

## Validation
- Verified requested markdown live-document set now exists in repository root.
- No functional parser code changed in this change set.

## Notes for Next Change Set
- Add regression harness baseline for `specs/*.spec`.
- Capture compile status matrix and known failures.
- Start phase tracking updates in `ROADMAP.md`.

## 2026-02-23 - Phase 0 Test::More Baseline Harness
## Summary
Switched from ad-hoc regression harness to `Test::More` and established baseline regression coverage under `t/`.

## Changed Files
- Added: `t/phase0_regression.t`
- Removed: `bin/spec_regression.pl`
- Updated: `ROADMAP.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `CHANGES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added a unified regression test file using `Test::More` with three blocks:
  - compile/generation checks for all non-deferred specs,
  - strict Lispish AST smoke check (`is_deeply`),
  - VHDL invariant smoke check.
- Added dedicated `ebnf.spec` smoke test to lock baseline expectations for rule-name extraction.
- Explicitly excluded `tclite.spec` from current scope.
- Initially marked `regdef.spec` compile check as TODO due validator false-positive; later resolved in this same change series.

## Validation
- Tests run via:
  - `prove -Iperl t/phase0_regression.t`
- Expected current behavior:
  - all in-scope compile checks pass,
  - Lispish smoke passes,
  - VHDL invariant smoke passes,
  - EBNF invariant smoke passes.
- Actual baseline run result:
  - PASS (`Result: PASS`)
  - Scope confirmed: `tclite.spec` excluded by design.

## 2026-02-23 - DSL Validator Fix (Escaped Slash Regex Handling)
## Summary
Resolved false-positive regex validation failures on `.spec` lines containing escaped slash sequences (e.g. `\\/\\/`), which previously impacted `regdef.spec`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `CHANGES.md`
- Updated: `MEMORY.md`

## Technical Details
- Reworked regex-literal extraction inside `validate_dsl_syntax`:
  - rule RHS is scanned for slash-delimited regex literals with escaped-delimiter-aware matching.
- Validator now compiles extracted regex bodies directly, avoiding truncated-literal false positives.
- Fixed undefined/unused rule warning calculations by replacing broken self-comparison logic with set-based checks.
- Removed obsolete TODO handling for `regdef.spec` in tests.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all in-scope compile checks pass (`tclite.spec` remains excluded by scope)
  - smoke tests pass for `Lispish.spec`, `vhdl.spec`, and `ebnf.spec`.

## 2026-02-23 - Corpus Regression Expansion + Invalid conf Cleanup
## Summary
Expanded Phase-0 regression to include real corpus directories and removed an invalid non-Lisp-like conf file that should not have been present.

## Changed Files
- Updated: `t/phase0_regression.t`
- Deleted: `conf/httpd.conf`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added new `corpus_regression` subtest in `t/phase0_regression.t` to validate:
  - `plugin/*.plg` via `pplugin.spec`
  - `conf/*.conf` via Lispish parser flow
  - `tablescript/*.ts` via Lispish parser flow
  - `ebnf/*.ebnf` via `ebnf.spec`
- Added exit-trapping helper in tests to protect suite integrity against parser-level `exit` calls.
- Removed `conf/httpd.conf` per user instruction (file not in intended Lisp-like conf format).

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - compile/spec smoke and corpus regression are green.

## 2026-02-23 - Phase 1 Core Isolation: Module-Relative Spec Resolution + Lazy Dependency Loading
## Summary
Completed the first parser-core isolation step in `LinkedSpec`: removed eager plugin coupling, made spec resolution module-relative (no cwd assumption), and kept `PathSearch` as lazy fallback only.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `CHANGES.md`
- Updated: `MEMORY.md`

## Technical Details
- `LinkedSpec` load path isolation:
  - Removed eager `use PPlugin;` from module load path.
  - `AUTOLOAD` now lazy-loads `PPlugin` only when plugin dispatch is actually needed.
- `get_parser` resolution flow hardened:
  - Added `_resolve_local_spec_path($spec_name)` to resolve in this order:
    1. exact file path if provided,
    2. `$spec_name.spec` in current context if directly available,
    3. module-relative `../specs/$spec_name.spec` (relative to `perl/LinkedSpec.pm` location).
  - If local resolution fails, fallback to `PathSearch` is loaded lazily (`require PathSearch`).
  - Fixed `_resolve_local_spec_path` control flow so module-relative matches are actually returned.
- Regression harness isolation:
  - `t/phase0_regression.t` no longer imports `Lispish.pm`.
  - Corpus helpers now use `LinkedSpec::get_parser('Lispish')` directly and parse streams iteratively with a guard.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - compile/smoke/corpus blocks all green.
  - prior `Lispish.pm` smartmatch warnings no longer appear in module-relative-only paths.

## 2026-02-23 - Phase 1 Validation Expansion: get_parser Resolution Paths
## Summary
Expanded regression coverage to explicitly verify both `get_parser` resolution paths: module-relative local resolution (without cwd dependency) and lazy `PathSearch` fallback resolution.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `CHANGES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added subtest `get_parser_local_resolution_without_pathsearch`:
  - changes cwd to a temporary non-project directory,
  - verifies `LinkedSpec::get_parser('Lispish')` still resolves/parser-runs,
  - verifies `PathSearch.pm` remains unloaded when module-relative resolution succeeds.
- Added subtest `get_parser_pathsearch_fallback`:
  - creates a temporary `.spec` outside `specs/` to force fallback path,
  - verifies parser is created and executed,
  - verifies `PathSearch.pm` is loaded only when fallback resolution is required.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - new subtests pass.
  - Inference: exercising `PathSearch` fallback currently triggers legacy smartmatch warnings from `perl/Lispish.pm` via fallback dependency chain.

## 2026-02-23 - Phase 1 Isolation Follow-up: Fallback Path Dependency Decoupling
## Summary
Removed unnecessary `PathSearch` dependency on `Global` so `get_parser` fallback no longer drags legacy modules into the load path.

## Changed Files
- Updated: `perl/PathSearch.pm`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Removed `use Global;` from `perl/PathSearch.pm`.
- Root cause chain was:
  - `LinkedSpec::get_parser` fallback loads `PathSearch`,
  - `PathSearch` imported `Global` even though it did not use it,
  - `Global` pulled `HUtils`,
  - `HUtils` pulls `Lispish`,
  - `Lispish` emits smartmatch experimental warnings.
- The `PathSearch` functionality used by `get_parser` (`go`) remains unchanged.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - compile, resolution-path, smoke, and corpus subtests all green.
  - fallback-resolution subtest no longer emits the prior `Lispish.pm` smartmatch warnings.

## 2026-02-23 - Phase 1 Validation Expansion: Complete get_parser Resolution Order Coverage
## Summary
Extended regression coverage to validate all documented non-fallback `get_parser` local resolution modes before fallback is exercised.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added subtest `get_parser_explicit_path_resolution_without_pathsearch`:
  - uses a temporary spec file via explicit file path argument,
  - verifies parser creation/execution,
  - verifies `PathSearch.pm` remains unloaded.
- Added subtest `get_parser_cwd_name_spec_resolution_without_pathsearch`:
  - creates `name.spec` in temporary cwd,
  - verifies `get_parser('name')` resolves directly from cwd local file,
  - verifies `PathSearch.pm` remains unloaded.
- Combined with existing coverage, `t/phase0_regression.t` now explicitly exercises:
  1. module-relative local resolution,
  2. explicit file path resolution,
  3. cwd `name.spec` resolution,
  4. lazy `PathSearch` fallback resolution.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 10 top-level test blocks pass.

## 2026-02-23 - Phase 1 Validation Expansion: get_parser Unresolved-Spec Negative Paths
## Summary
Added focused negative-path regression coverage for unresolved specs to ensure `get_parser` fails safely and emits useful diagnostics.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added subtest `get_parser_unresolved_spec_reports_error` with captured STDOUT/STDERR assertions.
- Validates two unresolved-spec scenarios:
  - missing spec name (e.g. `phase1_missing_spec_<pid>`),
  - missing explicit path (non-existent `.../does_not_exist.spec`).
- For each scenario, verifies:
  - `get_parser` returns without die,
  - parser return value is `undef`,
  - diagnostics include `Spec path not found`,
  - diagnostics include the requested spec token/path.
- Added helper `run_get_parser_with_captured_io` in test file to capture diagnostics without changing runtime behavior.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 11 top-level test blocks pass.

## 2026-02-23 - Phase 1 Validation Expansion: get_parser Open-Failure Negative Path
## Summary
Added regression coverage for the unresolved-open case where a spec path exists but cannot be opened.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added subtest `get_parser_open_failure_reports_error`.
- Scenario:
  - create temporary spec file,
  - make it unreadable via permissions,
  - call `LinkedSpec::get_parser` and capture diagnostics.
- Asserts:
  - call returns without die,
  - return value is `undef`,
  - diagnostics include `Unable to open spec file`,
  - diagnostics include requested file path and `OS Error`.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 12 top-level test blocks pass.

## 2026-02-23 - Phase 1 Validation Expansion: get_parser Malformed-Spec Negative Path
## Summary
Added regression coverage for malformed spec content to verify parser-generation validation failures are surfaced cleanly through `get_parser`.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added subtest `get_parser_malformed_spec_reports_validation_error`.
- Scenario:
  - write a temporary `.spec` file containing intentionally invalid DSL content (no rule definition).
  - call `LinkedSpec::get_parser` and capture diagnostics.
- Asserts:
  - call returns without die,
  - return value is `undef`,
  - diagnostics include DSL validation failure (`Spec file must start with a rule definition`),
  - diagnostics include `CRITICAL ERROR` from failed generation path.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 13 top-level test blocks pass.

## 2026-02-23 - Phase 1 Validation Expansion: get_parser Malformed-Handler Runtime Error Path
## Summary
Added regression coverage for post-generation runtime handler failures caused by malformed action-code emitted into generated parser handlers.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added subtest `get_parser_malformed_handler_runtime_error`.
- Scenario:
  - create temporary valid-looking spec with intentionally invalid Perl statement inside action block:
    - `my $broken = ;`
  - build parser via `get_parser`,
  - invoke parser and capture inner eval error from generated handler execution path.
- Asserts:
  - parser creation returns without die and yields coderef,
  - parser invocation returns without outer die,
  - returned AST is `undef`,
  - inner eval error is present and reports syntax failure.
- Added helper `run_parser_with_captured_io` to capture parser invocation IO and inner eval diagnostics under exit-trap protection.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 14 top-level test blocks pass.

## 2026-02-23 - Phase 1 Validation Expansion: get_parser Mixed ACTION/BLIND CALL Exit Path
## Summary
Added regression coverage for explicit `exit 1` behavior when a spec rule mixes ACTION (`->`) and BLIND CALL (`=>`) blocks, and validated emitted diagnostics.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added subtest `get_parser_mixed_action_blind_call_trapped_exit`.
- Scenario:
  - create temporary spec where `Top` rule contains both `->` and `=>` flows.
  - invoke `LinkedSpec::get_parser` in a subprocess to isolate explicit `exit` behavior from the test harness.
- Asserts:
  - subprocess exits with code `1`,
  - diagnostics include incompatible ACTION/BLIND CALL message,
  - diagnostics include offending rule label and remediation guidance.
- Added helper `run_get_parser_in_subprocess` using `IPC::Open3` to capture stdout/stderr and exit status safely.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 15 top-level test blocks pass.

## 2026-02-23 - Phase 1 Validation Expansion: Parser Invalid-Input Runtime Behavior Lock
## Summary
Added regression coverage for parser invocation with intentionally invalid non-scalar-ref input to lock current runtime behavior under subprocess isolation.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added subtest `parser_invalid_input_returns_undef_without_exit`.
- Scenario:
  - invoke `LinkedSpec::get_parser('Lispish')` in subprocess,
  - pass helper second argument as string sentinel (`__INPUT_ARRAYREF__`),
  - convert sentinel to arrayref inside subprocess before parser invocation.
- Asserts:
  - subprocess exits with code `0`,
  - output contains `__AST_UNDEF__`,
  - output does not contain `__AST_DEFINED__`,
  - no handler-generation error banner is emitted,
  - parser creation marker confirms parser existed (`__NO_PARSER__` absent).
- Updated helper `run_parser_invocation_in_subprocess` to preserve string-only call API while allowing controlled non-scalar-ref injection in subprocess.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 16 top-level test blocks pass.

## 2026-02-23 - Phase 1 Hardening: get_parser Empty/Undefined Spec-Name Guard
## Summary
Added fail-fast guard behavior for invalid `get_parser` spec-name inputs (`undef`/empty string) and locked the behavior with non-fallback regression coverage.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- `LinkedSpec::get_parser` now validates the first argument before any local/fallback path resolution:
  - if spec name is `undef` or empty, emits `Invalid spec name` diagnostics and returns `undef`.
  - this prevents lazy fallback loading from being attempted for invalid-name calls.
- Added subtest `get_parser_empty_spec_name_reports_error_without_pathsearch`:
  - validates both `undef` and `''` inputs,
  - asserts no die, `undef` parser return, and invalid-name diagnostics,
  - asserts `PathSearch.pm` remains unloaded before and after these calls.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 17 top-level test blocks pass.

## 2026-02-23 - Phase 1 Validation Expansion: get_parser PathSearch-Load-Failure Negative Path
## Summary
Added regression coverage for the fallback-loader failure branch where `get_parser` cannot `require PathSearch`, and locked the diagnostic/error-return behavior.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added subtest `get_parser_pathsearch_load_failure_reports_error`.
- Scenario:
  - force fallback resolution with a unique missing spec name,
  - isolate module search path with temporary empty `@INC` so `require PathSearch` fails.
- Asserts:
  - `get_parser` returns without die,
  - returned parser is `undef`,
  - diagnostics include unresolved-spec error and `PathSearch load failed` details,
  - `PathSearch.pm` remains unloaded before and after the call.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 18 top-level test blocks pass.

## 2026-02-23 - Phase 1 Hardening: Skip PathSearch Fallback for Missing Explicit Paths
## Summary
Hardened `get_parser` to fail fast on unresolved path-like spec arguments (containing path separators) without loading `PathSearch`, and added regression coverage to lock the behavior.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `LinkedSpec::get_parser` path-resolution flow:
  - after local/module-relative resolution fails, path-like spec names now report `Spec path not found` directly,
  - fallback `require PathSearch` is skipped for these explicit-path misses.
- Added subtest `get_parser_missing_explicit_path_skips_pathsearch`:
  - calls `get_parser` with missing explicit file path,
  - asserts no die, `undef` return, and not-found diagnostics include requested path,
  - asserts `PathSearch.pm` remains unloaded before and after the call.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 19 top-level test blocks pass.

## 2026-02-23 - Phase 1 Hardening: Skip PathSearch Fallback for Missing .spec Basenames
## Summary
Hardened `get_parser` to treat unresolved `.spec`-suffixed arguments as explicit file-name misses and avoid `PathSearch` fallback loading for this case.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `LinkedSpec::get_parser`:
  - unresolved arguments ending in `.spec` now report `Spec path not found` directly,
  - fallback `require PathSearch` is skipped for these explicit `.spec` misses.
- Added subtest `get_parser_missing_dot_spec_name_skips_pathsearch`:
  - calls `get_parser` with a guaranteed-missing `<name>.spec`,
  - asserts no die, `undef` return, and not-found diagnostics include requested name,
  - asserts `PathSearch.pm` remains unloaded before and after the call.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 20 top-level test blocks pass.

## 2026-02-23 - Phase 1 Hardening: Trap PathSearch Runtime Failure in get_parser Fallback
## Summary
Hardened `get_parser` fallback flow to trap runtime exceptions thrown by `PathSearch->go`, return `undef`, and emit explicit diagnostics instead of propagating `die`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `LinkedSpec::get_parser` fallback resolution:
  - wrapped `PathSearch->go($spec_name, 'spec')` in `eval`,
  - on runtime exception, emits `Unable to resolve spec` + `PathSearch runtime failure` diagnostics and returns `undef`.
- Added subtest `get_parser_pathsearch_runtime_failure_reports_error`:
  - monkey-patches `PathSearch::go` to `die` with a sentinel marker,
  - asserts no outer die from `get_parser`, `undef` return, runtime-failure diagnostics, and sentinel propagation in captured diagnostics.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 21 top-level test blocks pass.

## 2026-02-23 - Phase 1 Validation Expansion: get_parser PathSearch-Resolved Missing-File Path
## Summary
Added regression coverage for the fallback branch where `PathSearch->go` returns a path string that does not exist on disk, and locked the resulting `Spec path not found` behavior.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added subtest `get_parser_pathsearch_returns_missing_file_reports_error`.
- Scenario:
  - monkey-patch `PathSearch::go` to return a deterministic non-existent `*.spec` path,
  - call `LinkedSpec::get_parser` with a missing spec name to force fallback resolution path.
- Asserts:
  - call returns without die,
  - parser return is `undef`,
  - diagnostics include `Spec path not found`,
  - diagnostics include both requested spec name and the resolved missing file path.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 22 top-level test blocks pass.

## 2026-02-23 - Phase 1 Hardening: get_parser Whitespace-Only Spec-Name Guard
## Summary
Hardened `get_parser` input validation so whitespace-only spec names are treated as invalid (same fail-fast behavior as `undef`/empty names), with regression coverage that confirms no fallback loader activity.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `LinkedSpec::get_parser` invalid-name gate:
  - validation now requires at least one non-whitespace character (`/\S/`),
  - whitespace-only names return `undef` with `Invalid spec name` diagnostics before resolution/fallback.
- Added subtest `get_parser_whitespace_spec_name_reports_error_without_pathsearch`:
  - checks both `'   '` and `" \\t\\n"` inputs,
  - asserts no die, `undef` return, and invalid-name diagnostics,
  - asserts `PathSearch.pm` remains unloaded before and after these calls.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 23 top-level test blocks pass.

## 2026-02-23 - Phase 1 Hardening: get_parser Non-Scalar Spec-Name Guard
## Summary
Hardened `get_parser` input validation to reject non-scalar spec-name arguments (e.g. references) with fail-fast diagnostics before any resolution/fallback behavior.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `LinkedSpec::get_parser` invalid-name gate:
  - now requires spec-name argument to be defined, non-reference, and contain at least one non-whitespace character.
  - non-scalar arguments now return `undef` with `Invalid spec name` diagnostics before resolution/fallback.
- Added subtest `get_parser_non_scalar_spec_name_reports_error_without_pathsearch`:
  - validates arrayref (`[]`) and hashref (`{}`) spec-name inputs,
  - asserts no die, `undef` return, and invalid-name diagnostics,
  - asserts `PathSearch.pm` remains unloaded before and after these calls.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 24 top-level test blocks pass.

## 2026-02-23 - Phase 1 Hardening: get_parser NUL-Byte Spec-Name Guard
## Summary
Hardened `get_parser` invalid-name validation to reject NUL-byte-containing spec names and added regression coverage to lock fail-fast behavior before any fallback loading.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `LinkedSpec::get_parser` invalid-name gate:
  - now rejects spec-name arguments containing `\0`,
  - NUL-byte-containing names return `undef` with `Invalid spec name` diagnostics before resolution/fallback.
- Added subtest `get_parser_nul_byte_spec_name_reports_error_without_pathsearch`:
  - validates `\"\0\"` and `"Lispish\0.spec"` inputs,
  - asserts no die, `undef` return, and invalid-name diagnostics,
  - asserts `PathSearch.pm` remains unloaded before and after these calls.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 25 top-level test blocks pass.

## 2026-02-23 - Phase 1 Validation Expansion: get_parser Non-Scalar Reference Variants
## Summary
Expanded invalid-input regression coverage for `get_parser` by locking behavior for additional non-scalar reference variants (scalarref, coderef, and regexp-ref).

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added subtest `get_parser_non_scalar_reference_variants_reports_error_without_pathsearch`.
- Scenarios:
  - scalar reference spec-name argument (`\$scalar`),
  - code reference spec-name argument (`sub { ... }`),
  - regexp reference spec-name argument (`qr/.../`).
- Asserts for each scenario:
  - `get_parser` returns without die,
  - parser return is `undef`,
  - diagnostics include `Invalid spec name`.
- Also asserts `PathSearch.pm` remains unloaded before and after these checks.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 26 top-level test blocks pass.

## 2026-02-23 - Phase 1 Hardening: Remove Duplicate PathSearch::go Fallback Call
## Summary
Fixed a fallback-resolution bug in `get_parser` where `PathSearch->go` was invoked twice (once inside eval guard and once again unguarded), and added regression coverage to lock single-call behavior.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Removed duplicate unguarded fallback call in `LinkedSpec::get_parser`:
  - retained the eval-wrapped `PathSearch->go` result assignment,
  - removed trailing second `PathSearch->go` invocation.
- Added subtest `get_parser_pathsearch_fallback_calls_go_once`:
  - monkey-patches `PathSearch::go` to count invocations and return a valid temporary spec path,
  - asserts `get_parser` returns without die and creates parser coderef,
  - asserts fallback resolver is called exactly once,
  - asserts parser invocation succeeds and returns AST.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 27 top-level test blocks pass.

## 2026-02-23 - Phase 1 Hardening: get_parser Leading/Trailing Whitespace Guard
## Summary
Hardened `get_parser` invalid-name validation so spec names with leading or trailing whitespace are rejected as invalid input before any resolution/fallback path.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `LinkedSpec::get_parser` invalid-name gate:
  - now rejects values matching leading or trailing whitespace (`/^\s|\s$/`),
  - padded names return `undef` with `Invalid spec name` diagnostics before fallback loader paths.
- Added subtest `get_parser_padded_spec_name_reports_error_without_pathsearch`:
  - validates `' Lispish'` and `'Lispish '` inputs,
  - asserts no die, `undef` return, and invalid-name diagnostics,
  - asserts `PathSearch.pm` remains unloaded before and after these calls.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 28 top-level test blocks pass.

## 2026-02-23 - Phase 1 Hardening: get_parser Control-Character Spec-Name Guard
## Summary
Hardened `get_parser` invalid-name validation to reject tab/newline/carriage-return control characters in spec names and locked behavior with targeted regression coverage.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `LinkedSpec::get_parser` invalid-name gate:
  - now rejects spec names containing `\t`, `\r`, or `\n`,
  - control-character names return `undef` with `Invalid spec name` diagnostics before resolution/fallback.
- Added subtest `get_parser_control_char_spec_name_reports_error_without_pathsearch`:
  - validates `"Lis\tpish"` and `"Lis\npish"` inputs,
  - asserts no die, `undef` return, and invalid-name diagnostics,
  - asserts `PathSearch.pm` remains unloaded before and after these calls.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 29 top-level test blocks pass.

## 2026-02-23 - Phase 1 Hardening: Generalized Control-Byte Spec-Name Validation
## Summary
Generalized `get_parser` invalid-name validation from specific control characters to all control bytes, and expanded regression coverage with additional non-whitespace control-byte cases.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `LinkedSpec::get_parser` invalid-name gate:
  - replaced targeted `\t/\r/\n` filter with a generalized control-byte check (`/[[:cntrl:]]/`),
  - this preserves prior behavior while covering additional control-byte variants.
- Added subtest `get_parser_additional_control_byte_spec_name_reports_error_without_pathsearch`:
  - validates `"Lis\apish"` (BEL) and `"Lis\x1Fpish"` (US) inputs,
  - asserts no die, `undef` return, and invalid-name diagnostics,
  - asserts `PathSearch.pm` remains unloaded before and after these calls.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 30 top-level test blocks pass.

## 2026-02-23 - Phase 1 Validation Expansion: get_parser Windows-Style Explicit Path Miss
## Summary
Added regression coverage to lock `get_parser` behavior for backslash-separated explicit path misses, ensuring fallback resolution is skipped and diagnostics remain stable.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added subtest `get_parser_missing_windows_style_path_skips_pathsearch`.
- Scenario:
  - pass a missing backslash-separated explicit path (e.g. `tmp_phase1_missing\\does_not_exist.spec`) into `get_parser`.
- Asserts:
  - call returns without die,
  - parser return is `undef`,
  - diagnostics include `Spec path not found` and requested path token,
  - `PathSearch.pm` remains unloaded before and after the call.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 31 top-level test blocks pass.

## 2026-02-23 - Phase 1 Hardening: get_parser Directory-Path Resolution Handling
## Summary
Hardened `get_parser` to explicitly handle resolved directory paths as a dedicated error case and expanded regression coverage for both explicit and fallback-resolved directory-path scenarios.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `LinkedSpec::get_parser`:
  - when an explicit path-like argument resolves to an existing directory, reports `Spec path is not a file` and returns `undef`,
  - retained existing not-found behavior for unresolved explicit paths.
- Added subtest `get_parser_explicit_directory_path_reports_error_without_pathsearch`:
  - validates explicit directory argument handling without fallback loading.
- Added subtest `get_parser_pathsearch_returns_directory_reports_error`:
  - monkey-patches `PathSearch::go` to return an existing directory path,
  - asserts no die, `undef` return, directory-path diagnostics, and single resolver invocation.
- Kept no-fallback/load-precondition checks stable by ordering PathSearch-loading subtests after no-PathSearch precondition subtests.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 33 top-level test blocks pass.

## 2026-02-23 - Phase 1 Hardening: Generalize get_parser Non-Regular Path Handling
## Summary
Generalized `get_parser` non-file path handling to treat any existing non-regular path as a dedicated not-a-file error, and expanded regression coverage for explicit and fallback-resolved non-regular paths.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Updated `LinkedSpec::get_parser` path handling:
  - explicit path-like inputs now report `Spec path is not a file` when the target exists but is not a regular file,
  - fallback-resolved paths now report the same not-a-file diagnostics for any existing non-regular path,
  - diagnostics include a `type` marker (`directory` or `non-regular`).
- Added subtest `get_parser_explicit_non_regular_path_reports_error_without_pathsearch`:
  - uses `File::Spec->devnull` as a stable existing non-regular explicit path,
  - asserts no die, `undef` return, not-a-file diagnostics with `type='non-regular'`,
  - asserts `PathSearch.pm` remains unloaded.
- Added subtest `get_parser_pathsearch_returns_non_regular_path_reports_error`:
  - monkey-patches `PathSearch::go` to return `File::Spec->devnull`,
  - asserts no die, `undef` return, not-a-file diagnostics with requested spec + resolved path + `type='non-regular'`,
  - asserts single fallback resolver invocation.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 35 top-level test blocks pass.

## 2026-02-23 - Phase 1 Validation Expansion: Explicit-Miss Bypass with PathSearch Already Loaded
## Summary
Added regression coverage to lock the invariant that explicit missing path inputs bypass `PathSearch::go` even when `PathSearch.pm` is already loaded in-process.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added subtest `get_parser_explicit_miss_bypasses_pathsearch_when_loaded`.
- Scenario:
  - force `PathSearch.pm` to be loaded,
  - monkey-patch `PathSearch::go` with a sentinel die and call counter,
  - invoke `get_parser` with:
    - a missing explicit path (`.../does_not_exist_loaded.spec`),
    - a missing `.spec` basename (`phase1_missing_dot_spec_loaded_<pid>.spec`).
- Asserts:
  - no die from `get_parser`,
  - both calls return `undef`,
  - diagnostics report `Spec path not found` and include requested tokens,
  - `PathSearch::go` call count remains `0` (bypass preserved).

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 36 top-level test blocks pass.

## 2026-02-23 - Phase 1 Validation Expansion: Explicit-Miss Bypass with Preloaded PathSearch
## Summary
Added a dedicated regression lock confirming that explicit missing-path inputs continue to bypass `PathSearch::go` even when `PathSearch.pm` is already loaded in-process.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added subtest `get_parser_explicit_miss_bypasses_pathsearch_when_loaded`.
- Scenario:
  - preload `PathSearch.pm`,
  - monkey-patch `PathSearch::go` with a sentinel die and call counter,
  - invoke `get_parser` with both:
    - missing explicit path (`.../does_not_exist_loaded.spec`),
    - missing `.spec` basename (`phase1_missing_dot_spec_loaded_<pid>.spec`).
- Asserts:
  - no die from `get_parser`,
  - both calls return `undef`,
  - diagnostics report `Spec path not found` and include requested tokens,
  - `PathSearch::go` call count remains `0`.

## Validation
- Ran:
  - `prove -v -Iperl t/phase0_regression.t`
- Result:
  - PASS
  - all 36 top-level test blocks pass.
