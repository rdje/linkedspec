---
id: rust-trace-parity-design-inventory
title: TRACE-OBSERVABILITY.4.1 maps the neutral trace contract onto Rust owner boundaries
answers:
  - "what did TRACE-OBSERVABILITY.4.1 decide"
  - "where should Rust trace controls live"
  - "why must Rust trace primitives be core-visible"
  - "which Rust entrypoints need trace parity"
  - "what Rust trace work comes after TRACE-OBSERVABILITY.4.1"
  - "can Rust claim trace parity now"
date: 2026-07-04
status: current
tags: [trace, observability, rust, parity, task-tree, mdbook]
evidence: "rust/README.md; rust/linkedspec-core/src/{parser.rs,validation.rs,compiler.rs,types.rs}; rust/linkedspec-runtime/src/{spec_parser.rs,engine.rs,runtime.rs,source_emitter.rs}; docs/tasks/TRACE-OBSERVABILITY.md .4.1"
reverify: "rg -n 'TRACE-OBSERVABILITY\\.4\\.1|Rust variant trace status|Rust parity design inventory|Engine::execute|parse_spec_with_user_functions|execute_generated_parser' docs/tasks/TRACE-OBSERVABILITY.md docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md TOOLBOX.md rust/linkedspec-core/src rust/linkedspec-runtime/src"
---

`TRACE-OBSERVABILITY.4.1` closed the Rust trace parity design inventory before code. Rust does not yet claim trace
parity: the `.3.5` inventory found no Rust trace API/control hits outside corpus fixture text, and `.4.1` is a
design/ownership slice only.

The key design point is crate ownership. `linkedspec-core` owns `parse_spec`, `validate`, `compile`,
dependency-regex resolution, and the shared `CompiledSpec`/`CompiledRule` contract, so shared Rust trace levels,
configuration, sink routing, and event primitives must be visible from `linkedspec-core`. Placing trace primitives
only in `linkedspec-runtime` would leave core parser/compiler owners unable to emit contract-level trace events
without a dependency cycle.

`linkedspec-runtime` must reuse the same trace model for `parse_spec_with_user_functions`, staged parse-job
dispatch, `Engine::execute`, `Engine::execute_generated_with_plan`, `source_emitter::execute_generated_parser`,
generated parser modules, runtime context/match/mark state, interpreter branch execution, lifecycle block
execution, statement-form `if`/`switch`, acode/bcode child dispatch, repetition/AND/OR choices, and generated-rule
family plan dispatch.

`.4.2` has since added Rust controls, levels, sinks, event primitives, and traced entrypoint plumbing while
preserving default quiet behavior. The remaining leaves are `.4.3` compile/spec-parser/staged-dispatch trace
events, `.4.4` runtime/generated-plan branch events, and `.4.5` cross-variant trace parity proof plus the reusable
future-variant checklist.
