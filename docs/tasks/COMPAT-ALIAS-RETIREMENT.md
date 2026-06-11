# COMPAT-ALIAS-RETIREMENT: Compatibility Alias Retirement

## Metadata

- Tree ID: `COMPAT-ALIAS-RETIREMENT`
- Status: `active`
- Roadmap lane: `Method-like DSL migration track`
- Created: `2026-06-11`
- Last updated: `2026-06-11`
- Owner: repo-local workflow

## Goal

Remove all 8 retired compatibility aliases from the implementation, tests, and documentation.
The policy was defined in `METHOD-LIKE-DSL-MIGRATION.1`; this tree executes the removal.

## Non-Goals

- Retiring `declare(a/s/h)` shorthand — classified as intentional ergonomic shorthand, retained indefinitely per `METHOD-LIKE-DSL-MIGRATION.1`.
- Adding new DSL features or helpers.
- Changing the lowering output of any canonical helper.
- Touching `.spec` files — all 19 shipped specs already use zero aliases.

## Acceptance Criteria

- All 8 aliases removed from implementation files (scanner rules, contract entries, canonical event mappings, regex alternations, `if`-condition fallthroughs).
- All test references updated to canonical forms; dedicated alias regression tests removed or rewritten.
- Book documentation updated to remove alias entries from helper reference tables.
- `docs/decisions/0003-raw-perl-free-spec-authoring.md` updated to drop alias mentions.
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
  Commit: `pending`

- ID: `COMPAT-ALIAS-RETIREMENT.2`
  Status: `pending`
  Goal: `Remove medium-term aliases from implementation — delete contract entries (return_a/return_m/return_ma/return_imatch) from Contracts.pm, delete scanner rules from LegacyRules.pm and PrimitivePipelineRules.pm, delete canonical event mappings from CanonicalEvents/Core.pm, remove dispatch entries from EmitContext.pm and MethodLowering.pm.`
  Acceptance: `Zero contract entries, scanner rules, or canonical event mappings for return_a/return_m/return_ma/return_imatch remain. Phase0 will fail at this leaf (tests still reference the aliases) — this is expected and .3 will fix it.`
  Verification: `pending`
  Commit: `pending`

- ID: `COMPAT-ALIAS-RETIREMENT.3`
  Status: `pending`
  Goal: `Update all test references to medium-term aliases in phase0_regression.t (~80 return_a sites, plus return_m/return_ma/return_imatch/return_im sites). Replace legacy helper calls with canonical return(...) forms. Remove or rewrite dedicated alias regression subtests.`
  Acceptance: `Zero references to return_a/return_m/return_ma/return_imatch/return_im remain as DSL helper calls in phase0_regression.t. Phase0 full baseline passes.`
  Verification: `pending`
  Commit: `pending`

- ID: `COMPAT-ALIAS-RETIREMENT.4`
  Status: `pending`
  Goal: `Update documentation and close out — update book helper-reference tables, update docs/decisions/0003, update ROADMAP_V2.md Method-like DSL track status to done, update LIVE_ACHIEVEMENT_STATUS.md, update MEMORY.md. Run full local CI gate.`
  Acceptance: `Book and decision docs no longer reference the 8 aliases as live. ROADMAP_V2.md Method-like track flips to done. tools/run_ci_local.sh exits 0.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `COMPAT-ALIAS-RETIREMENT.1` | `done` | Short-term aliases removed (tail/drop_last/flatten/array_values). |
| 2 | `COMPAT-ALIAS-RETIREMENT.2` | `pending` | Remove medium-term infrastructure before updating tests. |
| 3 | `COMPAT-ALIAS-RETIREMENT.3` | `pending` | Update ~80 test references; depends on .2 infrastructure removal. |
| 4 | `COMPAT-ALIAS-RETIREMENT.4` | `pending` | Documentation and close-out; depends on .1–.3. |

## Decisions

- `2026-06-11`: Created task tree. 4 leaves: short-term removal (.1), medium-term infrastructure removal (.2), test updates (.3), documentation and close-out (.4). Short-term aliases removed first because they are simple regex/condition cleanups with minimal test impact. Medium-term split into infrastructure (.2) and test (.3) leaves because the test update is ~80 references and warrants its own slice.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-12` | `COMPAT-ALIAS-RETIREMENT.1` | 5 impl files, test updates, book update, CI gate: 1004 PASS | Pass |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `COMPAT-ALIAS-RETIREMENT.1` | `pending` | — |
| `COMPAT-ALIAS-RETIREMENT.2` | `pending` | — |
| `COMPAT-ALIAS-RETIREMENT.3` | `pending` | — |
| `COMPAT-ALIAS-RETIREMENT.4` | `pending` | — |

## Changelog

- `2026-06-11`: Created task tree with 4 leaves.
