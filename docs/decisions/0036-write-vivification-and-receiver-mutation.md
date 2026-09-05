# 0036 - Nested creation is write-only and `!` denotes explicit receiver mutation

- Date: 2026-07-15
- Status: accepted; both mechanisms portable-capability-admitted, recurrently proven, and public-closed
- Tags: dsl, language-evolution, mutation, autovivification, receiver-methods, traversal, paths, portability

## Context

Perl-style autovivification can construct a deep hierarchy by assigning a leaf through a path whose intermediate
containers do not yet exist. Ruby uses a trailing `!` convention to warn that a method may update its receiver.
Both ideas fit LinkedSpec's terse/expressive direction if their observable semantics are explicit rather than
inherited from a host language.

At the decision boundary, the five-backend contract was narrower. Uniform binding auto-created an absent top-level array or harray
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
`tools/check_write_vivification_contract.py`. At this freeze boundary Perl/Rust/Dart/Julia/Lua lowering remained
unchanged and non-vivifying; backend implementation began only in `.19.2` after `.19.1.2-.3` completed the neutral
parent.

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
boundaries, and 167 rejected mutations. At this freeze boundary a verified five-backend control accepted the
unchanged non-bang call while its one-token bang twin remained unsupported on every backend. Implementation began
only in `.19.2` after the composition leaf `.19.1.3` passed.

## Neutral composition freeze (2026-08-31)

Leaf `.19.1.3` binds the two unchanged mechanism contracts through
`linkedspec-write-map-leaves-composition-v1` without admitting backend behavior:

- a callback may vivify its detached `value` and return the updated result as a replacement; the replacement is
  not revisited and remains detached from callback, snapshot, committed, and returned boundaries;
- a nested write to an unrelated binding commits or fails under ordinary write semantics. Its completed effects
  persist across a later callback failure, while its own unchanged diagnostic aborts the bang call before receiver
  commit. Structural failure rolls back only the isolated write path, not an already-completed segment/RHS effect;
- the active receiver guard compares resolved identity before any nested-write segment or RHS evaluation.
  `receiver_mutation_reentrant` therefore wins over every latent nested-write diagnostic and produces no attempted-
  write effect;
- a same-spelling helper parameter or scoped binding remains legal when its resolved identity differs from the
  receiver identity; and
- callback success commits the receiver and releases the guard before continuation. A continuation-side receiver
  write then uses ordinary write semantics; its failure preserves the earlier bang commit.

The shared fixture is `capability_conformance/write_map_leaves_composition_contract.json`. Both existing checkers
consume it: the write checker independently validates eight embedded writes, while the mutation checker executes
six callback compositions plus one post-commit continuation. The original freeze rejected 593 scalar/container-
shape mutations in addition to its 167 base mutations. The implementation-scope carrier correction described
below preserves every observation while reducing the current mechanically generated composition total to 592.
This adds no executable entrypoint or temporary allocator.

At the freeze boundary the exact composed probe stopped at the unsupported bang token before callback nested-
write lowering. Its non-bang control returned `{"leaf":[]}` on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT. The
bang form returned null on Perl/Rust (with Rust's stopped-identifier warning) and the generic parser-invocation
failure on Dart/Julia/both Lua ABIs. Backend implementation began with `.19.2.1`; capability/public claims remain
unchanged until the later admission leaves.

## Perl nested-write implementation (2026-08-31)

Leaf `.19.2.1` implements the unchanged `linkedspec-write-vivification-v1` contract on the Perl reference only:

- one- and many-segment bracket assignments parse as one `assign_nested_access` node containing ordered
  expression-bearing `path_segment` records and authored Unicode-scalar spans;
- lowering evaluates every segment once left-to-right, then the RHS once, and calls
  `LinkedSpec::BindingRuntime::nested_write` only after those expressions complete;
- an invocation-local presence map distinguishes an absent Perl lexical from explicitly bound `undef`. Rule
  assignments mark tracked roots present, user-function parameters begin present, and fresh function locals reset
  to absent on every call;
- the runtime chooses harray/array from evaluated string/nonnegative-integer kinds, clones before structural work,
  creates only unambiguous missing values, keeps arrays dense, and throws exact typed selector/kind/gap objects;
  and
- successful bindings/results and aggregate inputs remain detached; structural failure commits no partial path,
  while completed same-binding segment/RHS effects retain the frozen post-evaluation snapshot semantics.

The permanent Perl contract projects all frozen AST, syntax, success, structural-failure, evaluation, detachment,
bound-null, and user-function cases. This leaf did not implement `map_leaves!`, alter Rust/Dart/Julia/Lua, or
admit a portable/public capability. Those boundaries remain owned by `.19.2.2-.19.9`.

## Rust nested-write implementation (2026-09-01)

Leaf `.19.3.1` implements the same unchanged `linkedspec-write-vivification-v1` contract on Rust:

- one `WritePathSegment` representation retains typed expression, source, and Unicode-scalar span, while one
  `AssignNestedAccess` owns every one- or many-segment write;
- the parser emits the seven frozen syntax diagnostics, and compiler/callable validation rejects malformed typed
  nodes before execution. Serde, generated plans, source emission, emitted-plan decode, and direct engine entry
  preserve and revalidate the same shape;
- the engine evaluates segments left-to-right and RHS once, then snapshots presence/value and builds on an
  isolated clone. Strings select harrays, nonnegative integral numbers select dense arrays, and only unambiguous
  absent roots/intermediates create;
- bound null, wrong kind, invalid selector, and array gaps produce the exact typed diagnostic fields; expression
  failures propagate unchanged and structural failure publishes no partial path; and
- successful binding/result/input/RHS aggregates detach. Rule state, fresh user-function locals, present
  parameters, native execution, serialized state, generated plan, emitted source, and independently compiled
  emitted Rust share the same behavior.

The permanent Rust contract projects all frozen AST/syntax/success/structural-failure cases plus evaluation,
detachment, bound-null, fresh-function, fail-closed carrier, and generated execution boundaries. This leaf does
not itself implement Rust `map_leaves!`; `.19.3.2` has since composed that mechanism with these nested writes.
Dart nested writes have since advanced under `.19.4.1`; Dart `map_leaves!`, Julia/Lua, and portable/public
admission remain owned by `.19.4.2-.19.9`.

## Rust `map_leaves!` implementation (2026-09-01)

Leaf `.19.3.2` implements the unchanged `linkedspec-map-leaves-mutation-v1` contract on Rust:

- `ReceiverMutationChain` retains the typed bare receiver, mutation call, callback ActionIR, ordinary fluent
  continuation, exact authored source, and half-open Unicode-scalar spans through compiler validation, serde,
  generated plans, source emission, emitted-plan decode, and independently compiled emitted Rust;
- `RuntimeContext` assigns stable identities to visible bindings and replaces/restores them across scoped and
  function-local lifetimes. The callback guard therefore follows the resolved receiver identity, while a
  same-spelling parameter or scoped binding remains distinct;
- direct assignment, append, nested write, nested bang, mutation helpers, array-end methods, and binding-target
  pipelines reject before their operand/segment/RHS evaluation when they target the active receiver;
- the engine traverses a detached original-shape snapshot in sorted-key or index order, recursing only through
  containers of the starting root kind. Copied callback frames produce detached, non-revisited replacements;
  complete success publishes once, while callback/re-entrant failure leaves the receiver unchanged and releases
  the guard; and
- ordinary unrelated effects keep their normal semantics. Continuation starts after commit and guard release, so
  its later failure preserves the completed receiver publication. All aggregate boundaries detach.

Permanent proof projects the 4/14/5 syntax inventory, 10 successes, 8 pre-commit failures, special state cases,
six callback compositions, one continuation composition, native/serde/generated/emitted/independently compiled
routes, and corrupt-node rejection. Private runtime proof exercises state visible only after failure. The unchanged
oracle rejects all 167 base and 592 current composition mutations. Dart and Julia now implement both mechanisms;
Lua and portable/public admission remain future.

## Dart nested-write implementation (2026-09-02)

Leaf `.19.4.1` implements the unchanged `linkedspec-write-vivification-v1` contract on Dart:

- one `ActionWritePathSegment` retains the authored expression, source, and half-open Unicode-scalar span, while
  one `ActionAssignNestedAccessExpr` owns every one- or many-segment bracket write;
- source parsing, callable validation, compiled-state validation, generated plans, emitted source, and direct
  runtime execution reject malformed or empty typed segment carriers;
- the interpreter evaluates every segment left-to-right and then the RHS, snapshots binding presence/value only
  afterward, and constructs on an isolated copy. Evaluated strings select harrays and nonnegative integers select
  dense arrays; absent roots/intermediates create, while bound null, wrong kinds, invalid selectors, and gaps emit
  the exact typed diagnostic without partial publication;
- completed expression effects retain ordinary semantics, expression failures preserve their exception identity,
  and successful binding/result/input/RHS aggregates detach; and
- the same carrier and behavior execute natively, after `SpecFile` JSON reconstruction, through generated plans,
  through freshly emitted Dart independently analyzed/executed by a caller package, and through the primary CLI.

Permanent proof projects the frozen 5 AST / 7 syntax / 11 success / 16 structural-failure / 3 expression-failure /
3 read-exclusion inventory plus detachment, function presence, astral spans, corrupt carriers, and every supported
Dart route. The complete Dart gate passes format 110/0, strict analysis, 450/450 tests, 24 managed temporary
owners / 47 locked packages, CLI 66/66 in default and POSIX environments, and corpus 105/105. Reads remain
non-creating. Dart `map_leaves!`, Julia/Lua, and portable/public admission do not move in this leaf.

## Dart `map_leaves!` implementation (2026-09-02)

Leaf `.19.4.2` implements `linkedspec-map-leaves-mutation-v1` on Dart without changing the neutral contract:

- `ActionReceiverMutationChainExpr` retains the bare binding reference, mutation method, typed callback block,
  ordinary continuation, exact source, and half-open Unicode-scalar spans through contract/callable resolution,
  compiled-state validation, generated plans, emitted source, and direct runtime entry;
- stable runtime binding identities distinguish the active receiver from same-spelling callback scopes and
  user-function parameters. Direct assignment/append, nested write, nested bang, explicit mutation helpers, all
  array-end methods, and binding-target pipelines check the resolved identity before operand/segment/RHS work;
- the interpreter traverses a detached original-shape snapshot in sorted harray-key or array-index order, recursing
  only through the starting root kind. Copied callback frames produce detached, non-revisited replacements;
  callback or re-entrant failure publishes nothing and always releases the guard;
- successful traversal publishes one rebuilt root, returns another detached root, releases the guard, and then
  executes ordinary continuation, so a continuation failure preserves the completed receiver commit; and
- reconstructed `SpecFile`, native execution, generated plan, emitted Dart independently analyzed/executed by a
  caller package, primary CLI, malformed-state rejection, and nested-write composition share this carrier.

Permanent proof projects the 4/14/5 syntax inventory, 10 successes, 8 pre-commit failures, special state cases,
six callback compositions, one continuation composition, and all supported Dart routes. The unchanged checker
rejects 167 base and 592 composition mutations. The composed-boundary audit corrected only an inert parent `/x/`
to the established zero-regex `Top` loop/child-owned `Done` regex shape; no language observation changed. Julia,
Lua, portable capability, public examples, and recurring admission remain owned by `.19.5-.19.9`.

## Julia nested-write implementation (2026-09-03)

Leaf `.19.5.1` implements the unchanged `linkedspec-write-vivification-v1` contract on Julia:

- one `ActionWritePathSegment` retains the authored expression, source, and half-open Unicode-scalar span, while
  one `ActionAssignNestedAccessExpr` owns every one- or many-segment bracket write;
- source parsing, callable/contract traversal, compiled-state validation, generated plans, source emission, and
  direct runtime entry preserve and reject malformed typed carriers;
- the interpreter evaluates every segment left-to-right and then the RHS, snapshots binding presence/value only
  afterward, and constructs on an isolated copy. Evaluated strings select harrays and nonnegative integers select
  dense arrays; absent roots/intermediates create, while bound null, wrong kinds, invalid selectors, and gaps emit
  the exact typed diagnostic without partial publication;
- completed expression effects retain ordinary semantics, expression failures preserve identity, reads remain
  non-creating, and successful binding/result/input/RHS aggregates detach; and
- the same carrier and behavior execute natively, after `SpecFile` reconstruction, through generated plans,
  through a freshly emitted module loaded into an isolated host module, and through the primary CLI.

Permanent proof projects the frozen 5 AST / 7 syntax / 11 success / 16 structural-failure / 3 expression-failure /
3 read-exclusion inventory plus detachment, function presence, astral spans, corrupt carriers, and every supported
Julia route. The focused contract passes 406 assertions and the complete package suite passes. Julia
`map_leaves!` has since advanced below. At this dated Julia-write boundary both Lua mechanisms, recurring proof,
and portable/public admission remained future; the later Lua write implementation is recorded below.

## Function-scope carrier resolution (2026-08-31)

The `.19.2.2` Perl implementation audit found that two frozen composition examples use unparameterized user
functions while labeling their `tree`/`audit` spellings as caller bindings. That conflicts with the admitted
portable function contract: parameters and working variables have fresh function-local scope, implicit caller
capture is forbidden, and caller-state-mutating functions remain deferred. An exact Perl probe confirms the
helper mutates only its local bindings.

The director chose option A: preserve pure functions and replace only those carriers with existing caller-scope
constructs. The helper-mediated rejection now uses inline explicit-target `set(tree, ...)`; the post-commit proof
uses a trailing caller-scoped `.with()` block. The intended receiver-identity and commit-order observations remain
unchanged, the corrected current composition corpus has 592 mutations, and no implicit capture was introduced.
See [[map-leaves-function-scope-contract-conflict]].

## Perl `map_leaves!` implementation (2026-08-31)

Leaf `.19.2.2` implements `linkedspec-map-leaves-mutation-v1` on the Perl reference backend:

- the AST parser recognizes only bare `IDENTIFIER.map_leaves!() { ACTION_BLOCK }` as a dedicated
  `receiver_mutation_chain`, preserving all 4 valid, 14 invalid, and 5 excluded syntax shapes with exact spans;
- lowering creates copied callback bindings for `value`, `path`/`@path`, `depth`, and `key|index`, uses the callback
  result as the leaf replacement, and starts ordinary fluent continuation only after runtime commit;
- `BindingRuntime::map_leaves_mutation` deep-copies the receiver, traverses only the original root kind and shape,
  never revisits replacement containers, rebuilds fully, and performs one detached atomic root publication;
- a dynamically scoped guard keys the actual receiver scalar slot, not its spelling. Direct assignment, nested
  write, nested bang, `set`, `set_key`, `push`, array-end methods, and binding-target array pipelines all reject
  before writing the receiver, while unrelated bindings and distinct same-spelling shadows remain legal; and
- callback/re-entrant failure leaves the receiver unchanged and always releases the guard. A continuation starts
  after release, so its ordinary failure preserves an already completed receiver commit.

The permanent Perl contract exercises the frozen base and composition authority, including the array-pipeline
write audit, with fatal warnings. It passes 58 focused tests, 105 write mutations, 167 base map mutations, 592
composition mutations, and the complete 1,032-test Perl Phase 0 regression. Rust and Dart have since implemented
both mechanisms; Julia has since implemented both mechanisms. At this dated Perl-bang boundary Lua remained
non-bang/non-vivifying; the later Lua write implementation is recorded below. Portable capability and public
admission remain future.

## Julia `map_leaves!` implementation (2026-09-03)

Leaf `.19.5.2` implements `linkedspec-map-leaves-mutation-v1` on Julia without changing either neutral contract:

- `ActionReceiverMutationChainExpr` retains one bare binding reference, mutation call, direct typed callback
  `ActionBlock`, ordinary continuation, exact source, and half-open Unicode-scalar spans through contract,
  callable, semantic, compiler, generated-plan, source-emitter, and runtime boundaries;
- visible bindings have stable identities across ordinary writes, while callback scopes and user-function
  parameters receive fresh identities and restore their shadows. The active guard therefore follows resolution,
  not spelling;
- assignment/append, nested write/bang, explicit mutation helpers, array-end methods, regex substitution, and all
  binding-target array pipelines reject before their operand, selector, or RHS work only when they target the
  guarded identity. Unrelated and distinct same-spelling writes remain legal;
- the interpreter maps a detached original-shape snapshot in sorted harray-key or array-index order, recursing
  only through the starting root kind. Copied callback frames yield detached, non-revisited replacements;
  callback or re-entrant failure publishes no receiver root and always releases the guard; and
- complete callback success publishes once, releases the guard, returns another detached root, and only then
  executes ordinary fluent continuation, so continuation failure cannot undo the completed commit.

Permanent proof passes 496 assertions across all 4 valid / 14 invalid / 5 excluded syntax cases, the frozen
behavior and composition groups, 18 pre-evaluation guarded write forms, corruption, reconstruction, native,
generated-plan, emitted-module, and primary-CLI routes. The unchanged neutral checkers reject 167 base plus 592
composition mutations. The exact control keeps `Top` regex-free: entering it starts the parent loop, whose edge
selects `Done` and matches only `Done`'s regex. Lua, recurring proof, and portable/public admission remain future.

## Lua nested-write implementation (2026-09-04)

Leaf `.19.6.1` implements the unchanged `linkedspec-write-vivification-v1` contract in shared Lua on PUC Lua and
LuaJIT:

- one `ActionWritePathSegment` retains each authored expression, source, and half-open Unicode-scalar span, while
  one `assign_nested_access` `ActionExpr` owns every one- or many-segment bracket write;
- parser contracts, static call projection, compiled-state validation, generated plans, source emission, and
  direct runtime entry preserve the carrier and reject malformed or reserved reconstructed state;
- the runtime evaluates every segment left-to-right and then the RHS, snapshots binding presence/value only
  afterward, and constructs on an isolated copy. Evaluated strings select harrays and nonnegative integers select
  dense arrays; absent roots/intermediates create, while bound null, wrong kinds, invalid selectors, and gaps emit
  exact typed diagnostics without partial publication;
- completed expression effects retain ordinary semantics, expression failures preserve identity, reads remain
  non-creating, and successful binding/result/input/RHS aggregates detach; and
- the same behavior executes natively, after public `SpecFile` reconstruction, through generated plans, through a
  freshly loaded emitted module, and through the primary CLI on both supported Lua ABIs.

The permanent shared consumer passes 436 assertions per ABI and explicitly proves `map_leaves!` remains
unsupported. The complete Lua gate, CLI 66x2, corpus 105/105, and repository-local storage proof pass. During the
full integration run, stale action-edge endpoint expectations were corrected from 1 to 6: the parent loop had
already consumed the child-owned `Done` regex for `xhello`, so this repairs test evidence without changing runtime
dispatch. At that `.19.6.1` boundary, Lua receiver mutation, recurring proof, and portable/public admission
remained future.

## Lua `map_leaves!` implementation (2026-09-04)

Leaf `.19.6.2` implements the unchanged `linkedspec-map-leaves-mutation-v1` contract in shared Lua on PUC Lua
and LuaJIT:

- exact `IDENTIFIER.map_leaves!() { ACTION_BLOCK } CONTINUATION*` syntax lowers to a typed
  `receiver_mutation_chain` with distinct receiver, mutation-call, direct callback-block, and ordinary fluent-
  continuation state plus authored Unicode-scalar spans;
- action contracts/static projection preserve the callback and continuation, while compiler, direct-runtime,
  public `SpecFile` reconstruction, generated-plan, and source-emitter boundaries fail closed on malformed or
  reserved state;
- visible bindings keep stable identity across ordinary writes, callback and user-function scopes get fresh
  identities, and every direct/nested/helper/array-end/regex-substitution/binding-target-pipeline write checks the
  resolved active receiver before evaluating operands, segments, or RHS values;
- detached original-shape traversal follows the starting root kind, copies callback fields and results, does not
  revisit replacement aggregates, publishes once after complete success, clears the guard on every exit, and
  releases it before post-commit continuation; and
- the known Lua 5.1 200-local ceiling is preserved by placing the implementation under the existing private
  `typed_source.receiver_mutation` namespace rather than adding chunk-local aliases.

The permanent shared suite passes 530 assertions per ABI across all frozen syntax/behavior/composition IDs, all
18 guarded writes, user-function bodies, malformed state, native, reconstructed, generated-plan, emitted-module,
and primary-CLI routes. The adjacent write suite passes 438 per ABI; the unchanged neutral oracles reject all 167
base and 592 composition mutations; and the complete Lua gate passes. This closes the five-backend implementation
parent `.19.6`. At that implementation boundary, portable capability, recurring proof, and final public admission
remained owned by `.19.7-.9`.

## Portable capability admission (2026-09-04)

Leaf `.19.7` admits the two completed mechanisms as exact `language-runtime` capability rows:

- `language.nested_write_vivification` cites the frozen write authority and shared composition dependency;
- `language.map_leaves_receiver_mutation` cites the frozen receiver-mutation authority and the same composition
  dependency; and
- each row records exact production/test evidence for Perl, Rust, Dart, Julia, and shared Lua, whose note requires
  independent execution on PUC Lua and LuaJIT.

The manifest advances from 18 capabilities / 90 pass states to 20 / 100 with no partial or gap state. Its checker
pins exact row order, contract text, sources, backend status/reference sets, the dual-ABI note, tracked owner state,
neutral authority IDs/formats/statuses/canonical JSON digests, and composition ID/path/digest links. Sixteen
dedicated mutations prove that omission, duplication, reordering, stale backend state, evidence substitution, or
authority drift fails closed.

This admission does not rewrite the frozen artifacts' historically accurate `future-neutral` status strings and
does not change parser, compiler, runtime, generated carrier, facade, schema, MCP, CLI, or example behavior.
## Recurring six-runtime proof (2026-09-05)

Leaf `.19.8` adds one repository-routed driver for the unchanged nested-write and `map_leaves!`/composition
authorities. It executes exact consumers in Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT order, then generated-
source, capability, and language-coverage ledgers. Canonical CI tracks, path-audits, and syntax-checks the driver
unconditionally and executes it exactly once when `LINKEDSPEC_RUN_MUTATION_MATRIX=1`.

The capability checker binds the recurring owner, driver, opt-in switch, project-data initializer, three exact
historical authority IDs/statuses/canonical JSON digests, command and route order, support-ledger order, and CI
topology through seventeen fail-closed mutations. This changes verification infrastructure only. Frozen artifact
bytes, production behavior, public-current teaching, parent `.19`, and push remain unchanged; `.19.9` owns those
remaining public/no-drift/closeout boundaries.

## Public closeout (2026-09-05)

Leaf `.19.9` publishes the admitted current semantics without changing the three frozen authorities or any
parser, compiler, runtime, generated carrier, capability row, facade, schema, MCP, or CLI behavior. The primary
guide demonstrates missing-container creation, dense-array append/gap rejection, existing-kind conflicts,
segment-before-RHS evaluation, original-shape traversal, callback fields, receiver-identity guarding, rollback,
detached results, callback-local composition, and post-commit continuation.

`tools/check_mutation_public_surface.py` inventories 63 current public Markdown files, requires exact anchors in
14 mutation-owning documents, binds eleven semantic example classes to exact policy strings from the frozen write,
bang, and composition contracts, rejects ten stale current claims, and proves those controls through 50 isolated
in-memory mutations. Historical task, decision, Knowledge, and history records remain outside its stale-current
scan. Canonical CI tracks and runs the checker unconditionally; the capability checker independently pins its
`.19.9` owner and exact-one CI registration. The exact six-runtime driver remains the recurring executable behavior
proof. Together those layers close parent `.19` while preserving every frozen authority byte.

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
- During `.19.2-.19.6`, public guidance named the backend transition explicitly. `.19.7` admits both portable
  capability rows, `.19.8` completes recurring proof, and `.19.9` closes current public teaching and no-drift.

## Links

- Owning tree: `docs/tasks/FUTURE-PARITY-BACKLOG.md` `.19`
- Frozen nested-write contract: `docs/knowledge/write-vivification-neutral-contract.md`
- Planning leaf: `FUTURE-PARITY-BACKLOG.19.0`
- Authoring quality: ADR `0035`
- Uniform binding: `docs/knowledge/uniform-binding-neutral-contract.md`
- Current nested-write fact: `docs/knowledge/terse-nested-value-path-assignment.md`
- Current array traversal: `docs/knowledge/array-tree-traversal-contract.md`
