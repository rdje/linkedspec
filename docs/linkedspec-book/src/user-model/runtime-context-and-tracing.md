# Runtime Context and Tracing

LinkedSpec has a structured runtime-context story rather than only ad hoc dies and trace prints.

This chapter explains two related but separate tools:

- runtime context: durable state and structured failure payloads,
- tracing: optional visibility into compile/runtime execution.

They are not the same thing. Runtime context is the machine-readable continuity surface. Tracing is the human-readable observability surface.

Both are described here at the contract level. The runtime context is an abstract per-run object that a backend populates with run identity and structured failure payloads; the `last_error` schema, the owner/stage attribution, the handler source labels, the trace levels, and the trace output modes below are **backend-neutral contracts**. The concrete mechanics shown — how the context object is passed, how `last_error` is read, the trace API calls, and the `LINKEDSPEC_*` environment variables — are the **Perl reference backend's** surface; another backend exposes an equivalent in its own language.

## Runtime context

The runtime context is a caller-provided object (a hash in the Perl reference backend) that the backend can use while compiling and invoking parsers.

Pass it with:

```perl
my %ctx;

my $parser = LinkedSpec::Get(
  \$spec_source,
  runtime_ctx_ref => \%ctx,
);
```

You can also pass a scalar slot if you want LinkedSpec to install the hashref:

```perl
my $ctx;

my $parser = LinkedSpec::Get(
  \$spec_source,
  runtime_ctx_ref => \$ctx,
);

die "no runtime context" unless ref($ctx) eq 'HASH';
```

Both shapes exist because some callers already own a hash, while other callers want LinkedSpec to populate a shared slot.

The scalar-slot form is reusable. After the first call, `$ctx` holds the context hashref; passing `runtime_ctx_ref => \$ctx` again keeps that same hashref alive and refreshes LinkedSpec-owned fields for the new call. This applies to both public `LinkedSpec::Get(...)` and `LinkedSpec::get_parser(...)` entrypoints. If the slot already contains a non-hash reference, LinkedSpec rejects it as an invalid `runtime_ctx_ref` shape.

## What runtime context carries

The runtime context can carry useful execution information such as:

- selected `top_rule`
- `spec_name`
- `spec_path`
- structured `last_error`
- parser-source capture state when requested

For direct source compilation through `Get(...)`, `spec_name` and `spec_path` are normally empty because no file lookup happened:

```perl
my %ctx;
my $parser = LinkedSpec::Get(
  \$spec_source,
  runtime_ctx_ref => \%ctx,
);
```

For file-oriented compilation through `get_parser(...)`, the parser factory can preserve both the requested name and resolved path:

```perl
my %ctx;
my $parser = LinkedSpec::get_parser(
  'vhdl',
  runtime_ctx_ref => \%ctx,
);
```

If a later compile or parser-invocation failure occurs, that file identity can still be present in `last_error`. That continuity is intentional.

## Structured `last_error`

When a structured failure happens, LinkedSpec writes a hashref at:

```perl
$ctx{last_error}
```

Typical shape:

```perl
{
  type => 'compiler_pipeline',
  stage => 'build_final_descriptor',
  owner_stage => 'compiler_pipeline:build_final_descriptor',
  summary => 'Final descriptor assembly failed',
  detail => '...',
  spec_name => 'vhdl',
  spec_path => '/path/to/specs/vhdl.spec',
  top_rule => 'vhdl_file',
  rule_label => 'vhdl_file',
  handler_source_label => 'LinkedSpec::generated_handler:vhdl_file',
}
```

Not every field is guaranteed. The point is not to force a huge fixed schema everywhere. The point is to preserve the information the failing owner actually knows.

Common owner `type` values include:

- `parser_factory`
- `runtime_owner`
- `compiler_pipeline`
- `runtime_parser`
- `runtime_handler`

Common stages include:

- `prepare_parser_factory`
- `validate_spec_name`
- `resolve_spec_path`
- `load_spec_content`
- `compile_spec`
- `prepare_pipeline`
- `validate_spec_content`
- `validate_dsl_syntax`
- `bootstrap_parse`
- `build_compiled_rule_table`
- `build_final_descriptor`
- `validate_dependency_regex_references`
- `resolve_top_rule_handler`
- `validate_input_ref`
- `invoke_top_rule`

The `Get(...)`, `get_parser(...)`, and low-level `build_compiled_rule_table(...)` paths use the same shared runtime-context preparation owner before writing new diagnostics. That preparation clears stale `last_error`, refreshes stale file identity and selected-rule state for the current boundary, clears stale parser-source capture state where applicable, then seeds the selected `top_rule` when one is known.

`owner_stage` is the combined form:

```text
<type>:<stage>
```

That combined value is useful for logs, dashboards, and test assertions because it avoids losing the owner when stage names overlap.

## Example: reporting compile failure

A caller can inspect the structured failure instead of scraping the host language's raw error string (`$@` in the Perl reference backend):

```perl
my %ctx;
my $parser = LinkedSpec::Get(
  \$spec_source,
  runtime_ctx_ref => \%ctx,
);

if (!$parser) {
  my $err = $ctx{last_error};

  if (ref($err) eq 'HASH') {
    warn "LinkedSpec failed at $err->{owner_stage}: $err->{summary}\n";
    warn "$err->{detail}\n" if length($err->{detail} // '');
  }
}
```

This is the preferred error path for tools built around LinkedSpec. The host language's raw error string can still matter at parser-invocation boundaries (`$@` in the Perl reference backend), but `last_error` is the richer, backend-neutral machine-readable channel.

## Example: preserving file identity

`get_parser(...)` uses the parser-factory path, so it can preserve file identity:

```perl
my %ctx;

my $parser = LinkedSpec::get_parser(
  'vhdl',
  top_rule => 'vhdl_file',
  runtime_ctx_ref => \%ctx,
);

if (!$parser) {
  my $err = $ctx{last_error};

  warn "requested spec: $err->{spec_name}\n" if ref($err) eq 'HASH';
  warn "resolved path : $err->{spec_path}\n" if ref($err) eq 'HASH';
  warn "top rule      : $err->{top_rule}\n" if ref($err) eq 'HASH';
}
```

This is why runtime context is shared across parser factory, runtime, and compiler owners. A failure after file resolution should not erase the file that was successfully resolved earlier.

## Parser invocation failures

The same runtime context can be used after compilation.

The returned parser closes over the runtime context. When the parser is called, LinkedSpec clears stale `last_error` first, then writes a new structured payload if parser invocation fails.

Example:

```perl
my %ctx;
my $parser = LinkedSpec::Get(
  \$spec_source,
  runtime_ctx_ref => \%ctx,
);

if ($parser) {
  my $ok = eval {
    my $result = $parser->('not a scalar ref');
    1;
  };

  if (!$ok && ref($ctx{last_error}) eq 'HASH') {
    my $err = $ctx{last_error};
    warn "$err->{owner_stage}\n";
    warn "$err->{detail}\n";
  }
}
```

For invalid parser input, the structured stage is:

```text
runtime_parser:validate_input_ref
```

For a top-level handler failure, the stage is:

```text
runtime_parser:invoke_top_rule
```

For a rule handler failure deeper inside generated runtime behavior, the owner can be:

```text
runtime_handler
```

## Handler source labels

Generated handlers need readable attribution.

When LinkedSpec knows the rule label, diagnostics can include:

```perl
handler_source_label => 'LinkedSpec::generated_handler:Top'
```

When the selected handler variant is known, the label can become:

```perl
handler_source_label => 'LinkedSpec::generated_handler:Top:<variant>'
```

This matters because, in the Perl reference backend, generated source and `eval` are still part of how handlers run. A structured handler label gives users and tests a stable, backend-neutral way to identify the logical rule that owns a failure, regardless of how a given backend emits or executes its handlers.

Top-rule diagnostics derive that label from the shared runtime context, so runtime, parser-factory, and compiler failures use the same selected-rule attribution. Compiler diagnostics that know a concrete failing rule label prefer that rule label and fall back to the selected `top_rule` through the same shared runtime-context helper. Generated rule handlers also build labels from their compiled rule metadata through the runtime-context owner, including the selected handler variant when one is known. When the parser-invocation boundary knows the selected handler variant, that variant is included through the same shared helper.

## Parser-source capture

LinkedSpec can capture generated parser source for debugging and development.

Use:

```perl
my %ctx;
my $parser_source = '';

my $parser = LinkedSpec::Get(
  \$spec_source,
  runtime_ctx_ref => \%ctx,
  dump_parser_source => 1,
  parser_source_ref => \$parser_source,
);
```

When `dump_parser_source` is true, LinkedSpec collects emitted parser-source chunks in runtime context and flushes them at the end of generation.

If `parser_source_ref` is a scalar ref, the generated source is written into that scalar.

If `parser_source_ref` is not provided, the generated source is printed.

This low-level capture remains useful for inspection and debugging. Generated source itself is now a governed
public capability: application code should prefer `LinkedSpec::emit_generated_source(...)`, which returns the same
source directly, carries contract/version/source-identity metadata, reconstructs dependency alternations safely for
independent loading, validates its family plan, and exposes ordinary/traced execution roles.

## Tracing

Tracing exists to make runtime and compile behavior inspectable without turning the system into an opaque dynamic-eval black box.

The trace capabilities documented here are an external contract for every LinkedSpec variant. Backend-specific
names and implementation mechanics may differ, but trace parity means equivalent user-visible controls, verbosity
levels, event classes, and sink behavior.

A variant that claims trace parity must let users enable the same observable behavior from that variant's normal
entrypoints: ordered levels equivalent to `none` through `debug`, stdout/routed-file/mirror sink routing, reset
behavior for routed files, structured enter/exit events, decision or branch events, mark/capture events where source
boundaries exist, dump/log events, and unchanged default output when tracing is disabled.

The trace surface is useful for:

- understanding parser entry and dispatch
- seeing rule-handler boundaries
- inspecting decision points
- debugging mark/capture behavior

Current Perl reference coverage is useful and broad. LinkedSpec traces broad compiler/parser scopes, per-rule runtime
handler wrappers, selected decisions, dumps, mark/capture events, debug-level RuleIR planning decisions,
debug-level EmitContext owner-bridge/rewrite-orchestration decisions, debug-level ActionIR
scanner/canonical-event/diagnostic/rewrite-pipeline decisions, debug-level compact ActionIR lowerer decisions, and
debug-level `ActionIR::MethodLowering` helper-family/assignment/mutation/receiver-chain/fallback decisions. The
Perl reference backend also emits debug-level generated-handler branch decisions for non-repetition dispatch paths
and repetition loop paths.

In the Perl reference backend, the planned compile/ActionIR owner coverage is closed through MethodLowering. Rust
also satisfies the mdBook-documented external trace capability contract as of `TRACE-OBSERVABILITY.4.5`; future
variants must implement the same external capabilities before claiming trace parity.

As of `TRACE-OBSERVABILITY.4.5`, the Rust variant has the shared trace control surface, emits compile-side,
full-spec parser, staged parse-job dispatcher, interpreted runtime, and generated-plan runtime events, and claims
trace parity for the documented external contract.
`linkedspec-core::trace` owns `TraceLevel`, `TraceConfig`,
`TraceSinkMode`, `TraceEmitter`, the `DUMP_*` constants, environment-derived configuration, stdout/routed-file/
mirror sinks, routed-file reset, and structured event primitives. `linkedspec-runtime::trace` re-exports the same
module, and Rust exposes opt-in traced entrypoints beside the existing quiet APIs for core parse/validate/compile,
full-spec user-function parsing, staged parse jobs, interpreter execution, generated-plan execution, generated
parser execution, and newly emitted generated parser modules (`parse_with_trace(...)` beside `parse(...)`). Existing
Rust APIs remain default-quiet and output-compatible. Rust traced compile/spec-parser paths now report parse,
validation-pass, compile-rule, dependency-regex, user-function-definition parser, and staged-dispatch normalize/
resolve/load/compile/execute events. Rust traced runtime paths now report rule entry/exit, recursion cutoffs,
regex match/no-match decisions, acode/bcode child dispatch, lifecycle block execution, statement-form branch
decisions, mark/capture helper operations, and generated-rule family-plan dispatch. The parity claim remains tied
to the documented behavior, not to Perl-specific package names or internal event vocabulary.

Tracing is controlled separately from runtime context.

You can configure tracing directly:

```perl
my $cfg = LinkedSpec::configure_trace(
  trace_level => 'high',
  trace_log_file => 'linkedspec.trace.log',
  trace_log_mode => 'route',
  trace_reset_log => 1,
);
```

Or pass trace options through compile calls:

```perl
my %ctx;

my $parser = LinkedSpec::get_parser(
  'vhdl',
  runtime_ctx_ref => \%ctx,
  trace_level => 'medium',
  trace_log_file => 'linkedspec.trace.log',
  trace_log_mode => 'mirror',
);
```

## Trace levels

Trace levels can be numeric or named.

Named levels include:

- `none` or `quiet`
- `low`
- `medium` or `med`
- `high`
- `full`
- `debug` or `verbose`

The rough intent is:

- `low`: major pipeline events and critical outcomes
- `medium`: standard parser/spec dumps
- `high`: detailed rule and handler boundaries
- `full`: deeper DSL transformation detail
- `debug`: maximum detail

Use the smallest level that answers the current question. `debug` can be noisy.

## Trace output modes

`trace_log_mode` controls where trace text goes:

- `stdout`: print to stdout
- `route`: write to `trace_log_file` only
- `mirror`: print to stdout and write to `trace_log_file`

Example:

```perl
LinkedSpec::configure_trace(
  trace_level => 'high',
  trace_log_file => 'trace.log',
  trace_log_mode => 'route',
  trace_reset_log => 1,
);
```

If `trace_log_file` is set and no mode is provided, LinkedSpec routes to the file by default.

`trace_reset_log => 1` truncates the configured log file before writing new trace output.

## Environment variables

Tracing can also be configured from the environment:

```sh
LINKEDSPEC_TRACE_LEVEL=high
LINKEDSPEC_TRACE_FILE=trace.log
LINKEDSPEC_TRACE_MIRROR_STDOUT=1
```

Supported trace environment variables include:

- `LINKEDSPEC_TRACE_LEVEL`
- `LINKEDSPEC_DUMP_VERBOSITY`
- `LINKEDSPEC_TRACE_EMOJI`
- `LINKEDSPEC_TRACE_FILE`
- `LINKEDSPEC_TRACE_MIRROR_STDOUT`
- `LINKEDSPEC_TRACE_RESET_FILE`

Environment configuration is useful when you cannot easily change embedding caller code.

Prefer environment variables, per-call trace options, or `configure_trace(...)` for control. Direct package-variable
mutation is compatibility state; assigning `$LinkedSpec::DUMP_VERBOSITY` before the lazy trace owner is loaded is
not a reliable substitute for configuring trace.

## Command-line trace runner

For quick investigations, the Perl reference backend also exposes the same controls through `bin/linkedspec`.
The primary CLI activates trace only from its documented trace options; backend-specific ambient trace environment
variables do not opt in an otherwise untraced primary command. This keeps every backend's stdout/error contract
identical while native embedding callers retain the environment controls above.

```sh
perl bin/linkedspec --spec-file demo.spec --input-file demo.txt \
  --trace debug \
  --trace-file trace.log \
  --trace-mode route \
  --trace-reset
```

Use `--spec NAME` for shipped specs resolved by `get_parser(...)`, `--spec-file PATH` for a `.spec` file on disk, or `--inline-spec TEXT` for a literal source string. Use either `--input TEXT` or `--input-file PATH` for parser input. `--top-rule` selects a non-default entry; `--parse-mode seek` scans forward while `consume` matches at the current cursor. ADR `0025` requires Unicode scalar text encoded as strict UTF-8 while preserving BOM/code points/newlines and performing no trimming or normalization. The Perl command now enforces that boundary: invalid spec/input bytes fail in compilation/input loading, and canonical nested JSON is encoded once. UTF-16/UTF-32 files are not implicitly detected. The runner writes recursively key-sorted canonical JSON followed by exactly one newline on stdout, so routed trace files are the cleanest mode for repeatable command-line debugging.

Primary trace is the portable ADR `0024` phase protocol, not a dump of backend
implementation internals. For example, `--trace low` emits deterministic records
such as:

```text
[linkedspec][low] compile:start
[linkedspec][low] compile:ok
[linkedspec][low] input:start
[linkedspec][low] input:ok
[linkedspec][low] invoke:start
[linkedspec][low] invoke:ok
```

`medium`, `high`, `full`, and `debug` add portable request, byte-count, JSON-size,
and protocol-version fields respectively. Byte counts measure the process/file
UTF-8 bytes once; user-controlled field bytes outside `[A-Za-z0-9_.:-]` are
uppercase `%HH`, so a newline in a top-rule name cannot forge another trace record.
`<default>` is the reserved absent-top-rule marker. Use the in-memory trace APIs below when
you need the richer backend-specific scopes, decisions, marks, and generated-handler
events.

## Trace scopes and decisions

Internally, LinkedSpec traces named scopes such as:

```text
LinkedSpec::get_parser
LinkedSpec::Get
LinkedSpec::parser_invoke:<top_rule>
```

It also traces decisions such as:

```text
validate_spec_content
validate_dsl_syntax
bootstrap_spec_parse
resolve_top_rule_handler
validate_input_ref
invoke_top_rule:<top_rule>
```

RuleIR planning decisions follow this shape:

```text
rule_ir:<phase>:<rule_label>:<decision>
```

Current RuleIR phases include `collect`, `select`, `meta`, and `validate`. Typical decisions include
`entry_label`, `regex_entry`, `explicit_acode`, `blind_call`, `per_regex_lifecycle_acode`,
`per_regex_lifecycle_and_icode`, `move_pos_lecode`, `mark_pos_lecode`,
`handler_variant_<Variant>`, `action_mode_<mode>`, `execution_shape_<shape>`, `action_mode_valid`,
and `mixed_action_mode`.

EmitContext owner-bridge decisions follow this shape:

```text
emit_context:<phase>:<label>:<decision>
```

Current EmitContext phases include `owner_package`, `owner_callback`, `owner_deps`, `rewrite_compat`,
`rewrite_diagnostics`, and `build`. Typical decisions include `package_resolved`, `callback_resolved`,
`default_bundle`, `inject_function_registry`, `inject_bare_symbol_kind`, `retired_colon_scalar_slot`,
`aggregate_wrapper_fallback`, `canonical_rewrite_pipeline`, `canonical_raw_perl_fallback`,
`function_registry_available`, `bare_type_memory_collected`, and `rewrite_rules_built`.

ActionIR owner decisions follow this shape:

```text
actionir:<owner>:<phase>:<label>:<decision>
```

Current Perl reference ActionIR trace owners include scanner/canonical/diagnostic/rewrite owners, compact lowerers
such as `flow_expr`, `value_expr`, `array_pipeline`, `declare_method`, and `control_flow`, and
`method_lowering`. Typical MethodLowering decisions include `helper_family_string`, `ast_value_lowered`,
`unsupported_helper`, `string_receiver_chain`, `number_receiver_chain`, `hash_receiver_chain`,
`array_receiver_chain`, `ast_scalar_assignment_operator`, `ast_array_append_operator`,
`ast_hash_index_assignment`, `ast_array_end_mutation`, `bare_scalar_read`, `method_payload`, and
`legacy_raw_payload`.

When generated handler templates use the branch helper, decision names follow this shape:

```text
generated_handler_branch:<handler_kind>:<rule_label>:<branch>
```

In the Perl reference backend, generated handlers emit those decisions at `debug` level for regex match/miss, `LX`
no-match paths, acode dispatch, AND sequence checks, bcode child-call dispatch, bcode child-result checks,
repetition loop entry, min-satisfied stop decisions, per-iteration success/failure, max-bound continuation/cutoff,
and bcode REP zero-progress cutoffs. Typical branch names are `match`, `no_match_lx`, `acode_index_0`,
`required_sequence_index`, `bcode_call_Child`, `bcode_child_result`, `loop_enter`, `iteration_result`,
`miss_min_satisfied`, `max_continue`, `zero_progress`, and `zero_progress_min_satisfied`.

Those helper events return the normalized original branch boolean and evaluate lazy detail builders only when
tracing is enabled, so branch tracing should not perturb parser behavior.

Those names are intentionally concrete. Trace output should help users answer:

- Which stage did LinkedSpec enter?
- Which decision was taken or skipped?
- Which rule or top-level parser was involved?
- Did the failure happen while compiling, resolving, or invoking?

## Runtime context versus tracing

Use runtime context when you need a stable programmatic answer:

```perl
my $err = $ctx{last_error};
```

Use tracing when you need a chronological explanation:

```text
ENTER LinkedSpec::Get
DECISION validate_spec_content => TAKEN
EXIT LinkedSpec::Get
```

Runtime context should be safe to inspect in scripts and tests.

Trace output should be safe to read as a human when investigating a behavior.

## Why this exists

LinkedSpec wants to remain dynamic and flexible without becoming impossible to trust. Structured runtime context and trace scopes are part of that trust story.

The design principle is:

```text
runtime context records what failed;
tracing explains how the system got there.
```
