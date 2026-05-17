# Trace API

LinkedSpec exposes a structured trace system for debugging compiler internals, following parser invocation, and controlling diagnostic output.

The trace API is a first-class public surface on the `LinkedSpec` facade. It delegates to `LinkedSpec::Trace`, the trace state and formatting owner.

## Trace entry points

### `configure_trace(%opts)`

Configures trace verbosity, output routing, and formatting. Returns a hashref of effective settings.

```perl
LinkedSpec::configure_trace(
  verbosity => 300,       # DUMP_HIGH
  log_file  => 'debug.log',
  log_mode  => '>>',      # append or overwrite
);
```

Key options:
- `verbosity` — numeric verbosity threshold (see levels below)
- `log_file` — file path for trace output (when not set, output goes to the console)
- `log_mode` — file-open mode (`>` for overwrite, `>>` for append)

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

Writes a preformatted payload through the trace routing system. Useful for Data::Dumper-style debug output. Returns `undef`.

### `should_dump($level)`

Returns true when the current verbosity threshold enables output at the given level. Convenience helper for gating expensive trace computation.

```perl
if (LinkedSpec::should_dump(300)) {
  # build expensive debug output
}
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

These variables provide direct read/write access to trace state without calling `configure_trace`. Setting `$DUMP_VERBOSITY` to `300` has the same effect as `configure_trace(verbosity => 300)`.

## Typical usage

The trace API is used throughout the compile pipeline, runtime handler execution, and parser invocation. The consistent scope naming makes it possible to follow a single parse through nested trace output:

```text
LinkedSpec::parser_invoke:Top
  -> resolve_top_rule_handler
  -> invoke_top_rule:Top
    -> LinkedSpec::rule_handler:Top
    <- LinkedSpec::rule_handler:Top (returned hashref)
  <- invoke_top_rule:Top (completed)
<- LinkedSpec::parser_invoke:Top (returned AST)
```

Each `->` and `<-` pair corresponds to a `trace_enter`/`trace_exit` call. Decision events appear inline without indent changes.

The trace API is intentionally kept separate from the structured `last_error` diagnostics channel. Trace output is for developers and debugging; structured `last_error` payloads are for callers programmatically handling failures.
