---
id: rust-core-compilation-boundaries
title: Rust compilation orders callable normalization, typed validation, and regex resolution
answers:
  - what is the Rust compiler validation order
  - where does Rust normalize callables before resolving regex dependencies
  - do repeated Rust I lifecycle blocks append
  - do other Rust lifecycle blocks overwrite their compiled slots
  - how does Rust check recursive observation effects through rule and function calls
  - do Rust self-recursive action edges duplicate regex patterns
  - can a skipped Rust dependency target still fail complete compilation
date: 2026-09-07
status: current source-reading evidence; known parser-boundary repairs remain pending
tags: [rust, compiler, actionir, lifecycle, normalization, validation, SESSION-STARTUP-READING]
evidence: "SESSION-STARTUP-READING.3.3.3 reconciles compiler.rs 1–1355 and callable_contract.rs 251–394, 1,499 lines / 56,169 bytes, against unchanged baseline files. Fresh neutral callable checks pass 7/11 literal/call cases, 9/7 invalid cases, four invalid declarations, eight contextual forms and 23 mutations; the selector scan reports zero positive and 20 classified occurrences. These checks are not fresh native runtime execution."
reverify: "Read rust/linkedspec-core/src/compiler.rs 44–238, 422–551, 1013–1355 and 1538–1654 plus rust/linkedspec-core/src/callable_contract.rs 251–394; bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py; bash tools/run_python_project_data.sh tools/check_executable_aggregate_selector_sources.py"
---

`rust/linkedspec-core/src/compiler.rs::compile` builds every compiled function and
rule before applying this order:

1. Normalize contextual callable candidates against the complete callable registry.
2. Reject removed aggregate selectors, invalid typed nested writes, and invalid
   receiver-mutation carriers.
3. Resolve authored regex selectors, then build dependency regex mappings.
4. Validate recursive observation, progressive span dispatch, staged parse jobs,
   and compiled regex-slot identities.

`compile_with_events` uses the same order, with additional function/rule decisions
and dependency-resolution trace scopes. This is a source-order fact, not a claim
that trace I/O cannot fail or that both routes were freshly executed here.

`compile_function` prefers a supplied serialized body AST, otherwise parsing the
authored body with callable candidates. Both function-body errors propagate.
`parse_rule_code_block` instead returns no block after warning for errors outside
five recognized diagnostic markers. That confirmed defect and its native controls
are owned by `.45` in `docs/tasks/SESSION-STARTUP-READING.md`; see
[[rust-action-parser-boundary-defects]]. Whole-spec validation of surviving blocks
cannot recover an authored block already discarded at this earlier boundary.

The callable visitor recursively processes nested arguments, writes, access
expressions, mutation callbacks and continuations, shape literals, block bodies,
and fluent calls. Ordinary parenthesized block candidates in non-codeblock
positions become eager `BlockValue` expressions. Dedicated recognition,
progressive, and staged nodes are left to their corresponding validators.
[[rust-generic-final-codeblock-normalization]] owns the callable contract itself.

The compiler's expression walker includes every function and all seven lifecycle
fields plus action/blind edge code. Recursive-observation validation gathers
static rule/function calls and `recognize_once` attempts. It follows call-graph
reachability with a visited set, rejects observation nodes as `binding_write`
effects, and progressive/staged nodes as `parser_registry_or_staged_dispatch`
effects in attempted rules. This particular walker is not a claim of a general
classifier for every possible assignment or runtime side effect.

During rule lowering, repeated successfully parsed `I` blocks append statements
to `preamble`; `LS`, `LE`, `E`, `EX`, `IT`, and `LX` assign their single compiled
slots. An action edge is parent-regex anchored only when it shares the preceding
regex's physical source line. Nonregex members reset that adjacency. AND bare
edges become blind dispatch entries; OR/default bare edges become action entries.
This records current lowering, without inventing a new lifecycle policy or claiming
that every parsed body-element kind is implemented by these match arms.

Checkpoint `.3.3.4` completes compiler source reading through line 2153. Named
selectors resolve before dependency expansion. In `build_dependency_regex_map`,
external edge-only targets append their selected child pattern; self-targets reuse
the existing parent slot. The API comment claiming self-edge duplication is stale.
The helper can warn and skip an invalid target, but complete `compile` and traced
compilation subsequently call `validate_compiled_regex_slot_identities`, rejecting
missing target or dispatch slots with `regex_slot_identity_invalid` at
`validate_compiled_rule`. A successful standalone helper result is not a successful
complete compilation. `.41.2` owns these comment corrections without changing the
runtime contract.

Fresh neutral checks at `.3.3.4` pass five slot fixtures/two diagnostics/59 drift
mutations and eight entry cases/three failures/three strict cases/54 mutations.
They do not rerun native or generated consumers. The entry/error source read also
confirms structural emptiness before selector lookup, immutable borrowed selection,
and sorted portable diagnostic fields retained by `LinkedSpecError::diagnostic`.

Related: [[rust-rule-local-cursor-normalization]],
[[rust-aggregate-selector-compile-rejection]], [[write-vivification-rust-runtime]],
[[rust-progressive-span-dispatch-carriers]].
