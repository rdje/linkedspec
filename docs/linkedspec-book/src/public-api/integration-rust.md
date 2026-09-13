# Integrating LinkedSpec into a Rust application

Use the `linkedspec-runtime` crate to load a `.spec`, compile it once and parse
inputs inside your Rust process. Cargo brings `linkedspec-core` and the RGX regex
engine through path dependencies. There is no Perl parser process in this route.

**Verified scope:** on macOS arm64 with Rust 1.95.0, the locked consumer resolved
200 packages from project-local sources and passed two runs with the four values
below. Four argument-error checks also passed. Both Cargo commands rebuilt the
dependency chain. This is prepared-checkout proof; fresh-checkout preparation,
Lispish adaptation and deployment checks remain separate integration work.

## Add and pin the source dependency

From your application's repository root:

```sh
git submodule add https://github.com/rdje/linkedspec.git vendor/linkedspec
git -C vendor/linkedspec submodule update --init --recursive
git -C vendor/linkedspec rev-parse HEAD
git add .gitmodules vendor/linkedspec
```

Review the revision and commit the submodule pointer with your application. An
existing clone uses `git submodule update --init --recursive` from its own root.
This retrieves the pinned nested RGX/PGEN sources; it does not prepare every
backend or guarantee that generated parser inputs exist.

To update deliberately, fetch LinkedSpec, check out the reviewed revision inside
`vendor/linkedspec`, initialize its recursive dependencies again, then verify your
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

Fresh PGEN checkouts do not ship the generated EBNF and regex Rust sources. The
RGX setup authority describes this bootstrap target, run from its checkout:

```sh
# Required only when preparing missing/incompatible generated parser inputs.
source vendor/linkedspec/tools/project_data_env.sh
bash vendor/linkedspec/tools/project_data_run.sh \
  make -C vendor/linkedspec/rgx/subs/pgen/rust \
  SHELL=/bin/bash regex_parser_bootstrap
```

The required outputs are `rgx/subs/pgen/generated/ebnf.rs` and
`rgx/subs/pgen/generated/regex_parser.rs`, relative to LinkedSpec. This is an
initial-preparation recipe from the dependency's documentation, **not a newly
verified clean-clone bootstrap**. It was unnecessary in the prepared checkout
used for this guide. Consult the pinned RGX/PGEN instructions when either source
is absent or incompatible; do not generate unrelated language parsers merely
because their optional paths appear in a build log.

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

The remaining Rust integration slice supplies ARCHOGEN's Lispish adaptation,
packaged-grammar/outside-cwd checks and worked failure handling. The
[Lispish walkthrough](../specs-and-corpora/lispish-spec-walkthrough.md) already
explains the historical head/tail representation; it is not a flat s-expression
AST or a promise that arbitrary Lisp syntax is accepted.
