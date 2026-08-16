# Diagnostics

Diagnostics are a first-class part of LinkedSpec’s architecture, not just an afterthought.

The diagnostics **contract** described in this chapter is backend-neutral: the structured `last_error` payload and its fields (`type`, `stage`, `owner_stage`, `summary`, `detail`, `top_rule`, `rule_label`, `handler_source_label`, `spec_name`, `spec_path`), the owner/stage families, and rule-plus-handler attribution are part of the `.spec` execution contract every backend should preserve. The concrete capture mechanism shown (`LinkedSpec::Get(..., runtime_ctx_ref => \%ctx)`) and the `LinkedSpec::generated_handler:Top` label spelling are the **Perl reference backend's** surface; another backend exposes the same structured failure information in its own language.

## What the project is aiming for

- deterministic validation failures
- structured runtime and compiler context
- clear ownership and stage attribution
- preserved rule labels and handler identity when known

## Why that matters

If a dynamic parser system cannot explain its failures clearly, it becomes expensive to use and hard to trust.

That is why recent work has focused so much on:

- `runtime_ctx->{last_error}`
- owner/stage naming
- compile-time attribution
- parser-factory continuity
- handler-source labels

These are part of the product quality story, not just developer convenience.

## The main structured error field

The central public runtime-context field is:

```perl
$runtime_ctx->{last_error}
```

Callers can capture it with:

```perl
my %ctx;
my $parser = LinkedSpec::Get(
  \$spec,
  runtime_ctx_ref => \%ctx,
);
```

When a structured failure occurs, `last_error` is a hashref rather than an unstructured string.

For the Dart backend, the equivalent runtime surface is
`RuntimeInterpreterException.diagnostic`. That value is a `RuntimeDiagnostic`
with the same neutral field names (`type`, `stage`, `owner_stage`, `summary`,
`detail`, `top_rule`, `rule_label`, `handler_source_label`, and optional
`spec_name` / `spec_path`). Dart keeps successful parse output unchanged; the
diagnostic object appears on runtime failures.

For the Julia backend, the equivalent surface is also
`RuntimeInterpreterException.diagnostic`. Julia exports `RuntimeDiagnostic`
with the same neutral field names, accepts optional `spec_name` / `spec_path`
on `LinkedSpecRuntimeEngine`, and preserves the failing child rule and
`julia_runtime:rule:<label>` handler attribution before parent context unwind.
Successful Julia `RuntimeParseResult` JSON and textual exception display remain
unchanged.

For the Lua backend, `pcall(...)` returns a typed `RuntimeInterpreterException`
table whose `diagnostic` field is a typed `RuntimeDiagnostic`. Native callers
may attach source identity when constructing the engine:

```lua
local engine = linkedspec.runtime_engine(compiled, {
  spec_name = "Example",
  spec_path = "specs/Example.spec",
})

local ok, result_or_error = pcall(linkedspec.runtime_parse, engine, input)
if not ok and linkedspec.is_runtime_interpreter_error(result_or_error) then
  local diagnostic = linkedspec.interpreter.to_json(result_or_error.diagnostic)
  io.stderr:write(diagnostic.owner_stage, ": ", diagnostic.summary, "\n")
  io.stderr:write(diagnostic.handler_source_label, "\n")
end
```

The Lua fields use the same neutral snake-case names. `rule_lookup`,
`top_rule_selection`, `runtime_input`, and `runtime_execution` distinguish
specific runtime stages. A child attaches its payload before unwinding, and
outer wrappers preserve it, so `top_rule = "Top"` can coexist with
`rule_label = "Child"` and `handler_source_label = "lua_runtime:rule:Child"`.
`linkedspec.interpreter.to_json(error)` returns the unchanged message plus the
nested diagnostic; absent optional identity fields are omitted. Successful
parse values and ordinary textual errors are unchanged.

Lua tracing uses a separate caller-owned channel. Passing `{ trace = emitter }`
to `runtime_parse(...)` or calling `runtime_parse_with_trace(...)` emits
structured trace events without replacing `RuntimeDiagnostic`, writing ambient
diagnostics, or changing successful results. Disabled configs stay quiet;
stdout, routed-file, and mirror sinks are explicit native trace policy.

For Rust, `RuntimeExecutionError` carries the equivalent serializable `RuntimeDiagnostic`. Native callers opt into
it through `Engine::execute_with_diagnostics(...)` or `execute_value_with_diagnostics(...)`:

```rust
let engine = Engine::new(compiled)
    .with_spec_name("Example")
    .with_spec_path("/specs/Example.spec");

match engine.execute_with_diagnostics("input") {
    Ok(value) => use_value(value),
    Err(error) => {
        eprintln!("{}", error.message());
        eprintln!("{:?}", error.diagnostic().rule_label);
    }
}
```

The JSON record uses the same neutral names: `type`, `stage`, `owner_stage`, `summary`, `detail`, `spec_name`,
`spec_path`, `top_rule`, `rule_label`, and `handler_source_label`. Optional fields are omitted when unavailable.
Rule failures capture the deepest child before its frame unwinds; missing entry rules use `rule_lookup`, and an
empty compiled state uses `top_rule_selection`. Existing `execute(...)` / `execute_value(...)` methods remain
`Result<_, String>` compatibility adapters with identical messages and successful values. Trace methods and the
canonical primary CLI projection are unchanged. The complete Rust/CLI recurring gate passes, and `.1.6.3.2`
admits this capability for all four variants.

Rust also rejects malformed compiled action-slot identity before ordinary,
loaded/reconstructed, or generated-plan execution. The portable failure is
`regex_slot_identity_invalid` at `validate_compiled_rule` with `rule_label`,
`target_rule`, and `regex_index`. If an ordered matcher ever returns an identity
other than the already-required slot, the invariant is
`ordered_regex_slot_identity_lost` at `execute_rule` with `rule_label`,
`target_rule`, `expected_regex_index`, and `actual_regex_index`.
`RuntimeDiagnostic` exposes those optional fields. Generated adapters project
invalid compiled state as `GeneratedSourceStage::ValidateCompiledRule` /
`GeneratedSourceCode::RegexSlotIdentityInvalid` with the same target identity;
the source emitter rejects it before producing an artifact.

Dart uses the same portable codes and fields. `compileSpec(...)`,
`validateCompiledRegexSlotIdentities(...)`, runtime entry, descriptor projection,
and generated-source validation all reject a missing or out-of-range action slot
as `regex_slot_identity_invalid` / `validate_compiled_rule`. `RuntimeDiagnostic`
adds optional `target_rule` and `regex_index`; `GeneratedSourceException` maps
the failure to `GeneratedSourceStage.validateCompiledRule` and
`GeneratedSourceCode.regexSlotIdentityInvalid`. The public
`assertOrderedRegexSlotIdentity(...)` seam exposes
`ordered_regex_slot_identity_lost` / `execute_rule` with expected and actual
indices for invariant testing.

Dart's, Julia's, and shared Lua's authored gap-metadata layers report the neutral source-aware static failures
before compiled state is accepted:

- `regex_slot_name_invalid` / `parse_declaration`
- `regex_slot_duplicate_name` / `resolve_declaration`
- `regex_slot_unknown_name` and `regex_slot_index_out_of_range` / `resolve_selector`
- `regex_slot_selector_invalid` / `parse_selector`
- `capture_gaps_duplicate_directive` / `parse_directive`
- `capture_gaps_rule_ineligible` and `capture_gaps_legacy_marker_conflict` / `validate_directive`

Every row includes `rule_label`, logical `source_id`, and physical `line`, plus its contract-specific selector,
slot, eligibility, or marker context. The Lua source id defaults to `inline`; a relative loaded request retains
its caller spelling, while an absolute loaded request is reduced to its basename so host paths never become
compiled provenance. Runtime backends use `gap_capture_context_unavailable` for a private gap read outside a live
candidate/tail and `source_location_cursor_regression` when the accepted cursor would commit before the selected
match end. Lua runtime context and those accessor/runtime failures remain owned by `.6.2`; `.6.1` does not
manufacture a live gap context.

Parser-authored `print`/`say`/`print_each` events use a separate Rust facility. Call
`execute_with_diagnostic_output(input, sink)` or
`execute_value_with_diagnostic_output(input, options, sink)` with an optional caller-owned
`RuntimeDiagnosticOutputSink`. Its `RuntimeDiagnosticOutputEvent` carries only `helper_name`, `rule_label`, and
Unicode `message`; passing no sink is quiet and event text is never inserted into `RuntimeDiagnostic` or native
trace. `RuntimeDiagnosticOutputExecutionError` has distinct `Runtime`, `Sink`, and `Exit` variants, so existing
structured runtime context, the caller's concrete sink failure, and `RuntimeExitNow { status }` do not get
rewritten into one textual channel. Emitted Rust modules preserve their sinkless functions and add paired
`execute_with_diagnostic_output` / `execute_with_trace_and_diagnostic_output` plus compatibility
`parse_with_diagnostic_output` / `parse_with_trace_and_diagnostic_output` functions. Their
`GeneratedDiagnosticOutputExecutionError` keeps generated-source, compatibility, caller-sink, and immediate-exit
outcomes distinct.

## Typical payload shape

A payload can include fields such as:

```perl
{
  type => 'compiler_pipeline',
  stage => 'build_final_descriptor',
  owner_stage => 'compiler_pipeline:build_final_descriptor',
  summary => 'Final descriptor assembly failed',
  detail => '...',
  top_rule => 'Top',
  rule_label => 'Top',
  handler_source_label => 'LinkedSpec::generated_handler:Top',
  spec_name => '',
  spec_path => '',
}
```

Not every field is present for every failure. The principle is: preserve what the owner knows at the point of failure.

## Owner/stage families

Common structured owner families include:

- `compiler_pipeline`
- `parser_factory`
- `runtime_owner`
- `runtime_parser`
- `runtime_handler`

Common compiler stages include:

- `prepare_pipeline`
- `validate_spec_content`
- `validate_dsl_syntax`
- `bootstrap_parse`
- `build_compiled_rule_table`
- `build_final_descriptor`
- `validate_dependency_regex_references`

Common parser-factory stages include:

- `prepare_parser_factory`
- `validate_spec_name`
- `resolve_spec_path`
- `load_spec_content`
- `compile_spec`

These names are intentionally explicit. A diagnostic should tell you which owner was responsible and which stage failed.

## Rule and handler attribution

When the failing rule is known, diagnostics should preserve:

```perl
rule_label => 'Top'
```

When the generated handler identity is known, diagnostics should preserve:

```perl
handler_source_label => 'LinkedSpec::generated_handler:Top'
```

or a more specific variant form.

This is especially important for generated handler failures because otherwise users would have to infer source ownership from emitted code or raw Perl errors.

## File-oriented continuity

The file-oriented `get_parser(...)` path can preserve:

- requested `spec_name`
- resolved `spec_path`
- selected `top_rule`
- later compiler/runtime failure context

That means a failure after successful file resolution can still report the file identity. The project treats that continuity as part of diagnostics quality.

## Fallback rule

Owners should avoid overwriting richer lower-level payloads.

If a deeper owner already wrote a structured `last_error`, a wrapper should preserve it rather than collapse it into a generic outer failure.

If no deeper payload exists, the wrapper can write a fallback payload with a clear owner/stage and a specific detail string.

That rule is what keeps diagnostics useful across `Runtime -> Compiler`, `ParserFactory -> Compiler`, and top-level parser invocation boundaries.
