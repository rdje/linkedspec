---
id: phase0-regression-structure
title: phase0_regression.t is a 44,000+ line single-file regression gate covering 19 shipped specs, all ActionIR lowering paths, scanner families, lifecycle blocks, and plugin migration checks
answers:
  - "what does phase0_regression.t cover"
  - "how is the regression test organized"
  - "how long does phase0 take to run"
  - "why is the test file so large"
date: 2026-06-12
status: current
tags: [testing, phase0, regression, ci]
evidence: "t/phase0_regression.t is 44,000+ lines; 1004 subtests; runs in ~3 min; covers spec compilation, ActionIR lowering, scanner, lifecycle, plugin migration"
reverify: "wc -l t/phase0_regression.t"
---

`t/phase0_regression.t` is the primary regression gate. At 44,000+ lines and 1004 subtests,
it covers:

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

Run time is ~3 minutes (195 CPU-seconds). The monolithic structure slows the edit/test cycle.
See `LINKEDSPEC-ENHANCEMENTS.3` for the planned split into focused modules.

Related: [[hosted-ci-disabled-run-local-gate]].
