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
   - Move progressively away from raw Perl code blocks in `.spec`.
   - Status: In progress (v1 pipeline + unresolved-helper diagnostics landed; full action AST/IR still planned).

## Practical Migration Path (Tracked Sequence)
1. Refactor-only extraction:
   - Isolate bootstrap handlers and `spec_entry()` stages into private helpers/modules with behavior parity.
2. Deterministic codegen routing:
   - Route handler template selection entirely through explicit metadata/strategy plans.
3. Action rewriter v1:
   - Introduce IR-based rewrite for current helper surface while keeping compatibility fallback.
4. Language-neutral action DSL transition:
   - Define and adopt a backend-agnostic action DSL in `.spec` (no raw Perl dependency by default).
5. Multi-backend enablement:
   - Keep regex/execution semantics documented and map action IR to Perl first, then additional backends (e.g. Rust, Julia) incrementally.

## Immediate Next Steps
- Keep Phase-0 baseline continuously green while Phase-1 proceeds.
- Extend Phase-1 isolation to remaining non-essential framework couplings (without changing parser semantics).
- Continue core-structure cleanup with metadata-driven execution routing in `LinkedSpec.pm`, keeping behavior backward compatible.
- Continue Backbone Refactor Track action rewriter follow-up by defining explicit action IR nodes/lowering while preserving compatibility.
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
    - Landed detail: `call_spec_handler_subst()` now routes helper rewrites through ordered declarative rules (`_build_action_rewrite_rules`) and a dedicated apply stage (`_apply_action_rewrite_pipeline`), with regression lock `action_rewriter_pipeline_helper_substitutions`.
    - Landed follow-up: unresolved helper diagnostics are now surfaced in `spec->{rule}{meta}{action_rewriter}` (`unresolved_helpers`, hit counts), with regression lock `action_rewriter_reports_unresolved_helpers_in_rule_meta`.
  - Language-neutral `.spec` action DSL objective (reduce/remove Perl dependency): Planned.
- Phase 2+: Planned.
