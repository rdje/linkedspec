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
evidence: "Historical native milestone evidence from 2026-09-01; the September 7 update below is reading and neutral verification only. FUTURE-PARITY-BACKLOG.19.3.1 replaces Rust's static key/index split with WritePathSegment and one AssignNestedAccess node for one or many authored segments. Parser, callable-contract, compiler, serde, source-emitter, generated-plan, independently compiled emitted source, and Engine entrypoints all validate the typed node. Runtime proof covers the frozen 5 AST / 7 syntax / 11 success / 16 structural-failure contract, evaluation order/failure, absent versus bound-null state, fresh user functions, dense arrays, post-evaluation snapshots, rollback, reads, detachment, and exact typed diagnostic fields. The 105-fixture corpus and 197-test runtime integration suite pass."
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
partially interpreted compatibility path. Native, serialized, generated-plan, emitted-source, and independently
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
