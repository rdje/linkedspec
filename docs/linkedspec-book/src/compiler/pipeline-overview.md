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

The seven stages above are a **backend-neutral** description of how any LinkedSpec backend turns `.spec` source into a parser or descriptor. The concrete module names, line counts, and signatures used as examples in this chapter (`LinkedSpec::Validation`, `LinkedSpec::Get(...)`, `Runtime::run_get`, `pos($$input_ref)`, …) are the **Perl reference backend's** realization of those stages; another backend implements the same stage sequence in its own language.

## Why the pipeline matters

Understanding the pipeline helps explain:

- where failures happen
- why diagnostics have stages
- how runtime/context metadata is preserved
- why internal state models exist

It also makes clear that the reference implementation is no longer best understood as one giant monolithic script (historically the Perl backend's `LinkedSpec.pm`).

## Stage 1: prepare the compile pipeline

Pipeline preparation normalizes options and callback ownership before real parsing begins.

This is where the compiler knows about requested options such as:

- `top_rule`
- `parse_mode`
- `return_descriptor`
- runtime context plumbing

Two specialty compilation modes are also set here: `parse_only` (build compiled rule-table state without generating handlers or emitting parser code) and `generate_only` (regenerate handlers from an already-compiled rule table without re-parsing). These modes support introspection and tooling workflows that need intermediate compiler artifacts.

The preparation stage also makes diagnostics better. If an invalid option or malformed callback surface is detected before parsing starts, the error can still be attributed to `compiler_pipeline:prepare_pipeline` instead of escaping as an arbitrary low-level failure.

## Stage 2: validate the source envelope

Before bootstrap parsing, LinkedSpec validates obvious `.spec` source-shape problems through a dedicated validation owner (in the Perl reference backend, `LinkedSpec::Validation` — 1,368 lines, its largest single-purpose validation owner).

This stage exists to reject malformed input early and clearly. The validation owner provides three layers of defense:

**Envelope validation** (`validate_spec_content`): checks the input is a non-empty SCALAR ref, verifies the first content line is a valid rule label, and requires at least one top rule (`RuleName::`) as the parser entry point.

**Paragraph-level validation** (`validate_dsl_syntax`): the deepest layer. It detects duplicate rule definitions, rejects rule definitions inside still-open blocks, checks that action edges (`->`) and blind-call edges (`=>`) have valid target labels and block-depth balance, rejects mixed action/blind-call modes within one rule, validates Perl regex literals for compile-ability, verifies rule-header right-hand-side content, checks split-marker syntax, and reports unused/undefined rule references. When `strict_syntax => 1` is set, unused-rule and undefined-reference warnings become hard errors, which is useful for CI regressions.

**Cross-reference validation** (`validate_dependency_regex_references`): checks that every dependency-regex entry references a rule that exists, every rule reference targets a valid regex index, and every rule's `dependency_refs` entries carry the required `label`/`idx` keys.

Errors from any layer carry structured payloads with `summary`, `detail`, and `rule_label` fields routed through the `on_failure` callback. Context-aware helpers like `get_dsl_context` correlate error positions with line numbers and surrounding source lines.

The high-level principle: malformed input should be rejected with targeted, debuggable messages before it reaches the bootstrap parser, the compiler state models, or (worst) the generated handler runtime.

## Stage 3: bootstrap parse

The bootstrap parser reads the `.spec` source and produces parsed rule entries.

This stage is still special because LinkedSpec uses a bootstrap grammar to parse the language that defines LinkedSpec parsers. That bootstrap layer is owned separately from the main compiler state model.

**Dual-path parse**: LinkedSpec also runs a second parse through the self-hosted `spec.spec` grammar as a diagnostic side channel. `BootstrapSpec::run_bootstrap_parse()` executes both the hardcoded bootstrap parser (always the primary output for format compatibility) and the `spec.spec`-generated parser, enabling cross-check comparisons via `tools/cross_check_spec_parsers.pl`. A recursion guard prevents infinite loops when `spec.spec` tries to parse itself.

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

The final public result depends on options. The entry point shown below (`LinkedSpec::Get(...)`) is the Perl reference backend's surface — see [`Get(...)` and `get_parser(...)`](../public-api/get-and-get-parser.md) for the backend-neutral roles and options.

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

## Runtime wrapper

Parser invocation is wrapped with a comment and blank-line skip loop. Before each match attempt the wrapper advances the cursor past any leading whitespace-only lines or `#`-to-end-of-line comment lines, so grammar rules do not need to handle these themselves. This skip wrapper is applied at runtime on every generated handler invocation, keeping the grammar surface clean. (In the Perl reference backend this is `Runtime::run_get` advancing `pos($$input_ref)`.)
