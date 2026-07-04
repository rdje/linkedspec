---
id: rust-trace-compile-spec-parser-events
title: TRACE-OBSERVABILITY.4.3 adds Rust compile/spec-parser/staged-dispatch trace events
answers:
  - "does Rust currently emit compile trace events"
  - "what did TRACE-OBSERVABILITY.4.3 add"
  - "which Rust trace events existed before runtime branch parity"
  - "does Rust staged parser dispatch trace phases"
  - "can Rust claim trace parity after TRACE-OBSERVABILITY.4.3"
date: 2026-07-04
status: current
tags: [trace, observability, rust, parity, staged-parsing, task-tree, mdbook]
evidence: "rust/linkedspec-core/src/{parser.rs,validation.rs,compiler.rs}; rust/linkedspec-runtime/src/{spec_parser.rs,staged_parser_registry.rs}; rust/linkedspec-runtime/tests/trace_controls.rs; docs/linkedspec-book/src/public-api/trace-api.md"
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test trace_controls"
---

`TRACE-OBSERVABILITY.4.3` adds routed Rust trace events for compile-side and spec-parser owner boundaries while
preserving the untraced result contract.

The core Rust traced entrypoints now emit scope/decision events for `parse_spec`, validation passes, `compile`,
per-function/per-rule compilation, and dependency-regex mapping. Runtime full-spec parsing now traces
user-function-definition parser execution, function projection, stripped-rule parsing, and the neutral
`body_parse_job` dispatch path. The staged parser registry traced entrypoints now report normalize, stable queue
sort, resolve, load, compile, and execute decisions for each job.

This did not complete Rust trace parity by itself. `.4.4` has since added runtime interpreter/generated-plan branch
events, rule entry/exit, and mark/capture operations. `.4.5` remains the cross-variant parity proof before Rust can
claim trace parity.
