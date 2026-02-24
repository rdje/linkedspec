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
- Expand `USER_GUIDE.md` with practical patterns and anti-patterns.
- Maintain architecture rationale in `DEVELOPMENT_NOTES.md`.
- Keep live state in `MEMORY.md`.
- Exit criteria:
  - Documentation remains current at each commit.

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

## Immediate Next Steps
- Keep Phase-0 baseline continuously green while Phase-1 proceeds.
- Extend Phase-1 isolation to remaining non-essential framework couplings (without changing parser semantics).
- Continue core-structure cleanup with metadata-driven execution routing in `LinkedSpec.pm`, keeping behavior backward compatible.
- Continue Backbone Refactor Track action rewriter follow-up by reducing `RAW_PERL` fallback usage through broader structured action-IR coverage, but do this via action-IR/lowering improvements rather than additional `_split_action_ir_statements(...)` delimiter hardening for now.
- Pause further `_split_action_ir_statements(...)` hardening work; only revisit splitter surface expansion when a concrete regression or unsupported production pattern is observed.
- Keep `.spec` action semantics language-agnostic: avoid introducing new Perl code-block dependence and prioritize IR/DSL forms that can map cleanly to non-Perl backends.
- Keep backend emission under strict canonical forms we control so emitted host-language code avoids avoidable parser/splitter fragility.
- Keep `specs/tclite.spec` deferred until explicitly resumed.
- Define explicit `seek` vs `consume` semantics in design notes before Phase-3 code changes.

## Status
- Phase 0: Active and green (Test::More baseline under `t/phase0_regression.t` for all in-scope specs; `tclite.spec` deferred).
- Phase 0 enhancement: corpus-level regression includes real project directories (`plugin/`, `conf/`, `tablescript/`, `ebnf/`).
- Phase 1: In progress.
  - Landed: module-relative spec resolution in `LinkedSpec::get_parser`.
  - Landed: lazy fallback loading for `PathSearch`.
  - Landed: removal of eager `PPlugin` load at module import time; `AUTOLOAD` remains lazy.
  - Landed: regression harness decoupled from direct `Lispish.pm` import.
  - Landed: rule-level execution metadata + deterministic handler variant selection (`spec->{rule}{meta}`).
  - Landed: `LinkedSpec::Get(..., return_descr => 1)` descriptor-introspection mode for tooling.
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
    - Landed follow-up: `LinkedSpec.pm` now has broad subroutine/top-level documentation comments to improve readability and continuity of parser/rewrite architecture understanding across maintainer handoffs.
    - Current decision: `_split_action_ir_statements(...)` hardening track is paused; future work should prioritize action-IR/lowering and diagnostics unless concrete splitter regressions appear.
  - Language-neutral `.spec` action DSL objective (reduce/remove then eliminate Perl code-block dependency in `.spec`): Planned.
- Phase 2+: Planned.
