# `Get(...)`, `get_parser(...)`, and `emit_generated_source(...)`

> **Current Perl API:** ADR `0044` removes public/global `parse_mode` from all
> construction and execution surfaces. Perl `Get`, `get_parser`, and
> `emit_generated_source` now reject the legacy dynamic key during
> `prepare_options` with `parse_mode_override_removed`; the primary
> `--parse-mode` flag returns usage exit 2 with a targeted migration message.
> Rust has also removed its static execution/runtime override and primary flag;
> Dart, Julia, and Lua follow in their dependency-ordered rollout leaves.

These are the Perl reference entry points most readers should know first. They
demonstrate LinkedSpec's primary multi-backend product role: an application embeds the
backend as a native library and keeps `.spec` source, parser input, and results in memory.
No backend requires a CLI or subprocess for complete parser use.

LinkedSpec's public API has three relevant backend-neutral roles: an **inline compile path** (compile in-memory
`.spec` text into a runnable parser), a **file-oriented path** (resolve a named spec, then compile it), and a
**generated-source path** (emit independently loadable host source). The concrete Perl names and signatures on this
page are the reference surface; another backend exposes equivalent operations through idiomatic host APIs.

## Backend-native library surfaces

Names and return types are idiomatic to each host language. The invariant is the
in-process data path, not identical spelling:

| Backend | Native in-memory composition |
| --- | --- |
| Perl | Inline: `LinkedSpec::Get(...)` → parser coderef. Portable file-oriented: `LinkedSpec::SpecLoader::load_and_compile_spec(...)`; legacy `get_parser(...)` retains compatibility discovery. Generated source: `LinkedSpec::emit_generated_source(...)`. |
| Rust | Inline: `parse_spec(...)` → core compilation → `Engine::new(...)`. File-oriented: `spec_loader::load_and_compile_spec(...)` → `LoadedCompiledSpec::into_engine()`. |
| Dart | Inline: `parseSpec(...)` → `compileSpec(...)` → `LinkedSpecRuntimeEngine(...).parse(...)`. File-oriented: `loadAndCompileSpec(...)` → `LoadedCompiledSpec.createEngine()`. |
| Julia | Inline: staged `parse_spec_with_staged_user_function_definitions(...)` → `compile_spec(...)` → `LinkedSpecRuntimeEngine(...)`. File-oriented: `load_and_compile_spec(...)` → `create_engine(...)`. |
| Lua | Inline: staged `parse_spec_with_staged_user_function_definitions(...)` → `compile_spec(...)` → `runtime_engine(...)`. File-oriented: `load_and_compile_spec(...)` → `LoadedCompiledSpec:create_engine(...)`. |
| Later backends | An idiomatic native module must expose equivalent in-memory parse/compile/execute capability before its CLI can count as a complete backend. |

The inline and file-oriented roles are implemented on all five current backends: Perl through `Get(...)`, portable
`LinkedSpec::SpecLoader`, and legacy `get_parser(...)`; Rust through core composition and
`linkedspec_runtime::spec_loader`; Dart through its public parser/compiler plus `spec_loader.dart`; and Julia
through its staged parser/compiler plus `SpecLoader.jl`. Lua adds its native typed full composition over the same
staged parser/compiler/runtime. The original four-backend admission is closed under
`FUTURE-PARITY-BACKLOG.1.6.4`; Lua consumes the same contract under `LUA-BACKEND-PARITY.5.2`.

The implementation audit found that the former adapters did not share one fallback policy. Rust and Dart stopped
after three local candidates, Julia added a sorted recursive repository search, and Perl delegated a bare miss to
legacy `PathSearch`, whose recursively cached directory set and hash-key selection do not define portable
duplicate-name precedence. ADR `0026` therefore makes additional search roots explicit and ordered. The Rust,
Dart, Julia, and Lua native APIs now use that policy; Julia's recursive adapter fallback was removed. Perl's
implicit recursive fallback remains a compatibility extension, not the semantic model that new variants reproduce.

### Portable file-oriented contract

The contract is ratified and executable in `capability_conformance/native_spec_resolution_contract.json`; Perl,
Rust, Dart, Julia, and Lua pass it directly. It separates two caller intents:

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

### Perl portable named/file example

The portable Perl facade is separate from `get_parser(...)` so existing implicit `PathSearch` callers keep their
compatibility behavior while new applications can make discovery explicit:

```perl
use LinkedSpec::SpecLoader ();

my $request = LinkedSpec::SpecLoader::name_request('grammars/Expression');
my $options = LinkedSpec::SpecLoader::load_options(
  cwd => '/work/project',
  search_roots => ['/app/specs', '/team/specs'],
);

my $loaded = LinkedSpec::SpecLoader::load_and_compile_spec($request, $options);
print "resolved: ", $loaded->loaded->resolved->path, "\n";
print "source characters: ", length($loaded->loaded->source_text), "\n";

my $input = 'input';
my $value = $loaded->compiled->(\$input);
```

Use `path_request('relative/or/absolute.spec')` for one exact host path. `resolve_spec(...)` selects only,
`load_spec(...)` also reads and strictly decodes, and `load_and_compile_spec(...)` continues through the reference
compiler. Failures throw a blessed `LinkedSpec::SpecLoader::Error`; `to_hash()` returns the neutral structured
record. The complete result retains a runtime context carrying the requested name and resolved path.

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

### Julia named/file example

Julia exports the progressive file stages and complete composition from `LinkedSpecJulia`:

```julia
using LinkedSpecJulia

loaded = load_and_compile_spec(
    named_spec_request("grammars/Expression"),
    SpecLoadOptions(
        "/work/project";
        search_roots = ["/app/specs", "/team/specs"],
    ),
)

println("resolved: ", loaded.loaded.resolved.path)
println("source characters: ", length(loaded.loaded.source_text))

engine = create_engine(loaded)
value = runtime_execute(engine, "input").value
```

Use `path_spec_request("relative/or/absolute.spec")` for one exact host path. `resolve_spec(...)` selects only,
`load_spec(...)` also reads and strictly decodes, and `load_and_compile_spec(...)` continues through the full
staged function-aware parser, validation, and compiler. `to_json(error::SpecPipelineException)` exposes the
neutral structured error shape. `create_engine(...)` attaches the requested name and resolved file path to later
runtime diagnostics.

### Julia inline example

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

### Lua named/file example

Lua exposes the progressive stages and complete composition from `require("linkedspec")`:
Repository-checkout use first needs the caller-owned `LUA_PATH`/`LUA_CPATH`
setup documented under
[Lua primary parser command](native-spec-loading.md#lua-primary-parser-command).

```lua
local linkedspec = require("linkedspec")

local loaded = linkedspec.load_and_compile_spec(
  linkedspec.named_spec_request("grammars/Expression"),
  linkedspec.spec_load_options({
    cwd = "/work/project",
    search_roots = { "/app/specs", "/team/specs" },
  })
)

print("resolved: " .. loaded.loaded.resolved.path)
print("source bytes: " .. #loaded.loaded.source_text)

local engine = loaded:create_engine()
local value = linkedspec.runtime_parse(engine, "input").value
```

Use `path_spec_request("relative/or/absolute.spec")` for one exact host path. `resolve_spec(...)` selects only,
`load_spec(...)` also reads and strictly validates UTF-8, and `load_and_compile_spec(...)` continues through the
automatic spec-owned function parser, staged body dispatch, validation, and compiler. `SpecPipelineError` values
project the neutral structured record. `LoadedCompiledSpec:create_engine(...)` copies caller options, attaches
the requested name only for named requests, and attaches the resolved path for both kinds. The function-form
`create_loaded_spec_engine(...)` is equivalent.

## `LinkedSpec::Get(...)`

`Get(...)` is the inline compile path. It works from in-memory spec content and is convenient for direct parser construction, experiments, and tooling flows.

Minimal example:

```perl
use LinkedSpec;

my $spec = <<'SPEC';
top::
 -> word .push

LX { return(copy(top)) }

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

For a complete inline example with a small `.spec`, parser invocation, structural cursor policy, descriptor mode,
and runtime context, read [Worked `.spec` Walkthrough](../user-model/worked-spec-walkthrough.md).

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

## `LinkedSpec::emit_generated_source(...)`

`emit_generated_source(...)` compiles in-memory `.spec` text and returns deterministic, independently loadable
Perl source conforming to `linkedspec-generated-source-v2`:

```perl
use LinkedSpec;

my $source = LinkedSpec::emit_generated_source(
  \$spec,
  source_identity => 'examples/words.spec',
);

my $loaded = eval "package My::GeneratedWords;\n$source\n1;";
die $@ unless $loaded;

my $input = 'foo';
my $result = My::GeneratedWords::Execute(\$input);
my $metadata = My::GeneratedWords::LinkedSpecGeneratedMetadata();
```

The generated package exposes semantic roles:

- `Execute($input_ref)`;
- `ExecuteWithTrace($input_ref, \%trace_config)`;
- `LinkedSpecGeneratedMetadata()` and `LinkedSpecGeneratedPlan()`;
- `ValidateGeneratedPlan($plan, [$actual_contract])`.

Metadata contains the contract id, format version, source identity, and ordered `label` / `family` rows. Plan
validation rejects count, label, family, and unknown-family drift before execution. Emission, validation, and
execution failures are thrown as `generated_source_error` hashrefs with stable stage/code/identity fields.
The plan remains the minimal `{label, family}` shape. Perl v2 derives five seek and five consume policies from the
ten admitted family names; it does not serialize a separate cursor field. Supplying a v1 contract at reconstruction
fails with `generated_source_contract_version_mismatch`, `expected_contract`, and `actual_contract`; regenerate the
artifact from its `.spec` source.

The emitter rejects the removed `parse_mode` key before parsing source. Its structured error retains
`stage = "prepare_options"`, `code = "parse_mode_override_removed"`, `option_name = "parse_mode"`, and the caller's
`source_identity`.

The older `Get(... generate_only => 1, dump_parser_source => 1, parser_source_ref => \$source)` path remains
compatible and emits the same text. The dedicated method is preferred for application code because it returns the
source directly and normalizes emission failures.

## Shared options

Both entry points support the same core option style:

```perl
my $parser = LinkedSpec::Get(
  \$spec,
  top_rule => 'Top',
);

my $parser = LinkedSpec::get_parser(
  'Lispish',
  top_rule => 'Lispish',
);
```

Important options include:

- `top_rule`
- `return_descriptor`
- `runtime_ctx_ref`

Two specialty compilation modes are also available:

- `parse_only` — parse the `.spec` source and build the compiled rule table, but skip handler generation and parser-code emission. Returns the compiled internal state instead of a parser coderef. Useful for introspection tools that need rule-level metadata without the full runtime surface.
- `generate_only` — regenerate handlers from an already-compiled rule table without re-parsing the source. Requires a previously built compiled state. Useful for tooling workflows that cache parse results and only need to re-emit handlers.

## `top_rule`

`top_rule` explicitly selects the parser entry rule. It may name any declared rule, including an ordinary
single-colon rule, and has priority over every authored `::` marker. The primary-command equivalent is
`--top-rule NAME`.

ADR `0046` fixes the cross-backend default when the option is omitted: select the first authored `::`; if the file
has no marker, select the first authored rule. That contract is at 1 complete / 6 pending. The current Perl
reference still selects the first parsed rule even when a later marker exists, Rust requires and selects a marker,
and Dart/Julia/Lua validation still blocks their existing markerless runtime fallback. Use an explicit selector
when current multi-backend execution must be independent of those staged differences.

```perl
my $parser = LinkedSpec::Get(
  \$spec,
  top_rule => 'Expression',
);
```

For example, the accepted default for this source is `Marked`, not `Earlier`; `top_rule => 'Later'` still wins:

```text
Earlier:
 /earlier/

Marked::
 /marked/

Later:
 /later/
```

With no `::`, the accepted default is simply the first declared rule. A markerless file remains implementation-
pending until the backend rollout closes, so this example currently needs an explicit selector on portable paths:

```text
First:
 /first/

Second:
 /second/
```

## Removed `parse_mode`

`parse_mode` no longer controls or configures a Perl parser. Cursor discipline comes from each authored rule
family:

- default/OR families derive `seek`
- AND families derive `consume`

```perl
my %ctx;
my $parser = LinkedSpec::Get(
  \$spec,
  parse_mode => 'consume', # removed
  runtime_ctx_ref => \%ctx,
);

die $ctx{last_error}{code};
# parse_mode_override_removed
```

The failure occurs at `prepare_options`, normalizes `option_name` to `parse_mode` (including callers that use the
camel-case legacy spelling), and happens before `.spec` parsing or action execution. Author an `AND` family for
contiguous consumption, a default/OR family for progressive seeking, and explicit child-rule composition for mixed
cursor structures.

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
