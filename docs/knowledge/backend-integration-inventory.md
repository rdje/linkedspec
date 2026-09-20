---
id: backend-integration-inventory
title: Five native integration guides have distinct setup dependencies and one common content route
answers:
  - what is the implementation plan for the five backend integration guides
  - which LinkedSpec backends require RGX and PGEN for native use
  - where will the integration guides and executable consumer examples live
  - how do native integration callers obtain direct parser values
  - which runtime versions were observed for integration guide preparation
  - how was the standalone Rust integration example verified
  - which modules and native libraries does the Perl integration example require
  - how is clean Perl submodule integration verified without RGX and PGEN
  - how does a Perl embedding application handle runtime context errors and diagnostics
  - why does an empty PERL_UNICODE setting double encode JSON bytes
  - does a Dart embedding app need hosted packages or RGX PGEN
  - which supporting grammar must a Dart native application package
  - how does the Dart integration example deploy a compiled executable outside its working directory
  - how does a Julia application activate a relative LinkedSpec path package
  - does a Julia consumer inherit the library manifest or need its own package lock
  - what Julia package data must an offline integration retain
  - how does a Julia application deploy and relocate offline
  - how does a Lua application retain native products without rebuilding each run
  - what blocks committing the verified Lua integration guide
date: 2026-09-20
status: Rust complete, Perl/Dart/Julia leaves and Lua setup verified; Lua deployment and independent closeout pending
tags: [integration, documentation, perl, rust, dart, julia, lua]
evidence: "BACKEND-INTEGRATION-GUIDES.0, activation 00f9783a1e4b625bc251a3e260ef1eef60c35888. Canonical Knowledge, ADR0040, companion tree, manifests, six complete setup scripts and native loader/result seams inspected. Managed version commands and read-only pkg-config identities consumed with exit0; no compiler, dependency preparation or consumer execution ran."
reverify: "Inspect the exact sources in the matrix below. Version-only commands: bash tools/run_cargo_local.sh --version; bash tools/run_dart_project_data.sh --version; bash tools/run_julia_project_data.sh --project=julia --version; bash tools/project_data_run.sh perl -e 'printf qq{Perl %vd\\n}, $^V'; bash tools/project_data_run.sh lua -v; bash tools/project_data_run.sh luajit -v; bash tools/project_data_run.sh pkg-config --modversion lua luajit libpcre2-8. These commands establish installed identity, not consumer support or a passing backend suite."
---

The director explicitly requests implementation of all backend integration guides
after the clean conformance .1.34 checkpoint, then a return to conformance .1.35.
The current activity is `docs/tasks/BACKEND-INTEGRATION-GUIDES.md`. Remaining source
reading is temporarily deferred for this activity; its coverage and unrelated
runtime repair obligations remain unchanged. No further approval is needed for
ordinary guide/example work within that request.

## Setup and native value inventory

| Backend | Package or module wiring | Required setup for the inspected route | Direct result path |
| --- | --- | --- | --- |
| Perl | Add the checkout's `perl/` to `@INC`; use `LinkedSpec::SpecLoader`. | Perl and the repo-owned modules; .1.1 verifies66 repository modules plus37 core modules and10 standard native libraries on Perl5.34.1. The facade declares `use 5.010`, which is not a fresh minimum-version support test. | `load_and_compile_spec(...)->compiled` yields the parser coderef; invoke it with a scalar reference and optional invocation options. |
| Rust | Cargo path dependency on `rust/linkedspec-runtime`; it brings core and `rgx-core`. | Compatible Rust toolchain, recursively initialized RGX/PGEN, required generated PGEN parser sources and Cargo dependencies. Existing local dependencies declare Rust1.95. | `load_and_compile_spec(...).into_engine()` then `execute_value_with_diagnostics(input, &options)` returns the direct JSON value. |
| Dart | `linkedspec_dart` path dependency on `dart/`. | SDK constraint `>=3.9.0 <4.0.0`; no runtime package dependencies in pubspec.yaml. `test` is a development dependency. The regex implementation uses Dart matching and its repo-owned bridge. | `loadAndCompileSpec(...).createEngine().execute(input).value`; execute delegates to parse. |
| Julia | `LinkedSpecJulia`, UUID `8eec5991-a432-4f89-ae45-eeda2e697757`, local package at `julia/`. | Project compatibility Julia1.12 and JSON3 1.14.3; Base64, Random and SHA are standard-library dependencies. Regex is Julia's `Regex` type. Retain package sources and the consumer-local depot. | `load_and_compile_spec(...)`, `create_engine(...)`, then `runtime_execute(engine, input).value`. |
| Lua | `lua/src/?.lua` and `lua/src/?/init.lua` in the module search path; three native modules in the selected ABI's native path. | Matching Lua interpreter/headers, C compiler, pkg-config and PCRE2 development files. Build `linkedspec_regex_pcre2`, `linkedspec_filesystem_native` and `linkedspec_mcp_system` for the chosen ABI. No LuaRocks dependency. | `load_and_compile_spec(...)`, `loaded:create_engine()`, then `runtime_parse(engine, input).value`; the result also carries matched/cursor/output fields. |

The metadata does not require an RGX/PGEN build for the Perl, Dart, Julia or Lua
routes. Recursive source checkout and building every nested project are separate
operations. Initial required preparation must be documented without turning it
into a routine per-run rebuild.

Loader/type authorities are `perl/LinkedSpec/SpecLoader.pm`,
`rust/linkedspec-runtime/src/spec_loader.rs`,
`dart/lib/src/io/spec_loader.dart`, `julia/src/io/SpecLoader.jl`, and
`lua/src/linkedspec/spec_loader.lua`. The existing native API book remains the
semantic authority for name/path resolution and structured pipeline errors.

## Observed tools and existing limits

Version-only output on September13: Cargo1.95.0, Dart3.13.3 on macos_arm64,
Julia1.12.7, Perl5.34.1, PUC Lua5.5.1 and LuaJIT2.1.1788460057.
pkg-config reports Lua5.5.1, LuaJIT2.1.1788460057 and PCRE2 10.48.
These are installed identities, not newly tested minimum supported versions.
Interpreter/compiler/SDK/header/library access is required read-only toolchain
access; no toolchain installation or external project-data write occurred.

Existing owners remain authoritative:

- startup .80: optional-file freshness/performance repair; former no-rebuild requirement cancelled September13;
- startup .41.7: Rust README1.85 contradiction with required local Rust1.95 declarations;
- Lua .2.2: declared PUC5.4 target versus measured PUC5.5.1/header selection;
- Lua .2.3: invalid-regex formatter failure; no excluded malformed-regex or unfiltered Lua gate;
- legacy Lispish facts: historical head/tail representation and dated Perl multi-form/no-progress findings.

Rust-first delivery addresses the motivating ARCHOGEN question. A Cargo consumer
must report actual Cargo behavior rather than manufacture a warm-run claim.
The director cancelled the no-rebuild requirement on September13: ordinary
RGX/PGEN builds are authorized and must not be blocked by a compiler guard.
Retain caches; the optional-file freshness repair keeps its existing owner and
is no longer a prerequisite for these guides.

## Exact content destinations and ownership

Create the common entry at
`docs/linkedspec-book/src/public-api/integration.md` and backend guides at
`docs/linkedspec-book/src/public-api/integration-perl.md`, `integration-rust.md`,
`integration-dart.md`, `integration-julia.md`, and `integration-lua.md` in that
same directory. The Rust page and native word consumer are delivered by .2.1;
.2.2 completes actual Lispish files, typed adaptation, failures, clean pinned
preparation and moved/outside-cwd deployment. See [[archogen-rust-lispish-integration]]
for measured scope and the still-open strict document/token repair under startup
.83. Perl setup, deployment and runtime diagnostics are verified under .1.1-.1.2;
independent parent closeout remains .7. Dart setup and deployment/errors are verified by .3.1-.3.2. Julia setup and deployment/errors are verified by .4.1-.4.2. The common
and Lua pages remain planned until their owning leaves land.
Add navigation through SUMMARY.md and the existing backend landing pages.

Runnable sources belong under `examples/integration/`, with shared grammar/input
fixtures and a directory for each backend. The guides will show both the checked-in
example invocation and the application's actual local dependency wiring after a
`vendor/linkedspec` submodule is added. Keep code listings sourced from the runnable
files where useful; never require a user to infer how an example becomes an app.

Existing `get-and-get-parser.md`, `native-spec-loading.md`, tracing/diagnostic/value
chapters and the Lispish walkthrough retain their normative explanations. The new
pages own consumer setup, assembly, packaging and worked native usage. Link to
those semantic owners rather than copy their contracts. Existing content stays
in place; this activity neither creates independent companion scaffolds nor moves
chapters. BACKEND-COMPANION-BOOKS later inventories and routes these owned pages
under ADR0040 before any companion population.

Each example will accept explicit runtime-derived grammar/input locations, reuse
one compiled engine for independent inputs, check exact results, and demonstrate
documented failures. Deployment checks run outside the checkout's working
directory; complete-input and multi-form guarantees must be tested before claimed.
Storage and example-check workflow changes receive their required verification
tier before editing. Final activity closeout retains canonical CI.

## Managed wrapper boundaries read for this inventory

The complete scripts read are `tools/project_data_env.sh` (288 lines),
`tools/run_cargo_local.sh` (16), `tools/run_dart_project_data.sh` (22),
`tools/run_julia_project_data.sh` (36), `tools/run_lua_project_data.sh` (39), and
`tools/build_lua_native.sh` (112). This inspection does not advance the paused
conformance counter or claim completion of the later startup tooling lane.

The initializer derives storage from its checkout and accepts only same-volume
directory overrides. Cargo and Julia wrappers change to the LinkedSpec root;
Dart preserves the caller cwd and isolates only its child home. Julia defaults
offline and disables startup/history files. The targeted Lua wrapper builds
disposable native products on every invocation, so application reuse guidance
must use explicit retained ABI products instead of presenting that test wrapper
as a zero-build launcher. The native builder has no automatic reuse check.

Related facts: [[archogen-rust-lispish-integration]], [[backend-companion-book-architecture]],
[[rust-native-spec-resolution]], [[rust-project-data-ssd-storage]],
[[dart-project-data-ssd-storage]], [[julia-project-data-ssd-storage]],
[[lua-project-data-ssd-storage]], [[lua-native-readme-and-action-ast-reading]].

## Rust native consumer — September13, integration .2.1

`examples/integration/rust/Cargo.toml` is a standalone application manifest with a
path dependency on the real runtime crate and a checked-in lockfile. Cargo1.95.0
resolves200 packages; all manifest paths, including registry packages, lie below
the current repository root. Rustc1.95.0 compiles the consumer with its native
loading pipeline and direct-value API. One engine parses four independent inputs.
The word grammar dispatches to a regex-bearing child; entering a root alone does
not match that root's stored regex. Native values match the independent
LinkedSpec::Get reference: ["alpha"], ["Beta"], [], ["alpha","rest"].

Both normal Cargo build/run commands pass. The first build reports3m12s and the
repeat4m02s; each compiles PGEN, RGX, core, runtime and the example. This is actual
rebuilding, not a warm dependency-reuse claim. The director explicitly cancelled
the no-rebuild requirement during this leaf. The earlier guard rejected PGEN
compilation, and a narrower retained-library link failed for a missing PGEN rlib;
neither failed diagnostic is successful consumer evidence. The later normal
Cargo-built binary and repeat command provide the accepted native proof.

Four argument rejections pass: missing grammar, missing input, non-UTF-8 grammar
path and non-UTF-8 input. Each returns exit1 with empty stdout and its expected
message. The prepared checkout already had generated EBNF/regex inputs; this
leaf does not verify fresh recursive clone/bootstrap, Lispish adaptation,
outside-cwd deployment or other backends. Those remain explicit activity
criteria. The checked-in Cargo.lock mechanically requires canonical verification;
the exact staged CI receipt governs .2.1 landing, in addition to its native proof. No backend source, dependency source/pin or shared build
wrapper was edited.

Replay from the repository root, using the managed Cargo environment:

```sh
bash tools/run_cargo_local.sh metadata --offline --locked --format-version 1 \
  --manifest-path examples/integration/rust/Cargo.toml
bash tools/run_cargo_local.sh run --offline --locked \
  --manifest-path examples/integration/rust/Cargo.toml -- \
  examples/integration/word.spec alpha Beta 123 '123 alpha rest'
```

A second normal run must reproduce the four values; record whether Cargo rebuilds.
Exact local evidence is under `.linkedspec-data/scratch/backend-integration21/`:
`verification.json`, `build-authorized.log`, `repeat-cargo.log`, and native JSONL
outputs. The runnable source and expected values are also in the public guide,
so they remain reviewable without relying on retained scratch.

The first canonical attempt rejected the new guide as an unowned cursor-inventory
path because its chapter link contains a scanned migration token. The same .2.1
leaf registers that path and the matching current census markers; the inventory
is now 75 while 8 rollout legs and 60 mutations remain unchanged. Exact contract
projection and the offline checker pass. Historical ADR/snapshots are preserved;
this documentation delta gives no additional startup source-reading credit.

Remaining public preflight also reviews this one page for mutation64-file and
selector63-file inventories. The selector scan exposes three existing mentions
in the Julia callable-validation limitation from6308ff4e24. Its fenced example
now explicitly labels the retired syntax invalid, while the full example and
open Julia repair remain intact. The reference census is35; the fourteen mutation
documents, eleven semantic examples, fifty mutation cases, five selector contrasts
and eleven contrast mutations remain unchanged. The generated-source, native
resolution and language-coverage checks pass. Exact semantic contracts stay
byte-identical; final receipt-bound canonical verification still governs landing.

## Perl native consumer — September14, integration .1.1

The canonical chapter is `docs/linkedspec-book/src/public-api/integration-perl.md`.
The runnable consumer and its module/value verifier live in `examples/integration/perl/`.
An explicit -I selects the checkout's complete perl/ tree; the portable SpecLoader
receives one exact grammar path, explicit cwd and no search roots. One compilation
serves independent input scalars and returns the shared word grammar's array directly.
The original four values are ["alpha"], ["Beta"], [], ["alpha","rest"].

Both the current checkout and a clean pinned source submodule pass eight verifier
groups. inspect_modules.pl snapshots %INC after the actual consumer, before its
inspection-only imports. There are66 repository module files plus the consumer,
37 Perl core module files and10 native libraries supplied by Perl5.34.1 on macOS
arm64. The verifier checks core-catalog identities and actual distribution paths;
no third-party CPAN dependency, PathSearch.pm or PPlugin.pm is loaded in this route.
This is not a minimum-version or all-plugin dependency claim. Retain the complete
source checkout and specs/ for other facilities described by
[[current-supporting-grammar-dependencies]].

The fresh consumer uses a real Git submodule atad290bdb4, with the public HTTPS
origin preserved. A command-scoped local transport rewrite avoids downloading
already-owned Git objects; all2814 source files/58588415 bytes match committed
blobs. Nested RGX/PGEN remains uninitialized. The candidate consumer and common
grammar are copied byte-exactly into the application's bin/ and specs/ directories.
No package installation or dependency build is needed; independent and repeated
native runs pass. Consumer data is rooted under its own .app-data on this volume.
The original checkout's pre-existing PGEN diff remains exact.

Replay syntax, native values, module closure and failures from the repository root:

```sh
bash tools/project_data_run.sh env PERL5LIB= PERL5OPT= PERL_UNICODE=0 perl -Iperl -c examples/integration/perl/parse_words.pl
bash tools/run_python_project_data.sh examples/integration/perl/verify_words.py
bash tools/project_data_run.sh env PERL5LIB= PERL5OPT= PERL_UNICODE=0 prove -Iperl t/native_spec_resolution.t
```

The maintained verifier additionally proves Unicode cwd/grammar paths, absent
grammar, usage and invalid UTF-8 argument rejection, plus cleanup of owned fixtures.
For another managed consumer, supply its --perl-root, --consumer and --grammar
paths to the same verifier. These paths are derived from the current root at
runtime. Setup proof does not complete Perl deployment/runtime-error/sink .1.2.
Other backend guides and final .7 remain required before conformance .1.35 resumes.
Rust .2.2 is already committed and pushed atad290bdb4; full CI passed with both
CLI66/66 and Phase0 1032/1032, and the remote main hash was verified.

## Perl deployment and error channels — September19, integration .1.2

The existing guide and consumer now cover optional diagnostic_sink events, typed
exit/arity errors, structured loader failures and nonthrowing handler last_error.
The word/module verifier remains8 groups/66 project modules/37 core modules/10
standard native libraries. The deployment verifier passes17 groups using clean
pinned ad290bdb4 source; the current source passes15 plus the two isolated native
trace controls. Three targeted Perl suites pass27 tests. Source/grammar hashes
survive packaging and a move to a Unicode path; two outside-cwd calls and one
caller-relative grammar call pass. The source bundle retains perl/, specs/ and
tools/; launcher-derived .app-data and the wrapper checkout identity stay on the
same volume. This is writable source deployment, not an immutable bundle or
another operating-system/ABI claim. No nested dependency initialization/build
is needed for this Perl route. Replay:

```sh
bash tools/run_python_project_data.sh examples/integration/perl/verify_deployment.py
bash tools/run_python_project_data.sh examples/integration/perl/verify_words.py
bash tools/project_data_run.sh env PERL5LIB= PERL5OPT= PERL_UNICODE=0 prove -Iperl t/native_spec_resolution.t t/diagnostic_output_perl_contract.t t/generated_source_contract.t
```

A scratch probe initially double-encoded its own UTF-8 JSON: empty PERL_UNICODE
adds an output UTF-8 layer. Eight inline/file codepoint controls prove the parser
preserved Latin-1 and wider Unicode values; PERL_UNICODE=0 and raw output remove
the observer artifact. The maintained consumer uses both controls. Native trace
is separate: SpecEntry emits level-zero records on ordinary handler failure,
as documented by [[perl-primary-cli-conformance-audit]]. This standalone adapter
selects negative-level/empty-route trace configuration and clears inherited trace
settings; an application embedding multiple parsers must choose a process-wide
policy. The verifier preserves a sentinel trace file despite inherited reset/
mirror requests and requires JSON-only stdout on validation/handler failure.
Typed events/exit retain their separate [[perl-diagnostic-output-events]] contract;
no failure rollback or subsequent parser reuse is promised. The source/runtime
and dependency pins remain unchanged; final .7 retains independent parent closure.

## Dart native application — September19, integration .3.1

The canonical integration-dart chapter and examples/integration/dart package use
SpecRequest.path, loadAndCompileSpec, createEngine and execute(input).value. The
shared word grammar gives the same four direct values as the Perl/Rust examples.
Both working and clean pinned-source consumers pass9 groups. Pub has exactly two
local package roots and one relative path dependency; the application does not
inherit the library's test-only hosted dependencies. The separate application
resolves offline with an initially empty cache in0.90s and runs in1.44s/1.37s on
SDK3.13.3/macOS arm64. Its clean submodule0aac639a9 preserves2822 files/58656678 bytes,
leaves RGX/PGEN uninitialized, and keeps source/data on this volume. The lockfile's
path does not replace the Git submodule revision pin.

The default staged file loader requires specs/user_function_definition.spec even
for source without a function. Copy that asset from the pinned checkout into the
application specs/ directory and execute from the application root. Default
lookup searches cwd/script ancestors, not the Dart path-package root. The verifier
uses an invalid owned copy to force parse_spec/spec_parse_failed, then restores
identical bytes and succeeds. That control rules out accidental success from a
convenient parent checkout. [[dart-function-definition-shell-projection]] owns the
underlying parser mechanism. Lower-level explicit parserSpecSource remains a
separate supported input; no new loadAndCompileSpec option is invented.

Replay the nine groups with managed Python, which launches only wrapped Dart:

```sh
bash tools/run_python_project_data.sh examples/integration/dart/verify_words.py
```

The consumer-only formatter/strict analyzer and13 loader/function/native-trace tests
pass. [[dart-component-gate-sdk-compatibility]] retains the already-confirmed full
component failures under .2.24/.2.25; no complete Dart gate success is inferred.
The new page advances only public counts66/65, preserving all semantic checks.
Deployment, comprehensive runtime errors and sinks remain .3.2; .7 retains final
independent replay/parent closeout before conformance .1.35.

## Dart source and AOT deployment — September19, integration .3.2

The maintained parse_words.dart accepts optional --diagnostics and --, emits
typed per-call diagnostic records separately from direct JSON values, retains
RuntimeInterpreterException.toJson() and handles RuntimeExitNow as its own
status-bearing record. This adapter chooses process exit 1 for failures and
typed exits. Prior output remains delivered and the input loop stops immediately.
It does not install native trace or infer configuration from inherited trace
environment variables. The admitted native APIs are unchanged.

The 36-group deployment verifier passes on both current source and a separate
application whose clean LinkedSpec submodule is pinned to 0826ca2d4. Each run
checks thirteen source and thirteen AOT behaviors, then ten packaging controls.
The native bundle contains only the compiled executable, Bash launcher, three
application grammars and the pinned user_function_definition.spec. Its launcher
preserves caller-relative grammar meaning before selecting the bundle root.
A bad caller support grammar breaks the bare executable but not the launcher;
a bad packaged copy fails, a missing copy returns deployment_error without
ancestor fallback, and restoration/moving preserve exact bundle bytes. Moved
Unicode paths and read-only file modes work with no Dart command on PATH.
This is measured macOS arm64/Dart 3.13.3 evidence, not another target's admission.
The working deployment replay uses Bash 5.3.15 and the clean-source replay uses
system Bash 3.2.57. An unpublished launcher draft expanded an empty array under
nounset, which system Bash rejected with exit 127. Scalar flags plus positional
argument reconstruction replace that construct; both complete replays pass.

The word verifier remains nine groups; consumer analysis and 23 loader,
diagnostic-output, trace and native-pipeline tests pass. Build with managed
`dart compile exe bin/parse_words.dart -o build/bin/parse_words`, then run
`bash tools/run_python_project_data.sh examples/integration/dart/verify_deployment.py`
from the repository root. The verifier reuses that binary and does not compile
or fetch dependencies. For a separate application, pass --package, --library-root,
--grammar and --fixtures explicitly; --bash selects the deployment-control shell.
Existing complete Dart component failures remain under .2.24/.2.25; final
independent integration closeout remains .7.

## Julia native application — September20, integration .4.1

The maintained Project.toml selects LinkedSpecJulia through `[sources]` with the
relative path ../../../julia. A separate Git application uses vendor/linkedspec/julia
and pins clean source49758cbc9. Both explicitly activate the application project,
restrict JULIA_LOAD_PATH to @:@stdlib, and put the first writable depot and temporary
data under application-owned .app-data on the same volume. The trailing depot
separator retains the installed Julia system depots as read-only toolchain inputs,
not the home depot. Set both JULIA_DEPOT_PATH and LINKEDSPEC_JULIA_DEPOT_PATH because
the latter is the managed wrapper's higher-priority override.

The first application preparation fetches the General registry and five package
source trees into a new application depot, then precompiles. Pkg generates a
relative-path application Manifest.toml: JSON3 1.14.3, Parsers2.8.8, PrecompileTools
1.3.4, Preferences1.6.0 and StructTypes1.11.0 on Julia1.12.7/macOS arm64. The package's
own manifest is not a consumer lock; the existing library manifest remains byte
exact. Compatibility ranges can admit different versions in a newly resolved app.
Commit the application's generated manifest and the Git submodule pointer, which
own different parts of reproducibility.

The separate consumer receives only copied/verified project-owned package sources
(148 files/734878 bytes, manifest SHA256 e75ea14d524f33c408d668c99fd0504af4658f5bc97e8b8ca60b36b00808eee4)
and registry inputs (2 files/11419507 bytes, manifest SHA256 8bbac5a5f2252c96dd55791ee13c6ff53012ebc644e1aa23f95775719ad0e025).
No compiled depot is copied. Offline preparation must retain source and registry
inputs; an initially empty depot cannot load JSON3 from cache filenames alone.
These copies are both repository-local; no shared home cache is deleted or used.

The public guide includes the actual native consumer and shared word grammar.
The adapter fixes application-relative grammar meaning with an explicit cwd,
compiles once and parses independent inputs in one Julia process, serializing
only result.value. Fresh ordinary processes reuse the prepared environment; no
package update command or RGX/PGEN build is required for each parse. This is not
a claim of zero Julia compilation or persisted compiled-parser objects. Package
source-first support grammar selection is owned by
[[julia-spec-driven-function-shell-parser]].

Replay the application setup checks with:

```sh
bash tools/run_python_project_data.sh examples/integration/julia/verify_words.py
```

Supply --package, --library-root and --grammar for a prepared separate application.
Native loader tests cover82 assertions, including the function-bearing staged
pipeline and source identity; the shared resolution contract remains14/9/4.
The new public page advances only inventory counts67/66. Julia deployment,
comprehensive runtime diagnostics and cache relocation remain .4.2; independent
parent closeout and final canonical push remain .7.

Both maintained and clean-source applications pass11 setup/value groups; their
independent-input calls take12.39s and12.61s, with fresh-process repeat calls12.43s
and11.88s respectively on this host. These are observations, not performance
contracts. All2832 pinned source files/58732023 bytes match committed blobs; nested
RGX/PGEN is uninitialized and the original PGEN diff remains unchanged.

## Julia source deployment — September20, integration .4.2

The maintained adapter now accepts --diagnostics and --, passing a typed sink to
runtime_execute and projecting RuntimeExitNow separately from runtime errors.
The application launcher fixes its project and owned depot from its own location;
relative grammar paths retain application-root meaning. Missing packaged function
grammar fails explicitly before native ancestor lookup. Exact event/typed-error
semantics remain [[julia-diagnostic-output-helpers]].

Both current and clean 29bf3fdd1 applications pass 24 deployment checks,11 setup/value
groups and 164 native loader/diagnostic assertions. Git archive packages committed
source without nested dependency contents. The separate application's manifest is
copied byte-exactly; the in-repository example lets Pkg generate the bundle-relative
local source entry while preserving all five registry versions and content hashes.
Only owned package sources and registries are copied; fresh offline preparation
creates compiled caches. Source, manifest and package hashes survive moving to a
Unicode path and outside-cwd calls. The deployed source/data remain writable.

Replay `bash tools/run_python_project_data.sh examples/integration/julia/verify_deployment.py`.
Use --package, --library-root, --grammar and --fixtures for a prepared separate app;
--bash selects the deployment shell. Both Bash 5.3.15 and system Bash 3.2.57 pass on
Julia 1.12.7/macOS arm64. Clean source is 2838 files / 58774855 bytes. Runtime source,
pins and original PGEN changes remain exact; final parent closeout remains .7.

## Lua setup — September 20, integration .5.1

The native consumer and guide now select exact Lua and ABI-specific native paths,
use interpreter -E, and keep reusable products in application build directories.
Thirteen setup checks pass on both working and clean pinned 0b409e305 applications
for each installed runtime: PUC Lua 5.5.1 and LuaJIT 2.1.1788460057 with PCRE2 10.48.
Five selected native loader tests pass per runtime. Clean source is 2842 files /
58811026 bytes; nested RGX/PGEN remain uninitialized and original PGEN edits stay
exact. Native product hashes/mtimes are unchanged across fresh processes.

Detailed build/reuse, module and supporting-grammar facts are in
[[lua-project-data-ssd-storage]]. The maintained verifier is
examples/integration/lua/verify_words.py (--runtime puc or luajit); build the chosen
ABI once as documented in the guide before running it. Optional --package,
--library-root and --grammar select a prepared separate consumer. Declared PUC 5.4
and invalid-regex handling remain unverified; .5.2 owns deployment/diagnostics and
.7 owns independent parent closeout. No runtime source, pin or reading credit changes.

## Lua setup landing — history capacity proposal, September 20

Native/setup proof is complete; .5.1 is not committed. Its two required normal
rollovers preserve clean 0b409e305 source exactly but exceed current controls.
The task-tree section "Lua integration history capacity" owns the exact proposal,
six old/new limits, reconstruction identities and seven-record finite forecast.
Change-history files/manifest lines/bytes would be 39/38/21647 (limits38/37/21071);
engineering notes would be 35/34/20514 (limits34/33/19902). No limits changed.
Both new archive segments reproduce exact HEAD suffixes; all older rows/archives
are unchanged. Both current hot shards pass roll_document_history --check, while
scripts/check_readme_stability.sh rejects exactly those six controls.

The proposal requests one slot per collection, preserving all other controls and
normal canonical CI. README_POLICY.md requires an accepted indexed ADR before any
routed limit changes; ADR0118's finite Lua-reading allowance does not authorize
later increases. Seven further records of14 lines/2048 bytes fit the retained hot
shards without another rollover (240/46302 and208/46175 maxima). This forecast
covers remaining integration and bounded closeout overhead, not unlimited PNT.
Reverify actual state with both history --check commands and the routing checker;
the current task owns disposition and repair before .5.1 can land.

### Approved disposition and implementation

The director granted all six proposed limits on September 20. ADR0121 records the
exact old/new objects and normal canonical verification. Its implementation changes
only those six registry scalars. Actual production functions pass 44 boundary and
34 authorization cases; unchanged guards reject absent/altered authority and every
tested unapproved increase. The proposal above is dated pre-admission evidence.
Reverify the current candidate with scripts/check_readme_stability.sh and both
history --check commands; exact staged canonical CI still governs .5.1 landing.
All previous archives and historical manifest rows remain byte-exact. Finite
forecast counts are recomputed after admission overhead; this is not an unlimited
PNT capacity grant. Continue Lua deployment .5.2 after a clean committed handoff.
