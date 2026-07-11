---
id: rust-local-verification-gate
title: One optional Rust local gate proves the runtime package and both primary CLI environments
answers:
  - how do I run the Rust local gate
  - what does tools run_rust_local sh check
  - does run_ci_local include Rust checks
  - does local CI require a Rust toolchain by default
  - how do I select the Cargo executable for LinkedSpec checks
  - how do I select the Rust target directory for LinkedSpec checks
  - does Rust pass primary CLI conformance with POSIXLY_CORRECT
  - what did FUTURE-PARITY-BACKLOG 1.5.2.4 implement
date: 2026-07-10
status: current
tags: [rust, cli, ci, conformance, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.2.4 adds tools/run_rust_local.sh and LINKEDSPEC_RUN_RUST opt-in; the gate passes the full runtime package plus 61/61 default and POSIX CLI cases."
reverify: "bash tools/run_rust_local.sh && rg -n 'LINKEDSPEC_RUN_RUST|run_rust_local' tools/run_ci_local.sh README.md docs/linkedspec-book/src/development/local-ci-and-regression.md"
---

Run `bash tools/run_rust_local.sh` from the repository root. It checks workspace formatting, runs the complete
`linkedspec-runtime` package, builds `linkedspec-rust`, then runs the unchanged 61-case primary-command manifest
with `POSIXLY_CORRECT` unset and set. The package proof includes 137 unit tests, the 99-fixture interpreter oracle,
190 integration tests, three source-emitter tests, and 10 native trace-control tests.

`LINKEDSPEC_CARGO_CMD` selects the Cargo executable. `CARGO_TARGET_DIR` selects the build directory and is also
used to locate the built primary binary. The script defaults to `cargo` and `rust/target`.

The canonical `tools/run_ci_local.sh` remains toolchain-independent by default and includes this full Rust gate
only when `LINKEDSPEC_RUN_RUST=1` is set, matching the explicit Dart/Julia opt-in model. `.1.5.2.4` also proves the
broader default local gate through Phase 0 `1..1028`, closes the Rust primary-command lane, and advances PNT to
Dart `.1.5.3`.

For exact cross-backend command identity, `tools/run_primary_cli_matrix.sh` builds Rust and combines this command
with Perl, Dart, and Julia across both environments. That recurring 4x2x61 proof is separately owned by `.1.5.4.3`.

Related facts: [[neutral-cli-fixture-runner]], [[rust-canonical-primary-cli-trace]],
[[hosted-ci-disabled-run-local-gate]], [[dart-local-verification-gate]],
[[julia-local-verification-gate]], [[primary-cli-four-backend-matrix]].
