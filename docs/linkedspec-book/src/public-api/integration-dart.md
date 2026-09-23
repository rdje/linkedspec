# Integrating LinkedSpec into a Dart application

See [Application Integration](integration.md) for backend selection, shared
checkout and storage principles, and the common example.

Use `package:linkedspec_dart/linkedspec_dart.dart` to load a grammar, compile it
once and parse inputs inside your Dart process. The package uses Dart's runtime
and its own regex compatibility code. This route requires no RGX/PGEN build,
Perl process, native regex library installation or third-party runtime package.

This chapter covers source checkout, package setup, required grammar assets,
native values, diagnostic events, failures and a compiled application bundle.

## Add and pin the source dependency

From your application's repository root:

```sh
git submodule add https://github.com/rdje/linkedspec.git vendor/linkedspec
git -C vendor/linkedspec rev-parse HEAD
git add .gitmodules vendor/linkedspec
```

Review and commit the submodule revision with your application. For an existing
clone, run `git submodule update --init vendor/linkedspec`. Nested RGX/PGEN source
is not needed for this Dart consumer. To update deliberately, fetch LinkedSpec,
check out a reviewed revision inside `vendor/linkedspec`, refresh the application
assets described below, run your checks and commit the changed submodule pointer.

Add `linkedspec_dart` to your application's `pubspec.yaml`. A minimal standalone
application looks like this:

```yaml
name: linkedspec_integration_example
version: 0.1.0
publish_to: none

environment:
  sdk: ">=3.9.0 <4.0.0"

dependencies:
  linkedspec_dart:
    path: vendor/linkedspec/dart
```

The verified SDK is **Dart 3.13.3 on macOS arm64**. The package declares the SDK
range above; this example does not establish a minimum-version or other-platform
support matrix. Its file loader uses `dart:io`; this is a native Dart application
example, not a browser integration.

LinkedSpec has no hosted runtime dependencies in its Dart manifest. Its own `test`
dependency is for backend development and is not inherited by this application.
The minimal application's package configuration contains exactly two local
packages: the application and `linkedspec_dart`.

## Assemble the application and its assets

From the application root:

```sh
mkdir -p bin specs
cp vendor/linkedspec/examples/integration/dart/bin/parse_words.dart bin/parse_words.dart
cp vendor/linkedspec/examples/integration/dart/bin/parse-words bin/parse-words
cp vendor/linkedspec/examples/integration/word.spec specs/word.spec
cp vendor/linkedspec/examples/integration/dart/diagnostics.spec specs/diagnostics.spec
cp vendor/linkedspec/examples/integration/dart/exit.spec specs/exit.spec
cp vendor/linkedspec/specs/user_function_definition.spec specs/user_function_definition.spec
```

The last file is required by the standard staged file loader, including when your
application grammar has no user-defined functions. Its default function parser
searches upward from the working directory and then from the running script's
directory for `specs/user_function_definition.spec`. A nested package dependency
alone does not add that nested checkout to these search roots. Running from your
application root selects the application-owned copy above. Keep it byte-identical
to the pinned LinkedSpec source and refresh it when updating that pin.

This supporting-grammar lookup is separate from `SpecRequest.path`, which resolves
the application grammar exactly. Do not depend on an unrelated ancestor checkout
having a convenient `specs/` directory. For callers that need to supply every
frontend input explicitly, the lower-level
`parseSpecWithStagedUserFunctionDefinitions` API accepts `parserSpecSource`; the
standard `loadAndCompileSpec` signature does not expose that override.

The shared example grammar is:

```text
{{#include ../../../../examples/integration/word.spec}}
```

It extracts ASCII words and skips other text. It is not a complete-input
validator: `123 alpha rest` returns two words, and `café` returns `caf`.

The complete native consumer is:

```dart
{{#include ../../../../examples/integration/dart/bin/parse_words.dart}}
```

## Prepare packages with application-owned storage

From the application root, derive storage paths at runtime:

```sh
APP_ROOT=$(pwd -P)
export LINKEDSPEC_PROJECT_DATA_ROOT="$APP_ROOT/.app-data/linkedspec"
export LINKEDSPEC_CACHE_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/cache"
export LINKEDSPEC_SCRATCH_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/scratch"
export PUB_CACHE="$LINKEDSPEC_CACHE_ROOT/dart-pub"
export LINKEDSPEC_DART_HOME="$LINKEDSPEC_CACHE_ROOT/dart-home"
bash vendor/linkedspec/tools/run_dart_project_data.sh pub get --offline
```

Ignore `.app-data/`, `.dart_tool/` and application build output in your application
repository. Commit `pubspec.yaml`, `pubspec.lock`, your source/assets and the Git
submodule pointer. A path dependency's lockfile does not replace the Git revision
pin. Keep the manifest's dependency path relative; `.dart_tool` is disposable
SDK-generated metadata and must not be committed.

The wrapper keeps SDK command metadata, package cache and temporary work on the
application's volume. It preserves the caller's working directory and gives only
the Dart child an isolated home. This prevents Dart command startup from writing
telemetry settings in the developer's home. The SDK and its standard runtime are
required read-only toolchain dependencies.

For the minimal application above, offline package resolution succeeds with an
initially empty application package cache because the sole dependency is a local
path. Applications with additional hosted packages must populate their own cache
before requesting offline resolution; omit `--offline` for that authorized first
fetch. Reuse the same managed environment for subsequent SDK commands.

## Parse native values

Still from the application root and with the same environment:

```sh
bash vendor/linkedspec/tools/run_dart_project_data.sh run bin/parse_words.dart \
  specs/word.spec alpha Beta 123 '123 alpha rest'
```

Expected stdout:

```json
["alpha"]
["Beta"]
[]
["alpha","rest"]
```

`loadAndCompileSpec` resolves and strictly decodes the grammar as UTF-8, composes
the staged frontend, validates and compiles it. `createEngine()` retains the
loaded grammar identity for runtime diagnostics. The example performs this setup
once, then calls `execute` for each independent input string with `topRule: 'Top'`.

`RuntimeParseResult.value` is the grammar's direct result. For this grammar it is
a Dart `List` of strings, with no additional collection envelope. Adapt this value
to your application's model before serializing it. The result object also exposes
match state, cursor positions, output and lifecycle information; those fields are
not substitutes for validating a grammar's complete-input contract.

An empty input or digits alone produce `[]`. Other grammars may return `null`,
numbers, booleans, maps or nested lists. This executable takes input text as
arguments; it does not interpret those arguments as input file names.

The consumer projects `SpecPipelineException.toJson()` on stderr and exits 1 for
loader failures. A missing path has type `spec_pipeline_error`, stage
`resolve_spec_path` and code `spec_path_not_found`. Invalid UTF-8 grammar bytes
fail at `decode_spec_content` with code `invalid_utf8`. Runtime exceptions retain
their message and optional diagnostic in the example's `runtime_error` envelope.
`RuntimeExitNow` has its own `runtime_exit_now` record; other caught exceptions use
`consumer_error`. It stops at the first failure.
See [Native Spec Loading](native-spec-loading.md) for the full loader contract.

Repeat the run command to start another Dart process with the same package
resolution and pinned source. The Dart SDK may compile or reuse its own generated
products; this does not build RGX/PGEN. The compiled LinkedSpec engine is an
in-memory object and this example does not persist it across processes.

## Parse complete s-expression documents

Load `specs/SExprDocumentV1.spec` from your pinned checkout for complete
s-expression documents, keeping the supporting function grammar described above.
Change the word adapter's `topRule: 'Top'` to `topRule: 'Document'` when selecting
this grammar. Read the direct `RuntimeParseResult.value`: it is a map with
`format: 'linkedspec-sexpr-v1'` and an ordered `forms` list. Atom maps preserve
`kind` and the string `lexeme`; string quotes and escapes remain in that lexeme.
The [document grammar chapter](../specs-and-corpora/sexpr-document-v1.md) defines
the schema and shows exact examples.

Empty documents succeed with no forms. Invalid documents throw `RuntimeExitNow`
with status 1, without an accepted partial document. Keep the typed failure
handling below. To verify the contract from the LinkedSpec root:

```sh
(
  cd dart
  bash ../tools/run_dart_project_data.sh test test/sexpr_document_v1_test.dart
)
```

The native tests check all 37 authored cases, token-spelling round trips and fresh
independent input after every rejection through one compiled engine. This is
grammar-specific recovery proof, not rollback of arbitrary application effects.
The existing word executable still takes text arguments; it is not a file reader.
If adapting its AOT bundle, include `SExprDocumentV1.spec` among your application
assets and retain the required `user_function_definition.spec`.

After preparing the repository integration example, replay this guide’s public-loader
path and exact `Top` → `Document` adaptation with:

```sh
bash tools/run_python_project_data.sh examples/integration/verify_sexpr.py --runtime dart
```

The verifier checks all 37 authored cases, earlier-output retention, the documented
relative grammar path, missing files and invalid UTF-8 grammar bytes. It preserves
the original examples and expectations. These are text-argument checks; the Rust
[file-consumer verifier](integration-rust.md#reproduce-the-integration-checks) separately
covers document-file bytes and relocated bundles.

## Capture diagnostics and handle failures

The example is quiet by default: grammar calls such as `say(...)` do not write
to stdout or stderr unless you install a diagnostic sink. Add `--diagnostics`
to send one JSON record per event to stderr, leaving stdout for parser values.
The callback is installed for each `execute` invocation.

The diagnostic grammar is:

```text
{{#include ../../../../examples/integration/dart/diagnostics.spec}}
```

From the application root, with the same managed environment:

```sh
bash vendor/linkedspec/tools/run_dart_project_data.sh run bin/parse_words.dart \
  --diagnostics specs/diagnostics.spec x
```

Stdout contains `"ok"`. Stderr contains these two records in order:

```json
{"type":"diagnostic_output","helper_name":"say","rule_label":"Top","message":"héllo 雪\n"}
{"type":"diagnostic_output","helper_name":"print","rule_label":"Top","message":"done"}
```

Omit `--diagnostics` and the parser value stays `"ok"` while stderr stays empty.
For an embedded application, pass `diagnosticOutputSink: events.add` with a
`List<RuntimeDiagnosticOutputEvent>` instead of serializing to stderr. Events
arrive synchronously. A throwing sink propagates its caller-owned failure;
choose the application's logging and failure policy accordingly.

Diagnostic helper events are separate from runtime error diagnostics and native
trace. The example does not call `LinkedSpecTraceConfig.fromEnvironment` or
install a trace emitter. Inherited `LINKEDSPEC_TRACE_*` settings therefore do not
turn tracing on for this consumer. See [Tracing and Debugging API](trace-api.md)
for explicitly configured tracing.

The exit example demonstrates a successful input before an immediate exit:

```text
{{#include ../../../../examples/integration/dart/exit.spec}}
```

```sh
bash vendor/linkedspec/tools/run_dart_project_data.sh run bin/parse_words.dart \
  --diagnostics specs/exit.spec x y x
```

Stdout contains one `"ok"` from the first input. Stderr contains:

```json
{"type":"diagnostic_output","helper_name":"say","rule_label":"Top","message":"before\n"}
{"type":"runtime_exit_now","status":7}
```

The example process exits **1**, retaining the grammar's status **7** in the
typed record. That process status is an application policy; the library throws
`RuntimeExitNow(7)` and does not terminate the host process. The final input and
the action after `exit_now` do not execute. Earlier values and diagnostic events
remain delivered; the example promises neither rollback nor reuse after failure.

| Situation | Example result |
| --- | --- |
| Missing grammar | Exit 1; `spec_pipeline_error`, `resolve_spec_path`, `spec_path_not_found` |
| Invalid UTF-8 grammar | Exit 1; `decode_spec_content`, `invalid_utf8` |
| Malformed grammar | Exit 1; `parse_spec`, `spec_parse_failed` |
| Comment-only grammar | Exit 1; `validate_spec`, `no_rules_defined` |
| Runtime helper misuse, such as `say()` | Exit 1; `runtime_error`, message and structured diagnostic; the demonstrated arity error has stage `helper_arity_mismatch` and the loaded grammar path |
| `exit_now(7)` | Exit 1; `runtime_exit_now` with `status: 7` |
| Missing command arguments | Exit 1; `consumer_error` |
| Successful `return(undef)` | Exit 0; stdout `null` |

Errors do not turn a successful `null` result into failure. Inspect exception
types and their structured fields rather than testing result truthiness or
matching human-readable messages. Use `--` before a grammar whose filename
would otherwise be interpreted as the leading `--diagnostics` option.

## Compile and deploy a native application

The tested deployment target is **macOS arm64 with Dart 3.13.3**. Compile for the
intended host; these measurements do not establish cross-compilation, another
OS/architecture, browser deployment or the package's minimum supported SDK.

From the application root, using the managed environment from package setup:

```sh
mkdir -p build/bin build/specs
bash vendor/linkedspec/tools/run_dart_project_data.sh compile exe \
  bin/parse_words.dart -o build/bin/parse_words
cp bin/parse-words build/bin/parse-words
chmod +x build/bin/parse-words
cp specs/word.spec specs/diagnostics.spec specs/exit.spec \
  specs/user_function_definition.spec build/specs/
bash build/bin/parse-words build/specs/word.spec alpha Beta 123
```

The output is `["alpha"]`, `["Beta"]`, then `[]`, one JSON value per line.
Ignore `build/` in the application repository. Compilation happens during
preparation; ordinary runs invoke the retained native executable. Recompile
when changing application code, the pinned library or the selected build target.
The grammar itself is still loaded and compiled in memory once per process,
then reused for the independent inputs in that process.

The deployment bundle has six files:

```text
build/
  bin/parse-words
  bin/parse_words
  specs/word.spec
  specs/diagnostics.spec
  specs/exit.spec
  specs/user_function_definition.spec
```

`parse_words` is the compiled program. `parse-words` is this Bash launcher:

```sh
{{#include ../../../../examples/integration/dart/bin/parse-words}}
```

The launcher derives the application root from its own location, checks the
executable and required supporting grammar, makes a relative application-grammar
argument absolute against the caller's directory, then changes to the bundle
root before loading the frontend. This keeps both meanings explicit: your grammar
path belongs to the caller, while frontend assets belong to the application.

The asset check matters because the default frontend can search ancestor
directories. A missing packaged copy must fail instead of silently using another
checkout's grammar. Bypassing the launcher from an arbitrary directory can select
that directory's supporting grammar before the executable's own ancestors.
The verifier demonstrates this with a deliberately invalid caller-owned copy.

For example, start the packaged application from the parent directory:

```sh
(
  cd "$APP_ROOT/.."
  bash "$APP_ROOT/build/bin/parse-words" \
    "$APP_ROOT/build/specs/word.spec" 'alpha rest'
)
```

The same layout can be moved together to another directory on the application
volume. The verifier moves it into a Unicode path and repeats native values,
diagnostic and exit checks. Its bundle contains no Dart source, package metadata,
SDK or LinkedSpec checkout, and it executes with no Dart command on `PATH`.
The host still provides Bash for the launcher and the operating-system runtime
needed by the compiled executable. Bundle file bytes remain unchanged during
these tests, including after files are made read-only. The launcher was tested
with both system Bash 3.2.57 and Bash 5.3.15 on this host.

## Verify the maintained example

The checked-in package at `examples/integration/dart/` uses `../../../dart` as its
local dependency path. That relative path is for its position inside LinkedSpec;
use `vendor/linkedspec/dart` in a separate application's manifest as shown above.

From the LinkedSpec root:

```sh
bash tools/run_python_project_data.sh examples/integration/dart/verify_words.py
```

Python is only needed for verification. The application itself runs in Dart.
The verifier resolves packages offline with application-local data, asserts the
two exact package roots, checks seven independent/repeated values and Unicode
working-directory/path handling, and checks usage, missing-source and UTF-8
failures. A controlled bad supporting grammar proves that lookup selected the
owned copy; restoring the exact bytes restores successful parsing. Temporary
verification assets are removed after the run.

To verify deployment, start from the LinkedSpec root after the word verifier has
prepared this package. Select the maintained application's own data directories
and compile it:

```sh
cd examples/integration/dart
APP_ROOT=$(pwd -P)
export LINKEDSPEC_PROJECT_DATA_ROOT="$APP_ROOT/.app-data/linkedspec"
export LINKEDSPEC_CACHE_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/cache"
export LINKEDSPEC_SCRATCH_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/scratch"
export PUB_CACHE="$LINKEDSPEC_CACHE_ROOT/dart-pub"
export LINKEDSPEC_DART_HOME="$LINKEDSPEC_CACHE_ROOT/dart-home"
mkdir -p build/bin
bash ../../../tools/run_dart_project_data.sh compile exe \
  bin/parse_words.dart -o build/bin/parse_words
```

Then return to the LinkedSpec root:

```sh
cd ../../..
bash tools/run_python_project_data.sh examples/integration/dart/verify_deployment.py
```

The verifier reuses that executable. It checks source and AOT quiet/event modes,
Unicode, typed exits and earlier output, structured loader/runtime failures,
successful null results, option-like grammar names and trace separation. It then
packages only the six listed files, checks exact asset selection, moves the
bundle and reruns it outside its directory without a Dart command on `PATH`.
Missing owned assets fail explicitly. Generated verification fixtures are removed.

The setup and deployment were also replayed in a separate application with a
clean committed LinkedSpec submodule, uninitialized nested dependencies and its
own package cache. Python is verification tooling; neither source nor compiled
application execution delegates parsing to Python or another backend.
Existing backend-wide formatter and SDK regex-adapter analysis issues remain
tracked independently; successful consumer analysis and execution do not
establish a green complete Dart component gate.
