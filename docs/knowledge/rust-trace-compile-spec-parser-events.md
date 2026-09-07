---
id: rust-trace-compile-spec-parser-events
title: Rust traced compilation emits events and enforces the ordinary static validators
answers:
  - "does Rust currently emit compile trace events"
  - "what did TRACE-OBSERVABILITY.4.3 add"
  - "which Rust trace events existed before runtime branch parity"
  - "does Rust staged parser dispatch trace phases"
  - "can Rust claim trace parity after TRACE-OBSERVABILITY.4.3"
  - "does Rust traced compilation enforce progressive span dispatch validation"
  - "why did compile_with_trace accept residual dispatch_span calls"
  - "what did TRACE-OBSERVABILITY.5.1 repair"
date: 2026-09-07
status: current
tags: [trace, observability, rust, parity, staged-parsing, task-tree, mdbook]
evidence: "rust/linkedspec-core/src/{parser.rs,validation.rs,compiler.rs}; rust/linkedspec-runtime/src/{spec_parser.rs,staged_parser_registry.rs}; rust/linkedspec-runtime/tests/trace_controls.rs; docs/linkedspec-book/src/public-api/trace-api.md"
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test trace_controls"
---

`TRACE-OBSERVABILITY.4.3` adds routed Rust trace events for compile-side and spec-parser owner boundaries while
preserving the untraced result contract.

The core Rust traced entrypoints now emit scope/decision events for `parse_spec`, validation passes, `compile`,
per-function/per-rule compilation, and dependency-regex mapping. Runtime full-spec parsing now traces
user-function-definition parser execution, function projection, stripped-rule parsing, and the neutral
`body_parse_job` dispatch path. The staged parser registry traced entrypoints now report normalize, stable queue
sort, resolve, load, compile, and execute decisions for each job.

This did not complete Rust trace parity by itself. `.4.4` later added runtime interpreter/generated-plan branch
events, rule entry/exit, and mark/capture operations, and `.4.5` closed the original cross-variant parity proof.

Corrective audit `.5.1` then found that `compiler::compile_with_events` called the recursive-observation,
staged-parse, and compiled-regex validators but omitted the already-current
`validate_progressive_span_dispatch_contract` call made by ordinary `compile`. Therefore a malformed residual
`dispatch_span(...)` could be accepted only when compilation tracing was enabled. `.5.1` restores the missing
call at the same point in the validator sequence and adds an exact ordinary/traced diagnostic-equality regression.
Valid traced/untraced compile results remain equal, and the admitted progressive four-route contract remains
GREEN. The separate gap-aware runtime `child_dispatch` event defect subsequently closed under `.5.2` on
August 26. That leaf restores the shared entry-slot dispatch/result event seam for interpreted and generated
plans; its dated proof is 11/11 trace controls, 6/6 source-emitter tests, 1/1 gap admission and 7/7 core trace.
The corrective tree then closes canonically under `.5.4` after the staged admission proof snapshot repair.

September 7 reading checkpoint `SESSION-STARTUP-READING.3.3.10` reconciles the stale pending sentence against
the completed `.5.2` and `.5.4` records in `docs/tasks/TRACE-OBSERVABILITY.md`. Their native and canonical
results remain dated milestone evidence, not an assertion that this reading leaf reran those full suites.
