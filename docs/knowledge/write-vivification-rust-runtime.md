---
id: write-vivification-rust-runtime
title: "Rust preserves one typed nested-write node through every supported carrier and executes v1 vivification atomically"
answers:
  - "which write vivification fixture independently compiles emitted Rust"
  - "how does Rust implement nested write vivification"
  - "does Rust nested write create absent roots and intermediates"
  - "how does Rust preserve nested write path spans through serde and emitted source"
  - "does generated Rust execute write vivification"
  - "how does Rust fail closed on corrupt nested write nodes"
  - "when does Rust evaluate nested write segments and RHS"
  - "does Rust nested write distinguish absent binding and null"
  - "are Rust nested write results detached"
  - "how does Rust preserve signed diagnostic integers beyond i64"
  - "why do Rust callable nested-write errors have a codeblock prefix"
  - "are Rust action error spans relative to outer brace padding"
date: 2026-10-25
status: v1 admitted under FUTURE-PARITY-BACKLOG.19.7; signed extension implemented under TYPE-REFERENCE-BOOK.1.2.17.3, portable extension pending17.7
tags: [rust, dsl, actionir, assignment, autovivification, diagnostics, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "Historical native milestone evidence from 2026-09-01; the September 7 updates below are reading and neutral verification only. FUTURE-PARITY-BACKLOG.19.3.1 replaces Rust's static key/index split with WritePathSegment and one AssignNestedAccess node for one or many authored segments. Direct Engine entry validates typed nodes; supported generated carriers validate through emission and decoded compiled state before engine execution. Runtime proof covers the frozen 5 AST / 7 syntax / 11 success / 16 structural-failure contract, evaluation order/failure, absent versus bound-null state, fresh user functions, dense arrays, post-evaluation snapshots, rollback, reads, detachment, and exact typed diagnostic fields. The 105-fixture corpus and 197-test runtime integration suite pass."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test write_vivification_contract && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test integration_test && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test corpus_oracle"
---

# Current signed Rust extension

Child17.3 preserves the v1 node/carriers and adds conditionally valid negative integer
segments. `NegativeIndex(i128)` retains the authored value; the isolated walk checks
array kind and resolves each position against its encountered post-expression length.
Missing negative roots/children retain invalid-segment/negative_integer; present null
and wrong kinds remain conflicts. Underflow carries exact index, length, resolved_index
and authored prefix. Negative selectors never append, create arrays or invent fillers.
All segments then RHS evaluate once before classification/walk; global invalid kinds
precede structural failures, and existing guard identity, effects, atomicity and copies
remain. The `usize` magnitude check is repeated after exact conversion because the float
representation of usize::MAX can round upward. Broader positive-index/Number saturation
remains P1 startup55.1, next after this leaf; this path does not close that defect.

Nested-write diagnostics serialize a private typed payload directly to the original
String channel. Its signed fields/path use serde i128 without a generic Value round-trip
or Cargo feature change. Generic JSON Value observation can coarsen wide integers;
the regression consumes original strings with typed fields, and Python independently
decodes exact integer tokens. Existing alphabetical v1 field order/messages remain.
Callable invocation still prefixes a nested failure with `codeblock 'name': `; the
observer requires the explicitly expected name before examining the inner JSON, keeping
the complete original error. No runtime envelope policy changes here.

Public rule parsing trims outer action whitespace into the CodeBlock source before
compilation. Nested-write spans are Unicode-scalar positions in that action source,
not full-spec bytes or brace padding. The Unicode probe distinguishes scalar26 from
byte28 and rejected padded scalar27, and varies leading/trailing spaces and newlines.
Standalone ActionIR retains its own containing source coordinates.

Current consumers: `rust/linkedspec-runtime/tests/signed_array_selector_contract.rs`
and `tests/signed-array-rust/cases.json`; retained dated proof and qualifications:
`docs/checkpoints/signed-array-rust/`. Reverify through the Cargo consumer and readonly
`publish.py`; exact staged canonical CI is the admission boundary. Other backends and
portable signed admission stay separately owned. Installed SDK/OS and public prepared
RGX outputs are prerequisites; no dependency-internal or whole-SDK replay is claimed.

# Historical v1 runtime and reading checkpoints

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

## Dated reading checkpoints

The exact previous card, including every original reading window and repeated neutral
result, remains `git show 691d2d87690ce3f9052c1d032a3e862ee5d76211:docs/knowledge/write-vivification-rust-runtime.md`.
These checkpoints establish source/assertion definitions, with no fresh native milestone
rerun. Their neutral proof retains5 AST/7 syntax,11 success/16 structural failures,
3 evaluation failures/3 read exclusions,8 compositions and105 mutations.

- Startup3.3.15 reads the three v1 formatter variants: exact binding/path/segment/span,
  kind/reason or index/length, deterministic String JSON; no traversal proof yet.
- Startup3.3.16 reads engine2631–2669 and supporting emitter355–420/997–1030:
  validated entry/emission/decode reject malformed nodes; raw low-level generated
  contexts rely on caller validation rather than independently repeating it.
- Startup3.3.17 reads ordered segments then RHS, classification, post-expression
  presence/kind snapshot and store-preserving single commit. Its positive numeric
  `<= usize::MAX as f64` cast has the separately owned55.1 rounded-boundary risk.
- Startup3.3.18 completes engine4888–4986 recursion: replace/insert harray keys,
  create absent children from the next selector, reject positive gaps, append at
  exact length, preserve null/wrong-kind conflicts and publish only after success.
  The old pure numeric read cast is superseded by signed17.3 above.
- Startup3.3.23 reads tests through EOF: exact segment0/segment1/RHS audit,
  structural fields and RHS-rebind preservation, independently mutated aggregate
  boundaries, three expression-stop positions and three noncreating read controls.
- Startup3.3.66 reconciles all592 lines of the original write consumer. Five parent
  tests cover frozen AST/syntax, native successes/failures, fresh function presence
  and one composed carrier. That carrier reconstructs SpecFile/CompiledSpec,
  validates native/generated-plan state and rejects corrupt segment kind. Its
  separately compiled emitted child checks one computed path yielding
  `{"sections":[{"title":"Intro"}]}`, using relative `../../../linkedspec-runtime`
  and an owned Drop workspace. It does not run every frozen case on every carrier.
