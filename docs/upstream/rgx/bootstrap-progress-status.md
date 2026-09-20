# Misleading progress text during a failed RGX public bootstrap

- Status: reproduced locally; upstream resolution pending. This report has not been posted externally.
- Owner: `RGX-CONSUMER-BUILD-REPORTS.1`; prepared by `BACKEND-INTEGRATION-GUIDES.8.3`.
- Related consumer report: ARCHOGEN/LS-004.
- RGX revision: `8763a0e6bea97879f027237439d57725f83ead23`.
- Observed environment: macOS26.6.2 arm64, Rust/Cargo1.95.0, system Make3.81.
- Authority: RGX `docs/INTEGRATION.md`, downstream `make bootstrap` interface.

## Public reproduction

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

Requested upstream outcome: progress messages should accurately reflect failed
preparation. RGX's maintainer owns diagnosis and remedy; this report makes no
claim about internal implementation or a source-level fix.

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
