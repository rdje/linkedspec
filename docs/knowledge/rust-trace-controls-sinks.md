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
date: 2026-09-07
status: current
tags: [trace, observability, rust, parity, task-tree, mdbook]
evidence: "rust/linkedspec-core/src/trace.rs; rust/linkedspec-core/src/{parser.rs,validation.rs,compiler.rs}; rust/linkedspec-runtime/src/{engine.rs,spec_parser.rs,staged_parser_registry.rs,source_emitter.rs}; rust/linkedspec-runtime/tests/trace_controls.rs; docs/linkedspec-book/src/public-api/trace-api.md"
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-core --lib trace::tests -- --test-threads=1 && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test trace_controls && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter"
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

September 7 reading checkpoint `SESSION-STARTUP-READING.3.3.10` reads the complete
715-line core implementation. An event is enabled only for a positive event level
at or below the configured threshold. Environment level takes precedence over the
legacy dump fallback. `with_trace_file` changes a default stdout sink to routed output;
explicit route mode without a file discards output, while mirror mode without a
file still writes stdout. File creation/reset occurs when the emitter is built.

`emit_line`, `emit_event`, `enter_scope`, and `exit_scope` return I/O failures; `trace_decision`
intentionally discards its event result and returns the original boolean. These
are source-level behavior observations, not new sink-error guarantees or a fresh
full-runtime parity claim. The typed caller-owned diagnostic-output channel is a
separate API: [[rust-diagnostic-output-events]]. Corrective trace work later closed
under `.5.4`: [[rust-trace-compile-spec-parser-events]].

The primary CLI's portable `compile:ok`/`invoke:ok` protocol uses its own adapter;
it is not a direct test of this richer emitter. See [[rust-canonical-primary-cli-trace]].

The September 7 managed locked/offline single-thread core target passes 7/7,
with 194 unrelated tests filtered out. This fresh result covers the selected level,
configuration, route/reset/mirror, scope/decision and log/dump tests only. It does
not rerun runtime trace controls, source emission or cross-variant parity.
