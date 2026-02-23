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
- Keep Phase-0 baseline green while preparing Phase-1 start:
  - preserve current regression suite in CI/local workflow,
  - keep `tclite.spec` deferred until explicitly resumed,
  - begin parser-core isolation planning with compatibility preserved.

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

## Update Policy
Update this file after every meaningful exchange/task completion with:
- What changed,
- Why it changed,
- What remains,
- Exact next step.
