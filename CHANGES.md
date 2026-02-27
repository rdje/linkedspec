# CHANGES
Detailed technical history of changes prepared for commit.
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
