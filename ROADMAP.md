# ROADMAP
LinkedSpec is being positioned as a progressive extraction parser DSL: fast, recursive, regex-anchored, and intentionally different from strict EBNF-centric tooling.

## Scope and Objective
- Make LinkedSpec a serious, stable, respected parser prototyping tool.
- Preserve the current strengths:
  - Recursive/nested construct parsing.
  - Coarse-to-fine staged parsing (multi-pass).
  - Fast AST prototyping through concise rule/action syntax.
- Improve reliability, diagnostics, and maintainability without breaking existing users.

## Current Baseline (Observed)
- Core compiler/runtime: `perl/LinkedSpec.pm`.
- Regex dispatch helper: `perl/LinkedRE.pm`.
- Parser loading path: `LinkedSpec::get_parser(...)` + `PathSearch`.
- Existing production consumers:
  - `LibReader`
  - `PPlugin`
  - `RTLUtils`
  - `TableGrep`
  - Note: downstream-consumer compatibility is deferred and out of current implementation scope unless explicitly resumed later.
- Specs baseline:
  - Most files in `specs/*.spec` compile.
  - Known compile failure: `specs/tclite.spec` (regex for `[` needs correction).

## Strategic Principles
1. Keep staged extraction as a first-class concept.
2. Keep recursion ergonomics simple.
3. Make parser behavior explicit (not accidental).
4. Improve trust with deterministic diagnostics and regression tests.
5. Maintain backward compatibility by default while introducing stricter optional modes.
6. Drive `.spec` toward language-agnostic action semantics (no embedded Perl code-block dependency in final state).

## Work Phases
## Phase 0: Safety Net and Baseline Lock
- Build regression harness for all `specs/*.spec`.
- Add smoke tests for `LibReader`, `TableGrep`, `RTLUtils` parser entry points.
- Freeze baseline AST shapes for representative inputs.
- Exit criteria:
  - Green baseline suite.
  - Known failures documented (including `tclite.spec`).

## Phase 1: Parser-Core Isolation
- Reduce non-essential module coupling during LinkedSpec load/compile.
- Separate parser-core concerns from framework/global configuration concerns.
- Exit criteria:
  - LinkedSpec core can compile/run specs with minimal dependency surface.

## Phase 1A: LinkedSpec.pm Modularization (New Priority)
- Keep `perl/LinkedSpec.pm` as a thin orchestration façade with stable public APIs (`get_parser`, `Get`, compatibility helpers).
- Extract cohesive internal concerns into focused submodules/packages with explicit interfaces and behavior parity.
- Module boundaries (target structure):
  - `perl/LinkedSpec/Trace.pm`
    - Trace config + emission/routing (`configure_trace`, `log_output`, `log_dump`, `trace_enter`, `trace_exit`, `trace_decision`).
  - `perl/LinkedSpec/Validation.pm`
    - Spec and rule/gdata validation (`validate_spec_content`, `validate_dsl_syntax`, `validate_rule_definition`, `validate_gdata_references`).
  - `perl/LinkedSpec/Resolver.pm`
    - Spec path resolution + source loading (`_resolve_local_spec_path`, fallback rules, file-open error surfaces).
  - `perl/LinkedSpec/RuleIR.pm`
    - Rule IR collection/planning/validation/emit-context assembly.
  - `perl/LinkedSpec/ActionRewriter.pm`
    - Helper-contract catalog + canonical action-IR scanning/lowering.
  - `perl/LinkedSpec/Compiler.pm`
    - `Get` compile pipeline orchestration.
  - `perl/LinkedSpec/BootstrapSpec.pm` (later slice)
    - Bootstrap grammar descriptor + bootstrap parse handlers.
- Shared-state policy:
  - Introduce/expand a shared context object (hashref) for cross-cutting state (`top_rule`, trace/runtime config, compile metadata) to reduce package-global coupling during extraction.
- Rollout policy:
  - Incremental, no-behavior-change slices.
  - Keep `t/phase0_regression.t` green after every slice.
  - Start with lowest-risk extractions first: **Trace -> Validation -> Resolver**, then proceed to RuleIR/ActionRewriter/Compiler and finally BootstrapSpec.
- Exit criteria:
  - `LinkedSpec.pm` delegates most internal work to extracted modules.
  - Existing behavior and regression baseline preserved.
  - Public API compatibility maintained.

## Phase 2: DSL Frontend Hardening
- Replace permissive/spec-skipping behavior with explicit token handling.
- Provide high-quality errors with line/column context.
- Keep a compatibility mode for legacy permissive behavior where needed.
- Exit criteria:
  - Deterministic DSL validation.
  - No silent token-loss in strict mode.

## Phase 3: Execution Semantics Clarification
- Introduce explicit parse modes:
  - `seek` mode (progressive extraction; can skip to anchors).
  - `consume` mode (contiguous matching discipline).
- Keep default behavior backward compatible.
- Exit criteria:
  - Clear documented behavior contract for each mode.

## Phase 4: Capture/Mark API Formalization
- Make position/capture concepts first-class and transparent:
  - Named marks/checkpoints.
  - Capture helpers based on marks and current match boundaries.
- Preserve `$CAPTURE` compatibility.
- Exit criteria:
  - Cleaner author experience for staged extraction patterns.

## Phase 5: Runtime and Diagnostics Modernization
- Reduce runtime string `eval` frequency in hot parse paths.
- Improve debug tracing and rule-level instrumentation.
- Introduce consistent error objects/messages instead of abrupt process exits.
- Exit criteria:
  - Better performance predictability and debuggability.

## Phase 6: Documentation and Adoption
- Expand `USER_GUIDE.md` with practical patterns and anti-patterns, and maintain module-focused lowering references when the user-facing surface becomes too large for one file.
- Maintain architecture rationale in `DEVELOPMENT_NOTES.md`.
- Keep live state in `MEMORY.md`.
- Exit criteria:
  - Documentation remains current at each commit.

## Phase 7: Self-Hosted `.spec` Grammar via `spec.spec`
- Define and maintain a first-class `spec.spec` that captures the currently supported LinkedSpec `.spec` syntax and semantics.
- Make `spec.spec` the preferred extension surface for future `.spec` format evolution so most syntax/semantic improvements can be implemented without modifying LinkedSpec core files.
- Keep LinkedSpec core changes as the fallback path only when a required capability cannot be expressed through `spec.spec`-driven evolution.
- Exit criteria:
  - `spec.spec` can represent the current supported `.spec` language envelope with regression coverage.
  - roadmap-level `.spec` feature changes are expected to land through `spec.spec` first.
  - touching LinkedSpec core for `.spec` language evolution is treated as exception-only and explicitly justified.

## Backbone Refactor Track (Explicit, Tracked)
This track captures the core refactor items needed to make `LinkedSpec.pm` robust and extensible while preserving current behavior.

1. Replace positional hardcoded bootstrap grammar (`$spec_descr` array indexing) with a declarative bootstrap rule registry.
   - Use stable rule IDs/names and explicit tags instead of index-coupled dispatch.
   - Derive special sets (e.g. start patterns, brace scanners) by semantic tags, not fixed numeric offsets.
   - Status: Landed.
2. Split `spec_entry()` into a staged compiler pipeline around an intermediate rule representation (RuleIR).
   - Separate collection, validation, metadata planning, and handler emission.
   - Keep `spec_entry()` as orchestration glue only.
   - Status: Landed.
3. Replace `call_spec_handler_subst()` regex-chain rewriting with a structured action rewriter.
   - Parse supported action helpers into a small action AST/IR and emit backend code from IR.
   - Improve diagnostics for unsupported/ambiguous forms.
   - Move progressively away from raw Perl code blocks in `.spec`, with final objective of eliminating Perl code-block usage in `.spec`.
   - Status: In progress (v1 pipeline + diagnostics + lowering-contract catalog + canonical action-IR promotion + canonical-IR-driven lowering landed; full action AST/IR lowering still planned).

## Practical Migration Path (Tracked Sequence)
1. Refactor-only extraction:
   - Isolate bootstrap handlers and `spec_entry()` stages into private helpers/modules with behavior parity.
2. Deterministic codegen routing:
   - Route handler template selection entirely through explicit metadata/strategy plans.
3. Action rewriter v1:
   - Introduce IR-based rewrite for current helper surface while keeping compatibility fallback.
4. Language-neutral action DSL transition:
   - Define and adopt a backend-agnostic action DSL in `.spec` (no raw Perl dependency by default, and ultimately no Perl code-block usage in `.spec`).
5. Multi-backend enablement:
   - Keep regex/execution semantics documented and map action IR to Perl first, then additional backends (e.g. Rust, Julia) incrementally.

## Method-Like DSL Migration Track (Planned, Under Item #3)
Goal: converge `.spec` semantics on method-like operations and phase out embedded `{...}` code blocks without breaking existing specs abruptly.

1. Canonical method IR vocabulary (Planned)
   - Define backend-neutral method ops for declaration/assignment/call/push/return/scalar-array-object construction/regex-substitution/capture-backtrack surfaces.
   - Keep method semantics explicit and language-agnostic so every op can be implemented consistently across backends.
   - Canonical declaration method form is `declare(type, ...)` where `type ∈ {array, scalar, hash}`.
   - Optional short aliases (`declare_a`, `declare_s`, `declare_h`) remain syntax sugar only and must map to the same typed IR declaration node as `declare(array|scalar|hash, ...)`.
2. Chained method syntax support (Planned)
   - Action edges: `-> rule .method1(...).method2(...).methodN(...)`.
   - Lifecycle sections: `I/E/EX/IT/LX/LS/LE .methodA(...).methodB(...).methodK(...)`.
   - Parse method chains into canonical action IR (not raw host-language text).
3. Unified lowering path (Planned)
   - Lower both legacy helpers (`return_a`, `return_m`, etc.) and new method-chain forms into the same canonical IR/lowering pipeline.
   - Keep compatibility helper APIs during migration so existing specs stay functional.
   - Method-chain parsing and lowering stay IR-first: each method maps to a typed IR node (not opaque string rewrite).
4. Code-block deprecation policy (Planned)
   - Phase A: `{...}` allowed, but emit migration diagnostics encouraging method-like equivalents.
   - Phase B: strict mode rejects new/remaining `{...}` usage.
   - Phase C: strict mode becomes default after migration readiness is acceptable.
5. Tracking policy (Planned)
   - Track progress through existing migration readiness/blocker metadata and regression locks.
   - Prioritize real blocker reduction over telemetry expansion unless explicitly requested.
## Plugin and Resource-Resolution Modernization Track (Planned)
Goal: replace the current `AUTOLOAD` + `.plg` plugin runtime with a more explicit module-based plugin architecture, while making path/resource lookup deterministic and easier to reason about.

1. Freeze the current compatibility surface
   - Document the current bridge chain (`LinkedSpec::AUTOLOAD` -> `LinkedSpec::PluginBridge::_dispatch_autoload(...)` -> `LinkedSpec::PluginBridge::_dispatch_plugin_name(...)` -> `PPlugin->exec_plugin_name(...)`) and keep corpus coverage for `plugin/*.plg`.
   - Treat current `.plg` behavior as legacy compatibility that must be preserved during migration, not as the desired end-state architecture.
2. Introduce an explicit plugin API
   - New plugin entrypoints should live in normal Perl packages with explicit names and registration/loading semantics.
   - `LinkedSpec::PluginBridge` should remain only as a compatibility shim while legacy callers are migrated.
3. Replace implicit discovery/loading
   - Move away from method-name extraction plus cwd/project-root `.plg` globbing as the primary runtime plugin contract.
   - Prefer explicit module discovery/loading and a deterministic registry interface; keep a `.plg` adapter only until parity is reached.
4. `PathSearch` keep-and-harden strategy
   - Do not remove `PathSearch` outright yet: it is still used by parser resolution, config loading, GUI resource lookup, FSM loading, and plugin helpers.
   - Short term: preserve the `PathSearch->go(...)` caller surface but rework the implementation to use deterministic ordered roots, explicit search policy, lazy walking, and better diagnostics.
   - Medium term: back the implementation with standard path/search primitives while preserving compatibility for existing callers.
5. Deprecation gate
   - Only deprecate `AUTOLOAD` / `.plg` execution after explicit module-based plugins reach practical parity and migration tooling exists.
   - Keep this track orthogonal to Backbone item #3: clearing `pplugin.spec` is parser-grammar work, not a commitment to preserve the current plugin runtime forever.

## Immediate Next Steps
- Keep local and GitHub CI aligned through the shared entrypoint `tools/run_ci_local.sh`, with `.github/workflows/ci.yml` delegating to that same repo-root gate.
- Use the new emitted-Perl lowering reference as the review baseline for Backbone item #3 and let user review feedback drive any compatibility-surface cleanup or syntax/semantic amendments.
- Start Phase 1A modularization in no-behavior-change slices with Trace/Validation/Resolver extraction first, while keeping the façade API in `LinkedSpec.pm`.
- Keep Phase-0 baseline continuously green while Phase-1 proceeds.
- Extend Phase-1 isolation to remaining non-essential framework couplings (without changing parser semantics).
- Continue core-structure cleanup with metadata-driven execution routing in `LinkedSpec.pm`, keeping behavior backward compatible.
- Plugin/runtime modernization is now an explicit roadmap track: future work should replace the current `AUTOLOAD` + `.plg` runtime with an explicit module-based plugin model, while keeping parser-grammar cleanup orthogonal to that runtime work.
- With `tkgui.spec` now cleared, the current non-deferred migration scan reports zero blocked specs; shift the next Backbone #3 work away from deterministic per-spec blocker cleanup and back toward broader lowering/DSL follow-up unless a deferred spec is explicitly resumed.
- Continue Backbone Refactor Track action rewriter follow-up by reducing `RAW_PERL` fallback usage through broader structured action-IR coverage, but do this via action-IR/lowering improvements rather than additional `_split_action_ir_statements(...)` delimiter hardening for now.
- With `Lispish::parenthesis` now cleared, the tracked `Lispish`, `vhdl`, `ds_vhistory`, and `ebnf` descriptor summaries no longer report a remaining top blocked rule; shift the next Backbone item #3 work away from per-rule blocker removal in those families and back toward broader ActionIR-first lowering improvements and compatibility-surface cleanup.
- Start Method-Like DSL Migration Track implementation in small slices:
  - introduce canonical method ops incrementally and validate each slice with focused regressions,
  - keep helper-compatibility lowering active while method-chain coverage grows,
  - gate `{...}` deprecation behind explicit migration phases (diagnose first, enforce later).
- Pause further `_split_action_ir_statements(...)` hardening work; only revisit splitter surface expansion when a concrete regression or unsupported production pattern is observed.
- Keep balanced-delimiter behavior strict by policy; do not introduce permissive missing-close helper normalization.
- Keep `.spec` action semantics language-agnostic: avoid introducing new Perl code-block dependence and prioritize IR/DSL forms that can map cleanly to non-Perl backends.
- Keep backend emission under strict canonical forms we control so emitted host-language code avoids avoidable parser/splitter fragility.
- Landed DSL naming cleanup: backend-neutral array snapshot helper now prefers `array_copy(array(...))` while preserving `array_values(array(...))` as a compatibility alias, and existing specs can migrate opportunistically rather than through a dedicated sweep.
- Keep `specs/tclite.spec` deferred until explicitly resumed.
- Define explicit `seek` vs `consume` semantics in design notes before Phase-3 code changes.

## Status
- Phase 0: Active and green (Test::More baseline under `t/phase0_regression.t` for all in-scope specs; `tclite.spec` deferred).
- Phase 0 enhancement: corpus-level regression includes real project directories (`plugin/`, `conf/`, `tablescript/`, `ebnf/`).
- Phase 1: In progress.
- Phase 1A (LinkedSpec.pm modularization): In progress and far advanced.
  - Planned first slice: extract tracing/logging APIs to `LinkedSpec/Trace.pm`.
  - Planned second slice: extract spec/rule/gdata validation APIs to `LinkedSpec/Validation.pm`.
  - Planned third slice: extract spec path/file resolution APIs to `LinkedSpec/Resolver.pm`.
  - Planned follow-up slices: RuleIR + ActionRewriter + Compiler + BootstrapSpec extraction.
  - Landed: module-relative spec resolution in `LinkedSpec::get_parser`.
  - Landed: lazy fallback loading for `PathSearch`.
  - Landed: removal of eager `PPlugin` load at module import time; `AUTOLOAD` remains lazy.
  - Landed: regression harness decoupled from direct `Lispish.pm` import.
  - Landed: rule-level execution metadata + deterministic handler variant selection (`spec->{rule}{meta}`).
  - Landed: `LinkedSpec::Get(..., return_descr => 1)` descriptor-introspection mode for tooling.
  - Landed follow-up: `LinkedSpec::Get(...)` now normalizes flat option pairs locally and delegates straight to `LinkedSpec::Runtime::run_get(...)`, so the active public `Get` path no longer depends on the raw-arg compatibility wrapper `LinkedSpec::Runtime::run_get_from_args(...)`.
  - Landed follow-up: the stale runtime wrapper `LinkedSpec::Runtime::run_get_from_args(...)` has been removed, and active runtime entrypoints now flow through normalized hashref options into `LinkedSpec::Runtime::run_get(...)`.
  - Landed follow-up: `LinkedSpec::get_parser(...)` now normalizes flat option pairs locally and passes a hashref into `LinkedSpec::ParserFactory::run_get_parser(...)`, so the active public parser path no longer depends on raw option-list normalization inside `ParserFactory.pm`.
  - Landed follow-up: `LinkedSpec::ParserFactory::run_get_parser(...)` now owns its default trace/resolution/compile dependency map, so `LinkedSpec::get_parser(...)` no longer depends on the façade-only `_parser_factory_deps()` helper.
  - Landed follow-up: `LinkedSpec::ParserFactory` now owns that last default dependency map directly, the stale `LinkedSpec::Deps::parser_factory_deps_for_package(...)` entrypoint has been removed, and `LinkedSpec::Deps` has been deleted.
  - Landed follow-up: `LinkedSpec::ParserFactory::_require_pkg_cb(...)` now lazy-loads callback owner packages on demand, so `LinkedSpec.pm` no longer imports `LinkedSpec::Resolver` just to keep parser-factory default deps callable.
  - Landed follow-up: `LinkedSpec::Resolver` now lazy-loads `Trace` on demand, so require-only consumers of `Resolver.pm` do not import the trace owner until invalid-spec or spec-resolution trace/error paths actually emit output.
  - Landed follow-up: `LinkedSpec.pm` now lazy-loads `Runtime` and `Compiler` through `_require_pkg(...)` inside `Get(...)` and `spec_descr(...)`, so `require LinkedSpec` no longer drags the compile pipeline into memory up front.
  - Landed follow-up: `LinkedSpec.pm::call_spec_handler_subst(...)` now lazy-loads `LinkedSpec::RuleIR::EmitContext` through the extracted compatibility-owner path and keeps `ActionRewriter` out of the façade helper path, while `LinkedSpec::ActionRewriter::call_spec_handler_subst(...)` remains a backward-compatible wrapper around the same owner.
  - Landed follow-up: `LinkedSpec.pm` now lazy-loads `ParserFactory` and `PluginBridge` at the `get_parser(...)` and `AUTOLOAD` boundaries too, so plain `require LinkedSpec` keeps those owner modules unloaded until those façade entrypoints are actually invoked.
  - Landed follow-up: `LinkedSpec.pm` now lazy-loads `Trace` through the public trace wrapper API (`configure_trace`, `trace_enter`, `trace_exit`, `trace_decision`, `log_output`, `log_dump`, `should_dump`), so plain `require LinkedSpec` no longer imports `Trace.pm` until tracing is actually requested while preserving the existing façade trace-state aliases.
  - Landed follow-up: the public façade wrappers `Get(...)`, `spec_descr(...)`, `call_spec_handler_subst(...)`, `get_parser(...)`, and `AUTOLOAD` now preserve caller `$@` across successful owner delegation, so eval-based compatibility callers do not lose prior error state when using the thin façade entrypoints.
  - Landed follow-up: the public trace wrappers `configure_trace(...)`, `trace_enter(...)`, `trace_exit(...)`, `trace_decision(...)`, `log_output(...)`, `log_dump(...)`, and `should_dump(...)` now preserve caller `$@` across successful owner delegation too, so the remaining façade trace API no longer clobbers prior eval error state when trace-owner calls succeed.
  - Landed follow-up: `LinkedSpec::Validation`, `LinkedSpec::Resolver`, `LinkedSpec::RuleIR`, and `LinkedSpec::RuleIR::EmitContext` now preserve caller `$@` across successful extracted-owner delegation too, so thin helper wrappers no longer clobber prior eval error state when trace, emit-context, dump, or action-rewrite owner calls succeed.
  - Landed follow-up: the remaining thin owner delegates in `LinkedSpec::BootstrapSpec`, `LinkedSpec::Runtime`, `LinkedSpec::ActionIR::Scanner`, `LinkedSpec::ActionIR::StatementSplit`, and `LinkedSpec::ActionIR::CanonicalEvents` now preserve caller `$@` across successful owner delegation too, closing the current compatibility-layer `$@` preservation cleanup track for lightweight wrapper entrypoints.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now preserves caller `$@` across successful owner delegation for its dep-builder, helper parsing, lowering, scanner, canonical, diagnostics, rewrite-pipeline, and compatibility helper wrappers too, closing the same compatibility contract on the large Backbone Item 3 helper surface.
  - Landed follow-up: `LinkedSpec::SpecEntry` now preserves caller `$@` across successful trace and dump helper delegation too, so its extracted trace/dump helper wrappers no longer clobber prior eval error state when those owner calls succeed.
  - Landed follow-up: `LinkedSpec::Compiler` now preserves caller `$@` across successful trace, dump, and regex helper delegation too, so its extracted helper wrappers no longer clobber prior eval error state when those owner calls succeed.
  - Landed follow-up: `LinkedSpec::BootstrapSpec::Core` now preserves caller `$@` across successful `LinkedRE` helper delegation too, so its bootstrap regex-helper wrappers no longer clobber prior eval error state when those owner calls succeed.
  - Landed follow-up: `LinkedSpec::Trace::_trace_stringify(...)` now preserves caller `$@` across successful `Data::Dumper` formatting too, so traced reference-stringification no longer clears prior eval error state on successful dump rendering.
  - Landed follow-up: `LinkedSpec::PluginBridge` now preserves caller `$@` across successful legacy runtime load/exec delegation too, so the compatibility plugin-runtime handoff no longer clobbers prior eval error state when `PPlugin` load or explicit-name exec succeeds.
  - Landed follow-up: `LinkedSpec::ParserFactory` now preserves caller `$@` across successful lazy owner lookup and public parser-factory orchestration too, so eval-based callers do not lose prior error state when package callbacks/values resolve or `run_get_parser(...)` completes successfully.
  - Landed follow-up: the remaining extracted ActionIR dep-builder owners (`Diagnostics`, `Contracts`, `DeclareMethod`, `ControlFlow`, `ArrayPipeline`, `RewritePipeline`, `FlowExpr`, `MethodLowering`, `ValueExpr`, `Scanner`, `StatementSplit`, and `CanonicalEvents`) now preserve caller `$@` across successful callback-map lookup/build paths too, so default ActionIR dep resolution no longer clears prior eval error state when those owner callback maps are assembled.
  - Landed follow-up: `LinkedSpec.pm` no longer imports `Data::Dumper` at module load time, so plain `require LinkedSpec` keeps that dump helper out of memory unless an extracted owner module actually needs it.
  - Landed follow-up: `LinkedSpec.pm` no longer imports `LinkedRE` at module load time, so plain `require LinkedSpec` keeps that regex helper out of memory until the compile path actually needs it.
  - Landed follow-up: `LinkedSpec::Compiler` now lazy-loads `LinkedRE` only when `spec_gdata(...)` actually builds combined regex dependencies, so require-only consumers of `Compiler.pm` do not import the regex helper up front.
  - Landed follow-up: `LinkedSpec::BootstrapSpec::Core` now lazy-loads `LinkedRE` only when bootstrap registry construction or bootstrap scanner handlers actually need it, so require-only consumers of `BootstrapSpec::Core.pm` do not import the regex helper up front.
  - Landed follow-up: `LinkedSpec::Trace` now lazy-loads `Data::Dumper` only when referenced values actually need structured dump formatting, so require-only consumers of `Trace.pm` do not import the dump helper up front.
  - Landed follow-up: `LinkedSpec::RuleIR` now lazy-loads `Data::Dumper` only when debug execution-meta dumps actually need it, so require-only consumers of `RuleIR.pm` do not import the dump helper up front.
  - Landed follow-up: `LinkedSpec::SpecEntry` now lazy-loads `Data::Dumper` only when high-verbosity rule-entry debug dumps actually need it, so require-only consumers of `SpecEntry.pm` do not import the dump helper up front.
  - Landed follow-up: `LinkedSpec::Compiler` now lazy-loads `Data::Dumper` only when traced compiler dumps actually need structured formatting, so require-only consumers of `Compiler.pm` do not import the dump helper up front.
  - Landed follow-up: `LinkedSpec::Runtime` now lazy-loads `LinkedSpec::Compiler` inside `run_get(...)`, so require-only consumers of `Runtime.pm` do not pull the compiler pipeline into memory until actual compilation starts.
  - Landed follow-up: `LinkedSpec::Compiler` now lazy-loads `BootstrapSpec`, `SpecEntry`, and `Validation` through owner helpers, so require-only consumers of `Compiler.pm` do not import those compile-stage owner modules until `spec_descr(...)` or `run_get_pipeline(...)` actually needs them.
  - Landed follow-up: `LinkedSpec::Compiler` now lazy-loads `Trace` through owner helpers, so require-only consumers of `Compiler.pm` do not import the trace owner until `spec_descr(...)`, `spec_gdata(...)`, or `run_get_pipeline(...)` actually starts traced compiler work.
  - Landed follow-up: `LinkedSpec::Validation` now lazy-loads `Trace` on demand, so require-only consumers of `Validation.pm` do not import the trace owner until an actual validation error or warning path emits trace output.
  - Landed follow-up: `LinkedSpec::SpecEntry` now lazy-loads `RuleIR` inside `compile_spec_entry(...)`, so require-only consumers of `SpecEntry.pm` do not import the staged rule-IR pipeline until actual rule compilation starts.
  - Landed follow-up: `LinkedSpec::SpecEntry` now lazy-loads `Trace` through owner helpers, so require-only consumers of `SpecEntry.pm` do not import the trace owner until `compile_spec_entry(...)` actually starts traced rule compilation.
  - Landed follow-up: `LinkedSpec::RuleIR::EmitContext` now lazy-loads `ActionIR::RewritePipeline` and `ActionIR::Diagnostics` through an owner-local rewrite dep bundle, so require-only consumers of `EmitContext.pm` do not import `ActionRewriter.pm`, and normal emit-context builds keep that compatibility owner unloaded.
  - Landed follow-up: `LinkedSpec::RuleIR::EmitContext` now resolves its `Diagnostics` callback bundle through `LinkedSpec::ActionIR::Diagnostics::default_deps_for_package(__PACKAGE__)` instead of hand-building that map locally, so the extracted diagnostics owner now defines the active callback contract for both unresolved-helper scans and helper-event collection.
  - Landed follow-up: `LinkedSpec::RuleIR::EmitContext` now resolves its `CanonicalEvents` callback bundle through `LinkedSpec::ActionIR::CanonicalEvents::default_deps_for_package(__PACKAGE__)` instead of hand-building that map locally, so the extracted canonical-events owner now defines the active callback contract for helper-event canonicalization too.
  - Landed follow-up: `LinkedSpec::RuleIR::EmitContext` now resolves its `StatementSplit` callback bundle through `LinkedSpec::ActionIR::StatementSplit::default_deps_for_package(__PACKAGE__)` instead of hand-building that map locally, so the extracted statement-split owner now defines the active callback contract for emit-context statement splitting too.
  - Landed follow-up: `LinkedSpec::RuleIR::EmitContext` now resolves its `FlowExpr` callback bundle through `LinkedSpec::ActionIR::FlowExpr::default_deps_for_package(__PACKAGE__)` instead of hand-building that map locally, so the extracted flow-expression owner now defines the active callback contract for emit-context flow lowering too.
  - Landed follow-up: `LinkedSpec::RuleIR::EmitContext` now resolves its `ValueExpr` callback bundle through `LinkedSpec::ActionIR::ValueExpr::default_deps_for_package(__PACKAGE__)` instead of hand-building that map locally, so the extracted value-expression owner now defines the active callback contract for emit-context scalar-access and scalaref lowering too.
  - Landed follow-up: `LinkedSpec::RuleIR::EmitContext` now resolves its `ArrayPipeline` callback bundle through `LinkedSpec::ActionIR::ArrayPipeline::default_deps_for_package(__PACKAGE__)` instead of hand-building that map locally, so the extracted array-pipeline owner now defines the active callback contract for emit-context array-pipeline planning and lowering too.
  - Landed follow-up: `LinkedSpec::RuleIR` now lazy-loads `Trace` through owner helpers, so require-only consumers of `RuleIR.pm` do not import the trace owner until RuleIR diagnostics actually emit output.
  - Landed follow-up: `LinkedSpec::RuleIR` now lazy-loads `RuleIR::EmitContext` through owner helpers, so require-only consumers of `RuleIR.pm` do not import the emit-context assembly stage until rule-IR normalization or emit-context build actually starts.
  - Landed follow-up: `LinkedSpec::RuleIR::EmitContext` now lazy-loads `Trace` through owner helpers, so require-only consumers of `EmitContext.pm` do not import the trace owner until unresolved-helper diagnostics actually emit output.
  - Landed follow-up: `LinkedSpec::BootstrapSpec` now lazy-loads `BootstrapSpec::Core` through an owner helper, so require-only consumers of `BootstrapSpec.pm` do not import the hardcoded bootstrap grammar builder until bootstrap state or bootstrap parsing is actually requested.
  - Landed follow-up: `LinkedSpec::ActionIR::Scanner` now lazy-loads `ScannerCore` through an owner helper, so require-only consumers of `ActionIR::Scanner.pm` do not import the scanner-core rule dispatcher until contract scanning actually starts.
  - Landed follow-up: `LinkedSpec::ActionIR::ScannerCore` now lazy-loads its scanner rule packages (`PrimitiveBasicRules`, `PrimitivePipelineRules`, `FlowRules`, `LegacyRules`) through owner helpers, so require-only consumers of `ActionIR::ScannerCore.pm` do not import the contract scanner rule tables until scanning actually starts.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now lazy-loads `ActionIR::MethodExpr` through an owner helper, so require-only consumers of `ActionRewriter.pm` do not import the method-expression parser until method-expression helpers are actually used.
  - Landed follow-up: `LinkedSpec::ActionIR::DeclareMethod` and `LinkedSpec::ActionIR::Scanner` now lazy-load `ActionIR::MethodExpr` while assembling their default callback maps, so `LinkedSpec::ActionRewriter` no longer preloads `MethodExpr` just to build declare/scanner dep-builder payloads.
  - Landed follow-up: the remaining extracted `ActionIR` dep-builder owners now lazy-load callback-owner packages while assembling their default callback maps too, so `ControlFlow`, `Diagnostics`, `RewritePipeline`, `Contracts`, `ValueExpr`, `ArrayPipeline`, `FlowExpr`, `MethodLowering`, `StatementSplit`, and `CanonicalEvents` no longer assume those callback owners were already loaded by the caller.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now lazy-loads `ActionIR::CanonicalEvents` through an owner helper, so require-only consumers of `ActionRewriter.pm` do not import the canonical-event classifier until canonical-event helpers are actually used.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now lazy-loads `ActionIR::Diagnostics` through an owner helper, so require-only consumers of `ActionRewriter.pm` do not import the diagnostics collector until diagnostics helpers are actually used.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now lazy-loads `ActionIR::Scanner` through an owner helper, so require-only consumers of `ActionRewriter.pm` do not import the contract scanner owner until scanner helpers are actually used.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now lazy-loads `ActionIR::StatementSplit` through an owner helper, so require-only consumers of `ActionRewriter.pm` do not import the statement-splitting owner until split helpers are actually used.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now lazy-loads `ActionIR::Contracts` through an owner helper, so require-only consumers of `ActionRewriter.pm` do not import the lowering-contract owner until contract helpers are actually used.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now lazy-loads `ActionIR::RewritePipeline` through an owner helper, so require-only consumers of `ActionRewriter.pm` do not import the rewrite-pipeline owner until rewrite helpers are actually used.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now lazy-loads `ActionIR::FlowExpr` through an owner helper, so require-only consumers of `ActionRewriter.pm` do not import the flow-expression owner until flow helpers are actually used.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now lazy-loads `ActionIR::ArrayPipeline` through an owner helper, so require-only consumers of `ActionRewriter.pm` do not import the array-pipeline owner until array helpers are actually used.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now lazy-loads `ActionIR::ValueExpr` through an owner helper, so require-only consumers of `ActionRewriter.pm` do not import the value-expression owner until value helpers are actually used.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now lazy-loads `ActionIR::ControlFlow` through an owner helper, so require-only consumers of `ActionRewriter.pm` do not import the control-flow owner until flow-statement helpers are actually used.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now lazy-loads `ActionIR::MethodLowering` through an owner helper, so require-only consumers of `ActionRewriter.pm` do not import the method-lowering owner until method-lowering helpers are actually used.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now lazy-loads `ActionIR::DeclareMethod` through an owner helper, so require-only consumers of `ActionRewriter.pm` do not import the declare-method owner until declare-method helpers are actually used.
  - Landed follow-up: `LinkedSpec::ActionIR::StatementSplit` now lazy-loads `StatementSplit::Core` through an owner helper, so require-only consumers of `ActionIR::StatementSplit.pm` do not import the statement-splitting engine until statement splitting actually starts.
  - Landed follow-up: `LinkedSpec::ActionIR::StatementSplit::Core` now lazy-loads `StatementSplit::Mode` through an owner helper, so require-only consumers of `ActionIR::StatementSplit::Core.pm` do not import the quote/comment mode-state engine until actual statement splitting starts.
  - Landed follow-up: `LinkedSpec::ActionIR::CanonicalEvents` now lazy-loads `CanonicalEvents::Core` through an owner helper, so require-only consumers of `ActionIR::CanonicalEvents.pm` do not import the canonical-event classification engine until canonical-event building actually starts.
  - Landed follow-up: `LinkedSpec::Compiler::spec_descr(...)` now owns the default `compile_spec_entry` callback, so `LinkedSpec::spec_descr(...)` is reduced to a pure façade delegate and no longer injects that default itself.
  - Landed follow-up: `LinkedSpec::Compiler::_build_final_descr(...)` now owns the default `spec_gdata` callback, so `run_get_pipeline(...)` no longer threads that callback explicitly during descriptor assembly.
  - Landed follow-up: the stale façade helper `LinkedSpec::spec_gdata(...)` has been removed, and final descriptor `gdata` compilation now stays on `LinkedSpec::Compiler` only.
  - Landed follow-up: `LinkedSpec::Compiler::run_get_pipeline(...)` now owns the default `bootstrap_parse` and `compile_spec_entry` callbacks, so `LinkedSpec::Runtime::run_get(...)` only injects `runtime_ctx` for mutable per-run state.
  - Landed follow-up: the stale compiler helper `LinkedSpec::Compiler::_run_bootstrap_parse(...)` has been removed, and the active pipeline is now regression-locked to the `BootstrapSpec` owner path only.
  - Landed follow-up: `LinkedSpec::Compiler::run_get_pipeline(...)` now receives `compile_spec_entry` as an injected dependency during descriptor assembly, so `Compiler.pm` no longer needs to reach back into `LinkedSpec.pm` for `spec_entry` while preserving existing parser-generation behavior.
  - Landed follow-up: `LinkedSpec::RuleIR::EmitContext` now assembles its rewrite-pipeline callback bundle from extracted `ActionIR::*` owners directly, so emit-context assembly no longer depends on thin `LinkedSpec::ActionRewriter` wrapper methods or indirect `ActionRewriter` callback-map loading; regression locks `emit_context_require_avoids_action_rewriter_load_until_emit_context_build` and `emit_context_avoids_action_rewriter_owner_bundle` now keep that seam closed.
  - Landed follow-up: `LinkedSpec::RuleIR::EmitContext` now also owns the focused helper-rewrite compatibility entrypoint `rewrite_action_code_for_compat(...)`, so the public façade helper `LinkedSpec::call_spec_handler_subst(...)` no longer needs to lazy-load `ActionRewriter`.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now routes its remaining generic rewrite-orchestration wrappers (`_build_action_lowering_contracts(...)`, `_scan_contract_ir_events(...)`, `_find_unresolved_action_helpers(...)`, `_collect_action_helper_ir_nodes(...)`, `_build_canonical_action_ir_events(...)`, `_rewrite_action_code_with_diagnostics(...)`) through `LinkedSpec::RuleIR::EmitContext`, so generic compatibility rewrites stay centered on the extracted compile-path owner instead of re-owning that orchestration surface inside `ActionRewriter`.
  - Landed follow-up: `LinkedSpec::RuleIR::EmitContext` now also owns the remaining generic split/canonical/rewrite helper entrypoints (`_canonicalize_helper_action_ir_event(...)`, `_split_action_ir_statements(...)`, `_lower_action_code_from_canonical_ir(...)`, `_accumulate_action_rewrite_diagnostics(...)`, `_build_action_rewrite_rules(...)`), and `LinkedSpec::ActionRewriter` now delegates those compatibility wrappers there too, removing another batch of duplicate canonical/split/rewrite dep-builder scaffolding from `ActionRewriter`.
  - Landed follow-up: `LinkedSpec::ActionRewriter` no longer owns the direct MethodExpr compatibility helper wrappers (`_parse_method_function_expr(...)`, `_is_bare_method_scope_token(...)`, `_normalize_method_args_with_optional_scope(...)`, `_split_top_level_csv(...)`); those now delegate to `LinkedSpec::RuleIR::EmitContext`, removing the last direct MethodExpr package loader from `ActionRewriter`.
  - Landed follow-up: `LinkedSpec::ActionRewriter` no longer owns the direct ValueExpr compatibility helper wrappers (`_extract_scalar_symbol_name(...)`, `_extract_array_symbol_name(...)`, `_extract_hash_symbol_name(...)`, `_lower_scalar_access_key_expr(...)`, `_lower_scalaref_value_expr(...)`, `_infer_scalar_container_kind(...)`, `_lower_assignment_source_expr(...)`, `_strip_literal_delimiters(...)`); those now delegate to `LinkedSpec::RuleIR::EmitContext`, removing the last direct ValueExpr package loader and local ValueExpr dep-map builder from `ActionRewriter`.
  - Landed follow-up: `LinkedSpec::ActionRewriter` no longer owns the direct FlowExpr compatibility wrapper `_lower_flow_composite_expr(...)`; that now delegates to `LinkedSpec::RuleIR::EmitContext`, removing the last direct FlowExpr package loader and local FlowExpr dep-map builder from `ActionRewriter`.
  - Landed follow-up: `LinkedSpec::ActionRewriter` no longer owns the direct ArrayPipeline compatibility wrappers `_build_array_pipeline_plan_from_expr(...)` and `_lower_array_pipeline_expr(...)`; those now delegate to `LinkedSpec::RuleIR::EmitContext`, removing the last direct ArrayPipeline package loader and local ArrayPipeline dep-map builder from `ActionRewriter`.
  - Landed follow-up: `LinkedSpec::ActionRewriter` no longer owns the direct MethodLowering compatibility wrappers `_declare_alias_to_type(...)`, `_lower_typed_declare_statement(...)`, `_normalize_method_tag_expr(...)`, `_lower_method_value_expr(...)`, and `_lower_assign_statement(...)`; those now delegate to `LinkedSpec::RuleIR::EmitContext`, further shrinking the compatibility surface while leaving the broader MethodLowering statement wrappers in place for now.
  - Landed follow-up: `LinkedSpec::ActionRewriter` no longer owns the remaining broad MethodLowering compatibility wrappers `_lower_return_general_statement(...)`, `_lower_return_imatch_statement(...)`, `_lower_push_value_statement(...)`, `_lower_regex_subst_statement(...)`, `_lower_return_undef_statement(...)`, and `_lower_return_array_statement(...)`; those now delegate to `LinkedSpec::RuleIR::EmitContext`, which removes the final direct `MethodLowering` package loader and local MethodLowering dep-map builder from `ActionRewriter`.
  - Landed follow-up: `LinkedSpec::ActionRewriter` no longer owns the remaining direct DeclareMethod compatibility wrappers `_split_declare_symbol_names(...)`, `_parse_declare_binding_entry(...)`, `_lower_declare_value_expr(...)`, `_lower_declare_initializer_expr(...)`, `_extract_declare_statement_from_method_expr(...)`, `_lower_declare_method_statement(...)`, and `_lower_assign_method_statement(...)`; those now delegate to `LinkedSpec::RuleIR::EmitContext`, which removes the final direct `DeclareMethod` package loader and local DeclareMethod dep-map builder from `ActionRewriter`.
  - Landed follow-up: `LinkedSpec::ActionRewriter` no longer owns the remaining direct ControlFlow compatibility wrappers `_lower_if_flow_statement(...)`, `_lower_elseif_flow_statement(...)`, `_lower_else_flow_statement(...)`, `_lower_endif_flow_statement(...)`, `_lower_switch_flow_statement(...)`, `_lower_case_flow_statement(...)`, `_lower_default_flow_statement(...)`, `_lower_endcase_flow_statement(...)`, `_lower_endswitch_flow_statement(...)`, `_lower_say_statement(...)`, and `_lower_print_statement(...)`; those now delegate to `LinkedSpec::RuleIR::EmitContext`, which removes the final direct `ControlFlow` package loader and local ControlFlow dep-map builder from `ActionRewriter`.
  - Landed follow-up: the stale local `LinkedSpec::ActionRewriter::_trim_action_ir_value(...)` helper has been removed, so the compatibility module no longer carries dead pre-EmitContext trim scaffolding and whitespace trimming now stays local to `LinkedSpec::RuleIR::EmitContext` plus the extracted `ActionIR::*` owners.
  - Landed follow-up: `LinkedSpec::RuleIR::EmitContext` now resolves its `ControlFlow` callback bundle through `LinkedSpec::ActionIR::ControlFlow::default_deps_for_package(__PACKAGE__)` instead of hand-building that map locally, so the extracted control-flow owner now defines the active callback contract for both direct owner calls and emit-context lowering.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now owns the extracted FlowExpr/ValueExpr/MethodLowering/ArrayPipeline/ControlFlow callback surface it needs for declare/scanner/lowering work, so `LinkedSpec::Deps` no longer resolves those action-rewriter callbacks through `LinkedSpec.pm`.
  - Landed follow-up: `LinkedSpec::ParserFactory` now receives trace/config/compile dependencies from `LinkedSpec::Trace`, `LinkedSpec::Resolver`, and `LinkedSpec::Runtime` directly, so `get_parser(...)` no longer relies on `LinkedSpec.pm` parser-factory façade callbacks for tracing or compilation.
  - Landed follow-up: `LinkedSpec::ParserFactory` now compiles specs through `LinkedSpec::Runtime::run_get(...)` with an injected option hashref, so active parser-factory compilation no longer depends on the raw-arg compatibility wrapper `LinkedSpec::Runtime::run_get_from_args(...)`.
  - Landed follow-up: the stale façade helper `LinkedSpec::_resolve_local_spec_path(...)` has been removed, and active local/module-relative spec lookup now stays on `LinkedSpec::Resolver` only.
  - Landed follow-up: `LinkedSpec::Runtime` now carries mutable per-run parser state (`top_rule`, parser-source emission) in an injected runtime context hash instead of package-global mutation, while keeping cached bootstrap grammar state shared.
  - Landed follow-up: `LinkedSpec::Compiler::run_get_pipeline(...)` now consumes that injected `runtime_ctx` directly for parser-source emission/chunk capture and `top_rule` propagation, so compiler/runtime descriptor assembly no longer threads those mutable state handles as separate dependencies.
  - Landed follow-up: `LinkedSpec::SpecEntry::compile_spec_entry(...)` now consumes the injected `runtime_ctx` directly for parser-source emission and `top_rule` propagation, so default spec-entry compilation no longer routes through `LinkedSpec::Runtime::compile_spec_entry(...)` except as compatibility glue.
  - Landed follow-up: `LinkedSpec::SpecEntry::compile_spec_entry(...)` now lazy-loads `LinkedSpec::RuleIR::EmitContext` directly and calls `build_rule_ir_emit_context(...)` on the owner module, so the dead `LinkedSpec::RuleIR` emit-context delegate layer has been removed and `EmitContext` remains the sole owner of emit-context assembly.
  - Landed follow-up: the stale runtime wrapper `LinkedSpec::Runtime::compile_spec_entry(...)` has been removed, and active rule-entry compilation now stays on `LinkedSpec::SpecEntry` plus injected `runtime_ctx`.
  - Landed follow-up: the stale façade helper `LinkedSpec::spec_entry(...)` has been removed, and active rule-entry compilation now stays on `LinkedSpec::SpecEntry` only.
  - Landed follow-up: `LinkedSpec::BootstrapSpec` now owns the cached bootstrap grammar state and bootstrap parse callback (`run_bootstrap_parse(...)`), while `LinkedSpec::Compiler::run_get_pipeline(...)` consumes an injected `bootstrap_parse` callback instead of the raw bootstrap descriptor/index/gdata triple.
  - Landed follow-up: the stale internal ActionRewriter façade delegates (`_find_unresolved_action_helpers`, `_scan_contract_ir_events`, `_collect_action_helper_ir_nodes`, `_trim_action_ir_value`, `_canonicalize_helper_action_ir_event`, `_split_action_ir_statements`, `_build_canonical_action_ir_events`, `_lower_action_code_from_canonical_ir`, `_accumulate_action_rewrite_diagnostics`, `_rewrite_action_code_with_diagnostics`, `_build_action_rewrite_rules`) have been removed from `LinkedSpec.pm`, and the active RuleIR/action-rewriter path is regression-locked to the `LinkedSpec::ActionRewriter` owner surface.
  - Landed follow-up: the stale internal `Compiler`/`RuleIR`/action-contract delegates (`_build_action_rewriter_migration_summary`, `_action_contract_deps`, `_build_action_lowering_contracts`, `_select_rule_handler_variant`, `_build_rule_execution_meta`, `_collect_rule_ir`, `_plan_rule_ir_meta`, `_validate_rule_ir_or_exit`, `_normalize_rule_code_chunks`, `_build_rule_ir_emit_context`) have been removed from `LinkedSpec.pm`, and the active descriptor/rule-compilation path is regression-locked to `LinkedSpec::Compiler`, `LinkedSpec::ActionRewriter`, and `LinkedSpec::RuleIR`.
  - Landed follow-up: the stale internal ActionIR lowering/dependency delegates (`_flow_expr_deps`, `_method_lowering_deps`, `_declare_method_deps`, `_array_pipeline_deps`, `_control_flow_deps`, `_value_expr_deps`, and the remaining `_lower_*`/`_parse_*`/`_extract_*` lowering wrappers) have been removed from `LinkedSpec.pm`, along with their now-unused ActionIR/Deps import surface.
  - Landed follow-up: `LinkedSpec::ActionIR::ScannerCore` now owns scanner-rule dependency rebinding and scanner dispatch-chain selection through `_scanner_rule_dep_bindings(...)`, `_with_scanner_rule_deps(...)`, and `_scanner_dispatchers()`, so contract scanning no longer keeps that orchestration inline in `scan_contract_ir_events(...)`.
  - Landed follow-up: `LinkedSpec::ActionIR::Scanner` now owns its default callback map through `default_deps_for_package(...)`, and the stale `LinkedSpec::Deps::action_rewriter_scanner_deps_for_package(...)` entrypoint has been removed from the active path.
  - Landed follow-up: `LinkedSpec::ActionIR::StatementSplit` now owns its default callback map through `default_deps_for_package(...)`, and the stale `LinkedSpec::Deps::action_rewriter_statement_split_deps_for_package(...)` entrypoint has been removed from the active path.
  - Landed follow-up: `LinkedSpec::ActionIR::CanonicalEvents` now owns its default callback map through `default_deps_for_package(...)`, and the stale `LinkedSpec::Deps::action_rewriter_canonical_event_deps_for_package(...)` entrypoint has been removed from the active path.
  - Landed follow-up: `LinkedSpec::ActionIR::Diagnostics` now owns its default callback map through `default_deps_for_package(...)`, and the stale `LinkedSpec::Deps::action_rewriter_diagnostics_deps_for_package(...)` entrypoint has been removed from the active path.
  - Landed follow-up: `LinkedSpec::ActionIR::RewritePipeline` now owns its default callback map through `default_deps_for_package(...)`, and the stale `LinkedSpec::Deps::action_rewriter_rewrite_pipeline_deps_for_package(...)` entrypoint has been removed from the active path.
  - Landed follow-up: `LinkedSpec::ActionIR::DeclareMethod` now owns its ActionRewriter-facing default callback map through `default_deps_for_package(...)`, and the stale `LinkedSpec::Deps::action_rewriter_declare_method_deps_for_package(...)` entrypoint has been removed from the active path.
  - Landed follow-up: `LinkedSpec::ActionIR::Contracts` now owns its ActionRewriter-facing default callback map through `default_deps_for_package(...)`, and the stale `LinkedSpec::Deps::action_rewriter_contract_deps_for_package(...)` entrypoint has been removed from the active path.
  - Landed follow-up: `LinkedSpec::ActionIR::ValueExpr` now owns its default callback map through `default_deps_for_package(...)`, and the stale `LinkedSpec::Deps::value_expr_deps_for_package(...)` entrypoint has been removed from the active path.
  - Landed follow-up: `LinkedSpec::ActionIR::FlowExpr` now owns its default callback map through `default_deps_for_package(...)`, and the stale `LinkedSpec::Deps::flow_expr_deps_for_package(...)` entrypoint has been removed from the active path.
  - Landed follow-up: `LinkedSpec::ActionIR::ArrayPipeline` now owns its default callback map through `default_deps_for_package(...)`, and the stale `LinkedSpec::Deps::array_pipeline_deps_for_package(...)` entrypoint has been removed from the active path.
  - Landed follow-up: `LinkedSpec::ActionIR::ControlFlow` now owns its default callback map through `default_deps_for_package(...)`, and the stale `LinkedSpec::Deps::control_flow_deps_for_package(...)` entrypoint has been removed from the active path.
  - Landed follow-up: `LinkedSpec::ActionIR::MethodLowering` now owns its default callback map through `default_deps_for_package(...)`, and the stale `LinkedSpec::Deps::method_lowering_deps_for_package(...)` entrypoint has been removed from the active path.
  - Landed follow-up: `LinkedSpec::ActionRewriter` no longer imports `LinkedSpec::Deps` at load time, and `LinkedSpec::ParserFactory` has now absorbed the last remaining parser-factory dep builder as well, so `LinkedSpec::Deps` has been removed from the repo entirely.
  - Landed follow-up: the stale internal trace/runtime helpers `_trace_level_name(...)`, `_apply_trace_options(...)`, and `_emit_parser_source_line(...)` have been removed from `LinkedSpec.pm`, and the active trace/parser-source paths are regression-locked to `LinkedSpec::Trace`, `LinkedSpec::ParserFactory`, and `LinkedSpec::SpecEntry`.
  - Landed follow-up: the stale validation facade wrappers `get_dsl_context(...)`, `report_dsl_error(...)`, `validate_spec_content(...)`, `validate_rule_definition(...)`, `validate_gdata_references(...)`, `validate_dsl_syntax(...)`, and `extract_regex_literals_from_rule_rhs(...)` have been removed from `LinkedSpec.pm`, and the active validation/error-reporting paths are regression-locked to `LinkedSpec::Validation`.
- Plugin and resource-resolution modernization track: In progress.
  - Landed follow-up: `LinkedSpec::PluginBridge` now owns explicit plugin-runtime load/exec dependency callbacks through `_dispatch_autoload(...)`, so future module-based plugin runtime work can replace `PPlugin` without changing `LinkedSpec::AUTOLOAD`.
  - Landed follow-up: the stale `LinkedSpec::PluginBridge::dispatch_autoload(...)` wrapper has been removed, and `LinkedSpec::AUTOLOAD` now delegates straight to the owner path `_dispatch_autoload(...)`.
  - Landed follow-up: `LinkedSpec::PluginBridge` now normalizes full Perl autoload names into explicit plugin names before dispatching through its injected exec callback, so future plugin runtimes can consume deterministic plugin identifiers without depending on method-name extraction.
  - Landed follow-up: `LinkedSpec::PluginBridge` now owns a dedicated explicit-name dispatcher (`_dispatch_plugin_name(...)`) plus explicit-name validation (`_require_plugin_name(...)`), so autoload handling is reduced to normalization plus delegation into the explicit-name owner path.
  - Landed follow-up: `LinkedSpec::PluginBridge` now routes its default lazy legacy-runtime load/exec behavior through explicit owner helpers (`_load_legacy_plugin_runtime(...)`, `_exec_legacy_plugin(...)`) instead of inline closures, further localizing the compatibility bridge seam inside `LinkedSpec::*`.
  - Landed follow-up: the legacy `.plg` adapter in `PPlugin` now enumerates plugin search roots explicitly and lists `.plg` files in deterministic cwd-first sorted order instead of relying on brace-glob expansion.
  - Landed follow-up: the legacy `.plg` adapter in `PPlugin` now builds its cached plugin registry through `_build_plugin_registry(...)`, preserving deterministic file-order override behavior while narrowing the registry construction seam for future runtime replacement.
  - Landed follow-up: `PPlugin` now owns explicit normalized-name execution through `exec_plugin_name(...)`, and `LinkedSpec::PluginBridge` default runtime dispatch now uses that owner path directly while `PPlugin::exec(...)` remains as compatibility glue for older mixed-name callers.
  - Landed follow-up: `PPlugin::new(...)` now initializes its cached legacy registry through `_load_legacy_registry()` plus explicit default dependency callbacks (`load_plugin_parser`, `discover_plugin_files`, `build_plugin_registry`), so parser loading and registry setup are no longer hardwired inline in the constructor.
  - Landed follow-up: `PPlugin.pm` no longer eager-loads `LinkedSpec` at module import time; the default parser dependency now lazy-loads `LinkedSpec` only when the compatibility `pplugin` parser callback is actually needed.
  - Landed follow-up: repo-owned callers that already have explicit plugin names (`HUtils`, `RTLUtils`, `TableScript`, and `plugin/string.plg`) now dispatch through `PPlugin::exec_plugin_name(...)` directly, narrowing the remaining mixed-name compatibility surface to autoload-style and external legacy callers.
  - Long-term plugin direction: explicit module/package plugins replace `AUTOLOAD` + `.plg` as the primary runtime contract.
  - Near-term `PathSearch` direction: keep `PathSearch->go(...)` as compatibility surface, but harden/rework internals before any caller-visible removal.
- Backbone Refactor Track: In progress.
  - Item 1 (`$spec_descr` declarative registry): Landed.
    - Landed detail: bootstrap rules now carry explicit `id` + `tags`, root dispatch uses `start_dispatch`, and curly-brace recursion resolves via `CURLY_BRACE` rule ID instead of fixed index.
  - Item 2 (`spec_entry()` staged RuleIR pipeline): Landed.
    - Landed detail: `spec_entry()` now runs explicit RuleIR stages (collect, plan, validate, emit-context normalize) via private helpers before handler-template assembly.
  - Item 3 (`call_spec_handler_subst()` structured action rewriter): In progress.
    - Landed detail: runtime helper rewriting now flows through canonical-IR-first rewrite (`_rewrite_action_code_with_diagnostics(...)` + `_lower_action_code_from_canonical_ir(...)`), while `call_spec_handler_subst()` remains as the compatibility/test helper API through the `RuleIR::EmitContext` owner path, with regression lock `action_rewriter_pipeline_helper_substitutions`.
    - Landed follow-up: unresolved helper diagnostics are now surfaced in `spec->{rule}{meta}{action_rewriter}` (`unresolved_helpers`, hit counts), with regression lock `action_rewriter_reports_unresolved_helpers_in_rule_meta`.
    - Landed follow-up: helper lowering is now centralized in explicit contracts (`_build_action_lowering_contracts`) reused by rewrite+diagnostics plumbing, with exposed `rewrite_contract_ids` metadata and regression lock `action_rewriter_meta_exposes_lowering_contract_ids`.
    - Landed follow-up: helper action-IR node usage is now exposed in `spec->{rule}{meta}{action_rewriter}` (`helper_action_ir_nodes`, hit counts), with regression lock `action_rewriter_meta_exposes_helper_action_ir_nodes`.
    - Landed follow-up: helper action-IR payload events are now exposed in `spec->{rule}{meta}{action_rewriter}` (`helper_action_ir_events`) with parsed argument payloads, with regression lock `action_rewriter_meta_exposes_helper_action_ir_payload_events`.
    - Landed follow-up: helper payload events are now promoted into canonical action-IR events (`canonical_action_ir_events`) with `RAW_PERL` fallback markers for non-helper statements, with regression lock `action_rewriter_meta_exposes_canonical_action_ir_with_raw_fallback`.
    - Landed follow-up: helper lowering now consumes canonical action-IR events first via `_lower_action_code_from_canonical_ir(...)`, with regression lock `action_rewriter_canonical_ir_lowering_preserves_helper_and_raw_behavior`.
    - Landed follow-up: canonical action-IR statement splitting is now nesting-aware (`()`, `{}`, `[]`, quotes), preventing false `RAW_PERL` fallback fragmentation for helper payloads containing nested semicolons, with regression lock `action_rewriter_canonical_action_ir_handles_nested_semicolon_payloads`.
    - Landed follow-up: helper lowering substitutions are now whitespace-tolerant (`call (X)`, `CAPTURE_IF ( )`, etc.), reducing spacing-only unresolved helper cases while preserving unresolved diagnostics for label-mismatch helper forms, with updated regression locks around helper substitution and unresolved-helper metadata.
    - Landed follow-up: canonical action-IR statement splitting now ignores semicolons inside Perl line comments (`# ...`), preventing comment-fragmented fallback shards and stabilizing canonical fallback metadata, with regression lock `action_rewriter_canonical_action_ir_ignores_line_comment_semicolon_fragmentation`.
    - Landed follow-up: canonical action-IR statement splitting now ignores semicolons inside Perl backtick-quoted strings, preventing fallback fragmentation for backtick payload statements, with regression lock `action_rewriter_canonical_action_ir_ignores_backtick_semicolon_fragmentation`.
    - Landed follow-up: canonical action-IR statement splitting now ignores semicolons inside slash-delimited Perl quote-like payloads (e.g. `qr/.../`), preventing fallback fragmentation for slash-quote payload statements, with regression lock `action_rewriter_canonical_action_ir_ignores_slash_quote_semicolon_fragmentation`.
    - Landed follow-up: canonical action-IR statement splitting now ignores semicolons inside angle-delimited Perl quote-like payloads (e.g. `qr<...>`), preventing fallback fragmentation for angle-quote payload statements, with regression lock `action_rewriter_canonical_action_ir_ignores_angle_quote_semicolon_fragmentation`.
    - Landed follow-up: canonical action-IR statement splitting now ignores semicolons inside pipe-delimited Perl quote-like payloads (e.g. `qr|...|`), preventing fallback fragmentation for pipe-quote payload statements, with regression lock `action_rewriter_canonical_action_ir_ignores_pipe_quote_semicolon_fragmentation`.
    - Landed follow-up: action-rewriter metadata now exposes per-rule raw-Perl fallback dependency and language-agnostic readiness (`raw_perl_dependency_count`, `raw_perl_dependency_statements`, `language_agnostic_action_ir_ready`), with regression lock `action_rewriter_meta_exposes_language_agnostic_readiness`.
    - Landed follow-up: action-rewriter metadata now exposes consolidated language-agnostic blocker statements (`unresolved_helper_statements` + RAW_PERL dependency union) with `language_agnostic_action_ir_blocker_statements` and count, with regression lock `action_rewriter_meta_exposes_language_agnostic_blocker_statements`.
    - Landed follow-up: descriptor-level migration summary is now exposed at `return_descr` top-level metadata (`meta.action_rewriter_migration`) with ready/blocked counts, rule lists, and ratio for backlog prioritization, with regression lock `return_descr_exposes_action_rewriter_migration_summary`.
    - Landed follow-up: descriptor-level migration summary now also exposes deterministic blocker-triage prioritization fields (`language_agnostic_blocker_statement_total_count`, `language_agnostic_blocked_rules_by_priority`, `language_agnostic_top_blocked_rule`) so migration can target highest-impact blocked rules first, with extended regression lock `return_descr_exposes_action_rewriter_migration_summary`.
    - Landed follow-up: descriptor-level migration summary now exposes explicit blocker-type breakdown counts/lists (`language_agnostic_blocked_raw_perl_only_rule_count`, `language_agnostic_blocked_unresolved_helper_only_rule_count`, `language_agnostic_blocked_mixed_rule_count`, and per-type rule lists) for deterministic migration triage slices, with regression lock `return_descr_exposes_action_rewriter_migration_blocker_type_breakdown`.
    - Landed follow-up: descriptor-level migration summary now exposes blocker-type ratio fields (`language_agnostic_blocked_raw_perl_only_ratio`, `language_agnostic_blocked_unresolved_helper_only_ratio`, `language_agnostic_blocked_mixed_ratio`) normalized by blocked-rule count for trend tracking, with extended regression lock `return_descr_exposes_action_rewriter_migration_blocker_type_breakdown`.
    - Landed follow-up: canonical lowering now covers common call-wrapper statements (`my $x = call(...)`, `$x = call(...)`, `push @arr, call(...)`) via explicit lowering contracts, reducing RAW_PERL fallback for wrapper-only action code, with regression lock `action_rewriter_canonical_action_ir_lowers_call_wrappers_without_raw_fallback`.
    - Landed follow-up: canonical lowering now covers full-statement indexed push-call wrappers (`push @target, call(...)->[index]`) via explicit `push_call_indexed_builtin` lowering contract, reducing RAW_PERL fallback for indexed call-wrapper push action code, with regression lock `action_rewriter_canonical_action_ir_lowers_push_call_indexed_wrapper_without_raw_fallback`.
    - Landed follow-up: canonical lowering now covers full-statement `return call(...)` wrappers via explicit `return_call` lowering contract, reducing RAW_PERL fallback for return-call wrapper action code, with regression lock `action_rewriter_canonical_action_ir_lowers_return_call_wrapper_without_raw_fallback`.
    - Landed follow-up: method-like bootstrap parsing now supports chained action/non-action method forms (`.m1(...).m2(...)`) including empty-arg segments (`()`), with regression lock `method_like_action_chain_parses_into_multiple_helper_events`.
    - Landed follow-up: canonical lowering now covers typed declaration methods (`declare(array|scalar|hash, ...)`) and declaration aliases (`declare_a/s/h`, `declare_array/scalar/hash`) via explicit `DECLARE` contracts, reducing RAW_PERL fallback for declaration setup code, with regression lock `action_rewriter_lowers_typed_declare_methods_and_aliases`.
    - Landed follow-up: canonical lowering now covers additional method-like `ebnf.spec`-style contracts (`return_imatch`/`return_im`, `assign(..., CAPTURE|IMATCH|LMATCH)`, `substr(...)`/`regex_subst(...)`, and nested `return_array(..., array(scalar(...), scalar(...)))`) with canonical `RETURN`/`ASSIGN`/`REGEX_SUBST` event mapping, with regression lock `action_rewriter_lowers_method_contracts_for_capture_and_structured_return_values`.
    - Landed follow-up: canonical lowering now covers composable array-string routines (`split`, `trim_each`, `filter_nonempty`, `lowercase_each`, `uppercase_each`, `uniq`, `filter_match`) with canonical `SPLIT`/`TRIM_EACH`/`FILTER_NONEMPTY`/`MAP_LOWERCASE`/`MAP_UPPERCASE`/`UNIQ`/`FILTER_MATCH` event mapping, with regression locks `action_rewriter_lowers_composable_array_string_method_contracts` and `action_rewriter_lowers_additional_composable_array_string_routines`.
    - Landed follow-up: nested functional composition is now supported for array routines (e.g. `filter_match(uniq(uppercase_each(array(parts))), /.../)`) while preserving dot-chain compatibility and method-chain injected scope argument handling (`method(Top, ...)`).
    - Landed follow-up: `tools/inspect_spec_codegen.pl` now provides snippet-level generated-Perl inspection to visualize lowering output and canonical action-IR metadata during migration work.
    - Landed follow-up: canonical lowering now supports fluent control-flow method markers (`if`/`i`, `elseif`/`elif`, `else`, `endif`, `switch`, `case`, `default`, optional `endcase`, `endswitch`) plus branch statements (`say`, `print`, `return_undef`) without requiring `{...}` action blocks, with regression locks `action_rewriter_lowers_fluent_if_else_and_branch_statements` and `action_rewriter_lowers_fluent_switch_case_default_with_optional_endcase`.
    - Landed follow-up: scope-injected push-target lowering now handles method-chain emitted `push(Top, pipe_operator, rule)` via `push_scope_target_arg` contract so branch-side push forms avoid RAW_PERL fallback in fluent flows.
    - Landed follow-up: `USER_GUIDE.md` now includes a fluent `pipe_operator` if/else example and regression lock `action_rewriter_showcase_pipe_operator_if_else_method_chain` to keep the showcased branch-chain lowering behavior stable.
    - Landed follow-up: fluent condition/value arguments now use unified Lisp-style recursive lowering for `if`/`elseif`/`switch` surfaces (nested `or`/`and`/`not`, emptiness predicates, comparison helpers, regex predicates), keeping control-flow expression semantics consistent across markers.
    - Landed follow-up: scalar method-value lowering now supports collection entry access via `scalar(container, key_or_index)` (including explicit `scalar(array(...), idx)` / `scalar(hash(...), key)` forms) while preserving `scalar(IMATCH_LIST, n)` behavior.
    - Landed follow-up: inline composite switch branch form is now supported directly in switch arguments (`switch(cond, case(...), default(...))`) with inline branch actions lowered through existing helper contracts, while retaining legacy marker-style `case()/default()/endswitch()` compatibility.
    - Landed follow-up: method-style empty action argument trimming in `METHOD_EMPTY_ACTION_CODE_BLOCK` now removes outer parentheses with whitespace-tolerant boundaries, preserving balanced helper payload lowering for leading-space `.return ((...))` forms, with regression lock `method_empty_action_return_with_leading_space_args_stays_balanced`.
    - Landed follow-up: `LinkedSpec.pm` now has broad subroutine/top-level documentation comments to improve readability and continuity of parser/rewrite architecture understanding across maintainer handoffs.
    - Landed follow-up: backend-neutral array snapshot payloads are now expressible as `array_values(array(...))`, and `assign(...)` now accepts collection targets (`array(...)` / `hash(...)`) in addition to scalar targets; this enabled `simenv::begin_end_blocks` to migrate off Perl-specific `[@...]` / `\@...` payload forms and reach `raw_perl_dependency_count=0`, with regression locks `action_rewriter_lowers_array_snapshot_and_array_assign_method_contracts` and `simenv_begin_end_blocks_method_flow_is_language_agnostic_ready`.
    - Landed follow-up: generalized `return(payload)` now lowers helper-based `hash(...)` constructor payloads, enabling canonical structured returns without raw Perl hash literals inside `return(...)`; this also cleared the remaining `tablegrep` blockers (`and_op`, `or_op`, `re_term`) via regression locks `action_rewriter_lowers_general_return_payloads_with_nested_structures` and `tablegrep_terminal_token_helper_flow_eliminates_raw_fallback`.
    - Landed follow-up: `vhdl::signal_decl_range` is now fully language-agnostic action-IR ready after replacing its final raw array reset with canonical collection-target assignment (`assign(array(capt), array())`); regression lock `vhdl_signal_decl_range_method_flow_reduces_raw_push_capture_fallback` now asserts zero raw fallback and readiness.
    - Landed follow-up: `vhdl::package_declaration` and `vhdl::package_body` now lower through canonical helper flow using `declare`, `assign`, `lowercase_each`, generalized `return(array(...))`, and `array_values(array(...))`, clearing both rules from the blocked set with regression lock `vhdl_package_helper_flow_eliminates_raw_fallback`.
    - Landed follow-up: flat list insertion helpers are now supported via generic `flat(array|hash(...))` / `flatten(array|hash(...))` plus non-redundant aliases `flat_array(name)` / `flat_hash(name)`, enabling backend-neutral list-context insertion inside array/hash constructors and generalized `return(payload)` flows; this cleared `vhdl::subprogram_declaration` and `vhdl::type_declaration` via regression locks `action_rewriter_lowers_flat_list_value_helpers` and `vhdl_declaration_helper_flow_eliminates_raw_fallback`.
    - Landed follow-up: `vhdl::signal_declaration`, `vhdl::configuration_specification`, and `vhdl::vhdl_file` no longer report raw fallback after replacing rest-arity destructuring with fixed-arity destructuring and dropping the leftover `$|=1` side effect; the refreshed `vhdl_small_blocker_helper_flow_eliminates_raw_fallback` regression now tracks the later zero-blocker `vhdl` state after `subprogram_body` migration.
    - Landed follow-up: `ebnf::grammar_file` now lowers through existing helper flow using `declare`, `assign`, `if/endif`, `push_value`, `flat_array`, and generalized `return(array(...))`, clearing the last `ebnf` blocked rule without adding new lowering contracts; regression lock `ebnf_grammar_file_helper_flow_eliminates_raw_fallback` now verifies zero raw fallback, zero blocker statements, readiness, and zero blocked-rule summary state for `ebnf`.
    - Landed follow-up: `Lispish`, `comments`, `curlyb`, `dquotes`, `others`, `sbrackets`, `spaces`, and `squotes` now lower through canonical `say(...)`, `hash(...)`, `declare`, and `assign` helper flow, clearing all small `Lispish` blockers and leaving only `parenthesis`; regression lock `lispish_small_helper_flow_eliminates_raw_fallback` now verifies zero raw fallback, zero unresolved helpers, canonical node coverage, readiness, and the reduced `Lispish` blocked-rule summary.
    - Landed follow-up: `vhdl::process_statement` now lowers through canonical helper flow using `declare`, `assign`, and generalized `return(array(...))`, clearing the rule from the blocked set without adding new lowering contracts; the refreshed `vhdl_process_statement_helper_flow_eliminates_raw_fallback` regression now tracks the later zero-blocker `vhdl` state after `subprogram_body` migration.
    - Landed follow-up: `ds_vhistory::vhistory` now lowers through canonical helper flow using `declare`, `assign`, `scalaref`, `if/else/endif`, `push_value`, `print(...)`, and generalized `return(array(...))`; rebuilding finalized `"?object:"` rows directly removed the earlier `@$cur_object` mutation blocker, and regression lock `ds_vhistory_vhistory_helper_flow_eliminates_raw_fallback` now verifies zero raw fallback, zero unresolved helpers, canonical node coverage, readiness, and zero blocked-rule summary state for `ds_vhistory`.
    - Landed follow-up: added composable array helper `split_each(array(...), /.../)` with canonical `SPLIT_EACH` action-IR mapping, then used it to migrate `vhdl::subprogram_body` off the final raw Perl tokenization block; regression lock `vhdl_subprogram_body_helper_flow_eliminates_raw_fallback` now verifies zero raw fallback, zero blocker statements, canonical node coverage, readiness, and zero blocked-rule summary state for `vhdl`.
    - Landed follow-up: method-value lowering now supports `call(rule)` as a canonical assignment source via `assign(scalar(retv), call(rule))`; this cleared `Lispish::parenthesis`, and the tracked `Lispish`, `vhdl`, `ds_vhistory`, and `ebnf` descriptor summaries now all report zero blocked rules.
    - Landed follow-up: the lowering documentation is now split into a top-level `USER_GUIDE.md` hub plus module-focused ActionIR guides, so the user-facing surface for declarations, value expressions, control flow, array pipelines, and compatibility helpers is documented with denser examples.
    - Landed follow-up: the guide set now includes `USER_GUIDE_ActionIR_EmittedPerlReference.md`, which enumerates the current ActionIR lowering contract by showing emitted Perl for canonical helpers, compatibility helpers, and classified pass-through idioms; use that file as the review baseline for future DSL cleanup.
    - Landed follow-up: raw debug prints in `ifelse.spec` now lower through canonical `print(...)` helper calls instead of RAW_PERL fallback, clearing the full `ifelse` rule family (`program`, `if`, `then`, `elsif`, `else`, `while`, `while_then`) from the blocked set, with regression lock `ifelse_debug_print_helper_flow_eliminates_raw_fallback`.
    - Landed follow-up: raw debug prints in `BNF.spec` now lower through canonical `print(...)` helper calls instead of RAW_PERL fallback, clearing the full BNF rule family (`description`, `construction_start`, `node`, `dquote_str`, `squote_str`, `regex`, `group`, `g_repetition`, `q_mark`, `plus`, `star`, `pipe`) from the blocked set, with regression lock `bnf_debug_print_helper_flow_eliminates_raw_fallback`.
    - Landed follow-up: raw diagnostic/debug prints in the selected `simenv` delimiter-helper family (`bs_nl`, `squotes`, `perl_squotes`, `multiline_value`, `bvariable_substitution`, `curlybrace`, `parenthesis`) now lower through canonical `print(...)` helper calls instead of RAW_PERL fallback, with regression lock `simenv_delimiter_helper_print_flow_eliminates_raw_fallback`.
    - Landed follow-up: the remaining selected `simenv` quote/substitution family (`singleline_value`, `dquotes`, `perl_dquotes`, `command_substitution`, `perl_command_substitution`, `variable_substitution`, `comments`) now lowers through canonical helper flow instead of RAW_PERL fallback, with regression lock `simenv_quote_substitution_helper_flow_eliminates_raw_fallback`.
    - Landed follow-up: the final remaining `simenv` blockers (`top`, `anyvariable`) now lower through canonical helper flow instead of RAW_PERL fallback, with regression lock `simenv_top_and_anyvariable_helper_flow_eliminates_raw_fallback`; `simenv` now reports zero blocked rules in descriptor migration metadata.
    - Landed follow-up: `sdce::sdc_esplit` and `sdce::get_pinport` now lower through canonical helper flow using `declare`, `assign`, `push_value`, `split`, `filter_nonempty`, `flat_array`, and `array_values`; regression lock `sdce_helper_flow_eliminates_raw_fallback` verifies zero raw fallback, zero unresolved-helper hits, and zero blocked-rule summary state for `sdce`.
    - Landed follow-up: `portmap::bare_bit_slice` now lowers through canonical helper control flow instead of raw smartmatch classification; regression locks `portmap_bare_bit_slice_helper_flow_eliminates_raw_fallback` and `portmap_bare_bit_slice_classification_smoke` verify zero raw fallback, zero blocked-rule summary state, and preserved `bare` / `bit` / `slice` / `constant` output classification including `bar[0]`.
    - Landed follow-up: `pplugin::pplugin_top` now lowers through canonical helper flow by rebuilding the flat definition list with collection-target assignment plus `flat_array(...)` / `scalaref(...)` instead of raw `push @defs, @$retv`; regression locks `pplugin_helper_flow_eliminates_raw_fallback` and `pplugin_parser_smoke` verify zero raw fallback, zero blocked-rule summary state, and preserved returned hash/coderef behavior for parsed plugin bodies.
    - Landed follow-up: `tkgui::sub_gui` now lowers through canonical helper flow by replacing its last raw entry-point debug print with helper `print(...)`; regression locks `tkgui_helper_flow_eliminates_raw_fallback` and `tkgui_parser_smoke` verify zero raw fallback, zero blocked-rule summary state, preserved entry-point print output, and preserved current one-entry hash result shape.
    - Landed follow-up: backend-neutral array snapshot lowering now accepts clearer `array_copy(array(...))` anywhere `array_values(array(...))` already worked, while preserving `array_values(...)` as a compatibility alias; regression lock `action_rewriter_lowers_array_snapshot_and_array_assign_method_contracts` now covers both spellings.
    - Landed follow-up: direct `LinkedSpec::ActionRewriter` rewrites now stay on extracted lowering modules for declare/value/pipeline/flow/return contracts instead of routing those callbacks back through `LinkedSpec.pm`; regression lock `action_rewriter_avoids_removed_linkedspec_lowering_facade` traps the removed façade helpers and verifies rewrite parity.
    - Landed follow-up: `get_parser(...)` trace/config/compile wiring now bypasses `LinkedSpec.pm` façade callbacks in favor of direct `Trace`/`Resolver`/`Runtime` dependencies; regression lock `get_parser_avoids_linkedspec_parser_factory_facade` traps the old façade helpers and verifies parser creation, execution, and routed tracing still work.
    - Landed follow-up: runtime-owned mutable parser build state now flows through an injected context hash in `LinkedSpec::Runtime`, so `compile_spec_entry(...)` can update `top_rule` and parser-source output without package-global mutation; regression lock `runtime_compile_spec_entry_uses_injected_runtime_context` verifies the injected-state path.
    - Current decision: `_split_action_ir_statements(...)` hardening track is paused; future work should prioritize action-IR/lowering and diagnostics unless concrete splitter regressions appear.
  - Language-neutral `.spec` action DSL objective (reduce/remove then eliminate Perl code-block dependency in `.spec`): Planned.
- Phase 2+: Planned.
