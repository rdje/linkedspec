---
id: julia-open-arity-concat-result-guards
title: Julia concat results retain guards across existing one or more Array inputs
answers:
  - "why does Julia unary or three Array concat run rejected Hash operands"
  - "which Julia concat result arity selector owns later guards"
  - "where is own Julia concat full error and source proof retained"
  - "which Julia legacy concat operand continuations transfer"
  - "does Julia concat preserve initial and invalid function signature policies"
date: 2026-11-12
status: bounded80.4 implemented with focused proof; full admission separate
tags: [julia, arrays, concat, guards, functions, errors, custody]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.80.4; docs/checkpoints/array-concat-open-arity-julia-2026-11-12/REVIEW.md;508/four routes/20 supported/four separate compatibility/484 preserved/80 initial/eight invalid signatures; old24-current508/direct4959 assertions/readonly10/current516."
reverify:
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P docs/checkpoints/array-concat-open-arity-julia-2026-11-12/review_qualified.py"
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P docs/checkpoints/array-concat-open-arity-julia-2026-11-12/review_publication.py"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test; include(ARGS[1])' julia/test/array_concat_open_arity_result_guard_composition_test.jl"
---

At activation952f8a022, Interpreter.jl6981 recognizes concat result ownership only
at count2 while existing terminal producers accept the recorded one/two/three
Array forms. One line admits count>=1 and one normal include selects the proof.
The existing persistent actual-kind guard then rejects Hash operands before K/V
and skips later D/W. First producers/signatures/function dispatch/formats remain.
User-function resolution near4343 rejects unmatched arity before entering the
argument evaluator; fixed/rest failure observations stay exact.

Own508/four routes establish20 supported targets/four separate legacy operand
continuations/484 preservation, with80 initial/eight invalid-signature fences.
Exact own legacy terminal contrasts retain SX or SA and scalar operand elements;
only their four old continuation route records transfer, with no portable input
authority. Complete errors/field absence, authored source identities, snapshots,
nested Bool/null/Number values and source/additional Array/rest order remain.

Old24-current508/private same-path/direct4959 assertions pass; first historical
readonly10/current516 and3048 epoch pairs retain full channels,
input identities/modes and new parsed/module first-use order. Successful root
precompilation and old Test stderr remain. Older direct transient strings gain
no new custody credit. Current identity is point-in-time; historical recovery
uses no SDK. Full native/cache/transitive/toolchain/OS4.2/SESSION5 and wider
source/context/discovery/admission23.4 remain open. Rebuild Julia applications.

Related: [[julia-callable-array-transform-result-guards]],
[[julia-array-transform-result-guards]], [[array-concat-open-arity-result-selection]].

The retained unified diff is compressed byte-exactly after the cached whitespace
check rejects its blank context line. Use review_qualified.py: the original
reader/seal/first0 remain unchanged; only the exact compressed-patch read is
substituted. All ten original controls and two patch corruption controls pass.
Original document publication images remain historical; separate patch-publication
images retain the current entrypoint qualification. No SDK/producer replay.
