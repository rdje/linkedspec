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
  - does the Rust local gate pass all 66 primary cases
  - does the Rust local gate prove project data stays on repository storage
  - what did FUTURE-PARITY-BACKLOG 1.5.2.4 implement
date: 2026-09-08
status: current
tags: [rust, cli, ci, conformance, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.4.1 adds unfiltered core immediately before runtime package tests; PROJECT-DATA-SSD-ROOTING.2.2 adds managed storage proof. The pre-reconciliation record, dated July 18, reports runtime 149, oracle/classifier 105 each, integration 197, both primary 66/66 environments, 17 temporary owners and 195 offline registry packages. These counts are historical. Startup .3.3.61/.62 source review confirms tools/run_ci_local.sh runs mandatory native Rust consumers by default; LINKEDSPEC_RUN_RUST=1 selects the additional complete Rust gate. The default canonical result does not refresh the optional full-package totals."
reverify: "bash -n tools/run_rust_local.sh tools/run_cargo_local.sh tools/test_rust_project_data_storage.sh && bash tools/run_rust_local.sh && bash tools/run_cargo_local.sh fetch --manifest-path rust/Cargo.toml --locked --offline && rg -n 'LINKEDSPEC_RUN_RUST|run_rust_local' tools/run_ci_local.sh README.md docs/linkedspec-book/src/development/local-ci-and-regression.md"
---

Run `bash tools/run_rust_local.sh` from the repository root. It checks workspace formatting, runs the complete
`linkedspec-core` and `linkedspec-runtime` packages, builds `linkedspec-rust`, proves Rust project-data storage,
then runs the current primary-command manifest with `POSIXLY_CORRECT` unset and set. The historical recorded runtime
proof included 149 unit tests, the 105-fixture interpreter oracle,
197 integration tests, the 105-case generated-source classifier, and emitted/trace/contract suites.
These dated totals are not a fresh run of the optional complete gate.

`FUTURE-PARITY-BACKLOG.9.1.4.1` closes the preflight's verification-topology gap. Immediately after formatting,
the script runs unfiltered `cargo test -p linkedspec-core`, then unfiltered `cargo test -p linkedspec-runtime`.
The core package owns the Rust `.spec` parser, compiler, validation, descriptor, and compiled serialization types;
its previously recorded proof included 193 unit tests, four descriptor integration tests, five contract-driven
normalization tests, and eight type integration tests. A
runtime dependency build alone never substitutes for those tests.

`LINKEDSPEC_CARGO_CMD` selects the Cargo executable. Repository-local `CARGO_TARGET_DIR` selects the build directory
and is also used to locate the built primary binary. For a targeted command use `bash tools/run_cargo_local.sh ...`;
it self-roots and enters managed storage. The recurring storage oracle checks temporary owners, the offline Cargo cache,
generated projects, traces,
and copied-binary relocation. The 17-owner / 195-package measurement belongs to the earlier record.

The canonical `tools/run_ci_local.sh` requires native toolchains for its mandatory backend consumers,
including Rust admissions, even with all optional gates disabled. `LINKEDSPEC_RUN_RUST=1` selects the
additional complete Rust gate described here. Mandatory selected consumers and full-package execution are
distinct scopes: for example, .3.3.61 ran 16 selected MCP library tests with 162 unrelated tests filtered out.
Startup repair `SESSION-STARTUP-READING.41.7` owns the corresponding stale public CI teaching.

`.1.5.2.4` also proves the
historical gate introduction. Rule-local cursor slice `.9.1.4.6` removes the retired flag and request-trace field;
the gate passed that then-current 63-case manifest in both environments. Root-selection admission has since
expanded the shared reference to 65 and the current manifest is 66. Preflight `.9.1.1.2.2.0` measured the
historical 64/65 boundary; Rust core/routes/admission leaves now converge the gate to 66/66 twice and retain the topology-checked
15-role root-selection consumer. The complete optional gate was green in the dated record; .3.3.61 did not enable it.

For exact cross-backend command identity, `tools/run_primary_cli_matrix.sh` builds Rust and combines this command
with Perl, Dart, Julia, and Lua across both environments. `.1.5.4.3` owns the original 4x2x61 proof; Lua `.7.2`
extends the same matrix to 5x2x61.

Related facts: [[neutral-cli-fixture-runner]], [[rust-canonical-primary-cli-trace]],
[[hosted-ci-disabled-run-local-gate]], [[dart-local-verification-gate]],
[[julia-local-verification-gate]], [[primary-cli-four-backend-matrix]], [[rust-project-data-ssd-storage]].
