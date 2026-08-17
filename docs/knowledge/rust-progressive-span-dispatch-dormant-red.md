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
status: dormant final-path RED frozen; private Rust authority/core current, carriers and rollout pending
tags: [rust, progressive-parsing, red-test, generated-source, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.3.0 adds rust/linkedspec-runtime/tests/progressive_span_dispatch_contract.rs behind file-level cfg linkedspec_progressive_span_dispatch_red. It derives the neutral 2 registry / 2 source + 8 view / 6 authority / 6 cancellation / 8 chain / 4 execution / 26 diagnostic / 2-of-9 rollout / 86 mutation truth, proves staged parser identity expr-v1 is rejected at resolve, and compiles the exact reserved assignment. Current Rust represents dispatch_span as generic Expr::Call; serialized and emitted carriers contain exactly one generic call and neither dedicated token. Native, reconstructed, generated-plan, and independently compiled emitted-source execution all return null through unknown-helper fallback. The explicit cfg run passes every pre-boundary assertion and fails only because progressive_dispatch_span / PROGRESSIVE_DISPATCH_SPAN is absent. The ordinary target runs zero tests and tools/run_ci_local.sh does not route it."
reverify:
  - "RUSTFLAGS='--cfg linkedspec_progressive_span_dispatch_red' bash tools/run_cargo_local.sh test --offline --jobs 1 --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_contract -- --nocapture"
  - "bash tools/run_cargo_local.sh test --offline --jobs 1 --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_contract"
  - "if rg -n 'progressive_span_dispatch_contract\\.rs|--test progressive_span_dispatch_contract' tools/run_ci_local.sh; then exit 1; fi"
---

# Rust dormant progressive-dispatch boundary

The Rust compiler accepts the reserved authored spelling, but only as an ordinary call to an unknown helper.
That generic fallback returning `null` is explicitly not progressive dispatch: it has no immutable registry,
bounded rebased source view, inherited authority, cycle/progress guard, dedicated effect, or typed diagnostic path.

The dormant consumer walks all four final carriers before asserting the missing dedicated node. `.14.6.3.1` owns
the now-current private immutable registry/invocation/source-view authority, `.14.6.3.2` owns the dedicated node
and four carriers, and `.14.6.3.3` alone may route the unchanged consumer and promote Rust rollout. The authority
has its own dormant focused proof, so the final-path RED still fails only at its original node boundary. Until the
later leaves land, private Perl remains the sole backend implementation and neutral + Perl remains rollout 2/9.
