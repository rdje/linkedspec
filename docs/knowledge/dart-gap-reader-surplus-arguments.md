---
id: dart-gap-reader-surplus-arguments
title: Dart gap and slot readers silently accept surplus arguments before the owned zero-arity repair
answers:
  - "why does Dart entry_slot accept an extra argument"
  - "which task owns strict zero arity for Dart gap readers"
  - "does Dart currently reject gap_span gap_text gap_kind surplus arguments"
date: 2026-10-30
status: confirmed defect; P1 repair55.0 immediately after Dart55.3 before Julia55.4
tags: [dart, gap, slot, arity, diagnostics, defect]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.55.3 intake at21954dcdb; gap-slot-selection-dart-arity-probe-all.jsonl retains eight authored source forms across native/restored/generated-plan. Initial two-helper probe/source retained separately."
reverify: "Recover the exact arity probe from gap-slot-record-dart-intake.json.gz; from dart run the project Dart wrapper with --packages=.dart_tool/package_config.json and the repository-relative recovered script. Historical observations remain fixed after repair."
---

The four published readers entry_slot/gap_span/gap_text/gap_kind have zero
arguments. Current Dart accepts an extra positional1 on all three public routes:
entry_slot returns null; active span/text/kind readers retain their ordinary two
records, empty/comma strings and prefix/interstitial kinds. These are observed
invalid-call acceptances, not healthy arity calibration or a new supported form.

Interpreter _callHelper constructs argument expression nodes, validates separate
diagnostic/logical helper arities and resolves user functions. Its four gap/slot
branches then ignore the argument list and read context without a zero-arity
check. Rust's existing zero-reader validation independently rejects surplus
record-helper arguments. No runtime gap-state or dependency defect is inferred.

Owned P1 TYPE-REFERENCE-BOOK.1.2.23.3.55.0 follows the focused Dart55.3 guard commit
before Julia55.4. It must reuse existing typed arity diagnostics while preserving
function-resolution/state-fence precedence and valid source/context/effect
behavior. The55.3 selected-kind guard admits only canonical zero-argument calls;
it neither promotes nor normalizes these malformed source forms. Full invalid-
program/error-phase parity remains separate from this finite defect.
