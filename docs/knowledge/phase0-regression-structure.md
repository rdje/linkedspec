---
id: phase0-regression-structure
title: Historical June 12 Phase0 size, timing and regression coverage inventory
answers:
  - "what does phase0_regression.t cover"
  - "how is the regression test organized"
  - "how long does phase0 take to run"
  - "why is the test file so large"
date: 2026-06-12
status: historical June 12 snapshot; counts, timing and coverage inventory are not current assertions
tags: [testing, phase0, regression, ci]
evidence: "The original June 12 card recorded 44,000+ lines, 1004 subtests, approximately 3 minutes and 195 CPU-seconds, with 19 shipped specs and the coverage topics below. REPO-HYGIENE.12 qualifies these existing observations without remeasurement. Current reach belongs to the completed run's TAP and retained acceptance proof."
reverify: "Read the original card at 11f6a87d136ce213899ca6a0cd98cf3f0833f720:docs/knowledge/phase0-regression-structure.md with git show. For a new run, follow TOOLBOX.md section 5.1 and retain complete TAP reach; wc -l alone cannot verify test counts or runtime."
---

`t/phase0_regression.t` is the primary regression gate. The original record dated
June 12, 2026 described 44,000+ lines and 1004 subtests. Its coverage inventory was:

- **19 shipped spec compilation** — every `specs/*.spec` must build a parser coderef and
  produce a descriptor with `language_agnostic_ready_ratio == 1.0000`
- **ActionIR lowering** — method-value, flow-expression, declare-method, control-flow,
  array-pipeline, contracts, method-lowering across fluent and structured surfaces
- **Scanner families** — PrimitiveBasicRules, PrimitivePipelineRules, FlowRules, LegacyRules
- **Lifecycle block coverage** — I/LS/LE/E/EX/IT/LX across composite-if, marker-if, switch,
  attached-branch, and deep-nesting parity tests
- **EmitContext** — owner dispatch, dependency routing, canonical IR events, diagnostics
- **Plugin migration** — extracted owners (RTLUtils, Timing, FSMGen, etc.), deleted wrappers,
  compatibility-surface verification
- **Memory architecture self-check** — called by `tools/run_ci_local.sh`

That record described runtime as approximately 3 minutes (195 CPU-seconds).
These numbers are historical observations, not a current suite census or a
performance expectation. This correction does not remeasure their original
accuracy or prove exhaustive coverage of current lowering paths.

Use the actual complete TAP, its final plan and the retained proof for the exact
run being assessed. The committed compiler-membership acceptance is recorded in
`docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.2.json`;
its scope does not turn one run's duration into a universal estimate.
`TOOLBOX.md` section 5.1 explains the reach check. The memory-architecture check
listed above belongs to the composed local gate, as the original bullet states.
See `LINKEDSPEC-ENHANCEMENTS.3` for the separately owned test-module split.

Related: [[hosted-ci-disabled-run-local-gate]].
