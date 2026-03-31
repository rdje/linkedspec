# MEMORY
Compact, actionable session memory for interruption-safe continuation.

- 2026-03-30: Started this new session from the bootstrap contract again: reread the README/doc entry set, refreshed the `LinkedSpec.pm` plus owner-tree reading, and lightly refreshed `ARCHITECTURE_STATE.md` because the 2026-03-30 deep pass confirmed the same thin-façade / `ParserFactory -> Runtime -> Compiler` spine with no material owner-tree shift. Future resume should keep treating `ARCHITECTURE_STATE.md` as the live owner-tree snapshot and refresh it again only when a new deep pass changes that model materially.
- 2026-03-30: Continued the Phase 4 helper-adoption line with another bounded `vhdl` live-spec spend. `specs/vhdl.spec::{entity_declaration,architecture_body,component_instantiation_statement}` now snapshot their lowercase header groups through `entry_groups()` plus `lowercase_each(...)` instead of raw `map {lc} @IMATCH_LIST`. One intermediate rewrite briefly dropped the old `return_a(...)`-style tagged/current-array payload shape and immediately broke the `vhdl_invariants_smoke` tag expectation; the final landed shape preserves that AST contract explicitly. Future resume should keep that migration rule in mind: when replacing raw `return_a(...)` list transforms, preserve the tagged return payload and current rule array shape, not only the helperized immediate-group read.

- 2026-03-29: Continued the Phase 4 helper-adoption line with another bounded `vhdl` spend. `specs/vhdl.spec::subprogram_declaration`, `subprogram_body`, and `type_declaration` now read their whole immediate-group lists through `entry_groups()` instead of `IMATCH_LIST` inside helper-style `flat_array(...)` returns. Future resume should keep live-spec whole-group-list reads on `entry_groups()` rather than `IMATCH_LIST` when helper returns already exist.
- 2026-03-29: Continued the Phase 4 helper-adoption line with another bounded `vhdl` spend. The package-name reads in `specs/vhdl.spec::package_declaration[1]` and `specs/vhdl.spec::package_body[1]` now read through `entry_group(0)` instead of `scalar(IMATCH_LIST, 0)`. Future resume should keep simple live-spec immediate-match positional-group reads on `entry_group(...)` rather than `IMATCH_LIST` indexing in migrated bands.
- 2026-03-28: Continued the Phase 4 helper-adoption line with another bounded live-spec token-reader spend. The top `comment` and `space` token readers in `specs/vhdl.spec` now read through `entry_text()` instead of raw `$IMATCH`. Future resume should keep simple live-spec immediate-match text reads on `entry_text()` rather than raw `$IMATCH`.
- 2026-03-28: Continued the Phase 4 helper-adoption line with another bounded live-spec token-reader spend. `specs/tkgui.spec::sub_gui` now reads its entry-point name through `entry_group(0)` instead of raw `@IMATCH_LIST` destructuring. Future resume should keep simple live-spec immediate-match scalar reads on `entry_text()` / `entry_group(...)` rather than raw `IMATCH` or `@IMATCH_LIST`.
- 2026-03-28: Continued the Phase 4 helper-adoption line with another bounded live-spec token-reader spend. The simple token-return seams in `specs/regdef.spec` now return through `entry_groups()` plus `flat_array(...)` instead of raw `@IMATCH_LIST`. Future resume should keep live-spec immediate-match group-list reads on `entry_groups()` rather than raw `@IMATCH_LIST`.
- 2026-03-28: Continued the Phase 4 helper-adoption line with one bounded live-spec token-reader spend. The simple token-reader rules in `specs/ds_vhistory.spec` now return through `entry_groups()` plus `flat_array(...)` instead of raw `@IMATCH_LIST`. Future resume should keep live-spec immediate-match group-list reads on `entry_groups()` rather than raw `@IMATCH_LIST`.

- 2026-03-28: Continued the Phase 4 helper-adoption line with one bounded live-spec spend. `specs/sdce.spec::sdc_esplit` now initializes its anonymous capture boundary with `start_capture_slice()` instead of direct `assign(s(IPOS), 0)` setup. Future resume should keep live-spec anonymous boundary initialization on `start_capture_slice()` rather than direct `IPOS` writes.

- 2026-03-28: Continued the Phase 4 named-checkpoint line in one bounded helper-surface slice. `mark_line(name)` is now the direct 1-based line-read companion to `mark_pos(name)`, so rules can report where a stored named checkpoint landed without round-tripping through raw newline counting from the numeric mark position. Future resume should keep named-checkpoint line reads on `mark_line(name)` instead of reintroducing raw prefix-newline counting around `mark_pos(...)`.

- 2026-03-28: Continued the Phase 4 anonymous capture-boundary line in one bounded helper-surface slice. `capture_slice_pos()` is now the direct numeric read helper for the current anonymous capture boundary, so the honest preferred pair is now `start_capture_slice()` to move that boundary and `capture_slice_pos()` to read it back. Future resume should keep new direct anonymous-boundary position reads on `capture_slice_pos()` rather than raw `$IPOS`.

- 2026-03-28: Added `SESSION_BOOTSTRAP.md` and appended the explicit final-line handoff in `README.md`: `Read SESSION_BOOTSTRAP.md and start from there.` Future resume should treat `SESSION_BOOTSTRAP.md` as the first-task contract for a new session before doing anything else.

- 2026-03-28: Refreshed `ARCHITECTURE_STATE.md` after a new deep doc-plus-code pass. Current best reading stays: `LinkedSpec.pm` is a thin façade over `OwnerDispatch`, `ParserFactory` is the real named `.spec` resolution owner, `RuntimeContext` is still the strongest shared-state seam, and the legacy plugin branch still forms a lazy compatibility cycle through `PluginBridge`, `PPlugin`, and `LinkedSpec::get_parser('pplugin')`. Future resume should reuse that owner-tree reading rather than overfocusing on the shallow static import list.
- 2026-03-28: Continued the Phase 4 helper-adoption line in one bounded live-spec slice. The remaining obvious raw live-cursor and anonymous capture-boundary reads in `specs/vhdl.spec` now spend `cursor_pos()`, `capture_slice()`, and `start_capture_slice()` directly instead of raw `pos $$STRING`, raw anonymous-boundary `substr(...)`, and direct `assign(scalar(IPOS), pos $$STRING)`. Future resume should keep obvious same-shape VHDL-style cursor/boundary flows on the current helper family before inventing more helper spellings.

- 2026-03-28: Continued the Phase 4 anonymous capture-boundary spend line in one bounded live-spec slice. `specs/tkgui.spec::sub_gui`, `specs/hlink_substitution.spec::{substitute_statement2,curlyb}`, and the obvious delimiter-reader return/debug bands in `specs/simenv.spec` now spend `capture_slice()` directly instead of raw anonymous-boundary `substr($$STRING, $IPOS, $LSPOS - $IPOS - ...)` reads. Future resume should keep using `capture_slice()` for that simple “current anonymous capture body” case before inventing more helper spellings.

- 2026-03-28: Continued the Phase 4 anonymous capture-boundary line in one bounded slice. `capture_slice_line()` is now the first-class helper for reporting the 1-based line of the current anonymous capture boundary, and `specs/simenv.spec` now spends it in the repeated unmatched-delimiter LX diagnostics instead of raw prefix-newline counting from `$IPOS`. Future resume should keep anonymous capture-boundary line reporting on `capture_slice_line()` rather than raw `substr($$STRING, 0, $IPOS) =~ /\n/g`.

- 2026-03-28: Continued the Phase 4 anonymous capture-boundary line in one coherent slice. The preferred explicit lifecycle/action-block write helper is now `start_capture_slice()` and the new explicit tail readers are `capture_rest()` / `capture_rest_len()`. `capture_slice_here()` stays supported only as a compatibility alias because it misleadingly sounded like a read helper. Future resume should keep new live spends on `start_capture_slice()` plus `capture_rest()` / `capture_rest_len()` rather than on raw `assign(s(IPOS), cursor_pos())` or raw tail `substr(...)`.

- 2026-03-28: Continued the Phase 5 diagnostics-continuity line in one bounded runtime-context slice. Structured `runtime_ctx->{last_error}` payloads now also carry `top_rule` when the shared runtime context already knows the selected parser entrypoint, so runtime/parser failures are more self-contained and callers no longer have to recover parser identity from separate context fields. Future resume should treat `top_rule` as part of the structured diagnostics contract alongside `owner_stage`, `spec_name`, and `spec_path`.

- 2026-03-28: Continued the remaining Phase 1A compatibility-wrapper cleanup in one bounded slice. `LinkedSpec::ActionRewriter::_delegate_emit_context_call(...)` now routes directly through `LinkedSpec::OwnerDispatch::dispatch_owner_call(...)` into `LinkedSpec::RuleIR::EmitContext`, so that legacy compatibility owner no longer carries a second local lazy-load / `can(...)` / symbol-call implementation on top of the shared owner-dispatch seam. Future resume should keep `ActionRewriter` shrinking toward a thin compatibility map over `EmitContext`, not as a separate delegation style.

- 2026-03-28: Continued the same Phase 5 runtime-owner cleanup line in a bounded way. `Runtime.pm`, `Compiler.pm`, and `SpecEntry.pm` now route their private `RuntimeContext` helper calls through the same shared `LinkedSpec::OwnerDispatch::dispatch_owner_call(...)` seam that `ParserFactory.pm` already used, so the active runtime/compile owners no longer carry a second local lazy-load-plus-symbol-call implementation for shared runtime-context dispatch. Future resume should keep runtime-context delegation on that one shared owner-dispatch shape instead of reintroducing ad hoc local wrappers.

- 2026-03-28: Preferred anonymous capture-boundary naming is now `@capture_slice`, `capture_slice()`, and `capture_slice_len()`. Older spellings `@capture_from_here`, `@move_pos`, `capture_slice_length()`, `capture_from_rule_start()`, and `capture_len_from_rule_start()` are now compatibility aliases only. Future resume should treat the `capture_slice*` names as the honest description of the mutable `$IPOS` capture-boundary semantics and keep new live spends on those names.
- 2026-03-27: Added `capture_from_rule_start()` and `capture_len_from_rule_start()` as first-class Phase 4 helpers for the common direct rule-entry span read pattern. `specs/sdce.spec` now spends `capture_from_rule_start()` in its split bands, and future resume should treat these helpers as the preferred backend-neutral replacement for raw `$IPOS`-anchored capture substrings when no named mark is needed.
- 2026-03-27: Corrected `cursor_line()` so it now reads the live parser cursor line from `pos $$STRING` instead of the stale rule-entry `$IPOS` snapshot. Future resume should treat `cursor_line()` as a true same-rule moving cursor helper and keep that runtime contract locked with both rewrite-level and parser-runtime coverage.
- 2026-03-27: Added `cursor_pos()` as a first-class Phase 4 helper for direct current parser-position reads, with full contract/scanner/canonical lowering support and one live spend in `specs/sdce.spec`. Future resume should treat `cursor_pos()` as the preferred backend-neutral replacement for raw `pos $$STRING` when a rule wants the current parser position as data without storing a named mark first.
- 2026-03-27: `LinkedSpec::OwnerDispatch` now also owns a shared `build_dep_bundle(...)` helper for mixed callback/value dependency bundles, and `ParserFactory.pm` now uses that seam for its default trace/resolve/compile callback plus trace dump-level value bundle. Future resume should treat shared mixed dep-bundle assembly as the preferred direction for the remaining parser-core compatibility seams instead of letting active compile-path owners hand-build another mixed registry inline.
- 2026-03-27: The shared `LinkedSpec::OwnerDispatch::build_dep_map(...)` seam now also covers the remaining secondary ActionIR owners `ArrayPipeline`, `ControlFlow`, `Contracts`, `RewritePipeline`, `Diagnostics`, `StatementSplit`, `CanonicalEvents`, and `Scanner`. Future resume should treat broad default callback-map centralization as the normal ActionIR pattern now, with `ScannerCore` still defining the scanner-specific dep contract underneath.
- 2026-03-27: `LinkedSpec::OwnerDispatch` now also owns shared ActionIR dep-map assembly through `build_dep_map(...)`, and the core lowering owners `FlowExpr`, `ValueExpr`, `MethodLowering`, and `DeclareMethod` now use that seam for `default_deps_for_package(...)`. Future resume should treat shared dep-map assembly as the preferred direction for active ActionIR owner callback maps.
- 2026-03-27: `LinkedSpec::RuleIR::EmitContext` now centralizes its internal ActionIR owner registry and owner default-dependency lookup behind shared local helpers. Future resume should treat that bridge registry as the current single source of truth for EmitContext-owned ActionIR package/dependency wiring instead of reintroducing per-wrapper duplication.
- 2026-03-27: Broadened parser-oriented list-context insertion helpers `flat_array(...)` / `flat_hash(...)` so they now accept composed aggregate helper expressions too, not only one named working array/hash. Future resume should treat list-context constructor splicing and direct `return(payload)` flattening as available over helpers such as `sorted_keys(...)`, `sorted_values(...)`, `pick_keys(...)`, and `hash_copy(...)` without introducing temporary working variables first.
- 2026-03-27: Added parser-oriented pure hash/object snapshot helper `hash_copy(...)`, so `.spec` rules can now keep one stable copied hash/object value from direct working hashes or composed hash-valued expressions inside assignment sources, nested scalar/hash composition, aggregate emptiness checks, and direct `return(payload)` expressions. Future resume should treat `hash_copy(...)` as the preferred object-snapshot spelling, analogous to `array_copy(...)` for arrays.
- 2026-03-27: `LinkedSpec::SpecEntry` and `LinkedSpec::RuleIR` now route `Data::Dumper` loading through their existing shared package-loading seam instead of keeping direct bare `require Data::Dumper` helpers. Future resume should treat those rule-compilation owners as aligned with the broader owner-dispatch cleanup now.
- 2026-03-27: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::Trace`, so that active trace owner now uses the same shared `Data::Dumper` loading and eval-error-preservation seam as the reduced compile-path owners. Future resume should treat Trace as covered by that same owner-dispatch cleanup line now.
- 2026-03-27: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::BootstrapSpec::Core`, so that active bootstrap grammar core owner now uses the same shared package-loading and eval-error-preservation seam as the reduced compile-path owners. Future resume should treat BootstrapSpec::Core as covered by that same owner-dispatch cleanup line now.
- 2026-03-27: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::StatementSplit::Core`, so that active ActionIR statement-split core owner now uses the same shared package-loading seam as the reduced compile-path owners. Future resume should treat StatementSplit::Core as covered by that same owner-dispatch cleanup line now.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::ScannerCore`, so that active ActionIR scanner-core owner now uses the same shared package-loading seam as the reduced compile-path owners. Future resume should treat ScannerCore as covered by that same owner-dispatch cleanup line now.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::DeclareMethod`, so that active ActionIR declare/assign owner now uses the same shared package-loading, callback-lookup, and eval-error-preservation seam as the reduced compile-path owners. Future resume should treat DeclareMethod as covered by that same owner-dispatch cleanup line now.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::MethodLowering`, so that active ActionIR lowering owner now uses the same shared package-loading, callback-lookup, and eval-error-preservation seam as the reduced compile-path owners. Future resume should treat MethodLowering as covered by that same owner-dispatch cleanup line now.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::Contracts`, so that active ActionIR owner now uses the same shared package-loading, callback-lookup, and eval-error-preservation seam as the reduced compile-path owners. Future resume should treat Contracts as covered by that same owner-dispatch cleanup line now.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::ControlFlow`, so that active ActionIR owner now uses the same shared package-loading, callback-lookup, and eval-error-preservation seam as the reduced compile-path owners. Future resume should treat ControlFlow as covered by that same owner-dispatch cleanup line now.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::ArrayPipeline`, so that active ActionIR owner now uses the same shared package-loading, callback-lookup, and eval-error-preservation seam as the reduced compile-path owners. Future resume should treat ArrayPipeline as covered by that same owner-dispatch cleanup line now.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::FlowExpr`, so that active ActionIR owner now uses the same shared package-loading, callback-lookup, and eval-error-preservation seam as the reduced compile-path owners. Future resume should treat FlowExpr as covered by that same owner-dispatch cleanup line now.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::ValueExpr`, so that active ActionIR owner now uses the same shared package-loading, callback-lookup, and eval-error-preservation seam as the reduced compile-path owners. Future resume should treat ValueExpr as covered by that same owner-dispatch cleanup line now.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::Diagnostics`, so that active ActionIR owner now uses the same shared package-loading, callback-lookup, and eval-error-preservation seam as the reduced compile-path owners. Future resume should treat Diagnostics as covered by that same owner-dispatch cleanup line now.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::CanonicalEvents`, so that active ActionIR owner now uses the same shared package-loading, callback-lookup, and eval-error-preservation seam as the reduced compile-path owners. Future resume should treat CanonicalEvents as covered by that same owner-dispatch cleanup line now.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::StatementSplit`, so that active ActionIR owner now uses the same shared package-loading, callback-lookup, and eval-error-preservation seam as the reduced compile-path owners. Future resume should treat StatementSplit as covered by that same owner-dispatch cleanup line now.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::Scanner`, so that active ActionIR owner now uses the same shared package-loading, callback-lookup, and eval-error-preservation seam as the reduced compile-path owners. Future resume should treat Scanner as covered by that same owner-dispatch cleanup line now.
- 2026-03-26: Extended `LinkedSpec::OwnerDispatch` into `LinkedSpec::ActionIR::RewritePipeline`, so that active ActionIR owner now uses the same shared package-loading, callback-lookup, and eval-error-preservation seam as the reduced compile-path owners. Future resume should treat RewritePipeline as covered by that same owner-dispatch cleanup line now.
- 2026-03-25: Extended `LinkedSpec::OwnerDispatch` into `RuleIR::EmitContext`, so the RuleIR-to-ActionIR bridge owner now uses the same shared package-loading and eval-error-preservation seam as the other reduced thin wrappers. Future resume should treat EmitContext as covered by that same owner-dispatch cleanup line now.
- 2026-03-25: Extended `LinkedSpec::OwnerDispatch` into `SpecEntry.pm`, so the rule-entry compile owner now uses the same shared package-loading and eval-error-preservation seam as the other reduced thin wrappers. Future resume should treat SpecEntry as covered by that same owner-dispatch cleanup line now.
- 2026-03-25: Extended `LinkedSpec::OwnerDispatch` into `RuleIR.pm`, so the rule-planning owner now uses the same shared package-loading and eval-error-preservation seam as the other reduced thin wrappers. Future resume should treat RuleIR as covered by that same owner-dispatch cleanup line now.
- 2026-03-25: Extended `LinkedSpec::OwnerDispatch` into `Compiler.pm`, so the compile-pipeline owner now uses the same shared package-loading and eval-error-preservation seam as the other reduced thin wrappers. Future resume should treat Compiler as covered by that same owner-dispatch cleanup line now.
- 2026-03-25: Extended `LinkedSpec::OwnerDispatch` into `Resolver.pm` and `Validation.pm`, so the active parser/frontend trace-wrapper seam now uses the same shared Trace-loading and eval-error-preservation helper as the other reduced thin wrappers. Future resume should treat those two modules as covered by the same owner-dispatch cleanup line now.
- 2026-03-25: Extended `LinkedSpec::OwnerDispatch` into `BootstrapSpec.pm`, so the hardcoded bootstrap owner now uses the same shared package-loading and eval-error-preservation seam as the other active compile-path thin wrappers. Future resume should treat BootstrapSpec as covered by that same owner-dispatch cleanup line now.
- 2026-03-25: Extended the new `LinkedSpec::OwnerDispatch` seam into `ParserFactory.pm`. The shared helper now owns callback/value lookup there too, and `ParserFactory::_call_runtime_ctx(...)` now routes through the same shared owner-dispatch helper. Future resume should keep pushing any remaining thin compile-path wrapper plumbing toward `OwnerDispatch` instead of adding one more local helper copy.
- 2026-03-25: Continued the remaining Phase 1A / Backbone Item 3 cleanup by adding `LinkedSpec::OwnerDispatch` as the shared owner-dispatch seam. `LinkedSpec.pm`, `Runtime.pm`, and `ActionRewriter.pm` now all route thin-wrapper lazy loading plus `$@` preservation through that helper instead of each carrying a local copy. Future resume should keep using `OwnerDispatch` when another thin compatibility wrapper still needs that pattern, rather than cloning the same scaffolding again.
- 2026-03-25: Continued Phase 2 frontend hardening by rejecting stray unmatched top-level closing delimiters inside rule paragraphs during `validate_dsl_syntax(...)`. Validation now reports an explicit early diagnostic for malformed `}` / `)` / `]` balance errors, and the slice also corrected one malformed fluent lifecycle regression fixture that had an extra `)` and had previously passed only because validation was looser.
- 2026-03-25: Continued the package-backed HTTP extraction. `Plugin::HTTP` now owns `set_http_hostport(...)` and `set_http_localhost(...)` in addition to `httplink(...)`, `lighttpd.plg` now keeps only thin compatibility wrappers for those helper subdefs, and `Plugin::String::var_subst_test(...)` now calls `Plugin::HTTP` plus `Plugin::CGI` directly instead of routing already-extracted helpers through `LinkedSpec::run_plugin(...)`. Future resume should keep collapsing those leftover transition hops whenever the destination package owner is already clear.
- 2026-03-25: Continued the plugin-removal line by extracting `httplink(...)` into `Plugin::HTTP`. `http.plg` now keeps only the thin compatibility wrapper for that helper, while direct Perl callers such as `TableScript::http_exec(...)` and `Plugin::CGI::file_list_path2http(...)` now call `Plugin::HTTP::httplink(...)` directly instead of bouncing back through `LinkedSpec::run_plugin(...)`. Future resume should keep pushing shared helper bodies into normal package owners and prefer direct package calls from Perl code whenever compatibility wrappers are no longer needed.
- 2026-03-25: Added `ARCHITECTURE_STATE.md` as the dedicated live architecture snapshot. It now holds the current deep reading of `LinkedSpec.pm`, the owner tree, the main compile/runtime spine, the ActionIR boundary, the legacy plugin branch, and the biggest current architectural hotspots. Future resume should re-read and refresh that file at session start whenever the architectural picture has shifted materially, instead of letting the analysis live only in chat history.
- 2026-03-25: Tightened the standing commit workflow rules. `COMMIT.md` no longer asks for the stale automatic `Co-Authored-By: Oz <oz-agent@warp.dev>` line, and `MEMORY.md` is now an explicit required update for every accepted implementation slice alongside `CHANGES.md` and `DEVELOPMENT_NOTES.md`. Future resume should treat `MEMORY.md` updates as mandatory continuity work because this file is the crash/session-loss recovery log.
- 2026-03-25: Corrected the first extracted package owners so they no longer live under `LinkedSpec/Plugin/`. The real owners now live in `Plugin::String` and `Plugin::CGI`, the old `LinkedSpec::Plugin::*` files have been deleted, and the thin `.plg` wrappers now point at the external `Plugin::*` namespace instead. Future resume should keep extracted executable helper bodies outside `LinkedSpec::*` while continuing to retire dynamic `.plg` loading.
- 2026-03-25: Captured a stronger architecture decision for future resume. LinkedSpec should keep spec-name resolution by asking for `foobar` and locating `foobar.spec`, but it does not need dynamic plugin loading as a framework capability. Future resume should treat plugin loading/execution as legacy removal territory, not as a feature family to preserve under a new namespace.
- 2026-03-25: Continued the actual package-backed extraction line for future resume. `LinkedSpec::Plugin::CGI` now owns the old `cgi.plg` logic, `cgi.plg` is reduced to a thin compatibility wrapper, and the new package owner keeps its still-legacy `httplink` dependency explicit through `LinkedSpec::run_plugin(...)`. Future resume should use this as the reference pattern when an extracted package still depends on another plugin helper that has not been package-extracted yet.
- 2026-03-24: Captured a namespace-policy clarification for future plugin extraction work. `LinkedSpec::Plugin::*` should be treated as a migration namespace for package-backed compatibility extractions and plugin-runtime transition code, not as an automatic forever-home for every former `.plg`. Future resume should feel free to move extracted domain logic into a different explicit namespace or ordinary library module when that is the cleaner long-term home.
- 2026-03-24: Started the first actual package-backed `.plg` extraction for future resume. `LinkedSpec::Plugin::String` now owns the old `string.plg` logic, `string.plg` is reduced to thin compatibility wrappers, and `cgi.plg` now calls `LinkedSpec::Plugin::String::var_subst(...)` directly. Future resume should use this as the reference migration shape for other small `.plg` files: move logic into a package owner first, then keep or delete the wrapper based on whether compatibility is still needed.
- 2026-03-24: Captured the intended `.plg` endgame for future resume. Retiring `.plg` does mean moving current executable behavior into `.pm` package ownership first, but not every `.plg` needs to survive as a permanent one-for-one `.pm` wrapper. The intended migration path is: move logic into explicit packages, register or call it explicitly, then simplify or delete old wrapper-shaped plugin files once they no longer add value.
- 2026-03-24: Continued the plugin/runtime modernization track by retiring repo-owned use of the legacy `_get_parser(...)` helper plugin. `Lispish.pm` now uses `LinkedSpec::get_parser('Lispish')` directly, and the remaining repo-owned `.plg` callers (`ds_vhistory.plg`, `fsmgen.plg`, and `regtest.plg`) now do the same. Future resume should treat `plugin/spec.plg::_get_parser` as compatibility-only surface for older external callers, not as the preferred parser-lookup path for repo-owned code.
- 2026-03-24: Continued the plugin/runtime modernization track by spending public plugin lookup inside smaller repo-owned plugin files. `qc_summary.plg` now uses `LinkedSpec::get_plugin('qc_summary_merge')`, and `skew.plg` now uses `LinkedSpec::get_plugin('stan_backend_start')`, instead of direct `PPlugin->get(...)`. Future resume should keep migrating repo-owned `.plg` files with known plugin names toward `get_plugin(...)` or `run_plugin(...)` depending on whether they need a coderef or immediate execution.
- 2026-03-24: Continued the plugin/runtime modernization track inside lightweight repo-owned plugin files. `regtest.plg` now uses `LinkedSpec::run_plugin('hvalue_substitute', ...)` instead of instantiating `PPlugin`, and `string.plg` now uses `LinkedSpec::run_plugin('file_list_path2http', ...)` instead of `PPlugin->exec_plugin_name(...)`. Future resume should keep steering repo-owned `.plg` files with known plugin names toward `run_plugin(...)`, leaving dynamic `plugin { PPlugin->get(...) }`-style compatibility surfaces for later.
- 2026-03-24: Continued the plugin/runtime modernization track by removing stale repo-owned `PPlugin` inheritance. `RTLUtils.pm` and `LispML.pm` no longer advertise `PPlugin` in `@ISA`, and require-only regression coverage now locks that neither module eager-loads the legacy runtime. Future resume should treat remaining repo-owned `PPlugin` inheritance as suspicious unless the package is still intentionally acting as a compatibility plugin adapter.
- 2026-03-24: Logged a repo-wide Perl documentation convention for future resume. Touched Perl packages should get a short package-level purpose block plus per-routine Perl-style doc blocks (`Function`, `Purpose`, `Args`, `Returns`). The first backfill slice now covers `LinkedSpec.pm`, `LinkedSpec::PluginBridge`, `LinkedSpec::PluginRegistry`, `PPlugin`, and `TableSort`; future resume should keep extending that convention incrementally in packages we actively edit instead of attempting one huge repo-wide comment churn pass.
- 2026-03-24: Continued the plugin/runtime modernization track by adding `LinkedSpec::get_plugin(name)` as the public handler-lookup companion to `run_plugin(name, @args)`. `LinkedSpec::PluginBridge` now owns `_lookup_plugin_name(...)` and `_get_legacy_plugin(...)`, and `TableSort::GenericFilter(...)` now uses `LinkedSpec::get_plugin(...)` instead of `PPlugin->get(...)`. Future resume should use `get_plugin(...)` for callers that need a plugin coderef rather than immediate execution.
- 2026-03-24: Continued the plugin/runtime modernization track by adding `LinkedSpec::dispatch_plugin_autoload_name($autoload_name, @args)` as a public compatibility handoff for legacy module-owned AUTOLOAD shims. `FSMGen.pm` now uses that helper instead of calling `PPlugin->exec(...)` directly, and the regression suite now locks that `FSMGen::AUTOLOAD` avoids the legacy mixed-name PPlugin wrapper. Future resume should use this helper only for transition-era AUTOLOAD shims; explicit-name callers should still prefer `run_plugin(...)`.
- 2026-03-24: Continued the plugin/runtime modernization track by spending the public explicit dispatch API in repo-owned callers that already know their plugin names. `HUtils::GenericFilter(...)`, `TableScript::http_exec(...)`, and the header-generation paths in `RTLUtils` now call `LinkedSpec::run_plugin(...)` directly, with regression locks proving those paths avoid `PPlugin` dispatch. Future resume should keep steering repo-owned explicit-name callers toward `run_plugin(...)`, leaving `PPlugin.pm` as compatibility/runtime fallback only.
- 2026-03-24: Logged the historical motivation behind `.plg` for future resume. The original value was low-ceremony discovered extension code, not plugin magic for its own sake: drop helper logic into a lightweight file, let the framework locate it, parse it, and return executable `sub { ... }` payloads without `.pm` / `.pl` packaging ceremony or explicit path management. Future replacement work should preserve that low-friction extensibility while removing the "magical" `AUTOLOAD`-driven mixing of discovery, parsing, caching, and execution.
- 2026-03-24: Continued the plugin/runtime modernization track with a public explicit dispatch entrypoint. LinkedSpec now exposes `run_plugin(name, @args)` as the preferred plugin-call surface, and it reuses the same `PluginBridge` explicit-name owner path as the compatibility autoload bridge. Future resume should treat `run_plugin(...)` as the first-class non-`AUTOLOAD` plugin API.
- 2026-03-24: Locked the intended plugin architecture direction for future resume. `AUTOLOAD` is transition-only, not the desired long-term primary plugin API. `.plg` loading and `PPlugin.pm` remain legacy compatibility fallback only; future work should add explicit plugin dispatch and then retire those compatibility layers after parity.
- 2026-03-24: Started the plugin/runtime modernization track in a more explicit way. LinkedSpec now has a real `PluginRegistry` owner plus public `register_plugin(...)` / `register_plugins(...)` / `clear_registered_plugins()` entrypoints, and `PluginBridge` now checks that registry before loading the legacy `.plg` runtime. Future resume should treat that as the new first-class explicit plugin seam while leaving `.plg` fallback intact until later migration.
- 2026-03-24: Pivoted from another token-reader helper-spend to a more semantic Phase 4 slice. Explicit `cursor_line()` / `entry_line()` / `match_line()` helpers now expose 1-based parser-state line numbers directly, and `specs/simenv.spec::begin_end_blocks` now spends `cursor_line()` / `match_line()` in its begin/end diagnostics instead of raw prefix-newline counting.
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
- 2026-03-24: Spent the new concise `s(...)` / `a(...)` aliases on a real core grammar too. The main orchestration and terminal-reader band in `specs/ebnf.spec` now prefers `s(...)` / `a(...)`, and a focused source-level regression now locks that migration intent while the existing `ebnf` descriptor/runtime tests continue to lock behavior.
- 2026-03-24: Added concise DSL container aliases `s(...)` / `a(...)` / `h(...)` as exact short spellings for `scalar(...)` / `array(...)` / `hash(...)`. This is intentionally only DSL shorthand, not Perl-sigil syntax. Lowering/tests now cover assignment targets, constructor values, container reads like `count(a(parts))`, and hash access like `has_key(h(meta), ...)`.
- 2026-03-24: Kept spending the newer Phase 4 immediate-match helper surface on real specs after the `portmap` slice too. The compact token-reader band in `specs/Lispish.spec` now uses `entry_text()` / `entry_group(0)` instead of `scalar(IMATCH)` / `scalar(IMATCH_LIST, 0)`, and the existing `lispish_small_helper_flow_eliminates_raw_fallback` plus `lispish_ast_smoke` regressions were already enough to lock the preserved token payload/runtime behavior for future resume work.
- 2026-03-24: Continued spending the Phase 4 helper surface on real specs after the `lib_reader` slice too. `specs/portmap.spec::bare_bit_slice` now uses `entry_text()` / `entry_group(...)` / `entry_groups()` instead of `scalar(IMATCH)` / `scalar(IMATCH_LIST, ...)` / `flat_array(IMATCH_LIST)`, and the existing `portmap` metadata plus runtime smoke regressions still lock the preserved `bare` / `bit` / `slice` / `constant` behavior for future resume work.
- 2026-03-24: Continued spending the Phase 4 helper surface on real specs after the `ebnf` token-reader slice. The grouped entry-reader band in `specs/lib_reader.spec` now uses `entry_group(0)` / `entry_group(1)` instead of `scalar(IMATCH_LIST, ...)`, and the regression suite now locks one representative `lib_reader` runtime parse so future resume work can keep migrating live specs while preserving AST shape.
- 2026-03-24: Began using the newer Phase 4 immediate-match helper surface in a live core grammar. The simple terminal-reader band in `specs/ebnf.spec` now uses `entry_text()` / `entry_group(0)` plus helper-method cleanup instead of raw `$IMATCH` reads, and the regression suite now locks those token rules as language-agnostic-ready so future resume work can keep migrating real specs, not just the helper catalog.
- 2026-03-23: Extended the Phase 4 named-capture read surface again so future resume work can see the next intended shape clearly. `entry_has(name)` and `match_has(name)` now answer the common immediate/local named-capture presence question directly, without forcing rules through `has_key(entry_map(), ...)` or `has_key(match_map(), ...)` when the whole hash is not otherwise needed.
- 2026-03-23: Refined the Phase 4 named-capture-hash surface so `entry_map()` / `match_map()` are now the preferred short spellings, while `entry_named_map()` / `match_named_map()` remain supported compatibility aliases. The hash-lowering path recognizes both pairs equally.
- 2026-03-23: Extended Phase 4 so full positional capture-group lists now have explicit backend-neutral read helpers too. `entry_groups()` and `match_groups()` now snapshot the current immediate/local capture-group lists without raw `array(IMATCH_LIST)` / `array(LMATCH_LIST)` spellings in normal user-facing `.spec` examples.
- 2026-03-23: Extended Phase 4 so full named-capture hashes now have explicit backend-neutral read helpers too. `entry_named_map()` and `match_named_map()` now snapshot the current immediate/local named-capture hashes without raw `%IMATCH_HASH` / `%LMATCH_HASH` access, and the hash-lowering path now treats those helpers as real hash-valued expressions instead of rewrite-only surfaces.
- 2026-03-23: Extended Phase 4 so named regex captures now have explicit backend-neutral read helpers too. `entry_named(name)` and `match_named(name)` now cover immediate/local named-capture hash reads without raw `%IMATCH_HASH` / `%LMATCH_HASH` access, and `specs/pplugin.spec` now uses `entry_named(subname)` as the first migrated live use-site of that surface.
- 2026-03-20: Added explicit blind-call fluent post-call chaining as supported surface. `=> Rule.method(...)` and `=> Rule .method(...).method2(...)` now lower as sugar over the existing post-call `=> Rule { ... }` form, while `validate_dsl_syntax(...)` now rejects only malformed blind-call fluent starts such as `=> Rule.` or `=> Rule..return_a()` instead of rejecting blind-call fluent continuations outright.
- 2026-03-20: Extended Phase 2 frontend hardening so malformed action-edge fluent starts are rejected during `validate_dsl_syntax(...)` too. Validation now reports an early targeted diagnostic for empty method hops like `-> Rule.` and `-> Rule..push(...)`, instead of leaving those malformed fluent continuations to later bootstrap parse failure.
- 2026-03-20: Extended Phase 2 frontend hardening so rule paragraphs with open `{`, `(`, or `[` constructs are rejected at EOF during `validate_dsl_syntax(...)`. Validation now reports an explicit early “unclosed rule block” diagnostic instead of silently accepting unfinished open blocks at the end of the spec.
- 2026-03-19: Extended Phase 2 frontend hardening so rule-start detection stays top-level only inside open action/lifecycle/code blocks. Validation now keeps label-like lines such as `label:` inside open `{ ... }` blocks as block content instead of misclassifying them as new rule paragraphs, and the regex-token validation pass now follows that same block-depth boundary.
- 2026-03-19: Extended Phase 2 frontend hardening so malformed glued edge-target suffixes are rejected during `validate_dsl_syntax(...)` too. Validation now treats forms like `-> Rule-extra` and `=> Rule-extra` as invalid edge-target syntax instead of prefix-parsing them as `Rule`, while still preserving supported action-edge fluent suffixes and the separate indexed blind-call diagnostic for `=> Rule[0]`.
- 2026-03-19: Extended Phase 2 frontend hardening so malformed `@...` split-marker spellings are rejected during `validate_dsl_syntax(...)` too. Validation now gives a targeted early diagnostic for unknown split-boundary markers on both top-level rule-paragraph lines and same-line rule headers, while keeping `@capture_from_here` and compatibility alias `@move_pos` as the only supported spellings.
- 2026-03-19: Extended Phase 2 frontend hardening so same-line rule headers reject unsupported filler after the rule start or after a leading same-line regex cluster. Validation now rejects shapes like `Top:: random garbage` and `Top:: /a/ random garbage` earlier, and the validation-side regex literal matcher now handles escaped-slash literals like `/\/.+\//` correctly while those same-line checks run.
- 2026-03-19: Extended Phase 2 frontend hardening so unsupported top-level garbage inside a rule paragraph is rejected during `validate_dsl_syntax(...)` too. The validator now distinguishes between true paragraph-member freedom and arbitrary text: at top level inside a rule paragraph, supported starts remain regexes, lifecycle/code blocks, action edges, blind calls, split markers, multiline fluent continuation lines, or the next rule start.
- 2026-03-19: Extended Phase 2 frontend hardening so stray preamble text before the first rule paragraph is rejected during both `validate_spec_content(...)` and `validate_dsl_syntax(...)`. Validation now enforces the documented paragraph-based file contract more literally: after leading blank lines and `#` comments, the first real line must be a supported rule start.
- 2026-03-19: Extended Phase 2 frontend hardening so malformed glued worded rule-mode suffixes are rejected during `validate_dsl_syntax(...)` too. Validation now treats forms like `RuleName:ORX` and `RuleName::ANDX` as invalid rule-label syntax instead of accepting them as prefix matches on supported worded modes, and focused regression coverage now locks that early diagnostic.
- 2026-03-19: Extended Phase 2 frontend hardening so malformed extra-colon rule starts are rejected during `validate_dsl_syntax(...)` too. Validation now treats forms like `RuleName:::` as invalid rule-label syntax instead of letting them drift into later bootstrap parse failure, and focused regression coverage now locks that early diagnostic.
- 2026-03-19: Extended Phase 2 frontend hardening so missing top-level edge targets are rejected during `validate_dsl_syntax(...)` too. Validation now reports early targeted diagnostics for malformed forms like `-> { ... }` and `=> { ... }`, instead of letting incomplete action-edge or blind-call arrows fall through to generic bootstrap parse failure.
- 2026-03-19: Extended Phase 2 frontend hardening so malformed top-level edge-target syntax is rejected during `validate_dsl_syntax(...)` too. Validation now rejects malformed action-edge slot forms like `-> Rule[]` / `-> Rule[abc]`, rejects indexed blind-call targets like `=> Rule[0]`, and keeps those checks top-level aware so action-code strings and nested code do not get misread as real edges.
- 2026-03-19: Extended the first Phase 2 frontend-hardening pass so mixed `->` / `=>` rule paragraphs are rejected during `validate_dsl_syntax(...)` instead of only later in RuleIR. Validation now tracks edge families per rule paragraph, keeps the established mixed-edge diagnostic/guidance text, and regression coverage now locks both multiline and same-line mixed-edge rejection before bootstrap parse.
- 2026-03-19: Started Phase 2 frontend hardening with stricter rule-paragraph regex validation. `validate_dsl_syntax(...)` now checks leading regex tokens on both multiline and same-line rule paragraphs, regression coverage now locks current packed paragraph acceptance plus malformed-regex rejection before bootstrap parse, and the roadmap Phase 2 row now moves to `in progress`.
- 2026-03-19: Locked same-line rule paragraphs as explicit supported format. Representative action-rule and blind-call examples are now regression-covered in both multiline and same-line layout, and the user guide now states plainly that same-line packing is still just the same paragraph model rather than a different sublanguage.
- 2026-03-19: Locked the open-ended regex-slot indexing contract more explicitly. Regression coverage now proves that action-edge indexing continues through a representative four-regex rule (`-> A[3]` targeting the fourth regex), and the user guide now states plainly that the regex-slot model is not artificially capped at one, two, or three entries.
- 2026-03-19: Locked the paragraph-based `.spec` rule-body contract in docs/tests. Representative action-rule and blind-call rule paragraphs now prove that after the leading `rule:` / `rule::` token, regexes, lifecycles, and edges can be interleaved without changing their structural meaning; the guide now says that flexibility is supported format, not accidental parser tolerance.
- 2026-03-19: Added explicit repeated-choice shorthand `OR+` as supported current rule-label surface. `rule:OR+` now lowers with the same min-one repeated-choice contract as `rule:OR` and `rule:OR{1,}`, validation accepts it, regression coverage locks metadata plus runtime parity, and the guide now treats it as explicit shorthand rather than a distinct execution family.
- 2026-03-19: Hardened bounded/shorthand repeated-choice blind-call behavior further. `:+`, `:OR{2,3}`, and `:OR{,2}` now have focused regression coverage, and repeat blind-call handlers now stop cleanly on zero-progress child success so lower-bound-zero child rules can return `[]` standalone without sending repeated parents into infinite loops.
- 2026-03-19: Hardened repeated-choice blind-call semantics. `REP_BCODE` now repeats one child-choice step rather than reusing the ordered-sequence blind-call body, so explicit `:OR` blind-call rules and historical bare `rule:` blind-call rules now both follow repeated-choice semantics instead of accidentally behaving like repeated `AND` sequences.
- 2026-03-19: Captured the blind-call mode-selection rule explicitly. `=> child_rule` makes a rule parser-step oriented, but it does not itself mean ordered sequence. The rule label must still decide whether the blind-call body behaves as sequence, choice, or repeated choice, so future implementation should not silently reinterpret bare `rule:` as implicit `AND` just because the body uses blind calls.
- 2026-03-19: Added the rationale for the “do not mix `->` and `=>` in one rule” contract. The current model treats `->` as regex-slot-driven execution and `=>` as parser-step orchestration/composition, so mixing them in one rule muddies input-ownership, grouping semantics, and return-shape meaning; current policy therefore remains one rule, one execution model.
- 2026-03-19: Locked the action-edge regex-slot indexing contract in docs/tests: `-> rule` is now regression-pinned as `-> rule[0]`, later indexed forms like `-> rule[1]` / `-> rule[2]` are pinned through bootstrap `reidx` checks, and same-rule recursive runtime parity now proves that `-> A` and `-> A[0]` remain equivalent on both base-case and recursive inputs.
- 2026-03-19: Locked the current blind-call contract in docs/tests: `=> child_rule` is now taught explicitly as parser-step composition rather than regex-slot dispatch, focused regression coverage now pins the clear sequence-wrapper (`AND_BCODE`) and choice-wrapper (`OR_BCODE`) metadata/runtime surfaces, and the repeated-choice blind-call family on `rule:`, `:OR`, `:+`, and `:OR{...}` is now tracked honestly as a clarification seam instead of being overclaimed.
- 2026-03-19: Added parser-oriented middle-window array helper `slice(array_expr, start)` / `slice(array_expr, start, count)` so `.spec` rules can derive one canonical bounded subarray from direct arrays and composed array-valued expressions across array assignment sources, direct return payloads, reducer composition, and nested scalar(container, index) reads, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; invalid/negative start or count values clamp to `0`, and undefined/out-of-range sources yield `[]`.
- 2026-03-19: Added parser-oriented first-match array lookup helper `index_of(array_expr, needle_expr)` so `.spec` rules can derive one canonical zero-based location from direct arrays and composed array-valued expressions across assignment sources, direct return payloads, and numeric/definedness comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; `index_of(...)` returns `undef` for missing/non-array/no-match cases and returns `0` when the first match is already at index `0`.
- 2026-03-19: Added parser-oriented arithmetic reducer `num_range(array_expr)` so `.spec` rules can derive one canonical numeric max-minus-min span from direct arrays and composed array-valued expressions across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; `num_range(...)` returns `undef` for empty arrays, non-array sources, and non-numeric item sources, and otherwise returns the numeric maximum minus the numeric minimum so a one-item array yields `0`.
- 2026-03-19: Broadened parser-oriented arithmetic helpers `num_min(...)` and `num_max(...)` so they still accept two-or-more scalar operands, but now also accept one array-valued source as a reducer across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; unary array-reducer mode returns `undef` for empty arrays, non-array sources, and non-numeric item sources.
- 2026-03-18: Added parser-oriented arithmetic reducer `num_median(array_expr)` so `.spec` rules can derive one canonical numeric median from direct arrays and composed array-valued expressions across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; `num_median(...)` now returns `undef` for empty arrays, non-array sources, and non-numeric item sources, and averages the two middle items for even-length arrays after numeric ordering.
- 2026-03-18: Added parser-oriented arithmetic reducer `num_avg(array_expr)` so `.spec` rules can average numeric-looking direct arrays and composed array-valued expressions into one canonical scalar summary across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; `num_avg(...)` now returns `undef` for empty arrays, non-array sources, and non-numeric item sources.
- 2026-03-18: Added parser-oriented arithmetic reducer `num_sum(array_expr)` so `.spec` rules can sum numeric-looking direct arrays and composed array-valued expressions into one canonical scalar total across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; `num_sum(...)` now returns `0` for empty arrays and `undef` for non-array or non-numeric item sources.
- 2026-03-18: Added parser-oriented array order-inversion helper `reversed(...)` so `.spec` rules can flip direct arrays and composed array-valued expressions into one canonical last-added-first array view inside pure value compositions across assignment sources, direct return payloads, and reducer inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-18: Added parser-oriented deterministic array-ordering helper `sorted(...)` so `.spec` rules can normalize direct arrays and composed array-valued expressions into one canonical lexical array value inside pure value compositions across assignment sources, direct return payloads, and reducer inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-18: Added parser-oriented scalar assembly helper `concat(...)` so `.spec` rules can build canonical string values from normalized scalar fragments inside pure value compositions across assignment sources, direct return payloads, and comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces while preserving `undef` for missing or aggregate/reference operands.
- 2026-03-18: Added parser-oriented arithmetic helper `num_clamp(...)` so `.spec` rules can keep bounded-result numeric normalization inside canonical value expressions across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; `num_clamp(...)` now preserves `undef` for missing, non-numeric-looking, or inverted-bound operands instead of silently swapping bounds.
- 2026-03-18: Added parser-oriented arithmetic helper `num_mod(...)` so `.spec` rules can keep parity, bucket, and wraparound-style integer composition inside canonical value expressions across assignment sources, direct return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces; `num_mod(...)` is intentionally integer-oriented and now preserves `undef` for missing, non-integer-looking, or divide-by-zero operands.
- 2026-03-18: Added parser-oriented scalar fallback helper `coalesce_nonempty(...)` so `.spec` rules can keep “first defined nonempty value wins” logic inside canonical value expressions across assignment sources, direct return payloads, and comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces while still preserving `0` as a valid chosen value.
- 2026-03-18: Added parser-oriented scalar substring predicate helper `contains_substr(...)` so `.spec` rules can keep normalized substring-membership flags inside canonical value expressions across assignment sources, direct return payloads, and flow conditions, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-18: Added parser-oriented pure hash/object single-field update helper `set_key(...)` so `.spec` rules can set one canonical field on working hashes and hash-valued expressions inside pure value compositions across assignment sources, direct return payloads, nested scalar reads, and flow-helper composition, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-18: Added parser-oriented pure hash/object single-field rename helper `rename_key(...)` so `.spec` rules can rename one canonical field on working hashes and hash-valued expressions inside pure value compositions across assignment sources, direct return payloads, nested scalar reads, and flow-helper composition, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-18: Added parser-oriented pure array-layering helper `concat_arrays(...)` so `.spec` rules can combine direct arrays, projected arrays, array constructors, and array-valued fallback chains into one canonical array value across declarations, assignments, direct return payloads, and reducer composition, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-18: Added parser-oriented literal string rewrite helper `replace_substr(...)` so `.spec` rules can keep separator cleanup and canonical-name normalization inside pure value expressions across assignment sources, direct return payloads, and flow comparisons, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- Deferred hardening seam: fluent lifecycle metadata currently under-reports `RETURN` coverage for the value-layer `is_empty(...)` / `is_nonempty(...)` helper family even though the feature is otherwise rewrite-ready and regression-green; if we resume lifecycle metadata hardening later, start there.
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
- 2026-03-17: Logged a deferred architecture-risk note so future slices keep four concrete seams visible without reprioritizing away from feature work yet:
  - `BootstrapSpec::Core` remains the main bootstrap/frontend syntax hotspot,
  - semicolon-light plus attached-block control flow still crosses a tight `StatementSplit` / `Scanner::FlowRules` / `ControlFlow` / `RewritePipeline` seam,
  - final runtime handler generation in `SpecEntry` / `Compiler` is still Perl source-string assembly plus eval and therefore the clearest backend-portability ceiling,
  - and `Validation.pm` still lags the supported DSL surface enough to remain a clear Phase 2 hardening target.
- 2026-03-17: Added parser-oriented `drop_keys(...)` pure hash/object-cleanup lowering so `.spec` rules can remove debug or transport-only fields from working hashes and hash-valued expressions inside canonical value expressions, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `pick_keys(...)` pure hash/object-projection lowering so `.spec` rules can keep only one explicit field set from working hashes and hash-valued expressions inside canonical value expressions, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `sorted_keys(...)` stable hash/object-to-array projection lowering so `.spec` rules can derive deterministic key-list arrays from working hashes and hash-valued expressions inside canonical value expressions, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `merge_hash(...)` pure hash/object-layering lowering so `.spec` rules can compose stable base metadata, fallback objects, and final normalization overlays inside canonical value expressions, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `count(...)` array-reducer lowering so `.spec` rules can derive one scalar size value from array variables and array-valued expressions across assignment sources, return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented scalar-normalization helper lowering for `trim(...)`, `lowercase(...)`, and `uppercase(...)` so `.spec` rules can normalize text canonically across assignment sources, return payloads, and comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `is_defined(...)` / `is_undefined(...)` flow-helper lowering so `.spec` rules can distinguish “missing” from “empty” across scalar fields, nested payload reads, and fallback chains, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `coalesce(...)` value-helper lowering so first-defined fallback chains now work canonically across assignment sources, return payloads, and comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Captured a design note that future scalar and aggregate helper growth should follow a disciplined functional-expression style: unlimited composition, clear helper signatures, pure-expression preference at the value layer, and parser-oriented semantics, while explicitly avoiding scope creep into lambdas, closures, currying, or a general-purpose FP sublanguage.
- 2026-03-17: Added a dedicated scalar-and-aggregate composition cookbook so string, integer, float-like, array, and hash helper usage is now taught in one place with many worked `.spec` examples and explicit no-DSL-fixed-depth composition guidance.
- 2026-03-17: Regression-locked the representative `assign(array(...), filter_match(uniq(uppercase_each(array(...))), /.../)) -> lowercase_each(...) -> return(array_copy(...))` case-normalization/filter pipeline between fluent and structured authoring on both action-edge and lifecycle surfaces, so the uppercase/uniq/filter/lowercase family is now explicitly part of the method-like DSL contract.
- 2026-03-16: Regression-locked mixed per-branch carriers on the outer attached-block switch family, so forms like `case("A") { ... } case("B") ... default { ... }` are now explicit supported surfaces on both structured and final-call fluent action-edge/lifecycle contexts.
- 2026-03-16: Regression-locked the representative `split(...) -> split_each(...) -> trim_each(...) -> filter_nonempty(...) -> return(array_copy(...))` array-normalization pipeline between fluent and structured authoring on both action-edge and lifecycle surfaces, so `split_each(...)` is now explicitly part of the method-like DSL contract.
- 2026-03-16: Made zero-arg fluent control-flow markers explicit in the bootstrap renderer so `.else`, `.endif`, `.default`, `.endcase`, and `.endswitch` are now an intentional supported fluent surface rather than an accidental byproduct of later optional-scope normalization.
- 2026-03-16: Added mixed-carrier composite `if(...)` support so attached-block `if` chains can mix attached branch blocks with lighter plain marker bodies across one `if/elseif/else` chain, including the final-call fluent action-edge/lifecycle surface.

## Mission Context
LinkedSpec is being evolved into a serious progressive extraction parser tool (alternative to strict EBNF workflows in niche use-cases), with recursion and staged coarse-to-fine parsing as core strengths.

## Documentation Contract
- Project docs are expected to optimize for readability, non-ambiguity, and clear explanations.
- Representative examples are encouraged whenever they make semantics easier to learn or verify.
- Newly landed user-facing surfaces should get fuller worked examples when terse snippets would undersell or obscure the real supported shape.
- User-facing guides and worked examples are part of the end-user contract for supported surfaces and should not be treated as optional polish.
- Once the user clarifies a project-level documentation or adoption expectation, treat it as a standing rule and do not wait for repeated reminders.
- Cross-cutting cookbook guides should be added when one high-frequency user-facing family would be too fragmented across only module-owner references.
- Obfuscation is explicitly out of scope for both user-facing guidance and architecture rationale.

## Current Session Snapshot (2026-03-16)
- Feature follow-up:
  - representative case-normalization/filter pipelines using `assign(array(...), filter_match(uniq(uppercase_each(array(...))), /.../))`, `lowercase_each(...)`, and `return(array_copy(...))` now have explicit fluent-versus-structured regression coverage,
  - that coverage spans both action-edge and lifecycle surfaces,
  - and roadmap/guide wording now treats `lowercase_each(...)`, `uppercase_each(...)`, `uniq(...)`, and `filter_match(...)` as part of an explicit backend-neutral cleanup pipeline contract instead of mostly as lower-level lowering details.
- Feature follow-up:
  - the outer attached-block switch family now explicitly supports mixed per-branch carriers such as `case("A") { ... } case("B") ... default { ... }`,
  - that support is now regression-locked on both structured and final-call fluent surfaces across action-edge and the full lifecycle family,
  - and the guides now show the mixed-carrier outer-switch shape directly instead of leaving it implicit.
- Feature follow-up:
  - representative array-normalization pipelines using `split(...)`, `split_each(...)`, `trim_each(...)`, `filter_nonempty(...)`, and `return(array_copy(...))` now have explicit fluent-versus-structured regression coverage,
  - that coverage spans both action-edge and lifecycle surfaces,
  - and roadmap/guide wording now treats `split_each(...)` as part of a supported backend-neutral normalization pipeline instead of mostly as a corpus-migration detail.
- Feature follow-up:
  - the attached-block composite `if(...)` surface now works as the final call on fluent action-edge and lifecycle chains too,
  - so surfaces like `-> rule .if(cond) { ... } elseif(cond2) { ... } else { ... }` and `I.if(cond) { ... } elseif(cond2) { ... } else { ... }` are now tracked as supported,
  - and the bootstrap chain parser now preserves the trailing attached `elseif(...)` / `else` clauses instead of dropping them after the first fluent `if(...)` block.
- Feature follow-up:
  - the outer attached-block switch surface now works as the final call on fluent action-edge and lifecycle chains too,
  - so surfaces like `-> rule .switch(expr) { ... }` and `I.switch(expr) { ... }` are now tracked as supported,
  - and the bootstrap chain parser now preserves that final attached block instead of dropping it.
- Feature follow-up:
  - the outer attached-block switch surface is now explicitly regression-locked for plain marker branches too,
  - so `switch(expr) { case(value) ... default ... }` is now tracked as supported alongside the per-branch attached-block variant,
  - and that parity lock now spans action-edge plus the full lifecycle family (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`).
- Feature follow-up:
  - the block-bodied outer switch surface `switch(expr) { case(value) { ... } default { ... } }` is now supported,
  - it is tracked as the structured outer-body sibling of the inline composite switch attached-branch-block surface rather than as marker-style `endswitch()` sugar,
  - and the implementation depended on switch-flow scanner widening so the whole attached outer-switch statement now counts as canonical ActionIR instead of a fallback RAW_PERL statement.
- Feature-priority follow-up:
  - structured marker-style control-flow now accepts bare zero-arg markers `else`, `endif`, `default`, `endcase`, and `endswitch`,
  - regression coverage now pins that surface in statement splitting plus structured action-edge/lifecycle lowering,
  - and this is the first punctuation-reduction feature slice after the last scoped deep marker hardening checkpoint.
- Method-DSL / control-flow follow-up:
  - `t/phase0_regression.t` now parity-locks each switch family’s own structured branch-body carriers for nested composite `if(...)` / `elseif(...)` flow when those inner branches themselves carry the representative deeper alternating marker `if(...) ... switch(...) ... endif()` shape.
  - that now covers:
    - inline composite switch `case(value, { ... })` / `default({ ... })` versus `case(value) { ... }` / `default() { ... }`,
    - and marker-style outer switch plain branch markers versus attached branch-block sugar.
  - coverage spans action-edge plus the full lifecycle family (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`).
  - roadmap/user-guide wording now says this combined nested composite-`if` plus deeper alternating marker seam preserves parity within each switch family’s own structured branch-body carriers too, not only across the two outer switch families.
- Priority shift after this slice:
  - deeper marker `if(...)` / marker `switch(...)` cross-nesting hardening is no longer the near-term focus,
  - next slices should focus on adding missing user-facing DSL features first.
- Method-DSL / control-flow follow-up:
  - `t/phase0_regression.t` now directly parity-locks inline composite outer `switch(...)` and marker-style outer `switch(...) ... endswitch()` on the common attached branch-block carrier for nested composite `if(...)` / `elseif(...)` flow when those inner branches themselves carry the representative deeper alternating marker `if(...) ... switch(...) ... endif()` shape.
  - coverage spans action-edge plus the full lifecycle family (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`).
  - roadmap/user-guide wording now says this combined nested composite-`if` plus deeper alternating marker seam has direct cross-family outer-switch parity coverage too, not only the plain nested composite-if seam or the switch-only deep-marker seam.
- Method-DSL / control-flow follow-up:
  - `t/phase0_regression.t` now directly parity-locks inline composite outer `switch(...)` and marker-style outer `switch(...) ... endswitch()` on the common attached branch-block carrier for nested composite `if(...)` / `elseif(...)` flow when those deeper branches carry:
    - the broader multi-`case(...)` nested inline-composite `switch(...)` shape,
    - and the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape.
  - coverage spans action-edge plus the full lifecycle family (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`).
  - roadmap/user-guide wording now says those broader multi-`case(...)` nested switch shapes have direct cross-family outer-switch parity coverage too, not only same-family branch-carrier parity or within-family attached-switch parity.
- Method-DSL / control-flow follow-up:
  - `t/phase0_regression.t` now parity-locks the same two local structured branch-body carrier pairs for the broader multi-`case(...)` nested inline-composite `switch(...)` shape inside nested composite `if(...)` / `elseif(...)` flow:
    - inline composite switch `case(value, { ... })` / `default({ ... })` versus `case(value) { ... }` / `default() { ... }`,
    - and marker-style outer switch plain branch markers versus attached branch-block sugar.
  - coverage spans action-edge plus the full lifecycle family (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`).
  - roadmap/user-guide wording now says that this broader multi-`case(...)` nested inline-composite switch shape preserves parity within each switch family's own structured branch-body carriers when it appears inside nested composite `if/elseif` flow too, not only across attached switch branch blocks.
- Method-DSL / control-flow follow-up:
  - `t/phase0_regression.t` now parity-locks the same two local structured branch-body carrier pairs for the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape inside nested composite `if(...)` / `elseif(...)` flow:
    - inline composite switch `case(value, { ... })` / `default({ ... })` versus `case(value) { ... }` / `default() { ... }`,
    - and marker-style outer switch plain branch markers versus attached branch-block sugar.
  - coverage spans action-edge plus the full lifecycle family (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`).
  - roadmap/user-guide wording now says that this broader multi-`case(...)` nested marker-switch shape preserves parity within each switch family's own structured branch-body carriers when it appears inside nested composite `if/elseif` flow too, not only across attached switch branch blocks.
- Method-DSL / control-flow follow-up:
  - `t/phase0_regression.t` now parity-locks the two local structured branch-body carrier pairs for nested composite `if(...)` / `elseif(...)` flow:
    - inline composite switch `case(value, { ... })` / `default({ ... })` versus `case(value) { ... }` / `default() { ... }`,
    - and marker-style outer switch plain branch markers versus attached branch-block sugar.
  - coverage spans action-edge plus the full lifecycle family (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`).
  - roadmap/user-guide wording now says that nested composite `if/elseif` parity holds within each switch family's own structured branch-body carriers too, not only across the two outer switch families.
- Method-DSL / control-flow follow-up:
  - `t/phase0_regression.t` now parity-locks inline composite outer `switch(...)` and marker-style outer `switch(...) ... endswitch()` directly on attached branch blocks `case(value) { ... }` / `default() { ... }` for nested composite `if/elseif` flow.
  - coverage spans action-edge plus the full lifecycle family (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`).
  - roadmap/user-guide wording now says that nested composite-`if` contract spans both outer switch families too, not only same-family outer-switch surfaces.
- Method-DSL / control-flow follow-up:
  - `t/phase0_regression.t` now parity-locks inline composite outer `switch(...)` and marker-style outer `switch(...) ... endswitch()` directly on attached branch blocks `case(value) { ... }` / `default() { ... }` for broader nested multi-`case(...)` inline-composite `switch(...)` flow.
  - coverage spans action-edge plus the full lifecycle family (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`).
  - roadmap/user-guide wording now says that broader multi-`case(...)` nested inline-switch contract spans both outer switch families too, not only same-family outer-switch surfaces.
- Method-DSL / control-flow follow-up:
  - `t/phase0_regression.t` now parity-locks inline composite outer `switch(...)` and marker-style outer `switch(...) ... endswitch()` directly on attached branch blocks `case(value) { ... }` / `default() { ... }` for broader nested multi-`case(...)` marker-style switch flow.
  - coverage spans action-edge plus the full lifecycle family (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`).
  - roadmap/user-guide wording now says that broader multi-`case(...)` nested marker-switch contract spans both outer switch families too, not only the branch-body carriers or same-family surfaces.
- Method-DSL / control-flow follow-up:
  - `t/phase0_regression.t` now parity-locks inline composite outer `switch(...)` and marker-style outer `switch(...) ... endswitch()` directly on attached branch blocks `case(value) { ... }` / `default() { ... }` for the deeper alternating marker `if(...) ... switch(...) ... endif()` nesting shape.
  - coverage spans action-edge plus the full lifecycle family (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`).
  - roadmap/user-guide wording now says that same deeper alternating marker contract spans both outer switch families too, not only the branch-body carriers within each family.
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

## Current Session Snapshot (2026-03-15)
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

## Current Session Snapshot (2026-03-15)
- Extended the deep mutual marker-flow contract into composite `if(...)` branch bodies:
  - marker `if(...) ... endif()` and marker `switch(...) ... endswitch()` now have a representative deeper alternating nesting regression inside both structured inline composite-`if` branch blocks and attached-block composite-`if` branch bodies too,
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

## Current Session Snapshot (2026-03-15)
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

## Current Session Snapshot (2026-03-15)
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

## Current Session Snapshot (2026-03-15)
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

## Current Session Snapshot (2026-03-15)
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

## Current Session Snapshot (2026-03-15)
- Regression-locked the broader plain nested multi-`case(...)` marker-switch seam inside attached switch branch blocks:
  - inline composite and marker-style outer switch surfaces now cover nested marker-style `switch(...) ... endswitch()` flow with multiple `case(...)` arms,
  - without needing the extra inner composite-`if(...)` layer,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the combined deeper composite-`if/elseif/else` plus broader multi-`case(...)` nested marker-switch seam:
  - composite `if(...)` branch-block parity now covers the deeper `if/elseif/else` branch shape,
  - when those branches carry marker-style `switch(...) ... endswitch()` flow with multiple `case(...)` arms,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow parity without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the combined deeper composite-`if/elseif/else` plus broader multi-`case(...)` nested inline-switch seam:
  - composite `if(...)` branch-block parity now covers the deeper `if/elseif/else` branch shape,
  - when those branches carry inline-composite `switch(...)` flow with multiple `case(...)` arms,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow parity without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the broader multi-`case(...)` marker-switch parity seam inside attached switch branch blocks:
  - attached switch branch blocks now preserve parity between structured inline composite `if(...)` branch-block bodies and attached-block composite `if(...)` branch bodies on both outer switch families,
  - when those deeper `if/elseif/else` branches carry nested marker-style `switch(...) ... endswitch()` flow with multiple `case(...)` arms,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow parity without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the marker-style outer-switch follow-up for the attached-switch nested composite-if multi-case inline-switch parity seam:
  - attached switch branch blocks now preserve parity between structured inline composite `if(...)` branch-block bodies and attached-block composite `if(...)` branch bodies on both outer switch families,
  - including the marker-style outer `switch(...) ... endswitch()` family, not only the inline composite outer switch family,
  - when those deeper `if/elseif/else` branches carry nested inline-composite `switch(...)` flow with multiple `case(...)` arms,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow parity without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the attached-switch nested composite-if multi-case inline-switch parity follow-up:
  - inline composite outer switch attached branch blocks now preserve parity between structured inline composite `if(...)` branch-block bodies and attached-block composite `if(...)` branch bodies,
  - even when those deeper `if/elseif/else` branches themselves carry nested inline-composite `switch(...)` flow with multiple `case(...)` arms,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow parity without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the attached-switch nested composite-if marker-switch parity follow-up:
  - inline composite and marker-style outer switch attached branch blocks now preserve parity between structured inline composite `if(...)` branch-block bodies and attached-block composite `if(...)` branch bodies,
  - even when those deeper `if/elseif/else` branches themselves carry nested marker-style `switch(...) ... endswitch()` flow,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow parity without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the attached-switch nested composite-if/switch parity follow-up:
  - inline composite and marker-style outer switch attached branch blocks now preserve parity between structured inline composite `if(...)` branch-block bodies and attached-block composite `if(...)` branch bodies,
  - even when those deeper `if/elseif/else` branches themselves carry nested inline-composite `switch(...)` flow,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow parity without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the deeper composite-if nested inline-switch follow-up:
  - structured inline composite `if(...)` branch blocks and attached-block composite `if(...)` forms now have explicit coverage for nested inline-composite `switch(...)` flow in the deeper `if/elseif/else` branch shape too,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the deeper composite-if nested marker-switch follow-up:
  - structured inline composite `if(...)` branch blocks and attached-block composite `if(...)` forms now have explicit coverage for nested marker-style `switch(...) ... endswitch()` flow in the deeper `if/elseif/else` branch shape too,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the broader composite-if nested marker-switch follow-up:
  - structured inline composite `if(...)` branch blocks and attached-block composite `if(...)` forms now have explicit coverage for nested marker-style `switch(...) ... endswitch()` flow with multiple `case(...)` arms too,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the broader composite-if nested inline-switch follow-up:
  - structured inline composite `if(...)` branch blocks and attached-block composite `if(...)` forms now have explicit coverage for nested inline-composite `switch(...)` flow with multiple `case(...)` arms too,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the broader attached-switch nested inline-switch follow-up:
  - attached `case(value) { ... }` and `default() { ... }` branch bodies now have explicit coverage for nested inline-composite `switch(...)` flow with multiple `case(...)` arms too,
  - on both inline composite outer switch surfaces and marker-style outer switch surfaces,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the deeper attached-switch nested composite-if follow-up:
  - attached `case(value) { ... }` and `default() { ... }` branch bodies now have explicit coverage for nested composite `if/elseif/else` flow too,
  - on both inline composite outer switch surfaces and marker-style outer switch surfaces,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the next attached-switch structured-context follow-up:
  - attached `case(value) { ... }` and `default() { ... }` branch bodies now have explicit coverage for nested inline-composite `switch(...)` flow too,
  - on both inline composite outer switch surfaces and marker-style outer switch surfaces,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the next attached-switch structured-context follow-up:
  - attached `case(value) { ... }` and `default() { ... }` branch bodies now have explicit coverage for nested composite `if(...)` flow too,
  - on both inline composite outer switch surfaces and marker-style outer switch surfaces,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Regression-locked the next attached-switch structured-context follow-up:
  - attached `case(value) { ... }` and `default() { ... }` branch bodies now have explicit coverage for nested marker-style `switch(...) ... case(...) ... default() ... endswitch()` flow,
  - on both inline composite outer switch surfaces and marker-style outer switch surfaces,
  - across action-edge plus the full lifecycle family `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens regression-locked structured control-flow coverage without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Fixed the compile-path rewrite gap for attached-block switch branch bodies that contain nested marker flow:
  - inline composite `switch(expr, case(value) { if(...) ... endif() }, default() { ... })` now stays zero-fallback and zero-unresolved,
  - structured marker-style `switch(expr) case(value) { if(...) ... endif() } default() { ... } endswitch()` now does the same,
  - and those nested-flow branch-body forms are now regression-locked across action-edge and lifecycle coverage.
- Root cause and fix:
  - the rewrite pipeline was still executing child helper lowerers after a parent statement had already been replaced,
  - that left stale flow-stack state behind and caused the pipeline to return the original code,
  - the fix now skips later helper applications when the source statement is no longer present in the rewritten buffer.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice fixes and broadens a supported attached-block switch surface without moving the track level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Landed attached-block switch branch sugar on the switch surfaces that were explicitly staged first:
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

## Current Session Snapshot (2026-03-15)
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

## Current Session Snapshot (2026-03-15)
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

## Current Session Snapshot (2026-03-15)
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

## Current Session Snapshot (2026-03-15)
- Landed the first inline composite `if(...)` slice:
  - argument-list forms such as `if(cond, action1(...), action2(...), elseif(cond2, ...), else(...))` now lower through the same control-flow owner path as the existing marker-style `if()/elseif()/else()/endif()` baseline,
  - action-edge and lifecycle surfaces are both regression-locked,
  - the new branch bodies reuse the same shared branch-action rewrite context as inline composite `switch(...)`,
  - and the flow scanner now recognizes those compact `if(...)` / `elseif(...)` / `else(...)` forms as the same canonical control-flow family for migration metadata.
- Clarified the docs accordingly:
  - inline composite `if(...)` is no longer only a feasibility note,
  - the first-step argument-list form is now supported,
  - the later structured attached-block form `if(cond) { ... } elseif(cond2) { ... } else() { ... }` is now supported on action-edge and lifecycle block surfaces too,
  - and the compact form is documented as semantically equivalent to the marker baseline even though it does not materialize a separate explicit `ENDIF` helper node in metadata.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported control-flow authoring without moving the track level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`

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
  - because this slice lands another supported method-like control-flow surface without moving the track level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Landed the next composite-`if(...)` branch-body regression follow-up:
  - nested inline-composite `switch(...)` forms now have explicit regression coverage inside both structured inline composite `if(...)` branch blocks and attached-block composite `if(...)` branch blocks,
  - including the attached switch-branch sugar `case(value) { ... }` / `default() { ... }`,
  - and the same nested switch contract is now locked across the full lifecycle family too.
- Clarified the docs accordingly:
  - composite-`if(...)` structured branch bodies are now documented as supporting nested switch flow generally,
  - not only the marker-style `switch(...) ... endswitch()` variant.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens regression-locked control-flow coverage without moving the track level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Landed the next composite-`if(...)` control-flow follow-up:
  - nested marker-style `switch(...) ... case(...) ... default() ... endswitch()` flow now stays fully rewrite-ready inside both structured inline composite `if(...)` branch blocks and attached-block composite `if(...)` branch blocks,
  - action-edge and full lifecycle-family coverage are now regression-locked for that nested switch shape,
  - and `StatementSplit::Core` now recognizes attached-block method statements with balanced parsing so attached `if/else` boundaries remain intact even when the branch body itself carries nested marker flow.
- Clarified the docs accordingly:
  - composite-`if(...)` structured branch bodies are now documented as supporting nested marker-style switch flow too,
  - not only flat helper sequences or nested marker-style `if(...) ... endif()` flow.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens supported structured control-flow behavior without moving the track level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit/Core.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Landed the first structured inline-composite switch branch-body extension:
  - `case(value, { ... })` and `default({ ... })` now lower through the same inline composite switch owner path as the existing action-list baseline,
  - semicolonless structured helper sequences inside those branch bodies are now supported on both action-edge and lifecycle surfaces,
  - and inline branch actions now share one rewrite context across the whole branch body so nested flow bookkeeping stays coherent.
- Clarified the docs accordingly:
  - the first structured inline-switch branch-body extension is now supported,
  - and, at that stage, attached-block sugar such as `case(value) { ... }` and `default() { ... }` was still deferred.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens the structured control-flow surface without moving the track level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
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

## Current Session Snapshot (2026-03-15)
- Landed the lifecycle-family follow-up for semicolon-light structured control flow:
  - semicolonless structured `LS`, `LE`, `E`, `EX`, and `IT` `if/else/endif` plus `switch/case/default/endswitch` blocks are now regression-locked too,
  - and those lifecycle blocks match their fluent baselines on canonical action-IR node coverage, canonical hit counts, expected control-flow helper coverage, zero fallback, and language-agnostic readiness.
- Clarified the docs accordingly:
  - semicolon-light marker-style control-flow coverage now spans `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`,
  - so the base optional-semicolon marker syntax is no longer documented as effectively `LX`-only.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens lifecycle-family control-flow coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-15)
- Landed the lifecycle-family follow-up for semicolon-light generic helper blocks:
  - semicolonless structured `LS`, `LE`, `E`, `EX`, and `IT` helper sequences are now regression-locked too,
  - and those lifecycle blocks match their fluent baselines on canonical action-IR node coverage, canonical hit counts, expected `DECLARE` / `ASSIGN` / `RETURN` / `RETURN_A` helper coverage, zero fallback, and language-agnostic readiness.
- Clarified the exact lifecycle-wide state in the docs:
  - generic helper-only semicolon-light regression coverage now spans `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`,
  - while control-flow-heavy semicolon-light lifecycle coverage is still the narrower `LX`-anchored slice for now.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens lifecycle-family regression coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-14)
- Added `ROADMAP_V2.md` as a shorter execution-oriented companion to `ROADMAP.md` so the active plan is easier to inspect without flattening the long-form roadmap into one file.
- Tightened the semicolon-light lifecycle policy wording:
  - the lifecycle family is explicitly `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`,
  - and `I { ... }` plus `LX { ... }` are documented as current regression anchors rather than the boundary of the intended lifecycle-wide rule.
- Tracker impact:
  - no live-status row changes,
  - because this is a roadmap/doc precision slice rather than a new implementation slice.
- Validation snapshot for this slice:
  - `git diff --stat -- ROADMAP.md ROADMAP_V2.md USER_GUIDE.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`

## Current Session Snapshot (2026-03-14)
- Landed the generic `LX` follow-up for semicolon-light lifecycle blocks:
  - semicolonless non-control-flow `LX { ... }` helper sequences are now regression-locked too,
  - including a supported `declare(...)` / `assign(...)` / `call(...)` / `return(...)` chain,
  - and those blocks now match the fluent `LX.` baseline on `LXCODE`, canonical action-IR coverage, zero fallback, and language-agnostic readiness without needing `;` separators.
  - Clarification: if semicolon-light structured authoring applies to one lifecycle block family, it is intended to apply to the others too unless an explicit documented exception exists; `I { ... }` and `LX { ... }` are current regression locks for that broader lifecycle-wide direction.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported semicolon-light lifecycle authoring without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-14)
- Landed the generic structured-block follow-up for semicolon-light method DSL authoring:
  - semicolonless helper-only `{ ... }` blocks are now regression-locked on action-edge surfaces too,
  - semicolonless helper-only lifecycle blocks like `I { ... }` are now regression-locked as well,
  - and both forms now match the fluent baseline on lowered output plus zero-fallback, zero-unresolved, language-agnostic migration metadata without needing `;` separators.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported semicolon-light structured authoring without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-14)
- Landed the lifecycle follow-up for semicolon-light structured control flow:
  - semicolonless marker-style `if(...)` / `else()` / `endif()` and `switch(...)` / `case(...)` / `default()` / `endswitch()` forms are now regression-locked on structured lifecycle `LX { ... }` blocks too,
  - those lifecycle blocks now match the fluent baseline on `LXCODE` lowering,
  - and they preserve zero-fallback, zero-unresolved, language-agnostic migration metadata without needing `;` separators between top-level method statements.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported structured lifecycle control-flow authoring without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-14)
- Landed the first semicolon-light structured control-flow follow-up:
  - `StatementSplit::Core` now accepts adjacent top-level method-like statements without `;` separators,
  - structured helper-only `if(...)` / `else()` / `endif()` and `switch(...)` / `case(...)` / `default()` / `endswitch()` blocks now compile cleanly without trailing semicolons,
  - and those semicolonless structured action-edge control-flow forms now match the fluent baseline on lowered output plus language-agnostic migration metadata.
- Tracker impact:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported structured control-flow authoring without moving the level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit/Core.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`

## Current Session Snapshot (2026-03-14)
- Recorded an explicit raw-Perl-free `.spec` policy design note:
  - `.spec` authoring is intended to become permanently raw-Perl-free,
  - raw Perl in `.spec` is obsolete compatibility debt rather than syntax to preserve,
  - remaining raw Perl occurrences should be flagged and migrated to canonical method-like DSL equivalents,
  - and semicolon-optional control-flow work is scoped only to canonical DSL blocks rather than to a mixed Perl/DSL model.
- Tracker impact:
  - no live-status row changes,
  - because this is a policy/design-note slice rather than a landed enforcement implementation.
- Validation snapshot for this slice:
  - `git diff --stat -- ROADMAP.md USER_GUIDE.md USER_GUIDE_ActionIR_ControlFlow.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`

## Current Session Snapshot (2026-03-14)
- Recorded the agreed pre-implementation design note for composite control-flow syntax:
  - keep current inline composite `switch(expr, case(...), default(...))` action-list syntax as the baseline composite surface,
  - do not support chained branch-body forms like `case(value, m1(...).m2(...))`,
  - enforce one branch header and one body carrier only,
  - prefer `case(value, { ... })` as the first structured inline-switch extension,
  - leave attached-block `case(value) { ... }` / `default() { ... }` as later syntax sugar at that stage,
  - and treat argument-list composite `if(cond, ..., elseif(...), else(...))` as the first landed `if(...)` direction, with the later structured attached-block form `if(cond) { ... } elseif(cond2) { ... } else() { ... }` now landed on structured block surfaces too.
- Tracker impact:
  - no live-status row changes,
  - because this is a tracked design-note slice rather than a landed implementation.
- Validation snapshot for this slice:
  - `git diff --stat -- ROADMAP.md USER_GUIDE_ActionIR_ControlFlow.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`

## Current Session Snapshot (2026-03-14)
- Recorded a control-flow syntax ergonomics clarification:
  - current docs still describe the syntax that is supported now,
  - but marker-heavy forms like `else();` and `endif()` are not being treated as the final UX target,
  - and the roadmap now explicitly tracks a future revisit of `if` / `else` / `switch` concrete syntax, including lower-friction block forms and inline composite `if(...)` exploration.
- Tracker impact:
  - no live-status row changes,
  - because this is a design-direction clarification rather than a landed syntax implementation.
- Validation snapshot for this slice:
  - `git diff --stat -- ROADMAP.md USER_GUIDE.md USER_GUIDE_ActionIR_ControlFlow.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for nested accessor payload equivalence:
  - supported `scalaref(base, path)` plus indexed/keyed `scalar(...)` payload reads now have regression coverage between fluent and structured authoring on both action-edge and lifecycle surfaces,
  - and those forms now agree on lowered output plus matching zero-unresolved / zero-fallback migration metadata.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice deepens supported nested accessor payload equivalence coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=287`)

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for branch-local canonical call-result capture equivalence:
  - supported `assign(scalar(retv), call(rule))` chains now have regression coverage inside `if/elseif` and `switch/case` control-flow bodies on both action-edge and lifecycle surfaces,
  - and those branch-local forms now agree on lowered output plus matching zero-unresolved / zero-fallback migration metadata.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice deepens supported branch-local canonical call-value equivalence coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=285`)

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for canonical call-result capture equivalence:
  - supported `assign(scalar(retv), call(rule))` forms now have regression coverage between fluent and structured authoring on both action-edge and lifecycle surfaces,
  - and those forms now agree on lowered output plus matching zero-unresolved / zero-fallback migration metadata.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice deepens supported canonical call-value capture equivalence coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=281`)

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for branch-local flat-list payload helper equivalence:
  - supported `flat_array(...)` and `flat_hash(...)` return payloads now have regression coverage inside `if/elseif` and `switch/case` control-flow bodies on both action-edge and lifecycle surfaces,
  - and those branch-local forms now agree on lowered output plus matching zero-unresolved / zero-fallback migration metadata.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice deepens supported branch-local flat-list payload equivalence coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=279`)

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for branch-local string-join payload helper equivalence:
  - supported `join_values(delimiter, array(...))` return payloads now have regression coverage inside `if/elseif` and `switch/case` control-flow bodies on both action-edge and lifecycle surfaces,
  - and those branch-local forms now agree on lowered output plus matching zero-unresolved / zero-fallback migration metadata.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice deepens supported branch-local joined-string payload equivalence coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=275`)

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for string-join payload helper equivalence:
  - supported `join_values(delimiter, array(...))` payload forms now have regression coverage between fluent and structured authoring on both action-edge and lifecycle surfaces,
  - and those forms now agree on lowered output plus matching zero-unresolved / zero-fallback migration metadata.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice deepens supported joined-string payload equivalence coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=271`)

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for branch-local snapshot payload helper equivalence:
  - supported `array_copy(...)` and compatibility `array_values(...)` return payloads now have regression coverage inside `if/elseif` and `switch/case` control-flow bodies on both action-edge and lifecycle surfaces,
  - and those branch-local forms now agree on lowered output plus matching zero-unresolved / zero-fallback migration metadata.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice deepens supported branch-local snapshot-payload equivalence coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=269`)

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for snapshot payload helper equivalence:
  - supported `array_copy(...)` and compatibility `array_values(...)` payload forms now have regression coverage between fluent and structured authoring on both action-edge and lifecycle surfaces,
  - and those forms now agree on lowered output plus matching zero-unresolved / zero-fallback migration metadata.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice deepens supported snapshot-payload equivalence coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=265`)

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for flat-list insertion helper equivalence:
  - supported `flat_array(...)` and `flat_hash(...)` payload forms now have regression coverage between fluent and structured authoring on both action-edge and lifecycle surfaces,
  - and those forms now agree on lowered output plus matching zero-unresolved / zero-fallback migration metadata.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice deepens supported list-context insertion equivalence coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=263`)

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for inline composite switch equivalence:
  - supported inline composite `switch(..., case(...), default(...))` forms now have regression coverage between fluent and structured authoring on both action-edge and lifecycle surfaces,
  - and those forms now agree on lowered output plus matching zero-unresolved / zero-fallback migration metadata even when inline `case(...)` and `default(...)` bodies contain supported helper sequences.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice deepens supported inline-switch equivalence coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=261`)

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for multi-step lifecycle branch-local control-flow equivalence:
  - supported multi-step helper sequences inside `LX` `if(...)` / `elseif(...)` and `switch(...)` / `case(...)` bodies now have regression coverage between fluent and structured forms,
  - and those lifecycle surfaces now agree on lowered `LXCODE` plus matching zero-unresolved / zero-fallback migration metadata.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice broadens supported lifecycle branch-local equivalence coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=259`)

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for multi-step action-edge branch-local control-flow equivalence:
  - supported multi-step helper sequences inside action-edge `if(...)` / `elseif(...)` and `switch(...)` / `case(...)` bodies now have regression coverage between fluent and structured forms,
  - and those action-edge surfaces now agree on compiled `ACODE` plus matching zero-unresolved / zero-fallback migration metadata.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice broadens supported action-edge branch-local equivalence coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=257`)

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for lifecycle branch-local control-flow equivalence:
  - supported `LX` fluent `if(...)` / `elseif(...)` and `switch(...)` / `case(...)` forms now have regression coverage against their structured lifecycle-block equivalents,
  - and those lifecycle surfaces now agree on lowered `LXCODE` plus matching zero-unresolved / zero-fallback migration metadata.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice broadens supported lifecycle control-flow equivalence coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=255`)

## Current Session Snapshot (2026-03-14)
- Fixed a real method-DSL branch-local control-flow bug:
  - the bootstrap fluent-chain renderer had been truncating the rest of a fluent chain at the first general `return(...)`,
  - which broke fluent-versus-structured equivalence for supported `if(...)` / `elseif(...)` and `switch(...)` / `case(...)` branch-local method bodies.
- The fix is now landed together with regression locks covering those supported branch-local control-flow surfaces.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice fixes a concrete supported-surface bug without moving the level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec/Core.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=253`)

## Current Session Snapshot (2026-03-14)
- Clarified another method-DSL equivalence requirement:
  - fluent-versus-structured equivalence is expected inside `if(...)` / `elseif(...)` branches and `switch(...)` / `case(...)` action bodies too,
  - not just at top-level action/lifecycle sequences.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this is a target-surface clarification only.

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for action-edge fluent/block equivalence on the supported collection-hash shape:
  - `-> rule .m1(...).m2(...)` and `-> rule { m1(...); m2(...); }` now have regression coverage for the same supported collection-hash method chain,
  - and those action-edge forms now agree on compiled action output plus zero-unresolved / zero-fallback migration metadata.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice broadens fluent/block equivalence coverage on supported action-edge surfaces without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=251`)

## Current Session Snapshot (2026-03-14)
- Clarified the method-DSL documentation policy:
  - unlimited nested method composition in arguments is now stated explicitly as a supported capability in the roadmap and relevant guides,
  - and the guides now say they use representative examples rather than trying to enumerate every nesting combination.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this is a documentation-policy clarification only.

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for collection-valued hash/object composition:
  - `declare(hash, ...)`, `assign(hash(...), ...)`, `push_value(array(...), hash(...))`, and `return_array(..., hash(...))` now have regression coverage for helper-only nested array-pipeline composition inside hash/object-valued shapes,
  - and fluent versus structured lifecycle surfaces now agree on that supported collection-hash shape too.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice broadens supported collection-hash coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=250`)

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for collection-valued nested composition:
  - `declare(array, ...)`, `assign(array(...), ...)`, and nested hash/array payload values now have regression coverage for helper-only nested array-pipeline composition,
  - and fluent versus structured lifecycle surfaces now agree on that supported collection-value shape too.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice broadens supported collection-value coverage without moving the level.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=249`)

## Current Session Snapshot (2026-03-14)
- Method-like DSL follow-up landed for nested return payloads:
  - helper-only nested array-pipeline composition inside `return(array(...))` now lowers cleanly,
  - and fluent versus structured method surfaces now report matching zero-unresolved / zero-fallback migration metadata for that supported return-payload shape.
- Tracker impact: `Method-like DSL migration track` stays `in progress`; this slice expands supported coverage but does not move the level.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=248`)

## Current Session Snapshot (2026-03-14)
- Started the dedicated Method-like DSL migration track in roadmap terms.
- Helper-only fluent action chains and structured `{...}` action blocks are now regression-locked to identical action lowering, and helper-only lifecycle chains with nested composed arguments are now regression-locked to identical lifecycle lowering on the currently supported lifecycle surface.
- `ROADMAP.md` now marks the `Method-like DSL migration track` row as `in progress` because dedicated migration work has landed, not just prerequisite Backbone Item 3 groundwork.
- This start slice is intentionally scoped and does not yet claim blanket equivalence for every nested composition inside every return-payload shape.
- Validation snapshot for this slice:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=247`)

## Current Session Snapshot (2026-03-14)
- Corrected the method-like DSL end-state wording:
  - the target is to remove raw Perl dependence,
  - not to remove structured `{...}` blocks when those blocks contain method-like DSL statements.
- The intended backend-neutral surface now explicitly includes:
  - fluent method sequences (`.m1(...).m2(...).mk(...)`),
  - equivalent structured blocks (`{ m1(...); m2(...); ...; mk(...) }`),
  - and unlimited nested method composition in argument lists.

## Current Session Snapshot (2026-03-14)
- Clarified the roadmap-status interpretation for the method-like DSL row:
  - it remains `not started` until dedicated method-chain / structured-block-equivalence / raw-Perl-reduction work lands,
  - and Backbone Item 3 groundwork does not count as starting that track on its own.

## Current Session Snapshot (2026-03-14)
- Refined the live-status display rule again:
  - commit close-outs should now print only the tracker rows affected by the current task,
  - and the full tracker should be shown only on explicit user request.
- Affected-row displays still need to include the row scope description from `ROADMAP.md`.

## Current Session Snapshot (2026-03-14)
- Tightened the live-status presentation rule again:
  - every displayed tracker snapshot must now include each row's brief scope description,
  - so the roadmap view remains understandable even when a row stands for multiple internal sub-slices.
- `ROADMAP.md` now embeds those brief explanations directly in a `What it covers` column.

## Current Session Snapshot (2026-03-14)
- Completed a Backbone Item 3 compatibility-surface cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` now funnels its remaining `EmitContext` compatibility wrappers through one shared `_delegate_emit_context_call(...)` helper instead of a large wall of repeated wrapper bodies.
- `LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics(...)` now passes the optional rewrite-rules slot explicitly into `LinkedSpec::ActionIR::RewritePipeline`, preserving the old two-argument `ActionRewriter` rewrite-helper behavior through the extracted owner path.
- Added the focused regression lock `action_rewriter_compat_wrappers_share_emit_context_delegator` so representative helper families stay pinned to the shared delegator path.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=246`)

## Current Session Snapshot (2026-03-14)
- Clarified the roadmap execution policy explicitly in the repo:
  - phase numbering is not a hard waterfall contract,
  - the default execution mode is dependency-first, bounded slices,
  - strict phase-by-phase sequencing only applies when explicitly requested.

## Current Session Snapshot (2026-03-14)
- Tightened the live-status workflow rule again:
  - every commit workflow close-out must now display the current live-status tracker snapshot,
  - so it is always explicit how the completed slice did or did not change the dashboard.
- This sits on top of the existing rules to update the dashboard before commits when status materially changes and to display/log any row whose level changes.

## Current Session Snapshot (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_rewrite_pipeline_deps()` is now explicitly grouped with the other owner-map helpers, and the focused seam lock now pins `_build_action_rewrite_rules(...)` to `LinkedSpec::ActionIR::RewritePipeline::default_deps_for_package(__PACKAGE__)`.
- Added the focused regression lock `emit_context_rewrite_pipeline_deps_route_through_owner_default_map` so `EmitContext` stays pinned to the extracted `RewritePipeline` owner map.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=245`)

## Current Session Snapshot (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_action_contract_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::Contracts::default_deps_for_package(__PACKAGE__)`.
- Added the focused regression lock `emit_context_action_contract_deps_route_through_owner_default_map` so `EmitContext` stays pinned to the extracted `Contracts` owner map.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=244`)

## Current Session Snapshot (2026-03-14)
- Tightened the live-status workflow rule:
  - when any roadmap dashboard level changes, display the changed rows in the task close-out,
  - and record that level change in `ROADMAP.md`, which remains the canonical live-status source.
- This sits on top of the existing pre-commit rule to update the dashboard whenever a slice materially changes what is done, what is left, or which area is active.

## Current Session Snapshot (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_scan_contract_ir_event_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::Scanner::default_deps_for_package(__PACKAGE__)`.
- Added the focused regression lock `emit_context_scanner_deps_route_through_owner_default_map` so `EmitContext` stays pinned to the extracted `Scanner` owner map.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=243`)

## Current Session Snapshot (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_declare_method_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::DeclareMethod::default_deps_for_package(__PACKAGE__)`.
- Added the focused regression lock `emit_context_declare_method_deps_route_through_owner_default_map` so `EmitContext` stays pinned to the extracted `DeclareMethod` owner map.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=242`)

## Current Session Snapshot (2026-03-14)
- Added a canonical live four-level progress dashboard to `ROADMAP.md`.
- Status vocabulary is now fixed to:
  - `done`
  - `mostly done`
  - `in progress`
  - `not started`
- Commit workflow rule:
  - before every commit, update the roadmap dashboard if a completed slice materially changes what is done, what is left, or which area is active.
- Current dashboard snapshot at the time of this rule change:
  - overall roadmap: `in progress`
  - Phase 0: `done`
  - Phase 1: `mostly done`
  - Phase 1A: `mostly done`
  - Backbone Item 3: `mostly done`
  - Phase 5: `in progress`
  - Phase 6: `in progress`
  - Phases 2, 3, 4, 7: `not started`

## Current Session Snapshot (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_method_lowering_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::MethodLowering::default_deps_for_package(__PACKAGE__)`.
- Added the focused regression lock `emit_context_method_lowering_deps_route_through_owner_default_map` so `EmitContext` stays pinned to the extracted `MethodLowering` owner map.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=241`)

## Current Session Snapshot (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_array_pipeline_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::ArrayPipeline::default_deps_for_package(__PACKAGE__)`.
- Added the focused regression lock `emit_context_array_pipeline_deps_route_through_owner_default_map` so `EmitContext` stays pinned to the extracted `ArrayPipeline` owner map.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=240`)

## Current Session Snapshot (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_value_expr_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::ValueExpr::default_deps_for_package(__PACKAGE__)`.
- Added the focused regression lock `emit_context_value_expr_deps_route_through_owner_default_map` so `EmitContext` stays pinned to the extracted `ValueExpr` owner map.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=239`)

## Current Session Snapshot (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_flow_expr_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::FlowExpr::default_deps_for_package(__PACKAGE__)`.
- Added the focused regression lock `emit_context_flow_expr_deps_route_through_owner_default_map` so `EmitContext` stays pinned to the extracted `FlowExpr` owner map.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=238`)

## Current Session Snapshot (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_statement_split_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::StatementSplit::default_deps_for_package(__PACKAGE__)`.
- Added the focused regression lock `emit_context_statement_split_deps_route_through_owner_default_map` so `EmitContext` stays pinned to the extracted `StatementSplit` owner map.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=237`)

## Current Session Snapshot (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_canonical_event_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::CanonicalEvents::default_deps_for_package(__PACKAGE__)`.
- Added the focused regression lock `emit_context_canonical_event_deps_route_through_owner_default_map` so `EmitContext` stays pinned to the extracted `CanonicalEvents` owner map.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=236`)

## Current Session Snapshot (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_diagnostics_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::Diagnostics::default_deps_for_package(__PACKAGE__)`.
- Added the focused regression lock `emit_context_diagnostics_deps_route_through_owner_default_map` so `EmitContext` stays pinned to the extracted `Diagnostics` owner map.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=235`)

## Current Session Snapshot (2026-03-14)
- Completed another small Backbone Item 3 owner-contract cleanup slice inside `LinkedSpec::*`.
- `LinkedSpec::RuleIR::EmitContext::_control_flow_deps()` no longer hand-builds its local callback map; it now delegates to `LinkedSpec::ActionIR::ControlFlow::default_deps_for_package(__PACKAGE__)`.
- Added the focused regression lock `emit_context_control_flow_deps_route_through_owner_default_map` so `EmitContext` stays pinned to the extracted `ControlFlow` owner map.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=233`)

## Current Session Snapshot (2026-03-14)
- Completed a small Backbone Item 3 cleanup slice inside `LinkedSpec::*`.
- Removed the stale local `LinkedSpec::ActionRewriter::_trim_action_ir_value(...)` helper; trimming now stays only on `LinkedSpec::RuleIR::EmitContext` and the extracted `ActionIR::*` owners.
- Added the focused regression lock `action_rewriter_drops_dead_trim_helper` so the dead helper stays gone while `EmitContext` continues to own the active trim helper.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=233`)

## Current Session Snapshot (2026-03-13)
- Completed the next no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer owns the remaining direct ControlFlow compatibility wrappers:
  - `_lower_if_flow_statement(...)`,
  - `_lower_elseif_flow_statement(...)`,
  - `_lower_else_flow_statement(...)`,
  - `_lower_endif_flow_statement(...)`,
  - `_lower_switch_flow_statement(...)`,
  - `_lower_case_flow_statement(...)`,
  - `_lower_default_flow_statement(...)`,
  - `_lower_endcase_flow_statement(...)`,
  - `_lower_endswitch_flow_statement(...)`,
  - `_lower_say_statement(...)`,
  - `_lower_print_statement(...)`;
  those now delegate to `LinkedSpec::RuleIR::EmitContext`.
- `LinkedSpec::RuleIR::EmitContext` now exposes the matching direct owner entrypoints too, so `ActionRewriter` no longer needs a direct `ControlFlow` package loader or local ControlFlow dep-map builder.
- Focused regression locks updated:
  - strengthened `action_rewriter_require_avoids_control_flow_load_until_control_helper` to lock the `EmitContext` lazy-load seam too,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the remaining ControlFlow wrapper family to the `EmitContext` owner path.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=232`)

## Current Session Snapshot (2026-03-13)
- Completed the next no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer owns the remaining direct DeclareMethod compatibility wrappers:
  - `_split_declare_symbol_names(...)`,
  - `_parse_declare_binding_entry(...)`,
  - `_lower_declare_value_expr(...)`,
  - `_lower_declare_initializer_expr(...)`,
  - `_extract_declare_statement_from_method_expr(...)`,
  - `_lower_declare_method_statement(...)`,
  - `_lower_assign_method_statement(...)`;
  those now delegate to `LinkedSpec::RuleIR::EmitContext`.
- `LinkedSpec::RuleIR::EmitContext` now exposes the missing direct owner entrypoints too, so `ActionRewriter` no longer needs a direct `DeclareMethod` package loader or local DeclareMethod dep-map builder.
- Focused regression locks updated:
  - strengthened `action_rewriter_require_avoids_declare_method_load_until_declare_helper` to lock the `EmitContext` lazy-load seam too,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the remaining DeclareMethod wrapper family to the `EmitContext` owner path.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=232`)

## Current Session Snapshot (2026-03-13)
- Completed the next no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- `LinkedSpec::ActionRewriter` no longer owns the remaining broad MethodLowering compatibility wrappers:
  - `_lower_return_general_statement(...)`,
  - `_lower_return_imatch_statement(...)`,
  - `_lower_push_value_statement(...)`,
  - `_lower_regex_subst_statement(...)`,
  - `_lower_return_undef_statement(...)`,
  - `_lower_return_array_statement(...)`;
  those now delegate to `LinkedSpec::RuleIR::EmitContext`.
- `LinkedSpec::RuleIR::EmitContext` now exposes the matching owner entrypoints too, so `ActionRewriter` no longer needs a direct `MethodLowering` package loader or local MethodLowering dep-map builder.
- Focused regression locks updated:
  - strengthened `action_rewriter_require_avoids_method_lowering_load_until_method_helper` to exercise the migrated broad MethodLowering helper path,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the remaining MethodLowering wrapper family to the `EmitContext` owner path.
- Validation snapshot for this slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
  - PASS (`Files=1, Tests=232`)

## Current State Snapshot
- Core module analyzed: `perl/LinkedSpec.pm`.
- Dependencies analyzed: `perl/LinkedRE.pm`, `perl/PathSearch.pm`, `perl/PPlugin.pm`, and downstream consumers (`LibReader`, `RTLUtils`, `TableGrep`).
- Spec corpus reviewed: `specs/*.spec` examples, including complex recursive/nested grammars.
- Known concrete issue:
  - `specs/tclite.spec` compile failure due to regex for literal `[` pattern.
- Strategic direction agreed:
  - Keep extraction-oriented behavior as intentional strength.
  - Hide internal complexity behind transparent user concepts.
  - Build reliability/diagnostics/compatibility safety net.

## Key User-Guided Decisions
1. LinkedSpec is intentionally not EBNF.
2. Multi-pass parsing is a first-class workflow:
   - pass 1 coarse anchors/chunks,
   - pass 2..N refinement.
3. Capture semantics (e.g., `$CAPTURE`) are central to the model.
4. Live markdown documents must be maintained before each commit.
5. Commit workflow uses `git commit -F git_message_brief.txt`; brief file should be cleared after commit.
6. Downstream consumers exist, but work on them is currently out of scope unless explicitly requested.
7. `_split_action_ir_statements(...)` hardening is intentionally paused for now; only resume if a concrete regression or unsupported real pattern appears.
8. Final architecture goal: `.spec` files must become language-agnostic/language-independent, with no embedded Perl code-block dependency.
9. Backend code emission should stay under strict canonical-generator control so emitted host-language code avoids avoidable splitter/parser fragility.
10. Balanced delimiters are strict policy; do not add permissive missing-close helper behavior for unmatched `)`, `]`, or `}` cases.

## Live Documents Contract
These files are live and must be amended before any commit:
- `ROADMAP.md`
- `USER_GUIDE.md`
- `DEVELOPMENT_NOTES.md`
- `CHANGES.md`
- `MEMORY.md`
## Current Session Snapshot (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- Key technical outcome:
  - `LinkedSpec::ActionRewriter::_declare_alias_to_type(...)`,
    `_lower_typed_declare_statement(...)`,
    `_normalize_method_tag_expr(...)`,
    `_lower_method_value_expr(...)`, and
    `_lower_assign_statement(...)`
    now delegate to `LinkedSpec::RuleIR::EmitContext`,
  - the broader MethodLowering statement wrappers remain on `ActionRewriter` for now,
  - require-only consumers of `ActionRewriter.pm` now keep both `EmitContext.pm` and `MethodLowering.pm` unloaded until that migrated helper path is actually invoked.
- Regression outcome:
  - strengthened `action_rewriter_require_avoids_method_lowering_load_until_method_helper` to lock the `EmitContext` lazy-load seam too,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the migrated MethodLowering helper subset to the `EmitContext` owner path.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (`Files=1, Tests=232`)
  - `bash tools/run_ci_local.sh` => PASS (`Files=1, Tests=232`)

## Current Session Snapshot (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- Key technical outcome:
  - `LinkedSpec::ActionRewriter::_build_array_pipeline_plan_from_expr(...)` and
    `_lower_array_pipeline_expr(...)`
    now delegate to `LinkedSpec::RuleIR::EmitContext`,
  - `LinkedSpec::RuleIR::EmitContext` now exposes the direct `_lower_array_pipeline_expr(...)` owner entrypoint too,
  - the direct `ActionRewriter` ArrayPipeline package loader and local ArrayPipeline dep-map builder have been removed,
  - require-only consumers of `ActionRewriter.pm` now keep both `EmitContext.pm` and `ArrayPipeline.pm` unloaded until that helper path is actually invoked.
- Regression outcome:
  - strengthened `action_rewriter_require_avoids_array_pipeline_load_until_array_helper` to lock the `EmitContext` lazy-load seam too,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the remaining array-pipeline helpers to the `EmitContext` owner path.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (`Files=1, Tests=232`)
  - `bash tools/run_ci_local.sh` => PASS (`Files=1, Tests=232`)

## Current Session Snapshot (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- Key technical outcome:
  - `LinkedSpec::ActionRewriter::_lower_flow_composite_expr(...)`
    now delegates to `LinkedSpec::RuleIR::EmitContext`,
  - the direct `ActionRewriter` FlowExpr package loader and local FlowExpr dep-map builder have been removed,
  - require-only consumers of `ActionRewriter.pm` now keep both `EmitContext.pm` and `FlowExpr.pm` unloaded until that helper path is actually invoked.
- Regression outcome:
  - strengthened `action_rewriter_require_avoids_flow_expr_load_until_flow_helper` to lock the `EmitContext` lazy-load seam too,
  - updated `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the remaining flow helper to the `EmitContext` owner path.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (`Files=1, Tests=232`)
  - `bash tools/run_ci_local.sh` => PASS (`Files=1, Tests=232`)

## Current Session Snapshot (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- Key technical outcome:
  - `LinkedSpec::ActionRewriter::_extract_scalar_symbol_name(...)`,
    `_extract_array_symbol_name(...)`,
    `_extract_hash_symbol_name(...)`,
    `_lower_scalar_access_key_expr(...)`,
    `_lower_scalaref_value_expr(...)`,
    `_infer_scalar_container_kind(...)`,
    `_lower_assignment_source_expr(...)`, and
    `_strip_literal_delimiters(...)`
    now delegate to `LinkedSpec::RuleIR::EmitContext`,
  - the direct `ActionRewriter` ValueExpr package loader and local ValueExpr dep-map builder have been removed,
  - require-only consumers of `ActionRewriter.pm` now keep both `EmitContext.pm` and `ValueExpr.pm` unloaded until that helper path is actually invoked.
- Regression outcome:
  - strengthened `action_rewriter_require_avoids_value_expr_load_until_value_helper` to lock the `EmitContext` lazy-load seam too,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the full ValueExpr helper family to the `EmitContext` owner path.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (`Files=1, Tests=232`)
  - `bash tools/run_ci_local.sh` => PASS (`Files=1, Tests=232`)

## Current Session Snapshot (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- Key technical outcome:
  - `LinkedSpec::ActionRewriter::_parse_method_function_expr(...)`,
    `_is_bare_method_scope_token(...)`,
    `_normalize_method_args_with_optional_scope(...)`, and
    `_split_top_level_csv(...)`
    now delegate to `LinkedSpec::RuleIR::EmitContext`,
  - the direct `ActionRewriter` MethodExpr package loader has been removed,
  - require-only consumers of `ActionRewriter.pm` now keep both `EmitContext.pm` and `MethodExpr.pm` unloaded until that helper path is actually invoked.
- Regression outcome:
  - strengthened `action_rewriter_require_avoids_method_expr_load_until_parse_helper` to lock the `EmitContext` lazy-load seam too,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the full MethodExpr helper family to the `EmitContext` owner path.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (`Files=1, Tests=232`)
  - `bash tools/run_ci_local.sh` => PASS (`Files=1, Tests=232`)

## Current Session Snapshot (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- Key technical outcome:
  - `LinkedSpec::RuleIR::EmitContext` now exposes owner entrypoints for `_canonicalize_helper_action_ir_event(...)` and `_lower_action_code_from_canonical_ir(...)`,
  - `LinkedSpec::ActionRewriter::_canonicalize_helper_action_ir_event(...)`,
    `_split_action_ir_statements(...)`,
    `_lower_action_code_from_canonical_ir(...)`,
    `_accumulate_action_rewrite_diagnostics(...)`, and
    `_build_action_rewrite_rules(...)`
    now delegate to `EmitContext`,
  - the duplicate canonical/split/rewrite-pipeline/diagnostics dep-builder scaffolding has been removed from `ActionRewriter`.
- Regression outcome:
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock those remaining generic helper wrappers to the `EmitContext` owner path,
  - revalidated the full phase-0 suite and local CI gate after the handoff.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (`Files=1, Tests=232`)
  - `bash tools/run_ci_local.sh` => PASS (`Files=1, Tests=232`)

## Current Session Snapshot (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- Key technical outcome:
  - `LinkedSpec::ActionRewriter::_build_action_lowering_contracts(...)`,
    `_scan_contract_ir_events(...)`,
    `_find_unresolved_action_helpers(...)`,
    `_collect_action_helper_ir_nodes(...)`,
    `_build_canonical_action_ir_events(...)`, and
    `_rewrite_action_code_with_diagnostics(...)`
    now delegate to `LinkedSpec::RuleIR::EmitContext`,
  - the remaining generic rewrite orchestration now stays on the same extracted owner path used by normal compile-time helper rewriting,
  - `ActionRewriter` remains as compatibility wrapper surface plus direct lower-level lowering helpers.
- Regression outcome:
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` to lock the new `EmitContext` owner path for the generic rewrite wrappers,
  - revalidated the full phase-0 suite and local CI gate after the handoff.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (`Files=1, Tests=232`)
  - `bash tools/run_ci_local.sh` => PASS (`Files=1, Tests=232`)

## Current Session Snapshot (2026-03-13)
- Completed another no-behavior-change Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- Key technical outcome:
  - `LinkedSpec::RuleIR::EmitContext` now owns focused helper rewrite inspection through `rewrite_action_code_for_compat(...)`,
  - `LinkedSpec::call_spec_handler_subst(...)` now lazy-loads `RuleIR::EmitContext` instead of `ActionRewriter`,
  - `LinkedSpec::ActionRewriter::call_spec_handler_subst(...)` remains available as a backward-compatible wrapper around the same owner path.
- Regression outcome:
  - strengthened `linkedspec_require_avoids_action_rewriter_load_until_compat_helper`,
  - updated `linkedspec_public_facade_wrappers_preserve_eval_error_state`,
  - updated `action_rewriter_owner_wrappers_preserve_eval_error_state`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (`Files=1, Tests=232`)
  - `bash tools/run_ci_local.sh` => PASS (`Files=1, Tests=232`)

## Current Session Snapshot (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- Key technical outcome:
  - `LinkedSpec::RuleIR::EmitContext` now assembles its rewrite callback bundle from extracted `ActionIR::*` owners directly,
  - normal emit-context builds no longer load `LinkedSpec::ActionRewriter`,
  - normal `LinkedSpec::Get(...)` compilation no longer loads `ActionRewriter` through the emit-context rewrite path either,
  - `LinkedSpec::call_spec_handler_subst(...)` remains the compatibility-only entrypoint that still lazy-loads `ActionRewriter` on demand.
- Regression outcome:
  - strengthened `linkedspec_require_avoids_compile_pipeline_load_until_get`,
  - strengthened `emit_context_require_avoids_action_rewriter_load_until_emit_context_build`,
  - added `emit_context_avoids_action_rewriter_owner_bundle`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (232 tests)
## Current Session Snapshot (2026-03-13)
- Completed another no-behavior-change Phase 1A ownership-cleanup slice inside `LinkedSpec::*`.
- Key technical outcome:
  - added `LinkedSpec::SpecEntry::_require_emit_context_pkg(...)`,
  - changed `compile_spec_entry(...)` to call `LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context(...)` directly,
  - removed `LinkedSpec::RuleIR::_require_emit_context_pkg(...)`, `_normalize_rule_code_chunks(...)`, and `_build_rule_ir_emit_context(...)`.
- Regression outcome:
  - strengthened `spec_entry_require_avoids_ruleir_load_until_compile_spec_entry` to lock lazy `EmitContext` loading too,
  - added `spec_entry_avoids_removed_ruleir_emit_context_delegates`,
  - removed obsolete `RuleIR` emit-context delegate expectations from `extracted_wrapper_helpers_preserve_eval_error_state`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (231 tests)
## Current Session Snapshot (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A compatibility-surface slice inside `LinkedSpec::*`.
- Key technical outcome:
  - `LinkedSpec::RuleIR::EmitContext` now calls `LinkedSpec::ActionIR::RewritePipeline` directly for rewrite-rule construction and rewrite execution,
  - `LinkedSpec::RuleIR::EmitContext` now calls `LinkedSpec::ActionIR::Diagnostics` directly for rewrite-diagnostic accumulation,
  - localized `_trim_action_ir_value(...)` inside `EmitContext`,
  - removed the direct dependency on thin `LinkedSpec::ActionRewriter` wrapper methods from the emit-context rewrite/diagnostic path while preserving the indirect lazy `ActionRewriter` load behind rewrite-pipeline callback-map resolution.
- Regression outcome:
  - strengthened `emit_context_require_avoids_action_rewriter_load_until_emit_context_build`,
  - updated `extracted_wrapper_helpers_preserve_eval_error_state` so the rewrite helper is locked to `RewritePipeline`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (231 tests)
## Current Session Snapshot (2026-03-13)
- Completed another no-behavior-change Backbone Item 3 / Phase 1A load-time coupling slice inside `LinkedSpec::*`.
- Key technical outcome:
  - added local `_require_pkg(...)` helpers to `ControlFlow`, `Diagnostics`, `RewritePipeline`, `Contracts`, `ValueExpr`, `ArrayPipeline`, `FlowExpr`, and `MethodLowering`,
  - updated `_require_pkg_cb(...)` in those modules to lazy-load callback-owner packages before resolving `can(...)`,
  - updated `StatementSplit::_require_pkg_cb(...)` and `CanonicalEvents::_require_pkg_cb(...)` to do the same before symbol-table callback lookup,
  - extracted ActionIR dep builders no longer assume their callback-owner package was already loaded by the caller.
- Regression outcome:
  - added `actionir_dep_builders_lazy_load_callback_owner_packages`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Diagnostics.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ValueExpr.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (231 tests)
## Current Session Snapshot (2026-03-13)
- Uncommitted Backbone Item 3 / Phase 1A load-time coupling slice completed against the remaining `MethodExpr` dep-builder prefetch seam in `LinkedSpec::*`.
- Key technical outcome:
  - removed the redundant `MethodExpr` prefetch from `LinkedSpec::ActionRewriter::_declare_method_deps(...)`,
  - removed the redundant `MethodExpr` prefetch from `LinkedSpec::ActionRewriter::_scan_contract_ir_event_deps(...)`,
  - updated `LinkedSpec::ActionIR::DeclareMethod::_require_pkg_cb(...)` to lazy-load callback-owner packages before resolving `can(...)`,
  - updated `LinkedSpec::ActionIR::Scanner::_require_pkg_cb(...)` the same way,
  - `DeclareMethod` and `Scanner` now own `MethodExpr` callback loading for their default dep maps.
- Regression outcome:
  - added `action_rewriter_dep_builders_avoid_method_expr_prefetch`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/DeclareMethod.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (230 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: move MethodExpr dep loading into owners` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-13)
- Uncommitted Backbone Item 3 / Phase 1A API-stability slice completed against the remaining extracted `ActionIR` dep-builder owners.
- Key technical outcome:
  - added `::_call_preserving_err(...)` to `Diagnostics`, `Contracts`, `DeclareMethod`, `ControlFlow`, `ArrayPipeline`, `RewritePipeline`, `FlowExpr`, `MethodLowering`, and `ValueExpr`,
  - routed `_require_pkg_cb(...)` and `default_deps_for_package(...)` through that helper across those modules,
  - routed the same dep-builder surfaces through the existing helper in `Scanner`, `StatementSplit`, and `CanonicalEvents`,
  - successful ActionIR callback-map lookup/build paths now preserve caller `$@`.
- Regression outcome:
  - added `actionir_dep_builders_preserve_eval_error_state`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Diagnostics.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/DeclareMethod.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ValueExpr.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (229 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: preserve ActionIR dep-builder caller error state` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-13)
- Uncommitted Phase 1A helper API-stability slice completed against `LinkedSpec::ParserFactory`.
- Key technical outcome:
  - added `LinkedSpec::ParserFactory::_call_preserving_err(...)`,
  - routed `_require_pkg(...)`, `_require_pkg_cb(...)`, `_require_pkg_value(...)`, and
    `run_get_parser(...)` through that helper,
  - successful lazy owner lookup and public parser-factory orchestration now preserve caller `$@`.
- Regression outcome:
  - added `parser_factory_wrappers_preserve_eval_error_state`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (228 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: preserve ParserFactory caller error state` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-13)
- Uncommitted Phase 1A helper API-stability slice completed against `LinkedSpec::PluginBridge`.
- Key technical outcome:
  - added `LinkedSpec::PluginBridge::_call_preserving_err(...)`,
  - routed `_load_legacy_plugin_runtime(...)`, `_exec_legacy_plugin(...)`, and
    `_dispatch_plugin_name(...)` through that helper,
  - successful `PluginBridge` legacy runtime load/exec delegation now preserves caller `$@`.
- Regression outcome:
  - added `plugin_bridge_owner_wrappers_preserve_eval_error_state`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (227 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: preserve PluginBridge caller error state` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-13)
- Uncommitted Phase 1A helper API-stability slice completed against `LinkedSpec::Trace`.
- Key technical outcome:
  - added `LinkedSpec::Trace::_call_preserving_err(...)`,
  - routed the reference-formatting branch of `_trace_stringify(...)` through that helper,
  - successful `Trace` dump formatting now preserves caller `$@`.
- Regression outcome:
  - added `trace_stringify_preserves_eval_error_state`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/Trace.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (226 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: preserve Trace caller error state during stringify` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-13)
- Uncommitted Phase 1A helper API-stability slice completed against `LinkedSpec::BootstrapSpec::Core`.
- Key technical outcome:
  - added `LinkedSpec::BootstrapSpec::Core::_call_preserving_err(...)`,
  - routed `_linkedre_or(...)` and `_linkedre_ored_re(...)` through that helper,
  - successful `BootstrapSpec::Core` regex-helper delegation now preserves caller `$@`.
- Regression outcome:
  - added `bootstrap_spec_core_linkedre_wrappers_preserve_eval_error_state`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec/Core.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (225 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: preserve BootstrapSpec::Core caller error state` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-13)
- Uncommitted Phase 1A façade API-stability slice completed against the public `LinkedSpec` trace wrapper surface.
- Key technical outcome:
  - routed `configure_trace(...)`, `trace_enter(...)`, `trace_exit(...)`,
    `trace_decision(...)`, `log_output(...)`, `log_dump(...)`, and
    `should_dump(...)` through `LinkedSpec::_call_preserving_err(...)`,
  - successful public trace wrapper delegation now preserves caller `$@`.
- Regression outcome:
  - added `linkedspec_trace_wrappers_preserve_eval_error_state`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (224 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: preserve facade trace caller error state` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-13)
- Uncommitted Phase 1A helper API-stability slice completed against `LinkedSpec::Compiler`.
- Key technical outcome:
  - added `LinkedSpec::Compiler::_call_preserving_err(...)`,
  - routed `_dump_value(...)`, `_ored_re(...)`, `_trace_log_output(...)`,
    `_trace_log_dump(...)`, `_trace_should_dump(...)`, `_trace_enter(...)`,
    `_trace_exit(...)`, `_trace_decision(...)`,
    `_trace_apply_trace_options(...)`, and
    `_trace_level_name_for_current_verbosity(...)` through that helper,
  - successful `Compiler` trace/dump/regex helper delegation now preserves caller `$@`.
- Regression outcome:
  - added `compiler_helper_wrappers_preserve_eval_error_state`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (223 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: preserve Compiler caller error state` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-13)
- Uncommitted Phase 1A helper API-stability slice completed against `LinkedSpec::SpecEntry`.
- Key technical outcome:
  - added `LinkedSpec::SpecEntry::_call_preserving_err(...)`,
  - routed `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`,
    `_trace_log_dump(...)`, `_trace_should_dump(...)`, and `_dump_value(...)`
    through that helper,
  - successful `SpecEntry` trace/dump helper delegation now preserves caller `$@`.
- Regression outcome:
  - added `spec_entry_helper_wrappers_preserve_eval_error_state`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (222 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: preserve SpecEntry caller error state` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A / Backbone Item 3 API-stability slice completed against `LinkedSpec::ActionRewriter`.
- Key technical outcome:
  - added `LinkedSpec::ActionRewriter::_call_preserving_err(...)`,
  - routed owner-delegate dep builders and helper wrappers through that helper,
  - successful `ActionRewriter` delegation now preserves caller `$@` across deps, helper parsing, lowering, scanner, canonical, diagnostics, and rewrite-pipeline wrapper paths.
- Regression outcome:
  - added `action_rewriter_owner_wrappers_preserve_eval_error_state`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (221 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: preserve ActionRewriter caller error state` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A owner-wrapper API-stability slice completed against the remaining thin `LinkedSpec::*` delegates.
- Key technical outcome:
  - added `_call_preserving_err(...)` to `BootstrapSpec`, `Runtime`,
    `ActionIR::Scanner`, `ActionIR::StatementSplit`, and
    `ActionIR::CanonicalEvents`,
  - routed their thin owner-delegate entrypoints through those helpers,
  - successful owner delegation now preserves caller `$@` across the remaining
    lightweight wrapper layer too.
- Regression outcome:
  - added `remaining_owner_wrappers_preserve_eval_error_state`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (220 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: preserve remaining owner wrapper caller error state` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A extracted-wrapper API-stability slice completed against `LinkedSpec::*`.
- Key technical outcome:
  - added `_call_preserving_err(...)` to `Validation`, `Resolver`, `RuleIR`, and `RuleIR::EmitContext`,
  - routed successful trace, emit-context, dump, and action-rewrite owner calls through those helpers,
  - successful extracted wrapper delegation now preserves caller `$@`.
- Regression outcome:
  - added `extracted_wrapper_helpers_preserve_eval_error_state`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/Validation.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Resolver.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (219 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: preserve extracted wrapper caller error state` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A façade API-stability slice completed against `LinkedSpec.pm`.
- Key technical outcome:
  - added `LinkedSpec::_call_preserving_err(...)`,
  - routed `Get(...)`, `spec_descr(...)`, `call_spec_handler_subst(...)`,
    `get_parser(...)`, and `AUTOLOAD` through that helper,
  - successful public façade delegation now preserves caller `$@`.
- Regression outcome:
  - added `linkedspec_public_facade_wrappers_preserve_eval_error_state`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (218 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: preserve facade caller error state` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::BootstrapSpec::Core`.
- Key technical outcome:
  - removed eager `LinkedRE` import from `perl/LinkedSpec/BootstrapSpec/Core.pm`,
  - added `LinkedSpec::BootstrapSpec::Core::_require_linkedre_pkg(...)`,
  - added `LinkedSpec::BootstrapSpec::Core::_linkedre_or(...)`,
  - added `LinkedSpec::BootstrapSpec::Core::_linkedre_ored_re(...)`,
  - updated bootstrap registry construction and bootstrap scanner handlers to lazy-load
    `LinkedRE` only when bootstrap regex dispatch is actually used.
- Regression outcome:
  - added `bootstrap_spec_core_require_avoids_linkedre_load_until_bootstrap_spec_build`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec/Core.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (217 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load LinkedRE through BootstrapSpec::Core` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::Compiler`.
- Key technical outcome:
  - removed eager `LinkedRE` import from `perl/LinkedSpec/Compiler.pm`,
  - added `LinkedSpec::Compiler::_require_linkedre_pkg(...)`,
  - added `LinkedSpec::Compiler::_ored_re(...)`,
  - updated `spec_gdata(...)` to lazy-load `LinkedRE` only when combined regex
    dependency assembly actually needs it.
- Regression outcome:
  - added `compiler_require_avoids_linkedre_load_until_run_get_pipeline`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (216 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load LinkedRE through Compiler` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A façade load-time coupling slice completed against `LinkedSpec.pm`.
- Key technical outcome:
  - removed dead eager `LinkedRE` import from `perl/LinkedSpec.pm`,
  - added a focused regression proving plain `require LinkedSpec` keeps `LinkedRE`
    unloaded until the compile path actually needs it.
- Regression outcome:
  - added `linkedspec_require_avoids_linkedre_load_until_get`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (215 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: remove dead LinkedRE import from LinkedSpec.pm` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::Compiler`.
- Key technical outcome:
  - removed eager `Data::Dumper` import from `perl/LinkedSpec/Compiler.pm`,
  - added `LinkedSpec::Compiler::_require_data_dumper_pkg(...)`,
  - added `LinkedSpec::Compiler::_dump_value(...)`,
  - updated traced compiler dump sites to lazy-load `Data::Dumper` only when
    structured formatting is actually needed.
- Regression outcome:
  - added `compiler_require_avoids_data_dumper_load_until_debug_pipeline_dump`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (214 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Data::Dumper through Compiler` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::SpecEntry`.
- Key technical outcome:
  - removed eager `Data::Dumper` import from `perl/LinkedSpec/SpecEntry.pm`,
  - added `LinkedSpec::SpecEntry::_require_data_dumper_pkg(...)`,
  - added `LinkedSpec::SpecEntry::_dump_value(...)`,
  - updated `compile_spec_entry(...)` to lazy-load `Data::Dumper` only for the
    high-verbosity `SPEC ENTRY DUMP` and `RULE INFO DUMP` trace paths.
- Regression outcome:
  - added `spec_entry_require_avoids_data_dumper_load_until_debug_compile_dump`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (213 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Data::Dumper through SpecEntry` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A façade load-time coupling slice completed against `LinkedSpec.pm`.
- Key technical outcome:
  - removed dead eager `Data::Dumper` import from `perl/LinkedSpec.pm`,
  - added a require-only regression proving plain `require LinkedSpec` keeps `Data::Dumper`
    unloaded.
- Regression outcome:
  - added `linkedspec_require_avoids_data_dumper_load`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (212 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: remove dead Data::Dumper import from LinkedSpec.pm` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::RuleIR`.
- Key technical outcome:
  - removed eager `Data::Dumper` import from `perl/LinkedSpec/RuleIR.pm`,
  - added `LinkedSpec::RuleIR::_require_data_dumper_pkg(...)`,
  - added `LinkedSpec::RuleIR::_dump_value(...)`,
  - updated `_build_rule_execution_meta(...)` to lazy-load `Data::Dumper` only when
    the debug-only `Rule meta` trace path runs.
- Regression outcome:
  - added `ruleir_require_avoids_data_dumper_load_until_debug_meta_dump`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (211 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Data::Dumper through RuleIR` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::Trace`.
- Key technical outcome:
  - removed eager `Data::Dumper` import from `perl/LinkedSpec/Trace.pm`,
  - added `LinkedSpec::Trace::_require_data_dumper_pkg(...)`,
  - updated `_trace_stringify(...)` to lazy-load `Data::Dumper` and use
    `Data::Dumper::Dumper(...)` only for referenced values.
- Regression outcome:
  - added `trace_require_avoids_data_dumper_load_until_stringify_ref`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/Trace.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (210 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Data::Dumper through Trace` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::RuleIR::EmitContext`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionRewriter` import from `perl/LinkedSpec/RuleIR/EmitContext.pm`,
  - added `LinkedSpec::RuleIR::EmitContext::_require_action_rewriter_pkg(...)`,
  - updated `_trim_action_ir_value(...)`, `_rewrite_action_code_with_diagnostics(...)`,
    `_accumulate_action_rewrite_diagnostics(...)`, and `_build_action_rewrite_rules(...)`
    to lazy-load `ActionRewriter.pm` before delegating.
- Regression outcome:
  - added `emit_context_require_avoids_action_rewriter_load_until_emit_context_build`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (209 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load ActionRewriter through RuleIR::EmitContext` until commit workflow runs, then reset to zero-byte untracked.

## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A load-time coupling slice completed against the `LinkedSpec.pm` façade trace surface.
- Key technical outcome:
  - removed eager `LinkedSpec::Trace` import from `perl/LinkedSpec.pm`,
  - added `LinkedSpec::_require_trace_pkg(...)`,
  - updated `configure_trace(...)`, `trace_enter(...)`, `trace_exit(...)`, `trace_decision(...)`,
    `log_output(...)`, `log_dump(...)`, and `should_dump(...)` to lazy-load `Trace.pm`
    before delegating while preserving `$@`,
  - kept the existing façade trace-state aliases (`$LinkedSpec::DUMP_VERBOSITY`,
    `$LinkedSpec::TRACE_LOG_FILE`, and related variables) as the compatibility surface,
  - updated parser-factory regression setup to explicitly `require LinkedSpec::Trace` when it
    intentionally localizes internal trace state, so façade loading can remain lazy.
- Regression outcome:
  - added `linkedspec_require_avoids_trace_load_until_public_trace_api`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (208 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Trace through facade` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::Compiler`.
- Key technical outcome:
  - removed eager `LinkedSpec::Trace` import from `perl/LinkedSpec/Compiler.pm`,
  - replaced Compiler-local dump constants with stable numeric values matching `Trace.pm`,
  - added `LinkedSpec::Compiler::_require_trace_pkg(...)`,
  - added `LinkedSpec::Compiler::_trace_log_output(...)`,
  - added `LinkedSpec::Compiler::_trace_log_dump(...)`,
  - added `LinkedSpec::Compiler::_trace_should_dump(...)`,
  - added `LinkedSpec::Compiler::_trace_enter(...)`,
  - added `LinkedSpec::Compiler::_trace_exit(...)`,
  - added `LinkedSpec::Compiler::_trace_decision(...)`,
  - added `LinkedSpec::Compiler::_trace_apply_trace_options(...)`,
  - added `LinkedSpec::Compiler::_trace_level_name_for_current_verbosity(...)`,
  - updated `spec_descr(...)`, `spec_gdata(...)`, `_build_action_rewriter_migration_summary(...)`,
    and `run_get_pipeline(...)` to route trace work through those owner helpers.
- Regression outcome:
  - added `compiler_require_avoids_trace_load_until_run_get_pipeline`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (207 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Trace through Compiler` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::SpecEntry`.
- Key technical outcome:
  - removed eager `LinkedSpec::Trace` import from `perl/LinkedSpec/SpecEntry.pm`,
  - replaced SpecEntry-local dump constants with stable numeric values matching `Trace.pm`,
  - added `LinkedSpec::SpecEntry::_require_trace_pkg(...)`,
  - added `LinkedSpec::SpecEntry::_trace_enter(...)`,
  - added `LinkedSpec::SpecEntry::_trace_exit(...)`,
  - added `LinkedSpec::SpecEntry::_trace_decision(...)`,
  - added `LinkedSpec::SpecEntry::_trace_log_dump(...)`,
  - added `LinkedSpec::SpecEntry::_trace_should_dump(...)`,
  - updated `compile_spec_entry(...)` and runtime handler construction to route trace work through those owner helpers.
- Regression outcome:
  - added `spec_entry_require_avoids_trace_load_until_compile_spec_entry`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (206 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Trace through SpecEntry` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::RuleIR`.
- Key technical outcome:
  - removed eager `LinkedSpec::Trace` import from `perl/LinkedSpec/RuleIR.pm`,
  - replaced RuleIR-local dump constants with stable numeric values matching `Trace.pm`,
  - added `LinkedSpec::RuleIR::_require_trace_pkg(...)`,
  - added `LinkedSpec::RuleIR::_trace_should_dump(...)`,
  - added `LinkedSpec::RuleIR::_trace_log_output(...)`,
  - added `LinkedSpec::RuleIR::_trace_decision(...)`,
  - updated execution-meta debug dumping to stay lazy when `Trace.pm` has not been loaded,
  - updated mixed-action validation diagnostics to lazy-load `Trace.pm` only when that error path actually emits output.
- Regression outcome:
  - added `ruleir_require_avoids_trace_load_until_mixed_action_error`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (205 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Trace through RuleIR` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::RuleIR::EmitContext`.
- Key technical outcome:
  - removed eager `LinkedSpec::Trace` import from `perl/LinkedSpec/RuleIR/EmitContext.pm`,
  - replaced the EmitContext-local `DUMP_LOW` constant with the stable numeric value matching `Trace.pm`,
  - added `LinkedSpec::RuleIR::EmitContext::_require_trace_pkg(...)`,
  - added `LinkedSpec::RuleIR::EmitContext::_trace_log_output(...)`,
  - updated unresolved-helper diagnostic logging in `_build_action_rewriter_meta(...)`
    to lazy-load `Trace.pm` only when that diagnostic path actually runs.
- Regression outcome:
  - added `emit_context_require_avoids_trace_load_until_unresolved_helper_diag`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (204 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Trace through RuleIR::EmitContext` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::Resolver`.
- Key technical outcome:
  - removed eager `LinkedSpec::Trace` import from `perl/LinkedSpec/Resolver.pm`,
  - replaced Resolver-local dump constants with stable numeric values matching `Trace.pm`,
  - added `LinkedSpec::Resolver::_require_trace_pkg(...)`,
  - added `LinkedSpec::Resolver::_trace_log_output(...)`,
  - added `LinkedSpec::Resolver::_trace_exit(...)`,
  - added `LinkedSpec::Resolver::_trace_decision(...)`,
  - updated invalid-spec, path-resolution, and file-open reporting paths to lazy-load `Trace.pm`
    only when they actually emit trace output.
- Regression outcome:
  - added `resolver_require_avoids_trace_load_until_invalid_spec_error`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/Resolver.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (203 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Trace through Resolver` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::Validation`.
- Key technical outcome:
  - removed eager `LinkedSpec::Trace` import from `perl/LinkedSpec/Validation.pm`,
  - replaced Validation-local dump constants with stable numeric values matching `Trace.pm`,
  - added `LinkedSpec::Validation::_require_trace_pkg(...)`,
  - added `LinkedSpec::Validation::_trace_log_output(...)`,
  - updated Validation error/warning reporting paths to lazy-load `Trace.pm`
    only when they actually emit log output.
- Regression outcome:
  - added `validation_require_avoids_trace_load_until_error_report`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/Validation.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (202 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Trace through Validation` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionRewriter`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::DeclareMethod` import from `perl/LinkedSpec/ActionRewriter.pm`,
  - added `LinkedSpec::ActionRewriter::_require_declare_method_pkg(...)`,
  - updated `_declare_method_deps(...)`, `_split_declare_symbol_names(...)`,
    `_parse_declare_binding_entry(...)`, `_lower_declare_value_expr(...)`,
    `_lower_declare_initializer_expr(...)`, `_extract_declare_statement_from_method_expr(...)`,
    `_lower_declare_method_statement(...)`, and `_lower_assign_method_statement(...)`
    to lazy-load `DeclareMethod.pm` only when declare-method helpers actually run.
- Regression outcome:
  - added `action_rewriter_require_avoids_declare_method_load_until_declare_helper`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (201 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load DeclareMethod through ActionRewriter` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionRewriter`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::MethodLowering` import from `perl/LinkedSpec/ActionRewriter.pm`,
  - added `LinkedSpec::ActionRewriter::_require_method_lowering_pkg(...)`,
  - updated `_method_lowering_deps(...)`, `_declare_alias_to_type(...)`,
    `_lower_typed_declare_statement(...)`, `_normalize_method_tag_expr(...)`,
    `_lower_method_value_expr(...)`, `_lower_return_general_statement(...)`,
    `_lower_return_imatch_statement(...)`, `_lower_assign_statement(...)`,
    `_lower_push_value_statement(...)`, `_lower_regex_subst_statement(...)`,
    `_lower_return_undef_statement(...)`, and `_lower_return_array_statement(...)`
    to lazy-load `MethodLowering.pm` only when method-lowering helpers actually run.
- Regression outcome:
  - added `action_rewriter_require_avoids_method_lowering_load_until_method_helper`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (200 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load MethodLowering through ActionRewriter` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionRewriter`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::ControlFlow` import from `perl/LinkedSpec/ActionRewriter.pm`,
  - added `LinkedSpec::ActionRewriter::_require_control_flow_pkg(...)`,
  - updated `_control_flow_deps(...)`, `_lower_if_flow_statement(...)`,
    `_lower_elseif_flow_statement(...)`, `_lower_else_flow_statement(...)`,
    `_lower_endif_flow_statement(...)`, `_lower_switch_flow_statement(...)`,
    `_lower_case_flow_statement(...)`, `_lower_default_flow_statement(...)`,
    `_lower_endcase_flow_statement(...)`, `_lower_endswitch_flow_statement(...)`,
    `_lower_say_statement(...)`, and `_lower_print_statement(...)`
    to lazy-load `ControlFlow.pm` only when flow-statement helpers actually run.
- Regression outcome:
  - added `action_rewriter_require_avoids_control_flow_load_until_control_helper`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (199 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load ControlFlow through ActionRewriter` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionRewriter`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::ValueExpr` import from `perl/LinkedSpec/ActionRewriter.pm`,
  - added `LinkedSpec::ActionRewriter::_require_value_expr_pkg(...)`,
  - updated `_value_expr_deps(...)`, `_extract_scalar_symbol_name(...)`,
    `_extract_array_symbol_name(...)`, `_extract_hash_symbol_name(...)`,
    `_lower_scalar_access_key_expr(...)`, `_lower_scalaref_value_expr(...)`,
    `_infer_scalar_container_kind(...)`, `_lower_assignment_source_expr(...)`,
    and `_strip_literal_delimiters(...)` to lazy-load `ValueExpr.pm`
    only when value helpers actually run.
- Regression outcome:
  - added `action_rewriter_require_avoids_value_expr_load_until_value_helper`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (198 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load ValueExpr through ActionRewriter` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionRewriter`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::ArrayPipeline` import from `perl/LinkedSpec/ActionRewriter.pm`,
  - added `LinkedSpec::ActionRewriter::_require_array_pipeline_pkg(...)`,
  - updated `_array_pipeline_deps(...)`, `_build_array_pipeline_plan_from_expr(...)`,
    and `_lower_array_pipeline_expr(...)` to lazy-load `ArrayPipeline.pm`
    only when array helpers actually run.
- Regression outcome:
  - added `action_rewriter_require_avoids_array_pipeline_load_until_array_helper`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (197 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load ArrayPipeline through ActionRewriter` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionRewriter`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::FlowExpr` import from `perl/LinkedSpec/ActionRewriter.pm`,
  - added `LinkedSpec::ActionRewriter::_require_flow_expr_pkg(...)`,
  - updated `_flow_expr_deps(...)` and `_lower_flow_composite_expr(...)`
    to lazy-load `FlowExpr.pm` only when flow helpers actually run.
- Regression outcome:
  - added `action_rewriter_require_avoids_flow_expr_load_until_flow_helper`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (196 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load FlowExpr through ActionRewriter` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionRewriter`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::RewritePipeline` import from `perl/LinkedSpec/ActionRewriter.pm`,
  - added `LinkedSpec::ActionRewriter::_require_rewrite_pipeline_pkg(...)`,
  - updated `_rewrite_pipeline_deps(...)`, `_lower_action_code_from_canonical_ir(...)`,
    `_rewrite_action_code_with_diagnostics(...)`, and `_build_action_rewrite_rules(...)`
    to lazy-load `RewritePipeline.pm` only when rewrite helpers actually run.
- Regression outcome:
  - added `action_rewriter_require_avoids_rewrite_pipeline_load_until_rewrite_helper`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (195 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load RewritePipeline through ActionRewriter` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionRewriter`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::Contracts` import from `perl/LinkedSpec/ActionRewriter.pm`,
  - added `LinkedSpec::ActionRewriter::_require_contracts_pkg(...)`,
  - updated `_action_contract_deps(...)` and `_build_action_lowering_contracts(...)`
    to lazy-load `Contracts.pm` only when lowering-contract helper paths actually run.
- Regression outcome:
  - added `action_rewriter_require_avoids_contracts_load_until_contract_helper`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (194 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Contracts through ActionRewriter` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionRewriter`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::StatementSplit` import from `perl/LinkedSpec/ActionRewriter.pm`,
  - added `LinkedSpec::ActionRewriter::_require_statement_split_pkg(...)`,
  - updated `_statement_split_deps(...)` and `_split_action_ir_statements(...)`
    to lazy-load `StatementSplit.pm` only when split helper paths actually run.
- Regression outcome:
  - added `action_rewriter_require_avoids_statement_split_load_until_split_helper`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (193 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load StatementSplit through ActionRewriter` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionRewriter`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::Scanner` import from `perl/LinkedSpec/ActionRewriter.pm`,
  - added `LinkedSpec::ActionRewriter::_require_scanner_pkg(...)`,
  - updated `_scan_contract_ir_event_deps(...)` and `_scan_contract_ir_events(...)`
    to lazy-load `Scanner.pm` only when scanner helper paths actually run.
- Regression outcome:
  - added `action_rewriter_require_avoids_scanner_load_until_scan_helper`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (192 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Scanner through ActionRewriter` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionRewriter`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::Diagnostics` import from `perl/LinkedSpec/ActionRewriter.pm`,
  - added `LinkedSpec::ActionRewriter::_require_diagnostics_pkg(...)`,
  - updated `_diagnostics_deps(...)`, `_find_unresolved_action_helpers(...)`,
    `_collect_action_helper_ir_nodes(...)`, and `_accumulate_action_rewrite_diagnostics(...)`
    to lazy-load `Diagnostics.pm` only when diagnostics helpers actually run.
- Regression outcome:
  - added `action_rewriter_require_avoids_diagnostics_load_until_diag_helper`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (191 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Diagnostics through ActionRewriter` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionRewriter`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::CanonicalEvents` import from `perl/LinkedSpec/ActionRewriter.pm`,
  - added `LinkedSpec::ActionRewriter::_require_canonical_events_pkg(...)`,
  - updated `_canonical_event_deps(...)`, `_canonicalize_helper_action_ir_event(...)`,
    and `_build_canonical_action_ir_events(...)` to lazy-load `CanonicalEvents.pm`
    only when canonical-event helpers actually run.
- Regression outcome:
  - added `action_rewriter_require_avoids_canonical_events_load_until_canonical_build`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (190 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load CanonicalEvents through ActionRewriter` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionRewriter`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::MethodExpr` import from `perl/LinkedSpec/ActionRewriter.pm`,
  - added `LinkedSpec::ActionRewriter::_require_pkg(...)`,
  - added `LinkedSpec::ActionRewriter::_require_method_expr_pkg(...)`,
  - updated `_parse_method_function_expr(...)`, `_is_bare_method_scope_token(...)`,
    `_normalize_method_args_with_optional_scope(...)`, and `_split_top_level_csv(...)`
    to lazy-load `MethodExpr.pm` only when method-expression helpers actually run,
  - updated `_scan_contract_ir_event_deps(...)` so scanner dep resolution loads
    `MethodExpr.pm` before `ActionIR::Scanner` resolves its direct method-expression callbacks.
- Regression outcome:
  - updated `action_rewriter_require_avoids_linkedspec_deps_load`,
  - added `action_rewriter_require_avoids_method_expr_load_until_parse_helper`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (189 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load MethodExpr through ActionRewriter` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionIR::ScannerCore`.
- Key technical outcome:
  - removed eager imports of `LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules`,
    `PrimitivePipelineRules`, `FlowRules`, and `LegacyRules` from `perl/LinkedSpec/ActionIR/ScannerCore.pm`,
  - added `LinkedSpec::ActionIR::ScannerCore::_require_pkg(...)`,
  - updated `_scanner_dispatchers(...)` to lazy-load the scanner rule packages only when contract scanning actually starts.
- Regression outcome:
  - added `actionir_scannercore_require_avoids_scanner_rule_load_until_scan`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ScannerCore.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (188 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load scanner rule packages through ActionIR::ScannerCore` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionIR::StatementSplit::Core`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::StatementSplit::Mode` import from `perl/LinkedSpec/ActionIR/StatementSplit/Core.pm`,
  - added `LinkedSpec::ActionIR::StatementSplit::Core::_require_pkg(...)`,
  - added `LinkedSpec::ActionIR::StatementSplit::Core::_require_statement_split_mode_pkg(...)`,
  - updated `split_action_ir_statements(...)` to lazy-load `StatementSplit::Mode.pm` only when statement splitting actually starts.
- Regression outcome:
  - added `actionir_statement_split_core_require_avoids_mode_load_until_split`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit/Core.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (187 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load StatementSplit::Mode through ActionIR::StatementSplit::Core` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionIR::CanonicalEvents`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::CanonicalEvents::Core` import from `perl/LinkedSpec/ActionIR/CanonicalEvents.pm`,
  - added `LinkedSpec::ActionIR::CanonicalEvents::_require_pkg(...)`,
  - added `LinkedSpec::ActionIR::CanonicalEvents::_require_canonical_events_core_pkg(...)`,
  - updated `_canonicalize_helper_action_ir_event(...)` to lazy-load `CanonicalEvents::Core.pm` only when canonical-event building actually starts.
- Regression outcome:
  - added `actionir_canonical_events_require_avoids_core_load_until_build`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (186 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load CanonicalEvents::Core through ActionIR::CanonicalEvents` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionIR::StatementSplit`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::StatementSplit::Core` import from `perl/LinkedSpec/ActionIR/StatementSplit.pm`,
  - added `LinkedSpec::ActionIR::StatementSplit::_require_pkg(...)`,
  - added `LinkedSpec::ActionIR::StatementSplit::_require_statement_split_core_pkg(...)`,
  - updated `_split_action_ir_statements(...)` to lazy-load `StatementSplit::Core.pm` only when statement splitting actually starts.
- Regression outcome:
  - added `actionir_statement_split_require_avoids_core_load_until_split`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (185 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load StatementSplit::Core through ActionIR::StatementSplit` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::ActionIR::Scanner`.
- Key technical outcome:
  - removed eager `LinkedSpec::ActionIR::ScannerCore` import from `perl/LinkedSpec/ActionIR/Scanner.pm`,
  - added `LinkedSpec::ActionIR::Scanner::_require_pkg(...)`,
  - added `LinkedSpec::ActionIR::Scanner::_require_scanner_core_pkg(...)`,
  - updated `scan_contract_ir_events(...)` to lazy-load `ScannerCore.pm` only when contract scanning actually starts.
- Regression outcome:
  - added `actionir_scanner_require_avoids_scannercore_load_until_scan`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (184 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load ScannerCore through ActionIR::Scanner` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::BootstrapSpec`.
- Key technical outcome:
  - removed eager `LinkedSpec::BootstrapSpec::Core` import from `perl/LinkedSpec/BootstrapSpec.pm`,
  - added `LinkedSpec::BootstrapSpec::_require_pkg(...)`,
  - added `LinkedSpec::BootstrapSpec::_require_bootstrap_core_pkg(...)`,
  - updated `build_bootstrap_spec(...)` to lazy-load `BootstrapSpec::Core.pm` only when bootstrap grammar state is actually requested.
- Regression outcome:
  - added `bootstrap_spec_require_avoids_core_load_until_bootstrap_state_build`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (183 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load BootstrapSpec::Core through BootstrapSpec` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::RuleIR`.
- Key technical outcome:
  - removed eager `LinkedSpec::RuleIR::EmitContext` import from `perl/LinkedSpec/RuleIR.pm`,
  - added `LinkedSpec::RuleIR::_require_pkg(...)`,
  - added `LinkedSpec::RuleIR::_require_emit_context_pkg(...)`,
  - updated `_normalize_rule_code_chunks(...)` and `_build_rule_ir_emit_context(...)` to lazy-load `EmitContext.pm` only when the emit-context stage actually runs.
- Regression outcome:
  - added `ruleir_require_avoids_emit_context_load_until_emit_context_build`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (182 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load EmitContext through RuleIR` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-12)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::SpecEntry`.
- Key technical outcome:
  - removed eager `LinkedSpec::RuleIR` import from `perl/LinkedSpec/SpecEntry.pm`,
  - added `LinkedSpec::SpecEntry::_require_pkg(...)`,
  - added `LinkedSpec::SpecEntry::_require_rule_ir_pkg(...)`,
  - updated `compile_spec_entry(...)` to lazy-load `RuleIR.pm` only when staged rule compilation actually begins.
- Regression outcome:
  - added `spec_entry_require_avoids_ruleir_load_until_compile_spec_entry`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (181 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load RuleIR through SpecEntry` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::Compiler`.
- Key technical outcome:
  - removed eager `LinkedSpec::BootstrapSpec`, `LinkedSpec::SpecEntry`, and `LinkedSpec::Validation` imports from `perl/LinkedSpec/Compiler.pm`,
  - added `LinkedSpec::Compiler::_require_pkg(...)`,
  - updated compiler default owner paths to lazy-load those modules only when `spec_descr(...)` or `run_get_pipeline(...)` actually uses them.
- Regression outcome:
  - added `compiler_require_avoids_owner_load_until_run_get_pipeline`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (180 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Compiler owner modules` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Phase 1A submodule load-time coupling slice completed against `LinkedSpec::Runtime`.
- Key technical outcome:
  - removed eager `LinkedSpec::Compiler` import from `perl/LinkedSpec/Runtime.pm`,
  - added `LinkedSpec::Runtime::_require_pkg(...)`,
  - updated `run_get(...)` to lazy-load `Compiler.pm` only when the runtime compile path is invoked.
- Regression outcome:
  - added `runtime_require_avoids_compiler_load_until_run_get`.
- Validation snapshot:
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (179 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Compiler through Runtime` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Phase 1A load-time coupling slice completed against the façade's eager parser/plugin edge imports.
- Key technical outcome:
  - removed eager `ParserFactory` and `PluginBridge` imports from `LinkedSpec.pm`,
  - updated `get_parser(...)` and `AUTOLOAD` to lazy-load those owners only when their symbols are not already present.
- Regression outcome:
  - added `linkedspec_require_avoids_parser_factory_load_until_get_parser`,
  - added `linkedspec_require_avoids_plugin_bridge_load_until_autoload`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (178 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load ParserFactory and PluginBridge through facade` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Phase 1A load-time coupling slice completed against the façade's eager compile-pipeline imports.
- Key technical outcome:
  - added `LinkedSpec::_require_pkg(...)`,
  - removed eager `Runtime`, `Compiler`, and `ActionRewriter` imports from `LinkedSpec.pm`,
  - updated `Get(...)`, `spec_descr(...)`, and `call_spec_handler_subst(...)` to lazy-load their owner packages on demand.
- Regression outcome:
  - added `linkedspec_require_avoids_compile_pipeline_load_until_get`,
  - added `linkedspec_require_avoids_compiler_load_until_spec_descr`,
  - added `linkedspec_require_avoids_action_rewriter_load_until_compat_helper`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (176 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load compile pipeline owners through facade` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Phase 1A load-time coupling slice completed against the façade's direct `Resolver` import.
- Key technical outcome:
  - added `LinkedSpec::ParserFactory::_require_pkg(...)`,
  - updated `LinkedSpec::ParserFactory::_require_pkg_cb(...)` to lazy-load callback owner packages,
  - removed `use LinkedSpec::Resolver ();` from `LinkedSpec.pm`.
- Regression outcome:
  - added `linkedspec_require_avoids_resolver_load_until_get_parser`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (173 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: lazy-load Resolver through ParserFactory` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Backbone Item #3 cleanup slice completed against the last remaining parser-factory `LinkedSpec::Deps` coupling.
- Key technical outcome:
  - added `_require_pkg_cb(...)` and `_require_pkg_value(...)` to `LinkedSpec::ParserFactory`,
  - moved `LinkedSpec::ParserFactory::_default_deps()` to local owner-built callback wiring,
  - deleted `perl/LinkedSpec/Deps.pm` after removing its last active entrypoint.
- Regression outcome:
  - added `get_parser_avoids_removed_deps_parser_factory_dep_builder`,
  - added `parser_factory_require_avoids_linkedspec_deps_load`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (172 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: remove final ParserFactory Deps builder` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Backbone Item #3 cleanup slice completed against ActionRewriter's last load-time `LinkedSpec::Deps` coupling.
- Key technical outcome:
  - removed `use LinkedSpec::Deps ();` from `LinkedSpec::ActionRewriter`,
  - removed the dead `LinkedSpec::Deps::declare_method_deps_for_package(...)` helper,
  - `require LinkedSpec::ActionRewriter` now stays on extracted ActionIR owner modules without pulling `LinkedSpec::Deps` into `%INC`.
- Regression outcome:
  - added `action_rewriter_require_avoids_linkedspec_deps_load`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (170 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: drop ActionRewriter Deps import` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Backbone Item #3 cleanup slice completed against method-lowering default dependency ownership.
- Key technical outcome:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::MethodLowering`,
  - `LinkedSpec::ActionRewriter::_method_lowering_deps()` now resolves through `MethodLowering` instead of `Deps`,
  - removed the now-unused `LinkedSpec::Deps::method_lowering_deps_for_package(...)`.
- Regression outcome:
  - added `action_rewriter_avoids_deps_method_lowering_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (169 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: move method lowering default deps into MethodLowering` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Backbone Item #3 cleanup slice completed against control-flow default dependency ownership.
- Key technical outcome:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::ControlFlow`,
  - `LinkedSpec::ActionRewriter::_control_flow_deps()` now resolves through `ControlFlow` instead of `Deps`,
  - removed the now-unused `LinkedSpec::Deps::control_flow_deps_for_package(...)`.
- Regression outcome:
  - added `action_rewriter_avoids_deps_control_flow_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (168 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: move control flow default deps into ControlFlow` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Backbone Item #3 cleanup slice completed against array-pipeline default dependency ownership.
- Key technical outcome:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::ArrayPipeline`,
  - `LinkedSpec::ActionRewriter::_array_pipeline_deps()` now resolves through `ArrayPipeline` instead of `Deps`,
  - removed the now-unused `LinkedSpec::Deps::array_pipeline_deps_for_package(...)`.
- Regression outcome:
  - added `action_rewriter_avoids_deps_array_pipeline_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (167 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: move array pipeline default deps into ArrayPipeline` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Backbone Item #3 cleanup slice completed against flow-expression default dependency ownership.
- Key technical outcome:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::FlowExpr`,
  - `LinkedSpec::ActionRewriter::_flow_expr_deps()` now resolves through `FlowExpr` instead of `Deps`,
  - removed the now-unused `LinkedSpec::Deps::flow_expr_deps_for_package(...)`.
- Regression outcome:
  - added `action_rewriter_avoids_deps_flow_expr_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (166 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: move flow expr default deps into FlowExpr` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Backbone Item #3 cleanup slice completed against value-expression default dependency ownership.
- Key technical outcome:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::ValueExpr`,
  - `LinkedSpec::ActionRewriter::_value_expr_deps()` now resolves through `ValueExpr` instead of `Deps`,
  - removed the now-unused `LinkedSpec::Deps::value_expr_deps_for_package(...)`.
- Regression outcome:
  - added `action_rewriter_avoids_deps_value_expr_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ValueExpr.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (165 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: move value expr default deps into ValueExpr` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Backbone Item #3 cleanup slice completed against action-contract default dependency ownership.
- Key technical outcome:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::Contracts`,
  - `LinkedSpec::ActionRewriter::_action_contract_deps()` now resolves through `Contracts` instead of `Deps`,
  - removed the now-unused `LinkedSpec::Deps::action_rewriter_contract_deps_for_package(...)`.
- Regression outcome:
  - added `action_rewriter_avoids_deps_action_contract_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (164 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: move action contract default deps into Contracts` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Backbone Item #3 cleanup slice completed against specialized declare-method default dependency ownership.
- Key technical outcome:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::DeclareMethod`,
  - `LinkedSpec::ActionRewriter::_declare_method_deps()` now resolves through `DeclareMethod` instead of `Deps`,
  - removed the now-unused `LinkedSpec::Deps::action_rewriter_declare_method_deps_for_package(...)`.
- Regression outcome:
  - added `action_rewriter_avoids_deps_declare_method_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/DeclareMethod.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (163 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: move declare method default deps into DeclareMethod` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Backbone Item #3 cleanup slice completed against rewrite-pipeline default dependency ownership.
- Key technical outcome:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::RewritePipeline`,
  - `LinkedSpec::ActionRewriter::_rewrite_pipeline_deps()` now resolves through `RewritePipeline` instead of `Deps`,
  - removed the now-unused `LinkedSpec::Deps::action_rewriter_rewrite_pipeline_deps_for_package(...)`.
- Regression outcome:
  - added `action_rewriter_avoids_deps_rewrite_pipeline_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (162 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: move rewrite pipeline default deps into RewritePipeline` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Backbone Item #3 cleanup slice completed against diagnostics default dependency ownership.
- Key technical outcome:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::Diagnostics`,
  - `LinkedSpec::ActionRewriter::_diagnostics_deps()` now resolves through `Diagnostics` instead of `Deps`,
  - removed the now-unused `LinkedSpec::Deps::action_rewriter_diagnostics_deps_for_package(...)`.
- Regression outcome:
  - added `action_rewriter_avoids_deps_diagnostics_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Diagnostics.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (161 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: move diagnostics default deps into Diagnostics` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Backbone Item #3 cleanup slice completed against canonical-event default dependency ownership.
- Key technical outcome:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::CanonicalEvents`,
  - `LinkedSpec::ActionRewriter::_canonical_event_deps()` now resolves through `CanonicalEvents` instead of `Deps`,
  - removed the now-unused `LinkedSpec::Deps::action_rewriter_canonical_event_deps_for_package(...)`.
- Regression outcome:
  - added `action_rewriter_avoids_deps_canonical_event_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (160 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: move canonical event default deps into CanonicalEvents` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Backbone Item #3 cleanup slice completed against statement-split default dependency ownership.
- Key technical outcome:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::StatementSplit`,
  - `LinkedSpec::ActionRewriter::_statement_split_deps()` now resolves through `StatementSplit` instead of `Deps`,
  - removed the now-unused `LinkedSpec::Deps::action_rewriter_statement_split_deps_for_package(...)`.
- Regression outcome:
  - added `action_rewriter_avoids_deps_statement_split_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (159 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: move statement split default deps into StatementSplit` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Backbone Item #3 cleanup slice completed against scanner default dependency ownership.
- Key technical outcome:
  - added `_require_pkg_cb(...)` and `default_deps_for_package(...)` to `LinkedSpec::ActionIR::Scanner`,
  - `LinkedSpec::ActionRewriter::_scan_contract_ir_event_deps()` now resolves through `Scanner` instead of `Deps`,
  - removed the now-unused `LinkedSpec::Deps::action_rewriter_scanner_deps_for_package(...)`.
- Regression outcome:
  - added `action_rewriter_avoids_deps_scanner_dep_builder`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Deps.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (158 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: move scanner default deps into Scanner` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted Backbone Item #3 cleanup slice completed against `LinkedSpec::ActionIR::ScannerCore`.
- Key technical outcome:
  - added `_scanner_rule_dep_bindings(...)`, `_with_scanner_rule_deps(...)`, and `_scanner_dispatchers()` to `ScannerCore`,
  - `scan_contract_ir_events(...)` now routes scanner-rule dependency rebinding and dispatch-chain selection through those owner helpers,
  - the scanner rule packages still execute through the same active helper callbacks and scan order.
- Regression outcome:
  - added `actionir_scannercore_uses_scanner_dep_binding_owner`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ScannerCore.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (157 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone Item 3: move scanner dep rebinding into ScannerCore owner` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted LinkedSpec-only plugin bridge slice completed against default legacy runtime dependency ownership in `LinkedSpec::PluginBridge`.
- Key technical outcome:
  - added `_load_legacy_plugin_runtime(...)` and `_exec_legacy_plugin(...)` to `LinkedSpec::PluginBridge`,
  - `LinkedSpec::PluginBridge::_default_deps()` now routes through those explicit owner helpers instead of inline closures,
  - the bridge keeps the same legacy `AUTOLOAD` behavior while exposing a cleaner internal replacement seam.
- Regression outcome:
  - added `plugin_bridge_default_load_dep_uses_legacy_runtime_owner`,
  - added `plugin_bridge_default_exec_dep_uses_legacy_exec_owner`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (156 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Plugin bridge: move default legacy runtime deps onto owner helpers` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted LinkedSpec-only plugin bridge slice completed against autoload normalization/explicit-name dispatch ownership in `LinkedSpec::PluginBridge`.
- Key technical outcome:
  - added `_require_plugin_name(...)` and `_dispatch_plugin_name(...)` to `LinkedSpec::PluginBridge`,
  - `_dispatch_autoload(...)` now only normalizes the autoload name and delegates explicit-name runtime dispatch to `_dispatch_plugin_name(...)`,
  - explicit plugin-name validation and injected runtime execution now have a dedicated bridge owner seam.
- Regression outcome:
  - added `plugin_bridge_dispatch_plugin_name_supports_injected_runtime_deps`,
  - added `plugin_bridge_dispatch_plugin_name_rejects_invalid_name_before_runtime_load`,
  - added `plugin_bridge_autoload_uses_dispatch_plugin_name_owner`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (154 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Plugin bridge: split explicit-name dispatch owner` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted plugin/runtime modernization slice completed against repo-owned explicit plugin callers outside the `PluginBridge` autoload path.
- Key technical outcome:
  - `HUtils::GenericFilter(...)`, `RTLUtils`, `TableScript::http_exec(...)`, and `plugin/string.plg` now call `PPlugin::exec_plugin_name(...)`,
  - repo-owned explicit plugin-name callers no longer need the mixed-name `PPlugin::exec(...)` compatibility wrapper,
  - remaining mixed-name compatibility use is narrowed further toward autoload-style and external legacy callers.
- Regression outcome:
  - added `tablescript_http_exec_uses_pplugin_explicit_name_owner`,
  - added `hutils_generic_filter_uses_pplugin_explicit_name_owner`.
- Validation snapshot:
  - `perl -Iperl -c perl/HUtils.pm` => syntax OK
  - `perl -Iperl -c perl/RTLUtils.pm` => syntax OK
  - `perl -Iperl -c perl/TableScript.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (151 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Plugin runtime: migrate internal explicit callers` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted plugin/runtime modernization slice completed against `PPlugin` eager module-load coupling to `LinkedSpec`.
- Key technical outcome:
  - removed eager `use LinkedSpec;` from `PPlugin.pm`,
  - added explicit `Cwd`, `File::Basename`, and `File::Spec` ownership in `PPlugin.pm`,
  - `PPlugin::_default_deps()->{load_plugin_parser}` now lazy-loads `LinkedSpec` only when the default parser callback is executed.
- Regression outcome:
  - added `pplugin_require_does_not_eagerly_load_linkedspec`,
  - added `pplugin_default_parser_dep_lazy_loads_linkedspec`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/PPlugin.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (149 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Plugin runtime: lazy-load LinkedSpec from PPlugin deps` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted plugin/runtime modernization slice completed against the legacy registry-construction seam inside `PPlugin::new(...)`.
- Key technical outcome:
  - added `_require_dep(...)`, `_default_deps()`, and `_load_legacy_registry(...)` to `PPlugin`,
  - `PPlugin::new(...)` now builds its cached legacy registry through the explicit `_load_legacy_registry()` seam instead of calling parser load/discovery/registry helpers inline,
  - the default dependency map now makes `pplugin` parser loading, `.plg` discovery, and registry assembly explicit owner callbacks.
- Regression outcome:
  - added `pplugin_load_legacy_registry_uses_explicit_dependency_callbacks`,
  - added `pplugin_default_registry_deps_load_through_explicit_owner_paths`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/PPlugin.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (147 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Plugin runtime: extract explicit PPlugin registry loader deps` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted plugin/runtime modernization slice completed against the legacy plugin-execution seam between `LinkedSpec::PluginBridge` and `PPlugin`.
- Key technical outcome:
  - added `PPlugin::exec_plugin_name(...)` as the explicit owner path for normalized plugin-name dispatch,
  - added `PPlugin::_normalize_plugin_name(...)` so the older `PPlugin::exec(...)` and `AUTOLOAD` compatibility surfaces normalize before delegating,
  - `LinkedSpec::PluginBridge::_default_deps()` now executes through `PPlugin::exec_plugin_name(...)` instead of `PPlugin::exec(...)`.
- Regression outcome:
  - added `plugin_bridge_default_exec_dep_uses_pplugin_explicit_name_owner`,
  - added `pplugin_exec_wrapper_normalizes_to_explicit_name_owner`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/PPlugin.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (145 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Plugin runtime: route bridge exec through explicit PPlugin owner` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-11)
- Uncommitted plugin/runtime modernization slice completed against the legacy `.plg` registry builder in `PPlugin`.
- Key technical outcome:
  - added `_build_plugin_registry(...)` to `PPlugin`,
  - `PPlugin::new(...)` now routes ordered legacy `.plg` files through that helper instead of building the registry inline,
  - duplicate plugin names still resolve by later-file override order, and malformed plugin parses are skipped with warning.
- Regression outcome:
  - added `pplugin_build_plugin_registry_preserves_file_order_and_skips_parse_failures`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/PPlugin.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (143 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Plugin runtime: extract explicit legacy registry builder` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted plugin/runtime modernization slice completed against the legacy `.plg` adapter in `PPlugin`.
- Key technical outcome:
  - added `_plugin_project_root(...)`, `_legacy_plugin_search_roots(...)`, and `_legacy_plugin_files(...)` to `PPlugin`,
  - `PPlugin::new(...)` now enumerates plugin files through explicit cwd-first roots instead of brace-glob expansion,
  - legacy `.plg` file enumeration is now sorted per root and deduped by file path.
- Regression outcome:
  - added `pplugin_legacy_plugin_search_roots_are_cwd_first_and_deduped`,
  - added `pplugin_legacy_plugin_files_are_sorted_and_deduped`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/PPlugin.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (142 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Plugin runtime: make legacy .plg file discovery deterministic` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted plugin/runtime modernization slice completed against the legacy `AUTOLOAD` compatibility bridge in `LinkedSpec::PluginBridge`.
- Key technical outcome:
  - added `_normalize_plugin_name(...)` to `LinkedSpec::PluginBridge`,
  - `_dispatch_autoload(...)` now normalizes the full Perl autoload name to an explicit plugin name before runtime dispatch,
  - invalid autoload names now fail before legacy plugin runtime load/exec side effects.
- Regression outcome:
  - `plugin_bridge_supports_injected_plugin_runtime_deps` now proves the exec callback receives normalized plugin names,
  - added `plugin_bridge_rejects_invalid_autoload_name_before_runtime_load` to prove invalid autoload names do not load the runtime or call exec.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (140 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Plugin runtime: normalize PluginBridge dispatch to explicit plugin names` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A cleanup slice completed against the dead validation facade wrappers in `LinkedSpec.pm`.
- Key technical outcome:
  - removed `get_dsl_context(...)`, `report_dsl_error(...)`, `validate_spec_content(...)`, `validate_rule_definition(...)`, `validate_gdata_references(...)`, `validate_dsl_syntax(...)`, and `extract_regex_literals_from_rule_rhs(...)` from `LinkedSpec.pm`,
  - removed the now-unused `LinkedSpec::Validation` import from `LinkedSpec.pm`,
  - active compile-time validation and DSL error reporting now remain on `LinkedSpec::Validation`.
- Regression outcome:
  - `get_parser_malformed_spec_reports_validation_error` now traps the removed validation helper names and proves malformed-spec diagnostics still route through the `LinkedSpec::Validation` owner path,
  - added `get_return_descr_avoids_removed_linkedspec_validation_facade` to prove successful descriptor-build paths do not depend on the removed helper names.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Validation.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (139 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: remove dead validation facade wrappers` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A cleanup slice completed against the dead internal trace/runtime helper wrappers in `LinkedSpec.pm`.
- Key technical outcome:
  - removed `_trace_level_name(...)`, `_apply_trace_options(...)`, and `_emit_parser_source_line(...)` from `LinkedSpec.pm`,
  - active trace/parser-source behavior now remains on `LinkedSpec::Trace`, `LinkedSpec::ParserFactory`, and `LinkedSpec::SpecEntry`.
- Regression outcome:
  - `get_parser_avoids_linkedspec_parser_factory_facade` now traps `_trace_level_name(...)` as part of the removed trace helper surface,
  - `spec_entry_compile_spec_entry_uses_injected_runtime_context` now traps `_emit_parser_source_line(...)` and proves parser-source emission still uses injected runtime context only.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Trace.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (138 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: remove dead internal trace and runtime helper wrappers` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A cleanup slice completed against the dead internal ActionIR lowering/dependency delegate block in `LinkedSpec.pm`.
- Key technical outcome:
  - removed the stale internal dependency builders and lowering/parser/extraction wrappers for flow expressions, declare/method lowering, value lowering, array-pipeline lowering, and fluent control-flow lowering,
  - removed the now-unused ActionIR/Deps import surface from `LinkedSpec.pm`,
  - active helper lowering now remains on `LinkedSpec::ActionRewriter` plus the extracted ActionIR owner modules.
- Regression outcome:
  - renamed and expanded the seam lock to `action_rewriter_avoids_removed_linkedspec_lowering_facade`,
  - the regression traps the removed helper names and proves broader flow/value/pipeline lowering still succeeds through owner modules only.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (138 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: remove dead internal actionir lowering delegate block` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A cleanup slice completed against the dead internal `Compiler`/`RuleIR`/action-contract delegate block in `LinkedSpec.pm`.
- Key technical outcome:
  - removed the stale internal `LinkedSpec.pm` delegates for descriptor-level migration summary, action-contract defaults, RuleIR collection/planning/validation, and emit-context assembly,
  - active descriptor/rule-compilation flow now remains on `LinkedSpec::Compiler`, `LinkedSpec::SpecEntry`, `LinkedSpec::RuleIR`, and `LinkedSpec::ActionRewriter`,
  - no live repo path still depends on the deleted internal delegate names.
- Regression outcome:
  - added `spec_descr_and_get_avoid_removed_linkedspec_ruleir_internal_facade`,
  - the regression traps the removed helper names and proves both `spec_descr(...)` and `Get(..., return_descr => 1)` still succeed through the owner modules only.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (138 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: remove dead internal ruleir and descriptor delegate block` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A cleanup slice completed against the dead internal ActionRewriter delegate block in `LinkedSpec.pm`.
- Key technical outcome:
  - removed the stale internal `LinkedSpec.pm` delegates for unresolved-helper scanning, rewrite-rule construction, canonical event construction, statement splitting, canonical lowering, and rewrite diagnostics accumulation,
  - active rewrite flow now remains on `LinkedSpec::ActionRewriter` plus `LinkedSpec::RuleIR::EmitContext`,
  - `LinkedSpec::call_spec_handler_subst(...)` remains the only public compatibility/test shim on this surface.
- Regression outcome:
  - renamed and expanded the seam lock to `ruleir_emit_context_avoids_removed_linkedspec_action_rewriter_facade`,
  - the regression traps the removed helper names and proves `build_rule_ir_emit_context(...)` still succeeds without them.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (137 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: remove dead internal action rewriter facade block` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A cleanup slice completed against the stale runtime `compile_spec_entry(...)` wrapper in `LinkedSpec::Runtime`.
- Key technical outcome:
  - removed `LinkedSpec::Runtime::compile_spec_entry(...)`,
  - active rule-entry compilation now remains owned by `LinkedSpec::SpecEntry` plus injected `runtime_ctx`,
  - no live repo path still depends on the deleted runtime wrapper.
- Regression outcome:
  - direct injected-state coverage now targets `LinkedSpec::SpecEntry::compile_spec_entry(...)` via `spec_entry_compile_spec_entry_uses_injected_runtime_context`,
  - existing wrapper-bypass regressions still prove the active descriptor-build paths do not depend on the removed runtime wrapper.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (137 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: remove runtime compile_spec_entry wrapper` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A cleanup slice completed against the stale façade `spec_entry(...)` helper in `LinkedSpec.pm`.
- Key technical outcome:
  - removed `LinkedSpec::spec_entry(...)`,
  - active rule-entry compilation now remains owned exclusively by `LinkedSpec::SpecEntry`,
  - no live repo path still depends on the deleted façade rule-entry helper.
- Regression outcome:
  - added `spec_descr_paths_avoid_linkedspec_spec_entry_facade`,
  - the regression traps the removed façade helper name and proves both `LinkedSpec::spec_descr(...)` and `LinkedSpec::Get(..., return_descr => 1)` still build compiled handlers directly through the owner path.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (137 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: drop facade spec_entry helper` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A cleanup slice completed against the legacy raw-argument runtime wrapper in `LinkedSpec::Runtime`.
- Key technical outcome:
  - removed `LinkedSpec::Runtime::run_get_from_args(...)`,
  - active runtime entrypoints now normalize into `LinkedSpec::Runtime::run_get(...)` only,
  - no live repo path still depends on the deleted raw-arg runtime wrapper.
- Regression outcome:
  - added `runtime_run_get_avoids_legacy_raw_arg_wrapper`,
  - the regression traps the removed wrapper name and proves `LinkedSpec::Runtime::run_get(..., { return_descr => 1 })` still returns a descriptor hash directly.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (136 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: remove runtime raw-arg wrapper` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A cleanup slice completed against the stale façade `spec_gdata(...)` helper in `LinkedSpec.pm`.
- Key technical outcome:
  - removed `LinkedSpec::spec_gdata(...)`,
  - active final descriptor `gdata` compilation remains owned exclusively by `LinkedSpec::Compiler`,
  - `LinkedSpec::Runtime::run_get(...)` no longer has a façade-level `gdata` helper alias anywhere on the active descriptor path.
- Regression outcome:
  - added `compiler_pipeline_avoids_linkedspec_spec_gdata_facade`,
  - the regression traps the removed façade helper name and proves `Runtime::run_get(..., return_descr => 1)` still returns a descriptor hash with compiled `gdata`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (135 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: drop facade spec_gdata helper` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A cleanup slice completed against the stale façade-local spec-resolution helper in `LinkedSpec.pm`.
- Key technical outcome:
  - removed `LinkedSpec::_resolve_local_spec_path(...)`,
  - active local/module-relative parser lookup remains owned exclusively by `LinkedSpec::Resolver`,
  - `LinkedSpec::get_parser(...)` no longer has a façade-level local-resolution helper alias to fall back through.
- Regression outcome:
  - added `get_parser_avoids_linkedspec_local_spec_path_facade`,
  - the regression traps the removed façade helper name and proves `get_parser('Lispish')` still resolves from a non-project cwd, executes successfully, and keeps `PathSearch` unloaded.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Resolver.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (134 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: drop facade local spec path helper` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A cleanup slice completed against stale bootstrap parsing scaffolding in `Compiler.pm`.
- Key technical outcome:
  - removed the dead `LinkedSpec::Compiler::_run_bootstrap_parse(...)` helper,
  - active bootstrap parsing remains owned exclusively by `LinkedSpec::BootstrapSpec::run_bootstrap_parse(...)`,
  - the compiler surface is smaller and no active path relies on the removed helper name.
- Regression outcome:
  - added `compiler_pipeline_avoids_legacy_run_bootstrap_parse_helper`,
  - the regression traps the old compiler-local helper name and proves `Runtime::run_get(...)` still returns a valid descriptor through the active BootstrapSpec-owned path.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (133 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: remove stale compiler bootstrap helper` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted plugin/runtime modernization slice completed against the legacy `AUTOLOAD` compatibility bridge.
- Key technical outcome:
  - `LinkedSpec::PluginBridge` now owns explicit plugin-runtime load/exec dependency callbacks through `_dispatch_autoload(...)`,
  - `LinkedSpec::AUTOLOAD` now delegates straight to `_dispatch_autoload(...)` without the extra `dispatch_autoload(...)` wrapper,
  - the plugin/runtime modernization track is now in progress rather than purely planned.
- Regression outcome:
  - added `autoload_avoids_plugin_bridge_wrapper`,
  - added `plugin_bridge_supports_injected_plugin_runtime_deps`,
  - the new regressions prove the `AUTOLOAD -> PluginBridge` handoff and the injected runtime dependency seam both work without changing public behavior.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (132 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Plugin runtime: add explicit PluginBridge runtime deps` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A modularization slice completed against the compiler/runtime default-callback boundary in `run_get_pipeline(...)`.
- Key technical outcome:
  - `LinkedSpec::Compiler::run_get_pipeline(...)` now owns the default `bootstrap_parse` and `compile_spec_entry` callbacks,
  - `LinkedSpec::Runtime::run_get(...)` now injects only `runtime_ctx` for mutable per-run parser state,
  - explicit callback injection remains available for focused tests and future internal refactors.
- Regression outcome:
  - added `runtime_run_get_defers_default_pipeline_callbacks_to_compiler_owner`,
  - the regression traps `LinkedSpec::Compiler::run_get_pipeline(...)` and proves `Runtime::run_get(...)` no longer injects `bootstrap_parse` or `compile_spec_entry` while still returning a valid descriptor hash.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (130 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: move pipeline default callbacks into Compiler` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A modularization slice completed against the compiler-owned final-descriptor `spec_gdata` callback boundary.
- Key technical outcome:
  - `LinkedSpec::Compiler::_build_final_descr(...)` now owns the default `spec_gdata` callback,
  - `LinkedSpec::Compiler::run_get_pipeline(...)` no longer threads `\&spec_gdata` explicitly during descriptor assembly,
  - explicit callback injection remains available for focused tests and future internal refactors.
- Regression outcome:
  - added `run_get_pipeline_defers_default_spec_gdata_callback_to_final_descr_owner`,
  - the regression traps `LinkedSpec::Compiler::_build_final_descr(...)` and proves the compiler pipeline now leaves the default `spec_gdata` callback undefined at the call site while still returning a valid descriptor.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (129 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: move final descriptor spec_gdata default into Compiler` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A modularization slice completed against the façade-owned `spec_descr(...)` default callback boundary.
- Key technical outcome:
  - `LinkedSpec::Compiler::spec_descr(...)` now owns the default `compile_spec_entry` callback,
  - `LinkedSpec::spec_descr(...)` is now a pure façade delegate into `Compiler.pm`,
  - injected compile callbacks remain supported for focused tests and alternative internal flows.
- Regression outcome:
  - added `spec_descr_defers_default_compile_callback_to_compiler_owner`,
  - the regression traps `LinkedSpec::Compiler::spec_descr(...)` and proves `LinkedSpec::spec_descr(...)` delegates without injecting the default callback while still building a compiled handler hash.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (128 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: move spec_descr default callback into Compiler` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A modularization slice completed against the façade-owned parser-factory dependency builder boundary.
- Key technical outcome:
  - `LinkedSpec::ParserFactory::run_get_parser(...)` now owns its default trace/resolution/compile dependency map,
  - `LinkedSpec::get_parser(...)` remains the stable public wrapper but no longer depends on the private façade helper `_parser_factory_deps()`,
  - the explicit injected-deps seam is still available for focused tests and internal reuse.
- Regression outcome:
  - added `get_parser_avoids_linkedspec_parser_factory_dep_builder`,
  - the regression traps `LinkedSpec::_parser_factory_deps()` and proves `get_parser(...)` still returns an executable parser and parses input successfully.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (127 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: move ParserFactory default deps out of facade` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-10)
- Uncommitted Phase 1A modularization slice completed against the public `get_parser(...)`/parser-factory option-normalization boundary.
- Key technical outcome:
  - `LinkedSpec::get_parser(...)` now normalizes flat option pairs locally before delegating,
  - `LinkedSpec::ParserFactory::run_get_parser(...)` now consumes an option hashref contract directly,
  - the active public parser path no longer depends on raw option-list normalization inside `ParserFactory.pm`.
- Regression outcome:
  - added `get_parser_normalizes_option_pairs_before_parser_factory`,
  - the regression traps `LinkedSpec::ParserFactory::run_get_parser(...)` and proves `get_parser(...)` passes the expected normalized trace option hash while still returning an executable parser.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (126 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: normalize get_parser options before ParserFactory` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-09)
- Uncommitted Phase 1A modularization slice completed against the public `Get(...)`/runtime wrapper boundary.
- Key technical outcome:
  - `LinkedSpec::Get(...)` now normalizes flat option pairs locally and delegates directly to `LinkedSpec::Runtime::run_get(...)`,
  - the active public `Get` path no longer depends on the raw-arg compatibility wrapper `LinkedSpec::Runtime::run_get_from_args(...)`.
- Regression outcome:
  - added `get_avoids_runtime_run_get_from_args_wrapper`,
  - the regression traps `LinkedSpec::Runtime::run_get_from_args(...)` and proves `LinkedSpec::Get(...)` still returns an executable parser and parses input successfully.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (125 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: route Get through Runtime::run_get` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-09)
- Uncommitted Phase 1A modularization slice completed against the parser-factory/runtime compile boundary.
- Key technical outcome:
  - `LinkedSpec::ParserFactory::run_get_parser(...)` now compiles through `LinkedSpec::Runtime::run_get(...)` with a normalized option hashref,
  - active parser-factory compilation no longer depends on the raw-arg compatibility wrapper `LinkedSpec::Runtime::run_get_from_args(...)`.
- Regression outcome:
  - extended `get_parser_avoids_linkedspec_parser_factory_facade`,
  - the regression now traps `LinkedSpec::Runtime::run_get_from_args(...)` and proves `get_parser(...)` still resolves, compiles, executes, keeps `PathSearch` unloaded, and emits routed trace output.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (124 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: route ParserFactory compilation through Runtime::run_get` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-09)
- Uncommitted Phase 1A modularization slice completed against bootstrap parse ownership.
- Key technical outcome:
  - `LinkedSpec::BootstrapSpec` now owns cached bootstrap grammar state via `cached_bootstrap_state()` and bootstrap parse execution via `run_bootstrap_parse(...)`,
  - `LinkedSpec::Compiler::run_get_pipeline(...)` now consumes a single injected `bootstrap_parse` callback rather than the raw bootstrap descriptor/index/gdata triple,
  - `LinkedSpec::Runtime::run_get(...)` no longer owns local bootstrap cache state.
- Regression outcome:
  - updated the compiler/runtime seam lock to `compiler_run_get_pipeline_uses_injected_bootstrap_parse_and_runtime_context`,
  - the regression proves the compiler pipeline works with the injected bootstrap parse callback plus shared runtime context and calls the bootstrap callback exactly once.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (124 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: move bootstrap parse ownership into BootstrapSpec` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-09)
- Uncommitted Phase 1A modularization slice completed against the spec-entry/runtime wrapper boundary.
- Key technical outcome:
  - `LinkedSpec::SpecEntry::compile_spec_entry(...)` now accepts the injected `runtime_ctx` directly for parser-source emission and `top_rule` propagation,
  - default rule compilation paths (`LinkedSpec::spec_descr(...)`, `LinkedSpec::spec_entry(...)`, and `Runtime::run_get(...)`) no longer need `LinkedSpec::Runtime::compile_spec_entry(...)` as the active owner.
- Regression outcome:
  - added `spec_entry_paths_avoid_runtime_compile_spec_entry_wrapper`,
  - the regression traps `LinkedSpec::Runtime::compile_spec_entry(...)` and proves both the façade default path and `LinkedSpec::Get(..., return_descr => 1)` still compile rules successfully.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (124 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: route SpecEntry compilation through SpecEntry` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-09)
- Uncommitted Phase 1A modularization slice completed against the compiler/runtime mutable-state dependency boundary.
- Key technical outcome:
  - `LinkedSpec::Compiler::run_get_pipeline(...)` now consumes a single injected `runtime_ctx` hash for parser-source emission, parser-source chunk capture, and `top_rule` propagation,
  - `LinkedSpec::Runtime::run_get(...)` no longer threads those mutable state handles as separate compiler dependencies.
- Regression outcome:
  - added `compiler_run_get_pipeline_uses_injected_runtime_context`,
  - the regression proves `run_get_pipeline(...)` succeeds with only the injected shared runtime context for mutable parser-build state and still captures parser source plus `top_rule`.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (123 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: collapse Compiler runtime deps into context` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-09)
- Uncommitted Phase 1A modularization slice completed against `LinkedSpec::Runtime` mutable state.
- Key technical outcome:
  - cached bootstrap grammar state now lives in a shared lexical runtime hash,
  - mutable per-run parser-build state (`top_rule`, parser-source emission) now flows through an injected runtime context hash instead of package-global mutation.
- Regression outcome:
  - added `runtime_compile_spec_entry_uses_injected_runtime_context`,
  - the regression proves `LinkedSpec::Runtime::compile_spec_entry(...)` can compile a parsed bootstrap entry, emit parser-source chunks, and record `top_rule` through injected runtime state.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (122 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: move Runtime mutable state into context` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-09)
- Uncommitted Phase 1A modularization slice completed against `LinkedSpec::ParserFactory` dependency wiring.
- Key technical outcome:
  - parser-factory trace/config wiring now resolves directly from `LinkedSpec::Trace`,
  - parser compilation now resolves from `LinkedSpec::Runtime::run_get_from_args(...)`,
  - `LinkedSpec::get_parser(...)` no longer depends on `LinkedSpec.pm` parser-factory façade callbacks/values for tracing or compilation.
- Regression outcome:
  - added `get_parser_avoids_linkedspec_parser_factory_facade`,
  - the regression traps the old `LinkedSpec.pm` parser-factory façade helper names/values and verifies `get_parser(...)` still resolves `Lispish`, builds a parser, executes it, keeps `PathSearch` unloaded, and emits routed trace output.
- Trace-contract note:
  - trace metadata now surfaces the real owning modules (`ParserFactory.pm`, `Resolver.pm`, `Compiler.pm`, etc.) rather than being implicitly tied to `LinkedSpec.pm`,
  - the trace metadata regression was updated accordingly.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (121 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: decouple ParserFactory from facade` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-09)
- Uncommitted Phase 1A modularization slice completed against `LinkedSpec::ActionRewriter` lowering dependencies.
- Key technical outcome:
  - `LinkedSpec::ActionRewriter` now owns the extracted ActionIR lowering/value/pipeline/control-flow callback surface it needs for direct rewrites,
  - `LinkedSpec::Deps` no longer routes action-rewriter declare/scanner/contract lowering callbacks back through `LinkedSpec.pm`.
- Regression outcome:
  - added `action_rewriter_avoids_removed_linkedspec_lowering_facade`,
  - the regression traps the old `LinkedSpec::_...` lowering helper names and verifies direct `LinkedSpec::ActionRewriter::call_spec_handler_subst(...)` rewrites still succeed across representative declare, assign, push, regex, pipeline, flow, switch, and return forms.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (120 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: decouple ActionRewriter lowering from facade` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-09)
- Uncommitted Phase 1A modularization slice completed against `LinkedSpec::RuleIR::EmitContext`.
- Key technical outcome:
  - `LinkedSpec::RuleIR::EmitContext` now routes rewrite-rule construction, rewrite execution, trim helpers, and diagnostic accumulation through `LinkedSpec::ActionRewriter`,
  - the module no longer needs `LinkedSpec.pm` action-rewriter façade helpers during emit-context assembly.
- Regression outcome:
  - added `ruleir_emit_context_avoids_linkedspec_action_rewriter_facade`,
  - the regression traps the old `LinkedSpec::_...` façade helper names and verifies emit-context build still succeeds with preserved ACODE/gdata/meta outputs.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm` => syntax OK
  - `bash tools/run_ci_local.sh` => PASS (119 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: decouple RuleIR emit context from facade` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-09)
- CI slice completed for local/GitHub phase-0 validation.
- Key technical outcome:
  - `.github/workflows/ci.yml` now exists and delegates to `bash tools/run_ci_local.sh`,
  - `tools/run_ci_local.sh` is the shared repo-root gate for both local runs and GitHub Actions,
  - the gate now enforces that the workflow file and shared CI script are git-tracked before it can pass.
- Validation outcome:
  - `bash tools/run_ci_local.sh` was verified to fail while `.github/workflows/ci.yml` was still untracked,
  - after adding the CI files to the index, the same gate passed cleanly at `Files=1, Tests=118`.
- Path-hygiene outcome:
  - the CI audit now checks for machine-specific absolute paths across the exercised LinkedSpec package surface (`perl/LinkedSpec.pm` + `perl/LinkedSpec/**`) as well as the workflow, CI script, and regression test,
  - no such absolute-path literals were found in the LinkedSpec package tree.
- Scope note:
  - older absolute-path literals still exist in non-gated files such as `perl/env.conf` and `perl/EasyTk.pm`,
  - those remain portability debt but are outside the current CI-blocking surface.
- Commit workflow prep:
  - `git_message_brief.txt` should contain `CI: add shared local/GitHub phase0 gate` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-09)
- Uncommitted Phase 1A modularization slice completed against the compiler/runtime descriptor-assembly boundary.
- Key technical outcome:
  - `LinkedSpec::Compiler::spec_descr(...)` now consumes an injected `compile_spec_entry` callback instead of calling back into `LinkedSpec.pm`,
  - `LinkedSpec::Compiler::run_get_pipeline(...)` now receives that callback explicitly,
  - `LinkedSpec::Runtime::run_get(...)` injects `\&compile_spec_entry`, so runtime-owned top-rule propagation remains intact.
- Compatibility outcome:
  - `LinkedSpec::spec_descr(...)` keeps the same public surface and now supplies the runtime callback internally,
  - parser-generation behavior and descriptor output stayed unchanged across the phase-0 suite.
- Regression outcome:
  - added `compiler_spec_descr_uses_injected_compile_spec_entry_callback`,
  - full `t/phase0_regression.t` suite now passes at 118 tests.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (118 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Phase 1A: inject compile_spec_entry into compiler` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-09)
- Uncommitted post-blocker snapshot-helper naming slice completed in ActionIR lowering and docs.
- Key technical outcome:
  - `array_copy(array(...))` now lowers identically to `array_values(array(...))`,
  - support was wired through direct method-value lowering, generalized `return(payload)` nested-helper rewriting, and flow-expression passthrough surfaces.
- Compatibility outcome:
  - existing specs using `array_values(...)` remain unchanged and still emit the same `[@target]` payload form,
  - the user guides now present `array_copy(...)` as the preferred spelling and `array_values(...)` as compatibility syntax.
- Regression outcome:
  - expanded `action_rewriter_lowers_array_snapshot_and_array_assign_method_contracts`,
  - full `t/phase0_regression.t` suite still passes at 117 tests.
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (117 tests)
- Commit workflow prep:
  - `git_message_brief.txt` should contain `Backbone #3: add array_copy snapshot alias` until commit workflow runs, then reset to zero-byte untracked.
## Current Session Snapshot (2026-03-09)
- Uncommitted Backbone item #3 slice completed against `tkgui.spec`.
- Key technical outcome:
  - `sub_gui` is now clear,
  - the final raw blocker `print "Found a SUB GUI entry point <$subgui_name>\n"` was replaced with canonical helper `print("Found a SUB GUI entry point <", scalar(subgui_name), ">\n")`.
- Rule-migration outcome:
  - `tkgui` now reports `language_agnostic_blocked_rule_count=0`
  - `sub_gui` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - canonical action-IR coverage for `sub_gui` now includes `ASSIGN`, `CALL`, `PRINT`, and `RETURN`
- Regression outcome:
  - added `tkgui_helper_flow_eliminates_raw_fallback`
  - added `tkgui_parser_smoke`
  - full `t/phase0_regression.t` suite now passes at 117 tests
- Semantic-preservation note:
  - the parser still emits the current `Found a SUB GUI entry point <...>` message,
  - the new smoke case locks the current one-entry hash result shape `{'((frame foo))' => undef}` so the helper rewrite does not silently “improve” or alter existing semantics.
- Blocker-ranking outcome:
  - `tkgui.spec` no longer appears in the blocked-spec ranking
  - the current non-deferred action-rewriter migration scan reports zero blocked specs
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (117 tests)
## Current Session Snapshot (2026-03-09)
- Uncommitted Backbone item #3 slice completed against `pplugin.spec`.
- Key technical outcome:
  - `pplugin_top` is now clear,
  - the final raw blocker `push @defs, @$retv` was replaced with canonical collection-target assignment using `flat_array(defs)` plus `scalaref(retv, [0])` / `scalaref(retv, [1])`.
- Rule-migration outcome:
  - `pplugin` now reports `language_agnostic_blocked_rule_count=0`
  - `pplugin_top` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - canonical action-IR coverage for `pplugin_top` now includes `DECLARE`, `ASSIGN`, `NEXT`, `CALL`, and `RETURN`
- Regression outcome:
  - added `pplugin_helper_flow_eliminates_raw_fallback`
  - added `pplugin_parser_smoke`
  - full `t/phase0_regression.t` suite now passes at 115 tests
- Semantic-preservation note:
  - the parser still returns a hash of plugin-name to coderef,
  - the new smoke case confirms the returned coderefs still evaluate their captured plugin bodies correctly after parsing comments and multiple subdefs.
- Blocker-ranking outcome:
  - `pplugin.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs at that point were:
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (115 tests)
## Current Session Snapshot (2026-03-08)
- Live docs now explicitly capture the future replacement of the current `AUTOLOAD` + `.plg` plugin runtime.
- Architecture findings:
  - `LinkedSpec::AUTOLOAD` delegates to `LinkedSpec::PluginBridge`, which lazy-loads `PPlugin`.
  - `PPlugin` builds a cached registry from cwd/project `.plg` files and dispatches by extracted method suffix.
  - `PathSearch` still uses a mutable `state` cache seeded from cwd plus a project-tree walk and remains a cross-cutting dependency.
- Decision:
  - long-term plugin direction is explicit module/package plugins with a registry/loader; the current bridge remains compatibility-only during migration.
  - `PathSearch->go(...)` stays as the short-term compatibility surface, but the implementation should become deterministic and later use standard path/search primitives instead of the current global-state scan.
- Roadmap impact:
  - this new track is explicit and does not replace the short-term Backbone #3 tail work.
  - the next deterministic parser slice after that roadmap update was `pplugin.spec`, followed by `tkgui.spec`.
- Validation snapshot:
  - docs-only update; no code validation run.
## Current Session Snapshot (2026-03-08)
- Uncommitted Backbone item #3 slice completed against `portmap.spec`.
- Key technical outcome:
  - `portmap` is now clear,
  - `bare_bit_slice` now uses canonical helper control flow instead of raw Perl smartmatch classification,
  - the zero-valued index cases (`bar[0]`, `baz[7:0]`) are explicitly preserved inside helper flow.
- Migration nuance:
  - indexed `is_nonempty(scalar(IMATCH_LIST, n))` lowers through truthiness, so zero-valued captures need explicit handling,
  - `slice` classification now keys off `matches(scalar(IMATCH), /:/)`,
  - `bit` classification now uses `or(eq(scalar(IMATCH_LIST, 1), "0"), is_nonempty(scalar(IMATCH_LIST, 1)))`.
- Rule-migration outcome:
  - `portmap` now reports `language_agnostic_blocked_rule_count=0`
  - `bare_bit_slice` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
- Regression outcome:
  - added `portmap_bare_bit_slice_helper_flow_eliminates_raw_fallback`
  - added `portmap_bare_bit_slice_classification_smoke`
  - full `t/phase0_regression.t` suite now passes at 113 tests
- Behavior note:
  - the old experimental smartmatch warning path is gone after the helper rewrite.
- Blocker-ranking outcome:
  - `portmap.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (113 tests)
## Current Session Snapshot (2026-03-08)
- Uncommitted Backbone item #3 slice completed against `sdce.spec`.
- Key technical outcome:
  - `sdce` is now clear,
  - `sdc_esplit` now uses canonical `declare`/`assign`/`push_value`/`array_values` accumulator flow,
  - `get_pinport` now uses canonical `split`/`filter_nonempty`/`flat_array` merge flow.
- Semantic-preservation note:
  - plain-text segments still preserve interstitial whitespace tokens via `split(..., /(\\s+)/)`,
  - brace-content segments still emit only non-whitespace tokens via `split(..., /\\s+/)` plus `filter_nonempty(...)`,
  - representative parser outputs were manually spot-checked and matched the pre-migration baseline.
- Rule-migration outcome:
  - `sdce` now reports `language_agnostic_blocked_rule_count=0`
  - `sdc_esplit` and `get_pinport` now report `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
- Regression outcome:
  - added `sdce_helper_flow_eliminates_raw_fallback`
  - full `t/phase0_regression.t` suite now passes at 111 tests
- Blocker-ranking outcome:
  - `sdce.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `portmap.spec` (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`)
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (111 tests)
## Current Session Snapshot (2026-03-08)
- Uncommitted Backbone item #3 slice completed against `lib_reader.spec`.
- Key technical outcome:
  - `lib_reader` is now clear,
  - the winning migration form for this slice was method-chain initializer syntax rather than multiline helper statements inside `I { ... }`.
- Rule-migration outcome:
  - `lib_reader` now reports `language_agnostic_blocked_rule_count=0`
  - `group`, `sattribute`, and `cattribute` now report `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
- Migration nuance:
  - the brace-block helper rewrite still left raw-fallback metadata in these initializer rules even though the same helper statements lowered correctly through `call_spec_handler_subst(...)`,
  - switching those initializers to method-chain form (`I.declare(...).substr(...).return(...)`) cleared the blockers.
- Regression outcome:
  - added `lib_reader_helper_flow_eliminates_raw_fallback`
  - full `t/phase0_regression.t` suite now passes at 110 tests
- Blocker-ranking outcome:
  - `lib_reader.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `sdce.spec` (`BLOCKED=2`, `TOP=sdc_esplit`, `BLOCKERS=5`)
    - `portmap.spec` (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`)
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (110 tests)
## Current Session Snapshot (2026-03-08)
- Uncommitted Backbone item #3 slices completed against `DT.spec` and `hlink_substitution.spec`.
- Key technical outcome:
  - `DT.spec` was cleared via canonical `print(...)` helper rewrites across the recursive delimiters, top rule, and token rules,
  - `hlink_substitution.spec` was cleared by converting the remaining raw error prints and rewriting `substitute_top` into canonical helper flow with `declare`, `assign(call(...))`, `push_value`, and helper-based `return_undef`.
- Rule-migration outcome:
  - `DT` now reports `language_agnostic_blocked_rule_count=0`
  - `hlink_substitution` now reports `language_agnostic_blocked_rule_count=0`
  - migrated rules now report `raw_perl_dependency_count=0` and `language_agnostic_action_ir_ready=1`
- Regression outcome:
  - added `dt_debug_print_helper_flow_eliminates_raw_fallback`
  - added `hlink_substitution_helper_flow_eliminates_raw_fallback`
  - full `t/phase0_regression.t` suite now passes at 109 tests
- Blocker-ranking outcome:
  - `DT.spec` no longer appears in the blocked-spec ranking
  - `hlink_substitution.spec` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `lib_reader.spec` (`BLOCKED=3`, `TOP=group`, `BLOCKERS=4`)
    - `sdce.spec` (`BLOCKED=2`, `TOP=sdc_esplit`, `BLOCKERS=5`)
    - `portmap.spec` (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`)
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (109 tests)
## Current Session Snapshot (2026-03-08)
- Uncommitted Backbone item #3 slice completed against `operators_try`.
- Key technical outcome:
  - all remaining blocked `operators_try` rules were cleared without new lowering surface,
  - the migration was purely a canonical `print(...)` helper rewrite plus removal of one leftover nested `I { ... }` wrapper in `group[1]`.
- Rule-migration outcome:
  - `operators_try` now reports `language_agnostic_blocked_rule_count=0`
  - migrated rules now report `raw_perl_dependency_count=0` and `language_agnostic_action_ir_ready=1`
  - canonical action-IR coverage for the slice is centered on `PRINT`
- Regression outcome:
  - added `operators_try_debug_print_helper_flow_eliminates_raw_fallback`
  - full `t/phase0_regression.t` suite now passes at 107 tests
- Blocker-ranking outcome:
  - `operators_try` no longer appears in the blocked-spec ranking
  - current remaining blocked specs are:
    - `DT.spec` (`BLOCKED=11`, `TOP=group`, `BLOCKERS=14`)
    - `hlink_substitution.spec` (`BLOCKED=3`, `TOP=substitute_top`, `BLOCKERS=4`)
    - `lib_reader.spec` (`BLOCKED=3`, `TOP=group`, `BLOCKERS=4`)
    - `sdce.spec` (`BLOCKED=2`, `TOP=sdc_esplit`, `BLOCKERS=5`)
    - `portmap.spec` (`BLOCKED=1`, `TOP=bare_bit_slice`, `BLOCKERS=2`)
    - `pplugin.spec` (`BLOCKED=1`, `TOP=pplugin_top`, `BLOCKERS=1`)
    - `tkgui.spec` (`BLOCKED=1`, `TOP=sub_gui`, `BLOCKERS=1`)
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (107 tests)
## Current Session Snapshot (2026-03-08)
- Backbone item #3 blocker-reduction slice completed against `Lispish::parenthesis`.
- Key technical outcome:
  - canonical lowering now supports `assign(scalar(retv), call(rule))`,
  - this removed the need for raw wrapper assignments like `$retv = call(rule)` in `Lispish::parenthesis`.
- Rule-migration outcome:
  - `Lispish::parenthesis` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`
  - `Lispish` now reports `language_agnostic_blocked_rule_count=0`
  - within the previously tracked families (`Lispish`, `vhdl`, `ds_vhistory`, `ebnf`), no remaining top blocked rule is reported in descriptor migration metadata
- Regression outcome:
  - added a direct lowering lock for `assign(scalar(retv), call(Leaf))`
  - added `lispish_parenthesis_helper_flow_eliminates_raw_fallback`
  - refreshed `lispish_small_helper_flow_eliminates_raw_fallback` to the final zero-blocker state
  - preserved `lispish_ast_smoke`
- Documentation outcome:
  - `USER_GUIDE.md` is now a top-level navigation hub
  - the lowering reference is now split into module-focused guides:
    - `USER_GUIDE_ActionIR_DeclareMethod.md`
    - `USER_GUIDE_ActionIR_MethodLowering.md`
    - `USER_GUIDE_ActionIR_ValueExpr.md`
    - `USER_GUIDE_ActionIR_FlowExpr.md`
    - `USER_GUIDE_ActionIR_ControlFlow.md`
    - `USER_GUIDE_ActionIR_ArrayPipeline.md`
    - `USER_GUIDE_ActionIR_Contracts.md`
  - `USER_GUIDE_ActionIR_EmittedPerlReference.md` now serves as the exhaustive review baseline:
    - lists the canonical helper surface,
    - lists compatibility helpers such as `return_a` / `return_m` / `return_ma`, capture/backtrack helpers, and raw call wrappers,
    - lists classified pass-through idioms that remain verbatim but no longer count as `RAW_PERL` fallback,
    - shows the emitted Perl shape for each documented construct
- Validation snapshot:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (106 tests)

## Recent Commit Ledger (Newest First)
- `c850fca` - Backbone #3: migrate ds_vhistory vhistory helper flow
- `02ac4d9` - Backbone #3: migrate vhdl process_statement helper flow
- `714abf7` - Backbone #3: clear remaining small Lispish blockers
- `a04282d` - Backbone #3: clear remaining small vhdl blockers
- `6ff211b` - Backbone #3: migrate ebnf grammar_file helper flow
- `a79dc72` - Backbone #3: add flat list helpers and clear VHDL declarations
- `1757b21` - Backbone #3: migrate VHDL package helper flow
- `193b42f` - Backbone #3: clear final signal_decl_range blocker
- `b17a173` - Backbone #3: add hash payload lowering and clear tablegrep blockers
- `1495f86` - Backbone #3: clear remaining simenv blockers
- `933e22a` - Roadmap: queue array_values naming cleanup
- `1eda69a` - Backbone #3: migrate simenv quote substitution helpers
- `f5fe9d9` - Backbone #3: migrate simenv delimiter helper prints
- `12dc155` - Backbone #3: migrate BNF debug prints to print helper flow
- `6f0eb1a` - Backbone #3: migrate ifelse debug prints to print helper flow
- `a240bca` - Backbone #3: add array_values helper and migrate simenv begin_end_blocks
- `858e586` - feat(spec): migrate vhdl signal_decl_range with join_values method flow
- `2b1101b` - Backbone #3: fluent control-flow method DSL + pipe_operator showcase
- `2984fb5` - Backbone #3: composable array-method lowering + snippet codegen inspector
- `677677d` - Backbone item #3 follow-up: add typed declare methods and method chains
- `6ff99b5` - Backbone item #3 follow-up: lower indexed push-call wrappers
- `e06493c` - Backbone item #3 follow-up: lower return-call action wrappers
- `f9ad3fb` - Backbone item #3 follow-up: fix method-style action arg trimming
- `ec2ee3f` - Backbone item #3: lower call-wrapper statements to reduce RAW_PERL fallback
- `f4fc24a` - Backbone item #3: add descriptor migration blocker-type ratio metadata
- `79e7d47` - Backbone item #3: add descriptor migration blocker-type breakdown metadata
- `d66d925` - Backbone item #3: add migration-priority metadata and rewrite-helper cleanup
- `a7c727e` - Backbone item #3 follow-up: add descriptor-level migration summary
- `45fb1ca` - Add LinkedSpec.pm subroutine docstrings and structural comments
- `9d0c75f` - Backbone item #3 follow-up: add language-agnostic blocker statement metadata
- `6c71e21` - Backbone item #3 follow-up: add language-agnostic action readiness metadata
- `3e7de01` - Document language-agnostic .spec end-state and guardrails
- `69c53f1` - Document pause for _split_action_ir_statements hardening track
- `3b1e7d9` - Backbone item #3 follow-up: harden canonical splitter for pipe quotes
- `0ca3a48` - Backbone item #3 follow-up: harden canonical splitter for angle quotes
- `879585d` - Backbone item #3 follow-up: harden canonical splitter for slash quotes
- `6ce4333` - Backbone item #3 follow-up: harden canonical splitter for backtick quotes
- `5b93e84` - Backbone item #3 follow-up: harden canonical splitter for line comments
- `2d4c16d` - Backbone item #3 follow-up: make helper lowering whitespace-tolerant
- `7a33587` - Backbone item #3 follow-up: harden canonical IR statement splitting
- `3d83017` - Backbone item #3 follow-up: lower action emission from canonical IR
- `226ea24` - Backbone item #3 follow-up: add structured helper payload events
- `9bb6647` - Backbone item #3 follow-up: add helper action-IR metadata
- `546bfd0` - Backbone item #3 follow-up: add lowering contract catalog
- `ce6be32` - Backbone item #3 follow-up: add action rewriter diagnostics metadata
- `1943f0a` - Backbone item #3: land structured action rewriter pipeline
- `ef0de33` - Landed Backbone Track item #2 with staged RuleIR pipeline in spec_entry
- `65467d9` - Landed Backbone Track item #1 with declarative bootstrap registry dispatch
- `f2ead5a` - Track backbone refactor and language-neutral action DSL objectives in roadmap
- `494f658` - Refactor LinkedSpec core with deterministic rule metadata and descriptor introspection
- `8c7150d` - Lock explicit-miss bypass behavior when PathSearch is preloaded
- `8b766e4` - Generalize get_parser non-regular path handling and lock regressions
- `751bee2` - Harden get_parser directory-path handling and lock new regressions
- `2146f2f` - Lock windows-style explicit-path miss behavior and update live docs
- `0b9fd0a` - Generalize get_parser control-byte validation and expand regression locks
- `a8bb56a` - Harden get_parser control-character validation and extend regression locks
- `50fe970` - Fix duplicate fallback resolver call and harden padded spec-name validation
- `813fb42` - Expand get_parser invalid-name hardening and regression coverage
- `9e1c8b7` - Harden get_parser invalid-input guards and expand negative-path regressions
- `1012876` - Expand get_parser fallback hardening and negative-path regression locks
- `78217d7` - Harden get_parser invalid spec-name handling and refresh regression/docs
- `4067980` - Lock parser invalid-input subprocess behavior and update live docs

## Resume-Work Checklist
When resuming after interruption:
1. Read `MEMORY.md` first (this file).
2. Check `CHANGES.md` for pending commit scope.
3. Check `ROADMAP.md` for current phase + next milestone.
4. Check `DEVELOPMENT_NOTES.md` for design constraints/decisions.
5. Check `USER_GUIDE.md` for user-facing behavior implications.
6. Continue implementation from highest-priority roadmap item.

## Next Recommended Work Item
- If continuing blocker reduction before the next commit, target `pplugin.spec` next:
  - the remaining blocker tail is now `pplugin.spec` and `tkgui.spec`, each with one blocked rule
  - `pplugin.spec` is the next deterministic one-rule tail slice to inspect, followed by `tkgui.spec`
- `portmap.spec` is now clear and should be treated like the already-cleared `sdce`, `lib_reader`, `hlink_substitution`, `DT`, `operators_try`, `Lispish`, `vhdl`, `ds_vhistory`, and `ebnf` families for blocker-ranking purposes.
- Continue post-item-#3 follow-up toward language-neutral actions:
  - after this commit, the next high-value work item is user review of the exhaustive lowering-guide set, with any resulting syntax/semantic cleanup driven by that review,
  - keep `_split_action_ir_statements(...)` hardening frozen unless a concrete regression appears,
  - continue reducing `RAW_PERL` fallback usage through action-IR/lowering improvements and diagnostics tightening (not more delimiter-surface expansion for now),
  - use per-rule readiness metadata (`raw_perl_dependency_count`, `raw_perl_dependency_statements`, `language_agnostic_action_ir_ready`) to prioritize migration of high-impact rules away from raw Perl fallback behavior,
  - use blocker statement metadata (`unresolved_helper_statements`, `language_agnostic_action_ir_blocker_statements`) to drive concrete migration backlog items,
  - use descriptor-level `meta.action_rewriter_migration` summary (including `language_agnostic_blocker_statement_total_count`, `language_agnostic_blocked_rules_by_priority`, `language_agnostic_top_blocked_rule`, blocker-type breakdown fields/lists, and blocker-type ratio fields) to track migration progress and select next highest-value blocked rules,
  - no remaining top blocked rule is now reported in the tracked `Lispish`/`vhdl`/`ds_vhistory`/`ebnf` descriptor summaries,
  - `Lispish::parenthesis` is now clear and `Lispish` no longer contributes blocked rules in descriptor migration metadata,
  - the canonical call-assignment surface `assign(scalar(retv), call(rule))` is now available for future migrations and should be preferred over raw `$retv = call(rule)` wrappers,
  - the emitted-Perl lowering reference should now be treated as the user-visible compatibility contract for current helper semantics during further ActionIR cleanup,
  - `ebnf` no longer contributes blocked rules in descriptor migration metadata,
  - `ds_vhistory` no longer contributes blocked rules in descriptor migration metadata,
  - `vhdl` no longer contributes blocked rules in descriptor migration metadata,
  - within `vhdl`, `package_declaration`, `package_body`, `subprogram_declaration`, `type_declaration`, `signal_declaration`, `configuration_specification`, `vhdl_file`, `process_statement`, and `subprogram_body` are now clear,
  - the next Backbone item #3 work is therefore broader compatibility-surface cleanup and ActionIR-first lowering improvements rather than another blocker-reduction slice in those tracked families,
  - flat list insertion helpers are now available for future migrations:
    - `flat(array(name))` / `flatten(array(name))`
    - `flat(hash(name))` / `flatten(hash(name))`
    - `flat_array(name)` / `flat_hash(name)`
  - the array tokenization helper `split_each(array(name), /.../)` is now available for backend-neutral per-element split/flatten flow,
  - remember the current DSL distinction:
    - `array_values(array(name))` => array snapshot payload,
    - `array(flat_array(name))` => list-context insertion/copy inside array constructors,
  - prioritize backend-neutral action DSL/IR migration so `.spec` no longer depends on embedded Perl code-blocks,
  - avoid introducing new features that increase raw Perl action dependency in `.spec`,
  - keep canonical-IR-first lowering as the default rewrite path while tightening helper-contract diagnostics boundaries,
  - keep strict balanced-delimiter behavior (no permissive missing-close helper variants),
  - keep `tclite.spec` deferred until explicitly resumed.

## Earlier Session Updates
- Implemented Backbone item #3 roadmap slice in `specs/vhdl.spec`:
  - migrated `subprogram_body` to helper flow with typed declarations, saved-position assignment, helper-based substring capture, composable tokenization, and generalized `return(array(...))`,
  - preserved the previous split/map/grep token behavior by adding the backend-neutral `split_each(array(...), /.../)` helper instead of keeping a Perl-specific action block.
- Added focused regression coverage in `t/phase0_regression.t`:
  - `vhdl_subprogram_body_helper_flow_eliminates_raw_fallback`,
  - and refreshed the older `vhdl_declaration_helper_flow_eliminates_raw_fallback`, `vhdl_small_blocker_helper_flow_eliminates_raw_fallback`, and `vhdl_process_statement_helper_flow_eliminates_raw_fallback` snapshot expectations to the final zero-blocker `vhdl` state.
- Re-ran validation after the `subprogram_body` slice:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (105 tests)
- Migration impact snapshot:
  - `vhdl::subprogram_body` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `vhdl::subprogram_body` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, `SPLIT`, `SPLIT_EACH`, `FILTER_NONEMPTY`, `RETURN`, and existing `CALL`,
  - `vhdl` now reports `language_agnostic_blocked_rule_count=0`.
- Updated blocker ranking snapshot after the slice:
  - `vhdl` no longer contributes blocked rules,
  - `ds_vhistory` no longer contributes blocked rules,
  - the only remaining top blocked rule is `Lispish::parenthesis` (`raw=6`).
- Implemented Backbone item #3 roadmap slice in `specs/ds_vhistory.spec`:
  - migrated `vhistory` to helper flow with typed declarations, helper-based capture flush logic, finalized object payload construction, canonical `print(...)`, and generalized `return(array(...))`,
  - avoided the earlier `@$cur_object` arrayref-target mutation blocker by rebuilding finalized `"?object:"` rows directly before pushing them into `vhistory`.
- Added focused regression coverage in `t/phase0_regression.t`:
  - `ds_vhistory_vhistory_helper_flow_eliminates_raw_fallback`.
- Re-ran validation after the `ds_vhistory` slice:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (104 tests)
- Migration impact snapshot:
  - `ds_vhistory::vhistory` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `ds_vhistory::vhistory` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, `IF`, `ELSE`, `ENDIF`, `PUSH`, `RETURN`, `CALL`, and `PRINT`,
  - `ds_vhistory` now reports `language_agnostic_blocked_rule_count=0`.
- Updated blocker ranking snapshot after the slice:
  - `ds_vhistory` no longer contributes blocked rules,
  - current top blockers are `Lispish::parenthesis` (`raw=6`) and `vhdl::subprogram_body` (`raw=5`).
- Implemented Backbone item #3 roadmap slice in `specs/vhdl.spec`:
  - migrated `process_statement` to helper flow with `declare(scalar, pos_begin, process_statement_part)`, saved-position assignment, helper-based substring capture, and generalized `return(array(...))`,
  - removed the leftover commented raw debug-print statements from the `process_statement` action blocks.
- Added focused regression coverage in `t/phase0_regression.t`:
  - `vhdl_process_statement_helper_flow_eliminates_raw_fallback`,
  - and refreshed the older `vhdl_declaration_helper_flow_eliminates_raw_fallback` and `vhdl_small_blocker_helper_flow_eliminates_raw_fallback` snapshot expectations to the current post-migration state.
- Re-ran validation after the `process_statement` slice:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (103 tests)
- Migration impact snapshot:
  - `vhdl::process_statement` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `vhdl::process_statement` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, and `RETURN`,
  - `vhdl` now reports `language_agnostic_blocked_rule_count=1`.
- Updated blocker ranking snapshot after the slice:
  - the only remaining `vhdl` blocked rule is `subprogram_body` (`raw=5`),
  - current top blockers are `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), and `vhdl::subprogram_body` (`raw=5`).
- Implemented Backbone item #3 roadmap slice in `specs/Lispish.spec`:
  - migrated the top-level `Lispish` syntax-error branch to canonical `say(...)` call syntax while preserving `exit 1`,
  - migrated `sbrackets`, `dquotes`, `squotes`, `spaces`, `others`, and `comments` to canonical `return(hash(...))` payload flow,
  - migrated `curlyb` to helper flow with `declare(scalar, content)`, `assign(scalar(content), CAPTURE)`, and `return(hash(...))`.
- Added focused regression coverage in `t/phase0_regression.t`:
  - `lispish_small_helper_flow_eliminates_raw_fallback`.
- Re-ran validation after the small `Lispish` slice:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (102 tests)
- Migration impact snapshot:
  - `Lispish`, `comments`, `curlyb`, `dquotes`, `others`, `sbrackets`, `spaces`, and `squotes` now report `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `curlyb` canonical action-IR nodes now include `DECLARE`, `ASSIGN`, and `RETURN`,
  - top-level `Lispish` canonical action-IR nodes now include `SAY`,
  - `Lispish` now reports `language_agnostic_blocked_rule_count=1`.
- Updated blocker ranking snapshot after the slice:
  - the only remaining `Lispish` blocked rule is `parenthesis` (`raw=6`),
  - current top blockers are `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), and `vhdl::process_statement` (`raw=4`),
  - `vhdl` still has only two blocked rules left: `subprogram_body` and `process_statement`.
- Implemented Backbone item #3 roadmap slice in `specs/vhdl.spec`:
  - cleared the remaining small VHDL blockers `signal_declaration`, `configuration_specification`, and `vhdl_file`,
  - removed the leftover `vhdl_file` line-buffering side effect `I {$|=1}`,
  - replaced rest-arity destructuring in `signal_declaration` and `configuration_specification` with fixed-arity scalar destructuring while preserving return shapes.
- Added focused regression coverage in `t/phase0_regression.t`:
  - `vhdl_small_blocker_helper_flow_eliminates_raw_fallback`,
  - and refreshed the older `vhdl_declaration_helper_flow_eliminates_raw_fallback` blocked-count snapshot to the current post-cleanup state.
- Re-ran validation after the small `vhdl` slice:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (101 tests)
- Migration impact snapshot:
  - `vhdl::signal_declaration` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `vhdl::configuration_specification` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `vhdl::vhdl_file` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `vhdl` now reports `language_agnostic_blocked_rule_count=2`.
- Updated blocker ranking snapshot after the slice:
  - the only remaining `vhdl` blocked rules are `subprogram_body` (`raw=5`) and `process_statement` (`raw=4`),
  - current top blockers are `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), and `vhdl::process_statement` (`raw=4`).
- Implemented Backbone item #3 roadmap slice in `specs/ebnf.spec`:
  - migrated `grammar_file` initialization, pending-rule flush, semantic-annotation handoff, and final return path to canonical helper flow,
  - replaced raw declarations with `declare(array, ...)` / `declare(scalar, ...)`,
  - replaced raw list assembly with `if(...)`, `push_value(...)`, `assign(array(...), array(flat_array(...)))`, and `return(array(flat_array(...), ...))`.
- Important DSL note from the slice:
  - `array_values(array(name))` remains the snapshot helper,
  - list-context copy into an array-target assignment now has an explicit canonical shape: `assign(array(target), array(flat_array(source)))`.
- Reused existing call-wrapper lowering rather than adding new helper surface:
  - `grammar_file` still binds the active rule via `$rule = call(grammar_rule)`,
  - this is already covered by canonical CALL contracts and kept the slice contained.
- Added focused regression coverage in `t/phase0_regression.t`:
  - `ebnf_grammar_file_helper_flow_eliminates_raw_fallback`.
- Re-ran validation after the `ebnf` slice:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (100 tests)
- Migration impact snapshot:
  - `ebnf::grammar_file` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `ebnf` now reports `language_agnostic_blocked_rule_count=0`.
- Updated blocker ranking snapshot after the slice:
  - current top blockers are `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), and `vhdl::process_statement` (`raw=4`),
  - remaining `vhdl` blocked rules are `subprogram_body`, `process_statement`, `configuration_specification`, `signal_declaration`, and `vhdl_file`,
  - `ebnf` no longer appears in the blocked-rule priority list.
- Implemented Backbone item #3 helper-surface follow-up in `perl/LinkedSpec/ActionIR/MethodLowering.pm`, `perl/LinkedSpec/ActionIR/Contracts.pm`, and `perl/LinkedSpec/BootstrapSpec/Core.pm`:
  - added first-class flat list insertion helpers for backend-neutral list-context expansion,
  - generic forms: `flat(array(name))`, `flatten(array(name))`, `flat(hash(name))`, `flatten(hash(name))`,
  - non-redundant aliases: `flat_array(name)`, `flat_hash(name)`,
  - generalized `return(payload)` and method-chain `.return(...)` payload detection now recognize flat helper starts,
  - `hash(...)` constructor lowering now accepts flat list insertions in addition to ordinary key/value pairs.
- Implemented Backbone item #3 roadmap slice in `specs/vhdl.spec`:
  - migrated `subprogram_declaration` to `flat_array(IMATCH_LIST)` return flow,
  - migrated `type_declaration` to helper flow with `declare`, `assign(..., CAPTURE)`, and `return(array(..., flat_array(IMATCH_LIST), ...))`.
- Added focused regression coverage in `t/phase0_regression.t`:
  - `action_rewriter_lowers_flat_list_value_helpers`
  - `vhdl_declaration_helper_flow_eliminates_raw_fallback`
- Re-ran validation after the flat-list helper and VHDL declaration slice:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (100 tests)
- Migration impact snapshot:
  - `vhdl::subprogram_declaration` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `vhdl::type_declaration` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `vhdl` now reports `language_agnostic_blocked_rule_count=5`.
- Updated blocker ranking snapshot after the slice:
  - current `vhdl` top blockers are `subprogram_body` (`raw=5`), `process_statement` (`raw=4`), `configuration_specification` (`raw=1`), `signal_declaration` (`raw=1`), and `vhdl_file` (`raw=1`),
  - broader top blockers remain `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), `ebnf::grammar_file` (`raw=4`), and `vhdl::process_statement` (`raw=4`).
- Implemented Backbone item #3 roadmap slice in `specs/vhdl.spec`:
  - migrated `package_declaration` and `package_body` to canonical helper flow,
  - replaced the inert `package_declaration` start block with `declare(array, imatch_copy)`,
  - replaced raw package return logic with helper-based `assign`, `lowercase_each`, `return(array(...))`, and `array_values(array(...))`.
- Added focused regression coverage in `t/phase0_regression.t`:
  - `vhdl_package_helper_flow_eliminates_raw_fallback`.
- Re-ran validation after the VHDL package slice:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (98 tests)
- Migration impact snapshot:
  - `vhdl::package_declaration` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `vhdl::package_body` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `vhdl` now reports `language_agnostic_blocked_rule_count=7`.
- Updated blocker ranking snapshot after the slice:
  - `package_declaration` and `package_body` are no longer blocked,
  - current `vhdl` top blockers are `subprogram_body` (`raw=5`), `process_statement` (`raw=4`), and `type_declaration` (`raw=2`),
  - broader top blockers remain `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), `ebnf::grammar_file` (`raw=4`), and `vhdl::process_statement` (`raw=4`).
- Implemented Backbone item #3 roadmap slice in `specs/vhdl.spec`:
  - cleared the final remaining `vhdl::signal_decl_range` blocker by replacing raw array reset `@capt = ()` with canonical helper flow `assign(array(capt), array())`.
- Strengthened focused regression coverage in `t/phase0_regression.t`:
  - `vhdl_signal_decl_range_method_flow_reduces_raw_push_capture_fallback` now locks zero raw fallback statements and full readiness for `signal_decl_range`.
- Re-ran validation after the final `signal_decl_range` cleanup:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (97 tests)
- Migration impact snapshot:
  - `vhdl::signal_decl_range` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`.
- Updated blocker ranking snapshot after the slice:
  - `signal_decl_range` is no longer blocked,
  - current `vhdl` top blockers remain `subprogram_body` (`raw=5`), `process_statement` (`raw=4`), and `package_body` (`raw=2`),
  - broader top blockers remain `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), and `ebnf::grammar_file` (`raw=4`).
- Implemented Backbone item #3 roadmap slice in `perl/LinkedSpec/ActionIR/MethodLowering.pm` and `specs/tablegrep.spec`:
  - added canonical helper-based `hash(...)` lowering for generalized `return(payload)` expressions,
  - migrated `tablegrep::and_op`, `tablegrep::or_op`, and `tablegrep::re_term` to use canonical `return(hash(...))` helper flow instead of raw Perl payloads,
  - rewrote `re_term` branch logic with `declare`, `if(matches(...))`, `substr`, and canonical structured helper returns.
- Extended and added focused regression locks in `t/phase0_regression.t`:
  - extended `action_rewriter_lowers_general_return_payloads_with_nested_structures` to cover `return(hash(...))`,
  - added `tablegrep_terminal_token_helper_flow_eliminates_raw_fallback`.
- Re-ran validation after the `hash(...)`/`tablegrep` slice:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (97 tests)
- Migration impact snapshot:
  - `tablegrep::and_op`, `tablegrep::or_op`, and `tablegrep::re_term` now report `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `tablegrep` now reports `language_agnostic_blocked_rule_count=0`.
- Updated blocker ranking snapshot after the slice:
  - `tablegrep` no longer contributes blocked rules,
  - current top blockers remain `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), `ebnf::grammar_file` (`raw=4`), and `vhdl::process_statement` (`raw=4`).
- Implemented Backbone item #3 roadmap slice in `specs/simenv.spec`:
  - migrated the last two blocked `simenv` rules, `top` and `anyvariable`, to canonical helper flow,
  - replaced the remaining raw block push guard in `top` with fluent helper control flow,
  - replaced raw variable-name extraction and print logic in `anyvariable` with `declare`, `substr`, `print`, and generalized `return(...)`.
- Added focused regression lock in `t/phase0_regression.t`:
  - `simenv_top_and_anyvariable_helper_flow_eliminates_raw_fallback`.
- Re-ran validation after the final `simenv` cleanup slice:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c -Iperl t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (96 tests)
- Migration impact snapshot:
  - `simenv::top` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `simenv::anyvariable` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `simenv` now reports `language_agnostic_blocked_rule_count=0`.
- Updated blocker ranking snapshot after the slice:
  - `simenv` no longer contributes blocked rules,
  - current top blockers remain `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), `ebnf::grammar_file` (`raw=4`), and `vhdl::process_statement` (`raw=4`).
- Added a docs-only roadmap backlog note:
  - future naming cleanup should rename backend-neutral array snapshot helper `array_values(array(...))` to clearer `array_copy(array(...))`,
  - no implementation change was made yet; current helper behavior and existing specs remain unchanged for now.
- Implemented Backbone item #3 roadmap slice in `specs/simenv.spec`:
  - converted the remaining raw diagnostic/debug print statements in `singleline_value`, `dquotes`, `perl_dquotes`, `command_substitution`, and `perl_command_substitution` to canonical `print(...)` helper calls,
  - rewrote `variable_substitution` and `comments` to helper flow using `declare`, `substr`, `print`, and generalized `return(...)` where needed.
- Added focused regression lock in `t/phase0_regression.t`:
  - `simenv_quote_substitution_helper_flow_eliminates_raw_fallback`.
- Re-ran validation after the `simenv` quote/substitution slice:
  - `perl -Iperl -c t/phase0_regression.t` => syntax OK
  - `prove -Iperl t/phase0_regression.t` => PASS (95 tests)
- Migration impact snapshot:
  - all seven migrated `simenv` rules now report `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - the previously remaining top `simenv` blockers (`command_substitution`, `dquotes`, `perl_command_substitution`, `perl_dquotes`) are no longer part of the blocked-rule set.
- Updated blocker ranking snapshot after the slice:
  - current top blockers include `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), `ebnf::grammar_file` (`raw=4`), and `vhdl::process_statement` (`raw=4`),
  - no `simenv` rules remain in the current top blocked-rule ranking.
- Implemented Backbone item #3 roadmap slice in `specs/simenv.spec`:
  - converted the raw diagnostic/debug print statements to canonical `print(...)` helper calls in `bs_nl`, `squotes`, `perl_squotes`, `multiline_value`, `bvariable_substitution`, `curlybrace`, and `parenthesis`,
  - preserved existing parser behavior while removing raw-print fallback from that delimiter-helper family.
- Added focused regression lock in `t/phase0_regression.t`:
  - `simenv_delimiter_helper_print_flow_eliminates_raw_fallback`.
- Re-ran validation after the `simenv` delimiter-helper slice:
  - `perl -Iperl -c t/phase0_regression.t` => syntax OK
  - `prove -Iperl t/phase0_regression.t` => PASS (94 tests)
- Migration impact snapshot:
  - all seven migrated `simenv` rules now report `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `simenv::bvariable_substitution` and `simenv::parenthesis` are no longer part of the blocked-rule set.
- Updated blocker ranking snapshot after the slice:
  - current top blockers include `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), `ebnf::grammar_file` (`raw=4`), and `vhdl::process_statement` (`raw=4`),
  - remaining `simenv` blockers are now concentrated in `command_substitution`, `dquotes`, `perl_command_substitution`, and `perl_dquotes`.
- Implemented Backbone item #3 roadmap slice in `specs/BNF.spec`:
  - converted the raw debug-print statements across the BNF grammar to canonical `print(...)` helper calls,
  - used `scalar(IMATCH)` inside helper print payloads where the message depends on the current match value.
- Added focused regression lock in `t/phase0_regression.t`:
  - `bnf_debug_print_helper_flow_eliminates_raw_fallback`.
- Re-ran validation after the `BNF` slice:
  - `perl -Iperl -c t/phase0_regression.t` => syntax OK
  - `prove -Iperl t/phase0_regression.t` => PASS (93 tests)
- Migration impact snapshot:
  - all 12 migrated BNF rules now report `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `BNF::group` is no longer part of the blocked-rule set.
- Updated blocker ranking snapshot after the slice:
  - current top blockers include `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), `ebnf::grammar_file` (`raw=4`), and `vhdl::process_statement` (`raw=4`).
- Implemented Backbone item #3 roadmap slice in `specs/ifelse.spec`:
  - converted all raw debug-print statements in `program`, `if`, `then`, `elsif`, `else`, `while`, and `while_then` from `print "..."` to canonical `print("...")` helper calls,
  - preserved the existing parser flow while eliminating raw-print fallback across the whole file.
- Added focused regression lock in `t/phase0_regression.t`:
  - `ifelse_debug_print_helper_flow_eliminates_raw_fallback`.
- Re-ran validation after the `ifelse` slice:
  - `perl -Iperl -c t/phase0_regression.t` => syntax OK
  - `prove -Iperl t/phase0_regression.t` => PASS (92 tests)
- Migration impact snapshot:
  - all seven migrated `ifelse` rules now report `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - `ifelse::then`, `ifelse::else`, and `ifelse::while_then` are no longer part of the blocked-rule set.
- Updated blocker ranking snapshot after the slice:
  - current top blockers include `Lispish::parenthesis` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), `BNF::group` (`raw=4`), `ebnf::grammar_file` (`raw=4`), and `vhdl::process_statement` (`raw=4`).
- Implemented Backbone item #3 roadmap slice in `perl/LinkedSpec/ActionIR/MethodLowering.pm`, `perl/LinkedSpec/ActionIR/FlowExpr.pm`, and `specs/simenv.spec`:
  - added canonical array snapshot helper `array_values(array(target))` so `.spec` can express array-copy payloads without Perl-specific `[@target]` syntax,
  - extended `assign(target, source_expr)` to support `array(...)` and `hash(...)` targets in addition to scalar targets,
  - migrated `simenv::begin_end_blocks` off Perl-specific array payload forms and onto helper flow (`declare`, `assign`, `push_value`, `if/else/endif`, `substr`, `print`, `return`, `return_undef`, `exit`).
- Added focused regression locks in `t/phase0_regression.t`:
  - `action_rewriter_lowers_array_snapshot_and_array_assign_method_contracts`,
  - `simenv_begin_end_blocks_method_flow_is_language_agnostic_ready`.
- Re-ran validation after the `simenv` slice:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` => syntax OK
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm` => syntax OK
  - `perl -Iperl -c t/phase0_regression.t` => syntax OK
  - `prove -Iperl t/phase0_regression.t` => PASS (91 tests)
- Migration impact snapshot:
  - `simenv::begin_end_blocks` now reports `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and `language_agnostic_action_ir_ready=1`,
  - the rule is no longer in the blocked-rule set for the roadmap-first migration track.
- Updated blocker ranking snapshot after the slice:
  - highest current blocker counts include `Lispish::parenthesis` (`raw=6`), `ifelse::then` (`raw=6`), `ds_vhistory::vhistory` (`raw=5`), `vhdl::subprogram_body` (`raw=5`), and `simenv::bvariable_substitution` (`raw=3`).
- Implemented Backbone item #3 control-flow expression unification + composite switch follow-up in `perl/LinkedSpec.pm`:
  - added unified Lisp-style recursive control-flow expression lowering shared by `if`/`elseif`/`switch` condition/value paths (`or`, `and`, `not`, emptiness predicates, comparison helpers, regex predicate),
  - extended method-value lowering to support collection entry access through `scalar(container, key_or_index)` (including explicit `scalar(array(...), idx)` / `scalar(hash(...), key)` forms) while preserving `scalar(IMATCH_LIST, n)` behavior,
  - added inline composite switch branch lowering so `switch(cond, case(...), default(...))` works directly inside switch arguments, with inline branch actions lowered through existing helper contracts,
  - preserved existing marker-style fluent control-flow behavior (`switch(); case(); default(); endswitch()`) for backward compatibility.
- Extended regression coverage in `t/phase0_regression.t`:
  - `action_rewriter_lowers_fluent_if_else_and_branch_statements` now validates nested Lisp-style conditions and scalar collection-entry accessor lowering,
  - `action_rewriter_lowers_fluent_switch_case_default_with_optional_endcase` now validates inline composite switch(case/default) lowering and descriptor readiness invariants.
- Re-ran full validation after control-flow expression/composite switch follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (68 tests)
- Implemented Backbone item #3 fluent control-flow method-DSL follow-up in `perl/LinkedSpec.pm`:
  - added lowering helpers/contracts for `if`/`i`, `elseif`/`elif`, `else`, `endif`, `switch`, `case`, `default`, optional `endcase`, `endswitch`, and branch statements `say`, `print`, `return_undef`,
  - added control-flow value normalization helpers and contextual stack-aware lowering state for nested/ordered control-flow emission,
  - fixed contextual lowering path usage by removing stale duplicate non-contextual apply call in `_lower_action_code_from_canonical_ir(...)`,
  - added `push_scope_target_arg` handling so scope-injected push forms (for example `push(Top, pipe_operator, rule)`) lower cleanly in fluent branch flows.
- Added and validated fluent control-flow regression coverage in `t/phase0_regression.t`:
  - `action_rewriter_lowers_fluent_if_else_and_branch_statements`,
  - `action_rewriter_lowers_fluent_switch_case_default_with_optional_endcase`.
- Added fluent `pipe_operator` branch-chain showcase coverage:
  - `USER_GUIDE.md` now includes `Fluent Control-Flow Example (pipe_operator with if/else)`,
  - regression lock `action_rewriter_showcase_pipe_operator_if_else_method_chain` verifies expected lowering for method-chained if/else branch behavior.
- Re-ran full validation after fluent control-flow + showcase follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (68 tests)
- Implemented Backbone item #3 composable array-method DSL follow-up in `perl/LinkedSpec.pm`:
  - added/extended lowering contracts for `split`, `trim_each`, `filter_nonempty`, `lowercase_each`, `uppercase_each`, `uniq`, and `filter_match`,
  - introduced recursive function-expression parsing/planning helpers (`_parse_method_function_expr`, `_build_array_pipeline_plan_from_expr`, `_lower_array_pipeline_expr`) to support both dot-chain and nested functional composition (including mixed style),
  - added scope-token handling for method-chain injected forms (`method(Top, ...)`) and improved CSV/slash-literal splitting behavior for nested helper argument parsing.
- Added snippet-level generated-Perl inspection tooling:
  - new script `tools/inspect_spec_codegen.pl` to inspect normalized helper code, generated Perl, canonical action-IR nodes, RAW_PERL fallback count, and unresolved-helper count from focused `.spec` snippets.
- Updated regression coverage in `t/phase0_regression.t` for composable array-method contracts and mixed composition forms:
  - `action_rewriter_lowers_composable_array_string_method_contracts`,
  - `action_rewriter_lowers_additional_composable_array_string_routines`.
- Adjusted lowering output style per user direction:
  - nested functional composition lowers through single-assignment expression composition,
  - removed unnecessary outer parentheses around map-led upstream expression in `uniq(...)` lowering stage.
- Re-ran full validation after composable-array and inspection-tool follow-ups:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `perl -c tools/inspect_spec_codegen.pl` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (65 tests)
- Implemented (pending commit workflow) Backbone item #3 method-contract follow-up in `perl/LinkedSpec.pm`:
  - added method-contract lowering for `return_imatch`/`return_im`, `assign(..., CAPTURE|IMATCH|LMATCH)`, `substr(...)`/`regex_subst(...)`, and `return_array(...)` with nested `array(scalar(...), scalar(...))` payload constructors,
  - added helper/lowering utilities (`_lower_method_value_expr`, `_lower_return_imatch_statement`, `_lower_assign_statement`, `_lower_regex_subst_statement`, `_lower_return_array_statement`, and related normalization helpers),
  - extended contract scanning/canonical mapping so descriptor metadata surfaces canonical `RETURN`, `ASSIGN`, and `REGEX_SUBST` event kinds for these forms.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_lowers_method_contracts_for_capture_and_structured_return_values`.
- Re-ran full validation after method-contract follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (63 tests)
- Landed Backbone item #3 method-like DSL migration slice in `perl/LinkedSpec.pm`:
  - bootstrap method-like parsing now supports chained forms for both action and non-action blocks via `_parse_method_call_chain(...)` and `_render_method_call_chain(...)`,
  - chained method parsing now accepts empty-arg segments (`()`),
  - canonical declaration methods now lower via typed form `declare(array|scalar|hash, ...)` plus aliases (`declare_a/s/h`, `declare_array/scalar/hash`) through explicit `DECLARE` contracts.
- Added focused regression locks in `t/phase0_regression.t`:
  - subtest `action_rewriter_lowers_typed_declare_methods_and_aliases`,
  - subtest `method_like_action_chain_parses_into_multiple_helper_events`.
- Re-ran full validation after typed declare + method-chain parsing follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (62 tests)
- Landed Backbone item #3 indexed push-call wrapper lowering follow-up in `perl/LinkedSpec.pm`:
  - action lowering now explicitly covers full-statement `push @target, call(...)->[index]` wrappers through `push_call_indexed_builtin` contract support.
  - non-indexed `push_call_builtin` now excludes indexed forms so wrapper routing is deterministic.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_canonical_action_ir_lowers_push_call_indexed_wrapper_without_raw_fallback`.
- Re-ran full validation after indexed push-call wrapper follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (60 tests)
- Landed Backbone item #3 return-call wrapper lowering follow-up in `perl/LinkedSpec.pm`:
  - action lowering now explicitly covers full-statement `return call(...)` wrappers through `return_call` contract support.
  - wrapper-only return-call actions now avoid RAW_PERL fallback classification and remain language-agnostic action-IR ready.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_canonical_action_ir_lowers_return_call_wrapper_without_raw_fallback`.
- Re-ran full validation after return-call wrapper lowering follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (59 tests)
- Landed Backbone item #3 method-style action arg-normalization follow-up in `perl/LinkedSpec.pm`:
  - `METHOD_EMPTY_ACTION_CODE_BLOCK` outer-arg trimming now uses whitespace-tolerant boundaries (`^\s*\(` and `\)\s*$`), so leading-space method-arg forms keep balanced helper payloads.
  - method-style `.return ((...))` payloads now lower through structured helper contracts without false unresolved-helper/RAW_PERL blocker classification.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `method_empty_action_return_with_leading_space_args_stays_balanced`.
- Re-ran full validation after method-style arg-normalization follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (58 tests)
- Landed Backbone item #3 call-wrapper lowering follow-up in `perl/LinkedSpec.pm`:
  - action lowering now explicitly covers `my $x = call(...)`, `$x = call(...)`, and `push @arr, call(...)` wrappers,
  - wrapper-only actions now avoid RAW_PERL fallback classification and remain language-agnostic action-IR ready.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_canonical_action_ir_lowers_call_wrappers_without_raw_fallback`.
- Re-ran full validation after call-wrapper lowering follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (57 tests)
- Landed Backbone item #3 descriptor migration blocker-type ratio follow-up in `perl/LinkedSpec.pm`:
  - descriptor-level `meta.action_rewriter_migration` now exposes blocked-rule composition ratios (`language_agnostic_blocked_raw_perl_only_ratio`, `language_agnostic_blocked_unresolved_helper_only_ratio`, `language_agnostic_blocked_mixed_ratio`) normalized by blocked-rule count.
- Extended focused regression lock in `t/phase0_regression.t`:
  - subtest `return_descr_exposes_action_rewriter_migration_blocker_type_breakdown` now validates blocker-type ratio fields in addition to counts/lists.
- Re-ran full validation after descriptor migration blocker-type ratio follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (56 tests)
- Landed Backbone item #3 descriptor migration blocker-type breakdown follow-up in `perl/LinkedSpec.pm`:
  - descriptor-level `meta.action_rewriter_migration` now exposes blocked-rule type counters/lists for raw-perl-only, unresolved-helper-only, and mixed blockers.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `return_descr_exposes_action_rewriter_migration_blocker_type_breakdown`.
- Re-ran full validation after descriptor migration blocker-type breakdown follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (56 tests)
- Cleanup pass on action-rewriter helper entrypoints in `perl/LinkedSpec.pm`:
  - removed unused legacy helper `_apply_action_rewrite_pipeline(...)` (no runtime/test callers),
  - clarified `call_spec_handler_subst(...)` as compatibility/test shim only; runtime rule compilation uses `_rewrite_action_code_with_diagnostics(...)` directly.
- Landed Backbone item #3 descriptor migration prioritization follow-up in `perl/LinkedSpec.pm`:
  - descriptor-level `meta.action_rewriter_migration` now exposes `language_agnostic_blocker_statement_total_count`, `language_agnostic_blocked_rules_by_priority`, and `language_agnostic_top_blocked_rule`,
  - blocked-rule priority ordering is deterministic: blocker statement count (desc), unresolved helper count (desc), raw-Perl dependency count (desc), rule name (asc).
- Extended focused regression lock in `t/phase0_regression.t`:
  - subtest `return_descr_exposes_action_rewriter_migration_summary` now validates blocker total, prioritized blocked-rule ordering, and top blocked rule.
- Re-ran full validation after descriptor migration prioritization follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (55 tests)
- Landed Backbone item #3 descriptor-level migration summary follow-up in `perl/LinkedSpec.pm`:
  - descriptor now exposes top-level `meta.action_rewriter_migration` summary in `return_descr` mode with ready/blocked counts, deterministic rule lists, blocked rule payload details, and readiness ratio,
  - this provides a direct roadmap-aligned prioritization surface for language-agnostic migration backlog selection.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `return_descr_exposes_action_rewriter_migration_summary`.
- Re-ran full validation after descriptor-level migration summary follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (55 tests)
- Landed LinkedSpec.pm maintainability documentation pass in `perl/LinkedSpec.pm`:
  - added subroutine-level docstring-style comment headers (`Function`, `Purpose`, `Args`, `Returns`) across logging, parser generation, RuleIR, rewrite, and parser-resolution helpers,
  - added explanatory comments for important bootstrap/parser globals and structural parser/rewrite sections to improve maintainability and handoff readability.
- Re-ran full validation after documentation pass:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (54 tests)
- Landed Backbone item #3 language-agnostic blocker statement follow-up in `perl/LinkedSpec.pm`:
  - unresolved helper diagnostics are now captured at statement granularity and exposed as `unresolved_helper_events` and `unresolved_helper_statements`,
  - action-rewriter metadata now exposes consolidated blocker statement surface via `language_agnostic_action_ir_blocker_statements` and `language_agnostic_action_ir_blocker_statement_count`.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_meta_exposes_language_agnostic_blocker_statements`.
- Re-ran full validation after blocker statement follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (54 tests)
- Landed Backbone item #3 language-agnostic readiness follow-up in `perl/LinkedSpec.pm`:
  - action-rewriter metadata now exposes `raw_perl_dependency_count`, `raw_perl_dependency_statements`, and `language_agnostic_action_ir_ready` per rule,
  - readiness is now explicitly false when either RAW_PERL fallback dependency or unresolved helper diagnostics are present.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_meta_exposes_language_agnostic_readiness`.
- Re-ran full validation after language-agnostic readiness follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (53 tests)
- User reaffirmed final objective: make `.spec` language-agnostic and stop relying on embedded Perl code-blocks; keep generated host-language code within controlled canonical forms to reduce splitter fragility and simplify multi-backend portability.
- User-directed decision: pause further `_split_action_ir_statements(...)` hardening for now and revisit only when needed by concrete regressions or unsupported production patterns.
- Landed Backbone item #3 canonical splitter pipe-quote follow-up in `perl/LinkedSpec.pm`:
  - `_split_action_ir_statements(...)` now tracks pipe-delimited Perl quote-like payloads with escape handling and multi-segment support for `s|...|...|`/`tr|...|...|`/`y|...|...|`,
  - semicolons inside pipe-quote payload strings are ignored by top-level statement splitting, preventing fallback-fragment noise for statements like `my $re = qr|a;b|`.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_canonical_action_ir_ignores_pipe_quote_semicolon_fragmentation`.
- Re-ran full validation after pipe-quote splitter follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (52 tests)
- Landed Backbone item #3 canonical splitter angle-quote follow-up in `perl/LinkedSpec.pm`:
  - `_split_action_ir_statements(...)` now tracks angle-delimited Perl quote-like payloads with escape and nested-angle handling,
  - semicolons inside angle-quote payload strings are ignored by top-level statement splitting, preventing fallback-fragment noise for statements like `my $re = qr<a;b>`.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_canonical_action_ir_ignores_angle_quote_semicolon_fragmentation`.
- Re-ran full validation after angle-quote splitter follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (51 tests)
- Landed Backbone item #3 canonical splitter slash-quote follow-up in `perl/LinkedSpec.pm`:
  - `_split_action_ir_statements(...)` now tracks slash-delimited Perl quote-like payloads with escape handling,
  - semicolons inside slash-quote payload strings are ignored by top-level statement splitting, preventing fallback-fragment noise for statements like `my $re = qr/a;b/`.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_canonical_action_ir_ignores_slash_quote_semicolon_fragmentation`.
- Re-ran full validation after slash-quote splitter follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (50 tests)
- Landed Backbone item #3 canonical splitter backtick-quote follow-up in `perl/LinkedSpec.pm`:
  - `_split_action_ir_statements(...)` now tracks backtick-quoted strings with escape handling,
  - semicolons inside backtick payload strings are ignored by top-level statement splitting, preventing fallback-fragment noise for statements like ``my $cmd = `echo a;b` ``.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_canonical_action_ir_ignores_backtick_semicolon_fragmentation`.
- Re-ran full validation after backtick-quote splitter follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (49 tests)
- Landed Backbone item #3 canonical splitter line-comment follow-up in `perl/LinkedSpec.pm`:
  - `_split_action_ir_statements(...)` now tracks Perl line comments outside quoted strings,
  - semicolons inside `# ...` comments are ignored by top-level statement splitting, avoiding comment-fragmented RAW_PERL fallback shards.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_canonical_action_ir_ignores_line_comment_semicolon_fragmentation`.
- Re-ran full validation after line-comment splitter follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (48 tests)
- Landed Backbone item #3 whitespace-tolerant helper lowering follow-up in `perl/LinkedSpec.pm`:
  - helper-lowering substitutions in `_build_action_lowering_contracts(...)` now accept optional spacing around helper names/arguments (`call (X)`, `CAPTURE_IF ( )`, etc.),
  - spacing-only helper variants now lower through canonical action-IR flow instead of remaining unresolved.
- Updated focused regression locks in `t/phase0_regression.t`:
  - `action_rewriter_pipeline_helper_substitutions` now validates spaced helper forms,
  - `action_rewriter_canonical_ir_lowering_preserves_helper_and_raw_behavior` now locks spaced helper lowering in mixed helper + RAW_PERL flows,
  - `action_rewriter_reports_unresolved_helpers_in_rule_meta` now uses label-mismatch helper forms (`return_a(Leaf)`, `return(Leaf, $x)`) to preserve unresolved-helper diagnostics coverage.
- Re-ran full validation after whitespace-tolerant helper lowering follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (47 tests)
- Landed Backbone item #3 canonical action-IR splitting follow-up in `perl/LinkedSpec.pm`:
  - `_split_action_ir_statements(...)` is now nesting-aware across `()`, `{}`, `[]`, and quoted strings,
  - semicolons inside nested helper payloads no longer split helper statements into false `RAW_PERL` canonical fallback fragments.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_canonical_action_ir_handles_nested_semicolon_payloads`.
- Re-ran full validation after canonical action-IR splitting follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (47 tests)
- Landed Backbone item #3 canonical-IR-driven lowering follow-up in `perl/LinkedSpec.pm`:
  - action rewrite emission now lowers directly from canonical action-IR events via `_lower_action_code_from_canonical_ir(...)` inside `_rewrite_action_code_with_diagnostics(...)`,
  - lowering now uses event-driven in-place replacement on original action code, preserving unresolved helper forms and raw Perl regions while reducing regex-first coupling.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_canonical_ir_lowering_preserves_helper_and_raw_behavior`.
- Re-ran full validation after canonical-IR-driven lowering follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (46 tests)
- Landed Backbone item #3 canonical action-IR follow-up in `perl/LinkedSpec.pm`:
  - helper payload events are now promoted into canonical action-IR events,
  - non-helper statements are now represented explicitly as `RAW_PERL` fallback canonical events.
- Extended `spec->{rule}{meta}{action_rewriter}` metadata:
  - added `canonical_action_ir_count`, `canonical_action_ir_nodes`, `canonical_action_ir_hits`, `canonical_action_ir_events`, and `canonical_action_ir_fallback_count`.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_meta_exposes_canonical_action_ir_with_raw_fallback`.
- Re-ran full validation after canonical action-IR follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (45 tests)
- Landed Backbone item #3 helper payload-event follow-up in `perl/LinkedSpec.pm`:
  - helper invocation payload scanning is now explicit (`_scan_contract_ir_events`) with argument trimming (`_trim_action_ir_value`),
  - helper action-IR aggregation now carries structured per-event payloads (`ir_node`, `contract_id`, `raw`, `args`) in addition to counts.
- Extended `spec->{rule}{meta}{action_rewriter}` metadata:
  - added `helper_action_ir_events` for structured helper payload introspection.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_meta_exposes_helper_action_ir_payload_events`.
- Re-ran full validation after helper payload-event follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (44 tests)
- Landed Backbone item #3 helper action-IR follow-up in `perl/LinkedSpec.pm`:
  - helper-lowering contracts now carry explicit `ir_node` identities (e.g. `CALL`, `RETURN_A`, `CAPTURE_IF`),
  - helper action-IR node hits are now collected pre-lowering via `_collect_action_helper_ir_nodes(...)`,
  - rewrite diagnostics aggregation now tracks both unresolved-helper diagnostics and helper action-IR counters.
- Extended `spec->{rule}{meta}{action_rewriter}` metadata:
  - added `helper_action_ir_count`, `helper_action_ir_nodes`, and `helper_action_ir_hits`.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_meta_exposes_helper_action_ir_nodes`.
- Re-ran full validation after helper action-IR follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (43 tests)
- Landed Backbone item #3 lowering-contract follow-up in `perl/LinkedSpec.pm`:
  - helper lowering is now centralized in `_build_action_lowering_contracts($label)`,
  - rewrite rule compilation and unresolved-helper diagnostics now share the same contract definitions.
- Extended action-rewriter metadata in `spec->{rule}{meta}{action_rewriter}`:
  - added `rewrite_contract_ids` for stable tooling introspection of active helper-lowering surface.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_meta_exposes_lowering_contract_ids`.
- Re-ran full validation after lowering-contract follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (42 tests)
- Landed Backbone item #3 diagnostics follow-up in `perl/LinkedSpec.pm`:
  - action rewrite flow now tracks unresolved helper forms via `_find_unresolved_action_helpers`, `_accumulate_action_rewrite_diagnostics`, and `_rewrite_action_code_with_diagnostics`.
  - per-rule diagnostics are now exposed at `spec->{rule}{meta}{action_rewriter}` with unresolved helper names/hit counts.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_reports_unresolved_helpers_in_rule_meta`.
- Re-ran full validation after diagnostics follow-up:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (41 tests)
- Landed Backbone Refactor Track item #3 in `perl/LinkedSpec.pm`:
  - `call_spec_handler_subst()` now routes rewrites via `_build_action_rewrite_rules($label)` and `_apply_action_rewrite_pipeline($code, $rules)` instead of ad hoc substitution chaining.
- Added focused helper-substitution regression lock in `t/phase0_regression.t`:
  - subtest `action_rewriter_pipeline_helper_substitutions`.
- Stabilized new regression expectation for `return_a(label,arg)` helper rewrite:
  - expected output now preserves current argument spacing behavior (`( $x)`).
- Re-ran full validation after item #3:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `perl -c t/phase0_regression.t` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (40 tests)
- Landed Backbone Refactor Track item #2 in `perl/LinkedSpec.pm`:
  - `spec_entry()` now runs staged RuleIR helpers (`_collect_rule_ir`, `_plan_rule_ir_meta`, `_validate_rule_ir_or_exit`, `_build_rule_ir_emit_context`),
  - collection/planning/validation/emit-context normalization are now explicit phases before handler-template assembly.
- Added focused RuleIR regression lock in `t/phase0_regression.t`:
  - subtest `ruleir_pipeline_preserves_acode_gdata_mapping_order`.
- Re-ran validation after Backbone item #2:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (39 tests)
- Landed Backbone Refactor Track item #1 in `perl/LinkedSpec.pm`:
  - hardcoded bootstrap rules now carry explicit `id` + semantic `tags`,
  - root scanner dispatch now uses `start_dispatch` mapping instead of positional `index + 1`,
  - recursive brace handling now resolves `CURLY_BRACE` by rule ID instead of fixed numeric slot.
- Added bootstrap-integrity guards:
  - required bootstrap IDs (`SPEC_ROOT`, `CURLY_BRACE`) are validated at load time,
  - bootstrap start-token registry must be non-empty.
- Added focused regression lock in `t/phase0_regression.t`:
  - subtest `bootstrap_registry_curly_brace_recursion_smoke`.
- Re-ran validation after Backbone item #1:
  - `perl -c perl/LinkedSpec.pm` => syntax OK
  - `prove -v -Iperl t/phase0_regression.t` => PASS (38 tests)
- Paused further `get_parser` hardening by explicit user direction and shifted focus to `LinkedSpec.pm` core structure.
- Landed core execution-structure increment in `perl/LinkedSpec.pm`:
  - added `Get(..., return_descr => 1)` for descriptor introspection (`spec` + `gdata`),
  - added deterministic rule strategy helpers (`_select_rule_handler_variant`, `_build_rule_execution_meta`),
  - added per-rule `meta` payload under `spec->{rule}{meta}` (counts, strategy, loop marker),
  - added dedicated `AND_SINGLE_ACODE` template for single-regex AND action rules,
  - replaced non-deterministic handler selection via hash-key order with metadata-based selection.
- Added regression lock in `t/phase0_regression.t`:
  - subtest `get_return_descr_rule_meta_single_vs_multi_strategy` validates descriptor metadata and single-vs-multi AND strategy mapping.
- Re-ran baseline after core changes:
  - command: `prove -v -Iperl t/phase0_regression.t`
  - result: PASS
  - note: all 37 tests pass.
- Created and initialized live documents:
  - `ROADMAP.md`
  - `USER_GUIDE.md`
  - `DEVELOPMENT_NOTES.md`
  - `CHANGES.md`
  - `MEMORY.md`
- Recorded user clarification that downstream consumers are independent projects and updated planning notes accordingly.
- Recorded subsequent scope decision: downstream-consumer work is deferred for now.
- Switched Phase-0 baseline from ad-hoc script to `Test::More` (`t/phase0_regression.t`).
- Current test scope excludes `tclite.spec`.
- Baseline command executed: `prove -Iperl t/phase0_regression.t`
- Baseline result: PASS.
- `specs/ebnf.spec` is now explicitly smoke-tested (invariant-based) in `t/phase0_regression.t`.
- DSL validator fix landed in `perl/LinkedSpec.pm` for escaped-slash regex handling; `regdef.spec` now passes baseline without TODO.
- Corpus regression added in `t/phase0_regression.t`:
  - `plugin/*.plg` via `pplugin.spec` (52 files)
  - `conf/*.conf` via Lispish flow (53 files)
  - `tablescript/*.ts` via Lispish flow (23 files)
  - `ebnf/*.ebnf` via `ebnf.spec` (7 files)
- `conf/httpd.conf` removed by explicit user request because it is not valid for intended Lisp-like conf corpus.
- Phase-1 isolation implementation progressed and validated:
  - `LinkedSpec` no longer eagerly imports `PPlugin` at module load.
  - `LinkedSpec::AUTOLOAD` now handles lazy `PPlugin` loading path.
  - `LinkedSpec::get_parser` now resolves module-relative `specs/*.spec` first (no cwd assumption), then lazy-falls back to `PathSearch`.
  - `_resolve_local_spec_path` return-flow bug fixed so module-relative matches are actually returned.
  - `t/phase0_regression.t` no longer imports `Lispish.pm`; corpus stream parsing uses LinkedSpec-generated `Lispish` parser coderef.
- Re-ran baseline after these changes:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
- Added explicit resolution-path regression coverage in `t/phase0_regression.t`:
  - `get_parser_local_resolution_without_pathsearch`: verifies module-relative resolution works from non-project cwd and keeps `PathSearch.pm` unloaded.
  - `get_parser_pathsearch_fallback`: creates a temporary fallback spec outside `specs/` and verifies fallback parser creation/execution with lazy `PathSearch` load.
- Re-ran baseline with the new subtests:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
- Follow-up fallback-path isolation fix:
  - removed unused `use Global;` from `perl/PathSearch.pm`.
  - root-cause chain removed: `PathSearch -> Global -> HUtils -> Lispish`.
- Re-ran baseline after the decoupling:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - observation: fallback path no longer emits the prior `Lispish.pm` smartmatch warnings.
- Added missing local-resolution coverage in `t/phase0_regression.t`:
  - `get_parser_explicit_path_resolution_without_pathsearch`
  - `get_parser_cwd_name_spec_resolution_without_pathsearch`
- Re-ran baseline with expanded resolution-order coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 10 top-level test blocks pass.
- Added unresolved-spec negative-path coverage in `t/phase0_regression.t`:
  - subtest `get_parser_unresolved_spec_reports_error`,
  - scenarios: missing spec name and missing explicit path,
  - assertions: no die, undef return, and diagnostic content checks.
- Re-ran baseline with the new negative-path coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 11 top-level test blocks pass.
- Added open-failure negative-path coverage in `t/phase0_regression.t`:
  - subtest `get_parser_open_failure_reports_error`,
  - scenario: existing but unreadable spec path,
  - assertions: no die, undef return, open-failure diagnostic content.
- Re-ran baseline with open-failure coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 12 top-level test blocks pass.
- Added malformed-spec negative-path coverage in `t/phase0_regression.t`:
  - subtest `get_parser_malformed_spec_reports_validation_error`,
  - scenario: invalid DSL content (no rule definition) in temporary `.spec`,
  - assertions: no die, undef return, validation + critical-error diagnostics.
- Re-ran baseline with malformed-spec coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 13 top-level test blocks pass.
- Added malformed-handler runtime-error coverage in `t/phase0_regression.t`:
  - subtest `get_parser_malformed_handler_runtime_error`,
  - scenario: action block with invalid embedded Perl (`my $broken = ;`),
  - assertions: parser coderef builds, invocation yields undef AST, inner eval syntax error is captured.
- Added helper `run_parser_with_captured_io` to capture invocation IO + inner eval diagnostics with exit trapping.
- Re-ran baseline with malformed-handler runtime coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 14 top-level test blocks pass.
- Added mixed ACTION/BLIND CALL explicit-exit coverage in `t/phase0_regression.t`:
  - subtest `get_parser_mixed_action_blind_call_trapped_exit`,
  - scenario: `Top` rule intentionally mixes `->` and `=>`,
  - assertions: subprocess exit code is `1` and diagnostics include rule + remediation guidance.
- Added helper `run_get_parser_in_subprocess` (`IPC::Open3`) for safe exit-path testing without in-process context corruption.
- Re-ran baseline with explicit-exit coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 15 top-level test blocks pass.
- Added parser invalid-input runtime behavior lock in `t/phase0_regression.t`:
  - subtest `parser_invalid_input_returns_undef_without_exit`,
  - helper API keeps second argument as string and uses sentinel conversion (`__INPUT_ARRAYREF__`) inside subprocess to pass controlled non-scalar-ref input,
  - assertions lock current behavior: subprocess exit code `0`, undefined AST marker present, no handler-generation error banner.
- Re-ran baseline with invalid-input behavior lock:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 16 top-level test blocks pass.
- Hardened `LinkedSpec::get_parser` invalid-name entry path in `perl/LinkedSpec.pm`:
  - added early guard for `undef`/empty spec-name arguments,
  - invalid-name calls now emit `Invalid spec name` diagnostics and return `undef` before path resolution/fallback.
- Added empty-spec-name regression coverage in `t/phase0_regression.t`:
  - subtest `get_parser_empty_spec_name_reports_error_without_pathsearch`,
  - validates both `undef` and `''` inputs,
  - asserts no die, `undef` return, and no `PathSearch.pm` load for these invalid-name calls.
- Re-ran baseline with empty-spec-name guard coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 17 top-level test blocks pass.
- Added fallback-loader failure-path coverage in `t/phase0_regression.t`:
  - subtest `get_parser_pathsearch_load_failure_reports_error`,
  - forces fallback resolution while isolating `@INC` to an empty temporary directory so `require PathSearch` fails,
  - assertions: no die, undef parser, unresolved-spec + `PathSearch load failed` diagnostics, and `PathSearch.pm` remains unloaded.
- Re-ran baseline with fallback-loader failure coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 18 top-level test blocks pass.
- Hardened explicit-path miss handling in `LinkedSpec::get_parser`:
  - unresolved path-like spec names (with path separators) now report `Spec path not found` directly,
  - fallback `PathSearch` loading is skipped for these explicit-path miss cases.
- Added explicit-path miss no-fallback regression coverage in `t/phase0_regression.t`:
  - subtest `get_parser_missing_explicit_path_skips_pathsearch`,
  - assertions: no die, undef return, requested-path diagnostics, and `PathSearch.pm` remains unloaded.
- Re-ran baseline with explicit-path miss no-fallback coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 19 top-level test blocks pass.
- Hardened missing `.spec` basename handling in `LinkedSpec::get_parser`:
  - unresolved `.spec`-suffixed names now report `Spec path not found` directly,
  - fallback `PathSearch` loading is skipped for these explicit `.spec` miss cases.
- Added missing `.spec` basename no-fallback regression coverage in `t/phase0_regression.t`:
  - subtest `get_parser_missing_dot_spec_name_skips_pathsearch`,
  - assertions: no die, undef return, requested-name diagnostics, and `PathSearch.pm` remains unloaded.
- Re-ran baseline with missing `.spec` basename no-fallback coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 20 top-level test blocks pass.
- Hardened fallback runtime-failure handling in `LinkedSpec::get_parser`:
  - wrapped `PathSearch->go` in `eval` inside fallback flow,
  - runtime exceptions now emit diagnostics and return `undef` instead of escaping via outer die.
- Added PathSearch runtime-failure regression coverage in `t/phase0_regression.t`:
  - subtest `get_parser_pathsearch_runtime_failure_reports_error`,
  - monkey-patches `PathSearch::go` to `die`,
  - assertions: no outer die, undef parser, unresolved-spec/runtime-failure diagnostics, and sentinel die marker in output.
- Re-ran baseline with fallback runtime-failure coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 21 top-level test blocks pass.
- Added fallback-resolved-missing-file coverage in `t/phase0_regression.t`:
  - subtest `get_parser_pathsearch_returns_missing_file_reports_error`,
  - monkey-patches `PathSearch::go` to return a deterministic non-existent `*.spec` path,
  - assertions: no die, undef parser, and diagnostics include not-found + requested spec + resolved missing path.
- Re-ran baseline with fallback-resolved-missing-file coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 22 top-level test blocks pass.
- Hardened whitespace-only spec-name input handling in `LinkedSpec::get_parser`:
  - invalid-name gate now requires at least one non-whitespace character,
  - whitespace-only names now fail fast with diagnostics + undef return before any fallback activity.
- Added whitespace-only invalid-name regression coverage in `t/phase0_regression.t`:
  - subtest `get_parser_whitespace_spec_name_reports_error_without_pathsearch`,
  - covers `'   '` and `" \t\n"` inputs,
  - assertions: no die, undef parser, invalid-name diagnostics, and `PathSearch.pm` remains unloaded.
- Re-ran baseline with whitespace-only invalid-name coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 23 top-level test blocks pass.
- Hardened non-scalar spec-name input handling in `LinkedSpec::get_parser`:
  - invalid-name gate now rejects reference-type spec-name arguments,
  - non-scalar names fail fast with diagnostics + undef return before any fallback activity.
- Added non-scalar invalid-name regression coverage in `t/phase0_regression.t`:
  - subtest `get_parser_non_scalar_spec_name_reports_error_without_pathsearch`,
  - covers arrayref (`[]`) and hashref (`{}`) inputs,
  - assertions: no die, undef parser, invalid-name diagnostics, and `PathSearch.pm` remains unloaded.
- Re-ran baseline with non-scalar invalid-name coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 24 top-level test blocks pass.
- Hardened NUL-byte spec-name input handling in `LinkedSpec::get_parser`:
  - invalid-name gate now rejects spec-name strings containing `\0`,
  - NUL-byte names fail fast with diagnostics + undef return before any fallback activity.
- Added NUL-byte invalid-name regression coverage in `t/phase0_regression.t`:
  - subtest `get_parser_nul_byte_spec_name_reports_error_without_pathsearch`,
  - covers `"\0"` and `"Lispish\0.spec"` inputs,
  - assertions: no die, undef parser, invalid-name diagnostics, and `PathSearch.pm` remains unloaded.
- Re-ran baseline with NUL-byte invalid-name coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 25 top-level test blocks pass.
- Expanded non-scalar invalid-name coverage in `t/phase0_regression.t`:
  - added subtest `get_parser_non_scalar_reference_variants_reports_error_without_pathsearch`,
  - covers scalarref, coderef, and regexp-ref spec-name arguments in addition to existing arrayref/hashref checks,
  - assertions: no die, undef parser, invalid-name diagnostics, and `PathSearch.pm` remains unloaded.
- Re-ran baseline with non-scalar reference-variant coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 26 top-level test blocks pass.
- Fixed duplicate fallback resolver invocation in `LinkedSpec::get_parser`:
  - removed stale second unguarded `PathSearch->go` call after eval-guarded resolver assignment.
- Added fallback go-once regression coverage in `t/phase0_regression.t`:
  - subtest `get_parser_pathsearch_fallback_calls_go_once`,
  - monkey-patches `PathSearch::go` to count invocations and return a valid temporary spec path,
  - assertions: no die, parser coderef returned, go-call count is exactly 1, parser invocation yields AST.
- Re-ran baseline with go-once fallback coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 27 top-level test blocks pass.
- Hardened padded spec-name input handling in `LinkedSpec::get_parser`:
  - invalid-name gate now rejects leading/trailing whitespace in otherwise non-empty names,
  - padded names fail fast with diagnostics + undef return before fallback activity.
- Added padded-spec-name invalid-input regression coverage in `t/phase0_regression.t`:
  - subtest `get_parser_padded_spec_name_reports_error_without_pathsearch`,
  - covers `' Lispish'` and `'Lispish '` inputs,
  - assertions: no die, undef parser, invalid-name diagnostics, and `PathSearch.pm` remains unloaded.
- Re-ran baseline with padded-spec-name coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 28 top-level test blocks pass.
- Hardened control-character spec-name input handling in `LinkedSpec::get_parser`:
  - invalid-name gate now rejects `\t`, `\r`, and `\n` in spec-name values,
  - control-character names fail fast with diagnostics + undef return before fallback activity.
- Added control-character invalid-input regression coverage in `t/phase0_regression.t`:
  - subtest `get_parser_control_char_spec_name_reports_error_without_pathsearch`,
  - covers `"Lis\tpish"` and `"Lis\npish"` inputs,
  - assertions: no die, undef parser, invalid-name diagnostics, and `PathSearch.pm` remains unloaded.
- Re-ran baseline with control-character coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 29 top-level test blocks pass.
- Generalized control-byte validation in `LinkedSpec::get_parser`:
  - replaced targeted `\t/\r/\n` filter with generalized control-byte check (`/[[:cntrl:]]/`),
  - preserves existing behavior while covering additional control-byte variants.
- Added additional-control-byte regression coverage in `t/phase0_regression.t`:
  - subtest `get_parser_additional_control_byte_spec_name_reports_error_without_pathsearch`,
  - covers BEL (`"Lis\apish"`) and US (`"Lis\x1Fpish"`) inputs,
  - assertions: no die, undef parser, invalid-name diagnostics, and `PathSearch.pm` remains unloaded.
- Re-ran baseline with generalized control-byte coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 30 top-level test blocks pass.
- Added windows-style explicit-path miss coverage in `t/phase0_regression.t`:
  - subtest `get_parser_missing_windows_style_path_skips_pathsearch`,
  - scenario uses missing backslash-separated path (`tmp_phase1_missing\\does_not_exist.spec`),
  - assertions: no die, undef parser, not-found diagnostics include requested token, and `PathSearch.pm` remains unloaded.
- Re-ran baseline with windows-style explicit-path miss coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 31 top-level test blocks pass.
- Hardened directory-path handling in `LinkedSpec::get_parser`:
  - explicit directory path inputs now report `Spec path is not a file` and return undef,
  - fallback-resolved directory paths now report directory-path diagnostics and return undef.
- Added directory-path regression coverage in `t/phase0_regression.t`:
  - `get_parser_explicit_directory_path_reports_error_without_pathsearch`,
  - `get_parser_pathsearch_returns_directory_reports_error`,
  - assertions include no die, undef parser, directory-path diagnostics, and fallback resolver single-call behavior.
- Re-ran baseline with directory-path handling coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 33 top-level test blocks pass.
- Generalized non-regular path handling in `LinkedSpec::get_parser`:
  - existing explicit paths that are not regular files now consistently report `Spec path is not a file`,
  - fallback-resolved existing non-regular paths now use the same not-a-file diagnostics,
  - diagnostics include `type='directory'` or `type='non-regular'`.
- Added non-regular-path regression coverage in `t/phase0_regression.t`:
  - `get_parser_explicit_non_regular_path_reports_error_without_pathsearch`,
  - `get_parser_pathsearch_returns_non_regular_path_reports_error`,
  - uses `File::Spec->devnull` for stable non-regular path checks,
  - assertions: no die, undef parser, not-a-file diagnostics with type marker, and single fallback resolver invocation.
- Re-ran baseline with non-regular-path handling coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 35 top-level test blocks pass.
- Added explicit-miss bypass-when-loaded coverage in `t/phase0_regression.t`:
  - subtest `get_parser_explicit_miss_bypasses_pathsearch_when_loaded`,
  - preloads `PathSearch.pm`, monkey-patches `PathSearch::go` with call counter + sentinel,
  - asserts explicit missing path and missing `.spec` basename both return undef/not-found without invoking `PathSearch::go`.
- Re-ran baseline with explicit-bypass-when-loaded coverage:
  - command: `prove -v -I perl t/phase0_regression.t`
  - result: PASS
  - note: all 36 top-level test blocks pass.

## Update Policy
Update this file after every meaningful exchange/task completion with:
- What changed,
- Why it changed,
- What remains,
- Exact next step.
- If a commit was created, append hash + subject in `Recent Commit Ledger (Newest First)`.
- Method-like DSL control-flow now accepts punctuation-light attached branch aliases too: `else { ... }` and `default { ... }` lower the same as `else() { ... }` and `default() { ... }` on composite-`if(...)`, inline-composite switch, and marker-style switch branch-body surfaces.
- 2026-03-17: Added parser-oriented `count_keys(...)` hash/object-size reducer lowering so `.spec` rules can derive one scalar key-count value from working hashes and hash-valued expressions across assignment sources, return payloads, and numeric comparison inputs, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented `has_key(...)` hash/object key-presence lowering so `.spec` rules can ask whether a field exists at all across assignment sources, return payloads, and flow conditions, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented array `take_last(...)` lowering so `.spec` rules can now derive one canonical trailing-suffix array value from direct arrays, projected arrays such as `sorted_keys(...)` / `sorted_values(...)`, and array-valued fallback chains too: `take_last(array_expr)` keeps the last `1` entry by default, while `take_last(array_expr, n)` keeps the last `n` entries across array assignment sources, direct return payloads, reducer composition, and nested scalar(container, index) reads, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-17: Added explicit parser-oriented drop aliases `drop_front(...)` and `drop_back(...)` as exact lowering aliases of `tail(...)` and `drop_last(...)`, respectively, with representative fluent-versus-structured regression coverage on both action-edge and lifecycle surfaces.
- 2026-03-17: Added parser-oriented scalar boundary predicates `starts_with(...)` and `ends_with(...)` so `.spec` rules can now keep normalized prefix/suffix checks inside backend-neutral value expressions across assignments, direct return payloads, and flow conditions, with fluent-versus-structured parity locked on both action-edge and lifecycle surfaces.
- 2026-03-19: Shifted the next parser-core slice away from more helper farming and toward explicit rule-behavior contract work. The current rule-label suffixes `:&`, `:|`, `:+`, `:*`, and `:?` are now being treated as supported surface to lock and document before any future `OR{N,M}` / `AND{N,M}` extension work.
- 2026-03-19: Re-confirmed that `@move_pos` still exists in the extracted code path and should be documented as a split-boundary cursor move, not a free-standing collector. Its practical value is staged parsing: use stable anchors to isolate raw inner regions first, then parse those regions in a second pass with another `.spec` or follow-up parser.
- 2026-03-19: Agreed naming cleanup for the split-boundary cursor: `@capture_from_here` is now the preferred author-facing spelling, while `@move_pos` stays as the compatibility alias. The internal lowering remains `MOVE_POS` / `$IPOS = pos $$STRING`.
- 2026-03-19: Landed bounded repeated-choice rule labels `OR{N,M}`, `OR{N}`, `OR{N,}`, and `OR{,M}` as the first explicit grouped-rule extension. The implementation threads `rep_min` / `rep_max` through bootstrap label parsing, RuleIR metadata, and the existing repetition handlers; bounded `AND` remains deliberately deferred because it needs sequence-repetition semantics rather than reused choice-repetition machinery.
- 2026-03-19: Landed bounded repeated-sequence rule labels `AND{N,M}`, `AND{N}`, `AND{N,}`, and `AND{,M}` as the next explicit grouped-rule extension. The implementation threads `rep_min` / `rep_max` through bootstrap label parsing, RuleIR metadata, and dedicated repeated-sequence handler variants, with metadata locked on both action and blind-call sequence paths plus representative runtime checks for bounded ordered repetition, so ordered repetition now has an explicit user-facing contract too.
- 2026-03-19: Landed plain standalone `OR` as the explicit worded repeated-choice rule label. `rule:OR` now lowers with the same repetition-family metadata contract as `rule:OR{1,}` and is runtime-locked against that open-ended bounded form, while plain standalone `AND` remains deferred and is explicitly regression-locked as rejected syntax for now. Bare historical `rule:` remains the author-facing baseline mental model for that repeated-choice family rather than a promise of byte-for-byte handler identity.
- 2026-03-19: Added the missing general `.spec` file-structure explanation to the user docs. `USER_GUIDE.md` now teaches `.spec` files as paragraph-oriented rule files: each rule starts at `rule:` / `rule::`, continues until the next rule start or EOF, and then contains regexes, lifecycles, and edges as free-form paragraph members after that first anchor. This was added specifically to demystify the file format apart from the helper-method surface.
- 2026-03-19: Added the matching action-edge indexing explanation to the same general guide area. `USER_GUIDE.md` now says explicitly that `-> rule` is the same as `-> rule[0]`, and that `-> rule[N]` targets the `(N+1)`th regex of the referenced rule. That first-regex default is now documented as part of the core `.spec` file model rather than being left implicit.
- 2026-03-19: Tightened that guide wording with the practical authoring pattern too: indexed `rule[N]` targeting is now described primarily as a same-rule recursive mechanism, while cross-rule edges are documented as normally entering through `-> B` / `-> B[0]` rather than higher regex slots.
- 2026-03-19: Landed plain standalone `AND` as the explicit worded ordered-sequence rule label. `rule:AND` now lowers with the same ordered-sequence runtime behavior as `rule:&`, is regression-locked against that ampersand baseline, and is now documented as supported surface. `AND+` is the remaining deferred shorthand in that family.
- 2026-03-19: Landed plain standalone `AND+` as the explicit open-ended repeated-sequence shorthand. `rule:AND+` now lowers with the same min-one repeated-sequence metadata contract and runtime behavior as `rule:AND{1,}`, is regression-locked against that bounded-open baseline, and is now documented as supported surface instead of deferred grouped-rule exploration.
- 2026-03-19: Hardened `LinkedSpec::Validation` on the current rule-label surface. Validation now recognizes explicit `AND+`, bounded `OR{...}` / `AND{...}`, and inline rule-label lines with same-line regexes / `@capture_from_here`; it now catches duplicate regular-rule labels across current mode spellings and rejects malformed grouped labels like `AND{,}` earlier instead of leaving those cases entirely to bootstrap parse failure.
- 2026-03-20: Picked up a concrete Phase 5 runtime-modernization slice. `SpecEntry.pm` no longer hard-exits when the generated default action-edge handler hits a `LinkedRE::or(...)` dispatch failure; it now raises a normal eval-visible handler-generation error instead, and `t/phase0_regression.t` now forces that runtime seam to fail to prove parser invocation still returns `undef` plus inner eval error without process termination. Remaining next step on this line: look for the next abrupt-exit or inconsistent runtime-error seam after the current regression baseline stays green.
- 2026-03-20: Continued the same Phase 5 runtime/diagnostics line in `Compiler.pm`. `run_get_pipeline(...)` now records structured failure context in injected `runtime_ctx->{last_error}` for validation, bootstrap-parse, spec-descriptor, and generated-descriptor-validation failures, and clears stale `last_error` state on successful entry. Regression coverage now locks malformed-spec validation failure capture, generated-descriptor validation failure capture, and success-path stale-error clearing. Remaining next step on this line: decide whether the next slice should widen `last_error` capture into `Runtime::run_get` / facade-facing convenience surfaces or move to another remaining inconsistent compiler/runtime diagnostic seam.
- 2026-03-20: Followed through on that next step. `LinkedSpec::Runtime::run_get(...)` now accepts `runtime_ctx_ref => \$ctx`, stores the live runtime context there before compiler delegation, and therefore lets both `Runtime::run_get(...)` and `LinkedSpec::Get(...)` expose `top_rule`, parser-source chunk capture, and structured compile failures at `$ctx->{last_error}` without changing their main return shape. Regression coverage now locks success-path context capture through `Runtime::run_get(...)` and failure-path structured error capture through `LinkedSpec::Get(...)`.
- 2026-03-20: Continued the same Phase 5 thread into `get_parser(...)`. `LinkedSpec::ParserFactory::run_get_parser(...)` now initializes/uses the opt-in `runtime_ctx_ref => \$ctx` hook early enough to record parser-factory failures before compilation starts, and `LinkedSpec::Runtime::run_get(...)` now reuses an existing context hash instead of replacing it. That gives file-oriented callers one continuous context across spec-name validation, path resolution, file loading, and later compiler failures, with preserved `spec_name`, resolved `spec_path`, and whichever structured `last_error` payload was last written. Regression coverage now locks parser-factory resolution failure capture and shared-context continuity across compile failure.
- 2026-03-20: Tightened that same structured diagnostics payload so `last_error` now includes `owner_stage` plus `spec_name` / `spec_path` when known. This makes the failure record more self-contained for persistence, crash recovery, or trace-adjacent logging, especially on the `get_parser(...)` path where parser-factory and compiler failures now both carry the requested spec identity and a stable combined owner-stage marker.
- 2026-03-20: Continued the same Phase 5 runtime/diagnostics line into parser execution failures. Returned parser coderefs now clear stale `runtime_ctx->{last_error}` at invocation entry, and compiled handler eval failures now write a structured `runtime_handler` payload there with `rule_label`, `handler_variant`, and preserved spec identity when known. Regression coverage now locks both inline `Get(...)` runtime failure capture/clear behavior and file-oriented `get_parser(...)` runtime failure capture with preserved `spec_name` / `spec_path`.
- 2026-03-20: Continued the same Phase 5 diagnostics line into the remaining outer parser-die seam. The top-level parser closure returned by `Compiler.pm` now promotes outer top-rule invocation dies into a structured `runtime_parser` payload before rethrowing, including `rule_label`, `handler_variant`, and preserved spec identity when known. Regression coverage now locks that path through an injected custom compiler callback that returns a top-level handler coderef which dies directly.
- 2026-03-21: Continued the same Phase 5 diagnostics line back into compile-time descriptor assembly. `LinkedSpec::Compiler::run_get_pipeline(...)` now traps exceptions thrown while `spec_descr(...)` is compiling parsed rule entries and while final descriptor assembly is building `gdata`, then records those failures in the same structured `compiler_pipeline` `last_error` channel under `spec_descr` / `build_final_descr`. Regression coverage now forces both a `compile_spec_entry(...)` die and a `spec_gdata(...)` die so the shared runtime-context diagnostics story stays continuous across compile-time callback exceptions too.
- 2026-03-21: Continued that same Phase 5 line across the earlier compiler-stage callbacks as well. `LinkedSpec::Compiler::run_get_pipeline(...)` now traps exceptions from `validate_spec_content(...)`, `validate_dsl_syntax(...)`, `bootstrap_parse(...)`, and `validate_gdata_references(...)` and normalizes them into the same structured `compiler_pipeline` `last_error` channel. Regression coverage now forces all four exception seams so the runtime-context diagnostics contract stays continuous whether those stages fail by returning false or by throwing.
- 2026-03-21: Continued the same Phase 5 diagnostics normalization on the parser-factory side. `LinkedSpec::ParserFactory::run_get_parser(...)` now traps exceptions from `validate_spec_name(...)`, `resolve_spec_path(...)`, `load_spec_content(...)`, and `compile_spec(...)` and records parser-factory `last_error` payloads instead of leaking raw callback dies. When `compile_spec(...)` already wrote a structured deeper-owner payload before throwing, that richer `last_error` record is now preserved rather than overwritten. Regression coverage now locks the forced parser-factory exception seams and the preserved-deeper-payload case.
- 2026-03-21: Continued the same Phase 5 diagnostics normalization into `Runtime.pm`. `LinkedSpec::Runtime::run_get(...)` now traps raw dies coming back from `Compiler::run_get_pipeline(...)`, records a fallback structured `runtime_owner` payload at `run_get_pipeline` when no deeper owner payload exists yet, and preserves any richer deeper `last_error` payload already written by the compiler/runtime owner before the die. Regression coverage now locks the forced runtime-delegation die path through both `Runtime::run_get(...)` and `LinkedSpec::Get(...)`, plus the preserved-deeper-payload case. Remaining next step on this line: keep shrinking the remaining raw-die seams around compile/runtime owner boundaries so `runtime_ctx->{last_error}` stays the consistent inspection point without changing public return shapes.
- 2026-03-21: Continued that same Phase 5 line back into the compiler owner setup seam. `LinkedSpec::Compiler::run_get_pipeline(...)` now normalizes callback/runtime-owner preparation failures into a structured `compiler_pipeline` payload at `prepare_pipeline`, so invalid bootstrap callback contracts and similar setup failures no longer fall through to the generic `runtime_owner` wrapper when the compiler already has a usable runtime context. Regression coverage now locks the direct compiler-owner setup failure and the public `LinkedSpec::Get(...)` path preserving that deeper compiler-owned context. Remaining next step on this line: keep shrinking the remaining raw-die seams that still happen before a usable runtime context exists, or decide whether those should stay as explicit hard contract errors.
- 2026-03-21: Continued that same Phase 5 line into the parser-factory owner setup seam. `LinkedSpec::ParserFactory::run_get_parser(...)` now normalizes callback/trace/dependency preparation failures into a structured `parser_factory` payload at `prepare_parser_factory`, so invalid parser-factory callback contracts no longer fall through as raw owner setup dies when `runtime_ctx_ref => \$ctx` is in use. Regression coverage now locks the direct parser-factory setup failure and the public `LinkedSpec::get_parser(...)` path preserving that deeper parser-factory-owned context. Remaining next step on this line: look at the few remaining raw-die seams that happen before any structured context hook exists at all, and decide case by case whether they should stay as hard contract errors or gain a new explicit capture path.
- 2026-03-21: Added grouped shared-code action-edge targets for the structured block form. `.spec` rules can now write `-> RuleA | RuleB { ... }` when multiple action-edge targets need the same code block, and bootstrap lowering expands that grouped surface into ordinary duplicated `ACODE` entries so the existing RuleIR/runtime path stays unchanged. Validation now accepts that shared-block grouped form and rejects grouped targets that omit the required `{ ... }` block. The in-tree `specs/ebnf.spec` `semantic_annotation` rule now uses the new grouped syntax instead of duplicating the same action block twice.
- 2026-03-21: Continued the same Phase 5 runtime/diagnostics line into the top-rule contract seam of the returned parser closure. `Compiler.pm` now records a structured `runtime_parser` payload at `resolve_top_rule_handler` when a returned parser coderef does not have a usable selected top rule label or top-rule handler coderef to invoke. Regression coverage now locks both the missing-top-rule-label and missing-top-rule-handler cases, so that seam no longer regresses back into opaque undefined-subroutine failures.
- 2026-03-21: Extended the same Phase 5 runtime-context hook ergonomics too. `Runtime.pm` and `ParserFactory.pm` now accept direct shared hashrefs for `runtime_ctx_ref` in addition to scalar slots, which means caller-owned hashes like `\%ctx` can now carry seed metadata and later receive LinkedSpec’s `top_rule`, `spec_name`, and structured `last_error` fields in place. Regression coverage now locks one inline success case and one file-oriented failure case through that direct-hashref form.
- 2026-03-21: Re-aligned the public `LinkedSpec::Get(...)` façade with its documented flat option-pair behavior. `Get(...)` now normalizes even key/value option lists before delegating to `Runtime::run_get(...)`, and odd trailing option lists again fall back to an empty option hash for backward compatibility, just like `get_parser(...)`. Regression coverage now traps the runtime owner directly to lock both behaviors.
- 2026-03-22: Continued the same Phase 5 `RuntimeContext` extraction into reused parser-source capture hygiene too. Reused shared runtime contexts now clear stale parser-source chunks at the start of each compile while preserving the shared `parser_source_chunks_ref` arrayref itself, so parser-source capture reflects the current compile instead of appending stale chunks from earlier runs. Regression coverage now locks both the helper behavior and an end-to-end reused-context parser-source capture case.
- 2026-03-22: Continued that same Phase 5 `RuntimeContext` extraction into parser-factory-side parser-source hygiene too. Reused shared runtime contexts now also clear stale parser-source chunks and drop stale emit callbacks during `get_parser(...)` preparation, so an early parser-factory failure does not leave old parser-source output looking like it belongs to the current call. Regression coverage now locks both the helper behavior and an end-to-end reused-context resolution-failure case.
- 2026-03-21: Continued the same Phase 1A façade cleanup as a no-behavior-change owner-dispatch refactor. `LinkedSpec.pm` now shares one `_dispatch_owner_call(...)` helper across its public wrappers instead of repeating the same lazy-load and delegation boilerplate for Trace, Runtime, Compiler, EmitContext, ParserFactory, and PluginBridge. The façade stays behaviorally the same, but the remaining wrapper surface is thinner and more uniform to resume from in later sessions.
- 2026-03-21: Continued the same Phase 5 runtime-modernization line inside `SpecEntry.pm`. Generated rule-handler source now compiles at most once per rule and is cached as a coderef for later invocations, instead of string-evaling the full handler source on every call. Invalid generated handler source now records an explicit structured `runtime_handler:rule_handler_compile` failure on first invocation. Regression coverage now locks both the compile-once reuse behavior and the new compile-failure stage.
- 2026-03-21: Continued that same Phase 5 line deeper into the repeat-handler builders. `REP_BCODE`, `REP_AND_BCODE`, and `REP_AND_ACODE` now emit plain nested anonymous subs in generated parser source instead of `sub { eval '...' }` helper wrappers, so those repeat handlers no longer pay that extra inner eval seam at runtime. Regression coverage now locks both the expected repeat variants and the absence of the old eval-wrapped nested helper subs in captured parser source.
- 2026-03-21: Continued that same Phase 5 line into the default `LinkedRE` dispatch seam too. The main generated handler loop now uses a normal block `eval { LinkedRE::or(...) }` wrapper instead of quoted-string `eval q/$minfo = LinkedRE::or(...)/`, while keeping the same failure banner and detail surface. Regression coverage now locks that parser-source change alongside the repeat-helper source cleanup.
- 2026-03-22: Continued that same Phase 5 line one step further at the same default `LinkedRE` dispatch seam. The main generated handler loop now calls `LinkedRE::or(...)` directly with no inner eval wrapper, so failures from that dispatch path are owned only by the existing outer `runtime_handler` trap instead of a second per-iteration eval/banner layer. Regression coverage now locks the direct parser-source shape, the preserved failure detail, and the removal of the stale inner-banner expectation.
- 2026-03-22: Continued the same Phase 5 `RuntimeContext` extraction into owner-default error typing too. `Runtime.pm`, `ParserFactory.pm`, `Compiler.pm`, and `SpecEntry.pm` no longer each hand-apply their own fallback `last_error` type before delegating into the shared builder; `LinkedSpec::RuntimeContext` now owns that defaulting rule as well. Focused regression coverage now locks both default-type application and explicit override behavior in the shared helper.
- 2026-03-22: Continued that same Phase 5 owner-cleanup line in `SpecEntry.pm`. Top-rule publication after rule compilation now routes through a tiny local runtime-context helper instead of a one-off inline direct `LinkedSpec::RuntimeContext::set_runtime_ctx_top_rule(...)` call. Focused regression coverage now locks that `compile_spec_entry(...)` still drives the top-rule write through the shared setter seam.
- 2026-03-22: Continued the Phase 1A façade-thinning line with one more small no-behavior-change cleanup. `LinkedSpec.pm` now shares one `_normalize_flat_option_pairs(...)` helper across `Get(...)` and `get_parser(...)` instead of duplicating the same flat option-pair normalization logic in both wrappers. Existing regression coverage for both public entrypoints remains the lock for that contract.
- 2026-03-22: Continued the same Phase 5 owner-cleanup line in `ParserFactory.pm`. Its small runtime-context wrapper surface now routes through one private owner helper instead of repeating the same lazy-load plus direct `LinkedSpec::RuntimeContext` package-call pattern in each wrapper. Focused regression coverage now locks that the parser-factory prepare helper still delegates into the shared owner with the expected owner metadata and `spec_name`.
- 2026-03-21: Continued that same Phase 5 line into cached handler construction timing. `SpecEntry.pm` now compiles generated handler source eagerly when `_build_runtime_handler(...)` builds the wrapper, instead of waiting until the first rule invocation to string-eval the handler body. The public contract stays the same from the caller side: successful handlers still compile once and reuse the cached coderef, and invalid generated source still records `runtime_handler:rule_handler_compile` only when invoked.
- 2026-03-21: Tightened that eager-handler-compile seam too. Invalid generated handler source now keeps its compile warnings inside the eventual structured `runtime_handler:rule_handler_compile` detail text instead of leaking them to stderr during wrapper construction. Regression coverage now locks the quiet-stderr behavior and the preserved warning/detail text in `last_error`.
- 2026-03-21: Continued the Phase 1A façade-thinning line with a small compile-surface cleanup. `LinkedSpec.pm` no longer enables `use re 'eval'`; that pragma was stale monolith carryover and is not needed by the current owner-dispatch façade. Existing lazy-load/require regression coverage remains the lock for this no-behavior-change shrink.
- 2026-03-21: Tightened the same Phase 5 runtime diagnostics contract at the parser-return boundary. Successful top-level parses now clear stale inner `runtime_handler` payloads from `runtime_ctx->{last_error}` when a later path in the same invocation returns a defined AST, so `last_error` stays a failure-only channel instead of preserving recovered inner-handler noise.
- 2026-03-21: Continued the same Phase 5 diagnostics cleanup with a shared owner helper. `LinkedSpec::RuntimeContext` now owns the structured `runtime_ctx->{last_error}` set/clear behavior, and the Runtime/ParserFactory/Compiler/SpecEntry owners now delegate there instead of each carrying their own duplicated payload-builder logic. The lazy-load regression also now locks that this helper module is still not loaded just by requiring `LinkedSpec`.
- 2026-03-21: Continued that same shared-owner cleanup by moving `runtime_ctx_ref` normalization and seeded-context materialization into `LinkedSpec::RuntimeContext` too. `Runtime.pm` and `ParserFactory.pm` no longer each maintain their own copy of the SCALAR/HASH/shared-hash-slot coercion logic, and the lazy-load regression now also locks the `get_parser(...)` side of that contract.
- 2026-03-21: Continued the same `LinkedSpec::RuntimeContext` extraction into parser-source handling too. Parser-source chunk allocation/configuration/emission now live in the shared helper instead of being split across Runtime/Compiler/SpecEntry, and a focused regression now locks the helper behavior directly.
- 2026-03-21: Continued that same `LinkedSpec::RuntimeContext` extraction into the remaining small state-field writes too. `top_rule` reset/update and resolved `spec_path` assignment now live in the shared helper instead of being hand-coded in Runtime/ParserFactory/SpecEntry, and focused regression now locks those helper behaviors directly.
- 2026-03-22: Continued that same `LinkedSpec::RuntimeContext` extraction into fallback `last_error` preservation too. The shared helper now owns the rule “only write a fallback owner error if no deeper structured payload is already present,” so Runtime and ParserFactory no longer duplicate that check separately. Focused regression locks both the fresh-write and preserve-existing helper paths.
- 2026-03-22: Continued that same `LinkedSpec::RuntimeContext` extraction into read-side state access too. `RuntimeContext` now owns helper readers for `top_rule` and structured `last_error` inspection, and `Compiler.pm` now uses those helpers instead of reading runtime-context internals directly for parser-ready tracing and recovered `runtime_handler` cleanup. Focused regression locks the read-side helper behavior too.
- 2026-03-22: Continued that same `LinkedSpec::RuntimeContext` extraction into read-side parser-source access too. `RuntimeContext` now owns a reader for `parser_source_chunks_ref`, and `Compiler.pm` now uses it during pipeline setup instead of reading that runtime-context slot directly. Focused regression locks the parser-source read helper alongside the existing parser-source capture helpers.
- 2026-03-22: Continued that same `LinkedSpec::RuntimeContext` extraction into `run_get(...)` preparation too. `Runtime.pm` no longer hand-orchestrates stale `top_rule` clearing and parser-source capture setup for each invocation; the shared helper now owns that preparation step, and focused regression locks the helper behavior directly.
- 2026-03-22: Continued that same `LinkedSpec::RuntimeContext` extraction into `get_parser(...)` preparation too. `ParserFactory.pm` no longer hand-orchestrates `runtime_ctx_ref` normalization and `spec_name` seeding for the file-oriented path; the shared helper now owns that preparation step as well, and focused regression locks the helper behavior for both hooked and unhooked paths.
- 2026-03-22: Continued the same Phase 5 owner cleanup with a no-behavior-change `RuntimeContext` lazy-load refactor. Runtime, ParserFactory, Compiler, and SpecEntry now each use one tiny local helper for `LinkedSpec::RuntimeContext` lazy-load checks instead of repeating the same `unless ...->can(...)` guard at every call site. Existing regression/CI coverage is the lock for this cleanup.
- 2026-03-22: Continued the same Phase 5 runtime-context cleanup into `SpecEntry::compile_spec_entry(...)`. Parser-source emission there now uses injected `runtime_ctx` only, and the stale direct `emit_parser_source_line` dependency slot is ignored. Regression coverage now locks both the active runtime-context path and the ignored legacy dep path for future resume.
- 2026-03-22: Continued the same Phase 5 runtime-context cleanup into `Compiler.pm`. Parser-source chunk setup for `run_get_pipeline(...)` now lives in `LinkedSpec::RuntimeContext` instead of being hand-prepared in the compiler owner, and focused regression coverage now locks that helper behavior for future resume.
- 2026-03-22: Continued the same Phase 5 runtime-context cleanup into `Runtime.pm` option handling. `LinkedSpec::RuntimeContext` now owns `run_get(...)` option-level preparation for `runtime_ctx_ref` plus `dump_parser_source`, and focused regression coverage now locks that helper behavior for future resume.
- 2026-03-22: Continued that same Phase 5 owner-cleanup line in `Runtime.pm`. The runtime owner now routes its small `RuntimeContext` wrapper surface through one private owner helper instead of repeating the same lazy-load plus direct package-call pattern across `_build_runtime_context(...)`, `_set_runtime_ctx_last_error(...)`, and `_set_runtime_ctx_last_error_unless_present(...)`. Focused regression coverage now locks that the runtime context builder still forwards the expected owner metadata.
- 2026-03-22: Continued that same Phase 5 owner-cleanup line in `Compiler.pm`. The compiler owner now routes its small `RuntimeContext` wrapper surface through one private owner helper instead of repeating the same lazy-load plus direct package-call pattern across runtime-context preparation, parser-source, and structured-error wrapper helpers. Focused regression coverage now locks that compiler pipeline preparation still forwards the injected runtime context hashref into the shared owner.
- 2026-03-22: Continued that same Phase 5 owner-cleanup line in `SpecEntry.pm`. The spec-entry owner now routes its small `RuntimeContext` wrapper surface through one private owner helper instead of repeating the same lazy-load plus direct package-call pattern across runtime-handler error, parser-source, and top-rule wrapper helpers. Focused regression coverage now locks that the spec-entry top-rule helper still forwards the injected runtime context hashref and discovered top-rule value into the shared owner.
- 2026-03-22: Continued the same Phase 5 runtime-context cleanup into final parser-source delivery. `LinkedSpec::RuntimeContext` now owns the flush/output step that joins captured parser-source chunks and writes them either into `parser_source_ref` or stdout, and `Compiler.pm` no longer hand-codes that final parser-source assembly path. Focused regression coverage now locks both helper output modes for future resume.
- 2026-03-22: Continued that same Phase 5 runtime-context cleanup into reused-context spec identity. Shared runtime contexts reused across file-oriented and inline entrypoints now refresh or clear `spec_name` / `spec_path` / `top_rule` deliberately: inline `run_get(...)` clears stale file identity by default, parser-factory delegated compilation preserves it explicitly, and `get_parser(...)` preparation now clears stale `spec_path` / `top_rule` before starting a new resolution flow. Focused regression coverage now locks both the helper behavior and the end-to-end reused-context failure surfaces.
- 2026-03-22: Continued the same Phase 5 tracing/instrumentation line in `Compiler.pm`. Returned parser coderefs now emit an explicit top-level `LinkedSpec::parser_invoke:<top_rule>` trace scope plus `resolve_top_rule_handler` and `invoke_top_rule:<top_rule>` decisions, so runtime trace logs bridge cleanly from compile-time scopes into nested `rule_handler` scopes. Focused regression coverage now locks the invocation trace shape and keeps stderr empty on the traced success path.
- 2026-03-22: Continued the same Phase 5 diagnostics-improvement line in `SpecEntry.pm`. `runtime_handler:rule_handler_compile` detail now carries a stable synthetic source label (`LinkedSpec::generated_handler:<rule_label>:<handler_variant>`) instead of only anonymous eval text, and regression coverage now locks that generated-handler label in the preserved compile-failure detail for future resume.
- 2026-03-22: Continued that same Phase 5 diagnostics-improvement line one step further. `runtime_handler` failures now also expose the generated-handler label as structured `handler_source_label` data in `runtime_ctx->{last_error}`, so future work and callers do not need to scrape `detail` just to recover the synthetic source identity.
- 2026-03-22: Continued that same Phase 5 diagnostics-improvement line across the top-level parser boundary too. `runtime_parser` failures now also expose the same structured `handler_source_label` when the top-rule handler variant is known, and the generated-handler label builder itself now lives in `RuntimeContext` so `Compiler.pm` and `SpecEntry.pm` share one source-identity contract.
- 2026-03-22: Started Phase 3 with the first public parse-mode slice. LinkedSpec now accepts `parse_mode => 'seek' | 'consume'`, defaults to historical `seek`, records the selected mode at descriptor level (`meta->{parse_mode}`), and emits explicit contiguous `LinkedRE::or(..., 'consume')` calls only when consume semantics are requested. Invalid parse modes are normalized through the existing structured compiler-setup failure path, and regression coverage now locks default seek parity, explicit consume behavior, descriptor metadata, consume parser-source emission, and invalid-mode diagnostics for future resume.
- 2026-03-22: Captured the follow-up Phase 3 semantics clarification in the docs for future resume. `seek` / `consume` is now documented as cursor discipline, `OR` / `AND` remains the rule-composition axis, and representative `OR + seek`, `OR + consume`, `AND + seek`, and `AND + consume` combinations are now part of the contract so later work does not accidentally bind those axes together.
- 2026-03-22: Captured the next Phase 3 semantic boundary for future resume. Current LinkedSpec is not targeting full parser-engine backtracking: the `.spec` model and runtime remain mostly forward-moving, `BACKTRACK()` / `IBACKTRACK()` are documented as local cursor-rewind helpers only, and future work should not quietly turn that into systemic search-tree rollback without a separate explicit design.
- 2026-03-22: Started Phase 4 with the first named checkpoint slice for future resume. The current semantics are now safer than the very first draft: named `@mark(name)` lowers under the current rule label, `capture_from(name)` captures from that rule-local mark up to the left edge of the current match, and mark writes only fire when the regex slot that actually carries the `@mark(name)` paragraph member matches.
- 2026-03-23: Expanded and corrected the named-checkpoint docs right away because adoption depends on it. The rule-mode guide and ActionIR contract guide now spell out the exact current semantics, including rule-local scope, later-slot timing, same-name reuse across different rules, and the fact that child rules do not inherit a parent rule's named marks.
- 2026-03-23: Captured a documentation-style correction for future resume too: user-guide examples should prefer backend-neutral helper syntax such as `return(payload)`, `assign(...)`, and `call(rule)` where possible, while Perl lowering belongs in the emitted-reference guides.
- 2026-03-23: Added the next Phase 4 capture helper for future resume. `capture_from(name)` remains the stable rule-local named-read helper, while new `capture_take(name)` returns that same span and then advances the same rule-local mark to the current parser position so repeated separator-style capture can work like an explicit named split cursor.
- 2026-03-23: Added the next complementary Phase 4 helper for future resume too. `mark_here(name)` now updates or initializes the same rule-local named mark at the current parser position without first reading a span from it, so the current capture API now has a cleaner three-part split: stable read, read+advance, explicit write.
- 2026-03-23: Added the next complementary Phase 4 helper for future resume again. `clear_mark(name)` now deletes that same rule-local named mark explicitly, so the current capture API now has a cleaner four-part split: stable read, read+advance, explicit write, explicit clear.
- 2026-03-23: Added the next complementary Phase 4 helper for future resume again. `mark_exists(name)` now reports whether that same rule-local named mark is currently present, so the current capture API now has a cleaner five-part split: stable read, read+advance, explicit write, explicit clear, explicit presence check.
- 2026-03-23: Locked the next practical usage contract for future resume too. `mark_exists(name)` is now explicitly supported inside backend-neutral `if(...)` flow conditions, not just in assignment/return payload positions.
- 2026-03-23: Added the next complementary Phase 4 helper for future resume again. `capture_between(start_mark, end_mark)` now reads the span between two explicit rule-local named checkpoints, so the current capture API now has a cleaner six-part split: stable read, read+advance, explicit two-mark span read, explicit write, explicit clear, explicit presence check.
- 2026-03-23: Added the next complementary Phase 4 helper for future resume again. `mark_match_start(name)` now stores the left edge of the current match, so the current capture API now has a cleaner seven-part split: stable read, read+advance, explicit two-mark span read, explicit post-match write, explicit left-edge write, explicit clear, explicit presence check.
- 2026-03-23: Continued that same Phase 4 line into runtime trace visibility for future resume. High/debug tracing now shows mark-write positions for `@mark(name)`, `mark_here(name)`, `mark_match_start(name)`, and the advancing write inside `capture_take(name)` as a short input excerpt plus a caret under the stored checkpoint position, and regression coverage now locks both the helper/LECODE rewrite hooks and an end-to-end traced parser run.
- 2026-03-23: Added the next complementary Phase 4 helper for future resume again. `capture_take_between(start_mark, end_mark)` now returns the span between two explicit rule-local named checkpoints and then advances the start mark to the stored end mark, so the current capture API now has both a stable explicit two-mark read (`capture_between`) and an advancing explicit two-mark read (`capture_take_between`).
- 2026-03-23: Added the next complementary Phase 4 helper for future resume again. `mark_pos(name)` now returns the stored numeric position of a rule-local named checkpoint or `undef` when absent, so the current mark API now has both explicit presence checks (`mark_exists`) and explicit numeric position reads (`mark_pos`) instead of forcing that distinction through raw host-language access.
- 2026-03-23: Added the next complementary Phase 4 helper for future resume again. `capture_len_from(name)` now returns the numeric width of the same current-edge span that `capture_from(name)` would read, so the current mark API now distinguishes cleanly between substring reads, current-edge length reads, position reads, and advancing reads without forcing rules to materialize text just to learn its length.
- 2026-03-23: Added the next complementary Phase 4 helper for future resume again. `capture_len_between(start_mark, end_mark)` now returns the numeric width of the same explicit two-mark span that `capture_between(start_mark, end_mark)` would read, so the current mark API now distinguishes cleanly between current-edge width reads and explicit remembered-boundary width reads without forcing rules to materialize text just to learn its length.
- 2026-03-23: Added the next complementary Phase 4 helper for future resume again. `mark_copy(target_mark, source_mark)` now copies one explicit remembered boundary into another named checkpoint and clears the target when the source mark is absent, so future work can move boundaries explicitly after pure numeric reads without having to add more mutating capture helpers immediately.
- 2026-03-23: Added the next complementary Phase 4 helpers for future resume again. `match_start_pos()` and `match_end_pos()` now expose the current local match left and right boundaries directly, so future rules and docs no longer need to blur “stored named checkpoint position” with “current match boundary” or reach for raw Perl just to surface those numbers.
- 2026-03-23: Added the next complementary Phase 4 helper for future resume again. `match_text()` now exposes the current local match text directly, so the current local-match surface is now a clean trio: `match_text()`, `match_start_pos()`, and `match_end_pos()`.
- 2026-03-23: Added the next complementary Phase 4 helper for future resume again. `match_len()` now exposes the current local match width directly, so the current local-match read surface is now a clean four-part family: `match_text()`, `match_len()`, `match_start_pos()`, and `match_end_pos()`.
- 2026-03-23: Added the next complementary Phase 4 helper for future resume again. `entry_text()` now exposes the current immediate match text directly, which makes the user-facing match-read surface more symmetric and gives the guides a clean explicit way to teach the difference between entry/immediate match text and active local match text. The same slice also fixed two exposed runtime gaps: multi-rule parser builds now treat the first parsed rule paragraph as the default top-level entry and honor explicit `top_rule => 'RuleName'` overrides before parser emission/invocation, instead of effectively letting the last compiled rule win, and repeated `Get(...)` calls on the same inline spec scalar ref now reset the regex cursor before validation/bootstrap parse so later builds do not silently see an empty spec.
- 2026-03-23: Added the next complementary Phase 4 helpers for future resume again. `entry_group(index)` and `match_group(index)` now expose immediate-entry and current-local capture-group reads directly, so the next resume can keep pushing the runtime-value surface away from raw `IMATCH_LIST` / `LMATCH_LIST` without having to infer where that normalization line was headed.
- 2026-03-23: Added the next complementary Phase 4 helper for future resume again. `entry_len()` now exposes the current immediate match width directly, so the immediate-match read surface is now a clean four-part family: `entry_text()`, `entry_len()`, `entry_start_pos()`, and `entry_end_pos()`.
- 2026-03-23: Added the next complementary Phase 4 helpers for future resume again. `entry_start_pos()` and `entry_end_pos()` now expose the current immediate match left and right boundaries directly, so the immediate-match surface is now a clean quartet too: `entry_text()`, `entry_len()`, `entry_start_pos()`, and `entry_end_pos()`.
- 2026-03-24: Extended the new compatibility-surface migration telemetry for future resume. It no longer only tracks Perl-shaped pass-through idioms; it now also flags older helper wrappers such as `return_a` / `return_m` / `return_ma`, `return_imatch`, `return_array`, `capture_if`, and raw call-wrapper forms. Readiness still means “no RAW_PERL fallback and no unresolved helpers,” but future resume should now treat a nonzero `compatibility_surface_*` count as including those older helper families too.
- 2026-03-24: Added a new migration-telemetry distinction for future resume. `language_agnostic_action_ir_ready` still only means “no RAW_PERL fallback and no unresolved helpers,” but rule metadata and descriptor migration summary now also expose `compatibility_surface_*` fields so ready-but-still-Perl-shaped compatibility syntax stays visible and prioritized instead of disappearing behind a green readiness flag.
- 2026-03-27: Continued the remaining Backbone Item 3 owner-contract cleanup in `LinkedSpec::ActionIR::ScannerCore`. The scanner core no longer hardcodes the scanner-rule family package list and shared helper rebinding symbols in parallel across `_scanner_dispatchers(...)` and `_with_scanner_rule_deps(...)`; it now centralizes both behind explicit helper tables. Regression coverage now locks that registry-driven scanner-family contract for future resume, on top of the existing lazy-load and scanned-event behavior.
- 2026-03-27: Continued the same Backbone Item 3 scanner cleanup one step further. `LinkedSpec::ActionIR::ScannerCore` now owns a shared `_scanner_dep_specs()` table, and `LinkedSpec::ActionIR::Scanner::default_deps_for_package(...)` now assembles scanner callbacks from that shared contract instead of keeping a separate manual dep-name list. Regression coverage now locks both the shared scanner-family registry seam and the shared scanner dependency-contract seam for future resume.
- 2026-03-28: Continued the Phase 5 runtime-context diagnostics line for future resume. `LinkedSpec::RuntimeContext` preparation now reseeds an explicit requested `top_rule` during both inline `run_get(...)` and file-oriented `get_parser(...)` setup, so earlier compiler/parser-factory failures preserve the caller’s intended parser entrypoint in structured `last_error` payloads. Regression coverage now locks the helper behavior directly plus end-to-end invalid-parse-mode and parser-factory resolution-failure cases.
- 2026-03-30: Continued the Phase 4 `vhdl` helper-adoption line for future resume. `specs/vhdl.spec::process_statement` now uses `flat_array(entry_groups())` instead of `flat_array(IMATCH_LIST)`, and the same `vhdl_helper_returns_prefer_entry_groups` source lock in `t/phase0_regression.t` now covers that seam too. If we resume this migration band later, keep the current rule in mind: convert the immediate-group snapshot surface, but preserve any extra helper-return payload pieces and AST ordering around it exactly.
- 2026-03-30: Continued the same Phase 4 helper-return migration rule in `sdce` for future resume. `specs/sdce.spec::get_pinport` now uses `flat_array(entry_groups())` instead of `flat_array(IMATCH_LIST)`, and the existing `sdce_spec_prefers_short_container_aliases_in_split_band` source lock now covers that seam too. If we keep pushing this band later, keep using the same pattern: replace only the immediate-group snapshot surface and preserve the surrounding helper-return payload exactly.
- 2026-03-31: Continued the same Phase 4 `vhdl` migration band for future resume, but with a reordered-group case instead of a flat whole-list snapshot. `specs/vhdl.spec::concurrent_signal_assignment_statement` now uses explicit reordered `entry_group(1)` / `entry_group(2)` / `entry_group(0)` reads instead of raw `@IMATCH_LIST[-2, -1, 0]`, and the new `vhdl_concurrent_signal_assignment_prefers_entry_group_reorder` source lock in `t/phase0_regression.t` covers that seam. If we keep pushing this line later, preserve intentional capture-group reordering exactly when converting raw `IMATCH_LIST` indexing to explicit helper reads.
- 2026-03-31: Corrected the local commit-workflow state for future resume. `git_message_brief.txt` had to be restored to its intended untracked-temp-file role after accidental tracking, and the resume invariant remains: after a successful commit, status should return to the normal `?? git_message_brief.txt` shape with the file zero-byte and ready for the next slice.
- 2026-03-31: Continued the same Phase 4 `vhdl` migration band for future resume with a small declaration-reader spend. `specs/vhdl.spec::{constant_declaration,variable_declaration,file_declaration,signal_declaration,configuration_specification}` now use `declare(...=entry_group(...))` locals instead of raw `@IMATCH_LIST` destructuring, and the new `vhdl_declaration_readers_prefer_entry_group_locals` source lock in `t/phase0_regression.t` covers that seam. If we keep pushing this line later, preserve the surrounding `split`/`map` AST logic exactly while only swapping the immediate-match read surface.
- 2026-03-31: Continued the same Phase 4 `vhdl` migration band for future resume with a small interface-port spend. `specs/vhdl.spec::interface_signal_declaration` now uses a named helper array seeded from `entry_groups()` and returned through `array_copy(...)` instead of mutating raw `@IMATCH_LIST` when appending the optional `signal_decl_range` child result, and the new `vhdl_interface_port_decl_prefers_helper_array_flow` source lock in `t/phase0_regression.t` covers that seam. If we keep pushing this line later, preserve the current child-append timing and final `?port_decl:` list shape while removing direct mutation of the built-in immediate-group storage.
