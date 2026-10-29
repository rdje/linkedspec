---
id: dart-blind-fluent-parent-push-gap
title: Dart blind fluent push incorrectly requires an action-edge child context
answers:
  - "why does Dart blind push require an action edge child context"
  - "which task implements Dart blind fluent push parent calls"
date: 2026-10-29
status: confirmed; P1 repair48.3.1 immediately after validator48.3
evidence: "dart-referenced-intermediate-intake.json.gz retains original/qualified28-row baseline, repaired-validator runtime diagnostics, compiled action payloads and full normal RED."
reverify: "Recover retained Dart probe and use the project-routed Dart wrapper; preserve original parent-LX runtime exclusions and qualified counterparts."
---

After the validator permits declared no-regex blind targets, three qualified
runtime sources fail native, JSON-restored and generated-plan execution with
`push() in rule Top requires an action-edge child context`. These are
blind_no_regex, marked_blind_target and markerless_blind; four other runtime
controls pass. The earlier compiler rejection hid this independent runtime gap.

`_executeBlindOnce` passes `currentEdge:null` to its action payload. A blind
zero-argument fluent push reaches `_callPush`'s empty-argument branch, which
requires an action child via `_requireCurrentEdgeChild`. Existing reference
authority injects the parent rule as the callee; it does not append the prior
child result. Repair48.3.1 is scheduled immediately after validator48.3 and before
Julia48.4/admission, using the frozen parent-push target and direct dependents.
The validator commit retains compiler credit and only four healthy runtime
controls. The complete failing normal and actual three-route diagnostics stay
retained. Original parent-LX authority remains separate48.2.2.1.
