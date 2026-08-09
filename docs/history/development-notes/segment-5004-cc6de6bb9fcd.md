- 2026-04-22: Deleted the single-use `LinkedSpec::OwnerDispatch` `$@`-preservation wrapper from `BootstrapSpec/Core.pm`. The meaningful local seams there are still `_linkedre_or(...)` and `_linkedre_ored_re(...)`, and both now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a local `_call_preserving_err(...)` subdef that only forwarded the same successful-eval-preservation behavior. Phase0 now locks that slimmer bootstrap-core helper shape.
- 2026-04-22: Deleted the generic `LinkedSpec::OwnerDispatch` package-loader wrapper from `ActionIR/StatementSplit/Core.pm`. The meaningful local seams there are `_require_statement_split_mode_pkg(...)` and `_require_method_expr_pkg(...)`, and both now spend `OwnerDispatch::require_pkg(...)` directly instead of bouncing through a local `_require_pkg(...)` subdef that only forwarded the same lazy-load call. Phase0 now locks that slimmer statement-split-core source shape.
- 2026-04-22: Deleted the generic `LinkedSpec::OwnerDispatch` package-loader wrapper from `RuleIR/EmitContext.pm`. The meaningful local seam there is `_actionir_owner_package(...)`, and it now spends `OwnerDispatch::require_pkg(...)` directly instead of bouncing through a local `_require_pkg(...)` subdef that only forwarded the same lazy-load call. Phase0 now locks that slimmer emit-context owner-registry shape.
- 2026-04-22: Deleted the generic `LinkedSpec::OwnerDispatch` callback-loader wrappers from `Compiler.pm` and `SpecEntry.pm`. Those compile-path owners still keep their named bootstrap/spec-entry/validation and RuleIR/emit-context helper seams, but those helpers now spend `OwnerDispatch::require_pkg_cb(...)` directly instead of bouncing through a local `_require_pkg_cb(...)` subdef that only forwarded the call. Phase0 now locks that slimmer callback-loader shape.
- 2026-04-22: Deleted the generic `LinkedSpec::OwnerDispatch` package-loader wrappers from `Compiler.pm`, `SpecEntry.pm`, and `RuleIR.pm`. Those compile-path owners still keep their meaningful Trace / `Data::Dumper` / `LinkedRE` helper seams, but those helpers now spend `OwnerDispatch::require_pkg(...)` directly instead of bouncing through a local `_require_pkg(...)` subdef that only forwarded the call. Phase0 now locks that slimmer compile-path shape.
- 2026-04-22: Deleted the last single-use generic `LinkedSpec::OwnerDispatch` package-loader wrappers from `BootstrapSpec/Core.pm`, `ActionIR/ScannerCore.pm`, and `PluginBridge.pm`. Those owners still keep their meaningful local helper seams (`_require_linkedre_pkg(...)`, `_scanner_dispatchers(...)`, and `_load_legacy_plugin_runtime(...)`), but the live bodies now spend `OwnerDispatch::require_pkg(...)` directly instead of bouncing through a generic `_require_pkg(...)` subdef with only one caller. Phase0 now locks that slimmer support-owner shape.
- 2026-04-22: Deleted the local `LinkedSpec::OwnerDispatch` pass-through wrappers from `ActionIR/Scanner.pm`. The scanner owner still keeps `_require_scanner_core_pkg(...)` as the meaningful local seam, but that helper plus `default_deps_for_package(...)` and `scan_contract_ir_events(...)` now spend `OwnerDispatch` directly instead of bouncing through local `_require_pkg_cb(...)` / `_call_preserving_err(...)` wrappers whose only job was to forward one internal call. Phase0 now locks that slimmer scanner-owner shape.
- 2026-04-22: Deleted the local `LinkedSpec::OwnerDispatch` pass-through wrappers from `Resolver.pm`. Its trace helper entrypoints now spend `OwnerDispatch` directly for Trace loading and successful `$@` preservation, so the remaining parser-factory resource-resolution owner no longer keeps a separate `_require_trace_pkg(...)` / `_call_preserving_err(...)` layer whose only callers were those three helper bodies. Phase0 now locks that source shape.
- 2026-04-22: Deleted one-shot local `LinkedSpec::OwnerDispatch` pass-through wrappers from `Runtime.pm`, `BootstrapSpec.pm`, and `ParserFactory.pm`. Those owners still keep their named orchestration helpers, but the live bodies now spend `OwnerDispatch` directly for the one-use compiler callback lookup, bootstrap-core callback lookup, and `$@`-preservation seams instead of keeping wrapper subdefs whose only job was to forward a single internal call. Phase0 now locks that slimmer source shape.
- 2026-04-22: Hardened `LinkedSpec::OwnerDispatch` lazy owner loading against later `chdir(...)`. Its bootstrap `@INC` seed is now absolute rather than repo-root-relative, so file-oriented parser paths such as `get_parser(...)` keep finding lazily loaded owners (`ParserFactory`, `RuntimeContext`, and deeper compile/runtime modules) even when tests or callers change directories after the initial `require LinkedSpec`.
- 2026-04-22: Deleted single-use local `LinkedSpec::OwnerDispatch` wrappers from `Trace.pm`, `Validation.pm`, `ActionIR/CanonicalEvents.pm`, and `ActionIR/StatementSplit.pm`. Those wrappers were no longer meaningful seams; each existed only to forward one internal helper call. The live helper bodies now spend `OwnerDispatch` directly, and phase0 locks that source shape.
- 2026-04-22: Deleted another small set of dead `LinkedSpec::OwnerDispatch` pass-through wrappers from `Runtime.pm`, `BootstrapSpec.pm`, `ActionIR/Scanner.pm`, and `RuleIR/EmitContext.pm`. In these owners the real live seams were already the callback-loader or owner-registry paths, so the leftover local `_require_pkg(...)` / `_require_trace_pkg(...)` helpers had become unused scaffolding rather than meaningful architecture. Phase0 now locks those wrappers out at the source level.
- 2026-04-22: Deleted dead local `LinkedSpec::OwnerDispatch` pass-through wrappers from the dep-map-only ActionIR owners `RewritePipeline`, `Diagnostics`, `ValueExpr`, `FlowExpr`, `ArrayPipeline`, `ControlFlow`, `Contracts`, `MethodLowering`, and `DeclareMethod`. Those owners already spent `LinkedSpec::OwnerDispatch::build_dep_map(...)` directly for their active dependency wiring, so the leftover `_require_pkg(...)` and `_call_preserving_err(...)` subdefs had become unused scaffolding rather than real seams. Phase0 now locks the absence of those wrapper bodies at the source level.
- 2026-04-21: Deleted dead local `LinkedSpec::OwnerDispatch` pass-through wrappers from `perl/LinkedSpec.pm` and `perl/LinkedSpec/ParserFactory.pm`. Those files were already spending the shared owner-dispatch seam directly on their active paths, so the leftover `_require_pkg(...)`, `_call_preserving_err(...)`, `_require_pkg_cb(...)`, and `_require_pkg_value(...)` subdefs had become unused compatibility scaffolding rather than real architecture. Phase0 now locks both the missing wrapper bodies and the preserved `$@` contract on direct `OwnerDispatch` package/callback/value lookup for ParserFactory-owned paths.
- 2026-04-18: Deleted the legacy `getop_plugin_list` compatibility subdef from `plugin/fsmgen.plg`. Repo-owned FSM plugin-list parsing was already using `FSMGen::getop_plugin_list(...)` directly, so the old helper name left the shipped plugin registry and regression now locks both the missing coderef in `fsmgen.plg` and the absence of bare `getop_plugin_list(...)` calls across repo-owned plugin files.
- 2026-04-18: Deleted the legacy `add_header_n_context_clause` compatibility subdef from `plugin/fsmgen.plg`. Repo-owned RTL/FSM generation was already calling `RTLUtils::add_header_n_context_clause(...)` directly, so the old helper name left the shipped plugin registry and regression now locks both the missing coderef in `fsmgen.plg` and the absence of bare `add_header_n_context_clause(...)` calls across repo-owned plugin files.
- 2026-04-18: Deleted `plugin/tcl4interconn.plg` now that the earlier `QC::TclInterconn` extraction has no remaining repo-owned legacy-name callers. `plugin/qcflow.plg::glc_xcel2hm` was already calling `append_interconnect_tcl(...)`, `load_fanx(...)`, and `fanx_info(...)` directly, so the standalone wrapper left the shipped `.plg` corpus and regression now locks the absence of bare `tcl4interconn(...)`, `tcl4fanx(...)`, and `get_fanxinfo(...)` action calls in repo-owned plugin files.
- 2026-04-18: Extracted the visible `tssio` report/action body out of `plugin/tssio.plg` and into `perl/Timing/SetupHold.pm` as `Timing::SetupHold::write_tssio(...)`. At that point the legacy `.plg` entry became only a thin compatibility wrapper; a later 2026-04-30 cleanup deleted that wrapper. The package owner preserves `tssio.lof`, per-path `sta_<n>.lof` sheets, historical banner/error strings, and internal workbook-link formatting without loading `PPlugin`.
- 2026-04-18: Extracted the STAN OMAP2430C backend report writers `potential_fp`, `questionable_paths`, and `freqency_summary` out of `plugin/stan_omap2430c_backend.plg` and into `perl/Timing/StanOmap2430cBackend.pm` as `Timing::StanOmap2430cBackend::write_potential_fp(...)`, `write_questionable_paths(...)`, and `write_frequency_summary(...)`. The visible `.plg` entries remain thin compatibility wrappers, so the timing-domain owner now carries all repo-owned STAN OMAP helper/report bodies while preserving the historical LOF filenames, section markers, and visible legacy action names.
- 2026-04-17: Moved the FSMGen dynamic plugin-list parser out of `plugin/fsmgen.plg::getop_plugin_list` and into `perl/FSMGen.pm` as `FSMGen::getop_plugin_list(...)`. At that step the legacy `.plg` entry remained as a thin package-owner wrapper; the newer 2026-04-18 note above records that the obsolete wrapper has since been deleted. The package owner preserves `+type=plugin#args...` bucket construction, the default `LinkedSpec::get_plugin(...)` resolver, and the unresolved-name no-op fallback. Tests can inject a resolver directly, so this path no longer needs the legacy plugin runtime just to verify the parser behavior.
- 2026-04-17: Extracted the QC flow Tcl/FANX helper trio out of legacy callback lookup and into `perl/QC/TclInterconn.pm`. `plugin/qcflow.plg::glc_xcel2hm` now calls `QC::TclInterconn::append_interconnect_tcl(...)`, `load_fanx(...)`, and `fanx_info(...)` directly instead of resolving `tcl4interconn`, `tcl4fanx`, or `get_fanxinfo` through `LinkedSpec::get_plugin(...)`; the newer 2026-04-18 note above records that the temporary `plugin/tcl4interconn.plg` compatibility wrapper has since been deleted.
- 2026-04-17: Extracted the RTL/FSM VHDL header/context-clause helper out of plugin dispatch and into `perl/RTLUtils.pm` as `RTLUtils::add_header_n_context_clause(...)`. `RTLUtils` entity/architecture generation and `FSMGen.pm` package code now call that owner directly, while the newer 2026-04-18 note above records that the temporary `plugin/fsmgen.plg::add_header_n_context_clause` compatibility wrapper has since been deleted. This advances the earlier `run_plugin(...)` transition path into the preferred package-owner end state for repo-owned header generation.
- 2026-04-17: Re-ran the README/SESSION_BOOTSTRAP bootstrap pass and refreshed `ARCHITECTURE_STATE.md` to keep the root owner tree aligned with the code-backed model: `LinkedSpec::CompilerState` now appears under the compiler path in the tree diagram, and the `PluginBridge` section records that its default dependency callback map is assembled through `LinkedSpec::OwnerDispatch::build_dep_map(...)`.
- 2026-04-17: Routed `LinkedSpec::PluginBridge::_default_deps()` through `LinkedSpec::OwnerDispatch::build_dep_map(...)` instead of hand-building another local callback map. The bridge still owns the transition policy, but default registered-plugin lookup, legacy runtime loading, legacy lookup, and legacy exec callbacks are now assembled through the same shared dependency-map helper used by the other owner surfaces.
- 2026-04-17: Removed dead local `_require_pkg_cb(...)` wrappers from the ActionIR owners whose `default_deps_for_package(...)` methods already delegate dependency callback resolution straight to `LinkedSpec::OwnerDispatch::build_dep_map(...)`: `ArrayPipeline`, `CanonicalEvents`, `Contracts`, `ControlFlow`, `DeclareMethod`, `Diagnostics`, `FlowExpr`, `MethodLowering`, `RewritePipeline`, `StatementSplit`, and `ValueExpr`. `ActionIR::Scanner` keeps its local wrapper because it still uses it to load `ScannerCore` directly.
- 2026-04-17: Routed `LinkedSpec::RuleIR::EmitContext` ActionIR owner callback lookup through `LinkedSpec::OwnerDispatch::require_pkg_cb(...)` instead of local `Package->can(...)` probes. EmitContext still owns the ActionIR owner-key registry and wrapper shape, but callback resolution now uses the same shared loader as dependency maps, delegated owner calls, and the other thin wrappers.
- 2026-04-17: Extracted the RTL memory-wrapper `get_log2` address-width helper out of `plugin/generic_fake_memory_module.plg` and into `perl/RTLUtils.pm` as `RTLUtils::ceil_log2(...)`. `plugin/generic_fake_memory_module.plg` and `plugin/wrapgen.plg` now call that package owner directly for memory address bus sizing instead of relying on an unqualified helper subdef shared through the legacy plugin registry.
- 2026-04-17: Extracted the STAN/report-timing backend `minmax_clockmx_cellcode` clock-matrix summary cell formatter out of `plugin/stan_backend.plg` and into `perl/Timing/StanBackend.pm` as `Timing::StanBackend::clock_matrix_cell_code(...)`. The visible `clockmatrix` action still lives in the legacy `.plg` corpus for now, but the per-cell first-100 sheet allocation, min/max slack sorting, and summary workbook link text no longer depend on a same-file helper subdef or dynamic plugin registration.
- 2026-04-17: Extracted the QC flow `qcflow_qclogdata` qclog table-preparation helper out of `plugin/qcflow.plg` and into `perl/QC/Flow.pm` as `QC::Flow::prepare_qclog_data(...)`. The visible `glc_xcel2hm` action now calls that package owner directly in both the qclib/noctslib and CSV-only paths instead of resolving a same-file plugin helper, preserving configured filter dispatch, XCEL2HM row-link rewriting, qclog table index mapping, and `_qclogdata_a` preparation while keeping `QC::Flow` free of plugin lookup and `PPlugin`.
- 2026-04-17: Extracted the QC flow `qcflow_links_n_qclog` qclog workbook/link writer out of `plugin/qcflow.plg` and into `perl/QC/Flow.pm` as `QC::Flow::write_qclog_links(...)`. The visible `glc_xcel2hm` action now calls that package owner directly in both the qclib/noctslib and CSV-only paths instead of resolving a same-file plugin helper, preserving workbook creation, qclog/link sheet writes, optional clock CTS link insertion, and `$qconf->{_logallocate}` storage while keeping `QC::Flow` free of plugin lookup and `PPlugin`.
- 2026-04-17: Extracted the QC flow `qcflow_clock_ctsinfo` clock CTS summary helper out of `plugin/qcflow.plg` and into `perl/QC/Flow.pm` as `QC::Flow::clock_cts_info(...)`. The visible `glc_xcel2hm` action now calls that package owner directly instead of resolving a same-file plugin helper, preserving CTS range aggregation, min/max violation formatting, and `$qconf->{_ctsinfo_rca}` allocation while keeping `QC::Flow` free of plugin lookup and `PPlugin`.
- 2026-04-17: Extracted the QC flow `qcflow_filter_handler` filter-expression helper out of `plugin/qcflow.plg` and into `perl/QC/Flow.pm` as `QC::Flow::filter_handler(...)`. The visible `glc_xcel2hm` action now stores that package coderef in `$qconf->{_filter_handler}` instead of resolving a same-file plugin helper, preserving scalar passthrough and array-to-grouped-OR formatting while keeping `QC::Flow` free of plugin lookup and `PPlugin`.
- 2026-04-17: Extracted the QC flow `qc_budget_check` traversal callback and `qc_budget_check_01match_code` helper out of `plugin/qcflow.plg` and into `perl/QC/Flow.pm` as `QC::Flow::budget_check(...)` and `budget_check_single_or_zero_match(...)`. The visible `glc_xcel2hm` action still lives in the legacy `.plg` corpus for now, and later QC flow qclog-data/link helpers still had dynamic lookups to unwind at that point, but the budget-check recursion no longer resolves same-file helpers through `LinkedSpec::get_plugin(...)`. The remaining `get_fanxinfo` callback is resolved at the visible action boundary and passed into `QC::Flow`, keeping the package owner clear of plugin lookup and `PPlugin`.
- 2026-04-17: Extracted the QC flow `qc_pushonce` duplicate-suppressed qclog insertion helper out of `plugin/qcflow.plg` and into `perl/QC/Flow.pm` as `QC::Flow::push_once(...)`. The visible `glc_xcel2hm` action still lives in the legacy `.plg` corpus for now, and later QC flow qclog-data/link helpers still had dynamic lookups to unwind at that point, but its push-once qclog accumulator no longer resolves `LinkedSpec::get_plugin('qc_pushonce')` or exposes `qc_pushonce` as a dynamic plugin subdef.
- 2026-04-17: Extracted the STAN OMAP2430C backend `drive_nopath_check` writer and `nopath_check` traversal callback out of `plugin/stan_omap2430c_backend.plg` and into `perl/Timing/StanOmap2430cBackend.pm` as `Timing::StanOmap2430cBackend::write_no_path_check(...)` and `record_no_path_check(...)`. The package owner now passes an explicit output filehandle through `HUtils::Recurse(...)` instead of relying on the legacy shared `CHECK` handle, and the former helper subdefs are no longer dynamic plugin registrations or resolved through `LinkedSpec::get_plugin(...)`. This completed the then-identified private STAN OMAP callback extraction cluster; a later 2026-04-18 slice moved the remaining visible report-writer bodies into the same package owner too.
- 2026-04-17: Extracted the STAN OMAP2430C backend `drive_tckdelays` DM-measures writer out of `plugin/stan_omap2430c_backend.plg` and into `perl/Timing/StanOmap2430cBackend.pm` as `Timing::StanOmap2430cBackend::write_tck_delays(...)`. The visible `dm_measures` action still lives in the legacy `.plg` corpus for now, but TCK-delay output no longer resolves `LinkedSpec::get_plugin('drive_tckdelays')` or exposes `drive_tckdelays` as a dynamic plugin subdef. The package writer preserves `stan_tcksegments.lof`, per-segment sheet naming, workbook links, and `consolidated_ns` path-sheet sections.
- 2026-04-16: Extracted the STAN OMAP2430C backend `stafrequency` traversal callback out of `plugin/stan_omap2430c_backend.plg` and into `perl/Timing/StanOmap2430cBackend.pm` as `Timing::StanOmap2430cBackend::collect_sta_frequency(...)`. The visible `old_default` action still lives in the legacy `.plg` corpus for now, but STA-frequency classification no longer resolves `LinkedSpec::get_plugin('stafrequency')` or exposes `stafrequency` as a dynamic plugin subdef. The package callback preserves the historical good-path frequency accumulation, negative-period/questionable path handling, and potential false-path collection.
- 2026-04-15: Extracted the STAN OMAP2430C backend `portiming` traversal callback out of `plugin/stan_omap2430c_backend.plg` and into `perl/Timing/StanOmap2430cBackend.pm` as `Timing::StanOmap2430cBackend::filter_port_timing_paths(...)`. The visible `old_default` action still lives in the legacy `.plg` corpus for now, but setup/hold port filtering no longer resolves `LinkedSpec::get_plugin('portiming')` or exposes `portiming` as a dynamic plugin subdef. The new package callback lazy-loads `TableGrep` at use time, preserving package `require` without forcing the legacy plugin runtime, and it keeps the historical input/startpoint and output/endpoint filter expression behavior.
- 2026-04-14: Hosted GitHub Actions CI is disabled to preserve account Actions minutes. `.github/workflows/ci.yml` no longer has `push` or `pull_request` triggers and its only remaining manual-dispatch job is guarded with `if: ${{ false }}`. Keep the file tracked because `tools/run_ci_local.sh` audits it and because it documents the hosted wrapper to re-enable later. The canonical gate during the pause is `bash tools/run_ci_local.sh`; re-enable hosted CI by restoring the automatic triggers and removing the disabled job guard.
- 2026-04-13: Extracted the STAN OMAP2430C backend frequency-detail helper family out of `plugin/stan_omap2430c_backend.plg` and into `perl/Timing/StanOmap2430cBackend.pm`. The visible `old_default` action still lives in the legacy `.plg` corpus for now, but it no longer resolves `freqency_detailed`, `freqency_detailed_paths`, `drive_freqency_detailed`, or `get_freqency_detailed_fname` through `LinkedSpec::get_plugin(...)`; it calls `Timing::StanOmap2430cBackend::record_frequency_detail(...)`, `write_frequency_detail_paths(...)`, `write_frequency_detail(...)`, and `frequency_detail_filename(...)` through direct package coderefs. Later slices moved `portiming`, `stafrequency`, `drive_tckdelays`, and `nopath_check` into the same package owner. The package keeps historical LOF section strings and data keys where they are file/data contracts, but the callable API uses corrected frequency-detail names instead of carrying the old misspelling forward as a public owner surface.
- 2026-04-13: Extracted the STAN/report-timing backend setup helper out of `plugin/stan_backend.plg` and into `perl/Timing/StanBackend.pm` as `Timing::StanBackend::start(...)`. The visible `stan_backend.plg` actions still live in the legacy `.plg` corpus for now, but they no longer expose `stan_backend_start` as a dynamic plugin subdef, and `plugin/skew.plg` plus `plugin/duty_cycle_degradation.plg` now call the package owner directly instead of relying on `LinkedSpec::get_plugin('stan_backend_start')` or an unqualified helper call. This continues the mixed-legacy-file cleanup pattern: private setup behavior should move to a named domain owner while visible legacy actions remain only as long as real callers need them.
- 2026-04-12: Extracted setup/hold timing math out of legacy `.plg` helper registrations and into `perl/Timing/SetupHold.pm`. `plugin/setup_hold_tmax_tmin.plg` now calls `Timing::SetupHold::collect_dxcy(...)`, the then-current `plugin/tssio.plg` body called `Timing::SetupHold::tss_setup_hold_delay(...)`, `tss_tmax_tmin_delay(...)`, and `calculate_path_delay(...)`, and the former helper subdefs `DxCy`, `DiCi`, `DiCo`, `DoCi`, `DoCo`, `tss_setup_hold`, and `tss_tmax_tmin` are no longer exposed as dynamic plugin registrations. The package owner also makes the timing configuration explicit when `collect_dxcy(...)` dispatches to a delay formula, which corrects the old same-file dynamic-helper path where the helper formulas declared `$conf` but the traversal call did not pass it. A later 2026-04-18 slice moved the full `tssio` action body into `Timing::SetupHold::write_tssio(...)` too.
- 2026-04-12: Extracted the internal QC summary merge helper out of `plugin/qc_summary.plg` and into `perl/QC/Summary.pm` as `QC::Summary::append_merged_rows(...)`. The visible `qc_summary` action still lives in the legacy `.plg` corpus for now, but it no longer resolves its own helper via `LinkedSpec::get_plugin('qc_summary_merge')`, and `qc_summary_merge` is no longer exposed as a legacy plugin subdef. This is the next cleanup shape for mixed legacy files: if a subdefinition is really private implementation detail, move it to a package owner instead of keeping it in the dynamic plugin registry.
- 2026-04-12: Graduated HTTP file-access behavior out of the plugin namespace after the `.plg` wrapper removal. `perl/Plugin/HTTP.pm` is gone; `perl/HTTP/FileAccess.pm` now owns `url_for_path(...)`, `set_hostport(...)`, `set_localhost(...)`, `print_file_links_for_conf(...)`, `run_lighttpd_for_conf(...)`, and `run_httpd_for_conf(...)`; and `TableScript`, `HTML::PathLinks`, `Text::VariableSubstitution`, `rtl.plg`, `stan_backend.plg`, plus `tree.plg` call `HTTP::FileAccess` directly. This retires the historical `httplink(...)`, `set_http_hostport(...)`, and `set_http_localhost(...)` helper names in current repo-owned usage and removes the last live `Plugin::*` implementation owner.
- 2026-04-12: Graduated path-token link rendering out of the plugin namespace after the `.plg` wrapper removal. `perl/Plugin/CGI.pm` is gone; `perl/HTML/PathLinks.pm` now owns `link_path_tokens(...)`; and `Text::VariableSubstitution::var_subst_test(...)` calls `HTML::PathLinks::link_path_tokens(...)` directly. This also retires the historical `file_list_path2http(...)` helper name in current repo-owned usage: the behavior renders HTML anchors for path-like tokens, not a CGI plugin action.
- 2026-04-12: Graduated string substitution out of the plugin namespace after the `.plg` wrapper removal. `perl/Plugin/String.pm` is gone; `perl/Text/VariableSubstitution.pm` now owns `var_subst(...)` and `var_subst_test(...)`; at that step the remaining path-link dependency still lived in `Plugin::CGI::file_list_path2http(...)`, and the newer note above records that current path-link rendering now lives in `HTML::PathLinks`. This follows the same rule as `InteractivePrompt`, `VHDL::ConstantEval`, `MSOffice::Excel`, and `Table::GenericFilter`: once the compatibility wrapper is gone and the behavior has a clearer domain, do not leave it under `Plugin::*` just because that is where the extraction first landed.
- 2026-04-12: Graduated GenericFilter table grouping out of the plugin namespace after the `.plg` wrapper removal. `perl/Plugin/GenericFilter.pm` is gone; `perl/Table/GenericFilter.pm` now owns `dispatch(...)`, `group_by(...)`, `group_by_port(...)`, `group_by_ioclock(...)`, and `group_byRE(...)`; and `HUtils::GenericFilter(...)` / `TableSort::GenericFilter(...)` call `Table::GenericFilter::dispatch(...)` directly. This keeps the behavior close to the table stack (`TableGrep`, `TableSort`, `HUtils` table recursion) instead of leaving it on the plugin migration shelf.
- 2026-04-12: Graduated the Excel automation helper out of the plugin namespace after the `.plg` wrapper removal. `perl/Plugin/MSOffice.pm` is gone; `perl/MSOffice/Excel.pm` now owns `start(...)`; and `plugin/spyglass.plg::spyglass_waive` calls `MSOffice::Excel::start()` directly. This follows the same rule as `InteractivePrompt` and `VHDL::ConstantEval`: `Plugin::*` is a temporary extraction shelf, not a final resting place when the behavior has a clearer domain owner.
- 2026-04-12: Graduated the VHDL constant helpers out of the plugin namespace after the `.plg` wrapper removal. `perl/Plugin/VHDLConst.pm` is gone; `perl/VHDL/ConstantEval.pm` now owns `evaluate_constant_values(...)`, `substitute_hash_values(...)`, and `print_constant_values_for_conf(...)`; and `plugin/mbist.plg` / `plugin/regtest.plg` call `VHDL::ConstantEval` directly. This is the next concrete example after `InteractivePrompt`: `Plugin::*` is useful as a migration shelf, but it should not become the resting place when the behavior has an obvious domain owner.
- 2026-04-11: Graduated the prompt helper out of the plugin namespace immediately after the `.plg` extraction. `perl/Plugin/Prompt.pm` is gone; `perl/InteractivePrompt.pm` now owns `yes_no(...)`, and `plugin/fxenv_helper.plg` calls `InteractivePrompt::yes_no(...)` directly. Treat `Plugin::*` owners as tactical migration scaffolding, not a permanent home when a clearer non-plugin domain owner exists.
- 2026-04-11: Deleted `plugin/yesno.plg` after moving the interactive yes/no prompt helper into `Plugin::Prompt::yes_no(...)`. `plugin/fxenv_helper.plg` now calls the package owner directly, empty input still defaults to "yes", and the package owner fixes the historical no-branch array-callback typo instead of preserving it behind the legacy `.plg` parser.
- 2026-04-11: Deleted `plugin/vhdconst_eval.plg` after moving VHDL constant extraction and hash-value substitution into the then-current `Plugin::VHDLConst` migration scaffold. That step moved `plugin/mbist.plg` and `plugin/regtest.plg` off bare helper calls / `LinkedSpec::run_plugin('hvalue_substitute', ...)`; the newer 2026-04-12 note above records that the scaffold has since graduated to `VHDL::ConstantEval`.
- 2026-04-11: Deleted `plugin/msoffice.plg` after moving its only repo-owned caller, `plugin/spyglass.plg::spyglass_waive`, to the then-current `Plugin::MSOffice::excel_start(...)` migration scaffold. That step kept the historical active Excel instance preference and lazy `Win32::OLE` boundary while avoiding a permanent `excel_start` plugin registration with no internal caller; the newer 2026-04-12 note above records that the scaffold has since graduated to `MSOffice::Excel::start(...)`.
- 2026-04-11: Deleted `plugin/table.plg` after moving the last repo-owned unqualified `list_2table(...)` callers in `plugin/generic_fake_memory_module.plg`, `plugin/lte_digital_rf.plg`, and `plugin/spyglass.plg` to `Table::list2table(...)` directly. The deleted wrapper's `table_2ss` sibling action had no repo-owned caller, so there was no concrete compatibility surface to preserve. Future utility-style `.plg` wrappers should be removed once callers can name the real package owner directly, especially when the wrapper only re-exports a normal module function.
- 2026-04-11: Deleted the one-line `plugin/plugin.plg` dynamic lookup shim after moving its remaining repo-owned caller, `plugin/fsmgen.plg::getop_plugin_list`, to `LinkedSpec::get_plugin($name) // sub {}` directly. The newer 2026-04-17 note above records that this parser has since moved one step further into `FSMGen::getop_plugin_list(...)` while preserving that default resolver and no-op fallback. Future dynamic callback lookup inside shipped legacy plugin files should call `LinkedSpec::get_plugin(...)` explicitly or move to a normal package owner, not route through a generic `plugin(...)` helper action.
- 2026-04-11: Deleted the one-line `plugin/spec.plg` `_get_parser` compatibility shim. Repo-owned parser lookup had already moved to `LinkedSpec::get_parser(...)` in `Lispish.pm`, `plugin/ds_vhistory.plg`, `plugin/fsmgen.plg`, and `plugin/regtest.plg`, so keeping a permanent `.plg` wrapper would preserve legacy plugin indirection after the concrete internal need was gone. Future parser lookup should remain a direct `LinkedSpec::get_parser(...)` / `LinkedSpec::Get(...)` concern, not a plugin action.
- 2026-04-11: Moved the historical `httpd` action out of the legacy `.plg` registry and into the then-current `Plugin::HTTP::run_httpd_for_conf(...)` scaffold. This action was already practically stale because `conf/httpd.conf` had been intentionally removed earlier, but the behavior was still preserved behind an explicit package owner for callers that provide a valid `Global->httpd_conf`. The package substituted server name, port, and author email, wrote and closed a generated temp config, validated port/action input, and used list-form `system('apachectl', '-k', $action, '-f', $filename)` instead of shell-string execution. `plugin/httpd.plg` was deleted rather than kept as a permanent wrapper; the newer note above records that current HTTP file access now lives in `HTTP::FileAccess`.
- 2026-04-11: Moved the remaining real `lighttpd` action out of the legacy `.plg` registry and into the then-current `Plugin::HTTP::run_lighttpd_for_conf(...)` scaffold. The package owner read `Global->lighttpd_conf`, substituted host/port placeholders, wrote and closed a generated temp config, validated the port, and used list-form `system('lighttpd', '-f', $filename)` instead of the old shell-string invocation. `plugin/lighttpd.plg` was deleted rather than kept as a permanent wrapper; the newer note above records that current HTTP file access now lives in `HTTP::FileAccess`.
- 2026-04-11: Moved the remaining real `http` action out of the legacy `.plg` registry and into the then-current `Plugin::HTTP::print_file_links_for_conf(...)` scaffold. The package owner covered URL signing, CGI config lookup, host/port setup, and existing-file filtering for that historical action directly, so `plugin/http.plg` was deleted rather than kept as a permanent wrapper. At that moment `plugin/lighttpd.plg` still carried the real `lighttpd` legacy action; the newer note above records that current HTTP file access now lives in `HTTP::FileAccess`.
- 2026-04-11: Removed the next pure package-backed `.plg` helper wrappers instead of preserving compatibility surfaces with no repo-owned caller. `plugin/string.plg` was gone once the then-current `Plugin::String` scaffold owned `var_subst(...)` / `var_subst_test(...)`, and `plugin/genericfilter.plg` was removed after the then-current `Plugin::GenericFilter` scaffold took over the GenericFilter behavior. Regression coverage locks wrapper absence and keeps behavior coverage on package owners themselves; the newer 2026-04-12 notes above record that current string substitution now lives in `Text::VariableSubstitution` and GenericFilter now lives in `Table::GenericFilter`.
- 2026-04-11: Earlier in the HTTP helper-retirement path, repo-owned legacy actions in `plugin/http.plg`, `plugin/rtl.plg`, `plugin/stan_backend.plg`, and `plugin/tree.plg` were moved to the then-current `Plugin::HTTP::httplink(...)`, `Plugin::HTTP::set_http_hostport(...)`, or `Plugin::HTTP::set_http_localhost(...)` scaffold instead of relying on unqualified helper names registered through legacy plugin discovery. That left `plugin/http.plg` and `plugin/lighttpd.plg` carrying only real legacy actions at that moment; the newer notes above record that current HTTP file access now lives in `HTTP::FileAccess`.
- 2026-04-11: Took the plugin-removal direction one step past extraction by deleting the obsolete `plugin/cgi.plg` compatibility wrapper. `Plugin::CGI::file_list_path2http(...)` then owned all repo-owned usage directly, the then-current string substitution owner already called it as a normal package function, and no repo-owned code still needed `file_list_path2http` as a legacy plugin-registration name. Future plugin work should not create a `.plg` shadow by default after a `.pm` owner exists; keep a wrapper only while a concrete repo-owned legacy caller still needs that name.
- 2026-04-11: Continued the plugin/resource modernization track by extracting the generic table grouping plugin body into the then-current `Plugin::GenericFilter` migration scaffold. `HUtils::GenericFilter(...)` and `TableSort::GenericFilter(...)` moved off `LinkedSpec::run_plugin(...)` / `get_plugin(...)`; the temporary `plugin/genericfilter.plg` compatibility wrapper from the extraction step has since been removed, and the newer 2026-04-12 note above records that the current owner is `Table::GenericFilter`.
- 2026-04-11: Tightened the same Backbone Item 3 / Phase 1A owner-contract seam one step further: `LinkedSpec::OwnerDispatch::dispatch_owner_call(...)` now delegates through `require_pkg_cb(...)` internally instead of carrying its own callback lookup plus direct symbol-call path. This keeps delegated owner calls, dependency maps, mixed dependency bundles, and thin wrapper callback lookup on the same callback-loader implementation while preserving list-context returns and successful `$@` preservation.
- 2026-04-11: Continued the Backbone Item 3 / Phase 1A owner-contract cleanup by routing the remaining thin wrapper callback lookups in `Runtime`, `Compiler`, `BootstrapSpec`, `SpecEntry`, and `ActionIR::Scanner` through `LinkedSpec::OwnerDispatch::require_pkg_cb(...)` instead of local `Package->can(...)` probes. At that point `RuleIR::EmitContext` still carried custom owner-key registry callback probes; the newer 2026-04-17 note above records that those now route through `OwnerDispatch` too.
- 2026-04-11: Renamed the remaining active bootstrap-local `spec_descr` / `gdata` vocabulary in `LinkedSpec::BootstrapSpec` and `BootstrapSpec::Core` to explicit `rule_descriptors` / `dispatch_state` terminology, including dispatch-state keys (`start_token_re`, `start_rule_dispatch`, `brace_scanner_re`, `current_rule_label`). The old names should now be treated as historical compatibility/negative-test language rather than active bootstrap implementation language.
- 2026-04-11: Executed the README/SESSION_BOOTSTRAP architecture refresh path. The deep read confirmed `LinkedSpec.pm` remains a thin facade and the active compiler path now speaks in `build_compiled_rule_table(...)` plus compiled dependency-regex state. At refresh time, the remaining `spec_descr` / `gdata` names were isolated to bootstrap parser internals in `LinkedSpec::BootstrapSpec` / `BootstrapSpec::Core`; the follow-up note above records that this bootstrap-local naming island has since been cleaned.
- 2026-04-11: Modernized the public mdBook blind-call post-processing examples to use explicit `return(array(...))` payloads instead of `return_a(...)`, and updated the malformed fluent suffix example to `=> Child..return(...)`. Root guides and the public book now teach visible return payloads for normal blind-call examples; legacy tagged return helpers remain compatibility surfaces rather than adoption-path examples.
- 2026-04-11: Cleaned stale root-guide teaching examples after the return-helper and capture-if migrations. `USER_GUIDE.md` ordinary examples now prefer explicit `return(array(...))` payloads instead of `return_a(...)`, and `USER_GUIDE_RuleModesAndSplit.md` now shows blind-call post-processing with explicit return payloads plus the live EBNF logging-annotation `push(...)` / `push_nonempty(...)` form instead of raw child-call pushes, `capture_if(...)`, and `CAPTURE_IF()`. Remaining root-guide mentions of `return_a(...)` and `capture_if(...)` are compatibility-focused lists rather than normal examples.
- 2026-04-11: Migrated the remaining live `specs/vhdl.spec` uses of legacy tagged return helper aliases (`return_m`, `return_ma`, `return_a`) to explicit `return(array(...))` payloads. Immediate capture-group payloads now use `flat_array(entry_groups())`, accumulator payloads now use `array_copy(array(rule))`, and a source-lock regression rejects reintroducing those aliases or raw `flat_array(IMATCH_LIST)` in VHDL. This exposed and fixed a core method-return lowering gap: `flat_array(entry_groups())` / `flat_array(match_groups())` are now classified as flattenable array-valued helper expressions rather than leaving runtime helper calls behind. The public ActionIR contract guide, emitted-Perl reference, and mdBook helper reference now document the compatibility helpers with direct modern replacements. Future DSL consistency work should treat legacy return-helper overlap as reduced to compatibility docs/tests and deferred/problem specs, not as an active live-VHDL ambiguity.
- 2026-04-10: Canonicalized array-edge drop authoring around `drop_front(...)` and `drop_back(...)`. `tail(...)` and `drop_last(...)` remain supported compatibility aliases, but current repo guides, public mdBook examples, emitted-Perl examples, flow examples, and fluent/structured regression fixtures now use the explicit edge names as the preferred spelling. Future DSL consistency work should treat this family as compatibility-retirement policy only, not an active naming ambiguity; the main remaining audit target is legacy return helper overlap plus convention-based accumulator helper documentation.
- 2026-04-10: Canonicalized the generic list-context splice spelling around `flat(...)`. `flatten(...)` remains supported and now has explicit compatibility regression coverage for array and hash generic splice forms, but current lowering/reference docs present it as a compatibility alias rather than a peer or normal example. Future DSL consistency work should move on to legacy return helper overlap and remaining convention-based accumulator helper documentation.
- 2026-04-10: Migrated live snapshot-helper authoring from compatibility `array_values(...)` to preferred `array_copy(...)` in the remaining shipped specs (`lib_reader`, `sdce`, `ds_vhistory`, `Lispish`, `hlink_substitution`, `simenv`, and `vhdl`) plus current public examples and source-lock expectations. Explicit `array_values(...)` compatibility coverage remains where the alias behavior is the tested/documented subject. Future DSL consistency work should now treat snapshot helper cleanup as eventual alias-retirement policy, not as a live-spec/example migration gap.
- 2026-04-10: Standardized child-call appends on the existing shorter `push(...)` DSL surface instead of keeping a duplicate `push_call(...)` method. `push(Rule)` appends `call(Rule)` into the current rule's default accumulator array, `push(Rule, index)` appends one indexed element from a shaped child return into that current-rule array, `push(Rule, target)` appends into an explicit target array, and `push(Rule, target, index)` covers explicit-target indexed appends. The internal raw-wrapper contracts are now named `push_child_call_*_builtin` rather than `push_call_*_builtin` so descriptor metadata does not resemble a public `push_call(...)` DSL helper. The public mdBook now documents the rule-local default accumulator convention and the older capture/tagged-return helpers that also use it. Future exhaustive DSL cleanup should look for the same kind of overlap: duplicate names, conflicting argument order, or helpers that hide target selection by convention without documenting it; the live roadmap currently calls out legacy return helper overlap, compatibility-alias retirement policy, and convention-based accumulator helpers as the next audit targets.
- 2026-04-10: Added `push_nonempty(array(target), value)` as the modern helper for optional accumulator appends, wired it through the ActionIR contract/scanner/lowering path as canonical `PUSH`, and migrated `specs/ebnf.spec::logging_annotation` from the legacy `capture_if(...)` / `CAPTURE_IF()` surface to `push_nonempty(a(logging_annotation), trim(capture_slice()))`. The helper skips `undef`, empty strings, empty arrayrefs, and empty hashrefs while preserving meaningful values like `"0"`. The public book now documents the helper in the value/container/flow reference and updates the EBNF walkthrough so shipped examples no longer teach the legacy capture-if surface for this pattern. Future resume should prefer `push_nonempty(...)` for trimmed optional captures and child-result accumulators where empty payloads are parser noise.
- 2026-04-10: Added the second detailed shipped-spec walkthrough to the public mdBook at `docs/linkedspec-book/src/specs-and-corpora/ebnf-spec-walkthrough.md` and fixed the ActionIR capture-if lowering edge it exposed. The chapter documents `get_parser('ebnf')`, the `Expr`/`Term` AST shape, top-level include entries, `grammar_file` accumulator state, guarded rule-body token flow, terminal token readers, semantic annotations, logging annotations, return annotations, corpus coverage over `ebnf/*.ebnf`, descriptor ActionIR-readiness facts, and regression locks. The code fix changes shared `capture_if(...)` / `CAPTURE_IF()` lowering in `perl/LinkedSpec/ActionIR/Contracts.pm` to emit the literal trim regex without interpolation, with new regression coverage for the generated helper code and `@log_rule("expr", "term")` runtime parsing. Future shipped-material book work can continue with `vhdl.spec` or the smaller focused domain specs.
- 2026-04-10: Added the first detailed shipped-spec walkthrough to the public mdBook at `docs/linkedspec-book/src/specs-and-corpora/lispish-spec-walkthrough.md`. It explains `LinkedSpec::get_parser('Lispish')`, the regression-locked nested AST output, head/tail and `undef` tail conventions, rule inventory, top-level `Lispish` dispatch, recursive `parenthesis` accumulator state, token readers, comment consumption, descriptor ActionIR-readiness facts, and the `perl/Lispish.pm` convenience wrapper. Future public-book shipped-material work can continue with `ebnf.spec`, `vhdl.spec`, or focused domain-spec walkthroughs.
- 2026-04-10: Modernized the public book's first-reader examples. `docs/linkedspec-book/src/user-model/spec-files-and-rule-paragraphs.md` and `docs/linkedspec-book/src/public-api/get-and-get-parser.md` now use helper-built payload examples with `return(hash(...))` and `match_text()` instead of leading readers through tiny legacy `return_a(...)` examples; a later 2026-04-11 cleanup also moved the blind-call orchestration chapter's normal post-call examples to explicit `return(array(...))` payloads. Future public-book cleanup can continue replacing older raw/legacy snippets only when the replacement is validated and clearer than the original.
- 2026-04-10: Added a public mdBook worked `.spec` walkthrough at `docs/linkedspec-book/src/user-model/worked-spec-walkthrough.md`. It uses a validated helper-style `Pair::AND` example to explain rule labels, regex captures, zero-based `match_group(...)`, `trim(...)`, `hash(...)`, `return(...)`, inline `LinkedSpec::Get(...)`, `seek` versus `consume`, descriptor mode, `runtime_ctx_ref`, and how to evolve the grammar toward blind calls, explicit `call(...)` dataflow, or repeated `OR` extraction. Future public-book work can continue with per-spec walkthroughs for shipped specs or deeper helper-family examples.
- 2026-04-10: Added a public mdBook blind-call orchestration guide at `docs/linkedspec-book/src/user-model/blind-calls-and-parser-orchestration.md`. It documents `=>` versus `->`, supported blind-call forms and malformed target shapes, rule-label-driven sequence/choice/repetition behavior, ordered wrappers, single-choice wrappers, repeated-choice wrappers, repeated ordered wrappers, post-call block/fluent processing, the no-mixed-edge-family rule, same-line versus multiline placement, and when explicit `assign(scalar(retv), call(Child))` dataflow is clearer than a blind call. Future public-book work can continue with per-spec walkthroughs, DSL helper reference backfill, or a worked end-to-end `.spec` chapter.
- 2026-04-10: Deepened the public mdBook rule-mode guide. `docs/linkedspec-book/src/user-model/rule-modes-and-parse-modes.md` now explains rule labels as a separate axis from parse modes, documents baseline `:` / `::` labels, compact `:&` / `:|` / `:+` / `:*` / `:?` sigils, worded `AND` / `OR` families, bounded `AND{...}` / `OR{...}` forms, choice-versus-sequence-versus-repetition semantics, blind-call label behavior, `seek` versus `consume`, and exact spelling expectations. Future public-book work can continue with deeper blind-call walkthroughs, per-spec walkthroughs, or more method-level DSL reference slices.
- 2026-04-10: Added a public mdBook action/lifecycle placement chapter. `docs/linkedspec-book/src/dsl/action-and-lifecycle-placement.md` now explains rule paragraph members, `I { ... }` setup, action edges, method-chain action edges, empty action edges, blind-call edges, helper-based local match reads, `LS`/`LE`, `LX`, advanced `IT`/`EX`/`E`, and placement-sensitive `@capture_slice` / `@mark(name)` markers with examples. Future public-book work can continue with deeper rule-mode walkthroughs, blind-call orchestration details, or shipped-spec walkthroughs.
- 2026-04-10: Added a public mdBook declaration helper reference chapter. `docs/linkedspec-book/src/dsl/declaration-helper-reference.md` now documents `declare(type, ...)`, `declare_s`/`declare_a`/`declare_h` and long aliases, shared-state placement in `I { ... }`, action-local declarations, initialized declarations, scalar/array/hash initializer patterns, fluent versus structured forms, reset-vs-redeclare guidance, and common declaration mistakes. Future public-book DSL work can continue with lifecycle/control-flow placement, per-spec walkthroughs, or deeper examples for helper clusters that still live mostly in repo-root guides.
- 2026-04-10: Added the next method-level public mdBook DSL reference chapter for value/container/flow helpers. `docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md` now documents composition sites, `scalar`/`array`/`hash` access, `scalaref`, snapshots versus flattening, `assign`, `call`, `push_value`, `return`, scalar/string/numeric helpers, array/hash helpers, array pipelines, fallback/presence helpers, boolean composition, structured `if`, structured `switch`, and debug output helpers with worked examples. Future public-book DSL work can continue with declaration helper details, shipped-spec walkthroughs, or deeper examples for individual helper clusters.
- 2026-04-10: Added the first method-level public mdBook DSL reference chapter for source-boundary helpers. `docs/linkedspec-book/src/dsl/source-boundary-helper-reference.md` now documents `capture_*`, `mark_*`, `cursor_*`, `input_*`, `entry_*`, and `match_*` semantics, including right-edge choices, stable versus advancing reads, anonymous/named boundary movement, compatibility aliases, and worked examples. Future public-book DSL work can continue with values/container/control helper references at the same bar.
- 2026-04-10: Deepened the public LinkedSpec book development workflow path. The Development chapters now explain local CI/regression ownership, GitHub delegating to `tools/run_ci_local.sh`, tracked CI input areas, why untracked CI inputs fail, failure interpretation, docs-only versus code/spec/runtime validation, public book versus continuity docs, mdBook source/build paths, `SUMMARY.md` chapter registration, documentation style expectations, and the DSL documentation bar. Future book work can move to method-level DSL reference expansion or per-spec walkthroughs.
- 2026-04-10: Deepened the public LinkedSpec book shipped-material path. The shipped specs/corpora chapter now maps `specs/`, `plugin/`, `conf/`, `tablescript/`, `ebnf/`, and `t/phase0_regression.t`; documents each shipped `.spec` with its main entry rule and purpose; calls out maturity differences including historical/experimental specs and the `verilog.spec` placeholder; explains `.plg` as legacy transition material; ties corpus directories to regression coverage; and records the future obligation to add deeper per-spec walkthroughs. Future book work can move to local CI/development workflow or method-level DSL reference expansion.
- 2026-04-10: Deepened the public LinkedSpec book runtime-context/tracing path. The chapter now explains `runtime_ctx_ref` hash/scalar-slot forms, context lifecycle across `Get(...)`, `get_parser(...)`, compile failures, parser invocation failures, file identity preservation, `last_error` owner/stage payloads, handler source labels, parser-source capture via `dump_parser_source` / `parser_source_ref`, and trace configuration through `configure_trace(...)`, compile options, levels, output modes, and environment variables. Future book work can move to shipped specs/corpora, local CI/development workflow, or method-level DSL reference expansion.
- 2026-04-10: Deepened the public LinkedSpec book architecture path. The owner-tree chapter now explains the facade/core-spine model, `OwnerDispatch`, `ParserFactory -> Runtime -> Compiler`, `Resolver`, `RuntimeContext`, `CompilerState`, bootstrap/validation ownership, `SpecEntry` / `RuleIR` / `RuleIR::EmitContext`, the `ActionIR::*` subtree, the legacy plugin branch as transition machinery, and a practical change-routing map. Future book work can now move to shipped specs/corpora, runtime context/tracing, local CI/development workflow, or method-level DSL reference expansion.
- 2026-04-09: Deepened the public LinkedSpec book compiler/runtime path. The mdBook now explains the compile pipeline stage by stage, the active compiled state records (`compiled_spec_state`, `compiled_dependency_regex_state`, `compiled_descriptor_state`), outward descriptor projection, generated handler dispatch through `dependency_regex_map`, `DEPENDENCY_REFS` emit-context naming, and structured diagnostics through `runtime_ctx->{last_error}` with owner/stage attribution. Future book work can now move to architecture/shipped-specs chapters or add deeper method-level DSL reference material.
- 2026-04-09: Deepened the public LinkedSpec book DSL/action path with new chapters for the ActionIR lowering mental model, capture/mark/source-location helpers, and value/container/control helpers. The book now explains why the project is moving away from raw Perl-shaped actions, how helper DSL lowers through ActionIR, and how to choose between `capture_*`, `mark_*`, `cursor_*`, `entry_*`, `match_*`, `input_*`, assignment, return, container, and flow helpers. Future book work can now either deepen those chapters method-by-method or move into compiler/runtime internals.
- 2026-04-09: Deepened the first public LinkedSpec book reader path instead of only extending internal working docs. The mdBook user-model and public-API chapters now include concrete `.spec` paragraph examples, top-level rule-start versus block-content explanation, `seek`/`consume` examples, shared `Get(...)` / `get_parser(...)` option examples, and an explicit descriptor shape using `dependency_regex_map` plus `dependency_refs`. Future book work should keep this public, example-heavy style and continue expanding one coherent reader path at a time.
- 2026-04-09: The documentation-layer split is now explicit in the repo workflow. `docs/linkedspec-book/` is the public-facing LinkedSpec book, while `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `MEMORY.md`, roadmap notes, and `COMMIT.md` remain internal continuity/execution docs. Future resume should not treat continuity docs as a substitute for the public documentation story.
- 2026-04-09: Started the real LinkedSpec mdBook at `docs/linkedspec-book/`. The first slice establishes a broad chapter map across overview, user model, public API, DSL/action surface, compiler/runtime internals, shipped specs/corpora, architecture, and development workflow, and seeds core chapters so the book can grow as the public explanation layer of the project. Future resume should extend this book as the project evolves instead of letting the public narrative live only in repo-native working docs.
- 2026-04-09: Finished the active dependency-regex naming cleanup across the live descriptor path with no compatibility alias preserved there. The outward descriptor key is now `dependency_regex_map`, per-rule compiled dependency mappings are now `dependency_refs`, and the remaining RuleIR emit-context holdout is now `DEPENDENCY_REFS`. Future resume should treat `gdata` as historical vocabulary unless a slice is explicitly about older notes or outward compatibility descriptor shapes.
- 2026-04-09: Finished the next active naming-cleanup seam by replacing compressed final-descriptor `descr` wording with full `descriptor` wording across the live compiler path. `Compiler.pm`, `CompilerState.pm`, the active regression locks, and the current docs now treat `build_final_descriptor`, `_build_final_descriptor_state(...)`, and `_compiled_descriptor_state_to_legacy_descriptor(...)` as the real names, with no compatibility alias kept for the old `build_final_descr` seam. Future resume should use the full `descriptor` names on the active path and avoid reintroducing the compressed seam wording outside older history.
- 2026-04-09: Removed a mistakenly added external-project mdBook/doc slice and restored the repo documentation scope to LinkedSpec-only. Future resume should not recreate subsystem/book scaffolding from another project here unless that scope is explicitly reintroduced on purpose.
- 2026-04-09: Renamed the active public descriptor-introspection option from `return_descr` to `return_descriptor` with no compatibility alias preserved. Runtime, ParserFactory, Compiler, the active regression locks, and the current docs now all treat `return_descriptor => 1` as the real public descriptor-return surface. Future resume should use `return_descriptor` everywhere on the active path and avoid reintroducing `return_descr` outside older historical notes.
- 2026-04-09: Continued the active state-model naming cleanup by replacing `duplicate_rule_labels` with `redefined_rule_labels` across compiled-spec state, descriptor metadata, regression locks, and the current docs. Future resume should use `redefined_rule_labels` for the active last-definition-wins overwrite signal and avoid reintroducing the more ambiguous duplicate-label wording on the state-first compiler path.
- 2026-04-09: Continued the same state-model naming cleanup by replacing ambiguous `rule_order` with `compiled_rule_order` on the active compiled-spec and descriptor-metadata path. `CompilerState.pm`, the active regression locks, and the current docs now all treat that array as the deterministic unique compiled-rule sequence, not just a generic “rule order.” Future resume should use `compiled_rule_order` for new work and avoid reintroducing `rule_order` on the active state-first surface.
- 2026-04-09: Finished the next naming-cleanup pass on the derived-regex compiler path with no compatibility aliases kept on the active internal model. `build_dependency_regex_map(...)`, `validate_dependency_regex_references(...)`, `compiled_dependency_regex_state`, and the shared dependency-regex validation view are now the real working terms across `Compiler.pm`, `CompilerState.pm`, and `Validation.pm`; the old `spec_gdata` / `compiled_gdata_state` / `gdata_validation_view` vocabulary now survives only in older history and the outward legacy descriptor field `gdata`. Future resume should keep new compiler/state/validation work on the dependency-regex names and avoid reintroducing internal alias surfaces.
- 2026-04-08: Renamed the active low-level compiler seam from `spec_descr(...)` to `build_compiled_rule_table(...)` with no compatibility wrapper kept under the old name. `Compiler.pm`, the public `LinkedSpec.pm` façade, structured diagnostics stage naming, and the active regression locks now all speak in terms of compiled rule-table construction directly. Future resume should treat `spec_descr` as historical vocabulary only unless the task is explicitly about older bootstrap internals or older notes.
- 2026-04-08: Continued the same state-first compiler line by clarifying the naming model around historical `gdata`. `LinkedSpec::CompilerState` now treats dependency-regex state as the preferred internal term and keeps `compiled_gdata_state`, `gdata_by_label`, and `gdata_rows` as compatibility aliases over the same payload. Future resume should use dependency-regex state as the architectural term unless the task is specifically about outward compatibility surfaces.
- 2026-04-08: Continued the same state-first validation line by removing the duplicated gdata-validation engines in `Validation.pm`. Legacy `validate_gdata_references(...)` input and the newer owner-provided descriptor-state validation view now both route through one shared validation-view validator. Future resume should keep gdata/rule consistency checks unified there rather than reintroducing parallel validation bodies.
- 2026-04-08: Continued the same state-first compiler line one seam further into validation-view assembly. `LinkedSpec::CompilerState` now builds one explicit `compiled_descriptor_state_validation_view(...)`, and `Validation.pm` now validates through that single owner-provided view instead of issuing repeated owner lookups from inside its descriptor-state validation loops. Future resume should keep descriptor-state validation on that single owner-provided view seam.
- 2026-04-08: Continued the same state-first compiler line one seam further into generated-descriptor validation. `Validation.pm` now walks descriptor-state rule rows, descriptor-state gdata rows, and descriptor-state by-label lookup through `LinkedSpec::CompilerState` instead of flattening descriptor state back into raw validation maps first. Future resume should keep descriptor-state validation on that owner-provided view layer rather than reintroducing local map extraction in `Validation.pm`.
- 2026-04-08: Continued the same state-first compiler line by extracting the compiled state model into its own owner. `LinkedSpec::CompilerState` now owns compiled-spec / compiled-gdata / compiled-descriptor state construction, shape checks, and legacy projection, while `Compiler.pm` and `Validation.pm` now delegate through that owner instead of each carrying local state-model logic. Future resume should treat compiler-state ownership as a separate architectural seam now, not just as a cluster of private helper subs inside `Compiler.pm`.
- 2026-04-08: Continued the same state-first compiler line one seam later into derived gdata. `Compiler.pm` now has an explicit `compiled_gdata_state` model, `spec_gdata(...)` can return that state directly with `{ return_state => 1 }`, `compiled_descriptor_state` now composes compiled-spec state plus compiled-gdata state instead of keeping a raw compiled-gdata hash, and `Validation.pm` now reads generated-descriptor validation input from that explicit gdata-state seam. Future resume should treat compiled gdata as part of the same explicit compiler state model now instead of as the last anonymous hash structure.
- 2026-04-08: Finished the next state-first compiler follow-up after introducing `compiled_descriptor_state`. `Validation.pm` no longer treats `validate_compiled_descriptor_state(...)` as a thin wrapper over the legacy `validate_gdata_references(...)` shape; it now validates descriptor state directly through one shared state-aware validator, and `Compiler.pm` now defers legacy `{ spec => ..., gdata => ..., meta => ... }` projection until after that internal descriptor-state validation has already succeeded. Future resume should treat generated-descriptor validation as fully state-first now, not just state-aware at the call boundary.
- 2026-04-08: Continued the same state-first compiler line one seam further into validation. `Validation.pm` now exposes `validate_compiled_descriptor_state(...)`, and `Compiler.pm` now validates the internal `compiled_descriptor_state` directly before projecting the outward `{ spec => ..., gdata => ..., meta => ... }` compatibility descriptor. Future resume should treat generated-descriptor validation as part of the same state-first compiler path now instead of reasoning from flattened `spec` / `gdata` inputs first.
- 2026-04-08: Continued the same state-first compiler refactor one seam later. `Compiler.pm` now builds an explicit internal `compiled_descriptor_state` after compiled-spec state and compiled `gdata` are available, then projects the outward `{ spec => ..., gdata => ..., meta => ... }` compatibility descriptor from that state. The same slice also exposes `meta.definition_order` at `return_descriptor`, and final descriptor assembly now rejects malformed compiled `gdata` callback output directly with specific contract detail instead of letting it drift into later generated-descriptor validation. Future resume should treat final descriptor assembly as state-first now too, not only `spec_descr(...)` / migration-summary generation.
- 2026-04-07: Continued the same compiled-spec-state line one seam later. `_build_action_rewriter_migration_summary(...)` now accepts compiled-spec state directly, and final descriptor assembly now builds `meta.action_rewriter_migration` from that state instead of bouncing back through a projected legacy `spec` hash just for migration metadata. Future resume should treat migration-summary generation as part of the same state-first compiler story now, not as one remaining legacy-spec detour.
- 2026-04-07: Took the first real structural step on the historical `spec_descr` / `spec_gdata` pair instead of only tightening diagnostics around them. `Compiler.pm` now has one explicit internal compiled-spec state model with `kind`, `version`, `definition_order`, `rule_order`, `rules_by_label`, and `redefined_rule_labels`; default `spec_gdata(...)` now enriches that state directly; and final descriptor assembly now emits legacy `spec` / `gdata` hashes only as compatibility projections while surfacing state-derived metadata (`descriptor_model`, `rule_order`, `redefined_rule_labels`) in descriptor `meta`. Future resume should treat compiled-spec state, not the historical loose spec hash, as the compiler's real source of truth now.
- 2026-04-07: Tightened the default `spec_gdata(...)` seam inside final descriptor assembly. It now validates descriptor shape explicitly instead of relying on incidental Perl reference errors, so malformed per-rule `gdata` / dependency / referenced-`re` structures now fail with targeted `build_final_descriptor` detail while preserving the active `rule_label` and label-scoped `handler_source_label` continuity through `run_get_pipeline(...)`. Future resume should treat default `spec_gdata(...)` contract validation as covered structured Phase 5 diagnostics surface now instead of assuming that seam only matters when `LinkedRE::or(...)` or another inner callback throws.
- 2026-04-06: Tightened the low-level compiler-facing `spec_descr(...)` surface too. It now accepts `runtime_ctx_ref => \$ctx`, seeds `top_rule` from the parsed entries when available, and normalizes both thrown and malformed non-throwing `compile_spec_entry(...)` failures into the same `compiler_pipeline:spec_descr` payload family with `rule_label` and label-scoped `handler_source_label` continuity. Future resume should treat standalone `spec_descr(...)` diagnostics as part of the structured Phase 5 story now instead of assuming only `run_get_pipeline(...)` exposes compiler-owned `spec_descr` failures cleanly.
- 2026-04-06: Tightened the top-level parser boundary itself. Returned parser coderefs now reject malformed non-`SCALAR`-reference input explicitly at `runtime_parser:validate_input_ref` instead of falling through to lower-level Perl dereference failures, and focused regression coverage now locks that both on the direct `run_get_pipeline(...)` seam and through file-oriented `get_parser(...)` continuity after spec resolution/load. Future resume should treat parser-input shape validation as covered runtime-parser diagnostics surface now instead of assuming top-level parser failures only start at handler resolution or handler dies.
- 2026-04-06: Locked the same file-oriented continuity story on the runtime-parser side too. `get_parser(...)` now has focused regression coverage proving that after a spec file has resolved and loaded successfully, a later top-level parser invocation failure still preserves resolved `spec_path`, selected `top_rule`, handler variant, and generated-handler identity in shared `runtime_ctx->{last_error}`. Future resume should treat file-oriented `runtime_parser` identity continuity as covered now instead of assuming only runtime-handler or compile-time failures preserve that file-backed context.
- 2026-04-06: Locked the same late generic compiler-failure attribution story through the file-oriented path too. `get_parser(...)` already preserved the deeper compiler payload, but we did not have a focused regression proving that resolved-spec continuity keeps `spec_path`, selected `top_rule`, and the label-only `LinkedSpec::generated_handler:<top_rule>` identity together on a later generic `build_final_descriptor` failure. Future resume should treat that file-oriented late-compiler continuity as covered now instead of rediscovering it by hand.
- 2026-04-05: Continued the same Phase 5 diagnostics-attribution line into the later generic compiler seams too. `Compiler.pm` now falls back to the selected `top_rule` for `handler_source_label` on unattributed `spec_descr`, `build_final_descriptor`, and `validate_gdata_references` failures when no rule label is known yet. Regression coverage now locks that directly and through public `LinkedSpec::Get(...)` continuity. Future resume should treat late generic compiler-failure handler attribution as covered structured-diagnostics continuity now instead of assuming only rule-attributed late compiler failures preserve handler identity.
- 2026-04-05: Continued the same Phase 5 diagnostics-attribution line into the remaining pre-rule compiler validation seams. `Compiler.pm` now falls back to the selected `top_rule` for `handler_source_label` on `validate_spec_content` and unattributed `validate_dsl_syntax` failures when no rule label is known yet. Regression coverage now locks that directly and through public `LinkedSpec::Get(...)` / `get_parser(...)` continuity paths. Future resume should treat pre-rule compiler-validation handler attribution as covered structured-diagnostics continuity now instead of assuming label-only handler identity starts only after rule ownership has been discovered.
- 2026-04-05: Continued the same Phase 5 diagnostics-attribution line into the earlier compiler-owned seams too. `Compiler.pm` now preserves the label-only generated-handler identity `LinkedSpec::generated_handler:<top_rule>` not only on later rule-attributed failures, but also on `prepare_pipeline` and `bootstrap_parse` payloads whenever the selected top rule is already known. Regression coverage now locks that through both the direct `run_get_pipeline(...)` seam and the public `LinkedSpec::Get(...)` path. Future resume should treat compiler pre-rule handler attribution as covered structured-diagnostics continuity now instead of assuming label-only handler identity starts only at later compiler stages or runtime/parser boundaries.
- 2026-04-05: Continued the same Phase 5 diagnostics-attribution line one seam earlier on the file-oriented path. `ParserFactory.pm` now preserves the label-only generated-handler identity `LinkedSpec::generated_handler:<top_rule>` not only on `parser_factory:compile_spec` fallback payloads, but also on the earlier `prepare_parser_factory`, `validate_spec_name`, `resolve_spec_path`, and `load_spec_content` failure seams whenever the selected top rule is already known. Regression coverage now locks that through both the direct `run_get_parser(...)` seam and the public `get_parser(...)` path. Future resume should treat parser-factory pre-compile handler attribution as covered structured-diagnostics continuity now instead of assuming label-only handler identity starts only at compile fallback or runtime/parser boundaries.
- 2026-04-04: Continued the same Phase 5 diagnostics-attribution line into the parser-factory compile fallback seam too. `ParserFactory.pm` now preserves the label-only generated-handler identity `LinkedSpec::generated_handler:<top_rule>` on fallback `parser_factory:compile_spec` payloads whenever the selected top rule is already known. Regression coverage now locks that through both the direct `run_get_parser(...)` seam and the public `get_parser(...)` continuity path, including default parser, descriptor, and mode-only malformed-result branches. Future resume should treat parser-factory compile fallback handler attribution as covered structured-diagnostics continuity now instead of assuming label-only handler identity starts only at runtime-owner or parser-boundary failures.
- 2026-04-04: Continued the same Phase 5 diagnostics-attribution line into the runtime-owner fallback seam. `Runtime.pm` now preserves the label-only generated-handler identity `LinkedSpec::generated_handler:<top_rule>` on fallback `runtime_owner:run_get_pipeline` payloads whenever the selected top rule is already known. Regression coverage now locks that through direct `Runtime::run_get(...)`, public `LinkedSpec::Get(...)`, and file-oriented `get_parser(...)` continuity paths. Future resume should treat runtime-owner fallback handler attribution as covered structured-diagnostics continuity now instead of assuming label-only handler identity starts only at compiler- or parser-boundary failures.
- 2026-04-04: Tightened the same Phase 5 compile-result line around the mode-only branches too. The runtime and parser-factory code already treated only `undef` as a successful `parse_only` / `generate_only` result, but that contract was not locked. Regression coverage now explicitly traps malformed defined mode-only returns on both the lower-level seams and the outward `LinkedSpec::Get(...)` / `get_parser(...)` surfaces, and the guide/roadmap now call that mode-only contract out directly. Future resume should treat malformed defined `parse_only` / `generate_only` results as covered diagnostics continuity now instead of assuming only default parser/descriptor result shapes are locked.
- 2026-04-04: Continued the same real Phase 5 diagnostics line on the inline runtime compile seam. `Runtime.pm` now treats only a real parser coderef as a successful default `run_get_pipeline(...)` result and only a descriptor hash as a successful `return_descriptor => 1` result, while preserving intentional `undef` success for `parse_only` / `generate_only`. Malformed defined compiler-delegation results now preserve specific detail such as `run_get_pipeline returned invalid parser value: HASH; expected CODE` instead of drifting outward as bogus success values or collapsing back to the generic runtime-owner wrapper. Future resume should treat malformed defined `run_get_pipeline(...)` returns as covered runtime-owner diagnostics continuity now instead of assuming only thrown or silent-`undef` compiler-delegation paths matter there.
- 2026-04-04: Continued the same real Phase 5 diagnostics line on the parser-factory compile seam. `ParserFactory.pm` now treats only a real parser coderef as a successful `compile_spec(...)` result and preserves specific malformed defined return detail such as `compile_spec returned invalid parser value: HASH; expected CODE` instead of letting bogus defined values drift outward as parsers or collapsing back to one generic wrapper. Future resume should treat malformed defined `compile_spec(...)` returns as covered parser-factory diagnostics continuity now instead of assuming only thrown or `undef` compile paths matter there.
- 2026-04-04: Continued the same real Phase 5 diagnostics line inside the descriptor-build seam. `Compiler.pm` now preserves specific malformed non-throwing `compile_spec_entry(...)` tuple detail on `compiler_pipeline:spec_descr` failures instead of collapsing back to the generic “Rule descriptor build failed while compiling parsed spec entries” wrapper. Future resume should treat malformed non-throwing `spec_descr` tuple returns as covered compiler diagnostics continuity now instead of assuming only thrown `compile_spec_entry(...)` failures preserve useful detail.
- 2026-04-04: Continued the real Phase 5 diagnostics line back into the compiler bootstrap seam. `Compiler.pm` now treats only a non-empty top-level ARRAY from `bootstrap_parse(...)` as a valid intermediate representation and preserves specific malformed-return detail on non-throwing bad shapes such as `undef`, `HASH`, or empty ARRAY results instead of collapsing them all to one generic invalid-IR detail string. Future resume should treat malformed non-throwing bootstrap results as covered compiler diagnostics continuity now instead of assuming only thrown bootstrap callbacks preserve useful detail.
- 2026-04-04: Continued the same real Phase 5 diagnostics line one step later in the parser-factory file-loading seam. `LinkedSpec::Resolver::load_spec_content(...)` now exposes structured failure metadata on its non-throwing open-failure `undef` path, and `ParserFactory.pm` now preserves that specific resolver summary/detail on `parser_factory:load_spec_content` false-return failures instead of collapsing back to the generic `Spec file load failed` wrapper. Future resume should treat resolver-attributed false-return unreadable-file failures as covered parser-factory diagnostics continuity now instead of assuming only thrown load callbacks keep their original text.
- 2026-04-04: Continued the same real Phase 5 diagnostics line on the parser-factory resolution seam. `LinkedSpec::Resolver::resolve_spec_path(...)` now exposes structured failure metadata on its non-throwing `undef` paths, and `ParserFactory.pm` now preserves that specific resolver summary/detail on `parser_factory:resolve_spec_path` false-return failures instead of collapsing back to the generic `Spec resolution failed` wrapper. Future resume should treat resolver-attributed false-return resolution failures as covered parser-factory diagnostics continuity now instead of assuming only thrown resolver callbacks keep their original text.
- 2026-04-04: Continued the same real Phase 5 diagnostics line on the parser-factory side. `LinkedSpec::Resolver::validate_spec_name(...)` now exposes structured failure metadata for non-throwing invalid-name rejections, and `ParserFactory.pm` now preserves that specific summary/detail on `parser_factory:validate_spec_name` false-return failures instead of collapsing back to a generic wrapper string. Future resume should treat invalid-name false returns as covered parser-factory diagnostics continuity now instead of assuming only thrown parser-factory callbacks preserve specific failure text.
- 2026-04-04: Continued the same real Phase 5 diagnostics line one stage earlier in the compile flow. `validate_spec_content(...)` now exposes structured failure metadata for non-throwing envelope-validation rejections, and `Compiler.pm` now preserves the validator’s specific summary/detail on `compiler_pipeline:validate_spec_content` false-return failures instead of collapsing back to the generic “Input envelope validation failed” banner. When the early validator already knows a malformed first-rule label, that same seam now also preserves `rule_label` plus the label-only synthetic `handler_source_label`. Future resume should treat attributed `validate_spec_content` false returns as part of the stable structured-diagnostics family now instead of assuming only later rule-level validation or descriptor-build stages can surface specific attribution.
- 2026-04-04: Continued the real Phase 5 diagnostics line back into rule-level DSL validation false-return paths. `LinkedSpec::Validation::validate_dsl_syntax(...)` now exposes structured failure metadata on non-throwing validation rejections, and `Compiler.pm` now preserves the validator’s specific `summary`, formatted DSL-error `detail`, `rule_label`, and synthetic `handler_source_label` when the offending rule paragraph is still known. Future resume should treat rule-attributed `compiler_pipeline:validate_dsl_syntax` failures as part of the same stable structured-diagnostics family as `spec_descr`, `build_final_descriptor`, and `validate_gdata_references`.
- 2026-04-02: Continued the real Phase 5 diagnostics line at the remaining parser-boundary missing-entry seam. `runtime_parser:resolve_top_rule_handler` now preserves `handler_source_label` even when the selected top-rule label is known but the compiled descriptor entry itself is missing, so callers still get the stable label-only form `LinkedSpec::generated_handler:<top_rule>` before any exact handler variant can exist. Future resume should treat that missing-descriptor-entry path as covered generated-handler attribution now instead of assuming label-only handler-source identity starts only after a handler entry or variant is present.
- 2026-04-02: Continued the real Phase 5 diagnostics line with synthetic generated-handler attribution on compile-time rule failures. `Compiler.pm` now preserves `handler_source_label` not only on runtime handler/runtime parser failures with a known handler variant, but also on attributed `spec_descr`, `build_final_descriptor`, and `validate_gdata_references` failures whenever LinkedSpec still knows the failing rule label. Future resume should treat label-only forms like `LinkedSpec::generated_handler:Top` as part of the stable structured-diagnostics contract now instead of assuming `handler_source_label` is runtime-only.
- 2026-04-02: Continued the real Phase 4 feature line with the missing whole-input right-edge position helper. `input_end_pos()` now returns the absolute position of the whole-input right edge directly, which is numerically equal to `input_len()` today but reads honestly as a boundary-position helper instead of a width helper. Future resume should treat direct whole-input right-edge position reads as covered helper surface now instead of overloading `input_len()` or raw `length($$STRING)` where the surrounding rule logic is clearly boundary-oriented.
- 2026-04-01: Continued the real Phase 4 feature line with the missing whole-input right-edge location pair. `input_end_line()` now returns the 1-based line number of the whole-input right edge directly, and `input_end_col()` now returns the 1-based column number of that same whole-input right edge directly, without forcing users to first store `mark_input_end(name)` or to spell raw `length($$STRING)` plus newline/column math. Future resume should treat direct whole-input end-location reads as covered helper surface now instead of improvising them with raw whole-input math.
- 2026-04-01: Continued the real Phase 4 feature line with the missing whole-input read pair. `input_text()` now returns the whole current input string directly, and `input_len()` now returns the width of that same whole current input directly, without forcing users to fall back to raw `$$STRING` / `length($$STRING)` or to round-trip through `mark_input_start(name)` / `mark_input_end(name)` plus explicit span reads first. Future resume should treat direct whole-input reads as covered helper surface now instead of improvising them with raw host expressions.
- 2026-04-01: Continued the real Phase 4 feature line with the missing absolute input-boundary writer pair. `mark_input_start(name)` now stores the absolute current-input start boundary `0` under one stable named checkpoint, while `mark_input_end(name)` now stores `length($$STRING)` under one stable named checkpoint even when the live parser cursor is still earlier in the rule. Their lowering is now also safe as standalone writer statements even when the stored boundary itself is `0`, so future resume should treat explicit whole-input boundary writes as covered helper surface now instead of forcing users to improvise that meaning through `mark_here(name)`, rule-entry boundaries, or raw `0` / `length($$STRING)` plumbing.
- 2026-04-01: Continued the real Phase 4 feature line with the missing advancing current-edge width pair. `capture_take_len()` now returns the width of the current anonymous current-edge span and then advances the anonymous capture boundary to the current parser position, while `capture_take_len_from(name)` now does the same for a stable named checkpoint. Future resume should treat rolling anonymous and named current-edge width reads as covered helper surface now instead of forcing users to chain a stable current-edge width read with a separate anonymous or named boundary move.
- 2026-04-01: Continued the real Phase 4 feature line with the missing advancing end-of-input tail family. `capture_take_rest()` / `capture_take_rest_len()` now return the current anonymous tail through end-of-input and then advance the anonymous capture boundary to end-of-input, while `capture_take_rest_from(name)` / `capture_take_rest_len_from(name)` now do the same for a stable named checkpoint. Future resume should treat rolling anonymous and named tail-through-end-of-input reads as covered helper surface now instead of forcing users to chain a stable tail read with a separate anonymous or named boundary move.
- 2026-04-01: Continued the real Phase 4 feature line with the missing advancing explicit two-mark width helper. `capture_take_between_len(start_mark, end_mark)` now returns the width of the span between two stored named checkpoints and then advances the start mark to the stored end mark, which closes the remaining obvious symmetry gap beside `capture_between(...)`, `capture_len_between(...)`, and `capture_take_between(...)`. Future resume should treat rolling explicit two-mark width reads as covered helper surface now instead of forcing users to pair a stable width read with a separate mark-copy or manual mark advance.
- 2026-04-01: Continued the real Phase 4 feature line with the missing advancing through-cursor width pair. `capture_take_until_cursor_len()` now returns the width of the current anonymous through-cursor span and then advances the anonymous capture boundary to the live parser cursor, while `capture_take_until_cursor_len_from(name)` now does the same for a stable named checkpoint. Future resume should treat rolling through-cursor width reads as covered helper surface now instead of forcing users to chain a stable width read with a separate anonymous or named boundary move.
- 2026-04-01: Continued the real Phase 4 feature line with explicit start-edge human-readable aliases. `entry_start_line()` / `entry_start_col()` now make the immediate-match left-edge line/column reads read symmetrically alongside `entry_start_pos()` / `entry_end_*()`, and `match_start_line()` / `match_start_col()` now do the same for current local matches alongside `match_start_pos()` / `match_end_*()`. Future resume should treat explicit start-edge line/column naming as covered helper surface now instead of assuming users must infer that meaning from the older shorter `entry_line()` / `entry_col()` / `match_line()` / `match_col()` names alone.
- 2026-04-01: Continued the real Phase 4 feature line with the missing stable named boundary writers. `mark_entry_start(name)` and `mark_entry_end(name)` now snapshot the immediate entry-match boundaries into rule-local named checkpoints, and `mark_match_end(name)` now snapshots the current local-match right edge explicitly. Future resume should treat stable named entry/match boundary writes as covered helper surface now instead of chaining raw `entry_*_pos()` or `match_end_pos()` reads into manual mark plumbing.
- 2026-04-01: Continued the real Phase 4 feature line with the missing advancing through-cursor pair. `capture_take_until_cursor()` now advances the anonymous capture boundary after reading through the live parser cursor, and `capture_take_until_cursor_from(name)` now does the same for a stable named checkpoint. Future resume should treat rolling through-cursor capture as covered helper surface now instead of chaining a stable through-cursor read with a separate boundary move.
- 2026-04-01: Continued the real Phase 4 feature line with the missing anonymous/named bridge pair. `mark_capture_slice(name)` now snapshots the current anonymous capture boundary into a stable rule-local named mark, and `start_capture_slice_from(name)` now restores that stored named mark back into the anonymous capture-boundary slot. Future resume should treat anonymous/named bridge flow as covered helper surface now instead of falling back to raw `$IPOS` plus `mark_pos(...)` plumbing when one rule wants both models.
- 2026-04-01: Continued the real Phase 4 feature line with the missing anonymous advancing-read companion. `capture_take()` is now the anonymous capture-boundary counterpart to named `capture_take(name)`, which closes the remaining obvious gap between stable anonymous reads like `capture_slice()` and rolling split-cursor-style anonymous capture flow. Future resume should treat anonymous “read current slice, then move the same rolling boundary forward” behavior as covered helper surface now instead of dropping back to raw `$IPOS` span math plus a separate `$IPOS = pos $$STRING` write.
- 2026-04-01: Continued the real Phase 4 feature line with the missing live-cursor tail pair. `cursor_rest()` and `cursor_rest_len()` are now first-class helper contracts across the contract/scanner/canonical stack, which closes the remaining obvious “through end of input” gap on the current-cursor side after the anonymous-boundary and named-mark tail helpers. Future resume should treat live parser-cursor tail reads as covered helper surface now instead of dropping back to raw `pos $$STRING` plus `substr(...)` math.
- 2026-03-31: Captured a stricter standing documentation policy for the DSL surface. New helper methods are not considered fully landed unless the user-facing docs explain them clearly with extensive worked examples, and older already-landed DSL methods are now held to that same bar too. Future resume should treat documentation backfill for thinly documented helper families as required product work, not optional polish.
- 2026-03-31: Continued the real Phase 4 feature line with the missing named-mark tail pair. `capture_rest_from(name)` and `capture_rest_len_from(name)` are now first-class helper contracts across the contract/scanner/canonical stack, which closes the remaining obvious gap between anonymous `capture_rest()` and named-checkpoint capture flows. Future resume should treat named-mark “through end of input” reads as covered by the helper surface now instead of dropping back to `mark_pos(...)` plus raw `substr(...)`.
- 2026-03-31: Continued the real Phase 4 feature line with the missing right-edge location companions. `entry_end_line()`, `entry_end_col()`, `match_end_line()`, and `match_end_col()` are now first-class helper contracts across the contract/scanner/canonical stack. Future resume should treat immediate/local match right-edge reporting as complete on the helper surface now: position, line, and column each have direct readers, so new authoring should not reintroduce manual math around `entry_end_pos()` or `match_end_pos()`.
- 2026-03-31: Pivoted back to a real Phase 4 feature slice instead of another live-spec helper replay. `capture_slice_col()`, `mark_col(name)`, `cursor_col()`, `entry_col()`, and `match_col()` are now first-class 1-based column-read helpers across the contract/scanner/canonical stack. Future resume should treat same-shape column reporting as covered by the helper surface now instead of reintroducing raw position-plus-newline math in new `.spec` authoring.
- 2026-03-29: Continued the Phase 4 helper-adoption line with another bounded `vhdl` spend. `specs/vhdl.spec::subprogram_declaration`, `subprogram_body`, and `type_declaration` now use `entry_groups()` instead of `IMATCH_LIST` inside their helper-style `flat_array(...)` returns. Future resume should keep live-spec whole-group-list reads on `entry_groups()` rather than `IMATCH_LIST` when a helper-return path is already in place.
- 2026-03-29: Continued the Phase 4 helper-adoption line with another bounded `vhdl` spend. The package-name reads in `specs/vhdl.spec::package_declaration[1]` and `specs/vhdl.spec::package_body[1]` now use `entry_group(0)` instead of `scalar(IMATCH_LIST, 0)`. Future resume should keep simple live-spec immediate-match positional-group reads on `entry_group(...)` rather than reintroducing `IMATCH_LIST` indexing in migrated bands.
- 2026-03-28: Continued the Phase 4 helper-adoption line with another bounded live-spec token-reader spend. The top `comment` and `space` token readers in `specs/vhdl.spec` now use `entry_text()` instead of raw `$IMATCH`. Future resume should keep simple live-spec immediate-match text reads on `entry_text()` rather than raw `$IMATCH`.
- 2026-03-28: Continued the Phase 4 helper-adoption line with another bounded live-spec token-reader spend. `specs/tkgui.spec::sub_gui` now uses `entry_group(0)` instead of raw `@IMATCH_LIST` destructuring for the sub-gui entry-point name read. Future resume should keep simple immediate-match scalar reads on `entry_text()` / `entry_group(...)` rather than reintroducing raw `IMATCH` or `@IMATCH_LIST` access in live specs.
- 2026-03-28: Continued the Phase 4 helper-adoption line with another bounded live-spec token-reader spend. The simple token-return seams in `specs/regdef.spec` now use `entry_groups()` plus `flat_array(...)` instead of raw `@IMATCH_LIST` returns. Future resume should keep live-spec immediate-match group-list reads on `entry_groups()` rather than reintroducing raw `@IMATCH_LIST`.
- 2026-03-28: Continued the Phase 4 helper-adoption line with one bounded live-spec token-reader spend. The simple token readers in `specs/ds_vhistory.spec` now use `entry_groups()` plus `flat_array(...)` instead of returning raw `@IMATCH_LIST`. Future resume should keep direct immediate-match group-list reads on `entry_groups()` in live specs instead of reintroducing raw `@IMATCH_LIST` returns.

- 2026-03-28: Continued the Phase 4 helper-adoption line with one bounded live-spec spend. `specs/sdce.spec::sdc_esplit` now starts its anonymous capture boundary with `start_capture_slice()` instead of direct `assign(s(IPOS), 0)` initialization. Future resume should keep new anonymous boundary setup on the explicit helper surface instead of reintroducing direct `IPOS` writes in live specs.

- 2026-03-28: Continued the Phase 4 named-checkpoint line in one bounded helper-surface slice. `mark_line(name)` is now the direct 1-based line-read companion to `mark_pos(name)`, so rules no longer need to round-trip a stored named checkpoint through raw newline counting just to report where that remembered boundary landed. Future resume should keep named-checkpoint line reporting on `mark_line(name)` instead of reintroducing raw `substr($$STRING, 0, mark_pos(...)) =~ /\n/g` patterns.

- 2026-03-28: Continued the Phase 4 anonymous capture-boundary line in one bounded helper-surface slice. `capture_slice_pos()` is now the direct numeric read helper for the current anonymous capture boundary, which makes the write/read pair around that surface much clearer: `start_capture_slice()` moves the boundary and `capture_slice_pos()` reads it back as data. Future resume should keep direct anonymous-boundary position reads on `capture_slice_pos()` instead of reintroducing raw `$IPOS` reads in new `.spec` authoring.

- 2026-03-28: Added `SESSION_BOOTSTRAP.md` and appended an explicit final-line handoff in `README.md`: `Read SESSION_BOOTSTRAP.md and start from there.` The bootstrap file now captures the standing new-session startup task: read `README.md` plus the referenced `.md` files, re-analyze `LinkedSpec.pm` and its import tree, refresh `ARCHITECTURE_STATE.md` if needed, then continue execution from the roadmap. Future resume should treat that bootstrap file as the first task contract for a fresh session.

- 2026-03-28: Refreshed the live architecture reading after a new deep pass through `README.md`, the roadmap/docs set, `perl/LinkedSpec.pm`, and the active owner tree. The sharper current reading is that `LinkedSpec.pm` really is just a thin façade over `OwnerDispatch`, `ParserFactory` is the real named `.spec` resolution owner, `RuntimeContext` remains the strongest shared-state boundary, and the legacy plugin branch is still a real lazy cycle (`LinkedSpec -> PluginBridge -> PPlugin -> LinkedSpec::get_parser('pplugin')`) even though project direction already treats it as transition/removal machinery. Future resume should keep architecture work grounded in that owner-tree reading rather than the bare static `use` list.
- 2026-03-28: Continued the Phase 4 helper-adoption line in one bounded live-spec slice. The remaining obvious raw live-cursor and anonymous capture-boundary reads in `specs/vhdl.spec` now spend `cursor_pos()`, `capture_slice()`, and `start_capture_slice()` directly instead of raw `pos $$STRING`, raw anonymous-boundary `substr(...)`, and direct `assign(scalar(IPOS), pos $$STRING)` in those migrated bands. Future resume should keep obvious same-shape VHDL-style cursor/boundary flows on the current helper family before inventing new spellings.

- 2026-03-28: Continued the Phase 4 anonymous capture-boundary line in one bounded slice. `capture_slice_line()` is now the first-class read helper for “what 1-based line did the current anonymous capture slice start on?”, so later diagnostics no longer need to count newlines from `$IPOS` by hand. `specs/simenv.spec` now spends that helper in its repeated unmatched-delimiter LX paths. Future resume should keep anonymous capture-boundary line reporting on `capture_slice_line()` instead of reintroducing raw prefix-newline counting.

- 2026-03-28: Continued the Phase 4 anonymous capture-boundary line in one coherent slice. The preferred explicit lifecycle/action-block write helper is now `start_capture_slice()`, not `capture_slice_here()`, because the old name sounded like it returned captured text even though it only moved the anonymous `$IPOS` boundary to the current parser position. The new `capture_rest()` / `capture_rest_len()` helpers now cover the companion “read from the current anonymous boundary through end-of-input” case without raw Perl. Future resume should treat `start_capture_slice()` plus `capture_rest()` / `capture_rest_len()` as the honest user-facing surface, while keeping `capture_slice_here()` only as a compatibility alias.

- 2026-03-28: Continued the Phase 5 diagnostics-continuity line in one bounded runtime-context slice. Structured `runtime_ctx->{last_error}` payloads now also carry `top_rule` when the shared runtime context already knows the selected parser entrypoint, so runtime/parser failures are more self-contained and callers no longer have to read `top_rule` from one place and `last_error` from another just to recover the active parser identity. Future resume should treat `top_rule` as part of the structured diagnostics contract, alongside `owner_stage`, `spec_name`, and `spec_path`.

- 2026-03-28: Continued the remaining Phase 1A compatibility-wrapper cleanup in one bounded slice. `LinkedSpec::ActionRewriter::_delegate_emit_context_call(...)` now routes directly through `LinkedSpec::OwnerDispatch::dispatch_owner_call(...)` into `LinkedSpec::RuleIR::EmitContext`, so that legacy compatibility owner no longer carries a second local lazy-load / `can(...)` / symbol-call implementation on top of the shared owner-dispatch seam. Future resume should keep `ActionRewriter` shrinking toward a thin compatibility map over `EmitContext`, not as a separate delegation style.

- 2026-03-28: Continued the same Phase 5 runtime-owner cleanup line in a bounded way. `Runtime.pm`, `Compiler.pm`, and `SpecEntry.pm` now route their private `RuntimeContext` helper calls through the same shared `LinkedSpec::OwnerDispatch::dispatch_owner_call(...)` seam that `ParserFactory.pm` already used, so the active runtime/compile owners no longer carry a second local lazy-load-plus-symbol-call implementation for shared runtime-context dispatch. Future resume should keep runtime-context delegation on that one shared owner-dispatch shape instead of reintroducing ad hoc local wrappers.

- 2026-03-28: Renamed the preferred anonymous capture-boundary surface to `@capture_slice`, `capture_slice()`, and `capture_slice_len()`. `@capture_from_here`, `@move_pos`, `capture_slice_length()`, `capture_from_rule_start()`, and `capture_len_from_rule_start()` now remain as compatibility aliases only. Future resume should treat the new `capture_slice*` names as the honest description of the mutable `$IPOS` capture-boundary semantics.
- 2026-03-27: Added `capture_from_rule_start()` and `capture_len_from_rule_start()` as first-class Phase 4 helpers for the common “read from current rule-entry start to the left edge of the current local match” pattern without creating a named mark first. `specs/sdce.spec` now spends `capture_from_rule_start()` in its live split bands, and future resume should treat these helpers as the preferred backend-neutral replacement for raw `$IPOS`-anchored capture substrings when the left boundary is simply the current rule start.
- 2026-03-27: Corrected `cursor_line()` so it now reads the live parser cursor line from `pos $$STRING` instead of the stale rule-entry `$IPOS` snapshot. Future resume should treat `cursor_line()` as a true same-rule moving cursor helper, and should preserve that runtime contract in both rewrite-level and parser-runtime coverage.
- 2026-03-27: Added `cursor_pos()` as a first-class Phase 4 helper for direct current parser-position reads, with full contract/scanner/canonical lowering support and one live spend in `specs/sdce.spec`. Future resume should treat `cursor_pos()` as the preferred backend-neutral replacement for raw `pos $$STRING` when a rule wants the current parser position as data without storing a named mark first.
- 2026-03-27: `LinkedSpec::OwnerDispatch` now also owns a shared `build_dep_bundle(...)` helper for mixed callback/value dependency bundles, and `ParserFactory.pm` now uses that seam for its default trace/resolve/compile callback plus trace dump-level value bundle. Future resume should treat shared mixed dep-bundle assembly as the preferred direction for the remaining parser-core compatibility seams instead of letting active compile-path owners hand-build another mixed registry inline.
- 2026-03-27: The shared `LinkedSpec::OwnerDispatch::build_dep_map(...)` seam now also covers the remaining secondary ActionIR owners `ArrayPipeline`, `ControlFlow`, `Contracts`, `RewritePipeline`, `Diagnostics`, `StatementSplit`, `CanonicalEvents`, and `Scanner`. Future resume should treat broad default callback-map centralization as the current normal pattern across the ActionIR owner surface, with `ScannerCore` still defining the scanner-specific dependency contract underneath.
- 2026-03-27: `LinkedSpec::OwnerDispatch` now also owns a shared `build_dep_map(...)` helper, and the core ActionIR lowering owners `FlowExpr`, `ValueExpr`, `MethodLowering`, and `DeclareMethod` now assemble their `default_deps_for_package(...)` callback maps through that one shared seam. Future resume should treat shared dep-map assembly as the preferred Backbone Item 3 direction for active ActionIR owners instead of letting each owner reintroduce its own inline callback registry.
- 2026-03-27: `LinkedSpec::RuleIR::EmitContext` now centralizes its own ActionIR owner-key to package registry plus owner `default_deps_for_package(...)` lookup behind shared local helpers. Future resume should treat that bridge registry as the single source of truth for EmitContext-owned ActionIR package/dependency wiring instead of letting per-wrapper package/dependency duplication creep back in.
- 2026-03-27: Broadened parser-oriented list-context insertion helpers `flat_array(...)` / `flat_hash(...)` so they now accept composed aggregate helper expressions too, not only one named working array/hash. `.spec` rules can now splice results from helpers such as `sorted_keys(...)`, `sorted_values(...)`, `pick_keys(...)`, and `hash_copy(...)` directly into surrounding constructors and direct `return(payload)` list forms without temporary working variables or raw Perl flattening.
- 2026-03-27: Added parser-oriented pure hash/object snapshot helper `hash_copy(...)` so `.spec` rules can keep one stable copied hash/object value from a working hash or composed hash-valued expression inside assignment sources, nested scalar/hash composition, aggregate emptiness checks, and direct `return(payload)` expressions. The lowering now spans `MethodLowering`, `FlowExpr`, and `DeclareMethod`, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-27: `LinkedSpec::SpecEntry` and `LinkedSpec::RuleIR` now route their `Data::Dumper` helper loading through the same shared package-loading seam as the rest of the reduced compile-path owners. Future resume should treat those two rule-compilation owners as aligned with the broader owner-dispatch cleanup now instead of leaving bespoke bare `require Data::Dumper` calls there.
- 2026-03-27: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::Trace` too. That active trace owner now routes shared `Data::Dumper` loading and eval-error preservation through the same helper as the reduced compile-path owners. Future resume should treat `Trace.pm` as covered by that same owner-dispatch reduction line now instead of leaving another local helper seam on the runtime/diagnostic path.
- 2026-03-27: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::BootstrapSpec::Core` too. That active bootstrap grammar core owner now routes shared lazy package loading and eval-error preservation through the same helper as the reduced compile-path owners. Future resume should treat `BootstrapSpec/Core.pm` as covered by that same owner-dispatch reduction line now instead of leaving another local helper seam on the parser-core path.
- 2026-03-27: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::StatementSplit::Core` too. That active ActionIR statement-split core owner now routes shared lazy package loading through the same helper as the reduced compile-path owners. Future resume should treat `StatementSplit/Core.pm` as covered by that same owner-dispatch reduction line now instead of leaving another local helper seam on the ActionIR path.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::ScannerCore` too. That active ActionIR scanner-core owner now routes shared lazy package loading through the same helper as the reduced compile-path owners. Future resume should treat `ScannerCore.pm` as covered by that same owner-dispatch reduction line now instead of leaving another local helper seam on the ActionIR path.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::DeclareMethod` too. That active ActionIR declare/assign owner now routes shared lazy package loading, callback lookup, and eval-error preservation through the same helper as the reduced compile-path owners. Future resume should treat `DeclareMethod.pm` as covered by that same owner-dispatch reduction line now instead of leaving another local helper cluster on the ActionIR path.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::MethodLowering` too. That active ActionIR lowering owner now routes shared lazy package loading, callback lookup, and eval-error preservation through the same helper as the reduced compile-path owners. Future resume should treat `MethodLowering.pm` as covered by that same owner-dispatch reduction line now instead of leaving another local helper cluster on the ActionIR path.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::Contracts` too. That active ActionIR owner now routes shared lazy package loading, callback lookup, and eval-error preservation through the same helper as the reduced compile-path owners. Future resume should treat `Contracts.pm` as covered by that same owner-dispatch reduction line now instead of leaving another local helper cluster on the ActionIR path.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::ControlFlow` too. That active ActionIR owner now routes shared lazy package loading, callback lookup, and eval-error preservation through the same helper as the reduced compile-path owners. Future resume should treat `ControlFlow.pm` as covered by that same owner-dispatch reduction line now instead of leaving another local helper cluster on the ActionIR path.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::ArrayPipeline` too. That active ActionIR owner now routes shared lazy package loading, callback lookup, and eval-error preservation through the same helper as the reduced compile-path owners. Future resume should treat `ArrayPipeline.pm` as covered by that same owner-dispatch reduction line now instead of leaving another local helper cluster on the ActionIR path.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::FlowExpr` too. That active ActionIR owner now routes shared lazy package loading, callback lookup, and eval-error preservation through the same helper as the reduced compile-path owners. Future resume should treat `FlowExpr.pm` as covered by that same owner-dispatch reduction line now instead of leaving another local helper cluster on the ActionIR path.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::ValueExpr` too. That active ActionIR owner now routes shared lazy package loading, callback lookup, and eval-error preservation through the same helper as the reduced compile-path owners. Future resume should treat `ValueExpr.pm` as covered by that same owner-dispatch reduction line now instead of leaving another local helper cluster on the ActionIR path.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::Diagnostics` too. That active ActionIR owner now routes shared lazy package loading, callback lookup, and eval-error preservation through the same helper as the reduced compile-path owners. Future resume should treat `Diagnostics.pm` as covered by that same owner-dispatch reduction line now instead of leaving another local helper cluster on the ActionIR path.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::CanonicalEvents` too. That active ActionIR owner now routes shared lazy package loading, callback lookup, and eval-error preservation through the same helper as the reduced compile-path owners. Future resume should treat `CanonicalEvents.pm` as covered by that same owner-dispatch reduction line now instead of leaving one more local helper cluster on the ActionIR path.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::StatementSplit` too. That active ActionIR owner now routes shared lazy package loading, callback lookup, and eval-error preservation through the same helper as the reduced compile-path owners. Future resume should treat `StatementSplit.pm` as covered by that same owner-dispatch reduction line now instead of leaving one more local helper cluster on the ActionIR path.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::Scanner` too. That active ActionIR owner now routes shared lazy package loading, callback lookup, and eval-error preservation through the same helper as the reduced compile-path owners. Future resume should treat `Scanner.pm` as covered by that same owner-dispatch reduction line now instead of leaving one more local helper cluster on the ActionIR path.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::RewritePipeline` too. That active ActionIR owner now routes shared lazy package loading, callback lookup, and eval-error preservation through the same helper as the reduced compile-path owners. Future resume should treat `RewritePipeline.pm` as covered by that same owner-dispatch reduction line now instead of leaving one more local helper cluster on the ActionIR path.
- 2026-03-25: Extended `LinkedSpec::OwnerDispatch` into `RuleIR::EmitContext` too. The RuleIR-to-ActionIR bridge owner now routes its shared lazy package loading and eval-error preservation through the same helper as the other reduced thin wrappers. Future resume should treat `EmitContext.pm` as covered by that same owner-dispatch reduction line now, not as a separate local-helper family on the ActionIR boundary.
- 2026-03-25: Extended `LinkedSpec::OwnerDispatch` into `SpecEntry.pm` too. The rule-entry compile owner now routes its shared lazy package loading and eval-error preservation through the same helper as the other reduced thin wrappers. Future resume should treat `SpecEntry.pm` as covered by the same owner-dispatch reduction line now rather than leaving it as another local-helper holdout.
- 2026-03-25: Extended `LinkedSpec::OwnerDispatch` into `RuleIR.pm` too. The rule-planning owner now routes its shared lazy package loading and eval-error preservation through the same helper as the other reduced thin wrappers. Future resume should treat `RuleIR.pm` as covered by the same owner-dispatch reduction line now rather than leaving it as a separate local-helper family.
- 2026-03-25: Extended `LinkedSpec::OwnerDispatch` into `Compiler.pm` too. The compile-pipeline owner now routes its shared lazy package loading and eval-error preservation through the same helper as the other reduced thin wrappers. Future resume should treat `Compiler.pm` as covered by the same owner-dispatch reduction line now rather than as a special local-helper holdout.
- 2026-03-25: Extended `LinkedSpec::OwnerDispatch` into `Resolver.pm` and `Validation.pm` too. Those parser/frontend owners now route their shared Trace loading and eval-error preservation through the same helper as the other active thin wrappers. Future resume should treat the parser/frontend trace-wrapper seam as covered by the same owner-dispatch reduction line now, not as a separate local-helper family.
- 2026-03-25: Extended the shared `LinkedSpec::OwnerDispatch` seam into `BootstrapSpec.pm` too. The hardcoded bootstrap owner now routes its shared lazy package loading and eval-error preservation through the same helper as the other active compile-path wrappers. Future resume should keep using `OwnerDispatch` to absorb this kind of thin wrapper scaffolding on the compile path before reaching for any new local helper.
- 2026-03-25: Extended the new `LinkedSpec::OwnerDispatch` seam into `ParserFactory.pm` too. It now owns not only shared lazy package loading and `$@` preservation, but also the repeated callback/value lookup helpers that `ParserFactory` used for its default dependency map. `ParserFactory::_call_runtime_ctx(...)` now also routes through that same shared delegated-owner-call helper. Future resume should treat `OwnerDispatch` as the preferred place for any remaining thin wrapper plumbing on the active compile/runtime path.
- 2026-03-25: Continued the remaining Phase 1A / Backbone Item 3 cleanup by adding `LinkedSpec::OwnerDispatch` as the shared owner for thin-wrapper lazy package loading, delegated owner calls, and `$@` preservation. `LinkedSpec.pm`, `Runtime.pm`, and `ActionRewriter.pm` now all route that repeated scaffolding through the same helper instead of each carrying their own near-identical local implementation. Future resume should keep that module as the preferred seam for any remaining thin compatibility wrappers rather than reintroducing local `_require_pkg(...)` / `_call_preserving_err(...)` copies.
- 2026-03-25: Continued Phase 2 frontend hardening by rejecting stray unmatched top-level closing delimiters inside rule paragraphs during `validate_dsl_syntax(...)`. Validation now reports an explicit early diagnostic for malformed `}` / `)` / `]` balance errors instead of letting those drift into later bootstrap/runtime behavior, and the slice also corrected one malformed fluent lifecycle regression fixture that had previously slipped through with one extra `)` in the test spec itself.
- 2026-03-25: Continued the same package-backed HTTP extraction line one more step. `Plugin::HTTP` now owns `set_http_hostport(...)` and `set_http_localhost(...)` in addition to `httplink(...)`, `lighttpd.plg` now keeps thin compatibility wrappers for those helper subdefs, and `Plugin::String::var_subst_test(...)` now calls `Plugin::HTTP` plus `Plugin::CGI` directly instead of routing already-extracted helpers back through `LinkedSpec::run_plugin(...)`. Future resume should keep removing those small "already package-backed, but still bouncing through plugin dispatch" seams as soon as a clear package owner exists.
- 2026-03-25: Continued the plugin-removal track by extracting the still-used `httplink(...)` helper into `Plugin::HTTP`. `http.plg` now keeps only the thin compatibility wrapper for that subdef, while direct Perl callers such as `TableScript::http_exec(...)` and `Plugin::CGI::file_list_path2http(...)` now call `Plugin::HTTP::httplink(...)` directly instead of routing URL generation back through `LinkedSpec::run_plugin(...)`. Future resume should keep following that pattern: move shared helper behavior into normal package owners first, keep `.plg` wrappers only where compatibility still matters, and prefer direct package calls from Perl code over transition-era plugin-dispatch calls.
- 2026-03-25: Added a new live architecture snapshot document at `ARCHITECTURE_STATE.md`. It captures the current reading of `LinkedSpec.pm`, the owner/module tree, the main implementation spine, the ActionIR boundary, the remaining plugin legacy branch, and the current architectural hotspots. Future resume should treat that file as a maintained session-start snapshot: refresh it when a new deep analysis changes the best current reading of the project shape.
- 2026-03-25: Tightened the standing commit workflow rules. `COMMIT.md` no longer asks for the stale automatic `Co-Authored-By: Oz <oz-agent@warp.dev>` line, and `MEMORY.md` is now an explicit required update for each accepted implementation slice alongside `CHANGES.md` and `DEVELOPMENT_NOTES.md`. Future resume should treat `MEMORY.md` updates as mandatory continuity work, not optional polish.
- 2026-03-25: Corrected the first extracted package owners so they no longer live under `LinkedSpec/Plugin/`. The real owners now live in `Plugin::String` and `Plugin::CGI`, the old `LinkedSpec::Plugin::*` files have been deleted, and the thin `.plg` wrappers now point at the external `Plugin::*` namespace instead. Future work should keep LinkedSpec focused on spec lookup and compatibility seams rather than hosting plugin implementation packages under `LinkedSpec::*`.
- 2026-03-25: Captured a sharper architectural simplification for future work. LinkedSpec still needs named `.spec` resolution (`get_parser('foo')` locating `foo.spec` without path fiddling), but it does not objectively need dynamic plugin loading as a framework feature. Future resume should treat spec/resource lookup as the part to preserve and harden, while treating dynamic `.plg`/plugin execution as legacy behavior to retire rather than a capability to preserve under a cleaner API.
- 2026-03-25: Continued the package-backed extraction line with the next small plugin. `LinkedSpec::Plugin::CGI` now owns the old `cgi.plg` behavior (`file_list_path2http`), `cgi.plg` is reduced to a thin compatibility wrapper, and the new package owner resolves its remaining `httplink` dependency through explicit `LinkedSpec::run_plugin(...)` instead of a raw implicit plugin call. Future resume should keep following that pattern when an extracted package still depends on a not-yet-extracted plugin helper: keep the dependency explicit through the public API until that helper gets its own package owner.
- 2026-03-24: Captured a namespace policy for future `.plg` extraction work. `LinkedSpec::Plugin::*` is a reasonable home for migration-owned compatibility extractions and plugin-runtime transition code, but it is not automatically the permanent destination for every former `.plg`. Domain/application logic that happens to originate in a `.plg` file may deserve a separate namespace or an ordinary library module once extracted. Future resume should treat `LinkedSpec::Plugin::*` as a migration namespace first, not as a universal final rule.
- 2026-03-24: Started the first real `.plg`-to-`.pm` extraction slice instead of only rerouting callers. This historical step moved the old `string.plg` behavior (`var_subst`, `var_subst_test`) into a package owner before the temporary wrapper was later removed. Future resume should keep the later policy, not the temporary snapshot: move logic into a package owner, leave a small `.plg` wrapper only where compatibility still matters, and then delete it once repo-owned callers no longer need the old plugin name.
- 2026-03-24: Captured the intended `.plg` retirement path more explicitly so future plugin work does not drift into half-measures. The right migration is to move executable logic out of `.plg` files into explicit `.pm` package ownership first, then adapt and simplify from there; it is not necessary to preserve every `.plg` file as a permanent one-to-one `.pm` equivalent. Some migrated pieces should remain explicit plugin entrypoints, some should become ordinary library modules/helpers, and some legacy wrapper-style `.plg` files should disappear entirely once callers can use direct APIs. Future resume should treat “move behavior into `.pm`, then reshape/trim” as the intended path away from `.plg`.
- 2026-03-24: Continued the plugin/runtime modernization track by retiring the repo-owned `_get_parser(...)` plugin dependency. `Lispish.pm` now uses `LinkedSpec::get_parser('Lispish')` directly instead of `PPlugin->_get_parser(...)`, and the remaining repo-owned `.plg` callers that were still using `_get_parser(...)` (`ds_vhistory.plg`, `fsmgen.plg`, and `regtest.plg`) now also call `LinkedSpec::get_parser(...)` explicitly. At that point the old `plugin/spec.plg::_get_parser` helper remained only as compatibility surface for older external callers, not as the preferred parser-lookup contract for repo-owned code; the 2026-04-11 note above records that the shim has since been removed.
- 2026-03-24: Captured a project-wide Perl documentation convention so future implementation work stays readable as the codebase grows. Modified Perl packages should carry one short package-level block describing the owner/responsibility, and each routine in a touched package should carry a Perl-style block comment with at least function name, purpose, arguments, and return shape. The active plugin/runtime slice now backfills that convention in `LinkedSpec.pm`, `LinkedSpec::PluginBridge`, `LinkedSpec::PluginRegistry`, `PPlugin`, and `TableSort`; broader repo coverage should continue incrementally as packages are touched rather than as one giant doc-only churn pass.
- 2026-03-24: Added the missing explicit plugin-handler lookup seam. `LinkedSpec` now exposes `get_plugin(name)` as the public handler-lookup companion to `run_plugin(name, @args)`, and `LinkedSpec::PluginBridge` now owns `_lookup_plugin_name(...)` plus `_get_legacy_plugin(...)` so registry-first / legacy-fallback lookup has a named owner path too. `TableSort::GenericFilter(...)` now spends that new public API instead of calling `PPlugin->get(...)` directly.
- 2026-03-24: Added an explicit compatibility handoff for legacy module-owned AUTOLOAD shims. `LinkedSpec` now exposes `dispatch_plugin_autoload_name($autoload_name, @args)` as the public bridge entry for that narrow transition case, and `FSMGen.pm` now uses it instead of calling `PPlugin->exec(...)` directly. That keeps AUTOLOAD compatibility centralized under `LinkedSpec::PluginBridge` while reducing another direct dependency on `PPlugin`.
- 2026-03-24: Kept the plugin/runtime modernization track moving by spending the new explicit dispatch API in repo-owned callers that already know their plugin names. `HUtils::GenericFilter(...)`, `TableScript::http_exec(...)`, and the header-generation paths in `RTLUtils` now call `LinkedSpec::run_plugin(...)` directly instead of using `PPlugin::exec_plugin_name(...)`. That is a better end-state signal: repo code now prefers the public explicit API, while `PPlugin` is left as compatibility/runtime fallback rather than the owner new code should target.
- 2026-03-24: Logged the historical rationale behind the old plugin stack more explicitly so future replacement work preserves the right thing. The original `.plg` mechanism was mainly about low-ceremony discovered extension code: being able to throw helper logic into a lightweight file, let the framework locate it under the hood, and get executable `sub { ... }` payloads back without forcing callers through `.pm` / `.pl` packaging ceremony or path-fiddling. The part to retire is the "magical" coupling of discovery, parsing, caching, and execution behind `AUTOLOAD`, not the underlying ergonomics goal.
- 2026-03-24: Continued the plugin/runtime modernization track with an explicit public dispatch path. LinkedSpec now exposes `run_plugin(name, @args)` as the preferred plugin-call surface, reusing the same explicit-name `PluginBridge` owner path as the compatibility autoload bridge. That gives new code a clean path away from `AUTOLOAD` even before the legacy `.plg` fallback is retired.
- 2026-03-24: Clarified the intended plugin end-state before the next implementation slice. `AUTOLOAD` is no longer the desired primary plugin API; it remains only as transition glue while the project grows explicit plugin dispatch and normal package/registry ownership. `.plg` lookup and `PPlugin.pm` should be treated as legacy compatibility fallback, not as architecture to preserve.
- 2026-03-24: Started the next plugin/runtime modernization milestone. LinkedSpec now has an explicit `PluginRegistry` owner plus public `register_plugin(...)` / `register_plugins(...)` / `clear_registered_plugins()` façade entrypoints, and `PluginBridge` now consults that registry before loading the legacy `.plg` runtime. That keeps `AUTOLOAD` as compatibility glue while finally giving the project a real explicit plugin-registration surface for future package-based plugin migration.
- 2026-03-24: Pivoted away from another token-reader/helper-spending slice and landed a more semantic Phase 4 feature instead. Explicit `cursor_line()` / `entry_line()` / `match_line()` helpers now expose 1-based parser-state line numbers directly, and `specs/simenv.spec::begin_end_blocks` now spends `cursor_line()` / `match_line()` in its begin/end diagnostics instead of spelling raw prefix-newline counting inline.
- 2026-03-24: Kept the post-shorthand helper migration line moving in another debug-print grammar. The token-reader rules in `specs/DT.spec` now prefer `entry_text()` instead of `scalar(IMATCH)`, and the regression suite now locks that source-level migration intent alongside the pre-existing `DT` helper-flow checks.
- 2026-03-24: Kept the post-shorthand helper migration line moving in another debug-print grammar. The token-reader rules in `specs/operators_try.spec` now prefer `entry_text()` instead of `scalar(IMATCH)`, and the regression suite now locks that source-level migration intent alongside the pre-existing `operators_try` helper-flow checks.
- 2026-03-24: Kept the post-shorthand work moving on substantive helper migration. The debug-print token-reader rules in `specs/BNF.spec` now prefer `entry_text()` instead of `scalar(IMATCH)`, and the regression suite now locks that source-level migration intent alongside the pre-existing `BNF` helper-flow checks.
- 2026-03-24: Kept the post-shorthand work focused on substantive helper migration. The `anyvariable`, `variable_substitution`, and `comments` token-reader rules in `specs/simenv.spec` now prefer `entry_text()` instead of `scalar(IMATCH)`, and the regression suite now locks that source-level migration intent alongside the pre-existing `simenv` helper-flow checks.
- 2026-03-24: Stopped spending time on the optional `s(...)` / `a(...)` / `h(...)` shorthand migration and kept moving on the more substantive helper surface instead. The terminal token band in `specs/tablegrep.spec` now prefers `entry_group(0..2)` instead of `scalar(IMATCH_LIST, ...)`, and the regression suite now locks that source-level migration intent alongside the pre-existing `tablegrep` terminal/token helper-flow checks.
- 2026-03-24: Kept spending the concise alias surface on real live specs. The main `vhistory` orchestration band in `specs/ds_vhistory.spec` now prefers `s(...)` / `a(...)` for captured-entry reads, object-hierarchy accumulation, reset paths, and top-level return payload construction, and the regression suite now locks that source-level migration intent alongside the pre-existing `ds_vhistory` helper-flow behavior checks.
- 2026-03-24: Kept spending the concise alias surface on real live specs. The `substitute_top` orchestration band in `specs/hlink_substitution.spec` now prefers `s(retv)` for call-result assignment and `a(word_items)` for accumulator pushes and aggregate return flow, and the regression suite now locks that source-level migration intent alongside the pre-existing `hlink_substitution` helper-flow behavior checks.
- 2026-03-24: Kept spending the concise alias surface on real live specs. The split/accumulation band in `specs/sdce.spec` now prefers `s(...)` / `a(...)` for cursor tracking, accumulator pushes, split targets/sources, and return payload construction, and the regression suite now locks that source-level migration intent alongside the pre-existing `sdce` helper-flow behavior checks.
- 2026-03-24: Kept spending the concise alias surface on real live specs. The `LE` aggregation line in `specs/pplugin.spec::pplugin_top` now prefers `a(defs)` plus an `a(...)` constructor when accumulating discovered subdefs, and the regression suite now locks that source-level migration intent alongside the pre-existing `pplugin` metadata/runtime behavior checks.
- 2026-03-24: Kept spending the concise alias surface on real live specs. `specs/portmap.spec::bare_bit_slice` now prefers `a(...)` for the capture-group snapshot and its classification returns, and the regression suite now locks that source-level migration intent alongside the pre-existing `portmap` metadata/runtime classification checks.
- 2026-03-24: Kept spending the concise `s(...)` / `a(...)` / `h(...)` aliases on real live specs. The dense `parenthesis` orchestration band in `specs/Lispish.spec` now prefers `s(...)` / `a(...)` for working-state flow, accumulation, and return payload construction, while the compact token-reader band now also prefers `h(...)` for typed payload returns; the regression suite now locks that source-level migration intent alongside the pre-existing `Lispish` metadata/runtime behavior checks.
- 2026-03-24: Kept spending the concise `s(...)` / `a(...)` aliases on real live specs. The grouped reader band in `specs/lib_reader.spec` now prefers the short aliases in its cleanup, split, and return payload paths, and the regression suite now locks that source-level migration intent alongside the pre-existing `lib_reader` metadata/runtime behavior checks.
- 2026-03-24: Spent the new concise `s(...)` / `a(...)` aliases on a real core grammar too. The main orchestration and terminal-reader band in `specs/ebnf.spec` now prefers `s(...)` / `a(...)` over the longer `scalar(...)` / `array(...)` spellings, and the regression suite now locks that source-level migration intent alongside the pre-existing `ebnf` descriptor/runtime behavior checks.
- 2026-03-24: Added concise DSL container aliases `s(...)` / `a(...)` / `h(...)` as exact short spellings for `scalar(...)` / `array(...)` / `hash(...)`. The normalization now happens at the ActionIR method-expression seam, the scalar/array/hash symbol extractors now accept the short forms too, and the direct container-shape lowering branches now treat `a(name)` / `h(name)` as real first-class array/hash references instead of partial shortcuts.
- 2026-03-24: Kept spending the newer Phase 4 immediate-match helpers on real live specs. The compact token-reader band in `specs/Lispish.spec` now uses `entry_text()` / `entry_group(0)` instead of `scalar(IMATCH)` / `scalar(IMATCH_LIST, 0)`, and the pre-existing `Lispish` metadata/runtime regressions were already strong enough to lock the preserved token payload behavior without adding another dedicated test block.
- 2026-03-24: Continued the same “spend the new helper surface on real specs” line again after `lib_reader.spec`. `specs/portmap.spec::bare_bit_slice` now uses `entry_text()` / `entry_group(...)` / `entry_groups()` instead of `scalar(IMATCH)` / `scalar(IMATCH_LIST, ...)` / `flat_array(IMATCH_LIST)`, while the existing `portmap` metadata and runtime smoke regressions continue to lock the preserved `bare` / `bit` / `slice` / `constant` behavior.
- 2026-03-24: Continued the same “spend the new helper surface on real specs” line after `ebnf.spec`. The grouped entry-reader band in `specs/lib_reader.spec` now uses `entry_group(0)` / `entry_group(1)` instead of `scalar(IMATCH_LIST, ...)`, and regression coverage now locks one representative `lib_reader` runtime parse so the AST shape is preserved while the live spec gets less Perl-shaped.
- 2026-03-24: Started spending the newer Phase 4 immediate-match helper surface on a real core grammar instead of only adding helper contracts. The simple terminal-reader band in `specs/ebnf.spec` now uses `entry_text()` / `entry_group(0)` plus helper-method cleanup instead of raw `$IMATCH` reads, and regression coverage now locks those token rules as language-agnostic-ready.
- 2026-03-23: Extended the Phase 4 named-capture read surface again so it now has explicit direct presence probes too. `entry_has(name)` and `match_has(name)` now cover the common “does this named capture exist right now?” question without forcing specs through `has_key(entry_map(), ...)` or `has_key(match_map(), ...)` when the whole hash is not otherwise needed.
- 2026-03-23: Refined the new Phase 4 named-capture-hash helper surface so `entry_map()` / `match_map()` are now the preferred short spellings, while `entry_named_map()` / `match_named_map()` remain supported as compatibility aliases. The hash-lowering path recognizes both pairs equally.
- 2026-03-23: Extended Phase 4 so full positional capture-group lists now have explicit backend-neutral read helpers too. `entry_groups()` and `match_groups()` now snapshot the current immediate/local capture-group lists without raw `array(IMATCH_LIST)` / `array(LMATCH_LIST)` spellings in normal user-facing `.spec` examples.
- 2026-03-23: Extended Phase 4 so full named-capture hashes now have explicit backend-neutral read helpers too. `entry_named_map()` and `match_named_map()` now snapshot the current immediate/local named-capture hashes without raw `%IMATCH_HASH` / `%LMATCH_HASH` access, and the hash-lowering path now treats those helpers as real hash-valued expressions instead of rewrite-only curiosities.
- 2026-03-23: Extended Phase 4 so named regex captures now have explicit backend-neutral read helpers too. `entry_named(name)` and `match_named(name)` now expose the current immediate/local named-capture hash surfaces without raw `%IMATCH_HASH` / `%LMATCH_HASH` access, and `specs/pplugin.spec` now uses `entry_named(subname)` as the first migrated live use-site of that surface.
- 2026-03-20: Added explicit blind-call fluent post-call chaining as supported surface. `=> Rule.method(...)` and `=> Rule .method(...).method2(...)` now lower as sugar over the existing post-call `=> Rule { ... }` form, while `validate_dsl_syntax(...)` now rejects only malformed blind-call fluent starts such as `=> Rule.` or `=> Rule..return_a()` instead of rejecting blind-call fluent continuations outright.
- 2026-03-20: Extended Phase 2 frontend hardening so malformed action-edge fluent starts are rejected during `validate_dsl_syntax(...)` too. Validation now reports an early targeted diagnostic for empty method hops like `-> Rule.` and `-> Rule..push(...)`, instead of leaving those malformed fluent continuations to later bootstrap parse failure.
- 2026-03-20: Extended Phase 2 frontend hardening so rule paragraphs with open `{`, `(`, or `[` constructs are rejected at EOF during `validate_dsl_syntax(...)`. Validation now reports an explicit early “unclosed rule block” diagnostic instead of silently accepting unfinished open blocks at the end of the spec.
- 2026-03-19: Extended Phase 2 frontend hardening so rule-start detection stays top-level only inside open action/lifecycle/code blocks. Validation now keeps label-like lines such as `label:` inside open `{ ... }` blocks as block content instead of misclassifying them as new rule paragraphs, and the regex-token validation pass now follows that same block-depth boundary.
- 2026-03-19: Extended Phase 2 frontend hardening so malformed glued edge-target suffixes are rejected during `validate_dsl_syntax(...)` too. Validation now treats forms like `-> Rule-extra` and `=> Rule-extra` as invalid edge-target syntax instead of prefix-parsing them as `Rule`, while still preserving supported action-edge fluent suffixes and the separate indexed blind-call diagnostic for `=> Rule[0]`.
- 2026-03-19: Extended Phase 2 frontend hardening so malformed `@...` split-marker spellings are rejected during `validate_dsl_syntax(...)` too. Validation now gives a targeted early diagnostic for unknown split-boundary markers on both top-level rule-paragraph lines and same-line rule headers, while keeping `@capture_from_here` and compatibility alias `@move_pos` as the only supported spellings.
- 2026-03-19: Extended Phase 2 frontend hardening so same-line rule headers reject unsupported filler after the rule start or after a leading same-line regex cluster. Validation now rejects shapes like `Top:: random garbage` and `Top:: /a/ random garbage` earlier, and the validation-side regex literal matcher now handles escaped-slash literals like `/\/.+\//` correctly while those same-line checks run.
- 2026-03-19: Extended Phase 2 frontend hardening so unsupported top-level garbage inside a rule paragraph is rejected during `validate_dsl_syntax(...)` too. The validator now distinguishes between true paragraph-member freedom and arbitrary text: at top level inside a rule paragraph, supported starts remain regexes, lifecycle/code blocks, action edges, blind calls, split markers, multiline fluent continuation lines, or the next rule start.
- 2026-03-19: Extended Phase 2 frontend hardening so stray preamble text before the first rule paragraph is rejected during both `validate_spec_content(...)` and `validate_dsl_syntax(...)`. Validation now enforces the documented “sequence of rule paragraphs” contract more literally: after leading blank lines and `#` comments, the first real line must be a supported rule start.
- 2026-03-19: Extended Phase 2 frontend hardening so malformed glued worded rule-mode suffixes are rejected during `validate_dsl_syntax(...)` too. Validation now treats forms like `RuleName:ORX` and `RuleName::ANDX` as invalid rule-label syntax instead of accepting them as prefix matches on supported worded modes, and focused regression coverage now locks that early diagnostic.
- 2026-03-19: Extended Phase 2 frontend hardening so malformed extra-colon rule starts are rejected during `validate_dsl_syntax(...)` too. Validation now treats forms like `RuleName:::` as invalid rule-label syntax instead of letting them drift into later bootstrap parse failure, and focused regression coverage now locks that early diagnostic.
- 2026-03-19: Extended Phase 2 frontend hardening so missing top-level edge targets are rejected during `validate_dsl_syntax(...)` too. Validation now reports early targeted diagnostics for malformed forms like `-> { ... }` and `=> { ... }`, instead of letting incomplete action-edge or blind-call arrows fall through to generic bootstrap parse failure.
- 2026-03-19: Extended Phase 2 frontend hardening so malformed top-level edge-target syntax is rejected during `validate_dsl_syntax(...)` too. Validation now rejects malformed action-edge slot forms like `-> Rule[]` / `-> Rule[abc]`, rejects indexed blind-call targets like `=> Rule[0]`, and keeps those checks top-level aware so action-code strings and nested code do not get misread as real edges.
- 2026-03-19: Extended the first Phase 2 frontend-hardening pass so mixed `->` / `=>` rule paragraphs are rejected during `validate_dsl_syntax(...)` instead of only later in RuleIR. Validation now tracks edge families per rule paragraph, preserves the established mixed-edge diagnostic text/guidance, and regression coverage now locks both multiline and same-line mixed-edge rejection before bootstrap parse.
- 2026-03-19: Started Phase 2 frontend hardening with stricter rule-paragraph regex validation. `LinkedSpec::Validation::validate_dsl_syntax(...)` now validates leading regex tokens on both multiline and same-line rule paragraphs, focused regression coverage now locks both acceptance of current packed paragraph forms and rejection of malformed regex tokens before bootstrap parse, and the roadmap Phase 2 row now moves from `not started` to `in progress`.
- 2026-03-19: Locked same-line rule paragraphs as explicit supported format. Representative action-rule and blind-call examples are now regression-covered in both multiline and same-line layout, and the user guide now states plainly that same-line packing is still the same paragraph model rather than a different sublanguage.
- 2026-03-19: Locked the open-ended regex-slot indexing contract more explicitly. Focused regression coverage now proves that action-edge indexing continues cleanly through a representative four-regex rule (`-> A[3]` targeting the fourth regex), and the user guide now says plainly that the regex-slot model is not artificially capped at one, two, or three entries.
- 2026-03-19: Locked the paragraph-based `.spec` rule-body contract in docs and regression coverage. Representative action-rule and blind-call rule paragraphs now prove that after the leading `rule:` / `rule::` token, regexes, lifecycles, and edges can be interleaved without changing their structural meaning; the guide now states that this flexibility is part of the supported format, not an accidental parser side effect.
- 2026-03-19: Added explicit repeated-choice shorthand `OR+` as a real supported rule-label surface. `rule:OR+` now lowers with the same min-one repeated-choice contract as `rule:OR` and `rule:OR{1,}`, validation accepts the new spelling, regression coverage locks both metadata and runtime parity, and the rule-mode guide now teaches it as explicit shorthand rather than as a new execution family.
- 2026-03-19: Hardened bounded/shorthand repeated-choice blind-call behavior further. Added regression coverage for `:+`, `:OR{2,3}`, and `:OR{,2}` on blind-call rules, and repeat blind-call handlers now stop cleanly on zero-progress child success instead of looping forever when an optional child can succeed with an empty collection. This keeps lower-bound-zero repeated-choice child rules usable both standalone and under repeated parents.
- 2026-03-19: Hardened repeated-choice blind-call semantics. `REP_BCODE` no longer reuses the ordered-sequence blind-call body; it now repeats a child-rule choice step, so explicit `:OR` blind-call rules and historical bare `rule:` blind-call rules both follow repeated-choice semantics instead of accidentally behaving like repeated `AND` sequences. The docs were updated to treat this as supported current surface rather than a tracked clarification seam.
- 2026-03-19: Captured the blind-call mode-selection rule explicitly. `=> child_rule` makes a rule parser-step oriented, but it does not by itself imply ordered sequence. The rule label must continue to decide whether the blind-call body behaves as ordered sequence, single-choice dispatch, or repeated choice. Future implementation should therefore keep bare `rule:` semantics independent from whether a rule uses `->` or `=>`.
- 2026-03-19: Captured the design rationale for the “do not mix `->` and `=>` in one rule” contract. The current runtime/handler model treats `->` as regex-slot-driven rule execution and `=>` as parser-step orchestration/composition, so mixing them inside one rule blurs which mechanism owns input progress, grouping semantics, and return-shape meaning. Current policy therefore stays: one rule, one execution model.
- 2026-03-19: Locked the action-edge regex-slot indexing contract in docs and regression coverage. `-> rule` is now explicitly pinned as `-> rule[0]`, later indexed forms `-> rule[1]`, `-> rule[2]`, ... are pinned through bootstrap `reidx` checks, and same-rule recursive runtime parity now proves that `-> A` and `-> A[0]` stay equivalent on both base-case and recursive inputs.
- 2026-03-19: Locked the currently clear blind-call contract in docs and regression coverage. `=> child_rule` is now taught explicitly as parser-step composition rather than regex-slot dispatch, with sequence wrappers (`:&`, `:AND`, `:AND+`, `:AND{...}`) and single-choice wrappers (`:|`) documented as the clearest current forms; the remaining repeated-choice blind-call family on `rule:`, `:OR`, `:+`, and `:OR{...}` is now tracked explicitly as a contract-clarification seam instead of being overclaimed.
- 2026-03-19: Added parser-oriented middle-window array helper `slice(array_expr, start)` / `slice(array_expr, start, count)` so `.spec` rules can derive one canonical bounded subarray from direct arrays and composed array-valued expressions across array assignment sources, direct return payloads, reducer composition, and nested scalar(container, index) reads, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; invalid/negative start or count values clamp to `0`, and undefined/out-of-range sources yield `[]`.
- 2026-03-19: Added parser-oriented first-match array lookup helper `index_of(array_expr, needle_expr)` so `.spec` rules can derive one canonical zero-based location from direct arrays and composed array-valued expressions across assignment sources, direct return payloads, and numeric/definedness comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; `index_of(...)` returns `undef` for missing/non-array/no-match cases and returns `0` when the first match is already at index `0`.
- 2026-03-19: Added parser-oriented arithmetic reducer `num_range(array_expr)` so `.spec` rules can derive one canonical numeric max-minus-min span from direct arrays and composed array-valued expressions across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; `num_range(...)` returns `undef` for empty arrays, non-array sources, and non-numeric item sources, and otherwise returns the numeric maximum minus the numeric minimum so a one-item array yields `0`.
- 2026-03-19: Broadened parser-oriented arithmetic helpers `num_min(...)` and `num_max(...)` so they still accept two-or-more scalar operands, but now also accept one array-valued source as a reducer across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; unary array-reducer mode returns `undef` for empty arrays, non-array sources, and non-numeric item sources.
- 2026-03-18: Added parser-oriented arithmetic reducer `num_median(array_expr)` so `.spec` rules can derive one canonical numeric median from direct arrays and composed array-valued expressions across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; `num_median(...)` now returns `undef` for empty arrays, non-array sources, and non-numeric item sources, and averages the two middle items for even-length arrays after numeric ordering.
- 2026-03-18: Added parser-oriented arithmetic reducer `num_avg(array_expr)` so `.spec` rules can average numeric-looking direct arrays and composed array-valued expressions into one canonical scalar summary across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; `num_avg(...)` now returns `undef` for empty arrays, non-array sources, and non-numeric item sources.
- 2026-03-18: Added parser-oriented arithmetic reducer `num_sum(array_expr)` so `.spec` rules can sum numeric-looking direct arrays and composed array-valued expressions into one canonical scalar total across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; `num_sum(...)` now returns `0` for empty arrays and `undef` for non-array or non-numeric item sources.
- 2026-03-18: Added parser-oriented array order-inversion helper `reversed(...)` so `.spec` rules can flip direct arrays and composed array-valued expressions into one canonical last-added-first array view inside pure value compositions across assignment sources, direct return payloads, and reducer inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-18: Added parser-oriented deterministic array-ordering helper `sorted(...)` so `.spec` rules can normalize direct arrays and composed array-valued expressions into one canonical lexical array value inside pure value compositions across assignment sources, direct return payloads, and reducer inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-18: Added parser-oriented scalar boundary transforms `rm_prefix(...)` and `rm_suffix(...)` so `.spec` rules can strip one literal leading or trailing marker from normalized scalar values inside pure value compositions across assignment sources, direct return payloads, and comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces while preserving `undef` for missing operands and otherwise leaving unmatched values unchanged.
- 2026-03-18: Added parser-oriented scalar assembly helper `concat(...)` so `.spec` rules can build canonical string values from normalized scalar fragments inside pure value compositions across assignment sources, direct return payloads, and comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces while preserving `undef` for missing or aggregate/reference operands.
- 2026-03-18: Added parser-oriented arithmetic helper `num_clamp(...)` so `.spec` rules can keep bounded-result numeric normalization inside canonical value expressions across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; `num_clamp(...)` now preserves `undef` for missing, non-numeric-looking, or inverted-bound operands instead of silently swapping bounds.
- 2026-03-18: Added parser-oriented arithmetic helper `num_mod(...)` so `.spec` rules can keep parity, bucket, and wraparound-style integer composition inside canonical value expressions across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; `num_mod(...)` is intentionally integer-oriented and now preserves `undef` for missing, non-integer-looking, or divide-by-zero operands.
- 2026-03-18: Added parser-oriented scalar fallback helper `coalesce_nonempty(...)` so `.spec` rules can keep “first defined nonempty value wins” logic inside canonical value expressions across assignment sources, direct return payloads, and comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces while still preserving `0` as a valid chosen value.
- 2026-03-18: Added parser-oriented scalar substring predicate helper `contains_substr(...)` so `.spec` rules can keep normalized substring-membership flags inside canonical value expressions across assignment sources, direct return payloads, and flow conditions, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-18: Added parser-oriented pure hash/object single-field update helper `set_key(...)` so `.spec` rules can set one canonical field on working hashes and hash-valued expressions inside pure value compositions across assignment sources, direct return payloads, nested scalar reads, and flow-helper composition, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-18: Added parser-oriented pure hash/object single-field rename helper `rename_key(...)` so `.spec` rules can rename one canonical field on working hashes and hash-valued expressions inside pure value compositions across assignment sources, direct return payloads, nested scalar reads, and flow-helper composition, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-18: Added parser-oriented pure array-layering helper `concat_arrays(...)` so `.spec` rules can combine direct arrays, projected arrays, array constructors, and array-valued fallback chains into one canonical array value across declarations, assignments, direct return payloads, and reducer composition, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-18: Added parser-oriented literal string rewrite helper `replace_substr(...)` so `.spec` rules can keep separator cleanup and canonical-name normalization inside pure value expressions across assignment sources, direct return payloads, and flow comparisons, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- Deferred hardening note: fluent lifecycle descriptor metadata still under-reports `RETURN` coverage for the new value-layer aggregate emptiness helper family `is_empty(...)` / `is_nonempty(...)` even though the feature is otherwise rewrite-ready and regression-green; keep future lifecycle metadata-parity work separate from the landed feature contract.
- 2026-03-18: Added value-layer lowering for parser-oriented aggregate emptiness helpers `is_empty(...)` / `is_nonempty(...)` so the same aggregate-aware emptiness family now works inside assignments and direct `return(payload)` expressions too, not only in flow predicates; this intentionally preserved the existing flow-lowering shape instead of changing older flow semantics as part of the same slice.
- 2026-03-17: Added parser-oriented arithmetic helper `num_abs(...)` so `.spec` rules can keep absolute-distance and magnitude-style numeric composition inside canonical value expressions across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-18: Added parser-oriented arithmetic helpers `num_floor(...)`, `num_ceil(...)`, and `num_round(...)` so `.spec` rules can keep float-like scalar normalization and explicit integer-boundary rounding inside canonical value expressions across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; `num_round(...)` now uses explicit half-away-from-zero semantics.
- 2026-03-17: Added parser-oriented scalar regex predicate helper `matches(...)` so `.spec` rules can keep regex-membership flags inside canonical value expressions across assignment sources, direct return payloads, and flow conditions, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented arithmetic helpers `num_min(...)` and `num_max(...)` so `.spec` rules can keep floor/ceiling-style numeric composition inside canonical value expressions across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented arithmetic helpers `num_mul(...)` and `num_div(...)` so `.spec` rules can keep weighted counts, scaled metadata, and average-like reducer composition inside canonical value expressions across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; divide-by-zero now preserves `undef` rather than inventing a value.
- 2026-03-17: Added parser-oriented arithmetic helpers `num_add(...)` and `num_sub(...)` so `.spec` rules can keep numeric metadata adjustment and reducer-based arithmetic inside canonical value expressions across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Extended parser-oriented array `tail(...)` lowering so `.spec` rules can now supply one optional explicit drop-count argument too: `tail(array_expr)` still defaults to dropping `1` entry, while `tail(array_expr, n)` now works across direct arrays, projected arrays, array assignment sources, direct return payloads, reducer composition, and nested scalar(container, index) reads, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented array `take(...)` lowering so `.spec` rules can now derive one canonical prefix-array value from direct arrays, projected arrays such as `sorted_keys(...)` / `sorted_values(...)`, and array-valued fallback chains too: `take(array_expr)` keeps the first `1` entry by default, while `take(array_expr, n)` keeps the first `n` entries across array assignment sources, direct return payloads, reducer composition, and nested scalar(container, index) reads, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented array `drop_last(...)` lowering so `.spec` rules can now derive one canonical leading-array value by dropping the trailing suffix from direct arrays, projected arrays such as `sorted_keys(...)` / `sorted_values(...)`, and array-valued fallback chains too: `drop_last(array_expr)` drops the last `1` entry by default, while `drop_last(array_expr, n)` drops the last `n` entries across array assignment sources, direct return payloads, reducer composition, and nested scalar(container, index) reads, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented array `tail(...)` lowering so `.spec` rules can derive one canonical “rest of array after the first element” value from direct arrays, projected arrays such as `sorted_keys(...)` / `sorted_values(...)`, and array-valued fallback chains across assignment sources, return payloads, and reducer composition, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Broadened parser-oriented `scalar(container, key_or_index)` lowering so `.spec` rules can read one entry directly from composed array-valued and hash-valued helper expressions such as `sorted_keys(...)`, `merge_hash(...)`, and aggregate `coalesce(...)` chains across assignment sources, return payloads, and flow comparisons, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented scalar `length(...)` lowering so `.spec` rules can derive one canonical scalar-length value from normalized scalar expressions, nested payload reads, and scalar fallback chains across assignment sources, return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `first(...)` / `last(...)` array-boundary lowering so `.spec` rules can derive one canonical first/last scalar value from direct arrays, projected arrays such as `sorted_keys(...)` / `sorted_values(...)`, and array-valued fallback chains across assignment sources, return payloads, and flow comparisons, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Broadened parser-oriented `join_values(...)` lowering so `.spec` rules can reduce composed array-valued helper expressions such as `sorted_keys(...)`, `sorted_values(...)`, projected-object helpers, and array-valued `coalesce(...)` chains directly into one scalar string across assignment sources, direct return payloads, and flow comparisons, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `contains(...)` array-membership lowering so `.spec` rules can derive one canonical boolean-like membership flag from working arrays and projected array expressions such as `sorted_keys(...)`, `sorted_values(...)`, and aggregate `coalesce(...)` chains across assignment sources, return payloads, and flow conditions, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented aggregate-emptiness flow lowering so `is_empty(...)` / `is_nonempty(...)` now treat composed array-valued and hash-valued helper expressions as real aggregates instead of Perl reference truthiness, covering direct projections like `sorted_values(...)`, object-shape helpers like `pick_keys(...)` / `drop_keys(...)`, and aggregate `coalesce(...)` chains with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `sorted_values(...)` stable hash/object-to-array projection lowering so `.spec` rules can derive deterministic value-list arrays from working hashes and hash-valued expressions inside canonical value expressions, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Captured a deferred architecture-risk note so future implementation work keeps four concrete seams visible without treating them as current blockers:
  - `BootstrapSpec::Core` is still the main syntax/frontend concentration point,
  - semicolon-light and attached-block control flow still crosses a tight `StatementSplit` / `Scanner::FlowRules` / `ControlFlow` / `RewritePipeline` seam,
  - final runtime handler generation is still Perl string assembly plus eval inside `SpecEntry` / `Compiler`,
  - and `Validation.pm` still trails the supported DSL surface enough to remain a clear Phase 2 hardening target.
- 2026-03-17: Added parser-oriented `drop_keys(...)` pure hash/object-cleanup lowering so `.spec` rules can remove debug or transport-only fields from working hashes and hash-valued expressions inside canonical value expressions, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `pick_keys(...)` pure hash/object-projection lowering so `.spec` rules can keep only one explicit field set from working hashes and hash-valued expressions inside canonical value expressions, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `sorted_keys(...)` stable hash/object-to-array projection lowering so `.spec` rules can derive deterministic key-list arrays from working hashes and hash-valued expressions inside canonical value expressions, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `merge_hash(...)` pure hash/object-layering lowering so `.spec` rules can compose stable base metadata, fallback objects, and final normalization overlays inside canonical value expressions, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `count(...)` array-reducer lowering so `.spec` rules can derive one scalar size value from array variables and array-valued expressions across assignment sources, return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented scalar-normalization helper lowering for `trim(...)`, `lowercase(...)`, and `uppercase(...)` so `.spec` rules can normalize text canonically across assignment sources, return payloads, and comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `is_defined(...)` / `is_undefined(...)` flow-helper lowering so `.spec` rules can distinguish “missing” from “empty” across scalar fields, nested payload reads, and fallback chains, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `coalesce(...)` value-helper lowering so first-defined fallback chains now work canonically across assignment sources, return payloads, and comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Captured a design note that future scalar and aggregate helper growth should follow a disciplined functional-expression style: unlimited composition, clear helper signatures, pure-expression preference at the value layer, and parser-oriented semantics, while explicitly avoiding scope creep into lambdas, closures, currying, or a general-purpose FP sublanguage.
- 2026-03-17: Added a dedicated scalar-and-aggregate composition cookbook so string, integer, float-like, array, and hash helper usage is now taught in one place with many worked `.spec` examples and explicit no-DSL-fixed-depth composition guidance instead of leaving that story fragmented across only module-owner references.
- 2026-03-17: Regression-locked the representative `assign(array(...), filter_match(uniq(uppercase_each(array(...))), /.../)) -> lowercase_each(...) -> return(array_copy(...))` case-normalization/filter pipeline between fluent and structured authoring on both action-edge and lifecycle surfaces, so the uppercase/uniq/filter/lowercase family now sits inside the explicit method-like DSL contract too.
- 2026-03-16: Regression-locked mixed per-branch carriers on the outer attached-block switch family, so forms like `case("A") { ... } case("B") ... default { ... }` are now explicit supported surfaces on both structured and final-call fluent action-edge/lifecycle contexts.
- 2026-03-16: Regression-locked the representative `split(...) -> split_each(...) -> trim_each(...) -> filter_nonempty(...) -> return(array_copy(...))` array-normalization pipeline between fluent and structured authoring on both action-edge and lifecycle surfaces, so `split_each(...)` now sits inside the explicit method-like DSL contract instead of living mostly as a VHDL migration detail.
- 2026-03-16: Made zero-arg fluent control-flow markers explicit in the bootstrap renderer so `.else`, `.endif`, `.default`, `.endcase`, and `.endswitch` are now an intentional supported fluent surface rather than an accidental byproduct of later optional-scope normalization.
- 2026-03-16: Added mixed-carrier composite `if(...)` support so attached-block `if` chains can mix attached branch blocks with lighter plain marker bodies across one `if/elseif/else` chain, including the final-call fluent action-edge/lifecycle surface.

## Documentation Contract
- Treat readability as a first-class engineering requirement, not a cosmetic nice-to-have.
- Prefer explicit wording over compressed expert shorthand when the shorter phrasing risks ambiguity.
- Explain semantics, constraints, and tradeoffs directly instead of implying them.
- Use representative examples generously when they reduce ambiguity or help adoption.
- Use fuller worked examples for newly landed user-facing surfaces when terse snippets would undersell or obscure the real supported shape.
- Treat user-facing guides and worked examples as part of the end-user contract for supported surfaces, not as optional after-the-fact polish.
- Once the user clarifies a project-level documentation or adoption expectation, treat it as standing policy rather than waiting for repeated reminders.
- Add cross-cutting cookbook guides when a high-frequency user-facing surface would become too fragmented if it lived only in module-owner references.
- Do not intentionally obfuscate user-facing behavior, lowering contracts, or project goals.

## Current Session Notes (2026-03-16)
- Feature follow-up:
  - representative case-normalization/filter pipelines using `assign(array(...), filter_match(uniq(uppercase_each(array(...))), /.../))`, `lowercase_each(...)`, and `return(array_copy(...))` are now explicitly regression-locked between fluent and structured authoring,
  - that contract now spans both action-edge and lifecycle surfaces,
  - and the guides now present `lowercase_each(...)`, `uppercase_each(...)`, `uniq(...)`, and `filter_match(...)` as part of an explicit backend-neutral cleanup pipeline rather than mostly as low-level array-pipeline lowering machinery.
- Feature follow-up:
  - the outer attached-block switch family now explicitly supports mixed per-branch carriers such as `case("A") { ... } case("B") ... default { ... }`,
  - that contract is now regression-locked on both structured and final-call fluent surfaces across action-edge and the full lifecycle family,
  - and the control-flow guide now teaches the mixed-carrier shape with fuller worked examples instead of leaving it implicit.
- Feature follow-up:
  - representative array-normalization pipelines using `split(...)`, `split_each(...)`, `trim_each(...)`, `filter_nonempty(...)`, and `return(array_copy(...))` are now explicitly regression-locked between fluent and structured authoring,
  - that contract now spans both action-edge and lifecycle surfaces,
  - and the guides now present `split_each(...)` as part of a supported backend-neutral normalization pipeline rather than mostly as a corpus-specific migration anecdote.
- Feature follow-up:
  - the attached-block composite `if(...)` surface is now available as the final call on fluent action-edge and lifecycle chains too,
  - so `-> rule .if(cond) { ... } elseif(cond2) { ... } else { ... }` and `I.if(cond) { ... } elseif(cond2) { ... } else { ... }` now lower through the same canonical path as the structured attached-block baseline,
  - and the bootstrap chain parser now preserves trailing attached `elseif(...) { ... }` / `else { ... }` clauses after a fluent final-call `if(...)` branch block instead of dropping them.
- Feature follow-up:
  - the outer attached-block switch surface is now available as the final call on fluent action-edge and lifecycle chains too,
  - so `-> rule .switch(expr) { ... }` and `I.switch(expr) { ... }` now lower through the same canonical path as the structured outer-switch baseline,
  - and the bootstrap chain parser now binds an optional attached block to the final fluent call instead of dropping it.
- Feature follow-up:
  - the outer attached-block switch surface is now explicitly regression-locked for plain marker branches too,
  - so `switch(expr) { case(value) ... default ... }` is tracked as supported alongside the per-branch attached-block variant,
  - and the regression baseline now compares those two outer-switch branch carriers directly on action-edge plus the full lifecycle family.
- Feature follow-up:
  - added the block-bodied outer switch surface `switch(expr) { case(value) { ... } default { ... } }`,
  - it lowers equivalently to the inline composite switch attached-branch-block surface rather than to the marker-style `endswitch()` surface,
  - and the fix required widening switch-flow scanning so the whole attached outer-switch statement is recognized as canonical ActionIR instead of falling back as one RAW_PERL statement.
- Feature-priority follow-up:
  - structured marker-style control-flow now accepts bare zero-arg markers `else`, `endif`, `default`, `endcase`, and `endswitch`,
  - the implementation went through `MethodExpr` plus `FlowRules`,
  - and `t/phase0_regression.t` now locks that surface in statement splitting plus structured action-edge/lifecycle lowering.
- Extended same-family structured switch-branch parity into the combined deep marker seam.
- `t/phase0_regression.t` now compares each switch family’s own structured branch-body carriers when nested composite `if(...)` / `elseif(...)` flow carries the representative deeper alternating marker `if(...) ... switch(...) ... endif()` shape:
  - inline composite switch structured-argument branch blocks versus attached branch-block sugar,
  - and marker-style outer switch plain branch markers versus attached branch-block sugar.
- That parity lock spans action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Clarified the scope precisely:
  - this combined nested composite-`if` plus deeper alternating marker seam now preserves parity within each switch family’s own structured branch-body carriers too,
  - not only across the two outer switch families.
- Priority shift after this slice:
  - deeper marker `if(...)` / marker `switch(...)` cross-nesting hardening is no longer the near-term focus,
  - the next execution priority is adding missing user-facing DSL features first,
  - with additional hardening to resume later only if needed.
- Extended direct outer-switch-family parity on the common attached branch-block carrier for nested composite `if(...)` / `elseif(...)` flow one layer deeper into the deep marker contract.
- `t/phase0_regression.t` now compares inline composite outer `switch(...)` and marker-style outer `switch(...) ... endswitch()` directly when attached `case(value) { ... }` / `default() { ... }` branch blocks carry nested composite `if/elseif` flow whose inner branches themselves carry the representative deeper alternating marker `if(...) ... switch(...) ... endif()` shape.
- That direct outer-family parity lock spans action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Clarified the scope precisely:
  - this combined nested composite-`if` plus deeper alternating marker seam now has direct cross-family outer-switch parity coverage too,
  - not only the plain nested composite-if seam or the switch-only deep-marker seam.
- Extended direct outer-switch-family parity on the common attached branch-block carrier for nested composite `if(...)` / `elseif(...)` flow.
- `t/phase0_regression.t` now compares inline composite outer `switch(...)` and marker-style outer `switch(...) ... endswitch()` directly when attached `case(value) { ... }` / `default() { ... }` branch blocks carry:
  - the broader multi-`case(...)` nested inline-composite `switch(...)` shape,
  - and the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape.
- That direct outer-family parity lock spans action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Clarified the scope precisely:
  - those broader multi-`case(...)` nested switch shapes now have direct cross-family outer-switch parity coverage too,
  - not only same-family structured-branch parity or within-family attached-switch parity.
- Extended local structured-branch parity one level deeper for nested composite `if(...)` / `elseif(...)` flow on both switch families.
- `t/phase0_regression.t` now compares the same two local structured branch-body carrier pairs:
  - inline composite switch structured-argument branch blocks versus attached branch-block sugar,
  - and marker-style outer switch plain branch markers versus attached branch-block sugar,
  - for the broader multi-`case(...)` nested inline-composite `switch(...)` shape inside nested composite `if/elseif` flow.
- That parity lock spans action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Clarified the scope precisely:
  - the broader multi-`case(...)` nested inline-composite switch shape now preserves parity within each switch family's own structured branch-body carriers when it appears inside nested composite `if(...)` / `elseif(...)` flow too,
  - not only across attached switch branch blocks.
- Extended local structured-branch parity one level deeper for nested composite `if(...)` / `elseif(...)` flow on both switch families.
- `t/phase0_regression.t` now compares the same two local structured branch-body carrier pairs:
  - inline composite switch structured-argument branch blocks versus attached branch-block sugar,
  - and marker-style outer switch plain branch markers versus attached branch-block sugar,
  - for the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape inside nested composite `if/elseif` flow.
- That parity lock spans action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Clarified the scope precisely:
  - the broader multi-`case(...)` nested marker-switch shape now preserves parity within each switch family's own structured branch-body carriers when it appears inside nested composite `if(...)` / `elseif(...)` flow too,
  - not only across attached switch branch blocks.
- Extended local structured-branch parity for nested composite `if(...)` / `elseif(...)` flow on both switch families.
- `t/phase0_regression.t` now compares:
  - inline composite switch structured-argument branch blocks `case(value, { ... })` / `default({ ... })` against attached branch-block sugar `case(value) { ... }` / `default() { ... }`,
  - and marker-style outer switch plain branch markers against attached branch-block sugar,
  - for the same nested composite `if/elseif` shape.
- That parity lock spans action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Clarified the scope precisely:
  - nested composite `if(...)` / `elseif(...)` flow is now parity-locked within each switch family's own structured branch-body carriers too,
  - not only across the two outer switch families.
- Extended the nested composite `if(...)` / `elseif(...)` contract across the two outer switch families themselves.
- `t/phase0_regression.t` now compares inline composite outer `switch(...)` and marker-style outer `switch(...) ... endswitch()` directly on the common attached branch-block carrier `case(value) { ... }` / `default() { ... }` for nested composite `if/elseif` flow.
- That parity lock spans action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Clarified the scope precisely:
  - the nested composite-`if` contract now spans both outer switch families too,
  - not only same-family outer-switch surfaces.
- Extended the broader nested multi-`case(...)` inline-composite switch contract across the two outer switch families themselves.
- `t/phase0_regression.t` now compares inline composite outer `switch(...)` and marker-style outer `switch(...) ... endswitch()` directly on the common attached branch-block carrier `case(value) { ... }` / `default() { ... }` for nested multi-`case(...)` inline-composite `switch(...)` flow.
- That parity lock spans action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Clarified the scope precisely:
  - the broader multi-`case(...)` nested inline-switch contract now spans both outer switch families too,
  - not only same-family outer-switch surfaces.
- Extended the broader nested multi-`case(...)` marker-switch contract across the two outer switch families themselves.
- `t/phase0_regression.t` now compares inline composite outer `switch(...)` and marker-style outer `switch(...) ... endswitch()` directly on the common attached branch-block carrier `case(value) { ... }` / `default() { ... }` for nested multi-`case(...)` marker-style switch flow.
- That parity lock spans action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Clarified the scope precisely:
  - the broader multi-`case(...)` nested marker-switch contract now spans both outer switch families too,
  - not only the branch-body carriers or same-family surfaces.
- Extended the deep mutual marker-flow contract across the two outer switch families themselves.
- `t/phase0_regression.t` now compares inline composite outer `switch(...)` and marker-style outer `switch(...) ... endswitch()` directly on the common attached branch-block carrier `case(value) { ... }` / `default() { ... }` for the representative deeper alternating marker `if/switch` nesting shape.
- That parity lock spans action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Clarified the scope precisely:
  - the deeper alternating marker-nesting contract now spans both outer switch families too,
  - not only the branch-body carriers within each family.
- Extended the deep mutual marker-flow contract across the marker-style outer switch structured branch-body carriers:
  - plain branch-marker carrier `case(value)` / `default()`,
  - attached-block carrier `case(value) { ... }` / `default() { ... }`,
  - and the representative deeper alternating marker `if/switch` nesting chain is now regression-locked in parity across those two carriers on action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Clarified the scope precisely:
  - marker-style outer switch branch-body parity now covers the deeper alternating marker-nesting contract too,
  - not only the broader nested marker-switch shape.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice extends parity coverage inside an already-supported control-flow surface without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Extended the deep mutual marker-flow contract across the two inline composite switch structured branch-body carriers:
  - `case(value, { ... })` / `default({ ... })`,
  - `case(value) { ... }` / `default() { ... }`,
  - and the representative deeper alternating marker `if/switch` nesting chain is now regression-locked in parity across those two carriers on action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Clarified the scope precisely:
  - inline composite switch branch-body parity now covers the deeper alternating marker-nesting contract too,
  - not only the broader multi-case nested marker-switch shape.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice extends parity coverage inside an already-supported control-flow surface without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Extended the deep mutual marker-flow contract into composite `if(...)` branch bodies:
  - marker `if(...) ... endif()` and marker `switch(...) ... endswitch()` now have a representative deeper alternating nesting regression inside both structured inline composite-`if` branch blocks and attached-block composite-`if` branch bodies,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Clarified the scope precisely:
  - the no-DSL-fixed-cap marker-nesting contract covers those composite `if(...)` branch bodies as structured subcontexts too,
  - not only outermost action-edge or lifecycle structured blocks and attached switch branch blocks.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice extends the same deep marker-nesting contract into another already-supported structured subcontext without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Extended the deep mutual marker-flow contract into attached switch branch blocks:
  - marker `if(...) ... endif()` and marker `switch(...) ... endswitch()` now have a representative deeper alternating nesting regression inside marker-style switch attached branch blocks too,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Clarified the scope precisely:
  - the no-DSL-fixed-cap marker-nesting contract covers those attached switch branch blocks as structured subcontexts too,
  - not only outermost action-edge or lifecycle structured blocks.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice extends the same deep marker-nesting contract into an already-supported structured subcontext without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Locked the explicit deep mutual marker-flow contract:
  - marker `if(...) ... endif()` and marker `switch(...) ... endswitch()` are intended to allow arbitrarily deep mutual nesting in structured block contexts,
  - and the suite now carries a representative deeper alternating `if -> switch -> if -> switch -> if -> switch` regression across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Clarified the intended limit precisely:
  - there is no DSL-fixed semantic nesting cap here,
  - practical limits come from normal runtime recursion and resource ceilings instead.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice makes the marker-flow nesting contract explicit and regression-locked without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the matching marker-style outer-switch parity seam on the broader nested multi-`case(...)` marker-style `switch(...) ... endswitch()` shape:
  - plain marker branches `case(value)` / `default()`, and
  - attached switch branch-block sugar `case(value) { ... }` / `default() { ... }`
- That parity is now pinned across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`,
  - not only on the earlier flat helper-only branch-body baseline,
  - but on the broader nested multi-`case(...)` marker-switch shape too.
- Landed by normalizing scanner-side switch branch accounting too, so:
  - attached outer `case(value) { ... }` / `default() { ... }` branches no longer hide nested same-type marker events inside their attached blocks, and
  - inline-composite structured-argument carriers `case(value, { ... })` / `default({ ... })` now surface those same nested marker events through the branch-body carrier path too.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens parity coverage on already-supported marker-style outer switch surfaces without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the deeper parity seam between the two supported inline-switch structured branch-body carriers:
  - `case(value, { ... })` / `default({ ... })`, and
  - `case(value) { ... }` / `default() { ... }`
- That parity is now pinned on the broader nested multi-`case(...)` marker-style `switch(...) ... endswitch()` shape too,
  - not only on the earlier flat helper-only branch-body baseline,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Landed by normalizing scanner-side inline-switch branch event accounting too, so the structured-argument and attached-block carriers now report the same outer CASE/DEFAULT canonical metadata on this deeper seam.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens parity coverage on already-supported switch branch-body carriers without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the broader plain nested multi-`case(...)` marker-switch seam inside attached switch branch blocks:
  - inline composite and marker-style outer switch surfaces now cover nested marker-style `switch(...) ... endswitch()` flow with multiple `case(...)` arms,
  - without needing the extra inner composite-`if(...)` layer,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the combined deeper composite-`if/elseif/else` plus broader multi-`case(...)` nested marker-switch seam:
  - composite `if(...)` branch-block parity now covers the deeper `if/elseif/else` branch shape,
  - when those branches carry marker-style `switch(...) ... endswitch()` flow with multiple `case(...)` arms,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow parity without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the combined deeper composite-`if/elseif/else` plus broader multi-`case(...)` nested inline-switch seam:
  - composite `if(...)` branch-block parity now covers the deeper `if/elseif/else` branch shape,
  - when those branches carry inline-composite `switch(...)` flow with multiple `case(...)` arms,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow parity without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the broader multi-`case(...)` marker-switch parity seam inside attached switch branch blocks:
  - attached switch branch blocks now preserve parity between structured inline composite `if(...)` branch-block bodies and attached-block composite `if(...)` branch bodies on both outer switch families,
  - when those deeper `if/elseif/else` branches carry nested marker-style `switch(...) ... endswitch()` flow with multiple `case(...)` arms,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow parity without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the marker-style outer-switch follow-up for the attached-switch nested composite-if multi-case inline-switch parity seam:
  - attached switch branch blocks now preserve parity between structured inline composite `if(...)` branch-block bodies and attached-block composite `if(...)` branch bodies on both outer switch families,
  - including the marker-style outer `switch(...) ... endswitch()` family, not only the inline composite outer switch family,
  - when those deeper `if/elseif/else` branches carry nested inline-composite `switch(...)` flow with multiple `case(...)` arms,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow parity without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the attached-switch nested composite-if multi-case inline-switch parity follow-up:
  - inline composite outer switch attached branch blocks now preserve parity between structured inline composite `if(...)` branch-block bodies and attached-block composite `if(...)` branch bodies,
  - even when those deeper `if/elseif/else` branches themselves carry nested inline-composite `switch(...)` flow with multiple `case(...)` arms,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow parity without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the attached-switch nested composite-if marker-switch parity follow-up:
  - inline composite and marker-style outer switch attached branch blocks now preserve parity between structured inline composite `if(...)` branch-block bodies and attached-block composite `if(...)` branch bodies,
  - even when those deeper `if/elseif/else` branches themselves carry nested marker-style `switch(...) ... endswitch()` flow,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow parity without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the attached-switch nested composite-if/switch parity follow-up:
  - inline composite and marker-style outer switch attached branch blocks now preserve parity between structured inline composite `if(...)` branch-block bodies and attached-block composite `if(...)` branch bodies,
  - even when those deeper `if/elseif/else` branches themselves carry nested inline-composite `switch(...)` flow,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow parity without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the deeper composite-if nested inline-switch follow-up:
  - structured inline composite `if(...)` branch blocks and attached-block composite `if(...)` forms now have explicit coverage for nested inline-composite `switch(...)` flow in the deeper `if/elseif/else` branch shape too,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the deeper composite-if nested marker-switch follow-up:
  - structured inline composite `if(...)` branch blocks and attached-block composite `if(...)` forms now have explicit coverage for nested marker-style `switch(...) ... endswitch()` flow in the deeper `if/elseif/else` branch shape too,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the broader composite-if nested marker-switch follow-up:
  - structured inline composite `if(...)` branch blocks and attached-block composite `if(...)` forms now have explicit coverage for nested marker-style `switch(...) ... endswitch()` flow with multiple `case(...)` arms too,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the broader composite-if nested inline-switch follow-up:
  - structured inline composite `if(...)` branch blocks and attached-block composite `if(...)` forms now have explicit coverage for nested inline-composite `switch(...)` flow with multiple `case(...)` arms too,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the broader attached-switch nested inline-switch follow-up:
  - attached `case(value) { ... }` and `default() { ... }` branch bodies now have explicit coverage for nested inline-composite `switch(...)` flow with multiple `case(...)` arms too,
  - on both inline composite outer switch surfaces and marker-style outer switch surfaces,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the deeper attached-switch nested composite-if follow-up:
  - attached `case(value) { ... }` and `default() { ... }` branch bodies now have explicit coverage for nested composite `if/elseif/else` flow too,
  - on both inline composite outer switch surfaces and marker-style outer switch surfaces,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the next attached-switch structured-context follow-up:
  - attached `case(value) { ... }` and `default() { ... }` branch bodies now have explicit coverage for nested inline-composite `switch(...)` flow too,
  - on both inline composite outer switch surfaces and marker-style outer switch surfaces,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the next attached-switch structured-context follow-up:
  - attached `case(value) { ... }` and `default() { ... }` branch bodies now have explicit coverage for nested composite `if(...)` flow too,
  - on both inline composite outer switch surfaces and marker-style outer switch surfaces,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Regression-locked the next attached-switch structured-context follow-up:
  - attached `case(value) { ... }` and `default() { ... }` branch bodies now have explicit action-edge and lifecycle coverage for nested marker-style `switch(...) ... endswitch()` flow,
  - on both inline composite outer switch surfaces and marker-style outer switch surfaces,
  - with expected nested `SWITCH` / `CASE` / `DEFAULT` / `ENDSWITCH` helper coverage and zero unresolved-helper hits.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression coverage for already-supported structured control-flow contexts without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Fixed the compile-path rewrite gap for attached-block switch branch bodies that contain nested marker flow:
  - inline composite `switch(expr, case(value) { if(...) ... endif() }, default() { ... })` now keeps zero unresolved-helper hits,
  - structured marker-style `switch(expr) case(value) { if(...) ... endif() } default() { ... } endswitch()` now does the same,
  - and the lifecycle family is regression-locked for those supported nested-flow switch branch bodies too.
- Root cause and fix:
  - the rewrite pipeline was still executing nested child helper lowerers after a parent statement had already been replaced,
  - that stale child processing dirtied flow stacks and forced the pipeline to fall back to the original code,
  - the fix now skips later helper applications when the original source statement is no longer present in the rewritten code.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice fixes and broadens a supported attached-block switch surface without changing the track level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Landed attached-block switch branch sugar on the two switch surfaces that were explicitly staged first:
  - inline composite `switch(expr, case(value) { ... }, default() { ... })`,
  - and structured marker-style `switch(expr) case(value) { ... } default() { ... } endswitch()`,
  - both now lower cleanly on action-edge and lifecycle surfaces with zero fallback and zero unresolved-helper hits.
- Supporting work landed in the same slice:
  - statement splitting now treats `case(value) { ... }` and `default() { ... }` as complete top-level method-like statements in semicolon-light structured blocks,
  - flow scanning and contract rewrites now keep attached-block switch branches together as single branch statements,
  - and attached-block composite `if(cond) { ... }` was intentionally kept deferred to stay aligned with the tracked design note.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported switch syntax without changing the overall track level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit/Core.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Extended lifecycle-family regression coverage for inline composite control flow:
  - inline composite `if(...)` and `switch(...)` action-list forms are now regression-locked across `I`, `LS`, `LE`, `E`, `EX`, and `IT`,
  - the structured branch-block variants of those same inline composite forms are now regression-locked across that same remaining lifecycle family too,
  - and the docs now state explicitly that inline composite control-flow support is lifecycle-wide across `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`, with `LX` kept only as the representative example family.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice extends lifecycle-family regression coverage without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Made structured inline-composite `if(...)` branch bodies an explicit supported contract:
  - `if(cond, { ... }, elseif(cond2, { ... }), else({ ... }))` is now regression-locked on both action-edge and lifecycle surfaces,
  - those branch-body forms match the canonical inline action-list baseline on `ACODE` or `LXCODE`, canonical action-IR node coverage, fallback counts, and language-agnostic readiness,
  - and the guides now document them as the first structured branch-body extension for inline composite `if(...)`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice expands supported control-flow surface area without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Logged a control-flow design clarification before further syntax work:
  - marker-style `if(...) ... endif()` and `switch(...) ... endswitch()` are now explicitly treated as structured-block-context syntax,
  - they are not intended to remain a permanently free-standing fluent surface,
  - valid structured contexts include top-level action-edge `{ ... }` blocks, lifecycle blocks (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`), and nested structured branch bodies such as `case(value, { ... })`,
  - while self-contained composite forms like `switch(expr, case(...), default(...))` and `if(cond, ..., elseif(...), else(...))` remain distinct single-call surfaces.
- Tracker impact:
  - no live-status row changes,
  - because this slice records a design boundary rather than landing executable behavior.
- Validation snapshot for this slice:
  - `git diff --stat -- ROADMAP.md ROADMAP_V2.md USER_GUIDE.md USER_GUIDE_ActionIR_ControlFlow.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`

## Current Session Notes (2026-03-15)
- Landed the first inline composite `if(...)` slice:
  - argument-list forms such as `if(cond, action1(...), action2(...), elseif(cond2, ...), else(...))` now lower through the same control-flow owner path as the existing marker-style `if()/elseif()/else()/endif()` baseline,
  - action-edge and lifecycle surfaces are both regression-locked,
  - the new branch bodies reuse the same shared branch-action rewrite context as inline composite `switch(...)`,
  - and the flow scanner now recognizes those compact `if(...)` / `elseif(...)` / `else(...)` forms as the same canonical control-flow family for migration metadata.
- Clarified the docs accordingly:
  - inline composite `if(...)` is no longer only a feasibility note,
  - the first-step argument-list form is now a supported surface,
  - the later structured attached-block form `if(cond) { ... } elseif(cond2) { ... } else() { ... }` is now supported on action-edge and lifecycle block surfaces too,
  - and the compact form is documented as semantically equivalent to the marker baseline even though it does not materialize a separate explicit `ENDIF` helper node in metadata.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported control-flow authoring without changing the track level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Landed the structured attached-block composite `if(...)` follow-up:
  - `if(cond) { ... } elseif(cond2) { ... } else() { ... }` now lowers cleanly on action-edge and lifecycle block surfaces,
  - canonical scanning now treats attached-block `if/elseif/else` statements as part of the normal control-flow helper family,
  - the rewrite pipeline auto-closes attached-block `if` chains at the next statement boundary or end of block,
  - and branch-local structured lowering now preserves those same implicit closures inside nested branch contexts too.
- Regression coverage now locks the new attached-block `if(...)` surface against the structured inline-composite branch-block baseline on:
  - action-edge `{ ... }`,
  - `LX { ... }`,
  - and the remaining lifecycle family `I`, `LS`, `LE`, `E`, `EX`, and `IT`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice lands another supported method-like control-flow surface without changing the track level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Landed the next composite-`if(...)` branch-body regression follow-up:
  - nested inline-composite `switch(...)` forms now have explicit regression coverage inside both structured inline composite `if(...)` branch blocks and attached-block composite `if(...)` branch blocks,
  - including the attached switch-branch sugar `case(value) { ... }` / `default() { ... }`,
  - and the same nested switch contract is now locked across the full lifecycle family too.
- Clarified the docs accordingly:
  - composite-`if(...)` structured branch bodies are now documented as supporting nested switch flow generally,
  - not only the marker-style `switch(...) ... endswitch()` variant.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens regression-locked control-flow coverage without changing the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Landed the next composite-`if(...)` control-flow follow-up:
  - nested marker-style `switch(...) ... case(...) ... default() ... endswitch()` flow now stays fully rewrite-ready inside both structured inline composite `if(...)` branch blocks and attached-block composite `if(...)` branch blocks,
  - action-edge and full lifecycle-family coverage are now regression-locked for that nested switch shape,
  - and `StatementSplit::Core` now recognizes attached-block method statements with balanced parsing so attached `if/else` boundaries remain intact even when the branch body itself carries nested marker flow.
- Clarified the docs accordingly:
  - composite-`if(...)` structured branch bodies are now documented as supporting nested marker-style switch flow too,
  - not only flat helper sequences or nested marker-style `if(...) ... endif()` flow.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens supported structured control-flow behavior without changing the track level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit/Core.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Landed the first structured inline-composite switch branch-body extension:
  - `case(value, { ... })` and `default({ ... })` now lower through the same owner-local composite switch path as the existing action-list baseline,
  - semicolonless structured helper sequences inside those branch bodies are now supported on both action-edge and lifecycle surfaces,
  - and inline branch actions now share one rewrite context across the whole branch body so nested flow-state bookkeeping stays coherent.
- Clarified the docs accordingly:
  - the first structured inline-switch branch-body extension is now an active supported surface,
  - and, at that stage, attached-block sugar such as `case(value) { ... }` and `default() { ... }` was still deferred.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens the structured control-flow surface without changing the track level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Logged a deferred future-enhancement note for richer grouped rule semantics:
  - keep the current default repeated-alternative rule model as the active baseline,
  - treat bare `rule:` as the author-facing implicit `OR+` / `OR{1,}` reading for that baseline,
  - and defer only the remaining grouped-rule follow-ons such as standalone `AND`, shorthand `AND+`, and related rule strategies until the current rule model is solid.
- Tracker impact:
  - no live-status row changes,
  - because this slice records deferred design intent rather than landing active roadmap work.
- Validation snapshot for this slice:
  - `git diff --stat -- ROADMAP.md ROADMAP_V2.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`

## Current Session Notes (2026-03-15)
- Landed the lifecycle-family follow-up for semicolon-light structured control flow:
  - semicolonless structured `LS`, `LE`, `E`, `EX`, and `IT` `if/else/endif` plus `switch/case/default/endswitch` blocks are now regression-locked too,
  - and those lifecycle blocks match their fluent baselines on canonical action-IR node coverage, canonical hit counts, expected control-flow helper coverage, zero fallback, and language-agnostic readiness.
- Clarified the docs accordingly:
  - semicolon-light marker-style control-flow coverage now spans `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`,
  - so the base optional-semicolon marker syntax is no longer documented as effectively `LX`-only.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens lifecycle-family control-flow coverage without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-15)
- Landed the lifecycle-family follow-up for semicolon-light generic helper blocks:
  - semicolonless structured `LS`, `LE`, `E`, `EX`, and `IT` helper sequences are now regression-locked too,
  - and those lifecycle blocks match their fluent baselines on canonical action-IR node coverage, canonical hit counts, expected `DECLARE` / `ASSIGN` / `RETURN` / `RETURN_A` helper coverage, zero fallback, and language-agnostic readiness.
- Clarified the exact lifecycle-wide state in the roadmap/docs:
  - generic helper-only semicolon-light regression coverage now spans `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`,
  - while the control-flow-heavy semicolon-light lifecycle slice is still the narrower `LX`-anchored coverage for now.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens lifecycle-family regression coverage without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-14)
- Added `ROADMAP_V2.md` as a shorter execution-oriented companion to `ROADMAP.md` so the active plan is easier to inspect without collapsing the long-form roadmap.
- Tightened the semicolon-light lifecycle policy wording:
  - the lifecycle family is explicitly `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`,
  - and `I { ... }` plus `LX { ... }` are now documented clearly as current regression anchors rather than the boundary of the intended policy.
- Tracker impact:
  - no live-status row changes,
  - because this slice strengthens execution tracking and documentation precision without moving any roadmap level.
- Validation snapshot for this slice:
  - `git diff --stat -- ROADMAP.md ROADMAP_V2.md USER_GUIDE.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`

## Current Session Notes (2026-03-14)
- Landed the generic `LX` follow-up for semicolon-light lifecycle blocks:
  - semicolonless non-control-flow `LX { ... }` helper sequences are now regression-locked too,
  - including a supported `declare(...)` / `assign(...)` / `call(...)` / `return(...)` chain,
  - and those blocks now match the fluent `LX.` baseline on `LXCODE`, canonical action-IR coverage, zero fallback, and language-agnostic readiness without needing `;` separators.
  - Clarification: if semicolon-light structured authoring applies to one lifecycle block family, it is intended to apply to the others too unless an explicit documented exception exists; `I { ... }` and `LX { ... }` are current regression locks for that broader lifecycle-wide direction.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported semicolon-light lifecycle authoring without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-14)
- Landed the generic structured-block follow-up for semicolon-light method DSL authoring:
  - semicolonless helper-only `{ ... }` blocks are now regression-locked on action-edge surfaces too,
  - semicolonless helper-only lifecycle blocks like `I { ... }` are now regression-locked as well,
  - and both forms now match the fluent baseline on lowered output plus zero-fallback, zero-unresolved, language-agnostic migration metadata without needing `;` separators.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported semicolon-light structured authoring without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-14)
- Landed the lifecycle follow-up for semicolon-light structured control flow:
  - semicolonless marker-style `if(...)` / `else()` / `endif()` and `switch(...)` / `case(...)` / `default()` / `endswitch()` forms are now regression-locked on structured lifecycle `LX { ... }` blocks too,
  - those lifecycle blocks now match the fluent baseline on `LXCODE` lowering,
  - and they preserve zero-fallback, zero-unresolved, language-agnostic migration metadata without needing `;` separators between top-level method statements.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported structured lifecycle control-flow authoring without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-14)
- Landed the first semicolon-light structured control-flow follow-up:
  - `StatementSplit::Core` now accepts adjacent top-level method-like statements without `;` separators,
  - structured helper-only `if(...)` / `else()` / `endif()` and `switch(...)` / `case(...)` / `default()` / `endswitch()` blocks now compile cleanly without trailing semicolons,
  - and the semicolonless structured action-edge control-flow forms now match the fluent baseline on lowered output plus language-agnostic migration metadata.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported structured control-flow authoring without moving the track level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit/Core.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Notes (2026-03-14)
- Recorded an explicit raw-Perl-free `.spec` policy design note:
  - `.spec` authoring is intended to become permanently raw-Perl-free,
  - raw Perl in `.spec` is obsolete compatibility debt, not a co-equal syntax surface to preserve,
  - remaining raw Perl occurrences should be flagged and migrated to canonical method-like DSL forms,
  - and the planned semicolon-light control-flow direction applies only to canonical DSL blocks rather than to any mixed Perl/DSL parsing model.
- Tracker impact:
  - no live-status row changes,
  - because this is a tracked policy/design-note slice rather than a landed enforcement slice.
- Validation snapshot for this slice:
  - `git diff --stat -- ROADMAP.md USER_GUIDE.md USER_GUIDE_ActionIR_ControlFlow.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`

## Current Session Notes (2026-03-14)
- Recorded the agreed pre-implementation design note for composite control-flow syntax:
  - keep current inline composite `switch(expr, case(...), default(...))` action-list syntax as the composite baseline,
  - do not pursue chained branch-body syntax like `case(value, m1(...).m2(...))`,
  - require one branch header and one body carrier only,
  - prefer `case(value, { ... })` as the first structured inline-switch extension,
  - reserve attached-block `case(value) { ... }` / `default() { ... }` as later syntax sugar at that stage,
  - and treat inline composite `if(cond, ..., elseif(...), else(...))` as the first landed `if(...)` step, with the later structured attached-block form `if(cond) { ... } elseif(cond2) { ... } else() { ... }` now landed on structured block surfaces too.
- Tracker impact:
  - no live-status row changes,
  - because this is a tracked design-note slice rather than an implementation slice.
- Validation snapshot for this slice:
  - `git diff --stat -- ROADMAP.md USER_GUIDE_ActionIR_ControlFlow.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`

## Current Session Notes (2026-03-14)
- Recorded a control-flow syntax ergonomics clarification:
  - current guide examples still document the syntax that is supported today,
  - but forms like `else();` and `endif()` are not being treated as the final UX target,
  - and the roadmap now explicitly keeps a follow-up open to revisit `if` / `else` / `switch` concrete syntax, including lower-friction block forms and inline composite `if(...)` exploration.
- Tracker impact:
  - no live-status row changes,
  - because this is a design-direction clarification rather than a landed syntax feature.
- Validation snapshot for this slice:
  - `git diff --stat -- ROADMAP.md USER_GUIDE.md USER_GUIDE_ActionIR_ControlFlow.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`

## Current Session Notes (2026-03-14)
- Landed the next method-DSL lowering-equivalence follow-up on nested accessor payload composition:
  - supported `scalaref(base, path)` plus indexed/keyed `scalar(...)` payload reads are now regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces,
  - and those forms now explicitly agree on lowered output, canonical action-IR coverage, and zero-fallback migration metadata.
- The method-like DSL track still stays `in progress`; this slice deepens supported nested accessor payload equivalence coverage without moving the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=287`)

## Current Session Notes (2026-03-14)
- Landed the next method-DSL branch-local equivalence follow-up on canonical call-result capture:
  - supported `assign(scalar(retv), call(rule))` chains are now regression-locked inside `if/elseif` and `switch/case` control-flow bodies on both action-edge and lifecycle surfaces,
  - and those branch-local forms now explicitly agree on lowered output, canonical action-IR coverage, and zero-fallback migration metadata.
- The method-like DSL track still stays `in progress`; this slice deepens supported branch-local canonical call-value equivalence coverage without moving the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=285`)

## Current Session Notes (2026-03-14)
- Landed the next method-DSL lowering-equivalence follow-up on canonical call-result capture:
  - supported `assign(scalar(retv), call(rule))` forms are now regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces,
  - and those forms now explicitly agree on lowered output, canonical action-IR coverage, and zero-fallback migration metadata.
- The method-like DSL track still stays `in progress`; this slice deepens supported canonical call-value capture equivalence coverage without moving the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=281`)

## Current Session Notes (2026-03-14)
- Landed the next method-DSL branch-local equivalence follow-up on flat-list payload helpers:
  - supported `flat_array(...)` and `flat_hash(...)` return payloads are now regression-locked inside `if/elseif` and `switch/case` control-flow bodies on both action-edge and lifecycle surfaces,
  - and those branch-local forms now explicitly agree on lowered output, canonical action-IR coverage, and zero-fallback migration metadata.
- The method-like DSL track still stays `in progress`; this slice deepens supported branch-local flat-list payload equivalence coverage without moving the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=279`)

## Current Session Notes (2026-03-14)
- Landed the next method-DSL branch-local equivalence follow-up on string-join payload helpers:
  - supported `join_values(delimiter, array(...))` return payloads are now regression-locked inside `if/elseif` and `switch/case` control-flow bodies on both action-edge and lifecycle surfaces,
  - and those branch-local forms now explicitly agree on lowered output, canonical action-IR coverage, and zero-fallback migration metadata.
- The method-like DSL track still stays `in progress`; this slice deepens supported branch-local joined-string payload equivalence coverage without moving the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=275`)

## Current Session Notes (2026-03-14)
- Landed the next method-DSL lowering-equivalence follow-up on string-join payload helpers:
  - supported `join_values(delimiter, array(...))` payload forms are now regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces,
  - and those forms now explicitly agree on lowered output, canonical action-IR coverage, and zero-fallback migration metadata.
- The method-like DSL track still stays `in progress`; this slice deepens supported joined-string payload equivalence coverage without moving the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=271`)

## Current Session Notes (2026-03-14)
- Landed the next method-DSL branch-local equivalence follow-up on snapshot payload helpers:
  - supported `array_copy(...)` and compatibility `array_values(...)` return payloads are now regression-locked inside `if/elseif` and `switch/case` control-flow bodies on both action-edge and lifecycle surfaces,
  - and those branch-local forms now explicitly agree on lowered output, canonical action-IR coverage, and zero-fallback migration metadata.
- The method-like DSL track still stays `in progress`; this slice deepens supported branch-local snapshot-payload equivalence coverage without moving the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=269`)

## Current Session Notes (2026-03-14)
- Landed the next method-DSL lowering-equivalence follow-up on snapshot payload helpers:
  - supported `array_copy(...)` and compatibility `array_values(...)` payload forms are now regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces,
  - and those forms now explicitly agree on lowered output, canonical action-IR coverage, and zero-fallback migration metadata.
- The method-like DSL track still stays `in progress`; this slice deepens supported snapshot-payload equivalence coverage without moving the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=265`)

## Current Session Notes (2026-03-14)
- Landed the next method-DSL lowering-equivalence follow-up on flat-list insertion helpers:
  - supported `flat_array(...)` and `flat_hash(...)` payload forms are now regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces,
  - and those forms now explicitly agree on lowered output, canonical action-IR coverage, and zero-fallback migration metadata.
- The method-like DSL track still stays `in progress`; this slice deepens supported list-context insertion equivalence coverage without moving the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=263`)

## Current Session Notes (2026-03-14)
- Landed the next method-DSL switch-equivalence follow-up on both action-edge and lifecycle surfaces:
  - supported inline composite `switch(..., case(...), default(...))` forms are now regression-locked between fluent and structured authoring,
  - and those forms now explicitly agree on lowered output, canonical action-IR coverage, and zero-fallback migration metadata even when the inline `case(...)` and `default(...)` bodies contain supported helper sequences.
- The method-like DSL track still stays `in progress`; this slice deepens supported inline switch equivalence coverage without moving the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=261`)

## Current Session Notes (2026-03-14)
- Landed the next method-DSL branch-local equivalence follow-up on lifecycle surfaces:
  - supported multi-step helper sequences inside `LX` `if(...)` / `elseif(...)` and `switch(...)` / `case(...)` bodies are now regression-locked between fluent and structured forms,
  - and those lifecycle forms now explicitly agree on lowered `LXCODE`, canonical action-IR coverage, and zero-fallback migration metadata.
- The method-like DSL track still stays `in progress`; this slice broadens supported lifecycle branch-local equivalence coverage without moving the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=259`)

## Current Session Notes (2026-03-14)
- Landed the next method-DSL branch-local equivalence follow-up on action-edge surfaces:
  - supported multi-step helper sequences inside `if(...)` / `elseif(...)` and `switch(...)` / `case(...)` bodies are now regression-locked between fluent and structured forms,
  - and those action-edge forms now explicitly agree on compiled `ACODE`, canonical action-IR coverage, and zero-fallback migration metadata.
- The method-like DSL track still stays `in progress`; this slice broadens supported action-edge branch-local equivalence coverage without moving the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=257`)

## Current Session Notes (2026-03-14)
- Landed the next method-DSL branch-local equivalence follow-up on lifecycle surfaces:
  - supported `LX` fluent control-flow forms now have regression locks against their structured lifecycle-block equivalents for both `if(...)` / `elseif(...)` and `switch(...)` / `case(...)`,
  - and those lifecycle forms now explicitly agree on lowered `LXCODE`, canonical action-IR coverage, and zero-fallback migration metadata.
- The method-like DSL track still stays `in progress`; this slice broadens supported lifecycle control-flow equivalence coverage without moving the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=255`)

## Current Session Notes (2026-03-14)
- Landed a real method-DSL branch-local fix rather than just a wording clarification:
  - the bootstrap fluent-chain renderer no longer truncates a chain when a general-payload `return(...)` appears inside `if(...)` / `elseif(...)` or `switch(...)` / `case(...)` branch bodies,
  - and supported fluent versus structured branch-local control-flow forms are now regression-locked to the same canonical action-IR coverage and zero-fallback migration metadata.
- The method-like DSL track still stays `in progress`; this slice fixes a real branch-local equivalence seam on supported control-flow surfaces without moving the tracker level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec/Core.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=253`)

## Current Session Notes (2026-03-14)
- Clarified another method-DSL equivalence requirement:
  - fluent-versus-structured equivalence is expected not only for top-level action/lifecycle sequences,
  - but also inside `if(...)` / `elseif(...)` branches and `switch(...)` / `case(...)` action bodies.
- Logged that requirement explicitly in the roadmap and user guides so the target surface is unambiguous.
- This is a wording/guide-policy clarification only; the method-like DSL tracker row stays `in progress`.

## Current Session Notes (2026-03-14)
- Landed another method-like DSL equivalence follow-up on action-edge surfaces:
  - the supported collection-hash method shape is now regression-locked on `-> rule .m1(...).m2(...)` versus `-> rule { m1(...); m2(...); }` too,
  - and those fluent versus structured action-edge forms now agree on compiled action output plus zero-unresolved / zero-fallback migration metadata.
- The method-like DSL track still stays `in progress`; this slice broadens fluent/block equivalence coverage on supported action-edge surfaces without changing the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=251`)

## Current Session Notes (2026-03-14)
- Clarified the method-DSL documentation policy:
  - the roadmap and relevant guides now state explicitly that unlimited nested method composition in arguments is a supported capability,
  - but the docs should show representative examples only rather than trying to catalog every legal nesting combination.
- This is a wording/guide-policy cleanup only; the method-like DSL tracker row stays `in progress`.

## Current Session Notes (2026-03-14)
- Landed another method-like DSL follow-up for collection-valued hash/object composition:
  - `declare(hash, ...)`, `assign(hash(...), ...)`, `push_value(array(...), hash(...))`, and `return_array(..., hash(...))` now have regression coverage for helper-only nested array-pipeline composition inside hash/object-valued shapes,
  - and fluent versus structured lifecycle surfaces now report matching zero-unresolved / zero-fallback metadata for that supported collection-hash shape too.
- The method-like DSL track still stays `in progress`; this slice broadens supported collection-hash coverage but does not change the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=250`)

## Current Session Notes (2026-03-14)
- Landed another method-like DSL follow-up for collection-valued nested composition:
  - `declare(array, ...)`, `assign(array(...), ...)`, and nested hash/array payload values now have regression coverage for helper-only nested array-pipeline composition,
  - and fluent versus structured lifecycle surfaces now report matching zero-unresolved / zero-fallback metadata for that supported collection-value shape too.
- The method-like DSL track still stays `in progress`; this slice broadens supported collection-value coverage but does not change the tracker level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=249`)

## Current Session Notes (2026-03-14)
- Landed a method-like DSL follow-up for nested return payloads:
  - helper-only nested array-pipeline composition inside `return(array(...))` now lowers cleanly,
  - and fluent versus structured method surfaces now report matching zero-unresolved / zero-fallback migration metadata for that supported return-payload shape.
- The method-like DSL track remains `in progress`; this slice deepens supported coverage but does not change the tracker level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=248`)

## Current Session Notes (2026-03-14)
- Started the dedicated Method-like DSL migration track in roadmap terms.
- Landed a focused equivalence lock showing that helper-only fluent action chains and structured `{...}` action blocks already lower identically, and that helper-only lifecycle chains with nested composed arguments already lower identically on the currently supported lifecycle surface.
- `ROADMAP.md` now marks `Method-like DSL migration track` as `in progress` on the strength of that dedicated migration work, while keeping Backbone Item 3 groundwork explicitly separate from the migration-track status.
- The claim is intentionally narrow: this start slice does not yet assert blanket fluent/block equivalence for every nested composition inside every return-payload shape.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=247`)

## Current Session Notes (2026-03-14)
- Corrected an important roadmap semantic point:
  - the long-term goal is to eliminate raw Perl dependence,
  - not to eliminate structured `{...}` blocks when those blocks contain method-like DSL statements.
- The intended backend-neutral surface now needs to be stated explicitly as:
  - fluent sequencing: `.m1(...).m2(...).mk(...)`,
  - structured-block sequencing: `{ m1(...); m2(...); ...; mk(...) }`,
  - and unlimited nested method composition inside arguments: `mk(mk1(...), mk2(...), ...)`.
- `ROADMAP.md` and `USER_GUIDE.md` now describe those surfaces as equivalent semantic forms rather than framing braces as a blanket deprecation target.

## Current Session Notes (2026-03-14)
- Clarified one roadmap-status ambiguity explicitly:
  - the `Method-like DSL migration track` stays `not started` until dedicated method-chain / structured-block-equivalence / raw-Perl-reduction work lands,
  - and Backbone Item 3 groundwork does not count as starting that track by itself.
- The roadmap row and the track section now both say this directly.

## Current Session Notes (2026-03-14)
- Refined the live-status display rule again:
  - commit close-outs should no longer print the full tracker by default,
  - they should print only the rows affected by the current task,
  - and they should print the full tracker only when the user explicitly asks for it.
- Affected-row displays must still include the short scope description from `ROADMAP.md`.

## Current Session Notes (2026-03-14)
- Tightened the live-status presentation rule again:
  - every displayed tracker snapshot must now include each row's brief scope description,
  - not just the area name, level, and remaining focus,
  - so complex rows stay self-explanatory even when they summarize several internal sub-steps.
- `ROADMAP.md` now carries that scope text directly in the canonical dashboard through a `What it covers` column.

## Current Session Notes (2026-03-14)
- Completed a bounded Backbone Item 3 compatibility-surface cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` now installs its remaining `EmitContext` compatibility wrappers through one shared `_delegate_emit_context_call(...)` helper instead of carrying a long wall of near-identical wrapper bodies.
- `LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics(...)` now explicitly threads the optional rewrite-rules slot when calling `LinkedSpec::ActionIR::RewritePipeline`, so the historical two-argument `ActionRewriter` rewrite-helper call shape stays intact through the owner path.
- Added the focused regression lock:
  - `action_rewriter_compat_wrappers_share_emit_context_delegator`
    to pin representative helper families to the shared delegator surface.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=246`)

## Current Session Notes (2026-03-14)
- Clarified the roadmap execution policy explicitly in the repo:
  - phase numbering is not a hard waterfall contract,
  - the default execution mode is dependency-first, bounded slices,
  - strict phase-by-phase sequencing only applies when explicitly requested.
- This removes ambiguity about why some support/foundation work may land outside pure phase-number order.

## Current Session Notes (2026-03-14)
- Tightened the live-status workflow rule again:
  - every commit workflow close-out must now display the current live-status tracker snapshot,
  - so it is always explicit how the completed slice did or did not change the dashboard.
- This is in addition to the existing rules to:
  - update the dashboard before commits when a slice materially changes status,
  - and explicitly display/log any row whose level changes.

## Current Session Notes (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_rewrite_pipeline_deps()` is now explicitly grouped with the other owner-map helpers, and the focused seam lock now pins `_build_action_rewrite_rules(...)` to `LinkedSpec::ActionIR::RewritePipeline::default_deps_for_package(__PACKAGE__)`.
- Added a focused regression lock:
  - `emit_context_rewrite_pipeline_deps_route_through_owner_default_map`
    to assert that `EmitContext` now requests the `RewritePipeline` owner map for `LinkedSpec::RuleIR::EmitContext`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=245`)

## Current Session Notes (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_action_contract_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::Contracts::default_deps_for_package(__PACKAGE__)`, so the extracted contracts owner defines that dependency contract in one place.
- Added a focused regression lock:
  - `emit_context_action_contract_deps_route_through_owner_default_map`
    to assert that `EmitContext` now requests the `Contracts` owner map for `LinkedSpec::RuleIR::EmitContext`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=244`)

## Current Session Notes (2026-03-14)
- Tightened the live-status workflow rule:
  - when any roadmap dashboard level changes, show the changed live-status rows in the task close-out,
  - and log that level change in the canonical roadmap source at `ROADMAP.md`.
- This is in addition to the existing rule that the dashboard must be updated before commits whenever a slice materially changes what is done, what is left, or which area is active.

## Current Session Notes (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_scan_contract_ir_event_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::Scanner::default_deps_for_package(__PACKAGE__)`, so the extracted scanner owner defines that dependency contract in one place.
- Added a focused regression lock:
  - `emit_context_scanner_deps_route_through_owner_default_map`
    to assert that `EmitContext` now requests the `Scanner` owner map for `LinkedSpec::RuleIR::EmitContext`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=243`)

## Current Session Notes (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_declare_method_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::DeclareMethod::default_deps_for_package(__PACKAGE__)`, so the extracted declare-method owner defines that dependency contract in one place.
- Added a focused regression lock:
  - `emit_context_declare_method_deps_route_through_owner_default_map`
    to assert that `EmitContext` now requests the `DeclareMethod` owner map for `LinkedSpec::RuleIR::EmitContext`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=242`)

## Current Session Notes (2026-03-14)
- Added a canonical live four-level roadmap dashboard to `ROADMAP.md`.
- The dashboard is now the source of truth for project progress and uses only:
  - `done`
  - `mostly done`
  - `in progress`
  - `not started`
- Workflow rule:
  - before every commit, update the roadmap dashboard if the completed slice materially changes what is done, what is left, or which area is actively in progress.
- Current classification snapshot at the time of this process change:
  - overall roadmap: `in progress`
  - Phase 0: `done`
  - Phase 1: `mostly done`
  - Phase 1A: `mostly done`
  - Backbone Item 3: `mostly done`
  - Phases 2, 3, 4, 7: `not started`
  - Phase 5 and Phase 6: `in progress`

## Current Session Notes (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_method_lowering_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::MethodLowering::default_deps_for_package(__PACKAGE__)`, so the extracted method-lowering owner defines that dependency contract in one place.
- Added a focused regression lock:
  - `emit_context_method_lowering_deps_route_through_owner_default_map`
    to assert that `EmitContext` now requests the `MethodLowering` owner map for `LinkedSpec::RuleIR::EmitContext`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=241`)

## Current Session Notes (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_array_pipeline_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::ArrayPipeline::default_deps_for_package(__PACKAGE__)`, so the extracted array-pipeline owner defines that dependency contract in one place.
- Added a focused regression lock:
  - `emit_context_array_pipeline_deps_route_through_owner_default_map`
    to assert that `EmitContext` now requests the `ArrayPipeline` owner map for `LinkedSpec::RuleIR::EmitContext`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=240`)

## Current Session Notes (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_value_expr_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::ValueExpr::default_deps_for_package(__PACKAGE__)`, so the extracted value-expression owner defines that dependency contract in one place.
- Added a focused regression lock:
  - `emit_context_value_expr_deps_route_through_owner_default_map`
    to assert that `EmitContext` now requests the `ValueExpr` owner map for `LinkedSpec::RuleIR::EmitContext`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=239`)

## Current Session Notes (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_flow_expr_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::FlowExpr::default_deps_for_package(__PACKAGE__)`, so the extracted flow-expression owner defines that dependency contract in one place.
- Added a focused regression lock:
  - `emit_context_flow_expr_deps_route_through_owner_default_map`
    to assert that `EmitContext` now requests the `FlowExpr` owner map for `LinkedSpec::RuleIR::EmitContext`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=238`)

## Current Session Notes (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_statement_split_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::StatementSplit::default_deps_for_package(__PACKAGE__)`, so the extracted statement-split owner defines that dependency contract in one place.
- Added a focused regression lock:
  - `emit_context_statement_split_deps_route_through_owner_default_map`
    to assert that `EmitContext` now requests the `StatementSplit` owner map for `LinkedSpec::RuleIR::EmitContext`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=237`)

## Current Session Notes (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_canonical_event_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::CanonicalEvents::default_deps_for_package(__PACKAGE__)`, so the extracted canonical-events owner defines that dependency contract in one place.
- Added a focused regression lock:
  - `emit_context_canonical_event_deps_route_through_owner_default_map`
    to assert that `EmitContext` now requests the `CanonicalEvents` owner map for `LinkedSpec::RuleIR::EmitContext`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=236`)

## Current Session Notes (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_diagnostics_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::Diagnostics::default_deps_for_package(__PACKAGE__)`, so the extracted diagnostics owner defines that dependency contract in one place.
- Added a focused regression lock:
  - `emit_context_diagnostics_deps_route_through_owner_default_map`
    to assert that `EmitContext` now requests the `Diagnostics` owner map for `LinkedSpec::RuleIR::EmitContext`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=235`)

## Current Session Notes (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_control_flow_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::ControlFlow::default_deps_for_package(__PACKAGE__)`, so the extracted control-flow owner defines that dependency contract in one place.
- Added a focused regression lock:
  - `emit_context_control_flow_deps_route_through_owner_default_map`
    to assert that `EmitContext` now requests the `ControlFlow` owner map for `LinkedSpec::RuleIR::EmitContext`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=233`)

## Current Session Notes (2026-03-14)
- Completed a small Backbone Item 3 cleanup slice inside `LinkedSpec::*`.
- Removed the stale local `LinkedSpec::ActionRewriter::_trim_action_ir_value(...)` helper; trimming had already been localized to `LinkedSpec::RuleIR::EmitContext` and the extracted `ActionIR::*` owners, so the compatibility module no longer needs to carry dead trim scaffolding.
- Added a focused regression lock:
  - `action_rewriter_drops_dead_trim_helper`
    to assert that `ActionRewriter` no longer exposes the dead trim helper while `EmitContext` still owns the active one.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=233`)

## Current Session Notes (2026-03-13)
- Completed the next no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer owns the remaining direct ControlFlow compatibility wrappers `_lower_if_flow_statement(...)`, `_lower_elseif_flow_statement(...)`, `_lower_else_flow_statement(...)`, `_lower_endif_flow_statement(...)`, `_lower_switch_flow_statement(...)`, `_lower_case_flow_statement(...)`, `_lower_default_flow_statement(...)`, `_lower_endcase_flow_statement(...)`, `_lower_endswitch_flow_statement(...)`, `_lower_say_statement(...)`, and `_lower_print_statement(...)`; those now route through `LinkedSpec::RuleIR::EmitContext`.
- `LinkedSpec::RuleIR::EmitContext` now exposes the matching direct owner entrypoints for those remaining ControlFlow wrappers too, so `ActionRewriter` no longer needs a direct `ControlFlow` package loader or local ControlFlow dep-map builder.
- Updated focused regression locks:
  - strengthened `action_rewriter_require_avoids_control_flow_load_until_control_helper`,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the remaining ControlFlow helper family to the `EmitContext` owner path.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=232`)

## Current Session Notes (2026-03-13)
- Completed the next no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer owns the remaining direct DeclareMethod compatibility wrappers `_split_declare_symbol_names(...)`, `_parse_declare_binding_entry(...)`, `_lower_declare_value_expr(...)`, `_lower_declare_initializer_expr(...)`, `_extract_declare_statement_from_method_expr(...)`, `_lower_declare_method_statement(...)`, and `_lower_assign_method_statement(...)`; those now route through `LinkedSpec::RuleIR::EmitContext`.
- `LinkedSpec::RuleIR::EmitContext` now exposes the missing direct owner entrypoints for the remaining DeclareMethod wrappers too, so `ActionRewriter` no longer needs a direct `DeclareMethod` package loader or local DeclareMethod dep-map builder.
- Updated focused regression locks:
  - strengthened `action_rewriter_require_avoids_declare_method_load_until_declare_helper`,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the remaining DeclareMethod helper family to the `EmitContext` owner path.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=232`)

## Current Session Notes (2026-03-13)
- Completed the next no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer owns the remaining broad MethodLowering compatibility wrappers `_lower_return_general_statement(...)`, `_lower_return_imatch_statement(...)`, `_lower_push_value_statement(...)`, `_lower_regex_subst_statement(...)`, `_lower_return_undef_statement(...)`, and `_lower_return_array_statement(...)`; those now route through `LinkedSpec::RuleIR::EmitContext`.
- `LinkedSpec::RuleIR::EmitContext` now exposes the matching owner entrypoints for those broad MethodLowering wrappers too, so the compatibility module no longer needs a direct `MethodLowering` package loader or local MethodLowering dep-map builder.
- Updated focused regression locks:
  - strengthened `action_rewriter_require_avoids_method_lowering_load_until_method_helper`,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the remaining MethodLowering helper family to the `EmitContext` owner path.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=232`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer owns the focused MethodLowering helper subset `_declare_alias_to_type(...)`, `_lower_typed_declare_statement(...)`, `_normalize_method_tag_expr(...)`, `_lower_method_value_expr(...)`, and `_lower_assign_statement(...)`; those now route through `LinkedSpec::RuleIR::EmitContext`, which already owns that helper lowering for the active compile path.
- The broader MethodLowering statement wrappers still remain on `ActionRewriter` for now, so this slice shrinks the compatibility module without trying to clear the full owner family in one step.
- Updated focused regression locks:
  - strengthened `action_rewriter_require_avoids_method_lowering_load_until_method_helper`,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the migrated MethodLowering helper subset to the `EmitContext` owner path.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=232`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer owns the direct ArrayPipeline compatibility wrappers `_build_array_pipeline_plan_from_expr(...)` and `_lower_array_pipeline_expr(...)`; they now route through `LinkedSpec::RuleIR::EmitContext`, which already owns that array-planning/lowering support for the active compile path.
- `LinkedSpec::RuleIR::EmitContext` now exposes the direct `_lower_array_pipeline_expr(...)` owner entrypoint too, so the compatibility wrapper handoff is complete on the owner side.
- That removes the last direct ArrayPipeline package loader and local ArrayPipeline dep-map builder from `ActionRewriter`, making the compatibility module narrower without changing downstream behavior.
- Updated focused regression locks:
  - strengthened `action_rewriter_require_avoids_array_pipeline_load_until_array_helper`,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the remaining array-pipeline helpers to the `EmitContext` owner path.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=232`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer owns the direct FlowExpr compatibility wrapper `_lower_flow_composite_expr(...)`; it now routes through `LinkedSpec::RuleIR::EmitContext`, which already owns that flow-lowering support for the active compile path.
- That removes the last direct FlowExpr package loader and local FlowExpr dep-map builder from `ActionRewriter`, making the compatibility module narrower without changing downstream behavior.
- Updated focused regression locks:
  - strengthened `action_rewriter_require_avoids_flow_expr_load_until_flow_helper`,
  - updated `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the remaining flow helper to the `EmitContext` owner path.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=232`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer owns the direct ValueExpr helper wrappers for symbol extraction and value lowering; those now route through `LinkedSpec::RuleIR::EmitContext`, which already owns that support for the active compile path.
- That removes the last direct ValueExpr package loader and local ValueExpr dep-map builder from `ActionRewriter`, making the compatibility module narrower without changing downstream behavior.
- Updated focused regression locks:
  - strengthened `action_rewriter_require_avoids_value_expr_load_until_value_helper`,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to cover the full ValueExpr helper family on the `EmitContext` owner path.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=232`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer owns the direct MethodExpr helper wrappers for parse / scope-token / arg-normalization / CSV split; those now route through `LinkedSpec::RuleIR::EmitContext`, which already owns that parsing support for the active compile path.
- That removes the last direct MethodExpr package loader from `ActionRewriter` and makes the compatibility module narrower without changing downstream behavior.
- Updated focused regression locks:
  - strengthened `action_rewriter_require_avoids_method_expr_load_until_parse_helper`,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to cover the full MethodExpr helper family on the `EmitContext` owner path.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=232`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` now routes the rest of its generic split/canonical/rewrite helper wrappers through `LinkedSpec::RuleIR::EmitContext`, and `EmitContext` now exposes owner entrypoints for the canonicalize/lower helper stages too.
- That removes another batch of duplicate dep-builder/load-time scaffolding from `ActionRewriter`; the compatibility module is now narrower and more clearly limited to lower-level direct helper families plus legacy wrapper surface.
- Updated focused regression locks:
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the remaining generic split/canonical/rewrite helper wrappers to the `EmitContext` owner path,
  - revalidated the full phase-0 suite and local CI gate after the handoff.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=232`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` now routes its remaining generic rewrite-orchestration wrappers through `LinkedSpec::RuleIR::EmitContext`, so the compatibility module no longer re-owns generic contract scan / unresolved-helper / canonical-build / rewrite dispatch for that path.
- Lower-level direct lowering helpers inside `ActionRewriter` remain intact; the change is specifically about keeping the generic rewrite orchestration centered on the same extracted owner used by the live compile path.
- Updated focused regression locks:
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the new `EmitContext` owner path for those wrappers,
  - revalidated the broader phase-0 rewrite/lazy-load suite through the local CI gate.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=232`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext` now exposes `rewrite_action_code_for_compat(...)` as the focused helper-rewrite owner, `LinkedSpec::call_spec_handler_subst(...)` now lazy-loads that owner directly, and `LinkedSpec::ActionRewriter::call_spec_handler_subst(...)` is now just a backward-compatible wrapper around the same path.
- Normal façade helper rewrites now keep `ActionRewriter.pm` unloaded; only direct legacy callers of `LinkedSpec::ActionRewriter::call_spec_handler_subst(...)` still load that compatibility wrapper module.
- Updated focused regression locks:
  - strengthened `linkedspec_require_avoids_action_rewriter_load_until_compat_helper`,
  - updated `linkedspec_public_facade_wrappers_preserve_eval_error_state`,
  - updated `action_rewriter_owner_wrappers_preserve_eval_error_state`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=232`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext` now assembles its rewrite callback bundle from extracted `ActionIR::*` owners directly instead of borrowing the `LinkedSpec::ActionRewriter` callback surface.
- Normal `EmitContext` builds and normal `LinkedSpec::Get(...)` compilation now keep `ActionRewriter.pm` unloaded; only the explicit compatibility helper `call_spec_handler_subst(...)` still lazy-loads that owner.
- Added focused regression locks:
  - strengthened `linkedspec_require_avoids_compile_pipeline_load_until_get`,
  - strengthened `emit_context_require_avoids_action_rewriter_load_until_emit_context_build`,
  - added `emit_context_avoids_action_rewriter_owner_bundle`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=232`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Phase 1A ownership-cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::SpecEntry` now lazy-loads `LinkedSpec::RuleIR::EmitContext` directly and calls `build_rule_ir_emit_context(...)` on the owner module instead of routing through thin `RuleIR` delegates.
- Removed the dead `LinkedSpec::RuleIR::_require_emit_context_pkg(...)`, `_normalize_rule_code_chunks(...)`, and `_build_rule_ir_emit_context(...)` scaffolding.
- Updated focused regression locks:
  - strengthened `spec_entry_require_avoids_ruleir_load_until_compile_spec_entry` to cover lazy `EmitContext` loading too,
  - added `spec_entry_avoids_removed_ruleir_emit_context_delegates`,
  - trimmed obsolete `RuleIR` emit-context delegate expectations from `extracted_wrapper_helpers_preserve_eval_error_state`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=231`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext` now routes rewrite-rule construction and rewrite execution through `LinkedSpec::ActionIR::RewritePipeline`, routes diagnostic accumulation through `LinkedSpec::ActionIR::Diagnostics`, and keeps its trivial trim helper local.
- `EmitContext` no longer depends on the thin `LinkedSpec::ActionRewriter` wrapper methods for this path; `ActionRewriter` is only pulled indirectly when the extracted rewrite-pipeline owner resolves lowering callback maps.
- Updated focused regression locks:
  - strengthened `emit_context_require_avoids_action_rewriter_load_until_emit_context_build` to cover lazy `RewritePipeline` loading,
  - updated `extracted_wrapper_helpers_preserve_eval_error_state` so the `EmitContext` rewrite helper is locked to `RewritePipeline`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=231`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- The remaining extracted `ActionIR` dep-builder owners now lazy-load callback-owner packages on demand instead of assuming those packages were already loaded by the caller.
- Added local `_require_pkg(...)` helpers to `ControlFlow`, `Diagnostics`, `RewritePipeline`, `Contracts`, `ValueExpr`, `ArrayPipeline`, `FlowExpr`, and `MethodLowering`, then routed `_require_pkg_cb(...)` through them.
- Updated `StatementSplit::_require_pkg_cb(...)` and `CanonicalEvents::_require_pkg_cb(...)` to lazy-load callback-owner packages before symbol-table callback lookup too.
- Added focused regression lock `actionir_dep_builders_lazy_load_callback_owner_packages`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Diagnostics.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ValueExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=231`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionIR::DeclareMethod` and `LinkedSpec::ActionIR::Scanner` now lazy-load `MethodExpr` while building their default callback maps, so `LinkedSpec::ActionRewriter` no longer has to prefetch `MethodExpr` just to assemble those dep-builder payloads.
- Removed the redundant `_require_method_expr_pkg()` calls from `LinkedSpec::ActionRewriter::_declare_method_deps(...)` and `_scan_contract_ir_event_deps(...)`.
- Updated `LinkedSpec::ActionIR::DeclareMethod::_require_pkg_cb(...)` and `LinkedSpec::ActionIR::Scanner::_require_pkg_cb(...)` to load callback-owner packages on demand before resolving `can(...)`.
- Added focused regression lock `action_rewriter_dep_builders_avoid_method_expr_prefetch`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/DeclareMethod.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=230`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A API-stability slice inside `LinkedSpec::*`.
- The remaining extracted ActionIR dep-builder owners now preserve caller `$@` across successful callback-map lookup and construction.
- Added `::_call_preserving_err(...)` to the dep-builder-only ActionIR owners that still lacked it, then routed `_require_pkg_cb(...)` and `default_deps_for_package(...)` through that helper across `Diagnostics`, `Contracts`, `DeclareMethod`, `ControlFlow`, `ArrayPipeline`, `RewritePipeline`, `FlowExpr`, `MethodLowering`, and `ValueExpr`, while routing the same dep-builder surfaces through the existing helper in `Scanner`, `StatementSplit`, and `CanonicalEvents`.
- Added focused regression lock `actionir_dep_builders_preserve_eval_error_state`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Diagnostics.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/DeclareMethod.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ValueExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=229`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Phase 1A helper API-stability slice inside `LinkedSpec::*`.
- `LinkedSpec::ParserFactory` lazy owner lookup and public parser-factory orchestration now preserve caller `$@` across successful delegation.
- Added `LinkedSpec::ParserFactory::_call_preserving_err(...)` and routed `_require_pkg(...)`, `_require_pkg_cb(...)`, `_require_pkg_value(...)`, and `run_get_parser(...)` through it.
- Added focused regression lock `parser_factory_wrappers_preserve_eval_error_state`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=228`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Phase 1A helper API-stability slice inside `LinkedSpec::*`.
- `LinkedSpec::PluginBridge` legacy runtime load/exec helpers now preserve caller `$@` across successful delegation.
- Added `LinkedSpec::PluginBridge::_call_preserving_err(...)` and routed `_load_legacy_plugin_runtime(...)`, `_exec_legacy_plugin(...)`, and `_dispatch_plugin_name(...)` through it.
- Added focused regression lock `plugin_bridge_owner_wrappers_preserve_eval_error_state`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=227`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Phase 1A helper API-stability slice inside `LinkedSpec::*`.
- `LinkedSpec::Trace::_trace_stringify(...)` now preserves caller `$@` across successful reference formatting through `Data::Dumper`.
- Added `LinkedSpec::Trace::_call_preserving_err(...)` and routed the reference-formatting branch of `_trace_stringify(...)` through it.
- Added focused regression lock `trace_stringify_preserves_eval_error_state`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/Trace.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=226`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Phase 1A helper API-stability slice inside `LinkedSpec::*`.
- `LinkedSpec::BootstrapSpec::Core` regex helper wrappers now preserve caller `$@` across successful delegation.
- Added `LinkedSpec::BootstrapSpec::Core::_call_preserving_err(...)` and routed `_linkedre_or(...)` plus `_linkedre_ored_re(...)` through it.
- Added focused regression lock `bootstrap_spec_core_linkedre_wrappers_preserve_eval_error_state`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec/Core.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=225`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Phase 1A façade API-stability slice inside `LinkedSpec.pm`.
- The public trace wrapper surface now preserves caller `$@` across successful delegation to `LinkedSpec::Trace`.
- Routed `configure_trace(...)`, `trace_enter(...)`, `trace_exit(...)`, `trace_decision(...)`, `log_output(...)`, `log_dump(...)`, and `should_dump(...)` through `LinkedSpec::_call_preserving_err(...)`.
- Added focused regression lock `linkedspec_trace_wrappers_preserve_eval_error_state`.
- Validation snapshot for this slice:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=224`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Phase 1A helper API-stability slice inside `LinkedSpec::*`.
- `LinkedSpec::Compiler` trace, dump, and regex helper wrappers now preserve caller `$@` across successful delegation.
- Added `LinkedSpec::Compiler::_call_preserving_err(...)` and routed `_dump_value(...)`, `_ored_re(...)`, `_trace_log_output(...)`, `_trace_log_dump(...)`, `_trace_should_dump(...)`, `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`, `_trace_apply_trace_options(...)`, and `_trace_level_name_for_current_verbosity(...)` through it.
- Added focused regression lock `compiler_helper_wrappers_preserve_eval_error_state`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=223`)

## Current Session Notes (2026-03-13)
- Completed another no-behavior-change Phase 1A helper API-stability slice inside `LinkedSpec::*`.
- `LinkedSpec::SpecEntry` trace and dump helper wrappers now preserve caller `$@` across successful delegation.
- Added `LinkedSpec::SpecEntry::_call_preserving_err(...)` and routed `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`, `_trace_log_dump(...)`, `_trace_should_dump(...)`, and `_dump_value(...)` through it.
- Added focused regression lock `spec_entry_helper_wrappers_preserve_eval_error_state`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=222`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A / Backbone Item 3 API-stability slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` owner-delegate wrappers now preserve caller `$@` across successful delegation.
- Added `LinkedSpec::ActionRewriter::_call_preserving_err(...)` and routed the extracted ActionIR dep-builder/helper/rewrite wrappers through it.
- Added focused regression lock `action_rewriter_owner_wrappers_preserve_eval_error_state`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=221`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A owner-wrapper API-stability slice inside `LinkedSpec::*`.
- `LinkedSpec::BootstrapSpec`, `LinkedSpec::Runtime`, `LinkedSpec::ActionIR::Scanner`, `LinkedSpec::ActionIR::StatementSplit`, and `LinkedSpec::ActionIR::CanonicalEvents` now preserve caller `$@` across successful owner delegation.
- Added `_call_preserving_err(...)` to those owner modules and routed their thin delegate entrypoints through it.
- Added focused regression lock `remaining_owner_wrappers_preserve_eval_error_state`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=220`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A extracted-wrapper API-stability slice inside `LinkedSpec::*`.
- `LinkedSpec::Validation`, `LinkedSpec::Resolver`, `LinkedSpec::RuleIR`, and `LinkedSpec::RuleIR::EmitContext` now preserve caller `$@` across successful owner delegation.
- Added `_call_preserving_err(...)` to those extracted modules and routed their thin trace/emit-context/action-rewrite delegate helpers through it.
- Added focused regression lock `extracted_wrapper_helpers_preserve_eval_error_state`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/Validation.pm`
  - `perl -Iperl -c perl/LinkedSpec/Resolver.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=219`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A façade API-stability slice inside `LinkedSpec::*`.
- `LinkedSpec.pm` public façade wrappers now preserve caller `$@` across successful owner delegation.
- Added `LinkedSpec::_call_preserving_err(...)` and routed `Get(...)`, `spec_descr(...)`, `call_spec_handler_subst(...)`, `get_parser(...)`, and `AUTOLOAD` through it.
- Added focused regression lock `linkedspec_public_facade_wrappers_preserve_eval_error_state`.
- Validation snapshot for this slice:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=218`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::BootstrapSpec::Core` no longer imports `LinkedRE` at module load time.
- `LinkedSpec::BootstrapSpec::Core` now lazy-loads `LinkedRE` only when bootstrap registry construction or bootstrap scanner handlers actually need it.
- Added require-only regression lock `bootstrap_spec_core_require_avoids_linkedre_load_until_bootstrap_spec_build`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec/Core.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=217`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::Compiler` no longer imports `LinkedRE` at module load time.
- `LinkedSpec::Compiler` now lazy-loads `LinkedRE` only when `spec_gdata(...)` actually builds combined regex dependencies.
- Added require-only regression lock `compiler_require_avoids_linkedre_load_until_run_get_pipeline`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=216`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec.pm` no longer imports `LinkedRE` at module load time.
- Plain `require LinkedSpec` now keeps `LinkedRE` unloaded until the compile path actually needs it.
- Added require-only regression lock `linkedspec_require_avoids_linkedre_load_until_get`.
- Validation snapshot for this slice:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=215`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::Compiler` no longer imports `Data::Dumper` at module load time.
- `LinkedSpec::Compiler` now lazy-loads `Data::Dumper` only when traced compiler dump paths actually need structured formatting.
- Added require-only regression lock `compiler_require_avoids_data_dumper_load_until_debug_pipeline_dump`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=214`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::SpecEntry` no longer imports `Data::Dumper` at module load time.
- `LinkedSpec::SpecEntry` now lazy-loads `Data::Dumper` only when high-verbosity rule-entry debug dumps actually need structured formatting.
- Added require-only regression lock `spec_entry_require_avoids_data_dumper_load_until_debug_compile_dump`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=213`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec.pm` no longer imports `Data::Dumper` at module load time.
- Plain `require LinkedSpec` now keeps `Data::Dumper` unloaded until an extracted owner module actually needs it.
- Added require-only regression lock `linkedspec_require_avoids_data_dumper_load`.
- Validation snapshot for this slice:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=212`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR` no longer imports `Data::Dumper` at module load time.
- `LinkedSpec::RuleIR` now lazy-loads `Data::Dumper` only when debug execution-meta dumps actually need structured formatting.
- Added require-only regression lock `ruleir_require_avoids_data_dumper_load_until_debug_meta_dump`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=211`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::Trace` no longer imports `Data::Dumper` at module load time.
- `LinkedSpec::Trace` now lazy-loads `Data::Dumper` only when referenced values actually need structured dump formatting.
- Added require-only regression lock `trace_require_avoids_data_dumper_load_until_stringify_ref`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/Trace.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=210`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext` no longer imports `LinkedSpec::ActionRewriter` at module load time.
- `LinkedSpec::RuleIR::EmitContext` now lazy-loads `ActionRewriter.pm` only when emit-context build paths actually need rewrite helpers.
- Added require-only regression lock `emit_context_require_avoids_action_rewriter_load_until_emit_context_build`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=209`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec.pm` no longer imports `LinkedSpec::Trace` at module load time.
- `LinkedSpec.pm` now lazy-loads `Trace.pm` only when the public trace API actually runs, while keeping the façade trace-state aliases intact.
- Added require-only regression lock `linkedspec_require_avoids_trace_load_until_public_trace_api`.
- Validation snapshot for this slice:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=208`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::Compiler` no longer imports `LinkedSpec::Trace` at module load time.
- `LinkedSpec::Compiler` now lazy-loads `Trace.pm` only when `spec_descr(...)`, `spec_gdata(...)`, or `run_get_pipeline(...)` actually starts traced compiler work.
- Added require-only regression lock `compiler_require_avoids_trace_load_until_run_get_pipeline`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=207`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::SpecEntry` no longer imports `LinkedSpec::Trace` at module load time.
- `LinkedSpec::SpecEntry` now lazy-loads `Trace.pm` only when `compile_spec_entry(...)` actually starts traced rule compilation.
- Added require-only regression lock `spec_entry_require_avoids_trace_load_until_compile_spec_entry`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=206`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR` no longer imports `LinkedSpec::Trace` at module load time.
- `LinkedSpec::RuleIR` now lazy-loads `Trace.pm` only when RuleIR diagnostics actually emit output.
- Added require-only regression lock `ruleir_require_avoids_trace_load_until_mixed_action_error`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=205`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext` no longer imports `LinkedSpec::Trace` at module load time.
- `LinkedSpec::RuleIR::EmitContext` now lazy-loads `Trace.pm` only when unresolved-helper diagnostics actually emit output.
- Added require-only regression lock `emit_context_require_avoids_trace_load_until_unresolved_helper_diag`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=204`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::Resolver` no longer imports `LinkedSpec::Trace` at module load time.
- `LinkedSpec::Resolver` now lazy-loads `Trace.pm` only when invalid-spec or spec-resolution trace/error paths actually emit output.
- Added require-only regression lock `resolver_require_avoids_trace_load_until_invalid_spec_error`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/Resolver.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=203`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::Validation` no longer imports `LinkedSpec::Trace` at module load time.
- `LinkedSpec::Validation` now lazy-loads `Trace.pm` only when validation errors or warnings actually emit trace output.
- Added require-only regression lock `validation_require_avoids_trace_load_until_error_report`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/Validation.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=202`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer imports `LinkedSpec::ActionIR::DeclareMethod` at module load time.
- `LinkedSpec::ActionRewriter` now lazy-loads `DeclareMethod.pm` only when declare-method helper paths actually start.
- Added require-only regression lock `action_rewriter_require_avoids_declare_method_load_until_declare_helper`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=201`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer imports `LinkedSpec::ActionIR::MethodLowering` at module load time.
- `LinkedSpec::ActionRewriter` now lazy-loads `MethodLowering.pm` only when method-lowering helper paths actually start.
- Added require-only regression lock `action_rewriter_require_avoids_method_lowering_load_until_method_helper`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=200`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer imports `LinkedSpec::ActionIR::ControlFlow` at module load time.
- `LinkedSpec::ActionRewriter` now lazy-loads `ControlFlow.pm` only when flow-statement helper paths actually start.
- Added require-only regression lock `action_rewriter_require_avoids_control_flow_load_until_control_helper`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=199`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer imports `LinkedSpec::ActionIR::ValueExpr` at module load time.
- `LinkedSpec::ActionRewriter` now lazy-loads `ValueExpr.pm` only when value helper paths actually start.
- Added require-only regression lock `action_rewriter_require_avoids_value_expr_load_until_value_helper`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=198`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer imports `LinkedSpec::ActionIR::ArrayPipeline` at module load time.
- `LinkedSpec::ActionRewriter` now lazy-loads `ArrayPipeline.pm` only when array helper paths actually start.
- Added require-only regression lock `action_rewriter_require_avoids_array_pipeline_load_until_array_helper`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=197`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer imports `LinkedSpec::ActionIR::FlowExpr` at module load time.
- `LinkedSpec::ActionRewriter` now lazy-loads `FlowExpr.pm` only when flow helper paths actually start.
- Added require-only regression lock `action_rewriter_require_avoids_flow_expr_load_until_flow_helper`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=196`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer imports `LinkedSpec::ActionIR::RewritePipeline` at module load time.
- `LinkedSpec::ActionRewriter` now lazy-loads `RewritePipeline.pm` only when rewrite helper paths actually start.
- Added require-only regression lock `action_rewriter_require_avoids_rewrite_pipeline_load_until_rewrite_helper`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=195`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer imports `LinkedSpec::ActionIR::Contracts` at module load time.
- `LinkedSpec::ActionRewriter` now lazy-loads `Contracts.pm` only when lowering-contract helper paths actually start.
- Added require-only regression lock `action_rewriter_require_avoids_contracts_load_until_contract_helper`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=194`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer imports `LinkedSpec::ActionIR::StatementSplit` at module load time.
- `LinkedSpec::ActionRewriter` now lazy-loads `StatementSplit.pm` only when split helper paths actually start.
- Added require-only regression lock `action_rewriter_require_avoids_statement_split_load_until_split_helper`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=193`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer imports `LinkedSpec::ActionIR::Scanner` at module load time.
- `LinkedSpec::ActionRewriter` now lazy-loads `Scanner.pm` only when scanner helper paths actually start.
- Added require-only regression lock `action_rewriter_require_avoids_scanner_load_until_scan_helper`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=192`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer imports `LinkedSpec::ActionIR::Diagnostics` at module load time.
- `LinkedSpec::ActionRewriter` now lazy-loads `Diagnostics.pm` only when diagnostics helper paths actually start.
- Added require-only regression lock `action_rewriter_require_avoids_diagnostics_load_until_diag_helper`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=191`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer imports `LinkedSpec::ActionIR::CanonicalEvents` at module load time.
- `LinkedSpec::ActionRewriter` now lazy-loads `CanonicalEvents.pm` only when canonical-event helper paths actually start.
- Added require-only regression lock `action_rewriter_require_avoids_canonical_events_load_until_canonical_build`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=190`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer imports `LinkedSpec::ActionIR::MethodExpr` at module load time.
- `LinkedSpec::ActionRewriter` now lazy-loads `MethodExpr.pm` only when method-expression-dependent helper paths actually start, including scanner dep resolution.
- Added require-only regression lock `action_rewriter_require_avoids_method_expr_load_until_parse_helper` and tightened the existing require-only ActionRewriter load contract.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=189`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionIR::ScannerCore` no longer imports its scanner rule packages at module load time.
- `LinkedSpec::ActionIR::ScannerCore` now lazy-loads `PrimitiveBasicRules`, `PrimitivePipelineRules`, `FlowRules`, and `LegacyRules` only when contract scanning actually starts.
- Added require-only regression lock `actionir_scannercore_require_avoids_scanner_rule_load_until_scan`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ScannerCore.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=188`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionIR::StatementSplit::Core` no longer imports `LinkedSpec::ActionIR::StatementSplit::Mode` at module load time.
- `LinkedSpec::ActionIR::StatementSplit::Core` now lazy-loads `StatementSplit::Mode.pm` only when statement splitting actually starts.
- Added require-only regression lock `actionir_statement_split_core_require_avoids_mode_load_until_split`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit/Core.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=187`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionIR::CanonicalEvents` no longer imports `LinkedSpec::ActionIR::CanonicalEvents::Core` at module load time.
- `LinkedSpec::ActionIR::CanonicalEvents` now lazy-loads `CanonicalEvents::Core.pm` only when canonical-event building actually starts.
- Added require-only regression lock `actionir_canonical_events_require_avoids_core_load_until_build`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=186`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionIR::StatementSplit` no longer imports `LinkedSpec::ActionIR::StatementSplit::Core` at module load time.
- `LinkedSpec::ActionIR::StatementSplit` now lazy-loads `StatementSplit::Core.pm` only when statement splitting actually starts.
- Added require-only regression lock `actionir_statement_split_require_avoids_core_load_until_split`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=185`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionIR::Scanner` no longer imports `LinkedSpec::ActionIR::ScannerCore` at module load time.
- `LinkedSpec::ActionIR::Scanner` now lazy-loads `ScannerCore.pm` only when contract scanning actually starts.
- Added require-only regression lock `actionir_scanner_require_avoids_scannercore_load_until_scan`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=184`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::BootstrapSpec` no longer imports `LinkedSpec::BootstrapSpec::Core` at module load time.
- `LinkedSpec::BootstrapSpec` now lazy-loads `BootstrapSpec::Core.pm` only when bootstrap grammar state or bootstrap parsing actually needs it.
- Added require-only regression lock `bootstrap_spec_require_avoids_core_load_until_bootstrap_state_build`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=183`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR` no longer imports `LinkedSpec::RuleIR::EmitContext` at module load time.
- `LinkedSpec::RuleIR` now lazy-loads `EmitContext.pm` only when rule-IR normalization or emit-context assembly actually starts.
- Added require-only regression lock `ruleir_require_avoids_emit_context_load_until_emit_context_build`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=182`)

## Current Session Notes (2026-03-12)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::SpecEntry` no longer imports `LinkedSpec::RuleIR` at module load time.
- `LinkedSpec::SpecEntry::compile_spec_entry(...)` now lazy-loads `RuleIR.pm` only when actual staged rule compilation starts.
- Added require-only regression lock `spec_entry_require_avoids_ruleir_load_until_compile_spec_entry`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=181`)

## Current Session Notes (2026-03-11)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::Compiler` no longer imports `LinkedSpec::BootstrapSpec`, `LinkedSpec::SpecEntry`, or `LinkedSpec::Validation` at module load time.
- `LinkedSpec::Compiler::spec_descr(...)` and `run_get_pipeline(...)` now lazy-load those owner modules only when the active compile path actually needs them.
- Added require-only regression lock `compiler_require_avoids_owner_load_until_run_get_pipeline`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=180`)

## Current Session Notes (2026-03-11)
- Completed another no-behavior-change Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- `LinkedSpec::Runtime` no longer imports `LinkedSpec::Compiler` at module load time.
- `LinkedSpec::Runtime::run_get(...)` now lazy-loads `LinkedSpec::Compiler` only when compilation actually starts.
- Added require-only regression lock `runtime_require_avoids_compiler_load_until_run_get`.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=179`)

## System Characterization
LinkedSpec is a DSL compiler in Perl5:
1. Parse `.spec` using a built-in hardcoded grammar parser.
2. Build rule descriptors and generated handler code.
3. Execute handler logic dynamically to parse target input.
4. Return raw AST structures controlled by spec actions.

## Core Files
- `perl/LinkedSpec.pm` - DSL parsing + parser generation + runtime.
- `perl/LinkedRE.pm` - regex OR dispatch and capture packaging.
- `perl/PathSearch.pm` - spec location helper for `get_parser`.

## Downstream Consumers
- `LibReader`
- `PPlugin`
- `RTLUtils`
- `TableGrep`

These consumers exist, but integration/compatibility work for them is currently deferred unless explicitly resumed.

## Key Observations
- Strong at nested/recursive constructs.
- Strong at staged parsing (coarse-to-fine passes).
- Current implementation includes permissive extraction behavior useful for anchor-driven scanning.
- Current implementation also contains technical debt:
  - Runtime eval-heavy generation/execution paths.
  - Validation logic weaknesses.
  - Silent skipping risk in some DSL parse paths.
  - Tight module coupling during load path.
  - Inconsistent hard exits from library code.

## Product Direction (Confirmed)
LinkedSpec should be treated as:
- A progressive extraction parser DSL.
- A practical alternative to strict EBNF-centric workflows for niche/high-variance inputs.
- A platform for building domain parsers quickly.
- A language-agnostic `.spec` system where parser semantics are portable across backend implementations.

It should not be reframed as a strict EBNF clone.
It should also not remain dependent on embedded Perl code-blocks in `.spec` as a long-term architecture.

## Language-Agnostic `.spec` End-State (Confirmed)
- Final objective: stop using Perl code-blocks in `.spec` files.
- `.spec` action semantics should be represented in backend-neutral IR/DSL forms.
- Backend implementations (Perl first, others later) should map the same `.spec` action IR to host-language code without requiring `.spec` changes.
- Emitted host-language code should be constrained to canonical forms under generator control to minimize parser/splitter fragility and cross-backend divergence.
- Near-term guardrail: avoid introducing new `.spec` features that increase raw Perl code-block dependence.

## Design Goals
1. Preserve extraction + recursion ergonomics.
2. Introduce explicit parse semantics (`seek` vs `consume`).
3. Formalize position/capture concepts into transparent APIs.
4. Improve diagnostics, determinism, and maintainability.
5. Maintain backward compatibility with existing specs.

## Maintainability Documentation Policy
- Core modules (especially `perl/LinkedSpec.pm`) should keep subroutine-level documentation comments that describe purpose, inputs, outputs, and side effects.
- Important top-level parser globals/registries should remain annotated so architecture intent is understandable even without reading every implementation line.
- Complex state-machine/pipeline sections should include concise explanatory comments to preserve continuity for successor maintainers and non-Perl backend migration work.
## Session Notes (2026-03-11)
- Phase 1A follow-up slice completed against the façade's last eager owner imports on the public parser/plugin edges.
- Slice-selection rationale:
  - after lazy-loading the compile pipeline owners, `LinkedSpec.pm` still imported `ParserFactory` and `PluginBridge` eagerly,
  - those two imports were only needed for `get_parser(...)` and `AUTOLOAD`,
  - the façade could defer them as long as it respected existing trap-based tests that preinstall those symbols.
- Implementation scope:
  - removed eager `ParserFactory` and `PluginBridge` imports from `LinkedSpec.pm`,
  - updated `get_parser(...)` and `AUTOLOAD` to lazy-load only when the target owner symbol is not already present,
  - added subprocess regressions proving `require LinkedSpec` now keeps both modules unloaded until the corresponding façade entrypoint runs.
- Regression addition/update:
  - added `linkedspec_require_avoids_parser_factory_load_until_get_parser`,
  - added `linkedspec_require_avoids_plugin_bridge_load_until_autoload`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=178`)
## Session Notes (2026-03-11)
- Phase 1A follow-up slice completed against the façade's remaining eager compile-pipeline imports.
- Slice-selection rationale:
  - after lazy-loading `Resolver` through `ParserFactory`, `LinkedSpec.pm` still imported `Runtime`, `Compiler`, and `ActionRewriter` eagerly,
  - those imports pulled most of the compile pipeline and ActionIR stack into memory even on plain `require LinkedSpec`,
  - the façade already owned the relevant public entrypoints, so it could assume package-load responsibility locally instead of at module import time.
- Implementation scope:
  - added `_require_pkg(...)` to `LinkedSpec.pm`,
  - removed eager `Runtime`, `Compiler`, and `ActionRewriter` imports from the façade,
  - updated `Get(...)`, `spec_descr(...)`, and `call_spec_handler_subst(...)` to lazy-load their owner packages on demand,
  - added subprocess regressions for the `Get`, `spec_descr`, and compatibility-helper lazy-load seams.
- Regression addition/update:
  - added `linkedspec_require_avoids_compile_pipeline_load_until_get`,
  - added `linkedspec_require_avoids_compiler_load_until_spec_descr`,
  - added `linkedspec_require_avoids_action_rewriter_load_until_compat_helper`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=176`)
## Session Notes (2026-03-11)
- Phase 1A follow-up slice completed against the `LinkedSpec.pm` façade's remaining direct `Resolver` load-time coupling.
- Slice-selection rationale:
  - after deleting `LinkedSpec::Deps`, `LinkedSpec.pm` still imported `LinkedSpec::Resolver` only so `ParserFactory` could resolve its default callback owners,
  - `LinkedSpec::ParserFactory` already owned that default dependency resolution path,
  - moving the package load responsibility into `ParserFactory` keeps the façade thinner and reduces eager load surface on `require LinkedSpec`.
- Implementation scope:
  - added `_require_pkg(...)` to `LinkedSpec::ParserFactory`,
  - updated `_require_pkg_cb(...)` to lazy-load callback owner packages before resolving `can(...)`,
  - removed `use LinkedSpec::Resolver ();` from `LinkedSpec.pm`,
  - added a subprocess regression proving `require LinkedSpec` keeps `Resolver` unloaded until `get_parser(...)` runs.
- Regression addition/update:
  - added `linkedspec_require_avoids_resolver_load_until_get_parser`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=173`)
## Session Notes (2026-03-11)
- Backbone Item #3 follow-up slice completed against the last remaining parser-factory `LinkedSpec::Deps` coupling.
- Slice-selection rationale:
  - after removing the ActionRewriter load-time import, the only remaining active `LinkedSpec::Deps` surface was `parser_factory_deps_for_package(...)`,
  - `LinkedSpec::ParserFactory` already owned parser-factory orchestration, so keeping its last default callback map in a separate module no longer paid for its coupling cost,
  - folding that map into `ParserFactory` allows `LinkedSpec::Deps` to be deleted outright.
- Implementation scope:
  - added `_require_pkg_cb(...)` and `_require_pkg_value(...)` to `LinkedSpec::ParserFactory`,
  - moved `_default_deps()` to build the parser-factory default callback map locally,
  - deleted `perl/LinkedSpec/Deps.pm`,
  - added active-path and require-only regressions proving `ParserFactory` no longer depends on `LinkedSpec::Deps`.
- Regression addition/update:
  - added `get_parser_avoids_removed_deps_parser_factory_dep_builder`,
  - added `parser_factory_require_avoids_linkedspec_deps_load`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=172`)
## Session Notes (2026-03-11)
- Backbone Item #3 follow-up slice completed against ActionRewriter's last load-time `LinkedSpec::Deps` coupling.
- Slice-selection rationale:
  - after moving all active ActionIR default dep-builders onto their owner modules, `LinkedSpec::ActionRewriter` still imported `LinkedSpec::Deps` even though it no longer called any of its builders,
  - `LinkedSpec::Deps` still contained one dead helper, `declare_method_deps_for_package(...)`,
  - removing that load-time edge narrows the remaining `LinkedSpec::Deps` role to parser-factory wiring only.
- Implementation scope:
  - removed `use LinkedSpec::Deps ();` from `LinkedSpec::ActionRewriter`,
  - removed the dead `LinkedSpec::Deps::declare_method_deps_for_package(...)` helper,
  - added a subprocess regression proving `require LinkedSpec::ActionRewriter` no longer loads `LinkedSpec::Deps`.
- Regression addition/update:
  - added `action_rewriter_require_avoids_linkedspec_deps_load`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=170`)
## Session Notes (2026-03-11)
- Backbone Item #3 follow-up slice completed against method-lowering default dependency ownership.
- Slice-selection rationale:
  - after moving `ControlFlow`, the last remaining active shared ActionIR dep-builder was method lowering,
  - `LinkedSpec::ActionIR::MethodLowering` already owned the broad alias/value/assignment/return lowering surface but still depended on `LinkedSpec::Deps` for its default callback map,
  - moving that map into `MethodLowering` keeps method-lowering behavior and default wiring on the same owner surface.
- Implementation scope:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::MethodLowering`,
  - rewired `LinkedSpec::ActionRewriter::_method_lowering_deps()` to use `MethodLowering` directly,
  - removed the now-unused `LinkedSpec::Deps::method_lowering_deps_for_package(...)`.
- Regression addition/update:
  - added `action_rewriter_avoids_deps_method_lowering_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=169`)
## Session Notes (2026-03-11)
- Backbone Item #3 follow-up slice completed against control-flow default dependency ownership.
- Slice-selection rationale:
  - after moving `ArrayPipeline`, the next smallest remaining active shared ActionIR seam was control-flow lowering,
  - `LinkedSpec::ActionIR::ControlFlow` already owned branch/output lowering but still depended on `LinkedSpec::Deps` for its default callback map,
  - moving that map into `ControlFlow` keeps control-flow behavior and default wiring on the same owner surface.
- Implementation scope:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::ControlFlow`,
  - rewired `LinkedSpec::ActionRewriter::_control_flow_deps()` to use `ControlFlow` directly,
  - removed the now-unused `LinkedSpec::Deps::control_flow_deps_for_package(...)`.
- Regression addition/update:
  - added `action_rewriter_avoids_deps_control_flow_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=168`)
## Session Notes (2026-03-11)
- Backbone Item #3 follow-up slice completed against array-pipeline default dependency ownership.
- Slice-selection rationale:
  - after moving `FlowExpr`, the next smallest remaining active shared ActionIR seam was array-pipeline planning/lowering,
  - `LinkedSpec::ActionIR::ArrayPipeline` already owned the plan builder and lowering logic but still depended on `LinkedSpec::Deps` for its default callback map,
  - moving that map into `ArrayPipeline` keeps array-pipeline behavior and default wiring on the same owner surface.
- Implementation scope:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::ArrayPipeline`,
  - rewired `LinkedSpec::ActionRewriter::_array_pipeline_deps()` to use `ArrayPipeline` directly,
  - removed the now-unused `LinkedSpec::Deps::array_pipeline_deps_for_package(...)`.
- Regression addition/update:
  - added `action_rewriter_avoids_deps_array_pipeline_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=167`)
## Session Notes (2026-03-11)
- Backbone Item #3 follow-up slice completed against flow-expression default dependency ownership.
- Slice-selection rationale:
  - after moving `ValueExpr` out of `LinkedSpec::Deps`, the next smallest remaining active shared ActionIR seam was flow-expression lowering,
  - `LinkedSpec::ActionIR::FlowExpr` already owned boolean/comparison flow lowering but still depended on `LinkedSpec::Deps` for its default callback map,
  - moving that map into `FlowExpr` keeps flow-expression lowering behavior and default wiring on the same owner surface.
- Implementation scope:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::FlowExpr`,
  - rewired `LinkedSpec::ActionRewriter::_flow_expr_deps()` to use `FlowExpr` directly,
  - removed the now-unused `LinkedSpec::Deps::flow_expr_deps_for_package(...)`.
- Regression addition/update:
  - added `action_rewriter_avoids_deps_flow_expr_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=166`)
## Session Notes (2026-03-11)
- Backbone Item #3 follow-up slice completed against value-expression default dependency ownership.
- Slice-selection rationale:
  - after moving the action-contract and other specialized owner maps out of `LinkedSpec::Deps`, the next small remaining active seam was value-expression lowering,
  - `LinkedSpec::ActionIR::ValueExpr` already owned scalar-access and scalaref lowering but still depended on `LinkedSpec::Deps` for its default callback map,
  - moving that map into `ValueExpr` keeps value-expression lowering behavior and default wiring on the same owner surface.
- Implementation scope:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::ValueExpr`,
  - rewired `LinkedSpec::ActionRewriter::_value_expr_deps()` to use `ValueExpr` directly,
  - removed the now-unused `LinkedSpec::Deps::value_expr_deps_for_package(...)`.
- Regression addition/update:
  - added `action_rewriter_avoids_deps_value_expr_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ValueExpr.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=165`)
## Session Notes (2026-03-11)
- Backbone Item #3 follow-up slice completed against action-contract default dependency ownership.
- Slice-selection rationale:
  - after moving specialized declare-method and the recent ActionIR orchestration dep-builders into their owner modules, the next small remaining active seam was contract construction,
  - `LinkedSpec::ActionIR::Contracts` already owned the grouped lowering-contract builders but still depended on `LinkedSpec::Deps` for its ActionRewriter-facing default callback map,
  - moving that map into `Contracts` keeps contract construction behavior and default wiring on the same owner surface.
- Implementation scope:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::Contracts`,
  - rewired `LinkedSpec::ActionRewriter::_action_contract_deps()` to use `Contracts` directly,
  - removed the now-unused `LinkedSpec::Deps::action_rewriter_contract_deps_for_package(...)`.
- Regression addition/update:
  - added `action_rewriter_avoids_deps_action_contract_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=164`)
## Session Notes (2026-03-11)
- Backbone Item #3 follow-up slice completed against specialized declare-method default dependency ownership.
- Slice-selection rationale:
  - after moving rewrite-pipeline, diagnostics, canonical-event, statement-split, and scanner default dep-builders into their owner modules, the next smallest remaining specialized ActionIR default wiring mismatch was declare-method lowering,
  - `LinkedSpec::ActionIR::DeclareMethod` already owned the actual `declare(...)` and `assign(...)` method lowering but still depended on `LinkedSpec::Deps` for its ActionRewriter-specific default callback map,
  - moving that map into `DeclareMethod` keeps declare-method lowering behavior and default wiring on the same owner surface.
- Implementation scope:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::DeclareMethod`,
  - rewired `LinkedSpec::ActionRewriter::_declare_method_deps()` to use `DeclareMethod` directly,
  - removed the now-unused `LinkedSpec::Deps::action_rewriter_declare_method_deps_for_package(...)`.
- Regression addition/update:
  - added `action_rewriter_avoids_deps_declare_method_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/DeclareMethod.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=163`)
## Session Notes (2026-03-11)
- Backbone Item #3 follow-up slice completed against rewrite-pipeline default dependency ownership.
- Slice-selection rationale:
  - after moving diagnostics, canonical-event, statement-split, and scanner default dep-builders into their owner modules, the next small remaining ActionIR default wiring mismatch was rewrite-pipeline orchestration,
  - `LinkedSpec::ActionIR::RewritePipeline` already owned rule construction and canonical-IR-driven rewrite execution but still depended on `LinkedSpec::Deps` for its default callback map,
  - moving that map into `RewritePipeline` keeps rewrite orchestration and default wiring on the same owner surface.
- Implementation scope:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::RewritePipeline`,
  - rewired `LinkedSpec::ActionRewriter::_rewrite_pipeline_deps()` to use `RewritePipeline` directly,
  - removed the now-unused `LinkedSpec::Deps::action_rewriter_rewrite_pipeline_deps_for_package(...)`.
- Regression addition/update:
  - added `action_rewriter_avoids_deps_rewrite_pipeline_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=162`)
## Session Notes (2026-03-11)
- Backbone Item #3 follow-up slice completed against diagnostics default dependency ownership.
- Slice-selection rationale:
  - after moving scanner, statement-split, and canonical-event default dep-builders into their owner modules, the next small remaining ActionIR default wiring mismatch was diagnostics,
  - `LinkedSpec::ActionIR::Diagnostics` already owned unresolved-helper and helper-event accumulation but still depended on `LinkedSpec::Deps` for its default callback map,
  - moving that map into `Diagnostics` keeps diagnostics behavior and default wiring on the same owner surface.
- Implementation scope:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::Diagnostics`,
  - rewired `LinkedSpec::ActionRewriter::_diagnostics_deps()` to use `Diagnostics` directly,
  - removed the now-unused `LinkedSpec::Deps::action_rewriter_diagnostics_deps_for_package(...)`.
- Regression addition/update:
  - added `action_rewriter_avoids_deps_diagnostics_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Diagnostics.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=161`)
## Session Notes (2026-03-11)
- Backbone Item #3 follow-up slice completed against canonical-event default dependency ownership.
- Slice-selection rationale:
  - after moving scanner and statement-split default dep-builders into their owner modules, the next small remaining ActionIR default wiring mismatch was canonical-event construction,
  - `LinkedSpec::ActionIR::CanonicalEvents` already owned canonical helper-event normalization and event assembly but still depended on `LinkedSpec::Deps` for its default callback map,
  - moving that map into `CanonicalEvents` keeps canonical-event behavior and default wiring on the same owner surface.
- Implementation scope:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::CanonicalEvents`,
  - rewired `LinkedSpec::ActionRewriter::_canonical_event_deps()` to use `CanonicalEvents` directly,
  - removed the now-unused `LinkedSpec::Deps::action_rewriter_canonical_event_deps_for_package(...)`.
- Regression addition/update:
  - added `action_rewriter_avoids_deps_canonical_event_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=160`)
## Session Notes (2026-03-11)
- Backbone Item #3 follow-up slice completed against statement-split default dependency ownership.
- Slice-selection rationale:
  - after moving scanner defaults into `Scanner`, the next smallest remaining owner mismatch in the active ActionIR path was statement splitting,
  - `LinkedSpec::ActionIR::StatementSplit` already owned the split implementation but still depended on `LinkedSpec::Deps` for its one default callback map,
  - moving that map into `StatementSplit` keeps the owner surface and default wiring together.
- Implementation scope:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::StatementSplit`,
  - rewired `LinkedSpec::ActionRewriter::_statement_split_deps()` to use `StatementSplit` directly,
  - removed the now-unused `LinkedSpec::Deps::action_rewriter_statement_split_deps_for_package(...)`.
- Regression addition/update:
  - added `action_rewriter_avoids_deps_statement_split_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=159`)
## Session Notes (2026-03-11)
- Backbone Item #3 follow-up slice completed against scanner default dependency ownership.
- Slice-selection rationale:
  - after moving scanner-rule rebinding into `ScannerCore`, the remaining default dep-builder still lived in `LinkedSpec::Deps`,
  - that left the active scanner path split across two owners even though `ActionRewriter` only uses the scanner dep-builder in one place,
  - moving the default dep map into `LinkedSpec::ActionIR::Scanner` makes the scanner owner module define both its active surface and its default callback wiring.
- Implementation scope:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::Scanner`,
  - rewired `LinkedSpec::ActionRewriter::_scan_contract_ir_event_deps()` to use `Scanner` directly,
  - removed the now-unused `LinkedSpec::Deps::action_rewriter_scanner_deps_for_package(...)`.
- Regression addition/update:
  - added `action_rewriter_avoids_deps_scanner_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=158`)
## Session Notes (2026-03-11)
- Backbone Item #3 follow-up slice completed against `LinkedSpec::ActionIR::ScannerCore` scanner-rule dependency orchestration.
- Slice-selection rationale:
  - the active `LinkedSpec::*` scope still allows internal ActionIR cleanup even while external plugin-runtime work is out of bounds,
  - `scan_contract_ir_events(...)` still embedded scanner-rule dependency rebinding and dispatcher selection inline,
  - extracting those pieces into `ScannerCore` owner helpers narrows the remaining inline orchestration inside the contract scanner without changing rule-package behavior.
- Implementation scope:
  - added `_scanner_rule_dep_bindings(...)`, `_with_scanner_rule_deps(...)`, and `_scanner_dispatchers()` to `LinkedSpec::ActionIR::ScannerCore`,
  - rewired `scan_contract_ir_events(...)` to use those owner helpers.
- Regression addition/update:
  - added `actionir_scannercore_uses_scanner_dep_binding_owner`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ScannerCore.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=157`)
## Session Notes (2026-03-11)
- LinkedSpec-only plugin bridge slice completed against `LinkedSpec::PluginBridge` default legacy runtime dependency ownership.
- Slice-selection rationale:
  - current scope remains restricted to `LinkedSpec.pm` and `LinkedSpec::*` modules,
  - `LinkedSpec::PluginBridge::_default_deps()` still expressed its lazy legacy runtime behavior through inline closures,
  - moving those callbacks onto named bridge-owned helpers keeps the compatibility seam local to `LinkedSpec::PluginBridge` and makes later bridge removal/replacement easier to reason about.
- Implementation scope:
  - added `_load_legacy_plugin_runtime(...)` and `_exec_legacy_plugin(...)` to `LinkedSpec::PluginBridge`,
  - updated `_default_deps()` to return those named owner helpers instead of anonymous subs.
- Regression addition/update:
  - added `plugin_bridge_default_load_dep_uses_legacy_runtime_owner`,
  - added `plugin_bridge_default_exec_dep_uses_legacy_exec_owner`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=156`)
## Session Notes (2026-03-11)
- LinkedSpec-only plugin bridge slice completed against `LinkedSpec::PluginBridge` autoload normalization/dispatch ownership.
- Slice-selection rationale:
  - current scope is restricted to `LinkedSpec.pm` and `LinkedSpec::*` modules,
  - `LinkedSpec::PluginBridge::_dispatch_autoload(...)` still combined autoload normalization with explicit-name runtime dispatch in one function,
  - splitting those stages gives the bridge a clearer explicit-name owner path without touching external runtime packages.
- Implementation scope:
  - added `_require_plugin_name(...)` and `_dispatch_plugin_name(...)` to `LinkedSpec::PluginBridge`,
  - `_dispatch_autoload(...)` now normalizes and then delegates to `_dispatch_plugin_name(...)`.
- Regression addition/update:
  - added `plugin_bridge_dispatch_plugin_name_supports_injected_runtime_deps`,
  - added `plugin_bridge_dispatch_plugin_name_rejects_invalid_name_before_runtime_load`,
  - added `plugin_bridge_autoload_uses_dispatch_plugin_name_owner`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=154`)
## Session Notes (2026-03-11)
- Plugin/runtime modernization slice completed against repo-owned explicit plugin callers outside the `PluginBridge` autoload path.
- Slice-selection rationale:
  - the roadmap calls for moving away from mixed-name compatibility dispatch toward explicit plugin identifiers,
  - several internal callers already had explicit plugin names but still routed through the legacy `PPlugin::exec(...)` wrapper,
  - migrating those low-risk callsites reduces remaining mixed-name compatibility usage without changing plugin semantics.
- Implementation scope:
  - changed `HUtils::GenericFilter(...)`, `RTLUtils`, `TableScript::http_exec(...)`, and `plugin/string.plg` to call `PPlugin::exec_plugin_name(...)`,
  - left `PPlugin::exec(...)` and autoload-style compatibility entrypoints in place for remaining mixed-name callers.
- Regression addition/update:
  - added `tablescript_http_exec_uses_pplugin_explicit_name_owner`,
  - added `hutils_generic_filter_uses_pplugin_explicit_name_owner`.
- Validation snapshot:
  - `perl -Iperl -c perl/HUtils.pm` -> OK
  - `perl -Iperl -c perl/RTLUtils.pm` -> OK
  - `perl -Iperl -c perl/TableScript.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=151`)
## Session Notes (2026-03-11)
- Plugin/runtime modernization slice completed against `PPlugin` module-load coupling to `LinkedSpec`.
- Slice-selection rationale:
  - the roadmap calls for narrowing legacy plugin runtime coupling and making dependency ownership explicit,
  - `PPlugin.pm` still loaded `LinkedSpec` eagerly at module import time even though that dependency is only needed for the default parser callback,
  - deferring that load reduces legacy startup coupling while preserving the compatibility parser path.
- Implementation scope:
  - removed eager `use LinkedSpec;` from `PPlugin.pm`,
  - added explicit `Cwd`, `File::Basename`, and `File::Spec` ownership to `PPlugin.pm`,
  - changed `_default_deps()->{load_plugin_parser}` to `require LinkedSpec` lazily before calling `LinkedSpec::get_parser('pplugin')`.
- Regression addition/update:
  - added `pplugin_require_does_not_eagerly_load_linkedspec`,
  - added `pplugin_default_parser_dep_lazy_loads_linkedspec`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/PPlugin.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=149`)
## Session Notes (2026-03-11)
- Plugin/runtime modernization slice completed against the legacy registry-construction boundary inside `PPlugin::new(...)`.
- Slice-selection rationale:
  - the roadmap calls for explicit plugin runtime seams instead of hardwired legacy construction paths,
  - `PPlugin::new(...)` still initialized the cached legacy registry by calling parser loading, plugin-file discovery, and registry assembly inline,
  - extracting a dependency-owned loader seam keeps compatibility behavior stable while narrowing the remaining implicit coupling to `LinkedSpec`.
- Implementation scope:
  - added `_require_dep(...)`, `_default_deps()`, and `_load_legacy_registry(...)` to `PPlugin`,
  - `PPlugin::new(...)` now builds its cached legacy registry through `_load_legacy_registry()`,
  - default deps make `pplugin` parser loading, `.plg` discovery, and registry assembly explicit callbacks instead of inline calls.
- Regression addition/update:
  - added `pplugin_load_legacy_registry_uses_explicit_dependency_callbacks`,
  - added `pplugin_default_registry_deps_load_through_explicit_owner_paths`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/PPlugin.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=147`)
## Session Notes (2026-03-11)
- Plugin/runtime modernization slice completed against the legacy plugin-execution boundary between `LinkedSpec::PluginBridge` and `PPlugin`.
- Slice-selection rationale:
  - the roadmap calls for replacing mixed method-name extraction plus implicit dispatch with explicit plugin identifiers and deterministic runtime seams,
  - `LinkedSpec::PluginBridge` already normalized plugin names, but its default runtime dependency still called the older mixed-name `PPlugin::exec(...)` wrapper,
  - moving the default bridge runtime onto `PPlugin::exec_plugin_name(...)` narrows the compatibility surface while preserving direct legacy callers.
- Implementation scope:
  - added `PPlugin::exec_plugin_name(...)` as the explicit owner for normalized plugin-name dispatch,
  - added `PPlugin::_normalize_plugin_name(...)` so `PPlugin::exec(...)` and `PPlugin::AUTOLOAD` remain compatibility wrappers around that owner path,
  - updated `LinkedSpec::PluginBridge::_default_deps()` to execute through `PPlugin::exec_plugin_name(...)`.
- Regression addition/update:
  - added `plugin_bridge_default_exec_dep_uses_pplugin_explicit_name_owner`,
  - added `pplugin_exec_wrapper_normalizes_to_explicit_name_owner`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/PPlugin.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=145`)
## Session Notes (2026-03-11)
- Plugin/runtime modernization slice completed against the legacy `.plg` registry builder in `PPlugin`.
- Slice-selection rationale:
  - the roadmap calls for moving away from implicit inline legacy registry state toward explicit, replaceable plugin runtime seams,
  - `PPlugin::new(...)` still built the legacy `.plg` registry inline even after deterministic file discovery was extracted,
  - extracting the registry builder keeps compatibility behavior stable while narrowing the future replacement boundary.
- Implementation scope:
  - added `_build_plugin_registry(...)` to `PPlugin`,
  - `PPlugin::new(...)` now passes the ordered `.plg` file list into that helper instead of building the registry inline,
  - malformed legacy plugin parses are skipped with warning while later plugin files still override earlier duplicate plugin names.
- Regression addition/update:
  - added `pplugin_build_plugin_registry_preserves_file_order_and_skips_parse_failures`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/PPlugin.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=143`)
## Session Notes (2026-03-10)
- Plugin/runtime modernization slice completed against the legacy `.plg` adapter in `PPlugin`.
- Slice-selection rationale:
  - the roadmap calls for moving away from implicit cwd/project-root globbing as the primary plugin runtime contract,
  - `PPlugin` still discovered legacy plugin files through brace-glob expansion over two roots,
  - extracting explicit helper stages gives the legacy adapter a deterministic file-order seam without changing current compatibility behavior.
- Implementation scope:
  - added `_plugin_project_root(...)`, `_legacy_plugin_search_roots(...)`, and `_legacy_plugin_files(...)` to `PPlugin`,
  - replaced brace-glob enumeration in `PPlugin::new(...)` with sorted cwd-first helper enumeration and duplicate file-path filtering.
- Regression addition/update:
  - added `pplugin_legacy_plugin_search_roots_are_cwd_first_and_deduped`,
  - added `pplugin_legacy_plugin_files_are_sorted_and_deduped`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/PPlugin.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=142`)
## Session Notes (2026-03-10)
- Plugin/runtime modernization slice completed against the legacy `AUTOLOAD` compatibility bridge in `LinkedSpec::PluginBridge`.
- Slice-selection rationale:
  - the roadmap calls for moving away from method-name extraction as the primary plugin runtime contract,
  - `LinkedSpec::PluginBridge` already owned the injected load/exec seam but still forwarded full Perl autoload names into the runtime callback,
  - normalizing to explicit plugin names narrows the bridge toward a deterministic registry interface without changing `LinkedSpec::AUTOLOAD`.
- Implementation scope:
  - added `_normalize_plugin_name(...)` to `LinkedSpec::PluginBridge`,
  - `_dispatch_autoload(...)` now validates and normalizes the autoloaded method name before runtime load/exec,
  - invalid autoload names now fail before any plugin runtime side effects.
- Regression addition/update:
  - `plugin_bridge_supports_injected_plugin_runtime_deps` now proves the exec callback receives normalized plugin names,
  - added `plugin_bridge_rejects_invalid_autoload_name_before_runtime_load` to prove invalid autoload names do not load the legacy runtime or call exec.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=140`)
## Session Notes (2026-03-10)
- Phase 1A cleanup slice completed against the dead validation facade wrappers in `LinkedSpec.pm`.
- Slice-selection rationale:
  - `LinkedSpec::Compiler` and `LinkedSpec::Validation` already owned the active compile-time validation path,
  - the remaining `LinkedSpec.pm` validation helpers were definition-only delegates with no live repo callers,
  - removing them tightens the façade surface without changing `Get(...)`, `get_parser(...)`, or validation behavior.
- Implementation scope:
  - deleted `get_dsl_context(...)`, `report_dsl_error(...)`, `validate_spec_content(...)`, `validate_rule_definition(...)`, `validate_gdata_references(...)`, `validate_dsl_syntax(...)`, and `extract_regex_literals_from_rule_rhs(...)` from `LinkedSpec.pm`,
  - removed the now-unused `LinkedSpec::Validation` import from `LinkedSpec.pm`,
  - expanded the malformed-spec and return-descriptor seam locks to trap the removed validation helper names directly.
- Regression addition/update:
  - `get_parser_malformed_spec_reports_validation_error` now traps the removed validation facade helpers and proves DSL line-context reporting still stays on `LinkedSpec::Validation`,
  - added `get_return_descriptor_avoids_removed_linkedspec_validation_facade` to prove successful descriptor build paths do not depend on the removed helper names.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Validation.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=139`)
## Session Notes (2026-03-10)
- Phase 1A cleanup slice completed against the dead internal trace/runtime helper wrappers in `LinkedSpec.pm`.
- Slice-selection rationale:
  - `LinkedSpec::Trace`, `LinkedSpec::ParserFactory`, and `LinkedSpec::SpecEntry` already owned the active trace/parser-source paths,
  - the remaining `LinkedSpec.pm` helpers were definition-only wrappers with no live repo callers,
  - removing them tightens the façade surface without changing the public `configure_trace(...)` entrypoint.
- Implementation scope:
  - deleted `_trace_level_name(...)`, `_apply_trace_options(...)`, and `_emit_parser_source_line(...)` from `LinkedSpec.pm`,
  - expanded the focused trace/spec-entry seam locks to trap the removed helper names directly.
- Regression addition/update:
  - `get_parser_avoids_linkedspec_parser_factory_facade` now traps `_trace_level_name(...)` alongside the already-removed trace wrapper surface,
  - `spec_entry_compile_spec_entry_uses_injected_runtime_context` now traps `_emit_parser_source_line(...)` and proves parser-source emission still flows through injected runtime context only.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Trace.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=138`)
## Session Notes (2026-03-10)
- Phase 1A cleanup slice completed against the dead internal ActionIR lowering/dependency delegate block in `LinkedSpec.pm`.
- Slice-selection rationale:
  - `LinkedSpec::ActionRewriter` and the extracted ActionIR modules already owned the active lowering path,
  - the remaining `LinkedSpec.pm` helpers were definition-only delegates with no live repo callers beyond seam traps,
  - removing them tightens the façade surface without changing the public compatibility shim `LinkedSpec::call_spec_handler_subst(...)`.
- Implementation scope:
  - deleted the stale internal dependency builders and lowering/parser/extraction wrappers for flow/value/declare/method/array-pipeline/control-flow helper lowering,
  - removed the now-unused ActionIR/Deps imports from `LinkedSpec.pm`,
  - expanded the focused ActionRewriter seam lock to trap those removed names directly while exercising broader owner-path lowering coverage.
- Regression addition/update:
  - renamed the seam lock to `action_rewriter_avoids_removed_linkedspec_lowering_facade`,
  - added explicit `is_empty(...)` flow coverage and composable array-pipeline coverage to prove the removed helper surface is not used on the active path.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=138`)
## Session Notes (2026-03-10)
- Phase 1A cleanup slice completed against the dead internal `Compiler`/`RuleIR`/action-contract delegate block in `LinkedSpec.pm`.
- Slice-selection rationale:
  - `LinkedSpec::Compiler`, `LinkedSpec::SpecEntry`, `LinkedSpec::RuleIR`, and `LinkedSpec::ActionRewriter` already owned the active descriptor/rule-compilation path,
  - the remaining `LinkedSpec.pm` helpers were definition-only delegates with no live repo callers,
  - removing them tightens the façade surface without changing the public entrypoints `Get(...)`, `spec_descr(...)`, or `call_spec_handler_subst(...)`.
- Implementation scope:
  - deleted the stale internal `LinkedSpec.pm` delegates for descriptor-level migration summary, action-contract defaults, RuleIR collection/planning/validation, and emit-context assembly,
  - added a focused seam lock that traps those removed names while exercising both `spec_descr(...)` and `Get(..., return_descriptor => 1)`.
- Regression addition:
  - added `spec_descr_and_get_avoid_removed_linkedspec_ruleir_internal_facade`,
  - the regression proves default rule-compilation and descriptor-assembly paths no longer depend on any of the removed internal delegate names.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=138`)
## Session Notes (2026-03-10)
- Phase 1A cleanup slice completed against the dead internal ActionRewriter delegate block in `LinkedSpec.pm`.
- Slice-selection rationale:
  - `LinkedSpec::RuleIR::EmitContext` and `LinkedSpec::ActionRewriter` already owned the active rewrite/scanner/canonicalization path,
  - the remaining `LinkedSpec.pm` helpers were definition-only internal delegates with no live repo callers,
  - removing the dead block tightens the façade surface without changing the public compatibility shim `LinkedSpec::call_spec_handler_subst(...)`.
- Implementation scope:
  - deleted the stale internal `LinkedSpec.pm` delegates for unresolved-helper scanning, canonical event construction, statement splitting, rewrite-rule construction, canonical lowering, and diagnostics accumulation,
  - updated the focused RuleIR seam lock to trap those removed helper names directly.
- Regression addition/update:
  - renamed the seam lock to `ruleir_emit_context_avoids_removed_linkedspec_action_rewriter_facade`,
  - expanded it to prove `build_rule_ir_emit_context(...)` does not call any of the removed internal delegate names.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=137`)
## Session Notes (2026-03-10)
- Phase 1A cleanup slice completed against the stale runtime `compile_spec_entry(...)` wrapper in `LinkedSpec::Runtime`.
- Slice-selection rationale:
  - `LinkedSpec::Compiler::spec_descr(...)` and `LinkedSpec::Runtime::run_get(...)` already consumed `LinkedSpec::SpecEntry::compile_spec_entry(...)` as the active owner,
  - the remaining runtime wrapper was only compatibility glue plus focused tests,
  - removing it tightens the runtime surface and leaves rule-entry compilation fully owned by `SpecEntry.pm`.
- Implementation scope:
  - deleted `LinkedSpec::Runtime::compile_spec_entry(...)` from `Runtime.pm`,
  - updated direct injected-state and injected-callback seam tests to call `LinkedSpec::SpecEntry::compile_spec_entry(...)` with `runtime_ctx`.
- Regression addition/update:
  - renamed direct injected-state coverage to `spec_entry_compile_spec_entry_uses_injected_runtime_context`,
  - existing wrapper-bypass regressions still prove the active descriptor-build paths do not depend on the removed runtime wrapper.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=137`)
## Session Notes (2026-03-10)
- Phase 1A cleanup slice completed against the stale façade `spec_entry(...)` helper in `LinkedSpec.pm`.
- Slice-selection rationale:
  - `LinkedSpec::Compiler::spec_descr(...)` and `LinkedSpec::Runtime::run_get(...)` already defaulted rule-entry compilation through `LinkedSpec::SpecEntry::compile_spec_entry(...)`,
  - no active repo caller still needed the `LinkedSpec.pm` wrapper name,
  - removing the wrapper tightens the façade surface and keeps rule-entry compilation owned entirely by `SpecEntry.pm`.
- Implementation scope:
  - deleted `LinkedSpec::spec_entry(...)` from `LinkedSpec.pm`,
  - left active rule-entry compilation on `LinkedSpec::SpecEntry::compile_spec_entry(...)`.
- Regression addition:
  - added `spec_descr_paths_avoid_linkedspec_spec_entry_facade`,
  - the regression traps the removed façade helper name and verifies both `LinkedSpec::spec_descr(...)` and `LinkedSpec::Get(..., return_descriptor => 1)` still build compiled handlers and preserve selected handler metadata.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=137`)
## Session Notes (2026-03-10)
- Phase 1A cleanup slice completed against the legacy raw-argument runtime wrapper in `LinkedSpec::Runtime`.
- Slice-selection rationale:
  - `LinkedSpec::Get(...)`, `LinkedSpec::ParserFactory`, and the direct runtime owner path already normalized into `LinkedSpec::Runtime::run_get(...)`,
  - no active repo caller still needed `run_get_from_args(...)`,
  - removing the wrapper tightens the runtime surface and makes `run_get(...)` the only active runtime entrypoint owner.
- Implementation scope:
  - deleted `LinkedSpec::Runtime::run_get_from_args(...)` from `Runtime.pm`,
  - left active runtime/parser generation flow on `LinkedSpec::Runtime::run_get(...)`.
- Regression addition:
  - added `runtime_run_get_avoids_legacy_raw_arg_wrapper`,
  - the regression traps the removed wrapper name and verifies `Runtime::run_get(..., { return_descriptor => 1 })` still returns a descriptor hash with compiled handlers.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=136`)
## Session Notes (2026-03-10)
- Phase 1A cleanup slice completed against the stale façade `spec_gdata(...)` helper in `LinkedSpec.pm`.
- Slice-selection rationale:
  - `LinkedSpec::Compiler::_build_final_descriptor(...)` already owned the default `spec_gdata` callback,
  - no active compiler path still needed the `LinkedSpec.pm` wrapper name,
  - removing the wrapper tightens the façade surface and keeps final descriptor `gdata` compilation owned entirely by `Compiler.pm`.
- Implementation scope:
  - deleted `LinkedSpec::spec_gdata(...)` from `LinkedSpec.pm`,
  - left active final descriptor assembly on `LinkedSpec::Compiler::_build_final_descriptor(...)` and `LinkedSpec::Compiler::spec_gdata(...)`.
- Regression addition:
  - added `compiler_pipeline_avoids_linkedspec_spec_gdata_facade`,
  - the regression traps the removed façade helper name and verifies `Runtime::run_get(..., return_descriptor => 1)` still returns a descriptor hash with compiled `gdata`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=135`)
## Session Notes (2026-03-10)
- Phase 1A cleanup slice completed against the stale façade-local spec-resolution helper in `LinkedSpec.pm`.
- Slice-selection rationale:
  - `LinkedSpec::Resolver` already owned `_resolve_local_spec_path(...)` and `resolve_spec_path(...)`,
  - no active parser path still needed the `LinkedSpec.pm` wrapper name,
  - removing the wrapper tightens the façade surface and makes `Resolver.pm` the only live owner for local/module-relative lookup behavior.
- Implementation scope:
  - deleted `LinkedSpec::_resolve_local_spec_path(...)` from `LinkedSpec.pm`,
  - left active parser resolution on `LinkedSpec::Resolver::resolve_spec_path(...)` and its internal `_resolve_local_spec_path(...)` helper.
- Regression addition:
  - added `get_parser_avoids_linkedspec_local_spec_path_facade`,
  - the regression traps the removed façade helper name and verifies `get_parser('Lispish')` still resolves from a non-project cwd, returns a parser coderef, executes it, and keeps `PathSearch` unloaded.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Resolver.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=134`)
## Session Notes (2026-03-10)
- Phase 1A cleanup slice completed against stale bootstrap parsing scaffolding in `Compiler.pm`.
- Slice-selection rationale:
  - bootstrap parsing had already been reassigned to `LinkedSpec::BootstrapSpec`,
  - `LinkedSpec::Compiler::_run_bootstrap_parse(...)` was left behind as dead compatibility-era scaffolding,
  - removing it tightens the compiler surface and makes the active owner path explicit without changing behavior.
- Implementation scope:
  - deleted the stale `LinkedSpec::Compiler::_run_bootstrap_parse(...)` helper,
  - left the active bootstrap parse flow on `LinkedSpec::BootstrapSpec::run_bootstrap_parse(...)`.
- Regression addition:
  - added `compiler_pipeline_avoids_legacy_run_bootstrap_parse_helper`,
  - the regression traps the old compiler-local helper name and verifies `Runtime::run_get(...)` still returns a valid descriptor through the active BootstrapSpec-owned path.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=133`)
## Session Notes (2026-03-10)
- Started the plugin/runtime modernization track with a no-behavior-change compatibility-shim slice in `LinkedSpec::PluginBridge`.
- Slice-selection rationale:
  - the roadmap already treats `AUTOLOAD` + `.plg` as legacy compatibility that should eventually be replaced by explicit package-based plugins,
  - `LinkedSpec::PluginBridge` was still hardwired directly to `require PPlugin` and `PPlugin->exec(...)`,
  - extracting explicit load/exec callbacks gives the bridge a narrow dependency seam for future runtime replacement without changing `LinkedSpec::AUTOLOAD`.
- Implementation scope:
  - added `_default_deps()` to `LinkedSpec::PluginBridge` for the current lazy `PPlugin` load/exec behavior,
  - added `_dispatch_autoload(...)` as the internal compatibility-shim owner that consumes injected plugin-runtime callbacks,
  - removed the stale `dispatch_autoload(...)` wrapper so `LinkedSpec::AUTOLOAD` now delegates straight to `_dispatch_autoload(...)`.
- Regression additions:
  - added `autoload_avoids_plugin_bridge_wrapper`,
  - added `plugin_bridge_supports_injected_plugin_runtime_deps`,
  - the new regressions verify the `AUTOLOAD -> PluginBridge` handoff and the injected runtime dependency seam independently of direct `PPlugin` calls at the call site.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=132`)
## Session Notes (2026-03-10)
- Phase 1A no-behavior-change modularization slice completed against the compiler/runtime default-callback boundary in `run_get_pipeline(...)`.
- Slice-selection rationale:
  - `Runtime::run_get(...)` still injected `bootstrap_parse` and `compile_spec_entry` into `Compiler::run_get_pipeline(...)` even though the owning modules already lived in `Compiler.pm`, `BootstrapSpec.pm`, and `SpecEntry.pm`,
  - those defaults belong with the compiler pipeline owner rather than the runtime wrapper,
  - moving them narrows `Runtime::run_get(...)` to the single mutable-state concern it still legitimately owns.
- Implementation scope:
  - updated `LinkedSpec::Compiler::run_get_pipeline(...)` to default `bootstrap_parse` and `compile_spec_entry` internally,
  - simplified `LinkedSpec::Runtime::run_get(...)` to inject only `runtime_ctx`,
  - removed the now-unused `LinkedSpec::BootstrapSpec` import from `Runtime.pm`.
- Regression addition:
  - added `runtime_run_get_defers_default_pipeline_callbacks_to_compiler_owner`,
  - the regression traps `LinkedSpec::Compiler::run_get_pipeline(...)` and verifies `Runtime::run_get(...)` now delegates without injecting `bootstrap_parse` or `compile_spec_entry` while still returning a working descriptor hash.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=130`)
## Session Notes (2026-03-10)
- Phase 1A no-behavior-change modularization slice completed against the compiler-owned final-descriptor `spec_gdata` callback seam.
- Slice-selection rationale:
  - `run_get_pipeline(...)` still threaded `\&spec_gdata` explicitly into `_build_final_descriptor(...)` even though both sides already live in `Compiler.pm`,
  - the default `spec_gdata` callback belongs with final descriptor assembly rather than the higher-level pipeline wrapper,
  - moving that default narrows one more internal callback seam without changing descriptor-build behavior.
- Implementation scope:
  - updated `LinkedSpec::Compiler::_build_final_descriptor(...)` to default `spec_gdata` internally,
  - simplified `LinkedSpec::Compiler::run_get_pipeline(...)` to call `_build_final_descriptor($auto_descr_spec)` directly,
  - kept explicit `spec_gdata` callback injection available for focused tests and future internal owner changes.
- Regression addition:
  - added `run_get_pipeline_defers_default_spec_gdata_callback_to_final_descr_owner`,
  - the regression traps `LinkedSpec::Compiler::_build_final_descriptor(...)` and verifies `run_get_pipeline(...)` now delegates without injecting the default `spec_gdata` callback while still returning a working descriptor hash.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=129`)
## Session Notes (2026-03-10)
- Phase 1A no-behavior-change modularization slice completed against the façade-owned `spec_descr(...)` default callback seam.
- Slice-selection rationale:
  - `LinkedSpec::spec_descr(...)` still owned the default `compile_spec_entry` callback even though `Compiler.pm` already owned descriptor assembly,
  - that default belongs with `LinkedSpec::Compiler::spec_descr(...)` rather than the façade wrapper,
  - moving it narrows the façade to a pure delegate without changing descriptor-build behavior.
- Implementation scope:
  - updated `LinkedSpec::Compiler::spec_descr(...)` to default `compile_spec_entry` internally,
  - simplified `LinkedSpec::spec_descr(...)` to a direct delegate into `Compiler.pm`,
  - kept injected compile callbacks supported for focused tests and alternative owner paths.
- Regression addition:
  - added `spec_descr_defers_default_compile_callback_to_compiler_owner`,
  - the regression traps `LinkedSpec::Compiler::spec_descr(...)` and verifies `LinkedSpec::spec_descr(...)` now delegates without injecting the default callback while still returning a working compiled handler hash.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=128`)
## Session Notes (2026-03-10)
- Phase 1A no-behavior-change modularization slice completed against the façade-owned parser-factory dependency builder seam.
- Slice-selection rationale:
  - `LinkedSpec::get_parser(...)` still relied on the private façade helper `_parser_factory_deps()` even though `ParserFactory.pm` already owned parser-factory orchestration,
  - the default trace/resolution/compile dependency map belongs with the parser-factory owner rather than the public wrapper,
  - moving that default wiring into `ParserFactory.pm` makes `get_parser(...)` a thinner delegate without changing behavior.
- Implementation scope:
  - added default dependency-map ownership in `LinkedSpec::ParserFactory::run_get_parser(...)`,
  - removed the now-unused façade helper `_parser_factory_deps()` from `LinkedSpec.pm`,
  - kept the explicit injected-deps seam in `run_get_parser(...)` for focused tests and internal call sites.
- Regression addition:
  - added `get_parser_avoids_linkedspec_parser_factory_dep_builder`,
  - the regression traps `LinkedSpec::_parser_factory_deps()` and verifies `get_parser(...)` still returns a working parser coderef and parses input successfully.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=127`)
## Session Notes (2026-03-10)
- Phase 1A no-behavior-change modularization slice completed against the public `get_parser(...)`/parser-factory option-normalization seam.
- Slice-selection rationale:
  - `LinkedSpec::get_parser(...)` still passed raw flat option pairs into `ParserFactory::run_get_parser(...)`,
  - `ParserFactory.pm` had become the owner of parser-factory orchestration rather than a raw-argument normalization shim,
  - moving option normalization into the public wrapper removes another active compatibility-style boundary without changing parser behavior.
- Implementation scope:
  - updated `LinkedSpec::get_parser(...)` to normalize flat option pairs locally while preserving the existing odd-option fallback to an empty option set,
  - changed `LinkedSpec::ParserFactory::run_get_parser(...)` to consume an option hashref contract directly.
- Regression addition:
  - added `get_parser_normalizes_option_pairs_before_parser_factory`,
  - the regression traps `LinkedSpec::ParserFactory::run_get_parser(...)` and verifies `get_parser(...)` now passes a normalized option hashref with the expected trace keys and values while still returning a working parser coderef.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=126`)
## Session Notes (2026-03-09)
- Phase 1A no-behavior-change modularization slice completed against the public `Get(...)`/runtime wrapper seam.
- Slice-selection rationale:
  - `LinkedSpec::Get(...)` still used `Runtime::run_get_from_args(...)`, which had become a raw-argument compatibility wrapper rather than the active runtime owner,
  - `Runtime::run_get(...)` is the actual owning runtime entrypoint for parser generation,
  - shifting `Get(...)` onto that direct owner removes another active wrapper dependency on the public path without changing behavior.
- Implementation scope:
  - updated `LinkedSpec::Get(...)` to normalize flat option pairs locally and call `LinkedSpec::Runtime::run_get(...)` directly,
  - kept `Runtime::run_get_from_args(...)` as compatibility glue for callers that still invoke the runtime surface with raw flat option pairs.
- Regression addition:
  - added `get_avoids_runtime_run_get_from_args_wrapper`,
  - the regression traps `LinkedSpec::Runtime::run_get_from_args(...)` and verifies `LinkedSpec::Get(...)` still returns a working parser coderef and parses input successfully.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=125`)
## Session Notes (2026-03-09)
- Phase 1A no-behavior-change modularization slice completed against the parser-factory/runtime compile seam.
- Slice-selection rationale:
  - `LinkedSpec::ParserFactory` still depended on `Runtime::run_get_from_args(...)`, which is only a raw-argument compatibility wrapper,
  - the real owning runtime entrypoint for parser compilation is `Runtime::run_get(...)`,
  - shifting parser-factory compilation to that direct owner narrows another active compatibility surface without changing public `get_parser(...)` behavior.
- Implementation scope:
  - changed `ParserFactory::run_get_parser(...)` to forward a normalized option hashref into the injected compile callback,
  - updated `Deps::parser_factory_deps_for_package(...)` so `compile_spec` resolves from `LinkedSpec::Runtime::run_get(...)`,
  - kept `Runtime::run_get_from_args(...)` as compatibility glue for raw `Get(...)`-style callers only.
- Regression extension:
  - expanded `get_parser_avoids_linkedspec_parser_factory_facade`,
  - the regression now also traps `LinkedSpec::Runtime::run_get_from_args(...)` and verifies `get_parser(...)` still resolves, compiles, executes, keeps `PathSearch` unloaded, and emits routed trace output.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=124`)
## Session Notes (2026-03-09)
- Phase 1A no-behavior-change modularization slice completed against bootstrap parse ownership.
- Slice-selection rationale:
  - `Compiler::run_get_pipeline(...)` still knew the raw bootstrap descriptor/index/gdata internals,
  - `Runtime.pm` was still caching bootstrap grammar state locally even though bootstrap grammar ownership conceptually belongs with `BootstrapSpec`,
  - replacing that triple with a single injected bootstrap-parse callback narrows the compiler contract and makes `BootstrapSpec` the real owner of the hardcoded grammar state.
- Implementation scope:
  - added `cached_bootstrap_state()` and `run_bootstrap_parse(...)` to `LinkedSpec::BootstrapSpec`,
  - changed `Compiler::run_get_pipeline(...)` to require `bootstrap_parse` instead of raw bootstrap structures,
  - removed local bootstrap cache ownership from `Runtime::run_get(...)` and injected `LinkedSpec::BootstrapSpec::run_bootstrap_parse(...)` directly.
- Regression addition:
  - renamed/expanded the compiler pipeline seam test to `compiler_run_get_pipeline_uses_injected_bootstrap_parse_and_runtime_context`,
  - the regression now proves `run_get_pipeline(...)` succeeds with the injected bootstrap callback and shared runtime context, and that the callback is invoked exactly once.
- Focused harness refresh:
  - the local bootstrap-entry tests now call `LinkedSpec::BootstrapSpec::run_bootstrap_parse(...)` directly instead of the older compiler-owned helper.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=124`)
## Session Notes (2026-03-09)
- Phase 1A no-behavior-change modularization slice completed against the spec-entry/runtime wrapper seam.
- Slice-selection rationale:
  - `LinkedSpec::SpecEntry` already owned the real rule-entry compilation logic,
  - `LinkedSpec::Runtime::compile_spec_entry(...)` had become a thin wrapper whose remaining job was only to pass parser-source emission and `top_rule` through runtime context,
  - moving that state hook into `SpecEntry.pm` removes another default path through `Runtime.pm` without changing the public `Get(...)` surface.
- Implementation scope:
  - added `runtime_ctx` handling in `SpecEntry::compile_spec_entry(...)` for parser-source emission and `top_rule` propagation,
  - switched `Runtime::run_get(...)` to inject `LinkedSpec::SpecEntry::compile_spec_entry(...)` directly into `Compiler.pm`,
  - updated `LinkedSpec::spec_descr(...)` and `LinkedSpec::spec_entry(...)` to default/delegate directly to `SpecEntry.pm`,
  - retained `Runtime::compile_spec_entry(...)` only as compatibility glue.
- Regression addition:
  - added `spec_entry_paths_avoid_runtime_compile_spec_entry_wrapper`,
  - the regression traps `LinkedSpec::Runtime::compile_spec_entry(...)` and verifies both `LinkedSpec::spec_descr(...)` and `LinkedSpec::Get(..., return_descriptor => 1)` still compile rules successfully.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=124`)
## Session Notes (2026-03-09)
- Phase 1A no-behavior-change modularization slice completed against the compiler/runtime mutable-state seam.
- Slice-selection rationale:
  - `LinkedSpec::Runtime` already had a per-run runtime context,
  - `LinkedSpec::Compiler::run_get_pipeline(...)` was still threading three separate mutable-state deps (`emit_parser_source_line`, `top_rule_ref`, `parser_source_chunks_ref`),
  - collapsing those onto `runtime_ctx` matches the roadmap's shared-context policy and narrows the compiler/runtime contract.
- Implementation scope:
  - added `runtime_ctx` validation helpers in `Compiler.pm`,
  - moved parser-source emission, parser-source chunk storage, and `top_rule` reads in `run_get_pipeline(...)` onto the injected runtime context,
  - simplified `Runtime::run_get(...)` so it injects only `runtime_ctx` for per-run mutable state instead of the older split dependency surface.
- Regression addition:
  - added `compiler_run_get_pipeline_uses_injected_runtime_context`,
  - the regression calls `run_get_pipeline(...)` with only the shared runtime context for mutable state and verifies descriptor build, `top_rule` propagation, and parser-source capture still work.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=123`)
## Session Notes (2026-03-09)
- Phase 1A no-behavior-change modularization slice completed against `Runtime.pm` mutable state handling.
- Slice-selection rationale:
  - the roadmap explicitly calls for reducing package-global cross-cutting state,
  - `LinkedSpec::Runtime` still owned mutable package globals for `top_rule` and parser-source emission,
  - those were good candidates for a small state-shape cleanup because the actual data is naturally per-run, not process-global.
- Implementation scope:
  - grouped cached bootstrap grammar state into one shared lexical runtime hash,
  - introduced per-run runtime context creation in `run_get(...)`,
  - routed parser-source emission through the injected runtime context instead of package-global callback mutation,
  - updated `compile_spec_entry(...)` to accept optional injected runtime context and write discovered `top_rule` into that context.
- Regression addition:
  - added `runtime_compile_spec_entry_uses_injected_runtime_context`,
  - the regression uses a real parsed bootstrap entry and verifies runtime compilation still returns rule info, emits parser-source chunks, and records `top_rule` through injected state.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=122`)
## Session Notes (2026-03-09)
- Phase 1A no-behavior-change modularization slice completed against the parser-factory dependency boundary.
- Slice-selection rationale:
  - `LinkedSpec::ParserFactory` was still getting trace/config/compile callbacks through `LinkedSpec.pm`,
  - the real behavior owners for that surface already lived in `LinkedSpec::Trace`, `LinkedSpec::Resolver`, and `LinkedSpec::Runtime`,
  - this made parser-factory wiring the next small, low-risk façade-indirection cleanup.
- Implementation scope:
  - updated `LinkedSpec::Deps::parser_factory_deps_for_package(...)` so parser-factory trace/config callbacks resolve from `Trace`,
  - compilation now resolves from `LinkedSpec::Runtime::run_get_from_args(...)` instead of `LinkedSpec::Get(...)`,
  - dump-level values now resolve from `LinkedSpec::Trace` instead of `LinkedSpec.pm`.
- Regression addition:
  - added `get_parser_avoids_linkedspec_parser_factory_facade`,
  - the regression traps the old `LinkedSpec.pm` parser-factory façade helper names/values and verifies `get_parser(...)` still resolves `Lispish`, compiles a parser, executes it, keeps `PathSearch` unloaded, and writes routed trace output.
- Trace-contract note:
  - trace metadata now reports the real owning modules (`ParserFactory.pm`, `Resolver.pm`, `Compiler.pm`, etc.) rather than always surfacing `LinkedSpec.pm`,
  - the trace regression was updated to lock metadata presence and ownership rather than the older façade-file assumption.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=121`)
## Session Notes (2026-03-09)
- Phase 1A no-behavior-change modularization slice completed against the action-rewriter lowering boundary.
- Slice-selection rationale:
  - the extracted ActionIR lowering modules already owned the behavior for declare/value/pipeline/control-flow lowering,
  - `LinkedSpec::Deps` still resolved the action-rewriter callback surface through `LinkedSpec.pm`,
  - this made `LinkedSpec::ActionRewriter` the next small, defensible place to cut façade-only indirection.
- Implementation scope:
  - added local wrapper/dependency-builder helpers in `perl/LinkedSpec/ActionRewriter.pm` for the extracted ActionIR lowering modules it already depends on,
  - switched `LinkedSpec::Deps` action-rewriter dependency maps from hardcoded `LinkedSpec.pm` callbacks to package-local `LinkedSpec::ActionRewriter` callbacks for declare/scanner/contract lowering work,
  - kept rewrite output and public compatibility (`LinkedSpec::call_spec_handler_subst(...)`) unchanged.
- Regression addition:
  - added `action_rewriter_avoids_removed_linkedspec_lowering_facade`,
  - the regression traps the old `LinkedSpec::_...` lowering helper names and verifies direct `LinkedSpec::ActionRewriter::call_spec_handler_subst(...)` rewrites still succeed across declare, assign, push, regex, array-pipeline, flow, switch, and return forms.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=120`)
## Session Notes (2026-03-09)
- Phase 1A no-behavior-change modularization slice completed against the RuleIR emit-context boundary.
- Slice-selection rationale:
  - `LinkedSpec::RuleIR::EmitContext` still depended on `LinkedSpec.pm` façade helpers for action-rewriter plumbing,
  - the concrete behavior owner for that helper surface already lived in `LinkedSpec::ActionRewriter`,
  - this made the slice small, low-risk, and aligned with the roadmap goal of shrinking façade-only indirection.
- Implementation scope:
  - added direct `LinkedSpec::ActionRewriter` dependency in `perl/LinkedSpec/RuleIR/EmitContext.pm`,
  - replaced direct `LinkedSpec::_...` action-rewriter helper calls with local wrappers that delegate to `LinkedSpec::ActionRewriter`,
  - kept emit-context output shape and metadata behavior unchanged.
- Regression addition:
  - added `ruleir_emit_context_avoids_linkedspec_action_rewriter_facade`,
  - the regression traps the old façade helper names and verifies `build_rule_ir_emit_context(...)` still succeeds, preserving rewritten ACODE output and rewrite-contract metadata.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm` -> OK
  - `bash tools/run_ci_local.sh` -> PASS (`Files=1, Tests=119`)
## Session Notes (2026-03-09)
- Shared local/GitHub CI slice completed for the phase-0 regression gate.
- Slice-selection rationale:
  - the repo had no committed GitHub Actions workflow yet,
  - the user explicitly wanted a locally runnable pre-push CI path,
  - the first version of the gate still had a correctness gap because it could pass while the workflow/script themselves were untracked.
- Implementation scope:
  - added `tools/run_ci_local.sh` as the repo-root CI entrypoint,
  - added `.github/workflows/ci.yml` to delegate to that shared script on GitHub,
  - tightened the gate so it now requires the workflow file and CI script themselves to be git-tracked,
  - extended the machine-specific absolute-path audit across the LinkedSpec package surface exercised by the gate (`perl/LinkedSpec.pm` + `perl/LinkedSpec/**`), alongside the workflow, script, and phase-0 regression test.
- Validation nuance:
  - the gate was intentionally checked in both directions:
    - it failed while `.github/workflows/ci.yml` was still untracked,
    - it passed after the CI files were added to the index.
- Scope note:
  - older machine-specific literals still exist in non-LinkedSpec/non-gated files such as `perl/env.conf` and `perl/EasyTk.pm`,
  - those are not part of the current phase-0 CI surface and therefore were not made workflow-blocking in this slice.
## Session Notes (2026-03-09)
- Phase 1A no-behavior-change modularization slice completed against the compiler/runtime boundary.
- Slice-selection rationale:
  - the roadmap still points to modularization as the next execution track,
  - the codebase already had extracted `Runtime.pm`, `Compiler.pm`, and `SpecEntry.pm`,
  - `Compiler.pm` still had one unnecessary reverse dependency back into `LinkedSpec.pm` through `LinkedSpec::spec_entry(...)`, making it a good bounded cleanup target.
- Implementation scope:
  - `LinkedSpec::Compiler::spec_descr(...)` now requires an injected `compile_spec_entry` callback instead of directly calling `LinkedSpec::spec_entry(...)`,
  - `LinkedSpec::Compiler::run_get_pipeline(...)` now receives `compile_spec_entry` through explicit dependency injection,
  - `LinkedSpec::Runtime::run_get(...)` now injects `\&compile_spec_entry`, preserving runtime ownership of top-rule propagation,
  - `LinkedSpec::spec_descr(...)` remains a compatibility façade and now supplies the runtime callback internally.
- Regression addition:
  - added `compiler_spec_descr_uses_injected_compile_spec_entry_callback`,
  - the regression locks that compiler-side descriptor assembly can proceed through an injected callback and still returns compiled handler state.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=118`)
## Session Notes (2026-03-09)
- Roadmap post-blocker naming-cleanup slice completed against the ActionIR snapshot-helper surface.
- Slice-selection rationale:
  - the current non-deferred blocked-spec queue is already at zero,
  - `ROADMAP.md` had explicitly queued the clearer rename from `array_values(...)` to `array_copy(...)` once blocker reduction settled down,
  - this was a bounded compatibility-safe follow-up that did not require touching existing specs.
- Implementation scope:
  - `MethodLowering` now accepts `array_copy(array(...))` anywhere direct snapshot value lowering already accepted `array_values(array(...))`,
  - generalized `return(payload)` lowering now recognizes and recursively rewrites nested `array_copy(...)` helpers alongside the legacy alias,
  - `FlowExpr` now whitelists `array_copy(...)` in value-expression passthrough paths so condition/value surfaces stay aligned.
- Compatibility outcome:
  - `array_values(array(...))` remains fully supported and still lowers to the same `[@target]` emitted-Perl shape,
  - the user guides now present `array_copy(...)` as the preferred canonical spelling and `array_values(...)` as compatibility syntax.
- Regression addition:
  - expanded `action_rewriter_lowers_array_snapshot_and_array_assign_method_contracts`,
  - new assertions lock alias behavior in `push_value(...)`, plain `return(payload)`, structured hash payloads, and descriptor readiness.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=117`)
## Session Notes (2026-03-08)
- Roadmap Item #3 slice completed against `portmap.spec`.
- Slice-selection rationale:
  - after the `sdce.spec` cleanup, `portmap.spec` became the next highest remaining blocked spec,
  - its blocker surface was isolated to one raw-only classifier rule, `bare_bit_slice`, so the slice required no new lowering contracts.
- Migration scope:
  - `bare_bit_slice`
    - replaced the raw `$mcnt = @IMATCH_LIST` / smartmatch return block with helper `if` / `elseif` / `else` control flow
    - helper returns now use `return(array("?kind:", array(flat_array(IMATCH_LIST))))`
    - classification now branches on:
      - `matches(scalar(IMATCH), /:/)` for `slice`
      - `or(eq(scalar(IMATCH_LIST, 1), "0"), is_nonempty(scalar(IMATCH_LIST, 1)))` for `bit`
      - `matches(scalar(IMATCH_LIST, 0), /^\\d/io)` for `constant`
      - final `else()` for `bare`
- Important implementation nuance:
  - indexed `is_nonempty(scalar(IMATCH_LIST, n))` currently lowers through truthiness,
  - zero-valued captures therefore need explicit handling (`bar[0]` and the low-bit side of `baz[7:0]`),
  - classifying `slice` through `matches(scalar(IMATCH), /:/)` and adding `eq(..., "0")` to the `bit` branch preserved those zero-valued cases cleanly inside helper flow.
- Migration outcome:
  - `portmap` now reports `language_agnostic_blocked_rule_count=0`
  - `bare_bit_slice` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - canonical action-IR coverage for the migrated rule now includes `IF`, `ELIF`, `ELSE`, `ENDIF`, and `RETURN`
- Behavior note:
  - the old raw classifier emitted Perl experimental smartmatch warnings during parsing,
  - those warnings are now gone because the rule no longer lowers through smartmatch.
- Regression addition:
  - added `portmap_bare_bit_slice_helper_flow_eliminates_raw_fallback`
  - added `portmap_bare_bit_slice_classification_smoke`
  - the smoke lock explicitly covers `foo`, `bar[3]`, `bar[0]`, `baz[7:0]`, `0x1f`, `foo[?bar]`, and `{foo bar[2]}`
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=113`)
- Updated blocker scan after this slice:
  - `portmap.spec` no longer appears in the blocked-spec ranking
  - the remaining blocked-spec tail is now:
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)
## Session Notes (2026-03-08)
- Roadmap Item #3 slice completed against `sdce.spec`.
- Slice-selection rationale:
  - after the `lib_reader.spec` cleanup, `sdce.spec` became the highest remaining blocked spec,
  - both blocked rules (`sdc_esplit`, `get_pinport`) were raw-only helper-friendly cleanup candidates, so no new lowering contracts were needed.
- Migration scope:
  - `sdc_esplit`
    - initializer moved to `I.declare(array, pieces).declare(scalar, retv).assign(scalar(IPOS), 0)`
    - child dispatch and plain substring captures now use `assign(...)` plus `push_value(...)`
    - rule exit now uses `return(array_values(array(pieces)))`
  - `get_pinport`
    - initializer moved to `I.declare(array, pieces)`
    - plain-text segment tokenization now uses `split(..., /(\\s+)/)` plus `filter_nonempty(...)`
    - brace-content tokenization now uses `split(..., /\\s+/)` plus `filter_nonempty(...)`
    - append semantics are preserved with `assign(array(pieces), array(flat_array(pieces), flat_array(segment_parts)))`
    - structured return now uses `return(array(flat_array(IMATCH_LIST), array_values(array(pieces))))`
- Important implementation nuance:
  - preserving the original token stream required two different split delimiters:
    - `/(\\s+)/` on the plain-text `LS` path to preserve interstitial whitespace tokens,
    - `/\\s+/` on the brace path to preserve the older `=~ /\\S+/og` behavior,
  - `assign(array(...), array(flat_array(...), flat_array(...)))` is a viable canonical replacement for raw `push @pieces, LIST` splice behavior when order must be preserved.
- Migration outcome:
  - `sdce` now reports `language_agnostic_blocked_rule_count=0`
  - `sdc_esplit` and `get_pinport` now report `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - canonical action-IR coverage now includes:
    - `sdc_esplit`: `ASSIGN`, `CALL`, `DECLARE`, `PUSH`, `RETURN`
    - `get_pinport`: `ASSIGN`, `CALL`, `DECLARE`, `SPLIT`, `FILTER_NONEMPTY`, `RETURN`
- Regression addition:
  - added `sdce_helper_flow_eliminates_raw_fallback`
  - the lock verifies per-rule zero raw fallback, zero unresolved-helper hits, canonical node coverage, and descriptor-level zero-blocker summary state
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=111`)
- Manual semantic spot-check:
  - representative parser outputs for `[get_port foo bar]`, `[get_port foo {bar baz}]`, and `[get_pin clk [get_port data]]` matched the pre-migration baseline.
- Updated blocker scan after this slice:
  - `sdce.spec` no longer appears in the blocked-spec ranking
  - the current top blocked spec is now `portmap.spec` (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`)
## Session Notes (2026-03-08)
- Roadmap Item #3 slice completed against `lib_reader.spec`.
- Slice-selection rationale:
  - after the `DT.spec` + `hlink_substitution.spec` commit, `lib_reader.spec` became the highest remaining blocked spec,
  - its blockers were still in the helper-friendly cleanup family: quote normalization, split-based attribute packaging, and the raw `say` syntax-error branch in `group`.
- Migration scope:
  - `group`
    - initializer moved from brace-block helper statements to method-chain form:
      - `I.declare(...).substr(...)`
    - close action migrated to method-style `.return(array(...))`
    - syntax-error branch now uses canonical `say(...)` helper syntax plus `exit 1`
  - `sattribute`
    - migrated to:
      - `I.declare(...).substr(...).return(array(...))`
  - `cattribute`
    - migrated to:
      - `I.declare(...).declare(array, value_items).substr(...).split(...).return(array(...))`
- Important implementation nuance:
  - the direct brace-block helper form for these initializer rules still left `raw_perl_dependency_count > 0` in descriptor metadata even though the same helper statements lowered correctly through `call_spec_handler_subst(...)`,
  - converting the initializer logic to method-chain form (`I.declare(...).substr(...).return(...)`) cleared the raw-fallback metadata and made the rules language-agnostic-action-IR ready,
  - for this rule family, method-chain initializer syntax is therefore the safer migration form than multiline helper statements inside `I { ... }`.
- Migration outcome:
  - `lib_reader` now reports `language_agnostic_blocked_rule_count=0`
  - `group`, `sattribute`, and `cattribute` now report `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `group` canonical action-IR nodes now include `DECLARE`, `REGEX_SUBST`, `PUSH`, `RETURN`, `SAY`, and `EXIT`
- Regression addition:
  - added `lib_reader_helper_flow_eliminates_raw_fallback`
  - the lock verifies per-rule zero raw fallback, zero unresolved-helper hits, readiness, and descriptor-level zero-blocker summary state
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=110`)
- Updated blocker scan after this slice:
  - `lib_reader.spec` no longer appears in the blocked-spec ranking
  - the current top blocked spec is now `sdce.spec` (`BLOCKED=2`, `TOP=sdc_esplit`, `BLOCKERS=5`)
## Session Notes (2026-03-08)
- Roadmap Item #3 slice completed against `hlink_substitution.spec`.
- Slice-selection rationale:
  - after the `DT.spec` cleanup, `hlink_substitution.spec` and `lib_reader.spec` were tied as the next blocker leaders,
  - `hlink_substitution` was the lower-risk slice because its blockers were limited to raw error prints plus one helper-friendly accumulator push in `substitute_top`,
  - `lib_reader` still wants conditional regex-substitution cleanup in three rules.
- Migration scope:
  - converted `substitute_top` from mixed raw Perl helper wrappers into canonical helper flow:
    - `declare(scalar, retv); declare(array, word_items)`
    - `assign(scalar(retv), call(...))`
    - `push_value(array(word_items), scalar(retv))`
    - `if(is_nonempty(array(word_items))) ... return(array_values(array(word_items))) ... return_undef()`
  - converted the remaining raw error prints in:
    - `substitute_top`
    - `substitute_statement2`
    - `curlyb`
- Migration outcome:
  - `hlink_substitution` now reports `language_agnostic_blocked_rule_count=0`
  - the migrated rules now report `raw_perl_dependency_count=0` and `language_agnostic_action_ir_ready=1`
  - canonical action-IR coverage now includes `DECLARE`, `ASSIGN`, `PUSH`, `IF`, `PRINT`, `EXIT`, and `RETURN` in `substitute_top`
- Regression addition:
  - added `hlink_substitution_helper_flow_eliminates_raw_fallback`
  - the lock verifies per-rule zero raw fallback, zero unresolved-helper hits, node coverage, and descriptor-level zero-blocker summary state
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=109`)
- Updated blocker scan after this slice:
  - `hlink_substitution.spec` no longer appears in the blocked-spec ranking
  - the current top blocked spec is now `lib_reader.spec` (`BLOCKED=3`, `TOP=group`, `BLOCKERS=4`)
## Session Notes (2026-03-08)
- Roadmap Item #3 slice completed against `DT.spec`.
- Slice-selection rationale:
  - after the `operators_try` commit, `DT.spec` became the highest remaining blocked spec in the corpus-level migration summary,
  - every blocked statement in `DT.spec` was a raw debug print rather than a missing lowering contract,
  - this made the slice another low-risk canonical `print(...)` migration pass.
- Migration scope:
  - replaced raw debug `print "..."` actions with canonical `print(...)` helper flow in:
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
  - converted the old `($IMATCH)` string interpolation cases to canonical helper arguments using `scalar(IMATCH)`
- Migration outcome:
  - `DT` now reports `language_agnostic_blocked_rule_count=0`
  - the migrated rules now report `raw_perl_dependency_count=0` and `language_agnostic_action_ir_ready=1`
  - canonical action-IR node coverage for the migrated rules includes `PRINT`
- Regression addition:
  - added `dt_debug_print_helper_flow_eliminates_raw_fallback`
  - the lock verifies per-rule zero raw fallback plus descriptor-level zero-blocker summary state
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=108`)
- Updated blocker scan after this slice:
  - `DT.spec` no longer appears in the blocked-spec ranking
  - the current highest remaining blocked specs are `hlink_substitution.spec` and `lib_reader.spec`, tied at `BLOCKED=3` / `BLOCKERS=4`
## Session Notes (2026-03-08)
- Roadmap Item #3 slice completed against `operators_try`.
- Slice-selection rationale:
  - the corpus-level migration summary still had `operators_try` as the highest remaining blocked spec before this slice,
  - the blocker statements in that spec were raw debug prints rather than stateful lowering gaps,
  - this made the slice a low-risk, high-yield cleanup that did not require adding new helper surface.
- Migration scope:
  - replaced raw debug `print "..."` actions with canonical `print(...)` helper flow in:
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
  - converted the old `($IMATCH)` string interpolation cases to canonical helper arguments using `scalar(IMATCH)`
  - removed the leftover nested `I { ... }` wrapper in `group[1]`, which was the only residual raw blocker after the first patch
- Migration outcome:
  - `operators_try` now reports `language_agnostic_blocked_rule_count=0`
  - the migrated rules now report `raw_perl_dependency_count=0` and `language_agnostic_action_ir_ready=1`
  - canonical action-IR node coverage for the migrated rules includes `PRINT`
- Regression addition:
  - added `operators_try_debug_print_helper_flow_eliminates_raw_fallback`
  - the lock verifies per-rule zero raw fallback plus descriptor-level zero-blocker summary state
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=107`)
- Updated blocker scan after this slice:
  - `operators_try` no longer appears in the blocked-spec ranking
  - the current top blocked spec is `DT.spec` (`BLOCKED=11`, `TOP=group`, `BLOCKERS=14`)
## Session Notes (2026-03-08)
- Roadmap Item #3 slice completed against `Lispish::parenthesis`, which had been the last remaining top blocked rule in the current blocker-reduction pass.
- Slice-selection rationale:
  - the rule was the only remaining `Lispish` blocker after the earlier small-rule cleanup,
  - the user explicitly rejected raw wrapper assignments like `$retv = call(parenthesis)` as too host-language specific,
  - the smallest clean fix was to make `call(rule)` usable as a canonical assignment value source so the spec could use `assign(scalar(retv), call(parenthesis))`.
- Lowering-surface follow-up:
  - `MethodLowering.pm` now lowers `call(rule)` as a method value expression,
  - `ValueExpr.pm` now special-cases `call(...)` in assignment-source lowering so `assign(scalar(retv), call(rule))` stays canonical instead of being stranded as a raw source string.
- Migration scope:
  - removed the raw declaration block from `Lispish::parenthesis`,
  - removed the raw `LE { ... }` post-dispatch classification logic,
  - replaced the old `@submatchs`/`@word`/`$retv` state machine with helper-only state:
    - `declare(array, word, tail)`
    - `declare(scalar, retv, head, has_head)`
  - recursive child dispatch now uses canonical helper flow:
    - `assign(scalar(retv), call(parenthesis))`
  - token content accumulation now uses:
    - `push_value(array(word), scalaref(retv, {content}))`
  - word flushes now use:
    - `join_values("", array(word))`
    - `push_value(array(tail), ...)`
    - `assign(array(word), array())`
  - final return shape now uses canonical helper flow instead of array slicing:
    - `return(array(undef))`
    - `return(array(scalar(head), undef))`
    - `return(array(scalar(head), array_values(array(tail))))`
- Migration outcome:
  - `Lispish::parenthesis` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - canonical action-IR nodes now include `DECLARE`, `ASSIGN`, `PUSH`, `IF`, `CALL`, and `RETURN`
  - `Lispish` descriptor migration summary now reports `language_agnostic_blocked_rule_count=0`
  - within the previously tracked families (`Lispish`, `vhdl`, `ds_vhistory`, `ebnf`), there is no longer a remaining top blocked rule in descriptor migration metadata
- Regression additions/updates:
  - added a direct lowering lock for `assign(scalar(retv), call(Leaf))`
  - refreshed `lispish_small_helper_flow_eliminates_raw_fallback` to the final zero-blocker state
  - added `lispish_parenthesis_helper_flow_eliminates_raw_fallback`
  - preserved the `lispish_ast_smoke` nested AST baseline
- Documentation follow-up:
  - `USER_GUIDE.md` is now a navigation hub rather than a single terse file
  - the lowering reference is now split into module-focused guides for `DeclareMethod.pm`, `MethodLowering.pm`, `ValueExpr.pm`, `FlowExpr.pm`, `ControlFlow.pm`, `ArrayPipeline.pm`, and `Contracts.pm`
  - the new docs explicitly distinguish canonical helper forms from compatibility-only wrapper surfaces and document the preferred `assign(scalar(retv), call(rule))` form with examples
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=106`)
## Session Notes (2026-03-08)
- Roadmap Item #3 slice completed against `vhdl::subprogram_body`.
- Slice-selection rationale:
  - `subprogram_body` had become the last remaining `vhdl` blocker after the earlier `process_statement` cleanup,
  - the remaining raw path was specialized tokenization rather than broader stateful control flow,
  - adding one small composable helper was lower-risk than attempting the larger `Lispish::parenthesis` migration first.
- Helper-surface addition:
  - added `split_each(array(...), /.../)` to the array pipeline so a rule can split each existing array element and flatten the result,
  - this gives a backend-neutral representation of the previous Perl idiom `grep {length} map {split /^(\s+)/o} split ...`.
- Migration scope:
  - the rule now declares `pos_begin`, `subprogram_statement_part`, and `subprogram_statement_tokens` through helper flow,
  - saved-position capture now uses `assign(scalar(pos_begin), pos $$STRING)`,
  - the statement tail tokenization now uses:
    - `split(array(subprogram_statement_tokens), scalar(subprogram_statement_part), /((?:\s*--.*\s*)+|\s*;\s*)/)`
    - `split_each(array(subprogram_statement_tokens), /^(\s+)/)`
    - `filter_nonempty(array(subprogram_statement_tokens))`
  - final emission now uses generalized `return(array(...))`.
- Migration outcome:
  - `vhdl::subprogram_body` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - canonical action-IR nodes now include `DECLARE`, `ASSIGN`, `SPLIT`, `SPLIT_EACH`, `FILTER_NONEMPTY`, `RETURN`, and existing `CALL`
  - `vhdl` descriptor migration summary now reports `language_agnostic_blocked_rule_count=0`
- Regression additions/updates:
  - added `vhdl_subprogram_body_helper_flow_eliminates_raw_fallback`
  - refreshed `vhdl_declaration_helper_flow_eliminates_raw_fallback`
  - refreshed `vhdl_small_blocker_helper_flow_eliminates_raw_fallback`
  - refreshed `vhdl_process_statement_helper_flow_eliminates_raw_fallback`
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=105`)
- Updated blocker scan after this slice:
  - `vhdl` no longer has blocked rules
  - the current top blocked rule is now only `Lispish::parenthesis` (`raw=6`)
## Session Notes (2026-03-07)
- Roadmap Item #3 slice completed against `ds_vhistory::vhistory`.
- Slice-selection rationale:
  - `vhistory` became tractable once the rule was reframed to build finalized `"?object:"` payloads directly instead of mutating `@$cur_object` in place,
  - this avoided the earlier arrayref-target mutation blocker without introducing new helper surface,
  - `vhdl::subprogram_body` still wants additional split/tokenization cleanup, and `Lispish::parenthesis` remains the larger stateful migration.
- Migration scope:
  - no new helper surface was added,
  - the rule now uses helper declarations for all working state arrays/scalars,
  - capture flush and entry-tag selection now use `scalaref(...)`, `eq(...)`, `if/else/endif`, and `push_value(...)`,
  - finalized object rows are now rebuilt as `array("?object:", scalar(current_object_name), array_values(array(object_hier)))` before being pushed into `vhistory`,
  - the debug print now uses canonical `print(...)` helper flow.
- Migration outcome:
  - `ds_vhistory::vhistory` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `ds_vhistory::vhistory` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, `IF`, `ELSE`, `ENDIF`, `PUSH`, `RETURN`, `CALL`, and `PRINT`
  - `ds_vhistory` descriptor migration summary now reports `language_agnostic_blocked_rule_count=0`
- Regression addition:
  - `ds_vhistory_vhistory_helper_flow_eliminates_raw_fallback`
  - the lock verifies zero raw fallback, zero unresolved helpers, canonical node coverage, readiness, and zero blocked-rule summary state for `ds_vhistory`
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=104`)
- Updated blocker scan after this slice:
  - `ds_vhistory` no longer has blocked rules
  - current top blockers are `Lispish::parenthesis` (`raw=6`) and `vhdl::subprogram_body` (`raw=5`)
## Session Notes (2026-03-07)
- Roadmap Item #3 slice completed against `vhdl::process_statement`.
- Slice-selection rationale:
  - `process_statement` still needed only saved-position tracking, substring capture, and structured return cleanup,
  - `subprogram_body` still wants the extra split/tokenization pipeline over the captured text,
  - `ds_vhistory::vhistory` still wants arrayref-target mutation such as `push @$cur_object, ...`,
  - `process_statement` was therefore the smallest remaining high-priority blocker slice.
- Migration scope:
  - no new helper surface was added,
  - the raw declaration block was replaced with `declare(scalar, pos_begin, process_statement_part)`,
  - saved-position tracking now uses `assign(scalar(pos_begin), pos $$STRING)`,
  - final substring capture and return now use helper flow:
    - `assign(scalar(process_statement_part), substr($$STRING, $pos_begin, $LSPOS - $pos_begin - length $LMATCH))`
    - `return(array("?process_statement:", flat_array(IMATCH_LIST), array_values(array(process_statement)), scalar(process_statement_part)))`
  - leftover commented raw debug-print statements were removed from the action blocks so they no longer count as raw fallback.
- Migration outcome:
  - `vhdl::process_statement` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `vhdl::process_statement` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, and `RETURN` in addition to existing `CALL`/`PUSH`
  - `vhdl` descriptor migration summary now reports `language_agnostic_blocked_rule_count=1`, with only `subprogram_body` still blocked
- Regression additions/updates:
  - added `vhdl_process_statement_helper_flow_eliminates_raw_fallback`
  - refreshed `vhdl_declaration_helper_flow_eliminates_raw_fallback`
  - refreshed `vhdl_small_blocker_helper_flow_eliminates_raw_fallback`
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=103`)
- Updated blocker scan after this slice:
  - the only remaining `vhdl` blocked rule is `subprogram_body` (`raw=5`)
  - current top blockers are `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), and `vhdl::subprogram_body` (`raw=5`)
## Session Notes (2026-03-07)
- Roadmap Item #3 slice completed against the remaining small `Lispish` blockers:
  - `Lispish`
  - `comments`
  - `curlyb`
  - `dquotes`
  - `others`
  - `sbrackets`
  - `spaces`
  - `squotes`
- Slice-selection rationale:
  - `ds_vhistory::vhistory` still wants arrayref-target mutation patterns such as `push @$cur_object, ...` and stateful capture branching,
  - `vhdl::subprogram_body` and `vhdl::process_statement` still want position/substr/split style helper surface,
  - the small `Lispish` rules were therefore the most contained next blocker-reduction slice.
- Migration scope:
  - no new helper surface was added,
  - the top-level syntax error branch now uses canonical `say(...)` call syntax while preserving `exit 1`,
  - the token/leaf rules now return canonical `hash(...)` payloads instead of raw Perl fallback,
  - `curlyb` now uses `declare(scalar, content)` plus `assign(scalar(content), CAPTURE)` before returning its canonical hash payload.
- Migration outcome:
  - `Lispish`, `comments`, `curlyb`, `dquotes`, `others`, `sbrackets`, `spaces`, and `squotes` now report `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `curlyb` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, and `RETURN`
  - top-level `Lispish` canonical action-IR nodes now include `SAY`
  - `Lispish` descriptor migration summary now reports `language_agnostic_blocked_rule_count=1`, with only `parenthesis` still blocked
- Regression addition:
  - `lispish_small_helper_flow_eliminates_raw_fallback`
  - the lock verifies zero raw fallback, zero unresolved helpers, canonical node coverage, readiness, and the reduced `Lispish` blocked-rule summary
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=102`)
- Updated blocker scan after this slice:
  - the only remaining `Lispish` blocked rule is `parenthesis` (`raw=6`)
  - current top blockers are `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), and `vhdl::process_statement` (`raw=4`)
  - `vhdl` still has only two blocked rules left: `subprogram_body` and `process_statement`
## Session Notes (2026-03-07)
- Roadmap Item #3 slice completed against the remaining small `vhdl` blockers:
  - `signal_declaration`
  - `configuration_specification`
  - `vhdl_file`
- Migration scope:
  - no new helper surface was added,
  - `signal_declaration` and `configuration_specification` were cleared by replacing Perl rest-arity destructuring with fixed-arity scalar destructuring,
  - `vhdl_file` was cleared by removing the leftover `$|=1` line-buffering side effect from the start rule.
- Important migration note:
  - this slice confirms that some remaining blockers are purely metadata-shape cleanup rather than new helper-surface gaps,
  - fixed-arity destructuring remains acceptable in these declaration-style VHDL rules, while rest-arity `@remainder_info` destructuring was the actual blocker pattern.
- Migration outcome:
  - `vhdl::signal_declaration`, `vhdl::configuration_specification`, and `vhdl::vhdl_file` now report `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `vhdl` descriptor migration summary now reports `language_agnostic_blocked_rule_count=2`
- Regression additions/updates:
  - added `vhdl_small_blocker_helper_flow_eliminates_raw_fallback`
  - refreshed `vhdl_declaration_helper_flow_eliminates_raw_fallback` so its blocked-count snapshot matches the later cleanup state
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=101`)
- Updated blocker scan after this slice:
  - `vhdl` now has only two blocked rules left: `subprogram_body` (`raw=5`) and `process_statement` (`raw=4`)
  - current top blockers are `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), and `vhdl::process_statement` (`raw=4`)
## Session Notes (2026-03-07)
- Roadmap Item #3 slice completed against `ebnf::grammar_file`.
- Migration scope:
  - no new helper surface was added; the rule now uses existing `declare`, `assign`, `if/endif`, `push_value`, `flat_array`, and generalized `return(array(...))` lowering paths,
  - pending-rule flush now uses canonical helper flow in both the lifecycle exit and `grammar_rule` rollover path,
  - semantic-annotation handoff now uses `assign(array(rule), array(flat_array(semantic_annotations)))` and `assign(array(semantic_annotations), array())`.
- Important DSL usage note:
  - `array_values(array(name))` should remain the array-snapshot helper for arrayref-style payloads,
  - when the intent is list-context insertion into an `array(...)` constructor for an array-target assignment, the canonical form is `array(flat_array(name))`.
- Compatibility decision retained:
  - the rule-binding step continues to use canonical call-wrapper assignment `$rule = call(grammar_rule)`,
  - this already lowers through explicit CALL contracts and did not justify a new helper surface just for this contained slice.
- Migration outcome:
  - `ebnf::grammar_file` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `ebnf` descriptor migration summary now reports `language_agnostic_blocked_rule_count=0`
- Regression addition:
  - `ebnf_grammar_file_helper_flow_eliminates_raw_fallback`
  - the lock verifies zero raw fallback, zero blocker statements, canonical node coverage, readiness, and zero blocked-rule summary state for `ebnf`
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=100`)
- Updated blocker scan after this slice:
  - `ebnf` has no remaining blocked rules
  - current top blockers are `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), and `vhdl::process_statement` (`raw=4`)
  - remaining `vhdl` blocked rules are `subprogram_body`, `process_statement`, `configuration_specification`, `signal_declaration`, and `vhdl_file`
## Session Notes (2026-03-07)
- User design correction for helper surface:
  - explicit per-index expansion like `scalar(IMATCH_LIST, 0), scalar(IMATCH_LIST, 1), ...` is not an acceptable long-term DSL pattern for list-context insertion,
  - instead the DSL now needs a first-class flatten surface for array/hash contents.
- Roadmap Item #3 slice completed by adding flat list helper support and using it to clear two VHDL declaration blockers:
  - added generic list-context helpers:
    - `flat(array(name))`
    - `flatten(array(name))`
    - `flat(hash(name))`
    - `flatten(hash(name))`
  - added non-redundant aliases:
    - `flat_array(name)`
    - `flat_hash(name)`
- Implementation scope:
  - method/value lowering now maps flat helpers to list-context Perl expressions (`@name` / `%name`) for use inside array/hash constructors and direct generalized `return(payload)` forms,
  - `return(payload)` helper detection and method-chain `.return(...)` payload detection now recognize flat helper starts,
  - `hash(...)` constructor lowering now permits flat insertions intermixed with ordinary key/value pairs.
- VHDL migration outcome:
  - `subprogram_declaration` now returns through `flat_array(IMATCH_LIST)` rather than raw `@IMATCH_LIST` expansion,
  - `type_declaration` now uses helper flow `declare` + `assign(..., CAPTURE)` + `return(array(..., flat_array(IMATCH_LIST), ...))`,
  - both rules now report `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`.
- Regression additions:
  - `action_rewriter_lowers_flat_list_value_helpers`
  - `vhdl_declaration_helper_flow_eliminates_raw_fallback`
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=100`)
- Updated blocker scan after this slice:
  - `vhdl` now reports `language_agnostic_blocked_rule_count=5`
  - `vhdl` top blockers are now `subprogram_body` (`raw=5`), `process_statement` (`raw=4`), `configuration_specification` (`raw=1`), `signal_declaration` (`raw=1`), and `vhdl_file` (`raw=1`)
  - broader top blockers remain `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), `ebnf::grammar_file` (`raw=4`), and `vhdl::process_statement` (`raw=4`)
## Session Notes (2026-03-07)
- Roadmap Item #3 slice completed against the VHDL package rules:
  - `package_declaration`
  - `package_body`
- Migration scope:
  - no new helper surface was needed; the slice used existing helper contracts only
  - `package_declaration` now uses helper declaration/assignment/lowercase/return flow:
    - `declare(array, imatch_copy)`
    - `assign(array(imatch_copy), array(scalar(IMATCH_LIST, 0)))`
    - `lowercase_each(array(imatch_copy))`
    - `return(array("?package_declaration:", scalar(array(imatch_copy), 0), array_values(array(package_declaration))))`
  - `package_body` now returns through generalized helper flow:
    - `return(array("?package_body:", scalar(IMATCH_LIST, 0), array_values(array(package_body))))`
- Migration outcome:
  - `vhdl::package_declaration` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `vhdl::package_body` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `vhdl` now reports `language_agnostic_blocked_rule_count=7`
- Regression addition:
  - `vhdl_package_helper_flow_eliminates_raw_fallback`
  - the lock verifies zero raw fallback, canonical node coverage, readiness, and that neither package rule remains in the blocked-rule priority list
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=98`)
- Updated blocker scan after this slice:
  - `vhdl` top blockers are now `subprogram_body` (`raw=5`), `process_statement` (`raw=4`), and `type_declaration` (`raw=2`)
  - broader top blockers remain `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), `ebnf::grammar_file` (`raw=4`), and `vhdl::process_statement` (`raw=4`)
## Session Notes (2026-03-07)
- Roadmap Item #3 slice completed against `vhdl::signal_decl_range`.
- Migration scope:
  - cleared the final remaining raw fallback statement in the rule by replacing raw array reset `@capt = ()` with canonical helper form `assign(array(capt), array())`
  - no new helper surface was needed for this cleanup; it was a contained follow-up on previously landed collection-target assignment support.
- Migration outcome:
  - `vhdl::signal_decl_range` now reports `raw_perl_dependency_count=0`
  - `vhdl::signal_decl_range` now reports `unresolved_helper_count=0`
  - `vhdl::signal_decl_range` now reports `language_agnostic_action_ir_ready=1`
- Regression update:
  - strengthened `vhdl_signal_decl_range_method_flow_reduces_raw_push_capture_fallback`
  - the lock now verifies zero raw fallback statements and full readiness, not just reduced fallback count
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=97`)
- Updated blocker scan after this slice:
  - `vhdl` now reports `language_agnostic_blocked_rule_count=9`
  - current `vhdl` top blockers remain `subprogram_body` (`raw=5`), `process_statement` (`raw=4`), and `package_body` (`raw=2`)
  - broader top blockers remain `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), and `ebnf::grammar_file` (`raw=4`)
## Session Notes (2026-03-07)
- Roadmap Item #3 slice completed against the remaining blocked `tablegrep` terminal/token rules:
  - `and_op`
  - `or_op`
  - `re_term`
- User design correction during the slice:
  - raw Perl hash literals inside `return(payload)` are not backend-neutral enough for the target DSL shape,
  - generalized `return(payload)` therefore needed native helper-based `hash(...)` constructor lowering before the `tablegrep` migration could be considered canonical.
- Implementation scope:
  - added `hash(...)` constructor lowering in `LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr(...)`
  - updated `tablegrep` returns to use canonical `return(hash(...))`
  - rewrote `re_term` to helper flow using:
    - `declare(scalar, field=..., sens=..., re=...)`
    - `if(matches(...))`
    - `substr(...)`
    - `return(hash(...))`
- Migration outcome:
  - `tablegrep::and_op` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `tablegrep::or_op` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `tablegrep::re_term` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `tablegrep` descriptor migration summary now reports `language_agnostic_blocked_rule_count=0`
- Regression additions:
  - `tablegrep_terminal_token_helper_flow_eliminates_raw_fallback`
  - extended `action_rewriter_lowers_general_return_payloads_with_nested_structures` with `return(hash(...))` lowering coverage
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=97`)
- Updated blocker scan after this slice:
  - `tablegrep` has no remaining blocked rules
  - current top blockers remain `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), `ebnf::grammar_file` (`raw=4`), and `vhdl::process_statement` (`raw=4`)
## Session Notes (2026-03-07)
- Roadmap Item #3 slice completed against the final remaining blocked `simenv.spec` rules:
  - `top`
  - `anyvariable`
- Migration scope:
  - `top` now uses helper flow for block collection and return behavior:
    - `declare(array, blocks)`
    - `if(scalar(retv))`
    - `push_value(array(blocks), scalar(retv))`
    - `return(array_values(array(blocks)))` / `return_undef()`
  - `anyvariable` now uses helper flow for variable-name normalization and structured return:
    - `declare(scalar, variable_name=scalar(IMATCH))`
    - `substr(...)` to trim trailing whitespace before `=`
    - `print(...)`
    - generalized `return({...})`
- Migration outcome:
  - `simenv::top` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `simenv::anyvariable` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `simenv` descriptor migration summary now reports `language_agnostic_blocked_rule_count=0`
- Regression addition:
  - `simenv_top_and_anyvariable_helper_flow_eliminates_raw_fallback`
  - verifies zero raw fallback, canonical node coverage, and zero blocked-rule summary state for `simenv`
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` -> OK
  - `perl -c -Iperl t/phase0_regression.t` -> OK
  - `prove -v -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=96`)
- Updated blocker scan after this slice:
  - `simenv` has no remaining blocked rules
  - current top blockers remain `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), `ebnf::grammar_file` (`raw=4`), and `vhdl::process_statement` (`raw=4`)
## Session Notes (2026-03-07)
- Clarified the semantic distinction between:
  - `array(...)` as constructor/container surface
  - `array_values(array(...))` as array snapshot/materialization surface
- User requested a deferred naming cleanup only for now:
  - queue future rename `array_values(array(...))` -> `array_copy(array(...))`
  - keep the current helper name and behavior unchanged in the present codebase
  - expect compatibility preservation during the eventual transition so existing specs continue to work
## Session Notes (2026-03-07)
- Roadmap Item #3 slice completed against the next `simenv.spec` quote/substitution family.
- Migration scope:
  - converted raw diagnostic/debug print statements to canonical `print(...)` helper calls in:
    - `singleline_value`
    - `dquotes`
    - `perl_dquotes`
    - `command_substitution`
    - `perl_command_substitution`
  - rewrote `variable_substitution` to helper flow using:
    - `declare(scalar, variable_name=scalar(IMATCH))`
    - `substr(...)` to strip the leading `$`
    - `print(...)`
    - generalized `return({...})`
  - rewrote `comments` to helper flow using:
    - `declare(scalar, comment_text=scalar(IMATCH))`
    - `substr(...)` to remove the trailing newline
    - `print(...)`
- Migration outcome:
  - all seven migrated rules now report `raw_perl_dependency_count=0`,
  - all seven migrated rules now report `unresolved_helper_count=0` and `language_agnostic_action_ir_ready=1`,
  - the previously remaining `simenv` top blockers (`command_substitution`, `dquotes`, `perl_command_substitution`, `perl_dquotes`) are no longer in the blocked set.
- Regression addition:
  - `simenv_quote_substitution_helper_flow_eliminates_raw_fallback`
  - verifies zero raw fallback, canonical `PRINT` node presence, and readiness across the selected `simenv` quote/substitution rules.
- Validation snapshot:
  - `perl -Iperl -c t/phase0_regression.t` -> OK
  - `prove -Iperl t/phase0_regression.t` -> PASS (`Files=1, Tests=95`)
- Updated blocker scan after this slice:
  - current top blockers are `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), `ebnf::grammar_file` (`raw=4`), and `vhdl::process_statement` (`raw=4`),
  - no `simenv` rules remain in the current top blocked-rule set.
## Session Notes (2026-03-07)
- Roadmap Item #3 slice completed against a focused `simenv.spec` delimiter-helper family.
- Migration scope:
  - converted raw diagnostic/debug print statements to canonical `print(...)` helper calls in:
    - `bs_nl`
    - `squotes`
    - `perl_squotes`
