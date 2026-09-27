# ARCHOGEN LS-004: misleading bootstrap progress observed through RGX

- Status: fixed upstream and published at LinkedSpec `fd3e328d5dd5c80981a1c3b8496a27270291f7b8`. ARCHOGEN verification remains pending. The agent's recipient-repository write was unauthorized and is recorded in docs/incidents/2026-09-27-archogen-write.md; all future handoff work stays in LinkedSpec.
- Owner: `RGX-CONSUMER-BUILD-REPORTS.1`; prepared by `BACKEND-INTEGRATION-GUIDES.8.3`.
- Related consumer report: ARCHOGEN/LS-004.
- LinkedSpec remedies published at: `a8d34c84595d46c24cd1820d5fc0414261706412`; remote main read-back and tested-baseline ancestry verified September23.
- Local feedback handoff: `CONSUMER-REPORT-DELIVERY.4`; attribution corrected by `.5`. September26 director instruction now requests a completion notice to both the director and ARCHOGEN, after verified publication.
- Original affected RGX revision: `8763a0e6bea97879f027237439d57725f83ead23`.
- Adopted remedy: `f6e5acdc99720349d1e3ecef9f821f365c4db19c`.
- Original observed environment: macOS26.6.2 arm64, Rust/Cargo1.95.0, system Make3.81.
- September23 recurrence: macOS27.0 (26A428) arm64, Cargo1.95.0, system Make3.81; same pinned RGX interface.
- Authority: RGX `docs/INTEGRATION.md`, downstream `make bootstrap` interface.

## Reporter, affected component and integration contact

ARCHOGEN reported LS-004 to LinkedSpec. Its original report identifies the PGEN
bootstrap as the affected component. LinkedSpec has not independently diagnosed
that implementation and has not established a defect in RGX's own code.

The public RGX command correctly returns failure (exit2) and emits no final
completion message. The empty offline package store deliberately induces an
expected prerequisite failure; failure to resolve an unavailable package is not
itself a newly discovered RGX defect. The reported concern is continued failed
preparation followed by a misleading intermediate seed-success message.

RGX is LinkedSpec's direct integration contact. Its published integration guide
also says PGEN is read-only from RGX. Routing the observation through RGX does not
assign code-level fault to RGX or ask it to patch PGEN. LinkedSpec retains report
tracking and public verification; the affected upstream maintainer owns any
implementation repair. The original caller-authorized source is
`../archogen/docs/feedback/linkedspec/issues/LS-004-bootstrap-false-success/README.md`.

## Distinct historical bootstrap build fix

The June15 cold-checkout build issue was resolved upstream at RGX
`8763a0e6bea97879f027237439d57725f83ead23` and adopted by LinkedSpec commit
`c4926f871131e9a67114425bb3c28108205bc283`, with successful cold-build evidence
under `RGX-BUILD-REPRO.1`. This report is the later September ARCHOGEN/LS-004;
that earlier closeout does not establish its repair. The exact report/commit
ledger is `docs/knowledge/consumer-report-fix-commits.md`.

## Public reproduction

The separate Cargo workspace build remedy is LinkedSpec commit
`effe3e7b2544abf79f7786a7aa54e77b1893880e`
(`BACKEND-INTEGRATION-GUIDES.8.2`). It is included in published history and fixes
ARCHOGEN/LS-001 and SEMULITH/LS-003 item1. It does not fix LS-004's failure-handling
and false-success report. The separate September26 adoption below carries that remedy.

Use a fresh checkout of the stated RGX revision, initialized according to its
published integration document. Existing prepared output can make bootstrap a
no-op, so use an isolated checkout rather than deleting a developer's artifacts.
Run from that checkout root with a new local package store:

```sh
REPORT_ROOT=$(pwd -P)
test ! -e .build-report || exit 1
mkdir -p .build-report/cargo-home .build-report/tmp
CARGO_HOME="$REPORT_ROOT/.build-report/cargo-home" \
TMPDIR="$REPORT_ROOT/.build-report/tmp" \
CARGO_NET_OFFLINE=true \
env -u CARGO_TARGET_DIR make bootstrap
```

The incomplete offline package store deliberately makes dependency resolution
fail. No dependency source modification, internal command invocation or generator
inspection is needed for this reproduction.

## Observed result

The public command exits **2**, correctly indicating failure. The log reports
`error: no matching package named` for `anyhow`, but also prints the affirmative
progress line `generated/ebnf.rs seeded.`. There is no final `Bootstrap complete.`
message. A reader relying on the intermediate message can mistake partial progress
for a completed step. LinkedSpec must check the overall command status.

Requested upstream outcome: stop dependent preparation after a failed prerequisite
and make progress messages accurate. RGX is the integration contact for this
PGEN-attributed report; the affected upstream maintainer owns implementation
changes. No RGX implementation defect or source-level root cause is established.

## Independent successful public use

With an already populated, byte-verified local package store, the documented
RGX bootstrap succeeds on isolated committed source with no overlays: 56.19s
cold and0.22s repeated. The dependent LinkedSpec two-member Rust application
builds locked/offline in26.65s, returns exact word values, passes18 Lispish
file/deployment groups and three adapter tests. Lockfiles remain unchanged.
These are dated native observations, not universal time or reuse guarantees.

## Evidence and limits

The managed equivalent of the command above was executed under repository-local
storage. The failed fixture also used unchanged committed sources and an empty
local Cargo store. Its command/output/status record is retained under
`.linkedspec-data/scratch/backend-integration83/public-interface/` as
`offline-failure.json` and `offline-failure.log`. Normal-route evidence is in
`state.json`, `consumer-state.json` and the associated logs in that directory.
Those original observations claimed no source patch, pin update, internal diagnosis, network installation or actual
ARCHOGEN application build. The September26 verification and adoption below supersede that earlier upstream-resolution status.

## September 23 recurrence

`CONSUMER-REPORT-DELIVERY.2` repeats the published command against the retained
isolated fixtures, with a fresh empty repository-local Cargo store for failure.
The failure again exits2, reports a missing package, prints the seed-success
line and omits final completion. The already-prepared control exits0 and prints
`PGEN parser already generated — nothing to bootstrap.`; a repeat also exits0.
A no-op need not print the fresh-generation completion banner. The initial
verification probe incorrectly required that banner; its assertion was corrected
without changing any dependency behavior.

The record and full public-command logs are under
`.linkedspec-data/scratch/consumer-report-delivery/` as `rgx-public.json`,
`rgx-failure.log`, `rgx-success.log` and `rgx-success-repeat.log`.
Failure-log SHA-256: `1d3c0bf9acc03c5fbe964f2ffbc6601b81213d4ab42e756221572805d6b0d745`.
Both successful no-op logs have SHA-256
`2f710aac340a1502ef3b70ec290c6eacaf57e4559a3a3c14919f7d3b3398c280`.
This is public failure/no-op recurrence, not another fresh-generation build.
The unchanged dependency pin and successful current LinkedSpec consumer proof
are recorded separately. The director has requested local tracking and will
relay this report after LinkedSpec publication, now completed. No external
message was sent by this session; no upstream repair had been verified at that September23 checkpoint.

## September26 .1.1 checkpoint: published remedy before adoption

The original report inputs are unchanged byte-for-byte. At this checkpoint, LinkedSpec remote
main was `a8d34c84595d46c24cd1820d5fc0414261706412`; all eight recorded related
fix/admission commits are ancestors. All three SEMULITH remedies remain published.

RGX's published main was `f6e5acdc99720349d1e3ecef9f821f365c4db19c`. Its
[published integration guide](https://github.com/rdje/rgx/blob/f6e5acdc99720349d1e3ecef9f821f365c4db19c/docs/INTEGRATION.md)
still specifies `make bootstrap`. A separate same-volume checkout used exactly
that interface, with no source overlays, internal inspection or retained pin change.

| Public check | Retained8763 | Published f6e5acdc |
| --- | --- | --- |
| Empty offline package store | Exit2; two package errors, later named steps and false seed success | Exit2 immediately after the first package error; no later named steps or false seed success |
| Independent repeated failure | Prior recurrence retained | Same accurate failure in0.088s |
| Fresh supported preparation | Earlier dated successful proof retained | Exit0 with completion in110.778s |
| Prepared reuse | Two exit0 no-op controls | Two exit0 no-op controls in0.029s and0.013s |

The initial published failure took5044.794s including the public command's large
transitive Git checkout initialization. It is not a parser-runtime measurement or
future duration promise. Fresh preparation used15360 byte-verified public Cargo
registry files/380075770bytes copied to a new repository-local store, with normal
package resolution allowed and no stale compiled products reused. The published
checkout remained Git-clean after all commands.

This checkpoint verified an upstream remedy for the observed LS-004 behavior at
the named published revision. It changed no LinkedSpec gitlink and established no
native LinkedSpec/ARCHOGEN compatibility. The then-retained8763 still reproduced.
Required `RGX-CONSUMER-BUILD-REPORTS.1.2` owned authorized pin adoption, native
consumer proof and canonical verification; the following section records that work.

Exact commands, revisions, report/cache hashes and every public-output hash are
in `docs/checkpoints/RGX-CONSUMER-BUILD-REPORTS.1.1.json`. Full logs are retained
under `.linkedspec-data/scratch/ls004-recheck26/`. No dependency implementation
was inspected and no source-level repair attribution is asserted. External
communication remained director-owned at that checkpoint; the subsequent
instruction authorizes the completion notice below.

## September26 authorized LinkedSpec adoption

After the public finding, the director requested fixing the identified issue and
notifying both the director and ARCHOGEN when done. `RGX-CONSUMER-BUILD-REPORTS.1.2`
adopts only the verified RGX revision. The new Git-clean checkout is the exact
publicly prepared f6e5acdc source; the previous checkout, its local edits and Git
metadata are retained with byte/status verification. The old native target is
preserved separately and LinkedSpec is rebuilt into a fresh target directory.

Native proof passes four word examples, nine workspace controls, three adapter
tests, 26 Lispish file values/18 groups and 37 document cases/36 groups. Public
bootstrap remains a successful prepared no-op after relocation. The Rust gate
now formats only LinkedSpec's own packages; the first run exposed `--all` traversing
dependency source. No dependency formatting diffs were analyzed or source changed.
The complete Rust component gate passes, including unchanged105-case oracle/classifier,
all core/runtime tests, emitted source, managed storage and both66-case CLI environments.
Exact staged canonical acceptance is mandatory for landing; `.1.3` owns
publication and the requested completion notice. No ARCHOGEN application acceptance
or `verified` state is claimed by LinkedSpec.

## September27 publication and local handoff

The reviewed adoption is published at LinkedSpec `fd3e328d5dd5c80981a1c3b8496a27270291f7b8` after exact
canonical PASS, clean push and matching remote read-back. This document is the
LinkedSpec-owned handoff for the director and ARCHOGEN; they control any downstream
repository change. SEMULITH independently verified and closed all three separate reports.

The agent's subsequent ARCHOGEN documentation commit82ee99a05 was unauthorized.
The director has forbidden all writes to other repositories, including corrections
or reverts. The exact incident and unapplied recovery material are retained inside
LinkedSpec at `docs/incidents/2026-09-27-archogen-write.md`. No consumer acceptance
is inferred from that commit. .1.3.1 records the correction; .1.3.2 owns final local closeout.
