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
date: 2026-09-13
status: inventory and Rust setup/native consumer verified; Lispish/deployment and other guides pending
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
| Perl | Add the checkout's `perl/` to `@INC`; use `LinkedSpec::SpecLoader`. | Perl and the repo-owned modules; verify the actual loaded-module closure with the consumer. The facade declares `use 5.010`, which is not a fresh minimum-version support test. | `load_and_compile_spec(...)->compiled` yields the parser coderef; invoke it with a scalar reference and optional invocation options. |
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
the other pages remain planned until their owning leaves land.
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
