---
id: perl-lossless-segmentation-readiness
title: Perl lossless extraction retains public-entry prefixes and uses default-loop finalization
answers:
  - "how does the readiness grammar retain every original input scalar"
  - "why did the published lossless gap example return null instead of segments"
  - "does List OR execute the LX gap finalizer"
  - "which test proves native and emitted lossless segmentation readiness"
  - "can reconstructing all input hide a wrong item gap classification"
date: 2026-09-27
status: bounded evidence preserved; cross-runtime milestone reconciled under .3.5
tags: [perl, lossless, gaps, readiness, lifecycle, generated-source, documentation]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.2 passes 537 top-level readiness tests: thirteen exact segmentation cases repeated on native/fresh emitted routes, independent scalar slicing/reconstruction, returned-gap detachment, four grammar mutants and exact published gap-fence proof with its original OR/LX mistake retained as a mutant. Existing nesting/context/entry cases stay unchanged."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/nested_tree_readiness.t"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/inter_match_gap_capture_perl_contract.t t/generated_source_contract.t"
---

# Lossless segmentation readiness

The corpus and exact limits live in `docs/language-readiness/lossless-child-parsing.md`. Default-loop `LX`
publishes the authored segment array. Explicit `::OR` instead takes repetition termination; the generated
`rep_acode` handler installs an `EX` tail and returns its collector. The old published `List::OR`/`LX` example
therefore returned null for empty input and null-valued collectors for words despite all-ready ActionIR metadata.
The corrected book fence and its old-mode mutant execute through both native and fresh emitted Perl.

Public entry skips some leading blank/comment lines without deleting source text. The grammar explicitly keeps
that initial range as `entry_prefix`, then retains every loop gap and selected item. This composes the known
entry behavior with lossless extraction; it does not change preprocessing.

Reconstruction is necessary but insufficient: a selector mutant can classify `[0]` entirely as gap text and still
reconstruct it. Exact independently authored classifications/spans and source slicing detect different defects.
No child-parsing or other-runtime result is inferred from this Perl-only evidence.

[[lossless-child-readiness-reconciliation]] records the completed bounded matrix and authoring costs; historical leaf evidence and open defect limits remain unchanged.
