---
id: lua-authority-compiled-reading-and-nested-step-gap
title: Lua authority completion confirms nested step inheritance gap and compiled-state snapshots
answers:
  - what did Lua startup reading group five cover
  - does Lua nested progressive dispatch enforce the parent remaining steps
  - which task owns Lua nested progressive step inheritance
  - how was Lua compiled state checked without native regex compilation
  - what does the Lua compiled spec prefix construct
  - which focused checks support Lua reading group five
date: 2026-09-12
status: exact group five read; existing startup .37.1 repair remains pending
tags: [lua, reading, progressive, compiler, budget, descriptor]
evidence: "LUA-STARTUP-READING.1.5 reads 1500 fragments /55335 bytes from 88da6dccce9a8cde785535d1ebe344a028af74ab. Selected authority 272 and 17 valid controls pass per installed runtime. A separate zero-parent-budget observation matches existing startup .37.1; no Lua source changes."
reverify:
  - "Run the exact managed replay below on both installed Lua hosts."
  - "Run the selected authority recipe in docs/knowledge/lua-parser-authority-reading-and-member-omission.md."
  - "Run LUA_READING_COVERAGE in docs/knowledge/lua-startup-reading-coverage.md."
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_executable_aggregate_selector_sources.py"
---

# Physical reading

Activation: `88da6dccce9a8cde785535d1ebe344a028af74ab`; frozen source baseline:
`baeb984e36a94a15951cd23d4c52def5064cdaca`. All nine exact windows were read
without truncation: authority 596–750, 751–905, 906–1060, 1061–1206; compiled
state 1–180, 181–360, 361–540, 541–720, 721–889.

| Path | Inclusive LF lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| `lua/src/linkedspec/bounded_child_parse_authority.lua` | 596–1206 | 21272 | `e9eed534f6cf325a4d3c7cc159c5a5d08eee3fc9b80115bd0cb84861cfca1a05` |
| `lua/src/linkedspec/compiled_spec.lua` | 1–889 | 34063 | `ad622c2d62df71bcc64ae408dc7987656e16940386675ff3d32f4dab0f23e4cf` |

The ordered-range digest is
`ac55758901370f425dfde54ee7124efb90a4c5472ec551136883b38c61d3dfc7`.
Cumulative: 5/51 groups, 6,945 fragments /283,881 bytes, eleven complete files
and a partial compiled-spec module. Its suffix belongs to .1.6. Incidental
API/fixture inspection grants no additional reading credit.

# Comprehension and canonical reconciliation

The authority suffix validates typed span identity and bounds, intersects entry
and caller settings, checks repeated parser/top/source chains and invocation
limits, and charges calls before callback execution. Callback source views map
local scalar offsets back to invocation positions and rebase typed spans and
diagnostics. Cancellation identity and deadline are checked before and after
execution. Callback view/chain state unwinds before failure propagation; failure
text is UTF-8 bounded. Result detachment requires finite acyclic typed JSON and
counts nodes independently. These mechanisms and their limits remain distinct.

The compiled-state prefix constructs typed metadata and rule identity, parses
payload ActionIR with registry-aware contracts, and retains ordered body slots,
captures/marks, action/blind edges and lifecycle/plain payloads. Same-line parent
regexes differ from regex-free edges that copy a target regex slot. It retains
last-definition ordering, validates child dependency indices, and builds neutral
dependency-pattern state. Serialized-state checks cover removed aggregate
selectors, nested writes and receiver mutation. Recursive-observation and
staged/progressive effect traversal begins here; closure validation continues
in the unread suffix. Compiling this state does not host-compile regexes.

Canonical homes were consulted first: [[lua-compiled-spec-state]],
[[lua-frontend-validation]], [[lua-aggregate-selector-compile-rejection]],
[[lua-progressive-span-dispatch-private-authority]],
[[dart-progressive-nested-authority-gap]] and
[[julia-progressive-authority-boundary-gaps]]. Dated historical inventory
counts remain historical; current helper inventory is 250.

# Confirmed numeric budget observation

ADR0080 requires parent remaining budget to propagate without reset or extension.
The local comparison uses two fixed callbacks, source `abc`, shared invocation
budget 10, callback cost 1 each, the same token/deadline, and unchanged caller
settings at both levels. With parent max_steps 1, the outer request reports zero
remaining steps but the inner callback runs. With max_steps 2, it reports one
and the inner callback runs as expected. Both cases charge the shared invocation
to 8 and record two calls. The zero case is a defect observation, not a passing
budget-conformance assertion.

Exact mechanism: `dispatch_nested` at authority lines 852–856 checks request
lifetime then calls `dispatch` with the shared invocation and supplied options.
Safe-point lines 759–760 compare cost with invocation remaining steps and the
new call's effective limit. Request lines 1166–1170 expose the narrower remaining
snapshot, but nested dispatch does not consume that snapshot as its parent limit.
This is the same numeric inheritance defect already owned for Dart and Julia by
`SESSION-STARTUP-READING.37.1`. Its existing cross-runtime decomposition and repair
acceptance now include this dated Lua result; no duplicate repair root is added.
Source-detail interpretation and other unmeasured nested settings are unchanged.

# Focused proof and limits

Installed hosts are PUC Lua 5.5.1 and LuaJIT 2.1.1788460057. Declared PUC 5.4
identity remains separately owned by Lua .2.2. The selected existing authority
consumer passes 272 checks per host; exactly its facade import and facade-absence
assertion are excluded, as retained in the group-four recipe. Its original
22130-byte SHA is `1c623f19e1b4503eaebe8c6e41ce80e13ec575cfb37b1a0943c5d3f55e703686`;
the selected 21986-byte SHA is
`375ab04e4409d13c1b2b899c9beeff2ae2dc912269621eea8e45047b4f8ce0ee`.

The replay below passes 17 valid controls per host: shared token/deadline/counters,
the one-step positive control, ordered compiled rules, child-pattern copying,
zero-based edge slot, exact four descriptor keys, and source snapshot isolation.
Together selected valid checks total 578. The separate zero-budget observation
is reported explicitly. An initial fixture omitted required total_calls and was
rejected as invalid configuration; adding total_calls=0 corrected the fixture.
No production source was changed to obtain these results.

The selector checker reports zero positives /20 classified and discovery selftest
PASS. Progressive governance passes 9/9 rollout legs, 116 contract mutations,
26 diagnostic rows, and public 6 documents /12 forbidden names /10 outward
checks /60 mutations. Neither selected consumer nor pure compiled-state replay
establishes facade/native loading, declared PUC 5.4, engine execution or full CI.
All seven Lua repair roots remain pending behind startup reading/book/policy.

# Exact local replay

The Lua payload SHA-256 is
`7cc49153d708e592d7d882dcf3d9a0acf708412c3a18cea9205aa306f0b6cc42`.
Run from repository root; all generated data uses the managed project volume.

```bash
bash tools/project_data_run.sh python3 - <<'LUA15_REPLAY'
from pathlib import Path
p = Path('.linkedspec-data/scratch/lua15/budget-compiled-proof.lua')
p.parent.mkdir(parents=True, exist_ok=True)
p.write_text(r'''package.path = "lua/src/?.lua;lua/src/?/init.lua;" .. package.path
local a = require("linkedspec.bounded_child_parse_authority")
local j = require("linkedspec.json")
local sp = require("linkedspec.spec_parser")
local cs = require("linkedspec.compiled_spec")
local checks = 0
local function check(value, label) assert(value, label); checks = checks + 1 end
local function ceilings(steps)
  return a.ceilings({source_detail="span", policy_modes=j.array({"deterministic"}),
    max_steps=steps, max_result_nodes=20, max_diagnostic_bytes=1024})
end
local function trial(steps)
  local token = a.cancellation_token()
  local remaining, calls = nil, 0
  local function options(id, first, last)
    return {origin="lua_reading_budget", parser_id=id, top_rule="Top",
      span=j.harray({source_id="input",start=first,["end"]=last,provenance="reading"}),
      caller_capabilities=j.array({"typed-source-location-v1"}),
      required_capabilities=j.array(), caller_ceilings=ceilings(steps),
      required_source_detail="none", child_token=token, cost=1, transaction_active=false}
  end
  local function entry(id, callback)
    return a.registry_entry({parser_id=id, compiled_authority=callback,
      fingerprint="sha256:"..string.rep("1",64), allowed_top_rules=j.array({"Top"}),
      capabilities=j.array({"typed-source-location-v1"}), ceilings=ceilings(steps)})
  end
  local registry = a.registry({entries=j.array({
    entry("outer-v1", function(request)
      remaining = a.request_remaining_steps(request)
      check(a.request_cancellation_token(request)==token,"same cancellation token")
      check(a.request_deadline_tick(request)==100,"same deadline")
      return a.dispatch_nested(request, options("inner-v1",1,2))
    end),
    entry("inner-v1", function() calls=calls+1; return "inner" end),
  })})
  local invocation = a.start_invocation(registry,{sources=j.harray({input="abc"}),
    source_id="input", cancellation_token=token, now=function() return 1 end,
    deadline_tick=100, remaining_steps=10, max_depth=4, total_calls=0, max_calls=8,
    active_chain=j.array()})
  local result = a.dispatch(invocation, options("outer-v1",0,3))
  check(a.remaining_steps(invocation)==8,"shared invocation charges both calls")
  check(a.total_calls(invocation)==2,"shared call count")
  assert(remaining==steps-1 and calls==1 and result=="inner")
  print("NESTED_BUDGET_OBSERVATION", "parent_limit="..steps,
    "parent_remaining="..remaining, "inner_calls="..calls,
    "invocation_remaining="..a.remaining_steps(invocation))
  if steps==2 then check(result=="inner","one-step positive control") end
end
print("RUNTIME",_VERSION,jit and jit.version or "PUC")
trial(1)
trial(2)
local source = [[Top::
 -> Child
 E { return(retv) }

Child:
 /x/
 E { return("child") }
]]
local spec = sp.parse_spec(source)
local compiled = cs.compile_spec(spec)
check(table.concat(compiled.definition_order,",")=="Top,Child","source definition order")
check(table.concat(compiled.compiled_rule_order,",")=="Top,Child","effective order")
check(compiled:rule("Top").regex_patterns[1]=="x","regex-free parent copies child pattern")
check(compiled:rule("Child").regex_patterns[1]=="x","child pattern retained")
check(compiled:rule("Top").action_edges[1].regex_index==0,"effective edge uses zero-based slot")
local descriptor = compiled:to_descriptor_json()
local keys={}; for key in pairs(descriptor) do keys[#keys+1]=key end; table.sort(keys)
check(table.concat(keys,",")=="dependency_regex_map,functions,meta,spec","exact descriptor keys")
local before = j.encode(descriptor)
spec.rules[2].body[1].kind.pattern = "changed"
check(compiled:rule("Child").regex_patterns[1]=="x","compiled state snapshots input")
check(j.encode(compiled:to_descriptor_json())==before,"descriptor survives input mutation")
print("VALID_CONTROLS",checks)
''')
LUA15_REPLAY
bash tools/project_data_run.sh lua .linkedspec-data/scratch/lua15/budget-compiled-proof.lua
bash tools/project_data_run.sh luajit .linkedspec-data/scratch/lua15/budget-compiled-proof.lua
```

# Continuity

The owning leaf syncs the book, roadmaps and all current frontiers to .1.6.
The change-history rollover, when required, preserves exact prior complete records
and immutable segments under the existing approved capacities. Independent source,
range and preservation proof, Knowledge, memory, histories, rendered book and normal
doctrine hooks govern landing. No source reading or runtime repair is inferred
from a successful documentation check.

Director communication preference: keep parser/compiler reports factual and local;
the reported UI notice has no established cause in this repository. Do not infer
platform diagnosis or reframe this work as a security exercise.

# Verified preservation and rollover

Independent reconstruction passes all 99 sources /51 groups /149 ranges and
matches the embedded replay bytes. It preserves 1,375 prior source/card/decision/
history files (the changed manifest is checked separately), 2,450 unchanged task
nodes, all 57 prior Known headings and the exact live-history query section.
Exactly three existing nodes receive current evidence; no new repair node is added.
The book now has 58 Known headings. The Lua metadata's stale 1/51 current label
is corrected to the same 5/51 as its physical coverage and frontier.

The existing rollover archives clean activation source lines 244–454 as
`docs/history/changes/segment-4978-f54190d7a909.md`: 211 lines /12,694 bytes,
SHA `f54190d7a9094e9c473472499f20e0b2b69053f08f1938aa4cb7447088a6acef`.
All previous manifest rows/segments remain exact; only segment_count and the new
leading segment row change. As in [[julia-reading-history-capacity-admission]],
one terminal separator LF is removed only from the live root and restored in the
reconstruction below. No archived byte or policy control changes.

Root is 249 lines /15,578 bytes; manifest 34 lines /19,343 bytes; collection uses
35 of 38 admitted files. Ordered archived query is 49,131 lines /3,549,185 bytes,
SHA `8b1cd7081dbbb3cceedcdc79385f212241113d9285bd50414bafb0d9541b0449`.
Notes remain 396 lines. Knowledge is 1,091 facts /8,773 questions; memory is
60 lines. Memory, both histories, diff hygiene and rendered book pass. The book's
10,032,580-byte search-index warning retains existing startup .41.9 ownership.
Normal doctrine hooks govern the exact resulting candidate at landing.

This dated check selects the completed leaf from Git when available; use the
managed project wrapper from repository root. Later archives retain this query
as a suffix.

```python
from pathlib import Path
import subprocess, json, re, hashlib
BASE='88da6dccce9a8cde785535d1ebe344a028af74ab'
SUBJECT='LUA-STARTUP-READING.1.5 - read authority and compiled state and record nested step gap'
def git(*args): return subprocess.check_output(['git',*args])
commits=[line.split(' ',1)[0] for line in git('log','--format=%H %s',
 '--fixed-strings','--grep='+SUBJECT).decode().splitlines()
 if line.split(' ',1)[1]==SUBJECT]
assert len(commits)<=1
SNAP=commits[0] if commits else None
if SNAP: assert git('rev-parse',SNAP+'^').decode().strip()==BASE
def old(p): return git('show',BASE+':'+p)
def snap(p): return git('show',SNAP+':'+p) if SNAP else Path(p).read_bytes()
mp='docs/history/changes/manifest.jsonl'
a=old(mp).splitlines(keepends=True); b=snap(mp).splitlines(keepends=True)
assert b[2:]==a[1:]
x,y=json.loads(a[0]),json.loads(b[0])
assert y.pop('segment_count')==x.pop('segment_count')+1 and x==y
r=json.loads(b[1]); source=old('CHANGES.md'); part=snap(r['target_path'])
assert r['source_commit']==BASE
assert r['source_blob']==git('rev-parse',BASE+':CHANGES.md').decode().strip()
assert (r['source_start_line'],r['source_end_line'])==(244,454)
assert part==b''.join(source.splitlines(keepends=True)[243:454])
assert (len(part.splitlines()),len(part),hashlib.sha256(part).hexdigest())==(211,12694,r['sha256'])
for row in a[1:]:
 p=json.loads(row)['target_path']; assert snap(p)==old(p)==Path(p).read_bytes()
root=snap('CHANGES.md'); marks=list(re.finditer(br'^## ',root,re.M))
assert root[:marks[0].start()]+root[marks[1].start():]+b'\n'+part==source
query=part+b''.join(old(json.loads(row)['target_path']) for row in a[1:])
assert (len(query.splitlines()),len(query),hashlib.sha256(query).hexdigest())==(49131,3549185,
 '8b1cd7081dbbb3cceedcdc79385f212241113d9285bd50414bafb0d9541b0449')
now=subprocess.check_output(['perl','tools/read_document_history.pl','--surface','change_history','--all'])
assert now.endswith(query) and (SNAP is not None or now==query)
print('PASS exact Lua .1.5 rollover, prior records and ordered query')
```
