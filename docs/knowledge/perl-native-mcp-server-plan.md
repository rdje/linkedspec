---
id: perl-native-mcp-server-plan
title: Perl native MCP server plan
status: current authority; behavior-free implementation plan, server pending
date: 2026-07-29
answers:
  - What Perl module will own the native LinkedSpec MCP server?
  - How will Perl MCP avoid reading contract files at runtime?
  - How will Perl reject duplicate JSON keys when JSON::PP accepts them?
  - Where do Perl MCP handles get 256 bits of entropy?
  - How does Perl MCP compare authorization context and enforce expiry?
  - Why is the Perl descriptor not an MCP payload?
  - Which leaves implement and admit the Perl MCP server?
reverify:
  - bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py
  - bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py
  - perl -Iperl t/semantic_index_perl_query.t
  - perl -Iperl t/semantic_introspection_perl_admission.t
---

# Perl native MCP server plan

`FUTURE-PARITY-BACKLOG.10.9.2.0` and ADR `0057` freeze a filesystem-free native Perl implementation before code.
The public owner will be `LinkedSpec::MCPServer`; private generated `LinkedSpec::MCPContract` data,
`LinkedSpec::MCPContractRuntime`, and strict `LinkedSpec::MCPWire` keep contract, schema, registry/dispatch, and
stdio authority separate. `tools/generate_perl_mcp_contract.py` will deterministically derive the embedded binding
from the exact neutral bundle and check byte freshness after the neutral materializer/validator.

LinkedSpec's own probe against `graph.spec` finds two `CODE` and five `Regexp` values in `return_descriptor`, so
the descriptor remains a nonportable compatibility projection. The opaque `LinkedSpec::SemanticIndex` is the only
native server value: capabilities digest
`a5f759dc8a5d060a36f86d35d5a86ff8b6745ef87cbe03d2c8b5a3200ddfd141` and graph-list digest
`b8872b7340d2d6f4aaa409745fe0083bc744a594e09a05ed5b9786446594df0b` match the neutral oracle exactly.

Perl `JSON::PP 4.06` accepts literal and escape-equivalent duplicate object keys. The wire owner must therefore
preflight tokens and compare decoded key identity before `JSON::PP`, retain numeric token kind for exact request-id
validation, and enforce strict UTF-8/BOM/depth/line/root rules. Production handles read exactly 32 bytes from
`/dev/urandom`, use unpadded base64url, and expire against `Time::HiRes::CLOCK_MONOTONIC`; absence or short reads
fail closed with no weak fallback. Only a private test constructor may inject deterministic entropy/time.

Registration accepts an existing `LinkedSpec::SemanticIndex`, a nonempty opaque byte-string authorization context
of at most 4,096 octets, bounded lifetime, and lowering-only policy. It retains only the context's SHA-256 digest;
each tool call hashes its out-of-band context and compares exactly 32 bytes through a branch-free XOR accumulator
(using a dummy digest for unknown handles), then rechecks revocation, absolute monotonic expiry, and policy. This
does not claim formal interpreter-level constant time, but unknown/expired/revoked/unauthorized states stay
externally indistinguishable. The registry stores only the index, auth/lifecycle state, policy, and five native
policy scalars—not semantic responses. The four implementation leaves are in-process binding/registry/dispatch
`.1`, strict stdio/lifecycle `.2`, exact Perl admission/ledger `.3`, and no-change closeout `.4`.
