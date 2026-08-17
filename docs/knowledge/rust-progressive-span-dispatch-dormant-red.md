---
id: rust-progressive-span-dispatch-dormant-red
title: Rust progressive span dispatch has a four-carrier dormant RED at the dedicated-node boundary
answers:
  - "is progressive span dispatch implemented in Rust"
  - "what is the Rust progressive span dispatch RED"
  - "how does Rust currently compile dispatch_span"
  - "does Rust progressive dispatch use a dedicated node"
  - "what happens when Rust executes dispatch_span today"
  - "does the Rust progressive dispatch test run in CI"
  - "which leaves implement Rust progressive span dispatch"
date: 2026-08-17
status: historical RED boundary; private Rust authority, carriers, canonical admission, and rollout current
tags: [rust, progressive-parsing, red-test, generated-source, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.3.0 adds rust/linkedspec-runtime/tests/progressive_span_dispatch_contract.rs behind file-level cfg linkedspec_progressive_span_dispatch_red. It derives the neutral 2 registry / 2 source + 8 view / 6 authority / 6 cancellation / 8 chain / 4 execution / 26 diagnostic / 2-of-9 rollout / 86 mutation truth, proves staged parser identity expr-v1 is rejected at resolve, and compiles the exact reserved assignment. Current Rust represents dispatch_span as generic Expr::Call; serialized and emitted carriers contain exactly one generic call and neither dedicated token. Native, reconstructed, generated-plan, and independently compiled emitted-source execution all return null through unknown-helper fallback. The explicit cfg run passes every pre-boundary assertion and fails only because progressive_dispatch_span / PROGRESSIVE_DISPATCH_SPAN is absent. The ordinary target runs zero tests and tools/run_ci_local.sh does not route it."
evidence_update_2026_08_17_carriers: "FUTURE-PARITY-BACKLOG.14.6.3.2 promotes this exact consumer from its historical RED to GREEN without changing its file-level cfg, fixture identity, four-route scope, ordinary zero-test discovery, or canonical absence. The generic call is replaced by one dedicated logical-only node; all four routes delegate to the private authority and return the same detached value. The current implementation fact is rust-progressive-span-dispatch-carriers; this card retains the exact historical boundary."
reverify:
  - "RUSTFLAGS='--cfg linkedspec_progressive_span_dispatch_red' bash tools/run_cargo_local.sh test --offline --jobs 1 --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_contract -- --nocapture"
  - "bash tools/run_cargo_local.sh test --offline --jobs 1 --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_contract"
  - "test \"$(rg -c 'RUSTFLAGS=.*linkedspec_progressive_span_dispatch_red.*--test progressive_span_dispatch_contract' tools/run_ci_local.sh)\" -eq 1"
---

# Rust dormant progressive-dispatch boundary

At `.14.6.3.0`, the Rust compiler accepted the reserved authored spelling only as an ordinary call to an unknown
helper. That historical generic fallback returned `null` and was explicitly not progressive dispatch.

The same outer-cfg consumer walks four GREEN carriers under `.14.6.3.2`; its historical cfg name remains an
intentional continuity anchor. `.14.6.3.3` canonically routes that exact cfg-enabled target once and promotes only
Rust, while ordinary discovery remains zero tests.
