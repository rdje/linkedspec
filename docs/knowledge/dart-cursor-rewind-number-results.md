---
id: dart-cursor-rewind-number-results
title: Dart cursor rewind Numbers reuse validated character offsets and typed guards
answers:
  - "why does Dart rewind_entry_start return null despite cursor movement"
  - "which Dart owner returns rewind Number results"
  - "does Dart reject surplus cursor rewind arguments"
  - "how do Dart rewind result guards preserve absence and Unicode positions"
date: 2026-10-30
status: bounded56.3 result and56.3.0 arity repaired/targeted-checked
tags: [dart, cursor, rewind, number, fluent, arity]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.56.3; cursor-rewind-result-dart-intake.json.gz retains5RED/4healthy-positive/1legacy-preservation to10passing, gap6/computed7/analysis/new-normal format, actual producer/source/inputs."
reverify: "From dart/: bash ../tools/run_dart_project_data.sh test test/cursor_rewind_result_test.dart test/cursor_control_arity_test.dart"
---

At a4cd519cf, private rewindToLocalMatchStart/rewindToEntryMatchStart validate
anchors and move through _setCursorCodeUnit but return void; _evaluateCall
always returns null. They now return the existing cached validated Position
offset after that same physical write. Dispatch preserves tracing and exposes
only canonical-zero Number results. _isInputCursorValueSource and
_isOrdinaryComputedRead admit just the two canonical-zero names to current
actual-kind guards, including selected absent reads and with Array bridges.

Native/restored SpecFile/generated-plan same10 tests5RED/4positive-healthy/
1legacy-preservation to10passing, nearest gap6/computed7 and fatal changed-owner/
new-normal analysis/new-normal format pass. Thirteen actual results/two function
fences retain shared12, source2 before consuming7/sum9, character Unicode1/3,
zero/default laziness, rejected consumer operand skips, absence null and original
null save/restore/physical effects. First function-fence input x missed the action;
retain that epoch and correct input before product baseline, no false RED credit.

Four surplus positional/keyword rewind forms still return null and move. They
are a known defect preservation group, no supported-shape/healthy arity proof.
Immediate P1 child56.3.0 independently tests/fixes all four controls before Julia.
Rebuild apps/runtime; no new anchor/stack/schema/ordinary progress policy or
isolated emitted/full context/shape/portable admission follows.

## Current cursor arity repair

56.3.0 renames _validateGapReaderArity to _validateZeroArgumentHelperArity and
adds all four controls, keeping existing _evaluateCall function priority and
validation point before physical switch dispatch. Typed helper/count/expected0
diagnostics now reject24 invalid programs on72 routes; previously ignored
operands are still skipped, with rejection replacing acceptance. Same8groups
4healthy/4RED to8passing, parent10/gap-arity9/fatal analysis/new-parent fmt pass.
Nine preceding parent positive groups are exact, final known-bug assertion
replaced in retained epoch. Four trailing compilation errors and function/valid0/
Unicode/absence/stack/logical outputs byte-equal. Actual source/producers/inputs/
RED-GREEN retained in cursor-control-arity-dart-intake.json.gz. Earlier accepted
malformed statements describe historical result-only epoch. Julia56.4 follows.
