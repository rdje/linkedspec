---
id: perl-primary-cli-conformance-audit
title: Perl primary CLI audit split strict arguments and output-channel normalization
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
evidence: "FUTURE-PARITY-BACKLOG.1.5.1.0 audited positionals, case/abbreviation/negation aliases, POSIXLY_CORRECT drift, GetOptions warnings, and DUMP_NONE failure trace; .1-.4 now close runner/help/arguments/success/failure while .5 retains trace."
reverify: "PERL5LIB= prove -v -Iperl t/trace_cli.t; sed -n '1,260p' bin/linkedspec; rg -n 'DUMP_NONE|sub log_output|sub trace_decision' perl/LinkedSpec/Trace.pm perl/LinkedSpec/Validation.pm perl/LinkedSpec/Compiler.pm; rg -n 'FUTURE-PARITY-BACKLOG\.1\.5\.1' docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

`bin/linkedspec` is parser-oriented and already exposes ADR `0023`'s intended
option names, canonical JSON success output, and 0/1/2 status classes. Its two
existing `t/trace_cli.t` subtests pass. At the `.1.5.1.0` audit boundary it was
not yet a strict, deterministic cross-backend reference.

Direct process probes established these facts at the `.1.5.1.0` audit boundary:

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

`.1.5.1.1` through `.1.5.1.4` have since added the neutral runner/help baseline,
replaced the argument boundary with an explicit exact parser, and locked seven
successful IO/control plus four operational failure families. The historical
positionals/aliases/environment/warning/stdout defects above are now closed;
deterministic explicit trace remains owned by `.5`.

`FUTURE-PARITY-BACKLOG.1.5.1` is split into neutral harness/help (`.1`, now done), strict
arguments (`.2`, now done), success/source/input/parser controls (`.3`, now done),
operational failure normalization (`.4`, now done), and trace/final Perl gate (`.5`). Rust, Dart, and
Julia will later consume the same manifest; they do not get backend-specific
fixture forks.

Related facts: [[user-observable-backend-cli-parity-contract]],
[[cross-backend-cli-contract-gap]], [[trace-cli-control]],
[[trace-verbosity-and-formatting]], [[julia-primary-cli-process-conformance]],
[[neutral-cli-fixture-runner]], [[perl-primary-cli-strict-arguments]],
[[perl-primary-cli-success-conformance]], [[perl-primary-cli-operational-failures]].
