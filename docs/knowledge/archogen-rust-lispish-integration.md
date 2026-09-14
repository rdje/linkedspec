---
id: archogen-rust-lispish-integration
title: ARCHOGEN can use Rust native loading with explicit Lispish and dependency preparation
answers:
  - what does ARCHOGEN need besides a LinkedSpec git submodule
  - can a Rust application embed Lispish without Perl or the CLI
  - does a fresh LinkedSpec recursive checkout include generated PGEN parsers
  - is the historical Lispish output a flat s-expression list
  - where are the requested five-backend integration guides tracked
  - where does reading resume after the integration documentation pivot
  - does Rust Lispish validate a whole input file
  - does Lispish decode quoted escape sequences
  - which task owns strict Lispish document parsing
date: 2026-09-13
status: Rust file consumer, clean pinned preparation and deployment verified; no ARCHOGEN application test
tags: [rust, lispish, embedding, dependencies, discussion]
evidence: "CONFORMANCE-SOURCE-READING.1.34 director discussion; existing Rust native loading and Lispish walkthrough; root/RGX submodule declarations, Cargo manifests and RGX README build note. No project or dependency source changed."
reverify: "Run bash tools/run_cargo_local.sh test --offline --locked --manifest-path examples/integration/rust/Cargo.toml; build --bins with the same wrapper/manifest/options; run bash tools/run_python_project_data.sh examples/integration/rust/verify_lispish.py --binary rust/target/debug/lispish_file. Replay clean preparation from docs/linkedspec-book/src/public-api/integration-rust.md. Historical discussion/source pointers remain below; an actual ARCHOGEN integration test remains consumer work."
---

## September 13 native Lispish characterization

The complete guide is `docs/linkedspec-book/src/public-api/integration-rust.md`,
linked from the book and Rust landing page. `examples/integration/rust/` contains
the locked word consumer, actual-file consumer, sample settings and maintained
verifier. Three adapter tests pass. The verifier checks18 files through one
engine plus the published settings file, structured loader/runtime failures,
I/O/UTF-8/usage errors, earlier output before a later error and packaged/moved
outside-cwd execution. The file consumer uses an executable-relative default
grammar path and explicit caller-relative override; it does not embed a build
checkout path. The domain adapter is shape conversion, not source validation.

Clean LinkedSpec42490a9d917e, RGX8763a0e6bea9 and PGENdb6f8c6836fe sources were
cloned from committed objects with every tracked blob checked. Only the Rust
dependency closure was initialized, not optional PCRE2/HDL test repositories.
A byte-verified public registry seed copied12738files/348484293bytes. Initial
offline PGEN resolution lacked mimalloc metadata; normal online preparation
then passed. No claim is made that mimalloc itself was compiled. Bootstrap
produced12files/18576534bytes, including EBNF, regex and both annotation Rust
parsers. The pinned Makefile executes `./target/debug/ast_pipeline`, so bootstrap
must select PGEN's own `rust/target`; application builds use their separate local
target. The guide now contains the verified override.

The separate application preserves the200-package reference lock's versions.
Locked offline builds took40.50s then4.87s; both logs report normal dependency
compilation, so the repeat is not a zero-build claim. Original-checkout file
consumer tests/build also pass. The original18-file nested PGEN diff remains
byte-exact: full-index SHA256
`4afdce4e7ec45ff7273dce698c6284cd7fa837de6e332c2fef8f9875f43aa0e5`.
Prepared-source/registry/generated/lock manifests and native/trace results live
under `.linkedspec-data/scratch/backend-integration22/`; the maintained verifier
and guide make the product checks reproducible without that scratch history.
This is macOS arm64/Rust1.95.0 debug-binary proof, not an empty-cache network
installation, release/cross-platform guarantee or actual ARCHOGEN build.

`BACKEND-INTEGRATION-GUIDES.2.2` runs 34 bounded cases through the already-built
native Rust integration consumer. Nine independently selected `LinkedSpec::Get`
Perl results match exactly. The historical head/tail examples below are confirmed
on Rust, including `[null]` for `()`. Empty input, a bare atom and a missing closing
parenthesis return null; a leading unmatched `)` produces `exit_now(1)` as a native
error. The caller must distinguish a missing value from a parsed empty list.

This is a first-form extraction grammar, not complete-document validation.
Leading text, trailing text and a second form can be ignored. An unterminated
double quote can yield an ordinary atom; `([])` yields the empty-form shape;
`(a ;comment)` yields `a` followed by `comment`, because the comment rule requires
a newline. Descriptors report `seek`/`default_scan_loop` for the entry and
parenthesis rules. Generated source returns the first parenthesis child directly;
its no-match branches return undef. The executed trace and exact values are under
`.linkedspec-data/scratch/backend-integration22/`.

Quoted escape sequences retain their literal characters; they are not decoded
as Rust, JSON or Lisp string escapes. Exact native/reference codepoints for an
escaped quote are `[97, 92, 34, 98]`. Capture, `join_values` and `cat` controls
preserve these bytes. The apparent additional escaping in the first inspection
was nested JSON display, not a runtime defect. Numeric atoms remain strings,
single quotes are ordinary atom characters in the parenthesis rule, brackets
remain in nonempty square-bracket content, and braces are removed from brace
content. Adjacent token fragments join into one atom.

`SESSION-STARTUP-READING.83.1-.83.3` own the strict document/token contract,
implementation and independent admission. They also give explicit ownership to
the grammar follow-ons described by historical `PHASE0-BACKHALF-TRIAGE.5.2`.
This current work does not reverify that older same-buffer never-undef finding or
claim that strict parsing is delivered. File integration, deployment and pinned
preparation now have the proof above; no ARCHOGEN application was built.

## Initial integration discussion and source guidance

The initial question was discussion during the active reading leaf. The director
subsequently requested integration guides for all five backends and explicitly
authorized a temporary pivot after clean conformance .1.34.
`docs/tasks/BACKEND-INTEGRATION-GUIDES.md` owns the common entry, five guide/example
lanes and final verification. Its .0 starts next; after .7, return to conformance
.1.35. This authorization temporarily defers remaining startup reading for the
documentation activity; it does not close the reading or existing runtime repairs.
ARCHOGEN can embed the native Rust backend in its own process. A checkout alone
does not connect Cargo dependencies or define the application's data model.

For a proposed `vendor/linkedspec` checkout, the consumer Cargo dependency is:

```toml
[dependencies]
linkedspec-runtime = { path = "vendor/linkedspec/rust/linkedspec-runtime" }
```

This assumes Cargo.toml is at the ARCHOGEN repository root. A workspace member's
path must instead be relative to that member's manifest. The runtime brings core
and RGX through existing path dependencies. LinkedSpec's nested RGX submodule
contains PGEN and PCRE2 submodules; recursive initialization preserves that layout.
This is source checkout, not a requirement to build every nested product.

The RGX README explicitly documents a fresh-checkout prerequisite: PGEN's
generated EBNF and regex parser sources are not shipped in Git. Prepare them once
when absent or invalidated by the pinned dependency update, then retain compatible
products and Cargo caches on the consumer repository volume. The documented
bootstrap target is `regex_parser_bootstrap` in PGEN's Rust Makefile. This note
does not run it or certify a clean consumer bootstrap. Repeated-build remediation
remains owned by `SESSION-STARTUP-READING.80`; no automatic reuse guarantee is added.
The September13 director update cancels the no-rebuild prohibition: normal Cargo
compilation of RGX/PGEN is authorized. This performance repair does not block the
integration guides, and existing dependency sources/pins remain untouched.
The current local RGX/PGEN manifests declare Rust 1.95. The older README 1.85
claim and actual compiler support proof remain owned by startup .41.7; see
[[rust-build-requirements-documentation-gap]].

The public file pipeline is `SpecRequest::path` with explicit `SpecLoadOptions`,
then `load_and_compile_spec`, `into_engine`, and
`execute_value_with_diagnostics(input, &ExecutionOptions::new())`. Resolve the
repository root at runtime and load the case-sensitive `specs/Lispish.spec` path.
Compile the grammar once and reuse the engine for independent inputs. The direct
value API avoids the legacy `execute` accumulator wrapper. Native parsing needs
no Perl process or LinkedSpec CLI. Package the grammar with the application or
adopt the existing in-memory/generated-source surface deliberately.

The historical Lispish grammar returns a head/tail array tree, for example
`(a b c)` becomes `["a", ["b", "c"]]`. It does not preserve all token kinds:
parent rules extract token content from their child records. ARCHOGEN should
explicitly choose whether that representation, quoting and escape behavior fit
its own s-expression language, and convert results into its typed domain model.
The Perl convenience walkers in `perl/Lispish.pm` are not Rust application APIs.

Existing Lispish parity fixtures support feasibility, not arbitrary document
acceptance. A consumer check should cover nested and empty forms, strings,
comments, malformed delimiters, complete input consumption and multiple top-level
forms if required. The dated Perl no-progress/multi-form findings must not be
promoted into either a new Rust failure claim or a guarantee of complete-file
parsing. No ARCHOGEN input, clean clone or consumer executable was tested here.

Related facts: [[rust-native-spec-resolution]], [[rust-project-data-ssd-storage]],
[[rust-ci-pgen-missing-input-rebuilds]], [[rust-scalaref-legacy-path-parity]],
[[lispish-corpus-catastrophic-backtracking]].
