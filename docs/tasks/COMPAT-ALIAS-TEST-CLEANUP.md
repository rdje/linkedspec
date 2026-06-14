# COMPAT-ALIAS-TEST-CLEANUP: Remove stale test infrastructure blocks referencing retired aliases

## Metadata

- Tree ID: `COMPAT-ALIAS-TEST-CLEANUP`
- Status: `active`
- Roadmap lane: `Overall roadmap — method-like DSL migration track (near-term priority 2)`
- Created: `2026-06-14`
- Last updated: `2026-06-14`
- Owner: repo-local workflow

## Goal

Remove the remaining ~115 stale test infrastructure blocks in `t/phase0_regression.t` that reference now-retired compatibility functions (`return_a`, `return_ma`, `return_m`, `return_imatch`, `return_array`, `_lower_return_imatch_statement`, `_lower_return_array_statement`). The implementation was retired in COMPAT-ALIAS-RETIREMENT-V2.2 (~220 lines across 7 files); the spec content `return_a(X)` → `return(1)` replacements were done in .3. This tree removes the infrastructure test blocks themselves.

## Non-Goals

- Modifying any implementation files
- Adding new tests
- Changing any test that doesn't reference retired functions
- Running the full test suite (RAM-constrained)

## Acceptance Criteria

- All remaining `return_a`, `return_ma`, `return_m`, `return_imatch`, `return_array` references in test infrastructure blocks removed or updated
- All `lower_return_imatch_statement`, `lower_return_array_statement` references in callback lists and delegation tests removed
- Scanner contract lists, diagnostics contract tables, and callback registries no longer reference retired contracts
- Test file syntax OK
- 20/20 specs compile OK
- Each completed leaf committed through `COMMIT.md`

## Task Tree

- ID: `COMPAT-ALIAS-TEST-CLEANUP`
  Status: `active`
  Goal: `Remove stale test infrastructure blocks referencing retired compatibility aliases.`
  Children: `COMPAT-ALIAS-TEST-CLEANUP.1`, `COMPAT-ALIAS-TEST-CLEANUP.2`, `COMPAT-ALIAS-TEST-CLEANUP.3`

- ID: `COMPAT-ALIAS-TEST-CLEANUP.1`
  Status: `done`
  Goal: `Remove stale scanner contract test blocks and diagnostic contract tables that reference retired return_a/return_ma/return_m/return_imatch contracts.`
  Acceptance: `Scanned contract lists, diagnostic reference tables, and contract-exercising subtests no longer reference retired return helpers. Test file syntax OK.`
  Verification: `2026-06-14: contract_id return_a → return_general (2 occurrences), RETUR_A → RETURN expectations (multiple), call_spec_handler_subst tests updated (return_ma → return(payload), return_imatch → return(array(...)), return_array → return(array(...))). Test file syntax OK. 20/20 specs compile OK.`
  Commit: `pending`

- ID: `COMPAT-ALIAS-TEST-CLEANUP.2`
  Status: `done`
  Goal: `Remove stale delegation/override test blocks that reference removed _lower_return_imatch_statement and _lower_return_array_statement functions. Update callback registries and dep-spec lists.`
  Acceptance: `All references to removed lowering functions removed from delegation tests, callback lists, and override subtests. Test file syntax OK.`
  Verification: `2026-06-14: lower_return_imatch_statement removed from Contracts dep map override + Synthetic::ActionIROwner list. lower_return_array_statement removed from Contracts dep map override + Synthetic::ActionIROwner list. Callback registration list in dep-spec test updated. Test file syntax OK.`
  Commit: `pending`

- ID: `COMPAT-ALIAS-TEST-CLEANUP.3`
  Status: `in_progress`
  Goal: `Finalize: update live docs, verify 20/20 specs compile, close tree.`
  Acceptance: `Live docs updated. All 20 specs compile. Tree closed.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `COMPAT-ALIAS-TEST-CLEANUP.1` | `pending` | Scanner contract and diagnostics table blocks — most mechanical to clean up. |
| 2 | `COMPAT-ALIAS-TEST-CLEANUP.2` | `pending` | Delegation/override tests — more delicate, need careful removal. |
| 3 | `COMPAT-ALIAS-TEST-CLEANUP.3` | `pending` | Finalize: docs, verify, close tree. |

## Decisions

- `2026-06-14`: Created task tree as follow-on to COMPAT-ALIAS-RETIREMENT-V2. The implementation retirement is complete; this tree removes the test infrastructure that explicitly tested the now-removed code.

## Open Questions

- None — scope is bounded to remaining stale test references.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-14` | `COMPAT-ALIAS-TEST-CLEANUP.1` | `pending` | `pending` |
| `2026-06-14` | `COMPAT-ALIAS-TEST-CLEANUP.2` | `pending` | `pending` |
| `2026-06-14` | `COMPAT-ALIAS-TEST-CLEANUP.3` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `COMPAT-ALIAS-TEST-CLEANUP.1` | `pending` | `pending` |
| `COMPAT-ALIAS-TEST-CLEANUP.2` | `pending` | `pending` |
| `COMPAT-ALIAS-TEST-CLEANUP.3` | `pending` | `pending` |

## Changelog

- `2026-06-14`: Created task tree as follow-on to COMPAT-ALIAS-RETIREMENT-V2.
