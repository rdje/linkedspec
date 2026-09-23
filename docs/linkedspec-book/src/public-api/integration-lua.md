# Integrating LinkedSpec into a Lua application

See [Application Integration](integration.md) for backend selection, shared
checkout and storage principles, and the common example.

Use `require("linkedspec")` to load a grammar, compile it once and parse independent
inputs in your Lua process. The repository supplies the Lua modules and JSON
codec. Matching uses a small native PCRE2 binding; native filesystem inspection
supports exact grammar loading. This route needs no RGX/PGEN or Perl parser.

## Add and pin the source dependency

From your application's repository root:

```sh
git submodule add https://github.com/rdje/linkedspec.git vendor/linkedspec
git -C vendor/linkedspec rev-parse HEAD
git add .gitmodules vendor/linkedspec
```

Review and commit the submodule revision with the application. For an existing
clone, run `git submodule update --init vendor/linkedspec`. The Lua consumer does
not need nested RGX/PGEN source. To update deliberately, fetch LinkedSpec, select
a reviewed revision, rebuild the selected Lua native products if their inputs
changed, test the application, then commit the new submodule pointer.

Retain the complete checkout. In particular, `lua/src/` and `specs/` must keep
their relative layout. The staged loader resolves
`specs/user_function_definition.spec` from its Lua module's own file location,
even when the application grammar has no user functions. It does not find that
supporting grammar through the caller's working directory or search roots.
Standard Lua `debug.getinfo` is needed for this module-relative lookup.

## Select a runtime and matching native products

The verified host is **macOS arm64**, with these installed identities:

| Route | Interpreter | Header package | Matching library |
| --- | --- | --- | --- |
| PUC Lua | Lua 5.5.1 | `pkg-config lua` 5.5.1 | PCRE2 10.48 |
| LuaJIT | LuaJIT 2.1.1788460057 | `pkg-config luajit` 2.1.1788460057 | PCRE2 10.48 |

The repository's declared PUC target remains 5.4; this guide's measured 5.5 route
does not establish 5.4 conformance or change that target. The existing native
malformed-regex error formatter can fail on the measured PUC host. These setup
checks use valid regex fixtures and do not establish invalid-regex handling.
The target-selection and formatter repairs remain tracked in the
[backend status](../overview/project-status.md).

Initial native preparation needs a C99 compiler, `pkg-config`, the selected Lua
development headers and PCRE2 development headers/library. The interpreter,
compiler, SDK, headers, PCRE2 and operating-system libraries are necessary
read-only toolchain/runtime inputs. Project outputs stay in the application.
There is no LuaRocks or external Lua JSON package installation for this consumer.

The maintained builder produces three files for each chosen ABI:

- `linkedspec_regex_pcre2.so`: native matching through PCRE2;
- `linkedspec_filesystem_native.so`: file-kind and working-directory inspection;
- `linkedspec_mcp_system.so`: native services used by the separate MCP interface.

Ordinary word parsing loads the first two modules. The setup verifier also loads
the third to check the complete builder output. Keep PUC Lua and LuaJIT products
in separate directories and select the matching directory at invocation time.
Do not treat the two ABI builds as interchangeable.

## Assemble and prepare the application

From the application root:

```sh
mkdir -p bin specs
cp vendor/linkedspec/examples/integration/lua/bin/parse_words.lua bin/parse_words.lua
cp vendor/linkedspec/examples/integration/lua/bin/parse-words bin/parse-words
cp vendor/linkedspec/examples/integration/word.spec specs/word.spec

APP_ROOT=$(pwd -P)
LINKEDSPEC_ROOT="$APP_ROOT/vendor/linkedspec"
export LINKEDSPEC_PROJECT_DATA_ROOT="$APP_ROOT/.app-data/linkedspec"
export LINKEDSPEC_CACHE_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/cache"
export LINKEDSPEC_SCRATCH_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/scratch"
export TMPDIR="$LINKEDSPEC_SCRATCH_ROOT/tmp"
export TMP="$TMPDIR"
export TEMP="$TMPDIR"

lua -E -v
pkg-config --modversion lua libpcre2-8
bash "$LINKEDSPEC_ROOT/tools/build_lua_native.sh" puc "$APP_ROOT/build/native/puc"
```

For LuaJIT, prepare its own products instead:

```sh
luajit -E -v
pkg-config --modversion luajit libpcre2-8
bash "$LINKEDSPEC_ROOT/tools/build_lua_native.sh" luajit "$APP_ROOT/build/native/luajit"
```

Choose either route; building both is useful when your application tests both
runtimes. The builder selects the `lua` or `luajit` header package independently
of the executable, so check their identities together. The verifier compares the
actual interpreter banner with the selected header package on the demonstrated
routes. A different toolchain needs its own matching build and verification.

On macOS the default builder invokes the selected developer tree's real `clang`
and supplies its SDK explicitly. This avoids the Apple compiler-selection shim's
temporary metadata writes. Native output paths are derived from the application
and checked against the checkout's filesystem volume before creation.

Ignore `build/` and `.app-data/`. Commit application source, grammar assets and
the Git submodule pointer. Retain compatible native products for ordinary runs;
rerun the builder when the pinned native source, interpreter ABI, headers,
compiler target or PCRE2 inputs change. The builder itself does not perform a
freshness check: invoking it explicitly rebuilds its three modules.

## Parse complete s-expression documents

Load `specs/SExprDocumentV1.spec` from your pinned checkout for complete
s-expression documents. Keep the module/supporting-grammar layout and select the
matching PUC Lua or LuaJIT native products as described above. Change the word
adapter's `top_rule = "Top"` to `top_rule = "Document"` for this grammar.

Read `result.value` as the native document: `format` is `linkedspec-sexpr-v1`,
`forms` is an ordered array, lists have `kind`/`items`, and atoms have
`kind`/`lexeme`. Preserve the JSON codec's array and harray identities, including
empty arrays. Atom lexemes remain strings with original quotes and escapes;
the [document grammar chapter](../specs-and-corpora/sexpr-document-v1.md) supplies
the full schema and examples.

Empty documents succeed with no forms. Invalid documents raise the typed
`runtime_exit_now` value with status 1; use `pcall` and
`linkedspec.is_runtime_exit_now` to identify it. No partial document is accepted.
From the LinkedSpec root, verify each prepared runtime separately:

```sh
bash tools/run_lua_project_data.sh puc lua/test/sexpr_document_v1_test.lua
bash tools/run_lua_project_data.sh luajit lua/test/sexpr_document_v1_test.lua
```

Each route checks all 37 authored cases, token-spelling round trips and fresh
independent input after every rejection using one compiled engine. This is
grammar-specific recovery proof, not a rollback promise for application effects.
The existing word adapter still takes text arguments. Its deployment instructions
continue to apply; include the selected document grammar in your application assets.

After preparing the repository integration example, replay this guide’s public-loader
path and exact `Top` → `Document` adaptation with:

```sh
bash tools/run_python_project_data.sh examples/integration/verify_sexpr.py --runtime puc
bash tools/run_python_project_data.sh examples/integration/verify_sexpr.py --runtime luajit
```

The verifier checks all 37 authored cases, earlier-output retention, the documented
relative grammar path, missing files and invalid UTF-8 grammar bytes. It preserves
the original examples and expectations. These are text-argument checks; the Rust
[file-consumer verifier](integration-rust.md#reproduce-the-integration-checks) separately
covers document-file bytes and relocated bundles.

## Parse native values

The shared grammar is:

```text
{{#include ../../../../examples/integration/word.spec}}
```

It extracts ASCII words and skips other text. It is not a complete-input
validator: `123 alpha rest` returns two words, and `café` returns `caf`.

The complete consumer is:

```lua
{{#include ../../../../examples/integration/lua/bin/parse_words.lua}}
```

With the same managed environment, run the PUC Lua application:

```sh
export LINKEDSPEC_LUA_NATIVE_ROOT="$APP_ROOT/build/native/puc"
bash "$LINKEDSPEC_ROOT/tools/project_data_run.sh" lua -E \
  "$APP_ROOT/bin/parse_words.lua" specs/word.spec alpha Beta 123 '123 alpha rest'
```

Or select the LuaJIT interpreter and its matching products:

```sh
export LINKEDSPEC_LUA_NATIVE_ROOT="$APP_ROOT/build/native/luajit"
bash "$LINKEDSPEC_ROOT/tools/project_data_run.sh" luajit -E \
  "$APP_ROOT/bin/parse_words.lua" specs/word.spec alpha Beta 123 '123 alpha rest'
```

Both routes produce:

```json
["alpha"]
["Beta"]
[]
["alpha","rest"]
```

The generic managed wrapper preserves the caller's working directory and supplies
`LINKEDSPEC_REPO_ROOT` for its own checkout. The example uses that root to select
exact `package.path` entries and uses `LINKEDSPEC_LUA_NATIVE_ROOT` for its sole
native `package.cpath` entry. The interpreter's `-E` flag ignores ambient Lua
initialization and module-path environment settings. These explicit paths select
the application's pinned dependency.

The grammar argument is an exact path: relative paths resolve against the caller's
working directory, while absolute paths select that file. Input arguments are
text to parse, not input file names. Use an absolute application grammar path
when invoking from a different working directory.

`load_and_compile_spec` resolves and strictly decodes the file, composes the
staged frontend, validates and compiles it. The loaded value retains source
identity; `loaded:create_engine()` builds a native engine. One engine handles
the loop's independent `runtime_parse` calls with `top_rule = "Top"`.
The bundled function parser is compiled once on first use and cached in that Lua
process; loading another application grammar reuses that supporting parser.

Read `result.value` for the direct native value. Arrays and harrays use the
repository JSON codec's explicit identities; plain Lua tables are not assumed
to be either kind. This adapter maps a host `nil` result to `json.null` before
encoding, preserving successful null and false values. For application use,
adapt the native result to your own model before serialization.

The adapter writes successful JSON values to stdout, stops at its first caught
failure and exits 1. Loader errors use `spec_pipeline_error_to_json`, retaining
type, stage, code and source identity. Missing grammar paths report
`resolve_spec_path` / `spec_path_not_found`; invalid file bytes report
`decode_spec_content` / `invalid_utf8`. Runtime errors retain their message and
optional structured diagnostic in a `runtime_error` record. The adapter also
copies `code`, `helper_name`, `expected_arity` and `actual_arity` from the native
error when present; those fields are not all included by the standard error JSON
projection. A distinct `runtime_exit_now` record preserves the requested `status`.
Other caught errors,
including missing arguments, use `consumer_error`.

Module or native-library loading happens before that handler and uses Lua's own
error reporting. The managed launcher can also emit its own process-control
diagnostics; a captured warning accompanies correct parser values and status0.
Its verification/repair remains tracked in [project status](../overview/project-status.md).
For programmatic event handling, use the native `diagnostic_sink` callback:
stderr can contain interpreter and launcher messages in addition to adapter records.
See [Native Spec Loading](native-spec-loading.md) for the loader
contract and [Diagnostics](../compiler/diagnostics.md) for runtime fields.
Ordinary parsing repeats the interpreter command, without invoking the native
builder. Each fresh process loads the retained modules and compiles its grammar
in memory; the example does not persist an engine across processes.

## Capture diagnostic events and handle failures

Diagnostic helpers deliver typed events separately from parse values. The example
enables a per-parse sink only when its first argument is `--diagnostics`.
For a grammar name equal to that option, put `--` before the grammar argument.
The sink writes one JSON record per event to stderr; successful values stay on
stdout. Delivery is synchronous and ordered, including events before a failure.
Without the option, diagnostic helpers are quiet and values are unchanged.

The maintained `diagnostics.spec` is:

```text
{{#include ../../../../examples/integration/lua/diagnostics.spec}}
```

Copy it into the application and run with the selected interpreter/native products:

```sh
cp "$LINKEDSPEC_ROOT/examples/integration/lua/diagnostics.spec" "$APP_ROOT/specs/"
bash "$LINKEDSPEC_ROOT/tools/project_data_run.sh" lua -E \
  "$APP_ROOT/bin/parse_words.lua" --diagnostics "$APP_ROOT/specs/diagnostics.spec" x
```

Stdout contains `"ok"`. Stderr contains these two records, whose key order is not
part of the contract:

```json
{"type":"diagnostic_output","helper_name":"say","rule_label":"Top","message":"héllo 雪\n"}
{"type":"diagnostic_output","helper_name":"print","rule_label":"Top","message":"done"}
```

Use `luajit -E` with the LuaJIT native directory for that route. Diagnostic events
are not parser trace events. This JSON adapter supplies a disabled trace emitter
explicitly and does not construct one from the ambient trace environment; an
inherited trace-file/reset setting therefore does not replace or mix with its
diagnostic output. Applications wanting parser tracing can inject a separate
caller-owned emitter through the [trace API](trace-api.md).

The maintained `exit.spec` demonstrates earlier values and immediate termination:

```text
{{#include ../../../../examples/integration/lua/exit.spec}}
```

With `--diagnostics`, parsing the three inputs `x y x` produces one stdout value
`"ok"`, then the stderr event `say` / `before\n`, followed by
`{"type":"runtime_exit_now","status":7}`. The final input is not executed.
This adapter exits **1 for any caught failure**, including typed `exit_now`;
the requested status is data for the application, not its process exit code.
Previously written values and delivered events remain observable.

A native helper arity failure retains its message, available error fields and
structured source attribution. Missing files and invalid UTF-8 remain loader
failures. A successful null or false value remains a successful JSON value.
Module loading occurs before the handler and still uses the interpreter's native
error output. These checks do not exercise the excluded malformed-regex path.

## Package and relocate the application

The launcher `bin/parse-words` derives its application root from its own location,
selects `vendor/linkedspec` and the chosen ABI directory, and configures writable
application-local data. It preserves the caller's working directory, so a relative
grammar argument is caller-relative. It rejects missing supporting grammar/native
products before starting the parser. For example:

```sh
bash "$APP_ROOT/bin/parse-words" puc "$APP_ROOT/specs/word.spec" alpha Beta
```

Keep a matching Lua interpreter and PCRE2 runtime library installed. Native
products are specific to their ABI, architecture and linked runtime libraries;
moving them on the verified host does not prove compatibility with another host.
No compiler, dependency build or native rebuild is needed for ordinary execution.

For a smaller source deployment, archive the committed Lua modules, grammar assets
and managed wrappers while preserving their relative layout. Copy the application's
adapter, launcher, grammar and already-built parsing modules:

```sh
ABI=puc
BUNDLE="$APP_ROOT/dist/lua-app"
mkdir -p "$BUNDLE/bin" "$BUNDLE/specs" "$BUNDLE/vendor/linkedspec" \
  "$BUNDLE/build/native/$ABI"
git -C "$LINKEDSPEC_ROOT" archive HEAD lua/src specs tools | \
  tar -x -C "$BUNDLE/vendor/linkedspec"
cp "$APP_ROOT/bin/parse_words.lua" "$APP_ROOT/bin/parse-words" "$BUNDLE/bin/"
cp "$APP_ROOT/specs/word.spec" "$BUNDLE/specs/"
cp "$APP_ROOT/build/native/$ABI/linkedspec_regex_pcre2.so" \
  "$APP_ROOT/build/native/$ABI/linkedspec_filesystem_native.so" \
  "$BUNDLE/build/native/$ABI/"
bash "$BUNDLE/bin/parse-words" "$ABI" "$BUNDLE/specs/word.spec" 'alpha Beta'
```

Choose `ABI=luajit` for its matching prepared products. Copy any additional
application grammars you use. The word parser does not load the MCP interface,
so its third native module is unnecessary in this bundle. RGX/PGEN are absent.
Package reviewed committed source and compatible native products together;
`git archive` does not include uncommitted source edits.

The bundle returns `["alpha","Beta"]` and can be moved as a unit. Invoke the
launcher at its new location and supply the moved grammar path, or an explicit
caller-relative application grammar. Source/native files may be read-only, but
the bundle's application data and managed checkout-identity directories must be
writable. No immutable-bundle, standalone-executable, other-platform or PUC 5.4
guarantee is implied by these macOS arm64 checks.

## Run the maintained consumer checks

From the LinkedSpec repository root, prepare the checked-in example:

```sh
REPO_ROOT=$(pwd -P)
APP_ROOT="$REPO_ROOT/examples/integration/lua"
LINKEDSPEC_ROOT="$REPO_ROOT"
export LINKEDSPEC_PROJECT_DATA_ROOT="$APP_ROOT/.app-data/linkedspec"
export LINKEDSPEC_CACHE_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/cache"
export LINKEDSPEC_SCRATCH_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/scratch"
export TMPDIR="$LINKEDSPEC_SCRATCH_ROOT/tmp"
export TMP="$TMPDIR"
export TEMP="$TMPDIR"
bash tools/build_lua_native.sh puc "$APP_ROOT/build/native/puc"
bash tools/build_lua_native.sh luajit "$APP_ROOT/build/native/luajit"
bash tools/run_python_project_data.sh examples/integration/lua/verify_words.py --runtime puc
bash tools/run_python_project_data.sh examples/integration/lua/verify_words.py --runtime luajit
bash tools/run_python_project_data.sh examples/integration/lua/verify_deployment.py --runtime puc
bash tools/run_python_project_data.sh examples/integration/lua/verify_deployment.py --runtime luajit
```

The Python 3.9+ verifier uses already-built products and performs no native build.
It checks runtime/header identities, actual module sources, the native module
trio, exact supporting-grammar identity and its one-build cache, independent and
repeated values, Unicode paths, missing files/arguments, strict UTF-8, successful
null/false values, ignored ambient Lua initialization and missing native products.
Native hashes and modification times must remain unchanged after repeated calls.
All temporary fixtures are removed and application data stays on this volume.

For a prepared separate application, supply `--package`, `--library-root` and
`--grammar` explicitly. Its native products must already exist under
`build/native/puc` or `build/native/luajit`. Keep the application-owned storage and
products; do not substitute `tools/run_lua_project_data.sh` for the ordinary
consumer command, because that targeted test wrapper builds disposable native
products on every invocation.

The deployment verifier additionally checks exact Unicode events, typed exit and
arity records, stop behavior, null/false/nested values, trace separation and
option-like grammar paths. It constructs the committed source closure without
copying caches, packages only the two parsing modules, moves it to a Unicode path,
and verifies outside-cwd calls and unchanged source/native bytes. Controlled bad
caller and bad packaged supporting grammars prove which asset is selected;
missing assets fail explicitly. Its source-identity check compares the selected
library against the verifier repository's committed revision. Run it from a
matching checkout; a prepared separate application can use the same `--package`,
`--library-root` and `--grammar` options. No native build runs in either verifier.
