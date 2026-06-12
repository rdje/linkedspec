# COMPAT-ALIAS-RETIREMENT: Compatibility Alias Retirement

## Metadata

- Tree ID: `COMPAT-ALIAS-RETIREMENT`
- Status: `completed`
- Roadmap lane: `Method-like DSL migration track`
- Created: `2026-06-11`
- Last updated: `2026-06-12` (tree completed — all 4 leaves done or deferred)
- Owner: repo-local workflow

## Goal

Remove the 4 short-term compatibility aliases from the implementation, tests, and documentation.
Remove medium-term aliases from book/documentation. Defer medium-term implementation removal
until a dedicated test migration strategy is available.

## Non-Goals

- Retiring `declare(a/s/h)` shorthand — classified as intentional ergonomic shorthand, retained indefinitely per `METHOD-LIKE-DSL-MIGRATION.1`.
- Adding new DSL features or helpers.
- Changing the lowering output of any canonical helper.
- Touching `.spec` files — all 19 shipped specs already use zero aliases.

## Acceptance Criteria

- All 4 short-term aliases removed from implementation files (regex alternations, `if`-condition fallthroughs).
- Test references updated to canonical forms; dedicated alias regression tests removed or rewritten.
- Book documentation updated to remove all 8 alias entries from helper reference tables.
- `docs/decisions/0003-raw-perl-free-spec-authoring.md` updated.
- `phase0_regression.t` passes with full baseline.
- `perl -c perl/LinkedSpec.pm` passes.
- Live docs and roadmap status updated.
- Each completed leaf committed through `COMMIT.md`.

## Task Tree

- ID: `COMPAT-ALIAS-RETIREMENT`
  Status: `active`
  Goal: `Remove all 8 compatibility aliases from code, tests, and docs.`
  Children: `COMPAT-ALIAS-RETIREMENT.1`, `COMPAT-ALIAS-RETIREMENT.2`, `COMPAT-ALIAS-RETIREMENT.3`, `COMPAT-ALIAS-RETIREMENT.4`

- ID: `COMPAT-ALIAS-RETIREMENT.1`
  Status: `done`
  Goal: `Remove short-term aliases (tail→drop_front, drop_last→drop_back, flatten→flat, array_values→array_copy) from implementation. Remove alias names from regex alternations and if-condition fallthroughs in MethodLowering.pm, FlowExpr.pm, DeclareMethod.pm, BootstrapSpec/Core.pm, and Contracts.pm. Update dedicated alias regression tests in phase0_regression.t. Update book helper-reference tables.`
  Acceptance: `Zero references to tail/drop_last/flatten/array_values as DSL helper names remain in perl/ (except Lispish::flatten which is a standalone Perl utility, and the word "tail" in unrelated contexts). Phase0 passes. Book reference tables no longer list these as aliases.`
  Verification: `2026-06-12: 5 implementation files cleaned (MethodLowering.pm, FlowExpr.pm, DeclareMethod.pm, BootstrapSpec/Core.pm, Contracts.pm). 2 alias regression tests removed (flatten), 2 converted to canonical-form tests (tail→drop_front, drop_last→drop_back). 36 array_values references in tests replaced with array_copy. Book helper-reference table updated (4 alias rows removed). docs/decisions/0003 updated. tools/run_ci_local.sh exit 0, phase0 1004 PASS. Also fixed 3 pre-existing test failures from PLUGIN-ACTION-MIGRATION deletions (tests 113, 131/132, 135).`
  Commit: `802dbe3`

- ID: `COMPAT-ALIAS-RETIREMENT.2`
  Status: `deferred`
  Goal: `Remove medium-term aliases from implementation — attempted 2026-06-12 (committed 390a87e), reverted (9d5f20f). Infrastructure removal is correct but test surface is too large for automated migration.`
  Acceptance: `Deferred until a dedicated test migration strategy exists. Root cause: ~692 return_a references across complex Perl quoting contexts (double-quoted, single-quoted, heredocs) make automated canonical-form replacement unreliable.`
  Verification: `2026-06-12: Infrastructure removal committed then reverted. 6 files changed correctly but test fallout (~91 failures after partial replacement) confirmed the test surface is the blocker, not the implementation.`
  Commit: `390a87e` (committed), `9d5f20f` (reverted)`

- ID: `COMPAT-ALIAS-RETIREMENT.3`
  Status: `deferred`
  Goal: `Update test references to medium-term aliases — blocked by .2 deferral. Three automated replacement strategies attempted (canonical with ', canonical with ", return(1) filler); all failed due to Perl quoting context conflicts across 692 references.`
  Acceptance: `Deferred with .2. Future approach: either (a) write a context-aware Perl parser for the test file, or (b) add internal compatibility redirects that keep return_a/m/ma/imatch working but undocumented.`
  Verification: `2026-06-12: Three replacement attempts; all produced Perl syntax errors in "..." contexts due to unescaped quotes.`
  Commit: `pending`

- ID: `COMPAT-ALIAS-RETIREMENT.4`
  Status: `done`
  Goal: `Update documentation — book helper-reference tables updated for all 8 aliases (4 rows removed for short-term, medium-term retained with deferred-removal annotation). docs/decisions/0003 updated. ROADMAP_V2.md and MEMORY.md updated.`
  Acceptance: `Book reflects short-term aliases as removed; medium-term aliases documented as deprecated/deferred-removal. Decision record 0003 updated.`
  Verification: `2026-06-12: Book value-container-flow-helper-reference.md updated (4 alias rows removed). docs/decisions/0003 updated. ROADMAP_V2.md Method-like track status refined.`
  Commit: `545515f`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `COMPAT-ALIAS-RETIREMENT.1` | `done` | Short-term aliases removed (tail/drop_last/flatten/array_values). |
| 2 | `COMPAT-ALIAS-RETIREMENT.4` | `done` | Documentation updated for short-term aliases; medium-term deferred. |
| 3 | `COMPAT-ALIAS-RETIREMENT.2` | `deferred` | Medium-term infrastructure removal depends on .3 test strategy. |
| 4 | `COMPAT-ALIAS-RETIREMENT.3` | `deferred` | ~692 test references need context-aware migration. |

## Decisions

- `2026-06-11`: Created task tree. 4 leaves: short-term removal (.1), medium-term infrastructure removal (.2), test updates (.3), documentation and close-out (.4).
- `2026-06-12`: Medium-term alias retirement (.2/.3) deferred. Root cause: ~692 `return_a(Label)` references in `phase0_regression.t` span multiple Perl quoting contexts (`"..."`, `'...'`, `<<'SPEC'` heredocs). Three automated replacement strategies failed. The canonical replacement `return(array("?Label:", array_copy(array(Label))))` introduces `"` characters that break double-quoted Perl strings. A future effort needs either a context-aware test parser or internal compatibility redirects. Short-term aliases (.1) successfully retired with only ~40 references and no quoting conflicts.

## Open Questions

- What is the right test migration strategy for the ~692 medium-term alias references? Options: (a) context-aware Perl parser for the test file, (b) internal compatibility redirects that keep aliases working but undocumented, (c) manual migration split across multiple leaves.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-12` | `COMPAT-ALIAS-RETIREMENT.1` | 5 impl files, test updates, book update, CI gate: 1004 PASS | Pass |
| `2026-06-12` | `COMPAT-ALIAS-RETIREMENT.2` | Infra removal correct, reverted due to test surface | Deferred |
| `2026-06-12` | `COMPAT-ALIAS-RETIREMENT.4` | Book, decision docs updated for short-term aliases | Pass |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `COMPAT-ALIAS-RETIREMENT.1` | `802dbe3` | Short-term aliases removed (tail/drop_last/flatten/array_values). |
| `COMPAT-ALIAS-RETIREMENT.2` | `390a87e` (committed), `9d5f20f` (reverted) | Medium-term infra correct but deferred. |
| `COMPAT-ALIAS-RETIREMENT.4` | `545515f` | Documentation update for completed + deferred leaves. |

## Changelog

- `2026-06-11`: Created task tree with 4 leaves.
- `2026-06-12`: Completed .1 (short-term aliases removed, 1004 PASS).
- `2026-06-12`: Attempted .2 — infrastructure removal committed (`390a87e`), verified correct, but reverted (`9d5f20f`) because .3 test migration proved infeasible with current tooling.
- `2026-06-12`: Completed .4 — documentation updated; .2/.3 deferred with detailed rationale.
- `2026-06-12`: Tree marked `completed` — all 4 leaves done or deferred. Moved to Completed in `docs/TASK_TREE.md`. Commit logs backfilled.
