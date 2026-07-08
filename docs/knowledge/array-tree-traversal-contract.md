---
id: array-tree-traversal-contract
title: "SPEC-FORMAT-TERSE.13.1 accepted array-tree receiver block traversal before implementation."
answers:
  - "what did SPEC-FORMAT-TERSE.13 decide"
  - "what is the array tree traversal contract"
  - "are hashes traversed recursively inside array tree traversal"
  - "what variables are scoped inside array tree traversal callbacks"
  - "what order does array tree traversal use"
  - "does array tree traversal use walk_leaves map_leaves reduce_leaves"
  - "is array tree traversal shipped"
  - "is SPEC-FORMAT-TERSE.13 closed"
date: 2026-07-08
status: current
tags: [spec-format-terse, array-tree, traversal, trailing-block, perl-reference, rust, oracle, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.13.1 reactivated and split array-tree traversal before parser/runtime code. The accepted MVP reuses the immediate receiver block method names `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` on array-valued receivers. Array roots and nested arrays are traversal nodes; scalar and hash values are leaves; hashes are not traversed recursively. Traversal is depth-first in zero-based index order. Callback bindings are scoped `value`, `index`, `path`, `depth`, and reduce-only `acc`. SPEC-FORMAT-TERSE.13.2 landed the Perl reference implementation and phase0 `1..1028`; SPEC-FORMAT-TERSE.13.3 landed Rust parser/runtime parity plus the Perl-backed oracle fixture `terse_13_3_array_tree_traversal_receiver_blocks`, raising the checked-in manifest to 97 fixtures. SPEC-FORMAT-TERSE.13.4 closed final docs/KM/no-drift alignment, so `.13` is closed/exhausted."
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.13|array-tree|array tree|walk_leaves|map_leaves|reduce_leaves|terse_13_3_array_tree_traversal_receiver_blocks|\"case_count\" : 99' docs/tasks/SPEC-FORMAT-TERSE.md docs/knowledge/array-tree-traversal-contract.md rust/linkedspec-runtime/tests/corpus/manifest.json && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference"
---

# Array-Tree Traversal Contract

`SPEC-FORMAT-TERSE.13.1` accepted array-tree traversal into the active terse-format roadmap.
`SPEC-FORMAT-TERSE.13.2` landed the Perl reference implementation, and `SPEC-FORMAT-TERSE.13.3` landed
Rust/oracle parity.

The shipped receiver-only surface reuses the immediate trailing-block traversal methods:

```text
array_value.walk_leaves() { ... }
array_value.map_leaves() { ... }
array_value.reduce_leaves(initial) { ... }
```

An array tree has an array root. Nested arrays are interior nodes. Scalar values and hash values are leaves; hashes
are not traversed recursively by this lane.

Traversal is depth-first in zero-based array index order. Callback blocks get scoped bindings:

- `value`: current leaf value
- `index`: zero-based index of the leaf in its parent array
- `path`: array value of zero-based indexes from root to leaf
- `depth`: `count(path)`
- `acc`: current accumulator, for `reduce_leaves` only

Return behavior mirrors hash-tree traversal:

- `walk_leaves` runs callbacks for side effects and returns the original array tree.
- `map_leaves` returns a new array tree with the same array structure and callback results replacing leaves.
- `reduce_leaves(initial)` returns the final accumulator, or `initial` for an empty valid tree.

Non-array receivers return `undef` without running callbacks; oracle JSON serializes that as `null`.
`walk_leaves` and `map_leaves` may feed later array-family receiver methods such as `.count()`.
`reduce_leaves(...)` is terminal.
