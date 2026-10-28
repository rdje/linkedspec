---
id: perl-emitted-ordinary-recursion-guard-gap
title: Standalone Perl handlers now share native ordinary non-progress recursion protection
answers:
  - "why does blind fluent push hang in a standalone Perl parser"
  - "does blind fluent push append the child result or call the parent"
  - "why does native Perl terminate a direct cycle while emitted source recurses"
  - "which owner repairs ordinary recursion guard parity in generated Perl"
date: 2026-10-28
status: shared native39.6.1 and emitted39.6.2 targeted-checked; full admission separate
tags: [perl, generated-source, recursion, progress, blind-call, fluent, push]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.39.6.0; blind-postcall-progress-authority.md and retained intake contain actual current92a6eeb95 bounded3 cases,2 fresh timeouts and1 completed pair, substitutions and source/phase/trace closure."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/emitted_rule_progress_guard.t t/shared_rule_progress_guard.t; historical timeout producers require their retained base Git inputs."
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

39.6.1 now extracts ordinary entry/release to RecognitionTransactionRuntime.
SpecEntry delegates and explicitly releases after eval; idempotent destruction
preserves caller error and opaque thrown-object identity. Before8 public groups
pass/shared4 skip; final12/no skips and syntax2 pass. Key/sentinel and typed
reject order stay, trace topic stays but debug file attribution follows runtime.
Get bootstrap compilation also uses native handlers; reset handoff probes after
Get to count only invocation. Exact epochs: shared-rule-progress-intake.json.gz.
Standalone ordinary cycles still need39.6.2; no generated completion claim.

39.6.2 now wraps all emitted CODE entries once after descriptor construction.
Final unchanged13 groups5 fresh timeout RED/final13pass; nearest sparse15 and
syntax2 pass. Exact12 actual source pairs differ only by registration and all
metadata stays identical. Native SpecEntry unchanged; call context, aliases,
opaque error identity and cleanup preserved. Packet:
emitted-rule-progress-intake.json.gz. Regenerate old standalone sources;
updating runtime alone does not add the registration. Broad admission separate.
