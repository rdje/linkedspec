# METHOD-LIKE-DSL-MIGRATION: Method-like DSL Migration Track

## Metadata

- Tree ID: `METHOD-LIKE-DSL-MIGRATION`
- Status: `active`
- Roadmap lane: `Method-like DSL migration track`
- Created: `2026-05-17`
- Last updated: `2026-05-17`
- Active frontier: `METHOD-LIKE-DSL-MIGRATION.3`
- Owner: repo-local workflow

## Goal

Complete the method-like DSL surface — backend-neutral method-style `.spec` action syntax with equivalent fluent-chain and structured-block surfaces, unlimited nested method composition, and zero compatibility-surface rules across all shipped specs. Retire compatibility aliases once migration is complete, document remaining deferred work, and close out the track.

## Non-Goals

- Adding lambdas, closures, currying, or a general-purpose FP sublanguage (explicitly avoided per ROADMAP_V2 design direction).
- Deeper marker `if(...)` / marker `switch(...)` cross-nesting parity expansion (deferred unless a concrete feature or bug requires it).
- PLUGIN-ACTION-MIGRATION — that is a separate proposed follow-on track for migrating 36 `.plg` files (~1,200+ actions) to package owners.
- Phase 1 parser-core isolation cleanup — that is a separate Phase 1 remainder tracked in ROADMAP_V2.

## Acceptance Criteria

- Compatibility alias retirement policy is documented with deprecation timelines and retirement criteria.
- Legacy return-helper references (`return_a`, `return_m`, `return_ma`, `return_imatch`/`return_im`) are audited and either migrated or documented as intentionally preserved compatibility coverage.
- Convention-based accumulator helpers (implicit `$retv`, rule-level array targets, `@capt` patterns) are audited and documented.
- Missing user-facing DSL features are inventoried against the design direction, with follow-on leaves for any concrete gaps found.
- Deeper cross-nesting parity is formally deferred with explicit reactivation criteria.
- Live docs and roadmap status updated.
- Each completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `METHOD-LIKE-DSL-MIGRATION`
  Status: `active`
  Goal: `Complete the method-like DSL surface — retire compatibility aliases, audit legacy helpers, inventory missing features, defer cross-nesting parity.`
  Children: `METHOD-LIKE-DSL-MIGRATION.1`, `METHOD-LIKE-DSL-MIGRATION.2`, `METHOD-LIKE-DSL-MIGRATION.3`, `METHOD-LIKE-DSL-MIGRATION.4`, `METHOD-LIKE-DSL-MIGRATION.5`

- ID: `METHOD-LIKE-DSL-MIGRATION.1`
  Status: `done`
  Goal: `Compatibility alias retirement policy audit — inventory all active compatibility aliases, document their current usage, deprecation timeline, and retirement criteria.`
  Acceptance: `Policy documented in DEVELOPMENT_NOTES.md. Each alias has a stated retirement condition (e.g., "when zero .spec/.plg references remain" or "when all shipped docs/tests use canonical form"). Alias inventory covers: tail→drop_front, drop_last→drop_back, flatten→flat, array_values→array_copy, declare a/s/h→array/scalar/hash, legacy return helpers (return_a, return_m, return_ma, return_imatch/return_im), and any additional aliases discovered during audit.`
  Verification: `2026-05-17: Comprehensive audit complete. 11 aliases inventoried across 4 implementation layers (BootstrapSpec/Core.pm, MethodLowering.pm, FlowExpr.pm, DeclareMethod.pm) plus 3 scanner/contract layers (LegacyRules.pm, Contracts.pm, CanonicalEvents/Core.pm). All 19 shipped .spec files use zero aliases — canonical forms exclusively. Retirement policy defined with 6-step retirement process. Full POLICY section appended to DEVELOPMENT_NOTES.md covering guiding principle, retirement process, alias inventory (11 entries), implementation layers affected (summary table), and current state assessment. Two retirement tiers identified: short-term (tail/drop_last/flatten/array_values — simple regex updates) and medium-term (return_a/m/ma/imatch — dedicated scanner/contract infrastructure). declare(a/s/h) classified as intentional ergonomic shorthand, not legacy debt — retained indefinitely.`
  Commit: `pending`

- ID: `METHOD-LIKE-DSL-MIGRATION.2`
  Status: `done`
  Goal: `Legacy return-helper cleanup — audit remaining return_a, return_m, return_ma, return_imatch/return_im references in docs/tests/deferred specs. Migrate or document as intentionally preserved compatibility coverage.`
  Acceptance: `All legacy return-helper references are either migrated to canonical return(...) or explicitly documented as preserved compatibility regression coverage with rationale. Tests that exercise legacy helpers for regression coverage are clearly marked.`
  Verification: `2026-05-17: Comprehensive audit complete. 4 categories of references found: (1) ~15 incidental spec-content uses in lazy-load tests — preserved, not testing action syntax; (2) ~11 intentional compatibility infrastructure tests — preserved, regression locks for compat path; (3) 6 book references — already documented as legacy with canonical alternatives; (4) ~15 USER_GUIDE references — authoritative compat contract reference docs. Zero references require migration. Full audit documented in DEVELOPMENT_NOTES.md with per-category breakdown and summary table.`
  Commit: `pending`

- ID: `METHOD-LIKE-DSL-MIGRATION.3`
  Status: `pending`
  Goal: `Convention-based accumulator audit — audit implicit $retv, rule-level array target, and @capt patterns across shipped specs. Document current conventions and determine whether any should be made explicit through new helpers.`
  Acceptance: `Audit findings documented. For each convention: stated whether it remains a supported convention or needs an explicit helper. Any new helpers needed are proposed as follow-on leaves.`
  Verification: `pending`
  Commit: `pending`

- ID: `METHOD-LIKE-DSL-MIGRATION.4`
  Status: `pending`
  Goal: `Missing user-facing DSL features inventory — compare current helper surface against the design direction (functional-expression style, unlimited composition) and identify concrete gaps.`
  Acceptance: `Inventory lists any DSL features still expressed as raw Perl in shipped specs, or any helper families missing for functional-expression coverage. If gaps are found, follow-on leaves are created. If no gaps remain, track can proceed to close-out.`
  Verification: `pending`
  Commit: `pending`

- ID: `METHOD-LIKE-DSL-MIGRATION.5`
  Status: `pending`
  Goal: `Formally defer deeper cross-nesting parity — document the deferred status of marker if(...)/switch(...) cross-nesting parity expansion with explicit reactivation criteria.`
  Acceptance: `Deferred item documented in DEVELOPMENT_NOTES.md (or task file) with: what is deferred, why, and what conditions would reactivate it (concrete feature request or bug). Track close-out proceeds with this deferred item acknowledged.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `METHOD-LIKE-DSL-MIGRATION.1` | `done` | Compatibility alias retirement policy audit — 11 aliases inventoried, policy in DEVELOPMENT_NOTES.md. |
| 2 | `METHOD-LIKE-DSL-MIGRATION.2` | `done` | Legacy return-helper cleanup — 4 categories audited, zero migrations needed, documented in DEVELOPMENT_NOTES.md. |
| 3 | `METHOD-LIKE-DSL-MIGRATION.3` | `pending` | Convention-based accumulator audit — independent of .1/.2, can run in parallel. |
| 4 | `METHOD-LIKE-DSL-MIGRATION.4` | `pending` | Missing DSL features inventory — determines whether additional leaves are needed. |
| 5 | `METHOD-LIKE-DSL-MIGRATION.5` | `pending` | Formalize cross-nesting parity deferral — close-out prerequisite. |

## Background

### What's Already Landed

The method-like DSL surface is extensive. All 19 shipped `.spec` files report zero compatibility-surface rules. The following families are fully regression-locked on both fluent-chain and structured-block surfaces:

- **Declare/assign**: `declare(scalar|array|hash, name)`, `declare(scalar, name=value)`, `assign(...)`, `push_value(...)`
- **Scalar ops**: `trim(...)`, `lowercase(...)`, `uppercase(...)`, `length(...)`, `concat(...)`, `substr(...)`, `coalesce(...)`, `coalesce_nonempty(...)`, `replace_substr(...)`, `rm_prefix(...)`, `rm_suffix(...)`, `matches(...)`, `starts_with(...)`, `ends_with(...)`, `contains_substr(...)`
- **Numeric ops**: `num_add(...)`, `num_sub(...)`, `num_mul(...)`, `num_div(...)`, `num_mod(...)`, `num_abs(...)`, `num_floor(...)`, `num_ceil(...)`, `num_round(...)`, `num_clamp(...)`, `num_min(...)`, `num_max(...)`, `num_sum(...)`, `num_avg(...)`, `num_median(...)`, `num_range(...)`
- **Array ops**: `count(...)`, `first(...)`, `last(...)`, `drop_front(...)`, `drop_back(...)`, `take(...)`, `take_last(...)`, `slice(...)`, `sorted(...)`, `reversed(...)`, `contains(...)`, `index_of(...)`, `concat_arrays(...)`, `split(...)`, `split_each(...)`, `trim_each(...)`, `filter_nonempty(...)`, `lowercase_each(...)`, `uppercase_each(...)`, `uniq(...)`, `filter_match(...)`, `join_values(...)`, `flat_array(...)`, `flat_hash(...)`, `array_copy(...)`, `entry_groups()`, `match_groups()`
- **Hash ops**: `count_keys(...)`, `has_key(...)`, `merge_hash(...)`, `hash_copy(...)`, `set_key(...)`, `rename_key(...)`, `drop_keys(...)`, `pick_keys(...)`, `sorted_keys(...)`, `sorted_values(...)`
- **Control flow**: `if(cond); ...; else(); ...; endif()`, `switch(expr) { case(val) ... default ... }`, `exit_now(n)`, `next()`
- **Return/flow**: `return(...)`, `return_undef()`, `call(...)`, `is_defined(...)`, `is_undefined(...)`, `is_empty(...)`, `is_nonempty(...)`
- **State access**: `scalar(name)`, `scalar(container, key_or_index)`, `scalaref(name, {...})`, `array(name)`
- **Predicates**: `and(...)`, `or(...)`, `not(...)`
- **I/O**: `print(...)`, `print_each(...)`

### Active Compatibility Aliases

These canonical forms are preferred; aliases remain supported for compatibility:

| Canonical | Alias | Usage notes |
| --- | --- | --- |
| `drop_front(...)` | `tail(...)` | Array rest-view, with optional count arg |
| `drop_back(...)` | `drop_last(...)` | Array trailing-drop, with optional count arg |
| `flat(...)` | `flatten(...)` | List-context splicing |
| `array_copy(...)` | `array_values(...)` | Array snapshot |
| `declare(array, ...)` | `declare(a, ...)` | Declare shorthand |
| `declare(scalar, ...)` | `declare(s, ...)` | Declare shorthand |
| `declare(hash, ...)` | `declare(h, ...)` | Declare shorthand |
| `return(...)` | `return_a(...)`, `return_m(...)`, `return_ma(...)`, `return_imatch(...)`/`return_im(...)` | Legacy tagged return helpers |

## Decisions

- `2026-05-17`: Created task tree. Method-like DSL migration track was `in progress` in ROADMAP_V2.md without a task tree file. Activated with 5 leaves covering the known remaining work: compatibility alias retirement policy, legacy return-helper cleanup, accumulator audit, missing features inventory, and cross-nesting parity deferral.

## Open Questions

- Are there concrete missing DSL features beyond the already-landed helper families? (Inventory leaf .4 will answer.)
- Should convention-based accumulators (`$retv`, implicit rule-level array) get explicit helper equivalents, or remain as supported conventions?
- What is the concrete retirement timeline for each compatibility alias? (Leaf .1 will establish criteria.)

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-05-17` | `METHOD-LIKE-DSL-MIGRATION.2` | Audited 4 categories of legacy return-helper references. ~15 incidental in lazy-load tests (preserved), ~11 intentional compat infra tests (preserved), ~6 book refs (already documented), ~15 USER_GUIDE refs (authoritative). Zero migrations needed. Audit in DEVELOPMENT_NOTES.md. | Pass — cleanup complete, frontier → .3. |
| `2026-05-17` | `METHOD-LIKE-DSL-MIGRATION.1` | Audited 11 aliases across 7 implementation files. 19/19 shipped specs use zero aliases. Policy in DEVELOPMENT_NOTES.md with 6-step retirement process, alias inventory (11 entries), implementation layer table, two retirement tiers (short-term: 4 aliases, medium-term: 4 legacy return helpers). declare(a/s/h) retained as ergonomic shorthand. | Pass — policy complete, frontier → .2. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `METHOD-LIKE-DSL-MIGRATION.2` | `pending` | — |
| `METHOD-LIKE-DSL-MIGRATION.1` | `pending` | — |

## Changelog

- `2026-05-17`: Completed METHOD-LIKE-DSL-MIGRATION.2 — legacy return-helper cleanup. 4 categories audited, zero migrations needed. Active frontier: `.3`.
- `2026-05-17`: Completed METHOD-LIKE-DSL-MIGRATION.1 — compatibility alias retirement policy audit. 11 aliases inventoried, policy in DEVELOPMENT_NOTES.md. Active frontier: `.2`.
- `2026-05-17`: Created task tree for Method-like DSL migration track (was `in progress` in ROADMAP_V2.md without task-tree ownership). 5 leaves defined covering compatibility aliases, legacy return helpers, accumulator audit, missing features inventory, and cross-nesting parity deferral.
