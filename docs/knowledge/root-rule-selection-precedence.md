---
id: root-rule-selection-precedence
title: "Directed root-selection contract: explicit selector > first authored `::` > first authored `:` when no marker exists"
answers:
  - "what is the root rule selection precedence"
  - "does --top-rule have priority over Rule::"
  - "can --top-rule select an ordinary single colon rule"
  - "what rule is top when a spec has no double colon rule"
  - "is Rule:: required in every spec"
  - "what task owns first rule as top"
  - "which backends currently reject a spec without Rule::"
date: 2026-07-18
status: director decision captured; neutral contract and implementation pending
tags: [dsl, root-rule, top-rule, entry-selection, cli, backend-parity, FUTURE-PARITY-BACKLOG]
evidence: "Director clarification on 2026-07-18 fixes exact precedence: (1) an explicit entry selector, specifically CLI `--top-rule NAME`, has highest priority and may designate any declared rule, including an ordinary `Rule:` even when a `Rule::` exists; (2) without an explicit selector, the first authored `Rule::` is the default; (3) when no rule ends in `::`, the first authored ordinary `Rule:` is the default. Read-only retrieval found Dart runtime `_parse` already uses `topRule ?? _defaultTopRuleLabel()`, and `_defaultTopRuleLabel()` scans authored top markers before falling back to `compiledRuleOrder.first`; source-emitter failure attribution mirrors that fallback. The normal path is inconsistent because Dart `validateSpec`, Rust core validation, Julia validation, and Lua validation still reject a source with no `::`; current mdBook doctrine also says a marker is required. No single backend may move alone. Dedicated subtree `FUTURE-PARITY-BACKLOG.9.1.1.2` owns neutral decision/contract, Perl reference, Rust, Dart, Julia, Lua, and public no-drift leaves."
reverify: "rg -n '_defaultTopRuleLabel|topRule \\?\\?|_topRuleLabel' dart/lib/src/runtime/interpreter.dart dart/lib/src/source_emitter.dart dart/lib/src/cli/primary_cli.dart; rg -n \"no top rule found|at least one rule must use\" dart/lib/src/validation rust/linkedspec-core/src/validation.rs julia/src/spec/Validator.jl lua/src/linkedspec/spec_validator.lua; rg -n 'FUTURE-PARITY-BACKLOG\\.9\\.1\\.1\\.2' docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

# Root-rule selection precedence

The durable target contract is ordered, not ambiguous:

1. An explicit entry selector wins. On the shared primary command this is `--top-rule NAME`; it may select any
   declared rule and has priority even when the source contains one or more `Rule::` markers.
2. With no explicit selector, the first authored `Rule::` in definition order is the default.
3. With no explicit selector and no `::` marker, the first authored ordinary `Rule:` is the default.

Zero-rule input remains invalid and an explicit unknown name remains an error. A rule selected by any route remains
an ordinary rule at execution time; authored `is_top` metadata records source syntax and is not rewritten to mimic
the dynamic selector.

This is the directed language contract, not yet the uniform current implementation. The validators named in the
front matter still make the no-marker fallback unreachable. Follow task subtree `.9.1.1.2` for rollout state.
