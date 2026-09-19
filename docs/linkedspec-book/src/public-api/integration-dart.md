# Integrating LinkedSpec into a Dart application

Use `package:linkedspec_dart/linkedspec_dart.dart` to load a grammar, compile it
once and parse inputs inside your Dart process. The package uses Dart's runtime
and its own regex compatibility code. This route requires no RGX/PGEN build,
Perl process, native regex library installation or third-party runtime package.

This chapter covers source checkout, package setup, required grammar assets and
a runnable native word consumer. Deployment and comprehensive runtime diagnostics
are the next part of this backend's integration work.

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
cp vendor/linkedspec/examples/integration/word.spec specs/word.spec
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
their message and optional diagnostic in the example's `runtime_error` envelope;
other host/usage errors use `consumer_error`. It stops at the first failure.
See [Native Spec Loading](native-spec-loading.md) for the full loader contract.

Repeat the run command to start another Dart process with the same package
resolution and pinned source. The Dart SDK may compile or reuse its own generated
products; this does not build RGX/PGEN. The compiled LinkedSpec engine is an
in-memory object and this example does not persist it across processes.

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

The setup was also replayed in a separate application with a clean committed
LinkedSpec submodule, uninitialized nested dependencies and its own initially
empty package cache. This verifies the native source setup on the stated host;
AOT packaging, moved deployment and complete runtime diagnostic examples remain
separate integration work. Existing backend-wide formatter and SDK regex-adapter
analysis issues remain tracked independently; successful consumer analysis and
execution do not establish a green complete Dart component gate.
