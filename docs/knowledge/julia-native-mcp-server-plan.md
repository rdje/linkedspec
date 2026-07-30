---
id: julia-native-mcp-server-plan
title: Julia MCP will use a generated Base64 contract module and synchronous native server
answers:
  - "how will the Julia MCP server be implemented"
  - "how do I register a Julia SemanticIndex with MCP"
  - "which Julia files will own MCP"
  - "will Julia MCP read contract files at runtime"
  - "does Julia JSON3 reject duplicate keys"
  - "does Julia JSON3 reject invalid UTF-8"
  - "does Julia JSON3 preserve JSON integer token kinds"
  - "how will Julia MCP produce canonical JSON"
  - "how will Julia MCP generate secure handles"
  - "how will Julia MCP measure handle expiry"
  - "will Julia MCP add an MCP SDK or third-party dependency"
  - "how will Julia MCP serve stdio"
  - "will Julia MCP add a CLI mode or executable"
  - "what are the Julia MCP implementation leaves"
  - "when will Julia MCP advance the implementation ledger"
date: 2026-07-29
status: current behavior-free plan; implementation pending under FUTURE-PARITY-BACKLOG.10.9.5.1-.4
tags: [julia, mcp, semantic-introspection, embedding, handles, json, stdio, security, generated-data]
evidence: docs/decisions/0060-julia-native-mcp-server-seams.md; docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.9.5.0-.4; julia/Project.toml; julia/src/LinkedSpecJulia.jl; julia/src/semantic/SemanticIndex.jl; julia/src/semantic/SemanticQuery.jl; julia/src/cli/LinkedSpecJuliaCli.jl; tools/mcp_contract_binding.py; tools/check_mcp_implementation_admission.py
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using JSON3, Base64, Random, SHA, LinkedSpecJulia; bytes=rand(RandomDevice(), UInt8, 32); handle=rstrip(replace(base64encode(bytes), \"+\"=>\"-\", \"/\"=>\"_\"), (Char(61),)); @assert length(handle)==43; @assert typeof(time_ns())==UInt64; duplicate=JSON3.read(\"{\\\"a\\\":1,\\\"\\\\u0061\\\":2}\"); @assert length(collect(pairs(duplicate)))==2; @assert !isvalid(String(UInt8[0xff])); @assert JSON3.read(\"{\\\"n\\\":1.0}\").n isa Int' && bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py && bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py"
---

# Julia Native MCP Server Plan

Behavior-free leaf `FUTURE-PARITY-BACKLOG.10.9.5.0` and ADR `0060` freeze Julia as the fourth native MCP
implementation before production code. One same-process `McpServer` will retain caller-created opaque immutable
`SemanticIndex` values and call only `semantic_capabilities`, `semantic_query_neutral`, and `to_json`. MCP cannot
load source or paths, compile or execute a specification, enable trace/runtime observation, cache semantic
responses, emit generated source, or bootstrap from the primary CLI.

The frozen owners are generated `julia/src/mcp/McpContract.jl`, private `McpContractRuntime.jl`, public-host
`McpServer.jl`, and strict synchronous `McpWire.jl`. `tools/generate_julia_mcp_contract.py` will consume the same
digest-verified bundle as Perl, Rust, and Dart. It will embed Base64 rather than raw JSON because Julia raw-string
quote escaping is not byte-transparent; runtime decoding verifies the canonical JSON SHA-256 before JSON3 and
performs no filesystem read.

The repository-routed Julia 1.12.6 / JSON3 1.14.3 audit proves that JSON3 retains duplicate pairs but normalization
would keep only the last literal or escape-equivalent key, accepts malformed-UTF-8 `String` input, and converts
`1.0`/`1e0` tokens to integers. Strict wire admission must therefore validate UTF-8 and decoded key uniqueness,
record numeric lexemes, decode through JSON3 with floating-number mode, then reconstruct exact integer versus
fraction/exponent kinds before frozen-schema evaluation. Canonical output is MCP-owned recursive key sorting, not
the private primary-CLI writer.

Core `RandomDevice()` supplies OS entropy, `time_ns()` supplies documented monotonic elapsed time, core Base64
maps 32 bytes to a 43-character unpadded URL-safe handle, and existing SHA digests authorization. Base64 and
Random become explicit standard-library dependencies; no third-party package, SDK, network stack, task runtime,
or executable is added. Caller-owned borrowed `IO` values provide bounded synchronous LF/CRLF/final-EOF framing,
cancellation through flush, fixed optional diagnostics, and shutdown release without closing the streams.

The omission-safe split is `.10.9.5.1` generated binding/runtime/secure decoded server, `.2` strict wire and
lifecycle, `.3` exact twelve-role Julia admission and Julia-only movement to 4/5 implementations plus 4/6
runtimes, and no-change `.4` parent closeout. Until `.3`, the ledger remains exactly 3/5 + 3/6 with rollout
pending.

Related facts: [[julia-semantic-introspection-authority-map]], [[julia-semantic-query-public-api]],
[[julia-semantic-runtime-observation-authority-map]], [[julia-primary-cli-native-execution-canonical-json]],
[[mcp-native-server-topology]], [[mcp-2026-07-28-stdio-contract]],
[[mcp-implementation-admission-ledger]], and [[dart-native-mcp-server-plan]].
