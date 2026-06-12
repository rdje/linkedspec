# LINKEDSPEC-ENHANCEMENTS: LinkedSpec Quality Enhancements

## Metadata

- Tree ID: `LINKEDSPEC-ENHANCEMENTS`
- Status: `active`
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
  Status: `pending`
  Goal: `Grow Knowledge Map — write 10+ new durable fact cards covering OwnerDispatch, RuntimeContext, scanner families, CompilerState, accumulator convention, blind-call contract, BootstrapSpec dual-path, plugin transition status, EmitContext registry, and medium-term alias deferral.`
  Acceptance: `10+ new fact cards under docs/knowledge/ with valid front-matter (answers, date, status, evidence, reverify). KNOWLEDGE_MAP.md regenerated. check_knowledge_map.sh passes.`
  Verification: `pending`
  Commit: `pending`

- ID: `LINKEDSPEC-ENHANCEMENTS.2`
  Status: `pending`
  Goal: `Enforce plugin deprecation in regression baseline. Add a subtest that scans all shipped .plg files for direct LinkedSpec::get_plugin(...), LinkedSpec::run_plugin(...), and LinkedSpec::dispatch_plugin_autoload_name(...) calls and rejects any new occurrences.`
  Acceptance: `New regression subtest passes (zero existing violations). Any future .plg file that adds a direct plugin-bridge call fails the gate. Phase0 full baseline passes.`
  Verification: `pending`
  Commit: `pending`

- ID: `LINKEDSPEC-ENHANCEMENTS.3`
  Status: `pending`
  Goal: `Split phase0_regression.t into focused test modules. Extract major subtest categories (scanner, lowering, lifecycle, parser-modes, emit-context, compatibility, plugin-migration) into t/ subdirectory. Master file becomes a thin loader.`
  Acceptance: `All 1004 tests pass. Test modules under t/ are self-contained with their own plan(). Master file loads them via require or do. tools/run_ci_local.sh adapts if needed.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `LINKEDSPEC-ENHANCEMENTS.1` | `pending` | Knowledge Map growth: lowest risk, immediate value for future sessions. |
| 2 | `LINKEDSPEC-ENHANCEMENTS.2` | `pending` | Plugin lock: prevents regression, small test addition. |
| 3 | `LINKEDSPEC-ENHANCEMENTS.3` | `pending` | Test split: largest, depends on stable baseline from .1 and .2. |

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
| `pending` | `pending` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `LINKEDSPEC-ENHANCEMENTS.1` | `pending` | — |
| `LINKEDSPEC-ENHANCEMENTS.2` | `pending` | — |
| `LINKEDSPEC-ENHANCEMENTS.3` | `pending` | — |

## Changelog

- `2026-06-12`: Created task tree with 3 leaves.
