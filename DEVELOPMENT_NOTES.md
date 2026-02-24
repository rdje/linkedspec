# DEVELOPMENT NOTES
Engineering notes for LinkedSpec refactoring and stabilization.

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

## Open Technical Work
- Build robust regression harness for all existing specs.
- Fix known `tclite.spec` regex issue.
- Define strict vs permissive mode contracts.
- Introduce structured error reporting and tracing.
- Reduce hot-path runtime eval usage.

## Testing Strategy (Current)
- Framework: `Test::More`.
- Baseline test entry point: `t/phase0_regression.t`.
- Scope:
  - Compile/generation checks for all `specs/*.spec` except `tclite.spec` (currently deferred).
  - `get_parser` resolution-path checks:
    - module-relative local resolution from non-project cwd (no `PathSearch` load),
    - explicit file path resolution (no `PathSearch` load),
    - cwd-local `name.spec` resolution (no `PathSearch` load),
    - lazy `PathSearch` fallback when local/module-relative candidate is absent.
  - `get_parser` invalid-spec-name negative-path checks:
    - `undef`, empty-string, whitespace-only, non-scalar, padded, and control-byte-containing names return `undef` without die,
    - control-byte coverage includes NUL, whitespace controls (tab/newline/carriage-return), and additional non-whitespace controls (e.g. BEL/US),
    - non-scalar coverage explicitly includes arrayref/hashref/scalarref/coderef/regexp-ref variants,
    - diagnostics include `Invalid spec name`,
    - `PathSearch.pm` remains unloaded for these calls.
  - `get_parser` fallback-loader negative-path checks:
    - forced fallback with isolated empty `@INC` returns `undef` without die when `PathSearch` cannot be loaded,
    - diagnostics include unresolved-spec and `PathSearch load failed` details,
    - `PathSearch.pm` remains unloaded for this failure path.
  - `get_parser` fallback-runtime negative-path checks:
    - forced fallback with monkey-patched `PathSearch::go` `die` returns `undef` without outer die,
    - diagnostics include unresolved-spec and `PathSearch runtime failure` details.
  - `get_parser` fallback-resolved-missing-path negative-path checks:
    - forced fallback with monkey-patched `PathSearch::go` returning non-existent file path returns `undef` without die,
    - diagnostics include `Spec path not found`, requested spec name, and resolved missing path.
  - `get_parser` fallback single-call invariant check:
    - fallback path invokes `PathSearch::go` exactly once per `get_parser` call,
    - validated by monkey-patched call counter with successful parser creation/invocation.
  - `get_parser` explicit-path-miss negative-path checks:
    - unresolved path-like arguments (containing `/` or `\\`) return `undef` without die and report `Spec path not found`,
    - includes missing backslash-separated explicit paths (windows-style separators),
    - explicit-path misses skip fallback loader paths and keep `PathSearch.pm` unloaded,
    - explicit-path and missing `.spec` basename misses continue to bypass `PathSearch::go` even when `PathSearch.pm` is already loaded (resolver call count remains `0`).
  - `get_parser` directory-path negative-path checks:
    - explicit directory path arguments return `undef` without die and report `Spec path is not a file`,
    - fallback-resolved directory paths (via `PathSearch::go`) return `undef` without die with directory-path diagnostics.
  - `get_parser` non-regular-path negative-path checks:
    - explicit non-regular path arguments (e.g. `File::Spec->devnull`) return `undef` without die and report `Spec path is not a file`,
    - fallback-resolved non-regular paths (via `PathSearch::go`) return `undef` without die with non-regular path diagnostics.
  - `get_parser` explicit-.spec-miss negative-path checks:
    - unresolved `.spec`-suffixed basenames return `undef` without die and report `Spec path not found`,
    - `.spec` misses skip fallback loader paths and keep `PathSearch.pm` unloaded.
  - `get_parser` unresolved-spec negative-path checks:
    - missing spec name returns `undef` without die and reports `Spec path not found`,
    - missing explicit path returns `undef` without die and includes requested path in diagnostics.
  - `get_parser` open-failure negative-path check:
    - unreadable existing spec path returns `undef` without die and reports open/OS error diagnostics.
  - `get_parser` malformed-spec negative-path check:
    - invalid DSL content returns `undef` without die and reports validation/critical error diagnostics.
  - `get_parser` malformed-handler runtime negative-path check:
    - parser coderef builds, but malformed embedded action Perl reports runtime inner eval syntax error and returns undefined AST.
  - `get_parser` mixed ACTION/BLIND CALL explicit-exit check:
    - incompatible `->` and `=>` usage exits with code 1 and emits rule-level remediation diagnostics,
    - validated via subprocess execution to avoid in-process test context interference.
  - parser invalid-input runtime behavior lock:
    - invoking generated parser with controlled non-scalar-ref input (via subprocess sentinel conversion) returns undefined AST without process exit.
  - `Get(..., return_descr => 1)` core-introspection behavior lock:
    - returns descriptor hash (`spec` + `gdata`) instead of parser coderef,
    - includes per-rule `meta` execution data (handler variant, regex/action counts, loop strategy marker).
  - single-vs-multi AND strategy lock:
    - single-regex AND action rule maps to `AND_SINGLE_ACODE` with non-loop strategy marker,
    - multi-regex AND action rule maps to `AND_ACODE` with loop strategy marker.
  - bootstrap rule-registry recursion lock:
    - hardcoded bootstrap grammar now uses ID/tag registry dispatch (no fixed slot index assumptions),
    - nested action-block braces with quoted literals remain stable under registry-driven `CURLY_BRACE` recursion (`bootstrap_registry_curly_brace_recursion_smoke`).
  - RuleIR stage-pipeline mapping lock:
    - staged `spec_entry()` RuleIR flow preserves ACODE gdata mapping order/count for multi-AND rule assembly,
    - covered by `ruleir_pipeline_preserves_acode_gdata_mapping_order`.
  - action-rewriter pipeline helper lock:
    - `call_spec_handler_subst()` remains available as a compatibility/test shim while runtime rule emission uses canonical-IR-first rewrite flow through `_rewrite_action_code_with_diagnostics(...)`,
    - covered by `action_rewriter_pipeline_helper_substitutions` for `call`/`push`/capture/backtrack/return helper surfaces.
  - action-rewriter unresolved-helper diagnostics lock:
    - unresolved helper forms that survive rewrite normalization are tracked in rule metadata under `meta.action_rewriter`,
    - covered by `action_rewriter_reports_unresolved_helpers_in_rule_meta`.
  - action-rewriter contract-catalog metadata lock:
    - rule metadata now exposes ordered helper-lowering contract IDs (`rewrite_contract_ids`) for tooling/introspection stability,
    - covered by `action_rewriter_meta_exposes_lowering_contract_ids`.
  - action-rewriter helper action-IR metadata lock:
    - rule metadata now exposes helper action-IR nodes/hit counts collected before lowering,
    - covered by `action_rewriter_meta_exposes_helper_action_ir_nodes`.
  - action-rewriter helper action-IR payload event lock:
    - rule metadata now exposes parsed helper payload events (`helper_action_ir_events`) with argument extraction,
    - covered by `action_rewriter_meta_exposes_helper_action_ir_payload_events`.
  - action-rewriter canonical action-IR fallback lock:
    - rule metadata now exposes canonical action-IR events and explicit `RAW_PERL` fallback markers for non-helper statements,
    - covered by `action_rewriter_meta_exposes_canonical_action_ir_with_raw_fallback`.
  - action-rewriter language-agnostic readiness lock:
    - rule metadata now exposes raw-host-language dependency and readiness indicators (`raw_perl_dependency_count`, `raw_perl_dependency_statements`, `language_agnostic_action_ir_ready`) to support backend-neutral `.spec` migration tracking,
    - covered by `action_rewriter_meta_exposes_language_agnostic_readiness`.
  - action-rewriter language-agnostic blocker statement lock:
    - rule metadata now exposes unresolved-helper statement payloads and consolidated migration blockers (`unresolved_helper_events`, `unresolved_helper_statements`, `language_agnostic_action_ir_blocker_statements`, `language_agnostic_action_ir_blocker_statement_count`),
    - covered by `action_rewriter_meta_exposes_language_agnostic_blocker_statements`.
  - action-rewriter descriptor migration summary lock:
    - `return_descr` now exposes descriptor-level migration summary metadata (`meta.action_rewriter_migration`) including ready/blocked counts, deterministic rule lists, blocked rule payloads, and readiness ratio,
    - covered by `return_descr_exposes_action_rewriter_migration_summary`.
  - action-rewriter descriptor migration prioritization lock:
    - descriptor-level migration summary now exposes blocker-triage prioritization metadata (`language_agnostic_blocker_statement_total_count`, `language_agnostic_blocked_rules_by_priority`, `language_agnostic_top_blocked_rule`),
    - blocked-rule priority ordering is deterministic: blocker statements (desc), unresolved-helper count (desc), raw-Perl dependency count (desc), then rule name (asc),
    - covered by extended `return_descr_exposes_action_rewriter_migration_summary`.
  - action-rewriter descriptor migration blocker-type breakdown lock:
    - descriptor-level migration summary now exposes blocked-rule type breakdown metadata (`language_agnostic_blocked_raw_perl_only_rule_count`, `language_agnostic_blocked_unresolved_helper_only_rule_count`, `language_agnostic_blocked_mixed_rule_count`, plus deterministic per-type rule lists),
    - descriptor-level migration summary also exposes blocked-rule type ratios (`language_agnostic_blocked_raw_perl_only_ratio`, `language_agnostic_blocked_unresolved_helper_only_ratio`, `language_agnostic_blocked_mixed_ratio`) normalized by blocked-rule count,
    - covered by extended `return_descr_exposes_action_rewriter_migration_blocker_type_breakdown`.
  - action-rewriter canonical-IR lowering lock:
    - helper lowering now consumes canonical action-IR events first while preserving unresolved-helper and RAW_PERL pass-through behavior,
    - covered by `action_rewriter_canonical_ir_lowering_preserves_helper_and_raw_behavior`.
  - action-rewriter call-wrapper lowering lock:
    - canonical lowering now covers common call-wrapper statements (`my $x = call(...)`, `$x = call(...)`, `push @arr, call(...)`) so these forms no longer require RAW_PERL fallback,
    - covered by `action_rewriter_canonical_action_ir_lowers_call_wrappers_without_raw_fallback`.
  - action-rewriter return-call wrapper lowering lock:
    - canonical lowering now covers full-statement `return call(...)` wrappers so this form no longer requires RAW_PERL fallback,
    - covered by `action_rewriter_canonical_action_ir_lowers_return_call_wrapper_without_raw_fallback`.
  - action-rewriter indexed push-call wrapper lowering lock:
    - canonical lowering now covers full-statement `push @target, call(...)->[index]` wrappers so indexed push-call forms no longer require RAW_PERL fallback,
    - covered by `action_rewriter_canonical_action_ir_lowers_push_call_indexed_wrapper_without_raw_fallback`.
  - action-rewriter typed declare-method lowering lock:
    - canonical lowering now covers typed declaration methods (`declare(array|scalar|hash, ...)`) and short/long aliases (`declare_a/s/h`, `declare_array/scalar/hash`) so declaration setup can avoid RAW_PERL fallback,
    - covered by `action_rewriter_lowers_typed_declare_methods_and_aliases`.
  - method-like action chain parsing lock:
    - chained method-like action forms (`-> Rule .m1(...).m2(...)`) now parse into multiple helper events, including empty-arg call segments (`()`),
    - covered by `method_like_action_chain_parses_into_multiple_helper_events`.
  - action-rewriter method-empty arg normalization lock:
    - method-style empty-action argument trimming now removes outer parentheses with whitespace-tolerant boundaries, so leading-space forms keep balanced helper payloads for canonical lowering,
    - covered by `method_empty_action_return_with_leading_space_args_stays_balanced`.
  - action-rewriter canonical action-IR nested-semicolon lock:
    - canonical action-IR statement splitting now ignores semicolons inside nested helper payload expressions (e.g. `do { ...; ... }`) when building statement-level events,
    - covered by `action_rewriter_canonical_action_ir_handles_nested_semicolon_payloads`.
  - action-rewriter whitespace-tolerant helper lowering lock:
    - helper lowering now accepts optional spacing forms (e.g. `call (Leaf)`, `CAPTURE_IF ( )`) across supported helper contracts,
    - unresolved-helper diagnostics lock now targets label-mismatch helper forms to preserve non-lowerable helper diagnostics coverage,
    - covered by updated `action_rewriter_pipeline_helper_substitutions`, `action_rewriter_canonical_ir_lowering_preserves_helper_and_raw_behavior`, and `action_rewriter_reports_unresolved_helpers_in_rule_meta`.
  - action-rewriter canonical action-IR line-comment semicolon lock:
    - canonical statement splitting now ignores semicolons inside Perl line comments (`# ...`) so comment text is not fragmented into multiple fallback statements,
    - covered by `action_rewriter_canonical_action_ir_ignores_line_comment_semicolon_fragmentation`.
  - action-rewriter canonical action-IR backtick-semicolon lock:
    - canonical statement splitting now ignores semicolons inside Perl backtick-quoted strings so backtick payload statements are not fragmented into fallback shards,
    - covered by `action_rewriter_canonical_action_ir_ignores_backtick_semicolon_fragmentation`.
  - action-rewriter canonical action-IR slash-quote semicolon lock:
    - canonical statement splitting now ignores semicolons inside slash-delimited Perl quote-like payloads so slash-quote payload statements are not fragmented into fallback shards,
    - covered by `action_rewriter_canonical_action_ir_ignores_slash_quote_semicolon_fragmentation`.
  - action-rewriter canonical action-IR angle-quote semicolon lock:
    - canonical statement splitting now ignores semicolons inside angle-delimited Perl quote-like payloads so angle-quote payload statements are not fragmented into fallback shards,
    - covered by `action_rewriter_canonical_action_ir_ignores_angle_quote_semicolon_fragmentation`.
  - action-rewriter canonical action-IR pipe-quote semicolon lock:
    - canonical statement splitting now ignores semicolons inside pipe-delimited Perl quote-like payloads so pipe-quote payload statements are not fragmented into fallback shards,
    - covered by `action_rewriter_canonical_action_ir_ignores_pipe_quote_semicolon_fragmentation`.
  - Smoke tests:
    - strict AST shape assertion for `Lispish.spec`.
    - invariant-based AST assertions for `vhdl.spec`.
    - invariant-based AST assertions for `ebnf.spec`.
- Current deferred test target:
  - `tclite.spec` (explicitly deferred by scope decision).
- Corpus regression (directory-level):
  - `plugin/*.plg` parsed via `pplugin.spec`.
  - `conf/*.conf` parsed via LinkedSpec-generated `Lispish.spec` parser stream.
  - `tablescript/*.ts` parsed via LinkedSpec-generated `Lispish.spec` parser stream.
  - `ebnf/*.ebnf` parsed via `ebnf.spec`.
- Baseline corpus counts currently covered:
  - plugin: 52 files
  - conf: 53 files
  - tablescript: 23 files
  - ebnf: 7 files

## Phase 1 Isolation Notes (Current)
- `LinkedSpec` now avoids eager plugin dependency at module load:
  - Removed top-level `use PPlugin;`.
  - `AUTOLOAD` performs lazy `require PPlugin` only when plugin execution is requested.
- `LinkedSpec::get_parser` now prefers module-relative spec resolution:
  - resolves to `../specs/<name>.spec` relative to `perl/LinkedSpec.pm` location,
  - avoids hard dependence on current working directory,
  - keeps `PathSearch` as lazy fallback only.
- `LinkedSpec::get_parser` now validates spec-name input early:
  - `undef`/empty/whitespace-only/non-scalar/padded/control-byte spec-name arguments fail fast with diagnostics and `undef` return,
  - invalid-name calls do not trigger fallback loader paths.
- `LinkedSpec::get_parser` now treats unresolved path-like names as explicit misses:
  - when local/module-relative lookup fails for path-like names, it returns not-found directly,
  - this avoids unnecessary `PathSearch` fallback load attempts for explicit-path errors.
- `LinkedSpec::get_parser` now treats unresolved `.spec` basenames as explicit misses:
  - when local/module-relative lookup fails for `.spec`-suffixed names, it returns not-found directly,
  - this avoids `PathSearch` fallback attempts that would otherwise probe `<name>.spec.spec`.
- `LinkedSpec::get_parser` now traps `PathSearch->go` runtime exceptions:
  - fallback runtime failures are converted to diagnostics + `undef` return,
  - explicit `die` from `PathSearch` no longer escapes from `get_parser`.
- `LinkedSpec::get_parser` fallback now uses a single guarded resolver call:
  - duplicate unguarded `PathSearch->go` invocation removed,
  - fallback resolution is now fully covered by the eval-guarded call path.
- `LinkedSpec::get_parser` now distinguishes missing paths vs directory paths:
  - unresolved explicit path-like names report `Spec path not found`,
  - resolved directory and non-regular paths report `Spec path is not a file`.
- Regression harness decoupled from direct `Lispish.pm` import:
  - uses LinkedSpec-generated `Lispish` parser coderef for stream parsing in corpus tests.
- Fallback-path coupling cleanup:
  - `PathSearch.pm` no longer imports `Global.pm` (unused for `PathSearch->go` behavior).
  - This prevents fallback-only parser resolution from loading `HUtils`/`Lispish` through `Global`.
- Rule-compilation structure now exposes deterministic execution metadata:
  - `LinkedSpec::Get(..., return_descr => 1)` returns generated descriptor internals for tooling (`spec` + `gdata`),
  - `spec_entry(...)` now records `meta` per rule (node type, counts, execution shape, selected handler variant),
  - handler-template selection now follows deterministic metadata-based routing instead of hash-key iteration order.
- AND action semantics are now structurally explicit in template selection:
  - one regex/action edge uses `AND_SINGLE_ACODE`,
  - multi-regex/action AND continues to use `AND_ACODE` loop template.
- Bootstrap grammar hardcode is now explicitly indexed by rule identity:
  - each bootstrap rule carries stable `id` + semantic `tags`,
  - `startREs` and dispatch routing are built from tag-driven registry data,
  - recursive brace handler dispatch now resolves `CURLY_BRACE` by ID rather than fixed index constants.
- `spec_entry()` now follows an explicit staged RuleIR pipeline:
  - collect phase: parsed entries are normalized into RuleIR (`_collect_rule_ir`),
  - plan phase: execution metadata is derived from RuleIR (`_plan_rule_ir_meta`),
  - validate phase: incompatible action-mode mixes are rejected (`_validate_rule_ir_or_exit`),
  - emit-context phase: code chunks and action mappings are normalized for handler assembly (`_build_rule_ir_emit_context`).
- Runtime action rewriting now flows through `_rewrite_action_code_with_diagnostics(...)`:
  - helper events are scanned and promoted into canonical action-IR,
  - lowering is applied from canonical events via `_lower_action_code_from_canonical_ir(...)`,
  - `call_spec_handler_subst()` is retained as a compatibility/test shim and is not the runtime emission entrypoint.
- Action rewriter diagnostics are now first-class metadata in RuleIR emit flow:
  - unresolved helper forms are detected by `_find_unresolved_action_helpers(...)`,
  - diagnostics are accumulated across ACODE/BCODE/lifecycle chunks and exposed at `spec->{rule}{meta}{action_rewriter}`,
  - current diagnostics scope focuses on helper-surface mismatch detection without changing rewrite/runtime behavior.
- Action helper lowering contracts are now explicit and shared across rewrite subsystems:
  - helper lowering is declared centrally by `_build_action_lowering_contracts($label)`,
  - rewrite rules are compiled from contracts (`_build_action_rewrite_rules`) rather than hardcoded duplication,
  - unresolved-helper diagnostics reuse contract-declared unresolved patterns and helper labels,
  - per-rule metadata now includes `action_rewriter.rewrite_contract_ids` to expose active lowering-contract surface.
- Helper action-IR node metadata is now collected pre-lowering and exposed for migration tooling:
  - lowering contracts now carry canonical `ir_node` identities,
  - `_collect_action_helper_ir_nodes(...)` records helper action-IR hits before textual lowering is applied,
  - aggregated IR-node counters are surfaced at `spec->{rule}{meta}{action_rewriter}` as `helper_action_ir_count`, `helper_action_ir_nodes`, and `helper_action_ir_hits`.
- Helper action-IR metadata now includes structured helper payload events:
  - helper invocations are scanned pre-lowering with `_scan_contract_ir_events(...)`,
  - payload argument strings are normalized with `_trim_action_ir_value(...)`,
  - `spec->{rule}{meta}{action_rewriter}{helper_action_ir_events}` now provides per-invocation payload records (`ir_node`, `contract_id`, `raw`, `args`) to support canonical action-IR promotion.
- Canonical action-IR promotion now builds statement-level lowering input metadata:
  - helper payload events are promoted by `_canonicalize_helper_action_ir_event(...)`,
  - `_build_canonical_action_ir_events(...)` merges helper-derived canonical events with `RAW_PERL` fallback events for non-helper statements,
  - canonical metadata surface now includes `canonical_action_ir_*` fields under `spec->{rule}{meta}{action_rewriter}` for direct lowering-boundary consumption.
- Canonical action-IR lowering is now active in rewrite execution flow:
  - `_lower_action_code_from_canonical_ir(...)` consumes canonical action-IR events to apply helper lowerings event-by-event,
  - lowering is now canonical-IR-first instead of whole-code regex-pass-first,
  - unresolved helper forms remain unmodified when contract lowering does not apply, preserving unresolved-helper diagnostics.
- Canonical action-IR statement splitting is now nesting-aware:
  - `_split_action_ir_statements(...)` now scans with depth/quote tracking over `()`, `{}`, `[]`, and quoted strings,
  - nested semicolons inside helper payloads no longer fragment helper statements into false `RAW_PERL` canonical fallback entries.
- Canonical helper lowering is now whitespace-tolerant:
  - helper substitution regexes in `_build_action_lowering_contracts(...)` now accept optional spacing around helper names, parentheses, and arguments,
  - spacing-only helper variants now lower through canonical action-IR flow instead of remaining unresolved.
- Canonical helper lowering now covers return-call wrappers:
  - `_build_action_lowering_contracts(...)` includes a `return_call` contract for full-statement `return call(Rule)` forms,
  - `_scan_contract_ir_events(...)` + `_canonicalize_helper_action_ir_event(...)` now carry return-call wrapper events into canonical CALL lowering.
- Canonical helper lowering now covers indexed push-call wrappers:
  - `_build_action_lowering_contracts(...)` includes `push_call_indexed_builtin` for `push @target, call(Rule)->[index]` forms,
  - non-indexed `push_call_builtin` now uses a boundary guard so indexed wrappers are routed deterministically to the indexed contract.
- Method-like parser entrypoints now support chained method blocks:
  - `_parse_method_call_chain(...)` and `_render_method_call_chain(...)` now normalize `.method(...).method2(...)` chains for both action and non-action method-like bootstrap handlers,
  - chained method parsing now accepts empty argument lists (`()`), preserving multi-step method-like authoring ergonomics.
- Canonical helper lowering now covers typed declaration methods:
  - `declare(type, ...)` with `type ∈ {array, scalar, hash}` is now lowered through dedicated `DECLARE` contracts and IR events,
  - declaration aliases (`declare_a/s/h` and `declare_array/scalar/hash`) map to the same typed declaration semantics.
- Method-style empty-action argument normalization is now whitespace-tolerant at outer boundaries:
  - `METHOD_EMPTY_ACTION_CODE_BLOCK` processing trims `^\s*\(` and `\)\s*$` around outer argument payloads,
  - leading-space argument forms no longer lose closing-balance alignment during helper rewrite/lowering paths.
- Canonical statement splitting is now line-comment-aware:
  - `_split_action_ir_statements(...)` now tracks Perl line comments outside quoted strings,
  - semicolons inside line comments are ignored by top-level statement splitting, reducing fallback-fragment noise in canonical metadata.
- Canonical statement splitting is now backtick-quote-aware:
  - `_split_action_ir_statements(...)` now tracks backtick-quoted strings with escape handling,
  - semicolons inside backtick payload strings are ignored by top-level statement splitting, keeping canonical RAW_PERL fallback payloads intact.
- Canonical statement splitting is now slash-quote-aware:
  - `_split_action_ir_statements(...)` now tracks slash-delimited Perl quote-like payloads with escape handling,
  - semicolons inside slash-quote payload strings are ignored by top-level statement splitting, keeping canonical RAW_PERL fallback payloads intact.
- Canonical statement splitting is now angle-quote-aware:
  - `_split_action_ir_statements(...)` now tracks angle-delimited Perl quote-like payloads with escape and nested-angle handling,
  - semicolons inside angle-quote payload strings are ignored by top-level statement splitting, keeping canonical RAW_PERL fallback payloads intact.

## Change Discipline
Before each commit:
1. Update `CHANGES.md` with exact pending changes.
2. Update `DEVELOPMENT_NOTES.md` with rationale/decisions.
3. Update `USER_GUIDE.md` for user-visible behavior changes.
4. Update `ROADMAP.md` status and milestones.
5. Update `MEMORY.md` with resumable session context.
