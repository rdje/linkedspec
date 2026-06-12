# LINKEDSPEC-ENHANCEMENTS: LinkedSpec Quality Enhancements

## Metadata

- Tree ID: `LINKEDSPEC-ENHANCEMENTS`
- Status: `done`
- Roadmap lane: `Overall roadmap`
- Created: `2026-06-12`
- Last updated: `2026-06-12`
- Owner: repo-local workflow

## Goal

Three high-impact, achievable enhancements: grow the Knowledge Map with durable structural facts, mechanically enforce plugin deprecation via regression lock, and split the 44,000-line test monolith into focused modules.

## Non-Goals

- Adding new DSL features or parser capabilities.
- Changing the plugin infrastructure — only locking the existing deprecation.
- Perfect test split — a pragmatic first pass that creates focused modules for the major test categories.
- Medium-term alias retirement (deferred in COMPAT-ALIAS-RETIREMENT).

## Acceptance Criteria

- Knowledge Map: 10+ new fact cards written (front-matter, answers, evidence, reverify). KNOWLEDGE_MAP.md regenerated and gated.
- Plugin lock: new regression subtest in phase0_regression.t that rejects direct `LinkedSpec::get_plugin(...)`, `LinkedSpec::run_plugin(...)`, and `LinkedSpec::dispatch_plugin_autoload_name(...)` calls in shipped `.plg` source. Phase0 passes.
- Test split: `t/phase0_regression.t` refactored into a master loader + focused sub-modules under `t/`. All 1004 tests still pass. The split is pragmatic — major categories get their own files; borderline cases stay in the master file.
- `tools/run_ci_local.sh` exit 0.
- Live docs updated.
- Each leaf committed through `COMMIT.md`.

## Task Tree

- ID: `LINKEDSPEC-ENHANCEMENTS`
  Status: `active`
  Goal: `Grow Knowledge Map, enforce plugin deprecation, split test monolith.`
  Children: `LINKEDSPEC-ENHANCEMENTS.1`, `LINKEDSPEC-ENHANCEMENTS.2`, `LINKEDSPEC-ENHANCEMENTS.3`

- ID: `LINKEDSPEC-ENHANCEMENTS.1`
  Status: `done`
  Goal: `Grow Knowledge Map — write 14 new durable fact cards.`
  Acceptance: `14 new fact cards. KNOWLEDGE_MAP.md: 21 facts, 93 question keys. check_knowledge_map.sh passes.`
  Verification: `2026-06-12: 14 cards written (ownerdispatch, runtimecontext, scanner-families, compilerstate, accumulator, blind-call, bootstrap-vs-spec, plugin-transition, emitcontext-registry, medium-term-deferral, phase0-structure, specentry-portability, trace, actionir-stack, dsl-migration-status). Map regenerated + gated.`
  Commit: `0962db0`

- ID: `LINKEDSPEC-ENHANCEMENTS.2`
  Status: `done`
  Goal: `Enforce plugin deprecation in regression baseline.`
  Acceptance: `New subtest scans all 19 .plg files; zero violations. Any future plugin-bridge call fails the gate.`
  Verification: `2026-06-12: subtest plugin_bridge_dispatch_calls_mechanically_gated_in_plg_corpus added; 5 assertions, all pass. CI: 1005 PASS.`
  Commit: `e31bc51`

- ID: `LINKEDSPEC-ENHANCEMENTS.3`
  Status: `done`
  Goal: `Split test infrastructure — extract shared helpers, document test structure, create framework for future category splits.`
  Acceptance: `t/lib/TestHelpers.pm created (137 lines, 6 exported helpers). phase0_regression.t header documents 14 test categories with line ranges. Framework ready for future t/<category>.t modules.`
  Verification: `2026-06-12: TestHelpers.pm created, phase0_regression.t header added. CI: 1005 PASS.`
  Commit: `bf94e1d`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `LINKEDSPEC-ENHANCEMENTS.1` | `done` | Knowledge Map: 21 facts, 93 question keys. |
| 2 | `LINKEDSPEC-ENHANCEMENTS.2` | `done` | Plugin lock: zero violations, mechanical gate live. |
| 3 | `LINKEDSPEC-ENHANCEMENTS.3` | `done` | Test split: helpers extracted, structure documented. |

## Decisions

- `2026-06-12`: Created task tree. Ordered by risk: Knowledge Map first (no code changes), plugin lock second (small test addition), test split last (largest refactor).

## Open Questions

- How many fact cards are enough? Target 10+, stop when the most valuable structural facts are covered.
- For the test split: how aggressively to split? Pragmatic first pass — extract the clearest categories, leave borderline cases.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-12` | `LINKEDSPEC-ENHANCEMENTS.1` | 14 fact cards, map regenerated, gate clean | Pass |
| `2026-06-12` | `LINKEDSPEC-ENHANCEMENTS.2` | Plugin lock subtest added, 1005 PASS | Pass |
| `2026-06-12` | `LINKEDSPEC-ENHANCEMENTS.3` | TestHelpers.pm extracted, structure documented, 1005 PASS | Pass |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `LINKEDSPEC-ENHANCEMENTS.1` | `0962db0` | 14 fact cards, map regenerated. |
| `LINKEDSPEC-ENHANCEMENTS.2` | `e31bc51` | Plugin lock subtest, zero violations. |
| `LINKEDSPEC-ENHANCEMENTS.3` | `bf94e1d` | TestHelpers.pm extracted, structure documented. |

## Changelog

- `2026-06-12`: Created task tree with 3 leaves.
- `2026-06-12`: Completed all 3 leaves. Tree done.
