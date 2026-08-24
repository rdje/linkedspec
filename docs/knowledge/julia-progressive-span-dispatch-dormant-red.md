---
id: julia-progressive-span-dispatch-dormant-red
title: Julia progressive span dispatch has a dormant RED at the dedicated-node boundary
answers:
  - "is progressive span dispatch implemented in Julia"
  - "where is the dormant Julia progressive span dispatch RED consumer"
  - "how does Julia currently compile dispatch_span"
  - "what happens when Julia executes dispatch_span today"
  - "which Julia carriers preserve the progressive dispatch RED"
  - "does ordinary Julia test discovery run the progressive dispatch consumer"
  - "does canonical CI run the Julia progressive dispatch consumer"
  - "which leaves implement Julia progressive span dispatch"
date: 2026-08-24
status: exact dormant RED current; Julia authority, carriers, admission, and recomposition pending
tags: [julia, progressive-parsing, red-test, generated-source, staged-registry, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.5.0 adds julia/test_dormant/progressive_span_dispatch_contract_test.jl outside ordinary and canonical discovery. The consumer derives neutral 4/9/103 truth, proves the unrelated staged function-body registry rejects expr-v1 at resolve, and compiles the exact reserved assignment. Current Julia retains one generic ActionCallExpr named dispatch_span and no progressive_dispatch_span / PROGRESSIVE_DISPATCH_SPAN node. Native, SpecFile-JSON reconstructed, generated-plan, and independently included emitted-module routes all reach the same unsupported runtime helper 'dispatch_span' in rule Top boundary; the generated routes preserve exact execute_generated/generated_execution_failed identity. The explicit repository-routed run passes 55 assertions and fails only its one dedicated-node assertion. Production sources retain committed SHA-256 identities ActionAst 9f74d633, ActionParser 8b31a114, ActionContracts c0ab5f28, CompiledSpec 7176052c, Interpreter 57c1bd1a, staged registry 211bad8b, and SourceEmitter 8a835429. Leaf .14.6.5.1 owns authority/core, .2 owns the node and four carriers, .3 alone owns ordinary/canonical admission plus Julia rollout, and .4 independently recomposes the admitted topology without behavior."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using Test; include(\"julia/test_dormant/progressive_span_dispatch_contract_test.jl\")' 2>&1 | rg '55 +1 +56'"
  - "! rg -q 'progressive_span_dispatch_contract_test[.]jl' julia/test/runtests.jl tools/run_ci_local.sh"
---

# Dormant Julia progressive-dispatch boundary

Julia accepts the reserved authored assignment but currently compiles its right-hand side as an ordinary
`ActionCallExpr`. Runtime helper resolution rejects `dispatch_span` with the existing unsupported-helper boundary;
that consistent failure is not child-parser execution. Rebuilding the parsed `SpecFile` from JSON, executing its
validated generated-v2 plan, and independently including a freshly emitted module preserve the same outcome.

The emitted module reconstructs and compiles the same normalized spec before entering the shared runtime. Its
generated failure records the emitted source identity, `execute_generated` stage, `generated_execution_failed`
code, `Top` rule, `default` family, and the same unsupported-helper detail. The generated source contains no
progressive authority, registry, or dedicated-node token.

The consumer lives under `julia/test_dormant/`, is absent from `julia/test/runtests.jl`, and has no route in
`tools/run_ci_local.sh`. Its neutral/staged, generic-AST, and four-carrier groups are GREEN at 55 assertions. One
final assertion deliberately requires the generic call to disappear and exactly one
`progressive_dispatch_span` node to exist; that is the sole RED.

The implementation split is deliberately disjoint: `.14.6.5.1` adds private immutable authority without touching
the final path; `.2` adds the dedicated logical node and four dormant carriers; `.3` admits the unchanged consumer
and advances only Julia rollout; `.4` independently recomposes the admitted generated/emitted topology and
continuity state.

Related facts: [[progressive-span-dispatch-audit-plan]], [[julia-staged-function-body-registry]],
[[julia-generated-source-v2-rule-local-cursor]], [[julia-recognition-transaction-integration]],
[[dart-progressive-span-dispatch-dormant-red]], and [[rust-progressive-span-dispatch-admission]].
