---
id: consumer-report-fix-commits
title: Consumer report remedies and the older bootstrap fix have distinct commit histories
answers:
  - which commits resolve the ten SEMULITH and ARCHOGEN reports
  - which bootstrap build issue was fixed in June
  - is RGX BUILD REPRO the same as ARCHOGEN LS-004
  - was a custom bootstrap helper committed or withdrawn
  - which commit adopted the successful cold-checkout RGX build
  - which commits implement versus admit the document parsing remedy
  - has SEMULITH independently verified and closed all three reports
  - is SEMULITH LS-002 atom typing fixed and pushed
  - was ARCHOGEN notified of the published LS-004 fix
date: 2026-09-27
status: eight report requirements addressed upstream including LS-004 at fd3e328d5; SEMULITH three verified and closed; ARCHOGEN acceptance pending; recipient write was unauthorized
tags: [consumer-reports, commits, bootstrap, integration, attribution]
evidence: "CONSUMER-REPORT-DELIVERY.6 reconciles RGX-BUILD-REPRO.1, integration .8.1-.8.5, startup .83.2.1-.2, SEXPR-DOCUMENT-INTEGRATION.1-.2, ADR0124, original report provenance and Git commit bodies/changed-path scopes. All eight references below are ancestors of published a8d34c845."
reverify: "Read the named tasks and ADR0124; use git show --stat on the full commit identities below and git merge-base --is-ancestor <commit> origin/main after refreshing publication identity. Inspect no dependency implementation."
---

## Three different build concerns

| Concern | Actual recorded outcome | Commit authority |
| --- | --- | --- |
| June15 cold-checkout RGX build | Resolved upstream via the published build flow, then adopted and verified by LinkedSpec. | LinkedSpec `c4926f871`; upstream public resolution `8763a0e6b`. |
| September consumer Cargo workspace collision, ARCHOGEN/LS-001 and SEMULITH/LS-003 item1 | Fixed example workspace boundary plus documented host exclusion; native consumer builds verified. | `effe3e7b2`. |
| ARCHOGEN/LS-004 bootstrap failure handling and false seed-success text | Published LinkedSpec fd3e328d5 adopts the publicly verified RGX f6e5acdc remedy. The recipient write is an incident, not authorized delivery or acceptance. | `a1166ee1d` adopts public preparation and explicitly leaves this report open; `12c6ca9ad` reverifies its recurrence. Neither is an LS-004 fix. |

The June issue predates ARCHOGEN's September report. Its closed task cannot close
LS-004. Conversely, saying LS-004 is unfixed must not imply that the earlier
bootstrap build problem was never repaired. No RGX code defect is established by
the current failure-path observation; ARCHOGEN attributes LS-004 to PGEN bootstrap.

## Original reports and repair commits

| Source-qualified report | Remedy or disposition | Implementation or documentation commit |
| --- | --- | --- |
| SEMULITH/LS-001 | Literal newlines remain within quoted Lispish strings; following structure is preserved. | `8259719f8` |
| SEMULITH/LS-002 | Kind-preserving document path delivered as an opt-in design request. | `77d7b3db1` grammar; `df845ce61` native file consumer |
| SEMULITH/LS-003 | Item1 workspace remedy; items2-3 prerequisite links and qualified optional-checkout guidance. | `effe3e7b2`; `6e37288f7` |
| ARCHOGEN/LS-001 | Enclosing Cargo workspace collision remedied. | `effe3e7b2` |
| ARCHOGEN/LS-002 | All top-level forms and complete-document rejection through the separate document grammar. | `77d7b3db1`; `df845ce61` |
| ARCHOGEN/LS-003 | Symbols, strings and numbers retain tagged kinds and token spelling. | `77d7b3db1`; `df845ce61` |
| ARCHOGEN/LS-004 | RGX f6e5acdc remedy adopted and published after exact canonical PASS; ARCHOGEN verification pending. | `fd3e328d5dd5c80981a1c3b8496a27270291f7b8` |
| ARCHOGEN/LS-005 | Checkout/file-entry prerequisite navigation corrected. | `6e37288f7` |
| ARCHOGEN/LS-006 | Withdrawn by reporter: hex underscore was preserved. | No fix required |
| ARCHOGEN/LS-007 | No-action: adjacent-fragment joining matches the documented contract. | No fix requested |

Document delivery was independently admitted at `92f58b56c`; ADR0124 defines its
contract, not an implementation fix. Consumers must select `SExprDocumentV1.spec`
and `Document` (or the native `sexpr_file` example). Historical `Lispish.spec`
retains its extraction behavior. Publication `a8d34c845` makes the remedies
available; it is not their original implementation commit. Downstream application
acceptance was separate at that publication; SEMULITH's later verification is recorded below. Seven addressed report requirements are not
seven newly fixed runtime bugs: the set includes documentation and a design request.

## Exact Git identities

- Cold-build adoption: `c4926f871131e9a67114425bb3c28108205bc283`.
- Adopted upstream RGX revision: `8763a0e6bea97879f027237439d57725f83ead23`.
- Workspace repair: `effe3e7b2544abf79f7786a7aa54e77b1893880e`.
- Public preparation guidance/report: `a1166ee1d9ce8fce0dfc8f75903d0734ab41c975`.
- Prerequisite guidance: `6e37288f7564d99480f1353231b226a678a9568f`.
- Quoted-LF repair: `8259719f8198a1280c8d91d07a9797ef39e036a8`.
- Document grammar: `77d7b3db1b65a2c83072447a6aec77456ca7aede`.
- Native document file consumer: `df845ce615df20929ac501b61984fbf9d29225ca`.
- Document admission: `92f58b56cddf4a104738374104ef5cc4847cf53d`.

`a1166ee1d` explicitly records that the custom dependency-preparation helper and
tests were uncommitted and discarded before landing. Its replacement is
integration guidance and public-interface verification, not a bootstrap code
repair. No dependency implementation was inspected in this audit. Searching the
ADR records for LS-004/false-success/bootstrap-repair terms finds no separate
closeout; ADR0124 concerns the document grammar and its consumers.

Canonical source-qualified intake and current attribution:
[[archogen-rust-lispish-integration]]. Native document design:
[[sexpr-document-design]]. Quote repair: [[lispish-multiline-quoted-payload]].
Dated publication ancestry evidence is retained at
`.linkedspec-data/scratch/consumer-report-delivery/fix-commit-audit.json`.

## September26 public remedy recheck

`RGX-CONSUMER-BUILD-REPORTS.1.1` rechecks both supplied report snapshots, live remote
main a8d34c845 and all eight ancestry references. [[rgx-bootstrap-published-remedy]]
records the independently verified public remedy at f6e5acdc and required `.1.2`
adoption. At the .1.1 checkpoint the old8763 failure still reproduced. The subsequent
director instruction authorizes fixing that identified issue and notifying the
director and ARCHOGEN after publication. .1.2 adopts only the reviewed RGX pin;
.1.3 owns the completion notice. Dependency implementation remains upstream-owned.

## SEMULITH independently closes all three reports

On September26 the director supplied SEMULITH's three `VERIFIED.md` notes and
confirmed all three cases closed. The clean feedback subtree at SEMULITH commit
`7f4d2cde61a82184cf06a7870c87a19b3aa744b3` marks LS-001, LS-002 and LS-003 verified
against published LinkedSpec `a8d34c84595d46c24cd1820d5fc0414261706412`.
The caller-authorized source is `../semulith/docs/upstream/linkedspec/`.

- LS-001: unchanged reproduction passes 8/8; both readers agree across all five
  then-tracked files, including the 43-form catalogue.
- LS-002: original four numeric/quoted-numeric files pass through `sexpr_file`
  with `SExprDocumentV1.spec`. Number and string kinds remain distinct. SEMULITH
  additionally reports six-file document-layer agreement with no classified residue.
- LS-003: SEMULITH exercised all three guide remedies while adopting that pin.

The LS-002 note SHA-256 is
`496b0e17f2c12e6cd4a19814bc31f796db439006ab62029d1aedce787f75d41c`;
its adjacent `evidence/verified-a8d34c845.txt` transcript SHA-256 is
`56b888c47a99d4e7eea9b1f6dd833af5754f6f25ff8708b0a08b0b76bb33274e`.
All three notes were read in full. This is consumer verification, not an inferred
closure from upstream tests. ARCHOGEN's separate IDs and acceptance remain distinct.

## September27 publication and unauthorized recipient-write correction

LinkedSpec `fd3e328d5dd5c80981a1c3b8496a27270291f7b8` publishes the adopted remedy and strict-document prefix
repair after exact canonical PASS, clean push and matching remote read-back. The eight
addressed requirements have upstream remedies; LS-006 remains withdrawn and LS-007 no-action.

The agent then wrongly treated a notification request as permission to modify ARCHOGEN.
Its commit `82ee99a05ee55babdf6ea49fb719707a030b8700` is **unauthorized**, not consumer acknowledgment or
acceptance. `docs/incidents/2026-09-27-archogen-write.md` records the twelve changed
documents and auxiliary writes, plus an unapplied local reverse patch. All other
repositories are strictly read-only; ARCHOGEN owns disposition of its commit and its
independent verification. SEMULITH's three independent closures remain valid.

The corrected local record is owned by .1.3.1; .1.3.2 retains final LinkedSpec-only
closeout. See [[external-repositories-read-only]].
