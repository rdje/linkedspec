---
id: write-vivification-receiver-mutation-direction
title: Nested creation is write-only and map_leaves bang explicitly rebinds its receiver
answers:
  - does LinkedSpec currently autovivify nested assignment paths
  - will LinkedSpec add Perl style autovivification
  - can a nested read create missing containers
  - how will a missing nested path choose array versus harray
  - will nested write vivification create sparse array gaps
  - will autovivification overwrite an existing wrong kind value
  - does LinkedSpec currently accept exclamation mark method names
  - what does map_leaves bang mean
  - will walk_leaves bang or reduce_leaves bang exist
  - is callback value a writable alias
  - is callback path absolute or relative
  - does map_leaves bang traverse replacement subtrees immediately
  - when will write vivification and map_leaves bang be implemented
date: 2026-07-15
status: accepted direction; nested writes complete through Julia, bang mutation through Dart; Julia bang/Lua/admission pending
tags: [dsl, mutation, autovivification, receiver-methods, traversal, paths, portability, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.0; ADR 0036; Knowledge Map cards for nested writes/uniform binding/five-backend traversal; source audit of Perl MethodExpr/AST Parser, Rust expr parser, Dart/Julia/Lua ActionIR parsers; Perl direct nested-write probe, Rust terse_11_4 (3/3), Dart exact no-autovivification test, Julia complete local tests with a writable depot stacked before installed packages, and Lua 121/121 on PUC Lua/LuaJIT. The first Julia empty-depot-only attempt failed on blocked registry resolution; the stacked-depot rerun passed. No behavior changed."
evidence_update_2026_08_30_neutral_write_contract: "FUTURE-PARITY-BACKLOG.19.1.1 freezes linkedspec-write-vivification-v1 before backend code. One assign_nested_access node owns every one-or-more-segment write; evaluated strings select harrays and nonnegative integers select arrays; syntax and structural diagnostics carry authored Unicode-scalar spans; segments then RHS evaluate before isolated validation; completed same-binding expression side effects settle before the snapshot; dense creation, atomic commit, and detached results are executable through an independent 105-mutation checker. Current Perl/Rust/Dart/Julia/Lua behavior stays non-vivifying."
evidence_update_2026_08_31_neutral_composition: "FUTURE-PARITY-BACKLOG.19.1.2 freezes linkedspec-map-leaves-mutation-v1; .19.1.3 then binds both unchanged mechanisms through linkedspec-write-map-leaves-composition-v1. Both existing checkers validate eight writes, six callback compositions, one continuation, 167 base map mutations, and 593 composition mutations. Current six-runtime source still stops at the bang token before callback write lowering."
evidence_update_2026_08_31_perl_reference: "FUTURE-PARITY-BACKLOG.19.2.1 implements the unchanged nested-write contract on Perl only, including typed evaluated paths, absent-versus-null presence, dense isolated creation, typed diagnostics, detachment, and invocation-local rule/function state. map_leaves! remains unsupported everywhere; Rust/Dart/Julia/Lua nested writes retain the prior boundary."
evidence_update_2026_08_31_perl_map_leaves: "FUTURE-PARITY-BACKLOG.19.2.2 preserves pure functions by correcting two composition carriers, then implements map_leaves! on Perl with dedicated AST, original-shape COW traversal, detached callback frames/results, identity-keyed guard, atomic publication, post-commit continuation, 58 focused tests, 167 base plus 592 composition mutations, and Phase 0 1,032/1,032. Rust/Dart/Julia/Lua and public admission remain pending."
evidence_update_2026_09_01_rust_implementations: "FUTURE-PARITY-BACKLOG.19.3.1-.2 implement both unchanged mechanisms on Rust through typed parsed/serialized/generated/emitted carriers, evaluated dense nested writes, stable binding identities, a complete receiver-write guard, atomic original-shape mapping, detached results, and post-commit continuation. Dart/Julia/Lua and portable/public admission remain pending."
evidence_update_2026_09_02_dart_implementations: "FUTURE-PARITY-BACKLOG.19.4.1-.2 implement both unchanged mechanisms on Dart through typed native/reconstructed/generated/emitted/independent-caller/CLI routes. Receiver mutation uses stable binding identities and guards direct, nested, helper, array-end, and binding-target pipeline writes before evaluation. Package 461/461, storage 25/47, CLI 66x2, corpus 105/105, and 167 base plus 592 composition mutations pass. Julia/Lua and portable/public admission remain pending."
evidence_update_2026_09_03_julia_write: "FUTURE-PARITY-BACKLOG.19.5.1 implements the unchanged nested-write mechanism on Julia through typed native/reconstructed/generated/emitted/CLI routes, exact evaluated selectors, dense isolated publication, detachment, and typed diagnostics. Julia map_leaves!, both Lua mechanisms, recurring proof, and portable/public admission remain pending."
reverify: "rg -n '0036|FUTURE-PARITY-BACKLOG\\.19|map_leaves!|write-only|arrays remain dense' docs/decisions/0036-write-vivification-and-receiver-mutation.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/linkedspec-book/src/overview/design-rationale.md && rg -n 'parse_method_function_expr|parse_name|_isIdentifier|_action_is_identifier|A-Za-z_.*A-Za-z0-9_' perl/LinkedSpec/ActionIR/MethodExpr.pm rust/linkedspec-core/src/expr.rs dart/lib/src/action/action_parser.dart julia/src/action/ActionParser.jl lua/src/linkedspec/action_parser.lua"
---

# Write vivification and explicit receiver mutation direction

Perl, Rust, Dart, and Julia nested assignment implement write-only vivification: an absent root or missing
intermediate is created from the evaluated string/integer selector kind. Lua still requires existing intermediate
array/harray shapes. Every backend keeps dense arrays and refuses wrong-kind coercion. Perl, Rust, and Dart
ActionIR accept only the ratified `map_leaves!` receiver form; Julia and Lua still reject `!` as a method suffix.

ADR `0036` accepts two portable mechanisms. Nested writes are now implemented on Perl, Rust, Dart, and Julia;
receiver mutation is implemented on Perl, Rust, and Dart:

1. A nested **write** may create a missing root or intermediate. The frozen neutral contract is
   [[write-vivification-neutral-contract]], now implemented on the Perl reference by
   [[write-vivification-perl-reference]]. Reads never create state. The next evaluated
   segment determines the container: exact nonnegative integer means array, string means harray. Existing
   wrong-kind values are never coerced. Arrays remain dense, so indexes greater than `length` fail instead of
   inventing null filler leaves. Path/RHS evaluation precedes isolated copy-on-write validation and commit.
2. `tree.map_leaves!() { ... }` is the only v1 bang method. It requires a bare named uniform binding,
   traverses an isolated original-shape snapshot using the starting receiver's root-kind rule, uses the callback
   result as the replacement, atomically rebinds `tree` after complete success, and returns an independent updated
   value. A replacement subtree is not revisited during that call.

The callback's `path` is the complete root-to-leaf path within the traversal receiver. The receiver variable name
is identity, not a path element. `value`, `path`, `key`/`index`, `depth`, and `acc` remain scoped values rather than
writable references. Assigning `value` does not secretly update a leaf.

The shared composition boundary is [[write-map-leaves-neutral-composition]]. `walk_leaves!`, `reduce_leaves!`,
function-form `map_leaves!(tree)`, arbitrary bang-suffixed identifiers, temporary
or nested-access v1 receivers, and short traversal aliases are excluded. Exact neutral diagnostics and re-entrant
same-receiver behavior belong to `.19.1`. Perl, Rust, and Dart implement `map_leaves!`; Julia bang, Lua, and
public admission follow in `.19.5.2-.19.9`. Until those leaves land, Perl, Rust, Dart, and Julia may claim current
write vivification; only Perl, Rust, and Dart may claim current bang receiver mutation.

## Links

- Decision: ADR `0036`.
- Owner: [[FUTURE-PARITY-BACKLOG]] `.19`.
- Current nested writes: [[terse-nested-value-path-assignment]].
- Current array traversal: [[array-tree-traversal-contract]].
- Uniform binding: [[uniform-binding-neutral-contract]].
- Authoring quality: [[spec-authoring-quality-doctrine]].
