---
id: dart-gap-reader-surplus-arguments
title: Dart gap and slot readers silently accept surplus arguments before the owned zero-arity repair
answers:
  - "why does Dart entry_slot accept an extra argument"
  - "which task owns strict zero arity for Dart gap readers"
  - "does Dart currently reject gap_span gap_text gap_kind surplus arguments"
date: 2026-10-30
status: bounded Dart55.0 repaired/targeted-checked; full shape admission separate
tags: [dart, gap, slot, arity, diagnostics, defect]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.55.3 intake at21954dcdb; gap-slot-selection-dart-arity-probe-all.jsonl retains eight authored source forms across native/restored/generated-plan. Initial two-helper probe/source retained separately."
reverify: "From dart/: bash ../tools/run_dart_project_data.sh test test/gap_reader_arity_test.dart test/gap_slot_record_selection_test.dart test/computed_selection_test.dart"
---

The four published readers entry_slot/gap_span/gap_text/gap_kind have zero
arguments. Before55.0, Dart accepts an extra positional1 on all three public routes:
entry_slot returns null; active span/text/kind readers retain their ordinary two
records, empty/comma strings and prefix/interstitial kinds. These are observed
invalid-call acceptances, not healthy arity calibration or a new supported form.

Interpreter _evaluateCall constructs argument expression nodes, validates separate
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

Source-owner erratum: Earlier55.3 intake prose named _callHelper; the actual method is _evaluateCall in interpreter.dart. The captured behavior/source bytes are unchanged.

## Verified repair55.0

A scoped zero-argument validator now runs after registered function resolution and before reader context/operand evaluation, using existing helper_arity_mismatch diagnostics. Same9groups4RED/5healthy to9GREEN retains72 malformed-call observations across native/restored/plan, valid helpers/records/text/kinds/null slot, typed context errors, function-state precedence and own function arity. Keyword surplus rejects too; existing attached codeblocks still fail compileSpec with callable_contract_rejected. New9/record6/computed7 give22 nonhidden/no-skip completions, empty stderr and new-test fatal analysis/format pass. Other interpreter/reader/state/schema bytes stay exact. Actual producers/normal/probes/inputs/results are retained in gap-reader-arity-dart-intake.json.gz. Julia55.4 is next; no broader invalid-program or portable admission.
