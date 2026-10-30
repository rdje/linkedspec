---
id: rust-gap-string-result-guards
title: Rust gap String results use the existing actual-kind operand guards
answers:
  - "why does Rust gap_text take execute incompatible operands"
  - "which Rust owner guards gap_kind result methods"
  - "does Rust gap String recovery already work"
  - "does Rust gap String composition change getter or context state"
date: 2026-10-30
status: bounded Rust57.2 repaired/targeted-checked; full admission separate
tags: [rust, gap, string, fluent, guards]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.57.2; gap-string-result-rust-intake.json.gz retains unchanged9groups7healthy/2RED to9GREEN, record7/computed6/owned fmt and actual source/producers/inputs."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test gap_string_result"
---

Atb58198469 primitive/compatible String/direct recovery/with actual kinds/Unicode
character length and error/function/arity policies work. Shared target and direct
Array/Hash consumers bypass actual-kind guards. Engine::is_input_cursor_value_source
and is_ordinary_computed_read exclude gap_text/gap_kind. Adding just these
canonical-zero names reuses guards; getter/runtime/parser/CompiledSpec/error/
function/arity/physical state and remaining engine bytes exact.

Same9groups7healthy/2RED to9GREEN, record7/computed6/owned fmt pass. Eight value
observations/10 error batches retain native/restored CompiledSpec/generated-plan;
six healthy values/all errors byte-equal. Native primitive/default diagnostic
equality is checked in retained normal. Initial fmt1 is corrected by exact
condition whitespace with identical tokens, final fmt0; runtime proof unchanged.
Bare-variable policies stay under unmodified non-Call/other paths; no complete
legacy named-value census. Dependency warnings remain opaque/upstream-owned
RUST-DEPENDENCY-WARNING-ZERO. Rebuild apps/runtime; no isolated emitted/package,
warning-free/new state/schema/error-phase/full admission claim. Dart57.3 follows.
