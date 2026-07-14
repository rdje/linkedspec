---
id: complete-current-mark-inventory-gap
title: Seven documented current named-mark helpers are outside the governed 239-name backend inventories
answers:
  - which current named mark helpers are missing from backend inventories
  - why does the 239 name coverage checker miss current mark helpers
  - what are the sixteen Perl contract names outside the backend inventories
  - are mark entry start and mark match start portable
  - who owns complete named mark parity
date: 2026-07-13
status: confirmed-gap
tags: [actionir, capture, marks, inventory, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.17.0 compares identifier-shaped non-compatibility Perl contract diagnostics with the aligned Dart/Julia/Lua 239-name inventories. Sixteen names differ: seven documented current mark helpers, two documented compatibility map aliases, two legacy capture names, and five internal lowering operations. tools/check_language_capability_coverage.pl reverse-checks only Perl contract calls found in the neutral corpus, so the seven current calls are invisible when every backend inventory omits them identically. FUTURE-PARITY-BACKLOG.17.1 aligns Perl/Rust; .17.2-.17.3 align Dart/Julia while staging the seven names outside the unchanged shared inventory."
reverify: "python3 tools/check_complete_named_mark_contract.py && perl tools/check_language_capability_coverage.pl --report && rg -n 'mark_entry_start|mark_entry_end|mark_match_start|mark_match_end|mark_line|mark_col|clear_mark' perl/LinkedSpec/ActionIR/Contracts.pm docs/linkedspec-book/src/dsl/source-boundary-helper-reference.md lua/src/linkedspec/action_call_names.lua dart/lib/src/action/action_contracts.dart julia/src/action/ActionContracts.jl"
---

# Complete Current Mark Inventory Gap

Seven public helpers are documented as part of the current named-mark family and implemented by the Perl reference,
but absent from the aligned 239-name Dart, Julia, and Lua inventories:

- `mark_entry_start` and `mark_entry_end`;
- `mark_match_start` and `mark_match_end`;
- `mark_line` and `mark_col`; and
- `clear_mark`.

This is not evidence that every Perl diagnostic name belongs in the public current inventory. The full comparison
contains nine other names: `entry_named_map` and `match_named_map` are documented compatibility aliases; `capture`
and `capture_macro` are legacy; and `array_append_operator`, `array_end_mutation_method`,
`hash_index_assignment_operator`, `scalar_assignment_operator`, and `value_drop` are internal lowering operations.

The current coverage gate begins with the aligned backend inventory, proves its members occur in the book and
neutral corpus, and reverse-checks only current Perl calls discovered in that corpus. It therefore prevents an
inventory-only extra and a corpus-visible omission, but not a current public call omitted by every inventory and
every governed fixture. `FUTURE-PARITY-BACKLOG.17` owns a neutral exact contract, backend rollout, Lua integration,
and final independent public-current inventory hardening. Lua capture leaf `.4.3.7.3` must consume that shared
resolution rather than inventing a backend-specific extension.

`.17.1` supplies the exact seven-helper contract and aligns Perl plus Rust live/generated execution. `.17.2`
aligns Dart native/generated-plan/emitted-state/CLI execution and stages the exact seven names in a Dart-specific
rollout set without changing the shared 239-name inventory. `.17.3` does the same for Julia. The symmetric
inventory omission remains open until Lua consumes the artifact and `.17.5` introduces the independent
public-current source of truth.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.17`.
- Initiating Lua audit: [[lua-capture-cursor-runtime-audit]].
- Existing governed-inventory lesson: [[governed-capture-helpers-missing-shared-inventory]].
- First backend rollout: [[complete-named-mark-perl-rust-parity]].
- Dart storage and rollout: [[dart-governed-capture-mark-parity]].
- Julia storage and rollout: [[julia-governed-capture-mark-parity]].
- Why names alone are insufficient: [[current-call-name-inventory-does-not-prove-runtime-semantics]].
