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

It should not be reframed as a strict EBNF clone.

## Design Goals
1. Preserve extraction + recursion ergonomics.
2. Introduce explicit parse semantics (`seek` vs `consume`).
3. Formalize position/capture concepts into transparent APIs.
4. Improve diagnostics, determinism, and maintainability.
5. Maintain backward compatibility with existing specs.

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
    - `undef`, empty-string, whitespace-only, non-scalar, and NUL-byte-containing names return `undef` without die,
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
  - `get_parser` explicit-path-miss negative-path checks:
    - unresolved path-like arguments (containing `/` or `\\`) return `undef` without die and report `Spec path not found`,
    - explicit-path misses skip fallback loader paths and keep `PathSearch.pm` unloaded.
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
  - `undef`/empty/whitespace-only/non-scalar/NUL-byte spec-name arguments fail fast with diagnostics and `undef` return,
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
- Regression harness decoupled from direct `Lispish.pm` import:
  - uses LinkedSpec-generated `Lispish` parser coderef for stream parsing in corpus tests.
- Fallback-path coupling cleanup:
  - `PathSearch.pm` no longer imports `Global.pm` (unused for `PathSearch->go` behavior).
  - This prevents fallback-only parser resolution from loading `HUtils`/`Lispish` through `Global`.

## Change Discipline
Before each commit:
1. Update `CHANGES.md` with exact pending changes.
2. Update `DEVELOPMENT_NOTES.md` with rationale/decisions.
3. Update `USER_GUIDE.md` for user-visible behavior changes.
4. Update `ROADMAP.md` status and milestones.
5. Update `MEMORY.md` with resumable session context.
