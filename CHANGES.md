# CHANGES
Detailed technical history of changes prepared for commit.

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
