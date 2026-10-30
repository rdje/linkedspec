---
id: cursor-rewind-default-loop-progress-gap
title: Completed child cursor rewinds can cycle in Perl ordinary default loops
answers:
  - "why can a child rewind make a default parent loop forever"
  - "does the Perl recursion guard protect completed child rewind loops"
  - "which task owns ordinary default net progress after cursor rewind"
date: 2026-10-30
status: P1 owned39.8.2 after ordinary-progress authority39.8.1 before admission
tags: [perl, cursor, rewind, progress, default, loop, diagnosis]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.1.17 and39.8.2; cursor-effect-result-selection-intake.json.gz retains original143/bounded142/scoped-runtime124, exact native debug cycles, corrected explicit-return native/fresh controls and actual producers/inputs."
reverify: "Recover original scoped-runtime diagnostic from retained intake; build quiet with cold bootstrap allowance, trace runtime only and enforce external/bounded execution. Never run the original unbounded probe."
---

Top:: ->Value with Value /ab/ and an I action ending at rewind origin0 repeatedly
selects ab (post-match2), completes the child at0, and matches again. The scoped
native trace observes multiple complete cycles until the one-second diagnostic
deadline exits124. It is not a native error diagnostic or a peer/fresh hang proof.
HandlerVariantEmitter::_emit_default_handler emits while(1) with no net-iteration
progress boundary. SpecEntry's active recursive re-entry guard does not prevent
completed sequential calls from repeating.39.8.2 owns the fix after canonical
ordinary minimum/count/lifecycle authority39.8.1, before full23.4/admission/push.

An explicit parent return(call(Value)) terminates and exposes actual child values
on native/fresh. An implicit parent without LX may discard child payload; its
null result cannot classify a helper result. The20-second build budget stopped in native Get construction without a stack.
A separate5-second stack was in cold function-definition parser compilation.
Neither truncated build proves a compile hang. Public standalone substitution and final explicit-return probes
preserve save/restore null and rewind Number results; no helper return change.

The June top-rule recursion card's broad ONLY-hang/per-handler-safe phrasing is
superseded by this bounded counterexample. No ordinary count/lifecycle/error
policy is changed by the value-composition selection; that authority stays owned.
