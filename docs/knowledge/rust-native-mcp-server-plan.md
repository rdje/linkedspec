---
id: rust-native-mcp-server-plan
title: Rust MCP has a generated binding, decoded server, and strict borrowed-stream stdio
answers:
  - Is the Rust LinkedSpec MCP decoded server implemented?
  - Is the Rust LinkedSpec MCP stdio server implemented?
  - How do I call Rust McpServer serve_stdio?
  - How does Rust MCP reject duplicate JSON keys?
  - What happens when Rust MCP stdin stdout or flush fails?
  - When does Rust MCP release registered SemanticIndex Arcs?
  - How do I register a Rust SemanticIndex with MCP?
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
status: current decoded and strict-stdio implementation; admission/closeout pending under FUTURE-PARITY-BACKLOG.10.9.3.3-.4
tags: [rust, mcp, semantic-introspection, embedding, json, security, stdio, generated-binding]
evidence: docs/decisions/0058-rust-native-mcp-server-seams.md; docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.9.3.1-.2; tools/mcp_contract_binding.py; tools/generate_rust_mcp_contract.py; rust/linkedspec-runtime/src/mcp_contract.rs; rust/linkedspec-runtime/src/mcp_contract_runtime.rs; rust/linkedspec-runtime/src/mcp_server.rs; rust/linkedspec-runtime/src/mcp_wire.rs; rust/linkedspec-runtime/tests/mcp_server_rust_dispatch.rs; rust/linkedspec-runtime/tests/mcp_server_rust_stdio.rs
reverify: "bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py && bash tools/run_python_project_data.sh tools/generate_rust_mcp_contract.py && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib mcp_ && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_dispatch && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_stdio"
---

# Rust generated binding, decoded server, and strict stdio

`linkedspec-runtime` now owns the public native Rust `McpServer` beside the immutable
`SemanticIndex`, public `capabilities()`, and transport-facing `query_neutral(&serde_json::Value)` operations.
Registration retains an `Arc<SemanticIndex>` created by the host. MCP cannot construct an index, read a path,
compile/execute a specification, enable trace, emit generated source, or add a mode to `linkedspec-rust`.

Implemented owners are generated private `mcp_contract.rs`, private `mcp_contract_runtime.rs`, public
`mcp_server.rs`, and private `mcp_wire.rs`. Shared `tools/mcp_contract_binding.py` feeds the Perl
and Rust generators from digest-verified neutral artifacts. The Perl output remains byte-identical at 83,072
bytes, the formatter-stable Rust binding is 82,886 bytes, and production Rust parses only that compile-time bundle.

The frozen runtime verifies the embedded SHA-256 digest once, deep-clones returned frames, implements only the
exact schema keyword profile, classifies all 28 accepted and seven rejected canonical values, and constructs
Rust-identity discovery/list/tool/error shells. The public decoded boundary validates those schemas but cannot
recover duplicate-key or numeric-token spelling after a caller has created `serde_json::Value`. The strict wire
owner now preserves and validates that lexical evidence before decoding.

Production handles use direct `getrandom 0.4.2` OS entropy
with exactly 32 bytes encoded by a private fixed 43-character unpadded-base64url routine. Registry state is
bounded `BTreeMap` data containing the native `Arc`, SHA-256 authorization digest, monotonic expiry from a
server-local `Instant`, and lowering-only policy. Fixed-work digest comparison uses a dummy digest for missing
handles; unknown/expired/revoked/unauthorized results stay indistinguishable.

Decoded dispatch implements only discover, list, capabilities, query, and cancellation. It calls native methods
afresh, rejects all five above-policy components before a query result, preserves exact native payloads, and catches
unwind panics for sanitized `-32603`. `serve_stdio` reads bounded fixed chunks over borrowed streams, rejects
malformed UTF-8/JSON and decoded duplicate keys, enforces exact depth/number/id lexemes, drains overlong frames,
emits only validated canonical LF responses, and retains activity through successful flush. Clean EOF is silent;
read/write/flush failures clear all registry Arcs and expose only fixed error/log text.

Unit and public integration proof cover entropy/time/collision/capacity,
authorization/expiry/revocation, policy, canonical classifications, cancellation, request isolation, and shutdown
release. No async runtime, network/SDK/base64 package, executable, source bootstrap, aggregator, or legacy surface
exists.

`.10.9.3.1-.2` are implemented without admission movement. `.10.9.3.3` adds exact Rust admission and advances only
Rust to 2/5 + 2/6 with rollout pending, and `.10.9.3.4` is unchanged-owner closeout.
