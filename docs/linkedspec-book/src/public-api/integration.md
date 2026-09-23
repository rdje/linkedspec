# Integrating LinkedSpec into an application

Embed the backend that matches your application language. Each guide below starts
with a pinned Git submodule and ends with native parser values, error handling,
and a deployable application. Parsing runs inside your process; you do not need
to invoke the LinkedSpec command-line interface.

## Choose your backend guide

| Application | Native dependency | Preparation and deployment guide |
| --- | --- | --- |
| Perl | Repository modules through `@INC` | [Perl integration](integration-perl.md): module provenance, native values, diagnostics and a relocatable source launcher. |
| Rust | Cargo path dependency on `rust/linkedspec-runtime` | [Rust integration](integration-rust.md): workspace setup, RGX public preparation, native builds, complete document files, historical Lispish and binary/grammar packaging. |
| Dart | Local `linkedspec_dart` package at `dart/` | [Dart integration](integration-dart.md): package resolution, supporting grammar assets, native values and an AOT application bundle. |
| Julia | Local `LinkedSpecJulia` package at `julia/` | [Julia integration](integration-julia.md): application project/depot, offline reuse, native values and source deployment. |
| Lua or LuaJIT | Repository Lua modules and matching native modules | [Lua integration](integration-lua.md): explicit module paths, per-runtime native preparation, retained products and source/native packaging. |

For complete s-expression documents on any backend, select
[`SExprDocumentV1.spec`](../specs-and-corpora/sexpr-document-v1.md). It returns all
top-level lists and preserves symbol, number and string kinds with exact token
spelling. Each backend guide's **Parse complete s-expression documents** section
explains entry-rule selection, native results, failure handling and its focused
contract check and public-loader replay. Follow that backend's setup prerequisites first.

The Rust [Lispish file example](integration-rust.md#parse-lispish-files-in-your-application)
retains its historical first-form/head-tail contract and documented
[limits](integration-rust.md#exact-grammar-and-file-consumption-limits). Use the separate
[Rust document-file consumer](integration-rust.md#read-document-files-in-your-application)
for the new format; changing only the old adapter's grammar path does not convert
its result representation.

The guides are the current owners of host-specific setup and deployment. The
[native loading contract](native-spec-loading.md),
[runtime value semantics](../appendix/runtime-semantics.md), and
[diagnostic contract](../compiler/diagnostics.md) remain the shared semantic
references. Future backend companion books will route these topics without
creating competing copies of those contracts.

## Pin the source and prepare only your backend

From the application repository root, add LinkedSpec at a deliberate location:

```sh
git submodule add https://github.com/rdje/linkedspec.git vendor/linkedspec
git -C vendor/linkedspec rev-parse HEAD
```

Commit `.gitmodules` and the `vendor/linkedspec` Git entry in your application.
That entry records the exact LinkedSpec revision. An existing application clone
can restore it with:

```sh
git submodule update --init vendor/linkedspec
```

Checkout is the first step. Continue with the selected backend guide before
building or running. It supplies the actual dependency declaration, toolchain
requirements, supporting assets and application-owned storage settings.

The Rust route uses RGX. Follow the
[RGX preparation section](integration-rust.md#initial-rgx-preparation), which
links the pinned RGX integration document. LinkedSpec consumes that published
interface; RGX owns all transitive preparation. Do not create a separate PGEN
build procedure or modify either dependency. The documented Perl, Dart, Julia
and Lua routes do not require RGX preparation.

For updates, deliberately select a LinkedSpec revision, follow that revision's
backend preparation instructions, rerun your application's checks, and commit
the new Git entry together with any changed application lockfiles. A submodule
update does not itself prove API or grammar compatibility.

## Keep paths, data and grammar assets with the application

The examples derive absolute paths at runtime from the application's current
root. Persist dependency and grammar locations relative to that root so the
whole application can move. Keep caches, dependency stores, temporary fixtures,
logs and build products on the application's filesystem volume. Each backend
guide shows the required environment; apply it before package preparation as
well as before ordinary execution.

Keep prepared products and caches for repeated runs. Rebuild when required by
the backend's documented workflow or changed inputs. An in-memory compiled
parser is a separate lifetime: the examples load one grammar and reuse one
engine for several independent inputs within a process.

Package the grammar files and supporting assets listed by your backend guide.
The source checkout alone is not a deployment recipe. Deployment examples
exercise calls from outside the application directory and after relocation;
use explicit grammar paths or an application-derived asset root. Dart's
supporting grammar, Julia's package sources and Lua's ABI-matched native modules
have different packaging requirements, explained in their respective guides.

## One grammar, the same direct values

All five examples use the maintained `examples/integration/word.spec` grammar:

```text
{{#include ../../../../examples/integration/word.spec}}
```

Each native adapter compiles this grammar once and parses four independent
inputs. The examples serialize the returned native values as JSON for inspection:

| Input | Direct value |
| --- | --- |
| `alpha` | `["alpha"]` |
| `Beta` | `["Beta"]` |
| `123` | `[]` |
| `123 alpha rest` | `["alpha","rest"]` |

This grammar extracts ASCII words and skips other text. The empty array is a
successful value. It is not proof that an input is a valid complete document.
For example, `café` extracts `caf`. Define your grammar and application validation
requirements explicitly; the
[rule and cursor model](../user-model/rule-modes-and-parse-modes.md) explains
seeking, consuming and repetition.

## Run the maintained consumer checks

Prepare the checked-in example as described in its guide, then follow that
guide's verification section. These checks use native APIs and verify exact
values, explicit asset selection, failures and deployment boundaries:

| Backend | Setup and value checks | Deployment and diagnostic checks |
| --- | --- | --- |
| Perl | [Checked-in example](integration-perl.md#verify-the-checked-in-example), `examples/integration/perl/verify_words.py` | Same section, `examples/integration/perl/verify_deployment.py` |
| Rust | [Word consumer](integration-rust.md#compile-once-parse-independent-inputs) and [workspace checks](integration-rust.md#reproduce-the-integration-checks) | [File-consumer checks](integration-rust.md#reproduce-the-integration-checks): `examples/integration/rust/verify_sexpr.py` and historical `verify_lispish.py` |
| Dart | [Maintained example](integration-dart.md#verify-the-maintained-example), `examples/integration/dart/verify_words.py` | Same section, `examples/integration/dart/verify_deployment.py` |
| Julia | [Maintained checks](integration-julia.md#run-the-maintained-setup-checks), `examples/integration/julia/verify_words.py` | Same section, `examples/integration/julia/verify_deployment.py` |
| Lua and LuaJIT | [Consumer checks](integration-lua.md#run-the-maintained-consumer-checks), `examples/integration/lua/verify_words.py` for each runtime | Same section, `examples/integration/lua/verify_deployment.py` for each runtime |

A successful native value, a diagnostic event and a runtime failure are distinct
outcomes. Each guide shows their host-language representation and the example's
process exit policy. Use the native diagnostic callback/sink for structured
events. Interpreter or launcher messages may also appear on stderr; the Lua
guide documents the currently observed launcher warning.

The measured integration routes use macOS arm64, Perl5.34.1, Rust1.95.0,
Dart3.13.3, Julia1.12.7, PUC Lua5.5.1 and LuaJIT2.1.1788460057. These are tested
identities, not a new minimum-version or cross-platform guarantee. In particular,
the Lua integration proof does not establish the declared PUC5.4 target or the
known malformed-regex error path. See each guide and
[project status](../overview/project-status.md) for the qualified evidence and
remaining grammar, runtime and integration limitations.
