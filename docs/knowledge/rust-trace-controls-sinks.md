---
id: rust-trace-controls-sinks
title: TRACE-OBSERVABILITY.4.2 adds Rust trace controls, levels, sinks, and traced entrypoints
answers:
  - "does Rust currently have trace controls"
  - "what did TRACE-OBSERVABILITY.4.2 add"
  - "where is the Rust trace API"
  - "how does Rust configure trace sinks"
  - "which Rust entrypoints have traced variants"
  - "can Rust claim trace parity after TRACE-OBSERVABILITY.4.2"
date: 2026-07-04
status: current
tags: [trace, observability, rust, parity, task-tree, mdbook]
evidence: "rust/linkedspec-core/src/trace.rs; rust/linkedspec-core/src/{parser.rs,validation.rs,compiler.rs}; rust/linkedspec-runtime/src/{engine.rs,spec_parser.rs,staged_parser_registry.rs,source_emitter.rs}; rust/linkedspec-runtime/tests/trace_controls.rs; docs/linkedspec-book/src/public-api/trace-api.md"
reverify: "cargo test -p linkedspec-core trace && cargo test -p linkedspec-runtime --test trace_controls && cargo test -p linkedspec-runtime --test source_emitter"
---

`TRACE-OBSERVABILITY.4.2` adds the Rust trace control layer but does not complete trace parity.

The shared Rust API lives in `linkedspec_core::trace` and is re-exported by `linkedspec_runtime::trace`. It includes
`TraceConfig`, `TraceLevel`, `TraceSinkMode`, `TraceEmitter`, `DUMP_NONE`, `DUMP_LOW`, `DUMP_MEDIUM`, `DUMP_HIGH`,
`DUMP_FULL`, and `DUMP_DEBUG`. `TraceConfig::from_env()` reads `LINKEDSPEC_TRACE_LEVEL`,
`LINKEDSPEC_DUMP_VERBOSITY`, `LINKEDSPEC_TRACE_FILE`, `LINKEDSPEC_TRACE_MIRROR_STDOUT`,
`LINKEDSPEC_TRACE_RESET_FILE`, and `LINKEDSPEC_TRACE_EMOJI`. Sink behavior supports stdout, routed file, mirrored
stdout+file, and routed-file reset/truncate.

Rust now exposes opt-in traced entrypoints beside the existing default-quiet APIs for core `parse_spec`,
`validate`, and `compile`; runtime full-spec user-function parsing; staged parse jobs; `Engine::execute`;
generated-plan execution; generated parser execution; and newly emitted generated modules (`parse_with_trace(...)`
beside `parse(...)`).

This slice intentionally landed controls and sink plumbing only. `.4.3` has since added compile/spec-parser/
staged-dispatch event emission, `.4.4` has since added runtime/generated-plan branch, lifecycle, and mark/capture
event emission, and `.4.5` has since closed cross-variant parity proof for the documented external capability
contract.
