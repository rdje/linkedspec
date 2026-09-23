---
id: map-leaves-mutation-rust-runtime
title: "Rust preserves map_leaves bang as one typed guarded receiver mutation through native and generated execution"
answers:
  - "how does Rust implement map_leaves bang"
  - "does Rust serialize receiver mutation as typed ActionIR"
  - "does generated Rust execute map_leaves bang"
  - "how does Rust identify the active map_leaves bang receiver"
  - "which Rust writes are blocked inside a map_leaves bang callback"
  - "does Rust map_leaves bang preserve unrelated callback effects"
  - "does Rust map_leaves bang release its guard after failure"
  - "does Rust map_leaves bang commit before continuation"
  - "do Rust map_leaves bang values share writable aliases"
  - "why did Rust parser-only mutation tests miss whitespace-only compilation failures"
date: 2026-09-23
status: implemented under FUTURE-PARITY-BACKLOG.19.3.2; portable capability admitted under .19.7
tags: [rust, dsl, actionir, map-leaves, mutation, identity, atomicity, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "Historical implementation and test evidence recorded 2026-09-01; the September reading update below does not rerun those native suites. FUTURE-PARITY-BACKLOG.19.3.2 adds ReceiverMutationChain with typed receiver/callback/continuation carriers and validates it at compiler, direct Engine, source-emitter, and generated-plan decode boundaries. RuntimeContext assigns stable binding identities and guards only the resolved receiver identity. The permanent contract passes 9/9 across 4 valid / 14 invalid / 5 excluded syntax cases, all base/special/composition behavior, serde/native/generated/emitted/independently compiled routes, and corrupt-node rejection; 3/3 private tests prove atomic rollback, guard release, unrelated effects, precedence, and post-commit failure. The unchanged neutral oracle rejects 167 base and 592 composition mutations."
reverify: "bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test map_leaves_mutation_contract && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib receiver_mutation_ -- --nocapture"
---

# Rust `map_leaves!` receiver mutation

Known exceptions: final scalar/nested callback assignments and statement regex
substitution bypass Rust receiver protection. See
[[rust-final-value-assignment-receiver-guard-gap]] and
[[regex-substitution-callback-and-flag-discrepancies]]; startup `.58`/`.59`
qualify current guard claims below.

Rust parses only `IDENTIFIER.map_leaves!() { ACTION_BLOCK } CONTINUATION*` as a dedicated
`receiver_mutation_chain`. The carrier retains the bare binding reference, exact method/callback/continuation
source, typed callback statements, and authored half-open Unicode-scalar spans. Compiler, serde, generated-plan,
source-emission, emitted-plan decode, and direct runtime entry all validate this same node and reject corrupt
serialized state.

`RuntimeContext` gives each visible binding a stable invocation-local identity. Entering a user-function or
callback scope allocates new identities and restores the prior ones afterward, so a parameter named `tree` is not
the guarded outer `tree`. During callbacks the engine rejects assignment, append, nested write, nested bang,
mutation helpers, array-end methods, and binding-target pipelines only when their resolved target identity equals
the active receiver. The check runs before target segment, operand, or RHS evaluation.

Execution deep-copies the existing harray or array and traverses only that snapshot's original shape. Hash roots
recurse through sorted harrays; array roots recurse through arrays in index order; cross-kind aggregates are
leaves. Each callback gets detached `value`, `path`, `depth`, and `key|index`. Its detached result replaces the
leaf without being revisited. Callback/re-entrant failure never publishes the rebuild and always releases the
guard, while ordinary completed effects on unrelated bindings persist.

Complete callback success publishes the rebuilt root once, returns another detached root, and releases the guard
before ordinary continuation. A continuation failure therefore preserves the completed receiver commit. Native,
serialized, generated-plan, emitted-source, and independently compiled emitted Rust execute the same semantics.

The 2026-09-07 reading checkpoint `SESSION-STARTUP-READING.3.3.6` confirmed a
parser/compiler mismatch beyond the established fixtures: the parser accepts
space/tab-only empty argument lists, while compiled source projection requires
exact `()`. Repair `.47` owns that gap; `.45` owns malformed rule-code warning/drop.
See [[rust-action-parser-boundary-defects]] for the original isolated core and
native CLI controls. That historical neutral-suite pass did not establish native compilation; current repair evidence follows.

The fresh neutral mutation checker passes four valid/fourteen invalid/five excluded
syntax cases, ten successes, eight pre-commit failures, six callback/one continuation
compositions, and 167 base plus 592 composition mutations. It verifies declared
neutral authority; it does not repeat native/generated runtime execution or prove
that every accepted parser spelling survives carrier validation.

Related: [[map-leaves-mutation-neutral-contract]], [[write-map-leaves-neutral-composition]],
[[write-vivification-rust-runtime]], and ADR `0036`.

## September 7 receiver-error definition reading

`SESSION-STARTUP-READING.3.3.15` reads the complete `ReceiverMutationError`
formatter: missing binding, wrong aggregate kind and guarded reentry each retain
their typed code, operation, binding, method and authored Unicode-scalar span,
plus kind or attempt context. This definition does not by itself prove guard
placement, traversal or rollback; those engine bodies retain later reading owners.
Fresh neutral proof again passes four valid/fourteen invalid/five excluded syntax
cases, ten successes, eight pre-commit failures, six callback/one continuation
compositions, and 167 base plus 592 composition mutations.

Checkpoint `SESSION-STARTUP-READING.3.3.18` reads the expression guard and source
site scanner, then the complete `eval_expr` dispatcher. The guard runs before
expression dispatch and asks `RuntimeContext::active_receiver_write` about the
resolved target and attempt. Typed nested-write/bang nodes carry explicit spans;
other forms use the active operation's recorded site, with a zero span fallback.
The scanner skips quoted strings, tracks the first site per attempt kind and
converts byte positions to Unicode-scalar offsets. It supplies diagnostic sites;
runtime binding identity remains the authority for whether a write is guarded.
This bounded reading does not yet cover the bang traversal/commit coordinator or
the context identity implementation. Fresh neutral proof again passes 167 base
and 592 composition mutations; native suites remain the dated milestone evidence.

Checkpoint `SESSION-STARTUP-READING.3.3.19` completes the bang coordinator and
both recursive rebuild/leaf-frame implementations. It snapshots the existing
aggregate, activates the identity guard, traverses only the original root-kind
shape, and releases the guard on callback error. On complete success it publishes
the rebuilt root, releases the guard and then evaluates continuation. Temporary
leaf bindings restore after body evaluation returns a Result. This ordering does
not establish that every callback write reaches the guard: final scalar/nested
assignment has a confirmed dispatch gap owned by `SESSION-STARTUP-READING.58`.
The neutral suite still passes 167 base/592 composition mutations; those fixtures
do not cover every final-expression route. The earlier general guard claim is
qualified by this measured exception until its repair and carrier recurrence land.
Exact fixtures, primary/native results and causal source locations are in
[[rust-final-value-assignment-receiver-guard-gap]].

## September 7 exact engine-test scope

`SESSION-STARTUP-READING.3.3.23` reads all three private receiver tests through engine EOF.
They assert that callback failure leaves the receiver unchanged while retaining audit/journal effects,
then prove guard release through a succeeding invocation. A continuation gap failure retains the
completed receiver commit. Guard controls cover append, push_back, split_each, set before RHS effects,
and nested write before selector/RHS evaluation; an unrelated failing write keeps its RHS side effect.
Those covered statements are followed by return expressions. They do not cover the final-assignment
or substitution gaps already owned by .58/.59. Fresh neutral 167/592 mutation checks pass;
no fresh native execution is claimed.

## September 7 binding identity body reading

`SESSION-STARTUP-READING.3.3.29` reads RuntimeContext identity/guard methods through line 2318.
Writes ensure an existing identity; declaration and scoped scalar entry replace it. Scoped entry saves the
prior variable snapshot, removes competing aggregate stores/descriptor-read override and installs the new
scalar. Exit delegates to snapshot restoration, whose body remains in the next reading window.
Receiver activation rejects an absent/already-active identity; write lookup resolves the current name to that
identity and then to the original binding/attempt span. It does not guard writes by spelling alone.
The allocator uses saturating u64 increment; this source inventory makes no measured exhaustion claim.
Existing .58/.59 dispatch gaps remain open. Fresh neutral proof passes 167 base/592 composition mutations.

## September 8 complete public consumer reading

Startup `.3.3.55` completes all 732 lines of the mutation consumer. Its guarded statement
controls precede return(value), so final-assignment and substitution exceptions .58/.59 remain
outside those controls. The emitted workspace uses a relative Cargo dependency and asserts
child-process success. This source checkpoint does not rerun the nine public or three private tests.

## September 23 empty-argument validation repair

Startup `.47.1` replaces exact `()` comparison with opening/closing-parenthesis
validation and a whitespace-only interior test. It validates the original scalar
span projection without rewriting source. The immutable neutral authority already
admits insignificant whitespace; neither its JSON nor the carrier format changes.
All four frozen valid spellings now explicitly reach compilation in the Rust test,
closing the former parser-only test gap.

Seven whitespace spellings cover spaces, tabs, LF, CRLF, mixed whitespace and
vertical-tab/form-feed. Both direct CodeBlock modes and caller-supplied source ASTs
check exact text and Unicode-scalar spans; serde/generated/emitted execution checks
values. Seven nonempty syntax controls and eight forged argument projections
retain rejection. Whole-spec native controls independently verify values.

Outer `.spec` block capture had a distinct CRLF/indentation normalization defect.
The initial whole-spec exact-text assertion failed rather than being weakened;
`.47.2` now preserves the original expected text through whole-spec and programmatic
source ASTs, serde/generated plans and independently compiled emitted consumers.
See [[rust-outer-action-source-fidelity]] for the complete Rust component/native proof.
Fresh runtime verification passes all 179 library and 12 public mutation tests;
six rebuilt-native controls and unchanged neutral 167+592 mutations pass.
Core compatibility passes 201 library, 4 diagnostic and 5 rule-code groups.
The owning leaves record exact evidence; `.47.3` closes the parent only with
receipt-bound canonical acceptance.
The separately recorded `.58`/`.59` receiver-guard defects remain open.
