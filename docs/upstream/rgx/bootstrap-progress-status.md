# ARCHOGEN LS-004: misleading bootstrap progress observed through RGX

- Status: reproduced locally; upstream resolution pending. The director will relay this local report; this session has not posted it externally.
- Owner: `RGX-CONSUMER-BUILD-REPORTS.1`; prepared by `BACKEND-INTEGRATION-GUIDES.8.3`.
- Related consumer report: ARCHOGEN/LS-004.
- LinkedSpec remedies published at: `a8d34c84595d46c24cd1820d5fc0414261706412`; remote main read-back and tested-baseline ancestry verified September23.
- Local feedback handoff: `CONSUMER-REPORT-DELIVERY.4`; attribution corrected by `.5`. The director owns communication.
- RGX revision: `8763a0e6bea97879f027237439d57725f83ead23`.
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

## Public reproduction

The separate Cargo workspace build remedy is LinkedSpec commit
`effe3e7b2544abf79f7786a7aa54e77b1893880e`
(`BACKEND-INTEGRATION-GUIDES.8.2`). It is included in published history and fixes
ARCHOGEN/LS-001 and SEMULITH/LS-003 item1. It does not fix LS-004's failure-handling
and false-success report; no LS-004 implementation fix commit exists here.

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
No source patch, pin update, internal diagnosis, network installation or actual
ARCHOGEN application build is claimed. The upstream report remains open.

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
message was sent by this session and no upstream repair has been verified.

## Requested repair and public acceptance

Please make progress output accurately describe failed preparation. The overall
nonzero failure status is already correct and must remain so. A success-sounding
intermediate line must not imply that a failed preparation step completed. The
original report also requests stopping dependent work after a prerequisite fails.
The affected upstream maintainer owns diagnosis and implementation; this report
prescribes no internal fix and does not require RGX to modify its PGEN submodule.

LinkedSpec will verify the published remedy through the supported public command:
repeat the isolated offline failure, check its status and progress text, then
check supported successful preparation and already-prepared reuse. The repair
task remains open until that evidence exists. The separate LinkedSpec publication
does not close this upstream report or establish downstream application acceptance.
