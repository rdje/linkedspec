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
  - how does a host Cargo workspace exclude vendored LinkedSpec
  - does the workspace verifier query dependency internals
date: 2026-09-21
status: workspace and public integration verified; prerequisite guidance corrected; bootstrap message and strict Lispish reports remain open
tags: [rust, lispish, embedding, dependencies, discussion]
evidence: "September13 native Lispish proof; September20 report intake, workspace repair and successful RGX public bootstrap/native consumer proof. Supplied grammar patch remains unverified locally."
reverify: "Follow the public preparation/workspace sequence in docs/linkedspec-book/src/public-api/integration-rust.md, then its native consumer checks. Treat rgx/docs/INTEGRATION.md as the dependency authority; do not inspect implementation."
---

**Direct dependency boundary:** LinkedSpec integrates only with RGX. RGX's
published integration document, public APIs and contracts are the sole authority.
RGX owns PGEN and all transitive preparation; no separate PGEN procedure or
internal dependency knowledge belongs in LinkedSpec. Reports go to RGX.

## September 20 public build boundary

The director requires RGX and PGEN to be black boxes. The integration authority is
`rgx/docs/INTEGRATION.md`: use RGX's public `make bootstrap` before the consumer's
Cargo build. Do not inspect or reconstruct dependency internals. A proposed local
bootstrap implementation was discarded before commit; its internal recipes and
conclusions are removed from maintained knowledge. Dependency source and pins
were unchanged throughout. `BACKEND-INTEGRATION-GUIDES.8.3` owns this correction
and public-interface verification; ARCHOGEN/LS-004 is not thereby declared fixed.

On unchanged committed source, the documented RGX bootstrap passes offline in
56.19s and repeats in 0.22s using a populated local package store. The two-member
host application builds in 26.65s; exact word values, 18 Lispish file/deployment
groups and three adapter tests pass with unchanged locks. An empty offline store
makes the same public command exit 2 correctly, while printing misleading
intermediate progress. The public reproduction is
`docs/upstream/rgx/bootstrap-progress-status.md`, with upstream follow-up owned by
`RGX-CONSUMER-BUILD-REPORTS.1`. It has not been posted externally. Evidence lives
under `.linkedspec-data/scratch/backend-integration83/public-interface/`.
This proves native use on macOS arm64/Rust 1.95.0 with committed source archives
and retained packages; it does not prove fresh network checkout/initialization,
release builds, another platform or an actual downstream application build.

## September 20 Cargo workspace repair

Integration `.8.2` repaired ARCHOGEN/LS-001 and SEMULITH/LS-003 item1:
the example declares its own empty `[workspace]`, and an enclosing application
adds `exclude = ["vendor/linkedspec"]` at its workspace root before preparation.
The original private dependency metadata probes are retired by `.8.5`; they are
not a maintained integration contract. The dated experiment remains in Git.

The current `verify_workspace.py` archives only LinkedSpec-owned Rust/example
source and links the retained RGX checkout as an opaque dependency. Nine locked,
offline metadata controls query only LinkedSpec/application manifests. Removing
the example's boundary reproduces Cargo's enclosing-workspace rejection; host
exclusion restores valid independent membership. Standalone library/example and
two-member host membership remain exact. No internal dependency directories or manifests
are selected, copied or queried directly. Metadata is only membership proof;
RGX's documented bootstrap and the native consumer checks establish actual use.
This follows [Cargo's workspace discovery/exclusion contract](https://doc.rust-lang.org/cargo/reference/workspaces.html#the-members-and-exclude-fields).

The two-member application (`app` and `support`) builds and parses through the
native runtime. The separately built example also passes its exact word values,
three adapter tests and 18 Lispish file/deployment groups; the copied host file
consumer passes the same 18 groups. Both run outside their source directories.
The application lock changes only local package identities (201 packages versus
the example's 200); all external versions/checksums and the example lock remain
exact. No dependency manifest, source or pin changes. The original 18-file PGEN
diff remains byte-exact.

Source proof checks 2849 LinkedSpec files/58888246 bytes, 857 RGX/138872410 and
2710 PGEN/72528444 against committed blobs. Same-pin prepared parser inputs from
the .2.2 proof are rechecked and copied byte-exactly: 12 files/18576534 bytes.
The application-owned public registry seed contains 15360 files/380075770 bytes;
all copied bytes and filesystem devices match. Offline locked host/example builds
pass in 28.17s/18.72s, with normal dependency compilation. These are reuse-assisted
clean-source builds, not a new bootstrap, empty-cache network installation,
release-profile guarantee or actual downstream application build.
Evidence is under `.linkedspec-data/scratch/backend-integration82/`.
The `.8.3` public-interface correction is described above. `.8.4` adds explicit
prerequisite links immediately after checkout and at the Lispish file section:
workspace setup, local storage and RGX's public preparation precede Cargo use.
It qualifies SEMULITH's recursive-checkout observation without claiming a measured
size or fresh network initialization for the targeted route. Runnable examples
and commands remain unchanged; rendered navigation is the changed surface.

## September 21 public boundary verification

Integration .8.5 passes nine workspace controls through Cargo1.95.0. The retained
public-interface consumer repeats RGX bootstrap in0.204s with status0/empty stderr,
returns the exact word value and passes all18 Lispish file/deployment groups.
Both native executables preserve hashes and modification times; five application
source/grammar/lock files match the maintained inputs. This reuses the existing
prepared source/package store and establishes no fresh network, older compiler,
new platform, release build or upstream progress-message repair. The Rust README
now follows RGX's public requirement and root-managed Building commands.

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
| ARCHOGEN/LS-001 | Reported open/blocker: example and PGEN manifests encounter an enclosing Cargo workspace. | Integration `.8.2`: reproduced and repaired as above; downstream report state unchanged. |
| ARCHOGEN/LS-002 | Open/blocker for eADL: first-form extraction ignores additional/trailing input; requests complete validation and all forms. | Startup `.83.1` contract, `.83.2` implementation, `.83.3` independent admission. |
| ARCHOGEN/LS-003 | Open/major for eADL: symbols, quoted strings and numbers lose their token-kind distinction. | Startup `.83.1-.83.3`; same requirement as SEMULITH/LS-002. |
| ARCHOGEN/LS-004 | Reported open/moderate: failed bootstrap prerequisites are followed by a false seed-success message. | Integration `.8.3`: public-interface report and guidance correction; no upstream fix or downstream state change claimed. |
| ARCHOGEN/LS-005 | Open/minor: checkout instructions need an explicit forward pointer to required preparation. | Integration `.8.4` corrects and verifies prerequisite navigation; downstream report state unchanged. |
| ARCHOGEN/LS-006 | Withdrawn by reporter: the hex underscore remains intact. | Intake retains the correction; no defect repair claimed or requested. |
| ARCHOGEN/LS-007 | No-action: adjacent fragments join as documented. | Intake retains the measured compatibility case; no behavior change requested. |
| SEMULITH/LS-001 | Draft/high, blocks SOT-FORMAT.9: LF inside a quoted string reportedly becomes syntax and changes the tree. | Startup `.83.1` newline/compatibility decision, `.83.2` concrete token repair, `.83.3` regression admission. |
| SEMULITH/LS-002 | Draft/medium: documented atom-kind erasure limits source-preserving consumers; explicitly a design request. | Startup `.83.1-.83.3`; no silent change to historical Lispish requested. |
| SEMULITH/LS-003 | Draft/low: enclosing workspace, file-section prerequisite back-reference, optional recursive checkout cost. | Item1 repaired by `.8.2`; items2-3 corrected by `.8.4` navigation and qualified observation. Downstream report remains draft. |

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
A byte-verified public registry seed copied12738files/348484293bytes. Earlier
preparation details are retired; current preparation follows RGX's published
interface and its separately recorded successful consumer proof above.

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
and RGX through the published crate interface. Initialize the direct RGX
checkout and let its public bootstrap own all transitive requirements.

RGX's published integration document requires its public bootstrap command on a
fresh downstream checkout. Follow that contract rather than an internal PGEN
procedure. Normal documented builds are authorized; retain compatible outputs
and same-volume caches. Startup `.80` tracks observable performance and upstream
reports only. Source inspection, implementation-derived assumptions and local
submodule patches are forbidden by the September20 director instruction.
The published RGX integration contract requires Rust1.95. Integration .8.5
removes the stale README1.85 claim and routes its Building commands through
managed storage. Tested1.95.0/macOS arm64 is not a minimum/platform matrix; see
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
