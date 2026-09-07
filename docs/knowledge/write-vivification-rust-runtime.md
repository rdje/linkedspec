---
id: write-vivification-rust-runtime
title: "Rust preserves one typed nested-write node through every supported carrier and executes v1 vivification atomically"
answers:
  - "how does Rust implement nested write vivification"
  - "does Rust nested write create absent roots and intermediates"
  - "how does Rust preserve nested write path spans through serde and emitted source"
  - "does generated Rust execute write vivification"
  - "how does Rust fail closed on corrupt nested write nodes"
  - "when does Rust evaluate nested write segments and RHS"
  - "does Rust nested write distinguish absent binding and null"
  - "are Rust nested write results detached"
date: 2026-09-07
status: implemented under FUTURE-PARITY-BACKLOG.19.3.1; portable capability admitted under .19.7
tags: [rust, dsl, actionir, assignment, autovivification, diagnostics, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "Historical native milestone evidence from 2026-09-01; the September 7 updates below are reading and neutral verification only. FUTURE-PARITY-BACKLOG.19.3.1 replaces Rust's static key/index split with WritePathSegment and one AssignNestedAccess node for one or many authored segments. Direct Engine entry validates typed nodes; supported generated carriers validate through emission and decoded compiled state before engine execution. Runtime proof covers the frozen 5 AST / 7 syntax / 11 success / 16 structural-failure contract, evaluation order/failure, absent versus bound-null state, fresh user functions, dense arrays, post-evaluation snapshots, rollback, reads, detachment, and exact typed diagnostic fields. The 105-fixture corpus and 197-test runtime integration suite pass."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test write_vivification_contract && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test integration_test && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle"
---

# Rust write-vivification runtime

Rust now consumes the unchanged `linkedspec-write-vivification-v1` authority. `WritePathSegment` retains each
segment's ordinary expression, exact source text, and half-open Unicode-scalar span. One- and many-segment writes
both use `AssignNestedAccess`, so no parser-selected key/index path remains.

All segments evaluate once from left to right, followed by the RHS. Only then does the engine snapshot the current
binding and build on an isolated structural clone. Evaluated strings select harrays; nonnegative integral numbers
select dense arrays. An absent root or child is created only when that selector determines its kind. Bound null
and existing wrong kinds are conflicts, and an array may replace an existing slot or append at length but never
create a gap.

The engine returns exact serialized `nested_write_segment_invalid`, `nested_write_kind_conflict`, and
`nested_write_array_gap` objects through its existing error channel. Expression failures propagate unchanged.
Structural failure publishes no partial path; already completed expression side effects remain ordinary state.
Successful binding, result, initial aggregate, and aggregate RHS values are detached.

Typed-node validation runs at compiler/callable boundaries, before source emission, after emitted-plan decode,
and at direct engine entry. Corrupt programmatic or serialized nodes therefore fail closed rather than reaching a
partially interpreted compatibility path through those validated boundaries. The raw engine generated-plan
contexts expect caller validation rather than repeating the typed-write check. Native, serialized, generated-plan, emitted-source, and independently
compiled emitted Rust all execute the same typed semantics.

The original `.19.3.1` leaf did not itself implement Rust `map_leaves!`; `.19.3.2` subsequently composed that
mechanism with these nested writes. Dart/Julia/Lua implementation, portable admission, exact recurrence, and public
closeout are now complete under `.19.4-.19.9`; the dated rollout is retained in [[write-vivification-neutral-contract]].

Reading checkpoint `SESSION-STARTUP-READING.3.3.8` reviews the core expression tests through EOF. The nested-write
test checks exact `document["é"][position] = "值"` source, Unicode-scalar segment spans, expression-bearing JSON,
and equality after serde reconstruction. Its seven syntax cases assert typed codes, parse stage, spans, and units.
These are test-definition observations. Fresh neutral write checks pass 5/7 syntax, 11 successes, 16 structural
failures, 3 evaluation failures, 3 read exclusions, 8 compositions and 105 mutations; the native integration/corpus
counts above remain the 2026-09-01 milestone evidence and are not rerun by this reading checkpoint.

Related: [[write-vivification-neutral-contract]], [[terse-nested-value-path-assignment]],
[[write-vivification-perl-reference]], [[write-map-leaves-neutral-composition]], and ADR `0036`.

## September 7 diagnostic-definition reading

`SESSION-STARTUP-READING.3.3.15` reads the complete `NestedWriteError` formatter
in the engine window. Its three failure variants serialize binding, evaluated
path, segment index and authored Unicode-scalar source span, adding the exact
kind/reason or index/length fields for that failure. Display emits deterministic
JSON through the existing String channel. This is diagnostic-definition proof;
assignment evaluation, snapshot and commit implementations remain later reading.
Fresh neutral write proof again passes 5/7 syntax, 11 successes, 16 structural
failures, three evaluation failures, three read exclusions, eight compositions
and 105 mutations. The native milestone counts above are not freshly rerun.

`SESSION-STARTUP-READING.3.3.16` confirms the direct entry checks in engine lines
2631–2669 and, as supporting bounded inspection, source-emitter lines 355–420 and
997–1030: emission and decoded generated state both validate nested writes and
receiver mutations. This qualifies validation ownership, without claiming that every
low-level engine method independently rejects arbitrary unvalidated compiled input.

Checkpoint `SESSION-STARTUP-READING.3.3.17` reads the assignment coordinator and
segment classifier. It rejects an empty segment list, evaluates all segments left to
right and then RHS, classifies selectors, and only then reads binding presence/kind
and its current value. String selectors remain keys; the numeric predicate checks
finite/nonnegative/integral form, compares with `usize::MAX as f64`, then casts to
`usize`. The exact rounded upper boundary is under `.55.1` review. Invalid selectors preserve
their authored span and the already-classified path prefix.

After recursive construction succeeds, the coordinator preserves an existing private
array/hash store or writes the scalar-held root and returns that root. The recursive
construction body begins at the next owned window, so its internal traversal and
rollback details are not newly proved here. Fresh neutral write proof remains
5/7 syntax, 11 successes, 16 structural failures and 105 mutations.

Checkpoint `SESSION-STARTUP-READING.3.3.18` completes that recursive body at
engine lines 4888–4986. Harray selection replaces or inserts the final key; an
absent intermediate is created from the following selector. Array selection
rejects index greater than length before indexing, appends at length, and replaces
an existing final slot. Existing intermediates recurse without null replacement,
so a wrong kind reports the current path prefix and authored segment span.
The coordinator's detached root is published only after successful recursion.
Read access separately coerces numeric indices and returns undef for absent or
wrong-kind values; it neither invokes this writer nor creates containers.
Fresh neutral proof retains the counts above; no native carrier suite is rerun.

## September 7 engine-test suffix reading

`SESSION-STARTUP-READING.3.3.23` reads the engine tests through EOF. Unlike value-only smoke tests,
these assert the exact segment-0/segment-1/RHS audit order, a structural failure's code/path/index/length,
and preservation of an RHS rebind without publishing a partial path. The detachment test independently
mutates initial, RHS, returned and stored aggregates. Three expression-failure positions assert exactly
the completed audit prefix and unchanged target; three read controls check absent binding, missing child
and wrong-kind state without creation. This is assertion-definition evidence; the native suites were
not rerun. Fresh neutral proof passes the same 105 mutations and frozen cases above.
