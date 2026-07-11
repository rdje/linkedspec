# Trace API

LinkedSpec exposes a structured trace system for debugging compiler internals, following parser invocation, and controlling diagnostic output.

The trace *capability contract* is variant-agnostic. Every LinkedSpec variant that claims trace parity must support the documented capability semantics: configurable verbosity levels, structured enter/exit scopes, decision/branch events, mark/capture position events where applicable, dump/log output, and route/mirror/stdout-style sink control. Concrete function names, package variables, file handles, environment variables, and internal decision names may be variant-specific, but the externally observable trace capabilities must be equivalent across the Perl reference backend, the Rust backend, and future variants.

This chapter documents the concrete trace API of the **Perl reference backend** — its function names and signatures, the constants exported by `use LinkedSpec`, and the package-variable state surface (including the typeglob-aliased state below) are Perl-reference specifics. Another backend exposes an equivalent trace facility in its own idiom.

In the Perl reference backend, the trace API is a first-class public surface on the `LinkedSpec` facade. It delegates to `LinkedSpec::Trace`, the trace state and formatting owner.

## Variant-neutral trace contract

The portable contract is behavioral, not package-name based. A variant that claims trace parity must provide:

- ordered trace levels equivalent to `none`, `low`, `medium`, `high`, `full`, and `debug`;
- controls that can be used from that variant's normal entrypoints without changing parse results;
- sink routing equivalent to stdout, routed trace file, and mirrored stdout+file output, including reset/truncate behavior for routed files;
- structured scope events for meaningful compile, parser, and runtime-handler entry/exit boundaries;
- structured decision or branch events for control-flow choices, including generated or interpreted runtime dispatch branches;
- mark/capture/source-position events where the variant implements those source-boundary features;
- dump/log events for deeper diagnostic payloads at higher verbosity;
- a default quiet mode where tracing is disabled and normal output remains unchanged.

Perl reference event names such as `rule_ir:...`, `emit_context:...`, `actionir:...`, and
`generated_handler_branch:...` are the current reference vocabulary. Other variants may use native names, but a
user reading this book must be able to ask the same trace questions and observe equivalent externally documented
behavior.

## Dart variant trace status

Dart exposes `LinkedSpecTraceEmitter` with the same ordered levels, structured event kinds, default quietness, and
stdout/route/mirror sink model used by its native runtime. Core frontend/compiler entrypoints accept one optional
caller-owned emitter without replacing their existing quiet API:

```dart
final trace = LinkedSpecTraceEmitter(
  LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
);

final spec = parseSpec(source, trace: trace);
final compiled = compileSpec(spec, trace: trace);
final result = LinkedSpecRuntimeEngine(compiled).execute(input, trace: trace);
```

`parseSpec(...)`, `validateSpec(...)`, `compileSpec(...)`, and `UserFunctionRegistry.fromSpec(...)` /
`fromFunctions(...)` now accept `trace:`. Their `dart_frontend:*` and `dart_compiler:*` events cover balanced parse,
validation, compilation, and registry scopes; rule/function/dependency decisions; and balanced failure exits.
Omitting the parameter preserves the original direct path. A disabled emitter records and writes nothing, and
focused tests compare parsed and compiled JSON exactly between traced and untraced execution.

This is a deliberately partial status, not yet a full-pipeline parity claim. Function-definition extraction and
staged parse-job dispatch still need to propagate the same emitter under `.1.6.5.2`; native loader composition and
final recurring admission remain under `.1.6.5.3`.

## Rust variant trace status

As of `TRACE-OBSERVABILITY.4.5`, the Rust variant claims trace parity for the mdBook-documented external capability
contract. This claim is behavioral: Rust does not reuse Perl package names or every Perl-internal event namespace,
but it exposes equivalent documented levels, controls, sinks, event classes, default-quiet behavior, and regression
proof.
Rust now has ordered trace levels, configuration, stdout/route/mirror sinks, reset/truncate behavior, event
primitives, opt-in traced entrypoints beside the existing quiet entrypoints, and routed debug events for
`parse_spec`, validation passes, `compile`, dependency-regex mapping, user-function definition parsing, full-spec
function projection, and staged parse-job normalize/resolve/load/compile/execute phases. Runtime branch and
mark/capture event coverage now includes interpreted `Engine::execute_with_trace(...)` and generated-plan
`Engine::execute_generated_with_plan_with_trace(...)` execution.

The required Rust mapping is:

- shared trace levels, configuration, sink routing, and event primitives are reachable from `linkedspec-core`,
  because Rust parser, validation, compiler, dependency-regex, and compiled-type owners live there;
- `linkedspec-runtime` reuses the same model for `parse_spec_with_user_functions`, staged parser dispatch,
  `Engine::execute`, `Engine::execute_generated_with_plan`, `source_emitter::execute_generated_parser`, and
  generated parser modules;
- compile-side trace events now cover `parse_spec`, `validate`, `compile`, dependency-regex resolution, full
  user-function source parsing, and staged parse-job normalize/resolve/load/compile/execute phases;
- runtime trace events now cover rule entry/exit, recursion cutoffs, acode/bcode child dispatch, regex
  match/no-match choices, AND/OR and repetition control flow, lifecycle block execution, statement-form
  `if`/`switch` branch selection, mark/capture helper operations, and generated-rule family plan dispatch;
- existing untraced APIs remain default-quiet and output-compatible; explicit traced entrypoints validate trace
  setup, route sinks, emit compile/spec-parser/staged-dispatch/runtime events, and preserve parse/compile/runtime
  results.

The Rust control surface is:

- `linkedspec_core::trace::{TraceConfig, TraceLevel, TraceSinkMode, TraceEmitter}` plus `DUMP_NONE`,
  `DUMP_LOW`, `DUMP_MEDIUM`, `DUMP_HIGH`, `DUMP_FULL`, and `DUMP_DEBUG`;
- `linkedspec_runtime::trace`, which re-exports the same core trace module for runtime users and generated modules;
- `TraceConfig::from_env()`, using the same `LINKEDSPEC_TRACE_LEVEL`, `LINKEDSPEC_DUMP_VERBOSITY`,
  `LINKEDSPEC_TRACE_FILE`, `LINKEDSPEC_TRACE_MIRROR_STDOUT`, `LINKEDSPEC_TRACE_RESET_FILE`, and
  `LINKEDSPEC_TRACE_EMOJI` controls documented for the portable contract;
- route/mirror/stdout behavior through `TraceSinkMode`, with `with_trace_file(...)` defaulting to routed-file output
  and `with_reset_file(true)` truncating the file during trace setup;
- structured primitives on `TraceEmitter`: `emit_event`, `enter_scope`, `exit_scope`, `trace_decision`,
  `log_output`, and `log_dump`.

The Rust opt-in traced entrypoints are:

- `linkedspec_core::parser::parse_spec_with_trace(...)` and `parse_spec_with_trace_emitter(...)`;
- `linkedspec_core::validation::validate_with_trace(...)` and `validate_with_trace_emitter(...)`;
- `linkedspec_core::compiler::compile_with_trace(...)` and `compile_with_trace_emitter(...)`;
- `linkedspec_runtime::spec_parser::parse_spec_with_user_functions_with_trace(...)` and
  `parse_spec_with_user_functions_with_trace_emitter(...)`;
- `linkedspec_runtime::spec_parser::parse_user_function_definition_asts_with_trace(...)` and
  `parse_user_function_definition_asts_with_trace_emitter(...)`;
- `linkedspec_runtime::staged_parser_registry::execute_parse_job_with_trace(...)`,
  `execute_parse_job_with_trace_emitter(...)`, `execute_parse_jobs_with_trace(...)`, and
  `execute_parse_jobs_with_trace_emitter(...)`;
- `Engine::execute_with_trace(...)`, `Engine::execute_with_trace_emitter(...)`,
  `Engine::execute_generated_with_plan_with_trace(...)`, and
  `Engine::execute_generated_with_plan_with_trace_emitter(...)`;
- `source_emitter::execute_generated_parser_with_trace(...)`; newly emitted Rust parser modules also expose
  `parse_with_trace(input, trace_config)` beside the existing `parse(input)`.

Example Rust usage:

```rust
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_runtime::engine::Engine;

let trace = TraceConfig::enabled(TraceLevel::DEBUG)
    .with_trace_file("linkedspec.trace.log")
    .with_reset_file(true);

let output = Engine::new(compiled).execute_with_trace(input, trace)?;
```

Rust compile/spec-parser/staged-dispatch trace events are present as of `.4.3`; Rust interpreted and generated-plan
runtime branch/mark/capture events are present as of `.4.4`; `.4.5` closes the cross-variant parity proof and
records the reusable future-variant checklist.

## Dart variant trace status

As of `DART-BACKEND-PARITY.4.5.4`, Dart has trace controls and runtime interpreter trace events, but does not yet
claim full trace parity.

The Dart control surface is:

- `LinkedSpecTraceLevel` with ordered levels equivalent to `none`, `low`, `medium`, `high`, `full`, and `debug`;
- `LinkedSpecTraceConfig`, including `fromEnvironment(...)` for `LINKEDSPEC_TRACE_LEVEL`,
  `LINKEDSPEC_DUMP_VERBOSITY`, `LINKEDSPEC_TRACE_FILE`, `LINKEDSPEC_TRACE_MIRROR_STDOUT`,
  `LINKEDSPEC_TRACE_RESET_FILE`, and `LINKEDSPEC_TRACE_EMOJI`;
- `LinkedSpecTraceSinkMode` for stdout, routed-file, and mirror sinks;
- `LinkedSpecTraceEmitter` event primitives: `emitEvent`, `enterScope`, `exitScope`, `traceDecision`,
  `logOutput`, and `logDump`;
- `LinkedSpecRuntimeEngine.parse(..., trace: emitter)`, `execute(..., trace: emitter)`,
  `parseWithTrace(...)`, and `executeWithTrace(...)`.

The `.4.5.2` proof covers default-quiet behavior, level gating, routed-file reset/truncate, mirror output,
structured event classes, decision/log/dump primitives, and runtime traced entrypoints preserving parse output.
The `.4.5.3` proof adds runtime interpreter instrumentation: parse/rule scopes, regex match/no-match decisions,
action-edge and blind-call child-dispatch decisions, lifecycle block mark events, cursor-control mark events,
recursion-cutoff decisions, and `capture_until_boundary(...)` source-boundary mark events. `.4.5.4` closes the
Dart diagnostics/trace no-drift sweep across Dart status text, mdBook pages, live docs, task-tree index, and
Knowledge Map. `DART-BACKEND-PARITY.5.1` then adds the minimal staged registry provider, `.5.2` adds registered
exact-arity user-function runtime execution, and `.5.3` preserves staged parse-job/function-registry descriptor
shapes. `DART-BACKEND-PARITY.6.1` adds the controlled executable corpus harness, and final capability admission
expands it to full 105-fixture Dart corpus execution. `.6.4` wires the focused Dart local verification gate, `.7.1` closes Dart mdBook
usage/status/handoff documentation, `.7.2` defers generated Dart source to a future source-emitter lane, `.7.4`
productizes the Dart-specific CLI around the existing corpus/runtime command path, and `.7.5` closes the scoped
Dart milestone. Trace parity is unchanged by these staged/user-function/corpus/generated-source/CLI/closeout
leaves.

The complete capability census therefore records Dart runtime trace controls/events/sinks as passing, but native
frontend/compiler/function-shell/staged propagation as a separate gap. `FUTURE-PARITY-BACKLOG.1.6.5` owns one
caller-emitter path through those phases; canonical primary CLI trace remains independently closed.

## Julia variant trace status

As of `JULIA-BACKEND-PARITY.7.3.2.1`, Julia has stable structured runtime
diagnostics, trace controls/events/sinks, interpreter instrumentation, and
opt-in source-parser, validation, compiler, function-shell, and staged-dispatch
events. `.7.3.2.3` composes that emitter through native primary execution, and
`.7.3.2.4` closes Julia's sink/reset/emoji CLI behavior. `.7.3.2.5` now locks
routed/mirrored behavior across real processes; this still does not claim
complete backend or CLI parity.

`FUTURE-PARITY-BACKLOG.1.5.4.1` separates exact help, strict UTF-8 files, and
phase-only stderr from native diagnostics. `.1.5.4.2` now adds an adapter-local
canonical phase recorder around native operations and closes 61/61 shared cases
in both option environments. The native emitter and APIs below remain unchanged.

The Julia control surface is:

- `LinkedSpecTraceLevel` plus exported `LinkedSpecTraceNone`,
  `LinkedSpecTraceLow`, `LinkedSpecTraceMedium`, `LinkedSpecTraceHigh`,
  `LinkedSpecTraceFull`, and `LinkedSpecTraceDebug` values; named aliases and
  numeric thresholds are accepted by `parse_trace_level(...)`;
- `LinkedSpecTraceConfig`, `trace_config_from_environment(...)`, and immutable
  `with_trace_*` helpers for the documented `LINKEDSPEC_TRACE_*` controls;
- `LinkedSpecTraceSinkMode` values for stdout, routed-file, and mirror output,
  including reset/truncate behavior for routed files;
- `LinkedSpecTraceEmitter`, structured event/scope records, and
  `emit_trace_event!`, `enter_trace_scope!`, `exit_trace_scope!`,
  `trace_decision!`, `log_trace_output!`, and `log_trace_dump!` primitives;
- optional `trace=...` emitter injection on `parse_spec(...)`,
  `validate_spec(...)`, `compile_spec(...)`, function-definition projection/
  parsing entrypoints, `execute_staged_parse_job(s)(...)`,
  `dispatch_function_body_parse_jobs(...)`, and stitching/composition APIs;
- optional `trace=...` emitter injection on `runtime_parse(...)` /
  `runtime_execute(...)`, plus `runtime_parse_with_trace(...)` and
  `runtime_execute_with_trace(...)` config wrappers.

The `.4.5.2` proof covers default-quiet behavior, level/environment controls,
routed-file reset, mirror output, event JSON/rendering, decisions/logs/dumps,
parse-scope routing, and result preservation. `.4.5.3` adds `julia_runtime:rule`
scopes; regex, child-dispatch, and recursion decisions; lifecycle marks; all
four cursor-control transitions; and source-boundary marks/decisions. Traced
and untraced action, blind, and recursion paths preserve identical results.
Package status was `runtime-trace-events` at the `.4.5.4` runtime-trace boundary; that
mechanism label is historical, not the current overall backend status. The
current Julia package/CLI status is `runtime-corpus-primary-cli` after the
105/105 interpreter, 1,040 package assertions, and nine-family direct-process gates.

`.7.3.2.1` propagates one caller-owned emitter through the native pipeline. At
low level, `julia_frontend:parse_spec`, `julia_frontend:validate_spec`,
`julia_compiler:compile_spec`, function-shell operations, staged queue dispatch,
and runtime execution emit balanced scopes. At medium level, decisions report
parse results, individual validation passes/skips, function-registry and rule
compilation, dependency-regex construction, function-shell parser cache/source/
projection results, staged normalization/sorting, and staged
resolve/load/compile/execute phases. Error paths retain paired error-bearing exit
events. Omitting `trace` retains the direct quiet path; a disabled emitter writes
and records nothing.

Example Julia pipeline trace:

```julia
using LinkedSpecJulia

source = """
Top::
 /x/
 E { return(match_text()) }
"""

config = with_trace_reset_file(with_trace_file(
    trace_config_enabled(LinkedSpecTraceDebug),
    "linkedspec.trace.log",
))
trace = LinkedSpecTraceEmitter(config)

spec = parse_spec(source; trace = trace)
compiled = compile_spec(spec; trace = trace)
result = runtime_execute(LinkedSpecRuntimeEngine(compiled), "x"; trace = trace)
@assert result.value == "x"
```

The focused proof adds 28 assertions for success/failure events, routed output,
disabled quietness, and traced/untraced identity. At that leaf the complete Julia
package suite passed with 868 assertions and the focused corpus gate remained 99/99;
later CLI preparation/execution/failure-routing, strict-boundary tests, exhaustive pure-helper lock, and exact
empty-local-match position, marker-control, and anonymous/named capture locks bring the current total to 1,028
without trace or corpus drift.

## Future variant trace parity checklist

Any future LinkedSpec variant must satisfy this checklist before it claims trace parity:

- implement ordered trace levels equivalent to `none`, `low`, `medium`, `high`, `full`, and `debug`;
- expose trace controls from the variant's normal parse/compile/runtime entrypoints without changing results;
- support stdout, routed-file, and mirrored sink behavior, including reset/truncate for routed trace files;
- keep the default untraced mode quiet and output-compatible;
- emit structured enter/exit scope events for meaningful compile, parser, and runtime-handler boundaries;
- emit decision or branch events for control-flow choices, including runtime dispatch branches;
- emit mark/capture/source-position events wherever the variant implements those source-boundary features;
- provide dump/log primitives for higher-verbosity diagnostic payloads;
- prove routed trace output with focused tests for controls, sinks, scopes, decisions, dump/log events, and
  default-quiet behavior;
- update the task tree, Knowledge Map, and mdBook with the proof before the variant parity claim is durable.

## Command-line trace control

The Perl reference backend ships `bin/linkedspec`, and the Julia variant ships
`julia/bin/linkedspec_julia.jl`. ADR `0024` requires every primary command to
project these controls through one canonical phase protocol; Perl is the current
61-case reference after strict UTF-8 expansion. `linkedspec-rust` projects the same protocol independently of its
richer native trace API and `.1.5.2.4` closes all 61 unchanged cases in both option environments plus recurring
`tools/run_rust_local.sh` verification. Dart and Julia also independently project this protocol and pass 61/61
default/POSIX. `.1.5.4.3` now closes recurring four-command integration, not more trace semantics.

```sh
perl bin/linkedspec --spec-file demo.spec --input-file demo.txt \
  --trace debug \
  --trace-file linkedspec.trace.log \
  --trace-mode route \
  --trace-reset

julia --project=julia julia/bin/linkedspec_julia.jl \
  --spec-file demo.spec --input-file demo.txt \
  --trace debug \
  --trace-file linkedspec.trace.log \
  --trace-mode route \
  --trace-reset
```

The trace flags have the same sink/level meanings as the public APIs, but primary
commands do not expose backend-internal event text:

- `--trace LEVEL` -> `trace_level => LEVEL`
- `--trace-file PATH` -> `trace_log_file => PATH`
- `--trace-mode stdout|route|mirror` -> `trace_log_mode => ...`
- `--trace-reset` -> `trace_reset_log => 1`
- `--trace-emoji` -> `trace_emoji => 1`

Primary records are exact UTF-8 lines shaped as `[linkedspec][LEVEL] EVENT`. `low`
records compile/input/invoke start and outcome; `medium` adds request controls;
`high` adds byte counts; `full` adds JSON byte length; `debug`/`verbose` adds the
protocol version. `none`/`quiet` and numeric levels at or below zero are silent.
Byte counts measure process/file UTF-8 bytes without re-encoding byte-oriented
host values. User fields stay on one record: bytes outside `[A-Za-z0-9_.:-]`
are uppercase `%HH`, and `<default>` marks an absent top-rule selection.
The native API entry points below retain richer backend-internal scopes, decisions,
marks, source locations, and dumps.

The runner prints the parser result as canonical JSON on stdout. If trace output is routed to stdout, trace text
is intentionally interleaved with that JSON. Use `--trace-file ... --trace-mode route` when stdout must remain
machine-readable. A file implies `route` when no mode is explicit; `mirror` copies the same trace to stdout and
file; `stdout` does not append the selected file. `--trace-reset` still truncates that file before execution, and
`--trace-emoji` adds the shared level-specific emoji prefix without enabling a quiet trace.

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

### `LinkedSpec::Trace::trace_generated_handler_branch(%args)`

Owner-level helper for generated handler branch decisions. It is designed for emitted Perl handler templates and
returns the normalized boolean value of `taken`, so generated code can wrap a branch condition without changing the
branch result.

```perl
if (LinkedSpec::Trace::trace_generated_handler_branch(
  rule_label => 'Top',
  handler_kind => 'default',
  branch => 'acode_index',
  taken => ($$minfo{index} == 0),
  match_index => $$minfo{index},
  details => sub { 'expected_index=0' },
)) {
  ...
}
```

The helper accepts `rule_label` (or `label`), `handler_kind` (or `kind`), `branch`, `taken`, optional metadata such
as `match_index`, `call`, `pos`, `loop_count`, `rep_min`, and `rep_max`, plus `reason` or `details`. If `details`
is a coderef, LinkedSpec evaluates it only when the configured trace level enables the event. A details coderef
error is captured in trace text instead of changing the branch result. The default event level is `debug`.

The Perl reference generated handlers now use this helper for both non-repetition dispatch branches and repetition
loop branches. At `debug` trace level, emitted handler bodies report regex match/miss decisions, `LX` no-match
paths, acode index choices, AND sequence index checks, bcode child-call dispatch, bcode child-result checks, REP
loop entry, per-iteration success/failure, min-satisfied stop decisions, max-bound continuation/cutoff decisions,
and the bcode REP zero-progress cutoff. Current branch names include `match`, `no_match_lx`, `acode_index_<n>`,
`required_index_0`, `required_sequence_index`, `bcode_call_<Rule>`, `bcode_child_result`,
`bcode_no_child_match`, `loop_enter`, `iteration_result`, `miss_min_satisfied`, `max_continue`, `zero_progress`,
and `zero_progress_min_satisfied`.

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

The current Perl reference trace implementation covers broad compile-pipeline stages, parser invocation, per-rule runtime handler wrappers, selected decisions, dumps, mark/capture events, RuleIR planning decisions, EmitContext owner-bridge/rewrite-orchestration decisions, ActionIR scanner/canonical/diagnostic/rewrite-pipeline decisions, compact ActionIR lowerer decisions, `ActionIR::MethodLowering` helper-family/assignment/mutation/receiver-chain/fallback decisions, and generated-handler branch decisions for the Perl reference non-repetition and repetition templates.

In the Perl reference backend, the planned compile/ActionIR owner coverage is closed through MethodLowering. The
cross-variant trace parity proof is closed for Rust as of `TRACE-OBSERVABILITY.4.5`; future variants must satisfy
the checklist above before claiming parity.

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

Each `->` and `<-` pair corresponds to a `trace_enter`/`trace_exit` call. Decision events appear inline without indent changes. RuleIR planning emits `rule_ir:<phase>:<rule_label>:<decision>` decisions at `debug` level for rule-entry collection, lifecycle routing, handler-variant selection, action-mode/execution-shape planning, split-boundary marker lowering, and mixed-action validation. EmitContext bridge orchestration emits `emit_context:<phase>:<label>:<decision>` decisions at `debug` level for ActionIR owner package/callback resolution, dependency bundle selection, function-registry and bare-symbol-kind injection, compatibility fallback paths, canonical rewrite-pipeline use, and rule emit-context build boundaries. ActionIR owners emit `actionir:<owner>:<phase>:<label>:<decision>` decisions at `debug` level for scanner helper-event discovery, canonical queue/fallback decisions, unresolved helper diagnostics, rewrite RAW_PERL and unmatched-event fallbacks, compact expression/value/array/declaration/control-flow lowerer choices, MethodLowering helper-family/assignment/mutation/receiver-chain/fallback choices, source-span and contract skips, and implicit attached-if closure handling. Generated runtime-handler branches such as match/no-match dispatch, `if`/`elsif`, repetition min/max paths, and bcode/acode dispatch emit `generated_handler_branch:<handler_kind>:<rule_label>:<branch>` decisions at `debug` level in the Perl reference backend.

The trace API is intentionally kept separate from the structured `last_error` diagnostics channel. Trace output is for developers and debugging; structured `last_error` payloads are for callers programmatically handling failures.
