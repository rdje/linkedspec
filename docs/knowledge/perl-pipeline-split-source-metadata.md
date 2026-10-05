---
id: perl-pipeline-split-source-metadata
title: Split metadata reports normalized planner expression with compatible legacy fallback
answers:
  - "what does split_array args source contain now"
  - "how is the null split source metadata defect repaired and verified"
  - "does split source metadata repair change generated parser code or source origins"
  - "how do canonical and legacy planner source fields take priority"
date: 2026-10-05
status: focused correction verified; exact staged canonical receipt gates public diagnostic landing
tags: [perl, actionir, scanner, metadata, pipeline, source-provenance]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.1 supplies two3991-file before/after boundaries/23 actual commands; same8-group metadata fixture is RED5/GREEN8, regex13 and seven consumers701 pass. Three seeds retain72 source occurrences/origins across8 cases plus original19-contract207 events/135 frames/99 regex origins per epoch. Only normalized source metadata changes; complete substitutions/dumps stay exact. Twenty-five evidence and ten render corruptions reject."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.1-review.py"
---

PrimitivePipelineRules split_array now uses last_op.source_expr // last_op.source_symbol.
The public default planner publishes source_expr: bare input normalizes to $input; quoted
literal and compound expressions retain their trimmed expression text. A supplied legacy
callback with only source_symbol preserves its previous value. Defined canonical text
has priority, including "0"; undefined canonical text falls back to the older field.
Unknown source fields remain null rather than inventing a value. Public event keys, raw,
target/delimiter, original event/argument references and exact scalar origins are unchanged.

The independent literal oracle covers three default source expressions and five callback
variants, with repeated Unicode/CRLF/quoted syntactic occurrences. Source intervals are
constructed cumulatively; no event-derived raw search chooses an occurrence. Complete
Toolbox substitution, descriptor and generated parser records cover the three default
cases; helper/canonical descriptor source values change exactly as specified, while all
other descriptor fields and complete substitution/dump bytes stay identical. Original
nineteen-contract mixed scans preserve all callback plans, origins and arguments except
split's declared source value. This is diagnostic expression text, not a new DSL form or
native-execution admission.

Inputs derive from immutable95e6a02935155b9ab7b5c30f79a3275529b803da:3986 regular Git
members/five authored overlays before;3984 unchanged regular members/seven overlays after.
Only actual PrimitivePipelineRules and its current regex expectation fixture replace Git
members; all new oracle/case/probe/fixture/original-owner overlays remain identical. These
are conservative supplied-input supersets, not minimal observed IO graphs. All actual
command channels and byte/mode/population guards remain retained. Gitlinks/nonregular
metadata are excluded without payload inspection; host tools are read-only and project
scratch stays repository-local on the same volume. Original null observations remain
historically unchanged. Canonical receipt is required before landing; eight statement
contracts .1.2.2 and full family .1.2.3 stay separately owned.
