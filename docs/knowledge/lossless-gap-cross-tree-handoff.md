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
date: 2026-08-16
status: inter-match gap owner closed; typed-source gap_composition handoff unblocked at clean-boundary commit
tags: [architecture, task-tree, gap-capture, named-slots, selectors, typed-source, handoff]
evidence: "Clean handoff 3d0384d1 assigned sole syntax/lifecycle/compatibility/runtime/public ownership to INTER-MATCH-GAP-CAPTURE. That tree is canonical-signoff-complete through no-change .7.3 from public atomic 254 bb0c3768: gap is 9/0/63 plus public 6/12/10/29, language is 250/105+1/126, recognition is 137/250/58, and the rooted neutral/Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT authority passes. Base-relative proof keeps executable contracts and outward surfaces unchanged. FUTURE-PARITY-BACKLOG.14.5.1 is unblocked but may activate only after the .7.3 receipt/brief/clean boundary; it owns only typed-source gap_composition."
reverify: "bash tools/check_duplicate_regex_slot_identity_five_backend.sh && bash tools/check_typed_source_location_six_runtime.sh && perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG.14.5.0 && perl tools/read_task_tree.pl --tree INTER-MATCH-GAP-CAPTURE --id INTER-MATCH-GAP-CAPTURE.1"
---

# Lossless gap cross-tree handoff

Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT support positional and named action-edge targets, named regex
declarations, and admitted `@capture_gaps` state/accessors across native, reconstructed/generated, emitted, and
primary roles. The public shared inventory contains `entry_slot`, `gap_span`, `gap_text`, and `gap_kind`; exact
compatibility governance keeps the three legacy markers divergent rather than aliases.

`INTER-MATCH-GAP-CAPTURE.1-.7` is therefore the sole owner of named-slot grammar, selector validation,
`@capture_gaps` lifecycle semantics, prefix/interstitial/tail and empty spans, failure/commit/recursion policy,
compatibility migration, six-runtime implementation, carriers, and public admission. Behavior-free
`FUTURE-PARITY-BACKLOG.14.5.0` selects that clean pivot. It adds no second implementation owner.

`INTER-MATCH-GAP-CAPTURE.7.3` independently closes the complete owner without executable movement.
`FUTURE-PARITY-BACKLOG.14.5.1` may consume that unchanged evidence and promote only the typed-source
`gap_composition` row after the clean closeout commit. Program-wide recurring/public no-drift remains
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
- Julia implementation plan: [[inter-match-gap-julia-implementation-plan]]
