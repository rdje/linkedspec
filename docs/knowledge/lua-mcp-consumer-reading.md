---
id: lua-mcp-consumer-reading
title: Lua MCP consumer reading separates scoped execution from admission source markers
answers:
  - "what exact Lua source did startup reading child 33 cover"
  - "which MCP consumers passed during Lua startup reading child 33"
  - "does the Lua MCP admission test execute the private pre emission cancellation seam"
  - "which Lua MCP tests execute native failure and decoded cancellation"
  - "which exact Lua stdio prefix has 71 assertions"
  - "which Lua MCP bundle and rollout guidance remains owned for qualification"
date: 2026-09-13
status: exact scoped reading and selected consumers pass; stdio suffix and prior repairs remain open
tags: [lua, mcp, binding, dispatch, stdio, admission, startup, evidence]
evidence: "LUA-STARTUP-READING.1.33 activates from e8f630f33581005524168bf3fa08e82d212ba0ea. Nine complete windows read 1500 fragments /63081 bytes. Both installed hosts pass binding116, admission281, dispatch216 and stdio-prefix71: 1368 assertions. Generated binding is byte-fresh at83166 bytes; neutral admission passes complete5/5+6/6/141. Existing .2.1 owns precise bundle/rollout guidance qualification; no production change or new runtime repair."
reverify: "Run LUA_MCP_CONSUMER_READING_33 and the managed commands below; pre-emission stdio execution remains outside this fresh prefix."
---

# Exact reading

| Repository source | Inclusive lines | Fragments / bytes | Raw SHA-256 |
| --- | --- | --- | --- |
| lua/test/mcp_contract_lua_binding_test.lua | 10–169 | 160 /7055 | 6bbacb5712978b76eab72ba6899a1ab8e0adf8d016f8f298de89cad55daed082 |
| lua/test/mcp_server_lua_admission_test.lua | 1–663 | 663 /28015 | d2175aea782ab31ab05365e38867509f041a3a59cf6787139a76ace790cb60ae |
| lua/test/mcp_server_lua_dispatch_test.lua | 1–484 | 484 /21869 | be937de458f24e30e2152ae0bcd4cfb2aedab609f231b431f00b67fdcf65969d |
| lua/test/mcp_server_lua_stdio_test.lua | 1–193 | 193 /6142 | dbd7612af9fb72870b5d4f010c6fb745fe639405a633ca73d271f5ff2316e542 |

Binding10–169 is one viewing window. Admission windows are 1–170, 171–340,
341–510 and511–663; dispatch windows are 1–160, 161–320 and321–484; stdio1–193
has one window. All nine outputs were complete. Ordered range SHA-256 is
`0138435828188c9efec0c835dc99756023ac610d54217bca56ee05e8d53e7412`.
All 99 Lua sources remain baseline-identical to
`baeb984e36a94a15951cd23d4c52def5064cdaca`. Reading reaches 33/51 groups,
45,151 fragments /1,682,742 bytes and 62 complete files. Stdio remains partial:
the final lines begin the lexical-test block, which belongs to child34.

# Generated binding and decoded dispatch

The binding consumer verifies format1, an 82,882-byte canonical bundle, its SHA-256,
embedded artifact digests, all 35 frame identities and frozen schema cases.
Unknown frames/payloads remain absent. Envelope extras, boolean IDs, UTF-8 byte
ceilings, query-contract character/byte limits, exact handle shape and unknown
definitions retain their classifications. Detached frames, contract and tool
payloads cannot change retained data. Canonical text equals structured content,
keys sort recursively without text normalization, and nonfinite values reject.
Source checks retain the immediate raw long-bracket binding and restricted runtime
dependencies. The local protocol version is pinned repository contract data, not
an assertion about the newest external MCP specification.

Dispatch begins by checking lazy implementation loading. Public static requests
produce exact canonical classifications while caller input stays unchanged;
notifications remain silent. Registration retains the actual semantic index,
validates capabilities once and makes fresh native calls thereafter. Semantic
`ok:false` remains a successful tool envelope. Explicit policy restrictions reject
source/digest/page/budget excess before native query; omitted or unrelated partial
overlays preserve native source-ceiling and unsupported-contract diagnostics.
Policies may not elevate native capabilities.

Deterministic private entropy/clock seams verify unknown, unauthorized, expired
and revoked handle equivalence, idempotent revoke/shutdown, invalid authorization
and lifetime, expiry pruning, capacity, released indexes and post-shutdown behavior.
Short entropy, bounded collision, clock failure/overflow and invalid index or
capability payloads retain typed errors. Injected native exceptions and malformed
native responses become fixed internal errors. In-flight decoded cancellation
suppresses the response and releases request state; a later request succeeds and
late cancellation cannot mutate its completed result. Protected public values and
the production native system seam are exercised without exposing private test APIs
through the root facade. These are local fixtures and caller-owned objects.

# Admission composition and stdio prefix

The admission consumer records twelve roles once in exact order. Inventory checks
35 canonical frames, raw/lifecycle/handle/policy order and the 76-case transport
validator inventory. Static dispatch matches pinned responses. Capabilities plus
all nineteen query cases compare native structured data, canonical text and exact
governed response digests. Runtime semantic input builds a three-event observation
snapshot with the expected two-value result. Registration remains host-owned.

Ten raw-input cases execute public stdio with exact output, empty operational log
and caller-owned streams. Lifecycle checks cover ready dispatch, LF output,
unknown/late cancellation, legacy silence, the real 1,024-entry production capacity,
expired-entry pruning, clean EOF and fixed I/O failure. Handle equivalence and
policy projection are compared independently. Later I/O failure preserves earlier
flushed output; output failure shuts down and releases state. Error/log fields omit
fixture-private text. Source/API/native dependency checks preserve the intended
module boundaries and absence of a primary-CLI server bootstrap.

Two admission subproofs use source markers: cancellation_emission reads the focused
stdio source for its before_wire_emit seam and suppression assertion, while the
native-failure portion reads the dispatch source for its injected throw case.
The admission consumer does not execute those private subcases merely by finding
their markers. It does execute successful emission and late cancellation. This
leaf's complete dispatch run independently executes native failure and decoded
cancellation; the specific before-wire-emission stdio case remains outside the
fresh prefix. This distinction qualifies the older card's composition wording
without inventing a missing runtime implementation or silently claiming coverage.

The stdio prefix reads helper streams, deterministic private construction, fixture
decoding and the first complete raw-input block. The initial lazy-wire assertion
precedes ten fixtures with seven counted checks each: exact protocol output, empty
log, three streams left open, no registered handles and no active requests. One
final check confirms public serve loads the private wire. Thus the complete prefix
through line189 has 71 counted assertions. Lines192–193 only begin the next block.
The scratch selector copies that complete prefix unchanged and adds final failure
and count checks; it executes no later lexical or pre-emission tests.

# Knowledge and repair reconciliation

Retrieved [[lua-generated-mcp-first-byte-range-reading]],
[[lua-mcp-implementation-admission]], [[lua-mcp-decoded-server]] and
[[lua-native-mcp-server-plan]] before deriving current mechanisms. The earlier
binding/admission/dispatch counts remain dated; fresh results are 116/281/216.
Current decoded-server guidance records the later shared rollout at 141 mutations.

Existing `LUA-STARTUP-READING.2.1` gains precise qualification of the native plan's
future implementation wording and unqualified 82,543-byte bundle, plus the earlier
admission card's shared-rollout-pending body sentence. Current comparison proves
an 83,166-byte module with an 82,882-byte bundle, and neutral governance proves
five implementations, six runtimes and complete rollout at 141 mutations. Preserve
historical sizes, original admission counts and implementation chronology.
No old Knowledge card or production file changes in this reading leaf.

All eight native jobs finish successfully: 116+281+216+71=684 per installed host,
1,368 assertions total. Generator default comparison is read-only and byte-fresh;
the fresh admission checker rejects 141 governance mutations. This does not rerun
all other backends or establish a new external protocol compatibility claim.
All thirty-three repair roots, the PUC5.5 nil-error and public-selector baseline
failures, pending PUC5.4 proof, startup .3/.4/.5 gates and parked named arguments
remain unchanged. No full CI, PGEN/RGX build, dependency change or push is claimed.

# Exact replay

```bash
bash tools/project_data_run.sh python3 - <<'LUA_MCP_CONSUMER_READING_33'
from pathlib import Path
p = Path('.linkedspec-data/scratch/lua133')
p.mkdir(parents=True, exist_ok=True)
(p / 'select-tests.py').write_text('from pathlib import Path\nsource = Path("lua/test/mcp_server_lua_stdio_test.lua").read_text().splitlines(keepends=True)\nassert source[188] == "end\\n" and source[191] == "do\\n"\nPath(".linkedspec-data/scratch/lua133/stdio-prefix.lua").write_text("".join(source[:189]) + \'\\nassert(#failures == 0, table.concat(failures, " | "))\\nassert(assertions == 71, "stdio prefix count drift: " .. assertions)\\nprint("stdio prefix: " .. assertions .. " assertions passed")\\n\')\n')
(p / 'verify.py').write_text("from pathlib import Path\nimport hashlib, json\n\np = Path('.linkedspec-data/scratch/lua133')\nfor row in json.loads((p / 'scope.json').read_text()):\n    data = b''.join(Path(row['path']).read_bytes().splitlines(keepends=True)[row['start'] - 1:row['end']])\n    assert len(data) == row['bytes']\n    assert hashlib.sha256(data).hexdigest() == row['sha256']\nexpected = {\n    'binding': '[lua-mcp-binding] PASS: 116 generated, digest, schema, clone, identity, and authority assertions\\n',\n    'admission': '[lua-mcp-admission] PASS: 281 assertions across all twelve exact roles\\n',\n    'dispatch': '[lua-mcp-dispatch] PASS: 216 public, registry, dispatch, policy, lifecycle, security, and authority assertions\\n',\n    'stdio': 'stdio prefix: 71 assertions passed\\n',\n}\nfor host in ['puc', 'luajit']:\n    for suite, result in expected.items():\n        assert (p / f'{suite}-{host}.log').read_text() == result\nassert (p / 'generator.log').read_text() == 'Lua MCP contract binding is byte-fresh (83166 bytes)\\n'\nassert (p / 'admission-neutral.log').read_text() == 'MCP implementation/admission: 5/5 implementations, 6/6 runtimes, rollout complete, 141 rejected mutations\\n'\nprint('PASS: exact source ranges; binding116 + admission281 + dispatch216 + stdio-prefix71 per host, 1368 assertions total; byte-fresh binding and complete neutral admission governance')\n")
(p / 'scope.json').write_text('[\n  {\n    "path": "lua/test/mcp_contract_lua_binding_test.lua",\n    "start": 10,\n    "end": 169,\n    "bytes": 7055,\n    "sha256": "6bbacb5712978b76eab72ba6899a1ab8e0adf8d016f8f298de89cad55daed082"\n  },\n  {\n    "path": "lua/test/mcp_server_lua_admission_test.lua",\n    "start": 1,\n    "end": 663,\n    "bytes": 28015,\n    "sha256": "d2175aea782ab31ab05365e38867509f041a3a59cf6787139a76ace790cb60ae"\n  },\n  {\n    "path": "lua/test/mcp_server_lua_dispatch_test.lua",\n    "start": 1,\n    "end": 484,\n    "bytes": 21869,\n    "sha256": "be937de458f24e30e2152ae0bcd4cfb2aedab609f231b431f00b67fdcf65969d"\n  },\n  {\n    "path": "lua/test/mcp_server_lua_stdio_test.lua",\n    "start": 1,\n    "end": 193,\n    "bytes": 6142,\n    "sha256": "dbd7612af9fb72870b5d4f010c6fb745fe639405a633ca73d271f5ff2316e542"\n  }\n]\n')
LUA_MCP_CONSUMER_READING_33
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua133/select-tests.py
for host in puc luajit; do
  bash tools/run_lua_project_data.sh "$host" lua/test/mcp_contract_lua_binding_test.lua > ".linkedspec-data/scratch/lua133/binding-$host.log" 2>&1 || exit
  bash tools/run_lua_project_data.sh "$host" lua/test/mcp_server_lua_admission_test.lua > ".linkedspec-data/scratch/lua133/admission-$host.log" 2>&1 || exit
  bash tools/run_lua_project_data.sh "$host" lua/test/mcp_server_lua_dispatch_test.lua > ".linkedspec-data/scratch/lua133/dispatch-$host.log" 2>&1 || exit
  bash tools/run_lua_project_data.sh "$host" .linkedspec-data/scratch/lua133/stdio-prefix.lua > ".linkedspec-data/scratch/lua133/stdio-$host.log" 2>&1 || exit
done
bash tools/run_python_project_data.sh tools/generate_lua_mcp_contract.py > .linkedspec-data/scratch/lua133/generator.log 2>&1
bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py > .linkedspec-data/scratch/lua133/admission-neutral.log 2>&1
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua133/verify.py
```

Related evidence: [[lua-gap-logical-map-consumer-reading]],
[[lua-startup-reading-coverage]].

# Candidate verification

Independent preservation passes for 1,408 source, prior Knowledge, decision,
immutable-history and policy files. Of 2,582 old task nodes, 2,579 are byte-identical;
only this reading leaf, existing guidance repair .2.1 and startup .3.6 change.
No repair node is added. All 90 book limitation headings, the parked authoring tree,
history preambles/suffixes and live-history pointer remain intact. All three embedded
replay payloads match their executed files. The independent full inventory/range
replay passes at 33 completed groups.

Memory remains 60 lines and phase/handoff checks pass. Shared history passes
34 mutation controls and three surfaces/66 segments. Changes is 445 lines /
32,909 bytes (within cap, pressure warning); notes is 375 lines /30,851 bytes.
Knowledge generation produces 1,119 cards and 8,952 question keys. The book renders
successfully; its existing search-index warning is 10,129,782 bytes and remains owned
by startup .41.9. Whitespace checks pass; normal per-leaf hooks govern landing.
