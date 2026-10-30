---
id: rust-cursor-rewind-number-results
title: Rust rewind position results and canonical source roles need independent completion
answers:
  - "why does Rust rewind_entry_start return null after moving the cursor"
  - "which Rust owner returns rewind Number values"
  - "does Rust reject surplus cursor rewind arguments"
  - "which task owns Rust cursor control zero arity"
date: 2026-10-30
status: bounded canonical-zero56.2 repaired/targeted-checked; immediate arity56.2.0 pending
tags: [rust, cursor, rewind, number, fluent, source-role, arity]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.56.2; cursor-rewind-result-rust-intake.json.gz retains5RED/3healthy-positive/1legacy-preservation to9passing, computed6/selected cursor5/owned fmt and actual source/normal/producers/inputs. Legacy malformed-call passing controls are no healthy arity credit; immediate owner56.2.0 follows."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test cursor_rewind_result"
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
canonical-zero Number result and current actual-kind/source guards. Current
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
