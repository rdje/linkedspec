# CONSUMER-REPORT-DELIVERY: Unblock reported consumer integration

## Metadata

- Tree ID: `CONSUMER-REPORT-DELIVERY`
- Status: `active`
- Roadmap lane: `SEMULITH / ARCHOGEN consumer blockers and delivery`
- Created: `2026-09-23`
- Last updated: `2026-09-23`
- Owner: repo-local workflow; RGX owns dependency repairs

## Goal

Make the verified LinkedSpec-owned report remedies available to consumers, with
exact migration commands and honest unresolved status. The director prioritizes
blocked SEMULITH/ARCHOGEN consumers over separately discovered validator work.

## Acceptance Criteria

- Reconcile all ten source-qualified reports against task/KM/ADR authority.
- Verify the delivered consumer paths using current source and authored expectations.
- Publish the fixes after exact canonical proof, leaving a clean durable handoff.
- Pursue ARCHOGEN/LS-004 only through RGX's published interface; preserve upstream
  repair ownership and obtain explicit authorization before posting a message.
- Do not claim downstream application acceptance or update either consumer's files.

## Task Tree

- ID: `CONSUMER-REPORT-DELIVERY`
  Status: `active`
  Goal: Deliver local fixes and resolve the remaining consumer report through its proper owner.
  Children: `CONSUMER-REPORT-DELIVERY.1`, `CONSUMER-REPORT-DELIVERY.2`, `CONSUMER-REPORT-DELIVERY.3`

- ID: `CONSUMER-REPORT-DELIVERY.1`
  Status: `done`
  Goal: Verify current local consumer remedies and prepare an actionable delivery handoff.
  Dependencies: Clean f60a70df37159c0e42d66ee5f08a959821c7e08d; September23 director prioritization. The activation-only .86.4.3 changes were withdrawn before switching; no implementation changed.
  Verification tier: `focused`
  Focused checks: Source-qualified report hashes and task/KM/ADR reconciliation; published main identity; managed current-source Rust integration build, workspace and historical/new file consumers; exact authored report cases, public-loader path and documentation commands; memory/Knowledge/histories/book/doctrines/diff.
  Canonical trigger: None for this bounded delivery preparation; .3 owns exact final canonical verification and push after .1/.2 are committed.
  Acceptance: Identify which fixes are local versus published, give source-qualified report dispositions and explain SExprDocumentV1/sexpr_file opt-in. Preserve upstream and downstream acceptance boundaries; commit reproducible evidence without falsely closing LS-004.
  Verification: Report snapshots are unchanged: ARCHOGEN43 files/75512 bytes, manifest7d791417288694ec44c969e7bd683dbbd71f0eaac6b1740496a70dba7b719df5; SEMULITH29/26871, manifesta77e92fedc744643db03edea346d3619c60c1ac3cb20dc97ab444f7cd82ed3af. Live git ls-remote returns main87b35665e1a8e0de1f03a27e31dbd4d34d8e2d94, before the local quote/document repairs. PASS current-source locked/offline native build, three adapter tests, historical26 file values/18 groups, document37 authored cases/36 file groups and Rust public-loader37/21, workspace9 and rendered migration links/pin. All diagnostic artifacts remain repository-local; the sampled final empty test target wait is before Rust main, not a consumer failure. Memory/Knowledge/history/diff and all registered doctrines govern landing.
  Commit: `CONSUMER-REPORT-DELIVERY.1 - verify consumer remedies and migration` (this slice; base f60a70df3).

- ID: `CONSUMER-REPORT-DELIVERY.2`
  Status: `done`
  Goal: Reverify the remaining RGX public-build report and prepare its concrete upstream handoff.
  Dependencies: .1; existing RGX-CONSUMER-BUILD-REPORTS.1 and docs/upstream/rgx/bootstrap-progress-status.md remain the repair/report owners.
  Verification tier: `focused`
  Focused checks: Current published integration instructions and pinned public make bootstrap behavior, exact overall exit/output, isolated repository-local failure fixture, successful supported preparation control and unchanged source/pins. No dependency implementation inspection or internal build reconstruction.
  Canonical trigger: None; .3 owns the final delivery boundary.
  Acceptance: Distinguish the actual preparation failure from misleading progress text, preserve an actionable report, and request explicit external-post authorization only after that report is reviewable. Verification/report preparation does not close the upstream bug.
  Verification: PASS current pinned public-interface recurrence on macOS27.0/Cargo1.95/Make3.81. Fresh local empty-store failure exits2 with missing-package error and misleading seed line, without final completion. Prepared control and repeat exit0 with the public already-generated no-op message. Correct the diagnostic-only fresh-banner assumption; no implementation change. Dependency pin stays exact. Refreshed report preserves full log hashes and external-post authorization remains pending. Book/memory/Knowledge/history/diff and normal doctrines govern landing.
  Commit: `CONSUMER-REPORT-DELIVERY.2 - reverify the public RGX report` (this slice; base01b04138a).

- ID: `CONSUMER-REPORT-DELIVERY.3`
  Status: `pending`
  Goal: Run canonical acceptance and publish the completed LinkedSpec consumer fixes.
  Dependencies: .1 and .2 committed clean; unchanged tracked source and exact final staged candidate.
  Planned tier: canonical.
  Planned focused proof: Consumer handoff commands and report dispositions; clean Git and commit-message hygiene; exact canonical receipt, push and read-back of remote main.
  Planned canonical boundary: Final three-slice consumer-delivery batch and pre-push boundary.
  Acceptance: Publish a reproducible fixed revision and clear migration instructions; distinguish local public-integration proof from downstream adoption, and retain LS-004 under RGX ownership until a verified upstream remedy exists.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `CONSUMER-REPORT-DELIVERY.3` | `pending` | Run exact canonical acceptance and publish the verified LinkedSpec remedies. |

## Decisions and Boundaries

- September23: Prioritize the director's blocked consumers; preserve .86.4.3 as
  pending unrelated follow-up. The ten original reports are seven locally resolved
  requirements, one open upstream report, one withdrawn report and one no-action report.
- ADR0124 delivers strict complete documents and token kinds through a separate
  grammar and consumer. Historical Lispish remains compatible; merely rerunning
  its old adapter does not exercise the new document contract.
- RGX/PGEN remain black boxes. No external issue or message is posted without
  explicit authorization; prepared repo-local reports are already authorized.

## Evidence Pointers

- `docs/knowledge/archogen-rust-lispish-integration.md`
- `docs/decisions/0124-kind-preserving-sexpr-document.md`
- `docs/tasks/SEXPR-DOCUMENT-INTEGRATION.md`
- `docs/tasks/BACKEND-INTEGRATION-GUIDES.md` (.8.1-.8.5)
- `docs/tasks/RGX-CONSUMER-BUILD-REPORTS.md`
