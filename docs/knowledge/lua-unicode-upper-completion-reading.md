---
id: lua-unicode-upper-completion-reading
title: Lua reading completes uppercase mappings and starts the Cased property table
answers:
  - "what exact Lua source did startup reading child 27 cover"
  - "how many Lua uppercase expansions were read in child 27"
  - "were all remaining Lua uppercase mappings compared with neutral data and executed"
  - "which Lua Cased property ranges are read after child 27"
date: 2026-09-13
status: exact generated-table reading complete; no new scoped defect found
tags: [lua, unicode, casing, generated-data, startup, evidence]
evidence: "LUA-STARTUP-READING.1.27 activates from 2e7046a44d0f6cafdc5bfeccc31f76c72b6ab122. All 1500 lines /35947 bytes of unicode_case_mapping.lua1670-3169 are read in six complete windows. All 1482 upper entries and 15 property ranges match neutral data; both installed hosts pass 2964 complete uppercase observations. The prior 198 fixture assertions and offline generation proof remain source-identical and are not recounted as fresh runs. No source change or repair closure."
reverify: "Run LUA_UNICODE_UPPER_READING_27 and the managed commands below; earlier complete fixture replay remains in lua-unicode-lower-completion-reading."
---

# Exact scope and comprehension

Read every `lua/src/linkedspec/unicode_case_mapping.lua` line 1670–3169 in six
complete windows: 1670–1919, 1920–2169, 2170–2419, 2420–2669, 2670–2919 and
2920–3169. There is no filtering, omitted table data or truncated viewing window.
The range is 1,500 fragments /35,947 bytes, raw SHA-256
`37f0e36c09a5c94f73cb505aedf5715660d029ab2725e424b2bb56501798cdb6`;
the owned ordered range digest is
`29933fa8d627a20c344cab6e3c6a3f21827fd84ed2d8056f0b22161e21d64018`.
All 99 Lua sources remain identical to baseline
`baeb984e36a94a15951cd23d4c52def5064cdaca`.

The remaining 1,482 uppercase mappings run from U+014F → U+014E at line 1670
through U+1E943 → U+1E921 at line 3151. Combined with the previous 99 entries,
the full 1,581-entry uppercase table is physically read. The scoped output lengths
are 1,382 single-scalar mappings, 84 two-scalar expansions and 16 three-scalar
expansions; none of these scoped entries maps to itself.

Examples include U+01F0 → U+004A U+030C, U+0390 → U+0399 U+0308 U+0301,
Greek iota-subscript expansions, Latin ligatures such as U+FB03 → `FFI`, Armenian
ligatures, regular and irregular Latin/Greek/Cyrillic mappings, fullwidth letters
and supplementary-plane scripts. These are full mapping sequences; the reading
does not introduce composition, normalization or locale-specific behavior.

After three closing/separator/declaration lines, the `CASED` table begins with
fifteen inclusive ranges at 3155–3169. They run from U+0041–U+005A through
U+0370–U+0373 and include singleton properties such as U+0345. Every endpoint is
compared with the neutral property data. The remaining `Cased`/`Case_Ignorable`
ranges and the existing UTF-8/contextual conversion algorithm stay in `.1.28`.
Reading the first property ranges does not establish complete property traversal.

Previously retrieved [[six-variant-unicode-17-case-parity]],
[[unicode-17-case-contract-data]] and [[lua-unicode-lower-completion-reading]]
remain the canonical homes for the shared contract, offline inputs, contextual
Final Sigma and prior native fixture proof. No new external Unicode source or
host Unicode library is used. These records are preserved rather than re-derived.

Reading totals 27/51 groups, 36,151 fragments /1,357,777 bytes, with 47 complete
files and the Unicode module partial. `.1.28` reads the casing suffix 3170–3846
and rule-label prefix 1–823. No newly confirmed defect is found in this range;
all thirty repair roots, known failures, startup and supported-PUC prerequisites,
and the parked named-argument direction remain unchanged.

# Focused verification and limits

The preparation script checks the exact source range, classifies every scoped
line, verifies all 1,482 mapping sequences, ordering and unique keys, and compares
all fifteen ranges against the existing neutral contract. Output-length counts
are checked independently. The Unicode version remains 17.0.0 with data digest
`5c17653094c49a3bd69222f6e8bde5de5ebd445a121453ccb156ea540a5e3bae`.

Both installed hosts execute each scoped uppercase mapping using one scalar as
input through the actual module. All 2,964 observations preserve exact source
line, operation, input, expected and actual strings. Each complete per-host JSON
result has canonical SHA-256
`c8c517bcde21a733960c0d9dfb69ee3a617fc0ed8cce02de97b20c431d419173`.
These are PUC 5.5.1 and LuaJIT results, not proof on the pending PUC 5.4 target.

The prior `.1.26` Unicode consumer passed 99 assertions per host through direct,
helper, receiver and array paths over twelve fixtures. Its source remains exactly
equal to that clean commit. The `.1.25` regeneration and neutral proof remain
applicable through exact comparison of their twelve inputs: four upstream files,
generator, checker, neutral JSON and five backend modules. Neither earlier run
is counted as fresh `.1.27` execution. There is no full CI, source/tool change,
dependency build, push or new cross-backend runtime claim.

## Reproduction

The exact preparation, native probe and independent verifier recreate only
repository-local scratch data and retain complete scoped results.

```bash
bash tools/project_data_run.sh python3 - <<'LUA_UNICODE_UPPER_READING_27'
from pathlib import Path
p = Path(".linkedspec-data/scratch/lua127")
p.mkdir(parents=True, exist_ok=True)
(p / 'prepare.py').write_text("from pathlib import Path\nimport hashlib\nimport json\nimport re\nimport subprocess\n\nroot = Path('.linkedspec-data/scratch/lua127')\nroot.mkdir(parents=True, exist_ok=True)\npath = Path('lua/src/linkedspec/unicode_case_mapping.lua')\nraw = path.read_bytes()\nscoped = b''.join(raw.splitlines(keepends=True)[1669:3169])\nassert len(scoped) == 35947\nassert hashlib.sha256(scoped).hexdigest() == '37f0e36c09a5c94f73cb505aedf5715660d029ab2725e424b2bb56501798cdb6'\ncontract = json.loads(Path('capability_conformance/unicode_case_contract.json').read_text())\nassert contract['unicode_version'] == '17.0.0'\nassert contract['data_sha256'] == '5c17653094c49a3bd69222f6e8bde5de5ebd445a121453ccb156ea540a5e3bae'\nmapping = {int(a, 16): [int(b, 16) for b in bs] for a, bs in contract['upper_mappings']}\nrows = []\nranges = []\nfor number, line in enumerate(scoped.decode().splitlines(), 1670):\n    match = re.fullmatch(r'  \\[0x([0-9A-F]+)\\] = \\{(.*?)\\},', line)\n    if match:\n        scalar = int(match[1], 16)\n        values = [int(value, 16) for value in match[2].split(', ')]\n        assert mapping[scalar] == values\n        rows.append({'line': number, 'operation': 'upper', 'source': scalar, 'result': values,\n                     'input': chr(scalar), 'expected': ''.join(chr(value) for value in values)})\n        continue\n    match = re.fullmatch(r'  \\{0x([0-9A-F]+), 0x([0-9A-F]+)\\},', line)\n    if match:\n        ranges.append([int(match[1], 16), int(match[2], 16)])\n        continue\n    assert line in ['}', '', 'local CASED = {'], (number, line)\nassert len(rows) == 1482 and len(ranges) == 15\nassert ranges == [[int(a, 16), int(b, 16)] for a, b in contract['cased_ranges'][:15]]\nassert [row['source'] for row in rows] == sorted({row['source'] for row in rows})\nassert {n: sum(len(row['result']) == n for row in rows) for n in [1, 2, 3]} == {1: 1382, 2: 84, 3: 16}\n(root / 'mappings.json').write_text(json.dumps(rows, ensure_ascii=False, separators=(',', ':')) + '\\n')\n\ngeneration_base = '67a97d3d32beb8b83fa1864e45102966699d7836'\npaths = ['capability_conformance/unicode_case_contract.json',\n         'unicode_case/generate_unicode_case_contract.py', 'tools/check_unicode_case_contract.py',\n         'perl/LinkedSpec/UnicodeCaseMapping.pm', 'rust/linkedspec-runtime/src/unicode_case_mapping.rs',\n         'dart/lib/src/runtime/unicode_case_mapping.dart', 'julia/src/runtime/UnicodeCaseMapping.jl', str(path)]\npaths += ['unicode_case/upstream/17.0.0/' + name + '.gz'\n          for name in ['LICENSE.txt', 'DerivedCoreProperties.txt', 'UnicodeData.txt', 'SpecialCasing.txt']]\nfor name in paths:\n    assert Path(name).read_bytes() == subprocess.check_output(['git', 'show', generation_base + ':' + name]), name\nconsumer_base = '2e7046a44d0f6cafdc5bfeccc31f76c72b6ab122'\nassert Path('lua/test/run.lua').read_bytes() == subprocess.check_output(['git', 'show', consumer_base + ':lua/test/run.lua'])\nprint('Lua .1.27: 1482 scoped uppercase mappings and 15 property ranges equal neutral data; generation and prior consumer sources remain exact')\n")
(p / 'mappings.lua').write_text('local json=require("linkedspec.json")\nlocal casing=require("linkedspec.unicode_case_mapping")\nlocal handle=assert(io.open(".linkedspec-data/scratch/lua127/mappings.json","rb"))\nlocal rows=json.decode(handle:read("*a"));handle:close()\nlocal results=json.array()\nfor index,row in ipairs(rows)do\n local actual=casing[row.operation=="lower" and "lowercase" or "uppercase"](row.input)\n assert(actual==row.expected,"mapping differs at source line "..row.line)\n results[index]=json.harray({line=row.line,operation=row.operation,input=row.input,expected=row.expected,actual=actual})\nend\nassert(#results==1482,"scope count drift")\nio.write(json.encode(results),"\\n")\n')
(p / 'verify.py').write_text("from pathlib import Path\nimport hashlib\nimport json\n\nroot = Path('.linkedspec-data/scratch/lua127')\nrows = json.loads((root / 'mappings.json').read_text())\nexpected = [{'line': row['line'], 'operation': row['operation'], 'input': row['input'],\n             'expected': row['expected'], 'actual': row['expected']} for row in rows]\nassert len(expected) == 1482\nfor host in ('puc', 'luajit'):\n    actual = json.loads((root / ('mappings-' + host + '.json')).read_text())\n    assert actual == expected\n    canonical = json.dumps(actual, ensure_ascii=False, sort_keys=True, separators=(',', ':')).encode()\n    assert hashlib.sha256(canonical).hexdigest() == 'c8c517bcde21a733960c0d9dfb69ee3a617fc0ed8cce02de97b20c431d419173'\nprint('Lua .1.27: 2964 complete uppercase mapping observations pass on the two installed hosts; prior fixture assertions are not recounted')\n")
LUA_UNICODE_UPPER_READING_27
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua127/prepare.py
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua127/mappings.lua > .linkedspec-data/scratch/lua127/mappings-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua127/mappings.lua > .linkedspec-data/scratch/lua127/mappings-luajit.json
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua127/verify.py
```

Related facts: [[lua-startup-reading-coverage]],
[[lua-reading-evidence-capacity-admission]].

## Preservation and documentation verification

The independent audit preserves all 1,402 prior source, Knowledge, decision,
immutable-history and policy files. Only the current reading leaf and startup
.3.6 change among 2,564 prior task nodes; the other 2,562 remain exact and no new
node is introduced. Both historical suffixes, live History query instructions,
all 87 Known book headings and the parked authoring tree are exact. Three embedded
payloads match the executed originals. Full range reconstruction reproduces all
baseline counts/digests and 27 completed groups without unread-source credit.

Knowledge regeneration reports 1,113 facts /8,913 question keys. Memory passes at
60 lines. Both histories fit without rollover: Changes 403 lines /28,888 bytes;
Notes 333 /26,034. The book renders; its 10,114,003-byte search-index warning stays
startup .41.9-owned. `git diff --check` passes. Normal registered hooks remain
required for the focused commit; no canonical gate or source repair is claimed.
