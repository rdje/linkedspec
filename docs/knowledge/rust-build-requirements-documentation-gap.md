---
id: rust-build-requirements-documentation-gap
title: Rust build guidance follows RGX's published toolchain requirement
answers:
  - what minimum Rust compiler does the README claim
  - why was the Rust README 1.85 requirement stale
  - where is the published RGX Rust toolchain requirement
  - does Cargo metadata prove the earliest working Rust compiler
  - who owns the Rust build requirements and command documentation repair
date: 2026-09-21
status: integration requirement and Building commands corrected; broader startup .41.7 repairs remain open
tags: [rust, cargo, requirements, documentation, SESSION-STARTUP-READING]
evidence: "RGX public rgx/docs/INTEGRATION.md sections3/12 requires Rust 1.95. Integration .8.5 replaces Rust README's1.85 wording and unmanaged Building block. Observed Cargo/rustc 1.95.0, prior native consumer proof and canonical fbb135d63 qualify actual support; no earlier compiler/platform matrix is claimed."
reverify: "Read rgx/docs/INTEGRATION.md sections3/12, rust/README.md Building and the Rust integration guide. Run bash tools/run_cargo_local.sh --version and bash tools/project_data_run.sh rustc --version; use the guide's managed native consumer checks for actual execution."
---

The maintained requirement is **Rust 1.95 or newer**, as published by RGX's
integration contract. LinkedSpec does not derive that requirement from private
manifests or a transitive dependency census. Recheck the selected RGX revision's
published contract when updating.

`BACKEND-INTEGRATION-GUIDES.8.5` replaces the stale Rust README 1.85 statement and
its Building block. Commands now run from the LinkedSpec root through
`tools/run_cargo_local.sh` with an explicit `rust/Cargo.toml` path. New checkout
preparation links to the Rust application guide's managed storage/public RGX
bootstrap sequence. No separate transitive preparation procedure is maintained.

Cargo and rustc report 1.95.0 on the measured macOS arm64 host. Native consumer
build/use was verified in integration .2.1/.2.2/.8.3, and .6's canonical checkpoint
fbb135d63 verifies required Rust admissions and relocation. This establishes the
observed route, not the earliest possible compiler, all platforms, every optional
Rust suite, clippy or a release-profile build. A version-only command is not a
substitute for a native build/use result.

The September 7 declared-version census is superseded as a requirements authority;
its exact historical record remains in Git. The public RGX contract and measured
consumer results govern current guidance. Cargo metadata describes declarations;
it cannot establish the earliest compiler on which an application works.

Startup `.41.7` retains its other development-command, cadence and stale-count
repairs. `.41.2` retains generated-source classification wording. Neither task is
closed by this bounded integration correction, and no source-reading credit is
added.

Related: [[archogen-rust-lispish-integration]], [[rust-ci-pgen-missing-input-rebuilds]],
[[rust-project-data-ssd-storage]], [[rust-generated-source-full-manifest-classification]],
[[rust-local-verification-gate]].
