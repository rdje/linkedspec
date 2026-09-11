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
status: strict stdio implemented, exactly admitted, and parent-closed
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
decoded-server assertions. Formal Julia admission remains exclusively owned by `.10.9.5.3`; that leaf and
unchanged closeout `.10.9.5.4` are complete.

Related facts: [[julia-native-mcp-server-plan]], [[julia-mcp-decoded-server]],
[[mcp-2026-07-28-stdio-contract]], [[mcp-native-server-topology]], and
[[mcp-implementation-admission-ledger]].

## September 11 physical wire reconciliation

Julia .1.11 finishes all672 lines of `julia/src/mcp/McpWire.jl`; the existing
stdio170 assertions pass. The scanner and JSON3 traversal reconcile numeric
lexemes before dispatch; bounded chunks drain overlong frames and resume at LF.
CRLF strips one delimiter CR, while a complete final EOF payload is decoded as-is.
The earlier48/139 binding/dispatch counts above describe their original admission;
current .1.10 evidence is53/145. The pattern and precedence defects discovered
there remain owned and do not invalidate the exact existing170-assertion scope.
See [[julia-mcp-pattern-terminal-newline-gap]] and [[perl-mcp-validation-error-order-drift]].
2026-09-11 Julia .1.37 exact reading and focused replay: `docs/tasks/JULIA-STARTUP-READING.md`, section `Reading evidence .1.37`.

## September 11 complete stdio-consumer reading

Julia .1.38 reads `julia/test/mcp_server_julia_stdio_test.jl`230–656 to EOF:
427 fragments /16,742 bytes, SHAd42cdb7e62c8933b86319a0a0573c98a3d056f5e31dee641fc6a53cd8c7066d0.
Together with .1.37, every source line is now read. All170 existing assertions
pass: ten neutral raw classifications, escaped-key collisions, number/ID kinds,
64/65-character IDs, inclusive line limits, CRLF/final EOF, malformed/oversized
frame recovery, chunked discovery/list/capability/query responses, cancellation
before emission, late cancellation, hostile read/write/flush/log and argument
preflight. Caller-open and released-state assertions retain their exact cases.
Static forbidden-string checks constrain the production surface but do not
constitute a complete sandbox or effect proof. The current terminal-LF and
validation-precedence findings remain separately owned. Neutral transport stays
35 frames /10 raw inputs /10 lifecycle cases /76 rejected mutations. The complete
focused command is in [[julia-progressive-span-dispatch-admission]] below.
