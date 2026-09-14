# Integrating LinkedSpec into a Rust application

Use the `linkedspec-runtime` crate to load a `.spec`, compile it once and parse
inputs inside your Rust process. Cargo brings `linkedspec-core` and the RGX regex
engine through path dependencies. There is no Perl parser process in this route.

This chapter covers a pinned source checkout, initial dependency preparation,
native API use, real UTF-8 files, application values and deployment. The runnable
examples live in `examples/integration/rust/`. Use the Lispish file example below
for an application such as ARCHOGEN.

**Lispish scope:** the shipped grammar extracts the first parenthesized form.
It can skip malformed or extra text. A successful value does **not** establish
that the complete file is valid. Read the concrete limits below before choosing
it as your application's file format.

## Add and pin the source dependency

From your application's repository root:

```sh
git submodule add https://github.com/rdje/linkedspec.git vendor/linkedspec
git -C vendor/linkedspec submodule update --init rgx
git -C vendor/linkedspec/rgx submodule update --init subs/pgen
git -C vendor/linkedspec rev-parse HEAD
git add .gitmodules vendor/linkedspec
```

Review the revision and commit the submodule pointer with your application. For
an existing application clone, first run `git submodule update --init
vendor/linkedspec`, then the two nested commands above. These commands retrieve
the Rust dependency closure. `git submodule update --init --recursive` also works,
but retrieves additional optional dependency/test repositories which this native
Rust example does not need. Checkout does not generate PGEN's parser inputs.

To update deliberately, fetch LinkedSpec, check out the reviewed revision inside
`vendor/linkedspec`, initialize its pinned nested dependencies again, then verify your
application before committing the changed pointer. Keep local nested changes out
of that update. Do not substitute an unreviewed branch tip for a release pin.

Add this dependency to the application's existing `Cargo.toml`:

```toml
[dependencies]
linkedspec-runtime = { path = "vendor/linkedspec/rust/linkedspec-runtime" }
```

Cargo resolves a path dependency relative to the manifest containing it. Point to
the crate directory, not the LinkedSpec root or the `rust/` workspace. Applications
should commit their resulting `Cargo.lock` as well as the submodule pointer.
[Cargo path dependencies](https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html#specifying-path-dependencies)

The inspected RGX/PGEN dependency manifests require Rust **1.95**. The checked-in
example therefore declares `rust-version = "1.95"` and edition 2024. Recheck the
chosen revision's manifests when updating; older Rust README wording is not the
authority for these dependency requirements. Verification currently uses Rust
1.95.0 on macOS arm64, not a minimum-version or cross-platform test matrix.

## Keep preparation and build products local

The maintained wrapper derives paths at runtime and validates their filesystem
location. From the application root, select an application-owned data directory:

```sh
APP_ROOT=$(pwd -P)
export LINKEDSPEC_PROJECT_DATA_ROOT="$APP_ROOT/.app-data/linkedspec"
export LINKEDSPEC_CACHE_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/cache"
export LINKEDSPEC_SCRATCH_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/scratch"
export CARGO_HOME="$APP_ROOT/.app-data/cargo-home"
export CARGO_TARGET_DIR="$APP_ROOT/.app-data/target"
bash vendor/linkedspec/tools/run_cargo_local.sh --version
```

Ignore `.app-data/` in the application repository. Keep these runtime-derived
paths in a launcher; do not save the expanded machine-specific values in a
manifest. The wrapper supplies local temporary directories and cache locations.
It changes to the LinkedSpec root, so pass the application's manifest explicitly:

```sh
bash vendor/linkedspec/tools/run_cargo_local.sh metadata \
  --format-version 1 --manifest-path "$APP_ROOT/Cargo.toml"
```

Initial package resolution may need network access. After preparing and locking
the graph, add `--offline --locked` to require the retained package store and
lockfile. Copying only a target directory is insufficient: source packages and
the exact nested checkout are also required.

### Initial PGEN preparation

Fresh PGEN checkouts do not ship the generated parser Rust sources. With Rust,
Cargo, a native linker/toolchain, Bash and Make available, prepare the pinned
dependency once. Keep the environment from the preceding section. Initial Cargo
package resolution needs network access when the local store is incomplete:

```sh
# The pinned Makefile runs ./target/debug/ast_pipeline directly.
CARGO_TARGET_DIR="$APP_ROOT/vendor/linkedspec/rgx/subs/pgen/rust/target" \
CARGO_NET_OFFLINE=false \
bash vendor/linkedspec/tools/project_data_run.sh \
  make -C vendor/linkedspec/rgx/subs/pgen/rust \
  SHELL=/bin/bash regex_parser_bootstrap
```

This command's target-directory override is deliberate: the pinned Makefile
expects its executable beneath PGEN's own `rust/target`. Normal application
builds continue to use `.app-data/target`. Both locations are on the application's
volume. Retain PGEN's generated directory and target products. The verified
bootstrap produces `ebnf.rs`, `regex_parser.rs`, `return_annotation_parser.rs`
and `semantic_annotation_parser.rs` under `rgx/subs/pgen/generated/`, relative to
LinkedSpec. Do not commit those generated products as dependency source changes.

Run this preparation when the files are absent or a reviewed pin/toolchain update
requires regeneration. Subsequent application builds use ordinary Cargo. An
offline package-resolution failure means the selected store is incomplete; it
does not justify silently using a home-directory cache. Prepare that same local
store online, retain the resulting locks, and then use locked offline builds.

Keep compatible generated sources and Cargo products across application builds.
A changed compiler, target, features, build flags, dependency source or generated
input can legitimately require new products. Cargo follows the dependency chain
`LinkedSpec → RGX → PGEN` and builds dependencies automatically when needed.
Keep the target directory between routine runs so Cargo can reuse compatible work.

### Current Cargo reuse limitation

The inspected PGEN build script watches optional files even when they do not
exist. Cargo can report missing `generated/json_parser.rs` and schedule dependency
compilation on an otherwise unchanged run. The normal Cargo command still builds
the required chain; no separate RGX or PGEN compilation command is needed.

This known performance issue is tracked by `SESSION-STARTUP-READING.80.1-.4`.
It does not prevent native API use. Do not create dummy parser files or change
Cargo fingerprints to suppress legitimate dependency checks. Build measurements
must distinguish actual reuse from compilation.

## Compile once, parse independent inputs

The common example collects ASCII words. It intentionally skips other text; it
is an extraction example, not a complete-input validator:

```text
{{#include ../../../../examples/integration/word.spec}}
```

`Top` repeatedly dispatches to `Word`; `Word` reads the capture that selected it.
The final value is the collected array. A selected root is entered directly, so
putting a regex on the root alone would not create this dispatch loop. See
[rule modes and cursor policy](../user-model/rule-modes-and-parse-modes.md).

The runnable consumer is `examples/integration/rust/src/main.rs`:

```rust
{{#include ../../../../examples/integration/rust/src/main.rs}}
```

Its own manifest points back to this checkout:

```toml
{{#include ../../../../examples/integration/rust/Cargo.toml}}
```

`load_and_compile_spec` performs native resolution, loading, parsing, validation
and compilation. `SpecLoadOptions::new` has no ambient search roots. The caller
supplies a grammar path and the current directory explicitly. The example rejects
non-UTF-8 arguments rather than replacing bytes in a file name.

One engine processes every command-line input independently. The direct-value
method returns `serde_json::Value`; printing it writes JSON. This avoids the
legacy execution method's accumulator wrapper. The application can inspect that
value and convert it to its own types. Add a direct `serde_json` dependency if
your own code names its types or deserializes a domain model.

From the LinkedSpec checkout root, run:

```sh
bash tools/run_cargo_local.sh run --offline --locked \
  --manifest-path examples/integration/rust/Cargo.toml -- \
  examples/integration/word.spec 'alpha' 'Beta' '123' '123 alpha rest'
```

The reference values for these four inputs are:

```json
["alpha"]
["Beta"]
[]
["alpha","rest"]
```

The empty array is a successful extraction with no words, not a thrown syntax
error. Your grammar and application must define rejection and complete-input
requirements. `SpecPipelineError` and `RuntimeExecutionError` carry structured
information; the small example prints their human-readable messages to stderr
and exits unsuccessfully. See [native loading](native-spec-loading.md) and
[diagnostics](../compiler/diagnostics.md) for the detailed contracts.

## Parse Lispish files in your application

The case-sensitive shipped path is **`specs/Lispish.spec`**. The example reads
each file as exact UTF-8 text, loads and compiles the grammar once, and executes
one independent input per file. It writes one JSON value per successful file.
Add the following direct dependencies to your application's manifest:

```toml
[dependencies]
linkedspec-runtime = { path = "vendor/linkedspec/rust/linkedspec-runtime" }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

For an existing Rust application, merge these entries into its dependency table.
For a new application, use a package manifest with edition 2024 and
`rust-version = "1.95"`. Copy the complete maintained binary source:

```sh
mkdir -p src/bin
cp vendor/linkedspec/examples/integration/rust/src/bin/lispish_file.rs src/bin/
bash vendor/linkedspec/tools/run_cargo_local.sh build \
  --manifest-path "$APP_ROOT/Cargo.toml" --bin lispish_file
```

Commit your application's source and resulting `Cargo.lock`. After the first
successful build, add `--locked --offline` to require exactly that retained graph.
The example application's lockfile is a tested reference; your application's
combined dependencies determine its own lockfile.

Create an input file using the checked-in sample:

```sh
cp vendor/linkedspec/examples/integration/rust/settings.sexp settings.sexp
bash vendor/linkedspec/tools/project_data_run.sh \
  "$CARGO_TARGET_DIR/debug/lispish_file" \
  --grammar "$APP_ROOT/vendor/linkedspec/specs/Lispish.spec" \
  "$APP_ROOT/settings.sexp"
```

The sample contains:

```text
{{#include ../../../../examples/integration/rust/settings.sexp}}
```

The application value is:

```json
["application",["name","ARCHOGEN"],["paths","src","output"],["enabled","true"]]
```

`true` is an atom string, not a Boolean. Convert it according to your own domain
schema. This example demonstrates integration; it does not implement ARCHOGEN's
configuration schema or evaluate Lisp expressions.

### Convert the native result into application values

The native API returns the historical head/tail representation. The adapter
below converts that representation into ordinary nested lists without changing
atom text:

| Input | Native `serde_json::Value` | Application value |
|---|---|---|
| `()` | `[null]` | `[]` |
| `(a)` | `["a",null]` | `["a"]` |
| `(a b c)` | `["a",["b","c"]]` | `["a","b","c"]` |
| `(a (b c) d)` | `["a",[["b",["c"]],"d"]]` | `["a",["b","c"],"d"]` |
| no parenthesized form | `null` | application error |

`SExpression` deliberately has only `Atom(String)` and `List(...)`: Lispish's
parent rules discard distinctions between symbols, quoted strings and numeric
tokens. The adapter rejects unexpected result shapes and more than 256 nested
lists. This is an adapter limit applied **after parsing**, not a parser resource
budget or a depth guarantee for arbitrary input.

Here is the complete consumer, including file I/O and error reporting:

```rust
{{#include ../../../../examples/integration/rust/src/bin/lispish_file.rs:consumer}}
```

### Exact grammar and file-consumption limits

The maintained verifier checks these outcomes directly on Rust. The
[Lispish walkthrough](../specs-and-corpora/lispish-spec-walkthrough.md) explains
the rules and historical output in more detail.

| File text | Application outcome |
|---|---|
| `prefix (a) suffix` | `["a"]`; surrounding text is ignored |
| `(a)(b)` or two forms on separate lines | `["a"]`; only the first form is returned |
| `(a))` | `["a"]`; trailing close is ignored |
| empty file, `atom`, or `(a b` | no form; application exits 1 |
| `) (a)` | native `exit_now(1)` error; application exits 1 |
| `("abc)` | `["abc"]`; an unterminated quote can be skipped |
| `([])` | `[]`; empty square brackets disappear |
| `(a ;comment)` | `["a","comment"]`; the comment rule requires a newline |

A semicolon comment **with** its terminating newline is skipped. Double-quoted
text loses its delimiters, but escapes retain their literal characters: `\n`
remains backslash plus `n`, and an escaped quote retains its backslash. Numeric
atoms remain strings. Single quotes are ordinary atom characters in the
parenthesis rule. Nonempty square-bracket content retains its brackets; brace
content loses its outer braces. Adjacent fragments can join into a single atom:
`(a" b"[c]{d})` produces `["a b[c]d"]`.

The adapter cannot recover skipped text, token kinds or consumed offsets. Reading
an entire file into a string is not proof that the grammar consumed it. Applications
requiring strict document validation or multiple top-level forms need an explicit
grammar/contract for those requirements. That work is tracked by
`SESSION-STARTUP-READING.83.1-.83.3`; it is not implemented by this example.

### Handle failures and diagnostics

The executable exits 1 on its first error. Grammar-pipeline errors are JSON on
stderr, including `type`, `stage`, `code` and source-request context. A missing
grammar has `type: "spec_pipeline_error"`, `stage: "resolve_spec_path"` and
`code: "spec_path_not_found"`. Native runtime failures serialize their `message`
and nested `diagnostic`. File I/O, invalid UTF-8 and adapter errors are readable
stderr messages; file and adapter errors identify the input path.

Successes before a later failing file have already been written to stdout.
Applications needing an all-or-nothing operation should validate and collect
their results before committing application state. This example demonstrates
independent-input reuse; it does not claim recovery on the same engine after a
runtime failure. Use `--` before a filename beginning with `--grammar`.

The example installs no diagnostic-output sink. DSL `print`/`say` output is
separate from returned values and is quiet without a sink. Applications that
need those events can use `execute_value_with_diagnostic_output` with a
`RuntimeDiagnosticOutputSink`; see [diagnostics](../compiler/diagnostics.md).

## Package and relocate the application

Without `--grammar`, the consumer resolves `specs/Lispish.spec` beside its own
executable at runtime. It does not embed the build checkout path. Package:

```text
application/
  lispish_file
  specs/
    Lispish.spec
```

From the application root, a development bundle can be assembled and run as:

```sh
mkdir -p .app-data/dist/specs
cp "$CARGO_TARGET_DIR/debug/lispish_file" .app-data/dist/
cp vendor/linkedspec/specs/Lispish.spec .app-data/dist/specs/
bash vendor/linkedspec/tools/project_data_run.sh \
  "$APP_ROOT/.app-data/dist/lispish_file" "$APP_ROOT/settings.sexp"
```

Move the complete bundle together. Input paths and an explicit `--grammar` path
are relative to the caller's working directory; the default packaged grammar
path is relative to the executable. This single grammar has no separately loaded
`.spec` dependencies. A different grammar may require additional packaged assets.

The native Rust runtime is linked into the executable; this deployment does not
ship a Perl process, LinkedSpec CLI or Cargo registry. Preserve the corresponding
source revision and applicable dependency licences for your release process.
The verified bundle uses a debug binary on macOS arm64. A production build can
select Cargo's `--release` profile and the corresponding `release/lispish_file`,
but release-profile, cross-platform and cross-target deployment need their own
verification. OS runtime libraries remain platform dependencies.

## Reproduce the integration checks

From LinkedSpec's root:

```sh
bash tools/run_cargo_local.sh test --offline --locked \
  --manifest-path examples/integration/rust/Cargo.toml
bash tools/run_cargo_local.sh build --bins --offline --locked \
  --manifest-path examples/integration/rust/Cargo.toml
bash tools/run_python_project_data.sh examples/integration/rust/verify_lispish.py \
  --binary rust/target/debug/lispish_file
```

The three Rust tests check published result shapes, rejected shapes and the
adapter depth boundary. The Python verifier checks 18 real file values in one
engine, file/argument/grammar/runtime failures, packaged assets, a different
working directory and a moved bundle with spaces in its path. Python is only a
verification dependency; the deployed application remains Rust.

Clean preparation was verified from committed LinkedSpec `42490a9d917e`,
RGX `8763a0e6bea9` and PGEN `db6f8c6836fe` sources, with this file consumer copied
into a separate application. All tracked source blobs were checked against Git;
the original checkout's local PGEN edits were excluded. Only the Rust dependency
closure was initialized. A byte-verified public registry copy seeded the local
store; initial PGEN package resolution then needed online metadata/downloads.
Bootstrap and the subsequent locked offline application build passed on macOS
arm64, Rust 1.95.0. This is clean-source preparation evidence, not an empty-cache
network installation or a test of the actual ARCHOGEN repository.
The separate application built in 40.50 seconds, then 4.87 seconds on a repeat;
both logs reported dependency compilation. The file/deployment verifier passed
against that application and the repository example. These measurements do not
promise zero dependency work or a portable build-time bound.
