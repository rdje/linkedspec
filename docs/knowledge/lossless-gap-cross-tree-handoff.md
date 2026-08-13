---
id: lossless-gap-cross-tree-handoff
title: Lossless gap syntax and admission belong to INTER-MATCH-GAP-CAPTURE before typed-source composition
answers:
  - "which tree implements capture_gaps"
  - "which tree implements named regex slots"
  - "what does FUTURE-PARITY-BACKLOG 14.5 own"
  - "when is typed gap composition complete"
  - "is Rule dot name an alias for Rule bracket name"
  - "are Rule dot N and Rule bracket N equivalent"
  - "why do regex slot selectors use brackets"
  - "do numeric and named regex selectors have the same reorder semantics"
  - "can the first dot after an action edge target be omitted"
  - "is arrow Rule method equivalent to arrow Rule dot method"
  - "why does an action edge fluent chain keep its first dot"
  - "what happens after FUTURE-PARITY-BACKLOG 14.5.0"
date: 2026-08-13
status: cross-tree handoff complete; Perl authored/static and native-live leaves complete; carrier/admission pending
tags: [architecture, task-tree, gap-capture, named-slots, selectors, typed-source, handoff]
evidence: "Clean handoff d26e4d4e and the committed ADR/duplicate-slot/typed-source authorities assign implementation to INTER-MATCH-GAP-CAPTURE. Perl .2.1 from clean 8f826923 admits named declarations, named selectors, and capture_gaps static metadata; .2.2 from clean 912fc5ed adds only private native-live state/accessors and synchronizes recognition to 137/246/58. Generated loading, runtime admission, and typed-source composition remain pending. Gap rollout remains 1 complete + 8 pending and 55 mutations, plus 10 independent Perl dormancy mutations."
reverify: "bash tools/check_duplicate_regex_slot_identity_five_backend.sh && bash tools/check_typed_source_location_six_runtime.sh && perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG.14.5.0 && perl tools/read_task_tree.pl --tree INTER-MATCH-GAP-CAPTURE --id INTER-MATCH-GAP-CAPTURE.1"
---

# Lossless gap cross-tree handoff

Current Perl LinkedSpec supports positional action-edge targets such as `Rule[1]`, named regex declarations,
`Rule[name]`, and private native-live `@capture_gaps` state/accessors. It does not yet execute from an
independently loaded generated carrier, and the forms are not portable/publicly admitted. The historical Perl mechanism
proves the intended automatic prefix/interstitial behavior, while the current marker implementations prove that
legacy scope and timing cannot simply be promoted into a portable contract.

`INTER-MATCH-GAP-CAPTURE.1-.7` is therefore the sole owner of named-slot grammar, selector validation,
`@capture_gaps` lifecycle semantics, prefix/interstitial/tail and empty spans, failure/commit/recursion policy,
compatibility migration, six-runtime implementation, carriers, and public admission. Behavior-free
`FUTURE-PARITY-BACKLOG.14.5.0` selects that clean pivot. It adds no second implementation owner.

After `INTER-MATCH-GAP-CAPTURE.7` closes, `FUTURE-PARITY-BACKLOG.14.5.1` may consume its unchanged evidence
and promote only the typed-source `gap_composition` row. Program-wide recurring/public no-drift remains
`FUTURE-PARITY-BACKLOG.14.8`.

## Selector namespaces

- `Rule[N]` is positional compatibility. Declaration reordering can change its target.
- `Rule[name]` is stable identity. Declaration reordering must not change its target.
- Both bracket forms may compile to one typed slot target, but the compiler retains source form and resolved
  identity so diagnostics and migration never confuse position with name.
- `Rule.N` and `Rule.name` are not aliases. Dot remains the fluent rule-behavior namespace, including existing
  method-like forms such as `Rule.return(...)`.
- The first fluent dot is mandatory: `-> Rule[name].method1(...).method2(...)` is canonical, while
  `-> Rule[name] method1(...).method2(...)` is not an alias. The dot visibly binds the chain to its receiver,
  keeps all methods structurally uniform, avoids whitespace-sensitive attachment, and leaves a clean boundary for
  multiline continuation and future edge modifiers.

This separation provides the useful shorthand—stable names—without creating an ambiguous second selector grammar.

## Links

- Decision and historical contract: ADR `0045`, [[inter-match-gap-capture-origin-and-contract]]
- Duplicate slot identity: ADR `0047`, [[duplicate-regex-slot-identity-contract]]
- Typed span algebra: ADR `0056`, [[typed-source-location-cursor-algebra-direction]]
- Implementation owner: `docs/tasks/INTER-MATCH-GAP-CAPTURE.md`
- Composition owner: `docs/tasks/FUTURE-PARITY-BACKLOG.14.md`
