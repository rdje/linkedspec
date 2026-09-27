---
id: lossless-child-readiness-authority-plan
title: Lossless child readiness separates public staged authoring from private progressive dispatch
answers:
  - "which task proves lossless segmentation and bounded child parsing readiness"
  - "does the lossless readiness probe use public parse_job or private dispatch_span"
  - "may parse_job accept gap_text or an arbitrary span in the readiness grammar"
  - "what independent oracles must the lossless child readiness corpus use"
date: 2026-09-27
status: authority plan verified; executable composed corpus pending
tags: [self-containment, lossless, gaps, staged-parsing, authority, readiness]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.1 reviews the existing gap/typed/progressive/staged contracts and passes all four neutral checkers. It selects public parse_job over recognized source-bound items while retaining gap text separately; it does not publish dispatch_span or admit gap_text as a staged operand. No runtime composition proof is claimed."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
---

# Lossless child readiness authority

The canonical plan and evidence boundary live in
`docs/language-readiness/lossless-child-parsing.md`. Exact item/gap records, independent scalar input slicing and
ordered reconstruction are distinct oracles. A precompiled child `.spec` must recognize the child language;
host authority preparation and request plumbing are not permission to implement that parser in the host.

Public exact `parse_job` assignment uses entry/match source-bound expressions and literal options. Private
`dispatch_span` carriers retain their separate authority and do not establish public authoring. Resource and
stitch-conflict defects stay with startup `.37`, `.73`, `.75` and the backend-specific owners; passing neutral
checks does not close them. `.3.2` is the next executable segmentation slice, before staged child composition.
