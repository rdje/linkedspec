# Integrating LinkedSpec into a Julia application

Use the `LinkedSpecJulia` package to load a grammar, compile it once and parse
independent inputs in your Julia process. The package uses Julia's `Regex` and
requires JSON3 plus Julia standard libraries. This native route does not require
RGX/PGEN preparation or a Perl subprocess.

## Add and pin the source dependency

From your application's repository root:

```sh
git submodule add https://github.com/rdje/linkedspec.git vendor/linkedspec
git -C vendor/linkedspec rev-parse HEAD
git add .gitmodules vendor/linkedspec
```

Review and commit the submodule revision with the application. For an existing
clone, run `git submodule update --init vendor/linkedspec`. Nested RGX/PGEN source
is not needed for this Julia consumer. To update deliberately, fetch LinkedSpec,
check out a reviewed revision, prepare and test the application, then commit the
new submodule pointer and any resulting application manifest changes.

Create this `Project.toml` in your application root:

```toml
[deps]
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
LinkedSpecJulia = "8eec5991-a432-4f89-ae45-eeda2e697757"

[sources]
LinkedSpecJulia = {path = "vendor/linkedspec/julia"}

[compat]
JSON3 = "1.14.3"
julia = "1.12"
```

The verified runtime is **Julia 1.12.7 on macOS arm64**. The compatibility entries
are version ranges, not proof of every accepted runtime or dependency version.
JSON3 is a direct application dependency because this example serializes native
values to JSON; LinkedSpec also depends on it internally. `[sources]` supplies
the local package when this application project is active. It does not propagate
the same source selection to another environment that depends on your project.

## Assemble the application

From the application root:

```sh
mkdir -p bin specs
cp vendor/linkedspec/examples/integration/julia/bin/parse_words.jl bin/parse_words.jl
cp vendor/linkedspec/examples/integration/word.spec specs/word.spec
```

Retain the complete LinkedSpec checkout. Its staged file loader needs
`specs/user_function_definition.spec` even for a grammar without user functions.
Julia searches package-source ancestors before working-directory ancestors, so
the complete checkout supplies this supporting grammar beside `julia/`.
Copying only the `julia/` subtree would lose that arrangement. The application
grammar and this supporting parser grammar have separate resolution rules.

The shared example grammar is:

```text
{{#include ../../../../examples/integration/word.spec}}
```

It extracts ASCII words and skips other text. It is not a complete-input
validator: `123 alpha rest` returns two words, and `café` returns `caf`.

The complete consumer is:

```julia
{{#include ../../../../examples/integration/julia/bin/parse_words.jl}}
```

The script derives the application root from its own `bin/` directory. Relative
grammar arguments resolve against that application root, even when the caller
starts elsewhere. Absolute grammar paths select that exact file. Input arguments
are text to parse, not input file names.

## Prepare packages with application-owned storage

From the application root, derive these paths at runtime:

```sh
APP_ROOT=$(pwd -P)
LINKEDSPEC_ROOT="$APP_ROOT/vendor/linkedspec"
export LINKEDSPEC_PROJECT_DATA_ROOT="$APP_ROOT/.app-data/linkedspec"
export LINKEDSPEC_CACHE_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/cache"
export LINKEDSPEC_SCRATCH_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/scratch"
export JULIA_DEPOT_PATH="$LINKEDSPEC_CACHE_ROOT/julia-depot:"
export LINKEDSPEC_JULIA_DEPOT_PATH="$JULIA_DEPOT_PATH"
export JULIA_LOAD_PATH='@:@stdlib'
export TMPDIR="$LINKEDSPEC_SCRATCH_ROOT/tmp"
export TMP="$TMPDIR"
export TEMP="$TMPDIR"
JULIA_PKG_OFFLINE=false bash "$LINKEDSPEC_ROOT/tools/run_julia_project_data.sh" \
  --project="$APP_ROOT" -e 'using Pkg; Pkg.instantiate()'
```

The first preparation may fetch the registry and required package sources and
precompile packages. It needs network access when those inputs are absent. The
wrapper defaults to offline mode; the command explicitly enables this initial
fetch. An empty depot cannot satisfy JSON3 merely because LinkedSpec is a local
path dependency.

The first depot is writable and belongs to the application. On the demonstrated
Unix host, the trailing `:` retains Julia's system depots without adding the user
home depot. Those system depots and the installed Julia runtime are required
read-only toolchain inputs. `JULIA_LOAD_PATH` restricts package loading to the
selected application and standard libraries. Both depot variables are set
because the managed wrapper's `LINKEDSPEC_JULIA_DEPOT_PATH` override has priority.
The wrapper disables startup/history files and routes temporary data to the
application volume. It changes the working directory to the LinkedSpec checkout,
so the explicit absolute `--project` and script paths matter.

Ignore `.app-data/` and build outputs. Commit `Project.toml`, the Pkg-generated
`Manifest.toml`, application source/assets and the Git submodule pointer. Keep
the source path relative in both TOML files. The manifest locks registry package
versions and content hashes; the Git submodule pins the path dependency's source.
The library's own `julia/Manifest.toml` is not the application's dependency lock.
Do not edit generated manifest entries by hand.

The demonstrated application resolved JSON3 1.14.3, Parsers 2.8.8,
PrecompileTools 1.3.4, Preferences 1.6.0 and StructTypes 1.11.0. A new application
without a manifest can resolve different compatible versions later. Commit its
resolved manifest, and review intentional updates as application changes.

After preparation, this offline replay uses the retained sources and manifest:

```sh
JULIA_PKG_OFFLINE=true bash "$LINKEDSPEC_ROOT/tools/run_julia_project_data.sh" \
  --project="$APP_ROOT" -e 'using Pkg; Pkg.instantiate()'
```

Retain package sources as well as compiled caches. Compiled cache files alone
are insufficient for ordinary package loading. Julia may precompile again when
the selected runtime, source or environment changes; this is separate from
compiling a LinkedSpec grammar in memory.

## Parse native values

With the same managed environment:

```sh
bash "$LINKEDSPEC_ROOT/tools/run_julia_project_data.sh" \
  --project="$APP_ROOT" "$APP_ROOT/bin/parse_words.jl" \
  specs/word.spec alpha Beta 123 '123 alpha rest'
```

Expected stdout:

```json
["alpha"]
["Beta"]
[]
["alpha","rest"]
```

`load_and_compile_spec` resolves and strictly decodes the grammar as UTF-8,
composes its staged frontend, validates it and compiles it. `create_engine`
retains the loaded source identity for runtime diagnostics. The example performs
that setup once and calls `runtime_execute` with `top_rule = "Top"` for each
independent input. Read `.value` for the direct native result; this grammar
returns an array of strings without an extra collection envelope. Adapt the
native value to your application model before serializing it.

Empty input or digits alone produce `[]`. Other grammars can return `nothing`,
numbers, booleans, dictionaries or nested arrays. JSON3 writes `nothing` as
`null`; a successful null value is not a failure signal. The result also exposes
parse state, which does not replace a grammar's complete-input validation policy.

The example stops at its first caught failure and exits 1. Loader exceptions use
`SpecPipelineException` and `to_json`; missing grammar paths report type
`spec_pipeline_error`, stage `resolve_spec_path`, code `spec_path_not_found`.
Invalid UTF-8 bytes report stage `decode_spec_content`, code `invalid_utf8`.
Runtime exceptions retain their message and optional diagnostic in a
`runtime_error` record. Other caught errors, including missing arguments, use
`consumer_error`. Interrupt, out-of-memory and stack-overflow exceptions rethrow.
Package import failures happen before this application's error handler and use
Julia's own reporting. See [Native Spec Loading](native-spec-loading.md) for the
loader contract and [Diagnostics](../compiler/diagnostics.md) for runtime fields.

Ordinary parsing runs the last command again; it does not need a package update
or dependency build command. Each new Julia process loads the prepared package
environment and constructs one in-memory engine. The example does not persist
that engine across processes or promise a fixed startup time.

## Run the maintained setup checks

The checked-in application at `examples/integration/julia/` uses the same source
with the relative dependency path `../../../julia`. From the LinkedSpec root:

```sh
REPO_ROOT=$(pwd -P)
APP_ROOT="$REPO_ROOT/examples/integration/julia"
LINKEDSPEC_ROOT="$REPO_ROOT"
export LINKEDSPEC_PROJECT_DATA_ROOT="$APP_ROOT/.app-data/linkedspec"
export LINKEDSPEC_CACHE_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/cache"
export LINKEDSPEC_SCRATCH_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/scratch"
export JULIA_DEPOT_PATH="$LINKEDSPEC_CACHE_ROOT/julia-depot:"
export LINKEDSPEC_JULIA_DEPOT_PATH="$JULIA_DEPOT_PATH"
export JULIA_LOAD_PATH='@:@stdlib'
export TMPDIR="$LINKEDSPEC_SCRATCH_ROOT/tmp"
export TMP="$TMPDIR"
export TEMP="$TMPDIR"
JULIA_PKG_OFFLINE=false bash "$LINKEDSPEC_ROOT/tools/run_julia_project_data.sh" \
  --project="$APP_ROOT" -e 'using Pkg; Pkg.instantiate()'
bash "$LINKEDSPEC_ROOT/tools/run_julia_project_data.sh" \
  --project="$APP_ROOT" "$APP_ROOT/bin/parse_words.jl" \
  ../word.spec alpha Beta 123 '123 alpha rest'
bash tools/run_python_project_data.sh examples/integration/julia/verify_words.py
```

Once this application depot is prepared, use `JULIA_PKG_OFFLINE=true` for any
later instantiation and reuse it for ordinary parsing.

The verifier uses Python 3.11 or newer and the installed Julia runtime. It
instantiates offline, verifies the selected project, relative manifest path,
module origins, supporting grammar and same-volume application data, then checks
exact values, repeated inputs, Unicode paths, missing arguments/files, strict
UTF-8 and null success. It also checks the package-owned supporting grammar while
Julia's working directory contains a deliberately invalid competing copy.
Temporary fixtures are removed after the run. For a separate application, pass
`--package`, `--library-root` and `--grammar` explicitly. Preparation must already
have populated that application's own depot.
