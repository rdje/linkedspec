---
id: trace-verbosity-and-formatting
title: LinkedSpec::Trace owns all trace state — verbosity, indentation, formatting, and output routing — with UVM-style verbosity levels and lazy Data::Dumper loading
answers:
  - "how does trace work in linkedspec"
  - "what are the verbosity levels"
  - "how do I configure trace output"
  - "where does log_output go"
  - "can I set DUMP_VERBOSITY directly"
date: 2026-06-12
status: current
tags: [trace, diagnostics, verbosity, formatting]
evidence: "perl/LinkedSpec/Trace.pm; LinkedSpec.pm facade wrappers; TRACE-OBSERVABILITY.1 measured that facade-level $LinkedSpec::DUMP_VERBOSITY assignment before lazy Trace load does not enable log_output, while configure_trace/env/per-call options do"
reverify: "rg -n 'DUMP_NONE|DUMP_DEBUG|configure_trace|trace_log_file|trace_reset_log' perl/LinkedSpec.pm perl/LinkedSpec/Trace.pm docs/tasks/TRACE-OBSERVABILITY.md"
---

`LinkedSpec::Trace` is the sole owner of trace state, formatting, indentation, verbosity,
and output routing. It is reached through `LinkedSpec::OwnerDispatch` by all consumers.

**Verbosity levels** (UVM-style, defined as constants in `LinkedSpec.pm`):
- `DUMP_NONE` (0) — no output
- `DUMP_LOW` (100) — essential: errors, final results
- `DUMP_MEDIUM` (200) — standard: parse results, generated spec
- `DUMP_HIGH` (300) — detailed: rule info, handlers
- `DUMP_FULL` (400) — very detailed: DSL transformations
- `DUMP_DEBUG` (500) — maximum detail

**Public globals** (re-exported via typeglob aliasing in `LinkedSpec.pm`):
`$DUMP_VERBOSITY`, `$TRACE_LOG_FILE`, `$TRACE_LOG_MODE`, `$TRACE_EMOJI`,
`$TRACE_INDENT_LEVEL`, `$TRACE_INDENT_WIDTH`, `$TRACE_TOPIC_SPACING`, `$TRACE_INITIALIZED`.

**Key entrypoints**: `configure_trace`, `trace_enter`/`trace_exit` (scoped), `trace_decision`
(branch logging), `log_output` (verbosity-gated), `log_dump` (preformatted payloads),
`should_dump` (verbosity threshold check).

Use `configure_trace(...)`, per-call trace options, or `LINKEDSPEC_TRACE_*` environment variables to control trace.
The facade's package-variable aliases are compatibility state, not the reliable configuration path before the lazy
`LinkedSpec::Trace` owner has loaded.

The module lazily loads `Data::Dumper` only when needed for structured dumps, keeping the
common no-dump path fast.

Related: [[runtimecontext-boundary]], [[ownerdispatch-shared-seam]].
