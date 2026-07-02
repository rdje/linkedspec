# ARCHITECTURE STATE
Live architecture snapshot for LinkedSpec.

This document is the current high-level technical reading of the project shape. It is meant to steer implementation, record important architectural judgments, and give future sessions a fast way to re-enter the codebase with the right mental model.

## Status
- Last refreshed: `2026-06-14`
- `2026-06-14` refresh: COMPAT-ALIAS-RETIREMENT-V2.2 removed 5 legacy return helpers (return_a, return_m, return_ma, return_imatch, return_im) from all 7 implementation files. LIFECYCLE-FAMILY-AUDIT tree completed — all 7 lifecycle markers verified. ROADMAP-V2-TRACKER-SYNC tree completed — trackers synchronized. DOC-BOOK-SYNC tree active for documentation/book sync.
- `2026-06-13` refresh: MEDIUM-IMPACT task tree substantially advanced. HandlerVariantEmitter now has structured HandlerIR (10 variant builders → IR hashrefs → dispatched emitter templates), a backend dispatch table (`%BACKEND_EMITTERS` with `perl` default), and a JSON/AST diagnostic backend (`_emit_handler_json` via `JSON::PP`). Validation.pm fuzzing harness (`t/phase0_validation_fuzz.t`) covers 5 surfaces with 168+ combinatorial cases across rule labels, edge scanning, and DSL syntax. BootstrapSpec.pm now has dual-path parse: `_build_spec_spec_parser()` lazily builds spec.spec parser via bootstrap seed and caches it; `run_bootstrap_parse()` runs spec.spec alongside bootstrap as a diagnostic side channel (bootstrap always primary; recursion guard active). Cross-check at 2/20 exact match (tablegrep, verilog); remaining 18 specs tracked in .3.4 parity gap. AND handler MIXED_ACTIONS conflict resolved (.3.4.4): RuleIR routes AND I-blocks to `and_icode_entries`, EmitContext processes them, HandlerVariantEmitter prepends assignment for result capture. Comment/blank-line skip in Runtime.pm wrapper. RuntimeContext reusable via populated scalar-slot contract.
- `2026-06-04` refresh: removed two stale references that still presented the deleted `perl/LinkedSpec/ActionRewriter.pm` module as a live owner-dispatch participant. That module was deleted in Phase 1 (`PHASE1-PARSER-CORE-ISOLATION.2`, commit `4f8e0b6`); the focused helper-rewrite compatibility entrypoint now lives solely in `LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat(...)`, reachable through the façade helper `LinkedSpec::call_spec_handler_subst(...)`.
- Scope of this snapshot:
  - `perl/LinkedSpec.pm`
  - the main owner modules it dispatches into
  - the ActionIR lowering subtree
  - the current legacy plugin/runtime branch
  - new: `LinkedSpec::HandlerVariantEmitter` (HandlerIR + backend dispatch + JSON/AST backend)
  - new: `t/phase0_validation_fuzz.t` (Validation.pm systematic fuzzing harness, 5 surfaces)
  - new: `tools/cross_check_spec_parsers.pl` (oracle vs candidate cross-check harness)

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
- `Compiler` no longer keeps a one-shot final-descriptor error-detail normalizer wrapper either; that trapped error detail is normalized directly at the structured last-error write.
- `Compiler` no longer keeps a one-shot parser-input ref describer wrapper either; top-level parser invocation builds invalid-input diagnostics directly at the runtime-parser last-error write.
- `Compiler` no longer keeps a one-shot bootstrap-parse result detail wrapper either; invalid intermediate-representation diagnostics are built directly at the structured last-error write.
- `Compiler` no longer keeps a one-shot rule-table failure-detail reader wrapper either; the pipeline fallback reads retained rule-table failure detail directly.
- `Compiler` no longer keeps a one-shot rule-table failure-detail clearer wrapper either; rule-table and pipeline boundaries reset retained failure detail directly.
- `Compiler` no longer keeps a one-shot rule-table failure-detail setter wrapper either; rule-table failure sites write retained failure detail directly.
- `Compiler` no longer keeps a one-shot rule-table entries-result describer wrapper either; invalid parsed-entry-list diagnostics are built directly at the rule-table boundary.
- `Compiler` no longer keeps a one-shot rule-table entry-result describer wrapper either; invalid per-entry diagnostics are built directly at the rule-table boundary.
- `Compiler` no longer keeps a one-shot compile-spec-entry tuple describer wrapper either; invalid tuple diagnostics are built directly at the rule-table boundary.
- `Compiler` no longer keeps a one-shot final-descriptor state-result describer wrapper either; invalid descriptor-state diagnostics are built directly at the final descriptor boundary.
- `Compiler` no longer keeps a one-shot final-descriptor dependency-regex describer wrapper either; invalid normalization diagnostics are built directly inside the CompilerState callback.
- `Compiler` no longer keeps a one-shot dependency-regex map spec-result describer wrapper either; invalid compiled-spec input diagnostics are built directly inside the CompilerState callback.
- `Compiler` no longer keeps a one-shot dependency-regex map rule-info describer wrapper either; invalid rule-info diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map `dependency_refs` describer wrapper either; invalid dependency-list diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map dependency-ref describer wrapper either; invalid dependency-ref diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map dependency-label describer wrapper either; invalid dependency-label diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map dependency-index describer wrapper either; invalid dependency-index diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map missing-rule describer wrapper either; missing dependency-rule diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map dependency-rule-info describer wrapper either; invalid referenced dependency-rule info diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a one-shot dependency-regex map dependency regex-list describer wrapper either; invalid referenced regex-list diagnostics are built directly at the map validation boundary.
- `Compiler` no longer keeps a compiled-spec state constructor pass-through wrapper either; rule-table build asks `CompilerState` for new state directly through the shared owner seam.
- `Compiler` no longer keeps a compiled-spec state predicate pass-through wrapper either; compiler-pipeline validation asks `CompilerState` directly through the shared owner seam.
- `Compiler` no longer keeps a compiled-spec rule-count pass-through wrapper either; trace and parser-generation counts ask `CompilerState` directly through the shared owner seam.
- `Compiler` no longer keeps the unused compiled-spec rules-by-label pass-through wrapper either; rules-by-label map access stays owned by `CompilerState` without a compiler-local mirror.
- `Compiler` no longer keeps a compiled-spec has-rule pass-through wrapper either; dependency-regex validation asks `CompilerState` directly whether referenced dependency rules exist.
- `Compiler` no longer keeps a compiled-spec rule-info pass-through wrapper either; dependency-regex validation retrieves referenced dependency-rule metadata directly from `CompilerState`.
- `Compiler` no longer keeps the unused compiled-rule-order pass-through wrapper either; compiled-rule ordering remains a `CompilerState` concern without a compiler-local mirror.
- `Compiler` no longer keeps a compiled-spec rule-rows pass-through wrapper either; dependency-regex map iteration asks `CompilerState` directly for compiled rule rows.
- `Compiler` no longer keeps a compiled-spec definition-order pass-through wrapper either; compiled-state trace output asks `CompilerState` directly for definition order.
- `Compiler` no longer keeps a compiled-spec redefined-labels pass-through wrapper either; compiled-state trace reporting asks `CompilerState` directly for redefined rule labels.
- `Compiler` no longer keeps a compiled-spec legacy projection pass-through wrapper either; legacy spec-hash projection asks `CompilerState` directly through the shared owner seam.
- `Compiler` no longer keeps a compiled-spec record-rule pass-through wrapper either; rule-table construction records compiled rules by asking `CompilerState` directly through the shared owner seam.
- `Compiler` no longer keeps a compiled descriptor legacy projection pass-through wrapper either; final descriptor projection asks `CompilerState` directly through the shared owner seam.
- `Compiler` no longer keeps the unused `_build_final_descriptor(...)` legacy projection helper either; the active path builds descriptor state with `_build_final_descriptor_state(...)` and projects through `CompilerState` at the boundary that needs the compatibility descriptor.
- `Compiler` no longer keeps a compiled-descriptor metadata pass-through wrapper either; final-descriptor assembly asks `CompilerState` to build descriptor metadata directly through the shared owner seam.
- `Compiler` now uses full `final_descriptor` local naming and `FINAL_DESCRIPTOR` trace banners on the active path instead of compressed `final_descr` wording.
- `Compiler` no longer keeps a compiled dependency-regex state constructor pass-through wrapper either; dependency-regex enrichment asks `CompilerState` to construct the state directly through the shared owner seam.
- `Compiler` no longer keeps a compiled descriptor state constructor pass-through wrapper either; final descriptor assembly asks `CompilerState` to construct the state directly through the shared owner seam.
- `Compiler` no longer keeps a compiled descriptor state predicate pass-through wrapper either; final descriptor assembly asks `CompilerState` to validate the state shape directly through the shared owner seam.
- `Compiler` no longer keeps the unused compiled descriptor metadata pass-through wrapper either; descriptor metadata reads stay owned by `CompilerState` without a compiler-local mirror.
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
- The former Perl-only legacy domain-utility owners and the `.plg` plugin corpus are no longer part of the active `perl/` tree; two retirement passes resolved them, and `t/phase0_regression.t` is green (960/960) without any of them.
  - **Deleted** (`LEGACY-VHDL-RETIRE`, the Perl-only non-portable VHDL/RTL/FSM-generation subsystem with no Rust/Julia/Dart counterpart): `RTLUtils`, `FSMGen`, `VHDL::ConstantEval`, and the six `.plg` files that depended exclusively on them (`fsmgen`/`lte_digital_rf`/`mbist`/`msword`/`regtest`/`rtl`). The stale `generic_fake_memory_module.plg` / `wrapgen.plg` / `get_log2`->`ceil_log2` prose carried here described files already deleted earlier; it is gone with the subsystem.
  - **Relocated to `noncore/`** (`NONCORE-QUARANTINE`, proven unreachable from the `LinkedSpec.pm` union shipped-`specs/*.spec` closure): the remaining non-core domain owners — `HTTP::FileAccess`, `HTML::PathLinks`, `InteractivePrompt`, `Text::VariableSubstitution`, `MSOffice::Excel`, `QC::Flow`, `QC::Summary`, `QC::TclInterconn`, `Table::GenericFilter`, `Timing::SetupHold`, `Timing::StanBackend`, `Timing::StanOmap2430cBackend` (plus the flat domain `.pm`) — and the 13 surviving `.plg`, all `git mv`'d into `noncore/` with layout preserved (`noncore/README.md` is the parked-fate ledger). The root `plugin/` directory no longer exists; `perl/` is now core-only.
- A fresh 2026-04-11 bootstrap pass confirmed that the recent compiler naming cleanup is now on the active facade/compiler path: `LinkedSpec.pm` exposes `build_compiled_rule_table(...)`, `Compiler.pm` / `CompilerState.pm` speak in terms of compiled-spec / compiled dependency-regex / compiled-descriptor state, and the former bootstrap-local `spec_descr` / `gdata` vocabulary has now been renamed to rule-descriptor / dispatch-state terminology.
- The legacy `ActionRewriter` compatibility module has now been deleted entirely (Phase 1 / `PHASE1-PARSER-CORE-ISOLATION.2`): it had become a pure forwarding shim over `RuleIR::EmitContext`, so the focused helper-rewrite compatibility entrypoint now lives solely in `LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat(...)` and there is no separate `ActionRewriter` surface to keep thin.
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

One supporting detail matters now: the repeated thin-wrapper plumbing for lazy package loading, callback/value lookup, delegated owner calls, and `$@` preservation is no longer reimplemented separately in each owner. `LinkedSpec.pm`, `LinkedSpec::Trace`, `Runtime.pm`, `ParserFactory.pm`, `BootstrapSpec.pm`, `BootstrapSpec::Core`, `Compiler.pm`, `SpecEntry.pm`, `RuleIR.pm`, `RuleIR::EmitContext.pm`, `Resolver.pm`, and `Validation.pm` now share that seam through `LinkedSpec::OwnerDispatch` (the former `ActionRewriter.pm` listed here was deleted in Phase 1), and the same seam is now also being spent inside active ActionIR owners such as `LinkedSpec::ActionIR::RewritePipeline`, `LinkedSpec::ActionIR::Scanner`, `LinkedSpec::ActionIR::ScannerCore`, `LinkedSpec::ActionIR::StatementSplit`, `LinkedSpec::ActionIR::StatementSplit::Core`, `LinkedSpec::ActionIR::CanonicalEvents`, `LinkedSpec::ActionIR::Diagnostics`, `LinkedSpec::ActionIR::ValueExpr`, `LinkedSpec::ActionIR::FlowExpr`, `LinkedSpec::ActionIR::ArrayPipeline`, `LinkedSpec::ActionIR::ControlFlow`, `LinkedSpec::ActionIR::Contracts`, `LinkedSpec::ActionIR::MethodLowering`, and `LinkedSpec::ActionIR::DeclareMethod`.
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
Project/domain utility owners - removed from core (`perl/` is now core-only)
  - Deleted   (LEGACY-VHDL-RETIRE):  RTLUtils, FSMGen, VHDL::ConstantEval
  - Relocated (NONCORE-QUARANTINE):  HTTP::FileAccess, HTML::PathLinks, InteractivePrompt,
                                     Text::VariableSubstitution, MSOffice::Excel, QC::Flow,
                                     QC::Summary, QC::TclInterconn, Table::GenericFilter,
                                     Timing::SetupHold, Timing::StanBackend,
                                     Timing::StanOmap2430cBackend (+ the flat domain .pm)
                                     -> noncore/  (parked-fate ledger: noncore/README.md)
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
- while compiled-rule recording during rule-table construction now also routes through that same owner instead of a compiler-local mutation pass-through,
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
- now use explicit `rule_descriptors` and `dispatch_state` naming for bootstrap parser handler plumbing. The old `spec_descr` / `gdata` words should be read as history/compatibility context, not active compiler descriptor/dependency-regex terminology,
- **new in MEDIUM-IMPACT.3.5**: `BootstrapSpec.pm` now has `_build_spec_spec_parser()` which lazily builds the spec.spec-generated parser via the bootstrap seed path (BootstrapSpec::Core → Compiler → spec.spec → parser) and caches the result. `run_bootstrap_parse()` runs the spec.spec parser alongside the bootstrap parser as a **diagnostic side channel** — bootstrap output is always primary for format compatibility. A recursion guard (`$BUILDING_SPEC_SPEC_PARSER` package variable) prevents infinite loop when spec.spec tries to parse itself. The cross-check harness (`tools/cross_check_spec_parsers.pl`) compares oracle (bootstrap) vs candidate (spec.spec) output: currently 2/20 exact match (tablegrep, verilog); remaining 18 specs have inflated candidate counts due to spec.spec `rule_paragraph:AND` handler lacking E-block body collection (MEDIUM-IMPACT.3.4 parity gap).

### `LinkedSpec::Validation`
- is the front-end DSL validation owner (1,368 lines, 30+ subs),
- provides three public entry points that gate the compile pipeline:

  **`validate_spec_content($spec_content, $option)`** — envelope validation:
  - checks the input is a SCALAR ref with non-empty content,
  - verifies the first non-comment/non-blank line starts with a valid rule label,
  - requires at least one top rule (`RuleName::`) as the parser entry point,
  - rejects malformed rule label syntax (extra colons, invalid mode suffixes),

  **`validate_dsl_syntax($spec_content, $option)`** — full paragraph-level validation:
  - parses rule labels (label, colon vs double-colon, mode suffix, RHS),
  - detects duplicate rule definitions,
  - rejects rule definitions inside still-open `{ }` blocks,
  - scans action edges (`->`) and blind-call edges (`=>`) with block-depth tracking,
  - rejects mixed action/blind-call code blocks within a single rule,
  - validates regex literals (`/pattern/`) for Perl compile-ability,
  - validates rule-header RHS start (regex cluster then valid paragraph member content),
  - checks split-marker syntax (`@capture_slice`, `@mark(name)`, etc.),
  - reports unused and undefined rule references,
  - when `strict_syntax => 1` is set, promotes reference warnings to hard errors,

  **`validate_dependency_regex_references($dependency_regex_map, $spec, $option)`** — cross-reference validation:
  - checks every dependency-regex entry references an existing rule,
  - verifies every rule reference targets a valid regex index within the referenced rule's `re` array,
  - validates each rule definition's `dependency_refs` entries have `label` and `idx` keys,

  plus two shared back-end validation entry points:
  - `validate_compiled_descriptor_state($descriptor_state, $option)` — validates compiled descriptor state shape and cross-references via the `CompilerState` validation-view seam,
  - `validate_rule_definition($rule_name, $rule_def)` — validates a single rule's handler field, `re` array, and regex syntax,

- error reporting routes through `_report_dsl_validation_failure` which passes structured `summary`/`detail`/`rule_label` info to the `on_failure` callback and logs via `_trace_log_output`,
- `get_dsl_context($spec_content, $position)` provides line-number/context extraction for error messages,
- `_parse_rule_label_line($line)` is the single rule-label parser used across Validation, Compiler, and BootstrapSpec — it recognizes all supported label forms (`:`, `::`, `:AND+`, `:OR{2,4}`, etc.) and flags invalid modes,
- `_scan_rule_edges_in_fragment($fragment, $start_depth)` is the edge scanner that tracks block depth across `{ }`, `( )`, `[ ]`, string literals, and regex literals while extracting action/blind-call target labels — it powers both same-line validation and cross-line paragraph-member validation,
- for debugging validation failures: look at `_trace_log_output` messages (logged at `DUMP_NONE` for errors, `DUMP_LOW` for warnings), check the `on_failure` callback for structured payloads, and use `get_dsl_context` to correlate line numbers in error messages with source content.

### `LinkedSpec::SpecEntry`
- compiles parsed rule entries into generated runtime handler code,
- still assembles Perl source strings and `eval`s them,
- remains the clearest backend-portability ceiling in the current implementation,
- **new in MEDIUM-IMPACT.1**: handler-variant building is now delegated to `LinkedSpec::HandlerVariantEmitter` which provides:
  - a structured **HandlerIR** (hashref-based AST with `kind`/`label`/`parse_mode`/lifecycle slots / dispatch refs) — each of the 10 variant builders returns an IR node instead of raw Perl source,
  - `_emit_handler($ir, %opts)` dispatches through a `%BACKEND_EMITTERS` table (default: `perl` backend → `_emit_handler_perl`),
  - a JSON/AST diagnostic backend (`_emit_handler_json`) that serializes HandlerIR as canonical pretty-printed JSON via `JSON::PP`, proving backend pluggability,
  - `$BACKEND` package variable + `$deps->{backend}` threading so callers can request alternative backends per compilation.

### `LinkedRE`
- is a small (56-line) regex composition utility living at `perl/LinkedRE.pm`,
- provides two functions: `or(...)` and `oredRE(...)`,
- `oredRE(@regexes)` joins an array of regex references into a single compiled regex via `(?{$pos=N})` position-tracking alternation (`qr/$re0(?{$pos=0})|$re1(?{$pos=1})|.../`),
- `or($stref, $oredRE, $mode_or_parent, $parent_info)` executes the compiled alternation against a scalar ref in seek mode (ungrounded `//gcp`, matches anywhere) or consume mode (`\G`-anchored `//gcp`, contiguously from `pos()`), and returns a match-info hash with `index`, `match`, `match_list`, `match_hash`, and optional `marks`,
- the position-tracking `(?{$pos=N})` embedded in each alternation branch lets callers identify which regex alternative matched via the returned `index` field,
- consumers:
  - `Compiler.pm` (via `_ored_re`): builds compiled regex alternative tables for the dependency-regex map,
  - `SpecEntry.pm`: generates `LinkedRE::or(...)` calls in handler source strings for rule dispatch at runtime,
  - `BootstrapSpec::Core.pm` (via `_linkedre_or` and `_linkedre_ored_re`): uses both functions for bootstrap grammar matching without any `eval`,
- all three consumers load LinkedRE through `OwnerDispatch::require_pkg(...)` rather than direct `use` or local loader wrappers,
- `use re 'eval'` is required for the `(?{...})` embedded code blocks in the compiled regex alternation.

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
  - now also treats `_extract_scalar_symbol_name(...)`, `_extract_array_symbol_name(...)`, `_extract_hash_symbol_name(...)`, `_lower_scalar_access_key_expr(...)`, `_split_nested_access_path_segments(...)`, `_lower_nested_access_segment_expr(...)`, `_infer_scalar_container_kind(...)`, `_lower_assignment_source_expr(...)`, and `_strip_literal_delimiters(...)` as the direct callback-validation seams instead of keeping a second top-level `_require_dep(...)` wrapper above them.
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
- is treated as an internal compatibility adapter reachable only through the deprecated `LinkedSpec` plugin-bridge stubs; the legacy `.plg` corpus it used to discover has been relocated to `noncore/plugin/`, so the active `perl/` tree no longer ships any `.plg` file for it to load,
- and still closes the remaining lazy compatibility cycle:
  - `LinkedSpec -> PluginBridge -> PPlugin -> LinkedSpec::get_parser('pplugin')`

Current project direction does not treat that branch as a target architecture.

### Retired and quarantined domain owners

The project's former domain-utility owners — the RTL/VHDL/FSM generation helpers, the QC and timing report backends, the HTTP/HTML/text/Office/table helpers — and the legacy `.plg` plugin corpus they came from are **no longer part of the active `perl/` tree**. They were the Perl reference backend's legacy island, not part of the backend-neutral `.spec` contract, and two retirement passes resolved them once `t/phase0_regression.t` confirmed the `.spec` engine has zero functional dependency on any of them:

- **Deleted** (`LEGACY-VHDL-RETIRE`): the Perl-only, non-portable VHDL/RTL/FSM-generation subsystem — `RTLUtils`, `FSMGen`, `VHDL::ConstantEval`, and the six `.plg` files that depended exclusively on them — has no Rust/Julia/Dart counterpart, so it was removed rather than ported (which also cleared a catastrophic-backtracking regex hang that used to block the regression gate). The earlier `generic_fake_memory_module.plg` / `wrapgen.plg` / `get_log2`->`ceil_log2` prose described files that had already been deleted; it is gone with the subsystem.
- **Relocated to `noncore/`** (`NONCORE-QUARANTINE`): every remaining non-core domain owner — `HTTP::FileAccess`, `HTML::PathLinks`, `InteractivePrompt`, `Text::VariableSubstitution`, `MSOffice::Excel`, `QC::Flow`, `QC::Summary`, `QC::TclInterconn`, `Table::GenericFilter`, `Timing::SetupHold`, `Timing::StanBackend`, `Timing::StanOmap2430cBackend`, plus the flat domain `.pm` — and the 13 surviving `.plg` were `git mv`'d into `noncore/` with layout preserved. `noncore/README.md` is the parked-fate ledger (refactor / port / publish / delete each on its own merits later), and the root `plugin/` directory no longer exists.

The historical narrative — how each helper family graduated out of `.plg` plugin subdefs into a package owner — lived here as a faithful record of the reference backend's plugin-retirement work. That work is now moot: the code itself has left the core. `git log` for `LEGACY-VHDL-RETIRE` and `NONCORE-QUARANTINE` preserves the detail.

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

As of the 2026-05-11 phase0 guard, every discovered target `.spec` must compile to descriptor metadata with `language_agnostic_ready_ratio == 1.0000`, no language-agnostic blocked rules, and no compatibility-surface rules. That makes future DSL migration work a matter of preserving the all-target ActionIR-ready contract while improving semantics and architecture.

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
- `SpecEntry` remains the biggest portability hotspot, though `HandlerVariantEmitter` now isolates the 10 variant builders into their own module (first step toward HandlerIR and backend pluggability),
- `RuleIR` plus `ActionIR::*` are where backend-neutral action semantics really live,
- `RuntimeContext` is one of the strongest architectural boundaries in the project,
- and the legacy plugin branch should be treated as transition/removal machinery, not as the future identity of LinkedSpec.
