---
id: julia-mcp-strict-stdio
title: Julia has strict synchronous caller-owned MCP stdio
answers:
  - "is Julia MCP stdio implemented"
  - "how do I call Julia serve_mcp_stdio"
  - "does Julia MCP close stdin stdout or log"
  - "how does Julia MCP reject duplicate JSON keys"
  - "how does Julia MCP preserve JSON number kinds"
  - "what is the Julia MCP maximum line size"
  - "does Julia MCP accept CRLF or final EOF frames"
  - "how does Julia MCP cancellation interact with flush"
  - "what does Julia MCP log on IO failure"
  - "does generic Julia readbytes support all false"
date: 2026-07-29
status: strict stdio implemented; exact formal admission pending
tags: [julia, mcp, stdio, json, utf8, cancellation, io, security]
evidence: julia/src/mcp/McpWire.jl; julia/src/mcp/McpServer.jl; julia/src/LinkedSpecJulia.jl; julia/test/mcp_server_julia_stdio_test.jl; docs/decisions/0060-julia-native-mcp-server-seams.md; FUTURE-PARITY-BACKLOG.10.9.5.2
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test; const REPO_ROOT=pwd(); include(\"julia/test/mcp_contract_julia_binding_test.jl\"); include(\"julia/test/mcp_server_julia_dispatch_test.jl\"); include(\"julia/test/mcp_server_julia_stdio_test.jl\")'"
---

# Julia MCP Strict Stdio

`FUTURE-PARITY-BACKLOG.10.9.5.2` implements exported `serve_mcp_stdio!(server, input, output,
authorization_context; log=nothing)` through private synchronous `McpWire.jl`. Input, output, and the optional log
are caller-owned `IO` and are never closed; output and log must be distinct. EOF flushes, shuts down, releases all
registered indexes and active requests, then returns normally.

Framing accepts LF, CRLF, and one complete final frame at EOF. Payloads are bounded at 1,048,576 bytes excluding
the delimiter; an overlong frame is drained through LF before the next frame is considered. One iterative scanner
rejects BOMs, invalid UTF-8, malformed JSON/escapes/surrogates, decoded duplicate keys including escape-equivalent
spellings, excess depth, batches/non-object roots, nonfinite values, and invalid string/safe-integer id tokens.
It records number lexemes in value order; JSON3 decodes with `numbertype=Float64`, after which the converter
reconstructs integral lexemes as exact `Int` and keeps fraction/exponent lexemes as finite `Float64`. Canonical
responses recursively sort keys and append exactly one LF.

Generic Julia `IO` does not share `IOStream`'s `all=false` read keyword. The wire blocks for one byte with generic
`readbytes!` and then drains only the current bounded `bytesavailable` count into fixed buffers. Reverify that API
fact with `bash tools/run_julia_project_data.sh --project=julia -e 'println(methods(readbytes!))'`.

An active request remains cancellable after preparation and until emission. Cancellation at the deterministic
pre-emission seam suppresses the response; a successful write and flush marks it emitted, so later cancellation
cannot retract it. Read/write/flush failure performs the same release, optionally writes only the fixed line
`linkedspec_mcp_io_failure`, and throws sanitized `McpServerError` code `linkedspec_mcp_io_failure`; log failure
cannot replace that error. Focused proof is 170 assertions in addition to the existing 48 binding/runtime and 139
decoded-server assertions. Formal ledger promotion remains exclusively owned by `.10.9.5.3`.

Related facts: [[julia-native-mcp-server-plan]], [[julia-mcp-decoded-server]],
[[mcp-2026-07-28-stdio-contract]], [[mcp-native-server-topology]], and
[[mcp-implementation-admission-ledger]].
