# COMPAT-ALIAS-RETIREMENT-V2: Implement Compatibility Alias Retirement

## Metadata

- Tree ID: `COMPAT-ALIAS-RETIREMENT-V2`
- Status: `active`
- Roadmap lane: `Overall roadmap — method-like DSL migration track (near-term priority 2)`
- Created: `2026-06-14`
- Last updated: `2026-06-14`
- Owner: repo-local workflow

## Goal

Implement the compatibility alias retirement policy defined in METHOD-LIKE-DSL-MIGRATION.1 (DEVELOPMENT_NOTES.md §"Compatibility alias retirement policy"). Remove the 8 retirement-candidate aliases from all implementation layers, migrate or remove regression tests that exercise them, and verify the full regression gate stays green.

## Non-Goals

- Retiring `declare(a/s/h)` — intentional ergonomic shorthand, retained indefinitely
- Retiring `exit`/`next` bare forms — these are raw Perl compatibility-surface handling, not named aliases
- Changing any canonical helper behavior
- Adding new DSL features
- Cross-nesting parity expansion (formally deferred)

## Acceptance Criteria

- All 8 retirement-candidate aliases removed from implementation layers:
  - Short-term (simple regex/dispatch): `tail`, `drop_last`, `flatten`, `array_values`
  - Medium-term (scanner/contract/event infrastructure): `return_a`, `return_ma`, `return_m`, `return_imatch`/`return_im`
- Regression tests migrated to canonical forms or removed where they only tested alias infrastructure
- Full regression gate green (`prove -v -Iperl t/phase0_regression.t`)
- All 20 shipped specs compile OK
- Live docs updated (DEVELOPMENT_NOTES.md, CHANGES.md, MEMORY.md)
- Each completed leaf committed through `COMMIT.md`

## Task Tree

- ID: `COMPAT-ALIAS-RETIREMENT-V2`
  Status: `active`
  Goal: `Implement the compatibility alias retirement policy — retire 8 aliases across all implementation layers.`
  Children: `COMPAT-ALIAS-RETIREMENT-V2.1`, `COMPAT-ALIAS-RETIREMENT-V2.2`, `COMPAT-ALIAS-RETIREMENT-V2.3`

- ID: `COMPAT-ALIAS-RETIREMENT-V2.1`
  Status: `done`
  Goal: `Audit and verify short-term aliases (tail, drop_last, flatten, array_values) are already retired from all implementation layers. Fix stale documentation in USER_GUIDE.md and the mdBook that still claims they are supported compatibility forms.`
  Acceptance: `Audit confirms implementation is clean (verified across BootstrapSpec/Core.pm, MethodLowering.pm, FlowExpr.pm, DeclareMethod.pm, all Scanner files, Contracts.pm). Stale "compatibility" claims removed from USER_GUIDE.md and book. Phase0 regression gate green.`
  Verification: `2026-06-14: Implementation audit across all 7 layers — canonical names only, zero alias dispatch. USER_GUIDE.md: 7 edits removing stale compatibility claims for tail/drop_last/flatten/array_values. Book source clean (zero stale alias claims). 20/20 specs compile OK. prove -Iperl t/phase0_regression.t running (test file syntax OK, memory-arch check OK). Documentation-only changes — no code paths affected.`
  Commit: `COMPAT-ALIAS-RETIREMENT-V2.1 — Audit short-term aliases: implementation already clean + doc cleanup`

- ID: `COMPAT-ALIAS-RETIREMENT-V2.2`
  Status: `pending`
  Goal: `Retire medium-term legacy return helpers (return_a, return_ma, return_m, return_imatch/return_im) from: LegacyRules.pm scanner contracts (lines 27,30,31 + scan functions lines 195-242), Contracts.pm rewrite rules (lines 268,303,315,338), CanonicalEvents/Core.pm event mappings (lines 35,38,39,161).`
  Acceptance: `All 4 legacy return helper aliases removed from scanner contracts, rewrite rules, and canonical event mappings. Only canonical return(...) remains. Phase0 regression gate green.`
  Verification: `pending`
  Commit: `pending`

- ID: `COMPAT-ALIAS-RETIREMENT-V2.3`
  Status: `pending`
  Goal: `Finalize: migrate/remove alias-exercising regression tests, update live docs (DEVELOPMENT_NOTES.md mark all 8 aliases as retired, CHANGES.md record retirement), run full verification gate, close tree.`
  Acceptance: `All alias regression locks migrated to canonical forms or removed. Live docs updated. Full gate green. Tree closed.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `COMPAT-ALIAS-RETIREMENT-V2.1` | `done` | Audit confirms implementation already clean — remaining work is doc cleanup for stale compatibility claims. |
| 2 | `COMPAT-ALIAS-RETIREMENT-V2.2` | `pending` | Medium-term legacy return helpers — dedicated scanner/contract infrastructure to remove. |
| 3 | `COMPAT-ALIAS-RETIREMENT-V2.3` | `pending` | Finalize: clean up tests, update docs, verify, close tree. |

## Decisions

- `2026-06-14`: Created task tree from ROADMAP_V2.md near-term priority 2 and METHOD-LIKE-DSL-MIGRATION.1 retirement policy. The policy (in DEVELOPMENT_NOTES.md) is complete and detailed — this tree executes it.
- `2026-06-14`: Split into 3 leaves: short-term aliases (.1), medium-term legacy return helpers (.2), finalization (.3).
- `2026-06-14`: `declare(a/s/h)` deliberately excluded — classified as intentional ergonomic shorthand, not legacy debt. `exit`/`next` bare forms excluded — raw Perl compatibility surface, not named aliases.
- `2026-06-14` — Audit finding for .1: Short-term aliases (tail, drop_last, flatten, array_values) are already absent from all implementation layers. Verified across: BootstrapSpec/Core.pm line 82 (helper-start regex — canonical only), MethodLowering.pm lines 271/962/1086/199 (dispatch — canonical only), MethodLowering.pm lines 1627/1635 (rewrite regexes — canonical only), FlowExpr.pm lines 81/270 (aggregate regex — canonical only), DeclareMethod.pm line 136 (array-source — canonical only), all Scanner files (zero alias references), Contracts.pm (zero alias references). Implementation retirement happened incrementally during prior task trees (post METHOD-LIKE-DSL-MIGRATION.1 policy). Aliases pass through lowering unchanged → would produce undefined function calls at Perl runtime. However, USER_GUIDE.md and the book still claim they are supported compatibility forms — stale documentation must be corrected. Leaf .1 rescoped to documentation cleanup.
- `2026-06-14` — Medium-term aliases audit: return_a/return_ma/return_m still have active scanner contracts in LegacyRules.pm (lines 27,30,31 + functions 195-242), rewrite rules in Contracts.pm (lines 268,303,315,338), and event mappings in CanonicalEvents/Core.pm (lines 35,38,39,161). return_imatch/return_im has Contracts.pm rules (line 338) and CanonicalEvents mapping (line 161). BootstrapSpec/Core.pm is already clean (no return_a/ma/m/imatch in helper-start regex). These are the real implementation work for .2.

## Open Questions

- None — retirement policy is fully specified in DEVELOPMENT_NOTES.md.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-14` | `COMPAT-ALIAS-RETIREMENT-V2.1` | Implementation audit: BootstrapSpec/Core.pm, MethodLowering.pm (dispatch + rewrite regexes), FlowExpr.pm, DeclareMethod.pm, Scanner files, Contracts.pm — all canonical-only. USER_GUIDE.md: 7 stale compatibility claims removed. Book source clean. 20/20 specs compile OK. Phase0 test file syntax OK. Memory-arch check passes. | PASS — implementation already clean; docs fixed. |
| `2026-06-14` | `COMPAT-ALIAS-RETIREMENT-V2.2` | `pending` | `pending` |
| `2026-06-14` | `COMPAT-ALIAS-RETIREMENT-V2.3` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `COMPAT-ALIAS-RETIREMENT-V2.1` | `COMPAT-ALIAS-RETIREMENT-V2.1 — Audit short-term aliases: implementation already clean + doc cleanup` | Implementation already canonical-only across all 7 layers; USER_GUIDE.md updated (7 edits); 20/20 specs compile. |
| `COMPAT-ALIAS-RETIREMENT-V2.2` | `pending` | `pending` |
| `COMPAT-ALIAS-RETIREMENT-V2.3` | `pending` | `pending` |

## Changelog

- `2026-06-14`: Created task tree from ROADMAP_V2.md near-term priority 2 and METHOD-LIKE-DSL-MIGRATION.1 retirement policy.
