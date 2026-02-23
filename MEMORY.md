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
  - add targeted checks for explicit exit-path diagnostics emitted by generated handlers,
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

## Update Policy
Update this file after every meaningful exchange/task completion with:
- What changed,
- Why it changed,
- What remains,
- Exact next step.
