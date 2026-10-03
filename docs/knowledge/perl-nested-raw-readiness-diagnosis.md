---
id: perl-nested-raw-readiness-diagnosis
title: Nested unsupported source survives lowering while top-level telemetry reports ready
answers:
  - "why do nested raw expressions report language agnostic ready"
  - "which branch passes unsupported i+1 through Perl lowering"
  - "are condition and args raw AST nodes separate source occurrences"
  - "how should repeated equal text raw expressions be counted"
  - "do source comments falsely block Perl readiness"
  - "what owns the nested raw readiness repair"
date: 2026-10-03
status: diagnosis verified; repairs pending
tags: [perl, actionir, readiness, raw-perl, provenance, comments]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0 retains16 sources/48 native-fresh pairs,16 actual traces,42 top-level TAP tests and twelve actual evidence corruption rejections; public reference identity distinguishes shared aliases from distinct repeated spans."
reverify: "At the recorded diagnostic revision, run bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0-review.py; producer/input identities are bound in its claim. Later compiler repairs require historical replay rather than refreshing these captures."
---

The public action AST at clean activation `834e0a3dd` marks `i+1` or `i < 1`
as `raw_perl` with reason `unsupported_expression`. Seven measured sources place
that raw child in an assignment, if/while condition, call argument, array element,
hash value or deferred body. All report ready1/raw dependency0/fallback0/unresolved0
and empty raw/blocker lists across three fixed seeds. These are21 missed
source/seed pairs, not a probability estimate. Canonical num_add/num_lt controls
produce the intended typed values without raw AST children.

For `i=2; i=i+1; return(i)`, the real trace reaches FlowExpr.pm:415
`passthrough_no_call`, then ValueExpr's `flow_composite_value`. Both canonical
raw fallback decisions are skipped. AST/Parser.pm:289 produces the unsupported
node; CanonicalEvents.pm only counts unmatched top-level statements.
RuleIR/EmitContext.pm:1558 collects raw text only from canonical RAW_PERL events,
and :1630 derives raw dependency count from their fallback count. Readiness at
:1637 tests that count and unresolved helpers, hiding these descendants.

Six infix sources retain actual host bareword/numeric warnings and values1,
yes, yes,3,[1],{"n":1}. These are compatibility observations, not admitted DSL
results. The deferred body produces `unsupported_codeblock_actionir/raw_perl`;
native context and fresh generated failure adapters retain the same actual
exception object. Native evaluation emits two timestamped DUMP_NONE failure
trace records from SpecEntry.pm:421; the captures keep every byte.

Actual public reference identity proves an if/while condition and args[0] share
one node. Their two serialized representations are one source occurrence.
Conversely, `i=i+1; i=i+1` has two distinct nodes/spans2–5 and9–12. This fragment
is AST-only, with no additional native/fresh route. Source-unit/span provenance
must preserve repetitions while avoiding aliases and children already covered
by a containing raw statement. Unique blocker text is not an occurrence count.

Desired comment data remains an independent failing oracle: an ordinary LF
comment `# i=i+1; i < 1` returns ok yet becomes raw AST source and ready0/raw1/
fallback1. `.0.7.3` owns that classification separately from `.0.7.2`'s correctly
typed quoted string with phantom helper/control events. Deferred/function
comment variants are unassessed. No blanket raw-node waiver is selected.

`.0.7.1` owns original-source diagnostics, accumulation and deterministic
readiness/blocker reporting at EmitContext. Existing canonical fallback/event
meaning, lowering and runtime/source bytes must remain intact. Shipped-spec and
all caller-surface census, actual RED/GREEN and warranted canonical signoff
precede landing. This diagnosis changes no production, AST/event schema,
authority, grammar, dependency or backend. Dispatcher/full composition and
complete language admission remain unassessed here.
