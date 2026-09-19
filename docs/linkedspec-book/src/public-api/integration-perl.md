# Integrating LinkedSpec into a Perl application

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
  env PERL5LIB= PERL5OPT= PERL_UNICODE= \
  perl -I"$APP_ROOT/vendor/linkedspec/perl" "$APP_ROOT/bin/parse_words.pl" \
  "$APP_ROOT/specs/word.spec" alpha Beta 123 '123 alpha rest'
```

Ignore `.app-data/` in the application repository. The wrapper keeps temporary
work and runtime caches on the application's volume and removes its owned
successful run scratch. The interpreter and its standard libraries are required
read-only toolchain dependencies. This example writes results to stdout; if you
redirect them, select an application-owned output path.

The empty Perl environment overrides remove ambient module injection, startup
options and automatic Unicode stream settings for this invocation. The script
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

## Verify the checked-in example

From the LinkedSpec repository root:

```sh
bash tools/project_data_run.sh env PERL5LIB= PERL5OPT= PERL_UNICODE= \
  perl -Iperl examples/integration/perl/parse_words.pl \
  examples/integration/word.spec alpha Beta 123 '123 alpha rest'
bash tools/run_python_project_data.sh examples/integration/perl/verify_words.py
```

Python is used only by the example verifier. The application runs Perl directly.
The verifier uses `inspect_modules.pl` to check repository module origins, core
module identities and standard-library locations. It also checks independent/
repeated inputs, Unicode working-directory and grammar paths, missing arguments
and grammar, invalid UTF-8 arguments on POSIX, and cleanup of its own fixtures.
Native setup was also replayed using a clean
pinned LinkedSpec submodule, without initializing its nested dependencies.

This chapter currently verifies setup and the native word consumer. Deployment
packaging, runtime failures and optional diagnostic sinks are not yet covered.
