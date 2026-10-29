---
id: perl-unicode-recognition-operand-extraction
title: Perl recognition and observation static callee extraction rejects Unicode rule identities
answers:
  - "why does recognize_once reject call Ω despite a declared Unicode rule"
  - "why does observe_recognition report call_expression for a Unicode static callee"
date: 2026-10-29
status: repaired48.2.6.1 across scanner/lowering/runtime; focused selected routes
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

## Static operand closure48.2.6.1 (2026-10-29)

Scanner extraction now parses the whole static call and applies the pinned
classifier. Two downstream ASCII restrictions were independently exposed by a
scanner-only intermediate: observation Contracts refused lowering and generated
unloadable source; recognition attempt_static raised a typed rule error at0.
Both now use the same predicate, retaining unrelated variable patterns and
diagnostics.22 sources include10 valid (2 ASCII/8 Unicode) and12 strict negatives.
All10 execute native/emitted/fresh; negatives and healthy ASCII source/metadata/
events/results stay exact. Fresh reuses2 original ASCII modules and4 retained
intermediate recognition source bodies restored to numeric artifact paths,
while4 malformed intermediate observation source bodies require
regeneration. Original Unicode compiler rejects had no usable source. New22 and
two direct neighbor58 groups pass. Selected labels are independently checked;
no coexistence or broad frontend completion. Initial fixture/projection errors
and exact intermediate outputs are retained without product failure credit.
See perl-unicode-operand-intake.json.gz for actual recoverable inputs/receipts.
Unicode label-derived filenames aliased one filesystem inode; the integrity check
refused them. All bodies were retained in per-row JSON and restored byte-exact
to16 distinct numeric files; see [[perl-unicode-artifact-filename-aliases]].
No original overwritten physical-file reuse is claimed.
