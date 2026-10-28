---
id: perl-emitted-ordinary-recursion-guard-gap
title: Standalone Perl handlers omit the native ordinary non-progress recursion guard
answers:
  - "why does blind fluent push hang in a standalone Perl parser"
  - "does blind fluent push append the child result or call the parent"
  - "why does native Perl terminate a direct cycle while emitted source recurses"
  - "which owner repairs ordinary recursion guard parity in generated Perl"
date: 2026-10-28
status: owned39.6.1 shared extraction and39.6.2 emitted wiring before independent peers
tags: [perl, generated-source, recursion, progress, blind-call, fluent, push]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.39.6.0; blind-postcall-progress-authority.md and retained intake contain actual current92a6eeb95 bounded3 cases,2 fresh timeouts and1 completed pair, substitutions and source/phase/trace closure."
reverify: "Recover bounded probe, cases, runner and strict summary from blind-postcall-progress-authority-intake.json.gz; use project_data_run.sh/run_python_project_data.sh with retained per-phase hard limits. Never run known hanging fresh cycles unbounded."
---

Blind fluent rendering injects the parent label. push(rule) intentionally calls
that rule and appends to the current accumulator. Thus Top =>Value .push calls
Value via the Core-owned bridge, then recursively calls Top through push(Top).
Preserve this existing meaning; do not invent child-value append semantics.

At clean92a6eeb95 native blind push returns[BODY]/4 and direct cycle null/0;
both emitted fresh paths time out after5s. A no-tail blind control agrees on
[BODY]/4. Native SpecEntry guards active descriptor/rule/cursor before entering
the handler, forwards typed rejection under recognition/observation scopes and
releases entries after eval. Compiler emits raw CODE entries without that
ordinary wrapper. Existing typed InvocationGuard does not cut unscoped cycles.

39.6.1 extracts the current guard to one shared runtime owner;39.6.2 wraps every
emitted rule once at descriptor construction. Preserve key, typed rejection,
trace topic, error/control/result identity, cleanup and consuming recursion.
Exact current inputs/producers/source/phases and incomplete2 are retained; no
new policy/format or broad admission. [[top-rule-recursion-forward-progress-guard]]
is dated native mechanics, not proof that standalone ordinary cycles terminate.
