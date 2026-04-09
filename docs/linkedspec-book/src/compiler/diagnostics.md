# Diagnostics

Diagnostics are a first-class part of LinkedSpec’s architecture, not just an afterthought.

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
