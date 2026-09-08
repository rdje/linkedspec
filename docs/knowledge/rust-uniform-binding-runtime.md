---
id: rust-uniform-binding-runtime
title: "Rust bare mutations use one typed binding on native and generated execution"
answers:
  - "what carriers do the Rust uniform binding integration tests exercise"
  - "does Rust support selector free push split and hash mutation"
  - "what does Rust set return for method chaining"
  - "how does Rust report a wrong kind bare mutation"
  - "does a saved Rust mutation result change after a later mutation"
  - "how does Rust distinguish push rule dispatch from binding mutation"
  - "are array name and hash name rejected on Rust yet"
date: 2026-09-08
status: current
tags: [rust, language, bindings, array, harray, mutation, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.3 adds RuntimeContext bare-array/harray mutation methods and native/generated proof. FUTURE-PARITY-BACKLOG.12.1.7.2 then migrates all file-backed specs and closes exposed seams: action-edge fluent push uses the same bare typed binding, direct I assignments are rule-invocation-local, otherwise absent compiled-rule names read as empty implicit accumulators, and an explicit non-undef typed binding wins over a descriptor alias. Rust passes 105/105 interpreted and generated corpus cases plus permanent focused tests. FUTURE-PARITY-BACKLOG.12.1.7.3 completes embedded-source migration, and .12.1.8.2 hard-rejects exact aggregate selectors."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test uniform_binding_contract"
---

# Rust uniform binding runtime

Rust consumes `linkedspec-uniform-binding-v1` through the same `Engine` used by native and generated-plan
execution. `RuntimeContext` may retain separate private maps, but a bare `.spec` identifier is resolved to one
current `RuntimeValue`. Bare `push(name, value)`, `name += value`, `split(name, source, delimiter)`,
`name[key] = value`, `set_key(name, key, value)`, and array end/standalone collection mutations update that value.

Mutable operations clone their returned `RuntimeValue`, so saving a first update is an independent snapshot when
the binding changes again. `set(name, value)` yields the assigned value and therefore supports chains such as
`set(items, ["b", "a"]).sorted().first()`. Array-end mutations likewise feed continuations, so
`items.push_back(value).count()` mutates `items` and yields its updated count.

An absent array or harray mutation target starts as the required empty kind. An existing incompatible value fails
with `binding_kind_mismatch` and stable identifier, expected-kind, and actual-kind fields. A statically compiled
rule retains precedence when the first argument of `push(...)` is ambiguous; otherwise the bare name is the array
binding.

The first full oracle run exposed a mixed migration bridge: bare `push(items, "a")` created a scalar-held array,
then statement `items += value` used the old aggregate-map path and lost the first update. Routing both statement
and expression append through the same bare mutation method repaired the causal defect; the existing oracle
fixture now returns `["a", "b"]`.

The complete file-backed migration exposed four more wrapper-hidden assumptions. Action-edge fluent push now
updates the bare typed binding; direct `I` assignments are scoped to the current rule invocation; an otherwise
absent compiled-rule name reads as its empty implicit accumulator; and descriptor tags do not overwrite an
explicitly initialized non-undef typed binding. Focused native/generated tests preserve these behaviors.

Exact `array(name)` and `hash(name)` selectors are rejected across Rust's compiled and generated boundaries with
the portable `aggregate_selector_removed` diagnostic. Empty, multi-argument, quoted, and computed constructor
forms remain distinct accepted surfaces.

## September 7 statement execution reading

`SESSION-STARTUP-READING.3.3.17` confirms that the I-phase prewalk records direct
scalar-assignment names and direct bare-target `set` names before executing the block.
This does not assert that every nested expression is predeclared. Statement handling
gates inactive controls, checks receiver writes, then dispatches while/return and
typed mutation forms. Array append uses the shared bare-array operation. Fluent push
resolves its child and target separately, retaining the selected edge index only for
the matching child identity.

Standalone trim/filter/case collection transforms distinguish an absent binding from
an existing wrong kind and replace the typed array. Switch compares a stored string
subject to ordered case strings, treating a bare case name symbolically; while checks
its condition before incrementing/enforcing the body limit. Existing cross-backend
while differences remain separately owned. Fresh binding neutral proof passes 11
migrations/7 executions/6 invalid selectors/8 constructors; logical proof passes
17 truthiness cases/10 helpers/3 effects/26 mutations. Native counts above remain dated.

Checkpoint `SESSION-STARTUP-READING.3.3.18` completes the expression dispatcher
and array-end/child-push helpers. Array-end methods accept only a bare variable
receiver, mutate its typed array and return the updated aggregate to subsequent
value-chain calls. A later array-end method in an ordinary chain returns undef.
Child-push dispatch recognizes a compiled-rule first argument, validates a literal
index shape before dispatch, reuses a scoped action-edge result when available,
and then resolves the destination binding. This remains distinct from an ordinary
bare-target push. Read-only access follows its existing numeric coercion path,
separate from strict write-path classification. Fresh neutral binding proof again
passes 11 migrations/7 executions/6 invalid selectors/8 constructors.

Related facts: [[uniform-binding-neutral-contract]], [[perl-uniform-binding-runtime]],
[[spec-facing-aggregate-selector-retirement-inventory]], [[terse-rust-duck-typed-assignment-parity]].

## September 7 RuntimeContext store reading

`SESSION-STARTUP-READING.3.3.29` reads bare resolution and array/harray mutation bodies.
An explicit descriptor-scalar override wins before the current bare-kind tag selects a private map.
Absent-kind plus Undef initializes an empty aggregate; explicitly bound Undef is a wrong-kind value.
Mutations retain an existing private aggregate store or publish a scalar-held aggregate, returning a detached
updated root. Bare pop operations return the updated array; private pop methods return the removed value.
Hash updates replace an existing key in place or append it. Source reading confirms this distinction without
fresh native execution; neutral binding passes 11 migrations/7 executions/6 invalid selectors/8 constructors,
write vivification passes 105 mutations and receiver mutation passes 167/592.

## September 8 uniform-binding consumer reading

`SESSION-STARTUP-READING.3.3.66` reconciles the complete 525-line, sixteen-test
`rust/linkedspec-runtime/tests/uniform_binding_contract.rs` target. Assertions
cover exact retired-selector rejection at compilation, including dead/fluent/unused
function forms, and synthetic selector rejection during emission and generated
plan validation. Retained constructors, neutral values, detached array-end results,
rule-versus-binding push precedence, pure/mutating split, harray updates, dropped
values, collection rebinds, wrong-kind fields, set chains, action-edge push and
explicit-binding precedence run through native and generated-plan helper routes.
This target does not independently compile an emitted module.

Fresh neutral checking retains eleven migrations, seven executions, six invalid
selectors and eight constructors. Earlier native/corpus results above remain dated;
this reading checkpoint does not rerun those targets.
