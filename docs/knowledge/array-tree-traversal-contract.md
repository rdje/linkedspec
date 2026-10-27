---
id: array-tree-traversal-contract
title: "Array and Hash traversal preserve callback scope and actual reduction result kinds"
answers:
  - "why does Rust evaluate a reduction initial for a scalar or null root"
  - "does Rust reduce_leaves preserve malformed callback arity errors"
  - "can reduce_leaves result continue into numeric Array or Hash methods"
  - "which task extends terminal reduction accumulator results"
  - "what did SPEC-FORMAT-TERSE.13 decide"
  - "what is the array tree traversal contract"
  - "are hashes traversed recursively inside array tree traversal"
  - "what variables are scoped inside array tree traversal callbacks"
  - "what order does array tree traversal use"
  - "does array tree traversal use walk_leaves map_leaves reduce_leaves"
  - "is array tree traversal shipped"
  - "is SPEC-FORMAT-TERSE.13 closed"
date: 2026-10-27
status: current
tags: [spec-format-terse, array-tree, traversal, trailing-block, perl-reference, rust, oracle, SPEC-FORMAT-TERSE]
evidence: "SPEC13 root traversal; TYPE23.1.1 frozen result feature and Perl21.1/Rust21.2 focused RED/GREEN. Exact prior full record/July milestones at Git2eb98f833f712bfeb78d0cdb416060e1905ff72c for this path."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/reduction_result_receiver_contract.t"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test reduction_result_receivers"
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

Scalar receivers return `undef` without running callbacks; oracle JSON serializes that as `null`.
Hash receivers retain their separate hash-tree behavior through the shared dispatcher, as recorded in
[[perl-array-tree-traversal-callback-frame]]; the original array-lane non-array wording did not retire it.
`walk_leaves` and `map_leaves` may feed later array-family receiver methods such as `.count()`.
`reduce_leaves(...)` was terminal at that milestone; current bounded Perl flow is recorded below.

TYPE23.1.1 selects bounded reduction result continuations as a feature addition,
not a producer repair. Public native/fresh accumulators include Number/String/
Array/Hash/false/null/empty initial; nested numeric consumption gives7. Appended
scalar/container links give null through explicit terminal metadata. AST retains
the callback/add link while substitution is return undef. Healthy source capture
is[3,SILL,1,[9]], versus skipped appended chain[null,empty,0,[1,2]]; malformed
shapes skip effects, scalar root skips initial/callback. An appended default
leaks raw DSL through emitted-default bypass; dedicated traversal/result dispatch
is owned by upcoming Perl21.1. Frozen reduction-result-continuations.md schedules
all five backend children21.1-.5, preserving root/callback/copy/order and actual
accumulator kinds. Current terminal behavior stays until targeted implementation;
full signature/context/portable admission remains23.4. Original July reverify
command/history is retained exactly at Git7222ff78668d6fd08ee0dc448d1c8bb4d3da9855.

Perl21.1 now tags reduction results with existing default_result actual-kind
dispatch, starts the dedicated first tree step as tree_source, and keeps reduce
chains out of emitted-default bypass. Callback/root/initial bodies are unchanged.
The tree selected-tail rejection now binds the valid prefix once before null;
first feature RED had empty order, Toolbox result=undef, final order is SILC.
Twelve native/fresh shared/direct traversal checks plus syntax pass: exact result
kinds/typed indices/copies, empty/null/false/default/generic/numeric/Array/Hash
consumers, named/reversed roots, SI(L*)C snapshots/scope restoration, invalid-root
skipping and malformed/rejected operands. Rust21.2 independently follows; deferred/
context/full portable admission and canonical Perl registration23.4.1 remain open.

Immediate traversal consumers of dynamic results also delegate to that existing
tree lowerer through a forward declaration, before generic result guards. Public
pre-route reduction/map brace compilation fails native/fresh; final shared
[3,B,b,4,4] retains Array/Hash accumulator maps, repeated reduction after a pipeline
and a coalesced container reducing. Twelve final assertions pass native/fresh
with these additional fields. This adds ordinary composition, not deferred/bang
callback policy.

Rust21.2 independently confirms producers, then removes the nonfinal reduction
fence in eval_receiver_with_trailing_block_chain. Container-only consumers check
actual reduced kind before operands; existing callback/dynamic routing stays.
Six native/restored/in-process plan tests pass shared data/immediate traversals/
coalesced-repeat reductions/kinds/typed indices/copies/scoped SI(L*)C and rejected
SIL/SILC. A separate old invalid-root defect is reproduced as SII instead of S:
eval_tree_receiver_trailing_block_call initializes before root matching. Guard
invalid reduce roots after shape validation and before initial/callback; direct/
chained checks pass. Offline compile/rustfmt and admitted walk/map/root/path pass.

Shared fixture now contains valid shapes only: Rust Core compile retains typed
zero/two-initial arity errors, while local Perl controls retain null/no-effects
(eighteen reference checks pass). Error phase/identity parity is owned and
scheduled1.2.1.4.1 before admission. No standalone/deferred/context/bang or full
portable claim; Dart21.3 independently follows.
