---
id: actionir-lowering-stack
title: The ActionIR lowering stack has 12+ sub-owners (Scanner, CanonicalEvents, Diagnostics, StatementSplit, RewritePipeline, MethodLowering, FlowExpr, ValueExpr, ArrayPipeline, ControlFlow, DeclareMethod, Contracts) replacing what was once a giant mixed-semantics file
answers:
  - "how does ActionIR lowering work"
  - "what are the ActionIR sub-owners"
  - "how does helper code get from .spec to emitted Perl"
  - "what is the ActionIR pipeline"
date: 2026-06-12
status: current
tags: [architecture, actionir, lowering, pipeline]
evidence: "ARCHITECTURE_STATE.md §ActionIR Reading: 12+ sub-owners documented; EmitContext owner registry maps all 13 keys"
reverify: "ls perl/LinkedSpec/ActionIR/*.pm | wc -l"
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

Related: [[emitcontext-owner-registry]], [[scanner-rule-family-architecture]], [[ownerdispatch-shared-seam]].
