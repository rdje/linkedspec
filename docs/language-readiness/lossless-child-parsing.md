# Lossless segmentation and bounded child parsing

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3`. Authority review on 2026-09-27 from
clean `ca197a38c269cfeb89341505db83e395ebf6f308`; executable composition proof is pending.

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
