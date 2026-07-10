---
id: perl-primary-cli-conformance-audit
title: Perl primary CLI needs strict option and output-channel normalization
answers:
  - does the Perl primary CLI reject positional arguments
  - does the Perl primary CLI accept abbreviated options
  - are Perl CLI long options case sensitive
  - does the Perl CLI accept no trace reset and no trace emoji
  - does POSIXLY_CORRECT change the Perl CLI
  - why does a Perl CLI failure write trace to stdout
  - what did FUTURE-PARITY-BACKLOG.1.5.1.0 find
  - how is neutral CLI fixture work split
date: 2026-07-10
status: current
tags: [perl, cli, conformance, getopt-long, trace, stdout, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.1.0 audits bin/linkedspec/t/trace_cli.t and direct processes: positionals, case/abbreviation/negation aliases, POSIXLY_CORRECT drift, GetOptions warnings, and DUMP_NONE failure trace on stdout are current gaps; .1-.5 own repair."
reverify: "PERL5LIB= prove -v -Iperl t/trace_cli.t; sed -n '1,260p' bin/linkedspec; rg -n 'DUMP_NONE|sub log_output|sub trace_decision' perl/LinkedSpec/Trace.pm perl/LinkedSpec/Validation.pm perl/LinkedSpec/Compiler.pm; rg -n 'FUTURE-PARITY-BACKLOG\.1\.5\.1' docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

`bin/linkedspec` is parser-oriented and already exposes ADR `0023`'s intended
option names, canonical JSON success output, and 0/1/2 status classes. Its two
existing `t/trace_cli.t` subtests pass. It is not yet a strict, deterministic
cross-backend reference.

Direct process probes establish these current facts:

- residual positional arguments are ignored and a valid command still exits `0`;
- long options are case-insensitive and unique abbreviations such as `--inl`
  are accepted;
- `trace-reset!` and `trace-emoji!` expose undocumented `--no-trace-*` aliases;
- `POSIXLY_CORRECT` changes abbreviation and option-order behavior because the
  `Getopt::Long` policy is not configured explicitly;
- an unknown option prints `GetOptions`' own warning before the CLI-owned usage
  error;
- compilation and missing-top-rule failures exit `1` and print structured stderr,
  but the library's visible `DUMP_NONE` events add timestamped/source-located
  records to stdout;
- missing input exposes host `$!` wording.

The level-zero events are intentional in the general trace owner, so the primary
CLI adapter must own stdout purity and a deterministic cross-backend projection
without silently changing the library-wide diagnostic contract.

`FUTURE-PARITY-BACKLOG.1.5.1` is split into neutral harness/help (`.1`), strict
arguments (`.2`), success/source/input/parser controls (`.3`), operational
failure normalization (`.4`), and trace/final Perl gate (`.5`). Rust, Dart, and
Julia will later consume the same manifest; they do not get backend-specific
fixture forks.

Related facts: [[user-observable-backend-cli-parity-contract]],
[[cross-backend-cli-contract-gap]], [[trace-cli-control]],
[[trace-verbosity-and-formatting]], [[julia-primary-cli-process-conformance]].
