# MEMORY
Compact, actionable session memory for interruption-safe continuation.

## Mission Context
LinkedSpec is being evolved into a serious progressive extraction parser tool (alternative to strict EBNF workflows in niche use-cases), with recursion and staged coarse-to-fine parsing as core strengths.

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

## Live Documents Contract
These files are live and must be amended before any commit:
- `ROADMAP.md`
- `USER_GUIDE.md`
- `DEVELOPMENT_NOTES.md`
- `CHANGES.md`
- `MEMORY.md`

## Recent Commit Ledger (Newest First)
- `4067980` - Lock parser invalid-input subprocess behavior and update live docs
- `59ed4d0` - Add mixed ACTION/BLIND CALL exit-path regression coverage for get_parser
- `417d43e` - Add malformed-handler runtime-error regression coverage for get_parser
- `cfa140b` - Add malformed-spec negative-path regression for get_parser
- `8c66bc5` - Add get_parser open-failure negative-path regression coverage
- `f38e0b3` - Add unresolved-spec negative-path regression checks for get_parser
- `0651fc6` - Expand Phase-1 regression coverage and decouple PathSearch fallback dependencies
- `3d4b75b` - Complete Phase-1 LinkedSpec core isolation and refresh live docs
- `cf25bd3` - Bootstrap LinkedSpec baseline, docs, and corpus regression
- `dca1b21` - Initial commit

## Resume-Work Checklist
When resuming after interruption:
1. Read `MEMORY.md` first (this file).
2. Check `CHANGES.md` for pending commit scope.
3. Check `ROADMAP.md` for current phase + next milestone.
4. Check `DEVELOPMENT_NOTES.md` for design constraints/decisions.
5. Check `USER_GUIDE.md` for user-facing behavior implications.
6. Continue implementation from highest-priority roadmap item.

## Next Recommended Work Item
- Continue Phase-1 hardening with targeted behavior locks:
  - keep full resolution-order tests green,
  - add targeted checks for additional explicit exit paths outside ACTION/BLIND CALL conflict handling,
  - keep `tclite.spec` deferred until explicitly resumed.

## Latest Session Update
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

## Update Policy
Update this file after every meaningful exchange/task completion with:
- What changed,
- Why it changed,
- What remains,
- Exact next step.
- If a commit was created, append hash + subject in `Recent Commit Ledger (Newest First)`.
