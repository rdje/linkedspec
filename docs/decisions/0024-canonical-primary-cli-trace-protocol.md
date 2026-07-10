# 0024 - Primary CLIs use one canonical phase-trace protocol; native embedding retains rich backend trace

- Date: 2026-07-10
- Status: accepted
- Tags: architecture, cli, trace, diagnostics, portability, cross-variant-parity

## Context

ADR `0022` makes native in-memory embedding the primary product contract and CLIs
thin secondary adapters. ADR `0023` requires those distinct primary commands to
have identical user-visible options, behavior, output, errors, and trace routing.

`FUTURE-PARITY-BACKLOG.1.5.1.5` measured the old Perl CLI projection before
fixture-locking it. A one-token parse emitted about 1.7 MB at `low` and 6.8 MB at
`high`. Records contained timestamps, Perl module/function/line locations, and
backend-internal compiler events. Emoji file routing also wrote host "Wide
character" warnings to stderr. That stream is useful through native embedding,
but it is nondeterministic, implementation-specific, and unsuitable as the exact
primary-command contract every backend must reproduce.

## Decision

1. **The primary CLI owns a canonical phase trace.** Its records use exact UTF-8
   lines shaped as `[linkedspec][LEVEL] EVENT`. No timestamp, host source path,
   module/function name, line number, pointer identity, or backend name appears.
2. **Events describe portable command phases.** `low` records compile, input,
   and invoke start/outcome. `medium` adds the source/input selector kinds, top
   rule, and parse mode. `high` adds UTF-8 argument/input byte counts. `full`
   adds canonical JSON byte length. `debug`/`verbose` adds protocol version.
   Numeric levels use the same `0/100/200/300/400/500` thresholds. Byte counts
   measure the UTF-8 process/file bytes: already-byte-oriented values are not
   encoded a second time, while host-decoded character values are encoded once.
   User-controlled field data is one-line-safe: every UTF-8 byte outside
   `[A-Za-z0-9_.:-]` becomes uppercase `%HH`; `<default>` remains the reserved
   absent-top-rule marker.
3. **`none` and `quiet` are silent.** Level `0` or below emits no trace record.
   Reset still truncates a selected file even when the selected level is silent.
4. **Sink behavior is exact.** Without an explicit mode, a selected file implies
   `route`; otherwise trace defaults to `stdout`. `stdout` writes no trace bytes
   to a selected file, `route` writes no trace bytes to stdout, and `mirror`
   writes byte-identical trace data to both. Without reset, files append/persist;
   with reset, the selected file is truncated before the first phase.
5. **Emoji is protocol data.** Event-level prefixes are UTF-8 `ℹ️`, `🔎`, `🧭`,
   `🐞`, and `🔥` for low through debug. Emoji never changes thresholds, routing,
   JSON, stderr, or exit status.
6. **Failure trace remains phase-stable.** An explicitly traced failure records
   the portable phase error and retains the stable operational stderr/exit
   contract. Host exception details do not enter the primary trace protocol.
7. **Native trace is not reduced.** Perl `LinkedSpec::Trace` and the equivalent
   host-language in-memory APIs retain their richer backend-internal events and
   controls. The CLI deliberately suppresses that native stream and emits the
   canonical adapter protocol instead.
8. **One manifest is the executable contract.** Exact trace stdout, stderr,
   files, reset/append, levels/aliases, UTF-8 counts, field escaping, emoji,
   success/failure, and exit behavior live in
   `cli_conformance/manifest.json`. Every backend consumes those same cases.

## Consequences

- Primary trace is concise, deterministic, UTF-8-clean, and reproducible across
  implementation languages.
- Users who need compiler/runtime internals use the native in-memory tracing API;
  users who need portable command automation use the canonical CLI trace.
- Rust, Dart, Julia, Lua, and later primary adapters must implement this protocol
  rather than expose their host-specific internal event streams.
- New portable CLI phases or fields require a protocol/fixture update across all
  active backends. Backend-only internal trace events do not.

## Links

- Parent contracts: ADR `0022`, ADR `0023`
- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md`
  (`FUTURE-PARITY-BACKLOG.1.5.1.5`)
- Fixture contract: `cli_conformance/manifest.json`
- Reference adapter: `bin/linkedspec`
- User documentation: `docs/linkedspec-book/src/appendix/backend-handoff.md`
