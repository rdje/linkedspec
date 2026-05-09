# ARCHITECTURE STATE
Live architecture snapshot for LinkedSpec.

This document is the current high-level technical reading of the project shape. It is meant to steer implementation, record important architectural judgments, and give future sessions a fast way to re-enter the codebase with the right mental model.

## Status
- Last refreshed: `2026-04-29`
- Scope of this snapshot:
  - `perl/LinkedSpec.pm`
  - the main owner modules it dispatches into
  - the ActionIR lowering subtree
  - the current legacy plugin/runtime branch

## Maintenance Policy
- Treat this as a live document, not a one-off memo.
- Refresh it at the start of a new session when the current architectural reading has changed materially or when a new deep codebase pass produces a better model.
- Update it when package ownership, major runtime boundaries, compile/lowering seams, or strategic judgments shift.
- Keep it aligned with:
  - `README.md` for discoverability,
  - `ROADMAP.md` for execution direction,
  - `DEVELOPMENT_NOTES.md` for rationale,
  - `MEMORY.md` for interruption-safe continuity.

## Executive Summary
- `perl/LinkedSpec.pm` is now a deliberately thin lazy facade rather than the real implementation center.
- Its static import tree is intentionally shallow; the real architecture is the lazy owner tree it dispatches into.
- In practice that static tree is now almost just `File::Basename` plus `LinkedSpec::OwnerDispatch`; even the public trace globals are simple aliases into `LinkedSpec::Trace`.
- `LinkedSpec::OwnerDispatch` is now the small shared seam for thin-wrapper lazy loading, callback/value lookup, and delegated owner calls.
- `LinkedSpec::OwnerDispatch` now also anchors lazy owner loading to an absolute repo `perl` path at module load time, so later `chdir(...)` does not strand the file-oriented parser/runtime owner tree on stale relative `@INC` entries.
- `Runtime`, `BootstrapSpec`, and `ParserFactory` no longer keep one-shot local `OwnerDispatch` callback-loader or `$@`-preservation wrappers either; the live compile/bootstrap/parser-factory orchestration bodies now spend the shared seam directly where those pass-through helpers were the only consumer.
- `Runtime` no longer keeps a one-shot runtime-owner generated-handler label wrapper either; fallback diagnostics ask `RuntimeContext` for selected top-rule handler-source labels directly through the owner-dispatch seam.
- `ParserFactory` no longer keeps a one-shot generated-handler label wrapper either; parser-factory fallback diagnostics ask `RuntimeContext` for selected top-rule handler-source labels directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot top-rule generated-handler label wrapper either; top-rule-only fallback diagnostics ask `RuntimeContext` for selected top-rule handler-source labels directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot rule-or-top generated-handler label wrapper either; rule-attributed diagnostics ask `RuntimeContext` for concrete-rule-or-selected-top-rule handler-source labels directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot parser-source flush wrapper either; final parser-source output asks `RuntimeContext` to flush captured parser-source text directly through the owner-dispatch seam.
- `Compiler` no longer keeps one-shot runtime-context last-error read wrappers either; parser invocation asks `RuntimeContext` for last-error type/detail reads directly through the owner-dispatch seam when preserving deeper runtime-handler context.
- `Compiler` no longer keeps a one-shot runtime-context top-rule setter wrapper either; selected-top-rule writes ask `RuntimeContext` to update shared top-rule state directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot runtime-context top-rule reader wrapper either; parser-source emission, final descriptor tracing, parser-ready trace metadata, and parser closure capture ask `RuntimeContext` for selected top-rule state directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot runtime-context last-error clear wrapper either; operation-boundary and parser-invocation stale-error cleanup asks `RuntimeContext` to clear `last_error` directly through the owner-dispatch seam.
- `Compiler` no longer keeps a parser-source emission pass-through wrapper either; parser-source line emission asks `RuntimeContext` to append captured source text directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot low-level rule-table runtime-context preparation wrapper either; `build_compiled_rule_table(...)` now inlines its small `top_rule` selection before asking `RuntimeContext` to prepare shared rule-table state.
- `Compiler` no longer keeps a one-shot validation callback availability wrapper either; `run_get_pipeline(...)` checks `Validation::validate_spec_content(...)` availability directly through the owner-dispatch seam.
- `Compiler` no longer keeps a Trace loader wrapper either; its trace helper bodies load `LinkedSpec::Trace` directly through the owner-dispatch seam.
- `Compiler` no longer keeps a pass-through compiler-pipeline last-error setter wrapper either; compiler error boundaries ask `RuntimeContext` to write structured error state directly through the owner-dispatch seam.
- `Compiler` no longer keeps a one-shot active dependency-regex rule-label reader wrapper either; final-descriptor failure attribution reads that active label directly at the diagnostic boundary.
- `Compiler` no longer keeps a one-shot active dependency-regex rule-label clearer wrapper either; dependency-regex boundaries reset that transient diagnostic label directly.
- `Compiler` no longer keeps a scalar-position reset wrapper either; `run_get_pipeline(...)` resets the spec-content scalar position directly at validation and bootstrap-parse boundaries.
- `Compiler` no longer keeps a first parsed-rule label wrapper either; rule-table preparation and final top-rule selection derive the first label directly at each decision point.
- `SpecEntry` no longer keeps a one-shot runtime-context top-rule setter wrapper either; discovered top-rule writes ask `RuntimeContext` to update shared top-rule state directly through the owner-dispatch seam.
- `SpecEntry` no longer keeps a parser-source emission pass-through wrapper either; generated-handler source emission asks `RuntimeContext` to append captured source text directly through the owner-dispatch seam.
- `SpecEntry` no longer keeps a pass-through runtime-handler last-error setter wrapper either; rule-handler compile/eval errors ask `RuntimeContext` to write runtime-handler error state directly through the owner-dispatch seam.
- `SpecEntry` no longer keeps a one-shot runtime-context dependency-reader wrapper either; `compile_spec_entry(...)` reads the optional `runtime_ctx` dependency inline beside RuleIR setup.
- `SpecEntry` no longer keeps a one-shot RuleIR callback availability wrapper either; `compile_spec_entry(...)` checks `RuleIR::_collect_rule_ir(...)` availability directly through the owner-dispatch seam.
- `SpecEntry` no longer keeps a one-shot emit-context callback availability wrapper either; `compile_spec_entry(...)` checks `RuleIR::EmitContext::build_rule_ir_emit_context(...)` availability directly through the owner-dispatch seam.
- `SpecEntry` no longer keeps a Trace loader wrapper either; its trace wrapper bodies load `LinkedSpec::Trace` directly through the owner-dispatch seam.
- `ParserFactory` no longer keeps a one-shot runtime-context preparation wrapper either; `run_get_parser(...)` asks `RuntimeContext` to prepare file-oriented parser state directly through the owner-dispatch seam.
- `ParserFactory` no longer keeps a one-shot runtime-context spec-path setter wrapper either; resolved-spec-path writes ask `RuntimeContext` to update shared file identity directly through the owner-dispatch seam.
- `ParserFactory` no longer keeps a pass-through preserve-existing last-error setter wrapper either; compile-stage fallback writes ask `RuntimeContext` to preserve deeper compile errors directly through the owner-dispatch seam.
- `ParserFactory` no longer keeps a pass-through direct last-error setter wrapper either; setup, validation, resolution, and load errors ask `RuntimeContext` to write parser-factory error state directly through the owner-dispatch seam.
- `Runtime` no longer keeps a one-shot runtime-context preparation wrapper either; `run_get(...)` asks `RuntimeContext` to prepare inline runtime state directly through the owner-dispatch seam.
- `Runtime` no longer keeps an unused direct last-error setter wrapper either; runtime-owner fallback writes stay on the preserve-existing `last_error` path.
- `Runtime` no longer keeps a pass-through preserve-existing last-error setter wrapper either; fallback writes ask `RuntimeContext` to preserve deeper error state directly through the owner-dispatch seam.
- `Runtime` no longer keeps a one-shot compiler callback-loader wrapper either; `run_get(...)` resolves `Compiler::run_get_pipeline(...)` directly through the owner-dispatch seam.
- `Compiler` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still `_require_runtime_ctx(...)` and `run_get_pipeline(...)`, and those now validate the required runtime/pipeline dependencies inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::ValueExpr` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still the value-expression lowering helpers, and those now validate their required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::FlowExpr` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still the flow-expression lowering helpers, and those now validate their required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::ControlFlow` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still the control-flow lowering helpers, and those now validate their required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::MethodLowering` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still the method/value/assignment/return lowering helpers, and those now validate their required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::DeclareMethod` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still the declare/assign lowering helpers, and those now validate their required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ParserFactory` no longer keeps second top-level dependency-validator wrappers either; its meaningful local setup seam is still `run_get_parser(...)`, and that setup path now validates the required trace/resolve/compile callbacks plus trace-level values inline instead of bouncing through separate `_require_dep(...)` or `_require_value_dep(...)` subdefs.
- `PPlugin` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local compatibility seam is still `_load_legacy_registry(...)`, and that loader now validates the required parser/discovery/registry callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `Resolver` no longer keeps local Trace-loader or `$@`-preservation wrappers either; its live trace helper bodies now spend `OwnerDispatch` directly in the same way `Validation` already did.
- `ActionIR::Scanner` no longer keeps local callback-loader or `$@`-preservation wrappers either; its live owner helper bodies now spend `OwnerDispatch` directly while still keeping `_require_scanner_core_pkg(...)` as the meaningful local scanner-core seam.
- `Compiler`, `SpecEntry`, and `RuleIR` no longer keep generic package-loader wrappers either; their Trace / `Data::Dumper` / `LinkedRE` helper seams now spend `OwnerDispatch::require_pkg(...)` directly instead of bouncing through a local `_require_pkg(...)` pass-through.
- `Compiler` no longer keeps a separate `Data::Dumper` loader wrapper either; its meaningful local dump-formatting seam is still `_dump_value(...)`, and that helper now spends `OwnerDispatch::require_pkg(...)` directly inside its `$@`-preserving body.
- `SpecEntry` no longer keeps a separate `Data::Dumper` loader wrapper either; its meaningful local dump-formatting seam is still `_dump_value(...)`, and that helper now spends `OwnerDispatch::require_pkg(...)` directly inside its `$@`-preserving body.
- `SpecEntry` no longer keeps a one-shot generated-handler label wrapper either; runtime-handler construction now asks `RuntimeContext` for rule-metadata generated-handler source labels through the existing owner-dispatch seam.
- `RuleIR` no longer keeps a separate `Data::Dumper` loader wrapper either; its meaningful local dump-formatting seam is still `_dump_value(...)`, and that helper now spends `OwnerDispatch::require_pkg(...)` directly inside its `$@`-preserving body.
- `Compiler` no longer keeps a separate `LinkedRE` loader wrapper either; its meaningful local regex seam is still `_ored_re(...)`, and that helper now spends `OwnerDispatch::require_pkg(...)` directly inside its `$@`-preserving body.
- `Compiler` and `SpecEntry` no longer keep generic callback-loader wrappers either; their named bootstrap/spec-entry/validation and RuleIR/emit-context helper seams now spend `OwnerDispatch::require_pkg_cb(...)` directly instead of bouncing through a local `_require_pkg_cb(...)` pass-through.
- `BootstrapSpec` no longer keeps a separate bootstrap-core loader wrapper either; its meaningful local bootstrap grammar seam is still `build_bootstrap_spec(...)`, and that helper now spends `OwnerDispatch::require_pkg_cb(...)` directly inside its `$@`-preserving body.
- `RuleIR::EmitContext` no longer keeps a generic package-loader wrapper either; its meaningful local seam is `_actionir_owner_package(...)`, and that owner-key registry now spends `OwnerDispatch::require_pkg(...)` directly instead of bouncing through a second local `_require_pkg(...)` layer.
- `ActionIR::StatementSplit::Core` no longer keeps a generic package-loader wrapper either; its meaningful local seams are the statement-split-mode and `MethodExpr` loader helpers, and both now spend `OwnerDispatch::require_pkg(...)` directly instead of bouncing through a second local `_require_pkg(...)` layer.
- `BootstrapSpec::Core` no longer keeps a separate `LinkedRE` loader wrapper either; its meaningful local bootstrap regex seams are still `_linkedre_or(...)` and `_linkedre_ored_re(...)`, and both now spend `OwnerDispatch::require_pkg(...)` directly inside their `$@`-preserving bodies.
- `BootstrapSpec::Core` no longer keeps a single-use `$@`-preservation wrapper either; its meaningful local seams are still `_linkedre_or(...)` and `_linkedre_ored_re(...)`, and both now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `PluginBridge` no longer keeps a local `$@`-preservation wrapper either; its meaningful compatibility seams are still `_exec_legacy_plugin(...)`, `_get_legacy_plugin(...)`, `_lookup_plugin_name(...)`, and `_dispatch_plugin_name(...)`, and those now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `PluginBridge` no longer keeps a second top-level dependency-validator wrapper either; its meaningful compatibility seams are still `_lookup_plugin_name(...)` and `_dispatch_plugin_name(...)`, and those helpers now validate the required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `Compiler` no longer keeps a local `$@`-preservation wrapper either; its meaningful local seams are still `_dump_value(...)`, `_ored_re(...)`, `_trace_log_output(...)`, `_trace_log_dump(...)`, `_trace_should_dump(...)`, `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`, `_trace_apply_trace_options(...)`, and `_trace_level_name_for_current_verbosity(...)`, and those now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `SpecEntry` no longer keeps a local `$@`-preservation wrapper either; its meaningful local seams are still `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`, `_trace_log_dump(...)`, `_trace_should_dump(...)`, `_dump_value(...)`, and `_trace_runtime_mark_event(...)`, and those now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `RuleIR` no longer keeps a local `$@`-preservation wrapper either; its meaningful local seams are still `_trace_should_dump(...)`, `_trace_log_output(...)`, `_trace_decision(...)`, and `_dump_value(...)`, and those now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `RuleIR::EmitContext` no longer keeps a local `$@`-preservation wrapper either; its meaningful local seams are still `_actionir_owner_default_deps(...)`, `_call_actionir_owner(...)`, `_call_actionir_owner_with_deps(...)`, `_accumulate_action_rewrite_diagnostics(...)`, and `rewrite_action_code_for_compat(...)`, and those now spend `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through a second local `_call_preserving_err(...)` layer.
- `ActionIR::Contracts` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seam is still `_require_lowering_deps(...)`, and that helper now validates required lowering callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::ScannerCore` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seam is still `_scanner_rule_dep_bindings(...)`, and that helper now validates required scanner callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::StatementSplit` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seam is still `_split_action_ir_statements(...)`, and that helper now validates the required `trim_action_ir_value` callback inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::StatementSplit` no longer keeps a single-use `StatementSplit::Core` loader wrapper either; `_split_action_ir_statements(...)` now lazy-loads the core owner directly through `OwnerDispatch::require_pkg(...)` inside its live `$@`-preserving delegation body.
- `ActionIR::CanonicalEvents` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seam is still `_build_canonical_action_ir_events(...)`, and that helper now validates the required trim/split callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::CanonicalEvents` no longer keeps a single-use `CanonicalEvents::Core` loader wrapper either; `_canonicalize_helper_action_ir_event(...)` now lazy-loads the core owner directly through `OwnerDispatch::require_pkg(...)` inside its live `$@`-preserving delegation body.
- `ActionIR::Diagnostics` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still `_find_unresolved_action_helpers(...)` and `_collect_action_helper_ir_nodes(...)`, and those helpers now validate the required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::RewritePipeline` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still `_build_action_rewrite_rules(...)` and `_rewrite_action_code_with_diagnostics(...)`, and those helpers now validate the required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `ActionIR::ArrayPipeline` no longer keeps a second top-level dependency-validator wrapper either; its meaningful local seams are still `_normalize_split_delimiter_expr(...)` and `_build_array_pipeline_plan_from_expr(...)`, and those helpers now validate the required callbacks inline instead of bouncing through a separate `_require_dep(...)` subdef.
- `BootstrapSpec::Core`, `ActionIR::ScannerCore`, and `LinkedSpec::PluginBridge` no longer keep single-use generic package-loader wrappers either; their remaining LinkedRE, scanner-rule-family, and legacy-`PPlugin` helper seams now spend `OwnerDispatch::require_pkg(...)` directly instead of bouncing through local `_require_pkg(...)` pass-throughs.
- `LinkedSpec.pm` and `LinkedSpec::ParserFactory` no longer keep dead local pass-throughs around that seam; once the active facade/parser-factory paths spent `OwnerDispatch` directly, the shadow `_require_pkg(...)`, `_call_preserving_err(...)`, `_require_pkg_cb(...)`, and `_require_pkg_value(...)` wrappers became removable compatibility debris rather than real architecture.
- The dep-map-only ActionIR owners no longer keep dead local `_require_pkg(...)` or `_call_preserving_err(...)` wrappers around that seam either; once `default_deps_for_package(...)` moved to `OwnerDispatch::build_dep_map(...)`, those local pass-through bodies stopped being part of the real lowering path.
- `Runtime`, `BootstrapSpec`, and `ActionIR::Scanner` no longer keep dead local package-loader wrappers either, and `RuleIR::EmitContext` no longer keeps a dead local Trace-loader wrapper; the active runtime/bootstrap/scanner/emit-context paths now make their remaining callback-loader and owner-registry seams explicit instead of keeping zero-call helper shadows around them.
- `Trace`, `Validation`, `ActionIR::CanonicalEvents`, and `ActionIR::StatementSplit` now also spend `OwnerDispatch` directly inside their live helper bodies instead of keeping one-shot local wrappers for a single Data::Dumper/Trace/core-owner load or `$@`-preservation call.
- Delegated owner calls now resolve their target callbacks through the same `OwnerDispatch::require_pkg_cb(...)` loader path used by dependency maps and thin wrappers, so `dispatch_owner_call(...)` no longer carries a second symbol-call route internally.
- Thin wrapper callback lookup now routes through that seam for `Runtime`, `Compiler`, `BootstrapSpec`, `SpecEntry`, `ActionIR::Scanner`, and `RuleIR::EmitContext`'s ActionIR owner dispatch; direct callback probing is reserved for `OwnerDispatch` itself.
- `LinkedSpec::OwnerDispatch` now also owns shared dependency-map assembly for active ActionIR owners and a mixed callback/value bundle builder for the parser-factory path, so owner-side dependency wiring is centralizing instead of drifting back into local registries.
- `LinkedSpec::PluginBridge` now also spends that same owner-dispatch seam for its default compatibility plumbing: lazy `PPlugin` loading, registered-plugin lookup through `PluginRegistry`, successful `$@` preservation, and default callback-map assembly no longer require bridge-local eval/restore branches or a hand-built dependency hash.
- `Table::GenericFilter` now owns the `group_by`, `group_by_port`, `group_by_ioclock`, and `group_byRE` actions that used to live entirely in `plugin/genericfilter.plg`, so `HUtils::GenericFilter(...)` and `TableSort::GenericFilter(...)` no longer build `genericfilter_*` names and bounce through `LinkedSpec::run_plugin(...)` / `get_plugin(...)`; the pure `plugin/genericfilter.plg` wrapper and short-lived `Plugin::GenericFilter` scaffold are now removed too.
- `RTLUtils` now also owns the former `get_log2` address-width helper from `plugin/generic_fake_memory_module.plg` as `ceil_log2(...)`, plus VHDL header/context-clause generation as `add_header_n_context_clause(...)`; repo-owned RTL/FSM generation calls those RTL-domain owners directly instead of sharing those utilities through plugin dispatch.
- `FSMGen` now owns its own dynamic plugin-list parser as `getop_plugin_list(...)`; the obsolete `plugin/fsmgen.plg::getop_plugin_list` helper wrapper is gone, and the owner preserves `+type=plugin#args...` parsing with `LinkedSpec::get_plugin(...)` as the default resolver plus the unresolved-name no-op fallback.
- Pure extracted helper wrappers are being deleted once no repo-owned caller needs the old plugin name: `plugin/string.plg`, `plugin/cgi.plg`, `plugin/genericfilter.plg`, `plugin/msoffice.plg`, `plugin/vhdconst_eval.plg`, and `plugin/yesno.plg` are now gone while explicit package owners carry the behavior directly. `Plugin::*` was useful migration scaffolding for legacy plugin extractions, but it is not the permanent home for behavior that has a clearer non-plugin/domain owner; the former prompt helper has graduated to `InteractivePrompt`, VHDL constants to `VHDL::ConstantEval`, Excel automation to `MSOffice::Excel`, and HTTP file access to `HTTP::FileAccess`.
- `HTTP::FileAccess` carries the former HTTP plugin boundary beyond helper subdefs now: repo-owned `.plg` actions call it directly for `url_for_path`, `set_hostport`, and `set_localhost`, while the former `plugin/http.plg` file-link action lives in `HTTP::FileAccess::print_file_links_for_conf(...)`, the former `plugin/lighttpd.plg` action lives in `HTTP::FileAccess::run_lighttpd_for_conf(...)`, and the former `plugin/httpd.plg` action lives in `HTTP::FileAccess::run_httpd_for_conf(...)`; those legacy wrapper files are gone.
- `QC::Summary` now owns the former internal `qc_summary_merge` helper from `plugin/qc_summary.plg` as `append_merged_rows(...)`; the visible `qc_summary` action still exists in the legacy corpus for now, but its private row-merge helper no longer goes through `LinkedSpec::get_plugin(...)` or appears as a dynamic plugin registration.
- `QC::Flow` now owns the former internal `qc_pushonce` qclog insertion helper, `qc_budget_check` / `qc_budget_check_01match_code` budget-check callbacks, `qcflow_filter_handler` filter-expression helper, `qcflow_clock_ctsinfo` clock CTS summary helper, `qcflow_links_n_qclog` qclog workbook/link writer, and `qcflow_qclogdata` qclog table preparer from `plugin/qcflow.plg` as `push_once(...)`, `budget_check(...)`, `budget_check_single_or_zero_match(...)`, `filter_handler(...)`, `clock_cts_info(...)`, `write_qclog_links(...)`, and `prepare_qclog_data(...)`; `QC::TclInterconn` owns the related Tcl/FANX helper trio as `append_interconnect_tcl(...)`, `load_fanx(...)`, and `fanx_info(...)`; the visible `glc_xcel2hm` action still exists in the legacy corpus for now, but it calls those QC package owners instead of resolving the helper names through plugin lookup.
- `Timing::SetupHold` now owns the former internal setup/hold timing helpers from `plugin/setup_hold_tmax_tmin.plg` and the deleted `plugin/tssio.plg`: `collect_dxcy(...)`, named path-delay formulas, the TSS setup/tmax delay helpers, and the visible `tssio` report/action body now live in a normal package owner. `setup_hold_tmax_tmin.plg` still calls that owner directly for its visible action, and the obsolete `tssio.plg` wrapper is gone.
- `Timing::StanBackend` now owns the former internal `stan_backend_start` setup helper and the `minmax_clockmx_cellcode` clock-matrix summary cell formatter from `plugin/stan_backend.plg`; the visible STAN backend actions still live in legacy `.plg` files for now, while `plugin/stan_backend.plg`, `plugin/skew.plg`, and `plugin/duty_cycle_degradation.plg` call the timing-domain owner directly instead of using plugin lookup or unqualified helpers.
- `Timing::StanOmap2430cBackend` now owns the former internal STAN OMAP STA-frequency callback, frequency-detail helper family, `potential_fp` / `questionable_paths` / `freqency_summary` report writers, TCK-delay DM-measures writer, no-path checker, and port-timing traversal callback from `plugin/stan_omap2430c_backend.plg`; the visible legacy actions call corrected package functions and package-owned callbacks directly while the historical LOF/data strings keep their existing spelling for file compatibility.
- A fresh 2026-04-11 bootstrap pass confirmed that the recent compiler naming cleanup is now on the active facade/compiler path: `LinkedSpec.pm` exposes `build_compiled_rule_table(...)`, `Compiler.pm` / `CompilerState.pm` speak in terms of compiled-spec / compiled dependency-regex / compiled-descriptor state, and the former bootstrap-local `spec_descr` / `gdata` vocabulary has now been renamed to rule-descriptor / dispatch-state terminology.
- The remaining legacy `ActionRewriter` compatibility surface is thinner now too: its shared `EmitContext` delegation uses the same owner-dispatch seam instead of one extra local lazy-load / `can(...)` / symbol-call implementation.
- The practical core path is:
  - `ParserFactory -> Runtime -> Compiler`
- The frontend syntax/bootstrapping truth still concentrates in:
  - `BootstrapSpec::Core`
  - `Validation`
- Rule compilation and emitted runtime behavior still concentrate in:
  - `SpecEntry`
  - `RuleIR`
  - `RuleIR::EmitContext`
- Backend-neutral action semantics now largely live in:
  - `LinkedSpec::ActionIR::*`
- `RuntimeContext` is one of the cleanest and most important boundaries in the tree.
- `Compiler.pm` now also has one explicit internal compiled-spec state model, so descriptor assembly no longer treats loose parallel compiled-rule-table / `build_dependency_regex_map` hashes as its own source of truth.
- Dynamic plugin loading is still present in the public facade, but current project direction treats it as legacy-removal territory rather than a feature family to preserve.

## LinkedSpec Facade Reading
`perl/LinkedSpec.pm` does almost no real work itself. Its main roles are:

- expose the public API,
- lazily load owner modules,
- preserve `$@` across owner dispatch through `LinkedSpec::OwnerDispatch`,
- no longer carry dead local `_require_pkg(...)` / `_call_preserving_err(...)` pass-through helpers now that the shared owner-dispatch seam is the real implementation,
- normalize flat option pairs,
- re-export trace-oriented globals from `LinkedSpec::Trace`.

Its direct static imports are intentionally narrow:
- `File::Basename` at `BEGIN` time for local path setup,
- `LinkedSpec::OwnerDispatch` for shared lazy owner dispatch.

That means the important import tree is the runtime owner tree, not the `use` list in `LinkedSpec.pm` itself.

The facade surface currently falls into four bands.

### Trace Surface
- `configure_trace`
- `trace_enter`
- `trace_exit`
- `trace_decision`
- `log_output`
- `log_dump`
- `should_dump`

### Compile/Runtime Surface
- `Get`
- `build_compiled_rule_table`
- `call_spec_handler_subst`
- `get_parser`

### Registry Maintenance Surface
- `register_plugin`
- `register_plugins`
- `clear_registered_plugins`

### Legacy Transition Surface
- `run_plugin`
- `get_plugin`
- `dispatch_plugin_autoload_name`
- `AUTOLOAD`

The important conclusion is that `LinkedSpec.pm` should be read as a facade and routing layer, not as the place where most semantics live anymore.

One supporting detail matters now: the repeated thin-wrapper plumbing for lazy package loading, callback/value lookup, delegated owner calls, and `$@` preservation is no longer reimplemented separately in each owner. `LinkedSpec.pm`, `LinkedSpec::Trace`, `Runtime.pm`, `ParserFactory.pm`, `BootstrapSpec.pm`, `BootstrapSpec::Core`, `Compiler.pm`, `SpecEntry.pm`, `RuleIR.pm`, `RuleIR::EmitContext.pm`, `Resolver.pm`, `Validation.pm`, and `ActionRewriter.pm` now share that seam through `LinkedSpec::OwnerDispatch`, and the same seam is now also being spent inside active ActionIR owners such as `LinkedSpec::ActionIR::RewritePipeline`, `LinkedSpec::ActionIR::Scanner`, `LinkedSpec::ActionIR::ScannerCore`, `LinkedSpec::ActionIR::StatementSplit`, `LinkedSpec::ActionIR::StatementSplit::Core`, `LinkedSpec::ActionIR::CanonicalEvents`, `LinkedSpec::ActionIR::Diagnostics`, `LinkedSpec::ActionIR::ValueExpr`, `LinkedSpec::ActionIR::FlowExpr`, `LinkedSpec::ActionIR::ArrayPipeline`, `LinkedSpec::ActionIR::ControlFlow`, `LinkedSpec::ActionIR::Contracts`, `LinkedSpec::ActionIR::MethodLowering`, and `LinkedSpec::ActionIR::DeclareMethod`.
One more concrete consequence of that shift is now visible on the parser-factory path too: `ParserFactory.pm` no longer hand-builds its mixed trace/resolve/compile callback plus trace-verbosity value bundle locally, because `LinkedSpec::OwnerDispatch` now owns a shared mixed dependency-bundle builder for that active compile-path surface.

## Current Owner Tree
The current practical owner tree is:

```text
LinkedSpec
├─ LinkedSpec::OwnerDispatch
├─ LinkedSpec::Trace
├─ LinkedSpec::Runtime
│  ├─ LinkedSpec::RuntimeContext
│  └─ LinkedSpec::Compiler
│     ├─ LinkedSpec::Trace
│     ├─ LinkedRE
│     ├─ LinkedSpec::BootstrapSpec
│     │  └─ LinkedSpec::BootstrapSpec::Core
│     │     └─ LinkedRE
│     ├─ LinkedSpec::SpecEntry
│     │  ├─ LinkedSpec::RuleIR
│     │  ├─ LinkedSpec::RuleIR::EmitContext
│     │  │  ├─ LinkedSpec::ActionIR::RewritePipeline
│     │  │  ├─ LinkedSpec::ActionIR::MethodExpr
│     │  │  ├─ LinkedSpec::ActionIR::Scanner
│     │  │  │  └─ LinkedSpec::ActionIR::ScannerCore
│     │  │  │     ├─ Scanner::PrimitiveBasicRules
│     │  │  │     ├─ Scanner::PrimitivePipelineRules
│     │  │  │     ├─ Scanner::FlowRules
│     │  │  │     └─ Scanner::LegacyRules
│     │  │  ├─ LinkedSpec::ActionIR::CanonicalEvents
│     │  │  │  └─ CanonicalEvents::Core
│     │  │  ├─ LinkedSpec::ActionIR::Diagnostics
│     │  │  ├─ LinkedSpec::ActionIR::StatementSplit
│     │  │  │  └─ StatementSplit::Core
│     │  │  │     └─ StatementSplit::Mode
│     │  │  ├─ LinkedSpec::ActionIR::Contracts
│     │  │  ├─ LinkedSpec::ActionIR::FlowExpr
│     │  │  ├─ LinkedSpec::ActionIR::ArrayPipeline
│     │  │  ├─ LinkedSpec::ActionIR::ControlFlow
│     │  │  ├─ LinkedSpec::ActionIR::MethodLowering
│     │  │  ├─ LinkedSpec::ActionIR::DeclareMethod
│     │  │  ├─ LinkedSpec::ActionIR::ValueExpr
│     │  │  └─ LinkedSpec::Trace
│     │  ├─ LinkedSpec::Trace
│     │  └─ LinkedSpec::RuntimeContext
│     ├─ LinkedSpec::Validation
│     ├─ LinkedSpec::CompilerState
│     └─ LinkedSpec::RuntimeContext
├─ LinkedSpec::ParserFactory
│  ├─ LinkedSpec::RuntimeContext
│  ├─ LinkedSpec::Trace
│  ├─ LinkedSpec::Resolver
│  └─ LinkedSpec::Runtime
├─ LinkedSpec::PluginRegistry
└─ LinkedSpec::PluginBridge
   ├─ LinkedSpec::PluginRegistry
   └─ PPlugin
      └─ LinkedSpec
Project/domain utility owners
├─ HTTP::FileAccess
├─ HTML::PathLinks
├─ InteractivePrompt
├─ Text::VariableSubstitution
├─ VHDL::ConstantEval
├─ MSOffice::Excel
├─ QC::Flow
├─ QC::Summary
├─ QC::TclInterconn
├─ RTLUtils
├─ Timing::SetupHold
├─ Timing::StanBackend
├─ Timing::StanOmap2430cBackend
└─ Table::GenericFilter
```

## What the Main Owners Do
### `LinkedSpec::Trace`
- owns trace state, indentation, formatting, verbosity, and output routing,
- lazily uses `Data::Dumper` only when needed,
- now also owns richer trace rendering such as mark-position pointer excerpts.

### `LinkedSpec::Runtime`
- owns the small orchestration layer around the compile pipeline,
- builds or normalizes runtime context,
- delegates into `Compiler`,
- writes fallback runtime-owner errors only when deeper owners did not already write a structured failure.

### `LinkedSpec::RuntimeContext`
- owns shared runtime state and structured error payload helpers,
- owns parser-source chunk capture and capture-reset helpers,
- normalizes `runtime_ctx_ref` for direct hashrefs plus scalar slots, including reuse after a scalar slot already contains the shared context hashref,
- carries `spec_name`, `spec_path`, `top_rule`, and `last_error`,
- now clears stale `last_error` during `run_get(...)`, `get_parser(...)`, and low-level rule-table preparation so reused contexts begin each boundary with a failure-only diagnostics channel,
- now also keeps `last_error` more self-contained by copying the known `top_rule` into the structured payload alongside `spec_name` and `spec_path`,
- now also owns top-rule generated-handler source-label construction for runtime/parser-factory/compiler diagnostics, including parser-invocation labels that know the selected handler variant,
- now also owns compiler-style rule-or-top generated-handler source-label fallback, where a concrete rule label wins and selected `top_rule` is the fallback,
- now also owns rule-metadata generated-handler source-label construction for `SpecEntry`, including selected handler variants stored in compiled rule metadata,
- now also seeds an explicitly requested `top_rule` during both inline and file-oriented preparation, so earlier parser-factory/compiler failures can still report the caller’s intended entrypoint before final parser selection happens,
- now also owns the paired stale `spec_name` / `spec_path` reset as a distinct helper from `top_rule` selection, so file identity cleanup and selected-entrypoint continuity stay separate,
- now also owns the low-level `build_compiled_rule_table(...)` runtime-context preparation path, so compiler-side rule-table diagnostics no longer hand-normalize `runtime_ctx_ref` or hand-clear stale context identity/parser-source capture state in `Compiler.pm`,
- is now reached through one shared `OwnerDispatch::dispatch_owner_call(...)` delegation shape across the active runtime/compile owners instead of one dispatch style in `ParserFactory.pm` and another in `Runtime.pm` / `Compiler.pm` / `SpecEntry.pm`,
- is one of the cleanest and highest-value seams in the project.

### `LinkedSpec::ParserFactory`
- owns `get_parser(...)`,
- validates the requested spec name,
- resolves the target `.spec`,
- loads file content,
- prepares trace/runtime context,
- now assembles its default trace/resolve/compile callback dependencies plus trace dump-level values through one shared `OwnerDispatch` bundle helper instead of another owner-local registry,
- no longer keeps dead local `_require_pkg(...)`, `_require_pkg_cb(...)`, or `_require_pkg_value(...)` pass-through wrappers around that now-shared dependency/owner-dispatch path,
- delegates actual compilation to the runtime/compiler path.

### `LinkedSpec::Resolver`
- is the real owner of named spec lookup,
- resolves direct paths first,
- tries module-relative spec paths next,
- falls back to `PathSearch` last.

This module, not the plugin branch, is the real home of the "ask for `foo`, get `foo.spec`" behavior.

### `LinkedSpec::Compiler`
- is the main compile pipeline coordinator,
- owns validation/bootstrap/descriptor-build orchestration,
- now treats `_require_runtime_ctx(...)` and `run_get_pipeline(...)` as its direct runtime/pipeline dependency-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them,
- now coordinates one explicit internal compiled-state model first and treats that as the source of truth for later descriptor assembly,
- now emits the outward descriptor `{ spec => ..., dependency_regex_map => ... }` at the outer boundary, but that is now a projection of the compiled-spec state rather than the compiler's own working model,
- carries much of the compile-stage structured-diagnostics normalization,
- is one of the project's main implementation centers.

One concrete architectural consequence matters now:

- `build_compiled_rule_table(...)` is now the active low-level seam and still exposes the historical rule-label => info hash by default,
- but internally it first builds a `compiled_spec_state` record with:
  - `definition_order`
  - `compiled_rule_order`
  - `rules_by_label`
  - `redefined_rule_labels`
- default `build_dependency_regex_map(...)` now consumes that state directly and, on the active path, first builds an explicit internal `compiled_dependency_regex_state` record,
- final descriptor assembly now first builds an explicit internal `compiled_descriptor_state` record that composes compiled-spec state plus dependency-regex state, generated-descriptor validation now consumes that state directly, and only then does the compiler project outward `spec` / `dependency_regex_map` hashes while also exposing state-derived metadata such as `meta.descriptor_model`, `meta.definition_order`, `meta.compiled_rule_order`, and `meta.redefined_rule_labels`,
- generated-descriptor validation now also walks that descriptor state directly instead of routing back through the historical legacy `validate_dependency_regex_references(...)` entrypoint, so compatibility descriptor projection is fully deferred until after descriptor-state validation succeeds,
- and descriptor-level migration summary generation now also consumes compiled-spec state directly, so even that metadata no longer needs to bounce back through a legacy spec-hash working model.

That is a real structural improvement, not only a diagnostics tweak:

- the compiler now has one explicit internal state-model owner behind its descriptor model,
- derived dependency regexes now also have one explicit internal state model,
- final descriptor assembly now also has one explicit internal descriptor-state model,
- generated-descriptor validation now also consumes that same descriptor-state model directly on the active path,
- the last legacy compatibility-shape normalization seams for compiled spec and compiled dependency-regex maps now also route through that same owner instead of living as local compiler glue,
- and read-side compiled-state access for definition-order, duplicate-label, and descriptor-to-rule-map reads now also routes through that same owner instead of peeking raw state fields directly,
- while ordered compiled-rule iteration now also comes from one owner-provided `rule_rows` view instead of being rebuilt ad hoc from `compiled_rule_order + rules_by_label` in compiler consumers,
- and compiled-spec dependency existence / rule-info lookup now also routes through that same owner instead of direct compiler-side map probing during `build_dependency_regex_map(...)`,
- while compiled-descriptor metadata assembly now also routes through that same owner instead of `Compiler.pm` mutating owner metadata locally,
- and descriptor migration-summary shaping now also routes through that same owner instead of being computed as a large compiler-local reduction over compiled rules,
- ordering is first-class instead of incidental,
- duplicate-label tracking is first-class instead of ad hoc,
- and `build_dependency_regex_map(...)` is now clearly a derived-enrichment phase over compiled-spec state rather than a peer loose hash the compiler happens to juggle beside `spec`, while the outward descriptor now calls that derived payload `dependency_regex_map`.

### `LinkedSpec::CompilerState`
- owns the internal compiled-spec, dependency-regex, and compiled-descriptor state records,
- owns normalization of legacy compatibility hashes into those explicit state records,
- owns the preferred read-side accessors for that state as well,
- owns the preferred ordered-rule iteration view for compiled-spec state as well,
- owns the preferred by-label compiled-rule lookup helpers as well,
- owns compiled-descriptor metadata assembly over compiled-spec state as well,
- owns migration-summary shaping over compiled-spec state as well,
- owns the preferred descriptor-state validation views as well,
- owns validation-friendly shape checks for those records,
- owns projection back to outward `spec` / `dependency_regex_map` hashes,
- is now the one place where the compiler's state model is defined instead of splitting that logic between `Compiler.pm` and `Validation.pm`,
- which means `Compiler.pm` and `Validation.pm` no longer need to carry raw-state field reads, local ordered-rule reconstruction, direct rule-map probing, migration-summary reduction, descriptor-meta mutation, repeated descriptor-validation owner dispatch inside validation loops, descriptor-validation map flattening, or leftover local “accept legacy hash or compiled-state record” conversion seams beside the state owner.

One more boundary is now tighter too:

- malformed compiled dependency-regex-map callback output is rejected directly at final descriptor assembly,
- instead of being allowed to drift into later generated-descriptor validation before the contract problem is identified.

### `LinkedSpec::BootstrapSpec` and `LinkedSpec::BootstrapSpec::Core`
- own the hardcoded bootstrap grammar,
- parse `.spec` syntax before self-hosting is fully realized,
- also carry bootstrap-side parsing/rendering intelligence for method-chain and attached control-flow syntax normalization,
- remain a major syntax and safety hotspot,
- now use explicit `rule_descriptors` and `dispatch_state` naming for bootstrap parser handler plumbing. The old `spec_descr` / `gdata` words should be read as history/compatibility context, not active compiler descriptor/dependency-regex terminology.

### `LinkedSpec::Validation`
- owns frontend hardening before bootstrap or runtime failure,
- checks malformed rule starts, modes, split markers, edges, and top-level paragraph structure,
- now also uses one shared dependency-regex validation engine across both legacy hash inputs and owner-provided descriptor-state validation views,
- remains strategically important because it is the earliest trustworthy barrier against bad DSL input.

### `LinkedSpec::SpecEntry`
- compiles parsed rule entries into generated runtime handler code,
- still assembles Perl source strings and `eval`s them,
- remains the clearest backend-portability ceiling in the current implementation.

### `LinkedSpec::RuleIR`
- owns rule-level intermediate structure and metadata planning,
- drives handler-variant selection and rule execution metadata.

### `LinkedSpec::RuleIR::EmitContext`
- is the bridge from rule IR into ActionIR scanning and lowering,
- is the main gateway into backend-neutral action rewriting,
- now also centralizes its internal ActionIR owner package registry and owner default-dependency lookup instead of hardwiring those contracts separately across dozens of local wrappers,
- and now treats that owner-key registry plus shared owner dispatcher as the only package/callback-loading seams on the bridge instead of keeping a second layer of owner-specific `_require_*_pkg(...)` shims.

## ActionIR Reading
The ActionIR subtree is now large, but structurally it is much healthier than the older monolithic style.

Current reading:

- `MethodExpr`
  - parses method-like expressions.
- `Scanner` and `ScannerCore`
  - find helper-like and compatibility-like surfaces.
- scanner rule families are split deliberately:
  - `PrimitiveBasicRules`
  - `PrimitivePipelineRules`
  - `FlowRules`
  - `LegacyRules`
- `CanonicalEvents`
  - turns scanned helper hits into canonical event forms.
  - its thin owner wrapper now also uses `LinkedSpec::OwnerDispatch` for lazy loading, callback lookup, and `$@` preservation.
  - now lazy-loads `CanonicalEvents::Core` directly through `LinkedSpec::OwnerDispatch::require_pkg(...)` inside `_canonicalize_helper_action_ir_event(...)` instead of keeping a second single-use core-loader wrapper.
- `Diagnostics`
  - tracks unresolved helpers, readiness, and compatibility-surface telemetry.
  - its thin owner wrapper now also uses `LinkedSpec::OwnerDispatch` for lazy loading, callback lookup, and `$@` preservation.
- `Diagnostics`, `StatementSplit`, `CanonicalEvents`, `ArrayPipeline`, `ControlFlow`, `Contracts`, `RewritePipeline`, and `Scanner`
  - now also assemble their default callback maps through the shared `OwnerDispatch::build_dep_map(...)` seam instead of hand-building those maps inline.
  - dep-map-only owners no longer keep local `_require_pkg_cb(...)` wrapper bodies around that shared seam; `Scanner` still has one because it directly resolves `ScannerCore`.
- `StatementSplit`
  - owns safe statement splitting.
  - now lazy-loads `StatementSplit::Core` directly through `LinkedSpec::OwnerDispatch::require_pkg(...)` inside `_split_action_ir_statements(...)` instead of keeping a second single-use core-loader wrapper.
- `StatementSplit::Core`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy package loading of statement-split helper packages.
- `ScannerCore`
  - now lazy-loads scanner-rule families directly through `LinkedSpec::OwnerDispatch` inside the shared family-registry loop instead of through a single-use local generic package-loader wrapper.
  - now also centralizes the scanner-rule family registry, and the remaining helper rebinding symbols are derived straight from `_scanner_dep_specs()` instead of living in a second hardwired registry.
  - now also centralizes the scanner dependency contract consumed by `Scanner::default_deps_for_package(...)`, so dependency assembly and dependency rebinding both spend that same dep-spec table instead of drifting in parallel.
- `Contracts`
  - is the contract catalog for supported helper surfaces and how they lower.
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
- `FlowExpr`, `ArrayPipeline`, `ControlFlow`, `MethodLowering`, `DeclareMethod`, and `ValueExpr`
  - make up the main lowering families.
- core lowering owners such as `FlowExpr`, `ValueExpr`, `MethodLowering`, and `DeclareMethod` now also assemble their default callback maps through one shared `OwnerDispatch::build_dep_map(...)` helper instead of hand-building those callback registries inline.
  - those dep-map-only lowering owners no longer keep dead local `_require_pkg(...)`, `_call_preserving_err(...)`, or `_require_pkg_cb(...)` wrappers once `build_dep_map(...)` owns dependency callback resolution.
- `FlowExpr`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
  - now also treats `_looks_like_array_value_expr(...)`, `_looks_like_hash_value_expr(...)`, `_lower_is_empty_expr(...)`, `_lower_defined_target_expr(...)`, and `_lower_flow_composite_expr(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them.
- `ArrayPipeline`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
- `ControlFlow`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
  - now also treats `_lower_control_flow_value_expr(...)`, `_lower_switch_case_value_expr(...)`, `_normalize_bare_zero_arg_flow_marker_expr(...)`, `_lower_if_flow_statement(...)`, `_lower_elseif_flow_statement(...)`, `_lower_else_flow_statement(...)`, `_lower_endif_flow_statement(...)`, `_expand_flow_branch_action_exprs(...)`, `_parse_method_expr_with_optional_attached_block(...)`, `_lower_flow_branch_single_statement(...)`, `_lower_inline_if_branch_expr(...)`, `_lower_inline_switch_branch_expr(...)`, `_lower_switch_flow_statement(...)`, `_lower_case_flow_statement(...)`, `_lower_default_flow_statement(...)`, `_lower_endcase_flow_statement(...)`, `_lower_endswitch_flow_statement(...)`, `_lower_say_statement(...)`, `_lower_print_statement(...)`, and `_lower_print_each_statement(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them.
- `MethodLowering`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
  - now also treats `_lower_typed_declare_statement(...)`, `_normalize_method_tag_expr(...)`, `_lower_method_value_expr(...)`, `_lower_return_payload_expr(...)`, `_lower_return_general_statement(...)`, `_lower_assign_statement(...)`, `_lower_push_value_statement(...)`, `_lower_push_nonempty_statement(...)`, `_lower_regex_subst_statement(...)`, and `_lower_return_undef_statement(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them.
- `DeclareMethod`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
  - now also treats `_parse_declare_binding_entry(...)`, `_lower_declare_value_expr(...)`, `_lower_declare_initializer_expr(...)`, `_extract_declare_statement_from_method_expr(...)`, `_lower_declare_method_statement(...)`, and `_lower_assign_method_statement(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them.
- `ValueExpr`
  - now also uses `LinkedSpec::OwnerDispatch` in its thin owner wrapper for lazy loading, callback lookup, and `$@` preservation.
  - now also treats `_extract_scalar_symbol_name(...)`, `_extract_array_symbol_name(...)`, `_extract_hash_symbol_name(...)`, `_lower_scalar_access_key_expr(...)`, `_split_scalaref_path_segments(...)`, `_lower_scalaref_segment_expr(...)`, `_infer_scalar_container_kind(...)`, `_lower_assignment_source_expr(...)`, and `_strip_literal_delimiters(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them.
- `RewritePipeline`
  - glues the scan, classify, and lower pipeline together.

The important judgment here is:
- the language-neutral `.spec` story does not live in `LinkedSpec.pm`,
- it lives mostly in `RuleIR::EmitContext` and the `ActionIR::*` subtree.

## Legacy Plugin Branch Reading
The current public facade still exposes a plugin/runtime branch, but the architecture direction has shifted.

### `LinkedSpec::PluginRegistry`
- owns the clean explicit in-memory registry surface.

### `LinkedSpec::PluginBridge`
- is the transition bridge,
- checks explicit registration first,
- falls back to legacy behavior only when needed,
- assembles its default dependency callback map through `LinkedSpec::OwnerDispatch::build_dep_map(...)`,
- routes its default registered-plugin lookup and legacy runtime load through `LinkedSpec::OwnerDispatch`,
- spends that legacy runtime load directly inside `_load_legacy_plugin_runtime(...)` instead of through a single-use local generic package-loader wrapper,
- and does not own discovery itself; it is a registry-first dispatch shim over the older `.plg` runtime.

### `PPlugin`
- owns legacy `.plg` discovery,
- reads legacy `.plg` files through explicit file IO rather than global diamond-reader state,
- parses `.plg` files through the `pplugin` parser,
- caches discovered handlers,
- executes them dynamically,
- lazy-loads its default `pplugin` parser callback through `LinkedSpec::OwnerDispatch` rather than a local `require LinkedSpec` branch,
- now also treats `_load_legacy_registry(...)` as its direct parser/discovery/registry dependency-validation seam instead of keeping a second top-level `_require_dep(...)` wrapper above it,
- is now treated as an internal compatibility adapter by repo-owned `.plg` code too: shipped `.plg` paths that still need callback resolution should go through `LinkedSpec::get_plugin(...)` instead of reaching into `PPlugin->get(...)` directly, while `FSMGen` has already moved its dynamic plugin-list parsing into a package owner with that resolver as the default,
- and still closes the remaining lazy compatibility cycle:
  - `LinkedSpec -> PluginBridge -> PPlugin -> LinkedSpec::get_parser('pplugin')`

Current project direction does not treat that branch as a target architecture.

### `Table::GenericFilter`
- owns package-backed table grouping actions formerly embedded in `plugin/genericfilter.plg`,
- exposes an explicit `dispatch($action, ...)` boundary for `HUtils::GenericFilter(...)` and `TableSort::GenericFilter(...)`,
- keeps the recursive `group_by_port` / `group_by_ioclock` behavior on the existing HUtils grouping path without routing through stringly plugin lookup,
- and no longer keeps `plugin/genericfilter.plg` as a thin legacy registration wrapper now that no repo-owned caller still needs those `genericfilter_*` plugin names.

Pure helper extractions may land temporarily in a `Plugin::*` package when no clearer owner has been chosen yet, but that destination is tactical rather than sacred. When a clearer domain owner exists, the behavior should graduate out of `Plugin::*` too; `HTTP::FileAccess` now owns the signed file-access URLs plus local HTTP daemon actions that briefly lived under `Plugin::HTTP`, `HTML::PathLinks` now owns the path-token HTML link rendering that briefly lived under `Plugin::CGI`, `Text::VariableSubstitution` now owns the string substitution helpers that briefly lived under `Plugin::String`, `Table::GenericFilter` now owns the table grouping helpers that briefly lived under `Plugin::GenericFilter`, `VHDL::ConstantEval` now owns the VHDL constant helpers that briefly lived under `Plugin::VHDLConst`, `MSOffice::Excel` now owns the Excel helper that briefly lived under `Plugin::MSOffice`, `QC::Flow`, `QC::Summary`, plus `QC::TclInterconn` now own QC helper clusters that moved straight out of mixed `.plg` implementation detail, `RTLUtils` now owns RTL address-width sizing plus VHDL header/context-clause generation that moved out of plugin-dispatched helper detail, `FSMGen` now owns its dynamic plugin-list parsing instead of keeping that parser in `plugin/fsmgen.plg`, and `Timing::SetupHold`, `Timing::StanBackend`, plus `Timing::StanOmap2430cBackend` now own timing helpers that moved straight out of mixed `.plg` implementation detail.

`RTLUtils` now carries small RTL-generation helpers that used to be shared through plugin dispatch. `plugin/generic_fake_memory_module.plg` still exposes its visible fake-memory generation action, and `plugin/wrapgen.plg` still exposes wrapper-generation actions, but the address-width `get_log2` helper is no longer a dynamic plugin subdef. Both callers now use `RTLUtils::ceil_log2(...)` directly for memory address bus sizing. VHDL header/context-clause generation now also lives in `RTLUtils::add_header_n_context_clause(...)`; `RTLUtils` and `FSMGen.pm` package code call it directly, and the obsolete `plugin/fsmgen.plg::add_header_n_context_clause` helper wrapper is gone.

`FSMGen` now also owns the dynamic plugin-list parser that used to live in `plugin/fsmgen.plg::getop_plugin_list`. The obsolete `.plg` helper wrapper is gone; `FSMGen::getop_plugin_list(...)` preserves the historical `+type=plugin#args...` bucket shape, uses `LinkedSpec::get_plugin(...)` as the default resolver, and keeps the unresolved-name no-op fallback.

`HTTP::FileAccess` shows the same destination applied to formerly real legacy actions, not just thin helper wrappers. The package owns `url_for_path`, `set_hostport`, `set_localhost`, the former `http` file-link action through `print_file_links_for_conf(...)`, the former `lighttpd` action through `run_lighttpd_for_conf(...)`, and the former `httpd` action through `run_httpd_for_conf(...)`; `plugin/http.plg`, `plugin/lighttpd.plg`, and `plugin/httpd.plg` have been removed. Repo-owned `.plg` callers that need HTTP file-access helpers call `HTTP::FileAccess` explicitly.

`QC::Summary` shows the same cleanup inside a mixed legacy file. `plugin/qc_summary.plg` still carries the visible `qc_summary` action, but the private row-merging subdefinition is no longer registered as `qc_summary_merge` and no longer requires a plugin lookup just to reuse local implementation detail. The package owner now exposes `append_merged_rows(...)`, and the `.plg` action calls that directly.

`QC::Flow` applies that cleanup to the larger `plugin/qcflow.plg` file one helper cluster at a time. The visible `glc_xcel2hm` action still carries the main QC flow, but the private duplicate-suppressed qclog insertion helper, budget-check recursion callbacks, filter-expression formatter, clock CTS summary helper, qclog workbook/link writer, and qclog table preparer are no longer registered as `qc_pushonce`, `qc_budget_check`, `qc_budget_check_01match_code`, `qcflow_filter_handler`, `qcflow_clock_ctsinfo`, `qcflow_links_n_qclog`, or `qcflow_qclogdata`. The package owner exposes `push_once(...)`, `budget_check(...)`, `budget_check_single_or_zero_match(...)`, `filter_handler(...)`, `clock_cts_info(...)`, `write_qclog_links(...)`, and `prepare_qclog_data(...)`; `glc_xcel2hm` passes those coderefs or direct package calls through the existing flow.

`QC::TclInterconn` now owns the Tcl/FANX side of that same QC flow. `plugin/qcflow.plg` no longer resolves `tcl4interconn`, `tcl4fanx`, or `get_fanxinfo` through `LinkedSpec::get_plugin(...)`; it calls `QC::TclInterconn::append_interconnect_tcl(...)`, `load_fanx(...)`, and `fanx_info(...)` directly. The old standalone `plugin/tcl4interconn.plg` wrapper is gone now that no repo-owned caller still needs those legacy plugin names.

`Timing::SetupHold` extends that cleanup to a small helper family that used to span two legacy action files. `plugin/setup_hold_tmax_tmin.plg` still exposes `setup_hold_tmax_tmin`, but the obsolete `plugin/tssio.plg` wrapper has been removed now that `write_tssio(...)` carries the visible `tssio` report/action body directly. The private timing formulas and DxCy traversal helper are no longer registered as `DxCy`, `DiCi`, `DiCo`, `DoCi`, `DoCo`, `tss_setup_hold`, or `tss_tmax_tmin` plugin subdefs, and the package owner carries those formulas, the named dispatcher, and `write_tssio(...)` directly. That keeps timing math explicit and avoids a same-file plugin lookup just to call implementation detail.

`Timing::StanBackend` applies the same cleanup to STAN/report-timing backend setup and clock-matrix formatting. `plugin/stan_backend.plg` still exposes visible actions such as `clockmatrix`, `filterout`, `eponsout`, `defaultout`, `treeout`, and `interface`, but its private `stan_backend_start` helper is no longer a dynamic plugin subdef, and the `clockmatrix` action no longer calls the same-file `minmax_clockmx_cellcode` helper. The package owner now preserves the launch banner, HTTP host/port setup, `stan_backend_table2ss` configuration load, per-cell first-100 path-sheet allocation, and min/max summary link formatting directly; repo-owned callers such as `plugin/skew.plg` plus `plugin/duty_cycle_degradation.plg` call `Timing::StanBackend::start(...)` without plugin lookup.

`Timing::StanOmap2430cBackend` continues that cleanup in `plugin/stan_omap2430c_backend.plg`. The visible `old_default` and `dm_measures` actions still live in the legacy action file, and the visible `potential_fp`, `questionable_paths`, and `freqency_summary` entries now remain only as thin compatibility wrappers, but the private STA-frequency callback is no longer registered as `stafrequency`, the private frequency-detail helper family is no longer registered as `freqency_detailed`, `freqency_detailed_paths`, `drive_freqency_detailed`, or `get_freqency_detailed_fname`, the report-writer bodies no longer live in `.plg`, the TCK-delay writer is no longer registered as `drive_tckdelays`, the no-path checker is no longer registered as `drive_nopath_check` or `nopath_check`, and the port-timing traversal callback is no longer registered as `portiming`. The package owner now exposes `collect_sta_frequency(...)`, corrected frequency-detail function names, `write_potential_fp(...)`, `write_questionable_paths(...)`, `write_frequency_summary(...)`, `write_tck_delays(...)`, `write_no_path_check(...)`, `record_no_path_check(...)`, and `filter_port_timing_paths(...)` for the callable API while preserving historical LOF section strings and data keys where they are file/data compatibility contracts.

The one-line parser-lookup compatibility shim `plugin/spec.plg` has also been removed. Repo-owned parser lookup now stays on `LinkedSpec::get_parser(...)` directly instead of routing through a legacy `_get_parser` plugin action.

The generic one-line dynamic lookup shim `plugin/plugin.plg` is gone as well. Its former repo-owned caller in `plugin/fsmgen.plg` now uses `FSMGen::getop_plugin_list(...)` directly, so known dynamic lookup stays behind the package owner and explicit `LinkedSpec::get_plugin(...)` default resolver without preserving an extra legacy action name or keeping the parser body in `.plg`.

The small utility wrapper `plugin/table.plg` has also been removed. Repo-owned table-row extraction now names `Table::list2table(...)` directly, and the unused `table_2ss` action is not preserved as a legacy plugin registration without a concrete caller.

The Office automation wrapper `plugin/msoffice.plg` has also been removed. Repo-owned SpyGlass waiver extraction now names `MSOffice::Excel::start()` directly, and the package owner keeps the lazy `Win32::OLE` boundary instead of exposing an unqualified `excel_start` plugin action.

The VHDL constant helper wrapper `plugin/vhdconst_eval.plg` has also been removed. Repo-owned MBIST and register-test paths now name `VHDL::ConstantEval::evaluate_constant_values(...)` / `substitute_hash_values(...)` directly, and the old print action is preserved only as explicit package function `print_constant_values_for_conf(...)`.

The interactive yes/no prompt helper wrapper `plugin/yesno.plg` has also been removed, and its short-lived `Plugin::Prompt` scaffold has been removed too. Repo-owned FX environment comparison code now names `InteractivePrompt::yes_no(...)` directly, and that owner fixes the historical no-branch array-callback typo while preserving the empty-answer-defaults-to-yes behavior.

The current intended direction is:
- keep deterministic named `.spec` resolution,
- treat dynamic `.plg` loading and plugin execution as legacy-removal territory,
- move executable helper logic into explicit package ownership outside `LinkedSpec::*`,
- keep LinkedSpec focused on parser/spec/runtime responsibilities.

## Strongest Current Boundaries
These are the seams that currently look healthiest and most worth preserving.

### 1. Thin `LinkedSpec.pm` facade
This is good architectural movement. The public entrypoint is no longer trying to own everything itself.

### 2. `ParserFactory -> Runtime -> Compiler`
This is the practical core spine of the system and gives a readable ownership model to parser construction.

### 3. `RuntimeContext`
This is one of the best extractions in the project so far. It reduced drift and made structured diagnostics much more coherent.

### 4. Compiler-owned compiled-spec state
This is now one of the healthiest improvements in the compile path. The compiler no longer has to reason about “legacy spec hash” as its own internal truth; it has one explicit compiled-spec state model and emits legacy compatibility shapes only at the edges.

### 5. ActionIR modularization
The lowering stack is big, but it now has real sub-owners instead of one giant mixed-semantics file.

## Main Hotspots and Risks
### `BootstrapSpec::Core`
- dense syntax hotspot,
- difficult to change safely,
- still central until self-hosting is stronger,
- the former bootstrap-only `spec_descr` / `gdata` vocabulary has been renamed to `rule_descriptors` / `dispatch_state`, so the remaining risk is the density of the bootstrap syntax logic rather than a known active naming island.

### `SpecEntry`
- still relies on generated Perl source plus `eval`,
- strongest backend-portability ceiling,
- still a likely long-term refactor target.

### Public visibility of legacy plugin surface
- `run_plugin`, `get_plugin`, `dispatch_plugin_autoload_name`, and `AUTOLOAD` still sit in `LinkedSpec.pm`,
- even though the project direction now says dynamic plugin loading is not a core target to preserve.

### Remaining compatibility drag
- the broad owner-dispatch cleanup has paid off and Backbone Item 3 is much thinner now than it was,
- but the public plugin compatibility surface still over-advertises a branch the docs already treat as transition/removal machinery,
- and future effort should bias back toward semantic/runtime/self-hosting milestones unless fresh duplication is clearly material.

## Current Strategic Judgments
### 1. LinkedSpec is no longer best understood as a plugin-hosting framework
The clearer core story is:
- named `.spec` lookup,
- parser compilation,
- parser runtime,
- action lowering,
- diagnostics.

Dynamic plugin loading was historically useful, but it is not the architectural center anymore.

### 2. Spec/resource lookup and plugin loading should stay separate in our thinking
The justified behavior to preserve is:
- `get_parser('foo')` should locate `foo.spec` without path burden.

That does not imply that LinkedSpec must keep a dynamic plugin system.

### 3. Future portability still runs through `SpecEntry`
Even with a much stronger ActionIR story, runtime handler generation still bottoms out in emitted Perl and `eval`.

### 4. ActionIR maturity is now more about semantics and architecture than helper count
The helper family is much richer than it used to be. The bigger future wins are now around:
- cleaner semantics,
- lowering discipline,
- validation,
- self-hosting,
- and eventual backend decoupling.

### 5. `build_compiled_rule_table` / `build_dependency_regex_map` should now be read as phases, not as the ideal long-term data model
The information they represent is still needed. What changed is the ownership model:
- `build_compiled_rule_table(...)` is now best read as "build compiled-spec state",
- `build_dependency_regex_map(...)` is now best read as "build compiled dependency-regex state from compiled-spec state and project the outward dependency_regex_map hash when a caller wants the normal descriptor surface",
- and the legacy hash forms are compatibility outputs rather than the compiler's own preferred representation.

## Suggested Session-Start Refresh Checklist
At the start of a future session, this document should be re-read and adjusted if any of the following changed:

- the public API surface of `LinkedSpec.pm`,
- the practical compile spine,
- the role of `RuntimeContext`,
- the biggest architectural hotspots,
- the status of `SpecEntry` code generation,
- the status of bootstrap/self-hosting,
- the status of the legacy plugin-removal track,
- or the project's own understanding of what LinkedSpec should and should not own.

## Bottom Line
Current best reading:

- `LinkedSpec.pm` is a facade,
- `ParserFactory`, `Runtime`, and `Compiler` are the practical parser-build spine,
- `BootstrapSpec::Core` and `Validation` still define much of the frontend truth,
- `Compiler.pm` now has one explicit compiled-spec state model internally and only emits outward `spec` / `dependency_regex_map` hashes at descriptor boundaries,
- `SpecEntry` remains the biggest portability hotspot,
- `RuleIR` plus `ActionIR::*` are where backend-neutral action semantics really live,
- `RuntimeContext` is one of the strongest architectural boundaries in the project,
- and the legacy plugin branch should be treated as transition/removal machinery, not as the future identity of LinkedSpec.
