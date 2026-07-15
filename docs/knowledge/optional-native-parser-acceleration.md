---
id: optional-native-parser-acceleration
title: Native parser acceleration is optional, measured, and derived from the dynamic spec parser
answers:
  - can a dynamic spec parser be converted to a faster native parser
  - is native parser generation worth pursuing
  - is the dynamic spec parser still the primary product
  - does a format need a native parser to be supported
  - is generated-source v1 already an optimizing compiler
  - must Perl implement native parser acceleration
  - how must native parser artifacts be fingerprinted
  - what proves an accelerated parser is correct
  - can loading an ordinary spec invoke a native compiler
  - what is NATIVE-PARSER-ACCELERATOR
  - what is FUTURE-PARITY-BACKLOG 18.3
date: 2026-07-15
status: current
tags: [parser, native, acceleration, codegen, generated-source, performance, formats, parity, FUTURE-PARITY-BACKLOG]
evidence: "Director/engineer agreement 2026-07-15; generated-source v1 Knowledge Map audit; ADR 0038; FUTURE-PARITY-BACKLOG.18.3; docs/tasks/NATIVE-PARSER-ACCELERATOR.md. Planning only: no parser/compiler/runtime/emitter/cache/CLI behavior or performance claim changed."
reverify: "rg -n '0038|dynamic parser|sole source|disposable|break-even|generated-source v1|Perl acceleration|NATIVE-PARSER-ACCELERATOR' docs/decisions/0038-optional-native-parser-acceleration.md docs/tasks/NATIVE-PARSER-ACCELERATOR.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/linkedspec-book/src/architecture/structured-format-program.md docs/knowledge/generated-source-contract-v1.md"
---

ADR `0038` adopts a worthwhile but non-blocking horizon: after a realistic dynamic `.spec` parser is correct,
observable, and measured, LinkedSpec may compile its normalized effective parser state into a backend-native
artifact for workloads that objectively benefit.

The primary promise does not change. Loading `foo.spec` must immediately produce a functional `foo` text-to-AST
parser without requiring a host compiler or prebuilt artifact. The complete `.spec` graph remains the sole source
of truth; warm compiled state and native source/packages/bytecode/binaries are disposable fingerprinted
derivatives. A stale or incompatible artifact invalidates and falls back to dynamic parsing.

Generated-source contract v1 is the foundation, not the speed claim. It already governs normalized compiled-state
input, deterministic host source and identity, independent loading, structural plans, diagnostics, trace roles,
and dynamic-oracle equivalence. Current emitters may reconstruct state and execute the native in-memory engine, so
v1 alone does not establish an optimizing compiler or improved throughput.

An accelerator consumes governed compiled IR, not backend-specific grammar syntax. It must match dynamic ASTs,
spans, diagnostics, Unicode behavior, recovery, limits, and observable trace semantics over authoritative,
invalid, differential, fuzz/property, and adversarial cases. Its fingerprint includes the full spec graph,
LinkedSpec contracts, Unicode data, backend/compiler, behavior options, and target/ABI as applicable. Compilation
is explicit and isolated; ordinary loading never invokes a toolchain for untrusted text.

Promotion also requires reproducible cold/warm/build/load/steady-state/resource measurements and a useful
break-even workload. Rust, Dart, Julia, and Lua may use different implementation strategies. Perl acceleration is
not required; it may remain the dynamic/reference/generated-handler baseline. Acceleration is not a format-support
or semantic-parity prerequisite, and no divergent public API is adopted without later reconciliation with ADR
`0023`.

Related facts: [[generated-source-contract-v1]], [[generated-source-parity-audit]],
[[post-parity-structured-text-program]], [[selective-end-to-end-parser-observability]],
[[native-in-memory-backend-contract]].
