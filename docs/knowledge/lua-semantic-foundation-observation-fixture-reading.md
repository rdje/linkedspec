---
id: lua-semantic-foundation-observation-fixture-reading
title: Lua semantic foundations pass while six missing-field observation fixtures contain sentinel tables
answers:
  - "what exact Lua source did startup reading child 46 cover"
  - "do Lua missing-field observation fixtures actually omit the fields"
  - "which task fixes the Lua malformed event NIL sentinel coverage gap"
  - "does Lua reject genuinely absent observation fields"
  - "what proves Lua observation derivation materializes exactly once"
  - "what source-coordinate and static graph tests pass in Lua reading child 46"
  - "which Lua native observation failure remains on installed PUC5.5"
  - "how did Lua reading child 46 preserve the engineering notes rollover"
date: 2026-09-13
status: exact reading and evidence verification complete; fixture repair .2.34 and known PUC nil-error failure remain open
tags: [lua, semantic-introspection, observation, source-map, test-coverage, startup, document-history]
evidence: "LUA-STARTUP-READING.1.46 activates from 47bea50a5f05756eac9d117662aedd649e483c61. Eleven complete windows read five ranges, 1500 fragments /62032 bytes. Twelve native jobs finish: projection 269/source 382/graph 64 pass per host; native LuaJIT 121 passes and PUC5.5 remains FAIL 120/121 exit 1. Two helper prefixes load; 48 observations establish six misleading missing-field fixtures and correct real-absence rejection. Notes rollover is byte-exact."
reverify: "Run LUA_SEMANTIC_FIXTURE_READING_46 and the managed commands below. Keep native PUC exit 1 and its exact nil-identity diagnostic. The fixture probe copies the original helper and adds independently absent-field controls. History verification retains clean-HEAD provenance and exact archived bytes."
---

# Exact source coverage

| Repository source | Inclusive lines | Fragments / bytes | Raw SHA-256 |
| --- | --- | --- | --- |
| lua/test/semantic_index_runtime_observation_native_test.lua | 258–548 | 291 /12078 | 0181e1d3daf434886aea1d6181774517d908e73e1d184f06d4f5a9bd49205694 |
| lua/test/semantic_index_runtime_projection_test.lua | 1–472 | 472 /18678 | df7a3a31cb6c3355c07cee80423c4c1403635bf2f378d81769878cfb164bd018 |
| lua/test/semantic_index_source_foundation_test.lua | 1–438 | 438 /19816 | c30a8a0dac24b535cdba5ab7cae89aa0b324150a8a0c8bbf77726936949d2e17 |
| lua/test/semantic_index_static_graph_test.lua | 1–226 | 226 /9299 | 5ffae9909fc65c99612f10987b285a95ff046e991a4d108119458499423a9189 |
| lua/test/semantic_index_static_remaining_test.lua | 1–73 | 73 /2161 | dffb60b82839ac526d73a66789a23f97e502e2647b2407c64054f9428ec8737c |

Complete credited windows are native observation 258–405,406–548; runtime
projection 1–180,181–340,341–472; source foundation 1–145,146–290,291–438;
static graph 1–145,146–226; remaining static 1–73. Ordered range SHA-256 is
`d9b9711ece56ff8f978153b81464f3d1701cd3a84adf8609e692e46bead50002`.
All 99 Lua sources remain baseline-identical to
`baeb984e36a94a15951cd23d4c52def5064cdaca`. Reading reaches 46/51 groups,
64,540 fragments /2,463,688 bytes and 87 complete files. Native observation,
runtime projection, source foundation and static graph tests are fully read.
Remaining-static reading ends inside runtime_static_expected; only the complete
helper prefix 1–63 is loaded, with no original behavior assertions executed.

# Native observation completion

The alias-route continuation compares values, byte/scalar cursors and canonical
events across the admitted convenience routes. Unicode input distinguishes byte
position 3 from scalar position 2, preserving the executing/target rule label and
UTF-8 input digest. Normal no-match emits a successful final result event. Invalid
sink type and engine-level configuration reject; a missing entry emits no events.
Runtime failure and exit 7 preserve an accepted slot but omit the final result.

No-sink instrumentation replaces event constructors, hashing and byte-to-scalar
conversion with throwing sentinels. The fixture still reaches its typed exit 19,
proving those observation operations are avoided on that path; originals are
restored. String/table/runtime-error callback identity and first-event stopping
pass. Nil failure after the final event repeats PUC5.5's known host change:
expected nil, got <no error object>. The unchanged native footer reports 120/121
and exit 1; LuaJIT passes 121/121. Existing .2.2 owns restoration of matching declared
5.4 runtime/header proof; the expectation remains unchanged.

Healthy traced callback failure closes scopes with its semantic-sink marker and
preserves table identity. Observed and baseline results, trace bytes/events and
diagnostics agree; diagnostic and semantic channels retain distinct event counts.
Reentrant runs keep separate canonical event lists. Generated-plan execution
propagates the same events; emitter source markers and emitted-text omissions keep
observation adaptation outside serialized v2/format 2 data. Complete emitted-route
execution remains separately established in child 45. Arbitrary-writer .2.30 stays
open; healthy writers do not establish all-writer cleanup guarantees.

# Immutable runtime derivation

The complete 269-assertion projection suite passes per host. A static base has no
runtime query rows and remains static after derivation. The fresh protected index
deep-equals the entire neutral runtime projection and preserves the twentieth
typed/raw response digest
`36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`.
Three observed_as relations retain exact slot/rule evidence ids, and derived
capabilities alone report execution observation.

Changing the caller event sequence, detached event JSON, response JSON or private
materialization cannot alter either index. Repeated and interleaved derivations
remain exact. Forty-one malformed input rows check protected typed rejection,
stage, code and a nonempty message. They cover sequence shape, foreign kinds,
labels/UTF-8, finite integral positions/indexes, slot/result fields, final ordering
and digest spelling. Unrelated selecting topology, already-observed bases and
failed-compilation bases also reject. Six rows have the coverage defect below.

Replacing static_projection.materialize with a counting wrapper and sha256.hex
with a throwing sentinel measures exactly one materialization and no input hash
during valid derivation. Originals are restored. This is dynamic instrumentation;
the later index call-site count and forbidden dependency/token checks remain
source scans. Public root exports omit the private derivation/projector/event
construction seams. Shared explanation-budget and raw-false owners stay open.

# Confirmed fixture gap and correct runtime controls

At runtime-projection-test line 264, `value == NIL and nil or value` never removes
the field: when the condition succeeds, nil is falsey, so the final `or value`
returns the original sentinel table. The exact helper is lines 240–267. Six cases
at 296,305,326,338,366,369 therefore retain a table instead of absent contract_id,
rule_label, target_rule, regex_index, result status or input_identity.

Knowledge Map searches found no prior card for this fixture issue. The probe
copies the exact helper, uses the private event constructor and checks that each
original event field is the identical NIL table. It then copies all eight event
fields and explicitly deletes the selected key, verifying that the new event
field is absent. Original-table and actual-absence variants both reject at
execution_observation with semantic_index_invalid_observation. Four observations
per field give 24 per host, 48 total. Exact logs and exit 0 prove this on both hosts.
No new runtime acceptance defect is inferred.

The passing 269 suite proves rejection of its actual table-valued inputs; its six
missing-field labels overstate that coverage. New .2.34/.1/.2 owns explicit test
field removal, distinct missing/table/false/null preconditions and mutation proof
that catches restoration of the fallthrough expression. Production and original
tests remain unchanged until startup .3/.4/.5 and complete reading permit repair.
The first unexecuted scratch draft assumed an event method; source/API inspection
corrected it to direct protected field access before either host ran the probe.

# Strict source foundation

The source suite passes 382 assertions per host. Import-time package.loaded checks
keep seven compiler/loader/emitter/interpreter/trace dependencies absent. The module
contains seven require sites: immediate JSON/SHA/Unicode plus four lazy semantic
owners. Source scans exclude file/environment/loading and optional bit libraries.

Exact SHA vectors cover empty, abc, repeated-a 55/56/64/1000, the neutral graph and
privacy fixtures, and mixed Unicode. Caller options and returned identity JSON
are detached. Ordered duplicate lookup retains byte positions 10/47/119/124 and
exhaustion. Unicode mapping distinguishes bytes from scalars, one-based columns,
LF line advance, ordinary CR, combining scalars, supplementary characters and
empty end spans. Four source ceilings retain exact identity/digest/span/excerpt
admission and null JSON representation.

Ten invalid numeric ranges reject, including Boolean, fractional, NaN and infinity;
mid-scalar endpoints retain exact offending fields. Needle type/empty/UTF-8 errors,
seven invalid source byte sequences with offsets, four invalid source types and
eighteen option errors retain typed stages/codes and option fields. Public source
coordinate rejection does not close the separate private infinite-cursor .2.12.

Four public value kinds expose protected empty tables and detached error fields.
Stable strings redact private identities. During construction, active replacements
of io.open/getenv/time/clock throw if used, and an authored fail action must remain
unexecuted; the constructor succeeds and originals are restored. Existing
diagnostic-null .2.14 and source-correlation owners remain open.

# Exact static graph and bounded prefix

The unchanged graph suite passes 64 assertions per host: 12 records, 14 relations
and seven source references, with full materialized equality and plain JSON.
Two duplicate Child slots retain separate ids; Top parent matchers are excluded
from slot rows. Indexed edge source forms, string shapes, lifecycle array-of-string
shape and exact whole-member excerpt/span/digest remain correct for this fixture.
Relation counts are declares 2/contains 6/dispatches 2/selects 2/explained_by 2.

Mutating record/source/relation copies cannot alter a fresh materialization.
Protected empty indexes and absent direct materializer/record exports remain;
this does not imply the public query API is absent. Default neutral mode is
non-repeating with null bounds. Forbidden-import/token checks are source scans.
Previously reported .2.16/.2.17/.2.18, startup .67.2 and conditional explanation
.2.19 limitations remain separate from this fixture's equality proof.

The remaining-static prefix defines helpers only. Loading exact lines 1–63 on each
host checks a complete syntax boundary; no later projection target, mutation or
runtime assertion receives fresh credit. Those tests belong to the next leaf.

# Exact totals and Knowledge reconciliation

All twelve native jobs are consumed. The four complete suites total
(121+269+382+64)×2=1,672 assertions, with 1,671 passes and the known PUC nil failure.
Two helper loads and 48 diagnostic observations are separate. Evidence verification
checks all 12 exact logs/statuses, all five source ranges and the unchanged helper.
No full CI, primary/cross-backend matrix, PGEN/RGX build, push or unavailable
supported-PUC 5.4 certification is performed. Native-error exclusions stay intact.

Read [[lua-semantic-source-foundation]], [[lua-semantic-static-projection-plan]]
and [[lua-semantic-runtime-observation-derivation]], and reuse fully read child 45
direct/generated observation and child 17/18 defect facts. Existing .2.1 owns
source 378/current 382/import-count/next-graph wording and the static plan's historical
next-calls pointer, preserving original 378/379/64 proof. Its derivation coverage
qualification points to .2.34. Existing .2.2 gains fresh exact native 120/121 versus
121/121 evidence. All 34 repair roots and parked named arguments remain open.

# Required notes rollover

The leaf owns the rollover before changing history. Its seven-line record reaches
466/512 lines; the pressure check requires rollover. The existing tool archives
only clean-HEAD lines 244–459 from 47bea50a5, source blob
`4e0de58fcfa92d77889036d01460b7e69321f6e3`, as
`docs/history/development-notes/segment-4976-8f23f4b6bde6.md`.
The immutable segment is 216 lines /14,514 bytes, SHA-256
`8f23f4b6bde6b9b9796b1b35403a37aa7ece9bc3747ece75b8f9ed397ced9366`.

The tool leaves 250 lines /26,612 bytes; whitespace validation identifies its new
blank EOF line. Normalizing one terminal LF leaves 249 lines /26,611 bytes. Root
plus one boundary LF plus the new segment reproduces the pre-rollover root exactly.
All prior manifest rows and segments remain byte-exact. The collection now has 32
files including hot root, with a 31-line /18,678-byte manifest, within ADR0118.
The prior pointer's 30-file wording counted only the archive directory; the new
current count explicitly includes the hot root, as the pressure registry does.

Archive --all is segment-only: new segment plus the exact prior archive gives
26,654 lines /2,810,230 bytes, SHA-256
`b7a9ee168ccc682f07f7854258e813a0a6e0bf214bc1c66f0a9bbc93f1a665f1`.
Hot root plus its boundary LF plus archive preserves the combined SHA-256
`5c1bc075b2a0955debeb3731836e9b1a25f6d2a1b84a87d22ff45498ecec986a`.
The independent history script verifies exact clean-HEAD source provenance,
segment retrieval, preserved prior rows and complete reconstructed bytes.

# Exact replay

```bash
bash tools/project_data_run.sh python3 - <<'LUA_SEMANTIC_FIXTURE_READING_46'
from pathlib import Path
p=Path('.linkedspec-data/scratch/lua146')
p.mkdir(parents=True, exist_ok=True)
(p / 'select-tests.py').write_text('from pathlib import Path\n\np=Path(\'.linkedspec-data/scratch/lua146\')\nlines=Path(\'lua/test/semantic_index_static_remaining_test.lua\').read_text().splitlines(keepends=True)\nassert lines[62].strip() == \'end\' and lines[64].startswith(\'local function runtime_static_expected\')\n(p/\'static-helper-prefix.lua\').write_text(\'\'.join(lines[:63]) + \'\\nassert(assertions == 0 and #failures == 0)\\nprint("remaining-static helper prefix: loads; no original behavior assertions executed")\\n\')\nprint(\'Selected unchanged complete static helper prefix 1-63; partial function and all later behavior fixtures excluded\')\n')
(p / 'verify.py').write_text("from pathlib import Path\nimport hashlib, json\n\np=Path('.linkedspec-data/scratch/lua146')\nfor row in json.loads((p/'scope.json').read_text()):\n    data=b''.join(Path(row['path']).read_bytes().splitlines(keepends=True)[row['start']-1:row['end']])\n    assert len(data)==row['bytes'] and hashlib.sha256(data).hexdigest()==row['sha256']\nfields=['slot.contract_id','slot.rule_label','slot.target_rule','slot.regex_index','result.status','result.input_identity']\nprobe=''.join(f'{field}: original=table; corrected=absent; both rejected\\n' for field in fields)\nprobe+='missing-field fixture probe: 24 observations passed; 6 mislabeled original fixtures\\n'\nfor host in ['puc','luajit']:\n    logs={\n        'native':'Lua native semantic runtime observation: 1 of 121 assertions failed\\n- nil callback value preserved: expected nil, got <no error object>\\n' if host=='puc' else 'Lua native semantic runtime observation: 121 assertions passed\\n',\n        'projection':'Lua immutable semantic runtime projection: 269 assertions passed\\n',\n        'source':'Lua semantic-index source foundation: 382 assertions passed\\n',\n        'graph':'semantic static graph assertions: 64\\n',\n        'static-prefix':'remaining-static helper prefix: loads; no original behavior assertions executed\\n',\n        'missing-fields':probe,\n    }\n    for name,expected in logs.items():\n        assert (p/f'{name}-{host}.log').read_text()==expected,(name,host)\n        expected_exit='1\\n' if (name,host)==('native','puc') else '0\\n'\n        assert (p/f'{name}-{host}.exit').read_text()==expected_exit,(name,host)\noriginal=Path('lua/test/semantic_index_runtime_projection_test.lua').read_text().splitlines(keepends=True)\nassert ''.join(original[239:267]) in (p/'missing-field-probe.lua').read_text()\nprint('PASS evidence verification: five exact source ranges; native PUC5.5 remains FAIL120/121 exit1 and LuaJIT passes121; projection269/source382/graph64 pass per host (1671/1672 total); static helper prefixes load with no original behavior assertions; 48 observations confirm six table-valued missing-field fixtures and correct absent-field rejection on both hosts.')\n")
(p / 'scope.json').write_text('[\n  {\n    "path": "lua/test/semantic_index_runtime_observation_native_test.lua",\n    "start": 258,\n    "end": 548,\n    "bytes": 12078,\n    "sha256": "0181e1d3daf434886aea1d6181774517d908e73e1d184f06d4f5a9bd49205694"\n  },\n  {\n    "path": "lua/test/semantic_index_runtime_projection_test.lua",\n    "start": 1,\n    "end": 472,\n    "bytes": 18678,\n    "sha256": "df7a3a31cb6c3355c07cee80423c4c1403635bf2f378d81769878cfb164bd018"\n  },\n  {\n    "path": "lua/test/semantic_index_source_foundation_test.lua",\n    "start": 1,\n    "end": 438,\n    "bytes": 19816,\n    "sha256": "c30a8a0dac24b535cdba5ab7cae89aa0b324150a8a0c8bbf77726936949d2e17"\n  },\n  {\n    "path": "lua/test/semantic_index_static_graph_test.lua",\n    "start": 1,\n    "end": 226,\n    "bytes": 9299,\n    "sha256": "5ffae9909fc65c99612f10987b285a95ff046e991a4d108119458499423a9189"\n  },\n  {\n    "path": "lua/test/semantic_index_static_remaining_test.lua",\n    "start": 1,\n    "end": 73,\n    "bytes": 2161,\n    "sha256": "dffb60b82839ac526d73a66789a23f97e502e2647b2407c64054f9428ec8737c"\n  }\n]\n')
(p / 'missing-field-probe.lua').write_text('local linkedspec = require("linkedspec")\nlocal observation = require("linkedspec.semantic_observation")\nlocal json = linkedspec.json\nlocal NIL = {}\nlocal function malformed_event(kind, overrides)\n  local fields\n  if kind == "slot" then\n    fields = {\n      contract_id = observation.CONTRACT_ID,\n      event_kind = observation.REGEX_SLOT_SELECTED,\n      rule_label = "Top",\n      target_rule = "Top",\n      regex_index = 0,\n      position = 1,\n    }\n  else\n    fields = {\n      contract_id = observation.CONTRACT_ID,\n      event_kind = observation.RULE_RESULT,\n      rule_label = "Top",\n      position = 2,\n      input_identity =\n        "input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece",\n      status = "succeeded",\n    }\n  end\n  for key, value in pairs(overrides or {}) do\n    fields[key] = value == NIL and nil or value\n  end\n  return observation._event_for_testing(fields)\nend\n\nlocal source = assert(io.open("capability_conformance/semantic_introspection/runtime.spec", "rb"))\nlocal text = assert(source:read("*a")); assert(source:close())\nlocal base = linkedspec.semantic_index(text, { logical_name = "runtime.spec", source_detail_ceiling = "text" })\nlocal cases = {\n  { "slot", "contract_id" }, { "slot", "rule_label" },\n  { "slot", "target_rule" }, { "slot", "regex_index" },\n  { "result", "status" }, { "result", "input_identity" },\n}\nlocal observations = 0\nfor _, case in ipairs(cases) do\n  local event = malformed_event(case[1], { [case[2]] = NIL })\n  local fields = {}\n  for _, key in ipairs({ "contract_id", "event_kind", "rule_label", "target_rule", "regex_index", "position", "input_identity", "status" }) do fields[key] = event[key] end\n  assert(fields[case[2]] == NIL and type(fields[case[2]]) == "table")\n  observations = observations + 1\n  local copied = {}; for key, value in pairs(fields) do copied[key] = value end\n  copied[case[2]] = nil\n  local missing = observation._event_for_testing(copied)\n  assert(missing[case[2]] == nil)\n  observations = observations + 1\n  for _, candidate in ipairs({ event, missing }) do\n    local events = { malformed_event("slot"), malformed_event("slot", { regex_index=1,position=2 }), malformed_event("result") }\n    events[case[1] == "slot" and 1 or 3] = candidate\n    local ok, failure = pcall(base.with_execution_observation, base, events)\n    assert(not ok and failure.code == "semantic_index_invalid_observation" and failure.stage == "execution_observation")\n    observations = observations + 1\n  end\n  print(case[1] .. "." .. case[2] .. ": original=table; corrected=absent; both rejected")\nend\nprint("missing-field fixture probe: " .. observations .. " observations passed; 6 mislabeled original fixtures")\n')
(p / 'verify-history.py').write_text("from pathlib import Path\nimport hashlib,json,subprocess\n\nbase='47bea50a5f05756eac9d117662aedd649e483c61'\nmanifest='docs/history/development-notes/manifest.jsonl'\nrows=Path(manifest).read_bytes().splitlines(keepends=True)\noldrows=subprocess.check_output(['git','show',base+':'+manifest]).splitlines(keepends=True)\nassert rows[2:]==oldrows[1:] and len(rows)==31\nentry=json.loads(rows[1]);data=Path(entry['target_path']).read_bytes()\nassert entry['source_commit']==base and entry['source_blob']=='4e0de58fcfa92d77889036d01460b7e69321f6e3'\nassert (entry['source_start_line'],entry['source_end_line'])==(244,459)\nassert entry['target_path']=='docs/history/development-notes/segment-4976-8f23f4b6bde6.md'\nassert len(data)==entry['byte_count']==14514 and len(data.splitlines())==entry['line_count']==216\nassert hashlib.sha256(data).hexdigest()==entry['sha256']=='8f23f4b6bde6b9b9796b1b35403a37aa7ece9bc3747ece75b8f9ed397ced9366'\nsource=subprocess.check_output(['git','show',base+':DEVELOPMENT_NOTES.md'])\nassert data==b''.join(source.splitlines(keepends=True)[243:459])\noldhistory=b''.join(Path(json.loads(row)['target_path']).read_bytes() for row in oldrows[1:])\nquery=subprocess.check_output(['perl','tools/read_document_history.pl','--surface','engineering_notes','--all'])\nassert query==data+oldhistory\nassert subprocess.check_output(['perl','tools/read_document_history.pl','--surface','engineering_notes','--segment','4976'])==data\nassert len(query)==2810230 and len(query.splitlines())==26654\nassert hashlib.sha256(query).hexdigest()=='b7a9ee168ccc682f07f7854258e813a0a6e0bf214bc1c66f0a9bbc93f1a665f1'\nroot=Path('DEVELOPMENT_NOTES.md').read_bytes()\nif subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()==base:\n    import re\n    starts=[m.start() for m in re.finditer(rb'^## ',root,re.M)]\n    assert root[:starts[0]]+root[starts[1]:]+b'\\n'+data==source\n    assert len(root)==26611 and len(root.splitlines())==249\n    assert hashlib.sha256(root+b'\\n'+query).hexdigest()=='5c1bc075b2a0955debeb3731836e9b1a25f6d2a1b84a87d22ff45498ecec986a'\nprint('PASS: engineering-notes segment4976 is the exact216-line/14514-byte clean-HEAD suffix; all prior manifest rows and archive bytes remain exact; current hot-root reconstruction includes its original one-LF record separator')\n")
LUA_SEMANTIC_FIXTURE_READING_46
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua146/select-tests.py
for host in puc luajit; do
  for item in native projection source graph static-prefix missing-fields; do
    case "$item" in
      native) script=lua/test/semantic_index_runtime_observation_native_test.lua ;;
      projection) script=lua/test/semantic_index_runtime_projection_test.lua ;;
      source) script=lua/test/semantic_index_source_foundation_test.lua ;;
      graph) script=lua/test/semantic_index_static_graph_test.lua ;;
      static-prefix) script=.linkedspec-data/scratch/lua146/static-helper-prefix.lua ;;
      missing-fields) script=.linkedspec-data/scratch/lua146/missing-field-probe.lua ;;
    esac
    status=0
    bash tools/run_lua_project_data.sh "$host" "$script" > ".linkedspec-data/scratch/lua146/$item-$host.log" 2>&1 || status=$?
    printf '%s\n' "$status" > ".linkedspec-data/scratch/lua146/$item-$host.exit"
  done
done
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua146/verify.py
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua146/verify-history.py
```

Related: [[lua-query-generated-observation-consumer-reading]],
[[lua-startup-reading-coverage]], [[lua-semantic-projector-reading-and-source-ownership-gaps]].

# Preservation and focused completion

Independent preservation keeps 1,421 prior source/Knowledge/decision/history/policy
files byte-exact, with the one changed notes manifest independently verified.
Of 2,582 prior task nodes, 2,577 remain exact; only this reading leaf, repair parent,
existing .2.1/.2.2 and startup .3.6 change. Exactly three new .2.34 nodes are added.
All ninety previous Known book headings remain, with one new fixture-coverage
heading; the parked authoring tree is byte-exact. All five embedded payloads match
scratch exactly, and independent reconstruction confirms every source range and
all 46 completed groups with unchanged inventory/range/group digests.

History checks pass 34 mutation controls, three surfaces and 68 immutable segments;
both rollover pressure checks pass. Memory remains 60 lines with exact activation
and handoff semantics. Knowledge regeneration reports 1,132 cards /9,044 question
keys. The book renders with its existing large-search-index warning at 10,176,433
bytes, still owned by startup .41.9. Whitespace checks pass after the documented
history-boundary normalization. Normal doctrine and activation hooks are required
at landing; no canonical CI or push result is claimed here.
