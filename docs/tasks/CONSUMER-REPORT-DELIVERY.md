# CONSUMER-REPORT-DELIVERY: Unblock reported consumer integration

## Metadata

- Tree ID: `CONSUMER-REPORT-DELIVERY`
- Status: `done` / published remedies and audited local fix ledger; LS-004 remains open
- Roadmap lane: `SEMULITH / ARCHOGEN consumer blockers and delivery`
- Created: `2026-09-23`
- Last updated: `2026-09-23`
- Owner: repo-local workflow; RGX is integration contact; affected upstream maintainers own dependency repairs

## Goal

Make the verified LinkedSpec-owned report remedies available to consumers, with
exact migration commands and honest unresolved status. The director prioritizes
blocked SEMULITH/ARCHOGEN consumers over separately discovered validator work.

## Acceptance Criteria

- Reconcile all ten source-qualified reports against task/KM/ADR authority.
- Verify the delivered consumer paths using current source and authored expectations.
- Publish the fixes after exact canonical proof, leaving a clean durable handoff.
- Pursue ARCHOGEN/LS-004 only through RGX's published interface; preserve upstream
  repair ownership and keep feedback local for the director to relay after publication.
- Do not claim downstream application acceptance or update either consumer's files.

## Task Tree

- ID: `CONSUMER-REPORT-DELIVERY`
  Status: `done`
  Goal: Deliver local fixes and pursue the remaining consumer report through its proper owner.
  Children: `CONSUMER-REPORT-DELIVERY.1`, `CONSUMER-REPORT-DELIVERY.2`, `CONSUMER-REPORT-DELIVERY.3`, `CONSUMER-REPORT-DELIVERY.4`, `CONSUMER-REPORT-DELIVERY.5`, `CONSUMER-REPORT-DELIVERY.6`

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
  Verification: PASS current pinned public-interface recurrence on macOS27.0/Cargo1.95/Make3.81. Fresh local empty-store failure exits2 with missing-package error and misleading seed line, without final completion. Prepared control and repeat exit0 with the public already-generated no-op message. Correct the diagnostic-only fresh-banner assumption; no implementation change. Dependency pin stays exact. Refreshed report preserves full log hashes. At this checkpoint external-post authorization had been requested; .4 records the subsequent director-owned relay. Book/memory/Knowledge/history/diff and normal doctrines govern landing.
  Commit: `CONSUMER-REPORT-DELIVERY.2 - reverify the public RGX report` (this slice; base01b04138a).

- ID: `CONSUMER-REPORT-DELIVERY.3`
  Status: `done`
  Goal: Run canonical acceptance and publish the completed LinkedSpec consumer fixes.
  Dependencies: .1 and .2 committed clean; unchanged tracked source and exact final staged candidate.
  Verification tier: `canonical`
  Focused checks: Consumer handoff commands and report dispositions; clean Git and commit-message hygiene; exact canonical receipt, push and read-back of remote main.
  Canonical trigger: Final three-slice consumer-delivery batch and pre-push boundary.
  Acceptance: Publish a reproducible fixed revision and clear migration instructions; distinguish local public-integration proof from downstream adoption, and retain LS-004 under RGX ownership until a verified upstream remedy exists.
  Verification: PASS tools/run_ci_local.sh, exit0; nine doctrines, both CLI66/66 routes and Phase0 1032/1032 in1113s. Twenty-five opt-in gates remain skipped. The exact staged receipt was promoted to a8d34c84595d46c24cd1820d5fc0414261706412; the clean push reused it. Live git ls-remote and origin/main both match that commit, and tested baseline f60a70df37159c0e42d66ee5f08a959821c7e08d is an ancestor. Commit body records the staged fingerprint and canonical log hash. LS-004 remains open; .4 records the director-owned relay.
  Commit: `a8d34c84595d46c24cd1820d5fc0414261706412` — `CONSUMER-REPORT-DELIVERY.3 - admit and publish consumer remedies`; published to origin/main.

- ID: `CONSUMER-REPORT-DELIVERY.4`
  Status: `done`
  Goal: Record successful publication and the director's ownership of relaying the remaining RGX feedback.
  Dependencies: .3 committed and pushed from a clean tree; remote main read-back equals a8d34c84595d46c24cd1820d5fc0414261706412. The director requests local task-tree tracking and will communicate with RGX after publication.
  Verification tier: `focused`
  Focused checks: Exact remote identity and tested-baseline ancestry; report/task/KM/resume consistency; memory architecture, Knowledge generation, bounded histories, all registered doctrines and diff hygiene. Public behavior and book migration instructions remain unchanged.
  Canonical trigger: None for this local administrative follow-up after completed canonical publication. Any later push requires canonical proof for its exact HEAD.
  Acceptance: Give the director a concrete local report and open repair owner, record the published fixes, remove the obsolete pending-permission state, and preserve public post-fix acceptance criteria. Do not post externally or claim upstream repair or downstream acceptance.
  Verification: PASS exact remote main read-back and tested-baseline ancestry at published a8d34c845. Current report/task/KM/resume pointers agree on director-owned relay and pending upstream repair. Memory architecture, Knowledge generation, both bounded-history checks, all nine registered doctrines and diff hygiene govern this focused landing; the commit body records their result. No public behavior or book migration change requires another runtime test run.
  Commit: `CONSUMER-REPORT-DELIVERY.4 - record director-owned RGX handoff` (local follow-up; base a8d34c845).

- ID: `CONSUMER-REPORT-DELIVERY.5`
  Status: `done`
  Goal: Correct the conflation of the RGX integration contact with the component blamed by ARCHOGEN/LS-004.
  Dependencies: Clean dc46151be48cd66f7bd56f5a52b84cef7fe26f4f; director questions the RGX attribution. Original caller-authorized report, retained public-command log and RGX published integration contract supply the evidence.
  Verification tier: `focused`
  Focused checks: Compare original report attribution, public failure status/output and published dependency ownership; align report/task/KM/resume/book wording; memory, Knowledge, bounded histories, book rendering, all doctrines and diff hygiene.
  Canonical trigger: None for this local documentation correction. No implementation, contract or dependency pin changes; a future push still requires exact-HEAD canonical proof.
  Acceptance: State that no RGX implementation defect has been established, the observed RGX command correctly propagates failure, and ARCHOGEN identifies PGEN bootstrap as the affected component. Keep original reporter provenance and LinkedSpec tracking ownership. Treat RGX as the integration contact; do not demand it modify its read-only PGEN dependency or claim independent internal root-cause proof.
  Verification: Original report names PGEN bootstrap; retained public output returns exit2 and no final completion; RGX published guide keeps PGEN read-only. Workspace build remedy is effe3e7b2544abf79f7786a7aa54e77b1893880e, verified as an ancestor of published origin/main; it does not fix LS-004. Report/task/KM/resume/book wording now distinguishes these facts. Focused memory/Knowledge/history/book/diff proof and all nine doctrine hooks govern landing, with results recorded in the commit body.
  Commit: `CONSUMER-REPORT-DELIVERY.5 - distinguish integration contact from defect attribution` (local follow-up; base dc46151be).

- ID: `CONSUMER-REPORT-DELIVERY.6`
  Status: `done`
  Goal: Audit all original consumer report dispositions against exact commits and distinguish the older resolved bootstrap build problem from LS-004.
  Dependencies: Clean 4e2598d1eed1001be370ccaec089922c1ce622ab; director explicitly requests task-tree, KM, ADR and Git-history evidence plus each bug's fix commit.
  Verification tier: `focused`
  Focused checks: Relevant task/KM/ADR records; commit bodies and first-party changed-path scopes; public Gitlink adoption metadata and published-main ancestry; exact ten-report mapping; memory/Knowledge/history/book/doctrines/diff.
  Canonical trigger: None for this bounded historical evidence and documentation audit. No source, dependency pin, runtime contract or checker changes. Future push requires canonical exact-HEAD proof.
  Acceptance: Name the June15 cold-build adoption c4926f871 and its upstream public resolution separately from workspace fix effe3e7b2 and September LS-004. Give each original report its actual implementation/documentation commits or explicit no-fix disposition. Distinguish opt-in document delivery, admission and publication from defect fixes, and retain original reporter provenance.
  Verification: PASS task/KM/ADR0124 and commit-body/changed-path reconciliation. RGX-BUILD-REPRO.1 and Gitlink adoption metadata identify c4926f871 as the June build closeout; a1166ee1d explicitly discards an uncommitted helper and leaves September LS-004 open. All eight relevant LinkedSpec references are ancestors of published a8d34c845. The ten-report mapping and exact hashes are in docs/knowledge/consumer-report-fix-commits.md. Memory/Knowledge/history/book/diff checks and all nine doctrine hooks govern landing; commit body records results. No dependency implementation read or pin change.
  Commit: `CONSUMER-REPORT-DELIVERY.6 - audit consumer fix commits and bootstrap history` (local follow-up; base4e2598d1e).

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `CONSUMER-REPORT-DELIVERY.6` | `done` | Exact fix ledger and historical build distinction recorded; RGX-CONSUMER-BUILD-REPORTS.1 retains the open September report. |

## Decisions and Boundaries

- September23: Prioritize the director's blocked consumers; preserve .86.4.3 as
  pending unrelated follow-up. The ten original reports are seven locally resolved
  requirements, one open upstream report, one withdrawn report and one no-action report.
- ADR0124 delivers strict complete documents and token kinds through a separate
  grammar and consumer. Historical Lispish remains compatible; merely rerunning
  its old adapter does not exercise the new document contract.
- RGX/PGEN remain black boxes. September23 director decision: keep response and
  feedback locally in LinkedSpec task tracking; the director will communicate it
  to RGX after the fixes are pushed. No agent posting request remains pending.
  The LinkedSpec fixes are now published; the upstream report remains open.
- Attribution correction `.5`: ARCHOGEN reports PGEN bootstrap as the affected
  component. The public RGX command correctly returns failure. RGX is an
  integration contact; no RGX implementation defect has been established.

## Evidence Pointers

- `docs/knowledge/archogen-rust-lispish-integration.md`
- `docs/decisions/0124-kind-preserving-sexpr-document.md`
- `docs/tasks/SEXPR-DOCUMENT-INTEGRATION.md`
- `docs/tasks/BACKEND-INTEGRATION-GUIDES.md` (.8.1-.8.5)
- `docs/tasks/RGX-CONSUMER-BUILD-REPORTS.md`

## Publication and Resume Contract

- `.3` completed the canonical three-slice delivery batch. Remote main read-back
  equals `a8d34c84595d46c24cd1820d5fc0414261706412`; the push advanced it from
  `87b35665e1a8e0de1f03a27e31dbd4d34d8e2d94`. The tested baseline
  `f60a70df37159c0e42d66ee5f08a959821c7e08d` is an ancestor of published main.
- Publication evidence is retained in the commit body and repository-local
  `.linkedspec-data/scratch/consumer-report-delivery/publication.json`.
  After interruption, reverify current publication with
  `git ls-remote origin refs/heads/main`; dated evidence is not a perpetual claim
  about remote state.
- `.4` records the later director-owned relay in a focused local commit. It does
  not claim a new canonical receipt or another push. Any later push must satisfy
  the exact-HEAD canonical boundary again.
- The director can relay `docs/upstream/rgx/bootstrap-progress-status.md`, owned
  by `RGX-CONSUMER-BUILD-REPORTS.1`. That task retains upstream diagnosis/repair
  and public post-fix verification. No external message was sent by this session,
  no downstream application was changed, and LS-004 has not been fixed.
