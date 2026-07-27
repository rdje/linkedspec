---
id: julia-root-rule-selection-core
title: "Julia core resolves explicit selector, first authored marker, then first authored rule before user code"
answers:
  - "how does Julia select the entry rule now"
  - "does Julia accept a spec without Rule::"
  - "what is the Julia markerless default rule"
  - "does Julia --top-rule override Rule::"
  - "where is Julia root selection implemented"
  - "what diagnostic does Julia return for an unknown entry rule"
  - "what diagnostic does Julia return for a zero-rule spec"
  - "why does the Julia parser preserve an empty or comment-only spec"
  - "does Julia parsing or validation own no_rules_defined"
  - "does Julia root selection rewrite descriptor is_top"
  - "does Julia strict unused count the selected entry rule"
  - "is Julia root selection admitted"
date: 2026-07-18
status: core implemented; composed routes implemented separately; cursor prerequisite and admission remain pending
tags: [julia, root-rule, top-rule, markerless, parser, validation, diagnostics, descriptor, strict-syntax, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.4.1 adds `resolve_entry_rule`, the single ordered resolver over `CompiledSpec.compiled_rule_order`: zero structure first, then exact explicit selector, first authored `RuleHeader.is_top`, and row zero. Empty state returns `no_rules_defined` / `validate_spec`; unknown explicit selection returns `entry_rule_not_found` / `select_entry_rule` with requested `entry_rule`, before runtime context or user code. Validation accepts one-or-more-rule markerless source. `parse_spec` preserves empty/comment-only `SpecFile` envelopes so validation owns the portable zero-rule identity, while non-rule garbage remains a parse error. Descriptor metadata publishes `linkedspec-root-rule-selection-v1`; definition order and authored `is_top` bits remain unchanged before and after selection. Neutral strict-unused rows remain authored-edge-only. The focused neutral consumer passes 79 assertions, package execution reaches the unchanged cursor-owned 56/57 help boundary with all earlier groups green, shared primary passes exactly 32/65 in default and POSIX environments with the identical 33 cursor failures, and corpus execution passes 105/105. Root governance remains 4 complete / 3 pending with 34 mutations because composed routes `.4.2`, cursor `.9.1.6`, and topology admission `.4.3` have not landed."
evidence_update_2026_07_18_routes: "Composed route leaf `.4.2` is now implemented; follow [[julia-root-rule-selection-routes]] for loaded/normalized/generated/emitted/trace/failure behavior. Cursor `.9.1.6` and topology admission `.4.3` remain pending, so rollout stays 4/7."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/root_rule_selection_core_test.jl\")' && bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py && bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute"
---

# Julia root-selection core

Julia validates source structure before selecting an entry rule. A valid executable source must define one or
more rules, but no authored `::` marker is required. `resolve_entry_rule(compiled, selector)` owns the exact
precedence without reparsing source or mutating compiled identity: explicit exact selector, first authored marker,
then first authored rule.

Blank and comment-only text intentionally parse to an empty `SpecFile`. That envelope lets validation return the
portable `no_rules_defined` / `validate_spec` failure. Arbitrary non-rule text still fails in the parser. Native
runtime wraps compiled selection failures as structured `RuntimeInterpreterException` diagnostics before it
creates execution context or enters any lifecycle/user action.

Selection is invocation state, not authored state. The descriptor publishes the root contract id and retains
source definition order plus every authored `is_top` value. Selecting a rule adds no strict-unused reference or
exemption. Loaded, normalized/reconstructed, generated/emitted, and selection-trace convergence is implemented by
the separate route fact; final rollout must not be inferred from this core fact.

Related: [[julia-root-rule-selection-preflight]], [[root-rule-selection-precedence]],
[[julia-root-rule-selection-routes]], [[dart-root-rule-selection-core]], and [[rust-root-rule-selection-core]].
