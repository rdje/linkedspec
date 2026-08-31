# 0036 - Nested creation is write-only and `!` denotes explicit receiver mutation

- Date: 2026-07-15
- Status: accepted direction; implementation pending
- Tags: dsl, language-evolution, mutation, autovivification, receiver-methods, traversal, paths, portability

## Context

Perl-style autovivification can construct a deep hierarchy by assigning a leaf through a path whose intermediate
containers do not yet exist. Ruby uses a trailing `!` convention to warn that a method may update its receiver.
Both ideas fit LinkedSpec's terse/expressive direction if their observable semantics are explicit rather than
inherited from a host language.

The current five-backend contract is narrower. Uniform binding auto-creates an absent top-level array or harray
for an explicit mutation of that kind. Nested value-path assignment is copy-on-write, but every intermediate
container must already exist with the required kind; only the final harray key may be created and only an array
index at the exact current length may append. Missing/wrong intermediates and array gaps do not mutate the root.
Perl and Rust focused proof, Dart's exact no-autovivification test, Julia's complete package proof, and Lua's
121/121 dual-ABI gate confirm that boundary.

Hash-root and array-root `walk_leaves`, `map_leaves`, and `reduce_leaves` already execute on all five backends.
They recurse only through the receiver's root kind. Each callback receives the current leaf plus a complete copied
receiver-root-to-leaf `path`, `depth`, the current `key` or zero-based `index`, and reduce-only `acc`. Callback
bindings are scoped values, not writable references into the receiver. `map_leaves` returns a rebuilt tree but
does not update its receiver.

The parser audit also finds no current bang-method grammar. Perl method calls use a word method token; Dart,
Julia, and Lua use identifier-only callees; Rust's `parse_name` stops before `!` and then requires `(`. Thus
`tree.map_leaves!() { ... }` is not an existing spelling that can be enabled only in a runtime dispatch table.

## Decision

1. **Adopt portable write-only vivification as a future language direction.** Reads remain pure and never create
   a binding, key, array element, container, cache entry, or other state. Only an assignment/mutation lvalue may
   request creation.
2. **Infer a missing container only from the next evaluated path segment.** An exact nonnegative integer segment
   selects an array; a string segment selects an harray. A quoted numeric string is an harray key. Boolean, null,
   negative, fractional, aggregate, and codeblock segments cannot choose a container and receive a typed path
   diagnostic. The same rule may determine an absent root from the first segment.
3. **Create missing values, never coerce existing ones.** A missing intermediate may be created. An existing
   scalar, array, harray, or codeblock of the wrong kind is not overwritten or coerced to satisfy the path. The
   operation fails through the neutral typed conflict boundary and leaves the root unchanged.
4. **Keep arrays dense.** A write may replace an existing element or append at exactly `length`. It may not
   create an implicit run of null/undefined filler values. A greater index remains an array-gap failure. Authors
   who need filler data construct it explicitly, so traversal and AST consumers never encounter invented leaves.
5. **Preserve copy-on-write atomicity and evaluation order.** Path-segment expressions evaluate left to right,
   then the RHS evaluates once, then validation/building operates on an isolated root copy. Success commits and
   returns the updated root; any segment/kind/gap failure leaves the binding unchanged. Leaf `.19.1.1` fixes exact
   AST fields, diagnostic codes, and re-entrant mutation behavior.
6. **Reserve trailing `!` for receiver-mutating method twins.** It is a single suffix on a receiver method token,
   not a general identifier character. It is not admitted in variable, rule, helper/function, parameter, or
   property names. A bang method must have a clear non-bang twin and must actually update an addressable receiver.
7. **Limit v1 to `map_leaves!`.** `tree.map_leaves!() { ... }` is the mutating twin of
   `tree.map_leaves() { ... }`. Version 1 requires a bare named uniform binding as receiver; temporary, literal,
   helper-result, and nested-access receivers remain non-addressable. Function-form `map_leaves!(tree)`,
   `walk_leaves!`, `reduce_leaves!`, and a generic permission to append `!` are excluded.
8. **Make `map_leaves!` a binding update, not host aliasing.** It traverses an isolated snapshot using the
   starting receiver's root-kind rule and original tree shape. The callback result, not assignment to scoped
   `value`, replaces the leaf. The complete receiver-root-relative `path` is copied and stable. A replacement that
   itself has the root container kind is not revisited during the same call.
9. **Commit the receiver only after complete success.** A successful call rebinds the named receiver to the
   rebuilt tree and returns an independent updated typed value for chaining. A callback/path/runtime failure does
   not partially update the receiver. Ordinary side effects on unrelated bindings retain their normal semantics;
   `.19.1.2` defines and tests same-receiver/re-entrant mutation rejection before backend code.
10. **Leave current non-mutating traversal untouched.** `walk_leaves`, `map_leaves`, and `reduce_leaves` keep their
    names, return contracts, callback fields, root-kind recursion, and scoped-value semantics. No short aliases are
    introduced.
11. **Implement only through the universal contract.** Neutral executable contracts land first, followed by
   Perl, Rust, Dart, Julia, and Lua/two-ABI slices and one final public/capability/no-drift admission. Behavior
   implementation waits for complete current-backend parity so the active Lua parity target does not move.

## Neutral nested-write contract freeze (2026-08-30)

Leaf `.19.1.1` resolves the nested-write details delegated by decision item 5 without admitting a backend:

- every one-or-more-segment authored assignment uses one neutral `assign_nested_access` node; each
  `path_segment` contains the ordinary typed expression rather than a parser-selected key/index tag;
- an evaluated string selects harray and an evaluated nonnegative integer selects array, including for dynamic
  expressions; quoted numeric strings remain harray keys;
- segments evaluate once left to right, then the RHS evaluates once. Expression failures propagate unchanged.
  Structural validation begins only afterward and diagnoses the first invalid selector before the first
  kind-conflict or dense-array gap;
- a same-binding side effect completed by a segment or RHS is ordinary expression state, not a partial path
  commit. The outer operation snapshots that post-evaluation binding, composes on it after success, and leaves it
  intact after a later structural failure. The isolated structural build itself still commits only once;
- syntax and structural diagnostics carry exact authored half-open Unicode-scalar spans. Structural identities are
  `nested_write_segment_invalid`, `nested_write_kind_conflict`, and `nested_write_array_gap`; and
- the committed binding, returned updated root, initial aggregate, and aggregate RHS remain detached values.

The executable owner is `capability_conformance/write_vivification_contract.json`, checked by
`tools/check_write_vivification_contract.py`. Current Perl/Rust/Dart/Julia/Lua lowering remains unchanged and
non-vivifying; backend implementation begins only in `.19.2` after `.19.1.2-.3` complete the neutral parent.

## Neutral `map_leaves!` contract freeze (2026-08-31)

Leaf `.19.1.2` resolves the receiver-mutation details delegated by decision item 9 without admitting a backend:

- the sole v1 surface is `IDENTIFIER.map_leaves!() { ACTION_BLOCK }`, represented by a dedicated
  `receiver_mutation_chain` containing one `receiver_mutation_call`; the bang is method syntax, never a general
  identifier character;
- the receiver must resolve to one existing bare non-reserved uniform-binding identity holding an harray or array.
  Root kind fixes sorted-key or zero-based-index depth-first recursion across a detached original-shape snapshot;
- every callback receives copied `value`, complete `path`, `depth`, and `key` or `index`. Its detached result
  replaces the leaf; local changes to `value`/`path` cannot write the receiver, and replacement aggregates are not
  revisited;
- the resolved receiver binding identity is guarded while callbacks run. Any direct assignment, nested write,
  nested bang invocation, or helper-mediated write through that identity fails before the attempted write with
  `receiver_mutation_reentrant`. A lexical/scoped shadow identity with the same spelling and unrelated bindings
  remain legal;
- complete callback success commits the rebuilt root once and produces a detached returned root. Ordinary fluent
  continuation starts after that commit against the returned value, so later continuation failure preserves the
  already-completed receiver update; and
- absent/wrong-kind receivers, syntax exclusions, re-entrancy, callback failure, and continuation failure have
  exact typed boundaries and authored half-open Unicode-scalar spans. Callback diagnostics propagate unchanged.

The executable owner is `capability_conformance/map_leaves_mutation_contract.json`, checked by
`tools/check_map_leaves_mutation_contract.py`. It covers four valid syntax forms, fourteen syntax failures, five
exclusions, ten successes, eight pre-commit failures, the continuation/shadow/guard-release/non-bang/detachment
boundaries, and 167 rejected mutations. A verified five-backend control accepts the unchanged non-bang call; its
one-token bang twin remains unsupported on every backend. Implementation still begins only in `.19.2` after the
composition leaf `.19.1.3` passes.

## Consequences

- The terse deep-write form remains ordinary assignment, for example
  `document["sections"][0]["title"] = title`; no explicit `vivify(...)` wrapper is needed. Its creation behavior
  is deterministic from evaluated segment kinds and remains confined to writes.
- Arbitrary sparse Perl-array behavior is deliberately not copied. Dense zero-based arrays, explicit filler data,
  typed conflicts, and atomic root replacement are portable and easier for AST consumers to reason about.
- `map_leaves!` communicates a real observable difference: the receiver binding changes. The existing
  `map_leaves` remains the pure rebuilt-value form. `walk_leaves!` and `reduce_leaves!` are not synonyms waiting to
  be added; they are excluded because no distinct coherent mutation contract has been accepted.
- “Absolute path” means complete root-to-leaf path inside the traversal receiver. The variable name is receiver
  identity, not an extra path element. Hash-root paths contain keys; array-root paths contain zero-based indexes.
- Until `.19.1-.19.7` land, every current public guide and runtime statement about non-vivifying nested writes
  remains true, and `map_leaves!` remains unsupported syntax.

## Links

- Owning tree: `docs/tasks/FUTURE-PARITY-BACKLOG.md` `.19`
- Frozen nested-write contract: `docs/knowledge/write-vivification-neutral-contract.md`
- Planning leaf: `FUTURE-PARITY-BACKLOG.19.0`
- Authoring quality: ADR `0035`
- Uniform binding: `docs/knowledge/uniform-binding-neutral-contract.md`
- Current nested-write fact: `docs/knowledge/terse-nested-value-path-assignment.md`
- Current array traversal: `docs/knowledge/array-tree-traversal-contract.md`
