---
id: perl-callable-marker-conditional-execution
title: Perl callable marker groups execute typed branches and propagate local returns
answers:
  - "how does Perl execute marker if else endif in a callable body"
  - "does Perl marker return propagate through attached or eager blocks"
  - "why did the attached callable test stop expecting marker failure"
  - "does Perl validate unreachable marker controls before an early return"
date: 2026-10-03
status: marker executor verified; while successor verified; boolean literal owner separate
tags: [perl, callable, actionir, marker, control, return]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.2 tracked public native/fresh source matrix, actual pre-fix runtime and documented PUC CLI comparisons."
reverify: "prove -Iperl t/codeblock_marker_if_perl.t; current successor replay: bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.5-review.py. Earlier full reviews are historical because old loop failures are superseded."
---

The private marker collector reads typed sibling statements, counts nested marker if/endif
pairs and shields attached sibling arms from the outer marker branches. It validates reached
group closure/order before evaluating conditions, then evaluates conditions once until selection.
A private action-block view runs only the selected body through the existing sequence/return flag.
Marker/attached bodies propagate return; callable and eager expression boundaries consume it.
A completed statement group without return yields null. Typed records/signatures/contexts stay exact.

The public PUC CLI agrees on final marker null, rejects missing closure/duplicate fallback,
and preserves early-return skipping of an unreachable extra endif. This comparison neither adds
whole-body syntax preflight nor admits another backend. Reachable orphan controls diagnose.
Source-poisoned public AST invocation, original x/rest slots/array and equal-value controls,
actual helper/error identities and native/fresh observations distinguish the selected semantics.

The attached test's old marker_excluded source is retained unchanged. Its current test loads
a source-identical successor oracle from .5.2 cases; the old expected failure and all .5.1 captures
remain frozen atfd022815. Running the old full .5.1 reviewer against later runtime is inappropriate.

A return(false) literal control initially exposes the indexed startup35 kind drift: numeric0,
not JSON false. Exact before-bool source/observations survive; the final marker test passes a typed
false argument and returns its parameter, preserving boolean kind and proving falsey return.
No boolean evaluator repair is hidden in this leaf. Value if/else, empty return/return_undef,
while, function MVP, event ordering/readiness and dispatcher/full16 remain independent owners.

Value `.0.5.3` now executes canonical lazy value conditionals; the old failure evidence
remains historical. See [the value executor card](perl-callable-value-conditional-execution.md).

Null-return `.0.5.4` now closes the private empty-return/return_undef gap. Earlier failures
remain historical; see [the null-return card](perl-callable-null-return-execution.md).

## October 3 while successor

Typed attached while now executes under `.0.5.5`; the former loop failure described above
is retained history. Current tests replace only its exact source-identical oracle; old
observations/producers remain unchanged. The while fact card owns guard/local-return semantics.
