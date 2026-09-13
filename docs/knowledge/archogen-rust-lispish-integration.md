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
date: 2026-09-13
status: read-only integration guidance; no ARCHOGEN consumer build or admission performed
tags: [rust, lispish, embedding, dependencies, discussion]
evidence: "CONFORMANCE-SOURCE-READING.1.34 director discussion; existing Rust native loading and Lispish walkthrough; root/RGX submodule declarations, Cargo manifests and RGX README build note. No project or dependency source changed."
reverify: "Read rust-native-spec-resolution.md, rust-project-data-ssd-storage.md and rust-ci-pgen-missing-input-rebuilds.md; inspect .gitmodules, rust/Cargo.toml, rust/linkedspec-runtime/Cargo.toml, rgx/.gitmodules, rgx/rgx-core/Cargo.toml and the fresh-checkout build note in rgx/README.md. Check the Lispish walkthrough and lispish-corpus-catastrophic-backtracking.md for exact historical scope. A real ARCHOGEN integration test remains future consumer work."
---

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
