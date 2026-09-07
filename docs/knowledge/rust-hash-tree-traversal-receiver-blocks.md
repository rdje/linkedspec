---
id: rust-hash-tree-traversal-receiver-blocks
title: "SPEC-FORMAT-TERSE.12.3 - Rust hash-tree traversal receiver blocks mirror the Perl reference."
answers:
  - "does Rust support hash tree traversal receiver blocks"
  - "where does Rust execute map_leaves walk_leaves reduce_leaves receiver blocks"
  - "how are Rust hash tree callback variables bound"
  - "what variables are scoped inside Rust hash tree traversal callbacks"
  - "does Rust map_leaves treat arrays as leaves"
  - "what order do hash tree traversal callbacks run in"
  - "what oracle fixture covers Rust hash tree traversal"
  - "why did the hash tree oracle assign nonhash before if"
  - "is SPEC-FORMAT-TERSE.12 closed"
date: 2026-09-07
status: confirmed
tags: [spec-format-terse, rust, hash-tree, trailing-block, oracle, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.12.3 updated rust/linkedspec-core/src/expr.rs to parse receiver trailing blocks for `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` and updated rust/linkedspec-runtime/src/engine.rs to execute those methods through the receiver trailing-block chain path. The runtime requires a hash receiver, treats nested hashes as interior nodes, treats every non-hash value including arrays as a leaf, traverses sorted-key depth-first, and binds scoped scalar values `value`, `key`, `path`, `depth`, and reduce-only `acc` during callbacks. Focused tests `terse_12_3_*` cover map/reduce/walk behavior, empty/non-hash receivers, scoped binding restoration, and malformed calls. The oracle fixture `terse_12_3_hash_tree_traversal_receiver_blocks` raises the manifest to 96 fixtures and the Rust corpus oracle passes over all 96. During fixture debugging, the non-hash traversal result was assigned to `nonhash` before `if(is_undefined(nonhash), ...)` because nesting the trailing-block call directly inside inline `if(...)` collapsed the Perl reference case to undef. SPEC-FORMAT-TERSE.12.4 closed the no-drift sweep by aligning mdBook helper/reference/formal/backend-handoff docs, Knowledge Map retrieval, live docs, task-tree rows, and roadmap/architecture state on the 96-fixture boundary."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-core tree_traversal_receiver && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_12_3_hash_tree && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference"
---

# Rust Hash-Tree Traversal Receiver Blocks

`SPEC-FORMAT-TERSE.12.3` landed Rust parser/runtime parity for the Perl hash-tree traversal receiver block
surface:

```text
tree.walk_leaves() { ... }
tree.map_leaves() { ... }
tree.reduce_leaves(initial) { ... }
```

The methods run as immediate receiver trailing-block calls. In hash-root mode, the tree root is a hash,
nested hashes are interior nodes, and
every non-hash value is a leaf, including arrays. Traversal is sorted-key depth-first. Callback bindings are scoped
and restored: `value`, `key`, `path`, `depth`, and reduce-only `acc`.

Rust stores callback `path` and array-valued `value` as scalar-held `RuntimeValue::Array` values.
Current bare identifiers read these values; exact `array(name)` selectors were subsequently retired.
Array roots now have their own traversal mode under [[rust-array-tree-traversal-receiver-blocks]].
Scalar roots execute no leaf body, although callback/initial-accumulator expressions are evaluated first.

The checked-in Perl-backed fixture is `terse_12_3_hash_tree_traversal_receiver_blocks`; it raised
`rust/linkedspec-runtime/tests/corpus/manifest.json` to `case_count` 96.

## September 7 complete traversal reading

`SESSION-STARTUP-READING.3.3.19` reads the complete pure traversal and leaf-frame
implementations. Hash roots visit sorted keys and recurse only into hashes; array
roots visit indices in order and recurse only into arrays. Cross-kind aggregates
remain leaves. Walk returns its input snapshot; map builds callback replacements
without revisiting them; reduce threads the callback result as the next accumulator.
Leaf bindings are restored after the callable returns a Result. The dispatcher
evaluates the initial accumulator and callback value before choosing root-kind mode.
These source observations supplement the dated native evidence; fresh callable
neutral proof passes seven literals/eleven calls/23 mutations.
