# Integrating LinkedSpec into a Perl application

See [Application Integration](integration.md) for backend selection, shared
checkout and storage principles, and the common example.

Use `LinkedSpec::SpecLoader` to load a grammar, compile it once and call the
resulting Perl parser directly. The example in this chapter collects ASCII
words from several independent inputs and prints one JSON value per input.

## Add and pin the source dependency

Run these commands from your application's repository root:

```sh
git submodule add https://github.com/rdje/linkedspec.git vendor/linkedspec
git -C vendor/linkedspec rev-parse HEAD
git add .gitmodules vendor/linkedspec
```

Review and commit the submodule revision with your application. When cloning an
application that already has this dependency, initialize its recorded revision:

```sh
git submodule update --init vendor/linkedspec
```

This Perl route needs the LinkedSpec checkout and a complete Perl installation.
It does not require initialization or compilation of the nested RGX/PGEN
projects. No Cargo, C compiler, CPAN installation or LinkedSpec build step was
needed for the example verified here.

To update deliberately, fetch the LinkedSpec repository, check out a reviewed
revision inside `vendor/linkedspec`, run your application's checks, and commit
the changed submodule pointer. Keep the complete `perl/` module tree. Some
language facilities also use grammars in the checkout's sibling `specs/`
directory; retaining the source checkout preserves that layout.

### Runtime and module prerequisites

Verification uses Perl **5.34.1 on macOS arm64**. The facade declares Perl 5.10,
but this example has not established a minimum supported version or a Windows
support matrix. Use a complete interpreter distribution, including its standard
modules and their matching native libraries.

The word consumer loads 66 repository-owned Perl modules plus 37 modules from
the tested interpreter's core distribution. The latter include `Encode`,
`JSON::PP`, `Cwd`, `File::Spec`, `Scalar::Util`, `Storable` and `Digest::SHA`.
The ten native libraries observed during this run are all supplied by that Perl
installation. No third-party CPAN module is loaded by this route.

This measured closure covers the word consumer. An application that explicitly
adds another package, plugin or service owns that additional dependency. The
portable loader does not call the legacy `get_parser` discovery path; neither
`PathSearch.pm` nor `PPlugin.pm` was loaded by the example.

## Assemble the consumer

From the application root, copy the maintained example and its grammar:

```sh
mkdir -p bin specs
cp vendor/linkedspec/examples/integration/perl/parse_words.pl bin/parse_words.pl
cp vendor/linkedspec/examples/integration/perl/parse-words bin/parse-words
cp vendor/linkedspec/examples/integration/word.spec specs/word.spec
```

The grammar deliberately extracts words and skips other text. It does not
validate the complete input:

```text
{{#include ../../../../examples/integration/word.spec}}
```

`Top` repeatedly dispatches to `Word`, whose capture becomes one array element.
At completion, the array is the direct return value. A grammar without this
collection action can return a different kind of Perl value.

The complete executable consumer is:

```perl
{{#include ../../../../examples/integration/perl/parse_words.pl}}
```

The application selects the library through Perl's `-I` option. Point it at
`vendor/linkedspec/perl`, which contains `LinkedSpec.pm` and its module tree.
Do not rely on the current directory, a developer's `PERL5LIB`, or a globally
installed copy of LinkedSpec.

## Run with application-owned storage

Derive absolute paths at launch time from the application root. Keep the
relative layout in your launcher rather than saving expanded machine paths:

```sh
APP_ROOT=$(pwd -P)
export LINKEDSPEC_PROJECT_DATA_ROOT="$APP_ROOT/.app-data/linkedspec"
export LINKEDSPEC_CACHE_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/cache"
export LINKEDSPEC_SCRATCH_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/scratch"
bash vendor/linkedspec/tools/project_data_run.sh \
  env PERL5LIB= PERL5OPT= PERL_UNICODE=0 \
  perl -I"$APP_ROOT/vendor/linkedspec/perl" "$APP_ROOT/bin/parse_words.pl" \
  "$APP_ROOT/specs/word.spec" alpha Beta 123 '123 alpha rest'
```

Ignore `.app-data/` in the application repository. The wrapper keeps temporary
work and runtime caches on the application's volume and removes its owned
successful run scratch. The interpreter and its standard libraries are required
read-only toolchain dependencies. This example writes results to stdout; if you
redirect them, select an application-owned output path.

The empty `PERL5LIB` and `PERL5OPT` overrides remove ambient module injection and
startup options. `PERL_UNICODE=0` disables automatic Unicode stream settings; an
empty value would enable them. The script also explicitly sets raw output streams. The script
decodes command-line arguments strictly as UTF-8 and emits UTF-8 JSON bytes.
Each `INPUT` argument is text to parse, rather than a file name.

Expected output:

```json
["alpha"]
["Beta"]
[]
["alpha","rest"]
```

Repeat the same command to start a new Perl process with the same pinned source.
No dependency compilation or installation is performed. Within each process,
`load_and_compile_spec` runs once and the parser is reused for all inputs.
The compiled parser is an in-memory coderef; this example does not persist a
compiled cache between processes.

## Use the native values in your application

`path_request` selects exactly the supplied grammar path. A relative path is
resolved against the explicit `cwd`; no search roots are supplied here.
`load_and_compile_spec` performs resolution, strict UTF-8 source loading and
compilation. Its result retains the loaded source, resolved identity, parser
coderef and runtime context.

Pass the parser a reference to a fresh input scalar for each independent parse.
The result is already the grammar's value: this example receives an array
reference such as `["alpha", "rest"]`, with no extra accumulator envelope.
Iterate `@$value` or adapt it into your application's own model before serializing.
The grammar intentionally recognizes ASCII letters only; `café` produces
`["caf"]`. An empty input or an input containing only digits produces `[]`.
Other grammars can return `undef`, scalars or nested containers; an undefined
value alone is not a universal parse-error test.

The example projects loader failures with `SpecLoader::Error->to_hash`. For a
missing grammar, stderr contains a JSON `spec_pipeline_error` record with stage
`resolve_spec_path` and code `spec_path_not_found`, and the process exits 1.
Argument/UTF-8 failures use the example's `consumer_error` record. The standard
loader's complete resolution and error contract is described in
[Native Spec Loading](native-spec-loading.md). The lower-level inline API remains
documented in [`Get(...)` and `get_parser(...)`](get-and-get-parser.md).

## Parse complete s-expression documents

Load `specs/SExprDocumentV1.spec` from your pinned checkout when every character
must belong to a valid document. Select `top_rule => 'Document'` in the loader's
compilation options. The word example explicitly selects `Top`, so adapting it
requires changing that option as well as the grammar path.

The parser returns a hash reference with `format => 'linkedspec-sexpr-v1'` and
an ordered `forms` array reference. Each list has `kind` and `items`; atoms have
`kind` and a string-valued `lexeme`, including original string quotes and escapes.
The [document grammar chapter](../specs-and-corpora/sexpr-document-v1.md) gives
the full schema, numeric classification and worked examples. Empty documents
succeed with no forms. Invalid documents throw `LinkedSpec::RuntimeExitNow`
with status 1 and return no accepted partial document; retain the exception and
context handling below.

From the LinkedSpec root, verify this grammar through the native Perl parser:

```sh
bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/sexpr_document_v1.t
```

This checks all 37 authored cases, token-spelling round trips and fresh independent
input after each rejection on the same compiled parser. That recovery evidence
is specific to this grammar; it does not promise rollback for arbitrary grammars
or application side effects. The word consumer's text-argument and deployment
contracts remain as documented below.

After preparing the repository integration example, replay this guide’s public-loader
path and exact `Top` → `Document` adaptation with:

```sh
bash tools/run_python_project_data.sh examples/integration/verify_sexpr.py --runtime perl
```

The verifier checks all 37 authored cases, earlier-output retention, the documented
relative grammar path, missing files and invalid UTF-8 grammar bytes. It preserves
the original examples and expectations. These are text-argument checks; the Rust
[file-consumer verifier](integration-rust.md#reproduce-the-integration-checks) separately
covers document-file bytes and relocated bundles.

## Verify the checked-in example

From the LinkedSpec repository root:

```sh
bash tools/project_data_run.sh env PERL5LIB= PERL5OPT= PERL_UNICODE=0 \
  perl -Iperl examples/integration/perl/parse_words.pl \
  examples/integration/word.spec alpha Beta 123 '123 alpha rest'
bash tools/run_python_project_data.sh examples/integration/perl/verify_words.py
bash tools/run_python_project_data.sh examples/integration/perl/verify_deployment.py
```

Python is used only by the example verifier. The application runs Perl directly.
The verifier uses `inspect_modules.pl` to check repository module origins, core
module identities and standard-library locations. It also checks independent/
repeated inputs, Unicode working-directory and grammar paths, missing arguments
and grammar, invalid UTF-8 arguments on POSIX, and cleanup of its own fixtures.
Native setup was also replayed using a clean
pinned LinkedSpec submodule, without initializing its nested dependencies.

The deployment verifier additionally exercises quiet and explicit diagnostics,
Unicode event bytes, typed exits and arity errors, invalid UTF-8 source,
undefined successful values, and a forced failure in the real generated handler.
It packages the runtime sources and launcher, moves the application to a Unicode
path, executes from outside that directory, checks source/grammar hashes and
same-volume storage, and removes its own test fixtures.

## Regex and division in action code

Regex patterns are supported operands of helpers such as `matches`, `split` and
`regex_subst`. They are not a separate builtin variable type. For example,
`return(matches("abc", /b/))` returns `1`; a reusable string pattern also works:
`pattern = "b"; return(matches("abc", pattern))`.

Do not treat `pattern = /b/` as construction of a regex object. Current Perl
lowers that standalone expression to a host match against implicit `$_`, storing
`1` or the empty string. That compatibility behavior is different from a helper
matching its explicit subject. See [regex patterns and variable values](../dsl/value-container-flow-helper-reference.md#regex-patterns-and-variable-values).

A known Perl validation failure affects multiline patterns even in documented
helper positions. This action lowers correctly and independently evaluates to
`1`, but placing it before another rule can cause whole-spec validation to
report that the next rule is inside an open block:

```text
return(matches(cat("x", "\n", "y"), /(x)
y/))
```

That validator defect is tracked under `SESSION-STARTUP-READING.86.4.3`.
It does not require adding regex-valued variables or choosing a new global slash
precedence. Check both failure channels described below; a returned parser alone
does not establish successful compilation and execution.

For arithmetic division, `div(14, 2)` works at the end of an action block.
The equivalent slash call `/(14, 2)` currently requires a trailing semicolon in
that position; its separate repair is tracked under `.86.5`. Newline-separated
division followed by another assignment already works. Prefer `div(...)` when
slash syntax would obscure the arithmetic intent.

## Handle runtime outcomes explicitly

The parser has two failure channels. Catch exceptions with `eval` and immediately
save `$@`. Also inspect `$loaded->runtime_ctx->{last_error}`: a generated rule
handler can record a structured failure and return `undef` without throwing to
the outer caller. Check the context before treating the value as a success.
Conversely, a grammar that explicitly returns `undef` without an error is a
successful undefined value; the example writes JSON `null`.

The standalone JSON adapter also selects `trace_level => -1` and an empty
`route` destination, and clears inherited native trace settings within its work.
Native level-zero tracing can otherwise print failure records on stdout; it is
separate from the grammar's `diagnostic_sink` events. These trace controls affect
the Perl process's shared trace configuration. An embedded application with
multiple parsers should choose its own process-wide trace policy instead of
silently overriding another component's settings.

The application example serializes a selected view of error fields:

| Outcome | Example stderr record | Process exit |
| --- | --- | --- |
| Missing grammar | `spec_pipeline_error`, stage `resolve_spec_path`, code `spec_path_not_found` | 1 |
| Invalid UTF-8 grammar bytes | `spec_pipeline_error`, stage `decode_spec_content`, code `invalid_utf8` | 1 |
| Recorded handler/parser error | `runtime_error` with a `context` object | 1 |
| `exit_now(7)` | `runtime_exit_now` with `status: 7` and `rule_label` | 1 |
| Diagnostic helper arity failure | `runtime_diagnostic_output_error` with its code and helper fields | 1 |
| Bad arguments or another host exception | `consumer_error` with class and detail | 1 |

These JSON envelopes belong to the example. Native applications receive the
original Perl values and exception objects. In particular, `exit_now` throws a
`LinkedSpec::RuntimeExitNow` object; it does not terminate your process. The host
chooses its own process exit policy. The example consistently exits 1 on failure
and reports the grammar's requested status separately.

Runtime context details can retain typed objects. Preserve those objects in a
native application; when exporting JSON, choose the fields your application
needs. Generic blessed-object conversion can otherwise erase useful details.
The example projects referenced context fields as class plus string detail.

The consumer stops on its first failure. Earlier result lines and events remain
emitted; later inputs are not attempted. This is not a transaction or a promise
that a failed parser can safely continue with its prior state. Create a new
compiled parser when your application needs to recover; design application
side effects and retry policy separately.

The word grammar is an extractor. Digits, punctuation and incomplete language-like
text do not necessarily fail: only its ASCII words are collected. A strict
configuration parser needs a grammar and checks that enforce its complete-input
contract.

## Capture diagnostics only when requested

The parser's optional second argument accepts a `diagnostic_sink` callback:

```perl
my @events;
my $input = 'x';
my $value = $parser->(\$input, {
    diagnostic_sink => sub { push @events, {%{$_[0]}} },
});
```

Each callback receives a blessed `LinkedSpec::RuntimeDiagnosticOutputEvent` hash
with `helper_name`, `rule_label` and `message`. `say` appends a newline; `print`
does not. Delivery is synchronous. Without a sink, the diagnostic helpers write
nothing to host stdout or stderr, though their arguments still evaluate.
If your callback throws, its exception escapes unchanged and later delivery
stops; handle that host exception as well as runtime context errors.

Copy the demonstration grammars into your application's assets:

```sh
cp vendor/linkedspec/examples/integration/perl/diagnostics.spec specs/diagnostics.spec
cp vendor/linkedspec/examples/integration/perl/exit.spec specs/exit.spec
bash bin/parse-words --diagnostics specs/diagnostics.spec x
```

The diagnostic grammar is:

```text
{{#include ../../../../examples/integration/perl/diagnostics.spec}}
```

Stdout contains `"ok"`. Stderr contains two UTF-8 JSON lines:

```json
{"event":{"helper_name":"say","message":"héllo 雪\n","rule_label":"Top"},"type":"diagnostic"}
{"event":{"helper_name":"print","message":"done","rule_label":"Top"},"type":"diagnostic"}
```

Omit `--diagnostics` to keep stderr empty on this successful parse. An optional
`--` ends option processing if the grammar path itself is `--diagnostics`.

The exit example makes the failure boundary visible:

```sh
bash bin/parse-words --diagnostics specs/exit.spec x y x
```

It emits one `"ok"` result for the first input. The second input emits the
`before\n` event followed by `{"rule_label":"Top","status":7,"type":"runtime_exit_now"}`,
and the process exits 1. The third input is never parsed.

## Package and relocate the application

Install the maintained launcher alongside `bin/parse_words.pl`:

```sh
{{#include ../../../../examples/integration/perl/parse-words}}
```

It derives the application root from its own location, selects the bundled Perl
modules, and places managed data under that root's `.app-data/`. It preserves the
caller's working directory: relative grammar arguments remain relative to the
caller. Invoke it with `bash`; executable permission is not required.

A source deployment needs the complete `vendor/linkedspec/perl/` tree and its
sibling `specs/`. This launcher also needs `vendor/linkedspec/tools/` for the
managed storage wrapper. Retain the checkout's license and notices. Keep your
application's `bin/` and `specs/` assets together with that layout. Git metadata,
RGX/PGEN and Rust build products are not required for this Perl consumer. The
full pinned source checkout is also a valid deployment; no CPAN installation or
LinkedSpec compilation is needed by the verified word/diagnostic route.

For example, after placing that layout at `release/my-app`, invoke it from the
application repository root:

```sh
APP_ROOT=$(cd release/my-app && pwd -P)
bash "$APP_ROOT/bin/parse-words" "$APP_ROOT/specs/word.spec" 'one two'
```

This returns `["one","two"]` regardless of the caller's directory. Moving the
whole bundle preserves the relative module and asset relationships. The launcher
recomputes storage paths at each invocation. Keep reusable data on the same
volume as the application, and make the selected `.app-data/` location writable;
the wrapper also maintains a small checkout identity under the bundled library's
`.linkedspec-data/` directory. This example does not target a read-only bundle.

The host must still provide the compatible Perl distribution, its core native
libraries, Bash and the platform utilities used by the storage wrapper. The
verified deployment is macOS arm64 with Perl 5.34.1. A successful relocation on
that host does not establish another operating system or interpreter version.
This guide uses live compilation; it does not package a standalone emitted parser.
