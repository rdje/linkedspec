---
id: perl-callable-null-return-execution
title: Perl callable null returns stop the local statement sequence
answers:
  - "does Perl callable return() stop with null"
  - "does return_undef() exit a Perl callable or eager block"
  - "why do conditional tests no longer expect empty return failures"
  - "does a raw direct return prove typed portable return arity"
date: 2026-10-03
status: current private null-return executor; while and raw readiness remain separate
tags: [perl, callable, return, null, actionir]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.4 exact native/fresh sources, baseline runtime, typed source-poison/identity controls and published PUC CLI comparisons."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.4-review.py"
---

The private statement sequence now accepts zero or one payload for return and
zero effective arguments for return_undef, with the existing optional bare scope label.
It validates arity before argument effects, returns null with the local return flag,
and propagates that flag through selected attached/marker branches. Callable and eager
expression boundaries consume the flag; an eager null exit lets its caller continue.
One-payload false/null/container values and original x/rest slots/array/error identity
remain intact. No source text is reparsed or public carrier changed.

Public direct-action return()/return_undef()/return(undef) all skip a later unknown helper
and yield null. The first and multi-argument return probes stay raw Perl in generated
handlers with readiness0 and unchanged substitution. Their last-argument/native results
are not typed portable arity or tagged-return admission. The readiness observation is
for the whole action, which includes an unknown-helper sentinel; it does not isolate
return readiness. Unchanged substitution/dumped source delimit the raw controls. Canonical return_undef lowering
accepts zero args or a bare scope label; its value-helper argument use stays unsupported
in this private evaluator. While, function statement MVP, boolean literal kind, metadata,
raw readiness and dispatcher/full execution remain separately owned.

Old attached/marker/value zero/null-return sources and producers remain unchanged. Current
tests load source-identical success oracles; the value claim is historical at e133707f.
Use the current focused tests or this successor review rather than an old full reviewer.
The stale values-and-flow book paragraph is corrected to reflect already working value
conditionals and these null returns. Source-bound rendered examples check that teaching.
