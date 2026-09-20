# RGX-CONSUMER-BUILD-REPORTS: Public build reports and upstream resolutions

**Direct dependency boundary:** LinkedSpec integrates only with RGX. RGX's
published integration document, public APIs and contracts are the sole authority.
RGX owns PGEN and all transitive preparation; no separate PGEN procedure or
internal dependency knowledge belongs in LinkedSpec. Reports go to RGX.

## Metadata

- Tree ID: `RGX-CONSUMER-BUILD-REPORTS`
- Status: `pending` / upstream-owned and non-blocking for integration documentation
- Roadmap lane: `Rust downstream integration / upstream issue follow-up`
- Created: `2026-09-20`
- Last updated: `2026-09-20`
- Owner: LinkedSpec public-interface reporting; RGX maintainer owns diagnosis/repair

## Goal

Track observable failures of RGX's published consumer interface through upstream
resolution and consumer verification. RGX/PGEN are black boxes: no implementation
inspection, analysis, reconstruction, source edits or pin changes are authorized.

## Task Tree

- ID: `RGX-CONSUMER-BUILD-REPORTS`
  Status: `pending`
  Goal: Resolve public build reports through upstream-published fixes.
  Children: `.1`

- ID: `RGX-CONSUMER-BUILD-REPORTS.1`
  Status: `pending`
  Goal: Resolve the misleading bootstrap progress message reported as ARCHOGEN/LS-004.
  Scope: Public RGX make bootstrap command, command environment, exit status and output only.
  Dependencies: Integration `.8.3` supplies a self-contained public-interface report.
  Acceptance: Preserve exact public reproduction and observed status; receive an upstream response or published resolution; verify through the supported interface and record remaining limitations. Do not claim a fixed issue merely because a downstream guide uses the correct entry point. Posting a message or issue requires explicit director authorization; preparation of the repository-local report is authorized.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `RGX-CONSUMER-BUILD-REPORTS.1` | `pending` | Public-interface evidence and upstream response are required; no local dependency repair. |

## Decisions

- Integration documentation may describe verified supported use while this upstream
  report remains open. Neither documentation delivery nor a successful normal build
  establishes correction of a failure-path progress message.
- All dependency implementation authority remains upstream. Published interfaces,
  contracts and observable consumer results are the only local evidence surface.
