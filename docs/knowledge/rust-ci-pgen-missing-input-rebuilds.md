---
id: rust-ci-pgen-missing-input-rebuilds
title: RGX and PGEN integration uses published contracts and observable build results only
answers:
  - "may Cargo rebuild RGX and PGEN now"
  - "is the RGX PGEN no-rebuild requirement still active"
  - "what is the RGX PGEN black box boundary"
  - "may an agent inspect RGX or PGEN implementation"
  - "which public command prepares RGX for a downstream application"
  - "what task owns observed dependency build costs"
  - "does local CI already retain a shared Rust target directory"
date: 2026-09-20
status: director boundary enforced in agent instructions; dependency implementation knowledge removed
tags: [rust, dependencies, public-contract, cargo, ci, startup]
evidence: "Director instructions on September20; AGENTS.md; RGX published rgx/docs/INTEGRATION.md sections1/5/6; existing RGX-BUILD-REPRO.1 records adoption of the public build interface."
reverify: "Read AGENTS.md and rgx/docs/INTEGRATION.md; verify documented commands and observable results under BACKEND-INTEGRATION-GUIDES.8.3 or SESSION-STARTUP-READING.80. No dependency implementation inspection is authorized."
---

**Direct dependency boundary:** LinkedSpec integrates only with RGX. RGX's
published integration document, public APIs and contracts are the sole authority.
RGX owns PGEN and all transitive preparation; no separate PGEN procedure or
internal dependency knowledge belongs in LinkedSpec. Reports go to RGX.

## Mandatory integration boundary

Treat RGX and PGEN as black boxes. Use RGX's published integration/build
instructions, public APIs and contracts. Do not inspect, analyze or modify their
implementation, reconstruct internal generation steps, or change submodule pins.
Source availability grants no permission to investigate internals. Any failure
must be reproduced through the public interface and tracked for the upstream
maintainer. Older task plans and historical observations cannot override this rule.

RGX publishes `make` to prepare and build its workspace, and `make -C path/to/rgx
bootstrap` for downstream consumers before their own Cargo build. The authority
is `rgx/docs/INTEGRATION.md`, not a LinkedSpec reconstruction of PGEN internals.
The Rust integration chapter supplies the consumer workspace and managed-storage
context around that public interface.

## Build permissions and observations

The September13 director instruction cancelled the no-rebuild requirement.
Normal documented builds may compile dependencies. Retain compatible caches;
do not promise that an unchanged submodule pin guarantees zero compilation.
Build logs are observations of a particular command/environment, not an internal
causal model or a portable timing guarantee.

An earlier canonical run at `bef5dafd` reported eleven Rust build stages totaling
4682 seconds. This counts reported build durations, not subsequent test startup
or execution. Its successful result does not establish the cause of build costs.
Implementation-derived explanations and replay instructions have been removed.

LinkedSpec's own `tools/project_data_env.sh` selects repository-local data and
Cargo storage; its normal target is `rust/target`. Startup `.80.1` may measure
public build behavior, `.80.2` tracks upstream reports/results, `.80.3` may improve
LinkedSpec-owned target retention, and `.80.4` verifies measured results. None of
these leaves authorizes dependency-internal investigation or changes.

Related: [[archogen-rust-lispish-integration]], [[rust-dependency-warning-baseline]],
[[macos-rust-first-launch-validation-latency]].
