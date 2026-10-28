---
id: repeated-and-falsey-group-acceptance
title: Repeated AND needs group acceptance separate from its action result
answers:
  - "why does repeated AND returning zero stop after one group"
  - "can a falsey repeated AND action result be confused with a miss"
  - "what prerequisite blocks Rust repeated AND return parity"
  - "does an early repeated AND action return skip the rest of the group"
  - "does custom IT replace repeated AND default collection"
date: 2026-10-28
status: confirmed P1 reference39.7 before Rust39.1.3; lifecycle omission separately owned
tags: [perl, rust, and, repetition, falsey, returns, acceptance]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.39.1.3.0; rust-and-returns-reference-intake.json.gz retains10 public sources/16 native-fresh value/cursor/error pairs and actual emitted source."
reverify: "Recover and run the retained probe_rust_and_returns_reference.pl through tools/project_data_run.sh with PERL5LIB empty and -Iperl; it is diagnostic, not an acceptance gate. Normal39.7 regressions will gate the fix."
---

For Value::AND{2} with /H/, /cat/ and final action return0/empty/undef,
HcatHcat yieldsnull at4 on native and fresh generated Perl. Returning BODY
instead yields[BODY,BODY] at8. The inner emitted AND coderef returns the raw
payload; REP_AND_ACODE calls result_is_match, whose ordinary non-recognition
fallback tests truthiness. No separate group outcome distinguishes an accepted
falsey value from a real matcher miss. This is a defect, not portable policy.

Immediate P1 owner39.7 must separate local accepted-group state from payload,
preserve0/empty/null/Bool false kinds, real misses/minima/reset/early unwind,
progress and recognition errors. Do not widen the global predicate, infer
acceptance from sticky previous matches, or change serialized schemas. Then
resume Rust39.1.3. Existing plain action falsey values and typed recognition
already distinguish result value from match status; no new user decision needed.

Truthy early return at H on HH skips the remaining cat slot and yields
[[H,1],[H,2]] at2; HcatHcat then misses minimum at1. IT still runs after an
accepted early return and a return from IT exits the whole rule. Custom IT
replaces the default collection push. Full nonreturn groups yield[[],[]].
The same public probes show LS/LE hooks omitted: HandlerVariantEmitter's
_build_rep_and_acode_variant drops lscode/lecode from supplied arguments before
_emit_and_acode_seq_handler could consume them. The existing
P1 SESSION-STARTUP-READING.27 owns that lifecycle defect before admission.
Do not copy that omission into Rust. No production fix or broad parity claim.
Related: [[rust-sparse-and-required-step-gaps]], [[perl-sparse-and-structural-slots]].
