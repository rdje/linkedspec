---
id: julia-hash-view-result-guards
title: Julia Hash-view Arrays retain guarded consumers and their own input policy
answers:
  - "why do Julia sorted_keys and sorted_values run incompatible Hash operands"
  - "how do Julia Hash-view Arrays retain rejection through copy logical and with"
  - "what are Julia initial Number null and Array Hash-view policies"
  - "do Julia free and receiver extra Hash-view operands evaluate effects"
  - "does Julia Hash-view guarding change scalar_result or call_index mutation policy"
  - "which task completes Julia Hash-view76.4"
date: 2026-11-07
status: bounded Julia76.4 focused-checked; installed Lua and full admission remain
tags: [julia, hash, arrays, guards, source, grammar, copy, scalar]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.76.4; docs/checkpoints/hash-view-result-guard-julia-2026-11-07/REVIEW.md retains actual33/four routes26healthy7RED, unchanged normal156PASS28FAIL to184PASS, direct315,19 own profiles/33 actual module-parsed pairs exact and first readonly recovery/eight corruptions PASS."
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test; for path in ARGS; include(path); end' julia/test/hash_view_result_guard_composition_test.jl julia/test/constructor_result_composition_test.jl julia/test/value_copy_test.jl julia/test/receiver_copy_arity_test.jl"
  - "bash tools/run_python_project_data.sh docs/checkpoints/hash-view-result-guard-julia-2026-11-07/review.py"
---

Actual unchanged Julia33 independently exposes seven guard failures: Array views
reach set_key without kind ownership, so K/V and later W/D effects run.
Interpreter.jl now recognizes canonical free-one/zero-extra first-view result
roles in current guards. Separate single first-source permission precedes later
Count/CountKeys ownership; earlier produced/selected/copied owners stay guarded.
Original ordered producers, nested kinds, snapshots, source/errors, depth and
signatures remain. Scalar-result initialization/assignments/guard and enumerate/
call_index mutation policy stay exact. Registered-function receiver, unknown,
keyword, traversal and non-with trailing forms gain no new role.

Own initial Number/null/Array views return[]; null-with returns0/W and valid
Hash-with2/W. Produced Count/CountKeys/Length remain null. Both free and receiver
extra operand profiles retain ran/AW, independently of Dart's free W. Needed
native/restored errors preserve text/class and five diagnostic fields; plan/
fresh keep GeneratedSourceException. These are finite preservation fences,
not new malformed-call or universal wrong-kind contracts.

Actual grammar bytes precede SDK invocation and are printed/supplied through
parser_spec_source. Same33 normal moves156PASS28FAIL to184PASS. Direct new184+
constructor116+value-copy12+receiver-arity3 passes315 under strict depwarn; direct
stderr is empty. After's separate stderr contains successful package precompilation.
All26 healthy observations/19 profiles/33 emitted-parsed pairs stay exact across
four actual phases. First readonly recovery/eight corruption controls pass with
empty decoded own stderr. Rebuild applications/runtime; emitted bytes/format stay.

Full native/cache/transitive/toolchain custody4.2/SESSION5, source/registered-function
contexts, general isolation, canonical registration23.4.1 and full23.4 remain
separate. Fresh Modules share runtime/process. Independent installed Lua76.5
requires own source/arity/error profiles and actual grammar before SDK use;
declared Lua5.4 remains separate. Historical recovery is not latest-runtime proof.
