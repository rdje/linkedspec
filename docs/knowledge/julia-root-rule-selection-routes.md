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
  - "does Julia root selection widen the generated family plan"
  - "does generated plan validation run before Julia root selection"
  - "is Julia root rule selection admitted after route convergence"
date: 2026-07-18
status: composed routes implemented; cursor prerequisite and topology admission remain pending
tags: [julia, root-rule, top-rule, loader, normalized-json, generated-source, emitted-source, trace, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.4.2 adds a 57-assertion route suite. File-loaded and normalized-JSON reconstructed `CompiledSpec` state preserves definition order, authored `is_top`, and descriptor JSON while default and explicit execution call `resolve_entry_rule`. Generated direct/traced and a fresh isolated emitted module apply explicit selector > first authored marker > first authored rule through the same runtime. Low `julia_runtime:entry_rule_selection` decisions record requested/effective/basis; failures record requested identity plus portable stage/code. Loader zero-rule validation projects `no_rules_defined` / `validate_spec`. Generated zero and unknown selection project `no_rules_defined` / `validate_spec` and `entry_rule_not_found` / `select_entry_rule` with requested `entry_rule`, while unrelated execution failures retain `generated_execution_failed`. Generated plan validation remains before selection. Artifacts stay `linkedspec-generated-source-v1` / format 1 with the unchanged minimal ordered label/family plan and existing optional `top_rule` signatures. Core 79, loader 82, emitter 59, routes 57, package progression through the frozen cursor-owned 56/57 help mismatch, exact primary 32/65 twice, corpus 105, and root governance 4/7 plus 34 mutations pass. No admission consumer or rollout row changes; cursor `.9.1.6` and admission `.4.3` remain required."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/root_rule_selection_routes_test.jl\")' && python3 tools/check_root_rule_selection_contract.py && JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute"
---

# Julia root-selection routes

Julia route adapters do not own precedence. Loaded source and normalized JSON both produce ordered compiled state,
and generated direct/traced plus freshly emitted direct/traced execution pass the invocation-local `top_rule` to
the ordinary runtime. `resolve_entry_rule` remains the only semantic decision owner.

Generated identity is unchanged. The artifact remains contract v1/format 1 and its family plan stays ordered
`{label, family}` rows. Authored marker bits live in reconstructed compiled state; an explicit selector belongs
only to one execution. Existing `execute(...)` and `execute_with_trace(...)` signatures already accept optional
`top_rule`, so no parallel API or format bump is needed.

Trace and error wrappers now preserve selection identity. Low trace records requested selector (or `<default>`),
effective rule, and basis; failure trace uses `<none>` effective/basis plus the portable stage/code. Loader and
generated boundaries preserve zero-rule and unknown-selection identities, while unrelated generated execution
errors retain their generic classification. Generated plan validation still occurs before selection.

This leaf is mechanism proof, not rollout admission. Julia remains at the shared 32/65 cursor boundary until
`.9.1.6`; `.4.3` must later topology-check all routes and pass exact 65x2 before advancing the 4/7 ledger.

Related: [[julia-root-rule-selection-core]], [[julia-generated-source-scaffold]],
[[dart-root-rule-selection-routes]], and [[rust-root-rule-selection-routes]].
