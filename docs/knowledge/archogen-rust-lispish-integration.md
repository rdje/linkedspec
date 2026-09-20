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
  - which ARCHOGEN and SEMULITH reports are owned by LinkedSpec
  - which task owns the Cargo workspace integration failure
  - which task owns the PGEN bootstrap false success report
  - has the reported Lispish multiline string patch been verified locally
date: 2026-09-20
status: Rust integration verified in the recorded scope; ten downstream reports received and repair-owned, not locally reproduced by the intake
tags: [rust, lispish, embedding, dependencies, discussion]
evidence: "September13 CONFORMANCE-SOURCE-READING.1.34 discussion and integration .2.2 native/clean-source proof; September20 BACKEND-INTEGRATION-GUIDES.8.1 complete read and byte-exact snapshots of seven ARCHOGEN and three SEMULITH reports. Intake changes documentation/ownership only; supplied reproducer and patch results are not local execution claims."
reverify: "Run bash tools/run_cargo_local.sh test --offline --locked --manifest-path examples/integration/rust/Cargo.toml; build --bins with the same wrapper/manifest/options; run bash tools/run_python_project_data.sh examples/integration/rust/verify_lispish.py --binary rust/target/debug/lispish_file. Replay clean preparation from docs/linkedspec-book/src/public-api/integration-rust.md. Historical discussion/source pointers remain below; an actual ARCHOGEN integration test remains consumer work."
---

## September 20 downstream report intake

The director supplied two read-only input directories, both on the repository's
filesystem volume: `../archogen/docs/feedback/linkedspec` and
`../semulith/docs/upstream/linkedspec`. Their report bodies, setup/validation
instructions, reproducers, inputs and frozen observations were read under
`BACKEND-INTEGRATION-GUIDES.8.1`. Neither application repository was modified.
Report IDs are qualified by their source because the two projects reuse `LS-001`
and other numbers for different concerns.

| Report | Supplied state and concern | LinkedSpec repair owner |
| --- | --- | --- |
| ARCHOGEN/LS-001 | Open/blocker: the example and PGEN bootstrap manifests encounter an enclosing Cargo workspace. | Integration `.8.2`: isolated reproduction, supported setup remedy and actual consumer build. |
| ARCHOGEN/LS-002 | Open/blocker for eADL: first-form extraction ignores additional/trailing input; requests complete validation and all forms. | Startup `.83.1` contract, `.83.2` implementation, `.83.3` independent admission. |
| ARCHOGEN/LS-003 | Open/major for eADL: symbols, quoted strings and numbers lose their token-kind distinction. | Startup `.83.1-.83.3`; same requirement as SEMULITH/LS-002. |
| ARCHOGEN/LS-004 | Open/moderate: failed bootstrap prerequisites are followed by a false seed-success message. | Integration `.8.3`: independently reproduce failure, stop promptly and verify products before success. |
| ARCHOGEN/LS-005 | Open/minor: checkout instructions need an explicit forward pointer to required preparation. | Integration `.8.4`, coordinated with `.8.2-.8.3`. |
| ARCHOGEN/LS-006 | Withdrawn by reporter: the hex underscore remains intact. | Intake retains the correction; no defect repair claimed or requested. |
| ARCHOGEN/LS-007 | No-action: adjacent fragments join as documented. | Intake retains the measured compatibility case; no behavior change requested. |
| SEMULITH/LS-001 | Draft/high, blocks SOT-FORMAT.9: LF inside a quoted string reportedly becomes syntax and changes the tree. | Startup `.83.1` newline/compatibility decision, `.83.2` concrete token repair, `.83.3` regression admission. |
| SEMULITH/LS-002 | Draft/medium: documented atom-kind erasure limits source-preserving consumers; explicitly a design request. | Startup `.83.1-.83.3`; no silent change to historical Lispish requested. |
| SEMULITH/LS-003 | Draft/low: enclosing workspace, file-section prerequisite back-reference, optional recursive checkout cost. | Integration `.8.2` for item1; `.8.4` for items2-3. |

These are **supplied observations**, not ten newly reproduced defects. Both
projects name LinkedSpec `ad290bdb427bc19a5af81de0f0b07e119c8999ff`, RGX
`8763a0e6bea97879f027237439d57725f83ead23` and PGEN
`db6f8c6836fefa5a57b1337d3ffbf6f15774089f` on Rust 1.95.0/macOS arm64.
SEMULITH supplies a `(?s)` quote-pattern patch and reports four failures before
and eight passing cases after it. LinkedSpec has not executed that patch during
this intake. Its fixtures distinguish LF from space, parentheses, tab and CR;
the single-quote change and malformed-input effects still need independent proof.
SEMULITH's 1.7 GB / 30-submodule recursive-checkout measurement is a dated
downstream observation, not a universal checkout-size guarantee.

The existing September13 local evidence below already establishes first-form
extraction and lost token kinds. New consumer requirements strengthen the repair
acceptance; they do not turn historical extraction into a strict parser. A final
cursor alone cannot establish that leading or interstitial text was validated.
Likewise, failure to recover original token kinds is narrower than a blanket
claim that no application value can be serialized. No generic parser obligation
to enforce eADL domain rules such as positive periods is inferred from its probes.

The input snapshots contain ARCHOGEN **43 files / 75512 bytes**, manifest SHA256
`7d791417288694ec44c969e7bd683dbbd71f0eaac6b1740496a70dba7b719df5`, and
SEMULITH **29 files / 26871 bytes**, manifest SHA256
`a77e92fedc744643db03edea346d3619c60c1ac3cb20dc97ab444f7cd82ed3af`.
Each digest hashes sorted UTF-8 lines of `sha256(file bytes)`, two spaces,
the path relative to that report directory, and LF. Same-volume byte-exact
copies and per-file manifests are retained as reproducible runtime evidence in
`.linkedspec-data/scratch/backend-integration81/`; the task ownership and qualified
conclusions are durable here and in the task trees. Upstream reproducers were
read, not executed: their default work directories/copy operations and temporary
file allocation must be routed into isolated owned storage before replay.

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
