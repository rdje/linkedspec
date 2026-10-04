---
id: perl-residual-event-order-diagnosis
title: Residual canonical events lose occurrence order while measured consumers remain stable
answers:
  - "why do Perl residual canonical events vary under hash seeds"
  - "does sorting raw event keys preserve duplicate helper occurrences"
  - "is helper scan order the same as lexical source order"
  - "does residual event permutation change current native emitted results"
  - "why does helper-looking quoted text create false readiness blockers"
  - "which task owns quoted-payload helper metadata repair"
date: 2026-10-03
status: historical diagnosis at bf1e4edd; .0.6.1 is the current order-repair successor; readiness remains open
tags: [perl, actionir, metadata, nondeterminism, provenance, readiness]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0 retains27 source-bound native/fresh observations, six original public captures,15 public substitution traces, four complete suites/34 top-level TAP tests and ten observed evidence corruptions."
reverify: "Use .0.6.0 reviewer only at captured bf1e4edd inputs. Current repair evidence: bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1-review.py. Never rerun historical original-order.py."
---

At cleanbb615f387, CanonicalEvents::_build_canonical_action_ir_events queues helper events
by trimmed raw text, consumes authored top-level statements, then drains remaining queues
through unsorted keys (line249). The nested/body/repeated/raw_ambiguous cases retain different
residual sequences across three fixed seeds with perturbation2. All complete raw arrays survive.
Event-kind summaries alone hide swapped RETURN payloads. Equal text still has distinct
occurrences; the repeated scan input has return(a),return(b),return(a) in that order.

Diagnostics::_collect_action_helper_ir_nodes assembles each contract's scan in registry
precedence order. This input is stable in the measured population, but is not global lexical
source order. The bounded selected repair preserves top-level/exclusive ownership and appends
each still-pending residual occurrence in scan provenance order. A flat occurrence sequence
alongside existing queues avoids raw-key regrouping without inventing public span/ordinal fields.
Only CanonicalEvents production is selected for .0.6.1; scanner/AST/schema/value semantics stay
outside this repair. Canonical proof is required before that compiler slice lands.

RewritePipeline::lower_action_code_from_canonical_ir consumes this array with a source cursor.
Fifteen traces show body/repeated residuals missing its cursor (3/5 decisions), two ambiguous
raw residuals taking the overlap skip path, and one unambiguous raw residual being rewritten.
Every measured source keeps substitution/dump/emitted/AST bytes, metadata counts/readiness
and native/fresh values stable. Raw compatibility returns inner/other are host observations,
not a portable unknown-helper or return-in-argument admission. These exact controls do not
establish arbitrary-overlap equivalence or a statistical nondeterminism frequency.

Quoted control Top:: I { return("return(inner); if(true)") } has a typed string argument and
returns its exact literal on both routes, but reports residual IF if(true), unresolved3 and
ready0. Its public trace reaches unmatched rewrite and unresolved diagnostics. P1 .0.7.2 owns
quote-masking diagnosis/repair before dispatcher closeout, independently of order. The known
nested i=i+1 control still reports ready1 yet returns1 with host bareword warnings; .0.7.0/.1
owns that false-ready mechanism. Neither result is normalized or promoted to portability.

The read-only reviewer checks exact raw stdout/parsed correspondence, source/generated hashes,
ordered helper provenance, canonical event multisets, counts and runtime expectations, retained
traces and complete TAP. Ten evidence corruptions reject, including erased permutation,
missing occurrence and removed consumer decisions. They are report controls, not runtime mutants.
All tracked Perl/spec/test input bytes equal activation Git blobs; no executable change occurs.

Current succession: `.0.6.1` preserves pending occurrences using an ordered list alongside
raw-key queues. See [the current repair fact](perl-residual-event-occurrence-order.md).
All diagnosis arrays/streams and its historical claim hashes/results remain exact.

October4 succession: raw-expression reporting `.0.7.1` lands at
`363c79109ea8498252927547438ade47117ae71e` with exact canonical acceptance. Quoted-data
parent `.0.7.2` is split before implementation: planning `.0`, current source-bound
diagnosis `.1`, evidence-selected repair `.2`, then independent closeout `.3`.
The older quoted primitive/ASSIGN evidence is indexed by
[[perl-quoted-primitive-rewrite-event-drift]]; its broader startup owner remains open.
The next diagnosis must reverify current behavior rather than refresh historical captures.
