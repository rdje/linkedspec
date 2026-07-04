---
id: trace-observability-coverage-audit
title: TRACE-OBSERVABILITY.1 found trace is usable but not exhaustive; generated handler branches, ActionIR owner branches, CLI discovery, and Rust parity remain gaps
answers:
  - "what does trace observability cover today"
  - "is linkedspec trace exhaustive"
  - "are generated handler branches traced"
  - "what is next after TRACE-OBSERVABILITY.1"
  - "does rust have linkedspec trace"
date: 2026-07-04
status: current
tags: [trace, observability, task-tree, runtime, generated-handlers, rust]
evidence: "docs/tasks/TRACE-OBSERVABILITY.md Coverage Audit; rg trace call-site inventory; dump_parser_source probe showed generated while/unless branches without emitted trace_decision/trace_enter/trace_exit; rust/linkedspec-runtime trace search found no runtime trace API"
reverify: "rg -n 'Coverage Audit|TRACE-OBSERVABILITY.1|TRACE-OBSERVABILITY.2|generated handler|Rust currently has no analogous trace' docs/tasks/TRACE-OBSERVABILITY.md docs/TASK_TREE.md MEMORY.md docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md"
---

`TRACE-OBSERVABILITY.1` is closed as a read-only coverage audit. The existing Perl reference trace framework is
real and useful: env/per-call/API controls configure `LinkedSpec::Trace`, and current output covers broad
`Get`/parser invocation scopes, per-rule runtime handler wrappers, selected compiler/resolver/validation decisions,
dumps, and mark/capture events.

It is not exhaustive. Generated handler bodies from `HandlerVariantEmitter` still contain untraced `while`,
`foreach`, `if`/`elsif`, `unless`, acode/bcode dispatch, repetition min/max, zero-progress, no-match, `LX`, and
`EX` paths. Most ActionIR owner lowering branches also lack ENTER/EXIT or decision trace. There is no discoverable
CLI flag/entrypoint yet, and the Rust runtime has no equivalent trace API/sink surface.

PNT frontier after this audit is `TRACE-OBSERVABILITY.2`: add/document discoverable CLI control for the existing
trace API before extending coverage.
