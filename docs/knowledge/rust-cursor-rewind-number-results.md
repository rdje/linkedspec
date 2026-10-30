---
id: rust-cursor-rewind-number-results
title: Rust rewind Numbers compose and cursor controls reject surplus arguments
answers:
  - "why does Rust rewind_entry_start return null after moving the cursor"
  - "which Rust owner returns rewind Number values"
  - "does Rust reject surplus cursor rewind arguments"
  - "which task owns Rust cursor control zero arity"
date: 2026-10-30
status: bounded result56.2 and cursor arity56.2.0 repaired/targeted-checked
tags: [rust, cursor, rewind, number, fluent, source-role, arity]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.56.2 and56.2.0; cursor-rewind-result-rust-intake.json.gz preserves the original result epoch; cursor-control-arity-rust-intake.json.gz retains phase-locked4healthy/4RED to8passing, repaired parent9/gap7/fmt and actual producers/inputs."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test cursor_control_arity --test cursor_rewind_result"
---

At55a743e0b, both typed physical rewind setters already validate/move correctly.
Engine::call_helper in engine.rs discards their successful result and returns
RuntimeValue::Undef. Three routes retain primitive ASCII[5,null,2,null,4,null,5]
and Unicode[4,null,1,null,3,null,4]. Reference Perl/frozen56 return the validated
character-based position Number. Reuse existing typed_position_offset_from_byte
projection after successful physical movement; do not change the setter/runtime
state, anchors/absence, null save/restore, error or serialized interfaces.

Existing is_input_cursor_value_source and is_ordinary_computed_read omit the two
zero-argument rewind calls, independently of their producer result.56.2 owns
canonical-zero Number result and current actual-kind/source guards. At that baseline,
malformed surplus positional/keyword forms return null and move, without typed
arity error. Preserve their legacy result during this bounded source slice with
no supported-shape credit; immediate P1 child56.2.0 fixes actual arity before Dart.
No peer failure, full domain/context/shape/portable or new cursor authority follows.

## Verified bounded result repair

Engine::call_helper now projects the existing character offset after the original
successful typed setter for canonical-zero calls. is_input_cursor_value_source
and is_ordinary_computed_read reuse existing actual-kind guards for those two
empty-argument names. All other engine/runtime/parser/setter/schema bytes exact.
Same9 tests now pass: eight positive groups, one known malformed-call preservation
group. The baseline has5RED/3healthy-positive/1legacy-preservation, correcting
initial shorthand4healthy; that passing malformed group is no healthy arity credit.
Computed6, five selected cursor units (190 filtered), owned fmt pass. Twelve
result observations/two function fences retain three routes; Unicode positions
are1/3, matching original cursor reads, rather than byte offsets. Physical state
and null save/restore stay exact. Rebuild applications with updated runtime;
no format/regeneration or isolated emitted/full admission claim. Immediate
56.2.0 repairs the four observed malformed forms next.

## Current four-control arity repair

56.2.0 adds save_cursor/restore_cursor/rewind_entry_start/rewind_match_start to
the existing validate_eager_helper_arity zero-argument set. Expr::Call keeps
pure-function parser-state priority, then validates before evaluating arguments;
call_helper shares validation before dispatch. Typed native/restored diagnostics
retain helper/count/expected0/stage; generated-plan error strings retain identity.
All20 invalid programs/60 route observations reject. Trapping operands previously
enter entry_text; now the outer helper arity fails. This plus original validator
placement establishes ordering; RuntimeDiagnostic has no cursor-after-error field.
Trailing bodies retain exact callable_contract_rejected compile phase. Four
healthy baseline groups stay byte-equal; four failing groups now pass, parent9/
gap7/owned fmt pass. Parent's last accepted-malformed assertion is replaced in a
new epoch; its eight positive groups are exact. All setup/API and trailing-phase
calibrations, final unchanged eight-group RED/GREEN and actual producers/inputs
are retained in cursor-control-arity-rust-intake.json.gz. Earlier accepted/null/
moving statements describe the historical pre-repair epoch only. Rebuild apps.
