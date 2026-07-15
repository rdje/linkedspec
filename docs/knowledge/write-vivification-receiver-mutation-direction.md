---
id: write-vivification-receiver-mutation-direction
title: Nested creation is write-only and map_leaves bang will explicitly rebind its receiver
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
status: accepted direction; implementation pending
tags: [dsl, mutation, autovivification, receiver-methods, traversal, paths, portability, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.0; ADR 0036; Knowledge Map cards for nested writes/uniform binding/five-backend traversal; source audit of Perl MethodExpr/AST Parser, Rust expr parser, Dart/Julia/Lua ActionIR parsers; Perl direct nested-write probe, Rust terse_11_4 (3/3), Dart exact no-autovivification test, Julia complete local tests with a writable depot stacked before installed packages, and Lua 121/121 on PUC Lua/LuaJIT. The first Julia empty-depot-only attempt failed on blocked registry resolution; the stacked-depot rerun passed. No behavior changed."
reverify: "rg -n '0036|FUTURE-PARITY-BACKLOG\\.19|map_leaves!|write-only|arrays remain dense' docs/decisions/0036-write-vivification-and-receiver-mutation.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/linkedspec-book/src/overview/design-rationale.md && rg -n 'parse_method_function_expr|parse_name|_isIdentifier|_action_is_identifier|A-Za-z_.*A-Za-z0-9_' perl/LinkedSpec/ActionIR/MethodExpr.pm rust/linkedspec-core/src/expr.rs dart/lib/src/action/action_parser.dart julia/src/action/ActionParser.jl lua/src/linkedspec/action_parser.lua"
---

# Write vivification and explicit receiver mutation direction

Current behavior remains non-vivifying: nested assignment requires every intermediate array/harray to exist. A
final harray key may be created, and a final array index may replace an element or append exactly at length.
Missing/wrong intermediates and gaps leave the root unchanged. Current ActionIR method grammars also do not accept
`!` as a method-name suffix.

ADR `0036` accepts two future mechanisms after complete current-backend parity:

1. A nested **write** may create a missing root or intermediate. Reads never create state. The next evaluated
   segment determines the container: exact nonnegative integer means array, string means harray. Existing
   wrong-kind values are never coerced. Arrays remain dense, so indexes greater than `length` fail instead of
   inventing null filler leaves. Path/RHS evaluation precedes isolated copy-on-write validation and commit.
2. `tree.map_leaves!() { ... }` will be the only v1 bang method. It requires a bare named uniform binding,
   traverses an isolated original-shape snapshot using the starting receiver's root-kind rule, uses the callback
   result as the replacement, atomically rebinds `tree` after complete success, and returns an independent updated
   value. A replacement subtree is not revisited during that call.

The callback's `path` is the complete root-to-leaf path within the traversal receiver. The receiver variable name
is identity, not a path element. `value`, `path`, `key`/`index`, `depth`, and `acc` remain scoped values rather than
writable references. Assigning `value` does not secretly update a leaf.

`walk_leaves!`, `reduce_leaves!`, function-form `map_leaves!(tree)`, arbitrary bang-suffixed identifiers, temporary
or nested-access v1 receivers, and short traversal aliases are excluded. Exact neutral diagnostics and re-entrant
same-receiver behavior belong to `.19.1`; Perl/Rust/Dart/Julia/Lua implementations and public admission follow in
`.19.2-.19.7`. Until those leaves land, the current non-vivifying/bang-invalid contract remains authoritative.

## Links

- Decision: ADR `0036`.
- Owner: [[FUTURE-PARITY-BACKLOG]] `.19`.
- Current nested writes: [[terse-nested-value-path-assignment]].
- Current array traversal: [[array-tree-traversal-contract]].
- Uniform binding: [[uniform-binding-neutral-contract]].
- Authoring quality: [[spec-authoring-quality-doctrine]].
