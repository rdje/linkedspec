---
id: primary-cli-four-backend-matrix
title: One recurring warmed matrix proves exact primary CLI identity across all implemented backends
answers:
  - how do I run primary CLI parity across Perl Rust Dart Julia and Lua
  - what does tools run_primary_cli_matrix sh do
  - how many primary CLI matrix cases pass
  - does the five backend matrix run POSIXLY_CORRECT
  - how does the CLI matrix handle Julia precompile output
  - how do I include the primary CLI matrix in local CI
  - what did FUTURE-PARITY-BACKLOG 1.5.4.3 implement
date: 2026-07-15
status: current
tags: [cli, parity, matrix, perl, rust, dart, julia, lua, ci, FUTURE-PARITY-BACKLOG, LUA-BACKEND-PARITY]
evidence: "FUTURE-PARITY-BACKLOG.1.5.4.3 adds tools/run_primary_cli_matrix.sh at 4x2x61; LUA-BACKEND-PARITY.7.2 adds a disposable PUC Lua native build and extends the unchanged recurring manifest to Perl/Rust/Dart/Julia/Lua at 5x2x61."
reverify: "bash tools/run_primary_cli_matrix.sh && rg -n 'LINKEDSPEC_RUN_CLI_MATRIX|run_primary_cli_matrix' tools/run_ci_local.sh README.md docs/linkedspec-book/src/development/local-ci-and-regression.md"
---

Run `bash tools/run_primary_cli_matrix.sh` from the repository root. The driver validates the Perl, Cargo, Dart,
Julia, and PUC Lua commands; builds the Rust primary binary; prepares and warms the Dart project; explicitly warms
the normal Julia project; builds Lua's native adapters in disposable temporary storage; and then invokes
`tools/run_cli_conformance.pl` against all five commands.

Each backend receives the same unchanged manifest twice: once with `POSIXLY_CORRECT` unset and once with it set.
Each leg contains 61 exact cases, so a green run proves 5 backends x 2 environments x 61 cases. Expected help uses
only the command-token placeholder; stdout, stderr, exit status, and generated files remain otherwise identical.

Warmup is part of the driver because Dart compilation and Julia precompilation may emit toolchain progress before
application code. Once warmed, the exact process-byte comparison owns LinkedSpec behavior. The matrix is optional
from the core gate so ordinary Perl/core work does not require every SDK:

```bash
LINKEDSPEC_RUN_CLI_MATRIX=1 bash tools/run_ci_local.sh
```

The focused Rust, Dart, Julia, and Lua gates remain separate owners of native/package/corpus depth. The original
four-backend matrix closed exact CLI parent `.1.5`; Lua `.7.2` extends the same command-identity proof without
changing the still-four-backend capability census.

Related facts: [[neutral-cli-fixture-runner]], [[cross-backend-cli-contract-gap]],
[[canonical-primary-cli-trace-protocol]], [[rust-local-verification-gate]], [[dart-local-verification-gate]],
[[julia-local-verification-gate]], [[lua-primary-cli-recurring-admission]],
[[primary-cli-strict-utf8-text-contract]].
