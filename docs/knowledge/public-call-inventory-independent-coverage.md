---
id: public-call-inventory-independent-coverage
title: Current call coverage independently checks 122 public Perl contracts against 246 backend names
answers:
  - how many current action call names are in the shared backend inventory
  - how many public Perl action contracts are independently checked
  - how does the coverage gate prevent symmetric backend inventory omissions
  - why does action call coverage use 105 corpus fixtures plus one exact fixture
  - which Perl contracts are deliberately excluded from the public current inventory
  - what mutation proves the symmetric omission guard works
  - how are Dart source boundary compatibility aliases governed without changing the shared inventory
date: 2026-07-15
status: current
tags: [actionir, inventory, coverage, parity, marks, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.17.5 admits the exact seven complete named-mark helpers into equal 246-name Dart/Julia/Lua inventories. FUTURE-PARITY-BACKLOG.14.3.2.2 advances the Perl lowering registry to 135 identifier-shaped diagnostics by adding four grammar-owned recognition intrinsics with dedicated ActionIR nodes. tools/check_language_capability_coverage.pl combines 105 corpus sources with complete_named_mark_contract.json, subtracts thirteen exact compatibility/legacy/internal/intrinsic classifications, and still requires the remaining 122 ordinary public calls in every inventory. A simultaneous clear_mark deletion from all three inventories is reported by the exact-family and independent-public checks."
evidence_update_2026_08_07_dart_source_aliases: "FUTURE-PARITY-BACKLOG.14.2.3.0.1 keeps Dart's seven source-boundary compatibility spellings in a separate private inventory instead of widening the 246 names shared with Julia/Lua. The same checker derives their canonical targets from Dart and requires the exact seven name/target pairs to equal typed_source_location_contract.json."
reverify: "perl tools/check_language_capability_coverage.pl --report && bash tools/run_python_project_data.sh tools/check_complete_named_mark_contract.py"
---

# Independent Public-Call Inventory Coverage

Backend inventory equality is necessary but not sufficient: the same public call can be omitted from every
backend without breaking equality. Corpus-seeded reverse checking has the same weakness when no governed corpus
fixture calls the missing name.

The current coverage gate keeps three independent obligations:

1. Dart, Julia, and Lua expose exactly the same 246 shared current call names.
2. Every shared name appears in the mdBook and in either the 105-case corpus or the exact complete named-mark
   fixture.
3. The Perl lowering contracts independently produce 122 public identifier-shaped names, all of which must occur
   in the backend inventories.

Dart's seven source-boundary compatibility spellings are a separately governed backend rollout, not additions to
the 246-name shared Dart/Julia/Lua inventory. The checker derives their exact Dart canonical targets and requires
all seven name/target pairs to equal the neutral typed-source contract, so compatibility parity cannot drift while
the common vocabulary remains honest.

The independent Perl set starts with 135 identifier-shaped contracts and excludes exactly thirteen names.
`entry_named_map` and `match_named_map` are compatibility aliases; `capture` and `capture_macro` are legacy; and
`array_append_operator`, `array_end_mutation_method`, `hash_index_assignment_operator`,
`scalar_assignment_operator`, and `value_drop` are internal lowering operations. The checker also requires those
operations plus `recognition_checkpoint`, `recognize_once`, `recognition_commit`, and `recognition_rollback` to
remain present in Perl and absent from backend public helper inventories. The recognition forms are grammar-owned
intrinsics with dedicated ActionIR nodes, not ordinary calls; disappearance or accidental helper admission fails
loudly.

Mutation proof removes `clear_mark` from all three backend inventories simultaneously while retaining their exact
seven-name family views. Backend equality still holds, but the report identifies `clear_mark` through both the
complete named-mark contract check and the independent 122-contract reverse check.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.17.5`.
- Resolved gap: [[complete-current-mark-inventory-gap]].
- Exact behavior contract: [[complete-named-mark-perl-rust-parity]].
- Why inventory names do not prove behavior: [[current-call-name-inventory-does-not-prove-runtime-semantics]].
