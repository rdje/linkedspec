# RGX-CONSUMER-BUILD-REPORTS: Public build reports and upstream resolutions

**Direct dependency boundary:** LinkedSpec integrates only with RGX. RGX's
published integration document, public APIs and contracts are the sole authority.
RGX defines supported transitive preparation and is the integration contact. Its
published contract keeps PGEN read-only from RGX. No separate PGEN procedure or
internal dependency knowledge belongs in LinkedSpec; routing is not fault attribution.

## Metadata

- Tree ID: `RGX-CONSUMER-BUILD-REPORTS`
- Status: `pending` / upstream remedy verified; retained-pin adoption requires explicit director authorization
- Roadmap lane: `Rust downstream integration / upstream issue follow-up`
- Created: `2026-09-20`
- Last updated: `2026-09-26`
- Owner: LinkedSpec report tracking/public verification; director relays feedback; RGX is integration contact; affected upstream maintainer owns implementation repair

## Goal

Track consumer-reported preparation problems observed through RGX's published
interface through upstream resolution and consumer verification. No RGX code
defect is established by observing transitive bootstrap output. RGX/PGEN are black boxes: no implementation
inspection, analysis, reconstruction, source edits or pin changes are authorized.

## Task Tree

- ID: `RGX-CONSUMER-BUILD-REPORTS`
  Status: `pending`
  Goal: Resolve public build reports through upstream-published fixes.
  Children: `.1`

- ID: `RGX-CONSUMER-BUILD-REPORTS.1`
  Status: `pending`
  Goal: Resolve the misleading bootstrap progress message reported as ARCHOGEN/LS-004.
  Scope: Public RGX bootstrap verification and separately authorized dependency adoption; no dependency implementation inspection or patches.
  Children: `.1.1`, `.1.2`
  Dependencies: Integration `.8.3` supplies the report; CONSUMER-REPORT-DELIVERY.2 reverifies it, .3 publishes the LinkedSpec fixes and .4 records the director-owned relay.
  Acceptance: Preserve exact public reproduction and observed status; receive an upstream response or published resolution; verify through the supported interface and record remaining limitations. Do not claim a fixed issue merely because a downstream guide uses the correct entry point. The director will relay the local report via RGX as the integration contact. Preserve ARCHOGEN's PGEN component attribution as reported, not independently proven; RGX correctly propagates the observed failure and no RGX implementation defect is established. This session must not post an external issue; there is no pending external-post permission request. A response alone does not establish repair: retain the failure exit status, verify accurate failure-path progress text, and preserve supported successful and already-prepared public bootstrap behavior.
  Verification: September23 CONSUMER-REPORT-DELIVERY.2 reproduces the public failure at pinned RGX8763a0e6: exit2, missing package, misleading seed line and no final completion. Prepared public bootstrap exits0 with its documented reusable no-op outcome. Report and log hashes are refreshed. Delivery .3 is published at a8d34c84595d46c24cd1820d5fc0414261706412 (exact remote read-back and source-baseline ancestry PASS). September23 director instruction assigns external communication to the director and local feedback tracking to LinkedSpec under delivery .4. Delivery .5 corrects the contact-versus-component conflation against the original report, retained public output and published integration contract. No external message was sent by this session. Upstream diagnosis/repair and post-fix verification remain pending.
  September26 continuation: .1.1 verifies the published remedy through failure/success/reuse at f6e5acdc. Retained8763 is still affected; .1.2 now owns authorized pin adoption, native consumer proof and canonical verification. The parent remains open until that retained-checkout repair is admitted.
  Commit: `pending`

- ID: `RGX-CONSUMER-BUILD-REPORTS.1.1`
  Status: `done`
  Goal: Recheck all supplied consumer-report coverage and verify whether a published RGX revision resolves LS-004 through its public interface.
  Activation: Clean 35c00924cf0add082e94213da3d01394cb5993df, brief0, no jobs; scoped roadmap, report ledger, original caller-authorized report and published integration guides read.
  Verification tier: `focused`
  Focused checks: Original report snapshot hashes and published LinkedSpec ancestry; retained public failure/reuse; exact published RGX identity and integration document; two empty-store failures, fresh normal bootstrap and two offline prepared controls; book render/exact paragraph/link, Knowledge/history/memory/doctrines and diff.
  Canonical trigger: Any retained dependency pin, infrastructure or public contract movement; otherwise final clean push. This leaf changes no dependency pin or implementation.
  Verification: Retained8763 failure still exits2 with two missing-package errors, later Step B/Step C and false seed success. Its two prepared controls exit0. Published f6e5acdc99720349d1e3ecef9f821f365c4db19c stops at the first missing-anyhow error, exits2, runs no later named steps and prints no false seed success; independent repeat agrees in0.088s. Fresh normal public bootstrap exits0 with completion in110.778s; offline prepared controls exit0 in0.029s and0.013s. Published checkout stays Git-clean. Initial published failure took5044.794s including the public command's transitive Git initialization; this is not parser/build CPU time or a future duration promise.
  Coverage: ARCHOGEN43files/75512bytes and SEMULITH29files/26871bytes match the supplied snapshot hashes exactly. Live remote main remains a8d34c84595d46c24cd1820d5fc0414261706412; all eight recorded related fix/admission commits remain ancestors. Seven remedies are published; withdrawn/no-action dispositions are unchanged. No downstream application acceptance is claimed.
  Storage: Copied and byte-verified15360 public Cargo registry files/380075770bytes to a new same-volume package store; retained the source cache and reused no old compiled outputs. All commands used repository-derived storage and the public RGX entry point. No dependency implementation was inspected, no retained pin changed and no external message sent.
  Evidence: docs/checkpoints/RGX-CONSUMER-BUILD-REPORTS.1.1.json retains commands, exact revisions, public output hashes, source/report provenance, cache proof and scope. Raw logs remain under .linkedspec-data/scratch/ls004-recheck26/.
  Required continuation: Upstream public behavior is verified fixed at f6e5acdc, but LinkedSpec still pins affected8763. Required .1.2 owns adoption, native compatibility and canonical verification. The director's section20/AGENTS pin freeze requires an explicit exception before any pin change. Do not notify ARCHOGEN that the retained LinkedSpec checkout is fixed yet.
  - [x] **REPRODUCE / ISSUE** — Retained public failure reproduces the original symptom exactly; current published failure and repeat differ at the same missing prerequisite.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Observable public progress continues after failure at8763, whereas f6e5acdc stops after the first error. No internal implementation diagnosis or RGX fault attribution is made.
  - [x] **FIX** — Report and book distinguish the verified published remedy from the still-affected retained pin; actual LinkedSpec adoption is required under .1.2.
  - [x] **ADDRESSED (verified)** — This status-verification leaf passes both failure controls, fresh successful preparation and two prepared controls at the exact published revision. It is not local pin-adoption acceptance.
  - [x] **NO REGRESSION** — Public successful/reusable bootstrap is preserved; native LinkedSpec compatibility and exact canonical proof remain required for .1.2.
  - [x] **LOCKSTEP** — Current report, book, ledger/Knowledge, roadmap/task and bounded continuity records carry the same qualified status; final normal checks govern landing.
  Commit: `RGX-CONSUMER-BUILD-REPORTS.1.1 - verify published bootstrap remedy`; derive landed identity from Git.

- ID: `RGX-CONSUMER-BUILD-REPORTS.1.2`
  Status: `pending`
  Goal: Make the verified LS-004 remedy available in LinkedSpec through an explicitly authorized RGX pin update and complete consumer verification.
  Dependencies: .1.1 verifies public bootstrap at f6e5acdc99720349d1e3ecef9f821f365c4db19c. The director must explicitly authorize an exception to the standing prohibition on submodule pin changes; elapsed time is not approval.
  Planned tier: canonical, because a dependency pin changes.
  Acceptance: After authorization, use only the published integration/build instructions and public APIs/contracts. Update only the reviewed RGX gitlink from8763a0e6bea97879f027237439d57725f83ead23 to f6e5acdc99720349d1e3ecef9f821f365c4db19c; no dependency source patches or internal inspection. Rebuild through supported preparation without stale compiled products; verify native LinkedSpec and maintained historical/document file consumers, focused direct dependents and exact staged canonical CI. Synchronize pin/setup claims and the book, commit cleanly, and establish publication before consumer delivery is claimed. Stop and own any compatibility failure through the public interface.
  Verification: Public upstream failure/success/reuse is complete under .1.1; LinkedSpec native compatibility, pin adoption and publication are not yet verified. No pin-change authorization is recorded in this leaf.
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `RGX-CONSUMER-BUILD-REPORTS.1.2` | `pending` | Explicit pin-freeze exception, then native/canonical adoption of the verified published remedy; retained8763 remains affected. |

## Director Handoff

- Ready response: `docs/upstream/rgx/bootstrap-progress-status.md`.
- Published LinkedSpec delivery: `a8d34c84595d46c24cd1820d5fc0414261706412`;
  the remaining report is not a claim that these LinkedSpec remedies failed.
- RGX contact role: coordinate the PGEN-attributed report through the appropriate
  upstream owner. No request to alter RGX code or patch its read-only dependency
  follows from this evidence. Requested outcome: stop dependent steps after a
  prerequisite fails and avoid false success text, preserving the correct exit status.
- LinkedSpec follow-up: test the published remedy only through RGX's supported
  interface, record exact status/output and successful/reusable controls, and
  keep this task open until repair is verified. No dependency pin change or
  implementation inspection is authorized by this handoff.
- No issue URL or upstream reply is recorded; independently tested published f6e5acdc supplies the remedy evidence. The director owns communication.
- September26: .1.1 verifies the public remedy; .1.2 owns required retained-pin adoption after explicit authorization. The report remains open for this checkout until adoption is verified.

## Distinct Historical Build Fix

`RGX-BUILD-REPRO.1` closed the June15 cold-checkout build problem. LinkedSpec
`c4926f871131e9a67114425bb3c28108205bc283` adopted upstream RGX
`8763a0e6bea97879f027237439d57725f83ead23` and recorded a successful cold build.
That older issue is distinct from September ARCHOGEN/LS-004. Integration
`a1166ee1d` explicitly left LS-004 open after adopting the public preparation
flow and discarding an uncommitted custom helper. The complete report/commit
ledger is `docs/knowledge/consumer-report-fix-commits.md`.

## Attribution Evidence

- ARCHOGEN's original LS-004 names PGEN bootstrap, not the RGX engine.
- The retained public command exits2 correctly; no final success is claimed.
- The deliberately unavailable offline prerequisite is an expected failure.
  The misleading intermediate message remains the observed report symptom.
- RGX's published `docs/INTEGRATION.md` says PGEN is read-only from RGX.
- This task's stable RGX-prefixed ID names the integration route, not a finding
  of faulty RGX implementation. LinkedSpec still owns intake and verification.

## Decisions

- Integration documentation may describe verified supported use while this upstream
  report remains open. Neither documentation delivery nor a successful normal build
  establishes correction of a failure-path progress message.
- All dependency implementation authority remains upstream. Published interfaces,
  contracts and observable consumer results are the only local evidence surface.
