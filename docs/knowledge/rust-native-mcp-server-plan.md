---
id: rust-native-mcp-server-plan
title: Rust MCP is planned as a generated filesystem-free binding and in-process runtime server
answers:
  - What crate will own the Rust LinkedSpec MCP server?
  - What Rust type will an MCP handle retain?
  - Will Rust MCP add a standalone executable or primary CLI mode?
  - How will Rust MCP consume the neutral contract without runtime path reads?
  - Why can Rust MCP not rely on serde_json alone for strict JSON?
  - How will Rust MCP generate opaque handles?
  - Which dependency supplies Rust MCP entropy?
  - How will Rust MCP compare authorization and enforce expiry?
  - How will Rust MCP preserve canonical semantic response bytes?
  - How will Rust MCP sanitize native panics?
  - Which leaves implement and admit the Rust MCP server?
date: 2026-07-29
status: current behavior-free plan; implementation pending under FUTURE-PARITY-BACKLOG.10.9.3.1-.4
tags: [rust, mcp, semantic-introspection, embedding, json, security, stdio, generated-binding]
evidence: docs/decisions/0058-rust-native-mcp-server-seams.md; docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.9.3.0; rust/linkedspec-runtime/src/semantic_index.rs; rust/linkedspec-runtime/src/semantic_index/query.rs; rust/linkedspec-runtime/Cargo.toml; rust/Cargo.lock
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_index_foundation --test semantic_index_query --test semantic_introspection_rust_admission; cargo tree --manifest-path rust/Cargo.toml -p linkedspec-runtime -e features; rg -n 'pub fn (capabilities|query|query_neutral)|pub struct SemanticIndex' rust/linkedspec-runtime/src/semantic_index.rs"
---

# Rust native MCP server plan

`linkedspec-runtime` owns the future native Rust `McpServer` because it already owns the immutable
`SemanticIndex`, public `capabilities()`, and transport-facing `query_neutral(&serde_json::Value)` operations.
Registration will retain an `Arc<SemanticIndex>` created by the host. MCP will not construct an index, read a path,
compile/execute a specification, enable trace, emit generated source, or add a mode to `linkedspec-rust`.

The exact owners frozen by ADR `0058` are generated private `mcp_contract.rs`, private
`mcp_contract_runtime.rs`, public `mcp_server.rs`, and private `mcp_wire.rs`. A shared Python verified-bundle module
will feed the existing Perl generator and a new Rust generator without changing Perl output; neutral artifacts
remain normative. Rust runtime code parses only its compile-time embedded bundle.

Installed/locked `serde_json 1.0.150` default maps provide sorted object-key serialization after typed responses
are converted to `Value`, matching the existing Rust semantic digest proof. Its `Value` visitor inserts repeated
keys and overwrites earlier values, so the wire must independently preflight decoded duplicate keys, UTF-8,
strings/surrogates, numbers/request ids, object roots, size, and depth 64 before value construction.

Production handles use direct `getrandom 0.4.2` OS entropy, already present in the repository-local lock/cache,
with exactly 32 bytes encoded by a private fixed 43-character unpadded-base64url routine. Registry state is
bounded `BTreeMap` data containing the native `Arc`, SHA-256 authorization digest, monotonic expiry from a
server-local `Instant`, and lowering-only policy. Fixed-work digest comparison uses a dummy digest for missing
handles; unknown/expired/revoked/unauthorized results stay indistinguishable.

Native calls remain synchronous and are caught at an unwind boundary for sanitized `-32603` projection. Strict
stdio uses fixed-size `Read` chunks, prepared-response activity through successful flush, optional fixed-code logs,
and registry cleanup on EOF/I/O failure. No async runtime, network/SDK/base64 package, executable, source bootstrap,
aggregator, or legacy protocol surface is planned.

Implementation order is `.10.9.3.1` binding/decoded server, `.10.9.3.2` strict stdio, `.10.9.3.3` exact Rust
admission plus ledger advance to 2/5 + 2/6 with rollout pending, and `.10.9.3.4` unchanged-owner parent closeout.
