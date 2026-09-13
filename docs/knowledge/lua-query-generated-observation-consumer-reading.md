---
id: lua-query-generated-observation-consumer-reading
title: Lua query and generated observation consumer reading retains the PUC nil-error failure
answers:
  - "what exact Lua source did startup reading child 45 cover"
  - "which Lua semantic query hashes and malformed requests are tested"
  - "what proves Lua generated execution without a sink avoids observation work"
  - "does the Lua generated observation suite pass on installed PUC 5.5"
  - "which native observation prefix is executed in Lua reading child 45"
  - "which query and observation limitations remain after startup consumer reading"
  - "what focused evidence was verified for Lua reading child 45"
date: 2026-09-13
status: exact source reading and evidence verification complete; known PUC 5.5 generated test failure remains open
tags: [lua, semantic-introspection, query, observation, generated-source, startup, evidence]
evidence: "LUA-STARTUP-READING.1.45 activates from 98c15b80597cff8fc25b52e93ff1f99a155c5598. Nine complete windows read three ranges, 1500 fragments /59366 bytes. Six managed jobs finish: query 571 and native-prefix 41 pass per host; generated LuaJIT 80/80 passes and PUC 5.5 remains FAIL 79/80 exit 1 for known nil-error identity. No production changes or new repair node."
reverify: "Run LUA_QUERY_OBSERVATION_READING_45 and the managed commands below. Preserve generated PUC exit 1 and its exact diagnostic; evidence verification success does not make that suite pass. Native selection is unchanged lines 1-226 only."
---

# Exact source coverage

| Repository source | Inclusive lines | Fragments / bytes | Raw SHA-256 |
| --- | --- | --- | --- |
| lua/test/semantic_index_query_kernel_test.lua | 155–861 | 707 /28842 | 6f1089b965c4b81ede12c7c0ccc967c5fae8bda65a84c5515871d16a66464c07 |
| lua/test/semantic_index_runtime_observation_generated_routes_test.lua | 1–536 | 536 /21310 | fd6d1219f751516b99dfa296601757f305b75b7ffba460a82aaf0c69408215c2 |
| lua/test/semantic_index_runtime_observation_native_test.lua | 1–257 | 257 /9214 | b252b43b891ae97747e88d4edb8229c77becd7be99f64c883e0b86fe48da82b2 |

Credited windows are query-kernel 155–340,341–525,526–700,701–861;
generated-observation 1–180,181–360,361–536; and native-observation 1–130,131–257.
Every source window was returned completely. Ordered range SHA-256 is
`368dfb410954a394d22b374c7803e8bd27a15448f42e2d759121efcaf8bfdf5d`.
All 99 Lua sources remain baseline-identical to
`baeb984e36a94a15951cd23d4c52def5064cdaca`. Reading reaches 45/51 groups,
63,040 fragments /2,401,656 bytes and 83 complete files. Query-kernel and generated
observation tests are now fully read; native observation remains partial.

# Complete query consumer

The unchanged query suite passes 571 assertions on each installed host. Five
fixture snapshots cover graph, calls, failed compilation, privacy and limited
privacy. Typed requests translate neutral JSON null cursor fields into absent Lua
values and copy plain sequences and options. Nineteen static query ids, including
ten completion rows, compare typed and raw-neutral status, canonical record and
relation ids, diagnostics, completeness and the entire expected SHA-256 response.
The runtime twentieth query is tested separately by generated observation.

Twenty-six malformed raw envelopes lock exact reason, empty output and zero
record/relation cost: request/contract/field shape, operations, subjects, duplicate
and ranked kinds, order/direction/cursor, limits, source ceiling, digest/operation
combinations and missing/non-explainable ids. Boolean numeric limits reject.
Decimal, NaN and Infinity-looking after-id strings reject; hexadecimal-looking
text retains identifier shape but fails stream membership. No malformed native
regex is compiled by these fixtures.

Repeated and interleaved calls return fresh exact JSON. None/text source modes
retain precise null/redaction paths and Unicode excerpts; a higher source ceiling
fails with zero work costs. Explain returns the decision before ordered steps and
relations. Nested caller/response/source edits remain isolated. Public query value
handles have protected empty raw tables and cannot expose internal authority.

Traversal covers outgoing/incoming/both directions, canonical order, staged and
generated relation costs, after-id pages and explicit page limits. Record,
relation and depth limits retain deterministic prefixes and relation-before-depth
diagnostic precedence, including two-layer traversal. Explain reserves one record
for its decision. These exact fixtures do not close the separately measured
shared explanation-budget defect under SESSION-STARTUP-READING.82.

Seven typed constructors reject invalid option/sequence shapes. The root exports
request construction, request/response predicates and response JSON; index-only
query/capability entrypoints remain on the index. Raw callback-shaped fields are
not called, metatable-backed input does not invoke __index/__pairs, ambiguous plain
tables reject, and unknown cyclic extra fields reject without traversing them.
The raw-false echo omission under .2.15 remains outside these assertions.

Source scans count one detached materialization and evaluator call site per route,
the narrow JSON dependency and absent host-authority tokens. Those scans are not
instrumented invocation measurements or a universal execution-silence proof.

# Complete generated-observation consumer

The fixture emits three canonical events: accepted Top slots zero and one at
scalar offsets one and two, followed by a successful Top result at offset two.
Its input digest is
`input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece`.
Derived typed and raw-neutral queries lock the twentieth response digest
`36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`.

Public generated execution, traced helpers and freshly loaded current-host emitted
modules retain values, event JSON, digests and exact quiet-versus-observed trace
bytes. Deterministic generated-source-v2/format 2 text retains only label/family
plan metadata and omits serialized callback state and observation vocabulary.
Controlled replacement of event constructors and the input hash function with
throwing sentinels proves no-sink execution avoids those calls; each original is
restored. This is active instrumentation, unlike the query source-token checks.

Unwrapped generated metadata and an orphan sink marker reject before any event.
Callback probes throw string, table, nil and runtime-error values on the second
event, checking failure, exact identity and delivered count. PUC 5.5 fails precisely
the nil identity assertion: expected nil, got <no error object>. LuaJIT preserves
nil. The unchanged complete footer reports PUC FAIL 1 of 80 with exit 1, versus
LuaJIT PASS 80 with exit 0. No expectation is edited or result translated.

Table-error identity through traced execution, one-event stopping and cleanup
markers pass with the fixture's healthy writer. Separate diagnostic events remain
outside semantic capture. No-match emits one final null result; immediate exit 7
and runtime failure each retain the preceding accepted slot and omit final result
capture. Runtime failure keeps its typed generated error. Reentrant execution
maintains separate inner and outer three-event lists. The earlier arbitrary-writer
identity limitation under .2.30 remains open.

The complete test also creates a repository-volume temporary generated module and
runner, then executes a fresh child on the selected host. Direct/traced values,
typed events, input digest, observed-query digest and trace presence match exactly;
the parent checks child status 0 and empty stderr. Its cleanup command succeeds.
This wrapper has no separate post-cleanup absence assertion, so none is claimed.

# Native prefix and exact accounting

Native reading ends at 257 inside the alias-route list beginning at 228. The scratch
selection copies exact lines 1–226, ending after the complete temporary fixture
block, and appends only an assertion/failure summary. Partial alias iteration and
later callback checks are excluded. This prefix checks canonical direct events,
detached values and direct/loaded/reconstructed route equivalence at 41 assertions
per host. No fresh complete-native121 claim follows from this selection.

All six jobs are consumed. Query571 plus native-prefix 41 pass on both hosts;
generated LuaJIT passes 80 and PUC passes 79 of 80, exiting1. The exact total is
1,383/1,384 assertions. Evidence verification checks all six complete log strings,
all six observed exit statuses and the three source hashes. Its own PASS means
the reported evidence is exact; the PUC suite remains FAIL under .2.2.

The earlier native 120/121 PUC and 121/121 LuaJIT results remain dated child 17 proof.
No full CI, primary/cross-backend matrix, PGEN/RGX build, push or supported-PUC 5.4
admission is performed. All earlier malformed-native-error exclusions remain.

# Knowledge and repair reconciliation

Read [[lua-semantic-query-observation-reading-and-evidence-gaps]],
[[lua-semantic-runtime-observation-generated-routes]] and
[[lua-semantic-runtime-observation-direct-capture]]; reuse the completely read
query-kernel card and child 17 public-query/traversal facts. Existing .2.1 now owns
unqualified callback-nil identity wording and generated-stage pending-rollout/
admission pointers. Historical 80/121 counts remain dated fixture evidence rather
than current supported-runtime certification. No old card is rewritten here.

Existing .2.2 gains this exact generated 79/80 re-verification. Child17 already
root-caused the difference with bare host pcall/error and official Lua5.5 language
and implementation evidence, without LinkedSpec. No redundant cause probe or
runtime install is needed. Preserve the declared 5.4 target and restore a verified
matching runtime/header pair after startup prerequisites; do not map the legitimate
error string back to nil or weaken the expectation. Reading/evidence work can
continue while the already-owned runtime repair remains gated.

All 33 repair roots, query-false .2.15, shared explanation-budget .82, earlier
public-selector failure and native-error exclusions remain open. Named arguments
stay parked in their unchanged authoring tree. This leaf introduces no new repair
node or production change. A broad auxiliary task/book extraction was truncated;
the needed repair-node tails were subsequently returned completely. That output
earns no source-reading credit.

# Exact replay

```bash
bash tools/project_data_run.sh python3 - <<'LUA_QUERY_OBSERVATION_READING_45'
from pathlib import Path
p=Path('.linkedspec-data/scratch/lua145')
p.mkdir(parents=True, exist_ok=True)
(p / 'select-tests.py').write_text('from pathlib import Path\n\np = Path(\'.linkedspec-data/scratch/lua145\')\nlines = Path(\'lua/test/semantic_index_runtime_observation_native_test.lua\').read_text().splitlines(keepends=True)\nassert lines[225].strip() == \'end)\'\nassert lines[227].startswith(\'for _, route in ipairs({\')\nfooter = \'\'\'\nif #failures == 0 then\n  io.stdout:write("Lua native semantic observation read prefix: ", assertions, " assertions passed\\\\n")\nelse\n  io.stderr:write("Lua native semantic observation read prefix: ", #failures, " of ", assertions, " assertions failed\\\\n")\n  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\\\\n") end\n  os.exit(1)\nend\n\'\'\'\n(p / \'native-read-prefix.lua\').write_text(\'\'.join(lines[:226]) + footer)\nprint(\'Selected unchanged native test lines 1-226; the partial alias loop is excluded\')\n')
(p / 'verify.py').write_text("from pathlib import Path\nimport hashlib, json\n\np = Path('.linkedspec-data/scratch/lua145')\nfor row in json.loads((p / 'scope.json').read_text()):\n    data = b''.join(Path(row['path']).read_bytes().splitlines(keepends=True)[row['start'] - 1:row['end']])\n    assert len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256']\nfor host in ['puc', 'luajit']:\n    expected = {\n        'query': ('ok - semantic index query kernel (571 assertions)\\n', 0),\n        'native-prefix': ('Lua native semantic observation read prefix: 41 assertions passed\\n', 0),\n        'generated': ('Lua generated semantic observation routes: 1 of 80 assertions failed\\n- nil callback exact identity: expected nil, got <no error object>\\n', 1) if host == 'puc' else ('Lua generated semantic observation routes: 80 assertions passed\\n', 0),\n    }\n    for name, (line, status) in expected.items():\n        assert (p / f'{name}-{host}.log').read_text() == line, (name, host)\n        assert (p / f'{name}-{host}.exit').read_text() == str(status) + '\\n', (name, host)\nprint('PASS evidence verification: three exact source ranges; query 571 and native read-prefix 41 pass per host; generated observation remains FAIL 79/80 exit1 on PUC5.5 and PASS 80/80 on LuaJIT. Total 1383/1384; known .2.2 remains open.')\n")
(p / 'scope.json').write_text('[\n  {\n    "path": "lua/test/semantic_index_query_kernel_test.lua",\n    "start": 155,\n    "end": 861,\n    "bytes": 28842,\n    "sha256": "6f1089b965c4b81ede12c7c0ccc967c5fae8bda65a84c5515871d16a66464c07"\n  },\n  {\n    "path": "lua/test/semantic_index_runtime_observation_generated_routes_test.lua",\n    "start": 1,\n    "end": 536,\n    "bytes": 21310,\n    "sha256": "fd6d1219f751516b99dfa296601757f305b75b7ffba460a82aaf0c69408215c2"\n  },\n  {\n    "path": "lua/test/semantic_index_runtime_observation_native_test.lua",\n    "start": 1,\n    "end": 257,\n    "bytes": 9214,\n    "sha256": "b252b43b891ae97747e88d4edb8229c77becd7be99f64c883e0b86fe48da82b2"\n  }\n]\n')
LUA_QUERY_OBSERVATION_READING_45
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua145/select-tests.py
for host in puc luajit; do
  status=0
  bash tools/run_lua_project_data.sh "$host" lua/test/semantic_index_query_kernel_test.lua > ".linkedspec-data/scratch/lua145/query-$host.log" 2>&1 || status=$?
  printf '%s\n' "$status" > ".linkedspec-data/scratch/lua145/query-$host.exit"
  status=0
  bash tools/run_lua_project_data.sh "$host" lua/test/semantic_index_runtime_observation_generated_routes_test.lua > ".linkedspec-data/scratch/lua145/generated-$host.log" 2>&1 || status=$?
  printf '%s\n' "$status" > ".linkedspec-data/scratch/lua145/generated-$host.exit"
  status=0
  bash tools/run_lua_project_data.sh "$host" .linkedspec-data/scratch/lua145/native-read-prefix.lua > ".linkedspec-data/scratch/lua145/native-prefix-$host.log" 2>&1 || status=$?
  printf '%s\n' "$status" > ".linkedspec-data/scratch/lua145/native-prefix-$host.exit"
done
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua145/verify.py
```

Related: [[lua-package-completion-semantic-foundation-reading]],
[[lua-startup-reading-coverage]], [[lua-semantic-query-kernel]].

# Preservation and focused completion

The independent audit preserves 1,421 prior source/Knowledge/decision/history/policy
files and 2,578 of 2,582 existing task nodes byte-exactly. Only this leaf, the two
existing repair owners and startup .3.6 change; no task node is added. All ninety
prior Known book headings and the parked authoring tree remain. All three embedded
replay payloads match the executed scratch files exactly. Independent coverage
reconstructs every range and all 45 completed children with unchanged inventory,
range and group digests.

History validation passes 34 mutation controls, three surfaces and 67 segments.
The root hot shards are Changes 312 and Notes 459 lines; the next leaf must own the
notes rollover before extending it. Knowledge regeneration reports 1,131 cards /
9,036 question keys. The book renders successfully with its existing large-search-
index warning at 10,171,555 bytes, still owned by startup .41.9. Explicit memory
validation and whitespace checks pass. The normal per-leaf hooks and activation
check are required at landing; no full CI or push is claimed here.
