---
id: write-vivification-neutral-contract
title: "Frozen write-v1 and the separate signed-array target"
answers:
  - "what is the neutral nested write vivification contract"
  - "does write vivification currently run on any backend"
  - "does a dynamic string path segment select an harray"
  - "does a dynamic integer path segment select an array"
  - "does quoted zero select an array or harray"
  - "what AST node owns one segment nested assignment"
  - "what AST node owns multi segment nested assignment"
  - "when do nested write segments and RHS evaluate"
  - "what happens when a nested write expression mutates the same binding"
  - "does a failed nested write roll back expression side effects"
  - "can nested write vivification create array gaps"
  - "what diagnostics does nested write vivification use"
  - "why must current static key index lowering change"
  - "how are nested write source spans measured"
  - "which neutral authority defines tail-relative array selectors"
  - "what diagnostic identifies signed array write underflow"
  - "when does a negative write selector resolve its array length"
  - "does the signed contract admit current backend support"
  - "can identical validator outcomes establish which source epoch was imported"
date: "2026-10-24"
status: write-v1 portable; signed target frozen with implementation and admission separately owned
tags: [dsl, actionir, assignment, autovivification, diagnostics, source-spans, mutation, FUTURE-PARITY-BACKLOG]
evidence: "Historical neutral-freeze evidence from 2026-08-30; subsequent dated rollout updates below supersede its pending-backend wording. FUTURE-PARITY-BACKLOG.19.1.1 adds capability_conformance/write_vivification_contract.json and tools/check_write_vivification_contract.py. The independent checker validates five exact AST cases, seven syntax failures, 11 successful writes, 16 structural failures, three expression failures, three read exclusions, detached values, and 105 rejected mutations. Exact current probes remain non-vivifying on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT. Perl lowering proves quoted segments are currently tagged key while every computed segment is statically tagged/coerced as index; Rust/Dart/Julia/Lua preserve the same authored key/index split. No backend behavior or public-current capability changes in this leaf."
evidence_update_2026_08_31_composition: "FUTURE-PARITY-BACKLOG.19.1.3 adds linkedspec-write-map-leaves-composition-v1 as a shared fixture consumed by both existing checkers. This write checker now validates eight additional nested writes spanning detached callback value, unrelated global, same-spelling shadow local, active receiver guard, and post-commit receiver targets while retaining all 105 base mutations. No write behavior is admitted."
evidence_update_2026_09_04_portable_admission: "FUTURE-PARITY-BACKLOG.19.7 admits language.nested_write_vivification as one exact language-runtime capability across Perl, Rust, Dart, Julia, and shared Lua, with independent PUC Lua/LuaJIT execution recorded. The capability checker pins this neutral authority's ID, format, unchanged future-neutral status, canonical JSON digest, shared composition dependency, exact backend references, row order, and owner state through 16 dedicated admission mutations. Current census is 20 capabilities / 100 pass / 0 partial / 0 gap; recurrence remains .19.8 and public-current closeout remains .19.9."
evidence_update_2026_09_05_recurring_proof: "FUTURE-PARITY-BACKLOG.19.8 runs this unchanged authority before exact consumers on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT, then all three support ledgers. The recurring topology pins this file's historical status and canonical digest through 17 fail-closed mutations and exact-one canonical CI registration. Public-current closeout remains .19.9."
evidence_update_2026_09_05_public_closeout: "FUTURE-PARITY-BACKLOG.19.9 binds current public creation, dense-array, conflict, and evaluation-order examples back to this unchanged authority. The public checker requires those example classes and exact policy text, rejects stale non-vivifying claims, and preserves this frozen JSON byte-for-byte."
evidence_update_2026_10_24_history: "Seven repetitive per-backend rollout rows remain whole in Git 9dd5e35550036c5093a35986a2b3149f8ea79f9a:docs/knowledge/write-vivification-neutral-contract.md and docs/checkpoints/signed-array-contract-admission/knowledge-before.json.gz; current v1 semantics and all lookup questions remain here."
reverify: "bash tools/check_mutation_six_runtime.sh && bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py && bash tools/run_python_project_data.sh tools/check_signed_array_selector_contract.py && bash tools/run_python_project_data.sh docs/checkpoints/signed-array-contract/import_epoch.py"
---

# Future neutral write-vivification contract

The frozen `linkedspec-write-vivification-v1` contract keeps ordinary assignment syntax:

```text
document["sections"][0]["title"] = title
document[segment_name][position] = make_value()
```

It was frozen without admitting a backend. Perl, Rust, Dart, Julia, and Lua now implement that unchanged contract
under `.19.2.1`, `.19.3.1`, `.19.4.1`, `.19.5.1`, and `.19.6.1`. `.19.7` separately admits the exact portable
capability row, `.19.8` completes exact six-runtime recurrence, and `.19.9` closes current public teaching and
no-drift.

## One typed path model

Every bracket contains one ordinary ActionIR value expression. Its evaluated value, not its spelling, selects the
container kind: a string selects an harray and a nonnegative integer selects a zero-based array. Consequently a
dynamic string selects an harray, a dynamic integer selects an array, and the quoted string `"0"` remains an harray
key. Boolean, null, negative, fractional, aggregate, and codeblock values are invalid selectors.

One or many segments lower to `assign_nested_access`. Each `path_segment` retains `source`, a half-open
Unicode-scalar `source_span`, and its complete typed `expression`; the parser does not assign a semantic `key` or
`index` tag. The complete assignment retains exact source, span, bare binding base, ordered segments, and typed RHS.

Before the implementation leaves, lowering assigned quoted literals to a static key path and computed expressions
to a static integer-index path. That historical `payload[segment]` model could not implement the accepted rule when
`segment` evaluated to a string. The completed write implementations replaced that static choice with evaluated
expression segments. Ordinary reads retain their separately governed non-creating behavior. The original neutral
fixture and its historical status remain unchanged; this September reading correction clarifies the rollout prose.

## Evaluation, creation, and commit

Segments evaluate once from left to right, then the RHS evaluates once. Expression failures stop continuation and
propagate unchanged. Only after those evaluations does structural validation/building snapshot the binding and
operate on an isolated copy.

An absent root is created from the first valid selector. A missing nonfinal child is created from the next valid
selector. Bound null is present, not absent; existing wrong-kind values are never coerced. Arrays remain dense:
existing indexes may be replaced and index `length` may append, while a larger index fails without fillers.

Completed expression side effects follow ordinary language semantics. If a segment or RHS mutates the same root
binding, the outer write snapshots that post-evaluation value. Success composes its isolated path update onto that
state; a later structural failure leaves the post-evaluation state intact rather than rolling back an already
completed expression. Atomicity forbids only a partial structural path commit. The committed binding, returned
updated root, initial tree, and aggregate RHS are detached values.

## Diagnostics and exclusions

Syntax failures use exact `action_parse` diagnostics and authored Unicode-scalar spans. Structural failures use
`nested_write_segment_invalid`, `nested_write_kind_conflict`, or `nested_write_array_gap`, with the binding,
zero-based failing segment, detached valid prefix, typed authored segment span, and kind/gap fields. Precedence is
unchanged expression failure first, then the first invalid evaluated selector, then the first structural conflict
or dense-array gap.

Reads never create state. Scalar assignment, temporary/literal/helper/property roots, reserved runtime bindings,
an invented `vivify(...)` helper, and an invented `:=` operator are outside this contract.

Related: [[write-vivification-receiver-mutation-direction]], [[terse-nested-value-path-assignment]],
[[write-vivification-perl-reference]], [[write-vivification-rust-runtime]],
[[write-vivification-dart-runtime]], [[write-vivification-julia-runtime]], [[write-vivification-lua-runtime]],
[[uniform-binding-neutral-contract]],
[[write-map-leaves-neutral-composition]], and ADR `0036`.


## Signed-array target (October24)

TYPE-REFERENCE-BOOK.1.2.17.1 freezes a separate target in
`capability_conformance/signed_array_selector_contract.json`
and its owned checker. The v1 authorities, digests and historical proof stay exact.
For integer i<0 on an existing length-L array, select L+i only in [0,L).
Negative selectors cannot create or append; positive dense writes and quoted
harray keys remain unchanged.

Normalize during the isolated post-expression walk. Existing-array underflow
uses `nested_write_array_underflow` with authored index, encountered length,
resolved_index, segment, authored span and authored-value prefix. Missing
negative targets retain v1's invalid-segment error. Identity guard precedes
expressions; global invalid kinds precede structural checks. V1 atomicity,
expression effects and detachment remain required.

This is a neutral target. Backend implementation17.2–6 and portable admission17.7
remain separately owned; unrelated read coercions and receiver order stay outside
the extension. Retained proof: docs/checkpoints/signed-array-contract/.

The freeze's original validator import predates its published reader. Both source
epochs reproduce the same20 control outcomes; the captured source identity still
rejects the later epoch. `docs/checkpoints/signed-array-contract/import_epoch.py`
verifies the retained original bytes and four-module closure; the default
publisher checks the40 actual replay outcomes. Equal results do not identify an
instrument's imported source. Whole old state and actual producers remain in the
validator-import packets and admission repair records.
