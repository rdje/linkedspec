---
id: rust-progressive-span-dispatch-carriers
title: Rust privately carries progressive span dispatch through four dormant execution routes
answers:
  - "does Rust progressive span dispatch use a dedicated node"
  - "how does Rust compile dispatch_span"
  - "which Rust routes execute progressive span dispatch"
  - "how does Rust seed progressive dispatch authority"
  - "does generated Rust source serialize progressive callbacks"
  - "does Rust reject progressive dispatch in recognition transactions"
  - "is the Rust progressive dispatch consumer admitted in CI"
  - "what remains before Rust progressive rollout"
date: 2026-08-17
status: private Rust carriers complete and dormant; canonical admission and rollout pending
tags: [rust, progressive-parsing, actionir, generated-source, recognition-transaction, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.3.2 replaces the generic helper fallback with one exclusive serde-tagged ProgressiveDispatchSpan expression carrying only target, literal parser id, literal top rule, and bare span binding. Direct malformed operands fail with the five reserved progressive static diagnostics; any residual generic dispatch_span call rejects during compilation. Recognition effect analysis rejects any recognize_once-reachable rule/function graph containing the node as parser_registry_or_staged_dispatch, and runtime dispatch independently rejects a live uncommitted token. ExecutionOptions accepts one doc-hidden opaque ProgressiveExecutionSeed; every native or generated execution starts a fresh invocation, while cloned runtime contexts share the one budget/call/cancellation authority. Native, serialized reconstruction, generated-plan, and independently compiled emitted-source routes return the same detached child payload. Compiled/generated JSON contains exactly one logical node and no fingerprint, callback, registry, cancellation token, or authority. The exact outer-cfg consumer is GREEN but remains absent from ordinary/canonical discovery; neutral governance is 3 pending-backend guard groups/11 paths, 9 Rust carrier marker paths, 10 outward guards, 26 diagnostics, rollout 2/9, and 91 mutations. Rust admission and rollout remain exclusively owned by .14.6.3.3."
reverify:
  - "RUSTFLAGS='--cfg linkedspec_progressive_span_dispatch_red' bash tools/run_cargo_local.sh test --offline --jobs 1 --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_contract -- --nocapture"
  - "bash tools/run_cargo_local.sh test --offline --jobs 1 --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_contract"
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "if rg -n 'progressive_span_dispatch_contract\\.rs|--test progressive_span_dispatch_contract' tools/run_ci_local.sh; then exit 1; fi"
---

# Private Rust progressive carriers

The authored assignment is an exclusive whole-statement node, not an ordinary helper call:

```text
value = dispatch_span("expr-v1", "Expr", span)
```

Only `value`, `expr-v1`, `Expr`, and `span` enter compiled or generated data. The host-only seed owns the immutable
registry callback, source snapshot, cancellation identity, budget, capabilities, and ceilings. Starting an Engine
execution creates fresh invocation state from that seed; dispatch delegates to the previously admitted authority
and writes the detached result to `value` without advancing the parent cursor.

Static recognition composition treats the node as a non-rollbackable parser-registry effect. The live-token query
is retained as a defensive runtime boundary for reconstructed or otherwise precompiled inputs that bypass static
compilation.

The focused consumer proves identical native, reconstructed, generated-plan, and independently compiled emitted-
source results. Its outer cfg deliberately retains the historical RED name so admission can route the exact same
consumer without replacing its identity. Ordinary Cargo executes zero tests and canonical CI omits it until
`.14.6.3.3`; therefore Rust rollout remains pending even though its private carrier implementation is complete.
