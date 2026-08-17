---
id: rust-progressive-span-dispatch-admission
title: Rust progressive span dispatch is privately admitted through one exact cfg-enabled canonical route
answers:
  - "is Rust progressive span dispatch admitted"
  - "where does canonical CI run the Rust progressive span dispatch consumer"
  - "why does the Rust progressive dispatch consumer keep its historical cfg"
  - "does ordinary Cargo run the Rust progressive dispatch consumer"
  - "what is the current progressive span dispatch rollout after Rust admission"
  - "what remains after Rust progressive span dispatch admission"
date: 2026-08-17
status: current private Rust admission; Dart also admitted while Julia, Lua, recurrence, typed projection, and public no-drift remain pending
tags: [rust, progressive-parsing, admission, ci, actionir, generated-source, task-tree]
evidence: "FUTURE-PARITY-BACKLOG.14.6.3.3 requires rust/linkedspec-runtime/tests/progressive_span_dispatch_contract.rs as a tracked canonical input, logs one exact Rust progressive admission marker, and runs RUSTFLAGS='--cfg linkedspec_progressive_span_dispatch_red' cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_contract exactly once. The consumer retains its historical cfg and one-test identity, exact fixture, and native/reconstructed/generated-plan/independently compiled emitted-source scope; ordinary Cargo still executes zero tests. Neutral governance advances only Rust to 3/9 rollout and 95 mutations with 3 pending-backend groups/11 paths, 9 governed Rust carrier paths, 10 outward guards, and 26 diagnostics. Typed recurrence and every public/outward surface remain unchanged."
evidence_update_2026_08_17_dart_admission: "FUTURE-PARITY-BACKLOG.14.6.4.3 leaves Rust behavior and its exact cfg-enabled canonical route unchanged while Dart becomes the third admitted backend. Progressive governance is 4/9/103 with 9 Rust + 8 Dart carrier paths and 2 Julia/Lua guards/8 paths. Julia/Lua, recurrence, typed projection, generated format, public inventory, and outward surfaces remain pending or unchanged."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "RUSTFLAGS='--cfg linkedspec_progressive_span_dispatch_red' bash tools/run_cargo_local.sh test --offline --jobs 1 --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_contract -- --nocapture"
  - "bash tools/run_cargo_local.sh test --offline --jobs 1 --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_contract"
  - "test \"$(rg -c 'RUSTFLAGS=.*linkedspec_progressive_span_dispatch_red.*--test progressive_span_dispatch_contract' tools/run_ci_local.sh)\" -eq 1"
---

# Private Rust progressive admission

Canonical admission intentionally preserves the historical outer cfg. That keeps the RED-to-GREEN consumer's
identity stable while making the trust boundary explicit: ordinary discovery remains inert, and only the exact
cfg-enabled canonical command executes the four-route proof.

This leaf changes no authority, parser/compiler/runtime behavior, generated format, dependency, facade, schema,
semantic/MCP field, CLI, README, or public helper. It promotes only the Rust rollout row. Dart has since been
admitted independently; Julia, shared Lua, recurring six-runtime composition, typed progressive projection, and
public no-drift keep their separate owners.

## Links

- Architecture: [[progressive-span-dispatch-audit-plan]].
- Authority: [[rust-progressive-span-dispatch-authority]].
- Four carriers: [[rust-progressive-span-dispatch-carriers]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.6.3.3`.
