---
id: dart-rule-invocation-accumulator-gap
title: Dart retains a conventional rule accumulator across invocations without an explicit reset
answers:
  - "why does a Dart no regex coordinator return duplicate x values"
  - "which task scopes the Dart conventional rule accumulator on invocation entry"
date: 2026-10-29
status: confirmed; P1 repair48.3.2 immediately after parent-push48.3.1
evidence: "dart-blind-parent-push-intake.json.gz retains actual full referenced normal and native/restored/plan duplicate outcomes after parent-push repair."
reverify: "Recover retained public Dart probe and full normal under an owning leaf; rule_invocation_accumulators.json distinguishes implicit, direct-twice and explicit-reset cases before scope repair."
---

After parent-push is fixed, the three qualified coordinator sources
blind_no_regex, marked_blind_target and markerless_blind return `[["x"],["x"]]`
on `x` instead of `[["x"]]`. The complete public source/compiled/result artifact
and normal retain this separate runtime failure; parent-push13 controls pass.

`enterRuleLocalBindingScope` creates an empty snapshot map at rule entry. The
rule's conventional array is not initialized there, so its next invocation can
read the preceding contents. Existing explicit reset/initializer scope is
deliberately narrower and preserves other undeclared caller-visible mutation;
see [[dart-recursive-dispatch-rule-local-scope]].48.3.2 owns the focused rule-name
accumulator repair immediately next, using the existing three-source target.
It must preserve other variable bindings/kinds/restoration and remove the three
explicit runtime normal exclusions only after qualification. Original parent-LX
authority remains separately owned48.2.2.1.
