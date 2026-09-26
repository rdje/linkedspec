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
date: 2026-09-26
status: eight relevant commits reverified in published main; seven requirements addressed; LS-004 upstream remedy verified but retained adoption pending; one withdrawn and one no-action
tags: [consumer-reports, commits, bootstrap, integration, attribution]
evidence: "CONSUMER-REPORT-DELIVERY.6 reconciles RGX-BUILD-REPRO.1, integration .8.1-.8.5, startup .83.2.1-.2, SEXPR-DOCUMENT-INTEGRATION.1-.2, ADR0124, original report provenance and Git commit bodies/changed-path scopes. All eight references below are ancestors of published a8d34c845."
reverify: "Read the named tasks and ADR0124; use git show --stat on the full commit identities below and git merge-base --is-ancestor <commit> origin/main after refreshing publication identity. Inspect no dependency implementation."
---

## Three different build concerns

| Concern | Actual recorded outcome | Commit authority |
| --- | --- | --- |
| June15 cold-checkout RGX build | Resolved upstream via the published build flow, then adopted and verified by LinkedSpec. | LinkedSpec `c4926f871`; upstream public resolution `8763a0e6b`. |
| September consumer Cargo workspace collision, ARCHOGEN/LS-001 and SEMULITH/LS-003 item1 | Fixed example workspace boundary plus documented host exclusion; native consumer builds verified. | `effe3e7b2`. |
| ARCHOGEN/LS-004 bootstrap failure handling and false seed-success text | Still open at the retained pin. Published RGX f6e5acdc now passes public failure/success/reuse; no LinkedSpec pin adoption is recorded/applied here. | `a1166ee1d` adopts public preparation and explicitly leaves this report open; `12c6ca9ad` reverifies its recurrence. Neither is an LS-004 fix. |

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
| ARCHOGEN/LS-004 | Public upstream remedy verified at RGX f6e5acdc; retained8763 still affected. Required .1.2 owns authorized adoption. | No LinkedSpec adoption commit yet |
| ARCHOGEN/LS-005 | Checkout/file-entry prerequisite navigation corrected. | `6e37288f7` |
| ARCHOGEN/LS-006 | Withdrawn by reporter: hex underscore was preserved. | No fix required |
| ARCHOGEN/LS-007 | No-action: adjacent-fragment joining matches the documented contract. | No fix requested |

Document delivery was independently admitted at `92f58b56c`; ADR0124 defines its
contract, not an implementation fix. Consumers must select `SExprDocumentV1.spec`
and `Document` (or the native `sexpr_file` example). Historical `Lispish.spec`
retains its extraction behavior. Publication `a8d34c845` makes the remedies
available; it is not their original implementation commit. Downstream application
acceptance has not been claimed. Seven addressed report requirements are not
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
adoption. The retained8763 failure still reproduces; an explicit director exception
to the pin freeze, native compatibility and canonical verification are required.
