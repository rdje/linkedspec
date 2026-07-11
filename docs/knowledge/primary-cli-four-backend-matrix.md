---
id: primary-cli-four-backend-matrix
title: One recurring warmed matrix proves exact primary CLI identity across all implemented backends
answers:
  - how do I run primary CLI parity across Perl Rust Dart and Julia
  - what does tools run_primary_cli_matrix sh do
  - how many primary CLI matrix cases pass
  - does the four backend matrix run POSIXLY_CORRECT
  - how does the CLI matrix handle Julia precompile output
  - how do I include the primary CLI matrix in local CI
  - what did FUTURE-PARITY-BACKLOG 1.5.4.3 implement
date: 2026-07-10
status: current
tags: [cli, parity, matrix, perl, rust, dart, julia, ci, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.4.3 adds tools/run_primary_cli_matrix.sh; Perl/Rust/Dart/Julia pass one unchanged 61-case manifest under default and POSIX environments (4x2x61), with focused backend gates and Phase 0 1..1028 also green."
reverify: "bash tools/run_primary_cli_matrix.sh && rg -n 'LINKEDSPEC_RUN_CLI_MATRIX|run_primary_cli_matrix' tools/run_ci_local.sh README.md docs/linkedspec-book/src/development/local-ci-and-regression.md"
---

Run `bash tools/run_primary_cli_matrix.sh` from the repository root. The driver validates the Perl, Cargo, Dart,
and Julia commands; builds the Rust primary binary; prepares and warms the Dart project; explicitly warms the
normal Julia project; and then invokes `tools/run_cli_conformance.pl` against all four commands.

Each backend receives the same unchanged manifest twice: once with `POSIXLY_CORRECT` unset and once with it set.
Each leg contains 61 exact cases, so a green run proves 4 backends x 2 environments x 61 cases. Expected help uses
only the command-token placeholder; stdout, stderr, exit status, and generated files remain otherwise identical.

Warmup is part of the driver because Dart compilation and Julia precompilation may emit toolchain progress before
application code. Once warmed, the exact process-byte comparison owns LinkedSpec behavior. The matrix is optional
from the core gate so ordinary Perl/core work does not require every SDK:

```bash
LINKEDSPEC_RUN_CLI_MATRIX=1 bash tools/run_ci_local.sh
```

The focused Rust, Dart, and Julia gates remain separate owners of native/package/corpus depth. The matrix owns
cross-backend command identity and closes exact CLI parent `.1.5`; active `.1.6` owns broader capability census.

Related facts: [[neutral-cli-fixture-runner]], [[cross-backend-cli-contract-gap]],
[[canonical-primary-cli-trace-protocol]], [[rust-local-verification-gate]], [[dart-local-verification-gate]],
[[julia-local-verification-gate]], [[primary-cli-strict-utf8-text-contract]].
