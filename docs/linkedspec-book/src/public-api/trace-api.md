# Trace API

LinkedSpec exposes a structured trace system for debugging compiler internals, following parser invocation, and controlling diagnostic output.

The trace *model* is backend-neutral: verbosity levels, structured enter/exit scopes, decision events, and output routing (console / file / mirror) are concepts any backend can offer. This chapter, however, documents the concrete trace API of the **Perl reference backend** — its function names and signatures, the constants exported by `use LinkedSpec`, and the package-variable state surface (including the typeglob-aliased state below) are Perl-reference specifics. Another backend exposes an equivalent trace facility in its own idiom.

In the Perl reference backend, the trace API is a first-class public surface on the `LinkedSpec` facade. It delegates to `LinkedSpec::Trace`, the trace state and formatting owner.

## Command-line trace control

The Perl reference backend ships a small command-line runner at `bin/linkedspec`. It exists to make the same trace controls discoverable without writing a custom driver script.

```sh
perl bin/linkedspec --spec-file demo.spec --input-file demo.txt \
  --trace high \
  --trace-file linkedspec.trace.log \
  --trace-mode route \
  --trace-reset
```

The trace flags map directly to the public API options:

- `--trace LEVEL` -> `trace_level => LEVEL`
- `--trace-file PATH` -> `trace_log_file => PATH`
- `--trace-mode stdout|route|mirror` -> `trace_log_mode => ...`
- `--trace-reset` -> `trace_reset_log => 1`
- `--trace-emoji` -> `trace_emoji => 1`

The runner prints the parser result as canonical JSON on stdout. If trace output is routed to stdout, trace text is intentionally interleaved with that JSON. Use `--trace-file ... --trace-mode route` when stdout must remain machine-readable.

## Trace entry points

### `configure_trace(%opts)`

Configures trace verbosity, output routing, and formatting. Returns a hashref of effective settings.

```perl
LinkedSpec::configure_trace(
  trace_level => 'high',          # or numeric: dump_verbosity => 300
  trace_log_file  => 'debug.log',
  trace_log_mode  => 'route',     # 'stdout', 'route', or 'mirror'
);
```

Key options:
- `trace_level` or `dump_verbosity` — verbosity name (`none`/`low`/`medium`/`high`/`full`/`debug`) or numeric threshold (see levels below)
- `trace_log_file` — file path for trace output (when not set, output goes to the console)
- `trace_log_mode` — output routing: `stdout` (console only), `route` (file only), or `mirror` (both)

### `trace_enter($topic, $details, $level)`

Emits a structured entry trace event. Returns a scope hashref to pass to `trace_exit`.

```perl
my $scope = LinkedSpec::trace_enter('my_operation', 'starting work', 300);
```

### `trace_exit($scope, $details, $level)`

Emits a structured exit trace event paired with a `trace_enter` scope. Returns `undef`.

```perl
LinkedSpec::trace_exit($scope, 'completed work', 300);
```

### `trace_decision($decision_name, $taken, $reason, $level)`

Emits a decision/branch trace message. `$taken` is a boolean (1 for yes, 0 for no); `$reason` is a human-readable string. Returns the normalized boolean value of `$taken`.

```perl
LinkedSpec::trace_decision('use_cache', 1, 'cache hit for rule Foo', 300);
```

### `log_output($level, $message, $context)`

Central trace/log entry point with verbosity gating. Output goes to console or file depending on `configure_trace` settings. Returns `undef`.

```perl
LinkedSpec::log_output(100, 'compilation failed', 'SpecEntry::compile_spec_entry');
```

### `log_dump($message, $opts)`

Writes a preformatted payload through the trace routing system. Useful for dumper-style debug output (e.g. Perl's `Data::Dumper`). Returns `undef`.

### `should_dump($level)`

Returns true when the current verbosity threshold enables output at the given level. Convenience helper for gating expensive trace computation.

```perl
if (LinkedSpec::should_dump(300)) {
  # build expensive debug output
}
```

### `LinkedSpec::Trace::trace_mark_event(%args)`

Emits a trace event for parser boundary marks. This is an owner-level function on `LinkedSpec::Trace`, not a `LinkedSpec` facade wrapper. Generated/runtime internals normally reach it through the runtime mark bridge; most callers configure tracing rather than calling this directly.

```perl
LinkedSpec::Trace::trace_mark_event(
  operation => 'mark_here',
  rule_label => 'Segment',
  mark_name => 'segment_start',
  string_ref => \$input,
  mark_pos => pos($input),
  level => 300,
);
```

## Verbosity levels

LinkedSpec uses UVM-style verbosity constants:

| Constant | Value | Meaning |
| --- | --- | --- |
| `DUMP_NONE` | 0 | No output |
| `DUMP_LOW` | 100 | Essential output only (errors, final results) |
| `DUMP_MEDIUM` | 200 | Standard output (parse results, generated spec) |
| `DUMP_HIGH` | 300 | Detailed output (rule info, handlers) |
| `DUMP_FULL` | 400 | Very detailed output (DSL transformations) |
| `DUMP_DEBUG` | 500 | Maximum detail (everything) |

These constants are exported by `use LinkedSpec` and are the standard way to set verbosity thresholds.

## Trace state variables

LinkedSpec exports public package variables that alias into `LinkedSpec::Trace` state:

- `$LinkedSpec::DUMP_VERBOSITY` — current verbosity threshold (see `configure_trace`)
- `$LinkedSpec::TRACE_LOG_FILE` — output file path
- `$LinkedSpec::TRACE_LOG_MODE` — file-open mode

Additional trace state variables are exported from LinkedSpec.pm via typeglob aliasing into `LinkedSpec::Trace`:

- `$TRACE_EMOJI` — emoji prefix toggle for trace banners
- `$TRACE_INDENT_LEVEL` — current indentation depth for nested trace scopes
- `$TRACE_INDENT_WIDTH` — spaces per indentation level
- `$TRACE_TOPIC_SPACING` — vertical spacing between trace topics
- `$TRACE_INITIALIZED` — flag set after first `configure_trace` call

Treat these variables as compatibility state, not the preferred control API. Use `configure_trace(...)`, per-call trace options, or the `LINKEDSPEC_TRACE_*` environment variables to configure tracing reliably. Assigning `$LinkedSpec::DUMP_VERBOSITY` before the lazy `LinkedSpec::Trace` owner has been loaded is not equivalent to `configure_trace(...)`, because the owner initializes its own state on first use.

## Typical usage

The current trace implementation covers broad compile-pipeline stages, parser invocation, per-rule runtime handler wrappers, selected decisions, dumps, and mark/capture events. It is not yet an exhaustive branch tracer for every generated handler body or every ActionIR lowering branch.

The consistent scope naming makes it possible to follow a single parse through nested trace output:

```text
LinkedSpec::parser_invoke:Top
  -> resolve_top_rule_handler
  -> invoke_top_rule:Top
    -> LinkedSpec::rule_handler:Top
    <- LinkedSpec::rule_handler:Top (returned hashref)
  <- invoke_top_rule:Top (completed)
<- LinkedSpec::parser_invoke:Top (returned AST)
```

Each `->` and `<-` pair corresponds to a `trace_enter`/`trace_exit` call. Decision events appear inline without indent changes. Generated runtime-handler branches such as match/no-match dispatch, `if`/`elsif`, repetition min/max paths, and bcode/acode dispatch are still a planned coverage extension rather than guaranteed current output.

The trace API is intentionally kept separate from the structured `last_error` diagnostics channel. Trace output is for developers and debugging; structured `last_error` payloads are for callers programmatically handling failures.
