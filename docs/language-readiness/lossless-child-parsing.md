# Lossless segmentation and bounded child parsing

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3`. Authority review on 2026-09-27 from
clean `ca197a38c269cfeb89341505db83e395ebf6f308`. Perl segmentation is verified under `.3.2` and
public staged child composition under `.3.3`; other backend routes remain pending.

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
