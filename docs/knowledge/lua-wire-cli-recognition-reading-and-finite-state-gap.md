---
id: lua-wire-cli-recognition-reading-and-finite-state-gap
title: Lua wire CLI and recognition reading identifies non-finite private state admission
answers:
  - what did Lua startup reading group fifteen cover
  - can private Lua recognition frame states contain infinity
  - why do Lua recognition snapshots fail JSON encoding after accepting coordinates
  - does the private Lua recognition progress check accept an infinite end offset
  - what current Lua primary CLI process proof ran during source reading
  - which task owns finite Lua recognition coordinates and progress repair
date: 2026-09-12
status: exact group fifteen read; finite private validation repair .2.12 pending
tags: [lua, reading, cli, mcp, recognition, transaction, numeric, validation]
evidence: "LUA-STARTUP-READING.1.15 reads 1500 fragments /51908 bytes from 400e3db4418e04fe6514f2c34a083648244acaf5. Both installed hosts pass 246 recognition assertions and 30 valid boundary controls each; 552 total. Nine private non-finite observations per host gain .2.12 repair/proof. Default-environment CLI conformance passes 66 cases per host, separately counted. Cumulative reading is 15/51, 18151 fragments and 768251 bytes."
reverify:
  - "Run the exact two managed replays below on both hosts."
  - "bash tools/run_lua_project_data.sh puc lua/test/recognition_transaction_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/recognition_transaction_contract_test.lua"
  - "bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py"
  - "Run LUA_READING_COVERAGE in docs/knowledge/lua-startup-reading-coverage.md."
---

# Exact reading

Activation is `400e3db4418e04fe6514f2c34a083648244acaf5`; frozen source baseline
remains `baeb984e36a94a15951cd23d4c52def5064cdaca`. All coordinates are inclusive
LF lines under `lua/src/linkedspec`. Group fifteen covers 1,500 fragments /51,908
bytes with ordered-range SHA-256
`8473f4c5be44a6cded592f0ab42146a777df62fd365b703324c8df741a8fce93`.

| File | Lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| mcp_wire.lua | 233–511 | 9733 | bd05047639fd472842fc55bb6aa10aa0525890a4d03baa3e798a14063c395ba5 |
| primary_cli.lua | 1–381 | 14146 | b1be8d1003d5697c121d959df438d8dab640ba99a0fbaf6446310f8b67b93fae |
| recognition_transaction.lua | 1–699 | 23471 | 68b3394eb866584ae886cdba833340ab8f823c618f931f20ee61b1811d8616fd |
| recognition_transaction_runtime.lua | 1–141 | 4558 | 2523359dc462466c535a88dff5e1f304ba3b07a1eae34d5b815d48836c571890 |

All eleven windows were consumed completely, without truncation:

- `mcp_wire.lua`: 233–382, 383–511.
- `primary_cli.lua`: 1–150, 151–300, 301–381.
- `recognition_transaction.lua`: 1–150, 151–300, 301–450, 451–600, 601–699.
- `recognition_transaction_runtime.lua`: 1–141.

Wire, primary CLI and transaction state module reading are complete. The adapter
is read only through line 141; its suffix remains .1.16-owned. Cumulative coverage
is 15/51, 18,151 fragments /768,251 bytes, with 24 complete files and a partial
transaction runtime adapter. All 99 source files remain baseline-identical.

# Comprehension and canonical reconciliation

The wire suffix completes its explicit object/list scanner, rejects duplicate
decoded keys and trailing content, and separates number-token syntax from Lua's
numeric representation. Raw ID bounds use decimal-string comparison; fractional
syntax at governed integer paths is invalidated before schema dispatch. Frame
processing validates the decoded request and emitted response. Bounded byte reads
retain one possible CR delimiter byte, handle overlong frames without retaining
their full content, and process final EOF content. Writes and flushes are checked;
EOF clears server state, while I/O failure attempts cleanup and fixed optional
logging. The complete stdio consumer's most recent 247 assertions per host belong
to .1.14; this leaf does not relabel that run as fresh evidence.

The primary CLI accepts exact source/input selectors, rejects positionals and
removed global parse-mode syntax, and validates portable trace settings. Compilation
precedes deferred input-file loading. Named/path requests use the loader; inline
requests use staged function parsing and compilation. Execution uses the ordinary
engine and serializes the result through typed JSON. Trace records use deterministic
phase order, byte counts, escaped fields and the selected route/mirror/stdout sink.
Relative inputs use the caller/process cwd; optional repository roots provide named
spec search. These runtime-derived paths are separate from persisted project paths.

The transaction module separates private identities, invocation stacks, frame
state, snapshots and linear tokens. Cross-source/invocation and invalid generation
operations restore staged state before invalidation; token reuse, nested checkpoint,
multiple attempts, missing terminals and escapes have explicit diagnostics. Attempt
presence and payload remain separate, preserving a successful false value. Effects
propagate to a fixed point through rule calls, and progress evaluates cursor movement
independently of marks or other state. The numeric predicate has the gap below.

The adapter prefix copies gap/entry-slot state, synchronizes live cursor/boundary
and invocation-local mark buckets, creates its private context and begins entering
an invocation. It clamps restored cursors to input bounds and reconstructs matching
registers. This scope ends in the failure cleanup branch; later adapter behavior
receives no source credit from running its full consumer.

Canonical retrieval preceded diagnosis: [[lua-primary-cli-adapter]],
[[lua-primary-cli-recurring-admission]], [[neutral-cli-fixture-runner]],
[[lua-recognition-transaction-private-authority]] and
[[lua-recognition-transaction-integration]]. Older 61-case CLI /243-assertion
transaction counts remain dated; current results are below. The transaction header
still describes future integration at lines 3–4 despite current adapter consumption.
Existing stale-guidance repair .2.1 gains that exact source-comment correction;
no source comment or older fact card is changed during reading.

# Non-finite private state and progress admission

A normal parser cursor is a byte position: for input "abc", positions run from 0
through 3. An infinite cursor here means the stored numeric field contains Lua
math.huge, not a finite position. The observation concerns invalid state admission.

Both installed hosts admit positive and negative infinity in each frame_state
cursor, boundary and initial named-mark field. All six constructed states enter
an invocation and project snapshots containing the original non-finite value;
json.encode then rejects those six snapshots. The mark setter independently accepts
and returns both infinities. The private progress helper accepts start 0 /end
infinity for accepted repetition. These are nine observations per host, counted
separately from passing controls.

The shared predicate at recognition_transaction.lua 63–65 checks only number type
and equality with math.floor; both infinities satisfy it. Constructor use is at
301–302 and copied marks at 119; write_mark uses it at 420, and progress_offset
at 617–620 forwards the accepted infinity to the comparison at 628. Finite zero,
positive and negative integer state controls pass, while false, true, string,
fraction and NaN constructor values reject. Finite forward progress, rejected zero
repetition progress and allowed one-shot zero width also retain expected behavior.

Pending `.2.12.1` owns finite private coordinate/mark/progress validation and
`.2.12.2` owns independent rejection, atomicity, snapshot encoding and carrier
proof. Invalid infinite progress operands must not become advancing defaults.
Existing finite negative private coordinates are controls; no new source-bound or
nonnegative policy is inferred. This is not an observation of an ordinary `.spec`
producing infinity, a public parser loop, or parser nontermination. Reachability
and adapter-produced domains require their own census before stronger claims.

# Fresh focused proof

- The admitted recognition consumer passes 246 assertions per host, and the new
  private boundary probe passes 30 valid controls per host: 552 assertions total.
  Nine defect observations per host are additional observations, not passing tests.
- The unchanged CLI runner passes all 66 manifest cases on each installed host
  with POSIXLY_CORRECT explicitly unset: 132 process cases, counted separately.
  Each managed host build supplies its native module path to child CLI processes;
  the runner creates and cleans repository-local case workspaces.
- Neutral recognition validation passes 138 ActionIR rows (134 current +4 dedicated),
  250 call rows, 8 positive/17 negative token cases, 6 effect graphs, 6 mark cases,
  8 progress cases and 58 mutations. It also reports the existing public sequence
  45, capability-guide 18 and Lua private-authority/integration/admission 22/19/22
  mutation checks. Governance rollout 9/9 is not fresh execution of nine routes.
- All six managed native/CLI executions complete and their results/cleanup are
  consumed. No POSIX CLI leg, full Lua gate, complete corpus, declared PUC5.4 or
  full CI result is claimed. Earlier public-selector failure stays .28.7-owned.
- Twelve Lua repair roots now remain open, alongside startup .37.1/.28.7 and all
  startup prerequisites. Approved named-argument direction remains parked under
  PARSER-AUTHORING-APIS.4; this leaf does not activate or alter that direction.

# Exact replay payloads

The finite-state probe is 3,136 bytes with SHA-256
`808c239802901cae6e8127a19e4ff0c12cd6ce7bba6680e8e59b31c455e4f2c9`.
The CLI launcher is 648 bytes with SHA-256
`08c68c2db037ee2876e8d020baf25f05e5269d4eb1b0133e32d89370b8def558`.
The latter derives the current interpreter from arg[-1]; it does not persist a
machine-specific executable path or build any PGEN/RGX dependency.

```bash
bash tools/project_data_run.sh python3 - <<'LUA_RECOGNITION_READING_15'
from pathlib import Path
root = Path('.linkedspec-data/scratch/lua115')
root.mkdir(parents=True, exist_ok=True)
(root / 'transaction-finite-proof.lua').write_text('local json = require("linkedspec.json")\nlocal source = require("linkedspec.source_location")\nlocal tx = require("linkedspec.recognition_transaction")\nlocal controls = 0\nlocal observations = 0\nlocal function check(value, label)\n  assert(value, label)\n  controls = controls + 1\nend\nlocal function authority()\n  return tx.authority({\n    source_authority = source.source_authority({ sources = json.harray({ input = "abc" }) }),\n    source_identity = "input",\n  })\nend\nlocal function state(field, value)\n  local options = { cursor = 0, boundary = nil, marks = {} }\n  if field == "mark" then options.marks.point = value else options[field] = value end\n  return tx.frame_state(options)\nend\nfor _, field in ipairs({ "cursor", "boundary", "mark" }) do\n  for _, value in ipairs({ 0, 1, -1 }) do\n    local item = state(field, value)\n    check(tx.node_type(item) == "RecognitionFrameState", "finite integer state control")\n  end\n  for _, value in ipairs({ false, true, "1", 1.5, 0 / 0 }) do\n    check(not pcall(state, field, value), "noninteger state rejected")\n  end\n  for _, value in ipairs({ math.huge, -math.huge }) do\n    local item = state(field, value)\n    local owner = authority()\n    local frame = tx.enter_invocation(owner, { rule = "Top", origin = "probe", state = item })\n    local record = tx.to_json(tx.frame_snapshot(owner, frame))\n    local stored = field == "mark" and record.marks.point or record[field]\n    assert(stored == value, "expected existing infinite state admission")\n    local ok, message = pcall(json.encode, record)\n    assert(not ok and tostring(message):find("non-finite", 1, true), "expected non-finite JSON failure")\n    observations = observations + 1\n    io.write("OBSERVED ", field, " accepts ", tostring(value), "; snapshot JSON rejects it\\n")\n    tx.leave_invocation(owner, frame)\n  end\nend\nlocal owner = authority()\nlocal frame = tx.enter_invocation(owner, { rule = "Top", origin = "probe", state = state("cursor", 0) })\nfor _, value in ipairs({ 0, 2, -1 }) do\n  check(tx.write_mark(owner, frame, "point", value) == value, "finite mark write")\nend\nfor _, value in ipairs({ math.huge, -math.huge }) do\n  assert(tx.write_mark(owner, frame, "point", value) == value)\n  assert(tx.read_mark(owner, frame, "point") == value)\n  observations = observations + 1\n  io.write("OBSERVED mark setter accepts ", tostring(value), "\\n")\nend\ntx.leave_invocation(owner, frame)\ncheck(pcall(tx.validate_progress, owner, { context = "accepted_repetition_iteration", start = 0, ["end"] = 1 }), "forward finite progress")\ncheck(not pcall(tx.validate_progress, owner, { context = "accepted_repetition_iteration", start = 0, ["end"] = 0 }), "zero finite progress rejected")\ncheck(pcall(tx.validate_progress, owner, { context = "one_shot", start = 0, ["end"] = 0 }), "one shot zero width")\nassert(pcall(tx.validate_progress, owner, { context = "accepted_repetition_iteration", start = 0, ["end"] = math.huge }))\nobservations = observations + 1\nio.write("OBSERVED private progress accepts infinite end offset\\n")\nio.write("PASS ", controls, " valid controls; ", observations, " private non-finite observations counted separately\\n")\n')
(root / 'primary-cli-proof.lua').write_text('local executable = assert(arg[-1], "Lua executable identity is required")\nlocal function quote(value)\n  return "\'" .. value:gsub("\'", "\'\\\\\'\'") .. "\'"\nend\nlocal command = "env -u POSIXLY_CORRECT perl tools/run_cli_conformance.pl " ..\n  "--display-command \'lua/bin/linkedspec-lua\' -- " .. quote(executable) ..\n  " \'{{REPO_ROOT}}/lua/bin/linkedspec-lua\'"\nlocal first, _, third = os.execute(command)\nlocal success = type(first) == "number" and first == 0 or\n  first == true and (third == nil or third == 0)\nassert(success, "default-environment primary CLI conformance failed")\nio.write("PASS default-environment Lua primary CLI process conformance\\n")\n')
LUA_RECOGNITION_READING_15
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua115/transaction-finite-proof.lua
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua115/transaction-finite-proof.lua
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua115/primary-cli-proof.lua
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua115/primary-cli-proof.lua
```

# Preservation and engineering-history rollover

Independent completed-node sums confirm 18,151 fragments /768,251 bytes. Canonical
coverage replay retains all 99 baseline sources and the original inventory/range/
group digests. Both embedded replay payloads match the executed scratch bytes.
The preservation audit retains 1,388 prior source/card/decision/history/policy files
byte-for-byte, excluding the owned manifest update, and 2,474 of 2,479 old task
nodes. Only .1.15, .2, .2.1, .2.1.1 and startup .3.6 change; exactly .2.12 and its
two pending children are added. The approved named-argument tree remains byte-exact.
All 63 prior Known book headings remain, with one additional recognition limitation.
Changes retains its exact prior suffix and live status its exact History section.

Engineering notes reached 466 lines and required the existing rollover workflow.
It archives clean activation lines 244–459, 216 lines /11,955 bytes, as
`docs/history/development-notes/segment-4977-4ba5996b63aa.md`, SHA-256
`4ba5996b63aa2691ddd791a6aef43273494fc830c04de9a1b6d8f77c024795f1`.
The retained prior root plus this segment reconstruct the activation root exactly
after restoring one terminal LF removed from the generated hot shard to satisfy
git diff --check. Every prior segment and manifest segment row is
unchanged; only the manifest header count and new row change. The initial audit
incorrectly required the count header to be byte-identical; correcting that audit
expectation establishes the precise header-only count update without changing data.
The collection now uses 30 files; its manifest has 30 lines /18,066 bytes, within
ADR0118. The normalized root is 249 lines /17,404 bytes. The indexed `--all` query succeeds:
26,438 lines /2,795,716 bytes, SHA-256 `d862746588be9ab3fc9a92ddfdeda8a2eb7f782784499f6ca6ee2210d01d8953`.

Reverify the source slice through the manifest's segment command; compare it to
`git show 400e3db4418e04fe6514f2c34a083648244acaf5:DEVELOPMENT_NOTES.md`
lines 244–459. Run both COMMIT.md history checks and the indexed engineering-notes
`--all` query for full reconstruction. Memory, Knowledge, rendered book and normal
doctrine hooks govern landing; all ADR0118 controls remain unchanged.

Both history pressure checks and rendered mdBook pass. The existing large search
index warning remains owned by startup .41.9; it does not imply a new runtime
defect. Knowledge generation passes with 1,101 facts /8,830 question keys; explicit memory
validation passes at 60 lines. All normal hooks remain required.
