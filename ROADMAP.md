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
   - Document the current bridge chain (`LinkedSpec::AUTOLOAD` -> `LinkedSpec::PluginBridge` -> `PPlugin->exec(...)`) and keep corpus coverage for `plugin/*.plg`.
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
- Phase 1A (LinkedSpec.pm modularization): Planned and queued as next execution track.
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
  - Landed follow-up: `LinkedSpec::Compiler::run_get_pipeline(...)` now receives `compile_spec_entry` as an injected dependency during descriptor assembly, so `Compiler.pm` no longer needs to reach back into `LinkedSpec.pm` for `spec_entry` while preserving existing parser-generation behavior.
  - Landed follow-up: `LinkedSpec::RuleIR::EmitContext` now routes rewrite/diagnostic helper plumbing through `LinkedSpec::ActionRewriter` directly, so emit-context assembly no longer needs `LinkedSpec.pm` action-rewriter façade callbacks.
  - Landed follow-up: `LinkedSpec::ActionRewriter` now owns the extracted FlowExpr/ValueExpr/MethodLowering/ArrayPipeline/ControlFlow callback surface it needs for declare/scanner/lowering work, so `LinkedSpec::Deps` no longer resolves those action-rewriter callbacks through `LinkedSpec.pm`.
  - Landed follow-up: `LinkedSpec::ParserFactory` now receives trace/config/compile dependencies from `LinkedSpec::Trace`, `LinkedSpec::Resolver`, and `LinkedSpec::Runtime` directly, so `get_parser(...)` no longer relies on `LinkedSpec.pm` parser-factory façade callbacks for tracing or compilation.
  - Landed follow-up: `LinkedSpec::Runtime` now carries mutable per-run parser state (`top_rule`, parser-source emission) in an injected runtime context hash instead of package-global mutation, while keeping cached bootstrap grammar state shared.
  - Landed follow-up: `LinkedSpec::Compiler::run_get_pipeline(...)` now consumes that injected `runtime_ctx` directly for parser-source emission/chunk capture and `top_rule` propagation, so compiler/runtime descriptor assembly no longer threads those mutable state handles as separate dependencies.
- Plugin and resource-resolution modernization track: Planned.
  - Long-term plugin direction: explicit module/package plugins replace `AUTOLOAD` + `.plg` as the primary runtime contract.
  - Near-term `PathSearch` direction: keep `PathSearch->go(...)` as compatibility surface, but harden/rework internals before any caller-visible removal.
- Backbone Refactor Track: In progress.
  - Item 1 (`$spec_descr` declarative registry): Landed.
    - Landed detail: bootstrap rules now carry explicit `id` + `tags`, root dispatch uses `start_dispatch`, and curly-brace recursion resolves via `CURLY_BRACE` rule ID instead of fixed index.
  - Item 2 (`spec_entry()` staged RuleIR pipeline): Landed.
    - Landed detail: `spec_entry()` now runs explicit RuleIR stages (collect, plan, validate, emit-context normalize) via private helpers before handler-template assembly.
  - Item 3 (`call_spec_handler_subst()` structured action rewriter): In progress.
    - Landed detail: runtime helper rewriting now flows through canonical-IR-first rewrite (`_rewrite_action_code_with_diagnostics(...)` + `_lower_action_code_from_canonical_ir(...)`), while `call_spec_handler_subst()` remains as compatibility/test helper API, with regression lock `action_rewriter_pipeline_helper_substitutions`.
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
    - Landed follow-up: direct `LinkedSpec::ActionRewriter` rewrites now stay on extracted lowering modules for declare/value/pipeline/flow/return contracts instead of routing those callbacks back through `LinkedSpec.pm`; regression lock `action_rewriter_avoids_linkedspec_lowering_facade` traps the old façade helpers and verifies rewrite parity.
    - Landed follow-up: `get_parser(...)` trace/config/compile wiring now bypasses `LinkedSpec.pm` façade callbacks in favor of direct `Trace`/`Resolver`/`Runtime` dependencies; regression lock `get_parser_avoids_linkedspec_parser_factory_facade` traps the old façade helpers and verifies parser creation, execution, and routed tracing still work.
    - Landed follow-up: runtime-owned mutable parser build state now flows through an injected context hash in `LinkedSpec::Runtime`, so `compile_spec_entry(...)` can update `top_rule` and parser-source output without package-global mutation; regression lock `runtime_compile_spec_entry_uses_injected_runtime_context` verifies the injected-state path.
    - Current decision: `_split_action_ir_statements(...)` hardening track is paused; future work should prioritize action-IR/lowering and diagnostics unless concrete splitter regressions appear.
  - Language-neutral `.spec` action DSL objective (reduce/remove then eliminate Perl code-block dependency in `.spec`): Planned.
- Phase 2+: Planned.
