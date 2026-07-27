---
id: complete-current-mark-inventory-gap
title: Seven documented named-mark helpers were admitted after exposing a symmetric inventory gap
answers:
  - which current named mark helpers are missing from backend inventories
  - why does the 239 name coverage checker miss current mark helpers
  - what are the sixteen Perl contract names outside the backend inventories
  - are mark entry start and mark match start portable
  - who owns complete named mark parity
date: 2026-07-13
status: resolved
tags: [actionir, capture, marks, inventory, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.17.0 compares identifier-shaped Perl contract diagnostics with the aligned Dart/Julia/Lua 239-name inventories and classifies seven public current marks plus nine compatibility/legacy/internal names. FUTURE-PARITY-BACKLOG.17.1-.17.4 align all five backends. FUTURE-PARITY-BACKLOG.17.5 admits the seven at 246 shared names; tools/check_language_capability_coverage.pl now combines 105 corpus fixtures with the exact named-mark fixture, independently checks 122 public Perl contracts, and rejects the nine classified exclusions."
reverify: "bash tools/run_python_project_data.sh tools/check_complete_named_mark_contract.py && perl tools/check_language_capability_coverage.pl --report && rg -n 'mark_entry_start|mark_entry_end|mark_match_start|mark_match_end|mark_line|mark_col|clear_mark' perl/LinkedSpec/ActionIR/Contracts.pm docs/linkedspec-book/src/dsl/source-boundary-helper-reference.md lua/src/linkedspec/action_call_names.lua dart/lib/src/action/action_contracts.dart julia/src/action/ActionContracts.jl"
---

# Complete Current Mark Inventory Gap

Seven public helpers were documented as part of the current named-mark family and implemented by the Perl
reference, but were absent from the aligned 239-name Dart, Julia, and Lua inventories:

- `mark_entry_start` and `mark_entry_end`;
- `mark_match_start` and `mark_match_end`;
- `mark_line` and `mark_col`; and
- `clear_mark`.

This is not evidence that every Perl diagnostic name belongs in the public current inventory. The full comparison
contains nine other names: `entry_named_map` and `match_named_map` are documented compatibility aliases; `capture`
and `capture_macro` are legacy; and `array_append_operator`, `array_end_mutation_method`,
`hash_index_assignment_operator`, `scalar_assignment_operator`, and `value_drop` are internal lowering operations.

The former coverage gate began with the aligned backend inventory and reverse-checked only current Perl calls
discovered in the corpus. It therefore prevented an inventory-only extra and a corpus-visible omission, but not a
public call omitted by every inventory and fixture. `.17.5` separates discovery from occurrence: the checker
independently derives 122 public Perl contracts, locks nine non-public exclusions, and uses the exact named-mark
fixture alongside 105 corpus fixtures. Lua capture leaf `.4.3.7.3` consumes that shared resolution.

`.17.1` supplies the exact seven-helper contract and aligns Perl plus Rust live/generated execution. `.17.2` and
`.17.3` align Dart and Julia native/generated-plan/emitted-state/CLI execution; Lua `.17.4` consumes the same
native/serialized result on both ABIs. `.17.5` admits the exact seven into all three shared inventories at 246
names. A simultaneous `clear_mark` deletion from all three is caught by both exact-family and independent-public
checks, proving the symmetric gap is closed.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.17`.
- Initiating Lua audit: [[lua-capture-cursor-runtime-audit]].
- Existing governed-inventory lesson: [[governed-capture-helpers-missing-shared-inventory]].
- First backend rollout: [[complete-named-mark-perl-rust-parity]].
- Dart storage and rollout: [[dart-governed-capture-mark-parity]].
- Julia storage and rollout: [[julia-governed-capture-mark-parity]].
- Lua storage and rollout: [[lua-complete-named-mark-parity]].
- Why names alone are insufficient: [[current-call-name-inventory-does-not-prove-runtime-semantics]].
