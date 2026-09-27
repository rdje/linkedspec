# Lossless segmentation and bounded child parsing

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3`. Authority review on 2026-09-27 from
clean `ca197a38c269cfeb89341505db83e395ebf6f308`. Perl segmentation is verified under `.3.2` and
public staged child composition under `.3.3`; Rust matched carriers are verified under `.3.4.1`, Dart under `.3.4.2`
and Julia under `.3.4.3`. Both shared Lua ABI routes are verified under `.3.4.4`; canonical reconciliation remains `.3.5`.

## What this objective must establish

One parent grammar retains every decoded input scalar in ordered item/gap segments. A selected item can declare
a staged child parse without losing its original text or source provenance. The child is an actual precompiled
`.spec` grammar: host glue passes the authorized request and result, but does not recognize the child language.
This is a finite extraction objective, not a claim of strict whole-document validation or format support.

The independent oracle must compare each segment's text, kind and half-open Unicode-scalar span with authored
expected records, then reconstruct the input and check adjacency. Reconstruction alone would miss wrong item/gap
classification. Exact records alone could share a mistaken span convention; Unicode, CRLF and explicit input
slicing provide separate controls. Empty gaps remain observable but account for zero scalars.

Public entry can skip leading blank/comment lines before the selected rule begins. The original decoded input
and absolute offsets remain available, so the grammar must explicitly retain `[0, cursor_pos())` at entry as
well as invocation-owned gaps. Include LF, comment-at-EOF and CRLF controls; see
`docs/knowledge/rust-leading-input-trivia-boundary.md` for the already-established cross-backend boundary.

## Existing authority, with separate public and private boundaries

| Mechanism | Canonical authority | Selected use |
| --- | --- | --- |
| Named item selection and gaps | `capability_conformance/inter_match_gap_capture_contract.json`: authored surfaces, segmentation cases and lifecycle matrix | Public named regex slot, `@capture_gaps`, `entry_slot()`, `gap_kind()`, `gap_span()` and `gap_text()`. Actions explicitly construct the result. |
| Source locations | `capability_conformance/typed_source_location_contract.json`: positions, spans and lossless-gap composition | Same-source scalar offsets; text and identity must remain tied to the caller's original decoded source. Detached spans confer no dispatch authority. |
| Staged children | `capability_conformance/staged_ast_enrichment_contract.json` and ADR0088 | Public exact scalar assignment `marker = parse_job(source_bound_text, hash(literal options))`; an inert marker is consumed after the parent AST returns. |
| Progressive children | `capability_conformance/progressive_span_dispatch_contract.json` and ADR0080 | Private `dispatch_span(...)` intrinsic and host authority. Existing private parity is not a public helper or a substitute for the staged authoring proof. |

The staged text operand is an admitted entry/match text or literal-index group expression, or an ordered `cat`
composition of those expressions. `gap_text()`, copied bindings and arbitrary spans are not admitted operands.
The first composition therefore annotates recognized items, preserves gaps unchanged, and uses `sibling_field`
to keep original item text alongside the child result. Whether a future objective needs direct gap dispatch is
unassessed; this plan neither invents that syntax nor declares a missing capability from its absence.

Caller preparation supplies an immutable snapshot with already-compiled entries. The authored parser identity
selects only within that snapshot. No path/provider lookup, loading, compilation, registry mutation or ambient
authority belongs in the parent or child grammar. Tests must distinguish an inert declaration without a seed
from an authorized composed invocation and from missing/unapproved identity failures.

## Ordered proof and rejection controls

1. **Perl segmentation** (`.3.2`): commit one portable grammar and exact cases for empty input, no selected items,
   leading/trailing text, adjacent items, interstitial punctuation, Unicode including an astral scalar, CRLF and
   malformed candidates retained as gaps. Run native and independently emitted source, repeated retained calls,
   detached-result checks and mutants that alter item selection, gap retention and spans.
2. **Perl staged composition** (`.3.3`): retain that original oracle and add an actual child grammar. Observe exact
   child input and selected identity, local child spans and their global provenance, parent text after stitching,
   child rejection/recovery and authority denials. A child parsing a bounded substring must not see neighboring
   delimiters or gaps. Host request instrumentation may record calls; it must not supply the parsed answer.
3. **Backend carriers** (`.3.4`): split before execution into Rust, Dart, Julia and shared Lua leaves. Preserve the
   same original oracle on PUC Lua and LuaJIT. Record native/reconstructed/generated/emitted proof separately and
   distinguish retained-parser recovery from per-call isolation.
4. **Canonical reconciliation** (`.3.5`): verify checkpoint/source identity, all required route-level results and
   authoring costs. Keep unsupported and untested objectives explicit before closing the parent.

Input containment, exact provenance, authorization, result detachment and resource ceilings are separate claims.
An ordinary small successful child is insufficient evidence for malformed authorities, recursive budget limits,
diagnostic byte ceilings or pre-callback rejection of conflicting stitch targets.

## Existing defects remain owned

- `docs/knowledge/perl-progressive-resource-ceiling-enforcement-gap.md` and startup `.37` own effective numeric
  ceiling and diagnostic containment gaps. The private progressive path is not selected for public proof.
- `docs/knowledge/staged-target-preparation-gaps.md` and startup `.73` own conflicting Perl/Rust destinations.
  Distinct item objects avoid that conflict in the initial corpus; they cannot establish conflict rejection.
- `docs/knowledge/rust-staged-call-counter-saturation.md` and startup `.75` own exhausted maximum counters.
  Small counters do not close that boundary.
- Backend activation must consult the existing staged provenance, resource and result-isolation Knowledge cards
  before selecting its assertions. A defect on the selected route becomes a required repair dependency under its
  existing owner. This plan does not defer a failing acceptance assertion or bless a weaker expected result.

## Fresh verification and limits

These existing independent checkers passed on the activation tree. They include their own drift mutations; no
new runtime composition or backend run is claimed by this documentation slice.

```sh
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py
bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py
bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py
bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py
```

Observed boundaries: typed 14 complete / 0 pending / 231 mutations; gaps 9 complete / 0 pending / 63 semantic
and 34 public mutations; progressive 9/9 / 116 contract and 60 public mutations; staged 9 rollout legs / 123
contract and 129 public mutations. The checkpoint for `.3.1` binds each source and log digest. These counts are
dated measurements, not an independently maintained capability inventory. The four commands above rederive them.

## Perl segmentation evidence — .3.2

`tests/language-readiness/lossless-segments/grammar.spec` is a two-rule default-loop extraction grammar for
bracketed ASCII integers. Its committed `cases.json` has thirteen independently authored exact outputs, including
Unicode and astral text, empty/adjacent gaps, malformed candidates, CRLF and public-entry-skipped LF/comments.
It retains skipped public-entry text explicitly as `entry_prefix`; invocation-owned gap spans keep their own
source identity and provenance. It does not change the public entry policy or reject malformed gap text.

The existing `t/nested_tree_readiness.t` harness runs the same original sequence twice on native and independently
loaded generated source: 26 original calls per route, then a separate returned-gap mutation/reparse check.
Four grammar mutants independently alter selection, terminal retention, item spans and initial-prefix retention.
Each has an exact controlled wrong output and fails the unchanged original oracle. In particular, excluding zero
from the item regex still reconstructs `[0]` exactly as tail text; only classification-aware comparison catches it.
Every original output also passes adjacency, nonnegative spans, decoded-scalar slicing and full reconstruction.

The published gap example exposed a documentation defect: `List::OR` plus `LX` returned null for empty input and
null collectors for selected words. `dump_parser_source` locates the mechanism in the repetition handler's
successful-miss branch: it installs the `EX` tail and returns its collector. The corrected `List::` selects the
default loop. The harness extracts the exact published fence, executes its empty and full Unicode examples twice
on both carriers, and restores `::OR` as a deliberate regression control. No runtime implementation changed.

```sh
bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/nested_tree_readiness.t
bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/inter_match_gap_capture_perl_contract.t t/generated_source_contract.t
```

The readiness run passes 537 top-level tests, including all pre-existing nesting/context/entry controls. Exact
commands, source identities and log digests belong to the `.3.2` checkpoint. `parse_job`, child recognition,
cross-backend segmentation, resource ceilings and whole-format validation are not proved by this result.

## Perl actual-child composition evidence — .3.3

The 27-line parent and 21-line child under `tests/language-readiness/lossless-child/` compose the existing
segmentation grammar with exact `parse_job(entry_group(0), hash(...))` assignment. `return_descriptor` confirms
one dedicated portable staged node without raw-host or unresolved-helper dependencies. The child constructs an
integer-lexeme AST and local span itself. The registry callback only invokes that precompiled parser and uses
the authorized context to rebase its span; it does not recognize digits or manufacture a semantic answer.

`t/lossless_child_readiness.t` runs four carrier pairs: native/native, native parent/emitted child, emitted
parent/native child, and emitted/emitted in a fresh process with no compiler loaded. Each pair repeats the original
thirteen cases twice and compares exact original segment records after removing the child annotation. Separate
assertions check reconstruction, ordered bounded requests, local/global spans, resolved identity, sidecar paths,
fresh invocation caches, selected call accounting and detached returned results. Complete normalized observations
are equal across all four pairs, including typed failures and resource records.

The child corpus pins four exact accepted ASTs and fifteen typed status1 rejections. All four routes detect three
mutations: accepting `[00]` through an overly broad child regex, shifting local/rebased spans while preserving
recognition, and passing `[12]` rather than `12`. `[12][00][7]` calls two children and publishes no partial parent;
the same parser/options then accept `[8]`. Missing identity, forbidden top and exhausted steps execute zero children;
the one-call control executes one. No seed produces an inert marker. These are individual controls, not a claim
about all authority or resource boundaries.

```sh
bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/lossless_child_readiness.t
bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/nested_tree_readiness.t t/staged_ast_enrichment_perl_contract.t t/inter_match_gap_capture_perl_contract.t t/generated_source_contract.t
```

The new readiness consumer and `.3.3` checkpoint own the measured results and exact source/log hashes. The book
includes both complete grammars from their tested sources. No runtime implementation or public authority changes.
The explicit child guards, immutable caller registry and host span projection are current authoring costs. This
finite composition neither tests arbitrary recursion nor closes startup `.37`, `.73` or `.75`; `.3.4` must check
each backend's existing defect cards before claiming equivalent readiness.

## Rust matched carriers — .3.4.1

The existing `rust/linkedspec-runtime/tests/nested_tree_readiness.rs` includes two task-owned test functions from
`tests/language-readiness/lossless-child/rust_carriers.rs`. Shared independent assertions in `rust_checks.rs` also
run inside the emitted crate; all `.spec` and JSON oracles are unchanged from the Perl leaves. The existing atomic
scratch allocator and target cache are reused without new output roots or dependency changes.

Native compiled and JSON-reconstructed engines each execute through native and generated-plan entrypoints. These
four pairs retain both parent and actual child engines throughout the sequence. Public serialized v2 and freshly
compiled emitted modules form two additional pairs that reconstruct per call. Each pair runs original segmentation
and composition cases twice, all child4/15 cases, four segmentation mutants and three child mutants. Call/step
denials, inert no-seed declarations, detached results, exact local/rebased spans and subsequent acceptance are
separate assertions. Complete successful enriched values match across the five in-process pairs; the fresh pair
uses the same authored oracles rather than a cross-process full-response-equality claim.

The child callback only invokes its precompiled carrier and projects the child's own span. Child exits retain
typed status1. Staged failure codes are exact through native/generated execution wrappers; Rust's wrapper objects
are not Perl's staged error class. The emitted host loads ten modules (three originals and seven mutations), checks
their metadata/plans and must execute all three child tests successfully.

```sh
bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml \
  -p linkedspec-runtime --test nested_tree_readiness lossless -- --nocapture
```

The `.3.4.1` checkpoint records focused and direct-dependent results. No production/runtime, generated format or
authority changed. Existing startup `.73` target reservation, `.74` returned-marker validation, `.75` saturated call
counter and `.78` older consumer path portability obligations remain separate; this corpus uses distinct targets,
plain child ASTs and small counters. Dart `.3.4.2`, Julia `.3.4.3` and both Lua ABIs `.3.4.4` follow before canonical
parent reconciliation `.3.5`.

## Dart matched carriers — .3.4.2

`dart/test/nested_tree_readiness_test.dart` registers the shared `dart_carriers.dart` consumer under the existing
lossless-child fixture directory. The original `.spec` and JSON files remain exact. Compiled and `SpecFile`-JSON
reconstructed engines each execute natively and through generated plans, followed by public v2 and fresh emitted
entries. Four pairs retain engines; two create per-call engines. All run the thirteen original/enriched cases twice,
child4/15, four segmentation mutants and three child mutants.

Dart's public staged entry returns an AST; its outcome sink separately exposes the complete detached execution
record. The consumer independently compares both, exact callback requests, scalar slices, local/global spans,
sidecar identities/paths, fresh caches and selected resource counters. Returned child data and sink-exposed source
spans are mutated before a subsequent exact success. A failure publishes neither an AST result nor a completed
outcome. Exact staged codes survive the supported wrapper types; strict child rejection uses typed status1.

Five in-process pairs compare complete successful outcome records. The fresh package copies the exact shared
checker, carrier producer and original independent JSON utility into matching relative directories, analyzes them
and all ten emitted modules
with fatal infos/warnings, then must return the exact modules/corpus/mutation completion report. It resolves existing
dependencies offline and reuses the current test allocator. The source helper outside the Dart package is analyzed
through its main test import and the fresh package, respecting the known package-context requirement.

```sh
cd dart
bash ../tools/run_dart_project_data.sh test --reporter expanded \
  test/nested_tree_readiness_test.dart --name lossless
```

Focused2 and the full selected88-test readiness/staged/gap/emitter/document set pass. Main-test fatal analysis,
fresh-package analysis/execution, unchanged-oracle verification and book rendering pass; `.3.4.2` binds the exact
storage/neutral results and all source/log hashes. No runtime, generated format, authority or dependency changes.
DART-STARTUP-READING `.2.17` diagnostic-byte, `.2.18` extreme arithmetic, `.2.19` malformed provenance and `.2.25`
whole-package SDK obligations stay open. Authored direct spans and ordinary counters do not exercise those defects.

## Julia matched carriers — .3.4.3

The existing `julia/test/source_emitter_test.jl` includes shared `julia_carriers.jl` and `julia_checks.jl` under the
lossless-child fixture. Its managed allocation owner and fresh-host launcher remain the storage/launch boundary.
Native compiled and `SpecFile`-JSON reconstructed parent/child engines retain their instances. The public generated
v2 API on each compiled form and the fresh emitted host supply three per-call pairs, for five supported pairs total.
No private generated-family entry is treated as another supported carrier.

All five execute original/enriched13 twice, child4/15, seven mutations, scalar slicing/classification/reconstruction,
bounded requests, exact local/rebased spans, sidecars, fresh accounting and selected authority denials. Typed staged
exceptions preserve exact codes and standalone child rejections retain typed status1. Complete successful records match across
the four in-process pairs; the emitted pair executes the same independent oracle and exact completion report.

Result detachment is tested on the actual returned child text and source span, with a second already-returned
result compared to its before-snapshot and a subsequent parse checked against the original oracle. An intentionally
aliased pair must fail the identical assertion with the expected error. This separate bounded proof does not claim
to repair JULIA-STARTUP-READING `.2.26`'s older copy-mutating general-consumer assertion.

```sh
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no \
  -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include("julia/test/source_emitter_test.jl")'
```

The new69 assertions pass alongside original emitter65/nesting30/context30, totaling194. The fresh child validates
and executes ten modules and must exit successfully with exact modules/corpus/mutation/alias-control fields.
Both the original shared JSON utility and new checker are copied unchanged into matching relative directories;
latest-world bindings and execution, strict merged-output JSON parsing, private depot and scratch cleanup remain
explicit. `.3.4.3` records direct-dependent/storage/neutral results and exact source/log hashes. No runtime, manifest,
dependency or public authority changes. Existing registry `.2.13`, diagnostic `.2.14` and isolation `.2.26` obligations
stay open before shared Lua proof and canonical parent reconciliation.


## Shared Lua matched carriers — .3.4.4

The existing `lua/test/rule_local_cursor_generated_source_test.lua` consumes shared `lua_carriers.lua` and
`lua_checks.lua` under the lossless-child fixture. The same unchanged producer/checker source executes on PUC Lua
and LuaJIT. Each ABI covers five matched parent/child routes: retained native and SpecFile-JSON reconstructed
engines, public generated v2 on both compiled forms, and a fresh emitted process on the selected ABI. The latter
three construct engines per call. Existing allocation and cleanup owners remain unchanged.

All five routes preserve original/enriched13 twice, standalone child4/15, seven grammar mutants, exact typed staged
codes and child status1. Independent UTF-8 scalar slicing verifies ordered spans, complete coverage and exact text
reconstruction beside the authored classification oracle. The child grammar performs recognition and AST construction;
host glue only invokes it and rebases its returned span. Exact callback order, source bounds, sidecars and selected
accounting are checked. Four in-process pairs agree on26 complete successful enriched records.

The actual first returned child's text/span are mutated while the second result and the next parse stay exact.
Passing one object twice must fail the same isolation oracle with the exact alias error. The fresh process loads
ten modules, validates metadata/plans, executes the same corpus/mutants/alias control and must return the exact
completion report with successful status and empty stderr. The unchanged shared JSON utility and checker are
copied into its owned workspace; verified removal follows execution.

```sh
bash tools/run_lua_project_data.sh puc lua/test/rule_local_cursor_generated_source_test.lua
bash tools/run_lua_project_data.sh luajit lua/test/rule_local_cursor_generated_source_test.lua
```

Each ABI passes222 v2 assertions (new62/existing160), staged890, gap392, and document51 cases/27 round trips/24
recoveries. Real storage passes19 owners/three dual-ABI native modules and30 census controls; neutral staged123/129
and exact book proof pass. The checkpoint binds successful logs and source hashes. No runtime, contract, native
module, fixture or dependency changes. Malformed arrays `.2.25`, diagnostic bytes `.2.26`, marker cycles/null
`.2.27`, private capture ranges `.2.28`, malformed provenance `.2.29` and seeded-count defaults `.2.8.15/.16` remain
owned by LUA-STARTUP-READING, alongside the installed-PUC baseline `.2.2` and stale guidance `.2.1`. Plain child
values, dense valid snapshots/direct spans and small counters do not close those obligations.
