---
id: rust-progressive-span-dispatch-carriers
title: Rust privately carries progressive span dispatch through four admitted execution routes
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
status: private Rust carriers complete and canonically admitted; later backends and recurrence pending
tags: [rust, progressive-parsing, actionir, generated-source, recognition-transaction, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.3.2 replaces the generic helper fallback with one exclusive serde-tagged ProgressiveDispatchSpan expression carrying only target, literal parser id, literal top rule, and bare span binding. Direct malformed operands fail with the five reserved progressive static diagnostics; any residual generic dispatch_span call rejects during compilation. Recognition effect analysis rejects any recognize_once-reachable rule/function graph containing the node as parser_registry_or_staged_dispatch, and runtime dispatch independently rejects a live uncommitted token. ExecutionOptions accepts one doc-hidden opaque ProgressiveExecutionSeed; every native or generated execution starts a fresh invocation, while cloned runtime contexts share the one budget/call/cancellation authority. Native, serialized reconstruction, generated-plan, and independently compiled emitted-source routes return the same detached child payload. Compiled/generated JSON contains exactly one logical node and no fingerprint, callback, registry, cancellation token, or authority. The exact outer-cfg consumer is GREEN but remains absent from ordinary/canonical discovery; neutral governance is 3 pending-backend guard groups/11 paths, 9 Rust carrier marker paths, 10 outward guards, 26 diagnostics, rollout 2/9, and 91 mutations. Rust admission and rollout remain exclusively owned by .14.6.3.3."
evidence_update_2026_08_17_admission: "FUTURE-PARITY-BACKLOG.14.6.3.3 keeps the exact consumer identity/cfg, fixture, and native/reconstructed/generated-plan/independently compiled emitted-source assertions, but requires and executes that cfg-enabled target once in canonical CI. Ordinary discovery remains zero tests. Neutral governance advances only Rust to rollout 3/9 and 95 mutations while retaining 3 pending-backend groups/11 paths, 9 Rust carrier paths, 10 outward guards, and 26 diagnostics."
reverify:
  - "RUSTFLAGS='--cfg linkedspec_progressive_span_dispatch_red' bash tools/run_cargo_local.sh test --offline --jobs 1 --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_contract -- --nocapture"
  - "bash tools/run_cargo_local.sh test --offline --jobs 1 --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_contract"
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "test \"$(rg -c 'RUSTFLAGS=.*linkedspec_progressive_span_dispatch_red.*--test progressive_span_dispatch_contract' tools/run_ci_local.sh)\" -eq 1"
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

The admitted consumer proves identical native, reconstructed, generated-plan, and independently compiled emitted-
source results. Its outer cfg deliberately retains the historical RED name so canonical CI routes the exact same
consumer without replacing its identity. Ordinary Cargo still executes zero tests; the one explicit canonical
cfg-enabled route owns Rust admission and rollout.
