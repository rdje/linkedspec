---
id: julia-facade-action-model-reading
title: Julia facade and ActionIR prefix assemble typed data without a second command runtime
answers:
  - where does Julia assemble its native public module
  - do Julia command entrypoints implement their own parser
  - which Julia ActionIR constructor ranges were read at startup
  - are Julia ActionIR structs recursively immutable
  - what does the focused Julia punctuation consumer actually verify
date: 2026-09-11
status: dated bounded reading and focused verification
tags: [julia, startup, actionir, facade, cli, verification]
evidence: "JULIA-STARTUP-READING.1.2 reads 1500 fragments /38998 baseline-identical bytes: README 964-969, both five-line commands, the complete 520-line module and ActionAst 1-964. Cumulative reading is 2/52 groups, 2571 fragments /104408 bytes, six complete files. All 452 names returned by names(LinkedSpecJulia) are defined; both managed CLI help calls and 55 punctuation assertions pass, plus the neutral 6/4/6 check. No runtime repair or full gate."
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); public_names=names(LinkedSpecJulia); @assert all(name -> isdefined(LinkedSpecJulia,name), public_names); println(length(public_names)); include(\"julia/test/punctuation_light_zero_arg_contract_test.jl\")'"
  - "bash tools/run_julia_project_data.sh --project=julia julia/bin/linkedspec_julia.jl --help"
  - "bash tools/run_julia_project_data.sh --project=julia julia/bin/corpus_runner.jl --help"
  - "bash tools/run_python_project_data.sh tools/check_punctuation_light_zero_arg_contract.py"
---

# Owned source and comprehension

The exact scope and digest live in `docs/tasks/JULIA-STARTUP-READING.md` child .1.2.
Reading finishes the README, both command files and module facade, then stops at
`ActionControlSwitchExpr`'s `args` field in `julia/src/action/ActionAst.jl` line 964.
Its remaining fields, constructors and JSON methods belong to .1.3.
The separately read 167-line punctuation consumer was inspected for focused proof;
it receives no advance credit against its later numeric reading owner.

The two five-line commands load `LinkedSpecJulia` and exit with `run_cli(ARGS)` or
`run_corpus_runner(ARGS)`. The module imports Base64, JSON3, Random and SHA,
declares its native API, and includes 37 implementation files in dependency order.
Its status helper returns stable package and repository-relative entrypoint data.
All 452 public names reported by `names(LinkedSpecJulia)`, including the module
name, are defined on Julia 1.12.7. That is binding completeness, not proof that
every API implementation is correct or that every included file has been read.

The ActionIR prefix defines source spans, expression/statement/argument families,
recognition checkpoint/attempt/observe/commit/rollback nodes, progressive dispatch
and inert staged-job declaration data, direct/derived text plans, typed options,
access and nested-write segments, aggregate literals, explicit/contextual callable
blocks, assignments, receiver mutation/continuation, fluent calls and control
nodes. Constructors assign fixed kinds and copy/coerce their immediate fields.
Many fields are vectors containing other nodes; immutable Julia `struct` fields
do not make this whole AST recursively immutable. Staged option/segment sequences
use tuples. These data definitions neither execute callbacks nor independently
validate the complete parser contract.

# Focused consumer and preserved obligations

The existing punctuation consumer passes all 55 assertions. It compares bare and
parenthesized semantic ASTs after removing source metadata, retains identifiers,
rejects six invalid forms, and checks native/generated-plan values. Its emitted
proof extracts normalized hex JSON and recompiles that data; it does not load and
execute an independent emitted module. Both command help processes exit zero.
The neutral checker passes six standalone forms, four receiver forms and six
invalid cases with its exact fixture.

Missing-needle `contains` remains numeric zero in both spellings in this consumer.
[[punctuation-light-receiver-arity-calibration]] and `FUTURE-PARITY-BACKLOG.5`
already own that semantic drift; alias equality does not close it. No new runtime
defect or duplicate repair root follows from this check.
The final README window adds two more bare corpus commands at lines 964–965 to
startup .41.7's existing locality-teaching repair. They were not executed unmanaged.

[[julia-action-ast-parser]] now frames its original structural-only milestone as
historical and points to current compilation/runtime evidence, preserving its
punctuation rules. No implementation, contract, fixture, complete component gate,
canonical CI or PGEN/RGX build changes accompany this reading checkpoint.
