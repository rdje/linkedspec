---
id: julia-root-rule-selection-routes
title: "Julia loaded, reconstructed, generated, emitted, and traced routes reuse one entry resolver"
answers:
  - "do Julia loaded specs use the root rule resolver"
  - "does Julia normalized JSON preserve root rule selection"
  - "do Julia generated parsers support markerless default selection"
  - "does emitted Julia source support an explicit top rule"
  - "what does Julia entry rule selection trace record"
  - "what trace level records Julia entry rule selection"
  - "what generated Julia diagnostic reports an unknown top rule"
  - "what generated Julia diagnostic reports zero rules"
  - "what loader diagnostic reports a zero-rule Julia spec"
  - "does Julia generated root selection change the v1 artifact format"
  - "what generated source version carries Julia root selection now"
  - "does Julia root selection widen the generated family plan"
  - "does generated plan validation run before Julia root selection"
  - "is Julia root rule selection admitted after route convergence"
date: 2026-07-18
status: composed routes, generated-v2, and cursor-option prerequisite implemented; topology admission remains pending
tags: [julia, root-rule, top-rule, loader, normalized-json, generated-source, emitted-source, trace, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.4.2 adds a 57-assertion route suite. File-loaded and normalized-JSON reconstructed `CompiledSpec` state preserves definition order, authored `is_top`, and descriptor JSON while default and explicit execution call `resolve_entry_rule`. Generated direct/traced and a fresh isolated emitted module apply explicit selector > first authored marker > first authored rule through the same runtime. Low `julia_runtime:entry_rule_selection` decisions record requested/effective/basis; failures record requested identity plus portable stage/code. Loader zero-rule validation projects `no_rules_defined` / `validate_spec`. Generated zero and unknown selection project `no_rules_defined` / `validate_spec` and `entry_rule_not_found` / `select_entry_rule` with requested `entry_rule`, while unrelated execution failures retain `generated_execution_failed`. Generated plan validation remains before selection. Artifacts stay `linkedspec-generated-source-v1` / format 1 with the unchanged minimal ordered label/family plan and existing optional `top_rule` signatures. Core 79, loader 82, emitter 59, routes 57, package progression through the frozen cursor-owned 56/57 help mismatch, exact primary 32/65 twice, corpus 105, and root governance 4/7 plus 34 mutations pass. No admission consumer or rollout row changes; cursor `.9.1.6` and admission `.4.3` remain required."
evidence_update_2026_07_18_dependency_order: "The route commit satisfies one Julia cursor dependency, not the whole frontier. ADR 0044 and the task graph require active Dart composed admission `.9.1.5.6` to close `.9.1.5` first; Julia cursor `.9.1.6` then precedes root topology admission `.4.3`."
evidence_update_2026_07_18_generated_v2: "FUTURE-PARITY-BACKLOG.9.1.6.4 advances artifacts to v2/format 2 without changing the minimal plan or top_rule signatures. Root route tests now execute the v2 direct/traced/emitted APIs; contract-first rejection remains before entry selection."
evidence_update_2026_07_18_option_removal: "FUTURE-PARITY-BACKLOG.9.1.6.5 removes Julia's 33 cursor-owned shared-primary mismatches while preserving --top-rule. Shared primary is now 65/65 twice; only the composed cursor admission .9.1.6.6 and root topology admission .4.3 remain."
evidence_update_2026_07_18_cursor_admission: "FUTURE-PARITY-BACKLOG.9.1.6.6 closes the composed cursor dependency at 67 files / 5 complete + 3 pending / 44 mutations. Exact Julia root topology admission .4.3 is now the next dependency-ordered leaf."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/root_rule_selection_routes_test.jl\")' && python3 tools/check_root_rule_selection_contract.py && JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute"
---

# Julia root-selection routes

Julia route adapters do not own precedence. Loaded source and normalized JSON both produce ordered compiled state,
and generated direct/traced plus freshly emitted direct/traced execution pass the invocation-local `top_rule` to
the ordinary runtime. `resolve_entry_rule` remains the only semantic decision owner.

Generated-source v2/format 2 retains the ordered `{label, family}` plan and the same invocation-local root route.
Authored marker bits live in reconstructed compiled state; an explicit selector belongs only to one execution.
Existing emitted `execute(...)` and `execute_with_trace(...)` signatures accept optional `top_rule`, so the cursor
format bump adds no parallel root API or plan field.

Trace and error wrappers now preserve selection identity. Low trace records requested selector (or `<default>`),
effective rule, and basis; failure trace uses `<none>` effective/basis plus the portable stage/code. Loader and
generated boundaries preserve zero-rule and unknown-selection identities, while unrelated generated execution
errors retain their generic classification. Generated plan validation still occurs before selection.

This remains mechanism proof, not rollout admission. Cursor public removal now makes Julia's shared command exact
at 65/65 twice. Cursor admission `.9.1.6.6` now topology-checks the complete cursor projection; root admission
`.4.3` must still topology-check its complete
route sets before either rollout advances.

Related: [[julia-root-rule-selection-core]], [[julia-generated-source-scaffold]],
[[julia-generated-source-v2-rule-local-cursor]],
[[julia-global-cursor-option-removal]],
[[dart-root-rule-selection-routes]], and [[rust-root-rule-selection-routes]].
