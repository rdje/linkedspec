---
id: actionir-lowering-stack
title: The ActionIR lowering stack has 12+ sub-owners (Scanner, CanonicalEvents, Diagnostics, StatementSplit, RewritePipeline, MethodLowering, FlowExpr, ValueExpr, ArrayPipeline, ControlFlow, DeclareMethod, Contracts) replacing what was once a giant mixed-semantics file
answers:
  - "how does ActionIR lowering work"
  - "what are the ActionIR sub-owners"
  - "how does helper code get from .spec to emitted Perl"
  - "what is the ActionIR pipeline"
  - "in what order are Perl action lowering contract groups assembled"
  - "where is the complete Perl action lowering contract catalog built"
date: 2026-09-06
status: current
tags: [architecture, actionir, lowering, pipeline]
evidence: "ARCHITECTURE_STATE.md §ActionIR Reading documents the ActionIR sub-owners. SESSION-STARTUP-READING.3.2.12 reverified EmitContext's fourteen registry keys: these thirteen ActionIR owners plus the separate Trace owner."
reverify: "ls perl/LinkedSpec/ActionIR/*.pm | wc -l; sed -n '/^sub build_action_lowering_contracts {/,/^}/p' perl/LinkedSpec/ActionIR/Contracts.pm"
---

The ActionIR subtree transforms `.spec` action code through a staged pipeline:

1. **Scanner** (4 rule families: PrimitiveBasicRules, PrimitivePipelineRules, FlowRules, LegacyRules) — finds helper-like and compatibility-like surfaces in action code, producing scan events with contract IDs
2. **CanonicalEvents** — converts scan events into canonical IR event forms (kind + args)
3. **Diagnostics** — tracks unresolved helpers, readiness ratios, compatibility-surface telemetry
4. **StatementSplit** — safely splits compound action statements
5. **RewritePipeline** — glues scan→classify→lower together
6. **MethodLowering** — the main lowering engine: converts method-call IR into Perl expressions. Handles 100+ helpers across scalar, numeric, array, hash, control-flow, and I/O families
7. **FlowExpr** — flow-expression lowering for composite conditionals and switch
8. **ValueExpr** — value-expression lowering for scalar access, direct nested access, array, and hash projections
9. **ArrayPipeline** — array-pipeline plan building from split/filter/transform chains
10. **ControlFlow** — marker-style and composite if/switch/else/endif lowering
11. **DeclareMethod** — declare/assign typed declarations
12. **Contracts** — the contract catalog: supported helper surfaces and how they lower
13. **MethodExpr** — method-like expression parsing (function-call shape recognition)

The lowering pipeline is now modular with real sub-owners instead of one giant mixed-semantics
file. Each owner assembles its default callback map through `OwnerDispatch::build_dep_map`.

Registry cardinality reverified on 2026-09-06: the thirteen listed ActionIR owners are a
subset of EmitContext's fourteen keys; `trace` maps separately to `LinkedSpec::Trace`.
See [[emitcontext-owner-registry]] for the exact source extraction command. This corrects
the original evidence's ambiguous “all 13 keys” wording; the dated pipeline inventory above
is not a fresh audit of every ActionIR module.

Contract assembly reverified on 2026-09-06 under `SESSION-STARTUP-READING.3.2.19`:
`Contracts::build_action_lowering_contracts` resolves required callbacks, then concatenates
fourteen groups in this source order: call/dispatch, recursive observation, inter-match gap,
recognition transaction, staged parse job, progressive span dispatch, return, capture/cursor,
compatibility IR passthrough, assignment/regex, array pipeline, dropped value, flow control,
and emit/declare. The staged and progressive groups delegate to their dedicated owners;
the other groups are built locally. This is source ownership/order evidence, not fresh
runtime admission or parity proof. The complete file is 2,513 baseline lines / 113,936 bytes.

Related: [[emitcontext-owner-registry]], [[scanner-rule-family-architecture]], [[ownerdispatch-shared-seam]].
