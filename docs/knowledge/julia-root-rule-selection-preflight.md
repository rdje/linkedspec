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
status: superseded by Julia root core/routes and cursor implementation; rollout admission remains pending at 4/7
tags: [julia, root-rule, top-rule, markerless, validation, generated-source, descriptor, diagnostics, cursor, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.4.0 runs the exact 65-case shared primary manifest with POSIXLY_CORRECT unset and set. Julia passes 31/65 both times. The identical failures are 22 help/usage plus 11 medium-or-higher request traces caused by the separately pending global parse_mode removal, and one root-owned success_markerless_first_authored_rule compile failure. Explicit ordinary override, first-authored-marker default, unknown selector, default seek, and AND consume pass. Exact API probes prove Parser preserves ordered RuleHeader.is_top; Validator._check_top_rule_exists blocks normal markerless source before strict and other checks; bypass-compiled native/generated direct execution already implements explicit > first marker > first rule; loaded/normalized/emitted routes re-enter validation. Unknown explicit selection uses rule_lookup; zero default uses top_rule_selection; explicit selection against zero state incorrectly reaches rule_lookup. Descriptor meta preserves definition_order and per-rule is_top but lacks entry_rule_contract and retains parse_mode=seek. Low runtime trace is silent; high trace records only effective top_rule. Generated unknown selection collapses to GeneratedExecutionFailedCode. Pkg.test reaches the primary arguments suite and fails 1/57 on the cursor-owned help line; standalone corpus execution passes 105/105. Root governance stays 4 complete / 3 pending with 34 mutations. Safe order is root core .4.1, root routes .4.2, Julia cursor .9.1.6, then exact 65x2 root admission .4.3. No Julia behavior changes in the preflight."
evidence_update_2026_07_18_core: "Superseded for current core status by [[julia-root-rule-selection-core]]. Leaf `.4.1` removes marker-required validation, centralizes ordered selection and portable failures before user code, publishes descriptor identity, and improves shared primary to exact 32/65 twice. Routes `.4.2`, cursor `.9.1.6`, and admission `.4.3` remain pending, so rollout stays 4/7."
evidence_update_2026_07_18_routes: "Superseded for current composed behavior by [[julia-root-rule-selection-routes]]. Leaf `.4.2` converges loaded, normalized, generated, emitted, trace, loader-error, and generated-error routes without advancing rollout. Cursor `.9.1.6` and admission `.4.3` remain pending."
evidence_update_2026_07_18_dependency_order: "After clean route commit `42c98dfe`, exact task dependencies restore the ADR 0044 backend order: active Dart admission `.9.1.5.6` must close parent `.9.1.5`; Julia cursor `.9.1.6` then has both `.9.1.5` and root-routes `.4.2`; root admission `.4.3` follows Julia."
evidence_update_2026_07_18_cursor_option_removal: "FUTURE-PARITY-BACKLOG.9.1.6.1-.5 now implement normalization, intrinsic runtime, descriptor v1, generated v2, and public/CLI removal. The historical 33 cursor mismatches are gone and shared primary is 65/65 twice; composed cursor .6 and root .4.3 admission remain."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia; source=\"Earlier:\\n /x/\\n\\nMarked::\\n /x/\\n\"; compiled=compile_spec(parse_spec(source)); println(runtime_parse(LinkedSpecRuntimeEngine(compiled), \"x\"; top_rule=\"Earlier\").matched)' && bash tools/check_julia_primary_cli.sh"
---

# Julia root-selection preflight

Julia's core selection order is not missing. An invocation-local explicit label wins; omitted selection scans
compiled definition order for the first authored marker and then falls back to row zero. Marker-required validation
makes the final branch unreachable for ordinary source. Loaded source, normalized reconstruction, and emitted
source all cross that validator, while a deliberately bypass-compiled generated-direct probe reaches the fallback.

Final admission has an independent prerequisite. The shared primary reference already reflects the cursor
program's removal of global `parse_mode`, and Julia now implements that migration through `.9.1.6.5`. Root core
and route behavior stayed independent while those 33 help/usage/trace failures were removed. The remaining cursor
admission `.9.1.6.6` and root admission `.4.3` still have separate topology obligations; exact bytes alone do not
advance either rollout.

Related: [[root-rule-selection-precedence]], [[julia-frontend-validation]],
[[julia-runtime-rule-interpreter]], [[julia-generated-source-scaffold]], and
[[root-rule-rollout-roadmap-projection]], [[julia-global-cursor-option-removal]].
