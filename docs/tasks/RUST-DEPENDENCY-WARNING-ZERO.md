# RUST-DEPENDENCY-WARNING-ZERO: Eliminate canonical Rust dependency warning noise

## Metadata

- Tree ID: `RUST-DEPENDENCY-WARNING-ZERO`
- Status: `proposed` / non-blocking; intake `.0` focused-signoff-complete
- Roadmap lane: `Repository quality / Rust dependency and generated-source hygiene`
- Created: `2026-09-04`
- Last updated: `2026-09-04`
- Owner: repo-local workflow

## Goal

Make every maintained Rust build used by LinkedSpec's canonical gate warning-clean, including the pinned `rgx`
submodule, its nested `pgen` dependency, generated parser output, and LinkedSpec's direct Rust crates. Repair causes
at their authoritative authored or generator source, regenerate deterministically, update the pinned dependency,
and enforce the zero-warning boundary without suppressing actionable diagnostics.

## Non-Goals

- Do not apply `cargo fix` indiscriminately or hand-edit generated parser artifacts whose source is a generator.
- Do not hide warnings through global `RUSTFLAGS=-Awarnings`, crate-wide `allow` attributes, stderr filtering, or
  reduced canonical coverage.
- Do not change `.spec` language semantics, parser behavior, runtime results, generated-state formats, or backend
  capability claims merely to silence diagnostics.
- Do not make this non-blocking hygiene program preempt the active Lua `map_leaves!` parity frontier.

## Acceptance Criteria

- A repository-local, reproducible warning census records exact commands, toolchain identity, warning classes,
  counts, authored/generated ownership, and the pinned `rgx`/nested-`pgen` commits.
- Every warning is repaired at the correct authority: authored `pgen`, parser generator/template, `rgx-core`, or
  direct LinkedSpec crate/test source. Generated artifacts remain byte-fresh after regeneration.
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
    authored/generator/dependency/direct-crate leaves, zero-warning enforcement outcome, and non-blocking return to
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
    inspection proves the upstream integration boundary. The new task tree separates census, authored `pgen`,
    generator/generated `pgen`, `rgx-core`, direct LinkedSpec, pin integration, and enforcement; the Knowledge
    card preserves the searchable causal fact. Task metadata passes 1,732/1,732 unique IDs and all partition/
    closed-marker checks; Knowledge regenerates at 935 facts / 7,942 keys; Memory is 59 lines; all 49
    document-history segments reconstruct; README routing passes 20 surfaces / 62 routes / 32 mutations; the
    mdBook renders 82 files / 15.7 MiB and the exact status entry is present; generated output is removed.
    History pressure, memory architecture, doctrines, and whitespace pass before commit. No Rust source,
    dependency pin, generator, generated artifact, CI behavior, or runtime semantics changed.
  Verification: `focused-signoff-complete`
  Commit: `RUST-DEPENDENCY-WARNING-ZERO.0 - own Rust warning cleanup`

- ID: `RUST-DEPENDENCY-WARNING-ZERO.1`
  Status: `pending`
  Goal: Build the exact repository-local warning census and ownership map before any warning repair.
  Dependencies: `.0`
  Acceptance: Capture pinned commits and toolchain; run each maintained Rust build/check/test route with machine-
    readable diagnostics under repository-local project storage; classify every warning by crate, lint, authored
    versus generated origin, generator authority, duplication factor, and safe remediation class; prove the
    observed headline counts are not mistaken for unique root causes; split further before implementation if one
    leaf would exceed a safe review boundary.
  Verification: `pending`
  Commit: `RUST-DEPENDENCY-WARNING-ZERO.1 - census Rust warnings`

- ID: `RUST-DEPENDENCY-WARNING-ZERO.2`
  Status: `pending`
  Goal: Repair authored `pgen` warning causes in bounded, behavior-preserving slices.
  Dependencies: `.1`
  Acceptance: Remove only census-owned warnings rooted in authored `rgx/subs/pgen/rust` source; preserve parser,
    generator, corpus, and public API behavior; use narrow justified attributes only where a real conditional-
    compilation or compatibility obligation makes code intentionally inactive; commit upstream changes and keep
    the nested dependency boundary recoverable.
  Verification: `pending`
  Commit: `RUST-DEPENDENCY-WARNING-ZERO.2 - clean authored pgen warnings`

- ID: `RUST-DEPENDENCY-WARNING-ZERO.3`
  Status: `pending`
  Goal: Repair generator/template causes and deterministically regenerate warning-clean `pgen` parser sources.
  Dependencies: `.1`, `.2`
  Acceptance: Trace generated warnings to their authoritative generator/template; repair the authority rather than
    generated leaves; regenerate all affected artifacts; prove byte freshness/idempotence, exact parser behavior,
    and zero census-owned generated warnings across every maintained generated parser.
  Verification: `pending`
  Commit: `RUST-DEPENDENCY-WARNING-ZERO.3 - clean generated pgen warnings`

- ID: `RUST-DEPENDENCY-WARNING-ZERO.4`
  Status: `pending`
  Goal: Repair the census-owned `rgx-core` warning classes without semantic regression.
  Dependencies: `.1`
  Acceptance: Resolve architecture-specific unreachable paths, unused/dead owners, missing documentation, and all
    other classified `rgx-core` diagnostics at their real causes; preserve scalar/SIMD behavior and every regex,
    capture, parser, VM, and LinkedSpec integration contract; keep intentional platform branches explicit and
    narrowly justified.
  Verification: `pending`
  Commit: `RUST-DEPENDENCY-WARNING-ZERO.4 - clean rgx core warnings`

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
  Goal: Integrate the warning-clean upstream commits and update LinkedSpec's pinned `rgx` dependency atomically.
  Dependencies: `.2`, `.3`, `.4`, `.5`
  Acceptance: Verify clean nested `pgen` and `rgx` repositories at explicit commits, update the parent `rgx` and
    LinkedSpec gitlinks, reproduce the zero-warning census from a clean checkout/carrier, and retain exact build,
    generated-source, corpus, CLI, runtime, storage, and relocation behavior.
  Verification: `pending`
  Commit: `RUST-DEPENDENCY-WARNING-ZERO.6 - pin warning-clean Rust dependencies`

- ID: `RUST-DEPENDENCY-WARNING-ZERO.7`
  Status: `pending`
  Goal: Enforce and independently close the zero-warning canonical Rust boundary.
  Dependencies: `.6`
  Acceptance: Add a focused repository-local warning guard that fails on any maintained Rust warning without
    suppressing output; register it at the appropriate doctrine/CI cadence; independently rerun the exact census,
    all affected Rust/cross-backend contracts, generated freshness, project-data storage/relocation proof, mdBook,
    Knowledge, doctrines, and receipt-bound canonical CI; close the tree only at zero warnings and a clean commit.
  Verification: `pending`
  Commit: `RUST-DEPENDENCY-WARNING-ZERO.7 - enforce zero Rust warnings`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `.1` | `pending` / non-blocking | Exact unique-root-cause census is required before warning cleanup, after explicit future activation. |

## Baseline Evidence

- During receipt-bound canonical verification of `FUTURE-PARITY-BACKLOG.19.6.1` on 2026-09-04, multiple clean
  Rust carriers independently reported `pgen (lib) generated 1870 warnings`, with Cargo offering 1,360 automated
  suggestions. The stream included both authored `src/ast_pipeline/*` diagnostics and generated parser diagnostics;
  therefore 1,870 is a build-output count, not yet a unique-root-cause count.
- The same carriers reported 26 warnings from `rgx-core`, including architecture-specific unreachable expressions,
  unused/dead owners, and missing documentation. Earlier task evidence also records separate direct-runtime lint
  baselines; `.1` must measure rather than merge these counts by assumption.
- The warning baseline reproduced both inside and outside the outer execution sandbox. The sandboxed canonical run's
  later status 71 was the separately known nested-`sandbox-exec` restriction; the unchanged authorized rerun passed.
- LinkedSpec tracks `rgx` as gitlink `8763a0e6bea97879f027237439d57725f83ead23`; `rgx/subs/pgen` is a nested Git
  dependency. Cleanup therefore requires explicit upstream commits and pin integration, not hidden main-tree edits.

## Decisions

- `2026-09-04`: Own the warning set as a defect-remediation program rather than accepting recurring canonical noise.
- `2026-09-04`: Keep the tree proposed/non-blocking after intake; resume Lua `.19.6.2` before implementation unless
  the director reprioritizes it.
- `2026-09-04`: Treat warning elimination as causal repair. Broad suppression, output filtering, and blind bulk
  fixes do not satisfy the task.
- `2026-09-04`: Separate authored `pgen`, generated `pgen`, `rgx-core`, direct LinkedSpec, dependency-pin, and final
  enforcement work so each commit is reviewable and recoverable.

## Open Questions

- `.1` must determine the unique warning/root-cause distribution and whether further per-lint or per-generator
  subdivision is required; this does not block intake ownership or current Lua parity work.
- `.1` must identify which upstream repositories/remotes accept the `pgen` and `rgx-core` commits before `.2-.4`;
  no push or external publication is authorized by this planning leaf.

## Blockers

- None for intake `.0` or resuming Lua parity. Upstream integration details are intentionally deferred to `.1`.

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
