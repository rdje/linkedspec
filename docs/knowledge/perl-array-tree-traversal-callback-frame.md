---
id: perl-array-tree-traversal-callback-frame
title: "SPEC-FORMAT-TERSE.13.2 - Perl array-tree traversal receiver blocks share the tree-dispatch lowering path."
answers:
  - "where does Perl lower array tree traversal receiver blocks"
  - "does Perl support array tree traversal receiver blocks"
  - "what variables are scoped inside Perl array tree traversal callbacks"
  - "does Perl array tree traversal recurse into hashes"
  - "what order does Perl array tree traversal use"
  - "does Perl array tree map_leaves feed array continuations"
  - "what phase0 count includes Perl array tree traversal"
date: 2026-07-08
status: current
tags: [spec-format-terse, array-tree, trailing-block, method-lowering, perl, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.13.2 updates perl/LinkedSpec/ActionIR/MethodLowering.pm so `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver trailing-block calls dispatch at runtime over hash or array receiver values. Hash receivers preserve the `.12` sorted-key contract. Array receivers traverse nested arrays depth-first by zero-based index, treat hash values as leaves, bind scoped `value`, `index`, `path`, `depth`, and reduce-only `acc`, return `undef` without callbacks for scalar receivers, and allow `walk_leaves` / `map_leaves` to feed array-family continuations such as `.count()`. Tests in `t/actionir_ast_parser.t` and `t/phase0_regression.t` lock parsing, lowering diagnostics, valid/empty/non-array runtime behavior, hash leaves, continuation, scoped restoration, descriptor readiness, and generated-source residue. The original .13.2 milestone recorded phase0 `Files=1, Tests=1028`, `Result: PASS`; this is historical evidence, not a current suite count."
reverify: "PERL5LIB= prove -q -Iperl t/phase0_regression.t && prove -q -Iperl t/actionir_ast_parser.t && rg -n 'SPEC-FORMAT-TERSE\\.13\\.2|__ls_array_tree|array-tree traversal|Tests=1028|1\\.\\.1028' perl/LinkedSpec/ActionIR/MethodLowering.pm t/phase0_regression.t t/actionir_ast_parser.t docs/tasks/SPEC-FORMAT-TERSE.md docs/knowledge/perl-array-tree-traversal-callback-frame.md"
---

# Perl Array-Tree Traversal Callback Frame

`SPEC-FORMAT-TERSE.13.2` lands Perl reference support for array-valued receiver blocks:

```text
items.walk_leaves() { ... }
items.map_leaves() { ... }
items.reduce_leaves(initial) { ... }
```

The implementation lives in `perl/LinkedSpec/ActionIR/MethodLowering.pm`. It uses one tree receiver lowering path
that dispatches at runtime:

- hash receiver values keep the existing `.12` sorted-key hash-tree traversal contract
- array receiver values use array-tree traversal
- scalar receiver values return `undef` without running the callback

Array traversal treats nested arrays as interior nodes. Scalar values and hash values are leaves; hashes are not
recursed into. Traversal is depth-first in zero-based index order.

Array callback blocks get scoped scalar bindings:

- `value`: current leaf value
- `index`: zero-based index in the parent array
- `path`: array value of root-to-leaf indexes
- `depth`: `count(path)`
- `acc`: current accumulator, for `reduce_leaves` only

`walk_leaves` returns the original array tree after side effects. `map_leaves` returns a new array tree with the
same nested-array structure and replaced leaves. `reduce_leaves(initial)` returns the final accumulator, or
`initial` for an empty array. `walk_leaves` and `map_leaves` can feed array-family continuations such as `.count()`.

The September 6 root-dispatch recheck and exact command live with
[[perl-hash-tree-traversal-callback-frame]] so the shared hash/array distinction has one diagnostic owner.
