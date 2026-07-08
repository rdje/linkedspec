---
id: rust-array-tree-traversal-receiver-blocks
title: "SPEC-FORMAT-TERSE.13.3 - Rust array-tree traversal receiver blocks mirror the Perl reference."
answers:
  - "does Rust support array tree traversal receiver blocks"
  - "where does Rust execute array tree map_leaves walk_leaves reduce_leaves"
  - "what variables are scoped inside Rust array tree traversal callbacks"
  - "does Rust array tree traversal recurse into hashes"
  - "what order do Rust array tree callbacks run in"
  - "what oracle fixture covers Rust array tree traversal"
  - "what fixture count includes Rust array tree traversal"
  - "does array tree map_leaves feed array continuations on Rust"
date: 2026-07-08
status: current
tags: [spec-format-terse, rust, array-tree, trailing-block, oracle, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.13.3 updated rust/linkedspec-core/src/expr.rs to classify receiver trailing blocks for tree traversal methods and updated rust/linkedspec-runtime/src/engine.rs so `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` dispatch over hash or array receiver values. Hash receivers preserve the `.12` sorted-key contract. Array receivers recurse through nested arrays by zero-based index, treat scalar and hash values as leaves, bind scoped scalar values `value`, `index`, `path`, `depth`, and reduce-only `acc`, return `undef` without callbacks for scalar receivers, and let `walk_leaves` / `map_leaves` feed array-family continuations such as `.count()`. Focused tests `terse_13_3_*` cover valid traversal, empty and scalar receivers, scoped binding restoration, malformed calls, and `.12` hash-tree regression coverage. The oracle fixture `terse_13_3_array_tree_traversal_receiver_blocks` raises the manifest to 97 fixtures and the Rust corpus oracle passes."
reverify: "cargo test --manifest-path rust/linkedspec-core/Cargo.toml tree_traversal_receiver && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_13_3 && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_12_3_hash_tree && rg -n '\"case_count\" : 97|terse_13_3_array_tree_traversal_receiver_blocks' rust/linkedspec-runtime/tests/corpus/manifest.json && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference"
---

# Rust Array-Tree Traversal Receiver Blocks

`SPEC-FORMAT-TERSE.13.3` lands Rust parser/runtime parity for the Perl array-tree traversal receiver block surface:

```text
items.walk_leaves() { ... }
items.map_leaves() { ... }
items.reduce_leaves(initial) { ... }
```

The methods run as immediate receiver trailing-block calls. A scalar receiver returns `undef` and does not execute
the callback. Hash receivers keep the `.12` sorted-key hash-tree traversal behavior. Array receivers recurse through
nested arrays only; scalar values and hash values are leaves.

Traversal is depth-first in zero-based index order. Callback bindings are scoped and restored: `value`, `index`,
`path`, `depth`, and reduce-only `acc`.

The checked-in Perl-backed fixture is `terse_13_3_array_tree_traversal_receiver_blocks`; it raised
`rust/linkedspec-runtime/tests/corpus/manifest.json` to `case_count` 97.
