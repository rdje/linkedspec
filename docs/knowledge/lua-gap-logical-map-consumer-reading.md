---
id: lua-gap-logical-map-consumer-reading
title: Lua gap logical and map-leaves consumers retain their exact execution boundaries
answers:
  - "what exact Lua source did startup reading child 32 cover"
  - "which gap logical and map leaves suites passed during Lua reading child 32"
  - "which Lua gap test runs emitted modules in a fresh child process"
  - "do Lua logical and map leaves tests execute emitted source in the current host"
  - "which map leaves mutation and write guard cases are in the Lua consumer"
  - "does reading the MCP binding header establish fresh MCP execution proof"
date: 2026-09-13
status: exact scoped reading and all selected consumers pass; previous repair ownership remains open
tags: [lua, gaps, logical, map-leaves, callbacks, generated-source, startup, evidence]
evidence: "LUA-STARTUP-READING.1.32 activates from 9109e20ab1255a85d879bfdcbd32da846a14eb0b. Ten complete windows read 1500 fragments /61938 bytes. Both installed hosts pass gap392, logical359 and map530: 2562 fresh assertions. Fresh neutral logical8/0/26 and mutation167+592 pass; previous neutral gap evidence remains dated and input-identical. No new repair or production change."
reverify: "Run LUA_GAP_LOGICAL_MAP_READING_32 and the managed commands below; emitted routes and prior governance are qualified separately."
---

# Exact reading

| Repository source | Inclusive lines | Fragments / bytes | Raw SHA-256 |
| --- | --- | --- | --- |
| lua/test/inter_match_gap_capture_contract_test.lua | 948–1462 | 515 /18697 | 487a2e39b2ff4e465f742d575c360ae28d32f189b4f4b55a736ecb3255845c81 |
| lua/test/logical_helper_contract_test.lua | 1–280 | 280 /10771 | f05f3f039ff3d9321e7ad63f111ec3dc53d9108cecd143b9f51d0b380f9868c0 |
| lua/test/map_leaves_mutation_contract_test.lua | 1–696 | 696 /32154 | c69f85d0dda35db90128cb25e4d18af1ebfae7bef882598db62a2fc914015c90 |
| lua/test/mcp_contract_lua_binding_test.lua | 1–9 | 9 /316 | 5851a4cf323f5d09f603144b1d23e9ec8f6205773e55c6fc7afb7a8844671dff |

Gap windows are 948–1135, 1136–1320 and1321–1462; logical windows are 1–180 and
181–280; map-leaves windows are 1–180, 181–365, 366–535 and536–696; the MCP header
has one window. All ten outputs were complete. Ordered range SHA-256 is
`1448f96de3281ed9707eeffa0a30b74e21193179ae801ce6cc9dbaddb0d718e5`.
The 99-file Lua baseline remains byte-identical to
`baeb984e36a94a15951cd23d4c52def5064cdaca`. Reading reaches 32/51 groups,
43,651 fragments /1,619,661 bytes and 59 complete files. The MCP-binding consumer
is partial: only its header, four imports, counter and failure-list declarations
are covered. Its prior116 assertion result is not run or recounted here.

# Gap completion

The emitted group finishes ten value and two typed-error cases. Native results
and exact generated plans seed expectations. Each host emits twelve modules,
manifest, runner and trace/output paths under managed TMPDIR, then invokes one
fresh child host that independently loads every module. Direct/traced values and
plans agree with native authority; traces contain enter/exit and logical source
identity. Unavailable-gap and cursor-regression errors retain execute_generated,
generated_execution_failed, source identity and the native typed marker. Child
stderr must be empty. The returned JSON envelope includes consumed trace bytes,
and the parent verifies workspace absence after cleanup. This group locks105.

Ten later portable-diagnostic fixtures lock code, stage, rule, source, line and
22 additional fields: 72 checks. They complete the metadata178 total established
across two source regions in [[lua-diagnostic-slot-gap-consumer-reading]].

The nine-role admission ledger executes native, ordinary reconstruction,
descriptor, generated plan, emitted source, lifecycle, recursion/rollback,
portable diagnostics and existing-primary roles exactly once. Its emitted role
separately loads a file in the parent host, executes it and verifies cleanup.
Lifecycle order remains LS/action/LE/IT/LX with candidate/tail availability;
nested capture and rollback preserve their distinct state. The existing primary
adapter checks exact stdout, empty stderr and status0. Role count/completion
locks30. Fresh full proof on each installed host is392, including185 prefix,
105 emitted,72 later metadata and30 admission assertions.

# Logical helpers

The consumer checks neutral contract identity and17 truthiness/10 helper rows,
then executes three source fixtures for values, eager effects and receiver/lazy
control behavior. Native and public SpecFile reconstruction agree with generated
direct/traced and loaded emitted direct/traced results and source identity.
The primary adapter produces the expected value with status0/empty stderr.
A staged final-codeblock argument is truthful without invoking its failing body.

Invalid arity compares typed native and reconstructed errors, diagnostic stage,
helper name, actual/expected arity and rule; absence of the operand-failure marker
proves rejection precedes operand effects. Generated/emitted direct/traced failures
retain generated stage/code/source identity/rule/family and the original arity
detail. The primary adapter retains its generic invocation-failed stderr and
status1. The complete consumer passes359 per host. Emitted code is actually loaded
and executed using loadstring/load in the current process; no fresh child is
claimed for this suite. The canonical July238 count remains dated evidence.

# Map-leaves mutation

The complete consumer projects four valid, fourteen invalid and five excluded
syntax cases into the dedicated typed receiver-mutation carrier, preserving exact
Unicode-scalar spans and ordinary continuation. Bang syntax remains specific to
map_leaves on a bare binding. The fixture enters a regex-free Top whose edge owns
the Done regex; a parent regex is not needed for that dispatch.

Ten success rows cover harray lexical/array index order, root-kind-only recursion,
opaque cross-kind leaves, detached callback path/value fields, replacement shapes
not revisited, unrelated effects, empty roots and commit before continuation.
Eight failure rows compare typed diagnostics and exact final bindings. The private
test seam is absent from the root facade; injected callback failure preserves its
caller object, rolls back only the receiver and leaves prior unrelated effects.
Guard release allows the next invocation to succeed. A continuation failure
preserves the already committed receiver; statement-position bang also commits.
Independent edits to initial, returned and committed aggregate branches prove
detachment. A same-spelling function parameter has distinct identity, and a staged
user-function body retains the typed bang node. The non-bang control stays pure.

The eighteen-row guarded_paths table covers append/nested writes, set/push,
array-end methods, binding-target pipelines, substr and regex substitution.
An additional set_key case checks the same before-operand rejection. Diagnostic
events stay empty when an active receiver write is rejected. Pure three-argument
substr remains unchanged. Six callback compositions and one continuation case
cover leaf/unrelated vivification, later callback failure, failing unrelated writes
with retained RHS effects, same-receiver precedence, independent shadow identity
and post-commit failure. All declared composition rows are accounted for.

Corrupt receiver source and corrupt chain kind fail typed state validation and
runtime construction; source corruption also fails emitter and generated-plan
boundaries. Public reconstruction/descriptors retain the dedicated node; actual
generated and loaded emitted execution plus the primary adapter return2.
The complete suite passes530 per host. Emitted source is loaded in the current
host, not an independent process. These fixtures do not close the separately
measured Rust/Perl mutation exceptions retained by the neutral Knowledge owner.

# Reconciliation and proof limits

Retrieved [[lua-logical-helper-execution]], [[logical-helper-neutral-contract]],
[[lua-runtime-array-tree-callbacks]], [[lua-runtime-harray-tree-callbacks]],
[[map-leaves-mutation-lua-runtime]], [[map-leaves-mutation-neutral-contract]],
[[lua-mcp-implementation-admission]] and
[[lua-generated-mcp-first-byte-range-reading]]. The gap owners read in child31
remain the canonical source and are not re-derived. The non-bang traversal cards
describe the separate pure operations correctly; they are not bang mutation rules.
Historical implementation counts and shared-rollout milestones remain dated.

All six native jobs complete successfully:392+359+530=1281 per host,2562 total.
Fresh logical governance passes17 truthiness/10 helper/3 effect cases,8 complete
rows,0 pending,19 public documents,14 stale-current denials and26 mutations.
Fresh mutation proof covers its exact syntax/behavior/composition cases and
rejects167 base+592 composition mutations. Its frozen neutral status is preserved;
external capability admission is not moved by this checker.

The previous child31 gap governance result is reused only after exact identity
checks on its JSON authority and checker; it is not counted as a fresh run.
All thirty-three repair roots, the PUC5.5 nil-error and public-selector baseline
failures, pending PUC5.4 verification, startup .3/.4/.5 gates and parked named
arguments remain unchanged. No full CI, PGEN/RGX build, dependency change, push,
new MCP execution or defect-free claim is made.

# Exact replay

```bash
bash tools/project_data_run.sh python3 - <<'LUA_GAP_LOGICAL_MAP_READING_32'
from pathlib import Path
p = Path('.linkedspec-data/scratch/lua132')
p.mkdir(parents=True, exist_ok=True)
(p / 'verify.py').write_text("from pathlib import Path\nimport hashlib, json, subprocess\n\np = Path('.linkedspec-data/scratch/lua132')\nfor row in json.loads((p / 'scope.json').read_text()):\n    data = b''.join(Path(row['path']).read_bytes().splitlines(keepends=True)[row['start'] - 1:row['end']])\n    assert len(data) == row['bytes']\n    assert hashlib.sha256(data).hexdigest() == row['sha256']\nfor host, runtime in [('puc', 'puc-lua'), ('luajit', 'luajit')]:\n    assert (p / f'gap-{host}.log').read_text() == f'Lua inter-match gap contract: OK (392 assertions; admitted; runtime={runtime})\\n'\n    assert (p / f'logical-{host}.log').read_text() == 'logical helper contract: 359 assertions passed\\n'\n    assert (p / f'map-{host}.log').read_text() == 'map-leaves mutation Lua dual-ABI admission: 530 assertions passed\\n'\nlogical = (p / 'neutral-logical.log').read_text()\nfor value in ['17 truthiness', '10 helper', '3 effect', '8 complete / 0 pending', '19 public documents', '14 forbidden current claims', '26 drift mutations']:\n    assert value in logical, value\nmutation = (p / 'neutral-map.log').read_text()\nfor value in ['4 valid syntax', '14 invalid syntax', '5 exclusions', '10 success', '8 pre-commit failures', '6 callback compositions', '1 continuation composition', '167 base + 592 composition mutations rejected']:\n    assert value in mutation, value\n# Previous neutral gap proof is dated evidence. Verify both its inputs against\n# the clean leaf that recorded that run instead of counting it as fresh proof.\nbase = '9109e20ab1255a85d879bfdcbd32da846a14eb0b'\nfor path, expected in [\n    ('capability_conformance/inter_match_gap_capture_contract.json', 'f5901338a6dac92a56b7dd4089fd7b865f210571089fe6311e83f98c85e4dfdf'),\n    ('tools/check_inter_match_gap_capture_contract.py', 'e1a2848fb28ccbffd32edf7d4ed2b0ffcac98ad725fa23f16e5204985aca95c1'),\n]:\n    data = Path(path).read_bytes()\n    assert data == subprocess.check_output(['git', 'show', base + ':' + path])\n    assert hashlib.sha256(data).hexdigest() == expected\nprint('PASS: exact source windows; gap392 + logical359 + map530 per installed host, 2562 assertions total; logical and mutation neutral proof; prior gap governance remains dated and input-identical')\n")
(p / 'scope.json').write_text('[\n  {\n    "path": "lua/test/inter_match_gap_capture_contract_test.lua",\n    "start": 948,\n    "end": 1462,\n    "bytes": 18697,\n    "sha256": "487a2e39b2ff4e465f742d575c360ae28d32f189b4f4b55a736ecb3255845c81"\n  },\n  {\n    "path": "lua/test/logical_helper_contract_test.lua",\n    "start": 1,\n    "end": 280,\n    "bytes": 10771,\n    "sha256": "f05f3f039ff3d9321e7ad63f111ec3dc53d9108cecd143b9f51d0b380f9868c0"\n  },\n  {\n    "path": "lua/test/map_leaves_mutation_contract_test.lua",\n    "start": 1,\n    "end": 696,\n    "bytes": 32154,\n    "sha256": "c69f85d0dda35db90128cb25e4d18af1ebfae7bef882598db62a2fc914015c90"\n  },\n  {\n    "path": "lua/test/mcp_contract_lua_binding_test.lua",\n    "start": 1,\n    "end": 9,\n    "bytes": 316,\n    "sha256": "5851a4cf323f5d09f603144b1d23e9ec8f6205773e55c6fc7afb7a8844671dff"\n  }\n]\n')
LUA_GAP_LOGICAL_MAP_READING_32
for host in puc luajit; do
  bash tools/run_lua_project_data.sh "$host" lua/test/inter_match_gap_capture_contract_test.lua > ".linkedspec-data/scratch/lua132/gap-$host.log" 2>&1 || exit
  bash tools/run_lua_project_data.sh "$host" lua/test/logical_helper_contract_test.lua > ".linkedspec-data/scratch/lua132/logical-$host.log" 2>&1 || exit
  bash tools/run_lua_project_data.sh "$host" lua/test/map_leaves_mutation_contract_test.lua > ".linkedspec-data/scratch/lua132/map-$host.log" 2>&1 || exit
done
bash tools/run_python_project_data.sh tools/check_logical_helper_contract.py > .linkedspec-data/scratch/lua132/neutral-logical.log 2>&1
bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py > .linkedspec-data/scratch/lua132/neutral-map.log 2>&1
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua132/verify.py
```

Related evidence: [[lua-diagnostic-slot-gap-consumer-reading]],
[[lua-startup-reading-coverage]].

# Candidate verification

Independent base-relative preservation passes for1,407 source, prior Knowledge,
decision, immutable-history and policy files. Of2,582 old task nodes,2,580 are
byte-identical; only this reading leaf and startup .3.6 change. No repair node is
added or edited. All90 book limitation headings, the parked authoring tree,
history preambles/suffixes and live-history pointer remain intact. Both embedded
replay payloads match their executed files. The independent full inventory/range
replay passes at32 completed groups.

Memory remains60 lines and phase/handoff checks pass. Shared history passes34
mutation controls and three surfaces/66 segments. Changes is438 lines /32,238 bytes
(within cap, pressure warning); notes is368 lines /30,038 bytes. Knowledge generation
produces1,118 cards and8,946 question keys. The book renders successfully; its
existing10,127,656-byte search-index warning remains owned by startup .41.9.
Whitespace checks pass; normal per-leaf hooks govern landing. An initial scratch
patch was rejected for a malformed added-line marker before any file changed;
the corrected saved script generated the reviewed synchronization candidate.
