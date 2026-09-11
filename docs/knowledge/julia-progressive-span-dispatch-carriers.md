---
id: julia-progressive-span-dispatch-carriers
title: Julia privately carries progressive span dispatch through four admitted execution routes
answers:
  - "does Julia progressive span dispatch use a dedicated node"
  - "how does Julia compile dispatch_span"
  - "which Julia routes execute progressive span dispatch"
  - "how does Julia seed progressive dispatch authority"
  - "does generated Julia source serialize progressive callbacks"
  - "does Julia reject progressive dispatch in recognition transactions"
  - "why can recognition cleanup mask a Julia runtime error"
  - "is the Julia progressive dispatch consumer admitted in CI"
  - "what remains before Julia progressive rollout"
date: 2026-08-24
status: private Julia carriers admitted and independently recomposed; shared Lua carriers also admitted and recomposed
tags: [julia, progressive-parsing, actionir, generated-source, recognition-transaction, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.5.2 replaces the generic helper fallback with one exclusive ActionProgressiveDispatchSpanExpr carrying only target, literal parser id, literal top rule, and bare span binding. Five malformed operand cases, residual generic dispatch_span calls, and recognize_once-reachable rule/function graphs containing parser_registry_or_staged_dispatch reject before execution; reconstructed compiled input is validated again by the engine. ProgressiveExecutionSeed is opaque host authority whose start function creates fresh invocation budget and call state for each top-level execution while retaining shared cancellation, deadline, and step authority. Native, SpecFile-JSON reconstructed, generated-plan, and independently included emitted-module routes return the same detached child payload without advancing the parent cursor. Serialized and emitted logical data contain no callback, registry, fingerprint, source snapshot, cancellation token, or mutable invocation. The runtime also rejects a live recognition token defensively. Julia teardown preserves the primary error while the existing RecognitionTransaction authority restores and invalidates unfinished tokens. FUTURE-PARITY-BACKLOG.14.6.5.3 admits the same seven-group consumer at 62 assertions through ordinary discovery and one exact canonical route; no dormant carrier duplicate remains. The separate authority consumer remains dormant and GREEN at 210 assertions. Neutral governance records 9 Rust + 8 Dart + 9 Julia carrier paths, one Lua absence guard over 5 paths, 10 outward guards, 26 diagnostics, rollout 5/9, and 106 mutations."
evidence_update_2026_08_25_recomposition: "FUTURE-PARITY-BACKLOG.14.6.5.4 reruns the committed carrier at 62/62 and authority matrix at 210/210, plus complete ordinary Julia and all neutral/direct-dependent proofs, without production, test, fixture, executable-contract, generated-format, or CI-topology changes. Julia parent .14.6.5 closes unchanged at 5/9/106."
evidence_update_2026_08_25_lua_carriers: "FUTURE-PARITY-BACKLOG.14.6.6.2 leaves Julia behavior/admission unchanged while replacing the Lua guard with 9 dormant Lua carrier paths. Julia 62/62 agrees with neutral rollout 5/9/106 and zero backend guards."
evidence_update_2026_08_25_lua_recomposition: "FUTURE-PARITY-BACKLOG.14.6.6.4 leaves Julia behavior/admission unchanged at 62/62 while independently recomposing both admitted Lua rows. All six private runtime rows are current at 7/9/112; typed recurrence remains pending for .14.6.7."
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/progressive_span_dispatch_contract_test.jl\")'"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using Test; include(\"julia/test_dormant/progressive_span_dispatch_authority_test.jl\")'"
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "test \"$(rg -c 'include\(\"progressive_span_dispatch_contract_test[.]jl\"\)' julia/test/runtests.jl)\" -eq 1"
---

# Private admitted Julia progressive carriers

The authored assignment is one whole-statement node:

```text
value = dispatch_span("expr-v1", "Expr", span)
```

Only its target, two static logical identities, and bare span-binding name enter ActionIR and generated data. A
trusted host supplies the unexported opaque execution seed. Every top-level native or generated execution starts
fresh invocation accounting; nested dispatch in that execution shares the seed's narrowing authority and limits.

Static effect closure forbids recognition of any rule that can reach this non-rollbackable node through rule or
user-function calls. The runtime still checks live tokens for externally reconstructed input. The recognition
authority restores and invalidates unfinished tokens during unwind; invocation teardown preserves a primary
progressive denial instead of replacing it with the resulting secondary token-terminal diagnostic.

Native, reconstructed, generated-plan, and independently included emitted-module routes delegate through the
same private carrier. The emitted adapter accepts host authority as an execution argument but never serializes it.
The exact consumer is admitted through ordinary and canonical discovery by `.14.6.5.3`, which promotes only
Julia rollout. `.14.6.5.4` independently recomposes that topology unchanged and closes the Julia parent.

Related facts: [[julia-progressive-span-dispatch-authority]],
[[julia-progressive-span-dispatch-dormant-red]], [[julia-progressive-span-dispatch-admission]],
[[progressive-span-dispatch-audit-plan]], and
[[julia-recognition-transaction-integration]].

## September 11 reading qualification

Julia .1.15 reads the exclusive dispatch assignment and its immediate runtime
adapter in Interpreter3611-3730. The receiver-write guard runs before dispatch;
absent host authority fails, the span value is copied, live recognition tokens are
reported to the private authority, and the detached child result is stored only
after successful dispatch. The existing four-carrier consumer passes 62 assertions.

The earlier claim that nested calls share narrowing authority is limited by
[[julia-progressive-authority-boundary-gaps]]: startup .37.1 owns the confirmed
nested grant/budget inheritance defects. Static effect claims are limited by
[[julia-recognition-effect-integration-gap]], owned by Julia .2.3. The direct live-
token defense does not close the structural effect-classification gap. Current
neutral progressive rollout is 9/9 with 116 contract and 60 public mutations; older
5/9/106 and 7/9/112 snapshots above are dated history. No repair is closed here.
