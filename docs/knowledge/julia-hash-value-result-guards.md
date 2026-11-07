---
id: julia-hash-value-result-guards
title: Julia pure Hash-helper results retain guards and initial producer policies
answers:
  - "why do Julia merge_hash set_key rename_key drop_keys pick_keys run incompatible Array operands"
  - "which Julia guard dispatcher owns pure Hash-helper results"
  - "what are Julia initial Number null Array Hash-helper and excluded arity policies"
  - "why did Julia with-ending Hash chains evade the first repair"
  - "does Julia Hash-result repair change scalar_result or call_index mutation policy"
  - "why did the Julia Hash-result recovery reader expect1.12.6 instead of1.12.7"
  - "which task completes Julia Hash-valued77.4"
date: 2026-11-07
status: bounded Julia77.4 focused-checked; installed Lua and full admission remain separate
tags: [julia, hash, results, guards, source, with, grammar, recovery]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.77.4; docs/checkpoints/hash-value-result-guard-julia-2026-11-07/REVIEW.md retains own89/shared28 plus61 fences,13 original failures/76 healthy; normal458PASS52FAIL then partial498PASS12FAIL then510PASS; direct825, private exact old/current13RED/89PASS and qualified readonly0/empty stderr/eight controls. Original reader version failure is retained."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/hash-value-result-guard-julia-2026-11-07/review_observed_version.py"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test; for path in ARGS; include(path); end' julia/test/hash_value_result_guard_composition_test.jl julia/test/hash_view_result_guard_composition_test.jl julia/test/constructor_result_composition_test.jl julia/test/value_copy_test.jl julia/test/receiver_copy_arity_test.jl"
---

Actual Julia89 independently exposes13 guard gaps: both wrong take forms return[]
with A; later bodies run AW/ADW. Interpreter.jl's ordinary retained-kind list omits
pure Hash-valued roles. Canonical positional merge2, set/rename3, drop/pick>=2
(including receiver) now own later actual-kind/rejection checks. One first-helper
source permission excludes earlier retained/view/size/copy/constructor owners.
Scalar_result initialization/assignments/guard, enumerate/call_index mutation
policy and complete Hash producer bodies remain exact.

First repair498PASS12FAIL is preserved. Public parse_action_block shows with's
block_value; actual compile_spec action_payloads normalize it into
ActionCodeblockArgumentExpr. Only this existing single contextual with operand
joins ordinary continuation operands. Explicit deferred literals, other callbacks,
unknown/keyword/traversal/non-with trailing and unassessed registered-function
receiver roles gain no authority. Preserve actual source/snapshot/key/splice/depth/
collision/mutation policy; see [[hash-value-result-guard-selection]].

Own Number/null/Array controls keep overlay Hashes for merge, original values for
set/rename/drop and null for pick. Initial with runs W/count0 except merge1. Six
extra forms retain SATW, four zero-key forms AW; these are fences, not canonical
or portable fallback authority. Six prior result owners still reject before A/W.
Four needed errors keep complete native/restored text/class/five diagnostic
fields and plan/fresh GeneratedSourceException framing.

Unchanged89/four routes now510PASS; direct825 passes. Exact old/current private
SDKs at one path, with compiled modules disabled and actual module path checked,
reproduce13RED/89PASS with89 full frames. All76 healthy observations/65 profiles/
89 parsed-module pairs remain exact across original/partial/complete/private.
Actual inputs/grammar/instruments precede SDK use, artifacts precede execution,
and full SDK/reader channels are gzip from first physical storage.

First review.py fails its manifest-derived1.12.6 host assumption; every actual
captured --version says1.12.7. A manifest's recorded creation version does not
establish the current executable version. Original reader/failure/seal stay
unchanged. Separate review_observed_version.py derives coherent actual host
bytes; its first recovery0/empty stderr/eight effective corruptions passes.
Reverify recovers historical proof, not a future host-version or runtime verdict.

Rebuild Julia applications/runtime; emitted/parsed format stays unchanged. Fresh
Modules share runtime/process. Full source/context/native/cache/transitive custody
4.2/SESSION5, general isolation, registration23.4.1 and full23.4 remain separate.
Independent installed Lua77.5 assesses its own policies next.
