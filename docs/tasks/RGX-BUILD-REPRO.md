# RGX-BUILD-REPRO: Historical public build reproduction and upstream resolution

## Metadata

- Tree ID: `RGX-BUILD-REPRO`
- Status: `done`
- Roadmap lane: `Phase 9 — Rust variant (rgx evaluation unblock)`
- Created: `2026-06-15`
- Last updated: `2026-09-20` (remove implementation-derived dependency notes)
- Owner: repo-local workflow
- Upstream: https://github.com/rdje/rgx

## Goal

Preserve the historical cold-checkout public build report and published upstream
resolution. RGX/PGEN are black boxes. Source-level analysis, suggested internal
patches and implementation-derived notes were removed by director instruction.
This record supplies no permission to inspect or modify dependency implementation.

## Task Tree

- ID: `RGX-BUILD-REPRO`
  Status: `done`
  Goal: Reproduce public RGX build failures and record the upstream-supported resolution.
  Children: `.1`

- ID: `RGX-BUILD-REPRO.1`
  Status: `done`
  Goal: Provide self-contained public-command reproduction for cold-checkout build failures.
  Acceptance: Record exact revision, toolchain, command and observable failure; receive the upstream build contract and verify it.
  Verification: Upstream BUILD-FLOW published the root make entrypoint and docs/INTEGRATION.md. A cold-checkout make succeeded on macOS arm64 with Rust1.95.0 at RGX8763a0e6. The default build and documented alternative were reported resolved in the June15 closeout. No fresh alternative-feature verification is claimed here.
  Commit: `8763a0e` (RGX upstream); historical LinkedSpec pin adoption b771c7b→8763a0e.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | — | — | Historical tree complete; no implementation work authorized. |

## Public observations and resolution

At original RGX `b771c7b872675a333b2c42571249ba7b36435d2f`, the downstream
reported failure of a fresh default Cargo build due to an unavailable generated
input, and failure of the documented alternative-feature build. The upstream
maintainer supplied BUILD-FLOW.1-.4 and RGX
`8763a0e6bea97879f027237439d57725f83ead23`.

The published consumer entry point is `make -C path/to/rgx bootstrap`, followed
by the consuming workspace's Cargo build. RGX's own `make` prepares and builds
its workspace. Read `rgx/docs/INTEGRATION.md` for requirements and supported use;
do not reconstruct the dependency's internal build process.

The historical verification environment was Rust1.95.0 on macOS26.1 arm64.
Its successful cold-build observation is dated evidence, not a guarantee about
another revision, platform, feature configuration or future release.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| 2026-06-15 | `.1` | Public cold-checkout builds | Failures reported |
| 2026-06-15 | `.1` | Upstream documented make entrypoint at8763a0e | Passed; original issue closed |
| 2026-09-20 | Integration `.8.3` | Director-requested knowledge cleanup | Internal dependency notes removed; original outcome and public authority retained |

## Changelog

- 2026-06-15: Original report and upstream-supported resolution completed.
- 2026-09-20: Remove internal implementation analysis and proposed patches. The
  public-interface-only boundary in AGENTS.md governs all future dependency work.
