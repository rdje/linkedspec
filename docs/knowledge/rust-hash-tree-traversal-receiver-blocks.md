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
date: 2026-07-08
status: confirmed
tags: [spec-format-terse, rust, hash-tree, trailing-block, oracle, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.12.3 updated rust/linkedspec-core/src/expr.rs to parse receiver trailing blocks for `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` and updated rust/linkedspec-runtime/src/engine.rs to execute those methods through the receiver trailing-block chain path. The runtime requires a hash receiver, treats nested hashes as interior nodes, treats every non-hash value including arrays as a leaf, traverses sorted-key depth-first, and binds scoped scalar values `value`, `key`, `path`, `depth`, and reduce-only `acc` during callbacks. Focused tests `terse_12_3_*` cover map/reduce/walk behavior, empty/non-hash receivers, scoped binding restoration, and malformed calls. The oracle fixture `terse_12_3_hash_tree_traversal_receiver_blocks` raises the manifest to 96 fixtures and the Rust corpus oracle passes over all 96. During fixture debugging, the non-hash traversal result was assigned to `nonhash` before `if(is_undefined(nonhash), ...)` because nesting the trailing-block call directly inside inline `if(...)` collapsed the Perl reference case to undef. SPEC-FORMAT-TERSE.12.4 closed the no-drift sweep by aligning mdBook helper/reference/formal/backend-handoff docs, Knowledge Map retrieval, live docs, task-tree rows, and roadmap/architecture state on the 96-fixture boundary."
reverify: "cargo test --manifest-path rust/linkedspec-core/Cargo.toml hash_tree_receiver -- --nocapture && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_12_3 -- --nocapture && rg -n '\"case_count\" : 96|terse_12_3_hash_tree_traversal_receiver_blocks' rust/linkedspec-runtime/tests/corpus/manifest.json && rg -n 'SPEC-FORMAT-TERSE\\.12\\.4|walk_leaves|map_leaves|reduce_leaves' docs/tasks/SPEC-FORMAT-TERSE.md docs/TASK_TREE.md ROADMAP_V2.md ARCHITECTURE_STATE.md docs/linkedspec-book/src docs/knowledge/rust-hash-tree-traversal-receiver-blocks.md && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference"
---

# Rust Hash-Tree Traversal Receiver Blocks

`SPEC-FORMAT-TERSE.12.3` landed Rust parser/runtime parity for the Perl hash-tree traversal receiver block
surface:

```text
tree.walk_leaves() { ... }
tree.map_leaves() { ... }
tree.reduce_leaves(initial) { ... }
```

The methods run as immediate receiver trailing-block calls. A hash receiver is required; a non-hash receiver
returns `undef` and does not execute the callback. The tree root is a hash, nested hashes are interior nodes, and
every non-hash value is a leaf, including arrays. Traversal is sorted-key depth-first. Callback bindings are scoped
and restored: `value`, `key`, `path`, `depth`, and reduce-only `acc`.

Rust does not need the Perl aggregate mirror lexicals for these callback variables because `path` and array-valued
`value` are scalar-held `RuntimeValue::Array` values, and existing helpers such as `array(path)` can read them.

The checked-in Perl-backed fixture is `terse_12_3_hash_tree_traversal_receiver_blocks`; it raised
`rust/linkedspec-runtime/tests/corpus/manifest.json` to `case_count` 96.
