---
id: lua-root-rule-selection-routes
title: "Lua loaded, reconstructed, generated, emitted, and traced routes reuse one entry resolver"
answers:
  - "do Lua loaded specs use the root rule resolver"
  - "does Lua normalized AST reconstruction preserve root rule selection"
  - "do Lua generated parsers support markerless default selection"
  - "does emitted Lua source support an explicit top rule"
  - "what does Lua entry rule selection trace record"
  - "what trace level records Lua entry rule selection"
  - "what generated Lua diagnostic reports an unknown top rule"
  - "what generated Lua diagnostic reports zero rules"
  - "what loader diagnostic reports a zero-rule Lua spec"
  - "does Lua generated root selection change the v1 artifact format"
  - "does Lua root selection widen the generated family plan"
  - "does generated plan validation run before Lua root selection"
  - "do PUC Lua and LuaJIT root selection routes agree"
  - "which lifecycle proves Lua root rule entry"
  - "is Lua root rule selection admitted after route convergence"
date: 2026-07-18
status: composed routes implemented identically on PUC Lua and LuaJIT; cursor migration and topology admission remain pending
tags: [lua, luajit, root-rule, top-rule, loader, normalized-ast, generated-source, emitted-source, trace, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.5.2 adds a 101-assertion route consumer on each Lua ABI. File-loaded and normalized-AST reconstructed compiled state preserves definition order, authored `is_top`, and descriptor JSON while default and explicit execution call `resolve_entry_rule`. Generated-v1 direct/traced and freshly persisted emitted direct/traced calls apply explicit selector > first authored marker > first authored rule through that same runtime owner. Low `lua_runtime:entry_rule_selection` decisions record requested/effective/basis; failure records requested identity, effective `<none>`, and portable stage/code before any parse scope. Loader zero-rule validation projects `no_rules_defined` / `validate_spec`, while unrelated validation retains `spec_validation_failed`. Generated zero and unknown selection project `no_rules_defined` / `validate_spec` and `entry_rule_not_found` / `select_entry_rule` with requested `entry_rule`; unrelated execution retains `generated_execution_failed`. Generated plan validation remains before selection. Artifacts stay `linkedspec-generated-source-v1` / format 1 with the unchanged minimal ordered label/family plan. Hand-authored result fixtures use entry lifecycle `I`; fixed shared request-trace bytes retain canonical `E`. Package remains 176/177 per ABI with only the cursor-help mismatch; all four default/POSIX primary legs remain exactly 32/65 with the same 33 cursor-owned residuals; corpus is 105/105 per ABI. No admission consumer or rollout row changes; cursor `.9.1.7` and admission `.5.3` remain required."
evidence_update_2026_07_19_signoff: "Root governance remains 5/7+39 and KM is 625/4,561. Canonical local CI exits 0 after reference root consumers 7+5, cursor admission 288, primary 65x2, and Phase 0 1,031/1,031 in 643 seconds. Generated book, Python cache, and both disposable ABI-native trees are removed before the clean route commit."
reverify: "bash tools/run_lua_local.sh && python3 tools/check_root_rule_selection_contract.py"
---

# Lua root-selection routes

Lua route adapters do not own precedence. Loaded source and normalized AST reconstruction both produce ordered
compiled state. Generated-v1 direct/traced plus freshly persisted emitted direct/traced execution pass the
invocation-local `top_rule` to the ordinary runtime. `resolve_entry_rule` remains the only semantic decision owner.

Generated source remains contract v1/format 1. Its plan retains only ordered `{label, family}` rows: authored
marker identity lives in reconstructed compiled state, and an explicit selector belongs only to one invocation.
Plan validation runs before execution, so a stale plan fails before selection even when the caller also requests
an unknown rule.

Trace and error wrappers preserve selection identity. Low trace records requested selector or `<default>`,
effective rule, and basis. A failed selection records `effective=<none>` plus portable stage/code and creates no
parse scope. Loader and generated boundaries preserve zero-rule and unknown-selection identities without
specializing unrelated failures. PUC Lua and LuaJIT produce the same result, trace, and diagnostic projection.

This is mechanism proof, not rollout admission. The authored selection fixtures return distinct values from
lifecycle `I`, directly proving which rule was entered; a matching `E` result would be weaker evidence because it
occurs only after successful matching. Cursor migration `.9.1.7` and root topology admission `.5.3` must still
close before Lua advances the neutral rollout.

Related: [[lua-root-rule-selection-core]], [[lua-root-rule-selection-preflight]],
[[julia-root-rule-selection-routes]], [[dart-root-rule-selection-routes]], and
[[lua-generated-source-emitter-core]].
