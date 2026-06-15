# RGX-ADOPTION: Adopt rgx as the regex engine in the Rust variant

## Metadata

- Tree ID: `RGX-ADOPTION`
- Status: `done`
- Roadmap lane: `Phase 9 — Rust variant (rgx adoption)`
- Created: `2026-06-15`
- Last updated: `2026-06-15`
- Owner: repo-local workflow
- Dependency: rgx submodule at `8763a0e` (verified building)

## Goal

Replace the `regex` crate with `rgx-core` in the Rust LinkedSpec runtime,
migrating the `regex_engine` module in `helpers.rs` to use rgx's API.
All 39 existing tests must pass with the rgx backend.

## Non-Goals

- Does NOT add PCRE2-only regex features to LinkedSpec specs (that's a follow-on).
- Does NOT change the regex dispatch algorithm (iterate alternatives, select earliest).
- Does NOT add a code-gen or compiled-mode path.
- Does NOT publish linked-spec crates to crates.io.

## Acceptance Criteria

- `rgx-core` replaces `regex` as the sole regex dependency in `linkedspec-runtime`.
- `helpers.rs::regex_engine` API migrated: `Regex::new` → `Regex::compile`, `.find` → `.find_first`, `.find_at` → `.find_first_at`, captures/extract adapted to rgx `Captures`/`MatchResult` types.
- `cargo test -p linkedspec-runtime` passes (35 unit + 4 integration).
- `cargo test --workspace` passes (39 total).
- rgx submodule pin stable at `8763a0e`.

## Task Tree

- ID: `RGX-ADOPTION`
  Status: `active`
  Goal: `Adopt rgx-core as the regex engine in the Rust variant, replacing the regex crate.`
  Children: `.1, .2, .3`

- ID: `RGX-ADOPTION.1`
  Status: `done`
  Goal: `Swap dependency: replace regex with rgx-core in workspace Cargo.toml and linkedspec-runtime Cargo.toml. Migrate regex_engine module API calls (Regex::new → Regex::compile, .find → .find_first, .find_at → .find_first_at, captures/extract functions adapted to rgx Captures/MatchResult types).`
  Acceptance: `cargo build --workspace succeeds. No regex crate in dependency tree. rgx-core compiles and links.`
  Verification: `cargo build succeeded; 0 regex crate references remain in linkedspec source; rgx-core v0.1.0 linked`
  Commit: `pending`

- ID: `RGX-ADOPTION.2`
  Status: `done`
  Goal: `Verify all tests pass with rgx backend. Fix any behavioral differences (e.g., match result field access, capture group iteration, named capture lookup).`
  Acceptance: `cargo test --workspace: all tests PASS, zero failures.`
  Verification: `126/126 PASS (79 core + 8 types + 35 runtime + 4 integration), zero failures, zero regressions`
  Commit: `pending`

- ID: `RGX-ADOPTION.3`
  Status: `done`
  Goal: `Finalization: update live docs (CHANGES.md, DEVELOPMENT_NOTES.md, MEMORY.md, LIVE_ACHIEVEMENT_STATUS.md), update RUST-FUNCTIONAL-PARITY task tree (.2.4 status → done), close tree.`
  Acceptance: `Live docs reflect rgx adoption. Task tree moved to Completed.`
  Verification: `CHANGES.md, DEVELOPMENT_NOTES.md, LIVE_ACHIEVEMENT_STATUS.md, MEMORY.md updated. RUST-FUNCTIONAL-PARITY.2.4 → done. Tree closed.`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | — | — | Tree complete |

## Decisions

- `2026-06-15`: **Adopt now.** rgx builds on cold clone (`make`), full engine verified. The `.2.3` DEFER conditions are satisfied. Migration is mechanical (4 API renames + captures adaptation).

## Open Questions

- None at this time.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-15` | `.1` | `cargo build --workspace` with rgx-core; zero `regex::` crate refs remain | PASS |
| `2026-06-15` | `.2` | `cargo test --workspace` — 126/126 PASS, zero failures | PASS |
| `2026-06-15` | `.3` | Live docs updated, RUST-FUNCTIONAL-PARITY.2.4 → done, tree closed | PASS |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1` | `ca40805` — "Feat: RGX-ADOPTION.1/.2 — swap regex→rgx-core, migrate API, 126/126 tests PASS" | Code + test verification |
| `.2` | (bundled with .1) | Test verification — all 126 pass |
| `.3` | `pending` | Live docs + finalization |

## Changelog

- `2026-06-15`: Created task tree. Follows RUST-FUNCTIONAL-PARITY.2.3 evaluation (DEFER → now unblocked) and RGX-BUILD-REPRO build fix verification.
- `2026-06-15`: **Closed.** All 3 leaves done. rgx-core is the active regex engine in the Rust variant. 126/126 tests PASS. Tree complete.
