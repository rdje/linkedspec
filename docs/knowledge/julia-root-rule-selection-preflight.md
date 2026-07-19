---
id: julia-root-rule-selection-preflight
title: "Julia root fallback exists behind validation, but exact admission also waits for cursor migration"
answers:
  - "why does Julia fail root rule selection parity"
  - "what is Julia root selection parity before implementation"
  - "does Julia --top-rule override Rule::"
  - "does Julia already select the first marker"
  - "does Julia already select the first rule without a marker"
  - "what blocks markerless Julia specs"
  - "which Julia root selection routes already work"
  - "what Julia root selection diagnostics still differ"
  - "does Julia descriptor publish the root selection contract"
  - "why does Julia pass only 31 of 65 primary cases"
  - "how many Julia primary failures belong to root selection"
  - "why must Julia root admission wait for cursor migration"
  - "what is the safe Julia root and cursor implementation order"
date: 2026-07-18
status: superseded by Julia root core/routes; cursor and rollout admission remain pending at the 4/7 boundary
tags: [julia, root-rule, top-rule, markerless, validation, generated-source, descriptor, diagnostics, cursor, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.4.0 runs the exact 65-case shared primary manifest with POSIXLY_CORRECT unset and set. Julia passes 31/65 both times. The identical failures are 22 help/usage plus 11 medium-or-higher request traces caused by the separately pending global parse_mode removal, and one root-owned success_markerless_first_authored_rule compile failure. Explicit ordinary override, first-authored-marker default, unknown selector, default seek, and AND consume pass. Exact API probes prove Parser preserves ordered RuleHeader.is_top; Validator._check_top_rule_exists blocks normal markerless source before strict and other checks; bypass-compiled native/generated direct execution already implements explicit > first marker > first rule; loaded/normalized/emitted routes re-enter validation. Unknown explicit selection uses rule_lookup; zero default uses top_rule_selection; explicit selection against zero state incorrectly reaches rule_lookup. Descriptor meta preserves definition_order and per-rule is_top but lacks entry_rule_contract and retains parse_mode=seek. Low runtime trace is silent; high trace records only effective top_rule. Generated unknown selection collapses to GeneratedExecutionFailedCode. Pkg.test reaches the primary arguments suite and fails 1/57 on the cursor-owned help line; standalone corpus execution passes 105/105. Root governance stays 4 complete / 3 pending with 34 mutations. Safe order is root core .4.1, root routes .4.2, Julia cursor .9.1.6, then exact 65x2 root admission .4.3. No Julia behavior changes in the preflight."
evidence_update_2026_07_18_core: "Superseded for current core status by [[julia-root-rule-selection-core]]. Leaf `.4.1` removes marker-required validation, centralizes ordered selection and portable failures before user code, publishes descriptor identity, and improves shared primary to exact 32/65 twice. Routes `.4.2`, cursor `.9.1.6`, and admission `.4.3` remain pending, so rollout stays 4/7."
evidence_update_2026_07_18_routes: "Superseded for current composed behavior by [[julia-root-rule-selection-routes]]. Leaf `.4.2` converges loaded, normalized, generated, emitted, trace, loader-error, and generated-error routes without advancing rollout. Cursor `.9.1.6` and admission `.4.3` remain pending."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot: julia --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia; source=\"Earlier:\\n /x/\\n\\nMarked::\\n /x/\\n\"; compiled=compile_spec(parse_spec(source)); println(runtime_parse(LinkedSpecRuntimeEngine(compiled), \"x\"; top_rule=\"Earlier\").matched)' && env -u POSIXLY_CORRECT PERL5LIB= perl tools/run_cli_conformance.pl --case success_explicit_top_rule --case success_default_first_authored_marker --case success_markerless_first_authored_rule --display-command linkedspec_julia -- julia --project={{REPO_ROOT}}/julia --startup-file=no --history-file=no {{REPO_ROOT}}/julia/bin/linkedspec_julia.jl"
---

# Julia root-selection preflight

Julia's core selection order is not missing. An invocation-local explicit label wins; omitted selection scans
compiled definition order for the first authored marker and then falls back to row zero. Marker-required validation
makes the final branch unreachable for ordinary source. Loaded source, normalized reconstruction, and emitted
source all cross that validator, while a deliberately bypass-compiled generated-direct probe reaches the fallback.

Final admission has an independent prerequisite. The shared primary reference already reflects the cursor
program's removal of global `parse_mode`, but Julia has not completed that migration. Root core and route behavior
can be implemented without touching cursor ownership. The root admission consumer cannot claim exact shared 65x2
until cursor migration removes the 33 unrelated help/usage/trace failures. Task dependencies encode the acyclic
order rather than weakening either contract.

Related: [[root-rule-selection-precedence]], [[julia-frontend-validation]],
[[julia-runtime-rule-interpreter]], [[julia-generated-source-scaffold]], and
[[root-rule-rollout-roadmap-projection]].
