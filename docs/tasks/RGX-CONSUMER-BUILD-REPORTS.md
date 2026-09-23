# RGX-CONSUMER-BUILD-REPORTS: Public build reports and upstream resolutions

**Direct dependency boundary:** LinkedSpec integrates only with RGX. RGX's
published integration document, public APIs and contracts are the sole authority.
RGX defines supported transitive preparation and is the integration contact. Its
published contract keeps PGEN read-only from RGX. No separate PGEN procedure or
internal dependency knowledge belongs in LinkedSpec; routing is not fault attribution.

## Metadata

- Tree ID: `RGX-CONSUMER-BUILD-REPORTS`
- Status: `pending` / upstream-owned and non-blocking for integration documentation
- Roadmap lane: `Rust downstream integration / upstream issue follow-up`
- Created: `2026-09-20`
- Last updated: `2026-09-23`
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
  Scope: Public RGX make bootstrap command, command environment, exit status and output only.
  Dependencies: Integration `.8.3` supplies the report; CONSUMER-REPORT-DELIVERY.2 reverifies it, .3 publishes the LinkedSpec fixes and .4 records the director-owned relay.
  Acceptance: Preserve exact public reproduction and observed status; receive an upstream response or published resolution; verify through the supported interface and record remaining limitations. Do not claim a fixed issue merely because a downstream guide uses the correct entry point. The director will relay the local report via RGX as the integration contact. Preserve ARCHOGEN's PGEN component attribution as reported, not independently proven; RGX correctly propagates the observed failure and no RGX implementation defect is established. This session must not post an external issue; there is no pending permission request. A response alone does not establish repair: retain the failure exit status, verify accurate failure-path progress text, and preserve supported successful and already-prepared public bootstrap behavior.
  Verification: September23 CONSUMER-REPORT-DELIVERY.2 reproduces the public failure at pinned RGX8763a0e6: exit2, missing package, misleading seed line and no final completion. Prepared public bootstrap exits0 with its documented reusable no-op outcome. Report and log hashes are refreshed. Delivery .3 is published at a8d34c84595d46c24cd1820d5fc0414261706412 (exact remote read-back and source-baseline ancestry PASS). September23 director instruction assigns external communication to the director and local feedback tracking to LinkedSpec under delivery .4. Delivery .5 corrects the contact-versus-component conflation against the original report, retained public output and published integration contract. No external message was sent by this session. Upstream diagnosis/repair and post-fix verification remain pending.
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `RGX-CONSUMER-BUILD-REPORTS.1` | `pending` | Director relays the ready local report after verified LinkedSpec publication; await upstream remedy, then verify public failure/success/reuse outcomes. |

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
- No issue URL or upstream reply is recorded yet; the director owns communication.

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
