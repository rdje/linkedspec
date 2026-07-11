---
id: cross-backend-cli-contract-gap
title: Implemented backend CLIs do not yet expose one identical user-facing interface
answers:
  - do all LinkedSpec backend CLIs have the same options
  - are the Perl Rust Dart and Julia CLIs equivalent
  - does Rust have a LinkedSpec CLI binary
  - what does the current Perl CLI do
  - what do the current Dart and Julia CLIs do
  - why was JULIA-BACKEND-PARITY.7.3 split
date: 2026-07-10
status: current
tags: [cli, parity, perl, rust, dart, julia, JULIA-BACKEND-PARITY]
evidence: "Perl/Rust/Dart close 61/61 default/POSIX. FUTURE-PARITY-BACKLOG.1.5.4.1 advances Julia to 42/61 with only 19 canonical-trace residuals before the final matrix."
reverify: "bash tools/run_dart_local.sh; sed -n '1,220p' julia/src/cli/LinkedSpecJuliaCli.jl; rg -n 'FUTURE-PARITY-BACKLOG\.1\.5\.4|61/61' docs/tasks/FUTURE-PARITY-BACKLOG.md docs/TASK_TREE.md ROADMAP_V2.md"
---

The implemented backend CLI surfaces are not currently interface-equivalent:

- Perl `bin/linkedspec` parses an arbitrary named, file-backed, or inline spec against literal or file-backed
  input. It exposes top-rule, parse-mode, and trace controls, prints canonical JSON, and distinguishes runtime
  failure (`1`) from usage failure (`2`). `.1.5.1.5` closes canonical trace, and `.1.5.1.6` resolves the surfaced
  UTF-8 argv/JSON gap. Perl passes the complete 61-case default/POSIX reference; Rust `.1.5.2.4` closes the
  unchanged suite in both environments with exact direct execution, canonical trace, and recurring verification.
- Dart `bin/linkedspec_dart.dart` now passes the same 61 cases in both environments with native direct execution,
  canonical JSON/trace, strict UTF-8, and a recurring gate. `bin/corpus_runner.dart` remains separate at 99/99.
- Julia `bin/linkedspec_julia.jl` now accepts only the exact parser option contract, rejects subcommands/
  positionals as usage `2`, prepares deterministic named/file/inline source plus literal/file input, executes it
  through the native pipeline, emits recursively key-sorted direct JSON, renders exact shared help, rejects
  malformed UTF-8 files, and emits phase-only primary errors. It passes 42/61 default/POSIX; the 19 remaining
  differences are canonical trace, while native rich diagnostics/trace remain independent.
- The Rust workspace now contains `linkedspec-rust`. Exact arguments/loading, reusable direct-result/entry/mode
  execution, and canonical CLI trace pass all 61 shared cases in both environments; its primary lane is closed.

ADR `0006` already requires the same backend features and semantics. The director clarified that distinct backend
executable names must also expose the exact same command structure, option list and meanings, positional arguments,
outputs/errors, and exit semantics. `JULIA-BACKEND-PARITY.7.3.0` therefore splits durable contract/routing, Julia
repair, and honest no-drift work rather than treating 99/99 corpus execution as complete CLI parity.

ADR `0023` has since ratified the exact interface. `FUTURE-PARITY-BACKLOG.1.5` owns the neutral fixtures and
Perl/Rust/Dart repairs are closed; `JULIA-BACKEND-PARITY.7.3.2` owns Julia's local repair, complete through exact
local process conformance. Global `.1.5.4` now owns unchanged fixture identity and one recurring four-command gate;
`.1.5.4.0` records Julia's 13/61 baseline; `.1.5.4.1` advances it to 42/61. Active `.2` owns canonical trace and
`.3` the warmed recurring four-command gate.

Related facts: [[user-observable-backend-cli-parity-contract]], [[variant-specific-cli-requirement]], [[native-in-memory-backend-contract]],
[[language-agnostic-backend-vision]], [[dart-specific-cli]], [[julia-mdbook-usage-status]],
[[julia-primary-cli-arguments-resolution-loading]],
[[julia-primary-cli-native-execution-canonical-json]],
[[julia-primary-cli-failure-trace-routing]], [[julia-primary-cli-process-conformance]],
[[julia-scoped-parity-no-drift]], [[perl-primary-cli-conformance-audit]],
[[neutral-cli-fixture-runner]], [[perl-primary-cli-strict-arguments]],
[[perl-primary-cli-success-conformance]], [[perl-primary-cli-operational-failures]],
[[primary-cli-utf8-process-boundary-gap]], [[rust-canonical-primary-cli-trace]],
[[rust-local-verification-gate]], [[dart-primary-cli-closeout]], [[julia-global-cli-61-audit]].
Canonical trace: [[canonical-primary-cli-trace-protocol]].
