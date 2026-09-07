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
date: 2026-09-07
status: accepted
tags: [cli, trace, protocol, deterministic, utf8, backends, ADR-0024, FUTURE-PARITY-BACKLOG]
evidence: "Historical July proof: ADR 0024 defines canonical primary phase trace; Perl, Rust, Dart, and Julia then passed the same 61/61 default/POSIX cases through independent adapter projections. September 7 startup .3.3.27 reads the complete Rust adapter and passes current 66/66 default cases; later ADR 0044 removed parse-mode metadata."
evidence_update_2026_07_15_lua_adapter: "LUA-BACKEND-PARITY.7.1 implements the same independent canonical phase trace in Lua and passes diagnostic shared CLI 61/61 in default and POSIX environments; recurring matrix admission remains .7.2."
reverify: "bash tools/run_primary_cli_matrix.sh"
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
- `medium` / 200: source/input kinds and top rule (ADR `0044` removed the parse-mode field);
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
53/53 at trace closure; eight later strict UTF-8 cases made that historical suite 61/61
in both option environments. The current manifest contains 66 cases.
`tools/run_ci_local.sh` executes this same manifest twice for the Perl reference before Phase 0. Rust, Dart, and
Julia then independently closed the same 61 cases in both environments while retaining native rich trace.
`tools/run_primary_cli_matrix.sh` now composes all five primary commands in both option environments.

Related facts: [[user-observable-backend-cli-parity-contract]],
[[neutral-cli-fixture-runner]], [[trace-cli-control]],
[[trace-verbosity-and-formatting]], [[perl-primary-cli-operational-failures]],
[[cross-backend-cli-contract-gap]], [[primary-cli-utf8-process-boundary-gap]],
[[rust-canonical-primary-cli-trace]], [[rust-local-verification-gate]],
[[julia-canonical-primary-cli-trace]], [[primary-cli-four-backend-matrix]].
Lua implementation detail: [[lua-primary-cli-adapter]].

September 7 `SESSION-STARTUP-READING.3.3.27` completes Rust primary_cli.rs reading and
passes its current 66-case default-environment matrix. Its medium request record contains
source/input kinds and escaped top rule only; the old parse-mode field is retired. This is
fresh Rust/default proof, not a rerun of every backend or POSIX leg. Earlier evidence counts
above describe their dated milestones; the canonical fixture inventory remains authoritative.
