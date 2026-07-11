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
| Rust | Inline: `parse_spec(...)` → core compilation → `Engine::new(...)`. File-oriented: `spec_loader::load_and_compile_spec(...)` → `LoadedCompiledSpec::into_engine()`. |
| Dart | Inline: `parseSpec(...)` → `compileSpec(...)` → `LinkedSpecRuntimeEngine(...).parse(...)`. File-oriented: `loadAndCompileSpec(...)` → `LoadedCompiledSpec.createEngine()`. |
| Julia | Rule-only: `parse_spec(...)`; source with top-level functions: `parse_spec_with_staged_user_function_definitions(...)`; then `compile_spec(...)` → `LinkedSpecRuntimeEngine(...)` → `runtime_parse(...)` / `runtime_execute(...)`. |
| Lua and later backends | An idiomatic native module must expose equivalent in-memory parse/compile/execute capability before its CLI can count as a complete backend. |

The inline in-memory role is implemented on all four current backends. Perl, Rust, and Dart also expose the native
file-oriented role: Perl through `get_parser(...)`, Rust through `linkedspec_runtime::spec_loader`, and Dart
through the public `spec_loader.dart` export. Julia still resolves named specs only inside its thin primary process
adapter. `FUTURE-PARITY-BACKLOG.1.6.4.4-.5` owns Julia's idiomatic native equivalent and final shared admission;
until those leaves close, Julia callers should load source explicitly and pass it to the in-memory parser.

The implementation audit found that the adapters do not yet share one fallback policy. Rust and Dart stop after
the exact working-directory path, working-directory `<name>.spec`, and repository `specs/<name>.spec`; Julia adds
a sorted recursive repository search. Perl checks the same three local forms but then delegates a bare miss to the
legacy `PathSearch`, whose recursively cached directory set and hash-key selection do not define portable
duplicate-name precedence. ADR `0026` therefore makes additional search roots explicit and ordered. Perl's
implicit recursive fallback remains a compatibility extension, not the semantic model that new variants reproduce.

### Portable file-oriented contract

The contract is ratified and executable in `capability_conformance/native_spec_resolution_contract.json`; Rust
and Dart pass it directly, while Julia rollout remains in progress. It separates two caller intents:

| Request | Resolution |
| --- | --- |
| named spec | cwd exact value → cwd value with `.spec` → each explicit search root in declared order |
| explicit path | absolute path as given, or relative path joined to cwd; no suffix and no root fallback |

A named identity uses `/` for optional nested components. It cannot be absolute or contain backslashes, empty
components, `.`, or `..`; use the explicit-path request for arbitrary host filesystem syntax. Search roots are
not recursive. Candidate deduplication preserves the first occurrence, and the first regular file wins. A
directory at an earlier candidate does not mask a later file; if no file matches, diagnostics distinguish the
first existing non-file from a pure miss.

Conceptually, a native caller supplies:

```text
request = name("grammars/Expression")
cwd = "/work/project"
search_roots = ["/app/specs", "/team/specs"]
```

The candidates are exactly:

```text
/work/project/grammars/Expression
/work/project/grammars/Expression.spec
/app/specs/grammars/Expression.spec
/team/specs/grammars/Expression.spec
```

The file pipeline is validate → resolve → read bytes → strict UTF-8 decode → parse → validate → compile. A
successful native result keeps request kind/value, resolved path, and exact source text alongside its
backend-native compiled value. A failure exposes neutral `type`, `stage`, `code`, `summary`, `request_kind`, and
`requested` fields, with resolved path and backend detail when available.

Unicode and UTF-8 are different layers here. The logical source is Unicode scalar text; UTF-8 is the selected file
encoding. UTF-16 and UTF-32 are valid Unicode encodings generally, but this API does not guess or transcode them.
Callers must transcode such files explicitly or pass already-decoded text to the inline API. Valid UTF-8 preserves
BOM as U+FEFF, normalization form, code points, newlines, and surrounding text exactly.

### Rust named/file example

Rust exposes each stage for tooling and the complete composition for ordinary embedding:

```rust
use linkedspec_runtime::engine::ExecutionOptions;
use linkedspec_runtime::spec_loader::{
    SpecLoadOptions, SpecRequest, load_and_compile_spec,
};

let request = SpecRequest::named("grammars/Expression");
let options = SpecLoadOptions::new("/work/project")
    .with_search_root("/app/specs")
    .with_search_root("/team/specs");

let loaded = load_and_compile_spec(&request, &options)?;
println!("resolved: {}", loaded.loaded().resolved().path().display());
println!("source bytes: {}", loaded.loaded().source_text().len());

let engine = loaded.into_engine();
let value = engine.execute_value("input", &ExecutionOptions::new())?;
```

Use `SpecRequest::path("relative/or/absolute.spec")` for one exact host path. `resolve_spec(...)` stops after
selection, `load_spec(...)` also reads/decodes, and `load_and_compile_spec(...)` continues through the full staged
function-aware parser, validation, and compiler. `LoadedCompiledSpec::into_engine()` attaches the requested name
and resolved path to later structured runtime diagnostics.

Errors serialize without string scraping. For example, a pure named miss projects:

```json
{
  "type": "spec_pipeline_error",
  "stage": "resolve_spec_path",
  "code": "spec_path_not_found",
  "summary": "Spec path not found",
  "request_kind": "name",
  "requested": "Missing"
}
```

### Dart named/file example

Dart exposes the same progressive stages and complete composition from its top-level package:

```dart
import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';

final loaded = loadAndCompileSpec(
  const SpecRequest.named('grammars/Expression'),
  SpecLoadOptions(
    cwd: Directory('/work/project'),
    searchRoots: [Directory('/app/specs'), Directory('/team/specs')],
  ),
);

print('resolved: ${loaded.loaded.resolved.file.path}');
print('source characters: ${loaded.loaded.sourceText.length}');

final engine = loaded.createEngine();
final value = engine.execute('input').value;
```

Use `SpecRequest.path('relative/or/absolute.spec')` for one exact host path. `resolveSpec(...)` selects only,
`loadSpec(...)` also reads and strictly decodes, and `loadAndCompileSpec(...)` continues through the full staged
function-aware parser, validation, and compiler. `SpecPipelineException.toJson()` exposes the neutral structured
error shape. `createEngine()` attaches the requested name and resolved file path to later runtime diagnostics.

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
