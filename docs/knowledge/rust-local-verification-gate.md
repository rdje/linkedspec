---
id: rust-local-verification-gate
title: The optional Rust local gate runs complete core and runtime packages before primary conformance
answers:
  - how do I run the Rust local gate
  - what does tools run_rust_local sh check
  - does the Rust local gate run linkedspec core tests
  - which Rust tests does tools run_rust_local sh omit
  - are Rust parser compiler and validation tests in the focused gate
  - does run_ci_local include Rust checks
  - does local CI require a Rust toolchain by default
  - how do I select the Cargo executable for LinkedSpec checks
  - how do I select the Rust target directory for LinkedSpec checks
  - does Rust pass primary CLI conformance with POSIXLY_CORRECT
  - what did FUTURE-PARITY-BACKLOG 1.5.2.4 implement
date: 2026-07-17
status: current
tags: [rust, cli, ci, conformance, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.4.1 adds unfiltered cargo test -p linkedspec-core immediately before cargo test -p linkedspec-runtime; actual gate execution passes 188 core unit, 3 descriptor, and 8 type tests plus the complete runtime package before reaching the expected cursor-migration CLI boundary."
reverify: "bash -n tools/run_rust_local.sh && sed -n '1,90p' tools/run_rust_local.sh && cargo test --manifest-path rust/Cargo.toml -p linkedspec-core && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime && rg -n 'LINKEDSPEC_RUN_RUST|run_rust_local' tools/run_ci_local.sh README.md docs/linkedspec-book/src/development/local-ci-and-regression.md"
---

Run `bash tools/run_rust_local.sh` from the repository root. At the audited 2026-07-17 boundary it checks workspace
formatting, runs the complete `linkedspec-runtime` package, builds `linkedspec-rust`, then runs the current 63-case
primary-command manifest with `POSIXLY_CORRECT` unset and set. The runtime proof includes 137 unit tests, the
105-fixture interpreter oracle, 197 integration tests, the exhaustive 105-case generated-source classifier, and
the emitted/trace/contract suites.

`FUTURE-PARITY-BACKLOG.9.1.4.1` closes the preflight's verification-topology gap. Immediately after formatting,
the script runs unfiltered `cargo test -p linkedspec-core`, then unfiltered `cargo test -p linkedspec-runtime`.
The core package owns the Rust `.spec` parser, compiler, validation, descriptor, and compiled serialization types;
its current proof is 188 unit tests, three descriptor integration tests, and eight type integration tests. A
runtime dependency build alone never substitutes for those tests.

`LINKEDSPEC_CARGO_CMD` selects the Cargo executable. `CARGO_TARGET_DIR` selects the build directory and is also
used to locate the built primary binary. The script defaults to `cargo` and `rust/target`.

The canonical `tools/run_ci_local.sh` remains toolchain-independent by default and includes this focused Rust gate
only when `LINKEDSPEC_RUN_RUST=1` is set, matching the explicit Dart/Julia opt-in model. `.1.5.2.4` also proves the
historical gate introduction. The current rule-local cursor migration intentionally leaves Rust primary at 51/63
until `.9.1.4.6` removes the retired flag and trace field. Because the script is fail-fast, it stops after the
default environment at that exact boundary; `.9.1.4.0` separately proved the same 51/63 POSIX result.

For exact cross-backend command identity, `tools/run_primary_cli_matrix.sh` builds Rust and combines this command
with Perl, Dart, Julia, and Lua across both environments. `.1.5.4.3` owns the original 4x2x61 proof; Lua `.7.2`
extends the same matrix to 5x2x61.

Related facts: [[neutral-cli-fixture-runner]], [[rust-canonical-primary-cli-trace]],
[[hosted-ci-disabled-run-local-gate]], [[dart-local-verification-gate]],
[[julia-local-verification-gate]], [[primary-cli-four-backend-matrix]].
