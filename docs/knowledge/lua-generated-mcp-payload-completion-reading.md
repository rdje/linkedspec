---
id: lua-generated-mcp-payload-completion-reading
title: Lua generated MCP payload completion and independent neutral reconciliation
answers:
  - what did Lua startup reading group thirteen cover
  - is the full generated Lua MCP JSON payload physically read
  - how does Lua embedded MCP data reconcile with the neutral artifact sources
  - what do the four embedded MCP semantic payload fixtures represent
date: 2026-09-12
status: exact group thirteen read; final module line and MCP runtime reading remain
tags: [lua, reading, mcp, generated, schema, payload]
evidence: "LUA-STARTUP-READING.1.13 reads bytes 65797-83164 in three complete windows from a8834341b59d39b56b9de4fd24fa1db2e1959012. Independent reconciliation matches the 82882-byte bundle, seven artifact digests, three embedded artifact values, 35 frames and four payload digests. Neutral transport passes 76 mutations; cumulative reading is 13/51, 15151 fragments and 663181 bytes."
reverify:
  - "Run the independent managed reconciliation below."
  - "Run LUA_READING_COVERAGE in docs/knowledge/lua-startup-reading-coverage.md."
  - "bash tools/run_python_project_data.sh tools/generate_lua_mcp_contract.py"
  - "bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py"
---

# Exact reading

Activation is `a8834341b59d39b56b9de4fd24fa1db2e1959012`; source baseline remains
`baeb984e36a94a15951cd23d4c52def5064cdaca`. This leaf reads
`lua/src/linkedspec/mcp_contract.lua` bytes 65797–83164 inclusive: one LF fragment
and 17,368 bytes. Ordered-range SHA-256 is
`fdd776f35ec057bfc00cd19ef0a1ede2371bd55093d29f6ae51e6907685f3a5f`;
selected-content SHA-256 is
`d8abe2d6e689642cc64c6401bc6243142059e1dc5e7917d8f08c76d17f9e64ef`.

| Inclusive bytes | Bytes | SHA-256 |
| --- | ---: | --- |
| 65797–73988 | 8192 | cabbbddb2dbb92c5e53217261ba1d2c9d8d293c8a06fc05d1a648e081976be02 |
| 73989–82180 | 8192 | 5ffd9384298a2a6229c8f8cab652e0d089d39d5872c8381361d5df9432588cb7 |
| 82181–83164 | 984 | b4b868c9a6806d1c0e4f1230f6cb059c4a91280079192ead73da0fc4c31d0a02 |

All three windows were read completely without truncation. Together with .1.12,
they finish physical reading of the oversized literal and its field terminator.
The module's final two bytes belong to .1.14 and remain outside this leaf's credit.
Cumulative reading is 13/51 groups, 15,151 fragments /663,181 bytes; eighteen files
are complete and the generated module is still formally partial. The next group
also owns the contract runtime, decoded server and first wire-module range.

# Comprehension and canonical reconciliation

The suffix completes the semantic request/response schema, including source
references, snapshots, records, relations, recursive shapes, callable signatures
and named parameters. Tool success requires structured semantic content and one
text content item; tool execution errors use their separate result shape. Tool
listing fixes the two tool names in order and advertises complete public results
with the pinned cache lifetime. The top-level schema is a union of ten envelope
forms. Definitions alone do not prove native runtime enforcement.

Four semantic fixtures follow. Default capabilities are an exact native response.
Restricted capabilities identify their source fixture and explicit policy-only
projection: defaults and maxima become depth 2 /records 100 /relations 200,
page defaults/maxima become 50, source detail becomes identity and content digests
are unavailable. The rule-list fixture retains Top/Child order, value shapes,
source identity and cursor/repetition facts. Invalid operation combination retains
a typed semantic diagnostic, empty records/relations and semantic `ok: false`.
Each fixture pins the digest of its response, and the bundle ends with seven
source-artifact digests matching the embedded contract manifest.

Canonical retrieval used [[mcp-2026-07-28-stdio-contract]] plus the previously read
[[lua-native-mcp-server-plan]], [[lua-mcp-decoded-server]] and
[[lua-mcp-implementation-admission]]. The preceding exact byte-range evidence is
[[lua-generated-mcp-first-byte-range-reading]]. The transport card's initial
68-mutation count is historical; its later 76-mutation count matches the current
run. None of these checks verifies external protocol publications afresh.

# Independent proof and limits

The standalone Python replay below imports only the standard library. It extracts
the long-bracket payload, rejects duplicate object keys, checks canonical UTF-8
JSON identity, compares the bundle and contract hashes, and reads each of the seven
manifest-owned artifact paths. The schema, corpus and semantic payload objects
match their source values; the complete named frame dictionary matches all 35
ordered JSONL frames; all four semantic response digests match independently.

The exact executed scratch script is 2,336 bytes, SHA-256
`cc27b4622103678003939e4614851d874a7fbed1bcf11301de1fe631a8af1484`.
Its complete payload follows. The repository's normal generator comparison passes
at 83,166 module bytes. Materialization then independent transport validation pass
35 frames, ten raw inputs, ten lifecycle cases and 76 rejected mutations.
Neither regeneration command uses its write mode.

The previous leaf's 116 binding assertions per installed host remain the most
recent native binding proof; they are not rerun or counted as fresh .1.13 tests.
All Lua source bytes, including those test/runtime owners, remain unchanged.
There is no fresh full-server, six-runtime execution, corpus, full CI or declared
PUC 5.4 result. All eleven Lua repair roots and startup .37.1/.28.7 remain open;
startup .3/.4/.5 and later canonical boundaries retain their prerequisites.
No new runtime defect is established by this generated-data range.

```bash
bash tools/project_data_run.sh python3 - <<'LUA_MCP_READING_13'
from pathlib import Path
import hashlib, json, re

def digest(data):
    return hashlib.sha256(data).hexdigest()

def canonical(value):
    return json.dumps(value, ensure_ascii=False, allow_nan=False, sort_keys=True, separators=(",", ":")).encode("utf-8")

def unique(pairs):
    result = {}
    for key, value in pairs:
        assert key not in result, key
        result[key] = value
    return result

def decode(data):
    return json.loads(data, object_pairs_hook=unique)

source = Path("lua/src/linkedspec/mcp_contract.lua").read_bytes()
match = re.search(rb"bundle_json = \[\[(.*)\]\],\n", source, re.S)
assert match is not None
embedded = match.group(1)
bundle = decode(embedded)
assert len(embedded) == 82882 and canonical(bundle) == embedded
assert digest(embedded) == re.search(rb'bundle_sha256 = "([0-9a-f]{64})"', source).group(1).decode()
contract_bytes = Path("capability_conformance/mcp_semantic_transport_contract.json").read_bytes()
assert bundle["contract"] == decode(contract_bytes)
assert bundle["contract_sha256"] == digest(contract_bytes)
artifacts = bundle["contract"]["artifacts"]
assert len(artifacts) == 7
for name, path in artifacts.items():
    value = Path(path).read_bytes()
    assert digest(value) == bundle["source_sha256"][name] == bundle["contract"]["artifact_sha256"][name]
    if name in ("schema", "corpus", "semantic_payloads"):
        assert bundle[name] == decode(value)
frames = [decode(line) for line in Path(artifacts["canonical_frames"]).read_bytes().splitlines()]
order = bundle["corpus"]["canonical_order"]
assert len(frames) == len(order) == 35 and len(set(order)) == 35
assert bundle["canonical_frames"] == dict(zip(order, frames))
payloads = bundle["semantic_payloads"]["payloads"]
assert len(payloads) == 4
for payload in payloads:
    assert digest(canonical(payload["response"])) == payload["response_sha256"]
selected = source[65796:83164]
assert len(selected) == 17368
assert digest(selected) == "d8abe2d6e689642cc64c6401bc6243142059e1dc5e7917d8f08c76d17f9e64ef"
for start, end in [(65796, 73988), (73988, 82180), (82180, 83164)]:
    source[start:end].decode("utf-8")
    print(start + 1, end, digest(source[start:end]))
print("PASS canonical bundle, contract, seven artifact digests, three embedded artifact values, 35 frames, four payload digests and group thirteen bytes")
LUA_MCP_READING_13
```

Reading credit is separate from the replay's whole-file data extraction. Exact
coverage and source identity are independently reproduced by LUA_READING_COVERAGE;
current aggregate/frontier pointers are checked against the completed-node sum.
Memory, Knowledge, both history checks, rendered book and normal doctrine hooks
remain required before landing. ADR0118's finite evidence controls are unchanged.

The activation comparison preserves 1,387 prior source/Knowledge/decision/history
and selected policy files byte-for-byte, 2,470 prior task nodes (only this leaf and
startup .3.6 change), all 63 prior Known headings, both exact history suffixes and
the live-history query section. The completed-node sum is 13 /15,151 /663,181.
Memory is 60 lines; history roots are 305 and 452 lines within their caps. The
book renders with the existing search-index warning owned by startup .41.9.
