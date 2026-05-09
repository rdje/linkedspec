# Owner Tree and Module Boundaries

LinkedSpec is no longer best understood as one large `LinkedSpec.pm` file.

The active architecture is deliberately owner-oriented: each important package is expected to own one part of the system, and cross-owner calls should make that ownership visible.

This matters because LinkedSpec is dynamic. It parses `.spec` source, compiles runtime handlers, rewrites action DSL, dispatches through dependency regexes, and preserves structured diagnostics across several boundaries. Without clear owners, those pieces become opaque implementation detail. With clear owners, they become a system that can be refactored safely.

## High-level reading

`LinkedSpec.pm` is now a thin facade.

It exposes the public API, then delegates into owners:

```text
LinkedSpec.pm
  -> LinkedSpec::ParserFactory
  -> LinkedSpec::Runtime
  -> LinkedSpec::Compiler
```

The practical core spine is:

```text
get_parser(...) -> ParserFactory -> Runtime -> Compiler
Get(...)        -> Runtime       -> Compiler
```

`get_parser(...)` is the file-oriented public path. It validates a spec name, resolves a `.spec` file, loads it, and then delegates compilation.

`Get(...)` is the source-oriented public path. It receives `.spec` source directly and delegates compilation.

Both paths converge on the runtime/compiler pipeline.

## Current owner tree

This is the public mental model for the core owner tree:

```text
LinkedSpec
  facade and public entrypoint

  OwnerDispatch
    shared lazy-loading, callback lookup, dependency bundles, and $@ preservation

  Trace
    trace configuration, verbosity gates, formatting, and trace sinks

  ParserFactory
    get_parser(...): name validation, spec resolution, loading, compile delegation

    Resolver
      named .spec lookup and file loading

    RuntimeContext
      spec identity and structured last_error payloads

    Runtime
      Get(...) orchestration and compile-pipeline delegation

      Compiler
        source validation, bootstrap parse, compiled states, descriptors, parser wrapper

        BootstrapSpec / BootstrapSpec::Core
          bootstrap parser for .spec syntax

        Validation
          early frontend validation and descriptor-state validation

        CompilerState
          compiled_spec_state, compiled_dependency_regex_state, compiled_descriptor_state

        SpecEntry
          per-rule generated handler construction

          RuleIR
            rule-level intermediate representation and handler metadata

          RuleIR::EmitContext
            bridge into ActionIR scanning/lowering and generated code emission

            ActionIR::*
              backend-neutral helper DSL scanning, canonicalization, contracts, and lowering

  PluginRegistry / PluginBridge / PPlugin
    legacy plugin transition branch, not the future architectural center
```

This tree is intentionally a reading guide, not a literal static import tree. LinkedSpec uses lazy loading, so the code that matters is often reached through owner dispatch rather than visible in one large `use` list.

`LinkedSpec::RuntimeContext` is the shared owner for runtime-context preparation as well as payload storage. Inline `Get(...)`, file-oriented `get_parser(...)`, compiler-pipeline parser-source setup, and low-level `build_compiled_rule_table(...)` diagnostics now route their runtime-context setup through that owner instead of each hand-normalizing the hook or carrying their own stale parser-source cleanup rules. Paths that need to drop stale parser-source emit callbacks now share one capture-reset helper there, while the compiler-pipeline path still uses the narrower chunk-only reset that keeps active source emission wired. Stale `spec_name` / `spec_path` cleanup is also a shared helper now, kept separate from `top_rule` selection so file identity and entrypoint continuity do not blur together.

Eleven small but useful examples of that owner-shape cleanup are `LinkedSpec::ActionIR::Contracts`, `LinkedSpec::ActionIR::ScannerCore`, `LinkedSpec::ActionIR::StatementSplit`, `LinkedSpec::ActionIR::CanonicalEvents`, `LinkedSpec::ActionIR::Diagnostics`, `LinkedSpec::ActionIR::RewritePipeline`, `LinkedSpec::ActionIR::ArrayPipeline`, `LinkedSpec::ActionIR::ValueExpr`, `LinkedSpec::ActionIR::FlowExpr`, `LinkedSpec::ActionIR::ControlFlow`, and `LinkedSpec::ActionIR::MethodLowering`: those files now keep `_require_lowering_deps(...)`, `_scanner_rule_dep_bindings(...)`, `_split_action_ir_statements(...)`, `_build_canonical_action_ir_events(...)`, `_find_unresolved_action_helpers(...)`, `_collect_action_helper_ir_nodes(...)`, `_build_action_rewrite_rules(...)`, `_rewrite_action_code_with_diagnostics(...)`, `_normalize_split_delimiter_expr(...)`, `_build_array_pipeline_plan_from_expr(...)`, `_extract_scalar_symbol_name(...)`, `_extract_array_symbol_name(...)`, `_extract_hash_symbol_name(...)`, `_lower_scalar_access_key_expr(...)`, `_split_scalaref_path_segments(...)`, `_lower_scalaref_segment_expr(...)`, `_infer_scalar_container_kind(...)`, `_lower_assignment_source_expr(...)`, `_strip_literal_delimiters(...)`, `_looks_like_array_value_expr(...)`, `_looks_like_hash_value_expr(...)`, `_lower_is_empty_expr(...)`, `_lower_defined_target_expr(...)`, `_lower_flow_composite_expr(...)`, `_lower_control_flow_value_expr(...)`, `_lower_switch_case_value_expr(...)`, `_normalize_bare_zero_arg_flow_marker_expr(...)`, `_lower_if_flow_statement(...)`, `_lower_elseif_flow_statement(...)`, `_lower_else_flow_statement(...)`, `_lower_endif_flow_statement(...)`, `_expand_flow_branch_action_exprs(...)`, `_parse_method_expr_with_optional_attached_block(...)`, `_lower_flow_branch_single_statement(...)`, `_lower_inline_if_branch_expr(...)`, `_lower_inline_switch_branch_expr(...)`, `_lower_switch_flow_statement(...)`, `_lower_case_flow_statement(...)`, `_lower_default_flow_statement(...)`, `_lower_endcase_flow_statement(...)`, `_lower_endswitch_flow_statement(...)`, `_lower_say_statement(...)`, `_lower_print_statement(...)`, `_lower_print_each_statement(...)`, `_lower_typed_declare_statement(...)`, `_normalize_method_tag_expr(...)`, `_lower_method_value_expr(...)`, `_lower_return_payload_expr(...)`, `_lower_return_general_statement(...)`, `_lower_assign_statement(...)`, `_lower_push_value_statement(...)`, `_lower_push_nonempty_statement(...)`, `_lower_regex_subst_statement(...)`, and `_lower_return_undef_statement(...)` as their local dependency seams and no longer expose second top-level `_require_dep(...)` validator wrappers beside them.

## The facade owns routing, not semantics

`LinkedSpec.pm` is the public door.

It owns:

- public function names such as `Get(...)`, `get_parser(...)`, `configure_trace(...)`, and trace helpers,
- thin compatibility wrappers such as `build_compiled_rule_table(...)`,
- plugin compatibility entrypoints that still exist during the transition,
- routing into owner modules through `LinkedSpec::OwnerDispatch`.

It should not own:

- spec-file resolution,
- compile-pipeline semantics,
- generated handler construction,
- ActionIR lowering semantics,
- structured diagnostic payload construction,
- dependency-regex descriptor-state validation.

That separation is deliberate. When the facade stays thin, public API stability does not force the implementation to stay monolithic.

## `OwnerDispatch`

`LinkedSpec::OwnerDispatch` is plumbing, not product semantics.

It centralizes repeated owner-wrapper behavior:

- lazy package loading,
- callback lookup from an owner package,
- dependency callback map construction,
- mixed callback/value dependency bundle construction,
- `$@` preservation across successful delegated calls,
- uniform delegated owner calls.

This matters because many LinkedSpec owners are thin wrappers around deeper implementation packages. If each wrapper hand-rolls lazy loading and callback lookup, the project accumulates small inconsistencies. `OwnerDispatch` keeps that boilerplate in one place.

Delegated owner calls go through that same callback-loader route too: `dispatch_owner_call(...)` resolves its target through `require_pkg_cb(...)` before invoking the coderef. That keeps lazy loading, callback validation, list-context return preservation, and successful `$@` preservation on one shared path.

`OwnerDispatch` now also makes that lazy-load path `chdir(...)`-safe by seeding the repo `perl` root into `@INC` as an absolute path at module load time. That matters for file-oriented parser flows such as `get_parser(...)`, which may resolve deeper owners only after tests or callers have moved into a temp directory.

Current thin wrapper callback lookup for `Compiler`, `BootstrapSpec`, `SpecEntry`, `ActionIR::Scanner`, and `RuleIR::EmitContext`'s ActionIR owner dispatch goes through this shared callback-loader seam. `Runtime::run_get(...)` resolves its compiler pipeline callback directly through that seam inside the live orchestration body. Direct callback probing is reserved for `OwnerDispatch` itself.

In the same direction, `Runtime`, `Compiler`, `BootstrapSpec`, and `ParserFactory` no longer keep one-shot local pass-through wrappers for the single compiler/bootstrap callback or `$@`-preservation calls inside their main orchestration helpers. `Runtime`, `ParserFactory`, `SpecEntry`, and compiler diagnostics also ask `RuntimeContext` for generated-handler labels and last-error writes directly at their fallback diagnostics boundaries instead of keeping one-shot label or setter wrappers. Compiler parser-source emission and final parser-source output also ask `RuntimeContext` to append and flush captured source text directly instead of keeping local pass-through wrappers, parser invocation asks `RuntimeContext` for last-error read state directly when preserving deeper runtime-handler context, stale-error cleanup goes to `RuntimeContext` directly, selected-top-rule reads/writes now go to `RuntimeContext` directly too, low-level rule-table setup now inlines its small `top_rule` selection before asking `RuntimeContext` to prepare shared rule-table state, `ParserFactory::run_get_parser(...)` now calls runtime-context preparation, spec-path writes, direct parser-factory last-error writes, and compile-stage fallback last-error preservation directly too, and `Runtime::run_get(...)` now resolves the compiler callback, prepares runtime context, and writes fallback last-error state directly too while no longer carrying local setup wrappers. `ParserFactory` also validates its required trace-level values directly in `run_get_parser(...)` instead of keeping a one-shot value-dependency validator. Those live bodies now spend the real setup seams directly, which keeps meaningful ownership visible instead of hiding it behind wrapper names that only had one caller.

`BootstrapSpec` now follows that rule at the bootstrap facade too: `build_bootstrap_spec(...)` remains the meaningful local seam, but it now calls `OwnerDispatch::require_pkg_cb(...)` directly for `BootstrapSpec::Core::build_bootstrap_spec(...)` instead of bouncing through a separate `_require_bootstrap_core_pkg(...)` loader first.

`Resolver` and `ActionIR::Scanner` now follow that same pattern for their local trace/scanner-owner helper paths too: the meaningful local helpers remain, but the live bodies spend `OwnerDispatch` directly instead of bouncing through extra local pass-through wrappers first.

`Compiler`, `SpecEntry`, and `RuleIR` now follow the same rule for package-specific helper loading on the compile path: the meaningful Trace / `Data::Dumper` / `LinkedRE` helper seams remain, but they call `OwnerDispatch::require_pkg(...)` directly instead of bouncing through another generic `_require_pkg(...)` shim first.

`Compiler` and `SpecEntry` now follow the same rule for callback loading on that compile path too: the meaningful bootstrap/spec-entry/validation and RuleIR/emit-context helper seams remain, but they call `OwnerDispatch::require_pkg_cb(...)` directly instead of bouncing through another generic `_require_pkg_cb(...)` shim first.

`BootstrapSpec::Core`, `ActionIR::ScannerCore`, and `PluginBridge` now follow the same rule for single-use package loading too: they still keep their meaningful local LinkedRE/scanner-family/legacy-runtime helper seams, but those helpers now call `OwnerDispatch::require_pkg(...)` directly instead of bouncing through another generic `_require_pkg(...)` shim first.

`RuleIR::EmitContext` now follows that same rule for its internal ActionIR owner-package registry: `_actionir_owner_package(...)` remains the meaningful local seam, but it now calls `OwnerDispatch::require_pkg(...)` directly instead of bouncing through another generic `_require_pkg(...)` shim first.

`ActionIR::StatementSplit` now follows the same rule at the split facade: `_split_action_ir_statements(...)` remains the meaningful local seam, but it now calls `OwnerDispatch::require_pkg(...)` directly when it lazy-loads `StatementSplit::Core` instead of bouncing through another single-use core-loader wrapper.

`ActionIR::CanonicalEvents` now follows it at the canonicalization facade too: `_canonicalize_helper_action_ir_event(...)` remains the meaningful local seam, but it now calls `OwnerDispatch::require_pkg(...)` directly when it lazy-loads `CanonicalEvents::Core` instead of bouncing through another single-use core-loader wrapper.

`ActionIR::StatementSplit::Core` now follows it too: `_require_statement_split_mode_pkg(...)` and `_require_method_expr_pkg(...)` remain the meaningful local seams, but they now call `OwnerDispatch::require_pkg(...)` directly instead of bouncing through another generic `_require_pkg(...)` shim first.

`BootstrapSpec::Core` now follows the same rule for its tiny LinkedRE helper wrappers: `_linkedre_or(...)` and `_linkedre_ored_re(...)` remain the meaningful local seams, but they now call both `OwnerDispatch::require_pkg(...)` and `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through separate local loader or `$@`-preservation shims first.

`PluginBridge` now follows that same rule for its compatibility dispatch helpers too: `_exec_legacy_plugin(...)`, `_get_legacy_plugin(...)`, `_lookup_plugin_name(...)`, and `_dispatch_plugin_name(...)` remain the meaningful local seams, but they now call `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through another local `_call_preserving_err(...)` shim first.

`Compiler` now follows it too for its compile-path trace/dump helpers: `_dump_value(...)`, `_ored_re(...)`, `_trace_log_output(...)`, `_trace_log_dump(...)`, `_trace_should_dump(...)`, `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`, `_trace_apply_trace_options(...)`, and `_trace_level_name_for_current_verbosity(...)` remain the meaningful local seams, but they now call `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through another local `_call_preserving_err(...)` shim first. `_dump_value(...)` also calls `OwnerDispatch::require_pkg(...)` directly for `Data::Dumper`, and `_ored_re(...)` does the same for `LinkedRE`, so neither helper needs a separate compiler-local loader wrapper.

`SpecEntry` now follows it too for its compile-path trace/dump helpers: `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`, `_trace_log_dump(...)`, `_trace_should_dump(...)`, `_dump_value(...)`, and `_trace_runtime_mark_event(...)` remain the meaningful local seams, but they now call `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through another local `_call_preserving_err(...)` shim first. `_dump_value(...)` also calls `OwnerDispatch::require_pkg(...)` directly for `Data::Dumper`, so it no longer needs a separate spec-entry-local loader wrapper. In the same cleanup style, generated-handler source labels now come from `RuntimeContext`'s rule-metadata label helper directly instead of a one-shot `SpecEntry` pass-through wrapper.

`SpecEntry` discovered top-rule writes and generated-handler parser-source emission now follow that same direct owner-dispatch style too: `compile_spec_entry(...)` calls `RuntimeContext`'s top-rule setter and parser-source emitter directly instead of keeping local pass-throughs.

`RuleIR` now follows it too: `_trace_should_dump(...)`, `_trace_log_output(...)`, `_trace_decision(...)`, and `_dump_value(...)` remain the meaningful local seams, but they now call `OwnerDispatch::call_preserving_err(...)` directly instead of bouncing through another local `_call_preserving_err(...)` shim first. `_dump_value(...)` also calls `OwnerDispatch::require_pkg(...)` directly for `Data::Dumper`, so it no longer needs a separate RuleIR-local loader wrapper.

`RuleIR::EmitContext` now follows it too for its internal ActionIR/rewrite orchestration helpers: `_actionir_owner_package(...)`, `_actionir_owner_default_deps(...)`, `_call_actionir_owner(...)`, `_call_actionir_owner_with_deps(...)`, `_accumulate_action_rewrite_diagnostics(...)`, and `rewrite_action_code_for_compat(...)` remain the meaningful local seams, but they now spend the owner-key registry plus shared dispatcher directly instead of bouncing through extra owner-specific `_require_*_pkg(...)` shims or another local `_call_preserving_err(...)` shim first.

ActionIR owners whose only callback resolution happens while assembling `default_deps_for_package(...)` do not keep local callback-loader wrappers. They use `OwnerDispatch::build_dep_map(...)` directly, and that shared builder owns dependency callback loading.

The design rule is:

```text
semantic ownership belongs to the target owner;
dispatch mechanics belong to OwnerDispatch.
```

## `ParserFactory`

`LinkedSpec::ParserFactory` owns the file-oriented public parser path:

```perl
my $parser = LinkedSpec::get_parser('vhdl');
```

Its job is to answer this question:

```text
How do we turn a requested spec name into a compiled parser?
```

That includes:

- validating the requested spec name,
- resolving it to a `.spec` path through `Resolver`,
- loading the spec content,
- preparing runtime context identity such as `spec_name` and `spec_path`,
- applying trace options for the parser-factory call,
- delegating actual compilation to `Runtime`.

`ParserFactory` should not compile rules itself. Once it has loaded `.spec` source, it hands the source to the same runtime/compiler path used by direct `Get(...)`.

## `Resolver`

`LinkedSpec::Resolver` owns named `.spec` lookup.

It is the home for behavior like:

```text
get_parser('vhdl') should be able to find specs/vhdl.spec
```

That responsibility is different from plugin lookup. Spec resolution should stay deterministic and file-oriented. It should not be confused with the legacy dynamic plugin system.

Its small trace-reporting helpers now spend `LinkedSpec::OwnerDispatch` directly for lazy `Trace` loading and successful `$@` preservation, so the resolver owner no longer carries a separate local trace-wrapper layer on top of the shared seam.

## `Runtime`

`LinkedSpec::Runtime` owns the source-oriented public path:

```perl
my $parser = LinkedSpec::Get(\$spec_source);
```

It prepares runtime context, normalizes mode expectations, delegates to the compiler pipeline, and writes fallback runtime-owner diagnostics only if a deeper owner did not already provide a better structured error.

The key rule is:

```text
Runtime orchestrates the call;
Compiler owns the compile semantics.
```

## `RuntimeContext`

`LinkedSpec::RuntimeContext` is one of the strongest boundaries in the current architecture.

It owns shared runtime state such as:

- `spec_name`,
- `spec_path`,
- `top_rule`,
- structured `last_error`,
- generated handler source labels,
- parser-source capture state when requested.

That state has to survive crossings between public API, parser factory, runtime owner, compiler, generated handlers, and parser invocation. Centralizing it prevents each owner from inventing its own partial context shape.

When a failure occurs, the preferred pattern is:

```text
the owner closest to the failure writes the richest payload;
outer owners preserve it unless no payload exists yet.
```

That is why `runtime_ctx->{last_error}` can keep useful fields such as `spec_path`, `top_rule`, `rule_label`, and `handler_source_label` instead of collapsing into a generic outer exception.

## `Compiler`

`LinkedSpec::Compiler` owns the compile pipeline.

Its public mental model is covered in the compiler chapter, but architecturally it is the owner that coordinates:

- source envelope validation,
- DSL syntax validation,
- bootstrap parsing,
- compiled rule-table construction,
- dependency-regex state construction,
- compiled descriptor-state assembly,
- descriptor-state validation,
- outward descriptor projection,
- parser coderef construction.

The important architectural move is that the compiler now works through explicit internal state records before projecting outward descriptor data.

The active internal records are:

- `compiled_spec_state`,
- `compiled_dependency_regex_state`,
- `compiled_descriptor_state`.

The public outward descriptor can still expose:

```perl
{
  spec => { ... },
  dependency_regex_map => { ... },
  meta => { ... },
}
```

But the compiler should not treat that outward projection as its own only source of truth.

## `CompilerState`

`LinkedSpec::CompilerState` owns the compiled state model.

It is the right home for questions like:

- What shape is a valid `compiled_spec_state`?
- How do we iterate compiled rules in deterministic order?
- How do we project compiled state to outward descriptor hashes?
- How do we build descriptor metadata from compiled state?
- How do we expose validation-friendly descriptor-state views?

This owner exists to avoid a bad pattern:

```text
Compiler.pm and Validation.pm both poking raw state hashes directly.
```

The preferred direction for this project is state-first and owner-first:

```text
Compiler coordinates.
CompilerState defines and reads compiler state.
Validation validates through owner-provided views.
```

## `BootstrapSpec` and `Validation`

`LinkedSpec::BootstrapSpec` and `LinkedSpec::BootstrapSpec::Core` own the bootstrap grammar used to parse `.spec` syntax.

That area is powerful and still a hotspot because LinkedSpec uses a bootstrap parser to parse the language used to define parsers.

One naming caveat is worth keeping straight: active compiler descriptors use compiled-state and dependency-regex terminology, and the bootstrap parser internals now use explicit `rule_descriptors` / `dispatch_state` terminology as well. Older `spec_descr` / `gdata` wording should be read as historical context or compatibility-test language, not as the active compiler descriptor model.

`LinkedSpec::Validation` owns early hardening before failures become confusing runtime behavior. It validates things like malformed rule starts, mode syntax, split markers, top-level paragraph shape, and descriptor-state dependency consistency.

The frontend rule is:

```text
reject malformed .spec structure as early and specifically as possible.
```

That keeps bad user input from drifting into generated code, generic Perl errors, or misleading runtime failures.

## `SpecEntry`, `RuleIR`, and `RuleIR::EmitContext`

`LinkedSpec::SpecEntry` compiles one parsed rule entry into generated runtime behavior.

It is where the current Perl backend still shows through most clearly: generated handler source is assembled and evaluated.

`LinkedSpec::RuleIR` owns rule-level intermediate representation and metadata planning.

`LinkedSpec::RuleIR::EmitContext` is the bridge from rule IR into action-helper scanning and lowering. It carries normalized action/lifecycle material such as:

- `ACODEs`,
- `BCODEs`,
- `BCALLs`,
- `DEPENDENCY_REFS`,
- lifecycle chunks,
- action-rewriter metadata.

The key architecture point is:

```text
SpecEntry emits the current backend.
RuleIR and ActionIR carry the path toward cleaner backend-neutral semantics.
```

## `ActionIR::*`

The `LinkedSpec::ActionIR::*` subtree is where the helper DSL becomes structured semantics.

Important families include:

- `MethodExpr` for parsing method-like helper expressions,
- `Scanner` and `ScannerCore` for finding helper and compatibility surfaces,
- scanner rule families such as `PrimitiveBasicRules`, `PrimitivePipelineRules`, `FlowRules`, and `LegacyRules`,
- `StatementSplit` for safe statement splitting,
- `CanonicalEvents` for canonical helper-event forms,
- `Contracts` for the supported helper contract catalog,
- `ValueExpr`, `FlowExpr`, `ArrayPipeline`, `ControlFlow`, `MethodLowering`, and `DeclareMethod` for lowering families,
- `Diagnostics` for unresolved helper and compatibility-surface telemetry,
- `RewritePipeline` for gluing scan, classify, and lower phases together.

Within those lowering owners, `DeclareMethod` now treats its declare/assign helper routines as the direct callback-validation seams instead of carrying a second top-level `_require_dep(...)` wrapper above them. `ControlFlow` now does the same for the branch/output lowering helper family that owns if/switch marker lowering plus fluent `say(...)` / `print(...)` / `print_each(...)` lowering. `MethodLowering` now follows that same shape for method/value/assignment/return lowering.

`ScannerCore` is also the single source of truth for the scanner dependency contract: `Scanner.pm` assembles its default dep map from `_scanner_dep_specs()`, and the core derives its rebinding symbols from that same table instead of carrying a second symbol registry.

This is where much of the long-term portability story lives. The project can keep the current Perl backend while progressively making action semantics less dependent on raw Perl snippets.

## `Trace`

`LinkedSpec::Trace` owns trace configuration and rendering.

It is separate from `RuntimeContext` on purpose:

- `RuntimeContext` owns structured state and `last_error`,
- `Trace` owns optional visibility into what the system is doing.

That separation keeps diagnostics usable even when tracing is off.

## Legacy plugin branch

The public facade still exposes plugin-related entrypoints:

- `register_plugin(...)`,
- `register_plugins(...)`,
- `clear_registered_plugins(...)`,
- `run_plugin(...)`,
- `get_plugin(...)`,
- `dispatch_plugin_autoload_name(...)`,
- `AUTOLOAD`.

Architecturally, this branch should be read as transition machinery.

`LinkedSpec::PluginRegistry` owns explicit in-memory plugin registration.

`LinkedSpec::PluginBridge` checks explicit registration first and falls back to legacy behavior when needed. Its current compatibility plumbing uses the shared owner-dispatch seam for default dependency-map assembly, registered-plugin lookup, legacy `PPlugin` loading, and successful `$@` preservation, and its live lookup/dispatch bodies now validate injected callbacks inline instead of bouncing through a second top-level `_require_dep(...)` helper, so even this transition branch follows the same wrapper discipline as the main runtime owners.

`PPlugin` owns the old `.plg` discovery/execution path. It reads legacy plugin files through explicit file IO, reports and skips unreadable or malformed files during registry construction, and still reaches back to `LinkedSpec::get_parser('pplugin')` to parse `.plg` files. That callback load now goes through the shared owner-dispatch seam instead of a local `require LinkedSpec` branch.

Repo-owned `.plg` files should not reach into `PPlugin->get(...)` directly. Shipped lookup paths that still need callback resolution should use `LinkedSpec::get_plugin(...)`, which keeps registry-first lookup and legacy fallback under `PluginBridge` while the `.plg` surface is being retired. The FSMGen dynamic plugin-list parser has already moved one step further: the old `plugin/fsmgen.plg::getop_plugin_list` helper wrapper is gone, and `FSMGen::getop_plugin_list(...)` uses `LinkedSpec::get_plugin(...)` only as its default resolver.

Package-backed plugin extraction is already underway. The former HTTP-oriented helper/action surface has graduated further into HTTP-domain owner `HTTP::FileAccess`: `url_for_path`, `set_hostport`, `set_localhost`, `print_file_links_for_conf`, and `run_lighttpd_for_conf`. The former path-token link helper has graduated further into HTML-domain owner `HTML::PathLinks`: `link_path_tokens`. The former string substitution helpers have graduated further into text-domain owner `Text::VariableSubstitution`: `var_subst` and `var_subst_test`. The former generic table grouping actions have graduated further into table-domain owner `Table::GenericFilter`: `group_by`, `group_by_port`, `group_by_ioclock`, and `group_byRE`. The former private QC summary row-merging helper has moved into domain owner `QC::Summary`: `append_merged_rows`. The former QC flow duplicate-suppressed log insertion, budget-check, filter-expression, clock CTS summary, qclog workbook/link, and qclog table-preparation helpers have moved into domain owner `QC::Flow`: `push_once`, `budget_check`, `budget_check_single_or_zero_match`, `filter_handler`, `clock_cts_info`, `write_qclog_links`, and `prepare_qclog_data`. The related Tcl/FANX helper trio has moved into domain owner `QC::TclInterconn`: `append_interconnect_tcl`, `load_fanx`, and `fanx_info`. The RTL memory-wrapper address-width helper and VHDL header/context-clause helper have moved into RTL-domain owner `RTLUtils`: `ceil_log2` and `add_header_n_context_clause`. FSMGen's dynamic plugin-list parser has moved into FSMGen-domain owner `FSMGen`: `getop_plugin_list`. The setup/hold timing formulas, DxCy traversal helper, and visible `tssio` report/action body have moved into timing-domain owner `Timing::SetupHold`: `collect_dxcy`, `calculate_path_delay`, the named delay helpers, and `write_tssio`. The STAN/report-timing backend setup helper and clock-matrix cell formatter have moved into timing-domain owner `Timing::StanBackend`: `start` and `clock_matrix_cell_code`. The STAN OMAP2430C STA-frequency callback, frequency-detail helpers, report writers, TCK-delay DM-measures writer, no-path checker, and port-timing traversal callback have moved into timing-domain owner `Timing::StanOmap2430cBackend`: `collect_sta_frequency`, `record_frequency_detail`, `write_frequency_detail_paths`, `write_frequency_detail`, `frequency_detail_filename`, `write_potential_fp`, `write_questionable_paths`, `write_frequency_summary`, `write_tck_delays`, `write_no_path_check`, `record_no_path_check`, and `filter_port_timing_paths`. The former VHDL constant-evaluation helpers have graduated further into domain owner `VHDL::ConstantEval`, and the former Excel-start helper has graduated further into domain owner `MSOffice::Excel`. That means repo-owned callers can name normal package owners instead of constructing plugin strings and asking the bridge or legacy runtime to look them up.

The `plugin/genericfilter.plg` file no longer exists. It had already become only compatibility registration after the GenericFilter implementation moved into a package owner, and it was deleted once no repo-owned caller still needed the legacy `genericfilter_*` names. The short-lived `Plugin::GenericFilter` scaffold is gone too; current callers use `Table::GenericFilter`.

Not every extracted package owner should keep such a wrapper. `Text::VariableSubstitution`, `HTML::PathLinks`, `Table::GenericFilter`, `VHDL::ConstantEval`, and `MSOffice::Excel` now have no repo-owned legacy plugin caller left for their old registration names, so `plugin/string.plg`, `plugin/cgi.plg`, `plugin/genericfilter.plg`, `plugin/msoffice.plg`, and `plugin/vhdconst_eval.plg` have been removed. That is the healthier destination: normal package owner first, temporary `.plg` bridge only when a concrete remaining caller still needs it, then deletion. It is also a namespace guideline: when the extracted behavior has a clearer non-plugin/domain home, move it there instead of leaving it under `Plugin::*` just because it came from a `.plg` file.

The same point also applies to the package namespace itself. `Plugin::*` is a tactical migration scaffold, not a final taxonomy. The former `yesno.plg` prompt helper first moved into a package owner so the `.plg` file could disappear, then graduated immediately into `InteractivePrompt::yes_no(...)` because interactive prompting is a clearer domain than "plugin". The former `string.plg` substitution helpers now follow the same rule through `Text::VariableSubstitution` because variable substitution is text behavior, not plugin behavior. The former `cgi.plg` path-link helper now follows it through `HTML::PathLinks` because it renders HTML anchors for path tokens, not CGI behavior. The former HTTP helper/action owner now follows it through `HTTP::FileAccess` because it builds signed file-access URLs and local daemon actions, not plugin behavior. Future extractions should make the same judgment: keep `Plugin::*` only while the behavior genuinely belongs to plugin compatibility or has no clearer owner yet.

The HTTP migration shows the same distinction advancing from helper subdefs to real legacy actions. `HTTP::FileAccess` now owns `url_for_path`, `set_hostport`, `set_localhost`, the former `http` file-link action through `print_file_links_for_conf(...)`, the former `lighttpd` action through `run_lighttpd_for_conf(...)`, and the former Apache `httpd` action through `run_httpd_for_conf(...)`; `plugin/http.plg`, `plugin/lighttpd.plg`, and `plugin/httpd.plg` are gone. Repo-owned `.plg` callers now call `HTTP::FileAccess` directly for HTTP file-access behavior.

The FSMGen migration applies the same rule to dynamic plugin-list parsing rather than a private helper subdef. The old `plugin/fsmgen.plg::getop_plugin_list` compatibility entry is gone, and the parser now lives only in `FSMGen::getop_plugin_list(...)`. That owner preserves `+type=plugin#args...` bucket construction, the default `LinkedSpec::get_plugin(...)` resolver, and the unresolved-name no-op fallback without keeping a legacy helper wrapper in the shipped plugin corpus.

The QC summary migration shows the distinction inside a still-shipped legacy action. `plugin/qc_summary.plg` still exposes `qc_summary`, but its private row-merging helper is no longer a dynamic `qc_summary_merge` plugin subdef. `QC::Summary::append_merged_rows(...)` owns that behavior, and the legacy action calls it directly.

The QC flow migration starts the same cleanup inside a larger still-shipped legacy action. `plugin/qcflow.plg` still exposes `glc_xcel2hm`, but its private duplicate-suppressed qclog insertion helper is no longer a dynamic `qc_pushonce` plugin subdef, its budget-check callbacks are no longer dynamic `qc_budget_check` / `qc_budget_check_01match_code` subdefs, its filter-expression formatter is no longer a dynamic `qcflow_filter_handler` subdef, its clock CTS summary builder is no longer a dynamic `qcflow_clock_ctsinfo` subdef, its qclog workbook/link writer is no longer a dynamic `qcflow_links_n_qclog` subdef, and its qclog table preparer is no longer a dynamic `qcflow_qclogdata` subdef. `QC::Flow::push_once(...)`, `QC::Flow::budget_check(...)`, `QC::Flow::budget_check_single_or_zero_match(...)`, `QC::Flow::filter_handler(...)`, `QC::Flow::clock_cts_info(...)`, `QC::Flow::write_qclog_links(...)`, and `QC::Flow::prepare_qclog_data(...)` own that behavior, and the legacy action passes those package coderefs or direct package calls through the existing flow. `QC::TclInterconn::append_interconnect_tcl(...)`, `load_fanx(...)`, and `fanx_info(...)` now own the related Tcl/FANX helper bodies; `plugin/qcflow.plg` calls them directly, and the old standalone `plugin/tcl4interconn.plg` wrapper is gone now that no repo-owned caller still needs those legacy plugin names.

The setup/hold timing migration shows the same pattern across the former mixed legacy actions. `plugin/setup_hold_tmax_tmin.plg` still exposes `setup_hold_tmax_tmin`, but the obsolete `plugin/tssio.plg` wrapper is gone now that `Timing::SetupHold::write_tssio(...)` owns the visible `tssio` report/action body directly. The private timing helpers are no longer dynamic `DxCy`, `DiCi`, `DiCo`, `DoCi`, `DoCo`, `tss_setup_hold`, or `tss_tmax_tmin` plugin subdefs, and the `tssio` report body no longer lives in the legacy plugin file.

The STAN backend migration shows the same pattern for setup and formatting helpers inside visible legacy actions. `plugin/stan_backend.plg` still exposes visible report-timing actions, and `plugin/skew.plg` plus `plugin/duty_cycle_degradation.plg` still expose their visible actions, but the private `stan_backend_start` setup helper is no longer a dynamic plugin subdef, and `clockmatrix` no longer calls a same-file `minmax_clockmx_cellcode` helper. `Timing::StanBackend::start(...)` owns the launch banner, HTTP host/port setup, and `stan_backend_table2ss` configuration load directly; `Timing::StanBackend::clock_matrix_cell_code(...)` owns min/max slack sorting, first-100 path sheet allocation, and summary workbook link text.

The STAN OMAP migration shows the same pattern with a naming correction. `plugin/stan_omap2430c_backend.plg` still exposes visible actions such as `old_default` and `dm_measures`, and it still exposes `potential_fp`, `questionable_paths`, and `freqency_summary` as visible compatibility wrappers, but those actions no longer call private STA-frequency, frequency-detail, report-writer, TCK-delay, or no-path helpers through dynamic plugin names, and they no longer resolve the port-timing traversal callback through `LinkedSpec::get_plugin('portiming')`. `Timing::StanOmap2430cBackend` owns those callbacks directly under corrected function names, including `collect_sta_frequency(...)`, `write_potential_fp(...)`, `write_questionable_paths(...)`, `write_frequency_summary(...)`, `write_tck_delays(...)`, `write_no_path_check(...)`, `record_no_path_check(...)`, and `filter_port_timing_paths(...)`, while the package preserves historical LOF section strings and data keys where file compatibility matters.

The current direction is not to make dynamic plugin loading the identity of LinkedSpec. The healthier core story is:

```text
named .spec lookup
parser compilation
parser runtime
ActionIR helper semantics
structured diagnostics
```

## How to route a change

Use this practical map when deciding where work belongs:

- Public API wrapper or backward-compatibility facade: `LinkedSpec.pm`.
- File-oriented parser construction: `ParserFactory`.
- Spec-name validation, path resolution, and file loading: `Resolver`.
- Direct source compilation orchestration: `Runtime`.
- Shared runtime identity and structured errors: `RuntimeContext`.
- Compile-pipeline stage ownership: `Compiler`.
- Compiled state shape, metadata, and projection: `CompilerState`.
- `.spec` syntax bootstrap parsing: `BootstrapSpec::Core`.
- Early source validation and descriptor consistency validation: `Validation`.
- Per-rule handler source generation: `SpecEntry`.
- Rule-level intermediate representation: `RuleIR`.
- Action helper scanning/lowering bridge: `RuleIR::EmitContext`.
- Helper DSL contracts and backend-neutral lowering: `ActionIR::*`.
- Trace formatting and verbosity: `Trace`.
- Legacy plugin compatibility: `PluginRegistry`, `PluginBridge`, and `PPlugin`.

## Why this structure exists

The goal is to reduce monolithic behavior and make the system easier to reason about:

- narrower ownership boundaries
- clearer lazy-load behavior
- less duplicated wrapper logic
- more explicit state and validation seams

The current strongest boundaries are:

- the thin `LinkedSpec.pm` facade,
- the `ParserFactory -> Runtime -> Compiler` spine,
- the `RuntimeContext` structured state boundary,
- the `CompilerState` compiled-state owner,
- the `ActionIR::*` lowering subtree.

The current main hotspots are:

- `BootstrapSpec::Core`, because it owns dense bootstrap syntax behavior,
- `SpecEntry`, because generated Perl handler source and `eval` still define the current backend ceiling,
- the legacy plugin branch, because it remains publicly visible while no longer being the future architectural center.

For the denser implementation-maintenance snapshot, the repo's `ARCHITECTURE_STATE.md` remains the internal working companion to this public chapter.
