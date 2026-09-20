# RUST-DEPENDENCY-WARNING-ZERO: Eliminate canonical Rust dependency warning noise

**Direct dependency boundary:** LinkedSpec integrates only with RGX. RGX's
published integration document, public APIs and contracts are the sole authority.
RGX owns PGEN and all transitive preparation; no separate PGEN procedure or
internal dependency knowledge belongs in LinkedSpec. Reports go to RGX.

## Metadata

- Tree ID: `RUST-DEPENDENCY-WARNING-ZERO`
- Status: `proposed` / non-blocking; intake `.0` focused-signoff-complete
- Roadmap lane: `Repository quality / Rust dependency and generated-source hygiene`
- Created: `2026-09-04`
- Last updated: `2026-09-20`
- Owner: repo-local workflow

## Goal

Achieve warning-clean maintained Rust builds through LinkedSpec-owned fixes and
upstream-owned dependency repairs. RGX and PGEN are black boxes: use only RGX's
published interfaces/contracts, observe build output, and prepare reports for RGX.
Do not inspect or analyze implementation, reconstruct internal procedures, apply
submodule changes, or change pins. The September20 director boundary overrides
all contrary historical plans. No dependency implementation assumptions are retained.

## Non-Goals

- Do not apply source-changing tools to RGX/PGEN or investigate their implementation.
- Do not hide warnings through global `RUSTFLAGS=-Awarnings`, crate-wide `allow` attributes, stderr filtering, or
  reduced canonical coverage.
- Do not change `.spec` language semantics, parser behavior, runtime results, generated-state formats, or backend
  capability claims merely to silence diagnostics.
- Do not make this non-blocking hygiene program preempt the active Lua `map_leaves!` parity frontier.

## Acceptance Criteria

- A repository-local, reproducible warning census records exact commands, toolchain identity, warning classes,
  counts, public command/environment identity, and the pinned dependency revisions.
- Dependency findings have reproducible public-interface reports and upstream-owned resolutions;
  LinkedSpec-owned findings have local task-owned fixes. No internal dependency recipe is inferred.
- Warning cleanup preserves all existing Rust and cross-backend semantic contracts and exact generated carriers.
- Maintained Rust build/check/test surfaces pass with warnings denied, without broad suppression or stderr masks.
- A focused recurring guard detects warning reintroduction; canonical CI and its storage/relocation proof pass.
- Task tree, roadmaps, architecture/live status, Knowledge Map, mdBook where relevant, and bounded continuity docs
  stay synchronized; every completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `RUST-DEPENDENCY-WARNING-ZERO`
  Status: `proposed` / non-blocking
  Goal: Eliminate warning noise from every maintained Rust dependency and generated-source build used by LinkedSpec.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`

- ID: `RUST-DEPENDENCY-WARNING-ZERO.0`
  Status: `done` / `focused-signoff-complete` (activated 2026-09-04 from exact clean Lua write-vivification
    commit `7ed47a0a1104d984967808c98f52a3e1d5031520`; no push)
  Goal: Durably own the director-requested warning cleanup and freeze a safe implementation split.
  Acceptance: Record the reproduced baseline, dependency/pin boundary, prohibited suppression shortcuts, separate
    upstream-report and LinkedSpec-owned repair leaves, zero-warning enforcement outcome, and non-blocking return to
    Lua `.19.6.2`; synchronize task/roadmap/live/Knowledge/continuity surfaces without changing build behavior.
  Verification tier: `focused` — planning and durable defect ownership only; no Rust source, dependency pin,
    generator, generated artifact, CI behavior, or runtime semantics change.
  Focused checks: task metadata/index; Knowledge Map regeneration/check; roadmap/live/history/Memory alignment;
    README-routing and memory doctrines; mdBook source review or render if the sole-facing project status changes;
    whitespace; clean atomic commit.
  Canonical trigger: none — this intake changes only planning, status, retrieval, and continuity documentation; it
    does not move code, generated formats, dependency pins, public contracts, gates, or infrastructure.
  Signoff evidence: multiple clean canonical carriers independently reproduced the 1,870-`pgen` / 26-`rgx-core`
    output baseline both within and outside the outer execution sandbox; the unchanged authorized `.19.6.1`
    canonical run passed through exact receipt and committed clean at `7ed47a0a`. Gitlink/nested-repository
    inspection proves the upstream integration boundary. The task tree records the warning-clean objective and public output baseline;
    implementation-specific dependency plans were removed on September20. The Knowledge card now
    preserves the public integration boundary. Task metadata passes 1,732/1,732 unique IDs and all partition/
    closed-marker checks; Knowledge regenerates at 935 facts / 7,942 keys; Memory is 59 lines; all 49
    document-history segments reconstruct; README routing passes 20 surfaces / 62 routes / 32 mutations; the
    mdBook renders 82 files / 15.7 MiB and the exact status entry is present; generated output is removed.
    History pressure, memory architecture, doctrines, and whitespace pass before commit. No Rust source,
    dependency pin, generator, generated artifact, CI behavior, or runtime semantics changed.
  Verification: `focused-signoff-complete`
  Commit: `RUST-DEPENDENCY-WARNING-ZERO.0 - own Rust warning cleanup`

- ID: `RUST-DEPENDENCY-WARNING-ZERO.1`
  Status: `pending`
  Goal: Capture observable warning output from documented build interfaces.
  Dependencies: `.0`
  Acceptance: Record command, toolchain, pins, exit status and warnings from a warranted public build.
    Do not equate repeated output with distinct root causes. Route dependency reports upstream without
    source inspection; separate LinkedSpec-owned diagnostics for local repair.
  Verification: `pending`
  Commit: `RUST-DEPENDENCY-WARNING-ZERO.1 - census Rust warnings`

- ID: `RUST-DEPENDENCY-WARNING-ZERO.2`
  Status: `pending`
  Goal: Track upstream resolution of PGEN warnings visible through supported builds.
  Dependencies: `.1`
  Acceptance: Prepare a self-contained public RGX-command report with environment and observed output.
    Record upstream response and published fix status; verify via the public interface when available.
    Do not inspect or modify PGEN implementation or change its pin.
  Verification: `pending`
  Commit: `RUST-DEPENDENCY-WARNING-ZERO.2 - track RGX dependency warning resolution`

- ID: `RUST-DEPENDENCY-WARNING-ZERO.3`
  Status: `pending`
  Goal: Track upstream handling of remaining PGEN build-warning reports.
  Dependencies: `.1`
  Acceptance: Let the upstream maintainer determine internal ownership and remedy. Preserve observable
    reproduction and published response, without generator investigation, output rewriting or internal
    assumptions. Verify any delivered resolution only through the supported public build and consumer API.
  Verification: `pending`
  Commit: `RUST-DEPENDENCY-WARNING-ZERO.3 - verify remaining upstream warning reports`

- ID: `RUST-DEPENDENCY-WARNING-ZERO.4`
  Status: `pending`
  Goal: Track upstream resolution of RGX warnings visible through supported builds.
  Dependencies: `.1`
  Acceptance: Report public command, environment and observable warning output. Record the upstream
    response and verify published behavior; do not inspect or modify RGX implementation or change pins.
  Verification: `pending`
  Commit: `RUST-DEPENDENCY-WARNING-ZERO.4 - verify upstream RGX warning resolution`

- ID: `RUST-DEPENDENCY-WARNING-ZERO.5`
  Status: `pending`
  Goal: Repair census-owned warnings in LinkedSpec's direct Rust crates and maintained tests.
  Dependencies: `.1`
  Acceptance: Remove remaining warnings rooted in `rust/linkedspec-core`, `rust/linkedspec-runtime`, their binaries,
    integration tests, and emitted-source harnesses; preserve all typed carriers and runtime semantics; do not
    classify dependency warnings as direct-crate success.
  Verification: `pending`
  Commit: `RUST-DEPENDENCY-WARNING-ZERO.5 - clean LinkedSpec Rust warnings`

- ID: `RUST-DEPENDENCY-WARNING-ZERO.6`
  Status: `pending`
  Goal: Verify upstream-published resolutions through supported consumer interfaces.
  Dependencies: `.2`, `.3`, `.4`, `.5`
  Acceptance: Check public release notes/contracts and run the documented build plus native consumer
    tests when the required dependency version is supplied. Do not change pins or modify submodule code.
    Preserve original nested edits and report unresolved upstream issues without false closure.
  Verification: `pending`
  Commit: `RUST-DEPENDENCY-WARNING-ZERO.6 - verify supplied dependency resolutions`

- ID: `RUST-DEPENDENCY-WARNING-ZERO.7`
  Status: `pending`
  Goal: Enforce and independently close the zero-warning canonical Rust boundary.
  Dependencies: `.6`
  Acceptance: Add a focused repository-local warning guard that fails on any maintained Rust warning without
    suppressing output; register it at the appropriate doctrine/CI cadence; independently rerun the exact census,
    all affected published Rust/cross-backend contracts, project-data storage/relocation proof, mdBook,
    Knowledge, doctrines, and receipt-bound canonical CI; close the tree only at zero warnings and a clean commit.
  Verification: `pending`
  Commit: `RUST-DEPENDENCY-WARNING-ZERO.7 - enforce zero Rust warnings`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `.1` | `pending` / non-blocking | Public warning-output census precedes upstream reporting, after explicit future activation. |

## Baseline Evidence

- Completed public build logs repeatedly report1870 pgen and26 rgx-core warnings.
  These are output counts, not unique defect counts or an internal causal model.
- The original nested source edits and dependency pins remain unchanged.
- The upstream RGX maintainer owns transitive warning diagnosis and repair.
  LinkedSpec reports public commands/results and verifies published resolutions.

## Decisions

- 2026-09-04: Own the warning-clean outcome without suppressing diagnostics.
- 2026-09-20: The director prohibits RGX/PGEN implementation inspection or changes.
  Remove internal repair assumptions. Existing task IDs retain public observation,
  upstream-report and result-verification responsibilities only, except `.5`,
  which may repair LinkedSpec-owned code.

## Open Questions

- Which observable warnings remain after an upstream-published resolution?
- What LinkedSpec-owned fixes or cache-retention improvements are independently
  warranted by public build results? No dependency implementation inference.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-09-04` | `.0` | Git-boundary inspection; task metadata 1,732 IDs; Knowledge 935/7,942; Memory 59; history 49; README routing 20/62/32; rendered mdBook 82 files; memory/doctrine/whitespace checks | `PASS` — durable non-blocking ownership; no executable or pin movement; return to Lua `.19.6.2` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.0` | `RUST-DEPENDENCY-WARNING-ZERO.0 - own Rust warning cleanup` | Prepared from clean `7ed47a0a`; no push |

## Changelog

- `2026-09-04`: Created from the director-requested durable ownership of the repeatedly reproduced canonical Rust
  dependency warning stream; implementation remains non-blocking behind current Lua parity.
- `2026-09-04`: Intake `.0` focused-signoff-complete; `.1` remains durably queued and PNT returns to Lua `.19.6.2`.
