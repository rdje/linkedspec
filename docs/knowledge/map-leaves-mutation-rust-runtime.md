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
date: 2026-09-01
status: implemented under FUTURE-PARITY-BACKLOG.19.3.2; portable capability admitted under .19.7
tags: [rust, dsl, actionir, map-leaves, mutation, identity, atomicity, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.3.2 adds ReceiverMutationChain with typed receiver/callback/continuation carriers and validates it at compiler, direct Engine, source-emitter, and generated-plan decode boundaries. RuntimeContext assigns stable binding identities and guards only the resolved receiver identity. The permanent contract passes 9/9 across 4 valid / 14 invalid / 5 excluded syntax cases, all base/special/composition behavior, serde/native/generated/emitted/independently compiled routes, and corrupt-node rejection; 3/3 private tests prove atomic rollback, guard release, unrelated effects, precedence, and post-commit failure. The unchanged neutral oracle rejects 167 base and 592 composition mutations."
reverify: "bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test map_leaves_mutation_contract && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib receiver_mutation_ -- --nocapture"
---

# Rust `map_leaves!` receiver mutation

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

Related: [[map-leaves-mutation-neutral-contract]], [[write-map-leaves-neutral-composition]],
[[write-vivification-rust-runtime]], and ADR `0036`.
