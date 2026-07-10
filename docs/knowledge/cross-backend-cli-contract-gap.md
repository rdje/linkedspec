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
evidence: "JULIA-BACKEND-PARITY.7.3.0 finds Perl parser CLI, Dart/Julia corpus CLIs, and no Rust binary. ADR 0023 defines the target. Julia .7.3.2.2 now accepts/prepares exact options but .7.3.2.3 still owns execution/JSON; Dart/Rust/Perl normalization remains globally owned."
reverify: "sed -n '1,230p' bin/linkedspec; sed -n '1,330p' dart/lib/src/cli/linkedspec_dart_cli.dart; sed -n '1,220p' julia/src/cli/LinkedSpecJuliaCli.jl; rg -n '\[\[bin\]\]|^name =|^members =' rust/Cargo.toml rust/*/Cargo.toml; find rust -type f -path '*/src/bin/*' -print"
---

The implemented backend CLI surfaces are not currently interface-equivalent:

- Perl `bin/linkedspec` parses an arbitrary named, file-backed, or inline spec against literal or file-backed
  input. It exposes top-rule, parse-mode, and trace controls, prints canonical JSON, and distinguishes runtime
  failure (`1`) from usage failure (`2`).
- Dart `bin/linkedspec_dart.dart` is a manifest corpus validator/executor. Its options select corpus cases/windows,
  and it reports usage failure as `64`.
- Julia `bin/linkedspec_julia.jl` now accepts only the exact parser option contract, rejects subcommands/
  positionals as usage `2`, and prepares deterministic named/file/inline source plus literal/file input. Native
  execution and canonical JSON remain active `.7.3.2.3` work.
- The Rust workspace contains library crates and no binary target or `src/bin` entrypoint.

ADR `0006` already requires the same backend features and semantics. The director clarified that distinct backend
executable names must also expose the exact same command structure, option list and meanings, positional arguments,
outputs/errors, and exit semantics. `JULIA-BACKEND-PARITY.7.3.0` therefore splits durable contract/routing, Julia
repair, and honest no-drift work rather than treating 99/99 corpus execution as complete CLI parity.

ADR `0023` has since ratified the exact interface. `FUTURE-PARITY-BACKLOG.1.5` owns the neutral fixtures and
Perl/Rust/Dart/global repairs; `JULIA-BACKEND-PARITY.7.3.2` owns Julia's repair, now complete through preparation.

Related facts: [[user-observable-backend-cli-parity-contract]], [[variant-specific-cli-requirement]], [[native-in-memory-backend-contract]],
[[language-agnostic-backend-vision]], [[dart-specific-cli]], [[julia-mdbook-usage-status]],
[[julia-primary-cli-arguments-resolution-loading]].
