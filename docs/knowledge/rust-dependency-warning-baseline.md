---
id: rust-dependency-warning-baseline
title: Canonical Rust carriers expose reproducible pgen and rgx-core warning debt
answers:
  - why does canonical Rust compilation print thousands of warnings
  - how many warnings does pgen currently emit
  - are the Rust dependency warnings just sandbox noise
  - which task owns Rust dependency warning cleanup
  - can cargo fix be used blindly on pgen warnings
  - where must generated parser warnings be fixed
  - what git boundary owns rgx and pgen warning fixes
date: 2026-09-04
status: current baseline; cleanup durably owned by RUST-DEPENDENCY-WARNING-ZERO and intentionally non-blocking
tags: [rust, pgen, rgx, warnings, generated-source, diagnostics, task-tree]
evidence: "During exact staged canonical verification of FUTURE-PARITY-BACKLOG.19.6.1, multiple independent clean Rust carriers reported `pgen (lib) generated 1870 warnings` and 1360 Cargo fix suggestions, plus 26 `rgx-core` warnings. The pgen stream includes authored ast_pipeline files and generated parser files, so 1870 is a repeated build-output count rather than a proven unique-cause count. The same baseline appeared inside and outside the outer execution sandbox; the sandboxed run's later status 71 was only the separately known nested sandbox-exec restriction, and the unchanged authorized canonical rerun passed. Main Git tracks rgx as gitlink 8763a0e6bea97879f027237439d57725f83ead23, while rgx/subs/pgen is nested beneath that repository. RUST-DEPENDENCY-WARNING-ZERO.1 must perform a machine-readable unique-cause census before repairs; later leaves separate authored pgen, generator/generated pgen, rgx-core, direct LinkedSpec, pin integration, and zero-warning enforcement. Broad allow attributes, RUSTFLAGS=-Awarnings, output filtering, and blind cargo fix do not satisfy the task."
reverify: "bash tools/run_ci_local.sh"
---

# Rust dependency warning baseline

Canonical Rust consumers repeatedly build the pinned `rgx` dependency and its nested
`pgen` parser generator. The current build output reports 1,870 warnings for the
`pgen` library and 26 for `rgx-core`. The larger number is not yet a count of distinct
defects: generated parser repetition and multiple build targets can amplify one
authoritative cause.

Cleanup must begin with structured diagnostic capture and source ownership. Authored
`pgen` code, generator templates, regenerated parser artifacts, `rgx-core`, and direct
LinkedSpec crates are separate repair surfaces. A warning originating in generated
source is fixed in its generator/template and then regenerated; a broad suppression or
an unreviewed bulk rewrite would only conceal the causal boundary.

The dependency boundary is also explicit. LinkedSpec pins the `rgx` repository as a Git
submodule, and `pgen` is nested within it. Durable repair therefore requires clean
upstream commits plus reviewed gitlink integration before a zero-warning guard can be
admitted here.

Related: [[project-data-process-locality-proof]], [[repository-root-path-portability]],
[[verification-cadence-policy]], and task tree `RUST-DEPENDENCY-WARNING-ZERO`.
