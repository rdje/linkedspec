# Pipeline Overview

At a high level, LinkedSpec’s compile/runtime flow looks like this:

1. validate and prepare the compile pipeline
2. bootstrap-parse the `.spec` source into parsed entries
3. build compiled rule-table state
4. build dependency-regex state
5. build compiled descriptor state
6. validate the generated descriptor state
7. project the outward descriptor or build the runtime parser wrapper

In text-diagram form:

```text
source .spec text
  -> prepare pipeline
  -> validate source envelope
  -> bootstrap parse
  -> compiled_spec_state
  -> compiled_dependency_regex_state
  -> compiled_descriptor_state
  -> validate descriptor state
  -> outward descriptor or parser coderef
```

## Why the pipeline matters

Understanding the pipeline helps explain:

- where failures happen
- why diagnostics have stages
- how runtime/context metadata is preserved
- why internal state models exist

It also makes clear that LinkedSpec is no longer best understood as one giant monolithic `LinkedSpec.pm` script.

## Stage 1: prepare the compile pipeline

Pipeline preparation normalizes options and callback ownership before real parsing begins.

This is where the compiler knows about requested options such as:

- `top_rule`
- `parse_mode`
- `return_descriptor`
- runtime context plumbing

The preparation stage also makes diagnostics better. If an invalid option or malformed callback surface is detected before parsing starts, the error can still be attributed to `compiler_pipeline:prepare_pipeline` instead of escaping as an arbitrary low-level failure.

## Stage 2: validate the source envelope

Before bootstrap parsing, LinkedSpec validates obvious `.spec` source-shape problems.

This stage exists to reject malformed input early and clearly. For example, stray preamble text before the first rule paragraph or malformed top-level structure should be reported as validation failures, not allowed to drift into a confusing bootstrap parse result.

## Stage 3: bootstrap parse

The bootstrap parser reads the `.spec` source and produces parsed rule entries.

This stage is still special because LinkedSpec uses a bootstrap grammar to parse the language that defines LinkedSpec parsers. That bootstrap layer is owned separately from the main compiler state model.

## Stage 4: build compiled rule-table state

The active low-level compiler seam is:

```text
build_compiled_rule_table(...)
```

Its job is to convert parsed rule entries into `compiled_spec_state`.

That state owns:

- deterministic definition information
- compiled rule order
- rules by label
- redefinition metadata
- per-rule compiled info such as regexes, handlers, dependency refs, and rule metadata

This is the compiler’s rule source of truth.

## Stage 5: build dependency-regex state

The next derived stage is:

```text
build_dependency_regex_map(...)
```

Despite the public name, the active internal path can build an explicit `compiled_dependency_regex_state`.

That state is derived from compiled rules. It exists because generated handlers need efficient combined regex dispatch for referenced child-rule regexes.

## Stage 6: build compiled descriptor state

Once compiled rule state and dependency-regex state exist, the compiler builds:

```text
compiled_descriptor_state
```

This internal state composes the two earlier state records.

It is important that validation happens against this internal state before projecting the outward descriptor. That keeps the compiler on explicit, owned structures rather than bouncing back into older loose hash shapes too early.

## Stage 7: validate descriptor state

Generated-descriptor validation checks that the compiled rule state and dependency-regex state agree.

For example, dependency references must point to rules and regex indexes that actually exist.

When validation fails, the compiler can preserve structured attribution such as:

- owner/stage
- selected top rule
- rule label
- handler source label
- specific summary/detail text

## Stage 8: project descriptor or return parser

The final public result depends on options.

Default behavior returns a parser coderef:

```perl
my $parser = LinkedSpec::Get(\$spec);
```

Descriptor mode returns the outward descriptor:

```perl
my $descr = LinkedSpec::Get(
  \$spec,
  return_descriptor => 1,
);
```

The outward descriptor is not the compiler’s only internal truth. It is a public/tooling projection of the state-first model.
