---
id: lua-root-rule-selection-core
title: "Lua core resolves explicit selector, first authored marker, then first authored rule before user code"
answers:
  - "how does Lua select the entry rule now"
  - "does Lua accept a spec without Rule::"
  - "what is the Lua markerless default rule"
  - "does Lua --top-rule override Rule::"
  - "where is Lua root selection implemented"
  - "what diagnostic does Lua return for an unknown entry rule"
  - "what diagnostic does Lua return for a zero-rule spec"
  - "why does the Lua parser preserve an empty or comment-only spec"
  - "does Lua parsing or validation own no_rules_defined"
  - "does Lua root selection rewrite descriptor is_top"
  - "does Lua strict unused count the selected entry rule"
  - "why do Lua root selection fixtures use I instead of E"
  - "is Lua root selection admitted"
date: 2026-07-18
status: core implemented on PUC Lua and LuaJIT; composed routes, cursor, and admission remain pending
tags: [lua, luajit, root-rule, top-rule, markerless, parser, validation, diagnostics, descriptor, strict-syntax, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.5.1 adds `resolve_entry_rule`, the single ordered resolver over `CompiledSpec.compiled_rule_order`: structural zero-rule failure first, then exact explicit selector, first authored `header.is_top`, and row one. Empty state returns `no_rules_defined` / `validate_spec`; unknown explicit selection returns `entry_rule_not_found` / `select_entry_rule` with requested `entry_rule`, before runtime context or user code. Validation accepts one-or-more-rule markerless source. `parse_spec` preserves empty/comment-only `SpecFile` envelopes so validation owns the portable zero-rule identity, while non-rule text remains a parser error. Descriptor metadata publishes `linkedspec-root-rule-selection-v1`; definition order and authored `is_top` bits remain unchanged before and after selection. Neutral strict-unused rows remain authored-edge-only. The focused consumer passes 99 assertions on PUC Lua and LuaJIT; package execution is 176/177 with only the cursor-help mismatch on each ABI; shared primary is exactly 32/65 with `POSIXLY_CORRECT` unset and set on both ABIs, leaving the same 33 cursor-owned failures; corpus is 105/105 per ABI. Root governance stays 5 complete / 2 pending with 39 mutations because composed routes `.5.2`, cursor `.9.1.7`, and topology admission `.5.3` have not landed. KM is 624/4,546; mdBook/four doctrines pass; canonical local CI closes with root consumers 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 613 seconds."
reverify: "bash tools/run_lua_local.sh && python3 tools/check_root_rule_selection_contract.py"
---

# Lua root-selection core

Lua validates structure before selecting an entry rule. A valid executable source must define one or more rules,
but no authored `::` marker is required. `resolve_entry_rule(compiled, selector)` owns the exact precedence without
reparsing source or mutating compiled identity: explicit exact selector, first authored marker, then first authored
rule.

Blank and comment-only text intentionally parse to an empty `SpecFile`. That envelope lets validation return the
portable `no_rules_defined` / `validate_spec` failure. Arbitrary non-rule text still fails in the parser. Native
runtime wraps only typed selection failures as structured runtime diagnostics before it creates execution context
or enters lifecycle/user actions. Child dispatch retains its separate rule-lookup ownership.

Selection is invocation state, not authored state. The descriptor publishes the root contract id and retains
source definition order plus every authored `is_top` value. Selecting a rule adds no strict-unused reference or
exemption. Hand-authored selection fixtures return distinct values from lifecycle `I`, directly proving the chosen
rule was entered; an `E` return can coincide only after a successful match and is weaker causal evidence. Fixed
shared request-trace source bytes remain unchanged.

This card covers parser/validation, compiled resolution, native/primary behavior, portable selection failures,
descriptor identity, and strict no-drift. Loaded/reconstructed/generated/emitted, low trace, and composed failure
convergence remain `.5.2`; cursor `.9.1.7` and final dual-ABI topology admission `.5.3` follow.

Related: [[lua-root-rule-selection-preflight]], [[root-rule-selection-precedence]],
[[julia-root-rule-selection-core]], and [[dart-root-rule-selection-core]].
