# Integrating LinkedSpec into a Rust application

See [Application Integration](integration.md) for backend selection, shared
checkout and storage principles, and the common example.

Use the `linkedspec-runtime` crate to load a `.spec`, compile it once and parse
inputs inside your Rust process. Cargo brings `linkedspec-core` and the RGX regex
engine through path dependencies. There is no Perl parser process in this route.

This chapter covers a pinned source checkout, initial dependency preparation,
native API use, real UTF-8 files, application values and deployment. The runnable
examples live in `examples/integration/rust/`. Use the
[document-file example](#read-document-files-in-your-application) for complete
documents and token kinds, as required by ARCHOGEN and SEMULITH. The historical
Lispish file example remains available for its original extraction contract.

**Lispish scope:** the shipped grammar extracts the first parenthesized form.
It can skip malformed or extra text. A successful value does **not** establish
that the complete file is valid. Read the concrete limits below before choosing
it as your application's file format.

## Add and pin the source dependency

From your application's repository root:

```sh
git submodule add https://github.com/rdje/linkedspec.git vendor/linkedspec
git -C vendor/linkedspec submodule update --init rgx
git -C vendor/linkedspec rev-parse HEAD
git add .gitmodules vendor/linkedspec
```

**Before running Cargo metadata or building:** complete
[workspace setup](#applications-with-a-cargo-workspace), when applicable,
[application-local storage](#keep-preparation-and-build-products-local), and
[RGX preparation](#initial-rgx-preparation). The checkout commands above obtain
source; the preparation section is a required part of this setup sequence.

Review the revision and commit the submodule pointer with your application. For
an existing application clone, first run `git submodule update --init
vendor/linkedspec`, then initialize RGX with the command above. RGX owns preparation
of its transitive dependencies through its published bootstrap command.
`git submodule update --init --recursive` also works,
but retrieves additional optional dependency/test repositories which this native
Rust example does not require directly. Checkout alone does not complete RGX's
documented preparation.

Recursive checkout can also consume substantially more disk space. One downstream
report (SEMULITH, reviewed 2026-09-20) measured about **1.7 GB across 30 submodules**.
That is a dated observation of one recursive checkout, not a fixed size or a
measurement of the targeted commands above. Initialize LinkedSpec and its direct
RGX submodule as shown, then let RGX's published bootstrap own its transitive
requirements. Do not replace that public command with a manual dependency recipe.

To update deliberately, fetch LinkedSpec, check out the reviewed revision inside
`vendor/linkedspec`, initialize its pinned RGX checkout again, follow that revision's
published preparation contract, then verify your application before committing the
changed pointer. Keep local nested changes out
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

### Applications with a Cargo workspace

Before running RGX bootstrap or building, add `vendor/linkedspec` to `exclude` in the
**application workspace root** manifest. Merge it with existing members and
exclusions; do not add a second `[workspace]` table. For example:

```toml
[workspace]
resolver = "2"
members = ["app", "support"]
exclude = ["vendor/linkedspec"]
```

The exclusion path is relative to this workspace root. Adjust it if the submodule
lives elsewhere. It keeps the vendored packages out of the application's workspace;
the application still uses `linkedspec-runtime` as a normal path dependency.
In this layout, `app/Cargo.toml` would contain:

```toml
[dependencies]
linkedspec-runtime = { path = "../vendor/linkedspec/rust/linkedspec-runtime" }
```

LinkedSpec's native Rust library and runnable example each have their own
workspace. The host exclusion also keeps vendored dependencies outside the
application's workspace. Without it, a dependency build can stop with “current
package believes it's in a workspace when it's not”. Follow the public workspace
setup; do not modify dependency manifests or add vendored crates to the application's
workspace members to work around this error.
An application with no enclosing `[workspace]` does not need this exclusion.
See [Cargo workspace membership](https://doc.rust-lang.org/cargo/reference/workspaces.html#the-members-and-exclude-fields)
for Cargo's parent-manifest discovery and exclusion rules.

RGX's published integration contract requires Rust **1.95**. The checked-in
example therefore declares `rust-version = "1.95"` and edition 2024. Recheck the
chosen revision's published requirements when updating. Verification currently uses Rust
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
It changes to the LinkedSpec root, so pass the application's manifest explicitly
in Cargo commands after preparation.

Initial package resolution may need network access. After preparing and locking
the graph, add `--offline --locked` to require the retained package store and
lockfile. Copying only a target directory is insufficient: source packages and
the exact nested checkout are also required.

### Initial RGX preparation

Use RGX's published downstream build interface. Its integration contract is
`rgx/docs/INTEGRATION.md` inside LinkedSpec, also available in the
[pinned RGX integration guide](https://github.com/rdje/rgx/blob/8763a0e6bea97879f027237439d57725f83ead23/docs/INTEGRATION.md).
RGX owns preparation of its dependencies. Applications should not reproduce
PGEN's internal generation steps or modify either submodule.

After configuring the workspace and local storage above, run from the application
root, with Rust, Cargo, a native toolchain, Bash and Make available:

```sh
CARGO_NET_OFFLINE=false \
bash vendor/linkedspec/tools/project_data_run.sh \
  env -u CARGO_TARGET_DIR make -C "$APP_ROOT/vendor/linkedspec/rgx" bootstrap
```

The existing runner retains the selected local Cargo package store and temporary
storage. `env -u CARGO_TARGET_DIR` lets the dependency's documented build use its
default target locations for this child process. The application's exported
`CARGO_TARGET_DIR` is unchanged. Keep the checkout and its build products on the
application's volume and retain compatible outputs for subsequent builds.

Initial package resolution may need network access. With the required package
store already populated, use `CARGO_NET_OFFLINE=true`. If the command fails,
stop before building the application and preserve its exit status and full log.
An intermediate progress message is not the overall command result. Report a
failure against RGX's published interface with the exact dependency revision;
do not repair it by editing submodule code or inventing another bootstrap recipe.
ARCHOGEN's reported misleading bootstrap progress message remains upstream-owned.

After successful preparation, confirm the application graph with its explicit
manifest:

```sh
bash vendor/linkedspec/tools/run_cargo_local.sh metadata \
  --format-version 1 --manifest-path "$APP_ROOT/Cargo.toml"
```

Then build the application through the ordinary Cargo commands below. RGX
documents bootstrap as reusable when already prepared.
Normal Cargo builds may still compile dependencies; retain caches and measure
actual results rather than promising zero compilation. A dependency update must
be checked against that release's published integration contract.

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

Rust rejects compilation when parsing lifecycle, action-edge or blind-call code
reports an error.
For a rule named `Top`, `I { return(@invalid) }` produces a compile error
attributed to that rule and its `I -block`; the invalid block is never dropped to continue
execution. Valid code and omitted optional edge code retain their behavior.
The low-level `linkedspec_core::compiler::compile` API returns
`LinkedSpecError::Compile` with the parser detail. The primary command exits 1
with `linkedspec: parser compilation failed`. With `--trace low`, it reports
`compile:start` then `compile:error`, before input loading or invocation.

Malformed action text containing multibyte characters follows the same failure
path. For example, `return(@éééééééééééééééééééé)` rejects compilation without
panicking while formatting the error. The `near:` excerpt contains complete
UTF-8 characters within its 40-byte limit. Its plain-text `position` retains the
byte offset within the parsed action text; structured ActionIR source spans
continue to use Unicode scalar offsets. Valid Unicode text is preserved exactly.

The file loader preserves this failure as `compile_spec` / `spec_compile_failed`,
including the requested and resolved path plus compiler detail. Reconstructing a
serialized source AST or enabling compilation tracing preserves rejection.
A semantic snapshot of that source records failed compilation and exposes no
compiled authority or generated plan.

Rust source emitters take an already compiled specification. They cannot restore
rule code discarded by an older compiler. Regenerate affected compiled JSON and
generated modules from their original `.spec` source with the corrected compiler.
Valid compiled JSON still reconstructs and executes normally; generated modules
retain their direct-value and compatibility entry points.

The empty argument list in `tree.map_leaves!() { add(value, 1) }` may contain
spaces, tabs or newlines: `tree.map_leaves!( ) { add(value, 1) }` has the same
meaning. The typed mutation node preserves its supplied call text and Unicode
scalar spans through compilation, source-AST reconstruction, compiled JSON and
generated execution.
The outer `.spec` parser retains internal LF/CRLF line endings, blank lines and
indentation in action blocks. It trims only whitespace surrounding the complete
block interior; action coordinates refer to that trimmed interior. Nonempty arguments such as
`map_leaves!(1)` remain invalid. See the
[mutation examples](../dsl/values-containers-and-flow-helpers.md#mutating-leaves-on-all-five-backends)
for receiver initialization, callback values and commit behavior.

Compact blocks on a rule header preserve quoted whitespace too. For example,
`Top:: E{return("a  b")} /x/` returns the string with both spaces, just as it does
when the `E` block starts on the following line. Tabs inside quoted values remain
tabs. This does not add multiline string literals to `.spec` action blocks.

When one multiline block starts on another block's closing line, its following
statements are retained too. With input `x`, this specification returns `4`:

```text
Top::
 I { note = 0;
     note = 1 } E { note = 3;
     note = 4;
     return(note) } /x/
```

Rebuild affected source ASTs, compiled JSON and generated modules from the original
`.spec` files. Later stages cannot recover whitespace or statements that an older
outer parser already removed.

Within an action block, a regex literal can precede another statement on the
next line. LF and CRLF both separate the statements. This example returns `7`
with input `x`:

```text
Top::
 -> Done { rx = /x/
           out = 7;
           return(out) }
Done:
 /x/
```

Compatibility suffix letters must touch the closing slash: `/x/i` is accepted,
whereas `/x/ i` does not attach a suffix and is invalid without a statement
separator. The action-expression carrier keeps the regex pattern only; accepting
these suffix letters does not give them matching semantics. Use an inline flag
such as `/(?i)x/` when the pattern needs one.

Arithmetic slash calls currently need a semicolon before a following statement:
`out = /(14, 2); note = 1`. The word form `div(14, 2)` also works before a newline.
A slash call followed directly by a newline and another identifier is a known
Rust parsing limitation; it is separate from regex-literal statement separation.

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

## Parse complete s-expression documents

Select `specs/SExprDocumentV1.spec` for complete input validation, all top-level
forms and preserved token kinds. It uses the same public loader and native
engine as the word consumer above. `ExecutionOptions::new()` selects the grammar's
default `Document` rule. The direct `serde_json::Value` is an object with
`format: "linkedspec-sexpr-v1"` and an ordered `forms` array; atoms preserve
`kind` and a string `lexeme`, including original string quotes and escapes.
See the [document grammar chapter](../specs-and-corpora/sexpr-document-v1.md)
for the schema, lexical rules and worked examples.

After preparation, the generic text consumer can run it from the LinkedSpec root:

```sh
bash tools/run_cargo_local.sh run --offline --locked \
  --manifest-path examples/integration/rust/Cargo.toml -- \
  specs/SExprDocumentV1.spec '(v 1 "1")(done)'
```

The result is the two-form tagged document shown in that chapter. Empty input
succeeds with no forms; malformed input fails without an accepted partial
document. For callers that need the typed status, use
`execute_value_with_diagnostic_output`: rejection is
`RuntimeDiagnosticOutputExecutionError::Exit` with status 1. The generic example
prints its runtime failure to stderr and exits unsuccessfully.

The native contract test checks all 37 authored cases, token-spelling round trips
and fresh independent input after every rejection through one compiled engine:

```sh
bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline \
  -p linkedspec-runtime --test sexpr_document_v1
```

That recovery proof is specific to this grammar and does not promise rollback of
application effects. The separate `sexpr_file` example below handles real files.
The historical `lispish_file` adapter expects head/tail values and cannot consume
the tagged document merely by changing `--grammar`.

### Read document files in your application

First complete [source checkout](#add-and-pin-the-source-dependency),
[workspace setup](#applications-with-a-cargo-workspace), when applicable,
[application-local storage](#keep-preparation-and-build-products-local), and
[RGX preparation](#initial-rgx-preparation). These commands run from the
application root with the `APP_ROOT` and `CARGO_TARGET_DIR` defined there.

Add `serde_json = "1"` alongside the `linkedspec-runtime` path dependency in your
application's existing dependency table. The new consumer needs no direct `serde`
dependency. Copy and build its complete source:

```sh
mkdir -p src/bin
cp vendor/linkedspec/examples/integration/rust/src/bin/sexpr_file.rs src/bin/
bash vendor/linkedspec/tools/run_cargo_local.sh build \
  --manifest-path "$APP_ROOT/Cargo.toml" --bin sexpr_file
```

Commit the application source and resulting `Cargo.lock`. Subsequent builds can
use `--locked --offline` with the retained package store. Create a two-form file:

```sh
cat > document.sexp <<'SEXP'
(v 1 "1")
(done)
SEXP
bash vendor/linkedspec/tools/project_data_run.sh \
  "$CARGO_TARGET_DIR/debug/sexpr_file" \
  --grammar "$APP_ROOT/vendor/linkedspec/specs/SExprDocumentV1.spec" \
  "$APP_ROOT/document.sexp"
```

Stdout is one JSON line containing the exact two-form document shown in the
[grammar chapter](../specs-and-corpora/sexpr-document-v1.md#read-a-document).
The first form's items have kinds `symbol`, `number`, `string`, with lexemes
`v`, `1`, and `"1"` respectively; the quotes belong to the string lexeme.
The second form is retained. No number conversion or escape decoding occurs.

Pass several file paths to reuse one compiled engine. The consumer reads each
file as exact UTF-8, selects `Document` explicitly, and writes the grammar's
direct `serde_json::Value`. It does not use the historical adapter or add that
adapter's 256-list depth limit. An empty file returns
`{"format":"linkedspec-sexpr-v1","forms":[]}`. Grammar assets and application
schemas remain separate: a number token's spelling does not establish its
application range or meaning.

Here is the complete native consumer:

```rust
{{#include ../../../../examples/integration/rust/src/bin/sexpr_file.rs:consumer}}
```

### Handle document-file failures

The consumer exits 1 at its first error. Malformed document input emits no value
for that file. Earlier successful files have already produced their JSON lines;
later files are not attempted. Collect and validate the whole batch before
committing application state if your application requires batch atomicity.

For malformed text passed as `broken.sexp`, stderr contains:

```json
{"type":"document_parse_error","input":"broken.sexp","cause":{"type":"runtime_exit_now","status":1}}
```

The input field preserves the supplied path. This envelope belongs to the
example. Its underlying error retains the native
`RuntimeDiagnosticOutputExecutionError`, including typed `Exit`; ordinary runtime
failures retain their structured diagnostic in `cause`. The host chooses process
exit 1; the library does not terminate the application.

Grammar-loading failures retain the standard `spec_pipeline_error` JSON fields.
Invalid UTF-8 grammar bytes report `decode_spec_content` / `invalid_utf8`;
malformed action code reports `compile_spec` / `spec_compile_failed` before any
input file is loaded. Input I/O and invalid-UTF-8 errors are readable stderr
messages naming the file. Invalid-UTF-8 arguments are rejected, rather than
silently rewritten. Use `--` before an input file named `--grammar`.

An explicit `--grammar` selects another location of the document grammar; it
does not convert another grammar's result into the versioned format. In
particular, Lispish has no `Document` entry and fails this consumer's explicit
selection. The example installs no diagnostic-output sink, so DSL diagnostic
helpers remain separate from its JSON value stream.

### Bundle the document consumer

Without `--grammar`, the default is `specs/SExprDocumentV1.spec` beside the running
executable. Assemble the two-file bundle from the application root:

```sh
mkdir -p .app-data/document-dist/specs
cp "$CARGO_TARGET_DIR/debug/sexpr_file" .app-data/document-dist/
cp vendor/linkedspec/specs/SExprDocumentV1.spec .app-data/document-dist/specs/
bash vendor/linkedspec/tools/project_data_run.sh \
  "$APP_ROOT/.app-data/document-dist/sexpr_file" "$APP_ROOT/document.sexp"
```

Move the complete bundle together. The default asset path is derived at runtime
from the executable; input paths and explicit grammar paths belong to the
caller's working directory. A missing bundled grammar fails even if the caller's
directory contains another copy. The retained binary needs no Perl process,
LinkedSpec CLI, Python verifier or Cargo registry to parse files. Platform runtime
libraries still apply. Verification covers a debug binary on macOS arm64,
including a moved Unicode path and an unrelated working directory; release
profiles and other deployment targets require their own checks.

After preparing the repository integration example, replay this guide’s public-loader
path and default entry selection with:

```sh
bash tools/run_python_project_data.sh examples/integration/verify_sexpr.py --runtime rust
```

The verifier checks all 37 authored cases, earlier-output retention, the documented
relative grammar path, missing files and invalid UTF-8 grammar bytes. It preserves
the original examples and expectations. These are text-argument checks; the Rust
[file-consumer verifier](integration-rust.md#reproduce-the-integration-checks) separately
covers document-file bytes and relocated bundles.

## Parse Lispish files in your application

If you arrived directly at this section, first complete
[source checkout](#add-and-pin-the-source-dependency),
[workspace setup](#applications-with-a-cargo-workspace), when applicable,
[application-local storage](#keep-preparation-and-build-products-local), and
[RGX preparation](#initial-rgx-preparation). The commands below use the `APP_ROOT`
and `CARGO_TARGET_DIR` set there and assume preparation succeeded.

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
requiring strict document validation or multiple top-level forms should select
[`SExprDocumentV1.spec`](#parse-complete-s-expression-documents) and its tagged
document contract. The historical file example does not implement that contract.

SEMULITH/LS-001's multiline-string corruption is fixed by enabling newline
matching in both quote readers. Actual LF, indentation and embedded parentheses
stay inside the string, and following sibling forms retain their structure:

```text
(r (a "p
   q) r") (b "z"))
```

The file consumer returns `["r",["a","p\n   q) r"],["b","z"]]`, where JSON's
`\n` represents the actual LF. The eight report cases are included in the file
verifier. The [Lispish walkthrough](../specs-and-corpora/lispish-spec-walkthrough.md#multiline-quoted-text)
explains exact newline, escape and quote behavior. The separate document grammar
passes the authored ARCHOGEN complete-input and SEMULITH kind cases on all six
runtimes. The separate document-file consumer passes the same cases as files;
independent public-loader integration replay also passes all 37 cases on each
of the six runtime routes. Downstream application acceptance is separate.
Both consumers also reported setup difficulties inside an enclosing Cargo
workspace. The [workspace setup above](#applications-with-a-cargo-workspace)
addresses the reproduced membership failures without changing dependency pins.
Prerequisite navigation was corrected under integration .8.4. The public RGX
bootstrap progress-message report remains owned by `RGX-CONSUMER-BUILD-REPORTS.1`.
These setup repairs do not change Lispish's input-consumption or token-kind behavior.

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
bash tools/run_python_project_data.sh examples/integration/rust/verify_workspace.py
bash tools/run_cargo_local.sh test --offline --locked \
  --manifest-path examples/integration/rust/Cargo.toml
bash tools/run_cargo_local.sh build --bins --offline --locked \
  --manifest-path examples/integration/rust/Cargo.toml
bash tools/run_python_project_data.sh examples/integration/rust/verify_lispish.py \
  --binary rust/target/debug/lispish_file
bash tools/run_python_project_data.sh examples/integration/rust/verify_sexpr.py \
  --binary rust/target/debug/sexpr_file
```

The workspace verifier checks only LinkedSpec and application manifests. It
archives LinkedSpec-owned source, links the prepared RGX checkout as an opaque
dependency, and uses locked offline Cargo metadata. Its nine checks include a
missing LinkedSpec workspace boundary that must fail, followed by the application
exclusion that must succeed. It neither probes transitive manifests nor replaces
RGX's documented bootstrap and the native build checks.

The three Rust tests check published result shapes, rejected shapes and the
adapter depth boundary. The Lispish verifier checks 26 real file values in one
engine, file/argument/grammar/runtime failures, packaged assets, a different
working directory and a moved bundle with spaces in its path. Python is only a
verification dependency; the deployed application remains Rust.

The document-file verifier independently consumes the 37 authored cases: 21 valid
files in one engine and 16 rejected documents with typed causes and no partial
value. It also checks the published file example, earlier-output retention,
strict UTF-8 input/grammar/arguments, source-compilation failure, paths, option
termination, and default/explicit assets. All valid cases repeat after bundle
relocation. Binary, grammar and contract hashes remain unchanged, and owned
temporary fixtures are removed. The historical adapter fails this document
verifier as expected; its separate Lispish checks continue to pass.

The workspace verifier uses committed native source and dependency pins, with
the current example manifest, in an isolated local fixture. Nine Cargo metadata
checks cover standalone use, enclosing-workspace boundaries and the required
host exclusion for vendored dependency builds. It performs no dependency build and does not copy local
dependency edits. This verifier needs Python 3.12 or later for filtered archive
extraction. The native checks above verify execution separately.

The current documented RGX command was independently exercised on Git-archived
LinkedSpec `effe3e7b2` and its unchanged dependency pins, without source overlays.
The clean preparation completed offline in 56.19 seconds using a byte-verified
local registry copy and retained lockfiles; a repeat completed in 0.22 seconds.
The two-member consumer built locked/offline in 26.65 seconds, returned the exact
word values outside its source directory and passed all 18 Lispish file/deployment
groups. The example's three adapter tests also passed. This verifies the published
build route on macOS arm64/Rust 1.95.0; it does not establish an empty-cache network,
release-profile, cross-platform or actual ARCHOGEN/SEMULITH application result.
