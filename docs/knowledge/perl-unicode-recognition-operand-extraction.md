---
id: perl-unicode-recognition-operand-extraction
title: Perl recognition and observation static callee extraction rejects Unicode rule identities
answers:
  - "why does recognize_once reject call Ω despite a declared Unicode rule"
  - "why does observe_recognition report call_expression for a Unicode static callee"
date: 2026-10-29
status: confirmed; P1 repair48.2.6.1 immediately after runtime guard48.2.6
evidence: "perl-unicode-guard-intake.json.gz retains initial public diagnostic log, current scanner and policy owners."
reverify: "Restore retained inputs and use the routed public Perl probe; owning48.2.6.1 qualifies exact independent normal RED before repair."
---

Four selected Unicode labels (Ω, Töp, decomposed Töp and töp) are rejected as
static callees by current public recognition and recursive-observation compiler
policy. The initial guard normal records all eight compile failures. This is a
separate boundary from the runtime name guard. Scanner
`perl/LinkedSpec/ActionIR/Scanner/RecognitionTransactionRules.pm` lines42/108
extracts static `call(...)` callees with ASCII letter-first patterns. Its event
therefore omits the callee; recognition policy reports
`recognition_static_rule_required`, and observation policy reports
`source_location_recursive_observation_operand` with `call_expression`.

Existing ADR0051 authorizes these rule identities. Repair48.2.6.1 is scheduled
immediately after48.2.6 and before Dart48.3/admission. Result, transaction-token
and observation-target variable identifiers remain separate grammars. No broad
frontend completion follows from either repair. The initial ASCII recognition
control had an acceptance/payload mismatch; it is not product RED. The runtime
guard selection uses the nearest known two-level transaction source instead.
