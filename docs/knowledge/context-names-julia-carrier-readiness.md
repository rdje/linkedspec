---
id: context-names-julia-carrier-readiness
title: Julia preserves bounded closing-name context across five public carriers
answers:
  - which Julia context-name carriers retain an engine after rejection
  - do Julia generated parsers preserve exact closing-name statuses and Unicode spans
  - how are fresh Julia context-name modules loaded and verified
date: 2026-09-27
status: bounded julia carrier proof verified; canonical context reconciliation remains
tags: [language-readiness, context, julia, generated-source, recovery]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.5 passes253 assertions: context30, original nesting30, existing emitter65 and strict-document128. Five context routes each execute90 calls/three mutants, with68 recoveries on two retained engines. Both emitted hosts require actual success, exact report and cleanup. Storage remains22 owners/five locked package trees."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include("julia/test/source_emitter_test.jl"); include("julia/test/sexpr_document_v1_test.jl")'"
---

`docs/language-readiness/context-names.md` owns exact scope and commands. Native and SpecFile-JSON reconstructed
engines retain their instance over34 typed rejections/immediate successes each. Public generated v2 runs on
both compiled forms and the emitted entry create an engine per invocation, proving isolation. Only typed
RuntimeExitNow with the authored1/2/3 counts as rejection; nothing or another failure cannot pass. JSON kinds
remain exact, including Bool versus Number. Comparison/state/span mutants expose the authored wrong outcomes.

The existing managed emitter scratch owner and private-depot host now take explicit fixture options; nesting
defaults and both original grammar/oracle pairs stay exact. A data config selects emitted identities/options;
four independent modules validate metadata/plans and actual execution. Latest-world binding access and calls
remain unchanged, as do strict merged-output JSON parsing and success status. Both scratch directories are
verified absent after their scopes. No private generated-family invocation, runtime, manifest or format change.
Related: [[nested-tree-julia-carrier-readiness]], [[context-names-public-native-readiness]],
[[context-names-dart-carrier-readiness]].
