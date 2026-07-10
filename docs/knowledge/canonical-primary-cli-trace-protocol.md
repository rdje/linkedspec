---
id: canonical-primary-cli-trace-protocol
title: Every primary CLI uses one deterministic phase trace while native embedding keeps rich backend events
answers:
  - what trace format must every LinkedSpec primary CLI emit
  - why does primary CLI trace differ from native embedding trace
  - what events does low medium high full debug CLI trace add
  - are primary CLI trace records allowed to contain timestamps or source paths
  - how do stdout route mirror reset and trace files behave
  - what emoji prefixes does canonical CLI trace use
  - are none and quiet trace levels silent
  - how many neutral CLI cases pass after trace conformance
  - what did FUTURE-PARITY-BACKLOG.1.5.1.5 implement
  - what does ADR 0024 decide
date: 2026-07-10
status: accepted
tags: [cli, trace, protocol, deterministic, utf8, backends, ADR-0024, FUTURE-PARITY-BACKLOG]
evidence: "ADR 0024 and FUTURE-PARITY-BACKLOG.1.5.1.5 define canonical primary phase trace; 20 exact trace cases brought Perl to 53/53, and FUTURE-PARITY-BACKLOG.1.5.1.6.2 adds eight UTF-8 cases for the current 61/61 default/POSIX suite."
reverify: "PERL5LIB= perl tools/run_cli_conformance.pl --display-command 'perl bin/linkedspec' -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec && POSIXLY_CORRECT=1 PERL5LIB= perl tools/run_cli_conformance.pl --display-command 'perl bin/linkedspec' -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec && PERL5LIB= prove -v -Iperl t/trace_cli.t"
---

ADR `0024` separates two valid trace surfaces:

- Native in-memory APIs retain rich backend-internal scopes, decisions, marks,
  source locations, generated-handler events, and dumps.
- Every primary command emits the same concise phase protocol as exact UTF-8
  `[linkedspec][LEVEL] EVENT` records.

The split is necessary for exact user-facing parity. Before `.1.5.1.5`, a
one-token Perl command produced about 1.7 MB at `low` and 6.8 MB at `high`, with
timestamps, Perl source locations, and emoji wide-character stderr warnings.
Those internals remain useful through embedding but cannot be a deterministic
cross-language command contract.

Canonical thresholds are:

- `low` / 100: compile, input, and invoke start/outcome;
- `medium` / 200: source/input kinds, top rule, and parse mode;
- `high` / 300: UTF-8 argument and loaded-input byte counts;
- `full` / 400: canonical JSON byte length;
- `debug` / `verbose` / 500: protocol version;
- `none` / `quiet` / numeric values at or below zero: no records.

No record contains a timestamp, host path, module/function name, source line,
pointer identity, or backend name. Emoji prefixes are exact UTF-8 `ℹ️`, `🔎`,
`🧭`, `🐞`, and `🔥` from low through debug.

High-level counts measure process/file UTF-8 bytes without double-encoding an
already byte-oriented host value. User-controlled field data cannot inject a
second record: each UTF-8 byte outside `[A-Za-z0-9_.:-]` is rendered as uppercase
`%HH`, while `<default>` is the reserved absent-top-rule marker.

A file with no explicit mode implies `route`; otherwise the default is stdout.
`stdout` leaves a selected file unchanged, `route` keeps stdout JSON/failure
channels clean, and `mirror` writes byte-identical trace to stdout and file.
Reset truncates a selected file even at none/quiet; without reset it persists or
appends. Explicitly traced failure records the portable phase error and retains
stable operational stderr/exit behavior.

Twenty trace cases lock stdout, route+reset+emoji, mirror+reset, stdout with an
unchanged selected file, none+reset, quiet, every named level/alias, a numeric
threshold, default route, append, UTF-8 byte counts, escaped user fields, and all
three routed failure phases. Together with help/usage/success/failure, Perl passed
53/53 at trace closure; eight later strict UTF-8 cases make the current suite 61/61
in both option environments.
`tools/run_ci_local.sh` executes this same manifest twice before Phase 0.

Related facts: [[user-observable-backend-cli-parity-contract]],
[[neutral-cli-fixture-runner]], [[trace-cli-control]],
[[trace-verbosity-and-formatting]], [[perl-primary-cli-operational-failures]],
[[cross-backend-cli-contract-gap]], [[primary-cli-utf8-process-boundary-gap]].
