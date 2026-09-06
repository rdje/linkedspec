---
id: perl-native-mcp-server-plan
title: Perl native MCP server plan
status: current historical plan; implementation, admission, and no-change parent closeout complete under FUTURE-PARITY-BACKLOG.10.9.2.1-.4
date: 2026-09-06
answers:
  - What Perl module will own the native LinkedSpec MCP server?
  - How will Perl MCP avoid reading contract files at runtime?
  - How will Perl reject duplicate JSON keys when JSON::PP accepts them?
  - Where do Perl MCP handles get 256 bits of entropy?
  - How does Perl MCP compare authorization context and enforce expiry?
  - Why is the Perl descriptor not an MCP payload?
  - Which leaves implement and admit the Perl MCP server?
  - Which semantic payload examples are embedded in the Perl MCP binding?
  - Does the Perl MCP bundle preserve the neutral artifact and response digests?
reverify:
  - bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py
  - bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py
  - perl -Iperl t/semantic_index_perl_query.t
  - perl -Iperl t/semantic_introspection_perl_admission.t
---

# Perl native MCP server plan

`FUTURE-PARITY-BACKLOG.10.9.2.0` and ADR `0057` froze a filesystem-free native Perl implementation before code.
The implemented public owner is `LinkedSpec::MCPServer`; private generated `LinkedSpec::MCPContract` data,
`LinkedSpec::MCPContractRuntime`, and strict `LinkedSpec::MCPWire` keep contract, schema, registry/dispatch, and
stdio authority separate. `tools/generate_perl_mcp_contract.py` deterministically derives the embedded binding
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

## September 6 embedded payload and digest boundary

`SESSION-STARTUP-READING.3.2.37` reads MCPContract.pm bytes 65927–83273, finishing its embedded JSON
schema and payload data. The remaining Perl accessor suffix belongs to `.3.2.38`. The generated bundle stores
four transport examples: default capabilities, the restricted capabilities projection, graph-list rules, and
an invalid-operation semantic response. Three preserve native responses (including native ok=false); the fourth
is the declared capability-field projection. Those four transport examples do not replace the separate
all-twenty native/MCP consumer authority in [[mcp-recurring-six-runtime-plan]].

The exact embedded JSON is canonical and matches its header SHA-256; its payload collection equals the neutral
payload file. All four response hashes and all seven neutral source-artifact hashes match. The managed generator
also confirms the 83,411-byte binding is byte-fresh. This is data identity/freshness evidence, not new native
query or server dispatch proof. The public compiled descriptor remains outside the MCP payload boundary above.

Reverify the bounded suffix and digest checks:

```sh
bash tools/project_data_run.sh env PYTHONDONTWRITEBYTECODE=1 python3 - <<'PY'
from pathlib import Path
import json,hashlib,re,subprocess
p='perl/LinkedSpec/MCPContract.pm';raw=Path(p).read_bytes();assert raw==subprocess.check_output(['git','show','baeb984e36a94a15951cd23d4c52def5064cdaca:'+p]);part=raw[65926:83273];assert len(part)==17347
print('Exact baseline and suffix bytes65927–83273 SHA256 '+hashlib.sha256(part).hexdigest())
line=raw.splitlines()[13];bundle=json.loads(line);declared=re.search(rb"BUNDLE_SHA256 = '([0-9a-f]{64})'",raw).group(1).decode();assert hashlib.sha256(line).hexdigest()==declared
canonical=lambda v:json.dumps(v,ensure_ascii=False,sort_keys=True,separators=(',',':')).encode()
assert canonical(bundle)==line
payloads=bundle['semantic_payloads'];assert payloads==json.loads(Path('capability_conformance/mcp_semantic_transport/semantic_payloads.json').read_text())
for payload in payloads['payloads']:
 assert hashlib.sha256(canonical(payload['response'])).hexdigest()==payload['response_sha256']
 print(payload['id']+': canonical response digest PASS')
for key,path in bundle['contract']['artifacts'].items():
 assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==bundle['source_sha256'][key]
print('Canonical embedded JSON/header digest, neutral payload identity, four response digests, seven source digests PASS')
PY
```
