# `Get(...)` and `get_parser(...)`

These are the two Perl reference entry points most readers should know first. They
demonstrate LinkedSpec's primary multi-backend product role: an application embeds the
backend as a native library and keeps `.spec` source, parser input, and results in memory.
No backend requires a CLI or subprocess for complete parser use.

LinkedSpec's public API has two entry points serving two backend-neutral roles: an **inline compile path** (compile in-memory `.spec` text into a runnable parser) and a **file-oriented path** (resolve a named spec, then compile it). Those roles — and all the options below (`top_rule`, `parse_mode`, `return_descriptor`, `runtime_ctx_ref`, `parse_only`, `generate_only`) — are backend-neutral. The concrete names and signatures on this page (`LinkedSpec::Get(...)`, `LinkedSpec::get_parser(...)`, and the returned parser coderef) are the **Perl reference backend's** surface; another backend exposes the same two entry points and the same options in its own language.

## Backend-native library surfaces

Names and return types are idiomatic to each host language. The invariant is the
in-process data path, not identical spelling:

| Backend | Native in-memory composition |
| --- | --- |
| Perl | `LinkedSpec::Get(...)` → parser coderef; `get_parser(...)` adds named/file resolution. |
| Rust | `linkedspec_core::parser::parse_spec(...)` → core compilation → `linkedspec_runtime::engine::Engine::new(...)` → `execute(...)` or structured `execute_with_diagnostics(...)`. |
| Dart | `parseSpec(...)` → `compileSpec(...)` → `LinkedSpecRuntimeEngine(...).parse(...)`. |
| Julia | Rule-only: `parse_spec(...)`; source with top-level functions: `parse_spec_with_staged_user_function_definitions(...)`; then `compile_spec(...)` → `LinkedSpecRuntimeEngine(...)` → `runtime_parse(...)` / `runtime_execute(...)`. |
| Lua and later backends | An idiomatic native module must expose equivalent in-memory parse/compile/execute capability before its CLI can count as a complete backend. |

The in-memory role is implemented on all four current backends. The file-oriented named-resolution role is not yet
library-equivalent: Perl exposes `get_parser(...)`, while Rust, Dart, and Julia currently resolve named specs only
inside their thin primary process adapters. `FUTURE-PARITY-BACKLOG.1.6.4` owns idiomatic native equivalents and
shared path/search fixtures; until it closes, callers on those backends should load source explicitly and pass it
to the in-memory parser.

The implementation audit found that the adapters do not yet share one fallback policy. Rust and Dart stop after
the exact working-directory path, working-directory `<name>.spec`, and repository `specs/<name>.spec`; Julia adds
a sorted recursive repository search. Perl checks the same three local forms but then delegates a bare miss to the
legacy `PathSearch`, whose recursively cached directory set and hash-key selection do not define portable
duplicate-name precedence. The backend-neutral API will therefore make additional search roots explicit and
ordered. Perl's implicit recursive fallback remains a compatibility extension, not the semantic model that new
variants reproduce.

File-oriented helpers, per-variant CLIs, corpus runners, Wasm/web/mobile wrappers, and
service adapters may wrap these APIs. They are secondary surfaces and must not contain
parser, compiler, runtime, or `.spec` semantics unavailable to native library callers.
Backend tests therefore call the library directly; CLI and corpus tests add integration
proof but do not replace host-process API proof.

### Julia in-memory example

Rule-only `.spec` source stays entirely in the Julia process:

```julia
using LinkedSpecJulia

spec_source = raw"""
Top::
 /x/
 E {
   return("ok")
 }
"""

spec = parse_spec(spec_source)
compiled = compile_spec(spec)
result = runtime_parse(LinkedSpecRuntimeEngine(compiled), "x")

println(result.output)
```

When the source contains top-level `fn` definitions, replace `parse_spec(spec_source)` with
`parse_spec_with_staged_user_function_definitions(spec_source)`. That entrypoint executes the shared checked-in
function-definition spec and staged body parser in memory; it does not invoke the CLI or raw-scan Julia source.
Both paths feed the same compiled/runtime API.

## `LinkedSpec::Get(...)`

`Get(...)` is the inline compile path. It works from in-memory spec content and is convenient for direct parser construction, experiments, and tooling flows.

Minimal example:

```perl
use LinkedSpec;

my $spec = <<'SPEC';
top::
 -> word .push

LX { return(copy(array(top))) }

word:
 /foo/ I {
   return(hash("kind", "top", "text", entry_text()));
 }
SPEC

my $parser = LinkedSpec::Get(\$spec);
my $input = 'foo';
my $ast = $parser->(\$input);
# $ast is [ { kind => "top", text => "foo" } ]
```

The spec is written in the standard two-rule shape: the entry rule `top::` carries no regex and dispatches to `word`, which carries the regex and returns a value per match (`entry_text()` reads the matched text). See [.spec Files and Rule Paragraphs](../user-model/spec-files-and-rule-paragraphs.md).

Use this form when the spec text is already in memory or generated by a tool. This inline
path is the reference example of the native embedding contract every backend inherits.

For a complete inline example with a small `.spec`, parser invocation, `parse_mode`, descriptor mode, and runtime context, read [Worked `.spec` Walkthrough](../user-model/worked-spec-walkthrough.md).

## `LinkedSpec::get_parser(...)`

`get_parser(...)` is the file-oriented path. It resolves a named spec, loads it, compiles it, and returns a parser.

Minimal example:

```perl
use LinkedSpec;

my $parser = LinkedSpec::get_parser('Lispish');
my $input = '(hello world)';
my $ast = $parser->(\$input);
```

Use this form when you want LinkedSpec to resolve a shipped or local spec by name.

## Why both exist

They serve different usage patterns:

- `Get(...)` is great for inline or tooling-oriented work
- `get_parser(...)` is great for repo/spec-name based workflows

Internally, both flow into the same broader runtime/compiler story, but they carry different setup responsibilities and diagnostics seams. The file-oriented path is a convenience over that library story, not a requirement to serialize an in-memory spec.

## Shared options

Both entry points support the same core option style:

```perl
my $parser = LinkedSpec::Get(
  \$spec,
  top_rule => 'Top',
  parse_mode => 'seek',
);

my $parser = LinkedSpec::get_parser(
  'Lispish',
  top_rule => 'Lispish',
  parse_mode => 'consume',
);
```

Important options include:

- `top_rule`
- `parse_mode`
- `return_descriptor`
- `runtime_ctx_ref`

Two specialty compilation modes are also available:

- `parse_only` — parse the `.spec` source and build the compiled rule table, but skip handler generation and parser-code emission. Returns the compiled internal state instead of a parser coderef. Useful for introspection tools that need rule-level metadata without the full runtime surface.
- `generate_only` — regenerate handlers from an already-compiled rule table without re-parsing the source. Requires a previously built compiled state. Useful for tooling workflows that cache parse results and only need to re-emit handlers.

## `top_rule`

`top_rule` selects the parser entrypoint rule.

If omitted, LinkedSpec uses the first parsed rule paragraph as the default top-level rule.

```perl
my $parser = LinkedSpec::Get(
  \$spec,
  top_rule => 'Expression',
);
```

## `parse_mode`

`parse_mode` controls cursor discipline:

- `seek` preserves progressive extraction behavior and is the default
- `consume` requires contiguous matching from the current cursor

```perl
my $parser = LinkedSpec::get_parser(
  'Lispish',
  parse_mode => 'consume',
);
```

## `runtime_ctx_ref`

`runtime_ctx_ref` lets callers capture structured runtime/compiler context:

```perl
my %ctx;
my $parser = LinkedSpec::Get(
  \$spec,
  runtime_ctx_ref => \%ctx,
);
```

Callers may also pass a scalar slot with `runtime_ctx_ref => \$ctx`. LinkedSpec installs the context hashref there on the first call and reuses that same hashref on later calls when the slot is already populated. This populated scalar-slot reuse is part of both public entrypoints: later `LinkedSpec::Get(...)` and `LinkedSpec::get_parser(...)` calls can keep caller-owned fields while LinkedSpec refreshes its own context fields. A populated slot that already contains a non-hash reference is rejected as an invalid `runtime_ctx_ref` shape.

On failures, the context can carry structured `last_error` data such as owner/stage, rule label, selected top rule, and file identity when known.

This is a major part of the current diagnostics story: callers should not have to scrape raw host-language error strings to understand which owner/stage failed.

## Descriptor mode

If you want descriptor data rather than a parser coderef, use:

```perl
my $descr = LinkedSpec::Get(
  \$spec,
  return_descriptor => 1,
);
```

The descriptor shape is covered in the next chapter.

## Other compile/runtime methods

Two additional methods on the facade serve specialized compile/runtime needs:

### `build_compiled_rule_table($parsed_spec_entries, [$compile_spec_entry_cb], [$option_hashref])`

Returns the compiled rule table from already-parsed spec entries without building the full descriptor or generating handlers. An optional compile callback and option hashref control advanced behavior (e.g., `{ return_state => 1 }` returns the full compiled-spec state instead of the rule-table projection). Useful for introspection tools that need rule-level metadata.

### `call_spec_handler_subst($label, $code)`

Rewrites a single helper-action code string for the named rule label through the ActionIR lowering pipeline. Returns the rewritten code. Used primarily by regression tests and compatibility checks — runtime rule compilation calls the ActionIR rewrite path directly.

These are lower-level than `Get` and `get_parser`; most callers will not need them directly.
