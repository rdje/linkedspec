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
  - Which artifacts generate the Rust embedded MCP contract?
  - How does the Rust MCP generator verify its source bundle?
  - What is the current embedded Rust MCP bundle identity?
date: 2026-09-07
status: current; implementation, admission, and no-change parent closeout complete under FUTURE-PARITY-BACKLOG.10.9.3.1-.4
tags: [rust, mcp, semantic-introspection, embedding, json, security, stdio, generated-binding]
evidence: docs/decisions/0058-rust-native-mcp-server-seams.md; docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.9.3.1-.4; tools/mcp_contract_binding.py; tools/generate_rust_mcp_contract.py; rust/linkedspec-runtime/src/mcp_contract.rs; rust/linkedspec-runtime/src/mcp_contract_runtime.rs; rust/linkedspec-runtime/src/mcp_server.rs; rust/linkedspec-runtime/src/mcp_wire.rs; rust/linkedspec-runtime/tests/mcp_server_rust_dispatch.rs; rust/linkedspec-runtime/tests/mcp_server_rust_stdio.rs; rust/linkedspec-runtime/tests/mcp_server_rust_admission.rs
reverify: "bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py && bash tools/run_python_project_data.sh tools/generate_rust_mcp_contract.py && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --lib mcp_ && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test mcp_server_rust_dispatch && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test mcp_server_rust_stdio"
---

# Rust generated binding, decoded server, and strict stdio

`linkedspec-runtime` now owns the public native Rust `McpServer` beside the immutable
`SemanticIndex`, public `capabilities()`, and transport-facing `query_neutral(&serde_json::Value)` operations.
Registration retains an `Arc<SemanticIndex>` created by the host. MCP cannot construct an index, read a path,
compile/execute a specification, enable trace, emit generated source, or add a mode to `linkedspec-rust`.

Implemented owners are generated private `mcp_contract.rs`, private `mcp_contract_runtime.rs`, public
`mcp_server.rs`, and private `mcp_wire.rs`. Shared `tools/mcp_contract_binding.py` feeds the Perl
and Rust generators from digest-verified neutral artifacts. The initial 83,072-byte Perl and 82,886-byte Rust
sizes describe the July implementation milestone. Current generated sizes and identities are recorded below;
production Rust parses only its compile-time bundle.

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

`.10.9.3.1-.2` implement the server without admission movement, and `.10.9.3.3` advances only Rust to 2/5 + 2/6
with rollout pending. No-change `.10.9.3.4` recomposes those committed owners under focused/canonical proof,
closes parent `.10.9.3`, and hands the exact contract to Dart `.10.9.4` after the clean closeout commit.

## September 7 embedded-prefix and generator reading

`SESSION-STARTUP-READING.3.3.24` reads module lines 1–6 (297 bytes) and file bytes 298–65536
of line 7, covering every canonical frame, the manifest, corpus and schema prefix. The remaining
17,689 module bytes and runtime implementation stay with `.3.3.25` and later reading leaves.
Full-module machine identity is separate from that physical reading boundary.

The shared builder requires exactly seven artifact paths/digests, resolves paths within the current
repository root, checks each hash, and decodes object inputs with strict UTF-8, BOM/duplicate-key and
nonfinite-constant rejection. Canonical frame rows must match corpus order/count, LF framing and exact
canonical re-encoding. It constructs one bundle containing the contract/hash, schema, semantic payloads,
corpus, canonical frames and source hashes. The Rust renderer hashes canonical UTF-8 JSON and increases
raw-string hash delimiters until the embedded value cannot close the literal. The Rust generator
and shared builder read repository-derived sources; production consumers use the generated constant.
The generator's default mode compares bytes; only explicit `--write` mutates the module.

Fresh managed Rust/Perl generator checks pass at 83,225/83,411 bytes. Rust module SHA-256 is
`7473a113474d090a1304ffc0d419de18b6b97c10639e7a484e5625abc83e7ece`;
its 82,882-byte JSON has bundle SHA-256
`a1d2857c57ef93ea0e62403977105fdf6380f6fcb4d7a89ed5749c1bfdd64001`,
and the embedded manifest hash is
`e068519994a7d4fb8e4c8ece0e277a470f48204d4c670f915ba49052a52630b3`.
Independent decoded checks reproduce the generated module and preserve all four success-frame
canonical-text/structured-content identities, including semantic `ok:false` with transport `isError:false`.
Neutral transport passes 35/10/10/76; admission governance passes 5/5 implementations, 6/6 runtimes,
rollout complete/141. These are generated-artifact and governance checks, not fresh Rust dispatch,
stdio or six-runtime execution. Older native counts and intermediate handoffs above remain historical.
