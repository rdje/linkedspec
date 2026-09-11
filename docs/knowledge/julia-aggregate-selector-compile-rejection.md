---
id: julia-aggregate-selector-compile-rejection
title: "Julia rejects exact aggregate selectors across compiled and generated ActionIR"
answers:
  - "how does Julia reject array name and hash name selectors"
  - "what is the Julia aggregate selector removed diagnostic"
  - "are Julia selectors rejected inside dead code"
  - "are Julia selectors rejected inside unused user functions"
  - "does generated Julia reject caller constructed selector AST"
  - "which array and hash constructors remain valid on Julia"
  - "where was Julia selector compatibility dispatch removed"
date: 2026-07-12
status: historical retirement proof; callable-body validation gap remains open
tags: [julia, actionir, compiler, generated-source, bindings, retirement, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.12.1.8.4 adds recursive typed-ActionIR detection in julia/src/action/ActionAst.jl and whole-CompiledSpec validation in julia/src/compiler/CompiledSpec.jl. Normal compilation, dead control bodies, valid deferred fluent calls, unused function bodies, generated emission, generated-plan validation, and caller-constructed compiled payloads reject exact selectors. Selector-specific runtime reads, set/push/receiver targets, split/transform wrappers, and target recognizers are deleted. The focused suite passes 59/59 across all six neutral invalid cases and all eight retained constructor/literal classes. The authoritative gate passes 1,339 package assertions, CLI 61x2, and 105 corpus; the recurring executable scan is zero-positive/15 classified."
reverify: "bash tools/run_julia_local.sh"
---

# Julia aggregate-selector compile rejection

**Current limitation, September 11:** explicit and contextual callable bodies bypass the recursive selector
visitor. Native, reconstructed, generated-plan and separately included emitted-module controls all accept
forbidden array/hash selectors. JULIA-STARTUP-READING.2.1 owns the repair; exact causal evidence is in
[[julia-callable-selector-validation-gap]]. The original retirement proof below predates callable-body coverage.

## Historical retirement milestone

Julia rejects the removed exact one-bare-identifier `array` and `hash` call shapes before execution with
`aggregate_selector_removed surface=<surface> identifier=<name> replacement=<name>`.

The validator walks every typed ActionIR expression family in compiled rule payloads. Because user-function bodies
and some edge fluent calls retain deferred source, whole-compiled-state validation also parses and inspects every
valid deferred body/call while preserving the historical timing of unrelated parse failures. Generated-source
emission and generated plan/execution entry repeat the same validation rather than trusting caller-constructed
`CompiledSpec` values.

Runtime compatibility is deleted: `array`/`hash` no longer perform one-name reads, `set` and `push` no longer accept
wrapper targets, receivers no longer unwrap them, mutable split/collection transforms no longer recognize them,
and the target-name recognizers no longer exist. Empty, multi-argument, quoted, computed, and direct literal forms
remain distinct constructors/values.

Related facts: [[julia-uniform-binding-runtime]], [[uniform-binding-neutral-contract]],
[[spec-facing-aggregate-selector-retirement-inventory]], [[rust-aggregate-selector-compile-rejection]],
[[dart-aggregate-selector-compile-rejection]].
