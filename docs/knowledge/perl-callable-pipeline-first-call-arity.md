---
id: perl-callable-pipeline-first-call-arity
title: Perl callable first pipeline signatures reject before host code and effects
answers:
  - "why did a function receiver split_each call an undefined private helper"
  - "how are malformed initial callable pipeline signatures rejected on Perl"
  - "does invalid callable trim_each arity execute source or later with effects"
  - "which Perl callable result defects remain after the arity prerequisite"
date: 2026-11-11
status: bounded first-call repair focused-checked; result79.6.1.2 remains pending
tags: [perl, functions, pipeline, arity, readiness, effects]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.79.6.1.1; docs/checkpoints/array-pipeline-callable-arity-perl-2026-11-11/REVIEW.md retains125 normal groups/18 receiver RED/private exact old-current control,107 stable projections, original178/169 preserved/nine arity changes,678 actual source pairs, direct6+66/31 artifacts, first readonly0/eleven controls/current121 identity."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/array_pipeline_callable_arity.t"
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P docs/checkpoints/array-pipeline-callable-arity-perl-2026-11-11/review.py"
---

Legacy pipeline synthesis manufactured private __array_value helpers after failed
argument normalization. Nine malformed terminal function-receiver forms reported
ready despite seven compilation failures/two undefined private-helper calls.
Corresponding terminal free helpers already reject null/no effects/unready.

Ten lines in MethodLowering's existing early fluent-shape validation reuse the
aggregate signature table with one implicit source operand. Only the first
canonical pipeline call on a registered function receiver is selected. The
existing unsupported marker names the public helper and rejects the entire
receiver expression before source/operand/later continuation effects. Aliases,
other receiver roles, source getters, signatures and formats remain unchanged.

All125 normal groups pass; the identical private load path reproduces18 RED
groups with old bytes and125 passing with repaired bytes.107 other projections
and84 initial/with plus14 valid Array controls remain exact. Original178 replay
changes only nine malformed receiver arities;169 other projections include the
still-owned25 result/readiness gaps. Malformed composed free forms remain unready
excluded observations, not new source or rejection authority.

All678 module/handler pairs, full observed fields/commands/channels, before-use
inputs and direct31 API artifacts survive. Direct6+66 and syntax pass. First
readonly0/empty stderr/eleven controls and current121 source identity pass.
Historical recovery needs no latest SDK. Full native/cache/transitive/toolchain/
context/isolation/registration/declared5.4/full23.4 remains separately owned.
Regenerate older emitted Perl; next re-acquire178 and repair result79.6.1.2.
Related: [[perl-callable-pipeline-intake-and-arity]].
